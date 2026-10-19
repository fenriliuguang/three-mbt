// r186: `Group` https://github.com/mrdoob/three.js/blob/r186/src/objects/Group.js#L20 ; `Mesh` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L39 ; `Points` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L19 ; `Line` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L41 ; `LineSegments` https://github.com/mrdoob/three.js/blob/r186/src/objects/LineSegments.js#L14 ; `LineLoop` https://github.com/mrdoob/three.js/blob/r186/src/objects/LineLoop.js#L10 ; `InstancedMesh` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L28 ; `Sprite` https://github.com/mrdoob/three.js/blob/r186/src/objects/Sprite.js#L47 ; `LOD` https://github.com/mrdoob/three.js/blob/r186/src/objects/LOD.js#L33

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
/// 三角网格。`geometry` 与 `material.color` 同时挂在场景节点上，遍历时可以读到。`count` 默认是 `1`。
/// r186: `Mesh` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L39
/// r186: `count` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L104
pub(all) struct Mesh {
  node : Object3D
  mut geometry : BufferGeometry
  mut material : @materials.Material
  mut count : Int
}

///|
pub fn Mesh::new(
  geometry : BufferGeometry,
  material : @materials.Material,
) -> Mesh {
  let node = Object3D::new(kind=@core.Mesh)
  let mesh : Mesh = { node, geometry, material, count: 1, }
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
/// 复制变换、几何体和材质。几何体与材质沿用源对象。形变权重留在后面。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L110
pub fn Mesh::copy(
  self : Mesh,
  source : Mesh,
  recursive? : Bool = true,
) -> Mesh {
  ignore(self.node.copy(source.node, recursive~))
  self.geometry = source.geometry
  self.material = source.material
  self.refresh()
  self
}

///|
/// 新建一份网格再复制。three.js 没有单独的 `Mesh.clone`，用的是 `Object3D.clone`。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1592
pub fn Mesh::clone(self : Mesh, recursive? : Bool = true) -> Mesh {
  Mesh::new(self.geometry, self.material).copy(self, recursive~)
}

///|
/// 把材质上的侧面、透明度、线框、透明裁切、自发光、贴图、粗糙度贴图、金属度贴图、透明贴图、粗糙度和金属度写回节点。颜色本身是共享的，不需要复制。
pub fn Mesh::refresh(self : Mesh) -> Unit {
  self.node.mesh = Some(MeshBinding::{
    geometry: self.geometry,
    color: self.material.color,
    shading: self.material.shading(),
    side: self.material.side,
    shadow_side: self.material.shadow_side,
    opacity: self.material.opacity,
    transparent: self.material.transparent,
    wireframe: self.material.wireframe,
    map: self.material.map,
    roughness: self.material.roughness,
    metalness: self.material.metalness,
    fog: self.material.fog,
    alpha_test: self.material.alpha_test,
    flat_shading: self.material.flat_shading,
    depth_write: self.material.depth_write,
    depth_test: self.material.depth_test,
    depth_func: self.material.depth_func,
    color_write: self.material.color_write,
    premultiplied_alpha: self.material.premultiplied_alpha,
    visible: self.material.visible,
    force_single_pass: self.material.force_single_pass,
    emissive: self.material.emissive,
    emissive_intensity: self.material.emissive_intensity,
    emissive_map: self.material.emissive_map,
    roughness_map: self.material.roughness_map,
    metalness_map: self.material.metalness_map,
    alpha_map: self.material.alpha_map,
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
  depth_write : Bool,
  depth_test : Bool,
  depth_func : @constants.DepthFunc,
  color_write : Bool,
  premultiplied_alpha : Bool,
  visible : Bool,
) -> @core.PrimitiveBinding {
  {
    geometry,
    color,
    kind,
    size,
    size_attenuation,
    opacity,
    transparent,
    fog,
    depth_write,
    depth_test,
    depth_func,
    color_write,
    premultiplied_alpha,
    visible,
  }
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
      self.material.depth_write,
      self.material.depth_test,
      self.material.depth_func,
      self.material.color_write,
      self.material.premultiplied_alpha,
      self.material.visible,
    ),
  )
}

///|
pub fn Points::set_fog(self : Points, enabled : Bool) -> Unit {
  self.material.fog = enabled
  self.refresh()
}

///|
/// `enabled` 为真时进入透明队列，并按 `opacity` 做 src-alpha 混合。
/// 直接改 `material.transparent` 不会更新绑定。
/// r186: `Points` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L19
pub fn Points::set_transparent(
  self : Points,
  enabled : Bool,
  opacity? : Double = 1.0,
) -> Unit {
  self.material.transparent = enabled
  self.material.opacity = opacity
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
      self.material.depth_write,
      self.material.depth_test,
      self.material.depth_func,
      self.material.color_write,
      self.material.premultiplied_alpha,
      self.material.visible,
    ),
  )
}

///|
pub fn Line::set_fog(self : Line, enabled : Bool) -> Unit {
  self.material.fog = enabled
  self.refresh()
}

///|
/// `enabled` 为真时进入透明队列，并按 `opacity` 做 src-alpha 混合。
/// 直接改 `material.transparent` 不会更新绑定。
/// r186: `Line` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L41
pub fn Line::set_transparent(
  self : Line,
  enabled : Bool,
  opacity? : Double = 1.0,
) -> Unit {
  self.material.transparent = enabled
  self.material.opacity = opacity
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
      self.material.depth_write,
      self.material.depth_test,
      self.material.depth_func,
      self.material.color_write,
      self.material.premultiplied_alpha,
      self.material.visible,
    ),
  )
}

///|
pub fn LineSegments::set_fog(self : LineSegments, enabled : Bool) -> Unit {
  self.material.fog = enabled
  self.refresh()
}

///|
/// `enabled` 为真时进入透明队列，并按 `opacity` 做 src-alpha 混合。
/// 直接改 `material.transparent` 不会更新绑定。
/// r186: `LineSegments` https://github.com/mrdoob/three.js/blob/r186/src/objects/LineSegments.js#L14
pub fn LineSegments::set_transparent(
  self : LineSegments,
  enabled : Bool,
  opacity? : Double = 1.0,
) -> Unit {
  self.material.transparent = enabled
  self.material.opacity = opacity
  self.refresh()
}

///|
/// 闭合折线。最后一点连回第一点，射线会测这段；绘制仍按折线提交。
/// r186: `LineLoop` https://github.com/mrdoob/three.js/blob/r186/src/objects/LineLoop.js#L10
pub(all) struct LineLoop {
  node : Object3D
  geometry : BufferGeometry
  material : @materials.LineBasicMaterial
}

///|
pub fn LineLoop::new(
  geometry : BufferGeometry,
  material : @materials.LineBasicMaterial,
) -> LineLoop {
  let node = Object3D::new(kind=@core.NodeKind::LineLoop)
  let line : LineLoop = { node, geometry, material, }
  line.refresh()
  line
}

///|
pub impl @core.AsNode for LineLoop with fn to_node(self) {
  self.node
}

///|
pub extend LineLoop with @core.AsNode::{to_node}

///|
pub fn LineLoop::refresh(self : LineLoop) -> Unit {
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
      self.material.depth_write,
      self.material.depth_test,
      self.material.depth_func,
      self.material.color_write,
      self.material.premultiplied_alpha,
      self.material.visible,
    ),
  )
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
  mut geometry : BufferGeometry
  mut material : @materials.Material
  instances : @core.InstanceData
  mut bounding_box : @math.Box3?
  mut bounding_sphere : @math.Sphere?
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
    bounding_sphere: None,
  }
  let mesh : InstancedMesh = {
    node,
    geometry,
    material,
    instances,
    bounding_box: None,
    bounding_sphere: None,
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
    shadow_side: self.material.shadow_side,
    opacity: self.material.opacity,
    transparent: self.material.transparent,
    wireframe: self.material.wireframe,
    map: self.material.map,
    roughness: self.material.roughness,
    metalness: self.material.metalness,
    fog: self.material.fog,
    alpha_test: self.material.alpha_test,
    flat_shading: self.material.flat_shading,
    depth_write: self.material.depth_write,
    depth_test: self.material.depth_test,
    depth_func: self.material.depth_func,
    color_write: self.material.color_write,
    premultiplied_alpha: self.material.premultiplied_alpha,
    visible: self.material.visible,
    force_single_pass: self.material.force_single_pass,
    emissive: self.material.emissive,
    emissive_intensity: self.material.emissive_intensity,
    emissive_map: self.material.emissive_map,
    roughness_map: self.material.roughness_map,
    metalness_map: self.material.metalness_map,
    alpha_map: self.material.alpha_map,
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
/// 复制变换、实例矩阵、颜色、个数和包围体。几何体与材质沿用源对象。包围盒和包围球是克隆。没有形变纹理。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L182
pub fn InstancedMesh::copy(
  self : InstancedMesh,
  source : InstancedMesh,
  recursive? : Bool = true,
) -> InstancedMesh {
  ignore(self.node.copy(source.node, recursive~))
  self.geometry = source.geometry
  self.material = source.material
  ignore(self.instances.matrices.copy(source.instances.matrices))
  self.instances.colors = match source.instances.colors {
    None => None
    Some(colors) => Some(BufferAttribute::new([], 3).copy(colors))
  }
  self.instances.count = source.instances.count
  self.instances.version = self.instances.version + 1
  let sphere = match source.bounding_sphere {
    Some(sphere) => Some(sphere.clone())
    None =>
      match source.instances.bounding_sphere {
        None => None
        Some(sphere) => Some(sphere.clone())
      }
  }
  self.instances.bounding_sphere = sphere
  self.bounding_sphere = sphere
  self.bounding_box = match source.bounding_box {
    None => None
    Some(box) => Some(box.clone())
  }
  self.refresh()
  self
}

///|
/// 新建一份网格再复制。three.js 没有单独的 `InstancedMesh.clone`，用的是 `Object3D.clone`。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1592
pub fn InstancedMesh::clone(
  self : InstancedMesh,
  recursive? : Bool = true,
) -> InstancedMesh {
  InstancedMesh::new(
    self.geometry,
    self.material,
    self.instances.matrices.count,
  ).copy(self, recursive~)
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

///|
/// 局部包围球：几何体包围球按每个实例矩阵变换后再求并。结果同时写在实例数据上。
/// r186: `computeBoundingSphere` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L151
pub fn InstancedMesh::compute_bounding_sphere(
  self : InstancedMesh,
) -> @math.Sphere {
  let sphere = self.instances.compute_bounding_sphere(self.geometry)
  self.bounding_sphere = Some(sphere)
  sphere
}

///|
/// 用这份实例包围球做视锥测试。还没算过就先算。测试用的是拷贝，局部球和几何体的球都不改。
/// three.js 没有 `InstancedMesh.intersectsFrustum`。对象自带包围球时走 `Frustum.intersectsObject` 的这条分支。
/// r186: `intersectsObject` https://github.com/mrdoob/three.js/blob/r186/src/math/Frustum.js#L146
pub fn InstancedMesh::intersects_frustum(
  self : InstancedMesh,
  frustum : @math.Frustum,
) -> Bool {
  let sphere = match self.bounding_sphere {
    Some(sphere) => sphere
    None => self.compute_bounding_sphere()
  }
  let copy = @math.Sphere::new()
  ignore(copy.copy(sphere).apply_matrix4(self.node.matrix_world))
  frustum.intersects_sphere(copy)
}

///|
/// 任一已用视锥碰到这份实例包围球则为真。`count` 为 0 时为假，也不会先去计算包围球。
/// three.js 没有 `InstancedMesh.intersectsFrustumArray`。对象自带包围球时，每个视锥走 `Frustum.intersectsObject`。
/// r186: `intersectsObject` https://github.com/mrdoob/three.js/blob/r186/src/math/FrustumArray.js#L86
pub fn InstancedMesh::intersects_frustum_array(
  self : InstancedMesh,
  frustums : @math.FrustumArray,
) -> Bool {
  for i in 0..<frustums.count {
    if self.intersects_frustum(frustums.frustums[i]) {
      return true
    }
  }
  false
}

///|
/// 所有精灵共用的单位四边形。r186 把位置和 uv 打进步长为 5 的交错缓冲。这里几何体属性是 `BufferAttribute`，所以位置和 uv 分开存放，数值与索引相同。
/// r186: `geometry` https://github.com/mrdoob/three.js/blob/r186/src/objects/Sprite.js#L93
let shared_sprite_geometry : Ref[BufferGeometry?] = Ref::Ref(None)

///|
fn sprite_geometry() -> BufferGeometry {
  match shared_sprite_geometry.val {
    Some(geometry) => geometry
    None => {
      let geometry = BufferGeometry::new()
      ignore(
        geometry.set_attribute(
          "position",
          BufferAttribute::new(
            [
              -0.5, -0.5, 0.0, 0.5, -0.5, 0.0, 0.5, 0.5, 0.0, -0.5, 0.5, 0.0,
            ],
            3,
          ),
        ),
      )
      ignore(
        geometry.set_attribute(
          "uv",
          BufferAttribute::new(
            [0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0],
            2,
          ),
        ),
      )
      ignore(geometry.set_index_array([0, 1, 2, 0, 2, 3]))
      shared_sprite_geometry.val = Some(geometry)
      geometry
    }
  }
}

///|
/// 始终朝向相机的四边形。`center` 与节点上的锚点是同一个向量，默认 `(0.5, 0.5)`。几何体是所有精灵共用的那一份。`count` 默认是 `1`。
/// r186: `Sprite` https://github.com/mrdoob/three.js/blob/r186/src/objects/Sprite.js#L47
/// r186: `center` https://github.com/mrdoob/three.js/blob/r186/src/objects/Sprite.js#L110
/// r186: `geometry` https://github.com/mrdoob/three.js/blob/r186/src/objects/Sprite.js#L93
/// r186: `count` https://github.com/mrdoob/three.js/blob/r186/src/objects/Sprite.js#L119
pub(all) struct Sprite {
  node : Object3D
  material : @materials.SpriteMaterial
  center : @math.Vector2
  geometry : BufferGeometry
  mut count : Int
}

///|
pub fn Sprite::new(material : @materials.SpriteMaterial) -> Sprite {
  let node = Object3D::new(kind=@core.NodeKind::Sprite)
  let center = @math.Vector2::new(x=0.5, y=0.5)
  node.sprite = Some(@core.SpriteState::{
    center,
    rotation: material.rotation,
    size_attenuation: material.size_attenuation,
  })
  { node, material, center, geometry: sprite_geometry(), count: 1, }
}

///|
pub impl @core.AsNode for Sprite with fn to_node(self) {
  self.node
}

///|
pub extend Sprite with @core.AsNode::{to_node}

///|
/// 把材质上的旋转和尺寸衰减写回节点。直接改这两个字段不会更新射线用的状态。锚点是共享的。
pub fn Sprite::refresh(self : Sprite) -> Unit {
  match self.node.sprite {
    None => ()
    Some(state) => {
      state.rotation = self.material.rotation
      state.size_attenuation = self.material.size_attenuation
    }
  }
}

///|
/// 用世界矩阵变换一个包围球，再交给视锥。球心从原点出发，半径是 `sqrt(2) / 2` 加上锚点到 `(0.5, 0.5)` 的距离。
/// r186: `intersectsFrustum` https://github.com/mrdoob/three.js/blob/r186/src/objects/Sprite.js#L129
/// r186: `intersectsSprite` https://github.com/mrdoob/three.js/blob/r186/src/math/Frustum.js#L174
pub fn Sprite::intersects_frustum(
  self : Sprite,
  frustum : @math.Frustum,
) -> Bool {
  let sphere = @math.Sphere::new(radius=0.0)
  let offset = @math.Vector2::new(x=0.5, y=0.5).distance_to(self.center)
  sphere.radius = 0.7071067811865476 + offset
  ignore(sphere.apply_matrix4(self.node.matrix_world))
  frustum.intersects_sphere(sphere)
}

///|
/// 任一已用视锥碰到这张精灵则为真。`count` 为 0 时为假。
/// r186: `intersectsSprite` https://github.com/mrdoob/three.js/blob/r186/src/math/FrustumArray.js#L108
pub fn Sprite::intersects_frustum_array(
  self : Sprite,
  frustums : @math.FrustumArray,
) -> Bool {
  for i in 0..<frustums.count {
    if self.intersects_frustum(frustums.frustums[i]) {
      return true
    }
  }
  false
}

///|
/// 按距离切换显示的对象。级别从近到远排列，`auto_update` 默认真。节点上的级别数组与 `levels` 是同一份。
/// r186: `LOD` https://github.com/mrdoob/three.js/blob/r186/src/objects/LOD.js#L33
pub(all) struct LOD {
  node : Object3D
  mut levels : Array[@core.LodLevel]
  mut auto_update : Bool
  mut current_level : Int
}

///|
fn LOD::write_levels(self : LOD, levels : Array[@core.LodLevel]) -> Unit {
  self.levels = levels
  self.node.lod_levels = Some(levels)
}

///|
pub fn LOD::new() -> LOD {
  let levels : Array[@core.LodLevel] = []
  let node = Object3D::new(kind=@core.NodeKind::LOD)
  node.lod_levels = Some(levels)
  { node, levels, auto_update: true, current_level: 0, }
}

///|
pub impl @core.AsNode for LOD with fn to_node(self) {
  self.node
}

///|
pub extend LOD with @core.AsNode::{to_node}

///|
/// 按距离插入一级，并把它加为子节点。负距离取绝对值。相等距离排在已有级别之后。
/// r186: `addLevel` https://github.com/mrdoob/three.js/blob/r186/src/objects/LOD.js#L116
pub fn LOD::add_level(
  self : LOD,
  object : Object3D,
  distance? : Double = 0.0,
  hysteresis? : Double = 0.0,
) -> LOD {
  let distance = distance.abs()
  let mut index = 0
  let count = self.levels.length()
  while index < count {
    if distance < self.levels[index].distance {
      break
    }
    index = index + 1
  }
  let next : Array[@core.LodLevel] = []
  let mut i = 0
  while i < index {
    next.push(self.levels[i])
    i = i + 1
  }
  next.push({ object, distance, hysteresis })
  while i < count {
    next.push(self.levels[i])
    i = i + 1
  }
  self.write_levels(next)
  ignore(self.node.add(object))
  self
}

///|
/// 按距离删掉第一级匹配，并把该对象从子节点拿掉。没有这一级时返回假，级别和子节点都不改。
/// r186: `removeLevel` https://github.com/mrdoob/three.js/blob/r186/src/objects/LOD.js#L149
pub fn LOD::remove_level(self : LOD, distance : Double) -> Bool {
  let mut found = None
  let mut i = 0
  let count = self.levels.length()
  while i < count {
    if self.levels[i].distance == distance {
      found = Some(i)
      break
    }
    i = i + 1
  }
  match found {
    None => false
    Some(index) => {
      let object = self.levels[index].object
      let next : Array[@core.LodLevel] = []
      let mut j = 0
      while j < count {
        if j != index {
          next.push(self.levels[j])
        }
        j = j + 1
      }
      self.write_levels(next)
      ignore(self.node.remove(object))
      true
    }
  }
}

///|
/// 返回当前级别下标。新建时是 `0`。`update` 在多于一级时改写它。
/// r186: `getCurrentLevel` https://github.com/mrdoob/three.js/blob/r186/src/objects/LOD.js#L175
pub fn LOD::get_current_level(self : LOD) -> Int {
  self.current_level
}

///|
/// 返回第一个距离阈值大于给定距离的前一级对象。对象可见时，阈值会减去 `distance * hysteresis`。没有级别时返回空。
/// r186: `getObjectForDistance` https://github.com/mrdoob/three.js/blob/r186/src/objects/LOD.js#L188
pub fn LOD::get_object_for_distance(
  self : LOD,
  distance : Double,
) -> Object3D? {
  @core.lod_object_for_distance(self.levels, distance)
}

///|
/// 按相机到 LOD 的世界距离除以 `zoom` 切换可见级别。只有一级时什么都不改。没有相机会中止。
/// r186: `update` https://github.com/mrdoob/three.js/blob/r186/src/objects/LOD.js#L250
pub fn LOD::update(self : LOD, camera : Object3D) -> Unit {
  let count = self.levels.length()
  if count <= 1 {
    return
  }
  let state = match camera.camera {
    None => abort("LOD.update requires a camera")
    Some(state) => state
  }
  let camera_position = @math.Vector3::new()
    .set_from_matrix_position(camera.matrix_world)
  let lod_position = @math.Vector3::new()
    .set_from_matrix_position(self.node.matrix_world)
  let distance = camera_position.distance_to(lod_position) / state.zoom
  self.levels[0].object.visible = true
  let mut i = 1
  while i < count {
    let level = self.levels[i]
    let mut level_distance = level.distance
    if level.object.visible {
      level_distance = level_distance - level_distance * level.hysteresis
    }
    if distance >= level_distance {
      self.levels[i - 1].object.visible = false
      level.object.visible = true
    } else {
      break
    }
    i = i + 1
  }
  self.current_level = i - 1
  while i < count {
    self.levels[i].object.visible = false
    i = i + 1
  }
}

///|
/// 复制变换和各级对象。子节点不从源节点整棵复制，而是克隆每一级的对象再加入。`current_level` 留在目标原来的值。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/objects/LOD.js#L87
pub fn LOD::copy(self : LOD, source : LOD) -> LOD {
  ignore(self.node.copy(source.node, recursive=false))
  let count = source.levels.length()
  let mut index = 0
  while index < count {
    let level = source.levels[index]
    ignore(
      self.add_level(
        level.object.clone(),
        distance=level.distance,
        hysteresis=level.hysteresis,
      ),
    )
    index = index + 1
  }
  self.auto_update = source.auto_update
  self
}

///|
/// 新建一份 LOD 再复制。three.js 没有单独的 `LOD.clone`，用的是 `Object3D.clone`。新对象的 `current_level` 从 `0` 开始。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1592
pub fn LOD::clone(self : LOD) -> LOD {
  LOD::new().copy(self)
}
