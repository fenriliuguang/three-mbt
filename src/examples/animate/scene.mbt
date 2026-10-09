///|
using @cameras {type PerspectiveCamera}

///|
using @objects {type Mesh}

///|
using @scenes {type Scene}

///|
using @animation {type AnimationMixer}

///|
/// 两秒一个来回：升到 y = 1 并转到 180 度，再回到原点。
pub(all) struct AnimateScene {
  scene : Scene
  camera : PerspectiveCamera
  mesh : Mesh
  mixer : AnimationMixer
}

///|
pub fn AnimateScene::new() -> AnimateScene {
  let scene = Scene::new()
  scene.set_background(@math.Color::new().set_hex(0x0D1A33))
  let mesh = Mesh::new(
    @geometries.BoxGeometry::new().geometry,
    @materials.MeshLambertMaterial::new(hex=0xFF8800).material,
  )
  ignore(scene.add(mesh))
  let ambient = @lights.AmbientLight::new(hex=0x404040, intensity=1.0)
  ignore(scene.add(ambient))
  let sun = @lights.DirectionalLight::new(hex=0xFFFFFF, intensity=1.0)
  ignore(sun.node.position.set(2.0, 4.0, 3.0))
  ignore(scene.add(sun))
  let camera = PerspectiveCamera::new(fov=50.0, aspect=1.0, near=0.1, far=100.0)
  ignore(camera.node.position.set(0.0, 1.2, 4.0))
  camera.node.look_at(0.0, 0.5, 0.0)
  let position = @animation.KeyframeTrack::vector(
    ".position",
    [0.0, 1.0, 2.0],
    [0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0],
  )
  let rotation = @animation.KeyframeTrack::quaternion(
    ".quaternion",
    [0.0, 1.0, 2.0],
    [0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0],
  )
  let mixer = AnimationMixer::new(mesh.node)
  let clip = @animation.AnimationClip::new("bob", [position, rotation])
  mixer.clip_action(clip).play()
  { scene, camera, mesh, mixer, }
}

///|
/// 推进混合器 `delta` 秒。
pub fn AnimateScene::step(self : AnimateScene, delta : Double) -> Unit {
  self.mixer.update(delta)
}
