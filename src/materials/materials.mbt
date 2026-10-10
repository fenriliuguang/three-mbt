// r186: `Material` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L19

///|
/// 不受光照的基础材质、Lambert，以及直接光的 Standard。
pub(all) enum MaterialKind {
  Basic
  Lambert
  Standard
}

///|
/// 材质的公共数据。改 `side` 之后，网格需要调用 `Mesh::refresh` 才能写回节点。
/// r186: `Material` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L19
pub(all) struct Material {
  color : @math.Color
  mut side : @constants.Side
  mut opacity : Double
  mut transparent : Bool
  mut wireframe : Bool
  mut map : @textures.Texture?
  mut roughness : Double
  mut metalness : Double
  mut fog : Bool
  kind : MaterialKind
}

///|
pub fn Material::basic(hex? : Int = 0xFFFFFF) -> Material {
  {
    color: @math.Color::new().set_hex(hex),
    side: @constants.Front,
    opacity: 1.0,
    transparent: false,
    wireframe: false,
    map: None,
    roughness: 1.0,
    metalness: 0.0,
    fog: true,
    kind: Basic,
  }
}

///|
/// `MeshBasicMaterial`。颜色默认白色，`set_hex` 按 r186 的 sRGB 到线性转换。
/// r186: `MeshBasicMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L14
pub(all) struct MeshBasicMaterial {
  material : Material
}

///|
pub fn MeshBasicMaterial::new(hex? : Int = 0xFFFFFF) -> MeshBasicMaterial {
  { material: Material::basic(hex~), }
}

///|
pub fn Material::lambert(hex? : Int = 0xFFFFFF) -> Material {
  {
    color: @math.Color::new().set_hex(hex),
    side: @constants.Front,
    opacity: 1.0,
    transparent: false,
    wireframe: false,
    map: None,
    roughness: 1.0,
    metalness: 0.0,
    fog: true,
    kind: Lambert,
  }
}

///|
/// Lambert 漫反射。环境光和一盏平行光由渲染器写入 uniform。
/// r186: `MeshLambertMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L24
pub(all) struct MeshLambertMaterial {
  material : Material
}

///|
pub fn MeshLambertMaterial::new(hex? : Int = 0xFFFFFF) -> MeshLambertMaterial {
  { material: Material::lambert(hex~), }
}

///|
/// 直接光 PBR。默认粗糙度 1、金属度 0，与 r186 `MeshStandardMaterial` 相同。
/// 环境贴图和 PMREM 不在这一阶段。
pub fn Material::standard(
  hex? : Int = 0xFFFFFF,
  roughness? : Double = 1.0,
  metalness? : Double = 0.0,
) -> Material {
  {
    color: @math.Color::new().set_hex(hex),
    side: @constants.Front,
    opacity: 1.0,
    transparent: false,
    wireframe: false,
    map: None,
    roughness,
    metalness,
    fog: true,
    kind: Standard,
  }
}

///|
/// `MeshStandardMaterial`。`baseColor` 是 `color`，可再乘贴图。
/// r186: `MeshStandardMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L41
pub(all) struct MeshStandardMaterial {
  material : Material
}

///|
pub fn MeshStandardMaterial::new(
  hex? : Int = 0xFFFFFF,
  roughness? : Double = 1.0,
  metalness? : Double = 0.0,
) -> MeshStandardMaterial {
  { material: Material::standard(hex~, roughness~, metalness~), }
}

///|
pub fn Material::shading(self : Material) -> @constants.Shading {
  match self.kind {
    Basic => @constants.Basic
    Lambert => @constants.Lambert
    Standard => @constants.Standard
  }
}

///|
/// 点精灵。`size` 是像素，`size_attenuation` 为真时按透视缩小，对齐 r186 `PointsMaterial`。
/// r186: `PointsMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/PointsMaterial.js#L29
pub(all) struct PointsMaterial {
  color : @math.Color
  mut size : Double
  mut size_attenuation : Bool
  mut opacity : Double
  mut transparent : Bool
  mut fog : Bool
}

///|
pub fn PointsMaterial::new(
  hex? : Int = 0xFFFFFF,
  size? : Double = 1.0,
  size_attenuation? : Bool = true,
) -> PointsMaterial {
  {
    color: @math.Color::new().set_hex(hex),
    size,
    size_attenuation,
    opacity: 1.0,
    transparent: false,
    fog: true,
  }
}

///|
/// 线段和折线。WebGPU 的线宽是 1 像素，因此没有 `linewidth`。
/// r186: `LineBasicMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineBasicMaterial.js#L15
pub(all) struct LineBasicMaterial {
  color : @math.Color
  mut opacity : Double
  mut transparent : Bool
  mut fog : Bool
}

///|
pub fn LineBasicMaterial::new(hex? : Int = 0xFFFFFF) -> LineBasicMaterial {
  {
    color: @math.Color::new().set_hex(hex),
    opacity: 1.0,
    transparent: false,
    fog: true,
  }
}
