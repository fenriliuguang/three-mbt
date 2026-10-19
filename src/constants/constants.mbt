// r186: `FrontSide` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L92 ; `NeverDepth` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L335 ; `RepeatWrapping` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L556 ; `NearestFilter` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L581 ; `LoopOnce` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1125 ; `WebGPUCoordinateSystem` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1664 ; `NoToneMapping` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L423 ; `AttachedBindMode` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L491 ; `RGBAFormat` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L763 ; `RedFormat` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L788

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
/// 蒙皮网格和骨架是否共享世界空间。默认是附着。
/// r186: `AttachedBindMode` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L491 ; `DetachedBindMode` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L500
pub(all) enum BindMode {
  Attached
  Detached
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
/// 不做混合。对齐 `NoBlending`（0）。
pub const NO_BLENDING : Int = 0

///|
/// 默认混合。对齐 `NormalBlending`（1）。
pub const NORMAL_BLENDING : Int = 1

///|
/// 相加混合。对齐 `AdditiveBlending`（2）。
pub const ADDITIVE_BLENDING : Int = 2

///|
/// 相减混合。对齐 `SubtractiveBlending`（3）。
pub const SUBTRACTIVE_BLENDING : Int = 3

///|
/// 相乘混合。对齐 `MultiplyBlending`（4）。
pub const MULTIPLY_BLENDING : Int = 4

///|
/// 自定义混合。对齐 `CustomBlending`（5）。
pub const CUSTOM_BLENDING : Int = 5

///|
/// 材质混合模式。数值与 r186 `src/constants.js` 一致。默认是 `Normal`。
/// r186: `NoBlending` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L117 ; `NormalBlending` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L125 ; `AdditiveBlending` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L133 ; `SubtractiveBlending` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L141 ; `MultiplyBlending` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L149 ; `CustomBlending` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L157
pub(all) enum Blending {
  No
  Normal
  Additive
  Subtractive
  Multiply
  Custom
}

///|
pub fn Blending::to_int(self : Blending) -> Int {
  match self {
    No => NO_BLENDING
    Normal => NORMAL_BLENDING
    Additive => ADDITIVE_BLENDING
    Subtractive => SUBTRACTIVE_BLENDING
    Multiply => MULTIPLY_BLENDING
    Custom => CUSTOM_BLENDING
  }
}

///|
/// 混合因子乘 `0`。对齐 `ZeroFactor`（200）。
pub const ZERO_FACTOR : Int = 200

///|
/// 混合因子乘 `1`。对齐 `OneFactor`（201）。
pub const ONE_FACTOR : Int = 201

///|
/// 混合因子乘源颜色。对齐 `SrcColorFactor`（202）。
pub const SRC_COLOR_FACTOR : Int = 202

///|
/// 混合因子乘 `1` 减源颜色。对齐 `OneMinusSrcColorFactor`（203）。
pub const ONE_MINUS_SRC_COLOR_FACTOR : Int = 203

///|
/// 混合因子乘源 alpha。对齐 `SrcAlphaFactor`（204）。
pub const SRC_ALPHA_FACTOR : Int = 204

///|
/// 混合因子乘 `1` 减源 alpha。对齐 `OneMinusSrcAlphaFactor`（205）。
pub const ONE_MINUS_SRC_ALPHA_FACTOR : Int = 205

///|
/// 混合因子乘目标 alpha。对齐 `DstAlphaFactor`（206）。
pub const DST_ALPHA_FACTOR : Int = 206

///|
/// 混合因子乘 `1` 减目标 alpha。对齐 `OneMinusDstAlphaFactor`（207）。
pub const ONE_MINUS_DST_ALPHA_FACTOR : Int = 207

///|
/// 混合因子乘目标颜色。对齐 `DstColorFactor`（208）。
pub const DST_COLOR_FACTOR : Int = 208

///|
/// 混合因子乘 `1` 减目标颜色。对齐 `OneMinusDstColorFactor`（209）。
pub const ONE_MINUS_DST_COLOR_FACTOR : Int = 209

///|
/// RGB 乘源 alpha 与 `1` 减目标 alpha 的较小值，alpha 乘 `1`。对齐 `SrcAlphaSaturateFactor`（210）。
pub const SRC_ALPHA_SATURATE_FACTOR : Int = 210

///|
/// 混合因子乘常量颜色。对齐 `ConstantColorFactor`（211）。
pub const CONSTANT_COLOR_FACTOR : Int = 211

///|
/// 混合因子乘 `1` 减常量颜色。对齐 `OneMinusConstantColorFactor`（212）。
pub const ONE_MINUS_CONSTANT_COLOR_FACTOR : Int = 212

///|
/// 混合因子乘常量 alpha。对齐 `ConstantAlphaFactor`（213）。
pub const CONSTANT_ALPHA_FACTOR : Int = 213

///|
/// 混合因子乘 `1` 减常量 alpha。对齐 `OneMinusConstantAlphaFactor`（214）。
pub const ONE_MINUS_CONSTANT_ALPHA_FACTOR : Int = 214

///|
/// 混合源因子和目标因子。数值与 r186 `src/constants.js` 一致。默认是 `SrcAlpha`。
/// r186: `ZeroFactor` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L213 ; `SrcAlphaFactor` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L245 ; `OneMinusConstantAlphaFactor` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L327
pub(all) enum BlendFactor {
  Zero
  One
  SrcColor
  OneMinusSrcColor
  SrcAlpha
  OneMinusSrcAlpha
  DstAlpha
  OneMinusDstAlpha
  DstColor
  OneMinusDstColor
  SrcAlphaSaturate
  ConstantColor
  OneMinusConstantColor
  ConstantAlpha
  OneMinusConstantAlpha
}

///|
pub fn BlendFactor::to_int(self : BlendFactor) -> Int {
  match self {
    Zero => ZERO_FACTOR
    One => ONE_FACTOR
    SrcColor => SRC_COLOR_FACTOR
    OneMinusSrcColor => ONE_MINUS_SRC_COLOR_FACTOR
    SrcAlpha => SRC_ALPHA_FACTOR
    OneMinusSrcAlpha => ONE_MINUS_SRC_ALPHA_FACTOR
    DstAlpha => DST_ALPHA_FACTOR
    OneMinusDstAlpha => ONE_MINUS_DST_ALPHA_FACTOR
    DstColor => DST_COLOR_FACTOR
    OneMinusDstColor => ONE_MINUS_DST_COLOR_FACTOR
    SrcAlphaSaturate => SRC_ALPHA_SATURATE_FACTOR
    ConstantColor => CONSTANT_COLOR_FACTOR
    OneMinusConstantColor => ONE_MINUS_CONSTANT_COLOR_FACTOR
    ConstantAlpha => CONSTANT_ALPHA_FACTOR
    OneMinusConstantAlpha => ONE_MINUS_CONSTANT_ALPHA_FACTOR
  }
}

///|
/// 源加目标。对齐 `AddEquation`（100）。
pub const ADD_EQUATION : Int = 100

///|
/// 源减目标。对齐 `SubtractEquation`（101）。
pub const SUBTRACT_EQUATION : Int = 101

///|
/// 目标减源。对齐 `ReverseSubtractEquation`（102）。
pub const REVERSE_SUBTRACT_EQUATION : Int = 102

///|
/// 取源和目标的较小值。对齐 `MinEquation`（103）。
pub const MIN_EQUATION : Int = 103

///|
/// 取源和目标的较大值。对齐 `MaxEquation`（104）。
pub const MAX_EQUATION : Int = 104

///|
/// 混合方程。数值与 r186 `src/constants.js` 一致。默认是 `Add`。
/// r186: `AddEquation` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L173 ; `SubtractEquation` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L181 ; `ReverseSubtractEquation` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L189 ; `MinEquation` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L197 ; `MaxEquation` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L205
pub(all) enum BlendEquation {
  Add
  Subtract
  ReverseSubtract
  Min
  Max
}

///|
pub fn BlendEquation::to_int(self : BlendEquation) -> Int {
  match self {
    Add => ADD_EQUATION
    Subtract => SUBTRACT_EQUATION
    ReverseSubtract => REVERSE_SUBTRACT_EQUATION
    Min => MIN_EQUATION
    Max => MAX_EQUATION
  }
}

///|
/// 深度测试通过的条件。数值与 r186 `src/constants.js` 一致。默认是 `LessEqual`。
/// r186: `NeverDepth` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L335 ; `LessEqualDepth` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L359
pub(all) enum DepthFunc {
  Never
  Always
  Less
  LessEqual
  Equal
  GreaterEqual
  Greater
  NotEqual
}

///|
/// 深度测试永不通过。对齐 `NeverDepth`（0）。
pub const NEVER_DEPTH : Int = 0

///|
/// 深度测试始终通过。对齐 `AlwaysDepth`（1）。
pub const ALWAYS_DEPTH : Int = 1

///|
/// 新深度小于已有深度才通过。对齐 `LessDepth`（2）。
pub const LESS_DEPTH : Int = 2

///|
/// 新深度小于或等于已有深度才通过。对齐 `LessEqualDepth`（3）。
pub const LESS_EQUAL_DEPTH : Int = 3

///|
/// 深度相等才通过。对齐 `EqualDepth`（4）。
pub const EQUAL_DEPTH : Int = 4

///|
/// 新深度大于或等于已有深度才通过。对齐 `GreaterEqualDepth`（5）。
pub const GREATER_EQUAL_DEPTH : Int = 5

///|
/// 新深度大于已有深度才通过。对齐 `GreaterDepth`（6）。
pub const GREATER_DEPTH : Int = 6

///|
/// 深度不相等才通过。对齐 `NotEqualDepth`（7）。
pub const NOT_EQUAL_DEPTH : Int = 7

///|
pub fn DepthFunc::to_int(self : DepthFunc) -> Int {
  match self {
    Never => NEVER_DEPTH
    Always => ALWAYS_DEPTH
    Less => LESS_DEPTH
    LessEqual => LESS_EQUAL_DEPTH
    Equal => EQUAL_DEPTH
    GreaterEqual => GREATER_EQUAL_DEPTH
    Greater => GREATER_DEPTH
    NotEqual => NOT_EQUAL_DEPTH
  }
}

///|
/// 反向深度缓冲下的比较函数。`Never` 对 `Always`，`Equal` 对 `NotEqual`，不等号反过来。
/// r186: `ReversedDepthFuncs` https://github.com/mrdoob/three.js/blob/r186/src/utils.js#L481
pub fn DepthFunc::reversed(self : DepthFunc) -> DepthFunc {
  match self {
    Never => Always
    Less => Greater
    Equal => NotEqual
    LessEqual => GreaterEqual
    Always => Never
    Greater => Less
    NotEqual => Equal
    GreaterEqual => LessEqual
  }
}

///|
/// 模板比较永不通过。对齐 `NeverStencilFunc`（512）。
pub const NEVER_STENCIL_FUNC : Int = 512

///|
/// 参考值小于模板值才通过。对齐 `LessStencilFunc`（513）。
pub const LESS_STENCIL_FUNC : Int = 513

///|
/// 参考值等于模板值才通过。对齐 `EqualStencilFunc`（514）。
pub const EQUAL_STENCIL_FUNC : Int = 514

///|
/// 参考值小于或等于模板值才通过。对齐 `LessEqualStencilFunc`（515）。
pub const LESS_EQUAL_STENCIL_FUNC : Int = 515

///|
/// 参考值大于模板值才通过。对齐 `GreaterStencilFunc`（516）。
pub const GREATER_STENCIL_FUNC : Int = 516

///|
/// 参考值不等于模板值才通过。对齐 `NotEqualStencilFunc`（517）。
pub const NOT_EQUAL_STENCIL_FUNC : Int = 517

///|
/// 参考值大于或等于模板值才通过。对齐 `GreaterEqualStencilFunc`（518）。
pub const GREATER_EQUAL_STENCIL_FUNC : Int = 518

///|
/// 模板比较始终通过。对齐 `AlwaysStencilFunc`（519）。
pub const ALWAYS_STENCIL_FUNC : Int = 519

///|
/// 模板比较函数。数值与 r186 `src/constants.js` 一致。默认是 `Always`。
/// r186: `NeverStencilFunc` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1431 ; `LessStencilFunc` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1439 ; `EqualStencilFunc` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1447 ; `LessEqualStencilFunc` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1455 ; `GreaterStencilFunc` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1463 ; `NotEqualStencilFunc` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1471 ; `GreaterEqualStencilFunc` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1479 ; `AlwaysStencilFunc` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1487
pub(all) enum StencilFunc {
  Never
  Less
  Equal
  LessEqual
  Greater
  NotEqual
  GreaterEqual
  Always
}

///|
pub fn StencilFunc::to_int(self : StencilFunc) -> Int {
  match self {
    Never => NEVER_STENCIL_FUNC
    Less => LESS_STENCIL_FUNC
    Equal => EQUAL_STENCIL_FUNC
    LessEqual => LESS_EQUAL_STENCIL_FUNC
    Greater => GREATER_STENCIL_FUNC
    NotEqual => NOT_EQUAL_STENCIL_FUNC
    GreaterEqual => GREATER_EQUAL_STENCIL_FUNC
    Always => ALWAYS_STENCIL_FUNC
  }
}

///|
/// 把模板值写成 0。对齐 `ZeroStencilOp`（0）。
pub const ZERO_STENCIL_OP : Int = 0

///|
/// 保持模板值。对齐 `KeepStencilOp`（7680）。
pub const KEEP_STENCIL_OP : Int = 7680

///|
/// 把模板值写成参考值。对齐 `ReplaceStencilOp`（7681）。
pub const REPLACE_STENCIL_OP : Int = 7681

///|
/// 模板值加 1，到上限后夹住。对齐 `IncrementStencilOp`（7682）。
pub const INCREMENT_STENCIL_OP : Int = 7682

///|
/// 模板值减 1，到 0 后夹住。对齐 `DecrementStencilOp`（7683）。
pub const DECREMENT_STENCIL_OP : Int = 7683

///|
/// 模板值加 1，溢出后回到 0。对齐 `IncrementWrapStencilOp`（34055）。
pub const INCREMENT_WRAP_STENCIL_OP : Int = 34055

///|
/// 模板值减 1，低于 0 后回到上限。对齐 `DecrementWrapStencilOp`（34056）。
pub const DECREMENT_WRAP_STENCIL_OP : Int = 34056

///|
/// 按位取反模板值。对齐 `InvertStencilOp`（5386）。
pub const INVERT_STENCIL_OP : Int = 5386

///|
/// 模板操作。数值与 r186 `src/constants.js` 一致。默认是 `Keep`。
/// r186: `ZeroStencilOp` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1365 ; `KeepStencilOp` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1373 ; `ReplaceStencilOp` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1381 ; `IncrementStencilOp` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1389 ; `DecrementStencilOp` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1397 ; `IncrementWrapStencilOp` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1406 ; `DecrementWrapStencilOp` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1415 ; `InvertStencilOp` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1423
pub(all) enum StencilOp {
  Zero
  Keep
  Replace
  Increment
  Decrement
  IncrementWrap
  DecrementWrap
  Invert
}

///|
pub fn StencilOp::to_int(self : StencilOp) -> Int {
  match self {
    Zero => ZERO_STENCIL_OP
    Keep => KEEP_STENCIL_OP
    Replace => REPLACE_STENCIL_OP
    Increment => INCREMENT_STENCIL_OP
    Decrement => DECREMENT_STENCIL_OP
    IncrementWrap => INCREMENT_WRAP_STENCIL_OP
    DecrementWrap => DECREMENT_WRAP_STENCIL_OP
    Invert => INVERT_STENCIL_OP
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
/// 纹素通道。`RGBA` 是四个浮点，`Red` 是一个浮点。
/// r186: `RGBAFormat` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L763 ; `RedFormat` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L788
pub(all) enum PixelFormat {
  RGBA
  Red
}

///|
pub fn PixelFormat::to_int(self : PixelFormat) -> Int {
  match self {
    RGBA => 1023
    Red => 1028
  }
}

///|
/// 每个纹素的浮点个数。
pub fn PixelFormat::components(self : PixelFormat) -> Int {
  match self {
    RGBA => 4
    Red => 1
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
/// 三次样条。对齐 `InterpolateSmooth`（2302）。向量轨道会采样它。
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
/// 关键帧插值。向量轨道的 `Smooth` 是零曲率端点的三次样条。四元数没有这条工厂。
/// r186: `InterpolateDiscrete` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1151 ; `InterpolateLinear` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1159 ; `InterpolateSmooth` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1167
pub(all) enum Interpolation {
  Discrete
  Linear
  Smooth
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
    Smooth => INTERPOLATE_SMOOTH
  }
}

///|
/// 样条起点零曲率。对齐 `ZeroCurvatureEnding`（2400）。
pub const ZERO_CURVATURE_ENDING : Int = 2400

///|
/// 样条端点零斜率。对齐 `ZeroSlopeEnding`（2401）。
pub const ZERO_SLOPE_ENDING : Int = 2401

///|
/// 样条两端环绕。对齐 `WrapAroundEnding`（2402）。
pub const WRAP_AROUND_ENDING : Int = 2402

///|
/// 三次样条的端点条件。`CubicInterpolant` 默认两端都是零曲率。
/// r186: `ZeroCurvatureEnding` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1186 ; `ZeroSlopeEnding` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1194 ; `WrapAroundEnding` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1202
pub(all) enum SplineEnding {
  ZeroCurvature
  ZeroSlope
  WrapAround
}

///|
pub fn SplineEnding::to_int(self : SplineEnding) -> Int {
  match self {
    ZeroCurvature => ZERO_CURVATURE_ENDING
    ZeroSlope => ZERO_SLOPE_ENDING
    WrapAround => WRAP_AROUND_ENDING
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

///|
/// 缓冲区静态绘制。对齐 `StaticDrawUsage`（35044）。
/// r186: `StaticDrawUsage` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1560
pub const STATIC_DRAW_USAGE : Int = 35044

///|
/// 缓冲区动态绘制。对齐 `DynamicDrawUsage`（35048）。
/// r186: `DynamicDrawUsage` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1569
pub const DYNAMIC_DRAW_USAGE : Int = 35048

///|
/// 缓冲区流式绘制。对齐 `StreamDrawUsage`（35040）。
/// r186: `StreamDrawUsage` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1578
pub const STREAM_DRAW_USAGE : Int = 35040

///|
/// 缓冲区静态读取。对齐 `StaticReadUsage`（35045）。
/// r186: `StaticReadUsage` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1587
pub const STATIC_READ_USAGE : Int = 35045

///|
/// 缓冲区动态读取。对齐 `DynamicReadUsage`（35049）。
/// r186: `DynamicReadUsage` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1596
pub const DYNAMIC_READ_USAGE : Int = 35049

///|
/// 缓冲区流式读取。对齐 `StreamReadUsage`（35041）。
/// r186: `StreamReadUsage` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1605
pub const STREAM_READ_USAGE : Int = 35041

///|
/// 缓冲区静态复制。对齐 `StaticCopyUsage`（35046）。
/// r186: `StaticCopyUsage` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1614
pub const STATIC_COPY_USAGE : Int = 35046

///|
/// 缓冲区动态复制。对齐 `DynamicCopyUsage`（35050）。
/// r186: `DynamicCopyUsage` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1623
pub const DYNAMIC_COPY_USAGE : Int = 35050

///|
/// 缓冲区流式复制。对齐 `StreamCopyUsage`（35042）。
/// r186: `StreamCopyUsage` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L1632
pub const STREAM_COPY_USAGE : Int = 35042

///|
/// 整数纹理类型。对齐 `IntType`（1013）。
/// r186: `IntType` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L675
pub const INT_TYPE : Int = 1013

///|
/// 浮点纹理类型。对齐 `FloatType`（1015）。
/// r186: `FloatType` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L691
pub const FLOAT_TYPE : Int = 1015
