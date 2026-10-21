// r186: `LineSegments` https://github.com/mrdoob/three.js/blob/r186/src/objects/LineSegments.js#L14

///|
/// 成对线段，对应 r186 的 `LineSegments`。没有形变属性时，权重和名字表保持空。
/// 这两个字段来自 `Line`，`LineSegments` 没有单独声明。
/// r186: `LineSegments` https://github.com/mrdoob/three.js/blob/r186/src/objects/LineSegments.js#L14
/// r186: `morphTargetDictionary` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L87
/// r186: `morphTargetInfluences` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L97
pub(all) struct LineSegments {
  node : Object3D
  mut geometry : BufferGeometry
  mut material : @materials.LineBasicMaterial
  mut materials : Array[@materials.LineBasicMaterial]?
  mut morph_target_influences : Array[Double]?
  mut morph_target_dictionary : Map[String, Int32]?
}

///|
pub fn LineSegments::new(
  geometry : BufferGeometry,
  material : @materials.LineBasicMaterial,
) -> LineSegments {
  let node = Object3D::new(kind=@core.NodeKind::LineSegments)
  let line : LineSegments = {
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
pub impl @core.AsNode for LineSegments with fn to_node(self) {
  self.node
}

///|
pub extend LineSegments with @core.AsNode::{to_node}

///|
/// 复制变换、几何体和材质。几何体与材质沿用源对象。
/// `LineSegments` 没有自己的 `copy`，行为来自 `Line.copy`。
/// 形变权重和名字表留在目标上，不从源对象复制。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L103
pub fn LineSegments::copy(
  self : LineSegments,
  source : LineSegments,
  recursive~ : Bool = true,
) -> LineSegments {
  ignore(self.node.copy(source.node, recursive~))
  self.geometry = source.geometry
  self.material = source.material
  self.materials = copy_line_materials(source.materials)
  self.refresh()
  self
}

///|
/// 新建一份成对线段再复制。three.js 没有单独的 `LineSegments.clone`，用的是 `Object3D.clone`。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1592
pub fn LineSegments::clone(
  self : LineSegments,
  recursive~ : Bool = true,
) -> LineSegments {
  LineSegments::new(self.geometry, self.material).copy(self, recursive~)
}

///|
/// 按几何体里先迭代到的那一组形变属性填写权重和名字表。权重全是 `0`。
/// 属性名为空时用下标字符串。没有形变属性时保持原值。
/// `LineSegments` 没有自己的 `updateMorphTargets`，行为来自 `Line`。
/// r186: `updateMorphTargets` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L275
pub fn LineSegments::update_morph_targets(self : LineSegments) -> Unit {
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
/// 按成对顶点累计长度，写入 `lineDistance`。每段的起点沿用上一段的终点距离，第一段从 `0` 起。
/// 几何体带索引时上游只警告，这里不改属性。
/// r186: `computeLineDistances` https://github.com/mrdoob/three.js/blob/r186/src/objects/LineSegments.js#L39
pub fn LineSegments::compute_line_distances(
  self : LineSegments,
) -> LineSegments {
  if self.geometry.index is Some(_) {
    return self
  }
  let position = match self.geometry.get_attribute("position") {
    None =>
      abort("LineSegments.computeLineDistances requires a position attribute")
    Some(position) => position
  }
  let distances : Array[Double] = []
  let mut index = 0
  while index < position.count {
    let next = index + 1
    let start = @math.Vector3::new(
      x=position.get_x(index),
      y=position.get_y(index),
      z=position.get_z(index),
    )
    let end = @math.Vector3::new(
      x=position.get_x(next),
      y=position.get_y(next),
      z=position.get_z(next),
    )
    let segment_start = if index == 0 { 0.0 } else { distances[index - 1] }
    distances.push(segment_start)
    distances.push(segment_start + start.distance_to(end))
    index = index + 2
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
pub fn LineSegments::refresh(self : LineSegments) -> Unit {
  self.node.primitive = Some(
    primitive_binding(
      self.geometry,
      self.material.color,
      @core.PrimitiveKind::LineSegments,
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
      self.material.visible,
      line_draws(self.materials),
    ),
  )
}

///|
/// 换成材质数组后，每个几何分组用自己的颜色和透明度。
/// 直接改数组里的值不会更新节点，要再调用 `refresh`。
/// r186: `material` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L77
pub fn LineSegments::set_materials(
  self : LineSegments,
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
pub fn LineSegments::set_fog(self : LineSegments, enabled : Bool) -> Unit {
  self.material.fog = enabled
  self.refresh()
}

///|
/// `enabled` 为真时进入透明队列，并按 `opacity` 做 src-alpha 混合。
/// 直接改 `material.transparent` 不会更新绑定。
/// r186: `LineSegments` https://github.com/mrdoob/three.js/blob/r186/src/objects/LineSegments.js#L14
pub fn LineSegments::set_transparent(
  self : LineSegments,
  enabled : Bool,
  opacity~ : Double = 1.0,
) -> Unit {
  self.material.transparent = enabled
  self.material.opacity = opacity
  self.refresh()
}
