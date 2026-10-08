///|
using @cameras {type PerspectiveCamera}

///|
using @objects {type Mesh}

///|
using @scenes {type Scene}

///|
/// 一个橙色单位立方体，相机从前方看向原点。
pub(all) struct CubeScene {
  scene : Scene
  camera : PerspectiveCamera
  mesh : Mesh
  mut angle : Double
}

///|
pub fn CubeScene::new() -> CubeScene {
  let scene = Scene::new()
  scene.set_background(@math.Color::new().set_hex(0x0D1A33))
  let box = @geometries.BoxGeometry::new()
  let basic = @materials.MeshBasicMaterial::new(hex=0xFF8800)
  let mesh = Mesh::new(box.geometry, basic.material)
  ignore(scene.add(mesh))
  let camera = PerspectiveCamera::new(fov=50.0, aspect=1.0, near=0.1, far=100.0)
  ignore(camera.node.position.set(0.0, 0.8, 3.0))
  camera.node.look_at(0.0, 0.0, 0.0)
  { scene, camera, mesh, angle: 0.0, }
}

///|
/// 每帧绕 Y 轴转过 `delta` 弧度。
pub fn CubeScene::spin(self : CubeScene, delta : Double) -> Unit {
  self.angle = self.angle + delta
  ignore(self.mesh.node.rotation.set(0.35, self.angle, 0.0))
}
