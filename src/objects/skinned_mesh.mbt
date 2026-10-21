// r186: `SkinnedMesh` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L38

///|
/// 带骨架的网格。绑定模式默认是附着，两份绑定矩阵都是单位矩阵，包围体和骨架都为空。
/// 节点种类仍是 `Mesh`。`bind` 留到后面。
/// r186: `SkinnedMesh` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L38
/// r186: `bindMode` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L69
/// r186: `bindMatrix` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L76
/// r186: `bindMatrixInverse` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L83
pub(all) struct SkinnedMesh {
  mesh : Mesh
  mut bind_mode : @constants.BindMode
  bind_matrix : @math.Matrix4
  bind_matrix_inverse : @math.Matrix4
  mut bounding_box : @math.Box3?
  mut bounding_sphere : @math.Sphere?
  mut skeleton : Skeleton?
}

///|
pub fn SkinnedMesh::new(
  geometry : BufferGeometry,
  material : @materials.Material,
) -> SkinnedMesh {
  let skin : SkinnedMesh = {
    mesh: Mesh::new(geometry, material),
    bind_mode: @constants.Attached,
    bind_matrix: @math.Matrix4::new(),
    bind_matrix_inverse: @math.Matrix4::new(),
    bounding_box: None,
    bounding_sphere: None,
    skeleton: None,
  }
  skin.attach_raycast()
  skin
}

///|
fn SkinnedMesh::attach_raycast(self : SkinnedMesh) -> Unit {
  self.mesh.node.skinned_raycast = Some(fn(raycaster, intersects) {
    self.raycast(raycaster, intersects)
  })
}

///|
pub impl @core.AsNode for SkinnedMesh with fn to_node(self) {
  self.mesh.node
}

///|
pub extend SkinnedMesh with @core.AsNode::{to_node}

///|
/// 绑定骨架。给出绑定矩阵时直接使用它。没有给出时先更新世界矩阵，再按骨骼当前的世界矩阵重算逆绑定，并用网格自己的世界矩阵。
/// r186: `bind` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L230
pub fn SkinnedMesh::bind(
  self : SkinnedMesh,
  skeleton : Skeleton,
  bind_matrix? : @math.Matrix4,
) -> Unit {
  self.skeleton = Some(skeleton)
  let matrix = match bind_matrix {
    None => {
      self.mesh.node.update_matrix_world(force=true)
      skeleton.calculate_inverses()
      self.mesh.node.matrix_world
    }
    Some(matrix) => matrix
  }
  ignore(self.bind_matrix.copy(matrix))
  ignore(self.bind_matrix_inverse.copy(matrix).invert())
}

///|
/// 把已绑定的骨架收回绑定姿态。还没有骨架时中止。
/// r186: `pose` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L252
pub fn SkinnedMesh::pose(self : SkinnedMesh) -> Unit {
  match self.skeleton {
    None => abort("SkinnedMesh.pose requires a skeleton")
    Some(skeleton) => skeleton.pose()
  }
}

///|
/// 把 `skinWeight` 按曼哈顿长度归一。长度是 0 的顶点写成 `(1, 0, 0, 0)`。没有这个属性时中止。
/// r186: `normalizeSkinWeights` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L262
pub fn SkinnedMesh::normalize_skin_weights(self : SkinnedMesh) -> Unit {
  let skin_weight = match self.mesh.geometry.get_attribute("skinWeight") {
    None =>
      abort("SkinnedMesh.normalizeSkinWeights requires a skinWeight attribute")
    Some(attribute) => attribute
  }
  let vector = @math.Vector4::new()
  let mut index = 0
  while index < skin_weight.count {
    ignore(skin_weight.copy_to_vector4(index, vector))
    let length = vector.manhattan_length()
    if length == 0.0 {
      ignore(vector.set(1.0, 0.0, 0.0, 0.0))
    } else {
      ignore(vector.multiply_scalar(1.0 / length))
    }
    ignore(skin_weight.set_xyzw(index, vector.x, vector.y, vector.z, vector.w))
    index = index + 1
  }
}

///|
/// 更新世界矩阵，再按绑定模式重写逆绑定矩阵。附着时用世界矩阵，分离时用绑定矩阵。
/// r186: `updateMatrixWorld` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L290
pub fn SkinnedMesh::update_matrix_world(
  self : SkinnedMesh,
  force? : Bool = false,
) -> Unit {
  self.mesh.node.update_matrix_world(force~)
  match self.bind_mode {
    @constants.Attached =>
      ignore(self.bind_matrix_inverse.copy(self.mesh.node.matrix_world).invert())
    @constants.Detached =>
      ignore(self.bind_matrix_inverse.copy(self.bind_matrix).invert())
  }
}

///|
/// 用骨骼矩阵变换一个点。`w` 按 1 处理。权重为 0 的影响跳过。
/// 没有骨架、`skinIndex` 或 `skinWeight` 时中止。
/// r186: `applyBoneTransform` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L319
pub fn SkinnedMesh::apply_bone_transform(
  self : SkinnedMesh,
  index : Int,
  target : @math.Vector3,
) -> @math.Vector3 {
  let skeleton = match self.skeleton {
    None => abort("SkinnedMesh.applyBoneTransform requires a skeleton")
    Some(skeleton) => skeleton
  }
  let geometry = self.mesh.geometry
  let skin_index = match geometry.get_attribute("skinIndex") {
    None => abort("SkinnedMesh.applyBoneTransform requires a skinIndex attribute")
    Some(attribute) => attribute
  }
  let skin_weight = match geometry.get_attribute("skinWeight") {
    None => abort("SkinnedMesh.applyBoneTransform requires a skinWeight attribute")
    Some(attribute) => attribute
  }
  let base = @math.Vector4::new(x=target.x, y=target.y, z=target.z, w=1.0)
  target.x = 0.0
  target.y = 0.0
  target.z = 0.0
  ignore(base.apply_matrix4(self.bind_matrix))
  let indices = @math.Vector4::new()
  let weights = @math.Vector4::new()
  ignore(skin_index.copy_to_vector4(index, indices))
  ignore(skin_weight.copy_to_vector4(index, weights))
  let mut slot = 0
  while slot < 4 {
    let weight = weights.get_component(slot)
    if weight != 0.0 {
      let bone_index = indices.get_component(slot).to_int()
      if bone_index < 0 ||
        bone_index >= skeleton.bones.length() ||
        bone_index >= skeleton.bone_inverses.length() {
        abort("SkinnedMesh.applyBoneTransform bone index is out of range")
      }
      let bone_matrix = @math.Matrix4::new()
      ignore(
        bone_matrix.multiply_matrices(
          skeleton.bones[bone_index].node.matrix_world,
          skeleton.bone_inverses[bone_index],
        ),
      )
      let transformed = @math.Vector4::new()
      ignore(transformed.copy(base).apply_matrix4(bone_matrix))
      ignore(
        target.add_scaled_vector(
          @math.Vector3::new(
            x=transformed.x,
            y=transformed.y,
            z=transformed.z,
          ),
          weight,
        ),
      )
    }
    slot = slot + 1
  }
  ignore(target.apply_matrix4(self.bind_matrix_inverse))
  target
}

///|
/// 用骨骼矩阵变换一个齐次向量。`w` 为 1 的是点，为 0 的是方向。
/// 混合之后把 `w` 设回绑定矩阵作用后的值，再乘逆绑定矩阵，不做透视除法。
/// 没有骨架、`skinIndex` 或 `skinWeight` 时中止。
/// r186: `applyBoneTransform` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L319
pub fn SkinnedMesh::apply_bone_transform_vector4(
  self : SkinnedMesh,
  index : Int,
  target : @math.Vector4,
) -> @math.Vector4 {
  let skeleton = match self.skeleton {
    None => abort("SkinnedMesh.applyBoneTransform requires a skeleton")
    Some(skeleton) => skeleton
  }
  let geometry = self.mesh.geometry
  let skin_index = match geometry.get_attribute("skinIndex") {
    None => abort("SkinnedMesh.applyBoneTransform requires a skinIndex attribute")
    Some(attribute) => attribute
  }
  let skin_weight = match geometry.get_attribute("skinWeight") {
    None => abort("SkinnedMesh.applyBoneTransform requires a skinWeight attribute")
    Some(attribute) => attribute
  }
  let base = target.clone()
  ignore(target.set(0.0, 0.0, 0.0, 0.0))
  ignore(base.apply_matrix4(self.bind_matrix))
  let indices = @math.Vector4::new()
  let weights = @math.Vector4::new()
  ignore(skin_index.copy_to_vector4(index, indices))
  ignore(skin_weight.copy_to_vector4(index, weights))
  let mut slot = 0
  while slot < 4 {
    let weight = weights.get_component(slot)
    if weight != 0.0 {
      let bone_index = indices.get_component(slot).to_int()
      if bone_index < 0 ||
        bone_index >= skeleton.bones.length() ||
        bone_index >= skeleton.bone_inverses.length() {
        abort("SkinnedMesh.applyBoneTransform bone index is out of range")
      }
      let bone_matrix = @math.Matrix4::new()
      ignore(
        bone_matrix.multiply_matrices(
          skeleton.bones[bone_index].node.matrix_world,
          skeleton.bone_inverses[bone_index],
        ),
      )
      let transformed = @math.Vector4::new()
      ignore(transformed.copy(base).apply_matrix4(bone_matrix))
      ignore(target.add_scaled_vector(transformed, weight))
    }
    slot = slot + 1
  }
  target.w = base.w
  ignore(target.apply_matrix4(self.bind_matrix_inverse))
  target
}

///|
/// 先按网格读局部顶点（含形变），再套骨骼变换。
/// r186: `getVertexPosition` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L213
pub fn SkinnedMesh::get_vertex_position(
  self : SkinnedMesh,
  index : Int,
  target : @math.Vector3,
) -> @math.Vector3 {
  ignore(self.mesh.node.get_vertex_position(index, target))
  self.apply_bone_transform(index, target)
}

///|
/// 用蒙皮后的顶点重算局部包围盒。没有盒子时新建一个空盒，已有的盒子先清空再写入。
/// 没有 `position` 时中止。
/// r186: `computeBoundingBox` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L109
pub fn SkinnedMesh::compute_bounding_box(self : SkinnedMesh) -> @math.Box3 {
  let position = match self.mesh.geometry.get_attribute("position") {
    None => abort("SkinnedMesh.computeBoundingBox requires a position attribute")
    Some(position) => position
  }
  let box = match self.bounding_box {
    Some(box) => box
    None => {
      let box = @math.Box3::empty()
      self.bounding_box = Some(box)
      box
    }
  }
  ignore(box.make_empty())
  let vertex = @math.Vector3::new()
  let mut index = 0
  while index < position.count {
    ignore(self.get_vertex_position(index, vertex))
    ignore(box.expand_by_point(vertex))
    index = index + 1
  }
  box
}

///|
/// 用蒙皮后的顶点重算局部包围球。没有球时新建一个空球，已有的球先清空再写入。
/// 没有 `position` 时中止。
/// r186: `computeBoundingSphere` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L138
pub fn SkinnedMesh::compute_bounding_sphere(self : SkinnedMesh) -> @math.Sphere {
  let position = match self.mesh.geometry.get_attribute("position") {
    None => abort("SkinnedMesh.computeBoundingSphere requires a position attribute")
    Some(position) => position
  }
  let sphere = match self.bounding_sphere {
    Some(sphere) => sphere
    None => {
      let sphere = @math.Sphere::new()
      self.bounding_sphere = Some(sphere)
      sphere
    }
  }
  ignore(sphere.make_empty())
  let vertex = @math.Vector3::new()
  let mut index = 0
  while index < position.count {
    ignore(self.get_vertex_position(index, vertex))
    ignore(sphere.expand_by_point(vertex))
    index = index + 1
  }
  sphere
}

///|
/// 复制网格、绑定和包围体。几何体、材质和骨架沿用源对象。
/// 包围盒和包围球各克隆一份。源对象没有包围体时，目标上已有的值留着。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L161
pub fn SkinnedMesh::copy(
  self : SkinnedMesh,
  source : SkinnedMesh,
  recursive? : Bool = true,
) -> SkinnedMesh {
  ignore(self.mesh.copy(source.mesh, recursive~))
  self.bind_mode = source.bind_mode
  ignore(self.bind_matrix.copy(source.bind_matrix))
  ignore(self.bind_matrix_inverse.copy(source.bind_matrix_inverse))
  self.skeleton = source.skeleton
  match source.bounding_box {
    None => ()
    Some(box) => self.bounding_box = Some(box.clone())
  }
  match source.bounding_sphere {
    None => ()
    Some(sphere) => self.bounding_sphere = Some(sphere.clone())
  }
  self
}

///|
/// 新建一份蒙皮网格再复制。three.js 没有单独的 `SkinnedMesh.clone`，用的是 `Object3D.clone`。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1592
pub fn SkinnedMesh::clone(
  self : SkinnedMesh,
  recursive? : Bool = true,
) -> SkinnedMesh {
  SkinnedMesh::new(self.mesh.geometry, self.mesh.material).copy(self, recursive~)
}

///|
/// 换成材质数组后，射线按几何分组使用各自的侧面，并写下 `material_index`。
/// 顶点仍先做骨骼变换。直接改数组里的侧面不会更新节点，要再调用内层网格的 `refresh`。
/// r186: `material` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L75
pub fn SkinnedMesh::set_materials(
  self : SkinnedMesh,
  materials : Array[@materials.Material],
) -> Unit {
  self.mesh.set_materials(materials)
}

///|
/// 用蒙皮后的包围球、包围盒和顶点做射线相交。没有包围球时先算。
/// 包围盒在局部空间里挡掉射线时不写交点。
/// r186: `raycast` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L178
pub fn SkinnedMesh::raycast(
  self : SkinnedMesh,
  raycaster : @core.Raycaster,
  intersects : Array[@core.Intersection],
) -> Unit {
  let sphere = match self.bounding_sphere {
    Some(sphere) => sphere
    None => self.compute_bounding_sphere()
  }
  let world_sphere = @math.Sphere::new()
  ignore(
    world_sphere.copy(sphere).apply_matrix4(self.mesh.node.matrix_world),
  )
  if !raycaster.ray.intersects_sphere(world_sphere) {
    return
  }
  let inverse = @math.Matrix4::new()
  ignore(inverse.copy(self.mesh.node.matrix_world).invert())
  let ray = @math.Ray::new()
  ignore(ray.copy(raycaster.ray).apply_matrix4(inverse))
  match self.bounding_box {
    None => ()
    Some(box) =>
      if !ray.intersects_box(box) {
        return
      }
  }
  self.mesh.node.raycast_triangles_with(
    raycaster,
    intersects,
    ray,
    self.mesh.material.side,
    fn(index, target) { self.get_vertex_position(index, target) },
  )
}

