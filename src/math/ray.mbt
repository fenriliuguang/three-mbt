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

///|
/// 射线与盒子的第一个前方交点写入 target。没有交点时返回 None。盒子和射线都不改。
/// r186: `intersectBox` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L449
pub fn Ray::intersect_box(self : Ray, box : Box3, target : Vector3) -> Vector3? {
  let invdirx = 1.0 / self.direction.x
  let invdiry = 1.0 / self.direction.y
  let invdirz = 1.0 / self.direction.z
  let origin = self.origin
  let mut tmin = 0.0
  let mut tmax = 0.0
  if invdirx >= 0.0 {
    tmin = (box.min.x - origin.x) * invdirx
    tmax = (box.max.x - origin.x) * invdirx
  } else {
    tmin = (box.max.x - origin.x) * invdirx
    tmax = (box.min.x - origin.x) * invdirx
  }
  let tymin = if invdiry >= 0.0 {
    (box.min.y - origin.y) * invdiry
  } else {
    (box.max.y - origin.y) * invdiry
  }
  let tymax = if invdiry >= 0.0 {
    (box.max.y - origin.y) * invdiry
  } else {
    (box.min.y - origin.y) * invdiry
  }
  if tmin > tymax || tymin > tmax {
    return None
  }
  if tymin > tmin || tmin.is_nan() {
    tmin = tymin
  }
  if tymax < tmax || tmax.is_nan() {
    tmax = tymax
  }
  let tzmin = if invdirz >= 0.0 {
    (box.min.z - origin.z) * invdirz
  } else {
    (box.max.z - origin.z) * invdirz
  }
  let tzmax = if invdirz >= 0.0 {
    (box.max.z - origin.z) * invdirz
  } else {
    (box.min.z - origin.z) * invdirz
  }
  if tmin > tzmax || tzmin > tmax {
    return None
  }
  if tzmin > tmin || tmin.is_nan() {
    tmin = tzmin
  }
  if tzmax < tmax || tmax.is_nan() {
    tmax = tzmax
  }
  if tmax < 0.0 {
    return None
  }
  let t = if tmin >= 0.0 { tmin } else { tmax }
  Some(self.at(t, target))
}

///|
/// 射线与盒子相交则为真。盒子和射线都不改。
/// r186: `intersectsBox` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L521
pub fn Ray::intersects_box(self : Ray, box : Box3) -> Bool {
  match self.intersect_box(box, Vector3::new()) {
    None => false
    Some(_) => true
  }
}

///|
/// 射线与三角形的交点写入 target。背面剔除或没有交点时返回 None。顶点和射线都不改。
/// r186: `intersectTriangle` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L538
pub fn Ray::intersect_triangle(
  self : Ray,
  a : Vector3,
  b : Vector3,
  c : Vector3,
  backface_culling : Bool,
  target : Vector3,
) -> Vector3? {
  let origin = self.origin
  let direction = self.direction
  let dx = direction.x
  let dy = direction.y
  let dz = direction.z
  let aox = a.x - origin.x
  let aoy = a.y - origin.y
  let aoz = a.z - origin.z
  let box_ = b.x - origin.x
  let boy = b.y - origin.y
  let boz = b.z - origin.z
  let cox = c.x - origin.x
  let coy = c.y - origin.y
  let coz = c.z - origin.z
  let adx = dx.abs()
  let ady = dy.abs()
  let adz = dz.abs()
  let mut dkx = 0.0
  let mut dky = 0.0
  let mut dkz = 0.0
  let mut akx = 0.0
  let mut aky = 0.0
  let mut akz = 0.0
  let mut bkx = 0.0
  let mut bky = 0.0
  let mut bkz = 0.0
  let mut ckx = 0.0
  let mut cky = 0.0
  let mut ckz = 0.0
  if adx >= ady && adx >= adz {
    dkz = dx
    akz = aox
    bkz = box_
    ckz = cox
    if dx >= 0.0 {
      dkx = dy
      dky = dz
      akx = aoy
      aky = aoz
      bkx = boy
      bky = boz
      ckx = coy
      cky = coz
    } else {
      dkx = dz
      dky = dy
      akx = aoz
      aky = aoy
      bkx = boz
      bky = boy
      ckx = coz
      cky = coy
    }
  } else if ady >= adz {
    dkz = dy
    akz = aoy
    bkz = boy
    ckz = coy
    if dy >= 0.0 {
      dkx = dz
      dky = dx
      akx = aoz
      aky = aox
      bkx = boz
      bky = box_
      ckx = coz
      cky = cox
    } else {
      dkx = dx
      dky = dz
      akx = aox
      aky = aoz
      bkx = box_
      bky = boz
      ckx = cox
      cky = coz
    }
  } else {
    dkz = dz
    akz = aoz
    bkz = boz
    ckz = coz
    if dz >= 0.0 {
      dkx = dx
      dky = dy
      akx = aox
      aky = aoy
      bkx = box_
      bky = boy
      ckx = cox
      cky = coy
    } else {
      dkx = dy
      dky = dx
      akx = aoy
      aky = aox
      bkx = boy
      bky = box_
      ckx = coy
      cky = cox
    }
  }
  if dkz == 0.0 {
    return None
  }
  let sx = dkx / dkz
  let sy = dky / dkz
  let sz = 1.0 / dkz
  let ax = akx - sx * akz
  let ay = aky - sy * akz
  let bx = bkx - sx * bkz
  let by = bky - sy * bkz
  let cx = ckx - sx * ckz
  let cy = cky - sy * ckz
  let u = cx * by - cy * bx
  let v = ax * cy - ay * cx
  let w = bx * ay - by * ax
  if backface_culling {
    if u < 0.0 || v < 0.0 || w < 0.0 {
      return None
    }
  } else if (u < 0.0 || v < 0.0 || w < 0.0) &&
    (u > 0.0 || v > 0.0 || w > 0.0) {
    return None
  }
  let det = u + v + w
  if det == 0.0 {
    return None
  }
  let t_scaled = sz * (u * akz + v * bkz + w * ckz)
  let behind = if det > 0.0 { t_scaled < 0.0 } else { t_scaled > 0.0 }
  if behind {
    return None
  }
  Some(self.at(t_scaled / det, target))
}

///|
/// 用矩阵变换原点，并把方向按矩阵的 3×3 部分变换后单位化。矩阵不改。
/// r186: `applyMatrix4` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L671
pub fn Ray::apply_matrix4(self : Ray, matrix : Matrix4) -> Ray {
  ignore(self.origin.apply_matrix4(matrix))
  ignore(self.direction.transform_direction(matrix))
  self
}
