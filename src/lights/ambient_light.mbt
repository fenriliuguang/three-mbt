// r186: `AmbientLight` https://github.com/mrdoob/three.js/blob/r186/src/lights/AmbientLight.js#L15

///|
using @core {type Object3D, type NodeKind, type LightKind, type LightState}

///|
fn make_light(
  kind : NodeKind,
  light_kind : LightKind,
  hex : Int32,
  intensity : Double,
  distance~ : Double = 0.0,
  decay~ : Double = 2.0,
  angle~ : Double = 0.0,
  penumbra~ : Double = 0.0,
  ground~ : Int32 = 0xFFFFFF,
) -> Object3D {
  let node = Object3D::new(kind~)
  node.light = Some(LightState::{
    color: @math.Color::new().set_hex(hex),
    ground_color: @math.Color::new().set_hex(ground),
    intensity,
    distance,
    decay,
    angle,
    penumbra,
    target: None,
    kind: light_kind,
    shadow: None,
  })
  node
}

///|
/// 环境光。颜色和强度先作为数据，阶段 4 才进入着色。
/// r186: `AmbientLight` https://github.com/mrdoob/three.js/blob/r186/src/lights/AmbientLight.js#L15
pub(all) struct AmbientLight {
  node : Object3D
}

///|
pub fn AmbientLight::new(
  hex~ : Int32 = 0xFFFFFF,
  intensity~ : Double = 1.0,
) -> AmbientLight {
  { node: make_light(@core.AmbientLight, @core.Ambient, hex, intensity), }
}

///|
pub impl @core.AsNode for AmbientLight with fn to_node(self) {
  self.node
}

///|
pub extend AmbientLight with @core.AsNode::{to_node}
