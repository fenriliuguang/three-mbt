///|
fn includes(text : String, part : String) -> Bool {
  text.contains(part)
}

///|
test "basic material ignores lights" {
  let wgsl = @nodes.basic_wgsl()
  assert_eq(includes(wgsl, "return uniforms.color;"), true)
  assert_eq(includes(wgsl, "uniforms.mvp"), true)
  assert_eq(includes(wgsl, "@location(0) position : vec3<f32>"), true)
  assert_eq(includes(wgsl, "@location(1) normal : vec3<f32>"), true)
  assert_eq(includes(wgsl, "normalize("), false)
}

///|
test "lambert material uses ambient and one directional light" {
  let wgsl = @nodes.lambert_wgsl()
  assert_eq(
    includes(
      wgsl, "max(dot(normalize(input.v_normal), (uniforms.light_direction).xyz), 0.0)",
    ),
    true,
  )
  assert_eq(includes(wgsl, "(uniforms.ambient).xyz"), true)
  assert_eq(includes(wgsl, "(uniforms.light_color).xyz"), true)
  assert_eq(includes(wgsl, "uniforms.normal_matrix"), true)
  assert_eq(includes(wgsl, "@location(0) v_normal : vec3<f32>"), true)
}
