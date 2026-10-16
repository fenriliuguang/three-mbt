// r186: `CubicInterpolant` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/CubicInterpolant.js#L13

///|
/// 三次样条插值。权重从 `-0` 开始，两端默认零曲率。
/// r186: `CubicInterpolant` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/CubicInterpolant.js#L13
pub(all) struct CubicInterpolant {
  interpolant : Interpolant
  mut weight_prev : Double
  mut offset_prev : Int
  mut weight_next : Double
  mut offset_next : Int
  default_settings : SplineEndings
}

///|
/// 三次样条的端点设置。上游没有同名类型，对应 `DefaultSettings_`。
/// r186: `DefaultSettings_` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/CubicInterpolant.js#L32
pub(all) struct SplineEndings {
  mut ending_start : @constants.SplineEnding
  mut ending_end : @constants.SplineEnding
}

///|
/// r186: `constructor` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/CubicInterpolant.js#L23
pub fn CubicInterpolant::new(
  parameter_positions : Array[Double],
  sample_values : Array[Double],
  sample_size : Int,
  result_buffer? : Array[Double],
) -> CubicInterpolant {
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
  {
    interpolant,
    weight_prev: -0.0,
    offset_prev: 0,
    weight_next: -0.0,
    offset_next: 0,
    default_settings: {
      ending_start: @constants.ZeroCurvature,
      ending_end: @constants.ZeroCurvature,
    },
  }
}
