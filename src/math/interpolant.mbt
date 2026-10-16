// r186: `Interpolant` https://github.com/mrdoob/three.js/blob/r186/src/math/Interpolant.js#L20

///|
/// 一维参数上的样本插值。没给结果缓冲时，长度是 `sampleSize` 的全 0 数组。
/// r186: `Interpolant` https://github.com/mrdoob/three.js/blob/r186/src/math/Interpolant.js#L20
pub(all) struct Interpolant {
  parameter_positions : Array[Double]
  mut cached_index : Int
  result_buffer : Array[Double]
  sample_values : Array[Double]
  value_size : Int
}

///|
/// r186: `constructor` https://github.com/mrdoob/three.js/blob/r186/src/math/Interpolant.js#L30
pub fn Interpolant::new(
  parameter_positions : Array[Double],
  sample_values : Array[Double],
  sample_size : Int,
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
  }
}

///|
/// 把第 `index` 个样本抄进结果缓冲。样本本身不改。
/// r186: `copySampleValue_` https://github.com/mrdoob/three.js/blob/r186/src/math/Interpolant.js#L269
pub fn Interpolant::copy_sample_value(
  self : Interpolant,
  index : Int,
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
  i1 : Int,
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
