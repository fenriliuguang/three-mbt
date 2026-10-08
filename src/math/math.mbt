///|
/// 角度转弧度。对齐 r186 `DEG2RAD`。
pub fn deg_to_rad(degrees : Double) -> Double {
  degrees * @std.PI / 180.0
}

///|
/// 弧度转角度。对齐 r186 `RAD2DEG`。
pub fn rad_to_deg(radians : Double) -> Double {
  radians * 180.0 / @std.PI
}

///|
/// sRGB 分量转线性。对齐 r186 `SRGBToLinear`。
pub fn srgb_to_linear(c : Double) -> Double {
  if c < 0.04045 {
    c * 0.0773993808
  } else {
    @std.pow(c * 0.9478672986 + 0.0521327014, 2.4)
  }
}

///|
/// 线性分量转 sRGB。对齐 r186 `LinearToSRGB`。
pub fn linear_to_srgb(c : Double) -> Double {
  if c < 0.0031308 {
    c * 12.92
  } else {
    1.055 * @std.pow(c, 0.41666) - 0.055
  }
}
