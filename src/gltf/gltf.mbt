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
}

///|
priv struct Prim {
  geometry : @core.BufferGeometry
  mat : Mat
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
}

///|
/// 从 glTF 2.0 JSON 读出默认场景。
///
/// 缓冲来自 `data:` URI 的 base64。第 0 个缓冲没有 URI 时，用 `bin` 填上。
/// 只建 `TRIANGLES` 网格：`POSITION`、`NORMAL`、`TEXCOORD_0` 和索引。
/// 材质写成 `MeshStandardMaterial`，`baseColorFactor` 按线性通道写入，
/// 再带上粗糙度、金属度和 `doubleSided`。
/// 贴图、蒙皮、形变、动画、相机和灯光先不读。
pub fn parse(
  text : String,
  bin? : Bytes = b"",
) -> @objects.Group raise GltfError {
  let root = as_object(parse_json(text))
  check_version(root)
  let bins = load_buffers(root, bin)
  let views = load_views(root)
  let accs = load_accessors(root)
  let materials = load_materials(root)
  let meshes = load_meshes(root, bins, views, accs, materials)
  let nodes = load_nodes(root)
  let built = build_nodes(nodes, meshes)
  link_children(nodes, built)
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
  group
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
  { geometry, mat, }
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
    let built = []
    let mut p = 0
    while p < prims.length() {
      built.push(
        load_primitive(as_object(prims[p]), bins, views, accs, materials),
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
  let children = match obj.get("children") {
    None => []
    Some(value) => as_ints(value)
  }
  {
    name: opt_string(obj, "name", ""),
    children,
    mesh,
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
fn mesh_from(prim : Prim) -> @objects.Mesh {
  let standard = @materials.MeshStandardMaterial::new(
    roughness=prim.mat.roughness,
    metalness=prim.mat.metalness,
  )
  ignore(standard.material.color.set_rgb(prim.mat.r, prim.mat.g, prim.mat.b))
  standard.material.opacity = prim.mat.opacity
  standard.material.transparent = prim.mat.transparent
  let mesh = @objects.Mesh::new(prim.geometry, standard.material)
  if prim.mat.double_sided {
    mesh.set_side(@constants.Side::Double)
  }
  mesh
}

///|
fn build_nodes(
  nodes : Array[NodeDesc],
  meshes : Array[Array[Prim]],
) -> Array[@core.Object3D] raise GltfError {
  let built = []
  let mut i = 0
  while i < nodes.length() {
    let desc = nodes[i]
    let node = match desc.mesh {
      None => {
        let group = @objects.Group::new()
        apply_transform(group.node, desc)
        group.node
      }
      Some(index) => {
        if index < 0 || index >= meshes.length() {
          raise GltfError::Invalid("mesh index")
        }
        let prims = meshes[index]
        if prims.length() == 1 {
          let mesh = mesh_from(prims[0])
          apply_transform(mesh.node, desc)
          mesh.node
        } else {
          let group = @objects.Group::new()
          apply_transform(group.node, desc)
          let mut p = 0
          while p < prims.length() {
            ignore(group.add(mesh_from(prims[p])))
            p = p + 1
          }
          group.node
        }
      }
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
