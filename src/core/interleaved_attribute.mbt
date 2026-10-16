// r186: `InterleavedBufferAttribute` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBufferAttribute.js#L13

///|
/// 从交错缓冲里按偏移读取的属性。`name` 默认是空字符串。`count` 来自缓冲的顶点数。
/// r186: `InterleavedBufferAttribute` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBufferAttribute.js#L13
/// r186: `name` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBufferAttribute.js#L39
/// r186: `data` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBufferAttribute.js#L46
/// r186: `itemSize` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBufferAttribute.js#L53
/// r186: `offset` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBufferAttribute.js#L60
/// r186: `normalized` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBufferAttribute.js#L67
pub(all) struct InterleavedBufferAttribute {
  mut name : String
  data : InterleavedBuffer
  item_size : Int
  offset : Int
  mut normalized : Bool
}

///|
pub fn InterleavedBufferAttribute::new(
  data : InterleavedBuffer,
  item_size : Int,
  offset : Int,
  normalized? : Bool = false,
) -> InterleavedBufferAttribute {
  { name: "", data, item_size, offset, normalized }
}

///|
/// 顶点数，与交错缓冲的 `count` 相同。
/// r186: `count` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBufferAttribute.js#L77
pub fn InterleavedBufferAttribute::count(self : InterleavedBufferAttribute) -> Int {
  self.data.count
}
