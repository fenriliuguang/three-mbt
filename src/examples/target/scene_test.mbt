///|
test "screen quad samples the render target" {
  let world = @target.TargetScene::new()
  world.spin(0.4)
  assert_eq(world.cube.node.rotation.y, 0.4)
  assert_eq(world.target.texture.width, 256)
  assert_eq(world.target.texture.height, 256)
  assert_eq(world.target.texture.attachment, true)
  assert_eq(world.target.texture.flip_y, false)
  @common.update_frame(world.offscreen.node, world.off_camera.node)
  let drawn = @common.collect_opaque(world.offscreen.node)
  assert_eq(drawn.length(), 1)
  assert_eq(drawn[0].map is None, true)
  @common.update_frame(world.screen.node, world.screen_camera.node)
  let shown = @common.collect_opaque(world.screen.node)
  assert_eq(shown.length(), 1)
  match shown[0].map {
    None => panic()
    Some(map) => assert_eq(physical_equal(map, world.target.texture), true)
  }
  match world.quad.geometry.get_attribute("uv") {
    None => panic()
    Some(uv) => {
      assert_eq(uv.get_x(0), 0.0)
      assert_eq(uv.get_y(0), 1.0)
      assert_eq(uv.get_y(2), 0.0)
    }
  }
}
