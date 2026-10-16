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
