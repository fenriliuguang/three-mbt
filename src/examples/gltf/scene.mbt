///|
using @cameras {type PerspectiveCamera}

///|
using @objects {type Group}

///|
using @scenes {type Scene}

///|
/// 内嵌 glTF 里的单位立方体。颜色是线性的 (1, 0.5, 0.25)，粗糙度 0.25，金属度 0。
pub(all) struct GltfScene {
  scene : Scene
  camera : PerspectiveCamera
  root : Group
  mut angle : Double
}

///|
pub fn GltfScene::new() -> GltfScene {
  let root = @loader.parse(box_gltf()) catch { _ => panic() }
  let scene = Scene::new()
  scene.set_background(@math.Color::new().set_hex(0x0D1A33))
  ignore(scene.add(root))
  let ambient = @lights.AmbientLight::new(hex=0x404040, intensity=1.0)
  ignore(scene.add(ambient))
  let sun = @lights.DirectionalLight::new(hex=0xFFFFFF, intensity=2.0)
  ignore(sun.node.position.set(2.0, 4.0, 3.0))
  ignore(scene.add(sun))
  let camera = PerspectiveCamera::new(fov=50.0, aspect=1.0, near=0.1, far=100.0)
  ignore(camera.node.position.set(0.0, 0.8, 3.0))
  camera.node.look_at(0.0, 0.0, 0.0)
  { scene, camera, root, angle: 0.0, }
}

///|
/// 每帧绕 Y 轴转过 `delta` 弧度。
pub fn GltfScene::spin(self : GltfScene, delta : Double) -> Unit {
  self.angle = self.angle + delta
  ignore(self.root.node.rotation.set(0.35, self.angle, 0.0))
}
