// r186: `RenderList` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderList.js#L94 ; `intersectsObject` https://github.com/mrdoob/three.js/blob/r186/src/math/Frustum.js#L146 ; `test` https://github.com/mrdoob/three.js/blob/r186/src/core/Layers.js#L100 ; `getWireframeIndex` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Geometries.js#L42

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
  alpha_test : Double
  emissive : @math.Color
  instances : @core.InstanceData?
}

///|
/// 收集当前可见的不透明网格。传入视锥时按包围球裁剪，不排序。
/// r186: `reversePainterSortStable` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderList.js#L45
pub fn collect_opaque(
  root : Object3D,
  frustum? : @math.Frustum,
  camera? : Object3D,
) -> Array[RenderItem] {
  let items = []
  root.traverse_visible(fn(node) {
    match node.kind {
      @core.Mesh =>
        match node.mesh {
          None => ()
          Some(binding) =>
            if !binding.transparent &&
              !binding.wireframe &&
              on_camera_layer(node, camera) &&
              kept_by_frustum(node, binding.geometry, frustum) {
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
                alpha_test: binding.alpha_test,
                emissive: binding.emissive,
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
/// 阴影投射体。线框也包含在内，几何仍是三角形，边列表只给颜色通道。
pub fn collect_shadow(root : Object3D, camera? : Object3D) -> Array[RenderItem] {
  let items = []
  root.traverse_visible(fn(node) {
    match node.kind {
      @core.Mesh =>
        match node.mesh {
          None => ()
          Some(binding) =>
            if !binding.transparent &&
              on_camera_layer(node, camera) &&
              kept_by_frustum(node, binding.geometry, None) {
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
                alpha_test: binding.alpha_test,
                emissive: binding.emissive,
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
/// 线框网格。透明与不透明、普通与实例化都收集。
/// r186: `getWireframeIndex` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Geometries.js#L42 ; `InstancedMesh` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L28
pub fn collect_wireframe(
  root : Object3D,
  frustum? : @math.Frustum,
  camera? : Object3D,
) -> Array[RenderItem] {
  let items = []
  root.traverse_visible(fn(node) {
    match node.kind {
      @core.Mesh =>
        match node.mesh {
          None => ()
          Some(binding) =>
            if binding.wireframe &&
              on_camera_layer(node, camera) &&
              kept_by_frustum(node, binding.geometry, frustum) {
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
                alpha_test: binding.alpha_test,
                emissive: binding.emissive,
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
/// 每个三角形展开成三条边：`a b`、`b c`、`c a`。不成三角形的尾部丢掉。
/// r186: `getWireframeIndex` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Geometries.js#L42
pub fn wireframe_line_indices(geometry : BufferGeometry) -> Array[Int] {
  let lines = []
  match geometry.index {
    Some(index) => {
      let mut cursor = 0
      while cursor + 2 < index.count {
        let a = index.get_x(cursor).to_int()
        let b = index.get_x(cursor + 1).to_int()
        let c = index.get_x(cursor + 2).to_int()
        lines.push(a)
        lines.push(b)
        lines.push(b)
        lines.push(c)
        lines.push(c)
        lines.push(a)
        cursor = cursor + 3
      }
    }
    None =>
      match geometry.get_attribute("position") {
        None => ()
        Some(position) => {
          let mut cursor = 0
          while cursor + 2 < position.count {
            lines.push(cursor)
            lines.push(cursor + 1)
            lines.push(cursor + 1)
            lines.push(cursor + 2)
            lines.push(cursor + 2)
            lines.push(cursor)
            cursor = cursor + 3
          }
        }
      }
  }
  lines
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
/// 收集当前可见的点和线。传入视锥时按包围球裁剪。
pub fn collect_primitives(
  root : Object3D,
  frustum? : @math.Frustum,
  camera? : Object3D,
) -> Array[PrimitiveItem] {
  let items = []
  root.traverse_visible(fn(node) {
    match node.primitive {
      None => ()
      Some(binding) =>
        if !binding.transparent &&
          on_camera_layer(node, camera) &&
          kept_by_frustum(node, binding.geometry, frustum) {
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
/// 透明的点和线，从远到近。深度相同则保持遍历顺序。
/// r186: `painterSortStable` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderList.js#L14
pub fn collect_transparent_primitives(
  root : Object3D,
  camera : Object3D,
  frustum? : @math.Frustum,
) -> Array[PrimitiveItem] {
  let items = []
  root.traverse_visible(fn(node) {
    match node.primitive {
      None => ()
      Some(binding) =>
        if binding.transparent &&
          on_camera_layer(node, Some(camera)) &&
          kept_by_frustum(node, binding.geometry, frustum) {
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
  let ranked = []
  let mut order = 0
  for item in items {
    ranked.push(PrimitiveDepth::{
      item,
      depth: view_depth(camera, item.node),
      order,
    })
    order = order + 1
  }
  sort_primitives_far_to_near(ranked)
  let sorted = []
  for entry in ranked {
    sorted.push(entry.item)
  }
  sorted
}

///|
priv struct DepthItem {
  item : RenderItem
  depth : Double
  order : Int
}

///|
priv struct PrimitiveDepth {
  item : PrimitiveItem
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
fn primitive_farther(left : PrimitiveDepth, right : PrimitiveDepth) -> Bool {
  if left.depth < right.depth {
    true
  } else if left.depth > right.depth {
    false
  } else {
    left.order < right.order
  }
}

///|
fn sort_primitives_far_to_near(items : Array[PrimitiveDepth]) -> Unit {
  let mut index = 1
  while index < items.length() {
    let current = items[index]
    let mut hole = index
    while hole > 0 && primitive_farther(current, items[hole - 1]) {
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
  frustum? : @math.Frustum,
) -> Array[RenderItem] {
  let items = []
  root.traverse_visible(fn(node) {
    match node.kind {
      @core.Mesh =>
        match node.mesh {
          None => ()
          Some(binding) =>
            if binding.transparent &&
              !binding.wireframe &&
              on_camera_layer(node, Some(camera)) &&
              kept_by_frustum(node, binding.geometry, frustum) {
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
                alpha_test: binding.alpha_test,
                emissive: binding.emissive,
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
    ranked.push(DepthItem::{
      item,
      depth: view_depth(camera, item.node),
      order,
    })
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
/// `projection * matrixWorldInverse`。坐标和反向深度跟相机走。
/// r186: `setFromProjectionMatrix` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Renderer.js#L979
pub fn camera_frustum(state : @core.CameraState) -> @math.Frustum {
  let view = @math.Matrix4::new().multiply_matrices(
    state.projection,
    state.matrix_world_inverse,
  )
  @math.Frustum::new().set_from_projection_matrix(
    view,
    coordinate_system=state.coordinate_system,
    reversed_depth=state.reversed_depth,
  )
}

///|
/// 没传相机时不看层。传了相机时，层掩码必须相交。
/// r186: `test` https://github.com/mrdoob/three.js/blob/r186/src/core/Layers.js#L100
fn on_camera_layer(node : Object3D, camera : Object3D?) -> Bool {
  match camera {
    None => true
    Some(camera) => node.layers.intersects(camera.layers)
  }
}

///|
/// 没传视锥，或 `frustum_culled` 为假时保留。否则用世界空间包围球。
/// r186: `intersectsObject` https://github.com/mrdoob/three.js/blob/r186/src/math/Frustum.js#L146
fn kept_by_frustum(
  node : Object3D,
  geometry : BufferGeometry,
  frustum : @math.Frustum?,
) -> Bool {
  match frustum {
    None => true
    Some(frustum) =>
      if !node.frustum_culled {
        true
      } else {
        if geometry.bounding_sphere is None {
          geometry.compute_bounding_sphere()
        }
        match geometry.bounding_sphere {
          None => true
          Some(sphere) => {
            let world = @math.Sphere::new()
              .copy(sphere)
              .apply_matrix4(node.matrix_world)
            frustum.intersects_sphere(world)
          }
        }
      }
  }
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
