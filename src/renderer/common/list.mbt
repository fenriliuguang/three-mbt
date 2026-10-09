///|
using @core {type BufferGeometry, type Object3D}

///|
/// 不透明队列里的一个网格。透明和线框留到后面的阶段。
pub(all) struct RenderItem {
  node : Object3D
  geometry : BufferGeometry
  color : @math.Color
  shading : @constants.Shading
  side : @constants.Side
  opacity : Double
  map : @textures.Texture?
  roughness : Double
  metalness : Double
  instances : @core.InstanceData?
}

///|
/// 收集当前可见的不透明网格。不做视锥裁剪，也不排序。
pub fn collect_opaque(root : Object3D) -> Array[RenderItem] {
  let items = []
  root.traverse_visible(fn(node) {
    match node.kind {
      @core.Mesh =>
        match node.mesh {
          None => ()
          Some(binding) =>
            if !binding.transparent && !binding.wireframe {
              items.push({
                node,
                geometry: binding.geometry,
                color: binding.color,
                shading: binding.shading,
                side: binding.side,
                opacity: binding.opacity,
                map: binding.map,
                roughness: binding.roughness,
                metalness: binding.metalness,
                instances: binding.instances,
              })
            }
        }
      _ => ()
    }
  })
  items
}

///|

///|
/// 点和线。透明的留到后面。
pub(all) struct PrimitiveItem {
  node : Object3D
  geometry : BufferGeometry
  color : @math.Color
  kind : @core.PrimitiveKind
  size : Double
  size_attenuation : Bool
  opacity : Double
}

///|
/// 收集当前可见的点和线。
pub fn collect_primitives(root : Object3D) -> Array[PrimitiveItem] {
  let items = []
  root.traverse_visible(fn(node) {
    match node.primitive {
      None => ()
      Some(binding) =>
        if !binding.transparent {
          items.push({
            node,
            geometry: binding.geometry,
            color: binding.color,
            kind: binding.kind,
            size: binding.size,
            size_attenuation: binding.size_attenuation,
            opacity: binding.opacity,
          })
        }
    }
  })
  items
}

///|
/// 先更新场景，再更新相机，这样挂在场景里的相机能读到父节点的世界矩阵。
pub fn update_frame(scene : Object3D, camera : Object3D) -> Unit {
  scene.update_matrix_world(force=true)
  camera.update_matrix_world(force=true)
}

///|
/// `projection * matrixWorldInverse * matrixWorld`。矩阵按列主序存放。
pub fn model_view_projection(
  camera : @core.CameraState,
  object : Object3D,
) -> @math.Matrix4 {
  let model_view = @math.Matrix4::new().multiply_matrices(
    camera.matrix_world_inverse,
    object.matrix_world,
  )
  @math.Matrix4::new().multiply_matrices(camera.projection, model_view)
}
