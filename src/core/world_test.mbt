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
test "child world matrix matches r186" {
  let parent = @core.Object3D::new()
  ignore(parent.position.set(10.0, 0.0, 0.0))
  ignore(parent.rotation.set(0.0, 0.5, 0.0))
  let child = @core.Object3D::new()
  ignore(child.position.set(0.0, 0.0, 4.0))
  ignore(parent.add(child))
  parent.update_matrix_world()
  let expected = [
    0.87758256189, 0.0, -0.479425538604, 0.0, 0.0, 1.0, 0.0, 0.0, 0.479425538604,
    0.0, 0.87758256189, 0.0, 11.9177021544, 0.0, 3.51033024756, 1.0,
  ]
  for i in 0..<16 {
    assert_close(child.matrix_world.elements[i], expected[i])
  }
}

///|
test "local rotate and translate match r186" {
  let half = 0.7071067811865476
  let right_angle = 1.5707963267948966
  let object = @core.Object3D::new()
  ignore(object.rotate_y(right_angle))
  assert_close(object.quaternion.x, 0.0)
  assert_close(object.quaternion.y, half)
  assert_close(object.quaternion.z, 0.0)
  assert_close(object.quaternion.w, half)
  assert_close(object.rotation.y, right_angle)
  ignore(object.translate_x(2.0))
  assert_close(object.position.x, 0.0)
  assert_close(object.position.y, 0.0)
  assert_close(object.position.z, -2.0)
  let identity = @core.Object3D::new()
  let axis = @math.Vector3::new(x=1.0)
  ignore(identity.translate_on_axis(axis, 2.0))
  assert_eq(identity.position.x, 2.0)
  assert_eq(identity.position.y, 0.0)
  assert_eq(identity.position.z, 0.0)
  assert_eq(axis.x, 1.0)
  assert_eq(axis.y, 0.0)
  assert_eq(axis.z, 0.0)
  ignore(identity.translate_y(3.0))
  ignore(identity.translate_z(-1.0))
  assert_eq(identity.position.x, 2.0)
  assert_eq(identity.position.y, 3.0)
  assert_eq(identity.position.z, -1.0)
  let pitched = @core.Object3D::new()
  ignore(pitched.rotate_x(right_angle))
  assert_close(pitched.quaternion.x, half)
  assert_close(pitched.quaternion.w, half)
  let rolled = @core.Object3D::new()
  ignore(rolled.rotate_z(right_angle))
  assert_close(rolled.quaternion.z, half)
  assert_close(rolled.quaternion.w, half)
}

///|
test "world axis rotation premultiplies the quaternion" {
  let right_angle = 1.5707963267948966
  let world = @core.Object3D::new()
  ignore(world.rotate_y(right_angle))
  ignore(world.rotate_on_world_axis(@math.Vector3::new(x=1.0), right_angle))
  assert_close(world.quaternion.x, 0.5)
  assert_close(world.quaternion.y, 0.5)
  assert_close(world.quaternion.z, 0.5)
  assert_close(world.quaternion.w, 0.5)
  let body = @core.Object3D::new()
  ignore(body.rotate_y(right_angle))
  ignore(body.rotate_x(right_angle))
  assert_close(body.quaternion.x, 0.5)
  assert_close(body.quaternion.y, 0.5)
  assert_close(body.quaternion.z, -0.5)
  assert_close(body.quaternion.w, 0.5)
}

///|
test "apply matrix and quaternion update the local transform" {
  let right_angle = 1.5707963267948966
  let half = 0.7071067811865476
  let object = @core.Object3D::new()
  ignore(object.position.set(1.0, 0.0, 0.0))
  let turn = @math.Quaternion::new().set_from_axis_angle(
    @math.Vector3::new(y=1.0),
    right_angle,
  )
  let matrix = @math.Matrix4::new().make_rotation_from_quaternion(turn)
  object.apply_matrix4(matrix)
  assert_close(object.position.x, 0.0)
  assert_close(object.position.y, 0.0)
  assert_close(object.position.z, -1.0)
  assert_close(object.quaternion.x, 0.0)
  assert_close(object.quaternion.y, half)
  assert_close(object.quaternion.z, 0.0)
  assert_close(object.quaternion.w, half)
  assert_close(object.scale.x, 1.0)
  assert_close(object.scale.y, 1.0)
  assert_close(object.scale.z, 1.0)
  let spun = @core.Object3D::new()
  ignore(spun.rotate_y(right_angle))
  let pitch = @math.Quaternion::new().set_from_axis_angle(
    @math.Vector3::new(x=1.0),
    right_angle,
  )
  ignore(spun.apply_quaternion(pitch))
  assert_close(spun.quaternion.x, 0.5)
  assert_close(spun.quaternion.y, 0.5)
  assert_close(spun.quaternion.z, 0.5)
  assert_close(spun.quaternion.w, 0.5)
}

///|
test "world rotation scale and direction follow the parent" {
  let parent = @core.Object3D::new()
  ignore(parent.position.set(10.0, 0.0, 0.0))
  ignore(parent.rotation.set(0.0, 0.5, 0.0))
  let child = @core.Object3D::new()
  ignore(child.position.set(0.0, 0.0, 4.0))
  ignore(parent.add(child))
  parent.update_matrix_world()
  let rotation = @math.Quaternion::new()
  ignore(child.get_world_quaternion(rotation))
  assert_close(rotation.x, parent.quaternion.x)
  assert_close(rotation.y, parent.quaternion.y)
  assert_close(rotation.z, parent.quaternion.z)
  assert_close(rotation.w, parent.quaternion.w)
  let scale = @math.Vector3::new()
  ignore(child.get_world_scale(scale))
  assert_eq(scale.x, 1.0)
  assert_eq(scale.y, 1.0)
  assert_eq(scale.z, 1.0)
  let direction = @math.Vector3::new()
  ignore(child.get_world_direction(direction))
  assert_close(direction.x, 0.479425538604)
  assert_close(direction.y, 0.0)
  assert_close(direction.z, 0.87758256189)
  let scaled = @core.Object3D::new()
  ignore(scaled.scale.set(2.0, 3.0, 4.0))
  let nested = @core.Object3D::new()
  ignore(nested.scale.set(0.5, 2.0, 1.0))
  ignore(scaled.add(nested))
  let world_scale = @math.Vector3::new()
  ignore(nested.get_world_scale(world_scale))
  assert_eq(world_scale.x, 1.0)
  assert_eq(world_scale.y, 6.0)
  assert_eq(world_scale.z, 4.0)
}

///|
test "local and world vectors round trip through the child" {
  let parent = @core.Object3D::new()
  ignore(parent.position.set(10.0, 0.0, 0.0))
  ignore(parent.rotation.set(0.0, 0.5, 0.0))
  let child = @core.Object3D::new()
  ignore(child.position.set(0.0, 0.0, 4.0))
  ignore(parent.add(child))
  let point = @math.Vector3::new(z=1.0)
  ignore(child.local_to_world(point))
  assert_close(point.x, 12.397127693021)
  assert_close(point.y, 0.0)
  assert_close(point.z, 4.38791280945)
  ignore(child.world_to_local(point))
  assert_close(point.x, 0.0)
  assert_close(point.y, 0.0)
  assert_close(point.z, 1.0)
  assert_close(child.matrix_world.elements[12], 11.9177021544)
  assert_close(child.matrix_world.elements[14], 3.51033024756)
}

///|
test "lookAt matches r186 quaternion" {
  let looker = @core.Object3D::new()
  ignore(looker.position.set(0.0, 0.0, 5.0))
  looker.look_at(0.0, 0.0, 0.0)
  assert_eq(looker.quaternion.x, 0.0)
  assert_eq(looker.quaternion.y, 1.0)
  assert_eq(looker.quaternion.z, 0.0)
  assert_eq(looker.quaternion.w, 0.0)
}

///|
test "added child notifies the parent" {
  let parent = @core.Object3D::new()
  let hits = Ref::Ref(0)
  parent.add_event_listener("childadded", fn(_event) { hits.val = hits.val + 1 })
  let child = @core.Object3D::new()
  ignore(parent.add(child))
  assert_eq(hits.val, 1)
  assert_eq(parent.children.length(), 1)
  ignore(parent.remove(child))
  assert_eq(parent.children.length(), 0)
  match child.parent {
    None => assert_eq(true, true)
    Some(_) => assert_eq(false, true)
  }
}
