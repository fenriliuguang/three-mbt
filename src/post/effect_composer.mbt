// r186: `EffectComposer` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/EffectComposer.js#L42

///|
/// 一条通道里的效果。没有同名枚举，对应 `EffectComposer` 通道数组里的 `Pass`。
/// r186: `Pass` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/Pass.js#L16
pub(all) enum ComposerEffect {
  Grayscale(GrayscalePass)
  Tone(ToneMappingPass)
  Bloom(BloomPass)
  Copy(CopyPass)
  Mask(MaskPass)
  ClearMask(ClearMaskPass)
}

///|
/// 通道和它的 `enabled`。关掉之后合成时跳过。
/// r186: `Pass` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/Pass.js#L16
pub(all) struct ComposerPass {
  effect : ComposerEffect
  mut enabled : Bool
}

///|
/// 按加入顺序执行的后处理链。复制通道按 `opacity` 缩放四个通道。
/// 蒙版和清除蒙版不交换读写缓冲，也不写出颜色。其余通道写出新图像。
/// r186: `EffectComposer` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/EffectComposer.js#L42
pub(all) struct EffectComposer {
  mut passes : Array[ComposerPass]
}

///|
pub fn EffectComposer::new() -> EffectComposer {
  { passes: [], }
}

///|
/// r186: `addPass` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/EffectComposer.js#L149
pub fn EffectComposer::add_pass(
  self : EffectComposer,
  effect : ComposerEffect,
) -> Unit {
  self.passes.push({ effect, enabled: true, })
}

///|
pub fn EffectComposer::add_grayscale(
  self : EffectComposer,
  pass : GrayscalePass,
) -> Unit {
  self.add_pass(Grayscale(pass))
}

///|
pub fn EffectComposer::add_tone(
  self : EffectComposer,
  pass : ToneMappingPass,
) -> Unit {
  self.add_pass(Tone(pass))
}

///|
pub fn EffectComposer::add_bloom(
  self : EffectComposer,
  pass : BloomPass,
) -> Unit {
  self.add_pass(Bloom(pass))
}

///|
pub fn EffectComposer::add_copy(self : EffectComposer, pass : CopyPass) -> Unit {
  self.add_pass(Copy(pass))
}

///|
/// r186: `addPass` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/EffectComposer.js#L149
pub fn EffectComposer::add_mask(self : EffectComposer, pass : MaskPass) -> Unit {
  self.add_pass(Mask(pass))
}

///|
/// r186: `addPass` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/EffectComposer.js#L149
pub fn EffectComposer::add_clear_mask(
  self : EffectComposer,
  pass : ClearMaskPass,
) -> Unit {
  self.add_pass(ClearMask(pass))
}

///|
pub fn EffectComposer::pass_count(self : EffectComposer) -> Int32 {
  self.passes.length()
}

///|
pub fn EffectComposer::set_enabled(
  self : EffectComposer,
  index : Int32,
  enabled : Bool,
) -> Unit {
  if index >= 0 && index < self.passes.length() {
    self.passes[index].enabled = enabled
  }
}

///|
pub fn EffectComposer::any_enabled(self : EffectComposer) -> Bool {
  let mut index = 0
  while index < self.passes.length() {
    if self.passes[index].enabled {
      return true
    }
    index = index + 1
  }
  false
}

///|
/// 下标之后没有别的启用通道时为真。通道自己是否启用不参与判断。
/// r186: `isLastEnabledPass` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/EffectComposer.js#L192
pub fn EffectComposer::is_last_enabled(
  self : EffectComposer,
  index : Int32,
) -> Bool {
  let mut next = index + 1
  while next < self.passes.length() {
    if self.passes[next].enabled {
      return false
    }
    next = next + 1
  }
  true
}

///|
/// 蒙版不交换读写缓冲。图像通道会交换。
/// r186: `needsSwap` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/Pass.js#L46
pub fn ComposerEffect::needs_swap(self : ComposerEffect) -> Bool {
  match self {
    Mask(_) => false
    ClearMask(_) => false
    Grayscale(_) | Tone(_) | Bloom(_) | Copy(_) => true
  }
}

///|
/// 蒙版只写模板，不改颜色。
pub fn ComposerEffect::writes_color(self : ComposerEffect) -> Bool {
  match self {
    Mask(_) => false
    ClearMask(_) => false
    Grayscale(_) | Tone(_) | Bloom(_) | Copy(_) => true
  }
}

///|
/// 后面没有还会写出颜色的启用通道时为真。蒙版不算。
pub fn EffectComposer::is_last_color(
  self : EffectComposer,
  index : Int32,
) -> Bool {
  let mut next = index + 1
  while next < self.passes.length() {
    if self.passes[next].enabled && self.passes[next].effect.writes_color() {
      return false
    }
    next = next + 1
  }
  true
}

///|
pub fn EffectComposer::any_color_enabled(self : EffectComposer) -> Bool {
  let mut index = 0
  while index < self.passes.length() {
    if self.passes[index].enabled && self.passes[index].effect.writes_color() {
      return true
    }
    index = index + 1
  }
  false
}
