// r186: `Color` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L88

///|
/// 线性工作空间里的 RGB 颜色，通道范围通常是 \[0, 1\]。
/// `set_hex` 把 sRGB 十六进制转成线性，与 r186 默认的 `ColorManagement` 一致。
/// r186: `Color` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L88
pub(all) struct Color {
  mut r : Double
  mut g : Double
  mut b : Double
}

///|
pub fn Color::new(
  r? : Double = 1.0,
  g? : Double = 1.0,
  b? : Double = 1.0,
) -> Color {
  { r, g, b, }
}

///|
/// r186: `setRGB` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L58
pub fn Color::set_rgb(
  self : Color,
  r : Double,
  g : Double,
  b : Double,
) -> Color {
  self.r = r
  self.g = g
  self.b = b
  self
}

///|
/// 写入三个线性通道。
/// r186: `set` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L149
pub fn Color::set(self : Color, r : Double, g : Double, b : Double) -> Color {
  self.set_rgb(r, g, b)
}

///|
/// 三个通道都写成同一个值。
/// r186: `setScalar` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L187
pub fn Color::set_scalar(self : Color, scalar : Double) -> Color {
  self.r = scalar
  self.g = scalar
  self.b = scalar
  self
}

///|
/// 色相转成一个线性通道。
/// r186: `hue2rgb` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L34
fn hue2rgb(p : Double, q : Double, t : Double) -> Double {
  let t = if t < 0.0 {
    t + 1.0
  } else if t > 1.0 {
    t - 1.0
  } else {
    t
  }
  if t < 1.0 / 6.0 {
    p + (q - p) * 6.0 * t
  } else if t < 0.5 {
    q
  } else if t < 2.0 / 3.0 {
    p + (q - p) * 6.0 * (2.0 / 3.0 - t)
  } else {
    p
  }
}

///|
/// 用色相、饱和度、亮度写入线性通道。默认工作空间已是线性，不再做色彩空间转换。
/// r186: `setHSL` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L248
pub fn Color::set_hsl(self : Color, h : Double, s : Double, l : Double) -> Color {
  let h = euclidean_modulo(h, 1.0)
  let s = clamp(s, 0.0, 1.0)
  let l = clamp(l, 0.0, 1.0)
  if s == 0.0 {
    self.r = l
    self.g = l
    self.b = l
  } else {
    let p = if l <= 0.5 { l * (1.0 + s) } else { l + s - l * s }
    let q = 2.0 * l - p
    self.r = hue2rgb(q, p, h + 1.0 / 3.0)
    self.g = hue2rgb(q, p, h)
    self.b = hue2rgb(q, p, h - 1.0 / 3.0)
  }
  self
}

///|
/// 复制颜色，并把每个 sRGB 通道转成线性。
/// r186: `copySRGBToLinear` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L480
pub fn Color::copy_srgb_to_linear(self : Color, color : Color) -> Color {
  self.r = srgb_to_linear(color.r)
  self.g = srgb_to_linear(color.g)
  self.b = srgb_to_linear(color.b)
  self
}

///|
/// 复制颜色，并把每个线性通道转成 sRGB。
/// r186: `copyLinearToSRGB` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L497
pub fn Color::copy_linear_to_srgb(self : Color, color : Color) -> Color {
  self.r = linear_to_srgb(color.r)
  self.g = linear_to_srgb(color.g)
  self.b = linear_to_srgb(color.b)
  self
}

///|
/// 把自身的 sRGB 通道转成线性。
/// r186: `convertSRGBToLinear` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L512
pub fn Color::convert_srgb_to_linear(self : Color) -> Color {
  self.copy_srgb_to_linear(self)
}

///|
/// 把自身的线性通道转成 sRGB。
/// r186: `convertLinearToSRGB` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L525
pub fn Color::convert_linear_to_srgb(self : Color) -> Color {
  self.copy_linear_to_srgb(self)
}

///|
/// r186: `setHex` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L163
pub fn Color::set_hex(self : Color, hex : Int) -> Color {
  let hex = hex.to_double().floor().to_int()
  self.r = srgb_to_linear(((hex >> 16) & 255).to_double() / 255.0)
  self.g = srgb_to_linear(((hex >> 8) & 255).to_double() / 255.0)
  self.b = srgb_to_linear((hex & 255).to_double() / 255.0)
  self
}

///|
pub fn Color::copy(self : Color, color : Color) -> Color {
  self.r = color.r
  self.g = color.g
  self.b = color.b
  self
}

///|
pub fn Color::clone(self : Color) -> Color {
  Color::new(r=self.r, g=self.g, b=self.b)
}

///|
pub fn Color::get_hex(self : Color) -> Int {
  let r = linear_to_srgb(self.r).clamp(min=0.0, max=1.0) * 255.0
  let g = linear_to_srgb(self.g).clamp(min=0.0, max=1.0) * 255.0
  let b = linear_to_srgb(self.b).clamp(min=0.0, max=1.0) * 255.0
  r.round().to_int() * 65536 + g.round().to_int() * 256 + b.round().to_int()
}

///|
/// 把颜色写成六位小写十六进制字符串。
/// r186: `getHexString` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L553
pub fn Color::get_hex_string(self : Color) -> String {
  self.get_hex().to_string(radix=16).pad_start(6, '0')
}

///|
/// 读出色相、饱和度、亮度。通道已在线性工作空间。
/// r186: `getHSL` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L567
pub fn Color::get_hsl(self : Color) -> (Double, Double, Double) {
  let r = self.r
  let g = self.g
  let b = self.b
  let max = r.max(g).max(b)
  let min = r.min(g).min(b)
  let lightness = (min + max) / 2.0
  if min == max {
    (0.0, 0.0, lightness)
  } else {
    let delta = max - min
    let saturation = if lightness <= 0.5 {
      delta / (max + min)
    } else {
      delta / (2.0 - max - min)
    }
    let hue = if max == r {
      (g - b) / delta + (if g < b { 6.0 } else { 0.0 })
    } else if max == g {
      (b - r) / delta + 2.0
    } else {
      (r - g) / delta + 4.0
    }
    (hue / 6.0, saturation, lightness)
  }
}

///|
/// 把线性通道写入目标颜色。
/// r186: `getRGB` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L619
pub fn Color::get_rgb(self : Color, target : Color) -> Color {
  target.r = self.r
  target.g = self.g
  target.b = self.b
  target
}

///|
pub fn Color::lerp(self : Color, color : Color, alpha : Double) -> Color {
  self.r += (color.r - self.r) * alpha
  self.g += (color.g - self.g) * alpha
  self.b += (color.b - self.b) * alpha
  self
}
