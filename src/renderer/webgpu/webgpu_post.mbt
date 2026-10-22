// r186: `BloomNode` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/tsl/display/BloomNode.js#L54 ; `EffectComposer` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/EffectComposer.js#L42 ; `CopyShader` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/shaders/CopyShader.js#L12

///|
struct PostGroup {
  source : @textures.Texture
  version : Int32
  width : UInt32
  height : UInt32
  group : GpuBindGroup
}

///|
priv struct BloomLevel {
  width : UInt32
  height : UInt32
  h_texture : GpuTexture
  h_view : GpuTextureView
  v_texture : GpuTexture
  v_view : GpuTextureView
}

///|
struct BloomPyramid {
  width : UInt32
  height : UInt32
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
  width : UInt32
  height : UInt32
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
/// 窗口尺寸为 0 时什么也不做。中间纹理和场景颜色目标是 `rgba16float`，交换链仍用画布格式。
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
    hdr=false,
  )
  self.context.present()
}

///|
/// 按通道顺序处理 `source`。前面的颜色通道画进一对 `rgba16float` 缓冲，最后一条写出颜色的通道画到窗口并 `present`。
/// 蒙版不交换缓冲。蒙版打开时，先把当前图像复制到目标，再只在模板等于 1 的地方画效果。
/// 关闭的通道跳过。没有启用的通道时不 `present`。窗口尺寸为 0 时什么也不做。
/// `transform` 为真时，最后一条颜色通道留在半精度缓冲里，再按给出的曲线画到窗口。
/// r186: `render` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/EffectComposer.js#L214 ; `isLastEnabledPass` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/EffectComposer.js#L192 ; `HalfFloatType` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/EffectComposer.js#L69
pub fn WebGPURenderer::compose(
  self : WebGPURenderer,
  source : @textures.RenderTarget,
  composer : @post.EffectComposer,
  transform~ : Bool = false,
  mapping~ : @constants.ToneMapping = @constants.ToneMapping::No,
  exposure~ : Double = 1.0,
  srgb~ : Bool = false,
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
  let mut mask_active = false
  let count = composer.pass_count()
  let screen_matches = width == frame.width && height == frame.height
  while index < count {
    let step = composer.passes[index]
    if step.enabled {
      match step.effect {
        @post.Mask(pass) => {
          self.draw_mask(
            pass,
            frame.view,
            frame.depth_view,
            frame.width,
            frame.height,
          )
          mask_active = true
        }
        @post.ClearMask(_) => mask_active = false
        _ => {
          let last = composer.is_last_color(index)
          let to_screen = last && !transform
          if to_screen {
            let screen = self.context.get_current_texture().create_view(None)
            let masked = mask_active && screen_matches
            let stencil = if masked { Some(frame.depth_view) } else { None }
            self.paint_effect(
              step.effect,
              read,
              screen,
              frame.width,
              frame.height,
              false,
              masked,
              stencil,
            )
            self.context.present()
            return
          }
          let buffers = self.ensure_chain(frame.width, frame.height)
          let target = if slot == 0 { buffers.a_view } else { buffers.b_view }
          let stencil = if mask_active { Some(frame.depth_view) } else { None }
          self.paint_effect(
            step.effect,
            read,
            target,
            frame.width,
            frame.height,
            true,
            mask_active,
            stencil,
          )
          read = target
          slot = if slot == 0 { 1 } else { 0 }
        }
      }
    }
    index = index + 1
  }
  if transform {
    let screen = self.context.get_current_texture().create_view(None)
    let tone = @post.ToneMappingPass::new(mapping~, exposure~)
    tone.set_srgb(srgb)
    let masked = mask_active && screen_matches
    let stencil = if masked { Some(frame.depth_view) } else { None }
    self.paint_effect(
      @post.Tone(tone),
      read,
      screen,
      frame.width,
      frame.height,
      false,
      masked,
      stencil,
    )
    self.context.present()
  }
}

///|
fn WebGPURenderer::paint_effect(
  self : WebGPURenderer,
  effect : @post.ComposerEffect,
  read : GpuTextureView,
  target : GpuTextureView,
  width : UInt32,
  height : UInt32,
  hdr : Bool,
  masked : Bool,
  stencil : GpuTextureView?,
) -> Unit {
  if masked {
    self.compose_effect(
      @post.Copy(@post.CopyPass::new()),
      read,
      target,
      width,
      height,
      hdr~,
    )
    self.compose_effect(
      effect,
      read,
      target,
      width,
      height,
      hdr~,
      masked=true,
      stencil~,
    )
  } else {
    self.compose_effect(effect, read, target, width, height, hdr~)
  }
}

///|
/// 把蒙版场景画进颜色目标的模板。颜色和深度保持原样。`clear` 为真时先把模板清成 `clear_value`。
/// r186: `render` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/postprocessing/MaskPass.js#L80
fn WebGPURenderer::draw_mask(
  self : WebGPURenderer,
  pass : @post.MaskPass,
  color : GpuTextureView,
  depth : GpuTextureView,
  width : UInt32,
  height : UInt32,
) -> Unit {
  let camera = pass.camera
  sync_camera(camera, width, height, self.reversed_depth)
  @common.update_frame(pass.scene.node, camera)
  self.prepare_skins(pass.scene.node)
  let state = match camera.camera {
    None => return
    Some(state) => state
  }
  let lights = @common.collect_lights(
    pass.scene.node,
    camera~,
    reversed_depth=self.reversed_depth,
  )
  let stencil_load = if pass.clear { @gpu.CLEAR } else { @gpu.LOAD }
  let encoder = self.device.create_command_encoder(None)
  let draw = encoder.begin_render_pass({
    color_attachments: [
      Some({
        view: color,
        depth_slice: None,
        resolve_target: None,
        clear_value: None,
        load_op: @gpu.LOAD,
        store_op: @gpu.STORE,
      }),
    ],
    depth_stencil_attachment: Some({
      view: depth,
      depth_clear_value: None,
      depth_load_op: Some(@gpu.LOAD),
      depth_store_op: Some(@gpu.STORE),
      depth_read_only: Some(false),
      stencil_clear_value: Some(pass.clear_value().reinterpret_as_uint()),
      stencil_load_op: Some(stencil_load),
      stencil_store_op: Some(@gpu.STORE),
      stencil_read_only: Some(false),
    }),
    occlusion_query_set: None,
    timestamp_writes: None,
    max_draw_count: None,
    label: Some("mask"),
  })
  draw.set_stencil_reference(pass.write_value().reinterpret_as_uint())
  let view = @common.camera_frustum(state)
  let shadow_group = self.shadow_dummy
  self.draw_meshes(
    draw,
    @common.collect_opaque(pass.scene.node, frustum=view, camera~),
    camera,
    state,
    lights,
    pass.scene.fog,
    width,
    height,
    shadow_group,
    pass.scene.environment,
    false,
    mask=true,
  )
  self.draw_meshes(
    draw,
    @common.collect_wireframe(pass.scene.node, frustum=view, camera~),
    camera,
    state,
    lights,
    pass.scene.fog,
    width,
    height,
    shadow_group,
    pass.scene.environment,
    false,
    lines=true,
    mask=true,
  )
  let viewport_width = width.reinterpret_as_int().to_double()
  let viewport_height = height.reinterpret_as_int().to_double()
  self.draw_strokes(
    draw,
    @common.collect_primitives(pass.scene.node, frustum=view, camera~),
    camera,
    state,
    lights,
    pass.scene.fog,
    viewport_width,
    viewport_height,
    false,
    mask=true,
  )
  self.draw_transparent(
    draw,
    @common.collect_transparent(pass.scene.node, camera, frustum=view),
    @common.collect_transparent_primitives(
      pass.scene.node,
      camera,
      frustum=view,
    ),
    camera,
    state,
    lights,
    pass.scene.fog,
    width,
    height,
    shadow_group,
    pass.scene.environment,
    viewport_width,
    viewport_height,
    mask=true,
  )
  draw.end()
  self.device.queue().submit([encoder.finish(None)])
}

///|
/// 跑输出链。没有颜色通道时把窗口清成默认蓝，变换打开时再套当前曲线。
/// r186: `render` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderPipeline.js#L130
pub fn WebGPURenderer::render_pipeline(
  self : WebGPURenderer,
  source : @textures.RenderTarget,
  pipeline : @post.RenderPipeline,
) -> Unit {
  ignore(pipeline.take_update())
  let width = self.window.width()
  let height = self.window.height()
  if width == 0U || height == 0U {
    return
  }
  if pipeline.passes.any_enabled() {
    self.compose(
      source,
      pipeline.passes,
      transform=pipeline.output_color_transform &&
        pipeline.passes.any_color_enabled(),
      mapping=pipeline.mapping,
      exposure=pipeline.exposure,
      srgb=pipeline.srgb,
    )
  }
  if !pipeline.passes.any_color_enabled() {
    let color = pipeline.clear_color()
    self.present_clear(color.r, color.g, color.b)
  }
}

///|
fn WebGPURenderer::present_clear(
  self : WebGPURenderer,
  r : Double,
  g : Double,
  b : Double,
) -> Unit {
  let width = self.window.width()
  let height = self.window.height()
  if width == 0U || height == 0U {
    return
  }
  self.sync_swapchain()
  let color = self.context.get_current_texture().create_view(None)
  let encoder = self.device.create_command_encoder(None)
  let draw = encoder.begin_render_pass({
    color_attachments: [
      Some({
        view: color,
        depth_slice: None,
        resolve_target: None,
        clear_value: Some({ r, g, b, a: 1.0, }),
        load_op: @gpu.CLEAR,
        store_op: @gpu.STORE,
      }),
    ],
    depth_stencil_attachment: None,
    occlusion_query_set: None,
    timestamp_writes: None,
    max_draw_count: None,
    label: Some("pipeline-clear"),
  })
  draw.end()
  self.device.queue().submit([encoder.finish(None)])
  self.context.present()
}
