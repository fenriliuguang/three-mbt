// r186: `DEG2RAD` https://github.com/mrdoob/three.js/blob/r186/src/math/MathUtils.js#L8 ; `SRGBToLinear` https://github.com/mrdoob/three.js/blob/r186/src/math/ColorManagement.js#L205

///|
/// 角度转弧度。对齐 r186 `DEG2RAD`。
/// r186: `degToRad` https://github.com/mrdoob/three.js/blob/r186/src/math/MathUtils.js#L264
pub fn deg_to_rad(degrees : Double) -> Double {
  degrees * @std.PI / 180.0
}

///|
/// 弧度转角度。对齐 r186 `RAD2DEG`。
/// r186: `radToDeg` https://github.com/mrdoob/three.js/blob/r186/src/math/MathUtils.js#L276
pub fn rad_to_deg(radians : Double) -> Double {
  radians * 180.0 / @std.PI
}

///|
/// sRGB 分量转线性。对齐 r186 `SRGBToLinear`。
/// r186: `SRGBToLinear` https://github.com/mrdoob/three.js/blob/r186/src/math/ColorManagement.js#L205
pub fn srgb_to_linear(c : Double) -> Double {
  if c < 0.04045 {
    c * 0.0773993808
  } else {
    @std.pow(c * 0.9478672986 + 0.0521327014, 2.4)
  }
}

///|
/// 线性分量转 sRGB。对齐 r186 `LinearToSRGB`。
/// r186: `LinearToSRGB` https://github.com/mrdoob/three.js/blob/r186/src/math/ColorManagement.js#L211
pub fn linear_to_srgb(c : Double) -> Double {
  if c < 0.0031308 {
    c * 12.92
  } else {
    1.055 * @std.pow(c, 0.41666) - 0.055
  }
}

///|
/// 把数值限制在闭区间里。
/// r186: `clamp` https://github.com/mrdoob/three.js/blob/r186/src/math/MathUtils.js#L43
pub fn clamp(value : Double, min : Double, max : Double) -> Double {
  max.min(value).max(min)
}

///|
/// 欧几里得取模，结果与除数同号。
/// r186: `euclideanModulo` https://github.com/mrdoob/three.js/blob/r186/src/math/MathUtils.js#L57
pub fn euclidean_modulo(n : Double, m : Double) -> Double {
  ((n % m) + m) % m
}

///|
/// 在两个数之间线性插值。
/// r186: `lerp` https://github.com/mrdoob/three.js/blob/r186/src/math/MathUtils.js#L116
pub fn lerp(x : Double, y : Double, t : Double) -> Double {
  (1.0 - t) * x + t * y
}

///|
/// 把一个区间上的数线性映射到另一个区间。
/// r186: `mapLinear` https://github.com/mrdoob/three.js/blob/r186/src/math/MathUtils.js#L76
pub fn map_linear(
  x : Double,
  a1 : Double,
  a2 : Double,
  b1 : Double,
  b2 : Double,
) -> Double {
  b1 + (x - a1) * (b2 - b1) / (a2 - a1)
}

///|
/// 求一个数在区间里的位置。两端相同返回 0。
/// r186: `inverseLerp` https://github.com/mrdoob/three.js/blob/r186/src/math/MathUtils.js#L91
pub fn inverse_lerp(x : Double, y : Double, value : Double) -> Double {
  if x != y {
    (value - x) / (y - x)
  } else {
    0.0
  }
}

///|
/// 按指数衰减靠近目标。`lambda` 或 `dt` 为 0 时停在当前值。
/// r186: `damp` https://github.com/mrdoob/three.js/blob/r186/src/math/MathUtils.js#L134
pub fn damp(x : Double, y : Double, lambda : Double, dt : Double) -> Double {
  lerp(x, y, 1.0 - @std.exp(-lambda * dt))
}

///|
/// 在 `0` 和 `length` 之间来回折返。`length` 默认是 1。
/// r186: `pingpong` https://github.com/mrdoob/three.js/blob/r186/src/math/MathUtils.js#L147
pub fn pingpong(x : Double, length? : Double = 1.0) -> Double {
  length - (euclidean_modulo(x, length * 2.0) - length).abs()
}

///|
/// 在两端放慢的平滑插值。低于 `min` 是 0，高于 `max` 是 1。
/// r186: `smoothstep` https://github.com/mrdoob/three.js/blob/r186/src/math/MathUtils.js#L167
pub fn smoothstep(x : Double, min : Double, max : Double) -> Double {
  if x <= min {
    0.0
  } else if x >= max {
    1.0
  } else {
    let t = (x - min) / (max - min)
    t * t * (3.0 - 2.0 * t)
  }
}
