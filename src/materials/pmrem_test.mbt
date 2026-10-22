///|
fn solid(r : Byte, g : Byte, b : Byte) -> @textures.Texture {
  let pixels = FixedArray::make(4, b'\x00')
  pixels[0] = r
  pixels[1] = g
  pixels[2] = b
  pixels[3] = b'\xFF'
  @textures.Texture::from_rgba8(1, 1, pixels)
}

///|
test "a constant environment stays constant on every atlas row" {
  let atlas = @materials.pmrem_atlas(solid(b'\xFF', b'\xFF', b'\xFF'))
  assert_eq(atlas.width, 1)
  assert_eq(atlas.height, 6)
  assert_eq(atlas.flip_y, false)
  assert_eq(atlas.mapping is @constants.TextureMapping::CubeUVReflection, true)
  assert_eq(atlas.color_space is @constants.ColorSpace::No, true)
  let bytes = atlas.rgba8()
  assert_eq(bytes.length(), 24)
  for index in 0..<24 {
    assert_eq(bytes[index], b'\xFF')
  }
  let red = @materials.pmrem_atlas(solid(b'\xFF', b'\x00', b'\x00')).rgba8()
  assert_eq(red.length(), 24)
  let mut index = 0
  while index < 24 {
    assert_eq(red[index], b'\xFF')
    assert_eq(red[index + 1], b'\x00')
    assert_eq(red[index + 2], b'\x00')
    assert_eq(red[index + 3], b'\xFF')
    index = index + 4
  }
}

///|
test "roughness zero copies an equirectangular image" {
  let pixels = FixedArray::make(8, b'\x00')
  pixels[0] = b'\xFF'
  pixels[3] = b'\xFF'
  pixels[6] = b'\xFF'
  pixels[7] = b'\xFF'
  let source = @textures.Texture::from_rgba8(2, 1, pixels)
  let atlas = @materials.pmrem_atlas(source)
  assert_eq(atlas.width, 2)
  assert_eq(atlas.height, 6)
  let bytes = atlas.rgba8()
  assert_eq(bytes[0], b'\xFF')
  assert_eq(bytes[1], b'\x00')
  assert_eq(bytes[2], b'\x00')
  assert_eq(bytes[3], b'\xFF')
  assert_eq(bytes[4], b'\x00')
  assert_eq(bytes[5], b'\x00')
  assert_eq(bytes[6], b'\xFF')
  assert_eq(bytes[7], b'\xFF')
}

///|
test "an environment wider than 16 nearest-filters to 16" {
  let pixels = FixedArray::make(17 * 4, b'\x00')
  pixels[0] = b'\xFF'
  pixels[3] = b'\xFF'
  pixels[16 * 4 + 2] = b'\xFF'
  pixels[16 * 4 + 3] = b'\xFF'
  let mut index = 1
  while index < 16 {
    pixels[index * 4 + 1] = b'\xFF'
    pixels[index * 4 + 3] = b'\xFF'
    index = index + 1
  }
  let source = @textures.Texture::from_rgba8(17, 1, pixels)
  let atlas = @materials.pmrem_atlas(source)
  assert_eq(atlas.width, 16)
  assert_eq(atlas.height, 6)
  let bytes = atlas.rgba8()
  assert_eq(bytes[0], b'\xFF')
  assert_eq(bytes[1], b'\x00')
  assert_eq(bytes[2], b'\x00')
  assert_eq(bytes[3], b'\xFF')
  let last = 15 * 4
  assert_eq(bytes[last], b'\x00')
  assert_eq(bytes[last + 1], b'\x00')
  assert_eq(bytes[last + 2], b'\xFF')
  assert_eq(bytes[last + 3], b'\xFF')
}

///|
test "yaw of pi/2 turns +X with the euler matrix" {
  let stayed = @materials.rotate_env_direction(
    @math.Euler::new(),
    @math.Vector3::new(x=1.0),
  )
  assert_eq(stayed.x, 1.0)
  assert_eq(stayed.y, 0.0)
  assert_eq(stayed.z, 0.0)
  let half = @std.PI / 2.0
  let euler = @math.Euler::new(y=half)
  let turned = @materials.rotate_env_direction(euler, @math.Vector3::new(x=1.0))
  let matrix = @math.Matrix4::new()
  ignore(matrix.make_rotation_from_euler(euler))
  let c = @std.cos(half)
  let s = @std.sin(half)
  assert_eq(matrix.elements[0], c)
  assert_eq(matrix.elements[1], 0.0)
  assert_eq(matrix.elements[2], -s)
  assert_eq(matrix.elements[5], 1.0)
  assert_eq(matrix.elements[8], s)
  let length = (c * c + s * s).sqrt()
  assert_eq(turned.x, c / length)
  assert_eq(turned.y, 0.0)
  assert_eq(turned.z, -s / length)
}

///|
test "color space and cube UV mapping stay on the atlas" {
  let pixels = FixedArray::make(4, b'\x00')
  pixels[0] = b'\x80'
  pixels[1] = b'\x80'
  pixels[2] = b'\x80'
  pixels[3] = b'\xFF'
  let linear = @textures.Texture::from_rgba8(1, 1, pixels)
  let linear_atlas = @materials.pmrem_atlas(linear)
  let linear_bytes = linear_atlas.rgba8()
  assert_eq(linear_bytes[0], b'\x80')
  assert_eq(linear_bytes[4], b'\x80')
  let encoded = @textures.Texture::from_rgba8(1, 1, pixels)
  encoded.color_space = @constants.ColorSpace::SRGB
  let srgb_atlas = @materials.pmrem_atlas(encoded)
  assert_eq(srgb_atlas.color_space is @constants.ColorSpace::SRGB, true)
  assert_eq(srgb_atlas.rgba8()[0], b'\x80')
  let decoded = @math.srgb_to_linear(128.0 / 255.0)
  let stored = (@math.linear_to_srgb(decoded) * 255.0)
    .round()
    .to_int()
    .to_byte()
  assert_eq(srgb_atlas.rgba8()[4], stored)
  let rows = FixedArray::make(2 * 6 * 4, b'\x10')
  rows[3] = b'\xFF'
  let cube = @textures.Texture::from_rgba8(2, 6, rows)
  cube.flip_y = false
  cube.mapping = @constants.TextureMapping::CubeUVReflection
  cube.color_space = @constants.ColorSpace::LinearSRGB
  let kept = @materials.pmrem_atlas(cube)
  assert_eq(kept.width, 2)
  assert_eq(kept.height, 6)
  assert_eq(kept.mapping is @constants.TextureMapping::CubeUVReflection, true)
  assert_eq(kept.color_space is @constants.ColorSpace::LinearSRGB, true)
  assert_eq(kept.rgba8()[0], b'\x10')
  assert_eq(kept.rgba8()[3], b'\xFF')
}
