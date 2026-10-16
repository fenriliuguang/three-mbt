// r186: `Ray` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L14

///|
/// 从原点沿方向发出的射线。缺省原点是 (0, 0, 0)，方向是 (0, 0, -1)。
/// r186: `Ray` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L14
pub(all) struct Ray {
  origin : Vector3
  direction : Vector3
}

///|
pub fn Ray::new(origin? : Vector3, direction? : Vector3) -> Ray {
  let origin = match origin {
    None => Vector3::new()
    Some(origin) => origin.clone()
  }
  let direction = match direction {
    None => Vector3::new(z=-1.0)
    Some(direction) => direction.clone()
  }
  { origin, direction }
}

///|
/// 拷贝原点和方向。之后改来源向量不影响这里。
/// r186: `set` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L47
pub fn Ray::set(self : Ray, origin : Vector3, direction : Vector3) -> Ray {
  ignore(self.origin.copy(origin))
  ignore(self.direction.copy(direction))
  self
}

///|
/// 把另一条射线的原点和方向拷过来。之后改来源不影响这里。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L62
pub fn Ray::copy(self : Ray, ray : Ray) -> Ray {
  ignore(self.origin.copy(ray.origin))
  ignore(self.direction.copy(ray.direction))
  self
}

///|
/// 沿射线走距离 t，写入 target。射线不改。
/// r186: `at` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L78
pub fn Ray::at(self : Ray, t : Double, target : Vector3) -> Vector3 {
  target.copy(self.origin).add_scaled_vector(self.direction, t)
}

///|
/// 把方向改成从原点指向这个点，并单位化。点不改。
/// r186: `lookAt` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L90
pub fn Ray::look_at(self : Ray, v : Vector3) -> Ray {
  ignore(self.direction.copy(v).sub(self.origin).normalize())
  self
}

///|
/// 把原点沿方向挪一段距离。方向不改。
/// r186: `recast` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L104
pub fn Ray::recast(self : Ray, t : Double) -> Ray {
  ignore(self.origin.copy(self.at(t, Vector3::new())))
  self
}

///|
/// 把射线上离点最近的位置写入 target。点在射线反方向时结果是原点。点和射线都不改。
/// r186: `closestPointToPoint` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L119
pub fn Ray::closest_point_to_point(
  self : Ray,
  point : Vector3,
  target : Vector3,
) -> Vector3 {
  let direction_distance = target
    .sub_vectors(point, self.origin)
    .dot(self.direction)
  if direction_distance < 0.0 {
    target.copy(self.origin)
  } else {
    target.copy(self.origin).add_scaled_vector(self.direction, direction_distance)
  }
}

///|
/// 返回点到射线的距离平方。点在反方向时是到原点的距离平方。点和射线都不改。
/// r186: `distanceSqToPoint` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L153
pub fn Ray::distance_sq_to_point(self : Ray, point : Vector3) -> Double {
  let direction = Vector3::new().sub_vectors(point, self.origin)
  let direction_distance = direction.dot(self.direction)
  if direction_distance < 0.0 {
    self.origin.distance_to_squared(point)
  } else {
    let closest = Vector3::new()
      .copy(self.origin)
      .add_scaled_vector(self.direction, direction_distance)
    closest.distance_to_squared(point)
  }
}

///|
/// 返回点到射线的距离。点在反方向时是到原点的距离。点和射线都不改。
/// r186: `distanceToPoint` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L141
pub fn Ray::distance_to_point(self : Ray, point : Vector3) -> Double {
  self.distance_sq_to_point(point).sqrt()
}

///|
/// 返回射线到线段的距离平方。给出的话，写入两边的最近点。射线和端点都不改。
/// r186: `distanceSqToSegment` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L180
pub fn Ray::distance_sq_to_segment(
  self : Ray,
  v0 : Vector3,
  v1 : Vector3,
  point_on_ray? : Vector3,
  point_on_segment? : Vector3,
) -> Double {
  let seg_center = Vector3::new().copy(v0).add(v1).multiply_scalar(0.5)
  let seg_dir = Vector3::new().copy(v1).sub(v0).normalize()
  let diff = Vector3::new().copy(self.origin).sub(seg_center)
  let seg_extent = v0.distance_to(v1) * 0.5
  let a01 = -self.direction.dot(seg_dir)
  let b0 = diff.dot(self.direction)
  let b1 = -diff.dot(seg_dir)
  let c = diff.length_sq()
  let det = (1.0 - a01 * a01).abs()
  let mut s0 = 0.0
  let mut s1 = 0.0
  let mut sqr_dist = 0.0
  if det > 0.0 {
    s0 = a01 * b1 - b0
    s1 = a01 * b0 - b1
    let ext_det = seg_extent * det
    if s0 >= 0.0 {
      if s1 >= -ext_det {
        if s1 <= ext_det {
          let inv_det = 1.0 / det
          s0 = s0 * inv_det
          s1 = s1 * inv_det
          sqr_dist = s0 * (s0 + a01 * s1 + 2.0 * b0) +
            s1 * (a01 * s0 + s1 + 2.0 * b1) +
            c
        } else {
          s1 = seg_extent
          s0 = 0.0.max(-(a01 * s1 + b0))
          sqr_dist = -s0 * s0 + s1 * (s1 + 2.0 * b1) + c
        }
      } else {
        s1 = -seg_extent
        s0 = 0.0.max(-(a01 * s1 + b0))
        sqr_dist = -s0 * s0 + s1 * (s1 + 2.0 * b1) + c
      }
    } else if s1 <= -ext_det {
      s0 = 0.0.max(-(-a01 * seg_extent + b0))
      s1 = if s0 > 0.0 {
        -seg_extent
      } else {
        (-seg_extent).max(-b1).min(seg_extent)
      }
      sqr_dist = -s0 * s0 + s1 * (s1 + 2.0 * b1) + c
    } else if s1 <= ext_det {
      s0 = 0.0
      s1 = (-seg_extent).max(-b1).min(seg_extent)
      sqr_dist = s1 * (s1 + 2.0 * b1) + c
    } else {
      s0 = 0.0.max(-(a01 * seg_extent + b0))
      s1 = if s0 > 0.0 {
        seg_extent
      } else {
        (-seg_extent).max(-b1).min(seg_extent)
      }
      sqr_dist = -s0 * s0 + s1 * (s1 + 2.0 * b1) + c
    }
  } else {
    s1 = if a01 > 0.0 { -seg_extent } else { seg_extent }
    s0 = 0.0.max(-(a01 * s1 + b0))
    sqr_dist = -s0 * s0 + s1 * (s1 + 2.0 * b1) + c
  }
  match point_on_ray {
    None => ()
    Some(point) =>
      ignore(point.copy(self.origin).add_scaled_vector(self.direction, s0))
  }
  match point_on_segment {
    None => ()
    Some(point) =>
      ignore(point.copy(seg_center).add_scaled_vector(seg_dir, s1))
  }
  sqr_dist
}

///|
/// 射线与球的第一个前方交点写入 target。没有交点时返回 None。球和射线都不改。
/// r186: `intersectSphere` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L307
pub fn Ray::intersect_sphere(
  self : Ray,
  sphere : Sphere,
  target : Vector3,
) -> Vector3? {
  if sphere.radius < 0.0 {
    return None
  }
  let offset = Vector3::new().sub_vectors(sphere.center, self.origin)
  let tca = offset.dot(self.direction)
  let d2 = offset.dot(offset) - tca * tca
  let radius2 = sphere.radius * sphere.radius
  if d2 > radius2 {
    return None
  }
  let thc = (radius2 - d2).sqrt()
  let t0 = tca - thc
  let t1 = tca + thc
  if t1 < 0.0 {
    return None
  }
  if t0 < 0.0 {
    Some(self.at(t1, target))
  } else {
    Some(self.at(t0, target))
  }
}

///|
/// 射线与球相交，或从球内出发，则为真。空球为假。球和射线都不改。
/// r186: `intersectsSphere` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L345
pub fn Ray::intersects_sphere(self : Ray, sphere : Sphere) -> Bool {
  if sphere.radius < 0.0 {
    return false
  }
  self.distance_sq_to_point(sphere.center) <= sphere.radius * sphere.radius
}

///|
/// 返回原点到平面的距离。射线背离平面、或平行且不在平面上时返回 None。平面和射线都不改。
/// r186: `distanceToPlane` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L360
pub fn Ray::distance_to_plane(self : Ray, plane : Plane) -> Double? {
  let denominator = plane.normal.dot(self.direction)
  if denominator == 0.0 {
    if plane.distance_to_point(self.origin) == 0.0 {
      Some(0.0)
    } else {
      None
    }
  } else {
    let t = -(self.origin.dot(plane.normal) + plane.constant) / denominator
    if t >= 0.0 {
      Some(t)
    } else {
      None
    }
  }
}

///|
/// 射线与平面的交点写入 target。没有交点时返回 None。平面和射线都不改。
/// r186: `intersectPlane` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L395
pub fn Ray::intersect_plane(
  self : Ray,
  plane : Plane,
  target : Vector3,
) -> Vector3? {
  match self.distance_to_plane(plane) {
    None => None
    Some(t) => Some(self.at(t, target))
  }
}

///|
/// 原点在平面上，或射线朝向平面，则为真。平面和射线都不改。
/// r186: `intersectsPlane` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L415
pub fn Ray::intersects_plane(self : Ray, plane : Plane) -> Bool {
  let dist_to_point = plane.distance_to_point(self.origin)
  if dist_to_point == 0.0 {
    return true
  }
  let denominator = plane.normal.dot(self.direction)
  denominator * dist_to_point < 0.0
}
