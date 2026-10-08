///|
/// 列主序 4×4 矩阵。`set` 的参数按行主序书写，与 r186 `Matrix4` 相同。
pub(all) struct Matrix4 {
  elements : FixedArray[Double]
}

///|
fn matrix4_elements() -> FixedArray[Double] {
  let te = FixedArray::make(16, 0.0)
  te[0] = 1.0
  te[5] = 1.0
  te[10] = 1.0
  te[15] = 1.0
  te
}

///|
pub fn Matrix4::new() -> Matrix4 {
  { elements: matrix4_elements(), }
}

///|
pub fn Matrix4::set(
  self : Matrix4,
  n11 : Double,
  n12 : Double,
  n13 : Double,
  n14 : Double,
  n21 : Double,
  n22 : Double,
  n23 : Double,
  n24 : Double,
  n31 : Double,
  n32 : Double,
  n33 : Double,
  n34 : Double,
  n41 : Double,
  n42 : Double,
  n43 : Double,
  n44 : Double,
) -> Matrix4 {
  let te = self.elements
  te[0] = n11
  te[4] = n12
  te[8] = n13
  te[12] = n14
  te[1] = n21
  te[5] = n22
  te[9] = n23
  te[13] = n24
  te[2] = n31
  te[6] = n32
  te[10] = n33
  te[14] = n34
  te[3] = n41
  te[7] = n42
  te[11] = n43
  te[15] = n44
  self
}

///|
pub fn Matrix4::identity(self : Matrix4) -> Matrix4 {
  self.set(
    1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0,
  )
}

///|
pub fn Matrix4::copy(self : Matrix4, m : Matrix4) -> Matrix4 {
  let te = self.elements
  let me = m.elements
  for i in 0..<16 {
    te[i] = me[i]
  }
  self
}

///|
pub fn Matrix4::clone(self : Matrix4) -> Matrix4 {
  Matrix4::new().copy(self)
}

///|
pub fn Matrix4::make_translation(
  self : Matrix4,
  x : Double,
  y : Double,
  z : Double,
) -> Matrix4 {
  self.set(
    1.0, 0.0, 0.0, x, 0.0, 1.0, 0.0, y, 0.0, 0.0, 1.0, z, 0.0, 0.0, 0.0, 1.0,
  )
}

///|
pub fn Matrix4::set_position(
  self : Matrix4,
  x : Double,
  y : Double,
  z : Double,
) -> Matrix4 {
  let te = self.elements
  te[12] = x
  te[13] = y
  te[14] = z
  self
}

///|
pub fn Matrix4::set_position_vector(self : Matrix4, v : Vector3) -> Matrix4 {
  self.set_position(v.x, v.y, v.z)
}

///|
pub fn Matrix4::make_rotation_from_euler(
  self : Matrix4,
  euler : Euler,
) -> Matrix4 {
  let te = self.elements
  let x = euler.x
  let y = euler.y
  let z = euler.z
  let a = @std.cos(x)
  let b = @std.sin(x)
  let c = @std.cos(y)
  let d = @std.sin(y)
  let e = @std.cos(z)
  let f = @std.sin(z)
  match euler.order {
    XYZ => {
      let ae = a * e
      let af = a * f
      let be = b * e
      let bf = b * f
      te[0] = c * e
      te[4] = -c * f
      te[8] = d
      te[1] = af + be * d
      te[5] = ae - bf * d
      te[9] = -b * c
      te[2] = bf - ae * d
      te[6] = be + af * d
      te[10] = a * c
    }
    YXZ => {
      let ce = c * e
      let cf = c * f
      let de = d * e
      let df = d * f
      te[0] = ce + df * b
      te[4] = de * b - cf
      te[8] = a * d
      te[1] = a * f
      te[5] = a * e
      te[9] = -b
      te[2] = cf * b - de
      te[6] = df + ce * b
      te[10] = a * c
    }
    ZXY => {
      let ce = c * e
      let cf = c * f
      let de = d * e
      let df = d * f
      te[0] = ce - df * b
      te[4] = -a * f
      te[8] = de + cf * b
      te[1] = cf + de * b
      te[5] = a * e
      te[9] = df - ce * b
      te[2] = -a * d
      te[6] = b
      te[10] = a * c
    }
    ZYX => {
      let ae = a * e
      let af = a * f
      let be = b * e
      let bf = b * f
      te[0] = c * e
      te[4] = be * d - af
      te[8] = ae * d + bf
      te[1] = c * f
      te[5] = bf * d + ae
      te[9] = af * d - be
      te[2] = -d
      te[6] = b * c
      te[10] = a * c
    }
    YZX => {
      let ac = a * c
      let ad = a * d
      let bc = b * c
      let bd = b * d
      te[0] = c * e
      te[4] = bd - ac * f
      te[8] = bc * f + ad
      te[1] = f
      te[5] = a * e
      te[9] = -b * e
      te[2] = -d * e
      te[6] = ad * f + bc
      te[10] = ac - bd * f
    }
    XZY => {
      let ac = a * c
      let ad = a * d
      let bc = b * c
      let bd = b * d
      te[0] = c * e
      te[4] = -f
      te[8] = d * e
      te[1] = ac * f + bd
      te[5] = a * e
      te[9] = ad * f - bc
      te[2] = bc * f - ad
      te[6] = b * e
      te[10] = bd * f + ac
    }
  }
  te[3] = 0.0
  te[7] = 0.0
  te[11] = 0.0
  te[12] = 0.0
  te[13] = 0.0
  te[14] = 0.0
  te[15] = 1.0
  self
}

///|
pub fn Matrix4::compose(
  self : Matrix4,
  position : Vector3,
  quaternion : Quaternion,
  scale : Vector3,
) -> Matrix4 {
  let te = self.elements
  let x = quaternion.x
  let y = quaternion.y
  let z = quaternion.z
  let w = quaternion.w
  let x2 = x + x
  let y2 = y + y
  let z2 = z + z
  let xx = x * x2
  let xy = x * y2
  let xz = x * z2
  let yy = y * y2
  let yz = y * z2
  let zz = z * z2
  let wx = w * x2
  let wy = w * y2
  let wz = w * z2
  let sx = scale.x
  let sy = scale.y
  let sz = scale.z
  te[0] = (1.0 - (yy + zz)) * sx
  te[1] = (xy + wz) * sx
  te[2] = (xz - wy) * sx
  te[3] = 0.0
  te[4] = (xy - wz) * sy
  te[5] = (1.0 - (xx + zz)) * sy
  te[6] = (yz + wx) * sy
  te[7] = 0.0
  te[8] = (xz + wy) * sz
  te[9] = (yz - wx) * sz
  te[10] = (1.0 - (xx + yy)) * sz
  te[11] = 0.0
  te[12] = position.x
  te[13] = position.y
  te[14] = position.z
  te[15] = 1.0
  self
}

///|
pub fn Matrix4::make_rotation_from_quaternion(
  self : Matrix4,
  q : Quaternion,
) -> Matrix4 {
  self.compose(Vector3::new(), q, Vector3::new(x=1.0, y=1.0, z=1.0))
}

///|
pub fn Matrix4::determinant_affine(self : Matrix4) -> Double {
  let te = self.elements
  let n11 = te[0]
  let n12 = te[4]
  let n13 = te[8]
  let n21 = te[1]
  let n22 = te[5]
  let n23 = te[9]
  let n31 = te[2]
  let n32 = te[6]
  let n33 = te[10]
  n11 * (n22 * n33 - n23 * n32) -
  n12 * (n21 * n33 - n23 * n31) +
  n13 * (n21 * n32 - n22 * n31)
}

///|
pub fn Matrix4::determinant(self : Matrix4) -> Double {
  let te = self.elements
  let n11 = te[0]
  let n12 = te[4]
  let n13 = te[8]
  let n14 = te[12]
  let n21 = te[1]
  let n22 = te[5]
  let n23 = te[9]
  let n24 = te[13]
  let n31 = te[2]
  let n32 = te[6]
  let n33 = te[10]
  let n34 = te[14]
  let n41 = te[3]
  let n42 = te[7]
  let n43 = te[11]
  let n44 = te[15]
  let t11 = n23 * n34 - n24 * n33
  let t12 = n22 * n34 - n24 * n32
  let t13 = n22 * n33 - n23 * n32
  let t21 = n21 * n34 - n24 * n31
  let t22 = n21 * n33 - n23 * n31
  let t23 = n21 * n32 - n22 * n31
  n11 * (n42 * t11 - n43 * t12 + n44 * t13) -
  n12 * (n41 * t11 - n43 * t21 + n44 * t22) +
  n13 * (n41 * t12 - n42 * t21 + n44 * t23) -
  n14 * (n41 * t13 - n42 * t22 + n43 * t23)
}

///|
fn column_length(m : Matrix4, column : Int) -> Double {
  let e = m.elements
  let i = column * 4
  (e[i] * e[i] + e[i + 1] * e[i + 1] + e[i + 2] * e[i + 2]).sqrt()
}

///|
pub fn Matrix4::extract_rotation(self : Matrix4, m : Matrix4) -> Matrix4 {
  if m.determinant_affine() == 0.0 {
    return self.identity()
  }
  let te = self.elements
  let me = m.elements
  let scale_x = 1.0 / column_length(m, 0)
  let scale_y = 1.0 / column_length(m, 1)
  let scale_z = 1.0 / column_length(m, 2)
  te[0] = me[0] * scale_x
  te[1] = me[1] * scale_x
  te[2] = me[2] * scale_x
  te[3] = 0.0
  te[4] = me[4] * scale_y
  te[5] = me[5] * scale_y
  te[6] = me[6] * scale_y
  te[7] = 0.0
  te[8] = me[8] * scale_z
  te[9] = me[9] * scale_z
  te[10] = me[10] * scale_z
  te[11] = 0.0
  te[12] = 0.0
  te[13] = 0.0
  te[14] = 0.0
  te[15] = 1.0
  self
}

///|
pub fn Matrix4::decompose(
  self : Matrix4,
  position : Vector3,
  quaternion : Quaternion,
  scale : Vector3,
) -> Matrix4 {
  let te = self.elements
  position.x = te[12]
  position.y = te[13]
  position.z = te[14]
  let det = self.determinant_affine()
  if det == 0.0 {
    ignore(scale.set(1.0, 1.0, 1.0))
    ignore(quaternion.identity())
    return self
  }
  let mut sx = column_length(self, 0)
  let sy = column_length(self, 1)
  let sz = column_length(self, 2)
  if det < 0.0 {
    sx = -sx
  }
  let rotation = self.clone()
  let inv_sx = 1.0 / sx
  let inv_sy = 1.0 / sy
  let inv_sz = 1.0 / sz
  let re = rotation.elements
  re[0] *= inv_sx
  re[1] *= inv_sx
  re[2] *= inv_sx
  re[4] *= inv_sy
  re[5] *= inv_sy
  re[6] *= inv_sy
  re[8] *= inv_sz
  re[9] *= inv_sz
  re[10] *= inv_sz
  ignore(quaternion.set_from_rotation_matrix(rotation))
  scale.x = sx
  scale.y = sy
  scale.z = sz
  self
}

///|
pub fn Matrix4::look_at(
  self : Matrix4,
  eye : Vector3,
  target : Vector3,
  up : Vector3,
) -> Matrix4 {
  let te = self.elements
  let z = Vector3::new().sub_vectors(eye, target)
  if z.length_sq() == 0.0 {
    z.z = 1.0
  }
  ignore(z.normalize())
  let x = Vector3::new().cross_vectors(up, z)
  if x.length_sq() == 0.0 {
    if up.z.abs() == 1.0 {
      z.x += 0.0001
    } else {
      z.z += 0.0001
    }
    ignore(z.normalize())
    ignore(x.cross_vectors(up, z))
  }
  ignore(x.normalize())
  let y = Vector3::new().cross_vectors(z, x)
  te[0] = x.x
  te[4] = y.x
  te[8] = z.x
  te[1] = x.y
  te[5] = y.y
  te[9] = z.y
  te[2] = x.z
  te[6] = y.z
  te[10] = z.z
  self
}

///|
pub fn Matrix4::multiply(self : Matrix4, m : Matrix4) -> Matrix4 {
  self.multiply_matrices(self, m)
}

///|
pub fn Matrix4::premultiply(self : Matrix4, m : Matrix4) -> Matrix4 {
  self.multiply_matrices(m, self)
}

///|
pub fn Matrix4::multiply_matrices(
  self : Matrix4,
  a : Matrix4,
  b : Matrix4,
) -> Matrix4 {
  let ae = a.elements
  let be = b.elements
  let a11 = ae[0]
  let a12 = ae[4]
  let a13 = ae[8]
  let a14 = ae[12]
  let a21 = ae[1]
  let a22 = ae[5]
  let a23 = ae[9]
  let a24 = ae[13]
  let a31 = ae[2]
  let a32 = ae[6]
  let a33 = ae[10]
  let a34 = ae[14]
  let a41 = ae[3]
  let a42 = ae[7]
  let a43 = ae[11]
  let a44 = ae[15]
  let b11 = be[0]
  let b12 = be[4]
  let b13 = be[8]
  let b14 = be[12]
  let b21 = be[1]
  let b22 = be[5]
  let b23 = be[9]
  let b24 = be[13]
  let b31 = be[2]
  let b32 = be[6]
  let b33 = be[10]
  let b34 = be[14]
  let b41 = be[3]
  let b42 = be[7]
  let b43 = be[11]
  let b44 = be[15]
  let te = self.elements
  te[0] = a11 * b11 + a12 * b21 + a13 * b31 + a14 * b41
  te[4] = a11 * b12 + a12 * b22 + a13 * b32 + a14 * b42
  te[8] = a11 * b13 + a12 * b23 + a13 * b33 + a14 * b43
  te[12] = a11 * b14 + a12 * b24 + a13 * b34 + a14 * b44
  te[1] = a21 * b11 + a22 * b21 + a23 * b31 + a24 * b41
  te[5] = a21 * b12 + a22 * b22 + a23 * b32 + a24 * b42
  te[9] = a21 * b13 + a22 * b23 + a23 * b33 + a24 * b43
  te[13] = a21 * b14 + a22 * b24 + a23 * b34 + a24 * b44
  te[2] = a31 * b11 + a32 * b21 + a33 * b31 + a34 * b41
  te[6] = a31 * b12 + a32 * b22 + a33 * b32 + a34 * b42
  te[10] = a31 * b13 + a32 * b23 + a33 * b33 + a34 * b43
  te[14] = a31 * b14 + a32 * b24 + a33 * b34 + a34 * b44
  te[3] = a41 * b11 + a42 * b21 + a43 * b31 + a44 * b41
  te[7] = a41 * b12 + a42 * b22 + a43 * b32 + a44 * b42
  te[11] = a41 * b13 + a42 * b23 + a43 * b33 + a44 * b43
  te[15] = a41 * b14 + a42 * b24 + a43 * b34 + a44 * b44
  self
}

///|
pub fn Matrix4::invert(self : Matrix4) -> Matrix4 {
  let te = self.elements
  let n11 = te[0]
  let n21 = te[1]
  let n31 = te[2]
  let n41 = te[3]
  let n12 = te[4]
  let n22 = te[5]
  let n32 = te[6]
  let n42 = te[7]
  let n13 = te[8]
  let n23 = te[9]
  let n33 = te[10]
  let n43 = te[11]
  let n14 = te[12]
  let n24 = te[13]
  let n34 = te[14]
  let n44 = te[15]
  let t1 = n11 * n22 - n21 * n12
  let t2 = n11 * n32 - n31 * n12
  let t3 = n11 * n42 - n41 * n12
  let t4 = n21 * n32 - n31 * n22
  let t5 = n21 * n42 - n41 * n22
  let t6 = n31 * n42 - n41 * n32
  let t7 = n13 * n24 - n23 * n14
  let t8 = n13 * n34 - n33 * n14
  let t9 = n13 * n44 - n43 * n14
  let t10 = n23 * n34 - n33 * n24
  let t11 = n23 * n44 - n43 * n24
  let t12 = n33 * n44 - n43 * n34
  let det = t1 * t12 - t2 * t11 + t3 * t10 + t4 * t9 - t5 * t8 + t6 * t7
  if det == 0.0 {
    return self.set(
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.0,
    )
  }
  let det_inv = 1.0 / det
  te[0] = (n22 * t12 - n32 * t11 + n42 * t10) * det_inv
  te[1] = (n31 * t11 - n21 * t12 - n41 * t10) * det_inv
  te[2] = (n24 * t6 - n34 * t5 + n44 * t4) * det_inv
  te[3] = (n33 * t5 - n23 * t6 - n43 * t4) * det_inv
  te[4] = (n32 * t9 - n12 * t12 - n42 * t8) * det_inv
  te[5] = (n11 * t12 - n31 * t9 + n41 * t8) * det_inv
  te[6] = (n34 * t3 - n14 * t6 - n44 * t2) * det_inv
  te[7] = (n13 * t6 - n33 * t3 + n43 * t2) * det_inv
  te[8] = (n12 * t11 - n22 * t9 + n42 * t7) * det_inv
  te[9] = (n21 * t9 - n11 * t11 - n41 * t7) * det_inv
  te[10] = (n14 * t5 - n24 * t3 + n44 * t1) * det_inv
  te[11] = (n23 * t3 - n13 * t5 - n43 * t1) * det_inv
  te[12] = (n22 * t8 - n12 * t10 - n32 * t7) * det_inv
  te[13] = (n11 * t10 - n21 * t8 + n31 * t7) * det_inv
  te[14] = (n24 * t2 - n14 * t4 - n34 * t1) * det_inv
  te[15] = (n13 * t4 - n23 * t2 + n33 * t1) * det_inv
  self
}

///|
pub fn Matrix4::scale(self : Matrix4, v : Vector3) -> Matrix4 {
  let te = self.elements
  let x = v.x
  let y = v.y
  let z = v.z
  te[0] *= x
  te[4] *= y
  te[8] *= z
  te[1] *= x
  te[5] *= y
  te[9] *= z
  te[2] *= x
  te[6] *= y
  te[10] *= z
  te[3] *= x
  te[7] *= y
  te[11] *= z
  self
}

///|
pub fn Matrix4::get_max_scale_on_axis(self : Matrix4) -> Double {
  let te = self.elements
  let scale_x_sq = te[0] * te[0] + te[1] * te[1] + te[2] * te[2]
  let scale_y_sq = te[4] * te[4] + te[5] * te[5] + te[6] * te[6]
  let scale_z_sq = te[8] * te[8] + te[9] * te[9] + te[10] * te[10]
  scale_x_sq.max(scale_y_sq).max(scale_z_sq).sqrt()
}

///|
pub fn Matrix4::transpose(self : Matrix4) -> Matrix4 {
  let te = self.elements
  let t1 = te[1]
  te[1] = te[4]
  te[4] = t1
  let t2 = te[2]
  te[2] = te[8]
  te[8] = t2
  let t6 = te[6]
  te[6] = te[9]
  te[9] = t6
  let t3 = te[3]
  te[3] = te[12]
  te[12] = t3
  let t7 = te[7]
  te[7] = te[13]
  te[13] = t7
  let t11 = te[11]
  te[11] = te[14]
  te[14] = t11
  self
}

///|
/// 透视投影。默认 WebGPU、非反转深度，与本仓库的绘制路径一致。
pub fn Matrix4::make_perspective(
  self : Matrix4,
  left : Double,
  right : Double,
  top : Double,
  bottom : Double,
  near : Double,
  far : Double,
  coordinate_system? : @constants.CoordinateSystem,
  reversed_depth? : Bool = false,
) -> Matrix4 {
  let coordinate_system = match coordinate_system {
    None => @constants.WebGPU
    Some(coordinate_system) => coordinate_system
  }
  let te = self.elements
  let x = 2.0 * near / (right - left)
  let y = 2.0 * near / (top - bottom)
  let a = (right + left) / (right - left)
  let b = (top + bottom) / (top - bottom)
  let c = if reversed_depth {
    near / (far - near)
  } else {
    match coordinate_system {
      WebGL => -(far + near) / (far - near)
      WebGPU => -far / (far - near)
    }
  }
  let d = if reversed_depth {
    far * near / (far - near)
  } else {
    match coordinate_system {
      WebGL => -2.0 * far * near / (far - near)
      WebGPU => -far * near / (far - near)
    }
  }
  te[0] = x
  te[4] = 0.0
  te[8] = a
  te[12] = 0.0
  te[1] = 0.0
  te[5] = y
  te[9] = b
  te[13] = 0.0
  te[2] = 0.0
  te[6] = 0.0
  te[10] = c
  te[14] = d
  te[3] = 0.0
  te[7] = 0.0
  te[11] = -1.0
  te[15] = 0.0
  self
}

///|
/// 正交投影。默认 WebGPU、非反转深度。
pub fn Matrix4::make_orthographic(
  self : Matrix4,
  left : Double,
  right : Double,
  top : Double,
  bottom : Double,
  near : Double,
  far : Double,
  coordinate_system? : @constants.CoordinateSystem,
  reversed_depth? : Bool = false,
) -> Matrix4 {
  let coordinate_system = match coordinate_system {
    None => @constants.WebGPU
    Some(coordinate_system) => coordinate_system
  }
  let te = self.elements
  let x = 2.0 / (right - left)
  let y = 2.0 / (top - bottom)
  let a = -(right + left) / (right - left)
  let b = -(top + bottom) / (top - bottom)
  let c = if reversed_depth {
    1.0 / (far - near)
  } else {
    match coordinate_system {
      WebGL => -2.0 / (far - near)
      WebGPU => -1.0 / (far - near)
    }
  }
  let d = if reversed_depth {
    far / (far - near)
  } else {
    match coordinate_system {
      WebGL => -(far + near) / (far - near)
      WebGPU => -near / (far - near)
    }
  }
  te[0] = x
  te[4] = 0.0
  te[8] = 0.0
  te[12] = a
  te[1] = 0.0
  te[5] = y
  te[9] = 0.0
  te[13] = b
  te[2] = 0.0
  te[6] = 0.0
  te[10] = c
  te[14] = d
  te[3] = 0.0
  te[7] = 0.0
  te[11] = 0.0
  te[15] = 1.0
  self
}

///|
pub fn Matrix4::equals(self : Matrix4, matrix : Matrix4) -> Bool {
  let te = self.elements
  let me = matrix.elements
  let mut same = true
  for i in 0..<16 {
    if te[i] != me[i] {
      same = false
    }
  }
  same
}
