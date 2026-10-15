// r186: `Spherical` https://github.com/mrdoob/three.js/blob/r186/src/math/Spherical.js#L7

///|
/// 球坐标。`phi` 相对正 Y 轴，`theta` 绕 Y 轴、从正 Z 转向正 X。
/// r186: `Spherical` https://github.com/mrdoob/three.js/blob/r186/src/math/Spherical.js#L7
pub(all) struct Spherical {
  mut radius : Double
  mut phi : Double
  mut theta : Double
}

///|
pub fn Spherical::new(
  radius? : Double = 1.0,
  phi? : Double = 0.0,
  theta? : Double = 0.0,
) -> Spherical {
  { radius, phi, theta }
}

///|
/// 写入半径和两个角。
/// r186: `set` https://github.com/mrdoob/three.js/blob/r186/src/math/Spherical.js#L52
pub fn Spherical::set(
  self : Spherical,
  radius : Double,
  phi : Double,
  theta : Double,
) -> Spherical {
  self.radius = radius
  self.phi = phi
  self.theta = theta
  self
}

///|
/// 复制另一组球坐标。来源不改。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/math/Spherical.js#L68
pub fn Spherical::copy(self : Spherical, other : Spherical) -> Spherical {
  self.radius = other.radius
  self.phi = other.phi
  self.theta = other.theta
  self
}
