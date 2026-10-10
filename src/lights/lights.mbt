// r186: `AmbientLight` https://github.com/mrdoob/three.js/blob/r186/src/lights/AmbientLight.js#L15 ; `DirectionalLight` https://github.com/mrdoob/three.js/blob/r186/src/lights/DirectionalLight.js#L32

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
