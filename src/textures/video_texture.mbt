// r186: `VideoTexture` https://github.com/mrdoob/three.js/blob/r186/src/textures/VideoTexture.js#L36

///|
/// 视频帧纹理。没有 DOM 元素，像素仍是调用方给的 `rgba8`。
/// 缩小过滤是 `Linear`，不走 mipmap。`video` 为 true。
/// r186: `VideoTexture` https://github.com/mrdoob/three.js/blob/r186/src/textures/VideoTexture.js#L36
/// r186: `isVideoTexture` https://github.com/mrdoob/three.js/blob/r186/src/textures/VideoTexture.js#L47
pub fn Texture::video(
  width : Int32,
  height : Int32,
  data : FixedArray[Byte],
) -> Texture {
  let map = Texture::from_rgba8(width, height, data)
  map.video = true
  map.mag_filter = @constants.Linear
  map.min_filter = @constants.Linear
  map
}

///|
/// 渲染器在采样前调用。标了视频时打开 `needs_update` 并增加 `version`。
/// 普通纹理什么都不做。没有视频元素可读。
/// r186: `update` https://github.com/mrdoob/three.js/blob/r186/src/textures/VideoTexture.js#L98
pub fn Texture::update(self : Texture) -> Unit {
  if self.video {
    self.needs_update = true
    self.version = self.version + 1
  }
}
