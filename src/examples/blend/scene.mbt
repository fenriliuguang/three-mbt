///|
using @cameras {type PerspectiveCamera}

///|
using @objects {type Mesh}

///|
using @scenes {type Scene}

///|
/// 后面是不透明立方体，前面是不透明度为 0.5 的立方体。
pub(all) struct BlendScene {
  scene : Scene
  camera : PerspectiveCamera
  solid : Mesh
  glass : Mesh
  mut angle : Double
}

///|
pub fn BlendScene::new() -> BlendScene {
  let scene = Scene::new()
  scene.set_background(@math.Color::new().set_hex(0x0D1A33))
  let solid = Mesh::new(
    @geometries.BoxGeometry::new().geometry,
    @materials.MeshLambertMaterial::new(hex=0xE27A3F).material,
  )
  ignore(solid.node.position.set(0.0, 0.0, -0.6))
  ignore(scene.add(solid))
  let glass = Mesh::new(
    @geometries.BoxGeometry::new().geometry,
    @materials.MeshLambertMaterial::new(hex=0x3A7BE2).material,
  )
  glass.set_transparent(true, opacity=0.5)
  ignore(glass.node.position.set(0.0, 0.0, 0.6))
  ignore(scene.add(glass))
  let ambient = @lights.AmbientLight::new(hex=0xFFFFFF, intensity=0.35)
  ignore(scene.add(ambient))
  let sun = @lights.DirectionalLight::new(hex=0xFFFFFF, intensity=1.6)
  ignore(sun.node.position.set(2.0, 3.0, 4.0))
  ignore(scene.add(sun))
  let camera = PerspectiveCamera::new(fov=50.0, aspect=1.0, near=0.1, far=100.0)
  ignore(camera.node.position.set(0.0, 0.8, 3.0))
  camera.node.look_at(0.0, 0.0, 0.0)
  { scene, camera, solid, glass, angle: 0.0, }
}

///|
/// 每帧让两个立方体绕 Y 轴转过 `delta` 弧度。
pub fn BlendScene::spin(self : BlendScene, delta : Double) -> Unit {
  self.angle = self.angle + delta
  ignore(self.solid.node.rotation.set(0.35, self.angle, 0.0))
  ignore(self.glass.node.rotation.set(0.35, self.angle, 0.0))
}
