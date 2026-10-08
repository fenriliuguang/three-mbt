///|
/// 线性工作空间里的 RGB 颜色，通道范围通常是 \[0, 1\]。
/// `set_hex` 把 sRGB 十六进制转成线性，与 r186 默认的 `ColorManagement` 一致。
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
pub fn Color::lerp(self : Color, color : Color, alpha : Double) -> Color {
  self.r += (color.r - self.r) * alpha
  self.g += (color.g - self.g) * alpha
  self.b += (color.b - self.b) * alpha
  self
}
