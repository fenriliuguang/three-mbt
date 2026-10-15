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
/// r186: `setScalar` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L102
pub fn Vector3::set_scalar(self : Vector3, scalar : Double) -> Vector3 {
  self.x = scalar
  self.y = scalar
  self.z = scalar
  self
}

///|
/// r186: `setX` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L118
pub fn Vector3::set_x(self : Vector3, x : Double) -> Vector3 {
  self.x = x
  self
}

///|
/// r186: `setY` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L132
pub fn Vector3::set_y(self : Vector3, y : Double) -> Vector3 {
  self.y = y
  self
}

///|
/// r186: `setZ` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L146
pub fn Vector3::set_z(self : Vector3, z : Double) -> Vector3 {
  self.z = z
  self
}

///|
/// 0 是 x，1 是 y，2 是 z。其他下标中止。
/// r186: `setComponent` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L161
pub fn Vector3::set_component(
  self : Vector3,
  index : Int,
  value : Double,
) -> Vector3 {
  match index {
    0 => self.x = value
    1 => self.y = value
    2 => self.z = value
    _ => abort("Vector3 index is out of range")
  }
  self
}

///|
/// 0 是 x，1 是 y，2 是 z。其他下标中止。
/// r186: `getComponent` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L182
pub fn Vector3::get_component(self : Vector3, index : Int) -> Double {
  match index {
    0 => self.x
    1 => self.y
    2 => self.z
    _ => abort("Vector3 index is out of range")
  }
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
/// r186: `addScalar` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L244
pub fn Vector3::add_scalar(self : Vector3, s : Double) -> Vector3 {
  self.x += s
  self.y += s
  self.z += s
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
/// r186: `addScaledVector` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L278
pub fn Vector3::add_scaled_vector(
  self : Vector3,
  v : Vector3,
  s : Double,
) -> Vector3 {
  self.x += v.x * s
  self.y += v.y * s
  self.z += v.z * s
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
/// r186: `subScalar` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L310
pub fn Vector3::sub_scalar(self : Vector3, s : Double) -> Vector3 {
  self.x -= s
  self.y -= s
  self.z -= s
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
/// r186: `multiply` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L343
pub fn Vector3::multiply(self : Vector3, v : Vector3) -> Vector3 {
  self.x *= v.x
  self.y *= v.y
  self.z *= v.z
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
/// r186: `multiplyVectors` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L376
pub fn Vector3::multiply_vectors(
  self : Vector3,
  a : Vector3,
  b : Vector3,
) -> Vector3 {
  self.x = a.x * b.x
  self.y = a.y * b.y
  self.z = a.z * b.z
  self
}

///|
/// r186: `divide` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L547
pub fn Vector3::divide(self : Vector3, v : Vector3) -> Vector3 {
  self.x /= v.x
  self.y /= v.y
  self.z /= v.z
  self
}

///|
/// r186: `divideScalar` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L563
pub fn Vector3::divide_scalar(self : Vector3, scalar : Double) -> Vector3 {
  self.multiply_scalar(1.0 / scalar)
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
/// 投影到零向量上得到零。目标向量不改。
/// r186: `projectOnVector` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L889
pub fn Vector3::project_on_vector(self : Vector3, v : Vector3) -> Vector3 {
  let denominator = v.length_sq()
  if denominator == 0.0 {
    return self.set(0.0, 0.0, 0.0)
  }
  let scalar = v.dot(self) / denominator
  self.copy(v).multiply_scalar(scalar)
}

///|
/// 法线不必是单位长度。零法线让向量保持不变。
/// r186: `projectOnPlane` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L908
pub fn Vector3::project_on_plane(
  self : Vector3,
  plane_normal : Vector3,
) -> Vector3 {
  let projected = Vector3::new().copy(self).project_on_vector(plane_normal)
  self.sub(projected)
}

///|
/// 法线按单位长度使用。法线本身不改。
/// r186: `reflect` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L922
pub fn Vector3::reflect(self : Vector3, normal : Vector3) -> Vector3 {
  let factor = 2.0 * self.dot(normal)
  let scaled = Vector3::new().copy(normal).multiply_scalar(factor)
  self.sub(scaled)
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
/// r186: `manhattanLength` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L780
pub fn Vector3::manhattan_length(self : Vector3) -> Double {
  self.x.abs() + self.y.abs() + self.z.abs()
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
/// 零向量保持为零。
/// r186: `setLength` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L805
pub fn Vector3::set_length(self : Vector3, length : Double) -> Vector3 {
  self.normalize().multiply_scalar(length)
}

///|
pub fn Vector3::lerp(self : Vector3, v : Vector3, t : Double) -> Vector3 {
  self.x += (v.x - self.x) * t
  self.y += (v.y - self.y) * t
  self.z += (v.z - self.z) * t
  self
}

///|
/// r186: `lerpVectors` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L840
pub fn Vector3::lerp_vectors(
  self : Vector3,
  v1 : Vector3,
  v2 : Vector3,
  alpha : Double,
) -> Vector3 {
  self.x = v1.x + (v2.x - v1.x) * alpha
  self.y = v1.y + (v2.y - v1.y) * alpha
  self.z = v1.z + (v2.z - v1.z) * alpha
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
/// 假定每个分量都是 `min` 小于 `max`。两个边界向量不改。
/// r186: `clamp` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L613
pub fn Vector3::clamp(self : Vector3, min : Vector3, max : Vector3) -> Vector3 {
  self.x = self.x.clamp(min=min.x, max=max.x)
  self.y = self.y.clamp(min=min.y, max=max.y)
  self.z = self.z.clamp(min=min.z, max=max.z)
  self
}

///|
/// 假定 `min_val` 小于 `max_val`。
/// r186: `clampScalar` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L635
pub fn Vector3::clamp_scalar(
  self : Vector3,
  min_val : Double,
  max_val : Double,
) -> Vector3 {
  self.x = self.x.clamp(min=min_val, max=max_val)
  self.y = self.y.clamp(min=min_val, max=max_val)
  self.z = self.z.clamp(min=min_val, max=max_val)
  self
}

///|
/// 假定 `min` 小于 `max`。零向量保持为零。
/// r186: `clampLength` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L655
pub fn Vector3::clamp_length(
  self : Vector3,
  min : Double,
  max : Double,
) -> Vector3 {
  let length = self.length()
  let divisor = if length == 0.0 { 1.0 } else { length }
  self.divide_scalar(divisor).multiply_scalar(length.clamp(min=min, max=max))
}

///|
/// r186: `floor` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L668
pub fn Vector3::floor(self : Vector3) -> Vector3 {
  self.x = self.x.floor()
  self.y = self.y.floor()
  self.z = self.z.floor()
  self
}

///|
/// r186: `ceil` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L683
pub fn Vector3::ceil(self : Vector3) -> Vector3 {
  self.x = self.x.ceil()
  self.y = self.y.ceil()
  self.z = self.z.ceil()
  self
}

///|
/// 一半时朝正无穷取整。
/// r186: `round` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L698
pub fn Vector3::round(self : Vector3) -> Vector3 {
  self.x = self.x.round()
  self.y = self.y.round()
  self.z = self.z.round()
  self
}

///|
/// 朝零取整。
/// r186: `roundToZero` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L714
pub fn Vector3::round_to_zero(self : Vector3) -> Vector3 {
  self.x = self.x.trunc()
  self.y = self.y.trunc()
  self.z = self.z.trunc()
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
/// r186: `applyMatrix3` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L417
pub fn Vector3::apply_matrix3(self : Vector3, m : Matrix3) -> Vector3 {
  let x = self.x
  let y = self.y
  let z = self.z
  let e = m.elements
  self.x = e[0] * x + e[3] * y + e[6] * z
  self.y = e[1] * x + e[4] * y + e[7] * z
  self.z = e[2] * x + e[5] * y + e[8] * z
  self
}

///|
/// 先乘矩阵，再归一化。零向量保持为零。
/// r186: `applyNormalMatrix` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L437
pub fn Vector3::apply_normal_matrix(self : Vector3, m : Matrix3) -> Vector3 {
  self.apply_matrix3(m).normalize()
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
/// 用一次局部四元数，不保留它。
/// r186: `applyEuler` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L392
pub fn Vector3::apply_euler(self : Vector3, euler : Euler) -> Vector3 {
  self.apply_quaternion(Quaternion::new().set_from_euler(euler))
}

///|
/// 轴假定为单位长度。临时四元数不保留。
/// r186: `applyAxisAngle` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L405
pub fn Vector3::apply_axis_angle(
  self : Vector3,
  axis : Vector3,
  angle : Double,
) -> Vector3 {
  self.apply_quaternion(Quaternion::new().set_from_axis_angle(axis, angle))
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
/// 只抄三个分量，旋转顺序不参与。
/// r186: `setFromEuler` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L1121
pub fn Vector3::set_from_euler(self : Vector3, euler : Euler) -> Vector3 {
  self.x = euler.x
  self.y = euler.y
  self.z = euler.z
  self
}

///|
/// 抄已经存放的线性通道，不再做 sRGB 转换。
/// r186: `setFromColor` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L1138
pub fn Vector3::set_from_color(self : Vector3, color : Color) -> Vector3 {
  self.x = color.r
  self.y = color.g
  self.z = color.b
  self
}

///|
pub fn Vector3::equals(self : Vector3, v : Vector3) -> Bool {
  self.x == v.x && self.y == v.y && self.z == v.z
}

///|
/// `offset` 默认是 0。数组本身不改。
/// r186: `fromArray` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L1168
pub fn Vector3::from_array(
  self : Vector3,
  array : Array[Double],
  offset? : Int = 0,
) -> Vector3 {
  self.x = array[offset]
  self.y = array[offset + 1]
  self.z = array[offset + 2]
  self
}

///|
/// 省略数组时新建一个。短于 `offset + 3` 的数组会补零再写入。向量本身不改。
/// r186: `toArray` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L1186
pub fn Vector3::to_array(
  self : Vector3,
  array? : Array[Double],
  offset? : Int = 0,
) -> Array[Double] {
  let target = match array {
    None => []
    Some(array) => array
  }
  let end = offset + 3
  while target.length() < end {
    target.push(0.0)
  }
  target[offset] = self.x
  target[offset + 1] = self.y
  target[offset + 2] = self.z
  target
}
