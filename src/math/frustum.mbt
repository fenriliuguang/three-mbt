///|
/// 六个裁剪面围成的视锥。平面顺序与 r186 `Frustum` 相同。
pub(all) struct Frustum {
  planes : Array[Plane]
}

///|
pub fn Frustum::new() -> Frustum {
  {
    planes: [
      Plane::new(),
      Plane::new(),
      Plane::new(),
      Plane::new(),
      Plane::new(),
      Plane::new(),
    ],
  }
}

///|
pub fn Frustum::set_from_projection_matrix(
  self : Frustum,
  m : Matrix4,
  coordinate_system? : @constants.CoordinateSystem,
  reversed_depth? : Bool = false,
) -> Frustum {
  let coordinate_system = match coordinate_system {
    None => @constants.WebGPU
    Some(coordinate_system) => coordinate_system
  }
  let me = m.elements
  let me0 = me[0]
  let me1 = me[1]
  let me2 = me[2]
  let me3 = me[3]
  let me4 = me[4]
  let me5 = me[5]
  let me6 = me[6]
  let me7 = me[7]
  let me8 = me[8]
  let me9 = me[9]
  let me10 = me[10]
  let me11 = me[11]
  let me12 = me[12]
  let me13 = me[13]
  let me14 = me[14]
  let me15 = me[15]
  let planes = self.planes
  ignore(
    planes[0]
    .set_components(me3 - me0, me7 - me4, me11 - me8, me15 - me12)
    .normalize(),
  )
  ignore(
    planes[1]
    .set_components(me3 + me0, me7 + me4, me11 + me8, me15 + me12)
    .normalize(),
  )
  ignore(
    planes[2]
    .set_components(me3 + me1, me7 + me5, me11 + me9, me15 + me13)
    .normalize(),
  )
  ignore(
    planes[3]
    .set_components(me3 - me1, me7 - me5, me11 - me9, me15 - me13)
    .normalize(),
  )
  if reversed_depth {
    ignore(planes[4].set_components(me2, me6, me10, me14).normalize())
    ignore(
      planes[5]
      .set_components(me3 - me2, me7 - me6, me11 - me10, me15 - me14)
      .normalize(),
    )
  } else {
    ignore(
      planes[4]
      .set_components(me3 - me2, me7 - me6, me11 - me10, me15 - me14)
      .normalize(),
    )
    match coordinate_system {
      WebGL =>
        ignore(
          planes[5]
          .set_components(me3 + me2, me7 + me6, me11 + me10, me15 + me14)
          .normalize(),
        )
      WebGPU =>
        ignore(planes[5].set_components(me2, me6, me10, me14).normalize())
    }
  }
  self
}

///|
pub fn Frustum::intersects_sphere(self : Frustum, sphere : Sphere) -> Bool {
  let neg_radius = -sphere.radius
  let mut hit = true
  for plane in self.planes {
    if plane.distance_to_point(sphere.center) < neg_radius {
      hit = false
    }
  }
  hit
}
