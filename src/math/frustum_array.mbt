// r186: `FrustumArray` https://github.com/mrdoob/three.js/blob/r186/src/math/FrustumArray.js#L11

///|
/// 一组视锥。初始没有视锥，坐标系是 WebGL。
/// r186: `FrustumArray` https://github.com/mrdoob/three.js/blob/r186/src/math/FrustumArray.js#L11
pub(all) struct FrustumArray {
  mut coordinate_system : @constants.CoordinateSystem
  frustums : Array[Frustum]
  mut count : Int
}

///|
/// r186: `constructor` https://github.com/mrdoob/three.js/blob/r186/src/math/FrustumArray.js#L17
pub fn FrustumArray::new() -> FrustumArray {
  { coordinate_system: @constants.WebGL, frustums: [], count: 0 }
}

///|
/// 球是否碰到任一已用视锥。`count` 为 0 时为 false。
/// `setFromArrayCamera` 需要 `ArrayCamera`，`intersectsObject` 需要 `Object3D`，`intersectsSprite` 需要精灵，这三项留在后面。
/// r186: `intersectsSphere` https://github.com/mrdoob/three.js/blob/r186/src/math/FrustumArray.js#L130
pub fn FrustumArray::intersects_sphere(
  self : FrustumArray,
  sphere : Sphere,
) -> Bool {
  for i in 0..<self.count {
    if self.frustums[i].intersects_sphere(sphere) {
      return true
    }
  }
  false
}

///|
/// 盒子是否碰到任一已用视锥。`count` 为 0 时为 false。
/// r186: `intersectsBox` https://github.com/mrdoob/three.js/blob/r186/src/math/FrustumArray.js#L152
pub fn FrustumArray::intersects_box(self : FrustumArray, box : Box3) -> Bool {
  for i in 0..<self.count {
    if self.frustums[i].intersects_box(box) {
      return true
    }
  }
  false
}
