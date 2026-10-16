// r186: `Ray` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L14

///|
/// 从原点沿方向发出的射线。缺省原点是 (0, 0, 0)，方向是 (0, 0, -1)。
/// r186: `Ray` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L14
pub(all) struct Ray {
  origin : Vector3
  direction : Vector3
}

///|
pub fn Ray::new(origin? : Vector3, direction? : Vector3) -> Ray {
  let origin = match origin {
    None => Vector3::new()
    Some(origin) => origin.clone()
  }
  let direction = match direction {
    None => Vector3::new(z=-1.0)
    Some(direction) => direction.clone()
  }
  { origin, direction }
}

///|
/// 拷贝原点和方向。之后改来源向量不影响这里。
/// r186: `set` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L47
pub fn Ray::set(self : Ray, origin : Vector3, direction : Vector3) -> Ray {
  ignore(self.origin.copy(origin))
  ignore(self.direction.copy(direction))
  self
}

///|
/// 把另一条射线的原点和方向拷过来。之后改来源不影响这里。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L62
pub fn Ray::copy(self : Ray, ray : Ray) -> Ray {
  ignore(self.origin.copy(ray.origin))
  ignore(self.direction.copy(ray.direction))
  self
}

///|
/// 沿射线走距离 t，写入 target。射线不改。
/// r186: `at` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L78
pub fn Ray::at(self : Ray, t : Double, target : Vector3) -> Vector3 {
  target.copy(self.origin).add_scaled_vector(self.direction, t)
}

///|
/// 把方向改成从原点指向这个点，并单位化。点不改。
/// r186: `lookAt` https://github.com/mrdoob/three.js/blob/r186/src/math/Ray.js#L90
pub fn Ray::look_at(self : Ray, v : Vector3) -> Ray {
  ignore(self.direction.copy(v).sub(self.origin).normalize())
  self
}
