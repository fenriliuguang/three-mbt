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
/// 绘制范围。上游没有单独的类，默认值写在 `BufferGeometry` 构造函数里。
/// r186: `drawRange` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L188
pub(all) struct DrawRange {
  mut start : Double
  mut count : Double
}

///|
/// 几何体。属性按名字存放，索引和包围体单独保存。
/// r186: `BufferGeometry` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L48
pub(all) struct BufferGeometry {
  attributes : Map[String, BufferAttribute]
  mut index : BufferAttribute?
  groups : Array[GeometryGroup]
  draw_range : DrawRange
  mut bounding_box : @math.Box3?
  mut bounding_sphere : @math.Sphere?
  mut version : Int
}

///|
pub fn BufferGeometry::new() -> BufferGeometry {
  {
    attributes: Map([]),
    index: None,
    groups: [],
    draw_range: { start: 0.0, count: 1.0 / 0.0 },
    bounding_box: None,
    bounding_sphere: None,
    version: 0,
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
/// 按名字删掉一个属性。没有这个名字时几何体不变。索引不受影响。
/// r186: `deleteAttribute` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L307
pub fn BufferGeometry::delete_attribute(
  self : BufferGeometry,
  name : String,
) -> BufferGeometry {
  self.attributes.remove(name)
  self
}

///|
/// 这个名字上有没有属性。索引不算属性。
/// r186: `hasAttribute` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L321
pub fn BufferGeometry::has_attribute(self : BufferGeometry, name : String) -> Bool {
  self.attributes.contains(name)
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
/// 清空全部分组。属性和索引不动。
/// r186: `clearGroups` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L350
pub fn BufferGeometry::clear_groups(self : BufferGeometry) -> Unit {
  self.groups.clear()
}

///|
/// 设置从哪个顶点或索引开始画，以及画多少个。默认从 `0` 画到正无穷。
/// r186: `setDrawRange` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L363
pub fn BufferGeometry::set_draw_range(
  self : BufferGeometry,
  start : Double,
  count : Double,
) -> Unit {
  self.draw_range.start = start
  self.draw_range.count = count
}

///|
/// 用矩阵变换 `position`，用法线矩阵变换 `normal`，用方向变换 `tangent`。包围体已有时重算。
/// r186: `applyMatrix4` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L376
pub fn BufferGeometry::apply_matrix4(
  self : BufferGeometry,
  matrix : @math.Matrix4,
) -> BufferGeometry {
  match self.get_attribute("position") {
    None => ()
    Some(position) => ignore(position.apply_matrix4(matrix))
  }
  match self.get_attribute("normal") {
    None => ()
    Some(normal) => {
      let normal_matrix = @math.Matrix3::new().get_normal_matrix(matrix)
      ignore(normal.apply_normal_matrix(normal_matrix))
    }
  }
  match self.get_attribute("tangent") {
    None => ()
    Some(tangent) => ignore(tangent.transform_direction(matrix))
  }
  if self.bounding_box is Some(_) {
    self.compute_bounding_box()
  }
  if self.bounding_sphere is Some(_) {
    self.compute_bounding_sphere()
  }
  self
}

///|
/// 把四元数转成旋转矩阵再作用于几何体。
/// r186: `applyQuaternion` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L434
pub fn BufferGeometry::apply_quaternion(
  self : BufferGeometry,
  q : @math.Quaternion,
) -> BufferGeometry {
  let matrix = @math.Matrix4::new().make_rotation_from_quaternion(q)
  self.apply_matrix4(matrix)
}

///|
/// 绕世界 X 轴旋转几何体。
/// r186: `rotateX` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L452
pub fn BufferGeometry::rotate_x(
  self : BufferGeometry,
  angle : Double,
) -> BufferGeometry {
  let matrix = @math.Matrix4::new().make_rotation_x(angle)
  self.apply_matrix4(matrix)
}

///|
/// 绕世界 Y 轴旋转几何体。
/// r186: `rotateY` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L472
pub fn BufferGeometry::rotate_y(
  self : BufferGeometry,
  angle : Double,
) -> BufferGeometry {
  let matrix = @math.Matrix4::new().make_rotation_y(angle)
  self.apply_matrix4(matrix)
}

///|
/// 绕世界 Z 轴旋转几何体。
/// r186: `rotateZ` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L492
pub fn BufferGeometry::rotate_z(
  self : BufferGeometry,
  angle : Double,
) -> BufferGeometry {
  let matrix = @math.Matrix4::new().make_rotation_z(angle)
  self.apply_matrix4(matrix)
}

///|
/// 平移几何体。
/// r186: `translate` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L514
pub fn BufferGeometry::translate(
  self : BufferGeometry,
  x : Double,
  y : Double,
  z : Double,
) -> BufferGeometry {
  let matrix = @math.Matrix4::new().make_translation(x, y, z)
  self.apply_matrix4(matrix)
}

///|
/// 缩放几何体。
/// r186: `scale` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L536
pub fn BufferGeometry::scale(
  self : BufferGeometry,
  x : Double,
  y : Double,
  z : Double,
) -> BufferGeometry {
  let matrix = @math.Matrix4::new().make_scale(x, y, z)
  self.apply_matrix4(matrix)
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

///|
/// 复制属性、索引和包围体。`version` 从 0 开始，供渲染器把这份几何当成新缓冲。
pub fn BufferGeometry::clone(self : BufferGeometry) -> BufferGeometry {
  let geometry = BufferGeometry::new()
  copy_attribute(self, geometry, "position")
  copy_attribute(self, geometry, "normal")
  copy_attribute(self, geometry, "uv")
  copy_attribute(self, geometry, "color")
  match self.index {
    None => ()
    Some(index) =>
      ignore(
        geometry.set_index(
          BufferAttribute::new(
            index.array.copy(),
            index.item_size,
            normalized=index.normalized,
          ),
        ),
      )
  }
  geometry.bounding_box = self.bounding_box
  geometry.bounding_sphere = self.bounding_sphere
  geometry
}

///|
fn copy_attribute(
  source : BufferGeometry,
  geometry : BufferGeometry,
  name : String,
) -> Unit {
  match source.get_attribute(name) {
    None => ()
    Some(attribute) =>
      ignore(
        geometry.set_attribute(
          name,
          BufferAttribute::new(
            attribute.array.copy(),
            attribute.item_size,
            normalized=attribute.normalized,
          ),
        ),
      )
  }
}
