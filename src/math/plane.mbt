// r186: `Plane` https://github.com/mrdoob/three.js/blob/r186/src/math/Plane.js#L13

///|
/// Hessian 法式平面。`Frustum` 用它描述六个裁剪面。
/// r186: `Plane` https://github.com/mrdoob/three.js/blob/r186/src/math/Plane.js#L13
pub(all) struct Plane {
  normal : Vector3
  mut constant : Double
}

///|
pub fn Plane::new(normal? : Vector3, constant? : Double = 0.0) -> Plane {
  let normal = match normal {
    None => Vector3::new(x=1.0, y=0.0, z=0.0)
    Some(normal) => normal.clone()
  }
  { normal, constant, }
}

///|
pub fn Plane::set_components(
  self : Plane,
  x : Double,
  y : Double,
  z : Double,
  w : Double,
) -> Plane {
  ignore(self.normal.set(x, y, z))
  self.constant = w
  self
}

///|
pub fn Plane::copy(self : Plane, plane : Plane) -> Plane {
  ignore(self.normal.copy(plane.normal))
  self.constant = plane.constant
  self
}

///|
pub fn Plane::normalize(self : Plane) -> Plane {
  let inverse = 1.0 / self.normal.length()
  ignore(self.normal.multiply_scalar(inverse))
  self.constant *= inverse
  self
}

///|
pub fn Plane::distance_to_point(self : Plane, point : Vector3) -> Double {
  self.normal.dot(point) + self.constant
}

///|
/// 用法线和平面上一点重设平面。来源不改。
/// r186: `setFromNormalAndCoplanarPoint` https://github.com/mrdoob/three.js/blob/r186/src/math/Plane.js#L92
pub fn Plane::set_from_normal_and_coplanar_point(
  self : Plane,
  normal : Vector3,
  point : Vector3,
) -> Plane {
  ignore(self.normal.copy(normal))
  self.constant = -point.dot(self.normal)
  self
}

///|
/// 用三个共面点重设平面。法线由 `(c - b)` 与 `(a - b)` 的叉积归一化得到。三点不改。
/// r186: `setFromCoplanarPoints` https://github.com/mrdoob/three.js/blob/r186/src/math/Plane.js#L111
pub fn Plane::set_from_coplanar_points(
  self : Plane,
  a : Vector3,
  b : Vector3,
  c : Vector3,
) -> Plane {
  let normal = Vector3::new().sub_vectors(c, b)
  let edge = Vector3::new().sub_vectors(a, b)
  ignore(normal.cross(edge).normalize())
  self.set_from_normal_and_coplanar_point(normal, a)
}

///|
/// 拷贝法线并写入常数。之后改来源法线不影响这里。
/// r186: `set` https://github.com/mrdoob/three.js/blob/r186/src/math/Plane.js#L56
pub fn Plane::set(
  self : Plane,
  normal : Vector3,
  constant : Double,
) -> Plane {
  ignore(self.normal.copy(normal))
  self.constant = constant
  self
}

///|
/// 把法线和常数同时取反。
/// r186: `negate` https://github.com/mrdoob/three.js/blob/r186/src/math/Plane.js#L160
pub fn Plane::negate(self : Plane) -> Plane {
  self.constant = -self.constant
  ignore(self.normal.negate())
  self
}
