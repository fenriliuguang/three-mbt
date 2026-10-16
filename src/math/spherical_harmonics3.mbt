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

///|
/// 求单位法线方向上的辐照度。法线本身不改。
/// r186: `getIrradianceAt` https://github.com/mrdoob/three.js/blob/r186/src/math/SphericalHarmonics3.js#L119
pub fn SphericalHarmonics3::get_irradiance_at(
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
      .multiply_scalar(0.886227)
      .add_scaled_vector(coeff[1], 2.0 * 0.511664 * y)
      .add_scaled_vector(coeff[2], 2.0 * 0.511664 * z)
      .add_scaled_vector(coeff[3], 2.0 * 0.511664 * x)
      .add_scaled_vector(coeff[4], 2.0 * 0.429043 * x * y)
      .add_scaled_vector(coeff[5], 2.0 * 0.429043 * y * z)
      .add_scaled_vector(coeff[6], 0.743125 * z * z - 0.247708)
      .add_scaled_vector(coeff[7], 2.0 * 0.429043 * x * z)
      .add_scaled_vector(coeff[8], 0.429043 * (x * x - y * y)),
  )
  target
}

///|
/// 把另一组球谐的九个系数加进来。来源不改。
/// r186: `add` https://github.com/mrdoob/three.js/blob/r186/src/math/SphericalHarmonics3.js#L152
pub fn SphericalHarmonics3::add(
  self : SphericalHarmonics3,
  sh : SphericalHarmonics3,
) -> SphericalHarmonics3 {
  for i in 0..<9 {
    ignore(self.coefficients[i].add(sh.coefficients[i]))
  }
  self
}

///|
/// 把另一组球谐按标量放大后加进来。来源不改。
/// r186: `addScaledSH` https://github.com/mrdoob/three.js/blob/r186/src/math/SphericalHarmonics3.js#L172
pub fn SphericalHarmonics3::add_scaled_sh(
  self : SphericalHarmonics3,
  sh : SphericalHarmonics3,
  s : Double,
) -> SphericalHarmonics3 {
  for i in 0..<9 {
    ignore(self.coefficients[i].add_scaled_vector(sh.coefficients[i], s))
  }
  self
}

///|
/// 把九个系数都乘上同一个标量。
/// r186: `scale` https://github.com/mrdoob/three.js/blob/r186/src/math/SphericalHarmonics3.js#L190
pub fn SphericalHarmonics3::scale(
  self : SphericalHarmonics3,
  s : Double,
) -> SphericalHarmonics3 {
  for i in 0..<9 {
    ignore(self.coefficients[i].multiply_scalar(s))
  }
  self
}

///|
/// 向另一组球谐插值。来源不改。
/// r186: `lerp` https://github.com/mrdoob/three.js/blob/r186/src/math/SphericalHarmonics3.js#L210
pub fn SphericalHarmonics3::lerp(
  self : SphericalHarmonics3,
  sh : SphericalHarmonics3,
  alpha : Double,
) -> SphericalHarmonics3 {
  for i in 0..<9 {
    ignore(self.coefficients[i].lerp(sh.coefficients[i], alpha))
  }
  self
}

///|
/// 九个系数都相同才相等。
/// r186: `equals` https://github.com/mrdoob/three.js/blob/r186/src/math/SphericalHarmonics3.js#L228
pub fn SphericalHarmonics3::equals(
  self : SphericalHarmonics3,
  sh : SphericalHarmonics3,
) -> Bool {
  for i in 0..<9 {
    if !self.coefficients[i].equals(sh.coefficients[i]) {
      return false
    }
  }
  true
}

///|
/// 复制另一组球谐。来源之后再改，不影响这里。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/math/SphericalHarmonics3.js#L250
pub fn SphericalHarmonics3::copy(
  self : SphericalHarmonics3,
  sh : SphericalHarmonics3,
) -> SphericalHarmonics3 {
  self.set(sh.coefficients)
}

///|
/// 复制出一组新的球谐。原对象之后再改，不影响副本。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/math/SphericalHarmonics3.js#L261
pub fn SphericalHarmonics3::clone(self : SphericalHarmonics3) -> SphericalHarmonics3 {
  SphericalHarmonics3::new().copy(self)
}

///|
/// 从扁平数组读入九个系数，每个系数三个数。
/// r186: `fromArray` https://github.com/mrdoob/three.js/blob/r186/src/math/SphericalHarmonics3.js#L274
pub fn SphericalHarmonics3::from_array(
  self : SphericalHarmonics3,
  array : Array[Double],
  offset? : Int = 0,
) -> SphericalHarmonics3 {
  for i in 0..<9 {
    ignore(self.coefficients[i].from_array(array, offset=offset + i * 3))
  }
  self
}

///|
/// 省略数组时新建一个。短于 `offset + 27` 的数组会补零再写入。球谐本身不改。
/// r186: `toArray` https://github.com/mrdoob/three.js/blob/r186/src/math/SphericalHarmonics3.js#L296
pub fn SphericalHarmonics3::to_array(
  self : SphericalHarmonics3,
  array? : Array[Double],
  offset? : Int = 0,
) -> Array[Double] {
  let mut target = match array {
    None => []
    Some(array) => array
  }
  for i in 0..<9 {
    target = self.coefficients[i].to_array(array=target, offset=offset + i * 3)
  }
  target
}

///|
/// 把单位法线展开成九个球谐基。短于 9 的数组会补零再写入。法线本身不改。
/// r186: `getBasisAt` https://github.com/mrdoob/three.js/blob/r186/src/math/SphericalHarmonics3.js#L316
pub fn SphericalHarmonics3::get_basis_at(
  normal : Vector3,
  sh_basis : Array[Double],
) -> Unit {
  while sh_basis.length() < 9 {
    sh_basis.push(0.0)
  }
  let x = normal.x
  let y = normal.y
  let z = normal.z
  sh_basis[0] = 0.282095
  sh_basis[1] = 0.488603 * y
  sh_basis[2] = 0.488603 * z
  sh_basis[3] = 0.488603 * x
  sh_basis[4] = 1.092548 * x * y
  sh_basis[5] = 1.092548 * y * z
  sh_basis[6] = 0.315392 * (3.0 * z * z - 1.0)
  sh_basis[7] = 1.092548 * x * z
  sh_basis[8] = 0.546274 * (x * x - y * y)
}
