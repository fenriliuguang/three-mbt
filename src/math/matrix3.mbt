// r186: `Matrix3` https://github.com/mrdoob/three.js/blob/r186/src/math/Matrix3.js#L31

///|
/// 列主序 3×3 矩阵。`set` 的参数按行主序书写，与 r186 `Matrix3` 相同。
/// r186: `Matrix3` https://github.com/mrdoob/three.js/blob/r186/src/math/Matrix3.js#L31
pub(all) struct Matrix3 {
  elements : FixedArray[Double]
}

///|
fn matrix3_elements() -> FixedArray[Double] {
  let te = FixedArray::make(9, 0.0)
  te[0] = 1.0
  te[4] = 1.0
  te[8] = 1.0
  te
}

///|
pub fn Matrix3::new() -> Matrix3 {
  { elements: matrix3_elements(), }
}

///|
pub fn Matrix3::set(
  self : Matrix3,
  n11 : Double,
  n12 : Double,
  n13 : Double,
  n21 : Double,
  n22 : Double,
  n23 : Double,
  n31 : Double,
  n32 : Double,
  n33 : Double,
) -> Matrix3 {
  let te = self.elements
  te[0] = n11
  te[1] = n21
  te[2] = n31
  te[3] = n12
  te[4] = n22
  te[5] = n32
  te[6] = n13
  te[7] = n23
  te[8] = n33
  self
}

///|
pub fn Matrix3::identity(self : Matrix3) -> Matrix3 {
  self.set(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0)
}

///|
pub fn Matrix3::copy(self : Matrix3, m : Matrix3) -> Matrix3 {
  let te = self.elements
  let me = m.elements
  for i in 0..<9 {
    te[i] = me[i]
  }
  self
}

///|
pub fn Matrix3::clone(self : Matrix3) -> Matrix3 {
  Matrix3::new().copy(self)
}

///|
pub fn Matrix3::set_from_matrix4(self : Matrix3, m : Matrix4) -> Matrix3 {
  let me = m.elements
  self.set(me[0], me[4], me[8], me[1], me[5], me[9], me[2], me[6], me[10])
}

///|
pub fn Matrix3::determinant(self : Matrix3) -> Double {
  let te = self.elements
  let a = te[0]
  let b = te[1]
  let c = te[2]
  let d = te[3]
  let e = te[4]
  let f = te[5]
  let g = te[6]
  let h = te[7]
  let i = te[8]
  a * e * i - a * f * h - b * d * i + b * f * g + c * d * h - c * e * g
}

///|
pub fn Matrix3::invert(self : Matrix3) -> Matrix3 {
  let te = self.elements
  let n11 = te[0]
  let n21 = te[1]
  let n31 = te[2]
  let n12 = te[3]
  let n22 = te[4]
  let n32 = te[5]
  let n13 = te[6]
  let n23 = te[7]
  let n33 = te[8]
  let t11 = n33 * n22 - n32 * n23
  let t12 = n32 * n13 - n33 * n12
  let t13 = n23 * n12 - n22 * n13
  let det = n11 * t11 + n21 * t12 + n31 * t13
  if det == 0.0 {
    return self.set(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
  }
  let det_inv = 1.0 / det
  te[0] = t11 * det_inv
  te[1] = (n31 * n23 - n33 * n21) * det_inv
  te[2] = (n32 * n21 - n31 * n22) * det_inv
  te[3] = t12 * det_inv
  te[4] = (n33 * n11 - n31 * n13) * det_inv
  te[5] = (n31 * n12 - n32 * n11) * det_inv
  te[6] = t13 * det_inv
  te[7] = (n21 * n13 - n23 * n11) * det_inv
  te[8] = (n22 * n11 - n21 * n12) * det_inv
  self
}

///|
pub fn Matrix3::transpose(self : Matrix3) -> Matrix3 {
  let m = self.elements
  let tmp1 = m[1]
  m[1] = m[3]
  m[3] = tmp1
  let tmp2 = m[2]
  m[2] = m[6]
  m[6] = tmp2
  let tmp5 = m[5]
  m[5] = m[7]
  m[7] = tmp5
  self
}

///|
/// 法线矩阵：给定 4×4 矩阵左上 3×3 的逆转置。对齐 r186 `Matrix3.getNormalMatrix`。
/// r186: `getNormalMatrix` https://github.com/mrdoob/three.js/blob/r186/src/math/Matrix3.js#L352
pub fn Matrix3::get_normal_matrix(self : Matrix3, matrix4 : Matrix4) -> Matrix3 {
  self.set_from_matrix4(matrix4).invert().transpose()
}
