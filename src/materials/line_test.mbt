///|
test "LineBasicMaterial stores a color map" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.map is None, true)
  assert_eq(defaults.color.r, 1.0)
  assert_eq(defaults.opacity, 1.0)
  assert_eq(defaults.fog, true)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  let material = @materials.LineBasicMaterial::new(hex=0x00FF00)
  material.map = Some(map)
  assert_eq(material.color.r, 0.0)
  assert_eq(material.color.g, 1.0)
  assert_eq(material.color.b, 0.0)
  match material.map {
    None => assert_eq(false, true)
    Some(stored) => {
      assert_eq(physical_equal(stored, map), true)
      assert_eq(stored.width, 1)
      assert_eq(stored.height, 1)
    }
  }
  assert_eq(defaults.map is None, true)
  assert_eq(defaults.color.g, 1.0)
}
