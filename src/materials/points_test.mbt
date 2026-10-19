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

///|
test "PointsMaterial.copy writes color and shares maps" {
  let color_pixels = FixedArray::make(4, b'\xFF')
  let color_map = @textures.Texture::from_rgba8(1, 1, color_pixels)
  let alpha_pixels = FixedArray::make(4, b'\x00')
  alpha_pixels[1] = b'\x80'
  let alpha_map = @textures.Texture::from_rgba8(1, 1, alpha_pixels)
  let source = @materials.PointsMaterial::new(
    hex=0xFF0000,
    size=4.0,
    size_attenuation=false,
  )
  source.map = Some(color_map)
  source.alpha_map = Some(alpha_map)
  source.opacity = 0.25
  source.transparent = true
  source.fog = false
  source.depth_write = false
  source.depth_test = false
  source.depth_func = @constants.DepthFunc::Greater
  source.color_write = false
  source.premultiplied_alpha = true
  source.visible = false
  let destination = @materials.PointsMaterial::new()
  let color = destination.color
  let copied = destination.copy(source)
  assert_eq(physical_equal(copied, destination), true)
  assert_eq(physical_equal(destination.color, color), true)
  assert_eq(destination.color.r, 1.0)
  assert_eq(destination.color.g, 0.0)
  assert_eq(destination.color.b, 0.0)
  assert_eq(destination.size, 4.0)
  assert_eq(destination.size_attenuation, false)
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
    Some(stored) => assert_eq(physical_equal(stored, color_map), true)
  }
  match destination.alpha_map {
    None => assert_eq(false, true)
    Some(stored) => {
      assert_eq(physical_equal(stored, alpha_map), true)
      assert_eq(stored.data[1], b'\x80')
    }
  }
  destination.color.r = 0.5
  destination.size = 8.0
  assert_eq(source.color.r, 1.0)
  assert_eq(source.size, 4.0)
  assert_eq(source.opacity, 0.25)
}

///|
test "PointsMaterial stores and copies alphaTest" {
  let defaults = @materials.PointsMaterial::new()
  assert_eq(defaults.alpha_test, 0.0)
  let source = @materials.PointsMaterial::new()
  source.alpha_test = 0.4
  assert_eq(defaults.alpha_test, 0.0)
  let destination = @materials.PointsMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.alpha_test, 0.4)
  destination.alpha_test = 0.8
  assert_eq(source.alpha_test, 0.4)
}

///|
test "PointsMaterial stores and copies vertex colors" {
  let defaults = @materials.PointsMaterial::new()
  assert_eq(defaults.vertex_colors, false)
  let source = @materials.PointsMaterial::new()
  source.vertex_colors = true
  assert_eq(defaults.vertex_colors, false)
  let destination = @materials.PointsMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.vertex_colors, true)
  destination.vertex_colors = false
  assert_eq(source.vertex_colors, true)
}

///|
test "PointsMaterial stores and copies toneMapped" {
  let defaults = @materials.PointsMaterial::new()
  assert_eq(defaults.tone_mapped, true)
  let source = @materials.PointsMaterial::new()
  source.tone_mapped = false
  assert_eq(defaults.tone_mapped, true)
  let destination = @materials.PointsMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.tone_mapped, false)
  destination.tone_mapped = true
  assert_eq(source.tone_mapped, false)
}
