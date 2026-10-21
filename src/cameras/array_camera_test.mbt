///|
test "ArrayCamera stores its perspective sub cameras" {
  let empty = @cameras.ArrayCamera::new()
  assert_eq(empty.cameras.length(), 0)
  match empty.node.kind {
    @core.PerspectiveCamera => assert_eq(true, true)
    _ => assert_eq(false, true)
  }
  match empty.node.camera {
    None => assert_eq(false, true)
    Some(state) => {
      assert_eq(state.fov, 50.0)
      assert_eq(state.aspect, 1.0)
      assert_eq(state.near, 0.1)
      assert_eq(state.far, 2000.0)
    }
  }
  let eye = @cameras.PerspectiveCamera::new(fov=40.0)
  let array = @cameras.ArrayCamera::new(cameras=[eye])
  assert_eq(array.cameras.length(), 1)
  assert_eq(physical_equal(array.cameras[0].node, eye.node), true)
  match array.cameras[0].node.camera {
    None => assert_eq(false, true)
    Some(state) => assert_eq(state.fov, 40.0)
  }
}

///|
fn assert_same_frustum(
  actual : @math.Frustum,
  expected : @math.Frustum,
) -> Unit raise {
  for i in 0..<6 {
    assert_eq(actual.planes[i].constant, expected.planes[i].constant)
    assert_eq(actual.planes[i].normal.x, expected.planes[i].normal.x)
    assert_eq(actual.planes[i].normal.y, expected.planes[i].normal.y)
    assert_eq(actual.planes[i].normal.z, expected.planes[i].normal.z)
  }
}

///|
fn frustum_from_camera(
  camera : @cameras.PerspectiveCamera,
) -> @math.Frustum raise {
  let frustum = @math.Frustum::new()
  match camera.node.camera {
    None => assert_eq(false, true)
    Some(state) => {
      let projected = @math.Matrix4::new().multiply_matrices(
        state.projection,
        state.matrix_world_inverse,
      )
      ignore(
        frustum.set_from_projection_matrix(
          projected,
          coordinate_system=state.coordinate_system,
          reversed_depth=state.reversed_depth,
        ),
      )
    }
  }
  frustum
}

///|
test "FrustumArray.setFromArrayCamera caches one frustum per sub camera" {
  let origin = @cameras.PerspectiveCamera::new()
  origin.node.update_matrix_world()
  let shifted = @cameras.PerspectiveCamera::new()
  ignore(shifted.node.position.set(10.0, 0.0, 0.0))
  shifted.node.update_matrix_world()
  let array = @cameras.ArrayCamera::new(cameras=[origin, shifted])
  let frustums = @math.FrustumArray::new()
  let written = @cameras.set_from_array_camera(frustums, array)
  assert_eq(physical_equal(written, frustums), true)
  assert_eq(frustums.count, 2)
  assert_same_frustum(frustums.frustums[0], frustum_from_camera(origin))
  assert_same_frustum(frustums.frustums[1], frustum_from_camera(shifted))
  assert_eq(
    frustums.frustums[0].planes[0].constant ==
    frustums.frustums[1].planes[0].constant,
    false,
  )
  let kept = frustums.frustums[1].planes[0].constant
  ignore(@cameras.set_from_array_camera(frustums, @cameras.ArrayCamera::new()))
  assert_eq(frustums.count, 0)
  assert_eq(frustums.frustums.length(), 2)
  assert_eq(frustums.frustums[1].planes[0].constant, kept)
}
