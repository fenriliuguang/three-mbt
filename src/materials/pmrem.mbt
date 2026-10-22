// r186: `PMREMGenerator` https://github.com/mrdoob/three.js/blob/r186/src/extras/PMREMGenerator.js#L65 ; `fromEquirectangular` https://github.com/mrdoob/three.js/blob/r186/src/extras/PMREMGenerator.js#L151

///|
let pmrem_specular_levels : Int32 = 5

///|
let pmrem_row_count : Int32 = 6

///|
let pmrem_max_width : Int32 = 16

///|
let pmrem_max_height : Int32 = 8

///|
let pmrem_ggx_samples : Int32 = 8

///|
fn level_extent(width : Int32, height : Int32) -> (Int32, Int32) {
  let level_w = if width > pmrem_max_width { pmrem_max_width } else { width }
  let level_h = if height > pmrem_max_height {
    pmrem_max_height
  } else {
    height
  }
  (level_w, level_h)
}

///|
fn nearest_texel(out : Int32, out_size : Int32, src_size : Int32) -> Int32 {
  if out_size == src_size {
    return out
  }
  let scaled = ((out.to_double() + 0.5) *
  src_size.to_double() /
  out_size.to_double()).floor()
  let mut index = scaled.to_int()
  if index < 0 {
    index = 0
  }
  if index >= src_size {
    index = src_size - 1
  }
  index
}

///|
fn copy_bytes(
  dst : FixedArray[Byte],
  dst_offset : Int32,
  src : FixedArray[Byte],
  src_offset : Int32,
  count : Int32,
) -> Unit {
  let mut index = 0
  while index < count {
    dst[dst_offset + index] = src[src_offset + index]
    index = index + 1
  }
}

///|
/// `rgba8` 在 `flip_y` 为真时把底行放到开头。这里要图像顶在第 0 行。
fn top_rgba8(source : @textures.Texture) -> FixedArray[Byte] {
  let uploaded = source.rgba8()
  if !source.flip_y || source.height <= 1 {
    return uploaded
  }
  let row = source.width * 4
  let dst = FixedArray::make(uploaded.length(), b'\x00')
  for y in 0..<source.height {
    copy_bytes(dst, y * row, uploaded, (source.height - 1 - y) * row, row)
  }
  dst
}

///|
fn texel_index(coord : Double, size : Int32) -> Int32 {
  let mut index = (coord * size.to_double()).floor().to_int()
  if index < 0 {
    index = 0
  }
  if index >= size {
    index = size - 1
  }
  index
}

///|
fn direction_from_uv(u : Double, v : Double) -> @math.Vector3 {
  let phi = (u * 2.0 - 1.0) * @std.PI
  let lat = (0.5 - v) * @std.PI
  let cos_lat = @std.cos(lat)
  @math.Vector3::new(
    x=cos_lat * @std.cos(phi),
    y=@std.sin(lat),
    z=cos_lat * @std.sin(phi),
  )
}

///|
fn uv_from_direction(dir : @math.Vector3) -> (Double, Double) {
  let u = @std.atan2(dir.z, dir.x) / (2.0 * @std.PI) + 0.5
  let v = 0.5 - @std.asin(@math.clamp(dir.y, -1.0, 1.0)) / @std.PI
  (u, v)
}

///|
fn read_linear(
  pixels : FixedArray[Byte],
  width : Int32,
  x : Int32,
  y : Int32,
) -> (Double, Double, Double, Double) {
  let offset = (y * width + x) * 4
  (
    @math.srgb_to_linear(pixels[offset].to_int().to_double() / 255.0),
    @math.srgb_to_linear(pixels[offset + 1].to_int().to_double() / 255.0),
    @math.srgb_to_linear(pixels[offset + 2].to_int().to_double() / 255.0),
    pixels[offset + 3].to_int().to_double() / 255.0,
  )
}

///|
fn sample_equirect(
  pixels : FixedArray[Byte],
  width : Int32,
  height : Int32,
  dir : @math.Vector3,
) -> (Double, Double, Double, Double) {
  let (u, v) = uv_from_direction(dir)
  read_linear(pixels, width, texel_index(u, width), texel_index(v, height))
}

///|
fn unit_byte(value : Double) -> Byte {
  let scaled = (@math.clamp(value, 0.0, 1.0) * 255.0).round()
  let mut index = scaled.to_int()
  if index < 0 {
    index = 0
  }
  if index > 255 {
    index = 255
  }
  index.to_byte()
}

///|
fn linear_byte(value : Double) -> Byte {
  unit_byte(@math.linear_to_srgb(@math.clamp(value, 0.0, 1.0)))
}

///|
fn write_pixel(
  dst : FixedArray[Byte],
  offset : Int32,
  r : Double,
  g : Double,
  b : Double,
  a : Double,
) -> Unit {
  dst[offset] = linear_byte(r)
  dst[offset + 1] = linear_byte(g)
  dst[offset + 2] = linear_byte(b)
  dst[offset + 3] = unit_byte(a)
}

///|
fn radical_inverse(index : Int32) -> Double {
  let mut bits = index.reinterpret_as_uint()
  bits = (bits << 16) | (bits >> 16)
  bits = ((bits & 0x55555555U) << 1) | ((bits & 0xAAAAAAAAU) >> 1)
  bits = ((bits & 0x33333333U) << 2) | ((bits & 0xCCCCCCCCU) >> 2)
  bits = ((bits & 0x0F0F0F0FU) << 4) | ((bits & 0xF0F0F0F0U) >> 4)
  bits = ((bits & 0x00FF00FFU) << 8) | ((bits & 0xFF00FF00U) >> 8)
  bits.to_double() * 2.3283064365386963e-10
}

///|
fn importance_ggx(
  xi_x : Double,
  xi_y : Double,
  roughness : Double,
  normal : @math.Vector3,
) -> @math.Vector3 {
  let alpha = roughness * roughness
  let phi = 2.0 * @std.PI * xi_x
  let cos_theta = ((1.0 - xi_y) / (1.0 + (alpha * alpha - 1.0) * xi_y)).sqrt()
  let sin_theta = (1.0 - cos_theta * cos_theta).max(0.0).sqrt()
  let up = if normal.z.abs() < 0.999 {
    @math.Vector3::new(z=1.0)
  } else {
    @math.Vector3::new(x=1.0)
  }
  let tangent = @math.Vector3::new()
  ignore(tangent.cross_vectors(up, normal).normalize())
  let bitangent = @math.Vector3::new()
  ignore(bitangent.cross_vectors(normal, tangent))
  let hx = sin_theta * @std.cos(phi)
  let hy = sin_theta * @std.sin(phi)
  let half = @math.Vector3::new(
    x=tangent.x * hx + bitangent.x * hy + normal.x * cos_theta,
    y=tangent.y * hx + bitangent.y * hy + normal.y * cos_theta,
    z=tangent.z * hx + bitangent.z * hy + normal.z * cos_theta,
  )
  half.normalize()
}

///|
fn prefilter_ggx(
  pixels : FixedArray[Byte],
  width : Int32,
  height : Int32,
  dir : @math.Vector3,
  roughness : Double,
) -> (Double, Double, Double, Double) {
  let mut sum_r = 0.0
  let mut sum_g = 0.0
  let mut sum_b = 0.0
  let mut sum_a = 0.0
  let mut weight = 0.0
  let mut sample = 0
  while sample < pmrem_ggx_samples {
    let xi_x = sample.to_double() / pmrem_ggx_samples.to_double()
    let xi_y = radical_inverse(sample)
    let half = importance_ggx(xi_x, xi_y, roughness, dir)
    let ndoth = dir.dot(half)
    let light = @math.Vector3::new(
      x=2.0 * ndoth * half.x - dir.x,
      y=2.0 * ndoth * half.y - dir.y,
      z=2.0 * ndoth * half.z - dir.z,
    )
    ignore(light.normalize())
    let ndotl = dir.dot(light)
    if ndotl > 0.0 {
      let (r, g, b, a) = sample_equirect(pixels, width, height, light)
      sum_r = sum_r + r * ndotl
      sum_g = sum_g + g * ndotl
      sum_b = sum_b + b * ndotl
      sum_a = sum_a + a * ndotl
      weight = weight + ndotl
    }
    sample = sample + 1
  }
  if weight == 0.0 {
    sample_equirect(pixels, width, height, dir)
  } else {
    (sum_r / weight, sum_g / weight, sum_b / weight, sum_a / weight)
  }
}

///|
fn prefilter_irradiance(
  pixels : FixedArray[Byte],
  width : Int32,
  height : Int32,
  dir : @math.Vector3,
) -> (Double, Double, Double, Double) {
  let mut sum_r = 0.0
  let mut sum_g = 0.0
  let mut sum_b = 0.0
  let mut sum_a = 0.0
  let mut weight = 0.0
  let mut mean_r = 0.0
  let mut mean_g = 0.0
  let mut mean_b = 0.0
  let mut mean_a = 0.0
  let count = (width * height).to_double()
  for y in 0..<height {
    for x in 0..<width {
      let u = (x.to_double() + 0.5) / width.to_double()
      let v = (y.to_double() + 0.5) / height.to_double()
      let sample_dir = direction_from_uv(u, v)
      let (r, g, b, a) = read_linear(pixels, width, x, y)
      mean_r = mean_r + r
      mean_g = mean_g + g
      mean_b = mean_b + b
      mean_a = mean_a + a
      let cosine = dir.dot(sample_dir)
      if cosine > 0.0 {
        sum_r = sum_r + r * cosine
        sum_g = sum_g + g * cosine
        sum_b = sum_b + b * cosine
        sum_a = sum_a + a * cosine
        weight = weight + cosine
      }
    }
  }
  if weight == 0.0 {
    (mean_r / count, mean_g / count, mean_b / count, mean_a / count)
  } else {
    (sum_r / weight, sum_g / weight, sum_b / weight, sum_a / weight)
  }
}

///|
fn downsample(
  source : FixedArray[Byte],
  src_w : Int32,
  src_h : Int32,
  level_w : Int32,
  level_h : Int32,
) -> FixedArray[Byte] {
  let dst = FixedArray::make(level_w * level_h * 4, b'\x00')
  for y in 0..<level_h {
    for x in 0..<level_w {
      let src_x = nearest_texel(x, level_w, src_w)
      let src_y = nearest_texel(y, level_h, src_h)
      copy_bytes(
        dst,
        (y * level_w + x) * 4,
        source,
        (src_y * src_w + src_x) * 4,
        4,
      )
    }
  }
  dst
}

///|
/// 用欧拉角的左上 3×3 旋转方向，再归一化。平移不参与。
pub fn rotate_env_direction(
  euler : @math.Euler,
  direction : @math.Vector3,
) -> @math.Vector3 {
  let matrix = @math.Matrix4::new()
  ignore(matrix.make_rotation_from_euler(euler))
  let turned = @math.Vector3::new(x=direction.x, y=direction.y, z=direction.z)
  ignore(turned.transform_direction(matrix))
  turned
}

///|
/// 把等距柱状环境贴图收成一张图集。每一级最长 16、最高 8，更大时最近邻缩小。
/// 前 5 行是粗糙度 0、0.25、0.5、0.75、1。最后一行是辐照度。
/// 粗糙度 0 直接拷贝。更高的粗糙度在线性光里做 8 次 GGX，再写回 sRGB。
/// 上游 `GGX_SAMPLES` 是 256。
/// r186: `fromEquirectangular` https://github.com/mrdoob/three.js/blob/r186/src/extras/PMREMGenerator.js#L151 ; `GGX_SAMPLES` https://github.com/mrdoob/three.js/blob/r186/src/extras/PMREMGenerator.js#L37
pub fn pmrem_atlas(source : @textures.Texture) -> @textures.Texture {
  let (level_w, level_h) = level_extent(source.width, source.height)
  let level = downsample(
    top_rgba8(source),
    source.width,
    source.height,
    level_w,
    level_h,
  )
  let row_bytes = level_w * level_h * 4
  let dst = FixedArray::make(row_bytes * pmrem_row_count, b'\x00')
  copy_bytes(dst, 0, level, 0, row_bytes)
  for row in 1..<pmrem_specular_levels {
    let roughness = row.to_double() / (pmrem_specular_levels - 1).to_double()
    for y in 0..<level_h {
      for x in 0..<level_w {
        let u = (x.to_double() + 0.5) / level_w.to_double()
        let v = (y.to_double() + 0.5) / level_h.to_double()
        let dir = direction_from_uv(u, v)
        let (r, g, b, a) = prefilter_ggx(
          level, level_w, level_h, dir, roughness,
        )
        let offset = row * row_bytes + (y * level_w + x) * 4
        write_pixel(dst, offset, r, g, b, a)
      }
    }
  }
  let irradiance_row = pmrem_specular_levels
  for y in 0..<level_h {
    for x in 0..<level_w {
      let u = (x.to_double() + 0.5) / level_w.to_double()
      let v = (y.to_double() + 0.5) / level_h.to_double()
      let dir = direction_from_uv(u, v)
      let (r, g, b, a) = prefilter_irradiance(level, level_w, level_h, dir)
      let offset = irradiance_row * row_bytes + (y * level_w + x) * 4
      write_pixel(dst, offset, r, g, b, a)
    }
  }
  let atlas = @textures.Texture::from_rgba8(
    level_w,
    level_h * pmrem_row_count,
    dst,
  )
  atlas.flip_y = false
  atlas.wrap_s = @constants.ClampToEdge
  atlas.wrap_t = @constants.ClampToEdge
  atlas.mag_filter = @constants.Linear
  atlas.min_filter = @constants.Linear
  atlas
}
