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
  array : Array[Double]
  stride : Int
  count : Int
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
