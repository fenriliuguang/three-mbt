///|
test "instanced cubes keep matrices, colors, and one local box" {
  let fresh = @objects.InstancedMesh::new(
    @core.BufferGeometry::new(),
    @materials.MeshLambertMaterial::new().material,
    2,
  )
  let identity = @math.Matrix4::new()
  ignore(fresh.get_matrix_at(0, identity))
  assert_eq(identity.elements[0], 1.0)
  assert_eq(identity.elements[12], 0.0)
  let white = @math.Color::new(r=0.0, g=0.0, b=0.0)
  ignore(fresh.get_color_at(0, white))
  assert_eq(white.r, 1.0)
  fresh.set_count(8)
  assert_eq(fresh.instances.count, 2)
  fresh.set_count(1)
  assert_eq(fresh.instances.count, 1)
  let world = @instanced.InstancedScene::new()
  world.spin(0.2)
  assert_eq(world.mesh.node.rotation.y, 0.2)
  assert_eq(world.mesh.instances.count, 3)
  assert_eq(world.mesh.node.frustum_culled, false)
  let matrix = @math.Matrix4::new()
  ignore(world.mesh.get_matrix_at(0, matrix))
  assert_eq(matrix.elements[12], -1.5)
  ignore(world.mesh.get_matrix_at(2, matrix))
  assert_eq(matrix.elements[12], 1.5)
  let color = @math.Color::new()
  ignore(world.mesh.get_color_at(0, color))
  let expected = @math.Color::new().set_hex(0xE07A5F)
  assert_eq(color.r, expected.r)
  assert_eq(color.g, expected.g)
  assert_eq(color.b, expected.b)
  let items = @common.collect_opaque(world.scene.node)
  assert_eq(items.length(), 1)
  match items[0].instances {
    None => panic()
    Some(data) => {
      assert_eq(data.count, 3)
      assert_eq(data.colors is Some(_), true)
    }
  }
  let box = world.mesh.compute_bounding_box()
  assert_eq(box.min.x, -2.0)
  assert_eq(box.max.x, 2.0)
  assert_eq(box.min.y, -0.5)
  assert_eq(box.max.y, 0.5)
  assert_eq(box.min.z, -0.5)
  assert_eq(box.max.z, 0.5)
}
