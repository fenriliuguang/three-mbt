///|
using @cameras {type OrthographicCamera, type PerspectiveCamera}

///|
using @objects {type Mesh}

///|
using @scenes {type Scene}

///|
using @textures {type RenderTarget}

///|
/// 屏幕四边形。颜色目标的画面顶在 v = 0，所以这里把 v 反过来，图像才是正的。
fn screen_quad() -> @core.BufferGeometry {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [-1.0, -1.0, 0.0, 1.0, -1.0, 0.0, 1.0, 1.0, 0.0, -1.0, 1.0, 0.0],
        3,
      ),
    ),
  )
  ignore(
    geometry.set_attribute(
      "normal",
      @core.BufferAttribute::new(
        [0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0],
        3,
      ),
    ),
  )
  ignore(
    geometry.set_attribute(
      "uv",
      @core.BufferAttribute::new([0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0], 2),
    ),
  )
  ignore(geometry.set_index_array([0, 1, 2, 0, 2, 3]))
  geometry
}

///|
/// 离屏场景里是一盏光下的立方体。屏幕场景用一张铺满窗口的四边形采样颜色目标。
pub(all) struct TargetScene {
  offscreen : Scene
  screen : Scene
  off_camera : PerspectiveCamera
  screen_camera : OrthographicCamera
  cube : Mesh
  quad : Mesh
  target : RenderTarget
  mut angle : Double
}

///|
pub fn TargetScene::new() -> TargetScene {
  let target = RenderTarget::new(256, 256)
  let offscreen = Scene::new()
  offscreen.set_background(@math.Color::new().set_hex(0x14384A))
  let cube = Mesh::new(
    @geometries.BoxGeometry::new().geometry,
    @materials.MeshLambertMaterial::new(hex=0xE27A3F).material,
  )
  ignore(offscreen.add(cube))
  let ambient = @lights.AmbientLight::new(hex=0xFFFFFF, intensity=0.35)
  ignore(offscreen.add(ambient))
  let sun = @lights.DirectionalLight::new(hex=0xFFFFFF, intensity=1.6)
  ignore(sun.node.position.set(2.0, 3.0, 4.0))
  ignore(offscreen.add(sun))
  let off_camera = PerspectiveCamera::new(
    fov=50.0,
    aspect=1.0,
    near=0.1,
    far=100.0,
  )
  ignore(off_camera.node.position.set(0.0, 0.8, 3.0))
  off_camera.node.look_at(0.0, 0.0, 0.0)
  let screen = Scene::new()
  screen.set_background(@math.Color::new().set_hex(0x111111))
  let quad = Mesh::new(
    screen_quad(),
    @materials.MeshBasicMaterial::new(hex=0xFFFFFF).material,
  )
  quad.set_map(Some(target.texture))
  ignore(screen.add(quad))
  let screen_camera = OrthographicCamera::new(
    left=-1.0,
    right=1.0,
    top=1.0,
    bottom=-1.0,
    near=0.1,
    far=10.0,
  )
  ignore(screen_camera.node.position.set(0.0, 0.0, 2.0))
  screen_camera.node.look_at(0.0, 0.0, 0.0)
  {
    offscreen,
    screen,
    off_camera,
    screen_camera,
    cube,
    quad,
    target,
    angle: 0.0,
  }
}

///|
/// 每帧让离屏立方体绕 Y 轴转过 `delta` 弧度。屏幕四边形不动。
pub fn TargetScene::spin(self : TargetScene, delta : Double) -> Unit {
  self.angle = self.angle + delta
  ignore(self.cube.node.rotation.set(0.35, self.angle, 0.0))
}
