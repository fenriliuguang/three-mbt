// r186: `Vector4` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L27

///|
/// 四维向量。对齐 three.js r186 `Vector4` 的运算子集。
/// r186: `Vector4` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L27
pub(all) struct Vector4 {
  mut x : Double
  mut y : Double
  mut z : Double
  mut w : Double
}

///|
pub fn Vector4::new(
  x? : Double = 0.0,
  y? : Double = 0.0,
  z? : Double = 0.0,
  w? : Double = 1.0,
) -> Vector4 {
  { x, y, z, w, }
}

///|
pub fn Vector4::set(
  self : Vector4,
  x : Double,
  y : Double,
  z : Double,
  w : Double,
) -> Vector4 {
  self.x = x
  self.y = y
  self.z = z
  self.w = w
  self
}

///|
pub fn Vector4::copy(self : Vector4, v : Vector4) -> Vector4 {
  self.x = v.x
  self.y = v.y
  self.z = v.z
  self.w = v.w
  self
}

///|
pub fn Vector4::clone(self : Vector4) -> Vector4 {
  Vector4::new(x=self.x, y=self.y, z=self.z, w=self.w)
}

///|
pub fn Vector4::dot(self : Vector4, v : Vector4) -> Double {
  self.x * v.x + self.y * v.y + self.z * v.z + self.w * v.w
}

///|
pub fn Vector4::length_sq(self : Vector4) -> Double {
  self.dot(self)
}

///|
pub fn Vector4::length(self : Vector4) -> Double {
  self.length_sq().sqrt()
}

///|
pub fn Vector4::normalize(self : Vector4) -> Vector4 {
  let len = self.length()
  if len == 0.0 {
    self.x = 0.0
    self.y = 0.0
    self.z = 0.0
    self.w = 1.0
  } else {
    let inv = 1.0 / len
    self.x *= inv
    self.y *= inv
    self.z *= inv
    self.w *= inv
  }
  self
}

///|
/// 用矩阵乘这个齐次坐标，不做透视除法。对齐 r186 `Vector4.applyMatrix4`。
pub fn Vector4::apply_matrix4(self : Vector4, m : Matrix4) -> Vector4 {
  let x = self.x
  let y = self.y
  let z = self.z
  let w = self.w
  let e = m.elements
  self.x = e[0] * x + e[4] * y + e[8] * z + e[12] * w
  self.y = e[1] * x + e[5] * y + e[9] * z + e[13] * w
  self.z = e[2] * x + e[6] * y + e[10] * z + e[14] * w
  self.w = e[3] * x + e[7] * y + e[11] * z + e[15] * w
  self
}
