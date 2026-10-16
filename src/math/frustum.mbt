// r186: `Frustum` https://github.com/mrdoob/three.js/blob/r186/src/math/Frustum.js#L18

///|
/// 六个裁剪面围成的视锥。平面顺序与 r186 `Frustum` 相同。
/// r186: `Frustum` https://github.com/mrdoob/three.js/blob/r186/src/math/Frustum.js#L18
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
/// 复制六个裁剪面。
/// r186: `set` https://github.com/mrdoob/three.js/blob/r186/src/math/Frustum.js#L52
pub fn Frustum::set(
  self : Frustum,
  p0 : Plane,
  p1 : Plane,
  p2 : Plane,
  p3 : Plane,
  p4 : Plane,
  p5 : Plane,
) -> Frustum {
  ignore(self.planes[0].copy(p0))
  ignore(self.planes[1].copy(p1))
  ignore(self.planes[2].copy(p2))
  ignore(self.planes[3].copy(p3))
  ignore(self.planes[4].copy(p4))
  ignore(self.planes[5].copy(p5))
  self
}

///|
/// 复制另一个视锥的六个裁剪面。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/math/Frustum.js#L73
pub fn Frustum::copy(self : Frustum, frustum : Frustum) -> Frustum {
  for i in 0..<6 {
    ignore(self.planes[i].copy(frustum.planes[i]))
  }
  self
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

///|
/// 盒子是否与视锥相交。完全落在某个裁剪面外侧才算不相交。
/// `intersectsObject` 需要 `Object3D`，`intersectsSprite` 需要精灵，这两项留在后面。
/// r186: `intersectsBox` https://github.com/mrdoob/three.js/blob/r186/src/math/Frustum.js#L230
pub fn Frustum::intersects_box(self : Frustum, box : Box3) -> Bool {
  let corner = Vector3::new()
  for i in 0..<6 {
    let plane = self.planes[i]
    corner.x = if plane.normal.x > 0.0 { box.max.x } else { box.min.x }
    corner.y = if plane.normal.y > 0.0 { box.max.y } else { box.min.y }
    corner.z = if plane.normal.z > 0.0 { box.max.z } else { box.min.z }
    if plane.distance_to_point(corner) < 0.0 {
      return false
    }
  }
  true
}

///|
/// 点在每个裁剪面的内侧或面上才算在视锥里。
/// r186: `containsPoint` https://github.com/mrdoob/three.js/blob/r186/src/math/Frustum.js#L262
pub fn Frustum::contains_point(self : Frustum, point : Vector3) -> Bool {
  for i in 0..<6 {
    if self.planes[i].distance_to_point(point) < 0.0 {
      return false
    }
  }
  true
}

///|
/// 复制出一份新的视锥。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/math/Frustum.js#L285
pub fn Frustum::clone(self : Frustum) -> Frustum {
  Frustum::new().copy(self)
}
