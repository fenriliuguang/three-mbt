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
test "Vector2.angle is measured from the positive x axis" {
  let right = @math.Vector2::new(x=1.0)
  assert_eq(right.angle(), 0.0)
  assert_eq(right.x, 1.0)
  assert_close(@math.Vector2::new(y=1.0).angle(), 1.5707963267948966)
  assert_close(@math.Vector2::new(x=-1.0).angle(), 3.141592653589793)
  assert_close(@math.Vector2::new(y=-1.0).angle(), 4.71238898038469)
}

///|
test "Vector2.angleTo is the angle between two vectors" {
  let axis = @math.Vector2::new(x=1.0)
  assert_eq(axis.angle_to(axis), 0.0)
  assert_eq(axis.x, 1.0)
  assert_close(axis.angle_to(@math.Vector2::new(y=1.0)), 1.5707963267948966)
  assert_close(axis.angle_to(@math.Vector2::new(x=-1.0)), 3.141592653589793)
  assert_close(
    axis.angle_to(@math.Vector2::new(x=1.0, y=1.0)),
    0.7853981633974483,
  )
  assert_close(@math.Vector2::new().angle_to(axis), 1.5707963267948966)
}

///|
test "Vector2.distanceToSquared is the squared separation" {
  let origin = @math.Vector2::new()
  let point = @math.Vector2::new(x=3.0, y=4.0)
  assert_eq(origin.distance_to_squared(point), 25.0)
  assert_eq(point.distance_to_squared(point), 0.0)
  assert_eq(origin.x, 0.0)
  assert_eq(point.y, 4.0)
}

///|
test "Vector2.distanceTo is the straight-line separation" {
  let origin = @math.Vector2::new()
  let point = @math.Vector2::new(x=3.0, y=4.0)
  assert_eq(origin.distance_to(point), 5.0)
  assert_eq(point.distance_to(point), 0.0)
  assert_eq(origin.y, 0.0)
  assert_eq(point.x, 3.0)
}

///|
test "Vector2.manhattanDistanceTo sums the absolute differences" {
  let origin = @math.Vector2::new()
  let point = @math.Vector2::new(x=3.0, y=4.0)
  let signed = @math.Vector2::new(x=1.0, y=-2.0)
  assert_eq(origin.manhattan_distance_to(point), 7.0)
  assert_eq(origin.manhattan_distance_to(signed), 3.0)
  assert_eq(signed.manhattan_distance_to(signed), 0.0)
  assert_eq(point.x, 3.0)
  assert_eq(signed.y, -2.0)
}

///|
test "Vector2.setLength rescales along the same direction" {
  let v = @math.Vector2::new(y=4.0)
  ignore(v.set_length(2.0))
  assert_eq(v.x, 0.0)
  assert_eq(v.y, 2.0)
  ignore(v.set_length(0.0))
  assert_eq(v.x, 0.0)
  assert_eq(v.y, 0.0)
  let zero = @math.Vector2::new()
  ignore(zero.set_length(5.0))
  assert_eq(zero.x, 0.0)
  assert_eq(zero.y, 0.0)
}

///|
test "Vector2.lerpVectors stores a blend of two vectors" {
  let a = @math.Vector2::new(x=1.0, y=2.0)
  let b = @math.Vector2::new(x=5.0, y=6.0)
  let v = @math.Vector2::new(x=9.0, y=9.0)
  ignore(v.lerp_vectors(a, b, 0.25))
  assert_eq(v.x, 2.0)
  assert_eq(v.y, 3.0)
  assert_eq(a.x, 1.0)
  assert_eq(b.y, 6.0)
  ignore(v.lerp_vectors(a, b, 0.0))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 2.0)
  ignore(v.lerp_vectors(a, b, 1.0))
  assert_eq(v.x, 5.0)
  assert_eq(v.y, 6.0)
}

///|
test "Vector2.fromArray reads two components at an offset" {
  let array = [1.0, 2.0, 3.0, 4.0, 5.0]
  let v = @math.Vector2::new(x=9.0, y=9.0)
  ignore(v.from_array(array))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 2.0)
  ignore(v.from_array(array, offset=2))
  assert_eq(v.x, 3.0)
  assert_eq(v.y, 4.0)
  assert_eq(array[0], 1.0)
  assert_eq(array[4], 5.0)
}

///|
test "Vector2.toArray writes two components at an offset" {
  let v = @math.Vector2::new(x=1.0, y=2.0)
  let fresh = v.to_array()
  assert_eq(fresh.length(), 2)
  assert_eq(fresh[0], 1.0)
  assert_eq(fresh[1], 2.0)
  let array = [9.0, 8.0, 7.0, 6.0]
  let written = v.to_array(array=array, offset=1)
  assert_eq(physical_equal(written, array), true)
  assert_eq(written[0], 9.0)
  assert_eq(written[1], 1.0)
  assert_eq(written[2], 2.0)
  assert_eq(written[3], 6.0)
  let short = [9.0]
  let padded = v.to_array(array=short, offset=1)
  assert_eq(padded.length(), 3)
  assert_eq(padded[0], 9.0)
  assert_eq(padded[1], 1.0)
  assert_eq(padded[2], 2.0)
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 2.0)
}

///|
test "Vector2.rotateAround turns counterclockwise about a center" {
  let right_angle = 1.5707963267948966
  let v = @math.Vector2::new(x=1.0, y=2.0)
  let origin = @math.Vector2::new()
  ignore(v.rotate_around(origin, 0.0))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 2.0)
  let axis = @math.Vector2::new(x=1.0)
  ignore(axis.rotate_around(origin, right_angle))
  assert_close(axis.x, 0.0)
  assert_close(axis.y, 1.0)
  assert_eq(origin.x, 0.0)
  let center = @math.Vector2::new(x=1.0, y=1.0)
  let point = @math.Vector2::new(x=2.0, y=1.0)
  ignore(point.rotate_around(center, right_angle))
  assert_close(point.x, 1.0)
  assert_close(point.y, 2.0)
  assert_eq(center.x, 1.0)
  assert_eq(center.y, 1.0)
}

///|
test "Vector4.setScalar writes the same value into every component" {
  let v = @math.Vector4::new(x=1.0, y=2.0, z=3.0, w=4.0)
  ignore(v.set_scalar(5.0))
  assert_eq(v.x, 5.0)
  assert_eq(v.y, 5.0)
  assert_eq(v.z, 5.0)
  assert_eq(v.w, 5.0)
}

///|
test "Vector4.setX writes x and leaves the rest" {
  let v = @math.Vector4::new(x=1.0, y=2.0, z=3.0, w=4.0)
  ignore(v.set_x(9.0))
  assert_eq(v.x, 9.0)
  assert_eq(v.y, 2.0)
  assert_eq(v.z, 3.0)
  assert_eq(v.w, 4.0)
}

///|
test "Vector4.setY writes y and leaves the rest" {
  let v = @math.Vector4::new(x=1.0, y=2.0, z=3.0, w=4.0)
  ignore(v.set_y(8.0))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 8.0)
  assert_eq(v.z, 3.0)
  assert_eq(v.w, 4.0)
}

///|
test "Vector4.setZ writes z and leaves the rest" {
  let v = @math.Vector4::new(x=1.0, y=2.0, z=3.0, w=4.0)
  ignore(v.set_z(7.0))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 2.0)
  assert_eq(v.z, 7.0)
  assert_eq(v.w, 4.0)
}

///|
test "Vector4.setW writes w and leaves the rest" {
  let v = @math.Vector4::new(x=1.0, y=2.0, z=3.0, w=4.0)
  ignore(v.set_w(6.0))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 2.0)
  assert_eq(v.z, 3.0)
  assert_eq(v.w, 6.0)
}

///|
test "Vector4.setComponent writes x, y, z, or w" {
  let v = @math.Vector4::new(x=1.0, y=2.0, z=3.0, w=4.0)
  ignore(v.set_component(3, 6.0))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 2.0)
  assert_eq(v.z, 3.0)
  assert_eq(v.w, 6.0)
  ignore(v.set_component(2, 7.0))
  assert_eq(v.z, 7.0)
  ignore(v.set_component(1, 8.0))
  assert_eq(v.y, 8.0)
  ignore(v.set_component(0, 9.0))
  assert_eq(v.x, 9.0)
  assert_eq(v.y, 8.0)
  assert_eq(v.z, 7.0)
  assert_eq(v.w, 6.0)
}

///|
test "panic Vector4 component index past w" {
  ignore(@math.Vector4::new().set_component(4, 1.0))
}

///|
test "Vector4.getComponent reads x, y, z, or w" {
  let v = @math.Vector4::new(x=1.0, y=2.0, z=3.0, w=4.0)
  assert_eq(v.get_component(0), 1.0)
  assert_eq(v.get_component(1), 2.0)
  assert_eq(v.get_component(2), 3.0)
  assert_eq(v.get_component(3), 4.0)
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 2.0)
  assert_eq(v.z, 3.0)
  assert_eq(v.w, 4.0)
}

///|
test "panic Vector4 getComponent index past w" {
  ignore(@math.Vector4::new().get_component(4))
}

///|
test "Vector4.add adds another vector" {
  let v = @math.Vector4::new(x=1.0, y=2.0, z=3.0, w=4.0)
  let other = @math.Vector4::new(x=5.0, y=6.0, z=7.0, w=8.0)
  ignore(v.add(other))
  assert_eq(v.x, 6.0)
  assert_eq(v.y, 8.0)
  assert_eq(v.z, 10.0)
  assert_eq(v.w, 12.0)
  assert_eq(other.x, 5.0)
  assert_eq(other.y, 6.0)
  assert_eq(other.z, 7.0)
  assert_eq(other.w, 8.0)
}

///|
test "Vector4.addScalar adds one number to every component" {
  let v = @math.Vector4::new(x=1.0, y=2.0, z=3.0, w=4.0)
  ignore(v.add_scalar(4.0))
  assert_eq(v.x, 5.0)
  assert_eq(v.y, 6.0)
  assert_eq(v.z, 7.0)
  assert_eq(v.w, 8.0)
  ignore(v.add_scalar(-1.0))
  assert_eq(v.x, 4.0)
  assert_eq(v.y, 5.0)
  assert_eq(v.z, 6.0)
  assert_eq(v.w, 7.0)
}

///|
test "Vector4.addVectors stores the sum of two vectors" {
  let a = @math.Vector4::new(x=1.0, y=2.0, z=3.0, w=4.0)
  let b = @math.Vector4::new(x=5.0, y=6.0, z=7.0, w=8.0)
  let sum = @math.Vector4::new(x=9.0, y=9.0, z=9.0, w=9.0)
  ignore(sum.add_vectors(a, b))
  assert_eq(sum.x, 6.0)
  assert_eq(sum.y, 8.0)
  assert_eq(sum.z, 10.0)
  assert_eq(sum.w, 12.0)
  assert_eq(a.x, 1.0)
  assert_eq(b.w, 8.0)
  ignore(a.add_vectors(a, b))
  assert_eq(a.x, 6.0)
  assert_eq(a.y, 8.0)
  assert_eq(a.z, 10.0)
  assert_eq(a.w, 12.0)
  assert_eq(b.x, 5.0)
  assert_eq(b.y, 6.0)
  assert_eq(b.z, 7.0)
  assert_eq(b.w, 8.0)
}

///|
test "Vector4.addScaledVector adds a scaled vector" {
  let v = @math.Vector4::new(x=1.0, y=2.0, z=3.0, w=4.0)
  let extra = @math.Vector4::new(x=4.0, y=5.0, z=6.0, w=7.0)
  ignore(v.add_scaled_vector(extra, 2.0))
  assert_eq(v.x, 9.0)
  assert_eq(v.y, 12.0)
  assert_eq(v.z, 15.0)
  assert_eq(v.w, 18.0)
  assert_eq(extra.x, 4.0)
  assert_eq(extra.y, 5.0)
  assert_eq(extra.z, 6.0)
  assert_eq(extra.w, 7.0)
}

///|
test "Vector4.sub subtracts another vector" {
  let v = @math.Vector4::new(x=6.0, y=8.0, z=10.0, w=12.0)
  let other = @math.Vector4::new(x=1.0, y=2.0, z=3.0, w=4.0)
  ignore(v.sub(other))
  assert_eq(v.x, 5.0)
  assert_eq(v.y, 6.0)
  assert_eq(v.z, 7.0)
  assert_eq(v.w, 8.0)
  assert_eq(other.x, 1.0)
  assert_eq(other.y, 2.0)
  assert_eq(other.z, 3.0)
  assert_eq(other.w, 4.0)
}

///|
test "Vector4.subScalar subtracts one number from every component" {
  let v = @math.Vector4::new(x=5.0, y=6.0, z=7.0, w=8.0)
  ignore(v.sub_scalar(4.0))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 2.0)
  assert_eq(v.z, 3.0)
  assert_eq(v.w, 4.0)
  ignore(v.sub_scalar(-1.0))
  assert_eq(v.x, 2.0)
  assert_eq(v.y, 3.0)
  assert_eq(v.z, 4.0)
  assert_eq(v.w, 5.0)
}

///|
test "Vector4.subVectors stores the difference of two vectors" {
  let a = @math.Vector4::new(x=5.0, y=6.0, z=7.0, w=8.0)
  let b = @math.Vector4::new(x=1.0, y=2.0, z=3.0, w=4.0)
  let diff = @math.Vector4::new(x=9.0, y=9.0, z=9.0, w=9.0)
  ignore(diff.sub_vectors(a, b))
  assert_eq(diff.x, 4.0)
  assert_eq(diff.y, 4.0)
  assert_eq(diff.z, 4.0)
  assert_eq(diff.w, 4.0)
  assert_eq(a.x, 5.0)
  assert_eq(b.w, 4.0)
  ignore(a.sub_vectors(a, b))
  assert_eq(a.x, 4.0)
  assert_eq(a.y, 4.0)
  assert_eq(a.z, 4.0)
  assert_eq(a.w, 4.0)
  assert_eq(b.x, 1.0)
  assert_eq(b.y, 2.0)
  assert_eq(b.z, 3.0)
  assert_eq(b.w, 4.0)
}

///|
test "Vector4.multiply multiplies matching components" {
  let v = @math.Vector4::new(x=2.0, y=4.0, z=6.0, w=8.0)
  let factor = @math.Vector4::new(x=5.0, y=6.0, z=7.0, w=8.0)
  ignore(v.multiply(factor))
  assert_eq(v.x, 10.0)
  assert_eq(v.y, 24.0)
  assert_eq(v.z, 42.0)
  assert_eq(v.w, 64.0)
  assert_eq(factor.x, 5.0)
  assert_eq(factor.y, 6.0)
  assert_eq(factor.z, 7.0)
  assert_eq(factor.w, 8.0)
}

///|
test "Vector4.multiplyScalar multiplies every component" {
  let v = @math.Vector4::new(x=2.0, y=4.0, z=6.0, w=8.0)
  ignore(v.multiply_scalar(2.0))
  assert_eq(v.x, 4.0)
  assert_eq(v.y, 8.0)
  assert_eq(v.z, 12.0)
  assert_eq(v.w, 16.0)
  ignore(v.multiply_scalar(-1.0))
  assert_eq(v.x, -4.0)
  assert_eq(v.y, -8.0)
  assert_eq(v.z, -12.0)
  assert_eq(v.w, -16.0)
}

///|
test "Vector4.divide divides matching components" {
  let v = @math.Vector4::new(x=10.0, y=24.0, z=42.0, w=64.0)
  let factor = @math.Vector4::new(x=5.0, y=6.0, z=7.0, w=8.0)
  ignore(v.divide(factor))
  assert_eq(v.x, 2.0)
  assert_eq(v.y, 4.0)
  assert_eq(v.z, 6.0)
  assert_eq(v.w, 8.0)
  assert_eq(factor.x, 5.0)
  assert_eq(factor.y, 6.0)
  assert_eq(factor.z, 7.0)
  assert_eq(factor.w, 8.0)
}

///|
test "Vector4.divideScalar divides every component" {
  let v = @math.Vector4::new(x=2.0, y=4.0, z=6.0, w=8.0)
  ignore(v.divide_scalar(2.0))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 2.0)
  assert_eq(v.z, 3.0)
  assert_eq(v.w, 4.0)
  ignore(v.divide_scalar(-1.0))
  assert_eq(v.x, -1.0)
  assert_eq(v.y, -2.0)
  assert_eq(v.z, -3.0)
  assert_eq(v.w, -4.0)
}

///|
test "Vector4.setAxisAngleFromQuaternion reads axis and angle" {
  let identity = @math.Quaternion::new()
  let still = @math.Vector4::new(x=9.0, y=9.0, z=9.0, w=9.0)
  ignore(still.set_axis_angle_from_quaternion(identity))
  assert_eq(still.x, 1.0)
  assert_eq(still.y, 0.0)
  assert_eq(still.z, 0.0)
  assert_eq(still.w, 0.0)
  assert_eq(identity.x, 0.0)
  assert_eq(identity.w, 1.0)
  let yaw = @math.Quaternion::new().set_from_axis_angle(
    @math.Vector3::new(y=1.0),
    1.5707963267948966,
  )
  let turned = @math.Vector4::new()
  ignore(turned.set_axis_angle_from_quaternion(yaw))
  assert_close(turned.x, 0.0)
  assert_close(turned.y, 1.0)
  assert_close(turned.z, 0.0)
  assert_close(turned.w, 1.5707963267948966)
  assert_close(yaw.y, 0.7071067811865476)
  assert_close(yaw.w, 0.7071067811865476)
}

///|
test "Vector4.setAxisAngleFromRotationMatrix reads axis and angle" {
  let identity = @math.Matrix4::new()
  let still = @math.Vector4::new(x=9.0, y=9.0, z=9.0, w=9.0)
  ignore(still.set_axis_angle_from_rotation_matrix(identity))
  assert_eq(still.x, 1.0)
  assert_eq(still.y, 0.0)
  assert_eq(still.z, 0.0)
  assert_eq(still.w, 0.0)
  assert_eq(identity.elements[0], 1.0)
  assert_eq(identity.elements[5], 1.0)
  let yaw = @math.Quaternion::new().set_from_axis_angle(
    @math.Vector3::new(y=1.0),
    1.5707963267948966,
  )
  let turned = @math.Matrix4::new().make_rotation_from_quaternion(yaw)
  let quarter = @math.Vector4::new()
  ignore(quarter.set_axis_angle_from_rotation_matrix(turned))
  assert_close(quarter.x, 0.0)
  assert_close(quarter.y, 1.0)
  assert_close(quarter.z, 0.0)
  assert_close(quarter.w, 1.5707963267948966)
  let half = @math.Matrix4::new().set(
    1.0, 0.0, 0.0, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 1.0,
  )
  let flip = @math.Vector4::new()
  ignore(flip.set_axis_angle_from_rotation_matrix(half))
  assert_eq(flip.x, 1.0)
  assert_eq(flip.y, 0.0)
  assert_eq(flip.z, 0.0)
  assert_close(flip.w, 3.141592653589793)
  assert_eq(half.elements[5], -1.0)
}

///|
test "Vector4.setFromMatrixPosition copies the last column" {
  let identity = @math.Matrix4::new()
  let origin = @math.Vector4::new(x=9.0, y=9.0, z=9.0, w=9.0)
  ignore(origin.set_from_matrix_position(identity))
  assert_eq(origin.x, 0.0)
  assert_eq(origin.y, 0.0)
  assert_eq(origin.z, 0.0)
  assert_eq(origin.w, 1.0)
  let placed = @math.Matrix4::new().set(
    1.0, 0.0, 0.0, 3.0, 0.0, 1.0, 0.0, 4.0, 0.0, 0.0, 1.0, 5.0, 0.0, 0.0, 0.0, 6.0,
  )
  ignore(origin.set_from_matrix_position(placed))
  assert_eq(origin.x, 3.0)
  assert_eq(origin.y, 4.0)
  assert_eq(origin.z, 5.0)
  assert_eq(origin.w, 6.0)
  assert_eq(placed.elements[12], 3.0)
  assert_eq(placed.elements[15], 6.0)
}

///|
test "Vector4.min keeps the smaller component" {
  let v = @math.Vector4::new(x=0.0, y=5.0, z=2.0, w=8.0)
  let bound = @math.Vector4::new(x=1.0, y=4.0, z=3.0, w=7.0)
  ignore(v.min(bound))
  assert_eq(v.x, 0.0)
  assert_eq(v.y, 4.0)
  assert_eq(v.z, 2.0)
  assert_eq(v.w, 7.0)
  assert_eq(bound.x, 1.0)
  assert_eq(bound.y, 4.0)
  assert_eq(bound.z, 3.0)
  assert_eq(bound.w, 7.0)
}

///|
test "Vector4.max keeps the larger component" {
  let v = @math.Vector4::new(x=0.0, y=5.0, z=2.0, w=8.0)
  let bound = @math.Vector4::new(x=1.0, y=4.0, z=3.0, w=7.0)
  ignore(v.max(bound))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 5.0)
  assert_eq(v.z, 3.0)
  assert_eq(v.w, 8.0)
  assert_eq(bound.x, 1.0)
  assert_eq(bound.y, 4.0)
  assert_eq(bound.z, 3.0)
  assert_eq(bound.w, 7.0)
}

///|
test "Vector4.clamp limits each component" {
  let v = @math.Vector4::new(x=0.0, y=5.0, z=2.0, w=9.0)
  let low = @math.Vector4::new(x=1.0, y=0.0, z=1.0, w=0.0)
  let high = @math.Vector4::new(x=3.0, y=4.0, z=4.0, w=8.0)
  ignore(v.clamp(low, high))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 4.0)
  assert_eq(v.z, 2.0)
  assert_eq(v.w, 8.0)
  assert_eq(low.x, 1.0)
  assert_eq(high.w, 8.0)
  let inside = @math.Vector4::new(x=2.0, y=2.0, z=2.0, w=2.0)
  ignore(
    inside.clamp(
      @math.Vector4::new(w=0.0),
      @math.Vector4::new(x=3.0, y=3.0, z=3.0, w=3.0),
    ),
  )
  assert_eq(inside.x, 2.0)
  assert_eq(inside.y, 2.0)
  assert_eq(inside.z, 2.0)
  assert_eq(inside.w, 2.0)
}

///|
test "Vector4.clampScalar limits every component" {
  let v = @math.Vector4::new(x=0.0, y=5.0, z=2.0, w=9.0)
  ignore(v.clamp_scalar(1.0, 4.0))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 4.0)
  assert_eq(v.z, 2.0)
  assert_eq(v.w, 4.0)
  let inside = @math.Vector4::new(x=2.0, y=3.0, z=1.0, w=4.0)
  ignore(inside.clamp_scalar(0.0, 5.0))
  assert_eq(inside.x, 2.0)
  assert_eq(inside.y, 3.0)
  assert_eq(inside.z, 1.0)
  assert_eq(inside.w, 4.0)
}

///|
test "Vector4.clampLength limits the vector length" {
  let long = @math.Vector4::new(x=0.0, y=0.0, z=0.0, w=4.0)
  ignore(long.clamp_length(1.0, 2.0))
  assert_eq(long.x, 0.0)
  assert_eq(long.y, 0.0)
  assert_eq(long.z, 0.0)
  assert_eq(long.w, 2.0)
  let short = @math.Vector4::new(x=0.0, y=0.0, z=0.0, w=0.5)
  ignore(short.clamp_length(1.0, 2.0))
  assert_eq(short.w, 1.0)
  let kept = @math.Vector4::new(x=0.0, y=0.0, z=0.0, w=4.0)
  ignore(kept.clamp_length(1.0, 8.0))
  assert_eq(kept.w, 4.0)
  let zero = @math.Vector4::new(x=0.0, y=0.0, z=0.0, w=0.0)
  ignore(zero.clamp_length(1.0, 2.0))
  assert_eq(zero.x, 0.0)
  assert_eq(zero.y, 0.0)
  assert_eq(zero.z, 0.0)
  assert_eq(zero.w, 0.0)
}

///|
test "Vector4.floor rounds each component down" {
  let v = @math.Vector4::new(x=1.2, y=-1.2, z=2.8, w=-2.8)
  ignore(v.floor())
  assert_eq(v.x, 1.0)
  assert_eq(v.y, -2.0)
  assert_eq(v.z, 2.0)
  assert_eq(v.w, -3.0)
}

///|
test "Vector4.ceil rounds each component up" {
  let v = @math.Vector4::new(x=1.2, y=-1.2, z=2.8, w=-2.8)
  ignore(v.ceil())
  assert_eq(v.x, 2.0)
  assert_eq(v.y, -1.0)
  assert_eq(v.z, 3.0)
  assert_eq(v.w, -2.0)
}

///|
test "Vector4.round rounds half toward positive infinity" {
  let v = @math.Vector4::new(x=1.5, y=-1.5, z=2.5, w=-2.5)
  ignore(v.round())
  assert_eq(v.x, 2.0)
  assert_eq(v.y, -1.0)
  assert_eq(v.z, 3.0)
  assert_eq(v.w, -2.0)
}

///|
test "Vector4.roundToZero rounds each component toward zero" {
  let v = @math.Vector4::new(x=1.8, y=-1.8, z=2.8, w=-2.8)
  ignore(v.round_to_zero())
  assert_eq(v.x, 1.0)
  assert_eq(v.y, -1.0)
  assert_eq(v.z, 2.0)
  assert_eq(v.w, -2.0)
}

///|
test "Vector4.negate flips the sign of every component" {
  let v = @math.Vector4::new(x=1.0, y=-2.0, z=3.0, w=-4.0)
  ignore(v.negate())
  assert_eq(v.x, -1.0)
  assert_eq(v.y, 2.0)
  assert_eq(v.z, -3.0)
  assert_eq(v.w, 4.0)
}

///|
test "Vector4.manhattanLength sums the absolute components" {
  let v = @math.Vector4::new(x=3.0, y=-4.0, z=5.0, w=-6.0)
  assert_eq(v.manhattan_length(), 18.0)
  assert_eq(v.x, 3.0)
  assert_eq(v.y, -4.0)
  assert_eq(v.z, 5.0)
  assert_eq(v.w, -6.0)
  assert_eq(@math.Vector4::new(w=0.0).manhattan_length(), 0.0)
}

///|
test "Vector4.setLength scales to the requested length" {
  let v = @math.Vector4::new(x=0.0, y=0.0, z=0.0, w=4.0)
  ignore(v.set_length(2.0))
  assert_eq(v.x, 0.0)
  assert_eq(v.y, 0.0)
  assert_eq(v.z, 0.0)
  assert_eq(v.w, 2.0)
  ignore(v.set_length(0.0))
  assert_eq(v.w, 0.0)
  let zero = @math.Vector4::new(x=0.0, y=0.0, z=0.0, w=0.0)
  ignore(zero.set_length(5.0))
  assert_eq(zero.x, 0.0)
  assert_eq(zero.y, 0.0)
  assert_eq(zero.z, 0.0)
  assert_eq(zero.w, 0.0)
}

///|
test "Vector4.lerp moves toward another vector" {
  let v = @math.Vector4::new(x=1.0, y=2.0, z=3.0, w=4.0)
  let other = @math.Vector4::new(x=5.0, y=6.0, z=7.0, w=8.0)
  ignore(v.lerp(other, 0.0))
  assert_eq(v.x, 1.0)
  assert_eq(v.w, 4.0)
  ignore(v.lerp(other, 0.25))
  assert_eq(v.x, 2.0)
  assert_eq(v.y, 3.0)
  assert_eq(v.z, 4.0)
  assert_eq(v.w, 5.0)
  assert_eq(other.x, 5.0)
  assert_eq(other.w, 8.0)
  ignore(v.lerp(other, 1.0))
  assert_eq(v.x, 5.0)
  assert_eq(v.y, 6.0)
  assert_eq(v.z, 7.0)
  assert_eq(v.w, 8.0)
}

///|
test "Vector4.lerpVectors stores the interpolation of two vectors" {
  let a = @math.Vector4::new(x=1.0, y=2.0, z=3.0, w=4.0)
  let b = @math.Vector4::new(x=5.0, y=6.0, z=7.0, w=8.0)
  let v = @math.Vector4::new(x=9.0, y=9.0, z=9.0, w=9.0)
  ignore(v.lerp_vectors(a, b, 0.25))
  assert_eq(v.x, 2.0)
  assert_eq(v.y, 3.0)
  assert_eq(v.z, 4.0)
  assert_eq(v.w, 5.0)
  ignore(v.lerp_vectors(a, b, 0.0))
  assert_eq(v.x, 1.0)
  assert_eq(v.w, 4.0)
  ignore(v.lerp_vectors(a, b, 1.0))
  assert_eq(v.x, 5.0)
  assert_eq(v.w, 8.0)
  assert_eq(a.x, 1.0)
  assert_eq(a.w, 4.0)
  assert_eq(b.x, 5.0)
  assert_eq(b.w, 8.0)
}

///|
test "Vector4.equals compares every component" {
  let v = @math.Vector4::new(x=1.0, y=2.0, z=3.0, w=4.0)
  let same = @math.Vector4::new(x=1.0, y=2.0, z=3.0, w=4.0)
  assert_eq(v.equals(same), true)
  assert_eq(v.equals(v), true)
  assert_eq(v.equals(@math.Vector4::new(x=9.0, y=2.0, z=3.0, w=4.0)), false)
  assert_eq(v.equals(@math.Vector4::new(x=1.0, y=9.0, z=3.0, w=4.0)), false)
  assert_eq(v.equals(@math.Vector4::new(x=1.0, y=2.0, z=9.0, w=4.0)), false)
  assert_eq(v.equals(@math.Vector4::new(x=1.0, y=2.0, z=3.0, w=9.0)), false)
  assert_eq(v.x, 1.0)
  assert_eq(v.w, 4.0)
  assert_eq(same.y, 2.0)
}

///|
test "Vector4.fromArray reads four components at an offset" {
  let array = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0]
  let v = @math.Vector4::new(x=9.0, y=9.0, z=9.0, w=9.0)
  ignore(v.from_array(array))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 2.0)
  assert_eq(v.z, 3.0)
  assert_eq(v.w, 4.0)
  ignore(v.from_array(array, offset=2))
  assert_eq(v.x, 3.0)
  assert_eq(v.y, 4.0)
  assert_eq(v.z, 5.0)
  assert_eq(v.w, 6.0)
  assert_eq(array[0], 1.0)
  assert_eq(array[6], 7.0)
}

///|
test "Box2 starts empty and copies its corners" {
  let empty = @math.Box2::new()
  assert_eq(empty.min.x > 1.0e308, true)
  assert_eq(empty.min.y > 1.0e308, true)
  assert_eq(empty.max.x < -1.0e308, true)
  assert_eq(empty.max.y < -1.0e308, true)
  let low = @math.Vector2::new(x=1.0, y=2.0)
  let high = @math.Vector2::new(x=3.0, y=4.0)
  let box = @math.Box2::new(min=low, max=high)
  assert_eq(box.min.x, 1.0)
  assert_eq(box.min.y, 2.0)
  assert_eq(box.max.x, 3.0)
  assert_eq(box.max.y, 4.0)
  low.x = 9.0
  high.y = 8.0
  assert_eq(box.min.x, 1.0)
  assert_eq(box.max.y, 4.0)
}

///|
test "Box2.set copies both corners" {
  let box = @math.Box2::new()
  let low = @math.Vector2::new(x=1.0, y=2.0)
  let high = @math.Vector2::new(x=3.0, y=4.0)
  ignore(box.set(low, high))
  assert_eq(box.min.x, 1.0)
  assert_eq(box.min.y, 2.0)
  assert_eq(box.max.x, 3.0)
  assert_eq(box.max.y, 4.0)
  low.x = 9.0
  high.y = 8.0
  assert_eq(box.min.x, 1.0)
  assert_eq(box.max.y, 4.0)
  assert_eq(low.x, 9.0)
  assert_eq(high.y, 8.0)
}

///|
test "Box2.makeEmpty clears both corners" {
  let box = @math.Box2::new(
    min=@math.Vector2::new(x=1.0, y=2.0),
    max=@math.Vector2::new(x=3.0, y=4.0),
  )
  ignore(box.make_empty())
  assert_eq(box.min.x > 1.0e308, true)
  assert_eq(box.min.y > 1.0e308, true)
  assert_eq(box.max.x < -1.0e308, true)
  assert_eq(box.max.y < -1.0e308, true)
}

///|
test "Box2.expandByPoint includes a point" {
  let box = @math.Box2::new()
  let point = @math.Vector2::new(x=1.0, y=2.0)
  ignore(box.expand_by_point(point))
  assert_eq(box.min.x, 1.0)
  assert_eq(box.min.y, 2.0)
  assert_eq(box.max.x, 1.0)
  assert_eq(box.max.y, 2.0)
  assert_eq(point.x, 1.0)
  assert_eq(point.y, 2.0)
  ignore(box.expand_by_point(@math.Vector2::new(x=0.0, y=5.0)))
  assert_eq(box.min.x, 0.0)
  assert_eq(box.min.y, 2.0)
  assert_eq(box.max.x, 1.0)
  assert_eq(box.max.y, 5.0)
}

///|
test "Box2.setFromPoints fits the given points" {
  let box = @math.Box2::new(
    min=@math.Vector2::new(x=9.0, y=9.0),
    max=@math.Vector2::new(x=8.0, y=8.0),
  )
  let a = @math.Vector2::new(x=1.0, y=2.0)
  let b = @math.Vector2::new(x=0.0, y=5.0)
  ignore(box.set_from_points([a, b]))
  assert_eq(box.min.x, 0.0)
  assert_eq(box.min.y, 2.0)
  assert_eq(box.max.x, 1.0)
  assert_eq(box.max.y, 5.0)
  assert_eq(a.x, 1.0)
  assert_eq(b.y, 5.0)
  ignore(box.set_from_points([]))
  assert_eq(box.min.x > 1.0e308, true)
  assert_eq(box.max.x < -1.0e308, true)
}

///|
test "Box2.setFromCenterAndSize uses center and size" {
  let box = @math.Box2::new()
  let center = @math.Vector2::new(x=5.0, y=6.0)
  let size = @math.Vector2::new(x=2.0, y=4.0)
  ignore(box.set_from_center_and_size(center, size))
  assert_eq(box.min.x, 4.0)
  assert_eq(box.min.y, 4.0)
  assert_eq(box.max.x, 6.0)
  assert_eq(box.max.y, 8.0)
  assert_eq(center.x, 5.0)
  assert_eq(center.y, 6.0)
  assert_eq(size.x, 2.0)
  assert_eq(size.y, 4.0)
}

///|
test "Box2.copy copies both corners" {
  let source = @math.Box2::new(
    min=@math.Vector2::new(x=1.0, y=2.0),
    max=@math.Vector2::new(x=3.0, y=4.0),
  )
  let box = @math.Box2::new()
  ignore(box.copy(source))
  assert_eq(box.min.x, 1.0)
  assert_eq(box.min.y, 2.0)
  assert_eq(box.max.x, 3.0)
  assert_eq(box.max.y, 4.0)
  source.min.x = 9.0
  source.max.y = 8.0
  assert_eq(box.min.x, 1.0)
  assert_eq(box.max.y, 4.0)
  assert_eq(source.min.x, 9.0)
  assert_eq(source.max.y, 8.0)
}

///|
test "Box2.clone copies both corners into a new box" {
  let source = @math.Box2::new(
    min=@math.Vector2::new(x=1.0, y=2.0),
    max=@math.Vector2::new(x=3.0, y=4.0),
  )
  let box = source.clone()
  assert_eq(box.min.x, 1.0)
  assert_eq(box.min.y, 2.0)
  assert_eq(box.max.x, 3.0)
  assert_eq(box.max.y, 4.0)
  source.min.x = 9.0
  source.max.y = 8.0
  assert_eq(box.min.x, 1.0)
  assert_eq(box.max.y, 4.0)
  assert_eq(source.min.x, 9.0)
  assert_eq(source.max.y, 8.0)
}

///|
test "Box2.isEmpty treats equal bounds as a point" {
  let empty = @math.Box2::new()
  assert_eq(empty.is_empty(), true)
  let box = @math.Box2::new(
    min=@math.Vector2::new(x=1.0, y=2.0),
    max=@math.Vector2::new(x=3.0, y=4.0),
  )
  assert_eq(box.is_empty(), false)
  let point = @math.Box2::new(
    min=@math.Vector2::new(x=1.0, y=2.0),
    max=@math.Vector2::new(x=1.0, y=2.0),
  )
  assert_eq(point.is_empty(), false)
  let inverted = @math.Box2::new(
    min=@math.Vector2::new(x=3.0, y=2.0),
    max=@math.Vector2::new(x=1.0, y=4.0),
  )
  assert_eq(inverted.is_empty(), true)
  assert_eq(box.min.x, 1.0)
  assert_eq(box.max.y, 4.0)
}

///|
test "Box2.getCenter writes the midpoint" {
  let box = @math.Box2::new(
    min=@math.Vector2::new(x=1.0, y=2.0),
    max=@math.Vector2::new(x=3.0, y=4.0),
  )
  let target = @math.Vector2::new(x=9.0, y=9.0)
  let center = box.get_center(target)
  assert_eq(physical_equal(center, target), true)
  assert_eq(center.x, 2.0)
  assert_eq(center.y, 3.0)
  assert_eq(box.min.x, 1.0)
  assert_eq(box.max.y, 4.0)
  let empty = @math.Box2::new()
  ignore(empty.get_center(target))
  assert_eq(target.x, 0.0)
  assert_eq(target.y, 0.0)
}

///|
test "Box2.getSize writes the width and height" {
  let box = @math.Box2::new(
    min=@math.Vector2::new(x=1.0, y=2.0),
    max=@math.Vector2::new(x=3.0, y=4.0),
  )
  let target = @math.Vector2::new(x=9.0, y=9.0)
  let size = box.get_size(target)
  assert_eq(physical_equal(size, target), true)
  assert_eq(size.x, 2.0)
  assert_eq(size.y, 2.0)
  assert_eq(box.min.x, 1.0)
  assert_eq(box.max.y, 4.0)
  let empty = @math.Box2::new()
  ignore(empty.get_size(target))
  assert_eq(target.x, 0.0)
  assert_eq(target.y, 0.0)
}

///|
test "Box2.expandByVector grows both sides" {
  let box = @math.Box2::new(
    min=@math.Vector2::new(x=1.0, y=2.0),
    max=@math.Vector2::new(x=3.0, y=4.0),
  )
  let vector = @math.Vector2::new(x=1.0, y=2.0)
  ignore(box.expand_by_vector(vector))
  assert_eq(box.min.x, 0.0)
  assert_eq(box.min.y, 0.0)
  assert_eq(box.max.x, 4.0)
  assert_eq(box.max.y, 6.0)
  assert_eq(vector.x, 1.0)
  assert_eq(vector.y, 2.0)
}

///|
test "Box2.expandByScalar grows or shrinks each side" {
  let box = @math.Box2::new(
    min=@math.Vector2::new(x=1.0, y=2.0),
    max=@math.Vector2::new(x=3.0, y=4.0),
  )
  ignore(box.expand_by_scalar(1.0))
  assert_eq(box.min.x, 0.0)
  assert_eq(box.min.y, 1.0)
  assert_eq(box.max.x, 4.0)
  assert_eq(box.max.y, 5.0)
  ignore(box.expand_by_scalar(-1.0))
  assert_eq(box.min.x, 1.0)
  assert_eq(box.min.y, 2.0)
  assert_eq(box.max.x, 3.0)
  assert_eq(box.max.y, 4.0)
}

///|
test "Box2.containsPoint includes the boundary" {
  let box = @math.Box2::new(
    min=@math.Vector2::new(x=1.0, y=2.0),
    max=@math.Vector2::new(x=3.0, y=4.0),
  )
  let inside = @math.Vector2::new(x=2.0, y=3.0)
  let corner = @math.Vector2::new(x=1.0, y=2.0)
  let outside = @math.Vector2::new(x=0.0, y=3.0)
  assert_eq(box.contains_point(inside), true)
  assert_eq(box.contains_point(corner), true)
  assert_eq(box.contains_point(outside), false)
  assert_eq(inside.x, 2.0)
  assert_eq(box.min.x, 1.0)
  assert_eq(box.max.y, 4.0)
}

///|
test "Box2.containsBox includes an identical box" {
  let box = @math.Box2::new(
    min=@math.Vector2::new(x=1.0, y=2.0),
    max=@math.Vector2::new(x=5.0, y=6.0),
  )
  let inner = @math.Box2::new(
    min=@math.Vector2::new(x=2.0, y=3.0),
    max=@math.Vector2::new(x=4.0, y=5.0),
  )
  let same = @math.Box2::new(
    min=@math.Vector2::new(x=1.0, y=2.0),
    max=@math.Vector2::new(x=5.0, y=6.0),
  )
  let overflow = @math.Box2::new(
    min=@math.Vector2::new(x=0.0, y=3.0),
    max=@math.Vector2::new(x=4.0, y=5.0),
  )
  assert_eq(box.contains_box(inner), true)
  assert_eq(box.contains_box(same), true)
  assert_eq(box.contains_box(overflow), false)
  assert_eq(inner.min.x, 2.0)
  assert_eq(box.max.y, 6.0)
}

///|
test "Box2.getParameter writes the point as a proportion" {
  let box = @math.Box2::new(
    min=@math.Vector2::new(x=1.0, y=2.0),
    max=@math.Vector2::new(x=3.0, y=6.0),
  )
  let point = @math.Vector2::new(x=2.0, y=4.0)
  let target = @math.Vector2::new(x=9.0, y=9.0)
  let parameter = box.get_parameter(point, target)
  assert_eq(physical_equal(parameter, target), true)
  assert_eq(parameter.x, 0.5)
  assert_eq(parameter.y, 0.5)
  ignore(box.get_parameter(@math.Vector2::new(x=1.0, y=2.0), target))
  assert_eq(target.x, 0.0)
  assert_eq(target.y, 0.0)
  assert_eq(point.x, 2.0)
  assert_eq(box.min.x, 1.0)
  assert_eq(box.max.y, 6.0)
}

///|
test "Box2.intersectsBox counts a shared edge" {
  let box = @math.Box2::new(
    min=@math.Vector2::new(x=1.0, y=2.0),
    max=@math.Vector2::new(x=3.0, y=4.0),
  )
  let overlap = @math.Box2::new(
    min=@math.Vector2::new(x=2.0, y=3.0),
    max=@math.Vector2::new(x=4.0, y=5.0),
  )
  let touch = @math.Box2::new(
    min=@math.Vector2::new(x=3.0, y=2.0),
    max=@math.Vector2::new(x=5.0, y=4.0),
  )
  let apart = @math.Box2::new(
    min=@math.Vector2::new(x=4.0, y=2.0),
    max=@math.Vector2::new(x=5.0, y=4.0),
  )
  assert_eq(box.intersects_box(overlap), true)
  assert_eq(box.intersects_box(touch), true)
  assert_eq(box.intersects_box(apart), false)
  assert_eq(overlap.min.x, 2.0)
  assert_eq(box.max.x, 3.0)
}

///|
test "Box2.clampPoint keeps the point inside the box" {
  let box = @math.Box2::new(
    min=@math.Vector2::new(x=1.0, y=2.0),
    max=@math.Vector2::new(x=3.0, y=4.0),
  )
  let outside = @math.Vector2::new(x=0.0, y=5.0)
  let target = @math.Vector2::new(x=9.0, y=9.0)
  let clamped = box.clamp_point(outside, target)
  assert_eq(physical_equal(clamped, target), true)
  assert_eq(clamped.x, 1.0)
  assert_eq(clamped.y, 4.0)
  let inside = @math.Vector2::new(x=2.0, y=3.0)
  ignore(box.clamp_point(inside, target))
  assert_eq(target.x, 2.0)
  assert_eq(target.y, 3.0)
  assert_eq(outside.x, 0.0)
  assert_eq(outside.y, 5.0)
  assert_eq(box.min.x, 1.0)
  assert_eq(box.max.y, 4.0)
}

///|
test "Box2.distanceToPoint is zero inside the box" {
  let box = @math.Box2::new(
    min=@math.Vector2::new(x=1.0, y=2.0),
    max=@math.Vector2::new(x=3.0, y=4.0),
  )
  let outside = @math.Vector2::new(x=0.0, y=3.0)
  let inside = @math.Vector2::new(x=2.0, y=3.0)
  assert_eq(box.distance_to_point(outside), 1.0)
  assert_eq(box.distance_to_point(inside), 0.0)
  assert_eq(outside.x, 0.0)
  assert_eq(inside.y, 3.0)
  assert_eq(box.min.x, 1.0)
  assert_eq(box.max.y, 4.0)
}

///|
test "Box2.intersect keeps the overlap" {
  let box = @math.Box2::new(
    min=@math.Vector2::new(x=1.0, y=2.0),
    max=@math.Vector2::new(x=5.0, y=6.0),
  )
  let other = @math.Box2::new(
    min=@math.Vector2::new(x=3.0, y=0.0),
    max=@math.Vector2::new(x=4.0, y=4.0),
  )
  ignore(box.intersect(other))
  assert_eq(box.min.x, 3.0)
  assert_eq(box.min.y, 2.0)
  assert_eq(box.max.x, 4.0)
  assert_eq(box.max.y, 4.0)
  assert_eq(other.min.x, 3.0)
  assert_eq(other.max.y, 4.0)
  let apart = @math.Box2::new(
    min=@math.Vector2::new(x=1.0, y=2.0),
    max=@math.Vector2::new(x=3.0, y=4.0),
  )
  ignore(
    apart.intersect(
      @math.Box2::new(
        min=@math.Vector2::new(x=5.0, y=6.0),
        max=@math.Vector2::new(x=7.0, y=8.0),
      ),
    ),
  )
  assert_eq(apart.min.x > 1.0e308, true)
  assert_eq(apart.max.x < -1.0e308, true)
}

///|
test "Box2.union covers both boxes" {
  let box = @math.Box2::new(
    min=@math.Vector2::new(x=1.0, y=2.0),
    max=@math.Vector2::new(x=3.0, y=4.0),
  )
  let other = @math.Box2::new(
    min=@math.Vector2::new(x=0.0, y=5.0),
    max=@math.Vector2::new(x=2.0, y=6.0),
  )
  ignore(box.union(other))
  assert_eq(box.min.x, 0.0)
  assert_eq(box.min.y, 2.0)
  assert_eq(box.max.x, 3.0)
  assert_eq(box.max.y, 6.0)
  assert_eq(other.min.x, 0.0)
  assert_eq(other.max.y, 6.0)
  let empty = @math.Box2::new()
  ignore(empty.union(other))
  assert_eq(empty.min.x, 0.0)
  assert_eq(empty.min.y, 5.0)
  assert_eq(empty.max.x, 2.0)
  assert_eq(empty.max.y, 6.0)
}

///|
test "Box2.translate moves both corners" {
  let box = @math.Box2::new(
    min=@math.Vector2::new(x=1.0, y=2.0),
    max=@math.Vector2::new(x=3.0, y=4.0),
  )
  let offset = @math.Vector2::new(x=1.0, y=-2.0)
  ignore(box.translate(offset))
  assert_eq(box.min.x, 2.0)
  assert_eq(box.min.y, 0.0)
  assert_eq(box.max.x, 4.0)
  assert_eq(box.max.y, 2.0)
  assert_eq(offset.x, 1.0)
  assert_eq(offset.y, -2.0)
}

///|
test "Box2.equals compares both corners" {
  let box = @math.Box2::new(
    min=@math.Vector2::new(x=1.0, y=2.0),
    max=@math.Vector2::new(x=3.0, y=4.0),
  )
  let same = box.clone()
  let other = @math.Box2::new(
    min=@math.Vector2::new(x=1.0, y=2.0),
    max=@math.Vector2::new(x=3.0, y=5.0),
  )
  assert_eq(box.equals(same), true)
  assert_eq(box.equals(box), true)
  assert_eq(box.equals(other), false)
  same.max.y = 5.0
  assert_eq(box.equals(same), false)
  assert_eq(box.max.y, 4.0)
  assert_eq(other.max.y, 5.0)
}

///|
test "Box3.setFromArray fits each triple" {
  let box = @math.Box3::new(
    @math.Vector3::new(x=9.0, y=9.0, z=9.0),
    @math.Vector3::new(x=8.0, y=8.0, z=8.0),
  )
  let array = [1.0, 2.0, 3.0, 0.0, 5.0, 4.0]
  ignore(box.set_from_array(array))
  assert_eq(box.min.x, 0.0)
  assert_eq(box.min.y, 2.0)
  assert_eq(box.min.z, 3.0)
  assert_eq(box.max.x, 1.0)
  assert_eq(box.max.y, 5.0)
  assert_eq(box.max.z, 4.0)
  assert_eq(array[0], 1.0)
  assert_eq(array[5], 4.0)
  ignore(box.set_from_array([]))
  assert_eq(box.min.x > 1.0e308, true)
  assert_eq(box.max.x < -1.0e308, true)
}

///|
test "Box3.setFromCenterAndSize uses center and size" {
  let box = @math.Box3::empty()
  let center = @math.Vector3::new(x=5.0, y=6.0, z=7.0)
  let size = @math.Vector3::new(x=2.0, y=4.0, z=6.0)
  ignore(box.set_from_center_and_size(center, size))
  assert_eq(box.min.x, 4.0)
  assert_eq(box.min.y, 4.0)
  assert_eq(box.min.z, 4.0)
  assert_eq(box.max.x, 6.0)
  assert_eq(box.max.y, 8.0)
  assert_eq(box.max.z, 10.0)
  assert_eq(center.x, 5.0)
  assert_eq(center.z, 7.0)
  assert_eq(size.y, 4.0)
  assert_eq(size.z, 6.0)
}

///|
test "Box3.copy copies both corners" {
  let source = @math.Box3::new(
    @math.Vector3::new(x=1.0, y=2.0, z=3.0),
    @math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  let box = @math.Box3::empty()
  ignore(box.copy(source))
  assert_eq(box.min.x, 1.0)
  assert_eq(box.min.y, 2.0)
  assert_eq(box.min.z, 3.0)
  assert_eq(box.max.x, 4.0)
  assert_eq(box.max.y, 5.0)
  assert_eq(box.max.z, 6.0)
  source.min.x = 9.0
  source.max.z = 8.0
  assert_eq(box.min.x, 1.0)
  assert_eq(box.max.z, 6.0)
  assert_eq(source.min.x, 9.0)
  assert_eq(source.max.z, 8.0)
}

///|
test "Box3.clone copies both corners into a new box" {
  let source = @math.Box3::new(
    @math.Vector3::new(x=1.0, y=2.0, z=3.0),
    @math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  let box = source.clone()
  assert_eq(box.min.x, 1.0)
  assert_eq(box.min.y, 2.0)
  assert_eq(box.min.z, 3.0)
  assert_eq(box.max.x, 4.0)
  assert_eq(box.max.y, 5.0)
  assert_eq(box.max.z, 6.0)
  source.min.x = 9.0
  source.max.z = 8.0
  assert_eq(box.min.x, 1.0)
  assert_eq(box.max.z, 6.0)
  assert_eq(source.min.x, 9.0)
  assert_eq(source.max.z, 8.0)
}

///|
test "Box3.expandByVector grows both sides" {
  let box = @math.Box3::new(
    @math.Vector3::new(x=1.0, y=2.0, z=3.0),
    @math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  let vector = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  ignore(box.expand_by_vector(vector))
  assert_eq(box.min.x, 0.0)
  assert_eq(box.min.y, 0.0)
  assert_eq(box.min.z, 0.0)
  assert_eq(box.max.x, 5.0)
  assert_eq(box.max.y, 7.0)
  assert_eq(box.max.z, 9.0)
  assert_eq(vector.x, 1.0)
  assert_eq(vector.z, 3.0)
}

///|
test "Box3.expandByScalar grows or shrinks each side" {
  let box = @math.Box3::new(
    @math.Vector3::new(x=1.0, y=2.0, z=3.0),
    @math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  ignore(box.expand_by_scalar(1.0))
  assert_eq(box.min.x, 0.0)
  assert_eq(box.min.y, 1.0)
  assert_eq(box.min.z, 2.0)
  assert_eq(box.max.x, 5.0)
  assert_eq(box.max.y, 6.0)
  assert_eq(box.max.z, 7.0)
  ignore(box.expand_by_scalar(-1.0))
  assert_eq(box.min.x, 1.0)
  assert_eq(box.min.y, 2.0)
  assert_eq(box.min.z, 3.0)
  assert_eq(box.max.x, 4.0)
  assert_eq(box.max.y, 5.0)
  assert_eq(box.max.z, 6.0)
}

///|
test "Box3.containsPoint includes the boundary" {
  let box = @math.Box3::new(
    @math.Vector3::new(x=1.0, y=2.0, z=3.0),
    @math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  let inside = @math.Vector3::new(x=2.0, y=3.0, z=4.0)
  let corner = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  let outside = @math.Vector3::new(x=0.0, y=3.0, z=4.0)
  assert_eq(box.contains_point(inside), true)
  assert_eq(box.contains_point(corner), true)
  assert_eq(box.contains_point(outside), false)
  assert_eq(inside.x, 2.0)
  assert_eq(box.min.x, 1.0)
  assert_eq(box.max.z, 6.0)
}

///|
test "Box3.containsBox includes an identical box" {
  let box = @math.Box3::new(
    @math.Vector3::new(x=1.0, y=2.0, z=3.0),
    @math.Vector3::new(x=7.0, y=8.0, z=9.0),
  )
  let inner = @math.Box3::new(
    @math.Vector3::new(x=2.0, y=3.0, z=4.0),
    @math.Vector3::new(x=6.0, y=7.0, z=8.0),
  )
  let same = @math.Box3::new(
    @math.Vector3::new(x=1.0, y=2.0, z=3.0),
    @math.Vector3::new(x=7.0, y=8.0, z=9.0),
  )
  let overflow = @math.Box3::new(
    @math.Vector3::new(x=0.0, y=3.0, z=4.0),
    @math.Vector3::new(x=6.0, y=7.0, z=8.0),
  )
  assert_eq(box.contains_box(inner), true)
  assert_eq(box.contains_box(same), true)
  assert_eq(box.contains_box(overflow), false)
  assert_eq(inner.min.x, 2.0)
  assert_eq(box.max.z, 9.0)
}

///|
test "Box3.getParameter writes the point as a proportion" {
  let box = @math.Box3::new(
    @math.Vector3::new(x=1.0, y=2.0, z=3.0),
    @math.Vector3::new(x=3.0, y=6.0, z=5.0),
  )
  let point = @math.Vector3::new(x=2.0, y=4.0, z=4.0)
  let target = @math.Vector3::new(x=9.0, y=9.0, z=9.0)
  let parameter = box.get_parameter(point, target)
  assert_eq(physical_equal(parameter, target), true)
  assert_eq(parameter.x, 0.5)
  assert_eq(parameter.y, 0.5)
  assert_eq(parameter.z, 0.5)
  ignore(box.get_parameter(@math.Vector3::new(x=1.0, y=2.0, z=3.0), target))
  assert_eq(target.x, 0.0)
  assert_eq(target.y, 0.0)
  assert_eq(target.z, 0.0)
  assert_eq(point.x, 2.0)
  assert_eq(box.min.z, 3.0)
  assert_eq(box.max.y, 6.0)
}

///|
test "Box3.intersectsBox counts a shared face" {
  let box = @math.Box3::new(
    @math.Vector3::new(x=1.0, y=2.0, z=3.0),
    @math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  let overlap = @math.Box3::new(
    @math.Vector3::new(x=3.0, y=4.0, z=5.0),
    @math.Vector3::new(x=6.0, y=7.0, z=8.0),
  )
  let touch = @math.Box3::new(
    @math.Vector3::new(x=4.0, y=2.0, z=3.0),
    @math.Vector3::new(x=6.0, y=5.0, z=6.0),
  )
  let apart = @math.Box3::new(
    @math.Vector3::new(x=5.0, y=2.0, z=3.0),
    @math.Vector3::new(x=6.0, y=5.0, z=6.0),
  )
  assert_eq(box.intersects_box(overlap), true)
  assert_eq(box.intersects_box(touch), true)
  assert_eq(box.intersects_box(apart), false)
  assert_eq(overlap.min.x, 3.0)
  assert_eq(box.max.x, 4.0)
}

///|
test "Box3.clampPoint keeps the point inside the box" {
  let box = @math.Box3::new(
    @math.Vector3::new(x=1.0, y=2.0, z=3.0),
    @math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  let outside = @math.Vector3::new(x=0.0, y=7.0, z=3.0)
  let target = @math.Vector3::new(x=9.0, y=9.0, z=9.0)
  let clamped = box.clamp_point(outside, target)
  assert_eq(physical_equal(clamped, target), true)
  assert_eq(clamped.x, 1.0)
  assert_eq(clamped.y, 5.0)
  assert_eq(clamped.z, 3.0)
  let inside = @math.Vector3::new(x=2.0, y=3.0, z=4.0)
  ignore(box.clamp_point(inside, target))
  assert_eq(target.x, 2.0)
  assert_eq(target.y, 3.0)
  assert_eq(target.z, 4.0)
  assert_eq(outside.x, 0.0)
  assert_eq(outside.y, 7.0)
  assert_eq(box.min.x, 1.0)
  assert_eq(box.max.z, 6.0)
}

///|
test "Box3.intersectsSphere counts a tangent sphere" {
  let box = @math.Box3::new(
    @math.Vector3::new(x=1.0, y=2.0, z=3.0),
    @math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  let touch = @math.Sphere::new(
    center=@math.Vector3::new(x=0.0, y=3.0, z=4.0),
    radius=1.0,
  )
  let apart = @math.Sphere::new(
    center=@math.Vector3::new(x=0.0, y=3.0, z=4.0),
    radius=0.5,
  )
  let inside = @math.Sphere::new(
    center=@math.Vector3::new(x=2.0, y=3.0, z=4.0),
    radius=0.0,
  )
  assert_eq(box.intersects_sphere(touch), true)
  assert_eq(box.intersects_sphere(apart), false)
  assert_eq(box.intersects_sphere(inside), true)
  assert_eq(touch.center.x, 0.0)
  assert_eq(touch.radius, 1.0)
  assert_eq(box.min.x, 1.0)
  assert_eq(box.max.z, 6.0)
}

///|
test "Box3.intersectsPlane counts a plane through the box" {
  let box = @math.Box3::new(
    @math.Vector3::new(x=1.0, y=2.0, z=3.0),
    @math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  let through = @math.Plane::new(
    normal=@math.Vector3::new(x=1.0, y=0.0, z=0.0),
    constant=-2.0,
  )
  let before = @math.Plane::new(
    normal=@math.Vector3::new(x=1.0, y=0.0, z=0.0),
    constant=0.0,
  )
  let behind = @math.Plane::new(
    normal=@math.Vector3::new(x=0.0, y=-1.0, z=0.0),
    constant=0.0,
  )
  assert_eq(box.intersects_plane(through), true)
  assert_eq(box.intersects_plane(before), false)
  assert_eq(box.intersects_plane(behind), false)
  assert_eq(through.constant, -2.0)
  assert_eq(through.normal.x, 1.0)
  assert_eq(box.min.x, 1.0)
  assert_eq(box.max.y, 5.0)
}

///|
test "Box3.distanceToPoint is zero inside the box" {
  let box = @math.Box3::new(
    @math.Vector3::new(x=1.0, y=2.0, z=3.0),
    @math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  let outside = @math.Vector3::new(x=0.0, y=3.0, z=4.0)
  let inside = @math.Vector3::new(x=2.0, y=3.0, z=4.0)
  assert_eq(box.distance_to_point(outside), 1.0)
  assert_eq(box.distance_to_point(inside), 0.0)
  assert_eq(outside.x, 0.0)
  assert_eq(inside.y, 3.0)
  assert_eq(box.min.x, 1.0)
  assert_eq(box.max.z, 6.0)
}

///|
test "Box3.getBoundingSphere uses the center and half diagonal" {
  let box = @math.Box3::new(
    @math.Vector3::new(x=0.0, y=0.0, z=0.0),
    @math.Vector3::new(x=2.0, y=0.0, z=0.0),
  )
  let sphere = @math.Sphere::new(
    center=@math.Vector3::new(x=9.0, y=9.0, z=9.0),
    radius=4.0,
  )
  let written = box.get_bounding_sphere(sphere)
  assert_eq(physical_equal(written, sphere), true)
  assert_eq(sphere.center.x, 1.0)
  assert_eq(sphere.center.y, 0.0)
  assert_eq(sphere.center.z, 0.0)
  assert_eq(sphere.radius, 1.0)
  assert_eq(box.min.x, 0.0)
  assert_eq(box.max.x, 2.0)
  ignore(@math.Box3::empty().get_bounding_sphere(sphere))
  assert_eq(sphere.center.x, 0.0)
  assert_eq(sphere.center.y, 0.0)
  assert_eq(sphere.center.z, 0.0)
  assert_eq(sphere.radius, -1.0)
}

///|
test "Box3.intersect keeps the overlap" {
  let box = @math.Box3::new(
    @math.Vector3::new(x=1.0, y=2.0, z=3.0),
    @math.Vector3::new(x=5.0, y=6.0, z=7.0),
  )
  let other = @math.Box3::new(
    @math.Vector3::new(x=3.0, y=0.0, z=4.0),
    @math.Vector3::new(x=4.0, y=4.0, z=8.0),
  )
  ignore(box.intersect(other))
  assert_eq(box.min.x, 3.0)
  assert_eq(box.min.y, 2.0)
  assert_eq(box.min.z, 4.0)
  assert_eq(box.max.x, 4.0)
  assert_eq(box.max.y, 4.0)
  assert_eq(box.max.z, 7.0)
  assert_eq(other.min.x, 3.0)
  assert_eq(other.max.z, 8.0)
  let apart = @math.Box3::new(
    @math.Vector3::new(x=1.0, y=2.0, z=3.0),
    @math.Vector3::new(x=3.0, y=4.0, z=5.0),
  )
  ignore(
    apart.intersect(
      @math.Box3::new(
        @math.Vector3::new(x=5.0, y=6.0, z=7.0),
        @math.Vector3::new(x=7.0, y=8.0, z=9.0),
      ),
    ),
  )
  assert_eq(apart.min.x > 1.0e308, true)
  assert_eq(apart.max.x < -1.0e308, true)
}

///|
test "Box3.translate moves both corners" {
  let box = @math.Box3::new(
    @math.Vector3::new(x=1.0, y=2.0, z=3.0),
    @math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  let offset = @math.Vector3::new(x=1.0, y=-2.0, z=3.0)
  ignore(box.translate(offset))
  assert_eq(box.min.x, 2.0)
  assert_eq(box.min.y, 0.0)
  assert_eq(box.min.z, 6.0)
  assert_eq(box.max.x, 5.0)
  assert_eq(box.max.y, 3.0)
  assert_eq(box.max.z, 9.0)
  assert_eq(offset.x, 1.0)
  assert_eq(offset.z, 3.0)
}

///|
test "Box3.equals compares both corners" {
  let box = @math.Box3::new(
    @math.Vector3::new(x=1.0, y=2.0, z=3.0),
    @math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  let same = box.clone()
  let other = @math.Box3::new(
    @math.Vector3::new(x=1.0, y=2.0, z=3.0),
    @math.Vector3::new(x=4.0, y=5.0, z=7.0),
  )
  assert_eq(box.equals(same), true)
  assert_eq(box.equals(box), true)
  assert_eq(box.equals(other), false)
  same.max.z = 7.0
  assert_eq(box.equals(same), false)
  assert_eq(box.max.z, 6.0)
  assert_eq(other.max.z, 7.0)
}

///|
test "Box3.toJSON writes both corners" {
  let box = @math.Box3::new(
    @math.Vector3::new(x=1.0, y=2.0, z=3.0),
    @math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  let (low, high) = box.to_json()
  assert_eq(low.length(), 3)
  assert_eq(low[0], 1.0)
  assert_eq(low[1], 2.0)
  assert_eq(low[2], 3.0)
  assert_eq(high.length(), 3)
  assert_eq(high[0], 4.0)
  assert_eq(high[1], 5.0)
  assert_eq(high[2], 6.0)
  low[0] = 9.0
  assert_eq(box.min.x, 1.0)
  assert_eq(box.max.z, 6.0)
}

///|
test "Box3.fromJSON reads both corners" {
  let box = @math.Box3::new(
    @math.Vector3::new(x=9.0, y=9.0, z=9.0),
    @math.Vector3::new(x=8.0, y=8.0, z=8.0),
  )
  let low = [1.0, 2.0, 3.0]
  let high = [4.0, 5.0, 6.0]
  ignore(box.from_json(low, high))
  assert_eq(box.min.x, 1.0)
  assert_eq(box.min.y, 2.0)
  assert_eq(box.min.z, 3.0)
  assert_eq(box.max.x, 4.0)
  assert_eq(box.max.y, 5.0)
  assert_eq(box.max.z, 6.0)
  assert_eq(low[0], 1.0)
  assert_eq(high[2], 6.0)
}

///|
test "Triangle starts at the origin and copies its corners" {
  let empty = @math.Triangle::new()
  assert_eq(empty.a.x, 0.0)
  assert_eq(empty.a.y, 0.0)
  assert_eq(empty.a.z, 0.0)
  assert_eq(empty.b.x, 0.0)
  assert_eq(empty.c.z, 0.0)
  let a = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  let b = @math.Vector3::new(x=4.0, y=5.0, z=6.0)
  let c = @math.Vector3::new(x=7.0, y=8.0, z=9.0)
  let triangle = @math.Triangle::new(a=a, b=b, c=c)
  assert_eq(triangle.a.x, 1.0)
  assert_eq(triangle.a.y, 2.0)
  assert_eq(triangle.a.z, 3.0)
  assert_eq(triangle.b.y, 5.0)
  assert_eq(triangle.c.z, 9.0)
  a.x = 9.0
  c.z = 0.0
  assert_eq(triangle.a.x, 1.0)
  assert_eq(triangle.c.z, 9.0)
}

///|
test "Triangle.getNormal writes a unit normal" {
  let a = @math.Vector3::new(x=0.0, y=0.0, z=0.0)
  let b = @math.Vector3::new(x=1.0, y=0.0, z=0.0)
  let c = @math.Vector3::new(x=0.0, y=1.0, z=0.0)
  let target = @math.Vector3::new(x=9.0, y=9.0, z=9.0)
  let normal = @math.Triangle::get_normal(a, b, c, target)
  assert_eq(physical_equal(normal, target), true)
  assert_eq(normal.x, 0.0)
  assert_eq(normal.y, 0.0)
  assert_eq(normal.z, 1.0)
  let flat = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  ignore(@math.Triangle::get_normal(flat, flat, flat, target))
  assert_eq(target.x, 0.0)
  assert_eq(target.y, 0.0)
  assert_eq(target.z, 0.0)
  assert_eq(a.x, 0.0)
  assert_eq(b.x, 1.0)
  assert_eq(c.y, 1.0)
}

///|
test "Triangle.getBarycoord writes weights that sum to one" {
  let a = @math.Vector3::new(x=0.0, y=0.0, z=0.0)
  let b = @math.Vector3::new(x=1.0, y=0.0, z=0.0)
  let c = @math.Vector3::new(x=0.0, y=1.0, z=0.0)
  let target = @math.Vector3::new(x=9.0, y=9.0, z=9.0)
  match @math.Triangle::get_barycoord(b, a, b, c, target) {
    None => assert_eq(true, false)
    Some(coord) => {
      assert_eq(physical_equal(coord, target), true)
      assert_eq(coord.x, 0.0)
      assert_eq(coord.y, 1.0)
      assert_eq(coord.z, 0.0)
    }
  }
  let flat = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  match @math.Triangle::get_barycoord(flat, flat, flat, flat, target) {
    None => {
      assert_eq(target.x, 0.0)
      assert_eq(target.y, 0.0)
      assert_eq(target.z, 0.0)
    }
    Some(_) => assert_eq(true, false)
  }
  assert_eq(a.x, 0.0)
  assert_eq(b.y, 0.0)
  assert_eq(c.y, 1.0)
}

///|
test "Triangle.containsPoint includes the boundary" {
  let a = @math.Vector3::new(x=0.0, y=0.0, z=0.0)
  let b = @math.Vector3::new(x=1.0, y=0.0, z=0.0)
  let c = @math.Vector3::new(x=0.0, y=1.0, z=0.0)
  let inside = @math.Vector3::new(x=0.25, y=0.25, z=0.0)
  let corner = @math.Vector3::new(x=1.0, y=0.0, z=0.0)
  let outside = @math.Vector3::new(x=2.0, y=0.0, z=0.0)
  assert_eq(@math.Triangle::contains_point(inside, a, b, c), true)
  assert_eq(@math.Triangle::contains_point(corner, a, b, c), true)
  assert_eq(@math.Triangle::contains_point(outside, a, b, c), false)
  let flat = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  assert_eq(@math.Triangle::contains_point(flat, flat, flat, flat), false)
  assert_eq(inside.x, 0.25)
  assert_eq(a.x, 0.0)
  assert_eq(b.x, 1.0)
  assert_eq(c.y, 1.0)
}

///|
test "Triangle.getInterpolation blends the vertex values" {
  let p1 = @math.Vector3::new(x=0.0, y=0.0, z=0.0)
  let p2 = @math.Vector3::new(x=1.0, y=0.0, z=0.0)
  let p3 = @math.Vector3::new(x=0.0, y=1.0, z=0.0)
  let v1 = @math.Vector3::new(x=1.0, y=0.0, z=0.0)
  let v2 = @math.Vector3::new(x=0.0, y=1.0, z=0.0)
  let v3 = @math.Vector3::new(x=0.0, y=0.0, z=1.0)
  let point = @math.Vector3::new(x=0.5, y=0.5, z=0.0)
  let target = @math.Vector3::new(x=9.0, y=9.0, z=9.0)
  match @math.Triangle::get_interpolation(point, p1, p2, p3, v1, v2, v3, target) {
    None => assert_eq(true, false)
    Some(value) => {
      assert_eq(physical_equal(value, target), true)
      assert_eq(value.x, 0.0)
      assert_eq(value.y, 0.5)
      assert_eq(value.z, 0.5)
    }
  }
  let flat = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  match @math.Triangle::get_interpolation(flat, flat, flat, flat, v1, v2, v3, target) {
    None => {
      assert_eq(target.x, 0.0)
      assert_eq(target.y, 0.0)
      assert_eq(target.z, 0.0)
    }
    Some(_) => assert_eq(true, false)
  }
  assert_eq(point.x, 0.5)
  assert_eq(v2.y, 1.0)
  assert_eq(p2.x, 1.0)
}

///|
test "isFrontFacing is true when the normal opposes the direction" {
  let a = @math.Vector3::new()
  let b = @math.Vector3::new(x=1.0)
  let c = @math.Vector3::new(y=1.0)
  let toward = @math.Vector3::new(z=-1.0)
  let away = @math.Vector3::new(z=1.0)
  assert_eq(@math.Triangle::is_front_facing(a, b, c, toward), true)
  assert_eq(@math.Triangle::is_front_facing(a, b, c, away), false)
  assert_eq(a.x, 0.0)
  assert_eq(b.x, 1.0)
  assert_eq(c.y, 1.0)
  assert_eq(toward.z, -1.0)
}

///|
test "Triangle.set copies the three corners" {
  let triangle = @math.Triangle::new()
  let a = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  let b = @math.Vector3::new(x=4.0, y=5.0, z=6.0)
  let c = @math.Vector3::new(x=7.0, y=8.0, z=9.0)
  ignore(triangle.set(a, b, c))
  assert_eq(triangle.a.x, 1.0)
  assert_eq(triangle.a.y, 2.0)
  assert_eq(triangle.a.z, 3.0)
  assert_eq(triangle.b.y, 5.0)
  assert_eq(triangle.c.z, 9.0)
  a.x = 0.0
  c.z = 0.0
  assert_eq(triangle.a.x, 1.0)
  assert_eq(triangle.c.z, 9.0)
}

///|
test "setFromPointsAndIndices copies three indexed points" {
  let p0 = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  let p1 = @math.Vector3::new(x=4.0, y=5.0, z=6.0)
  let p2 = @math.Vector3::new(x=7.0, y=8.0, z=9.0)
  let p3 = @math.Vector3::new(z=1.0)
  let triangle = @math.Triangle::new()
  ignore(triangle.set_from_points_and_indices([p3, p0, p1, p2], 0, 1, 2))
  assert_eq(triangle.a.z, 1.0)
  assert_eq(triangle.b.x, 1.0)
  assert_eq(triangle.b.y, 2.0)
  assert_eq(triangle.c.y, 5.0)
  assert_eq(triangle.c.z, 6.0)
  p0.x = 0.0
  p3.z = 0.0
  assert_eq(triangle.b.x, 1.0)
  assert_eq(triangle.a.z, 1.0)
}

///|
test "Triangle.copy copies the three corners" {
  let source = @math.Triangle::new(
    a=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    b=@math.Vector3::new(x=4.0, y=5.0, z=6.0),
    c=@math.Vector3::new(x=7.0, y=8.0, z=9.0),
  )
  let triangle = @math.Triangle::new()
  ignore(triangle.copy(source))
  assert_eq(triangle.a.x, 1.0)
  assert_eq(triangle.a.y, 2.0)
  assert_eq(triangle.b.z, 6.0)
  assert_eq(triangle.c.z, 9.0)
  source.a.x = 0.0
  source.c.z = 0.0
  assert_eq(triangle.a.x, 1.0)
  assert_eq(triangle.c.z, 9.0)
}

///|
test "Triangle.clone copies the three corners" {
  let source = @math.Triangle::new(
    a=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    b=@math.Vector3::new(x=4.0, y=5.0, z=6.0),
    c=@math.Vector3::new(x=7.0, y=8.0, z=9.0),
  )
  let triangle = source.clone()
  assert_eq(triangle.a.x, 1.0)
  assert_eq(triangle.a.y, 2.0)
  assert_eq(triangle.b.z, 6.0)
  assert_eq(triangle.c.z, 9.0)
  source.a.x = 0.0
  triangle.c.z = 0.0
  assert_eq(triangle.a.x, 1.0)
  assert_eq(source.c.z, 9.0)
}

///|
test "Triangle.getArea is half the cross product length" {
  let triangle = @math.Triangle::new(
    a=@math.Vector3::new(),
    b=@math.Vector3::new(x=1.0),
    c=@math.Vector3::new(y=1.0),
  )
  assert_eq(triangle.get_area(), 0.5)
  let flat = @math.Triangle::new(
    a=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    b=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    c=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
  )
  assert_eq(flat.get_area(), 0.0)
  assert_eq(triangle.b.x, 1.0)
  assert_eq(triangle.c.y, 1.0)
}

///|
test "Triangle.getMidpoint averages the three corners" {
  let triangle = @math.Triangle::new(
    a=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    b=@math.Vector3::new(x=4.0, y=5.0, z=6.0),
    c=@math.Vector3::new(x=7.0, y=8.0, z=9.0),
  )
  let target = @math.Vector3::new(x=9.0, y=9.0, z=9.0)
  let midpoint = triangle.get_midpoint(target)
  assert_eq(physical_equal(midpoint, target), true)
  assert_eq(midpoint.x, 4.0)
  assert_eq(midpoint.y, 5.0)
  assert_eq(midpoint.z, 6.0)
  assert_eq(triangle.a.x, 1.0)
  assert_eq(triangle.c.z, 9.0)
}

///|
test "Triangle.getNormal on an instance writes a unit normal" {
  let triangle = @math.Triangle::new(
    a=@math.Vector3::new(),
    b=@math.Vector3::new(x=1.0),
    c=@math.Vector3::new(y=1.0),
  )
  let target = @math.Vector3::new(x=9.0, y=9.0, z=9.0)
  let normal = triangle.normal(target)
  assert_eq(physical_equal(normal, target), true)
  assert_eq(normal.x, 0.0)
  assert_eq(normal.y, 0.0)
  assert_eq(normal.z, 1.0)
  let flat = @math.Triangle::new(
    a=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    b=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    c=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
  )
  ignore(flat.normal(target))
  assert_eq(target.x, 0.0)
  assert_eq(target.y, 0.0)
  assert_eq(target.z, 0.0)
  assert_eq(triangle.b.x, 1.0)
  assert_eq(triangle.c.y, 1.0)
}

///|
test "setFromNormalAndCoplanarPoint stores the normal and offset" {
  let plane = @math.Plane::new()
  let normal = @math.Vector3::new(y=1.0)
  let point = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  ignore(plane.set_from_normal_and_coplanar_point(normal, point))
  assert_eq(plane.normal.x, 0.0)
  assert_eq(plane.normal.y, 1.0)
  assert_eq(plane.normal.z, 0.0)
  assert_eq(plane.constant, -2.0)
  assert_eq(plane.distance_to_point(point), 0.0)
  normal.y = 0.0
  point.y = 0.0
  assert_eq(plane.normal.y, 1.0)
  assert_eq(plane.constant, -2.0)
}

///|
test "setFromCoplanarPoints builds the plane through three points" {
  let plane = @math.Plane::new()
  let a = @math.Vector3::new()
  let b = @math.Vector3::new(x=1.0)
  let c = @math.Vector3::new(y=1.0)
  ignore(plane.set_from_coplanar_points(a, b, c))
  assert_eq(plane.normal.x, 0.0)
  assert_eq(plane.normal.y, 0.0)
  assert_eq(plane.normal.z, 1.0)
  assert_eq(plane.constant, 0.0)
  assert_eq(plane.distance_to_point(c), 0.0)
  let flat = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  ignore(plane.set_from_coplanar_points(flat, flat, flat))
  assert_eq(plane.normal.x, 0.0)
  assert_eq(plane.normal.y, 0.0)
  assert_eq(plane.normal.z, 0.0)
  assert_eq(plane.constant, 0.0)
  assert_eq(a.x, 0.0)
  assert_eq(b.x, 1.0)
  assert_eq(c.y, 1.0)
}

///|
test "Triangle.getPlane writes the plane through the corners" {
  let triangle = @math.Triangle::new(
    a=@math.Vector3::new(),
    b=@math.Vector3::new(x=1.0),
    c=@math.Vector3::new(y=1.0),
  )
  let plane = @math.Plane::new()
  let result = triangle.get_plane(plane)
  assert_eq(physical_equal(result.normal, plane.normal), true)
  assert_eq(plane.normal.x, 0.0)
  assert_eq(plane.normal.y, 0.0)
  assert_eq(plane.normal.z, 1.0)
  assert_eq(plane.constant, 0.0)
  assert_eq(plane.distance_to_point(triangle.c), 0.0)
  assert_eq(triangle.b.x, 1.0)
  assert_eq(triangle.c.y, 1.0)
}

///|
test "Triangle.barycoord writes weights that sum to one" {
  let triangle = @math.Triangle::new(
    a=@math.Vector3::new(),
    b=@math.Vector3::new(x=1.0),
    c=@math.Vector3::new(y=1.0),
  )
  let point = @math.Vector3::new(x=1.0)
  let target = @math.Vector3::new(x=9.0, y=9.0, z=9.0)
  match triangle.barycoord(point, target) {
    None => assert_eq(true, false)
    Some(coord) => {
      assert_eq(physical_equal(coord, target), true)
      assert_eq(coord.x, 0.0)
      assert_eq(coord.y, 1.0)
      assert_eq(coord.z, 0.0)
    }
  }
  let flat = @math.Triangle::new(
    a=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    b=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    c=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
  )
  match flat.barycoord(point, target) {
    None => {
      assert_eq(target.x, 0.0)
      assert_eq(target.y, 0.0)
      assert_eq(target.z, 0.0)
    }
    Some(_) => assert_eq(true, false)
  }
  assert_eq(point.x, 1.0)
  assert_eq(triangle.b.x, 1.0)
  assert_eq(triangle.c.y, 1.0)
}

///|
test "Triangle.interpolation blends three values" {
  let triangle = @math.Triangle::new(
    a=@math.Vector3::new(),
    b=@math.Vector3::new(x=1.0),
    c=@math.Vector3::new(y=1.0),
  )
  let point = @math.Vector3::new(x=0.5, y=0.5)
  let v1 = @math.Vector3::new(x=1.0)
  let v2 = @math.Vector3::new(y=1.0)
  let v3 = @math.Vector3::new(z=1.0)
  let target = @math.Vector3::new(x=9.0, y=9.0, z=9.0)
  match triangle.interpolation(point, v1, v2, v3, target) {
    None => assert_eq(true, false)
    Some(value) => {
      assert_eq(physical_equal(value, target), true)
      assert_eq(value.x, 0.0)
      assert_eq(value.y, 0.5)
      assert_eq(value.z, 0.5)
    }
  }
  let flat = @math.Triangle::new(
    a=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    b=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    c=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
  )
  match flat.interpolation(point, v1, v2, v3, target) {
    None => {
      assert_eq(target.x, 0.0)
      assert_eq(target.y, 0.0)
      assert_eq(target.z, 0.0)
    }
    Some(_) => assert_eq(true, false)
  }
  assert_eq(point.x, 0.5)
  assert_eq(v2.y, 1.0)
  assert_eq(triangle.b.x, 1.0)
}

///|
test "Triangle.contains accepts the interior and the boundary" {
  let triangle = @math.Triangle::new(
    a=@math.Vector3::new(),
    b=@math.Vector3::new(x=1.0),
    c=@math.Vector3::new(y=1.0),
  )
  let inside = @math.Vector3::new(x=0.25, y=0.25)
  let corner = @math.Vector3::new(x=1.0)
  let outside = @math.Vector3::new(x=2.0)
  assert_eq(triangle.contains(inside), true)
  assert_eq(triangle.contains(corner), true)
  assert_eq(triangle.contains(outside), false)
  let flat = @math.Triangle::new(
    a=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    b=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    c=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
  )
  assert_eq(flat.contains(inside), false)
  assert_eq(inside.x, 0.25)
  assert_eq(triangle.b.x, 1.0)
  assert_eq(triangle.c.y, 1.0)
}

///|
test "Triangle.front_facing is true when the normal opposes the direction" {
  let triangle = @math.Triangle::new(
    a=@math.Vector3::new(),
    b=@math.Vector3::new(x=1.0),
    c=@math.Vector3::new(y=1.0),
  )
  let toward = @math.Vector3::new(z=-1.0)
  let away = @math.Vector3::new(z=1.0)
  assert_eq(triangle.front_facing(toward), true)
  assert_eq(triangle.front_facing(away), false)
  assert_eq(triangle.b.x, 1.0)
  assert_eq(triangle.c.y, 1.0)
  assert_eq(toward.z, -1.0)
}

///|
test "intersectsTriangle accepts a triangle on the box and rejects a distant one" {
  let box = @math.Box3::new(
    @math.Vector3::new(),
    @math.Vector3::new(x=1.0, y=1.0, z=1.0),
  )
  let triangle = @math.Triangle::new(
    a=@math.Vector3::new(),
    b=@math.Vector3::new(x=1.0),
    c=@math.Vector3::new(y=1.0),
  )
  assert_eq(box.intersects_triangle(triangle), true)
  let far = @math.Triangle::new(
    a=@math.Vector3::new(z=5.0),
    b=@math.Vector3::new(x=1.0, z=5.0),
    c=@math.Vector3::new(y=1.0, z=5.0),
  )
  assert_eq(box.intersects_triangle(far), false)
  assert_eq(@math.Box3::empty().intersects_triangle(triangle), false)
  assert_eq(triangle.b.x, 1.0)
  assert_eq(box.max.z, 1.0)
}

///|
test "Triangle.intersectsBox matches the box test" {
  let triangle = @math.Triangle::new(
    a=@math.Vector3::new(),
    b=@math.Vector3::new(x=1.0),
    c=@math.Vector3::new(y=1.0),
  )
  let box = @math.Box3::new(
    @math.Vector3::new(),
    @math.Vector3::new(x=1.0, y=1.0, z=1.0),
  )
  assert_eq(triangle.intersects_box(box), true)
  let far = @math.Box3::new(
    @math.Vector3::new(z=5.0),
    @math.Vector3::new(x=1.0, y=1.0, z=6.0),
  )
  assert_eq(triangle.intersects_box(far), false)
  assert_eq(triangle.intersects_box(@math.Box3::empty()), false)
  assert_eq(triangle.b.x, 1.0)
  assert_eq(box.max.z, 1.0)
}

///|
test "closestPointToPoint projects onto the triangle" {
  let triangle = @math.Triangle::new(
    a=@math.Vector3::new(),
    b=@math.Vector3::new(x=1.0),
    c=@math.Vector3::new(y=1.0),
  )
  let above = @math.Vector3::new(x=0.25, y=0.25, z=3.0)
  let target = @math.Vector3::new(x=9.0, y=9.0, z=9.0)
  let closest = triangle.closest_point_to_point(above, target)
  assert_eq(physical_equal(closest, target), true)
  assert_eq(closest.x, 0.25)
  assert_eq(closest.y, 0.25)
  assert_eq(closest.z, 0.0)
  let outside = @math.Vector3::new(x=2.0, y=-1.0)
  ignore(triangle.closest_point_to_point(outside, target))
  assert_eq(target.x, 1.0)
  assert_eq(target.y, 0.0)
  assert_eq(target.z, 0.0)
  assert_eq(above.z, 3.0)
  assert_eq(triangle.b.x, 1.0)
  assert_eq(triangle.c.y, 1.0)
}

///|
test "Triangle.equals compares the three corners" {
  let triangle = @math.Triangle::new(
    a=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    b=@math.Vector3::new(x=4.0, y=5.0, z=6.0),
    c=@math.Vector3::new(x=7.0, y=8.0, z=9.0),
  )
  let same = triangle.clone()
  assert_eq(triangle.equals(same), true)
  assert_eq(triangle.equals(triangle), true)
  same.c.z = 0.0
  assert_eq(triangle.equals(same), false)
  assert_eq(triangle.c.z, 9.0)
}

///|
test "Plane.set copies the normal and stores the constant" {
  let plane = @math.Plane::new()
  let normal = @math.Vector3::new(y=1.0)
  ignore(plane.set(normal, -2.0))
  assert_eq(plane.normal.x, 0.0)
  assert_eq(plane.normal.y, 1.0)
  assert_eq(plane.normal.z, 0.0)
  assert_eq(plane.constant, -2.0)
  normal.y = 0.0
  assert_eq(plane.normal.y, 1.0)
  assert_eq(plane.constant, -2.0)
}

///|
test "Plane.negate flips the normal and the constant" {
  let plane = @math.Plane::new()
  ignore(plane.set(@math.Vector3::new(y=1.0), -2.0))
  ignore(plane.negate())
  assert_eq(plane.normal.x, 0.0)
  assert_eq(plane.normal.y, -1.0)
  assert_eq(plane.normal.z, 0.0)
  assert_eq(plane.constant, 2.0)
  let point = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  assert_eq(plane.distance_to_point(point), 0.0)
}

///|
test "distanceToSphere subtracts the radius from the center distance" {
  let plane = @math.Plane::new()
  let sphere = @math.Sphere::new(center=@math.Vector3::new(x=3.0), radius=1.0)
  assert_eq(plane.distance_to_sphere(sphere), 2.0)
  assert_eq(sphere.center.x, 3.0)
  assert_eq(sphere.radius, 1.0)
  assert_eq(plane.constant, 0.0)
}

///|
test "projectPoint drops the point onto the plane" {
  let plane = @math.Plane::new()
  let point = @math.Vector3::new(x=3.0, y=4.0, z=5.0)
  let target = @math.Vector3::new(x=9.0, y=9.0, z=9.0)
  let projected = plane.project_point(point, target)
  assert_eq(physical_equal(projected, target), true)
  assert_eq(projected.x, 0.0)
  assert_eq(projected.y, 4.0)
  assert_eq(projected.z, 5.0)
  assert_eq(point.x, 3.0)
  assert_eq(plane.normal.x, 1.0)
}

///|
test "Line3 stores copies of its endpoints" {
  let empty = @math.Line3::new()
  assert_eq(empty.start.x, 0.0)
  assert_eq(empty.start.y, 0.0)
  assert_eq(empty.start.z, 0.0)
  assert_eq(empty.end.x, 0.0)
  let start = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  let end = @math.Vector3::new(x=4.0, y=5.0, z=6.0)
  let line = @math.Line3::new(start=start, end=end)
  assert_eq(line.start.x, 1.0)
  assert_eq(line.start.y, 2.0)
  assert_eq(line.start.z, 3.0)
  assert_eq(line.end.y, 5.0)
  assert_eq(line.end.z, 6.0)
  start.x = 9.0
  end.z = 0.0
  assert_eq(line.start.x, 1.0)
  assert_eq(line.end.z, 6.0)
}

///|
test "Line3.set copies both endpoints" {
  let line = @math.Line3::new()
  let start = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  let end = @math.Vector3::new(x=4.0, y=5.0, z=6.0)
  ignore(line.set(start, end))
  assert_eq(line.start.x, 1.0)
  assert_eq(line.start.y, 2.0)
  assert_eq(line.start.z, 3.0)
  assert_eq(line.end.y, 5.0)
  assert_eq(line.end.z, 6.0)
  start.x = 0.0
  end.z = 0.0
  assert_eq(line.start.x, 1.0)
  assert_eq(line.end.z, 6.0)
}

///|
test "Line3.copy copies both endpoints" {
  let source = @math.Line3::new(
    start=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    end=@math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  let line = @math.Line3::new()
  ignore(line.copy(source))
  assert_eq(line.start.x, 1.0)
  assert_eq(line.start.y, 2.0)
  assert_eq(line.end.z, 6.0)
  source.start.x = 0.0
  source.end.z = 0.0
  assert_eq(line.start.x, 1.0)
  assert_eq(line.end.z, 6.0)
}

///|
test "Line3.getCenter averages the endpoints" {
  let line = @math.Line3::new(
    start=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    end=@math.Vector3::new(x=3.0, y=6.0, z=9.0),
  )
  let target = @math.Vector3::new(x=9.0, y=9.0, z=9.0)
  let center = line.get_center(target)
  assert_eq(physical_equal(center, target), true)
  assert_eq(center.x, 2.0)
  assert_eq(center.y, 4.0)
  assert_eq(center.z, 6.0)
  assert_eq(line.start.x, 1.0)
  assert_eq(line.end.z, 9.0)
}

///|
test "Line3.delta subtracts the start from the end" {
  let line = @math.Line3::new(
    start=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    end=@math.Vector3::new(x=4.0, y=6.0, z=9.0),
  )
  let target = @math.Vector3::new(x=9.0, y=9.0, z=9.0)
  let delta = line.delta(target)
  assert_eq(physical_equal(delta, target), true)
  assert_eq(delta.x, 3.0)
  assert_eq(delta.y, 4.0)
  assert_eq(delta.z, 6.0)
  assert_eq(line.start.x, 1.0)
  assert_eq(line.end.z, 9.0)
}

///|
test "Line3.distanceSq is the squared length" {
  let line = @math.Line3::new(
    start=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    end=@math.Vector3::new(x=4.0, y=6.0, z=9.0),
  )
  assert_eq(line.distance_sq(), 61.0)
  assert_eq(line.start.x, 1.0)
  assert_eq(line.end.z, 9.0)
}

///|
test "Line3.distance is the length" {
  let line = @math.Line3::new(
    start=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    end=@math.Vector3::new(x=4.0, y=6.0, z=3.0),
  )
  assert_eq(line.distance(), 5.0)
  assert_eq(line.start.x, 1.0)
  assert_eq(line.end.y, 6.0)
}

///|
test "Line3.at samples a point along the segment" {
  let line = @math.Line3::new(
    start=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    end=@math.Vector3::new(x=5.0, y=6.0, z=7.0),
  )
  let target = @math.Vector3::new(x=9.0, y=9.0, z=9.0)
  let mid = line.at(0.5, target)
  assert_eq(physical_equal(mid, target), true)
  assert_eq(mid.x, 3.0)
  assert_eq(mid.y, 4.0)
  assert_eq(mid.z, 5.0)
  ignore(line.at(0.0, target))
  assert_eq(target.x, 1.0)
  assert_eq(target.y, 2.0)
  assert_eq(target.z, 3.0)
  assert_eq(line.end.z, 7.0)
}

///|
test "closestPointToPointParameter clamps when asked" {
  let line = @math.Line3::new(
    start=@math.Vector3::new(),
    end=@math.Vector3::new(x=2.0),
  )
  let mid = @math.Vector3::new(x=1.0, y=5.0)
  let past = @math.Vector3::new(x=4.0)
  assert_eq(line.closest_point_to_point_parameter(mid, false), 0.5)
  assert_eq(line.closest_point_to_point_parameter(past, false), 2.0)
  assert_eq(line.closest_point_to_point_parameter(past, true), 1.0)
  let flat = @math.Line3::new(
    start=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    end=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
  )
  assert_eq(flat.closest_point_to_point_parameter(past, true), 0.0)
  assert_eq(line.end.x, 2.0)
  assert_eq(past.x, 4.0)
}

///|
test "Line3.closestPointToPoint writes the nearest point" {
  let line = @math.Line3::new(
    start=@math.Vector3::new(),
    end=@math.Vector3::new(x=2.0),
  )
  let above = @math.Vector3::new(x=1.0, y=5.0)
  let target = @math.Vector3::new(x=9.0, y=9.0, z=9.0)
  let nearest = line.closest_point_to_point(above, true, target)
  assert_eq(physical_equal(nearest, target), true)
  assert_eq(nearest.x, 1.0)
  assert_eq(nearest.y, 0.0)
  assert_eq(nearest.z, 0.0)
  let past = @math.Vector3::new(x=4.0)
  ignore(line.closest_point_to_point(past, false, target))
  assert_eq(target.x, 4.0)
  assert_eq(target.y, 0.0)
  ignore(line.closest_point_to_point(past, true, target))
  assert_eq(target.x, 2.0)
  assert_eq(line.end.x, 2.0)
  assert_eq(above.y, 5.0)
}

///|
test "distanceSqToLine3 measures the gap between two segments" {
  let line = @math.Line3::new(
    start=@math.Vector3::new(),
    end=@math.Vector3::new(x=2.0),
  )
  let other = @math.Line3::new(
    start=@math.Vector3::new(y=1.0),
    end=@math.Vector3::new(x=2.0, y=1.0),
  )
  let c1 = @math.Vector3::new(x=9.0, y=9.0, z=9.0)
  let c2 = @math.Vector3::new(x=8.0, y=8.0, z=8.0)
  assert_eq(line.distance_sq_to_line3(other, c1=c1, c2=c2), 1.0)
  assert_eq(c1.x, 0.0)
  assert_eq(c1.y, 0.0)
  assert_eq(c1.z, 0.0)
  assert_eq(c2.x, 0.0)
  assert_eq(c2.y, 1.0)
  assert_eq(c2.z, 0.0)
  assert_eq(line.distance_sq_to_line3(line), 0.0)
  let point = @math.Line3::new(
    start=@math.Vector3::new(x=3.0),
    end=@math.Vector3::new(x=3.0),
  )
  let here = @math.Line3::new()
  assert_eq(here.distance_sq_to_line3(point), 9.0)
  assert_eq(line.end.x, 2.0)
  assert_eq(other.start.y, 1.0)
}

///|
test "Line3.applyMatrix4 transforms both endpoints" {
  let line = @math.Line3::new(end=@math.Vector3::new(x=4.0))
  let matrix = @math.Matrix4::new().make_translation(1.0, 2.0, 3.0)
  ignore(line.apply_matrix4(matrix))
  assert_eq(line.start.x, 1.0)
  assert_eq(line.start.y, 2.0)
  assert_eq(line.start.z, 3.0)
  assert_eq(line.end.x, 5.0)
  assert_eq(line.end.y, 2.0)
  assert_eq(line.end.z, 3.0)
  assert_eq(matrix.elements[12], 1.0)
}

///|
test "Line3.equals compares both endpoints" {
  let line = @math.Line3::new(
    start=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    end=@math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  let same = @math.Line3::new(
    start=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    end=@math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  assert_eq(line.equals(same), true)
  assert_eq(line.equals(line), true)
  same.end.z = 0.0
  assert_eq(line.equals(same), false)
  assert_eq(line.end.z, 6.0)
}

///|
test "Line3.clone copies both endpoints" {
  let source = @math.Line3::new(
    start=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    end=@math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  let line = source.clone()
  assert_eq(line.start.x, 1.0)
  assert_eq(line.start.y, 2.0)
  assert_eq(line.end.z, 6.0)
  source.start.x = 0.0
  line.end.z = 0.0
  assert_eq(line.start.x, 1.0)
  assert_eq(source.end.z, 6.0)
}

///|
test "intersectLine writes the crossing and skips a miss" {
  let plane = @math.Plane::new()
  let crossing = @math.Line3::new(
    start=@math.Vector3::new(x=-1.0, y=2.0, z=3.0),
    end=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
  )
  let target = @math.Vector3::new(x=9.0, y=9.0, z=9.0)
  match plane.intersect_line(crossing, target) {
    None => assert_eq(true, false)
    Some(hit) => {
      assert_eq(physical_equal(hit, target), true)
      assert_eq(hit.x, 0.0)
      assert_eq(hit.y, 2.0)
      assert_eq(hit.z, 3.0)
    }
  }
  let miss = @math.Line3::new(
    start=@math.Vector3::new(x=1.0),
    end=@math.Vector3::new(x=2.0),
  )
  match plane.intersect_line(miss, target) {
    None => assert_eq(true, true)
    Some(_) => assert_eq(true, false)
  }
  let on_plane = @math.Line3::new(end=@math.Vector3::new(y=1.0))
  match plane.intersect_line(on_plane, target) {
    None => assert_eq(true, false)
    Some(hit) => {
      assert_eq(hit.x, 0.0)
      assert_eq(hit.y, 0.0)
      assert_eq(hit.z, 0.0)
    }
  }
  assert_eq(crossing.start.x, -1.0)
  assert_eq(plane.normal.x, 1.0)
}

///|
test "intersectsLine is true only when the ends are on opposite sides" {
  let plane = @math.Plane::new()
  let crossing = @math.Line3::new(
    start=@math.Vector3::new(x=-1.0),
    end=@math.Vector3::new(x=1.0),
  )
  let aside = @math.Line3::new(
    start=@math.Vector3::new(x=1.0),
    end=@math.Vector3::new(x=2.0),
  )
  let lying = @math.Line3::new(end=@math.Vector3::new(y=1.0))
  assert_eq(plane.intersects_line(crossing), true)
  assert_eq(plane.intersects_line(aside), false)
  assert_eq(plane.intersects_line(lying), false)
  assert_eq(crossing.start.x, -1.0)
  assert_eq(plane.constant, 0.0)
}

///|
test "Plane.intersectsBox matches the box test" {
  let box = @math.Box3::new(
    @math.Vector3::new(x=1.0, y=2.0, z=3.0),
    @math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  let through = @math.Plane::new(constant=-2.0)
  let before = @math.Plane::new()
  assert_eq(through.intersects_box(box), true)
  assert_eq(before.intersects_box(box), false)
  assert_eq(through.intersects_box(@math.Box3::empty()), false)
  assert_eq(box.min.x, 1.0)
  assert_eq(through.constant, -2.0)
}

///|
test "intersectsPlane accepts a tangent sphere and rejects a distant one" {
  let plane = @math.Plane::new()
  let touching = @math.Sphere::new(center=@math.Vector3::new(x=1.0), radius=1.0)
  let apart = @math.Sphere::new(center=@math.Vector3::new(x=3.0), radius=1.0)
  let empty = @math.Sphere::new()
  assert_eq(touching.intersects_plane(plane), true)
  assert_eq(apart.intersects_plane(plane), false)
  assert_eq(empty.intersects_plane(plane), false)
  assert_eq(touching.radius, 1.0)
  assert_eq(plane.constant, 0.0)
}

///|
test "Plane.intersectsSphere matches the sphere test" {
  let plane = @math.Plane::new()
  let touching = @math.Sphere::new(center=@math.Vector3::new(x=1.0), radius=1.0)
  let apart = @math.Sphere::new(center=@math.Vector3::new(x=3.0), radius=1.0)
  assert_eq(plane.intersects_sphere(touching), true)
  assert_eq(plane.intersects_sphere(apart), false)
  assert_eq(plane.intersects_sphere(@math.Sphere::new()), false)
  assert_eq(touching.center.x, 1.0)
  assert_eq(plane.normal.x, 1.0)
}

///|
test "coplanarPoint scales the normal by the negated constant" {
  let plane = @math.Plane::new(constant=-2.0)
  let target = @math.Vector3::new(x=9.0, y=9.0, z=9.0)
  let point = plane.coplanar_point(target)
  assert_eq(physical_equal(point, target), true)
  assert_eq(point.x, 2.0)
  assert_eq(point.y, 0.0)
  assert_eq(point.z, 0.0)
  assert_eq(plane.distance_to_point(point), 0.0)
  assert_eq(plane.constant, -2.0)
  assert_eq(plane.normal.x, 1.0)
}

///|
test "Plane.applyMatrix4 translates the plane" {
  let plane = @math.Plane::new()
  let matrix = @math.Matrix4::new().make_translation(2.0, 0.0, 0.0)
  ignore(plane.apply_matrix4(matrix))
  assert_eq(plane.normal.x, 1.0)
  assert_eq(plane.normal.y, 0.0)
  assert_eq(plane.normal.z, 0.0)
  assert_eq(plane.constant, -2.0)
  assert_eq(matrix.elements[12], 2.0)
}

///|
test "Plane.translate shifts the constant along the normal" {
  let plane = @math.Plane::new()
  let offset = @math.Vector3::new(x=2.0, y=3.0)
  ignore(plane.translate(offset))
  assert_eq(plane.normal.x, 1.0)
  assert_eq(plane.normal.y, 0.0)
  assert_eq(plane.constant, -2.0)
  assert_eq(offset.x, 2.0)
  assert_eq(offset.y, 3.0)
}

///|
test "Plane.equals compares the normal and the constant" {
  let plane = @math.Plane::new(constant=-2.0)
  let same = @math.Plane::new(constant=-2.0)
  let other = @math.Plane::new(constant=-1.0)
  assert_eq(plane.equals(same), true)
  assert_eq(plane.equals(plane), true)
  assert_eq(plane.equals(other), false)
  other.constant = -2.0
  other.normal.y = 1.0
  assert_eq(plane.equals(other), false)
  assert_eq(plane.constant, -2.0)
  assert_eq(plane.normal.x, 1.0)
}

///|
test "Plane.clone copies the normal and the constant" {
  let source = @math.Plane::new(
    normal=@math.Vector3::new(y=1.0),
    constant=-2.0,
  )
  let plane = source.clone()
  assert_eq(plane.normal.x, 0.0)
  assert_eq(plane.normal.y, 1.0)
  assert_eq(plane.constant, -2.0)
  source.normal.y = 0.0
  plane.constant = 0.0
  assert_eq(plane.normal.y, 1.0)
  assert_eq(source.constant, -2.0)
}

///|
test "Plane.toJSON writes the normal and the constant" {
  let plane = @math.Plane::new(
    normal=@math.Vector3::new(y=1.0),
    constant=-2.0,
  )
  let (normal, constant) = plane.to_json()
  assert_eq(normal.length(), 3)
  assert_eq(normal[0], 0.0)
  assert_eq(normal[1], 1.0)
  assert_eq(normal[2], 0.0)
  assert_eq(constant, -2.0)
  normal[1] = 9.0
  assert_eq(plane.normal.y, 1.0)
  assert_eq(plane.constant, -2.0)
}

///|
test "Plane.fromJSON reads the normal and the constant" {
  let plane = @math.Plane::new()
  let normal = [0.0, 1.0, 0.0]
  ignore(plane.from_json(normal, -2.0))
  assert_eq(plane.normal.x, 0.0)
  assert_eq(plane.normal.y, 1.0)
  assert_eq(plane.normal.z, 0.0)
  assert_eq(plane.constant, -2.0)
  normal[1] = 9.0
  assert_eq(plane.normal.y, 1.0)
}

///|
test "Sphere.set copies the center and stores the radius" {
  let sphere = @math.Sphere::new()
  let center = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  ignore(sphere.set(center, 4.0))
  assert_eq(sphere.center.x, 1.0)
  assert_eq(sphere.center.y, 2.0)
  assert_eq(sphere.center.z, 3.0)
  assert_eq(sphere.radius, 4.0)
  center.x = 0.0
  assert_eq(sphere.center.x, 1.0)
  assert_eq(sphere.radius, 4.0)
}

///|
test "Sphere.distanceToPoint is negative inside the sphere" {
  let sphere = @math.Sphere::new(radius=1.0)
  let outside = @math.Vector3::new(x=3.0)
  let inside = @math.Vector3::new()
  assert_eq(sphere.distance_to_point(outside), 2.0)
  assert_eq(sphere.distance_to_point(inside), -1.0)
  assert_eq(outside.x, 3.0)
  assert_eq(sphere.radius, 1.0)
}

///|
test "Sphere.intersectsBox counts a tangent box" {
  let touch = @math.Sphere::new(
    center=@math.Vector3::new(x=0.0, y=3.0, z=4.0),
    radius=1.0,
  )
  let apart = @math.Sphere::new(
    center=@math.Vector3::new(x=0.0, y=3.0, z=4.0),
    radius=0.5,
  )
  let inside = @math.Sphere::new(
    center=@math.Vector3::new(x=2.0, y=3.0, z=4.0),
    radius=0.0,
  )
  let box = @math.Box3::new(
    @math.Vector3::new(x=1.0, y=2.0, z=3.0),
    @math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  assert_eq(touch.intersects_box(box), true)
  assert_eq(apart.intersects_box(box), false)
  assert_eq(inside.intersects_box(box), true)
  assert_eq(touch.center.x, 0.0)
  assert_eq(touch.radius, 1.0)
  assert_eq(box.min.x, 1.0)
  assert_eq(box.max.z, 6.0)
}

///|
test "Sphere.clampPoint pulls an outside point onto the sphere" {
  let sphere = @math.Sphere::new(radius=1.0)
  let outside = @math.Vector3::new(x=2.0)
  let inside = @math.Vector3::new(x=0.5)
  let target = @math.Vector3::new(x=9.0)
  ignore(sphere.clamp_point(outside, target))
  assert_eq(target.x, 1.0)
  assert_eq(target.y, 0.0)
  assert_eq(target.z, 0.0)
  ignore(sphere.clamp_point(inside, target))
  assert_eq(target.x, 0.5)
  assert_eq(target.y, 0.0)
  assert_eq(target.z, 0.0)
  assert_eq(outside.x, 2.0)
  assert_eq(inside.x, 0.5)
  assert_eq(sphere.radius, 1.0)
  assert_eq(sphere.center.x, 0.0)
}

///|
test "Sphere.getBoundingBox encloses the sphere" {
  let center = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  let sphere = @math.Sphere::new(center=center, radius=1.0)
  let box = @math.Box3::empty()
  ignore(sphere.get_bounding_box(box))
  assert_eq(box.min.x, 0.0)
  assert_eq(box.min.y, 1.0)
  assert_eq(box.min.z, 2.0)
  assert_eq(box.max.x, 2.0)
  assert_eq(box.max.y, 3.0)
  assert_eq(box.max.z, 4.0)
  assert_eq(sphere.center.x, 1.0)
  assert_eq(sphere.radius, 1.0)
  let empty = @math.Sphere::new()
  ignore(empty.get_bounding_box(box))
  assert_eq(box.is_empty(), true)
  assert_eq(empty.radius, -1.0)
}

///|
test "Sphere.translate moves the center and keeps the radius" {
  let sphere = @math.Sphere::new(radius=1.0)
  let offset = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  ignore(sphere.translate(offset))
  assert_eq(sphere.center.x, 1.0)
  assert_eq(sphere.center.y, 2.0)
  assert_eq(sphere.center.z, 3.0)
  assert_eq(sphere.radius, 1.0)
  assert_eq(offset.x, 1.0)
  assert_eq(offset.y, 2.0)
  assert_eq(offset.z, 3.0)
}

///|
test "Sphere.expandByPoint grows the radius to include a point" {
  let sphere = @math.Sphere::new(radius=1.0)
  let inside = @math.Vector3::new(x=0.5)
  ignore(sphere.expand_by_point(inside))
  assert_eq(sphere.center.x, 0.0)
  assert_eq(sphere.radius, 1.0)
  let outside = @math.Vector3::new(x=3.0)
  ignore(sphere.expand_by_point(outside))
  assert_eq(sphere.center.x, 1.0)
  assert_eq(sphere.center.y, 0.0)
  assert_eq(sphere.center.z, 0.0)
  assert_eq(sphere.radius, 2.0)
  assert_eq(outside.x, 3.0)
  let empty = @math.Sphere::new()
  let point = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  ignore(empty.expand_by_point(point))
  assert_eq(empty.center.x, 1.0)
  assert_eq(empty.center.y, 2.0)
  assert_eq(empty.center.z, 3.0)
  assert_eq(empty.radius, 0.0)
  assert_eq(point.x, 1.0)
}

///|
test "Sphere.union encloses both spheres" {
  let sphere = @math.Sphere::new(radius=1.0)
  let other = @math.Sphere::new(
    center=@math.Vector3::new(x=4.0),
    radius=1.0,
  )
  ignore(sphere.union(other))
  assert_eq(sphere.center.x, 2.0)
  assert_eq(sphere.center.y, 0.0)
  assert_eq(sphere.center.z, 0.0)
  assert_eq(sphere.radius, 3.0)
  assert_eq(other.center.x, 4.0)
  assert_eq(other.radius, 1.0)
  let shared = @math.Sphere::new(radius=1.0)
  ignore(shared.union(@math.Sphere::new(radius=3.0)))
  assert_eq(shared.center.x, 0.0)
  assert_eq(shared.radius, 3.0)
  let kept = @math.Sphere::new(radius=1.0)
  ignore(kept.union(@math.Sphere::new()))
  assert_eq(kept.center.x, 0.0)
  assert_eq(kept.radius, 1.0)
}

///|
test "Sphere.equals matches center and radius" {
  let sphere = @math.Sphere::new(
    center=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    radius=4.0,
  )
  let same = @math.Sphere::new(
    center=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    radius=4.0,
  )
  let other_radius = @math.Sphere::new(
    center=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    radius=5.0,
  )
  let other_center = @math.Sphere::new(
    center=@math.Vector3::new(x=0.0, y=2.0, z=3.0),
    radius=4.0,
  )
  assert_eq(sphere.equals(same), true)
  assert_eq(sphere.equals(other_radius), false)
  assert_eq(sphere.equals(other_center), false)
  assert_eq(sphere.center.x, 1.0)
  assert_eq(sphere.radius, 4.0)
  assert_eq(same.radius, 4.0)
}

///|
test "Sphere.clone copies the center and the radius" {
  let source = @math.Sphere::new(
    center=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    radius=4.0,
  )
  let sphere = source.clone()
  assert_eq(sphere.center.x, 1.0)
  assert_eq(sphere.center.y, 2.0)
  assert_eq(sphere.center.z, 3.0)
  assert_eq(sphere.radius, 4.0)
  source.center.x = 0.0
  sphere.radius = 0.0
  assert_eq(sphere.center.x, 1.0)
  assert_eq(source.radius, 4.0)
}

///|
test "Sphere.toJSON writes the center and the radius" {
  let sphere = @math.Sphere::new(
    center=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    radius=4.0,
  )
  let (center, radius) = sphere.to_json()
  assert_eq(center.length(), 3)
  assert_eq(center[0], 1.0)
  assert_eq(center[1], 2.0)
  assert_eq(center[2], 3.0)
  assert_eq(radius, 4.0)
  center[0] = 9.0
  assert_eq(sphere.center.x, 1.0)
  assert_eq(sphere.radius, 4.0)
}

///|
test "Sphere.fromJSON reads the center and the radius" {
  let sphere = @math.Sphere::new()
  let center = [1.0, 2.0, 3.0]
  ignore(sphere.from_json(center, 4.0))
  assert_eq(sphere.center.x, 1.0)
  assert_eq(sphere.center.y, 2.0)
  assert_eq(sphere.center.z, 3.0)
  assert_eq(sphere.radius, 4.0)
  center[0] = 9.0
  assert_eq(sphere.center.x, 1.0)
}

///|
test "Ray stores copies of its origin and direction" {
  let empty = @math.Ray::new()
  assert_eq(empty.origin.x, 0.0)
  assert_eq(empty.origin.y, 0.0)
  assert_eq(empty.origin.z, 0.0)
  assert_eq(empty.direction.x, 0.0)
  assert_eq(empty.direction.y, 0.0)
  assert_eq(empty.direction.z, -1.0)
  let origin = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  let direction = @math.Vector3::new(y=1.0)
  let ray = @math.Ray::new(origin=origin, direction=direction)
  assert_eq(ray.origin.x, 1.0)
  assert_eq(ray.origin.y, 2.0)
  assert_eq(ray.origin.z, 3.0)
  assert_eq(ray.direction.x, 0.0)
  assert_eq(ray.direction.y, 1.0)
  assert_eq(ray.direction.z, 0.0)
  origin.x = 9.0
  direction.y = 0.0
  assert_eq(ray.origin.x, 1.0)
  assert_eq(ray.direction.y, 1.0)
}

///|
test "Ray.set copies the origin and the direction" {
  let ray = @math.Ray::new()
  let origin = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  let direction = @math.Vector3::new(x=4.0, y=5.0, z=6.0)
  ignore(ray.set(origin, direction))
  assert_eq(ray.origin.x, 1.0)
  assert_eq(ray.origin.y, 2.0)
  assert_eq(ray.origin.z, 3.0)
  assert_eq(ray.direction.x, 4.0)
  assert_eq(ray.direction.y, 5.0)
  assert_eq(ray.direction.z, 6.0)
  origin.x = 0.0
  direction.z = 0.0
  assert_eq(ray.origin.x, 1.0)
  assert_eq(ray.direction.z, 6.0)
}

///|
test "Ray.copy copies the origin and the direction" {
  let source = @math.Ray::new(
    origin=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    direction=@math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  let ray = @math.Ray::new()
  ignore(ray.copy(source))
  assert_eq(ray.origin.x, 1.0)
  assert_eq(ray.origin.y, 2.0)
  assert_eq(ray.origin.z, 3.0)
  assert_eq(ray.direction.x, 4.0)
  assert_eq(ray.direction.y, 5.0)
  assert_eq(ray.direction.z, 6.0)
  source.origin.x = 0.0
  source.direction.z = 0.0
  assert_eq(ray.origin.x, 1.0)
  assert_eq(ray.direction.z, 6.0)
}

///|
test "Ray.at walks a distance along the direction" {
  let ray = @math.Ray::new(
    origin=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    direction=@math.Vector3::new(y=1.0),
  )
  let target = @math.Vector3::new(x=9.0)
  let point = ray.at(0.5, target)
  assert_eq(physical_equal(point, target), true)
  assert_eq(target.x, 1.0)
  assert_eq(target.y, 2.5)
  assert_eq(target.z, 3.0)
  ignore(ray.at(0.0, target))
  assert_eq(target.x, 1.0)
  assert_eq(target.y, 2.0)
  assert_eq(target.z, 3.0)
  assert_eq(ray.origin.x, 1.0)
  assert_eq(ray.direction.y, 1.0)
}

///|
test "Ray.lookAt points the direction at a position" {
  let ray = @math.Ray::new(origin=@math.Vector3::new(x=1.0, y=2.0, z=3.0))
  let target = @math.Vector3::new(x=1.0, y=5.0, z=3.0)
  ignore(ray.look_at(target))
  assert_eq(ray.direction.x, 0.0)
  assert_eq(ray.direction.y, 1.0)
  assert_eq(ray.direction.z, 0.0)
  assert_eq(ray.origin.y, 2.0)
  assert_eq(target.y, 5.0)
}

///|
test "Ray.recast shifts the origin along the direction" {
  let ray = @math.Ray::new(
    origin=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    direction=@math.Vector3::new(y=1.0),
  )
  ignore(ray.recast(0.5))
  assert_eq(ray.origin.x, 1.0)
  assert_eq(ray.origin.y, 2.5)
  assert_eq(ray.origin.z, 3.0)
  assert_eq(ray.direction.x, 0.0)
  assert_eq(ray.direction.y, 1.0)
  assert_eq(ray.direction.z, 0.0)
}

///|
test "Ray.closestPointToPoint stays on the ray" {
  let ray = @math.Ray::new()
  let ahead = @math.Vector3::new(x=4.0, y=5.0, z=-2.0)
  let behind = @math.Vector3::new(x=4.0, y=5.0, z=3.0)
  let target = @math.Vector3::new(x=9.0)
  let nearest = ray.closest_point_to_point(ahead, target)
  assert_eq(physical_equal(nearest, target), true)
  assert_eq(target.x, 0.0)
  assert_eq(target.y, 0.0)
  assert_eq(target.z, -2.0)
  ignore(ray.closest_point_to_point(behind, target))
  assert_eq(target.x, 0.0)
  assert_eq(target.y, 0.0)
  assert_eq(target.z, 0.0)
  assert_eq(ahead.x, 4.0)
  assert_eq(ray.origin.x, 0.0)
  assert_eq(ray.direction.z, -1.0)
}

///|
test "Ray.distanceSqToPoint is zero on the ray" {
  let ray = @math.Ray::new()
  let ahead = @math.Vector3::new(x=4.0, y=5.0, z=-2.0)
  let behind = @math.Vector3::new(x=4.0, y=5.0, z=3.0)
  let on_ray = @math.Vector3::new(z=-2.0)
  assert_eq(ray.distance_sq_to_point(ahead), 41.0)
  assert_eq(ray.distance_sq_to_point(behind), 50.0)
  assert_eq(ray.distance_sq_to_point(on_ray), 0.0)
  assert_eq(ahead.x, 4.0)
  assert_eq(ray.direction.z, -1.0)
}

///|
test "Ray.distanceToPoint is the root of the squared distance" {
  let ray = @math.Ray::new()
  let ahead = @math.Vector3::new(x=3.0, y=4.0, z=-2.0)
  let behind = @math.Vector3::new(z=3.0)
  let on_ray = @math.Vector3::new(z=-2.0)
  assert_eq(ray.distance_to_point(ahead), 5.0)
  assert_eq(ray.distance_to_point(behind), 3.0)
  assert_eq(ray.distance_to_point(on_ray), 0.0)
  assert_eq(ahead.x, 3.0)
  assert_eq(ray.direction.z, -1.0)
}

///|
test "Ray.distanceSqToSegment meets a crossing segment" {
  let ray = @math.Ray::new(direction=@math.Vector3::new(x=1.0))
  let v0 = @math.Vector3::new(x=2.0, y=-1.0)
  let v1 = @math.Vector3::new(x=2.0, y=1.0)
  let on_ray = @math.Vector3::new(x=9.0)
  let on_segment = @math.Vector3::new(y=9.0)
  assert_eq(
    ray.distance_sq_to_segment(
      v0,
      v1,
      point_on_ray=on_ray,
      point_on_segment=on_segment,
    ),
    0.0,
  )
  assert_eq(on_ray.x, 2.0)
  assert_eq(on_ray.y, 0.0)
  assert_eq(on_ray.z, 0.0)
  assert_eq(on_segment.x, 2.0)
  assert_eq(on_segment.y, 0.0)
  assert_eq(on_segment.z, 0.0)
  let parallel0 = @math.Vector3::new(y=1.0)
  let parallel1 = @math.Vector3::new(x=2.0, y=1.0)
  assert_eq(ray.distance_sq_to_segment(parallel0, parallel1), 1.0)
  assert_eq(v0.y, -1.0)
  assert_eq(v1.x, 2.0)
  assert_eq(ray.origin.x, 0.0)
  assert_eq(ray.direction.x, 1.0)
}

///|
test "Ray.intersectSphere returns the first hit in front of the ray" {
  let ray = @math.Ray::new(
    origin=@math.Vector3::new(x=-2.0),
    direction=@math.Vector3::new(x=1.0),
  )
  let sphere = @math.Sphere::new(radius=1.0)
  let target = @math.Vector3::new(x=9.0)
  match ray.intersect_sphere(sphere, target) {
    None => assert_eq(true, false)
    Some(hit) => {
      assert_eq(physical_equal(hit, target), true)
      assert_eq(hit.x, -1.0)
      assert_eq(hit.y, 0.0)
      assert_eq(hit.z, 0.0)
    }
  }
  let miss = @math.Ray::new(
    origin=@math.Vector3::new(y=3.0),
    direction=@math.Vector3::new(x=1.0),
  )
  match miss.intersect_sphere(sphere, target) {
    None => assert_eq(target.x, -1.0)
    Some(_) => assert_eq(true, false)
  }
  let inside = @math.Ray::new()
  match inside.intersect_sphere(sphere, target) {
    None => assert_eq(true, false)
    Some(hit) => {
      assert_eq(hit.x, 0.0)
      assert_eq(hit.y, 0.0)
      assert_eq(hit.z, -1.0)
    }
  }
  match ray.intersect_sphere(@math.Sphere::new(), target) {
    None => assert_eq(sphere.radius, 1.0)
    Some(_) => assert_eq(true, false)
  }
  assert_eq(ray.origin.x, -2.0)
  assert_eq(ray.direction.x, 1.0)
}

///|
test "Ray.intersectsSphere counts a sphere in front of the ray" {
  let ray = @math.Ray::new(
    origin=@math.Vector3::new(x=-2.0),
    direction=@math.Vector3::new(x=1.0),
  )
  let sphere = @math.Sphere::new(radius=1.0)
  let miss = @math.Ray::new(
    origin=@math.Vector3::new(y=3.0),
    direction=@math.Vector3::new(x=1.0),
  )
  let behind = @math.Ray::new(
    origin=@math.Vector3::new(x=2.0),
    direction=@math.Vector3::new(x=1.0),
  )
  assert_eq(ray.intersects_sphere(sphere), true)
  assert_eq(miss.intersects_sphere(sphere), false)
  assert_eq(behind.intersects_sphere(sphere), false)
  assert_eq(@math.Ray::new().intersects_sphere(sphere), true)
  assert_eq(ray.intersects_sphere(@math.Sphere::new()), false)
  assert_eq(sphere.radius, 1.0)
  assert_eq(ray.origin.x, -2.0)
  assert_eq(ray.direction.x, 1.0)
}

///|
test "Ray.distanceToPlane is the distance to the first hit" {
  let ray = @math.Ray::new(
    origin=@math.Vector3::new(x=-2.0),
    direction=@math.Vector3::new(x=1.0),
  )
  let plane = @math.Plane::new()
  match ray.distance_to_plane(plane) {
    None => assert_eq(true, false)
    Some(t) => assert_eq(t, 2.0)
  }
  let away = @math.Ray::new(
    origin=@math.Vector3::new(x=1.0),
    direction=@math.Vector3::new(x=1.0),
  )
  match away.distance_to_plane(plane) {
    None => assert_eq(plane.constant, 0.0)
    Some(_) => assert_eq(true, false)
  }
  let parallel = @math.Ray::new(
    origin=@math.Vector3::new(x=1.0),
    direction=@math.Vector3::new(y=1.0),
  )
  match parallel.distance_to_plane(plane) {
    None => assert_eq(plane.normal.x, 1.0)
    Some(_) => assert_eq(true, false)
  }
  let on_plane = @math.Ray::new(direction=@math.Vector3::new(y=1.0))
  match on_plane.distance_to_plane(plane) {
    None => assert_eq(true, false)
    Some(t) => assert_eq(t, 0.0)
  }
  assert_eq(ray.origin.x, -2.0)
  assert_eq(ray.direction.x, 1.0)
  assert_eq(plane.constant, 0.0)
}

///|
test "Ray.intersectPlane writes the hit on the plane" {
  let ray = @math.Ray::new(
    origin=@math.Vector3::new(x=-2.0),
    direction=@math.Vector3::new(x=1.0),
  )
  let plane = @math.Plane::new()
  let target = @math.Vector3::new(x=9.0)
  match ray.intersect_plane(plane, target) {
    None => assert_eq(true, false)
    Some(hit) => {
      assert_eq(physical_equal(hit, target), true)
      assert_eq(hit.x, 0.0)
      assert_eq(hit.y, 0.0)
      assert_eq(hit.z, 0.0)
    }
  }
  let away = @math.Ray::new(
    origin=@math.Vector3::new(x=1.0),
    direction=@math.Vector3::new(x=1.0),
  )
  match away.intersect_plane(plane, target) {
    None => assert_eq(target.x, 0.0)
    Some(_) => assert_eq(true, false)
  }
  assert_eq(ray.origin.x, -2.0)
  assert_eq(ray.direction.x, 1.0)
  assert_eq(plane.constant, 0.0)
}

///|
test "Ray.intersectsPlane is true when the ray heads toward the plane" {
  let ray = @math.Ray::new(
    origin=@math.Vector3::new(x=-2.0),
    direction=@math.Vector3::new(x=1.0),
  )
  let plane = @math.Plane::new()
  let away = @math.Ray::new(
    origin=@math.Vector3::new(x=1.0),
    direction=@math.Vector3::new(x=1.0),
  )
  let parallel = @math.Ray::new(
    origin=@math.Vector3::new(x=1.0),
    direction=@math.Vector3::new(y=1.0),
  )
  let on_plane = @math.Ray::new(direction=@math.Vector3::new(y=1.0))
  assert_eq(ray.intersects_plane(plane), true)
  assert_eq(away.intersects_plane(plane), false)
  assert_eq(parallel.intersects_plane(plane), false)
  assert_eq(on_plane.intersects_plane(plane), true)
  assert_eq(ray.origin.x, -2.0)
  assert_eq(plane.constant, 0.0)
}

///|
test "Ray.intersectBox writes the first hit on the box" {
  let box = @math.Box3::new(
    @math.Vector3::new(),
    @math.Vector3::new(x=1.0, y=1.0, z=1.0),
  )
  let ray = @math.Ray::new(
    origin=@math.Vector3::new(x=-1.0, y=0.5, z=0.5),
    direction=@math.Vector3::new(x=1.0),
  )
  let target = @math.Vector3::new(x=9.0)
  match ray.intersect_box(box, target) {
    None => assert_eq(true, false)
    Some(hit) => {
      assert_eq(physical_equal(hit, target), true)
      assert_eq(hit.x, 0.0)
      assert_eq(hit.y, 0.5)
      assert_eq(hit.z, 0.5)
    }
  }
  let miss = @math.Ray::new(
    origin=@math.Vector3::new(x=-1.0, y=2.0, z=0.5),
    direction=@math.Vector3::new(x=1.0),
  )
  match miss.intersect_box(box, target) {
    None => assert_eq(target.x, 0.0)
    Some(_) => assert_eq(true, false)
  }
  assert_eq(ray.origin.x, -1.0)
  assert_eq(ray.direction.x, 1.0)
  assert_eq(box.min.x, 0.0)
  assert_eq(box.max.x, 1.0)
}

///|
test "Ray.intersectsBox counts a box in front of the ray" {
  let box = @math.Box3::new(
    @math.Vector3::new(),
    @math.Vector3::new(x=1.0, y=1.0, z=1.0),
  )
  let ray = @math.Ray::new(
    origin=@math.Vector3::new(x=-1.0, y=0.5, z=0.5),
    direction=@math.Vector3::new(x=1.0),
  )
  let miss = @math.Ray::new(
    origin=@math.Vector3::new(x=-1.0, y=2.0, z=0.5),
    direction=@math.Vector3::new(x=1.0),
  )
  assert_eq(ray.intersects_box(box), true)
  assert_eq(miss.intersects_box(box), false)
  assert_eq(ray.origin.x, -1.0)
  assert_eq(ray.direction.x, 1.0)
  assert_eq(box.min.x, 0.0)
  assert_eq(box.max.z, 1.0)
}

///|
test "Ray.intersectTriangle hits the front of a triangle" {
  let ray = @math.Ray::new(
    origin=@math.Vector3::new(x=0.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  let a = @math.Vector3::new()
  let b = @math.Vector3::new(x=1.0)
  let c = @math.Vector3::new(y=1.0)
  let target = @math.Vector3::new(x=9.0)
  match ray.intersect_triangle(a, b, c, true, target) {
    None => assert_eq(true, false)
    Some(hit) => {
      assert_eq(physical_equal(hit, target), true)
      assert_eq(hit.x, 0.25)
      assert_eq(hit.y, 0.25)
      assert_eq(hit.z, 0.0)
    }
  }
  let miss = @math.Ray::new(
    origin=@math.Vector3::new(x=2.0, y=2.0, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  match miss.intersect_triangle(a, b, c, false, target) {
    None => assert_eq(target.x, 0.25)
    Some(_) => assert_eq(true, false)
  }
  let back = @math.Ray::new(
    origin=@math.Vector3::new(x=0.25, y=0.25, z=-1.0),
    direction=@math.Vector3::new(z=1.0),
  )
  match back.intersect_triangle(a, b, c, true, target) {
    None => assert_eq(target.y, 0.25)
    Some(_) => assert_eq(true, false)
  }
  match back.intersect_triangle(a, b, c, false, target) {
    None => assert_eq(true, false)
    Some(hit) => {
      assert_eq(hit.x, 0.25)
      assert_eq(hit.y, 0.25)
      assert_eq(hit.z, 0.0)
    }
  }
  assert_eq(a.x, 0.0)
  assert_eq(b.x, 1.0)
  assert_eq(c.y, 1.0)
  assert_eq(ray.origin.z, 1.0)
  assert_eq(ray.direction.z, -1.0)
}

///|
test "Ray.applyMatrix4 moves the origin and keeps a translated direction" {
  let ray = @math.Ray::new()
  let matrix = @math.Matrix4::new().make_translation(1.0, 2.0, 3.0)
  ignore(ray.apply_matrix4(matrix))
  assert_eq(ray.origin.x, 1.0)
  assert_eq(ray.origin.y, 2.0)
  assert_eq(ray.origin.z, 3.0)
  assert_eq(ray.direction.x, 0.0)
  assert_eq(ray.direction.y, 0.0)
  assert_eq(ray.direction.z, -1.0)
  assert_eq(matrix.elements[12], 1.0)
}

///|
test "Ray.equals matches the origin and the direction" {
  let ray = @math.Ray::new(
    origin=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    direction=@math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  let same = @math.Ray::new(
    origin=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    direction=@math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  let other_origin = @math.Ray::new(
    origin=@math.Vector3::new(x=0.0, y=2.0, z=3.0),
    direction=@math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  let other_direction = @math.Ray::new(
    origin=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    direction=@math.Vector3::new(x=4.0, y=5.0),
  )
  assert_eq(ray.equals(same), true)
  assert_eq(ray.equals(ray), true)
  assert_eq(ray.equals(other_origin), false)
  assert_eq(ray.equals(other_direction), false)
  assert_eq(ray.origin.x, 1.0)
  assert_eq(ray.direction.z, 6.0)
  assert_eq(same.direction.y, 5.0)
}

///|
test "Ray.clone copies the origin and the direction" {
  let source = @math.Ray::new(
    origin=@math.Vector3::new(x=1.0, y=2.0, z=3.0),
    direction=@math.Vector3::new(x=4.0, y=5.0, z=6.0),
  )
  let ray = source.clone()
  assert_eq(ray.origin.x, 1.0)
  assert_eq(ray.origin.y, 2.0)
  assert_eq(ray.origin.z, 3.0)
  assert_eq(ray.direction.x, 4.0)
  assert_eq(ray.direction.y, 5.0)
  assert_eq(ray.direction.z, 6.0)
  source.origin.x = 0.0
  ray.direction.z = 0.0
  assert_eq(ray.origin.x, 1.0)
  assert_eq(source.direction.z, 6.0)
}

///|
test "Color.set stores three linear channels" {
  let color = @math.Color::new()
  ignore(color.set(0.25, 0.5, 0.75))
  assert_eq(color.r, 0.25)
  assert_eq(color.g, 0.5)
  assert_eq(color.b, 0.75)
}

///|
test "Color.setScalar writes the same value into every channel" {
  let color = @math.Color::new()
  ignore(color.set_scalar(0.25))
  assert_eq(color.r, 0.25)
  assert_eq(color.g, 0.25)
  assert_eq(color.b, 0.25)
}

///|
test "MathUtils.clamp limits a number to a closed range" {
  assert_eq(@math.clamp(1.5, 0.0, 1.0), 1.0)
  assert_eq(@math.clamp(-0.5, 0.0, 1.0), 0.0)
  assert_eq(@math.clamp(0.25, 0.0, 1.0), 0.25)
}

///|
test "MathUtils.euclideanModulo wraps a negative remainder" {
  assert_eq(@math.euclidean_modulo(1.25, 1.0), 0.25)
  assert_eq(@math.euclidean_modulo(-0.25, 1.0), 0.75)
  assert_eq(@math.euclidean_modulo(0.25, 1.0), 0.25)
  assert_eq(@math.euclidean_modulo(2.0, 1.0), 0.0)
}

///|
test "Color.setHSL writes linear channels from hue saturation and lightness" {
  let red = @math.Color::new()
  ignore(red.set_hsl(0.0, 1.0, 0.5))
  assert_eq(red.r, 1.0)
  assert_eq(red.g, 0.0)
  assert_eq(red.b, 0.0)
  let gray = @math.Color::new()
  ignore(gray.set_hsl(0.2, 0.0, 0.25))
  assert_eq(gray.r, 0.25)
  assert_eq(gray.g, 0.25)
  assert_eq(gray.b, 0.25)
  let wrapped = @math.Color::new()
  ignore(wrapped.set_hsl(1.0, 1.0, 0.5))
  assert_eq(wrapped.r, 1.0)
  assert_eq(wrapped.g, 0.0)
  assert_eq(wrapped.b, 0.0)
}

///|
test "Color.copySRGBToLinear converts copied channels" {
  let source = @math.Color::new(r=0.0, g=0.5, b=1.0)
  let color = @math.Color::new()
  ignore(color.copy_srgb_to_linear(source))
  assert_eq(color.r, 0.0)
  assert_close(color.g, 0.2140411404715882)
  assert_eq(color.b, 1.0)
  assert_eq(source.r, 0.0)
  assert_eq(source.g, 0.5)
  assert_eq(source.b, 1.0)
}

///|
test "Color.copyLinearToSRGB converts copied channels" {
  let source = @math.Color::new(r=0.0, g=0.5, b=1.0)
  let color = @math.Color::new()
  ignore(color.copy_linear_to_srgb(source))
  assert_eq(color.r, 0.0)
  assert_close(color.g, 0.7353606352856507)
  assert_close(color.b, 0.9999999999999999)
  assert_eq(source.r, 0.0)
  assert_eq(source.g, 0.5)
  assert_eq(source.b, 1.0)
}

///|
test "Color.convertSRGBToLinear converts its own channels" {
  let color = @math.Color::new(r=0.0, g=0.5, b=1.0)
  ignore(color.convert_srgb_to_linear())
  assert_eq(color.r, 0.0)
  assert_close(color.g, 0.2140411404715882)
  assert_eq(color.b, 1.0)
}

///|
test "Color.convertLinearToSRGB converts its own channels" {
  let color = @math.Color::new(r=0.0, g=0.5, b=1.0)
  ignore(color.convert_linear_to_srgb())
  assert_eq(color.r, 0.0)
  assert_close(color.g, 0.7353606352856507)
  assert_close(color.b, 0.9999999999999999)
}

///|
test "Color.getHexString writes six lowercase digits" {
  let black = @math.Color::new(r=0.0, g=0.0, b=0.0)
  assert_eq(black.get_hex_string(), "000000")
  let green = @math.Color::new().set_hex(0x00FF00)
  assert_eq(green.get_hex_string(), "00ff00")
}

///|
test "Color.getHSL reads hue saturation and lightness" {
  let red = @math.Color::new(r=1.0, g=0.0, b=0.0)
  let (hue, saturation, lightness) = red.get_hsl()
  assert_eq(hue, 0.0)
  assert_eq(saturation, 1.0)
  assert_eq(lightness, 0.5)
  assert_eq(red.r, 1.0)
  let gray = @math.Color::new(r=0.25, g=0.25, b=0.25)
  let (gray_h, gray_s, gray_l) = gray.get_hsl()
  assert_eq(gray_h, 0.0)
  assert_eq(gray_s, 0.0)
  assert_eq(gray_l, 0.25)
}

///|
test "Color.getRGB writes the linear channels into a target" {
  let color = @math.Color::new(r=0.25, g=0.5, b=0.75)
  let target = @math.Color::new()
  ignore(color.get_rgb(target))
  assert_eq(target.r, 0.25)
  assert_eq(target.g, 0.5)
  assert_eq(target.b, 0.75)
  assert_eq(color.r, 0.25)
  assert_eq(color.g, 0.5)
  assert_eq(color.b, 0.75)
}

///|
test "Color.getStyle writes an sRGB rgb string" {
  let red = @math.Color::new(r=1.0, g=0.0, b=0.0)
  assert_eq(red.get_style(), "rgb(255,0,0)")
  let black = @math.Color::new(r=0.0, g=0.0, b=0.0)
  assert_eq(black.get_style(), "rgb(0,0,0)")
  assert_eq(red.r, 1.0)
}

///|
test "Color.offsetHSL adds to hue saturation and lightness" {
  let red = @math.Color::new(r=1.0, g=0.0, b=0.0)
  ignore(red.offset_hsl(0.0, 0.0, 0.0))
  assert_eq(red.r, 1.0)
  assert_eq(red.g, 0.0)
  assert_eq(red.b, 0.0)
  let gray = @math.Color::new(r=0.25, g=0.25, b=0.25)
  ignore(gray.offset_hsl(0.0, 0.0, 0.25))
  assert_eq(gray.r, 0.5)
  assert_eq(gray.g, 0.5)
  assert_eq(gray.b, 0.5)
}

///|
test "Color.add adds another color's channels" {
  let color = @math.Color::new(r=0.25, g=0.5, b=0.75)
  let other = @math.Color::new(r=0.25, g=0.5, b=0.25)
  ignore(color.add(other))
  assert_eq(color.r, 0.5)
  assert_eq(color.g, 1.0)
  assert_eq(color.b, 1.0)
  assert_eq(other.r, 0.25)
  assert_eq(other.g, 0.5)
  assert_eq(other.b, 0.25)
}

///|
test "Color.addColors stores the sum of two colors" {
  let color = @math.Color::new()
  let first = @math.Color::new(r=0.25, g=0.5, b=0.75)
  let second = @math.Color::new(r=0.25, g=0.5, b=0.25)
  ignore(color.add_colors(first, second))
  assert_eq(color.r, 0.5)
  assert_eq(color.g, 1.0)
  assert_eq(color.b, 1.0)
  assert_eq(first.r, 0.25)
  assert_eq(second.b, 0.25)
}

///|
test "Color.addScalar adds one value to every channel" {
  let color = @math.Color::new(r=0.25, g=0.5, b=0.75)
  ignore(color.add_scalar(0.25))
  assert_eq(color.r, 0.5)
  assert_eq(color.g, 0.75)
  assert_eq(color.b, 1.0)
}

///|
test "Color.sub subtracts another color and stays at zero" {
  let color = @math.Color::new(r=0.5, g=1.0, b=0.75)
  let other = @math.Color::new(r=0.25, g=0.25, b=0.25)
  ignore(color.sub(other))
  assert_eq(color.r, 0.25)
  assert_eq(color.g, 0.75)
  assert_eq(color.b, 0.5)
  assert_eq(other.r, 0.25)
  let clamped = @math.Color::new(r=0.25, g=0.5, b=0.75)
  ignore(clamped.sub(@math.Color::new(r=0.5, g=0.0, b=0.0)))
  assert_eq(clamped.r, 0.0)
  assert_eq(clamped.g, 0.5)
  assert_eq(clamped.b, 0.75)
}

///|
test "Color.multiply multiplies channels" {
  let color = @math.Color::new(r=0.5, g=0.25, b=1.0)
  let other = @math.Color::new(r=0.5, g=0.5, b=0.25)
  ignore(color.multiply(other))
  assert_eq(color.r, 0.25)
  assert_eq(color.g, 0.125)
  assert_eq(color.b, 0.25)
  assert_eq(other.r, 0.5)
  assert_eq(other.g, 0.5)
  assert_eq(other.b, 0.25)
}

///|
test "Color.multiplyScalar scales every channel" {
  let color = @math.Color::new(r=0.5, g=0.25, b=1.0)
  ignore(color.multiply_scalar(0.5))
  assert_eq(color.r, 0.25)
  assert_eq(color.g, 0.125)
  assert_eq(color.b, 0.5)
}

///|
test "Color.lerpColors stores the blend of two colors" {
  let color = @math.Color::new()
  let first = @math.Color::new(r=0.0, g=0.0, b=0.0)
  let second = @math.Color::new(r=1.0, g=0.5, b=0.0)
  ignore(color.lerp_colors(first, second, 0.25))
  assert_eq(color.r, 0.25)
  assert_eq(color.g, 0.125)
  assert_eq(color.b, 0.0)
  ignore(color.lerp_colors(first, second, 0.0))
  assert_eq(color.r, 0.0)
  assert_eq(color.g, 0.0)
  assert_eq(color.b, 0.0)
  ignore(color.lerp_colors(first, second, 1.0))
  assert_eq(color.r, 1.0)
  assert_eq(color.g, 0.5)
  assert_eq(color.b, 0.0)
  assert_eq(first.r, 0.0)
  assert_eq(second.g, 0.5)
}

///|
test "MathUtils.lerp blends two numbers" {
  assert_eq(@math.lerp(0.0, 1.0, 0.25), 0.25)
  assert_eq(@math.lerp(1.0, 5.0, 0.0), 1.0)
  assert_eq(@math.lerp(1.0, 5.0, 1.0), 5.0)
}

///|
test "Color.lerpHSL blends lightness of two grays" {
  let color = @math.Color::new(r=0.25, g=0.25, b=0.25)
  let other = @math.Color::new(r=0.75, g=0.75, b=0.75)
  ignore(color.lerp_hsl(other, 0.5))
  assert_eq(color.r, 0.5)
  assert_eq(color.g, 0.5)
  assert_eq(color.b, 0.5)
  assert_eq(other.r, 0.75)
  let stayed = @math.Color::new(r=0.25, g=0.25, b=0.25)
  ignore(stayed.lerp_hsl(other, 0.0))
  assert_eq(stayed.r, 0.25)
  assert_eq(stayed.g, 0.25)
  assert_eq(stayed.b, 0.25)
}

///|
test "Color.setFromVector3 copies the vector components" {
  let color = @math.Color::new()
  let v = @math.Vector3::new(x=0.25, y=0.5, z=0.75)
  ignore(color.set_from_vector3(v))
  assert_eq(color.r, 0.25)
  assert_eq(color.g, 0.5)
  assert_eq(color.b, 0.75)
  assert_eq(v.x, 0.25)
  assert_eq(v.y, 0.5)
  assert_eq(v.z, 0.75)
}

///|
test "Color.applyMatrix3 transforms the channels" {
  let color = @math.Color::new(r=0.25, g=0.5, b=0.75)
  let swap = @math.Matrix3::new().set(0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
  ignore(color.apply_matrix3(swap))
  assert_eq(color.r, 0.5)
  assert_eq(color.g, 0.25)
  assert_eq(color.b, 0.75)
  assert_eq(swap.elements[0], 0.0)
  assert_eq(swap.elements[3], 1.0)
}

///|
test "Color.equals compares the three channels" {
  let color = @math.Color::new(r=0.25, g=0.5, b=0.75)
  let same = @math.Color::new(r=0.25, g=0.5, b=0.75)
  assert_eq(color.equals(same), true)
  assert_eq(color.equals(color), true)
  assert_eq(color.equals(@math.Color::new(r=0.0, g=0.5, b=0.75)), false)
  assert_eq(color.equals(@math.Color::new(r=0.25, g=0.0, b=0.75)), false)
  assert_eq(color.equals(@math.Color::new(r=0.25, g=0.5, b=0.0)), false)
  assert_eq(color.r, 0.25)
  assert_eq(same.b, 0.75)
}

///|
test "Color.fromArray reads three channels at an offset" {
  let array = [1.0, 2.0, 3.0, 0.25, 0.5, 0.75]
  let color = @math.Color::new()
  ignore(color.from_array(array))
  assert_eq(color.r, 1.0)
  assert_eq(color.g, 2.0)
  assert_eq(color.b, 3.0)
  ignore(color.from_array(array, offset=3))
  assert_eq(color.r, 0.25)
  assert_eq(color.g, 0.5)
  assert_eq(color.b, 0.75)
  assert_eq(array[0], 1.0)
  assert_eq(array[5], 0.75)
}

///|
test "Color.toArray writes three channels at an offset" {
  let color = @math.Color::new(r=0.25, g=0.5, b=0.75)
  let fresh = color.to_array()
  assert_eq(fresh.length(), 3)
  assert_eq(fresh[0], 0.25)
  assert_eq(fresh[1], 0.5)
  assert_eq(fresh[2], 0.75)
  let values = [9.0, 8.0, 7.0, 6.0]
  let written = color.to_array(array=values, offset=1)
  assert_eq(physical_equal(written, values), true)
  assert_eq(values[0], 9.0)
  assert_eq(values[1], 0.25)
  assert_eq(values[2], 0.5)
  assert_eq(values[3], 0.75)
  let short = [4.0]
  ignore(color.to_array(array=short, offset=2))
  assert_eq(short.length(), 5)
  assert_eq(short[0], 4.0)
  assert_eq(short[1], 0.0)
  assert_eq(short[2], 0.25)
  assert_eq(short[3], 0.5)
  assert_eq(short[4], 0.75)
  assert_eq(color.r, 0.25)
  assert_eq(color.g, 0.5)
  assert_eq(color.b, 0.75)
}

///|
test "Color.toJSON returns the sRGB hexadecimal integer" {
  let black = @math.Color::new(r=0.0, g=0.0, b=0.0)
  assert_eq(black.to_json(), 0)
  let green = @math.Color::new().set_hex(0x00FF00)
  assert_eq(green.to_json(), 65280)
  let red = @math.Color::new(r=1.0, g=0.0, b=0.0)
  assert_eq(red.to_json(), 16711680)
  assert_eq(red.r, 1.0)
}

///|
test "Euler.clone copies the angles and the order" {
  let euler = @math.Euler::new(x=1.0, y=2.0, z=3.0, order=@math.EulerOrder::ZYX)
  let cloned = euler.clone()
  assert_eq(cloned.x, 1.0)
  assert_eq(cloned.y, 2.0)
  assert_eq(cloned.z, 3.0)
  match cloned.order {
    @math.EulerOrder::ZYX => assert_eq(cloned.x, 1.0)
    _ => assert_eq(true, false)
  }
  euler.x = 0.0
  cloned.order = @math.EulerOrder::XYZ
  assert_eq(cloned.x, 1.0)
  match euler.order {
    @math.EulerOrder::ZYX => assert_eq(euler.x, 0.0)
    _ => assert_eq(true, false)
  }
}

///|
test "Euler.setFromVector3 copies the vector components" {
  let euler = @math.Euler::new()
  let v = @math.Vector3::new(x=1.0, y=2.0, z=3.0)
  ignore(euler.set_from_vector3(v))
  assert_eq(euler.x, 1.0)
  assert_eq(euler.y, 2.0)
  assert_eq(euler.z, 3.0)
  match euler.order {
    @math.EulerOrder::XYZ => assert_eq(euler.x, 1.0)
    _ => assert_eq(true, false)
  }
  ignore(euler.set_from_vector3(v, order=@math.EulerOrder::ZYX))
  assert_eq(euler.x, 1.0)
  assert_eq(euler.y, 2.0)
  assert_eq(euler.z, 3.0)
  match euler.order {
    @math.EulerOrder::ZYX => assert_eq(v.x, 1.0)
    _ => assert_eq(true, false)
  }
  assert_eq(v.y, 2.0)
  assert_eq(v.z, 3.0)
}

///|
test "Euler.equals compares the angles and the order" {
  let euler = @math.Euler::new(x=1.0, y=2.0, z=3.0, order=@math.EulerOrder::ZYX)
  let same = @math.Euler::new(x=1.0, y=2.0, z=3.0, order=@math.EulerOrder::ZYX)
  assert_eq(euler.equals(same), true)
  assert_eq(euler.equals(euler), true)
  assert_eq(
    euler.equals(@math.Euler::new(x=0.0, y=2.0, z=3.0, order=@math.EulerOrder::ZYX)),
    false,
  )
  assert_eq(
    euler.equals(@math.Euler::new(x=1.0, y=2.0, z=3.0, order=@math.EulerOrder::XYZ)),
    false,
  )
  assert_eq(euler.x, 1.0)
  assert_eq(same.z, 3.0)
}

///|
test "Euler.fromArray reads three angles and an optional order" {
  let array = [1.0, 2.0, 3.0]
  let euler = @math.Euler::new(x=9.0, y=8.0, z=7.0, order=@math.EulerOrder::YXZ)
  ignore(euler.from_array(array))
  assert_eq(euler.x, 1.0)
  assert_eq(euler.y, 2.0)
  assert_eq(euler.z, 3.0)
  match euler.order {
    @math.EulerOrder::YXZ => assert_eq(euler.x, 1.0)
    _ => assert_eq(true, false)
  }
  ignore(euler.from_array(array, order=@math.EulerOrder::ZYX))
  assert_eq(euler.x, 1.0)
  assert_eq(euler.y, 2.0)
  assert_eq(euler.z, 3.0)
  match euler.order {
    @math.EulerOrder::ZYX => assert_eq(array[0], 1.0)
    _ => assert_eq(true, false)
  }
  assert_eq(array[2], 3.0)
}

///|
test "Euler.toArray writes three angles and returns the order" {
  let euler = @math.Euler::new(x=1.0, y=2.0, z=3.0, order=@math.EulerOrder::ZYX)
  let (fresh, fresh_order) = euler.to_array()
  assert_eq(fresh.length(), 3)
  assert_eq(fresh[0], 1.0)
  assert_eq(fresh[1], 2.0)
  assert_eq(fresh[2], 3.0)
  match fresh_order {
    @math.EulerOrder::ZYX => assert_eq(fresh[0], 1.0)
    _ => assert_eq(true, false)
  }
  let values = [9.0, 8.0, 7.0, 6.0]
  let (written, written_order) = euler.to_array(array=values, offset=1)
  assert_eq(physical_equal(written, values), true)
  assert_eq(values[0], 9.0)
  assert_eq(values[1], 1.0)
  assert_eq(values[2], 2.0)
  assert_eq(values[3], 3.0)
  match written_order {
    @math.EulerOrder::ZYX => assert_eq(values[1], 1.0)
    _ => assert_eq(true, false)
  }
  let short = [4.0]
  let (grown, _) = euler.to_array(array=short, offset=2)
  assert_eq(grown.length(), 5)
  assert_eq(short[0], 4.0)
  assert_eq(short[1], 0.0)
  assert_eq(short[2], 1.0)
  assert_eq(short[3], 2.0)
  assert_eq(short[4], 3.0)
  assert_eq(euler.x, 1.0)
  assert_eq(euler.y, 2.0)
  assert_eq(euler.z, 3.0)
}

///|
test "Frustum.set copies six planes" {
  let frustum = @math.Frustum::new()
  let p0 = @math.Plane::new(constant=1.0)
  let p1 = @math.Plane::new(normal=@math.Vector3::new(y=1.0), constant=2.0)
  let p2 = @math.Plane::new(constant=3.0)
  let p3 = @math.Plane::new(constant=4.0)
  let p4 = @math.Plane::new(constant=5.0)
  let p5 = @math.Plane::new(constant=6.0)
  ignore(frustum.set(p0, p1, p2, p3, p4, p5))
  assert_eq(frustum.planes[0].constant, 1.0)
  assert_eq(frustum.planes[1].constant, 2.0)
  assert_eq(frustum.planes[1].normal.y, 1.0)
  assert_eq(frustum.planes[5].constant, 6.0)
  p0.constant = 0.0
  p1.normal.y = 0.0
  assert_eq(frustum.planes[0].constant, 1.0)
  assert_eq(frustum.planes[1].normal.y, 1.0)
}

///|
test "Frustum.copy copies six planes" {
  let source = @math.Frustum::new()
  ignore(
    source.set(
      @math.Plane::new(constant=1.0),
      @math.Plane::new(normal=@math.Vector3::new(y=1.0), constant=2.0),
      @math.Plane::new(constant=3.0),
      @math.Plane::new(constant=4.0),
      @math.Plane::new(constant=5.0),
      @math.Plane::new(constant=6.0),
    ),
  )
  let frustum = @math.Frustum::new()
  ignore(frustum.copy(source))
  assert_eq(frustum.planes[0].constant, 1.0)
  assert_eq(frustum.planes[1].normal.y, 1.0)
  assert_eq(frustum.planes[5].constant, 6.0)
  source.planes[0].constant = 0.0
  source.planes[1].normal.y = 0.0
  assert_eq(frustum.planes[0].constant, 1.0)
  assert_eq(frustum.planes[1].normal.y, 1.0)
}

///|
test "Frustum.intersectsBox accepts a box inside the unit cube" {
  let frustum = @math.Frustum::new()
  ignore(
    frustum.set(
      @math.Plane::new(normal=@math.Vector3::new(x=1.0), constant=0.0),
      @math.Plane::new(normal=@math.Vector3::new(x=-1.0), constant=1.0),
      @math.Plane::new(normal=@math.Vector3::new(y=1.0), constant=0.0),
      @math.Plane::new(normal=@math.Vector3::new(y=-1.0), constant=1.0),
      @math.Plane::new(normal=@math.Vector3::new(z=1.0), constant=0.0),
      @math.Plane::new(normal=@math.Vector3::new(z=-1.0), constant=1.0),
    ),
  )
  let inside = @math.Box3::new(
    @math.Vector3::new(x=0.25, y=0.25, z=0.25),
    @math.Vector3::new(x=0.75, y=0.75, z=0.75),
  )
  assert_eq(frustum.intersects_box(inside), true)
  let outside = @math.Box3::new(
    @math.Vector3::new(x=-2.0, y=-2.0, z=-2.0),
    @math.Vector3::new(x=-1.0, y=-1.0, z=-1.0),
  )
  assert_eq(frustum.intersects_box(outside), false)
  assert_eq(outside.min.x, -2.0)
  assert_eq(frustum.planes[0].constant, 0.0)
}

///|
test "Frustum.containsPoint accepts a point inside the unit cube" {
  let frustum = @math.Frustum::new()
  ignore(
    frustum.set(
      @math.Plane::new(normal=@math.Vector3::new(x=1.0), constant=0.0),
      @math.Plane::new(normal=@math.Vector3::new(x=-1.0), constant=1.0),
      @math.Plane::new(normal=@math.Vector3::new(y=1.0), constant=0.0),
      @math.Plane::new(normal=@math.Vector3::new(y=-1.0), constant=1.0),
      @math.Plane::new(normal=@math.Vector3::new(z=1.0), constant=0.0),
      @math.Plane::new(normal=@math.Vector3::new(z=-1.0), constant=1.0),
    ),
  )
  let inside = @math.Vector3::new(x=0.5, y=0.5, z=0.5)
  assert_eq(frustum.contains_point(inside), true)
  let face = @math.Vector3::new(x=0.0, y=0.5, z=0.5)
  assert_eq(frustum.contains_point(face), true)
  let outside = @math.Vector3::new(x=-1.0, y=0.5, z=0.5)
  assert_eq(frustum.contains_point(outside), false)
  assert_eq(outside.x, -1.0)
  assert_eq(frustum.planes[1].constant, 1.0)
}

///|
test "Frustum.clone copies six planes into a new frustum" {
  let source = @math.Frustum::new()
  ignore(
    source.set(
      @math.Plane::new(constant=1.0),
      @math.Plane::new(normal=@math.Vector3::new(y=1.0), constant=2.0),
      @math.Plane::new(constant=3.0),
      @math.Plane::new(constant=4.0),
      @math.Plane::new(constant=5.0),
      @math.Plane::new(constant=6.0),
    ),
  )
  let cloned = source.clone()
  assert_eq(cloned.planes[0].constant, 1.0)
  assert_eq(cloned.planes[1].normal.y, 1.0)
  assert_eq(cloned.planes[5].constant, 6.0)
  source.planes[0].constant = 0.0
  source.planes[1].normal.y = 0.0
  cloned.planes[5].constant = 9.0
  assert_eq(cloned.planes[0].constant, 1.0)
  assert_eq(cloned.planes[1].normal.y, 1.0)
  assert_eq(source.planes[5].constant, 6.0)
}

///|
test "Matrix3.extractBasis writes the three columns" {
  let matrix = @math.Matrix3::new().set(
    1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0,
  )
  let x_axis = @math.Vector3::new(x=9.0)
  let y_axis = @math.Vector3::new(y=8.0)
  let z_axis = @math.Vector3::new(z=7.0)
  ignore(matrix.extract_basis(x_axis, y_axis, z_axis))
  assert_eq(x_axis.x, 1.0)
  assert_eq(x_axis.y, 4.0)
  assert_eq(x_axis.z, 7.0)
  assert_eq(y_axis.x, 2.0)
  assert_eq(y_axis.y, 5.0)
  assert_eq(y_axis.z, 8.0)
  assert_eq(z_axis.x, 3.0)
  assert_eq(z_axis.y, 6.0)
  assert_eq(z_axis.z, 9.0)
  assert_eq(matrix.elements[0], 1.0)
  x_axis.x = 0.0
  assert_eq(matrix.elements[0], 1.0)
}

///|
test "Matrix3.multiplyMatrices stores the product" {
  let a = @math.Matrix3::new().set(2.0, 0.0, 0.0, 0.0, 3.0, 0.0, 0.0, 0.0, 4.0)
  let b = @math.Matrix3::new().set(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0)
  let m = @math.Matrix3::new()
  ignore(m.multiply_matrices(a, b))
  assert_eq(m.elements[0], 2.0)
  assert_eq(m.elements[1], 12.0)
  assert_eq(m.elements[2], 28.0)
  assert_eq(m.elements[3], 4.0)
  assert_eq(m.elements[4], 15.0)
  assert_eq(m.elements[5], 32.0)
  assert_eq(m.elements[6], 6.0)
  assert_eq(m.elements[7], 18.0)
  assert_eq(m.elements[8], 36.0)
  assert_eq(a.elements[0], 2.0)
  assert_eq(b.elements[0], 1.0)
}

///|
test "Matrix3.multiply post-multiplies in place" {
  let m = @math.Matrix3::new().set(2.0, 0.0, 0.0, 0.0, 3.0, 0.0, 0.0, 0.0, 4.0)
  let other = @math.Matrix3::new().set(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0)
  ignore(m.multiply(other))
  assert_eq(m.elements[0], 2.0)
  assert_eq(m.elements[1], 12.0)
  assert_eq(m.elements[2], 28.0)
  assert_eq(m.elements[3], 4.0)
  assert_eq(m.elements[4], 15.0)
  assert_eq(m.elements[5], 32.0)
  assert_eq(m.elements[6], 6.0)
  assert_eq(m.elements[7], 18.0)
  assert_eq(m.elements[8], 36.0)
  assert_eq(other.elements[0], 1.0)
}

///|
test "Matrix3.premultiply pre-multiplies in place" {
  let m = @math.Matrix3::new().set(2.0, 0.0, 0.0, 0.0, 3.0, 0.0, 0.0, 0.0, 4.0)
  let other = @math.Matrix3::new().set(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0)
  ignore(m.premultiply(other))
  assert_eq(m.elements[0], 2.0)
  assert_eq(m.elements[1], 8.0)
  assert_eq(m.elements[2], 14.0)
  assert_eq(m.elements[3], 6.0)
  assert_eq(m.elements[4], 15.0)
  assert_eq(m.elements[5], 24.0)
  assert_eq(m.elements[6], 12.0)
  assert_eq(m.elements[7], 24.0)
  assert_eq(m.elements[8], 36.0)
  assert_eq(other.elements[0], 1.0)
}

///|
test "Matrix3.multiplyScalar scales every element" {
  let m = @math.Matrix3::new().set(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0)
  ignore(m.multiply_scalar(2.0))
  assert_eq(m.elements[0], 2.0)
  assert_eq(m.elements[1], 8.0)
  assert_eq(m.elements[2], 14.0)
  assert_eq(m.elements[3], 4.0)
  assert_eq(m.elements[4], 10.0)
  assert_eq(m.elements[5], 16.0)
  assert_eq(m.elements[6], 6.0)
  assert_eq(m.elements[7], 12.0)
  assert_eq(m.elements[8], 18.0)
}

///|
test "Matrix3.transposeIntoArray writes the transpose" {
  let m = @math.Matrix3::new().set(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0)
  let array = []
  ignore(m.transpose_into_array(array))
  assert_eq(array.length(), 9)
  assert_eq(array[0], 1.0)
  assert_eq(array[1], 2.0)
  assert_eq(array[2], 3.0)
  assert_eq(array[3], 4.0)
  assert_eq(array[4], 5.0)
  assert_eq(array[5], 6.0)
  assert_eq(array[6], 7.0)
  assert_eq(array[7], 8.0)
  assert_eq(array[8], 9.0)
  assert_eq(m.elements[1], 4.0)
}

///|
test "Matrix3.setUvTransform stores offset repeat and center" {
  let m = @math.Matrix3::new()
  ignore(m.set_uv_transform(0.25, 0.5, 2.0, 3.0, 0.0, 1.0, 0.0))
  assert_eq(m.elements[0], 2.0)
  assert_eq(m.elements[1], 0.0)
  assert_eq(m.elements[2], 0.0)
  assert_eq(m.elements[3], 0.0)
  assert_eq(m.elements[4], 3.0)
  assert_eq(m.elements[5], 0.0)
  assert_eq(m.elements[6], -0.75)
  assert_eq(m.elements[7], 0.5)
  assert_eq(m.elements[8], 1.0)
}

///|
test "Matrix3.makeScale stores a 2D scale" {
  let m = @math.Matrix3::new()
  ignore(m.make_scale(2.0, 3.0))
  assert_eq(m.elements[0], 2.0)
  assert_eq(m.elements[1], 0.0)
  assert_eq(m.elements[2], 0.0)
  assert_eq(m.elements[3], 0.0)
  assert_eq(m.elements[4], 3.0)
  assert_eq(m.elements[5], 0.0)
  assert_eq(m.elements[6], 0.0)
  assert_eq(m.elements[7], 0.0)
  assert_eq(m.elements[8], 1.0)
}

///|
test "Matrix3.scale premultiplies a 2D scale" {
  let m = @math.Matrix3::new().set(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0)
  ignore(m.scale(2.0, 3.0))
  assert_eq(m.elements[0], 2.0)
  assert_eq(m.elements[1], 12.0)
  assert_eq(m.elements[2], 7.0)
  assert_eq(m.elements[3], 4.0)
  assert_eq(m.elements[4], 15.0)
  assert_eq(m.elements[5], 8.0)
  assert_eq(m.elements[6], 6.0)
  assert_eq(m.elements[7], 18.0)
  assert_eq(m.elements[8], 9.0)
}

///|
test "Matrix3.makeRotation stores a zero angle as identity" {
  let m = @math.Matrix3::new().set(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0)
  ignore(m.make_rotation(0.0))
  assert_eq(m.elements[0], 1.0)
  assert_eq(m.elements[1], 0.0)
  assert_eq(m.elements[2], 0.0)
  assert_eq(m.elements[3], 0.0)
  assert_eq(m.elements[4], 1.0)
  assert_eq(m.elements[5], 0.0)
  assert_eq(m.elements[6], 0.0)
  assert_eq(m.elements[7], 0.0)
  assert_eq(m.elements[8], 1.0)
}

///|
test "Matrix3.rotate by zero leaves the matrix" {
  let m = @math.Matrix3::new().set(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0)
  ignore(m.rotate(0.0))
  assert_eq(m.elements[0], 1.0)
  assert_eq(m.elements[1], 4.0)
  assert_eq(m.elements[2], 7.0)
  assert_eq(m.elements[3], 2.0)
  assert_eq(m.elements[4], 5.0)
  assert_eq(m.elements[5], 8.0)
  assert_eq(m.elements[6], 3.0)
  assert_eq(m.elements[7], 6.0)
  assert_eq(m.elements[8], 9.0)
}

///|
test "Matrix3.makeTranslation stores a 2D translation" {
  let m = @math.Matrix3::new()
  ignore(m.make_translation(0.25, 0.5))
  assert_eq(m.elements[0], 1.0)
  assert_eq(m.elements[1], 0.0)
  assert_eq(m.elements[2], 0.0)
  assert_eq(m.elements[3], 0.0)
  assert_eq(m.elements[4], 1.0)
  assert_eq(m.elements[5], 0.0)
  assert_eq(m.elements[6], 0.25)
  assert_eq(m.elements[7], 0.5)
  assert_eq(m.elements[8], 1.0)
}

///|
test "Matrix3.translate premultiplies a 2D translation" {
  let m = @math.Matrix3::new().set(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0)
  ignore(m.translate(0.25, 0.5))
  assert_eq(m.elements[0], 2.75)
  assert_eq(m.elements[1], 7.5)
  assert_eq(m.elements[2], 7.0)
  assert_eq(m.elements[3], 4.0)
  assert_eq(m.elements[4], 9.0)
  assert_eq(m.elements[5], 8.0)
  assert_eq(m.elements[6], 5.25)
  assert_eq(m.elements[7], 10.5)
  assert_eq(m.elements[8], 9.0)
}

///|
test "Matrix3.equals compares every element" {
  let m = @math.Matrix3::new().set(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0)
  let same = @math.Matrix3::new().set(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0)
  assert_eq(m.equals(same), true)
  same.elements[0] = 0.0
  assert_eq(m.equals(same), false)
}

///|
test "Vector4.toArray writes four components at an offset" {
  let v = @math.Vector4::new(x=1.0, y=2.0, z=3.0, w=4.0)
  let fresh = v.to_array()
  assert_eq(fresh.length(), 4)
  assert_eq(fresh[0], 1.0)
  assert_eq(fresh[1], 2.0)
  assert_eq(fresh[2], 3.0)
  assert_eq(fresh[3], 4.0)
  let array = [9.0, 8.0, 7.0, 6.0, 5.0]
  let written = v.to_array(array=array, offset=1)
  assert_eq(physical_equal(written, array), true)
  assert_eq(written[0], 9.0)
  assert_eq(written[1], 1.0)
  assert_eq(written[2], 2.0)
  assert_eq(written[3], 3.0)
  assert_eq(written[4], 4.0)
  let short = [9.0]
  let padded = v.to_array(array=short, offset=1)
  assert_eq(padded.length(), 5)
  assert_eq(padded[0], 9.0)
  assert_eq(padded[1], 1.0)
  assert_eq(padded[2], 2.0)
  assert_eq(padded[3], 3.0)
  assert_eq(padded[4], 4.0)
  assert_eq(v.x, 1.0)
  assert_eq(v.w, 4.0)
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
