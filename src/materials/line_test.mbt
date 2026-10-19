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

///|
test "LineBasicMaterial.copy writes color and shares the map" {
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  let source = @materials.LineBasicMaterial::new(hex=0x00FF00)
  source.map = Some(map)
  source.opacity = 0.25
  source.transparent = true
  source.fog = false
  source.depth_write = false
  source.depth_test = false
  source.depth_func = @constants.DepthFunc::Greater
  source.color_write = false
  source.premultiplied_alpha = true
  source.visible = false
  let destination = @materials.LineBasicMaterial::new()
  let color = destination.color
  let copied = destination.copy(source)
  assert_eq(physical_equal(copied, destination), true)
  assert_eq(physical_equal(destination.color, color), true)
  assert_eq(destination.color.r, 0.0)
  assert_eq(destination.color.g, 1.0)
  assert_eq(destination.color.b, 0.0)
  assert_eq(destination.opacity, 0.25)
  assert_eq(destination.transparent, true)
  assert_eq(destination.fog, false)
  assert_eq(destination.depth_write, false)
  assert_eq(destination.depth_test, false)
  assert_eq(destination.depth_func.to_int(), 6)
  assert_eq(destination.color_write, false)
  assert_eq(destination.premultiplied_alpha, true)
  assert_eq(destination.visible, false)
  match destination.map {
    None => assert_eq(false, true)
    Some(stored) => assert_eq(physical_equal(stored, map), true)
  }
  destination.color.g = 0.5
  assert_eq(source.color.g, 1.0)
  assert_eq(source.opacity, 0.25)
}
