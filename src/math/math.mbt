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

///|
/// 两端一阶、二阶导数都为零的平滑插值。低于 `min` 是 0，高于 `max` 是 1。
/// r186: `smootherstep` https://github.com/mrdoob/three.js/blob/r186/src/math/MathUtils.js#L187
pub fn smootherstep(x : Double, min : Double, max : Double) -> Double {
  if x <= min {
    0.0
  } else if x >= max {
    1.0
  } else {
    let t = (x - min) / (max - min)
    t * t * t * (t * (t * 6.0 - 15.0) + 10.0)
  }
}

///|
/// 在闭区间里取一个随机整数。两端相同就返回那个数。
/// r186: `randInt` https://github.com/mrdoob/three.js/blob/r186/src/math/MathUtils.js#L205
pub fn rand_int(low : Double, high : Double) -> Double {
  let rng = @random.Rand::Rand()
  low + @std.floor(rng.double() * (high - low + 1.0))
}

///|
/// 在半开区间 `[low, high)` 里取一个随机数。两端相同就返回那个数。
/// r186: `randFloat` https://github.com/mrdoob/three.js/blob/r186/src/math/MathUtils.js#L218
pub fn rand_float(low : Double, high : Double) -> Double {
  let rng = @random.Rand::Rand()
  low + rng.double() * (high - low)
}

///|
/// 在以 0 为中心、宽度为 `range` 的区间里取一个随机数。`range` 为 0 时返回 0。
/// r186: `randFloatSpread` https://github.com/mrdoob/three.js/blob/r186/src/math/MathUtils.js#L230
pub fn rand_float_spread(range : Double) -> Double {
  let rng = @random.Rand::Rand()
  range * (0.5 - rng.double())
}

///|
let mulberry_seed : Ref[UInt] = Ref::Ref(1234567U)

///|
/// 用 Mulberry32 生成 `[0, 1)` 里的确定性随机数。传入种子会重置序列。
/// r186: `seededRandom` https://github.com/mrdoob/three.js/blob/r186/src/math/MathUtils.js#L242
pub fn seeded_random(s? : Int) -> Double {
  match s {
    Some(value) => mulberry_seed.val = value.reinterpret_as_uint()
    None => ()
  }
  mulberry_seed.val = mulberry_seed.val + 0x6D2B79F5U
  let mut t = mulberry_seed.val
  t = (t ^ (t >> 15)) * (t | 1U)
  t = t ^ (t + ((t ^ (t >> 7)) * (t | 61U)))
  (t ^ (t >> 14)).to_double() / 4294967296.0
}

///|
/// 正整数且恰好是 2 的幂才返回 true。
/// r186: `isPowerOfTwo` https://github.com/mrdoob/three.js/blob/r186/src/math/MathUtils.js#L288
pub fn is_power_of_two(value : Double) -> Bool {
  if value <= 0.0 || value.is_nan() || value.is_inf() || value != value.floor() {
    false
  } else {
    @std.pow(2.0, @std.log2(value).round()) == value
  }
}

///|
/// 不小于给定数的最小 2 的幂。
/// r186: `ceilPowerOfTwo` https://github.com/mrdoob/three.js/blob/r186/src/math/MathUtils.js#L300
pub fn ceil_power_of_two(value : Double) -> Double {
  @std.pow(2.0, @std.log2(value).ceil())
}

///|
/// 不大于给定数的最大 2 的幂。
/// r186: `floorPowerOfTwo` https://github.com/mrdoob/three.js/blob/r186/src/math/MathUtils.js#L312
pub fn floor_power_of_two(value : Double) -> Double {
  @std.pow(2.0, @std.log2(value).floor())
}

///|
/// 内禀正常欧拉角的轴序。
pub(all) enum ProperEulerOrder {
  XYX
  YZY
  ZXZ
  XZX
  YXY
  ZYZ
}

///|
/// 用内禀正常欧拉角写入四元数，并通知。
/// r186: `setQuaternionFromProperEuler` https://github.com/mrdoob/three.js/blob/r186/src/math/MathUtils.js#L331
pub fn set_quaternion_from_proper_euler(
  q : Quaternion,
  a : Double,
  b : Double,
  c : Double,
  order : ProperEulerOrder,
) -> Unit {
  let c2 = @std.cos(b / 2.0)
  let s2 = @std.sin(b / 2.0)
  let c13 = @std.cos((a + c) / 2.0)
  let s13 = @std.sin((a + c) / 2.0)
  let c1_3 = @std.cos((a - c) / 2.0)
  let s1_3 = @std.sin((a - c) / 2.0)
  let c3_1 = @std.cos((c - a) / 2.0)
  let s3_1 = @std.sin((c - a) / 2.0)
  match order {
    XYX => ignore(q.set(c2 * s13, s2 * c1_3, s2 * s1_3, c2 * c13))
    YZY => ignore(q.set(s2 * s1_3, c2 * s13, s2 * c1_3, c2 * c13))
    ZXZ => ignore(q.set(s2 * c1_3, s2 * s1_3, c2 * s13, c2 * c13))
    XZX => ignore(q.set(c2 * s13, s2 * s3_1, s2 * c3_1, c2 * c13))
    YXY => ignore(q.set(s2 * c3_1, c2 * s13, s2 * s3_1, c2 * c13))
    ZYZ => ignore(q.set(s2 * s3_1, s2 * c3_1, c2 * s13, c2 * c13))
  }
}

///|
/// 数值分量的存储类型。上游用类型化数组的构造函数区分，这里没有类型化数组。
pub(all) enum ArrayComponentType {
  Float32
  Uint32
  Uint16
  Uint8
  Uint8Clamped
  Int32
  Int16
  Int8
}

///|
/// 按分量类型把整数范围展开到 `[0, 1]` 或 `[-1, 1]`。
/// r186: `denormalize` https://github.com/mrdoob/three.js/blob/r186/src/math/MathUtils.js#L388
pub fn denormalize(value : Double, component : ArrayComponentType) -> Double {
  match component {
    Float32 => value
    Uint32 => value / 4294967295.0
    Uint16 => value / 65535.0
    Uint8 | Uint8Clamped => value / 255.0
    Int32 => (value / 2147483647.0).max(-1.0)
    Int16 => (value / 32767.0).max(-1.0)
    Int8 => (value / 127.0).max(-1.0)
  }
}

///|
/// 按分量类型把 `[0, 1]` 或 `[-1, 1]` 收成整数范围。
/// r186: `normalize` https://github.com/mrdoob/three.js/blob/r186/src/math/MathUtils.js#L436
pub fn normalize(value : Double, component : ArrayComponentType) -> Double {
  match component {
    Float32 => value
    Uint32 => (value * 4294967295.0).round()
    Uint16 => (value * 65535.0).round()
    Uint8 | Uint8Clamped => (value * 255.0).round()
    Int32 => (value * 2147483647.0).round()
    Int16 => (value * 32767.0).round()
    Int8 => (value * 127.0).round()
  }
}
