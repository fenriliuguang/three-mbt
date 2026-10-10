///|
using @cameras {type PerspectiveCamera}

///|
using @effect {type GrayscalePass}

///|
using @objects {type Mesh}

///|
using @scenes {type Scene}

///|
using @textures {type RenderTarget}

///|
/// 离屏场景是一盏光下的立方体。窗口由灰度全屏通道呈现，不另建屏幕网格。
pub(all) struct PostScene {
  scene : Scene
  camera : PerspectiveCamera
  cube : Mesh
  target : RenderTarget
  pass : GrayscalePass
  mut angle : Double
}

///|
pub fn PostScene::new() -> PostScene {
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
    pass: GrayscalePass::new(amount=0.5),
    angle: 0.0,
  }
}

///|
/// 每帧让立方体绕 Y 轴转过 `delta` 弧度。灰度系数保持 0.5。
pub fn PostScene::spin(self : PostScene, delta : Double) -> Unit {
  self.angle = self.angle + delta
  ignore(self.cube.node.rotation.set(0.35, self.angle, 0.0))
}
