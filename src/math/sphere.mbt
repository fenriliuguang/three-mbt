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
