// r186: `VSMShadowFilter` https://github.com/mrdoob/three.js/blob/r186/src/nodes/lighting/ShadowFilterNode.js#L93 ; `VSMPassVertical` https://github.com/mrdoob/three.js/blob/r186/src/nodes/lighting/ShadowNode.js#L37 ; `VSMPassHorizontal` https://github.com/mrdoob/three.js/blob/r186/src/nodes/lighting/ShadowNode.js#L84

///|
/// 模糊循环的上限。WGSL 用固定次数展开，超出的样本丢掉。
pub let vsm_sample_limit : Int32 = 64

///|
/// 一次 VSM 模糊得到的均值和标准差。
pub(all) struct VsmMoment {
  mean : Double
  std_dev : Double
}

///|
fn vsm_count(samples : Int32) -> Int32 {
  if samples < 1 {
    1
  } else if samples > vsm_sample_limit {
    vsm_sample_limit
  } else {
    samples
  }
}

///|
fn vsm_offsets(samples : Int32) -> Array[Double] {
  let count = vsm_count(samples)
  let offsets : Array[Double] = []
  if count <= 1 {
    offsets.push(0.0)
    return offsets
  }
  let stride = 2.0 / (count.to_double() - 1.0)
  let mut index = 0
  while index < count {
    offsets.push(-1.0 + index.to_double() * stride)
    index = index + 1
  }
  offsets
}

///|
fn clamp_index(value : Int32, limit : Int32) -> Int32 {
  if value < 0 {
    0
  } else if value >= limit {
    limit - 1
  } else {
    value
  }
}

///|
fn nearest_index(uv : Double, limit : Int32) -> Int32 {
  let pixel = (uv * limit.to_double() - 0.5).floor().to_int()
  clamp_index(pixel, limit)
}

///|
/// 沿一个轴做 VSM 模糊。`horizontal` 为假时 `values` 是深度，`std_devs` 不读。
/// 为真时 `values` 是均值，第二矩是标准差的平方加均值的平方。
/// 像素坐标用中心点。半径为 0 时每个样本都落在当前像素。
/// r186: `VSMPassVertical` https://github.com/mrdoob/three.js/blob/r186/src/nodes/lighting/ShadowNode.js#L37 ; `VSMPassHorizontal` https://github.com/mrdoob/three.js/blob/r186/src/nodes/lighting/ShadowNode.js#L84
pub fn vsm_axis_moment(
  values : Array[Double],
  std_devs : Array[Double],
  width : Int32,
  height : Int32,
  x : Int32,
  y : Int32,
  samples : Int32,
  radius : Double,
  horizontal : Bool,
) -> VsmMoment {
  let safe_width = if width < 1 { 1 } else { width }
  let safe_height = if height < 1 { 1 } else { height }
  let offsets = vsm_offsets(samples)
  let mut mean = 0.0
  let mut squared = 0.0
  for offset in offsets {
    let mut sample_x = x.to_double() + 0.5
    let mut sample_y = y.to_double() + 0.5
    if horizontal {
      sample_x = sample_x + offset * radius
    } else {
      sample_y = sample_y + offset * radius
    }
    let ix = nearest_index(sample_x / safe_width.to_double(), safe_width)
    let iy = nearest_index(sample_y / safe_height.to_double(), safe_height)
    let index = iy * safe_width + ix
    let sample = if index >= 0 && index < values.length() {
      values[index]
    } else {
      0.0
    }
    mean = mean + sample
    if horizontal {
      let spread = if index >= 0 && index < std_devs.length() {
        std_devs[index]
      } else {
        0.0
      }
      squared = squared + spread * spread + sample * sample
    } else {
      squared = squared + sample * sample
    }
  }
  let count = offsets.length().to_double()
  mean = mean / count
  squared = squared / count
  let variance = squared - mean * mean
  let std_dev = if variance > 0.0 { variance.sqrt() } else { 0.0 }
  { mean, std_dev, }
}

///|
/// Chebyshev 上界。硬阴影为 1 时直接返回 1。否则用方差把 `[0.3, 0.95]` 拉开。
/// `reversed` 为真时，深度大于等于均值算照亮。
/// r186: `VSMShadowFilter` https://github.com/mrdoob/three.js/blob/r186/src/nodes/lighting/ShadowFilterNode.js#L93
pub fn vsm_shadow(
  mean : Double,
  std_dev : Double,
  depth : Double,
  reversed : Bool,
) -> Double {
  let variance = 0.0000001.max(std_dev * std_dev)
  let hard = if reversed {
    if mean <= depth {
      1.0
    } else {
      0.0
    }
  } else if depth <= mean {
    1.0
  } else {
    0.0
  }
  if hard >= 1.0 {
    return 1.0
  }
  let delta = depth - mean
  let p_max = variance / (variance + delta * delta)
  let remapped = (p_max - 0.3) / 0.65
  let clamped = if remapped < 0.0 {
    0.0
  } else if remapped > 1.0 {
    1.0
  } else {
    remapped
  }
  if hard > clamped {
    hard
  } else {
    clamped
  }
}

///|
/// 阴影 uniform 的 `z`。不接收是 0。比较采样是 1。VSM 是 2，反向深度的 VSM 是 3。
pub fn shadow_enabled_value(
  receive : Bool,
  vsm : Bool,
  reversed : Bool,
) -> Double {
  if !receive {
    0.0
  } else if vsm && reversed {
    3.0
  } else if vsm {
    2.0
  } else {
    1.0
  }
}

///|
/// VSM 时接收者也投射。其它类型只看 `cast_shadow`。
/// r186: shadow receiver casts https://github.com/mrdoob/three.js/blob/r186/src/nodes/lighting/ShadowBaseNode.js#L90
pub fn casts_vsm_shadow(
  cast_shadow : Bool,
  receive_shadow : Bool,
  vsm : Bool,
) -> Bool {
  cast_shadow || (vsm && receive_shadow)
}
