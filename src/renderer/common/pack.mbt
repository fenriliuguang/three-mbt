///|
using @core {type BufferAttribute}

///|
/// `mat4x4<f32>` 加 `vec4<f32>`。80 字节，16 字节对齐。
pub let uniform_bytes : Int = 80

///|
fn write_f32(dst : FixedArray[Byte], offset : Int, value : Double) -> Unit {
  let bytes = Float::from_double(value).to_le_bytes()
  let mut index = 0
  while index < 4 {
    dst[offset + index] = bytes.at(index)
    index = index + 1
  }
}

///|
fn write_u32(dst : FixedArray[Byte], offset : Int, value : Int) -> Unit {
  let bits = value.reinterpret_as_uint()
  dst[offset] = bits.to_byte()
  dst[offset + 1] = (bits >> 8).to_byte()
  dst[offset + 2] = (bits >> 16).to_byte()
  dst[offset + 3] = (bits >> 24).to_byte()
}

///|
/// 把属性里的 `Double` 收成小端 `f32`。
pub fn pack_f32(attribute : BufferAttribute) -> FixedArray[Byte] {
  let dst = FixedArray::make(attribute.array.length() * 4, b'\x00')
  for index in 0..<attribute.array.length() {
    write_f32(dst, index * 4, attribute.array[index])
  }
  dst
}

///|
/// 索引收成小端 `u32`。
pub fn pack_u32_indices(index : BufferAttribute) -> FixedArray[Byte] {
  let dst = FixedArray::make(index.count * 4, b'\x00')
  for item in 0..<index.count {
    write_u32(dst, item * 4, index.get_x(item).to_int())
  }
  dst
}

///|
/// 模型视图投影在前 64 字节，线性颜色和透明度在后 16 字节。
pub fn pack_uniforms(
  mvp : @math.Matrix4,
  color : @math.Color,
  opacity : Double,
) -> FixedArray[Byte] {
  let dst = FixedArray::make(uniform_bytes, b'\x00')
  for index in 0..<16 {
    write_f32(dst, index * 4, mvp.elements[index])
  }
  write_f32(dst, 64, color.r)
  write_f32(dst, 68, color.g)
  write_f32(dst, 72, color.b)
  write_f32(dst, 76, opacity)
  dst
}
