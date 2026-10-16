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
