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

///|
/// 返回球心到平面的有符号距离再减去半径。球和平面都不改。
/// r186: `distanceToSphere` https://github.com/mrdoob/three.js/blob/r186/src/math/Plane.js#L187
pub fn Plane::distance_to_sphere(self : Plane, sphere : Sphere) -> Double {
  self.distance_to_point(sphere.center) - sphere.radius
}

///|
/// 把点沿法线投到平面上，写入 target。点和平面都不改。
/// r186: `projectPoint` https://github.com/mrdoob/three.js/blob/r186/src/math/Plane.js#L200
pub fn Plane::project_point(
  self : Plane,
  point : Vector3,
  target : Vector3,
) -> Vector3 {
  let distance = self.distance_to_point(point)
  target.copy(point).add_scaled_vector(self.normal, -distance)
}

///|
/// 把线段与平面的交点写入 target。平行且不在平面上时返回空。线段和平面都不改。
/// r186: `intersectLine` https://github.com/mrdoob/three.js/blob/r186/src/math/Plane.js#L216
pub fn Plane::intersect_line(
  self : Plane,
  line : Line3,
  target : Vector3,
  clamp_to_line? : Bool = true,
) -> Vector3? {
  let direction = line.delta(Vector3::new())
  let denominator = self.normal.dot(direction)
  if denominator == 0.0 {
    if self.distance_to_point(line.start) == 0.0 {
      Some(target.copy(line.start))
    } else {
      None
    }
  } else {
    let t = -(line.start.dot(self.normal) + self.constant) / denominator
    if clamp_to_line && (t < 0.0 || t > 1.0) {
      None
    } else {
      Some(target.copy(line.start).add_scaled_vector(direction, t))
    }
  }
}

///|
/// 线段两端分别在平面两侧则为真。贴在平面上不算。线段和平面都不改。
/// r186: `intersectsLine` https://github.com/mrdoob/three.js/blob/r186/src/math/Plane.js#L254
pub fn Plane::intersects_line(self : Plane, line : Line3) -> Bool {
  let start_sign = self.distance_to_point(line.start)
  let end_sign = self.distance_to_point(line.end)
  (start_sign < 0.0 && end_sign > 0.0) || (end_sign < 0.0 && start_sign > 0.0)
}

///|
/// 平面与盒子相交或贴在面上则为真。平面和盒子都不改。
/// r186: `intersectsBox` https://github.com/mrdoob/three.js/blob/r186/src/math/Plane.js#L271
pub fn Plane::intersects_box(self : Plane, box : Box3) -> Bool {
  box.intersects_plane(self)
}

///|
/// 平面与球相交或相切则为真。平面和球都不改。
/// r186: `intersectsSphere` https://github.com/mrdoob/three.js/blob/r186/src/math/Plane.js#L283
pub fn Plane::intersects_sphere(self : Plane, sphere : Sphere) -> Bool {
  sphere.intersects_plane(self)
}

///|
/// 把法线乘以常数的相反数写入 target。平面不改。
/// r186: `coplanarPoint` https://github.com/mrdoob/three.js/blob/r186/src/math/Plane.js#L296
pub fn Plane::coplanar_point(self : Plane, target : Vector3) -> Vector3 {
  target.copy(self.normal).multiply_scalar(-self.constant)
}

///|
/// 用矩阵变换平面。缺省时由矩阵自己算出法线矩阵。
/// r186: `applyMatrix4` https://github.com/mrdoob/three.js/blob/r186/src/math/Plane.js#L314
pub fn Plane::apply_matrix4(
  self : Plane,
  matrix : Matrix4,
  normal_matrix? : Matrix3,
) -> Plane {
  let normal_matrix = match normal_matrix {
    None => Matrix3::new().get_normal_matrix(matrix)
    Some(normal_matrix) => normal_matrix
  }
  let reference = self.coplanar_point(Vector3::new()).apply_matrix4(matrix)
  ignore(self.normal.apply_matrix3(normal_matrix).normalize())
  self.constant = -reference.dot(self.normal)
  self
}

///|
/// 按偏移在法线方向上移动平面。法线不改。
/// r186: `translate` https://github.com/mrdoob/three.js/blob/r186/src/math/Plane.js#L335
pub fn Plane::translate(self : Plane, offset : Vector3) -> Plane {
  self.constant = self.constant - offset.dot(self.normal)
  self
}
