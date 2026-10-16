// r186: `DiscreteInterpolant` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/DiscreteInterpolant.js#L9

///|
/// 离散插值。取值落在参数左侧的样本上。
/// r186: `DiscreteInterpolant` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/DiscreteInterpolant.js#L9
pub(all) struct DiscreteInterpolant {
  interpolant : Interpolant
}

///|
/// r186: `constructor` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/DiscreteInterpolant.js#L19
pub fn DiscreteInterpolant::new(
  parameter_positions : Array[Double],
  sample_values : Array[Double],
  sample_size : Int,
  result_buffer? : Array[Double],
) -> DiscreteInterpolant {
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
