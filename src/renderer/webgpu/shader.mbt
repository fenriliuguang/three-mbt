///|
/// 不受光照的 `MeshBasicMaterial`。颜色来自 uniform，顶点只读位置。
fn unlit_wgsl() -> String {
  "struct Uniforms {\n  mvp : mat4x4<f32>,\n  color : vec4<f32>,\n}\n\n@group(0) @binding(0) var<uniform> uniforms : Uniforms;\n\nstruct VertexInput {\n  @location(0) position : vec3<f32>,\n}\n\nstruct VertexOutput {\n  @builtin(position) clip : vec4<f32>,\n}\n\n@vertex\nfn vs(input : VertexInput) -> VertexOutput {\n  var output : VertexOutput;\n  output.clip = uniforms.mvp * vec4<f32>(input.position, 1.0);\n  return output;\n}\n\n@fragment\nfn fs() -> @location(0) vec4<f32> {\n  return uniforms.color;\n}\n"
}
