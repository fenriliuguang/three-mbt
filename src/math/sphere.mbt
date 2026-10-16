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

///|
/// 把球心按偏移平移。半径不变。偏移不改。
/// r186: `translate` https://github.com/mrdoob/three.js/blob/r186/src/math/Sphere.js#L279
pub fn Sphere::translate(self : Sphere, offset : Vector3) -> Sphere {
  ignore(self.center.add(offset))
  self
}

///|
/// 扩张球体以包含这个点。空球变成以该点为心、半径为零的球。点不改。
/// r186: `expandByPoint` https://github.com/mrdoob/three.js/blob/r186/src/math/Sphere.js#L293
pub fn Sphere::expand_by_point(self : Sphere, point : Vector3) -> Sphere {
  if self.is_empty() {
    ignore(self.center.copy(point))
    self.radius = 0.0
    return self
  }
  let direction = Vector3::new().sub_vectors(point, self.center)
  let length_sq = direction.length_sq()
  if length_sq > self.radius * self.radius {
    let length = length_sq.sqrt()
    let delta = (length - self.radius) * 0.5
    ignore(self.center.add_scaled_vector(direction, delta / length))
    self.radius = self.radius + delta
  }
  self
}

///|
/// 扩张球体以包住另一个球。对方为空则不动。另一个球不改。
/// r186: `union` https://github.com/mrdoob/three.js/blob/r186/src/math/Sphere.js#L333
pub fn Sphere::union(self : Sphere, sphere : Sphere) -> Sphere {
  if sphere.is_empty() {
    return self
  }
  if self.is_empty() {
    return self.copy(sphere)
  }
  if self.center.equals(sphere.center) {
    self.radius = self.radius.max(sphere.radius)
  } else {
    let direction = Vector3::new()
      .sub_vectors(sphere.center, self.center)
      .set_length(sphere.radius)
    ignore(
      self.expand_by_point(Vector3::new().copy(sphere.center).add(direction)),
    )
    ignore(
      self.expand_by_point(Vector3::new().copy(sphere.center).sub(direction)),
    )
  }
  self
}

///|
/// 球心和半径都相同则为真。两个球都不改。
/// r186: `equals` https://github.com/mrdoob/three.js/blob/r186/src/math/Sphere.js#L373
pub fn Sphere::equals(self : Sphere, sphere : Sphere) -> Bool {
  sphere.center.equals(self.center) && sphere.radius == self.radius
}

///|
/// 返回一个新球。来源不改。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/math/Sphere.js#L384
pub fn Sphere::clone(self : Sphere) -> Sphere {
  Sphere::new().copy(self)
}

///|
/// 把球心写成数组，并带上半径。改数组不影响球。
/// r186: `toJSON` https://github.com/mrdoob/three.js/blob/r186/src/math/Sphere.js#L395
pub fn Sphere::to_json(self : Sphere) -> (Array[Double], Double) {
  (self.center.to_array(), self.radius)
}
