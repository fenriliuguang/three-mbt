// r186: `BufferAttribute` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L21

///|
/// 顶点缓冲。数值用 `Double` 保存，对应 r186 里进入着色器之前的 JS number。
/// r186: `BufferAttribute` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L21
pub(all) struct BufferAttribute {
  array : Array[Double]
  item_size : Int
  mut normalized : Bool
  count : Int
}

///|
pub fn BufferAttribute::new(
  array : Array[Double],
  item_size : Int,
  normalized? : Bool = false,
) -> BufferAttribute {
  { array, item_size, normalized, count: array.length() / item_size, }
}

///|
pub fn BufferAttribute::from_ints(
  values : Array[Int],
  item_size : Int,
) -> BufferAttribute {
  let array = []
  for value in values {
    array.push(value.to_double())
  }
  BufferAttribute::new(array, item_size)
}

///|
pub fn BufferAttribute::get_component(
  self : BufferAttribute,
  index : Int,
  component : Int,
) -> Double {
  self.array[index * self.item_size + component]
}

///|
pub fn BufferAttribute::get_x(self : BufferAttribute, index : Int) -> Double {
  self.get_component(index, 0)
}

///|
pub fn BufferAttribute::get_y(self : BufferAttribute, index : Int) -> Double {
  self.get_component(index, 1)
}

///|
pub fn BufferAttribute::get_z(self : BufferAttribute, index : Int) -> Double {
  self.get_component(index, 2)
}

///|
/// 写入 `target`。`math` 不依赖 `core`，所以这个函数放在属性上，而不是 `Vector3` 上。
/// r186: `fromBufferAttribute` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector3.js#L1203
pub fn BufferAttribute::copy_to_vector3(
  self : BufferAttribute,
  index : Int,
  target : @math.Vector3,
) -> @math.Vector3 {
  target.set(self.get_x(index), self.get_y(index), self.get_z(index))
}

///|
/// 写入 `target` 的 x 和 y。`math` 不依赖 `core`，所以这个函数放在属性上。
/// r186: `fromBufferAttribute` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L816
pub fn BufferAttribute::copy_to_vector2(
  self : BufferAttribute,
  index : Int,
  target : @math.Vector2,
) -> @math.Vector2 {
  target.set(self.get_x(index), self.get_y(index))
}

///|
/// 写入 `target` 的 x、y、z 和 w。`math` 不依赖 `core`，所以这个函数放在属性上。
/// r186: `fromBufferAttribute` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector4.js#L1024
pub fn BufferAttribute::copy_to_vector4(
  self : BufferAttribute,
  index : Int,
  target : @math.Vector4,
) -> @math.Vector4 {
  target.set(
    self.get_x(index),
    self.get_y(index),
    self.get_z(index),
    self.get_component(index, 3),
  )
}

///|
/// 写入 `target` 的 r、g、b。通道按属性里的数原样拷贝。`math` 不依赖 `core`，所以这个函数放在属性上。
/// r186: `fromBufferAttribute` https://github.com/mrdoob/three.js/blob/r186/src/math/Color.js#L923
pub fn BufferAttribute::copy_to_color(
  self : BufferAttribute,
  index : Int,
  target : @math.Color,
) -> @math.Color {
  target.set(self.get_x(index), self.get_y(index), self.get_z(index))
}

///|
/// 写入 `target` 的 x、y、z、w，并通知一次。`math` 不依赖 `core`，所以这个函数放在属性上。
/// r186: `fromBufferAttribute` https://github.com/mrdoob/three.js/blob/r186/src/math/Quaternion.js#L862
pub fn BufferAttribute::copy_to_quaternion(
  self : BufferAttribute,
  index : Int,
  target : @math.Quaternion,
) -> @math.Quaternion {
  target.set(
    self.get_x(index),
    self.get_y(index),
    self.get_z(index),
    self.get_component(index, 3),
  )
}

///|
/// 先清空 `target`，再纳入每个顶点的 xyz。`math` 不依赖 `core`，所以这个函数放在属性上。
/// r186: `setFromBufferAttribute` https://github.com/mrdoob/three.js/blob/r186/src/math/Box3.js#L86
pub fn BufferAttribute::set_box3(
  self : BufferAttribute,
  target : @math.Box3,
) -> @math.Box3 {
  ignore(target.make_empty())
  let point = @math.Vector3::new()
  let mut index = 0
  while index < self.count {
    ignore(self.copy_to_vector3(index, point))
    ignore(target.expand_by_point(point))
    index = index + 1
  }
  target
}

///|
/// 按重心坐标混合三个顶点的 xyz。`math` 不依赖 `core`，所以这个函数放在属性上。
/// r186: `getInterpolatedAttribute` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L195
pub fn BufferAttribute::interpolate_vector3(
  self : BufferAttribute,
  i1 : Int,
  i2 : Int,
  i3 : Int,
  barycoord : @math.Vector3,
  target : @math.Vector3,
) -> @math.Vector3 {
  let v1 = self.copy_to_vector3(i1, @math.Vector3::new())
  let v2 = self.copy_to_vector3(i2, @math.Vector3::new())
  let v3 = self.copy_to_vector3(i3, @math.Vector3::new())
  ignore(target.set_scalar(0.0))
  ignore(target.add_scaled_vector(v1, barycoord.x))
  ignore(target.add_scaled_vector(v2, barycoord.y))
  target.add_scaled_vector(v3, barycoord.z)
}

///|
/// 按三个下标写入三角形的三个角。`math` 不依赖 `core`，所以这个函数放在属性上。
/// r186: `setFromAttributeAndIndices` https://github.com/mrdoob/three.js/blob/r186/src/math/Triangle.js#L279
pub fn BufferAttribute::set_triangle(
  self : BufferAttribute,
  target : @math.Triangle,
  i0 : Int,
  i1 : Int,
  i2 : Int,
) -> @math.Triangle {
  ignore(self.copy_to_vector3(i0, target.a))
  ignore(self.copy_to_vector3(i1, target.b))
  ignore(self.copy_to_vector3(i2, target.c))
  target
}

///|
pub fn BufferAttribute::set_xyz(
  self : BufferAttribute,
  index : Int,
  x : Double,
  y : Double,
  z : Double,
) -> Unit {
  let offset = index * self.item_size
  self.array[offset] = x
  self.array[offset + 1] = y
  self.array[offset + 2] = z
}

///|
/// 用 3×3 矩阵变换属性。`item_size` 为 2 或 3 时逐个顶点变换，其它大小不动。
/// r186: `applyMatrix3` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L263
pub fn BufferAttribute::apply_matrix3(
  self : BufferAttribute,
  matrix : @math.Matrix3,
) -> BufferAttribute {
  if self.item_size == 2 {
    let point = @math.Vector2::new()
    let mut index = 0
    while index < self.count {
      ignore(self.copy_to_vector2(index, point))
      ignore(point.apply_matrix3(matrix))
      let offset = index * self.item_size
      self.array[offset] = point.x
      self.array[offset + 1] = point.y
      index = index + 1
    }
  } else if self.item_size == 3 {
    let point = @math.Vector3::new()
    let mut index = 0
    while index < self.count {
      ignore(self.copy_to_vector3(index, point))
      ignore(point.apply_matrix3(matrix))
      self.set_xyz(index, point.x, point.y, point.z)
      index = index + 1
    }
  }
  self
}

///|
/// 用矩阵变换每个三点顶点。只适用于 `item_size` 为 3 的属性。
/// r186: `applyMatrix4` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L300
pub fn BufferAttribute::apply_matrix4(
  self : BufferAttribute,
  matrix : @math.Matrix4,
) -> BufferAttribute {
  let point = @math.Vector3::new()
  let mut index = 0
  while index < self.count {
    ignore(self.copy_to_vector3(index, point))
    ignore(point.apply_matrix4(matrix))
    self.set_xyz(index, point.x, point.y, point.z)
    index = index + 1
  }
  self
}

///|
/// 用法线矩阵变换每个三点顶点，并归一化。只适用于 `item_size` 为 3 的属性。
/// r186: `applyNormalMatrix` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L323
pub fn BufferAttribute::apply_normal_matrix(
  self : BufferAttribute,
  matrix : @math.Matrix3,
) -> BufferAttribute {
  let point = @math.Vector3::new()
  let mut index = 0
  while index < self.count {
    ignore(self.copy_to_vector3(index, point))
    ignore(point.apply_normal_matrix(matrix))
    self.set_xyz(index, point.x, point.y, point.z)
    index = index + 1
  }
  self
}

///|
/// 用矩阵左上 3×3 变换方向并归一化。平移不参与。只适用于 `item_size` 为 3 的属性。
/// r186: `transformDirection` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L346
pub fn BufferAttribute::transform_direction(
  self : BufferAttribute,
  matrix : @math.Matrix4,
) -> BufferAttribute {
  let point = @math.Vector3::new()
  let mut index = 0
  while index < self.count {
    ignore(self.copy_to_vector3(index, point))
    ignore(point.transform_direction(matrix))
    self.set_xyz(index, point.x, point.y, point.z)
    index = index + 1
  }
  self
}
