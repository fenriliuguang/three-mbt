// r186: `Texture` https://github.com/mrdoob/three.js/blob/r186/src/textures/Texture.js#L32 ; `RenderTarget` https://github.com/mrdoob/three.js/blob/r186/src/core/RenderTarget.js#L15

///|
/// `rgba8` 纹理。字节按行优先，第 0 行是图像顶部。没有 DOM 图片路径。
///
/// `flip_y` 默认 true，与 r186 一致：上传前把行序颠倒，使图像顶部落到较高的 v。
/// 本阶段不生成 mipmap。
///
/// `attachment` 为 true 时，像素在 GPU 颜色目标上，`data` 只是 1×1 占位。
/// 这种纹理 `flip_y` 为 false：画面顶在纹理的 v = 0。
/// r186: `Texture` https://github.com/mrdoob/three.js/blob/r186/src/textures/Texture.js#L32
pub(all) struct Texture {
  mut width : Int
  mut height : Int
  data : FixedArray[Byte]
  mut wrap_s : @constants.Wrapping
  mut wrap_t : @constants.Wrapping
  mut mag_filter : @constants.TextureFilter
  mut min_filter : @constants.TextureFilter
  mut flip_y : Bool
  mut needs_update : Bool
  attachment : Bool
  mut version : Int
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
    attachment: false,
    version: 0,
  }
}

///|
/// 颜色目标用的空纹理。尺寸至少是 1×1，CPU 侧不保存整张图。
pub fn Texture::attachment(width : Int, height : Int) -> Texture {
  {
    width: if width < 1 {
      1
    } else {
      width
    },
    height: if height < 1 {
      1
    } else {
      height
    },
    data: FixedArray::make(4, b'\x00'),
    wrap_s: @constants.ClampToEdge,
    wrap_t: @constants.ClampToEdge,
    mag_filter: @constants.Linear,
    min_filter: @constants.Linear,
    flip_y: false,
    needs_update: false,
    attachment: true,
    version: 0,
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
/// 颜色目标没有 CPU 像素，这里只返回 1×1 占位。
pub fn Texture::rgba8(self : Texture) -> FixedArray[Byte] {
  if self.attachment {
    return FixedArray::make(4, b'\x00')
  }
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

///|
/// 离屏颜色目标。`texture` 交给 `Mesh::set_map` 后即可采样。
/// 没有多重采样、模板缓冲和深度贴图。改尺寸会增加 `texture.version`。
/// r186: `RenderTarget` https://github.com/mrdoob/three.js/blob/r186/src/core/RenderTarget.js#L15
pub(all) struct RenderTarget {
  texture : Texture
}

///|
pub fn RenderTarget::new(width : Int, height : Int) -> RenderTarget {
  { texture: Texture::attachment(width, height), }
}

///|
/// 改颜色目标的宽高。相同尺寸不增加版本。小于 1 的边记为 1。
pub fn RenderTarget::set_size(
  self : RenderTarget,
  width : Int,
  height : Int,
) -> Unit {
  let next_width = if width < 1 { 1 } else { width }
  let next_height = if height < 1 { 1 } else { height }
  if self.texture.width == next_width && self.texture.height == next_height {
    return
  }
  self.texture.width = next_width
  self.texture.height = next_height
  self.texture.version = self.texture.version + 1
}
