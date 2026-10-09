///|
using @cameras {type PerspectiveCamera}

///|
using @objects {type Mesh}

///|
using @scenes {type Scene}

///|
fn ground() -> @core.BufferGeometry {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [-1.0, 0.0, -1.0, 1.0, 0.0, -1.0, 1.0, 0.0, 1.0, -1.0, 0.0, 1.0],
        3,
      ),
    ),
  )
  ignore(
    geometry.set_attribute(
      "normal",
      @core.BufferAttribute::new(
        [0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0],
        3,
      ),
    ),
  )
  ignore(
    geometry.set_attribute(
      "uv",
      @core.BufferAttribute::new([0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0], 2),
    ),
  )
  ignore(geometry.set_index_array([0, 1, 2, 0, 2, 3]))
  geometry
}

///|
/// 立方体投射阴影，地面接收。平行光的阴影相机盖住这一小块地面。
pub(all) struct ShadowScene {
  scene : Scene
  camera : PerspectiveCamera
  cube : Mesh
  ground : Mesh
  mut angle : Double
}

///|
pub fn ShadowScene::new() -> ShadowScene {
  let scene = Scene::new()
  scene.set_background(@math.Color::new().set_hex(0x0D1A33))
  let cube = Mesh::new(
    @geometries.BoxGeometry::new().geometry,
    @materials.MeshLambertMaterial::new(hex=0xC4783A).material,
  )
  cube.node.cast_shadow = true
  ignore(scene.add(cube))
  let ground_mesh = Mesh::new(
    ground(),
    @materials.MeshLambertMaterial::new(hex=0xD9D3C5).material,
  )
  ground_mesh.node.receive_shadow = true
  ignore(ground_mesh.node.position.set(0.0, -0.5, 0.0))
  ignore(ground_mesh.node.scale.set(4.0, 1.0, 4.0))
  ignore(scene.add(ground_mesh))
  let ambient = @lights.AmbientLight::new(hex=0x404040, intensity=0.35)
  ignore(scene.add(ambient))
  let sun = @lights.DirectionalLight::new(hex=0xFFFFFF, intensity=2.0)
  ignore(sun.node.position.set(4.0, 6.0, 3.0))
  sun.cast_shadow(true)
  sun.shadow.bias = -0.001
  sun.shadow.normal_bias = 0.02
  sun.set_shadow_bounds(-8.0, 8.0, 8.0, -8.0, 0.5, 20.0)
  ignore(scene.add(sun))
  let camera = PerspectiveCamera::new(fov=50.0, aspect=1.0, near=0.1, far=100.0)
  ignore(camera.node.position.set(3.0, 2.4, 5.0))
  camera.node.look_at(0.0, 0.0, 0.0)
  { scene, camera, cube, ground: ground_mesh, angle: 0.0, }
}

///|
/// 每帧让立方体绕 Y 轴转过 `delta` 弧度。地面不动。
pub fn ShadowScene::spin(self : ShadowScene, delta : Double) -> Unit {
  self.angle = self.angle + delta
  ignore(self.cube.node.rotation.set(0.2, self.angle, 0.0))
}
