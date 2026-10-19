///|
test "Material vertex colors default off" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.vertex_colors, false)
  basic.material.vertex_colors = true
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.vertex_colors, false)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.vertex_colors, false)
  standard.material.vertex_colors = true
  let other = @materials.Material::basic()
  assert_eq(other.vertex_colors, false)
  assert_eq(basic.material.vertex_colors, true)
  assert_eq(standard.material.vertex_colors, true)
}

///|
test "Material toneMapped defaults on" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.tone_mapped, true)
  basic.material.tone_mapped = false
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.tone_mapped, true)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.tone_mapped, true)
  standard.material.tone_mapped = false
  let other = @materials.Material::basic()
  assert_eq(other.tone_mapped, true)
  assert_eq(basic.material.tone_mapped, false)
  assert_eq(standard.material.tone_mapped, false)
}
