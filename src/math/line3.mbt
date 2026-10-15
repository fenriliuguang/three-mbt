// r186: `Line3` https://github.com/mrdoob/three.js/blob/r186/src/math/Line3.js#L16

///|
/// 由起点和终点组成的线段。缺省两端都是原点。
/// r186: `Line3` https://github.com/mrdoob/three.js/blob/r186/src/math/Line3.js#L16
pub(all) struct Line3 {
  start : Vector3
  end : Vector3
}

///|
pub fn Line3::new(start? : Vector3, end? : Vector3) -> Line3 {
  let start = match start {
    None => Vector3::new()
    Some(start) => start.clone()
  }
  let end = match end {
    None => Vector3::new()
    Some(end) => end.clone()
  }
  { start, end }
}

///|
/// 把起点和终点拷进线段。之后改来源向量不影响这里。
/// r186: `set` https://github.com/mrdoob/three.js/blob/r186/src/math/Line3.js#L49
pub fn Line3::set(self : Line3, start : Vector3, end : Vector3) -> Line3 {
  ignore(self.start.copy(start))
  ignore(self.end.copy(end))
  self
}
