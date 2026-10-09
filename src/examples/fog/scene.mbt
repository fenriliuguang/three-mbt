///|
using @cameras {type PerspectiveCamera}

///|
using @objects {type Mesh}

///|
using @scenes {type Fog, type Scene}

///|
fn cube_at(scene : Scene, hex : Int, z : Double) -> Mesh {
  let mesh = Mesh::new(
    @geometries.BoxGeometry::new().geometry,
    @materials.MeshLambertMaterial::new(hex~).material,
  )
  ignore(mesh.node.position.set(0.0, 0.0, z))
  ignore(scene.add(mesh))
  mesh
}

///|
/// 三个立方体从近到远。雾从深度 4 开始，到 12 完全变成背景色。
pub(all) struct FogScene {
  scene : Scene
  camera : PerspectiveCamera
  near_cube : Mesh
  mid_cube : Mesh
  far_cube : Mesh
  mut angle : Double
}

///|
pub fn FogScene::new() -> FogScene {
  let scene = Scene::new()
  let fog = Fog::linear(hex=0xC5D0D8, near=4.0, far=12.0)
  scene.set_background(fog.color)
  scene.set_fog(Some(fog))
  let near_cube = cube_at(scene, 0xE25B3A, 0.0)
  let mid_cube = cube_at(scene, 0xE2A23A, -3.0)
  let far_cube = cube_at(scene, 0x3A7BE2, -6.0)
  let ambient = @lights.AmbientLight::new(hex=0xFFFFFF, intensity=0.35)
  ignore(scene.add(ambient))
  let sun = @lights.DirectionalLight::new(hex=0xFFFFFF, intensity=1.6)
  ignore(sun.node.position.set(3.0, 5.0, 4.0))
  ignore(scene.add(sun))
  let camera = PerspectiveCamera::new(fov=50.0, aspect=1.0, near=0.1, far=100.0)
  ignore(camera.node.position.set(0.0, 1.5, 5.0))
  camera.node.look_at(0.0, 0.0, -3.0)
  { scene, camera, near_cube, mid_cube, far_cube, angle: 0.0, }
}

///|
/// 每帧让三个立方体绕 Y 轴转过 `delta` 弧度。
pub fn FogScene::spin(self : FogScene, delta : Double) -> Unit {
  self.angle = self.angle + delta
  ignore(self.near_cube.node.rotation.set(0.2, self.angle, 0.0))
  ignore(self.mid_cube.node.rotation.set(0.2, self.angle, 0.0))
  ignore(self.far_cube.node.rotation.set(0.2, self.angle, 0.0))
}
