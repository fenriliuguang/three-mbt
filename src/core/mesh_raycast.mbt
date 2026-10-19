// r186: `raycast` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L238

///|
/// 单材质网格的三角形相交。材质数组和分组留在后面。没有 `uv`、法线或 `face` 时不写这些字段。
/// r186: `raycast` https://github.com/mrdoob/three.js/blob/r186/src/objects/Mesh.js#L238
fn Object3D::raycast_mesh(
  self : Object3D,
  raycaster : Raycaster,
  intersects : Array[Intersection],
) -> Unit {
  let mesh = match self.mesh {
    None => return
    Some(mesh) => mesh
  }
  let geometry = mesh.geometry
  if geometry.bounding_sphere is None {
    geometry.compute_bounding_sphere()
  }
  let sphere = match geometry.bounding_sphere {
    None => return
    Some(sphere) => {
      let copy = @math.Sphere::new()
      ignore(copy.copy(sphere).apply_matrix4(self.matrix_world))
      copy
    }
  }
  let ray = @math.Ray::new()
  ignore(ray.copy(raycaster.ray).recast(raycaster.near))
  if !sphere.contains_point(ray.origin) {
    let hit_at = @math.Vector3::new()
    match ray.intersect_sphere(sphere, hit_at) {
      None => return
      Some(hit_at) => {
        let limit = raycaster.far - raycaster.near
        if ray.origin.distance_to_squared(hit_at) > limit * limit {
          return
        }
      }
    }
  }
  let inverse = @math.Matrix4::new()
  ignore(inverse.copy(self.matrix_world).invert())
  ignore(ray.copy(raycaster.ray).apply_matrix4(inverse))
  match geometry.bounding_box {
    None => ()
    Some(box) =>
      if !ray.intersects_box(box) {
        return
      }
  }
  self.raycast_triangles(raycaster, intersects, ray, mesh.side)
}

///|
fn Object3D::raycast_triangles(
  self : Object3D,
  raycaster : Raycaster,
  intersects : Array[Intersection],
  ray : @math.Ray,
  side : @constants.Side,
) -> Unit {
  let geometry = match self.mesh {
    None => return
    Some(mesh) => mesh.geometry
  }
  match geometry.index {
    Some(index) => {
      let (start, end) = triangle_bounds(
        index.count,
        geometry.draw_range.start,
        geometry.draw_range.count,
      )
      let mut i = start
      while i < end {
        self.push_triangle(
          raycaster,
          intersects,
          ray,
          side,
          index.get_x(i).to_int(),
          index.get_x(i + 1).to_int(),
          index.get_x(i + 2).to_int(),
          i / 3,
        )
        i = i + 3
      }
    }
    None =>
      match geometry.get_attribute("position") {
        None => ()
        Some(position) => {
          let (start, end) = triangle_bounds(
            position.count,
            geometry.draw_range.start,
            geometry.draw_range.count,
          )
          let mut i = start
          while i < end {
            self.push_triangle(
              raycaster,
              intersects,
              ray,
              side,
              i,
              i + 1,
              i + 2,
              i / 3,
            )
            i = i + 3
          }
        }
      }
  }
}

///|
fn Object3D::push_triangle(
  self : Object3D,
  raycaster : Raycaster,
  intersects : Array[Intersection],
  ray : @math.Ray,
  side : @constants.Side,
  a : Int,
  b : Int,
  c : Int,
  face_index : Int,
) -> Unit {
  let point = @math.Vector3::new()
  let corner_a = @math.Vector3::new()
  let corner_b = @math.Vector3::new()
  let corner_c = @math.Vector3::new()
  ignore(self.get_vertex_position(a, corner_a))
  ignore(self.get_vertex_position(b, corner_b))
  ignore(self.get_vertex_position(c, corner_c))
  let hit = match side {
    Front => ray.intersect_triangle(corner_a, corner_b, corner_c, true, point)
    Back => ray.intersect_triangle(corner_c, corner_b, corner_a, true, point)
    Double => ray.intersect_triangle(corner_a, corner_b, corner_c, false, point)
  }
  match hit {
    None => ()
    Some(point) => {
      let world = @math.Vector3::new().copy(point).apply_matrix4(self.matrix_world)
      let distance = raycaster.ray.origin.distance_to(world)
      if distance >= raycaster.near && distance <= raycaster.far {
        let normal = @math.Vector3::new()
        ignore(@math.Triangle::get_normal(corner_a, corner_b, corner_c, normal))
        let barycoord = @math.Triangle::get_barycoord(
          point,
          corner_a,
          corner_b,
          corner_c,
          @math.Vector3::new(),
        )
        let uv = interpolated_uv(self.mesh, "uv", a, b, c, barycoord)
        let uv1 = interpolated_uv(self.mesh, "uv1", a, b, c, barycoord)
        let shading = interpolated_normal(self.mesh, a, b, c, barycoord, ray)
        intersects.push({
          distance,
          point: world,
          object: self,
          face: Some({ a, b, c, normal, material_index: 0 }),
          face_index: Some(face_index),
          barycoord,
          uv,
          uv1,
          normal: shading,
          index: None,
          distance_to_ray: None,
        })
      }
    }
  }
}

///|
fn interpolated_uv(
  mesh : MeshBinding?,
  name : String,
  a : Int,
  b : Int,
  c : Int,
  barycoord : @math.Vector3?,
) -> @math.Vector2? {
  match barycoord {
    None => None
    Some(bary) =>
      match mesh {
        None => None
        Some(mesh) =>
          match mesh.geometry.get_attribute(name) {
            None => None
            Some(attribute) =>
              Some(
                attribute.interpolate_vector2(a, b, c, bary, @math.Vector2::new()),
              )
          }
      }
  }
}

///|
fn interpolated_normal(
  mesh : MeshBinding?,
  a : Int,
  b : Int,
  c : Int,
  barycoord : @math.Vector3?,
  ray : @math.Ray,
) -> @math.Vector3? {
  match barycoord {
    None => None
    Some(bary) =>
      match mesh {
        None => None
        Some(mesh) =>
          match mesh.geometry.get_attribute("normal") {
            None => None
            Some(attribute) => {
              let shading = attribute.interpolate_vector3(
                a,
                b,
                c,
                bary,
                @math.Vector3::new(),
              )
              if shading.dot(ray.direction) > 0.0 {
                ignore(shading.multiply_scalar(-1.0))
              }
              Some(shading)
            }
          }
      }
  }
}

///|
fn triangle_bounds(count : Int, start : Double, span : Double) -> (Int, Int) {
  let start_index = double_index(start, count)
  let end_index = double_index(start + span, count)
  if end_index < start_index {
    (start_index, start_index)
  } else {
    (start_index, end_index)
  }
}

///|
fn double_index(value : Double, limit : Int) -> Int {
  if value.is_nan() || value <= 0.0 {
    0
  } else if value.is_inf() {
    limit
  } else {
    let index = value.floor().to_int()
    if index > limit {
      limit
    } else {
      index
    }
  }
}
