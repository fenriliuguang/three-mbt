///|
test "SpriteMaterial stores color, map, and transparency" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.color.r, 1.0)
  assert_eq(defaults.color.g, 1.0)
  assert_eq(defaults.color.b, 1.0)
  assert_eq(defaults.map is None, true)
  assert_eq(defaults.opacity, 1.0)
  assert_eq(defaults.transparent, true)
  assert_eq(defaults.rotation, 0.0)
  assert_eq(defaults.size_attenuation, true)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  let material = @materials.SpriteMaterial::new(
    hex=0xFF0000,
    opacity=0.25,
    transparent=false,
  )
  material.map = Some(map)
  assert_eq(material.color.r, 1.0)
  assert_eq(material.color.g, 0.0)
  assert_eq(material.color.b, 0.0)
  assert_eq(material.opacity, 0.25)
  assert_eq(material.transparent, false)
  match material.map {
    None => assert_eq(false, true)
    Some(stored) => {
      assert_eq(physical_equal(stored, map), true)
      assert_eq(stored.width, 1)
      assert_eq(stored.height, 1)
    }
  }
  material.color.r = 0.5
  assert_eq(material.color.r, 0.5)
  assert_eq(defaults.color.r, 1.0)
  assert_eq(defaults.opacity, 1.0)
}
