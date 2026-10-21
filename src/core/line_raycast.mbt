// r186: `raycast` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L172 ; `isLineLoop` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L223

///|
/// 折线按相邻顶点成段，线段按成对顶点成段，闭合折线再补上最后一点到第一点。距离平方大于阈值就跳过。
/// r186: `raycast` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L172
/// r186: `isLineLoop` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L223
fn Object3D::raycast_line(
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
      copy.radius = copy.radius + raycaster.params.line.threshold
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
  let local_threshold = raycaster.params.line.threshold / scale
  let local_threshold_sq = local_threshold * local_threshold
  let step = match self.kind {
    LineSegments => 2
    _ => 1
  }
  let position = match geometry.get_attribute("position") {
    None => return
    Some(position) => position
  }
  let close = self.kind is LineLoop
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
      self.scan_lines(
        raycaster,
        intersects,
        ray,
        position,
        geometry.index,
        local_threshold_sq,
        start,
        end,
        step,
        None,
        close,
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
          abort("Line.raycast material index is out of range")
        }
        let (start, end) = group_draw_range(
          group.start,
          group.count,
          geometry.draw_range.start,
          geometry.draw_range.count,
          limit,
        )
        self.scan_lines(
          raycaster,
          intersects,
          ray,
          position,
          geometry.index,
          local_threshold_sq,
          start,
          end,
          step,
          Some(group.material_index),
          false,
        )
        group_index = group_index + 1
      }
    }
  }
}

///|
fn Object3D::scan_lines(
  self : Object3D,
  raycaster : Raycaster,
  intersects : Array[Intersection],
  ray : @math.Ray,
  position : BufferAttribute,
  index : BufferAttribute?,
  threshold_sq : Double,
  start : Int32,
  end : Int32,
  step : Int32,
  material_index : Int32?,
  close : Bool,
) -> Unit {
  match index {
    Some(index) => {
      let mut i = start
      while i < end - 1 {
        self.push_line_segment(
          raycaster,
          intersects,
          ray,
          position,
          threshold_sq,
          index.get_x(i).to_int(),
          index.get_x(i + 1).to_int(),
          i,
          material_index,
        )
        i = i + step
      }
      if close && end > start {
        self.push_line_segment(
          raycaster,
          intersects,
          ray,
          position,
          threshold_sq,
          index.get_x(end - 1).to_int(),
          index.get_x(start).to_int(),
          end - 1,
          material_index,
        )
      }
    }
    None => {
      let mut i = start
      while i < end - 1 {
        self.push_line_segment(
          raycaster,
          intersects,
          ray,
          position,
          threshold_sq,
          i,
          i + 1,
          i,
          material_index,
        )
        i = i + step
      }
      if close && end > start {
        self.push_line_segment(
          raycaster,
          intersects,
          ray,
          position,
          threshold_sq,
          end - 1,
          start,
          end - 1,
          material_index,
        )
      }
    }
  }
}

///|
fn Object3D::push_line_segment(
  self : Object3D,
  raycaster : Raycaster,
  intersects : Array[Intersection],
  ray : @math.Ray,
  position : BufferAttribute,
  threshold_sq : Double,
  a : Int32,
  b : Int32,
  index : Int32,
  material_index : Int32?,
) -> Unit {
  let start = @math.Vector3::new()
  let end = @math.Vector3::new()
  ignore(position.copy_to_vector3(a, start))
  ignore(position.copy_to_vector3(b, end))
  let on_ray = @math.Vector3::new()
  let on_segment = @math.Vector3::new()
  let dist_sq = ray.distance_sq_to_segment(
    start,
    end,
    point_on_ray=on_ray,
    point_on_segment=on_segment,
  )
  if dist_sq > threshold_sq {
    return
  }
  ignore(on_ray.apply_matrix4(self.matrix_world))
  let distance = raycaster.ray.origin.distance_to(on_ray)
  if distance < raycaster.near || distance > raycaster.far {
    return
  }
  let point = on_segment.apply_matrix4(self.matrix_world)
  intersects.push({
    distance,
    point,
    object: self,
    face: None,
    face_index: None,
    barycoord: None,
    uv: None,
    uv1: None,
    normal: None,
    index: Some(index),
    distance_to_ray: None,
    instance_id: None,
    material_index,
  })
}
