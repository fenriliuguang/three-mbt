///|
test "LOD.copy clones levels and leaves the current level" {
  let source = @objects.LOD::new()
  let near = @core.Object3D::new()
  near.name = "near"
  ignore(near.position.set(0.0, 1.0, 0.0))
  let far = @core.Object3D::new()
  far.name = "far"
  ignore(source.add_level(near, distance=0.0, hysteresis=0.0))
  ignore(source.add_level(far, distance=10.0, hysteresis=0.25))
  source.auto_update = false
  source.current_level = 1
  ignore(source.node.position.set(0.0, 4.0, 0.0))
  let destination = @objects.LOD::new()
  destination.current_level = 3
  let copied = destination.copy(source)
  assert_eq(physical_equal(copied, destination), true)
  assert_eq(destination.auto_update, false)
  assert_eq(destination.current_level, 3)
  assert_eq(destination.node.position.y, 4.0)
  assert_eq(destination.levels.length(), 2)
  assert_eq(destination.levels[0].distance, 0.0)
  assert_eq(destination.levels[0].hysteresis, 0.0)
  assert_eq(destination.levels[1].distance, 10.0)
  assert_eq(destination.levels[1].hysteresis, 0.25)
  assert_eq(destination.levels[0].object.name, "near")
  assert_eq(destination.levels[1].object.name, "far")
  assert_eq(destination.levels[0].object.position.y, 1.0)
  assert_eq(physical_equal(destination.levels[0].object, near), false)
  assert_eq(physical_equal(destination.levels[1].object, far), false)
  assert_eq(destination.node.children.length(), 2)
  assert_eq(source.node.children.length(), 2)
  assert_eq(source.current_level, 1)
  destination.levels[0].object.name = "copy"
  assert_eq(near.name, "near")
}

///|
test "LOD.clone starts at level zero with new objects" {
  let source = @objects.LOD::new()
  let near = @core.Object3D::new()
  near.name = "near"
  ignore(near.position.set(0.0, 1.0, 0.0))
  let far = @core.Object3D::new()
  far.name = "far"
  ignore(source.add_level(near, distance=0.0, hysteresis=0.0))
  ignore(source.add_level(far, distance=10.0, hysteresis=0.25))
  source.auto_update = false
  source.current_level = 1
  ignore(source.node.position.set(0.0, 4.0, 0.0))
  let cloned = source.clone()
  assert_eq(physical_equal(cloned, source), false)
  assert_eq(cloned.auto_update, false)
  assert_eq(cloned.current_level, 0)
  assert_eq(cloned.node.position.y, 4.0)
  assert_eq(cloned.levels.length(), 2)
  assert_eq(cloned.levels[0].distance, 0.0)
  assert_eq(cloned.levels[0].hysteresis, 0.0)
  assert_eq(cloned.levels[1].distance, 10.0)
  assert_eq(cloned.levels[1].hysteresis, 0.25)
  assert_eq(cloned.levels[0].object.name, "near")
  assert_eq(cloned.levels[0].object.position.y, 1.0)
  assert_eq(cloned.levels[1].object.name, "far")
  assert_eq(physical_equal(cloned.levels[0].object, near), false)
  assert_eq(physical_equal(cloned.levels[1].object, far), false)
  assert_eq(source.current_level, 1)
  cloned.levels[1].object.name = "copy"
  assert_eq(far.name, "far")
}

///|
test "LOD.getCurrentLevel reads the level chosen for the camera" {
  let fresh = @objects.LOD::new()
  assert_eq(fresh.get_current_level(), 0)
  let camera = @core.Object3D::new(kind=@core.NodeKind::PerspectiveCamera)
  let state = @core.CameraState::perspective(50.0, 1.0, 0.1, 2000.0)
  camera.camera = Some(state)
  ignore(camera.position.set(0.0, 0.0, 10.0))
  camera.update_matrix_world()
  let lod = @objects.LOD::new()
  ignore(lod.add_level(@core.Object3D::new(), distance=0.0))
  ignore(lod.add_level(@core.Object3D::new(), distance=10.0))
  ignore(lod.add_level(@core.Object3D::new(), distance=20.0))
  lod.node.update_matrix_world()
  lod.update(camera)
  assert_eq(lod.get_current_level(), 1)
  state.zoom = 2.0
  lod.update(camera)
  assert_eq(lod.get_current_level(), 0)
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

