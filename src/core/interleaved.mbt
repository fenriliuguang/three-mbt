// r186: `InterleavedBuffer` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L10

///|
/// 多个属性共用的交错缓冲。数值用 `Double` 保存。`count` 是数组长度除以步长。`usage` 默认是 `StaticDrawUsage`。待上传区间一开始是空的。`version` 从 0 起，只有 `needsUpdate` 为真时加一。`uuid` 在新建时生成，`copy` 不改写它。`mesh_per_attribute` 来自 `InstancedInterleavedBuffer`，默认是 `1`。
/// r186: `InterleavedBuffer` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L10
/// r186: `array` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L34
/// r186: `stride` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L41
/// r186: `count` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L49
/// r186: `usage` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L60
/// r186: `updateRanges` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L68
/// r186: `version` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L75
/// r186: `uuid` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L83
/// r186: `meshPerAttribute` https://github.com/mrdoob/three.js/blob/r186/src/core/InstancedInterleavedBuffer.js#L37
pub(all) struct InterleavedBuffer {
  uuid : String
  mut array : Array[Double]
  mut stride : Int
  mut count : Int
  mut usage : Int
  update_ranges : Array[UpdateRange]
  mut version : Int
  mut on_upload_callback : (() -> Unit)?
  mut mesh_per_attribute : Int
}

///|
pub fn InterleavedBuffer::new(
  array : Array[Double],
  stride : Int,
  mesh_per_attribute? : Int = 1,
) -> InterleavedBuffer {
  {
    uuid: @math.generate_uuid(),
    array,
    stride,
    count: array.length() / stride,
    usage: @constants.STATIC_DRAW_USAGE,
    update_ranges: [],
    version: 0,
    on_upload_callback: None,
    mesh_per_attribute,
  }
}

///|
/// 为真时把 `version` 加一。为假时不变。
/// r186: `needsUpdate` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L101
pub fn InterleavedBuffer::set_needs_update(
  self : InterleavedBuffer,
  value : Bool,
) -> Unit {
  if value {
    self.version = self.version + 1
  }
}

///|
/// 设置缓冲区的使用方式。默认是 `StaticDrawUsage`。
/// r186: `setUsage` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L113
pub fn InterleavedBuffer::set_usage(
  self : InterleavedBuffer,
  value : Int,
) -> InterleavedBuffer {
  self.usage = value
  self
}

///|
/// 追加一段需要上传到 GPU 的区间。
/// r186: `addUpdateRange` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L127
pub fn InterleavedBuffer::add_update_range(
  self : InterleavedBuffer,
  start : Int,
  count : Int,
) -> Unit {
  self.update_ranges.push({ start, count })
}

///|
/// 清空待上传区间。
/// r186: `clearUpdateRanges` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L136
pub fn InterleavedBuffer::clear_update_ranges(self : InterleavedBuffer) -> Unit {
  self.update_ranges.clear()
}

///|
/// 用源缓冲的数值、步长、顶点数、使用方式和实例重复次数替换当前缓冲。数值是一份副本。待上传区间保留目标自己的。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L148
pub fn InterleavedBuffer::copy(
  self : InterleavedBuffer,
  source : InterleavedBuffer,
) -> InterleavedBuffer {
  self.array = source.array.copy()
  self.count = source.count
  self.stride = source.stride
  self.usage = source.usage
  self.mesh_per_attribute = source.mesh_per_attribute
  self
}

///|
/// 把源缓冲的一个顶点复制到当前缓冲的指定位置。复制长度是当前缓冲的步长。
/// r186: `copyAt` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L169
pub fn InterleavedBuffer::copy_at(
  self : InterleavedBuffer,
  index1 : Int,
  buffer : InterleavedBuffer,
  index2 : Int,
) -> InterleavedBuffer {
  let mut destination = index1 * self.stride
  let mut source = index2 * buffer.stride
  let mut component = 0
  while component < self.stride {
    self.array[destination] = buffer.array[source]
    destination = destination + 1
    source = source + 1
    component = component + 1
  }
  self
}

///|
/// 从偏移处写入一份数值。放不下时中止。
/// r186: `set` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L191
pub fn InterleavedBuffer::set(
  self : InterleavedBuffer,
  value : Array[Double],
  offset? : Int = 0,
) -> InterleavedBuffer {
  if offset < 0 || offset + value.length() > self.array.length() {
    abort("InterleavedBuffer.set source does not fit")
  }
  let mut index = 0
  while index < value.length() {
    self.array[offset + index] = value[index]
    index = index + 1
  }
  self
}

///|
/// 新建一份交错缓冲。没有共享的 `ArrayBuffer`，数值是一份独立副本，使用方式一并带上。待上传区间不复制。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L205
pub fn InterleavedBuffer::clone(self : InterleavedBuffer) -> InterleavedBuffer {
  InterleavedBuffer::new(self.array, self.stride).copy(self)
}

///|
/// 设置上传到 GPU 之后要执行的回调。
/// r186: `onUpload` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L242
pub fn InterleavedBuffer::on_upload(
  self : InterleavedBuffer,
  callback : () -> Unit,
) -> InterleavedBuffer {
  self.on_upload_callback = Some(callback)
  self
}

///|
/// `InterleavedBuffer.toJSON` 返回的数据。上游没有单独的类。上游把底层 `ArrayBuffer` 放进 `data.arrayBuffers`。本地没有共享缓冲区，数值直接写进 `array`。
/// r186: `toJSON` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L256
pub(all) struct InterleavedJson {
  uuid : String
  stride : Int
  usage : Int
  array : Array[Double]
}

///|
/// 写出标识、步长、使用方式和一份数值副本。
/// r186: `toJSON` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L256
pub fn InterleavedBuffer::to_json(self : InterleavedBuffer) -> InterleavedJson {
  {
    uuid: self.uuid,
    stride: self.stride,
    usage: self.usage,
    array: self.array.copy(),
  }
}
