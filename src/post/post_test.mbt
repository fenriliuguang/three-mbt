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
  assert_eq(wgsl.contains("cineon_map"), true)
  assert_eq(wgsl.contains("aces_map"), true)
  assert_eq(wgsl.contains("agx_map"), true)
  assert_eq(wgsl.contains("neutral_map"), true)
}

///|
fn near(actual : Double, expected : Double, tol : Double) -> Bool {
  let delta = actual - expected
  let abs = if delta < 0.0 { -delta } else { delta }
  abs <= tol
}

///|
test "cineon aces agx and neutral match r186" {
  let toe = @post.tone_map(
    0.004,
    0.0,
    0.004,
    @constants.ToneMapping::Cineon,
    1.0,
  )
  assert_eq(toe.r, 0.0)
  assert_eq(toe.g, 0.0)
  assert_eq(toe.b, 0.0)
  let film = @post.tone_map(
    0.204,
    1.0,
    0.204,
    @constants.ToneMapping::Cineon,
    1.0,
  )
  assert_eq(near(film.r, 0.254688, 2.0e-4), true)
  assert_eq(near(film.g, 0.683542, 2.0e-4), true)
  assert_eq(near(film.b, 0.254688, 2.0e-4), true)
  let aces0 = @post.tone_map(0.0, 0.0, 0.0, @constants.ToneMapping::ACES, 1.0)
  assert_eq(aces0.r, 0.0)
  assert_eq(aces0.g, 0.0)
  assert_eq(aces0.b, 0.0)
  let aces_dark = @post.tone_map(
    0.5,
    0.8,
    0.2,
    @constants.ToneMapping::ACES,
    0.0,
  )
  assert_eq(aces_dark.r, 0.0)
  assert_eq(aces_dark.g, 0.0)
  assert_eq(aces_dark.b, 0.0)
  let aces = @post.tone_map(0.18, 0.18, 0.18, @constants.ToneMapping::ACES, 1.0)
  assert_eq(near(aces.r, 0.214097, 5.0e-4), true)
  assert_eq(near(aces.g, 0.214097, 5.0e-4), true)
  assert_eq(near(aces.b, 0.214097, 5.0e-4), true)
  let aces_white = @post.tone_map(
    1.0,
    1.0,
    1.0,
    @constants.ToneMapping::ACES,
    1.0,
  )
  assert_eq(near(aces_white.r, 0.765833, 5.0e-4), true)
  let agx0 = @post.tone_map(0.0, 0.0, 0.0, @constants.ToneMapping::AgX, 1.0)
  assert_eq(agx0.r, 0.0)
  assert_eq(agx0.g, 0.0)
  assert_eq(agx0.b, 0.0)
  let agx = @post.tone_map(0.5, 0.2, 0.1, @constants.ToneMapping::AgX, 1.0)
  assert_eq(near(agx.r, 0.441477, 1.0e-4), true)
  assert_eq(near(agx.g, 0.236864, 1.0e-4), true)
  assert_eq(near(agx.b, 0.150757, 1.0e-4), true)
  let flat = @post.tone_map(0.1, 0.2, 0.3, @constants.ToneMapping::Neutral, 1.0)
  assert_eq(near(flat.r, 0.06, 1.0e-4), true)
  assert_eq(near(flat.g, 0.16, 1.0e-4), true)
  assert_eq(near(flat.b, 0.26, 1.0e-4), true)
  let low = @post.tone_map(
    0.0625,
    0.5,
    0.5,
    @constants.ToneMapping::Neutral,
    1.0,
  )
  assert_eq(low.r, 0.0244140625)
  assert_eq(low.g, 0.4619140625)
  assert_eq(low.b, 0.4619140625)
  let high = @post.tone_map(1.0, 0.9, 0.5, @constants.ToneMapping::Neutral, 1.0)
  assert_eq(near(high.r, 0.869091, 1.0e-4), true)
  assert_eq(near(high.g, 0.779779, 1.0e-4), true)
  assert_eq(near(high.b, 0.422529, 1.0e-4), true)
  assert_eq(@constants.ToneMapping::Cineon.to_int(), 3)
  assert_eq(@constants.ToneMapping::ACES.to_int(), 4)
  assert_eq(@constants.ToneMapping::AgX.to_int(), 6)
  assert_eq(@constants.ToneMapping::Neutral.to_int(), 7)
}

///|
test "bloom high pass and composite match r186" {
  assert_eq(@post.luminance(1.0, 1.0, 1.0), 1.0)
  assert_eq(@post.luminance(0.0, 0.0, 0.0), 0.0)
  let kept = @post.high_pass(1.0, 1.0, 1.0, 0.0, 0.01)
  assert_eq(kept.r, 1.0)
  assert_eq(kept.g, 1.0)
  assert_eq(kept.b, 1.0)
  let dark = @post.high_pass(1.0, 1.0, 1.0, 1.0, 0.01)
  assert_eq(dark.r, 0.0)
  assert_eq(dark.g, 0.0)
  assert_eq(dark.b, 0.0)
  let mixed = @post.bloom_mix(0.25, 0.0, 0.0, 0.5, 0.0, 0.0, 2.0, 0.0)
  assert_eq(mixed.r, 1.25)
  assert_eq(mixed.g, 0.0)
  assert_eq(mixed.b, 0.0)
  assert_eq(near(@post.gaussian_coefficient(0, 6), 0.19947, 1.0e-6), true)
  let pass = @post.BloomPass::new()
  assert_eq(pass.strength, 1.0)
  assert_eq(pass.radius, 0.0)
  assert_eq(pass.threshold, 0.0)
  assert_eq(pass.smooth_width, 0.01)
  pass.set_radius(2.0)
  assert_eq(pass.radius, 1.0)
  pass.set_radius(-1.0)
  assert_eq(pass.radius, 0.0)
  let packed = @post.pack_bloom(pass, 0.0, 0.0, 0.0, 0.0, 0.0)
  assert_eq(packed.length(), 48)
  assert_eq(packed[8], b'\x00')
  assert_eq(packed[9], b'\x00')
  assert_eq(packed[10], b'\x80')
  assert_eq(packed[11], b'\x3F')
  let wgsl = @post.bloom_wgsl()
  assert_eq(wgsl.contains("vec3<f32>(0.2126, 0.7152, 0.0722)"), true)
  assert_eq(wgsl.contains("0.39894"), true)
  assert_eq(wgsl.contains("i < 6"), true)
  assert_eq(wgsl.contains("0.5 - y * 0.5"), true)
}

///|
test "effect composer runs enabled passes in order" {
  let chain = @post.EffectComposer::new()
  assert_eq(chain.pass_count(), 0)
  assert_eq(chain.any_enabled(), false)
  assert_eq(chain.is_last_enabled(0), true)
  chain.add_grayscale(@post.GrayscalePass::new(amount=0.5))
  chain.add_tone(
    @post.ToneMappingPass::new(mapping=@constants.ToneMapping::ACES),
  )
  chain.add_bloom(@post.BloomPass::new(threshold=0.2))
  assert_eq(chain.pass_count(), 3)
  assert_eq(chain.any_enabled(), true)
  assert_eq(chain.is_last_enabled(0), false)
  assert_eq(chain.is_last_enabled(1), false)
  assert_eq(chain.is_last_enabled(2), true)
  chain.set_enabled(2, false)
  assert_eq(chain.is_last_enabled(1), true)
  assert_eq(chain.is_last_enabled(2), true)
  chain.set_enabled(1, false)
  assert_eq(chain.is_last_enabled(0), true)
  chain.set_enabled(9, false)
  assert_eq(chain.pass_count(), 3)
  let gray = @post.grayscale(1.0, 0.0, 0.0, 0.5)
  assert_eq(gray.r, 0.625)
  assert_eq(gray.g, 0.125)
  assert_eq(gray.b, 0.125)
}
