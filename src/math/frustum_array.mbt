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
