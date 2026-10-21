///|
test "scene holds a mesh node" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let basic = @materials.MeshBasicMaterial::new(hex=0x00FF00)
  let mesh = @objects.Mesh::new(box.geometry, basic.material)
  ignore(scene.add(mesh))
  let mut meshes = 0
  let mut green = 0.0
  let mut positions = 0
  scene.node.traverse(fn(node) {
    match node.kind {
      @core.Mesh => {
        meshes = meshes + 1
        match node.mesh {
          None => ()
          Some(binding) => {
            green = binding.color.g
            positions = binding.geometry.get_attribute("position").unwrap().count
          }
        }
      }
      _ => ()
    }
  })
  assert_eq(meshes, 1)
  assert_eq(green, 1.0)
  assert_eq(positions, 24)
}

///|
test "getVertexPosition applies a relative morph" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 3),
    ),
  )
  let mesh = @objects.Mesh::new(geometry, @materials.Material::basic())
  let target = @math.Vector3::new()
  let written = mesh.node.get_vertex_position(1, target)
  assert_eq(physical_equal(written, target), true)
  assert_eq(target.x, 4.0)
  assert_eq(target.y, 5.0)
  assert_eq(target.z, 6.0)
  geometry.morph_targets_relative = true
  geometry.morph_attributes.set(
    "position",
    [@core.BufferAttribute::new([2.0, 0.0, 0.0], 3)],
  )
  mesh.node.morph = Some(@core.MorphState::{
    base_position: [1.0, 2.0, 3.0],
    base_normal: None,
    base_color: None,
    targets: [],
    weights: [0.5],
    shared: false,
  })
  ignore(mesh.node.get_vertex_position(0, target))
  assert_eq(target.x, 2.0)
  assert_eq(target.y, 2.0)
  assert_eq(target.z, 3.0)
}

///|
test "Mesh.count defaults to one instance" {
  let geometry = @core.BufferGeometry::new()
  let mesh = @objects.Mesh::new(geometry, @materials.Material::basic())
  assert_eq(mesh.count, 1)
  mesh.count = 4
  assert_eq(mesh.count, 4)
  let other = @objects.Mesh::new(geometry, @materials.Material::basic())
  assert_eq(other.count, 1)
  assert_eq(mesh.count, 4)
}

///|
test "Mesh.updateMorphTargets indexes named targets" {
  let empty = @core.BufferGeometry::new()
  let bare = @objects.Mesh::new(empty, @materials.Material::basic())
  assert_eq(bare.morph_target_influences is None, true)
  assert_eq(bare.morph_target_dictionary is None, true)
  let geometry = @core.BufferGeometry::new()
  let wide = @core.BufferAttribute::new([2.0, 0.0, 0.0], 3)
  wide.name = "wide"
  let tall = @core.BufferAttribute::new([0.0, 3.0, 0.0], 3)
  tall.name = "tall"
  geometry.morph_attributes.set("position", [wide, tall])
  let mesh = @objects.Mesh::new(geometry, @materials.Material::basic())
  match mesh.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => {
      assert_eq(weights.length(), 2)
      assert_eq(weights[0], 0.0)
      assert_eq(weights[1], 0.0)
      weights[0] = 0.5
    }
  }
  match mesh.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => {
      assert_eq(dictionary.get("wide"), Some(0))
      assert_eq(dictionary.get("tall"), Some(1))
    }
  }
  let other = @objects.Mesh::new(geometry, @materials.Material::basic())
  match other.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => assert_eq(weights[0], 0.0)
  }
  match mesh.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => assert_eq(weights[0], 0.5)
  }
  let late = @objects.Mesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
  )
  late.geometry = geometry
  assert_eq(late.morph_target_influences is None, true)
  late.update_morph_targets()
  match late.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => assert_eq(dictionary.get("wide"), Some(0))
  }
  let unnamed = @core.BufferAttribute::new([1.0, 0.0, 0.0], 3)
  geometry.morph_attributes.set("position", [unnamed])
  mesh.update_morph_targets()
  match mesh.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => {
      assert_eq(dictionary.get("0"), Some(0))
      assert_eq(dictionary.get("wide"), None)
    }
  }
  match mesh.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => {
      assert_eq(weights.length(), 1)
      assert_eq(weights[0], 0.0)
    }
  }
  geometry.morph_attributes.clear()
  mesh.update_morph_targets()
  match mesh.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => assert_eq(dictionary.get("0"), Some(0))
  }
  match mesh.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => assert_eq(weights[0], 0.0)
  }
}

///|
test "Mesh.copy shares geometry and material" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.5, 0.0, 0.0], 3),
    ),
  )
  let material = @materials.Material::basic()
  let source = @objects.Mesh::new(geometry, material)
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  source.node.render_order = 4
  let child = @core.Object3D::new()
  child.name = "marker"
  ignore(source.node.add(child))
  let destination = @objects.Mesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::lambert(),
  )
  let copied = destination.copy(source)
  assert_eq(physical_equal(copied, destination), true)
  assert_eq(physical_equal(destination.geometry, geometry), true)
  assert_eq(physical_equal(destination.material, material), true)
  assert_eq(destination.node.position.y, 3.0)
  assert_eq(destination.node.render_order, 4)
  assert_eq(destination.node.children.length(), 1)
  assert_eq(destination.node.children[0].name, "marker")
  assert_eq(physical_equal(destination.node.children[0], child), false)
  match destination.node.mesh {
    None => assert_eq(false, true)
    Some(binding) =>
      assert_eq(physical_equal(binding.geometry, geometry), true)
  }
  let bare = @objects.Mesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::lambert(),
  )
  ignore(bare.copy(source, recursive=false))
  assert_eq(bare.node.children.length(), 0)
  assert_eq(bare.node.position.y, 3.0)
  assert_eq(physical_equal(bare.geometry, geometry), true)
}

///|
test "Mesh.copy copies morph weights" {
  let geometry = @core.BufferGeometry::new()
  let wide = @core.BufferAttribute::new([2.0, 0.0, 0.0], 3)
  wide.name = "wide"
  let tall = @core.BufferAttribute::new([0.0, 3.0, 0.0], 3)
  tall.name = "tall"
  geometry.morph_attributes.set("position", [wide, tall])
  let source = @objects.Mesh::new(geometry, @materials.Material::basic())
  match source.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => weights[0] = 0.5
  }
  let destination = @objects.Mesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::lambert(),
  )
  ignore(destination.copy(source))
  match destination.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => {
      assert_eq(weights.length(), 2)
      assert_eq(weights[0], 0.5)
      assert_eq(weights[1], 0.0)
      weights[0] = 1.0
    }
  }
  match destination.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => {
      assert_eq(dictionary.get("wide"), Some(0))
      assert_eq(dictionary.get("tall"), Some(1))
      dictionary.set("wide", 9)
    }
  }
  match source.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => assert_eq(weights[0], 0.5)
  }
  match source.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => assert_eq(dictionary.get("wide"), Some(0))
  }
  let kept = @objects.Mesh::new(geometry, @materials.Material::basic())
  match kept.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => weights[0] = 0.25
  }
  let empty = @objects.Mesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
  )
  ignore(kept.copy(empty))
  match kept.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => assert_eq(weights[0], 0.25)
  }
  match kept.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => assert_eq(dictionary.get("wide"), Some(0))
  }
  let cloned = source.clone()
  match cloned.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => {
      assert_eq(weights[0], 0.5)
      assert_eq(weights[1], 0.0)
      weights[0] = 0.0
    }
  }
  match cloned.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => assert_eq(dictionary.get("tall"), Some(1))
  }
  match source.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => assert_eq(weights[0], 0.5)
  }
}

///|
test "panic mesh raycast material index is out of range" {
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
  let mesh = @objects.Mesh::new(geometry, @materials.Material::basic())
  mesh.set_materials([@materials.Material::basic()])
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  ignore(raycaster.intersect_object(mesh.node))
}

///|
test "Mesh.clone shares geometry and drops children when asked" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.5, 0.0, 0.0], 3),
    ),
  )
  let material = @materials.Material::basic()
  let source = @objects.Mesh::new(geometry, material)
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  source.node.render_order = 4
  let child = @core.Object3D::new()
  child.name = "marker"
  ignore(source.node.add(child))
  let cloned = source.clone()
  assert_eq(physical_equal(cloned, source), false)
  assert_eq(physical_equal(cloned.geometry, geometry), true)
  assert_eq(physical_equal(cloned.material, material), true)
  assert_eq(cloned.node.position.y, 3.0)
  assert_eq(cloned.node.render_order, 4)
  assert_eq(cloned.node.children.length(), 1)
  assert_eq(cloned.node.children[0].name, "marker")
  assert_eq(physical_equal(cloned.node.children[0], child), false)
  match cloned.node.mesh {
    None => assert_eq(false, true)
    Some(binding) =>
      assert_eq(physical_equal(binding.geometry, geometry), true)
  }
  let bare = source.clone(recursive=false)
  assert_eq(bare.node.children.length(), 0)
  assert_eq(bare.node.position.y, 3.0)
  assert_eq(physical_equal(bare.geometry, geometry), true)
  assert_eq(source.node.children.length(), 1)
}

///|
test "mesh raycast hits a front-facing triangle" {
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
  let mesh = @objects.Mesh::new(geometry, @materials.Material::basic())
  mesh.node.update_matrix_world()
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  let hits = raycaster.intersect_object(mesh.node)
  assert_eq(hits.length(), 1)
  assert_eq(hits[0].distance, 1.0)
  assert_eq(hits[0].point.x, 0.25)
  assert_eq(hits[0].point.y, 0.25)
  assert_eq(hits[0].point.z, 0.0)
  assert_eq(physical_equal(hits[0].object, mesh.node), true)
  match hits[0].face {
    None => assert_eq(false, true)
    Some(face) => {
      assert_eq(face.a, 0)
      assert_eq(face.b, 1)
      assert_eq(face.c, 2)
      assert_eq(face.material_index, 0)
      assert_eq(face.normal.x, 0.0)
      assert_eq(face.normal.y, 0.0)
      assert_eq(face.normal.z, 1.0)
    }
  }
  match hits[0].face_index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 0)
  }
  match hits[0].barycoord {
    None => assert_eq(false, true)
    Some(bary) => {
      assert_eq(bary.x, 0.5)
      assert_eq(bary.y, 0.25)
      assert_eq(bary.z, 0.25)
    }
  }
  match hits[0].uv {
    None => ()
    Some(_) => assert_eq(false, true)
  }
  match hits[0].instance_id {
    None => ()
    Some(_) => assert_eq(false, true)
  }
}

///|
test "mesh raycast interpolates uv" {
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
      "uv",
      @core.BufferAttribute::new([0.0, 0.0, 1.0, 0.0, 0.0, 1.0], 2),
    ),
  )
  let mesh = @objects.Mesh::new(geometry, @materials.Material::basic())
  mesh.node.update_matrix_world()
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  let hits = raycaster.intersect_object(mesh.node)
  assert_eq(hits.length(), 1)
  match hits[0].uv {
    None => assert_eq(false, true)
    Some(uv) => {
      assert_eq(uv.x, 0.25)
      assert_eq(uv.y, 0.25)
    }
  }
  match hits[0].uv1 {
    None => ()
    Some(_) => assert_eq(false, true)
  }
}

///|
test "mesh raycast interpolates uv1" {
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
      "uv1",
      @core.BufferAttribute::new([0.0, 1.0, 1.0, 1.0, 0.0, 0.0], 2),
    ),
  )
  let mesh = @objects.Mesh::new(geometry, @materials.Material::basic())
  mesh.node.update_matrix_world()
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  let hits = raycaster.intersect_object(mesh.node)
  assert_eq(hits.length(), 1)
  match hits[0].uv1 {
    None => assert_eq(false, true)
    Some(uv) => {
      assert_eq(uv.x, 0.25)
      assert_eq(uv.y, 0.75)
    }
  }
}

///|
test "mesh raycast flips a back-facing shading normal" {
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
        [0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0],
        3,
      ),
    ),
  )
  let mesh = @objects.Mesh::new(geometry, @materials.Material::basic())
  mesh.node.update_matrix_world()
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  let hits = raycaster.intersect_object(mesh.node)
  assert_eq(hits.length(), 1)
  match hits[0].normal {
    None => assert_eq(false, true)
    Some(normal) => {
      assert_eq(normal.x, 0.0)
      assert_eq(normal.y, 0.0)
      assert_eq(normal.z, 1.0)
    }
  }
}

///|
test "Object3D.intersectsFrustum uses the geometry sphere" {
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
  assert_eq(@core.Object3D::new().intersects_frustum(frustum), false)
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.5, 0.5, 0.5], 3),
    ),
  )
  let mesh = @objects.Mesh::new(geometry, @materials.Material::basic())
  mesh.node.update_matrix_world()
  assert_eq(mesh.node.intersects_frustum(frustum), true)
  ignore(mesh.node.position.set(-2.5, 0.0, 0.0))
  mesh.node.update_matrix_world()
  assert_eq(mesh.node.intersects_frustum(frustum), false)
  match geometry.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(sphere.center.x, 0.5)
      assert_eq(sphere.center.y, 0.5)
      assert_eq(sphere.center.z, 0.5)
      assert_eq(sphere.radius, 0.0)
    }
  }
}

///|
test "Object3D.intersectsFrustumArray uses only the counted frustums" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.5, 0.5, 0.5], 3),
    ),
  )
  let mesh = @objects.Mesh::new(geometry, @materials.Material::basic())
  mesh.node.update_matrix_world()
  let frustums = @math.FrustumArray::new()
  assert_eq(mesh.node.intersects_frustum_array(frustums), false)
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
  assert_eq(mesh.node.intersects_frustum_array(frustums), false)
  frustums.count = 1
  assert_eq(mesh.node.intersects_frustum_array(frustums), true)
  ignore(mesh.node.position.set(-2.5, 0.0, 0.0))
  mesh.node.update_matrix_world()
  assert_eq(mesh.node.intersects_frustum_array(frustums), false)
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
  assert_eq(mesh.node.intersects_frustum_array(frustums), false)
  frustums.count = 2
  assert_eq(mesh.node.intersects_frustum_array(frustums), true)
}

