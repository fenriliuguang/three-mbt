///|
test "gltf scene draws one standard box" {
  let world = @gltf.GltfScene::new()
  world.spin(0.25)
  assert_eq(world.root.node.rotation.y, 0.25)
  @common.update_frame(world.scene.node, world.camera.node)
  let items = @common.collect_opaque(world.scene.node)
  assert_eq(items.length(), 1)
  assert_eq(items[0].shading is @constants.Shading::Standard, true)
  assert_eq(items[0].roughness, 0.25)
  assert_eq(items[0].metalness, 0.0)
  assert_eq(items[0].color.r, 1.0)
  assert_eq(items[0].color.g, 0.5)
  assert_eq(items[0].color.b, 0.25)
  let position = items[0].geometry.get_attribute("position").unwrap()
  assert_eq(position.count, 24)
  assert_eq(position.get_x(0), -0.5)
  assert_eq(position.get_z(0), 0.5)
  match items[0].geometry.index {
    None => panic()
    Some(index) => assert_eq(index.count, 36)
  }
}
