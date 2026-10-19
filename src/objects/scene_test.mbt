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
}
