// r186: `VSMPassVertical` https://github.com/mrdoob/three.js/blob/r186/src/nodes/lighting/ShadowNode.js#L37 ; `VSMPassHorizontal` https://github.com/mrdoob/three.js/blob/r186/src/nodes/lighting/ShadowNode.js#L84 ; `VSMShadowFilter` https://github.com/mrdoob/three.js/blob/r186/src/nodes/lighting/ShadowFilterNode.js#L93

///|
struct VsmGpu {
  depth_sampler : GpuSampler
  moment_sampler : GpuSampler
  dummy_texture : GpuTexture
  dummy_view : GpuTextureView
  vertical_layout : GpuBindGroupLayout
  vertical : GpuRenderPipeline
  vertical_uniform : GpuBuffer
  horizontal_layout : GpuBindGroupLayout
  horizontal : GpuRenderPipeline
  horizontal_uniform : GpuBuffer
}

///|
fn vsm_sampler(device : GpuDevice, linear : Bool, label : String) -> GpuSampler {
  let filter = if linear {
    @gpu.GpuFilterMode::LINEAR
  } else {
    @gpu.GpuFilterMode::NEAREST
  }
  device.create_sampler(
    Some({
      address_mode_u: Some(@gpu.GpuAddressMode::CLAMP_TO_EDGE),
      address_mode_v: Some(@gpu.GpuAddressMode::CLAMP_TO_EDGE),
      address_mode_w: None,
      mag_filter: Some(filter),
      min_filter: Some(filter),
      mipmap_filter: Some(@gpu.GpuMipmapFilterMode::NEAREST),
      lod_min_clamp: None,
      lod_max_clamp: None,
      compare: None,
      max_anisotropy: None,
      label: Some(label),
    }),
  )
}

///|
fn vsm_pipeline(
  device : GpuDevice,
  code : String,
  name : String,
  depth : Bool,
) -> (GpuBindGroupLayout, GpuRenderPipeline, GpuBuffer) {
  let sample = if depth {
    @gpu.GpuTextureSampleType::DEPTH
  } else {
    @gpu.GpuTextureSampleType::FLOAT
  }
  let sampler = if depth {
    @gpu.GpuSamplerBindingType::NON_FILTERING
  } else {
    @gpu.GpuSamplerBindingType::FILTERING
  }
  let layout = device.create_bind_group_layout({
    entries: [
      {
        binding: 0U,
        visibility: fragment_visibility(),
        buffer: None,
        sampler: None,
        texture: Some({
          sample_type: Some(sample),
          view_dimension: Some(@gpu.GpuTextureViewDimension::D2),
          multisampled: Some(false),
        }),
        storage_texture: None,
      },
      {
        binding: 1U,
        visibility: fragment_visibility(),
        buffer: None,
        sampler: Some({ type_: Some(sampler), }),
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
      targets: [
        Some({
          format: @gpu.GpuTextureFormat::RG16FLOAT,
          blend: None,
          write_mask: None,
        }),
      ],
      module_: shader,
      entry_point: Some("fs"),
      constants: None,
    }),
    layout: @gpu.Specific(pipeline_layout),
    label: Some(name),
  })
  let uniform = pack_buffer(
    device,
    @common.pack_f32_values([1.0, 1.0, 1.0, 1.0]),
    vertex=false,
    index=false,
    uniform=true,
  )
  (layout, pipeline, uniform)
}

///|
fn make_vsm(device : GpuDevice) -> VsmGpu {
  let dummy_texture = device.create_texture({
    size: { width: 1U, height: Some(1U), depth_or_array_layers: Some(1U), },
    mip_level_count: Some(1U),
    sample_count: Some(1U),
    dimension: Some(@gpu.GpuTextureDimension::D2),
    format: @gpu.GpuTextureFormat::RG16FLOAT,
    usage: flags_color(),
    view_formats: None,
    texture_binding_view_dimension: None,
    label: Some("vsm-dummy"),
  })
  let vertical = vsm_pipeline(
    device,
    @nodes.vsm_vertical_wgsl(),
    "vsm-vertical",
    true,
  )
  let horizontal = vsm_pipeline(
    device,
    @nodes.vsm_horizontal_wgsl(),
    "vsm-horizontal",
    false,
  )
  {
    depth_sampler: vsm_sampler(device, false, "vsm-depth"),
    moment_sampler: vsm_sampler(device, true, "vsm-moment"),
    dummy_texture,
    dummy_view: dummy_texture.create_view(None),
    vertical_layout: vertical.0,
    vertical: vertical.1,
    vertical_uniform: vertical.2,
    horizontal_layout: horizontal.0,
    horizontal: horizontal.1,
    horizontal_uniform: horizontal.2,
  }
}

///|
fn moment_target(
  device : GpuDevice,
  size : UInt32,
  label : String,
) -> (GpuTexture, GpuTextureView) {
  let texture = device.create_texture({
    size: { width: size, height: Some(size), depth_or_array_layers: Some(1U), },
    mip_level_count: Some(1U),
    sample_count: Some(1U),
    dimension: Some(@gpu.GpuTextureDimension::D2),
    format: @gpu.GpuTextureFormat::RG16FLOAT,
    usage: flags_color(),
    view_formats: None,
    texture_binding_view_dimension: None,
    label: Some(label),
  })
  (texture, texture.create_view(None))
}
