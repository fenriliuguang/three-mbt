// r186: `RenderObject` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderObject.js#L65 ; `material` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L75

///|
/// 挂在网格节点上的绘制数据。颜色与材质共享同一个 `Color`。
/// r186: `RenderObject` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/RenderObject.js#L65
pub(all) struct MeshBinding {
  mut geometry : BufferGeometry
  color : @math.Color
  shading : @constants.Shading
  mut side : @constants.Side
  mut shadow_side : @constants.Side?
  mut opacity : Double
  mut transparent : Bool
  mut wireframe : Bool
  map : @textures.Texture?
  roughness : Double
  metalness : Double
  fog : Bool
  mut alpha_test : Double
  flat_shading : Bool
  depth_write : Bool
  depth_test : Bool
  depth_func : @constants.DepthFunc
  color_write : Bool
  premultiplied_alpha : Bool
  mut visible : Bool
  force_single_pass : Bool
  emissive : @math.Color
  mut emissive_intensity : Double
  emissive_map : @textures.Texture?
  roughness_map : @textures.Texture?
  metalness_map : @textures.Texture?
  alpha_map : @textures.Texture?
  instances : InstanceData?
  group_sides : Array[@constants.Side]?
  group_draws : Array[MaterialDraw]?
}

///|
/// 材质数组里的一份绘制参数。没有同名上游类型，字段来自网格材质。
/// r186: `material` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L75
pub(all) struct MaterialDraw {
  color : @math.Color
  shading : @constants.Shading
  side : @constants.Side
  shadow_side : @constants.Side?
  opacity : Double
  transparent : Bool
  wireframe : Bool
  visible : Bool
  map : @textures.Texture?
  roughness : Double
  metalness : Double
  fog : Bool
  alpha_test : Double
  flat_shading : Bool
  depth_write : Bool
  depth_test : Bool
  depth_func : @constants.DepthFunc
  color_write : Bool
  premultiplied_alpha : Bool
  force_single_pass : Bool
  emissive : @math.Color
  emissive_intensity : Double
  emissive_map : @textures.Texture?
  roughness_map : @textures.Texture?
  metalness_map : @textures.Texture?
  alpha_map : @textures.Texture?
}

///|
/// `InstancedMesh` 的实例数据。矩阵是列主序 16 个数，颜色是可选的 `rgb`。
/// `count` 可以小于矩阵容量。`version` 在矩阵或颜色改动后加一，供渲染器决定是否重传。
/// r186: `InstancedMesh` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L28
pub(all) struct InstanceData {
  matrices : BufferAttribute
  mut colors : BufferAttribute?
  mut count : Int
  mut version : Int
  mut bounding_sphere : @math.Sphere?
}

///|
fn read_instance_matrix(
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
/// 局部包围球：几何体包围球按每个实例矩阵变换后再求并。
/// r186: `computeBoundingSphere` https://github.com/mrdoob/three.js/blob/r186/src/objects/InstancedMesh.js#L151
pub fn InstanceData::compute_bounding_sphere(
  self : InstanceData,
  geometry : BufferGeometry,
) -> @math.Sphere {
  geometry.compute_bounding_sphere()
  let sphere = match self.bounding_sphere {
    Some(sphere) => sphere
    None => {
      let sphere = @math.Sphere::new()
      self.bounding_sphere = Some(sphere)
      sphere
    }
  }
  ignore(sphere.make_empty())
  match geometry.bounding_sphere {
    None => ()
    Some(geometry_sphere) => {
      let matrix = @math.Matrix4::new()
      let mut index = 0
      while index < self.count {
        read_instance_matrix(self.matrices, index, matrix)
        let transformed = @math.Sphere::new()
        ignore(transformed.copy(geometry_sphere).apply_matrix4(matrix))
        ignore(sphere.union(transformed))
        index = index + 1
      }
    }
  }
  sphere
}

///|
/// 点、折线和线段。`Line` 是折线，`LineSegments` 是成对线段。
/// r186: `Points` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L19
pub(all) enum PrimitiveKind {
  Points
  Line
  LineSegments
}

///|
/// 挂在点或线上的绘制数据。线宽在 WebGPU 里固定为 1 像素。
/// r186: `Points` https://github.com/mrdoob/three.js/blob/r186/src/objects/Points.js#L19
pub(all) struct PrimitiveBinding {
  geometry : BufferGeometry
  color : @math.Color
  kind : PrimitiveKind
  size : Double
  size_attenuation : Bool
  opacity : Double
  transparent : Bool
  fog : Bool
  depth_write : Bool
  depth_test : Bool
  depth_func : @constants.DepthFunc
  color_write : Bool
  premultiplied_alpha : Bool
  visible : Bool
}

///|
/// 平行光的阴影相机和参数。`camera` 是正交相机节点。
/// r186: `LightShadow` https://github.com/mrdoob/three.js/blob/r186/src/lights/LightShadow.js#L18
pub(all) struct ShadowState {
  camera : Object3D
  mut map_size : Int
  mut bias : Double
  mut normal_bias : Double
  mut radius : Double
}

///|
/// 挂在灯光节点上的数据。平行光的 `target` 是另一个场景节点。
/// `shadow` 只在平行光上有值。是否绘制由节点的 `cast_shadow` 决定。
/// r186: `Light` https://github.com/mrdoob/three.js/blob/r186/src/lights/Light.js#L11
pub(all) struct LightState {
  color : @math.Color
  ground_color : @math.Color
  mut intensity : Double
  mut distance : Double
  mut decay : Double
  mut angle : Double
  mut penumbra : Double
  mut target : Object3D?
  kind : LightKind
  mut shadow : ShadowState?
}
