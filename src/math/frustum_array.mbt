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

///|
/// 点是否落在任一已用视锥内。`count` 为 0 时为 false。
/// r186: `containsPoint` https://github.com/mrdoob/three.js/blob/r186/src/math/FrustumArray.js#L174
pub fn FrustumArray::contains_point(
  self : FrustumArray,
  point : Vector3,
) -> Bool {
  for i in 0..<self.count {
    if self.frustums[i].contains_point(point) {
      return true
    }
  }
  false
}

///|
/// 复制坐标系和已用视锥。目标更短时补上新视锥，更长时多出来的视锥留在原处。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/math/FrustumArray.js#L194
pub fn FrustumArray::copy(
  self : FrustumArray,
  source : FrustumArray,
) -> FrustumArray {
  self.coordinate_system = source.coordinate_system
  for i in 0..<source.count {
    if i >= self.frustums.length() {
      self.frustums.push(Frustum::new())
    }
    ignore(self.frustums[i].copy(source.frustums[i]))
  }
  self.count = source.count
  self
}

///|
/// 复制出一份新的视锥数组。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/math/FrustumArray.js#L220
pub fn FrustumArray::clone(self : FrustumArray) -> FrustumArray {
  FrustumArray::new().copy(self)
}
