// r186: `BloomNode` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/tsl/display/BloomNode.js#L54

///|
fn clamp_radius(radius : Double) -> Double {
  if radius < 0.0 {
    0.0
  } else if radius > 1.0 {
    1.0
  } else {
    radius
  }
}

///|
fn bloom_smoothstep(edge0 : Double, edge1 : Double, x : Double) -> Double {
  let span = edge1 - edge0
  if span <= 0.0 {
    if x < edge0 {
      0.0
    } else {
      1.0
    }
  } else {
    let mut t = (x - edge0) / span
    if t < 0.0 {
      t = 0.0
    }
    if t > 1.0 {
      t = 1.0
    }
    t * t * (3.0 - 2.0 * t)
  }
}

///|
/// 把高通、模糊后的光加回原图。`radius` 只拨第一级的权重，和 r186 `lerpBloomFactor(1, radius)` 相同。
/// r186: `lerpBloomFactor` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/tsl/display/BloomNode.js#L579
pub fn bloom_mix(
  r : Double,
  g : Double,
  b : Double,
  glow_r : Double,
  glow_g : Double,
  glow_b : Double,
  strength : Double,
  radius : Double,
) -> @math.Color {
  let t = clamp_radius(radius)
  let weight = strength * ((1.0 - t) * 1.0 + t * 0.2)
  @math.Color::new(
    r=r + glow_r * weight,
    g=g + glow_g * weight,
    b=b + glow_b * weight,
  )
}

///|
/// Rec.709 亮度系数，和 r186 线性 sRGB 工作空间相同。
/// r186: `luminance` https://github.com/mrdoob/three.js/blob/r186/src/nodes/display/ColorAdjustment.js#L87 ; `REC709_LUMINANCE_COEFFICIENTS` https://github.com/mrdoob/three.js/blob/r186/src/math/ColorManagement.js#L171
pub fn luminance(r : Double, g : Double, b : Double) -> Double {
  r * 0.2126 + g * 0.7152 + b * 0.0722
}

///|
/// 亮度高通。低于 `threshold` 的像素变成黑，过渡宽度是 `smooth_width`。
/// r186: `luminosityHighPass` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/tsl/display/BloomNode.js#L12
pub fn high_pass(
  r : Double,
  g : Double,
  b : Double,
  threshold : Double,
  smooth_width : Double,
) -> @math.Color {
  let alpha = bloom_smoothstep(
    threshold,
    threshold + smooth_width,
    luminance(r, g, b),
  )
  @math.Color::new(r=r * alpha, g=g * alpha, b=b * alpha)
}

///|
/// 可分离高斯的第 `index` 个系数。`kernel_radius / 3` 是 sigma，和 r186 第一级模糊相同。
/// r186: `_getSeparableBlurMaterial` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/tsl/display/BloomNode.js#L505
pub fn gaussian_coefficient(index : Int, kernel_radius : Int) -> Double {
  let safe = if kernel_radius < 1 { 1 } else { kernel_radius }
  let sigma = safe.to_double() / 3.0
  let i = index.to_double()
  0.39894 * @std.exp(-0.5 * i * i / (sigma * sigma)) / sigma
}

///|
/// 泛光。默认强度 1、半径 0、阈值 0、过渡 0.01，与 r186 `BloomNode` 相同。
/// 五级核半径是 6、10、14、18、22。第 0 级用全分辨率，之后每级对半。每级染色默认白色。中间结果用半精度浮点。
/// r186: `BloomNode` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/tsl/display/BloomNode.js#L54
pub(all) struct BloomPass {
  mut strength : Double
  mut radius : Double
  mut threshold : Double
  mut smooth_width : Double
  mut tint_r : Array[Double]
  mut tint_g : Array[Double]
  mut tint_b : Array[Double]
  mut resolution_scale : Double
}

///|
pub fn BloomPass::new(
  strength? : Double = 1.0,
  radius? : Double = 0.0,
  threshold? : Double = 0.0,
) -> BloomPass {
  {
    strength,
    radius: clamp_radius(radius),
    threshold,
    smooth_width: 0.01,
    tint_r: [1.0, 1.0, 1.0, 1.0, 1.0],
    tint_g: [1.0, 1.0, 1.0, 1.0, 1.0],
    tint_b: [1.0, 1.0, 1.0, 1.0, 1.0],
    resolution_scale: 1.0,
  }
}

///|
/// 内部目标相对输入的缩放。1 是全分辨率。r186 的默认值是 0.5。小于 0 当成 0。
/// r186: `setResolutionScale` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/tsl/display/BloomNode.js#L297
pub fn BloomPass::set_resolution_scale(
  self : BloomPass,
  scale : Double,
) -> Unit {
  self.resolution_scale = if scale < 0.0 { 0.0 } else { scale }
}

///|
/// 设置第 `level` 级的染色。越界下标不改。默认五级都是白。
/// r186: `bloomTintColors` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/tsl/display/BloomNode.js#L116
pub fn BloomPass::set_tint(
  self : BloomPass,
  level : Int,
  r : Double,
  g : Double,
  b : Double,
) -> Unit {
  if level >= 0 && level < 5 {
    self.tint_r[level] = r
    self.tint_g[level] = g
    self.tint_b[level] = b
  }
}

///|
pub fn BloomPass::set_strength(self : BloomPass, strength : Double) -> Unit {
  self.strength = strength
}

///|
pub fn BloomPass::set_radius(self : BloomPass, radius : Double) -> Unit {
  self.radius = clamp_radius(radius)
}

///|
pub fn BloomPass::set_threshold(self : BloomPass, threshold : Double) -> Unit {
  self.threshold = threshold
}

///|
pub fn BloomPass::set_smooth_width(
  self : BloomPass,
  smooth_width : Double,
) -> Unit {
  self.smooth_width = if smooth_width < 0.0 { 0.0 } else { smooth_width }
}

///|
/// 64 字节 uniform。依次是阈值、过渡、强度、半径、纹素、方向、模式、核半径、该级系数和染色。
pub fn pack_bloom(
  pass : BloomPass,
  texel_x : Double,
  texel_y : Double,
  dir_x : Double,
  dir_y : Double,
  mode : Double,
  kernel? : Double = 6.0,
  factor? : Double = 1.0,
  tint_r? : Double = 1.0,
  tint_g? : Double = 1.0,
  tint_b? : Double = 1.0,
) -> FixedArray[Byte] {
  let dst = FixedArray::make(64, b'\x00')
  write_f32(dst, 0, pass.threshold)
  write_f32(dst, 4, pass.smooth_width)
  write_f32(dst, 8, pass.strength)
  write_f32(dst, 12, pass.radius)
  write_f32(dst, 16, texel_x)
  write_f32(dst, 20, texel_y)
  write_f32(dst, 24, dir_x)
  write_f32(dst, 28, dir_y)
  write_f32(dst, 32, mode)
  write_f32(dst, 36, kernel)
  write_f32(dst, 40, factor)
  write_f32(dst, 44, tint_r)
  write_f32(dst, 48, tint_g)
  write_f32(dst, 52, tint_b)
  dst
}

///|
/// 把一级染色乘上该级权重。白染色时结果就是权重本身。
/// r186: `bloomTintColors` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/tsl/display/BloomNode.js#L116
pub fn bloom_tinted(
  level : Int,
  tint_r : Double,
  tint_g : Double,
  tint_b : Double,
  strength : Double,
  radius : Double,
) -> @math.Color {
  let weight = bloom_level_weight(level, strength, radius)
  @math.Color::new(r=tint_r * weight, g=tint_g * weight, b=tint_b * weight)
}

///|
/// 五级模糊的核半径，对应 `kernelSizeArray`。
/// r186: `kernelSizeArray` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/tsl/display/BloomNode.js#L425
pub fn bloom_kernel_radius(level : Int) -> Int {
  match level {
    0 => 6
    1 => 10
    2 => 14
    3 => 18
    _ => 22
  }
}

///|
/// 第 `level` 级的边长。先 `floor(base * scale)`，再每级对半，至少是 1。
/// r186: `setSize` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/tsl/display/BloomNode.js#L322
pub fn bloom_scaled_size(base : Int, level : Int, scale : Double) -> Int {
  let safe = if base < 1 { 1 } else { base }
  let clamped = if scale < 0.0 { 0.0 } else { scale }
  let mut size = (safe.to_double() * clamped).floor().to_int()
  if size < 1 {
    size = 1
  }
  let steps = if level < 0 { 0 } else { level }
  let mut index = 0
  while index < steps {
    size = size / 2
    if size < 1 {
      size = 1
    }
    index = index + 1
  }
  size
}

///|
/// 缩放为 1 时的边长，和第 0 级全分辨率的现有路径相同。
pub fn bloom_mip_size(base : Int, level : Int) -> Int {
  bloom_scaled_size(base, level, 1.0)
}

///|
/// 第 `level` 级的合成权重，`strength * lerpBloomFactor(bloomFactors[level], radius)`。
/// r186: `lerpBloomFactor` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/tsl/display/BloomNode.js#L579 ; `bloomFactors` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/tsl/display/BloomNode.js#L435
pub fn bloom_level_weight(
  level : Int,
  strength : Double,
  radius : Double,
) -> Double {
  let factor = match level {
    0 => 1.0
    1 => 0.8
    2 => 0.6
    3 => 0.4
    _ => 0.2
  }
  let t = clamp_radius(radius)
  strength * ((1.0 - t) * factor + t * (1.2 - factor))
}

///|
/// 全屏三角形。模式 0 是高通，1 是可分离高斯，2 把一级光加回原图，3 写出加权光，4 把加权光累加，5 把累加结果加回原图。
/// r186: `luminosityHighPass` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/tsl/display/BloomNode.js#L12
pub fn bloom_wgsl() -> String {
  let code =
    #|struct VertexOutput {
    #|  @builtin(position) clip : vec4<f32>,
    #|  @location(0) uv : vec2<f32>,
    #|}
    #|
    #|@vertex
    #|fn vs(@builtin(vertex_index) id : u32) -> VertexOutput {
    #|  let x = select(-1.0, 3.0, id == 1u);
    #|  let y = select(-1.0, 3.0, id == 2u);
    #|  var output : VertexOutput;
    #|  output.clip = vec4<f32>(x, y, 0.0, 1.0);
    #|  output.uv = vec2<f32>(x * 0.5 + 0.5, 0.5 - y * 0.5);
    #|  return output;
    #|}
    #|
    #|struct BloomParams {
    #|  threshold : f32,
    #|  smooth_width : f32,
    #|  strength : f32,
    #|  radius : f32,
    #|  texel_x : f32,
    #|  texel_y : f32,
    #|  dir_x : f32,
    #|  dir_y : f32,
    #|  mode : f32,
    #|  kernel : f32,
    #|  factor : f32,
    #|  tint_r : f32,
    #|  tint_g : f32,
    #|  tint_b : f32,
    #|  pad3 : f32,
    #|}
    #|
    #|@group(0) @binding(0) var color_tex : texture_2d<f32>;
    #|@group(0) @binding(1) var color_samp : sampler;
    #|@group(0) @binding(2) var glow_tex : texture_2d<f32>;
    #|@group(0) @binding(3) var glow_samp : sampler;
    #|@group(0) @binding(4) var<uniform> params : BloomParams;
    #|
    #|fn gauss(i : f32) -> f32 {
    #|  let sigma = max(params.kernel, 1.0) / 3.0;
    #|  return 0.39894 * exp(-0.5 * i * i / (sigma * sigma)) / sigma;
    #|}
    #|
    #|fn blur(uv : vec2<f32>) -> vec3<f32> {
    #|  var sum = textureSample(color_tex, color_samp, uv).rgb * gauss(0.0);
    #|  let radius = i32(max(params.kernel, 1.0));
    #|  for (var i = 1; i < radius; i = i + 2) {
    #|    let wa = gauss(f32(i));
    #|    let wb = select(gauss(f32(i + 1)), 0.0, i + 1 >= radius);
    #|    let w = wa + wb;
    #|    let offset = (f32(i) * wa + f32(i + 1) * wb) / max(w, 0.000001);
    #|    let delta = vec2<f32>(params.dir_x, params.dir_y) * vec2<f32>(params.texel_x, params.texel_y) * offset;
    #|    let left = textureSample(color_tex, color_samp, uv + delta).rgb;
    #|    let right = textureSample(color_tex, color_samp, uv - delta).rgb;
    #|    sum = sum + (left + right) * w;
    #|  }
    #|  return sum;
    #|}
    #|
    #|fn bloom_weight() -> f32 {
    #|  let t = clamp(params.radius, 0.0, 1.0);
    #|  let mirror = 1.2 - params.factor;
    #|  return params.strength * mix(params.factor, mirror, t);
    #|}
    #|
    #|@fragment
    #|fn fs(input : VertexOutput) -> @location(0) vec4<f32> {
    #|  let color = textureSample(color_tex, color_samp, input.uv);
    #|  if (params.mode < 0.5) {
    #|    let luma = dot(color.rgb, vec3<f32>(0.2126, 0.7152, 0.0722));
    #|    let span = max(params.smooth_width, 0.000001);
    #|    let t = clamp((luma - params.threshold) / span, 0.0, 1.0);
    #|    let alpha = t * t * (3.0 - 2.0 * t);
    #|    return vec4<f32>(color.rgb * alpha, color.a * alpha);
    #|  }
    #|  if (params.mode < 1.5) {
    #|    return vec4<f32>(blur(input.uv), 1.0);
    #|  }
    #|  let glow = textureSample(glow_tex, glow_samp, input.uv);
    #|  let weighted = glow.rgb * bloom_weight() * vec3<f32>(params.tint_r, params.tint_g, params.tint_b);
    #|  if (params.mode < 2.5) {
    #|    return vec4<f32>(color.rgb + weighted, color.a);
    #|  }
    #|  if (params.mode < 3.5) {
    #|    return vec4<f32>(weighted, 1.0);
    #|  }
    #|  if (params.mode < 4.5) {
    #|    return vec4<f32>(color.rgb + weighted, 1.0);
    #|  }
    #|  return vec4<f32>(color.rgb + glow.rgb, color.a);
    #|}
  code
}

