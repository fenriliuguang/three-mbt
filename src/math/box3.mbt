// r186: `Box3` https://github.com/mrdoob/three.js/blob/r186/src/math/Box3.js#L6

///|
/// 轴对齐包围盒。空盒的下界是 +∞，上界是 -∞，与 r186 `Box3` 相同。
/// r186: `Box3` https://github.com/mrdoob/three.js/blob/r186/src/math/Box3.js#L6
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
/// 沿向量向两侧扩张。向量本身不改。
/// r186: `expandByVector` https://github.com/mrdoob/three.js/blob/r186/src/math/Box3.js#L267
pub fn Box3::expand_by_vector(self : Box3, vector : Vector3) -> Box3 {
  ignore(self.min.sub(vector))
  ignore(self.max.add(vector))
  self
}

///|
/// 每个方向都按标量扩张。负数则收缩。
/// r186: `expandByScalar` https://github.com/mrdoob/three.js/blob/r186/src/math/Box3.js#L283
pub fn Box3::expand_by_scalar(self : Box3, scalar : Double) -> Box3 {
  ignore(self.min.add_scalar(-scalar))
  ignore(self.max.add_scalar(scalar))
  self
}

///|
/// 点在盒内或边界上则为真。点和盒子都不改。
/// r186: `containsPoint` https://github.com/mrdoob/three.js/blob/r186/src/math/Box3.js#L393
pub fn Box3::contains_point(self : Box3, point : Vector3) -> Bool {
  point.x >= self.min.x &&
  point.x <= self.max.x &&
  point.y >= self.min.y &&
  point.y <= self.max.y &&
  point.z >= self.min.z &&
  point.z <= self.max.z
}

///|
/// 整个盒子都在内部或边界上则为真。两个盒子都不改。
/// r186: `containsBox` https://github.com/mrdoob/three.js/blob/r186/src/math/Box3.js#L408
pub fn Box3::contains_box(self : Box3, box : Box3) -> Bool {
  self.min.x <= box.min.x &&
  box.max.x <= self.max.x &&
  self.min.y <= box.min.y &&
  box.max.y <= self.max.y &&
  self.min.z <= box.min.z &&
  box.max.z <= self.max.z
}

///|
/// 把点写成相对宽高深的比例，写入 target。点和盒子都不改。
/// r186: `getParameter` https://github.com/mrdoob/three.js/blob/r186/src/math/Box3.js#L423
pub fn Box3::get_parameter(
  self : Box3,
  point : Vector3,
  target : Vector3,
) -> Vector3 {
  target.set(
    (point.x - self.min.x) / (self.max.x - self.min.x),
    (point.y - self.min.y) / (self.max.y - self.min.y),
    (point.z - self.min.z) / (self.max.z - self.min.z),
  )
}

///|
/// 两个盒子有重叠或贴边则为真。两个盒子都不改。
/// r186: `intersectsBox` https://github.com/mrdoob/three.js/blob/r186/src/math/Box3.js#L442
pub fn Box3::intersects_box(self : Box3, box : Box3) -> Bool {
  box.max.x >= self.min.x &&
  box.min.x <= self.max.x &&
  box.max.y >= self.min.y &&
  box.min.y <= self.max.y &&
  box.max.z >= self.min.z &&
  box.min.z <= self.max.z
}

///|
/// 把点夹进盒子，写入 target。点和盒子都不改。
/// r186: `clampPoint` https://github.com/mrdoob/three.js/blob/r186/src/math/Box3.js#L586
pub fn Box3::clamp_point(
  self : Box3,
  point : Vector3,
  target : Vector3,
) -> Vector3 {
  target.copy(point).clamp(self.min, self.max)
}

///|
/// 球与盒子相交或相切则为真。球和盒子都不改。
/// r186: `intersectsSphere` https://github.com/mrdoob/three.js/blob/r186/src/math/Box3.js#L457
pub fn Box3::intersects_sphere(self : Box3, sphere : Sphere) -> Bool {
  let closest = self.clamp_point(sphere.center, Vector3::new())
  closest.distance_to_squared(sphere.center) <= sphere.radius * sphere.radius
}

///|
/// 平面穿过盒子或贴到面上则为真。平面和盒子都不改。
/// r186: `intersectsPlane` https://github.com/mrdoob/three.js/blob/r186/src/math/Box3.js#L473
pub fn Box3::intersects_plane(self : Box3, plane : Plane) -> Bool {
  let mut min = 0.0
  let mut max = 0.0
  if plane.normal.x > 0.0 {
    min = plane.normal.x * self.min.x
    max = plane.normal.x * self.max.x
  } else {
    min = plane.normal.x * self.max.x
    max = plane.normal.x * self.min.x
  }
  if plane.normal.y > 0.0 {
    min = min + plane.normal.y * self.min.y
    max = max + plane.normal.y * self.max.y
  } else {
    min = min + plane.normal.y * self.max.y
    max = max + plane.normal.y * self.min.y
  }
  if plane.normal.z > 0.0 {
    min = min + plane.normal.z * self.min.z
    max = max + plane.normal.z * self.max.z
  } else {
    min = min + plane.normal.z * self.max.z
    max = max + plane.normal.z * self.min.z
  }
  let limit = -plane.constant
  min <= limit && max >= limit
}

///|
/// 盒外点到最近边界的距离。盒内为 0。点和盒子都不改。
/// r186: `distanceToPoint` https://github.com/mrdoob/three.js/blob/r186/src/math/Box3.js#L599
pub fn Box3::distance_to_point(self : Box3, point : Vector3) -> Double {
  self.clamp_point(point, Vector3::new()).distance_to(point)
}

///|
/// 把包围球写入 target。空盒写入空球。盒子本身不改。
/// r186: `getBoundingSphere` https://github.com/mrdoob/three.js/blob/r186/src/math/Box3.js#L611
pub fn Box3::get_bounding_sphere(self : Box3, target : Sphere) -> Sphere {
  if self.is_empty() {
    ignore(target.make_empty())
  } else {
    ignore(self.get_center(target.center))
    target.radius = self.get_size(Vector3::new()).length() * 0.5
  }
  target
}

///|
/// 收成两个盒子的重叠部分。没有重叠则清空。另一个盒子不改。
/// r186: `intersect` https://github.com/mrdoob/three.js/blob/r186/src/math/Box3.js#L638
pub fn Box3::intersect(self : Box3, box : Box3) -> Box3 {
  ignore(self.min.max(box.min))
  ignore(self.max.min(box.max))
  if self.is_empty() {
    ignore(self.make_empty())
  }
  self
}

///|
/// 上下界都加上偏移。偏移本身不改。
/// r186: `translate` https://github.com/mrdoob/three.js/blob/r186/src/math/Box3.js#L701
pub fn Box3::translate(self : Box3, offset : Vector3) -> Box3 {
  ignore(self.min.add(offset))
  ignore(self.max.add(offset))
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
/// 先清空，再纳入数组里每三个数组成的点。数组不改。
/// r186: `setFromArray` https://github.com/mrdoob/three.js/blob/r186/src/math/Box3.js#L65
pub fn Box3::set_from_array(self : Box3, array : Array[Double]) -> Box3 {
  ignore(self.make_empty())
  let point = Vector3::new()
  let mut i = 0
  while i + 2 < array.length() {
    ignore(point.from_array(array, offset=i))
    ignore(self.expand_by_point(point))
    i = i + 3
  }
  self
}

///|
/// 以中心和尺寸重设盒子。中心和尺寸不改。
/// r186: `setFromCenterAndSize` https://github.com/mrdoob/three.js/blob/r186/src/math/Box3.js#L129
pub fn Box3::set_from_center_and_size(
  self : Box3,
  center : Vector3,
  size : Vector3,
) -> Box3 {
  let half_size = size.clone().multiply_scalar(0.5)
  ignore(self.min.copy(center).sub(half_size))
  ignore(self.max.copy(center).add(half_size))
  self
}

///|
/// 复制另一个盒子的两个角点。来源不改。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/math/Box3.js#L180
pub fn Box3::copy(self : Box3, box : Box3) -> Box3 {
  ignore(self.min.copy(box.min))
  ignore(self.max.copy(box.max))
  self
}

///|
/// 返回一份新的盒子。来源不改。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/math/Box3.js#L168
pub fn Box3::clone(self : Box3) -> Box3 {
  Box3::empty().copy(self)
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
