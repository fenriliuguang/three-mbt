// r186: `CopyShader` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/shaders/CopyShader.js#L12

///|
/// 全屏复制。`opacity` 默认 1，四个通道都乘它，不夹取。
/// r186: `CopyShader` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/shaders/CopyShader.js#L12
pub(all) struct CopyPass {
  mut opacity : Double
}

///|
pub fn CopyPass::new(opacity~ : Double = 1.0) -> CopyPass {
  { opacity, }
}

///|
pub fn CopyPass::set_opacity(self : CopyPass, opacity : Double) -> Unit {
  self.opacity = opacity
}

///|
/// 与 `CopyShader` 相同，四个通道都乘 `opacity`。
/// r186: `CopyShader` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/shaders/CopyShader.js#L45
pub fn copy_color(
  r : Double,
  g : Double,
  b : Double,
  a : Double,
  opacity : Double,
) -> (Double, Double, Double, Double) {
  (r * opacity, g * opacity, b * opacity, a * opacity)
}

///|
/// 16 字节 uniform，`opacity` 在第一个 `f32`。
pub fn pack_opacity(opacity : Double) -> FixedArray[Byte] {
  let dst = FixedArray::make(16, b'\x00')
  write_f32(dst, 0, opacity)
  dst
}

///|
/// 全屏三角形，片段着色器是 `opacity * texel`。
/// r186: `CopyShader` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/shaders/CopyShader.js#L45
pub fn copy_wgsl() -> String {
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
    #|struct CopyParams {
    #|  opacity : f32,
    #|  pad0 : f32,
    #|  pad1 : f32,
    #|  pad2 : f32,
    #|}
    #|
    #|@group(0) @binding(0) var color_tex : texture_2d<f32>;
    #|@group(0) @binding(1) var color_samp : sampler;
    #|@group(0) @binding(2) var<uniform> params : CopyParams;
    #|
    #|@fragment
    #|fn fs(input : VertexOutput) -> @location(0) vec4<f32> {
    #|  let texel = textureSample(color_tex, color_samp, input.uv);
    #|  return params.opacity * texel;
    #|}
  code
}
