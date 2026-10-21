// r186: `Scene` https://github.com/mrdoob/three.js/blob/r186/src/scenes/Scene.js#L10

///|
using @core {type Object3D}

///|
/// 场景根节点。背景色是可选的纯色。雾是可选的线性雾或指数平方雾。
/// r186: `Scene` https://github.com/mrdoob/three.js/blob/r186/src/scenes/Scene.js#L10
pub(all) struct Scene {
  node : Object3D
  mut background : @math.Color?
  mut background_blurriness : Double
  mut background_intensity : Double
  mut fog : Fog?
}

///|
pub fn Scene::new() -> Scene {
  {
    node: Object3D::new(kind=@core.Scene),
    background: None,
    background_blurriness: 0.0,
    background_intensity: 1.0,
    fog: None,
  }
}

///|
pub impl @core.AsNode for Scene with fn to_node(self) {
  self.node
}

///|
pub extend Scene with @core.AsNode::{to_node}

///|
pub fn[T : @core.AsNode] Scene::add(self : Scene, child : T) -> Scene {
  ignore(self.node.add(child.to_node()))
  self
}

///|
pub fn Scene::set_background(self : Scene, color : @math.Color) -> Unit {
  self.background = Some(color)
}

///|
/// `None` 表示这一帧不画雾。
pub fn Scene::set_fog(self : Scene, fog : Fog?) -> Unit {
  self.fog = fog
}
