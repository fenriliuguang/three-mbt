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

///|
/// 写入半径、方位角和高度。
/// r186: `set` https://github.com/mrdoob/three.js/blob/r186/src/math/Cylindrical.js#L50
pub fn Cylindrical::set(
  self : Cylindrical,
  radius : Double,
  theta : Double,
  y : Double,
) -> Cylindrical {
  self.radius = radius
  self.theta = theta
  self.y = y
  self
}
