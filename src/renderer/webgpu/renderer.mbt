///|
using @gpu {
  type GpuBindGroup,
  type GpuBindGroupLayout,
  type GpuBuffer,
  type GpuBufferUsage,
  type GpuCullMode,
  type GpuDevice,
  type GpuRenderPipeline,
  type GpuShaderModule,
  type GpuTexture,
  type GpuTextureFormat,
  type GpuTextureUsage,
  type GpuTextureView,
}

///|
struct DepthTarget {
  texture : GpuTexture
  view : GpuTextureView
  width : UInt
  height : UInt
}

///|
struct GeometryGpu {
  geometry : @core.BufferGeometry
  vertices : GpuBuffer
  indices : GpuBuffer?
  index_count : Int
  vertex_count : Int
}

///|
struct ObjectGpu {
  node : @core.Object3D
  buffer : GpuBuffer
  group : GpuBindGroup
}

///|
struct CullPipelines {
  front : GpuRenderPipeline
  back : GpuRenderPipeline
  double : GpuRenderPipeline
}

///|
/// 一帧里的不透明网格。深度比较是 `less`，近平面为 0。
pub struct WebGPURenderer {
  device : GpuDevice
  window : @surface.Surface
  context : @canvas.Context
  format : GpuTextureFormat
  layout : GpuBindGroupLayout
  basic : CullPipelines
  lambert : CullPipelines
  mut depth : DepthTarget?
  geometries : Array[GeometryGpu]
  uniforms : Array[ObjectGpu]
}

///|
fn flags_buffer(
  vertex~ : Bool,
  index~ : Bool,
  uniform~ : Bool,
) -> GpuBufferUsage {
  let mut usage = GpuBufferUsage::default().set(
    @gpu.GpuBufferUsageFlag::COPY_DST,
  )
  if vertex {
    usage = usage.set(@gpu.GpuBufferUsageFlag::VERTEX)
  }
  if index {
    usage = usage.set(@gpu.GpuBufferUsageFlag::INDEX)
  }
  if uniform {
    usage = usage.set(@gpu.GpuBufferUsageFlag::UNIFORM)
  }
  usage
}

///|
fn flags_texture() -> GpuTextureUsage {
  GpuTextureUsage::default().set(@gpu.GpuTextureUsageFlag::RENDER_ATTACHMENT)
}

///|
fn shader_visibility() -> @gpu.GpuShaderStage {
  @gpu.GpuShaderStage::default()
  .set(@gpu.GpuShaderStageFlag::VERTEX)
  .set(@gpu.GpuShaderStageFlag::FRAGMENT)
}

///|
fn unlit_pipeline(
  device : GpuDevice,
  shader : GpuShaderModule,
  pipeline_layout : @gpu.GpuPipelineLayout,
  format : GpuTextureFormat,
  cull : GpuCullMode,
) -> GpuRenderPipeline {
  device.create_render_pipeline({
    vertex: {
      buffers: Some([
        Some({
          array_stride: 24UL,
          step_mode: Some(@gpu.GpuVertexStepMode::VERTEX),
          attributes: [
            {
              format: @gpu.GpuVertexFormat::FLOAT32X3,
              offset: 0UL,
              shader_location: 0U,
            },
            {
              format: @gpu.GpuVertexFormat::FLOAT32X3,
              offset: 12UL,
              shader_location: 1U,
            },
          ],
        }),
      ]),
      module_: shader,
      entry_point: Some("vs"),
      constants: None,
    },
    primitive: Some({
      topology: Some(@gpu.GpuPrimitiveTopology::TRIANGLE_LIST),
      strip_index_format: None,
      front_face: Some(@gpu.GpuFrontFace::CCW),
      cull_mode: Some(cull),
      unclipped_depth: None,
    }),
    depth_stencil: Some({
      format: @gpu.GpuTextureFormat::DEPTH24PLUS,
      depth_write_enabled: Some(true),
      depth_compare: Some(@gpu.GpuCompareFunction::LESS),
      stencil_front: None,
      stencil_back: None,
      stencil_read_mask: None,
      stencil_write_mask: None,
      depth_bias: None,
      depth_bias_slope_scale: None,
      depth_bias_clamp: None,
    }),
    multisample: None,
    fragment: Some({
      targets: [Some({ format, blend: None, write_mask: None, })],
      module_: shader,
      entry_point: Some("fs"),
      constants: None,
    }),
    layout: @gpu.Specific(pipeline_layout),
    label: Some("unlit"),
  })
}

///|
fn shader_module(
  device : GpuDevice,
  code : String,
  label : String,
) -> GpuShaderModule {
  device.create_shader_module({
    code,
    compilation_hints: None,
    label: Some(label),
  })
}

///|
fn cull_pipelines(
  device : GpuDevice,
  shader : GpuShaderModule,
  pipeline_layout : @gpu.GpuPipelineLayout,
  format : GpuTextureFormat,
) -> CullPipelines {
  {
    front: unlit_pipeline(
      device,
      shader,
      pipeline_layout,
      format,
      GpuCullMode::BACK,
    ),
    back: unlit_pipeline(
      device,
      shader,
      pipeline_layout,
      format,
      GpuCullMode::FRONT,
    ),
    double: unlit_pipeline(
      device,
      shader,
      pipeline_layout,
      format,
      GpuCullMode::NONE,
    ),
  }
}

///|
pub fn WebGPURenderer::new(target : @platform.SurfaceTarget) -> WebGPURenderer {
  let device = target.device()
  let format = @gpu.get_gpu().get_preferred_canvas_format()
  let basic_shader = shader_module(device, @nodes.basic_wgsl(), "basic")
  let lambert_shader = shader_module(device, @nodes.lambert_wgsl(), "lambert")
  let layout = device.create_bind_group_layout({
    entries: [
      {
        binding: 0U,
        visibility: shader_visibility(),
        buffer: Some({
          type_: Some(@gpu.GpuBufferBindingType::UNIFORM),
          has_dynamic_offset: None,
          min_binding_size: None,
        }),
        sampler: None,
        texture: None,
        storage_texture: None,
      },
    ],
    label: Some("unlit"),
  })
  let pipeline_layout = device.create_pipeline_layout({
    bind_group_layouts: [Some(layout)],
    immediate_size: None,
    label: Some("unlit"),
  })
  {
    device,
    window: target.window(),
    context: target.context(),
    format,
    layout,
    basic: cull_pipelines(device, basic_shader, pipeline_layout, format),
    lambert: cull_pipelines(device, lambert_shader, pipeline_layout, format),
    depth: None,
    geometries: [],
    uniforms: [],
  }
}

///|
fn WebGPURenderer::pipeline(
  self : WebGPURenderer,
  shading : @constants.Shading,
  side : @constants.Side,
) -> GpuRenderPipeline {
  let group = match shading {
    @constants.Basic => self.basic
    @constants.Lambert => self.lambert
  }
  match side {
    @constants.Front => group.front
    @constants.Back => group.back
    @constants.Double => group.double
  }
}

///|
fn WebGPURenderer::ensure_depth(
  self : WebGPURenderer,
  width : UInt,
  height : UInt,
) -> GpuTextureView {
  match self.depth {
    Some(depth) =>
      if depth.width == width && depth.height == height {
        return depth.view
      } else {
        depth.view.drop()
        depth.texture.drop()
      }
    None => ()
  }
  let texture = self.device.create_texture({
    size: { width, height: Some(height), depth_or_array_layers: Some(1U), },
    mip_level_count: Some(1U),
    sample_count: Some(1U),
    dimension: Some(@gpu.GpuTextureDimension::D2),
    format: @gpu.GpuTextureFormat::DEPTH24PLUS,
    usage: flags_texture(),
    view_formats: None,
    texture_binding_view_dimension: None,
    label: Some("depth"),
  })
  let view = texture.create_view(None)
  self.depth = Some({ texture, view, width, height, })
  view
}

///|
fn WebGPURenderer::geometry_gpu(
  self : WebGPURenderer,
  geometry : @core.BufferGeometry,
) -> GeometryGpu? {
  for cached in self.geometries {
    if physical_equal(cached.geometry, geometry) {
      return Some(cached)
    }
  }
  match geometry.get_attribute("position") {
    None => None
    Some(position) =>
      if position.count == 0 {
        None
      } else {
        let vertices = pack_buffer(
          self.device,
          @common.pack_position_normal(
            position,
            geometry.get_attribute("normal"),
          ),
          vertex=true,
          index=false,
          uniform=false,
        )
        let (indices, index_count) = match geometry.index {
          None => (None, 0)
          Some(index) =>
            (
              Some(
                pack_buffer(
                  self.device,
                  @common.pack_u32_indices(index),
                  vertex=false,
                  index=true,
                  uniform=false,
                ),
              ),
              index.count,
            )
        }
        let cached = {
          geometry,
          vertices,
          indices,
          index_count,
          vertex_count: position.count,
        }
        self.geometries.push(cached)
        Some(cached)
      }
  }
}

///|
fn pack_buffer(
  device : GpuDevice,
  bytes : FixedArray[Byte],
  vertex~ : Bool,
  index~ : Bool,
  uniform~ : Bool,
) -> GpuBuffer {
  let buffer = device.create_buffer({
    size: bytes.length().to_uint64(),
    usage: flags_buffer(vertex~, index~, uniform~),
    mapped_at_creation: None,
    label: None,
  })
  ignore(device.queue().write_buffer_with_copy(buffer, 0UL, bytes, None, None))
  buffer
}

///|
fn WebGPURenderer::object_gpu(
  self : WebGPURenderer,
  node : @core.Object3D,
) -> ObjectGpu {
  for cached in self.uniforms {
    if physical_equal(cached.node, node) {
      return cached
    }
  }
  let buffer = self.device.create_buffer({
    size: @common.uniform_bytes.to_uint64(),
    usage: flags_buffer(vertex=false, index=false, uniform=true),
    mapped_at_creation: None,
    label: Some("mvp"),
  })
  let group = self.device.create_bind_group({
    layout: self.layout,
    entries: [
      { binding: 0U, resource: @gpu.GpuBindingResource::GpuBuffer(buffer), },
    ],
    label: Some("mvp"),
  })
  let cached = { node, buffer, group, }
  self.uniforms.push(cached)
  cached
}

///|
fn sync_aspect(camera : @core.Object3D, width : UInt, height : UInt) -> Unit {
  if height == 0U {
    return
  }
  match camera.camera {
    None => ()
    Some(state) =>
      match state.kind {
        @core.Perspective => {
          state.aspect = width.reinterpret_as_int().to_double() /
            height.reinterpret_as_int().to_double()
          state.update_projection()
        }
        @core.Orthographic => ()
      }
  }
}

///|
/// 更新矩阵，清屏，画出不透明网格，然后 `present`。
pub fn WebGPURenderer::render(
  self : WebGPURenderer,
  scene : @scenes.Scene,
  camera : @core.Object3D,
) -> Unit {
  let width = self.window.width()
  let height = self.window.height()
  if width == 0U || height == 0U {
    return
  }
  sync_aspect(camera, width, height)
  @common.update_frame(scene.node, camera)
  let state = match camera.camera {
    None => return
    Some(state) => state
  }
  let depth = self.ensure_depth(width, height)
  let color = self.context.get_current_texture().create_view(None)
  let (r, g, b) = match scene.background {
    None => (0.0, 0.0, 0.0)
    Some(background) => (background.r, background.g, background.b)
  }
  let encoder = self.device.create_command_encoder(None)
  let pass = encoder.begin_render_pass({
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
    depth_stencil_attachment: Some({
      view: depth,
      depth_clear_value: Some(Float::from_int(1)),
      depth_load_op: Some(@gpu.CLEAR),
      depth_store_op: Some(@gpu.STORE),
      depth_read_only: Some(false),
      stencil_clear_value: None,
      stencil_load_op: None,
      stencil_store_op: None,
      stencil_read_only: None,
    }),
    occlusion_query_set: None,
    timestamp_writes: None,
    max_draw_count: None,
    label: Some("frame"),
  })
  let lights = @common.collect_lights(scene.node)
  let items = @common.collect_opaque(scene.node)
  for item in items {
    match self.geometry_gpu(item.geometry) {
      None => ()
      Some(geometry) => {
        let mvp = @common.model_view_projection(state, item.node)
        let gpu = self.object_gpu(item.node)
        let uniforms = @common.pack_uniforms(
          mvp,
          @common.normal_matrix(item.node.matrix_world),
          item.color,
          item.opacity,
          lights.ambient,
          lights.color,
          lights.direction,
        )
        ignore(
          self.device
          .queue()
          .write_buffer_with_copy(gpu.buffer, 0UL, uniforms, None, None),
        )
        pass.set_pipeline(self.pipeline(item.shading, item.side))
        pass.set_vertex_buffer(0U, Some(geometry.vertices), None, None)
        ignore(pass.set_bind_group(0U, Some(gpu.group), None, None, None))
        match geometry.indices {
          None =>
            pass.draw(
              geometry.vertex_count.reinterpret_as_uint(),
              Some(1U),
              None,
              None,
            )
          Some(indices) => {
            pass.set_index_buffer(
              indices,
              @gpu.GpuIndexFormat::UINT32,
              None,
              None,
            )
            pass.draw_indexed(
              geometry.index_count.reinterpret_as_uint(),
              Some(1U),
              None,
              None,
              None,
            )
          }
        }
      }
    }
  }
  pass.end()
  self.device.queue().submit([encoder.finish(None)])
  self.context.present()
}
