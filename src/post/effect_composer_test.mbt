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

