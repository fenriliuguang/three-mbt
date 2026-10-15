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

///|
/// 复制另一组柱坐标。来源不改。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/math/Cylindrical.js#L66
pub fn Cylindrical::copy(self : Cylindrical, other : Cylindrical) -> Cylindrical {
  self.radius = other.radius
  self.theta = other.theta
  self.y = other.y
  self
}

///|
/// 从直角坐标写入半径、方位角和高度。半径是 xz 平面上到原点的距离。
/// r186: `setFromCartesianCoords` https://github.com/mrdoob/three.js/blob/r186/src/math/Cylindrical.js#L97
pub fn Cylindrical::set_from_cartesian_coords(
  self : Cylindrical,
  x : Double,
  y : Double,
  z : Double,
) -> Cylindrical {
  self.radius = (x * x + z * z).sqrt()
  self.theta = @std.atan2(x, z)
  self.y = y
  self
}
