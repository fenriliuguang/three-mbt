// r186: `RenderList` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderList.js#L94

///|
using @core {type BufferGeometry, type Object3D}

///|
/// 网格绘制项。线框不进不透明队列，也不进透明队列。
/// r186: `RenderObject` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderObject.js#L65
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
  fog : Bool
  instances : @core.InstanceData?
}

///|
/// 收集当前可见的不透明网格。不做视锥裁剪，也不排序。
/// r186: `reversePainterSortStable` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderList.js#L45
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
                fog: binding.fog,
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
/// 点和线。透明的点和线仍不绘制。
pub(all) struct PrimitiveItem {
  node : Object3D
  geometry : BufferGeometry
  color : @math.Color
  kind : @core.PrimitiveKind
  size : Double
  size_attenuation : Bool
  opacity : Double
  fog : Bool
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
            fog: binding.fog,
          })
        }
    }
  })
  items
}

///|
priv struct DepthItem {
  item : RenderItem
  depth : Double
  order : Int
}

///|
/// 相机前方的视图空间 z 为负。更小的值更远。
fn farther(left : DepthItem, right : DepthItem) -> Bool {
  if left.depth < right.depth {
    true
  } else if left.depth > right.depth {
    false
  } else {
    left.order < right.order
  }
}

///|
fn sort_far_to_near(items : Array[DepthItem]) -> Unit {
  let mut index = 1
  while index < items.length() {
    let current = items[index]
    let mut hole = index
    while hole > 0 && farther(current, items[hole - 1]) {
      items[hole] = items[hole - 1]
      hole = hole - 1
    }
    items[hole] = current
    index = index + 1
  }
}

///|
/// 物体原点在相机视图空间里的 z。相机前方为负，和 r186 的 `-mvPosition` 同一套轴向。
/// r186: `painterSortStable` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderList.js#L14
pub fn view_depth(camera : Object3D, object : Object3D) -> Double {
  match camera.camera {
    None => 0.0
    Some(state) => {
      let view = state.matrix_world_inverse.elements
      let world = object.matrix_world.elements
      view[2] * world[12] +
      view[6] * world[13] +
      view[10] * world[14] +
      view[14]
    }
  }
}

///|
/// 透明网格，从远到近。深度相同则保持遍历顺序。线框不在此列。
/// r186: `painterSortStable` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderList.js#L14
pub fn collect_transparent(
  root : Object3D,
  camera : Object3D,
) -> Array[RenderItem] {
  let items = []
  root.traverse_visible(fn(node) {
    match node.kind {
      @core.Mesh =>
        match node.mesh {
          None => ()
          Some(binding) =>
            if binding.transparent && !binding.wireframe {
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
                fog: binding.fog,
                instances: binding.instances,
              })
            }
        }
      _ => ()
    }
  })
  let ranked = []
  let mut order = 0
  for item in items {
    ranked.push({ item, depth: view_depth(camera, item.node), order, })
    order = order + 1
  }
  sort_far_to_near(ranked)
  let sorted = []
  for entry in ranked {
    sorted.push(entry.item)
  }
  sorted
}

///|
/// 先更新场景，再更新相机，这样挂在场景里的相机能读到父节点的世界矩阵。
pub fn update_frame(scene : Object3D, camera : Object3D) -> Unit {
  scene.update_matrix_world(force=true)
  camera.update_matrix_world(force=true)
}

///|
/// `projection * matrixWorldInverse * matrixWorld`。矩阵按列主序存放。
/// r186: `render` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Renderer.js#L1496
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
