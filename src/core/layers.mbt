///|
/// 32 层可见性掩码。默认只属于第 0 层，与 r186 `Layers` 相同。
pub(all) struct Layers {
  mut mask : Int
}

///|
pub fn Layers::new() -> Layers {
  { mask: 1, }
}

///|
pub fn Layers::set(self : Layers, layer : Int) -> Unit {
  self.mask = 1 << layer
}

///|
pub fn Layers::enable(self : Layers, layer : Int) -> Unit {
  self.mask = self.mask | (1 << layer)
}

///|
pub fn Layers::enable_all(self : Layers) -> Unit {
  self.mask = -1
}

///|
pub fn Layers::toggle(self : Layers, layer : Int) -> Unit {
  self.mask = self.mask ^ (1 << layer)
}

///|
pub fn Layers::disable(self : Layers, layer : Int) -> Unit {
  self.mask = self.mask & (1 << layer).lnot()
}

///|
pub fn Layers::disable_all(self : Layers) -> Unit {
  self.mask = 0
}

///|
pub fn Layers::intersects(self : Layers, layers : Layers) -> Bool {
  (self.mask & layers.mask) != 0
}

///|
pub fn Layers::is_enabled(self : Layers, layer : Int) -> Bool {
  (self.mask & (1 << layer)) != 0
}
