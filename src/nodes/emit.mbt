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
    Attribute(name, _, _) => "input.\{name}"
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
  lines.push("\n")
  if program.preamble != "" {
    lines.push(program.preamble)
  }
  lines.push("struct VertexInput {\n")
  for attribute in program.attributes {
    let (name, location, ty) = attribute
    lines.push("  @location(\{location}) \{name} : \{wgsl_type(ty)},\n")
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
  lines.push("  return \{emit_expr(program.fragment_color)};\n}\n")
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
pub fn lambert_wgsl() -> String {
  emit_wgsl(lambert_program())
}

///|
pub fn standard_wgsl() -> String {
  emit_wgsl(standard_program())
}
