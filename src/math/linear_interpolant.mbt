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

///|
/// 在相邻样本之间按时间加权。
/// r186: `interpolate_` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/LinearInterpolant.js#L24
pub fn LinearInterpolant::interpolate(
  self : LinearInterpolant,
  i1 : Int,
  t0 : Double,
  t : Double,
  t1 : Double,
) -> Array[Double] {
  let result = self.interpolant.result_buffer
  let values = self.interpolant.sample_values
  let stride = self.interpolant.value_size
  let offset1 = i1 * stride
  let offset0 = offset1 - stride
  let weight1 = (t - t0) / (t1 - t0)
  let weight0 = 1.0 - weight1
  for i in 0..<stride {
    result[i] = values[offset0 + i] * weight0 + values[offset1 + i] * weight1
  }
  result
}
