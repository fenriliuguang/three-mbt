// r186: `BezierInterpolant` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/BezierInterpolant.js#L20

///|
/// 带二维控制点的三次贝塞尔插值。切线一开始没有。
/// r186: `BezierInterpolant` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/BezierInterpolant.js#L20
pub(all) struct BezierInterpolant {
  interpolant : Interpolant
  mut in_tangents : Array[Double]?
  mut out_tangents : Array[Double]?
}

///|
/// 没有单独的构造函数，沿用 `Interpolant`。
/// r186: `constructor` https://github.com/mrdoob/three.js/blob/r186/src/math/Interpolant.js#L30
pub fn BezierInterpolant::new(
  parameter_positions : Array[Double],
  sample_values : Array[Double],
  sample_size : Int,
  result_buffer? : Array[Double],
) -> BezierInterpolant {
  let interpolant = match result_buffer {
    None => Interpolant::new(parameter_positions, sample_values, sample_size)
    Some(buffer) =>
      Interpolant::new(
        parameter_positions,
        sample_values,
        sample_size,
        result_buffer=buffer,
      )
  }
  { interpolant, in_tangents: None, out_tangents: None }
}

///|
/// 三次贝塞尔在参数 `s` 处的值。
/// r186: `cubicBezier` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/BezierInterpolant.js#L81
pub fn cubic_bezier(
  s : Double,
  p0 : Double,
  p1 : Double,
  p2 : Double,
  p3 : Double,
) -> Double {
  let k = 1.0 - s
  k * k * k * p0 +
  3.0 * k * k * s * p1 +
  3.0 * k * s * s * p2 +
  s * s * s * p3
}

///|
/// 三次贝塞尔对参数 `s` 的导数。
/// r186: `cubicBezierSlope` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/BezierInterpolant.js#L89
pub fn cubic_bezier_slope(
  s : Double,
  p0 : Double,
  p1 : Double,
  p2 : Double,
  p3 : Double,
) -> Double {
  let k = 1.0 - s
  3.0 * k * k * (p1 - p0) + 6.0 * k * s * (p2 - p1) + 3.0 * s * s * (p3 - p2)
}

///|
/// 求三次贝塞尔横坐标等于 `x` 时的参数。最多迭代 8 次。
/// r186: `solveBezierParameter` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/BezierInterpolant.js#L99
pub fn solve_bezier_parameter(
  x : Double,
  x0 : Double,
  x1 : Double,
  x2 : Double,
  x3 : Double,
) -> Double {
  let mut s = (x - x0) / (x3 - x0)
  for _ in 0..<8 {
    let error = cubic_bezier(s, x0, x1, x2, x3) - x
    if error.abs() < 1.0e-10 {
      break
    }
    let slope = cubic_bezier_slope(s, x0, x1, x2, x3)
    if slope.abs() < 1.0e-10 {
      break
    }
    s = 0.0.max(1.0.min(s - error / slope))
  }
  s
}
