///|
test "cube scene spins and stays one opaque mesh" {
  let world = @cube.CubeScene::new()
  world.spin(0.5)
  assert_eq(world.mesh.node.rotation.y, 0.5)
  assert_eq(world.angle, 0.5)
  let items = @common.collect_opaque(world.scene.node)
  assert_eq(items.length(), 1)
  assert_eq(items[0].color.get_hex(), 16746496)
  match world.scene.background {
    None => assert_eq(false, true)
    Some(_) => assert_eq(true, true)
  }
}
