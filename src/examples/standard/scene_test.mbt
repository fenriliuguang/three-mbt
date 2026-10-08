///|
test "standard scene is one metal-rough mesh" {
  let world = @standard.StandardScene::new()
  world.spin(0.5)
  assert_eq(world.mesh.node.rotation.y, 0.5)
  let items = @common.collect_opaque(world.scene.node)
  assert_eq(items.length(), 1)
  assert_eq(items[0].shading is @constants.Standard, true)
  assert_eq(items[0].roughness, 0.4)
  assert_eq(items[0].metalness, 0.6)
  @common.update_frame(world.scene.node, world.camera.node)
  let lights = @common.collect_lights(world.scene.node)
  assert_eq(lights.color.x, 2.0)
  assert_eq(lights.direction.y > 0.0, true)
}
