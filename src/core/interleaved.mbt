// r186: `InterleavedBuffer` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L10

///|
/// 多个属性共用的交错缓冲。数值用 `Double` 保存。`count` 是数组长度除以步长。`usage` 默认是 `StaticDrawUsage`。
/// r186: `InterleavedBuffer` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L10
/// r186: `array` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L34
/// r186: `stride` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L41
/// r186: `count` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L49
/// r186: `usage` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBuffer.js#L60
pub(all) struct InterleavedBuffer {
  array : Array[Double]
  stride : Int
  count : Int
  mut usage : Int
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
