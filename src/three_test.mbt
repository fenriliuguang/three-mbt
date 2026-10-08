///|
test "upstream revision is r186" {
  assert_eq(@three-mbt.upstream_revision, "r186")
}

///|
test "facade exports the phase 2 scene graph" {
  let position = @three-mbt.Vector3::new(x=1.0, y=2.0, z=3.0)
  let mesh = @three-mbt.Mesh::new(
    @three-mbt.BoxGeometry::new().geometry,
    @three-mbt.MeshBasicMaterial::new().material,
  )
  ignore(mesh.node.position.copy(position))
  assert_eq(mesh.node.position.z, 3.0)
  assert_eq(@three-mbt.WEBGPU_COORDINATE_SYSTEM, 2001)
}
