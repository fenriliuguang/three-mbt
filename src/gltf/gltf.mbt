// r186: `GLTFLoader` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L129

///|
/// glTF JSON 读不下来，或用到了这份子集以外的数据。
pub(all) suberror GltfError {
  Invalid(String)
}

///|
priv struct Bin {
  bytes : Bytes
  limit : Int
}

///|
priv struct View {
  buffer : Int
  offset : Int
  byte_length : Int
  stride : Int
}

///|
priv struct Acc {
  view : Int
  offset : Int
  count : Int
  components : Int
  component_type : Int
  normalized : Bool
}

///|
priv struct Mat {
  r : Double
  g : Double
  b : Double
  roughness : Double
  metalness : Double
  opacity : Double
  transparent : Bool
  double_sided : Bool
  unlit : Bool
}

///|
priv struct MorphTarget {
  position : Array[Double]?
  normal : Array[Double]?
}

///|
priv struct Prim {
  geometry : @core.BufferGeometry
  mat : Mat
  targets : Array[MorphTarget]
  mesh_weights : Array[Double]
  baked : @core.BufferGeometry
}

///|
priv struct NodeDesc {
  name : String
  children : Array[Int]
  mesh : Int?
  tx : Double
  ty : Double
  tz : Double
  rx : Double
  ry : Double
  rz : Double
  rw : Double
  sx : Double
  sy : Double
  sz : Double
  matrix : Array[Double]?
  camera : Int?
  light : Int?
  weights : Array[Double]?
}

///|
priv enum CamKind {
  Perspective
  Orthographic
}

///|
priv struct Cam {
  kind : CamKind
  fov : Double
  aspect : Double
  xmag : Double
  ymag : Double
  znear : Double
  zfar : Double
  name : String
}

///|
/// `parse` 的结果。`scene` 是默认场景，`animations` 是关键帧片段。
/// r186: `parse` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L430
pub(all) struct Gltf {
  scene : @objects.Group
  animations : Array[@animation.AnimationClip]
}

///|
/// 从 glTF 2.0 JSON 读出默认场景。
///
/// 缓冲来自 `data:` URI 的 base64。第 0 个缓冲没有 URI 时，用 `bin` 填上。
/// 只建 `TRIANGLES` 网格：`POSITION`、`NORMAL`、`TEXCOORD_0` 和索引。
/// 材质写成 `MeshStandardMaterial`，`baseColorFactor` 按线性通道写入，
/// 再带上粗糙度、金属度和 `doubleSided`。`KHR_materials_unlit` 改用 `MeshBasicMaterial`。
/// 节点上的相机会建成透视或正交相机。
/// 动画读取 `translation`、`rotation` 和 `scale`。`LINEAR` 与 `STEP` 按线性或离散采样，`CUBICSPLINE` 按切线布局采样。
/// `KHR_lights_punctual` 的平行光会挂到节点上。`mesh.weights` 会把 `POSITION` 形变增量烘焙进顶点，已有法线时也烘焙 `NORMAL`。节点 `weights` 按索引盖过网格权重；和网格权重不同时复制几何再烘焙。点光、聚光、贴图、蒙皮和顶点色形变先不读。动画通道里的 `weights` 仍跳过。
/// r186: `parse` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L430
pub fn parse(text : String, bin? : Bytes = b"") -> Gltf raise GltfError {
  let root = as_object(parse_json(text))
  check_version(root)
  let bins = load_buffers(root, bin)
  let views = load_views(root)
  let accs = load_accessors(root)
  let materials = load_materials(root)
  let meshes = load_meshes(root, bins, views, accs, materials)
  let cameras = load_cameras(root)
  let lights = load_punctuals(root)
  let nodes = load_nodes(root)
  let built = build_nodes(nodes, meshes, cameras, lights)
  link_children(nodes, built)
  let animations = load_animations(root, bins, views, accs, built)
  let group = @objects.Group::new()
  let roots = scene_roots(root, nodes)
  let mut i = 0
  while i < roots.indices.length() {
    let index = roots.indices[i]
    if index < 0 || index >= built.length() {
      raise GltfError::Invalid("scene node index")
    }
    ignore(group.node.add(built[index]))
    i = i + 1
  }
  group.node.name = roots.name
  { scene: group, animations, }
}

///|
priv struct SceneRoots {
  name : String
  indices : Array[Int]
}

///|
fn parse_json(text : String) -> Json raise GltfError {
  @json.parse(text) catch {
    _ => raise GltfError::Invalid("invalid json")
  }
}

///|
fn as_object(value : Json) -> Map[String, Json] raise GltfError {
  @json.from_json(value) catch {
    _ => raise GltfError::Invalid("expected an object")
  }
}

///|
fn as_array(value : Json) -> Array[Json] raise GltfError {
  @json.from_json(value) catch {
    _ => raise GltfError::Invalid("expected an array")
  }
}

///|
fn as_f64(value : Json) -> Double raise GltfError {
  @json.from_json(value) catch {
    _ => raise GltfError::Invalid("expected a number")
  }
}

///|
fn as_string(value : Json) -> String raise GltfError {
  @json.from_json(value) catch {
    _ => raise GltfError::Invalid("expected a string")
  }
}

///|
fn as_bool(value : Json) -> Bool raise GltfError {
  @json.from_json(value) catch {
    _ => raise GltfError::Invalid("expected a bool")
  }
}

///|
fn as_doubles(value : Json) -> Array[Double] raise GltfError {
  @json.from_json(value) catch {
    _ => raise GltfError::Invalid("expected numbers")
  }
}

///|
fn as_ints(value : Json) -> Array[Int] raise GltfError {
  let nums = as_doubles(value)
  let out = []
  let mut i = 0
  while i < nums.length() {
    out.push(nums[i].to_int())
    i = i + 1
  }
  out
}

///|
fn opt_string(
  obj : Map[String, Json],
  key : String,
  fallback : String,
) -> String raise GltfError {
  match obj.get(key) {
    None => fallback
    Some(value) => as_string(value)
  }
}

///|
fn opt_f64(
  obj : Map[String, Json],
  key : String,
  fallback : Double,
) -> Double raise GltfError {
  match obj.get(key) {
    None => fallback
    Some(value) => as_f64(value)
  }
}

///|
fn opt_bool(
  obj : Map[String, Json],
  key : String,
  fallback : Bool,
) -> Bool raise GltfError {
  match obj.get(key) {
    None => fallback
    Some(value) => as_bool(value)
  }
}

///|
fn objects(
  root : Map[String, Json],
  key : String,
) -> Array[Map[String, Json]] raise GltfError {
  match root.get(key) {
    None => []
    Some(value) => {
      let items = as_array(value)
      let out = []
      let mut i = 0
      while i < items.length() {
        out.push(as_object(items[i]))
        i = i + 1
      }
      out
    }
  }
}

///|
fn check_version(root : Map[String, Json]) -> Unit raise GltfError {
  match root.get("asset") {
    None => ()
    Some(asset) => {
      let obj = as_object(asset)
      match obj.get("version") {
        None => ()
        Some(version) =>
          if as_string(version) != "2.0" {
            raise GltfError::Invalid("only glTF 2.0")
          }
      }
    }
  }
}

///|
fn decode_uri(uri : String) -> Bytes raise GltfError {
  match uri.split_once("base64,") {
    None => raise GltfError::Invalid("buffer uri is not a base64 data URI")
    Some((_, payload)) =>
      @base64.decode(payload) catch {
        _ => raise GltfError::Invalid("buffer base64 is malformed")
      }
  }
}

///|
fn load_buffers(
  root : Map[String, Json],
  bin : Bytes,
) -> Array[Bin] raise GltfError {
  let listed = objects(root, "buffers")
  let out = []
  let mut i = 0
  while i < listed.length() {
    let obj = listed[i]
    let raw = match obj.get("uri") {
      Some(uri) => decode_uri(as_string(uri))
      None =>
        if i == 0 && bin.length() > 0 {
          bin
        } else {
          raise GltfError::Invalid("buffer has no data URI")
        }
    }
    let declared = opt_f64(obj, "byteLength", raw.length().to_double()).to_int()
    if declared < 0 || raw.length() < declared {
      raise GltfError::Invalid("buffer is shorter than byteLength")
    }
    out.push({ bytes: raw, limit: declared, })
    i = i + 1
  }
  out
}

///|
fn load_views(root : Map[String, Json]) -> Array[View] raise GltfError {
  let listed = objects(root, "bufferViews")
  let out = []
  let mut i = 0
  while i < listed.length() {
    let obj = listed[i]
    out.push({
      buffer: opt_f64(obj, "buffer", 0.0).to_int(),
      offset: opt_f64(obj, "byteOffset", 0.0).to_int(),
      byte_length: opt_f64(obj, "byteLength", 0.0).to_int(),
      stride: opt_f64(obj, "byteStride", 0.0).to_int(),
    })
    i = i + 1
  }
  out
}

///|
fn component_count(kind : String) -> Int raise GltfError {
  match kind {
    "SCALAR" => 1
    "VEC2" => 2
    "VEC3" => 3
    "VEC4" => 4
    _ => raise GltfError::Invalid("unsupported accessor type")
  }
}

///|
fn load_accessors(root : Map[String, Json]) -> Array[Acc] raise GltfError {
  let listed = objects(root, "accessors")
  let out = []
  let mut i = 0
  while i < listed.length() {
    let obj = listed[i]
    let view = match obj.get("bufferView") {
      None => raise GltfError::Invalid("accessor needs a bufferView")
      Some(value) => as_f64(value).to_int()
    }
    out.push({
      view,
      offset: opt_f64(obj, "byteOffset", 0.0).to_int(),
      count: opt_f64(obj, "count", 0.0).to_int(),
      components: component_count(opt_string(obj, "type", "")),
      component_type: opt_f64(obj, "componentType", 0.0).to_int(),
      normalized: opt_bool(obj, "normalized", false),
    })
    i = i + 1
  }
  out
}

///|
fn component_width(component_type : Int) -> Int raise GltfError {
  match component_type {
    5120 => 1
    5121 => 1
    5122 => 2
    5123 => 2
    5125 => 4
    5126 => 4
    _ => raise GltfError::Invalid("unsupported component type")
  }
}

///|
fn default_mat() -> Mat {
  {
    r: 1.0,
    g: 1.0,
    b: 1.0,
    roughness: 1.0,
    metalness: 1.0,
    opacity: 1.0,
    transparent: false,
    double_sided: false,
    unlit: false,
  }
}

///|
fn load_mat(obj : Map[String, Json]) -> Mat raise GltfError {
  let mut r = 1.0
  let mut g = 1.0
  let mut b = 1.0
  let mut alpha = 1.0
  let mut roughness = 1.0
  let mut metalness = 1.0
  match obj.get("pbrMetallicRoughness") {
    None => ()
    Some(value) => {
      let pbr = as_object(value)
      match pbr.get("baseColorFactor") {
        None => ()
        Some(factor) => {
          let nums = as_doubles(factor)
          if nums.length() < 3 {
            raise GltfError::Invalid("baseColorFactor needs RGB")
          }
          r = nums[0]
          g = nums[1]
          b = nums[2]
          if nums.length() >= 4 {
            alpha = nums[3]
          }
        }
      }
      roughness = opt_f64(pbr, "roughnessFactor", 1.0)
      metalness = opt_f64(pbr, "metallicFactor", 1.0)
    }
  }
  let blend = opt_string(obj, "alphaMode", "OPAQUE") == "BLEND"
  let transparent = blend && alpha < 1.0
  let opacity = if transparent { alpha } else { 1.0 }
  {
    r,
    g,
    b,
    roughness,
    metalness,
    opacity,
    transparent,
    double_sided: opt_bool(obj, "doubleSided", false),
    unlit: material_unlit(obj),
  }
}

///|
/// r186: `getMaterialType` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L808
fn material_unlit(obj : Map[String, Json]) -> Bool raise GltfError {
  match extension_block(obj, "KHR_materials_unlit") {
    None => false
    Some(_) => true
  }
}

///|
fn load_materials(root : Map[String, Json]) -> Array[Mat] raise GltfError {
  let listed = objects(root, "materials")
  let out = []
  let mut i = 0
  while i < listed.length() {
    out.push(load_mat(listed[i]))
    i = i + 1
  }
  out
}

///|
fn read_component(
  bin : Bin,
  offset : Int,
  component_type : Int,
) -> Double raise GltfError {
  let width = component_width(component_type)
  if offset < 0 || offset + width > bin.limit {
    raise GltfError::Invalid("accessor reads past the buffer")
  }
  let bytes = bin.bytes
  match component_type {
    5120 => {
      let v = bytes.at(offset).to_int()
      if v > 127 {
        (v - 256).to_double()
      } else {
        v.to_double()
      }
    }
    5121 => bytes.at(offset).to_int().to_double()
    5122 => {
      let v = bytes.at(offset).to_int() + (bytes.at(offset + 1).to_int() << 8)
      if v > 32767 {
        (v - 65536).to_double()
      } else {
        v.to_double()
      }
    }
    5123 =>
      (bytes.at(offset).to_int() + (bytes.at(offset + 1).to_int() << 8)).to_double()
    5125 =>
      bytes.at(offset).to_double() +
      bytes.at(offset + 1).to_double() * 256.0 +
      bytes.at(offset + 2).to_double() * 65536.0 +
      bytes.at(offset + 3).to_double() * 16777216.0
    5126 => {
      let bits = bytes.at(offset).to_int() |
        (bytes.at(offset + 1).to_int() << 8) |
        (bytes.at(offset + 2).to_int() << 16) |
        (bytes.at(offset + 3).to_int() << 24)
      Float::reinterpret_from_int(bits).to_double()
    }
    _ => raise GltfError::Invalid("unsupported component type")
  }
}

///|
fn normalize(raw : Double, component_type : Int) -> Double {
  match component_type {
    5120 => {
      let n = raw / 127.0
      if n < -1.0 {
        -1.0
      } else {
        n
      }
    }
    5121 => raw / 255.0
    5122 => {
      let n = raw / 32767.0
      if n < -1.0 {
        -1.0
      } else {
        n
      }
    }
    5123 => raw / 65535.0
    _ => raw
  }
}

///|
fn read_acc(
  bins : Array[Bin],
  views : Array[View],
  acc : Acc,
) -> Array[Double] raise GltfError {
  if acc.view < 0 || acc.view >= views.length() {
    raise GltfError::Invalid("bufferView index")
  }
  let view = views[acc.view]
  if view.buffer < 0 || view.buffer >= bins.length() {
    raise GltfError::Invalid("buffer index")
  }
  let bin = bins[view.buffer]
  let width = component_width(acc.component_type)
  let packed = width * acc.components
  let stride = if view.stride == 0 { packed } else { view.stride }
  if view.offset < 0 ||
    acc.offset < 0 ||
    stride <= 0 ||
    acc.count < 0 ||
    view.byte_length < 0 {
    raise GltfError::Invalid("accessor range")
  }
  if acc.count > 0 {
    let end = acc.offset + (acc.count - 1) * stride + acc.components * width
    if end > view.byte_length || view.offset + view.byte_length > bin.limit {
      raise GltfError::Invalid("accessor reads past the buffer view")
    }
  }
  let out = []
  let mut i = 0
  while i < acc.count {
    let mut c = 0
    while c < acc.components {
      let at = view.offset + acc.offset + i * stride + c * width
      let raw = read_component(bin, at, acc.component_type)
      let value = if acc.normalized {
        normalize(raw, acc.component_type)
      } else {
        raw
      }
      out.push(value)
      c = c + 1
    }
    i = i + 1
  }
  out
}

///|
fn read_values(
  bins : Array[Bin],
  views : Array[View],
  accs : Array[Acc],
  index : Int,
  components : Int,
) -> Array[Double] raise GltfError {
  if index < 0 || index >= accs.length() {
    raise GltfError::Invalid("accessor index")
  }
  let acc = accs[index]
  if acc.components != components {
    raise GltfError::Invalid("accessor type does not match the attribute")
  }
  read_acc(bins, views, acc)
}

///|
fn put_attribute(
  geometry : @core.BufferGeometry,
  name : String,
  values : Array[Double],
  item_size : Int,
) -> Unit {
  ignore(
    geometry.set_attribute(name, @core.BufferAttribute::new(values, item_size)),
  )
}

///|
fn load_primitive(
  obj : Map[String, Json],
  bins : Array[Bin],
  views : Array[View],
  accs : Array[Acc],
  materials : Array[Mat],
  weights : Array[Double],
) -> Prim raise GltfError {
  match obj.get("mode") {
    None => ()
    Some(mode) =>
      if as_f64(mode).to_int() != 4 {
        raise GltfError::Invalid("only TRIANGLES primitives are supported")
      }
  }
  let attrs = match obj.get("attributes") {
    None => raise GltfError::Invalid("primitive needs attributes")
    Some(value) => as_object(value)
  }
  let geometry = @core.BufferGeometry::new()
  match attrs.get("POSITION") {
    None => raise GltfError::Invalid("primitive needs POSITION")
    Some(index) =>
      put_attribute(
        geometry,
        "position",
        read_values(bins, views, accs, as_f64(index).to_int(), 3),
        3,
      )
  }
  match attrs.get("NORMAL") {
    None => ()
    Some(index) =>
      put_attribute(
        geometry,
        "normal",
        read_values(bins, views, accs, as_f64(index).to_int(), 3),
        3,
      )
  }
  match attrs.get("TEXCOORD_0") {
    None => ()
    Some(index) =>
      put_attribute(
        geometry,
        "uv",
        read_values(bins, views, accs, as_f64(index).to_int(), 2),
        2,
      )
  }
  match obj.get("indices") {
    None => ()
    Some(index) => {
      let values = read_values(bins, views, accs, as_f64(index).to_int(), 1)
      let indices = []
      let mut i = 0
      while i < values.length() {
        indices.push(values[i].to_int())
        i = i + 1
      }
      ignore(geometry.set_index_array(indices))
    }
  }
  let mat = match obj.get("material") {
    None => default_mat()
    Some(index) => {
      let at = as_f64(index).to_int()
      if at < 0 || at >= materials.length() {
        raise GltfError::Invalid("material index")
      }
      materials[at]
    }
  }
  let targets = match obj.get("targets") {
    None => []
    Some(value) => read_morph_targets(as_array(value), bins, views, accs)
  }
  let baked = baked_geometry(geometry, targets, weights)
  { geometry, mat, targets, mesh_weights: weights, baked, }
}

///|
fn read_morph_targets(
  targets : Array[Json],
  bins : Array[Bin],
  views : Array[View],
  accs : Array[Acc],
) -> Array[MorphTarget] raise GltfError {
  let out = []
  let mut index = 0
  while index < targets.length() {
    let target = as_object(targets[index])
    let position = match target.get("POSITION") {
      None => None
      Some(accessor) =>
        Some(read_values(bins, views, accs, as_f64(accessor).to_int(), 3))
    }
    let normal = match target.get("NORMAL") {
      None => None
      Some(accessor) =>
        Some(read_values(bins, views, accs, as_f64(accessor).to_int(), 3))
    }
    out.push({ position, normal, })
    index = index + 1
  }
  out
}

///|
/// 按权重把 `POSITION` 和 `NORMAL` 增量加进已有属性。
/// 没有法线属性时跳过 `NORMAL` 目标。顶点色形变先不加。
/// 这不是运行时的 `morphTargetInfluences`，只烘焙这一份权重。上游把增量放进 `morphAttributes`。
/// r186: `addMorphTargets` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L2387 ; `updateMorphTargets` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L2474
fn apply_stored_morphs(
  geometry : @core.BufferGeometry,
  targets : Array[MorphTarget],
  weights : Array[Double],
) -> Unit raise GltfError {
  let position = match geometry.get_attribute("position") {
    None => return
    Some(attribute) => attribute
  }
  let normal = geometry.get_attribute("normal")
  let mut index = 0
  while index < targets.length() {
    let weight = if index < weights.length() { weights[index] } else { 0.0 }
    if weight != 0.0 {
      match targets[index].position {
        None => ()
        Some(deltas) => add_weighted_deltas(position, deltas, weight)
      }
      match normal {
        None => ()
        Some(attribute) =>
          match targets[index].normal {
            None => ()
            Some(deltas) => add_weighted_deltas(attribute, deltas, weight)
          }
      }
    }
    index = index + 1
  }
}

///|
fn baked_geometry(
  base : @core.BufferGeometry,
  targets : Array[MorphTarget],
  weights : Array[Double],
) -> @core.BufferGeometry raise GltfError {
  let resolved = resolve_weights(weights, None, targets.length())
  if all_zero(resolved) {
    base
  } else {
    let geometry = clone_geometry(base)
    apply_stored_morphs(geometry, targets, resolved)
    geometry
  }
}

///|
/// 节点 `weights` 按索引盖过 `mesh.weights`。更短的节点列表保留后面的网格权重。
/// 和网格权重相同时共用烘焙结果；不同时从原始几何复制再烘焙，避免改到共享网格。
/// 权重全是 0 时共用未烘焙的几何。动画通道里的 `weights` 仍不采样。
/// r186: `createNodeMesh` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L4213
fn geometry_for(
  prim : Prim,
  node_weights : Array[Double]?,
) -> @core.BufferGeometry raise GltfError {
  match node_weights {
    None => prim.baked
    Some(_) => {
      let weights = resolve_weights(
        prim.mesh_weights,
        node_weights,
        prim.targets.length(),
      )
      let defaults = resolve_weights(
        prim.mesh_weights,
        None,
        prim.targets.length(),
      )
      if same_numbers(weights, defaults) {
        prim.baked
      } else if all_zero(weights) {
        prim.geometry
      } else {
        let geometry = clone_geometry(prim.geometry)
        apply_stored_morphs(geometry, prim.targets, weights)
        geometry
      }
    }
  }
}

///|
fn resolve_weights(
  mesh_weights : Array[Double],
  node_weights : Array[Double]?,
  count : Int,
) -> Array[Double] {
  let out = []
  let mut index = 0
  while index < count {
    let weight = match node_weights {
      None =>
        if index < mesh_weights.length() {
          mesh_weights[index]
        } else {
          0.0
        }
      Some(overrides) =>
        if index < overrides.length() {
          overrides[index]
        } else if index < mesh_weights.length() {
          mesh_weights[index]
        } else {
          0.0
        }
    }
    out.push(weight)
    index = index + 1
  }
  out
}

///|
fn same_numbers(left : Array[Double], right : Array[Double]) -> Bool {
  if left.length() != right.length() {
    return false
  }
  let mut index = 0
  while index < left.length() {
    if left[index] != right[index] {
      return false
    }
    index = index + 1
  }
  true
}

///|
fn all_zero(weights : Array[Double]) -> Bool {
  let mut index = 0
  while index < weights.length() {
    if weights[index] != 0.0 {
      return false
    }
    index = index + 1
  }
  true
}

///|
fn clone_geometry(source : @core.BufferGeometry) -> @core.BufferGeometry {
  let geometry = @core.BufferGeometry::new()
  copy_named(source, geometry, "position")
  copy_named(source, geometry, "normal")
  copy_named(source, geometry, "uv")
  match source.index {
    None => ()
    Some(index) =>
      ignore(
        geometry.set_index(
          @core.BufferAttribute::new(
            index.array.copy(),
            index.item_size,
            normalized=index.normalized,
          ),
        ),
      )
  }
  geometry
}

///|
fn copy_named(
  source : @core.BufferGeometry,
  geometry : @core.BufferGeometry,
  name : String,
) -> Unit {
  match source.get_attribute(name) {
    None => ()
    Some(attribute) =>
      ignore(
        geometry.set_attribute(
          name,
          @core.BufferAttribute::new(
            attribute.array.copy(),
            attribute.item_size,
            normalized=attribute.normalized,
          ),
        ),
      )
  }
}

///|
fn add_weighted_deltas(
  attribute : @core.BufferAttribute,
  deltas : Array[Double],
  weight : Double,
) -> Unit raise GltfError {
  if deltas.length() != attribute.count * 3 {
    raise GltfError::Invalid("morph target")
  }
  let mut vertex = 0
  while vertex < attribute.count {
    let base = vertex * 3
    attribute.set_xyz(
      vertex,
      attribute.get_x(vertex) + weight * deltas[base],
      attribute.get_y(vertex) + weight * deltas[base + 1],
      attribute.get_z(vertex) + weight * deltas[base + 2],
    )
    vertex = vertex + 1
  }
}

///|
fn load_meshes(
  root : Map[String, Json],
  bins : Array[Bin],
  views : Array[View],
  accs : Array[Acc],
  materials : Array[Mat],
) -> Array[Array[Prim]] raise GltfError {
  let listed = objects(root, "meshes")
  let out = []
  let mut i = 0
  while i < listed.length() {
    let prims = match listed[i].get("primitives") {
      None => []
      Some(value) => as_array(value)
    }
    let weights = match listed[i].get("weights") {
      None => []
      Some(value) => as_doubles(value)
    }
    let built = []
    let mut p = 0
    while p < prims.length() {
      built.push(
        load_primitive(
          as_object(prims[p]),
          bins,
          views,
          accs,
          materials,
          weights,
        ),
      )
      p = p + 1
    }
    out.push(built)
    i = i + 1
  }
  out
}

///|
fn opt_vec3(
  obj : Map[String, Json],
  key : String,
  x : Double,
  y : Double,
  z : Double,
) -> (Double, Double, Double) raise GltfError {
  match obj.get(key) {
    None => (x, y, z)
    Some(value) => {
      let nums = as_doubles(value)
      if nums.length() < 3 {
        raise GltfError::Invalid(key + " needs 3 numbers")
      }
      (nums[0], nums[1], nums[2])
    }
  }
}

///|
fn load_node(obj : Map[String, Json]) -> NodeDesc raise GltfError {
  let (tx, ty, tz) = opt_vec3(obj, "translation", 0.0, 0.0, 0.0)
  let (sx, sy, sz) = opt_vec3(obj, "scale", 1.0, 1.0, 1.0)
  let (rx, ry, rz, rw) = match obj.get("rotation") {
    None => (0.0, 0.0, 0.0, 1.0)
    Some(value) => {
      let nums = as_doubles(value)
      if nums.length() < 4 {
        raise GltfError::Invalid("rotation needs 4 numbers")
      }
      (nums[0], nums[1], nums[2], nums[3])
    }
  }
  let matrix = match obj.get("matrix") {
    None => None
    Some(value) => {
      let nums = as_doubles(value)
      if nums.length() != 16 {
        raise GltfError::Invalid("node matrix needs 16 numbers")
      }
      Some(nums)
    }
  }
  let mesh = match obj.get("mesh") {
    None => None
    Some(value) => Some(as_f64(value).to_int())
  }
  let camera = match obj.get("camera") {
    None => None
    Some(value) => Some(as_f64(value).to_int())
  }
  let light = node_light(obj)
  let children = match obj.get("children") {
    None => []
    Some(value) => as_ints(value)
  }
  let weights = match obj.get("weights") {
    None => None
    Some(value) => Some(as_doubles(value))
  }
  {
    name: opt_string(obj, "name", ""),
    children,
    mesh,
    camera,
    light,
    tx,
    ty,
    tz,
    rx,
    ry,
    rz,
    rw,
    sx,
    sy,
    sz,
    matrix,
    weights,
  }
}

///|
fn load_nodes(root : Map[String, Json]) -> Array[NodeDesc] raise GltfError {
  let listed = objects(root, "nodes")
  let out = []
  let mut i = 0
  while i < listed.length() {
    out.push(load_node(listed[i]))
    i = i + 1
  }
  out
}

///|
fn apply_transform(node : @core.Object3D, desc : NodeDesc) -> Unit {
  node.name = desc.name
  match desc.matrix {
    Some(values) => {
      let m = @math.Matrix4::new()
      let mut i = 0
      while i < 16 {
        m.elements[i] = values[i]
        i = i + 1
      }
      ignore(m.decompose(node.position, node.quaternion, node.scale))
    }
    None => {
      ignore(node.position.set(desc.tx, desc.ty, desc.tz))
      ignore(node.quaternion.set(desc.rx, desc.ry, desc.rz, desc.rw))
      ignore(node.scale.set(desc.sx, desc.sy, desc.sz))
    }
  }
}

///|
fn mesh_from(
  prim : Prim,
  node_weights : Array[Double]?,
) -> @objects.Mesh raise GltfError {
  let geometry = geometry_for(prim, node_weights)
  let material = if prim.mat.unlit {
    @materials.MeshBasicMaterial::new().material
  } else {
    @materials.MeshStandardMaterial::new(
      roughness=prim.mat.roughness,
      metalness=prim.mat.metalness,
    ).material
  }
  ignore(material.color.set_rgb(prim.mat.r, prim.mat.g, prim.mat.b))
  material.opacity = prim.mat.opacity
  material.transparent = prim.mat.transparent
  let mesh = @objects.Mesh::new(geometry, material)
  if prim.mat.double_sided {
    mesh.set_side(@constants.Side::Double)
  }
  mesh
}

///|
/// `0` 按 JavaScript 的 `||` 换成默认值。
fn or_nonzero(value : Double, fallback : Double) -> Double {
  if value == 0.0 {
    fallback
  } else {
    value
  }
}

///|
/// r186: `loadCamera` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L4014
fn load_camera(obj : Map[String, Json]) -> Cam raise GltfError {
  let name = opt_string(obj, "name", "")
  match opt_string(obj, "type", "") {
    "perspective" => {
      let params = match obj.get("perspective") {
        None => raise GltfError::Invalid("camera parameters")
        Some(value) => as_object(value)
      }
      match params.get("yfov") {
        None => raise GltfError::Invalid("perspective yfov")
        Some(value) =>
          {
            kind: Perspective,
            fov: @math.rad_to_deg(as_f64(value)),
            aspect: or_nonzero(opt_f64(params, "aspectRatio", 1.0), 1.0),
            xmag: 0.0,
            ymag: 0.0,
            znear: or_nonzero(opt_f64(params, "znear", 1.0), 1.0),
            zfar: or_nonzero(opt_f64(params, "zfar", 2000000.0), 2000000.0),
            name,
          }
      }
    }
    "orthographic" => {
      let params = match obj.get("orthographic") {
        None => raise GltfError::Invalid("camera parameters")
        Some(value) => as_object(value)
      }
      {
        kind: Orthographic,
        fov: 50.0,
        aspect: 1.0,
        xmag: require_f64(params, "xmag"),
        ymag: require_f64(params, "ymag"),
        znear: require_f64(params, "znear"),
        zfar: require_f64(params, "zfar"),
        name,
      }
    }
    _ => raise GltfError::Invalid("camera type")
  }
}

///|
fn require_f64(obj : Map[String, Json], key : String) -> Double raise GltfError {
  match obj.get(key) {
    None => raise GltfError::Invalid(key)
    Some(value) => as_f64(value)
  }
}

///|
fn load_cameras(root : Map[String, Json]) -> Array[Cam] raise GltfError {
  let listed = objects(root, "cameras")
  let out = []
  let mut i = 0
  while i < listed.length() {
    out.push(load_camera(listed[i]))
    i = i + 1
  }
  out
}

///|
fn camera_object(cam : Cam) -> @core.Object3D {
  match cam.kind {
    Perspective => {
      let camera = @cameras.PerspectiveCamera::new(
        fov=cam.fov,
        aspect=cam.aspect,
        near=cam.znear,
        far=cam.zfar,
      )
      camera.node.name = cam.name
      camera.node
    }
    Orthographic => {
      let camera = @cameras.OrthographicCamera::new(
        left=-cam.xmag,
        right=cam.xmag,
        top=cam.ymag,
        bottom=-cam.ymag,
        near=cam.znear,
        far=cam.zfar,
      )
      camera.node.name = cam.name
      camera.node
    }
  }
}

///|

///|
priv struct Punctual {
  r : Double
  g : Double
  b : Double
  intensity : Double
  name : String
}

///|
fn extension_block(
  obj : Map[String, Json],
  name : String,
) -> Map[String, Json]? raise GltfError {
  match obj.get("extensions") {
    None => None
    Some(value) => {
      let extensions = as_object(value)
      match extensions.get(name) {
        None => None
        Some(block) => Some(as_object(block))
      }
    }
  }
}

///|
fn node_light(obj : Map[String, Json]) -> Int? raise GltfError {
  match extension_block(obj, "KHR_lights_punctual") {
    None => None
    Some(block) =>
      match block.get("light") {
        None => None
        Some(value) => Some(as_f64(value).to_int())
      }
  }
}

///|
/// 平行光的目标在本地 `(0, 0, -1)`，位置先归零，再套节点变换。
/// r186: `_loadLight` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L695
fn load_punctual(
  obj : Map[String, Json],
  index : Int,
) -> Punctual raise GltfError {
  match opt_string(obj, "type", "") {
    "directional" => ()
    _ => raise GltfError::Invalid("punctual light type")
  }
  let (r, g, b) = match obj.get("color") {
    None => (1.0, 1.0, 1.0)
    Some(value) => {
      let nums = as_doubles(value)
      if nums.length() < 3 {
        raise GltfError::Invalid("light color")
      }
      (nums[0], nums[1], nums[2])
    }
  }
  let given = opt_string(obj, "name", "")
  let name = if given == "" { "light_\{index}" } else { given }
  { r, g, b, intensity: opt_f64(obj, "intensity", 1.0), name, }
}

///|
fn load_punctuals(root : Map[String, Json]) -> Array[Punctual] raise GltfError {
  let lights = match extension_block(root, "KHR_lights_punctual") {
    None => []
    Some(block) => objects(block, "lights")
  }
  let out = []
  let mut i = 0
  while i < lights.length() {
    out.push(load_punctual(lights[i], i))
    i = i + 1
  }
  out
}

///|
fn light_object(light : Punctual) -> @core.Object3D {
  let sun = @lights.DirectionalLight::new(intensity=light.intensity)
  ignore(sun.node.position.set(0.0, 0.0, 0.0))
  match sun.node.light {
    None => ()
    Some(state) => ignore(state.color.set_rgb(light.r, light.g, light.b))
  }
  ignore(sun.target.position.set(0.0, 0.0, -1.0))
  ignore(sun.node.add(sun.target))
  sun.node.name = light.name
  sun.node
}

///|
fn build_nodes(
  nodes : Array[NodeDesc],
  meshes : Array[Array[Prim]],
  cameras : Array[Cam],
  lights : Array[Punctual],
) -> Array[@core.Object3D] raise GltfError {
  let built = []
  let mut i = 0
  while i < nodes.length() {
    let desc = nodes[i]
    let parts = []
    match desc.mesh {
      None => ()
      Some(index) => {
        if index < 0 || index >= meshes.length() {
          raise GltfError::Invalid("mesh index")
        }
        let prims = meshes[index]
        let mut p = 0
        while p < prims.length() {
          parts.push(mesh_from(prims[p], desc.weights).node)
          p = p + 1
        }
      }
    }
    match desc.camera {
      None => ()
      Some(index) => {
        if index < 0 || index >= cameras.length() {
          raise GltfError::Invalid("camera index")
        }
        parts.push(camera_object(cameras[index]))
      }
    }
    match desc.light {
      None => ()
      Some(index) => {
        if index < 0 || index >= lights.length() {
          raise GltfError::Invalid("light index")
        }
        parts.push(light_object(lights[index]))
      }
    }
    let node = if parts.length() == 0 {
      let group = @objects.Group::new()
      apply_transform(group.node, desc)
      group.node
    } else if parts.length() == 1 {
      apply_transform(parts[0], desc)
      if desc.name == "" {
        match desc.camera {
          None => ()
          Some(index) => parts[0].name = cameras[index].name
        }
        match desc.light {
          None => ()
          Some(index) => parts[0].name = lights[index].name
        }
      }
      parts[0]
    } else {
      let group = @objects.Group::new()
      apply_transform(group.node, desc)
      let mut p = 0
      while p < parts.length() {
        ignore(group.node.add(parts[p]))
        p = p + 1
      }
      group.node
    }
    built.push(node)
    i = i + 1
  }
  built
}

///|
fn link_children(
  nodes : Array[NodeDesc],
  built : Array[@core.Object3D],
) -> Unit raise GltfError {
  let mut i = 0
  while i < nodes.length() {
    let mut c = 0
    let children = nodes[i].children
    while c < children.length() {
      let index = children[c]
      if index < 0 || index >= built.length() {
        raise GltfError::Invalid("child node index")
      }
      ignore(built[i].add(built[index]))
      c = c + 1
    }
    i = i + 1
  }
}

///|
fn unreferenced(nodes : Array[NodeDesc]) -> Array[Int] {
  let used = []
  let mut i = 0
  while i < nodes.length() {
    let mut c = 0
    let children = nodes[i].children
    while c < children.length() {
      used.push(children[c])
      c = c + 1
    }
    i = i + 1
  }
  let roots = []
  i = 0
  while i < nodes.length() {
    let mut found = false
    let mut u = 0
    while u < used.length() {
      if used[u] == i {
        found = true
      }
      u = u + 1
    }
    if !found {
      roots.push(i)
    }
    i = i + 1
  }
  roots
}

///|

///|
fn track_suffix(path : String) -> String raise GltfError {
  match path {
    "translation" => "position"
    "rotation" => "quaternion"
    "scale" => "scale"
    _ => raise GltfError::Invalid("animation path")
  }
}

///|
priv enum SamplerInterp {
  Linear
  Step
  Cubic
}

///|
fn animation_interpolation(name : String) -> SamplerInterp raise GltfError {
  match name {
    "LINEAR" => Linear
    "STEP" => Step
    "CUBICSPLINE" => Cubic
    _ => raise GltfError::Invalid("animation interpolation")
  }
}

///|
/// r186: `loadAnimation` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L4124
fn load_animation(
  obj : Map[String, Json],
  index : Int,
  bins : Array[Bin],
  views : Array[View],
  accs : Array[Acc],
  built : Array[@core.Object3D],
) -> @animation.AnimationClip raise GltfError {
  let given = opt_string(obj, "name", "")
  let name = if given == "" { "animation_\{index}" } else { given }
  let samplers = objects(obj, "samplers")
  let channels = objects(obj, "channels")
  let tracks = []
  let mut i = 0
  while i < channels.length() {
    let channel = channels[i]
    let target = match channel.get("target") {
      None => raise GltfError::Invalid("animation target")
      Some(value) => as_object(value)
    }
    match target.get("node") {
      None => ()
      Some(node_value) => {
        let node_index = as_f64(node_value).to_int()
        if node_index < 0 || node_index >= built.length() {
          raise GltfError::Invalid("animation node")
        }
        let node_name = built[node_index].name
        let path = opt_string(target, "path", "")
        if node_name != "" && path != "weights" {
          let suffix = track_suffix(path)
          let sampler_index = match channel.get("sampler") {
            None => raise GltfError::Invalid("animation sampler")
            Some(value) => as_f64(value).to_int()
          }
          if sampler_index < 0 || sampler_index >= samplers.length() {
            raise GltfError::Invalid("animation sampler")
          }
          let sampler = samplers[sampler_index]
          let kind = animation_interpolation(
            opt_string(sampler, "interpolation", "LINEAR"),
          )
          let times = read_values(
            bins,
            views,
            accs,
            require_f64(sampler, "input").to_int(),
            1,
          )
          let size = if path == "rotation" { 4 } else { 3 }
          let output = read_values(
            bins,
            views,
            accs,
            require_f64(sampler, "output").to_int(),
            size,
          )
          let copies = match kind {
            Cubic => 3
            _ => 1
          }
          if times.length() == 0 ||
            output.length() != times.length() * size * copies {
            raise GltfError::Invalid("animation output")
          }
          let track = match kind {
            Cubic =>
              if path == "rotation" {
                @animation.KeyframeTrack::cubic_quaternion(
                  node_name + "." + suffix,
                  times,
                  output,
                )
              } else {
                @animation.KeyframeTrack::cubic_vector(
                  node_name + "." + suffix,
                  times,
                  output,
                )
              }
            _ =>
              if path == "rotation" {
                @animation.KeyframeTrack::quaternion(
                  node_name + "." + suffix,
                  times,
                  output,
                )
              } else {
                @animation.KeyframeTrack::vector(
                  node_name + "." + suffix,
                  times,
                  output,
                )
              }
          }
          match kind {
            Step => track.interpolation = @constants.Interpolation::Discrete
            _ => ()
          }
          tracks.push(track)
        }
      }
    }
    i = i + 1
  }
  @animation.AnimationClip::new(name, tracks)
}

///|
fn load_animations(
  root : Map[String, Json],
  bins : Array[Bin],
  views : Array[View],
  accs : Array[Acc],
  built : Array[@core.Object3D],
) -> Array[@animation.AnimationClip] raise GltfError {
  let listed = objects(root, "animations")
  let out = []
  let mut i = 0
  while i < listed.length() {
    out.push(load_animation(listed[i], i, bins, views, accs, built))
    i = i + 1
  }
  out
}

///|
fn scene_roots(
  root : Map[String, Json],
  nodes : Array[NodeDesc],
) -> SceneRoots raise GltfError {
  let scenes = objects(root, "scenes")
  if scenes.length() == 0 {
    return { name: "", indices: unreferenced(nodes), }
  }
  let index = match root.get("scene") {
    None => 0
    Some(value) => as_f64(value).to_int()
  }
  if index < 0 || index >= scenes.length() {
    raise GltfError::Invalid("scene index")
  }
  let scene = scenes[index]
  let indices = match scene.get("nodes") {
    None => []
    Some(value) => as_ints(value)
  }
  { name: opt_string(scene, "name", ""), indices, }
}
