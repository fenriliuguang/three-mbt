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
