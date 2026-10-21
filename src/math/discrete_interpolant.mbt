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
  sample_size : Int32,
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

///|
/// 取参数左侧的样本。时间参数不参与计算。
/// r186: `interpolate_` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/DiscreteInterpolant.js#L25
pub fn DiscreteInterpolant::interpolate(
  self : DiscreteInterpolant,
  i1 : Int32,
  t0 : Double,
  t : Double,
  t1 : Double,
) -> Array[Double] {
  ignore(t0)
  ignore(t)
  ignore(t1)
  self.interpolant.copy_sample_value(i1 - 1)
}
