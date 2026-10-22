///|
test "gpu skin formula matches the cpu rewrite" {
  let joint = @core.Object3D::new()
  ignore(joint.position.set(3.0, 0.0, 0.0))
  ignore(joint.quaternion.set(0.0, 0.0, 1.0, 0.0))
  joint.update_matrix_world(force=true)
  let mesh = @core.Object3D::new()
  mesh.update_matrix_world(force=true)
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0], 3),
    ),
  )
  ignore(
    geometry.set_attribute(
      "normal",
      @core.BufferAttribute::new([0.0, 1.0, 0.0], 3),
    ),
  )
  ignore(
    geometry.set_attribute("uv", @core.BufferAttribute::new([0.25, 0.5], 2)),
  )
  let inverse = @math.Matrix4::new()
  ignore(inverse.make_translation(-1.0, 0.0, 0.0))
  let skin = @core.SkinState::{
    joints: [joint],
    inverse_binds: [inverse],
    bind_position: [0.0, 0.0, 0.0],
    bind_normal: Some([0.0, 1.0, 0.0]),
    indices: [0, 0, 0, 0],
    weights: [1.0, 0.0, 0.0, 0.0],
  }
  skin.write(mesh, geometry)
  let bytes = @common.skinned_vertex_bytes(mesh, geometry, skin)
  let position = geometry.get_attribute("position").unwrap()
  let normal = geometry.get_attribute("normal").unwrap()
  assert_eq(read_test_f32(bytes, 0), position.get_x(0))
  assert_eq(read_test_f32(bytes, 4), position.get_y(0))
  assert_eq(read_test_f32(bytes, 8), position.get_z(0))
  assert_eq(read_test_f32(bytes, 12), normal.get_x(0))
  assert_eq(read_test_f32(bytes, 16), normal.get_y(0))
  assert_eq(read_test_f32(bytes, 20), normal.get_z(0))
  assert_eq(read_test_f32(bytes, 24), 0.25)
  assert_eq(read_test_f32(bytes, 28), 0.5)
  assert_eq(position.get_x(0), 4.0)
  assert_eq(normal.get_y(0), -1.0)
}

///|
fn read_test_f32(src : FixedArray[Byte], offset : Int32) -> Double {
  let bits = src[offset].to_int() +
    (src[offset + 1].to_int() << 8) +
    (src[offset + 2].to_int() << 16) +
    (src[offset + 3].to_int() << 24)
  Float::reinterpret_from_uint(bits.reinterpret_as_uint()).to_double()
}
