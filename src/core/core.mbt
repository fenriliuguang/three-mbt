///|
/// 场景节点的种类。three.js 的 `isMesh` 一类运行时标记在这里变成枚举。
pub(all) enum NodeKind {
  Object
  Group
  Mesh
  Scene
  PerspectiveCamera
  OrthographicCamera
  AmbientLight
  DirectionalLight
  Points
  Line
  LineSegments
}

///|
pub(all) enum ProjectionKind {
  Perspective
  Orthographic
}

///|
pub(all) enum LightKind {
  Ambient
  Directional
}

///|
/// 把网格、相机、灯光收成场景图里的 `Object3D`。
pub(open) trait AsNode {
  fn to_node(Self) -> Object3D
}
