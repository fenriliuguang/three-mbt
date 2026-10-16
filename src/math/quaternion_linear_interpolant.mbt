// r186: `QuaternionLinearInterpolant` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/QuaternionLinearInterpolant.js#L9

///|
/// 单位四元数的球面线性插值。
/// r186: `QuaternionLinearInterpolant` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/QuaternionLinearInterpolant.js#L9
pub(all) struct QuaternionLinearInterpolant {
  interpolant : Interpolant
}

///|
/// r186: `constructor` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/QuaternionLinearInterpolant.js#L19
pub fn QuaternionLinearInterpolant::new(
  parameter_positions : Array[Double],
  sample_values : Array[Double],
  sample_size : Int,
  result_buffer? : Array[Double],
) -> QuaternionLinearInterpolant {
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
/// 对每个四元数做球面线性插值，结果从缓冲下标 0 写起。
/// r186: `interpolate_` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/QuaternionLinearInterpolant.js#L25
pub fn QuaternionLinearInterpolant::interpolate(
  self : QuaternionLinearInterpolant,
  i1 : Int,
  t0 : Double,
  t : Double,
  t1 : Double,
) -> Array[Double] {
  let result = self.interpolant.result_buffer
  let values = self.interpolant.sample_values
  let stride = self.interpolant.value_size
  let alpha = (t - t0) / (t1 - t0)
  let mut offset = i1 * stride
  let end = offset + stride
  while offset != end {
    Quaternion::slerp_flat(
      result,
      0,
      values,
      offset - stride,
      values,
      offset,
      alpha,
    )
    offset = offset + 4
  }
  result
}
