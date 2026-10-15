// r186: `Cylindrical` https://github.com/mrdoob/three.js/blob/r186/src/math/Cylindrical.js#L5

///|
/// 柱坐标。`theta` 绕 Y 轴、从正 Z 转向正 X，`y` 是高度。
/// r186: `Cylindrical` https://github.com/mrdoob/three.js/blob/r186/src/math/Cylindrical.js#L5
pub(all) struct Cylindrical {
  mut radius : Double
  mut theta : Double
  mut y : Double
}

///|
pub fn Cylindrical::new(
  radius? : Double = 1.0,
  theta? : Double = 0.0,
  y? : Double = 0.0,
) -> Cylindrical {
  { radius, theta, y }
}
