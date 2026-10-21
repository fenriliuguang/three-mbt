// r186: `BloomNode` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/tsl/display/BloomNode.js#L54 ; `EffectComposer` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/EffectComposer.js#L42 ; `CopyShader` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/shaders/CopyShader.js#L12

///|
struct PostGroup {
  source : @textures.Texture
  version : Int
  width : UInt
  height : UInt
  group : GpuBindGroup
}

///|
priv struct BloomLevel {
  width : UInt
  height : UInt
  h_texture : GpuTexture
  h_view : GpuTextureView
  v_texture : GpuTexture
  v_view : GpuTextureView
}

///|
struct BloomPyramid {
  width : UInt
  height : UInt
  bright_texture : GpuTexture
  bright_view : GpuTextureView
  levels : Array[BloomLevel]
  acc_texture : GpuTexture
  acc_view : GpuTextureView
  acc2_texture : GpuTexture
  acc2_view : GpuTextureView
}

///|
struct ChainBuffers {
  width : UInt
  height : UInt
  a_texture : GpuTexture
  a_view : GpuTextureView
  b_texture : GpuTexture
  b_view : GpuTextureView
}

///|
/// 把 `source` 铺满窗口，并按 `pass.amount` 混进灰度，然后 `present`。
/// 场景应先画进这个颜色目标。窗口尺寸为 0 时什么也不做。
/// r186: `PostProcessing` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/PostProcessing.js#L9
pub fn WebGPURenderer::post(
  self : WebGPURenderer,
  source : @textures.RenderTarget,
  pass : @post.GrayscalePass,
) -> Unit {
  let width = self.window.width()
  let height = self.window.height()
  if width == 0U || height == 0U {
    return
  }
  self.sync_swapchain()
  ignore(
    self.device
    .queue()
    .write_buffer_with_copy(
      self.post_uniform,
      0UL,
      @post.pack_amount(pass.amount),
      None,
      None,
    ),
  )
  let group = self.post_bind(source.texture)
  let color = self.context.get_current_texture().create_view(None)
  let encoder = self.device.create_command_encoder(None)
  let draw = encoder.begin_render_pass({
    color_attachments: [
      Some({
        view: color,
        depth_slice: None,
        resolve_target: None,
        clear_value: Some({ r: 0.0, g: 0.0, b: 0.0, a: 1.0, }),
        load_op: @gpu.CLEAR,
        store_op: @gpu.STORE,
      }),
    ],
    depth_stencil_attachment: None,
    occlusion_query_set: None,
    timestamp_writes: None,
    max_draw_count: None,
    label: Some("post"),
  })
  draw.set_pipeline(self.post)
  ignore(draw.set_bind_group(0U, Some(group), None, None, None))
  draw.draw(3U, Some(1U), None, None)
  draw.end()
  self.device.queue().submit([encoder.finish(None)])
  self.context.present()
}

///|
/// 把 `source` 铺满窗口并做色调映射，然后 `present`。
/// `No` 保持原色。`Linear` 乘曝光后夹到 \[0, 1\]。`Reinhard`、Cineon、ACES、AgX、Neutral 用 r186 的同名曲线。
/// r186 在画到屏幕时由输出节点完成；这里仍是单独的全屏通道。窗口尺寸为 0 时什么也不做。
/// r186: `toneMapping` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Renderer.js#L192 ; `reinhardToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/nodes/display/ToneMappingFunctions.js#L39
pub fn WebGPURenderer::tone_map(
  self : WebGPURenderer,
  source : @textures.RenderTarget,
  pass : @post.ToneMappingPass,
) -> Unit {
  let width = self.window.width()
  let height = self.window.height()
  if width == 0U || height == 0U {
    return
  }
  self.sync_swapchain()
  ignore(
    self.device
    .queue()
    .write_buffer_with_copy(
      self.tone_uniform,
      0UL,
      @post.pack_tone(pass.mapping, pass.exposure, srgb=pass.srgb),
      None,
      None,
    ),
  )
  let group = self.tone_bind(source.texture)
  let color = self.context.get_current_texture().create_view(None)
  let encoder = self.device.create_command_encoder(None)
  let draw = encoder.begin_render_pass({
    color_attachments: [
      Some({
        view: color,
        depth_slice: None,
        resolve_target: None,
        clear_value: Some({ r: 0.0, g: 0.0, b: 0.0, a: 1.0, }),
        load_op: @gpu.CLEAR,
        store_op: @gpu.STORE,
      }),
    ],
    depth_stencil_attachment: None,
    occlusion_query_set: None,
    timestamp_writes: None,
    max_draw_count: None,
    label: Some("tone"),
  })
  draw.set_pipeline(self.tone)
  ignore(draw.set_bind_group(0U, Some(group), None, None, None))
  draw.draw(3U, Some(1U), None, None)
  draw.end()
  self.device.queue().submit([encoder.finish(None)])
  self.context.present()
}

///|
/// 高通后做五级可分离模糊，核半径 6、10、14、18、22，再把光加回原图并 `present`。
/// 第 0 级是全分辨率，之后每级对半。每次提交单独发生，采样目标和渲染目标分开。
/// 窗口尺寸为 0 时什么也不做。中间纹理是 `rgba16float`，场景和交换链仍用画布格式。
/// r186: `updateBefore` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/tsl/display/BloomNode.js#L348 ; `HalfFloatType` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/tsl/display/BloomNode.js#L164
pub fn WebGPURenderer::bloom(
  self : WebGPURenderer,
  source : @textures.RenderTarget,
  pass : @post.BloomPass,
) -> Unit {
  let width = self.window.width()
  let height = self.window.height()
  if width == 0U || height == 0U {
    return
  }
  self.sync_swapchain()
  let frame = self.color_target(source.texture)
  self.bloom_release()
  let glow = self.bloom_prepare(frame.view, frame.width, frame.height, pass)
  let screen = self.context.get_current_texture().create_view(None)
  self.bloom_submit(
    pass,
    0.0,
    0.0,
    0.0,
    0.0,
    5.0,
    6.0,
    1.0,
    0,
    frame.view,
    glow,
    screen,
  )
  self.context.present()
}

///|
/// 按通道顺序处理 `source`。前面的通道画进一对全尺寸缓冲，最后一条启用的通道画到窗口并 `present`。
/// 关闭的通道跳过。没有启用的通道时不 `present`。窗口尺寸为 0 时什么也不做。
/// 采样的纹理和当前渲染目标分开。节点版 `RenderPipeline`、半精度目标和蒙版还没做。
/// r186: `render` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/EffectComposer.js#L214 ; `isLastEnabledPass` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/EffectComposer.js#L192
pub fn WebGPURenderer::compose(
  self : WebGPURenderer,
  source : @textures.RenderTarget,
  composer : @post.EffectComposer,
) -> Unit {
  let width = self.window.width()
  let height = self.window.height()
  if width == 0U || height == 0U {
    return
  }
  if !composer.any_enabled() {
    return
  }
  self.sync_swapchain()
  let frame = self.color_target(source.texture)
  self.compose_release()
  self.bloom_release()
  let mut read = frame.view
  let mut slot = 0
  let mut index = 0
  let count = composer.pass_count()
  while index < count {
    let step = composer.passes[index]
    if step.enabled {
      if composer.is_last_enabled(index) {
        let screen = self.context.get_current_texture().create_view(None)
        self.compose_effect(
          step.effect,
          read,
          screen,
          frame.width,
          frame.height,
        )
        self.context.present()
        return
      }
      let buffers = self.ensure_chain(frame.width, frame.height)
      let target = if slot == 0 { buffers.a_view } else { buffers.b_view }
      self.compose_effect(step.effect, read, target, frame.width, frame.height)
      read = target
      slot = if slot == 0 { 1 } else { 0 }
    }
    index = index + 1
  }
}

