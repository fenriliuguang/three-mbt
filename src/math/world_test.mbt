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
test "setScalar writes the same value into every component" {
  let v = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  ignore(v.set_scalar(4.0))
  assert_eq(v.x, 4.0)
  assert_eq(v.y, 4.0)
  assert_eq(v.z, 4.0)
}

///|
test "setX setY and setZ change one component" {
  let v = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  ignore(v.set_x(9.0))
  assert_eq(v.x, 9.0)
  assert_eq(v.y, 2.0)
  assert_eq(v.z, 3.0)
  ignore(v.set_y(8.0))
  assert_eq(v.x, 9.0)
  assert_eq(v.y, 8.0)
  assert_eq(v.z, 3.0)
  ignore(v.set_z(7.0))
  assert_eq(v.x, 9.0)
  assert_eq(v.y, 8.0)
  assert_eq(v.z, 7.0)
}

///|
test "component index 0 is x, 1 is y, and 2 is z" {
  let v = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  assert_eq(v.get_component(0), 1.0)
  assert_eq(v.get_component(1), 2.0)
  assert_eq(v.get_component(2), 3.0)
  ignore(v.set_component(1, 8.0))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 8.0)
  assert_eq(v.z, 3.0)
}

///|
test "panic component index past z" {
  ignore(@math.Vector3::new().get_component(3))
}

///|
test "addScalar adds one number to every component" {
  let v = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  ignore(v.add_scalar(4.0))
  assert_eq(v.x, 5.0)
  assert_eq(v.y, 6.0)
  assert_eq(v.z, 7.0)
  ignore(v.add_scalar(-1.0))
  assert_eq(v.x, 4.0)
  assert_eq(v.y, 5.0)
  assert_eq(v.z, 6.0)
}

///|
test "addScaledVector adds a vector multiplied by a factor" {
  let v = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  let step = @math.Vector3::new(x=4.0, y=5.0, z=6.0)
  ignore(v.add_scaled_vector(step, 2.0))
  assert_eq(v.x, 9.0)
  assert_eq(v.y, 12.0)
  assert_eq(v.z, 15.0)
  assert_eq(step.x, 4.0)
  assert_eq(step.y, 5.0)
  assert_eq(step.z, 6.0)
}

///|
test "subScalar subtracts one number from every component" {
  let v = @math.Vector3::new(x=5.0, y=6.0, z=7.0)
  ignore(v.sub_scalar(4.0))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 2.0)
  assert_eq(v.z, 3.0)
  ignore(v.sub_scalar(-1.0))
  assert_eq(v.x, 2.0)
  assert_eq(v.y, 3.0)
  assert_eq(v.z, 4.0)
}

///|
test "multiply scales each component by the other vector" {
  let v = @math.Vector3::new(x=2.0, y=3.0, z=4.0)
  let factor = @math.Vector3::new(x=5.0, y=6.0, z=0.5)
  ignore(v.multiply(factor))
  assert_eq(v.x, 10.0)
  assert_eq(v.y, 18.0)
  assert_eq(v.z, 2.0)
  assert_eq(factor.x, 5.0)
  assert_eq(factor.y, 6.0)
  assert_eq(factor.z, 0.5)
}

///|
test "multiplyVectors stores the componentwise product" {
  let a = @math.Vector3::new(x=2.0, y=3.0, z=4.0)
  let b = @math.Vector3::new(x=5.0, y=6.0, z=0.5)
  let out = @math.Vector3::new(x=9.0, y=9.0, z=9.0)
  ignore(out.multiply_vectors(a, b))
  assert_eq(out.x, 10.0)
  assert_eq(out.y, 18.0)
  assert_eq(out.z, 2.0)
  assert_eq(a.x, 2.0)
  assert_eq(b.z, 0.5)
  ignore(a.multiply_vectors(a, b))
  assert_eq(a.x, 10.0)
  assert_eq(a.y, 18.0)
  assert_eq(a.z, 2.0)
  assert_eq(b.x, 5.0)
}

///|
test "divide scales each component by the other vector" {
  let v = @math.Vector3::new(x=10.0, y=18.0, z=2.0)
  let factor = @math.Vector3::new(x=5.0, y=6.0, z=0.5)
  ignore(v.divide(factor))
  assert_eq(v.x, 2.0)
  assert_eq(v.y, 3.0)
  assert_eq(v.z, 4.0)
  assert_eq(factor.x, 5.0)
  assert_eq(factor.y, 6.0)
  assert_eq(factor.z, 0.5)
}

///|
test "divideScalar divides every component by one number" {
  let v = @math.Vector3::new(x=2.0, y=4.0, z=6.0)
  ignore(v.divide_scalar(2.0))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 2.0)
  assert_eq(v.z, 3.0)
  ignore(v.divide_scalar(-1.0))
  assert_eq(v.x, -1.0)
  assert_eq(v.y, -2.0)
  assert_eq(v.z, -3.0)
}

///|
test "clamp keeps each component inside its own range" {
  let v = @math.Vector3::new(x=0.0, y=5.0, z=-2.0)
  let min = @math.Vector3::new(x=1.0, y=0.0, z=-1.0)
  let max = @math.Vector3::new(x=3.0, y=4.0, z=1.0)
  ignore(v.clamp(min, max))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 4.0)
  assert_eq(v.z, -1.0)
  assert_eq(min.x, 1.0)
  assert_eq(max.y, 4.0)
  let inside = @math.Vector3::new(x=2.0, y=2.0, z=2.0)
  ignore(inside.clamp(@math.Vector3::new(), @math.Vector3::new(x=3.0, y=3.0, z=3.0)))
  assert_eq(inside.x, 2.0)
  assert_eq(inside.y, 2.0)
  assert_eq(inside.z, 2.0)
}

///|
test "clampScalar uses one range for every component" {
  let v = @math.Vector3::new(x=0.0, y=5.0, z=-2.0)
  ignore(v.clamp_scalar(1.0, 4.0))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 4.0)
  assert_eq(v.z, 1.0)
  let inside = @math.Vector3::new(x=2.0, y=3.0, z=4.0)
  ignore(inside.clamp_scalar(0.0, 5.0))
  assert_eq(inside.x, 2.0)
  assert_eq(inside.y, 3.0)
  assert_eq(inside.z, 4.0)
}

///|
test "clampLength limits the vector length" {
  let long = @math.Vector3::new(z=8.0)
  ignore(long.clamp_length(1.0, 2.0))
  assert_eq(long.x, 0.0)
  assert_eq(long.y, 0.0)
  assert_eq(long.z, 2.0)
  let short = @math.Vector3::new(z=0.5)
  ignore(short.clamp_length(1.0, 2.0))
  assert_eq(short.x, 0.0)
  assert_eq(short.y, 0.0)
  assert_eq(short.z, 1.0)
  let inside = @math.Vector3::new(z=4.0)
  ignore(inside.clamp_length(1.0, 8.0))
  assert_eq(inside.x, 0.0)
  assert_eq(inside.y, 0.0)
  assert_eq(inside.z, 4.0)
  let zero = @math.Vector3::new()
  ignore(zero.clamp_length(1.0, 2.0))
  assert_eq(zero.x, 0.0)
  assert_eq(zero.y, 0.0)
  assert_eq(zero.z, 0.0)
}

///|
test "floor rounds each component toward negative infinity" {
  let v = @math.Vector3::new(x=1.2, y=-1.2, z=3.0)
  ignore(v.floor())
  assert_eq(v.x, 1.0)
  assert_eq(v.y, -2.0)
  assert_eq(v.z, 3.0)
}

///|
test "ceil rounds each component toward positive infinity" {
  let v = @math.Vector3::new(x=1.2, y=-1.2, z=3.0)
  ignore(v.ceil())
  assert_eq(v.x, 2.0)
  assert_eq(v.y, -1.0)
  assert_eq(v.z, 3.0)
}

///|
test "round sends halfway cases toward positive infinity" {
  let v = @math.Vector3::new(x=1.5, y=-1.5, z=1.2)
  ignore(v.round())
  assert_eq(v.x, 2.0)
  assert_eq(v.y, -1.0)
  assert_eq(v.z, 1.0)
}

///|
test "roundToZero drops the fraction toward zero" {
  let v = @math.Vector3::new(x=1.8, y=-1.8, z=3.0)
  ignore(v.round_to_zero())
  assert_eq(v.x, 1.0)
  assert_eq(v.y, -1.0)
  assert_eq(v.z, 3.0)
}

///|
test "manhattanLength sums the absolute components" {
  let v = @math.Vector3::new(x=3.0, y=-4.0)
  assert_eq(v.manhattan_length(), 7.0)
  assert_eq(@math.Vector3::new().manhattan_length(), 0.0)
  assert_eq(v.x, 3.0)
  assert_eq(v.y, -4.0)
  assert_eq(v.z, 0.0)
}

///|
test "setLength rescales the vector and leaves zero unchanged" {
  let v = @math.Vector3::new(z=4.0)
  ignore(v.set_length(2.0))
  assert_eq(v.x, 0.0)
  assert_eq(v.y, 0.0)
  assert_eq(v.z, 2.0)
  ignore(v.set_length(0.0))
  assert_eq(v.z, 0.0)
  let zero = @math.Vector3::new()
  ignore(zero.set_length(5.0))
  assert_eq(zero.x, 0.0)
  assert_eq(zero.y, 0.0)
  assert_eq(zero.z, 0.0)
}

///|
test "lerpVectors stores the blend of two vectors" {
  let start = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  let end = @math.Vector3::new(x=5.0, y=6.0, z=7.0)
  let out = @math.Vector3::new(x=9.0)
  ignore(out.lerp_vectors(start, end, 0.25))
  assert_eq(out.x, 2.0)
  assert_eq(out.y, 3.0)
  assert_eq(out.z, 4.0)
  assert_eq(start.x, 1.0)
  assert_eq(end.z, 7.0)
  ignore(out.lerp_vectors(start, end, 0.0))
  assert_eq(out.x, 1.0)
  assert_eq(out.y, 2.0)
  assert_eq(out.z, 3.0)
  ignore(out.lerp_vectors(start, end, 1.0))
  assert_eq(out.x, 5.0)
  assert_eq(out.y, 6.0)
  assert_eq(out.z, 7.0)
}

///|
test "projectOnVector keeps the component along the target" {
  let v = @math.Vector3::new(x=2.0, y=3.0)
  let axis = @math.Vector3::new(x=4.0)
  ignore(v.project_on_vector(axis))
  assert_eq(v.x, 2.0)
  assert_eq(v.y, 0.0)
  assert_eq(v.z, 0.0)
  assert_eq(axis.x, 4.0)
  ignore(v.project_on_vector(@math.Vector3::new()))
  assert_eq(v.x, 0.0)
  assert_eq(v.y, 0.0)
  assert_eq(v.z, 0.0)
}

///|
test "projectOnPlane removes the component along the normal" {
  let v = @math.Vector3::new(x=2.0, y=3.0, z=4.0)
  let normal = @math.Vector3::new(y=4.0)
  ignore(v.project_on_plane(normal))
  assert_eq(v.x, 2.0)
  assert_eq(v.y, 0.0)
  assert_eq(v.z, 4.0)
  assert_eq(normal.y, 4.0)
  let kept = @math.Vector3::new(x=2.0, y=3.0, z=4.0)
  ignore(kept.project_on_plane(@math.Vector3::new()))
  assert_eq(kept.x, 2.0)
  assert_eq(kept.y, 3.0)
  assert_eq(kept.z, 4.0)
}

///|
test "reflect flips the component along the unit normal" {
  let v = @math.Vector3::new(x=1.0, y=-1.0)
  let normal = @math.Vector3::new(y=1.0)
  ignore(v.reflect(normal))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 1.0)
  assert_eq(v.z, 0.0)
  assert_eq(normal.y, 1.0)
}

///|
test "applyEuler rotates by the euler quaternion" {
  let right_angle = 1.5707963267948966
  let v = @math.Vector3::new(x=1.0)
  ignore(v.apply_euler(@math.Euler::new()))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 0.0)
  assert_eq(v.z, 0.0)
  ignore(v.apply_euler(@math.Euler::new(y=right_angle)))
  assert_close(v.x, 0.0)
  assert_close(v.y, 0.0)
  assert_close(v.z, -1.0)
}

///|
test "applyAxisAngle rotates around a unit axis" {
  let right_angle = 1.5707963267948966
  let axis = @math.Vector3::new(y=1.0)
  let v = @math.Vector3::new(x=1.0)
  ignore(v.apply_axis_angle(axis, 0.0))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 0.0)
  assert_eq(v.z, 0.0)
  ignore(v.apply_axis_angle(axis, right_angle))
  assert_close(v.x, 0.0)
  assert_close(v.y, 0.0)
  assert_close(v.z, -1.0)
  assert_eq(axis.y, 1.0)
}

///|
test "applyMatrix3 multiplies by a column-major 3x3 matrix" {
  let v = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  ignore(v.apply_matrix3(@math.Matrix3::new()))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 2.0)
  assert_eq(v.z, 3.0)
  let scale = @math.Matrix3::new().set(2.0, 0.0, 0.0, 0.0, 3.0, 0.0, 0.0, 0.0, 4.0)
  ignore(v.apply_matrix3(scale))
  assert_eq(v.x, 2.0)
  assert_eq(v.y, 6.0)
  assert_eq(v.z, 12.0)
  let mixed = @math.Matrix3::new().set(
    1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0,
  )
  let axis = @math.Vector3::new(x=1.0)
  ignore(axis.apply_matrix3(mixed))
  assert_eq(axis.x, 1.0)
  assert_eq(axis.y, 4.0)
  assert_eq(axis.z, 7.0)
}

///|
test "applyNormalMatrix multiplies and then normalizes" {
  let v = @math.Vector3::new(y=3.0, z=4.0)
  ignore(v.apply_normal_matrix(@math.Matrix3::new()))
  assert_eq(v.x, 0.0)
  assert_close(v.y, 0.6)
  assert_close(v.z, 0.8)
  let zero = @math.Vector3::new()
  ignore(zero.apply_normal_matrix(@math.Matrix3::new()))
  assert_eq(zero.x, 0.0)
  assert_eq(zero.y, 0.0)
  assert_eq(zero.z, 0.0)
}

///|
test "matrix compose and decompose match r186" {
  let position = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  let euler = @math.Euler::new(x=0.2, y=-0.4, z=0.6)
  let quaternion = @math.Quaternion::new().set_from_euler(euler)
  assert_close(quaternion.x, 0.0350558732382)
  assert_close(quaternion.y, -0.21776257154)
  assert_close(quaternion.z, 0.269234547391)
  assert_close(quaternion.w, 0.937477096616)
  let scale = @math.Vector3::new(x=2.0, y=3.0, z=4.0)
  let matrix = @math.Matrix4::new().compose(position, quaternion, scale)
  let expected = [
    1.52036888371, 0.979069458771, 0.854342701935, 0.0, -1.5602104734, 2.55770306546,
    -0.154590774748, 0.0, -1.55767336923, -0.7319462852, 3.6108043855, 0.0, 1.0,
    2.0, 3.0, 1.0,
  ]
  for i in 0..<16 {
    assert_close(matrix.elements[i], expected[i])
  }
  let out_position = @math.Vector3::new()
  let out_quaternion = @math.Quaternion::new()
  let out_scale = @math.Vector3::new()
  ignore(matrix.decompose(out_position, out_quaternion, out_scale))
  assert_eq(out_position.x, 1.0)
  assert_eq(out_position.y, 2.0)
  assert_eq(out_position.z, 3.0)
  assert_close(out_scale.x, 2.0)
  assert_close(out_scale.y, 3.0)
  assert_close(out_scale.z, 4.0)
  assert_close(out_quaternion.x, quaternion.x)
  assert_close(out_quaternion.y, quaternion.y)
  assert_close(out_quaternion.z, quaternion.z)
  assert_close(out_quaternion.w, quaternion.w)
}

///|
test "distanceTo is the square root of the squared distance" {
  let origin = @math.Vector3::new()
  let point = @math.Vector3::new(x=3.0, y=4.0)
  assert_eq(origin.distance_to(point), 5.0)
  assert_eq(point.distance_to(point), 0.0)
  assert_eq(point.x, 3.0)
  assert_eq(point.y, 4.0)
  assert_eq(point.z, 0.0)
}

///|
test "manhattanDistanceTo sums the absolute component differences" {
  let origin = @math.Vector3::new()
  let point = @math.Vector3::new(x=3.0, y=4.0)
  let signed = @math.Vector3::new(x=1.0, y=-2.0, z=3.0)
  assert_eq(origin.manhattan_distance_to(point), 7.0)
  assert_eq(origin.manhattan_distance_to(signed), 6.0)
  assert_eq(signed.manhattan_distance_to(signed), 0.0)
  assert_eq(signed.x, 1.0)
  assert_eq(signed.y, -2.0)
  assert_eq(signed.z, 3.0)
  assert_eq(point.x, 3.0)
  assert_eq(point.y, 4.0)
}

///|
test "setFromSphericalCoords uses y-up spherical coordinates" {
  let v = @math.Vector3::new(x=9.0)
  ignore(v.set_from_spherical_coords(5.0, 0.0, 1.0))
  assert_eq(v.x, 0.0)
  assert_eq(v.y, 5.0)
  assert_eq(v.z, 0.0)
  ignore(v.set_from_spherical_coords(2.0, 1.5707963267948966, 0.0))
  assert_close(v.x, 0.0)
  assert_close(v.y, 0.0)
  assert_close(v.z, 2.0)
  ignore(v.set_from_spherical_coords(2.0, 1.5707963267948966, 1.5707963267948966))
  assert_close(v.x, 2.0)
  assert_close(v.y, 0.0)
  assert_close(v.z, 0.0)
  ignore(v.set_from_spherical_coords(4.0, 0.5, -0.3))
  assert_close(v.x, -0.5667197369881524)
  assert_close(v.y, 3.510330247561491)
  assert_close(v.z, 1.832050843389168)
}

///|
test "setFromSpherical copies radius phi and theta" {
  let v = @math.Vector3::new(x=9.0)
  let s = @math.Spherical::new(radius=5.0, phi=0.0, theta=1.0)
  ignore(v.set_from_spherical(s))
  assert_eq(v.x, 0.0)
  assert_eq(v.y, 5.0)
  assert_eq(v.z, 0.0)
  assert_eq(s.radius, 5.0)
  assert_eq(s.phi, 0.0)
  assert_eq(s.theta, 1.0)
  let defaults = @math.Spherical::new()
  assert_eq(defaults.radius, 1.0)
  assert_eq(defaults.phi, 0.0)
  assert_eq(defaults.theta, 0.0)
}

///|
test "Spherical.set writes radius phi and theta" {
  let s = @math.Spherical::new()
  ignore(s.set(2.0, 0.5, -0.3))
  assert_eq(s.radius, 2.0)
  assert_eq(s.phi, 0.5)
  assert_eq(s.theta, -0.3)
}

///|
test "Spherical.copy copies radius phi and theta" {
  let source = @math.Spherical::new(radius=2.0, phi=0.5, theta=-0.3)
  let s = @math.Spherical::new()
  ignore(s.copy(source))
  assert_eq(s.radius, 2.0)
  assert_eq(s.phi, 0.5)
  assert_eq(s.theta, -0.3)
  assert_eq(source.radius, 2.0)
  assert_eq(source.phi, 0.5)
  assert_eq(source.theta, -0.3)
}

///|
test "Spherical.makeSafe clamps phi away from the poles" {
  let eps = 0.000001
  let low = @math.Spherical::new(radius=2.0, phi=0.0, theta=-0.3)
  ignore(low.make_safe())
  assert_eq(low.phi, eps)
  assert_eq(low.radius, 2.0)
  assert_eq(low.theta, -0.3)
  let high = @math.Spherical::new(phi=3.141592653589793)
  ignore(high.make_safe())
  assert_eq(high.phi, 3.141592653589793 - eps)
  let kept = @math.Spherical::new(phi=0.5)
  ignore(kept.make_safe())
  assert_eq(kept.phi, 0.5)
}

///|
test "setFromCartesianCoords recovers y-up spherical coordinates" {
  let origin = @math.Spherical::new(radius=9.0, phi=1.0, theta=1.0)
  ignore(origin.set_from_cartesian_coords(0.0, 0.0, 0.0))
  assert_eq(origin.radius, 0.0)
  assert_eq(origin.phi, 0.0)
  assert_eq(origin.theta, 0.0)
  let up = @math.Spherical::new()
  ignore(up.set_from_cartesian_coords(0.0, 5.0, 0.0))
  assert_eq(up.radius, 5.0)
  assert_eq(up.phi, 0.0)
  assert_eq(up.theta, 0.0)
  let forward = @math.Spherical::new()
  ignore(forward.set_from_cartesian_coords(0.0, 0.0, 2.0))
  assert_eq(forward.radius, 2.0)
  assert_close(forward.phi, 1.5707963267948966)
  assert_eq(forward.theta, 0.0)
  let right = @math.Spherical::new()
  ignore(right.set_from_cartesian_coords(2.0, 0.0, 0.0))
  assert_eq(right.radius, 2.0)
  assert_close(right.phi, 1.5707963267948966)
  assert_close(right.theta, 1.5707963267948966)
  let tilted = @math.Spherical::new()
  ignore(
    tilted.set_from_cartesian_coords(
      -0.5667197369881524,
      3.510330247561491,
      1.832050843389168,
    ),
  )
  assert_close(tilted.radius, 4.0)
  assert_close(tilted.phi, 0.5)
  assert_close(tilted.theta, -0.3)
}

///|
test "setFromVector3 reads the vector components" {
  let s = @math.Spherical::new(radius=9.0, phi=1.0, theta=1.0)
  let up = @math.Vector3::new(y=5.0)
  ignore(s.set_from_vector3(up))
  assert_eq(s.radius, 5.0)
  assert_eq(s.phi, 0.0)
  assert_eq(s.theta, 0.0)
  assert_eq(up.y, 5.0)
  let origin = @math.Vector3::new()
  ignore(s.set_from_vector3(origin))
  assert_eq(s.radius, 0.0)
  assert_eq(s.phi, 0.0)
  assert_eq(s.theta, 0.0)
}

///|
test "Spherical.clone copies radius phi and theta" {
  let source = @math.Spherical::new(radius=2.0, phi=0.5, theta=-0.3)
  let cloned = source.clone()
  assert_eq(cloned.radius, 2.0)
  assert_eq(cloned.phi, 0.5)
  assert_eq(cloned.theta, -0.3)
  ignore(cloned.set(1.0, 0.0, 0.0))
  assert_eq(source.radius, 2.0)
  assert_eq(source.phi, 0.5)
  assert_eq(source.theta, -0.3)
}

///|
test "setFromCylindricalCoords uses a y-up cylinder" {
  let v = @math.Vector3::new(x=9.0)
  ignore(v.set_from_cylindrical_coords(2.0, 0.0, 5.0))
  assert_eq(v.x, 0.0)
  assert_eq(v.y, 5.0)
  assert_eq(v.z, 2.0)
  ignore(v.set_from_cylindrical_coords(2.0, 1.5707963267948966, -1.0))
  assert_close(v.x, 2.0)
  assert_eq(v.y, -1.0)
  assert_close(v.z, 0.0)
  ignore(v.set_from_cylindrical_coords(3.0, -0.3, 1.0))
  assert_close(v.x, -0.8865606199840186)
  assert_eq(v.y, 1.0)
  assert_close(v.z, 2.866009467376818)
}

///|
test "setFromCylindrical copies radius theta and height" {
  let v = @math.Vector3::new(x=9.0)
  let c = @math.Cylindrical::new(radius=2.0, theta=0.0, y=5.0)
  ignore(v.set_from_cylindrical(c))
  assert_eq(v.x, 0.0)
  assert_eq(v.y, 5.0)
  assert_eq(v.z, 2.0)
  assert_eq(c.radius, 2.0)
  assert_eq(c.theta, 0.0)
  assert_eq(c.y, 5.0)
  let defaults = @math.Cylindrical::new()
  assert_eq(defaults.radius, 1.0)
  assert_eq(defaults.theta, 0.0)
  assert_eq(defaults.y, 0.0)
}

///|
test "Cylindrical.set writes radius theta and height" {
  let c = @math.Cylindrical::new()
  ignore(c.set(2.0, -0.3, 5.0))
  assert_eq(c.radius, 2.0)
  assert_eq(c.theta, -0.3)
  assert_eq(c.y, 5.0)
}

///|
test "Cylindrical.copy copies radius theta and height" {
  let source = @math.Cylindrical::new(radius=2.0, theta=-0.3, y=5.0)
  let c = @math.Cylindrical::new()
  ignore(c.copy(source))
  assert_eq(c.radius, 2.0)
  assert_eq(c.theta, -0.3)
  assert_eq(c.y, 5.0)
  assert_eq(source.radius, 2.0)
  assert_eq(source.theta, -0.3)
  assert_eq(source.y, 5.0)
}

///|
test "setFromCartesianCoords recovers a y-up cylinder" {
  let forward = @math.Cylindrical::new()
  ignore(forward.set_from_cartesian_coords(0.0, 5.0, 2.0))
  assert_eq(forward.radius, 2.0)
  assert_eq(forward.theta, 0.0)
  assert_eq(forward.y, 5.0)
  let right = @math.Cylindrical::new()
  ignore(right.set_from_cartesian_coords(2.0, -1.0, 0.0))
  assert_eq(right.radius, 2.0)
  assert_close(right.theta, 1.5707963267948966)
  assert_eq(right.y, -1.0)
  let origin = @math.Cylindrical::new(radius=9.0, theta=1.0, y=4.0)
  ignore(origin.set_from_cartesian_coords(0.0, 0.0, 0.0))
  assert_eq(origin.radius, 0.0)
  assert_eq(origin.theta, 0.0)
  assert_eq(origin.y, 0.0)
  let tilted = @math.Cylindrical::new()
  ignore(
    tilted.set_from_cartesian_coords(-0.8865606199840186, 1.0, 2.866009467376818),
  )
  assert_close(tilted.radius, 3.0)
  assert_close(tilted.theta, -0.3)
  assert_eq(tilted.y, 1.0)
}

///|
test "Cylindrical.setFromVector3 reads the vector components" {
  let c = @math.Cylindrical::new(radius=9.0, theta=1.0, y=4.0)
  let forward = @math.Vector3::new(y=5.0, z=2.0)
  ignore(c.set_from_vector3(forward))
  assert_eq(c.radius, 2.0)
  assert_eq(c.theta, 0.0)
  assert_eq(c.y, 5.0)
  assert_eq(forward.y, 5.0)
  assert_eq(forward.z, 2.0)
}

///|
test "Cylindrical.clone copies radius theta and height" {
  let source = @math.Cylindrical::new(radius=2.0, theta=-0.3, y=5.0)
  let cloned = source.clone()
  assert_eq(cloned.radius, 2.0)
  assert_eq(cloned.theta, -0.3)
  assert_eq(cloned.y, 5.0)
  ignore(cloned.set(1.0, 0.0, 0.0))
  assert_eq(source.radius, 2.0)
  assert_eq(source.theta, -0.3)
  assert_eq(source.y, 5.0)
}

///|
test "Vector2.setScalar writes the same value into both components" {
  let v = @math.Vector2::new(x=1.0, y=2.0)
  ignore(v.set_scalar(4.0))
  assert_eq(v.x, 4.0)
  assert_eq(v.y, 4.0)
}

///|
test "Vector2.setX writes x and leaves y" {
  let v = @math.Vector2::new(x=1.0, y=2.0)
  ignore(v.set_x(9.0))
  assert_eq(v.x, 9.0)
  assert_eq(v.y, 2.0)
}

///|
test "Vector2.setY writes y and leaves x" {
  let v = @math.Vector2::new(x=1.0, y=2.0)
  ignore(v.set_y(8.0))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 8.0)
}

///|
test "Vector2.setComponent writes x or y" {
  let v = @math.Vector2::new(x=1.0, y=2.0)
  ignore(v.set_component(1, 8.0))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 8.0)
  ignore(v.set_component(0, 9.0))
  assert_eq(v.x, 9.0)
  assert_eq(v.y, 8.0)
}

///|
test "panic Vector2 component index past y" {
  ignore(@math.Vector2::new().set_component(2, 1.0))
}

///|
test "Vector2.getComponent reads x or y" {
  let v = @math.Vector2::new(x=1.0, y=2.0)
  assert_eq(v.get_component(0), 1.0)
  assert_eq(v.get_component(1), 2.0)
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 2.0)
}

///|
test "Vector2.addScalar adds one number to both components" {
  let v = @math.Vector2::new(x=1.0, y=2.0)
  ignore(v.add_scalar(4.0))
  assert_eq(v.x, 5.0)
  assert_eq(v.y, 6.0)
  ignore(v.add_scalar(-1.0))
  assert_eq(v.x, 4.0)
  assert_eq(v.y, 5.0)
}

///|
test "Vector2.addVectors stores the sum of two vectors" {
  let a = @math.Vector2::new(x=1.0, y=2.0)
  let b = @math.Vector2::new(x=3.0, y=4.0)
  let sum = @math.Vector2::new(x=9.0, y=9.0)
  ignore(sum.add_vectors(a, b))
  assert_eq(sum.x, 4.0)
  assert_eq(sum.y, 6.0)
  assert_eq(a.x, 1.0)
  assert_eq(b.y, 4.0)
  ignore(a.add_vectors(a, b))
  assert_eq(a.x, 4.0)
  assert_eq(a.y, 6.0)
  assert_eq(b.x, 3.0)
}

///|
test "Vector2.addScaledVector adds a scaled vector" {
  let v = @math.Vector2::new(x=1.0, y=2.0)
  let extra = @math.Vector2::new(x=4.0, y=5.0)
  ignore(v.add_scaled_vector(extra, 2.0))
  assert_eq(v.x, 9.0)
  assert_eq(v.y, 12.0)
  assert_eq(extra.x, 4.0)
  assert_eq(extra.y, 5.0)
}

///|
test "Vector2.subScalar subtracts one number from both components" {
  let v = @math.Vector2::new(x=5.0, y=6.0)
  ignore(v.sub_scalar(4.0))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 2.0)
  ignore(v.sub_scalar(-1.0))
  assert_eq(v.x, 2.0)
  assert_eq(v.y, 3.0)
}

///|
test "Vector2.subVectors stores the difference of two vectors" {
  let a = @math.Vector2::new(x=5.0, y=6.0)
  let b = @math.Vector2::new(x=1.0, y=2.0)
  let diff = @math.Vector2::new(x=9.0, y=9.0)
  ignore(diff.sub_vectors(a, b))
  assert_eq(diff.x, 4.0)
  assert_eq(diff.y, 4.0)
  assert_eq(a.x, 5.0)
  assert_eq(b.y, 2.0)
  ignore(a.sub_vectors(a, b))
  assert_eq(a.x, 4.0)
  assert_eq(a.y, 4.0)
  assert_eq(b.x, 1.0)
}

///|
test "Vector2.multiply multiplies matching components" {
  let v = @math.Vector2::new(x=2.0, y=4.0)
  let factor = @math.Vector2::new(x=5.0, y=6.0)
  ignore(v.multiply(factor))
  assert_eq(v.x, 10.0)
  assert_eq(v.y, 24.0)
  assert_eq(factor.x, 5.0)
  assert_eq(factor.y, 6.0)
}

///|
test "Vector2.divide divides matching components" {
  let v = @math.Vector2::new(x=10.0, y=24.0)
  let factor = @math.Vector2::new(x=5.0, y=6.0)
  ignore(v.divide(factor))
  assert_eq(v.x, 2.0)
  assert_eq(v.y, 4.0)
  assert_eq(factor.x, 5.0)
  assert_eq(factor.y, 6.0)
}

///|
test "Vector2.divideScalar divides both components" {
  let v = @math.Vector2::new(x=2.0, y=4.0)
  ignore(v.divide_scalar(2.0))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 2.0)
  ignore(v.divide_scalar(-1.0))
  assert_eq(v.x, -1.0)
  assert_eq(v.y, -2.0)
}

///|
test "Vector2.applyMatrix3 uses an implicit z of 1" {
  let v = @math.Vector2::new(x=1.0, y=2.0)
  ignore(v.apply_matrix3(@math.Matrix3::new()))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 2.0)
  let shift = @math.Matrix3::new().set(1.0, 0.0, 3.0, 0.0, 1.0, 4.0, 0.0, 0.0, 1.0)
  ignore(v.apply_matrix3(shift))
  assert_eq(v.x, 4.0)
  assert_eq(v.y, 6.0)
  let mixed = @math.Matrix3::new().set(
    1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0,
  )
  let axis = @math.Vector2::new(x=1.0)
  ignore(axis.apply_matrix3(mixed))
  assert_eq(axis.x, 4.0)
  assert_eq(axis.y, 10.0)
}

///|
test "Vector2.min keeps the smaller component" {
  let v = @math.Vector2::new(x=0.0, y=5.0)
  let bound = @math.Vector2::new(x=1.0, y=4.0)
  ignore(v.min(bound))
  assert_eq(v.x, 0.0)
  assert_eq(v.y, 4.0)
  assert_eq(bound.x, 1.0)
  assert_eq(bound.y, 4.0)
}

///|
test "Vector2.max keeps the larger component" {
  let v = @math.Vector2::new(x=0.0, y=5.0)
  let bound = @math.Vector2::new(x=1.0, y=4.0)
  ignore(v.max(bound))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 5.0)
  assert_eq(bound.x, 1.0)
  assert_eq(bound.y, 4.0)
}

///|
test "Vector2.clamp limits each component" {
  let v = @math.Vector2::new(x=0.0, y=5.0)
  let low = @math.Vector2::new(x=1.0, y=0.0)
  let high = @math.Vector2::new(x=3.0, y=4.0)
  ignore(v.clamp(low, high))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 4.0)
  assert_eq(low.x, 1.0)
  assert_eq(high.y, 4.0)
  let inside = @math.Vector2::new(x=2.0, y=2.0)
  ignore(
    inside.clamp(@math.Vector2::new(), @math.Vector2::new(x=3.0, y=3.0)),
  )
  assert_eq(inside.x, 2.0)
  assert_eq(inside.y, 2.0)
}

///|
test "Vector2.clampScalar limits both components" {
  let v = @math.Vector2::new(x=0.0, y=5.0)
  ignore(v.clamp_scalar(1.0, 4.0))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 4.0)
  let inside = @math.Vector2::new(x=2.0, y=3.0)
  ignore(inside.clamp_scalar(0.0, 5.0))
  assert_eq(inside.x, 2.0)
  assert_eq(inside.y, 3.0)
}

///|
test "Vector2.clampLength limits the vector length" {
  let long = @math.Vector2::new(y=4.0)
  ignore(long.clamp_length(1.0, 2.0))
  assert_eq(long.x, 0.0)
  assert_eq(long.y, 2.0)
  let short = @math.Vector2::new(y=0.5)
  ignore(short.clamp_length(1.0, 2.0))
  assert_eq(short.x, 0.0)
  assert_eq(short.y, 1.0)
  let kept = @math.Vector2::new(y=4.0)
  ignore(kept.clamp_length(1.0, 8.0))
  assert_eq(kept.y, 4.0)
  let zero = @math.Vector2::new()
  ignore(zero.clamp_length(1.0, 2.0))
  assert_eq(zero.x, 0.0)
  assert_eq(zero.y, 0.0)
}

///|
test "Vector2.floor rounds toward negative infinity" {
  let v = @math.Vector2::new(x=1.2, y=-1.2)
  ignore(v.floor())
  assert_eq(v.x, 1.0)
  assert_eq(v.y, -2.0)
}

///|
test "Vector2.ceil rounds toward positive infinity" {
  let v = @math.Vector2::new(x=1.2, y=-1.2)
  ignore(v.ceil())
  assert_eq(v.x, 2.0)
  assert_eq(v.y, -1.0)
}

///|
test "Vector2.round rounds halfway toward positive infinity" {
  let v = @math.Vector2::new(x=1.5, y=-1.5)
  ignore(v.round())
  assert_eq(v.x, 2.0)
  assert_eq(v.y, -1.0)
}

///|
test "Vector2.roundToZero drops the fraction toward zero" {
  let v = @math.Vector2::new(x=1.8, y=-1.8)
  ignore(v.round_to_zero())
  assert_eq(v.x, 1.0)
  assert_eq(v.y, -1.0)
}

///|
test "Vector2.negate flips both components" {
  let v = @math.Vector2::new(x=1.0, y=-2.0)
  ignore(v.negate())
  assert_eq(v.x, -1.0)
  assert_eq(v.y, 2.0)
}

///|
test "Vector2.cross returns the z component" {
  let a = @math.Vector2::new(x=2.0, y=3.0)
  let b = @math.Vector2::new(x=4.0, y=5.0)
  assert_eq(a.cross(b), -2.0)
  assert_eq(a.x, 2.0)
  assert_eq(a.y, 3.0)
  assert_eq(b.x, 4.0)
  assert_eq(b.y, 5.0)
  assert_eq(@math.Vector2::new(x=1.0).cross(@math.Vector2::new(y=1.0)), 1.0)
}

///|
test "Vector2.manhattanLength sums the absolute components" {
  let v = @math.Vector2::new(x=3.0, y=-4.0)
  assert_eq(v.manhattan_length(), 7.0)
  assert_eq(v.x, 3.0)
  assert_eq(v.y, -4.0)
  assert_eq(@math.Vector2::new().manhattan_length(), 0.0)
}

///|
test "panic Vector2 getComponent index past y" {
  ignore(@math.Vector2::new().get_component(2))
}

///|
test "setFromMatrixScale reads the column lengths" {
  let scale = @math.Vector3::new(x=2.0, y=3.0, z=4.0)
  let matrix = @math.Matrix4::new().compose(
    @math.Vector3::new(x=10.0),
    @math.Quaternion::new(),
    scale,
  )
  let v = @math.Vector3::new(x=9.0, y=9.0, z=9.0)
  ignore(v.set_from_matrix_scale(matrix))
  assert_eq(v.x, 2.0)
  assert_eq(v.y, 3.0)
  assert_eq(v.z, 4.0)
  ignore(scale.set(-2.0, 3.0, 4.0))
  ignore(matrix.compose(@math.Vector3::new(), @math.Quaternion::new(), scale))
  ignore(v.set_from_matrix_scale(matrix))
  assert_eq(v.x, 2.0)
  assert_eq(v.y, 3.0)
  assert_eq(v.z, 4.0)
}

///|
test "setFromMatrix3Column reads one column" {
  let matrix = @math.Matrix3::new().set(
    1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0,
  )
  let v = @math.Vector3::new(x=9.0)
  ignore(v.set_from_matrix3_column(matrix, 0))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 4.0)
  assert_eq(v.z, 7.0)
  ignore(v.set_from_matrix3_column(matrix, 1))
  assert_eq(v.x, 2.0)
  assert_eq(v.y, 5.0)
  assert_eq(v.z, 8.0)
  ignore(v.set_from_matrix3_column(matrix, 2))
  assert_eq(v.x, 3.0)
  assert_eq(v.y, 6.0)
  assert_eq(v.z, 9.0)
}

///|
test "setFromEuler copies the three angles" {
  let euler = @math.Euler::new(x=0.2, y=-0.4, z=0.6, order=@math.EulerOrder::YXZ)
  let v = @math.Vector3::new(x=9.0, y=8.0, z=7.0)
  ignore(v.set_from_euler(euler))
  assert_eq(v.x, 0.2)
  assert_eq(v.y, -0.4)
  assert_eq(v.z, 0.6)
  ignore(euler.set(1.0, 2.0, 3.0))
  assert_eq(v.x, 0.2)
  assert_eq(v.y, -0.4)
  assert_eq(v.z, 0.6)
}

///|
test "setFromColor copies the stored linear channels" {
  let color = @math.Color::new(r=0.25, g=0.5, b=0.75)
  let v = @math.Vector3::new(x=9.0, y=8.0, z=7.0)
  ignore(v.set_from_color(color))
  assert_eq(v.x, 0.25)
  assert_eq(v.y, 0.5)
  assert_eq(v.z, 0.75)
  ignore(color.set_rgb(1.0, 0.0, 0.0))
  assert_eq(v.x, 0.25)
  assert_eq(v.y, 0.5)
  assert_eq(v.z, 0.75)
}

///|
test "fromArray reads three components at an offset" {
  let values = [1.0, 2.0, 3.0, 4.0, 5.0]
  let v = @math.Vector3::new(x=9.0, y=8.0, z=7.0)
  ignore(v.from_array(values))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 2.0)
  assert_eq(v.z, 3.0)
  ignore(v.from_array(values, offset=2))
  assert_eq(v.x, 3.0)
  assert_eq(v.y, 4.0)
  assert_eq(v.z, 5.0)
  assert_eq(values[0], 1.0)
  assert_eq(values[4], 5.0)
}

///|
test "toArray writes three components at an offset" {
  let v = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  let fresh = v.to_array()
  assert_eq(fresh.length(), 3)
  assert_eq(fresh[0], 1.0)
  assert_eq(fresh[1], 2.0)
  assert_eq(fresh[2], 3.0)
  let values = [9.0, 8.0, 7.0, 6.0, 5.0]
  let written = v.to_array(array=values, offset=1)
  assert_eq(physical_equal(written, values), true)
  assert_eq(values[0], 9.0)
  assert_eq(values[1], 1.0)
  assert_eq(values[2], 2.0)
  assert_eq(values[3], 3.0)
  assert_eq(values[4], 5.0)
  let short = [4.0]
  ignore(v.to_array(array=short, offset=2))
  assert_eq(short.length(), 5)
  assert_eq(short[0], 4.0)
  assert_eq(short[1], 0.0)
  assert_eq(short[2], 1.0)
  assert_eq(short[3], 2.0)
  assert_eq(short[4], 3.0)
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 2.0)
  assert_eq(v.z, 3.0)
}

///|
test "angleTo matches the right angle and the zero vector" {
  let axis = @math.Vector3::new(x=1.0)
  assert_eq(axis.angle_to(axis), 0.0)
  assert_close(axis.angle_to(@math.Vector3::new(z=-1.0)), 1.5707963267948966)
  assert_close(axis.angle_to(@math.Vector3::new(x=-1.0)), 3.141592653589793)
  assert_close(
    axis.angle_to(@math.Vector3::new(x=1.0, y=1.0)),
    0.7853981633974483,
  )
  assert_close(@math.Vector3::new().angle_to(axis), 1.5707963267948966)
  assert_eq(axis.x, 1.0)
}

///|
test "transformDirection uses the upper 3x3 and normalizes" {
  let translated = @math.Matrix4::new().compose(
    @math.Vector3::new(x=10.0),
    @math.Quaternion::new(),
    @math.Vector3::new(x=1.0, y=1.0, z=1.0),
  )
  let forward = @math.Vector3::new(z=1.0)
  ignore(forward.transform_direction(translated))
  assert_eq(forward.x, 0.0)
  assert_eq(forward.y, 0.0)
  assert_eq(forward.z, 1.0)
  let yaw = @math.Quaternion::new().set_from_axis_angle(
    @math.Vector3::new(y=1.0),
    1.5707963267948966,
  )
  let turned = @math.Matrix4::new().make_rotation_from_quaternion(yaw)
  let axis = @math.Vector3::new(x=1.0)
  ignore(axis.transform_direction(turned))
  assert_close(axis.x, 0.0)
  assert_close(axis.y, 0.0)
  assert_close(axis.z, -1.0)
  let scaled = @math.Matrix4::new().compose(
    @math.Vector3::new(),
    @math.Quaternion::new(),
    @math.Vector3::new(x=2.0, y=1.0, z=1.0),
  )
  let diagonal = @math.Vector3::new(x=1.0, y=1.0)
  ignore(diagonal.transform_direction(scaled))
  assert_close(diagonal.x, 0.894427190999916)
  assert_close(diagonal.y, 0.447213595499958)
  assert_close(diagonal.z, 0.0)
}

///|
test "applyQuaternion rotates a unit axis" {
  let axis = @math.Vector3::new(x=1.0)
  let turn = @math.Quaternion::new().set_from_axis_angle(
    @math.Vector3::new(y=1.0),
    1.5707963267948966,
  )
  ignore(axis.apply_quaternion(turn))
  assert_close(axis.x, 0.0)
  assert_close(axis.y, 0.0)
  assert_close(axis.z, -1.0)
}

///|
test "color hex follows r186 linear working space" {
  let green = @math.Color::new().set_hex(0x00FF00)
  assert_eq(green.r, 0.0)
  assert_eq(green.g, 1.0)
  assert_eq(green.b, 0.0)
  assert_eq(green.get_hex(), 65280)
  let orange = @math.Color::new().set_hex(0xFF8800)
  assert_close(orange.r, 1.0)
  assert_close(orange.g, 0.246201326697)
  assert_eq(orange.b, 0.0)
  assert_eq(orange.get_hex(), 16746496)
}
