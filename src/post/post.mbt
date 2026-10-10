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
