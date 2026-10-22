// r186: `Mesh` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L39

///|
using @core {
  type Object3D,
  type BufferAttribute,
  type BufferGeometry,
  type MeshBinding,
}

///|
/// 三角网格。`geometry` 与 `material.color` 同时挂在场景节点上，遍历时可以读到。`count` 默认是 `1`。
/// 没有形变属性时，权重和名字表保持空。
/// r186: `Mesh` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L39
/// r186: `morphTargetDictionary` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L85
/// r186: `morphTargetInfluences` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L95
/// r186: `count` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L104
pub(all) struct Mesh {
  node : Object3D
  mut geometry : BufferGeometry
  mut material : @materials.Material
  mut materials : Array[@materials.Material]?
  mut count : Int32
  mut morph_target_influences : Array[Double]?
  mut morph_target_dictionary : Map[String, Int32]?
}

///|
pub fn Mesh::new(
  geometry : BufferGeometry,
  material : @materials.Material,
) -> Mesh {
  let node = Object3D::new(kind=@core.Mesh)
  let mesh : Mesh = {
    node,
    geometry,
    material,
    materials: None,
    count: 1,
    morph_target_influences: None,
    morph_target_dictionary: None,
  }
  mesh.refresh()
  mesh.update_morph_targets()
  mesh
}

///|
/// 按几何体里先迭代到的那一组形变属性填写权重和名字表。权重全是 `0`。
/// 属性名为空时用下标字符串。没有形变属性时保持原值。
/// r186: `updateMorphTargets` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L137
pub fn Mesh::update_morph_targets(self : Mesh) -> Unit {
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
pub impl @core.AsNode for Mesh with fn to_node(self) {
  self.node
}

///|
pub extend Mesh with @core.AsNode::{to_node}

///|
/// 复制变换、几何体和材质。几何体与材质沿用源对象。
/// 材质数组会复制一份新列表，里面的材质仍是原来的对象。源对象没有数组时，目标的数组清掉。
/// 源对象有形变权重或名字表时各复制一份。源对象没有时，目标上已有的值留着。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L110
pub fn Mesh::copy(self : Mesh, source : Mesh, recursive~ : Bool = true) -> Mesh {
  ignore(self.node.copy(source.node, recursive~))
  self.geometry = source.geometry
  self.material = source.material
  self.materials = match source.materials {
    None => None
    Some(materials) => {
      let copied : Array[@materials.Material] = []
      for material in materials {
        copied.push(material)
      }
      Some(copied)
    }
  }
  match source.morph_target_influences {
    None => ()
    Some(weights) => {
      let copied : Array[Double] = []
      for weight in weights {
        copied.push(weight)
      }
      self.morph_target_influences = Some(copied)
    }
  }
  match source.morph_target_dictionary {
    None => ()
    Some(dictionary) => {
      let copied : Map[String, Int32] = Map([])
      for pair in dictionary.iter() {
        let (name, index) = pair
        copied.set(name, index)
      }
      self.morph_target_dictionary = Some(copied)
    }
  }
  self.refresh()
  self
}

///|
/// 新建一份网格再复制。three.js 没有单独的 `Mesh.clone`，用的是 `Object3D.clone`。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1592
pub fn Mesh::clone(self : Mesh, recursive~ : Bool = true) -> Mesh {
  Mesh::new(self.geometry, self.material).copy(self, recursive~)
}

///|
fn baked_env_rotation(euler : @math.Euler) -> @math.Matrix4 {
  let matrix = @math.Matrix4::new()
  ignore(matrix.make_rotation_from_euler(euler))
  matrix
}

///|
/// 把材质上的侧面、透明度、线框、透明裁切、自发光、贴图、粗糙度贴图、金属度贴图、透明贴图、环境贴图、粗糙度和金属度写回节点。颜色本身是共享的，不需要复制。
/// `env_map_rotation` 在这里收成矩阵。
pub fn Mesh::refresh(self : Mesh) -> Unit {
  self.node.mesh = Some(MeshBinding::{
    geometry: self.geometry,
    color: self.material.color,
    shading: self.material.shading(),
    side: self.material.side,
    shadow_side: self.material.shadow_side,
    opacity: self.material.opacity,
    transparent: self.material.transparent,
    wireframe: self.material.wireframe,
    map: self.material.map,
    roughness: self.material.roughness,
    metalness: self.material.metalness,
    fog: self.material.fog,
    alpha_test: self.material.alpha_test,
    flat_shading: self.material.flat_shading,
    depth_write: self.material.depth_write,
    depth_test: self.material.depth_test,
    depth_func: self.material.depth_func,
    color_write: self.material.color_write,
    premultiplied_alpha: self.material.premultiplied_alpha,
    visible: self.material.visible,
    force_single_pass: self.material.force_single_pass,
    emissive: self.material.emissive,
    emissive_intensity: self.material.emissive_intensity,
    emissive_map: self.material.emissive_map,
    roughness_map: self.material.roughness_map,
    metalness_map: self.material.metalness_map,
    alpha_map: self.material.alpha_map,
    env_map: self.material.env_map,
    env_map_intensity: self.material.env_map_intensity,
    env_rotation: baked_env_rotation(self.material.env_map_rotation),
    instances: None,
    group_sides: material_sides(self.materials),
    group_draws: material_draws(self.materials),
  })
}

///|
/// 换成材质数组后，射线按几何分组使用各自的侧面，并写下 `material_index`。
/// 直接改数组里的侧面不会更新节点，要再调用 `refresh`。
/// r186: `material` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L75
pub fn Mesh::set_materials(
  self : Mesh,
  materials : Array[@materials.Material],
) -> Unit {
  let copied : Array[@materials.Material] = []
  for material in materials {
    copied.push(material)
  }
  self.materials = Some(copied)
  self.refresh()
}

///|
fn material_sides(
  materials : Array[@materials.Material]?,
) -> Array[@constants.Side]? {
  match materials {
    None => None
    Some(materials) => {
      let sides : Array[@constants.Side] = []
      for material in materials {
        sides.push(material.side)
      }
      Some(sides)
    }
  }
}

///|
fn material_draws(
  materials : Array[@materials.Material]?,
) -> Array[@core.MaterialDraw]? {
  match materials {
    None => None
    Some(materials) => {
      let draws : Array[@core.MaterialDraw] = []
      for material in materials {
        draws.push({
          color: material.color,
          shading: material.shading(),
          side: material.side,
          shadow_side: material.shadow_side,
          opacity: material.opacity,
          alpha_test: material.alpha_test,
          transparent: material.transparent,
          wireframe: material.wireframe,
          visible: material.visible,
          map: material.map,
          roughness: material.roughness,
          metalness: material.metalness,
          fog: material.fog,
          flat_shading: material.flat_shading,
          depth_write: material.depth_write,
          depth_test: material.depth_test,
          depth_func: material.depth_func,
          color_write: material.color_write,
          premultiplied_alpha: material.premultiplied_alpha,
          force_single_pass: material.force_single_pass,
          emissive: material.emissive,
          emissive_intensity: material.emissive_intensity,
          emissive_map: material.emissive_map,
          roughness_map: material.roughness_map,
          metalness_map: material.metalness_map,
          alpha_map: material.alpha_map,
          env_map: material.env_map,
          env_map_intensity: material.env_map_intensity,
          env_rotation: baked_env_rotation(material.env_map_rotation),
        })
      }
      Some(draws)
    }
  }
}

///|
/// 换贴图并写回节点。直接改 `material.map` 不会更新绑定。
pub fn Mesh::set_map(self : Mesh, map : @textures.Texture?) -> Unit {
  self.material.map = map
  self.refresh()
}

///|
pub fn Mesh::set_side(self : Mesh, side : @constants.Side) -> Unit {
  self.material.side = side
  self.refresh()
}

///|
/// 关掉之后，这个网格不再混入场景雾。直接改 `material.fog` 不会更新绑定。
pub fn Mesh::set_fog(self : Mesh, enabled : Bool) -> Unit {
  self.material.fog = enabled
  self.refresh()
}

///|
/// `enabled` 为真时进入透明队列，并按 `opacity` 做 src-alpha 混合。
/// 直接改 `material.transparent` 不会更新绑定。
/// r186: `Material` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L19
pub fn Mesh::set_transparent(
  self : Mesh,
  enabled : Bool,
  opacity~ : Double = 1.0,
) -> Unit {
  self.material.transparent = enabled
  self.material.opacity = opacity
  self.refresh()
}

///|
fn primitive_binding(
  geometry : BufferGeometry,
  color : @math.Color,
  kind : @core.PrimitiveKind,
  size : Double,
  size_attenuation : Bool,
  opacity : Double,
  alpha_test : Double,
  transparent : Bool,
  fog : Bool,
  depth_write : Bool,
  depth_test : Bool,
  depth_func : @constants.DepthFunc,
  color_write : Bool,
  premultiplied_alpha : Bool,
  visible : Bool,
  group_draws : Array[@core.PrimitiveDraw]?,
) -> @core.PrimitiveBinding {
  {
    geometry,
    color,
    kind,
    size,
    size_attenuation,
    opacity,
    alpha_test,
    transparent,
    fog,
    depth_write,
    depth_test,
    depth_func,
    color_write,
    premultiplied_alpha,
    visible,
    group_draws,
  }
}

///|
fn point_draws(
  materials : Array[@materials.PointsMaterial]?,
) -> Array[@core.PrimitiveDraw]? {
  match materials {
    None => None
    Some(materials) => {
      let draws : Array[@core.PrimitiveDraw] = []
      for material in materials {
        draws.push({
          color: material.color,
          size: material.size,
          size_attenuation: material.size_attenuation,
          opacity: material.opacity,
          alpha_test: material.alpha_test,
          transparent: material.transparent,
          fog: material.fog,
          depth_write: material.depth_write,
          depth_test: material.depth_test,
          depth_func: material.depth_func,
          color_write: material.color_write,
          premultiplied_alpha: material.premultiplied_alpha,
          visible: material.visible,
        })
      }
      Some(draws)
    }
  }
}

///|
fn line_draws(
  materials : Array[@materials.LineBasicMaterial]?,
) -> Array[@core.PrimitiveDraw]? {
  match materials {
    None => None
    Some(materials) => {
      let draws : Array[@core.PrimitiveDraw] = []
      for material in materials {
        draws.push({
          color: material.color,
          size: 1.0,
          size_attenuation: false,
          opacity: material.opacity,
          alpha_test: material.alpha_test,
          transparent: material.transparent,
          fog: material.fog,
          depth_write: material.depth_write,
          depth_test: material.depth_test,
          depth_func: material.depth_func,
          color_write: material.color_write,
          premultiplied_alpha: material.premultiplied_alpha,
          visible: material.visible,
        })
      }
      Some(draws)
    }
  }
}

///|
fn copy_point_materials(
  materials : Array[@materials.PointsMaterial]?,
) -> Array[@materials.PointsMaterial]? {
  match materials {
    None => None
    Some(materials) => {
      let copied : Array[@materials.PointsMaterial] = []
      for material in materials {
        copied.push(material)
      }
      Some(copied)
    }
  }
}

///|
fn copy_line_materials(
  materials : Array[@materials.LineBasicMaterial]?,
) -> Array[@materials.LineBasicMaterial]? {
  match materials {
    None => None
    Some(materials) => {
      let copied : Array[@materials.LineBasicMaterial] = []
      for material in materials {
        copied.push(material)
      }
      Some(copied)
    }
  }
}
