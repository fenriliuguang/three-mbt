// r186: `_getBlending` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgpu/utils/WebGPUPipelineUtils.js#L552

///|
struct ShadowPipelines {
  back : GpuRenderPipeline
  front : GpuRenderPipeline
  double : GpuRenderPipeline
}

///|
struct CullPipelines {
  front : GpuRenderPipeline
  back : GpuRenderPipeline
  double : GpuRenderPipeline
}

///|
/// 颜色通道的深度状态。前两项是测试关掉时的写与不写，比较固定为 `always`。
/// 后面每项深度函数占两项，先写再不写，顺序与 `DepthFunc::to_int` 相同。
priv struct DepthModes[T] {
  modes : Array[T]
}

///|
fn[T] DepthModes::pick(
  self : DepthModes[T],
  depth_write : Bool,
  depth_test : Bool,
  depth_func : @constants.DepthFunc,
) -> T {
  let slot = if depth_write { 0 } else { 1 }
  let index = if depth_test { 2 + depth_func.to_int() * 2 + slot } else { slot }
  self.modes[index]
}

///|
/// 颜色写入打开和关掉各一套深度状态。关掉时片段写掩码为 0。
struct ColorModes[T] {
  write : DepthModes[T]
  quiet : DepthModes[T]
}

///|
fn[T] ColorModes::pick(
  self : ColorModes[T],
  depth_write : Bool,
  depth_test : Bool,
  depth_func : @constants.DepthFunc,
  color_write : Bool,
) -> T {
  let modes = if color_write { self.write } else { self.quiet }
  modes.pick(depth_write, depth_test, depth_func)
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
      {
        format: @gpu.GpuVertexFormat::FLOAT32X4,
        offset: 32UL,
        shader_location: 8U,
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
  instanced~ : Bool = false,
  blend~ : Bool = false,
  lines~ : Bool = false,
  depth_write~ : Bool = true,
  depth_compare~ : @gpu.GpuCompareFunction = @gpu.GpuCompareFunction::LESS_EQUAL,
  color_write~ : Bool = true,
  premultiplied~ : Bool = false,
) -> GpuRenderPipeline {
  let color_mask : @gpu.GpuColorWrite? = if color_write {
    None
  } else {
    Some(@gpu.GpuColorWrite::default())
  }
  let blend_state : @gpu.GpuBlendState? = if blend {
    Some({
      color: {
        operation: Some(@gpu.GpuBlendOperation::ADD),
        src_factor: Some(
          if premultiplied {
            @gpu.GpuBlendFactor::ONE
          } else {
            @gpu.GpuBlendFactor::SRC_ALPHA
          },
        ),
        dst_factor: Some(@gpu.GpuBlendFactor::ONE_MINUS_SRC_ALPHA),
      },
      alpha: {
        operation: Some(@gpu.GpuBlendOperation::ADD),
        src_factor: Some(
          if premultiplied {
            @gpu.GpuBlendFactor::ONE
          } else {
            @gpu.GpuBlendFactor::SRC_ALPHA
          },
        ),
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
      topology: Some(
        if lines {
          @gpu.GpuPrimitiveTopology::LINE_LIST
        } else {
          @gpu.GpuPrimitiveTopology::TRIANGLE_LIST
        },
      ),
      strip_index_format: None,
      front_face: Some(@gpu.GpuFrontFace::CCW),
      cull_mode: Some(if lines { GpuCullMode::NONE } else { cull }),
      unclipped_depth: None,
    }),
    depth_stencil: Some({
      format: @gpu.GpuTextureFormat::DEPTH24PLUS,
      depth_write_enabled: Some(depth_write),
      depth_compare: Some(depth_compare),
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
      targets: [Some({ format, blend: blend_state, write_mask: color_mask, })],
      module_: shader,
      entry_point: Some("fs"),
      constants: None,
    }),
    layout: @gpu.Specific(pipeline_layout),
    label: Some(if lines { "wire" } else if blend { "blend" } else { "unlit" }),
  })
}

///|
/// 只写深度。`cull` 决定阴影贴图留下哪一面。
fn depth_pipeline(
  device : GpuDevice,
  shader : GpuShaderModule,
  pipeline_layout : @gpu.GpuPipelineLayout,
  instanced : Bool,
  cull : GpuCullMode,
  compare~ : @gpu.GpuCompareFunction = @gpu.GpuCompareFunction::LESS,
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
      cull_mode: Some(cull),
      unclipped_depth: None,
    }),
    depth_stencil: Some({
      format: @gpu.GpuTextureFormat::DEPTH32FLOAT,
      depth_write_enabled: Some(true),
      depth_compare: Some(compare),
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
/// 背面投射剔除正面，正面投射剔除背面，双面不剔除。
fn shadow_pipelines(
  device : GpuDevice,
  shader : GpuShaderModule,
  pipeline_layout : @gpu.GpuPipelineLayout,
  instanced : Bool,
  compare~ : @gpu.GpuCompareFunction = @gpu.GpuCompareFunction::LESS,
) -> ShadowPipelines {
  {
    back: depth_pipeline(
      device,
      shader,
      pipeline_layout,
      instanced,
      GpuCullMode::FRONT,
      compare~,
    ),
    front: depth_pipeline(
      device,
      shader,
      pipeline_layout,
      instanced,
      GpuCullMode::BACK,
      compare~,
    ),
    double: depth_pipeline(
      device,
      shader,
      pipeline_layout,
      instanced,
      GpuCullMode::NONE,
      compare~,
    ),
  }
}

///|
fn color_pipeline(
  device : GpuDevice,
  shader : GpuShaderModule,
  pipeline_layout : @gpu.GpuPipelineLayout,
  format : GpuTextureFormat,
  topology : @gpu.GpuPrimitiveTopology,
  instanced : Bool,
  blend~ : Bool = false,
  depth_write~ : Bool = true,
  depth_compare~ : @gpu.GpuCompareFunction = @gpu.GpuCompareFunction::LESS_EQUAL,
  color_write~ : Bool = true,
  premultiplied~ : Bool = false,
) -> GpuRenderPipeline {
  let color_mask : @gpu.GpuColorWrite? = if color_write {
    None
  } else {
    Some(@gpu.GpuColorWrite::default())
  }
  let blend_state : @gpu.GpuBlendState? = if blend {
    Some({
      color: {
        operation: Some(@gpu.GpuBlendOperation::ADD),
        src_factor: Some(
          if premultiplied {
            @gpu.GpuBlendFactor::ONE
          } else {
            @gpu.GpuBlendFactor::SRC_ALPHA
          },
        ),
        dst_factor: Some(@gpu.GpuBlendFactor::ONE_MINUS_SRC_ALPHA),
      },
      alpha: {
        operation: Some(@gpu.GpuBlendOperation::ADD),
        src_factor: Some(
          if premultiplied {
            @gpu.GpuBlendFactor::ONE
          } else {
            @gpu.GpuBlendFactor::SRC_ALPHA
          },
        ),
        dst_factor: Some(@gpu.GpuBlendFactor::ONE_MINUS_SRC_ALPHA),
      },
    })
  } else {
    None
  }
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
      depth_write_enabled: Some(depth_write),
      depth_compare: Some(depth_compare),
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
      targets: [Some({ format, blend: blend_state, write_mask: color_mask, })],
      module_: shader,
      entry_point: Some("fs"),
      constants: None,
    }),
    layout: @gpu.Specific(pipeline_layout),
    label: Some(if blend { "color-blend" } else { "color" }),
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
  instanced~ : Bool = false,
  blend~ : Bool = false,
  depth_write~ : Bool = true,
  depth_compare~ : @gpu.GpuCompareFunction = @gpu.GpuCompareFunction::LESS_EQUAL,
  color_write~ : Bool = true,
  premultiplied~ : Bool = false,
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
      depth_write~,
      depth_compare~,
      color_write~,
      premultiplied~,
    ),
    back: unlit_pipeline(
      device,
      shader,
      pipeline_layout,
      format,
      GpuCullMode::FRONT,
      instanced~,
      blend~,
      depth_write~,
      depth_compare~,
      color_write~,
      premultiplied~,
    ),
    double: unlit_pipeline(
      device,
      shader,
      pipeline_layout,
      format,
      GpuCullMode::NONE,
      instanced~,
      blend~,
      depth_write~,
      depth_compare~,
      color_write~,
      premultiplied~,
    ),
  }
}

///|
fn depth_func_order() -> Array[@constants.DepthFunc] {
  [
    @constants.Never,
    @constants.Always,
    @constants.Less,
    @constants.LessEqual,
    @constants.Equal,
    @constants.GreaterEqual,
    @constants.Greater,
    @constants.NotEqual,
  ]
}

///|
fn gpu_depth_compare(
  depth_test : Bool,
  depth_func : @constants.DepthFunc,
) -> @gpu.GpuCompareFunction {
  if !depth_test {
    @gpu.GpuCompareFunction::ALWAYS
  } else {
    match depth_func {
      @constants.Never => @gpu.GpuCompareFunction::NEVER
      @constants.Always => @gpu.GpuCompareFunction::ALWAYS
      @constants.Less => @gpu.GpuCompareFunction::LESS
      @constants.LessEqual => @gpu.GpuCompareFunction::LESS_EQUAL
      @constants.Equal => @gpu.GpuCompareFunction::EQUAL
      @constants.GreaterEqual => @gpu.GpuCompareFunction::GREATER_EQUAL
      @constants.Greater => @gpu.GpuCompareFunction::GREATER
      @constants.NotEqual => @gpu.GpuCompareFunction::NOT_EQUAL
    }
  }
}

///|
fn[T] fill_depth_modes(
  make : (Bool, @gpu.GpuCompareFunction) -> T,
) -> DepthModes[T] {
  let modes : Array[T] = []
  modes.push(make(true, @gpu.GpuCompareFunction::ALWAYS))
  modes.push(make(false, @gpu.GpuCompareFunction::ALWAYS))
  for func in depth_func_order() {
    let compare = gpu_depth_compare(true, func)
    modes.push(make(true, compare))
    modes.push(make(false, compare))
  }
  { modes, }
}

///|
fn mesh_depth_modes(
  device : GpuDevice,
  shader : GpuShaderModule,
  pipeline_layout : @gpu.GpuPipelineLayout,
  format : GpuTextureFormat,
  instanced~ : Bool = false,
  blend~ : Bool = false,
  premultiplied~ : Bool = false,
) -> ColorModes[CullPipelines] {
  {
    write: fill_depth_modes(fn(depth_write, depth_compare) {
      cull_pipelines(
        device,
        shader,
        pipeline_layout,
        format,
        instanced~,
        blend~,
        depth_write~,
        depth_compare~,
        color_write=true,
        premultiplied~,
      )
    }),
    quiet: fill_depth_modes(fn(depth_write, depth_compare) {
      cull_pipelines(
        device,
        shader,
        pipeline_layout,
        format,
        instanced~,
        blend~,
        depth_write~,
        depth_compare~,
        color_write=false,
        premultiplied~,
      )
    }),
  }
}

///|
fn wire_depth_modes(
  device : GpuDevice,
  shader : GpuShaderModule,
  pipeline_layout : @gpu.GpuPipelineLayout,
  format : GpuTextureFormat,
  instanced~ : Bool = false,
) -> ColorModes[GpuRenderPipeline] {
  {
    write: fill_depth_modes(fn(depth_write, depth_compare) {
      unlit_pipeline(
        device,
        shader,
        pipeline_layout,
        format,
        GpuCullMode::NONE,
        instanced~,
        lines=true,
        depth_write~,
        depth_compare~,
        color_write=true,
      )
    }),
    quiet: fill_depth_modes(fn(depth_write, depth_compare) {
      unlit_pipeline(
        device,
        shader,
        pipeline_layout,
        format,
        GpuCullMode::NONE,
        instanced~,
        lines=true,
        depth_write~,
        depth_compare~,
        color_write=false,
      )
    }),
  }
}

///|
fn stroke_depth_modes(
  device : GpuDevice,
  shader : GpuShaderModule,
  pipeline_layout : @gpu.GpuPipelineLayout,
  format : GpuTextureFormat,
  topology : @gpu.GpuPrimitiveTopology,
  instanced : Bool,
  blend~ : Bool = false,
  premultiplied~ : Bool = false,
) -> ColorModes[GpuRenderPipeline] {
  {
    write: fill_depth_modes(fn(depth_write, depth_compare) {
      color_pipeline(
        device,
        shader,
        pipeline_layout,
        format,
        topology,
        instanced,
        blend~,
        depth_write~,
        depth_compare~,
        color_write=true,
        premultiplied~,
      )
    }),
    quiet: fill_depth_modes(fn(depth_write, depth_compare) {
      color_pipeline(
        device,
        shader,
        pipeline_layout,
        format,
        topology,
        instanced,
        blend~,
        depth_write~,
        depth_compare~,
        color_write=false,
        premultiplied~,
      )
    }),
  }
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
fn buffer_layout(
  binding : UInt32,
  kind : @gpu.GpuBufferBindingType,
) -> @gpu.GpuBindGroupLayoutEntry {
  {
    binding,
    visibility: compute_visibility(),
    buffer: Some({
      type_: Some(kind),
      has_dynamic_offset: None,
      min_binding_size: None,
    }),
    sampler: None,
    texture: None,
    storage_texture: None,
  }
}

///|
fn skin_pipeline(
  device : GpuDevice,
) -> (GpuBindGroupLayout, GpuComputePipeline) {
  let layout = device.create_bind_group_layout({
    entries: [
      buffer_layout(0U, @gpu.GpuBufferBindingType::READ_ONLY_STORAGE),
      buffer_layout(1U, @gpu.GpuBufferBindingType::STORAGE),
      buffer_layout(2U, @gpu.GpuBufferBindingType::READ_ONLY_STORAGE),
      buffer_layout(3U, @gpu.GpuBufferBindingType::READ_ONLY_STORAGE),
      buffer_layout(4U, @gpu.GpuBufferBindingType::READ_ONLY_STORAGE),
      buffer_layout(5U, @gpu.GpuBufferBindingType::UNIFORM),
    ],
    label: Some("skin"),
  })
  let pipeline_layout = device.create_pipeline_layout({
    bind_group_layouts: [Some(layout)],
    immediate_size: None,
    label: Some("skin"),
  })
  let shader = shader_module(device, @nodes.skin_wgsl(), "skin")
  let pipeline = device.create_compute_pipeline({
    compute: { module_: shader, entry_point: Some("main"), constants: None, },
    layout: @gpu.Specific(pipeline_layout),
    label: Some("skin"),
  })
  (layout, pipeline)
}

///|
fn fullscreen_pipeline(
  device : GpuDevice,
  format : GpuTextureFormat,
  code : String,
  name : String,
  uniform_bytes : FixedArray[Byte],
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
    label: Some(name),
  })
  let pipeline_layout = device.create_pipeline_layout({
    bind_group_layouts: [Some(layout)],
    immediate_size: None,
    label: Some(name),
  })
  let shader = shader_module(device, code, name)
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
    label: Some(name),
  })
  let uniform = pack_buffer(
    device,
    uniform_bytes,
    vertex=false,
    index=false,
    uniform=true,
  )
  (layout, pipeline, uniform)
}

///|
fn bloom_pipeline(
  device : GpuDevice,
  format : GpuTextureFormat,
) -> (GpuBindGroupLayout, GpuRenderPipeline, GpuBuffer, GpuSampler) {
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
        binding: 3U,
        visibility: fragment_visibility(),
        buffer: None,
        sampler: Some({ type_: Some(@gpu.GpuSamplerBindingType::FILTERING), }),
        texture: None,
        storage_texture: None,
      },
      {
        binding: 4U,
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
    label: Some("bloom"),
  })
  let pipeline_layout = device.create_pipeline_layout({
    bind_group_layouts: [Some(layout)],
    immediate_size: None,
    label: Some("bloom"),
  })
  let shader = shader_module(device, @post.bloom_wgsl(), "bloom")
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
    label: Some("bloom"),
  })
  let uniform = pack_buffer(
    device,
    @post.pack_bloom(@post.BloomPass::new(), 0.0, 0.0, 0.0, 0.0, 0.0),
    vertex=false,
    index=false,
    uniform=true,
  )
  let sampler = device.create_sampler(
    Some({
      address_mode_u: Some(@gpu.GpuAddressMode::CLAMP_TO_EDGE),
      address_mode_v: Some(@gpu.GpuAddressMode::CLAMP_TO_EDGE),
      address_mode_w: None,
      mag_filter: Some(@gpu.GpuFilterMode::LINEAR),
      min_filter: Some(@gpu.GpuFilterMode::LINEAR),
      mipmap_filter: Some(@gpu.GpuMipmapFilterMode::NEAREST),
      lod_min_clamp: None,
      lod_max_clamp: None,
      compare: None,
      max_anisotropy: None,
      label: Some("bloom"),
    }),
  )
  (layout, pipeline, uniform, sampler)
}
