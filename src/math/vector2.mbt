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
