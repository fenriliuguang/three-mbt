// r186: `AmbientLight` https://github.com/mrdoob/three.js/blob/r186/src/lights/AmbientLight.js#L15 ; `DirectionalLight` https://github.com/mrdoob/three.js/blob/r186/src/lights/DirectionalLight.js#L32 ; `PointLight` https://github.com/mrdoob/three.js/blob/r186/src/lights/PointLight.js#L19 ; `SpotLight` https://github.com/mrdoob/three.js/blob/r186/src/lights/SpotLight.js#L39 ; `HemisphereLight` https://github.com/mrdoob/three.js/blob/r186/src/lights/HemisphereLight.js#L18

///|
using @core {type Object3D, type NodeKind, type LightKind, type LightState}

///|
fn make_light(
  kind : NodeKind,
  light_kind : LightKind,
  hex : Int,
  intensity : Double,
  distance? : Double = 0.0,
  decay? : Double = 2.0,
  angle? : Double = 0.0,
  penumbra? : Double = 0.0,
  ground? : Int = 0xFFFFFF,
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
/// `shadow` 与节点上的阴影数据是同一个对象。`cast_shadow` 打开后才会渲染阴影贴图。
/// r186: `DirectionalLight` https://github.com/mrdoob/three.js/blob/r186/src/lights/DirectionalLight.js#L32
pub(all) struct DirectionalLight {
  node : Object3D
  target : Object3D
  shadow : @core.ShadowState
  camera : @cameras.OrthographicCamera
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
  let camera = @cameras.OrthographicCamera::new(
    left=-5.0,
    right=5.0,
    top=5.0,
    bottom=-5.0,
    near=0.5,
    far=500.0,
  )
  let shadow : @core.ShadowState = {
    camera: camera.node,
    map_size: 512,
    bias: 0.0,
    normal_bias: 0.0,
    radius: 1.0,
  }
  match node.light {
    None => ()
    Some(light) => light.shadow = Some(shadow)
  }
  { node, target, shadow, camera, }
}

///|
/// r186: `DirectionalLightShadow` https://github.com/mrdoob/three.js/blob/r186/src/lights/DirectionalLightShadow.js#L9
pub fn DirectionalLight::cast_shadow(
  self : DirectionalLight,
  enabled : Bool,
) -> Unit {
  self.node.cast_shadow = enabled
}

///|
/// 阴影正交相机的视锥，对应 r186 `light.shadow.camera`。
pub fn DirectionalLight::set_shadow_bounds(
  self : DirectionalLight,
  left : Double,
  right : Double,
  top : Double,
  bottom : Double,
  near : Double,
  far : Double,
) -> Unit {
  match self.camera.node.camera {
    None => ()
    Some(state) => {
      state.left = left
      state.right = right
      state.top = top
      state.bottom = bottom
      state.near = near
      state.far = far
      state.update_projection()
    }
  }
}

///|
pub impl @core.AsNode for DirectionalLight with fn to_node(self) {
  self.node
}

///|
pub extend DirectionalLight with @core.AsNode::{to_node}

///|
/// 点光。`distance` 为 0 时不截断，`decay` 默认 2。这一阶段不投射阴影。
/// r186: `PointLight` https://github.com/mrdoob/three.js/blob/r186/src/lights/PointLight.js#L19
pub(all) struct PointLight {
  node : Object3D
}

///|
pub fn PointLight::new(
  hex? : Int = 0xFFFFFF,
  intensity? : Double = 1.0,
  distance? : Double = 0.0,
  decay? : Double = 2.0,
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
