// r186: `isShaderMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/ShaderMaterial.js#L67

///|
/// 着色器材质存下的默认顶点着色器。字符串以换行开头，`gl_Position` 那一行用制表符缩进，并以换行结束。渲染器不编译这串代码。
/// r186: `default_vertex` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/default_vertex.glsl.js#L1
fn default_vertex_shader() -> String {
  "\nvoid main() {\n\tgl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );\n}\n"
}

///|
/// 着色器材质存下的默认片元着色器。字符串以换行开头，`gl_FragColor` 那一行用制表符缩进，红色通道是 `1`，绿色和蓝色是 `0`，并以换行结束。渲染器不编译这串代码。
/// r186: `default_fragment` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/default_fragment.glsl.js#L1
fn default_fragment_shader() -> String {
  "\nvoid main() {\n\tgl_FragColor = vec4( 1.0, 0.0, 0.0, 1.0 );\n}\n"
}

///|
/// 着色器材质记下的扩展开关。`clip_cull_distance` 和 `multi_draw` 默认关闭。渲染器不打开它们。
/// r186: `extensions` https://github.com/mrdoob/three.js/blob/r186/src/materials/ShaderMaterial.js#L222 ; `clipCullDistance` https://github.com/mrdoob/three.js/blob/r186/src/materials/ShaderMaterial.js#L223 ; `multiDraw` https://github.com/mrdoob/three.js/blob/r186/src/materials/ShaderMaterial.js#L224
pub(all) struct ShaderExtensions {
  mut clip_cull_distance : Bool
  mut multi_draw : Bool
}

///|
/// 着色器的 GLSL 版本。`GLSL1` 的版本串是 `100`，`GLSL3` 的版本串是 `300 es`。空值表示不指定。
/// r186: `GLSL1` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1640 ; `GLSL3` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1648
pub(all) enum GlslVersion {
  GLSL1
  GLSL3
}

///|
/// `GLSL1` 的版本串是 `100`，`GLSL3` 是 `300 es`。渲染器不把这串写进着色器。
pub fn GlslVersion::code(self : GlslVersion) -> String {
  match self {
    GLSL1 => "100"
    GLSL3 => "300 es"
  }
}

///|
/// 自定义着色器。`is_shader_material` 为真，`is_raw_shader_material` 为假，`type_name` 是 `ShaderMaterial`，`defines` 是空表。颜色仍是白，`transparent` 默认关闭，`fog` 默认关闭，`lights` 默认关闭，`clipping` 默认关闭，`vertex_shader` 是默认顶点着色器，`fragment_shader` 是默认片元着色器，`uniforms` 是空表，`uniforms_groups` 是空数组，`linewidth` 默认 `1`，`force_single_pass` 默认打开，`extensions` 的两个开关默认关闭，`default_attribute_values` 有 `color` `[1, 1, 1]`、`uv` `[0, 0]` 和 `uv1` `[0, 0]`，`glsl_version` 默认空，`index0_attribute_name` 默认空，`uniforms_need_update` 默认关闭。渲染器仍按 Basic 着色，场景雾只在 `fog` 打开时混入，仍不按 `lights` 传入光照，仍不按 `clipping` 传入裁剪平面，仍不编译这两串着色器，仍不读取 `uniforms`，仍不把 `uniforms_groups` 收成 UBO，仍按 1 像素画线。透明且双面时，这个开关打开就一次画完。仍不打开 `clip_cull_distance` 和 `multi_draw`。仍不把缺省顶点属性填进缺失的缓冲。仍不按 `index0_attribute_name` 绑定顶点属性。仍不按 `uniforms_need_update` 强制上传 uniform。
/// r186: `isShaderMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/ShaderMaterial.js#L67
/// r186: `type` https://github.com/mrdoob/three.js/blob/r186/src/materials/ShaderMaterial.js#L69
/// r186: `defines` https://github.com/mrdoob/three.js/blob/r186/src/materials/ShaderMaterial.js#L89
/// r186: `vertexShader` https://github.com/mrdoob/three.js/blob/r186/src/materials/ShaderMaterial.js#L127
/// r186: `fragmentShader` https://github.com/mrdoob/three.js/blob/r186/src/materials/ShaderMaterial.js#L134
/// r186: `uniforms` https://github.com/mrdoob/three.js/blob/r186/src/materials/ShaderMaterial.js#L113
/// r186: `uniformsGroups` https://github.com/mrdoob/three.js/blob/r186/src/materials/ShaderMaterial.js#L120
/// r186: `linewidth` https://github.com/mrdoob/three.js/blob/r186/src/materials/ShaderMaterial.js#L145
/// r186: `forceSinglePass` https://github.com/mrdoob/three.js/blob/r186/src/materials/ShaderMaterial.js#L212
/// r186: `extensions` https://github.com/mrdoob/three.js/blob/r186/src/materials/ShaderMaterial.js#L222
/// r186: `defaultAttributeValues` https://github.com/mrdoob/three.js/blob/r186/src/materials/ShaderMaterial.js#L238
/// r186: `glslVersion` https://github.com/mrdoob/three.js/blob/r186/src/materials/ShaderMaterial.js#L268
/// r186: `index0AttributeName` https://github.com/mrdoob/three.js/blob/r186/src/materials/ShaderMaterial.js#L251
/// r186: `uniformsNeedUpdate` https://github.com/mrdoob/three.js/blob/r186/src/materials/ShaderMaterial.js#L260
/// r186: `fog` https://github.com/mrdoob/three.js/blob/r186/src/materials/ShaderMaterial.js#L186
/// r186: `lights` https://github.com/mrdoob/three.js/blob/r186/src/materials/ShaderMaterial.js#L195
/// r186: `clipping` https://github.com/mrdoob/three.js/blob/r186/src/materials/ShaderMaterial.js#L204
pub fn Material::shader(
  hex~ : Int32 = 0xFFFFFF,
  roughness~ : Double = 1.0,
  metalness~ : Double = 0.0,
) -> Material {
  {
    color: @math.Color::new().set_hex(hex),
    side: @constants.Front,
    shadow_side: None,
    opacity: 1.0,
    transparent: false,
    wireframe: false,
    map: None,
    roughness,
    metalness,
    fog: false,
    lights: false,
    clipping: false,
    vertex_shader: default_vertex_shader(),
    fragment_shader: default_fragment_shader(),
    uniforms: Map([]),
    uniforms_groups: [],
    default_attribute_values: fresh_default_attribute_values(),
    glsl_version: None,
    index0_attribute_name: None,
    uniforms_need_update: false,
    alpha_test: 0.0,
    flat_shading: false,
    depth_write: true,
    depth_test: true,
    depth_func: @constants.LessEqual,
    color_write: true,
    premultiplied_alpha: false,
    visible: true,
    force_single_pass: true,
    extensions: { clip_cull_distance: false, multi_draw: false, },
    emissive: @math.Color::new(r=0.0, g=0.0, b=0.0),
    emissive_intensity: 1.0,
    emissive_map: None,
    roughness_map: None,
    metalness_map: None,
    alpha_map: None,
    normal_map: None,
    normal_map_type: @constants.TangentSpace,
    normal_scale: @math.Vector2::new(x=1.0, y=1.0),
    displacement_map: None,
    displacement_scale: 1.0,
    displacement_bias: 0.0,
    specular_map: None,
    env_map: None,
    env_map_rotation: @math.Euler::new(),
    combine: @constants.Combine::Multiply,
    reflectivity: 1.0,
    env_map_intensity: 1.0,
    refraction_ratio: 0.98,
    light_map: None,
    light_map_intensity: 1.0,
    ao_map: None,
    ao_map_intensity: 1.0,
    bump_map: None,
    gradient_map: None,
    matcap: None,
    bump_scale: 1.0,
    wireframe_linewidth: 1.0,
    linewidth: 1.0,
    wireframe_linecap: WireframeCap::Round,
    wireframe_linejoin: WireframeJoin::Round,
    defines: Map([]),
    anisotropy_rotation: 0.0,
    anisotropy_map: None,
    clearcoat_map: None,
    clearcoat_roughness: 0.0,
    clearcoat_roughness_map: None,
    clearcoat_normal_scale: @math.Vector2::new(x=1.0, y=1.0),
    clearcoat_normal_map: None,
    ior: 1.5,
    iridescence_map: None,
    iridescence_ior: 1.3,
    iridescence_thickness_range: fresh_iridescence_thickness_range(),
    iridescence_thickness_map: None,
    sheen_color: @math.Color::new(r=0.0, g=0.0, b=0.0),
    specular: @math.Color::new().set_hex(0x111111),
    shininess: 30.0,
    sheen_color_map: None,
    sheen_roughness: 1.0,
    sheen_roughness_map: None,
    transmission_map: None,
    thickness: 0.0,
    thickness_map: None,
    attenuation_distance: 1.0 / 0.0,
    attenuation_color: @math.Color::new(r=1.0, g=1.0, b=1.0),
    specular_intensity: 1.0,
    specular_intensity_map: None,
    specular_color: @math.Color::new(r=1.0, g=1.0, b=1.0),
    specular_color_map: None,
    anisotropy: 0.0,
    clearcoat: 0.0,
    iridescence: 0.0,
    dispersion: 0.0,
    retroreflectivity: 0.0,
    sheen: 0.0,
    transmission: 0.0,
    is_mesh_physical_material: false,
    is_mesh_toon_material: false,
    is_mesh_matcap_material: false,
    is_mesh_normal_material: false,
    is_mesh_depth_material: false,
    depth_packing: @constants.DepthPacking::Basic,
    is_mesh_distance_material: false,
    is_mesh_phong_material: false,
    is_shadow_material: false,
    is_shader_material: true,
    is_raw_shader_material: false,
    vertex_colors: false,
    tone_mapped: true,
    alpha_hash: false,
    alpha_to_coverage: false,
    dithering: false,
    polygon_offset: false,
    polygon_offset_factor: 0.0,
    polygon_offset_units: 0.0,
    clip_shadows: false,
    clip_intersection: false,
    allow_override: true,
    blend_alpha: 0.0,
    blend_color: @math.Color::new(r=0.0, g=0.0, b=0.0),
    blending: @constants.Normal,
    blend_src: @constants.SrcAlpha,
    blend_dst: @constants.OneMinusSrcAlpha,
    blend_equation: @constants.Add,
    blend_src_alpha: None,
    blend_dst_alpha: None,
    blend_equation_alpha: None,
    stencil_write_mask: 0xFF,
    stencil_func: @constants.StencilFunc::Always,
    stencil_ref: 0,
    stencil_func_mask: 0xFF,
    stencil_fail: @constants.StencilOp::Keep,
    stencil_z_fail: @constants.StencilOp::Keep,
    stencil_z_pass: @constants.StencilOp::Keep,
    stencil_write: false,
    clipping_planes: None,
    precision: None,
    user_data: Map([]),
    version: 0,
    id: fresh_material_id(),
    uuid: @math.generate_uuid(),
    name: "",
    type_name: "ShaderMaterial",
    kind: Shader,
    listeners: Map([]),
  }
}
