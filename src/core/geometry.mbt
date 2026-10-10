// r186: `BufferGeometry` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L48

///|
/// `BufferGeometry` 的一组索引。`material_index` 对应 r186 的 group materialIndex。
/// r186: `BufferGeometry` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L48
pub(all) struct GeometryGroup {
  start : Int
  count : Int
  material_index : Int
}

///|
/// 几何体。属性按名字存放，索引和包围体单独保存。
/// r186: `BufferGeometry` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L48
pub(all) struct BufferGeometry {
  attributes : Map[String, BufferAttribute]
  mut index : BufferAttribute?
  groups : Array[GeometryGroup]
  mut bounding_box : @math.Box3?
  mut bounding_sphere : @math.Sphere?
}

///|
pub fn BufferGeometry::new() -> BufferGeometry {
  {
    attributes: Map([]),
    index: None,
    groups: [],
    bounding_box: None,
    bounding_sphere: None,
  }
}

///|
pub fn BufferGeometry::set_attribute(
  self : BufferGeometry,
  name : String,
  attribute : BufferAttribute,
) -> BufferGeometry {
  self.attributes.set(name, attribute)
  self
}

///|
pub fn BufferGeometry::get_attribute(
  self : BufferGeometry,
  name : String,
) -> BufferAttribute? {
  self.attributes.get(name)
}

///|
pub fn BufferGeometry::set_index(
  self : BufferGeometry,
  index : BufferAttribute,
) -> BufferGeometry {
  self.index = Some(index)
  self
}

///|
pub fn BufferGeometry::set_index_array(
  self : BufferGeometry,
  indices : Array[Int],
) -> BufferGeometry {
  self.set_index(BufferAttribute::from_ints(indices, 1))
}

///|
pub fn BufferGeometry::add_group(
  self : BufferGeometry,
  start : Int,
  count : Int,
  material_index? : Int = 0,
) -> Unit {
  self.groups.push({ start, count, material_index, })
}

///|
pub fn BufferGeometry::compute_bounding_box(self : BufferGeometry) -> Unit {
  match self.attributes.get("position") {
    None => self.bounding_box = None
    Some(position) => {
      let box = match self.bounding_box {
        None => {
          let box = @math.Box3::empty()
          self.bounding_box = Some(box)
          box
        }
        Some(box) => box
      }
      ignore(box.make_empty())
      let mut index = 0
      while index < position.count {
        let point = @math.Vector3::new(
          x=position.get_x(index),
          y=position.get_y(index),
          z=position.get_z(index),
        )
        ignore(box.expand_by_point(point))
        index = index + 1
      }
    }
  }
}

///|
pub fn BufferGeometry::compute_bounding_sphere(self : BufferGeometry) -> Unit {
  self.compute_bounding_box()
  match (self.attributes.get("position"), self.bounding_box) {
    (Some(position), Some(box)) => {
      let sphere = match self.bounding_sphere {
        None => {
          let sphere = @math.Sphere::new()
          self.bounding_sphere = Some(sphere)
          sphere
        }
        Some(sphere) => sphere
      }
      ignore(box.get_center(sphere.center))
      let mut max_radius_sq = 0.0
      let mut index = 0
      while index < position.count {
        let point = @math.Vector3::new(
          x=position.get_x(index),
          y=position.get_y(index),
          z=position.get_z(index),
        )
        max_radius_sq = max_radius_sq.max(
          sphere.center.distance_to_squared(point),
        )
        index = index + 1
      }
      sphere.radius = max_radius_sq.sqrt()
    }
    _ => self.bounding_sphere = None
  }
}
