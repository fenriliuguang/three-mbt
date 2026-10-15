// r186: `Triangle` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L23

///|
/// 三个角点组成的三角形。缺省三个角都是原点。
/// r186: `Triangle` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L23
pub(all) struct Triangle {
  a : Vector3
  b : Vector3
  c : Vector3
}

///|
pub fn Triangle::new(a? : Vector3, b? : Vector3, c? : Vector3) -> Triangle {
  let a = match a {
    None => Vector3::new()
    Some(a) => a.clone()
  }
  let b = match b {
    None => Vector3::new()
    Some(b) => b.clone()
  }
  let c = match c {
    None => Vector3::new()
    Some(c) => c.clone()
  }
  { a, b, c }
}

///|
/// 把单位法线写入 target。退化三角形写入 (0, 0, 0)。三个角点不改。
/// r186: `getNormal` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L66
pub fn Triangle::get_normal(
  a : Vector3,
  b : Vector3,
  c : Vector3,
  target : Vector3,
) -> Vector3 {
  ignore(target.sub_vectors(c, b))
  let edge = Vector3::new().sub_vectors(a, b)
  ignore(target.cross(edge))
  let length_sq = target.length_sq()
  if length_sq > 0.0 {
    target.multiply_scalar(1.0 / length_sq.sqrt())
  } else {
    target.set(0.0, 0.0, 0.0)
  }
}

///|
/// 把重心坐标写入 target。退化三角形写入 (0, 0, 0) 并返回空。角点和点都不改。
/// r186: `getBarycoord` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L94
pub fn Triangle::get_barycoord(
  point : Vector3,
  a : Vector3,
  b : Vector3,
  c : Vector3,
  target : Vector3,
) -> Vector3? {
  let v0 = Vector3::new().sub_vectors(c, a)
  let v1 = Vector3::new().sub_vectors(b, a)
  let v2 = Vector3::new().sub_vectors(point, a)
  let dot00 = v0.dot(v0)
  let dot01 = v0.dot(v1)
  let dot02 = v0.dot(v2)
  let dot11 = v1.dot(v1)
  let dot12 = v1.dot(v2)
  let denom = dot00 * dot11 - dot01 * dot01
  if denom == 0.0 {
    ignore(target.set(0.0, 0.0, 0.0))
    None
  } else {
    let inv_denom = 1.0 / denom
    let u = (dot11 * dot02 - dot01 * dot12) * inv_denom
    let v = (dot00 * dot12 - dot01 * dot02) * inv_denom
    Some(target.set(1.0 - u - v, v, u))
  }
}

///|
/// 点投影到三角形所在平面后落在三角形内或边上则为真。点和角点都不改。
/// r186: `containsPoint` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L136
pub fn Triangle::contains_point(
  point : Vector3,
  a : Vector3,
  b : Vector3,
  c : Vector3,
) -> Bool {
  match Triangle::get_barycoord(point, a, b, c, Vector3::new()) {
    None => false
    Some(coord) => coord.x >= 0.0 && coord.y >= 0.0 && coord.x + coord.y <= 1.0
  }
}

///|
/// 按重心坐标插值。退化三角形写入 (0, 0, 0) 并返回空。来源不改。
/// r186: `getInterpolation` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L163
pub fn Triangle::get_interpolation(
  point : Vector3,
  p1 : Vector3,
  p2 : Vector3,
  p3 : Vector3,
  v1 : Vector3,
  v2 : Vector3,
  v3 : Vector3,
  target : Vector3,
) -> Vector3? {
  match Triangle::get_barycoord(point, p1, p2, p3, Vector3::new()) {
    None => {
      ignore(target.set(0.0, 0.0, 0.0))
      None
    }
    Some(coord) => {
      ignore(target.set_scalar(0.0))
      ignore(target.add_scaled_vector(v1, coord.x))
      ignore(target.add_scaled_vector(v2, coord.y))
      Some(target.add_scaled_vector(v3, coord.z))
    }
  }
}

///|
/// 法线与方向的点积小于 0 时为正面。角点和方向都不改。
/// r186: `isFrontFacing` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L223
pub fn Triangle::is_front_facing(
  a : Vector3,
  b : Vector3,
  c : Vector3,
  direction : Vector3,
) -> Bool {
  let edge0 = Vector3::new().sub_vectors(c, b)
  let edge1 = Vector3::new().sub_vectors(a, b)
  edge0.cross(edge1).dot(direction) < 0.0
}

///|
/// 把三个角点拷进三角形。之后改来源向量不影响这里。
/// r186: `set` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L241
pub fn Triangle::set(
  self : Triangle,
  a : Vector3,
  b : Vector3,
  c : Vector3,
) -> Triangle {
  ignore(self.a.copy(a))
  ignore(self.b.copy(b))
  ignore(self.c.copy(c))
  self
}

///|
/// 按三个下标从点数组拷出角点。之后改点数组不影响这里。
/// r186: `setFromPointsAndIndices` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L260
pub fn Triangle::set_from_points_and_indices(
  self : Triangle,
  points : Array[Vector3],
  i0 : Int,
  i1 : Int,
  i2 : Int,
) -> Triangle {
  self.set(points[i0], points[i1], points[i2])
}

///|
/// 把另一个三角形的三个角拷过来。之后改来源不影响这里。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L306
pub fn Triangle::copy(self : Triangle, triangle : Triangle) -> Triangle {
  ignore(self.a.copy(triangle.a))
  ignore(self.b.copy(triangle.b))
  ignore(self.c.copy(triangle.c))
  self
}

///|
/// 返回一份新的三角形。来源不改。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L294
pub fn Triangle::clone(self : Triangle) -> Triangle {
  Triangle::new().copy(self)
}

///|
/// 返回三角形面积。角点不改。
/// r186: `getArea` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L321
pub fn Triangle::get_area(self : Triangle) -> Double {
  let edge0 = Vector3::new().sub_vectors(self.c, self.b)
  let edge1 = Vector3::new().sub_vectors(self.a, self.b)
  edge0.cross(edge1).length() * 0.5
}

///|
/// 把三个角的平均值写入 target。角点不改。
/// r186: `getMidpoint` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L336
pub fn Triangle::get_midpoint(self : Triangle, target : Vector3) -> Vector3 {
  ignore(target.add_vectors(self.a, self.b))
  ignore(target.add(self.c))
  target.multiply_scalar(1.0 / 3.0)
}

///|
/// 把单位法线写入 target。退化三角形写入 (0, 0, 0)。角点不改。
/// r186: `getNormal` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L348
pub fn Triangle::normal(self : Triangle, target : Vector3) -> Vector3 {
  Triangle::get_normal(self.a, self.b, self.c, target)
}

///|
/// 把三角形所在平面写入 target。角点不改。
/// r186: `getPlane` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L360
pub fn Triangle::get_plane(self : Triangle, target : Plane) -> Plane {
  target.set_from_coplanar_points(self.a, self.b, self.c)
}

///|
/// 把重心坐标写入 target。退化三角形写入 (0, 0, 0) 并返回空。点和角点都不改。
/// r186: `getBarycoord` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L374
pub fn Triangle::barycoord(
  self : Triangle,
  point : Vector3,
  target : Vector3,
) -> Vector3? {
  Triangle::get_barycoord(point, self.a, self.b, self.c, target)
}

///|
/// 按重心坐标插值。退化三角形写入 (0, 0, 0) 并返回空。来源不改。
/// r186: `getInterpolation` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L391
pub fn Triangle::interpolation(
  self : Triangle,
  point : Vector3,
  v1 : Vector3,
  v2 : Vector3,
  v3 : Vector3,
  target : Vector3,
) -> Vector3? {
  Triangle::get_interpolation(point, self.a, self.b, self.c, v1, v2, v3, target)
}

///|
/// 点投影到三角形所在平面后落在三角形内或边上则为真。点和角点都不改。
/// r186: `containsPoint` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L405
pub fn Triangle::contains(self : Triangle, point : Vector3) -> Bool {
  Triangle::contains_point(point, self.a, self.b, self.c)
}

///|
/// 法线与方向的点积小于 0 时为正面。角点和方向都不改。
/// r186: `isFrontFacing` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L417
pub fn Triangle::front_facing(self : Triangle, direction : Vector3) -> Bool {
  Triangle::is_front_facing(self.a, self.b, self.c, direction)
}

///|
/// 三角形与盒子相交或贴在边界上则为真。空盒为假。三角形和盒子都不改。
/// r186: `intersectsBox` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L429
pub fn Triangle::intersects_box(self : Triangle, box : Box3) -> Bool {
  box.intersects_triangle(self)
}

///|
/// 把三角形上离给定点最近的点写入 target。点和角点都不改。
/// r186: `closestPointToPoint` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L442
pub fn Triangle::closest_point_to_point(
  self : Triangle,
  p : Vector3,
  target : Vector3,
) -> Vector3 {
  let a = self.a
  let b = self.b
  let c = self.c
  let vab = Vector3::new().sub_vectors(b, a)
  let vac = Vector3::new().sub_vectors(c, a)
  let vap = Vector3::new().sub_vectors(p, a)
  let d1 = vab.dot(vap)
  let d2 = vac.dot(vap)
  if d1 <= 0.0 && d2 <= 0.0 {
    return target.copy(a)
  }
  let vbp = Vector3::new().sub_vectors(p, b)
  let d3 = vab.dot(vbp)
  let d4 = vac.dot(vbp)
  if d3 >= 0.0 && d4 <= d3 {
    return target.copy(b)
  }
  let vc = d1 * d4 - d3 * d2
  if vc <= 0.0 && d1 >= 0.0 && d3 <= 0.0 {
    let v = d1 / (d1 - d3)
    return target.copy(a).add_scaled_vector(vab, v)
  }
  let vcp = Vector3::new().sub_vectors(p, c)
  let d5 = vab.dot(vcp)
  let d6 = vac.dot(vcp)
  if d6 >= 0.0 && d5 <= d6 {
    return target.copy(c)
  }
  let vb = d5 * d2 - d1 * d6
  if vb <= 0.0 && d2 >= 0.0 && d6 <= 0.0 {
    let w = d2 / (d2 - d6)
    return target.copy(a).add_scaled_vector(vac, w)
  }
  let va = d3 * d6 - d5 * d4
  if va <= 0.0 && (d4 - d3) >= 0.0 && (d5 - d6) >= 0.0 {
    let vbc = Vector3::new().sub_vectors(c, b)
    let w = (d4 - d3) / ((d4 - d3) + (d5 - d6))
    return target.copy(b).add_scaled_vector(vbc, w)
  }
  let denom = 1.0 / (va + vb + vc)
  let v = vb * denom
  let w = vc * denom
  ignore(target.copy(a).add_scaled_vector(vab, v))
  target.add_scaled_vector(vac, w)
}
