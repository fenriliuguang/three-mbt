///|
test "skinning follows the joint and keeps the second write stable" {
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
  skin.write(mesh, geometry)
  let position = geometry.get_attribute("position").unwrap()
  let normal = geometry.get_attribute("normal").unwrap()
  assert_eq(position.get_x(0), 4.0)
  assert_eq(position.get_y(0), 0.0)
  assert_eq(position.get_z(0), 0.0)
  assert_eq(normal.get_x(0), 0.0)
  assert_eq(normal.get_y(0), -1.0)
  assert_eq(normal.get_z(0), 0.0)
  assert_eq(geometry.version, 2)
  assert_eq(geometry.bounding_sphere is None, true)
}

///|
test "an out of range joint adds nothing" {
  let mesh = @core.Object3D::new()
  mesh.update_matrix_world(force=true)
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([1.0, 0.0, 0.0], 3),
    ),
  )
  let skin = @core.SkinState::{
    joints: [],
    inverse_binds: [],
    bind_position: [1.0, 0.0, 0.0],
    bind_normal: None,
    indices: [3, 0, 0, 0],
    weights: [1.0, 0.0, 0.0, 0.0],
  }
  skin.write(mesh, geometry)
  let position = geometry.get_attribute("position").unwrap()
  assert_eq(position.get_x(0), 0.0)
  assert_eq(position.get_y(0), 0.0)
  assert_eq(position.get_z(0), 0.0)
}
