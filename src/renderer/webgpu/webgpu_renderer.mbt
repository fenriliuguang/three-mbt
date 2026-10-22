// r186: `WebGPURenderer` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgpu/WebGPURenderer.js#L28 ; `Renderer` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Renderer.js#L55

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
/// 一帧里的网格。深度测试打开时比较来自 `depth_func`，默认 `less-equal`，近平面为 0。关掉后比较改为 `always`。
/// `depth_write` 为假时颜色通道不写深度。`color_write` 为假时颜色通道不写颜色。
/// `reversed_depth` 默认关闭。打开后颜色通道和阴影通道都走反向深度：比较按 `ReversedDepthFuncs` 重映射，投影反转，深度清成 0。阴影采样比较从 `less` 换成 `greater`。
/// `shadow_side` 为空时，正面材质的阴影画背面，背面材质画正面，双面画两面。设了值就按那个面投射。
/// 透明网格用另一组开启混合的管线。`premultiplied_alpha` 打开后，颜色和 alpha 的源因子从 `SrcAlpha` 改成 `One`，目标仍是 `OneMinusSrcAlpha`。关掉时源因子保持 `SrcAlpha`。不透明和线框不混合。阴影通道没有颜色混合。
/// 没有贴图的材质使用一张 1×1 白纹理，因此三种着色器始终采样。
/// r186: `WebGPURenderer` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgpu/WebGPURenderer.js#L28 ; `_getBlending` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgpu/utils/WebGPUPipelineUtils.js#L552 ; shadow pass side https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Renderer.js#L3767
pub struct WebGPURenderer {
  device : GpuDevice
  window : @surface.Surface
  context : @canvas.Context
  format : GpuTextureFormat
  layout : GpuBindGroupLayout
  texture_layout : GpuBindGroupLayout
  surface_layout : GpuBindGroupLayout
  surface_emissive : Array[@textures.Texture?]
  surface_roughness : Array[@textures.Texture?]
  surface_metalness : Array[@textures.Texture?]
  surface_alpha : Array[@textures.Texture?]
  surface_groups : Array[GpuBindGroup]
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
  wave : GpuComputePipeline
  wave_layout : GpuBindGroupLayout
  skin : GpuComputePipeline
  skin_layout : GpuBindGroupLayout
  post : GpuRenderPipeline
  post_layout : GpuBindGroupLayout
  post_uniform : GpuBuffer
  mut post_group : PostGroup?
  tone : GpuRenderPipeline
  tone_layout : GpuBindGroupLayout
  tone_uniform : GpuBuffer
  mut tone_group : PostGroup?
  copy : GpuRenderPipeline
  copy_layout : GpuBindGroupLayout
  copy_uniform : GpuBuffer
  bloom : GpuRenderPipeline
  bloom_layout : GpuBindGroupLayout
  bloom_uniform : GpuBuffer
  bloom_sampler : GpuSampler
  mut bloom_pyramid : BloomPyramid?
  mut bloom_held : Array[GpuBindGroup]
  mut chain_buffers : ChainBuffers?
  mut compose_held : Array[GpuBindGroup]
  quad : GpuBuffer
  white : TextureGpu
  env_layout : GpuBindGroupLayout
  env_black : TextureGpu
  env_fallback : GpuBindGroup
  envs : Array[EnvGpu]
  shadow_layout : GpuBindGroupLayout
  shadow_sampler : GpuSampler
  shadow_sampler_reversed : GpuSampler
  shadow_dummy : GpuBindGroup
  shadow_depth : ShadowPipelines
  shadow_depth_instanced : ShadowPipelines
  shadow_depth_reversed : ShadowPipelines
  shadow_depth_instanced_reversed : ShadowPipelines
  mut shadow_map : ShadowMap?
  mut depth : DepthTarget?
  mut output : @textures.RenderTarget?
  color_targets : Array[ColorTarget]
  geometries : Array[GeometryGpu]
  wireframes : Array[WireGpu]
  positions : Array[PositionGpu]
  instances : Array[InstanceGpu]
  storages : Array[StorageGpu]
  skins : Array[SkinGpu]
  uniforms : Array[ObjectGpu]
  textures : Array[TextureGpu]
  mut swap_width : UInt32
  mut swap_height : UInt32
  mut swapchain_dirty : Bool
  mut reversed_depth : Bool
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
  // 第 3 组八槽：0、1 自发光，2、3 粗糙度，4、5 金属度，6、7 透明贴图。第 1 组仍是两槽颜色贴图。
  // Lambert 和 Basic 不声明用不到的槽，绘制时仍按这个布局绑定。
  let surface_layout = device.create_bind_group_layout({
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
        binding: 5U,
        visibility: fragment_visibility(),
        buffer: None,
        sampler: Some({ type_: Some(@gpu.GpuSamplerBindingType::FILTERING), }),
        texture: None,
        storage_texture: None,
      },
      {
        binding: 6U,
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
        binding: 7U,
        visibility: fragment_visibility(),
        buffer: None,
        sampler: Some({ type_: Some(@gpu.GpuSamplerBindingType::FILTERING), }),
        texture: None,
        storage_texture: None,
      },
    ],
    label: Some("surface"),
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
  let env_layout = device.create_bind_group_layout({
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
    label: Some("env"),
  })
  let pipeline_layout = device.create_pipeline_layout({
    bind_group_layouts: [
      Some(layout),
      Some(texture_layout),
      Some(shadow_layout),
      Some(surface_layout),
      Some(env_layout),
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
  let shadow_sampler_reversed = device.create_sampler(
    Some({
      address_mode_u: Some(@gpu.GpuAddressMode::CLAMP_TO_EDGE),
      address_mode_v: Some(@gpu.GpuAddressMode::CLAMP_TO_EDGE),
      address_mode_w: None,
      mag_filter: Some(@gpu.GpuFilterMode::NEAREST),
      min_filter: Some(@gpu.GpuFilterMode::NEAREST),
      mipmap_filter: Some(@gpu.GpuMipmapFilterMode::NEAREST),
      lod_min_clamp: None,
      lod_max_clamp: None,
      compare: Some(@gpu.GpuCompareFunction::GREATER),
      max_anisotropy: None,
      label: Some("shadow-reversed"),
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
  let skin = skin_pipeline(device)
  let post = fullscreen_pipeline(
    device,
    format,
    @post.grayscale_wgsl(),
    "post",
    @post.pack_amount(1.0),
  )
  let tone = fullscreen_pipeline(
    device,
    format,
    @post.tone_wgsl(),
    "tone",
    @post.pack_tone(@constants.ToneMapping::No, 1.0),
  )
  let copy = fullscreen_pipeline(
    device,
    format,
    @post.copy_wgsl(),
    "copy",
    @post.pack_opacity(1.0),
  )
  let bloom = bloom_pipeline(device, format)
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
  let env_black = upload_texture(
    device,
    texture_layout,
    1,
    1,
    FixedArray::make(4, b'\x00'),
    @constants.ClampToEdge,
    @constants.ClampToEdge,
    @constants.Linear,
    @constants.Linear,
    None,
  )
  let env_fallback_params = pack_buffer(
    device,
    @common.pack_env_params(@math.Matrix4::new(), 0.0, false),
    vertex=false,
    index=false,
    uniform=true,
  )
  let env_fallback = device.create_bind_group({
    layout: env_layout,
    entries: [
      {
        binding: 0U,
        resource: @gpu.GpuBindingResource::GpuTextureView(env_black.view),
      },
      {
        binding: 1U,
        resource: @gpu.GpuBindingResource::GpuSampler(env_black.sampler),
      },
      {
        binding: 2U,
        resource: @gpu.GpuBindingResource::GpuBuffer(env_fallback_params),
      },
    ],
    label: Some("env-fallback"),
  })
  let window = target.window()
  {
    device,
    window,
    context: target.context(),
    format,
    layout,
    texture_layout,
    surface_layout,
    surface_emissive: [],
    surface_roughness: [],
    surface_metalness: [],
    surface_alpha: [],
    surface_groups: [],
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
    wave: wave.1,
    wave_layout: wave.0,
    skin: skin.1,
    skin_layout: skin.0,
    post: post.1,
    post_layout: post.0,
    post_uniform: post.2,
    post_group: None,
    tone: tone.1,
    tone_layout: tone.0,
    tone_uniform: tone.2,
    tone_group: None,
    copy: copy.1,
    copy_layout: copy.0,
    copy_uniform: copy.2,
    bloom: bloom.1,
    bloom_layout: bloom.0,
    bloom_uniform: bloom.2,
    bloom_sampler: bloom.3,
    bloom_pyramid: None,
    bloom_held: [],
    chain_buffers: None,
    compose_held: [],
    quad: pack_buffer(
      device,
      @common.point_quad_bytes(),
      vertex=true,
      index=false,
      uniform=false,
    ),
    white,
    env_layout,
    env_black,
    env_fallback,
    envs: [],
    shadow_layout,
    shadow_sampler,
    shadow_sampler_reversed,
    shadow_dummy,
    shadow_depth: shadow_pipelines(device, shadow_shader, color_layout, false),
    shadow_depth_instanced: shadow_pipelines(
      device, shadow_instanced_shader, color_layout, true,
    ),
    shadow_depth_reversed: shadow_pipelines(
      device,
      shadow_shader,
      color_layout,
      false,
      compare=@gpu.GpuCompareFunction::GREATER,
    ),
    shadow_depth_instanced_reversed: shadow_pipelines(
      device,
      shadow_instanced_shader,
      color_layout,
      true,
      compare=@gpu.GpuCompareFunction::GREATER,
    ),
    shadow_map: None,
    depth: None,
    output: None,
    color_targets: [],
    geometries: [],
    wireframes: [],
    positions: [],
    instances: [],
    storages: [],
    skins: [],
    uniforms: [],
    textures: [],
    swap_width: window.width(),
    swap_height: window.height(),
    swapchain_dirty: false,
    reversed_depth: false,
  }
}

///|
/// 打开后颜色通道使用反向深度。默认关闭，近平面深度仍是 0。
/// r186: `reversedDepthBuffer` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Renderer.js#L62
pub fn WebGPURenderer::set_reversed_depth(
  self : WebGPURenderer,
  enabled : Bool,
) -> Unit {
  self.reversed_depth = enabled
}

///|
fn WebGPURenderer::view_depth_func(
  self : WebGPURenderer,
  depth_func : @constants.DepthFunc,
) -> @constants.DepthFunc {
  if self.reversed_depth {
    depth_func.reversed()
  } else {
    depth_func
  }
}

///|
fn WebGPURenderer::wire_pipeline(
  self : WebGPURenderer,
  shading : @constants.Shading,
  instanced : Bool,
  depth_write : Bool,
  depth_test : Bool,
  depth_func : @constants.DepthFunc,
  color_write : Bool,
) -> GpuRenderPipeline {
  let modes = if instanced {
    match shading {
      @constants.Basic => self.basic_lines_instanced
      @constants.Lambert => self.lambert_lines_instanced
      @constants.Standard => self.standard_lines_instanced
    }
  } else {
    match shading {
      @constants.Basic => self.basic_lines
      @constants.Lambert => self.lambert_lines
      @constants.Standard => self.standard_lines
    }
  }
  modes.pick(depth_write, depth_test, depth_func, color_write)
}

///|
fn WebGPURenderer::ensure_wire(
  self : WebGPURenderer,
  geometry : @core.BufferGeometry,
) -> WireGpu? {
  for cached in self.wireframes {
    if physical_equal(cached.geometry, geometry) {
      return Some(cached)
    }
  }
  let lines = @common.wireframe_line_indices(geometry)
  if lines.length() < 2 {
    return None
  }
  let cached = {
    geometry,
    indices: pack_buffer(
      self.device,
      @common.pack_index_array(lines),
      vertex=false,
      index=true,
      uniform=false,
    ),
    index_count: lines.length(),
  }
  self.wireframes.push(cached)
  Some(cached)
}

///|
fn WebGPURenderer::pipeline(
  self : WebGPURenderer,
  shading : @constants.Shading,
  side : @constants.Side,
  blend : Bool,
  depth_write : Bool,
  depth_test : Bool,
  depth_func : @constants.DepthFunc,
  color_write : Bool,
  premultiplied : Bool,
) -> GpuRenderPipeline {
  self.cull_group(
    shading, side, false, blend, depth_write, depth_test, depth_func, color_write,
    premultiplied,
  )
}

///|
fn WebGPURenderer::instanced_pipeline(
  self : WebGPURenderer,
  shading : @constants.Shading,
  side : @constants.Side,
  blend : Bool,
  depth_write : Bool,
  depth_test : Bool,
  depth_func : @constants.DepthFunc,
  color_write : Bool,
  premultiplied : Bool,
) -> GpuRenderPipeline {
  self.cull_group(
    shading, side, true, blend, depth_write, depth_test, depth_func, color_write,
    premultiplied,
  )
}

///|
fn WebGPURenderer::cull_group(
  self : WebGPURenderer,
  shading : @constants.Shading,
  side : @constants.Side,
  instanced : Bool,
  blend : Bool,
  depth_write : Bool,
  depth_test : Bool,
  depth_func : @constants.DepthFunc,
  color_write : Bool,
  premultiplied : Bool,
) -> GpuRenderPipeline {
  let modes = if blend && premultiplied {
    if instanced {
      match shading {
        @constants.Basic => self.basic_instanced_blend_premul
        @constants.Lambert => self.lambert_instanced_blend_premul
        @constants.Standard => self.standard_instanced_blend_premul
      }
    } else {
      match shading {
        @constants.Basic => self.basic_blend_premul
        @constants.Lambert => self.lambert_blend_premul
        @constants.Standard => self.standard_blend_premul
      }
    }
  } else if blend {
    if instanced {
      match shading {
        @constants.Basic => self.basic_instanced_blend
        @constants.Lambert => self.lambert_instanced_blend
        @constants.Standard => self.standard_instanced_blend
      }
    } else {
      match shading {
        @constants.Basic => self.basic_blend
        @constants.Lambert => self.lambert_blend
        @constants.Standard => self.standard_blend
      }
    }
  } else if instanced {
    match shading {
      @constants.Basic => self.basic_instanced
      @constants.Lambert => self.lambert_instanced
      @constants.Standard => self.standard_instanced
    }
  } else {
    match shading {
      @constants.Basic => self.basic
      @constants.Lambert => self.lambert
      @constants.Standard => self.standard
    }
  }
  let group = modes.pick(depth_write, depth_test, depth_func, color_write)
  match side {
    @constants.Front => group.front
    @constants.Back => group.back
    @constants.Double => group.double
  }
}

///|
fn WebGPURenderer::stroke_pipeline(
  self : WebGPURenderer,
  kind : @core.PrimitiveKind,
  blend : Bool,
  depth_write : Bool,
  depth_test : Bool,
  depth_func : @constants.DepthFunc,
  color_write : Bool,
  premultiplied : Bool,
) -> GpuRenderPipeline {
  let modes = if blend && premultiplied {
    match kind {
      @core.PrimitiveKind::Points => self.points_blend_premul
      @core.PrimitiveKind::Line => self.line_strip_blend_premul
      @core.PrimitiveKind::LineSegments => self.line_list_blend_premul
    }
  } else if blend {
    match kind {
      @core.PrimitiveKind::Points => self.points_blend
      @core.PrimitiveKind::Line => self.line_strip_blend
      @core.PrimitiveKind::LineSegments => self.line_list_blend
    }
  } else {
    match kind {
      @core.PrimitiveKind::Points => self.points
      @core.PrimitiveKind::Line => self.line_strip
      @core.PrimitiveKind::LineSegments => self.line_list
    }
  }
  modes.pick(depth_write, depth_test, depth_func, color_write)
}

///|
fn WebGPURenderer::ensure_depth(
  self : WebGPURenderer,
  width : UInt32,
  height : UInt32,
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
      if cached.version != geometry.version {
        self.upload_geometry(cached, geometry)
      }
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
            color=geometry.get_attribute("color"),
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
          version: geometry.version,
        }
        self.geometries.push(cached)
        Some(cached)
      }
  }
}

///|
fn WebGPURenderer::upload_geometry(
  self : WebGPURenderer,
  cached : GeometryGpu,
  geometry : @core.BufferGeometry,
) -> Unit {
  match geometry.get_attribute("position") {
    None => ()
    Some(position) => {
      ignore(
        self.device
        .queue()
        .write_buffer_with_copy(
          cached.vertices,
          0UL,
          @common.pack_position_normal_uv(
            position,
            geometry.get_attribute("normal"),
            geometry.get_attribute("uv"),
            color=geometry.get_attribute("color"),
          ),
          None,
          None,
        ),
      )
      cached.version = geometry.version
    }
  }
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
/// r186: `compute` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Renderer.js#L2877
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
  draw_start : Int32,
  draw_count : Int32,
) -> Unit {
  ignore(self)
  let full = match geometry.indices {
    Some(_) => geometry.index_count
    None => geometry.vertex_count
  }
  let count_int = if draw_count < 0 { full } else { draw_count }
  if count_int < 2 {
    return
  }
  let (count, first) = mesh_draw(draw_count, draw_start, full)
  pass.set_pipeline(pipeline)
  pass.set_vertex_buffer(0U, Some(geometry.vertices), None, None)
  match geometry.indices {
    None => pass.draw(count, Some(1U), first, None)
    Some(indices) => {
      pass.set_index_buffer(indices, @gpu.GpuIndexFormat::UINT32, None, None)
      pass.draw_indexed(count, Some(1U), first, None, None)
    }
  }
}

///|
fn sync_camera(
  camera : @core.Object3D,
  width : UInt32,
  height : UInt32,
  reversed_depth : Bool,
) -> Unit {
  match camera.camera {
    None => ()
    Some(state) => {
      state.reversed_depth = reversed_depth
      if height != 0U {
        match state.kind {
          @core.Perspective =>
            state.aspect = width.reinterpret_as_int().to_double() /
              height.reinterpret_as_int().to_double()
          @core.Orthographic => ()
        }
      }
      state.update_projection()
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
fn extent(value : Int32) -> UInt32 {
  if value < 1 {
    1U
  } else {
    value.reinterpret_as_uint()
  }
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
    self.drop_surface_groups(source)
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
        match self.textures[found].source {
          Some(cached) => self.drop_surface_groups(cached)
          None => ()
        }
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
/// 纹理重建前丢掉仍引用它的第 3 组。白纹理没有来源，不进这个列表。
fn WebGPURenderer::drop_surface_groups(
  self : WebGPURenderer,
  source : @textures.Texture,
) -> Unit {
  let mut index = 0
  while index < self.surface_groups.length() {
    let emissive_hit = match self.surface_emissive[index] {
      Some(stored) => physical_equal(stored, source)
      None => false
    }
    let roughness_hit = match self.surface_roughness[index] {
      Some(stored) => physical_equal(stored, source)
      None => false
    }
    let metalness_hit = match self.surface_metalness[index] {
      Some(stored) => physical_equal(stored, source)
      None => false
    }
    let alpha_hit = match self.surface_alpha[index] {
      Some(stored) => physical_equal(stored, source)
      None => false
    }
    if emissive_hit || roughness_hit || metalness_hit || alpha_hit {
      self.surface_groups[index].drop()
      let last = self.surface_groups.length() - 1
      self.surface_groups[index] = self.surface_groups[last]
      self.surface_emissive[index] = self.surface_emissive[last]
      self.surface_roughness[index] = self.surface_roughness[last]
      self.surface_metalness[index] = self.surface_metalness[last]
      self.surface_alpha[index] = self.surface_alpha[last]
      ignore(self.surface_groups.pop())
      ignore(self.surface_emissive.pop())
      ignore(self.surface_roughness.pop())
      ignore(self.surface_metalness.pop())
      ignore(self.surface_alpha.pop())
    } else {
      index = index + 1
    }
  }
}

///|
fn WebGPURenderer::texture_views(
  self : WebGPURenderer,
  map : @textures.Texture?,
) -> (GpuTextureView, GpuSampler) {
  match map {
    None => (self.white.view, self.white.sampler)
    Some(source) => {
      if source.attachment {
        match self.output {
          Some(current) =>
            if physical_equal(current.texture, source) {
              return (self.white.view, self.white.sampler)
            }
          None => ()
        }
        let target = self.color_target(source)
        return (target.view, target.sampler)
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
      if found < 0 {
        return (self.white.view, self.white.sampler)
      }
      (self.textures[found].view, self.textures[found].sampler)
    }
  }
}

///|
fn same_texture(left : @textures.Texture?, right : @textures.Texture?) -> Bool {
  match (left, right) {
    (None, None) => true
    (Some(left), Some(right)) => physical_equal(left, right)
    _ => false
  }
}

///|
/// 第 3 组同时绑定自发光、粗糙度、金属度和透明贴图。缺贴图时用 1×1 白纹理，通道为 1。
/// 视图句柄与纹理缓存共用，这里只丢掉绑定组本身。
/// r186: `roughnessFactor` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/roughnessmap_fragment.glsl.js#L9 ; `metalnessFactor` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/metalnessmap_fragment.glsl.js#L9 ; `diffuseColor.a` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/alphamap_fragment.glsl.js#L4
fn WebGPURenderer::surface_group(
  self : WebGPURenderer,
  emissive : @textures.Texture?,
  roughness : @textures.Texture?,
  metalness : @textures.Texture?,
  alpha : @textures.Texture?,
) -> GpuBindGroup {
  ignore(self.texture_group(emissive))
  ignore(self.texture_group(roughness))
  ignore(self.texture_group(metalness))
  ignore(self.texture_group(alpha))
  let mut index = 0
  while index < self.surface_groups.length() {
    if same_texture(self.surface_emissive[index], emissive) &&
      same_texture(self.surface_roughness[index], roughness) &&
      same_texture(self.surface_metalness[index], metalness) &&
      same_texture(self.surface_alpha[index], alpha) {
      return self.surface_groups[index]
    }
    index = index + 1
  }
  let (emissive_view, emissive_sampler) = self.texture_views(emissive)
  let (roughness_view, roughness_sampler) = self.texture_views(roughness)
  let (metalness_view, metalness_sampler) = self.texture_views(metalness)
  let (alpha_view, alpha_sampler) = self.texture_views(alpha)
  let group = self.device.create_bind_group({
    layout: self.surface_layout,
    entries: [
      {
        binding: 0U,
        resource: @gpu.GpuBindingResource::GpuTextureView(emissive_view),
      },
      {
        binding: 1U,
        resource: @gpu.GpuBindingResource::GpuSampler(emissive_sampler),
      },
      {
        binding: 2U,
        resource: @gpu.GpuBindingResource::GpuTextureView(roughness_view),
      },
      {
        binding: 3U,
        resource: @gpu.GpuBindingResource::GpuSampler(roughness_sampler),
      },
      {
        binding: 4U,
        resource: @gpu.GpuBindingResource::GpuTextureView(metalness_view),
      },
      {
        binding: 5U,
        resource: @gpu.GpuBindingResource::GpuSampler(metalness_sampler),
      },
      {
        binding: 6U,
        resource: @gpu.GpuBindingResource::GpuTextureView(alpha_view),
      },
      {
        binding: 7U,
        resource: @gpu.GpuBindingResource::GpuSampler(alpha_sampler),
      },
    ],
    label: Some("surface"),
  })
  self.surface_emissive.push(emissive)
  self.surface_roughness.push(roughness)
  self.surface_metalness.push(metalness)
  self.surface_alpha.push(alpha)
  self.surface_groups.push(group)
  group
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
  size : Int32,
) -> ShadowMap {
  let extent = if size < 1 { 1U } else { size.reinterpret_as_uint() }
  let reversed = self.reversed_depth
  match self.shadow_map {
    Some(map) =>
      if map.size == extent && map.reversed == reversed {
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
        resource: @gpu.GpuBindingResource::GpuSampler(
          if reversed {
            self.shadow_sampler_reversed
          } else {
            self.shadow_sampler
          },
        ),
      },
    ],
    label: Some("shadow"),
  })
  let map = { texture, view, group, size: extent, reversed, }
  self.shadow_map = Some(map)
  map
}

///|
/// 分组范围。`group_count` 小于 0 时画全部。
/// r186: `getDrawParameters` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderObject.js#L603
fn mesh_draw(
  group_count : Int32,
  group_start : Int32,
  full : Int32,
) -> (UInt32, UInt32?) {
  if group_count < 0 {
    (full.reinterpret_as_uint(), None)
  } else {
    (group_count.reinterpret_as_uint(), Some(group_start.reinterpret_as_uint()))
  }
}

///|
fn storage_bytes(
  bytes : FixedArray[Byte],
  fallback : Int32,
) -> FixedArray[Byte] {
  if bytes.length() == 0 {
    FixedArray::make(fallback, b'\x00')
  } else {
    bytes
  }
}

///|
fn make_storage(device : GpuDevice, bytes : FixedArray[Byte]) -> GpuBuffer {
  let buffer = device.create_buffer({
    size: bytes.length().to_uint64(),
    usage: flags_storage_vertex(),
    mapped_at_creation: None,
    label: Some("skin"),
  })
  ignore(device.queue().write_buffer_with_copy(buffer, 0UL, bytes, None, None))
  buffer
}

///|
fn WebGPURenderer::skin_slot(
  self : WebGPURenderer,
  node : @core.Object3D,
) -> Int32? {
  let mut index = 0
  while index < self.skins.length() {
    if physical_equal(self.skins[index].node, node) {
      return Some(index)
    }
    index = index + 1
  }
  None
}

///|
fn WebGPURenderer::mesh_vertices(
  self : WebGPURenderer,
  node : @core.Object3D,
  instanced : Bool,
  lines : Bool,
  fallback : GpuBuffer,
) -> GpuBuffer {
  if lines || instanced {
    return fallback
  }
  match self.skin_slot(node) {
    None => fallback
    Some(index) => self.skins[index].output
  }
}

///|
/// 非实例三角形在绘制前从绑定姿态做一次计算蒙皮。实例、线和点仍用 CPU 改过的顶点。
/// r186: `compute` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Renderer.js#L2877
fn WebGPURenderer::prepare_skins(
  self : WebGPURenderer,
  root : @core.Object3D,
) -> Unit {
  let pending = [root]
  let mut index = 0
  while index < pending.length() {
    let node = pending[index]
    match node.skin {
      None => ()
      Some(skin) =>
        match node.mesh {
          None => ()
          Some(binding) =>
            match binding.instances {
              Some(_) => ()
              None => self.dispatch_skin(node, skin, binding.geometry)
            }
        }
    }
    let mut child = 0
    while child < node.children.length() {
      pending.push(node.children[child])
      child = child + 1
    }
    index = index + 1
  }
}

///|
fn WebGPURenderer::dispatch_skin(
  self : WebGPURenderer,
  node : @core.Object3D,
  skin : @core.SkinState,
  geometry : @core.BufferGeometry,
) -> Unit {
  let positions = skin.source_position(node)
  let count = positions.length() / 3
  if count < 1 {
    return
  }
  let normal = match skin.source_normal(node) {
    None => None
    Some(values) => Some(@core.BufferAttribute::new(values, 3))
  }
  let source_bytes = @common.pack_position_normal_uv(
    @core.BufferAttribute::new(positions, 3),
    normal,
    geometry.get_attribute("uv"),
    color=geometry.get_attribute("color"),
  )
  let bones = skin.bone_palette()
  let bone_bytes = storage_bytes(@common.pack_matrices(bones), 64)
  let joint_bytes = storage_bytes(@common.pack_u32_values(skin.indices), 4)
  let weight_bytes = storage_bytes(@common.pack_f32_values(skin.weights), 4)
  let bind_inverse = @math.Matrix4::new()
  ignore(bind_inverse.copy(node.matrix_world).invert())
  let params = @common.pack_skin_params(
    bind_inverse,
    count,
    bones.length(),
    skin.influence_width(),
    normal is Some(_),
  )
  let gpu = self.ensure_skin(
    node, source_bytes, bone_bytes, joint_bytes, weight_bytes, params, count,
  )
  ignore(
    self.device
    .queue()
    .write_buffer_with_copy(gpu.source, 0UL, source_bytes, None, None),
  )
  ignore(
    self.device
    .queue()
    .write_buffer_with_copy(gpu.output, 0UL, source_bytes, None, None),
  )
  ignore(
    self.device
    .queue()
    .write_buffer_with_copy(gpu.bones, 0UL, bone_bytes, None, None),
  )
  ignore(
    self.device
    .queue()
    .write_buffer_with_copy(gpu.joints, 0UL, joint_bytes, None, None),
  )
  ignore(
    self.device
    .queue()
    .write_buffer_with_copy(gpu.weights, 0UL, weight_bytes, None, None),
  )
  ignore(
    self.device
    .queue()
    .write_buffer_with_copy(gpu.params, 0UL, params, None, None),
  )
  let groups = @compute.workgroup_count(count)
  if groups < 1 {
    return
  }
  let encoder = self.device.create_command_encoder(None)
  let pass = encoder.begin_compute_pass(None)
  pass.set_pipeline(self.skin)
  ignore(pass.set_bind_group(0U, Some(gpu.group), None, None, None))
  pass.dispatch_workgroups(groups.reinterpret_as_uint(), None, None)
  pass.end()
  self.device.queue().submit([encoder.finish(None)])
}

///|
fn WebGPURenderer::ensure_skin(
  self : WebGPURenderer,
  node : @core.Object3D,
  source_bytes : FixedArray[Byte],
  bone_bytes : FixedArray[Byte],
  joint_bytes : FixedArray[Byte],
  weight_bytes : FixedArray[Byte],
  params : FixedArray[Byte],
  vertex_count : Int32,
) -> SkinGpu {
  let fits = fn(cached : SkinGpu) -> Bool {
    cached.vertex_count == vertex_count &&
    cached.bone_bytes == bone_bytes.length() &&
    cached.joint_bytes == joint_bytes.length() &&
    cached.weight_bytes == weight_bytes.length()
  }
  match self.skin_slot(node) {
    Some(index) => if fits(self.skins[index]) { return self.skins[index] }
    None => ()
  }
  let source = make_storage(self.device, source_bytes)
  let output = make_storage(self.device, source_bytes)
  let bones = make_storage(self.device, bone_bytes)
  let joints = make_storage(self.device, joint_bytes)
  let weights = make_storage(self.device, weight_bytes)
  let uniform = pack_buffer(
    self.device,
    params,
    vertex=false,
    index=false,
    uniform=true,
  )
  let group = self.device.create_bind_group({
    layout: self.skin_layout,
    entries: [
      { binding: 0U, resource: @gpu.GpuBindingResource::GpuBuffer(source), },
      { binding: 1U, resource: @gpu.GpuBindingResource::GpuBuffer(output), },
      { binding: 2U, resource: @gpu.GpuBindingResource::GpuBuffer(bones), },
      { binding: 3U, resource: @gpu.GpuBindingResource::GpuBuffer(joints), },
      { binding: 4U, resource: @gpu.GpuBindingResource::GpuBuffer(weights), },
      { binding: 5U, resource: @gpu.GpuBindingResource::GpuBuffer(uniform), },
    ],
    label: Some("skin"),
  })
  let cached = {
    node,
    source,
    output,
    bones,
    joints,
    weights,
    params: uniform,
    group,
    vertex_count,
    bone_bytes: bone_bytes.length(),
    joint_bytes: joint_bytes.length(),
    weight_bytes: weight_bytes.length(),
  }
  match self.skin_slot(node) {
    Some(index) => self.skins[index] = cached
    None => self.skins.push(cached)
  }
  cached
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
      depth_clear_value: Some(
        if self.reversed_depth {
          Float::from_int(0)
        } else {
          Float::from_int(1)
        },
      ),
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
  let items = @common.collect_shadow(scene.node, camera=shadow.camera)
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
        let shadow_group = if self.reversed_depth {
          match batch {
            Some(_) => self.shadow_depth_instanced_reversed
            None => self.shadow_depth_reversed
          }
        } else {
          match batch {
            Some(_) => self.shadow_depth_instanced
            None => self.shadow_depth
          }
        }
        pass.set_pipeline(
          match @common.shadow_cast_side(item.side, item.shadow_side) {
            @constants.Back => shadow_group.back
            @constants.Front => shadow_group.front
            @constants.Double => shadow_group.double
          },
        )
        pass.set_vertex_buffer(
          0U,
          Some(
            self.mesh_vertices(
              item.node,
              item.instances is Some(_),
              false,
              geometry.vertices,
            ),
          ),
          None,
          None,
        )
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
          None => {
            let (count, first) = mesh_draw(
              item.group_count,
              item.group_start,
              geometry.vertex_count,
            )
            pass.draw(
              count,
              Some(instance_count.reinterpret_as_uint()),
              first,
              None,
            )
          }
          Some(indices) => {
            pass.set_index_buffer(
              indices,
              @gpu.GpuIndexFormat::UINT32,
              None,
              None,
            )
            let (count, first) = mesh_draw(
              item.group_count,
              item.group_start,
              geometry.index_count,
            )
            pass.draw_indexed(
              count,
              Some(instance_count.reinterpret_as_uint()),
              first,
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
/// r186: `setRenderTarget` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Renderer.js#L2737
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
fn WebGPURenderer::tone_bind(
  self : WebGPURenderer,
  source : @textures.Texture,
) -> GpuBindGroup {
  let frame = self.color_target(source)
  match self.tone_group {
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
    layout: self.tone_layout,
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
        resource: @gpu.GpuBindingResource::GpuBuffer(self.tone_uniform),
      },
    ],
    label: Some("tone"),
  })
  self.tone_group = Some({
    source,
    version: source.version,
    width: frame.width,
    height: frame.height,
    group,
  })
  group
}

///|
fn WebGPURenderer::bloom_color(
  self : WebGPURenderer,
  width : UInt32,
  height : UInt32,
  format : GpuTextureFormat,
  label : String,
) -> (GpuTexture, GpuTextureView) {
  let texture = self.device.create_texture({
    size: { width, height: Some(height), depth_or_array_layers: Some(1U), },
    mip_level_count: Some(1U),
    sample_count: Some(1U),
    dimension: Some(@gpu.GpuTextureDimension::D2),
    format,
    usage: flags_color(),
    view_formats: None,
    texture_binding_view_dimension: None,
    label: Some(label),
  })
  (texture, texture.create_view(None))
}

///|
fn WebGPURenderer::ensure_bloom(
  self : WebGPURenderer,
  width : UInt32,
  height : UInt32,
) -> BloomPyramid {
  match self.bloom_pyramid {
    Some(cached) =>
      if cached.width == width && cached.height == height {
        return cached
      } else {
        drop_bloom(cached)
      }
    None => ()
  }
  let bright = self.bloom_color(
    width,
    height,
    @gpu.GpuTextureFormat::RGBA16FLOAT,
    "bloom-bright",
  )
  let levels : Array[BloomLevel] = []
  let mut level = 0
  let mut mip_w = width.reinterpret_as_int()
  let mut mip_h = height.reinterpret_as_int()
  if mip_w < 1 {
    mip_w = 1
  }
  if mip_h < 1 {
    mip_h = 1
  }
  while level < 5 {
    let wu = mip_w.reinterpret_as_uint()
    let hu = mip_h.reinterpret_as_uint()
    let horizontal = self.bloom_color(
      wu,
      hu,
      @gpu.GpuTextureFormat::RGBA16FLOAT,
      "bloom-h",
    )
    let vertical = self.bloom_color(
      wu,
      hu,
      @gpu.GpuTextureFormat::RGBA16FLOAT,
      "bloom-v",
    )
    levels.push({
      width: wu,
      height: hu,
      h_texture: horizontal.0,
      h_view: horizontal.1,
      v_texture: vertical.0,
      v_view: vertical.1,
    })
    mip_w = mip_w / 2
    mip_h = mip_h / 2
    if mip_w < 1 {
      mip_w = 1
    }
    if mip_h < 1 {
      mip_h = 1
    }
    level = level + 1
  }
  let acc = self.bloom_color(
    width,
    height,
    @gpu.GpuTextureFormat::RGBA16FLOAT,
    "bloom-acc",
  )
  let acc2 = self.bloom_color(
    width,
    height,
    @gpu.GpuTextureFormat::RGBA16FLOAT,
    "bloom-acc2",
  )
  let pyramid : BloomPyramid = {
    width,
    height,
    bright_texture: bright.0,
    bright_view: bright.1,
    levels,
    acc_texture: acc.0,
    acc_view: acc.1,
    acc2_texture: acc2.0,
    acc2_view: acc2.1,
  }
  self.bloom_pyramid = Some(pyramid)
  pyramid
}

///|
fn WebGPURenderer::bloom_release(self : WebGPURenderer) -> Unit {
  let mut index = 0
  while index < self.bloom_held.length() {
    self.bloom_held[index].drop()
    index = index + 1
  }
  self.bloom_held = []
}

///|
fn WebGPURenderer::bloom_group(
  self : WebGPURenderer,
  color : GpuTextureView,
  glow : GpuTextureView,
) -> GpuBindGroup {
  let group = self.device.create_bind_group({
    layout: self.bloom_layout,
    entries: [
      { binding: 0U, resource: @gpu.GpuBindingResource::GpuTextureView(color), },
      {
        binding: 1U,
        resource: @gpu.GpuBindingResource::GpuSampler(self.bloom_sampler),
      },
      { binding: 2U, resource: @gpu.GpuBindingResource::GpuTextureView(glow), },
      {
        binding: 3U,
        resource: @gpu.GpuBindingResource::GpuSampler(self.bloom_sampler),
      },
      {
        binding: 4U,
        resource: @gpu.GpuBindingResource::GpuBuffer(self.bloom_uniform),
      },
    ],
    label: Some("bloom"),
  })
  self.bloom_held.push(group)
  group
}

///|
fn WebGPURenderer::bloom_submit(
  self : WebGPURenderer,
  pass : @post.BloomPass,
  texel_x : Double,
  texel_y : Double,
  dir_x : Double,
  dir_y : Double,
  mode : Double,
  kernel : Double,
  factor : Double,
  tint_level : Int32,
  color : GpuTextureView,
  glow : GpuTextureView,
  target : GpuTextureView,
) -> Unit {
  let tint_index = if tint_level < 0 {
    0
  } else if tint_level > 4 {
    4
  } else {
    tint_level
  }
  ignore(
    self.device
    .queue()
    .write_buffer_with_copy(
      self.bloom_uniform,
      0UL,
      @post.pack_bloom(
        pass,
        texel_x,
        texel_y,
        dir_x,
        dir_y,
        mode,
        kernel~,
        factor~,
        tint_r=pass.tint_r[tint_index],
        tint_g=pass.tint_g[tint_index],
        tint_b=pass.tint_b[tint_index],
      ),
      None,
      None,
    ),
  )
  let group = self.bloom_group(color, glow)
  let encoder = self.device.create_command_encoder(None)
  let draw = encoder.begin_render_pass({
    color_attachments: [
      Some({
        view: target,
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
    label: Some("bloom"),
  })
  draw.set_pipeline(self.bloom)
  ignore(draw.set_bind_group(0U, Some(group), None, None, None))
  draw.draw(3U, Some(1U), None, None)
  draw.end()
  self.device.queue().submit([encoder.finish(None)])
}

///|
/// 高通之后逐级模糊，再把五级光累加。返回累加结果，不画到最终目标。
fn WebGPURenderer::bloom_prepare(
  self : WebGPURenderer,
  source : GpuTextureView,
  width : UInt32,
  height : UInt32,
  pass : @post.BloomPass,
) -> GpuTextureView {
  let base_w = @post.bloom_scaled_size(
    width.reinterpret_as_int(),
    0,
    pass.resolution_scale,
  )
  let base_h = @post.bloom_scaled_size(
    height.reinterpret_as_int(),
    0,
    pass.resolution_scale,
  )
  let pyramid = self.ensure_bloom(
    base_w.reinterpret_as_uint(),
    base_h.reinterpret_as_uint(),
  )
  let full_x = 1.0 / base_w.to_double()
  let full_y = 1.0 / base_h.to_double()
  self.bloom_submit(
    pass,
    full_x,
    full_y,
    0.0,
    0.0,
    0.0,
    6.0,
    1.0,
    0,
    source,
    source,
    pyramid.bright_view,
  )
  let mut input = pyramid.bright_view
  let mut level = 0
  while level < 5 {
    let mip = pyramid.levels[level]
    let texel_x = 1.0 / mip.width.reinterpret_as_int().to_double()
    let texel_y = 1.0 / mip.height.reinterpret_as_int().to_double()
    let kernel = @post.bloom_kernel_radius(level).to_double()
    self.bloom_submit(
      pass,
      texel_x,
      texel_y,
      1.0,
      0.0,
      1.0,
      kernel,
      1.0,
      0,
      input,
      input,
      mip.h_view,
    )
    self.bloom_submit(
      pass,
      texel_x,
      texel_y,
      0.0,
      1.0,
      1.0,
      kernel,
      1.0,
      0,
      mip.h_view,
      mip.h_view,
      mip.v_view,
    )
    input = mip.v_view
    level = level + 1
  }
  let factor = fn(index : Int32) -> Double {
    match index {
      0 => 1.0
      1 => 0.8
      2 => 0.6
      3 => 0.4
      _ => 0.2
    }
  }
  self.bloom_submit(
    pass,
    0.0,
    0.0,
    0.0,
    0.0,
    3.0,
    6.0,
    factor(0),
    0,
    pyramid.levels[0].v_view,
    pyramid.levels[0].v_view,
    pyramid.acc_view,
  )
  level = 1
  let mut in_acc = true
  while level < 5 {
    let glow = pyramid.levels[level].v_view
    if in_acc {
      self.bloom_submit(
        pass,
        0.0,
        0.0,
        0.0,
        0.0,
        4.0,
        6.0,
        factor(level),
        level,
        pyramid.acc_view,
        glow,
        pyramid.acc2_view,
      )
    } else {
      self.bloom_submit(
        pass,
        0.0,
        0.0,
        0.0,
        0.0,
        4.0,
        6.0,
        factor(level),
        level,
        pyramid.acc2_view,
        glow,
        pyramid.acc_view,
      )
    }
    in_acc = !in_acc
    level = level + 1
  }
  if in_acc {
    pyramid.acc_view
  } else {
    pyramid.acc2_view
  }
}

///|
/// 把已经加权的五级光加回 `source`，画进 `target`。
fn WebGPURenderer::bloom_to(
  self : WebGPURenderer,
  source : GpuTextureView,
  width : UInt32,
  height : UInt32,
  pass : @post.BloomPass,
  target : GpuTextureView,
) -> Unit {
  let glow = self.bloom_prepare(source, width, height, pass)
  self.bloom_submit(
    pass, 0.0, 0.0, 0.0, 0.0, 5.0, 6.0, 1.0, 0, source, glow, target,
  )
}

///|
fn WebGPURenderer::ensure_chain(
  self : WebGPURenderer,
  width : UInt32,
  height : UInt32,
) -> ChainBuffers {
  match self.chain_buffers {
    Some(cached) =>
      if cached.width == width && cached.height == height {
        return cached
      } else {
        drop_chain(cached)
      }
    None => ()
  }
  let a = self.bloom_color(width, height, self.format, "compose-a")
  let b = self.bloom_color(width, height, self.format, "compose-b")
  let buffers : ChainBuffers = {
    width,
    height,
    a_texture: a.0,
    a_view: a.1,
    b_texture: b.0,
    b_view: b.1,
  }
  self.chain_buffers = Some(buffers)
  buffers
}

///|
fn WebGPURenderer::compose_release(self : WebGPURenderer) -> Unit {
  let mut index = 0
  while index < self.compose_held.length() {
    self.compose_held[index].drop()
    index = index + 1
  }
  self.compose_held = []
}

///|
fn WebGPURenderer::compose_group(
  self : WebGPURenderer,
  layout : GpuBindGroupLayout,
  uniform : GpuBuffer,
  view : GpuTextureView,
) -> GpuBindGroup {
  let group = self.device.create_bind_group({
    layout,
    entries: [
      { binding: 0U, resource: @gpu.GpuBindingResource::GpuTextureView(view), },
      {
        binding: 1U,
        resource: @gpu.GpuBindingResource::GpuSampler(self.bloom_sampler),
      },
      { binding: 2U, resource: @gpu.GpuBindingResource::GpuBuffer(uniform), },
    ],
    label: Some("compose"),
  })
  self.compose_held.push(group)
  group
}

///|
fn WebGPURenderer::submit_fullscreen(
  self : WebGPURenderer,
  pipeline : GpuRenderPipeline,
  group : GpuBindGroup,
  view : GpuTextureView,
  label : String,
) -> Unit {
  let encoder = self.device.create_command_encoder(None)
  let draw = encoder.begin_render_pass({
    color_attachments: [
      Some({
        view,
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
    label: Some(label),
  })
  draw.set_pipeline(pipeline)
  ignore(draw.set_bind_group(0U, Some(group), None, None, None))
  draw.draw(3U, Some(1U), None, None)
  draw.end()
  self.device.queue().submit([encoder.finish(None)])
}

///|
fn WebGPURenderer::compose_effect(
  self : WebGPURenderer,
  effect : @post.ComposerEffect,
  read : GpuTextureView,
  target : GpuTextureView,
  width : UInt32,
  height : UInt32,
) -> Unit {
  match effect {
    @post.Grayscale(pass) => {
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
      let group = self.compose_group(self.post_layout, self.post_uniform, read)
      self.submit_fullscreen(self.post, group, target, "compose")
    }
    @post.Tone(pass) => {
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
      let group = self.compose_group(self.tone_layout, self.tone_uniform, read)
      self.submit_fullscreen(self.tone, group, target, "compose")
    }
    @post.Copy(pass) => {
      ignore(
        self.device
        .queue()
        .write_buffer_with_copy(
          self.copy_uniform,
          0UL,
          @post.pack_opacity(pass.opacity),
          None,
          None,
        ),
      )
      let group = self.compose_group(self.copy_layout, self.copy_uniform, read)
      self.submit_fullscreen(self.copy, group, target, "compose")
    }
    @post.Bloom(pass) => self.bloom_to(read, width, height, pass, target)
  }
}

///|
fn chosen_env(
  material_map : @textures.Texture?,
  scene_map : @textures.Texture?,
) -> @textures.Texture? {
  match material_map {
    Some(map) => Some(map)
    None => scene_map
  }
}

///|
fn WebGPURenderer::make_env_group(
  self : WebGPURenderer,
  view : GpuTextureView,
  sampler : GpuSampler,
  params : GpuBuffer,
) -> GpuBindGroup {
  self.device.create_bind_group({
    layout: self.env_layout,
    entries: [
      { binding: 0U, resource: @gpu.GpuBindingResource::GpuTextureView(view), },
      { binding: 1U, resource: @gpu.GpuBindingResource::GpuSampler(sampler), },
      { binding: 2U, resource: @gpu.GpuBindingResource::GpuBuffer(params), },
    ],
    label: Some("env"),
  })
}

///|
fn WebGPURenderer::release_env_atlas(
  self : WebGPURenderer,
  atlas : @textures.Texture,
) -> Unit {
  let mut index = 0
  while index < self.textures.length() {
    let hit = match self.textures[index].source {
      Some(stored) => physical_equal(stored, atlas)
      None => false
    }
    if hit {
      drop_texture(self.textures[index])
      let last = self.textures.length() - 1
      self.textures[index] = self.textures[last]
      ignore(self.textures.pop())
    } else {
      index = index + 1
    }
  }
}

///|
/// Standard 按节点缓存 PMREM。贴图对象或 `version` 变了就重建图集。强度和旋转每次重写 uniform。
fn WebGPURenderer::bind_env(
  self : WebGPURenderer,
  node : @core.Object3D,
  source : @textures.Texture,
  intensity : Double,
  rotation : @math.Matrix4,
) -> GpuBindGroup {
  let mut found = -1
  let mut index = 0
  while index < self.envs.length() {
    if physical_equal(self.envs[index].node, node) {
      found = index
    }
    index = index + 1
  }
  let current = if found < 0 {
    let atlas = @materials.pmrem_atlas(source)
    ignore(self.texture_group(Some(atlas)))
    let (view, sampler) = self.texture_views(Some(atlas))
    let params = pack_buffer(
      self.device,
      @common.pack_env_params(rotation, intensity, true),
      vertex=false,
      index=false,
      uniform=true,
    )
    let group = self.make_env_group(view, sampler, params)
    let created : EnvGpu = {
      node,
      atlas,
      source,
      version: source.version,
      params,
      group,
    }
    self.envs.push(created)
    created
  } else {
    let cached = self.envs[found]
    if physical_equal(cached.source, source) && cached.version == source.version {
      cached
    } else {
      self.release_env_atlas(cached.atlas)
      cached.group.drop()
      let atlas = @materials.pmrem_atlas(source)
      ignore(self.texture_group(Some(atlas)))
      let (view, sampler) = self.texture_views(Some(atlas))
      let group = self.make_env_group(view, sampler, cached.params)
      let updated : EnvGpu = {
        node,
        atlas,
        source,
        version: source.version,
        params: cached.params,
        group,
      }
      self.envs[found] = updated
      updated
    }
  }
  ignore(
    self.device
    .queue()
    .write_buffer_with_copy(
      current.params,
      0UL,
      @common.pack_env_params(rotation, intensity, true),
      None,
      None,
    ),
  )
  current.group
}

///|
/// 先画不透明网格，再按从远到近画透明网格。`blend` 为真时用 src-alpha 管线。
/// 透明双面且 `force_single_pass` 关闭时，同一次绘制里先画背面再画正面。
/// Standard 绑定第 4 组环境贴图。其它着色绑定黑色的空环境。
fn WebGPURenderer::draw_meshes(
  self : WebGPURenderer,
  pass : @gpu.GpuRenderPassEncoder,
  items : Array[@common.RenderItem],
  camera : @core.Object3D,
  state : @core.CameraState,
  lights : @common.LightFrame,
  fog : @scenes.Fog?,
  width : UInt32,
  height : UInt32,
  shadow_group : GpuBindGroup,
  environment : @textures.Texture?,
  blend : Bool,
  lines~ : Bool = false,
) -> Unit {
  for item in items {
    let draw_mesh = match item.instances {
      Some(data) => data.count > 0
      None => true
    }
    if !draw_mesh {
      continue
    }
    let wire = if lines { self.ensure_wire(item.geometry) } else { None }
    if lines && wire is None {
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
          alpha_test=item.alpha_test,
          side=match item.side {
            @constants.Front => 0.0
            @constants.Back => -1.0
            @constants.Double => 1.0
          },
          emissive_r=item.emissive.r,
          emissive_g=item.emissive.g,
          emissive_b=item.emissive.b,
          emissive_intensity=item.emissive_intensity,
          flat_shading=if item.flat_shading { 1.0 } else { 0.0 },
          point_x=lights.point_position.x,
          point_y=lights.point_position.y,
          point_z=lights.point_position.z,
          point_r=lights.point_color.x,
          point_g=lights.point_color.y,
          point_b=lights.point_color.z,
          point_distance=lights.point_distance,
          point_decay=lights.point_decay,
          point_enabled=lights.point_enabled,
          spot_x=lights.spot_position.x,
          spot_y=lights.spot_position.y,
          spot_z=lights.spot_position.z,
          spot_dx=lights.spot_direction.x,
          spot_dy=lights.spot_direction.y,
          spot_dz=lights.spot_direction.z,
          spot_r=lights.spot_color.x,
          spot_g=lights.spot_color.y,
          spot_b=lights.spot_color.z,
          spot_distance=lights.spot_distance,
          spot_decay=lights.spot_decay,
          spot_cone_cos=lights.spot_cone_cos,
          spot_penumbra_cos=lights.spot_penumbra_cos,
          spot_enabled=lights.spot_enabled,
          hemisphere_sky_r=lights.hemisphere_sky.x,
          hemisphere_sky_g=lights.hemisphere_sky.y,
          hemisphere_sky_b=lights.hemisphere_sky.z,
          hemisphere_ground_r=lights.hemisphere_ground.x,
          hemisphere_ground_g=lights.hemisphere_ground.y,
          hemisphere_ground_b=lights.hemisphere_ground.z,
          hemisphere_x=lights.hemisphere_direction.x,
          hemisphere_y=lights.hemisphere_direction.y,
          hemisphere_z=lights.hemisphere_direction.z,
          hemisphere_enabled=lights.hemisphere_enabled,
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
        let sides = @common.color_sides(
          item.side,
          blend,
          lines,
          item.force_single_pass,
        )
        for side in sides {
          pass.set_pipeline(
            if lines {
              self.wire_pipeline(
                item.shading,
                batch is Some(_),
                item.depth_write,
                item.depth_test,
                self.view_depth_func(item.depth_func),
                item.color_write,
              )
            } else {
              match batch {
                Some(_) =>
                  self.instanced_pipeline(
                    item.shading,
                    side,
                    blend,
                    item.depth_write,
                    item.depth_test,
                    self.view_depth_func(item.depth_func),
                    item.color_write,
                    item.premultiplied_alpha,
                  )
                None =>
                  self.pipeline(
                    item.shading,
                    side,
                    blend,
                    item.depth_write,
                    item.depth_test,
                    self.view_depth_func(item.depth_func),
                    item.color_write,
                    item.premultiplied_alpha,
                  )
              }
            },
          )
          pass.set_vertex_buffer(
            0U,
            Some(
              self.mesh_vertices(
                item.node,
                item.instances is Some(_),
                lines,
                geometry.vertices,
              ),
            ),
            None,
            None,
          )
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
          ignore(
            pass.set_bind_group(
              3U,
              Some(
                self.surface_group(
                  item.emissive_map,
                  item.roughness_map,
                  item.metalness_map,
                  item.alpha_map,
                ),
              ),
              None,
              None,
              None,
            ),
          )
          let env_group = match item.shading {
            @constants.Standard =>
              match chosen_env(item.env_map, environment) {
                None => self.env_fallback
                Some(map) =>
                  self.bind_env(
                    item.node,
                    map,
                    item.env_map_intensity,
                    item.env_rotation,
                  )
              }
            _ => self.env_fallback
          }
          ignore(pass.set_bind_group(4U, Some(env_group), None, None, None))
          if lines {
            match wire {
              None => ()
              Some(wire) => {
                pass.set_index_buffer(
                  wire.indices,
                  @gpu.GpuIndexFormat::UINT32,
                  None,
                  None,
                )
                let (count, first) = mesh_draw(
                  item.group_count,
                  item.group_start,
                  wire.index_count,
                )
                pass.draw_indexed(
                  count,
                  Some(instance_count.reinterpret_as_uint()),
                  first,
                  None,
                  None,
                )
              }
            }
          } else {
            match geometry.indices {
              None => {
                let (count, first) = mesh_draw(
                  item.group_count,
                  item.group_start,
                  geometry.vertex_count,
                )
                pass.draw(
                  count,
                  Some(instance_count.reinterpret_as_uint()),
                  first,
                  None,
                )
              }
              Some(indices) => {
                pass.set_index_buffer(
                  indices,
                  @gpu.GpuIndexFormat::UINT32,
                  None,
                  None,
                )
                let (count, first) = mesh_draw(
                  item.group_count,
                  item.group_start,
                  geometry.index_count,
                )
                pass.draw_indexed(
                  count,
                  Some(instance_count.reinterpret_as_uint()),
                  first,
                  None,
                  None,
                )
              }
            }
          }
        }
      }
    }
  }
}

///|
/// 点和线。`blend` 为真时混合。`premultiplied_alpha` 打开后源因子是 `One`，否则是 `SrcAlpha`。目标都是 `OneMinusSrcAlpha`。
fn WebGPURenderer::draw_strokes(
  self : WebGPURenderer,
  pass : @gpu.GpuRenderPassEncoder,
  items : Array[@common.PrimitiveItem],
  camera : @core.Object3D,
  state : @core.CameraState,
  lights : @common.LightFrame,
  fog : @scenes.Fog?,
  viewport_width : Double,
  viewport_height : Double,
  blend : Bool,
) -> Unit {
  for item in items {
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
          alpha_test=item.alpha_test,
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
            let instance_count = if item.draw_count < 0 {
              geometry.point_count
            } else {
              item.draw_count
            }
            if instance_count > 0 {
              pass.set_pipeline(
                self.stroke_pipeline(
                  item.kind,
                  blend,
                  item.depth_write,
                  item.depth_test,
                  self.view_depth_func(item.depth_func),
                  item.color_write,
                  item.premultiplied_alpha,
                ),
              )
              pass.set_vertex_buffer(0U, Some(self.quad), None, None)
              pass.set_vertex_buffer(1U, Some(instances), None, None)
              let first_instance = if item.draw_count < 0 {
                None
              } else {
                Some(item.draw_start.reinterpret_as_uint())
              }
              pass.draw(
                6U,
                Some(instance_count.reinterpret_as_uint()),
                None,
                first_instance,
              )
            }
          }
          @core.PrimitiveKind::Line =>
            self.draw_lines(
              pass,
              self.stroke_pipeline(
                item.kind,
                blend,
                item.depth_write,
                item.depth_test,
                self.view_depth_func(item.depth_func),
                item.color_write,
                item.premultiplied_alpha,
              ),
              geometry,
              item.draw_start,
              item.draw_count,
            )
          @core.PrimitiveKind::LineSegments =>
            self.draw_lines(
              pass,
              self.stroke_pipeline(
                item.kind,
                blend,
                item.depth_write,
                item.depth_test,
                self.view_depth_func(item.depth_func),
                item.color_write,
                item.premultiplied_alpha,
              ),
              geometry,
              item.draw_start,
              item.draw_count,
            )
        }
      }
    }
  }
}

///|
/// 透明网格和透明的点、线按视图深度从远到近穿插。深度相同先画网格。
fn WebGPURenderer::draw_transparent(
  self : WebGPURenderer,
  pass : @gpu.GpuRenderPassEncoder,
  meshes : Array[@common.RenderItem],
  strokes : Array[@common.PrimitiveItem],
  camera : @core.Object3D,
  state : @core.CameraState,
  lights : @common.LightFrame,
  fog : @scenes.Fog?,
  width : UInt32,
  height : UInt32,
  shadow_group : GpuBindGroup,
  environment : @textures.Texture?,
  viewport_width : Double,
  viewport_height : Double,
) -> Unit {
  let mut mesh_index = 0
  let mut stroke_index = 0
  while mesh_index < meshes.length() || stroke_index < strokes.length() {
    let mesh_first = if stroke_index >= strokes.length() {
      true
    } else if mesh_index >= meshes.length() {
      false
    } else {
      let mesh_depth = @common.view_depth(camera, meshes[mesh_index].node)
      let stroke_depth = @common.view_depth(camera, strokes[stroke_index].node)
      mesh_depth <= stroke_depth
    }
    if mesh_first {
      self.draw_meshes(
        pass,
        [meshes[mesh_index]],
        camera,
        state,
        lights,
        fog,
        width,
        height,
        shadow_group,
        environment,
        true,
      )
      mesh_index = mesh_index + 1
    } else {
      self.draw_strokes(
        pass,
        [strokes[stroke_index]],
        camera,
        state,
        lights,
        fog,
        viewport_width,
        viewport_height,
        true,
      )
      stroke_index = stroke_index + 1
    }
  }
}

///|
/// 更新矩阵，清屏，先画不透明网格，再画线框，然后画不透明的点和线，最后按从远到近画透明物体。窗口目标会 `present`，颜色目标不会。
/// 颜色通道按相机视锥和层掩码裁剪。线框把每个三角形画成三条边。实例化线框用实例着色器，每条边按实例画一次。阴影通道用三角形投射，包含线框，但只保留阴影相机看得到的层。
/// r186: `render` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Renderer.js#L1496
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
  sync_camera(camera, width, height, self.reversed_depth)
  @common.update_frame(scene.node, camera)
  self.prepare_skins(scene.node)
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
  let lights = @common.collect_lights(
    scene.node,
    camera~,
    reversed_depth=self.reversed_depth,
  )
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
      depth_clear_value: Some(
        if self.reversed_depth {
          Float::from_int(0)
        } else {
          Float::from_int(1)
        },
      ),
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
  let view = @common.camera_frustum(state)
  self.draw_meshes(
    pass,
    @common.collect_opaque(scene.node, frustum=view, camera~),
    camera,
    state,
    lights,
    scene.fog,
    width,
    height,
    shadow_group,
    scene.environment,
    false,
  )
  self.draw_meshes(
    pass,
    @common.collect_wireframe(scene.node, frustum=view, camera~),
    camera,
    state,
    lights,
    scene.fog,
    width,
    height,
    shadow_group,
    scene.environment,
    false,
    lines=true,
  )
  let viewport_width = width.reinterpret_as_int().to_double()
  let viewport_height = height.reinterpret_as_int().to_double()
  self.draw_strokes(
    pass,
    @common.collect_primitives(scene.node, frustum=view, camera~),
    camera,
    state,
    lights,
    scene.fog,
    viewport_width,
    viewport_height,
    false,
  )
  self.draw_transparent(
    pass,
    @common.collect_transparent(scene.node, camera, frustum=view),
    @common.collect_transparent_primitives(scene.node, camera, frustum=view),
    camera,
    state,
    lights,
    scene.fog,
    width,
    height,
    shadow_group,
    scene.environment,
    viewport_width,
    viewport_height,
  )
  pass.end()
  self.device.queue().submit([encoder.finish(None)])
  if to_screen {
    self.context.present()
  }
}
