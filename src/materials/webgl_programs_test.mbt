///|
test "Material shader getProgramCacheKey joins parameters" {
  assert_eq(
    @materials.program_cache_key(),
    ",,highp,,false,,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,0,false,false,0,,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,,",
  )
  assert_eq(
    @materials.program_cache_key(shader_id=Some("lambert"), custom_program_cache_key="custom"),
    "lambert,highp,,false,,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,0,false,false,0,,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,,custom",
  )
  assert_eq(
    @materials.program_cache_key(
      shader_id=Some("basic"),
      is_raw=true,
      defines=[("FOO", "1"), ("BAR", "2")],
      custom_program_cache_key="k",
    ),
    "basic,FOO,1,BAR,2,k",
  )
  assert_eq(
    @materials.program_cache_key(shader_id=Some("phong"), defines=[("A", "1"), ("B", "2")])[0:15].to_owned(),
    "phong,A,1,B,2,h",
  )
  assert_eq(
    @materials.program_cache_key(num_dir_lights="3").contains("0,,0,3,0"),
    true,
  )
  assert_eq(
    @materials.program_cache_key(instancing=true, retroreflection=true).contains(",16777217,0,,"),
    true,
  )
  assert_eq(
    @materials.program_cache_key(is_opaque=true, light_probe_grids=true).contains(",0,4325376,,"),
    true,
  )
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader acquireProgram reuses a cache key" {
  let cache = @materials.ProgramCache::new()
  assert_eq(cache.programs.length(), 0)
  let first = cache.acquire("a")
  assert_eq(first.cache_key, "a")
  assert_eq(first.used_times.val, 1)
  let again = cache.acquire("a")
  assert_eq(again.used_times.val, 2)
  assert_eq(first.used_times.val, 2)
  assert_eq(cache.programs.length(), 1)
  let second = cache.acquire("b")
  assert_eq(second.cache_key, "b")
  assert_eq(second.used_times.val, 1)
  assert_eq(cache.programs.length(), 2)
  assert_eq(cache.programs[0].cache_key, "a")
  assert_eq(cache.programs[1].cache_key, "b")
  assert_eq(first.used_times.val, 2)
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader releaseShaderCache drops unused stages" {
  let cache = @materials.ShaderCache::new()
  let shader = @materials.Material::shader()
  let raw = @materials.Material::raw()
  cache.update(shader.id, "vert", "frag")
  let vert = match cache.shader_cache.get("vert") {
    Some(stage) => stage
    None => abort("vertex stage missing")
  }
  let frag = match cache.shader_cache.get("frag") {
    Some(stage) => stage
    None => abort("fragment stage missing")
  }
  assert_eq(vert.used_times.val, 1)
  assert_eq(frag.used_times.val, 1)
  assert_eq(frag.id, vert.id + 1)
  cache.update(shader.id, "vert", "frag")
  assert_eq(vert.used_times.val, 1)
  cache.update(raw.id, "vert", "other")
  assert_eq(vert.used_times.val, 2)
  let other = match cache.shader_cache.get("other") {
    Some(stage) => stage
    None => abort("other stage missing")
  }
  assert_eq(other.used_times.val, 1)
  assert_eq(other.id == vert.id, false)
  cache.release_shader_cache(shader.id)
  assert_eq(vert.used_times.val, 1)
  match cache.shader_cache.get("frag") {
    None => ()
    Some(_) => abort("unused fragment stage stayed")
  }
  match cache.material_cache.get(shader.id) {
    None => ()
    Some(_) => abort("released material stayed")
  }
  cache.release_shader_cache(raw.id)
  match cache.shader_cache.get("vert") {
    None => ()
    Some(_) => abort("shared vertex stage stayed")
  }
  match cache.shader_cache.get("other") {
    None => ()
    Some(_) => abort("other stage stayed")
  }
  cache.update(shader.id, "same", "same")
  let same = match cache.shader_cache.get("same") {
    Some(stage) => stage
    None => abort("same stage missing")
  }
  assert_eq(same.used_times.val, 1)
  cache.release_shader_cache(shader.id)
  match cache.shader_cache.get("same") {
    None => ()
    Some(_) => abort("identical stage stayed")
  }
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader customProgramCacheKey reads the caller key" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_custom_program_cache_key(), "")
  assert_eq(@materials.Material::raw().program_custom_program_cache_key(), "")
  assert_eq(@materials.Material::basic().program_custom_program_cache_key(), "")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.program_custom_program_cache_key(custom_program_cache_key="custom"),
    "custom",
  )
  assert_eq(shader.program_custom_program_cache_key(), "")
  assert_eq(
    shader.program_renderer_extension_parallel_shader_compile(has_extension=true),
    true,
  )
  assert_eq(shader.program_custom_program_cache_key(), "")
}

///|
test "Material shader getUniforms clones builtin tables" {
  let library : Map[String, Map[String, Double]] = Map([])
  let names = [
    ("MeshDepthMaterial", "depth"),
    ("MeshDistanceMaterial", "distance"),
    ("MeshNormalMaterial", "normal"),
    ("MeshBasicMaterial", "basic"),
    ("MeshLambertMaterial", "lambert"),
    ("MeshPhongMaterial", "phong"),
    ("MeshToonMaterial", "toon"),
    ("MeshStandardMaterial", "physical"),
    ("MeshPhysicalMaterial", "physical"),
    ("MeshMatcapMaterial", "matcap"),
    ("LineBasicMaterial", "basic"),
    ("LineDashedMaterial", "dashed"),
    ("PointsMaterial", "points"),
    ("ShadowMaterial", "shadow"),
    ("SpriteMaterial", "sprite"),
  ]
  let mut index = 0
  while index < names.length() {
    let (type_name, shader_id) = names[index]
    let table : Map[String, Double] = Map([])
    table.set("marker", 1.0)
    library.set(shader_id, table)
    let own : Map[String, Double] = Map([])
    own.set("time", 9.0)
    let got = @materials.program_uniforms(type_name, own, library)
    assert_eq(got.get("marker"), Some(1.0))
    match got.get("time") {
      None => ()
      Some(_) => abort("builtin uniforms kept the material map")
    }
    got.set("marker", 5.0)
    assert_eq(table.get("marker"), Some(1.0))
    index = index + 1
  }
  let shader = @materials.Material::shader()
  shader.uniforms.set("time", 1.0)
  let got = @materials.program_uniforms(shader.type_name, shader.uniforms, library)
  assert_eq(got.get("time"), Some(1.0))
  match got.get("marker") {
    None => ()
    Some(_) => abort("shader uniforms came from the library")
  }
  got.set("time", 4.0)
  assert_eq(shader.uniforms.get("time"), Some(4.0))
  let raw = @materials.Material::raw()
  raw.uniforms.set("scale", 2.0)
  let raw_got = @materials.program_uniforms(raw.type_name, raw.uniforms, library)
  raw_got.set("scale", 6.0)
  assert_eq(raw.uniforms.get("scale"), Some(6.0))
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader releaseProgram drops a zero count" {
  let cache = @materials.ProgramCache::new()
  let first = cache.acquire("a")
  ignore(cache.acquire("a"))
  cache.release(first)
  assert_eq(first.used_times.val, 1)
  assert_eq(cache.programs.length(), 1)
  assert_eq(cache.by_key.get("a") is Some(_), true)
  cache.release(first)
  assert_eq(first.used_times.val, 0)
  assert_eq(cache.programs.length(), 0)
  match cache.by_key.get("a") {
    None => ()
    Some(_) => abort("released program stayed in the key map")
  }
  let again = cache.acquire("a")
  assert_eq(again.used_times.val, 1)
  assert_eq(first.used_times.val, 0)
  let left = cache.acquire("b")
  let middle = cache.acquire("c")
  let right = cache.acquire("d")
  cache.release(middle)
  assert_eq(middle.used_times.val, 0)
  assert_eq(cache.programs.length(), 3)
  assert_eq(cache.programs[0].cache_key, "a")
  assert_eq(cache.programs[1].cache_key, "b")
  assert_eq(cache.programs[2].cache_key, "d")
  assert_eq(left.used_times.val, 1)
  assert_eq(right.used_times.val, 1)
  match cache.by_key.get("c") {
    None => ()
    Some(_) => abort("swapped program stayed in the key map")
  }
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader dispose clears shader caches" {
  let cache = @materials.ShaderCache::new()
  let programs = @materials.ProgramCache::new()
  let shader = @materials.Material::shader()
  ignore(programs.acquire("kept"))
  cache.update(shader.id, "vert", "frag")
  let vert = match cache.shader_cache.get("vert") {
    Some(stage) => stage
    None => abort("vertex stage missing")
  }
  cache.dispose()
  match cache.shader_cache.get("vert") {
    None => ()
    Some(_) => abort("disposed shader code stayed")
  }
  match cache.material_cache.get(shader.id) {
    None => ()
    Some(_) => abort("disposed material stayed")
  }
  assert_eq(vert.used_times.val, 1)
  assert_eq(programs.programs.length(), 1)
  assert_eq(programs.programs[0].cache_key, "kept")
  cache.update(shader.id, "vert", "frag")
  let again = match cache.shader_cache.get("vert") {
    Some(stage) => stage
    None => abort("vertex stage missing after dispose")
  }
  assert_eq(again.used_times.val, 1)
  assert_eq(again.id, vert.id + 2)
  assert_eq(vert.used_times.val, 1)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader getVertexShaderStage reuses source" {
  let cache = @materials.ShaderCache::new()
  let shader = @materials.Material::shader()
  let stage = cache.get_vertex_shader_stage(shader)
  assert_eq(stage.code, shader.vertex_shader)
  assert_eq(stage.used_times.val, 0)
  let again = cache.get_vertex_shader_stage(shader)
  assert_eq(again.id, stage.id)
  assert_eq(again.used_times.val, 0)
  let raw = @materials.Material::raw()
  assert_eq(cache.get_vertex_shader_stage(raw).id, stage.id)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.vertex_shader = "custom"
  let custom = cache.get_vertex_shader_stage(shader)
  assert_eq(custom.code, "custom")
  assert_eq(custom.id == stage.id, false)
  assert_eq(custom.used_times.val, 0)
  let basic = @materials.Material::basic()
  let empty = cache.get_vertex_shader_stage(basic)
  assert_eq(empty.code, "")
  assert_eq(empty.used_times.val, 0)
  assert_eq(empty.id == custom.id, false)
  match cache.material_cache.get(shader.id) {
    None => ()
    Some(_) => abort("vertex stage wrote the material map")
  }
}

///|
test "Material shader getFragmentShaderStage reuses source" {
  let cache = @materials.ShaderCache::new()
  let shader = @materials.Material::shader()
  let stage = cache.get_fragment_shader_stage(shader)
  assert_eq(stage.code, shader.fragment_shader)
  assert_eq(stage.used_times.val, 0)
  let again = cache.get_fragment_shader_stage(shader)
  assert_eq(again.id, stage.id)
  assert_eq(again.used_times.val, 0)
  let raw = @materials.Material::raw()
  assert_eq(cache.get_fragment_shader_stage(raw).id, stage.id)
  let vertex = cache.get_vertex_shader_stage(shader)
  assert_eq(vertex.id == stage.id, false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.fragment_shader = "custom"
  let custom = cache.get_fragment_shader_stage(shader)
  assert_eq(custom.code, "custom")
  assert_eq(custom.id == stage.id, false)
  assert_eq(custom.used_times.val, 0)
  let basic = @materials.Material::basic()
  let empty = cache.get_fragment_shader_stage(basic)
  assert_eq(empty.code, "")
  assert_eq(empty.used_times.val, 0)
  assert_eq(empty.id == custom.id, false)
  match cache.material_cache.get(shader.id) {
    None => ()
    Some(_) => abort("fragment stage wrote the material map")
  }
}

///|
test "Material shader customVertexShaderID skips builtin types" {
  let cache = @materials.ShaderCache::new()
  let shader = @materials.Material::shader()
  let stage = cache.get_vertex_shader_stage(shader)
  match cache.custom_vertex_shader_id(shader) {
    Some(id) => assert_eq(id, stage.id)
    None => abort("shader vertex id missing")
  }
  assert_eq(stage.used_times.val, 0)
  let raw = @materials.Material::raw()
  match cache.custom_vertex_shader_id(raw) {
    Some(id) => assert_eq(id, stage.id)
    None => abort("raw vertex id missing")
  }
  match cache.custom_vertex_shader_id(@materials.Material::basic()) {
    None => ()
    Some(_) => abort("basic gained a custom vertex id")
  }
  match cache.custom_vertex_shader_id(@materials.Material::lambert()) {
    None => ()
    Some(_) => abort("lambert gained a custom vertex id")
  }
  match cache.custom_vertex_shader_id(@materials.Material::physical()) {
    None => ()
    Some(_) => abort("physical gained a custom vertex id")
  }
  match cache.shader_cache.get("") {
    None => ()
    Some(_) => abort("builtin vertex id stored an empty stage")
  }
  match cache.material_cache.get(shader.id) {
    None => ()
    Some(_) => abort("vertex id wrote the material map")
  }
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.vertex_shader = "custom"
  match cache.custom_vertex_shader_id(shader) {
    Some(id) => assert_eq(id == stage.id, false)
    None => abort("replaced vertex id missing")
  }
  assert_eq(stage.used_times.val, 0)
}

///|
test "Material shader customFragmentShaderID skips builtin types" {
  let cache = @materials.ShaderCache::new()
  let shader = @materials.Material::shader()
  let stage = cache.get_fragment_shader_stage(shader)
  let vertex = cache.get_vertex_shader_stage(shader)
  match cache.custom_fragment_shader_id(shader) {
    Some(id) => assert_eq(id, stage.id)
    None => abort("shader fragment id missing")
  }
  assert_eq(stage.id == vertex.id, false)
  assert_eq(stage.used_times.val, 0)
  let raw = @materials.Material::raw()
  match cache.custom_fragment_shader_id(raw) {
    Some(id) => assert_eq(id, stage.id)
    None => abort("raw fragment id missing")
  }
  match cache.custom_fragment_shader_id(@materials.Material::basic()) {
    None => ()
    Some(_) => abort("basic gained a custom fragment id")
  }
  match cache.custom_fragment_shader_id(@materials.Material::lambert()) {
    None => ()
    Some(_) => abort("lambert gained a custom fragment id")
  }
  match cache.custom_fragment_shader_id(@materials.Material::physical()) {
    None => ()
    Some(_) => abort("physical gained a custom fragment id")
  }
  match cache.shader_cache.get("") {
    None => ()
    Some(_) => abort("builtin fragment id stored an empty stage")
  }
  match cache.material_cache.get(shader.id) {
    None => ()
    Some(_) => abort("fragment id wrote the material map")
  }
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.fragment_shader = "custom"
  match cache.custom_fragment_shader_id(shader) {
    Some(id) => assert_eq(id == stage.id, false)
    None => abort("replaced fragment id missing")
  }
  assert_eq(stage.used_times.val, 0)
}

///|
test "Material shader shaderType reads the material type" {
  assert_eq(@materials.Material::basic().shader_type(), "MeshBasicMaterial")
  assert_eq(@materials.Material::lambert().shader_type(), "MeshLambertMaterial")
  assert_eq(@materials.Material::standard().shader_type(), "MeshStandardMaterial")
  assert_eq(@materials.Material::physical().shader_type(), "MeshPhysicalMaterial")
  assert_eq(@materials.Material::toon().shader_type(), "MeshToonMaterial")
  assert_eq(@materials.Material::matcap().shader_type(), "MeshMatcapMaterial")
  assert_eq(@materials.Material::normal().shader_type(), "MeshNormalMaterial")
  assert_eq(@materials.Material::depth().shader_type(), "MeshDepthMaterial")
  assert_eq(@materials.Material::distance().shader_type(), "MeshDistanceMaterial")
  assert_eq(@materials.Material::phong().shader_type(), "MeshPhongMaterial")
  assert_eq(@materials.Material::shadow().shader_type(), "ShadowMaterial")
  let shader = @materials.Material::shader()
  assert_eq(shader.shader_type(), "ShaderMaterial")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.name = "renamed"
  assert_eq(shader.shader_type(), "ShaderMaterial")
  assert_eq(@materials.Material::raw().shader_type(), "RawShaderMaterial")
}

///|
test "Material shader shaderName reads the material name" {
  let shader = @materials.Material::shader()
  assert_eq(shader.shader_name(), "")
  assert_eq(shader.shader_type(), "ShaderMaterial")
  assert_eq(@materials.Material::basic().shader_name(), "")
  assert_eq(@materials.Material::lambert().shader_name(), "")
  assert_eq(@materials.Material::raw().shader_name(), "")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.name = "renamed"
  assert_eq(shader.shader_name(), "renamed")
  assert_eq(shader.shader_type(), "ShaderMaterial")
}

///|
test "Material shader vertexShader keeps builtin source out" {
  let shader = @materials.Material::shader()
  let raw = @materials.Material::raw()
  match shader.program_vertex_shader() {
    Some(code) => assert_eq(code, shader.vertex_shader)
    None => abort("shader vertex source missing")
  }
  match raw.program_vertex_shader() {
    Some(code) => assert_eq(code, shader.vertex_shader)
    None => abort("raw vertex source missing")
  }
  match @materials.Material::basic().program_vertex_shader() {
    None => ()
    Some(_) => abort("basic returned vertex source")
  }
  match @materials.Material::lambert().program_vertex_shader() {
    None => ()
    Some(_) => abort("lambert returned vertex source")
  }
  match @materials.Material::physical().program_vertex_shader() {
    None => ()
    Some(_) => abort("physical returned vertex source")
  }
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.vertex_shader = "custom"
  match shader.program_vertex_shader() {
    Some(code) => assert_eq(code, "custom")
    None => abort("replaced vertex source missing")
  }
}

///|
test "Material shader fragmentShader keeps builtin source out" {
  let shader = @materials.Material::shader()
  let raw = @materials.Material::raw()
  match shader.program_fragment_shader() {
    Some(code) => assert_eq(code, shader.fragment_shader)
    None => abort("shader fragment source missing")
  }
  match raw.program_fragment_shader() {
    Some(code) => assert_eq(code, shader.fragment_shader)
    None => abort("raw fragment source missing")
  }
  match shader.program_vertex_shader() {
    Some(code) => assert_eq(code == shader.fragment_shader, false)
    None => abort("shader vertex source missing")
  }
  match @materials.Material::basic().program_fragment_shader() {
    None => ()
    Some(_) => abort("basic returned fragment source")
  }
  match @materials.Material::lambert().program_fragment_shader() {
    None => ()
    Some(_) => abort("lambert returned fragment source")
  }
  match @materials.Material::physical().program_fragment_shader() {
    None => ()
    Some(_) => abort("physical returned fragment source")
  }
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.fragment_shader = "custom"
  match shader.program_fragment_shader() {
    Some(code) => assert_eq(code, "custom")
    None => abort("replaced fragment source missing")
  }
}

///|
test "Material shader defines returns the material map" {
  let shader = @materials.Material::shader()
  let defines = shader.program_defines()
  match defines.get("FOO") {
    None => ()
    Some(_) => abort("shader defines started with FOO")
  }
  let basic = @materials.Material::basic()
  match basic.program_defines().get("STANDARD") {
    None => ()
    Some(_) => abort("basic defines gained STANDARD")
  }
  match @materials.Material::standard().program_defines().get("STANDARD") {
    Some(value) => assert_eq(value, "")
    None => abort("standard defines missing STANDARD")
  }
  let physical = @materials.Material::physical().program_defines()
  match physical.get("STANDARD") {
    Some(value) => assert_eq(value, "")
    None => abort("physical defines missing STANDARD")
  }
  match physical.get("PHYSICAL") {
    Some(value) => assert_eq(value, "")
    None => abort("physical defines missing PHYSICAL")
  }
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  defines.set("FOO", "1")
  assert_eq(shader.defines.get("FOO"), Some("1"))
}

///|
test "Material shader isRawShaderMaterial is only set on raw" {
  assert_eq(@materials.Material::raw().program_is_raw_shader_material(), true)
  let shader = @materials.Material::shader()
  assert_eq(shader.program_is_raw_shader_material(), false)
  assert_eq(@materials.Material::basic().program_is_raw_shader_material(), false)
  assert_eq(@materials.Material::lambert().program_is_raw_shader_material(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader glslVersion starts empty" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_glsl_version() is None, true)
  assert_eq(@materials.Material::raw().program_glsl_version() is None, true)
  assert_eq(@materials.Material::basic().program_glsl_version() is None, true)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.glsl_version = Some(@materials.GlslVersion::GLSL3)
  assert_eq(
    shader.program_glsl_version() is Some(@materials.GlslVersion::GLSL3),
    true,
  )
  shader.glsl_version = Some(@materials.GlslVersion::GLSL1)
  assert_eq(
    shader.program_glsl_version() is Some(@materials.GlslVersion::GLSL1),
    true,
  )
}

///|
test "Material shader precision uses capabilities unless set" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_precision("highp"), "highp")
  assert_eq(shader.program_precision("mediump"), "mediump")
  assert_eq(@materials.Material::basic().program_precision("lowp"), "lowp")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.precision = Some(@constants.Precision::Mediump)
  assert_eq(shader.program_precision("highp"), "mediump")
  shader.precision = Some(@constants.Precision::Lowp)
  assert_eq(shader.program_precision("highp"), "lowp")
  shader.precision = Some(@constants.Precision::Highp)
  assert_eq(shader.program_precision("lowp"), "highp")
}

///|
test "Material shader getMaxPrecision drops unavailable floats" {
  assert_eq(@materials.max_precision("highp"), "highp")
  assert_eq(@materials.max_precision("highp", vertex_highp=false), "mediump")
  assert_eq(@materials.max_precision("highp", fragment_highp=false), "mediump")
  assert_eq(
    @materials.max_precision("highp", vertex_highp=false, fragment_mediump=false),
    "lowp",
  )
  assert_eq(@materials.max_precision("mediump"), "mediump")
  assert_eq(@materials.max_precision("mediump", vertex_mediump=false), "lowp")
  assert_eq(@materials.max_precision("lowp", vertex_mediump=false), "lowp")
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.precision = Some(@constants.Precision::Highp)
  assert_eq(shader.program_precision("lowp", vertex_highp=false), "mediump")
}

///|
test "Material shader batching follows the batched mesh flag" {
  assert_eq(@materials.program_batching(), false)
  assert_eq(@materials.program_batching(is_batched_mesh=true), true)
  assert_eq(@materials.program_batching(is_batched_mesh=false), false)
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader batchingColor needs a colors texture" {
  assert_eq(@materials.program_batching_color(), false)
  assert_eq(@materials.program_batching_color(is_batched_mesh=true), false)
  assert_eq(@materials.program_batching_color(has_colors_texture=true), false)
  assert_eq(
    @materials.program_batching_color(is_batched_mesh=true, has_colors_texture=true),
    true,
  )
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader instancing follows the instanced mesh flag" {
  assert_eq(@materials.program_instancing(), false)
  assert_eq(@materials.program_instancing(is_instanced_mesh=true), true)
  assert_eq(@materials.program_instancing(is_instanced_mesh=false), false)
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader instancingColor needs instance color" {
  assert_eq(@materials.program_instancing_color(), false)
  assert_eq(@materials.program_instancing_color(is_instanced_mesh=true), false)
  assert_eq(@materials.program_instancing_color(has_instance_color=true), false)
  assert_eq(
    @materials.program_instancing_color(
      is_instanced_mesh=true,
      has_instance_color=true,
    ),
    true,
  )
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader instancingMorph needs a morph texture" {
  assert_eq(@materials.program_instancing_morph(), false)
  assert_eq(@materials.program_instancing_morph(is_instanced_mesh=true), false)
  assert_eq(@materials.program_instancing_morph(has_morph_texture=true), false)
  assert_eq(
    @materials.program_instancing_morph(
      is_instanced_mesh=true,
      has_morph_texture=true,
    ),
    true,
  )
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader outputColorSpace picks the active space" {
  assert_eq(@materials.program_output_color_space("srgb", "srgb-linear"), "srgb")
  assert_eq(
    @materials.program_output_color_space(
      "srgb",
      "srgb-linear",
      is_xr_render_target=true,
      target_color_space="display-p3",
    ),
    "srgb",
  )
  assert_eq(
    @materials.program_output_color_space(
      "srgb",
      "srgb-linear",
      has_render_target=true,
    ),
    "srgb-linear",
  )
  assert_eq(
    @materials.program_output_color_space(
      "srgb",
      "srgb-linear",
      has_render_target=true,
      is_xr_render_target=true,
      target_color_space="display-p3",
    ),
    "display-p3",
  )
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader alphaToCoverage starts off" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_alpha_to_coverage(), false)
  assert_eq(@materials.Material::raw().program_alpha_to_coverage(), false)
  assert_eq(@materials.Material::basic().program_alpha_to_coverage(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.alpha_to_coverage = true
  assert_eq(shader.program_alpha_to_coverage(), true)
}

///|
test "Material shader map follows the color texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_map(), false)
  assert_eq(@materials.Material::raw().program_map(), false)
  assert_eq(@materials.Material::basic().program_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_map(), true)
  shader.map = None
  assert_eq(shader.program_map(), false)
}

///|
test "Material shader matcap follows the matcap texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_matcap(), false)
  assert_eq(@materials.Material::raw().program_matcap(), false)
  assert_eq(@materials.Material::matcap().program_matcap(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.matcap = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_matcap(), true)
  shader.matcap = None
  assert_eq(shader.program_matcap(), false)
}

///|
test "Material shader envMap uses the scene for lit materials" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_env_map(), false)
  assert_eq(shader.program_env_map(has_scene_environment=true), false)
  assert_eq(@materials.Material::basic().program_env_map(has_scene_environment=true), false)
  assert_eq(@materials.Material::matcap().program_env_map(has_scene_environment=true), false)
  assert_eq(@materials.Material::lambert().program_env_map(), false)
  assert_eq(@materials.Material::lambert().program_env_map(has_scene_environment=true), true)
  assert_eq(@materials.Material::phong().program_env_map(has_scene_environment=true), true)
  assert_eq(@materials.Material::toon().program_env_map(has_scene_environment=true), true)
  assert_eq(@materials.Material::standard().program_env_map(has_scene_environment=true), true)
  assert_eq(@materials.Material::physical().program_env_map(has_scene_environment=true), true)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.env_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_env_map(), true)
  shader.env_map = None
  assert_eq(shader.program_env_map(), false)
}

///|
test "Material shader envMapMode is the mapping when a map exists" {
  let shader = @materials.Material::shader()
  match shader.program_env_map_mode(301) {
    None => ()
    Some(_) => abort("shader env map mode without a map")
  }
  match @materials.Material::basic().program_env_map_mode(301, has_scene_environment=true) {
    None => ()
    Some(_) => abort("basic env map mode from the scene")
  }
  match @materials.Material::lambert().program_env_map_mode(301, has_scene_environment=true) {
    Some(mode) => assert_eq(mode, 301)
    None => abort("lambert env map mode missing")
  }
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.env_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  match shader.program_env_map_mode(302) {
    Some(mode) => assert_eq(mode, 302)
    None => abort("shader env map mode missing")
  }
  shader.env_map = None
  match shader.program_env_map_mode(302) {
    None => ()
    Some(_) => abort("cleared env map kept a mode")
  }
}

///|
test "Material shader envMapCubeUVHeight needs cube UV mapping" {
  let shader = @materials.Material::shader()
  match shader.program_env_map_cube_uv_height(306) {
    None => ()
    Some(_) => abort("cube UV height without an env map")
  }
  match @materials.Material::basic().program_env_map_cube_uv_height(
    306,
    scene_environment_height=512,
    has_scene_environment=true,
  ) {
    None => ()
    Some(_) => abort("basic cube UV height from the scene")
  }
  match @materials.Material::lambert().program_env_map_cube_uv_height(
    306,
    scene_environment_height=512,
    has_scene_environment=true,
  ) {
    Some(height) => assert_eq(height, 512)
    None => abort("lambert cube UV height missing")
  }
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.env_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  match shader.program_env_map_cube_uv_height(301) {
    None => ()
    Some(_) => abort("reflection mapping wrote a cube UV height")
  }
  match shader.program_env_map_cube_uv_height(306) {
    Some(height) => assert_eq(height, 1)
    None => abort("shader cube UV height missing")
  }
}

///|
test "Material shader aoMap follows the occlusion texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_ao_map(), false)
  assert_eq(@materials.Material::raw().program_ao_map(), false)
  assert_eq(@materials.Material::standard().program_ao_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.ao_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_ao_map(), true)
  shader.ao_map = None
  assert_eq(shader.program_ao_map(), false)
}

///|
test "Material shader lightMap follows the light texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_light_map(), false)
  assert_eq(@materials.Material::raw().program_light_map(), false)
  assert_eq(@materials.Material::lambert().program_light_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.light_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_light_map(), true)
  shader.light_map = None
  assert_eq(shader.program_light_map(), false)
}

///|
test "Material shader bumpMap turns off for wireframe" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_bump_map(), false)
  assert_eq(@materials.Material::raw().program_bump_map(), false)
  assert_eq(@materials.Material::phong().program_bump_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.bump_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_bump_map(), true)
  shader.wireframe = true
  assert_eq(shader.program_bump_map(), false)
  shader.wireframe = false
  assert_eq(shader.program_bump_map(), true)
  shader.bump_map = None
  assert_eq(shader.program_bump_map(), false)
}

///|
test "Material shader normalMap follows the normal texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_normal_map(), false)
  assert_eq(@materials.Material::raw().program_normal_map(), false)
  assert_eq(@materials.Material::standard().program_normal_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.normal_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_normal_map(), true)
  shader.normal_map = None
  assert_eq(shader.program_normal_map(), false)
}

///|
test "Material shader normalMapObjectSpace follows object space" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_normal_map_object_space(), false)
  assert_eq(@materials.Material::raw().program_normal_map_object_space(), false)
  assert_eq(@materials.Material::standard().program_normal_map_object_space(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.normal_map_type = @constants.ObjectSpace
  assert_eq(shader.program_normal_map_object_space(), false)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.normal_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_normal_map_object_space(), true)
  shader.normal_map_type = @constants.TangentSpace
  assert_eq(shader.program_normal_map_object_space(), false)
  shader.normal_map_type = @constants.ObjectSpace
  assert_eq(shader.program_normal_map_object_space(), true)
  shader.normal_map = None
  assert_eq(shader.program_normal_map_object_space(), false)
}

///|
test "Material shader normalMapTangentSpace follows tangent space" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_normal_map_tangent_space(), false)
  assert_eq(@materials.Material::raw().program_normal_map_tangent_space(), false)
  assert_eq(@materials.Material::standard().program_normal_map_tangent_space(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.normal_map_type = @constants.TangentSpace
  assert_eq(shader.program_normal_map_tangent_space(), false)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.normal_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_normal_map_tangent_space(), true)
  shader.normal_map_type = @constants.ObjectSpace
  assert_eq(shader.program_normal_map_tangent_space(), false)
  shader.normal_map_type = @constants.TangentSpace
  assert_eq(shader.program_normal_map_tangent_space(), true)
  shader.normal_map = None
  assert_eq(shader.program_normal_map_tangent_space(), false)
}

///|
test "Material shader packedNormalMap follows packed RG formats" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_packed_normal_map(1030), false)
  assert_eq(@materials.Material::raw().program_packed_normal_map(37490), false)
  assert_eq(@materials.Material::standard().program_packed_normal_map(36285), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.normal_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_packed_normal_map(1023), false)
  assert_eq(shader.program_packed_normal_map(1028), false)
  assert_eq(shader.program_packed_normal_map(1030), true)
  assert_eq(shader.program_packed_normal_map(37490), true)
  assert_eq(shader.program_packed_normal_map(36285), true)
  assert_eq(shader.program_packed_normal_map(37491), false)
  assert_eq(shader.program_packed_normal_map(36286), false)
  shader.normal_map_type = @constants.ObjectSpace
  assert_eq(shader.program_packed_normal_map(1030), false)
  shader.normal_map_type = @constants.TangentSpace
  assert_eq(shader.program_packed_normal_map(1030), true)
  shader.normal_map = None
  assert_eq(shader.program_packed_normal_map(1030), false)
}

///|
test "Material shader displacementMap follows the displacement texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_displacement_map(), false)
  assert_eq(@materials.Material::raw().program_displacement_map(), false)
  assert_eq(@materials.Material::lambert().program_displacement_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.displacement_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_displacement_map(), true)
  shader.displacement_map = None
  assert_eq(shader.program_displacement_map(), false)
}

///|
test "Material shader emissiveMap follows the emissive texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_emissive_map(), false)
  assert_eq(@materials.Material::raw().program_emissive_map(), false)
  assert_eq(@materials.Material::standard().program_emissive_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.emissive_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_emissive_map(), true)
  shader.emissive_map = None
  assert_eq(shader.program_emissive_map(), false)
}

///|
test "Material shader metalnessMap follows the metalness texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_metalness_map(), false)
  assert_eq(@materials.Material::raw().program_metalness_map(), false)
  assert_eq(@materials.Material::standard().program_metalness_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.metalness_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_metalness_map(), true)
  shader.metalness_map = None
  assert_eq(shader.program_metalness_map(), false)
}

///|
test "Material shader roughnessMap follows the roughness texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_roughness_map(), false)
  assert_eq(@materials.Material::raw().program_roughness_map(), false)
  assert_eq(@materials.Material::standard().program_roughness_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.roughness_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_roughness_map(), true)
  shader.roughness_map = None
  assert_eq(shader.program_roughness_map(), false)
}

///|
test "Material shader anisotropy is true above zero" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_anisotropy(), false)
  assert_eq(@materials.Material::raw().program_anisotropy(), false)
  assert_eq(@materials.Material::physical().program_anisotropy(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.anisotropy = -1.0
  assert_eq(shader.program_anisotropy(), false)
  shader.anisotropy = 0.25
  assert_eq(shader.program_anisotropy(), true)
  shader.anisotropy = 0.0
  assert_eq(shader.program_anisotropy(), false)
}

///|
test "Material shader anisotropyMap needs strength and a texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_anisotropy_map(), false)
  assert_eq(@materials.Material::raw().program_anisotropy_map(), false)
  assert_eq(@materials.Material::physical().program_anisotropy_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.anisotropy_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_anisotropy_map(), false)
  shader.anisotropy = 0.25
  assert_eq(shader.program_anisotropy_map(), true)
  shader.anisotropy = 0.0
  assert_eq(shader.program_anisotropy_map(), false)
  shader.anisotropy = 0.25
  shader.anisotropy_map = None
  assert_eq(shader.program_anisotropy_map(), false)
}

///|
test "Material shader clearcoat is true above zero" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_clearcoat(), false)
  assert_eq(@materials.Material::raw().program_clearcoat(), false)
  assert_eq(@materials.Material::physical().program_clearcoat(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.clearcoat = -1.0
  assert_eq(shader.program_clearcoat(), false)
  shader.clearcoat = 0.25
  assert_eq(shader.program_clearcoat(), true)
  shader.clearcoat = 0.0
  assert_eq(shader.program_clearcoat(), false)
}

///|
test "Material shader clearcoatMap needs strength and a texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_clearcoat_map(), false)
  assert_eq(@materials.Material::raw().program_clearcoat_map(), false)
  assert_eq(@materials.Material::physical().program_clearcoat_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.clearcoat_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_clearcoat_map(), false)
  shader.clearcoat = 0.25
  assert_eq(shader.program_clearcoat_map(), true)
  shader.clearcoat = 0.0
  assert_eq(shader.program_clearcoat_map(), false)
  shader.clearcoat = 0.25
  shader.clearcoat_map = None
  assert_eq(shader.program_clearcoat_map(), false)
}

///|
test "Material shader clearcoatNormalMap needs strength and a texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_clearcoat_normal_map(), false)
  assert_eq(@materials.Material::raw().program_clearcoat_normal_map(), false)
  assert_eq(@materials.Material::physical().program_clearcoat_normal_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.clearcoat_normal_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_clearcoat_normal_map(), false)
  shader.clearcoat = 0.25
  assert_eq(shader.program_clearcoat_normal_map(), true)
  shader.clearcoat = 0.0
  assert_eq(shader.program_clearcoat_normal_map(), false)
  shader.clearcoat = 0.25
  shader.clearcoat_normal_map = None
  assert_eq(shader.program_clearcoat_normal_map(), false)
}

///|
test "Material shader clearcoatRoughnessMap needs strength and a texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_clearcoat_roughness_map(), false)
  assert_eq(@materials.Material::raw().program_clearcoat_roughness_map(), false)
  assert_eq(@materials.Material::physical().program_clearcoat_roughness_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.clearcoat_roughness_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_clearcoat_roughness_map(), false)
  shader.clearcoat = 0.25
  assert_eq(shader.program_clearcoat_roughness_map(), true)
  shader.clearcoat = 0.0
  assert_eq(shader.program_clearcoat_roughness_map(), false)
  shader.clearcoat = 0.25
  shader.clearcoat_roughness_map = None
  assert_eq(shader.program_clearcoat_roughness_map(), false)
}

///|
test "Material shader dispersion is true above zero" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_dispersion(), false)
  assert_eq(@materials.Material::raw().program_dispersion(), false)
  assert_eq(@materials.Material::physical().program_dispersion(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.dispersion = -1.0
  assert_eq(shader.program_dispersion(), false)
  shader.dispersion = 0.25
  assert_eq(shader.program_dispersion(), true)
  shader.dispersion = 0.0
  assert_eq(shader.program_dispersion(), false)
}

///|
test "Material shader retroreflection is true above zero" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_retroreflection(), false)
  assert_eq(@materials.Material::raw().program_retroreflection(), false)
  assert_eq(@materials.Material::physical().program_retroreflection(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.retroreflectivity = -1.0
  assert_eq(shader.program_retroreflection(), false)
  shader.retroreflectivity = 0.25
  assert_eq(shader.program_retroreflection(), true)
  shader.retroreflectivity = 0.0
  assert_eq(shader.program_retroreflection(), false)
}

///|
test "Material shader iridescence is true above zero" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_iridescence(), false)
  assert_eq(@materials.Material::raw().program_iridescence(), false)
  assert_eq(@materials.Material::physical().program_iridescence(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.iridescence = -1.0
  assert_eq(shader.program_iridescence(), false)
  shader.iridescence = 0.25
  assert_eq(shader.program_iridescence(), true)
  shader.iridescence = 0.0
  assert_eq(shader.program_iridescence(), false)
}

///|
test "Material shader iridescenceMap needs strength and a texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_iridescence_map(), false)
  assert_eq(@materials.Material::raw().program_iridescence_map(), false)
  assert_eq(@materials.Material::physical().program_iridescence_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.iridescence_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_iridescence_map(), false)
  shader.iridescence = 0.25
  assert_eq(shader.program_iridescence_map(), true)
  shader.iridescence = 0.0
  assert_eq(shader.program_iridescence_map(), false)
  shader.iridescence = 0.25
  shader.iridescence_map = None
  assert_eq(shader.program_iridescence_map(), false)
}

///|
test "Material shader iridescenceThicknessMap needs strength and a texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_iridescence_thickness_map(), false)
  assert_eq(@materials.Material::raw().program_iridescence_thickness_map(), false)
  assert_eq(@materials.Material::physical().program_iridescence_thickness_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.iridescence_thickness_map = Some(
    @textures.Texture::from_rgba8(1, 1, pixels),
  )
  assert_eq(shader.program_iridescence_thickness_map(), false)
  shader.iridescence = 0.25
  assert_eq(shader.program_iridescence_thickness_map(), true)
  shader.iridescence = 0.0
  assert_eq(shader.program_iridescence_thickness_map(), false)
  shader.iridescence = 0.25
  shader.iridescence_thickness_map = None
  assert_eq(shader.program_iridescence_thickness_map(), false)
}

///|
test "Material shader sheen is true above zero" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_sheen(), false)
  assert_eq(@materials.Material::raw().program_sheen(), false)
  assert_eq(@materials.Material::physical().program_sheen(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.sheen = -1.0
  assert_eq(shader.program_sheen(), false)
  shader.sheen = 0.25
  assert_eq(shader.program_sheen(), true)
  shader.sheen = 0.0
  assert_eq(shader.program_sheen(), false)
}

///|
test "Material shader sheenColorMap needs strength and a texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_sheen_color_map(), false)
  assert_eq(@materials.Material::raw().program_sheen_color_map(), false)
  assert_eq(@materials.Material::physical().program_sheen_color_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.sheen_color_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_sheen_color_map(), false)
  shader.sheen = 0.25
  assert_eq(shader.program_sheen_color_map(), true)
  shader.sheen = 0.0
  assert_eq(shader.program_sheen_color_map(), false)
  shader.sheen = 0.25
  shader.sheen_color_map = None
  assert_eq(shader.program_sheen_color_map(), false)
}

///|
test "Material shader sheenRoughnessMap needs strength and a texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_sheen_roughness_map(), false)
  assert_eq(@materials.Material::raw().program_sheen_roughness_map(), false)
  assert_eq(@materials.Material::physical().program_sheen_roughness_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.sheen_roughness_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_sheen_roughness_map(), false)
  shader.sheen = 0.25
  assert_eq(shader.program_sheen_roughness_map(), true)
  shader.sheen = 0.0
  assert_eq(shader.program_sheen_roughness_map(), false)
  shader.sheen = 0.25
  shader.sheen_roughness_map = None
  assert_eq(shader.program_sheen_roughness_map(), false)
}

///|
test "Material shader specularMap follows the specular texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_specular_map(), false)
  assert_eq(@materials.Material::raw().program_specular_map(), false)
  assert_eq(@materials.Material::phong().program_specular_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.specular_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_specular_map(), true)
  shader.specular_map = None
  assert_eq(shader.program_specular_map(), false)
}

///|
test "Material shader specularColorMap follows the specular color texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_specular_color_map(), false)
  assert_eq(@materials.Material::raw().program_specular_color_map(), false)
  assert_eq(@materials.Material::physical().program_specular_color_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.specular_color_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_specular_color_map(), true)
  shader.specular_color_map = None
  assert_eq(shader.program_specular_color_map(), false)
}

///|
test "Material shader specularIntensityMap follows the intensity texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_specular_intensity_map(), false)
  assert_eq(@materials.Material::raw().program_specular_intensity_map(), false)
  assert_eq(@materials.Material::physical().program_specular_intensity_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.specular_intensity_map = Some(
    @textures.Texture::from_rgba8(1, 1, pixels),
  )
  assert_eq(shader.program_specular_intensity_map(), true)
  shader.specular_intensity_map = None
  assert_eq(shader.program_specular_intensity_map(), false)
}

///|
test "Material shader transmission is true above zero" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_transmission(), false)
  assert_eq(@materials.Material::raw().program_transmission(), false)
  assert_eq(@materials.Material::physical().program_transmission(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.transmission = -1.0
  assert_eq(shader.program_transmission(), false)
  shader.transmission = 0.25
  assert_eq(shader.program_transmission(), true)
  shader.transmission = 0.0
  assert_eq(shader.program_transmission(), false)
}

///|
test "Material shader transmissionMap needs strength and a texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_transmission_map(), false)
  assert_eq(@materials.Material::raw().program_transmission_map(), false)
  assert_eq(@materials.Material::physical().program_transmission_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.transmission_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_transmission_map(), false)
  shader.transmission = 0.25
  assert_eq(shader.program_transmission_map(), true)
  shader.transmission = 0.0
  assert_eq(shader.program_transmission_map(), false)
  shader.transmission = 0.25
  shader.transmission_map = None
  assert_eq(shader.program_transmission_map(), false)
}

///|
test "Material shader thicknessMap needs transmission and a texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_thickness_map(), false)
  assert_eq(@materials.Material::raw().program_thickness_map(), false)
  assert_eq(@materials.Material::physical().program_thickness_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.thickness_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_thickness_map(), false)
  shader.transmission = 0.25
  assert_eq(shader.program_thickness_map(), true)
  shader.transmission = 0.0
  assert_eq(shader.program_thickness_map(), false)
  shader.transmission = 0.25
  shader.thickness_map = None
  assert_eq(shader.program_thickness_map(), false)
}

///|
test "Material shader gradientMap follows the gradient texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_gradient_map(), false)
  assert_eq(@materials.Material::raw().program_gradient_map(), false)
  assert_eq(@materials.Material::toon().program_gradient_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.gradient_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_gradient_map(), true)
  shader.gradient_map = None
  assert_eq(shader.program_gradient_map(), false)
}

///|
test "Material shader opaque needs normal blending" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_opaque(), true)
  assert_eq(@materials.Material::raw().program_opaque(), true)
  assert_eq(@materials.Material::basic().program_opaque(), true)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.transparent = true
  assert_eq(shader.program_opaque(), false)
  shader.transparent = false
  assert_eq(shader.program_opaque(), true)
  shader.blending = @constants.Additive
  assert_eq(shader.program_opaque(), false)
  shader.blending = @constants.Normal
  assert_eq(shader.program_opaque(), true)
  shader.alpha_to_coverage = true
  assert_eq(shader.program_opaque(), false)
  shader.alpha_to_coverage = false
  assert_eq(shader.program_opaque(), true)
}

///|
test "Material shader alphaMap follows the alpha texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_alpha_map(), false)
  assert_eq(@materials.Material::raw().program_alpha_map(), false)
  assert_eq(@materials.Material::basic().program_alpha_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.alpha_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_alpha_map(), true)
  shader.alpha_map = None
  assert_eq(shader.program_alpha_map(), false)
}

///|
test "Material shader alphaTest is true above zero" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_alpha_test(), false)
  assert_eq(@materials.Material::raw().program_alpha_test(), false)
  assert_eq(@materials.Material::basic().program_alpha_test(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.alpha_test = -1.0
  assert_eq(shader.program_alpha_test(), false)
  shader.alpha_test = 0.25
  assert_eq(shader.program_alpha_test(), true)
  shader.alpha_test = 0.0
  assert_eq(shader.program_alpha_test(), false)
}

///|
test "Material shader alphaHash follows the flag" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_alpha_hash(), false)
  assert_eq(@materials.Material::raw().program_alpha_hash(), false)
  assert_eq(@materials.Material::basic().program_alpha_hash(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.alpha_hash = true
  assert_eq(shader.program_alpha_hash(), true)
  shader.alpha_hash = false
  assert_eq(shader.program_alpha_hash(), false)
}

///|
test "Material shader combine returns the operation" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_combine() is @constants.Multiply, true)
  assert_eq(shader.program_combine().to_int(), 0)
  assert_eq(@materials.Material::raw().program_combine().to_int(), 0)
  assert_eq(@materials.Material::phong().program_combine().to_int(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.combine = @constants.Mix
  assert_eq(shader.program_combine() is @constants.Mix, true)
  assert_eq(shader.program_combine().to_int(), 1)
  shader.combine = @constants.Add
  assert_eq(shader.program_combine() is @constants.Add, true)
  assert_eq(shader.program_combine().to_int(), 2)
  shader.combine = @constants.Multiply
  assert_eq(shader.program_combine().to_int(), 0)
}

///|
test "Material shader mapUv names the color texture channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_map_uv(), "false")
  assert_eq(@materials.Material::basic().program_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.program_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_map_uv(), "uv2")
  shader.map = None
  assert_eq(shader.program_map_uv(), "false")
}

///|
test "Material shader aoMapUv names the occlusion texture channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_ao_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_ao_map_uv(), "false")
  assert_eq(@materials.Material::standard().program_ao_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.ao_map = Some(map)
  assert_eq(shader.program_ao_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_ao_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_ao_map_uv(), "uv2")
  shader.ao_map = None
  assert_eq(shader.program_ao_map_uv(), "false")
}

///|
test "Material shader lightMapUv names the light texture channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_light_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_light_map_uv(), "false")
  assert_eq(@materials.Material::lambert().program_light_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.light_map = Some(map)
  assert_eq(shader.program_light_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_light_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_light_map_uv(), "uv2")
  shader.light_map = None
  assert_eq(shader.program_light_map_uv(), "false")
}

///|
test "Material shader bumpMapUv turns off for wireframe" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_bump_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_bump_map_uv(), "false")
  assert_eq(@materials.Material::phong().program_bump_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.bump_map = Some(map)
  assert_eq(shader.program_bump_map_uv(), "uv")
  shader.wireframe = true
  assert_eq(shader.program_bump_map_uv(), "false")
  shader.wireframe = false
  map.channel = 1
  assert_eq(shader.program_bump_map_uv(), "uv1")
  shader.bump_map = None
  assert_eq(shader.program_bump_map_uv(), "false")
}

///|
test "Material shader normalMapUv names the normal texture channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_normal_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_normal_map_uv(), "false")
  assert_eq(@materials.Material::standard().program_normal_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.normal_map = Some(map)
  assert_eq(shader.program_normal_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_normal_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_normal_map_uv(), "uv2")
  shader.normal_map = None
  assert_eq(shader.program_normal_map_uv(), "false")
}

///|
test "Material shader displacementMapUv names the displacement texture channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_displacement_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_displacement_map_uv(), "false")
  assert_eq(@materials.Material::lambert().program_displacement_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.displacement_map = Some(map)
  assert_eq(shader.program_displacement_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_displacement_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_displacement_map_uv(), "uv2")
  shader.displacement_map = None
  assert_eq(shader.program_displacement_map_uv(), "false")
}

///|
test "Material shader emissiveMapUv names the emissive texture channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_emissive_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_emissive_map_uv(), "false")
  assert_eq(@materials.Material::standard().program_emissive_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.emissive_map = Some(map)
  assert_eq(shader.program_emissive_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_emissive_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_emissive_map_uv(), "uv2")
  shader.emissive_map = None
  assert_eq(shader.program_emissive_map_uv(), "false")
}

///|
test "Material shader metalnessMapUv names the metalness texture channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_metalness_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_metalness_map_uv(), "false")
  assert_eq(@materials.Material::standard().program_metalness_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.metalness_map = Some(map)
  assert_eq(shader.program_metalness_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_metalness_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_metalness_map_uv(), "uv2")
  shader.metalness_map = None
  assert_eq(shader.program_metalness_map_uv(), "false")
}

///|
test "Material shader roughnessMapUv names the roughness texture channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_roughness_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_roughness_map_uv(), "false")
  assert_eq(@materials.Material::standard().program_roughness_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.roughness_map = Some(map)
  assert_eq(shader.program_roughness_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_roughness_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_roughness_map_uv(), "uv2")
  shader.roughness_map = None
  assert_eq(shader.program_roughness_map_uv(), "false")
}

///|
test "Material shader anisotropyMapUv needs strength and a channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_anisotropy_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_anisotropy_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_anisotropy_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.anisotropy_map = Some(map)
  assert_eq(shader.program_anisotropy_map_uv(), "false")
  shader.anisotropy = 0.25
  assert_eq(shader.program_anisotropy_map_uv(), "uv")
  shader.anisotropy = 0.0
  assert_eq(shader.program_anisotropy_map_uv(), "false")
  shader.anisotropy = 0.25
  map.channel = 1
  assert_eq(shader.program_anisotropy_map_uv(), "uv1")
  shader.anisotropy_map = None
  assert_eq(shader.program_anisotropy_map_uv(), "false")
}

///|
test "Material shader clearcoatMapUv needs strength and a channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_clearcoat_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_clearcoat_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_clearcoat_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.clearcoat_map = Some(map)
  assert_eq(shader.program_clearcoat_map_uv(), "false")
  shader.clearcoat = 0.25
  assert_eq(shader.program_clearcoat_map_uv(), "uv")
  shader.clearcoat = 0.0
  assert_eq(shader.program_clearcoat_map_uv(), "false")
  shader.clearcoat = 0.25
  map.channel = 1
  assert_eq(shader.program_clearcoat_map_uv(), "uv1")
  shader.clearcoat_map = None
  assert_eq(shader.program_clearcoat_map_uv(), "false")
}

///|
test "Material shader clearcoatNormalMapUv needs strength and a channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_clearcoat_normal_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_clearcoat_normal_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_clearcoat_normal_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.clearcoat_normal_map = Some(map)
  assert_eq(shader.program_clearcoat_normal_map_uv(), "false")
  shader.clearcoat = 0.25
  assert_eq(shader.program_clearcoat_normal_map_uv(), "uv")
  shader.clearcoat = 0.0
  assert_eq(shader.program_clearcoat_normal_map_uv(), "false")
  shader.clearcoat = 0.25
  map.channel = 1
  assert_eq(shader.program_clearcoat_normal_map_uv(), "uv1")
  shader.clearcoat_normal_map = None
  assert_eq(shader.program_clearcoat_normal_map_uv(), "false")
}

///|
test "Material shader clearcoatRoughnessMapUv needs strength and a channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_clearcoat_roughness_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_clearcoat_roughness_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_clearcoat_roughness_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.clearcoat_roughness_map = Some(map)
  assert_eq(shader.program_clearcoat_roughness_map_uv(), "false")
  shader.clearcoat = 0.25
  assert_eq(shader.program_clearcoat_roughness_map_uv(), "uv")
  shader.clearcoat = 0.0
  assert_eq(shader.program_clearcoat_roughness_map_uv(), "false")
  shader.clearcoat = 0.25
  map.channel = 1
  assert_eq(shader.program_clearcoat_roughness_map_uv(), "uv1")
  shader.clearcoat_roughness_map = None
  assert_eq(shader.program_clearcoat_roughness_map_uv(), "false")
}

///|
test "Material shader iridescenceMapUv needs strength and a channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_iridescence_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_iridescence_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_iridescence_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.iridescence_map = Some(map)
  assert_eq(shader.program_iridescence_map_uv(), "false")
  shader.iridescence = 0.25
  assert_eq(shader.program_iridescence_map_uv(), "uv")
  shader.iridescence = 0.0
  assert_eq(shader.program_iridescence_map_uv(), "false")
  shader.iridescence = 0.25
  map.channel = 1
  assert_eq(shader.program_iridescence_map_uv(), "uv1")
  shader.iridescence_map = None
  assert_eq(shader.program_iridescence_map_uv(), "false")
}

///|
test "Material shader iridescenceThicknessMapUv needs strength and a channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_iridescence_thickness_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_iridescence_thickness_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_iridescence_thickness_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.iridescence_thickness_map = Some(map)
  assert_eq(shader.program_iridescence_thickness_map_uv(), "false")
  shader.iridescence = 0.25
  assert_eq(shader.program_iridescence_thickness_map_uv(), "uv")
  shader.iridescence = 0.0
  assert_eq(shader.program_iridescence_thickness_map_uv(), "false")
  shader.iridescence = 0.25
  map.channel = 1
  assert_eq(shader.program_iridescence_thickness_map_uv(), "uv1")
  shader.iridescence_thickness_map = None
  assert_eq(shader.program_iridescence_thickness_map_uv(), "false")
}

///|
test "Material shader sheenColorMapUv needs strength and a channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_sheen_color_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_sheen_color_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_sheen_color_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.sheen_color_map = Some(map)
  assert_eq(shader.program_sheen_color_map_uv(), "false")
  shader.sheen = 0.25
  assert_eq(shader.program_sheen_color_map_uv(), "uv")
  shader.sheen = 0.0
  assert_eq(shader.program_sheen_color_map_uv(), "false")
  shader.sheen = 0.25
  map.channel = 1
  assert_eq(shader.program_sheen_color_map_uv(), "uv1")
  shader.sheen_color_map = None
  assert_eq(shader.program_sheen_color_map_uv(), "false")
}

///|
test "Material shader sheenRoughnessMapUv needs strength and a channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_sheen_roughness_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_sheen_roughness_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_sheen_roughness_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.sheen_roughness_map = Some(map)
  assert_eq(shader.program_sheen_roughness_map_uv(), "false")
  shader.sheen = 0.25
  assert_eq(shader.program_sheen_roughness_map_uv(), "uv")
  shader.sheen = 0.0
  assert_eq(shader.program_sheen_roughness_map_uv(), "false")
  shader.sheen = 0.25
  map.channel = 1
  assert_eq(shader.program_sheen_roughness_map_uv(), "uv1")
  shader.sheen_roughness_map = None
  assert_eq(shader.program_sheen_roughness_map_uv(), "false")
}

///|
test "Material shader specularMapUv names the specular texture channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_specular_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_specular_map_uv(), "false")
  assert_eq(@materials.Material::lambert().program_specular_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.specular_map = Some(map)
  assert_eq(shader.program_specular_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_specular_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_specular_map_uv(), "uv2")
  shader.specular_map = None
  assert_eq(shader.program_specular_map_uv(), "false")
}

///|
test "Material shader specularColorMapUv names the specular color channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_specular_color_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_specular_color_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_specular_color_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.specular_color_map = Some(map)
  assert_eq(shader.program_specular_color_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_specular_color_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_specular_color_map_uv(), "uv2")
  shader.specular_color_map = None
  assert_eq(shader.program_specular_color_map_uv(), "false")
}

///|
test "Material shader specularIntensityMapUv names the intensity channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_specular_intensity_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_specular_intensity_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_specular_intensity_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.specular_intensity_map = Some(map)
  assert_eq(shader.program_specular_intensity_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_specular_intensity_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_specular_intensity_map_uv(), "uv2")
  shader.specular_intensity_map = None
  assert_eq(shader.program_specular_intensity_map_uv(), "false")
}

///|
test "Material shader transmissionMapUv needs strength and a channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_transmission_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_transmission_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_transmission_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.transmission_map = Some(map)
  assert_eq(shader.program_transmission_map_uv(), "false")
  shader.transmission = 0.25
  assert_eq(shader.program_transmission_map_uv(), "uv")
  shader.transmission = 0.0
  assert_eq(shader.program_transmission_map_uv(), "false")
  shader.transmission = 0.25
  map.channel = 1
  assert_eq(shader.program_transmission_map_uv(), "uv1")
  shader.transmission_map = None
  assert_eq(shader.program_transmission_map_uv(), "false")
}

///|
test "Material shader thicknessMapUv needs transmission and a channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_thickness_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_thickness_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_thickness_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.thickness_map = Some(map)
  assert_eq(shader.program_thickness_map_uv(), "false")
  shader.transmission = 0.25
  assert_eq(shader.program_thickness_map_uv(), "uv")
  shader.transmission = 0.0
  assert_eq(shader.program_thickness_map_uv(), "false")
  shader.transmission = 0.25
  map.channel = 1
  assert_eq(shader.program_thickness_map_uv(), "uv1")
  shader.thickness_map = None
  assert_eq(shader.program_thickness_map_uv(), "false")
}

///|
test "Material shader alphaMapUv names the alpha texture channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_alpha_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_alpha_map_uv(), "false")
  assert_eq(@materials.Material::basic().program_alpha_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.alpha_map = Some(map)
  assert_eq(shader.program_alpha_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_alpha_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_alpha_map_uv(), "uv2")
  shader.alpha_map = None
  assert_eq(shader.program_alpha_map_uv(), "false")
}

///|
test "Material shader vertexTangents needs a tangent and a normal source" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_vertex_tangents(), false)
  assert_eq(@materials.Material::raw().program_vertex_tangents(), false)
  assert_eq(@materials.Material::physical().program_vertex_tangents(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_vertex_tangents(has_tangent=true), false)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.normal_map = Some(map)
  assert_eq(shader.program_vertex_tangents(), false)
  assert_eq(shader.program_vertex_tangents(has_tangent=true), true)
  shader.normal_map = None
  shader.anisotropy = 0.25
  assert_eq(shader.program_vertex_tangents(has_tangent=true), true)
  shader.anisotropy = 0.0
  assert_eq(shader.program_vertex_tangents(has_tangent=true), false)
}

///|
test "Material shader vertexNormals reads the geometry normal attribute" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_vertex_normals(), false)
  assert_eq(@materials.Material::raw().program_vertex_normals(), false)
  assert_eq(@materials.Material::basic().program_vertex_normals(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_vertex_normals(has_normal=true), true)
  assert_eq(shader.program_vertex_normals(has_normal=false), false)
  shader.vertex_colors = true
  assert_eq(shader.program_vertex_normals(has_normal=true), true)
}

///|
test "Material shader vertexColors reads the material flag" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_vertex_colors(), false)
  assert_eq(@materials.Material::raw().program_vertex_colors(), false)
  assert_eq(@materials.Material::basic().program_vertex_colors(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.vertex_colors = true
  assert_eq(shader.program_vertex_colors(), true)
  shader.vertex_colors = false
  assert_eq(shader.program_vertex_colors(), false)
}

///|
test "Material shader vertexAlphas needs colors and a four-wide attribute" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_vertex_alphas(), false)
  assert_eq(@materials.Material::raw().program_vertex_alphas(), false)
  assert_eq(@materials.Material::basic().program_vertex_alphas(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.vertex_colors = true
  assert_eq(shader.program_vertex_alphas(), false)
  assert_eq(shader.program_vertex_alphas(has_vertex_alpha=true), true)
  shader.vertex_colors = false
  assert_eq(shader.program_vertex_alphas(has_vertex_alpha=true), false)
}

///|
test "Material shader pointsUvs needs points, a uv, and a map" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_points_uvs(), false)
  assert_eq(@materials.Material::raw().program_points_uvs(), false)
  assert_eq(@materials.Material::basic().program_points_uvs(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_points_uvs(has_points_uv=true), false)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.program_points_uvs(), false)
  assert_eq(shader.program_points_uvs(has_points_uv=true), true)
  shader.map = None
  let alpha = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.alpha_map = Some(alpha)
  assert_eq(shader.program_points_uvs(has_points_uv=true), true)
  shader.alpha_map = None
  assert_eq(shader.program_points_uvs(has_points_uv=true), false)
}

///|
test "Material shader fog reads the scene fog" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  assert_eq(shader.program_fog(), false)
  assert_eq(@materials.Material::raw().program_fog(), false)
  assert_eq(basic.program_fog(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_fog(has_fog=true), true)
  shader.fog = true
  assert_eq(shader.program_fog(), false)
  basic.fog = false
  assert_eq(basic.program_fog(has_fog=true), true)
}

///|
test "Material shader useFog reads the material flag" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  assert_eq(shader.program_use_fog(), false)
  assert_eq(@materials.Material::raw().program_use_fog(), false)
  assert_eq(basic.program_use_fog(), true)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.fog = true
  assert_eq(shader.program_use_fog(), true)
  shader.fog = false
  assert_eq(shader.program_use_fog(), false)
  assert_eq(shader.program_fog(has_fog=true), true)
}

///|
test "Material shader fogExp2 needs scene fog of that kind" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_fog_exp2(), false)
  assert_eq(@materials.Material::raw().program_fog_exp2(), false)
  assert_eq(@materials.Material::basic().program_fog_exp2(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_fog_exp2(has_fog=true), false)
  assert_eq(shader.program_fog_exp2(fog_exp2=true), false)
  assert_eq(shader.program_fog_exp2(has_fog=true, fog_exp2=true), true)
  shader.fog = true
  assert_eq(shader.program_fog_exp2(), false)
  shader.fog = false
  assert_eq(shader.program_fog_exp2(has_fog=true, fog_exp2=true), true)
}

///|
test "Material shader flatShading skips wireframes and derived lit meshes" {
  let shader = @materials.Material::shader()
  let lambert = @materials.Material::lambert()
  assert_eq(shader.program_flat_shading(), false)
  assert_eq(@materials.Material::raw().program_flat_shading(), false)
  assert_eq(@materials.Material::basic().program_flat_shading(), false)
  assert_eq(@materials.Material::toon().program_flat_shading(), false)
  assert_eq(lambert.program_flat_shading(), true)
  assert_eq(@materials.Material::phong().program_flat_shading(), true)
  assert_eq(@materials.Material::standard().program_flat_shading(), true)
  assert_eq(@materials.Material::physical().program_flat_shading(), true)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(lambert.program_flat_shading(has_normal=true), false)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  lambert.normal_map = Some(map)
  assert_eq(lambert.program_flat_shading(), false)
  lambert.normal_map = None
  shader.flat_shading = true
  assert_eq(shader.program_flat_shading(), true)
  shader.wireframe = true
  assert_eq(shader.program_flat_shading(), false)
  lambert.flat_shading = true
  lambert.wireframe = true
  assert_eq(lambert.program_flat_shading(has_normal=true), false)
  lambert.wireframe = false
  assert_eq(lambert.program_flat_shading(has_normal=true), true)
}

///|
test "Material shader sizeAttenuation is only on points and sprites" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_size_attenuation(), false)
  assert_eq(@materials.Material::raw().program_size_attenuation(), false)
  assert_eq(@materials.Material::basic().program_size_attenuation(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let points = @materials.PointsMaterial::new()
  assert_eq(points.program_size_attenuation(), true)
  points.size_attenuation = false
  assert_eq(points.program_size_attenuation(), false)
  points.size_attenuation = true
  assert_eq(points.program_size_attenuation(), true)
  let sprite = @materials.SpriteMaterial::new()
  assert_eq(sprite.program_size_attenuation(), true)
  sprite.size_attenuation = false
  assert_eq(sprite.program_size_attenuation(), false)
}

///|
test "Material shader logarithmicDepthBuffer reads the renderer flag" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_logarithmic_depth_buffer(), false)
  assert_eq(@materials.Material::raw().program_logarithmic_depth_buffer(), false)
  assert_eq(@materials.Material::basic().program_logarithmic_depth_buffer(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_logarithmic_depth_buffer(logarithmic_depth_buffer=true), true)
  assert_eq(shader.program_logarithmic_depth_buffer(logarithmic_depth_buffer=false), false)
}

///|
test "Material shader reversedDepthBuffer reads the renderer flag" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_reversed_depth_buffer(), false)
  assert_eq(@materials.Material::raw().program_reversed_depth_buffer(), false)
  assert_eq(@materials.Material::basic().program_reversed_depth_buffer(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_reversed_depth_buffer(reversed_depth_buffer=true), true)
  assert_eq(shader.program_reversed_depth_buffer(reversed_depth_buffer=false), false)
  assert_eq(shader.program_logarithmic_depth_buffer(logarithmic_depth_buffer=true), true)
  assert_eq(shader.program_reversed_depth_buffer(), false)
}

///|
test "Material shader skinning reads whether the object is skinned" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_skinning(), false)
  assert_eq(@materials.Material::raw().program_skinning(), false)
  assert_eq(@materials.Material::basic().program_skinning(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_skinning(has_skinning=true), true)
  assert_eq(shader.program_skinning(has_skinning=false), false)
  assert_eq(shader.program_reversed_depth_buffer(reversed_depth_buffer=true), true)
  assert_eq(shader.program_skinning(), false)
}

///|
test "Material shader hasPositionAttribute reads the geometry position" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_has_position_attribute(), false)
  assert_eq(@materials.Material::raw().program_has_position_attribute(), false)
  assert_eq(@materials.Material::basic().program_has_position_attribute(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_has_position_attribute(has_position=true), true)
  assert_eq(shader.program_has_position_attribute(has_position=false), false)
  assert_eq(shader.program_skinning(has_skinning=true), true)
  assert_eq(shader.program_has_position_attribute(), false)
}

///|
test "Material shader morphTargets reads position morph attributes" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_morph_targets(), false)
  assert_eq(@materials.Material::raw().program_morph_targets(), false)
  assert_eq(@materials.Material::basic().program_morph_targets(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_morph_targets(has_morph_targets=true), true)
  assert_eq(shader.program_morph_targets(has_morph_targets=false), false)
  assert_eq(shader.program_has_position_attribute(has_position=true), true)
  assert_eq(shader.program_morph_targets(), false)
}

///|
test "Material shader morphNormals reads normal morph attributes" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_morph_normals(), false)
  assert_eq(@materials.Material::raw().program_morph_normals(), false)
  assert_eq(@materials.Material::basic().program_morph_normals(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_morph_normals(has_morph_normals=true), true)
  assert_eq(shader.program_morph_normals(has_morph_normals=false), false)
  assert_eq(shader.program_morph_targets(has_morph_targets=true), true)
  assert_eq(shader.program_morph_normals(), false)
}

///|
test "Material shader morphColors reads color morph attributes" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_morph_colors(), false)
  assert_eq(@materials.Material::raw().program_morph_colors(), false)
  assert_eq(@materials.Material::basic().program_morph_colors(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_morph_colors(has_morph_colors=true), true)
  assert_eq(shader.program_morph_colors(has_morph_colors=false), false)
  assert_eq(shader.program_morph_normals(has_morph_normals=true), true)
  assert_eq(shader.program_morph_colors(), false)
}

///|
test "Material shader morphTargetsCount prefers position then normal then color" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_morph_targets_count(), 0)
  assert_eq(@materials.Material::raw().program_morph_targets_count(), 0)
  assert_eq(@materials.Material::basic().program_morph_targets_count(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.program_morph_targets_count(
      position_count=Some(3),
      normal_count=Some(2),
      color_count=Some(4),
    ),
    3,
  )
  assert_eq(shader.program_morph_targets_count(normal_count=Some(2)), 2)
  assert_eq(shader.program_morph_targets_count(color_count=Some(4)), 4)
  assert_eq(
    shader.program_morph_targets_count(position_count=Some(0), normal_count=Some(5)),
    0,
  )
  assert_eq(shader.program_morph_colors(has_morph_colors=true), true)
  assert_eq(shader.program_morph_targets_count(), 0)
}

///|
test "Material shader morphTextureStride lets later attributes overwrite" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_morph_texture_stride(), 0)
  assert_eq(@materials.Material::raw().program_morph_texture_stride(), 0)
  assert_eq(@materials.Material::basic().program_morph_texture_stride(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_morph_texture_stride(has_position_morph=true), 1)
  assert_eq(
    shader.program_morph_texture_stride(has_position_morph=true, has_normal_morph=true),
    2,
  )
  assert_eq(
    shader.program_morph_texture_stride(
      has_position_morph=true,
      has_normal_morph=true,
      has_color_morph=true,
    ),
    3,
  )
  assert_eq(shader.program_morph_texture_stride(has_color_morph=true), 3)
  assert_eq(shader.program_morph_texture_stride(has_normal_morph=true), 2)
  assert_eq(shader.program_morph_targets_count(position_count=Some(4)), 4)
  assert_eq(shader.program_morph_texture_stride(), 0)
}

///|
test "Material shader numSunLights reads the sun light count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_sun_lights(), 0)
  assert_eq(@materials.Material::raw().program_num_sun_lights(), 0)
  assert_eq(@materials.Material::basic().program_num_sun_lights(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_sun_lights(num_sun_lights=2), 2)
  assert_eq(shader.program_num_sun_lights(num_sun_lights=0), 0)
  assert_eq(shader.program_morph_texture_stride(has_color_morph=true), 3)
  assert_eq(shader.program_num_sun_lights(), 0)
}

///|
test "Material shader numDirLights reads the directional light count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_dir_lights(), 0)
  assert_eq(@materials.Material::raw().program_num_dir_lights(), 0)
  assert_eq(@materials.Material::basic().program_num_dir_lights(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_dir_lights(num_dir_lights=3), 3)
  assert_eq(shader.program_num_dir_lights(num_dir_lights=0), 0)
  assert_eq(shader.program_num_sun_lights(num_sun_lights=2), 2)
  assert_eq(shader.program_num_dir_lights(), 0)
}

///|
test "Material shader numPointLights reads the point light count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_point_lights(), 0)
  assert_eq(@materials.Material::raw().program_num_point_lights(), 0)
  assert_eq(@materials.Material::basic().program_num_point_lights(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_point_lights(num_point_lights=4), 4)
  assert_eq(shader.program_num_point_lights(num_point_lights=0), 0)
  assert_eq(shader.program_num_dir_lights(num_dir_lights=3), 3)
  assert_eq(shader.program_num_point_lights(), 0)
}

///|
test "Material shader numSpotLights reads the spot light count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_spot_lights(), 0)
  assert_eq(@materials.Material::raw().program_num_spot_lights(), 0)
  assert_eq(@materials.Material::basic().program_num_spot_lights(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_spot_lights(num_spot_lights=2), 2)
  assert_eq(shader.program_num_spot_lights(num_spot_lights=0), 0)
  assert_eq(shader.program_num_point_lights(num_point_lights=4), 4)
  assert_eq(shader.program_num_spot_lights(), 0)
}

///|
test "Material shader numSpotLightMaps reads the spot light map count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_spot_light_maps(), 0)
  assert_eq(@materials.Material::raw().program_num_spot_light_maps(), 0)
  assert_eq(@materials.Material::basic().program_num_spot_light_maps(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_spot_light_maps(num_spot_light_maps=1), 1)
  assert_eq(shader.program_num_spot_light_maps(num_spot_light_maps=0), 0)
  assert_eq(shader.program_num_spot_lights(num_spot_lights=2), 2)
  assert_eq(shader.program_num_spot_light_maps(), 0)
}

///|
test "Material shader numRectAreaLights reads the rect area light count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_rect_area_lights(), 0)
  assert_eq(@materials.Material::raw().program_num_rect_area_lights(), 0)
  assert_eq(@materials.Material::basic().program_num_rect_area_lights(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_rect_area_lights(num_rect_area_lights=2), 2)
  assert_eq(shader.program_num_rect_area_lights(num_rect_area_lights=0), 0)
  assert_eq(shader.program_num_spot_light_maps(num_spot_light_maps=1), 1)
  assert_eq(shader.program_num_rect_area_lights(), 0)
}

///|
test "Material shader numHemiLights reads the hemisphere light count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_hemi_lights(), 0)
  assert_eq(@materials.Material::raw().program_num_hemi_lights(), 0)
  assert_eq(@materials.Material::basic().program_num_hemi_lights(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_hemi_lights(num_hemi_lights=1), 1)
  assert_eq(shader.program_num_hemi_lights(num_hemi_lights=0), 0)
  assert_eq(shader.program_num_rect_area_lights(num_rect_area_lights=2), 2)
  assert_eq(shader.program_num_hemi_lights(), 0)
}

///|
test "Material shader numSunLightShadows reads the sun shadow count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_sun_light_shadows(), 0)
  assert_eq(@materials.Material::raw().program_num_sun_light_shadows(), 0)
  assert_eq(@materials.Material::basic().program_num_sun_light_shadows(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_sun_light_shadows(num_sun_light_shadows=1), 1)
  assert_eq(shader.program_num_sun_light_shadows(num_sun_light_shadows=0), 0)
  assert_eq(shader.program_num_sun_lights(num_sun_lights=2), 2)
  assert_eq(shader.program_num_sun_light_shadows(), 0)
}

///|
test "Material shader numDirLightShadows reads the directional shadow count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_dir_light_shadows(), 0)
  assert_eq(@materials.Material::raw().program_num_dir_light_shadows(), 0)
  assert_eq(@materials.Material::basic().program_num_dir_light_shadows(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_dir_light_shadows(num_dir_light_shadows=2), 2)
  assert_eq(shader.program_num_dir_light_shadows(num_dir_light_shadows=0), 0)
  assert_eq(shader.program_num_dir_lights(num_dir_lights=3), 3)
  assert_eq(shader.program_num_dir_light_shadows(), 0)
}

///|
test "Material shader numPointLightShadows reads the point shadow count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_point_light_shadows(), 0)
  assert_eq(@materials.Material::raw().program_num_point_light_shadows(), 0)
  assert_eq(@materials.Material::basic().program_num_point_light_shadows(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_point_light_shadows(num_point_light_shadows=3), 3)
  assert_eq(shader.program_num_point_light_shadows(num_point_light_shadows=0), 0)
  assert_eq(shader.program_num_point_lights(num_point_lights=4), 4)
  assert_eq(shader.program_num_point_light_shadows(), 0)
}

///|
test "Material shader numSpotLightShadows reads the spot shadow count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_spot_light_shadows(), 0)
  assert_eq(@materials.Material::raw().program_num_spot_light_shadows(), 0)
  assert_eq(@materials.Material::basic().program_num_spot_light_shadows(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_spot_light_shadows(num_spot_light_shadows=2), 2)
  assert_eq(shader.program_num_spot_light_shadows(num_spot_light_shadows=0), 0)
  assert_eq(shader.program_num_spot_lights(num_spot_lights=2), 2)
  assert_eq(shader.program_num_spot_light_shadows(), 0)
}

///|
test "Material shader numSpotLightShadowsWithMaps reads that shadow count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_spot_light_shadows_with_maps(), 0)
  assert_eq(@materials.Material::raw().program_num_spot_light_shadows_with_maps(), 0)
  assert_eq(@materials.Material::basic().program_num_spot_light_shadows_with_maps(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.program_num_spot_light_shadows_with_maps(num_spot_light_shadows_with_maps=1),
    1,
  )
  assert_eq(
    shader.program_num_spot_light_shadows_with_maps(num_spot_light_shadows_with_maps=0),
    0,
  )
  assert_eq(shader.program_num_spot_light_shadows(num_spot_light_shadows=2), 2)
  assert_eq(shader.program_num_spot_light_shadows_with_maps(), 0)
}

///|
test "Material shader numLightProbes reads the light probe count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_light_probes(), 0)
  assert_eq(@materials.Material::raw().program_num_light_probes(), 0)
  assert_eq(@materials.Material::basic().program_num_light_probes(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_light_probes(num_light_probes=2), 2)
  assert_eq(shader.program_num_light_probes(num_light_probes=0), 0)
  assert_eq(
    shader.program_num_spot_light_shadows_with_maps(num_spot_light_shadows_with_maps=1),
    1,
  )
  assert_eq(shader.program_num_light_probes(), 0)
}

///|
test "Material shader numLightProbeGrids reads the probe grid count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_light_probe_grids(), 0)
  assert_eq(@materials.Material::raw().program_num_light_probe_grids(), 0)
  assert_eq(@materials.Material::basic().program_num_light_probe_grids(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_light_probe_grids(num_light_probe_grids=2), 2)
  assert_eq(shader.program_num_light_probe_grids(num_light_probe_grids=0), 0)
  assert_eq(shader.program_num_light_probes(num_light_probes=2), 2)
  assert_eq(shader.program_num_light_probe_grids(), 0)
}

///|
test "Material shader numClippingPlanes reads the clipping plane count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_clipping_planes(), 0)
  assert_eq(@materials.Material::raw().program_num_clipping_planes(), 0)
  assert_eq(@materials.Material::basic().program_num_clipping_planes(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_clipping_planes(num_clipping_planes=3), 3)
  assert_eq(shader.program_num_clipping_planes(num_clipping_planes=0), 0)
  assert_eq(shader.program_num_light_probe_grids(num_light_probe_grids=2), 2)
  assert_eq(shader.program_num_clipping_planes(), 0)
}

///|
test "Material shader numClipIntersection reads the intersection count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_clip_intersection(), 0)
  assert_eq(@materials.Material::raw().program_num_clip_intersection(), 0)
  assert_eq(@materials.Material::basic().program_num_clip_intersection(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_clip_intersection(num_clip_intersection=2), 2)
  assert_eq(shader.program_num_clip_intersection(num_clip_intersection=0), 0)
  assert_eq(shader.program_num_clipping_planes(num_clipping_planes=3), 3)
  assert_eq(shader.program_num_clip_intersection(), 0)
}

///|
test "Material shader dithering reads the material flag" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_dithering(), false)
  assert_eq(@materials.Material::raw().program_dithering(), false)
  assert_eq(@materials.Material::basic().program_dithering(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.dithering = true
  assert_eq(shader.program_dithering(), true)
  shader.dithering = false
  assert_eq(shader.program_dithering(), false)
  assert_eq(shader.program_num_clip_intersection(num_clip_intersection=2), 2)
  assert_eq(shader.program_dithering(), false)
}

///|
test "Material shader shadowMapEnabled needs the renderer flag and a shadow" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_shadow_map_enabled(), false)
  assert_eq(@materials.Material::raw().program_shadow_map_enabled(), false)
  assert_eq(@materials.Material::basic().program_shadow_map_enabled(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_shadow_map_enabled(shadow_map_enabled=true), false)
  assert_eq(shader.program_shadow_map_enabled(has_shadows=true), false)
  assert_eq(
    shader.program_shadow_map_enabled(shadow_map_enabled=true, has_shadows=true),
    true,
  )
  shader.dithering = true
  assert_eq(shader.program_shadow_map_enabled(), false)
}

///|
test "Material shader shadowMapType reads the renderer type" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_shadow_map_type(), 0)
  assert_eq(@materials.Material::raw().program_shadow_map_type(), 0)
  assert_eq(@materials.Material::basic().program_shadow_map_type(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_shadow_map_type(shadow_map_type=1), 1)
  assert_eq(shader.program_shadow_map_type(shadow_map_type=3), 3)
  assert_eq(
    shader.program_shadow_map_enabled(shadow_map_enabled=true, has_shadows=true),
    true,
  )
  assert_eq(shader.program_shadow_map_type(), 0)
}

///|
test "Material shader toneMapping follows toneMapped and the render target" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_tone_mapping() is @constants.No, true)
  assert_eq(shader.program_tone_mapping().to_int(), 0)
  assert_eq(@materials.Material::raw().program_tone_mapping().to_int(), 0)
  assert_eq(@materials.Material::basic().program_tone_mapping().to_int(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_tone_mapping(tone_mapping=@constants.Linear) is @constants.Linear, true)
  assert_eq(shader.program_tone_mapping(tone_mapping=@constants.Linear).to_int(), 1)
  assert_eq(shader.program_tone_mapping(tone_mapping=@constants.ACES) is @constants.ACES, true)
  assert_eq(shader.program_tone_mapping(tone_mapping=@constants.ACES).to_int(), 4)
  shader.tone_mapped = false
  assert_eq(shader.program_tone_mapping(tone_mapping=@constants.Linear).to_int(), 0)
  shader.tone_mapped = true
  assert_eq(
    shader.program_tone_mapping(tone_mapping=@constants.Linear, has_render_target=true).to_int(),
    0,
  )
  assert_eq(shader.program_shadow_map_type(shadow_map_type=3), 3)
  assert_eq(shader.program_tone_mapping().to_int(), 0)
}

///|
test "Material shader decodeVideoTexture needs a video map in sRGB" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_decode_video_texture(), false)
  assert_eq(@materials.Material::raw().program_decode_video_texture(), false)
  assert_eq(@materials.Material::basic().program_decode_video_texture(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.program_decode_video_texture(video_texture=true, srgb_transfer=true),
    false,
  )
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.program_decode_video_texture(), false)
  assert_eq(shader.program_decode_video_texture(video_texture=true), false)
  assert_eq(shader.program_decode_video_texture(srgb_transfer=true), false)
  assert_eq(
    shader.program_decode_video_texture(video_texture=true, srgb_transfer=true),
    true,
  )
  assert_eq(shader.program_tone_mapping(tone_mapping=@constants.Linear).to_int(), 1)
  assert_eq(shader.program_decode_video_texture(), false)
}

///|
test "Material shader decodeVideoTextureEmissive needs a video emissive map in sRGB" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_decode_video_texture_emissive(), false)
  assert_eq(@materials.Material::raw().program_decode_video_texture_emissive(), false)
  assert_eq(@materials.Material::basic().program_decode_video_texture_emissive(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.program_decode_video_texture_emissive(video_texture=true, srgb_transfer=true),
    false,
  )
  let pixels = FixedArray::make(4, b'\xFF')
  shader.map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(
    shader.program_decode_video_texture(video_texture=true, srgb_transfer=true),
    true,
  )
  assert_eq(
    shader.program_decode_video_texture_emissive(video_texture=true, srgb_transfer=true),
    false,
  )
  shader.emissive_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_decode_video_texture_emissive(), false)
  assert_eq(shader.program_decode_video_texture_emissive(video_texture=true), false)
  assert_eq(shader.program_decode_video_texture_emissive(srgb_transfer=true), false)
  assert_eq(
    shader.program_decode_video_texture_emissive(video_texture=true, srgb_transfer=true),
    true,
  )
}

///|
test "Material shader premultipliedAlpha reads the material flag" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_premultiplied_alpha(), false)
  assert_eq(@materials.Material::raw().program_premultiplied_alpha(), false)
  assert_eq(@materials.Material::basic().program_premultiplied_alpha(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.premultiplied_alpha = true
  assert_eq(shader.program_premultiplied_alpha(), true)
  shader.premultiplied_alpha = false
  assert_eq(shader.program_premultiplied_alpha(), false)
  assert_eq(
    shader.program_decode_video_texture_emissive(video_texture=true, srgb_transfer=true),
    false,
  )
  assert_eq(shader.program_premultiplied_alpha(), false)
}

///|
test "Material shader doubleSided reads Double side" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_double_sided(), false)
  assert_eq(@materials.Material::raw().program_double_sided(), false)
  assert_eq(@materials.Material::basic().program_double_sided(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.side = @constants.Back
  assert_eq(shader.program_double_sided(), false)
  shader.side = @constants.Double
  assert_eq(shader.program_double_sided(), true)
  shader.side = @constants.Front
  assert_eq(shader.program_double_sided(), false)
  shader.premultiplied_alpha = true
  assert_eq(shader.program_double_sided(), false)
}

///|
test "Material shader flipSided reads Back side" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_flip_sided(), false)
  assert_eq(@materials.Material::raw().program_flip_sided(), false)
  assert_eq(@materials.Material::basic().program_flip_sided(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.side = @constants.Front
  assert_eq(shader.program_flip_sided(), false)
  shader.side = @constants.Double
  assert_eq(shader.program_double_sided(), true)
  assert_eq(shader.program_flip_sided(), false)
  shader.side = @constants.Back
  assert_eq(shader.program_flip_sided(), true)
  shader.side = @constants.Front
  assert_eq(shader.program_flip_sided(), false)
}

///|
test "Material shader useDepthPacking is on for a stored packing" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_use_depth_packing(), true)
  assert_eq(@materials.Material::raw().program_use_depth_packing(), true)
  assert_eq(@materials.Material::basic().program_use_depth_packing(), true)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.depth_packing = @constants.DepthPacking::RGBA
  assert_eq(shader.program_use_depth_packing(), true)
  shader.depth_packing = @constants.DepthPacking::Basic
  assert_eq(shader.program_use_depth_packing(), true)
  shader.side = @constants.Back
  assert_eq(shader.program_flip_sided(), true)
  assert_eq(shader.program_use_depth_packing(), true)
}

///|
test "Material shader depthPacking reads the packing integer" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_depth_packing(), 3200)
  assert_eq(@materials.Material::raw().program_depth_packing(), 3200)
  assert_eq(@materials.Material::basic().program_depth_packing(), 3200)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.depth_packing = @constants.DepthPacking::RGBA
  assert_eq(shader.program_depth_packing(), 3201)
  shader.depth_packing = @constants.DepthPacking::RGB
  assert_eq(shader.program_depth_packing(), 3202)
  shader.depth_packing = @constants.DepthPacking::RG
  assert_eq(shader.program_depth_packing(), 3203)
  shader.depth_packing = @constants.DepthPacking::Basic
  assert_eq(shader.program_depth_packing(), 3200)
  shader.side = @constants.Back
  assert_eq(shader.program_use_depth_packing(), true)
  assert_eq(shader.program_depth_packing(), 3200)
}

///|
test "Material shader index0AttributeName reads the attribute name" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_index0_attribute_name(), None)
  assert_eq(@materials.Material::raw().program_index0_attribute_name(), None)
  assert_eq(@materials.Material::basic().program_index0_attribute_name(), None)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.index0_attribute_name = Some("position")
  assert_eq(shader.program_index0_attribute_name(), Some("position"))
  shader.index0_attribute_name = None
  assert_eq(shader.program_index0_attribute_name(), None)
  shader.depth_packing = @constants.DepthPacking::RGBA
  assert_eq(shader.program_depth_packing(), 3201)
  assert_eq(shader.program_index0_attribute_name(), None)
}

///|
test "Material shader extensionClipCullDistance needs the flag and the extension" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_extension_clip_cull_distance(), false)
  assert_eq(@materials.Material::raw().program_extension_clip_cull_distance(), false)
  assert_eq(@materials.Material::basic().program_extension_clip_cull_distance(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.index0_attribute_name = Some("position")
  assert_eq(shader.program_extension_clip_cull_distance(has_extension=true), false)
  shader.index0_attribute_name = None
  assert_eq(shader.program_extension_clip_cull_distance(has_extension=true), false)
  shader.extensions.clip_cull_distance = true
  assert_eq(shader.program_extension_clip_cull_distance(), false)
  assert_eq(shader.program_extension_clip_cull_distance(has_extension=true), true)
  shader.extensions.clip_cull_distance = false
  assert_eq(shader.program_extension_clip_cull_distance(has_extension=true), false)
}

///|
test "Material shader extensionMultiDraw needs the extension and a draw path" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_extension_multi_draw(), false)
  assert_eq(@materials.Material::raw().program_extension_multi_draw(), false)
  assert_eq(@materials.Material::basic().program_extension_multi_draw(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.extensions.clip_cull_distance = true
  assert_eq(shader.program_extension_clip_cull_distance(has_extension=true), true)
  assert_eq(shader.program_extension_multi_draw(has_extension=true), false)
  shader.extensions.clip_cull_distance = false
  assert_eq(shader.program_extension_multi_draw(is_batched_mesh=true), false)
  shader.extensions.multi_draw = true
  assert_eq(shader.program_extension_multi_draw(), false)
  assert_eq(shader.program_extension_multi_draw(has_extension=true), true)
  shader.extensions.multi_draw = false
  assert_eq(
    shader.program_extension_multi_draw(has_extension=true, is_batched_mesh=true),
    true,
  )
  assert_eq(shader.program_extension_multi_draw(has_extension=true), false)
}

///|
test "Material shader rendererExtensionParallelShaderCompile reads the renderer extension" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_renderer_extension_parallel_shader_compile(), false)
  assert_eq(
    @materials.Material::raw().program_renderer_extension_parallel_shader_compile(),
    false,
  )
  assert_eq(
    @materials.Material::basic().program_renderer_extension_parallel_shader_compile(),
    false,
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.program_renderer_extension_parallel_shader_compile(has_extension=true),
    true,
  )
  assert_eq(
    shader.program_renderer_extension_parallel_shader_compile(has_extension=false),
    false,
  )
  assert_eq(
    shader.program_extension_multi_draw(has_extension=true, is_batched_mesh=true),
    true,
  )
  assert_eq(shader.program_renderer_extension_parallel_shader_compile(), false)
}

///|
test "Material shader vertexUv1s reads channel 1" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_vertex_uv1s(), false)
  assert_eq(@materials.Material::raw().program_vertex_uv1s(), false)
  assert_eq(@materials.Material::basic().program_vertex_uv1s(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.program_map_uv(), "uv")
  assert_eq(shader.program_vertex_uv1s(), false)
  map.channel = 2
  shader.map = Some(map)
  assert_eq(shader.program_vertex_uv1s(), false)
  map.channel = 1
  shader.map = Some(map)
  assert_eq(shader.program_map_uv(), "uv1")
  assert_eq(shader.program_vertex_uv1s(), true)
  shader.map = None
  assert_eq(shader.program_vertex_uv1s(), false)
  shader.anisotropy_map = Some(map)
  assert_eq(shader.program_vertex_uv1s(), false)
  shader.anisotropy = 1.0
  assert_eq(shader.program_vertex_uv1s(), true)
  shader.anisotropy = 0.0
  assert_eq(shader.program_vertex_uv1s(), false)
  assert_eq(
    shader.program_custom_program_cache_key(custom_program_cache_key="custom"),
    "custom",
  )
  assert_eq(shader.program_vertex_uv1s(), false)
}

///|
test "Material shader vertexUv2s reads channel 2" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_vertex_uv2s(), false)
  assert_eq(@materials.Material::raw().program_vertex_uv2s(), false)
  assert_eq(@materials.Material::basic().program_vertex_uv2s(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.program_vertex_uv2s(), false)
  map.channel = 1
  shader.map = Some(map)
  assert_eq(shader.program_vertex_uv1s(), true)
  assert_eq(shader.program_vertex_uv2s(), false)
  map.channel = 3
  shader.map = Some(map)
  assert_eq(shader.program_vertex_uv2s(), false)
  map.channel = 2
  shader.map = Some(map)
  assert_eq(shader.program_map_uv(), "uv2")
  assert_eq(shader.program_vertex_uv2s(), true)
  shader.map = None
  assert_eq(shader.program_vertex_uv2s(), false)
  shader.anisotropy_map = Some(map)
  assert_eq(shader.program_vertex_uv2s(), false)
  shader.anisotropy = 1.0
  assert_eq(shader.program_vertex_uv2s(), true)
  shader.anisotropy = 0.0
  assert_eq(shader.program_vertex_uv2s(), false)
  assert_eq(
    shader.program_custom_program_cache_key(custom_program_cache_key="custom"),
    "custom",
  )
  assert_eq(shader.program_vertex_uv2s(), false)
}

///|
test "Material shader vertexUv3s reads channel 3" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_vertex_uv3s(), false)
  assert_eq(@materials.Material::raw().program_vertex_uv3s(), false)
  assert_eq(@materials.Material::basic().program_vertex_uv3s(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.program_vertex_uv3s(), false)
  map.channel = 1
  shader.map = Some(map)
  assert_eq(shader.program_vertex_uv1s(), true)
  assert_eq(shader.program_vertex_uv3s(), false)
  map.channel = 2
  shader.map = Some(map)
  assert_eq(shader.program_vertex_uv2s(), true)
  assert_eq(shader.program_vertex_uv3s(), false)
  map.channel = 4
  shader.map = Some(map)
  assert_eq(shader.program_vertex_uv3s(), false)
  map.channel = 3
  shader.map = Some(map)
  assert_eq(shader.program_map_uv(), "uv3")
  assert_eq(shader.program_vertex_uv3s(), true)
  shader.map = None
  assert_eq(shader.program_vertex_uv3s(), false)
  shader.anisotropy_map = Some(map)
  assert_eq(shader.program_vertex_uv3s(), false)
  shader.anisotropy = 1.0
  assert_eq(shader.program_vertex_uv3s(), true)
  shader.anisotropy = 0.0
  assert_eq(shader.program_vertex_uv3s(), false)
  assert_eq(
    shader.program_custom_program_cache_key(custom_program_cache_key="custom"),
    "custom",
  )
  assert_eq(shader.program_vertex_uv3s(), false)
}

///|
test "Material shader shaderID reads the builtin id" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_shader_id(), None)
  assert_eq(@materials.Material::raw().program_shader_id(), None)
  assert_eq(@materials.Material::basic().program_shader_id(), Some("basic"))
  assert_eq(@materials.Material::lambert().program_shader_id(), Some("lambert"))
  assert_eq(@materials.Material::phong().program_shader_id(), Some("phong"))
  assert_eq(@materials.Material::toon().program_shader_id(), Some("toon"))
  assert_eq(@materials.Material::standard().program_shader_id(), Some("physical"))
  assert_eq(@materials.Material::physical().program_shader_id(), Some("physical"))
  assert_eq(@materials.Material::matcap().program_shader_id(), Some("matcap"))
  assert_eq(@materials.Material::normal().program_shader_id(), Some("normal"))
  assert_eq(@materials.Material::depth().program_shader_id(), Some("depth"))
  assert_eq(@materials.Material::distance().program_shader_id(), Some("distance"))
  assert_eq(@materials.Material::shadow().program_shader_id(), Some("shadow"))
  assert_eq(@materials.PointsMaterial::new().program_shader_id(), Some("points"))
  assert_eq(@materials.SpriteMaterial::new().program_shader_id(), Some("sprite"))
  assert_eq(
    @materials.LineBasicMaterial::new().program_shader_id(),
    Some("basic"),
  )
  assert_eq(
    @materials.LineDashedMaterial::new().program_shader_id(),
    Some("dashed"),
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.name = "renamed"
  assert_eq(shader.shader_type(), "ShaderMaterial")
  assert_eq(shader.program_shader_id(), None)
  let basic = @materials.Material::basic()
  basic.name = "renamed"
  assert_eq(basic.shader_type(), "MeshBasicMaterial")
  assert_eq(basic.program_shader_id(), Some("basic"))
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  map.channel = 3
  shader.map = Some(map)
  assert_eq(shader.program_vertex_uv3s(), true)
  assert_eq(shader.program_shader_id(), None)
}

