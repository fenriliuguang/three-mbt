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
