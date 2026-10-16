// r186: `LinearInterpolant` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/LinearInterpolant.js#L8

///|
/// 线性插值。在相邻两个样本之间按时间加权。
/// r186: `LinearInterpolant` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/LinearInterpolant.js#L8
pub(all) struct LinearInterpolant {
  interpolant : Interpolant
}

///|
/// r186: `constructor` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/LinearInterpolant.js#L18
pub fn LinearInterpolant::new(
  parameter_positions : Array[Double],
  sample_values : Array[Double],
  sample_size : Int,
  result_buffer? : Array[Double],
) -> LinearInterpolant {
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
  { interpolant, }
}
