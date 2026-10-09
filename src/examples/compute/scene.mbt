///|
using @cameras {type PerspectiveCamera}

///|
using @kernel {type StoragePositions}

///|
using @objects {type Points}

///|
using @scenes {type Scene}

///|
/// 65 个点，X 从 -1 到 1。Y 是 `sin(x π + time) * 0.5`，由计算着色器每帧写入。
pub(all) struct ComputeScene {
  scene : Scene
  camera : PerspectiveCamera
  points : Points
  positions : StoragePositions
}

///|
pub fn ComputeScene::new() -> ComputeScene {
  let positions = StoragePositions::new(65)
  let scene = Scene::new()
  scene.set_background(@math.Color::new().set_hex(0x0D1A33))
  let points = Points::new(
    positions.geometry,
    @materials.PointsMaterial::new(
      hex=0x7FD4FF,
      size=16.0,
      size_attenuation=true,
    ),
  )
  ignore(scene.add(points))
  let camera = PerspectiveCamera::new(fov=50.0, aspect=1.0, near=0.1, far=100.0)
  ignore(camera.node.position.set(0.0, 0.4, 3.5))
  camera.node.look_at(0.0, 0.0, 0.0)
  { scene, camera, points, positions, }
}

///|
/// 推进波形的时间。窗口循环里还要调用渲染器的 `compute`。
pub fn ComputeScene::step(self : ComputeScene, delta : Double) -> Unit {
  self.positions.set_time(self.positions.time + delta)
}
