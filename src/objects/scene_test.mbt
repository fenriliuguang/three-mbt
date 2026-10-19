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
test "line raycast hits the nearest point on a segment" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0, 1.0, 0.0, 0.0], 3),
    ),
  )
  let line = @objects.Line::new(geometry, @materials.LineBasicMaterial::new())
  line.node.update_matrix_world()
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.5, y=0.5, z=0.0),
    direction=@math.Vector3::new(y=-1.0),
  )
  let hits = raycaster.intersect_object(line.node)
  assert_eq(hits.length(), 1)
  assert_eq(hits[0].distance, 0.5)
  assert_eq(hits[0].point.x, 0.5)
  assert_eq(hits[0].point.y, 0.0)
  assert_eq(hits[0].point.z, 0.0)
  match hits[0].index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 0)
  }
}

///|
test "points raycast records distance to the ray" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.5, 0.0, 0.0], 3),
    ),
  )
  let points = @objects.Points::new(geometry, @materials.PointsMaterial::new())
  points.node.update_matrix_world()
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(y=0.5),
    direction=@math.Vector3::new(y=-1.0),
  )
  let hits = raycaster.intersect_object(points.node)
  assert_eq(hits.length(), 1)
  assert_eq(hits[0].distance, 0.5)
  assert_eq(hits[0].point.x, 0.0)
  assert_eq(hits[0].point.y, 0.0)
  assert_eq(hits[0].point.z, 0.0)
  match hits[0].index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 0)
  }
  match hits[0].distance_to_ray {
    None => assert_eq(false, true)
    Some(distance) => assert_eq(distance, 0.5)
  }
}

///|
test "sprite raycast hits the camera-facing quad" {
  let sprite = @objects.Sprite::new(@materials.SpriteMaterial::new())
  ignore(sprite.node.position.set(0.0, 0.0, -1.0))
  sprite.node.update_matrix_world()
  let camera = @core.Object3D::new(kind=@core.NodeKind::PerspectiveCamera)
  camera.camera = Some(@core.CameraState::perspective(50.0, 1.0, 0.1, 2000.0))
  camera.update_matrix_world()
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=-0.25),
    direction=@math.Vector3::new(z=-1.0),
  )
  raycaster.camera = Some(camera)
  let hits = raycaster.intersect_object(sprite.node)
  assert_eq(hits.length(), 1)
  assert_eq(hits[0].distance, 1.0)
  assert_eq(hits[0].point.x, 0.25)
  assert_eq(hits[0].point.y, -0.25)
  assert_eq(hits[0].point.z, -1.0)
  assert_eq(physical_equal(hits[0].object, sprite.node), true)
  match hits[0].uv {
    None => assert_eq(false, true)
    Some(uv) => {
      assert_eq(uv.x, 0.75)
      assert_eq(uv.y, 0.25)
    }
  }
  match hits[0].face {
    None => ()
    Some(_) => assert_eq(false, true)
  }
}

///|
test "panic sprite raycast without a camera" {
  let sprite = @objects.Sprite::new(@materials.SpriteMaterial::new())
  sprite.node.update_matrix_world()
  let raycaster = @core.Raycaster::new()
  ignore(raycaster.intersect_object(sprite.node))
}

///|
test "LOD.addLevel sorts levels by absolute distance" {
  let lod = @objects.LOD::new()
  let far = @core.Object3D::new()
  let near = @core.Object3D::new()
  let mid = @core.Object3D::new()
  ignore(lod.add_level(far, distance=10.0))
  ignore(lod.add_level(near, distance=0.0))
  ignore(lod.add_level(mid, distance=-5.0, hysteresis=0.25))
  assert_eq(lod.levels.length(), 3)
  assert_eq(lod.levels[0].distance, 0.0)
  assert_eq(lod.levels[1].distance, 5.0)
  assert_eq(lod.levels[2].distance, 10.0)
  assert_eq(lod.levels[0].hysteresis, 0.0)
  assert_eq(lod.levels[1].hysteresis, 0.25)
  assert_eq(physical_equal(lod.levels[0].object, near), true)
  assert_eq(physical_equal(lod.levels[1].object, mid), true)
  assert_eq(physical_equal(lod.levels[2].object, far), true)
  assert_eq(lod.node.children.length(), 3)
  assert_eq(physical_equal(lod.node.children[0], far), true)
  assert_eq(lod.auto_update, true)
}

///|
test "LOD.removeLevel drops the matching distance" {
  let lod = @objects.LOD::new()
  let far = @core.Object3D::new()
  let near = @core.Object3D::new()
  let mid = @core.Object3D::new()
  ignore(lod.add_level(far, distance=10.0))
  ignore(lod.add_level(near, distance=0.0))
  ignore(lod.add_level(mid, distance=5.0))
  assert_eq(lod.remove_level(5.0), true)
  assert_eq(lod.levels.length(), 2)
  assert_eq(lod.levels[0].distance, 0.0)
  assert_eq(lod.levels[1].distance, 10.0)
  assert_eq(physical_equal(lod.levels[0].object, near), true)
  assert_eq(physical_equal(lod.levels[1].object, far), true)
  assert_eq(lod.node.children.length(), 2)
  match mid.parent {
    None => assert_eq(true, true)
    Some(_) => assert_eq(false, true)
  }
  assert_eq(lod.remove_level(7.0), false)
  assert_eq(lod.levels.length(), 2)
  assert_eq(lod.node.children.length(), 2)
}

///|
test "LOD.getObjectForDistance applies visible hysteresis" {
  let empty = @objects.LOD::new()
  match empty.get_object_for_distance(1.0) {
    None => assert_eq(true, true)
    Some(_) => assert_eq(false, true)
  }
  let lod = @objects.LOD::new()
  let near = @core.Object3D::new()
  let far = @core.Object3D::new()
  ignore(lod.add_level(near, distance=0.0))
  ignore(lod.add_level(far, distance=10.0, hysteresis=0.5))
  match lod.get_object_for_distance(4.0) {
    None => assert_eq(false, true)
    Some(object) => assert_eq(physical_equal(object, near), true)
  }
  match lod.get_object_for_distance(5.0) {
    None => assert_eq(false, true)
    Some(object) => assert_eq(physical_equal(object, far), true)
  }
  far.visible = false
  match lod.get_object_for_distance(8.0) {
    None => assert_eq(false, true)
    Some(object) => assert_eq(physical_equal(object, near), true)
  }
}

///|
test "LOD.raycast hits the level selected by distance" {
  let lod = @objects.LOD::new()
  lod.node.update_matrix_world()
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  assert_eq(raycaster.intersect_object(lod.node, recursive=false).length(), 0)
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
  ignore(lod.add_level(@core.Object3D::new(), distance=0.0))
  ignore(lod.add_level(mesh.node, distance=0.5))
  lod.node.update_matrix_world()
  let hits = raycaster.intersect_object(lod.node, recursive=false)
  assert_eq(hits.length(), 1)
  assert_eq(hits[0].distance, 1.0)
  assert_eq(hits[0].point.x, 0.25)
  assert_eq(hits[0].point.y, 0.25)
  assert_eq(hits[0].point.z, 0.0)
  assert_eq(physical_equal(hits[0].object, mesh.node), true)
}

///|
test "LOD.update shows the level for the camera distance" {
  let camera = @core.Object3D::new(kind=@core.NodeKind::PerspectiveCamera)
  let state = @core.CameraState::perspective(50.0, 1.0, 0.1, 2000.0)
  camera.camera = Some(state)
  ignore(camera.position.set(0.0, 0.0, 10.0))
  camera.update_matrix_world()
  let alone = @core.Object3D::new()
  let single = @objects.LOD::new()
  ignore(single.add_level(alone, distance=0.0))
  single.node.update_matrix_world()
  single.update(camera)
  assert_eq(alone.visible, true)
  assert_eq(single.current_level, 0)
  let lod = @objects.LOD::new()
  let near = @core.Object3D::new()
  let mid = @core.Object3D::new()
  let far = @core.Object3D::new()
  ignore(lod.add_level(near, distance=0.0))
  ignore(lod.add_level(mid, distance=10.0))
  ignore(lod.add_level(far, distance=20.0))
  lod.node.update_matrix_world()
  lod.update(camera)
  assert_eq(lod.current_level, 1)
  assert_eq(near.visible, false)
  assert_eq(mid.visible, true)
  assert_eq(far.visible, false)
  state.zoom = 2.0
  lod.update(camera)
  assert_eq(lod.current_level, 0)
  assert_eq(near.visible, true)
  assert_eq(mid.visible, false)
  assert_eq(far.visible, false)
}
