// r186: `InstancedMesh` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L28

///|
/// 同一几何体画多次。实例矩阵在物体矩阵之前相乘，和 r186 `InstancedMesh` 一样。
/// 没有 `instanceColor` 时渲染器使用白色。默认不做视锥裁剪。
/// `morph_texture` 是红色浮点 `DataTexture`，默认没有。宽是权重个数加一，高是实例个数。
/// r186: `InstancedMesh` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L28
/// r186: `morphTexture` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L77
pub(all) struct InstancedMesh {
  node : Object3D
  mut geometry : BufferGeometry
  mut material : @materials.Material
  mut materials : Array[@materials.Material]?
  instances : @core.InstanceData
  mut bounding_box : @math.Box3?
  mut bounding_sphere : @math.Sphere?
  mut morph_texture : @textures.DataTexture?
}

///|
pub fn InstancedMesh::new(
  geometry : BufferGeometry,
  material : @materials.Material,
  count : Int32,
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
    materials: None,
    instances,
    bounding_box: None,
    bounding_sphere: None,
    morph_texture: None,
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
    env_map: self.material.env_map,
    env_map_intensity: self.material.env_map_intensity,
    env_rotation: baked_env_rotation(self.material.env_map_rotation),
    instances: Some(self.instances),
    group_sides: material_sides(self.materials),
    group_draws: material_draws(self.materials),
  })
}

///|
/// 换成材质数组后，每个实例的射线按几何分组使用各自的侧面，并写下 `material_index`。
/// 直接改数组里的侧面不会更新节点，要再调用 `refresh`。
/// r186: `material` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L75
pub fn InstancedMesh::set_materials(
  self : InstancedMesh,
  materials : Array[@materials.Material],
) -> Unit {
  let copied : Array[@materials.Material] = []
  for material in materials {
    copied.push(material)
  }
  self.materials = Some(copied)
  self.refresh()
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
  opacity~ : Double = 1.0,
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
pub fn InstancedMesh::set_count(self : InstancedMesh, count : Int32) -> Unit {
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
  index : Int32,
  matrix : @math.Matrix4,
) -> Unit {
  write_matrix(self.instances.matrices, index, matrix)
  self.instances.version = self.instances.version + 1
}

///|
pub fn InstancedMesh::get_matrix_at(
  self : InstancedMesh,
  index : Int32,
  target : @math.Matrix4,
) -> @math.Matrix4 {
  read_matrix(self.instances.matrices, index, target)
  target
}

///|
/// 第一次调用时分配白色 `rgb`。写入的是颜色里已经存好的线性分量。
pub fn InstancedMesh::set_color_at(
  self : InstancedMesh,
  index : Int32,
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
  index : Int32,
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
/// 把一只网格的形变权重写进第 `index` 个实例。
/// 缓冲第一个数是底权重：相对形变时是 `1`，否则是 `1` 减各项权重之和。后面接各项权重。
/// 第一次调用按 `(权重个数 + 1) * count` 分配红色浮点纹理，宽是这个长度，高是实例个数，其余位置是 `0`。
/// `needsUpdate` 保持 false，调用方要上传时自己打开。
/// r186: `setMorphAt` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L355
/// r186: `DataTexture` https://github.com/mrdoob/three.js/blob/r186/src/textures/DataTexture.js#L32
pub fn InstancedMesh::set_morph_at(
  self : InstancedMesh,
  index : Int32,
  object : Mesh,
) -> InstancedMesh {
  let influences = match object.morph_target_influences {
    None => abort("InstancedMesh.setMorphAt requires morphTargetInfluences")
    Some(influences) => influences
  }
  let len = influences.length() + 1
  if self.morph_texture is None {
    let created : Array[Double] = []
    let total = len * self.instances.count
    let mut fill = 0
    while fill < total {
      created.push(0.0)
      fill = fill + 1
    }
    self.morph_texture = Some(
      @textures.DataTexture::new(
        created,
        width=len,
        height=self.instances.count,
        format=@constants.PixelFormat::Red,
      ),
    )
  }
  let data = match self.morph_texture {
    None => abort("InstancedMesh.setMorphAt requires morphTexture")
    Some(texture) => texture.data
  }
  let mut sum = 0.0
  let mut cursor = 0
  while cursor < influences.length() {
    sum = sum + influences[cursor]
    cursor = cursor + 1
  }
  let base = if self.geometry.morph_targets_relative { 1.0 } else { 1.0 - sum }
  let data_index = len * index
  data[data_index] = base
  cursor = 0
  while cursor < influences.length() {
    data[data_index + 1 + cursor] = influences[cursor]
    cursor = cursor + 1
  }
  self
}

///|
/// 从第 `index` 个实例读出形变权重，写进网格已有的权重数组。跳过缓冲开头的底权重。
/// r186: `getMorphAt` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L240
pub fn InstancedMesh::get_morph_at(
  self : InstancedMesh,
  index : Int32,
  object : Mesh,
) -> Unit {
  let influences = match object.morph_target_influences {
    None => abort("InstancedMesh.getMorphAt requires morphTargetInfluences")
    Some(influences) => influences
  }
  let data = match self.morph_texture {
    None => abort("InstancedMesh.getMorphAt requires morphTexture")
    Some(texture) => texture.data
  }
  let len = influences.length() + 1
  let data_index = index * len + 1
  let mut cursor = 0
  while cursor < influences.length() {
    influences[cursor] = data[data_index + cursor]
    cursor = cursor + 1
  }
}

///|
/// 复制变换、实例矩阵、颜色、个数和包围体。几何体与材质沿用源对象。包围盒和包围球是克隆。
/// 材质数组会复制一份新列表，里面的材质仍是原来的对象。源对象没有数组时，目标的数组清掉。
/// 源对象有形变纹理时克隆一张。浮点数组与来源共用。源对象没有时，目标上已有的纹理留着。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L182
pub fn InstancedMesh::copy(
  self : InstancedMesh,
  source : InstancedMesh,
  recursive~ : Bool = true,
) -> InstancedMesh {
  ignore(self.node.copy(source.node, recursive~))
  self.geometry = source.geometry
  self.material = source.material
  self.materials = match source.materials {
    None => None
    Some(materials) => {
      let copied : Array[@materials.Material] = []
      for material in materials {
        copied.push(material)
      }
      Some(copied)
    }
  }
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
  match source.morph_texture {
    None => ()
    Some(texture) => self.morph_texture = Some(texture.clone())
  }
  self.refresh()
  self
}

///|
/// 新建一份网格再复制。three.js 没有单独的 `InstancedMesh.clone`，用的是 `Object3D.clone`。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1592
pub fn InstancedMesh::clone(
  self : InstancedMesh,
  recursive~ : Bool = true,
) -> InstancedMesh {
  InstancedMesh::new(
    self.geometry,
    self.material,
    self.instances.matrices.count,
  ).copy(self, recursive~)
}

///|
/// 空操作。实例网格的形变写在 `morph_texture` 里，不在这里建立权重表。
/// 已经写过的缓冲保持不变。
/// r186: `updateMorphTargets` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L388
pub fn InstancedMesh::update_morph_targets(_self : InstancedMesh) -> Unit {

}

///|
/// 发出 `dispose`，释放形变纹理并清空字段。
/// r186: `dispose` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L396
pub fn InstancedMesh::dispose(self : InstancedMesh) -> Unit {
  self.node.dispose()
  match self.morph_texture {
    None => ()
    Some(texture) => texture.dispose()
  }
  self.morph_texture = None
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
            [-0.5, -0.5, 0.0, 0.5, -0.5, 0.0, 0.5, 0.5, 0.0, -0.5, 0.5, 0.0],
            3,
          ),
        ),
      )
      ignore(
        geometry.set_attribute(
          "uv",
          BufferAttribute::new([0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0], 2),
        ),
      )
      ignore(geometry.set_index_array([0, 1, 2, 0, 2, 3]))
      shared_sprite_geometry.val = Some(geometry)
      geometry
    }
  }
}
