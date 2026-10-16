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
test "fromBufferAttribute reads xyz and skips a fourth component" {
  let positions = @core.BufferAttribute::new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 3)
  let v = @math.Vector3::new(x=9.0, y=8.0, z=7.0)
  ignore(positions.copy_to_vector3(1, v))
  assert_eq(v.x, 4.0)
  assert_eq(v.y, 5.0)
  assert_eq(v.z, 6.0)
  let wide = @core.BufferAttribute::new(
    [1.0, 2.0, 3.0, 9.0, 4.0, 5.0, 6.0, 8.0],
    4,
  )
  ignore(wide.copy_to_vector3(1, v))
  assert_eq(v.x, 4.0)
  assert_eq(v.y, 5.0)
  assert_eq(v.z, 6.0)
  assert_eq(positions.get_x(0), 1.0)
  assert_eq(wide.get_component(1, 3), 8.0)
}

///|
test "setFromBufferAttribute fits each vertex" {
  let positions = @core.BufferAttribute::new([1.0, 2.0, 3.0, 0.0, 5.0, 4.0], 3)
  let box = @math.Box3::new(
    @math.Vector3::new(x=9.0, y=9.0, z=9.0),
    @math.Vector3::new(x=8.0, y=8.0, z=8.0),
  )
  ignore(positions.set_box3(box))
  assert_eq(box.min.x, 0.0)
  assert_eq(box.min.y, 2.0)
  assert_eq(box.min.z, 3.0)
  assert_eq(box.max.x, 1.0)
  assert_eq(box.max.y, 5.0)
  assert_eq(box.max.z, 4.0)
  assert_eq(positions.get_x(0), 1.0)
  let wide = @core.BufferAttribute::new(
    [1.0, 2.0, 3.0, 9.0, 0.0, 5.0, 4.0, 8.0],
    4,
  )
  ignore(wide.set_box3(box))
  assert_eq(box.min.x, 0.0)
  assert_eq(box.min.y, 2.0)
  assert_eq(box.min.z, 3.0)
  assert_eq(box.max.x, 1.0)
  assert_eq(box.max.y, 5.0)
  assert_eq(box.max.z, 4.0)
  assert_eq(wide.get_component(0, 3), 9.0)
  let empty = @core.BufferAttribute::new([], 3)
  ignore(empty.set_box3(box))
  assert_eq(box.min.x > 1.0e308, true)
  assert_eq(box.max.x < -1.0e308, true)
}

///|
test "getInterpolatedAttribute blends three vertices" {
  let colors = @core.BufferAttribute::new(
    [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0],
    3,
  )
  let bary = @math.Vector3::new(x=0.0, y=0.5, z=0.5)
  let target = @math.Vector3::new(x=9.0, y=8.0, z=7.0)
  ignore(colors.interpolate_vector3(0, 1, 2, bary, target))
  assert_eq(target.x, 0.0)
  assert_eq(target.y, 0.5)
  assert_eq(target.z, 0.5)
  assert_eq(colors.get_x(0), 1.0)
  assert_eq(colors.get_y(1), 1.0)
  assert_eq(colors.get_z(2), 1.0)
  assert_eq(bary.y, 0.5)
}

///|
test "setFromAttributeAndIndices copies three indexed vertices" {
  let positions = @core.BufferAttribute::new(
    [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 0.0, 0.0, 1.0],
    3,
  )
  let triangle = @math.Triangle::new()
  ignore(positions.set_triangle(triangle, 3, 0, 1))
  assert_eq(triangle.a.z, 1.0)
  assert_eq(triangle.b.x, 1.0)
  assert_eq(triangle.b.y, 2.0)
  assert_eq(triangle.c.y, 5.0)
  assert_eq(triangle.c.z, 6.0)
  assert_eq(positions.get_x(0), 1.0)
  assert_eq(positions.get_z(3), 1.0)
}

///|
test "fromBufferAttribute reads xy and skips later components" {
  let positions = @core.BufferAttribute::new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 2)
  let v = @math.Vector2::new(x=9.0, y=8.0)
  ignore(positions.copy_to_vector2(1, v))
  assert_eq(v.x, 3.0)
  assert_eq(v.y, 4.0)
  let wide = @core.BufferAttribute::new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 3)
  ignore(wide.copy_to_vector2(1, v))
  assert_eq(v.x, 4.0)
  assert_eq(v.y, 5.0)
  assert_eq(positions.get_x(0), 1.0)
  assert_eq(wide.get_z(1), 6.0)
}

///|
test "fromBufferAttribute reads xyzw" {
  let colors = @core.BufferAttribute::new(
    [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0],
    4,
  )
  let v = @math.Vector4::new(x=9.0, y=9.0, z=9.0, w=9.0)
  ignore(colors.copy_to_vector4(1, v))
  assert_eq(v.x, 5.0)
  assert_eq(v.y, 6.0)
  assert_eq(v.z, 7.0)
  assert_eq(v.w, 8.0)
  let packed = @core.BufferAttribute::new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 3)
  ignore(packed.copy_to_vector4(0, v))
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 2.0)
  assert_eq(v.z, 3.0)
  assert_eq(v.w, 4.0)
  assert_eq(colors.get_x(0), 1.0)
  assert_eq(packed.get_x(1), 4.0)
}

///|
test "fromBufferAttribute reads rgb and skips a fourth component" {
  let colors = @core.BufferAttribute::new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 3)
  let color = @math.Color::new(r=9.0, g=8.0, b=7.0)
  let written = colors.copy_to_color(1, color)
  assert_eq(physical_equal(written, color), true)
  assert_eq(color.r, 4.0)
  assert_eq(color.g, 5.0)
  assert_eq(color.b, 6.0)
  let wide = @core.BufferAttribute::new(
    [1.0, 2.0, 3.0, 9.0, 4.0, 5.0, 6.0, 8.0],
    4,
  )
  ignore(wide.copy_to_color(1, color))
  assert_eq(color.r, 4.0)
  assert_eq(color.g, 5.0)
  assert_eq(color.b, 6.0)
  assert_eq(colors.get_x(0), 1.0)
  assert_eq(wide.get_component(1, 3), 8.0)
}

///|
test "fromBufferAttribute reads a quaternion" {
  let values = @core.BufferAttribute::new(
    [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0],
    4,
  )
  let q = @math.Quaternion::new(x=9.0, y=9.0, z=9.0, w=9.0)
  let hits = [0]
  q.on_change = Some(fn() { hits[0] = hits[0] + 1 })
  let written = values.copy_to_quaternion(1, q)
  assert_eq(physical_equal(written, q), true)
  assert_eq(q.x, 5.0)
  assert_eq(q.y, 6.0)
  assert_eq(q.z, 7.0)
  assert_eq(q.w, 8.0)
  assert_eq(hits[0], 1)
  let packed = @core.BufferAttribute::new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 3)
  ignore(packed.copy_to_quaternion(0, q))
  assert_eq(q.x, 1.0)
  assert_eq(q.y, 2.0)
  assert_eq(q.z, 3.0)
  assert_eq(q.w, 4.0)
  assert_eq(hits[0], 2)
  assert_eq(values.get_x(0), 1.0)
  assert_eq(packed.get_x(1), 4.0)
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
test "dispose notifies listeners" {
  let object = @core.Object3D::new()
  let hits = Ref::Ref(0)
  let kind = Ref::Ref("")
  object.add_event_listener("dispose", fn(event) {
    hits.val = hits.val + 1
    kind.val = event.kind
  })
  object.dispose()
  assert_eq(hits.val, 1)
  assert_eq(kind.val, "dispose")
  assert_eq(object.children.length(), 0)
}

///|
test "clone copies the transform and the children" {
  let source = @core.Object3D::new(kind=@core.NodeKind::Mesh)
  source.name = "box"
  ignore(source.position.set(1.0, 2.0, 3.0))
  ignore(source.rotation.set(0.0, 0.5, 0.0))
  source.rotation.order = @math.EulerOrder::YXZ
  ignore(source.scale.set(2.0, 3.0, 4.0))
  source.visible = false
  source.cast_shadow = true
  source.render_order = 7
  source.layers.set(2)
  source.pivot = Some(@math.Vector3::new(x=1.0, y=2.0, z=3.0))
  let arm = @core.Object3D::new()
  arm.name = "arm"
  ignore(arm.position.set(4.0, 0.0, 0.0))
  ignore(source.add(arm))
  let cloned = source.clone()
  assert_eq(cloned.id == source.id, false)
  assert_eq(cloned.name, "box")
  match cloned.kind {
    Mesh => assert_eq(true, true)
    _ => assert_eq(false, true)
  }
  assert_eq(cloned.position.x, 1.0)
  assert_eq(cloned.position.y, 2.0)
  assert_eq(cloned.position.z, 3.0)
  assert_close(cloned.quaternion.y, source.quaternion.y)
  assert_close(cloned.quaternion.w, source.quaternion.w)
  assert_close(cloned.rotation.y, 0.5)
  match cloned.rotation.order {
    YXZ => assert_eq(true, true)
    _ => assert_eq(false, true)
  }
  assert_eq(cloned.scale.x, 2.0)
  assert_eq(cloned.scale.y, 3.0)
  assert_eq(cloned.scale.z, 4.0)
  assert_eq(cloned.visible, false)
  assert_eq(cloned.cast_shadow, true)
  assert_eq(cloned.render_order, 7)
  assert_eq(cloned.layers.mask, 4)
  assert_eq(cloned.children.length(), 1)
  assert_eq(cloned.children[0].name, "arm")
  assert_eq(cloned.children[0].position.x, 4.0)
  assert_eq(cloned.children[0].id == arm.id, false)
  match cloned.children[0].parent {
    Some(parent) => assert_eq(parent.id, cloned.id)
    None => assert_eq(false, true)
  }
  match source.pivot {
    Some(pivot) => pivot.x = 9.0
    None => assert_eq(false, true)
  }
  match cloned.pivot {
    Some(pivot) => assert_eq(pivot.x, 1.0)
    None => assert_eq(false, true)
  }
  let flat = source.clone(recursive=false)
  assert_eq(flat.children.length(), 0)
  assert_eq(source.children.length(), 1)
}

///|
test "get object by id searches self then descendants" {
  let root = @core.Object3D::new()
  let child = @core.Object3D::new()
  let grandchild = @core.Object3D::new()
  let sibling = @core.Object3D::new()
  ignore(root.add(child))
  ignore(child.add(grandchild))
  ignore(root.add(sibling))
  match root.get_object_by_id(root.id) {
    Some(found) => assert_eq(found.id, root.id)
    None => assert_eq(false, true)
  }
  match root.get_object_by_id(grandchild.id) {
    Some(found) => assert_eq(found.id, grandchild.id)
    None => assert_eq(false, true)
  }
  match child.get_object_by_id(root.id) {
    None => assert_eq(true, true)
    Some(_) => assert_eq(false, true)
  }
  match root.get_object_by_id(-1) {
    None => assert_eq(true, true)
    Some(_) => assert_eq(false, true)
  }
  match root.get_object_by_id(sibling.id) {
    Some(found) => assert_eq(found.id, sibling.id)
    None => assert_eq(false, true)
  }
}

///|
test "traverse ancestors visits parents toward the root" {
  let root = @core.Object3D::new()
  root.name = "root"
  let parent = @core.Object3D::new()
  parent.name = "parent"
  let child = @core.Object3D::new()
  ignore(root.add(parent))
  ignore(parent.add(child))
  let names = []
  child.traverse_ancestors(fn(node) { names.push(node.name) })
  assert_eq(names.length(), 2)
  assert_eq(names[0], "parent")
  assert_eq(names[1], "root")
  let alone = []
  root.traverse_ancestors(fn(node) { alone.push(node.name) })
  assert_eq(alone.length(), 0)
}

///|
test "attach keeps the world position and rotation" {
  let source = @core.Object3D::new()
  ignore(source.position.set(10.0, 0.0, 0.0))
  let child = @core.Object3D::new()
  ignore(child.position.set(1.0, 0.0, 0.0))
  ignore(source.add(child))
  let dest = @core.Object3D::new()
  ignore(dest.position.set(3.0, 0.0, 0.0))
  let hits = Ref::Ref(0)
  dest.add_event_listener("childadded", fn(_event) { hits.val = hits.val + 1 })
  ignore(dest.attach(child))
  assert_eq(hits.val, 1)
  assert_eq(source.children.length(), 0)
  assert_eq(dest.children.length(), 1)
  assert_close(child.position.x, 8.0)
  assert_eq(child.position.y, 0.0)
  assert_eq(child.position.z, 0.0)
  let shifted = @math.Vector3::new()
  ignore(child.get_world_position(shifted))
  assert_close(shifted.x, 11.0)
  assert_close(shifted.y, 0.0)
  assert_close(shifted.z, 0.0)
  let yawed = @core.Object3D::new()
  ignore(yawed.position.set(10.0, 0.0, 0.0))
  ignore(yawed.rotation.set(0.0, 0.5, 0.0))
  let offset = @core.Object3D::new()
  ignore(offset.position.set(0.0, 0.0, 4.0))
  ignore(yawed.add(offset))
  let root = @core.Object3D::new()
  ignore(root.attach(offset))
  assert_close(offset.quaternion.x, yawed.quaternion.x)
  assert_close(offset.quaternion.y, yawed.quaternion.y)
  assert_close(offset.quaternion.z, yawed.quaternion.z)
  assert_close(offset.quaternion.w, yawed.quaternion.w)
  let world = @math.Vector3::new()
  ignore(offset.get_world_position(world))
  assert_close(world.x, 11.9177021544)
  assert_close(world.y, 0.0)
  assert_close(world.z, 3.51033024756)
}

///|
test "rotation setters write the quaternion and the bound euler" {
  let right_angle = 1.5707963267948966
  let half = 0.7071067811865476
  let yawed = @core.Object3D::new()
  yawed.set_rotation_from_axis_angle(@math.Vector3::new(y=1.0), right_angle)
  assert_close(yawed.quaternion.x, 0.0)
  assert_close(yawed.quaternion.y, half)
  assert_close(yawed.quaternion.z, 0.0)
  assert_close(yawed.quaternion.w, half)
  assert_close(yawed.rotation.y, right_angle)
  let tilted = @core.Object3D::new()
  tilted.set_rotation_from_euler(@math.Euler::new(x=0.2, y=-0.4, z=0.6))
  assert_close(tilted.quaternion.x, 0.0350558732382)
  assert_close(tilted.quaternion.y, -0.21776257154)
  assert_close(tilted.quaternion.z, 0.269234547391)
  assert_close(tilted.quaternion.w, 0.937477096616)
  assert_close(tilted.rotation.x, 0.2)
  assert_close(tilted.rotation.y, -0.4)
  assert_close(tilted.rotation.z, 0.6)
  let from_matrix = @core.Object3D::new()
  let matrix = @math.Matrix4::new().make_rotation_from_quaternion(
    yawed.quaternion,
  )
  from_matrix.set_rotation_from_matrix(matrix)
  assert_close(from_matrix.quaternion.y, half)
  assert_close(from_matrix.quaternion.w, half)
  let copied = @core.Object3D::new()
  copied.set_rotation_from_quaternion(tilted.quaternion)
  assert_close(copied.quaternion.x, 0.0350558732382)
  assert_close(copied.quaternion.y, -0.21776257154)
  assert_close(copied.quaternion.z, 0.269234547391)
  assert_close(copied.quaternion.w, 0.937477096616)
  assert_close(copied.rotation.x, 0.2)
  assert_close(copied.rotation.y, -0.4)
  assert_close(copied.rotation.z, 0.6)
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

///|
test "deleteAttribute removes one named attribute" {
  let geometry = @core.BufferGeometry::new()
  let position = @core.BufferAttribute::new([1.0, 2.0, 3.0], 3)
  let normal = @core.BufferAttribute::new([0.0, 1.0, 0.0], 3)
  ignore(geometry.set_attribute("position", position))
  ignore(geometry.set_attribute("normal", normal))
  ignore(geometry.set_index_array([0, 1, 2]))
  let written = geometry.delete_attribute("normal")
  assert_eq(physical_equal(written, geometry), true)
  match geometry.get_attribute("normal") {
    None => assert_eq(true, true)
    Some(_) => assert_eq(false, true)
  }
  match geometry.get_attribute("position") {
    None => assert_eq(false, true)
    Some(found) => assert_eq(found.get_y(0), 2.0)
  }
  match geometry.index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index.get_x(1), 1.0)
  }
  ignore(geometry.delete_attribute("missing"))
  match geometry.get_attribute("position") {
    None => assert_eq(false, true)
    Some(found) => assert_eq(found.get_x(0), 1.0)
  }
}

///|
test "hasAttribute reports a named attribute" {
  let geometry = @core.BufferGeometry::new()
  assert_eq(geometry.has_attribute("position"), false)
  ignore(geometry.set_attribute("position", @core.BufferAttribute::new([1.0, 2.0, 3.0], 3)))
  ignore(geometry.set_index_array([0]))
  assert_eq(geometry.has_attribute("position"), true)
  assert_eq(geometry.has_attribute("normal"), false)
  assert_eq(geometry.has_attribute("index"), false)
  ignore(geometry.delete_attribute("position"))
  assert_eq(geometry.has_attribute("position"), false)
}

///|
test "clearGroups drops every draw group" {
  let geometry = @core.BufferGeometry::new()
  geometry.add_group(0, 3, material_index=1)
  geometry.add_group(3, 6)
  assert_eq(geometry.groups.length(), 2)
  assert_eq(geometry.groups[0].material_index, 1)
  assert_eq(geometry.groups[1].start, 3)
  assert_eq(geometry.groups[1].count, 6)
  ignore(
    geometry.set_attribute("position", @core.BufferAttribute::new([1.0, 2.0, 3.0], 3)),
  )
  geometry.clear_groups()
  assert_eq(geometry.groups.length(), 0)
  assert_eq(geometry.has_attribute("position"), true)
}

///|
test "setDrawRange stores the first vertex and the count" {
  let geometry = @core.BufferGeometry::new()
  assert_eq(geometry.draw_range.start, 0.0)
  assert_eq(geometry.draw_range.count.is_inf(), true)
  assert_eq(geometry.draw_range.count > 0.0, true)
  geometry.set_draw_range(1.0, 4.0)
  assert_eq(geometry.draw_range.start, 1.0)
  assert_eq(geometry.draw_range.count, 4.0)
}

///|
test "applyMatrix4 translates each vertex" {
  let positions = @core.BufferAttribute::new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 3)
  let matrix = @math.Matrix4::new().make_translation(10.0, 0.0, 0.0)
  let written = positions.apply_matrix4(matrix)
  assert_eq(physical_equal(written, positions), true)
  assert_eq(positions.get_x(0), 11.0)
  assert_eq(positions.get_y(0), 2.0)
  assert_eq(positions.get_z(0), 3.0)
  assert_eq(positions.get_x(1), 14.0)
  assert_eq(positions.get_y(1), 5.0)
  assert_eq(positions.get_z(1), 6.0)
}

///|
test "applyMatrix3 transforms item sizes 2 and 3" {
  let uvs = @core.BufferAttribute::new([1.0, 2.0], 2)
  let shift = @math.Matrix3::new().make_translation(0.25, 0.5)
  let written = uvs.apply_matrix3(shift)
  assert_eq(physical_equal(written, uvs), true)
  assert_eq(uvs.get_x(0), 1.25)
  assert_eq(uvs.get_y(0), 2.5)
  let positions = @core.BufferAttribute::new([1.0, 1.0, 1.0], 3)
  let scale = @math.Matrix3::new().set(2.0, 0.0, 0.0, 0.0, 3.0, 0.0, 0.0, 0.0, 4.0)
  ignore(positions.apply_matrix3(scale))
  assert_eq(positions.get_x(0), 2.0)
  assert_eq(positions.get_y(0), 3.0)
  assert_eq(positions.get_z(0), 4.0)
  let wide = @core.BufferAttribute::new([9.0, 8.0, 7.0, 6.0], 4)
  ignore(wide.apply_matrix3(scale))
  assert_eq(wide.get_x(0), 9.0)
  assert_eq(wide.get_component(0, 3), 6.0)
}

///|
test "applyNormalMatrix rotates and normalizes each vertex" {
  let normals = @core.BufferAttribute::new([2.0, 0.0, 0.0, 0.0, 3.0, 0.0], 3)
  let turn = @math.Matrix3::new().set(0.0, -1.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
  let written = normals.apply_normal_matrix(turn)
  assert_eq(physical_equal(written, normals), true)
  assert_eq(normals.get_x(0), 0.0)
  assert_eq(normals.get_y(0), 1.0)
  assert_eq(normals.get_z(0), 0.0)
  assert_eq(normals.get_x(1), -1.0)
  assert_eq(normals.get_y(1), 0.0)
  assert_eq(normals.get_z(1), 0.0)
}

///|
test "transformDirection ignores translation and normalizes scale" {
  let directions = @core.BufferAttribute::new([0.0, 0.0, 1.0], 3)
  let shift = @math.Matrix4::new().make_translation(10.0, 0.0, 0.0)
  let written = directions.transform_direction(shift)
  assert_eq(physical_equal(written, directions), true)
  assert_eq(directions.get_x(0), 0.0)
  assert_eq(directions.get_y(0), 0.0)
  assert_eq(directions.get_z(0), 1.0)
  let scaled = @core.BufferAttribute::new([1.0, 1.0, 0.0], 3)
  let scale = @math.Matrix4::new().make_scale(2.0, 1.0, 1.0)
  ignore(scaled.transform_direction(scale))
  assert_close(scaled.get_x(0), 0.894427190999916)
  assert_close(scaled.get_y(0), 0.447213595499958)
  assert_eq(scaled.get_z(0), 0.0)
}

///|
test "applyMatrix4 transforms position, normal, and tangent" {
  let geometry = @core.BufferGeometry::new()
  ignore(geometry.set_attribute("position", @core.BufferAttribute::new([1.0, 2.0, 3.0], 3)))
  ignore(geometry.set_attribute("normal", @core.BufferAttribute::new([1.0, 1.0, 0.0], 3)))
  ignore(geometry.set_attribute("tangent", @core.BufferAttribute::new([1.0, 1.0, 0.0], 3)))
  ignore(geometry.set_attribute("uv", @core.BufferAttribute::new([0.25, 0.5], 2)))
  geometry.compute_bounding_box()
  geometry.compute_bounding_sphere()
  let scale = @math.Matrix4::new().make_scale(2.0, 1.0, 1.0)
  let written = geometry.apply_matrix4(scale)
  assert_eq(physical_equal(written, geometry), true)
  match geometry.get_attribute("position") {
    None => assert_eq(false, true)
    Some(position) => {
      assert_eq(position.get_x(0), 2.0)
      assert_eq(position.get_y(0), 2.0)
      assert_eq(position.get_z(0), 3.0)
    }
  }
  match geometry.get_attribute("normal") {
    None => assert_eq(false, true)
    Some(normal) => {
      assert_close(normal.get_x(0), 0.447213595499958)
      assert_close(normal.get_y(0), 0.894427190999916)
      assert_eq(normal.get_z(0), 0.0)
    }
  }
  match geometry.get_attribute("tangent") {
    None => assert_eq(false, true)
    Some(tangent) => {
      assert_close(tangent.get_x(0), 0.894427190999916)
      assert_close(tangent.get_y(0), 0.447213595499958)
      assert_eq(tangent.get_z(0), 0.0)
    }
  }
  match geometry.get_attribute("uv") {
    None => assert_eq(false, true)
    Some(uv) => {
      assert_eq(uv.get_x(0), 0.25)
      assert_eq(uv.get_y(0), 0.5)
    }
  }
  match geometry.bounding_box {
    None => assert_eq(false, true)
    Some(box) => {
      assert_eq(box.min.x, 2.0)
      assert_eq(box.min.y, 2.0)
      assert_eq(box.max.z, 3.0)
    }
  }
  match geometry.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(sphere.center.x, 2.0)
      assert_eq(sphere.radius, 0.0)
    }
  }
}

///|
test "applyQuaternion yaws a position a right angle around Y" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute("position", @core.BufferAttribute::new([1.0, 0.0, 0.0], 3)),
  )
  let half = 0.7071067811865476
  let q = @math.Quaternion::new().set_from_axis_angle(
    @math.Vector3::new(y=1.0),
    @std.PI / 2.0,
  )
  let written = geometry.apply_quaternion(q)
  assert_eq(physical_equal(written, geometry), true)
  match geometry.get_attribute("position") {
    None => assert_eq(false, true)
    Some(position) => {
      assert_close(position.get_x(0), 0.0)
      assert_eq(position.get_y(0), 0.0)
      assert_close(position.get_z(0), -1.0)
    }
  }
  assert_eq(q.x, 0.0)
  assert_close(q.y, half)
  assert_eq(q.z, 0.0)
  assert_close(q.w, half)
}

///|
test "rotateX turns a position a right angle around X" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute("position", @core.BufferAttribute::new([0.0, 1.0, 0.0], 3)),
  )
  let written = geometry.rotate_x(@std.PI / 2.0)
  assert_eq(physical_equal(written, geometry), true)
  match geometry.get_attribute("position") {
    None => assert_eq(false, true)
    Some(position) => {
      assert_eq(position.get_x(0), 0.0)
      assert_close(position.get_y(0), 0.0)
      assert_close(position.get_z(0), 1.0)
    }
  }
}

///|
test "rotateY turns a position a right angle around Y" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute("position", @core.BufferAttribute::new([1.0, 0.0, 0.0], 3)),
  )
  let written = geometry.rotate_y(@std.PI / 2.0)
  assert_eq(physical_equal(written, geometry), true)
  match geometry.get_attribute("position") {
    None => assert_eq(false, true)
    Some(position) => {
      assert_close(position.get_x(0), 0.0)
      assert_eq(position.get_y(0), 0.0)
      assert_close(position.get_z(0), -1.0)
    }
  }
}

///|
test "rotateZ turns a position a right angle around Z" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute("position", @core.BufferAttribute::new([1.0, 0.0, 0.0], 3)),
  )
  let written = geometry.rotate_z(@std.PI / 2.0)
  assert_eq(physical_equal(written, geometry), true)
  match geometry.get_attribute("position") {
    None => assert_eq(false, true)
    Some(position) => {
      assert_close(position.get_x(0), 0.0)
      assert_close(position.get_y(0), 1.0)
      assert_eq(position.get_z(0), 0.0)
    }
  }
}

///|
test "translate moves a position by an offset" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute("position", @core.BufferAttribute::new([1.0, 2.0, 3.0], 3)),
  )
  let written = geometry.translate(10.0, 0.0, 0.0)
  assert_eq(physical_equal(written, geometry), true)
  match geometry.get_attribute("position") {
    None => assert_eq(false, true)
    Some(position) => {
      assert_eq(position.get_x(0), 11.0)
      assert_eq(position.get_y(0), 2.0)
      assert_eq(position.get_z(0), 3.0)
    }
  }
}

///|
test "scale multiplies a position" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute("position", @core.BufferAttribute::new([1.0, 2.0, 3.0], 3)),
  )
  let written = geometry.scale(2.0, 1.0, 1.0)
  assert_eq(physical_equal(written, geometry), true)
  match geometry.get_attribute("position") {
    None => assert_eq(false, true)
    Some(position) => {
      assert_eq(position.get_x(0), 2.0)
      assert_eq(position.get_y(0), 2.0)
      assert_eq(position.get_z(0), 3.0)
    }
  }
}

///|
test "lookAt turns local +Z toward the target" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute("position", @core.BufferAttribute::new([0.0, 0.0, 1.0], 3)),
  )
  let written = geometry.look_at(@math.Vector3::new(x=1.0))
  assert_eq(physical_equal(written, geometry), true)
  match geometry.get_attribute("position") {
    None => assert_eq(false, true)
    Some(position) => {
      assert_close(position.get_x(0), 1.0)
      assert_close(position.get_y(0), 0.0)
      assert_close(position.get_z(0), 0.0)
    }
  }
}

///|
test "center moves the bounding box center to the origin" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0, 2.0, 4.0, 6.0], 3),
    ),
  )
  let written = geometry.center()
  assert_eq(physical_equal(written, geometry), true)
  match geometry.get_attribute("position") {
    None => assert_eq(false, true)
    Some(position) => {
      assert_eq(position.get_x(0), -1.0)
      assert_eq(position.get_y(0), -2.0)
      assert_eq(position.get_z(0), -3.0)
      assert_eq(position.get_x(1), 1.0)
      assert_eq(position.get_y(1), 2.0)
      assert_eq(position.get_z(1), 3.0)
    }
  }
}

///|
test "setFromPoints writes a position attribute" {
  let geometry = @core.BufferGeometry::new()
  let points = [
    @math.Vector3::new(x=1.0, y=2.0, z=3.0),
    @math.Vector3::new(x=4.0, y=5.0, z=6.0),
  ]
  let written = geometry.set_from_points(points)
  assert_eq(physical_equal(written, geometry), true)
  match geometry.get_attribute("position") {
    None => assert_eq(false, true)
    Some(position) => {
      assert_eq(position.count, 2)
      assert_eq(position.get_x(0), 1.0)
      assert_eq(position.get_y(0), 2.0)
      assert_eq(position.get_z(0), 3.0)
      assert_eq(position.get_x(1), 4.0)
      assert_eq(position.get_y(1), 5.0)
      assert_eq(position.get_z(1), 6.0)
    }
  }
  let existing = @core.BufferGeometry::new()
  ignore(
    existing.set_attribute("position", @core.BufferAttribute::new([9.0, 9.0, 9.0], 3)),
  )
  ignore(existing.set_from_points(points))
  match existing.get_attribute("position") {
    None => assert_eq(false, true)
    Some(position) => {
      assert_eq(position.count, 1)
      assert_eq(position.get_x(0), 1.0)
      assert_eq(position.get_y(0), 2.0)
      assert_eq(position.get_z(0), 3.0)
    }
  }
}

///|
test "setXYZW writes four components" {
  let attribute = @core.BufferAttribute::new(
    [0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0],
    4,
  )
  let written = attribute.set_xyzw(1, 2.0, 3.0, 4.0, 5.0)
  assert_eq(physical_equal(written, attribute), true)
  assert_eq(attribute.get_x(0), 0.0)
  assert_eq(attribute.get_y(0), 0.0)
  assert_eq(attribute.get_z(0), 0.0)
  assert_eq(attribute.get_x(1), 2.0)
  assert_eq(attribute.get_y(1), 3.0)
  assert_eq(attribute.get_z(1), 4.0)
  assert_eq(attribute.get_component(1, 3), 5.0)
}

///|
test "computeTangents writes a +X tangent for an xy triangle" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0],
        3,
      ),
    ),
  )
  ignore(
    geometry.set_attribute(
      "normal",
      @core.BufferAttribute::new(
        [0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0],
        3,
      ),
    ),
  )
  ignore(
    geometry.set_attribute(
      "uv",
      @core.BufferAttribute::new([0.0, 0.0, 1.0, 0.0, 0.0, 1.0], 2),
    ),
  )
  ignore(geometry.set_index_array([0, 1, 2]))
  geometry.compute_tangents()
  match geometry.get_attribute("tangent") {
    None => assert_eq(false, true)
    Some(tangent) => {
      assert_eq(tangent.count, 3)
      let mut vertex = 0
      while vertex < 3 {
        assert_eq(tangent.get_x(vertex), 1.0)
        assert_eq(tangent.get_y(vertex), 0.0)
        assert_eq(tangent.get_z(vertex), 0.0)
        assert_eq(tangent.get_component(vertex, 3), 1.0)
        vertex = vertex + 1
      }
    }
  }
  let bare = @core.BufferGeometry::new()
  ignore(
    bare.set_attribute("position", @core.BufferAttribute::new([0.0, 0.0, 0.0], 3)),
  )
  bare.compute_tangents()
  assert_eq(bare.has_attribute("tangent"), false)
}

///|
test "normalizeNormals makes each normal unit length" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "normal",
      @core.BufferAttribute::new([2.0, 0.0, 0.0, 0.0, 3.0, 0.0], 3),
    ),
  )
  geometry.normalize_normals()
  match geometry.get_attribute("normal") {
    None => assert_eq(false, true)
    Some(normal) => {
      assert_eq(normal.get_x(0), 1.0)
      assert_eq(normal.get_y(0), 0.0)
      assert_eq(normal.get_z(0), 0.0)
      assert_eq(normal.get_x(1), 0.0)
      assert_eq(normal.get_y(1), 1.0)
      assert_eq(normal.get_z(1), 0.0)
    }
  }
}

///|
test "computeVertexNormals points an xy triangle along +Z" {
  let positions = [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0]
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute("position", @core.BufferAttribute::new(positions, 3)),
  )
  ignore(geometry.set_index_array([0, 1, 2]))
  geometry.compute_vertex_normals()
  match geometry.get_attribute("normal") {
    None => assert_eq(false, true)
    Some(normal) => {
      let mut vertex = 0
      while vertex < 3 {
        assert_eq(normal.get_x(vertex), 0.0)
        assert_eq(normal.get_y(vertex), 0.0)
        assert_eq(normal.get_z(vertex), 1.0)
        vertex = vertex + 1
      }
    }
  }
  let soup = @core.BufferGeometry::new()
  ignore(soup.set_attribute("position", @core.BufferAttribute::new(positions, 3)))
  soup.compute_vertex_normals()
  match soup.get_attribute("normal") {
    None => assert_eq(false, true)
    Some(normal) => {
      assert_eq(normal.get_z(0), 1.0)
      assert_eq(normal.get_z(2), 1.0)
    }
  }
}

///|
test "toNonIndexed expands vertices in index order" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0],
        3,
      ),
    ),
  )
  ignore(geometry.set_index_array([0, 2, 1]))
  geometry.add_group(0, 3, material_index=1)
  let expanded = geometry.to_non_indexed()
  assert_eq(physical_equal(expanded, geometry), false)
  match expanded.index {
    None => assert_eq(true, true)
    Some(_) => assert_eq(false, true)
  }
  match expanded.get_attribute("position") {
    None => assert_eq(false, true)
    Some(position) => {
      assert_eq(position.count, 3)
      assert_eq(position.get_x(0), 0.0)
      assert_eq(position.get_y(0), 0.0)
      assert_eq(position.get_z(0), 0.0)
      assert_eq(position.get_x(1), 0.0)
      assert_eq(position.get_y(1), 1.0)
      assert_eq(position.get_z(1), 0.0)
      assert_eq(position.get_x(2), 1.0)
      assert_eq(position.get_y(2), 0.0)
      assert_eq(position.get_z(2), 0.0)
    }
  }
  assert_eq(expanded.groups.length(), 1)
  assert_eq(expanded.groups[0].start, 0)
  assert_eq(expanded.groups[0].count, 3)
  assert_eq(expanded.groups[0].material_index, 1)
  let plain = @core.BufferGeometry::new()
  assert_eq(physical_equal(plain.to_non_indexed(), plain), true)
}

///|
test "toJSON records attributes, index, groups, and the bounding sphere" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute("position", @core.BufferAttribute::new([1.0, 2.0, 3.0], 3)),
  )
  ignore(geometry.set_index_array([0]))
  geometry.add_group(0, 3, material_index=1)
  geometry.bounding_sphere = Some(
    @math.Sphere::new(center=@math.Vector3::new(x=1.0, y=2.0, z=3.0), radius=4.0),
  )
  let data = geometry.to_json()
  assert_eq(data.version, 4.7)
  assert_eq(data.type_name, "BufferGeometry")
  assert_eq(data.generator, "BufferGeometry.toJSON")
  match data.index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, [0.0])
  }
  match data.attributes.get("position") {
    None => assert_eq(false, true)
    Some(position) => {
      assert_eq(position.item_size, 3)
      assert_eq(position.array, [1.0, 2.0, 3.0])
      position.array[0] = 9.0
    }
  }
  assert_eq(data.groups.length(), 1)
  assert_eq(data.groups[0].start, 0)
  assert_eq(data.groups[0].count, 3)
  assert_eq(data.groups[0].material_index, 1)
  match data.bounding_sphere {
    None => assert_eq(false, true)
    Some((center, radius)) => {
      assert_eq(center, [1.0, 2.0, 3.0])
      assert_eq(radius, 4.0)
    }
  }
  match geometry.get_attribute("position") {
    None => assert_eq(false, true)
    Some(position) => assert_eq(position.get_x(0), 1.0)
  }
}

///|
test "toJSON copies item size, values, and normalized" {
  let attribute = @core.BufferAttribute::new([1.0, 2.0, 3.0], 3, normalized=true)
  let data = attribute.to_json()
  assert_eq(data.item_size, 3)
  assert_eq(data.normalized, true)
  assert_eq(data.array, [1.0, 2.0, 3.0])
  data.array[0] = 9.0
  assert_eq(attribute.get_x(0), 1.0)
}

///|
test "copy replaces an attribute with an independent buffer" {
  let source = @core.BufferAttribute::new([1.0, 2.0, 3.0], 3, normalized=true)
  let destination = @core.BufferAttribute::new([9.0], 1)
  let written = destination.copy(source)
  assert_eq(physical_equal(written, destination), true)
  assert_eq(destination.item_size, 3)
  assert_eq(destination.count, 1)
  assert_eq(destination.normalized, true)
  assert_eq(destination.array, [1.0, 2.0, 3.0])
  destination.array[0] = 8.0
  assert_eq(source.get_x(0), 1.0)
}

///|
test "clone makes an independent attribute" {
  let source = @core.BufferAttribute::new([1.0, 2.0, 3.0], 3, normalized=true)
  let cloned = source.clone()
  assert_eq(physical_equal(cloned, source), false)
  assert_eq(cloned.item_size, 3)
  assert_eq(cloned.count, 1)
  assert_eq(cloned.normalized, true)
  assert_eq(cloned.array, [1.0, 2.0, 3.0])
  cloned.array[0] = 8.0
  assert_eq(source.get_x(0), 1.0)
}

///|
test "copyAt copies one vertex" {
  let source = @core.BufferAttribute::new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 3)
  let destination = @core.BufferAttribute::new([0.0, 0.0, 0.0, 9.0, 9.0, 9.0], 3)
  let written = destination.copy_at(1, source, 0)
  assert_eq(physical_equal(written, destination), true)
  assert_eq(destination.get_x(0), 0.0)
  assert_eq(destination.get_y(0), 0.0)
  assert_eq(destination.get_z(0), 0.0)
  assert_eq(destination.get_x(1), 1.0)
  assert_eq(destination.get_y(1), 2.0)
  assert_eq(destination.get_z(1), 3.0)
  assert_eq(source.get_x(0), 1.0)
}

///|
test "copyArray writes a prefix and leaves the tail" {
  let attribute = @core.BufferAttribute::new([0.0, 0.0, 0.0, 9.0], 1)
  let values = [1.0, 2.0, 3.0]
  let written = attribute.copy_array(values)
  assert_eq(physical_equal(written, attribute), true)
  assert_eq(attribute.array, [1.0, 2.0, 3.0, 9.0])
  values[0] = 8.0
  assert_eq(attribute.get_x(0), 1.0)
}

///|
test "set writes values at an offset" {
  let attribute = @core.BufferAttribute::new([0.0, 0.0, 0.0, 9.0], 1)
  let values = [1.0, 2.0]
  let written = attribute.set(values, offset=1)
  assert_eq(physical_equal(written, attribute), true)
  assert_eq(attribute.array, [0.0, 1.0, 2.0, 9.0])
  values[0] = 8.0
  assert_eq(attribute.get_x(1), 1.0)
}

///|
test "setComponent writes one channel" {
  let attribute = @core.BufferAttribute::new([1.0, 2.0, 3.0], 3)
  let written = attribute.set_component(0, 1, 9.0)
  assert_eq(physical_equal(written, attribute), true)
  assert_eq(attribute.get_x(0), 1.0)
  assert_eq(attribute.get_y(0), 9.0)
  assert_eq(attribute.get_z(0), 3.0)
}

///|
test "setX writes the x channel" {
  let attribute = @core.BufferAttribute::new([1.0, 2.0, 3.0], 3)
  let written = attribute.set_x(0, 9.0)
  assert_eq(physical_equal(written, attribute), true)
  assert_eq(attribute.get_x(0), 9.0)
  assert_eq(attribute.get_y(0), 2.0)
  assert_eq(attribute.get_z(0), 3.0)
}

///|
test "setY writes the y channel" {
  let attribute = @core.BufferAttribute::new([1.0, 2.0, 3.0], 3)
  let written = attribute.set_y(0, 9.0)
  assert_eq(physical_equal(written, attribute), true)
  assert_eq(attribute.get_x(0), 1.0)
  assert_eq(attribute.get_y(0), 9.0)
  assert_eq(attribute.get_z(0), 3.0)
}

///|
test "setZ writes the z channel" {
  let attribute = @core.BufferAttribute::new([1.0, 2.0, 3.0], 3)
  let written = attribute.set_z(0, 9.0)
  assert_eq(physical_equal(written, attribute), true)
  assert_eq(attribute.get_x(0), 1.0)
  assert_eq(attribute.get_y(0), 2.0)
  assert_eq(attribute.get_z(0), 9.0)
}

///|
test "getW reads the fourth channel" {
  let attribute = @core.BufferAttribute::new([1.0, 2.0, 3.0, 4.0], 4)
  assert_eq(attribute.get_w(0), 4.0)
}

///|
test "setW writes the w channel" {
  let attribute = @core.BufferAttribute::new([1.0, 2.0, 3.0, 4.0], 4)
  let written = attribute.set_w(0, 9.0)
  assert_eq(physical_equal(written, attribute), true)
  assert_eq(attribute.get_x(0), 1.0)
  assert_eq(attribute.get_y(0), 2.0)
  assert_eq(attribute.get_z(0), 3.0)
  assert_eq(attribute.get_w(0), 9.0)
}

///|
test "setXY writes x and y and leaves z" {
  let attribute = @core.BufferAttribute::new([0.0, 0.0, 0.0], 3)
  let written = attribute.set_xy(0, 1.0, 2.0)
  assert_eq(physical_equal(written, attribute), true)
  assert_eq(attribute.get_x(0), 1.0)
  assert_eq(attribute.get_y(0), 2.0)
  assert_eq(attribute.get_z(0), 0.0)
}

///|
test "needsUpdate increments version only when true" {
  let attribute = @core.BufferAttribute::new([1.0, 2.0, 3.0], 3)
  assert_eq(attribute.version, 0)
  attribute.set_needs_update(false)
  assert_eq(attribute.version, 0)
  attribute.set_needs_update(true)
  attribute.set_needs_update(true)
  assert_eq(attribute.version, 2)
}

///|
test "setUsage switches static draw to dynamic draw" {
  let attribute = @core.BufferAttribute::new([1.0], 1)
  assert_eq(attribute.usage, @constants.STATIC_DRAW_USAGE)
  assert_eq(attribute.usage, 35044)
  let written = attribute.set_usage(@constants.DYNAMIC_DRAW_USAGE)
  assert_eq(physical_equal(written, attribute), true)
  assert_eq(attribute.usage, 35048)
  let destination = @core.BufferAttribute::new([0.0], 1)
  ignore(destination.copy(attribute))
  assert_eq(destination.usage, 35048)
}

///|
test "addUpdateRange records a component span" {
  let attribute = @core.BufferAttribute::new([1.0, 2.0, 3.0, 4.0], 1)
  assert_eq(attribute.update_ranges.length(), 0)
  attribute.add_update_range(1, 2)
  assert_eq(attribute.update_ranges.length(), 1)
  assert_eq(attribute.update_ranges[0].start, 1)
  assert_eq(attribute.update_ranges[0].count, 2)
}

///|
test "clearUpdateRanges drops every recorded span" {
  let attribute = @core.BufferAttribute::new([1.0, 2.0, 3.0, 4.0], 1)
  attribute.add_update_range(1, 2)
  attribute.clear_update_ranges()
  assert_eq(attribute.update_ranges.length(), 0)
}

///|
test "onUpload stores a callback that runs once" {
  let attribute = @core.BufferAttribute::new([1.0], 1)
  let hits = Ref::Ref(0)
  let written = attribute.on_upload(fn() { hits.val = hits.val + 1 })
  assert_eq(physical_equal(written, attribute), true)
  match attribute.on_upload_callback {
    None => assert_eq(false, true)
    Some(callback) => callback()
  }
  assert_eq(hits.val, 1)
}

///|
test "addEventListener keeps one copy of a listener" {
  let attribute = @core.BufferAttribute::new([1.0], 1)
  let listener = fn() {}
  attribute.add_event_listener("dispose", listener)
  attribute.add_event_listener("dispose", listener)
  match attribute.listeners.get("dispose") {
    None => assert_eq(false, true)
    Some(listeners) => assert_eq(listeners.length(), 1)
  }
}

///|
test "hasEventListener reports a registered listener" {
  let attribute = @core.BufferAttribute::new([1.0], 1)
  let listener = fn() {}
  assert_eq(attribute.has_event_listener("dispose", listener), false)
  attribute.add_event_listener("dispose", listener)
  assert_eq(attribute.has_event_listener("dispose", listener), true)
}

///|
test "removeEventListener drops a registered listener" {
  let attribute = @core.BufferAttribute::new([1.0], 1)
  let listener = fn() {}
  attribute.add_event_listener("dispose", listener)
  attribute.remove_event_listener("dispose", listener)
  assert_eq(attribute.has_event_listener("dispose", listener), false)
}

///|
test "dispatchEvent runs listeners of one kind" {
  let attribute = @core.BufferAttribute::new([1.0], 1)
  let hits = Ref::Ref(0)
  attribute.add_event_listener("change", fn() { hits.val = hits.val + 1 })
  attribute.add_event_listener("dispose", fn() { hits.val = hits.val + 10 })
  attribute.dispatch_event("change")
  assert_eq(hits.val, 1)
}

///|
test "dispose runs only dispose listeners" {
  let attribute = @core.BufferAttribute::new([1.0], 1)
  let hits = Ref::Ref(0)
  attribute.add_event_listener("dispose", fn() { hits.val = hits.val + 1 })
  attribute.add_event_listener("other", fn() { hits.val = hits.val + 10 })
  attribute.dispose()
  assert_eq(hits.val, 1)
}

///|
test "copy replaces a geometry with independent data" {
  let source = @core.BufferGeometry::new()
  ignore(
    source.set_attribute("position", @core.BufferAttribute::new([1.0, 2.0, 3.0], 3)),
  )
  ignore(source.set_index_array([0]))
  source.add_group(0, 3, material_index=1)
  source.bounding_sphere = Some(
    @math.Sphere::new(center=@math.Vector3::new(x=1.0, y=2.0, z=3.0), radius=4.0),
  )
  source.set_draw_range(2.0, 4.0)
  let destination = @core.BufferGeometry::new()
  ignore(
    destination.set_attribute("uv", @core.BufferAttribute::new([9.0, 9.0], 2)),
  )
  let written = destination.copy(source)
  assert_eq(physical_equal(written, destination), true)
  assert_eq(destination.has_attribute("uv"), false)
  match destination.get_attribute("position") {
    None => assert_eq(false, true)
    Some(position) => {
      assert_eq(position.get_x(0), 1.0)
      assert_eq(position.get_y(0), 2.0)
      assert_eq(position.get_z(0), 3.0)
      position.array[0] = 8.0
    }
  }
  match destination.index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index.get_x(0), 0.0)
  }
  assert_eq(destination.groups.length(), 1)
  assert_eq(destination.groups[0].material_index, 1)
  match destination.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => assert_eq(sphere.radius, 4.0)
  }
  assert_eq(destination.draw_range.start, 2.0)
  assert_eq(destination.draw_range.count, 4.0)
  match source.get_attribute("position") {
    None => assert_eq(false, true)
    Some(position) => assert_eq(position.get_x(0), 1.0)
  }
}

///|
test "clone copies tangent, groups, and draw range" {
  let source = @core.BufferGeometry::new()
  ignore(
    source.set_attribute(
      "tangent",
      @core.BufferAttribute::new([1.0, 0.0, 0.0, 1.0], 4),
    ),
  )
  ignore(source.set_index_array([0]))
  source.add_group(0, 3, material_index=1)
  source.set_draw_range(2.0, 4.0)
  let cloned = source.clone()
  assert_eq(physical_equal(cloned, source), false)
  match cloned.get_attribute("tangent") {
    None => assert_eq(false, true)
    Some(tangent) => {
      assert_eq(tangent.get_x(0), 1.0)
      assert_eq(tangent.get_w(0), 1.0)
      tangent.array[0] = 8.0
    }
  }
  match source.get_attribute("tangent") {
    None => assert_eq(false, true)
    Some(tangent) => assert_eq(tangent.get_x(0), 1.0)
  }
  assert_eq(cloned.groups.length(), 1)
  assert_eq(cloned.groups[0].material_index, 1)
  assert_eq(cloned.draw_range.start, 2.0)
  assert_eq(cloned.draw_range.count, 4.0)
  match cloned.index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index.get_x(0), 0.0)
  }
}

///|
test "addEventListener keeps one copy of a geometry listener" {
  let geometry = @core.BufferGeometry::new()
  let listener = fn() {}
  geometry.add_event_listener("dispose", listener)
  geometry.add_event_listener("dispose", listener)
  match geometry.listeners.get("dispose") {
    None => assert_eq(false, true)
    Some(listeners) => assert_eq(listeners.length(), 1)
  }
}

///|
test "hasEventListener reports a registered geometry listener" {
  let geometry = @core.BufferGeometry::new()
  let listener = fn() {}
  assert_eq(geometry.has_event_listener("dispose", listener), false)
  geometry.add_event_listener("dispose", listener)
  assert_eq(geometry.has_event_listener("dispose", listener), true)
}

///|
test "removeEventListener drops a registered geometry listener" {
  let geometry = @core.BufferGeometry::new()
  let listener = fn() {}
  geometry.add_event_listener("dispose", listener)
  geometry.remove_event_listener("dispose", listener)
  assert_eq(geometry.has_event_listener("dispose", listener), false)
}

///|
test "dispatchEvent runs geometry listeners of one kind" {
  let geometry = @core.BufferGeometry::new()
  let hits = Ref::Ref(0)
  geometry.add_event_listener("change", fn() { hits.val = hits.val + 1 })
  geometry.add_event_listener("dispose", fn() { hits.val = hits.val + 10 })
  geometry.dispatch_event("change")
  assert_eq(hits.val, 1)
}

///|
test "dispose runs only geometry dispose listeners" {
  let geometry = @core.BufferGeometry::new()
  let hits = Ref::Ref(0)
  geometry.add_event_listener("dispose", fn() { hits.val = hits.val + 1 })
  geometry.add_event_listener("other", fn() { hits.val = hits.val + 10 })
  geometry.dispose()
  assert_eq(hits.val, 1)
}

///|
test "id counts attributes and stays on the destination" {
  let first = @core.BufferAttribute::new([1.0], 1)
  let second = @core.BufferAttribute::new([2.0], 1)
  assert_eq(second.id, first.id + 1)
  let destination = @core.BufferAttribute::new([9.0], 1)
  let kept = destination.id
  ignore(destination.copy(first))
  assert_eq(destination.id, kept)
  assert_eq(destination.id == first.id, false)
}

///|
test "name starts empty and copy carries it" {
  let source = @core.BufferAttribute::new([1.0], 1)
  assert_eq(source.name, "")
  source.name = "tangent"
  let destination = @core.BufferAttribute::new([9.0], 1)
  destination.name = "old"
  ignore(destination.copy(source))
  assert_eq(destination.name, "tangent")
}

///|
test "gpuType defaults to float and copy carries int" {
  let source = @core.BufferAttribute::new([1.0], 1)
  assert_eq(source.gpu_type, @constants.FLOAT_TYPE)
  assert_eq(source.gpu_type, 1015)
  source.gpu_type = @constants.INT_TYPE
  let destination = @core.BufferAttribute::new([9.0], 1)
  ignore(destination.copy(source))
  assert_eq(destination.gpu_type, 1013)
}

///|
test "id counts geometries and stays on the destination" {
  let first = @core.BufferGeometry::new()
  let second = @core.BufferGeometry::new()
  assert_eq(second.id, first.id + 1)
  let destination = @core.BufferGeometry::new()
  let kept = destination.id
  ignore(destination.copy(first))
  assert_eq(destination.id, kept)
  assert_eq(destination.id == first.id, false)
}

///|
test "uuid is a version-4 id that copy keeps" {
  let source = @core.BufferGeometry::new()
  assert_eq(source.uuid.length(), 36)
  assert_eq(source.uuid[14:15].to_owned(), "4")
  let destination = @core.BufferGeometry::new()
  let kept = destination.uuid
  ignore(destination.copy(source))
  assert_eq(destination.uuid, kept)
}

///|
test "name starts empty and copy carries the geometry name" {
  let source = @core.BufferGeometry::new()
  assert_eq(source.name, "")
  source.name = "square"
  let destination = @core.BufferGeometry::new()
  destination.name = "old"
  ignore(destination.copy(source))
  assert_eq(destination.name, "square")
}

///|
test "type stays BufferGeometry and copy keeps the destination type" {
  let source = @core.BufferGeometry::new()
  assert_eq(source.type_name, "BufferGeometry")
  source.type_name = "BoxGeometry"
  let destination = @core.BufferGeometry::new()
  destination.type_name = "SphereGeometry"
  ignore(destination.copy(source))
  assert_eq(destination.type_name, "SphereGeometry")
  assert_eq(source.type_name, "BoxGeometry")
}

///|
test "setIndirect stores an attribute at a byte offset" {
  let geometry = @core.BufferGeometry::new()
  match geometry.indirect {
    None => ()
    Some(_) => assert_eq(false, true)
  }
  assert_eq(geometry.indirect_offset, 0)
  let attribute = @core.BufferAttribute::new([1.0, 2.0, 3.0, 4.0, 5.0], 5)
  let written = geometry.set_indirect(attribute, offset=16)
  assert_eq(physical_equal(written, geometry), true)
  match geometry.indirect {
    None => assert_eq(false, true)
    Some(stored) => assert_eq(stored.get_x(0), 1.0)
  }
  assert_eq(geometry.indirect_offset, 16)
}

///|
test "getIndirect returns the stored attribute" {
  let geometry = @core.BufferGeometry::new()
  match geometry.get_indirect() {
    None => ()
    Some(_) => assert_eq(false, true)
  }
  let attribute = @core.BufferAttribute::new([1.0, 2.0, 3.0, 4.0, 5.0], 5)
  ignore(geometry.set_indirect(attribute, offset=16))
  match geometry.get_indirect() {
    None => assert_eq(false, true)
    Some(stored) => {
      assert_eq(physical_equal(stored, attribute), true)
      assert_eq(stored.get_x(0), 1.0)
    }
  }
}

///|
test "morphAttributes copy a position target" {
  let source = @core.BufferGeometry::new()
  match source.morph_attributes.get("position") {
    None => ()
    Some(_) => assert_eq(false, true)
  }
  source.morph_attributes.set(
    "position",
    [@core.BufferAttribute::new([1.0, 2.0, 3.0], 3)],
  )
  let destination = @core.BufferGeometry::new()
  destination.morph_attributes.set(
    "normal",
    [@core.BufferAttribute::new([9.0, 9.0, 9.0], 3)],
  )
  ignore(destination.copy(source))
  match destination.morph_attributes.get("normal") {
    None => ()
    Some(_) => assert_eq(false, true)
  }
  match destination.morph_attributes.get("position") {
    None => assert_eq(false, true)
    Some(attributes) => {
      assert_eq(attributes.length(), 1)
      assert_eq(attributes[0].get_x(0), 1.0)
      attributes[0].array[0] = 8.0
    }
  }
  match source.morph_attributes.get("position") {
    None => assert_eq(false, true)
    Some(attributes) => assert_eq(attributes[0].get_x(0), 1.0)
  }
}

///|
test "morphTargetsRelative defaults to false and copy carries it" {
  let source = @core.BufferGeometry::new()
  assert_eq(source.morph_targets_relative, false)
  source.morph_targets_relative = true
  let destination = @core.BufferGeometry::new()
  ignore(destination.copy(source))
  assert_eq(destination.morph_targets_relative, true)
}

///|
test "userData starts empty and copy shares the map" {
  let source = @core.BufferGeometry::new()
  match source.user_data.get("label") {
    None => ()
    Some(_) => assert_eq(false, true)
  }
  source.user_data.set("label", "square")
  let destination = @core.BufferGeometry::new()
  ignore(destination.copy(source))
  match destination.user_data.get("label") {
    None => assert_eq(false, true)
    Some(label) => assert_eq(label, "square")
  }
  destination.user_data.set("label", "cube")
  match source.user_data.get("label") {
    None => assert_eq(false, true)
    Some(label) => assert_eq(label, "cube")
  }
}

///|
test "transformed starts false and applyMatrix4 sets it" {
  let source = @core.BufferGeometry::new()
  assert_eq(source.transformed, false)
  ignore(source.apply_matrix4(@math.Matrix4::new()))
  assert_eq(source.transformed, true)
  let destination = @core.BufferGeometry::new()
  ignore(destination.copy(source))
  assert_eq(destination.transformed, true)
}

///|
test "getIndex returns the stored index" {
  let geometry = @core.BufferGeometry::new()
  match geometry.get_index() {
    None => ()
    Some(_) => assert_eq(false, true)
  }
  ignore(geometry.set_index_array([0]))
  match geometry.get_index() {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index.get_x(0), 0.0)
  }
}

///|
test "toJSON writes name, usage, and gpuType" {
  let attribute = @core.BufferAttribute::new([1.0, 2.0, 3.0], 3)
  attribute.name = "tangent"
  ignore(attribute.set_usage(@constants.DYNAMIC_DRAW_USAGE))
  attribute.gpu_type = @constants.INT_TYPE
  let data = attribute.to_json()
  assert_eq(data.name, "tangent")
  assert_eq(data.usage, 35048)
  assert_eq(data.gpu_type, 1013)
}

///|
test "toJSON writes uuid, name, type, and userData" {
  let geometry = @core.BufferGeometry::new()
  geometry.name = "square"
  geometry.type_name = "BoxGeometry"
  let bare = geometry.to_json()
  assert_eq(bare.uuid, geometry.uuid)
  assert_eq(bare.uuid.length(), 36)
  assert_eq(bare.name, "square")
  assert_eq(bare.geometry_type, "BoxGeometry")
  assert_eq(bare.type_name, "BufferGeometry")
  match bare.user_data {
    None => ()
    Some(_) => assert_eq(false, true)
  }
  geometry.user_data.set("label", "square")
  let data = geometry.to_json()
  match data.user_data {
    None => assert_eq(false, true)
    Some(user_data) =>
      match user_data.get("label") {
        None => assert_eq(false, true)
        Some(label) => assert_eq(label, "square")
      }
  }
}

///|
test "applyMatrix4 marks position, normal, and tangent for update" {
  let geometry = @core.BufferGeometry::new()
  let position = @core.BufferAttribute::new([1.0, 0.0, 0.0], 3)
  let normal = @core.BufferAttribute::new([0.0, 1.0, 0.0], 3)
  let tangent = @core.BufferAttribute::new([1.0, 0.0, 0.0, 1.0], 4)
  let uv = @core.BufferAttribute::new([0.0, 0.0], 2)
  ignore(geometry.set_attribute("position", position))
  ignore(geometry.set_attribute("normal", normal))
  ignore(geometry.set_attribute("tangent", tangent))
  ignore(geometry.set_attribute("uv", uv))
  assert_eq(position.version, 0)
  ignore(geometry.apply_matrix4(@math.Matrix4::new()))
  assert_eq(position.version, 1)
  assert_eq(normal.version, 1)
  assert_eq(tangent.version, 1)
  assert_eq(uv.version, 0)
}

///|
test "computeBoundingBox includes morph positions" {
  let absolute = @core.BufferGeometry::new()
  ignore(
    absolute.set_attribute("position", @core.BufferAttribute::new([0.0, 0.0, 0.0], 3)),
  )
  absolute.morph_attributes.set(
    "position",
    [@core.BufferAttribute::new([2.0, 0.0, 0.0], 3)],
  )
  absolute.compute_bounding_box()
  match absolute.bounding_box {
    None => assert_eq(false, true)
    Some(box) => {
      assert_eq(box.min.x, 0.0)
      assert_eq(box.max.x, 2.0)
    }
  }
  let relative = @core.BufferGeometry::new()
  ignore(
    relative.set_attribute("position", @core.BufferAttribute::new([1.0, 0.0, 0.0], 3)),
  )
  relative.morph_attributes.set(
    "position",
    [@core.BufferAttribute::new([2.0, 0.0, 0.0], 3)],
  )
  relative.morph_targets_relative = true
  relative.compute_bounding_box()
  match relative.bounding_box {
    None => assert_eq(false, true)
    Some(box) => assert_eq(box.max.x, 5.0)
  }
}

///|
test "computeBoundingSphere includes morph positions" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute("position", @core.BufferAttribute::new([1.0, 1.0, 0.0], 3)),
  )
  geometry.morph_attributes.set(
    "position",
    [
      @core.BufferAttribute::new([0.0, 0.0, 0.0], 3),
      @core.BufferAttribute::new([2.0, 2.0, 0.0], 3),
    ],
  )
  geometry.compute_bounding_sphere()
  match geometry.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => assert_eq(sphere.radius, 2.0.sqrt())
  }
}

///|
test "toNonIndexed expands morph attributes" {
  let geometry = @core.BufferGeometry::new()
  ignore(geometry.set_index_array([0, 2, 1]))
  geometry.morph_attributes.set(
    "position",
    [@core.BufferAttribute::new([4.0, 5.0, 6.0], 1)],
  )
  geometry.morph_targets_relative = true
  let expanded = geometry.to_non_indexed()
  assert_eq(expanded.morph_targets_relative, true)
  match expanded.morph_attributes.get("position") {
    None => assert_eq(false, true)
    Some(morphs) => {
      assert_eq(morphs.length(), 1)
      assert_eq(morphs[0].get_x(0), 4.0)
      assert_eq(morphs[0].get_x(1), 6.0)
      assert_eq(morphs[0].get_x(2), 5.0)
    }
  }
  match geometry.morph_attributes.get("position") {
    None => assert_eq(false, true)
    Some(morphs) => assert_eq(morphs[0].get_x(1), 5.0)
  }
}

///|
test "toJSON writes morph attributes" {
  let bare = @core.BufferGeometry::new()
  match bare.to_json().morph_attributes {
    None => ()
    Some(_) => assert_eq(false, true)
  }
  let geometry = @core.BufferGeometry::new()
  geometry.morph_attributes.set(
    "position",
    [@core.BufferAttribute::new([1.0, 2.0, 3.0], 3)],
  )
  geometry.morph_targets_relative = true
  let data = geometry.to_json()
  match data.morph_targets_relative {
    None => assert_eq(false, true)
    Some(relative) => assert_eq(relative, true)
  }
  match data.morph_attributes {
    None => assert_eq(false, true)
    Some(morphs) =>
      match morphs.get("position") {
        None => assert_eq(false, true)
        Some(attributes) => {
          assert_eq(attributes.length(), 1)
          assert_eq(attributes[0].array, [1.0, 2.0, 3.0])
        }
      }
  }
}

///|
test "setIndirect stores several byte offsets" {
  let geometry = @core.BufferGeometry::new()
  let attribute = @core.BufferAttribute::new([1.0, 2.0, 3.0, 4.0, 5.0], 5)
  let offsets = [8, 24]
  let written = geometry.set_indirect_offsets(attribute, offsets)
  assert_eq(physical_equal(written, geometry), true)
  offsets[0] = 1
  match geometry.indirect_offsets {
    None => assert_eq(false, true)
    Some(stored) => {
      assert_eq(stored.length(), 2)
      assert_eq(stored[0], 8)
      assert_eq(stored[1], 24)
    }
  }
  match geometry.get_indirect() {
    None => assert_eq(false, true)
    Some(stored) => assert_eq(stored.get_x(0), 1.0)
  }
}

///|
test "update advances the timer delta" {
  let timer = @core.Timer::new()
  let written = timer.update(1000.0)
  assert_eq(physical_equal(written, timer), true)
  assert_eq(timer.get_delta(), 1.0)
  ignore(timer.update(2500.0))
  assert_eq(timer.get_delta(), 1.5)
}

///|
test "getElapsed accumulates timer updates" {
  let timer = @core.Timer::new()
  ignore(timer.update(1000.0))
  assert_eq(timer.get_elapsed(), 1.0)
  ignore(timer.update(2500.0))
  assert_eq(timer.get_elapsed(), 2.5)
}

///|
test "getTimescale starts at one" {
  let timer = @core.Timer::new()
  assert_eq(timer.get_timescale(), 1.0)
}

///|
test "setTimescale scales the next delta" {
  let timer = @core.Timer::new()
  let written = timer.set_timescale(2.0)
  assert_eq(physical_equal(written, timer), true)
  assert_eq(timer.get_timescale(), 2.0)
  ignore(timer.update(1000.0))
  assert_eq(timer.get_delta(), 2.0)
}

///|
test "reset skips the gap before the next update" {
  let timer = @core.Timer::new()
  ignore(timer.update(1000.0))
  let written = timer.reset(4000.0)
  assert_eq(physical_equal(written, timer), true)
  ignore(timer.update(5000.0))
  assert_eq(timer.get_delta(), 1.0)
}

///|
test "meshPerAttribute defaults to one and copy carries it" {
  let plain = @core.BufferAttribute::new([1.0], 1)
  assert_eq(plain.mesh_per_attribute, 1)
  let source = @core.BufferAttribute::new([1.0], 1, mesh_per_attribute=2)
  assert_eq(source.mesh_per_attribute, 2)
  let destination = @core.BufferAttribute::new([9.0], 1)
  ignore(destination.copy(source))
  assert_eq(destination.mesh_per_attribute, 2)
}

///|
test "toJSON writes meshPerAttribute when the repeat count is not one" {
  let plain = @core.BufferAttribute::new([1.0], 1).to_json()
  match plain.mesh_per_attribute {
    None => ()
    Some(_) => assert_eq(false, true)
  }
  match plain.is_instanced_buffer_attribute {
    None => ()
    Some(_) => assert_eq(false, true)
  }
  let data = @core.BufferAttribute::new([1.0], 1, mesh_per_attribute=2).to_json()
  match data.mesh_per_attribute {
    None => assert_eq(false, true)
    Some(count) => assert_eq(count, 2)
  }
  match data.is_instanced_buffer_attribute {
    None => assert_eq(false, true)
    Some(flag) => assert_eq(flag, true)
  }
}

///|
test "instanceCount defaults to infinity and copy carries it" {
  let geometry = @core.BufferGeometry::new()
  assert_eq(geometry.instance_count.is_inf(), true)
  assert_eq(geometry.instance_count > 0.0, true)
  geometry.instance_count = 4.0
  let destination = @core.BufferGeometry::new()
  ignore(destination.copy(geometry))
  assert_eq(destination.instance_count, 4.0)
  assert_eq(geometry.instance_count, 4.0)
}

///|
test "toJSON writes instanceCount when it is finite" {
  let plain = @core.BufferGeometry::new().to_json()
  match plain.instance_count {
    None => ()
    Some(_) => assert_eq(false, true)
  }
  match plain.is_instanced_buffer_geometry {
    None => ()
    Some(_) => assert_eq(false, true)
  }
  let geometry = @core.BufferGeometry::new()
  geometry.instance_count = 4.0
  let data = geometry.to_json()
  match data.instance_count {
    None => assert_eq(false, true)
    Some(count) => assert_eq(count, 4.0)
  }
  match data.is_instanced_buffer_geometry {
    None => assert_eq(false, true)
    Some(flag) => assert_eq(flag, true)
  }
}

///|
test "InterleavedBuffer count is the array length divided by stride" {
  let buffer = @core.InterleavedBuffer::new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 3)
  assert_eq(buffer.stride, 3)
  assert_eq(buffer.count, 2)
  assert_eq(buffer.array[0], 1.0)
  assert_eq(buffer.array[5], 6.0)
}

///|
test "setUsage stores DynamicDrawUsage on an interleaved buffer" {
  let buffer = @core.InterleavedBuffer::new([1.0, 2.0, 3.0], 3)
  assert_eq(buffer.usage, 35044)
  let written = buffer.set_usage(@constants.DYNAMIC_DRAW_USAGE)
  assert_eq(physical_equal(written, buffer), true)
  assert_eq(buffer.usage, 35048)
}

///|
test "addUpdateRange stores one span on an interleaved buffer" {
  let buffer = @core.InterleavedBuffer::new([1.0, 2.0, 3.0], 3)
  assert_eq(buffer.update_ranges.length(), 0)
  buffer.add_update_range(1, 2)
  assert_eq(buffer.update_ranges.length(), 1)
  assert_eq(buffer.update_ranges[0].start, 1)
  assert_eq(buffer.update_ranges[0].count, 2)
}

///|
test "clearUpdateRanges drops the span on an interleaved buffer" {
  let buffer = @core.InterleavedBuffer::new([1.0, 2.0, 3.0], 3)
  buffer.add_update_range(1, 2)
  buffer.clear_update_ranges()
  assert_eq(buffer.update_ranges.length(), 0)
}

///|
test "copy replaces an interleaved buffer" {
  let source = @core.InterleavedBuffer::new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 3)
  ignore(source.set_usage(@constants.DYNAMIC_DRAW_USAGE))
  let destination = @core.InterleavedBuffer::new([9.0], 1)
  destination.add_update_range(1, 2)
  let written = destination.copy(source)
  assert_eq(physical_equal(written, destination), true)
  assert_eq(destination.stride, 3)
  assert_eq(destination.count, 2)
  assert_eq(destination.usage, 35048)
  assert_eq(destination.array[0], 1.0)
  assert_eq(destination.array[5], 6.0)
  assert_eq(destination.update_ranges.length(), 1)
  destination.array[0] = 8.0
  assert_eq(source.array[0], 1.0)
}

///|
test "copyAt writes one interleaved vertex" {
  let source = @core.InterleavedBuffer::new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 3)
  let destination = @core.InterleavedBuffer::new([0.0, 0.0, 0.0, 9.0, 9.0, 9.0], 3)
  let written = destination.copy_at(1, source, 0)
  assert_eq(physical_equal(written, destination), true)
  assert_eq(destination.array[0], 0.0)
  assert_eq(destination.array[3], 1.0)
  assert_eq(destination.array[4], 2.0)
  assert_eq(destination.array[5], 3.0)
  assert_eq(source.array[0], 1.0)
}

///|
test "set writes an interleaved buffer at an offset" {
  let buffer = @core.InterleavedBuffer::new([0.0, 0.0, 0.0, 9.0], 1)
  let written = buffer.set([1.0, 2.0], offset=1)
  assert_eq(physical_equal(written, buffer), true)
  assert_eq(buffer.array[0], 0.0)
  assert_eq(buffer.array[1], 1.0)
  assert_eq(buffer.array[2], 2.0)
  assert_eq(buffer.array[3], 9.0)
}

///|
test "clone copies an interleaved buffer into a new object" {
  let source = @core.InterleavedBuffer::new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 3)
  ignore(source.set_usage(@constants.DYNAMIC_DRAW_USAGE))
  source.add_update_range(1, 2)
  let cloned = source.clone()
  assert_eq(physical_equal(cloned, source), false)
  assert_eq(cloned.stride, 3)
  assert_eq(cloned.count, 2)
  assert_eq(cloned.usage, 35048)
  assert_eq(cloned.array[0], 1.0)
  assert_eq(cloned.array[5], 6.0)
  assert_eq(cloned.update_ranges.length(), 0)
  cloned.array[0] = 8.0
  assert_eq(source.array[0], 1.0)
}

///|
test "onUpload stores a callback on an interleaved buffer" {
  let buffer = @core.InterleavedBuffer::new([1.0], 1)
  let hits = Ref::Ref(0)
  let written = buffer.on_upload(fn() { hits.val = hits.val + 1 })
  assert_eq(physical_equal(written, buffer), true)
  match buffer.on_upload_callback {
    None => assert_eq(false, true)
    Some(callback) => callback()
  }
  assert_eq(hits.val, 1)
}

///|
test "needsUpdate increments an interleaved buffer version only when true" {
  let buffer = @core.InterleavedBuffer::new([1.0, 2.0, 3.0], 3)
  assert_eq(buffer.version, 0)
  buffer.set_needs_update(false)
  assert_eq(buffer.version, 0)
  buffer.set_needs_update(true)
  buffer.set_needs_update(true)
  assert_eq(buffer.version, 2)
}

///|
test "uuid is a version-4 id that interleaved copy keeps" {
  let source = @core.InterleavedBuffer::new([1.0, 2.0, 3.0], 3)
  assert_eq(source.uuid.length(), 36)
  assert_eq(source.uuid[14:15].to_owned(), "4")
  let destination = @core.InterleavedBuffer::new([9.0], 1)
  let kept = destination.uuid
  ignore(destination.copy(source))
  assert_eq(destination.uuid, kept)
}

///|
test "toJSON writes an interleaved buffer" {
  let buffer = @core.InterleavedBuffer::new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 3)
  ignore(buffer.set_usage(@constants.DYNAMIC_DRAW_USAGE))
  let data = buffer.to_json()
  assert_eq(data.uuid, buffer.uuid)
  assert_eq(data.stride, 3)
  assert_eq(data.usage, 35048)
  assert_eq(data.array[0], 1.0)
  assert_eq(data.array[5], 6.0)
  data.array[0] = 8.0
  assert_eq(buffer.array[0], 1.0)
}

///|
test "InterleavedBufferAttribute count comes from its buffer" {
  let buffer = @core.InterleavedBuffer::new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 3)
  let attribute = @core.InterleavedBufferAttribute::new(buffer, 2, 1)
  assert_eq(attribute.name, "")
  assert_eq(attribute.item_size, 2)
  assert_eq(attribute.offset, 1)
  assert_eq(attribute.normalized, false)
  assert_eq(attribute.count(), 2)
  assert_eq(attribute.data.array[1], 2.0)
}

///|
test "array returns the interleaved storage" {
  let buffer = @core.InterleavedBuffer::new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 3)
  let attribute = @core.InterleavedBufferAttribute::new(buffer, 2, 1)
  assert_eq(attribute.array()[1], 2.0)
  attribute.array()[1] = 8.0
  assert_eq(buffer.array[1], 8.0)
}

///|
test "needsUpdate increments the interleaved attribute buffer version" {
  let buffer = @core.InterleavedBuffer::new([1.0, 2.0, 3.0], 3)
  let attribute = @core.InterleavedBufferAttribute::new(buffer, 3, 0)
  assert_eq(attribute.data.version, 0)
  attribute.set_needs_update(false)
  assert_eq(attribute.data.version, 0)
  attribute.set_needs_update(true)
  attribute.set_needs_update(true)
  assert_eq(attribute.data.version, 2)
}

///|
test "getX reads an interleaved component" {
  let buffer = @core.InterleavedBuffer::new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 3)
  let attribute = @core.InterleavedBufferAttribute::new(buffer, 3, 0)
  assert_eq(attribute.get_x(1), 4.0)
  let shifted = @core.InterleavedBufferAttribute::new(buffer, 1, 1)
  assert_eq(shifted.get_x(0), 2.0)
}

///|
test "getY reads an interleaved component" {
  let buffer = @core.InterleavedBuffer::new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 3)
  let attribute = @core.InterleavedBufferAttribute::new(buffer, 3, 0)
  assert_eq(attribute.get_y(1), 5.0)
  let shifted = @core.InterleavedBufferAttribute::new(buffer, 1, 1)
  assert_eq(shifted.get_y(0), 3.0)
}

///|
test "getZ reads an interleaved component" {
  let buffer = @core.InterleavedBuffer::new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 3)
  let attribute = @core.InterleavedBufferAttribute::new(buffer, 3, 0)
  assert_eq(attribute.get_z(1), 6.0)
  let shifted = @core.InterleavedBufferAttribute::new(buffer, 1, 1)
  assert_eq(shifted.get_z(0), 4.0)
}

///|
test "getW reads an interleaved component" {
  let buffer = @core.InterleavedBuffer::new(
    [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0],
    4,
  )
  let attribute = @core.InterleavedBufferAttribute::new(buffer, 4, 0)
  assert_eq(attribute.get_w(1), 8.0)
  let shifted = @core.InterleavedBufferAttribute::new(buffer, 1, 1)
  assert_eq(shifted.get_w(0), 5.0)
}

///|
test "setXY writes two interleaved components" {
  let buffer = @core.InterleavedBuffer::new([0.0, 0.0, 0.0, 9.0, 9.0, 9.0], 3)
  let attribute = @core.InterleavedBufferAttribute::new(buffer, 3, 0)
  let written = attribute.set_xy(1, 1.0, 2.0)
  assert_eq(physical_equal(written, attribute), true)
  assert_eq(buffer.array[2], 0.0)
  assert_eq(buffer.array[3], 1.0)
  assert_eq(buffer.array[4], 2.0)
  assert_eq(buffer.array[5], 9.0)
}

///|
test "setXYZ writes three interleaved components" {
  let buffer = @core.InterleavedBuffer::new([0.0, 0.0, 0.0, 9.0, 9.0, 9.0], 3)
  let attribute = @core.InterleavedBufferAttribute::new(buffer, 3, 0)
  let written = attribute.set_xyz(1, 1.0, 2.0, 3.0)
  assert_eq(physical_equal(written, attribute), true)
  assert_eq(buffer.array[2], 0.0)
  assert_eq(buffer.array[3], 1.0)
  assert_eq(buffer.array[4], 2.0)
  assert_eq(buffer.array[5], 3.0)
}

///|
test "setXYZW writes four interleaved components" {
  let buffer = @core.InterleavedBuffer::new(
    [0.0, 0.0, 0.0, 0.0, 9.0, 9.0, 9.0, 9.0],
    4,
  )
  let attribute = @core.InterleavedBufferAttribute::new(buffer, 4, 0)
  let written = attribute.set_xyzw(1, 1.0, 2.0, 3.0, 4.0)
  assert_eq(physical_equal(written, attribute), true)
  assert_eq(buffer.array[3], 0.0)
  assert_eq(buffer.array[4], 1.0)
  assert_eq(buffer.array[5], 2.0)
  assert_eq(buffer.array[6], 3.0)
  assert_eq(buffer.array[7], 4.0)
}

///|
test "applyMatrix4 translates each interleaved vertex" {
  let buffer = @core.InterleavedBuffer::new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 3)
  let attribute = @core.InterleavedBufferAttribute::new(buffer, 3, 0)
  let matrix = @math.Matrix4::new().make_translation(10.0, 0.0, 0.0)
  let written = attribute.apply_matrix4(matrix)
  assert_eq(physical_equal(written, attribute), true)
  assert_eq(attribute.get_x(0), 11.0)
  assert_eq(attribute.get_y(0), 2.0)
  assert_eq(attribute.get_z(0), 3.0)
  assert_eq(attribute.get_x(1), 14.0)
  assert_eq(attribute.get_y(1), 5.0)
  assert_eq(attribute.get_z(1), 6.0)
}

///|
test "applyNormalMatrix rotates and normalizes each interleaved vertex" {
  let buffer = @core.InterleavedBuffer::new([2.0, 0.0, 0.0, 0.0, 3.0, 0.0], 3)
  let attribute = @core.InterleavedBufferAttribute::new(buffer, 3, 0)
  let turn = @math.Matrix3::new().set(0.0, -1.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)
  let written = attribute.apply_normal_matrix(turn)
  assert_eq(physical_equal(written, attribute), true)
  assert_eq(attribute.get_x(0), 0.0)
  assert_eq(attribute.get_y(0), 1.0)
  assert_eq(attribute.get_z(0), 0.0)
  assert_eq(attribute.get_x(1), -1.0)
  assert_eq(attribute.get_y(1), 0.0)
  assert_eq(attribute.get_z(1), 0.0)
}

///|
test "transformDirection ignores translation on an interleaved vertex" {
  let buffer = @core.InterleavedBuffer::new([0.0, 0.0, 1.0], 3)
  let attribute = @core.InterleavedBufferAttribute::new(buffer, 3, 0)
  let shift = @math.Matrix4::new().make_translation(10.0, 0.0, 0.0)
  let written = attribute.transform_direction(shift)
  assert_eq(physical_equal(written, attribute), true)
  assert_eq(attribute.get_x(0), 0.0)
  assert_eq(attribute.get_y(0), 0.0)
  assert_eq(attribute.get_z(0), 1.0)
}

///|
test "getComponent reads an interleaved component by index" {
  let buffer = @core.InterleavedBuffer::new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 3)
  let attribute = @core.InterleavedBufferAttribute::new(buffer, 3, 0)
  assert_eq(attribute.get_component(1, 2), 6.0)
  let shifted = @core.InterleavedBufferAttribute::new(buffer, 1, 1)
  assert_eq(shifted.get_component(0, 0), 2.0)
}

///|
test "setComponent writes an interleaved component by index" {
  let buffer = @core.InterleavedBuffer::new([0.0, 0.0, 0.0, 9.0, 9.0, 9.0], 3)
  let attribute = @core.InterleavedBufferAttribute::new(buffer, 3, 0)
  let written = attribute.set_component(1, 2, 4.0)
  assert_eq(physical_equal(written, attribute), true)
  assert_eq(buffer.array[4], 9.0)
  assert_eq(buffer.array[5], 4.0)
}

///|
test "setX writes an interleaved component" {
  let buffer = @core.InterleavedBuffer::new([0.0, 0.0, 0.0, 9.0, 9.0, 9.0], 3)
  let attribute = @core.InterleavedBufferAttribute::new(buffer, 3, 0)
  let written = attribute.set_x(1, 4.0)
  assert_eq(physical_equal(written, attribute), true)
  assert_eq(buffer.array[3], 4.0)
  assert_eq(buffer.array[4], 9.0)
  assert_eq(buffer.array[2], 0.0)
}

///|
test "setY writes an interleaved component" {
  let buffer = @core.InterleavedBuffer::new([0.0, 0.0, 0.0, 9.0, 9.0, 9.0], 3)
  let attribute = @core.InterleavedBufferAttribute::new(buffer, 3, 0)
  let written = attribute.set_y(1, 4.0)
  assert_eq(physical_equal(written, attribute), true)
  assert_eq(buffer.array[3], 9.0)
  assert_eq(buffer.array[4], 4.0)
  assert_eq(buffer.array[5], 9.0)
}

///|
test "setZ writes an interleaved component" {
  let buffer = @core.InterleavedBuffer::new([0.0, 0.0, 0.0, 9.0, 9.0, 9.0], 3)
  let attribute = @core.InterleavedBufferAttribute::new(buffer, 3, 0)
  let written = attribute.set_z(1, 4.0)
  assert_eq(physical_equal(written, attribute), true)
  assert_eq(buffer.array[4], 9.0)
  assert_eq(buffer.array[5], 4.0)
  assert_eq(buffer.array[2], 0.0)
}

///|
test "setW writes an interleaved component" {
  let buffer = @core.InterleavedBuffer::new(
    [0.0, 0.0, 0.0, 0.0, 9.0, 9.0, 9.0, 9.0],
    4,
  )
  let attribute = @core.InterleavedBufferAttribute::new(buffer, 4, 0)
  let written = attribute.set_w(1, 4.0)
  assert_eq(physical_equal(written, attribute), true)
  assert_eq(buffer.array[6], 9.0)
  assert_eq(buffer.array[7], 4.0)
}
