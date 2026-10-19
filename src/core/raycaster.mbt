// r186: `Raycaster` https://github.com/mrdoob/three.js/blob/r186/src/core/Raycaster.js#L13

///|
/// 从一条射线挑出场景里的交点。缺省原点是 `(0, 0, 0)`，方向是 `(0, 0, -1)`。`near` 默认是 `0`，`far` 默认是正无穷。
/// r186: `Raycaster` https://github.com/mrdoob/three.js/blob/r186/src/core/Raycaster.js#L13
/// r186: `ray` https://github.com/mrdoob/three.js/blob/r186/src/core/Raycaster.js#L30
/// r186: `near` https://github.com/mrdoob/three.js/blob/r186/src/core/Raycaster.js#L38
/// r186: `far` https://github.com/mrdoob/three.js/blob/r186/src/core/Raycaster.js#L46
/// r186: `camera` https://github.com/mrdoob/three.js/blob/r186/src/core/Raycaster.js#L56
/// r186: `layers` https://github.com/mrdoob/three.js/blob/r186/src/core/Raycaster.js#L69
/// r186: `params` https://github.com/mrdoob/three.js/blob/r186/src/core/Raycaster.js#L88
pub(all) struct Raycaster {
  ray : @math.Ray
  mut near : Double
  mut far : Double
  mut camera : Object3D?
  layers : Layers
  params : RaycasterParams
}

///|
/// 一次射线相交。上游没有单独的类，记录来自 `Raycaster~Intersection`。
/// `face` 来自网格相交时写下的三角形。
/// r186: `Raycaster~Intersection` https://github.com/mrdoob/three.js/blob/r186/src/core/Raycaster.js#L160
/// r186: `face` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L489
/// r186: `faceIndex` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L406
/// r186: `barycoord` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L500
/// r186: `uv` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L467
/// r186: `uv1` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L473
/// r186: `normal` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L479
pub(all) struct Intersection {
  distance : Double
  point : @math.Vector3
  object : Object3D
  face : Face?
  face_index : Int?
  barycoord : @math.Vector3?
  uv : @math.Vector2?
  uv1 : @math.Vector2?
  normal : @math.Vector3?
}

///|
/// 上游没有单独的类。网格相交时写下的三角形，`materialIndex` 默认 `0`。
/// r186: `face` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L489
pub(all) struct Face {
  a : Int
  b : Int
  c : Int
  normal : @math.Vector3
  material_index : Int
}

///|
/// 上游没有单独的类。线段相交的世界单位容差，来自 `params.Line.threshold`，默认 `1`。
/// r186: `params` https://github.com/mrdoob/three.js/blob/r186/src/core/Raycaster.js#L88
pub(all) struct RaycasterLineParams {
  mut threshold : Double
}

///|
/// 上游没有单独的类。点相交的世界单位容差，来自 `params.Points.threshold`，默认 `1`。
/// r186: `params` https://github.com/mrdoob/three.js/blob/r186/src/core/Raycaster.js#L88
pub(all) struct RaycasterPointsParams {
  mut threshold : Double
}

///|
/// 上游没有单独的类。`Mesh`、`LOD`、`Sprite` 在 r186 里是空对象，这里不设字段。
/// r186: `params` https://github.com/mrdoob/three.js/blob/r186/src/core/Raycaster.js#L88
pub(all) struct RaycasterParams {
  line : RaycasterLineParams
  points : RaycasterPointsParams
}

///|
pub fn Raycaster::new(
  origin? : @math.Vector3,
  direction? : @math.Vector3,
  near? : Double = 0.0,
  far? : Double = 1.0 / 0.0,
) -> Raycaster {
  let ray = @math.Ray::new()
  match origin {
    None => ()
    Some(origin) => ignore(ray.origin.copy(origin))
  }
  match direction {
    None => ()
    Some(direction) => ignore(ray.direction.copy(direction))
  }
  {
    ray,
    near,
    far,
    camera: None,
    layers: Layers::new(),
    params: { line: { threshold: 1.0 }, points: { threshold: 1.0 } },
  }
}

///|
/// 用新的原点和方向更新射线。方向按已经归一化处理，这里不再归一化。之后改来源向量不影响射线。
/// r186: `set` https://github.com/mrdoob/three.js/blob/r186/src/core/Raycaster.js#L104
pub fn Raycaster::set(
  self : Raycaster,
  origin : @math.Vector3,
  direction : @math.Vector3,
) -> Unit {
  ignore(self.ray.set(origin, direction))
}

///|
/// 用 NDC 坐标和相机重算射线。透视相机从相机的世界位置出发，方向穿过反投影后的点。
/// 正交相机把原点放在投影矩阵第 14 号元素对应的相机平面上，方向是相机的 -Z。
/// 其他节点种类会中止。调用前要先更新相机的世界矩阵和投影。
/// r186: `setFromCamera` https://github.com/mrdoob/three.js/blob/r186/src/core/Raycaster.js#L119
pub fn Raycaster::set_from_camera(
  self : Raycaster,
  coords : @math.Vector2,
  camera : Object3D,
) -> Unit {
  match camera.kind {
    PerspectiveCamera => {
      ignore(self.ray.origin.set_from_matrix_position(camera.matrix_world))
      ignore(self.ray.direction.set(coords.x, coords.y, 0.5))
      ignore(camera.unproject_point(self.ray.direction))
      ignore(self.ray.direction.sub(self.ray.origin).normalize())
      self.camera = Some(camera)
    }
    OrthographicCamera =>
      match camera.camera {
        None => abort("Raycaster.set_from_camera requires a camera")
        Some(state) => {
          ignore(
            self.ray.origin.set(coords.x, coords.y, state.projection.elements[14]),
          )
          ignore(camera.unproject_point(self.ray.origin))
          ignore(
            self.ray.direction
            .set(0.0, 0.0, -1.0)
            .transform_direction(camera.matrix_world),
          )
          self.camera = Some(camera)
        }
      }
    _ => abort("Raycaster.set_from_camera unsupported camera type")
  }
}

///|
/// 收集对象和子节点上的交点，并按距离从近到远排序。基类 `raycast` 不写入交点。
/// 返回的是传入的数组；没传时用一个新数组。
/// r186: `intersectObject` https://github.com/mrdoob/three.js/blob/r186/src/core/Raycaster.js#L198
pub fn Raycaster::intersect_object(
  self : Raycaster,
  object : Object3D,
  recursive? : Bool = true,
  intersects? : Array[Intersection],
) -> Array[Intersection] {
  let intersects = match intersects {
    None => []
    Some(intersects) => intersects
  }
  self.intersect(object, intersects, recursive)
  intersects.sort_by_key(fn(hit) { hit.distance })
  intersects
}

///|
/// 对一组对象收集交点，全部走完后再按距离从近到远排序。
/// 返回的是传入的数组；没传时用一个新数组。
/// r186: `intersectObjects` https://github.com/mrdoob/three.js/blob/r186/src/core/Raycaster.js#L218
pub fn Raycaster::intersect_objects(
  self : Raycaster,
  objects : Array[Object3D],
  recursive? : Bool = true,
  intersects? : Array[Intersection],
) -> Array[Intersection] {
  let intersects = match intersects {
    None => []
    Some(intersects) => intersects
  }
  for object in objects {
    self.intersect(object, intersects, recursive)
  }
  intersects.sort_by_key(fn(hit) { hit.distance })
  intersects
}

///|
fn Raycaster::intersect(
  self : Raycaster,
  object : Object3D,
  intersects : Array[Intersection],
  recursive : Bool,
) -> Unit {
  let mut propagate = true
  if object.layers.intersects(self.layers) {
    match object.raycast(self, intersects) {
      Some(false) => propagate = false
      _ => ()
    }
  }
  if propagate && recursive {
    let count = object.children.length()
    let mut index = 0
    while index < count {
      self.intersect(object.children[index], intersects, true)
      index = index + 1
    }
  }
}
