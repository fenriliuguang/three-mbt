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
