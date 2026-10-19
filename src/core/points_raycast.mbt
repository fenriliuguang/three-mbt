// r186: `raycast` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L110

///|
/// 点云里每个顶点单独测试。到射线的距离平方小于阈值才记一笔。
/// r186: `raycast` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L110
fn Object3D::raycast_points(
  self : Object3D,
  raycaster : Raycaster,
  intersects : Array[Intersection],
) -> Unit {
  let (geometry, group_draws) = match self.primitive {
    None => return
    Some(primitive) => (primitive.geometry, primitive.group_draws)
  }
  if geometry.bounding_sphere is None {
    geometry.compute_bounding_sphere()
  }
  let sphere = match geometry.bounding_sphere {
    None => return
    Some(sphere) => {
      let copy = @math.Sphere::new()
      ignore(copy.copy(sphere).apply_matrix4(self.matrix_world))
      copy.radius = copy.radius + raycaster.params.points.threshold
      copy
    }
  }
  if !raycaster.ray.intersects_sphere(sphere) {
    return
  }
  let inverse = @math.Matrix4::new()
  ignore(inverse.copy(self.matrix_world).invert())
  let ray = @math.Ray::new().copy(raycaster.ray).apply_matrix4(inverse)
  let scale = (self.scale.x + self.scale.y + self.scale.z) / 3.0
  let local_threshold = raycaster.params.points.threshold / scale
  let local_threshold_sq = local_threshold * local_threshold
  let position = match geometry.get_attribute("position") {
    None => return
    Some(position) => position
  }
  match group_draws {
    None => {
      let limit = match geometry.index {
        Some(index) => index.count
        None => position.count
      }
      let (start, end) = triangle_bounds(
        limit,
        geometry.draw_range.start,
        geometry.draw_range.count,
      )
      self.scan_points(
        raycaster,
        intersects,
        ray,
        position,
        geometry.index,
        local_threshold_sq,
        start,
        end,
        None,
      )
    }
    Some(draws) => {
      let limit = match geometry.index {
        Some(index) => index.count
        None => position.count
      }
      let mut group_index = 0
      while group_index < geometry.groups.length() {
        let group = geometry.groups[group_index]
        if group.material_index < 0 || group.material_index >= draws.length() {
          abort("Points.raycast material index is out of range")
        }
        let (start, end) = group_draw_range(
          group.start,
          group.count,
          geometry.draw_range.start,
          geometry.draw_range.count,
          limit,
        )
        self.scan_points(
          raycaster,
          intersects,
          ray,
          position,
          geometry.index,
          local_threshold_sq,
          start,
          end,
          Some(group.material_index),
        )
        group_index = group_index + 1
      }
    }
  }
}

///|
fn Object3D::scan_points(
  self : Object3D,
  raycaster : Raycaster,
  intersects : Array[Intersection],
  ray : @math.Ray,
  position : BufferAttribute,
  index : BufferAttribute?,
  threshold_sq : Double,
  start : Int,
  end : Int,
  material_index : Int?,
) -> Unit {
  match index {
    Some(index) => {
      let mut i = start
      while i < end {
        let vertex = index.get_x(i).to_int()
        self.push_point(
          raycaster,
          intersects,
          ray,
          position,
          threshold_sq,
          vertex,
          vertex,
          material_index,
        )
        i = i + 1
      }
    }
    None => {
      let mut i = start
      while i < end {
        self.push_point(
          raycaster,
          intersects,
          ray,
          position,
          threshold_sq,
          i,
          i,
          material_index,
        )
        i = i + 1
      }
    }
  }
}

///|
fn Object3D::push_point(
  self : Object3D,
  raycaster : Raycaster,
  intersects : Array[Intersection],
  ray : @math.Ray,
  position : BufferAttribute,
  threshold_sq : Double,
  vertex : Int,
  index : Int,
  material_index : Int?,
) -> Unit {
  let point = @math.Vector3::new()
  ignore(position.copy_to_vector3(vertex, point))
  let dist_sq = ray.distance_sq_to_point(point)
  if dist_sq >= threshold_sq {
    return
  }
  let on_ray = @math.Vector3::new()
  ignore(ray.closest_point_to_point(point, on_ray))
  ignore(on_ray.apply_matrix4(self.matrix_world))
  let distance = raycaster.ray.origin.distance_to(on_ray)
  if distance < raycaster.near || distance > raycaster.far {
    return
  }
  intersects.push({
    distance,
    point: on_ray,
    object: self,
    face: None,
    face_index: None,
    barycoord: None,
    uv: None,
    uv1: None,
    normal: None,
    index: Some(index),
    distance_to_ray: Some(dist_sq.sqrt()),
    instance_id: None,
    material_index,
  })
}
