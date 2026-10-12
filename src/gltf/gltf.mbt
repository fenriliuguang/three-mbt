// r186: `GLTFLoader` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L129 ; `loadSkin` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L4052

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
priv struct SparseRef {
  count : Int
  index_view : Int
  index_offset : Int
  index_type : Int
  value_view : Int
  value_offset : Int
}

///|
priv struct Acc {
  view : Int
  offset : Int
  count : Int
  components : Int
  component_type : Int
  normalized : Bool
  sparse : SparseRef?
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
  alpha_test : Double
  er : Double
  eg : Double
  eb : Double
  emissive_intensity : Double
}

///|
priv struct MorphTarget {
  position : Array[Double]?
  normal : Array[Double]?
  color : Array[Double]?
}

///|
priv struct Prim {
  geometry : @core.BufferGeometry
  mat : Mat
  targets : Array[MorphTarget]
  mesh_weights : Array[Double]
  baked : @core.BufferGeometry
  joints : Array[Int]?
  weights : Array[Double]?
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
  skin : Int?
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
/// 只建 `TRIANGLES` 网格：`POSITION`、`NORMAL`、`TEXCOORD_0`、`COLOR_0` 和索引。
/// 稀疏 accessor 按索引替换元素；没有 `bufferView` 时底数是 0。
/// 材质写成 `MeshStandardMaterial`，`baseColorFactor` 按线性通道写入，
/// 再带上粗糙度、金属度和 `doubleSided`。`alphaMode` 为 `BLEND` 时进透明队列，`MASK` 写入 `alphaTest`，`OPAQUE` 忽略 alpha。`KHR_materials_unlit` 改用 `MeshBasicMaterial`。`emissiveFactor` 按线性通道写入 Lambert 和 Standard，缺省黑色；unlit 忽略它。`KHR_materials_emissive_strength` 写入 `emissiveIntensity`，缺省 1，`0` 保留。
/// 节点上的相机会建成透视或正交相机。
/// 动画读取 `translation`、`rotation` 和 `scale`。`LINEAR` 与 `STEP` 按线性或离散采样，`CUBICSPLINE` 按切线布局采样。
/// `KHR_lights_punctual` 的平行光会挂到节点上。`mesh.weights` 会把 `POSITION` 形变增量烘焙进顶点，已有法线时也烘焙 `NORMAL`，已有顶点色时也烘焙 `COLOR_0`。节点 `weights` 按索引盖过网格权重；和网格权重不同时复制几何再烘焙。动画通道 `weights` 写成 `.morphTargetInfluences`，按采样结果从底数重烘焙。没有形变目标的节点跳过该通道。点光按节点位置挂上，`range` 写成 `distance`，`decay` 为 2。聚光同样使用 `range` 和 `decay` 2，`outerConeAngle` 写成 `angle`，`penumbra` 为 `1 - innerConeAngle / outerConeAngle`，目标在本地 `(0, 0, -1)`。贴图先不读。`JOINTS_0` 和 `WEIGHTS_0` 在 CPU 上按线性混合写入顶点：关节矩阵是关节世界矩阵乘 `inverseBindMatrices`，再乘网格世界矩阵的逆。缺一对属性时不蒙皮。有形变目标时先把 `POSITION` 和 `NORMAL` 增量加进底数，再蒙皮。`JOINTS_1` 和 `WEIGHTS_1` 成对时再加四个影响，并和第一组一起归一化。`JOINTS_2` 和 `WEIGHTS_2` 只在第二组成对出现后再加四个，缺第二组时忽略第三组。`JOINTS_3` 和 `WEIGHTS_3` 只在第三组成对出现后再加四个，缺第三组时忽略第四组。
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
  let skins = load_skins(root, bins, views, accs)
  let nodes = load_nodes(root)
  let built = build_nodes(nodes, meshes, cameras, lights, skins)
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
    "MAT4" => 16
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
      None =>
        match obj.get("sparse") {
          None => raise GltfError::Invalid("accessor needs a bufferView")
          Some(_) => -1
        }
      Some(value) => as_f64(value).to_int()
    }
    out.push({
      view,
      offset: opt_f64(obj, "byteOffset", 0.0).to_int(),
      count: opt_f64(obj, "count", 0.0).to_int(),
      components: component_count(opt_string(obj, "type", "")),
      component_type: opt_f64(obj, "componentType", 0.0).to_int(),
      normalized: opt_bool(obj, "normalized", false),
      sparse: load_sparse(obj),
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
    alpha_test: 0.0,
    er: 0.0,
    eg: 0.0,
    eb: 0.0,
    emissive_intensity: 1.0,
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
  let mode = opt_string(obj, "alphaMode", "OPAQUE")
  let (transparent, opacity, alpha_test) = alpha_coverage(
    mode,
    alpha,
    opt_f64(obj, "alphaCutoff", 0.5),
  )
  let (er, eg, eb) = emissive_factor(obj)
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
    alpha_test,
    er,
    eg,
    eb,
    emissive_intensity: emissive_strength(obj),
  }
}

///|
/// 缺省是黑色。`0` 是有效值，不按缺失处理。自发光贴图先不读。
/// r186: `emissiveFactor` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L3719
fn emissive_factor(
  obj : Map[String, Json],
) -> (Double, Double, Double) raise GltfError {
  match obj.get("emissiveFactor") {
    None => (0.0, 0.0, 0.0)
    Some(factor) => {
      let nums = as_doubles(factor)
      if nums.length() < 3 {
        raise GltfError::Invalid("emissiveFactor needs RGB")
      }
      (nums[0], nums[1], nums[2])
    }
  }
}

///|
/// 缺省是 1。`0` 是有效值。unlit 材质不使用这份强度。
/// r186: `emissiveStrength` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L872
fn emissive_strength(obj : Map[String, Json]) -> Double raise GltfError {
  match extension_block(obj, "KHR_materials_emissive_strength") {
    None => 1.0
    Some(block) => opt_f64(block, "emissiveStrength", 1.0)
  }
}

///|
/// `OPAQUE` 忽略 alpha。`MASK` 把 `alphaCutoff` 写成 `alphaTest`，缺省 0.5。
/// `BLEND` 进入透明队列，opacity 用 baseColor 的 alpha。
/// r186: `alphaMode` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L3668
fn alpha_coverage(
  mode : String,
  alpha : Double,
  cutoff : Double,
) -> (Bool, Double, Double) raise GltfError {
  match mode {
    "OPAQUE" => (false, 1.0, 0.0)
    "MASK" => (false, alpha, cutoff)
    "BLEND" => (true, alpha, 0.0)
    _ => raise GltfError::Invalid("alpha mode")
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
  let out = if acc.view < 0 {
    if acc.count < 0 {
      raise GltfError::Invalid("accessor range")
    }
    zero_values(acc.count * acc.components)
  } else {
    read_dense(bins, views, acc)
  }
  apply_sparse(out, bins, views, acc)
}

///|
fn zero_values(count : Int) -> Array[Double] {
  let out = []
  let mut index = 0
  while index < count {
    out.push(0.0)
    index = index + 1
  }
  out
}

///|
fn read_dense(
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
/// 稀疏块按索引盖过稠密值。底数和替换值用同一套归一化。
/// r186: `loadAccessor` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L3213
fn apply_sparse(
  values : Array[Double],
  bins : Array[Bin],
  views : Array[View],
  acc : Acc,
) -> Array[Double] raise GltfError {
  match acc.sparse {
    None => values
    Some(sparse) => {
      if sparse.count < 0 || sparse.count > acc.count {
        raise GltfError::Invalid("sparse count")
      }
      let index_view = sparse_view(views, sparse.index_view)
      let value_view = sparse_view(views, sparse.value_view)
      let index_bin = sparse_bin(bins, index_view)
      let value_bin = sparse_bin(bins, value_view)
      let index_width = component_width(sparse.index_type)
      let value_width = component_width(acc.component_type)
      if sparse.index_offset < 0 || sparse.value_offset < 0 {
        raise GltfError::Invalid("accessor range")
      }
      if sparse.count > 0 {
        let index_end = sparse.index_offset + sparse.count * index_width
        let value_end = sparse.value_offset +
          sparse.count * acc.components * value_width
        if index_end > index_view.byte_length ||
          value_end > value_view.byte_length ||
          index_view.offset + index_view.byte_length > index_bin.limit ||
          value_view.offset + value_view.byte_length > value_bin.limit {
          raise GltfError::Invalid("accessor reads past the buffer view")
        }
      }
      let mut index = 0
      while index < sparse.count {
        let index_at = index_view.offset +
          sparse.index_offset +
          index * index_width
        let element = read_component(index_bin, index_at, sparse.index_type).to_int()
        if element < 0 || element >= acc.count {
          raise GltfError::Invalid("sparse index")
        }
        let mut component = 0
        while component < acc.components {
          let value_at = value_view.offset +
            sparse.value_offset +
            (index * acc.components + component) * value_width
          let raw = read_component(value_bin, value_at, acc.component_type)
          let value = if acc.normalized {
            normalize(raw, acc.component_type)
          } else {
            raw
          }
          values[element * acc.components + component] = value
          component = component + 1
        }
        index = index + 1
      }
      values
    }
  }
}

///|
fn sparse_view(views : Array[View], index : Int) -> View raise GltfError {
  if index < 0 || index >= views.length() {
    raise GltfError::Invalid("bufferView index")
  }
  views[index]
}

///|
fn sparse_bin(bins : Array[Bin], view : View) -> Bin raise GltfError {
  if view.buffer < 0 || view.buffer >= bins.length() {
    raise GltfError::Invalid("buffer index")
  }
  bins[view.buffer]
}

///|
fn load_sparse(obj : Map[String, Json]) -> SparseRef? raise GltfError {
  match obj.get("sparse") {
    None => None
    Some(value) => {
      let sparse = as_object(value)
      let count = opt_f64(sparse, "count", -1.0).to_int()
      if count < 0 {
        raise GltfError::Invalid("sparse count")
      }
      let indices = match sparse.get("indices") {
        None => raise GltfError::Invalid("sparse index")
        Some(block) => as_object(block)
      }
      let values = match sparse.get("values") {
        None => raise GltfError::Invalid("sparse values")
        Some(block) => as_object(block)
      }
      let index_type = opt_f64(indices, "componentType", 0.0).to_int()
      if index_type != 5121 && index_type != 5123 && index_type != 5125 {
        raise GltfError::Invalid("sparse index")
      }
      Some({
        count,
        index_view: require_f64(indices, "bufferView").to_int(),
        index_offset: opt_f64(indices, "byteOffset", 0.0).to_int(),
        index_type,
        value_view: require_f64(values, "bufferView").to_int(),
        value_offset: opt_f64(values, "byteOffset", 0.0).to_int(),
      })
    }
  }
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
fn color_width(accs : Array[Acc], index : Int) -> Int raise GltfError {
  if index < 0 || index >= accs.length() {
    raise GltfError::Invalid("accessor index")
  }
  let width = accs[index].components
  if width != 3 && width != 4 {
    raise GltfError::Invalid("color accessor")
  }
  width
}

///|
fn read_color(
  bins : Array[Bin],
  views : Array[View],
  accs : Array[Acc],
  index : Int,
) -> Array[Double] raise GltfError {
  read_values(bins, views, accs, index, color_width(accs, index))
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
  match attrs.get("COLOR_0") {
    None => ()
    Some(index) => {
      let at = as_f64(index).to_int()
      put_attribute(
        geometry,
        "color",
        read_color(bins, views, accs, at),
        color_width(accs, at),
      )
    }
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
  let (joints, skin_weights) = read_skin_attributes(
    attrs, bins, views, accs, geometry,
  )
  {
    geometry,
    mat,
    targets,
    mesh_weights: weights,
    baked,
    joints,
    weights: skin_weights,
  }
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
    let color = match target.get("COLOR_0") {
      None => None
      Some(accessor) =>
        Some(read_color(bins, views, accs, as_f64(accessor).to_int()))
    }
    out.push({ position, normal, color, })
    index = index + 1
  }
  out
}

///|
/// 按权重把 `POSITION`、`NORMAL` 和 `COLOR_0` 增量加进已有属性。
/// 没有法线或顶点色属性时跳过对应目标。
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
  let color = geometry.get_attribute("color")
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
      match color {
        None => ()
        Some(attribute) =>
          match targets[index].color {
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
/// 权重全是 0 时共用未烘焙的几何。动画采样会在第一次写入时复制仍共享的几何。
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
  copy_named(source, geometry, "color")
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
  if deltas.length() != attribute.count * attribute.item_size {
    raise GltfError::Invalid("morph target")
  }
  let mut vertex = 0
  while vertex < attribute.count {
    let base = vertex * attribute.item_size
    let mut component = 0
    while component < attribute.item_size {
      let at = base + component
      attribute.array[at] = attribute.array[at] + weight * deltas[at]
      component = component + 1
    }
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
  let skin = match obj.get("skin") {
    None => None
    Some(value) => Some(as_f64(value).to_int())
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
    skin,
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
  material.alpha_test = prim.mat.alpha_test
  if prim.mat.unlit == false {
    ignore(material.emissive.set_rgb(prim.mat.er, prim.mat.eg, prim.mat.eb))
    material.emissive_intensity = prim.mat.emissive_intensity
  }
  let mesh = @objects.Mesh::new(geometry, material)
  if prim.targets.length() > 0 {
    let weights = resolve_weights(
      prim.mesh_weights,
      node_weights,
      prim.targets.length(),
    )
    mesh.node.morph = Some(@core.MorphState::{
      base_position: copied_attribute(prim.geometry, "position"),
      base_normal: optional_attribute(prim.geometry, "normal"),
      base_color: optional_attribute(prim.geometry, "color"),
      targets: core_targets(prim.targets),
      weights,
      shared: physical_equal(geometry, prim.baked) ||
      physical_equal(geometry, prim.geometry),
    })
  }
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
priv enum PunctualKind {
  Directional
  Point
  Spot
}

///|
priv struct Punctual {
  kind : PunctualKind
  r : Double
  g : Double
  b : Double
  intensity : Double
  distance : Double
  angle : Double
  penumbra : Double
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
/// 平行光和聚光的目标在本地 `(0, 0, -1)`，位置先归零，再套节点变换。
/// 点光和聚光用 `range`，缺省是 0，表示不截断。聚光的外角缺省是 `π/4`。
/// r186: `_loadLight` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L695
fn load_punctual(
  obj : Map[String, Json],
  index : Int,
) -> Punctual raise GltfError {
  let kind = match opt_string(obj, "type", "") {
    "directional" => Directional
    "point" => Point
    "spot" => Spot
    _ => raise GltfError::Invalid("punctual light type")
  }
  let distance = match kind {
    Point | Spot => opt_f64(obj, "range", 0.0)
    Directional => 0.0
  }
  let (angle, penumbra) = match kind {
    Spot =>
      match obj.get("spot") {
        None => (@std.PI / 4.0, 1.0)
        Some(value) => {
          let spot = as_object(value)
          let inner = opt_f64(spot, "innerConeAngle", 0.0)
          let outer = opt_f64(spot, "outerConeAngle", @std.PI / 4.0)
          let softness = if outer == 0.0 { 0.0 } else { 1.0 - inner / outer }
          (outer, softness)
        }
      }
    _ => (@std.PI / 3.0, 0.0)
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
  {
    kind,
    r,
    g,
    b,
    intensity: opt_f64(obj, "intensity", 1.0),
    distance,
    angle,
    penumbra,
    name,
  }
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
  match light.kind {
    Directional => {
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
    Point => {
      let bulb = @lights.PointLight::new(
        intensity=light.intensity,
        distance=light.distance,
      )
      ignore(bulb.node.position.set(0.0, 0.0, 0.0))
      match bulb.node.light {
        None => ()
        Some(state) => ignore(state.color.set_rgb(light.r, light.g, light.b))
      }
      bulb.node.name = light.name
      bulb.node
    }
    Spot => {
      let lamp = @lights.SpotLight::new(
        intensity=light.intensity,
        distance=light.distance,
        angle=light.angle,
        penumbra=light.penumbra,
      )
      ignore(lamp.node.position.set(0.0, 0.0, 0.0))
      match lamp.node.light {
        None => ()
        Some(state) => ignore(state.color.set_rgb(light.r, light.g, light.b))
      }
      ignore(lamp.target.position.set(0.0, 0.0, -1.0))
      ignore(lamp.node.add(lamp.target))
      lamp.node.name = light.name
      lamp.node
    }
  }
}

///|
priv struct SkinDef {
  joints : Array[Int]
  inverses : Array[@math.Matrix4]
}

///|
priv struct PendingSkin {
  node : @core.Object3D
  skin : Int
  joints : Array[Int]
  weights : Array[Double]
}

///|
/// 关节下标指向节点。`inverseBindMatrices` 缺省是单位矩阵，数量少于关节时拒绝。
/// r186: `loadSkin` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L4052
fn load_skins(
  root : Map[String, Json],
  bins : Array[Bin],
  views : Array[View],
  accs : Array[Acc],
) -> Array[SkinDef] raise GltfError {
  let listed = objects(root, "skins")
  let out = []
  let mut i = 0
  while i < listed.length() {
    out.push(load_skin(listed[i], bins, views, accs))
    i = i + 1
  }
  out
}

///|
fn load_skin(
  obj : Map[String, Json],
  bins : Array[Bin],
  views : Array[View],
  accs : Array[Acc],
) -> SkinDef raise GltfError {
  let joints = match obj.get("joints") {
    None => raise GltfError::Invalid("skin joints")
    Some(value) => as_ints(value)
  }
  let inverses = match obj.get("inverseBindMatrices") {
    None => identity_matrices(joints.length())
    Some(value) => {
      let matrices = read_values(bins, views, accs, as_f64(value).to_int(), 16)
      let count = matrices.length() / 16
      if count < joints.length() {
        raise GltfError::Invalid("inverseBindMatrices")
      }
      let out = []
      let mut index = 0
      while index < joints.length() {
        out.push(matrix_from(matrices, index * 16))
        index = index + 1
      }
      out
    }
  }
  { joints, inverses, }
}

///|
fn matrix_from(values : Array[Double], offset : Int) -> @math.Matrix4 {
  let m = @math.Matrix4::new()
  let mut i = 0
  while i < 16 {
    m.elements[i] = values[offset + i]
    i = i + 1
  }
  m
}

///|
fn identity_matrices(count : Int) -> Array[@math.Matrix4] {
  let out = []
  let mut index = 0
  while index < count {
    out.push(@math.Matrix4::new())
    index = index + 1
  }
  out
}

///|
/// 先读 `JOINTS_0` 和 `WEIGHTS_0`。缺一则不蒙皮。
/// r186 的属性表没有 `JOINTS_1`、`JOINTS_2` 和 `JOINTS_3`。后一组只有在前一组两个属性都在时才按同样的规则再读四个影响。
/// r186: `JOINTS_0` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L2287
fn read_skin_attributes(
  attrs : Map[String, Json],
  bins : Array[Bin],
  views : Array[View],
  accs : Array[Acc],
  geometry : @core.BufferGeometry,
) -> (Array[Int]?, Array[Double]?) raise GltfError {
  match (attrs.get("JOINTS_0"), attrs.get("WEIGHTS_0")) {
    (Some(joints), Some(weights)) => {
      let joint_index = as_f64(joints).to_int()
      let weight_index = as_f64(weights).to_int()
      let joint_values = read_joints(bins, views, accs, joint_index, "JOINTS_0")
      let weight_values = read_weights(
        bins, views, accs, weight_index, "WEIGHTS_0",
      )
      let count = match geometry.get_attribute("position") {
        None => 0
        Some(attribute) => attribute.count
      }
      if joint_values.length() != count * 4 ||
        weight_values.length() != count * 4 {
        raise GltfError::Invalid("skin attributes")
      }
      let mut packed_joints = joint_values
      let mut packed_weights = weight_values
      let mut width = 4
      let mut set = 1
      while set <= 3 {
        let joint_name = "JOINTS_\{set}"
        let weight_name = "WEIGHTS_\{set}"
        match (attrs.get(joint_name), attrs.get(weight_name)) {
          (Some(extra_joints), Some(extra_weights)) => {
            let more_joints = read_joints(
              bins,
              views,
              accs,
              as_f64(extra_joints).to_int(),
              joint_name,
            )
            let more_weights = read_weights(
              bins,
              views,
              accs,
              as_f64(extra_weights).to_int(),
              weight_name,
            )
            if more_joints.length() != count * 4 ||
              more_weights.length() != count * 4 {
              raise GltfError::Invalid("skin attributes")
            }
            packed_joints = append_ints(
              packed_joints, more_joints, count, width,
            )
            packed_weights = append_doubles(
              packed_weights, more_weights, count, width,
            )
            width = width + 4
            set = set + 1
          }
          _ => set = 4
        }
      }
      (Some(packed_joints), Some(packed_weights))
    }
    _ => (None, None)
  }
}

///|
fn accessor_at(accs : Array[Acc], index : Int) -> Acc raise GltfError {
  if index < 0 || index >= accs.length() {
    raise GltfError::Invalid("accessor index")
  }
  accs[index]
}

///|
fn read_joints(
  bins : Array[Bin],
  views : Array[View],
  accs : Array[Acc],
  index : Int,
  name : String,
) -> Array[Int] raise GltfError {
  let acc = accessor_at(accs, index)
  if acc.normalized ||
    (acc.component_type != 5121 && acc.component_type != 5123) {
    raise GltfError::Invalid(name)
  }
  let values = read_values(bins, views, accs, index, 4)
  let out = []
  let mut i = 0
  while i < values.length() {
    out.push(values[i].to_int())
    i = i + 1
  }
  out
}

///|
fn read_weights(
  bins : Array[Bin],
  views : Array[View],
  accs : Array[Acc],
  index : Int,
  name : String,
) -> Array[Double] raise GltfError {
  let acc = accessor_at(accs, index)
  let float_weights = acc.component_type == 5126 && !acc.normalized
  let byte_weights = (acc.component_type == 5121 || acc.component_type == 5123) &&
    acc.normalized
  if !float_weights && !byte_weights {
    raise GltfError::Invalid(name)
  }
  read_values(bins, views, accs, index, 4)
}

///|
fn check_skin_joints(
  skins : Array[SkinDef],
  node_count : Int,
) -> Unit raise GltfError {
  let mut i = 0
  while i < skins.length() {
    let joints = skins[i].joints
    let mut j = 0
    while j < joints.length() {
      let index = joints[j]
      if index < 0 || index >= node_count {
        raise GltfError::Invalid("skin joint")
      }
      j = j + 1
    }
    i = i + 1
  }
}

///|
/// 形变和蒙皮可以同时在。蒙皮写入时会先加上当前形变权重。
fn remember_skin(
  pending : Array[PendingSkin],
  node : @core.Object3D,
  skin : Int,
  prim : Prim,
) -> Unit {
  match prim.joints {
    None => ()
    Some(joints) =>
      match prim.weights {
        None => ()
        Some(weights) => pending.push({ node, skin, joints, weights, })
      }
  }
}

///|
fn bind_pending(
  pending : Array[PendingSkin],
  skins : Array[SkinDef],
  built : Array[@core.Object3D],
) -> Unit raise GltfError {
  let mut i = 0
  while i < pending.length() {
    let item = pending[i]
    if item.skin < 0 || item.skin >= skins.length() {
      raise GltfError::Invalid("skin index")
    }
    let def = skins[item.skin]
    let joint_nodes = []
    let mut j = 0
    while j < def.joints.length() {
      joint_nodes.push(built[def.joints[j]])
      j = j + 1
    }
    bind_skin(item.node, joint_nodes, def.inverses, item.joints, item.weights)
    i = i + 1
  }
}

///|
/// 每个蒙皮原语复制一份几何，避免改到共用这份网格的节点。
/// 绑定矩阵是单位矩阵。
/// r186: `bind` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L230 ; `loadNode` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L4297
fn bind_skin(
  node : @core.Object3D,
  joints : Array[@core.Object3D],
  inverses : Array[@math.Matrix4],
  indices : Array[Int],
  weights : Array[Double],
) -> Unit {
  match node.mesh {
    None => ()
    Some(binding) => {
      let geometry = binding.geometry.clone()
      binding.geometry = geometry
      match node.morph {
        None => ()
        Some(state) => state.shared = false
      }
      let count = match geometry.get_attribute("position") {
        None => 0
        Some(attribute) => attribute.count
      }
      node.skin = Some(@core.SkinState::{
        joints,
        inverse_binds: inverses,
        bind_position: copied_attribute(geometry, "position"),
        bind_normal: optional_attribute(geometry, "normal"),
        indices,
        weights: normalized_skin_weights(weights, count),
      })
    }
  }
}

///|
/// 每个顶点的全部影响按绝对值之和缩放到 1。全是 0 时第一个写成 1，其余写成 0。
/// r186: `normalizeSkinWeights` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L262
fn normalized_skin_weights(
  weights : Array[Double],
  count : Int,
) -> Array[Double] {
  let out = weights.copy()
  let stride = if count <= 0 {
    4
  } else {
    let width = out.length() / count
    if width <= 0 {
      4
    } else {
      width
    }
  }
  let mut vertex = 0
  while vertex < count {
    let mut sum = 0.0
    let mut influence = 0
    while influence < stride {
      let weight = out[vertex * stride + influence]
      let absolute = if weight < 0.0 { -weight } else { weight }
      sum = sum + absolute
      influence = influence + 1
    }
    if sum == 0.0 {
      influence = 0
      while influence < stride {
        let at = vertex * stride + influence
        out[at] = if influence == 0 { 1.0 } else { 0.0 }
        influence = influence + 1
      }
    } else {
      let scale = 1.0 / sum
      influence = 0
      while influence < stride {
        let at = vertex * stride + influence
        out[at] = out[at] * scale
        influence = influence + 1
      }
    }
    vertex = vertex + 1
  }
  out
}

///|
fn append_ints(
  base : Array[Int],
  extra : Array[Int],
  count : Int,
  width : Int,
) -> Array[Int] {
  let out = []
  let mut vertex = 0
  while vertex < count {
    let mut influence = 0
    while influence < width {
      out.push(base[vertex * width + influence])
      influence = influence + 1
    }
    influence = 0
    while influence < 4 {
      out.push(extra[vertex * 4 + influence])
      influence = influence + 1
    }
    vertex = vertex + 1
  }
  out
}

///|
fn append_doubles(
  base : Array[Double],
  extra : Array[Double],
  count : Int,
  width : Int,
) -> Array[Double] {
  let out = []
  let mut vertex = 0
  while vertex < count {
    let mut influence = 0
    while influence < width {
      out.push(base[vertex * width + influence])
      influence = influence + 1
    }
    influence = 0
    while influence < 4 {
      out.push(extra[vertex * 4 + influence])
      influence = influence + 1
    }
    vertex = vertex + 1
  }
  out
}

///|
fn build_nodes(
  nodes : Array[NodeDesc],
  meshes : Array[Array[Prim]],
  cameras : Array[Cam],
  lights : Array[Punctual],
  skins : Array[SkinDef],
) -> Array[@core.Object3D] raise GltfError {
  check_skin_joints(skins, nodes.length())
  let pending : Array[PendingSkin] = []
  let built = []
  let mut i = 0
  while i < nodes.length() {
    let desc = nodes[i]
    match desc.skin {
      None => ()
      Some(index) =>
        if index < 0 || index >= skins.length() {
          raise GltfError::Invalid("skin index")
        }
    }
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
          let mesh = mesh_from(prims[p], desc.weights)
          match desc.skin {
            None => ()
            Some(skin_index) =>
              remember_skin(pending, mesh.node, skin_index, prims[p])
          }
          parts.push(mesh.node)
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
  bind_pending(pending, skins, built)
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
fn copied_attribute(
  geometry : @core.BufferGeometry,
  name : String,
) -> Array[Double] {
  match optional_attribute(geometry, name) {
    None => []
    Some(values) => values
  }
}

///|
fn optional_attribute(
  geometry : @core.BufferGeometry,
  name : String,
) -> Array[Double]? {
  match geometry.get_attribute(name) {
    None => None
    Some(attribute) => Some(attribute.array.copy())
  }
}

///|
fn core_targets(targets : Array[MorphTarget]) -> Array[@core.MorphTarget] {
  let out = []
  for target in targets {
    out.push(@core.MorphTarget::{
      position: target.position,
      normal: target.normal,
      color: target.color,
    })
  }
  out
}

///|
fn morph_count(node : @core.Object3D) -> Int? {
  match node.morph {
    Some(state) => Some(state.targets.length())
    None => {
      let mut count = -1
      for child in node.children {
        match child.morph {
          Some(state) => count = state.targets.length()
          None => ()
        }
      }
      if count < 0 {
        None
      } else {
        Some(count)
      }
    }
  }
}

///|
/// 没有形变目标时不建轨道。输出按目标个数切分，`CUBICSPLINE` 仍是三份。
/// r186: `_createAnimationTracks` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L4579
fn weights_track(
  node_name : String,
  bins : Array[Bin],
  views : Array[View],
  accs : Array[Acc],
  samplers : Array[Map[String, Json]],
  channel : Map[String, Json],
  count : Int,
) -> @animation.KeyframeTrack raise GltfError {
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
  let output = read_values(
    bins,
    views,
    accs,
    require_f64(sampler, "output").to_int(),
    1,
  )
  let copies = match kind {
    Cubic => 3
    _ => 1
  }
  if times.length() == 0 || output.length() != times.length() * count * copies {
    raise GltfError::Invalid("animation output")
  }
  let name = node_name + ".morphTargetInfluences"
  let track = match kind {
    Cubic => @animation.KeyframeTrack::cubic_numbers(name, times, output, count)
    _ => @animation.KeyframeTrack::numbers(name, times, output, count)
  }
  match kind {
    Step => track.interpolation = @constants.Interpolation::Discrete
    _ => ()
  }
  track
}

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
        if node_name != "" && path == "weights" {
          match morph_count(built[node_index]) {
            None => ()
            Some(count) =>
              tracks.push(
                weights_track(
                  node_name, bins, views, accs, samplers, channel, count,
                ),
              )
          }
        } else if node_name != "" && path != "weights" {
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
