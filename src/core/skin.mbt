// r186: `SkinnedMesh` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L38 ; `Skeleton` https://github.com/mrdoob/three.js/blob/r186/src/objects/Skeleton.js#L37

///|
/// 蒙皮用的绑定姿态。顶点留在网格局部空间，不在着色器里蒙皮。
/// 关节矩阵是 `joint.matrixWorld * inverseBindMatrix`。
/// 绑定矩阵是单位矩阵；每帧再用网格 `matrixWorld` 的逆把结果收回局部空间。
/// r186: `applyBoneTransform` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L319
pub(all) struct SkinState {
  joints : Array[Object3D]
  inverse_binds : Array[@math.Matrix4]
  bind_position : Array[Double]
  bind_normal : Array[Double]?
  indices : Array[Int]
  weights : Array[Double]
}

///|
/// 用当前关节世界矩阵重写 `position`，已有法线时也重写 `normal`。
/// 节点上有形变时，先把当前权重的 `POSITION` 和 `NORMAL` 增量加进未烘焙的底数。
/// 权重为 0，或关节下标越界的影响，不参与累加。
/// r186: `applyBoneTransform` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L319 ; `updateMatrixWorld` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L290
pub fn SkinState::write(
  self : SkinState,
  node : Object3D,
  geometry : BufferGeometry,
) -> Unit {
  let bind_inverse = @math.Matrix4::new()
  ignore(bind_inverse.copy(node.matrix_world).invert())
  let bones = bone_matrices(self)
  let positions = morphed_source(node, self.bind_position, true)
  write_skinned(
    geometry, "position", positions, self, bones, bind_inverse, true,
  )
  match self.bind_normal {
    None => ()
    Some(values) => {
      let normals = morphed_source(node, values, false)
      write_skinned(
        geometry, "normal", normals, self, bones, bind_inverse, false,
      )
    }
  }
  geometry.bounding_box = None
  geometry.bounding_sphere = None
  geometry.version = geometry.version + 1
}

///|
/// 深度优先，把每个带蒙皮的网格从绑定姿态重算一遍。
/// r186: `update` https://github.com/mrdoob/three.js/blob/r186/src/objects/Skeleton.js#L199
pub fn apply_skins(root : Object3D) -> Unit {
  root.traverse(fn(node) {
    match node.skin {
      None => ()
      Some(state) =>
        match node.mesh {
          None => ()
          Some(binding) => state.write(node, binding.geometry)
        }
    }
  })
}

///|
/// 形变增量先加进绑定姿态，再交给蒙皮。glTF 的增量是相对底数的。
/// r186: `morphtarget_vertex` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/morphtarget_vertex.glsl.js#L11 ; `skinning_vertex` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/skinning_vertex.glsl.js#L4
fn morphed_source(
  node : Object3D,
  bind : Array[Double],
  position : Bool,
) -> Array[Double] {
  match node.morph {
    None => bind
    Some(morph) => {
      let base = if position {
        Some(morph.base_position)
      } else {
        morph.base_normal
      }
      match base {
        None => bind
        Some(values) => {
          let out = values.copy()
          let mut index = 0
          while index < morph.targets.length() {
            let weight = if index < morph.weights.length() {
              morph.weights[index]
            } else {
              0.0
            }
            if weight != 0.0 {
              let deltas = if position {
                morph.targets[index].position
              } else {
                morph.targets[index].normal
              }
              match deltas {
                None => ()
                Some(deltas) => {
                  let mut component = 0
                  while component < out.length() && component < deltas.length() {
                    out[component] = out[component] + deltas[component] * weight
                    component = component + 1
                  }
                }
              }
            }
            index = index + 1
          }
          out
        }
      }
    }
  }
}

///|
/// r186: `update` https://github.com/mrdoob/three.js/blob/r186/src/objects/Skeleton.js#L199
fn bone_matrices(skin : SkinState) -> Array[@math.Matrix4] {
  let count = if skin.joints.length() < skin.inverse_binds.length() {
    skin.joints.length()
  } else {
    skin.inverse_binds.length()
  }
  let bones = []
  let mut index = 0
  while index < count {
    let bone = @math.Matrix4::new()
    ignore(
      bone.multiply_matrices(
        skin.joints[index].matrix_world,
        skin.inverse_binds[index],
      ),
    )
    bones.push(bone)
    index = index + 1
  }
  bones
}

///|
fn write_skinned(
  geometry : BufferGeometry,
  name : String,
  bind : Array[Double],
  skin : SkinState,
  bones : Array[@math.Matrix4],
  bind_inverse : @math.Matrix4,
  point : Bool,
) -> Unit {
  match geometry.get_attribute(name) {
    None => ()
    Some(attribute) => {
      let count = bind.length() / 3
      let mut vertex = 0
      while vertex < count {
        let base = vertex * 3
        if base + 2 >= attribute.array.length() {
          vertex = count
        } else {
          let w = if point { 1.0 } else { 0.0 }
          let acc = skin_vertex(
            bones,
            skin.indices,
            skin.weights,
            vertex,
            bind[base],
            bind[base + 1],
            bind[base + 2],
            w,
          )
          ignore(acc.apply_matrix4(bind_inverse))
          if point {
            attribute.array[base] = acc.x
            attribute.array[base + 1] = acc.y
            attribute.array[base + 2] = acc.z
          } else {
            let normal = @math.Vector3::new(x=acc.x, y=acc.y, z=acc.z).normalize()
            attribute.array[base] = normal.x
            attribute.array[base + 1] = normal.y
            attribute.array[base + 2] = normal.z
          }
          vertex = vertex + 1
        }
      }
    }
  }
}

///|
fn skin_vertex(
  bones : Array[@math.Matrix4],
  indices : Array[Int],
  weights : Array[Double],
  vertex : Int,
  x : Double,
  y : Double,
  z : Double,
  w : Double,
) -> @math.Vector4 {
  let acc = @math.Vector4::new(w=0.0)
  let mut influence = 0
  while influence < 4 {
    let at = vertex * 4 + influence
    if at < weights.length() && at < indices.length() {
      let weight = weights[at]
      if weight != 0.0 {
        let joint = indices[at]
        if joint >= 0 && joint < bones.length() {
          let posed = @math.Vector4::new(x~, y~, z~, w~).apply_matrix4(
            bones[joint],
          )
          acc.x = acc.x + posed.x * weight
          acc.y = acc.y + posed.y * weight
          acc.z = acc.z + posed.z * weight
          acc.w = acc.w + posed.w * weight
        }
      }
    }
    influence = influence + 1
  }
  acc
}
