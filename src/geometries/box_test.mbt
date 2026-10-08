///|
test "unit box matches r186 vertex layout" {
  let box = @geometries.BoxGeometry::new()
  let geometry = box.geometry
  let position = geometry.get_attribute("position").unwrap()
  let normal = geometry.get_attribute("normal").unwrap()
  let uv = geometry.get_attribute("uv").unwrap()
  let index = geometry.index.unwrap()
  assert_eq(position.count, 24)
  assert_eq(normal.count, 24)
  assert_eq(uv.count, 24)
  assert_eq(uv.array.length(), 48)
  assert_eq(index.count, 36)
  assert_eq(geometry.groups.length(), 6)
  let positions = [
    0.5, 0.5, 0.5, 0.5, 0.5, -0.5, 0.5, -0.5, 0.5, 0.5, -0.5, -0.5,
  ]
  for i in 0..<12 {
    assert_eq(position.array[i], positions[i])
  }
  let normals = [1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0]
  for i in 0..<12 {
    assert_eq(normal.array[i], normals[i])
  }
  let uvs = [0.0, 1.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0]
  for i in 0..<8 {
    assert_eq(uv.array[i], uvs[i])
  }
  let indices = [
    0, 2, 1, 2, 3, 1, 4, 6, 5, 6, 7, 5, 8, 10, 9, 10, 11, 9, 12, 14, 13, 14, 15,
    13, 16, 18, 17, 18, 19, 17, 20, 22, 21, 22, 23, 21,
  ]
  for i in 0..<36 {
    assert_eq(index.get_x(i), indices[i].to_double())
  }
  geometry.compute_bounding_box()
  match geometry.bounding_box {
    None => assert_eq(false, true)
    Some(bounds) => {
      assert_eq(bounds.min.x, -0.5)
      assert_eq(bounds.min.y, -0.5)
      assert_eq(bounds.min.z, -0.5)
      assert_eq(bounds.max.x, 0.5)
      assert_eq(bounds.max.y, 0.5)
      assert_eq(bounds.max.z, 0.5)
    }
  }
}
