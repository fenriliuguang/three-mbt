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

///|
/// 把线段上离给定点最近的点写入 target。点和线段都不改。
/// r186: `closestPointToPoint` https://github.com/mrdoob/three.js/blob/r186/src/math/Line3.js#L170
pub fn Line3::closest_point_to_point(
  self : Line3,
  point : Vector3,
  clamp_to_line : Bool,
  target : Vector3,
) -> Vector3 {
  let t = self.closest_point_to_point_parameter(point, clamp_to_line)
  ignore(self.delta(target).multiply_scalar(t))
  target.add(self.start)
}

///|
/// 返回两条线段的最近平方距离。传入的点会写成两条线上的最近点。线段本身不改。
/// r186: `distanceSqToLine3` https://github.com/mrdoob/three.js/blob/r186/src/math/Line3.js#L186
pub fn Line3::distance_sq_to_line3(
  self : Line3,
  line : Line3,
  c1? : Vector3,
  c2? : Vector3,
) -> Double {
  let out1 = match c1 {
    None => Vector3::new()
    Some(c1) => c1
  }
  let out2 = match c2 {
    None => Vector3::new()
    Some(c2) => c2
  }
  let epsilon = 1.0e-16
  let p1 = self.start
  let p2 = line.start
  let d1 = Vector3::new().sub_vectors(self.end, p1)
  let d2 = Vector3::new().sub_vectors(line.end, p2)
  let r = Vector3::new().sub_vectors(p1, p2)
  let a = d1.dot(d1)
  let e = d2.dot(d2)
  let f = d2.dot(r)
  if a <= epsilon && e <= epsilon {
    ignore(out1.copy(p1))
    ignore(out2.copy(p2))
    ignore(out1.sub(out2))
    return out1.dot(out1)
  }
  let mut s = 0.0
  let mut t = 0.0
  if a <= epsilon {
    t = (f / e).clamp(min=0.0, max=1.0)
  } else {
    let c = d1.dot(r)
    if e <= epsilon {
      s = (-c / a).clamp(min=0.0, max=1.0)
    } else {
      let b = d1.dot(d2)
      let denom = a * e - b * b
      if denom != 0.0 {
        s = ((b * f - c * e) / denom).clamp(min=0.0, max=1.0)
      }
      t = (b * s + f) / e
      if t < 0.0 {
        t = 0.0
        s = (-c / a).clamp(min=0.0, max=1.0)
      } else if t > 1.0 {
        t = 1.0
        s = ((b - c) / a).clamp(min=0.0, max=1.0)
      }
    }
  }
  ignore(out1.copy(p1).add_scaled_vector(d1, s))
  ignore(out2.copy(p2).add_scaled_vector(d2, t))
  out1.distance_to_squared(out2)
}

///|
/// 用矩阵变换两端。
/// r186: `applyMatrix4` https://github.com/mrdoob/three.js/blob/r186/src/math/Line3.js#L303
pub fn Line3::apply_matrix4(self : Line3, matrix : Matrix4) -> Line3 {
  ignore(self.start.apply_matrix4(matrix))
  ignore(self.end.apply_matrix4(matrix))
  self
}
