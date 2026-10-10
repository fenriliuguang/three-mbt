// r186: `Object3D` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L64

///|
/// 场景节点的种类。three.js 的 `isMesh` 一类运行时标记在这里变成枚举。
/// r186: `Object3D` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L64
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
/// r186: `Camera` https://github.com/mrdoob/three.js/blob/r186/src/cameras/Camera.js#L18
pub(all) enum ProjectionKind {
  Perspective
  Orthographic
}

///|
/// r186: `Light` https://github.com/mrdoob/three.js/blob/r186/src/lights/Light.js#L11
pub(all) enum LightKind {
  Ambient
  Directional
}

///|
/// 把网格、相机、灯光收成场景图里的 `Object3D`。
pub(open) trait AsNode {
  fn to_node(Self) -> Object3D
}
