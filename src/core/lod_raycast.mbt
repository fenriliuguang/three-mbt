// r186: `raycast` https://github.com/mrdoob/three.js/blob/r186/src/objects/LOD.js#L228 ; `levels` https://github.com/mrdoob/three.js/blob/r186/src/objects/LOD.js#L69

///|
/// 上游没有单独的类。每一级是 `levels` 里的对象、距离和滞后。
/// r186: `levels` https://github.com/mrdoob/three.js/blob/r186/src/objects/LOD.js#L69
pub(all) struct LodLevel {
  object : Object3D
  distance : Double
  hysteresis : Double
}

///|
/// 返回第一个距离阈值大于给定距离的前一级对象。对象可见时，阈值会减去 `distance * hysteresis`。没有级别时返回空。
/// r186: `getObjectForDistance` https://github.com/mrdoob/three.js/blob/r186/src/objects/LOD.js#L188
pub fn lod_object_for_distance(
  levels : Array[LodLevel],
  distance : Double,
) -> Object3D? {
  let count = levels.length()
  if count == 0 {
    return None
  }
  let mut i = 1
  while i < count {
    let level = levels[i]
    let mut level_distance = level.distance
    if level.object.visible {
      level_distance = level_distance - level_distance * level.hysteresis
    }
    if distance < level_distance {
      break
    }
    i = i + 1
  }
  Some(levels[i - 1].object)
}

///|
/// 用射线原点到 LOD 世界位置的距离选出一级，只测试那一个对象。
/// r186: `raycast` https://github.com/mrdoob/three.js/blob/r186/src/objects/LOD.js#L228
fn Object3D::raycast_lod(
  self : Object3D,
  raycaster : Raycaster,
  intersects : Array[Intersection],
) -> Unit {
  let levels = match self.lod_levels {
    None => return
    Some(levels) => levels
  }
  let position = @math.Vector3::new().set_from_matrix_position(self.matrix_world)
  match lod_object_for_distance(
    levels,
    raycaster.ray.origin.distance_to(position),
  ) {
    None => ()
    Some(object) => ignore(object.raycast(raycaster, intersects))
  }
}
