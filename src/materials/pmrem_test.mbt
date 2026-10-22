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
