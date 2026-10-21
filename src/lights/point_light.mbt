// r186: `PointLight` https://github.com/mrdoob/three.js/blob/r186/src/lights/PointLight.js#L19

///|
/// 点光。`distance` 为 0 时不截断，`decay` 默认 2。这一阶段不投射阴影。
/// r186: `PointLight` https://github.com/mrdoob/three.js/blob/r186/src/lights/PointLight.js#L19
pub(all) struct PointLight {
  node : Object3D
}

///|
pub fn PointLight::new(
  hex~ : Int32 = 0xFFFFFF,
  intensity~ : Double = 1.0,
  distance~ : Double = 0.0,
  decay~ : Double = 2.0,
) -> PointLight {
  {
    node: make_light(
      @core.PointLight,
      @core.Point,
      hex,
      intensity,
      distance~,
      decay~,
    ),
  }
}

///|
pub impl @core.AsNode for PointLight with fn to_node(self) {
  self.node
}

///|
pub extend PointLight with @core.AsNode::{to_node}
