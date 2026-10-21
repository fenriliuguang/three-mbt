///|
test "reversed orthographic projection matches r186 WebGPU" {
  let camera = @cameras.OrthographicCamera::new(
    left=-2.0,
    right=2.0,
    top=1.0,
    bottom=-1.0,
    near=0.1,
    far=10.0,
  )
  let expected = [
    0.5, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.10101010101, 0.0, 0.0, 0.0,
    1.010101010101, 1.0,
  ]
  match camera.node.camera {
    None => assert_eq(false, true)
    Some(state) => {
      state.reversed_depth = true
      state.update_projection()
      for i in 0..<16 {
        assert_close(state.projection.elements[i], expected[i])
      }
    }
  }
}

///|
test "orthographic view offset takes the left half" {
  let camera = @cameras.OrthographicCamera::new(
    left=-2.0,
    right=2.0,
    top=1.0,
    bottom=-1.0,
    near=0.1,
    far=10.0,
  )
  camera.set_view_offset(4.0, 2.0, 0.0, 0.0, 2.0, 2.0)
  let expected = [
    1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, -0.10101010101, 0.0, 1.0, 0.0,
    -0.010101010101, 1.0,
  ]
  match camera.node.camera {
    None => assert_eq(false, true)
    Some(state) => {
      assert_eq(state.aspect, 1.0)
      for i in 0..<16 {
        assert_close(state.projection.elements[i], expected[i])
      }
    }
  }
  camera.clear_view_offset()
  match camera.node.camera {
    None => assert_eq(false, true)
    Some(state) => {
      assert_close(state.projection.elements[0], 0.5)
      assert_close(state.projection.elements[12], 0.0)
    }
  }
}

///|
test "orthographic bounds rebuild the projection" {
  let camera = @cameras.OrthographicCamera::new(near=0.1, far=10.0)
  camera.set_left(-2.0)
  camera.set_right(2.0)
  camera.set_top(1.0)
  camera.set_bottom(-1.0)
  let expected = [
    0.5, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, -0.10101010101, 0.0, 0.0, 0.0,
    -0.010101010101, 1.0,
  ]
  match camera.node.camera {
    None => assert_eq(false, true)
    Some(state) => {
      assert_eq(state.left, -2.0)
      assert_eq(state.right, 2.0)
      assert_eq(state.top, 1.0)
      assert_eq(state.bottom, -1.0)
      for i in 0..<16 {
        assert_close(state.projection.elements[i], expected[i])
      }
    }
  }
  camera.set_top(2.0)
  camera.set_bottom(-2.0)
  match camera.node.camera {
    None => assert_eq(false, true)
    Some(state) => {
      assert_close(state.projection.elements[0], 0.5)
      assert_close(state.projection.elements[5], 0.5)
    }
  }
}

///|
test "orthographic projection matches r186 WebGPU" {
  let camera = @cameras.OrthographicCamera::new(
    left=-2.0,
    right=2.0,
    top=1.0,
    bottom=-1.0,
    near=0.1,
    far=10.0,
  )
  let expected = [
    0.5, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, -0.10101010101, 0.0, 0.0, 0.0,
    -0.010101010101, 1.0,
  ]
  match camera.node.camera {
    None => assert_eq(false, true)
    Some(state) =>
      for i in 0..<16 {
        assert_close(state.projection.elements[i], expected[i])
      }
  }
}
