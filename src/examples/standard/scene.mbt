///|
using @cameras {type PerspectiveCamera}

///|
using @objects {type Mesh}

///|
using @scenes {type Scene}

///|
/// 暖色 Standard 立方体。粗糙度 0.4、金属度 0.6，平行光强度略高，方便看出高光。
pub(all) struct StandardScene {
  scene : Scene
  camera : PerspectiveCamera
  mesh : Mesh
  mut angle : Double
}

///|
pub fn StandardScene::new() -> StandardScene {
  let scene = Scene::new()
  scene.set_background(@math.Color::new().set_hex(0x0D1A33))
  let box = @geometries.BoxGeometry::new()
  let standard = @materials.MeshStandardMaterial::new(
    hex=0xC4783A,
    roughness=0.4,
    metalness=0.6,
  )
  let mesh = Mesh::new(box.geometry, standard.material)
  ignore(scene.add(mesh))
  let ambient = @lights.AmbientLight::new(hex=0x404040, intensity=1.0)
  ignore(scene.add(ambient))
  let sun = @lights.DirectionalLight::new(hex=0xFFFFFF, intensity=2.0)
  ignore(sun.node.position.set(2.0, 4.0, 3.0))
  ignore(scene.add(sun))
  let camera = PerspectiveCamera::new(fov=50.0, aspect=1.0, near=0.1, far=100.0)
  ignore(camera.node.position.set(0.0, 0.8, 3.0))
  camera.node.look_at(0.0, 0.0, 0.0)
  { scene, camera, mesh, angle: 0.0, }
}

///|
/// 每帧绕 Y 轴转过 `delta` 弧度。
pub fn StandardScene::spin(self : StandardScene, delta : Double) -> Unit {
  self.angle = self.angle + delta
  ignore(self.mesh.node.rotation.set(0.35, self.angle, 0.0))
}
