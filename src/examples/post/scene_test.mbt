///|
test "post scene draws one cube into a color target" {
  let world = @post.PostScene::new()
  world.spin(0.4)
  assert_eq(world.cube.node.rotation.y, 0.4)
  assert_eq(world.target.texture.width, 256)
  assert_eq(world.target.texture.height, 256)
  assert_eq(world.target.texture.attachment, true)
  assert_eq(world.target.texture.flip_y, false)
  assert_eq(world.pass.amount, 0.5)
  let mixed = @effect.grayscale(1.0, 0.0, 0.0, world.pass.amount)
  assert_eq(mixed.r, 0.625)
  assert_eq(mixed.g, 0.125)
  assert_eq(mixed.b, 0.125)
  @common.update_frame(world.scene.node, world.camera.node)
  let drawn = @common.collect_opaque(world.scene.node)
  assert_eq(drawn.length(), 1)
  assert_eq(drawn[0].map is None, true)
}
