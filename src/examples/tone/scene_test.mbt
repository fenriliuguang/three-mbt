///|
test "tone scene draws one cube into a color target" {
  let world = @tone.ToneScene::new()
  world.spin(0.4)
  assert_eq(world.cube.node.rotation.y, 0.4)
  assert_eq(world.target.texture.width, 256)
  assert_eq(world.target.texture.height, 256)
  assert_eq(world.target.texture.attachment, true)
  assert_eq(world.target.texture.flip_y, false)
  assert_eq(world.pass.mapping is @constants.ToneMapping::Reinhard, true)
  assert_eq(world.pass.exposure, 1.0)
  let mapped = @post.tone_map(
    3.0,
    3.0,
    3.0,
    world.pass.mapping,
    world.pass.exposure,
  )
  assert_eq(mapped.r, 0.75)
  assert_eq(mapped.g, 0.75)
  assert_eq(mapped.b, 0.75)
  @common.update_frame(world.scene.node, world.camera.node)
  let drawn = @common.collect_opaque(world.scene.node)
  assert_eq(drawn.length(), 1)
  assert_eq(drawn[0].map is None, true)
}
