///|
test "blend scene keeps the glass cube in front" {
  let world = @blend.BlendScene::new()
  world.spin(0.4)
  assert_eq(world.solid.node.rotation.y, 0.4)
  assert_eq(world.glass.node.rotation.y, 0.4)
  @common.update_frame(world.scene.node, world.camera.node)
  let drawn = @common.collect_opaque(world.scene.node)
  assert_eq(drawn.length(), 1)
  assert_eq(physical_equal(drawn[0].node, world.solid.node), true)
  assert_eq(drawn[0].opacity, 1.0)
  let glass = @common.collect_transparent(world.scene.node, world.camera.node)
  assert_eq(glass.length(), 1)
  assert_eq(physical_equal(glass[0].node, world.glass.node), true)
  assert_eq(glass[0].opacity, 0.5)
  let far = @common.view_depth(world.camera.node, world.solid.node)
  let near = @common.view_depth(world.camera.node, world.glass.node)
  assert_eq(far < near, true)
}
