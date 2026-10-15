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
