// r186: `Sphere` https://github.com/mrdoob/three.js/blob/r186/src/math/Sphere.js#L12

///|
/// 球体。半径为负表示空球，与 r186 `Sphere` 相同。
/// r186: `Sphere` https://github.com/mrdoob/three.js/blob/r186/src/math/Sphere.js#L12
pub(all) struct Sphere {
  center : Vector3
  mut radius : Double
}

///|
pub fn Sphere::new(center? : Vector3, radius? : Double = -1.0) -> Sphere {
  let center = match center {
    None => Vector3::new()
    Some(center) => center.clone()
  }
  { center, radius, }
}

///|
pub fn Sphere::copy(self : Sphere, sphere : Sphere) -> Sphere {
  ignore(self.center.copy(sphere.center))
  self.radius = sphere.radius
  self
}

///|
pub fn Sphere::is_empty(self : Sphere) -> Bool {
  self.radius < 0.0
}

///|
pub fn Sphere::make_empty(self : Sphere) -> Sphere {
  ignore(self.center.set(0.0, 0.0, 0.0))
  self.radius = -1.0
  self
}

///|
pub fn Sphere::set_from_points(
  self : Sphere,
  points : Array[Vector3],
  optional_center? : Vector3,
) -> Sphere {
  match optional_center {
    None => {
      let box = Box3::empty().set_from_points(points)
      ignore(box.get_center(self.center))
    }
    Some(center) => ignore(self.center.copy(center))
  }
  let mut max_radius_sq = 0.0
  for point in points {
    max_radius_sq = max_radius_sq.max(self.center.distance_to_squared(point))
  }
  self.radius = max_radius_sq.sqrt()
  self
}

///|
pub fn Sphere::contains_point(self : Sphere, point : Vector3) -> Bool {
  self.center.distance_to_squared(point) <= self.radius * self.radius
}

///|
pub fn Sphere::apply_matrix4(self : Sphere, matrix : Matrix4) -> Sphere {
  ignore(self.center.apply_matrix4(matrix))
  self.radius = self.radius * matrix.get_max_scale_on_axis()
  self
}

///|
pub fn Sphere::intersects_sphere(self : Sphere, sphere : Sphere) -> Bool {
  let radius_sum = self.radius + sphere.radius
  self.center.distance_to_squared(sphere.center) <= radius_sum * radius_sum
}

///|
/// 球心到平面的距离不超过半径则为真。球和平面都不改。
/// r186: `intersectsPlane` https://github.com/mrdoob/three.js/blob/r186/src/math/Sphere.js#L203
pub fn Sphere::intersects_plane(self : Sphere, plane : Plane) -> Bool {
  plane.distance_to_point(self.center).abs() <= self.radius
}

///|
/// 拷贝球心并写入半径。之后改来源球心不影响这里。
/// r186: `set` https://github.com/mrdoob/three.js/blob/r186/src/math/Sphere.js#L54
pub fn Sphere::set(self : Sphere, center : Vector3, radius : Double) -> Sphere {
  ignore(self.center.copy(center))
  self.radius = radius
  self
}

///|
/// 返回点到球面的有符号距离。球内为负。点和球都不改。
/// r186: `distanceToPoint` https://github.com/mrdoob/three.js/blob/r186/src/math/Sphere.js#L165
pub fn Sphere::distance_to_point(self : Sphere, point : Vector3) -> Double {
  point.distance_to(self.center) - self.radius
}

///|
/// 球与盒子相交或相切则为真。球和盒子都不改。
/// r186: `intersectsBox` https://github.com/mrdoob/three.js/blob/r186/src/math/Sphere.js#L191
pub fn Sphere::intersects_box(self : Sphere, box : Box3) -> Bool {
  box.intersects_sphere(self)
}

///|
/// 把点夹进球内，写入 target。球外的点落到球面上最近点，球内的点原样写入。点和球都不改。
/// r186: `clampPoint` https://github.com/mrdoob/three.js/blob/r186/src/math/Sphere.js#L218
pub fn Sphere::clamp_point(
  self : Sphere,
  point : Vector3,
  target : Vector3,
) -> Vector3 {
  let delta_length_sq = self.center.distance_to_squared(point)
  ignore(target.copy(point))
  if delta_length_sq > self.radius * self.radius {
    ignore(
      target
      .sub(self.center)
      .normalize()
      .multiply_scalar(self.radius)
      .add(self.center),
    )
  }
  target
}

///|
/// 把包围这个球的盒子写入 target。空球得到空盒。球不改。
/// r186: `getBoundingBox` https://github.com/mrdoob/three.js/blob/r186/src/math/Sphere.js#L241
pub fn Sphere::get_bounding_box(self : Sphere, target : Box3) -> Box3 {
  if self.is_empty() {
    ignore(target.make_empty())
    return target
  }
  ignore(target.set(self.center, self.center))
  target.expand_by_scalar(self.radius)
}
