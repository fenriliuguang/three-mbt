///|
using @core {type Object3D}

///|
/// 场景根节点。背景色是可选的纯色，纹理背景留到阶段 5。
pub(all) struct Scene {
  node : Object3D
  mut background : @math.Color?
  mut background_blurriness : Double
  mut background_intensity : Double
}

///|
pub fn Scene::new() -> Scene {
  {
    node: Object3D::new(kind=@core.Scene),
    background: None,
    background_blurriness: 0.0,
    background_intensity: 1.0,
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
