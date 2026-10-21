///|
test "Material raw sets isRawShaderMaterial" {
  let basic = @materials.Material::basic()
  let shader = @materials.Material::shader()
  let raw = @materials.Material::raw()
  assert_eq(basic.is_raw_shader_material, false)
  assert_eq(basic.is_shader_material, false)
  assert_eq(shader.is_raw_shader_material, false)
  assert_eq(shader.is_shader_material, true)
  assert_eq(shader.type_name, "ShaderMaterial")
  assert_eq(raw.is_shader_material, true)
  assert_eq(raw.is_raw_shader_material, true)
  assert_eq(raw.type_name, "RawShaderMaterial")
  assert_eq(raw.kind is @materials.MaterialKind::Raw, true)
  assert_eq(raw.shading() is @constants.Basic, true)
  assert_eq(raw.linewidth, 1.0)
  assert_eq(raw.fog, false)
  assert_eq(raw.lights, false)
  raw.lights = true
  raw.defines.set("FOO", "1")
  let onto_basic = @materials.Material::basic()
  ignore(onto_basic.copy(raw))
  assert_eq(onto_basic.is_raw_shader_material, false)
  assert_eq(onto_basic.lights, false)
  let onto_shader = @materials.Material::shader()
  ignore(onto_shader.copy(raw))
  assert_eq(onto_shader.is_raw_shader_material, false)
  assert_eq(onto_shader.is_shader_material, true)
  assert_eq(onto_shader.kind is @materials.MaterialKind::Shader, true)
  assert_eq(onto_shader.type_name, "ShaderMaterial")
  assert_eq(onto_shader.lights, true)
  match onto_shader.defines.get("FOO") {
    None => abort("raw copy onto shader dropped FOO")
    Some(value) => assert_eq(value, "1")
  }
  let onto_raw = @materials.Material::raw()
  onto_raw.lights = true
  onto_raw.defines.set("KEEP", "9")
  let green = @materials.Material::shader(hex=0x00FF00)
  green.lights = false
  ignore(onto_raw.copy(green))
  assert_eq(onto_raw.is_raw_shader_material, true)
  assert_eq(onto_raw.is_shader_material, true)
  assert_eq(onto_raw.kind is @materials.MaterialKind::Raw, true)
  assert_eq(onto_raw.type_name, "RawShaderMaterial")
  assert_eq(onto_raw.lights, false)
  assert_eq(onto_raw.color.g, 1.0)
  match onto_raw.defines.get("KEEP") {
    None => ()
    Some(_) => abort("raw copy kept define missing from source")
  }
  let cloned = raw.clone()
  assert_eq(cloned.is_raw_shader_material, true)
  assert_eq(cloned.is_shader_material, true)
  assert_eq(cloned.type_name, "RawShaderMaterial")
  assert_eq(cloned.kind is @materials.MaterialKind::Raw, true)
  assert_eq(cloned.lights, true)
  assert_eq(cloned.id == raw.id, false)
  match cloned.defines.get("FOO") {
    None => abort("raw clone dropped FOO")
    Some(value) => assert_eq(value, "1")
  }
}
