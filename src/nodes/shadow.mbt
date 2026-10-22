// r186: `VSMPassVertical` https://github.com/mrdoob/three.js/blob/r186/src/nodes/lighting/ShadowNode.js#L37 ; `VSMPassHorizontal` https://github.com/mrdoob/three.js/blob/r186/src/nodes/lighting/ShadowNode.js#L84

///|
fn vsm_vertex() -> String {
  "struct VertexOutput {\n  @builtin(position) clip : vec4<f32>,\n}\n\n@vertex\nfn vs(@builtin(vertex_index) id : u32) -> VertexOutput {\n  let x = select(-1.0, 3.0, id == 1u);\n  let y = select(-1.0, 3.0, id == 2u);\n  var output : VertexOutput;\n  output.clip = vec4<f32>(x, y, 0.0, 1.0);\n  return output;\n}\n\nstruct VsmParams {\n  samples : f32,\n  radius : f32,\n  width : f32,\n  height : f32,\n}\n\n"
}

///|
/// 深度贴图沿竖直方向收成均值和标准差。样本数夹到 1 和 64。
/// r186: `VSMPassVertical` https://github.com/mrdoob/three.js/blob/r186/src/nodes/lighting/ShadowNode.js#L37
pub fn vsm_vertical_wgsl() -> String {
  vsm_vertex() +
  "@group(0) @binding(0) var depth_tex : texture_depth_2d;\n@group(0) @binding(1) var depth_samp : sampler;\n@group(0) @binding(2) var<uniform> params : VsmParams;\n\n@fragment\nfn fs(@builtin(position) pixel : vec4<f32>) -> @location(0) vec4<f32> {\n  let count = i32(clamp(params.samples, 1.0, 64.0));\n  var mean = 0.0;\n  var squared = 0.0;\n  for (var i = 0; i < 64; i = i + 1) {\n    if (i < count) {\n      let offset = select(0.0, -1.0 + f32(i) * (2.0 / (f32(count) - 1.0)), count > 1);\n      let sample_px = pixel.xy + vec2<f32>(0.0, offset * params.radius);\n      let uv = sample_px / vec2<f32>(params.width, params.height);\n      let depth = textureSample(depth_tex, depth_samp, uv);\n      mean = mean + depth;\n      squared = squared + depth * depth;\n    }\n  }\n  mean = mean / f32(count);\n  squared = squared / f32(count);\n  let variance = max(squared - mean * mean, 0.0);\n  return vec4<f32>(mean, sqrt(variance), 0.0, 1.0);\n}\n"
}

///|
/// 把竖直结果再沿水平方向收成均值和标准差。第二矩是标准差平方加均值平方。
/// r186: `VSMPassHorizontal` https://github.com/mrdoob/three.js/blob/r186/src/nodes/lighting/ShadowNode.js#L84
pub fn vsm_horizontal_wgsl() -> String {
  vsm_vertex() +
  "@group(0) @binding(0) var moment_tex : texture_2d<f32>;\n@group(0) @binding(1) var moment_samp : sampler;\n@group(0) @binding(2) var<uniform> params : VsmParams;\n\n@fragment\nfn fs(@builtin(position) pixel : vec4<f32>) -> @location(0) vec4<f32> {\n  let count = i32(clamp(params.samples, 1.0, 64.0));\n  var mean = 0.0;\n  var squared = 0.0;\n  for (var i = 0; i < 64; i = i + 1) {\n    if (i < count) {\n      let offset = select(0.0, -1.0 + f32(i) * (2.0 / (f32(count) - 1.0)), count > 1);\n      let sample_px = pixel.xy + vec2<f32>(offset * params.radius, 0.0);\n      let uv = sample_px / vec2<f32>(params.width, params.height);\n      let distribution = textureSample(moment_tex, moment_samp, uv);\n      mean = mean + distribution.x;\n      squared = squared + distribution.y * distribution.y + distribution.x * distribution.x;\n    }\n  }\n  mean = mean / f32(count);\n  squared = squared / f32(count);\n  let variance = max(squared - mean * mean, 0.0);\n  return vec4<f32>(mean, sqrt(variance), 0.0, 1.0);\n}\n"
}
