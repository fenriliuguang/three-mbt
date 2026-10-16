// r186: `InterleavedBuffer` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L10

///|
/// 多个属性共用的交错缓冲。数值用 `Double` 保存。`count` 是数组长度除以步长。`usage` 默认是 `StaticDrawUsage`。待上传区间一开始是空的。
/// r186: `InterleavedBuffer` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L10
/// r186: `array` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L34
/// r186: `stride` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L41
/// r186: `count` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L49
/// r186: `usage` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L60
/// r186: `updateRanges` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L68
pub(all) struct InterleavedBuffer {
  mut array : Array[Double]
  mut stride : Int
  mut count : Int
  mut usage : Int
  update_ranges : Array[UpdateRange]
}

///|
pub fn InterleavedBuffer::new(
  array : Array[Double],
  stride : Int,
) -> InterleavedBuffer {
  {
    array,
    stride,
    count: array.length() / stride,
    usage: @constants.STATIC_DRAW_USAGE,
    update_ranges: [],
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
/// 用源缓冲的数值、步长、顶点数和使用方式替换当前缓冲。数值是一份副本。待上传区间保留目标自己的。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L148
pub fn InterleavedBuffer::copy(
  self : InterleavedBuffer,
  source : InterleavedBuffer,
) -> InterleavedBuffer {
  self.array = source.array.copy()
  self.count = source.count
  self.stride = source.stride
  self.usage = source.usage
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
