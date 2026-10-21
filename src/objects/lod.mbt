// r186: `LOD` https://github.com/mrdoob/three.js/blob/r186/src/objects/LOD.js#L33

///|
/// 按距离切换显示的对象。级别从近到远排列，`auto_update` 默认真。节点上的级别数组与 `levels` 是同一份。
/// r186: `LOD` https://github.com/mrdoob/three.js/blob/r186/src/objects/LOD.js#L33
pub(all) struct LOD {
  node : Object3D
  mut levels : Array[@core.LodLevel]
  mut auto_update : Bool
  mut current_level : Int
}

///|
fn LOD::write_levels(self : LOD, levels : Array[@core.LodLevel]) -> Unit {
  self.levels = levels
  self.node.lod_levels = Some(levels)
}

///|
pub fn LOD::new() -> LOD {
  let levels : Array[@core.LodLevel] = []
  let node = Object3D::new(kind=@core.NodeKind::LOD)
  node.lod_levels = Some(levels)
  { node, levels, auto_update: true, current_level: 0, }
}

///|
pub impl @core.AsNode for LOD with fn to_node(self) {
  self.node
}

///|
pub extend LOD with @core.AsNode::{to_node}

///|
/// 按距离插入一级，并把它加为子节点。负距离取绝对值。相等距离排在已有级别之后。
/// r186: `addLevel` https://github.com/mrdoob/three.js/blob/r186/src/objects/LOD.js#L116
pub fn LOD::add_level(
  self : LOD,
  object : Object3D,
  distance? : Double = 0.0,
  hysteresis? : Double = 0.0,
) -> LOD {
  let distance = distance.abs()
  let mut index = 0
  let count = self.levels.length()
  while index < count {
    if distance < self.levels[index].distance {
      break
    }
    index = index + 1
  }
  let next : Array[@core.LodLevel] = []
  let mut i = 0
  while i < index {
    next.push(self.levels[i])
    i = i + 1
  }
  next.push({ object, distance, hysteresis })
  while i < count {
    next.push(self.levels[i])
    i = i + 1
  }
  self.write_levels(next)
  ignore(self.node.add(object))
  self
}

///|
/// 按距离删掉第一级匹配，并把该对象从子节点拿掉。没有这一级时返回假，级别和子节点都不改。
/// r186: `removeLevel` https://github.com/mrdoob/three.js/blob/r186/src/objects/LOD.js#L149
pub fn LOD::remove_level(self : LOD, distance : Double) -> Bool {
  let mut found = None
  let mut i = 0
  let count = self.levels.length()
  while i < count {
    if self.levels[i].distance == distance {
      found = Some(i)
      break
    }
    i = i + 1
  }
  match found {
    None => false
    Some(index) => {
      let object = self.levels[index].object
      let next : Array[@core.LodLevel] = []
      let mut j = 0
      while j < count {
        if j != index {
          next.push(self.levels[j])
        }
        j = j + 1
      }
      self.write_levels(next)
      ignore(self.node.remove(object))
      true
    }
  }
}

///|
/// 返回当前级别下标。新建时是 `0`。`update` 在多于一级时改写它。
/// r186: `getCurrentLevel` https://github.com/mrdoob/three.js/blob/r186/src/objects/LOD.js#L175
pub fn LOD::get_current_level(self : LOD) -> Int {
  self.current_level
}

///|
/// 返回第一个距离阈值大于给定距离的前一级对象。对象可见时，阈值会减去 `distance * hysteresis`。没有级别时返回空。
/// r186: `getObjectForDistance` https://github.com/mrdoob/three.js/blob/r186/src/objects/LOD.js#L188
pub fn LOD::get_object_for_distance(
  self : LOD,
  distance : Double,
) -> Object3D? {
  @core.lod_object_for_distance(self.levels, distance)
}

///|
/// 按相机到 LOD 的世界距离除以 `zoom` 切换可见级别。只有一级时什么都不改。没有相机会中止。
/// r186: `update` https://github.com/mrdoob/three.js/blob/r186/src/objects/LOD.js#L250
pub fn LOD::update(self : LOD, camera : Object3D) -> Unit {
  let count = self.levels.length()
  if count <= 1 {
    return
  }
  let state = match camera.camera {
    None => abort("LOD.update requires a camera")
    Some(state) => state
  }
  let camera_position = @math.Vector3::new()
    .set_from_matrix_position(camera.matrix_world)
  let lod_position = @math.Vector3::new()
    .set_from_matrix_position(self.node.matrix_world)
  let distance = camera_position.distance_to(lod_position) / state.zoom
  self.levels[0].object.visible = true
  let mut i = 1
  while i < count {
    let level = self.levels[i]
    let mut level_distance = level.distance
    if level.object.visible {
      level_distance = level_distance - level_distance * level.hysteresis
    }
    if distance >= level_distance {
      self.levels[i - 1].object.visible = false
      level.object.visible = true
    } else {
      break
    }
    i = i + 1
  }
  self.current_level = i - 1
  while i < count {
    self.levels[i].object.visible = false
    i = i + 1
  }
}

///|
/// 复制变换和各级对象。子节点不从源节点整棵复制，而是克隆每一级的对象再加入。`current_level` 留在目标原来的值。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/objects/LOD.js#L87
pub fn LOD::copy(self : LOD, source : LOD) -> LOD {
  ignore(self.node.copy(source.node, recursive=false))
  let count = source.levels.length()
  let mut index = 0
  while index < count {
    let level = source.levels[index]
    ignore(
      self.add_level(
        level.object.clone(),
        distance=level.distance,
        hysteresis=level.hysteresis,
      ),
    )
    index = index + 1
  }
  self.auto_update = source.auto_update
  self
}

///|
/// 新建一份 LOD 再复制。three.js 没有单独的 `LOD.clone`，用的是 `Object3D.clone`。新对象的 `current_level` 从 `0` 开始。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1592
pub fn LOD::clone(self : LOD) -> LOD {
  LOD::new().copy(self)
}
