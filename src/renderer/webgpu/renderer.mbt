///|
using @gpu {
  type GpuBindGroup,
  type GpuBindGroupLayout,
  type GpuBuffer,
  type GpuBufferUsage,
  type GpuComputePipeline,
  type GpuCullMode,
  type GpuDevice,
  type GpuRenderPipeline,
  type GpuSampler,
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
struct PositionGpu {
  geometry : @core.BufferGeometry
  vertices : GpuBuffer
  indices : GpuBuffer?
  index_count : Int
  vertex_count : Int
  mut points : GpuBuffer?
  mut point_count : Int
}

///|
struct ObjectGpu {
  node : @core.Object3D
  buffer : GpuBuffer
  group : GpuBindGroup
}

///|
struct InstanceGpu {
  data : @core.InstanceData
  matrices : GpuBuffer
  colors : GpuBuffer
  mut version : Int
}

///|
struct StorageGpu {
  source : @compute.StoragePositions
  buffer : GpuBuffer
  uniform : GpuBuffer
  group : GpuBindGroup
  count : Int
}

///|
struct PostGroup {
  source : @textures.Texture
  version : Int
  width : UInt
  height : UInt
  group : GpuBindGroup
}

///|
struct ShadowMap {
  texture : GpuTexture
  view : GpuTextureView
  group : GpuBindGroup
  size : UInt
}

///|
priv struct ShadowPack {
  matrix : @math.Matrix4
  bias : Double
  normal_bias : Double
  enabled : Double
  texel : Double
}

///|
priv struct FogPack {
  r : Double
  g : Double
  b : Double
  enabled : Double
  near : Double
  far : Double
  density : Double
  mode : Double
}

///|
struct TextureGpu {
  source : @textures.Texture?
  texture : GpuTexture
  view : GpuTextureView
  sampler : GpuSampler
  group : GpuBindGroup
}

///|
struct ColorTarget {
  source : @textures.Texture
  texture : GpuTexture
  view : GpuTextureView
  sampler : GpuSampler
  group : GpuBindGroup
  depth_texture : GpuTexture
  depth_view : GpuTextureView
  width : UInt
  height : UInt
  version : Int
}

///|
struct CullPipelines {
  front : GpuRenderPipeline
  back : GpuRenderPipeline
  double : GpuRenderPipeline
}

///|
/// 一帧里的网格。深度比较是 `less`，近平面为 0。透明网格用另一组开启混合的管线。
/// 没有贴图的材质使用一张 1×1 白纹理，因此三种着色器始终采样。
pub struct WebGPURenderer {
  device : GpuDevice
  window : @surface.Surface
  context : @canvas.Context
  format : GpuTextureFormat
  layout : GpuBindGroupLayout
  texture_layout : GpuBindGroupLayout
  basic : CullPipelines
  lambert : CullPipelines
  standard : CullPipelines
  basic_instanced : CullPipelines
  lambert_instanced : CullPipelines
  standard_instanced : CullPipelines
  basic_blend : CullPipelines
  lambert_blend : CullPipelines
  standard_blend : CullPipelines
  basic_instanced_blend : CullPipelines
  lambert_instanced_blend : CullPipelines
  standard_instanced_blend : CullPipelines
  line_list : GpuRenderPipeline
  line_strip : GpuRenderPipeline
  points : GpuRenderPipeline
  wave : GpuComputePipeline
  wave_layout : GpuBindGroupLayout
  post : GpuRenderPipeline
  post_layout : GpuBindGroupLayout
  post_uniform : GpuBuffer
  mut post_group : PostGroup?
  quad : GpuBuffer
  white : TextureGpu
  shadow_layout : GpuBindGroupLayout
  shadow_sampler : GpuSampler
  shadow_dummy : GpuBindGroup
  shadow_depth : GpuRenderPipeline
  shadow_depth_instanced : GpuRenderPipeline
  mut shadow_map : ShadowMap?
  mut depth : DepthTarget?
  mut output : @textures.RenderTarget?
  color_targets : Array[ColorTarget]
  geometries : Array[GeometryGpu]
  positions : Array[PositionGpu]
  instances : Array[InstanceGpu]
  storages : Array[StorageGpu]
  uniforms : Array[ObjectGpu]
  textures : Array[TextureGpu]
  mut swap_width : UInt
  mut swap_height : UInt
  mut swapchain_dirty : Bool
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
fn flags_shadow() -> GpuTextureUsage {
  GpuTextureUsage::default()
  .set(@gpu.GpuTextureUsageFlag::RENDER_ATTACHMENT)
  .set(@gpu.GpuTextureUsageFlag::TEXTURE_BINDING)
}

///|
fn flags_sampled() -> GpuTextureUsage {
  GpuTextureUsage::default()
  .set(@gpu.GpuTextureUsageFlag::COPY_DST)
  .set(@gpu.GpuTextureUsageFlag::TEXTURE_BINDING)
}

///|
fn flags_color() -> GpuTextureUsage {
  GpuTextureUsage::default()
  .set(@gpu.GpuTextureUsageFlag::RENDER_ATTACHMENT)
  .set(@gpu.GpuTextureUsageFlag::TEXTURE_BINDING)
}

///|
fn fragment_visibility() -> @gpu.GpuShaderStage {
  @gpu.GpuShaderStage::default().set(@gpu.GpuShaderStageFlag::FRAGMENT)
}

///|
fn compute_visibility() -> @gpu.GpuShaderStage {
  @gpu.GpuShaderStage::default().set(@gpu.GpuShaderStageFlag::COMPUTE)
}

///|
fn flags_storage_vertex() -> GpuBufferUsage {
  GpuBufferUsage::default()
  .set(@gpu.GpuBufferUsageFlag::COPY_DST)
  .set(@gpu.GpuBufferUsageFlag::VERTEX)
  .set(@gpu.GpuBufferUsageFlag::STORAGE)
}

///|
fn gpu_filter(nearest : Bool) -> @gpu.GpuFilterMode {
  if nearest {
    @gpu.GpuFilterMode::NEAREST
  } else {
    @gpu.GpuFilterMode::LINEAR
  }
}

///|
fn gpu_mip(linear : Bool) -> @gpu.GpuMipmapFilterMode {
  if linear {
    @gpu.GpuMipmapFilterMode::LINEAR
  } else {
    @gpu.GpuMipmapFilterMode::NEAREST
  }
}

///|
fn gpu_address(wrap : @constants.Wrapping) -> @gpu.GpuAddressMode {
  match wrap {
    @constants.Repeat => @gpu.GpuAddressMode::REPEAT
    @constants.ClampToEdge => @gpu.GpuAddressMode::CLAMP_TO_EDGE
    @constants.MirroredRepeat => @gpu.GpuAddressMode::MIRROR_REPEAT
  }
}

///|
fn shader_visibility() -> @gpu.GpuShaderStage {
  @gpu.GpuShaderStage::default()
  .set(@gpu.GpuShaderStageFlag::VERTEX)
  .set(@gpu.GpuShaderStageFlag::FRAGMENT)
}

///|
fn mesh_vertex_buffers(instanced : Bool) -> Array[@gpu.GpuVertexBufferLayout?] {
  let geometry : @gpu.GpuVertexBufferLayout? = Some({
    array_stride: @common.vertex_stride.to_uint64(),
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
      {
        format: @gpu.GpuVertexFormat::FLOAT32X2,
        offset: 24UL,
        shader_location: 2U,
      },
    ],
  })
  if !instanced {
    [geometry]
  } else {
    [
      geometry,
      Some({
        array_stride: @common.instance_matrix_stride.to_uint64(),
        step_mode: Some(@gpu.GpuVertexStepMode::INSTANCE),
        attributes: [
          {
            format: @gpu.GpuVertexFormat::FLOAT32X4,
            offset: 0UL,
            shader_location: 3U,
          },
          {
            format: @gpu.GpuVertexFormat::FLOAT32X4,
            offset: 16UL,
            shader_location: 4U,
          },
          {
            format: @gpu.GpuVertexFormat::FLOAT32X4,
            offset: 32UL,
            shader_location: 5U,
          },
          {
            format: @gpu.GpuVertexFormat::FLOAT32X4,
            offset: 48UL,
            shader_location: 6U,
          },
        ],
      }),
      Some({
        array_stride: @common.instance_color_stride.to_uint64(),
        step_mode: Some(@gpu.GpuVertexStepMode::INSTANCE),
        attributes: [
          {
            format: @gpu.GpuVertexFormat::FLOAT32X3,
            offset: 0UL,
            shader_location: 7U,
          },
        ],
      }),
    ]
  }
}

///|
fn unlit_pipeline(
  device : GpuDevice,
  shader : GpuShaderModule,
  pipeline_layout : @gpu.GpuPipelineLayout,
  format : GpuTextureFormat,
  cull : GpuCullMode,
  instanced? : Bool = false,
  blend? : Bool = false,
) -> GpuRenderPipeline {
  let blend_state : @gpu.GpuBlendState? = if blend {
    Some({
      color: {
        operation: Some(@gpu.GpuBlendOperation::ADD),
        src_factor: Some(@gpu.GpuBlendFactor::SRC_ALPHA),
        dst_factor: Some(@gpu.GpuBlendFactor::ONE_MINUS_SRC_ALPHA),
      },
      alpha: {
        operation: Some(@gpu.GpuBlendOperation::ADD),
        src_factor: Some(@gpu.GpuBlendFactor::SRC_ALPHA),
        dst_factor: Some(@gpu.GpuBlendFactor::ONE_MINUS_SRC_ALPHA),
      },
    })
  } else {
    None
  }
  device.create_render_pipeline({
    vertex: {
      buffers: Some(mesh_vertex_buffers(instanced)),
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
      targets: [Some({ format, blend: blend_state, write_mask: None, })],
      module_: shader,
      entry_point: Some("fs"),
      constants: None,
    }),
    layout: @gpu.Specific(pipeline_layout),
    label: Some(if blend { "blend" } else { "unlit" }),
  })
}

///|
/// 只写深度。剔除正面，让背面写入阴影贴图，减轻自阴影 acne。
fn depth_pipeline(
  device : GpuDevice,
  shader : GpuShaderModule,
  pipeline_layout : @gpu.GpuPipelineLayout,
  instanced : Bool,
) -> GpuRenderPipeline {
  device.create_render_pipeline({
    vertex: {
      buffers: Some(mesh_vertex_buffers(instanced)),
      module_: shader,
      entry_point: Some("vs"),
      constants: None,
    },
    primitive: Some({
      topology: Some(@gpu.GpuPrimitiveTopology::TRIANGLE_LIST),
      strip_index_format: None,
      front_face: Some(@gpu.GpuFrontFace::CCW),
      cull_mode: Some(GpuCullMode::FRONT),
      unclipped_depth: None,
    }),
    depth_stencil: Some({
      format: @gpu.GpuTextureFormat::DEPTH32FLOAT,
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
    fragment: None,
    layout: @gpu.Specific(pipeline_layout),
    label: Some("shadow"),
  })
}

///|
fn color_pipeline(
  device : GpuDevice,
  shader : GpuShaderModule,
  pipeline_layout : @gpu.GpuPipelineLayout,
  format : GpuTextureFormat,
  topology : @gpu.GpuPrimitiveTopology,
  instanced : Bool,
) -> GpuRenderPipeline {
  let buffers : Array[@gpu.GpuVertexBufferLayout?] = if instanced {
    [
      Some({
        array_stride: 8UL,
        step_mode: Some(@gpu.GpuVertexStepMode::VERTEX),
        attributes: [
          {
            format: @gpu.GpuVertexFormat::FLOAT32X2,
            offset: 0UL,
            shader_location: 0U,
          },
        ],
      }),
      Some({
        array_stride: @common.position_stride.to_uint64(),
        step_mode: Some(@gpu.GpuVertexStepMode::INSTANCE),
        attributes: [
          {
            format: @gpu.GpuVertexFormat::FLOAT32X3,
            offset: 0UL,
            shader_location: 1U,
          },
        ],
      }),
    ]
  } else {
    [
      Some({
        array_stride: @common.position_stride.to_uint64(),
        step_mode: Some(@gpu.GpuVertexStepMode::VERTEX),
        attributes: [
          {
            format: @gpu.GpuVertexFormat::FLOAT32X3,
            offset: 0UL,
            shader_location: 0U,
          },
        ],
      }),
    ]
  }
  let strip = match topology {
    @gpu.GpuPrimitiveTopology::LINE_STRIP => Some(@gpu.GpuIndexFormat::UINT32)
    _ => None
  }
  device.create_render_pipeline({
    vertex: {
      buffers: Some(buffers),
      module_: shader,
      entry_point: Some("vs"),
      constants: None,
    },
    primitive: Some({
      topology: Some(topology),
      strip_index_format: strip,
      front_face: Some(@gpu.GpuFrontFace::CCW),
      cull_mode: Some(GpuCullMode::NONE),
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
    label: Some("color"),
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
  instanced? : Bool = false,
  blend? : Bool = false,
) -> CullPipelines {
  {
    front: unlit_pipeline(
      device,
      shader,
      pipeline_layout,
      format,
      GpuCullMode::BACK,
      instanced~,
      blend~,
    ),
    back: unlit_pipeline(
      device,
      shader,
      pipeline_layout,
      format,
      GpuCullMode::FRONT,
      instanced~,
      blend~,
    ),
    double: unlit_pipeline(
      device,
      shader,
      pipeline_layout,
      format,
      GpuCullMode::NONE,
      instanced~,
      blend~,
    ),
  }
}

///|
fn upload_texture(
  device : GpuDevice,
  layout : GpuBindGroupLayout,
  width : Int,
  height : Int,
  pixels : FixedArray[Byte],
  wrap_s : @constants.Wrapping,
  wrap_t : @constants.Wrapping,
  mag_filter : @constants.TextureFilter,
  min_filter : @constants.TextureFilter,
  source : @textures.Texture?,
) -> TextureGpu {
  let (padded, stride) = @common.pad_texture_rows(pixels, width, height)
  let texture = device.create_texture({
    size: {
      width: width.reinterpret_as_uint(),
      height: Some(height.reinterpret_as_uint()),
      depth_or_array_layers: Some(1U),
    },
    mip_level_count: Some(1U),
    sample_count: Some(1U),
    dimension: Some(@gpu.GpuTextureDimension::D2),
    format: @gpu.GpuTextureFormat::RGBA8UNORM,
    usage: flags_sampled(),
    view_formats: None,
    texture_binding_view_dimension: None,
    label: Some("rgba8"),
  })
  device
  .queue()
  .write_texture_with_copy(
    { texture, mip_level: Some(0U), origin: None, aspect: None, },
    padded,
    {
      offset: Some(0UL),
      bytes_per_row: Some(stride.reinterpret_as_uint()),
      rows_per_image: Some(height.reinterpret_as_uint()),
    },
    {
      width: width.reinterpret_as_uint(),
      height: Some(height.reinterpret_as_uint()),
      depth_or_array_layers: Some(1U),
    },
  )
  let view = texture.create_view(None)
  let sampler = device.create_sampler(
    Some({
      address_mode_u: Some(gpu_address(wrap_s)),
      address_mode_v: Some(gpu_address(wrap_t)),
      address_mode_w: None,
      mag_filter: Some(gpu_filter(mag_filter.is_nearest())),
      min_filter: Some(gpu_filter(min_filter.is_nearest())),
      mipmap_filter: Some(gpu_mip(min_filter.mip_linear())),
      lod_min_clamp: None,
      lod_max_clamp: None,
      compare: None,
      max_anisotropy: None,
      label: Some("rgba8"),
    }),
  )
  let group = device.create_bind_group({
    layout,
    entries: [
      { binding: 0U, resource: @gpu.GpuBindingResource::GpuTextureView(view), },
      { binding: 1U, resource: @gpu.GpuBindingResource::GpuSampler(sampler), },
    ],
    label: Some("rgba8"),
  })
  { source, texture, view, sampler, group, }
}

///|
fn drop_texture(gpu : TextureGpu) -> Unit {
  gpu.group.drop()
  gpu.view.drop()
  gpu.sampler.drop()
  gpu.texture.drop()
}

///|
fn wave_pipeline(
  device : GpuDevice,
) -> (GpuBindGroupLayout, GpuComputePipeline) {
  let layout = device.create_bind_group_layout({
    entries: [
      {
        binding: 0U,
        visibility: compute_visibility(),
        buffer: Some({
          type_: Some(@gpu.GpuBufferBindingType::STORAGE),
          has_dynamic_offset: None,
          min_binding_size: None,
        }),
        sampler: None,
        texture: None,
        storage_texture: None,
      },
      {
        binding: 1U,
        visibility: compute_visibility(),
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
    label: Some("wave"),
  })
  let pipeline_layout = device.create_pipeline_layout({
    bind_group_layouts: [Some(layout)],
    immediate_size: None,
    label: Some("wave"),
  })
  let shader = shader_module(device, @compute.wave_wgsl(), "wave")
  let pipeline = device.create_compute_pipeline({
    compute: { module_: shader, entry_point: Some("main"), constants: None, },
    layout: @gpu.Specific(pipeline_layout),
    label: Some("wave"),
  })
  (layout, pipeline)
}

///|
fn post_pipeline(
  device : GpuDevice,
  format : GpuTextureFormat,
) -> (GpuBindGroupLayout, GpuRenderPipeline, GpuBuffer) {
  let layout = device.create_bind_group_layout({
    entries: [
      {
        binding: 0U,
        visibility: fragment_visibility(),
        buffer: None,
        sampler: None,
        texture: Some({
          sample_type: Some(@gpu.GpuTextureSampleType::FLOAT),
          view_dimension: Some(@gpu.GpuTextureViewDimension::D2),
          multisampled: Some(false),
        }),
        storage_texture: None,
      },
      {
        binding: 1U,
        visibility: fragment_visibility(),
        buffer: None,
        sampler: Some({ type_: Some(@gpu.GpuSamplerBindingType::FILTERING), }),
        texture: None,
        storage_texture: None,
      },
      {
        binding: 2U,
        visibility: fragment_visibility(),
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
    label: Some("post"),
  })
  let pipeline_layout = device.create_pipeline_layout({
    bind_group_layouts: [Some(layout)],
    immediate_size: None,
    label: Some("post"),
  })
  let shader = shader_module(device, @post.grayscale_wgsl(), "post")
  let pipeline = device.create_render_pipeline({
    vertex: {
      buffers: None,
      module_: shader,
      entry_point: Some("vs"),
      constants: None,
    },
    primitive: Some({
      topology: Some(@gpu.GpuPrimitiveTopology::TRIANGLE_LIST),
      strip_index_format: None,
      front_face: Some(@gpu.GpuFrontFace::CCW),
      cull_mode: Some(GpuCullMode::NONE),
      unclipped_depth: None,
    }),
    depth_stencil: None,
    multisample: None,
    fragment: Some({
      targets: [Some({ format, blend: None, write_mask: None, })],
      module_: shader,
      entry_point: Some("fs"),
      constants: None,
    }),
    layout: @gpu.Specific(pipeline_layout),
    label: Some("post"),
  })
  let uniform = pack_buffer(
    device,
    @post.pack_amount(1.0),
    vertex=false,
    index=false,
    uniform=true,
  )
  (layout, pipeline, uniform)
}

///|
pub fn WebGPURenderer::new(target : @platform.SurfaceTarget) -> WebGPURenderer {
  let device = target.device()
  let format = @gpu.get_gpu().get_preferred_canvas_format()
  let basic_shader = shader_module(device, @nodes.basic_wgsl(), "basic")
  let lambert_shader = shader_module(device, @nodes.lambert_wgsl(), "lambert")
  let standard_shader = shader_module(
    device,
    @nodes.standard_wgsl(),
    "standard",
  )
  let basic_instanced_shader = shader_module(
    device,
    @nodes.basic_instanced_wgsl(),
    "basic-instanced",
  )
  let lambert_instanced_shader = shader_module(
    device,
    @nodes.lambert_instanced_wgsl(),
    "lambert-instanced",
  )
  let standard_instanced_shader = shader_module(
    device,
    @nodes.standard_instanced_wgsl(),
    "standard-instanced",
  )
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
    label: Some("frame"),
  })
  let texture_layout = device.create_bind_group_layout({
    entries: [
      {
        binding: 0U,
        visibility: fragment_visibility(),
        buffer: None,
        sampler: None,
        texture: Some({
          sample_type: Some(@gpu.GpuTextureSampleType::FLOAT),
          view_dimension: Some(@gpu.GpuTextureViewDimension::D2),
          multisampled: Some(false),
        }),
        storage_texture: None,
      },
      {
        binding: 1U,
        visibility: fragment_visibility(),
        buffer: None,
        sampler: Some({ type_: Some(@gpu.GpuSamplerBindingType::FILTERING), }),
        texture: None,
        storage_texture: None,
      },
    ],
    label: Some("rgba8"),
  })
  let shadow_layout = device.create_bind_group_layout({
    entries: [
      {
        binding: 0U,
        visibility: fragment_visibility(),
        buffer: None,
        sampler: None,
        texture: Some({
          sample_type: Some(@gpu.GpuTextureSampleType::DEPTH),
          view_dimension: Some(@gpu.GpuTextureViewDimension::D2),
          multisampled: Some(false),
        }),
        storage_texture: None,
      },
      {
        binding: 1U,
        visibility: fragment_visibility(),
        buffer: None,
        sampler: Some({ type_: Some(@gpu.GpuSamplerBindingType::COMPARISON), }),
        texture: None,
        storage_texture: None,
      },
    ],
    label: Some("shadow"),
  })
  let pipeline_layout = device.create_pipeline_layout({
    bind_group_layouts: [
      Some(layout),
      Some(texture_layout),
      Some(shadow_layout),
    ],
    immediate_size: None,
    label: Some("frame"),
  })
  let color_layout = device.create_pipeline_layout({
    bind_group_layouts: [Some(layout)],
    immediate_size: None,
    label: Some("color"),
  })
  let line_shader = shader_module(device, @nodes.line_wgsl(), "line")
  let points_shader = shader_module(device, @nodes.points_wgsl(), "points")
  let shadow_shader = shader_module(device, @nodes.shadow_wgsl(), "shadow")
  let shadow_instanced_shader = shader_module(
    device,
    @nodes.shadow_instanced_wgsl(),
    "shadow-instanced",
  )
  let shadow_sampler = device.create_sampler(
    Some({
      address_mode_u: Some(@gpu.GpuAddressMode::CLAMP_TO_EDGE),
      address_mode_v: Some(@gpu.GpuAddressMode::CLAMP_TO_EDGE),
      address_mode_w: None,
      mag_filter: Some(@gpu.GpuFilterMode::NEAREST),
      min_filter: Some(@gpu.GpuFilterMode::NEAREST),
      mipmap_filter: Some(@gpu.GpuMipmapFilterMode::NEAREST),
      lod_min_clamp: None,
      lod_max_clamp: None,
      compare: Some(@gpu.GpuCompareFunction::LESS),
      max_anisotropy: None,
      label: Some("shadow"),
    }),
  )
  let shadow_dummy_texture = device.create_texture({
    size: { width: 1U, height: Some(1U), depth_or_array_layers: Some(1U), },
    mip_level_count: Some(1U),
    sample_count: Some(1U),
    dimension: Some(@gpu.GpuTextureDimension::D2),
    format: @gpu.GpuTextureFormat::DEPTH32FLOAT,
    usage: flags_shadow(),
    view_formats: None,
    texture_binding_view_dimension: None,
    label: Some("shadow-dummy"),
  })
  let shadow_dummy = device.create_bind_group({
    layout: shadow_layout,
    entries: [
      {
        binding: 0U,
        resource: @gpu.GpuBindingResource::GpuTextureView(
          shadow_dummy_texture.create_view(None),
        ),
      },
      {
        binding: 1U,
        resource: @gpu.GpuBindingResource::GpuSampler(shadow_sampler),
      },
    ],
    label: Some("shadow-dummy"),
  })
  let wave = wave_pipeline(device)
  let post = post_pipeline(device, format)
  let white = upload_texture(
    device,
    texture_layout,
    1,
    1,
    FixedArray::make(4, b'\xFF'),
    @constants.ClampToEdge,
    @constants.ClampToEdge,
    @constants.Linear,
    @constants.Linear,
    None,
  )
  let window = target.window()
  {
    device,
    window,
    context: target.context(),
    format,
    layout,
    texture_layout,
    basic: cull_pipelines(device, basic_shader, pipeline_layout, format),
    lambert: cull_pipelines(device, lambert_shader, pipeline_layout, format),
    standard: cull_pipelines(device, standard_shader, pipeline_layout, format),
    basic_instanced: cull_pipelines(
      device,
      basic_instanced_shader,
      pipeline_layout,
      format,
      instanced=true,
    ),
    lambert_instanced: cull_pipelines(
      device,
      lambert_instanced_shader,
      pipeline_layout,
      format,
      instanced=true,
    ),
    standard_instanced: cull_pipelines(
      device,
      standard_instanced_shader,
      pipeline_layout,
      format,
      instanced=true,
    ),
    basic_blend: cull_pipelines(
      device,
      basic_shader,
      pipeline_layout,
      format,
      blend=true,
    ),
    lambert_blend: cull_pipelines(
      device,
      lambert_shader,
      pipeline_layout,
      format,
      blend=true,
    ),
    standard_blend: cull_pipelines(
      device,
      standard_shader,
      pipeline_layout,
      format,
      blend=true,
    ),
    basic_instanced_blend: cull_pipelines(
      device,
      basic_instanced_shader,
      pipeline_layout,
      format,
      instanced=true,
      blend=true,
    ),
    lambert_instanced_blend: cull_pipelines(
      device,
      lambert_instanced_shader,
      pipeline_layout,
      format,
      instanced=true,
      blend=true,
    ),
    standard_instanced_blend: cull_pipelines(
      device,
      standard_instanced_shader,
      pipeline_layout,
      format,
      instanced=true,
      blend=true,
    ),
    line_list: color_pipeline(
      device,
      line_shader,
      color_layout,
      format,
      @gpu.GpuPrimitiveTopology::LINE_LIST,
      false,
    ),
    line_strip: color_pipeline(
      device,
      line_shader,
      color_layout,
      format,
      @gpu.GpuPrimitiveTopology::LINE_STRIP,
      false,
    ),
    points: color_pipeline(
      device,
      points_shader,
      color_layout,
      format,
      @gpu.GpuPrimitiveTopology::TRIANGLE_LIST,
      true,
    ),
    wave: wave.1,
    wave_layout: wave.0,
    post: post.1,
    post_layout: post.0,
    post_uniform: post.2,
    post_group: None,
    quad: pack_buffer(
      device,
      @common.point_quad_bytes(),
      vertex=true,
      index=false,
      uniform=false,
    ),
    white,
    shadow_layout,
    shadow_sampler,
    shadow_dummy,
    shadow_depth: depth_pipeline(device, shadow_shader, color_layout, false),
    shadow_depth_instanced: depth_pipeline(
      device, shadow_instanced_shader, color_layout, true,
    ),
    shadow_map: None,
    depth: None,
    output: None,
    color_targets: [],
    geometries: [],
    positions: [],
    instances: [],
    storages: [],
    uniforms: [],
    textures: [],
    swap_width: window.width(),
    swap_height: window.height(),
    swapchain_dirty: false,
  }
}

///|
fn WebGPURenderer::pipeline(
  self : WebGPURenderer,
  shading : @constants.Shading,
  side : @constants.Side,
  blend : Bool,
) -> GpuRenderPipeline {
  self.cull_group(shading, side, false, blend)
}

///|
fn WebGPURenderer::instanced_pipeline(
  self : WebGPURenderer,
  shading : @constants.Shading,
  side : @constants.Side,
  blend : Bool,
) -> GpuRenderPipeline {
  self.cull_group(shading, side, true, blend)
}

///|
fn WebGPURenderer::cull_group(
  self : WebGPURenderer,
  shading : @constants.Shading,
  side : @constants.Side,
  instanced : Bool,
  blend : Bool,
) -> GpuRenderPipeline {
  let group = if blend {
    match (shading, instanced) {
      (@constants.Basic, false) => self.basic_blend
      (@constants.Lambert, false) => self.lambert_blend
      (@constants.Standard, false) => self.standard_blend
      (@constants.Basic, true) => self.basic_instanced_blend
      (@constants.Lambert, true) => self.lambert_instanced_blend
      (@constants.Standard, true) => self.standard_instanced_blend
    }
  } else {
    match (shading, instanced) {
      (@constants.Basic, false) => self.basic
      (@constants.Lambert, false) => self.lambert
      (@constants.Standard, false) => self.standard
      (@constants.Basic, true) => self.basic_instanced
      (@constants.Lambert, true) => self.lambert_instanced
      (@constants.Standard, true) => self.standard_instanced
    }
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
          @common.pack_position_normal_uv(
            position,
            geometry.get_attribute("normal"),
            geometry.get_attribute("uv"),
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
fn upload_instances(
  device : GpuDevice,
  data : @core.InstanceData,
) -> (GpuBuffer, GpuBuffer) {
  let capacity = data.matrices.count
  let matrices = pack_buffer(
    device,
    @common.pack_f32(data.matrices),
    vertex=true,
    index=false,
    uniform=false,
  )
  let colors = pack_buffer(
    device,
    @common.pack_instance_colors(data.colors, capacity),
    vertex=true,
    index=false,
    uniform=false,
  )
  (matrices, colors)
}

///|
fn WebGPURenderer::instance_gpu(
  self : WebGPURenderer,
  data : @core.InstanceData,
) -> InstanceGpu {
  for cached in self.instances {
    if physical_equal(cached.data, data) {
      if cached.version != data.version {
        let capacity = data.matrices.count
        ignore(
          self.device
          .queue()
          .write_buffer_with_copy(
            cached.matrices,
            0UL,
            @common.pack_f32(data.matrices),
            None,
            None,
          ),
        )
        ignore(
          self.device
          .queue()
          .write_buffer_with_copy(
            cached.colors,
            0UL,
            @common.pack_instance_colors(data.colors, capacity),
            None,
            None,
          ),
        )
        cached.version = data.version
      }
      return cached
    }
  }
  let (matrices, colors) = upload_instances(self.device, data)
  let cached = { data, matrices, colors, version: data.version, }
  self.instances.push(cached)
  cached
}

///|
fn WebGPURenderer::position_gpu(
  self : WebGPURenderer,
  geometry : @core.BufferGeometry,
) -> PositionGpu? {
  for cached in self.positions {
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
          @common.pack_f32(position),
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
        let cached : PositionGpu = {
          geometry,
          vertices,
          indices,
          index_count,
          vertex_count: position.count,
          points: None,
          point_count: 0,
        }
        self.positions.push(cached)
        Some(cached)
      }
  }
}

///|
fn WebGPURenderer::storage_for(
  self : WebGPURenderer,
  geometry : @core.BufferGeometry,
) -> StorageGpu? {
  for cached in self.storages {
    if physical_equal(cached.source.geometry, geometry) {
      return Some(cached)
    }
  }
  None
}

///|
fn WebGPURenderer::ensure_storage(
  self : WebGPURenderer,
  positions : @compute.StoragePositions,
) -> StorageGpu {
  match self.storage_for(positions.geometry) {
    Some(cached) => cached
    None => {
      let stride = @common.position_stride
      let bytes = if positions.count < 1 {
        stride
      } else {
        positions.count * stride
      }
      let storage = self.device.create_buffer({
        size: bytes.to_uint64(),
        usage: flags_storage_vertex(),
        mapped_at_creation: None,
        label: Some("wave-positions"),
      })
      ignore(
        self.device
        .queue()
        .write_buffer_with_copy(
          storage,
          0UL,
          FixedArray::make(bytes, b'\x00'),
          None,
          None,
        ),
      )
      let uniform = pack_buffer(
        self.device,
        @compute.pack_wave_params(positions.time, positions.count),
        vertex=false,
        index=false,
        uniform=true,
      )
      let group = self.device.create_bind_group({
        layout: self.wave_layout,
        entries: [
          {
            binding: 0U,
            resource: @gpu.GpuBindingResource::GpuBuffer(storage),
          },
          {
            binding: 1U,
            resource: @gpu.GpuBindingResource::GpuBuffer(uniform),
          },
        ],
        label: Some("wave"),
      })
      let cached = {
        source: positions,
        buffer: storage,
        uniform,
        group,
        count: positions.count,
      }
      self.storages.push(cached)
      cached
    }
  }
}

///|
/// 把 `positions` 的波形写入存储缓冲。随后的 `render` 里，挂着同一几何体的点会读这块缓冲。
pub fn WebGPURenderer::compute(
  self : WebGPURenderer,
  positions : @compute.StoragePositions,
) -> Unit {
  let groups = @compute.workgroup_count(positions.count)
  if groups < 1 {
    return
  }
  let gpu = self.ensure_storage(positions)
  ignore(
    self.device
    .queue()
    .write_buffer_with_copy(
      gpu.uniform,
      0UL,
      @compute.pack_wave_params(positions.time, positions.count),
      None,
      None,
    ),
  )
  let encoder = self.device.create_command_encoder(None)
  let pass = encoder.begin_compute_pass(None)
  pass.set_pipeline(self.wave)
  ignore(pass.set_bind_group(0U, Some(gpu.group), None, None, None))
  pass.dispatch_workgroups(groups.reinterpret_as_uint(), None, None)
  pass.end()
  self.device.queue().submit([encoder.finish(None)])
}

///|
fn WebGPURenderer::point_instances(
  self : WebGPURenderer,
  geometry : PositionGpu,
) -> GpuBuffer {
  match self.storage_for(geometry.geometry) {
    Some(storage) => {
      geometry.point_count = storage.count
      return storage.buffer
    }
    None => ()
  }
  match geometry.points {
    Some(buffer) => buffer
    None => {
      let bytes = match geometry.geometry.get_attribute("position") {
        None => FixedArray::make(0, b'\x00')
        Some(position) =>
          @common.pack_point_positions(position, geometry.geometry.index)
      }
      let buffer = pack_buffer(
        self.device,
        bytes,
        vertex=true,
        index=false,
        uniform=false,
      )
      geometry.point_count = if @common.position_stride == 0 {
        0
      } else {
        bytes.length() / @common.position_stride
      }
      geometry.points = Some(buffer)
      buffer
    }
  }
}

///|
fn WebGPURenderer::draw_lines(
  self : WebGPURenderer,
  pass : @gpu.GpuRenderPassEncoder,
  pipeline : GpuRenderPipeline,
  geometry : PositionGpu,
) -> Unit {
  ignore(self)
  let indexed = match geometry.indices {
    Some(_) => geometry.index_count >= 2
    None => geometry.vertex_count >= 2
  }
  if !indexed {
    return
  }
  pass.set_pipeline(pipeline)
  pass.set_vertex_buffer(0U, Some(geometry.vertices), None, None)
  match geometry.indices {
    None =>
      pass.draw(
        geometry.vertex_count.reinterpret_as_uint(),
        Some(1U),
        None,
        None,
      )
    Some(indices) => {
      pass.set_index_buffer(indices, @gpu.GpuIndexFormat::UINT32, None, None)
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
/// `on-resize` 里调用。下一帧绘制前会 `unconfigure` 再 `configure`。
pub fn WebGPURenderer::invalidate_swapchain(self : WebGPURenderer) -> Unit {
  self.swapchain_dirty = true
}

///|
fn WebGPURenderer::sync_swapchain(self : WebGPURenderer) -> Unit {
  let width = self.window.width()
  let height = self.window.height()
  if !self.swapchain_dirty &&
    width == self.swap_width &&
    height == self.swap_height {
    return
  }
  self.context.unconfigure()
  self.context.configure({
    device: self.device,
    format: self.format,
    usage: None,
    view_formats: None,
    color_space: None,
    tone_mapping: None,
    alpha_mode: None,
  })
  self.swap_width = width
  self.swap_height = height
  self.swapchain_dirty = false
}

///|
fn extent(value : Int) -> UInt {
  if value < 1 {
    1U
  } else {
    value.reinterpret_as_uint()
  }
}

///|
fn drop_color_target(gpu : ColorTarget) -> Unit {
  gpu.group.drop()
  gpu.view.drop()
  gpu.sampler.drop()
  gpu.texture.drop()
  gpu.depth_view.drop()
  gpu.depth_texture.drop()
}

///|
/// 按纹理身份缓存颜色目标和它自己的深度缓冲。尺寸或版本变了就重建。
/// 格式跟画布相同，这样网格管线可以画进去。
fn WebGPURenderer::color_target(
  self : WebGPURenderer,
  source : @textures.Texture,
) -> ColorTarget {
  let width = extent(source.width)
  let height = extent(source.height)
  let version = source.version
  let mut found = -1
  let mut index = 0
  while index < self.color_targets.length() {
    if physical_equal(self.color_targets[index].source, source) {
      found = index
    }
    index = index + 1
  }
  if found >= 0 {
    let cached = self.color_targets[found]
    if cached.width == width &&
      cached.height == height &&
      cached.version == version {
      return cached
    }
    drop_color_target(cached)
  }
  let texture = self.device.create_texture({
    size: { width, height: Some(height), depth_or_array_layers: Some(1U), },
    mip_level_count: Some(1U),
    sample_count: Some(1U),
    dimension: Some(@gpu.GpuTextureDimension::D2),
    format: self.format,
    usage: flags_color(),
    view_formats: None,
    texture_binding_view_dimension: None,
    label: Some("color-target"),
  })
  let view = texture.create_view(None)
  let sampler = self.device.create_sampler(
    Some({
      address_mode_u: Some(gpu_address(source.wrap_s)),
      address_mode_v: Some(gpu_address(source.wrap_t)),
      address_mode_w: None,
      mag_filter: Some(gpu_filter(source.mag_filter.is_nearest())),
      min_filter: Some(gpu_filter(source.min_filter.is_nearest())),
      mipmap_filter: Some(gpu_mip(source.min_filter.mip_linear())),
      lod_min_clamp: None,
      lod_max_clamp: None,
      compare: None,
      max_anisotropy: None,
      label: Some("color-target"),
    }),
  )
  let group = self.device.create_bind_group({
    layout: self.texture_layout,
    entries: [
      { binding: 0U, resource: @gpu.GpuBindingResource::GpuTextureView(view), },
      { binding: 1U, resource: @gpu.GpuBindingResource::GpuSampler(sampler), },
    ],
    label: Some("color-target"),
  })
  let depth_texture = self.device.create_texture({
    size: { width, height: Some(height), depth_or_array_layers: Some(1U), },
    mip_level_count: Some(1U),
    sample_count: Some(1U),
    dimension: Some(@gpu.GpuTextureDimension::D2),
    format: @gpu.GpuTextureFormat::DEPTH24PLUS,
    usage: flags_texture(),
    view_formats: None,
    texture_binding_view_dimension: None,
    label: Some("color-target-depth"),
  })
  let depth_view = depth_texture.create_view(None)
  let cached : ColorTarget = {
    source,
    texture,
    view,
    sampler,
    group,
    depth_texture,
    depth_view,
    width,
    height,
    version,
  }
  if found >= 0 {
    self.color_targets[found] = cached
  } else {
    self.color_targets.push(cached)
  }
  cached
}

///|
fn WebGPURenderer::texture_group(
  self : WebGPURenderer,
  map : @textures.Texture?,
) -> GpuBindGroup {
  match map {
    None => self.white.group
    Some(source) => {
      if source.attachment {
        match self.output {
          Some(current) =>
            if physical_equal(current.texture, source) {
              return self.white.group
            }
          None => ()
        }
        return self.color_target(source).group
      }
      let mut found = -1
      let mut index = 0
      while index < self.textures.length() {
        match self.textures[index].source {
          Some(cached) => if physical_equal(cached, source) { found = index }
          None => ()
        }
        index = index + 1
      }
      if found >= 0 && !source.needs_update {
        return self.textures[found].group
      }
      if found >= 0 {
        drop_texture(self.textures[found])
      }
      let uploaded = upload_texture(
        self.device,
        self.texture_layout,
        source.width,
        source.height,
        source.rgba8(),
        source.wrap_s,
        source.wrap_t,
        source.mag_filter,
        source.min_filter,
        Some(source),
      )
      source.needs_update = false
      if found >= 0 {
        self.textures[found] = uploaded
      } else {
        self.textures.push(uploaded)
      }
      uploaded.group
    }
  }
}

///|
fn fog_pack(fog : @scenes.Fog?, receive : Bool) -> FogPack {
  match fog {
    None =>
      {
        r: 0.0,
        g: 0.0,
        b: 0.0,
        enabled: 0.0,
        near: 0.0,
        far: 1.0,
        density: 0.0,
        mode: 0.0,
      }
    Some(fog) =>
      {
        r: fog.color.r,
        g: fog.color.g,
        b: fog.color.b,
        enabled: if receive {
          1.0
        } else {
          0.0
        },
        near: fog.near,
        far: fog.far,
        density: fog.density,
        mode: match fog.kind {
          @scenes.Linear => 0.0
          @scenes.Exp2 => 1.0
        },
      }
  }
}

///|
fn shadow_pack(lights : @common.LightFrame, receive : Bool) -> ShadowPack {
  match lights.shadow {
    None =>
      {
        matrix: @math.Matrix4::new(),
        bias: 0.0,
        normal_bias: 0.0,
        enabled: 0.0,
        texel: 0.0,
      }
    Some(shadow) =>
      {
        matrix: shadow.matrix,
        bias: shadow.bias,
        normal_bias: shadow.normal_bias,
        enabled: if receive {
          1.0
        } else {
          0.0
        },
        texel: shadow.radius / shadow.map_size.to_double(),
      }
  }
}

///|
fn WebGPURenderer::ensure_shadow(
  self : WebGPURenderer,
  size : Int,
) -> ShadowMap {
  let extent = if size < 1 { 1U } else { size.reinterpret_as_uint() }
  match self.shadow_map {
    Some(map) =>
      if map.size == extent {
        return map
      } else {
        map.group.drop()
        map.view.drop()
        map.texture.drop()
      }
    None => ()
  }
  let texture = self.device.create_texture({
    size: {
      width: extent,
      height: Some(extent),
      depth_or_array_layers: Some(1U),
    },
    mip_level_count: Some(1U),
    sample_count: Some(1U),
    dimension: Some(@gpu.GpuTextureDimension::D2),
    format: @gpu.GpuTextureFormat::DEPTH32FLOAT,
    usage: flags_shadow(),
    view_formats: None,
    texture_binding_view_dimension: None,
    label: Some("shadow"),
  })
  let view = texture.create_view(None)
  let group = self.device.create_bind_group({
    layout: self.shadow_layout,
    entries: [
      { binding: 0U, resource: @gpu.GpuBindingResource::GpuTextureView(view), },
      {
        binding: 1U,
        resource: @gpu.GpuBindingResource::GpuSampler(self.shadow_sampler),
      },
    ],
    label: Some("shadow"),
  })
  let map = { texture, view, group, size: extent, }
  self.shadow_map = Some(map)
  map
}

///|
fn WebGPURenderer::draw_shadow(
  self : WebGPURenderer,
  scene : @scenes.Scene,
  shadow : @common.ShadowFrame,
) -> Unit {
  let map = self.ensure_shadow(shadow.map_size)
  let state = match shadow.camera.camera {
    None => return
    Some(state) => state
  }
  let encoder = self.device.create_command_encoder(None)
  let pass = encoder.begin_render_pass({
    color_attachments: [],
    depth_stencil_attachment: Some({
      view: map.view,
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
    label: Some("shadow"),
  })
  let blank = ShadowPack::{
    matrix: @math.Matrix4::new(),
    bias: 0.0,
    normal_bias: 0.0,
    enabled: 0.0,
    texel: 0.0,
  }
  let items = @common.collect_opaque(scene.node)
  for item in items {
    if !item.node.cast_shadow {
      continue
    }
    let draw_mesh = match item.instances {
      Some(data) => data.count > 0
      None => true
    }
    if !draw_mesh {
      continue
    }
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
          @math.Vector3::new(),
          @math.Vector3::new(),
          @math.Vector3::new(y=1.0),
          item.node.matrix_world,
          @math.Vector3::new(),
          item.roughness,
          item.metalness,
          @math.Matrix4::new(),
          1.0,
          1.0,
          1.0,
          0.0,
          blank.matrix,
          blank.bias,
          blank.normal_bias,
          blank.enabled,
          blank.texel,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          0.0,
        )
        ignore(
          self.device
          .queue()
          .write_buffer_with_copy(gpu.buffer, 0UL, uniforms, None, None),
        )
        let batch = match item.instances {
          Some(data) => Some(self.instance_gpu(data))
          None => None
        }
        pass.set_pipeline(
          match batch {
            Some(_) => self.shadow_depth_instanced
            None => self.shadow_depth
          },
        )
        pass.set_vertex_buffer(0U, Some(geometry.vertices), None, None)
        let instance_count = match item.instances {
          Some(data) =>
            if data.count < data.matrices.count {
              data.count
            } else {
              data.matrices.count
            }
          None => 1
        }
        match batch {
          None => ()
          Some(batch) => {
            pass.set_vertex_buffer(1U, Some(batch.matrices), None, None)
            pass.set_vertex_buffer(2U, Some(batch.colors), None, None)
          }
        }
        ignore(pass.set_bind_group(0U, Some(gpu.group), None, None, None))
        match geometry.indices {
          None =>
            pass.draw(
              geometry.vertex_count.reinterpret_as_uint(),
              Some(instance_count.reinterpret_as_uint()),
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
              Some(instance_count.reinterpret_as_uint()),
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
}

///|
/// 下一帧画到 `target`。`None` 回到窗口，并在帧末 `present`。
pub fn WebGPURenderer::set_render_target(
  self : WebGPURenderer,
  target : @textures.RenderTarget?,
) -> Unit {
  self.output = target
}

///|
fn WebGPURenderer::post_bind(
  self : WebGPURenderer,
  source : @textures.Texture,
) -> GpuBindGroup {
  let frame = self.color_target(source)
  match self.post_group {
    Some(cached) =>
      if physical_equal(cached.source, source) &&
        cached.version == source.version &&
        cached.width == frame.width &&
        cached.height == frame.height {
        return cached.group
      } else {
        cached.group.drop()
      }
    None => ()
  }
  let group = self.device.create_bind_group({
    layout: self.post_layout,
    entries: [
      {
        binding: 0U,
        resource: @gpu.GpuBindingResource::GpuTextureView(frame.view),
      },
      {
        binding: 1U,
        resource: @gpu.GpuBindingResource::GpuSampler(frame.sampler),
      },
      {
        binding: 2U,
        resource: @gpu.GpuBindingResource::GpuBuffer(self.post_uniform),
      },
    ],
    label: Some("post"),
  })
  self.post_group = Some({
    source,
    version: source.version,
    width: frame.width,
    height: frame.height,
    group,
  })
  group
}

///|
/// 把 `source` 铺满窗口，并按 `pass.amount` 混进灰度，然后 `present`。
/// 场景应先画进这个颜色目标。窗口尺寸为 0 时什么也不做。
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
/// 先画不透明网格，再按从远到近画透明网格。`blend` 为真时用 src-alpha 管线。
fn WebGPURenderer::draw_meshes(
  self : WebGPURenderer,
  pass : @gpu.GpuRenderPassEncoder,
  items : Array[@common.RenderItem],
  camera : @core.Object3D,
  state : @core.CameraState,
  lights : @common.LightFrame,
  fog : @scenes.Fog?,
  width : UInt,
  height : UInt,
  shadow_group : GpuBindGroup,
  blend : Bool,
) -> Unit {
  for item in items {
    let draw_mesh = match item.instances {
      Some(data) => data.count > 0
      None => true
    }
    if !draw_mesh {
      continue
    }
    match self.geometry_gpu(item.geometry) {
      None => ()
      Some(geometry) => {
        let mvp = @common.model_view_projection(state, item.node)
        let gpu = self.object_gpu(item.node)
        let eye = camera.matrix_world.elements
        let shade = shadow_pack(lights, item.node.receive_shadow)
        let haze = fog_pack(fog, item.fog)
        let uniforms = @common.pack_uniforms(
          mvp,
          @common.normal_matrix(item.node.matrix_world),
          item.color,
          item.opacity,
          lights.ambient,
          lights.color,
          lights.direction,
          item.node.matrix_world,
          @math.Vector3::new(x=eye[12], y=eye[13], z=eye[14]),
          item.roughness,
          item.metalness,
          state.matrix_world_inverse,
          width.reinterpret_as_int().to_double(),
          height.reinterpret_as_int().to_double(),
          1.0,
          0.0,
          shade.matrix,
          shade.bias,
          shade.normal_bias,
          shade.enabled,
          shade.texel,
          haze.r,
          haze.g,
          haze.b,
          haze.enabled,
          haze.near,
          haze.far,
          haze.density,
          haze.mode,
        )
        ignore(
          self.device
          .queue()
          .write_buffer_with_copy(gpu.buffer, 0UL, uniforms, None, None),
        )
        let batch = match item.instances {
          Some(data) => Some(self.instance_gpu(data))
          None => None
        }
        pass.set_pipeline(
          match batch {
            Some(_) => self.instanced_pipeline(item.shading, item.side, blend)
            None => self.pipeline(item.shading, item.side, blend)
          },
        )
        pass.set_vertex_buffer(0U, Some(geometry.vertices), None, None)
        let instance_count = match item.instances {
          Some(data) => {
            let capacity = data.matrices.count
            if data.count < capacity {
              data.count
            } else {
              capacity
            }
          }
          None => 1
        }
        match batch {
          None => ()
          Some(batch) => {
            pass.set_vertex_buffer(1U, Some(batch.matrices), None, None)
            pass.set_vertex_buffer(2U, Some(batch.colors), None, None)
          }
        }
        ignore(pass.set_bind_group(0U, Some(gpu.group), None, None, None))
        ignore(
          pass.set_bind_group(
            1U,
            Some(self.texture_group(item.map)),
            None,
            None,
            None,
          ),
        )
        ignore(pass.set_bind_group(2U, Some(shadow_group), None, None, None))
        match geometry.indices {
          None =>
            pass.draw(
              geometry.vertex_count.reinterpret_as_uint(),
              Some(instance_count.reinterpret_as_uint()),
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
              Some(instance_count.reinterpret_as_uint()),
              None,
              None,
              None,
            )
          }
        }
      }
    }
  }
}

///|
/// 更新矩阵，清屏，先画不透明网格，再画透明网格。窗口目标会 `present`，颜色目标不会。
pub fn WebGPURenderer::render(
  self : WebGPURenderer,
  scene : @scenes.Scene,
  camera : @core.Object3D,
) -> Unit {
  let offscreen = self.output
  let (width, height, to_screen) = match offscreen {
    None => {
      let width = self.window.width()
      let height = self.window.height()
      if width == 0U || height == 0U {
        return
      }
      self.sync_swapchain()
      (width, height, true)
    }
    Some(target) =>
      (extent(target.texture.width), extent(target.texture.height), false)
  }
  sync_aspect(camera, width, height)
  @common.update_frame(scene.node, camera)
  let state = match camera.camera {
    None => return
    Some(state) => state
  }
  let (color, depth) = match offscreen {
    None =>
      (
        self.context.get_current_texture().create_view(None),
        self.ensure_depth(width, height),
      )
    Some(target) => {
      let frame = self.color_target(target.texture)
      (frame.view, frame.depth_view)
    }
  }
  let (r, g, b) = match scene.background {
    None => (0.0, 0.0, 0.0)
    Some(background) => (background.r, background.g, background.b)
  }
  let lights = @common.collect_lights(scene.node)
  match lights.shadow {
    None => ()
    Some(shadow) => self.draw_shadow(scene, shadow)
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
  let shadow_group = match lights.shadow {
    None => self.shadow_dummy
    Some(shadow) => self.ensure_shadow(shadow.map_size).group
  }
  self.draw_meshes(
    pass,
    @common.collect_opaque(scene.node),
    camera,
    state,
    lights,
    scene.fog,
    width,
    height,
    shadow_group,
    false,
  )
  self.draw_meshes(
    pass,
    @common.collect_transparent(scene.node, camera),
    camera,
    state,
    lights,
    scene.fog,
    width,
    height,
    shadow_group,
    true,
  )
  let strokes = @common.collect_primitives(scene.node)
  let viewport_width = width.reinterpret_as_int().to_double()
  let viewport_height = height.reinterpret_as_int().to_double()
  for item in strokes {
    match self.position_gpu(item.geometry) {
      None => ()
      Some(geometry) => {
        let mvp = @common.model_view_projection(state, item.node)
        let gpu = self.object_gpu(item.node)
        let attenuation = if item.size_attenuation &&
          state.kind is @core.Perspective {
          1.0
        } else {
          0.0
        }
        let eye = camera.matrix_world.elements
        let shade = shadow_pack(lights, false)
        let haze = fog_pack(scene.fog, item.fog)
        let uniforms = @common.pack_uniforms(
          mvp,
          @common.normal_matrix(item.node.matrix_world),
          item.color,
          item.opacity,
          lights.ambient,
          lights.color,
          lights.direction,
          item.node.matrix_world,
          @math.Vector3::new(x=eye[12], y=eye[13], z=eye[14]),
          1.0,
          0.0,
          state.matrix_world_inverse,
          viewport_width,
          viewport_height,
          item.size,
          attenuation,
          shade.matrix,
          shade.bias,
          shade.normal_bias,
          shade.enabled,
          shade.texel,
          haze.r,
          haze.g,
          haze.b,
          haze.enabled,
          haze.near,
          haze.far,
          haze.density,
          haze.mode,
        )
        ignore(
          self.device
          .queue()
          .write_buffer_with_copy(gpu.buffer, 0UL, uniforms, None, None),
        )
        ignore(pass.set_bind_group(0U, Some(gpu.group), None, None, None))
        match item.kind {
          @core.PrimitiveKind::Points => {
            let instances = self.point_instances(geometry)
            if geometry.point_count > 0 {
              pass.set_pipeline(self.points)
              pass.set_vertex_buffer(0U, Some(self.quad), None, None)
              pass.set_vertex_buffer(1U, Some(instances), None, None)
              pass.draw(
                6U,
                Some(geometry.point_count.reinterpret_as_uint()),
                None,
                None,
              )
            }
          }
          @core.PrimitiveKind::Line =>
            self.draw_lines(pass, self.line_strip, geometry)
          @core.PrimitiveKind::LineSegments =>
            self.draw_lines(pass, self.line_list, geometry)
        }
      }
    }
  }
  pass.end()
  self.device.queue().submit([encoder.finish(None)])
  if to_screen {
    self.context.present()
  }
}
