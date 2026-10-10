///|
test "grayscale mix uses dyadic weights" {
  let same = @post.grayscale(1.0, 0.0, 0.0, 0.0)
  assert_eq(same.r, 1.0)
  assert_eq(same.g, 0.0)
  assert_eq(same.b, 0.0)
  let red = @post.grayscale(1.0, 0.0, 0.0, 0.5)
  assert_eq(red.r, 0.625)
  assert_eq(red.g, 0.125)
  assert_eq(red.b, 0.125)
  let green = @post.grayscale(0.0, 1.0, 0.0, 1.0)
  assert_eq(green.r, 0.5)
  assert_eq(green.g, 0.5)
  assert_eq(green.b, 0.5)
  let white = @post.grayscale(1.0, 1.0, 1.0, 1.0)
  assert_eq(white.r, 1.0)
  assert_eq(white.g, 1.0)
  assert_eq(white.b, 1.0)
  let pass = @post.GrayscalePass::new(amount=0.5)
  assert_eq(pass.amount, 0.5)
  pass.set_amount(2.0)
  assert_eq(pass.amount, 1.0)
  pass.set_amount(-1.0)
  assert_eq(pass.amount, 0.0)
  let packed = @post.pack_amount(0.5)
  assert_eq(packed.length(), 16)
  assert_eq(packed[0], b'\x00')
  assert_eq(packed[1], b'\x00')
  assert_eq(packed[2], b'\x00')
  assert_eq(packed[3], b'\x3F')
  let wgsl = @post.grayscale_wgsl()
  assert_eq(wgsl.contains("vec3<f32>(0.25, 0.5, 0.25)"), true)
  assert_eq(wgsl.contains("textureSample"), true)
  assert_eq(wgsl.contains("vertex_index"), true)
  assert_eq(wgsl.contains("0.5 - y * 0.5"), true)
}

///|
test "linear and reinhard tone mapping match r186" {
  let kept = @post.tone_map(1.5, 0.25, 0.0, @constants.ToneMapping::No, 4.0)
  assert_eq(kept.r, 1.5)
  assert_eq(kept.g, 0.25)
  assert_eq(kept.b, 0.0)
  let linear = @post.tone_map(
    0.5,
    1.5,
    -0.2,
    @constants.ToneMapping::Linear,
    2.0,
  )
  assert_eq(linear.r, 1.0)
  assert_eq(linear.g, 1.0)
  assert_eq(linear.b, 0.0)
  let mid = @post.tone_map(
    0.25,
    0.25,
    0.25,
    @constants.ToneMapping::Linear,
    2.0,
  )
  assert_eq(mid.r, 0.5)
  let reinhard = @post.tone_map(
    3.0,
    3.0,
    3.0,
    @constants.ToneMapping::Reinhard,
    1.0,
  )
  assert_eq(reinhard.r, 0.75)
  assert_eq(reinhard.g, 0.75)
  assert_eq(reinhard.b, 0.75)
  let black = @post.tone_map(
    1.0,
    1.0,
    1.0,
    @constants.ToneMapping::Reinhard,
    0.0,
  )
  assert_eq(black.r, 0.0)
  assert_eq(black.g, 0.0)
  assert_eq(black.b, 0.0)
  let pass = @post.ToneMappingPass::new()
  assert_eq(pass.mapping is @constants.ToneMapping::No, true)
  assert_eq(pass.exposure, 1.0)
  pass.set_mapping(@constants.ToneMapping::Reinhard)
  pass.set_exposure(1.0)
  assert_eq(pass.mapping is @constants.ToneMapping::Reinhard, true)
  assert_eq(@constants.NO_TONE_MAPPING, 0)
  assert_eq(@constants.LINEAR_TONE_MAPPING, 1)
  assert_eq(@constants.REINHARD_TONE_MAPPING, 2)
  assert_eq(@constants.CINEON_TONE_MAPPING, 3)
  assert_eq(@constants.ACES_FILMIC_TONE_MAPPING, 4)
  assert_eq(@constants.NEUTRAL_TONE_MAPPING, 7)
  let packed = @post.pack_tone(@constants.ToneMapping::Reinhard, 1.0)
  assert_eq(packed.length(), 16)
  assert_eq(packed[0], b'\x00')
  assert_eq(packed[1], b'\x00')
  assert_eq(packed[2], b'\x00')
  assert_eq(packed[3], b'\x40')
  assert_eq(packed[4], b'\x00')
  assert_eq(packed[5], b'\x00')
  assert_eq(packed[6], b'\x80')
  assert_eq(packed[7], b'\x3F')
  let wgsl = @post.tone_wgsl()
  assert_eq(wgsl.contains("params.mapping < 0.5"), true)
  assert_eq(wgsl.contains("scaled / (scaled + vec3<f32>(1.0))"), true)
  assert_eq(wgsl.contains("0.5 - y * 0.5"), true)
}
