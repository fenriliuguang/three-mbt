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
