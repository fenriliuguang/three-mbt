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
/// r186: `multiplyScalar` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L427
pub fn Vector4::multiply_scalar(self : Vector4, scalar : Double) -> Vector4 {
  self.x *= scalar
  self.y *= scalar
  self.z *= scalar
  self.w *= scalar
  self
}

///|
/// 按分量相除。另一个向量不改。
/// r186: `divide` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L464
pub fn Vector4::divide(self : Vector4, v : Vector4) -> Vector4 {
  self.x /= v.x
  self.y /= v.y
  self.z /= v.z
  self.w /= v.w
  self
}

///|
/// r186: `divideScalar` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L481
pub fn Vector4::divide_scalar(self : Vector4, scalar : Double) -> Vector4 {
  self.multiply_scalar(1.0 / scalar)
}

///|
/// 把四元数的旋转轴写入 x、y、z，把转角写入 w。四元数应当已归一化。
/// r186: `setAxisAngleFromQuaternion` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L494
pub fn Vector4::set_axis_angle_from_quaternion(
  self : Vector4,
  q : Quaternion,
) -> Vector4 {
  self.w = 2.0 * @std.acos(q.w)
  let s = (1.0 - q.w * q.w).sqrt()
  if s < 0.0001 {
    self.x = 1.0
    self.y = 0.0
    self.z = 0.0
  } else {
    self.x = q.x / s
    self.y = q.y / s
    self.z = q.z / s
  }
  self
}

///|
/// 把旋转矩阵的轴写入 x、y、z，把转角写入 w。左上 3×3 应当是纯旋转。
/// r186: `setAxisAngleFromRotationMatrix` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L527
pub fn Vector4::set_axis_angle_from_rotation_matrix(
  self : Vector4,
  m : Matrix4,
) -> Vector4 {
  let epsilon = 0.01
  let epsilon2 = 0.1
  let te = m.elements
  let m11 = te[0]
  let m12 = te[4]
  let m13 = te[8]
  let m21 = te[1]
  let m22 = te[5]
  let m23 = te[9]
  let m31 = te[2]
  let m32 = te[6]
  let m33 = te[10]
  if (m12 - m21).abs() < epsilon &&
    (m13 - m31).abs() < epsilon &&
    (m23 - m32).abs() < epsilon {
    if (m12 + m21).abs() < epsilon2 &&
      (m13 + m31).abs() < epsilon2 &&
      (m23 + m32).abs() < epsilon2 &&
      (m11 + m22 + m33 - 3.0).abs() < epsilon2 {
      return self.set(1.0, 0.0, 0.0, 0.0)
    }
    let angle = @std.PI
    let xx = (m11 + 1.0) / 2.0
    let yy = (m22 + 1.0) / 2.0
    let zz = (m33 + 1.0) / 2.0
    let xy = (m12 + m21) / 4.0
    let xz = (m13 + m31) / 4.0
    let yz = (m23 + m32) / 4.0
    let mut x = 0.0
    let mut y = 0.0
    let mut z = 0.0
    if xx > yy && xx > zz {
      if xx < epsilon {
        x = 0.0
        y = 0.707106781
        z = 0.707106781
      } else {
        x = xx.sqrt()
        y = xy / x
        z = xz / x
      }
    } else if yy > zz {
      if yy < epsilon {
        x = 0.707106781
        y = 0.0
        z = 0.707106781
      } else {
        y = yy.sqrt()
        x = xy / y
        z = yz / y
      }
    } else if zz < epsilon {
      x = 0.707106781
      y = 0.707106781
      z = 0.0
    } else {
      z = zz.sqrt()
      x = xz / z
      y = yz / z
    }
    return self.set(x, y, z, angle)
  }
  let mut s = ((m32 - m23) * (m32 - m23) +
    (m13 - m31) * (m13 - m31) +
    (m21 - m12) * (m21 - m12)).sqrt()
  if s.abs() < 0.001 {
    s = 1.0
  }
  self.x = (m32 - m23) / s
  self.y = (m13 - m31) / s
  self.z = (m21 - m12) / s
  self.w = @std.acos((m11 + m22 + m33 - 1.0) / 2.0)
  self
}

///|
/// 复制矩阵最后一列。矩阵不改。
/// r186: `setFromMatrixPosition` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L662
pub fn Vector4::set_from_matrix_position(
  self : Vector4,
  m : Matrix4,
) -> Vector4 {
  let e = m.elements
  self.x = e[12]
  self.y = e[13]
  self.z = e[14]
  self.w = e[15]
  self
}

///|
/// 每个分量取较小值。另一个向量不改。
/// r186: `min` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L682
pub fn Vector4::min(self : Vector4, v : Vector4) -> Vector4 {
  self.x = self.x.min(v.x)
  self.y = self.y.min(v.y)
  self.z = self.z.min(v.z)
  self.w = self.w.min(v.w)
  self
}

///|
/// 每个分量取较大值。另一个向量不改。
/// r186: `max` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L700
pub fn Vector4::max(self : Vector4, v : Vector4) -> Vector4 {
  self.x = self.x.max(v.x)
  self.y = self.y.max(v.y)
  self.z = self.z.max(v.z)
  self.w = self.w.max(v.w)
  self
}

///|
/// 假定每个分量都是 `min` 小于 `max`。两个边界向量不改。
/// r186: `clamp` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L721
pub fn Vector4::clamp(self : Vector4, min : Vector4, max : Vector4) -> Vector4 {
  self.x = self.x.clamp(min=min.x, max=max.x)
  self.y = self.y.clamp(min=min.y, max=max.y)
  self.z = self.z.clamp(min=min.z, max=max.z)
  self.w = self.w.clamp(min=min.w, max=max.w)
  self
}

///|
/// 假定 `min_val` 小于 `max_val`。
/// r186: `clampScalar` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L744
pub fn Vector4::clamp_scalar(
  self : Vector4,
  min_val : Double,
  max_val : Double,
) -> Vector4 {
  self.x = self.x.clamp(min=min_val, max=max_val)
  self.y = self.y.clamp(min=min_val, max=max_val)
  self.z = self.z.clamp(min=min_val, max=max_val)
  self.w = self.w.clamp(min=min_val, max=max_val)
  self
}

///|
/// 假定 `min` 小于 `max`。零向量保持为零。
/// r186: `clampLength` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L765
pub fn Vector4::clamp_length(
  self : Vector4,
  min : Double,
  max : Double,
) -> Vector4 {
  let length = self.length()
  let divisor = if length == 0.0 { 1.0 } else { length }
  self.divide_scalar(divisor).multiply_scalar(length.clamp(min=min, max=max))
}

///|
/// r186: `floor` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L778
pub fn Vector4::floor(self : Vector4) -> Vector4 {
  self.x = self.x.floor()
  self.y = self.y.floor()
  self.z = self.z.floor()
  self.w = self.w.floor()
  self
}

///|
/// r186: `ceil` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L794
pub fn Vector4::ceil(self : Vector4) -> Vector4 {
  self.x = self.x.ceil()
  self.y = self.y.ceil()
  self.z = self.z.ceil()
  self.w = self.w.ceil()
  self
}

///|
/// 一半时朝正无穷取整。
/// r186: `round` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L810
pub fn Vector4::round(self : Vector4) -> Vector4 {
  self.x = self.x.round()
  self.y = self.y.round()
  self.z = self.z.round()
  self.w = self.w.round()
  self
}

///|
/// 朝零取整。
/// r186: `roundToZero` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L827
pub fn Vector4::round_to_zero(self : Vector4) -> Vector4 {
  self.x = self.x.trunc()
  self.y = self.y.trunc()
  self.z = self.z.trunc()
  self.w = self.w.trunc()
  self
}

///|
/// r186: `negate` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L843
pub fn Vector4::negate(self : Vector4) -> Vector4 {
  self.x = -self.x
  self.y = -self.y
  self.z = -self.z
  self.w = -self.w
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
/// r186: `manhattanLength` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L895
pub fn Vector4::manhattan_length(self : Vector4) -> Double {
  self.x.abs() + self.y.abs() + self.z.abs() + self.w.abs()
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
/// 按当前长度缩放。长度为 0 时除数用 1，零向量保持为零。
/// r186: `setLength` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L920
pub fn Vector4::set_length(self : Vector4, length : Double) -> Vector4 {
  let len = self.length()
  let divisor = if len == 0.0 { 1.0 } else { len }
  self.divide_scalar(divisor).multiply_scalar(length)
}

///|
/// 另一个向量不改。
/// r186: `lerp` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L935
pub fn Vector4::lerp(self : Vector4, v : Vector4, alpha : Double) -> Vector4 {
  self.x += (v.x - self.x) * alpha
  self.y += (v.y - self.y) * alpha
  self.z += (v.z - self.z) * alpha
  self.w += (v.w - self.w) * alpha
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
