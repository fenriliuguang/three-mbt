///|
test "InstancedMesh.setMorphAt stores base influence and weights" {
  let geometry = @core.BufferGeometry::new()
  let mesh = @objects.InstancedMesh::new(geometry, @materials.Material::basic(), 2)
  assert_eq(mesh.morph_texture is None, true)
  let source = @objects.Mesh::new(geometry, @materials.Material::basic())
  source.morph_target_influences = Some([0.25, 0.5])
  let written = mesh.set_morph_at(1, source)
  assert_eq(physical_equal(written, mesh), true)
  match mesh.morph_texture {
    None => assert_eq(false, true)
    Some(texture) => {
      assert_eq(texture.width, 3)
      assert_eq(texture.height, 2)
      assert_eq(texture.format is @constants.PixelFormat::Red, true)
      assert_eq(texture.format.to_int(), 1028)
      assert_eq(texture.needs_update, false)
      assert_eq(texture.data.length(), 6)
      assert_eq(texture.data[0], 0.0)
      assert_eq(texture.data[1], 0.0)
      assert_eq(texture.data[2], 0.0)
      assert_eq(texture.data[3], 0.25)
      assert_eq(texture.data[4], 0.25)
      assert_eq(texture.data[5], 0.5)
    }
  }
  geometry.morph_targets_relative = true
  ignore(mesh.set_morph_at(0, source))
  match mesh.morph_texture {
    None => assert_eq(false, true)
    Some(texture) => {
      assert_eq(texture.data.length(), 6)
      assert_eq(texture.data[0], 1.0)
      assert_eq(texture.data[1], 0.25)
      assert_eq(texture.data[2], 0.5)
      assert_eq(texture.data[3], 0.25)
      assert_eq(texture.data[4], 0.25)
      assert_eq(texture.data[5], 0.5)
    }
  }
}

///|
test "InstancedMesh.getMorphAt reads weights and skips the base" {
  let geometry = @core.BufferGeometry::new()
  let mesh = @objects.InstancedMesh::new(geometry, @materials.Material::basic(), 2)
  let source = @objects.Mesh::new(geometry, @materials.Material::basic())
  source.morph_target_influences = Some([0.25, 0.5])
  ignore(mesh.set_morph_at(1, source))
  geometry.morph_targets_relative = true
  ignore(mesh.set_morph_at(0, source))
  let reader = @objects.Mesh::new(geometry, @materials.Material::basic())
  reader.morph_target_influences = Some([9.0, 9.0])
  mesh.get_morph_at(1, reader)
  match reader.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => {
      assert_eq(weights[0], 0.25)
      assert_eq(weights[1], 0.5)
    }
  }
  mesh.get_morph_at(0, reader)
  match reader.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => {
      assert_eq(weights[0], 0.25)
      assert_eq(weights[1], 0.5)
    }
  }
  match mesh.morph_texture {
    None => assert_eq(false, true)
    Some(texture) => assert_eq(texture.data[0], 1.0)
  }
  match source.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => {
      assert_eq(weights[0], 0.25)
      assert_eq(weights[1], 0.5)
    }
  }
}

///|
test "InstancedMesh.copy clones the morph buffer" {
  let geometry = @core.BufferGeometry::new()
  let source = @objects.InstancedMesh::new(
    geometry,
    @materials.Material::basic(),
    2,
  )
  let weights = @objects.Mesh::new(geometry, @materials.Material::basic())
  weights.morph_target_influences = Some([0.25, 0.5])
  ignore(source.set_morph_at(1, weights))
  let destination = @objects.InstancedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::lambert(),
    1,
  )
  ignore(destination.copy(source))
  match destination.morph_texture {
    None => assert_eq(false, true)
    Some(texture) => {
      assert_eq(texture.width, 3)
      assert_eq(texture.height, 2)
      assert_eq(texture.format is @constants.PixelFormat::Red, true)
      assert_eq(texture.needs_update, true)
      assert_eq(texture.data.length(), 6)
      assert_eq(texture.data[0], 0.0)
      assert_eq(texture.data[3], 0.25)
      assert_eq(texture.data[4], 0.25)
      assert_eq(texture.data[5], 0.5)
      texture.data[3] = 1.0
    }
  }
  match source.morph_texture {
    None => assert_eq(false, true)
    Some(texture) => {
      assert_eq(texture.needs_update, false)
      assert_eq(texture.data[3], 1.0)
    }
  }
  let empty = @objects.InstancedMesh::new(
    geometry,
    @materials.Material::basic(),
    2,
  )
  ignore(destination.copy(empty))
  match destination.morph_texture {
    None => assert_eq(false, true)
    Some(texture) => assert_eq(texture.data[3], 1.0)
  }
  let cloned = source.clone()
  match cloned.morph_texture {
    None => assert_eq(false, true)
    Some(texture) => {
      assert_eq(texture.needs_update, true)
      assert_eq(texture.data[3], 1.0)
      assert_eq(texture.data[5], 0.5)
      texture.data[3] = 0.0
    }
  }
  match source.morph_texture {
    None => assert_eq(false, true)
    Some(texture) => assert_eq(texture.data[3], 0.0)
  }
}

///|
test "InstancedMesh.dispose clears the morph buffer" {
  let geometry = @core.BufferGeometry::new()
  let mesh = @objects.InstancedMesh::new(geometry, @materials.Material::basic(), 2)
  let weights = @objects.Mesh::new(geometry, @materials.Material::basic())
  weights.morph_target_influences = Some([0.25, 0.5])
  ignore(mesh.set_morph_at(1, weights))
  let cloned = mesh.clone()
  let hits = Ref::Ref(0)
  let kind = Ref::Ref("")
  mesh.node.add_event_listener("dispose", fn(event) {
    hits.val = hits.val + 1
    kind.val = event.kind
  })
  mesh.dispose()
  assert_eq(hits.val, 1)
  assert_eq(kind.val, "dispose")
  assert_eq(mesh.morph_texture is None, true)
  match cloned.morph_texture {
    None => assert_eq(false, true)
    Some(texture) => {
      assert_eq(texture.data[3], 0.25)
      assert_eq(texture.data[5], 0.5)
    }
  }
  let bare = @objects.InstancedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
    1,
  )
  bare.dispose()
  assert_eq(bare.morph_texture is None, true)
}

///|
test "InstancedMesh.updateMorphTargets leaves the morph buffer alone" {
  let geometry = @core.BufferGeometry::new()
  let wide = @core.BufferAttribute::new([2.0, 0.0, 0.0], 3)
  wide.name = "wide"
  let tall = @core.BufferAttribute::new([0.0, 3.0, 0.0], 3)
  tall.name = "tall"
  geometry.morph_attributes.set("position", [wide, tall])
  let mesh = @objects.InstancedMesh::new(geometry, @materials.Material::basic(), 2)
  mesh.update_morph_targets()
  assert_eq(mesh.morph_texture is None, true)
  assert_eq(mesh.instances.count, 2)
  let plain = @objects.Mesh::new(geometry, @materials.Material::basic())
  match plain.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => assert_eq(dictionary.get("wide"), Some(0))
  }
  let weights = @objects.Mesh::new(geometry, @materials.Material::basic())
  weights.morph_target_influences = Some([0.25, 0.5])
  ignore(mesh.set_morph_at(1, weights))
  mesh.update_morph_targets()
  match mesh.morph_texture {
    None => assert_eq(false, true)
    Some(texture) => {
      assert_eq(texture.data.length(), 6)
      assert_eq(texture.data[3], 0.25)
      assert_eq(texture.data[4], 0.25)
      assert_eq(texture.data[5], 0.5)
    }
  }
}

///|
test "InstancedMesh.raycast uses a material array" {
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
  let back = @materials.Material::basic()
  back.side = @constants.Back
  let front = @materials.Material::basic()
  let mesh = @objects.InstancedMesh::new(geometry, front, 2)
  mesh.set_materials([back, front])
  let matrix = @math.Matrix4::new()
  ignore(matrix.make_translation(2.0, 0.0, 0.0))
  mesh.set_matrix_at(1, matrix)
  mesh.node.update_matrix_world()
  let near = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  assert_eq(near.intersect_object(mesh.node, recursive=false).length(), 0)
  geometry.add_group(0, 3, material_index=1)
  let first = near.intersect_object(mesh.node, recursive=false)
  assert_eq(first.length(), 1)
  assert_eq(first[0].distance, 1.0)
  assert_eq(first[0].point.x, 0.25)
  assert_eq(first[0].point.y, 0.25)
  assert_eq(first[0].point.z, 0.0)
  match first[0].instance_id {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 0)
  }
  match first[0].face {
    None => assert_eq(false, true)
    Some(face) => assert_eq(face.material_index, 1)
  }
  let far = @core.Raycaster::new(
    origin=@math.Vector3::new(x=2.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  let second = far.intersect_object(mesh.node, recursive=false)
  assert_eq(second.length(), 1)
  assert_eq(second[0].point.x, 2.25)
  assert_eq(second[0].point.y, 0.25)
  assert_eq(second[0].point.z, 0.0)
  match second[0].instance_id {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 1)
  }
  match second[0].face {
    None => assert_eq(false, true)
    Some(face) => assert_eq(face.material_index, 1)
  }
  let destination = @objects.InstancedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::lambert(),
    2,
  )
  ignore(destination.copy(mesh))
  match destination.materials {
    None => assert_eq(false, true)
    Some(copied) => {
      assert_eq(copied.length(), 2)
      copied.push(@materials.Material::basic())
      assert_eq(copied.length(), 3)
    }
  }
  match mesh.materials {
    None => assert_eq(false, true)
    Some(source) => assert_eq(source.length(), 2)
  }
}

///|
test "panic InstancedMesh.raycast material index is out of range" {
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
  geometry.add_group(0, 3, material_index=1)
  let mesh = @objects.InstancedMesh::new(
    geometry,
    @materials.Material::basic(),
    1,
  )
  mesh.set_materials([@materials.Material::basic()])
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  ignore(raycaster.intersect_object(mesh.node, recursive=false))
}

///|
test "InstancedMesh.raycast hits one instance and records its index" {
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
  let mesh = @objects.InstancedMesh::new(
    geometry,
    @materials.Material::basic(),
    2,
  )
  let matrix = @math.Matrix4::new()
  ignore(matrix.make_translation(2.0, 0.0, 0.0))
  mesh.set_matrix_at(1, matrix)
  mesh.node.update_matrix_world()
  let near = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  let first = near.intersect_object(mesh.node, recursive=false)
  assert_eq(first.length(), 1)
  assert_eq(first[0].distance, 1.0)
  assert_eq(first[0].point.x, 0.25)
  assert_eq(first[0].point.y, 0.25)
  assert_eq(first[0].point.z, 0.0)
  match first[0].instance_id {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 0)
  }
  assert_eq(physical_equal(first[0].object, mesh.node), true)
  let far = @core.Raycaster::new(
    origin=@math.Vector3::new(x=2.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  let second = far.intersect_object(mesh.node, recursive=false)
  assert_eq(second.length(), 1)
  assert_eq(second[0].point.x, 2.25)
  assert_eq(second[0].point.y, 0.25)
  assert_eq(second[0].point.z, 0.0)
  assert_eq(second[0].distance, 1.0)
  match second[0].instance_id {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 1)
  }
  assert_eq(mesh.node.matrix_world.elements[0], 1.0)
  assert_eq(mesh.node.matrix_world.elements[12], 0.0)
  match geometry.bounding_sphere {
    None => assert_eq(false, true)
    Some(geometry_sphere) => {
      assert_eq(geometry_sphere.center.x, 0.5)
      assert_eq(geometry_sphere.center.y, 0.5)
      assert_eq(geometry_sphere.center.z, 0.0)
    }
  }
  ignore(matrix.make_translation(10.0, 0.0, 0.0))
  mesh.set_matrix_at(0, matrix)
  ignore(matrix.make_translation(12.0, 0.0, 0.0))
  mesh.set_matrix_at(1, matrix)
  ignore(mesh.compute_bounding_sphere())
  let missed = near.intersect_object(mesh.node, recursive=false)
  assert_eq(missed.length(), 0)
  mesh.set_count(0)
  ignore(mesh.compute_bounding_sphere())
  ignore(matrix.make_translation(0.0, 0.0, 0.0))
  mesh.set_matrix_at(0, matrix)
  let none_drawn = near.intersect_object(mesh.node, recursive=false)
  assert_eq(none_drawn.length(), 0)
}

///|
test "InstancedMesh.copy clones bounds and shares geometry" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0], 3),
    ),
  )
  let material = @materials.Material::basic()
  let source = @objects.InstancedMesh::new(geometry, material, 2)
  source.set_count(1)
  let matrix = @math.Matrix4::new()
  ignore(matrix.make_translation(2.0, 0.0, 0.0))
  source.set_matrix_at(0, matrix)
  source.set_color_at(0, @math.Color::new(r=0.25, g=0.5, b=1.0))
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  source.node.frustum_culled = true
  let child = @core.Object3D::new()
  child.name = "marker"
  ignore(source.node.add(child))
  let destination = @objects.InstancedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::lambert(),
    1,
  )
  ignore(
    destination.geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([1.0, 1.0, 1.0], 3),
    ),
  )
  ignore(destination.compute_bounding_sphere())
  let copied = destination.copy(source)
  assert_eq(physical_equal(copied, destination), true)
  assert_eq(destination.instances.count, 1)
  assert_eq(destination.bounding_sphere is None, true)
  assert_eq(physical_equal(destination.geometry, geometry), true)
  assert_eq(physical_equal(destination.material, material), true)
  assert_eq(destination.node.position.y, 3.0)
  assert_eq(destination.node.frustum_culled, true)
  assert_eq(destination.node.children.length(), 1)
  assert_eq(destination.node.children[0].name, "marker")
  assert_eq(physical_equal(destination.node.children[0], child), false)
  ignore(source.compute_bounding_box())
  ignore(source.compute_bounding_sphere())
  ignore(destination.copy(source, recursive=false))
  assert_eq(destination.node.children.length(), 1)
  let read = @math.Matrix4::new()
  ignore(destination.get_matrix_at(0, read))
  assert_eq(read.elements[12], 2.0)
  let color = @math.Color::new(r=0.0, g=0.0, b=0.0)
  ignore(destination.get_color_at(0, color))
  assert_eq(color.r, 0.25)
  assert_eq(color.g, 0.5)
  assert_eq(color.b, 1.0)
  match destination.bounding_box {
    None => assert_eq(false, true)
    Some(box) => {
      assert_eq(box.min.x, 2.0)
      assert_eq(box.max.x, 2.0)
      assert_eq(box.min.y, 0.0)
      assert_eq(box.max.y, 0.0)
      assert_eq(box.min.z, 0.0)
      assert_eq(box.max.z, 0.0)
      box.max.x = 8.0
    }
  }
  match source.bounding_box {
    None => assert_eq(false, true)
    Some(box) => assert_eq(box.max.x, 2.0)
  }
  match destination.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(sphere.center.x, 2.0)
      assert_eq(sphere.center.y, 0.0)
      assert_eq(sphere.center.z, 0.0)
      assert_eq(sphere.radius, 0.0)
      sphere.radius = 5.0
    }
  }
  match source.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => assert_eq(sphere.radius, 0.0)
  }
  match destination.instances.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => assert_eq(sphere.radius, 5.0)
  }
  ignore(matrix.make_translation(9.0, 0.0, 0.0))
  destination.set_matrix_at(0, matrix)
  ignore(source.get_matrix_at(0, read))
  assert_eq(read.elements[12], 2.0)
  destination.set_color_at(0, @math.Color::new(r=0.0, g=0.0, b=0.0))
  ignore(source.get_color_at(0, color))
  assert_eq(color.r, 0.25)
  assert_eq(color.g, 0.5)
  assert_eq(color.b, 1.0)
}

///|
test "InstancedMesh.clone keeps capacity and detaches bounds" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0], 3),
    ),
  )
  let source = @objects.InstancedMesh::new(
    geometry,
    @materials.Material::basic(),
    2,
  )
  source.set_count(1)
  let matrix = @math.Matrix4::new()
  ignore(matrix.make_translation(2.0, 0.0, 0.0))
  source.set_matrix_at(0, matrix)
  source.set_color_at(0, @math.Color::new(r=0.25, g=0.5, b=1.0))
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  let child = @core.Object3D::new()
  child.name = "marker"
  ignore(source.node.add(child))
  ignore(source.compute_bounding_sphere())
  let cloned = source.clone()
  assert_eq(physical_equal(cloned, source), false)
  assert_eq(cloned.instances.matrices.count, 2)
  assert_eq(cloned.instances.count, 1)
  assert_eq(physical_equal(cloned.geometry, geometry), true)
  assert_eq(cloned.node.position.y, 3.0)
  assert_eq(cloned.node.children.length(), 1)
  assert_eq(cloned.node.children[0].name, "marker")
  assert_eq(physical_equal(cloned.node.children[0], child), false)
  let read = @math.Matrix4::new()
  ignore(cloned.get_matrix_at(0, read))
  assert_eq(read.elements[12], 2.0)
  let color = @math.Color::new(r=0.0, g=0.0, b=0.0)
  ignore(cloned.get_color_at(0, color))
  assert_eq(color.r, 0.25)
  assert_eq(color.g, 0.5)
  assert_eq(color.b, 1.0)
  match cloned.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(sphere.center.x, 2.0)
      assert_eq(sphere.radius, 0.0)
      sphere.radius = 5.0
    }
  }
  match source.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => assert_eq(sphere.radius, 0.0)
  }
  let bare = source.clone(recursive=false)
  assert_eq(bare.node.children.length(), 0)
  assert_eq(bare.instances.count, 1)
  ignore(bare.get_matrix_at(0, read))
  assert_eq(read.elements[12], 2.0)
}

///|
test "InstancedMesh.computeBoundingSphere unions transformed geometry spheres" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0], 3),
    ),
  )
  let mesh = @objects.InstancedMesh::new(
    geometry,
    @materials.Material::basic(),
    2,
  )
  let moved = @math.Matrix4::new()
  ignore(moved.make_translation(2.0, 0.0, 0.0))
  mesh.set_matrix_at(1, moved)
  let sphere = mesh.compute_bounding_sphere()
  assert_eq(sphere.center.x, 1.0)
  assert_eq(sphere.center.y, 0.0)
  assert_eq(sphere.center.z, 0.0)
  assert_eq(sphere.radius, 1.0)
  match geometry.bounding_sphere {
    None => assert_eq(false, true)
    Some(geometry_sphere) => {
      assert_eq(geometry_sphere.center.x, 0.0)
      assert_eq(geometry_sphere.center.y, 0.0)
      assert_eq(geometry_sphere.center.z, 0.0)
      assert_eq(geometry_sphere.radius, 0.0)
    }
  }
  mesh.set_count(1)
  let near = mesh.compute_bounding_sphere()
  assert_eq(near.center.x, 0.0)
  assert_eq(near.center.y, 0.0)
  assert_eq(near.center.z, 0.0)
  assert_eq(near.radius, 0.0)
  mesh.set_count(0)
  let none_drawn = mesh.compute_bounding_sphere()
  assert_eq(none_drawn.center.x, 0.0)
  assert_eq(none_drawn.radius, -1.0)
  let blank = @objects.InstancedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
    1,
  )
  let missing = blank.compute_bounding_sphere()
  assert_eq(missing.center.x, 0.0)
  assert_eq(missing.radius, -1.0)
}

///|
test "InstancedMesh.intersectsFrustum uses the instanced bounding sphere" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0], 3),
    ),
  )
  let mesh = @objects.InstancedMesh::new(
    geometry,
    @materials.Material::basic(),
    1,
  )
  let matrix = @math.Matrix4::new()
  ignore(matrix.make_translation(-2.0, 0.0, 0.0))
  mesh.set_matrix_at(0, matrix)
  mesh.node.update_matrix_world()
  assert_eq(mesh.bounding_sphere is None, true)
  let frustum = @math.Frustum::new()
  ignore(
    frustum.set(
      @math.Plane::new(normal=@math.Vector3::new(x=1.0), constant=0.0),
      @math.Plane::new(normal=@math.Vector3::new(x=-1.0), constant=1.0),
      @math.Plane::new(normal=@math.Vector3::new(y=1.0), constant=0.0),
      @math.Plane::new(normal=@math.Vector3::new(y=-1.0), constant=1.0),
      @math.Plane::new(normal=@math.Vector3::new(z=1.0), constant=0.0),
      @math.Plane::new(normal=@math.Vector3::new(z=-1.0), constant=1.0),
    ),
  )
  assert_eq(mesh.intersects_frustum(frustum), false)
  match mesh.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(sphere.center.x, -2.0)
      assert_eq(sphere.center.y, 0.0)
      assert_eq(sphere.center.z, 0.0)
      assert_eq(sphere.radius, 0.0)
    }
  }
  match geometry.bounding_sphere {
    None => assert_eq(false, true)
    Some(geometry_sphere) => {
      assert_eq(geometry_sphere.center.x, 0.0)
      assert_eq(geometry_sphere.center.y, 0.0)
      assert_eq(geometry_sphere.center.z, 0.0)
      assert_eq(geometry_sphere.radius, 0.0)
    }
  }
  ignore(matrix.make_translation(0.5, 0.5, 0.5))
  mesh.set_matrix_at(0, matrix)
  ignore(mesh.compute_bounding_sphere())
  assert_eq(mesh.intersects_frustum(frustum), true)
  match mesh.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(sphere.center.x, 0.5)
      assert_eq(sphere.center.y, 0.5)
      assert_eq(sphere.center.z, 0.5)
      assert_eq(sphere.radius, 0.0)
    }
  }
  ignore(matrix.make_translation(0.0, 0.0, 0.0))
  mesh.set_matrix_at(0, matrix)
  ignore(mesh.compute_bounding_sphere())
  ignore(mesh.node.position.set(-2.5, 0.0, 0.0))
  mesh.node.update_matrix_world()
  assert_eq(mesh.intersects_frustum(frustum), false)
  match mesh.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(sphere.center.x, 0.0)
      assert_eq(sphere.center.y, 0.0)
      assert_eq(sphere.center.z, 0.0)
      assert_eq(sphere.radius, 0.0)
    }
  }
}

///|
test "InstancedMesh.intersectsFrustumArray uses only the counted frustums" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0], 3),
    ),
  )
  let mesh = @objects.InstancedMesh::new(
    geometry,
    @materials.Material::basic(),
    1,
  )
  let matrix = @math.Matrix4::new()
  ignore(matrix.make_translation(0.5, 0.5, 0.5))
  mesh.set_matrix_at(0, matrix)
  mesh.node.update_matrix_world()
  let frustums = @math.FrustumArray::new()
  assert_eq(mesh.intersects_frustum_array(frustums), false)
  assert_eq(mesh.bounding_sphere is None, true)
  let cube = @math.Frustum::new()
  ignore(
    cube.set(
      @math.Plane::new(normal=@math.Vector3::new(x=1.0), constant=0.0),
      @math.Plane::new(normal=@math.Vector3::new(x=-1.0), constant=1.0),
      @math.Plane::new(normal=@math.Vector3::new(y=1.0), constant=0.0),
      @math.Plane::new(normal=@math.Vector3::new(y=-1.0), constant=1.0),
      @math.Plane::new(normal=@math.Vector3::new(z=1.0), constant=0.0),
      @math.Plane::new(normal=@math.Vector3::new(z=-1.0), constant=1.0),
    ),
  )
  frustums.frustums.push(cube)
  assert_eq(mesh.intersects_frustum_array(frustums), false)
  assert_eq(mesh.bounding_sphere is None, true)
  frustums.count = 1
  assert_eq(mesh.intersects_frustum_array(frustums), true)
  match mesh.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(sphere.center.x, 0.5)
      assert_eq(sphere.center.y, 0.5)
      assert_eq(sphere.center.z, 0.5)
      assert_eq(sphere.radius, 0.0)
    }
  }
  ignore(matrix.make_translation(-2.0, 0.5, 0.5))
  mesh.set_matrix_at(0, matrix)
  ignore(mesh.compute_bounding_sphere())
  assert_eq(mesh.intersects_frustum_array(frustums), false)
  let wide = @math.Frustum::new()
  ignore(
    wide.set(
      @math.Plane::new(constant=10.0),
      @math.Plane::new(constant=10.0),
      @math.Plane::new(constant=10.0),
      @math.Plane::new(constant=10.0),
      @math.Plane::new(constant=10.0),
      @math.Plane::new(constant=10.0),
    ),
  )
  frustums.frustums.push(wide)
  assert_eq(mesh.intersects_frustum_array(frustums), false)
  frustums.count = 2
  assert_eq(mesh.intersects_frustum_array(frustums), true)
  match mesh.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(sphere.center.x, -2.0)
      assert_eq(sphere.center.y, 0.5)
      assert_eq(sphere.center.z, 0.5)
      assert_eq(sphere.radius, 0.0)
    }
  }
  match geometry.bounding_sphere {
    None => assert_eq(false, true)
    Some(geometry_sphere) => {
      assert_eq(geometry_sphere.center.x, 0.0)
      assert_eq(geometry_sphere.radius, 0.0)
    }
  }
}

///|
test "Object3D.intersectsFrustum uses the instanced bounding sphere" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0], 3),
    ),
  )
  let plain = @objects.Mesh::new(geometry, @materials.Material::basic())
  plain.node.update_matrix_world()
  let frustum = @math.Frustum::new()
  ignore(
    frustum.set(
      @math.Plane::new(normal=@math.Vector3::new(x=1.0), constant=0.0),
      @math.Plane::new(normal=@math.Vector3::new(x=-1.0), constant=1.0),
      @math.Plane::new(normal=@math.Vector3::new(y=1.0), constant=0.0),
      @math.Plane::new(normal=@math.Vector3::new(y=-1.0), constant=1.0),
      @math.Plane::new(normal=@math.Vector3::new(z=1.0), constant=0.0),
      @math.Plane::new(normal=@math.Vector3::new(z=-1.0), constant=1.0),
    ),
  )
  assert_eq(plain.node.intersects_frustum(frustum), true)
  let mesh = @objects.InstancedMesh::new(
    geometry,
    @materials.Material::basic(),
    1,
  )
  let matrix = @math.Matrix4::new()
  ignore(matrix.make_translation(-2.0, 0.0, 0.0))
  mesh.set_matrix_at(0, matrix)
  mesh.node.update_matrix_world()
  assert_eq(mesh.node.intersects_frustum(frustum), false)
  match mesh.instances.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(sphere.center.x, -2.0)
      assert_eq(sphere.center.y, 0.0)
      assert_eq(sphere.center.z, 0.0)
      assert_eq(sphere.radius, 0.0)
    }
  }
  let stored = mesh.compute_bounding_sphere()
  assert_eq(stored.center.x, -2.0)
  assert_eq(stored.radius, 0.0)
  match mesh.instances.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => assert_eq(physical_equal(stored, sphere), true)
  }
  match geometry.bounding_sphere {
    None => assert_eq(false, true)
    Some(geometry_sphere) => {
      assert_eq(geometry_sphere.center.x, 0.0)
      assert_eq(geometry_sphere.radius, 0.0)
    }
  }
  ignore(matrix.make_translation(0.5, 0.5, 0.5))
  mesh.set_matrix_at(0, matrix)
  ignore(mesh.compute_bounding_sphere())
  assert_eq(mesh.node.intersects_frustum(frustum), true)
  ignore(matrix.make_translation(0.0, 0.0, 0.0))
  mesh.set_matrix_at(0, matrix)
  ignore(mesh.compute_bounding_sphere())
  ignore(mesh.node.position.set(-2.5, 0.0, 0.0))
  mesh.node.update_matrix_world()
  assert_eq(mesh.node.intersects_frustum(frustum), false)
  match mesh.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(sphere.center.x, 0.0)
      assert_eq(sphere.center.y, 0.0)
      assert_eq(sphere.center.z, 0.0)
      assert_eq(sphere.radius, 0.0)
    }
  }
}
