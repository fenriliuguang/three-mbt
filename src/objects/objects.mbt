///|
using @core {type Object3D, type BufferGeometry, type MeshBinding}

///|
/// 用来把若干节点当作一个整体变换。
pub(all) struct Group {
  node : Object3D
}

///|
pub fn Group::new() -> Group {
  { node: Object3D::new(kind=@core.Group), }
}

///|
pub impl @core.AsNode for Group with fn to_node(self) {
  self.node
}

///|
pub extend Group with @core.AsNode::{to_node}

///|
pub fn[T : @core.AsNode] Group::add(self : Group, child : T) -> Group {
  ignore(self.node.add(child.to_node()))
  self
}

///|
/// 三角网格。`geometry` 与 `material.color` 同时挂在场景节点上，遍历时可以读到。
pub(all) struct Mesh {
  node : Object3D
  geometry : BufferGeometry
  material : @materials.Material
}

///|
pub fn Mesh::new(
  geometry : BufferGeometry,
  material : @materials.Material,
) -> Mesh {
  let node = Object3D::new(kind=@core.Mesh)
  let mesh = { node, geometry, material, }
  mesh.refresh()
  mesh
}

///|
pub impl @core.AsNode for Mesh with fn to_node(self) {
  self.node
}

///|
pub extend Mesh with @core.AsNode::{to_node}

///|
/// 把材质上的侧面、透明度、线框和贴图写回节点。颜色本身是共享的，不需要复制。
pub fn Mesh::refresh(self : Mesh) -> Unit {
  self.node.mesh = Some(MeshBinding::{
    geometry: self.geometry,
    color: self.material.color,
    shading: self.material.shading(),
    side: self.material.side,
    opacity: self.material.opacity,
    transparent: self.material.transparent,
    wireframe: self.material.wireframe,
    map: self.material.map,
  })
}

///|
/// 换贴图并写回节点。直接改 `material.map` 不会更新绑定。
pub fn Mesh::set_map(self : Mesh, map : @textures.Texture?) -> Unit {
  self.material.map = map
  self.refresh()
}

///|
pub fn Mesh::set_side(self : Mesh, side : @constants.Side) -> Unit {
  self.material.side = side
  self.refresh()
}
