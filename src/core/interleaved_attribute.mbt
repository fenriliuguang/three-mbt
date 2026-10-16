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

///|
/// 交错缓冲里的数值。改这里会改到同一份数组。
/// r186: `array` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBufferAttribute.js#L88
pub fn InterleavedBufferAttribute::array(
  self : InterleavedBufferAttribute,
) -> Array[Double] {
  self.data.array
}

///|
/// 为真时把交错缓冲的 `version` 加一。为假时不变。
/// r186: `needsUpdate` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBufferAttribute.js#L102
pub fn InterleavedBufferAttribute::set_needs_update(
  self : InterleavedBufferAttribute,
  value : Bool,
) -> Unit {
  self.data.set_needs_update(value)
}

///|
/// 读取指定顶点的 x。下标是 `index * stride + offset`。归一化换算还没有落地，读到的是缓冲里的原值。
/// r186: `getX` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBufferAttribute.js#L286
pub fn InterleavedBufferAttribute::get_x(
  self : InterleavedBufferAttribute,
  index : Int,
) -> Double {
  self.data.array[index * self.data.stride + self.offset]
}

///|
/// 读取指定顶点的 y。下标是 `index * stride + offset + 1`。归一化换算还没有落地，读到的是缓冲里的原值。
/// r186: `getY` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBufferAttribute.js#L302
pub fn InterleavedBufferAttribute::get_y(
  self : InterleavedBufferAttribute,
  index : Int,
) -> Double {
  self.data.array[index * self.data.stride + self.offset + 1]
}

///|
/// 写入指定顶点的 x。下标是 `index * stride + offset`。归一化换算还没有落地，写入的是原值。
/// r186: `setX` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBufferAttribute.js#L219
pub fn InterleavedBufferAttribute::set_x(
  self : InterleavedBufferAttribute,
  index : Int,
  x : Double,
) -> InterleavedBufferAttribute {
  self.data.array[index * self.data.stride + self.offset] = x
  self
}

///|
/// 写入指定顶点的 y。下标是 `index * stride + offset + 1`。归一化换算还没有落地，写入的是原值。
/// r186: `setY` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBufferAttribute.js#L236
pub fn InterleavedBufferAttribute::set_y(
  self : InterleavedBufferAttribute,
  index : Int,
  y : Double,
) -> InterleavedBufferAttribute {
  self.data.array[index * self.data.stride + self.offset + 1] = y
  self
}

///|
/// 写入指定顶点的 z。下标是 `index * stride + offset + 2`。归一化换算还没有落地，写入的是原值。
/// r186: `setZ` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBufferAttribute.js#L253
pub fn InterleavedBufferAttribute::set_z(
  self : InterleavedBufferAttribute,
  index : Int,
  z : Double,
) -> InterleavedBufferAttribute {
  self.data.array[index * self.data.stride + self.offset + 2] = z
  self
}

///|
/// 写入指定顶点的 w。下标是 `index * stride + offset + 3`。归一化换算还没有落地，写入的是原值。
/// r186: `setW` https://github.com/mrdoob/three.js/blob/r186/src/core/InterleavedBufferAttribute.js#L270
pub fn InterleavedBufferAttribute::set_w(
  self : InterleavedBufferAttribute,
  index : Int,
  w : Double,
) -> InterleavedBufferAttribute {
  self.data.array[index * self.data.stride + self.offset + 3] = w
  self
}
