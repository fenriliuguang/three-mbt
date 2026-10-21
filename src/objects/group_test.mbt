///|
test "Group.copy clones the child and keeps the transform" {
  let source = @objects.Group::new()
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  source.node.render_order = 4
  let child = @core.Object3D::new()
  child.name = "marker"
  ignore(source.add(child))
  let destination = @objects.Group::new()
  ignore(destination.node.position.set(1.0, 0.0, 0.0))
  let copied = destination.copy(source)
  assert_eq(physical_equal(copied, destination), true)
  assert_eq(destination.node.position.y, 3.0)
  assert_eq(destination.node.position.x, 0.0)
  assert_eq(destination.node.render_order, 4)
  assert_eq(destination.node.children.length(), 1)
  assert_eq(destination.node.children[0].name, "marker")
  assert_eq(physical_equal(destination.node.children[0], child), false)
  assert_eq(source.node.children.length(), 1)
  let bare = @objects.Group::new()
  ignore(bare.copy(source, recursive=false))
  assert_eq(bare.node.children.length(), 0)
  assert_eq(bare.node.position.y, 3.0)
  assert_eq(bare.node.render_order, 4)
}

///|
test "Group.clone keeps the transform and drops children when asked" {
  let source = @objects.Group::new()
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  source.node.render_order = 4
  let child = @core.Object3D::new()
  child.name = "marker"
  ignore(source.add(child))
  let cloned = source.clone()
  assert_eq(physical_equal(cloned, source), false)
  assert_eq(cloned.node.position.y, 3.0)
  assert_eq(cloned.node.position.x, 0.0)
  assert_eq(cloned.node.render_order, 4)
  assert_eq(cloned.node.children.length(), 1)
  assert_eq(cloned.node.children[0].name, "marker")
  assert_eq(physical_equal(cloned.node.children[0], child), false)
  let bare = source.clone(recursive=false)
  assert_eq(bare.node.children.length(), 0)
  assert_eq(bare.node.position.y, 3.0)
  assert_eq(bare.node.render_order, 4)
  assert_eq(source.node.children.length(), 1)
  assert_eq(source.node.position.y, 3.0)
}

///|
test "mesh raycast uses a material array and geometry groups" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [
          0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 5.0, 0.0, 0.0, 6.0, 0.0,
          0.0, 5.0, 1.0, 0.0,
        ],
        3,
      ),
    ),
  )
  let front = @materials.Material::basic()
  let back = @materials.Material::basic()
  back.side = @constants.Back
  let mesh = @objects.Mesh::new(geometry, front)
  mesh.set_materials([front, back])
  mesh.node.update_matrix_world()
  let first = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  let second = @core.Raycaster::new(
    origin=@math.Vector3::new(x=5.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  assert_eq(first.intersect_object(mesh.node).length(), 0)
  geometry.add_group(0, 3, material_index=0)
  geometry.add_group(3, 3, material_index=1)
  let near = first.intersect_object(mesh.node)
  assert_eq(near.length(), 1)
  assert_eq(near[0].distance, 1.0)
  assert_eq(near[0].point.x, 0.25)
  assert_eq(near[0].point.y, 0.25)
  assert_eq(near[0].point.z, 0.0)
  match near[0].face {
    None => assert_eq(false, true)
    Some(face) => assert_eq(face.material_index, 0)
  }
  match near[0].face_index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 0)
  }
  assert_eq(second.intersect_object(mesh.node).length(), 0)
  back.side = @constants.Front
  mesh.refresh()
  let far = second.intersect_object(mesh.node)
  assert_eq(far.length(), 1)
  assert_eq(far[0].point.x, 5.25)
  assert_eq(far[0].point.y, 0.25)
  assert_eq(far[0].point.z, 0.0)
  match far[0].face {
    None => assert_eq(false, true)
    Some(face) => {
      assert_eq(face.material_index, 1)
      assert_eq(face.a, 3)
      assert_eq(face.b, 4)
      assert_eq(face.c, 5)
    }
  }
  match far[0].face_index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 1)
  }
  let destination = @objects.Mesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::lambert(),
  )
  ignore(destination.copy(mesh))
  match destination.materials {
    None => assert_eq(false, true)
    Some(copied) => {
      assert_eq(copied.length(), 2)
      assert_eq(physical_equal(copied[0], front), true)
      copied.push(@materials.Material::basic())
      assert_eq(copied.length(), 3)
    }
  }
  match mesh.materials {
    None => assert_eq(false, true)
    Some(source) => assert_eq(source.length(), 2)
  }
  geometry.clear_groups()
  geometry.add_group(0, 6, material_index=0)
  geometry.set_draw_range(3.0, 3.0)
  assert_eq(first.intersect_object(mesh.node).length(), 0)
  let drawn = second.intersect_object(mesh.node)
  assert_eq(drawn.length(), 1)
  assert_eq(drawn[0].point.x, 5.25)
  match drawn[0].face {
    None => assert_eq(false, true)
    Some(face) => assert_eq(face.material_index, 0)
  }
}

