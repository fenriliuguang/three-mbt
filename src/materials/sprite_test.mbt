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

///|
test "SpriteMaterial stores alpha map and fog" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.fog, true)
  assert_eq(defaults.alpha_map is None, true)
  let pixels = FixedArray::make(4, b'\x00')
  pixels[1] = b'\x80'
  let alpha = @textures.Texture::from_rgba8(1, 1, pixels)
  let material = @materials.SpriteMaterial::new(fog=false)
  material.alpha_map = Some(alpha)
  assert_eq(material.fog, false)
  match material.alpha_map {
    None => assert_eq(false, true)
    Some(stored) => {
      assert_eq(physical_equal(stored, alpha), true)
      assert_eq(stored.width, 1)
      assert_eq(stored.data[1], b'\x80')
    }
  }
  assert_eq(defaults.fog, true)
  assert_eq(defaults.alpha_map is None, true)
}

///|
test "SpriteMaterial.copy writes color and shares maps" {
  let color_pixels = FixedArray::make(4, b'\xFF')
  let color_map = @textures.Texture::from_rgba8(1, 1, color_pixels)
  let alpha_pixels = FixedArray::make(4, b'\x00')
  alpha_pixels[1] = b'\x80'
  let alpha_map = @textures.Texture::from_rgba8(1, 1, alpha_pixels)
  let source = @materials.SpriteMaterial::new(
    rotation=0.5,
    size_attenuation=false,
    hex=0xFF0000,
    opacity=0.25,
    transparent=false,
    fog=false,
  )
  source.map = Some(color_map)
  source.alpha_map = Some(alpha_map)
  source.depth_write = false
  source.depth_test = false
  source.depth_func = @constants.DepthFunc::Greater
  source.color_write = false
  source.premultiplied_alpha = true
  source.visible = false
  let destination = @materials.SpriteMaterial::new()
  assert_eq(destination.depth_write, true)
  assert_eq(destination.depth_test, true)
  assert_eq(destination.depth_func.to_int(), 3)
  assert_eq(destination.color_write, true)
  assert_eq(destination.premultiplied_alpha, false)
  assert_eq(destination.visible, true)
  let color = destination.color
  let copied = destination.copy(source)
  assert_eq(physical_equal(copied, destination), true)
  assert_eq(physical_equal(destination.color, color), true)
  assert_eq(destination.color.r, 1.0)
  assert_eq(destination.color.g, 0.0)
  assert_eq(destination.color.b, 0.0)
  assert_eq(destination.opacity, 0.25)
  assert_eq(destination.transparent, false)
  assert_eq(destination.fog, false)
  assert_eq(destination.rotation, 0.5)
  assert_eq(destination.size_attenuation, false)
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
    Some(stored) => assert_eq(physical_equal(stored, alpha_map), true)
  }
  destination.color.r = 0.5
  assert_eq(source.color.r, 1.0)
  assert_eq(source.opacity, 0.25)
  assert_eq(source.rotation, 0.5)
}

///|
test "SpriteMaterial stores and copies alphaTest" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.alpha_test, 0.0)
  let source = @materials.SpriteMaterial::new()
  source.alpha_test = 0.4
  assert_eq(defaults.alpha_test, 0.0)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.alpha_test, 0.4)
  destination.alpha_test = 0.8
  assert_eq(source.alpha_test, 0.4)
}
