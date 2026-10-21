// r186: `HemisphereLight` https://github.com/mrdoob/three.js/blob/r186/src/lights/HemisphereLight.js#L18

///|
/// 半球光。天空色是灯光颜色，地面色默认白。位置默认 `(0, 1, 0)`，方向是世界坐标位置的归一化。
/// 不投射阴影。
/// r186: `HemisphereLight` https://github.com/mrdoob/three.js/blob/r186/src/lights/HemisphereLight.js#L27
pub(all) struct HemisphereLight {
  node : Object3D
}

///|
pub fn HemisphereLight::new(
  sky? : Int = 0xFFFFFF,
  ground? : Int = 0xFFFFFF,
  intensity? : Double = 1.0,
) -> HemisphereLight {
  let node = make_light(
    @core.HemisphereLight,
    @core.Hemisphere,
    sky,
    intensity,
    ground~,
  )
  ignore(node.position.set(0.0, 1.0, 0.0))
  node.update_matrix()
  { node, }
}

///|
pub impl @core.AsNode for HemisphereLight with fn to_node(self) {
  self.node
}

///|
pub extend HemisphereLight with @core.AsNode::{to_node}
