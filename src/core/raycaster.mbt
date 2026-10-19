// r186: `Raycaster` https://github.com/mrdoob/three.js/blob/r186/src/core/Raycaster.js#L13

///|
/// 从一条射线挑出场景里的交点。缺省原点是 `(0, 0, 0)`，方向是 `(0, 0, -1)`。`near` 默认是 `0`，`far` 默认是正无穷。
/// r186: `Raycaster` https://github.com/mrdoob/three.js/blob/r186/src/core/Raycaster.js#L13
/// r186: `ray` https://github.com/mrdoob/three.js/blob/r186/src/core/Raycaster.js#L30
/// r186: `near` https://github.com/mrdoob/three.js/blob/r186/src/core/Raycaster.js#L38
/// r186: `far` https://github.com/mrdoob/three.js/blob/r186/src/core/Raycaster.js#L46
pub(all) struct Raycaster {
  ray : @math.Ray
  mut near : Double
  mut far : Double
}

///|
pub fn Raycaster::new(
  origin? : @math.Vector3,
  direction? : @math.Vector3,
  near? : Double = 0.0,
  far? : Double = 1.0 / 0.0,
) -> Raycaster {
  let ray = @math.Ray::new()
  match origin {
    None => ()
    Some(origin) => ignore(ray.origin.copy(origin))
  }
  match direction {
    None => ()
    Some(direction) => ignore(ray.direction.copy(direction))
  }
  { ray, near, far }
}

///|
/// 用新的原点和方向更新射线。方向按已经归一化处理，这里不再归一化。之后改来源向量不影响射线。
/// r186: `set` https://github.com/mrdoob/three.js/blob/r186/src/core/Raycaster.js#L104
pub fn Raycaster::set(
  self : Raycaster,
  origin : @math.Vector3,
  direction : @math.Vector3,
) -> Unit {
  ignore(self.ray.set(origin, direction))
}
