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
