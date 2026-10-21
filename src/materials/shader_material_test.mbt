///|
test "Material shader sets isShaderMaterial" {
  let basic = @materials.Material::basic()
  let lambert = @materials.Material::lambert()
  let standard = @materials.Material::standard()
  let physical = @materials.Material::physical()
  let toon = @materials.Material::toon()
  let matcap = @materials.Material::matcap()
  let normal = @materials.Material::normal()
  let depth = @materials.Material::depth()
  let distance = @materials.Material::distance()
  let phong = @materials.Material::phong()
  let shadow = @materials.Material::shadow()
  assert_eq(basic.is_shader_material, false)
  assert_eq(lambert.is_shader_material, false)
  assert_eq(standard.is_shader_material, false)
  assert_eq(physical.is_shader_material, false)
  assert_eq(toon.is_shader_material, false)
  assert_eq(matcap.is_shader_material, false)
  assert_eq(normal.is_shader_material, false)
  assert_eq(depth.is_shader_material, false)
  assert_eq(distance.is_shader_material, false)
  assert_eq(phong.is_shader_material, false)
  assert_eq(shadow.is_shader_material, false)
  let shader = @materials.Material::shader()
  assert_eq(shader.is_shader_material, true)
  assert_eq(shader.is_shadow_material, false)
  assert_eq(shader.type_name, "ShaderMaterial")
  assert_eq(shader.kind is @materials.MaterialKind::Shader, true)
  assert_eq(shader.shading() is @constants.Basic, true)
  assert_eq(shader.color.get_hex(), 0xFFFFFF)
  assert_eq(shader.transparent, false)
  assert_eq(shader.fog, false)
  match shader.defines.get("FOO") {
    None => ()
    Some(_) => abort("shader defines should start empty")
  }
  let destination = @materials.Material::basic()
  ignore(destination.copy(shader))
  assert_eq(destination.is_shader_material, false)
  assert_eq(destination.kind is @materials.MaterialKind::Basic, true)
  assert_eq(destination.type_name, "MeshBasicMaterial")
  assert_eq(shader.is_shader_material, true)
  let onto = @materials.Material::shader()
  onto.defines.set("FOO", "1")
  let green = @materials.Material::phong(hex=0x00FF00)
  ignore(onto.copy(green))
  assert_eq(onto.is_shader_material, true)
  assert_eq(onto.kind is @materials.MaterialKind::Shader, true)
  assert_eq(onto.color.r, 0.0)
  assert_eq(onto.color.g, 1.0)
  match onto.defines.get("FOO") {
    None => ()
    Some(_) => abort("shader copy kept define missing from source")
  }
  let cloned = shader.clone()
  assert_eq(cloned.is_shader_material, true)
  assert_eq(cloned.type_name, "ShaderMaterial")
  assert_eq(cloned.kind is @materials.MaterialKind::Shader, true)
  assert_eq(cloned.color.get_hex(), 0xFFFFFF)
  assert_eq(cloned.id == shader.id, false)
}

///|
test "Material shader copies defines" {
  let source = @materials.Material::shader()
  source.defines.set("FOO", "1")
  source.defines.set("BAR", "2")
  let onto = @materials.Material::shader()
  onto.defines.set("FOO", "9")
  onto.defines.set("BAZ", "3")
  ignore(onto.copy(source))
  match onto.defines.get("FOO") {
    None => abort("shader copy dropped FOO")
    Some(value) => assert_eq(value, "1")
  }
  match onto.defines.get("BAR") {
    None => abort("shader copy dropped BAR")
    Some(value) => assert_eq(value, "2")
  }
  match onto.defines.get("BAZ") {
    None => ()
    Some(_) => abort("shader copy kept destination define")
  }
  onto.defines.set("FOO", "7")
  match source.defines.get("FOO") {
    None => abort("source lost FOO")
    Some(value) => assert_eq(value, "1")
  }
  let basic = @materials.Material::basic()
  basic.defines.set("KEEP", "4")
  ignore(basic.copy(source))
  match basic.defines.get("FOO") {
    None => ()
    Some(_) => abort("basic copy gained shader define")
  }
  match basic.defines.get("KEEP") {
    None => abort("basic copy dropped define")
    Some(value) => assert_eq(value, "4")
  }
  let cleared = @materials.Material::shader()
  cleared.defines.set("FOO", "1")
  ignore(cleared.copy(@materials.Material::phong()))
  match cleared.defines.get("FOO") {
    None => ()
    Some(_) => abort("shader copy kept define missing from source")
  }
  let cloned = source.clone()
  match cloned.defines.get("FOO") {
    None => abort("clone dropped FOO")
    Some(value) => assert_eq(value, "1")
  }
  match cloned.defines.get("BAR") {
    None => abort("clone dropped BAR")
    Some(value) => assert_eq(value, "2")
  }
  cloned.defines.set("FOO", "8")
  match source.defines.get("FOO") {
    None => abort("clone wrote source")
    Some(value) => assert_eq(value, "1")
  }
}

///|
test "Material shader defaults fog off" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  assert_eq(shader.fog, false)
  assert_eq(basic.fog, true)
  ignore(basic.copy(shader))
  assert_eq(basic.fog, false)
  assert_eq(shader.fog, false)
  let onto = @materials.Material::shader()
  let phong = @materials.Material::phong()
  assert_eq(phong.fog, true)
  ignore(onto.copy(phong))
  assert_eq(onto.fog, true)
  onto.fog = false
  assert_eq(phong.fog, true)
  let cloned = shader.clone()
  assert_eq(cloned.fog, false)
  assert_eq(cloned.id == shader.id, false)
}

///|
test "Material shader defaults lights off and copies only onto shader" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  assert_eq(shader.lights, false)
  assert_eq(basic.lights, false)
  assert_eq(phong.lights, false)
  shader.lights = true
  ignore(basic.copy(shader))
  assert_eq(basic.lights, false)
  assert_eq(shader.lights, true)
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  assert_eq(onto.lights, true)
  onto.lights = false
  assert_eq(shader.lights, true)
  ignore(onto.copy(phong))
  assert_eq(onto.lights, false)
  assert_eq(phong.lights, false)
  let cloned = shader.clone()
  assert_eq(cloned.lights, true)
  assert_eq(cloned.id == shader.id, false)
  cloned.lights = false
  assert_eq(shader.lights, true)
}

///|
test "Material shader defaults clipping off and copies only onto shader" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  assert_eq(shader.clipping, false)
  assert_eq(basic.clipping, false)
  assert_eq(phong.clipping, false)
  shader.clipping = true
  ignore(basic.copy(shader))
  assert_eq(basic.clipping, false)
  assert_eq(shader.clipping, true)
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  assert_eq(onto.clipping, true)
  onto.clipping = false
  assert_eq(shader.clipping, true)
  ignore(onto.copy(phong))
  assert_eq(onto.clipping, false)
  assert_eq(phong.clipping, false)
  let cloned = shader.clone()
  assert_eq(cloned.clipping, true)
  assert_eq(cloned.id == shader.id, false)
  cloned.clipping = false
  assert_eq(shader.clipping, true)
}

///|
test "Material shader stores the default vertex shader" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  let expected = "\nvoid main() {\n\tgl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );\n}\n"
  assert_eq(shader.vertex_shader, expected)
  assert_eq(basic.vertex_shader, "")
  assert_eq(phong.vertex_shader, "")
  shader.vertex_shader = "void main() {}"
  ignore(basic.copy(shader))
  assert_eq(basic.vertex_shader, "")
  assert_eq(shader.vertex_shader, "void main() {}")
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  assert_eq(onto.vertex_shader, "void main() {}")
  onto.vertex_shader = "changed"
  assert_eq(shader.vertex_shader, "void main() {}")
  ignore(onto.copy(phong))
  assert_eq(onto.vertex_shader, "")
  assert_eq(phong.vertex_shader, "")
  let cloned = shader.clone()
  assert_eq(cloned.vertex_shader, "void main() {}")
  assert_eq(cloned.id == shader.id, false)
  cloned.vertex_shader = "clone"
  assert_eq(shader.vertex_shader, "void main() {}")
}

///|
test "Material shader stores the default fragment shader" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  let expected = "\nvoid main() {\n\tgl_FragColor = vec4( 1.0, 0.0, 0.0, 1.0 );\n}\n"
  assert_eq(shader.fragment_shader, expected)
  assert_eq(basic.fragment_shader, "")
  assert_eq(phong.fragment_shader, "")
  shader.fragment_shader = "void main() {}"
  ignore(basic.copy(shader))
  assert_eq(basic.fragment_shader, "")
  assert_eq(shader.fragment_shader, "void main() {}")
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  assert_eq(onto.fragment_shader, "void main() {}")
  onto.fragment_shader = "changed"
  assert_eq(shader.fragment_shader, "void main() {}")
  ignore(onto.copy(phong))
  assert_eq(onto.fragment_shader, "")
  assert_eq(phong.fragment_shader, "")
  let cloned = shader.clone()
  assert_eq(cloned.fragment_shader, "void main() {}")
  assert_eq(cloned.id == shader.id, false)
  cloned.fragment_shader = "clone"
  assert_eq(shader.fragment_shader, "void main() {}")
}

///|
test "Material shader copies numeric uniforms" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  match shader.uniforms.get("time") {
    None => ()
    Some(_) => abort("shader uniforms should start empty")
  }
  match basic.uniforms.get("time") {
    None => ()
    Some(_) => abort("basic uniforms should start empty")
  }
  match phong.uniforms.get("time") {
    None => ()
    Some(_) => abort("phong uniforms should start empty")
  }
  shader.uniforms.set("time", 1.0)
  shader.uniforms.set("scale", 2.0)
  ignore(basic.copy(shader))
  match basic.uniforms.get("time") {
    None => ()
    Some(_) => abort("basic copy gained shader uniform")
  }
  assert_eq(shader.uniforms.get("time"), Some(1.0))
  let onto = @materials.Material::shader()
  onto.uniforms.set("time", 9.0)
  onto.uniforms.set("extra", 3.0)
  ignore(onto.copy(shader))
  assert_eq(onto.uniforms.get("time"), Some(1.0))
  assert_eq(onto.uniforms.get("scale"), Some(2.0))
  match onto.uniforms.get("extra") {
    None => ()
    Some(_) => abort("shader copy kept destination uniform")
  }
  onto.uniforms.set("time", 7.0)
  assert_eq(shader.uniforms.get("time"), Some(1.0))
  ignore(onto.copy(phong))
  match onto.uniforms.get("time") {
    None => ()
    Some(_) => abort("shader copy kept uniform missing from source")
  }
  let cloned = shader.clone()
  assert_eq(cloned.uniforms.get("time"), Some(1.0))
  assert_eq(cloned.uniforms.get("scale"), Some(2.0))
  assert_eq(cloned.id == shader.id, false)
  cloned.uniforms.set("time", 8.0)
  assert_eq(shader.uniforms.get("time"), Some(1.0))
}

///|
test "Material shader copies uniforms groups" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  assert_eq(shader.uniforms_groups.length(), 0)
  assert_eq(basic.uniforms_groups.length(), 0)
  assert_eq(phong.uniforms_groups.length(), 0)
  let frame = @materials.UniformsGroup::new(name="Frame")
  assert_eq(frame.name, "Frame")
  assert_eq(frame.usage, 35044)
  shader.uniforms_groups.push(frame)
  let other = @materials.UniformsGroup::new(name="Other")
  other.usage = 35048
  shader.uniforms_groups.push(other)
  ignore(basic.copy(shader))
  assert_eq(basic.uniforms_groups.length(), 0)
  assert_eq(shader.uniforms_groups[0].name, "Frame")
  let onto = @materials.Material::shader()
  onto.uniforms_groups.push(@materials.UniformsGroup::new(name="Drop"))
  ignore(onto.copy(shader))
  assert_eq(onto.uniforms_groups.length(), 2)
  assert_eq(onto.uniforms_groups[0].name, "Frame")
  assert_eq(onto.uniforms_groups[0].usage, 35044)
  assert_eq(onto.uniforms_groups[0].id == shader.uniforms_groups[0].id, false)
  assert_eq(onto.uniforms_groups[1].name, "Other")
  assert_eq(onto.uniforms_groups[1].usage, 35048)
  onto.uniforms_groups[0].name = "Renamed"
  assert_eq(onto.uniforms_groups[0].name, "Renamed")
  assert_eq(shader.uniforms_groups[0].name, "Frame")
  ignore(onto.copy(phong))
  assert_eq(onto.uniforms_groups.length(), 0)
  let cloned = shader.clone()
  assert_eq(cloned.uniforms_groups.length(), 2)
  assert_eq(cloned.uniforms_groups[0].name, "Frame")
  assert_eq(cloned.uniforms_groups[1].usage, 35048)
  assert_eq(cloned.uniforms_groups[0].id == shader.uniforms_groups[0].id, false)
  cloned.uniforms_groups[0].name = "Clone"
  assert_eq(cloned.uniforms_groups[0].name, "Clone")
  assert_eq(shader.uniforms_groups[0].name, "Frame")
}

///|
test "Material shader keeps its own linewidth on copy" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  assert_eq(shader.linewidth, 1.0)
  assert_eq(basic.linewidth, 1.0)
  assert_eq(phong.linewidth, 1.0)
  assert_eq(shader.wireframe_linewidth, 1.0)
  shader.linewidth = 4.0
  shader.wireframe_linewidth = 5.0
  ignore(basic.copy(shader))
  assert_eq(basic.linewidth, 1.0)
  assert_eq(basic.wireframe_linewidth, 5.0)
  assert_eq(shader.linewidth, 4.0)
  let onto = @materials.Material::shader()
  onto.linewidth = 3.0
  ignore(onto.copy(shader))
  assert_eq(onto.linewidth, 3.0)
  assert_eq(shader.linewidth, 4.0)
  let cloned = shader.clone()
  assert_eq(cloned.linewidth, 1.0)
  assert_eq(cloned.id == shader.id, false)
  assert_eq(shader.linewidth, 4.0)
}

///|
test "Material shader defaults forceSinglePass on" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  assert_eq(shader.force_single_pass, true)
  assert_eq(basic.force_single_pass, false)
  assert_eq(phong.force_single_pass, false)
  ignore(basic.copy(shader))
  assert_eq(basic.force_single_pass, true)
  assert_eq(shader.force_single_pass, true)
  basic.force_single_pass = false
  assert_eq(shader.force_single_pass, true)
  let onto = @materials.Material::shader()
  ignore(onto.copy(phong))
  assert_eq(onto.force_single_pass, false)
  assert_eq(phong.force_single_pass, false)
  let cloned = shader.clone()
  assert_eq(cloned.force_single_pass, true)
  assert_eq(cloned.id == shader.id, false)
}

///|
test "Material shader copies extensions only onto shader" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  assert_eq(shader.extensions.clip_cull_distance, false)
  assert_eq(shader.extensions.multi_draw, false)
  assert_eq(basic.extensions.clip_cull_distance, false)
  assert_eq(basic.extensions.multi_draw, false)
  assert_eq(phong.extensions.clip_cull_distance, false)
  assert_eq(phong.extensions.multi_draw, false)
  shader.extensions.clip_cull_distance = true
  shader.extensions.multi_draw = true
  ignore(basic.copy(shader))
  assert_eq(basic.extensions.clip_cull_distance, false)
  assert_eq(basic.extensions.multi_draw, false)
  assert_eq(shader.extensions.clip_cull_distance, true)
  assert_eq(shader.extensions.multi_draw, true)
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  assert_eq(onto.extensions.clip_cull_distance, true)
  assert_eq(onto.extensions.multi_draw, true)
  onto.extensions.clip_cull_distance = false
  assert_eq(shader.extensions.clip_cull_distance, true)
  ignore(onto.copy(phong))
  assert_eq(onto.extensions.clip_cull_distance, false)
  assert_eq(onto.extensions.multi_draw, false)
  let cloned = shader.clone()
  assert_eq(cloned.extensions.clip_cull_distance, true)
  assert_eq(cloned.extensions.multi_draw, true)
  assert_eq(cloned.id == shader.id, false)
  cloned.extensions.multi_draw = false
  assert_eq(shader.extensions.multi_draw, true)
}

///|
test "Material shader copies default attribute values only onto shader" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  assert_eq(shader.default_attribute_values.get("color"), Some([1.0, 1.0, 1.0]))
  assert_eq(shader.default_attribute_values.get("uv"), Some([0.0, 0.0]))
  assert_eq(shader.default_attribute_values.get("uv1"), Some([0.0, 0.0]))
  match basic.default_attribute_values.get("color") {
    None => ()
    Some(_) => abort("basic default attributes should start empty")
  }
  match phong.default_attribute_values.get("color") {
    None => ()
    Some(_) => abort("phong default attributes should start empty")
  }
  shader.default_attribute_values.set("color", [2.0, 3.0, 4.0])
  shader.default_attribute_values.set("tangent", [5.0])
  ignore(basic.copy(shader))
  match basic.default_attribute_values.get("color") {
    None => ()
    Some(_) => abort("basic copy gained shader default attributes")
  }
  assert_eq(shader.default_attribute_values.get("color"), Some([2.0, 3.0, 4.0]))
  let onto = @materials.Material::shader()
  onto.default_attribute_values.set("color", [9.0, 9.0, 9.0])
  onto.default_attribute_values.set("drop", [1.0])
  ignore(onto.copy(shader))
  assert_eq(onto.default_attribute_values.get("color"), Some([2.0, 3.0, 4.0]))
  assert_eq(onto.default_attribute_values.get("uv"), Some([0.0, 0.0]))
  assert_eq(onto.default_attribute_values.get("uv1"), Some([0.0, 0.0]))
  assert_eq(onto.default_attribute_values.get("tangent"), Some([5.0]))
  match onto.default_attribute_values.get("drop") {
    None => ()
    Some(_) => abort("shader copy kept destination default attribute")
  }
  onto.default_attribute_values.get("color").unwrap()[0] = 8.0
  assert_eq(onto.default_attribute_values.get("color"), Some([8.0, 3.0, 4.0]))
  assert_eq(shader.default_attribute_values.get("color"), Some([2.0, 3.0, 4.0]))
  ignore(onto.copy(phong))
  match onto.default_attribute_values.get("color") {
    None => ()
    Some(_) => abort("shader copy kept default attribute missing from source")
  }
  let cloned = shader.clone()
  assert_eq(cloned.default_attribute_values.get("color"), Some([2.0, 3.0, 4.0]))
  assert_eq(cloned.default_attribute_values.get("uv"), Some([0.0, 0.0]))
  assert_eq(cloned.id == shader.id, false)
  cloned.default_attribute_values.get("color").unwrap()[0] = 6.0
  assert_eq(shader.default_attribute_values.get("color"), Some([2.0, 3.0, 4.0]))
}

///|
test "Material shader copies glslVersion only onto shader" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  assert_eq(shader.glsl_version is None, true)
  assert_eq(basic.glsl_version is None, true)
  assert_eq(phong.glsl_version is None, true)
  assert_eq(@materials.GlslVersion::GLSL1.code(), "100")
  assert_eq(@materials.GlslVersion::GLSL3.code(), "300 es")
  shader.glsl_version = Some(@materials.GlslVersion::GLSL3)
  ignore(basic.copy(shader))
  assert_eq(basic.glsl_version is None, true)
  assert_eq(shader.glsl_version is Some(@materials.GlslVersion::GLSL3), true)
  let onto = @materials.Material::shader()
  onto.glsl_version = Some(@materials.GlslVersion::GLSL1)
  ignore(onto.copy(shader))
  assert_eq(onto.glsl_version is Some(@materials.GlslVersion::GLSL3), true)
  onto.glsl_version = None
  assert_eq(shader.glsl_version is Some(@materials.GlslVersion::GLSL3), true)
  ignore(onto.copy(phong))
  assert_eq(onto.glsl_version is None, true)
  let cloned = shader.clone()
  assert_eq(cloned.glsl_version is Some(@materials.GlslVersion::GLSL3), true)
  assert_eq(cloned.id == shader.id, false)
  cloned.glsl_version = Some(@materials.GlslVersion::GLSL1)
  assert_eq(shader.glsl_version is Some(@materials.GlslVersion::GLSL3), true)
}

///|
test "Material shader copies index0AttributeName only onto shader" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  assert_eq(shader.index0_attribute_name is None, true)
  assert_eq(basic.index0_attribute_name is None, true)
  assert_eq(phong.index0_attribute_name is None, true)
  shader.index0_attribute_name = Some("position")
  ignore(basic.copy(shader))
  assert_eq(basic.index0_attribute_name is None, true)
  assert_eq(shader.index0_attribute_name, Some("position"))
  let onto = @materials.Material::shader()
  onto.index0_attribute_name = Some("normal")
  ignore(onto.copy(shader))
  assert_eq(onto.index0_attribute_name, Some("position"))
  onto.index0_attribute_name = Some("changed")
  assert_eq(shader.index0_attribute_name, Some("position"))
  ignore(onto.copy(phong))
  assert_eq(onto.index0_attribute_name is None, true)
  let cloned = shader.clone()
  assert_eq(cloned.index0_attribute_name, Some("position"))
  assert_eq(cloned.id == shader.id, false)
  cloned.index0_attribute_name = Some("uv")
  assert_eq(shader.index0_attribute_name, Some("position"))
}

///|
test "Material shader copies uniformsNeedUpdate only onto shader" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  assert_eq(shader.uniforms_need_update, false)
  assert_eq(basic.uniforms_need_update, false)
  assert_eq(phong.uniforms_need_update, false)
  shader.uniforms_need_update = true
  ignore(basic.copy(shader))
  assert_eq(basic.uniforms_need_update, false)
  assert_eq(shader.uniforms_need_update, true)
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  assert_eq(onto.uniforms_need_update, true)
  onto.uniforms_need_update = false
  assert_eq(shader.uniforms_need_update, true)
  ignore(onto.copy(phong))
  assert_eq(onto.uniforms_need_update, false)
  let cloned = shader.clone()
  assert_eq(cloned.uniforms_need_update, true)
  assert_eq(cloned.id == shader.id, false)
  cloned.uniforms_need_update = false
  assert_eq(shader.uniforms_need_update, true)
}
