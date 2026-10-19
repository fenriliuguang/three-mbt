///|
test "PointsMaterial stores a color map" {
  let defaults = @materials.PointsMaterial::new()
  assert_eq(defaults.map is None, true)
  assert_eq(defaults.size, 1.0)
  assert_eq(defaults.size_attenuation, true)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  let material = @materials.PointsMaterial::new(hex=0xFF0000, size=4.0)
  material.map = Some(map)
  assert_eq(material.color.r, 1.0)
  assert_eq(material.color.g, 0.0)
  assert_eq(material.color.b, 0.0)
  assert_eq(material.size, 4.0)
  match material.map {
    None => assert_eq(false, true)
    Some(stored) => {
      assert_eq(physical_equal(stored, map), true)
      assert_eq(stored.width, 1)
      assert_eq(stored.height, 1)
    }
  }
  assert_eq(defaults.map is None, true)
  assert_eq(defaults.size, 1.0)
}

///|
test "PointsMaterial stores an alpha map" {
  let defaults = @materials.PointsMaterial::new()
  assert_eq(defaults.alpha_map is None, true)
  assert_eq(defaults.fog, true)
  let pixels = FixedArray::make(4, b'\x00')
  pixels[1] = b'\x80'
  let alpha = @textures.Texture::from_rgba8(1, 1, pixels)
  let material = @materials.PointsMaterial::new()
  material.alpha_map = Some(alpha)
  assert_eq(material.fog, true)
  match material.alpha_map {
    None => assert_eq(false, true)
    Some(stored) => {
      assert_eq(physical_equal(stored, alpha), true)
      assert_eq(stored.width, 1)
      assert_eq(stored.data[1], b'\x80')
    }
  }
  assert_eq(defaults.alpha_map is None, true)
  assert_eq(defaults.fog, true)
}
