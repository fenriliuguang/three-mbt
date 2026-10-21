// r186: `KeyframeTrack` https://github.com/mrdoob/three.js/blob/r186/src/animation/KeyframeTrack.js#L19

///|
/// 一条关键帧。`value_size` 为 3 时按向量插值，为 4 时按四元数 slerp。
/// 时间必须非递减。`Smooth` 对向量用零曲率三次样条，四元数没有这条工厂，仍走 slerp。
/// `cubic_spline` 为真时，每个关键帧按 glTF 存切入切线、顶点、切出切线，四元数结果会归一化。
/// r186: `KeyframeTrack` https://github.com/mrdoob/three.js/blob/r186/src/animation/KeyframeTrack.js#L19
pub(all) struct KeyframeTrack {
  name : String
  times : Array[Double]
  values : Array[Double]
  value_size : Int
  mut interpolation : Interpolation
  cubic_spline : Bool
}

///|
fn check_times(times : Array[Double]) -> Unit {
  let mut previous = times[0]
  for index in 1..<times.length() {
    if times[index] < previous {
      abort("keyframe times must be sorted")
    }
    previous = times[index]
  }
}

///|
fn check_track(
  times : Array[Double],
  values : Array[Double],
  size : Int,
) -> Unit {
  if times.length() == 0 || values.length() != times.length() * size {
    abort("keyframe track size does not match its times")
  }
  check_times(times)
}

///|
fn check_cubic(
  times : Array[Double],
  values : Array[Double],
  size : Int,
) -> Unit {
  if times.length() == 0 || values.length() != times.length() * size * 3 {
    abort("keyframe track size does not match its times")
  }
  check_times(times)
}

///|
/// 向量轨道，对应 `.position` 或 `.scale`。每个关键帧 3 个数。
/// r186: `VectorKeyframeTrack` https://github.com/mrdoob/three.js/blob/r186/src/animation/tracks/VectorKeyframeTrack.js#L8
pub fn KeyframeTrack::vector(
  name : String,
  times : Array[Double],
  values : Array[Double],
) -> KeyframeTrack {
  check_track(times, values, 3)
  {
    name,
    times,
    values,
    value_size: 3,
    interpolation: Linear,
    cubic_spline: false,
  }
}

///|
/// 四元数轨道，对应 `.quaternion`。每个关键帧 4 个数，顺序是 `xyzw`。
/// r186: `QuaternionKeyframeTrack` https://github.com/mrdoob/three.js/blob/r186/src/animation/tracks/QuaternionKeyframeTrack.js#L9
pub fn KeyframeTrack::quaternion(
  name : String,
  times : Array[Double],
  values : Array[Double],
) -> KeyframeTrack {
  check_track(times, values, 4)
  {
    name,
    times,
    values,
    value_size: 4,
    interpolation: Linear,
    cubic_spline: false,
  }
}

///|
/// 标量序列。glTF 的 `weights` 每个关键帧有一份形变权重，`value_size` 是目标个数。
/// r186: `NumberKeyframeTrack` https://github.com/mrdoob/three.js/blob/r186/src/animation/tracks/NumberKeyframeTrack.js#L8
pub fn KeyframeTrack::numbers(
  name : String,
  times : Array[Double],
  values : Array[Double],
  value_size : Int,
) -> KeyframeTrack {
  check_track(times, values, value_size)
  {
    name,
    times,
    values,
    value_size,
    interpolation: Linear,
    cubic_spline: false,
  }
}

///|
/// glTF `CUBICSPLINE` 标量序列。每个关键帧是切入切线、顶点、切出切线，各 `value_size` 个数。
/// r186: `GLTFCubicSplineInterpolant` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L2128
pub fn KeyframeTrack::cubic_numbers(
  name : String,
  times : Array[Double],
  values : Array[Double],
  value_size : Int,
) -> KeyframeTrack {
  check_cubic(times, values, value_size)
  {
    name,
    times,
    values,
    value_size,
    interpolation: Linear,
    cubic_spline: true,
  }
}

///|
/// glTF `CUBICSPLINE` 向量轨道。每个关键帧 9 个数：切入切线、顶点、切出切线。
/// r186: `GLTFCubicSplineInterpolant` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L2128
pub fn KeyframeTrack::cubic_vector(
  name : String,
  times : Array[Double],
  values : Array[Double],
) -> KeyframeTrack {
  check_cubic(times, values, 3)
  {
    name,
    times,
    values,
    value_size: 3,
    interpolation: Linear,
    cubic_spline: true,
  }
}

///|
/// glTF `CUBICSPLINE` 四元数轨道。每个关键帧 12 个数，采样后归一化。
/// r186: `GLTFCubicSplineQuaternionInterpolant` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L2200
pub fn KeyframeTrack::cubic_quaternion(
  name : String,
  times : Array[Double],
  values : Array[Double],
) -> KeyframeTrack {
  check_cubic(times, values, 4)
  {
    name,
    times,
    values,
    value_size: 4,
    interpolation: Linear,
    cubic_spline: true,
  }
}

