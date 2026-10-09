///|
test "compute scene lays 65 points on a sine wave" {
  let world = @compute.ComputeScene::new()
  assert_eq(world.positions.count, 65)
  assert_eq(@kernel.workgroup_count(world.positions.count), 2)
  let position = world.positions.geometry.get_attribute("position").unwrap()
  assert_eq(position.get_x(0), -1.0)
  assert_eq(position.get_x(32), 0.0)
  assert_eq(position.get_y(32), 0.0)
  assert_eq(position.get_x(64), 1.0)
  world.step(0.5)
  assert_eq(world.positions.time, 0.5)
  assert_eq(position.get_x(32), 0.0)
  assert_eq(position.get_y(32) == 0.0, false)
  let items = @common.collect_primitives(world.scene.node)
  assert_eq(items.length(), 1)
  assert_eq(items[0].kind is @core.PrimitiveKind::Points, true)
  assert_eq(items[0].size, 16.0)
}
