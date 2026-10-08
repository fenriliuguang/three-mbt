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
  let mesh : Mesh = { node, geometry, material, }
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
/// 把材质上的侧面、透明度、线框、贴图、粗糙度和金属度写回节点。颜色本身是共享的，不需要复制。
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
    roughness: self.material.roughness,
    metalness: self.material.metalness,
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

///|
fn primitive_binding(
  geometry : BufferGeometry,
  color : @math.Color,
  kind : @core.PrimitiveKind,
  size : Double,
  size_attenuation : Bool,
  opacity : Double,
  transparent : Bool,
) -> @core.PrimitiveBinding {
  { geometry, color, kind, size, size_attenuation, opacity, transparent, }
}

///|
/// 点。每个位置画一个朝向相机的四边形。
pub(all) struct Points {
  node : Object3D
  geometry : BufferGeometry
  material : @materials.PointsMaterial
}

///|
pub fn Points::new(
  geometry : BufferGeometry,
  material : @materials.PointsMaterial,
) -> Points {
  let node = Object3D::new(kind=@core.NodeKind::Points)
  let points : Points = { node, geometry, material, }
  points.refresh()
  points
}

///|
pub impl @core.AsNode for Points with fn to_node(self) {
  self.node
}

///|
pub extend Points with @core.AsNode::{to_node}

///|
pub fn Points::refresh(self : Points) -> Unit {
  self.node.primitive = Some(
    primitive_binding(
      self.geometry,
      self.material.color,
      @core.PrimitiveKind::Points,
      self.material.size,
      self.material.size_attenuation,
      self.material.opacity,
      self.material.transparent,
    ),
  )
}

///|
/// 折线，对应 r186 的 `Line`。
pub(all) struct Line {
  node : Object3D
  geometry : BufferGeometry
  material : @materials.LineBasicMaterial
}

///|
pub fn Line::new(
  geometry : BufferGeometry,
  material : @materials.LineBasicMaterial,
) -> Line {
  let node = Object3D::new(kind=@core.NodeKind::Line)
  let line : Line = { node, geometry, material, }
  line.refresh()
  line
}

///|
pub impl @core.AsNode for Line with fn to_node(self) {
  self.node
}

///|
pub extend Line with @core.AsNode::{to_node}

///|
pub fn Line::refresh(self : Line) -> Unit {
  self.node.primitive = Some(
    primitive_binding(
      self.geometry,
      self.material.color,
      @core.PrimitiveKind::Line,
      1.0,
      false,
      self.material.opacity,
      self.material.transparent,
    ),
  )
}

///|
/// 成对线段，对应 r186 的 `LineSegments`。
pub(all) struct LineSegments {
  node : Object3D
  geometry : BufferGeometry
  material : @materials.LineBasicMaterial
}

///|
pub fn LineSegments::new(
  geometry : BufferGeometry,
  material : @materials.LineBasicMaterial,
) -> LineSegments {
  let node = Object3D::new(kind=@core.NodeKind::LineSegments)
  let line : LineSegments = { node, geometry, material, }
  line.refresh()
  line
}

///|
pub impl @core.AsNode for LineSegments with fn to_node(self) {
  self.node
}

///|
pub extend LineSegments with @core.AsNode::{to_node}

///|
pub fn LineSegments::refresh(self : LineSegments) -> Unit {
  self.node.primitive = Some(
    primitive_binding(
      self.geometry,
      self.material.color,
      @core.PrimitiveKind::LineSegments,
      1.0,
      false,
      self.material.opacity,
      self.material.transparent,
    ),
  )
}
