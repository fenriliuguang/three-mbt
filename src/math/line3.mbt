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

///|
/// 把另一条线段的两端拷过来。之后改来源不影响这里。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/math/Line3.js#L64
pub fn Line3::copy(self : Line3, line : Line3) -> Line3 {
  ignore(self.start.copy(line.start))
  ignore(self.end.copy(line.end))
  self
}

///|
/// 把两端的中点写入 target。线段不改。
/// r186: `getCenter` https://github.com/mrdoob/three.js/blob/r186/src/math/Line3.js#L79
pub fn Line3::get_center(self : Line3, target : Vector3) -> Vector3 {
  ignore(target.add_vectors(self.start, self.end))
  target.multiply_scalar(0.5)
}

///|
/// 把终点减去起点写入 target。线段不改。
/// r186: `delta` https://github.com/mrdoob/three.js/blob/r186/src/math/Line3.js#L91
pub fn Line3::delta(self : Line3, target : Vector3) -> Vector3 {
  target.sub_vectors(self.end, self.start)
}

///|
/// 返回两端的平方距离。线段不改。
/// r186: `distanceSq` https://github.com/mrdoob/three.js/blob/r186/src/math/Line3.js#L102
pub fn Line3::distance_sq(self : Line3) -> Double {
  self.start.distance_to_squared(self.end)
}

///|
/// 返回两端的距离。线段不改。
/// r186: `distance` https://github.com/mrdoob/three.js/blob/r186/src/math/Line3.js#L113
pub fn Line3::distance(self : Line3) -> Double {
  self.start.distance_to(self.end)
}

///|
/// 把参数 t 处的点写入 target。t 为 0 是起点，为 1 是终点。线段不改。
/// r186: `at` https://github.com/mrdoob/three.js/blob/r186/src/math/Line3.js#L126
pub fn Line3::at(self : Line3, t : Double, target : Vector3) -> Vector3 {
  ignore(self.delta(target).multiply_scalar(t))
  target.add(self.start)
}

///|
/// 返回点在线段方向上的参数。退化线段返回 0。点和线段都不改。
/// r186: `closestPointToPointParameter` https://github.com/mrdoob/three.js/blob/r186/src/math/Line3.js#L139
pub fn Line3::closest_point_to_point_parameter(
  self : Line3,
  point : Vector3,
  clamp_to_line : Bool,
) -> Double {
  let start_p = Vector3::new().sub_vectors(point, self.start)
  let start_end = Vector3::new().sub_vectors(self.end, self.start)
  let start_end2 = start_end.dot(start_end)
  if start_end2 == 0.0 {
    return 0.0
  }
  let mut t = start_end.dot(start_p) / start_end2
  if clamp_to_line {
    t = t.clamp(min=0.0, max=1.0)
  }
  t
}
