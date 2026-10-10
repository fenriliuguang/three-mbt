// r186: `Mesh` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L39

///|
using @core {
  type Object3D,
  type BufferAttribute,
  type BufferGeometry,
  type MeshBinding,
}

///|
/// 用来把若干节点当作一个整体变换。
/// r186: `Group` https://github.com/mrdoob/three.js/blob/r186/src/objects/Group.js#L20
pub(all) struct Group {
  node : Object3D
}

///|
pub fn Group::new() -> Group {
  { node: Object3D::new(kind=@core.Group), }
}

///|
pub impl @core.AsNode for Group with fn to_node(self) {
  self.node
}

///|
pub extend Group with @core.AsNode::{to_node}

///|
pub fn[T : @core.AsNode] Group::add(self : Group, child : T) -> Group {
  ignore(self.node.add(child.to_node()))
  self
}

///|
/// 三角网格。`geometry` 与 `material.color` 同时挂在场景节点上，遍历时可以读到。
/// r186: `Mesh` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L39
pub(all) struct Mesh {
  node : Object3D
  geometry : BufferGeometry
  material : @materials.Material
}

///|
pub fn Mesh::new(
  geometry : BufferGeometry,
  material : @materials.Material,
) -> Mesh {
  let node = Object3D::new(kind=@core.Mesh)
  let mesh : Mesh = { node, geometry, material, }
  mesh.refresh()
  mesh
}

///|
pub impl @core.AsNode for Mesh with fn to_node(self) {
  self.node
}

///|
pub extend Mesh with @core.AsNode::{to_node}

///|
/// 把材质上的侧面、透明度、线框、贴图、粗糙度和金属度写回节点。颜色本身是共享的，不需要复制。
pub fn Mesh::refresh(self : Mesh) -> Unit {
  self.node.mesh = Some(MeshBinding::{
    geometry: self.geometry,
    color: self.material.color,
    shading: self.material.shading(),
    side: self.material.side,
    opacity: self.material.opacity,
    transparent: self.material.transparent,
    wireframe: self.material.wireframe,
    map: self.material.map,
    roughness: self.material.roughness,
    metalness: self.material.metalness,
    fog: self.material.fog,
    instances: None,
  })
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
  opacity? : Double = 1.0,
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
  transparent : Bool,
  fog : Bool,
) -> @core.PrimitiveBinding {
  { geometry, color, kind, size, size_attenuation, opacity, transparent, fog, }
}

///|
/// 点。每个位置画一个朝向相机的四边形。
/// r186: `Points` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L19
pub(all) struct Points {
  node : Object3D
  geometry : BufferGeometry
  material : @materials.PointsMaterial
}

///|
pub fn Points::new(
  geometry : BufferGeometry,
  material : @materials.PointsMaterial,
) -> Points {
  let node = Object3D::new(kind=@core.NodeKind::Points)
  let points : Points = { node, geometry, material, }
  points.refresh()
  points
}

///|
pub impl @core.AsNode for Points with fn to_node(self) {
  self.node
}

///|
pub extend Points with @core.AsNode::{to_node}

///|
pub fn Points::refresh(self : Points) -> Unit {
  self.node.primitive = Some(
    primitive_binding(
      self.geometry,
      self.material.color,
      @core.PrimitiveKind::Points,
      self.material.size,
      self.material.size_attenuation,
      self.material.opacity,
      self.material.transparent,
      self.material.fog,
    ),
  )
}

///|
pub fn Points::set_fog(self : Points, enabled : Bool) -> Unit {
  self.material.fog = enabled
  self.refresh()
}

///|
/// 折线，对应 r186 的 `Line`。
/// r186: `Line` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L41
pub(all) struct Line {
  node : Object3D
  geometry : BufferGeometry
  material : @materials.LineBasicMaterial
}

///|
pub fn Line::new(
  geometry : BufferGeometry,
  material : @materials.LineBasicMaterial,
) -> Line {
  let node = Object3D::new(kind=@core.NodeKind::Line)
  let line : Line = { node, geometry, material, }
  line.refresh()
  line
}

///|
pub impl @core.AsNode for Line with fn to_node(self) {
  self.node
}

///|
pub extend Line with @core.AsNode::{to_node}

///|
pub fn Line::refresh(self : Line) -> Unit {
  self.node.primitive = Some(
    primitive_binding(
      self.geometry,
      self.material.color,
      @core.PrimitiveKind::Line,
      1.0,
      false,
      self.material.opacity,
      self.material.transparent,
      self.material.fog,
    ),
  )
}

///|
pub fn Line::set_fog(self : Line, enabled : Bool) -> Unit {
  self.material.fog = enabled
  self.refresh()
}

///|
/// 成对线段，对应 r186 的 `LineSegments`。
/// r186: `LineSegments` https://github.com/mrdoob/three.js/blob/r186/src/objects/LineSegments.js#L14
pub(all) struct LineSegments {
  node : Object3D
  geometry : BufferGeometry
  material : @materials.LineBasicMaterial
}

///|
pub fn LineSegments::new(
  geometry : BufferGeometry,
  material : @materials.LineBasicMaterial,
) -> LineSegments {
  let node = Object3D::new(kind=@core.NodeKind::LineSegments)
  let line : LineSegments = { node, geometry, material, }
  line.refresh()
  line
}

///|
pub impl @core.AsNode for LineSegments with fn to_node(self) {
  self.node
}

///|
pub extend LineSegments with @core.AsNode::{to_node}

///|
pub fn LineSegments::refresh(self : LineSegments) -> Unit {
  self.node.primitive = Some(
    primitive_binding(
      self.geometry,
      self.material.color,
      @core.PrimitiveKind::LineSegments,
      1.0,
      false,
      self.material.opacity,
      self.material.transparent,
      self.material.fog,
    ),
  )
}

///|
pub fn LineSegments::set_fog(self : LineSegments, enabled : Bool) -> Unit {
  self.material.fog = enabled
  self.refresh()
}

///|
fn identity_matrices(count : Int) -> BufferAttribute {
  let array = []
  let mut index = 0
  while index < count {
    array.push(1.0)
    array.push(0.0)
    array.push(0.0)
    array.push(0.0)
    array.push(0.0)
    array.push(1.0)
    array.push(0.0)
    array.push(0.0)
    array.push(0.0)
    array.push(0.0)
    array.push(1.0)
    array.push(0.0)
    array.push(0.0)
    array.push(0.0)
    array.push(0.0)
    array.push(1.0)
    index = index + 1
  }
  BufferAttribute::new(array, 16)
}

///|
fn write_matrix(
  attribute : BufferAttribute,
  index : Int,
  matrix : @math.Matrix4,
) -> Unit {
  let offset = index * attribute.item_size
  let mut component = 0
  while component < 16 {
    attribute.array[offset + component] = matrix.elements[component]
    component = component + 1
  }
}

///|
fn read_matrix(
  attribute : BufferAttribute,
  index : Int,
  target : @math.Matrix4,
) -> Unit {
  let offset = index * attribute.item_size
  let mut component = 0
  while component < 16 {
    target.elements[component] = attribute.array[offset + component]
    component = component + 1
  }
}

///|
/// 同一几何体画多次。实例矩阵在物体矩阵之前相乘，和 r186 `InstancedMesh` 一样。
/// 没有 `instanceColor` 时渲染器使用白色。默认不做视锥裁剪。
/// r186: `InstancedMesh` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L28
pub(all) struct InstancedMesh {
  node : Object3D
  geometry : BufferGeometry
  material : @materials.Material
  instances : @core.InstanceData
  mut bounding_box : @math.Box3?
}

///|
pub fn InstancedMesh::new(
  geometry : BufferGeometry,
  material : @materials.Material,
  count : Int,
) -> InstancedMesh {
  let node = Object3D::new(kind=@core.Mesh)
  node.frustum_culled = false
  let instances : @core.InstanceData = {
    matrices: identity_matrices(count),
    colors: None,
    count,
    version: 0,
  }
  let mesh : InstancedMesh = {
    node,
    geometry,
    material,
    instances,
    bounding_box: None,
  }
  mesh.refresh()
  mesh
}

///|
pub impl @core.AsNode for InstancedMesh with fn to_node(self) {
  self.node
}

///|
pub extend InstancedMesh with @core.AsNode::{to_node}

///|
pub fn InstancedMesh::refresh(self : InstancedMesh) -> Unit {
  self.node.mesh = Some(MeshBinding::{
    geometry: self.geometry,
    color: self.material.color,
    shading: self.material.shading(),
    side: self.material.side,
    opacity: self.material.opacity,
    transparent: self.material.transparent,
    wireframe: self.material.wireframe,
    map: self.material.map,
    roughness: self.material.roughness,
    metalness: self.material.metalness,
    fog: self.material.fog,
    instances: Some(self.instances),
  })
}

///|
pub fn InstancedMesh::set_side(
  self : InstancedMesh,
  side : @constants.Side,
) -> Unit {
  self.material.side = side
  self.refresh()
}

///|
pub fn InstancedMesh::set_fog(self : InstancedMesh, enabled : Bool) -> Unit {
  self.material.fog = enabled
  self.refresh()
}

///|
/// 与 `Mesh::set_transparent` 相同。整个实例网格当作一个物体排序。
pub fn InstancedMesh::set_transparent(
  self : InstancedMesh,
  enabled : Bool,
  opacity? : Double = 1.0,
) -> Unit {
  self.material.transparent = enabled
  self.material.opacity = opacity
  self.refresh()
}

///|
pub fn InstancedMesh::set_map(
  self : InstancedMesh,
  map : @textures.Texture?,
) -> Unit {
  self.material.map = map
  self.refresh()
}

///|
/// 把绘制个数限制在矩阵容量以内。
pub fn InstancedMesh::set_count(self : InstancedMesh, count : Int) -> Unit {
  let capacity = self.instances.matrices.count
  self.instances.count = if count < 0 {
    0
  } else if count > capacity {
    capacity
  } else {
    count
  }
}

///|
/// r186: `setMatrixAt` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L104
pub fn InstancedMesh::set_matrix_at(
  self : InstancedMesh,
  index : Int,
  matrix : @math.Matrix4,
) -> Unit {
  write_matrix(self.instances.matrices, index, matrix)
  self.instances.version = self.instances.version + 1
}

///|
pub fn InstancedMesh::get_matrix_at(
  self : InstancedMesh,
  index : Int,
  target : @math.Matrix4,
) -> @math.Matrix4 {
  read_matrix(self.instances.matrices, index, target)
  target
}

///|
/// 第一次调用时分配白色 `rgb`。写入的是颜色里已经存好的线性分量。
pub fn InstancedMesh::set_color_at(
  self : InstancedMesh,
  index : Int,
  color : @math.Color,
) -> Unit {
  let colors = match self.instances.colors {
    Some(colors) => colors
    None => {
      let array = []
      let mut item = 0
      while item < self.instances.matrices.count {
        array.push(1.0)
        array.push(1.0)
        array.push(1.0)
        item = item + 1
      }
      let colors = BufferAttribute::new(array, 3)
      self.instances.colors = Some(colors)
      colors
    }
  }
  colors.set_xyz(index, color.r, color.g, color.b)
  self.instances.version = self.instances.version + 1
}

///|
pub fn InstancedMesh::get_color_at(
  self : InstancedMesh,
  index : Int,
  target : @math.Color,
) -> @math.Color {
  match self.instances.colors {
    None => target.set_rgb(1.0, 1.0, 1.0)
    Some(colors) =>
      target.set_rgb(
        colors.get_x(index),
        colors.get_y(index),
        colors.get_z(index),
      )
  }
}

///|
/// 局部包围盒：几何体包围盒按每个实例矩阵变换后再求并。
/// r186: `computeBoundingBox` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L115
pub fn InstancedMesh::compute_bounding_box(self : InstancedMesh) -> @math.Box3 {
  self.geometry.compute_bounding_box()
  let box = match self.bounding_box {
    Some(box) => box
    None => {
      let box = @math.Box3::empty()
      self.bounding_box = Some(box)
      box
    }
  }
  ignore(box.make_empty())
  match self.geometry.bounding_box {
    None => ()
    Some(geometry_box) => {
      let matrix = @math.Matrix4::new()
      let mut index = 0
      while index < self.instances.count {
        ignore(self.get_matrix_at(index, matrix))
        let transformed = @math.Box3::new(geometry_box.min, geometry_box.max)
        ignore(transformed.apply_matrix4(matrix))
        ignore(box.union(transformed))
        index = index + 1
      }
    }
  }
  box
}
