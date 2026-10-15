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
