// r186: `RenderObject` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderObject.js#L65

///|
/// 挂在网格节点上的绘制数据。颜色与材质共享同一个 `Color`。
/// r186: `RenderObject` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderObject.js#L65
pub(all) struct MeshBinding {
  geometry : BufferGeometry
  color : @math.Color
  shading : @constants.Shading
  mut side : @constants.Side
  mut opacity : Double
  mut transparent : Bool
  mut wireframe : Bool
  map : @textures.Texture?
  roughness : Double
  metalness : Double
  fog : Bool
  instances : InstanceData?
}

///|
/// `InstancedMesh` 的实例数据。矩阵是列主序 16 个数，颜色是可选的 `rgb`。
/// `count` 可以小于矩阵容量。`version` 在矩阵或颜色改动后加一，供渲染器决定是否重传。
/// r186: `InstancedMesh` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L28
pub(all) struct InstanceData {
  matrices : BufferAttribute
  mut colors : BufferAttribute?
  mut count : Int
  mut version : Int
}

///|
/// 点、折线和线段。`Line` 是折线，`LineSegments` 是成对线段。
/// r186: `Points` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L19
pub(all) enum PrimitiveKind {
  Points
  Line
  LineSegments
}

///|
/// 挂在点或线上的绘制数据。线宽在 WebGPU 里固定为 1 像素。
/// r186: `Points` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L19
pub(all) struct PrimitiveBinding {
  geometry : BufferGeometry
  color : @math.Color
  kind : PrimitiveKind
  size : Double
  size_attenuation : Bool
  opacity : Double
  transparent : Bool
  fog : Bool
}

///|
/// 平行光的阴影相机和参数。`camera` 是正交相机节点。
/// r186: `LightShadow` https://github.com/mrdoob/three.js/blob/r186/src/lights/LightShadow.js#L18
pub(all) struct ShadowState {
  camera : Object3D
  mut map_size : Int
  mut bias : Double
  mut normal_bias : Double
  mut radius : Double
}

///|
/// 挂在灯光节点上的数据。平行光的 `target` 是另一个场景节点。
/// `shadow` 只在平行光上有值。是否绘制由节点的 `cast_shadow` 决定。
/// r186: `Light` https://github.com/mrdoob/three.js/blob/r186/src/lights/Light.js#L11
pub(all) struct LightState {
  color : @math.Color
  mut intensity : Double
  mut target : Object3D?
  kind : LightKind
  mut shadow : ShadowState?
}
