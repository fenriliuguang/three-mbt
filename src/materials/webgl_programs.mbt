// r186: `getProgramCacheKey` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L402

///|
/// 拼出程序缓存键。有 `shader_id` 时只放这一个标识，否则依次放自定义顶点着色器和片元着色器标识。`defines` 按给出的顺序写成名字、值。不是 Raw 时再放参数、两段布尔掩码，以及渲染器输出颜色空间。最后总是放 `custom_program_cache_key`。字段用逗号连接。`envMapCubeUVHeight` 缺省是空字符串，`morphAttributeCount` 缺省也是空字符串。顶点前缀和片元前缀不加这一步。
/// r186: `getProgramCacheKey` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L402
/// r186: `getProgramCacheKeyParameters` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L442
/// r186: `getProgramCacheKeyBooleans` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L497
pub fn program_cache_key(
  shader_id~ : String? = None,
  custom_vertex_shader_id~ : String = "",
  custom_fragment_shader_id~ : String = "",
  defines~ : Array[(String, String)] = [],
  is_raw~ : Bool = false,
  precision~ : String = "highp",
  output_color_space~ : String = "",
  renderer_output_color_space~ : String = "",
  env_map_mode~ : String = "false",
  env_map_cube_uv_height~ : String = "",
  map_uv~ : String = "false",
  alpha_map_uv~ : String = "false",
  light_map_uv~ : String = "false",
  ao_map_uv~ : String = "false",
  bump_map_uv~ : String = "false",
  normal_map_uv~ : String = "false",
  displacement_map_uv~ : String = "false",
  emissive_map_uv~ : String = "false",
  metalness_map_uv~ : String = "false",
  roughness_map_uv~ : String = "false",
  anisotropy_map_uv~ : String = "false",
  clearcoat_map_uv~ : String = "false",
  clearcoat_normal_map_uv~ : String = "false",
  clearcoat_roughness_map_uv~ : String = "false",
  iridescence_map_uv~ : String = "false",
  iridescence_thickness_map_uv~ : String = "false",
  sheen_color_map_uv~ : String = "false",
  sheen_roughness_map_uv~ : String = "false",
  specular_map_uv~ : String = "false",
  specular_color_map_uv~ : String = "false",
  specular_intensity_map_uv~ : String = "false",
  transmission_map_uv~ : String = "false",
  thickness_map_uv~ : String = "false",
  combine~ : String = "0",
  fog_exp2~ : String = "false",
  size_attenuation~ : String = "false",
  morph_targets_count~ : String = "0",
  morph_attribute_count~ : String = "",
  num_sun_lights~ : String = "0",
  num_dir_lights~ : String = "0",
  num_point_lights~ : String = "0",
  num_spot_lights~ : String = "0",
  num_spot_light_maps~ : String = "0",
  num_hemi_lights~ : String = "0",
  num_rect_area_lights~ : String = "0",
  num_sun_light_shadows~ : String = "0",
  num_dir_light_shadows~ : String = "0",
  num_point_light_shadows~ : String = "0",
  num_spot_light_shadows~ : String = "0",
  num_spot_light_shadows_with_maps~ : String = "0",
  num_light_probes~ : String = "0",
  shadow_map_type~ : String = "0",
  tone_mapping~ : String = "0",
  num_clipping_planes~ : String = "0",
  num_clip_intersection~ : String = "0",
  depth_packing~ : String = "0",
  custom_program_cache_key~ : String = "",
  instancing~ : Bool = false,
  instancing_color~ : Bool = false,
  instancing_morph~ : Bool = false,
  matcap~ : Bool = false,
  env_map~ : Bool = false,
  normal_map_object_space~ : Bool = false,
  normal_map_tangent_space~ : Bool = false,
  clearcoat~ : Bool = false,
  iridescence~ : Bool = false,
  alpha_test~ : Bool = false,
  vertex_colors~ : Bool = false,
  vertex_alphas~ : Bool = false,
  vertex_uv1s~ : Bool = false,
  vertex_uv2s~ : Bool = false,
  vertex_uv3s~ : Bool = false,
  vertex_tangents~ : Bool = false,
  anisotropy~ : Bool = false,
  alpha_hash~ : Bool = false,
  batching~ : Bool = false,
  dispersion~ : Bool = false,
  retroreflection~ : Bool = false,
  batching_color~ : Bool = false,
  gradient_map~ : Bool = false,
  packed_normal_map~ : Bool = false,
  vertex_normals~ : Bool = false,
  fog~ : Bool = false,
  use_fog~ : Bool = false,
  flat_shading~ : Bool = false,
  logarithmic_depth_buffer~ : Bool = false,
  reversed_depth_buffer~ : Bool = false,
  skinning~ : Bool = false,
  morph_targets~ : Bool = false,
  morph_normals~ : Bool = false,
  morph_colors~ : Bool = false,
  premultiplied_alpha~ : Bool = false,
  shadow_map_enabled~ : Bool = false,
  double_sided~ : Bool = false,
  flip_sided~ : Bool = false,
  use_depth_packing~ : Bool = false,
  dithering~ : Bool = false,
  transmission~ : Bool = false,
  sheen~ : Bool = false,
  is_opaque~ : Bool = false,
  points_uvs~ : Bool = false,
  decode_video_texture~ : Bool = false,
  decode_video_texture_emissive~ : Bool = false,
  alpha_to_coverage~ : Bool = false,
  light_probe_grids~ : Bool = false,
  has_position_attribute~ : Bool = false,
) -> String {
  let parts : Array[String] = []
  match shader_id {
    Some(id) => parts.push(id)
    None => {
      parts.push(custom_vertex_shader_id)
      parts.push(custom_fragment_shader_id)
    }
  }
  let mut index = 0
  while index < defines.length() {
    parts.push(defines[index].0)
    parts.push(defines[index].1)
    index = index + 1
  }
  if !is_raw {
    parts.push(precision)
    parts.push(output_color_space)
    parts.push(env_map_mode)
    parts.push(env_map_cube_uv_height)
    parts.push(map_uv)
    parts.push(alpha_map_uv)
    parts.push(light_map_uv)
    parts.push(ao_map_uv)
    parts.push(bump_map_uv)
    parts.push(normal_map_uv)
    parts.push(displacement_map_uv)
    parts.push(emissive_map_uv)
    parts.push(metalness_map_uv)
    parts.push(roughness_map_uv)
    parts.push(anisotropy_map_uv)
    parts.push(clearcoat_map_uv)
    parts.push(clearcoat_normal_map_uv)
    parts.push(clearcoat_roughness_map_uv)
    parts.push(iridescence_map_uv)
    parts.push(iridescence_thickness_map_uv)
    parts.push(sheen_color_map_uv)
    parts.push(sheen_roughness_map_uv)
    parts.push(specular_map_uv)
    parts.push(specular_color_map_uv)
    parts.push(specular_intensity_map_uv)
    parts.push(transmission_map_uv)
    parts.push(thickness_map_uv)
    parts.push(combine)
    parts.push(fog_exp2)
    parts.push(size_attenuation)
    parts.push(morph_targets_count)
    parts.push(morph_attribute_count)
    parts.push(num_sun_lights)
    parts.push(num_dir_lights)
    parts.push(num_point_lights)
    parts.push(num_spot_lights)
    parts.push(num_spot_light_maps)
    parts.push(num_hemi_lights)
    parts.push(num_rect_area_lights)
    parts.push(num_sun_light_shadows)
    parts.push(num_dir_light_shadows)
    parts.push(num_point_light_shadows)
    parts.push(num_spot_light_shadows)
    parts.push(num_spot_light_shadows_with_maps)
    parts.push(num_light_probes)
    parts.push(shadow_map_type)
    parts.push(tone_mapping)
    parts.push(num_clipping_planes)
    parts.push(num_clip_intersection)
    parts.push(depth_packing)
    parts.push(first_program_mask(
      instancing,
      instancing_color,
      instancing_morph,
      matcap,
      env_map,
      normal_map_object_space,
      normal_map_tangent_space,
      clearcoat,
      iridescence,
      alpha_test,
      vertex_colors,
      vertex_alphas,
      vertex_uv1s,
      vertex_uv2s,
      vertex_uv3s,
      vertex_tangents,
      anisotropy,
      alpha_hash,
      batching,
      dispersion,
      retroreflection,
      batching_color,
      gradient_map,
      packed_normal_map,
      vertex_normals,
    ).to_string())
    parts.push(second_program_mask(
      fog,
      use_fog,
      flat_shading,
      logarithmic_depth_buffer,
      reversed_depth_buffer,
      skinning,
      morph_targets,
      morph_normals,
      morph_colors,
      premultiplied_alpha,
      shadow_map_enabled,
      double_sided,
      flip_sided,
      use_depth_packing,
      dithering,
      transmission,
      sheen,
      is_opaque,
      points_uvs,
      decode_video_texture,
      decode_video_texture_emissive,
      alpha_to_coverage,
      light_probe_grids,
      has_position_attribute,
    ).to_string())
    parts.push(renderer_output_color_space)
  }
  parts.push(custom_program_cache_key)
  join_commas(parts)
}

///|
fn first_program_mask(
  instancing : Bool,
  instancing_color : Bool,
  instancing_morph : Bool,
  matcap : Bool,
  env_map : Bool,
  normal_map_object_space : Bool,
  normal_map_tangent_space : Bool,
  clearcoat : Bool,
  iridescence : Bool,
  alpha_test : Bool,
  vertex_colors : Bool,
  vertex_alphas : Bool,
  vertex_uv1s : Bool,
  vertex_uv2s : Bool,
  vertex_uv3s : Bool,
  vertex_tangents : Bool,
  anisotropy : Bool,
  alpha_hash : Bool,
  batching : Bool,
  dispersion : Bool,
  retroreflection : Bool,
  batching_color : Bool,
  gradient_map : Bool,
  packed_normal_map : Bool,
  vertex_normals : Bool,
) -> Int {
  let mut mask = 0
  if instancing { mask = mask | (1 << 0) }
  if instancing_color { mask = mask | (1 << 1) }
  if instancing_morph { mask = mask | (1 << 2) }
  if matcap { mask = mask | (1 << 3) }
  if env_map { mask = mask | (1 << 4) }
  if normal_map_object_space { mask = mask | (1 << 5) }
  if normal_map_tangent_space { mask = mask | (1 << 6) }
  if clearcoat { mask = mask | (1 << 7) }
  if iridescence { mask = mask | (1 << 8) }
  if alpha_test { mask = mask | (1 << 9) }
  if vertex_colors { mask = mask | (1 << 10) }
  if vertex_alphas { mask = mask | (1 << 11) }
  if vertex_uv1s { mask = mask | (1 << 12) }
  if vertex_uv2s { mask = mask | (1 << 13) }
  if vertex_uv3s { mask = mask | (1 << 14) }
  if vertex_tangents { mask = mask | (1 << 15) }
  if anisotropy { mask = mask | (1 << 16) }
  if alpha_hash { mask = mask | (1 << 17) }
  if batching { mask = mask | (1 << 18) }
  if dispersion { mask = mask | (1 << 19) }
  if batching_color { mask = mask | (1 << 20) }
  if gradient_map { mask = mask | (1 << 21) }
  if packed_normal_map { mask = mask | (1 << 22) }
  if vertex_normals { mask = mask | (1 << 23) }
  if retroreflection { mask = mask | (1 << 24) }
  mask
}

///|
fn second_program_mask(
  fog : Bool,
  use_fog : Bool,
  flat_shading : Bool,
  logarithmic_depth_buffer : Bool,
  reversed_depth_buffer : Bool,
  skinning : Bool,
  morph_targets : Bool,
  morph_normals : Bool,
  morph_colors : Bool,
  premultiplied_alpha : Bool,
  shadow_map_enabled : Bool,
  double_sided : Bool,
  flip_sided : Bool,
  use_depth_packing : Bool,
  dithering : Bool,
  transmission : Bool,
  sheen : Bool,
  is_opaque : Bool,
  points_uvs : Bool,
  decode_video_texture : Bool,
  decode_video_texture_emissive : Bool,
  alpha_to_coverage : Bool,
  light_probe_grids : Bool,
  has_position_attribute : Bool,
) -> Int {
  let mut mask = 0
  if fog { mask = mask | (1 << 0) }
  if use_fog { mask = mask | (1 << 1) }
  if flat_shading { mask = mask | (1 << 2) }
  if logarithmic_depth_buffer { mask = mask | (1 << 3) }
  if reversed_depth_buffer { mask = mask | (1 << 4) }
  if skinning { mask = mask | (1 << 5) }
  if morph_targets { mask = mask | (1 << 6) }
  if morph_normals { mask = mask | (1 << 7) }
  if morph_colors { mask = mask | (1 << 8) }
  if premultiplied_alpha { mask = mask | (1 << 9) }
  if shadow_map_enabled { mask = mask | (1 << 10) }
  if double_sided { mask = mask | (1 << 11) }
  if flip_sided { mask = mask | (1 << 12) }
  if use_depth_packing { mask = mask | (1 << 13) }
  if dithering { mask = mask | (1 << 14) }
  if transmission { mask = mask | (1 << 15) }
  if sheen { mask = mask | (1 << 16) }
  if is_opaque { mask = mask | (1 << 17) }
  if points_uvs { mask = mask | (1 << 18) }
  if decode_video_texture { mask = mask | (1 << 19) }
  if decode_video_texture_emissive { mask = mask | (1 << 20) }
  if alpha_to_coverage { mask = mask | (1 << 21) }
  if light_probe_grids { mask = mask | (1 << 22) }
  if has_position_attribute { mask = mask | (1 << 23) }
  mask
}

///|
fn join_commas(parts : Array[String]) -> String {
  if parts.length() == 0 {
    return ""
  }
  let mut joined = parts[0]
  let mut index = 1
  while index < parts.length() {
    joined = joined + "," + parts[index]
    index = index + 1
  }
  joined
}

///|
/// 按材质类型取 uniform。内置类型先换成着色器标识，再从 `library` 里取出同名表并复制。`MeshStandardMaterial` 和 `MeshPhysicalMaterial` 都用 `physical`。`LineBasicMaterial` 用 `basic`。库里没有这张表时中止。`ShaderMaterial`、`RawShaderMaterial` 和其它名字直接返回传入的表，不复制。顶点前缀和片元前缀不加这一步。
/// r186: `getUniforms` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L608
/// r186: `shaderIDs` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L28
pub fn program_uniforms(
  type_name : String,
  material_uniforms : Map[String, Double],
  library : Map[String, Map[String, Double]],
) -> Map[String, Double] {
  match builtin_shader_id(type_name) {
    Some(id) =>
      match library.get(id) {
        Some(uniforms) => copied_uniforms(uniforms)
        None =>
          abort("THREE.WebGLPrograms: Can not resolve shader uniforms <" + id + ">")
      }
    None => material_uniforms
  }
}

///|
fn builtin_shader_id(type_name : String) -> String? {
  match type_name {
    "MeshDepthMaterial" => Some("depth")
    "MeshDistanceMaterial" => Some("distance")
    "MeshNormalMaterial" => Some("normal")
    "MeshBasicMaterial" => Some("basic")
    "MeshLambertMaterial" => Some("lambert")
    "MeshPhongMaterial" => Some("phong")
    "MeshToonMaterial" => Some("toon")
    "MeshStandardMaterial" => Some("physical")
    "MeshPhysicalMaterial" => Some("physical")
    "MeshMatcapMaterial" => Some("matcap")
    "LineBasicMaterial" => Some("basic")
    "LineDashedMaterial" => Some("dashed")
    "PointsMaterial" => Some("points")
    "ShadowMaterial" => Some("shadow")
    "SpriteMaterial" => Some("sprite")
    _ => None
  }
}

///|
/// 按缓存键记下的程序。只存键和引用次数。第一次取出时引用次数是 `1`。同键再取就把次数加一。不编译着色器，也不持有 WebGL 程序。
/// r186: `usedTimes` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L1026
/// r186: `cacheKey` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L1025
pub struct CachedProgram {
  cache_key : String
  used_times : Ref[Int]
}

///|
/// 程序缓存。`programs` 按第一次出现的顺序保存。同一键在表里只占一项。
/// r186: `acquireProgram` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L628
pub struct ProgramCache {
  programs : Array[CachedProgram]
  by_key : Map[String, CachedProgram]
}

///|
/// 新建空缓存。
/// r186: `acquireProgram` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L628
pub fn ProgramCache::new() -> ProgramCache {
  { programs: [], by_key: Map([]) }
}

///|
/// 按缓存键取出程序。没有就新建，引用次数从 `1` 起。已有则把引用次数加一，并返回同一条记录。
/// r186: `acquireProgram` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L628
pub fn ProgramCache::acquire(
  self : ProgramCache,
  cache_key : String,
) -> CachedProgram {
  match self.by_key.get(cache_key) {
    Some(program) => {
      program.used_times.val = program.used_times.val + 1
      program
    }
    None => {
      let program : CachedProgram = {
        cache_key, used_times: Ref::Ref(1),
      }
      self.programs.push(program)
      self.by_key.set(cache_key, program)
      program
    }
  }
}

///|
/// 把引用次数减一。减到 `0` 时，用列表末尾的那一项填上这个空位，再从键表里删掉。次数仍大于 `0` 时列表不动。不释放 WebGL 程序。
/// r186: `releaseProgram` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L649
pub fn ProgramCache::release(self : ProgramCache, program : CachedProgram) -> Unit {
  program.used_times.val = program.used_times.val - 1
  if program.used_times.val != 0 {
    return
  }
  let mut found = None
  let mut index = 0
  while index < self.programs.length() {
    if self.programs[index].cache_key == program.cache_key {
      found = Some(index)
    }
    index = index + 1
  }
  match found {
    None => ()
    Some(index) => {
      let last = self.programs.length() - 1
      self.programs[index] = self.programs[last]
      ignore(self.programs.pop())
      ignore(self.by_key.remove(program.cache_key))
    }
  }
}

///|
/// 程序参数里的着色器类型。就是材质的 `type`，改名字不会改它。
/// r186: `shaderType` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L192
pub fn Material::shader_type(self : Material) -> String {
  self.type_name
}

///|
/// 程序参数里的着色器名字。就是材质的 `name`，默认空字符串。改它不会改 `shaderType`。
/// r186: `shaderName` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L193
pub fn Material::shader_name(self : Material) -> String {
  self.name
}

///|
/// 程序参数里的顶点着色器。内置类型的源码还在 `ShaderLib` 里，这里先不给。Shader 和 Raw 用材质自己的 `vertex_shader`。
/// r186: `vertexShader` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L108
/// r186: `vertexShader` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L195
pub fn Material::program_vertex_shader(self : Material) -> String? {
  match builtin_shader_id(self.type_name) {
    Some(_) => None
    None => Some(self.vertex_shader)
  }
}

///|
/// 程序参数里的片元着色器。内置类型的源码还在 `ShaderLib` 里，这里先不给。Shader 和 Raw 用材质自己的 `fragment_shader`。
/// r186: `fragmentShader` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L109
/// r186: `fragmentShader` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L196
pub fn Material::program_fragment_shader(self : Material) -> String? {
  match builtin_shader_id(self.type_name) {
    Some(_) => None
    None => Some(self.fragment_shader)
  }
}

///|
/// 程序参数里的宏表。就是材质自己的 `defines`，不复制。Standard 里有空的 `STANDARD`，Physical 再加空的 `PHYSICAL`。
/// r186: `defines` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L197
pub fn Material::program_defines(self : Material) -> Map[String, String] {
  self.defines
}

///|
/// 程序参数里的 Raw 标记。只有 Raw 是 `true`。Shader、Basic、Lambert 都是 `false`。
/// r186: `isRawShaderMaterial` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L202
pub fn Material::program_is_raw_shader_material(self : Material) -> Bool {
  self.is_raw_shader_material
}

///|
/// 程序参数里的 GLSL 版本。默认空。写成 `GLSL1` 或 `GLSL3` 后读到的就是这个值。
/// r186: `glslVersion` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L203
pub fn Material::program_glsl_version(self : Material) -> GlslVersion? {
  self.glsl_version
}

///|
/// 程序参数里的精度。材质没写时用渲染器传来的精度。写了就按 `getMaxPrecision` 选 `highp`、`mediump` 或 `lowp`。
/// r186: `precision` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L71
/// r186: `precision` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L205
pub fn Material::program_precision(
  self : Material,
  capabilities_precision : String,
  vertex_highp~ : Bool = true,
  fragment_highp~ : Bool = true,
  vertex_mediump~ : Bool = true,
  fragment_mediump~ : Bool = true,
) -> String {
  match self.precision {
    None => capabilities_precision
    Some(precision) =>
      max_precision(
        precision_word(Some(precision)),
        vertex_highp=vertex_highp,
        fragment_highp=fragment_highp,
        vertex_mediump=vertex_mediump,
        fragment_mediump=fragment_mediump,
      )
  }
}

///|
/// 显卡能用的最高精度。`highp` 要顶点和片元的高精度浮点都可用，否则降到 `mediump`。`mediump` 同样要两边可用，否则是 `lowp`。`lowp` 不再往下看。
/// r186: `getMaxPrecision` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLCapabilities.js#L55
pub fn max_precision(
  precision : String,
  vertex_highp~ : Bool = true,
  fragment_highp~ : Bool = true,
  vertex_mediump~ : Bool = true,
  fragment_mediump~ : Bool = true,
) -> String {
  let mut chosen = precision
  if chosen == "highp" {
    if vertex_highp && fragment_highp {
      return "highp"
    }
    chosen = "mediump"
  }
  if chosen == "mediump" && vertex_mediump && fragment_mediump {
    return "mediump"
  }
  "lowp"
}

///|
/// 程序参数里的合批标记。对象是合批网格时为 `true`，否则为 `false`。这里还没有合批网格类型，由调用方传入。
/// r186: `batching` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L125
/// r186: `batching` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L207
pub fn program_batching(is_batched_mesh~ : Bool = false) -> Bool {
  is_batched_mesh
}

///|
/// 程序参数里的合批颜色。合批网格而且有颜色贴图时才是 `true`。缺一则是 `false`。
/// r186: `batchingColor` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L208
pub fn program_batching_color(
  is_batched_mesh~ : Bool = false,
  has_colors_texture~ : Bool = false,
) -> Bool {
  is_batched_mesh && has_colors_texture
}

///|
/// 程序参数里的实例化标记。对象是实例网格时为 `true`，否则为 `false`。
/// r186: `instancing` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L124
/// r186: `instancing` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L209
pub fn program_instancing(is_instanced_mesh~ : Bool = false) -> Bool {
  is_instanced_mesh
}

///|
/// 程序参数里的实例颜色。实例网格而且有 `instanceColor` 时才是 `true`。缺一则是 `false`。
/// r186: `instancingColor` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L210
pub fn program_instancing_color(
  is_instanced_mesh~ : Bool = false,
  has_instance_color~ : Bool = false,
) -> Bool {
  is_instanced_mesh && has_instance_color
}

///|
/// 程序参数里的实例形变。实例网格而且有 `morphTexture` 时才是 `true`。缺一则是 `false`。
/// r186: `instancingMorph` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L211
pub fn program_instancing_morph(
  is_instanced_mesh~ : Bool = false,
  has_morph_texture~ : Bool = false,
) -> Bool {
  is_instanced_mesh && has_morph_texture
}

///|
/// 程序参数里的输出颜色空间。没有渲染目标时用渲染器的输出空间。有目标但不是 XR 目标时用工作空间。XR 目标用目标贴图自己的空间。
/// r186: `outputColorSpace` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L213
pub fn program_output_color_space(
  renderer_output_color_space : String,
  working_color_space : String,
  has_render_target~ : Bool = false,
  is_xr_render_target~ : Bool = false,
  target_color_space~ : String = "",
) -> String {
  if !has_render_target {
    return renderer_output_color_space
  }
  if is_xr_render_target {
    return target_color_space
  }
  working_color_space
}

///|
/// 程序参数里的 alpha to coverage。就是材质自己的开关。默认关闭。
/// r186: `alphaToCoverage` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L214
pub fn Material::program_alpha_to_coverage(self : Material) -> Bool {
  self.alpha_to_coverage
}

///|
/// 程序参数里的颜色贴图标记。材质有 `map` 时为 `true`，没有时为 `false`。
/// r186: `map` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L127
/// r186: `map` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L216
pub fn Material::program_map(self : Material) -> Bool {
  match self.map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的 matcap 标记。材质有 `matcap` 时为 `true`，没有时为 `false`。
/// r186: `matcap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L128
/// r186: `matcap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L217
pub fn Material::program_matcap(self : Material) -> Bool {
  match self.matcap {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的环境贴图标记。材质自己有 `env_map` 时为 `true`。Lambert、Phong、Toon、Standard、Physical 在场景有环境时也为 `true`。其它材质不看场景。
/// r186: `envMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L60
/// r186: `envMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L218
pub fn Material::program_env_map(
  self : Material,
  has_scene_environment~ : Bool = false,
) -> Bool {
  match self.env_map {
    Some(_) => true
    None => has_scene_environment && scene_environment_material(self.kind)
  }
}

///|
/// 程序参数里的环境贴图模式。没有环境贴图时是空。有贴图时用调用方给出的 mapping，场景环境也算有贴图。
/// r186: `envMapMode` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L219
pub fn Material::program_env_map_mode(
  self : Material,
  mapping : Int,
  has_scene_environment~ : Bool = false,
) -> Int? {
  if self.program_env_map(has_scene_environment=has_scene_environment) {
    Some(mapping)
  } else {
    None
  }
}

///|
/// `CubeUVReflectionMapping`。只有这个 mapping 才写出立方 UV 高度。
let cube_uv_reflection_mapping : Int = 306

///|
/// 程序参数里的立方 UV 环境贴图高度。没有环境贴图，或 mapping 不是 `306` 时为空。材质自己的贴图用它的高度。场景环境用调用方给出的高度。
/// r186: `envMapCubeUVHeight` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L64
/// r186: `envMapCubeUVHeight` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L220
pub fn Material::program_env_map_cube_uv_height(
  self : Material,
  mapping : Int,
  scene_environment_height~ : Int = 0,
  has_scene_environment~ : Bool = false,
) -> Int? {
  if mapping != cube_uv_reflection_mapping {
    return None
  }
  match self.env_map {
    Some(texture) => Some(texture.height)
    None =>
      if has_scene_environment && scene_environment_material(self.kind) {
        Some(scene_environment_height)
      } else {
        None
      }
  }
}

///|
/// 程序参数里的环境光遮蔽贴图标记。材质有 `ao_map` 时为 `true`，没有时为 `false`。
/// r186: `aoMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L130
/// r186: `aoMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L221
pub fn Material::program_ao_map(self : Material) -> Bool {
  match self.ao_map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的光照贴图标记。材质有 `light_map` 时为 `true`，没有时为 `false`。
/// r186: `lightMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L131
/// r186: `lightMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L222
pub fn Material::program_light_map(self : Material) -> Bool {
  match self.light_map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的凹凸贴图标记。有 `bump_map` 且没有线框时为 `true`。线框打开时为 `false`。
/// r186: `bumpMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L132
/// r186: `bumpMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L223
pub fn Material::program_bump_map(self : Material) -> Bool {
  match self.bump_map {
    None => false
    Some(_) => !self.wireframe
  }
}

///|
/// 程序参数里的法线贴图标记。材质有 `normal_map` 时为 `true`，没有时为 `false`。
/// r186: `normalMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L133
/// r186: `normalMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L224
pub fn Material::program_normal_map(self : Material) -> Bool {
  match self.normal_map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的物体空间法线贴图标记。有 `normal_map` 且类型是物体空间时为 `true`。切线空间或没有贴图时为 `false`。
/// r186: `normalMapObjectSpace` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L228
pub fn Material::program_normal_map_object_space(self : Material) -> Bool {
  match self.normal_map {
    None => false
    Some(_) => self.normal_map_type is @constants.ObjectSpace
  }
}

///|
/// 程序参数里的切线空间法线贴图标记。有 `normal_map` 且类型是切线空间时为 `true`。物体空间或没有贴图时为 `false`。
/// r186: `normalMapTangentSpace` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L229
pub fn Material::program_normal_map_tangent_space(self : Material) -> Bool {
  match self.normal_map {
    None => false
    Some(_) => self.normal_map_type is @constants.TangentSpace
  }
}

///|
/// `RGFormat` 是 `1030`，`RG11_EAC_Format` 是 `37490`，`RED_GREEN_RGTC2_Format` 是 `36285`。
/// r186: `isPackedRGFormat` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L10
/// r186: `RGFormat` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L804
/// r186: `RG11_EAC_Format` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L941
/// r186: `RED_GREEN_RGTC2_Format` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1109
fn packed_rg_format(format : Int) -> Bool {
  format == 1030 || format == 37490 || format == 36285
}

///|
/// 程序参数里的打包法线贴图标记。有 `normal_map`、类型是切线空间，且格式是打包 RG 时为 `true`。贴图还没有 format，所以格式由调用方传入。物体空间、没有贴图或其它格式时为 `false`。
/// r186: `packedNormalMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L230
pub fn Material::program_packed_normal_map(
  self : Material,
  format : Int,
) -> Bool {
  match self.normal_map {
    None => false
    Some(_) =>
      self.normal_map_type is @constants.TangentSpace && packed_rg_format(format)
  }
}

///|
/// 程序参数里的位移贴图标记。材质有 `displacement_map` 时为 `true`，没有时为 `false`。
/// r186: `displacementMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L134
/// r186: `displacementMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L225
pub fn Material::program_displacement_map(self : Material) -> Bool {
  match self.displacement_map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的自发光贴图标记。材质有 `emissive_map` 时为 `true`，没有时为 `false`。
/// r186: `emissiveMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L135
/// r186: `emissiveMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L226
pub fn Material::program_emissive_map(self : Material) -> Bool {
  match self.emissive_map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的金属度贴图标记。材质有 `metalness_map` 时为 `true`，没有时为 `false`。
/// r186: `metalnessMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L137
/// r186: `metalnessMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L232
pub fn Material::program_metalness_map(self : Material) -> Bool {
  match self.metalness_map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的粗糙度贴图标记。材质有 `roughness_map` 时为 `true`，没有时为 `false`。
/// r186: `roughnessMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L138
/// r186: `roughnessMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L233
pub fn Material::program_roughness_map(self : Material) -> Bool {
  match self.roughness_map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的各向异性标记。`anisotropy` 大于 `0` 时为 `true`。`0` 和负数时为 `false`。
/// r186: `anisotropy` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L140
/// r186: `anisotropy` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L235
pub fn Material::program_anisotropy(self : Material) -> Bool {
  self.anisotropy > 0.0
}

///|
/// 程序参数里的各向异性贴图标记。`anisotropy` 大于 `0` 且有 `anisotropy_map` 时为 `true`。强度不大于 `0` 或没有贴图时为 `false`。
/// r186: `anisotropyMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L148
/// r186: `anisotropyMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L236
pub fn Material::program_anisotropy_map(self : Material) -> Bool {
  if self.anisotropy <= 0.0 {
    return false
  }
  match self.anisotropy_map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的清漆标记。`clearcoat` 大于 `0` 时为 `true`。`0` 和负数时为 `false`。
/// r186: `clearcoat` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L141
/// r186: `clearcoat` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L238
pub fn Material::program_clearcoat(self : Material) -> Bool {
  self.clearcoat > 0.0
}

///|
/// 程序参数里的清漆贴图标记。`clearcoat` 大于 `0` 且有 `clearcoat_map` 时为 `true`。强度不大于 `0` 或没有贴图时为 `false`。
/// r186: `clearcoatMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L150
/// r186: `clearcoatMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L239
pub fn Material::program_clearcoat_map(self : Material) -> Bool {
  if self.clearcoat <= 0.0 {
    return false
  }
  match self.clearcoat_map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的清漆法线贴图标记。`clearcoat` 大于 `0` 且有 `clearcoat_normal_map` 时为 `true`。强度不大于 `0` 或没有贴图时为 `false`。
/// r186: `clearcoatNormalMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L151
/// r186: `clearcoatNormalMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L240
pub fn Material::program_clearcoat_normal_map(self : Material) -> Bool {
  if self.clearcoat <= 0.0 {
    return false
  }
  match self.clearcoat_normal_map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的清漆粗糙度贴图标记。`clearcoat` 大于 `0` 且有 `clearcoat_roughness_map` 时为 `true`。强度不大于 `0` 或没有贴图时为 `false`。
/// r186: `clearcoatRoughnessMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L152
/// r186: `clearcoatRoughnessMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L241
pub fn Material::program_clearcoat_roughness_map(self : Material) -> Bool {
  if self.clearcoat <= 0.0 {
    return false
  }
  match self.clearcoat_roughness_map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的色散标记。`dispersion` 大于 `0` 时为 `true`。`0` 和负数时为 `false`。
/// r186: `dispersion` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L142
/// r186: `dispersion` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L243
pub fn Material::program_dispersion(self : Material) -> Bool {
  self.dispersion > 0.0
}

///|
/// 程序参数里的逆反射标记。`retroreflectivity` 大于 `0` 时为 `true`。`0` 和负数时为 `false`。
/// r186: `retroreflection` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L143
/// r186: `retroreflection` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L244
pub fn Material::program_retroreflection(self : Material) -> Bool {
  self.retroreflectivity > 0.0
}

///|
/// 程序参数里的彩虹标记。`iridescence` 大于 `0` 时为 `true`。`0` 和负数时为 `false`。
/// r186: `iridescence` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L144
/// r186: `iridescence` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L246
pub fn Material::program_iridescence(self : Material) -> Bool {
  self.iridescence > 0.0
}

///|
/// 程序参数里的彩虹贴图标记。`iridescence` 大于 `0` 且有 `iridescence_map` 时为 `true`。强度不大于 `0` 或没有贴图时为 `false`。
/// r186: `iridescenceMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L154
/// r186: `iridescenceMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L247
pub fn Material::program_iridescence_map(self : Material) -> Bool {
  if self.iridescence <= 0.0 {
    return false
  }
  match self.iridescence_map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的彩虹厚度贴图标记。`iridescence` 大于 `0` 且有 `iridescence_thickness_map` 时为 `true`。强度不大于 `0` 或没有贴图时为 `false`。
/// r186: `iridescenceThicknessMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L155
/// r186: `iridescenceThicknessMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L248
pub fn Material::program_iridescence_thickness_map(self : Material) -> Bool {
  if self.iridescence <= 0.0 {
    return false
  }
  match self.iridescence_thickness_map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的光泽标记。`sheen` 大于 `0` 时为 `true`。`0` 和负数时为 `false`。
/// r186: `sheen` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L145
/// r186: `sheen` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L250
pub fn Material::program_sheen(self : Material) -> Bool {
  self.sheen > 0.0
}

///|
/// 程序参数里的光泽颜色贴图标记。`sheen` 大于 `0` 且有 `sheen_color_map` 时为 `true`。强度不大于 `0` 或没有贴图时为 `false`。
/// r186: `sheenColorMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L157
/// r186: `sheenColorMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L251
pub fn Material::program_sheen_color_map(self : Material) -> Bool {
  if self.sheen <= 0.0 {
    return false
  }
  match self.sheen_color_map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的光泽粗糙度贴图标记。`sheen` 大于 `0` 且有 `sheen_roughness_map` 时为 `true`。强度不大于 `0` 或没有贴图时为 `false`。
/// r186: `sheenRoughnessMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L158
/// r186: `sheenRoughnessMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L252
pub fn Material::program_sheen_roughness_map(self : Material) -> Bool {
  if self.sheen <= 0.0 {
    return false
  }
  match self.sheen_roughness_map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的高光贴图标记。材质有 `specular_map` 时为 `true`，没有时为 `false`。
/// r186: `specularMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L160
/// r186: `specularMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L254
pub fn Material::program_specular_map(self : Material) -> Bool {
  match self.specular_map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的高光颜色贴图标记。材质有 `specular_color_map` 时为 `true`，没有时为 `false`。
/// r186: `specularColorMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L161
/// r186: `specularColorMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L255
pub fn Material::program_specular_color_map(self : Material) -> Bool {
  match self.specular_color_map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的高光强度贴图标记。材质有 `specular_intensity_map` 时为 `true`，没有时为 `false`。
/// r186: `specularIntensityMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L162
/// r186: `specularIntensityMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L256
pub fn Material::program_specular_intensity_map(self : Material) -> Bool {
  match self.specular_intensity_map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的透射标记。`transmission` 大于 `0` 时为 `true`。`0` 和负数时为 `false`。
/// r186: `transmission` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L146
/// r186: `transmission` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L258
pub fn Material::program_transmission(self : Material) -> Bool {
  self.transmission > 0.0
}

///|
/// 程序参数里的透射贴图标记。`transmission` 大于 `0` 且有 `transmission_map` 时为 `true`。强度不大于 `0` 或没有贴图时为 `false`。
/// r186: `transmissionMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L164
/// r186: `transmissionMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L259
pub fn Material::program_transmission_map(self : Material) -> Bool {
  if self.transmission <= 0.0 {
    return false
  }
  match self.transmission_map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的厚度贴图标记。`transmission` 大于 `0` 且有 `thickness_map` 时为 `true`。强度不大于 `0` 或没有贴图时为 `false`。
/// r186: `thicknessMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L165
/// r186: `thicknessMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L260
pub fn Material::program_thickness_map(self : Material) -> Bool {
  if self.transmission <= 0.0 {
    return false
  }
  match self.thickness_map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的渐变贴图标记。材质有 `gradient_map` 时为 `true`，没有时为 `false`。
/// r186: `gradientMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L167
/// r186: `gradientMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L262
pub fn Material::program_gradient_map(self : Material) -> Bool {
  match self.gradient_map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的不透明标记。不透明、普通混合、并且没有 alpha to coverage 时为 `true`。
/// r186: `opaque` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L264
pub fn Material::program_opaque(self : Material) -> Bool {
  !self.transparent &&
  self.blending is @constants.Normal &&
  !self.alpha_to_coverage
}

///|
/// 程序参数里的透明贴图标记。材质有 `alpha_map` 时为 `true`，没有时为 `false`。
/// r186: `alphaMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L169
/// r186: `alphaMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L266
pub fn Material::program_alpha_map(self : Material) -> Bool {
  match self.alpha_map {
    None => false
    Some(_) => true
  }
}

///|
/// 程序参数里的 alpha 测试标记。`alpha_test` 大于 `0` 时为 `true`。`0` 和负数时为 `false`。
/// r186: `alphaTest` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L171
/// r186: `alphaTest` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L267
pub fn Material::program_alpha_test(self : Material) -> Bool {
  self.alpha_test > 0.0
}

///|
/// 程序参数里的 alpha 散列标记。`alpha_hash` 打开时为 `true`，关闭时为 `false`。
/// r186: `alphaHash` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L173
/// r186: `alphaHash` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L268
pub fn Material::program_alpha_hash(self : Material) -> Bool {
  self.alpha_hash
}

///|
/// 程序参数里的环境贴图合成方式。直接返回 `combine`。默认是相乘。
/// r186: `combine` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L270
pub fn Material::program_combine(self : Material) -> @constants.Combine {
  self.combine
}

///|
/// 程序参数里的颜色贴图 UV 通道。没有 `map` 时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `mapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L274
pub fn Material::program_map_uv(self : Material) -> String {
  match self.map {
    None => "false"
    Some(texture) => uv_channel_name(texture.channel)
  }
}

///|
/// 程序参数里的环境光遮蔽贴图 UV 通道。没有 `ao_map` 时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `aoMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L275
pub fn Material::program_ao_map_uv(self : Material) -> String {
  match self.ao_map {
    None => "false"
    Some(texture) => uv_channel_name(texture.channel)
  }
}

///|
/// 程序参数里的光照贴图 UV 通道。没有 `light_map` 时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `lightMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L276
pub fn Material::program_light_map_uv(self : Material) -> String {
  match self.light_map {
    None => "false"
    Some(texture) => uv_channel_name(texture.channel)
  }
}

///|
/// 程序参数里的凹凸贴图 UV 通道。没有 `bump_map` 或线框打开时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `bumpMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L277
pub fn Material::program_bump_map_uv(self : Material) -> String {
  match self.bump_map {
    None => "false"
    Some(texture) =>
      if self.wireframe {
        "false"
      } else {
        uv_channel_name(texture.channel)
      }
  }
}

///|
/// 程序参数里的法线贴图 UV 通道。没有 `normal_map` 时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `normalMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L278
pub fn Material::program_normal_map_uv(self : Material) -> String {
  match self.normal_map {
    None => "false"
    Some(texture) => uv_channel_name(texture.channel)
  }
}

///|
/// 程序参数里的位移贴图 UV 通道。没有 `displacement_map` 时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `displacementMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L279
pub fn Material::program_displacement_map_uv(self : Material) -> String {
  match self.displacement_map {
    None => "false"
    Some(texture) => uv_channel_name(texture.channel)
  }
}

///|
/// 程序参数里的自发光贴图 UV 通道。没有 `emissive_map` 时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `emissiveMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L280
pub fn Material::program_emissive_map_uv(self : Material) -> String {
  match self.emissive_map {
    None => "false"
    Some(texture) => uv_channel_name(texture.channel)
  }
}

///|
/// 程序参数里的金属度贴图 UV 通道。没有 `metalness_map` 时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `metalnessMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L282
pub fn Material::program_metalness_map_uv(self : Material) -> String {
  match self.metalness_map {
    None => "false"
    Some(texture) => uv_channel_name(texture.channel)
  }
}

///|
/// 程序参数里的粗糙度贴图 UV 通道。没有 `roughness_map` 时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `roughnessMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L283
pub fn Material::program_roughness_map_uv(self : Material) -> String {
  match self.roughness_map {
    None => "false"
    Some(texture) => uv_channel_name(texture.channel)
  }
}

///|
/// 程序参数里的各向异性贴图 UV 通道。`anisotropy` 不大于 `0` 或没有 `anisotropy_map` 时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `anisotropyMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L285
pub fn Material::program_anisotropy_map_uv(self : Material) -> String {
  if self.anisotropy <= 0.0 {
    return "false"
  }
  match self.anisotropy_map {
    None => "false"
    Some(texture) => uv_channel_name(texture.channel)
  }
}

///|
/// 程序参数里的清漆贴图 UV 通道。`clearcoat` 不大于 `0` 或没有 `clearcoat_map` 时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `clearcoatMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L287
pub fn Material::program_clearcoat_map_uv(self : Material) -> String {
  if self.clearcoat <= 0.0 {
    return "false"
  }
  match self.clearcoat_map {
    None => "false"
    Some(texture) => uv_channel_name(texture.channel)
  }
}

///|
/// 程序参数里的清漆法线贴图 UV 通道。`clearcoat` 不大于 `0` 或没有 `clearcoat_normal_map` 时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `clearcoatNormalMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L288
pub fn Material::program_clearcoat_normal_map_uv(self : Material) -> String {
  if self.clearcoat <= 0.0 {
    return "false"
  }
  match self.clearcoat_normal_map {
    None => "false"
    Some(texture) => uv_channel_name(texture.channel)
  }
}

///|
/// 程序参数里的清漆粗糙度贴图 UV 通道。`clearcoat` 不大于 `0` 或没有 `clearcoat_roughness_map` 时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `clearcoatRoughnessMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L289
pub fn Material::program_clearcoat_roughness_map_uv(self : Material) -> String {
  if self.clearcoat <= 0.0 {
    return "false"
  }
  match self.clearcoat_roughness_map {
    None => "false"
    Some(texture) => uv_channel_name(texture.channel)
  }
}

///|
/// 程序参数里的彩虹色贴图 UV 通道。`iridescence` 不大于 `0` 或没有 `iridescence_map` 时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `iridescenceMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L291
pub fn Material::program_iridescence_map_uv(self : Material) -> String {
  if self.iridescence <= 0.0 {
    return "false"
  }
  match self.iridescence_map {
    None => "false"
    Some(texture) => uv_channel_name(texture.channel)
  }
}

///|
/// 程序参数里的彩虹色厚度贴图 UV 通道。`iridescence` 不大于 `0` 或没有 `iridescence_thickness_map` 时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `iridescenceThicknessMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L292
pub fn Material::program_iridescence_thickness_map_uv(self : Material) -> String {
  if self.iridescence <= 0.0 {
    return "false"
  }
  match self.iridescence_thickness_map {
    None => "false"
    Some(texture) => uv_channel_name(texture.channel)
  }
}

///|
/// 程序参数里的光泽颜色贴图 UV 通道。`sheen` 不大于 `0` 或没有 `sheen_color_map` 时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `sheenColorMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L294
pub fn Material::program_sheen_color_map_uv(self : Material) -> String {
  if self.sheen <= 0.0 {
    return "false"
  }
  match self.sheen_color_map {
    None => "false"
    Some(texture) => uv_channel_name(texture.channel)
  }
}

///|
/// 程序参数里的光泽粗糙度贴图 UV 通道。`sheen` 不大于 `0` 或没有 `sheen_roughness_map` 时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `sheenRoughnessMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L295
pub fn Material::program_sheen_roughness_map_uv(self : Material) -> String {
  if self.sheen <= 0.0 {
    return "false"
  }
  match self.sheen_roughness_map {
    None => "false"
    Some(texture) => uv_channel_name(texture.channel)
  }
}

///|
/// 程序参数里的高光贴图 UV 通道。没有 `specular_map` 时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `specularMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L297
pub fn Material::program_specular_map_uv(self : Material) -> String {
  match self.specular_map {
    None => "false"
    Some(texture) => uv_channel_name(texture.channel)
  }
}

///|
/// 程序参数里的高光颜色贴图 UV 通道。没有 `specular_color_map` 时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `specularColorMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L298
pub fn Material::program_specular_color_map_uv(self : Material) -> String {
  match self.specular_color_map {
    None => "false"
    Some(texture) => uv_channel_name(texture.channel)
  }
}

///|
/// 程序参数里的高光强度贴图 UV 通道。没有 `specular_intensity_map` 时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `specularIntensityMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L299
pub fn Material::program_specular_intensity_map_uv(self : Material) -> String {
  match self.specular_intensity_map {
    None => "false"
    Some(texture) => uv_channel_name(texture.channel)
  }
}

///|
/// 程序参数里的透射贴图 UV 通道。`transmission` 不大于 `0` 或没有 `transmission_map` 时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `transmissionMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L301
pub fn Material::program_transmission_map_uv(self : Material) -> String {
  if self.transmission <= 0.0 {
    return "false"
  }
  match self.transmission_map {
    None => "false"
    Some(texture) => uv_channel_name(texture.channel)
  }
}

///|
/// 程序参数里的厚度贴图 UV 通道。`transmission` 不大于 `0` 或没有 `thickness_map` 时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `thicknessMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L302
pub fn Material::program_thickness_map_uv(self : Material) -> String {
  if self.transmission <= 0.0 {
    return "false"
  }
  match self.thickness_map {
    None => "false"
    Some(texture) => uv_channel_name(texture.channel)
  }
}

///|
/// 程序参数里的透明贴图 UV 通道。没有 `alpha_map` 时是 `false`。通道 `0` 是 `uv`，其它通道是 `uv` 加这个数。
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `alphaMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L304
pub fn Material::program_alpha_map_uv(self : Material) -> String {
  match self.alpha_map {
    None => "false"
    Some(texture) => uv_channel_name(texture.channel)
  }
}

///|
/// 程序参数里的顶点切线标记。几何体没有切线时为 `false`。有切线时，还要有法线贴图，或 `anisotropy` 大于 `0`。
/// r186: `vertexTangents` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L308
pub fn Material::program_vertex_tangents(
  self : Material,
  has_tangent~ : Bool = false,
) -> Bool {
  if !has_tangent {
    return false
  }
  match self.normal_map {
    Some(_) => true
    None => self.anisotropy > 0.0
  }
}

///|
/// 程序参数里的顶点法线标记。几何体有法线属性时为 `true`，没有时为 `false`。材质字段不参与。
/// r186: `vertexNormals` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L309
pub fn Material::program_vertex_normals(
  self : Material,
  has_normal~ : Bool = false,
) -> Bool {
  ignore(self)
  has_normal
}

///|
/// 程序参数里的顶点色标记。`vertex_colors` 打开时为 `true`，关闭时为 `false`。
/// r186: `vertexColors` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L310
pub fn Material::program_vertex_colors(self : Material) -> Bool {
  self.vertex_colors
}

///|
/// 程序参数里的顶点透明标记。`vertex_colors` 打开，并且几何体颜色属性的分量数是 `4` 时为 `true`。缺一项就是 `false`。
/// r186: `vertexAlphas` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L311
pub fn Material::program_vertex_alphas(
  self : Material,
  has_vertex_alpha~ : Bool = false,
) -> Bool {
  self.vertex_colors && has_vertex_alpha
}

///|
/// 程序参数里的点 UV 标记。调用方说明对象是点并且几何体有 `uv`。还要有 `map` 或 `alpha_map` 才为 `true`。缺一项就是 `false`。
/// r186: `pointsUvs` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L313
pub fn Material::program_points_uvs(
  self : Material,
  has_points_uv~ : Bool = false,
) -> Bool {
  if !has_points_uv {
    return false
  }
  match (self.map, self.alpha_map) {
    (None, None) => false
    _ => true
  }
}

///|
/// 程序参数里的场景雾标记。场景有雾时为 `true`，没有时为 `false`。材质自己的 `fog` 不参与。
/// r186: `fog` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L315
pub fn Material::program_fog(self : Material, has_fog~ : Bool = false) -> Bool {
  ignore(self)
  has_fog
}

///|
/// 程序参数里的材质雾开关。`fog` 打开时为 `true`，关闭时为 `false`。场景有没有雾不参与。
/// r186: `useFog` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L316
pub fn Material::program_use_fog(self : Material) -> Bool {
  self.fog
}

///|
/// 程序参数里的指数雾标记。场景有雾，并且这团雾是 `FogExp2` 时为 `true`。缺一项就是 `false`。材质自己的 `fog` 不参与。
/// r186: `fogExp2` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L317
pub fn Material::program_fog_exp2(
  self : Material,
  has_fog~ : Bool = false,
  fog_exp2~ : Bool = false,
) -> Bool {
  ignore(self)
  has_fog && fog_exp2
}

///|
/// 程序参数里的平直着色标记。线框打开时为 `false`。`flat_shading` 打开时为 `true`。否则要几何体没有法线、没有法线贴图，并且材质是 Lambert、Phong、Standard 或 Physical。
/// r186: `flatShading` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L319
pub fn Material::program_flat_shading(
  self : Material,
  has_normal~ : Bool = false,
) -> Bool {
  if self.wireframe {
    return false
  }
  if self.flat_shading {
    return true
  }
  if has_normal {
    return false
  }
  match self.normal_map {
    Some(_) => false
    None => flat_shading_derived_kind(self.kind)
  }
}

///|
fn flat_shading_derived_kind(kind : MaterialKind) -> Bool {
  match kind {
    Lambert => true
    Phong => true
    Standard => true
    Physical => true
    _ => false
  }
}

///|
/// 程序参数里的尺寸衰减标记。网格材质没有这个字段，固定是 `false`。
/// r186: `sizeAttenuation` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L326
pub fn Material::program_size_attenuation(self : Material) -> Bool {
  ignore(self)
  false
}

///|
/// 程序参数里的对数深度标记。渲染器打开对数深度缓冲时为 `true`，关闭时为 `false`。材质字段不参与。
/// r186: `logarithmicDepthBuffer` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L327
pub fn Material::program_logarithmic_depth_buffer(
  self : Material,
  logarithmic_depth_buffer~ : Bool = false,
) -> Bool {
  ignore(self)
  logarithmic_depth_buffer
}

///|
/// 程序参数里的反向深度标记。渲染器打开反向深度缓冲时为 `true`，关闭时为 `false`。材质字段不参与。
/// r186: `reversedDepthBuffer` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L328
pub fn Material::program_reversed_depth_buffer(
  self : Material,
  reversed_depth_buffer~ : Bool = false,
) -> Bool {
  ignore(self)
  reversed_depth_buffer
}

///|
/// 程序参数里的蒙皮标记。对象是骨骼网格时为 `true`，否则为 `false`。材质字段不参与。
/// r186: `skinning` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L330
pub fn Material::program_skinning(
  self : Material,
  has_skinning~ : Bool = false,
) -> Bool {
  ignore(self)
  has_skinning
}

///|
/// 程序参数里的位置属性标记。几何体有 `position` 时为 `true`，没有时为 `false`。材质字段不参与。
/// r186: `hasPositionAttribute` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L332
pub fn Material::program_has_position_attribute(
  self : Material,
  has_position~ : Bool = false,
) -> Bool {
  ignore(self)
  has_position
}

///|
/// 程序参数里的位置变形目标标记。几何体有位置变形属性时为 `true`，没有时为 `false`。材质字段不参与。
/// r186: `morphTargets` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L334
pub fn Material::program_morph_targets(
  self : Material,
  has_morph_targets~ : Bool = false,
) -> Bool {
  ignore(self)
  has_morph_targets
}

///|
/// 程序参数里的法线变形目标标记。几何体有法线变形属性时为 `true`，没有时为 `false`。材质字段不参与。
/// r186: `morphNormals` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L335
pub fn Material::program_morph_normals(
  self : Material,
  has_morph_normals~ : Bool = false,
) -> Bool {
  ignore(self)
  has_morph_normals
}

///|
/// 程序参数里的颜色变形目标标记。几何体有颜色变形属性时为 `true`，没有时为 `false`。材质字段不参与。
/// r186: `morphColors` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L336
pub fn Material::program_morph_colors(
  self : Material,
  has_morph_colors~ : Bool = false,
) -> Bool {
  ignore(self)
  has_morph_colors
}

///|
/// 程序参数里的变形目标数量。位置变形存在时用它的个数，空数组也算存在。没有位置再用做法线，再没有用颜色。都没有时是 `0`。
/// r186: `morphTargetsCount` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L85
/// r186: `morphTargetsCount` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L337
pub fn Material::program_morph_targets_count(
  self : Material,
  position_count~ : Int? = None,
  normal_count~ : Int? = None,
  color_count~ : Int? = None,
) -> Int {
  ignore(self)
  match position_count {
    Some(count) => count
    None =>
      match normal_count {
        Some(count) => count
        None =>
          match color_count {
            Some(count) => count
            None => 0
          }
      }
  }
}

///|
/// 程序参数里的变形纹理步长。没有变形属性时是 `0`。有位置是 `1`，有法线改成 `2`，有颜色改成 `3`。后面的属性盖过前面的。空数组也算有这份属性。
/// r186: `morphTextureStride` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L88
/// r186: `morphTextureStride` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L338
pub fn Material::program_morph_texture_stride(
  self : Material,
  has_position_morph~ : Bool = false,
  has_normal_morph~ : Bool = false,
  has_color_morph~ : Bool = false,
) -> Int {
  ignore(self)
  if has_color_morph {
    3
  } else if has_normal_morph {
    2
  } else if has_position_morph {
    1
  } else {
    0
  }
}

///|
/// 程序参数里的太阳光数量。调用方给出场景里太阳光的个数，没有时是 `0`。材质字段不参与。
/// r186: `numSunLights` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L340
pub fn Material::program_num_sun_lights(
  self : Material,
  num_sun_lights~ : Int = 0,
) -> Int {
  ignore(self)
  num_sun_lights
}

///|
/// 程序参数里的平行光数量。调用方给出场景里平行光的个数，没有时是 `0`。材质字段不参与。
/// r186: `numDirLights` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L341
pub fn Material::program_num_dir_lights(
  self : Material,
  num_dir_lights~ : Int = 0,
) -> Int {
  ignore(self)
  num_dir_lights
}

///|
/// 程序参数里的点光源数量。调用方给出场景里点光源的个数，没有时是 `0`。材质字段不参与。
/// r186: `numPointLights` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L342
pub fn Material::program_num_point_lights(
  self : Material,
  num_point_lights~ : Int = 0,
) -> Int {
  ignore(self)
  num_point_lights
}

///|
/// 程序参数里的聚光灯数量。调用方给出场景里聚光灯的个数，没有时是 `0`。材质字段不参与。
/// r186: `numSpotLights` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L343
pub fn Material::program_num_spot_lights(
  self : Material,
  num_spot_lights~ : Int = 0,
) -> Int {
  ignore(self)
  num_spot_lights
}

///|
/// 程序参数里的聚光灯贴图数量。调用方给出带贴图的聚光灯个数，没有时是 `0`。材质字段不参与。
/// r186: `numSpotLightMaps` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L344
pub fn Material::program_num_spot_light_maps(
  self : Material,
  num_spot_light_maps~ : Int = 0,
) -> Int {
  ignore(self)
  num_spot_light_maps
}

///|
/// 程序参数里的矩形面光源数量。调用方给出场景里矩形面光源的个数，没有时是 `0`。材质字段不参与。
/// r186: `numRectAreaLights` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L345
pub fn Material::program_num_rect_area_lights(
  self : Material,
  num_rect_area_lights~ : Int = 0,
) -> Int {
  ignore(self)
  num_rect_area_lights
}

///|
/// 程序参数里的半球光数量。调用方给出场景里半球光的个数，没有时是 `0`。材质字段不参与。
/// r186: `numHemiLights` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L346
pub fn Material::program_num_hemi_lights(
  self : Material,
  num_hemi_lights~ : Int = 0,
) -> Int {
  ignore(self)
  num_hemi_lights
}

///|
/// 程序参数里的太阳光阴影数量。调用方给出投射阴影的太阳光个数，没有时是 `0`。材质字段不参与。
/// r186: `numSunLightShadows` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L348
pub fn Material::program_num_sun_light_shadows(
  self : Material,
  num_sun_light_shadows~ : Int = 0,
) -> Int {
  ignore(self)
  num_sun_light_shadows
}

///|
/// 程序参数里的平行光阴影数量。调用方给出投射阴影的平行光个数，没有时是 `0`。材质字段不参与。
/// r186: `numDirLightShadows` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L349
pub fn Material::program_num_dir_light_shadows(
  self : Material,
  num_dir_light_shadows~ : Int = 0,
) -> Int {
  ignore(self)
  num_dir_light_shadows
}

///|
/// 程序参数里的点光源阴影数量。调用方给出投射阴影的点光源个数，没有时是 `0`。材质字段不参与。
/// r186: `numPointLightShadows` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L350
pub fn Material::program_num_point_light_shadows(
  self : Material,
  num_point_light_shadows~ : Int = 0,
) -> Int {
  ignore(self)
  num_point_light_shadows
}

///|
/// 程序参数里的聚光灯阴影数量。调用方给出投射阴影的聚光灯个数，没有时是 `0`。材质字段不参与。
/// r186: `numSpotLightShadows` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L351
pub fn Material::program_num_spot_light_shadows(
  self : Material,
  num_spot_light_shadows~ : Int = 0,
) -> Int {
  ignore(self)
  num_spot_light_shadows
}

///|
/// 程序参数里带贴图的聚光灯阴影数量。调用方给出这个个数，没有时是 `0`。材质字段不参与。
/// r186: `numSpotLightShadowsWithMaps` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L352
pub fn Material::program_num_spot_light_shadows_with_maps(
  self : Material,
  num_spot_light_shadows_with_maps~ : Int = 0,
) -> Int {
  ignore(self)
  num_spot_light_shadows_with_maps
}

///|
/// 程序参数里的光照探针数量。调用方给出这个个数，没有时是 `0`。材质字段不参与。
/// r186: `numLightProbes` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L354
pub fn Material::program_num_light_probes(
  self : Material,
  num_light_probes~ : Int = 0,
) -> Int {
  ignore(self)
  num_light_probes
}

///|
/// 程序参数里的光照探针网格数量。调用方给出这个个数，没有时是 `0`。材质字段不参与。
/// r186: `numLightProbeGrids` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L356
pub fn Material::program_num_light_probe_grids(
  self : Material,
  num_light_probe_grids~ : Int = 0,
) -> Int {
  ignore(self)
  num_light_probe_grids
}

///|
/// 程序参数里的裁剪平面数量。调用方给出 `clipping.numPlanes`，没有时是 `0`。材质字段不参与。
/// r186: `numClippingPlanes` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L358
pub fn Material::program_num_clipping_planes(
  self : Material,
  num_clipping_planes~ : Int = 0,
) -> Int {
  ignore(self)
  num_clipping_planes
}

///|
/// 程序参数里的裁剪交集数量。调用方给出 `clipping.numIntersection`，没有时是 `0`。材质字段不参与。
/// r186: `numClipIntersection` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L359
pub fn Material::program_num_clip_intersection(
  self : Material,
  num_clip_intersection~ : Int = 0,
) -> Int {
  ignore(self)
  num_clip_intersection
}

///|
/// 程序参数里的抖动标记。`dithering` 打开时为 `true`，关闭时为 `false`。
/// r186: `dithering` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L361
pub fn Material::program_dithering(self : Material) -> Bool {
  self.dithering
}

///|
/// 程序参数里的阴影贴图标记。渲染器打开阴影贴图，并且至少有一盏灯投射阴影时为 `true`。缺一项就是 `false`。材质字段不参与。
/// r186: `shadowMapEnabled` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L363
pub fn Material::program_shadow_map_enabled(
  self : Material,
  shadow_map_enabled~ : Bool = false,
  has_shadows~ : Bool = false,
) -> Bool {
  ignore(self)
  shadow_map_enabled && has_shadows
}

///|
/// 程序参数里的阴影贴图类型。调用方给出渲染器的 `shadowMap.type`。没有额外说明时是 `0`。材质字段不参与。
/// r186: `shadowMapType` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L364
pub fn Material::program_shadow_map_type(
  self : Material,
  shadow_map_type~ : Int = 0,
) -> Int {
  ignore(self)
  shadow_map_type
}

///|
/// 程序参数里的色调映射。材质 `tone_mapped` 关闭，或当前正在画到渲染目标时，返回 `No`。否则返回调用方给出的渲染器色调映射。没有额外说明时是 `No`。
/// r186: `toneMapping` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L177
/// r186: `toneMapping` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L366
pub fn Material::program_tone_mapping(
  self : Material,
  tone_mapping~ : @constants.ToneMapping = @constants.No,
  has_render_target~ : Bool = false,
) -> @constants.ToneMapping {
  if self.tone_mapped && !has_render_target {
    tone_mapping
  } else {
    @constants.No
  }
}

///|
/// 程序参数里的视频贴图解码。有颜色贴图，并且调用方标明它是视频贴图、传输函数是 sRGB 时为 `true`。缺一项就是 `false`。
/// r186: `decodeVideoTexture` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L368
pub fn Material::program_decode_video_texture(
  self : Material,
  video_texture~ : Bool = false,
  srgb_transfer~ : Bool = false,
) -> Bool {
  match self.map {
    None => false
    Some(_) => video_texture && srgb_transfer
  }
}

///|
/// 程序参数里的自发光视频贴图解码。有自发光贴图，并且调用方标明它是视频贴图、传输函数是 sRGB 时为 `true`。缺一项就是 `false`。颜色贴图不算。
/// r186: `decodeVideoTextureEmissive` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L369
pub fn Material::program_decode_video_texture_emissive(
  self : Material,
  video_texture~ : Bool = false,
  srgb_transfer~ : Bool = false,
) -> Bool {
  match self.emissive_map {
    None => false
    Some(_) => video_texture && srgb_transfer
  }
}

///|
/// 程序参数里的预乘透明度。`premultiplied_alpha` 打开时为 `true`，关闭时为 `false`。
/// r186: `premultipliedAlpha` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L371
pub fn Material::program_premultiplied_alpha(self : Material) -> Bool {
  self.premultiplied_alpha
}

///|
/// 程序参数里的双面标记。`side` 为 `Double` 时为 `true`。正面和背面都是 `false`。
/// r186: `doubleSided` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L373
pub fn Material::program_double_sided(self : Material) -> Bool {
  match self.side {
    Double => true
    _ => false
  }
}

///|
/// 程序参数里的背面标记。`side` 为 `Back` 时为 `true`。正面和双面都是 `false`。
/// r186: `flipSided` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L374
pub fn Material::program_flip_sided(self : Material) -> Bool {
  match self.side {
    Back => true
    _ => false
  }
}

///|
/// 程序参数里的深度打包开关。`depth_packing` 的整数大于等于 `0` 时为 `true`。现有四种打包都满足。
/// r186: `useDepthPacking` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L376
pub fn Material::program_use_depth_packing(self : Material) -> Bool {
  self.depth_packing.to_int() >= 0
}

///|
/// 程序参数里的深度打包整数。返回 `depth_packing` 的数值。基础打包是 `3200`。
/// r186: `depthPacking` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L377
pub fn Material::program_depth_packing(self : Material) -> Int {
  self.depth_packing.to_int()
}

///|
/// 程序参数里的 0 号属性名。没有设置时是 `None`。设了名字就返回这个字符串。
/// r186: `index0AttributeName` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L379
pub fn Material::program_index0_attribute_name(self : Material) -> String? {
  self.index0_attribute_name
}

///|
/// 程序参数里的裁剪剔除距离扩展。材质打开 `clip_cull_distance`，并且调用方标明这个扩展可用时为 `true`。缺一项就是 `false`。
/// r186: `extensionClipCullDistance` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L381
pub fn Material::program_extension_clip_cull_distance(
  self : Material,
  has_extension~ : Bool = false,
) -> Bool {
  self.extensions.clip_cull_distance && has_extension
}

///|
/// 程序参数里的多重绘制扩展。调用方标明这个扩展可用，并且材质打开 `multi_draw` 或对象是合批网格时为 `true`。缺了扩展就是 `false`。
/// r186: `extensionMultiDraw` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L382
pub fn Material::program_extension_multi_draw(
  self : Material,
  has_extension~ : Bool = false,
  is_batched_mesh~ : Bool = false,
) -> Bool {
  (self.extensions.multi_draw || is_batched_mesh) && has_extension
}

///|
/// 程序参数里的并行着色器编译扩展。调用方标明渲染器有这个扩展时为 `true`。材质字段不参与。
/// r186: `rendererExtensionParallelShaderCompile` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L384
pub fn Material::program_renderer_extension_parallel_shader_compile(
  self : Material,
  has_extension~ : Bool = false,
) -> Bool {
  ignore(self)
  has_extension
}

///|
/// 程序参数里的自定义程序缓存键。没有额外说明时是空字符串。这里还没有 `onBeforeCompile`，所以不返回函数源码。
/// r186: `customProgramCacheKey` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L544
/// r186: `customProgramCacheKey` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L386
pub fn Material::program_custom_program_cache_key(
  self : Material,
  custom_program_cache_key~ : String = "",
) -> String {
  ignore(self)
  custom_program_cache_key
}

///|
/// 程序参数里的 1 号 UV 通道。有贴图真正读到通道 `1` 时为 `true`。通道 `0` 和 `2` 不算。没有贴图时是 `false`。
/// r186: `vertexUv1s` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L392
pub fn Material::program_vertex_uv1s(self : Material) -> Bool {
  self.uses_uv_channel(1)
}

///|
/// 程序参数里的 2 号 UV 通道。有贴图真正读到通道 `2` 时为 `true`。通道 `0`、`1` 和 `3` 不算。没有贴图时是 `false`。
/// r186: `vertexUv2s` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L393
pub fn Material::program_vertex_uv2s(self : Material) -> Bool {
  self.uses_uv_channel(2)
}

///|
/// 程序参数里的 3 号 UV 通道。有贴图真正读到通道 `3` 时为 `true`。通道 `0`、`1`、`2` 和 `4` 不算。没有贴图时是 `false`。
/// r186: `vertexUv3s` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L394
pub fn Material::program_vertex_uv3s(self : Material) -> Bool {
  self.uses_uv_channel(3)
}

///|
/// 程序参数里的内置着色器标识。Basic 是 `basic`，Lambert 是 `lambert`，Phong 是 `phong`，Toon 是 `toon`，Standard 和 Physical 都是 `physical`，Matcap 是 `matcap`，Normal 是 `normal`，Depth 是 `depth`，Distance 是 `distance`，Shadow 是 `shadow`。Shader 和 Raw 没有这个标识。改名字不会改它。
/// r186: `shaderIDs` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L28
/// r186: `shaderID` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L66
/// r186: `shaderID` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L191
pub fn Material::program_shader_id(self : Material) -> String? {
  builtin_shader_id(self.type_name)
}

///|
fn scene_environment_material(kind : MaterialKind) -> Bool {
  match kind {
    Lambert => true
    Phong => true
    Toon => true
    Standard => true
    Physical => true
    _ => false
  }
}

