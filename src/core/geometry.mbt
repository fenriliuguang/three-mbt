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
  listeners : Map[String, Array[() -> Unit]]
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
    listeners: Map([]),
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
/// 让几何体朝向一个点。临时物体在原点，朝向后再把旋转作用到顶点上。
/// r186: `lookAt` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L556
pub fn BufferGeometry::look_at(
  self : BufferGeometry,
  vector : @math.Vector3,
) -> BufferGeometry {
  let obj = Object3D::new()
  obj.look_at_vector(vector)
  obj.update_matrix()
  self.apply_matrix4(obj.matrix)
}

///|
/// 把包围盒中心移到原点。
/// r186: `center` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L573
pub fn BufferGeometry::center(self : BufferGeometry) -> BufferGeometry {
  self.compute_bounding_box()
  match self.bounding_box {
    None => abort("BufferGeometry.center requires a position attribute")
    Some(box) => {
      let offset = @math.Vector3::new()
      ignore(box.get_center(offset).negate())
      self.translate(offset.x, offset.y, offset.z)
    }
  }
}

///|
/// 用三维点写入 `position`。没有该属性时新建；已有时只覆盖缓冲区装得下的顶点。
/// r186: `setFromPoints` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L596
pub fn BufferGeometry::set_from_points(
  self : BufferGeometry,
  points : Array[@math.Vector3],
) -> BufferGeometry {
  match self.get_attribute("position") {
    None => {
      let position = []
      let mut index = 0
      while index < points.length() {
        let point = points[index]
        position.push(point.x)
        position.push(point.y)
        position.push(point.z)
        index = index + 1
      }
      ignore(self.set_attribute("position", BufferAttribute::new(position, 3)))
      self
    }
    Some(attribute) => {
      let limit = if points.length() < attribute.count {
        points.length()
      } else {
        attribute.count
      }
      let mut index = 0
      while index < limit {
        let point = points[index]
        attribute.set_xyz(index, point.x, point.y, point.z)
        index = index + 1
      }
      self
    }
  }
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
fn accumulate_tangent_triangle(
  position : BufferAttribute,
  uv : BufferAttribute,
  a : Int,
  b : Int,
  c : Int,
  tan1 : Array[@math.Vector3],
  tan2 : Array[@math.Vector3],
) -> Unit {
  let v_a = @math.Vector3::new()
  let v_b = @math.Vector3::new()
  let v_c = @math.Vector3::new()
  let uv_a = @math.Vector2::new()
  let uv_b = @math.Vector2::new()
  let uv_c = @math.Vector2::new()
  ignore(position.copy_to_vector3(a, v_a))
  ignore(position.copy_to_vector3(b, v_b))
  ignore(position.copy_to_vector3(c, v_c))
  ignore(uv.copy_to_vector2(a, uv_a))
  ignore(uv.copy_to_vector2(b, uv_b))
  ignore(uv.copy_to_vector2(c, uv_c))
  ignore(v_b.sub(v_a))
  ignore(v_c.sub(v_a))
  ignore(uv_b.sub(uv_a))
  ignore(uv_c.sub(uv_a))
  let r = 1.0 / (uv_b.x * uv_c.y - uv_c.x * uv_b.y)
  if r.is_nan() || r.is_inf() {
    return
  }
  let sdir = @math.Vector3::new()
    .copy(v_b)
    .multiply_scalar(uv_c.y)
    .add_scaled_vector(v_c, -uv_b.y)
    .multiply_scalar(r)
  let tdir = @math.Vector3::new()
    .copy(v_c)
    .multiply_scalar(uv_b.x)
    .add_scaled_vector(v_b, -uv_c.x)
    .multiply_scalar(r)
  ignore(tan1[a].add(sdir))
  ignore(tan1[b].add(sdir))
  ignore(tan1[c].add(sdir))
  ignore(tan2[a].add(tdir))
  ignore(tan2[b].add(tdir))
  ignore(tan2[c].add(tdir))
}

///|
fn write_tangent_vertex(
  normal : BufferAttribute,
  tangent : BufferAttribute,
  tan1 : Array[@math.Vector3],
  tan2 : Array[@math.Vector3],
  vertex : Int,
) -> Unit {
  let n = @math.Vector3::new()
  ignore(normal.copy_to_vector3(vertex, n))
  let n2 = @math.Vector3::new().copy(n)
  let t = tan1[vertex]
  let tmp = @math.Vector3::new().copy(t)
  ignore(tmp.sub(n.multiply_scalar(n.dot(t))).normalize())
  let tmp2 = @math.Vector3::new().cross_vectors(n2, t)
  let w = if tmp2.dot(tan2[vertex]) < 0.0 { -1.0 } else { 1.0 }
  ignore(tangent.set_xyzw(vertex, tmp.x, tmp.y, tmp.z, w))
}

///|
fn BufferGeometry::tangent_attribute(
  self : BufferGeometry,
  vertex_count : Int,
) -> BufferAttribute {
  match self.get_attribute("tangent") {
    Some(existing) =>
      if existing.count == vertex_count {
        existing
      } else {
        self.replace_tangent_attribute(vertex_count)
      }
    None => self.replace_tangent_attribute(vertex_count)
  }
}

///|
fn BufferGeometry::replace_tangent_attribute(
  self : BufferGeometry,
  vertex_count : Int,
) -> BufferAttribute {
  let values = []
  let mut index = 0
  while index < vertex_count * 4 {
    values.push(0.0)
    index = index + 1
  }
  let tangent = BufferAttribute::new(values, 4)
  ignore(self.set_attribute("tangent", tangent))
  tangent
}

///|
/// 为带索引、位置、法线和 uv 的几何体计算切线。缺任一属性时不改动。
/// r186: `computeTangents` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L837
pub fn BufferGeometry::compute_tangents(self : BufferGeometry) -> Unit {
  match (
    self.index,
    self.get_attribute("position"),
    self.get_attribute("normal"),
    self.get_attribute("uv"),
  ) {
    (Some(index), Some(position), Some(normal), Some(uv)) => {
      let tangent = self.tangent_attribute(position.count)
      let tan1 = []
      let tan2 = []
      let mut vertex = 0
      while vertex < position.count {
        tan1.push(@math.Vector3::new())
        tan2.push(@math.Vector3::new())
        vertex = vertex + 1
      }
      let groups : Array[GeometryGroup] = if self.groups.length() == 0 {
        [{ start: 0, count: index.count, material_index: 0 }]
      } else {
        self.groups
      }
      let mut group_index = 0
      while group_index < groups.length() {
        let group = groups[group_index]
        let mut cursor = group.start
        let end = group.start + group.count
        while cursor < end {
          accumulate_tangent_triangle(
            position,
            uv,
            index.get_x(cursor).to_int(),
            index.get_x(cursor + 1).to_int(),
            index.get_x(cursor + 2).to_int(),
            tan1,
            tan2,
          )
          cursor = cursor + 3
        }
        group_index = group_index + 1
      }
      group_index = 0
      while group_index < groups.length() {
        let group = groups[group_index]
        let mut cursor = group.start
        let end = group.start + group.count
        while cursor < end {
          write_tangent_vertex(
            normal,
            tangent,
            tan1,
            tan2,
            index.get_x(cursor).to_int(),
          )
          write_tangent_vertex(
            normal,
            tangent,
            tan1,
            tan2,
            index.get_x(cursor + 1).to_int(),
          )
          write_tangent_vertex(
            normal,
            tangent,
            tan1,
            tan2,
            index.get_x(cursor + 2).to_int(),
          )
          cursor = cursor + 3
        }
        group_index = group_index + 1
      }
    }
    _ => ()
  }
}

///|
fn accumulate_indexed_normals(
  position : BufferAttribute,
  normal : BufferAttribute,
  index : BufferAttribute,
) -> Unit {
  let p_a = @math.Vector3::new()
  let p_b = @math.Vector3::new()
  let p_c = @math.Vector3::new()
  let n_a = @math.Vector3::new()
  let n_b = @math.Vector3::new()
  let n_c = @math.Vector3::new()
  let cb = @math.Vector3::new()
  let ab = @math.Vector3::new()
  let mut cursor = 0
  while cursor < index.count {
    let v_a = index.get_x(cursor).to_int()
    let v_b = index.get_x(cursor + 1).to_int()
    let v_c = index.get_x(cursor + 2).to_int()
    ignore(position.copy_to_vector3(v_a, p_a))
    ignore(position.copy_to_vector3(v_b, p_b))
    ignore(position.copy_to_vector3(v_c, p_c))
    ignore(cb.sub_vectors(p_c, p_b))
    ignore(ab.sub_vectors(p_a, p_b))
    ignore(cb.cross(ab))
    ignore(normal.copy_to_vector3(v_a, n_a))
    ignore(normal.copy_to_vector3(v_b, n_b))
    ignore(normal.copy_to_vector3(v_c, n_c))
    ignore(n_a.add(cb))
    ignore(n_b.add(cb))
    ignore(n_c.add(cb))
    normal.set_xyz(v_a, n_a.x, n_a.y, n_a.z)
    normal.set_xyz(v_b, n_b.x, n_b.y, n_b.z)
    normal.set_xyz(v_c, n_c.x, n_c.y, n_c.z)
    cursor = cursor + 3
  }
}

///|
fn assign_triangle_soup_normals(
  position : BufferAttribute,
  normal : BufferAttribute,
) -> Unit {
  let p_a = @math.Vector3::new()
  let p_b = @math.Vector3::new()
  let p_c = @math.Vector3::new()
  let cb = @math.Vector3::new()
  let ab = @math.Vector3::new()
  let mut cursor = 0
  while cursor < position.count {
    ignore(position.copy_to_vector3(cursor, p_a))
    ignore(position.copy_to_vector3(cursor + 1, p_b))
    ignore(position.copy_to_vector3(cursor + 2, p_c))
    ignore(cb.sub_vectors(p_c, p_b))
    ignore(ab.sub_vectors(p_a, p_b))
    ignore(cb.cross(ab))
    normal.set_xyz(cursor, cb.x, cb.y, cb.z)
    normal.set_xyz(cursor + 1, cb.x, cb.y, cb.z)
    normal.set_xyz(cursor + 2, cb.x, cb.y, cb.z)
    cursor = cursor + 3
  }
}

///|
fn BufferGeometry::fresh_normal_attribute(
  self : BufferGeometry,
  vertex_count : Int,
) -> BufferAttribute {
  let values = []
  let mut index = 0
  while index < vertex_count * 3 {
    values.push(0.0)
    index = index + 1
  }
  let normal = BufferAttribute::new(values, 3)
  ignore(self.set_attribute("normal", normal))
  normal
}

///|
/// 按三角形面法线累加顶点法线，再归一化。没有 `position` 时不改动。
/// r186: `computeVertexNormals` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L1005
pub fn BufferGeometry::compute_vertex_normals(self : BufferGeometry) -> Unit {
  match self.get_attribute("position") {
    None => ()
    Some(position) => {
      let normal = match self.get_attribute("normal") {
        Some(existing) =>
          if existing.count == position.count {
            let mut index = 0
            while index < existing.count {
              existing.set_xyz(index, 0.0, 0.0, 0.0)
              index = index + 1
            }
            existing
          } else {
            self.fresh_normal_attribute(position.count)
          }
        None => self.fresh_normal_attribute(position.count)
      }
      match self.index {
        Some(index) => accumulate_indexed_normals(position, normal, index)
        None => assign_triangle_soup_normals(position, normal)
      }
      self.normalize_normals()
    }
  }
}

///|
/// 把每个法线归一化。
/// r186: `normalizeNormals` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L1101
pub fn BufferGeometry::normalize_normals(self : BufferGeometry) -> Unit {
  match self.get_attribute("normal") {
    None => abort("BufferGeometry.normalize_normals requires a normal attribute")
    Some(normals) => {
      let vector = @math.Vector3::new()
      let mut index = 0
      while index < normals.count {
        ignore(normals.copy_to_vector3(index, vector))
        ignore(vector.normalize())
        normals.set_xyz(index, vector.x, vector.y, vector.z)
        index = index + 1
      }
    }
  }
}

///|
fn expand_indexed_attribute(
  attribute : BufferAttribute,
  index : BufferAttribute,
) -> BufferAttribute {
  let values = []
  let mut cursor = 0
  while cursor < index.count {
    let source = index.get_x(cursor).to_int() * attribute.item_size
    let mut component = 0
    while component < attribute.item_size {
      values.push(attribute.array[source + component])
      component = component + 1
    }
    cursor = cursor + 1
  }
  BufferAttribute::new(values, attribute.item_size, normalized=attribute.normalized)
}

///|
/// 按索引展开属性，得到没有索引的几何体。本来就没有索引时返回自身。
/// r186: `toNonIndexed` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L1123
pub fn BufferGeometry::to_non_indexed(self : BufferGeometry) -> BufferGeometry {
  match self.index {
    None => self
    Some(index) => {
      let geometry = BufferGeometry::new()
      for pair in self.attributes.iter() {
        let (name, attribute) = pair
        ignore(
          geometry.set_attribute(name, expand_indexed_attribute(attribute, index)),
        )
      }
      let mut group_index = 0
      while group_index < self.groups.length() {
        let group = self.groups[group_index]
        geometry.add_group(
          group.start,
          group.count,
          material_index=group.material_index,
        )
        group_index = group_index + 1
      }
      geometry
    }
  }
}

///|
/// `BufferGeometry.toJSON` 返回的数据。上游没有单独的类。`type_name` 对应元数据里的 `type`。
/// r186: `toJSON` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L1230
pub(all) struct GeometryJson {
  version : Double
  type_name : String
  generator : String
  index : Array[Double]?
  attributes : Map[String, AttributeJson]
  groups : Array[GeometryGroup]
  bounding_sphere : (Array[Double], Double)?
}

///|
/// 序列化元数据、属性、索引、分组和包围球。
/// r186: `toJSON` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L1230
pub fn BufferGeometry::to_json(self : BufferGeometry) -> GeometryJson {
  let attributes : Map[String, AttributeJson] = Map([])
  for pair in self.attributes.iter() {
    let (name, attribute) = pair
    attributes.set(name, attribute.to_json())
  }
  let groups = []
  let mut group_index = 0
  while group_index < self.groups.length() {
    let group = self.groups[group_index]
    groups.push({
      start: group.start,
      count: group.count,
      material_index: group.material_index,
    })
    group_index = group_index + 1
  }
  let index = match self.index {
    None => None
    Some(index) => Some(index.array.copy())
  }
  let bounding_sphere = match self.bounding_sphere {
    None => None
    Some(sphere) => Some(sphere.to_json())
  }
  {
    version: 4.7,
    type_name: "BufferGeometry",
    generator: "BufferGeometry.toJSON",
    index,
    attributes,
    groups,
    bounding_sphere,
  }
}

///|
/// 新建一份几何体并复制属性、索引、分组、包围体和绘制范围。`version` 从 0 开始。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L1345
pub fn BufferGeometry::clone(self : BufferGeometry) -> BufferGeometry {
  BufferGeometry::new().copy(self)
}

///|
/// 把源几何体的属性、索引、分组、包围体和绘制范围复制过来。数值各自独立。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferGeometry.js#L1357
pub fn BufferGeometry::copy(
  self : BufferGeometry,
  source : BufferGeometry,
) -> BufferGeometry {
  self.index = None
  self.attributes.clear()
  self.groups.clear()
  self.bounding_box = None
  self.bounding_sphere = None
  match source.index {
    None => ()
    Some(index) => ignore(self.set_index(index.clone()))
  }
  for pair in source.attributes.iter() {
    let (name, attribute) = pair
    ignore(self.set_attribute(name, attribute.clone()))
  }
  let mut group_index = 0
  while group_index < source.groups.length() {
    let group = source.groups[group_index]
    self.add_group(group.start, group.count, material_index=group.material_index)
    group_index = group_index + 1
  }
  match source.bounding_box {
    None => ()
    Some(box) => self.bounding_box = Some(box.clone())
  }
  match source.bounding_sphere {
    None => ()
    Some(sphere) => self.bounding_sphere = Some(sphere.clone())
  }
  self.draw_range.start = source.draw_range.start
  self.draw_range.count = source.draw_range.count
  self
}

///|
/// 登记一个监听。同一种事件里，同一个函数只保留一次。
/// r186: `addEventListener` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L31
pub fn BufferGeometry::add_event_listener(
  self : BufferGeometry,
  kind : String,
  listener : () -> Unit,
) -> Unit {
  let listeners = self.listeners.get_or_init(kind, fn() { [] })
  let mut found = false
  for existing in listeners {
    if physical_equal(existing, listener) {
      found = true
    }
  }
  if !found {
    listeners.push(listener)
  }
}

///|
/// 同一种事件里是否已经有这个监听。
/// r186: `hasEventListener` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L58
pub fn BufferGeometry::has_event_listener(
  self : BufferGeometry,
  kind : String,
  listener : () -> Unit,
) -> Bool {
  match self.listeners.get(kind) {
    None => false
    Some(listeners) => {
      let mut found = false
      for existing in listeners {
        if physical_equal(existing, listener) {
          found = true
        }
      }
      found
    }
  }
}
