///|
/// 节点值的 WGSL 类型。uniform 里的 `vec3` 也按 `vec4` 存放，对齐到 16 字节。
pub(all) enum ValueType {
  F32
  Vec2
  Vec3
  Vec4
  Mat4
}

///|
/// 材质图里的一个节点。覆盖基础材质、Lambert，以及 Standard 的直接光。
pub(all) enum Node {
  Uniform(String, ValueType)
  Attribute(String, Int, ValueType)
  Varying(String, ValueType)
  Float(Double)
  Add(Node, Node)
  Mul(Node, Node)
  Dot(Node, Node)
  Max(Node, Node)
  Normalize(Node)
  Vec4(Node, Node)
  Swizzle(Node, String)
  TextureSample(Node)
  StandardLit(Node)
  InstanceNormal(Node)
}

///|
pub(all) struct Program {
  uniforms : Array[(String, ValueType)]
  attributes : Array[(String, Int, ValueType)]
  varyings : Array[(String, ValueType)]
  vertex_clip : Node
  vertex_varyings : Array[(String, Node)]
  fragment_color : Node
  sampled : Bool
  preamble : String
}

///|
fn frame_uniforms() -> Array[(String, ValueType)] {
  [
    ("mvp", Mat4),
    ("normal_matrix", Mat4),
    ("color", Vec4),
    ("ambient", Vec4),
    ("light_color", Vec4),
    ("light_direction", Vec4),
    ("model", Mat4),
    ("camera_position", Vec4),
    ("surface", Vec4),
    ("viewport", Vec4),
    ("point", Vec4),
    ("view", Mat4),
  ]
}

///|
/// 直接光的 Cook-Torrance。粗糙度下限 0.0525，电介质 F0 为 0.04，与 r186 的物理光照一致。
/// 环境光只乘漫反射。没有环境贴图，所以金属在背光处是黑的。
fn standard_preamble() -> String {
  let lines = [
    "fn D_GGX(alpha : f32, NoH : f32) -> f32 {\n", "  let a2 = alpha * alpha;\n",
    "  let d = (NoH * a2 - NoH) * NoH + 1.0;\n", "  return 0.3183098861837907 * a2 / (d * d);\n",
    "}\n\n", "fn V_GGX_SmithCorrelated(alpha : f32, NoL : f32, NoV : f32) -> f32 {\n",
    "  let a2 = alpha * alpha;\n", "  let gv = NoL * sqrt(a2 + (1.0 - a2) * (NoV * NoV));\n",
    "  let gl = NoV * sqrt(a2 + (1.0 - a2) * (NoL * NoL));\n", "  return 0.5 / max(gv + gl, 0.000001);\n",
    "}\n\n", "fn F_Schlick(f0 : vec3<f32>, VoH : f32) -> vec3<f32> {\n", "  let fresnel = exp2((-5.55473 * VoH - 6.98316) * VoH);\n",
    "  return f0 * (1.0 - fresnel) + fresnel;\n", "}\n\n", "fn standard_lit(base : vec4<f32>, normal : vec3<f32>, world : vec3<f32>) -> vec4<f32> {\n",
    "  let roughness = max((uniforms.surface).x, 0.0525);\n", "  let metalness = clamp((uniforms.surface).y, 0.0, 1.0);\n",
    "  let alpha = roughness * roughness;\n", "  let diffuse_color = base.xyz * (1.0 - metalness);\n",
    "  let f0 = mix(vec3<f32>(0.04), base.xyz, metalness);\n", "  let N = normalize(normal);\n",
    "  let V = normalize((uniforms.camera_position).xyz - world);\n", "  let L = normalize((uniforms.light_direction).xyz);\n",
    "  let H = normalize(V + L);\n", "  let NoL = max(dot(N, L), 0.0);\n", "  let NoV = max(dot(N, V), 0.0);\n",
    "  let NoH = max(dot(N, H), 0.0);\n", "  let VoH = max(dot(V, H), 0.0);\n", "  let specular = F_Schlick(f0, VoH) * (D_GGX(alpha, NoH) * V_GGX_SmithCorrelated(alpha, NoL, NoV));\n",
    "  let diffuse = diffuse_color * 0.3183098861837907;\n", "  let direct = (diffuse + specular) * (uniforms.light_color).xyz * NoL;\n",
    "  let indirect = (uniforms.ambient).xyz * diffuse;\n", "  return vec4<f32>(direct + indirect, base.w);\n",
    "}\n\n",
  ]
  let mut text = ""
  for line in lines {
    text = text + line
  }
  text
}

///|
fn position_attributes() -> Array[(String, Int, ValueType)] {
  [("position", 0, Vec3), ("normal", 1, Vec3), ("uv", 2, Vec2)]
}

///|
fn mesh_attributes(instanced : Bool) -> Array[(String, Int, ValueType)] {
  let attributes = position_attributes()
  if instanced {
    attributes.push(("instance_matrix", 3, Mat4))
    attributes.push(("instance_color", 7, Vec3))
  }
  attributes
}

///|
/// 实例矩阵在物体矩阵之前。非实例路径保持 `vec4(position, 1)`。
fn mesh_local(position : Node, instanced : Bool) -> Node {
  let point = Node::Vec4(position, Float(1.0))
  if instanced {
    Mul(Attribute("instance_matrix", 3, Mat4), point)
  } else {
    point
  }
}

///|
fn mesh_normal(instanced : Bool) -> Node {
  let normal = Attribute("normal", 1, Vec3)
  if instanced {
    InstanceNormal(normal)
  } else {
    normal
  }
}

///|
fn instance_preamble() -> String {
  "fn instance_normal(n : vec3<f32>, i0 : vec4<f32>, i1 : vec4<f32>, i2 : vec4<f32>) -> vec3<f32> {\n  let m = mat3x3<f32>(i0.xyz, i1.xyz, i2.xyz);\n  let s = vec3<f32>(dot(m[0], m[0]), dot(m[1], m[1]), dot(m[2], m[2]));\n  return m * (n / max(s, vec3<f32>(0.000001)));\n}\n\n"
}

///|
fn tint_instance(color : Node, instanced : Bool) -> Node {
  if instanced {
    Node::Vec4(
      Mul(Swizzle(color, "xyz"), Varying("v_instance_color", Vec3)),
      Swizzle(color, "w"),
    )
  } else {
    color
  }
}

///|
fn with_instance_color(
  varyings : Array[(String, ValueType)],
  assignments : Array[(String, Node)],
  instanced : Bool,
) -> (Array[(String, ValueType)], Array[(String, Node)]) {
  if instanced {
    varyings.push(("v_instance_color", Vec3))
    assignments.push(("v_instance_color", Attribute("instance_color", 7, Vec3)))
  }
  (varyings, assignments)
}

///|
/// 不受光照。法线乘 0 只是为了让顶点布局和 Lambert 一致。贴图采样乘在颜色上，没有贴图时渲染器绑一张白纹理。
/// `instanced` 为真时再乘实例矩阵和实例颜色。
pub fn basic_program(instanced? : Bool = false) -> Program {
  let position = Attribute("position", 0, Vec3)
  let normal = Attribute("normal", 1, Vec3)
  let shifted = Add(position, Mul(normal, Float(0.0)))
  let sample = TextureSample(Varying("v_uv", Vec2))
  let (varyings, assignments) = with_instance_color(
    [("v_uv", Vec2)],
    [("v_uv", Attribute("uv", 2, Vec2))],
    instanced,
  )
  {
    uniforms: frame_uniforms(),
    attributes: mesh_attributes(instanced),
    varyings,
    vertex_clip: Mul(Uniform("mvp", Mat4), mesh_local(shifted, instanced)),
    vertex_varyings: assignments,
    fragment_color: tint_instance(
      Mul(Uniform("color", Vec4), sample),
      instanced,
    ),
    sampled: true,
    preamble: "",
  }
}

///|
/// Lambert：`color * (ambient + lightColor * max(dot(N, L), 0))`。
pub fn lambert_program(instanced? : Bool = false) -> Program {
  let position = Attribute("position", 0, Vec3)
  let normal = mesh_normal(instanced)
  let world_normal = Swizzle(
    Mul(Uniform("normal_matrix", Mat4), Vec4(normal, Float(0.0))),
    "xyz",
  )
  let n = Normalize(Varying("v_normal", Vec3))
  let ndotl = Max(
    Dot(n, Swizzle(Uniform("light_direction", Vec4), "xyz")),
    Float(0.0),
  )
  let lit = Add(
    Swizzle(Uniform("ambient", Vec4), "xyz"),
    Mul(Swizzle(Uniform("light_color", Vec4), "xyz"), ndotl),
  )
  let sample = TextureSample(Varying("v_uv", Vec2))
  let rgb = Mul(
    Mul(Swizzle(Uniform("color", Vec4), "xyz"), lit),
    Swizzle(sample, "xyz"),
  )
  let (varyings, assignments) = with_instance_color(
    [("v_normal", Vec3), ("v_uv", Vec2)],
    [("v_normal", world_normal), ("v_uv", Attribute("uv", 2, Vec2))],
    instanced,
  )
  {
    uniforms: frame_uniforms(),
    attributes: mesh_attributes(instanced),
    varyings,
    vertex_clip: Mul(Uniform("mvp", Mat4), mesh_local(position, instanced)),
    vertex_varyings: assignments,
    fragment_color: tint_instance(
      Vec4(rgb, Mul(Swizzle(Uniform("color", Vec4), "w"), Swizzle(sample, "w"))),
      instanced,
    ),
    sampled: true,
    preamble: if instanced {
      instance_preamble()
    } else {
      ""
    },
  }
}

///|
/// Standard：`baseColor * (1 - metalness)` 的 Lambert 漫反射，加上 GGX 高光。`baseColor` 已乘贴图。
pub fn standard_program(instanced? : Bool = false) -> Program {
  let position = Attribute("position", 0, Vec3)
  let placed = mesh_local(position, instanced)
  let normal = mesh_normal(instanced)
  let world_normal = Swizzle(
    Mul(Uniform("normal_matrix", Mat4), Vec4(normal, Float(0.0))),
    "xyz",
  )
  let world = Swizzle(Mul(Uniform("model", Mat4), placed), "xyz")
  let sample = TextureSample(Varying("v_uv", Vec2))
  let base = Node::Vec4(
    Mul(Swizzle(Uniform("color", Vec4), "xyz"), Swizzle(sample, "xyz")),
    Mul(Swizzle(Uniform("color", Vec4), "w"), Swizzle(sample, "w")),
  )
  let (varyings, assignments) = with_instance_color(
    [("v_normal", Vec3), ("v_uv", Vec2), ("v_world", Vec3)],
    [
      ("v_normal", world_normal),
      ("v_uv", Attribute("uv", 2, Vec2)),
      ("v_world", world),
    ],
    instanced,
  )
  {
    uniforms: frame_uniforms(),
    attributes: mesh_attributes(instanced),
    varyings,
    vertex_clip: Mul(Uniform("mvp", Mat4), placed),
    vertex_varyings: assignments,
    fragment_color: StandardLit(tint_instance(base, instanced)),
    sampled: true,
    preamble: if instanced {
      instance_preamble() + standard_preamble()
    } else {
      standard_preamble()
    },
  }
}

///|
/// 折线和线段。只有位置和颜色，线宽由光栅器固定为 1 像素。
pub fn line_program() -> Program {
  let position = Attribute("position", 0, Vec3)
  {
    uniforms: frame_uniforms(),
    attributes: [("position", 0, Vec3)],
    varyings: [],
    vertex_clip: Mul(Uniform("mvp", Mat4), Vec4(position, Float(1.0))),
    vertex_varyings: [],
    fragment_color: Uniform("color", Vec4),
    sampled: false,
    preamble: "",
  }
}
