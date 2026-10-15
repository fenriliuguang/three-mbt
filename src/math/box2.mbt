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
