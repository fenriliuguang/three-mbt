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
test "reversed perspective projection matches r186 WebGPU" {
  let camera = @cameras.PerspectiveCamera::new(
    fov=50.0,
    aspect=16.0 / 9.0,
    near=0.1,
    far=100.0,
  )
  let expected = [
    1.20628514279, 0.0, 0.0, 0.0, 0.0, 2.14450692051, 0.0, 0.0, 0.0, 0.0, 0.001001001001,
    -1.0, 0.0, 0.0, 0.1001001001, 0.0,
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
test "perspective zoom doubles the projection scale" {
  let camera = @cameras.PerspectiveCamera::new(
    fov=50.0,
    aspect=16.0 / 9.0,
    near=0.1,
    far=100.0,
  )
  match camera.node.camera {
    None => assert_eq(false, true)
    Some(state) => assert_eq(state.zoom, 1.0)
  }
  camera.set_zoom(2.0)
  let expected = [
    2.41257028557, 0.0, 0.0, 0.0, 0.0, 4.28901384102, 0.0, 0.0, 0.0, 0.0, -1.001001001,
    -1.0, 0.0, 0.0, -0.1001001001, 0.0,
  ]
  match camera.node.camera {
    None => assert_eq(false, true)
    Some(state) => {
      assert_eq(state.zoom, 2.0)
      for i in 0..<16 {
        assert_close(state.projection.elements[i], expected[i])
      }
    }
  }
}

///|
test "perspective film offset shifts the frustum" {
  let camera = @cameras.PerspectiveCamera::new(
    fov=50.0,
    aspect=16.0 / 9.0,
    near=0.1,
    far=100.0,
  )
  match camera.node.camera {
    None => assert_eq(false, true)
    Some(state) => {
      assert_eq(state.film_offset, 0.0)
      assert_eq(state.film_gauge, 35.0)
    }
  }
  camera.set_film_offset(3.5)
  let expected = [
    1.20628514279, 0.0, 0.0, 0.0, 0.0, 2.14450692051, 0.0, 0.0, 0.120628514279, 0.0,
    -1.001001001, -1.0, 0.0, 0.0, -0.1001001001, 0.0,
  ]
  match camera.node.camera {
    None => assert_eq(false, true)
    Some(state) => {
      assert_eq(state.film_offset, 3.5)
      for i in 0..<16 {
        assert_close(state.projection.elements[i], expected[i])
      }
    }
  }
}

///|
test "perspective focal length follows the film height" {
  let camera = @cameras.PerspectiveCamera::new(
    fov=50.0,
    aspect=16.0 / 9.0,
    near=0.1,
    far=100.0,
  )
  assert_eq(camera.film_width(), 35.0)
  assert_eq(camera.film_height(), 19.6875)
  assert_close(camera.focal_length(), 21.1099899988)
  assert_close(camera.effective_fov(), 50.0)
  camera.set_zoom(2.0)
  assert_close(camera.effective_fov(), 26.2485362456)
  camera.set_zoom(1.0)
  camera.set_focal_length(50.0)
  match camera.node.camera {
    None => assert_eq(false, true)
    Some(state) => assert_close(state.fov, 22.2753333373)
  }
  assert_close(camera.focal_length(), 50.0)
  camera.set_aspect(0.5)
  assert_eq(camera.film_width(), 17.5)
  assert_eq(camera.film_height(), 35.0)
}

///|
test "film gauge scales film size and the offset" {
  let camera = @cameras.PerspectiveCamera::new(
    fov=50.0,
    aspect=16.0 / 9.0,
    near=0.1,
    far=100.0,
  )
  assert_eq(camera.film_width(), 35.0)
  camera.set_film_gauge(70.0)
  assert_eq(camera.film_width(), 70.0)
  assert_eq(camera.film_height(), 39.375)
  assert_close(camera.focal_length(), 42.2199799975)
  camera.set_film_offset(3.5)
  match camera.node.camera {
    None => assert_eq(false, true)
    Some(state) => {
      assert_eq(state.film_gauge, 70.0)
      assert_close(state.projection.elements[8], 0.060314257139)
    }
  }
}

///|
test "perspective view bounds scale with distance and zoom" {
  let camera = @cameras.PerspectiveCamera::new(
    fov=50.0,
    aspect=16.0 / 9.0,
    near=0.1,
    far=100.0,
  )
  let min_target = @math.Vector2::new()
  let max_target = @math.Vector2::new()
  camera.view_bounds(10.0, min_target, max_target)
  assert_close(min_target.x, -8.2899139228)
  assert_close(min_target.y, -4.6630765815)
  assert_close(max_target.x, 8.2899139228)
  assert_close(max_target.y, 4.6630765815)
  let size = camera.view_size(10.0, @math.Vector2::new())
  assert_close(size.x, 16.5798278455)
  assert_close(size.y, 9.3261531631)
  camera.set_zoom(2.0)
  let zoomed = camera.view_size(10.0, @math.Vector2::new())
  assert_close(zoomed.x, 8.2899139228)
  assert_close(zoomed.y, 4.6630765815)
}

///|
test "perspective view offset takes the left half" {
  let camera = @cameras.PerspectiveCamera::new(
    fov=50.0,
    aspect=16.0 / 9.0,
    near=0.1,
    far=100.0,
  )
  camera.set_view_offset(1920.0, 1080.0, 0.0, 0.0, 960.0, 1080.0)
  let expected = [
    2.41257028557, 0.0, 0.0, 0.0, 0.0, 2.14450692051, 0.0, 0.0, -1.0, 0.0, -1.001001001,
    -1.0, 0.0, 0.0, -0.1001001001, 0.0,
  ]
  match camera.node.camera {
    None => assert_eq(false, true)
    Some(state) =>
      match state.view {
        None => assert_eq(false, true)
        Some(view) => {
          assert_eq(view.enabled, true)
          for i in 0..<16 {
            assert_close(state.projection.elements[i], expected[i])
          }
        }
      }
  }
  camera.clear_view_offset()
  match camera.node.camera {
    None => assert_eq(false, true)
    Some(state) =>
      match state.view {
        None => assert_eq(false, true)
        Some(view) => {
          assert_eq(view.enabled, false)
          assert_close(state.projection.elements[0], 1.20628514279)
          assert_close(state.projection.elements[8], 0.0)
        }
      }
  }
}

///|
test "near and far rebuild the depth terms" {
  let perspective = @cameras.PerspectiveCamera::new(
    fov=50.0,
    aspect=16.0 / 9.0,
    near=0.1,
    far=100.0,
  )
  perspective.set_near(1.0)
  match perspective.node.camera {
    None => assert_eq(false, true)
    Some(state) => {
      assert_eq(state.near, 1.0)
      assert_close(state.projection.elements[0], 1.20628514279)
      assert_close(state.projection.elements[10], -1.010101010101)
      assert_close(state.projection.elements[14], -1.010101010101)
    }
  }
  perspective.set_near(0.1)
  perspective.set_far(50.0)
  match perspective.node.camera {
    None => assert_eq(false, true)
    Some(state) => {
      assert_eq(state.far, 50.0)
      assert_close(state.projection.elements[10], -1.002004008016)
      assert_close(state.projection.elements[14], -0.100200400802)
    }
  }
  let ortho = @cameras.OrthographicCamera::new(
    left=-2.0,
    right=2.0,
    top=1.0,
    bottom=-1.0,
    near=0.1,
    far=10.0,
  )
  ortho.set_near(1.0)
  match ortho.node.camera {
    None => assert_eq(false, true)
    Some(state) => {
      assert_eq(state.near, 1.0)
      assert_close(state.projection.elements[0], 0.5)
      assert_close(state.projection.elements[10], -0.111111111111)
      assert_close(state.projection.elements[14], -0.111111111111)
    }
  }
  ortho.set_far(50.0)
  match ortho.node.camera {
    None => assert_eq(false, true)
    Some(state) => {
      assert_eq(state.far, 50.0)
      assert_close(state.projection.elements[10], -0.020408163265)
      assert_close(state.projection.elements[14], -0.020408163265)
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

///|
test "Vector3.project maps a world point into NDC" {
  let camera = @cameras.OrthographicCamera::new(
    left=-2.0,
    right=2.0,
    top=1.0,
    bottom=-1.0,
    near=0.1,
    far=10.0,
  )
  camera.node.update_matrix_world()
  let point = @math.Vector3::new(x=2.0, y=1.0, z=-0.1)
  let written = camera.node.project_point(point)
  assert_eq(physical_equal(written, point), true)
  assert_eq(point.x, 1.0)
  assert_eq(point.y, 1.0)
  assert_eq(point.z, 0.0)
  ignore(camera.node.position.set(10.0, 0.0, 0.0))
  camera.node.update_matrix_world()
  ignore(point.set(12.0, 1.0, -0.1))
  ignore(camera.node.project_point(point))
  assert_eq(point.x, 1.0)
  assert_eq(point.y, 1.0)
  assert_eq(point.z, 0.0)
}

///|
test "panic Vector3.project requires a camera" {
  let node = @core.Object3D::new()
  ignore(node.project_point(@math.Vector3::new()))
}

///|
test "Vector3.unproject maps NDC back to world space" {
  let camera = @cameras.OrthographicCamera::new(
    left=-2.0,
    right=2.0,
    top=1.0,
    bottom=-1.0,
    near=0.1,
    far=10.0,
  )
  camera.node.update_matrix_world()
  let point = @math.Vector3::new(x=1.0, y=1.0, z=0.0)
  let written = camera.node.unproject_point(point)
  assert_eq(physical_equal(written, point), true)
  assert_eq(point.x, 2.0)
  assert_eq(point.y, 1.0)
  assert_eq(point.z, -0.1)
  ignore(camera.node.position.set(10.0, 0.0, 0.0))
  camera.node.update_matrix_world()
  ignore(point.set(1.0, 1.0, 0.0))
  ignore(camera.node.unproject_point(point))
  assert_eq(point.x, 12.0)
  assert_eq(point.y, 1.0)
  assert_eq(point.z, -0.1)
}

///|
test "panic Vector3.unproject requires a camera" {
  let node = @core.Object3D::new()
  ignore(node.unproject_point(@math.Vector3::new()))
}
