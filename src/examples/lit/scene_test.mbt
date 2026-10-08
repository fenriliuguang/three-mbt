///|
test "lit scene is one lambert mesh with lights" {
  let world = @lit.LitScene::new()
  world.spin(0.5)
  assert_eq(world.mesh.node.rotation.y, 0.5)
  let items = @common.collect_opaque(world.scene.node)
  assert_eq(items.length(), 1)
  assert_eq(items[0].shading is @constants.Lambert, true)
  @common.update_frame(world.scene.node, world.camera.node)
  let lights = @common.collect_lights(world.scene.node)
  assert_eq(lights.color.x, 1.0)
  assert_eq(lights.ambient.x > 0.0, true)
  assert_eq(lights.direction.y > 0.0, true)
}
