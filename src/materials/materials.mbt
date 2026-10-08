///|
/// 不受光照的基础材质，以及 Lambert。Standard 留到阶段 6。
pub(all) enum MaterialKind {
  Basic
  Lambert
}

///|
/// 材质的公共数据。改 `side` 之后，网格需要调用 `Mesh::refresh` 才能写回节点。
pub(all) struct Material {
  color : @math.Color
  mut side : @constants.Side
  mut opacity : Double
  mut transparent : Bool
  mut wireframe : Bool
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
pub fn Material::shading(self : Material) -> @constants.Shading {
  match self.kind {
    Basic => @constants.Basic
    Lambert => @constants.Lambert
  }
}
