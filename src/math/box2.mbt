// r186: `Box2` https://github.com/mrdoob/three.js/blob/r186/src/math/Box2.js#L8

///|
/// 二维轴对齐包围盒。缺省下界是 +∞，上界是 -∞。
/// r186: `Box2` https://github.com/mrdoob/three.js/blob/r186/src/math/Box2.js#L8
pub(all) struct Box2 {
  min : Vector2
  max : Vector2
}

///|
pub fn Box2::new(min? : Vector2, max? : Vector2) -> Box2 {
  let min = match min {
    None => Vector2::new(x=@double.infinity, y=@double.infinity)
    Some(min) => min.clone()
  }
  let max = match max {
    None => Vector2::new(x=@double.neg_infinity, y=@double.neg_infinity)
    Some(max) => max.clone()
  }
  { min, max }
}

///|
/// 复制两个角点。来源不改。
/// r186: `set` https://github.com/mrdoob/three.js/blob/r186/src/math/Box2.js#L51
pub fn Box2::set(self : Box2, min : Vector2, max : Vector2) -> Box2 {
  ignore(self.min.copy(min))
  ignore(self.max.copy(max))
  self
}

///|
/// 下界设为 +∞，上界设为 -∞。
/// r186: `makeEmpty` https://github.com/mrdoob/three.js/blob/r186/src/math/Box2.js#L130
pub fn Box2::make_empty(self : Box2) -> Box2 {
  self.min.x = @double.infinity
  self.min.y = @double.infinity
  self.max.x = @double.neg_infinity
  self.max.y = @double.neg_infinity
  self
}

///|
/// 把盒子扩到包含这个点。点本身不改。
/// r186: `expandByPoint` https://github.com/mrdoob/three.js/blob/r186/src/math/Box2.js#L184
pub fn Box2::expand_by_point(self : Box2, point : Vector2) -> Box2 {
  ignore(self.min.min(point))
  ignore(self.max.max(point))
  self
}

///|
/// 先清空，再纳入每个点。点本身不改。
/// r186: `setFromPoints` https://github.com/mrdoob/three.js/blob/r186/src/math/Box2.js#L67
pub fn Box2::set_from_points(self : Box2, points : Array[Vector2]) -> Box2 {
  ignore(self.make_empty())
  for point in points {
    ignore(self.expand_by_point(point))
  }
  self
}

///|
/// 以中心和尺寸重设盒子。中心和尺寸不改。
/// r186: `setFromCenterAndSize` https://github.com/mrdoob/three.js/blob/r186/src/math/Box2.js#L89
pub fn Box2::set_from_center_and_size(
  self : Box2,
  center : Vector2,
  size : Vector2,
) -> Box2 {
  let half_size = size.clone().multiply_scalar(0.5)
  ignore(self.min.copy(center).sub(half_size))
  ignore(self.max.copy(center).add(half_size))
  self
}

///|
/// 复制另一个盒子的两个角点。来源不改。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/math/Box2.js#L116
pub fn Box2::copy(self : Box2, box : Box2) -> Box2 {
  ignore(self.min.copy(box.min))
  ignore(self.max.copy(box.max))
  self
}

///|
/// 返回一份新的盒子。来源不改。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/math/Box2.js#L104
pub fn Box2::clone(self : Box2) -> Box2 {
  Box2::new().copy(self)
}

///|
/// 任一轴上界小于下界则为空。上下界相等不算空。
/// r186: `isEmpty` https://github.com/mrdoob/three.js/blob/r186/src/math/Box2.js#L146
pub fn Box2::is_empty(self : Box2) -> Bool {
  self.max.x < self.min.x || self.max.y < self.min.y
}

///|
/// 把中心写入 target。空盒写入 (0, 0)。盒子本身不改。
/// r186: `getCenter` https://github.com/mrdoob/three.js/blob/r186/src/math/Box2.js#L160
pub fn Box2::get_center(self : Box2, target : Vector2) -> Vector2 {
  if self.is_empty() {
    target.set(0.0, 0.0)
  } else {
    target.add_vectors(self.min, self.max).multiply_scalar(0.5)
  }
}

///|
/// 把尺寸写入 target。空盒写入 (0, 0)。盒子本身不改。
/// r186: `getSize` https://github.com/mrdoob/three.js/blob/r186/src/math/Box2.js#L172
pub fn Box2::get_size(self : Box2, target : Vector2) -> Vector2 {
  if self.is_empty() {
    target.set(0.0, 0.0)
  } else {
    target.sub_vectors(self.max, self.min)
  }
}

///|
/// 沿向量向两侧扩张。向量本身不改。
/// r186: `expandByVector` https://github.com/mrdoob/three.js/blob/r186/src/math/Box2.js#L202
pub fn Box2::expand_by_vector(self : Box2, vector : Vector2) -> Box2 {
  ignore(self.min.sub(vector))
  ignore(self.max.add(vector))
  self
}

///|
/// 每个方向都按标量扩张。负数则收缩。
/// r186: `expandByScalar` https://github.com/mrdoob/three.js/blob/r186/src/math/Box2.js#L218
pub fn Box2::expand_by_scalar(self : Box2, scalar : Double) -> Box2 {
  ignore(self.min.add_scalar(-scalar))
  ignore(self.max.add_scalar(scalar))
  self
}

///|
/// 点在盒内或边界上则为真。点和盒子都不改。
/// r186: `containsPoint` https://github.com/mrdoob/three.js/blob/r186/src/math/Box2.js#L233
pub fn Box2::contains_point(self : Box2, point : Vector2) -> Bool {
  point.x >= self.min.x &&
  point.x <= self.max.x &&
  point.y >= self.min.y &&
  point.y <= self.max.y
}

///|
/// 整个盒子都在内部或边界上则为真。两个盒子都不改。
/// r186: `containsBox` https://github.com/mrdoob/three.js/blob/r186/src/math/Box2.js#L247
pub fn Box2::contains_box(self : Box2, box : Box2) -> Bool {
  self.min.x <= box.min.x &&
  box.max.x <= self.max.x &&
  self.min.y <= box.min.y &&
  box.max.y <= self.max.y
}

///|
/// 把点写成相对宽高的比例，写入 target。点和盒子都不改。
/// r186: `getParameter` https://github.com/mrdoob/three.js/blob/r186/src/math/Box2.js#L261
pub fn Box2::get_parameter(
  self : Box2,
  point : Vector2,
  target : Vector2,
) -> Vector2 {
  target.set(
    (point.x - self.min.x) / (self.max.x - self.min.x),
    (point.y - self.min.y) / (self.max.y - self.min.y),
  )
}

///|
/// 两个盒子有重叠或贴边则为真。两个盒子都不改。
/// r186: `intersectsBox` https://github.com/mrdoob/three.js/blob/r186/src/math/Box2.js#L279
pub fn Box2::intersects_box(self : Box2, box : Box2) -> Bool {
  box.max.x >= self.min.x &&
  box.min.x <= self.max.x &&
  box.max.y >= self.min.y &&
  box.min.y <= self.max.y
}

///|
/// 把点夹进盒子，写入 target。点和盒子都不改。
/// r186: `clampPoint` https://github.com/mrdoob/three.js/blob/r186/src/math/Box2.js#L295
pub fn Box2::clamp_point(
  self : Box2,
  point : Vector2,
  target : Vector2,
) -> Vector2 {
  target.copy(point).clamp(self.min, self.max)
}

///|
/// 盒外点到最近边界的距离。盒内为 0。点和盒子都不改。
/// r186: `distanceToPoint` https://github.com/mrdoob/three.js/blob/r186/src/math/Box2.js#L308
pub fn Box2::distance_to_point(self : Box2, point : Vector2) -> Double {
  self.clamp_point(point, Vector2::new()).distance_to(point)
}

///|
/// 收成两个盒子的重叠部分。没有重叠则清空。另一个盒子不改。
/// r186: `intersect` https://github.com/mrdoob/three.js/blob/r186/src/math/Box2.js#L323
pub fn Box2::intersect(self : Box2, box : Box2) -> Box2 {
  ignore(self.min.max(box.min))
  ignore(self.max.min(box.max))
  if self.is_empty() {
    ignore(self.make_empty())
  }
  self
}

///|
/// 扩成能包住两个盒子的范围。另一个盒子不改。
/// r186: `union` https://github.com/mrdoob/three.js/blob/r186/src/math/Box2.js#L342
pub fn Box2::union(self : Box2, box : Box2) -> Box2 {
  ignore(self.min.min(box.min))
  ignore(self.max.max(box.max))
  self
}
