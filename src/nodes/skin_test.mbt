///|
test "skin compute wgsl names the bind inverse and a 64-wide group" {
  let code = @nodes.skin_wgsl()
  assert_eq(code.contains("@workgroup_size(64)"), true)
  assert_eq(code.contains("bind_inverse"), true)
  assert_eq(code.contains("bone_count"), true)
  assert_eq(code.contains("skin_normal"), true)
}
