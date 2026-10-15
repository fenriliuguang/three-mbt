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
