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

///|
/// 区间变化时记下前后样本的权重和偏移。端点按零曲率、零斜率或环绕处理。
/// r186: `intervalChanged_` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/CubicInterpolant.js#L41
pub fn CubicInterpolant::interval_changed(
  self : CubicInterpolant,
  i1 : Int,
  t0 : Double,
  t1 : Double,
) -> Unit {
  let positions = self.interpolant.parameter_positions
  let mut i_prev = i1 - 2
  let mut i_next = i1 + 1
  let mut t_prev = position_at(positions, i_prev)
  let mut t_next = position_at(positions, i_next)
  match t_prev {
    Some(_) => ()
    None =>
      match self.default_settings.ending_start {
        @constants.ZeroSlope => {
          i_prev = i1
          t_prev = Some(2.0 * t0 - t1)
        }
        @constants.WrapAround => {
          i_prev = positions.length() - 2
          let left = present(position_at(positions, i_prev))
          let right = present(position_at(positions, i_prev + 1))
          t_prev = Some(t0 + left - right)
        }
        @constants.ZeroCurvature => {
          i_prev = i1
          t_prev = Some(t1)
        }
      }
  }
  match t_next {
    Some(_) => ()
    None =>
      match self.default_settings.ending_end {
        @constants.ZeroSlope => {
          i_next = i1
          t_next = Some(2.0 * t1 - t0)
        }
        @constants.WrapAround => {
          i_next = 1
          let first = present(position_at(positions, 0))
          let second = present(position_at(positions, 1))
          t_next = Some(t1 + second - first)
        }
        @constants.ZeroCurvature => {
          i_next = i1 - 1
          t_next = Some(t0)
        }
      }
  }
  let half_dt = (t1 - t0) * 0.5
  let stride = self.interpolant.value_size
  self.weight_prev = half_dt / (t0 - present(t_prev))
  self.weight_next = half_dt / (present(t_next) - t1)
  self.offset_prev = i_prev * stride
  self.offset_next = i_next * stride
}
