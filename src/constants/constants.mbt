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
/// 网格怎么着色。`Basic` 忽略灯光，`Lambert` 使用环境光和一盏平行光。
pub(all) enum Shading {
  Basic
  Lambert
}

///|
pub fn CoordinateSystem::to_int(self : CoordinateSystem) -> Int {
  match self {
    WebGL => WEBGL_COORDINATE_SYSTEM
    WebGPU => WEBGPU_COORDINATE_SYSTEM
  }
}
