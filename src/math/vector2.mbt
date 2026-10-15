// r186: `Vector2` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L28

///|
/// 二维向量。对齐 three.js r186 `Vector2` 的运算子集。
/// r186: `Vector2` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L28
pub(all) struct Vector2 {
  mut x : Double
  mut y : Double
}

///|
pub fn Vector2::new(x? : Double = 0.0, y? : Double = 0.0) -> Vector2 {
  { x, y, }
}

///|
pub fn Vector2::set(self : Vector2, x : Double, y : Double) -> Vector2 {
  self.x = x
  self.y = y
  self
}

///|
/// r186: `setScalar` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L123
pub fn Vector2::set_scalar(self : Vector2, scalar : Double) -> Vector2 {
  self.x = scalar
  self.y = scalar
  self
}

///|
/// r186: `setX` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L138
pub fn Vector2::set_x(self : Vector2, x : Double) -> Vector2 {
  self.x = x
  self
}

///|
/// r186: `setY` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L152
pub fn Vector2::set_y(self : Vector2, y : Double) -> Vector2 {
  self.y = y
  self
}

///|
/// 0 是 x，1 是 y。其他下标中止。
/// r186: `setComponent` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L167
pub fn Vector2::set_component(
  self : Vector2,
  index : Int,
  value : Double,
) -> Vector2 {
  match index {
    0 => self.x = value
    1 => self.y = value
    _ => abort("Vector2 index is out of range")
  }
  self
}

///|
/// 0 是 x，1 是 y。其他下标中止。
/// r186: `getComponent` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L187
pub fn Vector2::get_component(self : Vector2, index : Int) -> Double {
  match index {
    0 => self.x
    1 => self.y
    _ => abort("Vector2 index is out of range")
  }
}

///|
pub fn Vector2::copy(self : Vector2, v : Vector2) -> Vector2 {
  self.x = v.x
  self.y = v.y
  self
}

///|
pub fn Vector2::clone(self : Vector2) -> Vector2 {
  Vector2::new(x=self.x, y=self.y)
}

///|
pub fn Vector2::add(self : Vector2, v : Vector2) -> Vector2 {
  self.x += v.x
  self.y += v.y
  self
}

///|
/// r186: `addScalar` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L246
pub fn Vector2::add_scalar(self : Vector2, s : Double) -> Vector2 {
  self.x += s
  self.y += s
  self
}

///|
/// 把两个向量的和写入自身。两个来源不改。
/// r186: `addVectors` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L262
pub fn Vector2::add_vectors(
  self : Vector2,
  a : Vector2,
  b : Vector2,
) -> Vector2 {
  self.x = a.x + b.x
  self.y = a.y + b.y
  self
}

///|
/// 加上 `v * s`。另一个向量不改。
/// r186: `addScaledVector` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L278
pub fn Vector2::add_scaled_vector(
  self : Vector2,
  v : Vector2,
  s : Double,
) -> Vector2 {
  self.x += v.x * s
  self.y += v.y * s
  self
}

///|
pub fn Vector2::sub(self : Vector2, v : Vector2) -> Vector2 {
  self.x -= v.x
  self.y -= v.y
  self
}

///|
pub fn Vector2::multiply_scalar(self : Vector2, s : Double) -> Vector2 {
  self.x *= s
  self.y *= s
  self
}

///|
pub fn Vector2::dot(self : Vector2, v : Vector2) -> Double {
  self.x * v.x + self.y * v.y
}

///|
pub fn Vector2::length_sq(self : Vector2) -> Double {
  self.x * self.x + self.y * self.y
}

///|
pub fn Vector2::length(self : Vector2) -> Double {
  self.length_sq().sqrt()
}

///|
pub fn Vector2::normalize(self : Vector2) -> Vector2 {
  let len = self.length()
  if len == 0.0 {
    self
  } else {
    self.multiply_scalar(1.0 / len)
  }
}

///|
pub fn Vector2::lerp(self : Vector2, v : Vector2, t : Double) -> Vector2 {
  self.x += (v.x - self.x) * t
  self.y += (v.y - self.y) * t
  self
}

///|
pub fn Vector2::equals(self : Vector2, v : Vector2) -> Bool {
  self.x == v.x && self.y == v.y
}
