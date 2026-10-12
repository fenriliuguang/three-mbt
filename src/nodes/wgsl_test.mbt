///|
fn includes(text : String, part : String) -> Bool {
  text.contains(part)
}

///|
test "basic material ignores lights" {
  let wgsl = @nodes.basic_wgsl()
  assert_eq(includes(wgsl, "sample_color(input.v_uv)"), true)
  assert_eq(includes(wgsl, "uniforms.color"), true)
  assert_eq(includes(wgsl, "uniforms.mvp"), true)
  assert_eq(includes(wgsl, "@location(0) position : vec3<f32>"), true)
  assert_eq(includes(wgsl, "@location(1) normal : vec3<f32>"), true)
  assert_eq(includes(wgsl, "@location(2) uv : vec2<f32>"), true)
  assert_eq(includes(wgsl, "@location(8) color : vec4<f32>"), true)
  assert_eq(includes(wgsl, "input.v_color"), true)
  assert_eq(includes(wgsl, "@group(1) @binding(0) var map_texture"), true)
  assert_eq(includes(wgsl, "normalize("), false)
}

///|
test "lambert material uses ambient and one directional light" {
  let wgsl = @nodes.lambert_wgsl()
  assert_eq(
    includes(
      wgsl, "max(dot(normalize(facing_normal(input.v_normal, front)), (uniforms.light_direction).xyz), 0.0)",
    ),
    true,
  )
  assert_eq(includes(wgsl, "(uniforms.ambient).xyz"), true)
  assert_eq(includes(wgsl, "(uniforms.light_color).xyz"), true)
  assert_eq(includes(wgsl, "uniforms.normal_matrix"), true)
  assert_eq(includes(wgsl, "@location(0) v_normal : vec3<f32>"), true)
  assert_eq(includes(wgsl, "@location(1) v_uv : vec2<f32>"), true)
  assert_eq(includes(wgsl, "sample_color(input.v_uv)"), true)
  assert_eq(includes(wgsl, "input.v_color"), true)
}

///|
test "standard material uses direct GGX and keeps ambient diffuse" {
  let wgsl = @nodes.standard_wgsl()
  assert_eq(includes(wgsl, "fn D_GGX("), true)
  assert_eq(includes(wgsl, "fn V_GGX_SmithCorrelated("), true)
  assert_eq(includes(wgsl, "fn F_Schlick("), true)
  assert_eq(
    includes(
      wgsl, "max((uniforms.surface).x * textureSample(roughness_texture, roughness_sampler, input.v_uv).g, 0.0525)",
    ),
    true,
  )
  assert_eq(includes(wgsl, "mix(vec3<f32>(0.04), base.xyz, metalness)"), true)
  assert_eq(includes(wgsl, "exp2((-5.55473 * VoH - 6.98316) * VoH)"), true)
  assert_eq(includes(wgsl, "uniforms.model"), true)
  assert_eq(includes(wgsl, "uniforms.camera_position"), true)
  assert_eq(includes(wgsl, "@location(2) v_world : vec3<f32>"), true)
  assert_eq(
    includes(wgsl, "((uniforms.ambient).xyz + hemisphere_term(N)) * diffuse"),
    true,
  )
  assert_eq(includes(wgsl, "sample_color(input.v_uv)"), true)
  assert_eq(includes(wgsl, "input.v_color"), true)
  assert_eq(includes(wgsl, "return vec4<f32>(direct + indirect, base.w)"), true)
}

///|
test "lambert and standard add emissive after lighting" {
  let expr = "(uniforms.emissive).xyz"
  assert_eq(includes(@nodes.lambert_wgsl(), expr), true)
  assert_eq(includes(@nodes.standard_wgsl(), expr), true)
  assert_eq(includes(@nodes.lambert_instanced_wgsl(), expr), true)
  assert_eq(includes(@nodes.standard_instanced_wgsl(), expr), true)
  assert_eq(includes(@nodes.basic_wgsl(), expr), false)
  assert_eq(includes(@nodes.basic_instanced_wgsl(), expr), false)
  let sample = "sample_emissive(input.v_uv)"
  assert_eq(includes(@nodes.lambert_wgsl(), sample), true)
  assert_eq(includes(@nodes.standard_wgsl(), sample), true)
  assert_eq(includes(@nodes.basic_wgsl(), sample), false)
  assert_eq(
    includes(
      @nodes.lambert_wgsl(),
      "@group(3) @binding(0) var emissive_texture",
    ),
    true,
  )
}

///|
test "standard multiplies roughness by the green channel" {
  let sample = "textureSample(roughness_texture, roughness_sampler, input.v_uv).g"
  let binding = "@group(3) @binding(2) var roughness_texture"
  assert_eq(includes(@nodes.standard_wgsl(), sample), true)
  assert_eq(includes(@nodes.standard_instanced_wgsl(), sample), true)
  assert_eq(includes(@nodes.standard_wgsl(), binding), true)
  assert_eq(includes(@nodes.lambert_wgsl(), sample), false)
  assert_eq(includes(@nodes.lambert_instanced_wgsl(), sample), false)
  assert_eq(includes(@nodes.basic_wgsl(), sample), false)
  assert_eq(includes(@nodes.basic_instanced_wgsl(), "roughness_texture"), false)
}

///|
test "standard multiplies metalness by the blue channel" {
  let sample = "textureSample(metalness_texture, metalness_sampler, input.v_uv).b"
  let binding = "@group(3) @binding(4) var metalness_texture"
  assert_eq(includes(@nodes.standard_wgsl(), sample), true)
  assert_eq(includes(@nodes.standard_instanced_wgsl(), sample), true)
  assert_eq(includes(@nodes.standard_wgsl(), binding), true)
  assert_eq(
    includes(
      @nodes.standard_wgsl(),
      "clamp((uniforms.surface).y * textureSample(metalness_texture, metalness_sampler, input.v_uv).b, 0.0, 1.0)",
    ),
    true,
  )
  assert_eq(includes(@nodes.lambert_wgsl(), sample), false)
  assert_eq(includes(@nodes.lambert_instanced_wgsl(), sample), false)
  assert_eq(includes(@nodes.basic_wgsl(), sample), false)
  assert_eq(includes(@nodes.basic_instanced_wgsl(), "metalness_texture"), false)
}

///|
test "flat shading replaces the normal with screen derivatives" {
  let deriv = "cross(dpdx(view_pos), dpdy(view_pos))"
  assert_eq(includes(@nodes.lambert_wgsl(), deriv), true)
  assert_eq(includes(@nodes.lambert_instanced_wgsl(), deriv), true)
  assert_eq(includes(@nodes.standard_wgsl(), deriv), true)
  assert_eq(includes(@nodes.standard_instanced_wgsl(), deriv), true)
  assert_eq(
    includes(@nodes.lambert_wgsl(), "(uniforms.emissive).w > 0.5"),
    true,
  )
  assert_eq(includes(@nodes.basic_wgsl(), "dpdx"), false)
  assert_eq(includes(@nodes.line_wgsl(), "dpdx"), false)
}

///|
test "color and emissive maps decode sRGB" {
  let basic = @nodes.basic_wgsl()
  let lambert = @nodes.lambert_wgsl()
  let standard = @nodes.standard_wgsl()
  assert_eq(includes(basic, "fn srgb_to_linear("), true)
  assert_eq(includes(basic, "0.0773993808"), true)
  assert_eq(includes(basic, "0.04045"), true)
  assert_eq(includes(basic, "0.9478672986"), true)
  assert_eq(includes(basic, "0.0521327014"), true)
  assert_eq(includes(basic, "sample_color(input.v_uv)"), true)
  assert_eq(includes(basic, "fn sample_emissive("), false)
  assert_eq(includes(lambert, "fn sample_emissive("), true)
  assert_eq(includes(standard, "fn sample_emissive("), true)
  assert_eq(includes(standard, "srgb_to_linear(texel.xyz)"), true)
  assert_eq(
    includes(
      standard, "textureSample(roughness_texture, roughness_sampler, input.v_uv)",
    ),
    true,
  )
  assert_eq(
    includes(
      standard, "textureSample(metalness_texture, metalness_sampler, input.v_uv)",
    ),
    true,
  )
  assert_eq(
    includes(
      standard, "textureSample(alpha_texture, alpha_sampler, input.v_uv)",
    ),
    true,
  )
  assert_eq(includes(@nodes.line_wgsl(), "fn srgb_to_linear("), false)
  assert_eq(includes(@nodes.points_wgsl(), "fn srgb_to_linear("), false)
}

///|
test "mesh materials multiply alpha by the green channel" {
  let sample = "(textureSample(alpha_texture, alpha_sampler, input.v_uv)).g"
  let binding = "@group(3) @binding(6) var alpha_texture"
  assert_eq(includes(@nodes.basic_wgsl(), sample), true)
  assert_eq(includes(@nodes.basic_instanced_wgsl(), sample), true)
  assert_eq(includes(@nodes.lambert_wgsl(), sample), true)
  assert_eq(includes(@nodes.lambert_instanced_wgsl(), sample), true)
  assert_eq(includes(@nodes.standard_wgsl(), sample), true)
  assert_eq(includes(@nodes.standard_instanced_wgsl(), sample), true)
  assert_eq(includes(@nodes.basic_wgsl(), binding), true)
  assert_eq(includes(@nodes.line_wgsl(), sample), false)
  assert_eq(includes(@nodes.lambert_wgsl(), "metalness_texture"), false)
}

///|
test "lambert and standard add one point light" {
  let lambert = @nodes.lambert_wgsl()
  let standard = @nodes.standard_wgsl()
  let basic = @nodes.basic_wgsl()
  assert_eq(includes(lambert, "fn point_falloff("), true)
  assert_eq(includes(lambert, "1.0 / max(pow(dist, decay), 0.01)"), true)
  assert_eq(
    includes(
      lambert, "point_term(input.v_world, facing_normal(input.v_normal, front))",
    ),
    true,
  )
  assert_eq(includes(standard, "fn point_standard("), true)
  assert_eq(
    includes(standard, "point_standard(N, V, world, diffuse, f0, alpha)"),
    true,
  )
  assert_eq(
    includes(standard, "return vec4<f32>(direct + indirect, base.w)"),
    true,
  )
  assert_eq(includes(basic, "fn point_term("), false)
  assert_eq(includes(basic, "fn point_standard("), false)
  assert_eq(includes(lambert, "fn spot_falloff("), true)
  assert_eq(includes(lambert, "fn spot_cone("), true)
  assert_eq(
    includes(
      lambert, "spot_term(input.v_world, facing_normal(input.v_normal, front))",
    ),
    true,
  )
  assert_eq(includes(standard, "fn spot_standard("), true)
  assert_eq(
    includes(standard, "spot_standard(N, V, world, diffuse, f0, alpha)"),
    true,
  )
  assert_eq(includes(basic, "fn spot_term("), false)
  assert_eq(includes(basic, "fn spot_standard("), false)
  assert_eq(includes(lambert, "fn hemisphere_term("), true)
  assert_eq(
    includes(lambert, "hemisphere_term(facing_normal(input.v_normal, front))"),
    true,
  )
  assert_eq(
    includes(
      lambert, "mix((uniforms.hemisphere_ground).xyz, (uniforms.hemisphere_sky).xyz, weight)",
    ),
    true,
  )
  assert_eq(includes(standard, "fn hemisphere_term("), true)
  assert_eq(includes(basic, "fn hemisphere_term("), false)
  let line = @nodes.line_wgsl()
  assert_eq(includes(line, "fn hemisphere_term("), false)
}

///|
test "double sided materials flip the shading normal" {
  let lambert = @nodes.lambert_wgsl()
  let standard = @nodes.standard_wgsl()
  let basic = @nodes.basic_wgsl()
  let call = "facing_normal(input.v_normal, front)"
  assert_eq(includes(lambert, "fn facing_normal("), true)
  assert_eq(includes(lambert, call), true)
  assert_eq(includes(standard, "fn facing_normal("), true)
  assert_eq(includes(standard, call), true)
  assert_eq(includes(basic, "fn facing_normal("), false)
  assert_eq(includes(lambert, "@builtin(front_facing) front : bool"), true)
}

///|
test "instanced meshes multiply instance matrix and color" {
  let matrix = "mat4x4<f32>(input.instance_matrix_0, input.instance_matrix_1, input.instance_matrix_2, input.instance_matrix_3)"
  let basic = @nodes.basic_instanced_wgsl()
  let lambert = @nodes.lambert_instanced_wgsl()
  let standard = @nodes.standard_instanced_wgsl()
  assert_eq(includes(basic, "@location(3) instance_matrix_0 : vec4<f32>"), true)
  assert_eq(includes(basic, "@location(6) instance_matrix_3 : vec4<f32>"), true)
  assert_eq(includes(basic, "@location(7) instance_color : vec3<f32>"), true)
  assert_eq(includes(basic, matrix), true)
  assert_eq(includes(basic, "input.v_instance_color"), true)
  assert_eq(includes(basic, "input.v_color"), true)
  assert_eq(includes(@nodes.basic_wgsl(), "instance_matrix"), false)
  assert_eq(includes(lambert, "instance_normal("), true)
  assert_eq(includes(lambert, matrix), true)
  assert_eq(includes(standard, matrix), true)
  assert_eq(includes(standard, "fn D_GGX("), true)
  assert_eq(includes(standard, "input.v_instance_color"), true)
}

///|
test "lit materials sample a directional shadow map" {
  let lambert = @nodes.lambert_wgsl()
  let standard = @nodes.standard_wgsl()
  assert_eq(
    includes(lambert, "textureSampleCompare(shadow_map, shadow_sampler,"),
    true,
  )
  assert_eq(includes(lambert, "texture_depth_2d"), true)
  assert_eq(includes(lambert, "(uniforms.ambient).xyz"), true)
  assert_eq(
    includes(
      lambert, "direct_shadow(input.v_world, facing_normal(input.v_normal, front))",
    ),
    true,
  )
  assert_eq(includes(@nodes.basic_wgsl(), "shadow_map"), false)
  assert_eq(includes(standard, "direct_shadow(world, N)"), true)
  assert_eq(
    includes(
      standard, "((uniforms.ambient).xyz + hemisphere_term(N)) * diffuse",
    ),
    true,
  )
  assert_eq(
    includes(
      @nodes.shadow_wgsl(),
      "uniforms.mvp * vec4<f32>(input.position, 1.0)",
    ),
    true,
  )
  assert_eq(includes(@nodes.shadow_instanced_wgsl(), "instance_matrix_0"), true)
}

///|
test "lines return the uniform color and points scale like r186" {
  let line = @nodes.line_wgsl()
  assert_eq(
    includes(line, "apply_fog(uniforms.color, input.v_fog_depth)"),
    true,
  )
  assert_eq(includes(line, "@location(0) position : vec3<f32>"), true)
  assert_eq(includes(line, "map_texture"), false)
  assert_eq(includes(line, "color.a < (uniforms.surface).z"), true)
  assert_eq(includes(line, "discard"), true)
  assert_eq(includes(@nodes.basic_wgsl(), "fn apply_fog("), true)
  assert_eq(includes(@nodes.lambert_wgsl(), "v_fog_depth"), true)
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
  assert_eq(includes(points, "apply_fog(color, input.v_fog_depth)"), true)
}
