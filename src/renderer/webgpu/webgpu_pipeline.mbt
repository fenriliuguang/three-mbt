// r186: `_getBlending` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgpu/utils/WebGPUPipelineUtils.js#L552

///|
struct ShadowPipelines {
  back : GpuRenderPipeline
  front : GpuRenderPipeline
  double : GpuRenderPipeline
}

///|
priv struct CullPipelines {
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
priv struct ColorModes[T] {
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
fn gpu_blend_factor(code : Int32) -> @gpu.GpuBlendFactor {
  if code == @constants.ZERO_FACTOR {
    @gpu.GpuBlendFactor::ZERO
  } else if code == @constants.ONE_FACTOR {
    @gpu.GpuBlendFactor::ONE
  } else if code == @constants.SRC_COLOR_FACTOR {
    @gpu.GpuBlendFactor::SRC
  } else if code == @constants.ONE_MINUS_SRC_COLOR_FACTOR {
    @gpu.GpuBlendFactor::ONE_MINUS_SRC
  } else if code == @constants.SRC_ALPHA_FACTOR {
    @gpu.GpuBlendFactor::SRC_ALPHA
  } else if code == @constants.ONE_MINUS_SRC_ALPHA_FACTOR {
    @gpu.GpuBlendFactor::ONE_MINUS_SRC_ALPHA
  } else if code == @constants.DST_COLOR_FACTOR {
    @gpu.GpuBlendFactor::DST
  } else {
    @gpu.GpuBlendFactor::ONE
  }
}

///|
fn blend_component(
  src : @gpu.GpuBlendFactor,
  dst : @gpu.GpuBlendFactor,
) -> @gpu.GpuBlendComponent {
  {
    operation: Some(@gpu.GpuBlendOperation::ADD),
    src_factor: Some(src),
    dst_factor: Some(dst),
  }
}

///|
fn blend_state_for(
  blend : Bool,
  premultiplied : Bool,
  equation : @common.BlendEquation?,
) -> @gpu.GpuBlendState? {
  match equation {
    Some(equation) =>
      Some({
        color: blend_component(
          gpu_blend_factor(equation.src_color),
          gpu_blend_factor(equation.dst_color),
        ),
        alpha: blend_component(
          gpu_blend_factor(equation.src_alpha),
          gpu_blend_factor(equation.dst_alpha),
        ),
      })
    None =>
      if blend {
        let src = if premultiplied {
          @gpu.GpuBlendFactor::ONE
        } else {
          @gpu.GpuBlendFactor::SRC_ALPHA
        }
        Some({
          color: blend_component(src, @gpu.GpuBlendFactor::ONE_MINUS_SRC_ALPHA),
          alpha: blend_component(src, @gpu.GpuBlendFactor::ONE_MINUS_SRC_ALPHA),
        })
      } else {
        None
      }
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
  stencil~ : Int32 = 0,
  equation~ : @common.BlendEquation? = None,
) -> GpuRenderPipeline {
  let color_mask : @gpu.GpuColorWrite? = if color_write {
    None
  } else {
    Some(@gpu.GpuColorWrite::default())
  }
  let stencil_state = stencil_face(stencil)
  let blend_state = blend_state_for(blend, premultiplied, equation)
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
      format: @gpu.GpuTextureFormat::DEPTH24PLUS_STENCIL8,
      depth_write_enabled: Some(depth_write),
      depth_compare: Some(depth_compare),
      stencil_front: stencil_state,
      stencil_back: stencil_state,
      stencil_read_mask: stencil_read(stencil),
      stencil_write_mask: stencil_write(stencil),
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
  stencil~ : Int32 = 0,
  equation~ : @common.BlendEquation? = None,
) -> GpuRenderPipeline {
  let color_mask : @gpu.GpuColorWrite? = if color_write {
    None
  } else {
    Some(@gpu.GpuColorWrite::default())
  }
  let stencil_state = stencil_face(stencil)
  let blend_state = blend_state_for(blend, premultiplied, equation)
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
      format: @gpu.GpuTextureFormat::DEPTH24PLUS_STENCIL8,
      depth_write_enabled: Some(depth_write),
      depth_compare: Some(depth_compare),
      stencil_front: stencil_state,
      stencil_back: stencil_state,
      stencil_read_mask: stencil_read(stencil),
      stencil_write_mask: stencil_write(stencil),
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
  stencil~ : Int32 = 0,
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
      stencil~,
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
      stencil~,
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
      stencil~,
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
  mask~ : Bool = false,
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
    depth_stencil: fullscreen_depth(mask),
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
  mask~ : Bool = false,
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
    depth_stencil: fullscreen_depth(mask),
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

///|
fn stencil_face(mode : Int32) -> @gpu.GpuStencilFaceState? {
  if mode == 1 {
    Some({
      compare: Some(@gpu.GpuCompareFunction::ALWAYS),
      fail_op: Some(@gpu.GpuStencilOperation::REPLACE),
      depth_fail_op: Some(@gpu.GpuStencilOperation::REPLACE),
      pass_op: Some(@gpu.GpuStencilOperation::REPLACE),
    })
  } else if mode == 2 {
    Some({
      compare: Some(@gpu.GpuCompareFunction::EQUAL),
      fail_op: Some(@gpu.GpuStencilOperation::KEEP),
      depth_fail_op: Some(@gpu.GpuStencilOperation::KEEP),
      pass_op: Some(@gpu.GpuStencilOperation::KEEP),
    })
  } else {
    None
  }
}

///|
fn stencil_read(mode : Int32) -> UInt32? {
  if mode == 0 {
    None
  } else {
    Some(255U)
  }
}

///|
fn stencil_write(mode : Int32) -> UInt32? {
  if mode == 1 {
    Some(255U)
  } else if mode == 2 {
    Some(0U)
  } else {
    None
  }
}

///|
/// 蒙版全屏通道测模板等于 1，深度比较恒通过，不写深度。
fn fullscreen_depth(mask : Bool) -> @gpu.GpuDepthStencilState? {
  if mask {
    let face = stencil_face(2)
    Some({
      format: @gpu.GpuTextureFormat::DEPTH24PLUS_STENCIL8,
      depth_write_enabled: Some(false),
      depth_compare: Some(@gpu.GpuCompareFunction::ALWAYS),
      stencil_front: face,
      stencil_back: face,
      stencil_read_mask: stencil_read(2),
      stencil_write_mask: stencil_write(2),
      depth_bias: None,
      depth_bias_slope_scale: None,
      depth_bias_clamp: None,
    })
  } else {
    None
  }
}

///|
/// 颜色目标格式不同的一整套网格、线和点管线。深度格式都是 `depth24plus-stencil8`。
priv struct MeshFormats {
  basic : ColorModes[CullPipelines]
  lambert : ColorModes[CullPipelines]
  standard : ColorModes[CullPipelines]
  basic_instanced : ColorModes[CullPipelines]
  lambert_instanced : ColorModes[CullPipelines]
  standard_instanced : ColorModes[CullPipelines]
  basic_blend : ColorModes[CullPipelines]
  basic_blend_premul : ColorModes[CullPipelines]
  lambert_blend : ColorModes[CullPipelines]
  lambert_blend_premul : ColorModes[CullPipelines]
  standard_blend : ColorModes[CullPipelines]
  standard_blend_premul : ColorModes[CullPipelines]
  basic_instanced_blend : ColorModes[CullPipelines]
  basic_instanced_blend_premul : ColorModes[CullPipelines]
  lambert_instanced_blend : ColorModes[CullPipelines]
  lambert_instanced_blend_premul : ColorModes[CullPipelines]
  standard_instanced_blend : ColorModes[CullPipelines]
  standard_instanced_blend_premul : ColorModes[CullPipelines]
  basic_lines : ColorModes[GpuRenderPipeline]
  lambert_lines : ColorModes[GpuRenderPipeline]
  standard_lines : ColorModes[GpuRenderPipeline]
  basic_lines_instanced : ColorModes[GpuRenderPipeline]
  lambert_lines_instanced : ColorModes[GpuRenderPipeline]
  standard_lines_instanced : ColorModes[GpuRenderPipeline]
  line_list : ColorModes[GpuRenderPipeline]
  line_strip : ColorModes[GpuRenderPipeline]
  points : ColorModes[GpuRenderPipeline]
  line_list_blend : ColorModes[GpuRenderPipeline]
  line_list_blend_premul : ColorModes[GpuRenderPipeline]
  line_strip_blend : ColorModes[GpuRenderPipeline]
  line_strip_blend_premul : ColorModes[GpuRenderPipeline]
  points_blend : ColorModes[GpuRenderPipeline]
  points_blend_premul : ColorModes[GpuRenderPipeline]
}

///|
fn mesh_formats(
  device : GpuDevice,
  pipeline_layout : @gpu.GpuPipelineLayout,
  color_layout : @gpu.GpuPipelineLayout,
  format : GpuTextureFormat,
) -> MeshFormats {
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
  let line_shader = shader_module(device, @nodes.line_wgsl(), "line")
  let points_shader = shader_module(device, @nodes.points_wgsl(), "points")
  {
    basic: mesh_depth_modes(device, basic_shader, pipeline_layout, format),
    lambert: mesh_depth_modes(device, lambert_shader, pipeline_layout, format),
    standard: mesh_depth_modes(device, standard_shader, pipeline_layout, format),
    basic_instanced: mesh_depth_modes(
      device,
      basic_instanced_shader,
      pipeline_layout,
      format,
      instanced=true,
    ),
    lambert_instanced: mesh_depth_modes(
      device,
      lambert_instanced_shader,
      pipeline_layout,
      format,
      instanced=true,
    ),
    standard_instanced: mesh_depth_modes(
      device,
      standard_instanced_shader,
      pipeline_layout,
      format,
      instanced=true,
    ),
    basic_blend: mesh_depth_modes(
      device,
      basic_shader,
      pipeline_layout,
      format,
      blend=true,
    ),
    basic_blend_premul: mesh_depth_modes(
      device,
      basic_shader,
      pipeline_layout,
      format,
      blend=true,
      premultiplied=true,
    ),
    lambert_blend: mesh_depth_modes(
      device,
      lambert_shader,
      pipeline_layout,
      format,
      blend=true,
    ),
    lambert_blend_premul: mesh_depth_modes(
      device,
      lambert_shader,
      pipeline_layout,
      format,
      blend=true,
      premultiplied=true,
    ),
    standard_blend: mesh_depth_modes(
      device,
      standard_shader,
      pipeline_layout,
      format,
      blend=true,
    ),
    standard_blend_premul: mesh_depth_modes(
      device,
      standard_shader,
      pipeline_layout,
      format,
      blend=true,
      premultiplied=true,
    ),
    basic_instanced_blend: mesh_depth_modes(
      device,
      basic_instanced_shader,
      pipeline_layout,
      format,
      instanced=true,
      blend=true,
    ),
    basic_instanced_blend_premul: mesh_depth_modes(
      device,
      basic_instanced_shader,
      pipeline_layout,
      format,
      instanced=true,
      blend=true,
      premultiplied=true,
    ),
    lambert_instanced_blend: mesh_depth_modes(
      device,
      lambert_instanced_shader,
      pipeline_layout,
      format,
      instanced=true,
      blend=true,
    ),
    lambert_instanced_blend_premul: mesh_depth_modes(
      device,
      lambert_instanced_shader,
      pipeline_layout,
      format,
      instanced=true,
      blend=true,
      premultiplied=true,
    ),
    standard_instanced_blend: mesh_depth_modes(
      device,
      standard_instanced_shader,
      pipeline_layout,
      format,
      instanced=true,
      blend=true,
    ),
    standard_instanced_blend_premul: mesh_depth_modes(
      device,
      standard_instanced_shader,
      pipeline_layout,
      format,
      instanced=true,
      blend=true,
      premultiplied=true,
    ),
    basic_lines: wire_depth_modes(device, basic_shader, pipeline_layout, format),
    lambert_lines: wire_depth_modes(
      device, lambert_shader, pipeline_layout, format,
    ),
    standard_lines: wire_depth_modes(
      device, standard_shader, pipeline_layout, format,
    ),
    basic_lines_instanced: wire_depth_modes(
      device,
      basic_instanced_shader,
      pipeline_layout,
      format,
      instanced=true,
    ),
    lambert_lines_instanced: wire_depth_modes(
      device,
      lambert_instanced_shader,
      pipeline_layout,
      format,
      instanced=true,
    ),
    standard_lines_instanced: wire_depth_modes(
      device,
      standard_instanced_shader,
      pipeline_layout,
      format,
      instanced=true,
    ),
    line_list: stroke_depth_modes(
      device,
      line_shader,
      color_layout,
      format,
      @gpu.GpuPrimitiveTopology::LINE_LIST,
      false,
    ),
    line_strip: stroke_depth_modes(
      device,
      line_shader,
      color_layout,
      format,
      @gpu.GpuPrimitiveTopology::LINE_STRIP,
      false,
    ),
    points: stroke_depth_modes(
      device,
      points_shader,
      color_layout,
      format,
      @gpu.GpuPrimitiveTopology::TRIANGLE_LIST,
      true,
    ),
    line_list_blend: stroke_depth_modes(
      device,
      line_shader,
      color_layout,
      format,
      @gpu.GpuPrimitiveTopology::LINE_LIST,
      false,
      blend=true,
    ),
    line_list_blend_premul: stroke_depth_modes(
      device,
      line_shader,
      color_layout,
      format,
      @gpu.GpuPrimitiveTopology::LINE_LIST,
      false,
      blend=true,
      premultiplied=true,
    ),
    line_strip_blend: stroke_depth_modes(
      device,
      line_shader,
      color_layout,
      format,
      @gpu.GpuPrimitiveTopology::LINE_STRIP,
      false,
      blend=true,
    ),
    line_strip_blend_premul: stroke_depth_modes(
      device,
      line_shader,
      color_layout,
      format,
      @gpu.GpuPrimitiveTopology::LINE_STRIP,
      false,
      blend=true,
      premultiplied=true,
    ),
    points_blend: stroke_depth_modes(
      device,
      points_shader,
      color_layout,
      format,
      @gpu.GpuPrimitiveTopology::TRIANGLE_LIST,
      true,
      blend=true,
    ),
    points_blend_premul: stroke_depth_modes(
      device,
      points_shader,
      color_layout,
      format,
      @gpu.GpuPrimitiveTopology::TRIANGLE_LIST,
      true,
      blend=true,
      premultiplied=true,
    ),
  }
}

///|
/// 蒙版覆盖。颜色不写，深度不写，模板恒通过并替换。
priv struct MaskCoverage {
  basic : CullPipelines
  lambert : CullPipelines
  standard : CullPipelines
  basic_instanced : CullPipelines
  lambert_instanced : CullPipelines
  standard_instanced : CullPipelines
  basic_lines : GpuRenderPipeline
  lambert_lines : GpuRenderPipeline
  standard_lines : GpuRenderPipeline
  basic_lines_instanced : GpuRenderPipeline
  lambert_lines_instanced : GpuRenderPipeline
  standard_lines_instanced : GpuRenderPipeline
  points : GpuRenderPipeline
  line_strip : GpuRenderPipeline
  line_list : GpuRenderPipeline
}

///|
priv struct MaskSet {
  forward : MaskCoverage
  reversed : MaskCoverage
}

///|
fn mask_coverage(
  device : GpuDevice,
  pipeline_layout : @gpu.GpuPipelineLayout,
  color_layout : @gpu.GpuPipelineLayout,
  compare : @gpu.GpuCompareFunction,
) -> MaskCoverage {
  let format = @gpu.GpuTextureFormat::RGBA16FLOAT
  let basic_shader = shader_module(device, @nodes.basic_wgsl(), "mask-basic")
  let lambert_shader = shader_module(
    device,
    @nodes.lambert_wgsl(),
    "mask-lambert",
  )
  let standard_shader = shader_module(
    device,
    @nodes.standard_wgsl(),
    "mask-standard",
  )
  let basic_instanced_shader = shader_module(
    device,
    @nodes.basic_instanced_wgsl(),
    "mask-basic-instanced",
  )
  let lambert_instanced_shader = shader_module(
    device,
    @nodes.lambert_instanced_wgsl(),
    "mask-lambert-instanced",
  )
  let standard_instanced_shader = shader_module(
    device,
    @nodes.standard_instanced_wgsl(),
    "mask-standard-instanced",
  )
  let line_shader = shader_module(device, @nodes.line_wgsl(), "mask-line")
  let points_shader = shader_module(device, @nodes.points_wgsl(), "mask-points")
  let cover = fn(shader : GpuShaderModule, instanced : Bool) -> CullPipelines {
    cull_pipelines(
      device,
      shader,
      pipeline_layout,
      format,
      instanced~,
      depth_write=false,
      depth_compare=compare,
      color_write=false,
      stencil=1,
    )
  }
  {
    basic: cover(basic_shader, false),
    lambert: cover(lambert_shader, false),
    standard: cover(standard_shader, false),
    basic_instanced: cover(basic_instanced_shader, true),
    lambert_instanced: cover(lambert_instanced_shader, true),
    standard_instanced: cover(standard_instanced_shader, true),
    basic_lines: unlit_pipeline(
      device,
      basic_shader,
      pipeline_layout,
      format,
      GpuCullMode::NONE,
      lines=true,
      depth_write=false,
      depth_compare=compare,
      color_write=false,
      stencil=1,
    ),
    lambert_lines: unlit_pipeline(
      device,
      lambert_shader,
      pipeline_layout,
      format,
      GpuCullMode::NONE,
      lines=true,
      depth_write=false,
      depth_compare=compare,
      color_write=false,
      stencil=1,
    ),
    standard_lines: unlit_pipeline(
      device,
      standard_shader,
      pipeline_layout,
      format,
      GpuCullMode::NONE,
      lines=true,
      depth_write=false,
      depth_compare=compare,
      color_write=false,
      stencil=1,
    ),
    basic_lines_instanced: unlit_pipeline(
      device,
      basic_instanced_shader,
      pipeline_layout,
      format,
      GpuCullMode::NONE,
      instanced=true,
      lines=true,
      depth_write=false,
      depth_compare=compare,
      color_write=false,
      stencil=1,
    ),
    lambert_lines_instanced: unlit_pipeline(
      device,
      lambert_instanced_shader,
      pipeline_layout,
      format,
      GpuCullMode::NONE,
      instanced=true,
      lines=true,
      depth_write=false,
      depth_compare=compare,
      color_write=false,
      stencil=1,
    ),
    standard_lines_instanced: unlit_pipeline(
      device,
      standard_instanced_shader,
      pipeline_layout,
      format,
      GpuCullMode::NONE,
      instanced=true,
      lines=true,
      depth_write=false,
      depth_compare=compare,
      color_write=false,
      stencil=1,
    ),
    points: color_pipeline(
      device,
      points_shader,
      color_layout,
      format,
      @gpu.GpuPrimitiveTopology::TRIANGLE_LIST,
      true,
      depth_write=false,
      depth_compare=compare,
      color_write=false,
      stencil=1,
    ),
    line_strip: color_pipeline(
      device,
      line_shader,
      color_layout,
      format,
      @gpu.GpuPrimitiveTopology::LINE_STRIP,
      false,
      depth_write=false,
      depth_compare=compare,
      color_write=false,
      stencil=1,
    ),
    line_list: color_pipeline(
      device,
      line_shader,
      color_layout,
      format,
      @gpu.GpuPrimitiveTopology::LINE_LIST,
      false,
      depth_write=false,
      depth_compare=compare,
      color_write=false,
      stencil=1,
    ),
  }
}
