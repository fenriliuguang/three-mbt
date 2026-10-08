///|
fn includes(text : String, part : String) -> Bool {
  text.contains(part)
}

///|
test "basic material ignores lights" {
  let wgsl = @nodes.basic_wgsl()
  assert_eq(
    includes(wgsl, "textureSample(map_texture, map_sampler, input.v_uv)"),
    true,
  )
  assert_eq(includes(wgsl, "uniforms.color"), true)
  assert_eq(includes(wgsl, "uniforms.mvp"), true)
  assert_eq(includes(wgsl, "@location(0) position : vec3<f32>"), true)
  assert_eq(includes(wgsl, "@location(1) normal : vec3<f32>"), true)
  assert_eq(includes(wgsl, "@location(2) uv : vec2<f32>"), true)
  assert_eq(includes(wgsl, "@group(1) @binding(0) var map_texture"), true)
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
  assert_eq(includes(wgsl, "@location(1) v_uv : vec2<f32>"), true)
  assert_eq(
    includes(wgsl, "textureSample(map_texture, map_sampler, input.v_uv)"),
    true,
  )
}

///|
test "standard material uses direct GGX and keeps ambient diffuse" {
  let wgsl = @nodes.standard_wgsl()
  assert_eq(includes(wgsl, "fn D_GGX("), true)
  assert_eq(includes(wgsl, "fn V_GGX_SmithCorrelated("), true)
  assert_eq(includes(wgsl, "fn F_Schlick("), true)
  assert_eq(includes(wgsl, "max((uniforms.surface).x, 0.0525)"), true)
  assert_eq(includes(wgsl, "mix(vec3<f32>(0.04), base.xyz, metalness)"), true)
  assert_eq(includes(wgsl, "exp2((-5.55473 * VoH - 6.98316) * VoH)"), true)
  assert_eq(includes(wgsl, "uniforms.model"), true)
  assert_eq(includes(wgsl, "uniforms.camera_position"), true)
  assert_eq(includes(wgsl, "@location(2) v_world : vec3<f32>"), true)
  assert_eq(includes(wgsl, "(uniforms.ambient).xyz * diffuse"), true)
  assert_eq(
    includes(wgsl, "textureSample(map_texture, map_sampler, input.v_uv)"),
    true,
  )
}

///|
test "lines return the uniform color and points scale like r186" {
  let line = @nodes.line_wgsl()
  assert_eq(includes(line, "return uniforms.color;"), true)
  assert_eq(includes(line, "@location(0) position : vec3<f32>"), true)
  assert_eq(includes(line, "map_texture"), false)
  let points = @nodes.points_wgsl()
  assert_eq(
    includes(
      points, "select((uniforms.point).x, (uniforms.point).x * (uniforms.viewport).y * 0.5 / depth, attenuate)",
    ),
    true,
  )
  assert_eq(includes(points, "let depth = max(-view.z, 0.000001);"), true)
  assert_eq(includes(points, "@location(0) corner : vec2<f32>"), true)
  assert_eq(includes(points, "@location(1) position : vec3<f32>"), true)
  assert_eq(includes(points, "uniforms.view"), true)
}
