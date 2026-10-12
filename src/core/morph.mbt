// r186: `morphTargetInfluences` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L95 ; `weights` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L4597

///|
/// 一份形变增量。没有对应属性时是 `None`。
pub(all) struct MorphTarget {
  position : Array[Double]?
  normal : Array[Double]?
  color : Array[Double]?
}

///|
/// 未烘焙的底数、增量，以及当前权重。
/// `shared` 为真时，第一次写入会先复制几何，避免改到别的节点。
/// 运行时把权重烘焙进属性，而不是在着色器里做形变。
/// r186: `morphTargetInfluences` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L95
pub(all) struct MorphState {
  base_position : Array[Double]
  base_normal : Array[Double]?
  base_color : Array[Double]?
  targets : Array[MorphTarget]
  mut weights : Array[Double]
  mut shared : Bool
}

///|
/// 先写回底数，再按权重累加增量。随后清掉包围体并增加 `version`。
pub fn MorphState::write(self : MorphState, geometry : BufferGeometry) -> Unit {
  restore(geometry, "position", self.base_position)
  match self.base_normal {
    None => ()
    Some(values) => restore(geometry, "normal", values)
  }
  match self.base_color {
    None => ()
    Some(values) => restore(geometry, "color", values)
  }
  let mut index = 0
  while index < self.targets.length() {
    let weight = if index < self.weights.length() {
      self.weights[index]
    } else {
      0.0
    }
    if weight != 0.0 {
      let target = self.targets[index]
      add_deltas(geometry, "position", target.position, weight)
      add_deltas(geometry, "normal", target.normal, weight)
      add_deltas(geometry, "color", target.color, weight)
    }
    index = index + 1
  }
  geometry.bounding_box = None
  geometry.bounding_sphere = None
  geometry.version = geometry.version + 1
}

///|
fn restore(
  geometry : BufferGeometry,
  name : String,
  values : Array[Double],
) -> Unit {
  match geometry.get_attribute(name) {
    None => ()
    Some(attribute) => {
      let mut index = 0
      while index < attribute.array.length() && index < values.length() {
        attribute.array[index] = values[index]
        index = index + 1
      }
    }
  }
}

///|
fn add_deltas(
  geometry : BufferGeometry,
  name : String,
  deltas : Array[Double]?,
  weight : Double,
) -> Unit {
  match deltas {
    None => ()
    Some(deltas) =>
      match geometry.get_attribute(name) {
        None => ()
        Some(attribute) =>
          if deltas.length() == attribute.array.length() {
            let mut index = 0
            while index < deltas.length() {
              attribute.array[index] = attribute.array[index] +
                weight * deltas[index]
              index = index + 1
            }
          }
      }
  }
}
