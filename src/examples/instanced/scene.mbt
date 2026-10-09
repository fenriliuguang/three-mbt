///|
using @cameras {type PerspectiveCamera}

///|
using @objects {type InstancedMesh}

///|
using @scenes {type Scene}

///|
/// 三个 Lambert 立方体共用一个网格。颜色和位置都写在实例上。
pub(all) struct InstancedScene {
  scene : Scene
  camera : PerspectiveCamera
  mesh : InstancedMesh
  mut angle : Double
}

///|
pub fn InstancedScene::new() -> InstancedScene {
  let scene = Scene::new()
  scene.set_background(@math.Color::new().set_hex(0x0D1A33))
  let box = @geometries.BoxGeometry::new()
  let lambert = @materials.MeshLambertMaterial::new(hex=0xFFFFFF)
  let mesh = InstancedMesh::new(box.geometry, lambert.material, 3)
  let matrix = @math.Matrix4::new()
  ignore(matrix.make_translation(-1.5, 0.0, 0.0))
  mesh.set_matrix_at(0, matrix)
  ignore(matrix.make_translation(0.0, 0.0, 0.0))
  mesh.set_matrix_at(1, matrix)
  ignore(matrix.make_translation(1.5, 0.0, 0.0))
  mesh.set_matrix_at(2, matrix)
  mesh.set_color_at(0, @math.Color::new().set_hex(0xE07A5F))
  mesh.set_color_at(1, @math.Color::new().set_hex(0xF2CC8F))
  mesh.set_color_at(2, @math.Color::new().set_hex(0x81B29A))
  ignore(scene.add(mesh))
  let ambient = @lights.AmbientLight::new(hex=0x404040, intensity=1.0)
  ignore(scene.add(ambient))
  let sun = @lights.DirectionalLight::new(hex=0xFFFFFF, intensity=1.5)
  ignore(sun.node.position.set(2.0, 4.0, 3.0))
  ignore(scene.add(sun))
  let camera = PerspectiveCamera::new(fov=50.0, aspect=1.0, near=0.1, far=100.0)
  ignore(camera.node.position.set(0.0, 0.8, 4.5))
  camera.node.look_at(0.0, 0.0, 0.0)
  { scene, camera, mesh, angle: 0.0, }
}

///|
/// 每帧让三个立方体一起绕 Y 轴转过 `delta` 弧度。
pub fn InstancedScene::spin(self : InstancedScene, delta : Double) -> Unit {
  self.angle = self.angle + delta
  ignore(self.mesh.node.rotation.set(0.2, self.angle, 0.0))
}
