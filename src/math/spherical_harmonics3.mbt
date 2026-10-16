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

///|
/// 求单位法线方向上的辐射亮度。法线本身不改。
/// r186: `getAt` https://github.com/mrdoob/three.js/blob/r186/src/math/SphericalHarmonics3.js#L84
pub fn SphericalHarmonics3::get_at(
  self : SphericalHarmonics3,
  normal : Vector3,
  target : Vector3,
) -> Vector3 {
  let x = normal.x
  let y = normal.y
  let z = normal.z
  let coeff = self.coefficients
  ignore(
    target
      .copy(coeff[0])
      .multiply_scalar(0.282095)
      .add_scaled_vector(coeff[1], 0.488603 * y)
      .add_scaled_vector(coeff[2], 0.488603 * z)
      .add_scaled_vector(coeff[3], 0.488603 * x)
      .add_scaled_vector(coeff[4], 1.092548 * (x * y))
      .add_scaled_vector(coeff[5], 1.092548 * (y * z))
      .add_scaled_vector(coeff[6], 0.315392 * (3.0 * z * z - 1.0))
      .add_scaled_vector(coeff[7], 1.092548 * (x * z))
      .add_scaled_vector(coeff[8], 0.546274 * (x * x - y * y)),
  )
  target
}
