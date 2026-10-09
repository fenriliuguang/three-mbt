///|
test "shadow scene casts from the cube onto the ground" {
  let world = @shadow.ShadowScene::new()
  world.spin(0.3)
  assert_eq(world.cube.node.rotation.y, 0.3)
  assert_eq(world.cube.node.cast_shadow, true)
  assert_eq(world.ground.node.receive_shadow, true)
  assert_eq(world.cube.node.receive_shadow, false)
  @common.update_frame(world.scene.node, world.camera.node)
  let lights = @common.collect_lights(world.scene.node)
  match lights.shadow {
    None => panic()
    Some(shadow) => {
      assert_eq(shadow.map_size, 512)
      assert_eq(shadow.bias, -0.001)
      assert_eq(shadow.normal_bias, 0.02)
    }
  }
  let items = @common.collect_opaque(world.scene.node)
  assert_eq(items.length(), 2)
  assert_eq(items[0].node.cast_shadow, true)
  assert_eq(items[1].node.receive_shadow, true)
}
