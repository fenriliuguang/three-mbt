// r186: `MaskPass` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/MaskPass.js#L17 ; `ClearMaskPass` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/MaskPass.js#L156

///|
/// 用场景的屏幕覆盖写模板。默认清模板，不交换读写缓冲。
/// `inverse` 为假时几何写 1、清空值是 0。为真时反过来。
/// 之后的图像通道只在模板等于 1 的地方更新。
/// r186: `MaskPass` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/MaskPass.js#L17
pub(all) struct MaskPass {
  scene : @scenes.Scene
  camera : @core.Object3D
  mut inverse : Bool
  mut clear : Bool
}

///|
/// r186: `constructor` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/MaskPass.js#L25
pub fn MaskPass::new(
  scene : @scenes.Scene,
  camera : @core.Object3D,
) -> MaskPass {
  { scene, camera, inverse: false, clear: true, }
}

///|
/// r186: `inverse` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/MaskPass.js#L65
pub fn MaskPass::set_inverse(self : MaskPass, inverse : Bool) -> Unit {
  self.inverse = inverse
}

///|
/// r186: `clear` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/MaskPass.js#L49
pub fn MaskPass::set_clear(self : MaskPass, clear : Bool) -> Unit {
  self.clear = clear
}

///|
/// r186: `needsSwap` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/MaskPass.js#L57
pub fn MaskPass::needs_swap(_self : MaskPass) -> Bool {
  false
}

///|
/// 模板比较通过时写入的参考值。
/// r186: `render` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/MaskPass.js#L80
pub fn MaskPass::write_value(self : MaskPass) -> Int32 {
  if self.inverse {
    0
  } else {
    1
  }
}

///|
/// 绘制前清进模板的值。
/// r186: `render` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/MaskPass.js#L80
pub fn MaskPass::clear_value(self : MaskPass) -> Int32 {
  if self.inverse {
    1
  } else {
    0
  }
}

///|
/// 关掉模板测试。不交换读写缓冲。
/// r186: `ClearMaskPass` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/MaskPass.js#L156
pub(all) struct ClearMaskPass {}

///|
pub fn ClearMaskPass::new() -> ClearMaskPass {
  ClearMaskPass::{ }
}

///|
/// r186: `needsSwap` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/MaskPass.js#L171
pub fn ClearMaskPass::needs_swap(_self : ClearMaskPass) -> Bool {
  false
}
