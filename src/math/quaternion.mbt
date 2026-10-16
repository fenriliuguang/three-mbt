// r186: `Quaternion` https://github.com/mrdoob/three.js/blob/r186/src/math/Quaternion.js#L19

///|
/// 单位四元数。写入分量请用 `set`，以便和欧拉角互相同步。
/// r186: `Quaternion` https://github.com/mrdoob/three.js/blob/r186/src/math/Quaternion.js#L19
pub(all) struct Quaternion {
  mut x : Double
  mut y : Double
  mut z : Double
  mut w : Double
  mut on_change : (() -> Unit)?
}

///|
pub fn Quaternion::new(
  x? : Double = 0.0,
  y? : Double = 0.0,
  z? : Double = 0.0,
  w? : Double = 1.0,
) -> Quaternion {
  { x, y, z, w, on_change: None, }
}

///|
fn Quaternion::emit(self : Quaternion) -> Unit {
  match self.on_change {
    None => ()
    Some(notify) => notify()
  }
}

///|
/// 在扁平数组上做球面插值。两个四元数相同时直接复制第一个。
/// r186: `slerpFlat` https://github.com/mrdoob/three.js/blob/r186/src/math/Quaternion.js#L60
pub fn Quaternion::slerp_flat(
  dst : Array[Double],
  dst_offset : Int,
  src0 : Array[Double],
  src_offset0 : Int,
  src1 : Array[Double],
  src_offset1 : Int,
  t : Double,
) -> Unit {
  let mut x0 = src0[src_offset0]
  let mut y0 = src0[src_offset0 + 1]
  let mut z0 = src0[src_offset0 + 2]
  let mut w0 = src0[src_offset0 + 3]
  let mut x1 = src1[src_offset1]
  let mut y1 = src1[src_offset1 + 1]
  let mut z1 = src1[src_offset1 + 2]
  let mut w1 = src1[src_offset1 + 3]
  if w0 != w1 || x0 != x1 || y0 != y1 || z0 != z1 {
    let mut dot = x0 * x1 + y0 * y1 + z0 * z1 + w0 * w1
    if dot < 0.0 {
      x1 = -x1
      y1 = -y1
      z1 = -z1
      w1 = -w1
      dot = -dot
    }
    let mut s = 1.0 - t
    let mut factor = t
    if dot < 0.9995 {
      let theta = @std.acos(dot)
      let sin_theta = @std.sin(theta)
      s = @std.sin(s * theta) / sin_theta
      factor = @std.sin(factor * theta) / sin_theta
      x0 = x0 * s + x1 * factor
      y0 = y0 * s + y1 * factor
      z0 = z0 * s + z1 * factor
      w0 = w0 * s + w1 * factor
    } else {
      x0 = x0 * s + x1 * factor
      y0 = y0 * s + y1 * factor
      z0 = z0 * s + z1 * factor
      w0 = w0 * s + w1 * factor
      let f = 1.0 / (x0 * x0 + y0 * y0 + z0 * z0 + w0 * w0).sqrt()
      x0 *= f
      y0 *= f
      z0 *= f
      w0 *= f
    }
  }
  dst[dst_offset] = x0
  dst[dst_offset + 1] = y0
  dst[dst_offset + 2] = z0
  dst[dst_offset + 3] = w0
}

///|
/// 在扁平数组上相乘两个四元数，返回目标数组。
/// r186: `multiplyQuaternionsFlat` https://github.com/mrdoob/three.js/blob/r186/src/math/Quaternion.js#L144
pub fn Quaternion::multiply_quaternions_flat(
  dst : Array[Double],
  dst_offset : Int,
  src0 : Array[Double],
  src_offset0 : Int,
  src1 : Array[Double],
  src_offset1 : Int,
) -> Array[Double] {
  let x0 = src0[src_offset0]
  let y0 = src0[src_offset0 + 1]
  let z0 = src0[src_offset0 + 2]
  let w0 = src0[src_offset0 + 3]
  let x1 = src1[src_offset1]
  let y1 = src1[src_offset1 + 1]
  let z1 = src1[src_offset1 + 2]
  let w1 = src1[src_offset1 + 3]
  dst[dst_offset] = x0 * w1 + w0 * x1 + y0 * z1 - z0 * y1
  dst[dst_offset + 1] = y0 * w1 + w0 * y1 + z0 * x1 - x0 * z1
  dst[dst_offset + 2] = z0 * w1 + w0 * z1 + x0 * y1 - y0 * x1
  dst[dst_offset + 3] = w0 * w1 - x0 * x1 - y0 * y1 - z0 * z1
  dst
}

///|
pub fn Quaternion::set(
  self : Quaternion,
  x : Double,
  y : Double,
  z : Double,
  w : Double,
) -> Quaternion {
  self.x = x
  self.y = y
  self.z = z
  self.w = w
  self.emit()
  self
}

///|
/// 写入 x 并通知。
/// r186: `x` https://github.com/mrdoob/three.js/blob/r186/src/math/Quaternion.js#L177
pub fn Quaternion::set_x(self : Quaternion, value : Double) -> Quaternion {
  self.x = value
  self.emit()
  self
}

///|
/// 写入 y 并通知。
/// r186: `y` https://github.com/mrdoob/three.js/blob/r186/src/math/Quaternion.js#L196
pub fn Quaternion::set_y(self : Quaternion, value : Double) -> Quaternion {
  self.y = value
  self.emit()
  self
}

///|
pub fn Quaternion::copy(self : Quaternion, q : Quaternion) -> Quaternion {
  self.x = q.x
  self.y = q.y
  self.z = q.z
  self.w = q.w
  self.emit()
  self
}

///|
pub fn Quaternion::clone(self : Quaternion) -> Quaternion {
  Quaternion::new(x=self.x, y=self.y, z=self.z, w=self.w)
}

///|
pub fn Quaternion::identity(self : Quaternion) -> Quaternion {
  self.set(0.0, 0.0, 0.0, 1.0)
}

///|
/// r186: `setFromEuler` https://github.com/mrdoob/three.js/blob/r186/src/math/Quaternion.js#L301
pub fn Quaternion::set_from_euler(
  self : Quaternion,
  euler : Euler,
  update? : Bool = true,
) -> Quaternion {
  let x = euler.x
  let y = euler.y
  let z = euler.z
  let c1 = @std.cos(x / 2.0)
  let c2 = @std.cos(y / 2.0)
  let c3 = @std.cos(z / 2.0)
  let s1 = @std.sin(x / 2.0)
  let s2 = @std.sin(y / 2.0)
  let s3 = @std.sin(z / 2.0)
  match euler.order {
    XYZ => {
      self.x = s1 * c2 * c3 + c1 * s2 * s3
      self.y = c1 * s2 * c3 - s1 * c2 * s3
      self.z = c1 * c2 * s3 + s1 * s2 * c3
      self.w = c1 * c2 * c3 - s1 * s2 * s3
    }
    YXZ => {
      self.x = s1 * c2 * c3 + c1 * s2 * s3
      self.y = c1 * s2 * c3 - s1 * c2 * s3
      self.z = c1 * c2 * s3 - s1 * s2 * c3
      self.w = c1 * c2 * c3 + s1 * s2 * s3
    }
    ZXY => {
      self.x = s1 * c2 * c3 - c1 * s2 * s3
      self.y = c1 * s2 * c3 + s1 * c2 * s3
      self.z = c1 * c2 * s3 + s1 * s2 * c3
      self.w = c1 * c2 * c3 - s1 * s2 * s3
    }
    ZYX => {
      self.x = s1 * c2 * c3 - c1 * s2 * s3
      self.y = c1 * s2 * c3 + s1 * c2 * s3
      self.z = c1 * c2 * s3 - s1 * s2 * c3
      self.w = c1 * c2 * c3 + s1 * s2 * s3
    }
    YZX => {
      self.x = s1 * c2 * c3 + c1 * s2 * s3
      self.y = c1 * s2 * c3 + s1 * c2 * s3
      self.z = c1 * c2 * s3 - s1 * s2 * c3
      self.w = c1 * c2 * c3 - s1 * s2 * s3
    }
    XZY => {
      self.x = s1 * c2 * c3 - c1 * s2 * s3
      self.y = c1 * s2 * c3 - s1 * c2 * s3
      self.z = c1 * c2 * s3 + s1 * s2 * c3
      self.w = c1 * c2 * c3 + s1 * s2 * s3
    }
  }
  if update {
    self.emit()
  }
  self
}

///|
pub fn Quaternion::set_from_axis_angle(
  self : Quaternion,
  axis : Vector3,
  angle : Double,
) -> Quaternion {
  let half = angle / 2.0
  let s = @std.sin(half)
  self.x = axis.x * s
  self.y = axis.y * s
  self.z = axis.z * s
  self.w = @std.cos(half)
  self.emit()
  self
}

///|
pub fn Quaternion::set_from_rotation_matrix(
  self : Quaternion,
  m : Matrix4,
) -> Quaternion {
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
  let trace = m11 + m22 + m33
  if trace > 0.0 {
    let s = 0.5 / (trace + 1.0).sqrt()
    self.w = 0.25 / s
    self.x = (m32 - m23) * s
    self.y = (m13 - m31) * s
    self.z = (m21 - m12) * s
  } else if m11 > m22 && m11 > m33 {
    let s = 2.0 * (1.0 + m11 - m22 - m33).sqrt()
    self.w = (m32 - m23) / s
    self.x = 0.25 * s
    self.y = (m12 + m21) / s
    self.z = (m13 + m31) / s
  } else if m22 > m33 {
    let s = 2.0 * (1.0 + m22 - m11 - m33).sqrt()
    self.w = (m13 - m31) / s
    self.x = (m12 + m21) / s
    self.y = 0.25 * s
    self.z = (m23 + m32) / s
  } else {
    let s = 2.0 * (1.0 + m33 - m11 - m22).sqrt()
    self.w = (m21 - m12) / s
    self.x = (m13 + m31) / s
    self.y = (m23 + m32) / s
    self.z = 0.25 * s
  }
  self.emit()
  self
}

///|
pub fn Quaternion::conjugate(self : Quaternion) -> Quaternion {
  self.x = -self.x
  self.y = -self.y
  self.z = -self.z
  self.emit()
  self
}

///|
pub fn Quaternion::invert(self : Quaternion) -> Quaternion {
  self.conjugate()
}

///|
pub fn Quaternion::dot(self : Quaternion, v : Quaternion) -> Double {
  self.x * v.x + self.y * v.y + self.z * v.z + self.w * v.w
}

///|
pub fn Quaternion::length(self : Quaternion) -> Double {
  (self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w).sqrt()
}

///|
pub fn Quaternion::normalize(self : Quaternion) -> Quaternion {
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
  self.emit()
  self
}

///|
pub fn Quaternion::multiply(self : Quaternion, q : Quaternion) -> Quaternion {
  self.multiply_quaternions(self, q)
}

///|
pub fn Quaternion::premultiply(self : Quaternion, q : Quaternion) -> Quaternion {
  self.multiply_quaternions(q, self)
}

///|
pub fn Quaternion::multiply_quaternions(
  self : Quaternion,
  a : Quaternion,
  b : Quaternion,
) -> Quaternion {
  let qax = a.x
  let qay = a.y
  let qaz = a.z
  let qaw = a.w
  let qbx = b.x
  let qby = b.y
  let qbz = b.z
  let qbw = b.w
  self.x = qax * qbw + qaw * qbx + qay * qbz - qaz * qby
  self.y = qay * qbw + qaw * qby + qaz * qbx - qax * qbz
  self.z = qaz * qbw + qaw * qbz + qax * qby - qay * qbx
  self.w = qaw * qbw - qax * qbx - qay * qby - qaz * qbz
  self.emit()
  self
}

///|
/// r186: `slerp` https://github.com/mrdoob/three.js/blob/r186/src/math/Quaternion.js#L534
pub fn Quaternion::slerp(
  self : Quaternion,
  qb : Quaternion,
  t : Double,
) -> Quaternion {
  let mut x = qb.x
  let mut y = qb.y
  let mut z = qb.z
  let mut w = qb.w
  let mut dot = self.dot(qb)
  if dot < 0.0 {
    x = -x
    y = -y
    z = -z
    w = -w
    dot = -dot
  }
  if dot < 0.9995 {
    let theta = @std.acos(dot)
    let sin_theta = @std.sin(theta)
    let s = @std.sin((1.0 - t) * theta) / sin_theta
    let u = @std.sin(t * theta) / sin_theta
    self.x = self.x * s + x * u
    self.y = self.y * s + y * u
    self.z = self.z * s + z * u
    self.w = self.w * s + w * u
    self.emit()
  } else {
    let s = 1.0 - t
    self.x = self.x * s + x * t
    self.y = self.y * s + y * t
    self.z = self.z * s + z * t
    self.w = self.w * s + w * t
    ignore(self.normalize())
  }
  self
}
