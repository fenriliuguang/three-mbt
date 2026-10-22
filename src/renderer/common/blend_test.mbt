///|
test "additive subtractive and multiply use the webgpu factors" {
  match @common.named_blend(@constants.Normal, false) {
    None => assert_eq(true, true)
    Some(_) => assert_eq(false, true)
  }
  match @common.named_blend(@constants.Custom, true) {
    None => assert_eq(true, true)
    Some(_) => assert_eq(false, true)
  }
  match @common.named_blend(@constants.No, true) {
    None => assert_eq(true, true)
    Some(_) => assert_eq(false, true)
  }
  match @common.named_blend(@constants.Additive, false) {
    None => assert_eq(false, true)
    Some(equation) => {
      assert_eq(equation.op is @common.BlendOp::Additive, true)
      assert_eq(equation.src_color, @constants.SRC_ALPHA_FACTOR)
      assert_eq(equation.dst_color, @constants.ONE_FACTOR)
      assert_eq(equation.src_alpha, @constants.ONE_FACTOR)
      assert_eq(equation.dst_alpha, @constants.ONE_FACTOR)
    }
  }
  match @common.named_blend(@constants.Additive, true) {
    None => assert_eq(false, true)
    Some(equation) => {
      assert_eq(equation.src_color, @constants.ONE_FACTOR)
      assert_eq(equation.dst_color, @constants.ONE_FACTOR)
      assert_eq(equation.src_alpha, @constants.ONE_FACTOR)
      assert_eq(equation.dst_alpha, @constants.ONE_FACTOR)
    }
  }
  match @common.named_blend(@constants.Subtractive, false) {
    None => assert_eq(false, true)
    Some(equation) => {
      assert_eq(equation.op is @common.BlendOp::Subtractive, true)
      assert_eq(equation.src_color, @constants.ZERO_FACTOR)
      assert_eq(equation.dst_color, @constants.ONE_MINUS_SRC_COLOR_FACTOR)
      assert_eq(equation.src_alpha, @constants.ZERO_FACTOR)
      assert_eq(equation.dst_alpha, @constants.ONE_FACTOR)
    }
  }
  match @common.named_blend(@constants.Multiply, true) {
    None => assert_eq(false, true)
    Some(equation) => {
      assert_eq(equation.op is @common.BlendOp::Multiply, true)
      assert_eq(equation.src_color, @constants.DST_COLOR_FACTOR)
      assert_eq(equation.dst_color, @constants.ONE_MINUS_SRC_ALPHA_FACTOR)
      assert_eq(equation.src_alpha, @constants.ZERO_FACTOR)
      assert_eq(equation.dst_alpha, @constants.ONE_FACTOR)
    }
  }
}

///|
test "additive opaque meshes stay opaque and carry the blend mode" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let material = @materials.MeshBasicMaterial::new()
  material.material.blending = @constants.Additive
  let mesh = @objects.Mesh::new(box.geometry, material.material)
  ignore(scene.add(mesh))
  let solid = @common.collect_opaque(scene.node)
  assert_eq(solid.length(), 1)
  assert_eq(solid[0].blending.to_int(), @constants.ADDITIVE_BLENDING)
  assert_eq(@common.collect_transparent(scene.node, mesh.node).length(), 0)
  let points = @materials.PointsMaterial::new()
  points.blending = @constants.Blending::Multiply
  let cloud = @objects.Points::new(box.geometry, points)
  ignore(scene.add(cloud))
  let drawn = @common.collect_primitives(scene.node)
  assert_eq(drawn.length(), 1)
  assert_eq(drawn[0].blending.to_int(), @constants.MULTIPLY_BLENDING)
}
