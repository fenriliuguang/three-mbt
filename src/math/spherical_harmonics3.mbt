// r186: `SphericalHarmonics3` https://github.com/mrdoob/three.js/blob/r186/src/math/SphericalHarmonics3.js#L10

///|
/// 三阶球谐。九个系数都是零向量。
/// r186: `SphericalHarmonics3` https://github.com/mrdoob/three.js/blob/r186/src/math/SphericalHarmonics3.js#L10
pub(all) struct SphericalHarmonics3 {
  coefficients : Array[Vector3]
}

///|
fn sh3_coefficients() -> Array[Vector3] {
  let coefficients = []
  for _ in 0..<9 {
    coefficients.push(Vector3::new())
  }
  coefficients
}

///|
/// r186: `constructor` https://github.com/mrdoob/three.js/blob/r186/src/math/SphericalHarmonics3.js#L15
pub fn SphericalHarmonics3::new() -> SphericalHarmonics3 {
  { coefficients: sh3_coefficients(), }
}
