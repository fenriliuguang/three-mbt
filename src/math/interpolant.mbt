// r186: `Interpolant` https://github.com/mrdoob/three.js/blob/r186/src/math/Interpolant.js#L20

///|
/// 一维参数上的样本插值。没给结果缓冲时，长度是 `sampleSize` 的全 0 数组。
/// r186: `Interpolant` https://github.com/mrdoob/three.js/blob/r186/src/math/Interpolant.js#L20
pub(all) struct Interpolant {
  parameter_positions : Array[Double]
  mut cached_index : Int32
  result_buffer : Array[Double]
  sample_values : Array[Double]
  value_size : Int32
  mut settings : InterpolantSettings?
  default_settings : InterpolantSettings
}

///|
/// 插值设置。基类默认是空对象，显式设置优先。上游没有同名类型，对应 `settings` 和 `DefaultSettings_`。
/// r186: `DefaultSettings_` https://github.com/mrdoob/three.js/blob/r186/src/math/Interpolant.js#L82
pub(all) struct InterpolantSettings {}

///|
/// r186: `constructor` https://github.com/mrdoob/three.js/blob/r186/src/math/Interpolant.js#L30
pub fn Interpolant::new(
  parameter_positions : Array[Double],
  sample_values : Array[Double],
  sample_size : Int32,
  result_buffer? : Array[Double],
) -> Interpolant {
  let result_buffer = match result_buffer {
    None => {
      let buffer : Array[Double] = []
      for _ in 0..<sample_size {
        buffer.push(0.0)
      }
      buffer
    }
    Some(buffer) => buffer
  }
  {
    parameter_positions,
    cached_index: 0,
    result_buffer,
    sample_values,
    value_size: sample_size,
    settings: None,
    default_settings: InterpolantSettings::{ },
  }
}

///|
/// 把第 `index` 个样本抄进结果缓冲。样本本身不改。
/// r186: `copySampleValue_` https://github.com/mrdoob/three.js/blob/r186/src/math/Interpolant.js#L269
pub fn Interpolant::copy_sample_value(
  self : Interpolant,
  index : Int32,
) -> Array[Double] {
  let offset = index * self.value_size
  for i in 0..<self.value_size {
    self.result_buffer[i] = self.sample_values[offset + i]
  }
  self.result_buffer
}

///|
/// 基类不插值。子类覆盖这个方法。
/// r186: `interpolate_` https://github.com/mrdoob/three.js/blob/r186/src/math/Interpolant.js#L298
pub fn Interpolant::interpolate(
  self : Interpolant,
  i1 : Int32,
  t0 : Double,
  t : Double,
  t1 : Double,
) -> Array[Double] {
  ignore(self)
  ignore(i1)
  ignore(t0)
  ignore(t)
  ignore(t1)
  abort("THREE.Interpolant: Call to abstract method.")
}

///|
/// 区间变化时基类什么都不做。
/// r186: `intervalChanged_` https://github.com/mrdoob/three.js/blob/r186/src/math/Interpolant.js#L312
pub fn Interpolant::interval_changed(
  self : Interpolant,
  i1 : Int32,
  t0 : Double,
  t1 : Double,
) -> Unit {
  ignore(self)
  ignore(i1)
  ignore(t0)
  ignore(t1)
}

///|
/// 越界下标对应 JavaScript 里的 `undefined`。
fn position_at(positions : Array[Double], index : Int32) -> Double? {
  if index < 0 || index >= positions.length() {
    None
  } else {
    Some(positions[index])
  }
}

///|
/// `!(t < bound)`。上界越界时为 true。
fn not_before(t : Double, bound : Double?) -> Bool {
  match bound {
    None => true
    Some(bound) => !(t < bound)
  }
}

///|
/// `!(t >= bound)`。下界越界时为 true。
fn not_from(t : Double, bound : Double?) -> Bool {
  match bound {
    None => true
    Some(bound) => !(t >= bound)
  }
}

///|
/// `t < bound`。上界越界时为 false。
fn is_before(t : Double, bound : Double?) -> Bool {
  match bound {
    None => false
    Some(bound) => t < bound
  }
}

///|
/// `t >= bound`。下界越界时为 false。
fn is_from(t : Double, bound : Double?) -> Bool {
  match bound {
    None => false
    Some(bound) => t >= bound
  }
}

///|
fn present(bound : Double?) -> Double {
  match bound {
    Some(bound) => bound
    None => abort("interpolant interval is missing a bound")
  }
}

///|
priv enum EvalStep {
  CopySample(Int32)
  UseInterval(Int32, Double, Double)
}

///|
fn Interpolant::binary_search_interval(
  self : Interpolant,
  t : Double,
  i1 : Int32,
  right : Int32,
) -> EvalStep {
  let positions = self.parameter_positions
  let mut i1 = i1
  let mut right = right
  while i1 < right {
    let mid = (i1 + right) / 2
    if is_before(t, position_at(positions, mid)) {
      right = mid
    } else {
      i1 = mid + 1
    }
  }
  let t0 = position_at(positions, i1 - 1)
  let t1 = position_at(positions, i1)
  match t0 {
    None => {
      self.cached_index = 0
      CopySample(0)
    }
    Some(t0) =>
      match t1 {
        None => {
          let end = positions.length()
          self.cached_index = end
          CopySample(end - 1)
        }
        Some(t1) => UseInterval(i1, t0, t1)
      }
  }
}

///|
fn Interpolant::seek_interval(self : Interpolant, t : Double) -> EvalStep {
  let positions = self.parameter_positions
  let mut i1 = self.cached_index
  let mut t1 = position_at(positions, i1)
  let mut t0 = position_at(positions, i1 - 1)
  if not_before(t, t1) {
    let give_up_at = i1 + 2
    let mut scan_reverse = false
    while true {
      match t1 {
        None =>
          if is_before(t, t0) {
            scan_reverse = true
            break
          } else {
            let end = positions.length()
            self.cached_index = end
            return CopySample(end - 1)
          }
        Some(_) =>
          if i1 == give_up_at {
            break
          } else {
            t0 = t1
            i1 = i1 + 1
            t1 = position_at(positions, i1)
            if is_before(t, t1) {
              return UseInterval(i1, present(t0), present(t1))
            }
          }
      }
    }
    if !scan_reverse {
      return self.binary_search_interval(t, i1, positions.length())
    }
  }
  if not_from(t, t0) {
    let next = position_at(positions, 1)
    if is_before(t, next) {
      i1 = 2
      t0 = next
    }
    let give_up_at = i1 - 2
    while true {
      match t0 {
        None => {
          self.cached_index = 0
          return CopySample(0)
        }
        Some(_) => {
          if i1 == give_up_at {
            break
          }
          t1 = t0
          i1 = i1 - 1
          t0 = position_at(positions, i1 - 1)
          if is_from(t, t0) {
            return UseInterval(i1, present(t0), present(t1))
          }
        }
      }
    }
    return self.binary_search_interval(t, 0, i1)
  }
  UseInterval(i1, present(t0), present(t1))
}

///|
/// 在参数 `t` 处求值。区间外复制端点样本，区间内交给 `interpolate_`。
/// r186: `evaluate` https://github.com/mrdoob/three.js/blob/r186/src/math/Interpolant.js#L92
pub fn Interpolant::evaluate(self : Interpolant, t : Double) -> Array[Double] {
  match self.seek_interval(t) {
    CopySample(index) => self.copy_sample_value(index)
    UseInterval(i1, t0, t1) => {
      self.cached_index = i1
      self.interval_changed(i1, t0, t1)
      self.interpolate(i1, t0, t, t1)
    }
  }
}

///|
/// 返回显式设置。没有显式设置时返回默认对象。
/// r186: `getSettings_` https://github.com/mrdoob/three.js/blob/r186/src/math/Interpolant.js#L257
pub fn Interpolant::get_settings(self : Interpolant) -> InterpolantSettings {
  match self.settings {
    Some(settings) => settings
    None => self.default_settings
  }
}
