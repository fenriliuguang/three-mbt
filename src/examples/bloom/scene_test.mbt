///|
test "bloom scene draws one cube into a color target" {
  let world = @bloom.BloomScene::new()
  world.spin(0.4)
  assert_eq(world.cube.node.rotation.y, 0.4)
  assert_eq(world.target.texture.width, 256)
  assert_eq(world.target.texture.height, 256)
  assert_eq(world.target.texture.attachment, true)
  assert_eq(world.target.texture.flip_y, false)
  assert_eq(world.pass.strength, 1.0)
  assert_eq(world.pass.radius, 0.0)
  assert_eq(world.pass.threshold, 0.2)
  assert_eq(world.pass.smooth_width, 0.01)
  let kept = @post.high_pass(
    1.0,
    1.0,
    1.0,
    world.pass.threshold,
    world.pass.smooth_width,
  )
  assert_eq(kept.r, 1.0)
  assert_eq(kept.g, 1.0)
  assert_eq(kept.b, 1.0)
  let mixed = @post.bloom_mix(
    0.25,
    0.0,
    0.0,
    0.5,
    0.0,
    0.0,
    world.pass.strength,
    world.pass.radius,
  )
  assert_eq(mixed.r, 0.75)
  assert_eq(mixed.g, 0.0)
  assert_eq(mixed.b, 0.0)
  @common.update_frame(world.scene.node, world.camera.node)
  let drawn = @common.collect_opaque(world.scene.node)
  assert_eq(drawn.length(), 1)
  assert_eq(drawn[0].map is None, true)
}
