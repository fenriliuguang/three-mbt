// r186: `applyBoneTransform` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L319 ; `skinning_vertex` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/skinning_vertex.glsl.js#L4

///|
/// 用和 `SkinState::write` 相同的公式，把绑定姿态加形变后的顶点蒙进 48 字节交错缓冲。
/// 计算着色器按同样的布局读这份数据。没有绑定法线时法线保持打包时的 `(0, 0, 1)`。
/// r186: `applyBoneTransform` https://github.com/mrdoob/three.js/blob/r186/src/objects/SkinnedMesh.js#L319
pub fn skinned_vertex_bytes(
  node : @core.Object3D,
  geometry : @core.BufferGeometry,
  skin : @core.SkinState,
) -> FixedArray[Byte] {
  let positions = skin.source_position(node)
  let normal = match skin.source_normal(node) {
    None => None
    Some(values) => Some(@core.BufferAttribute::new(values, 3))
  }
  let packed = pack_position_normal_uv(
    @core.BufferAttribute::new(positions, 3),
    normal,
    geometry.get_attribute("uv"),
    color=geometry.get_attribute("color"),
  )
  let bones = skin.bone_palette()
  let bind_inverse = @math.Matrix4::new()
  ignore(bind_inverse.copy(node.matrix_world).invert())
  let stride = skin.influence_width()
  let count = positions.length() / 3
  let mut vertex = 0
  while vertex < count {
    let base = vertex * vertex_stride
    let x = read_f32(packed, base)
    let y = read_f32(packed, base + 4)
    let z = read_f32(packed, base + 8)
    let posed = skin_accumulated(
      bones,
      skin.indices,
      skin.weights,
      vertex,
      stride,
      x,
      y,
      z,
      1.0,
    )
    ignore(posed.apply_matrix4(bind_inverse))
    write_f32(packed, base, posed.x)
    write_f32(packed, base + 4, posed.y)
    write_f32(packed, base + 8, posed.z)
    if normal is Some(_) {
      let nx = read_f32(packed, base + 12)
      let ny = read_f32(packed, base + 16)
      let nz = read_f32(packed, base + 20)
      let nposed = skin_accumulated(
        bones,
        skin.indices,
        skin.weights,
        vertex,
        stride,
        nx,
        ny,
        nz,
        0.0,
      )
      ignore(nposed.apply_matrix4(bind_inverse))
      let normal = @math.Vector3::new(x=nposed.x, y=nposed.y, z=nposed.z).normalize()
      write_f32(packed, base + 12, normal.x)
      write_f32(packed, base + 16, normal.y)
      write_f32(packed, base + 20, normal.z)
    }
    vertex = vertex + 1
  }
  packed
}

///|
fn skin_accumulated(
  bones : Array[@math.Matrix4],
  indices : Array[Int32],
  weights : Array[Double],
  vertex : Int32,
  stride : Int32,
  x : Double,
  y : Double,
  z : Double,
  w : Double,
) -> @math.Vector4 {
  let acc = @math.Vector4::new(w=0.0)
  let mut influence = 0
  while influence < stride {
    let at = vertex * stride + influence
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

///|
fn read_f32(src : FixedArray[Byte], offset : Int32) -> Double {
  let bits = src[offset].to_int() +
    (src[offset + 1].to_int() << 8) +
    (src[offset + 2].to_int() << 16) +
    (src[offset + 3].to_int() << 24)
  Float::reinterpret_from_uint(bits.reinterpret_as_uint()).to_double()
}
