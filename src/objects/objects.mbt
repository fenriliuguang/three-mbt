// r186: `Group` https://github.com/mrdoob/three.js/blob/r186/src/objects/Group.js#L20 ; `Bone` https://github.com/mrdoob/three.js/blob/r186/src/objects/Bone.js#L17 ; `Skeleton` https://github.com/mrdoob/three.js/blob/r186/src/objects/Skeleton.js#L37 ; `SkinnedMesh` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L38 ; `Mesh` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L39 ; `Points` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L19 ; `Line` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L41 ; `LineSegments` https://github.com/mrdoob/three.js/blob/r186/src/objects/LineSegments.js#L14 ; `LineLoop` https://github.com/mrdoob/three.js/blob/r186/src/objects/LineLoop.js#L10 ; `InstancedMesh` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L28 ; `Sprite` https://github.com/mrdoob/three.js/blob/r186/src/objects/Sprite.js#L47 ; `LOD` https://github.com/mrdoob/three.js/blob/r186/src/objects/LOD.js#L33

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
/// 复制变换和子节点。`Group` 没有自己的 `copy`，行为来自 `Object3D.copy`。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1605
pub fn Group::copy(
  self : Group,
  source : Group,
  recursive? : Bool = true,
) -> Group {
  ignore(self.node.copy(source.node, recursive~))
  self
}

///|
/// 新建一个组再复制。three.js 没有单独的 `Group.clone`，用的是 `Object3D.clone`。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1592
pub fn Group::clone(self : Group, recursive? : Bool = true) -> Group {
  Group::new().copy(self, recursive~)
}

///|
/// 骨架上的一根骨骼。种类是 `Bone`。
/// r186: `Bone` https://github.com/mrdoob/three.js/blob/r186/src/objects/Bone.js#L17
pub(all) struct Bone {
  node : Object3D
}

///|
pub fn Bone::new() -> Bone {
  { node: Object3D::new(kind=@core.Bone), }
}

///|
pub impl @core.AsNode for Bone with fn to_node(self) {
  self.node
}

///|
pub extend Bone with @core.AsNode::{to_node}

///|
pub fn[T : @core.AsNode] Bone::add(self : Bone, child : T) -> Bone {
  ignore(self.node.add(child.to_node()))
  self
}

///|
/// 复制变换和子节点。`Bone` 没有自己的 `copy`，行为来自 `Object3D.copy`。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1605
pub fn Bone::copy(
  self : Bone,
  source : Bone,
  recursive? : Bool = true,
) -> Bone {
  ignore(self.node.copy(source.node, recursive~))
  self
}

///|
/// 新建一根骨骼再复制。three.js 没有单独的 `Bone.clone`，用的是 `Object3D.clone`。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1592
pub fn Bone::clone(self : Bone, recursive? : Bool = true) -> Bone {
  Bone::new().copy(self, recursive~)
}

///|
/// 由骨骼层级组成的骨架。构造时复制骨骼列表。逆绑定矩阵缺省时由当前 `matrixWorld` 求逆。
/// 骨骼纹理留到后面。
/// r186: `Skeleton` https://github.com/mrdoob/three.js/blob/r186/src/objects/Skeleton.js#L37
pub(all) struct Skeleton {
  mut uuid : String
  bones : Array[Bone]
  mut bone_inverses : Array[@math.Matrix4]
  mut bone_matrices : Array[Double]
}

///|
pub fn Skeleton::new(
  bones? : Array[Bone],
  bone_inverses? : Array[@math.Matrix4],
) -> Skeleton {
  let bones = match bones {
    None => []
    Some(bones) => bones.copy()
  }
  let bone_inverses = match bone_inverses {
    None => []
    Some(bone_inverses) => bone_inverses
  }
  let skeleton : Skeleton = {
    uuid: @math.generate_uuid(),
    bones,
    bone_inverses,
    bone_matrices: [],
  }
  skeleton.init()
  skeleton
}

///|
/// 按骨骼数量分配全零的矩阵缓冲。逆绑定矩阵为空时重新计算；数量对不上时改成同样多的单位矩阵。
/// r186: `init` https://github.com/mrdoob/three.js/blob/r186/src/objects/Skeleton.js#L91
pub fn Skeleton::init(self : Skeleton) -> Unit {
  self.bone_matrices = zero_doubles(self.bones.length() * 16)
  if self.bone_inverses.length() == 0 {
    self.calculate_inverses()
  } else if self.bones.length() != self.bone_inverses.length() {
    let inverses = []
    let count = self.bones.length()
    let mut index = 0
    while index < count {
      inverses.push(@math.Matrix4::new())
      index = index + 1
    }
    self.bone_inverses = inverses
  }
}

///|
/// 清空逆绑定矩阵，再写入每根骨骼 `matrixWorld` 的逆。
/// r186: `calculateInverses` https://github.com/mrdoob/three.js/blob/r186/src/objects/Skeleton.js#L130
pub fn Skeleton::calculate_inverses(self : Skeleton) -> Unit {
  self.bone_inverses.clear()
  let count = self.bones.length()
  let mut index = 0
  while index < count {
    let inverse = @math.Matrix4::new()
    ignore(inverse.copy(self.bones[index].node.matrix_world).invert())
    self.bone_inverses.push(inverse)
    index = index + 1
  }
}

///|
/// 用逆绑定矩阵恢复绑定姿态，再分解出每根骨骼的局部位置、旋转和缩放。
/// 父节点也是骨骼时，局部矩阵是父世界矩阵的逆乘上自己的世界矩阵。
/// r186: `pose` https://github.com/mrdoob/three.js/blob/r186/src/objects/Skeleton.js#L153
pub fn Skeleton::pose(self : Skeleton) -> Unit {
  let count = self.bones.length()
  let mut index = 0
  while index < count {
    let bone = self.bones[index].node
    ignore(bone.matrix_world.copy(self.bone_inverses[index]).invert())
    index = index + 1
  }
  index = 0
  while index < count {
    let bone = self.bones[index].node
    match bone.parent {
      Some(parent) =>
        if parent.kind is @core.NodeKind::Bone {
          ignore(bone.matrix.copy(parent.matrix_world).invert())
          ignore(bone.matrix.multiply(bone.matrix_world))
        } else {
          ignore(bone.matrix.copy(bone.matrix_world))
        }
      None => ignore(bone.matrix.copy(bone.matrix_world))
    }
    ignore(bone.matrix.decompose(bone.position, bone.quaternion, bone.scale))
    index = index + 1
  }
}

///|
/// 把当前世界矩阵乘上逆绑定矩阵，按列主序写入骨骼矩阵缓冲。
/// 骨骼纹理留到后面，所以这里不标记贴图更新。
/// r186: `update` https://github.com/mrdoob/three.js/blob/r186/src/objects/Skeleton.js#L199
pub fn Skeleton::update(self : Skeleton) -> Unit {
  let offset = @math.Matrix4::new()
  let count = self.bones.length()
  let mut index = 0
  while index < count {
    ignore(
      offset
      .multiply_matrices(
        self.bones[index].node.matrix_world,
        self.bone_inverses[index],
      )
      .to_array(array=self.bone_matrices, offset=index * 16),
    )
    index = index + 1
  }
}

///|
/// 新建一个骨架。骨骼列表是新数组，逆绑定矩阵与来源共用。
/// 矩阵缓冲重新分配为全零，不复制已经写入的蒙皮矩阵。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/objects/Skeleton.js#L232
pub fn Skeleton::clone(self : Skeleton) -> Skeleton {
  Skeleton::new(bones=self.bones, bone_inverses=self.bone_inverses)
}

///|
/// 按名字找第一根骨骼。找不到时返回空。
/// r186: `getBoneByName` https://github.com/mrdoob/three.js/blob/r186/src/objects/Skeleton.js#L276
pub fn Skeleton::get_bone_by_name(self : Skeleton, name : String) -> Bone? {
  let count = self.bones.length()
  let mut index = 0
  while index < count {
    let bone = self.bones[index]
    if bone.node.name == name {
      return Some(bone)
    }
    index = index + 1
  }
    None
}

///|
/// 按骨骼数量把矩阵缓冲扩成贴图布局。边长至少是 4，并且是 4 的倍数。
/// 已有的浮点按顺序拷进去，多出来的位置是 0。`DataTexture` 留到后面。
/// r186: `computeBoneTexture` https://github.com/mrdoob/three.js/blob/r186/src/objects/Skeleton.js#L243
pub fn Skeleton::compute_bone_texture(self : Skeleton) -> Skeleton {
  let raw = (self.bones.length() * 4).to_double().sqrt()
  let mut size = (raw / 4.0).ceil().to_int() * 4
  if size < 4 {
    size = 4
  }
  let length = size * size * 4
  if self.bone_matrices.length() > length {
    abort("Skeleton.compute_bone_texture bone data does not fit")
  }
  let matrices = zero_doubles(length)
  let count = self.bone_matrices.length()
  let mut index = 0
  while index < count {
    matrices[index] = self.bone_matrices[index]
    index = index + 1
  }
  self.bone_matrices = matrices
  self
}

///|
/// 释放骨骼贴图。贴图对象还没有落地，所以矩阵缓冲和骨骼列表保持原样。
/// r186: `dispose` https://github.com/mrdoob/three.js/blob/r186/src/objects/Skeleton.js#L298
pub fn Skeleton::dispose(_self : Skeleton) -> Unit {
}

///|
/// `Skeleton.toJSON` 返回的数据。上游没有单独的类。`type_name` 对应元数据里的 `type`。
/// r186: `toJSON` https://github.com/mrdoob/three.js/blob/r186/src/objects/Skeleton.js#L350
pub(all) struct SkeletonJson {
  version : Double
  type_name : String
  generator : String
  uuid : String
  bones : Array[String]
  bone_inverses : Array[Array[Double]]
}

///|
/// 写出骨架编号、每根骨骼的编号，以及逆绑定矩阵的十六个列主序元素。
/// r186: `toJSON` https://github.com/mrdoob/three.js/blob/r186/src/objects/Skeleton.js#L350
pub fn Skeleton::to_json(self : Skeleton) -> SkeletonJson {
  let bones = []
  let inverses = []
  let count = self.bones.length()
  let mut index = 0
  while index < count {
    bones.push(self.bones[index].node.uuid)
    inverses.push(self.bone_inverses[index].to_array())
    index = index + 1
  }
  {
    version: 4.7,
    type_name: "Skeleton",
    generator: "Skeleton.toJSON",
    uuid: self.uuid,
    bones,
    bone_inverses: inverses,
  }
}

///|
/// 按编号把骨骼装回骨架，并读入逆绑定矩阵。找不到的编号会新建一根骨骼。
/// 已有的骨骼留在列表前面。装完后重新分配全零的矩阵缓冲。
/// r186: `fromJSON` https://github.com/mrdoob/three.js/blob/r186/src/objects/Skeleton.js#L317
pub fn Skeleton::from_json(
  self : Skeleton,
  json : SkeletonJson,
  bones : Map[String, Bone],
) -> Skeleton {
  if json.bone_inverses.length() < json.bones.length() {
    abort("Skeleton.fromJSON inverse list is shorter than the bone list")
  }
  self.uuid = json.uuid
  let count = json.bones.length()
  let mut index = 0
  while index < count {
    let bone = match bones.get(json.bones[index]) {
      None => Bone::new()
      Some(bone) => bone
    }
    self.bones.push(bone)
    let inverse = @math.Matrix4::new()
    ignore(inverse.from_array(json.bone_inverses[index]))
    self.bone_inverses.push(inverse)
    index = index + 1
  }
  self.init()
  self
}

///|
fn zero_doubles(count : Int) -> Array[Double] {
  let values = []
  let mut index = 0
  while index < count {
    values.push(0.0)
    index = index + 1
  }
  values
}

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
  {
    mesh: Mesh::new(geometry, material),
    bind_mode: @constants.Attached,
    bind_matrix: @math.Matrix4::new(),
    bind_matrix_inverse: @math.Matrix4::new(),
    bounding_box: None,
    bounding_sphere: None,
    skeleton: None,
  }
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
/// 三角网格。`geometry` 与 `material.color` 同时挂在场景节点上，遍历时可以读到。`count` 默认是 `1`。
/// 没有形变属性时，权重和名字表保持空。
/// r186: `Mesh` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L39
/// r186: `morphTargetDictionary` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L85
/// r186: `morphTargetInfluences` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L95
/// r186: `count` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L104
pub(all) struct Mesh {
  node : Object3D
  mut geometry : BufferGeometry
  mut material : @materials.Material
  mut count : Int
  mut morph_target_influences : Array[Double]?
  mut morph_target_dictionary : Map[String, Int]?
}

///|
pub fn Mesh::new(
  geometry : BufferGeometry,
  material : @materials.Material,
) -> Mesh {
  let node = Object3D::new(kind=@core.Mesh)
  let mesh : Mesh = {
    node,
    geometry,
    material,
    count: 1,
    morph_target_influences: None,
    morph_target_dictionary: None,
  }
  mesh.refresh()
  mesh.update_morph_targets()
  mesh
}

///|
/// 按几何体里先迭代到的那一组形变属性填写权重和名字表。权重全是 `0`。
/// 属性名为空时用下标字符串。没有形变属性时保持原值。
/// r186: `updateMorphTargets` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L137
pub fn Mesh::update_morph_targets(self : Mesh) -> Unit {
  let mut chosen : Array[BufferAttribute]? = None
  for pair in self.geometry.morph_attributes.iter() {
    if chosen is None {
      let (_, attributes) = pair
      chosen = Some(attributes)
    }
  }
  match chosen {
    None => ()
    Some(attributes) => {
      let influences : Array[Double] = []
      let dictionary : Map[String, Int] = Map([])
      let mut index = 0
      while index < attributes.length() {
        let attribute = attributes[index]
        let name = if attribute.name == "" {
          index.to_string()
        } else {
          attribute.name
        }
        influences.push(0.0)
        dictionary.set(name, index)
        index = index + 1
      }
      self.morph_target_influences = Some(influences)
      self.morph_target_dictionary = Some(dictionary)
    }
  }
}

///|
pub impl @core.AsNode for Mesh with fn to_node(self) {
  self.node
}

///|
pub extend Mesh with @core.AsNode::{to_node}

///|
/// 复制变换、几何体和材质。几何体与材质沿用源对象。
/// 源对象有形变权重或名字表时各复制一份。源对象没有时，目标上已有的值留着。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L110
pub fn Mesh::copy(
  self : Mesh,
  source : Mesh,
  recursive? : Bool = true,
) -> Mesh {
  ignore(self.node.copy(source.node, recursive~))
  self.geometry = source.geometry
  self.material = source.material
  match source.morph_target_influences {
    None => ()
    Some(weights) => {
      let copied : Array[Double] = []
      for weight in weights {
        copied.push(weight)
      }
      self.morph_target_influences = Some(copied)
    }
  }
  match source.morph_target_dictionary {
    None => ()
    Some(dictionary) => {
      let copied : Map[String, Int] = Map([])
      for pair in dictionary.iter() {
        let (name, index) = pair
        copied.set(name, index)
      }
      self.morph_target_dictionary = Some(copied)
    }
  }
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
/// 点。每个位置画一个朝向相机的四边形。没有形变属性时，权重和名字表保持空。
/// r186: `Points` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L19
/// r186: `morphTargetDictionary` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L65
/// r186: `morphTargetInfluences` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L75
pub(all) struct Points {
  node : Object3D
  mut geometry : BufferGeometry
  mut material : @materials.PointsMaterial
  mut morph_target_influences : Array[Double]?
  mut morph_target_dictionary : Map[String, Int]?
}

///|
pub fn Points::new(
  geometry : BufferGeometry,
  material : @materials.PointsMaterial,
) -> Points {
  let node = Object3D::new(kind=@core.NodeKind::Points)
  let points : Points = {
    node,
    geometry,
    material,
    morph_target_influences: None,
    morph_target_dictionary: None,
  }
  points.refresh()
  points.update_morph_targets()
  points
}

///|
pub impl @core.AsNode for Points with fn to_node(self) {
  self.node
}

///|
pub extend Points with @core.AsNode::{to_node}

///|
/// 复制变换、几何体和材质。几何体与材质沿用源对象。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L81
pub fn Points::copy(
  self : Points,
  source : Points,
  recursive? : Bool = true,
) -> Points {
  ignore(self.node.copy(source.node, recursive~))
  self.geometry = source.geometry
  self.material = source.material
  self.refresh()
  self
}

///|
/// 新建一份点云再复制。three.js 没有单独的 `Points.clone`，用的是 `Object3D.clone`。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1592
pub fn Points::clone(self : Points, recursive? : Bool = true) -> Points {
  Points::new(self.geometry, self.material).copy(self, recursive~)
}

///|
/// 按几何体里先迭代到的那一组形变属性填写权重和名字表。权重全是 `0`。
/// 属性名为空时用下标字符串。没有形变属性时保持原值。
/// r186: `updateMorphTargets` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L175
pub fn Points::update_morph_targets(self : Points) -> Unit {
  let mut chosen : Array[BufferAttribute]? = None
  for pair in self.geometry.morph_attributes.iter() {
    if chosen is None {
      let (_, attributes) = pair
      chosen = Some(attributes)
    }
  }
  match chosen {
    None => ()
    Some(attributes) => {
      let influences : Array[Double] = []
      let dictionary : Map[String, Int] = Map([])
      let mut index = 0
      while index < attributes.length() {
        let attribute = attributes[index]
        let name = if attribute.name == "" {
          index.to_string()
        } else {
          attribute.name
        }
        influences.push(0.0)
        dictionary.set(name, index)
        index = index + 1
      }
      self.morph_target_influences = Some(influences)
      self.morph_target_dictionary = Some(dictionary)
    }
  }
}

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
/// 折线，对应 r186 的 `Line`。没有形变属性时，权重和名字表保持空。
/// r186: `Line` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L41
/// r186: `morphTargetDictionary` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L87
/// r186: `morphTargetInfluences` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L97
pub(all) struct Line {
  node : Object3D
  mut geometry : BufferGeometry
  mut material : @materials.LineBasicMaterial
  mut morph_target_influences : Array[Double]?
  mut morph_target_dictionary : Map[String, Int]?
}

///|
pub fn Line::new(
  geometry : BufferGeometry,
  material : @materials.LineBasicMaterial,
) -> Line {
  let node = Object3D::new(kind=@core.NodeKind::Line)
  let line : Line = {
    node,
    geometry,
    material,
    morph_target_influences: None,
    morph_target_dictionary: None,
  }
  line.refresh()
  line.update_morph_targets()
  line
}

///|
pub impl @core.AsNode for Line with fn to_node(self) {
  self.node
}

///|
pub extend Line with @core.AsNode::{to_node}

///|
/// 复制变换、几何体和材质。几何体与材质沿用源对象。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L103
pub fn Line::copy(
  self : Line,
  source : Line,
  recursive? : Bool = true,
) -> Line {
  ignore(self.node.copy(source.node, recursive~))
  self.geometry = source.geometry
  self.material = source.material
  self.refresh()
  self
}

///|
/// 新建一条折线再复制。three.js 没有单独的 `Line.clone`，用的是 `Object3D.clone`。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1592
pub fn Line::clone(self : Line, recursive? : Bool = true) -> Line {
  Line::new(self.geometry, self.material).copy(self, recursive~)
}

///|
/// 按几何体里先迭代到的那一组形变属性填写权重和名字表。权重全是 `0`。
/// 属性名为空时用下标字符串。没有形变属性时保持原值。
/// r186: `updateMorphTargets` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L275
pub fn Line::update_morph_targets(self : Line) -> Unit {
  let mut chosen : Array[BufferAttribute]? = None
  for pair in self.geometry.morph_attributes.iter() {
    if chosen is None {
      let (_, attributes) = pair
      chosen = Some(attributes)
    }
  }
  match chosen {
    None => ()
    Some(attributes) => {
      let influences : Array[Double] = []
      let dictionary : Map[String, Int] = Map([])
      let mut index = 0
      while index < attributes.length() {
        let attribute = attributes[index]
        let name = if attribute.name == "" {
          index.to_string()
        } else {
          attribute.name
        }
        influences.push(0.0)
        dictionary.set(name, index)
        index = index + 1
      }
      self.morph_target_influences = Some(influences)
      self.morph_target_dictionary = Some(dictionary)
    }
  }
}

///|
/// 沿折线累计每个顶点到起点的距离，写入 `lineDistance`。
/// 几何体带索引时上游只警告，这里不改属性。
/// r186: `computeLineDistances` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L121
pub fn Line::compute_line_distances(self : Line) -> Line {
  if self.geometry.index is Some(_) {
    return self
  }
  let position = match self.geometry.get_attribute("position") {
    None => abort("Line.computeLineDistances requires a position attribute")
    Some(position) => position
  }
  let distances = [0.0]
  let mut index = 1
  while index < position.count {
    let previous = index - 1
    let start = @math.Vector3::new(
      x=position.get_x(previous),
      y=position.get_y(previous),
      z=position.get_z(previous),
    )
    let end = @math.Vector3::new(
      x=position.get_x(index),
      y=position.get_y(index),
      z=position.get_z(index),
    )
    distances.push(distances[previous] + start.distance_to(end))
    index = index + 1
  }
  ignore(
    self.geometry.set_attribute(
      "lineDistance",
      @core.BufferAttribute::new(distances, 1),
    ),
  )
  self
}

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
/// 成对线段，对应 r186 的 `LineSegments`。没有形变属性时，权重和名字表保持空。
/// 这两个字段来自 `Line`，`LineSegments` 没有单独声明。
/// r186: `LineSegments` https://github.com/mrdoob/three.js/blob/r186/src/objects/LineSegments.js#L14
/// r186: `morphTargetDictionary` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L87
/// r186: `morphTargetInfluences` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L97
pub(all) struct LineSegments {
  node : Object3D
  mut geometry : BufferGeometry
  mut material : @materials.LineBasicMaterial
  mut morph_target_influences : Array[Double]?
  mut morph_target_dictionary : Map[String, Int]?
}

///|
pub fn LineSegments::new(
  geometry : BufferGeometry,
  material : @materials.LineBasicMaterial,
) -> LineSegments {
  let node = Object3D::new(kind=@core.NodeKind::LineSegments)
  let line : LineSegments = {
    node,
    geometry,
    material,
    morph_target_influences: None,
    morph_target_dictionary: None,
  }
  line.refresh()
  line.update_morph_targets()
  line
}

///|
pub impl @core.AsNode for LineSegments with fn to_node(self) {
  self.node
}

///|
pub extend LineSegments with @core.AsNode::{to_node}

///|
/// 复制变换、几何体和材质。几何体与材质沿用源对象。
/// `LineSegments` 没有自己的 `copy`，行为来自 `Line.copy`。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L103
pub fn LineSegments::copy(
  self : LineSegments,
  source : LineSegments,
  recursive? : Bool = true,
) -> LineSegments {
  ignore(self.node.copy(source.node, recursive~))
  self.geometry = source.geometry
  self.material = source.material
  self.refresh()
  self
}

///|
/// 新建一份成对线段再复制。three.js 没有单独的 `LineSegments.clone`，用的是 `Object3D.clone`。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1592
pub fn LineSegments::clone(
  self : LineSegments,
  recursive? : Bool = true,
) -> LineSegments {
  LineSegments::new(self.geometry, self.material).copy(self, recursive~)
}

///|
/// 按几何体里先迭代到的那一组形变属性填写权重和名字表。权重全是 `0`。
/// 属性名为空时用下标字符串。没有形变属性时保持原值。
/// `LineSegments` 没有自己的 `updateMorphTargets`，行为来自 `Line`。
/// r186: `updateMorphTargets` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L275
pub fn LineSegments::update_morph_targets(self : LineSegments) -> Unit {
  let mut chosen : Array[BufferAttribute]? = None
  for pair in self.geometry.morph_attributes.iter() {
    if chosen is None {
      let (_, attributes) = pair
      chosen = Some(attributes)
    }
  }
  match chosen {
    None => ()
    Some(attributes) => {
      let influences : Array[Double] = []
      let dictionary : Map[String, Int] = Map([])
      let mut index = 0
      while index < attributes.length() {
        let attribute = attributes[index]
        let name = if attribute.name == "" {
          index.to_string()
        } else {
          attribute.name
        }
        influences.push(0.0)
        dictionary.set(name, index)
        index = index + 1
      }
      self.morph_target_influences = Some(influences)
      self.morph_target_dictionary = Some(dictionary)
    }
  }
}

///|
/// 按成对顶点累计长度，写入 `lineDistance`。每段的起点沿用上一段的终点距离，第一段从 `0` 起。
/// 几何体带索引时上游只警告，这里不改属性。
/// r186: `computeLineDistances` https://github.com/mrdoob/three.js/blob/r186/src/objects/LineSegments.js#L39
pub fn LineSegments::compute_line_distances(self : LineSegments) -> LineSegments {
  if self.geometry.index is Some(_) {
    return self
  }
  let position = match self.geometry.get_attribute("position") {
    None =>
      abort("LineSegments.computeLineDistances requires a position attribute")
    Some(position) => position
  }
  let distances : Array[Double] = []
  let mut index = 0
  while index < position.count {
    let next = index + 1
    let start = @math.Vector3::new(
      x=position.get_x(index),
      y=position.get_y(index),
      z=position.get_z(index),
    )
    let end = @math.Vector3::new(
      x=position.get_x(next),
      y=position.get_y(next),
      z=position.get_z(next),
    )
    let segment_start = if index == 0 {
      0.0
    } else {
      distances[index - 1]
    }
    distances.push(segment_start)
    distances.push(segment_start + start.distance_to(end))
    index = index + 2
  }
  ignore(
    self.geometry.set_attribute(
      "lineDistance",
      @core.BufferAttribute::new(distances, 1),
    ),
  )
  self
}

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
/// 没有形变属性时，权重和名字表保持空。这两个字段来自 `Line`，`LineLoop` 没有单独声明。
/// r186: `LineLoop` https://github.com/mrdoob/three.js/blob/r186/src/objects/LineLoop.js#L10
/// r186: `morphTargetDictionary` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L87
/// r186: `morphTargetInfluences` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L97
pub(all) struct LineLoop {
  node : Object3D
  mut geometry : BufferGeometry
  mut material : @materials.LineBasicMaterial
  mut morph_target_influences : Array[Double]?
  mut morph_target_dictionary : Map[String, Int]?
}

///|
pub fn LineLoop::new(
  geometry : BufferGeometry,
  material : @materials.LineBasicMaterial,
) -> LineLoop {
  let node = Object3D::new(kind=@core.NodeKind::LineLoop)
  let line : LineLoop = {
    node,
    geometry,
    material,
    morph_target_influences: None,
    morph_target_dictionary: None,
  }
  line.refresh()
  line.update_morph_targets()
  line
}

///|
pub impl @core.AsNode for LineLoop with fn to_node(self) {
  self.node
}

///|
pub extend LineLoop with @core.AsNode::{to_node}

///|
/// 复制变换、几何体和材质。几何体与材质沿用源对象。
/// `LineLoop` 没有自己的 `copy`，行为来自 `Line.copy`。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L103
pub fn LineLoop::copy(
  self : LineLoop,
  source : LineLoop,
  recursive? : Bool = true,
) -> LineLoop {
  ignore(self.node.copy(source.node, recursive~))
  self.geometry = source.geometry
  self.material = source.material
  self.refresh()
  self
}

///|
/// 新建一条闭合折线再复制。three.js 没有单独的 `LineLoop.clone`，用的是 `Object3D.clone`。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1592
pub fn LineLoop::clone(self : LineLoop, recursive? : Bool = true) -> LineLoop {
  LineLoop::new(self.geometry, self.material).copy(self, recursive~)
}

///|
/// 按几何体里先迭代到的那一组形变属性填写权重和名字表。权重全是 `0`。
/// 属性名为空时用下标字符串。没有形变属性时保持原值。
/// `LineLoop` 没有自己的 `updateMorphTargets`，行为来自 `Line`。
/// r186: `updateMorphTargets` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L275
pub fn LineLoop::update_morph_targets(self : LineLoop) -> Unit {
  let mut chosen : Array[BufferAttribute]? = None
  for pair in self.geometry.morph_attributes.iter() {
    if chosen is None {
      let (_, attributes) = pair
      chosen = Some(attributes)
    }
  }
  match chosen {
    None => ()
    Some(attributes) => {
      let influences : Array[Double] = []
      let dictionary : Map[String, Int] = Map([])
      let mut index = 0
      while index < attributes.length() {
        let attribute = attributes[index]
        let name = if attribute.name == "" {
          index.to_string()
        } else {
          attribute.name
        }
        influences.push(0.0)
        dictionary.set(name, index)
        index = index + 1
      }
      self.morph_target_influences = Some(influences)
      self.morph_target_dictionary = Some(dictionary)
    }
  }
}

///|
/// 沿折线累计每个顶点到起点的距离，写入 `lineDistance`。
/// `LineLoop` 没有自己的 `computeLineDistances`，行为来自 `Line`。
/// 几何体带索引时上游只警告，这里不改属性。
/// r186: `computeLineDistances` https://github.com/mrdoob/three.js/blob/r186/src/objects/Line.js#L121
pub fn LineLoop::compute_line_distances(self : LineLoop) -> LineLoop {
  if self.geometry.index is Some(_) {
    return self
  }
  let position = match self.geometry.get_attribute("position") {
    None => abort("Line.computeLineDistances requires a position attribute")
    Some(position) => position
  }
  let distances = [0.0]
  let mut index = 1
  while index < position.count {
    let previous = index - 1
    let start = @math.Vector3::new(
      x=position.get_x(previous),
      y=position.get_y(previous),
      z=position.get_z(previous),
    )
    let end = @math.Vector3::new(
      x=position.get_x(index),
      y=position.get_y(index),
      z=position.get_z(index),
    )
    distances.push(distances[previous] + start.distance_to(end))
    index = index + 1
  }
  ignore(
    self.geometry.set_attribute(
      "lineDistance",
      @core.BufferAttribute::new(distances, 1),
    ),
  )
  self
}

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
/// `morph_texture` 是形变纹理的浮点数据，默认没有。
/// r186: `InstancedMesh` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L28
/// r186: `morphTexture` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L77
pub(all) struct InstancedMesh {
  node : Object3D
  mut geometry : BufferGeometry
  mut material : @materials.Material
  instances : @core.InstanceData
  mut bounding_box : @math.Box3?
  mut bounding_sphere : @math.Sphere?
  mut morph_texture : Array[Double]?
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
/// 把一只网格的形变权重写进第 `index` 个实例。
/// 缓冲第一个数是底权重：相对形变时是 `1`，否则是 `1` 减各项权重之和。后面接各项权重。
/// 第一次调用按 `(权重个数 + 1) * count` 分配，其余位置是 `0`。
/// 这里存的是 `DataTexture` 的浮点数据，纹理对象留在后面。
/// r186: `setMorphAt` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L355
pub fn InstancedMesh::set_morph_at(
  self : InstancedMesh,
  index : Int,
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
    self.morph_texture = Some(created)
  }
  let data = match self.morph_texture {
    None => abort("InstancedMesh.setMorphAt requires morphTexture")
    Some(data) => data
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
  index : Int,
  object : Mesh,
) -> Unit {
  let influences = match object.morph_target_influences {
    None => abort("InstancedMesh.getMorphAt requires morphTargetInfluences")
    Some(influences) => influences
  }
  let data = match self.morph_texture {
    None => abort("InstancedMesh.getMorphAt requires morphTexture")
    Some(data) => data
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
/// 源对象有形变缓冲时复制一份。源对象没有时，目标上已有的缓冲留着。
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
  match source.morph_texture {
    None => ()
    Some(data) => {
      let copied : Array[Double] = []
      for value in data {
        copied.push(value)
      }
      self.morph_texture = Some(copied)
    }
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
/// 空操作。实例网格的形变写在 `morph_texture` 里，不在这里建立权重表。
/// 已经写过的缓冲保持不变。
/// r186: `updateMorphTargets` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L388
pub fn InstancedMesh::update_morph_targets(_self : InstancedMesh) -> Unit {

}

///|
/// 发出 `dispose`，并清掉形变缓冲。
/// r186: `dispose` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L396
pub fn InstancedMesh::dispose(self : InstancedMesh) -> Unit {
  self.node.dispose()
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
  mut material : @materials.SpriteMaterial
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
/// 复制变换、锚点和材质。锚点写入已有的向量，材质沿用源对象。`count` 不复制。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/objects/Sprite.js#L216
pub fn Sprite::copy(
  self : Sprite,
  source : Sprite,
  recursive? : Bool = true,
) -> Sprite {
  ignore(self.node.copy(source.node, recursive~))
  ignore(self.center.copy(source.center))
  self.material = source.material
  self.refresh()
  self
}

///|
/// 新建一只精灵再复制。three.js 没有单独的 `Sprite.clone`，用的是 `Object3D.clone`。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1592
pub fn Sprite::clone(self : Sprite, recursive? : Bool = true) -> Sprite {
  Sprite::new(self.material).copy(self, recursive~)
}

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
