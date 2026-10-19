// r186: `Material` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L19 ; `SpriteMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/SpriteMaterial.js#L18 ; `LineDashedMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineDashedMaterial.js#L19 ; `wireframeLinecap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L213 ; `wireframeLinejoin` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L223 ; `defines` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L67 ; `side` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L88 ; `shadowSide` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L342 ; `forceSinglePass` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L431 ; `anisotropyRotation` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L75 ; `anisotropyMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L88 ; `clearcoatMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L100 ; `clearcoatRoughness` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L108 ; `clearcoatRoughnessMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L120 ; `clearcoatNormalScale` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L129 ; `clearcoatNormalMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L140 ; `ior` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L148 ; `iridescenceMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L184 ; `iridescenceIOR` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L193 ; `iridescenceThicknessRange` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L202 ; `iridescenceThicknessMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L217 ; `sheenColor` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L225 ; `sheenColorMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L238 ; `sheenRoughness` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L246 ; `sheenRoughnessMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L258

///|
let next_material_id : Ref[Int] = Ref::Ref(0)

///|
fn fresh_material_id() -> Int {
  let id = next_material_id.val
  next_material_id.val = id + 1
  id
}

///|
/// 不受光照的基础材质、Lambert，以及直接光的 Standard。
pub(all) enum MaterialKind {
  Basic
  Lambert
  Standard
}

///|
/// 线框端点。默认圆角。斜角和尖角一并存储。渲染器仍按 1 像素画线框。
/// r186: `wireframeLinecap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L213 ; `wireframeLinecap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L354 ; `wireframeLinecap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L376
pub(all) enum WireframeCap {
  Round
  Bevel
  Miter
}

///|
/// 线框拐角。默认圆角。斜角和尖角一并存储。渲染器仍按 1 像素画线框。
/// r186: `wireframeLinejoin` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L223 ; `wireframeLinejoin` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L364 ; `wireframeLinejoin` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L386
pub(all) enum WireframeJoin {
  Round
  Bevel
  Miter
}

///|
/// 材质的公共数据。`alpha_test` 大于片元 alpha 时丢弃该片元，默认 0。
/// `set_alpha_test` 在新值和旧值是否大于 `0` 发生变化时把 `version` 加一。
/// `vertex_colors` 默认关闭。着色器仍不读顶点色。
/// `tone_mapped` 默认打开。色调映射仍对每份绘制过的材质生效。
/// `alpha_hash` 默认关闭。着色器仍不做哈希透明。
/// `alpha_to_coverage` 默认关闭。管线仍不打开 alpha to coverage。
/// `dithering` 默认关闭。着色器仍不对颜色做抖动。
/// `polygon_offset` 默认关闭，`polygon_offset_factor` 和 `polygon_offset_units` 默认 `0`。管线仍不做多边形偏移。
/// `clip_shadows` 默认关闭。阴影通道仍不按裁剪平面裁剪。
/// `clip_intersection` 默认关闭。裁剪仍按并集，渲染器仍没有裁剪平面。
/// `allow_override` 默认打开。渲染器仍不用场景覆盖材质替换它。
/// `blend_alpha` 默认 `0`。混合仍不用常量 alpha。
/// `blend_color` 默认黑色 `(0, 0, 0)`。混合仍不用常量颜色。
/// `blending` 默认 `Normal`。透明绘制仍用现有的源 alpha 混合，管线仍不读这个字段。
/// `blend_src` 默认 `SrcAlpha`。透明绘制仍用现有的源 alpha 混合，管线仍不读这个字段。
/// `blend_dst` 默认 `OneMinusSrcAlpha`。透明绘制仍用现有的源 alpha 混合，管线仍不读这个字段。
/// `blend_equation` 默认 `Add`。透明绘制仍用现有的源 alpha 混合，管线仍不读这个字段。
/// `blend_src_alpha` 默认空。空着时 alpha 通道沿用 `blend_src`。管线仍不读这个字段。
/// `blend_dst_alpha` 默认空。空着时 alpha 通道沿用 `blend_dst`。管线仍不读这个字段。
/// `blend_equation_alpha` 默认空。空着时 alpha 通道沿用 `blend_equation`。管线仍不读这个字段。
/// `stencil_write_mask` 默认 `0xFF`。管线仍不读这个字段。
/// `stencil_func` 默认 `Always`。管线仍不读这个字段。
/// `stencil_ref` 默认 `0`。管线仍不读这个字段。
/// `stencil_func_mask` 默认 `0xFF`。管线仍不读这个字段。
/// `stencil_fail` 默认 `Keep`。比较失败时的模板操作。管线仍不读这个字段。
/// `stencil_z_fail` 默认 `Keep`。比较通过但深度测试失败时的模板操作。管线仍不读这个字段。
/// `stencil_z_pass` 默认 `Keep`。比较通过且深度测试通过时的模板操作。管线仍不读这个字段。
/// `stencil_write` 默认关闭。打开后才对模板缓冲做写入和比较。管线仍不读这个字段。
/// `clipping_planes` 默认空。世界空间平面，有符号距离为负的点会被裁掉。渲染器仍不按这些平面裁剪。
/// `precision` 默认空。空着时沿用渲染器默认精度。管线仍不读这个字段。
/// `user_data` 默认空表。自定义字符串键值。渲染器仍不读这张表。
/// `version` 默认 `0`。记录这份材质被标记为需要重新编译的次数。`set_needs_update(true)` 把它加一，`false` 不改计数。渲染器仍不读这个计数。
/// `id` 从 `0` 起递增。每新建一份基础、Lambert 或 Standard 材质取下一个编号。渲染器仍不读这个编号。
/// `uuid` 在新建时生成，长度 36，版本位是 4。渲染器仍不读这个字符串。
/// `name` 默认空字符串。渲染器仍不读这个名字。
/// `type_name` 对应上游 `type`。基础材质是 `MeshBasicMaterial`，Lambert 是 `MeshLambertMaterial`，Standard 是 `MeshStandardMaterial`。渲染器仍不读这个名字。
/// `listeners` 默认空表。同一种事件里，同一个函数只保留一次。`copy` 不改目标上的这张表。渲染器仍不读它。
/// `emissive` 默认黑色。Lambert 和 Standard 在光照之后加上它，Basic 不用。
/// `emissive_intensity` 默认 1，写入 uniform 时乘在自发光上。`0` 会把它写成黑。
/// `emissive_map` 再乘一次。没有贴图时渲染器绑一张白纹理。
/// `roughness_map` 只进 Standard：绿色通道乘在粗糙度上，再取 0.0525 下限。没有贴图时同样绑白纹理。
/// `metalness_map` 也只进 Standard：蓝色通道乘在金属度上，再夹到 0 和 1。没有贴图时绑白纹理。
/// `alpha_map` 的绿色通道乘在片元 alpha 上，乘完再做 `alpha_test`。Basic、Lambert、Standard 都采样。没有贴图时绑白纹理。
/// `normal_map` 默认空。Lambert 与 Standard 存这张切线空间法线贴图。`copy` 沿用源对象。Basic 也有这个字段。渲染器仍不采样它。
/// `normal_map_type` 默认切线空间，整数 `0`。物体空间是 `1`。Lambert 与 Standard 存这个类型。`copy` 沿用源对象。Basic 也有这个字段。渲染器仍不按它采样法线贴图。
/// `normal_scale` 默认 `(1, 1)`。Lambert 与 Standard 用它缩放法线贴图。`copy` 写进目标自己的向量。Basic 也有这个字段。渲染器仍不采样法线贴图。
/// `displacement_map` 默认空。Lambert 与 Standard 存这张顶点位移贴图。`copy` 沿用源对象。Basic 也有这个字段。渲染器仍不按它移动顶点。
/// `displacement_scale` 默认 `1`。Lambert 与 Standard 用它缩放位移贴图。`copy` 沿用源数值。Basic 也有这个字段。渲染器仍不按它移动顶点。
/// `displacement_bias` 默认 `0`。Lambert 与 Standard 把它加在缩放后的位移上。`copy` 沿用源数值。Basic 也有这个字段。渲染器仍不按它移动顶点。
/// `specular_map` 默认空。Lambert 存这张高光贴图。`copy` 沿用源对象。Basic 与 Standard 也有这个字段。渲染器仍不采样它。
/// `env_map` 默认空。Basic、Lambert、Standard 都存这张环境贴图。`copy` 沿用源对象。渲染器仍不采样它。
/// `env_map_rotation` 默认 `(0, 0, 0)`，顺序 `XYZ`。Basic、Lambert、Standard 用它旋转环境贴图。`copy` 写进目标自己的欧拉角。渲染器仍不采样环境贴图。
/// `combine` 默认相乘，整数 `0`。混合是 `1`，相加是 `2`。Basic 与 Lambert 用它把表面颜色和环境贴图合在一起。`copy` 沿用源值。Standard 也有这个字段。渲染器仍不采样环境贴图。
/// `reflectivity` 默认 `1`。Basic 与 Lambert 在 `combine` 为混合时用它决定环境贴图的比重。`copy` 沿用源数值。Standard 也有这个字段。渲染器仍不采样环境贴图。
/// `env_map_intensity` 默认 `1`。Lambert 与 Standard 用它乘环境贴图的颜色。`copy` 沿用源数值。Basic 也有这个字段。渲染器仍不采样环境贴图。
/// `refraction_ratio` 默认 `0.98`。Basic 与 Lambert 存空气折射率与材质折射率的比。`copy` 沿用源数值。Standard 也有这个字段。渲染器仍不按它做折射。
/// `light_map` 默认空。Basic、Lambert、Standard 都存这张光照贴图。`copy` 沿用源对象。渲染器仍不采样它。
/// `light_map_intensity` 默认 `1`。Basic、Lambert、Standard 用它乘光照贴图。`copy` 沿用源数值。渲染器仍不采样光照贴图。
/// `ao_map` 默认空。Basic、Lambert、Standard 都存这张环境光遮蔽贴图。`copy` 沿用源对象。渲染器仍不采样它。
/// `ao_map_intensity` 默认 `1`。Basic、Lambert、Standard 用它乘环境光遮蔽。`copy` 沿用源数值。渲染器仍不采样环境光遮蔽贴图。
/// `bump_map` 默认空。Lambert 与 Standard 存这张凹凸贴图。`copy` 沿用源对象。Basic 也有这个字段。渲染器仍不采样它。
/// `bump_scale` 默认 `1`。Lambert 与 Standard 用它缩放凹凸贴图。`copy` 沿用源数值。Basic 也有这个字段。渲染器仍不采样凹凸贴图。
/// `wireframe_linewidth` 默认 `1`。Basic、Lambert、Standard 存线框宽度。`copy` 沿用源数值。渲染器仍按 1 像素画线框。
/// `wireframe_linecap` 默认圆角。斜角和尖角一并存储。Basic、Lambert、Standard 存线框端点。`copy` 沿用源值。渲染器仍按 1 像素画线框。
/// `wireframe_linejoin` 默认圆角。斜角和尖角一并存储。Basic、Lambert、Standard 存线框拐角。`copy` 沿用源值。渲染器仍按 1 像素画线框。
/// `defines` 默认空。Standard 新建以及 `copy` 到 Standard 时写成只有 `STANDARD` 对空字符串。源上改过的键不跟着走。Basic 与 Lambert 的表留在目标上。渲染器仍不读这张表。
/// `anisotropy_rotation` 默认 `0`。上游注释写默认 `1`，赋值是 `0`。Basic、Lambert、Standard 一并存储。`copy` 沿用源数值。渲染器仍不旋转各向异性。
/// `anisotropy_map` 默认空。Basic、Lambert、Standard 都存这张各向异性贴图。`copy` 沿用源对象。渲染器仍不采样它。
/// `clearcoat_map` 默认空。Basic、Lambert、Standard 都存这张清漆贴图。`copy` 沿用源对象。渲染器仍不采样它。
/// `clearcoat_roughness` 默认 `0`。Basic、Lambert、Standard 用它表示清漆层的粗糙度。`copy` 沿用源数值。渲染器仍不画清漆。
/// `clearcoat_roughness_map` 默认空。Basic、Lambert、Standard 都存这张清漆粗糙度贴图。`copy` 沿用源对象。渲染器仍不采样它。
/// `clearcoat_normal_scale` 默认 `(1, 1)`。Basic、Lambert、Standard 用它缩放清漆法线贴图。`copy` 写进目标自己的向量。渲染器仍不采样清漆法线。
/// `clearcoat_normal_map` 默认空。Basic、Lambert、Standard 都存这张清漆法线贴图。`copy` 沿用源对象。渲染器仍不采样它。
/// `ior` 默认 `1.5`。Basic、Lambert、Standard 用它表示非金属的折射率。`copy` 沿用源数值。渲染器仍不按它算反射率。
/// `iridescence_map` 默认空。Basic、Lambert、Standard 都存这张彩虹贴图。`copy` 沿用源对象。渲染器仍不采样它。
/// `iridescence_ior` 默认 `1.3`。Basic、Lambert、Standard 用它表示彩虹层的折射率。`copy` 沿用源数值。渲染器仍不算彩虹。
/// `iridescence_thickness_range` 默认 `[100, 400]`。Basic、Lambert、Standard 用它表示彩虹层的最小和最大厚度。`copy` 复制成一张新数组。渲染器仍不算彩虹。
/// `iridescence_thickness_map` 默认空。Basic、Lambert、Standard 都存这张彩虹厚度贴图。`copy` 沿用源对象。渲染器仍不采样它。
/// `sheen_color` 默认黑色。Basic、Lambert、Standard 用它表示光泽颜色。`copy` 写进目标自己的颜色。渲染器仍不算光泽。
/// `sheen_color_map` 默认空。Basic、Lambert、Standard 都存这张光泽颜色贴图。`copy` 沿用源对象。渲染器仍不采样它。
/// `sheen_roughness` 默认 `1`。Basic、Lambert、Standard 用它表示光泽层的粗糙度。`copy` 沿用源数值。渲染器仍不算光泽。
/// `sheen_roughness_map` 默认空。Basic、Lambert、Standard 都存这张光泽粗糙度贴图。`copy` 沿用源对象。渲染器仍不采样它。
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
/// r186: `Material` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L19 ; `vertexColors` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L99 ; `toneMapped` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L458 ; `alphaHash` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L135 ; `alphaToCoverage` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L409 ; `dithering` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L399 ; `polygonOffset` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L375 ; `polygonOffsetFactor` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L383 ; `polygonOffsetUnits` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L391 ; `clipShadows` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L329 ; `clipIntersection` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L320 ; `allowOverride` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L439 ; `blendAlpha` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L203 ; `blendColor` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L193 ; `blending` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L80 ; `blendSrc` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L143 ; `blendDst` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L151 ; `blendEquation` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L159 ; `blendSrcAlpha` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L167 ; `blendDstAlpha` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L175 ; `blendEquationAlpha` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L183 ; `stencilWriteMask` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L239 ; `stencilFunc` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L247 ; `stencilRef` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L255 ; `stencilFuncMask` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L263 ; `stencilFail` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L271 ; `stencilZFail` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L280 ; `stencilZPass` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L289 ; `stencilWrite` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L299 ; `clippingPlanes` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L311 ; `precision` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L361 ; `userData` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L466 ; `version` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L475 ; `id` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L44 ; `uuid` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L52 ; `name` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L59 ; `type` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L38 ; `type` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L48 ; `type` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L65 ; `depthFunc` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L211 ; `depthTest` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L220 ; `depthWrite` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L231 ; `colorWrite` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L353 ; `premultipliedAlpha` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L417 ; `shadowSide` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L342 ; `visible` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L447 ; `forceSinglePass` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L431 ; `_getBlending` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgpu/utils/WebGPUPipelineUtils.js#L552 ; `_getDepthCompare` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgpu/utils/WebGPUPipelineUtils.js#L948 ; `_getColorWriteMask` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgpu/utils/WebGPUPipelineUtils.js#L935 ; `emissiveIntensity` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L130 ; `emissiveIntensity` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L170 ; `roughnessMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L288 ; `metalnessMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L300 ; `alphaMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L133 ; `normalMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L182 ; `normalMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L222 ; `normalMapType` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L190 ; `normalMapType` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L230 ; `normalScale` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L198 ; `normalScale` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L238 ; `displacementMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L216 ; `displacementMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L256 ; `displacementScale` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L226 ; `displacementScale` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L266 ; `displacementBias` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L236 ; `displacementBias` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L276 ; `specularMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L248 ; `envMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L146 ; `envMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L279 ; `envMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L332 ; `envMapRotation` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L154 ; `envMapRotation` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L287 ; `envMapRotation` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L340 ; `combine` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L165 ; `combine` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L298 ; `reflectivity` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L174 ; `reflectivity` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L307 ; `envMapIntensity` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L315 ; `envMapIntensity` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L348 ; `refractionRatio` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L185 ; `refractionRatio` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L326 ; `lightMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L73 ; `lightMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L83 ; `lightMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L123 ; `lightMapIntensity` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L81 ; `lightMapIntensity` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L91 ; `lightMapIntensity` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L131 ; `aoMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L93 ; `aoMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L103 ; `aoMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L143 ; `aoMapIntensity` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L103 ; `aoMapIntensity` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L113 ; `aoMapIntensity` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L153 ; `bumpMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L158 ; `bumpMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L198 ; `bumpScale` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L166 ; `bumpScale` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L206 ; `wireframeLinewidth` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L203 ; `wireframeLinewidth` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L344 ; `wireframeLinewidth` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L366 ; `wireframeLinecap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L213 ; `wireframeLinecap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L354 ; `wireframeLinecap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L376 ; `wireframeLinejoin` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L223 ; `wireframeLinejoin` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L364 ; `wireframeLinejoin` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L386 ; `defines` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L67 ; `anisotropyRotation` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L75 ; `anisotropyMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L88 ; `clearcoatMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L100 ; `clearcoatRoughness` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L108 ; `clearcoatRoughnessMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L120 ; `clearcoatNormalScale` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L129 ; `clearcoatNormalMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L140 ; `ior` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L148 ; `iridescenceMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L184 ; `iridescenceIOR` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L193 ; `iridescenceThicknessRange` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L202 ; `iridescenceThicknessMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L217 ; `sheenColor` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L225 ; `sheenColorMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L238 ; `sheenRoughness` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L246 ; `sheenRoughnessMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L258 ; `flatShading` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L372
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
  mut normal_map : @textures.Texture?
  mut normal_map_type : @constants.NormalMapType
  normal_scale : @math.Vector2
  mut displacement_map : @textures.Texture?
  mut displacement_scale : Double
  mut displacement_bias : Double
  mut specular_map : @textures.Texture?
  mut env_map : @textures.Texture?
  env_map_rotation : @math.Euler
  mut combine : @constants.Combine
  mut reflectivity : Double
  mut env_map_intensity : Double
  mut refraction_ratio : Double
  mut light_map : @textures.Texture?
  mut light_map_intensity : Double
  mut ao_map : @textures.Texture?
  mut ao_map_intensity : Double
  mut bump_map : @textures.Texture?
  mut bump_scale : Double
  mut wireframe_linewidth : Double
  mut wireframe_linecap : WireframeCap
  mut wireframe_linejoin : WireframeJoin
  mut defines : Map[String, String]
  mut anisotropy_rotation : Double
  mut anisotropy_map : @textures.Texture?
  mut clearcoat_map : @textures.Texture?
  mut clearcoat_roughness : Double
  mut clearcoat_roughness_map : @textures.Texture?
  clearcoat_normal_scale : @math.Vector2
  mut clearcoat_normal_map : @textures.Texture?
  mut ior : Double
  mut iridescence_map : @textures.Texture?
  mut iridescence_ior : Double
  mut iridescence_thickness_range : Array[Double]
  mut iridescence_thickness_map : @textures.Texture?
  sheen_color : @math.Color
  mut sheen_color_map : @textures.Texture?
  mut sheen_roughness : Double
  mut sheen_roughness_map : @textures.Texture?
  mut vertex_colors : Bool
  mut tone_mapped : Bool
  mut alpha_hash : Bool
  mut alpha_to_coverage : Bool
  mut dithering : Bool
  mut polygon_offset : Bool
  mut polygon_offset_factor : Double
  mut polygon_offset_units : Double
  mut clip_shadows : Bool
  mut clip_intersection : Bool
  mut allow_override : Bool
  mut blend_alpha : Double
  blend_color : @math.Color
  mut blending : @constants.Blending
  mut blend_src : @constants.BlendFactor
  mut blend_dst : @constants.BlendFactor
  mut blend_equation : @constants.BlendEquation
  mut blend_src_alpha : @constants.BlendFactor?
  mut blend_dst_alpha : @constants.BlendFactor?
  mut blend_equation_alpha : @constants.BlendEquation?
  mut stencil_write_mask : Int
  mut stencil_func : @constants.StencilFunc
  mut stencil_ref : Int
  mut stencil_func_mask : Int
  mut stencil_fail : @constants.StencilOp
  mut stencil_z_fail : @constants.StencilOp
  mut stencil_z_pass : @constants.StencilOp
  mut stencil_write : Bool
  mut clipping_planes : Array[@math.Plane]?
  mut precision : @constants.Precision?
  mut user_data : Map[String, String]
  mut version : Int
  id : Int
  mut uuid : String
  mut name : String
  type_name : String
  kind : MaterialKind
  listeners : Map[String, Array[() -> Unit]]
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
    normal_map: None,
    normal_map_type: @constants.TangentSpace,
    normal_scale: @math.Vector2::new(x=1.0, y=1.0),
    displacement_map: None,
    displacement_scale: 1.0,
    displacement_bias: 0.0,
    specular_map: None,
    env_map: None,
    env_map_rotation: @math.Euler::new(),
    combine: @constants.Combine::Multiply,
    reflectivity: 1.0,
    env_map_intensity: 1.0,
    refraction_ratio: 0.98,
    light_map: None,
    light_map_intensity: 1.0,
    ao_map: None,
    ao_map_intensity: 1.0,
    bump_map: None,
    bump_scale: 1.0,
    wireframe_linewidth: 1.0,
    wireframe_linecap: WireframeCap::Round,
    wireframe_linejoin: WireframeJoin::Round,
    defines: Map([]),
    anisotropy_rotation: 0.0,
    anisotropy_map: None,
    clearcoat_map: None,
    clearcoat_roughness: 0.0,
    clearcoat_roughness_map: None,
    clearcoat_normal_scale: @math.Vector2::new(x=1.0, y=1.0),
    clearcoat_normal_map: None,
    ior: 1.5,
    iridescence_map: None,
    iridescence_ior: 1.3,
    iridescence_thickness_range: fresh_iridescence_thickness_range(),
    iridescence_thickness_map: None,
    sheen_color: @math.Color::new(r=0.0, g=0.0, b=0.0),
    sheen_color_map: None,
    sheen_roughness: 1.0,
    sheen_roughness_map: None,
    vertex_colors: false,
    tone_mapped: true,
    alpha_hash: false,
    alpha_to_coverage: false,
    dithering: false,
    polygon_offset: false,
    polygon_offset_factor: 0.0,
    polygon_offset_units: 0.0,
    clip_shadows: false,
    clip_intersection: false,
    allow_override: true,
    blend_alpha: 0.0,
    blend_color: @math.Color::new(r=0.0, g=0.0, b=0.0),
    blending: @constants.Normal,
    blend_src: @constants.SrcAlpha,
    blend_dst: @constants.OneMinusSrcAlpha,
    blend_equation: @constants.Add,
    blend_src_alpha: None,
    blend_dst_alpha: None,
    blend_equation_alpha: None,
    stencil_write_mask: 0xFF,
    stencil_func: @constants.StencilFunc::Always,
    stencil_ref: 0,
    stencil_func_mask: 0xFF,
    stencil_fail: @constants.StencilOp::Keep,
    stencil_z_fail: @constants.StencilOp::Keep,
    stencil_z_pass: @constants.StencilOp::Keep,
    stencil_write: false,
    clipping_planes: None,
    precision: None,
    user_data: Map([]),
    version: 0,
    id: fresh_material_id(),
    uuid: @math.generate_uuid(),
    name: "",
    type_name: "MeshBasicMaterial",
    kind: Basic,
    listeners: Map([]),
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
    normal_map: None,
    normal_map_type: @constants.TangentSpace,
    normal_scale: @math.Vector2::new(x=1.0, y=1.0),
    displacement_map: None,
    displacement_scale: 1.0,
    displacement_bias: 0.0,
    specular_map: None,
    env_map: None,
    env_map_rotation: @math.Euler::new(),
    combine: @constants.Combine::Multiply,
    reflectivity: 1.0,
    env_map_intensity: 1.0,
    refraction_ratio: 0.98,
    light_map: None,
    light_map_intensity: 1.0,
    ao_map: None,
    ao_map_intensity: 1.0,
    bump_map: None,
    bump_scale: 1.0,
    wireframe_linewidth: 1.0,
    wireframe_linecap: WireframeCap::Round,
    wireframe_linejoin: WireframeJoin::Round,
    defines: Map([]),
    anisotropy_rotation: 0.0,
    anisotropy_map: None,
    clearcoat_map: None,
    clearcoat_roughness: 0.0,
    clearcoat_roughness_map: None,
    clearcoat_normal_scale: @math.Vector2::new(x=1.0, y=1.0),
    clearcoat_normal_map: None,
    ior: 1.5,
    iridescence_map: None,
    iridescence_ior: 1.3,
    iridescence_thickness_range: fresh_iridescence_thickness_range(),
    iridescence_thickness_map: None,
    sheen_color: @math.Color::new(r=0.0, g=0.0, b=0.0),
    sheen_color_map: None,
    sheen_roughness: 1.0,
    sheen_roughness_map: None,
    vertex_colors: false,
    tone_mapped: true,
    alpha_hash: false,
    alpha_to_coverage: false,
    dithering: false,
    polygon_offset: false,
    polygon_offset_factor: 0.0,
    polygon_offset_units: 0.0,
    clip_shadows: false,
    clip_intersection: false,
    allow_override: true,
    blend_alpha: 0.0,
    blend_color: @math.Color::new(r=0.0, g=0.0, b=0.0),
    blending: @constants.Normal,
    blend_src: @constants.SrcAlpha,
    blend_dst: @constants.OneMinusSrcAlpha,
    blend_equation: @constants.Add,
    blend_src_alpha: None,
    blend_dst_alpha: None,
    blend_equation_alpha: None,
    stencil_write_mask: 0xFF,
    stencil_func: @constants.StencilFunc::Always,
    stencil_ref: 0,
    stencil_func_mask: 0xFF,
    stencil_fail: @constants.StencilOp::Keep,
    stencil_z_fail: @constants.StencilOp::Keep,
    stencil_z_pass: @constants.StencilOp::Keep,
    stencil_write: false,
    clipping_planes: None,
    precision: None,
    user_data: Map([]),
    version: 0,
    id: fresh_material_id(),
    uuid: @math.generate_uuid(),
    name: "",
    type_name: "MeshLambertMaterial",
    kind: Lambert,
    listeners: Map([]),
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
    normal_map: None,
    normal_map_type: @constants.TangentSpace,
    normal_scale: @math.Vector2::new(x=1.0, y=1.0),
    displacement_map: None,
    displacement_scale: 1.0,
    displacement_bias: 0.0,
    specular_map: None,
    env_map: None,
    env_map_rotation: @math.Euler::new(),
    combine: @constants.Combine::Multiply,
    reflectivity: 1.0,
    env_map_intensity: 1.0,
    refraction_ratio: 0.98,
    light_map: None,
    light_map_intensity: 1.0,
    ao_map: None,
    ao_map_intensity: 1.0,
    bump_map: None,
    bump_scale: 1.0,
    wireframe_linewidth: 1.0,
    wireframe_linecap: WireframeCap::Round,
    wireframe_linejoin: WireframeJoin::Round,
    defines: fresh_standard_defines(),
    anisotropy_rotation: 0.0,
    anisotropy_map: None,
    clearcoat_map: None,
    clearcoat_roughness: 0.0,
    clearcoat_roughness_map: None,
    clearcoat_normal_scale: @math.Vector2::new(x=1.0, y=1.0),
    clearcoat_normal_map: None,
    ior: 1.5,
    iridescence_map: None,
    iridescence_ior: 1.3,
    iridescence_thickness_range: fresh_iridescence_thickness_range(),
    iridescence_thickness_map: None,
    sheen_color: @math.Color::new(r=0.0, g=0.0, b=0.0),
    sheen_color_map: None,
    sheen_roughness: 1.0,
    sheen_roughness_map: None,
    vertex_colors: false,
    tone_mapped: true,
    alpha_hash: false,
    alpha_to_coverage: false,
    dithering: false,
    polygon_offset: false,
    polygon_offset_factor: 0.0,
    polygon_offset_units: 0.0,
    clip_shadows: false,
    clip_intersection: false,
    allow_override: true,
    blend_alpha: 0.0,
    blend_color: @math.Color::new(r=0.0, g=0.0, b=0.0),
    blending: @constants.Normal,
    blend_src: @constants.SrcAlpha,
    blend_dst: @constants.OneMinusSrcAlpha,
    blend_equation: @constants.Add,
    blend_src_alpha: None,
    blend_dst_alpha: None,
    blend_equation_alpha: None,
    stencil_write_mask: 0xFF,
    stencil_func: @constants.StencilFunc::Always,
    stencil_ref: 0,
    stencil_func_mask: 0xFF,
    stencil_fail: @constants.StencilOp::Keep,
    stencil_z_fail: @constants.StencilOp::Keep,
    stencil_z_pass: @constants.StencilOp::Keep,
    stencil_write: false,
    clipping_planes: None,
    precision: None,
    user_data: Map([]),
    version: 0,
    id: fresh_material_id(),
    uuid: @math.generate_uuid(),
    name: "",
    type_name: "MeshStandardMaterial",
    kind: Standard,
    listeners: Map([]),
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
/// 传入 `true` 时把 `version` 加一。传入 `false` 时计数不变。渲染器仍不因这次标记重新编译。
/// r186: `needsUpdate` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1227
pub fn Material::set_needs_update(self : Material, value : Bool) -> Unit {
  if value {
    self.version = self.version + 1
  }
}

///|
/// 写入 `alpha_test`。新值和旧值是否大于 `0` 发生变化时，把 `version` 加一。
/// r186: `alphaTest` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L495
pub fn Material::set_alpha_test(self : Material, value : Double) -> Unit {
  if (self.alpha_test > 0.0) != (value > 0.0) {
    self.version = self.version + 1
  }
  self.alpha_test = value
}

///|
fn fresh_iridescence_thickness_range() -> Array[Double] {
  [100.0, 400.0]
}

///|
/// 把厚度范围复制成一张新数组。改目标里的数不会改到源。
fn copied_doubles(source : Array[Double]) -> Array[Double] {
  let copied : Array[Double] = []
  for value in source {
    copied.push(value)
  }
  copied
}

///|
/// Standard 的着色器宏。新建一张表，只有 `STANDARD` 对空字符串。
fn fresh_standard_defines() -> Map[String, String] {
  let defines : Map[String, String] = Map([])
  defines.set("STANDARD", "")
  defines
}

///|
/// 把颜色、常量混合色、自发光、光泽颜色、法线缩放、清漆法线缩放和环境贴图旋转写进目标自己的对象。颜色贴图、透明贴图、法线贴图、`normal_map_type`、位移贴图、高光贴图、环境贴图、光照贴图、环境光遮蔽贴图、凹凸贴图、各向异性贴图、清漆贴图、清漆粗糙度贴图、清漆法线贴图、彩虹贴图、彩虹厚度贴图、光泽颜色贴图、光泽粗糙度贴图、自发光贴图、粗糙度贴图和金属度贴图沿用源对象。
/// `name`、`side`、`shadow_side`、不透明度、透明开关、线框、`wireframe_linewidth`、`wireframe_linecap`、`wireframe_linejoin`、`anisotropy_rotation`、`clearcoat_roughness`、`ior`、`iridescence_ior`、`iridescence_thickness_range`、`sheen_roughness`、粗糙度、金属度、`displacement_scale`、`displacement_bias`、`combine`、`reflectivity`、`env_map_intensity`、`refraction_ratio`、`light_map_intensity`、`ao_map_intensity`、`bump_scale`、雾、`flat_shading`、`emissive_intensity`、`alpha_test`、深度、颜色写入、预乘、可见性、`force_single_pass`、顶点色、色调映射、`alpha_hash`、`alpha_to_coverage`、`dithering`、多边形偏移、`clip_shadows`、`clip_intersection`、`allow_override`、`blend_alpha`、`blending`、`blend_src`、`blend_dst`、`blend_equation`、`blend_src_alpha`、`blend_dst_alpha`、`blend_equation_alpha`、`stencil_write_mask`、`stencil_func`、`stencil_ref`、`stencil_func_mask`、`stencil_fail`、`stencil_z_fail`、`stencil_z_pass`、`stencil_write`、`clipping_planes`、`precision` 和 `user_data` 一并复制。`user_data` 复制成一张新表。`iridescence_thickness_range` 复制成一张新数组。`clipping_planes` 沿用源数组。目标是 Standard 时，`defines` 换成一张新表，只有 `STANDARD` 对空字符串。源表不复制。Basic 与 Lambert 的 `defines` 留在目标上。`alpha_test` 经 `set_alpha_test` 写入，穿过 `0` 时目标的 `version` 加一。`id`、`uuid`、`type_name`、`kind`、`listeners` 和其余的 `version` 留在目标上。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1119
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshBasicMaterial.js#L237
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshLambertMaterial.js#L386
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L408
/// r186: `defines` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshStandardMaterial.js#L412
/// r186: `anisotropyRotation` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L560
/// r186: `anisotropyMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L561
/// r186: `clearcoatMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L564
/// r186: `clearcoatRoughness` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L565
/// r186: `clearcoatRoughnessMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L566
/// r186: `clearcoatNormalScale` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L568
/// r186: `clearcoatNormalMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L567
/// r186: `ior` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L571
/// r186: `iridescenceMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L574
/// r186: `iridescenceIOR` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L575
/// r186: `iridescenceThicknessRange` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L576
/// r186: `iridescenceThicknessMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L577
/// r186: `sheenColor` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L582
/// r186: `sheenColorMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L583
/// r186: `sheenRoughness` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L584
/// r186: `sheenRoughnessMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/MeshPhysicalMaterial.js#L585
pub fn Material::copy(self : Material, source : Material) -> Material {
  self.name = source.name
  ignore(self.color.copy(source.color))
  ignore(self.blend_color.copy(source.blend_color))
  ignore(self.emissive.copy(source.emissive))
  ignore(self.normal_scale.copy(source.normal_scale))
  ignore(self.env_map_rotation.copy(source.env_map_rotation))
  self.blending = source.blending
  self.blend_src = source.blend_src
  self.blend_dst = source.blend_dst
  self.blend_equation = source.blend_equation
  self.blend_src_alpha = source.blend_src_alpha
  self.blend_dst_alpha = source.blend_dst_alpha
  self.blend_equation_alpha = source.blend_equation_alpha
  self.stencil_write_mask = source.stencil_write_mask
  self.stencil_func = source.stencil_func
  self.stencil_ref = source.stencil_ref
  self.stencil_func_mask = source.stencil_func_mask
  self.stencil_fail = source.stencil_fail
  self.stencil_z_fail = source.stencil_z_fail
  self.stencil_z_pass = source.stencil_z_pass
  self.stencil_write = source.stencil_write
  self.clipping_planes = source.clipping_planes
  self.precision = source.precision
  let copied : Map[String, String] = Map([])
  for pair in source.user_data.iter() {
    let (key, value) = pair
    copied.set(key, value)
  }
  self.user_data = copied
  self.map = source.map
  self.alpha_map = source.alpha_map
  self.normal_map = source.normal_map
  self.normal_map_type = source.normal_map_type
  self.displacement_map = source.displacement_map
  self.displacement_scale = source.displacement_scale
  self.displacement_bias = source.displacement_bias
  self.specular_map = source.specular_map
  self.env_map = source.env_map
  self.combine = source.combine
  self.reflectivity = source.reflectivity
  self.env_map_intensity = source.env_map_intensity
  self.refraction_ratio = source.refraction_ratio
  self.light_map = source.light_map
  self.light_map_intensity = source.light_map_intensity
  self.ao_map = source.ao_map
  self.ao_map_intensity = source.ao_map_intensity
  self.bump_map = source.bump_map
  self.bump_scale = source.bump_scale
  self.wireframe_linewidth = source.wireframe_linewidth
  self.wireframe_linecap = source.wireframe_linecap
  self.wireframe_linejoin = source.wireframe_linejoin
  match self.kind {
    Standard => self.defines = fresh_standard_defines()
    Basic => ()
    Lambert => ()
  }
  self.anisotropy_rotation = source.anisotropy_rotation
  self.anisotropy_map = source.anisotropy_map
  self.clearcoat_map = source.clearcoat_map
  self.clearcoat_roughness = source.clearcoat_roughness
  self.clearcoat_roughness_map = source.clearcoat_roughness_map
  ignore(self.clearcoat_normal_scale.copy(source.clearcoat_normal_scale))
  self.clearcoat_normal_map = source.clearcoat_normal_map
  self.ior = source.ior
  self.iridescence_map = source.iridescence_map
  self.iridescence_ior = source.iridescence_ior
  self.iridescence_thickness_range = copied_doubles(
    source.iridescence_thickness_range,
  )
  self.iridescence_thickness_map = source.iridescence_thickness_map
  ignore(self.sheen_color.copy(source.sheen_color))
  self.sheen_color_map = source.sheen_color_map
  self.sheen_roughness = source.sheen_roughness
  self.sheen_roughness_map = source.sheen_roughness_map
  self.emissive_map = source.emissive_map
  self.roughness_map = source.roughness_map
  self.metalness_map = source.metalness_map
  self.side = source.side
  self.shadow_side = source.shadow_side
  self.opacity = source.opacity
  self.set_alpha_test(source.alpha_test)
  self.transparent = source.transparent
  self.wireframe = source.wireframe
  self.roughness = source.roughness
  self.metalness = source.metalness
  self.fog = source.fog
  self.flat_shading = source.flat_shading
  self.emissive_intensity = source.emissive_intensity
  self.depth_write = source.depth_write
  self.depth_test = source.depth_test
  self.depth_func = source.depth_func
  self.color_write = source.color_write
  self.premultiplied_alpha = source.premultiplied_alpha
  self.visible = source.visible
  self.force_single_pass = source.force_single_pass
  self.vertex_colors = source.vertex_colors
  self.tone_mapped = source.tone_mapped
  self.alpha_hash = source.alpha_hash
  self.alpha_to_coverage = source.alpha_to_coverage
  self.dithering = source.dithering
  self.polygon_offset = source.polygon_offset
  self.polygon_offset_factor = source.polygon_offset_factor
  self.polygon_offset_units = source.polygon_offset_units
  self.clip_shadows = source.clip_shadows
  self.clip_intersection = source.clip_intersection
  self.allow_override = source.allow_override
  self.blend_alpha = source.blend_alpha
  self
}

///|
/// 按 `kind` 新建一份材质，再 `copy`。新材质有自己的 `id` 和 `uuid`。`type_name` 跟着 `kind`：基础是 `MeshBasicMaterial`，Lambert 是 `MeshLambertMaterial`，Standard 是 `MeshStandardMaterial`。`copy` 不改这三项。`alpha_test` 穿过 `0` 时新材质的 `version` 从 `0` 加一。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1107
pub fn Material::clone(self : Material) -> Material {
  let created = match self.kind {
    Basic => Material::basic()
    Lambert => Material::lambert()
    Standard => Material::standard()
  }
  created.copy(self)
}

///|
/// 登记一个监听。同一种事件里，同一个函数只保留一次。
/// r186: `addEventListener` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L31
pub fn Material::add_event_listener(
  self : Material,
  kind : String,
  listener : () -> Unit,
) -> Unit {
  let listeners = self.listeners.get_or_init(kind, fn() { [] })
  let mut found = false
  for existing in listeners {
    if physical_equal(existing, listener) {
      found = true
    }
  }
  if !found {
    listeners.push(listener)
  }
}

///|
/// 同一种事件里是否已经有这个监听。
/// r186: `hasEventListener` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L58
pub fn Material::has_event_listener(
  self : Material,
  kind : String,
  listener : () -> Unit,
) -> Bool {
  match self.listeners.get(kind) {
    None => false
    Some(listeners) => {
      let mut found = false
      for existing in listeners {
        if physical_equal(existing, listener) {
          found = true
        }
      }
      found
    }
  }
}

///|
/// 从一种事件里移除这个监听。没有登记时不动。
/// r186: `removeEventListener` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L74
pub fn Material::remove_event_listener(
  self : Material,
  kind : String,
  listener : () -> Unit,
) -> Unit {
  match self.listeners.get(kind) {
    None => ()
    Some(listeners) => {
      let mut index = None
      for i in 0..<listeners.length() {
        if physical_equal(listeners[i], listener) {
          index = Some(i)
        }
      }
      match index {
        None => ()
        Some(index) => ignore(listeners.remove(index))
      }
    }
  }
}

///|
/// 按名字通知已经登记的监听。调用期间改列表不会漏掉这一轮快照。
/// r186: `dispatchEvent` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L101
pub fn Material::dispatch_event(self : Material, kind : String) -> Unit {
  match self.listeners.get(kind) {
    None => ()
    Some(listeners) => {
      let snapshot = listeners.copy()
      for listener in snapshot {
        listener()
      }
    }
  }
}

///|
/// 通知 `dispose` 监听。其它事件不动。渲染器仍不因这次调用释放资源。
/// r186: `dispose` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1207
pub fn Material::dispose(self : Material) -> Unit {
  self.dispatch_event("dispose")
}

///|
/// 点精灵。`size` 是像素，`size_attenuation` 为真时按透视缩小，对齐 r186 `PointsMaterial`。
/// 颜色贴图和透明贴图默认空。点着色器仍按材质颜色绘制，不采样这两张贴图。
/// `side` 默认正面。背面和双面一并存储。`copy` 沿用源值。点绘制仍不按这个面剔除。
/// `shadow_side` 默认空。`copy` 沿用源值。点仍不投射阴影。
/// `force_single_pass` 默认关闭。`copy` 沿用源值。点绘制仍不按它合并正反面。
/// `alpha_test` 默认 `0`。点着色器在片元 alpha 小于它时丢弃。`set_alpha_test` 在新值和旧值是否大于 `0` 发生变化时把 `version` 加一。
/// `vertex_colors` 默认关闭。点着色器仍不读顶点色。
/// `tone_mapped` 默认打开。色调映射仍对每份绘制过的点生效。
/// `alpha_hash` 默认关闭。点着色器仍不做哈希透明。
/// `alpha_to_coverage` 默认关闭。点绘制仍不打开 alpha to coverage。
/// `dithering` 默认关闭。点着色器仍不对颜色做抖动。
/// `polygon_offset` 默认关闭，`polygon_offset_factor` 和 `polygon_offset_units` 默认 `0`。点绘制仍不做多边形偏移。
/// `clip_shadows` 默认关闭。点仍不投射阴影。
/// `clip_intersection` 默认关闭。点绘制仍没有裁剪平面。
/// `allow_override` 默认打开。点绘制仍不用场景覆盖材质替换它。
/// `blend_alpha` 默认 `0`。点绘制的混合仍不用常量 alpha。
/// `blend_color` 默认黑色 `(0, 0, 0)`。点绘制的混合仍不用常量颜色。
/// `blending` 默认 `Normal`。点绘制的透明混合仍用现有的源 alpha，管线仍不读这个字段。
/// `blend_src` 默认 `SrcAlpha`。点绘制的透明混合仍用现有的源 alpha，管线仍不读这个字段。
/// `blend_dst` 默认 `OneMinusSrcAlpha`。点绘制的透明混合仍用现有的源 alpha，管线仍不读这个字段。
/// `blend_equation` 默认 `Add`。点绘制的透明混合仍用现有的源 alpha，管线仍不读这个字段。
/// `blend_src_alpha` 默认空。空着时 alpha 通道沿用 `blend_src`。管线仍不读这个字段。
/// `blend_dst_alpha` 默认空。空着时 alpha 通道沿用 `blend_dst`。管线仍不读这个字段。
/// `blend_equation_alpha` 默认空。空着时 alpha 通道沿用 `blend_equation`。管线仍不读这个字段。
/// `stencil_write_mask` 默认 `0xFF`。管线仍不读这个字段。
/// `stencil_func` 默认 `Always`。管线仍不读这个字段。
/// `stencil_ref` 默认 `0`。管线仍不读这个字段。
/// `stencil_func_mask` 默认 `0xFF`。管线仍不读这个字段。
/// `stencil_fail` 默认 `Keep`。比较失败时的模板操作。管线仍不读这个字段。
/// `stencil_z_fail` 默认 `Keep`。比较通过但深度测试失败时的模板操作。管线仍不读这个字段。
/// `stencil_z_pass` 默认 `Keep`。比较通过且深度测试通过时的模板操作。管线仍不读这个字段。
/// `stencil_write` 默认关闭。打开后才对模板缓冲做写入和比较。管线仍不读这个字段。
/// `clipping_planes` 默认空。世界空间平面，有符号距离为负的点会被裁掉。点绘制仍不按这些平面裁剪。
/// `precision` 默认空。空着时沿用渲染器默认精度。管线仍不读这个字段。
/// `user_data` 默认空表。自定义字符串键值。点绘制仍不读这张表。
/// `version` 默认 `0`。记录这份材质被标记为需要重新编译的次数。`set_needs_update(true)` 把它加一，`false` 不改计数。`copy` 不改目标上的这个计数。点绘制仍不读它。
/// `id` 与网格材质共用从 `0` 起的计数。每新建一份点材质取下一个编号。`copy` 不改目标上的这个编号。点绘制仍不读它。
/// `uuid` 在新建时生成，长度 36，版本位是 4。`copy` 不改目标上的这个字符串。点绘制仍不读它。
/// `name` 默认空字符串。`copy` 把名字写进目标。点绘制仍不读它。
/// `type_name` 对应上游 `type`，固定是 `PointsMaterial`。`copy` 不改目标上的这个名字。点绘制仍不读它。
/// `listeners` 默认空表。同一种事件里，同一个函数只保留一次。`copy` 不改目标上的这张表。点绘制仍不读它。
/// r186: `PointsMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/PointsMaterial.js#L29
/// r186: `side` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L88
/// r186: `shadowSide` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L342
/// r186: `forceSinglePass` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L431
/// r186: `map` https://github.com/mrdoob/three.js/blob/r186/src/materials/PointsMaterial.js#L75
/// r186: `alphaMap` https://github.com/mrdoob/three.js/blob/r186/src/materials/PointsMaterial.js#L93
/// r186: `alphaTest` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L489
/// r186: `vertexColors` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L99
/// r186: `toneMapped` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L458
/// r186: `alphaHash` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L135
/// r186: `alphaToCoverage` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L409
/// r186: `dithering` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L399
/// r186: `polygonOffset` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L375
/// r186: `polygonOffsetFactor` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L383
/// r186: `polygonOffsetUnits` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L391
/// r186: `clipShadows` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L329
/// r186: `clipIntersection` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L320
/// r186: `allowOverride` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L439
/// r186: `blendAlpha` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L203
/// r186: `blendColor` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L193
/// r186: `blending` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L80
/// r186: `blendSrc` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L143
/// r186: `blendDst` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L151
/// r186: `blendEquation` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L159
/// r186: `blendSrcAlpha` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L167
/// r186: `blendDstAlpha` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L175
/// r186: `blendEquationAlpha` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L183
/// r186: `stencilWriteMask` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L239
/// r186: `stencilFunc` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L247
/// r186: `stencilRef` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L255
/// r186: `stencilFuncMask` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L263
/// r186: `stencilFail` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L271
/// r186: `stencilZFail` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L280
/// r186: `stencilZPass` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L289
/// r186: `stencilWrite` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L299
/// r186: `clippingPlanes` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L311
/// r186: `precision` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L361
/// r186: `userData` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L466
/// r186: `version` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L475
/// r186: `id` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L44
/// r186: `uuid` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L52
/// r186: `name` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L59
/// r186: `type` https://github.com/mrdoob/three.js/blob/r186/src/materials/PointsMaterial.js#L53
pub(all) struct PointsMaterial {
  color : @math.Color
  mut side : @constants.Side
  mut shadow_side : @constants.Side?
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
  mut force_single_pass : Bool
  mut vertex_colors : Bool
  mut tone_mapped : Bool
  mut alpha_hash : Bool
  mut alpha_to_coverage : Bool
  mut dithering : Bool
  mut polygon_offset : Bool
  mut polygon_offset_factor : Double
  mut polygon_offset_units : Double
  mut clip_shadows : Bool
  mut clip_intersection : Bool
  mut allow_override : Bool
  mut blend_alpha : Double
  blend_color : @math.Color
  mut blending : @constants.Blending
  mut blend_src : @constants.BlendFactor
  mut blend_dst : @constants.BlendFactor
  mut blend_equation : @constants.BlendEquation
  mut blend_src_alpha : @constants.BlendFactor?
  mut blend_dst_alpha : @constants.BlendFactor?
  mut blend_equation_alpha : @constants.BlendEquation?
  mut stencil_write_mask : Int
  mut stencil_func : @constants.StencilFunc
  mut stencil_ref : Int
  mut stencil_func_mask : Int
  mut stencil_fail : @constants.StencilOp
  mut stencil_z_fail : @constants.StencilOp
  mut stencil_z_pass : @constants.StencilOp
  mut stencil_write : Bool
  mut clipping_planes : Array[@math.Plane]?
  mut precision : @constants.Precision?
  mut user_data : Map[String, String]
  mut version : Int
  id : Int
  mut uuid : String
  mut name : String
  type_name : String
  listeners : Map[String, Array[() -> Unit]]
}

///|
pub fn PointsMaterial::new(
  hex? : Int = 0xFFFFFF,
  size? : Double = 1.0,
  size_attenuation? : Bool = true,
) -> PointsMaterial {
  {
    color: @math.Color::new().set_hex(hex),
    side: @constants.Front,
    shadow_side: None,
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
    force_single_pass: false,
    vertex_colors: false,
    tone_mapped: true,
    alpha_hash: false,
    alpha_to_coverage: false,
    dithering: false,
    polygon_offset: false,
    polygon_offset_factor: 0.0,
    polygon_offset_units: 0.0,
    clip_shadows: false,
    clip_intersection: false,
    allow_override: true,
    blend_alpha: 0.0,
    blend_color: @math.Color::new(r=0.0, g=0.0, b=0.0),
    blending: @constants.Normal,
    blend_src: @constants.SrcAlpha,
    blend_dst: @constants.OneMinusSrcAlpha,
    blend_equation: @constants.Add,
    blend_src_alpha: None,
    blend_dst_alpha: None,
    blend_equation_alpha: None,
    stencil_write_mask: 0xFF,
    stencil_func: @constants.StencilFunc::Always,
    stencil_ref: 0,
    stencil_func_mask: 0xFF,
    stencil_fail: @constants.StencilOp::Keep,
    stencil_z_fail: @constants.StencilOp::Keep,
    stencil_z_pass: @constants.StencilOp::Keep,
    stencil_write: false,
    clipping_planes: None,
    precision: None,
    user_data: Map([]),
    version: 0,
    id: fresh_material_id(),
    uuid: @math.generate_uuid(),
    name: "",
    type_name: "PointsMaterial",
    listeners: Map([]),
  }
}

///|
/// 把颜色和常量混合色写进目标自己的颜色对象。颜色贴图和透明贴图沿用源对象。
/// `name`、`side`、`shadow_side`、尺寸、尺寸衰减、不透明度、`alpha_test`、透明开关、雾、深度、颜色写入、预乘、可见性、`force_single_pass`、顶点色、色调映射、`alpha_hash`、`alpha_to_coverage`、`dithering`、多边形偏移、`clip_shadows`、`clip_intersection`、`allow_override`、`blend_alpha`、`blending`、`blend_src`、`blend_dst`、`blend_equation`、`blend_src_alpha`、`blend_dst_alpha`、`blend_equation_alpha`、`stencil_write_mask`、`stencil_func`、`stencil_ref`、`stencil_func_mask`、`stencil_fail`、`stencil_z_fail`、`stencil_z_pass`、`stencil_write`、`clipping_planes`、`precision` 和 `user_data` 一并复制。`user_data` 复制成一张新表。`alpha_test` 经 `set_alpha_test` 写入，穿过 `0` 时目标的 `version` 加一。`listeners` 留在目标上。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/materials/PointsMaterial.js#L125
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1119
pub fn PointsMaterial::copy(
  self : PointsMaterial,
  source : PointsMaterial,
) -> PointsMaterial {
  self.name = source.name
  self.side = source.side
  self.shadow_side = source.shadow_side
  ignore(self.color.copy(source.color))
  ignore(self.blend_color.copy(source.blend_color))
  self.blending = source.blending
  self.blend_src = source.blend_src
  self.blend_dst = source.blend_dst
  self.blend_equation = source.blend_equation
  self.blend_src_alpha = source.blend_src_alpha
  self.blend_dst_alpha = source.blend_dst_alpha
  self.blend_equation_alpha = source.blend_equation_alpha
  self.stencil_write_mask = source.stencil_write_mask
  self.stencil_func = source.stencil_func
  self.stencil_ref = source.stencil_ref
  self.stencil_func_mask = source.stencil_func_mask
  self.stencil_fail = source.stencil_fail
  self.stencil_z_fail = source.stencil_z_fail
  self.stencil_z_pass = source.stencil_z_pass
  self.stencil_write = source.stencil_write
  self.clipping_planes = source.clipping_planes
  self.precision = source.precision
  let copied : Map[String, String] = Map([])
  for pair in source.user_data.iter() {
    let (key, value) = pair
    copied.set(key, value)
  }
  self.user_data = copied
  self.map = source.map
  self.alpha_map = source.alpha_map
  self.size = source.size
  self.size_attenuation = source.size_attenuation
  self.opacity = source.opacity
  self.set_alpha_test(source.alpha_test)
  self.transparent = source.transparent
  self.fog = source.fog
  self.depth_write = source.depth_write
  self.depth_test = source.depth_test
  self.depth_func = source.depth_func
  self.color_write = source.color_write
  self.premultiplied_alpha = source.premultiplied_alpha
  self.visible = source.visible
  self.force_single_pass = source.force_single_pass
  self.vertex_colors = source.vertex_colors
  self.tone_mapped = source.tone_mapped
  self.alpha_hash = source.alpha_hash
  self.alpha_to_coverage = source.alpha_to_coverage
  self.dithering = source.dithering
  self.polygon_offset = source.polygon_offset
  self.polygon_offset_factor = source.polygon_offset_factor
  self.polygon_offset_units = source.polygon_offset_units
  self.clip_shadows = source.clip_shadows
  self.clip_intersection = source.clip_intersection
  self.allow_override = source.allow_override
  self.blend_alpha = source.blend_alpha
  self
}

///|
/// 没有单独的 `PointsMaterial.clone`。按 `Material.clone` 新建一份点材质，再 `copy`。新材质有自己的 `id` 和 `uuid`，`type_name` 仍是 `PointsMaterial`。`alpha_test` 穿过 `0` 时新材质的 `version` 从 `0` 加一。点绘制仍不读这份克隆。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1107
pub fn PointsMaterial::clone(self : PointsMaterial) -> PointsMaterial {
  PointsMaterial::new().copy(self)
}

///|
/// 登记一个监听。同一种事件里，同一个函数只保留一次。点绘制仍不读这张表。
/// r186: `addEventListener` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L31
pub fn PointsMaterial::add_event_listener(
  self : PointsMaterial,
  kind : String,
  listener : () -> Unit,
) -> Unit {
  let listeners = self.listeners.get_or_init(kind, fn() { [] })
  let mut found = false
  for existing in listeners {
    if physical_equal(existing, listener) {
      found = true
    }
  }
  if !found {
    listeners.push(listener)
  }
}

///|
/// 同一种事件里是否已经有这个监听。点绘制仍不读这张表。
/// r186: `hasEventListener` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L58
pub fn PointsMaterial::has_event_listener(
  self : PointsMaterial,
  kind : String,
  listener : () -> Unit,
) -> Bool {
  match self.listeners.get(kind) {
    None => false
    Some(listeners) => {
      let mut found = false
      for existing in listeners {
        if physical_equal(existing, listener) {
          found = true
        }
      }
      found
    }
  }
}

///|
/// 从一种事件里移除这个监听。没有登记时不动。点绘制仍不读这张表。
/// r186: `removeEventListener` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L74
pub fn PointsMaterial::remove_event_listener(
  self : PointsMaterial,
  kind : String,
  listener : () -> Unit,
) -> Unit {
  match self.listeners.get(kind) {
    None => ()
    Some(listeners) => {
      let mut index = None
      for i in 0..<listeners.length() {
        if physical_equal(listeners[i], listener) {
          index = Some(i)
        }
      }
      match index {
        None => ()
        Some(index) => ignore(listeners.remove(index))
      }
    }
  }
}

///|
/// 按名字通知已经登记的监听。调用期间改列表不会漏掉这一轮快照。点绘制仍不读这张表。
/// r186: `dispatchEvent` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L101
pub fn PointsMaterial::dispatch_event(self : PointsMaterial, kind : String) -> Unit {
  match self.listeners.get(kind) {
    None => ()
    Some(listeners) => {
      let snapshot = listeners.copy()
      for listener in snapshot {
        listener()
      }
    }
  }
}

///|
/// 通知 `dispose` 监听。其它事件不动。点绘制仍不因这次调用释放资源。
/// r186: `dispose` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1207
pub fn PointsMaterial::dispose(self : PointsMaterial) -> Unit {
  self.dispatch_event("dispose")
}

///|
/// 传入 `true` 时把 `version` 加一。传入 `false` 时计数不变。点绘制仍不因这次标记重新编译。
/// r186: `needsUpdate` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1227
pub fn PointsMaterial::set_needs_update(
  self : PointsMaterial,
  value : Bool,
) -> Unit {
  if value {
    self.version = self.version + 1
  }
}

///|
/// 写入 `alpha_test`。新值和旧值是否大于 `0` 发生变化时，把 `version` 加一。
/// r186: `alphaTest` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L495
pub fn PointsMaterial::set_alpha_test(self : PointsMaterial, value : Double) -> Unit {
  if (self.alpha_test > 0.0) != (value > 0.0) {
    self.version = self.version + 1
  }
  self.alpha_test = value
}

///|
/// 线段和折线。WebGPU 的线宽是 1 像素，因此没有 `linewidth`。
/// 颜色贴图默认空。线段着色器仍按材质颜色绘制，不采样这张贴图。
/// `side` 默认正面。背面和双面一并存储。`copy` 沿用源值。线段绘制仍不按这个面剔除。
/// `shadow_side` 默认空。`copy` 沿用源值。线段仍不投射阴影。
/// `force_single_pass` 默认关闭。`copy` 沿用源值。线段绘制仍不按它合并正反面。
/// `alpha_test` 默认 `0`。线段着色器在片元 alpha 小于它时丢弃。`set_alpha_test` 在新值和旧值是否大于 `0` 发生变化时把 `version` 加一。
/// `vertex_colors` 默认关闭。线段着色器仍不读顶点色。
/// `tone_mapped` 默认打开。色调映射仍对每份绘制过的线段生效。
/// `alpha_hash` 默认关闭。线段着色器仍不做哈希透明。
/// `alpha_to_coverage` 默认关闭。线段绘制仍不打开 alpha to coverage。
/// `dithering` 默认关闭。线段着色器仍不对颜色做抖动。
/// `polygon_offset` 默认关闭，`polygon_offset_factor` 和 `polygon_offset_units` 默认 `0`。线段绘制仍不做多边形偏移。
/// `clip_shadows` 默认关闭。线段仍不投射阴影。
/// `clip_intersection` 默认关闭。线段绘制仍没有裁剪平面。
/// `allow_override` 默认打开。线段绘制仍不用场景覆盖材质替换它。
/// `blend_alpha` 默认 `0`。线段绘制的混合仍不用常量 alpha。
/// `blend_color` 默认黑色 `(0, 0, 0)`。线段绘制的混合仍不用常量颜色。
/// `blending` 默认 `Normal`。线段绘制的透明混合仍用现有的源 alpha，管线仍不读这个字段。
/// `blend_src` 默认 `SrcAlpha`。线段绘制的透明混合仍用现有的源 alpha，管线仍不读这个字段。
/// `blend_dst` 默认 `OneMinusSrcAlpha`。线段绘制的透明混合仍用现有的源 alpha，管线仍不读这个字段。
/// `blend_equation` 默认 `Add`。线段绘制的透明混合仍用现有的源 alpha，管线仍不读这个字段。
/// `blend_src_alpha` 默认空。空着时 alpha 通道沿用 `blend_src`。管线仍不读这个字段。
/// `blend_dst_alpha` 默认空。空着时 alpha 通道沿用 `blend_dst`。管线仍不读这个字段。
/// `blend_equation_alpha` 默认空。空着时 alpha 通道沿用 `blend_equation`。管线仍不读这个字段。
/// `stencil_write_mask` 默认 `0xFF`。管线仍不读这个字段。
/// `stencil_func` 默认 `Always`。管线仍不读这个字段。
/// `stencil_ref` 默认 `0`。管线仍不读这个字段。
/// `stencil_func_mask` 默认 `0xFF`。管线仍不读这个字段。
/// `stencil_fail` 默认 `Keep`。比较失败时的模板操作。管线仍不读这个字段。
/// `stencil_z_fail` 默认 `Keep`。比较通过但深度测试失败时的模板操作。管线仍不读这个字段。
/// `stencil_z_pass` 默认 `Keep`。比较通过且深度测试通过时的模板操作。管线仍不读这个字段。
/// `stencil_write` 默认关闭。打开后才对模板缓冲做写入和比较。管线仍不读这个字段。
/// `clipping_planes` 默认空。世界空间平面，有符号距离为负的点会被裁掉。线段绘制仍不按这些平面裁剪。
/// `precision` 默认空。空着时沿用渲染器默认精度。管线仍不读这个字段。
/// `user_data` 默认空表。自定义字符串键值。线段绘制仍不读这张表。
/// `version` 默认 `0`。记录这份材质被标记为需要重新编译的次数。`set_needs_update(true)` 把它加一，`false` 不改计数。`copy` 不改目标上的这个计数。线段绘制仍不读它。
/// `id` 与网格材质共用从 `0` 起的计数。每新建一份线材质取下一个编号。`copy` 不改目标上的这个编号。线段绘制仍不读它。
/// `uuid` 在新建时生成，长度 36，版本位是 4。`copy` 不改目标上的这个字符串。线段绘制仍不读它。
/// `name` 默认空字符串。`copy` 把名字写进目标。线段绘制仍不读它。
/// `type_name` 对应上游 `type`，固定是 `LineBasicMaterial`。`copy` 不改目标上的这个名字。线段绘制仍不读它。
/// `listeners` 默认空表。同一种事件里，同一个函数只保留一次。`copy` 不改目标上的这张表。线段绘制仍不读它。
/// r186: `LineBasicMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineBasicMaterial.js#L15
/// r186: `side` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L88
/// r186: `shadowSide` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L342
/// r186: `forceSinglePass` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L431
/// r186: `map` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineBasicMaterial.js#L60
/// r186: `alphaTest` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L489
/// r186: `vertexColors` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L99
/// r186: `toneMapped` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L458
/// r186: `alphaHash` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L135
/// r186: `alphaToCoverage` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L409
/// r186: `dithering` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L399
/// r186: `polygonOffset` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L375
/// r186: `polygonOffsetFactor` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L383
/// r186: `polygonOffsetUnits` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L391
/// r186: `clipShadows` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L329
/// r186: `clipIntersection` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L320
/// r186: `allowOverride` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L439
/// r186: `blendAlpha` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L203
/// r186: `blendColor` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L193
/// r186: `blending` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L80
/// r186: `blendSrc` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L143
/// r186: `blendDst` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L151
/// r186: `blendEquation` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L159
/// r186: `blendSrcAlpha` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L167
/// r186: `blendDstAlpha` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L175
/// r186: `blendEquationAlpha` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L183
/// r186: `stencilWriteMask` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L239
/// r186: `stencilFunc` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L247
/// r186: `stencilRef` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L255
/// r186: `stencilFuncMask` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L263
/// r186: `stencilFail` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L271
/// r186: `stencilZFail` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L280
/// r186: `stencilZPass` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L289
/// r186: `stencilWrite` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L299
/// r186: `clippingPlanes` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L311
/// r186: `precision` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L361
/// r186: `userData` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L466
/// r186: `version` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L475
/// r186: `id` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L44
/// r186: `uuid` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L52
/// r186: `name` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L59
/// r186: `type` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineBasicMaterial.js#L39
pub(all) struct LineBasicMaterial {
  color : @math.Color
  mut side : @constants.Side
  mut shadow_side : @constants.Side?
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
  mut force_single_pass : Bool
  mut vertex_colors : Bool
  mut tone_mapped : Bool
  mut alpha_hash : Bool
  mut alpha_to_coverage : Bool
  mut dithering : Bool
  mut polygon_offset : Bool
  mut polygon_offset_factor : Double
  mut polygon_offset_units : Double
  mut clip_shadows : Bool
  mut clip_intersection : Bool
  mut allow_override : Bool
  mut blend_alpha : Double
  blend_color : @math.Color
  mut blending : @constants.Blending
  mut blend_src : @constants.BlendFactor
  mut blend_dst : @constants.BlendFactor
  mut blend_equation : @constants.BlendEquation
  mut blend_src_alpha : @constants.BlendFactor?
  mut blend_dst_alpha : @constants.BlendFactor?
  mut blend_equation_alpha : @constants.BlendEquation?
  mut stencil_write_mask : Int
  mut stencil_func : @constants.StencilFunc
  mut stencil_ref : Int
  mut stencil_func_mask : Int
  mut stencil_fail : @constants.StencilOp
  mut stencil_z_fail : @constants.StencilOp
  mut stencil_z_pass : @constants.StencilOp
  mut stencil_write : Bool
  mut clipping_planes : Array[@math.Plane]?
  mut precision : @constants.Precision?
  mut user_data : Map[String, String]
  mut version : Int
  id : Int
  mut uuid : String
  mut name : String
  type_name : String
  listeners : Map[String, Array[() -> Unit]]
}

///|
pub fn LineBasicMaterial::new(hex? : Int = 0xFFFFFF) -> LineBasicMaterial {
  {
    color: @math.Color::new().set_hex(hex),
    side: @constants.Front,
    shadow_side: None,
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
    force_single_pass: false,
    vertex_colors: false,
    tone_mapped: true,
    alpha_hash: false,
    alpha_to_coverage: false,
    dithering: false,
    polygon_offset: false,
    polygon_offset_factor: 0.0,
    polygon_offset_units: 0.0,
    clip_shadows: false,
    clip_intersection: false,
    allow_override: true,
    blend_alpha: 0.0,
    blend_color: @math.Color::new(r=0.0, g=0.0, b=0.0),
    blending: @constants.Normal,
    blend_src: @constants.SrcAlpha,
    blend_dst: @constants.OneMinusSrcAlpha,
    blend_equation: @constants.Add,
    blend_src_alpha: None,
    blend_dst_alpha: None,
    blend_equation_alpha: None,
    stencil_write_mask: 0xFF,
    stencil_func: @constants.StencilFunc::Always,
    stencil_ref: 0,
    stencil_func_mask: 0xFF,
    stencil_fail: @constants.StencilOp::Keep,
    stencil_z_fail: @constants.StencilOp::Keep,
    stencil_z_pass: @constants.StencilOp::Keep,
    stencil_write: false,
    clipping_planes: None,
    precision: None,
    user_data: Map([]),
    version: 0,
    id: fresh_material_id(),
    uuid: @math.generate_uuid(),
    name: "",
    type_name: "LineBasicMaterial",
    listeners: Map([]),
  }
}

///|
/// 把颜色和常量混合色写进目标自己的颜色对象。颜色贴图沿用源对象。
/// `name`、`side`、`shadow_side`、`force_single_pass`、不透明度、`alpha_test`、透明开关、雾、深度、颜色写入、预乘、可见性、顶点色、色调映射、`alpha_hash`、`alpha_to_coverage`、`dithering`、多边形偏移、`clip_shadows`、`clip_intersection`、`allow_override`、`blend_alpha`、`blending`、`blend_src`、`blend_dst`、`blend_equation`、`blend_src_alpha`、`blend_dst_alpha`、`blend_equation_alpha`、`stencil_write_mask`、`stencil_func`、`stencil_ref`、`stencil_func_mask`、`stencil_fail`、`stencil_z_fail`、`stencil_z_pass`、`stencil_write`、`clipping_planes`、`precision` 和 `user_data` 一并复制。`user_data` 复制成一张新表。`alpha_test` 经 `set_alpha_test` 写入，穿过 `0` 时目标的 `version` 加一。`listeners` 留在目标上。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineBasicMaterial.js#L106
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1119
pub fn LineBasicMaterial::copy(
  self : LineBasicMaterial,
  source : LineBasicMaterial,
) -> LineBasicMaterial {
  self.name = source.name
  self.side = source.side
  self.shadow_side = source.shadow_side
  ignore(self.color.copy(source.color))
  ignore(self.blend_color.copy(source.blend_color))
  self.blending = source.blending
  self.blend_src = source.blend_src
  self.blend_dst = source.blend_dst
  self.blend_equation = source.blend_equation
  self.blend_src_alpha = source.blend_src_alpha
  self.blend_dst_alpha = source.blend_dst_alpha
  self.blend_equation_alpha = source.blend_equation_alpha
  self.stencil_write_mask = source.stencil_write_mask
  self.stencil_func = source.stencil_func
  self.stencil_ref = source.stencil_ref
  self.stencil_func_mask = source.stencil_func_mask
  self.stencil_fail = source.stencil_fail
  self.stencil_z_fail = source.stencil_z_fail
  self.stencil_z_pass = source.stencil_z_pass
  self.stencil_write = source.stencil_write
  self.clipping_planes = source.clipping_planes
  self.precision = source.precision
  let copied : Map[String, String] = Map([])
  for pair in source.user_data.iter() {
    let (key, value) = pair
    copied.set(key, value)
  }
  self.user_data = copied
  self.map = source.map
  self.opacity = source.opacity
  self.set_alpha_test(source.alpha_test)
  self.transparent = source.transparent
  self.fog = source.fog
  self.depth_write = source.depth_write
  self.depth_test = source.depth_test
  self.depth_func = source.depth_func
  self.color_write = source.color_write
  self.premultiplied_alpha = source.premultiplied_alpha
  self.visible = source.visible
  self.force_single_pass = source.force_single_pass
  self.vertex_colors = source.vertex_colors
  self.tone_mapped = source.tone_mapped
  self.alpha_hash = source.alpha_hash
  self.alpha_to_coverage = source.alpha_to_coverage
  self.dithering = source.dithering
  self.polygon_offset = source.polygon_offset
  self.polygon_offset_factor = source.polygon_offset_factor
  self.polygon_offset_units = source.polygon_offset_units
  self.clip_shadows = source.clip_shadows
  self.clip_intersection = source.clip_intersection
  self.allow_override = source.allow_override
  self.blend_alpha = source.blend_alpha
  self
}

///|
/// 没有单独的 `LineBasicMaterial.clone`。按 `Material.clone` 新建一份线材质，再 `copy`。新材质有自己的 `id` 和 `uuid`，`type_name` 仍是 `LineBasicMaterial`。`alpha_test` 穿过 `0` 时新材质的 `version` 从 `0` 加一。线段绘制仍不读这份克隆。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1107
pub fn LineBasicMaterial::clone(self : LineBasicMaterial) -> LineBasicMaterial {
  LineBasicMaterial::new().copy(self)
}

///|
/// 登记一个监听。同一种事件里，同一个函数只保留一次。线段绘制仍不读这张表。
/// r186: `addEventListener` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L31
pub fn LineBasicMaterial::add_event_listener(
  self : LineBasicMaterial,
  kind : String,
  listener : () -> Unit,
) -> Unit {
  let listeners = self.listeners.get_or_init(kind, fn() { [] })
  let mut found = false
  for existing in listeners {
    if physical_equal(existing, listener) {
      found = true
    }
  }
  if !found {
    listeners.push(listener)
  }
}

///|
/// 同一种事件里是否已经有这个监听。线段绘制仍不读这张表。
/// r186: `hasEventListener` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L58
pub fn LineBasicMaterial::has_event_listener(
  self : LineBasicMaterial,
  kind : String,
  listener : () -> Unit,
) -> Bool {
  match self.listeners.get(kind) {
    None => false
    Some(listeners) => {
      let mut found = false
      for existing in listeners {
        if physical_equal(existing, listener) {
          found = true
        }
      }
      found
    }
  }
}

///|
/// 从一种事件里移除这个监听。没有登记时不动。线段绘制仍不读这张表。
/// r186: `removeEventListener` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L74
pub fn LineBasicMaterial::remove_event_listener(
  self : LineBasicMaterial,
  kind : String,
  listener : () -> Unit,
) -> Unit {
  match self.listeners.get(kind) {
    None => ()
    Some(listeners) => {
      let mut index = None
      for i in 0..<listeners.length() {
        if physical_equal(listeners[i], listener) {
          index = Some(i)
        }
      }
      match index {
        None => ()
        Some(index) => ignore(listeners.remove(index))
      }
    }
  }
}

///|
/// 按名字通知已经登记的监听。调用期间改列表不会漏掉这一轮快照。线段绘制仍不读这张表。
/// r186: `dispatchEvent` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L101
pub fn LineBasicMaterial::dispatch_event(
  self : LineBasicMaterial,
  kind : String,
) -> Unit {
  match self.listeners.get(kind) {
    None => ()
    Some(listeners) => {
      let snapshot = listeners.copy()
      for listener in snapshot {
        listener()
      }
    }
  }
}

///|
/// 通知 `dispose` 监听。其它事件不动。线段绘制仍不因这次调用释放资源。
/// r186: `dispose` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1207
pub fn LineBasicMaterial::dispose(self : LineBasicMaterial) -> Unit {
  self.dispatch_event("dispose")
}

///|
/// 传入 `true` 时把 `version` 加一。传入 `false` 时计数不变。线段绘制仍不因这次标记重新编译。
/// r186: `needsUpdate` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1227
pub fn LineBasicMaterial::set_needs_update(
  self : LineBasicMaterial,
  value : Bool,
) -> Unit {
  if value {
    self.version = self.version + 1
  }
}

///|
/// 写入 `alpha_test`。新值和旧值是否大于 `0` 发生变化时，把 `version` 加一。
/// r186: `alphaTest` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L495
pub fn LineBasicMaterial::set_alpha_test(
  self : LineBasicMaterial,
  value : Double,
) -> Unit {
  if (self.alpha_test > 0.0) != (value > 0.0) {
    self.version = self.version + 1
  }
  self.alpha_test = value
}

///|
/// 虚线材质。线段字段放在内嵌的 `line` 上。
/// `scale` 默认 `1`，`dash_size` 默认 `3`，`gap_size` 默认 `1`。
/// `type_name` 对应上游 `type`，固定是 `LineDashedMaterial`。`copy` 不改目标上的这个名字。内嵌线段仍是 `LineBasicMaterial`。线段绘制仍不读这个名字。
/// 折线仍使用 `LineBasicMaterial`。着色器仍画实线。
/// r186: `LineDashedMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineDashedMaterial.js#L19
/// r186: `type` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineDashedMaterial.js#L42
/// r186: `scale` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineDashedMaterial.js#L50
/// r186: `dashSize` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineDashedMaterial.js#L58
/// r186: `gapSize` https://github.com/mrdoob/three.js/blob/r186/src/materials/LineDashedMaterial.js#L66
pub(all) struct LineDashedMaterial {
  line : LineBasicMaterial
  mut scale : Double
  mut dash_size : Double
  mut gap_size : Double
  type_name : String
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
    type_name: "LineDashedMaterial",
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
/// 没有单独的 `LineDashedMaterial.clone`。按 `Material.clone` 新建一份虚线材质，再 `copy`。新材质的 `type_name` 仍是 `LineDashedMaterial`，内嵌线段是新的 `LineBasicMaterial`，有自己的 `id` 和 `uuid`。`alpha_test` 穿过 `0` 时内嵌线段的 `version` 从 `0` 加一。线段绘制仍不读这份克隆。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1107
pub fn LineDashedMaterial::clone(self : LineDashedMaterial) -> LineDashedMaterial {
  LineDashedMaterial::new().copy(self)
}

///|
/// 没有单独的 `LineDashedMaterial.dispose`。通知内嵌线段上的 `dispose` 监听。其它事件不动。线段绘制仍不因这次调用释放资源。
/// r186: `dispose` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1207
pub fn LineDashedMaterial::dispose(self : LineDashedMaterial) -> Unit {
  self.line.dispose()
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
/// `side` 默认正面。背面和双面一并存储。`copy` 沿用源值。渲染器仍不画精灵。
/// `shadow_side` 默认空。`copy` 沿用源值。渲染器仍不画精灵。
/// `force_single_pass` 默认关闭。`copy` 沿用源值。渲染器仍不画精灵。
/// 深度写入和深度测试默认打开，深度函数是 `LessEqual`。颜色写入默认打开，预乘默认关闭，可见性默认打开。
/// `alpha_test` 默认 `0`。`set_alpha_test` 在新值和旧值是否大于 `0` 发生变化时把 `version` 加一。`vertex_colors` 默认关闭。`tone_mapped` 默认打开。`alpha_hash` 默认关闭。`alpha_to_coverage` 默认关闭。`dithering` 默认关闭。`polygon_offset` 默认关闭，系数和单位默认 `0`。`clip_shadows` 默认关闭。`clip_intersection` 默认关闭。`allow_override` 默认打开。`blend_alpha` 默认 `0`。`blend_color` 默认黑色 `(0, 0, 0)`。`blending` 默认 `Normal`。`blend_src` 默认 `SrcAlpha`。`blend_dst` 默认 `OneMinusSrcAlpha`。`blend_equation` 默认 `Add`。`blend_src_alpha` 默认空。`blend_dst_alpha` 默认空。`blend_equation_alpha` 默认空。`stencil_write_mask` 默认 `0xFF`。`stencil_func` 默认 `Always`。`stencil_ref` 默认 `0`。`stencil_func_mask` 默认 `0xFF`。`stencil_fail` 默认 `Keep`。比较失败时的模板操作。`stencil_z_fail` 默认 `Keep`。比较通过但深度测试失败时的模板操作。`stencil_z_pass` 默认 `Keep`。比较通过且深度测试通过时的模板操作。`stencil_write` 默认关闭。打开后才对模板缓冲做写入和比较。`clipping_planes` 默认空。世界空间平面，有符号距离为负的点会被裁掉。`precision` 默认空。空着时沿用渲染器默认精度。`user_data` 默认空表。自定义字符串键值。`version` 默认 `0`。记录这份材质被标记为需要重新编译的次数。`set_needs_update(true)` 把它加一，`false` 不改计数。`copy` 不改目标上的这个计数。`id` 与网格材质共用从 `0` 起的计数。每新建一份精灵材质取下一个编号。`copy` 不改目标上的这个编号。`uuid` 在新建时生成，长度 36，版本位是 4。`copy` 不改目标上的这个字符串。`name` 默认空字符串。`copy` 把名字写进目标。`type_name` 对应上游 `type`，固定是 `SpriteMaterial`。`copy` 不改目标上的这个名字。`listeners` 默认空表。同一种事件里，同一个函数只保留一次。`copy` 不改目标上的这张表。渲染器仍不画精灵。混合仍不用常量颜色，管线仍不读 `blending`、`blend_src`、`blend_dst`、`blend_equation`、`blend_src_alpha`、`blend_dst_alpha`、`blend_equation_alpha`、`stencil_write_mask`、`stencil_func`、`stencil_ref`、`stencil_func_mask`、`stencil_fail`、`stencil_z_fail`、`stencil_z_pass`、`stencil_write`、`clipping_planes`、`precision` 和 `user_data`。空着时 alpha 通道分别沿用 `blend_src`、`blend_dst` 与 `blend_equation`。
/// r186: `SpriteMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/SpriteMaterial.js#L18
/// r186: `side` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L88
/// r186: `shadowSide` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L342
/// r186: `forceSinglePass` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L431
/// r186: `vertexColors` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L99
/// r186: `toneMapped` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L458
/// r186: `alphaHash` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L135
/// r186: `alphaToCoverage` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L409
/// r186: `dithering` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L399
/// r186: `polygonOffset` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L375
/// r186: `polygonOffsetFactor` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L383
/// r186: `polygonOffsetUnits` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L391
/// r186: `clipShadows` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L329
/// r186: `clipIntersection` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L320
/// r186: `allowOverride` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L439
/// r186: `blendAlpha` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L203
/// r186: `blendColor` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L193
/// r186: `blending` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L80
/// r186: `blendSrc` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L143
/// r186: `blendDst` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L151
/// r186: `blendEquation` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L159
/// r186: `blendSrcAlpha` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L167
/// r186: `blendDstAlpha` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L175
/// r186: `blendEquationAlpha` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L183
/// r186: `stencilWriteMask` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L239
/// r186: `stencilFunc` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L247
/// r186: `stencilRef` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L255
/// r186: `stencilFuncMask` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L263
/// r186: `stencilFail` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L271
/// r186: `stencilZFail` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L280
/// r186: `stencilZPass` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L289
/// r186: `stencilWrite` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L299
/// r186: `clippingPlanes` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L311
/// r186: `precision` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L361
/// r186: `userData` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L466
/// r186: `version` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L475
/// r186: `id` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L44
/// r186: `uuid` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L52
/// r186: `name` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L59
/// r186: `type` https://github.com/mrdoob/three.js/blob/r186/src/materials/SpriteMaterial.js#L42
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
  mut side : @constants.Side
  mut shadow_side : @constants.Side?
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
  mut force_single_pass : Bool
  mut vertex_colors : Bool
  mut tone_mapped : Bool
  mut alpha_hash : Bool
  mut alpha_to_coverage : Bool
  mut dithering : Bool
  mut polygon_offset : Bool
  mut polygon_offset_factor : Double
  mut polygon_offset_units : Double
  mut clip_shadows : Bool
  mut clip_intersection : Bool
  mut allow_override : Bool
  mut blend_alpha : Double
  blend_color : @math.Color
  mut blending : @constants.Blending
  mut blend_src : @constants.BlendFactor
  mut blend_dst : @constants.BlendFactor
  mut blend_equation : @constants.BlendEquation
  mut blend_src_alpha : @constants.BlendFactor?
  mut blend_dst_alpha : @constants.BlendFactor?
  mut blend_equation_alpha : @constants.BlendEquation?
  mut stencil_write_mask : Int
  mut stencil_func : @constants.StencilFunc
  mut stencil_ref : Int
  mut stencil_func_mask : Int
  mut stencil_fail : @constants.StencilOp
  mut stencil_z_fail : @constants.StencilOp
  mut stencil_z_pass : @constants.StencilOp
  mut stencil_write : Bool
  mut clipping_planes : Array[@math.Plane]?
  mut precision : @constants.Precision?
  mut user_data : Map[String, String]
  mut version : Int
  id : Int
  mut uuid : String
  mut name : String
  type_name : String
  listeners : Map[String, Array[() -> Unit]]
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
    side: @constants.Front,
    shadow_side: None,
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
    force_single_pass: false,
    vertex_colors: false,
    tone_mapped: true,
    alpha_hash: false,
    alpha_to_coverage: false,
    dithering: false,
    polygon_offset: false,
    polygon_offset_factor: 0.0,
    polygon_offset_units: 0.0,
    clip_shadows: false,
    clip_intersection: false,
    allow_override: true,
    blend_alpha: 0.0,
    blend_color: @math.Color::new(r=0.0, g=0.0, b=0.0),
    blending: @constants.Normal,
    blend_src: @constants.SrcAlpha,
    blend_dst: @constants.OneMinusSrcAlpha,
    blend_equation: @constants.Add,
    blend_src_alpha: None,
    blend_dst_alpha: None,
    blend_equation_alpha: None,
    stencil_write_mask: 0xFF,
    stencil_func: @constants.StencilFunc::Always,
    stencil_ref: 0,
    stencil_func_mask: 0xFF,
    stencil_fail: @constants.StencilOp::Keep,
    stencil_z_fail: @constants.StencilOp::Keep,
    stencil_z_pass: @constants.StencilOp::Keep,
    stencil_write: false,
    clipping_planes: None,
    precision: None,
    user_data: Map([]),
    version: 0,
    id: fresh_material_id(),
    uuid: @math.generate_uuid(),
    name: "",
    type_name: "SpriteMaterial",
    listeners: Map([]),
  }
}

///|
/// 把颜色和常量混合色写进目标自己的颜色对象。贴图和透明贴图沿用源对象。
/// `name`、`side`、`shadow_side`、不透明度、`alpha_test`、透明开关、雾、旋转、尺寸衰减、深度、颜色写入、预乘、可见性、`force_single_pass`、顶点色、色调映射、`alpha_hash`、`alpha_to_coverage`、`dithering`、多边形偏移、`clip_shadows`、`clip_intersection`、`allow_override`、`blend_alpha`、`blending`、`blend_src`、`blend_dst`、`blend_equation`、`blend_src_alpha`、`blend_dst_alpha`、`blend_equation_alpha`、`stencil_write_mask`、`stencil_func`、`stencil_ref`、`stencil_func_mask`、`stencil_fail`、`stencil_z_fail`、`stencil_z_pass`、`stencil_write`、`clipping_planes`、`precision` 和 `user_data` 一并复制。`user_data` 复制成一张新表。`alpha_test` 经 `set_alpha_test` 写入，穿过 `0` 时目标的 `version` 加一。`listeners` 留在目标上。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/materials/SpriteMaterial.js#L121
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1119
pub fn SpriteMaterial::copy(
  self : SpriteMaterial,
  source : SpriteMaterial,
) -> SpriteMaterial {
  self.name = source.name
  self.side = source.side
  self.shadow_side = source.shadow_side
  ignore(self.color.copy(source.color))
  ignore(self.blend_color.copy(source.blend_color))
  self.blending = source.blending
  self.blend_src = source.blend_src
  self.blend_dst = source.blend_dst
  self.blend_equation = source.blend_equation
  self.blend_src_alpha = source.blend_src_alpha
  self.blend_dst_alpha = source.blend_dst_alpha
  self.blend_equation_alpha = source.blend_equation_alpha
  self.stencil_write_mask = source.stencil_write_mask
  self.stencil_func = source.stencil_func
  self.stencil_ref = source.stencil_ref
  self.stencil_func_mask = source.stencil_func_mask
  self.stencil_fail = source.stencil_fail
  self.stencil_z_fail = source.stencil_z_fail
  self.stencil_z_pass = source.stencil_z_pass
  self.stencil_write = source.stencil_write
  self.clipping_planes = source.clipping_planes
  self.precision = source.precision
  let copied : Map[String, String] = Map([])
  for pair in source.user_data.iter() {
    let (key, value) = pair
    copied.set(key, value)
  }
  self.user_data = copied
  self.map = source.map
  self.alpha_map = source.alpha_map
  self.opacity = source.opacity
  self.set_alpha_test(source.alpha_test)
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
  self.force_single_pass = source.force_single_pass
  self.vertex_colors = source.vertex_colors
  self.tone_mapped = source.tone_mapped
  self.alpha_hash = source.alpha_hash
  self.alpha_to_coverage = source.alpha_to_coverage
  self.dithering = source.dithering
  self.polygon_offset = source.polygon_offset
  self.polygon_offset_factor = source.polygon_offset_factor
  self.polygon_offset_units = source.polygon_offset_units
  self.clip_shadows = source.clip_shadows
  self.clip_intersection = source.clip_intersection
  self.allow_override = source.allow_override
  self.blend_alpha = source.blend_alpha
  self
}

///|
/// 没有单独的 `SpriteMaterial.clone`。按 `Material.clone` 新建一份精灵材质，再 `copy`。新材质有自己的 `id` 和 `uuid`，`type_name` 仍是 `SpriteMaterial`。`alpha_test` 穿过 `0` 时新材质的 `version` 从 `0` 加一。渲染器仍不画精灵。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1107
pub fn SpriteMaterial::clone(self : SpriteMaterial) -> SpriteMaterial {
  SpriteMaterial::new().copy(self)
}

///|
/// 登记一个监听。同一种事件里，同一个函数只保留一次。渲染器仍不画精灵。
/// r186: `addEventListener` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L31
pub fn SpriteMaterial::add_event_listener(
  self : SpriteMaterial,
  kind : String,
  listener : () -> Unit,
) -> Unit {
  let listeners = self.listeners.get_or_init(kind, fn() { [] })
  let mut found = false
  for existing in listeners {
    if physical_equal(existing, listener) {
      found = true
    }
  }
  if !found {
    listeners.push(listener)
  }
}

///|
/// 同一种事件里是否已经有这个监听。渲染器仍不画精灵。
/// r186: `hasEventListener` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L58
pub fn SpriteMaterial::has_event_listener(
  self : SpriteMaterial,
  kind : String,
  listener : () -> Unit,
) -> Bool {
  match self.listeners.get(kind) {
    None => false
    Some(listeners) => {
      let mut found = false
      for existing in listeners {
        if physical_equal(existing, listener) {
          found = true
        }
      }
      found
    }
  }
}

///|
/// 从一种事件里移除这个监听。没有登记时不动。渲染器仍不画精灵。
/// r186: `removeEventListener` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L74
pub fn SpriteMaterial::remove_event_listener(
  self : SpriteMaterial,
  kind : String,
  listener : () -> Unit,
) -> Unit {
  match self.listeners.get(kind) {
    None => ()
    Some(listeners) => {
      let mut index = None
      for i in 0..<listeners.length() {
        if physical_equal(listeners[i], listener) {
          index = Some(i)
        }
      }
      match index {
        None => ()
        Some(index) => ignore(listeners.remove(index))
      }
    }
  }
}

///|
/// 按名字通知已经登记的监听。调用期间改列表不会漏掉这一轮快照。渲染器仍不画精灵。
/// r186: `dispatchEvent` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L101
pub fn SpriteMaterial::dispatch_event(self : SpriteMaterial, kind : String) -> Unit {
  match self.listeners.get(kind) {
    None => ()
    Some(listeners) => {
      let snapshot = listeners.copy()
      for listener in snapshot {
        listener()
      }
    }
  }
}

///|
/// 通知 `dispose` 监听。其它事件不动。渲染器仍不画精灵。
/// r186: `dispose` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1207
pub fn SpriteMaterial::dispose(self : SpriteMaterial) -> Unit {
  self.dispatch_event("dispose")
}

///|
/// 传入 `true` 时把 `version` 加一。传入 `false` 时计数不变。渲染器仍不画精灵。
/// r186: `needsUpdate` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L1227
pub fn SpriteMaterial::set_needs_update(
  self : SpriteMaterial,
  value : Bool,
) -> Unit {
  if value {
    self.version = self.version + 1
  }
}

///|
/// 写入 `alpha_test`。新值和旧值是否大于 `0` 发生变化时，把 `version` 加一。
/// r186: `alphaTest` https://github.com/mrdoob/three.js/blob/r186/src/materials/Material.js#L495
pub fn SpriteMaterial::set_alpha_test(self : SpriteMaterial, value : Double) -> Unit {
  if (self.alpha_test > 0.0) != (value > 0.0) {
    self.version = self.version + 1
  }
  self.alpha_test = value
}
