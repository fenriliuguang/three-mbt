///|
test "textured scene samples a checker and orbits from the pointer" {
  let world = @textured.TexturedScene::new()
  world.spin(0.5)
  assert_eq(world.mesh.node.rotation.y, 0.5)
  let items = @common.collect_opaque(world.scene.node)
  assert_eq(items.length(), 1)
  assert_eq(items[0].shading is @constants.Lambert, true)
  match items[0].map {
    None => assert_eq(false, true)
    Some(map) => {
      assert_eq(map.width, 4)
      assert_eq(map.data.length(), 64)
      assert_eq(physical_equal(map, world.map), true)
    }
  }
  assert_eq(world.camera.node.position.x, 0.0)
  world.pointer_move(10.0, 0.0)
  assert_eq(world.camera.node.position.x, 0.0)
  world.pointer_down(0.0, 0.0)
  world.pointer_move(10.0, 0.0)
  assert_eq(world.camera.node.position.x == 0.0, false)
  let y = world.camera.node.position.y
  world.pointer_move(12.0, 0.0)
  assert_eq(world.camera.node.position.y, y)
  world.pointer_up()
  let x = world.camera.node.position.x
  world.pointer_move(40.0, 0.0)
  assert_eq(world.camera.node.position.x, x)
  world.pointer_down(0.0, 0.0)
  world.pointer_move(0.0, 200.0)
  assert_eq(world.pitch, 1.2)
}
