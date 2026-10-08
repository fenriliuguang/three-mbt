///|
/// 三维向量。对齐 three.js r186 `Vector3` 里场景图和矩阵会用到的运算。
pub(all) struct Vector3 {
  mut x : Double
  mut y : Double
  mut z : Double
}

///|
pub fn Vector3::new(
  x? : Double = 0.0,
  y? : Double = 0.0,
  z? : Double = 0.0,
) -> Vector3 {
  { x, y, z, }
}

///|
pub fn Vector3::set(
  self : Vector3,
  x : Double,
  y : Double,
  z : Double,
) -> Vector3 {
  self.x = x
  self.y = y
  self.z = z
  self
}

///|
pub fn Vector3::copy(self : Vector3, v : Vector3) -> Vector3 {
  self.x = v.x
  self.y = v.y
  self.z = v.z
  self
}

///|
pub fn Vector3::clone(self : Vector3) -> Vector3 {
  Vector3::new(x=self.x, y=self.y, z=self.z)
}

///|
pub fn Vector3::add(self : Vector3, v : Vector3) -> Vector3 {
  self.x += v.x
  self.y += v.y
  self.z += v.z
  self
}

///|
pub fn Vector3::add_vectors(
  self : Vector3,
  a : Vector3,
  b : Vector3,
) -> Vector3 {
  self.x = a.x + b.x
  self.y = a.y + b.y
  self.z = a.z + b.z
  self
}

///|
pub fn Vector3::sub(self : Vector3, v : Vector3) -> Vector3 {
  self.x -= v.x
  self.y -= v.y
  self.z -= v.z
  self
}

///|
pub fn Vector3::sub_vectors(
  self : Vector3,
  a : Vector3,
  b : Vector3,
) -> Vector3 {
  self.x = a.x - b.x
  self.y = a.y - b.y
  self.z = a.z - b.z
  self
}

///|
pub fn Vector3::multiply_scalar(self : Vector3, s : Double) -> Vector3 {
  self.x *= s
  self.y *= s
  self.z *= s
  self
}

///|
pub fn Vector3::negate(self : Vector3) -> Vector3 {
  self.x = -self.x
  self.y = -self.y
  self.z = -self.z
  self
}

///|
pub fn Vector3::dot(self : Vector3, v : Vector3) -> Double {
  self.x * v.x + self.y * v.y + self.z * v.z
}

///|
pub fn Vector3::cross(self : Vector3, v : Vector3) -> Vector3 {
  self.cross_vectors(self, v)
}

///|
pub fn Vector3::cross_vectors(
  self : Vector3,
  a : Vector3,
  b : Vector3,
) -> Vector3 {
  let ax = a.x
  let ay = a.y
  let az = a.z
  let bx = b.x
  let by = b.y
  let bz = b.z
  self.x = ay * bz - az * by
  self.y = az * bx - ax * bz
  self.z = ax * by - ay * bx
  self
}

///|
pub fn Vector3::length_sq(self : Vector3) -> Double {
  self.x * self.x + self.y * self.y + self.z * self.z
}

///|
pub fn Vector3::length(self : Vector3) -> Double {
  self.length_sq().sqrt()
}

///|
pub fn Vector3::normalize(self : Vector3) -> Vector3 {
  let len = self.length()
  if len == 0.0 {
    self
  } else {
    self.multiply_scalar(1.0 / len)
  }
}

///|
pub fn Vector3::lerp(self : Vector3, v : Vector3, t : Double) -> Vector3 {
  self.x += (v.x - self.x) * t
  self.y += (v.y - self.y) * t
  self.z += (v.z - self.z) * t
  self
}

///|
pub fn Vector3::min(self : Vector3, v : Vector3) -> Vector3 {
  self.x = self.x.min(v.x)
  self.y = self.y.min(v.y)
  self.z = self.z.min(v.z)
  self
}

///|
pub fn Vector3::max(self : Vector3, v : Vector3) -> Vector3 {
  self.x = self.x.max(v.x)
  self.y = self.y.max(v.y)
  self.z = self.z.max(v.z)
  self
}

///|
pub fn Vector3::distance_to_squared(self : Vector3, v : Vector3) -> Double {
  let dx = self.x - v.x
  let dy = self.y - v.y
  let dz = self.z - v.z
  dx * dx + dy * dy + dz * dz
}

///|
pub fn Vector3::apply_matrix4(self : Vector3, m : Matrix4) -> Vector3 {
  let x = self.x
  let y = self.y
  let z = self.z
  let e = m.elements
  let w = 1.0 / (e[3] * x + e[7] * y + e[11] * z + e[15])
  self.x = (e[0] * x + e[4] * y + e[8] * z + e[12]) * w
  self.y = (e[1] * x + e[5] * y + e[9] * z + e[13]) * w
  self.z = (e[2] * x + e[6] * y + e[10] * z + e[14]) * w
  self
}

///|
pub fn Vector3::set_from_matrix_position(
  self : Vector3,
  m : Matrix4,
) -> Vector3 {
  let e = m.elements
  self.x = e[12]
  self.y = e[13]
  self.z = e[14]
  self
}

///|
pub fn Vector3::set_from_matrix_column(
  self : Vector3,
  m : Matrix4,
  index : Int,
) -> Vector3 {
  let e = m.elements
  let offset = index * 4
  self.x = e[offset]
  self.y = e[offset + 1]
  self.z = e[offset + 2]
  self
}

///|
pub fn Vector3::equals(self : Vector3, v : Vector3) -> Bool {
  self.x == v.x && self.y == v.y && self.z == v.z
}
