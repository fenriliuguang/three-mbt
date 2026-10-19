// r186: `raycast` https://github.com/mrdoob/three.js/blob/r186/src/objects/Sprite.js#L141 ; `transformVertex` https://github.com/mrdoob/three.js/blob/r186/src/objects/Sprite.js#L230

///|
/// 上游没有单独的类。锚点是 `Sprite.center`，旋转和尺寸衰减来自 `SpriteMaterial`。
/// r186: `center` https://github.com/mrdoob/three.js/blob/r186/src/objects/Sprite.js#L110
pub(all) struct SpriteState {
  center : @math.Vector2
  mut rotation : Double
  mut size_attenuation : Bool
}

///|
/// 把朝向相机的两个三角形与射线相交。调用前要先更新精灵和相机的世界矩阵。没有相机会中止。
/// r186: `raycast` https://github.com/mrdoob/three.js/blob/r186/src/objects/Sprite.js#L141
fn Object3D::raycast_sprite(
  self : Object3D,
  raycaster : Raycaster,
  intersects : Array[Intersection],
) -> Unit {
  let sprite = match self.sprite {
    None => return
    Some(sprite) => sprite
  }
  let camera = match raycaster.camera {
    None => abort("Sprite.raycast requires Raycaster.camera")
    Some(camera) => camera
  }
  let state = match camera.camera {
    None => abort("Sprite.raycast requires a camera")
    Some(state) => state
  }
  let world_scale = @math.Vector3::new().set_from_matrix_scale(self.matrix_world)
  let view_world = @math.Matrix4::new().copy(camera.matrix_world)
  ignore(
    self.model_view_matrix.multiply_matrices(
      state.matrix_world_inverse,
      self.matrix_world,
    ),
  )
  let mv = @math.Vector3::new().set_from_matrix_position(self.model_view_matrix)
  if camera.kind is PerspectiveCamera && !sprite.size_attenuation {
    ignore(world_scale.multiply_scalar(-mv.z))
  }
  let center = sprite.center
  let rotation = sprite.rotation
  let a = @math.Vector3::new().set(-0.5, -0.5, 0.0)
  let b = @math.Vector3::new().set(0.5, -0.5, 0.0)
  let c = @math.Vector3::new().set(0.5, 0.5, 0.0)
  transform_sprite_vertex(a, mv, center, world_scale, view_world, rotation)
  transform_sprite_vertex(b, mv, center, world_scale, view_world, rotation)
  transform_sprite_vertex(c, mv, center, world_scale, view_world, rotation)
  let uv_a = @math.Vector2::new()
  let uv_b = @math.Vector2::new(x=1.0)
  let uv_c = @math.Vector2::new(x=1.0, y=1.0)
  let point = @math.Vector3::new()
  let hit = match raycaster.ray.intersect_triangle(a, b, c, false, point) {
    Some(_) => true
    None => {
      ignore(b.set(-0.5, 0.5, 0.0))
      transform_sprite_vertex(b, mv, center, world_scale, view_world, rotation)
      ignore(uv_b.set(0.0, 1.0))
      match raycaster.ray.intersect_triangle(a, c, b, false, point) {
        Some(_) => true
        None => false
      }
    }
  }
  if !hit {
    return
  }
  let distance = raycaster.ray.origin.distance_to(point)
  if distance < raycaster.near || distance > raycaster.far {
    return
  }
  let uv = match @math.Triangle::get_interpolation(
    point,
    a,
    b,
    c,
    @math.Vector3::new(x=uv_a.x, y=uv_a.y),
    @math.Vector3::new(x=uv_b.x, y=uv_b.y),
    @math.Vector3::new(x=uv_c.x, y=uv_c.y),
    @math.Vector3::new(),
  ) {
    None => None
    Some(blended) => Some(@math.Vector2::new(x=blended.x, y=blended.y))
  }
  intersects.push({
    distance,
    point,
    object: self,
    face: None,
    face_index: None,
    barycoord: None,
    uv,
    uv1: None,
    normal: None,
    index: None,
    distance_to_ray: None,
    instance_id: None,
  })
}

///|
/// 把视图空间的角点转到世界空间。旋转为 0 时不乘正弦和余弦。
/// r186: `transformVertex` https://github.com/mrdoob/three.js/blob/r186/src/objects/Sprite.js#L230
fn transform_sprite_vertex(
  vertex : @math.Vector3,
  mv : @math.Vector3,
  center : @math.Vector2,
  scale : @math.Vector3,
  view_world : @math.Matrix4,
  rotation : Double,
) -> Unit {
  let flat = @math.Vector2::new(x=vertex.x, y=vertex.y)
  let aligned = @math.Vector2::new().sub_vectors(flat, center).add_scalar(0.5)
  aligned.x = aligned.x * scale.x
  aligned.y = aligned.y * scale.y
  let rotated = @math.Vector2::new()
  if rotation != 0.0 {
    let cos = @std.cos(rotation)
    let sin = @std.sin(rotation)
    rotated.x = cos * aligned.x - sin * aligned.y
    rotated.y = sin * aligned.x + cos * aligned.y
  } else {
    ignore(rotated.copy(aligned))
  }
  ignore(vertex.copy(mv))
  vertex.x = vertex.x + rotated.x
  vertex.y = vertex.y + rotated.y
  ignore(vertex.apply_matrix4(view_world))
}
