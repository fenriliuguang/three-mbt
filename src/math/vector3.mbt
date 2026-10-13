// r186: `Vector3` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L29

///|
/// 三维向量。对齐 three.js r186 `Vector3` 里场景图和矩阵会用到的运算。
/// r186: `Vector3` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L29
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
/// r186: `cross` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L478
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
/// r186: `normalize` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L439
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
/// r186: `distanceTo` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L953
pub fn Vector3::distance_to(self : Vector3, v : Vector3) -> Double {
  self.distance_to_squared(v).sqrt()
}

///|
/// r186: `manhattanDistanceTo` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L981
pub fn Vector3::manhattan_distance_to(self : Vector3, v : Vector3) -> Double {
  (self.x - v.x).abs() + (self.y - v.y).abs() + (self.z - v.z).abs()
}

///|
/// `phi` 是相对正 Y 轴的夹角，`theta` 绕 Y 轴、从正 Z 转向正 X。
/// r186: `setFromSphericalCoords` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L1007
pub fn Vector3::set_from_spherical_coords(
  self : Vector3,
  radius : Double,
  phi : Double,
  theta : Double,
) -> Vector3 {
  let sin_phi_radius = @std.sin(phi) * radius
  self.x = sin_phi_radius * @std.sin(theta)
  self.y = @std.cos(phi) * radius
  self.z = sin_phi_radius * @std.cos(theta)
  self
}

///|
/// `theta` 绕 Y 轴、从正 Z 转向正 X，`y` 是高度。
/// r186: `setFromCylindricalCoords` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L1039
pub fn Vector3::set_from_cylindrical_coords(
  self : Vector3,
  radius : Double,
  theta : Double,
  y : Double,
) -> Vector3 {
  self.x = radius * @std.sin(theta)
  self.y = y
  self.z = radius * @std.cos(theta)
  self
}

///|
/// r186: `angleTo` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L933
pub fn Vector3::angle_to(self : Vector3, v : Vector3) -> Double {
  let denominator = (self.length_sq() * v.length_sq()).sqrt()
  if denominator == 0.0 {
    return @std.PI / 2.0
  }
  let theta = self.dot(v) / denominator
  @std.acos(theta.clamp(min=-1.0, max=1.0))
}

///|
/// r186: `applyMatrix4` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L450
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
/// 四元数假定为单位长度。
/// r186: `applyQuaternion` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L471
pub fn Vector3::apply_quaternion(self : Vector3, q : Quaternion) -> Vector3 {
  let vx = self.x
  let vy = self.y
  let vz = self.z
  let qx = q.x
  let qy = q.y
  let qz = q.z
  let qw = q.w
  let tx = 2.0 * (qy * vz - qz * vy)
  let ty = 2.0 * (qz * vx - qx * vz)
  let tz = 2.0 * (qx * vy - qy * vx)
  self.x = vx + qw * tx + qy * tz - qz * ty
  self.y = vy + qw * ty + qz * tx - qx * tz
  self.z = vz + qw * tz + qx * ty - qy * tx
  self
}

///|
/// 只用矩阵左上 3×3，并把结果归一化。平移不参与。
/// r186: `transformDirection` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L525
pub fn Vector3::transform_direction(self : Vector3, m : Matrix4) -> Vector3 {
  let x = self.x
  let y = self.y
  let z = self.z
  let e = m.elements
  self.x = e[0] * x + e[4] * y + e[8] * z
  self.y = e[1] * x + e[5] * y + e[9] * z
  self.z = e[2] * x + e[6] * y + e[10] * z
  self.normalize()
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
/// 取前三列的长度。负缩放的符号会丢掉。
/// r186: `setFromMatrixScale` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L1075
pub fn Vector3::set_from_matrix_scale(self : Vector3, m : Matrix4) -> Vector3 {
  let sx = self.set_from_matrix_column(m, 0).length()
  let sy = self.set_from_matrix_column(m, 1).length()
  let sz = self.set_from_matrix_column(m, 2).length()
  self.x = sx
  self.y = sy
  self.z = sz
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
/// r186: `setFromMatrix3Column` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L1109
pub fn Vector3::set_from_matrix3_column(
  self : Vector3,
  m : Matrix3,
  index : Int,
) -> Vector3 {
  let e = m.elements
  let offset = index * 3
  self.x = e[offset]
  self.y = e[offset + 1]
  self.z = e[offset + 2]
  self
}

///|
pub fn Vector3::equals(self : Vector3, v : Vector3) -> Bool {
  self.x == v.x && self.y == v.y && self.z == v.z
}
