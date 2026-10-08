///|
using @core {type Object3D, type NodeKind, type LightKind, type LightState}

///|
fn make_light(
  kind : NodeKind,
  light_kind : LightKind,
  hex : Int,
  intensity : Double,
) -> Object3D {
  let node = Object3D::new(kind~)
  node.light = Some(LightState::{
    color: @math.Color::new().set_hex(hex),
    intensity,
    target: None,
    kind: light_kind,
  })
  node
}

///|
/// 环境光。颜色和强度先作为数据，阶段 4 才进入着色。
pub(all) struct AmbientLight {
  node : Object3D
}

///|
pub fn AmbientLight::new(
  hex? : Int = 0xFFFFFF,
  intensity? : Double = 1.0,
) -> AmbientLight {
  { node: make_light(@core.AmbientLight, @core.Ambient, hex, intensity), }
}

///|
pub impl @core.AsNode for AmbientLight with fn to_node(self) {
  self.node
}

///|
pub extend AmbientLight with @core.AsNode::{to_node}

///|
/// 平行光。从自身位置指向 `target`，默认位置是 `(0, 1, 0)`。
pub(all) struct DirectionalLight {
  node : Object3D
  target : Object3D
}

///|
pub fn DirectionalLight::new(
  hex? : Int = 0xFFFFFF,
  intensity? : Double = 1.0,
) -> DirectionalLight {
  let node = make_light(
    @core.DirectionalLight,
    @core.Directional,
    hex,
    intensity,
  )
  let target = Object3D::new()
  match node.light {
    None => ()
    Some(light) => light.target = Some(target)
  }
  ignore(node.position.set(0.0, 1.0, 0.0))
  node.update_matrix()
  { node, target, }
}

///|
pub impl @core.AsNode for DirectionalLight with fn to_node(self) {
  self.node
}

///|
pub extend DirectionalLight with @core.AsNode::{to_node}
