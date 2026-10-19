// r186: `RenderList` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderList.js#L94 ; `intersectsObject` https://github.com/mrdoob/three.js/blob/r186/src/math/Frustum.js#L146 ; `test` https://github.com/mrdoob/three.js/blob/r186/src/core/Layers.js#L100 ; `getWireframeIndex` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Geometries.js#L42 ; `_projectObject` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Renderer.js#L3242

///|
using @core {type BufferGeometry, type Object3D}

///|
/// 网格绘制项。线框不进不透明队列，也不进透明队列。
/// `group_count` 小于 0 时画整份几何。否则从 `group_start` 起画 `group_count` 个顶点或索引。
/// r186: `RenderObject` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderObject.js#L65
pub(all) struct RenderItem {
  node : Object3D
  geometry : BufferGeometry
  color : @math.Color
  shading : @constants.Shading
  side : @constants.Side
  shadow_side : @constants.Side?
  opacity : Double
  map : @textures.Texture?
  roughness : Double
  metalness : Double
  fog : Bool
  alpha_test : Double
  flat_shading : Bool
  depth_write : Bool
  depth_test : Bool
  depth_func : @constants.DepthFunc
  color_write : Bool
  premultiplied_alpha : Bool
  force_single_pass : Bool
  emissive : @math.Color
  emissive_intensity : Double
  emissive_map : @textures.Texture?
  roughness_map : @textures.Texture?
  metalness_map : @textures.Texture?
  alpha_map : @textures.Texture?
  instances : @core.InstanceData?
  group_start : Int
  group_count : Int
}

///|
priv enum MeshQueue {
  Opaque
  Transparent
  Shadow
}

///|
fn kept_for_queue(
  visible : Bool,
  transparent : Bool,
  wireframe : Bool,
  queue : MeshQueue,
) -> Bool {
  if !visible {
    false
  } else {
    match queue {
      MeshQueue::Opaque => !transparent && !wireframe
      MeshQueue::Transparent => transparent && !wireframe
      MeshQueue::Shadow => !transparent
    }
  }
}

///|
fn push_binding_item(
  items : Array[RenderItem],
  node : Object3D,
  binding : @core.MeshBinding,
  group_start : Int,
  group_count : Int,
) -> Unit {
  items.push({
    node,
    geometry: binding.geometry,
    color: binding.color,
    shading: binding.shading,
    side: binding.side,
    shadow_side: binding.shadow_side,
    opacity: binding.opacity,
    map: binding.map,
    roughness: binding.roughness,
    metalness: binding.metalness,
    fog: binding.fog,
    alpha_test: binding.alpha_test,
    flat_shading: binding.flat_shading,
    depth_write: binding.depth_write,
    depth_test: binding.depth_test,
    depth_func: binding.depth_func,
    color_write: binding.color_write,
    premultiplied_alpha: binding.premultiplied_alpha,
    force_single_pass: binding.force_single_pass,
    emissive: binding.emissive,
    emissive_intensity: binding.emissive_intensity,
    emissive_map: binding.emissive_map,
    roughness_map: binding.roughness_map,
    metalness_map: binding.metalness_map,
    alpha_map: binding.alpha_map,
    instances: binding.instances,
    group_start,
    group_count,
  })
}

///|
fn push_group_item(
  items : Array[RenderItem],
  node : Object3D,
  binding : @core.MeshBinding,
  draw : @core.MaterialDraw,
  group_start : Int,
  group_count : Int,
) -> Unit {
  items.push({
    node,
    geometry: binding.geometry,
    color: draw.color,
    shading: draw.shading,
    side: draw.side,
    shadow_side: draw.shadow_side,
    opacity: draw.opacity,
    map: draw.map,
    roughness: draw.roughness,
    metalness: draw.metalness,
    fog: draw.fog,
    alpha_test: draw.alpha_test,
    flat_shading: draw.flat_shading,
    depth_write: draw.depth_write,
    depth_test: draw.depth_test,
    depth_func: draw.depth_func,
    color_write: draw.color_write,
    premultiplied_alpha: draw.premultiplied_alpha,
    force_single_pass: draw.force_single_pass,
    emissive: draw.emissive,
    emissive_intensity: draw.emissive_intensity,
    emissive_map: draw.emissive_map,
    roughness_map: draw.roughness_map,
    metalness_map: draw.metalness_map,
    alpha_map: draw.alpha_map,
    instances: binding.instances,
    group_start,
    group_count,
  })
}

///|
/// 材质数组按几何分组各出一项。空分组不画。材质下标越界的组跳过。
/// 没有材质数组时仍是一项，`group_count` 为 -1。
/// r186: `_projectObject` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Renderer.js#L3242
fn append_mesh(
  items : Array[RenderItem],
  node : Object3D,
  binding : @core.MeshBinding,
  queue : MeshQueue,
) -> Unit {
  match binding.group_draws {
    None =>
      if kept_for_queue(
        binding.visible,
        binding.transparent,
        binding.wireframe,
        queue,
      ) {
        push_binding_item(items, node, binding, 0, -1)
      }
    Some(draws) =>
      for group in binding.geometry.groups {
        if group.material_index >= 0 && group.material_index < draws.length() {
          let draw = draws[group.material_index]
          if kept_for_queue(
            draw.visible,
            draw.transparent,
            draw.wireframe,
            queue,
          ) {
            push_group_item(items, node, binding, draw, group.start, group.count)
          }
        }
      }
  }
}

///|
/// 收集当前可见的不透明网格。传入视锥时按包围球裁剪。
/// 只按 `render_order` 从小到大排，相同则保持遍历顺序。不按深度排。
/// 没有 `groupOrder`。r186 还会比较 z，这里不比较。
/// 材质数组按几何分组展开，每一组用自己的材质。
/// r186: `painterSortStable` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderList.js#L20
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
            if on_camera_layer(node, camera) &&
              kept_by_frustum(node, binding.geometry, frustum) {
              append_mesh(items, node, binding, MeshQueue::Opaque)
            }
        }
      _ => ()
    }
  })
  by_render_order(items)
}

///|
/// 颜色通道这一次要画的面。透明双面且没有 `force_single_pass` 时，先背面再正面。
/// 线框和不透明网格仍按材质的 `side` 画一次。
/// r186: two-pass double side https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Renderer.js#L3783
pub fn color_sides(
  side : @constants.Side,
  blend : Bool,
  wire : Bool,
  force_single_pass : Bool,
) -> Array[@constants.Side] {
  if blend && !wire && side is @constants.Double && !force_single_pass {
    [@constants.Back, @constants.Front]
  } else {
    [side]
  }
}

///|
/// 阴影通道实际绘制的面。`shadow_side` 有值时直接用它。
/// 否则正面材质画背面，背面材质画正面，双面仍画双面。没有 VSM，所以不走那条不翻转的路径。
/// r186: `_shadowSide` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Renderer.js#L50 ; shadow pass side https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Renderer.js#L3767
pub fn shadow_cast_side(
  side : @constants.Side,
  shadow_side : @constants.Side?,
) -> @constants.Side {
  match shadow_side {
    Some(explicit) => explicit
    None =>
      match side {
        @constants.Front => @constants.Back
        @constants.Back => @constants.Front
        @constants.Double => @constants.Double
      }
  }
}

///|
/// 阴影投射体。线框也包含在内，几何仍是三角形，边列表只给颜色通道。
/// 不按 `render_order` 排，保持遍历顺序。
pub fn collect_shadow(root : Object3D, camera? : Object3D) -> Array[RenderItem] {
  let items = []
  root.traverse_visible(fn(node) {
    match node.kind {
      @core.Mesh =>
        match node.mesh {
          None => ()
          Some(binding) =>
            if on_camera_layer(node, camera) &&
              kept_by_frustum(node, binding.geometry, None) {
              append_mesh(items, node, binding, MeshQueue::Shadow)
            }
        }
      _ => ()
    }
  })
  items
}

///|
/// 线框网格。透明与不透明、普通与实例化都收集。
/// 彼此按 `render_order` 从小到大排，相同则保持遍历顺序。不按深度排。
/// r186: `painterSortStable` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderList.js#L20 ; `getWireframeIndex` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Geometries.js#L42 ; `InstancedMesh` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L28
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
            if binding.visible &&
              binding.wireframe &&
              on_camera_layer(node, camera) &&
              kept_by_frustum(node, binding.geometry, frustum) {
              push_binding_item(items, node, binding, 0, -1)
            }
        }
      _ => ()
    }
  })
  by_render_order(items)
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
  depth_write : Bool
  depth_test : Bool
  depth_func : @constants.DepthFunc
  color_write : Bool
  premultiplied_alpha : Bool
}

///|
/// 收集当前可见的不透明点和线。传入视锥时按包围球裁剪。
/// 只按 `render_order` 从小到大排，相同则保持遍历顺序。不按深度排。
/// r186: `painterSortStable` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderList.js#L20
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
        if binding.visible &&
          !binding.transparent &&
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
            depth_write: binding.depth_write,
            depth_test: binding.depth_test,
            depth_func: binding.depth_func,
            color_write: binding.color_write,
            premultiplied_alpha: binding.premultiplied_alpha,
          })
        }
    }
  })
  primitives_by_render_order(items)
}

///|
/// 透明的点和线。先比 `render_order`，再从远到近。都相同则保持遍历顺序。
/// r186: `reversePainterSortStable` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderList.js#L51
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
        if binding.visible &&
          binding.transparent &&
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
            depth_write: binding.depth_write,
            depth_test: binding.depth_test,
            depth_func: binding.depth_func,
            color_write: binding.color_write,
            premultiplied_alpha: binding.premultiplied_alpha,
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
      render_order: item.node.render_order,
      order,
    })
    order = order + 1
  }
  sort_ranked_primitives(ranked, primitive_farther)
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
  render_order : Int
  order : Int
}

///|
priv struct PrimitiveDepth {
  item : PrimitiveItem
  depth : Double
  render_order : Int
  order : Int
}

///|
/// `render_order` 更小的先画。相同则视图空间 z 更小（更远）的先画，再保持遍历顺序。
fn farther(left : DepthItem, right : DepthItem) -> Bool {
  if left.render_order < right.render_order {
    true
  } else if left.render_order > right.render_order {
    false
  } else if left.depth < right.depth {
    true
  } else if left.depth > right.depth {
    false
  } else {
    left.order < right.order
  }
}

///|
/// 只比 `render_order`。相同则保持遍历顺序，不看深度。
fn earlier(left : DepthItem, right : DepthItem) -> Bool {
  if left.render_order < right.render_order {
    true
  } else if left.render_order > right.render_order {
    false
  } else {
    left.order < right.order
  }
}

///|
fn sort_ranked(
  items : Array[DepthItem],
  before : (DepthItem, DepthItem) -> Bool,
) -> Unit {
  let mut index = 1
  while index < items.length() {
    let current = items[index]
    let mut hole = index
    while hole > 0 && before(current, items[hole - 1]) {
      items[hole] = items[hole - 1]
      hole = hole - 1
    }
    items[hole] = current
    index = index + 1
  }
}

///|
fn by_render_order(items : Array[RenderItem]) -> Array[RenderItem] {
  let ranked = []
  let mut order = 0
  for item in items {
    ranked.push(DepthItem::{
      item,
      depth: 0.0,
      render_order: item.node.render_order,
      order,
    })
    order = order + 1
  }
  sort_ranked(ranked, earlier)
  let sorted = []
  for entry in ranked {
    sorted.push(entry.item)
  }
  sorted
}

///|
fn primitive_farther(left : PrimitiveDepth, right : PrimitiveDepth) -> Bool {
  if left.render_order < right.render_order {
    true
  } else if left.render_order > right.render_order {
    false
  } else if left.depth < right.depth {
    true
  } else if left.depth > right.depth {
    false
  } else {
    left.order < right.order
  }
}

///|
fn primitive_earlier(left : PrimitiveDepth, right : PrimitiveDepth) -> Bool {
  if left.render_order < right.render_order {
    true
  } else if left.render_order > right.render_order {
    false
  } else {
    left.order < right.order
  }
}

///|
fn sort_ranked_primitives(
  items : Array[PrimitiveDepth],
  before : (PrimitiveDepth, PrimitiveDepth) -> Bool,
) -> Unit {
  let mut index = 1
  while index < items.length() {
    let current = items[index]
    let mut hole = index
    while hole > 0 && before(current, items[hole - 1]) {
      items[hole] = items[hole - 1]
      hole = hole - 1
    }
    items[hole] = current
    index = index + 1
  }
}

///|
fn primitives_by_render_order(
  items : Array[PrimitiveItem],
) -> Array[PrimitiveItem] {
  let ranked = []
  let mut order = 0
  for item in items {
    ranked.push(PrimitiveDepth::{
      item,
      depth: 0.0,
      render_order: item.node.render_order,
      order,
    })
    order = order + 1
  }
  sort_ranked_primitives(ranked, primitive_earlier)
  let sorted = []
  for entry in ranked {
    sorted.push(entry.item)
  }
  sorted
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
/// 透明网格。先比 `render_order`，再从远到近。都相同则保持遍历顺序。线框不在此列。
/// r186: `reversePainterSortStable` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderList.js#L51
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
            if on_camera_layer(node, Some(camera)) &&
              kept_by_frustum(node, binding.geometry, frustum) {
              append_mesh(items, node, binding, MeshQueue::Transparent)
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
      render_order: item.node.render_order,
      order,
    })
    order = order + 1
  }
  sort_ranked(ranked, farther)
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
/// 没传视锥，或 `frustum_culled` 为假时保留。否则用世界空间包围球。带实例数据时用实例包围球，没有就算。几何体没有位置时保留。
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
        match cull_sphere(node, geometry) {
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
fn cull_sphere(node : Object3D, geometry : BufferGeometry) -> @math.Sphere? {
  match node.mesh {
    Some(mesh) =>
      match mesh.instances {
        Some(instances) =>
          Some(match instances.bounding_sphere {
            Some(sphere) => sphere
            None => instances.compute_bounding_sphere(mesh.geometry)
          })
        None => geometry_bounding_sphere(geometry)
      }
    None => geometry_bounding_sphere(geometry)
  }
}

///|
fn geometry_bounding_sphere(geometry : BufferGeometry) -> @math.Sphere? {
  if geometry.bounding_sphere is None {
    geometry.compute_bounding_sphere()
  }
  geometry.bounding_sphere
}

///|
/// 先更新场景，再更新相机，这样挂在场景里的相机能读到父节点的世界矩阵。
/// 世界矩阵就绪后，按绑定姿态重算蒙皮顶点。
pub fn update_frame(scene : Object3D, camera : Object3D) -> Unit {
  scene.update_matrix_world(force=true)
  camera.update_matrix_world(force=true)
  @core.apply_skins(scene)
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
