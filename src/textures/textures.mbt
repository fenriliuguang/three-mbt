///|
/// `rgba8` 纹理。字节按行优先，第 0 行是图像顶部。没有 DOM 图片路径。
///
/// `flip_y` 默认 true，与 r186 一致：上传前把行序颠倒，使图像顶部落到较高的 v。
/// 本阶段不生成 mipmap。
pub(all) struct Texture {
  width : Int
  height : Int
  data : FixedArray[Byte]
  mut wrap_s : @constants.Wrapping
  mut wrap_t : @constants.Wrapping
  mut mag_filter : @constants.TextureFilter
  mut min_filter : @constants.TextureFilter
  mut flip_y : Bool
  mut needs_update : Bool
}

///|
fn write_rgba(dst : FixedArray[Byte], offset : Int, hex : Int) -> Unit {
  dst[offset] = ((hex >> 16) & 255).to_byte()
  dst[offset + 1] = ((hex >> 8) & 255).to_byte()
  dst[offset + 2] = (hex & 255).to_byte()
  dst[offset + 3] = b'\xFF'
}

///|
/// 用紧排的 `rgba8` 字节建纹理。长度必须是 `width * height * 4`。
pub fn Texture::from_rgba8(
  width : Int,
  height : Int,
  data : FixedArray[Byte],
) -> Texture {
  if width < 1 || height < 1 || data.length() != width * height * 4 {
    abort("rgba8 texture size does not match its bytes")
  }
  {
    width,
    height,
    data,
    wrap_s: @constants.ClampToEdge,
    wrap_t: @constants.ClampToEdge,
    mag_filter: @constants.Linear,
    min_filter: @constants.LinearMipmapLinear,
    flip_y: true,
    needs_update: true,
  }
}

///|
/// 棋盘格。`cell` 是一格的像素边长，`(x / cell + y / cell)` 为偶数时用 `first`。
/// `first` 和 `second` 是 `0xRRGGBB`，按字节原样写入，不做 sRGB 转换。
pub fn Texture::checker(
  width~ : Int,
  height~ : Int,
  cell~ : Int,
  first~ : Int,
  second~ : Int,
) -> Texture {
  let safe_cell = if cell < 1 { 1 } else { cell }
  let data = FixedArray::make(width * height * 4, b'\x00')
  for y in 0..<height {
    for x in 0..<width {
      let hex = if (x / safe_cell + y / safe_cell) % 2 == 0 {
        first
      } else {
        second
      }
      write_rgba(data, (y * width + x) * 4, hex)
    }
  }
  Texture::from_rgba8(width, height, data)
}

///|
/// 上传用的紧排 `rgba8`。`flip_y` 为 true 时第 0 行变成源数据的最后一行。
pub fn Texture::rgba8(self : Texture) -> FixedArray[Byte] {
  let row = self.width * 4
  let dst = FixedArray::make(self.data.length(), b'\x00')
  if !self.flip_y {
    for index in 0..<self.data.length() {
      dst[index] = self.data[index]
    }
    return dst
  }
  for y in 0..<self.height {
    let src_row = (self.height - 1 - y) * row
    let dst_row = y * row
    for x in 0..<row {
      dst[dst_row + x] = self.data[src_row + x]
    }
  }
  dst
}
