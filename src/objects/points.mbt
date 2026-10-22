// r186: `Points` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L19

///|
/// 点。每个位置画一个朝向相机的四边形。没有形变属性时，权重和名字表保持空。
/// r186: `Points` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L19
/// r186: `morphTargetDictionary` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L65
/// r186: `morphTargetInfluences` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L75
pub(all) struct Points {
  node : Object3D
  mut geometry : BufferGeometry
  mut material : @materials.PointsMaterial
  mut materials : Array[@materials.PointsMaterial]?
  mut morph_target_influences : Array[Double]?
  mut morph_target_dictionary : Map[String, Int32]?
}

///|
pub fn Points::new(
  geometry : BufferGeometry,
  material : @materials.PointsMaterial,
) -> Points {
  let node = Object3D::new(kind=@core.NodeKind::Points)
  let points : Points = {
    node,
    geometry,
    material,
    materials: None,
    morph_target_influences: None,
    morph_target_dictionary: None,
  }
  points.refresh()
  points.update_morph_targets()
  points
}

///|
pub impl @core.AsNode for Points with fn to_node(self) {
  self.node
}

///|
pub extend Points with @core.AsNode::{to_node}

///|
/// 复制变换、几何体和材质。几何体与材质沿用源对象。
/// 形变权重和名字表留在目标上，不从源对象复制。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L81
pub fn Points::copy(
  self : Points,
  source : Points,
  recursive~ : Bool = true,
) -> Points {
  ignore(self.node.copy(source.node, recursive~))
  self.geometry = source.geometry
  self.material = source.material
  self.materials = copy_point_materials(source.materials)
  self.refresh()
  self
}

///|
/// 新建一份点云再复制。three.js 没有单独的 `Points.clone`，用的是 `Object3D.clone`。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1592
pub fn Points::clone(self : Points, recursive~ : Bool = true) -> Points {
  Points::new(self.geometry, self.material).copy(self, recursive~)
}

///|
/// 按几何体里先迭代到的那一组形变属性填写权重和名字表。权重全是 `0`。
/// 属性名为空时用下标字符串。没有形变属性时保持原值。
/// r186: `updateMorphTargets` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L175
pub fn Points::update_morph_targets(self : Points) -> Unit {
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
pub fn Points::refresh(self : Points) -> Unit {
  self.node.primitive = Some(
    primitive_binding(
      self.geometry,
      self.material.color,
      @core.PrimitiveKind::Points,
      self.material.size,
      self.material.size_attenuation,
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
      point_draws(self.materials),
    ),
  )
}

///|
/// 换成材质数组后，每个几何分组用自己的颜色、大小和透明度。
/// 直接改数组里的值不会更新节点，要再调用 `refresh`。
/// r186: `material` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L55
pub fn Points::set_materials(
  self : Points,
  materials : Array[@materials.PointsMaterial],
) -> Unit {
  let copied : Array[@materials.PointsMaterial] = []
  for material in materials {
    copied.push(material)
  }
  self.materials = Some(copied)
  self.refresh()
}

///|
pub fn Points::set_fog(self : Points, enabled : Bool) -> Unit {
  self.material.fog = enabled
  self.refresh()
}

///|
/// `enabled` 为真时进入透明队列，并按 `opacity` 做 src-alpha 混合。
/// 直接改 `material.transparent` 不会更新绑定。
/// r186: `Points` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L19
pub fn Points::set_transparent(
  self : Points,
  enabled : Bool,
  opacity~ : Double = 1.0,
) -> Unit {
  self.material.transparent = enabled
  self.material.opacity = opacity
  self.refresh()
}
