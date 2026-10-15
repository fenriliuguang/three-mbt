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
