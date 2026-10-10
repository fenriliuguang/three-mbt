// r186: `FrontSide` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L92 ; `RepeatWrapping` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L556 ; `NearestFilter` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L581 ; `LoopOnce` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1125 ; `WebGPUCoordinateSystem` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1664 ; `NoToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L423

///|
/// 正面。对齐 three.js r186 `FrontSide`（0）。
pub const FRONT_SIDE : Int = 0

///|
/// 背面。对齐 `BackSide`（1）。
pub const BACK_SIDE : Int = 1

///|
/// 双面。对齐 `DoubleSide`（2）。
pub const DOUBLE_SIDE : Int = 2

///|
/// 三角形绕序。数值与 r186 `src/constants.js` 一致。
/// r186: `FrontSide` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L92 ; `DoubleSide` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L108
pub(all) enum Side {
  Front
  Back
  Double
}

///|
/// WebGL 裁剪空间，深度 NDC 为 \[-1, 1\]。对齐 `WebGLCoordinateSystem`（2000）。
pub const WEBGL_COORDINATE_SYSTEM : Int = 2000

///|
/// WebGPU 裁剪空间，深度 NDC 为 \[0, 1\]。对齐 `WebGPUCoordinateSystem`（2001）。
pub const WEBGPU_COORDINATE_SYSTEM : Int = 2001

///|
/// 投影矩阵使用的坐标系。本仓库默认 WebGPU。
/// r186: `WebGLCoordinateSystem` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1656 ; `WebGPUCoordinateSystem` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1664
pub(all) enum CoordinateSystem {
  WebGL
  WebGPU
}

///|
pub fn Side::to_int(self : Side) -> Int {
  match self {
    Front => FRONT_SIDE
    Back => BACK_SIDE
    Double => DOUBLE_SIDE
  }
}

///|
/// 网格怎么着色。`Basic` 忽略灯光，`Lambert` 使用环境光和一盏平行光，`Standard` 走直接光 GGX。
/// r186: 没有同名枚举。`Basic` `MeshBasicMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L14 ; `Lambert` `MeshLambertMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L24 ; `Standard` `MeshStandardMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L41
pub(all) enum Shading {
  Basic
  Lambert
  Standard
}

///|
pub fn CoordinateSystem::to_int(self : CoordinateSystem) -> Int {
  match self {
    WebGL => WEBGL_COORDINATE_SYSTEM
    WebGPU => WEBGPU_COORDINATE_SYSTEM
  }
}

///|
/// 纹理 U 向重复。对齐 r186 `RepeatWrapping`（1000）。
pub const REPEAT_WRAPPING : Int = 1000

///|
/// 纹理钳制到边缘。对齐 `ClampToEdgeWrapping`（1001）。
pub const CLAMP_TO_EDGE_WRAPPING : Int = 1001

///|
/// 纹理镜像重复。对齐 `MirroredRepeatWrapping`（1002）。
pub const MIRRORED_REPEAT_WRAPPING : Int = 1002

///|
/// 最近邻采样。对齐 `NearestFilter`（1003）。
pub const NEAREST_FILTER : Int = 1003

///|
/// 对齐 `NearestMipmapNearestFilter`（1004）。
pub const NEAREST_MIPMAP_NEAREST_FILTER : Int = 1004

///|
/// 对齐 `NearestMipmapLinearFilter`（1005）。
pub const NEAREST_MIPMAP_LINEAR_FILTER : Int = 1005

///|
/// 线性采样。对齐 `LinearFilter`（1006）。
pub const LINEAR_FILTER : Int = 1006

///|
/// 对齐 `LinearMipmapNearestFilter`（1007）。
pub const LINEAR_MIPMAP_NEAREST_FILTER : Int = 1007

///|
/// 对齐 `LinearMipmapLinearFilter`（1008）。这是 r186 纹理的默认缩小过滤。
pub const LINEAR_MIPMAP_LINEAR_FILTER : Int = 1008

///|
/// 纹理包裹方式。数值与 r186 `src/constants.js` 一致。
/// r186: `RepeatWrapping` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L556
pub(all) enum Wrapping {
  Repeat
  ClampToEdge
  MirroredRepeat
}

///|
/// 纹理放大或缩小过滤。本阶段不生成 mipmap，mipmap 项只决定采样器怎么声明。
/// r186: `NearestFilter` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L581 ; `LinearFilter` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L613
pub(all) enum TextureFilter {
  Nearest
  NearestMipmapNearest
  NearestMipmapLinear
  Linear
  LinearMipmapNearest
  LinearMipmapLinear
}

///|
pub fn Wrapping::to_int(self : Wrapping) -> Int {
  match self {
    Repeat => REPEAT_WRAPPING
    ClampToEdge => CLAMP_TO_EDGE_WRAPPING
    MirroredRepeat => MIRRORED_REPEAT_WRAPPING
  }
}

///|
pub fn TextureFilter::to_int(self : TextureFilter) -> Int {
  match self {
    Nearest => NEAREST_FILTER
    NearestMipmapNearest => NEAREST_MIPMAP_NEAREST_FILTER
    NearestMipmapLinear => NEAREST_MIPMAP_LINEAR_FILTER
    Linear => LINEAR_FILTER
    LinearMipmapNearest => LINEAR_MIPMAP_NEAREST_FILTER
    LinearMipmapLinear => LINEAR_MIPMAP_LINEAR_FILTER
  }
}

///|
/// 放大或缩小是否走最近邻。带 mipmap 的名称仍看主过滤，不看 mipmap 那一段。
pub fn TextureFilter::is_nearest(self : TextureFilter) -> Bool {
  match self {
    Nearest => true
    NearestMipmapNearest => true
    NearestMipmapLinear => true
    _ => false
  }
}

///|
/// mipmap 过滤是否为线性。纹理只有一级时，这一位不改变第 0 级的采样结果。
pub fn TextureFilter::mip_linear(self : TextureFilter) -> Bool {
  match self {
    NearestMipmapLinear => true
    LinearMipmapLinear => true
    _ => false
  }
}

///|
/// 播完一次就停。对齐 `LoopOnce`（2200）。
pub const LOOP_ONCE : Int = 2200

///|
/// 循环。对齐 `LoopRepeat`（2201）。
pub const LOOP_REPEAT : Int = 2201

///|
/// 往返。对齐 `LoopPingPong`（2202）。
pub const LOOP_PING_PONG : Int = 2202

///|
/// 关键帧直接取左边那一帧。对齐 `InterpolateDiscrete`（2300）。
pub const INTERPOLATE_DISCRETE : Int = 2300

///|
/// 关键帧线性插值。对齐 `InterpolateLinear`（2301）。
pub const INTERPOLATE_LINEAR : Int = 2301

///|
/// 三次样条。对齐 `InterpolateSmooth`（2302）。这一阶段还不采样它。
pub const INTERPOLATE_SMOOTH : Int = 2302

///|
/// 动画循环方式。
/// r186: `LoopOnce` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1125 ; `LoopRepeat` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1134
pub(all) enum LoopMode {
  Once
  Repeat
  PingPong
}

///|
/// 关键帧插值。`Smooth` 的数值留在常量里，采样只用离散和线性。
/// r186: `InterpolateDiscrete` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1151 ; `InterpolateLinear` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1159 ; `InterpolateSmooth` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1167
pub(all) enum Interpolation {
  Discrete
  Linear
}

///|
pub fn LoopMode::to_int(self : LoopMode) -> Int {
  match self {
    Once => LOOP_ONCE
    Repeat => LOOP_REPEAT
    PingPong => LOOP_PING_PONG
  }
}

///|
pub fn Interpolation::to_int(self : Interpolation) -> Int {
  match self {
    Discrete => INTERPOLATE_DISCRETE
    Linear => INTERPOLATE_LINEAR
  }
}

///|
/// 不做色调映射。对齐 `NoToneMapping`（0）。
pub const NO_TONE_MAPPING : Int = 0

///|
/// 乘以曝光后夹到 \[0, 1\]。对齐 `LinearToneMapping`（1）。
pub const LINEAR_TONE_MAPPING : Int = 1

///|
/// `scaled / (scaled + 1)`。对齐 `ReinhardToneMapping`（2）。
pub const REINHARD_TONE_MAPPING : Int = 2

///|
/// Hejl/Burgess-Dawson 胶片曲线。对齐 `CineonToneMapping`（3）。
pub const CINEON_TONE_MAPPING : Int = 3

///|
/// ACES RRT+ODT 拟合。对齐 `ACESFilmicToneMapping`（4）。
pub const ACES_FILMIC_TONE_MAPPING : Int = 4

///|
/// 由调用方自己改着色器。对齐 `CustomToneMapping`（5）。这一阶段还不采样它。
pub const CUSTOM_TONE_MAPPING : Int = 5

///|
/// AgX。对齐 `AgXToneMapping`（6）。
pub const AGX_TONE_MAPPING : Int = 6

///|
/// Khronos Neutral。对齐 `NeutralToneMapping`（7）。
pub const NEUTRAL_TONE_MAPPING : Int = 7

///|
/// `Custom` 仍只留数值，不采样。其余七种都有曲线。
/// r186: `NoToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L423 ; `LinearToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L431 ; `ReinhardToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L439 ; `CineonToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L447 ; `ACESFilmicToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L455 ; `AgXToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L473 ; `NeutralToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L483
pub(all) enum ToneMapping {
  No
  Linear
  Reinhard
  Cineon
  ACES
  AgX
  Neutral
}

///|
pub fn ToneMapping::to_int(self : ToneMapping) -> Int {
  match self {
    No => NO_TONE_MAPPING
    Linear => LINEAR_TONE_MAPPING
    Reinhard => REINHARD_TONE_MAPPING
    Cineon => CINEON_TONE_MAPPING
    ACES => ACES_FILMIC_TONE_MAPPING
    AgX => AGX_TONE_MAPPING
    Neutral => NEUTRAL_TONE_MAPPING
  }
}
