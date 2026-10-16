// r186: `BufferAttribute` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L21

///|
/// 一段待上传的缓冲区间。上游没有单独的类。
/// r186: `addUpdateRange` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L181
pub(all) struct UpdateRange {
  start : Int
  count : Int
}

///|
/// 顶点缓冲。数值用 `Double` 保存，对应 r186 里进入着色器之前的 JS number。
/// r186: `BufferAttribute` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L21
pub(all) struct BufferAttribute {
  mut array : Array[Double]
  mut item_size : Int
  mut normalized : Bool
  mut count : Int
  mut version : Int
  mut usage : Int
  update_ranges : Array[UpdateRange]
  mut on_upload_callback : (() -> Unit)?
  listeners : Map[String, Array[() -> Unit]]
}

///|
pub fn BufferAttribute::new(
  array : Array[Double],
  item_size : Int,
  normalized? : Bool = false,
) -> BufferAttribute {
  {
    array,
    item_size,
    normalized,
    count: array.length() / item_size,
    version: 0,
    usage: @constants.STATIC_DRAW_USAGE,
    update_ranges: [],
    on_upload_callback: None,
    listeners: Map([]),
  }
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
/// 为真时把 `version` 加一。为假时保持不变。
/// r186: `needsUpdate` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L155
pub fn BufferAttribute::set_needs_update(
  self : BufferAttribute,
  value : Bool,
) -> Unit {
  if value {
    self.version = self.version + 1
  }
}

///|
/// 设置缓冲区的使用方式。默认是 `StaticDrawUsage`。
/// r186: `setUsage` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L167
pub fn BufferAttribute::set_usage(
  self : BufferAttribute,
  value : Int,
) -> BufferAttribute {
  self.usage = value
  self
}

///|
/// 追加一段需要上传到 GPU 的区间。
/// r186: `addUpdateRange` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L181
pub fn BufferAttribute::add_update_range(
  self : BufferAttribute,
  start : Int,
  count : Int,
) -> Unit {
  self.update_ranges.push({ start, count })
}

///|
/// 清空待上传区间。
/// r186: `clearUpdateRanges` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L190
pub fn BufferAttribute::clear_update_ranges(self : BufferAttribute) -> Unit {
  self.update_ranges.clear()
}

///|
/// 设置上传到 GPU 之后要执行的回调。
/// r186: `onUpload` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L640
pub fn BufferAttribute::on_upload(
  self : BufferAttribute,
  callback : () -> Unit,
) -> BufferAttribute {
  self.on_upload_callback = Some(callback)
  self
}

///|
/// 登记一个监听。同一种事件里，同一个函数只保留一次。
/// r186: `addEventListener` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L31
pub fn BufferAttribute::add_event_listener(
  self : BufferAttribute,
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
pub fn BufferAttribute::has_event_listener(
  self : BufferAttribute,
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

///|
/// 从一种事件里移除这个监听。没有登记时不动。
/// r186: `removeEventListener` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L74
pub fn BufferAttribute::remove_event_listener(
  self : BufferAttribute,
  kind : String,
  listener : () -> Unit,
) -> Unit {
  match self.listeners.get(kind) {
    None => ()
    Some(listeners) => {
      let mut index = None
      for i in 0..<listeners.length() {
        if physical_equal(listeners[i], listener) {
          index = Some(i)
        }
      }
      match index {
        None => ()
        Some(index) => ignore(listeners.remove(index))
      }
    }
  }
}

///|
/// 通知 `dispose` 监听。其它事件不动。
/// r186: `dispose` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L684
pub fn BufferAttribute::dispose(self : BufferAttribute) -> Unit {
  match self.listeners.get("dispose") {
    None => ()
    Some(listeners) => {
      let snapshot = listeners.copy()
      for listener in snapshot {
        listener()
      }
    }
  }
}

///|
/// 用源属性的数值、分量个数、归一化标记和使用方式替换当前属性。数值是一份副本。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L202
pub fn BufferAttribute::copy(
  self : BufferAttribute,
  source : BufferAttribute,
) -> BufferAttribute {
  self.array = source.array.copy()
  self.item_size = source.item_size
  self.count = source.count
  self.normalized = source.normalized
  self.usage = source.usage
  self
}

///|
/// 把源属性的一个顶点复制到当前属性的指定位置。
/// r186: `copyAt` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L227
pub fn BufferAttribute::copy_at(
  self : BufferAttribute,
  index1 : Int,
  attribute : BufferAttribute,
  index2 : Int,
) -> BufferAttribute {
  let mut destination = index1 * self.item_size
  let mut source = index2 * attribute.item_size
  let mut component = 0
  while component < self.item_size {
    self.array[destination] = attribute.array[source]
    destination = destination + 1
    source = source + 1
    component = component + 1
  }
  self
}

///|
/// 从缓冲区开头写入一份数值。源比缓冲区长时中止。
/// r186: `copyArray` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L248
pub fn BufferAttribute::copy_array(
  self : BufferAttribute,
  array : Array[Double],
) -> BufferAttribute {
  if array.length() > self.array.length() {
    abort("BufferAttribute.copy_array source is longer than the attribute")
  }
  let mut index = 0
  while index < array.length() {
    self.array[index] = array[index]
    index = index + 1
  }
  self
}

///|
/// 从偏移处写入一份数值。放不下时中止。
/// r186: `set` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L369
pub fn BufferAttribute::set(
  self : BufferAttribute,
  value : Array[Double],
  offset? : Int = 0,
) -> BufferAttribute {
  if offset < 0 || offset + value.length() > self.array.length() {
    abort("BufferAttribute.set source does not fit")
  }
  let mut index = 0
  while index < value.length() {
    self.array[offset + index] = value[index]
    index = index + 1
  }
  self
}

///|
/// 新建一份属性，数值与源独立。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L653
pub fn BufferAttribute::clone(self : BufferAttribute) -> BufferAttribute {
  BufferAttribute::new(self.array, self.item_size, normalized=self.normalized).copy(self)
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
/// 写入一个顶点的指定分量。
/// r186: `setComponent` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L403
pub fn BufferAttribute::set_component(
  self : BufferAttribute,
  index : Int,
  component : Int,
  value : Double,
) -> BufferAttribute {
  self.array[index * self.item_size + component] = value
  self
}

///|
pub fn BufferAttribute::get_x(self : BufferAttribute, index : Int) -> Double {
  self.get_component(index, 0)
}

///|
/// 写入一个顶点的 x 分量。
/// r186: `setX` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L436
pub fn BufferAttribute::set_x(
  self : BufferAttribute,
  index : Int,
  x : Double,
) -> BufferAttribute {
  self.set_component(index, 0, x)
}

///|
pub fn BufferAttribute::get_y(self : BufferAttribute, index : Int) -> Double {
  self.get_component(index, 1)
}

///|
/// 写入一个顶点的 y 分量。
/// r186: `setY` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L469
pub fn BufferAttribute::set_y(
  self : BufferAttribute,
  index : Int,
  y : Double,
) -> BufferAttribute {
  self.set_component(index, 1, y)
}

///|
pub fn BufferAttribute::get_z(self : BufferAttribute, index : Int) -> Double {
  self.get_component(index, 2)
}

///|
/// 写入一个顶点的 z 分量。
/// r186: `setZ` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L502
pub fn BufferAttribute::set_z(
  self : BufferAttribute,
  index : Int,
  z : Double,
) -> BufferAttribute {
  self.set_component(index, 2, z)
}

///|
/// 读取一个顶点的 w 分量。
/// r186: `getW` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L518
pub fn BufferAttribute::get_w(self : BufferAttribute, index : Int) -> Double {
  self.get_component(index, 3)
}

///|
/// 写入一个顶点的 w 分量。
/// r186: `setW` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L535
pub fn BufferAttribute::set_w(
  self : BufferAttribute,
  index : Int,
  w : Double,
) -> BufferAttribute {
  self.set_component(index, 3, w)
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
/// 写入一个顶点的 x 和 y。z 及之后的分量不动。
/// r186: `setXY` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L553
pub fn BufferAttribute::set_xy(
  self : BufferAttribute,
  index : Int,
  x : Double,
  y : Double,
) -> BufferAttribute {
  let offset = index * self.item_size
  self.array[offset] = x
  self.array[offset + 1] = y
  self
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
/// 写入一个顶点的四个分量。
/// r186: `setXYZW` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L610
pub fn BufferAttribute::set_xyzw(
  self : BufferAttribute,
  index : Int,
  x : Double,
  y : Double,
  z : Double,
  w : Double,
) -> BufferAttribute {
  let offset = index * self.item_size
  self.array[offset] = x
  self.array[offset + 1] = y
  self.array[offset + 2] = z
  self.array[offset + 3] = w
  self
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

///|
/// `BufferAttribute.toJSON` 返回的数据。上游没有单独的类。
/// r186: `toJSON` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L664
pub(all) struct AttributeJson {
  item_size : Int
  array : Array[Double]
  normalized : Bool
}

///|
/// 复制分量个数、数值和是否归一化。
/// r186: `toJSON` https://github.com/mrdoob/three.js/blob/r186/src/core/BufferAttribute.js#L664
pub fn BufferAttribute::to_json(self : BufferAttribute) -> AttributeJson {
  {
    item_size: self.item_size,
    array: self.array.copy(),
    normalized: self.normalized,
  }
}
