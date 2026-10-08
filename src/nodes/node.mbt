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
/// 材质图里的一个节点。只覆盖基础材质和 Lambert 会走到的运算。
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
  ]
}

///|
fn position_attributes() -> Array[(String, Int, ValueType)] {
  [("position", 0, Vec3), ("normal", 1, Vec3), ("uv", 2, Vec2)]
}

///|
/// 不受光照。法线乘 0 只是为了让顶点布局和 Lambert 一致。贴图采样乘在颜色上，没有贴图时渲染器绑一张白纹理。
pub fn basic_program() -> Program {
  let position = Attribute("position", 0, Vec3)
  let normal = Attribute("normal", 1, Vec3)
  let shifted = Add(position, Mul(normal, Float(0.0)))
  let sample = TextureSample(Varying("v_uv", Vec2))
  {
    uniforms: frame_uniforms(),
    attributes: position_attributes(),
    varyings: [("v_uv", Vec2)],
    vertex_clip: Mul(Uniform("mvp", Mat4), Vec4(shifted, Float(1.0))),
    vertex_varyings: [("v_uv", Attribute("uv", 2, Vec2))],
    fragment_color: Mul(Uniform("color", Vec4), sample),
    sampled: true,
  }
}

///|
/// Lambert：`color * (ambient + lightColor * max(dot(N, L), 0))`。
pub fn lambert_program() -> Program {
  let position = Attribute("position", 0, Vec3)
  let normal = Attribute("normal", 1, Vec3)
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
  {
    uniforms: frame_uniforms(),
    attributes: position_attributes(),
    varyings: [("v_normal", Vec3), ("v_uv", Vec2)],
    vertex_clip: Mul(Uniform("mvp", Mat4), Vec4(position, Float(1.0))),
    vertex_varyings: [
      ("v_normal", world_normal),
      ("v_uv", Attribute("uv", 2, Vec2)),
    ],
    fragment_color: Vec4(
      rgb,
      Mul(Swizzle(Uniform("color", Vec4), "w"), Swizzle(sample, "w")),
    ),
    sampled: true,
  }
}
