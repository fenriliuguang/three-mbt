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
  r~ : Double = 1.0,
  g~ : Double = 1.0,
  b~ : Double = 1.0,
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
  let t = if t < 0.0 { t + 1.0 } else if t > 1.0 { t - 1.0 } else { t }
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
pub fn Color::set_hsl(
  self : Color,
  h : Double,
  s : Double,
  l : Double,
) -> Color {
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
pub fn Color::set_hex(self : Color, hex : Int32) -> Color {
  let hex = hex.to_double().floor().to_int()
  self.r = srgb_to_linear(((hex >> 16) & 255).to_double() / 255.0)
  self.g = srgb_to_linear(((hex >> 8) & 255).to_double() / 255.0)
  self.b = srgb_to_linear((hex & 255).to_double() / 255.0)
  self
}

///|
/// X11 颜色名。未知名字不改颜色。
/// r186: `setColorName` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L425
pub fn Color::set_color_name(self : Color, style : String) -> Color {
  match color_keyword(style.to_lower()) {
    Some(hex) => self.set_hex(hex)
    None => self
  }
}

///|
fn color_keyword(name : String) -> Int32? {
  match name {
    "aliceblue" => Some(0xF0F8FF)
    "antiquewhite" => Some(0xFAEBD7)
    "aqua" => Some(0x00FFFF)
    "aquamarine" => Some(0x7FFFD4)
    "azure" => Some(0xF0FFFF)
    "beige" => Some(0xF5F5DC)
    "bisque" => Some(0xFFE4C4)
    "black" => Some(0x000000)
    "blanchedalmond" => Some(0xFFEBCD)
    "blue" => Some(0x0000FF)
    "blueviolet" => Some(0x8A2BE2)
    "brown" => Some(0xA52A2A)
    "burlywood" => Some(0xDEB887)
    "cadetblue" => Some(0x5F9EA0)
    "chartreuse" => Some(0x7FFF00)
    "chocolate" => Some(0xD2691E)
    "coral" => Some(0xFF7F50)
    "cornflowerblue" => Some(0x6495ED)
    "cornsilk" => Some(0xFFF8DC)
    "crimson" => Some(0xDC143C)
    "cyan" => Some(0x00FFFF)
    "darkblue" => Some(0x00008B)
    "darkcyan" => Some(0x008B8B)
    "darkgoldenrod" => Some(0xB8860B)
    "darkgray" => Some(0xA9A9A9)
    "darkgreen" => Some(0x006400)
    "darkgrey" => Some(0xA9A9A9)
    "darkkhaki" => Some(0xBDB76B)
    "darkmagenta" => Some(0x8B008B)
    "darkolivegreen" => Some(0x556B2F)
    "darkorange" => Some(0xFF8C00)
    "darkorchid" => Some(0x9932CC)
    "darkred" => Some(0x8B0000)
    "darksalmon" => Some(0xE9967A)
    "darkseagreen" => Some(0x8FBC8F)
    "darkslateblue" => Some(0x483D8B)
    "darkslategray" => Some(0x2F4F4F)
    "darkslategrey" => Some(0x2F4F4F)
    "darkturquoise" => Some(0x00CED1)
    "darkviolet" => Some(0x9400D3)
    "deeppink" => Some(0xFF1493)
    "deepskyblue" => Some(0x00BFFF)
    "dimgray" => Some(0x696969)
    "dimgrey" => Some(0x696969)
    "dodgerblue" => Some(0x1E90FF)
    "firebrick" => Some(0xB22222)
    "floralwhite" => Some(0xFFFAF0)
    "forestgreen" => Some(0x228B22)
    "fuchsia" => Some(0xFF00FF)
    "gainsboro" => Some(0xDCDCDC)
    "ghostwhite" => Some(0xF8F8FF)
    "gold" => Some(0xFFD700)
    "goldenrod" => Some(0xDAA520)
    "gray" => Some(0x808080)
    "green" => Some(0x008000)
    "greenyellow" => Some(0xADFF2F)
    "grey" => Some(0x808080)
    "honeydew" => Some(0xF0FFF0)
    "hotpink" => Some(0xFF69B4)
    "indianred" => Some(0xCD5C5C)
    "indigo" => Some(0x4B0082)
    "ivory" => Some(0xFFFFF0)
    "khaki" => Some(0xF0E68C)
    "lavender" => Some(0xE6E6FA)
    "lavenderblush" => Some(0xFFF0F5)
    "lawngreen" => Some(0x7CFC00)
    "lemonchiffon" => Some(0xFFFACD)
    "lightblue" => Some(0xADD8E6)
    "lightcoral" => Some(0xF08080)
    "lightcyan" => Some(0xE0FFFF)
    "lightgoldenrodyellow" => Some(0xFAFAD2)
    "lightgray" => Some(0xD3D3D3)
    "lightgreen" => Some(0x90EE90)
    "lightgrey" => Some(0xD3D3D3)
    "lightpink" => Some(0xFFB6C1)
    "lightsalmon" => Some(0xFFA07A)
    "lightseagreen" => Some(0x20B2AA)
    "lightskyblue" => Some(0x87CEFA)
    "lightslategray" => Some(0x778899)
    "lightslategrey" => Some(0x778899)
    "lightsteelblue" => Some(0xB0C4DE)
    "lightyellow" => Some(0xFFFFE0)
    "lime" => Some(0x00FF00)
    "limegreen" => Some(0x32CD32)
    "linen" => Some(0xFAF0E6)
    "magenta" => Some(0xFF00FF)
    "maroon" => Some(0x800000)
    "mediumaquamarine" => Some(0x66CDAA)
    "mediumblue" => Some(0x0000CD)
    "mediumorchid" => Some(0xBA55D3)
    "mediumpurple" => Some(0x9370DB)
    "mediumseagreen" => Some(0x3CB371)
    "mediumslateblue" => Some(0x7B68EE)
    "mediumspringgreen" => Some(0x00FA9A)
    "mediumturquoise" => Some(0x48D1CC)
    "mediumvioletred" => Some(0xC71585)
    "midnightblue" => Some(0x191970)
    "mintcream" => Some(0xF5FFFA)
    "mistyrose" => Some(0xFFE4E1)
    "moccasin" => Some(0xFFE4B5)
    "navajowhite" => Some(0xFFDEAD)
    "navy" => Some(0x000080)
    "oldlace" => Some(0xFDF5E6)
    "olive" => Some(0x808000)
    "olivedrab" => Some(0x6B8E23)
    "orange" => Some(0xFFA500)
    "orangered" => Some(0xFF4500)
    "orchid" => Some(0xDA70D6)
    "palegoldenrod" => Some(0xEEE8AA)
    "palegreen" => Some(0x98FB98)
    "paleturquoise" => Some(0xAFEEEE)
    "palevioletred" => Some(0xDB7093)
    "papayawhip" => Some(0xFFEFD5)
    "peachpuff" => Some(0xFFDAB9)
    "peru" => Some(0xCD853F)
    "pink" => Some(0xFFC0CB)
    "plum" => Some(0xDDA0DD)
    "powderblue" => Some(0xB0E0E6)
    "purple" => Some(0x800080)
    "rebeccapurple" => Some(0x663399)
    "red" => Some(0xFF0000)
    "rosybrown" => Some(0xBC8F8F)
    "royalblue" => Some(0x4169E1)
    "saddlebrown" => Some(0x8B4513)
    "salmon" => Some(0xFA8072)
    "sandybrown" => Some(0xF4A460)
    "seagreen" => Some(0x2E8B57)
    "seashell" => Some(0xFFF5EE)
    "sienna" => Some(0xA0522D)
    "silver" => Some(0xC0C0C0)
    "skyblue" => Some(0x87CEEB)
    "slateblue" => Some(0x6A5ACD)
    "slategray" => Some(0x708090)
    "slategrey" => Some(0x708090)
    "snow" => Some(0xFFFAFA)
    "springgreen" => Some(0x00FF7F)
    "steelblue" => Some(0x4682B4)
    "tan" => Some(0xD2B48C)
    "teal" => Some(0x008080)
    "thistle" => Some(0xD8BFD8)
    "tomato" => Some(0xFF6347)
    "turquoise" => Some(0x40E0D0)
    "violet" => Some(0xEE82EE)
    "wheat" => Some(0xF5DEB3)
    "white" => Some(0xFFFFFF)
    "whitesmoke" => Some(0xF5F5F5)
    "yellow" => Some(0xFFFF00)
    "yellowgreen" => Some(0x9ACD32)
    _ => None
  }
}

///|
/// 从 CSS 字符串写颜色。`rgb`、`#hex` 和颜色名按 sRGB 转成线性。透明度忽略。
/// r186: `setStyle` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L286
pub fn Color::set_style(self : Color, style : String) -> Color {
  match css_color_function(style) {
    Some((name, components)) =>
      if name == "rgb" || name == "rgba" {
        match rgb_channels(components) {
          Some((r, g, b)) => self.set_rgb(r, g, b).convert_srgb_to_linear()
          None => self
        }
      } else if name == "hsl" || name == "hsla" {
        match hsl_channels(components) {
          Some((h, s, l)) => self.set_hsl(h, s, l).convert_srgb_to_linear()
          None => self
        }
      } else {
        self
      }
    None =>
      match css_hex_digits(style) {
        Some(hex) =>
          if hex.length() == 3 {
            self
            .set_rgb(
              hex_nibble_at(hex, 0) / 15.0,
              hex_nibble_at(hex, 1) / 15.0,
              hex_nibble_at(hex, 2) / 15.0,
            )
            .convert_srgb_to_linear()
          } else if hex.length() == 6 {
            self.set_hex(hex_int(hex))
          } else {
            self
          }
        None =>
          if style.length() > 0 {
            self.set_color_name(style)
          } else {
            self
          }
      }
  }
}

///|
fn is_css_word(c : Char) -> Bool {
  c.is_ascii_alphabetic() || c.is_ascii_digit() || c == '_'
}

///|
fn css_color_function(style : String) -> (String, String)? {
  let n = style.length()
  let mut i = 0
  while i < n {
    match style.get_char(i) {
      Some(c) => if is_css_word(c) { i = i + 1 } else { break }
      None => break
    }
  }
  if i == 0 {
    return None
  }
  let opened = match style.get_char(i) {
    Some('(') => true
    _ => false
  }
  if !opened {
    return None
  }
  let mut j = i + 1
  let mut closed = false
  while j < n {
    match style.get_char(j) {
      Some(')') => {
        closed = true
        break
      }
      Some(_) => j = j + 1
      None => break
    }
  }
  if !closed {
    return None
  }
  Some((style[0:i].to_owned(), style[i + 1:j].to_owned()))
}

///|
fn css_hex_digits(style : String) -> String? {
  let n = style.length()
  if n < 2 {
    return None
  }
  let hashed = match style.get_char(0) {
    Some('#') => true
    _ => false
  }
  if !hashed {
    return None
  }
  let mut i = 1
  while i < n {
    match style.get_char(i) {
      Some(c) => if c.is_ascii_hexdigit() { i = i + 1 } else { return None }
      None => return None
    }
  }
  Some(style[1:i].to_owned())
}

///|
fn skip_css_space(text : String, index : Int32) -> Int32 {
  let mut index = index
  let n = text.length()
  while index < n {
    match text.get_char(index) {
      Some(c) => if c.is_ascii_whitespace() { index = index + 1 } else { break }
      None => break
    }
  }
  index
}

///|
fn take_css_char(text : String, index : Int32, expect : Char) -> Int32? {
  match text.get_char(index) {
    Some(c) => if c == expect { Some(index + 1) } else { None }
    None => None
  }
}

///|
fn take_css_digits(text : String, index : Int32) -> (Int32, Double)? {
  let starts = match text.get_char(index) {
    Some(c) => c.is_ascii_digit()
    None => false
  }
  if !starts {
    return None
  }
  let mut index = index
  let mut value = 0.0
  let n = text.length()
  while index < n {
    match text.get_char(index) {
      Some(c) =>
        if c.is_ascii_digit() {
          value = value * 10.0 + (c.to_int() - '0'.to_int()).to_double()
          index = index + 1
        } else {
          break
        }
      None => break
    }
  }
  Some((index, value))
}

///|
fn take_css_float(text : String, index : Int32) -> (Int32, Double)? {
  let mut index = index
  let mut value = 0.0
  let mut saw_digit = false
  let n = text.length()
  while index < n {
    match text.get_char(index) {
      Some(c) =>
        if c.is_ascii_digit() {
          value = value * 10.0 + (c.to_int() - '0'.to_int()).to_double()
          saw_digit = true
          index = index + 1
        } else {
          break
        }
      None => break
    }
  }
  match text.get_char(index) {
    Some('.') => {
      index = index + 1
      let mut scale = 0.1
      let mut saw_frac = false
      while index < n {
        match text.get_char(index) {
          Some(c) =>
            if c.is_ascii_digit() {
              value = value + (c.to_int() - '0'.to_int()).to_double() * scale
              scale = scale * 0.1
              saw_frac = true
              index = index + 1
            } else {
              break
            }
          None => break
        }
      }
      if saw_frac {
        Some((index, value))
      } else {
        None
      }
    }
    _ => if saw_digit { Some((index, value)) } else { None }
  }
}

///|
fn take_css_alpha(text : String, index : Int32) -> Bool {
  let index = skip_css_space(text, index)
  if index >= text.length() {
    return true
  }
  match take_css_char(text, index, ',') {
    None => false
    Some(index) => {
      let index = skip_css_space(text, index)
      match take_css_float(text, index) {
        None => false
        Some((index, _)) => {
          let index = skip_css_space(text, index)
          index == text.length()
        }
      }
    }
  }
}

///|
fn rgb_channels(components : String) -> (Double, Double, Double)? {
  match rgb_byte_channels(components) {
    Some(channels) => Some(channels)
    None => rgb_percent_channels(components)
  }
}

///|
fn rgb_byte_channels(components : String) -> (Double, Double, Double)? {
  let i0 = skip_css_space(components, 0)
  let (i1, r) = match take_css_digits(components, i0) {
    Some(pair) => pair
    None => return None
  }
  let i2 = match
    take_css_char(components, skip_css_space(components, i1), ',') {
    Some(index) => index
    None => return None
  }
  let (i3, g) = match
    take_css_digits(components, skip_css_space(components, i2)) {
    Some(pair) => pair
    None => return None
  }
  let i4 = match
    take_css_char(components, skip_css_space(components, i3), ',') {
    Some(index) => index
    None => return None
  }
  let (i5, b) = match
    take_css_digits(components, skip_css_space(components, i4)) {
    Some(pair) => pair
    None => return None
  }
  if take_css_alpha(components, i5) {
    Some((255.0.min(r) / 255.0, 255.0.min(g) / 255.0, 255.0.min(b) / 255.0))
  } else {
    None
  }
}

///|
fn rgb_percent_channels(components : String) -> (Double, Double, Double)? {
  let i0 = skip_css_space(components, 0)
  let (i1, r) = match take_css_digits(components, i0) {
    Some(pair) => pair
    None => return None
  }
  let i2 = match take_css_char(components, i1, '%') {
    Some(index) => index
    None => return None
  }
  let i3 = match
    take_css_char(components, skip_css_space(components, i2), ',') {
    Some(index) => index
    None => return None
  }
  let (i4, g) = match
    take_css_digits(components, skip_css_space(components, i3)) {
    Some(pair) => pair
    None => return None
  }
  let i5 = match take_css_char(components, i4, '%') {
    Some(index) => index
    None => return None
  }
  let i6 = match
    take_css_char(components, skip_css_space(components, i5), ',') {
    Some(index) => index
    None => return None
  }
  let (i7, b) = match
    take_css_digits(components, skip_css_space(components, i6)) {
    Some(pair) => pair
    None => return None
  }
  let i8 = match take_css_char(components, i7, '%') {
    Some(index) => index
    None => return None
  }
  if take_css_alpha(components, i8) {
    Some((100.0.min(r) / 100.0, 100.0.min(g) / 100.0, 100.0.min(b) / 100.0))
  } else {
    None
  }
}

///|
fn hsl_channels(components : String) -> (Double, Double, Double)? {
  let i0 = skip_css_space(components, 0)
  let (i1, h) = match take_css_float(components, i0) {
    Some(pair) => pair
    None => return None
  }
  let i2 = match
    take_css_char(components, skip_css_space(components, i1), ',') {
    Some(index) => index
    None => return None
  }
  let (i3, s) = match
    take_css_float(components, skip_css_space(components, i2)) {
    Some(pair) => pair
    None => return None
  }
  let i4 = match take_css_char(components, i3, '%') {
    Some(index) => index
    None => return None
  }
  let i5 = match
    take_css_char(components, skip_css_space(components, i4), ',') {
    Some(index) => index
    None => return None
  }
  let (i6, l) = match
    take_css_float(components, skip_css_space(components, i5)) {
    Some(pair) => pair
    None => return None
  }
  let i7 = match take_css_char(components, i6, '%') {
    Some(index) => index
    None => return None
  }
  if take_css_alpha(components, i7) {
    Some((h / 360.0, s / 100.0, l / 100.0))
  } else {
    None
  }
}

///|
fn hex_nibble(c : Char) -> Int32 {
  if c.is_ascii_digit() {
    c.to_int() - '0'.to_int()
  } else {
    c.to_ascii_lowercase().to_int() - 'a'.to_int() + 10
  }
}

///|
fn hex_nibble_at(hex : String, index : Int32) -> Double {
  match hex.get_char(index) {
    Some(c) => hex_nibble(c).to_double()
    None => 0.0
  }
}

///|
fn hex_int(hex : String) -> Int32 {
  let mut value = 0
  let mut index = 0
  while index < hex.length() {
    match hex.get_char(index) {
      Some(c) => {
        value = value * 16 + hex_nibble(c)
        index = index + 1
      }
      None => break
    }
  }
  value
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
pub fn Color::get_hex(self : Color) -> Int32 {
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
/// 写成 sRGB 的 `rgb()` 字符串。
/// r186: `getStyle` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L637
pub fn Color::get_style(self : Color) -> String {
  let r = (linear_to_srgb(self.r) * 255.0).round().to_int()
  let g = (linear_to_srgb(self.g) * 255.0).round().to_int()
  let b = (linear_to_srgb(self.b) * 255.0).round().to_int()
  "rgb(\{r},\{g},\{b})"
}

///|
/// 在色相、饱和度、亮度上各加一个偏移，再写回线性通道。
/// r186: `offsetHSL` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L664
pub fn Color::offset_hsl(
  self : Color,
  h : Double,
  s : Double,
  l : Double,
) -> Color {
  let (hue, saturation, lightness) = self.get_hsl()
  self.set_hsl(hue + h, saturation + s, lightness + l)
}

///|
/// 把另一个颜色的通道加到自身。
/// r186: `add` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L678
pub fn Color::add(self : Color, color : Color) -> Color {
  self.r += color.r
  self.g += color.g
  self.b += color.b
  self
}

///|
/// 把两个颜色的通道相加，写入自身。
/// r186: `addColors` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L695
pub fn Color::add_colors(self : Color, color1 : Color, color2 : Color) -> Color {
  self.r = color1.r + color2.r
  self.g = color1.g + color2.g
  self.b = color1.b + color2.b
  self
}

///|
/// 每个通道都加上同一个数。
/// r186: `addScalar` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L711
pub fn Color::add_scalar(self : Color, scalar : Double) -> Color {
  self.r += scalar
  self.g += scalar
  self.b += scalar
  self
}

///|
/// 减去另一个颜色的通道，结果不低于 0。
/// r186: `sub` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L727
pub fn Color::sub(self : Color, color : Color) -> Color {
  self.r = 0.0.max(self.r - color.r)
  self.g = 0.0.max(self.g - color.g)
  self.b = 0.0.max(self.b - color.b)
  self
}

///|
/// 与另一个颜色按通道相乘。
/// r186: `multiply` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L743
pub fn Color::multiply(self : Color, color : Color) -> Color {
  self.r *= color.r
  self.g *= color.g
  self.b *= color.b
  self
}

///|
/// 每个通道都乘上同一个数。
/// r186: `multiplyScalar` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L759
pub fn Color::multiply_scalar(self : Color, scalar : Double) -> Color {
  self.r *= scalar
  self.g *= scalar
  self.b *= scalar
  self
}

///|
pub fn Color::lerp(self : Color, color : Color, alpha : Double) -> Color {
  self.r += (color.r - self.r) * alpha
  self.g += (color.g - self.g) * alpha
  self.b += (color.b - self.b) * alpha
  self
}

///|
/// 在两个颜色之间插值，写入自身。
/// r186: `lerpColors` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L798
pub fn Color::lerp_colors(
  self : Color,
  color1 : Color,
  color2 : Color,
  alpha : Double,
) -> Color {
  self.r = color1.r + (color2.r - color1.r) * alpha
  self.g = color1.g + (color2.g - color1.g) * alpha
  self.b = color1.b + (color2.b - color1.b) * alpha
  self
}

///|
/// 在色相、饱和度、亮度上向另一个颜色插值，再写回线性通道。
/// r186: `lerpHSL` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L819
pub fn Color::lerp_hsl(self : Color, color : Color, alpha : Double) -> Color {
  let (h1, s1, l1) = self.get_hsl()
  let (h2, s2, l2) = color.get_hsl()
  self.set_hsl(lerp(h1, h2, alpha), lerp(s1, s2, alpha), lerp(l1, l2, alpha))
}

///|
/// 用三维向量的三个分量写入通道。
/// r186: `setFromVector3` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L840
pub fn Color::set_from_vector3(self : Color, v : Vector3) -> Color {
  self.r = v.x
  self.g = v.y
  self.b = v.z
  self
}

///|
/// 用 3×3 矩阵变换三个通道。
/// r186: `applyMatrix3` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L856
pub fn Color::apply_matrix3(self : Color, m : Matrix3) -> Color {
  let r = self.r
  let g = self.g
  let b = self.b
  let e = m.elements
  self.r = e[0] * r + e[3] * g + e[6] * b
  self.g = e[1] * r + e[4] * g + e[7] * b
  self.b = e[2] * r + e[5] * g + e[8] * b
  self
}

///|
/// 三个通道都相同才相等。
/// r186: `equals` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L875
pub fn Color::equals(self : Color, color : Color) -> Bool {
  color.r == self.r && color.g == self.g && color.b == self.b
}

///|
/// `offset` 默认是 0。数组本身不改。
/// r186: `fromArray` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L888
pub fn Color::from_array(
  self : Color,
  array : Array[Double],
  offset~ : Int32 = 0,
) -> Color {
  self.r = array[offset]
  self.g = array[offset + 1]
  self.b = array[offset + 2]
  self
}

///|
/// 省略数组时新建一个。短于 `offset + 3` 的数组会补零再写入。颜色本身不改。
/// r186: `toArray` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L906
pub fn Color::to_array(
  self : Color,
  array? : Array[Double],
  offset~ : Int32 = 0,
) -> Array[Double] {
  let target = match array {
    None => []
    Some(array) => array
  }
  let end = offset + 3
  while target.length() < end {
    target.push(0.0)
  }
  target[offset] = self.r
  target[offset + 1] = self.g
  target[offset + 2] = self.b
  target
}

///|
/// 序列化成 sRGB 十六进制整数。
/// r186: `toJSON` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L939
pub fn Color::to_json(self : Color) -> Int32 {
  self.get_hex()
}
