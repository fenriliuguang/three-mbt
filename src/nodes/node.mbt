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
  DirectShadow
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
  shadowed : Bool
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
    ("shadow_matrix", Mat4),
    ("shadow", Vec4),
    ("fog", Vec4),
    ("fog_params", Vec4),
  ]
}

///|
/// 雾因子乘在片元颜色上。`fog.w` 小于 0.5 时这个材质不吃雾。
/// 线性雾是 smoothstep，`fog_params.w` 大于 0.5 时改成指数平方。
fn fog_preamble() -> String {
  "fn apply_fog(color : vec4<f32>, depth : f32) -> vec4<f32> {\n  if ((uniforms.fog).w < 0.5) {\n    return color;\n  }\n  var factor = 0.0;\n  let near = (uniforms.fog_params).x;\n  let far = (uniforms.fog_params).y;\n  let density = (uniforms.fog_params).z;\n  if ((uniforms.fog_params).w < 0.5) {\n    let span = max(far - near, 0.000001);\n    let t = clamp((depth - near) / span, 0.0, 1.0);\n    factor = t * t * (3.0 - 2.0 * t);\n  } else {\n    let amount = density * depth;\n    factor = 1.0 - exp(-amount * amount);\n  }\n  return vec4<f32>(mix(color.xyz, (uniforms.fog).xyz, factor), color.w);\n}\n\n"
}

///|
/// 视图空间深度，和 r186 的 `-mvPosition.z` 一样。相机前方为正。
fn fog_depth(point : Node) -> Node {
  let view_z = Swizzle(
    Mul(Uniform("view", Mat4), Mul(Uniform("model", Mat4), point)),
    "z",
  )
  Mul(view_z, Float(-1.0))
}

///|
fn with_fog(
  varyings : Array[(String, ValueType)],
  assignments : Array[(String, Node)],
  depth : Node,
) -> (Array[(String, ValueType)], Array[(String, Node)]) {
  varyings.push(("v_fog_depth", F32))
  assignments.push(("v_fog_depth", depth))
  (varyings, assignments)
}

///|
fn shadow_preamble() -> String {
  "fn direct_shadow(world : vec3<f32>, normal : vec3<f32>) -> f32 {\n  if ((uniforms.shadow).z < 0.5) {\n    return 1.0;\n  }\n  let shifted = world + normalize(normal) * (uniforms.shadow).y;\n  let clip = uniforms.shadow_matrix * vec4<f32>(shifted, 1.0);\n  let uv = clip.xy / clip.w;\n  let depth = clip.z / clip.w + (uniforms.shadow).x;\n  if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0 || depth < 0.0 || depth > 1.0) {\n    return 1.0;\n  }\n  let texel = (uniforms.shadow).w;\n  var sum = 0.0;\n  for (var y = -1; y <= 1; y = y + 1) {\n    for (var x = -1; x <= 1; x = x + 1) {\n      let offset = vec2<f32>(f32(x), f32(y)) * texel;\n      sum = sum + textureSampleCompare(shadow_map, shadow_sampler, uv + offset, depth);\n    }\n  }\n  return sum / 9.0;\n}\n\n"
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
    "  let diffuse = diffuse_color * 0.3183098861837907;\n", "  let direct = (diffuse + specular) * (uniforms.light_color).xyz * NoL * direct_shadow(world, N);\n",
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
  let (colored_varyings, colored_assignments) = with_instance_color(
    [("v_uv", Vec2)],
    [("v_uv", Attribute("uv", 2, Vec2))],
    instanced,
  )
  let (varyings, assignments) = with_fog(
    colored_varyings,
    colored_assignments,
    fog_depth(mesh_local(position, instanced)),
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
    shadowed: false,
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
  let world = Swizzle(
    Mul(Uniform("model", Mat4), mesh_local(position, instanced)),
    "xyz",
  )
  let direct = Mul(
    Mul(Swizzle(Uniform("light_color", Vec4), "xyz"), ndotl),
    DirectShadow,
  )
  let lit = Add(Swizzle(Uniform("ambient", Vec4), "xyz"), direct)
  let sample = TextureSample(Varying("v_uv", Vec2))
  let rgb = Mul(
    Mul(Swizzle(Uniform("color", Vec4), "xyz"), lit),
    Swizzle(sample, "xyz"),
  )
  let (colored_varyings, colored_assignments) = with_instance_color(
    [("v_normal", Vec3), ("v_uv", Vec2), ("v_world", Vec3)],
    [
      ("v_normal", world_normal),
      ("v_uv", Attribute("uv", 2, Vec2)),
      ("v_world", world),
    ],
    instanced,
  )
  let (varyings, assignments) = with_fog(
    colored_varyings,
    colored_assignments,
    fog_depth(mesh_local(position, instanced)),
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
    shadowed: true,
    preamble: if instanced {
      instance_preamble() + shadow_preamble()
    } else {
      shadow_preamble()
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
  let (colored_varyings, colored_assignments) = with_instance_color(
    [("v_normal", Vec3), ("v_uv", Vec2), ("v_world", Vec3)],
    [
      ("v_normal", world_normal),
      ("v_uv", Attribute("uv", 2, Vec2)),
      ("v_world", world),
    ],
    instanced,
  )
  let (varyings, assignments) = with_fog(
    colored_varyings,
    colored_assignments,
    fog_depth(placed),
  )
  {
    uniforms: frame_uniforms(),
    attributes: mesh_attributes(instanced),
    varyings,
    vertex_clip: Mul(Uniform("mvp", Mat4), placed),
    vertex_varyings: assignments,
    fragment_color: StandardLit(tint_instance(base, instanced)),
    sampled: true,
    shadowed: true,
    preamble: if instanced {
      instance_preamble() + shadow_preamble() + standard_preamble()
    } else {
      shadow_preamble() + standard_preamble()
    },
  }
}

///|
/// 折线和线段。只有位置和颜色，线宽由光栅器固定为 1 像素。
pub fn line_program() -> Program {
  let position = Attribute("position", 0, Vec3)
  let placed = Node::Vec4(position, Float(1.0))
  {
    uniforms: frame_uniforms(),
    attributes: [("position", 0, Vec3)],
    varyings: [("v_fog_depth", F32)],
    vertex_clip: Mul(Uniform("mvp", Mat4), placed),
    vertex_varyings: [("v_fog_depth", fog_depth(placed))],
    fragment_color: Uniform("color", Vec4),
    sampled: false,
    shadowed: false,
    preamble: "",
  }
}
