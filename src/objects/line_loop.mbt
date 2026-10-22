// r186: `LineLoop` https://github.com/mrdoob/three.js/blob/r186/src/objects/LineLoop.js#L10

///|
/// 闭合折线。最后一点连回第一点，射线会测这段；绘制仍按折线提交。
/// 没有形变属性时，权重和名字表保持空。这两个字段来自 `Line`，`LineLoop` 没有单独声明。
/// r186: `LineLoop` https://github.com/mrdoob/three.js/blob/r186/src/objects/LineLoop.js#L10
/// r186: `morphTargetDictionary` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L87
/// r186: `morphTargetInfluences` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L97
pub(all) struct LineLoop {
  node : Object3D
  mut geometry : BufferGeometry
  mut material : @materials.LineBasicMaterial
  mut materials : Array[@materials.LineBasicMaterial]?
  mut morph_target_influences : Array[Double]?
  mut morph_target_dictionary : Map[String, Int32]?
}

///|
pub fn LineLoop::new(
  geometry : BufferGeometry,
  material : @materials.LineBasicMaterial,
) -> LineLoop {
  let node = Object3D::new(kind=@core.NodeKind::LineLoop)
  let line : LineLoop = {
    node,
    geometry,
    material,
    materials: None,
    morph_target_influences: None,
    morph_target_dictionary: None,
  }
  line.refresh()
  line.update_morph_targets()
  line
}

///|
pub impl @core.AsNode for LineLoop with fn to_node(self) {
  self.node
}

///|
pub extend LineLoop with @core.AsNode::{to_node}

///|
/// 复制变换、几何体和材质。几何体与材质沿用源对象。
/// `LineLoop` 没有自己的 `copy`，行为来自 `Line.copy`。
/// 形变权重和名字表留在目标上，不从源对象复制。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L103
pub fn LineLoop::copy(
  self : LineLoop,
  source : LineLoop,
  recursive~ : Bool = true,
) -> LineLoop {
  ignore(self.node.copy(source.node, recursive~))
  self.geometry = source.geometry
  self.material = source.material
  self.materials = copy_line_materials(source.materials)
  self.refresh()
  self
}

///|
/// 新建一条闭合折线再复制。three.js 没有单独的 `LineLoop.clone`，用的是 `Object3D.clone`。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1592
pub fn LineLoop::clone(self : LineLoop, recursive~ : Bool = true) -> LineLoop {
  LineLoop::new(self.geometry, self.material).copy(self, recursive~)
}

///|
/// 按几何体里先迭代到的那一组形变属性填写权重和名字表。权重全是 `0`。
/// 属性名为空时用下标字符串。没有形变属性时保持原值。
/// `LineLoop` 没有自己的 `updateMorphTargets`，行为来自 `Line`。
/// r186: `updateMorphTargets` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L275
pub fn LineLoop::update_morph_targets(self : LineLoop) -> Unit {
  let mut chosen : Array[BufferAttribute]? = None
  for pair in self.geometry.morph_attributes.iter() {
    if chosen is None {
      let (_, attributes) = pair
      chosen = Some(attributes)
    }
  }
  match chosen {
    None => ()
    Some(attributes) => {
      let influences : Array[Double] = []
      let dictionary : Map[String, Int32] = Map([])
      let mut index = 0
      while index < attributes.length() {
        let attribute = attributes[index]
        let name = if attribute.name == "" {
          index.to_string()
        } else {
          attribute.name
        }
        influences.push(0.0)
        dictionary.set(name, index)
        index = index + 1
      }
      self.morph_target_influences = Some(influences)
      self.morph_target_dictionary = Some(dictionary)
    }
  }
}

///|
/// 沿折线累计每个顶点到起点的距离，写入 `lineDistance`。
/// `LineLoop` 没有自己的 `computeLineDistances`，行为来自 `Line`。
/// 几何体带索引时上游只警告，这里不改属性。
/// r186: `computeLineDistances` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L121
pub fn LineLoop::compute_line_distances(self : LineLoop) -> LineLoop {
  if self.geometry.index is Some(_) {
    return self
  }
  let position = match self.geometry.get_attribute("position") {
    None => abort("Line.computeLineDistances requires a position attribute")
    Some(position) => position
  }
  let distances = [0.0]
  let mut index = 1
  while index < position.count {
    let previous = index - 1
    let start = @math.Vector3::new(
      x=position.get_x(previous),
      y=position.get_y(previous),
      z=position.get_z(previous),
    )
    let end = @math.Vector3::new(
      x=position.get_x(index),
      y=position.get_y(index),
      z=position.get_z(index),
    )
    distances.push(distances[previous] + start.distance_to(end))
    index = index + 1
  }
  ignore(
    self.geometry.set_attribute(
      "lineDistance",
      @core.BufferAttribute::new(distances, 1),
    ),
  )
  self
}

///|
pub fn LineLoop::refresh(self : LineLoop) -> Unit {
  self.node.primitive = Some(
    primitive_binding(
      self.geometry,
      self.material.color,
      @core.PrimitiveKind::Line,
      1.0,
      false,
      self.material.opacity,
      self.material.alpha_test,
      self.material.transparent,
      self.material.fog,
      self.material.depth_write,
      self.material.depth_test,
      self.material.depth_func,
      self.material.color_write,
      self.material.premultiplied_alpha,
      self.material.blending,
      self.material.visible,
      line_draws(self.materials),
    ),
  )
}

///|
/// 换成材质数组后，每个几何分组用自己的颜色和透明度。
/// 直接改数组里的值不会更新节点，要再调用 `refresh`。
/// r186: `material` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L77
pub fn LineLoop::set_materials(
  self : LineLoop,
  materials : Array[@materials.LineBasicMaterial],
) -> Unit {
  let copied : Array[@materials.LineBasicMaterial] = []
  for material in materials {
    copied.push(material)
  }
  self.materials = Some(copied)
  self.refresh()
}

///|
fn identity_matrices(count : Int32) -> BufferAttribute {
  let array = []
  let mut index = 0
  while index < count {
    array.push(1.0)
    array.push(0.0)
    array.push(0.0)
    array.push(0.0)
    array.push(0.0)
    array.push(1.0)
    array.push(0.0)
    array.push(0.0)
    array.push(0.0)
    array.push(0.0)
    array.push(1.0)
    array.push(0.0)
    array.push(0.0)
    array.push(0.0)
    array.push(0.0)
    array.push(1.0)
    index = index + 1
  }
  BufferAttribute::new(array, 16)
}

///|
fn write_matrix(
  attribute : BufferAttribute,
  index : Int32,
  matrix : @math.Matrix4,
) -> Unit {
  let offset = index * attribute.item_size
  let mut component = 0
  while component < 16 {
    attribute.array[offset + component] = matrix.elements[component]
    component = component + 1
  }
}

///|
fn read_matrix(
  attribute : BufferAttribute,
  index : Int32,
  target : @math.Matrix4,
) -> Unit {
  let offset = index * attribute.item_size
  let mut component = 0
  while component < 16 {
    target.elements[component] = attribute.array[offset + component]
    component = component + 1
  }
}
