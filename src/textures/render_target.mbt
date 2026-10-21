// r186: `RenderTarget` https://github.com/mrdoob/three.js/blob/r186/src/core/RenderTarget.js#L15

///|
/// 离屏颜色目标。`texture` 交给 `Mesh::set_map` 后即可采样。
/// 没有多重采样、模板缓冲和深度贴图。改尺寸会增加 `texture.version`。
/// r186: `RenderTarget` https://github.com/mrdoob/three.js/blob/r186/src/core/RenderTarget.js#L15
pub(all) struct RenderTarget {
  texture : Texture
}

///|
pub fn RenderTarget::new(width : Int32, height : Int32) -> RenderTarget {
  { texture: Texture::attachment(width, height), }
}

///|
/// 改颜色目标的宽高。相同尺寸不增加版本。小于 1 的边记为 1。
pub fn RenderTarget::set_size(
  self : RenderTarget,
  width : Int32,
  height : Int32,
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
