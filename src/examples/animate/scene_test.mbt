///|
test "animate scene reaches the middle key then returns" {
  let world = @animate.AnimateScene::new()
  world.step(1.0)
  assert_eq(world.mesh.node.position.y, 1.0)
  assert_eq(world.mesh.node.quaternion.y, 1.0)
  assert_eq(world.mesh.node.quaternion.w, 0.0)
  world.step(1.0)
  assert_eq(world.mesh.node.position.y, 0.0)
  assert_eq(world.mesh.node.quaternion.w, 1.0)
  assert_eq(world.mesh.node.quaternion.y, 0.0)
}
