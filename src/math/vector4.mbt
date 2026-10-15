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
/// r186: `setScalar` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L142
pub fn Vector4::set_scalar(self : Vector4, scalar : Double) -> Vector4 {
  self.x = scalar
  self.y = scalar
  self.z = scalar
  self.w = scalar
  self
}

///|
/// r186: `setX` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L159
pub fn Vector4::set_x(self : Vector4, x : Double) -> Vector4 {
  self.x = x
  self
}

///|
/// r186: `setY` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L173
pub fn Vector4::set_y(self : Vector4, y : Double) -> Vector4 {
  self.y = y
  self
}

///|
/// r186: `setZ` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L187
pub fn Vector4::set_z(self : Vector4, z : Double) -> Vector4 {
  self.z = z
  self
}

///|
/// r186: `setW` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L201
pub fn Vector4::set_w(self : Vector4, w : Double) -> Vector4 {
  self.w = w
  self
}

///|
/// 0 是 x，1 是 y，2 是 z，3 是 w。其他下标中止。
/// r186: `setComponent` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L217
pub fn Vector4::set_component(
  self : Vector4,
  index : Int,
  value : Double,
) -> Vector4 {
  match index {
    0 => self.x = value
    1 => self.y = value
    2 => self.z = value
    3 => self.w = value
    _ => abort("Vector4 index is out of range")
  }
  self
}

///|
/// 0 是 x，1 是 y，2 是 z，3 是 w。其他下标中止。
/// r186: `getComponent` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L240
pub fn Vector4::get_component(self : Vector4, index : Int) -> Double {
  match index {
    0 => self.x
    1 => self.y
    2 => self.z
    3 => self.w
    _ => abort("Vector4 index is out of range")
  }
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
pub fn Vector4::add(self : Vector4, v : Vector4) -> Vector4 {
  self.x += v.x
  self.y += v.y
  self.z += v.z
  self.w += v.w
  self
}

///|
/// r186: `addScalar` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L305
pub fn Vector4::add_scalar(self : Vector4, s : Double) -> Vector4 {
  self.x += s
  self.y += s
  self.z += s
  self.w += s
  self
}

///|
/// 把两个向量的和写入自身。两个来源不改。
/// r186: `addVectors` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L323
pub fn Vector4::add_vectors(
  self : Vector4,
  a : Vector4,
  b : Vector4,
) -> Vector4 {
  self.x = a.x + b.x
  self.y = a.y + b.y
  self.z = a.z + b.z
  self.w = a.w + b.w
  self
}

///|
/// 加上 `v * s`。另一个向量不改。
/// r186: `addScaledVector` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L341
pub fn Vector4::add_scaled_vector(
  self : Vector4,
  v : Vector4,
  s : Double,
) -> Vector4 {
  self.x += v.x * s
  self.y += v.y * s
  self.z += v.z * s
  self.w += v.w * s
  self
}

///|
pub fn Vector4::sub(self : Vector4, v : Vector4) -> Vector4 {
  self.x -= v.x
  self.y -= v.y
  self.z -= v.z
  self.w -= v.w
  self
}

///|
/// r186: `subScalar` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L375
pub fn Vector4::sub_scalar(self : Vector4, s : Double) -> Vector4 {
  self.x -= s
  self.y -= s
  self.z -= s
  self.w -= s
  self
}

///|
/// 把两个向量的差写入自身。两个来源不改。
/// r186: `subVectors` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L393
pub fn Vector4::sub_vectors(
  self : Vector4,
  a : Vector4,
  b : Vector4,
) -> Vector4 {
  self.x = a.x - b.x
  self.y = a.y - b.y
  self.z = a.z - b.z
  self.w = a.w - b.w
  self
}

///|
/// 按分量相乘。另一个向量不改。
/// r186: `multiply` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L410
pub fn Vector4::multiply(self : Vector4, v : Vector4) -> Vector4 {
  self.x *= v.x
  self.y *= v.y
  self.z *= v.z
  self.w *= v.w
  self
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
