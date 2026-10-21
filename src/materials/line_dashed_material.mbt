// r186: `LineDashedMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineDashedMaterial.js#L19

///|
/// 虚线材质。线段字段放在内嵌的 `line` 上。
/// `scale` 默认 `1`，`dash_size` 默认 `3`，`gap_size` 默认 `1`。
/// `type_name` 对应上游 `type`，固定是 `LineDashedMaterial`。`copy` 不改目标上的这个名字。内嵌线段仍是 `LineBasicMaterial`。线段绘制仍不读这个名字。
/// 折线仍使用 `LineBasicMaterial`。着色器仍画实线。
/// r186: `LineDashedMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineDashedMaterial.js#L19
/// r186: `type` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineDashedMaterial.js#L42
/// r186: `scale` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineDashedMaterial.js#L50
/// r186: `dashSize` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineDashedMaterial.js#L58
/// r186: `gapSize` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineDashedMaterial.js#L66
pub(all) struct LineDashedMaterial {
  line : LineBasicMaterial
  mut scale : Double
  mut dash_size : Double
  mut gap_size : Double
  type_name : String
}

///|
pub fn LineDashedMaterial::new(
  hex~ : Int32 = 0xFFFFFF,
  scale~ : Double = 1.0,
  dash_size~ : Double = 3.0,
  gap_size~ : Double = 1.0,
) -> LineDashedMaterial {
  {
    line: LineBasicMaterial::new(hex~),
    scale,
    dash_size,
    gap_size,
    type_name: "LineDashedMaterial",
  }
}

///|
/// 内嵌线段材质按 `LineBasicMaterial.copy` 复制。虚线比例、线段长度和间隔一并复制。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineDashedMaterial.js#L72
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineBasicMaterial.js#L106
pub fn LineDashedMaterial::copy(
  self : LineDashedMaterial,
  source : LineDashedMaterial,
) -> LineDashedMaterial {
  ignore(self.line.copy(source.line))
  self.scale = source.scale
  self.dash_size = source.dash_size
  self.gap_size = source.gap_size
  self
}

///|
/// 没有单独的 `LineDashedMaterial.clone`。按 `Material.clone` 新建一份虚线材质，再 `copy`。新材质的 `type_name` 仍是 `LineDashedMaterial`，内嵌线段是新的 `LineBasicMaterial`，有自己的 `id` 和 `uuid`。`alpha_test` 穿过 `0` 时内嵌线段的 `version` 从 `0` 加一。线段绘制仍不读这份克隆。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1107
pub fn LineDashedMaterial::clone(
  self : LineDashedMaterial,
) -> LineDashedMaterial {
  LineDashedMaterial::new().copy(self)
}

///|
/// 没有单独的 `LineDashedMaterial.dispose`。通知内嵌线段上的 `dispose` 监听。其它事件不动。线段绘制仍不因这次调用释放资源。
/// r186: `dispose` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1207
pub fn LineDashedMaterial::dispose(self : LineDashedMaterial) -> Unit {
  self.line.dispose()
}

///|
/// 没有同名上游方法。距离先乘 `scale`，再对 `dash_size + gap_size` 取余。
/// 余数大于 `dash_size` 时落在间隔里，返回 false。周期为 0 时中止。
/// 着色器仍画实线。
/// r186: `vLineDistance` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderLib/linedashed.glsl.js#L17
/// r186: `mod` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderLib/linedashed.glsl.js#L55
/// r186: `totalSize` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLMaterials.js#L298
pub fn LineDashedMaterial::keeps_distance(
  self : LineDashedMaterial,
  distance : Double,
) -> Bool {
  let total = self.dash_size + self.gap_size
  if total == 0.0 {
    abort("LineDashedMaterial dash period is zero")
  }
  let scaled = self.scale * distance
  let wrapped = scaled - total * (scaled / total).floor()
  wrapped <= self.dash_size
}
