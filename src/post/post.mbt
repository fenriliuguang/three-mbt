// r186: 没有同名灰度通道。输出路径 `PostProcessing` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/PostProcessing.js#L9 ; 全屏通道形状 `ShaderPass` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/ShaderPass.js#L20 ; `linearToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/nodes/display/ToneMappingFunctions.js#L15 ; `reinhardToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/nodes/display/ToneMappingFunctions.js#L39 ; `cineonToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/nodes/display/ToneMappingFunctions.js#L65 ; `acesFilmicToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/nodes/display/ToneMappingFunctions.js#L107 ; `agxToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/nodes/display/ToneMappingFunctions.js#L166 ; `neutralToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/nodes/display/ToneMappingFunctions.js#L208

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
priv struct ToneVec {
  x : Double
  y : Double
  z : Double
}

///|
fn apply_rows(
  r0x : Double,
  r0y : Double,
  r0z : Double,
  r1x : Double,
  r1y : Double,
  r1z : Double,
  r2x : Double,
  r2y : Double,
  r2z : Double,
  v : ToneVec,
) -> ToneVec {
  {
    x: r0x * v.x + r0y * v.y + r0z * v.z,
    y: r1x * v.x + r1y * v.y + r1z * v.z,
    z: r2x * v.x + r2y * v.y + r2z * v.z,
  }
}

///|
fn cineon_channel(value : Double, exposure : Double) -> Double {
  let x = value * exposure - 0.004
  let toe = if x > 0.0 { x } else { 0.0 }
  let a = toe * (toe * 6.2 + 0.5)
  let b = toe * (toe * 6.2 + 1.7) + 0.06
  if b == 0.0 {
    0.0
  } else {
    @std.pow(a / b, 2.2)
  }
}

///|
fn aces_fit(value : Double) -> Double {
  let a = value * (value + 0.0245786) - 0.000090537
  let b = value * ((value + 0.4329510) * 0.983729) + 0.238081
  if b == 0.0 {
    0.0
  } else {
    a / b
  }
}

///|
fn aces_color(r : Double, g : Double, b : Double, exposure : Double) -> ToneVec {
  let scaled : ToneVec = {
    x: r * exposure / 0.6,
    y: g * exposure / 0.6,
    z: b * exposure / 0.6,
  }
  let input = apply_rows(
    0.59719, 0.35458, 0.04823, 0.07600, 0.90834, 0.01566, 0.02840, 0.13383, 0.83777,
    scaled,
  )
  let fitted : ToneVec = {
    x: aces_fit(input.x),
    y: aces_fit(input.y),
    z: aces_fit(input.z),
  }
  let output = apply_rows(
    1.60475, -0.53108, -0.07367, -0.10208, 1.10813, -0.00605, -0.00327, -0.07276,
    1.07602, fitted,
  )
  { x: clamp01(output.x), y: clamp01(output.y), z: clamp01(output.z), }
}

///|
fn agx_contrast(value : Double) -> Double {
  let x2 = value * value
  let x4 = x2 * x2
  15.5 * (x4 * x2) -
  40.14 * (x4 * value) +
  31.96 * x4 -
  6.868 * (x2 * value) +
  0.4298 * x2 +
  0.1191 * value -
  0.00232
}

///|
fn agx_color(r : Double, g : Double, b : Double, exposure : Double) -> ToneVec {
  let scaled : ToneVec = { x: r * exposure, y: g * exposure, z: b * exposure, }
  let rec = apply_rows(
    0.6274, 0.3293, 0.0433, 0.0691, 0.9195, 0.0113, 0.0164, 0.0880, 0.8956, scaled,
  )
  let inset = apply_rows(
    0.856627153315983, 0.0951212405381588, 0.0482516061458583, 0.137318972929847,
    0.761241990602591, 0.101439036467562, 0.11189821299995, 0.0767994186031903, 0.811302368396859,
    rec,
  )
  let lo = -12.47393
  let hi = 4.026069
  let span = hi - lo
  fn encode(value : Double) -> Double {
    let safe = if value > 1.0e-10 { value } else { 1.0e-10 }
    let t = (@std.log2(safe) - lo) / span
    if t < 0.0 {
      0.0
    } else if t > 1.0 {
      1.0
    } else {
      t
    }
  }
  let encoded : ToneVec = {
    x: agx_contrast(encode(inset.x)),
    y: agx_contrast(encode(inset.y)),
    z: agx_contrast(encode(inset.z)),
  }
  let outset = apply_rows(
    1.1271005818144368, -0.11060664309660323, -0.016493938717834573, -0.1413297634984383,
    1.157823702216272, -0.016493938717834257, -0.14132976349843826, -0.11060664309660294,
    1.2519364065950405, encoded,
  )
  fn gamma(value : Double) -> Double {
    let raised = if value > 0.0 { value } else { 0.0 }
    @std.pow(raised, 2.2)
  }
  let graded : ToneVec = {
    x: gamma(outset.x),
    y: gamma(outset.y),
    z: gamma(outset.z),
  }
  let linear = apply_rows(
    1.6605, -0.5876, -0.0728, -0.1246, 1.1329, -0.0083, -0.0182, -0.1006, 1.1187,
    graded,
  )
  { x: clamp01(linear.x), y: clamp01(linear.y), z: clamp01(linear.z), }
}

///|
fn neutral_color(
  r : Double,
  g : Double,
  b : Double,
  exposure : Double,
) -> ToneVec {
  let start = 0.76
  let mut x = r * exposure
  let mut y = g * exposure
  let mut z = b * exposure
  let mut min_channel = x
  if y < min_channel {
    min_channel = y
  }
  if z < min_channel {
    min_channel = z
  }
  let offset = if min_channel < 0.08 {
    min_channel - 6.25 * min_channel * min_channel
  } else {
    0.04
  }
  x = x - offset
  y = y - offset
  z = z - offset
  let mut peak = x
  if y > peak {
    peak = y
  }
  if z > peak {
    peak = z
  }
  if peak < start {
    { x, y, z, }
  } else {
    let d = 1.0 - start
    let new_peak = 1.0 - d * d / (peak + d - start)
    let scale = new_peak / peak
    x = x * scale
    y = y * scale
    z = z * scale
    let mix_t = 1.0 - 1.0 / (0.15 * (peak - new_peak) + 1.0)
    let keep = 1.0 - mix_t
    {
      x: x * keep + new_peak * mix_t,
      y: y * keep + new_peak * mix_t,
      z: z * keep + new_peak * mix_t,
    }
  }
}

///|
/// 屏幕输出上的色调映射。默认 `No`、曝光 1，与 r186 `Renderer` 相同。
/// `No` 不乘曝光。其余曲线先乘曝光。`Custom` 没有曲线。
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
/// r186: `linearToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/nodes/display/ToneMappingFunctions.js#L15 ; `reinhardToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/nodes/display/ToneMappingFunctions.js#L39 ; `cineonToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/nodes/display/ToneMappingFunctions.js#L65 ; `acesFilmicToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/nodes/display/ToneMappingFunctions.js#L107 ; `agxToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/nodes/display/ToneMappingFunctions.js#L166 ; `neutralToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/nodes/display/ToneMappingFunctions.js#L208
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
    Cineon =>
      @math.Color::new(
        r=cineon_channel(r, exposure),
        g=cineon_channel(g, exposure),
        b=cineon_channel(b, exposure),
      )
    ACES => {
      let mapped = aces_color(r, g, b, exposure)
      @math.Color::new(r=mapped.x, g=mapped.y, b=mapped.z)
    }
    AgX => {
      let mapped = agx_color(r, g, b, exposure)
      @math.Color::new(r=mapped.x, g=mapped.y, b=mapped.z)
    }
    Neutral => {
      let mapped = neutral_color(r, g, b, exposure)
      @math.Color::new(r=mapped.x, g=mapped.y, b=mapped.z)
    }
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
/// 全屏三角形，曲线与 `tone_map` 相同。编号 0 是 `No`，5 是没有曲线的 `Custom`。
/// r186: `acesFilmicToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/nodes/display/ToneMappingFunctions.js#L107
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
    #|fn cineon_map(scaled : vec3<f32>) -> vec3<f32> {
    #|  let x = max(scaled - vec3<f32>(0.004), vec3<f32>(0.0));
    #|  let a = x * (x * 6.2 + 0.5);
    #|  let b = x * (x * 6.2 + 1.7) + 0.06;
    #|  return pow(a / b, vec3<f32>(2.2));
    #|}
    #|
    #|fn aces_map(scaled : vec3<f32>) -> vec3<f32> {
    #|  let input_mat = mat3x3<f32>(
    #|    vec3<f32>(0.59719, 0.07600, 0.02840),
    #|    vec3<f32>(0.35458, 0.90834, 0.13383),
    #|    vec3<f32>(0.04823, 0.01566, 0.83777)
    #|  );
    #|  let output_mat = mat3x3<f32>(
    #|    vec3<f32>(1.60475, -0.10208, -0.00327),
    #|    vec3<f32>(-0.53108, 1.10813, -0.07276),
    #|    vec3<f32>(-0.07367, -0.00605, 1.07602)
    #|  );
    #|  var c = input_mat * (scaled / 0.6);
    #|  let a = c * (c + vec3<f32>(0.0245786)) - vec3<f32>(0.000090537);
    #|  let b = c * ((c + vec3<f32>(0.4329510)) * 0.983729) + vec3<f32>(0.238081);
    #|  c = output_mat * (a / b);
    #|  return clamp(c, vec3<f32>(0.0), vec3<f32>(1.0));
    #|}
    #|
    #|fn agx_contrast(x : vec3<f32>) -> vec3<f32> {
    #|  let x2 = x * x;
    #|  let x4 = x2 * x2;
    #|  return 15.5 * (x4 * x2) - 40.14 * (x4 * x) + 31.96 * x4 - 6.868 * (x2 * x) + 0.4298 * x2 + 0.1191 * x - 0.00232;
    #|}
    #|
    #|fn agx_map(scaled : vec3<f32>) -> vec3<f32> {
    #|  let to_rec = mat3x3<f32>(
    #|    vec3<f32>(0.6274, 0.0691, 0.0164),
    #|    vec3<f32>(0.3293, 0.9195, 0.0880),
    #|    vec3<f32>(0.0433, 0.0113, 0.8956)
    #|  );
    #|  let inset = mat3x3<f32>(
    #|    vec3<f32>(0.856627153315983, 0.137318972929847, 0.11189821299995),
    #|    vec3<f32>(0.0951212405381588, 0.761241990602591, 0.0767994186031903),
    #|    vec3<f32>(0.0482516061458583, 0.101439036467562, 0.811302368396859)
    #|  );
    #|  let outset = mat3x3<f32>(
    #|    vec3<f32>(1.1271005818144368, -0.1413297634984383, -0.14132976349843826),
    #|    vec3<f32>(-0.11060664309660323, 1.157823702216272, -0.11060664309660294),
    #|    vec3<f32>(-0.016493938717834573, -0.016493938717834257, 1.2519364065950405)
    #|  );
    #|  let to_srgb = mat3x3<f32>(
    #|    vec3<f32>(1.6605, -0.1246, -0.0182),
    #|    vec3<f32>(-0.5876, 1.1329, -0.1006),
    #|    vec3<f32>(-0.0728, -0.0083, 1.1187)
    #|  );
    #|  var c = inset * (to_rec * scaled);
    #|  c = max(c, vec3<f32>(1e-10));
    #|  c = log2(c);
    #|  c = clamp((c - vec3<f32>(-12.47393)) / vec3<f32>(4.026069 - -12.47393), vec3<f32>(0.0), vec3<f32>(1.0));
    #|  c = outset * agx_contrast(c);
    #|  c = pow(max(c, vec3<f32>(0.0)), vec3<f32>(2.2));
    #|  return clamp(to_srgb * c, vec3<f32>(0.0), vec3<f32>(1.0));
    #|}
    #|
    #|fn neutral_map(scaled : vec3<f32>) -> vec3<f32> {
    #|  let start = 0.76;
    #|  let x = min(scaled.r, min(scaled.g, scaled.b));
    #|  let offset = select(0.04, x - 6.25 * x * x, x < 0.08);
    #|  var c = scaled - vec3<f32>(offset);
    #|  let peak = max(c.r, max(c.g, c.b));
    #|  if (peak < start) {
    #|    return c;
    #|  }
    #|  let d = 1.0 - start;
    #|  let new_peak = 1.0 - (d * d) / (peak + d - start);
    #|  c = c * (new_peak / peak);
    #|  let g = 1.0 - 1.0 / (0.15 * (peak - new_peak) + 1.0);
    #|  return mix(c, vec3<f32>(new_peak), g);
    #|}
    #|
    #|@group(0) @binding(0) var color_tex : texture_2d<f32>;
    #|@group(0) @binding(1) var color_samp : sampler;
    #|@group(0) @binding(2) var<uniform> params : ToneParams;
    #|
    #|@fragment
    #|fn fs(input : VertexOutput) -> @location(0) vec4<f32> {
    #|  let color = textureSample(color_tex, color_samp, input.uv);
    #|  if (params.mapping < 0.5 || (params.mapping > 4.5 && params.mapping < 5.5)) {
    #|    return color;
    #|  }
    #|  let scaled = color.rgb * params.exposure;
    #|  var mapped = scaled;
    #|  if (params.mapping < 1.5) {
    #|    mapped = clamp(scaled, vec3<f32>(0.0), vec3<f32>(1.0));
    #|  } else if (params.mapping < 2.5) {
    #|    mapped = clamp(scaled / (scaled + vec3<f32>(1.0)), vec3<f32>(0.0), vec3<f32>(1.0));
    #|  } else if (params.mapping < 3.5) {
    #|    mapped = cineon_map(scaled);
    #|  } else if (params.mapping < 4.5) {
    #|    mapped = aces_map(scaled);
    #|  } else if (params.mapping < 6.5) {
    #|    mapped = agx_map(scaled);
    #|  } else {
    #|    mapped = neutral_map(scaled);
    #|  }
    #|  return vec4<f32>(mapped, color.a);
    #|}
  code
}
