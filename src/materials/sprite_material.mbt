// r186: `SpriteMaterial` https://github.com/mrdoob/three.js/blob/r186/src/materials/SpriteMaterial.js#L18

///|
/// 程序参数里的尺寸衰减标记。精灵材质默认打开。
/// r186: `sizeAttenuation` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L326
pub fn SpriteMaterial::program_size_attenuation(self : SpriteMaterial) -> Bool {
  self.size_attenuation
}

///|
/// 程序参数里的内置着色器标识。精灵材质是 `sprite`。
/// r186: `shaderIDs` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L28
/// r186: `shaderID` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L191
pub fn SpriteMaterial::program_shader_id(self : SpriteMaterial) -> String? {
  builtin_shader_id(self.type_name)
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
