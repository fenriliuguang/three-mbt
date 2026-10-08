///|
test "points scene keeps a strip and attenuated points" {
  let defaults = @materials.PointsMaterial::new()
  assert_eq(defaults.size, 1.0)
  assert_eq(defaults.size_attenuation, true)
  let world = @points.PointsScene::new()
  world.spin(0.4)
  assert_eq(world.group.node.rotation.y, 0.4)
  let meshes = @common.collect_opaque(world.scene.node)
  assert_eq(meshes.length(), 0)
  let items = @common.collect_primitives(world.scene.node)
  assert_eq(items.length(), 2)
  assert_eq(items[0].kind is @core.PrimitiveKind::Line, true)
  assert_eq(items[0].geometry.get_attribute("position").unwrap().count, 3)
  assert_eq(items[1].kind is @core.PrimitiveKind::Points, true)
  assert_eq(items[1].size, 18.0)
  assert_eq(items[1].size_attenuation, true)
  let segments = @objects.LineSegments::new(
    world.line.geometry,
    @materials.LineBasicMaterial::new(),
  )
  assert_eq(segments.node.kind is @core.NodeKind::LineSegments, true)
}
