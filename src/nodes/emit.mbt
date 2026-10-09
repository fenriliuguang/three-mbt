///|
fn wgsl_type(ty : ValueType) -> String {
  match ty {
    F32 => "f32"
    Vec2 => "vec2<f32>"
    Vec3 => "vec3<f32>"
    Vec4 => "vec4<f32>"
    Mat4 => "mat4x4<f32>"
  }
}

///|
fn emit_f32(value : Double) -> String {
  let text = value.to_string()
  if text.contains(".") || text.contains("e") || text.contains("E") {
    text
  } else {
    "\{text}.0"
  }
}

///|
fn emit_expr(node : Node) -> String {
  match node {
    Uniform(name, _) => "uniforms.\{name}"
    Attribute(name, _, ty) =>
      match ty {
        Mat4 =>
          "mat4x4<f32>(input.\{name}_0, input.\{name}_1, input.\{name}_2, input.\{name}_3)"
        _ => "input.\{name}"
      }
    Varying(name, _) => "input.\{name}"
    Float(value) => emit_f32(value)
    Add(left, right) => "(\{emit_expr(left)} + \{emit_expr(right)})"
    Mul(left, right) => "(\{emit_expr(left)} * \{emit_expr(right)})"
    Dot(left, right) => "dot(\{emit_expr(left)}, \{emit_expr(right)})"
    Max(left, right) => "max(\{emit_expr(left)}, \{emit_expr(right)})"
    Normalize(value) => "normalize(\{emit_expr(value)})"
    Vec4(xyz, w) => "vec4<f32>(\{emit_expr(xyz)}, \{emit_expr(w)})"
    Swizzle(value, suffix) => "(\{emit_expr(value)}).\{suffix}"
    TextureSample(uv) =>
      "textureSample(map_texture, map_sampler, \{emit_expr(uv)})"
    StandardLit(base) =>
      "standard_lit(\{emit_expr(base)}, input.v_normal, input.v_world)"
    InstanceNormal(normal) =>
      "instance_normal(\{emit_expr(normal)}, input.instance_matrix_0, input.instance_matrix_1, input.instance_matrix_2)"
    DirectShadow => "direct_shadow(input.v_world, input.v_normal)"
  }
}

///|
fn emit_fields(
  lines : Array[String],
  fields : Array[(String, ValueType)],
) -> Unit {
  for field in fields {
    let (name, ty) = field
    lines.push("  \{name} : \{wgsl_type(ty)},\n")
  }
}

///|
/// 把材质节点编成一段 WGSL。三种材质共用同一块 uniform。
pub fn emit_wgsl(program : Program) -> String {
  let lines = []
  lines.push("struct Uniforms {\n")
  emit_fields(lines, program.uniforms)
  lines.push("}\n\n@group(0) @binding(0) var<uniform> uniforms : Uniforms;\n")
  if program.sampled {
    lines.push("@group(1) @binding(0) var map_texture : texture_2d<f32>;\n")
    lines.push("@group(1) @binding(1) var map_sampler : sampler;\n")
  }
  if program.shadowed {
    lines.push("@group(2) @binding(0) var shadow_map : texture_depth_2d;\n")
    lines.push(
      "@group(2) @binding(1) var shadow_sampler : sampler_comparison;\n",
    )
  }
  lines.push("\n")
  if program.preamble != "" {
    lines.push(program.preamble)
  }
  lines.push(fog_preamble())
  lines.push("struct VertexInput {\n")
  for attribute in program.attributes {
    let (name, location, ty) = attribute
    match ty {
      Mat4 => {
        lines.push("  @location(\{location}) \{name}_0 : vec4<f32>,\n")
        lines.push("  @location(\{location + 1}) \{name}_1 : vec4<f32>,\n")
        lines.push("  @location(\{location + 2}) \{name}_2 : vec4<f32>,\n")
        lines.push("  @location(\{location + 3}) \{name}_3 : vec4<f32>,\n")
      }
      _ => lines.push("  @location(\{location}) \{name} : \{wgsl_type(ty)},\n")
    }
  }
  lines.push(
    "}\n\nstruct VertexOutput {\n  @builtin(position) clip : vec4<f32>,\n",
  )
  let mut location = 0
  for varying in program.varyings {
    let (name, ty) = varying
    lines.push("  @location(\{location}) \{name} : \{wgsl_type(ty)},\n")
    location = location + 1
  }
  lines.push("}\n\n@vertex\nfn vs(input : VertexInput) -> VertexOutput {\n")
  lines.push("  var output : VertexOutput;\n")
  lines.push("  output.clip = \{emit_expr(program.vertex_clip)};\n")
  for varying in program.vertex_varyings {
    let (name, expr) = varying
    lines.push("  output.\{name} = \{emit_expr(expr)};\n")
  }
  lines.push(
    "  return output;\n}\n\n@fragment\nfn fs(input : VertexOutput) -> @location(0) vec4<f32> {\n",
  )
  lines.push(
    "  return apply_fog(\{emit_expr(program.fragment_color)}, input.v_fog_depth);\n}\n",
  )
  let mut wgsl = ""
  for line in lines {
    wgsl = wgsl + line
  }
  wgsl
}

///|
pub fn basic_wgsl() -> String {
  emit_wgsl(basic_program())
}

///|
pub fn basic_instanced_wgsl() -> String {
  emit_wgsl(basic_program(instanced=true))
}

///|
pub fn lambert_wgsl() -> String {
  emit_wgsl(lambert_program())
}

///|
pub fn lambert_instanced_wgsl() -> String {
  emit_wgsl(lambert_program(instanced=true))
}

///|
pub fn standard_wgsl() -> String {
  emit_wgsl(standard_program())
}

///|
pub fn standard_instanced_wgsl() -> String {
  emit_wgsl(standard_program(instanced=true))
}

///|
pub fn line_wgsl() -> String {
  emit_wgsl(line_program())
}

///|
/// 阴影贴图只写深度。uniform 只声明开头的 `mvp`，和完整 uniform 块的前 64 字节对齐。
pub fn shadow_wgsl() -> String {
  "struct Uniforms {\n  mvp : mat4x4<f32>,\n}\n\n@group(0) @binding(0) var<uniform> uniforms : Uniforms;\n\nstruct VertexInput {\n  @location(0) position : vec3<f32>,\n}\n\nstruct VertexOutput {\n  @builtin(position) clip : vec4<f32>,\n}\n\n@vertex\nfn vs(input : VertexInput) -> VertexOutput {\n  var output : VertexOutput;\n  output.clip = uniforms.mvp * vec4<f32>(input.position, 1.0);\n  return output;\n}\n"
}

///|
pub fn shadow_instanced_wgsl() -> String {
  "struct Uniforms {\n  mvp : mat4x4<f32>,\n}\n\n@group(0) @binding(0) var<uniform> uniforms : Uniforms;\n\nstruct VertexInput {\n  @location(0) position : vec3<f32>,\n  @location(3) instance_matrix_0 : vec4<f32>,\n  @location(4) instance_matrix_1 : vec4<f32>,\n  @location(5) instance_matrix_2 : vec4<f32>,\n  @location(6) instance_matrix_3 : vec4<f32>,\n}\n\nstruct VertexOutput {\n  @builtin(position) clip : vec4<f32>,\n}\n\n@vertex\nfn vs(input : VertexInput) -> VertexOutput {\n  var output : VertexOutput;\n  let instance = mat4x4<f32>(input.instance_matrix_0, input.instance_matrix_1, input.instance_matrix_2, input.instance_matrix_3);\n  output.clip = uniforms.mvp * instance * vec4<f32>(input.position, 1.0);\n  return output;\n}\n"
}

///|
fn uniform_header() -> String {
  let lines = []
  lines.push("struct Uniforms {\n")
  emit_fields(lines, frame_uniforms())
  lines.push("}\n\n@group(0) @binding(0) var<uniform> uniforms : Uniforms;\n\n")
  let mut text = ""
  for line in lines {
    text = text + line
  }
  text
}

///|
/// WebGPU 的点是 1 像素，所以这里把每个点展开成朝向相机的四边形。
/// `size` 是像素。衰减打开时乘 `viewportHeight * 0.5 / -viewZ`，和 r186 的 `PointsMaterial` 一样。
pub fn points_wgsl() -> String {
  uniform_header() +
  fog_preamble() +
  "struct VertexInput {\n  @location(0) corner : vec2<f32>,\n  @location(1) position : vec3<f32>,\n}\n\nstruct VertexOutput {\n  @builtin(position) clip : vec4<f32>,\n  @location(0) v_fog_depth : f32,\n}\n\n@vertex\nfn vs(input : VertexInput) -> VertexOutput {\n  var output : VertexOutput;\n  let world = uniforms.model * vec4<f32>(input.position, 1.0);\n  let view = uniforms.view * world;\n  let clip = uniforms.mvp * vec4<f32>(input.position, 1.0);\n  let attenuate = (uniforms.point).y > 0.5;\n  let depth = max(-view.z, 0.000001);\n  let pixels = select((uniforms.point).x, (uniforms.point).x * (uniforms.viewport).y * 0.5 / depth, attenuate);\n  let ndc = vec2<f32>(pixels / (uniforms.viewport).x, pixels / (uniforms.viewport).y);\n  let offset = input.corner * ndc * clip.w;\n  output.clip = vec4<f32>(clip.x + offset.x, clip.y + offset.y, clip.z, clip.w);\n  output.v_fog_depth = -view.z;\n  return output;\n}\n\n@fragment\nfn fs(input : VertexOutput) -> @location(0) vec4<f32> {\n  let color = uniforms.color + vec4<f32>(input.clip.x * 0.0, 0.0, 0.0, 0.0);\n  return apply_fog(color, input.v_fog_depth);\n}\n"
}
