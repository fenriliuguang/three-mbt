///|
/// 不受光照的基础材质、Lambert，以及直接光的 Standard。
pub(all) enum MaterialKind {
  Basic
  Lambert
  Standard
}

///|
/// 材质的公共数据。改 `side` 之后，网格需要调用 `Mesh::refresh` 才能写回节点。
pub(all) struct Material {
  color : @math.Color
  mut side : @constants.Side
  mut opacity : Double
  mut transparent : Bool
  mut wireframe : Bool
  mut map : @textures.Texture?
  mut roughness : Double
  mut metalness : Double
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
    kind: Basic,
  }
}

///|
/// `MeshBasicMaterial`。颜色默认白色，`set_hex` 按 r186 的 sRGB 到线性转换。
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
    kind: Lambert,
  }
}

///|
/// Lambert 漫反射。环境光和一盏平行光由渲染器写入 uniform。
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
    kind: Standard,
  }
}

///|
/// `MeshStandardMaterial`。`baseColor` 是 `color`，可再乘贴图。
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
