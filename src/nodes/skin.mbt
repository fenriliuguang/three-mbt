// r186: `skinning_vertex` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/skinning_vertex.glsl.js#L4 ; `compute` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Renderer.js#L2877

///|
/// 蒙皮计算着色器。每个顶点 12 个 `f32`，与绘制用的 48 字节布局一致。
/// 第 0 个绑定逆矩阵在 uniform 里。骨骼矩阵、关节和权重是只读存储。
/// 权重为 0 或关节越界的影响跳过。无法线时 `skin_normal` 为 0，法线原样拷贝。
/// r186: `compute` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Renderer.js#L2877
pub fn skin_wgsl() -> String {
  "struct SkinParams {\n" +
  "  bind_inverse : mat4x4<f32>,\n" +
  "  vertex_count : u32,\n" +
  "  bone_count : u32,\n" +
  "  stride : u32,\n" +
  "  skin_normal : u32,\n" +
  "}\n" +
  "\n" +
  "@group(0) @binding(0) var<storage, read> src : array<f32>;\n" +
  "@group(0) @binding(1) var<storage, read_write> dst : array<f32>;\n" +
  "@group(0) @binding(2) var<storage, read> bones : array<mat4x4<f32>>;\n" +
  "@group(0) @binding(3) var<storage, read> joints : array<u32>;\n" +
  "@group(0) @binding(4) var<storage, read> weights : array<f32>;\n" +
  "@group(0) @binding(5) var<uniform> params : SkinParams;\n" +
  "\n" +
  "@compute @workgroup_size(64)\n" +
  "fn main(@builtin(global_invocation_id) id : vec3<u32>) {\n" +
  "  let vertex = id.x;\n" +
  "  if (vertex >= params.vertex_count) {\n" +
  "    return;\n" +
  "  }\n" +
  "  let base = vertex * 12u;\n" +
  "  let position = vec4<f32>(src[base], src[base + 1u], src[base + 2u], 1.0);\n" +
  "  let normal = vec4<f32>(src[base + 3u], src[base + 4u], src[base + 5u], 0.0);\n" +
  "  var acc_position = vec4<f32>(0.0);\n" +
  "  var acc_normal = vec4<f32>(0.0);\n" +
  "  for (var influence = 0u; influence < params.stride; influence = influence + 1u) {\n" +
  "    let at = vertex * params.stride + influence;\n" +
  "    let weight = weights[at];\n" +
  "    let joint = joints[at];\n" +
  "    if (weight != 0.0 && joint < params.bone_count) {\n" +
  "      let bone = bones[joint];\n" +
  "      acc_position = acc_position + weight * (bone * position);\n" +
  "      acc_normal = acc_normal + weight * (bone * normal);\n" +
  "    }\n" +
  "  }\n" +
  "  let skinned = params.bind_inverse * acc_position;\n" +
  "  dst[base] = skinned.x;\n" +
  "  dst[base + 1u] = skinned.y;\n" +
  "  dst[base + 2u] = skinned.z;\n" +
  "  if (params.skin_normal != 0u) {\n" +
  "    let turned = params.bind_inverse * acc_normal;\n" +
  "    let len = length(turned.xyz);\n" +
  "    let scaled = select(vec3<f32>(0.0), turned.xyz / vec3<f32>(max(len, 1e-20)), len == 0.0);\n" +
  "    dst[base + 3u] = scaled.x;\n" +
  "    dst[base + 4u] = scaled.y;\n" +
  "    dst[base + 5u] = scaled.z;\n" +
  "  } else {\n" +
  "    dst[base + 3u] = src[base + 3u];\n" +
  "    dst[base + 4u] = src[base + 4u];\n" +
  "    dst[base + 5u] = src[base + 5u];\n" +
  "  }\n" +
  "  dst[base + 6u] = src[base + 6u];\n" +
  "  dst[base + 7u] = src[base + 7u];\n" +
  "  dst[base + 8u] = src[base + 8u];\n" +
  "  dst[base + 9u] = src[base + 9u];\n" +
  "  dst[base + 10u] = src[base + 10u];\n" +
  "  dst[base + 11u] = src[base + 11u];\n" +
  "}\n"
}
