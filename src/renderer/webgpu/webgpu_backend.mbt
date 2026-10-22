// r186: `WebGPUBackend` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgpu/WebGPUBackend.js#L55

///|
struct DepthTarget {
  texture : GpuTexture
  view : GpuTextureView
  width : UInt32
  height : UInt32
}

///|
struct GeometryGpu {
  geometry : @core.BufferGeometry
  vertices : GpuBuffer
  indices : GpuBuffer?
  index_count : Int32
  vertex_count : Int32
  mut version : Int32
}

///|
struct WireGpu {
  geometry : @core.BufferGeometry
  indices : GpuBuffer
  index_count : Int32
}

///|
struct PositionGpu {
  geometry : @core.BufferGeometry
  vertices : GpuBuffer
  indices : GpuBuffer?
  index_count : Int32
  vertex_count : Int32
  mut points : GpuBuffer?
  mut point_count : Int32
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
  mut version : Int32
}

///|
struct EnvGpu {
  node : @core.Object3D
  atlas : @textures.Texture
  source : @textures.Texture
  version : Int32
  params : GpuBuffer
  group : GpuBindGroup
}

///|
struct SkinGpu {
  node : @core.Object3D
  source : GpuBuffer
  output : GpuBuffer
  bones : GpuBuffer
  joints : GpuBuffer
  weights : GpuBuffer
  params : GpuBuffer
  group : GpuBindGroup
  vertex_count : Int32
  bone_bytes : Int32
  joint_bytes : Int32
  weight_bytes : Int32
}

///|
struct StorageGpu {
  source : @compute.StoragePositions
  buffer : GpuBuffer
  uniform : GpuBuffer
  group : GpuBindGroup
  count : Int32
}

///|
struct ShadowMap {
  texture : GpuTexture
  view : GpuTextureView
  group : GpuBindGroup
  size : UInt32
  reversed : Bool
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
  width : UInt32
  height : UInt32
  version : Int32
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
fn vertex_visibility() -> @gpu.GpuShaderStage {
  @gpu.GpuShaderStage::default().set(@gpu.GpuShaderStageFlag::VERTEX)
}

///|
fn sampled_texture_entry(
  binding : UInt32,
  visibility : @gpu.GpuShaderStage,
) -> @gpu.GpuBindGroupLayoutEntry {
  {
    binding,
    visibility,
    buffer: None,
    sampler: None,
    texture: Some({
      sample_type: Some(@gpu.GpuTextureSampleType::FLOAT),
      view_dimension: Some(@gpu.GpuTextureViewDimension::D2),
      multisampled: Some(false),
    }),
    storage_texture: None,
  }
}

///|
fn filtering_sampler_entry(
  binding : UInt32,
  visibility : @gpu.GpuShaderStage,
) -> @gpu.GpuBindGroupLayoutEntry {
  {
    binding,
    visibility,
    buffer: None,
    sampler: Some({ type_: Some(@gpu.GpuSamplerBindingType::FILTERING), }),
    texture: None,
    storage_texture: None,
  }
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
fn upload_texture(
  device : GpuDevice,
  layout : GpuBindGroupLayout,
  width : Int32,
  height : Int32,
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
fn drop_color_target(gpu : ColorTarget) -> Unit {
  gpu.group.drop()
  gpu.view.drop()
  gpu.sampler.drop()
  gpu.texture.drop()
  gpu.depth_view.drop()
  gpu.depth_texture.drop()
}

///|
fn drop_bloom_level(level : BloomLevel) -> Unit {
  level.h_view.drop()
  level.v_view.drop()
  level.h_texture.drop()
  level.v_texture.drop()
}

///|
fn drop_bloom(pyramid : BloomPyramid) -> Unit {
  pyramid.bright_view.drop()
  pyramid.bright_texture.drop()
  let mut index = 0
  while index < pyramid.levels.length() {
    drop_bloom_level(pyramid.levels[index])
    index = index + 1
  }
  pyramid.acc_view.drop()
  pyramid.acc2_view.drop()
  pyramid.acc_texture.drop()
  pyramid.acc2_texture.drop()
}

///|
fn drop_chain(buffers : ChainBuffers) -> Unit {
  buffers.a_view.drop()
  buffers.b_view.drop()
  buffers.a_texture.drop()
  buffers.b_texture.drop()
}
