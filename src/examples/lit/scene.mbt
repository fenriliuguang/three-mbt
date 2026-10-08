///|
using @cameras {type PerspectiveCamera}

///|
using @objects {type Mesh}

///|
using @scenes {type Scene}

///|
/// 橙色 Lambert 立方体。环境光压暗阴影，平行光从上方偏前打过来。
pub(all) struct LitScene {
  scene : Scene
  camera : PerspectiveCamera
  mesh : Mesh
  mut angle : Double
}

///|
pub fn LitScene::new() -> LitScene {
  let scene = Scene::new()
  scene.set_background(@math.Color::new().set_hex(0x0D1A33))
  let box = @geometries.BoxGeometry::new()
  let lambert = @materials.MeshLambertMaterial::new(hex=0xFF8800)
  let mesh = Mesh::new(box.geometry, lambert.material)
  ignore(scene.add(mesh))
  let ambient = @lights.AmbientLight::new(hex=0x404040, intensity=1.0)
  ignore(scene.add(ambient))
  let sun = @lights.DirectionalLight::new(hex=0xFFFFFF, intensity=1.0)
  ignore(sun.node.position.set(2.0, 4.0, 3.0))
  ignore(scene.add(sun))
  let camera = PerspectiveCamera::new(fov=50.0, aspect=1.0, near=0.1, far=100.0)
  ignore(camera.node.position.set(0.0, 0.8, 3.0))
  camera.node.look_at(0.0, 0.0, 0.0)
  { scene, camera, mesh, angle: 0.0, }
}

///|
/// 每帧绕 Y 轴转过 `delta` 弧度。
pub fn LitScene::spin(self : LitScene, delta : Double) -> Unit {
  self.angle = self.angle + delta
  ignore(self.mesh.node.rotation.set(0.35, self.angle, 0.0))
}
