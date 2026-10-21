// r186: `SpotLight` https://github.com/mrdoob/three.js/blob/r186/src/lights/SpotLight.js#L39

///|
/// 聚光。从自身位置指向 `target`，默认位置是 `(0, 1, 0)`。
/// `angle` 默认 `π/3`，`penumbra` 默认 0。这一阶段不投射阴影。
/// r186: `SpotLight` https://github.com/mrdoob/three.js/blob/r186/src/lights/SpotLight.js#L39
pub(all) struct SpotLight {
  node : Object3D
  target : Object3D
}

///|
pub fn SpotLight::new(
  hex? : Int = 0xFFFFFF,
  intensity? : Double = 1.0,
  distance? : Double = 0.0,
  angle? : Double = @std.PI / 3.0,
  penumbra? : Double = 0.0,
  decay? : Double = 2.0,
) -> SpotLight {
  let node = make_light(
    @core.SpotLight,
    @core.Spot,
    hex,
    intensity,
    distance~,
    decay~,
    angle~,
    penumbra~,
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
pub impl @core.AsNode for SpotLight with fn to_node(self) {
  self.node
}

///|
pub extend SpotLight with @core.AsNode::{to_node}

