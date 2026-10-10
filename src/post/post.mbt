// r186: 没有同名灰度通道。输出路径 `PostProcessing` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/PostProcessing.js#L9 ; 全屏通道形状 `ShaderPass` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/ShaderPass.js#L20 ; `linearToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/nodes/display/ToneMappingFunctions.js#L15 ; `reinhardToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/nodes/display/ToneMappingFunctions.js#L39

///|
const WEIGHT_R : Double = 0.25

///|
const WEIGHT_G : Double = 0.5

///|
const WEIGHT_B : Double = 0.25

///|
fn clamp_amount(amount : Double) -> Double {
  if amount < 0.0 {
    0.0
  } else if amount > 1.0 {
    1.0
  } else {
    amount
  }
}

///|
/// 把颜色往灰度上混。`amount` 为 0 时保持原色，为 1 时只剩灰度。
/// 灰度是 `0.25 r + 0.5 g + 0.25 b`，三项都能用二进制精确表示。
/// r186: 没有同名类。全屏通道形状 `ShaderPass` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/ShaderPass.js#L20
pub(all) struct GrayscalePass {
  mut amount : Double
}

///|
pub fn GrayscalePass::new(amount? : Double = 1.0) -> GrayscalePass {
  { amount: clamp_amount(amount), }
}

///|
pub fn GrayscalePass::set_amount(self : GrayscalePass, amount : Double) -> Unit {
  self.amount = clamp_amount(amount)
}

///|
/// 与全屏着色器相同的混合。`amount` 会先夹到 \[0, 1\]。
pub fn grayscale(
  r : Double,
  g : Double,
  b : Double,
  amount : Double,
) -> @math.Color {
  let t = clamp_amount(amount)
  let gray = r * WEIGHT_R + g * WEIGHT_G + b * WEIGHT_B
  @math.Color::new(
    r=r + (gray - r) * t,
    g=g + (gray - g) * t,
    b=b + (gray - b) * t,
  )
}

///|
fn write_f32(dst : FixedArray[Byte], offset : Int, value : Double) -> Unit {
  let bytes = Float::from_double(value).to_le_bytes()
  let mut index = 0
  while index < 4 {
    dst[offset + index] = bytes.at(index)
    index = index + 1
  }
}

///|
/// 16 字节 uniform，`amount` 在第一个 `f32`。
pub fn pack_amount(amount : Double) -> FixedArray[Byte] {
  let dst = FixedArray::make(16, b'\x00')
  write_f32(dst, 0, clamp_amount(amount))
  dst
}

///|
/// 全屏三角形。颜色目标的顶在 v = 0，窗口的顶在 clip y = 1，所以 v 用 `0.5 - y * 0.5`。
/// r186: `PostProcessing` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/PostProcessing.js#L9
pub fn grayscale_wgsl() -> String {
  let code =
    #|struct VertexOutput {
    #|  @builtin(position) clip : vec4<f32>,
    #|  @location(0) uv : vec2<f32>,
    #|}
    #|
    #|@vertex
    #|fn vs(@builtin(vertex_index) id : u32) -> VertexOutput {
    #|  let x = select(-1.0, 3.0, id == 1u);
    #|  let y = select(-1.0, 3.0, id == 2u);
    #|  var output : VertexOutput;
    #|  output.clip = vec4<f32>(x, y, 0.0, 1.0);
    #|  output.uv = vec2<f32>(x * 0.5 + 0.5, 0.5 - y * 0.5);
    #|  return output;
    #|}
    #|
    #|struct GrayParams {
    #|  amount : f32,
    #|  pad0 : f32,
    #|  pad1 : f32,
    #|  pad2 : f32,
    #|}
    #|
    #|@group(0) @binding(0) var color_tex : texture_2d<f32>;
    #|@group(0) @binding(1) var color_samp : sampler;
    #|@group(0) @binding(2) var<uniform> params : GrayParams;
    #|
    #|@fragment
    #|fn fs(input : VertexOutput) -> @location(0) vec4<f32> {
    #|  let color = textureSample(color_tex, color_samp, input.uv);
    #|  let gray = dot(color.rgb, vec3<f32>(0.25, 0.5, 0.25));
    #|  let rgb = mix(color.rgb, vec3<f32>(gray), params.amount);
    #|  return vec4<f32>(rgb, color.a);
    #|}
  code
}

///|
fn clamp01(value : Double) -> Double {
  if value < 0.0 {
    0.0
  } else if value > 1.0 {
    1.0
  } else {
    value
  }
}

///|
fn reinhard_channel(value : Double, exposure : Double) -> Double {
  let scaled = value * exposure
  let denom = scaled + 1.0
  if denom == 0.0 {
    0.0
  } else {
    clamp01(scaled / denom)
  }
}

///|
/// 屏幕输出上的色调映射。默认 `No`、曝光 1，与 r186 `Renderer` 相同。
/// `No` 不乘曝光。`Linear` 和 `Reinhard` 先乘曝光。Cineon、ACES、AgX、Neutral 还没做。
/// r186: `toneMapping` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Renderer.js#L192
pub(all) struct ToneMappingPass {
  mut mapping : @constants.ToneMapping
  mut exposure : Double
}

///|
pub fn ToneMappingPass::new(
  mapping? : @constants.ToneMapping,
  exposure? : Double = 1.0,
) -> ToneMappingPass {
  let mapping = match mapping {
    None => @constants.ToneMapping::No
    Some(mapping) => mapping
  }
  { mapping, exposure, }
}

///|
pub fn ToneMappingPass::set_mapping(
  self : ToneMappingPass,
  mapping : @constants.ToneMapping,
) -> Unit {
  self.mapping = mapping
}

///|
pub fn ToneMappingPass::set_exposure(
  self : ToneMappingPass,
  exposure : Double,
) -> Unit {
  self.exposure = exposure
}

///|
/// 与全屏着色器相同的曲线。`No` 原样返回，不看曝光。
/// r186: `linearToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/nodes/display/ToneMappingFunctions.js#L15 ; `reinhardToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/nodes/display/ToneMappingFunctions.js#L39
pub fn tone_map(
  r : Double,
  g : Double,
  b : Double,
  mapping : @constants.ToneMapping,
  exposure : Double,
) -> @math.Color {
  match mapping {
    No => @math.Color::new(r~, g~, b~)
    Linear =>
      @math.Color::new(
        r=clamp01(r * exposure),
        g=clamp01(g * exposure),
        b=clamp01(b * exposure),
      )
    Reinhard =>
      @math.Color::new(
        r=reinhard_channel(r, exposure),
        g=reinhard_channel(g, exposure),
        b=reinhard_channel(b, exposure),
      )
  }
}

///|
/// 16 字节 uniform。第一个 `f32` 是映射编号，第二个是曝光。
pub fn pack_tone(
  mapping : @constants.ToneMapping,
  exposure : Double,
) -> FixedArray[Byte] {
  let dst = FixedArray::make(16, b'\x00')
  write_f32(dst, 0, mapping.to_int().to_double())
  write_f32(dst, 4, exposure)
  dst
}

///|
/// 全屏三角形，曲线与 `tone_map` 相同。`mapping` 小于 0.5 是 `No`，大于 1.5 是 `Reinhard`。
/// r186: `reinhardToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/nodes/display/ToneMappingFunctions.js#L39
pub fn tone_wgsl() -> String {
  let code =
    #|struct VertexOutput {
    #|  @builtin(position) clip : vec4<f32>,
    #|  @location(0) uv : vec2<f32>,
    #|}
    #|
    #|@vertex
    #|fn vs(@builtin(vertex_index) id : u32) -> VertexOutput {
    #|  let x = select(-1.0, 3.0, id == 1u);
    #|  let y = select(-1.0, 3.0, id == 2u);
    #|  var output : VertexOutput;
    #|  output.clip = vec4<f32>(x, y, 0.0, 1.0);
    #|  output.uv = vec2<f32>(x * 0.5 + 0.5, 0.5 - y * 0.5);
    #|  return output;
    #|}
    #|
    #|struct ToneParams {
    #|  mapping : f32,
    #|  exposure : f32,
    #|  pad0 : f32,
    #|  pad1 : f32,
    #|}
    #|
    #|@group(0) @binding(0) var color_tex : texture_2d<f32>;
    #|@group(0) @binding(1) var color_samp : sampler;
    #|@group(0) @binding(2) var<uniform> params : ToneParams;
    #|
    #|@fragment
    #|fn fs(input : VertexOutput) -> @location(0) vec4<f32> {
    #|  let color = textureSample(color_tex, color_samp, input.uv);
    #|  if (params.mapping < 0.5) {
    #|    return color;
    #|  }
    #|  let scaled = color.rgb * params.exposure;
    #|  let mapped = select(clamp(scaled, vec3<f32>(0.0), vec3<f32>(1.0)), clamp(scaled / (scaled + vec3<f32>(1.0)), vec3<f32>(0.0), vec3<f32>(1.0)), params.mapping > 1.5);
    #|  return vec4<f32>(mapped, color.a);
    #|}
  code
}
