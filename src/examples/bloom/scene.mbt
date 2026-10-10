///|
using @cameras {type PerspectiveCamera}

///|
using @objects {type Mesh}

///|
using @post {type BloomPass}

///|
using @scenes {type Scene}

///|
using @textures {type RenderTarget}

///|
/// 离屏场景是一盏光下的立方体。窗口由一级全分辨率泛光呈现，不另建屏幕网格。
pub(all) struct BloomScene {
  scene : Scene
  camera : PerspectiveCamera
  cube : Mesh
  target : RenderTarget
  pass : BloomPass
  mut angle : Double
}

///|
pub fn BloomScene::new() -> BloomScene {
  let target = RenderTarget::new(256, 256)
  let scene = Scene::new()
  scene.set_background(@math.Color::new().set_hex(0x0D1A33))
  let cube = Mesh::new(
    @geometries.BoxGeometry::new().geometry,
    @materials.MeshLambertMaterial::new(hex=0xE27A3F).material,
  )
  ignore(scene.add(cube))
  let ambient = @lights.AmbientLight::new(hex=0xFFFFFF, intensity=0.35)
  ignore(scene.add(ambient))
  let sun = @lights.DirectionalLight::new(hex=0xFFFFFF, intensity=1.6)
  ignore(sun.node.position.set(2.0, 3.0, 4.0))
  ignore(scene.add(sun))
  let camera = PerspectiveCamera::new(fov=50.0, aspect=1.0, near=0.1, far=100.0)
  ignore(camera.node.position.set(0.0, 0.8, 3.0))
  camera.node.look_at(0.0, 0.0, 0.0)
  {
    scene,
    camera,
    cube,
    target,
    pass: BloomPass::new(threshold=0.2),
    angle: 0.0,
  }
}

///|
/// 每帧让立方体绕 Y 轴转过 `delta` 弧度。阈值保持 0.2，强度 1，半径 0。
pub fn BloomScene::spin(self : BloomScene, delta : Double) -> Unit {
  self.angle = self.angle + delta
  ignore(self.cube.node.rotation.set(0.35, self.angle, 0.0))
}
