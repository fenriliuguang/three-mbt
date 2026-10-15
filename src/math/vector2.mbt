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
/// r186: `subScalar` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L308
pub fn Vector2::sub_scalar(self : Vector2, s : Double) -> Vector2 {
  self.x -= s
  self.y -= s
  self
}

///|
/// 把两个向量的差写入自身。两个来源不改。
/// r186: `subVectors` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L324
pub fn Vector2::sub_vectors(
  self : Vector2,
  a : Vector2,
  b : Vector2,
) -> Vector2 {
  self.x = a.x - b.x
  self.y = a.y - b.y
  self
}

///|
/// 按分量相乘。另一个向量不改。
/// r186: `multiply` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L339
pub fn Vector2::multiply(self : Vector2, v : Vector2) -> Vector2 {
  self.x *= v.x
  self.y *= v.y
  self
}

///|
/// 按分量相除。另一个向量不改。
/// r186: `divide` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L369
pub fn Vector2::divide(self : Vector2, v : Vector2) -> Vector2 {
  self.x /= v.x
  self.y /= v.y
  self
}

///|
/// r186: `divideScalar` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L384
pub fn Vector2::divide_scalar(self : Vector2, scalar : Double) -> Vector2 {
  self.multiply_scalar(1.0 / scalar)
}

///|
/// 第三分量按 1 参与乘法，结果只保留 x 和 y。
/// r186: `applyMatrix3` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L397
pub fn Vector2::apply_matrix3(self : Vector2, m : Matrix3) -> Vector2 {
  let x = self.x
  let y = self.y
  let e = m.elements
  self.x = e[0] * x + e[3] * y + e[6]
  self.y = e[1] * x + e[4] * y + e[7]
  self
}

///|
/// 每个分量取较小值。另一个向量不改。
/// r186: `min` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L416
pub fn Vector2::min(self : Vector2, v : Vector2) -> Vector2 {
  self.x = self.x.min(v.x)
  self.y = self.y.min(v.y)
  self
}

///|
/// 每个分量取较大值。另一个向量不改。
/// r186: `max` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L432
pub fn Vector2::max(self : Vector2, v : Vector2) -> Vector2 {
  self.x = self.x.max(v.x)
  self.y = self.y.max(v.y)
  self
}

///|
/// 假定每个分量都是 `min` 小于 `max`。两个边界向量不改。
/// r186: `clamp` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L451
pub fn Vector2::clamp(self : Vector2, min : Vector2, max : Vector2) -> Vector2 {
  self.x = self.x.clamp(min=min.x, max=max.x)
  self.y = self.y.clamp(min=min.y, max=max.y)
  self
}

///|
/// 假定 `min_val` 小于 `max_val`。
/// r186: `clampScalar` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L472
pub fn Vector2::clamp_scalar(
  self : Vector2,
  min_val : Double,
  max_val : Double,
) -> Vector2 {
  self.x = self.x.clamp(min=min_val, max=max_val)
  self.y = self.y.clamp(min=min_val, max=max_val)
  self
}

///|
/// 假定 `min` 小于 `max`。零向量保持为零。
/// r186: `clampLength` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L491
pub fn Vector2::clamp_length(
  self : Vector2,
  min : Double,
  max : Double,
) -> Vector2 {
  let length = self.length()
  let divisor = if length == 0.0 { 1.0 } else { length }
  self.divide_scalar(divisor).multiply_scalar(length.clamp(min=min, max=max))
}

///|
/// r186: `floor` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L504
pub fn Vector2::floor(self : Vector2) -> Vector2 {
  self.x = self.x.floor()
  self.y = self.y.floor()
  self
}

///|
/// r186: `ceil` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L518
pub fn Vector2::ceil(self : Vector2) -> Vector2 {
  self.x = self.x.ceil()
  self.y = self.y.ceil()
  self
}

///|
/// 一半时朝正无穷取整。
/// r186: `round` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L532
pub fn Vector2::round(self : Vector2) -> Vector2 {
  self.x = self.x.round()
  self.y = self.y.round()
  self
}

///|
/// 朝零取整。
/// r186: `roundToZero` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L547
pub fn Vector2::round_to_zero(self : Vector2) -> Vector2 {
  self.x = self.x.trunc()
  self.y = self.y.trunc()
  self
}

///|
/// r186: `negate` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L561
pub fn Vector2::negate(self : Vector2) -> Vector2 {
  self.x = -self.x
  self.y = -self.y
  self
}

///|
/// 返回叉积的 z 分量。两个向量都不改。
/// r186: `cross` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L588
pub fn Vector2::cross(self : Vector2, v : Vector2) -> Double {
  self.x * v.y - self.y * v.x
}

///|
/// r186: `manhattanLength` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L623
pub fn Vector2::manhattan_length(self : Vector2) -> Double {
  self.x.abs() + self.y.abs()
}

///|
/// 相对正 X 轴的夹角，范围是 `[0, 2π)`。向量本身不改。
/// r186: `angle` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L646
pub fn Vector2::angle(self : Vector2) -> Double {
  @std.atan2(-self.y, -self.x) + @std.PI
}

///|
/// 零长度向量返回 π/2。两个向量都不改。
/// r186: `angleTo` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L660
pub fn Vector2::angle_to(self : Vector2, v : Vector2) -> Double {
  let denominator = (self.length_sq() * v.length_sq()).sqrt()
  if denominator == 0.0 {
    return @std.PI / 2.0
  }
  let theta = self.dot(v) / denominator
  @std.acos(theta.clamp(min=-1.0, max=1.0))
}

///|
/// 直线距离。两个向量都不改。
/// r186: `distanceTo` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L680
pub fn Vector2::distance_to(self : Vector2, v : Vector2) -> Double {
  self.distance_to_squared(v).sqrt()
}

///|
/// 两个向量都不改。
/// r186: `distanceToSquared` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L694
pub fn Vector2::distance_to_squared(self : Vector2, v : Vector2) -> Double {
  let dx = self.x - v.x
  let dy = self.y - v.y
  dx * dx + dy * dy
}

///|
/// 两个向量都不改。
/// r186: `manhattanDistanceTo` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L707
pub fn Vector2::manhattan_distance_to(self : Vector2, v : Vector2) -> Double {
  (self.x - v.x).abs() + (self.y - v.y).abs()
}

///|
/// 零向量保持为零。
/// r186: `setLength` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L720
pub fn Vector2::set_length(self : Vector2, length : Double) -> Vector2 {
  self.normalize().multiply_scalar(length)
}

///|
/// 两个来源不改。
/// r186: `lerpVectors` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L754
pub fn Vector2::lerp_vectors(
  self : Vector2,
  v1 : Vector2,
  v2 : Vector2,
  alpha : Double,
) -> Vector2 {
  self.x = v1.x + (v2.x - v1.x) * alpha
  self.y = v1.y + (v2.y - v1.y) * alpha
  self
}

///|
/// `offset` 默认是 0。数组本身不改。
/// r186: `fromArray` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L783
pub fn Vector2::from_array(
  self : Vector2,
  array : Array[Double],
  offset? : Int = 0,
) -> Vector2 {
  self.x = array[offset]
  self.y = array[offset + 1]
  self
}

///|
/// 省略数组时新建一个。短于 `offset + 2` 的数组会补零再写入。向量本身不改。
/// r186: `toArray` https://github.com/mrdoob/three.js/blob/r186/src/math/Vector2.js#L800
pub fn Vector2::to_array(
  self : Vector2,
  array? : Array[Double],
  offset? : Int = 0,
) -> Array[Double] {
  let target = match array {
    None => []
    Some(array) => array
  }
  let end = offset + 2
  while target.length() < end {
    target.push(0.0)
  }
  target[offset] = self.x
  target[offset + 1] = self.y
  target
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
