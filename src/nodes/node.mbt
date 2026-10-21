// r186: `Node` https://github.com/mrdoob/three.js/blob/r186/src/nodes/core/Node.js#L22 ; `WGSLNodeBuilder` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgpu/nodes/WGSLNodeBuilder.js#L297

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
/// r186: `Node` https://github.com/mrdoob/three.js/blob/r186/src/nodes/core/Node.js#L22
pub(all) enum Node {
  Uniform(String, ValueType)
  Attribute(String, Int32, ValueType)
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
  PointTerm
  SpotTerm
  HemisphereTerm
  FacingNormal
  EmissiveSample
  AlphaSample
}

///|
/// r186: `WGSLNodeBuilder` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgpu/nodes/WGSLNodeBuilder.js#L297
pub(all) struct Program {
  uniforms : Array[(String, ValueType)]
  attributes : Array[(String, Int32, ValueType)]
  varyings : Array[(String, ValueType)]
  vertex_clip : Node
  vertex_varyings : Array[(String, Node)]
  fragment_color : Node
  sampled : Bool
  shadowed : Bool
  emissive : Bool
  roughness : Bool
  metalness : Bool
  alpha : Bool
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
    ("emissive", Vec4),
    ("point_position", Vec4),
    ("point_color", Vec4),
    ("point_params", Vec4),
    ("spot_position", Vec4),
    ("spot_direction", Vec4),
    ("spot_color", Vec4),
    ("spot_params", Vec4),
    ("hemisphere_sky", Vec4),
    ("hemisphere_ground", Vec4),
    ("hemisphere_direction", Vec4),
  ]
}

///|
/// 雾因子乘在片元颜色上。`fog.w` 小于 0.5 时这个材质不吃雾。
/// 线性雾是 smoothstep，`fog_params.w` 大于 0.5 时改成指数平方。
/// r186: `rangeFogFactor` https://github.com/mrdoob/three.js/blob/r186/src/nodes/fog/Fog.js#L40 ; `densityFogFactor` https://github.com/mrdoob/three.js/blob/r186/src/nodes/fog/Fog.js#L57
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
/// r186: `LightShadow` https://github.com/mrdoob/three.js/blob/r186/src/lights/LightShadow.js#L18
/// 点光衰减来自 Frostbite：`1 / max(distance^decay, 0.01)`，有截断时再乘平滑边缘。
/// 不乘阴影。`point_params.z` 小于 0.5 时没有点光。
/// r186: `getDistanceAttenuation` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/lights_pars_begin.glsl.js#L56
fn point_preamble() -> String {
  "fn point_falloff(world : vec3<f32>) -> f32 {\n  if ((uniforms.point_params).z < 0.5) {\n    return 0.0;\n  }\n  let delta = (uniforms.point_position).xyz - world;\n  let dist = length(delta);\n  let decay = (uniforms.point_params).y;\n  var falloff = 1.0 / max(pow(dist, decay), 0.01);\n  let cutoff = (uniforms.point_params).x;\n  if (cutoff > 0.0) {\n    let ratio = dist / cutoff;\n    let edged = clamp(1.0 - ratio * ratio * ratio * ratio, 0.0, 1.0);\n    falloff = falloff * edged * edged;\n  }\n  return falloff;\n}\n\nfn point_direction(world : vec3<f32>) -> vec3<f32> {\n  let delta = (uniforms.point_position).xyz - world;\n  return delta / max(length(delta), 0.000001);\n}\n\nfn point_term(world : vec3<f32>, normal : vec3<f32>) -> vec3<f32> {\n  let falloff = point_falloff(world);\n  let L = point_direction(world);\n  let ndotl = max(dot(normalize(normal), L), 0.0);\n  return (uniforms.point_color).xyz * ndotl * falloff;\n}\n\n"
}

///|
/// 半球光只进漫反射。权重是 `dot(N, L) * 0.5 + 0.5`，再从地面色混到天空色。
/// r186: `hemiDiffuseWeight` https://github.com/mrdoob/three.js/blob/r186/src/nodes/lighting/HemisphereLightNode.js#L77
/// r186: `mix` https://github.com/mrdoob/three.js/blob/r186/src/nodes/lighting/HemisphereLightNode.js#L79
fn hemisphere_preamble() -> String {
  "fn hemisphere_term(normal : vec3<f32>) -> vec3<f32> {\n  if ((uniforms.hemisphere_direction).w < 0.5) {\n    return vec3<f32>(0.0);\n  }\n  let weight = dot(normalize(normal), (uniforms.hemisphere_direction).xyz) * 0.5 + 0.5;\n  return mix((uniforms.hemisphere_ground).xyz, (uniforms.hemisphere_sky).xyz, weight);\n}\n\n"
}

///|
/// 聚光先走点光的距离衰减，再乘锥角。`spot_direction.w` 小于 0.5 时没有聚光。
/// `angleCos` 是片元指向灯的方向与灯轴的点积。两边余弦相等时用硬边，因为 WGSL 的 `smoothstep` 在边界重合时无定义。
/// r186: `getSpotAttenuation` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/lights_pars_begin.glsl.js#L73
/// r186: `getSpotLightInfo` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/lights_pars_begin.glsl.js#L163
fn spot_preamble() -> String {
  "fn spot_cone(angle_cos : f32, cone : f32, penumbra : f32) -> f32 {\n  if (penumbra <= cone) {\n    if (angle_cos >= cone) {\n      return 1.0;\n    }\n    return 0.0;\n  }\n  let t = clamp((angle_cos - cone) / (penumbra - cone), 0.0, 1.0);\n  return t * t * (3.0 - 2.0 * t);\n}\n\nfn spot_falloff(world : vec3<f32>) -> f32 {\n  if ((uniforms.spot_direction).w < 0.5) {\n    return 0.0;\n  }\n  let delta = (uniforms.spot_position).xyz - world;\n  let dist = length(delta);\n  let decay = (uniforms.spot_params).y;\n  var falloff = 1.0 / max(pow(dist, decay), 0.01);\n  let cutoff = (uniforms.spot_params).x;\n  if (cutoff > 0.0) {\n    let ratio = dist / cutoff;\n    let edged = clamp(1.0 - ratio * ratio * ratio * ratio, 0.0, 1.0);\n    falloff = falloff * edged * edged;\n  }\n  let axis = delta / max(dist, 0.000001);\n  let angle_cos = dot(axis, (uniforms.spot_direction).xyz);\n  return falloff * spot_cone(angle_cos, (uniforms.spot_params).z, (uniforms.spot_params).w);\n}\n\nfn spot_direction(world : vec3<f32>) -> vec3<f32> {\n  let delta = (uniforms.spot_position).xyz - world;\n  return delta / max(length(delta), 0.000001);\n}\n\nfn spot_term(world : vec3<f32>, normal : vec3<f32>) -> vec3<f32> {\n  let falloff = spot_falloff(world);\n  let L = spot_direction(world);\n  let ndotl = max(dot(normalize(normal), L), 0.0);\n  return (uniforms.spot_color).xyz * ndotl * falloff;\n}\n\n"
}

///|
fn shadow_preamble() -> String {
  "fn direct_shadow(world : vec3<f32>, normal : vec3<f32>) -> f32 {\n  if ((uniforms.shadow).z < 0.5) {\n    return 1.0;\n  }\n  let shifted = world + normalize(normal) * (uniforms.shadow).y;\n  let clip = uniforms.shadow_matrix * vec4<f32>(shifted, 1.0);\n  let uv = clip.xy / clip.w;\n  let depth = clip.z / clip.w + (uniforms.shadow).x;\n  if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0 || depth < 0.0 || depth > 1.0) {\n    return 1.0;\n  }\n  let texel = (uniforms.shadow).w;\n  var sum = 0.0;\n  for (var y = -1; y <= 1; y = y + 1) {\n    for (var x = -1; x <= 1; x = x + 1) {\n      let offset = vec2<f32>(f32(x), f32(y)) * texel;\n      sum = sum + textureSampleCompare(shadow_map, shadow_sampler, uv + offset, depth);\n    }\n  }\n  return sum / 9.0;\n}\n\n"
}

///|
/// 直接光的 Cook-Torrance。粗糙度先乘贴图绿色通道，再取下限 0.0525。金属度先乘贴图蓝色通道，再夹到 0 和 1。电介质 F0 为 0.04，与 r186 的物理光照一致。
/// 环境光只乘漫反射。没有环境贴图，所以金属在背光处是黑的。
/// r186: `D_GGX` https://github.com/mrdoob/three.js/blob/r186/src/nodes/functions/BSDF/D_GGX.js#L6 ; `V_GGX_SmithCorrelated` https://github.com/mrdoob/three.js/blob/r186/src/nodes/functions/BSDF/V_GGX_SmithCorrelated.js#L7 ; `F_Schlick` https://github.com/mrdoob/three.js/blob/r186/src/nodes/functions/BSDF/F_Schlick.js#L3 ; `BRDF_GGX` https://github.com/mrdoob/three.js/blob/r186/src/nodes/functions/BSDF/BRDF_GGX.js#L12 ; `roughnessFactor` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/roughnessmap_fragment.glsl.js#L9 ; `metalnessFactor` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/metalnessmap_fragment.glsl.js#L9
fn standard_preamble() -> String {
  let lines = [
    "fn D_GGX(alpha : f32, NoH : f32) -> f32 {\n", "  let a2 = alpha * alpha;\n",
    "  let d = (NoH * a2 - NoH) * NoH + 1.0;\n", "  return 0.3183098861837907 * a2 / (d * d);\n",
    "}\n\n", "fn V_GGX_SmithCorrelated(alpha : f32, NoL : f32, NoV : f32) -> f32 {\n",
    "  let a2 = alpha * alpha;\n", "  let gv = NoL * sqrt(a2 + (1.0 - a2) * (NoV * NoV));\n",
    "  let gl = NoV * sqrt(a2 + (1.0 - a2) * (NoL * NoL));\n", "  return 0.5 / max(gv + gl, 0.000001);\n",
    "}\n\n", "fn F_Schlick(f0 : vec3<f32>, VoH : f32) -> vec3<f32> {\n", "  let fresnel = exp2((-5.55473 * VoH - 6.98316) * VoH);\n",
    "  return f0 * (1.0 - fresnel) + fresnel;\n", "}\n\n", "fn point_standard(N : vec3<f32>, V : vec3<f32>, world : vec3<f32>, diffuse : vec3<f32>, f0 : vec3<f32>, alpha : f32) -> vec3<f32> {\n",
    "  let falloff = point_falloff(world);\n", "  let L = point_direction(world);\n",
    "  let H = normalize(V + L);\n", "  let NoL = max(dot(N, L), 0.0);\n", "  let NoV = max(dot(N, V), 0.0);\n",
    "  let NoH = max(dot(N, H), 0.0);\n", "  let VoH = max(dot(V, H), 0.0);\n", "  let specular = F_Schlick(f0, VoH) * (D_GGX(alpha, NoH) * V_GGX_SmithCorrelated(alpha, NoL, NoV));\n",
    "  return (diffuse + specular) * (uniforms.point_color).xyz * NoL * falloff;\n",
    "}\n\n", "fn spot_standard(N : vec3<f32>, V : vec3<f32>, world : vec3<f32>, diffuse : vec3<f32>, f0 : vec3<f32>, alpha : f32) -> vec3<f32> {\n",
    "  let falloff = spot_falloff(world);\n", "  let L = spot_direction(world);\n",
    "  let H = normalize(V + L);\n", "  let NoL = max(dot(N, L), 0.0);\n", "  let NoV = max(dot(N, V), 0.0);\n",
    "  let NoH = max(dot(N, H), 0.0);\n", "  let VoH = max(dot(V, H), 0.0);\n", "  let specular = F_Schlick(f0, VoH) * (D_GGX(alpha, NoH) * V_GGX_SmithCorrelated(alpha, NoL, NoV));\n",
    "  return (diffuse + specular) * (uniforms.spot_color).xyz * NoL * falloff;\n",
    "}\n\n", "fn standard_lit(base : vec4<f32>, normal : vec3<f32>, world : vec3<f32>) -> vec4<f32> {\n",
    "  let roughness = max((uniforms.surface).x * textureSample(roughness_texture, roughness_sampler, input.v_uv).g, 0.0525);\n",
    "  let metalness = clamp((uniforms.surface).y * textureSample(metalness_texture, metalness_sampler, input.v_uv).b, 0.0, 1.0);\n",
    "  let alpha = roughness * roughness;\n", "  let diffuse_color = base.xyz * (1.0 - metalness);\n",
    "  let f0 = mix(vec3<f32>(0.04), base.xyz, metalness);\n", "  let N = normalize(normal);\n",
    "  let V = normalize((uniforms.camera_position).xyz - world);\n", "  let L = normalize((uniforms.light_direction).xyz);\n",
    "  let H = normalize(V + L);\n", "  let NoL = max(dot(N, L), 0.0);\n", "  let NoV = max(dot(N, V), 0.0);\n",
    "  let NoH = max(dot(N, H), 0.0);\n", "  let VoH = max(dot(V, H), 0.0);\n", "  let specular = F_Schlick(f0, VoH) * (D_GGX(alpha, NoH) * V_GGX_SmithCorrelated(alpha, NoL, NoV));\n",
    "  let diffuse = diffuse_color * 0.3183098861837907;\n", "  var direct = (diffuse + specular) * (uniforms.light_color).xyz * NoL * direct_shadow(world, N);\n",
    "  direct = direct + point_standard(N, V, world, diffuse, f0, alpha);\n", "  direct = direct + spot_standard(N, V, world, diffuse, f0, alpha);\n",
    "  let indirect = ((uniforms.ambient).xyz + hemisphere_term(N)) * diffuse;\n",
    "  return vec4<f32>(direct + indirect, base.w);\n", "}\n\n",
  ]
  let mut text = ""
  for line in lines {
    text = text + line
  }
  text
}

///|
fn position_attributes() -> Array[(String, Int32, ValueType)] {
  [
    ("position", 0, Vec3),
    ("normal", 1, Vec3),
    ("uv", 2, Vec2),
    ("color", 8, Vec4),
  ]
}

///|
fn mesh_attributes(instanced : Bool) -> Array[(String, Int32, ValueType)] {
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
/// 顶点色乘进底色，包含 alpha。没有该属性时打包成白色，乘上去不变。
/// r186: `color_vertex` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/color_vertex.glsl.js#L10 ; `color_fragment` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/color_fragment.glsl.js#L4
fn tint_vertex(color : Node) -> Node {
  let vertex = Varying("v_color", Vec4)
  Node::Vec4(
    Mul(Swizzle(color, "xyz"), Swizzle(vertex, "xyz")),
    Mul(Swizzle(color, "w"), Swizzle(vertex, "w")),
  )
}

///|
/// Lambert 和 Standard 在光照结果上加上自发光，再乘自发光贴图。不受阴影影响，也不乘顶点色。
/// 没有贴图时渲染器绑一张白纹理，乘上去不变。
/// r186: `emissive` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L122 ; `emissive` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L162
/// r186: `emissiveMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/emissivemap_fragment.glsl.js#L4
fn add_emissive(color : Node) -> Node {
  let glow = Mul(
    Swizzle(Uniform("emissive", Vec4), "xyz"),
    Swizzle(EmissiveSample, "xyz"),
  )
  Node::Vec4(Add(Swizzle(color, "xyz"), glow), Swizzle(color, "w"))
}

///|
/// 绿色通道乘在已经乘过顶点色的 alpha 上。雾只改 rgb，所以裁切看到的是乘完的 alpha。
/// r186: `diffuseColor.a` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/alphamap_fragment.glsl.js#L4
fn scale_alpha(color : Node) -> Node {
  Node::Vec4(
    Swizzle(color, "xyz"),
    Mul(Swizzle(color, "w"), Swizzle(AlphaSample, "g")),
  )
}

///|
fn with_vertex_color(
  varyings : Array[(String, ValueType)],
  assignments : Array[(String, Node)],
) -> (Array[(String, ValueType)], Array[(String, Node)]) {
  varyings.push(("v_color", Vec4))
  assignments.push(("v_color", Attribute("color", 8, Vec4)))
  (varyings, assignments)
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
/// r186: `MeshBasicMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L14
pub fn basic_program(instanced~ : Bool = false) -> Program {
  let position = Attribute("position", 0, Vec3)
  let normal = Attribute("normal", 1, Vec3)
  let shifted = Add(position, Mul(normal, Float(0.0)))
  let sample = TextureSample(Varying("v_uv", Vec2))
  let (instanced_varyings, instanced_assignments) = with_instance_color(
    [("v_uv", Vec2)],
    [("v_uv", Attribute("uv", 2, Vec2))],
    instanced,
  )
  let (colored_varyings, colored_assignments) = with_vertex_color(
    instanced_varyings, instanced_assignments,
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
    fragment_color: scale_alpha(
      tint_vertex(tint_instance(Mul(Uniform("color", Vec4), sample), instanced)),
    ),
    sampled: true,
    shadowed: false,
    emissive: false,
    roughness: false,
    metalness: false,
    alpha: true,
    preamble: "",
  }
}

///|
/// 背面法线。`surface.w` 大于 0.5 时只在背面片元取反，小于 -0.5 时整面取反。
/// `emissive.w` 大于 0.5 时改用视图空间位置的屏幕导数，再变回世界空间，不再按侧面翻转。
/// r186: `negateOnBackSide` https://github.com/mrdoob/three.js/blob/r186/src/nodes/display/FrontFacingNode.js#L91
/// r186: `faceDirection` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/normal_fragment_begin.glsl.js#L2
/// r186: `FLAT_SHADED` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/normal_fragment_begin.glsl.js#L6
fn facing_preamble() -> String {
  "fn facing_normal(n : vec3<f32>, front : bool) -> vec3<f32> {\n  if ((uniforms.emissive).w > 0.5) {\n    let view_pos = (uniforms.view * vec4<f32>(input.v_world, 1.0)).xyz;\n    let n_view = normalize(cross(dpdx(view_pos), dpdy(view_pos)));\n    return normalize(vec3<f32>(dot((uniforms.view)[0].xyz, n_view), dot((uniforms.view)[1].xyz, n_view), dot((uniforms.view)[2].xyz, n_view)));\n  }\n  let side = (uniforms.surface).w;\n  if (side > 0.5) {\n    if (front) {\n      return n;\n    }\n    return -n;\n  }\n  if (side < -0.5) {\n    return -n;\n  }\n  return n;\n}\n\n"
}

///|
/// Lambert：`color * (ambient + lightColor * max(dot(N, L), 0))`。
/// r186: `MeshLambertMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L24
pub fn lambert_program(instanced~ : Bool = false) -> Program {
  let position = Attribute("position", 0, Vec3)
  let normal = mesh_normal(instanced)
  let world_normal = Swizzle(
    Mul(Uniform("normal_matrix", Mat4), Vec4(normal, Float(0.0))),
    "xyz",
  )
  let n = Normalize(FacingNormal)
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
  let lit = Add(
    Add(
      Add(Add(Swizzle(Uniform("ambient", Vec4), "xyz"), HemisphereTerm), direct),
      PointTerm,
    ),
    SpotTerm,
  )
  let sample = TextureSample(Varying("v_uv", Vec2))
  let rgb = Mul(
    Mul(Swizzle(Uniform("color", Vec4), "xyz"), lit),
    Swizzle(sample, "xyz"),
  )
  let (instanced_varyings, instanced_assignments) = with_instance_color(
    [("v_normal", Vec3), ("v_uv", Vec2), ("v_world", Vec3)],
    [
      ("v_normal", world_normal),
      ("v_uv", Attribute("uv", 2, Vec2)),
      ("v_world", world),
    ],
    instanced,
  )
  let (colored_varyings, colored_assignments) = with_vertex_color(
    instanced_varyings, instanced_assignments,
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
    fragment_color: scale_alpha(
      add_emissive(
        tint_vertex(
          tint_instance(
            Vec4(
              rgb,
              Mul(Swizzle(Uniform("color", Vec4), "w"), Swizzle(sample, "w")),
            ),
            instanced,
          ),
        ),
      ),
    ),
    sampled: true,
    shadowed: true,
    emissive: true,
    roughness: false,
    metalness: false,
    alpha: true,
    preamble: if instanced {
      instance_preamble() +
      facing_preamble() +
      shadow_preamble() +
      point_preamble() +
      spot_preamble() +
      hemisphere_preamble()
    } else {
      facing_preamble() +
      shadow_preamble() +
      point_preamble() +
      spot_preamble() +
      hemisphere_preamble()
    },
  }
}

///|
/// Standard：`baseColor * (1 - metalness)` 的 Lambert 漫反射，加上 GGX 高光。`baseColor` 已乘贴图。
/// r186: `MeshStandardMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L41
pub fn standard_program(instanced~ : Bool = false) -> Program {
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
  let (instanced_varyings, instanced_assignments) = with_instance_color(
    [("v_normal", Vec3), ("v_uv", Vec2), ("v_world", Vec3)],
    [
      ("v_normal", world_normal),
      ("v_uv", Attribute("uv", 2, Vec2)),
      ("v_world", world),
    ],
    instanced,
  )
  let (colored_varyings, colored_assignments) = with_vertex_color(
    instanced_varyings, instanced_assignments,
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
    fragment_color: scale_alpha(
      add_emissive(StandardLit(tint_instance(tint_vertex(base), instanced))),
    ),
    sampled: true,
    shadowed: true,
    emissive: true,
    roughness: true,
    metalness: true,
    alpha: true,
    preamble: if instanced {
      instance_preamble() +
      facing_preamble() +
      shadow_preamble() +
      point_preamble() +
      spot_preamble() +
      hemisphere_preamble() +
      standard_preamble()
    } else {
      facing_preamble() +
      shadow_preamble() +
      point_preamble() +
      spot_preamble() +
      hemisphere_preamble() +
      standard_preamble()
    },
  }
}

///|
/// 折线和线段。只有位置和颜色，线宽由光栅器固定为 1 像素。
/// r186: `LineBasicMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineBasicMaterial.js#L15
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
    emissive: false,
    roughness: false,
    metalness: false,
    alpha: false,
    preamble: "",
  }
}
