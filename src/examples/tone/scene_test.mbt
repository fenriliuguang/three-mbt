///|
test "tone scene draws one cube into a color target" {
  let world = @tone.ToneScene::new()
  world.spin(0.4)
  assert_eq(world.cube.node.rotation.y, 0.4)
  assert_eq(world.target.texture.width, 256)
  assert_eq(world.target.texture.height, 256)
  assert_eq(world.target.texture.attachment, true)
  assert_eq(world.target.texture.flip_y, false)
  assert_eq(world.pass.mapping is @constants.ToneMapping::ACES, true)
  assert_eq(world.pass.exposure, 1.0)
  let black = @post.tone_map(
    0.0,
    0.0,
    0.0,
    world.pass.mapping,
    world.pass.exposure,
  )
  assert_eq(black.r, 0.0)
  assert_eq(black.g, 0.0)
  assert_eq(black.b, 0.0)
  let white = @post.tone_map(
    1.0,
    1.0,
    1.0,
    world.pass.mapping,
    world.pass.exposure,
  )
  assert_eq(white.r > 0.7, true)
  assert_eq(white.r < 0.8, true)
  @common.update_frame(world.scene.node, world.camera.node)
  let drawn = @common.collect_opaque(world.scene.node)
  assert_eq(drawn.length(), 1)
  assert_eq(drawn[0].map is None, true)
}
