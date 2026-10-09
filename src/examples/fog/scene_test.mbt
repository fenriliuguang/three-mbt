///|
test "fog scene fades three cubes and can skip one material" {
  let world = @fog.FogScene::new()
  world.spin(0.25)
  assert_eq(world.near_cube.node.rotation.y, 0.25)
  assert_eq(world.far_cube.node.position.z, -6.0)
  match world.scene.fog {
    None => panic()
    Some(fog) => {
      assert_eq(fog.kind is @scenes.FogKind::Linear, true)
      assert_eq(fog.near, 4.0)
      assert_eq(fog.far, 12.0)
      assert_eq(fog.factor(4.0), 0.0)
      assert_eq(fog.factor(8.0), 0.5)
      assert_eq(fog.factor(12.0), 1.0)
    }
  }
  @common.update_frame(world.scene.node, world.camera.node)
  let items = @common.collect_opaque(world.scene.node)
  assert_eq(items.length(), 3)
  assert_eq(items[0].fog, true)
  world.far_cube.set_fog(false)
  let faded = @common.collect_opaque(world.scene.node)
  assert_eq(faded[2].fog, false)
  assert_eq(faded[0].fog, true)
}
