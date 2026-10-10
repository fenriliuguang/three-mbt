///|
test "compose scene chains grayscale then tone mapping" {
  let world = @compose.ComposeScene::new()
  world.spin(0.4)
  assert_eq(world.cube.node.rotation.y, 0.4)
  assert_eq(world.target.texture.width, 256)
  assert_eq(world.target.texture.height, 256)
  assert_eq(world.target.texture.attachment, true)
  assert_eq(world.target.texture.flip_y, false)
  assert_eq(world.composer.pass_count(), 2)
  assert_eq(world.composer.is_last_enabled(0), false)
  assert_eq(world.composer.is_last_enabled(1), true)
  match world.composer.passes[0].effect {
    @post.Grayscale(pass) => assert_eq(pass.amount, 0.5)
    @post.Tone(_) => assert_eq(false, true)
    @post.Bloom(_) => assert_eq(false, true)
  }
  let gray = @post.grayscale(1.0, 0.0, 0.0, 0.5)
  assert_eq(gray.r, 0.625)
  assert_eq(gray.g, 0.125)
  assert_eq(gray.b, 0.125)
  @common.update_frame(world.scene.node, world.camera.node)
  let drawn = @common.collect_opaque(world.scene.node)
  assert_eq(drawn.length(), 1)
  assert_eq(drawn[0].map is None, true)
}
