// r186: `_getBlending` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgpu/utils/WebGPUPipelineUtils.js#L552

///|
/// 颜色管线要用的混合方程。`Normal` 仍走原来的源 alpha 管线，不进这个结果。
/// 自定义因子留在上游。减色和相乘在 r186 里只有预乘那一组因子。
pub(all) enum BlendOp {
  Additive
  Subtractive
  Multiply
}

///|
/// 四个因子都是 `BlendFactor::to_int`。运算是相加。
/// r186: `_getBlending` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgpu/utils/WebGPUPipelineUtils.js#L600
pub(all) struct BlendEquation {
  op : BlendOp
  src_color : Int32
  dst_color : Int32
  src_alpha : Int32
  dst_alpha : Int32
}

///|
fn equation(
  op : BlendOp,
  src_color : @constants.BlendFactor,
  dst_color : @constants.BlendFactor,
  src_alpha : @constants.BlendFactor,
  dst_alpha : @constants.BlendFactor,
) -> BlendEquation {
  {
    op,
    src_color: src_color.to_int(),
    dst_color: dst_color.to_int(),
    src_alpha: src_alpha.to_int(),
    dst_alpha: dst_alpha.to_int(),
  }
}

///|
/// 加色、减色、相乘的因子。`No`、`Normal` 和 `Custom` 返回空，颜色通道继续用原来的开关。
/// 预乘打开时加色的四个因子都是 `One`。关掉时颜色源是 `SrcAlpha`，其余三个是 `One`。
/// 减色和相乘使用预乘分支的因子。r186 在没开预乘时直接报错，没有第二组数。
/// r186: `_getBlending` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgpu/utils/WebGPUPipelineUtils.js#L600
pub fn named_blend(
  blending : @constants.Blending,
  premultiplied : Bool,
) -> BlendEquation? {
  match blending {
    @constants.Additive =>
      if premultiplied {
        Some(
          equation(
            BlendOp::Additive,
            @constants.One,
            @constants.One,
            @constants.One,
            @constants.One,
          ),
        )
      } else {
        Some(
          equation(
            BlendOp::Additive,
            @constants.SrcAlpha,
            @constants.One,
            @constants.One,
            @constants.One,
          ),
        )
      }
    @constants.Subtractive =>
      Some(
        equation(
          BlendOp::Subtractive,
          @constants.Zero,
          @constants.OneMinusSrcColor,
          @constants.Zero,
          @constants.One,
        ),
      )
    @constants.Multiply =>
      Some(
        equation(
          BlendOp::Multiply,
          @constants.DstColor,
          @constants.OneMinusSrcAlpha,
          @constants.Zero,
          @constants.One,
        ),
      )
    _ => None
  }
}
