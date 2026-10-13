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
