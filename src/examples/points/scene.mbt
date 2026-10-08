///|
using @cameras {type PerspectiveCamera}

///|
using @objects {type Group, type Line, type Points}

///|
using @scenes {type Scene}

///|
fn polyline() -> @core.BufferGeometry {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [-1.0, 0.0, 0.0, 0.0, 0.8, 0.0, 1.0, 0.0, 0.0],
        3,
      ),
    ),
  )
  geometry
}

///|
/// 一条折线和三个点。点的大小是 18 像素，并随距离缩小。
pub(all) struct PointsScene {
  scene : Scene
  camera : PerspectiveCamera
  group : Group
  line : Line
  points : Points
  mut angle : Double
}

///|
pub fn PointsScene::new() -> PointsScene {
  let scene = Scene::new()
  scene.set_background(@math.Color::new().set_hex(0x0D1A33))
  let line = Line::new(
    polyline(),
    @materials.LineBasicMaterial::new(hex=0x88CCFF),
  )
  let points = Points::new(
    polyline(),
    @materials.PointsMaterial::new(
      hex=0xFFCC66,
      size=18.0,
      size_attenuation=true,
    ),
  )
  let group = Group::new().add(line).add(points)
  ignore(scene.add(group))
  let camera = PerspectiveCamera::new(fov=50.0, aspect=1.0, near=0.1, far=100.0)
  ignore(camera.node.position.set(0.0, 0.6, 4.0))
  camera.node.look_at(0.0, 0.0, 0.0)
  { scene, camera, group, line, points, angle: 0.0, }
}

///|
/// 每帧让折线和点一起绕 Y 轴转过 `delta` 弧度。
pub fn PointsScene::spin(self : PointsScene, delta : Double) -> Unit {
  self.angle = self.angle + delta
  ignore(self.group.node.rotation.set(0.0, self.angle, 0.0))
}
