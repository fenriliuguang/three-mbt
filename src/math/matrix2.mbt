// r186: `Matrix2` https://github.com/mrdoob/three.js/blob/r186/src/math/Matrix2.js#L28

///|
/// 列主序 2×2 矩阵。不带参数时是单位矩阵。
/// r186: `Matrix2` https://github.com/mrdoob/three.js/blob/r186/src/math/Matrix2.js#L28
pub(all) struct Matrix2 {
  elements : FixedArray[Double]
}

///|
fn matrix2_elements() -> FixedArray[Double] {
  let te = FixedArray::make(4, 0.0)
  te[0] = 1.0
  te[3] = 1.0
  te
}

///|
/// r186: `constructor` https://github.com/mrdoob/three.js/blob/r186/src/math/Matrix2.js#L52
pub fn Matrix2::new() -> Matrix2 {
  { elements: matrix2_elements(), }
}

///|
/// 参数按行主序书写，存成列主序。
/// r186: `set` https://github.com/mrdoob/three.js/blob/r186/src/math/Matrix2.js#L117
pub fn Matrix2::set(
  self : Matrix2,
  n11 : Double,
  n12 : Double,
  n21 : Double,
  n22 : Double,
) -> Matrix2 {
  let te = self.elements
  te[0] = n11
  te[2] = n12
  te[1] = n21
  te[3] = n22
  self
}
