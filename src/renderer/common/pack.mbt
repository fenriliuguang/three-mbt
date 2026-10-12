// r186: `Attributes` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Attributes.js#L12 ; `UniformsGroup` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/UniformsGroup.js#L12

///|
using @core {type BufferAttribute}

///|
/// 五块 `mat4x4<f32>` 和二十二块 `vec4<f32>`。672 字节。
/// 阴影参数之后是雾的颜色和开关，以及 `(near, far, density, mode)`。
/// `surface` 是 `(roughness, metalness, alphaTest, side)`。`side` 为 1 表示双面，-1 表示只画背面并翻转法线。
/// 自发光 `rgb` 的 `w` 是平直着色开关：大于 0.5 时用法线导数，默认 0。
/// 自发光 `rgb` 之后是点光的位置、颜色，以及 `(distance, decay, enabled, 0)`。
/// 再后面是聚光的位置、方向（`w` 为开关）、颜色，以及 `(distance, decay, coneCos, penumbraCos)`。
/// 末尾 48 字节是半球光的天空色、地面色，以及方向（`w` 为开关）。没有半球光时是 0。
pub let uniform_bytes : Int = 672

///|
/// 只有位置时，每个顶点 12 字节。
pub let position_stride : Int = 12

///|
/// 一个实例矩阵 16 个 `f32`，64 字节。
pub let instance_matrix_stride : Int = 64

///|
/// 一个实例颜色 `rgb`，12 字节。
pub let instance_color_stride : Int = 12

///|
/// 位置、法线、uv 和顶点色交错存放，每个顶点 48 字节。
pub let vertex_stride : Int = 48

///|
/// WebGPU 要求 `bytesPerRow` 是 256 的倍数。
pub fn copy_bytes_per_row(row_bytes : Int) -> Int {
  let alignment = 256
  let remainder = row_bytes % alignment
  if remainder == 0 {
    row_bytes
  } else {
    row_bytes + (alignment - remainder)
  }
}

///|
fn write_f32(dst : FixedArray[Byte], offset : Int, value : Double) -> Unit {
  let bytes = Float::from_double(value).to_le_bytes()
  let mut index = 0
  while index < 4 {
    dst[offset + index] = bytes.at(index)
    index = index + 1
  }
}

///|
fn write_u32(dst : FixedArray[Byte], offset : Int, value : Int) -> Unit {
  let bits = value.reinterpret_as_uint()
  dst[offset] = bits.to_byte()
  dst[offset + 1] = (bits >> 8).to_byte()
  dst[offset + 2] = (bits >> 16).to_byte()
  dst[offset + 3] = (bits >> 24).to_byte()
}

///|
fn write_vec3(
  dst : FixedArray[Byte],
  offset : Int,
  x : Double,
  y : Double,
  z : Double,
) -> Unit {
  write_f32(dst, offset, x)
  write_f32(dst, offset + 4, y)
  write_f32(dst, offset + 8, z)
}

///|
fn write_matrix4(
  dst : FixedArray[Byte],
  offset : Int,
  matrix : @math.Matrix4,
) -> Unit {
  for index in 0..<16 {
    write_f32(dst, offset + index * 4, matrix.elements[index])
  }
}

///|
/// 把属性里的 `Double` 收成小端 `f32`。
pub fn pack_f32(attribute : BufferAttribute) -> FixedArray[Byte] {
  let dst = FixedArray::make(attribute.array.length() * 4, b'\x00')
  for index in 0..<attribute.array.length() {
    write_f32(dst, index * 4, attribute.array[index])
  }
  dst
}

///|
/// 索引收成小端 `u32`。
pub fn pack_u32_indices(index : BufferAttribute) -> FixedArray[Byte] {
  let dst = FixedArray::make(index.count * 4, b'\x00')
  for item in 0..<index.count {
    write_u32(dst, item * 4, index.get_x(item).to_int())
  }
  dst
}

///|
/// 整数索引进小端 `u32`。
pub fn pack_index_array(indices : Array[Int]) -> FixedArray[Byte] {
  let dst = FixedArray::make(indices.length() * 4, b'\x00')
  for item in 0..<indices.length() {
    write_u32(dst, item * 4, indices[item])
  }
  dst
}

///|
/// 位置、法线、uv 和顶点色交错存放，每个顶点 48 字节。
/// 缺少法线时写成 `(0, 0, 1)`，缺少 uv 时写成 `(0, 0)`。
/// 缺少顶点色时写成白色；只有 rgb 时 alpha 写成 1。
pub fn pack_position_normal_uv(
  position : BufferAttribute,
  normal : BufferAttribute?,
  uv : BufferAttribute?,
  color? : BufferAttribute? = None,
) -> FixedArray[Byte] {
  let dst = FixedArray::make(position.count * vertex_stride, b'\x00')
  for index in 0..<position.count {
    let base = index * vertex_stride
    write_vec3(
      dst,
      base,
      position.get_x(index),
      position.get_y(index),
      position.get_z(index),
    )
    match normal {
      Some(normal) if index < normal.count =>
        write_vec3(
          dst,
          base + 12,
          normal.get_x(index),
          normal.get_y(index),
          normal.get_z(index),
        )
      _ => write_f32(dst, base + 20, 1.0)
    }
    match uv {
      Some(uv) if index < uv.count => {
        write_f32(dst, base + 24, uv.get_x(index))
        write_f32(dst, base + 28, uv.get_y(index))
      }
      _ => ()
    }
    write_vertex_color(dst, base + 32, color, index)
  }
  dst
}

///|
fn write_vertex_color(
  dst : FixedArray[Byte],
  offset : Int,
  color : BufferAttribute?,
  index : Int,
) -> Unit {
  match color {
    Some(color) if index < color.count => {
      write_f32(dst, offset, color.get_x(index))
      write_f32(dst, offset + 4, color.get_y(index))
      write_f32(dst, offset + 8, color.get_z(index))
      if color.item_size >= 4 {
        write_f32(dst, offset + 12, color.get_component(index, 3))
      } else {
        write_f32(dst, offset + 12, 1.0)
      }
    }
    _ => {
      write_f32(dst, offset, 1.0)
      write_f32(dst, offset + 4, 1.0)
      write_f32(dst, offset + 8, 1.0)
      write_f32(dst, offset + 12, 1.0)
    }
  }
}

///|
/// 把紧排的 `rgba8` 补到每行 256 字节对齐，供 `write_texture` 使用。
pub fn pad_texture_rows(
  pixels : FixedArray[Byte],
  width : Int,
  height : Int,
) -> (FixedArray[Byte], Int) {
  let row = width * 4
  let stride = copy_bytes_per_row(row)
  if stride == row {
    return (pixels, stride)
  }
  let dst = FixedArray::make(stride * height, b'\x00')
  for y in 0..<height {
    for x in 0..<row {
      dst[y * stride + x] = pixels[y * row + x]
    }
  }
  (dst, stride)
}

///|
/// 把模型矩阵的法线矩阵放进 4×4 的左上角，供 WGSL 的 `mat4x4` 使用。
/// r186: `getNormalMatrix` https://github.com/mrdoob/three.js/blob/r186/src/math/Matrix3.js#L352
pub fn normal_matrix(model : @math.Matrix4) -> @math.Matrix4 {
  let source = @math.Matrix3::new().get_normal_matrix(model).elements
  let matrix = @math.Matrix4::new()
  let destination = matrix.elements
  destination[0] = source[0]
  destination[1] = source[1]
  destination[2] = source[2]
  destination[4] = source[3]
  destination[5] = source[4]
  destination[6] = source[5]
  destination[8] = source[6]
  destination[9] = source[7]
  destination[10] = source[8]
  matrix
}

///|
/// `mvp`、法线矩阵、颜色、环境光、平行光，然后是模型矩阵、相机位置、粗糙度和金属度。
/// 自发光通道先乘 `emissive_intensity`，默认 1。`0` 会把自发光写成黑。
/// r186: `emissive` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLMaterials.js#L150
pub fn pack_uniforms(
  mvp : @math.Matrix4,
  normals : @math.Matrix4,
  color : @math.Color,
  opacity : Double,
  ambient : @math.Vector3,
  light_color : @math.Vector3,
  light_direction : @math.Vector3,
  model : @math.Matrix4,
  camera_position : @math.Vector3,
  roughness : Double,
  metalness : Double,
  view : @math.Matrix4,
  viewport_width : Double,
  viewport_height : Double,
  point_size : Double,
  size_attenuation : Double,
  shadow : @math.Matrix4,
  shadow_bias : Double,
  shadow_normal_bias : Double,
  shadow_enabled : Double,
  shadow_texel : Double,
  fog_r : Double,
  fog_g : Double,
  fog_b : Double,
  fog_enabled : Double,
  fog_near : Double,
  fog_far : Double,
  fog_density : Double,
  fog_mode : Double,
  alpha_test? : Double = 0.0,
  emissive_r? : Double = 0.0,
  emissive_g? : Double = 0.0,
  emissive_b? : Double = 0.0,
  emissive_intensity? : Double = 1.0,
  flat_shading? : Double = 0.0,
  point_x? : Double = 0.0,
  point_y? : Double = 0.0,
  point_z? : Double = 0.0,
  point_r? : Double = 0.0,
  point_g? : Double = 0.0,
  point_b? : Double = 0.0,
  point_distance? : Double = 0.0,
  point_decay? : Double = 2.0,
  point_enabled? : Double = 0.0,
  spot_x? : Double = 0.0,
  spot_y? : Double = 0.0,
  spot_z? : Double = 0.0,
  spot_dx? : Double = 0.0,
  spot_dy? : Double = 0.0,
  spot_dz? : Double = 0.0,
  spot_r? : Double = 0.0,
  spot_g? : Double = 0.0,
  spot_b? : Double = 0.0,
  spot_distance? : Double = 0.0,
  spot_decay? : Double = 2.0,
  spot_cone_cos? : Double = 1.0,
  spot_penumbra_cos? : Double = 1.0,
  spot_enabled? : Double = 0.0,
  side? : Double = 0.0,
  hemisphere_sky_r? : Double = 0.0,
  hemisphere_sky_g? : Double = 0.0,
  hemisphere_sky_b? : Double = 0.0,
  hemisphere_ground_r? : Double = 0.0,
  hemisphere_ground_g? : Double = 0.0,
  hemisphere_ground_b? : Double = 0.0,
  hemisphere_x? : Double = 0.0,
  hemisphere_y? : Double = 0.0,
  hemisphere_z? : Double = 0.0,
  hemisphere_enabled? : Double = 0.0,
) -> FixedArray[Byte] {
  let dst = FixedArray::make(uniform_bytes, b'\x00')
  write_matrix4(dst, 0, mvp)
  write_matrix4(dst, 64, normals)
  write_f32(dst, 128, color.r)
  write_f32(dst, 132, color.g)
  write_f32(dst, 136, color.b)
  write_f32(dst, 140, opacity)
  write_vec3(dst, 144, ambient.x, ambient.y, ambient.z)
  write_vec3(dst, 160, light_color.x, light_color.y, light_color.z)
  write_vec3(dst, 176, light_direction.x, light_direction.y, light_direction.z)
  write_matrix4(dst, 192, model)
  write_vec3(dst, 256, camera_position.x, camera_position.y, camera_position.z)
  write_f32(dst, 272, roughness)
  write_f32(dst, 276, metalness)
  write_f32(dst, 280, alpha_test)
  write_f32(dst, 284, side)
  write_f32(dst, 288, viewport_width)
  write_f32(dst, 292, viewport_height)
  write_f32(dst, 304, point_size)
  write_f32(dst, 308, size_attenuation)
  write_matrix4(dst, 320, view)
  write_matrix4(dst, 384, shadow)
  write_f32(dst, 448, shadow_bias)
  write_f32(dst, 452, shadow_normal_bias)
  write_f32(dst, 456, shadow_enabled)
  write_f32(dst, 460, shadow_texel)
  write_f32(dst, 464, fog_r)
  write_f32(dst, 468, fog_g)
  write_f32(dst, 472, fog_b)
  write_f32(dst, 476, fog_enabled)
  write_f32(dst, 480, fog_near)
  write_f32(dst, 484, fog_far)
  write_f32(dst, 488, fog_density)
  write_f32(dst, 492, fog_mode)
  write_f32(dst, 496, emissive_r * emissive_intensity)
  write_f32(dst, 500, emissive_g * emissive_intensity)
  write_f32(dst, 504, emissive_b * emissive_intensity)
  write_f32(dst, 508, flat_shading)
  write_f32(dst, 512, point_x)
  write_f32(dst, 516, point_y)
  write_f32(dst, 520, point_z)
  write_f32(dst, 528, point_r)
  write_f32(dst, 532, point_g)
  write_f32(dst, 536, point_b)
  write_f32(dst, 544, point_distance)
  write_f32(dst, 548, point_decay)
  write_f32(dst, 552, point_enabled)
  write_f32(dst, 560, spot_x)
  write_f32(dst, 564, spot_y)
  write_f32(dst, 568, spot_z)
  write_f32(dst, 576, spot_dx)
  write_f32(dst, 580, spot_dy)
  write_f32(dst, 584, spot_dz)
  write_f32(dst, 588, spot_enabled)
  write_f32(dst, 592, spot_r)
  write_f32(dst, 596, spot_g)
  write_f32(dst, 600, spot_b)
  write_f32(dst, 608, spot_distance)
  write_f32(dst, 612, spot_decay)
  write_f32(dst, 616, spot_cone_cos)
  write_f32(dst, 620, spot_penumbra_cos)
  write_f32(dst, 624, hemisphere_sky_r)
  write_f32(dst, 628, hemisphere_sky_g)
  write_f32(dst, 632, hemisphere_sky_b)
  write_f32(dst, 640, hemisphere_ground_r)
  write_f32(dst, 644, hemisphere_ground_g)
  write_f32(dst, 648, hemisphere_ground_b)
  write_f32(dst, 656, hemisphere_x)
  write_f32(dst, 660, hemisphere_y)
  write_f32(dst, 664, hemisphere_z)
  write_f32(dst, 668, hemisphere_enabled)
  dst
}

///|
/// 把正交阴影相机的裁剪空间变到贴图坐标。WebGPU 的 `y` 向上，所以这里把 `y` 翻转到贴图。
/// 深度已经在 `0..1`，不再做一次 `0.5` 缩放。
/// r186: `LightShadow` https://github.com/mrdoob/three.js/blob/r186/src/lights/LightShadow.js#L18
pub fn shadow_matrix(
  projection : @math.Matrix4,
  view : @math.Matrix4,
) -> @math.Matrix4 {
  let clip = @math.Matrix4::new().multiply_matrices(projection, view)
  let bias = @math.Matrix4::new()
  ignore(
    bias.set(
      0.5, 0.0, 0.0, 0.5, 0.0, -0.5, 0.0, 0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0,
      1.0,
    ),
  )
  @math.Matrix4::new().multiply_matrices(bias, clip)
}

///|
/// 点精灵的两个三角形。角点在 \[-1, 1\]，顺序保持朝外。
pub fn point_quad_bytes() -> FixedArray[Byte] {
  let corners = [
    -1.0, -1.0, 1.0, -1.0, 1.0, 1.0, -1.0, -1.0, 1.0, 1.0, -1.0, 1.0,
  ]
  let dst = FixedArray::make(corners.length() * 4, b'\x00')
  for index in 0..<corners.length() {
    write_f32(dst, index * 4, corners[index])
  }
  dst
}

///|
/// 实例颜色。没有颜色时写成白色。个数按矩阵容量，而不是当前 `count`。
pub fn pack_instance_colors(
  colors : BufferAttribute?,
  count : Int,
) -> FixedArray[Byte] {
  let dst = FixedArray::make(count * instance_color_stride, b'\x00')
  let mut index = 0
  while index < count {
    let (r, g, b) = match colors {
      Some(colors) if index < colors.count =>
        (colors.get_x(index), colors.get_y(index), colors.get_z(index))
      _ => (1.0, 1.0, 1.0)
    }
    let base = index * instance_color_stride
    write_f32(dst, base, r)
    write_f32(dst, base + 4, g)
    write_f32(dst, base + 8, b)
    index = index + 1
  }
  dst
}

///|
/// 点的实例位置。有索引时按索引展开，没有索引时紧排 `xyz`。
pub fn pack_point_positions(
  position : BufferAttribute,
  index : BufferAttribute?,
) -> FixedArray[Byte] {
  match index {
    None => pack_f32(position)
    Some(index) => {
      let dst = FixedArray::make(index.count * position_stride, b'\x00')
      for item in 0..<index.count {
        let vertex = index.get_x(item).to_int()
        let base = item * position_stride
        write_f32(dst, base, position.get_x(vertex))
        write_f32(dst, base + 4, position.get_y(vertex))
        write_f32(dst, base + 8, position.get_z(vertex))
      }
      dst
    }
  }
}
