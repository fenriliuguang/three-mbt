///|
using @cameras {type PerspectiveCamera}

///|
using @objects {type Mesh}

///|
using @scenes {type Scene}

///|
using @textures {type Texture}

///|
fn clamp_pitch(pitch : Double) -> Double {
  if pitch > 1.2 {
    1.2
  } else if pitch < -1.2 {
    -1.2
  } else {
    pitch
  }
}

///|
/// 白色 Lambert 立方体，表面是 `rgba8` 棋盘格。指针拖动时相机绕原点转。
pub(all) struct TexturedScene {
  scene : Scene
  camera : PerspectiveCamera
  mesh : Mesh
  map : Texture
  mut angle : Double
  mut yaw : Double
  mut pitch : Double
  radius : Double
  mut dragging : Bool
  mut last_x : Double
  mut last_y : Double
}

///|
fn TexturedScene::place_camera(self : TexturedScene) -> Unit {
  let horizontal = @std.cos(self.pitch)
  let x = self.radius * @std.sin(self.yaw) * horizontal
  let y = self.radius * @std.sin(self.pitch)
  let z = self.radius * @std.cos(self.yaw) * horizontal
  ignore(self.camera.node.position.set(x, y, z))
  self.camera.node.look_at(0.0, 0.0, 0.0)
}

///|
pub fn TexturedScene::new() -> TexturedScene {
  let scene = Scene::new()
  scene.set_background(@math.Color::new().set_hex(0x0D1A33))
  let box = @geometries.BoxGeometry::new()
  let lambert = @materials.MeshLambertMaterial::new(hex=0xFFFFFF)
  let mesh = Mesh::new(box.geometry, lambert.material)
  let map = Texture::checker(
    width=4,
    height=4,
    cell=1,
    first=0xF4F1DE,
    second=0x3D405B,
  )
  mesh.set_map(Some(map))
  ignore(scene.add(mesh))
  let ambient = @lights.AmbientLight::new(hex=0x404040, intensity=1.0)
  ignore(scene.add(ambient))
  let sun = @lights.DirectionalLight::new(hex=0xFFFFFF, intensity=1.0)
  ignore(sun.node.position.set(2.0, 4.0, 3.0))
  ignore(scene.add(sun))
  let camera = PerspectiveCamera::new(fov=50.0, aspect=1.0, near=0.1, far=100.0)
  let world = {
    scene,
    camera,
    mesh,
    map,
    angle: 0.0,
    yaw: 0.0,
    pitch: 0.25,
    radius: 3.2,
    dragging: false,
    last_x: 0.0,
    last_y: 0.0,
  }
  world.place_camera()
  world
}

///|
/// 每帧绕 Y 轴转过 `delta` 弧度。
pub fn TexturedScene::spin(self : TexturedScene, delta : Double) -> Unit {
  self.angle = self.angle + delta
  ignore(self.mesh.node.rotation.set(0.35, self.angle, 0.0))
}

///|
/// 开始拖动。坐标是表面给的指针位置，样本自己解释，渲染器不读它。
pub fn TexturedScene::pointer_down(
  self : TexturedScene,
  x : Double,
  y : Double,
) -> Unit {
  self.dragging = true
  self.last_x = x
  self.last_y = y
}

///|
pub fn TexturedScene::pointer_up(self : TexturedScene) -> Unit {
  self.dragging = false
}

///|
/// 拖动时用位移改相机的 yaw 和 pitch。未按下时只记住位置，避免下一次拖动跳变。
pub fn TexturedScene::pointer_move(
  self : TexturedScene,
  x : Double,
  y : Double,
) -> Unit {
  let dx = x - self.last_x
  let dy = y - self.last_y
  self.last_x = x
  self.last_y = y
  if !self.dragging {
    return
  }
  self.yaw = self.yaw - dx * 0.01
  self.pitch = clamp_pitch(self.pitch + dy * 0.01)
  self.place_camera()
}
