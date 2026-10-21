// r186: `DataTexture` https://github.com/mrdoob/three.js/blob/r186/src/textures/DataTexture.js#L14

///|
/// 直接用浮点缓冲建的纹理。默认是 `RGBA`，四个数一个纹素。`Red` 是一个数一个纹素。
/// 过滤默认最近邻，`flipY` 关闭，不生成 mipmap，行对齐是 `1`。
/// `needsUpdate` 跟 `Texture` 一样从 false 开始，调用方需要上传时自己打开。
/// r186: `DataTexture` https://github.com/mrdoob/three.js/blob/r186/src/textures/DataTexture.js#L14
/// r186: `constructor` https://github.com/mrdoob/three.js/blob/r186/src/textures/DataTexture.js#L32
/// r186: `generateMipmaps` https://github.com/mrdoob/three.js/blob/r186/src/textures/DataTexture.js#L60
/// r186: `flipY` https://github.com/mrdoob/three.js/blob/r186/src/textures/DataTexture.js#L71
/// r186: `unpackAlignment` https://github.com/mrdoob/three.js/blob/r186/src/textures/DataTexture.js#L81
pub(all) struct DataTexture {
  mut width : Int32
  mut height : Int32
  data : Array[Double]
  mut format : @constants.PixelFormat
  mut needs_update : Bool
  mut flip_y : Bool
  mut generate_mipmaps : Bool
  mut unpack_alignment : Int32
  mut wrap_s : @constants.Wrapping
  mut wrap_t : @constants.Wrapping
  mut mag_filter : @constants.TextureFilter
  mut min_filter : @constants.TextureFilter
}

///|
/// 浮点个数必须是 `width * height * components`。`RGBA` 是 4，`Red` 是 1。宽或高小于 1 同样失败。
/// r186: `constructor` https://github.com/mrdoob/three.js/blob/r186/src/textures/DataTexture.js#L32
pub fn DataTexture::new(
  data : Array[Double],
  width~ : Int32 = 1,
  height~ : Int32 = 1,
  format~ : @constants.PixelFormat = @constants.PixelFormat::RGBA,
) -> DataTexture {
  if width < 1 ||
    height < 1 ||
    data.length() != width * height * format.components() {
    abort("DataTexture size does not match its floats")
  }
  {
    width,
    height,
    data,
    format,
    needs_update: false,
    flip_y: false,
    generate_mipmaps: false,
    unpack_alignment: 1,
    wrap_s: @constants.ClampToEdge,
    wrap_t: @constants.ClampToEdge,
    mag_filter: @constants.Nearest,
    min_filter: @constants.Nearest,
  }
}

///|
/// 新建一张纹理，浮点数组与来源共用。`needsUpdate` 打开。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/textures/Texture.js#L462
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/textures/Texture.js#L474
pub fn DataTexture::clone(self : DataTexture) -> DataTexture {
  let cloned = DataTexture::new(
    self.data,
    width=self.width,
    height=self.height,
    format=self.format,
  )
  cloned.needs_update = true
  cloned.flip_y = self.flip_y
  cloned.generate_mipmaps = self.generate_mipmaps
  cloned.unpack_alignment = self.unpack_alignment
  cloned.wrap_s = self.wrap_s
  cloned.wrap_t = self.wrap_t
  cloned.mag_filter = self.mag_filter
  cloned.min_filter = self.min_filter
  cloned
}

///|
/// 释放 GPU 资源。这里没有贴图事件，调用本身不改浮点。
/// r186: `dispose` https://github.com/mrdoob/three.js/blob/r186/src/textures/Texture.js#L647
pub fn DataTexture::dispose(_self : DataTexture) -> Unit {

}
