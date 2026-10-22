// r186: `RenderPipeline` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderPipeline.js#L22 ; `PostProcessing` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/PostProcessing.js#L9

///|
/// 全屏输出链。默认输出是 `vec4(0, 0, 1, 1)`。
/// `output_color_transform` 为真时，链的最后再做一次色调映射和可选的 sRGB。
/// 节点图仍在上游。这里的输出是已有的手写全屏通道。
/// r186: `RenderPipeline` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderPipeline.js#L22
pub(all) struct RenderPipeline {
  passes : EffectComposer
  mut output_color_transform : Bool
  mut needs_update : Bool
  mut mapping : @constants.ToneMapping
  mut exposure : Double
  mut srgb : Bool
}

///|
/// 没有通道时输出蓝。色调映射默认 `No`，曝光 1，不做 sRGB。
/// r186: `constructor` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderPipeline.js#L30
pub fn RenderPipeline::new() -> RenderPipeline {
  {
    passes: EffectComposer::new(),
    output_color_transform: true,
    needs_update: true,
    mapping: @constants.ToneMapping::No,
    exposure: 1.0,
    srgb: false,
  }
}

///|
/// r186: `outputColorTransform` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderPipeline.js#L75
pub fn RenderPipeline::set_output_color_transform(
  self : RenderPipeline,
  enabled : Bool,
) -> Unit {
  self.output_color_transform = enabled
  self.needs_update = true
}

///|
pub fn RenderPipeline::set_mapping(
  self : RenderPipeline,
  mapping : @constants.ToneMapping,
) -> Unit {
  self.mapping = mapping
  self.needs_update = true
}

///|
pub fn RenderPipeline::set_exposure(
  self : RenderPipeline,
  exposure : Double,
) -> Unit {
  self.exposure = exposure
  self.needs_update = true
}

///|
pub fn RenderPipeline::set_srgb(self : RenderPipeline, srgb : Bool) -> Unit {
  self.srgb = srgb
  self.needs_update = true
}

///|
/// 读出 `needs_update` 并清掉。映射或输出变换变了之后为真。
/// r186: `needsUpdate` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderPipeline.js#L82
pub fn RenderPipeline::take_update(self : RenderPipeline) -> Bool {
  let flag = self.needs_update
  self.needs_update = false
  flag
}

///|
pub fn RenderPipeline::add_pass(
  self : RenderPipeline,
  effect : ComposerEffect,
) -> Unit {
  self.passes.add_pass(effect)
}

///|
pub fn RenderPipeline::add_grayscale(
  self : RenderPipeline,
  pass : GrayscalePass,
) -> Unit {
  self.passes.add_grayscale(pass)
}

///|
pub fn RenderPipeline::add_tone(
  self : RenderPipeline,
  pass : ToneMappingPass,
) -> Unit {
  self.passes.add_tone(pass)
}

///|
pub fn RenderPipeline::add_bloom(
  self : RenderPipeline,
  pass : BloomPass,
) -> Unit {
  self.passes.add_bloom(pass)
}

///|
pub fn RenderPipeline::add_copy(self : RenderPipeline, pass : CopyPass) -> Unit {
  self.passes.add_copy(pass)
}

///|
pub fn RenderPipeline::add_mask(self : RenderPipeline, pass : MaskPass) -> Unit {
  self.passes.add_mask(pass)
}

///|
pub fn RenderPipeline::add_clear_mask(
  self : RenderPipeline,
  pass : ClearMaskPass,
) -> Unit {
  self.passes.add_clear_mask(pass)
}

///|
/// 没有写出颜色的启用通道时，输出仍是默认的蓝。
pub fn RenderPipeline::output_is_blue(self : RenderPipeline) -> Bool {
  !self.passes.any_color_enabled()
}

///|
/// 默认输出 `vec4(0, 0, 1, 1)`。变换打开时再走当前曲线。
/// r186: `outputNode` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderPipeline.js#L30 ; `renderOutput` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderPipeline.js#L194
pub fn RenderPipeline::clear_color(self : RenderPipeline) -> @math.Color {
  if self.output_color_transform {
    tone_map(0.0, 0.0, 1.0, self.mapping, self.exposure, srgb=self.srgb)
  } else {
    @math.Color::new(r=0.0, g=0.0, b=1.0)
  }
}
