// r186: `Euler` https://github.com/mrdoob/three.js/blob/r186/src/math/Euler.js#L25

///|
/// 欧拉角顺序。默认 `XYZ`，与 r186 `Euler.DEFAULT_ORDER` 相同。
/// r186: `Euler` https://github.com/mrdoob/three.js/blob/r186/src/math/Euler.js#L25
pub(all) enum EulerOrder {
  XYZ
  YXZ
  ZXY
  ZYX
  YZX
  XZY
}

///|
/// 弧度制欧拉角。写入分量请用 `set` 或 `set_x` / `set_y` / `set_z`，
/// 这样挂在 `Object3D` 上时才会同步四元数。直接改字段不会触发回调。
/// r186: `Euler` https://github.com/mrdoob/three.js/blob/r186/src/math/Euler.js#L25
pub(all) struct Euler {
  mut x : Double
  mut y : Double
  mut z : Double
  mut order : EulerOrder
  mut on_change : (() -> Unit)?
}

///|
pub fn Euler::new(
  x? : Double = 0.0,
  y? : Double = 0.0,
  z? : Double = 0.0,
  order? : EulerOrder = XYZ,
) -> Euler {
  { x, y, z, order, on_change: None, }
}

///|
fn Euler::emit(self : Euler) -> Unit {
  match self.on_change {
    None => ()
    Some(notify) => notify()
  }
}

///|
pub fn Euler::set(
  self : Euler,
  x : Double,
  y : Double,
  z : Double,
  order? : EulerOrder,
) -> Euler {
  self.x = x
  self.y = y
  self.z = z
  match order {
    None => ()
    Some(order) => self.order = order
  }
  self.emit()
  self
}

///|
pub fn Euler::set_x(self : Euler, x : Double) -> Euler {
  self.set(x, self.y, self.z)
}

///|
pub fn Euler::set_y(self : Euler, y : Double) -> Euler {
  self.set(self.x, y, self.z)
}

///|
pub fn Euler::set_z(self : Euler, z : Double) -> Euler {
  self.set(self.x, self.y, z)
}

///|
pub fn Euler::set_order(self : Euler, order : EulerOrder) -> Euler {
  self.order = order
  self.emit()
  self
}

///|
pub fn Euler::copy(self : Euler, euler : Euler) -> Euler {
  self.x = euler.x
  self.y = euler.y
  self.z = euler.z
  self.order = euler.order
  self.emit()
  self
}

///|
pub fn Euler::set_from_rotation_matrix(
  self : Euler,
  m : Matrix4,
  order? : EulerOrder,
  update? : Bool = true,
) -> Euler {
  let order = match order {
    None => self.order
    Some(order) => order
  }
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
  match order {
    XYZ => {
      self.y = @std.asin(m13.clamp(min=-1.0, max=1.0))
      if m13.abs() < 0.9999999 {
        self.x = @std.atan2(-m23, m33)
        self.z = @std.atan2(-m12, m11)
      } else {
        self.x = @std.atan2(m32, m22)
        self.z = 0.0
      }
    }
    YXZ => {
      self.x = @std.asin((-m23).clamp(min=-1.0, max=1.0))
      if m23.abs() < 0.9999999 {
        self.y = @std.atan2(m13, m33)
        self.z = @std.atan2(m21, m22)
      } else {
        self.y = @std.atan2(-m31, m11)
        self.z = 0.0
      }
    }
    ZXY => {
      self.x = @std.asin(m32.clamp(min=-1.0, max=1.0))
      if m32.abs() < 0.9999999 {
        self.y = @std.atan2(-m31, m33)
        self.z = @std.atan2(-m12, m22)
      } else {
        self.y = 0.0
        self.z = @std.atan2(m21, m11)
      }
    }
    ZYX => {
      self.y = @std.asin((-m31).clamp(min=-1.0, max=1.0))
      if m31.abs() < 0.9999999 {
        self.x = @std.atan2(m32, m33)
        self.z = @std.atan2(m21, m11)
      } else {
        self.x = 0.0
        self.z = @std.atan2(-m12, m22)
      }
    }
    YZX => {
      self.z = @std.asin(m21.clamp(min=-1.0, max=1.0))
      if m21.abs() < 0.9999999 {
        self.x = @std.atan2(-m23, m22)
        self.y = @std.atan2(-m31, m11)
      } else {
        self.x = 0.0
        self.y = @std.atan2(m13, m33)
      }
    }
    XZY => {
      self.z = @std.asin((-m12).clamp(min=-1.0, max=1.0))
      if m12.abs() < 0.9999999 {
        self.x = @std.atan2(m32, m22)
        self.y = @std.atan2(m13, m11)
      } else {
        self.x = @std.atan2(-m23, m33)
        self.y = 0.0
      }
    }
  }
  self.order = order
  if update {
    self.emit()
  }
  self
}

///|
/// r186: `setFromQuaternion` https://github.com/mrdoob/three.js/blob/r186/src/math/Euler.js#L328
pub fn Euler::set_from_quaternion(
  self : Euler,
  q : Quaternion,
  order? : EulerOrder,
  update? : Bool = true,
) -> Euler {
  let matrix = Matrix4::new().make_rotation_from_quaternion(q)
  match order {
    None => self.set_from_rotation_matrix(matrix, update~)
    Some(order) => self.set_from_rotation_matrix(matrix, order~, update~)
  }
}

///|
pub fn Euler::reorder(self : Euler, new_order : EulerOrder) -> Euler {
  let quaternion = Quaternion::new().set_from_euler(self)
  self.set_from_quaternion(quaternion, order=new_order)
}
