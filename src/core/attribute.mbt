///|
/// 顶点缓冲。数值用 `Double` 保存，对应 r186 里进入着色器之前的 JS number。
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
