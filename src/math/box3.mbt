///|
/// 轴对齐包围盒。空盒的下界是 +∞，上界是 -∞，与 r186 `Box3` 相同。
pub(all) struct Box3 {
  min : Vector3
  max : Vector3
}

///|
pub fn Box3::empty() -> Box3 {
  {
    min: Vector3::new(
      x=@double.infinity,
      y=@double.infinity,
      z=@double.infinity,
    ),
    max: Vector3::new(
      x=@double.neg_infinity,
      y=@double.neg_infinity,
      z=@double.neg_infinity,
    ),
  }
}

///|
pub fn Box3::new(min : Vector3, max : Vector3) -> Box3 {
  { min: min.clone(), max: max.clone(), }
}

///|
pub fn Box3::set(self : Box3, min : Vector3, max : Vector3) -> Box3 {
  ignore(self.min.copy(min))
  ignore(self.max.copy(max))
  self
}

///|
pub fn Box3::make_empty(self : Box3) -> Box3 {
  ignore(self.min.set(@double.infinity, @double.infinity, @double.infinity))
  ignore(
    self.max.set(
      @double.neg_infinity, @double.neg_infinity, @double.neg_infinity,
    ),
  )
  self
}

///|
pub fn Box3::is_empty(self : Box3) -> Bool {
  self.max.x < self.min.x || self.max.y < self.min.y || self.max.z < self.min.z
}

///|
pub fn Box3::expand_by_point(self : Box3, point : Vector3) -> Box3 {
  ignore(self.min.min(point))
  ignore(self.max.max(point))
  self
}

///|
pub fn Box3::set_from_points(self : Box3, points : Array[Vector3]) -> Box3 {
  ignore(self.make_empty())
  for point in points {
    ignore(self.expand_by_point(point))
  }
  self
}

///|
pub fn Box3::get_center(self : Box3, target : Vector3) -> Vector3 {
  if self.is_empty() {
    target.set(0.0, 0.0, 0.0)
  } else {
    target.add_vectors(self.min, self.max).multiply_scalar(0.5)
  }
}

///|
pub fn Box3::get_size(self : Box3, target : Vector3) -> Vector3 {
  if self.is_empty() {
    target.set(0.0, 0.0, 0.0)
  } else {
    target.sub_vectors(self.max, self.min)
  }
}

///|
pub fn Box3::apply_matrix4(self : Box3, matrix : Matrix4) -> Box3 {
  if self.is_empty() {
    return self
  }
  let points = [
    Vector3::new(x=self.min.x, y=self.min.y, z=self.min.z).apply_matrix4(matrix),
    Vector3::new(x=self.min.x, y=self.min.y, z=self.max.z).apply_matrix4(matrix),
    Vector3::new(x=self.min.x, y=self.max.y, z=self.min.z).apply_matrix4(matrix),
    Vector3::new(x=self.min.x, y=self.max.y, z=self.max.z).apply_matrix4(matrix),
    Vector3::new(x=self.max.x, y=self.min.y, z=self.min.z).apply_matrix4(matrix),
    Vector3::new(x=self.max.x, y=self.min.y, z=self.max.z).apply_matrix4(matrix),
    Vector3::new(x=self.max.x, y=self.max.y, z=self.min.z).apply_matrix4(matrix),
    Vector3::new(x=self.max.x, y=self.max.y, z=self.max.z).apply_matrix4(matrix),
  ]
  self.set_from_points(points)
}

///|
pub fn Box3::union(self : Box3, box : Box3) -> Box3 {
  ignore(self.min.min(box.min))
  ignore(self.max.max(box.max))
  self
}
