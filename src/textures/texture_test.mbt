///|
test "wrapping and filters keep r186 numbers" {
  assert_eq(@constants.Wrapping::Repeat.to_int(), 1000)
  assert_eq(@constants.Wrapping::ClampToEdge.to_int(), 1001)
  assert_eq(@constants.Wrapping::MirroredRepeat.to_int(), 1002)
  assert_eq(@constants.TextureFilter::Nearest.to_int(), 1003)
  assert_eq(@constants.TextureFilter::Linear.to_int(), 1006)
  assert_eq(@constants.TextureFilter::LinearMipmapLinear.to_int(), 1008)
  assert_eq(@constants.TextureFilter::LinearMipmapLinear.is_nearest(), false)
  assert_eq(@constants.TextureFilter::LinearMipmapLinear.mip_linear(), true)
  assert_eq(@constants.TextureFilter::Nearest.is_nearest(), true)
  assert_eq(@constants.TextureFilter::Nearest.mip_linear(), false)
  assert_eq(@constants.TextureFilter::NearestMipmapLinear.mip_linear(), true)
}

///|
test "checker is rgba8 and flip_y reverses rows" {
  let map = @textures.Texture::checker(
    width=2,
    height=2,
    cell=1,
    first=0xFF0000,
    second=0x00FF00,
  )
  assert_eq(map.width, 2)
  assert_eq(map.height, 2)
  assert_eq(map.data.length(), 16)
  assert_eq(map.needs_update, true)
  assert_eq(map.flip_y, true)
  assert_eq(map.attachment, false)
  assert_eq(map.version, 0)
  assert_eq(map.wrap_s is @constants.ClampToEdge, true)
  assert_eq(map.min_filter is @constants.LinearMipmapLinear, true)
  assert_eq(map.data[0], b'\xFF')
  assert_eq(map.data[1], b'\x00')
  assert_eq(map.data[4], b'\x00')
  assert_eq(map.data[5], b'\xFF')
  let flipped = map.rgba8()
  assert_eq(flipped[0], b'\x00')
  assert_eq(flipped[1], b'\xFF')
  assert_eq(flipped[4], b'\xFF')
  assert_eq(flipped[5], b'\x00')
  map.flip_y = false
  let upright = map.rgba8()
  assert_eq(upright[0], b'\xFF')
  assert_eq(upright[5], b'\xFF')
}

///|
test "render target keeps one attachment texture" {
  let map = @textures.Texture::attachment(0, -2)
  assert_eq(map.width, 1)
  assert_eq(map.height, 1)
  assert_eq(map.attachment, true)
  assert_eq(map.flip_y, false)
  assert_eq(map.needs_update, false)
  assert_eq(map.data.length(), 4)
  assert_eq(map.rgba8().length(), 4)
  assert_eq(map.mag_filter is @constants.Linear, true)
  assert_eq(map.min_filter is @constants.Linear, true)
  let target = @textures.RenderTarget::new(256, 128)
  assert_eq(target.texture.width, 256)
  assert_eq(target.texture.height, 128)
  assert_eq(target.texture.version, 0)
  let image = target.texture
  target.set_size(256, 128)
  assert_eq(target.texture.version, 0)
  target.set_size(16, 8)
  assert_eq(target.texture.width, 16)
  assert_eq(target.texture.height, 8)
  assert_eq(target.texture.version, 1)
  assert_eq(physical_equal(image, target.texture), true)
  target.set_size(0, 0)
  assert_eq(target.texture.width, 1)
  assert_eq(target.texture.height, 1)
  assert_eq(target.texture.version, 2)
}
