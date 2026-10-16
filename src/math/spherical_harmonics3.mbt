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

///|
/// 把九个系数复制进来。来源之后再改，不影响这里。
/// r186: `set` https://github.com/mrdoob/three.js/blob/r186/src/math/SphericalHarmonics3.js#L48
pub fn SphericalHarmonics3::set(
  self : SphericalHarmonics3,
  coefficients : Array[Vector3],
) -> SphericalHarmonics3 {
  for i in 0..<9 {
    ignore(self.coefficients[i].copy(coefficients[i]))
  }
  self
}

///|
/// 把九个系数都写成零。
/// r186: `zero` https://github.com/mrdoob/three.js/blob/r186/src/math/SphericalHarmonics3.js#L65
pub fn SphericalHarmonics3::zero(self : SphericalHarmonics3) -> SphericalHarmonics3 {
  for i in 0..<9 {
    ignore(self.coefficients[i].set(0.0, 0.0, 0.0))
  }
  self
}
