///|
fn close(actual : Double, expected : Double) -> Bool {
  let diff = (actual - expected).abs()
  diff <= 1.0e-8 || diff <= expected.abs() * 1.0e-8
}

///|
fn assert_close(actual : Double, expected : Double) -> Unit raise {
  if close(actual, expected) {
    assert_eq(true, true)
  } else {
    assert_eq(actual, expected)
  }
}

///|
test "perspective projection matches r186 WebGPU" {
  let camera = @cameras.PerspectiveCamera::new(
    fov=50.0,
    aspect=16.0 / 9.0,
    near=0.1,
    far=100.0,
  )
  let expected = [
    1.20628514279, 0.0, 0.0, 0.0, 0.0, 2.14450692051, 0.0, 0.0, 0.0, 0.0, -1.001001001,
    -1.0, 0.0, 0.0, -0.1001001001, 0.0,
  ]
  match camera.node.camera {
    None => assert_eq(false, true)
    Some(state) =>
      for i in 0..<16 {
        assert_close(state.projection.elements[i], expected[i])
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
