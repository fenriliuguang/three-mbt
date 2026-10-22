///|
test "vsm chebyshev and zero radius moments" {
  assert_eq(@common.vsm_shadow(0.5, 0.25, 0.25, false), 1.0)
  assert_eq(@common.vsm_shadow(0.5, 0.0, 0.75, false), 0.0)
  assert_eq(@common.vsm_shadow(0.25, 0.0, 0.75, true), 1.0)
  assert_eq(@constants.ShadowMapType::VSM.to_int(), @constants.VSM_SHADOW_MAP)
  assert_eq(@constants.VSM_SHADOW_MAP, 3)
  let depths = [0.5]
  let moment = @common.vsm_axis_moment(depths, [0.0], 1, 1, 0, 0, 2, 0.0, false)
  assert_eq(moment.mean, 0.5)
  assert_eq(moment.std_dev, 0.0)
  let spread = @common.vsm_axis_moment([0.5], [0.25], 1, 1, 0, 0, 2, 0.0, true)
  assert_eq(spread.mean, 0.5)
  assert_eq(spread.std_dev, 0.25)
  assert_eq(@common.shadow_enabled_value(false, true, true), 0.0)
  assert_eq(@common.shadow_enabled_value(true, false, false), 1.0)
  assert_eq(@common.shadow_enabled_value(true, true, false), 2.0)
  assert_eq(@common.shadow_enabled_value(true, true, true), 3.0)
  assert_eq(@common.casts_vsm_shadow(false, true, false), false)
  assert_eq(@common.casts_vsm_shadow(false, true, true), true)
  assert_eq(@common.casts_vsm_shadow(true, false, false), true)
  assert_eq(@common.vsm_sample_limit, 64)
}

///|
test "vsm keeps the material side and includes transparent receivers" {
  assert_eq(
    @common.shadow_cast_side(@constants.Front, None, vsm=true).to_int(),
    @constants.FRONT_SIDE,
  )
  assert_eq(
    @common.shadow_cast_side(@constants.Back, None, vsm=true).to_int(),
    @constants.BACK_SIDE,
  )
  assert_eq(
    @common.shadow_cast_side(@constants.Front, None).to_int(),
    @constants.BACK_SIDE,
  )
  assert_eq(
    @common.shadow_cast_side(@constants.Front, Some(@constants.Back), vsm=true).to_int(),
    @constants.BACK_SIDE,
  )
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let glass = @materials.MeshLambertMaterial::new()
  glass.material.transparent = true
  let mesh = @objects.Mesh::new(box.geometry, glass.material)
  mesh.node.receive_shadow = true
  ignore(scene.add(mesh))
  assert_eq(@common.collect_shadow(scene.node).length(), 0)
  let received = @common.collect_shadow(scene.node, vsm=true)
  assert_eq(received.length(), 1)
  assert_eq(physical_equal(received[0].node, mesh.node), true)
}
