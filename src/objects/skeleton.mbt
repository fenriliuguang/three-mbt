// r186: `Skeleton` https://github.com/mrdoob/three.js/blob/r186/src/objects/Skeleton.js#L37

///|
/// 由骨骼层级组成的骨架。构造时复制骨骼列表。逆绑定矩阵缺省时由当前 `matrixWorld` 求逆。
/// `bone_texture` 在 `compute_bone_texture` 之前为空。
/// r186: `Skeleton` https://github.com/mrdoob/three.js/blob/r186/src/objects/Skeleton.js#L37
/// r186: `boneTexture` https://github.com/mrdoob/three.js/blob/r186/src/objects/Skeleton.js#L80
pub(all) struct Skeleton {
  mut uuid : String
  bones : Array[Bone]
  mut bone_inverses : Array[@math.Matrix4]
  mut bone_matrices : Array[Double]
  mut bone_texture : @textures.DataTexture?
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
    bone_texture: None,
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
/// 已经有骨骼纹理时，把 `needs_update` 设为 true。
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
  match self.bone_texture {
    None => ()
    Some(texture) => texture.needs_update = true
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
/// 已有的浮点按顺序拷进去，多出来的位置是 0。
/// 贴图是 `RGBA` 浮点 `DataTexture`，和矩阵缓冲共用这一份数组。`needs_update` 为 true。
/// r186: `computeBoneTexture` https://github.com/mrdoob/three.js/blob/r186/src/objects/Skeleton.js#L243
/// r186: `DataTexture` https://github.com/mrdoob/three.js/blob/r186/src/textures/DataTexture.js#L14
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
  let texture = @textures.DataTexture::new(matrices, width=size, height=size)
  texture.needs_update = true
  self.bone_texture = Some(texture)
  self
}

///|
/// 释放骨骼贴图并清空 `bone_texture`。矩阵缓冲和骨骼列表保持原样。
/// r186: `dispose` https://github.com/mrdoob/three.js/blob/r186/src/objects/Skeleton.js#L298
pub fn Skeleton::dispose(self : Skeleton) -> Unit {
  match self.bone_texture {
    None => ()
    Some(texture) => texture.dispose()
  }
  self.bone_texture = None
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
fn zero_doubles(count : Int32) -> Array[Double] {
  let values = []
  let mut index = 0
  while index < count {
    values.push(0.0)
    index = index + 1
  }
  values
}
