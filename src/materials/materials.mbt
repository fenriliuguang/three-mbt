// r186: `Material` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L19 ; `SpriteMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/SpriteMaterial.js#L18 ; `LineDashedMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineDashedMaterial.js#L19

///|
/// 不受光照的基础材质、Lambert，以及直接光的 Standard。
pub(all) enum MaterialKind {
  Basic
  Lambert
  Standard
}

///|
/// 材质的公共数据。`alpha_test` 大于片元 alpha 时丢弃该片元，默认 0。
/// `vertex_colors` 默认关闭。着色器仍不读顶点色。
/// `emissive` 默认黑色。Lambert 和 Standard 在光照之后加上它，Basic 不用。
/// `emissive_intensity` 默认 1，写入 uniform 时乘在自发光上。`0` 会把它写成黑。
/// `emissive_map` 再乘一次。没有贴图时渲染器绑一张白纹理。
/// `roughness_map` 只进 Standard：绿色通道乘在粗糙度上，再取 0.0525 下限。没有贴图时同样绑白纹理。
/// `metalness_map` 也只进 Standard：蓝色通道乘在金属度上，再夹到 0 和 1。没有贴图时绑白纹理。
/// `alpha_map` 的绿色通道乘在片元 alpha 上，乘完再做 `alpha_test`。Basic、Lambert、Standard 都采样。没有贴图时绑白纹理。
/// `flat_shading` 默认关闭。打开后 Lambert 和 Standard 忽略顶点法线，改用视图空间位置的屏幕导数。
/// `depth_write` 默认打开。关掉后颜色通道不写深度，阴影通道仍写深度。
/// `depth_test` 默认打开。关掉后比较改为 `always`，片段始终通过深度测试。`depth_write` 不跟着关。阴影通道仍用 `less` 并写深度。
/// `depth_func` 默认 `LessEqual`。只在 `depth_test` 打开时决定颜色通道的比较函数。点材质和线材质用同一组字段。
/// `color_write` 默认打开。关掉后颜色通道不写颜色，深度测试和深度写入不变。阴影通道没有颜色目标。
/// `premultiplied_alpha` 默认关闭。打开后透明混合的源因子从 `SrcAlpha` 改成 `One`，目标仍是 `OneMinusSrcAlpha`。不透明绘制没有混合，这个开关不起作用。
/// `shadow_side` 默认空。空着时阴影通道把正面翻成背面、背面翻成正面，双面保持双面。设了值就按那个面投射，不再翻转。
/// `visible` 默认打开。关掉后这个材质不进颜色列表，也不进阴影列表。节点的 `visible` 仍然单独决定整棵子树。
/// `force_single_pass` 默认关闭。透明且双面时，先画背面再画正面。打开后这两次合成一次双面绘制。不透明双面本来就是一次。
/// 改 `side`、`shadow_side`、`visible`、`force_single_pass`、`alpha_test`、`flat_shading`、`depth_write`、`depth_test`、`depth_func`、`color_write`、`premultiplied_alpha`、`emissive_intensity`、`emissive_map`、`roughness_map`、`metalness_map`、`alpha_map` 或换一份 `emissive` 之后，网格需要调用 `Mesh::refresh` 才能写回节点。
/// r186: `Material` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L19 ; `vertexColors` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L99 ; `depthFunc` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L211 ; `depthTest` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L220 ; `depthWrite` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L231 ; `colorWrite` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L353 ; `premultipliedAlpha` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L417 ; `shadowSide` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L342 ; `visible` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L447 ; `forceSinglePass` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L431 ; `_getBlending` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgpu/utils/WebGPUPipelineUtils.js#L552 ; `_getDepthCompare` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgpu/utils/WebGPUPipelineUtils.js#L948 ; `_getColorWriteMask` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgpu/utils/WebGPUPipelineUtils.js#L935 ; `emissiveIntensity` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L130 ; `emissiveIntensity` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L170 ; `roughnessMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L288 ; `metalnessMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L300 ; `alphaMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L133 ; `flatShading` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L372
pub(all) struct Material {
  color : @math.Color
  mut side : @constants.Side
  mut shadow_side : @constants.Side?
  mut opacity : Double
  mut transparent : Bool
  mut wireframe : Bool
  mut map : @textures.Texture?
  mut roughness : Double
  mut metalness : Double
  mut fog : Bool
  mut alpha_test : Double
  mut flat_shading : Bool
  mut depth_write : Bool
  mut depth_test : Bool
  mut depth_func : @constants.DepthFunc
  mut color_write : Bool
  mut premultiplied_alpha : Bool
  mut visible : Bool
  mut force_single_pass : Bool
  emissive : @math.Color
  mut emissive_intensity : Double
  mut emissive_map : @textures.Texture?
  mut roughness_map : @textures.Texture?
  mut metalness_map : @textures.Texture?
  mut alpha_map : @textures.Texture?
  mut vertex_colors : Bool
  kind : MaterialKind
}

///|
pub fn Material::basic(hex? : Int = 0xFFFFFF) -> Material {
  {
    color: @math.Color::new().set_hex(hex),
    side: @constants.Front,
    shadow_side: None,
    opacity: 1.0,
    transparent: false,
    wireframe: false,
    map: None,
    roughness: 1.0,
    metalness: 0.0,
    fog: true,
    alpha_test: 0.0,
    flat_shading: false,
    depth_write: true,
    depth_test: true,
    depth_func: @constants.LessEqual,
    color_write: true,
    premultiplied_alpha: false,
    visible: true,
    force_single_pass: false,
    emissive: @math.Color::new(r=0.0, g=0.0, b=0.0),
    emissive_intensity: 1.0,
    emissive_map: None,
    roughness_map: None,
    metalness_map: None,
    alpha_map: None,
    vertex_colors: false,
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
    shadow_side: None,
    opacity: 1.0,
    transparent: false,
    wireframe: false,
    map: None,
    roughness: 1.0,
    metalness: 0.0,
    fog: true,
    alpha_test: 0.0,
    flat_shading: false,
    depth_write: true,
    depth_test: true,
    depth_func: @constants.LessEqual,
    color_write: true,
    premultiplied_alpha: false,
    visible: true,
    force_single_pass: false,
    emissive: @math.Color::new(r=0.0, g=0.0, b=0.0),
    emissive_intensity: 1.0,
    emissive_map: None,
    roughness_map: None,
    metalness_map: None,
    alpha_map: None,
    vertex_colors: false,
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
    shadow_side: None,
    opacity: 1.0,
    transparent: false,
    wireframe: false,
    map: None,
    roughness,
    metalness,
    fog: true,
    alpha_test: 0.0,
    flat_shading: false,
    depth_write: true,
    depth_test: true,
    depth_func: @constants.LessEqual,
    color_write: true,
    premultiplied_alpha: false,
    visible: true,
    force_single_pass: false,
    emissive: @math.Color::new(r=0.0, g=0.0, b=0.0),
    emissive_intensity: 1.0,
    emissive_map: None,
    roughness_map: None,
    metalness_map: None,
    alpha_map: None,
    vertex_colors: false,
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
/// 颜色贴图和透明贴图默认空。点着色器仍按材质颜色绘制，不采样这两张贴图。
/// `alpha_test` 默认 `0`。点着色器在片元 alpha 小于它时丢弃。
/// `vertex_colors` 默认关闭。点着色器仍不读顶点色。
/// r186: `PointsMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/PointsMaterial.js#L29
/// r186: `map` https://github.com/mrdoob/three.js/blob/r186/src/materials/PointsMaterial.js#L75
/// r186: `alphaMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/PointsMaterial.js#L93
/// r186: `alphaTest` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L489
/// r186: `vertexColors` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L99
pub(all) struct PointsMaterial {
  color : @math.Color
  mut map : @textures.Texture?
  mut alpha_map : @textures.Texture?
  mut size : Double
  mut size_attenuation : Bool
  mut opacity : Double
  mut alpha_test : Double
  mut transparent : Bool
  mut fog : Bool
  mut depth_write : Bool
  mut depth_test : Bool
  mut depth_func : @constants.DepthFunc
  mut color_write : Bool
  mut premultiplied_alpha : Bool
  mut visible : Bool
  mut vertex_colors : Bool
}

///|
pub fn PointsMaterial::new(
  hex? : Int = 0xFFFFFF,
  size? : Double = 1.0,
  size_attenuation? : Bool = true,
) -> PointsMaterial {
  {
    color: @math.Color::new().set_hex(hex),
    map: None,
    alpha_map: None,
    size,
    size_attenuation,
    opacity: 1.0,
    alpha_test: 0.0,
    transparent: false,
    fog: true,
    depth_write: true,
    depth_test: true,
    depth_func: @constants.LessEqual,
    color_write: true,
    premultiplied_alpha: false,
    visible: true,
    vertex_colors: false,
  }
}

///|
/// 把颜色写进目标自己的颜色对象。颜色贴图和透明贴图沿用源对象。
/// 尺寸、尺寸衰减、不透明度、`alpha_test`、透明开关、雾、深度、颜色写入、预乘、可见性和顶点色一并复制。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/materials/PointsMaterial.js#L125
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1119
pub fn PointsMaterial::copy(
  self : PointsMaterial,
  source : PointsMaterial,
) -> PointsMaterial {
  ignore(self.color.copy(source.color))
  self.map = source.map
  self.alpha_map = source.alpha_map
  self.size = source.size
  self.size_attenuation = source.size_attenuation
  self.opacity = source.opacity
  self.alpha_test = source.alpha_test
  self.transparent = source.transparent
  self.fog = source.fog
  self.depth_write = source.depth_write
  self.depth_test = source.depth_test
  self.depth_func = source.depth_func
  self.color_write = source.color_write
  self.premultiplied_alpha = source.premultiplied_alpha
  self.visible = source.visible
  self.vertex_colors = source.vertex_colors
  self
}

///|
/// 线段和折线。WebGPU 的线宽是 1 像素，因此没有 `linewidth`。
/// 颜色贴图默认空。线段着色器仍按材质颜色绘制，不采样这张贴图。
/// `alpha_test` 默认 `0`。线段着色器在片元 alpha 小于它时丢弃。
/// `vertex_colors` 默认关闭。线段着色器仍不读顶点色。
/// r186: `LineBasicMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineBasicMaterial.js#L15
/// r186: `map` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineBasicMaterial.js#L60
/// r186: `alphaTest` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L489
/// r186: `vertexColors` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L99
pub(all) struct LineBasicMaterial {
  color : @math.Color
  mut map : @textures.Texture?
  mut opacity : Double
  mut alpha_test : Double
  mut transparent : Bool
  mut fog : Bool
  mut depth_write : Bool
  mut depth_test : Bool
  mut depth_func : @constants.DepthFunc
  mut color_write : Bool
  mut premultiplied_alpha : Bool
  mut visible : Bool
  mut vertex_colors : Bool
}

///|
pub fn LineBasicMaterial::new(hex? : Int = 0xFFFFFF) -> LineBasicMaterial {
  {
    color: @math.Color::new().set_hex(hex),
    map: None,
    opacity: 1.0,
    alpha_test: 0.0,
    transparent: false,
    fog: true,
    depth_write: true,
    depth_test: true,
    depth_func: @constants.LessEqual,
    color_write: true,
    premultiplied_alpha: false,
    visible: true,
    vertex_colors: false,
  }
}

///|
/// 把颜色写进目标自己的颜色对象。颜色贴图沿用源对象。
/// 不透明度、`alpha_test`、透明开关、雾、深度、颜色写入、预乘、可见性和顶点色一并复制。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineBasicMaterial.js#L106
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1119
pub fn LineBasicMaterial::copy(
  self : LineBasicMaterial,
  source : LineBasicMaterial,
) -> LineBasicMaterial {
  ignore(self.color.copy(source.color))
  self.map = source.map
  self.opacity = source.opacity
  self.alpha_test = source.alpha_test
  self.transparent = source.transparent
  self.fog = source.fog
  self.depth_write = source.depth_write
  self.depth_test = source.depth_test
  self.depth_func = source.depth_func
  self.color_write = source.color_write
  self.premultiplied_alpha = source.premultiplied_alpha
  self.visible = source.visible
  self.vertex_colors = source.vertex_colors
  self
}

///|
/// 虚线材质。线段字段放在内嵌的 `line` 上。
/// `scale` 默认 `1`，`dash_size` 默认 `3`，`gap_size` 默认 `1`。
/// 折线仍使用 `LineBasicMaterial`。着色器仍画实线。
/// r186: `LineDashedMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineDashedMaterial.js#L19
/// r186: `scale` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineDashedMaterial.js#L50
/// r186: `dashSize` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineDashedMaterial.js#L58
/// r186: `gapSize` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineDashedMaterial.js#L66
pub(all) struct LineDashedMaterial {
  line : LineBasicMaterial
  mut scale : Double
  mut dash_size : Double
  mut gap_size : Double
}

///|
pub fn LineDashedMaterial::new(
  hex? : Int = 0xFFFFFF,
  scale? : Double = 1.0,
  dash_size? : Double = 3.0,
  gap_size? : Double = 1.0,
) -> LineDashedMaterial {
  {
    line: LineBasicMaterial::new(hex=hex),
    scale,
    dash_size,
    gap_size,
  }
}

///|
/// 内嵌线段材质按 `LineBasicMaterial.copy` 复制。虚线比例、线段长度和间隔一并复制。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineDashedMaterial.js#L72
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineBasicMaterial.js#L106
pub fn LineDashedMaterial::copy(
  self : LineDashedMaterial,
  source : LineDashedMaterial,
) -> LineDashedMaterial {
  ignore(self.line.copy(source.line))
  self.scale = source.scale
  self.dash_size = source.dash_size
  self.gap_size = source.gap_size
  self
}

///|
/// 没有同名上游方法。距离先乘 `scale`，再按 GLSL `mod` 对 `dash_size + gap_size` 取余。
/// 余数大于 `dash_size` 时落在间隔里，返回 false。周期为 0 时中止。
/// 着色器仍画实线。
/// r186: `vLineDistance` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderLib/linedashed.glsl.js#L17
/// r186: `mod` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderLib/linedashed.glsl.js#L55
/// r186: `totalSize` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLMaterials.js#L298
pub fn LineDashedMaterial::keeps_distance(
  self : LineDashedMaterial,
  distance : Double,
) -> Bool {
  let total = self.dash_size + self.gap_size
  if total == 0.0 {
    abort("LineDashedMaterial dash period is zero")
  }
  let scaled = self.scale * distance
  let wrapped = scaled - total * (scaled / total).floor()
  wrapped <= self.dash_size
}

///|
/// 精灵材质。射线读取 `rotation` 和 `size_attenuation`。
/// 颜色默认白，贴图和透明贴图默认空。透明度默认打开，不透明度默认 `1`，雾默认打开。
/// 深度写入和深度测试默认打开，深度函数是 `LessEqual`。颜色写入默认打开，预乘默认关闭，可见性默认打开。
/// `alpha_test` 默认 `0`。`vertex_colors` 默认关闭。渲染器仍不画精灵。
/// r186: `SpriteMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/SpriteMaterial.js#L18
/// r186: `vertexColors` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L99
/// r186: `color` https://github.com/mrdoob/three.js/blob/r186/src/materials/SpriteMaterial.js#L50
/// r186: `map` https://github.com/mrdoob/three.js/blob/r186/src/materials/SpriteMaterial.js#L64
/// r186: `alphaMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/SpriteMaterial.js#L82
/// r186: `rotation` https://github.com/mrdoob/three.js/blob/r186/src/materials/SpriteMaterial.js#L90
/// r186: `sizeAttenuation` https://github.com/mrdoob/three.js/blob/r186/src/materials/SpriteMaterial.js#L98
/// r186: `transparent` https://github.com/mrdoob/three.js/blob/r186/src/materials/SpriteMaterial.js#L107
/// r186: `fog` https://github.com/mrdoob/three.js/blob/r186/src/materials/SpriteMaterial.js#L115
/// r186: `opacity` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L111
/// r186: `alphaTest` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L489
/// r186: `depthFunc` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L211
/// r186: `depthTest` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L220
/// r186: `depthWrite` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L231
/// r186: `colorWrite` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L353
/// r186: `premultipliedAlpha` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L417
/// r186: `visible` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L447
pub(all) struct SpriteMaterial {
  color : @math.Color
  mut map : @textures.Texture?
  mut alpha_map : @textures.Texture?
  mut opacity : Double
  mut alpha_test : Double
  mut transparent : Bool
  mut fog : Bool
  mut rotation : Double
  mut size_attenuation : Bool
  mut depth_write : Bool
  mut depth_test : Bool
  mut depth_func : @constants.DepthFunc
  mut color_write : Bool
  mut premultiplied_alpha : Bool
  mut visible : Bool
  mut vertex_colors : Bool
}

///|
pub fn SpriteMaterial::new(
  rotation? : Double = 0.0,
  size_attenuation? : Bool = true,
  hex? : Int = 0xFFFFFF,
  opacity? : Double = 1.0,
  transparent? : Bool = true,
  fog? : Bool = true,
) -> SpriteMaterial {
  {
    color: @math.Color::new().set_hex(hex),
    map: None,
    alpha_map: None,
    opacity,
    alpha_test: 0.0,
    transparent,
    fog,
    rotation,
    size_attenuation,
    depth_write: true,
    depth_test: true,
    depth_func: @constants.LessEqual,
    color_write: true,
    premultiplied_alpha: false,
    visible: true,
    vertex_colors: false,
  }
}

///|
/// 把颜色写进目标自己的颜色对象。贴图和透明贴图沿用源对象。
/// 不透明度、`alpha_test`、透明开关、雾、旋转、尺寸衰减、深度、颜色写入、预乘、可见性和顶点色一并复制。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/materials/SpriteMaterial.js#L121
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1119
pub fn SpriteMaterial::copy(
  self : SpriteMaterial,
  source : SpriteMaterial,
) -> SpriteMaterial {
  ignore(self.color.copy(source.color))
  self.map = source.map
  self.alpha_map = source.alpha_map
  self.opacity = source.opacity
  self.alpha_test = source.alpha_test
  self.transparent = source.transparent
  self.fog = source.fog
  self.rotation = source.rotation
  self.size_attenuation = source.size_attenuation
  self.depth_write = source.depth_write
  self.depth_test = source.depth_test
  self.depth_func = source.depth_func
  self.color_write = source.color_write
  self.premultiplied_alpha = source.premultiplied_alpha
  self.visible = source.visible
  self.vertex_colors = source.vertex_colors
  self
}
