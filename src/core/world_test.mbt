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
