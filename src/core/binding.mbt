///|
/// 挂在网格节点上的绘制数据。颜色与材质共享同一个 `Color`。
pub(all) struct MeshBinding {
  geometry : BufferGeometry
  color : @math.Color
  shading : @constants.Shading
  mut side : @constants.Side
  mut opacity : Double
  mut transparent : Bool
  mut wireframe : Bool
  map : @textures.Texture?
}

///|
/// 挂在灯光节点上的数据。平行光的 `target` 是另一个场景节点。
pub(all) struct LightState {
  color : @math.Color
  mut intensity : Double
  mut target : Object3D?
  kind : LightKind
}
