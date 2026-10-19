// r186: `raycast` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L258

///|
/// 先用实例包围球挡住整条射线，再把每个实例矩阵乘到世界矩阵上做三角形测试。
/// 测试期间临时改 `matrix_world`，结束时写回。没有 `instanceId` 的普通网格不走这里。
/// r186: `raycast` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L258
fn Object3D::raycast_instances(
  self : Object3D,
  raycaster : Raycaster,
  intersects : Array[Intersection],
) -> Unit {
  let mesh = match self.mesh {
    None => return
    Some(mesh) => mesh
  }
  let instances = match mesh.instances {
    None => return
    Some(instances) => instances
  }
  let sphere = match instances.bounding_sphere {
    Some(sphere) => sphere
    None => instances.compute_bounding_sphere(mesh.geometry)
  }
  let world_sphere = @math.Sphere::new()
  ignore(world_sphere.copy(sphere).apply_matrix4(self.matrix_world))
  if !raycaster.ray.intersects_sphere(world_sphere) {
    return
  }
  let saved = @math.Matrix4::new().copy(self.matrix_world)
  let instance_matrix = @math.Matrix4::new()
  let instance_world = @math.Matrix4::new()
  let mut index = 0
  while index < instances.count {
    read_instance_matrix(instances.matrices, index, instance_matrix)
    ignore(instance_world.multiply_matrices(saved, instance_matrix))
    ignore(self.matrix_world.copy(instance_world))
    self.raycast_mesh(raycaster, intersects, instance_id=Some(index))
    index = index + 1
  }
  ignore(self.matrix_world.copy(saved))
}
