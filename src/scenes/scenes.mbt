///|
using @core {type Object3D}

///|
/// 线性雾或指数平方雾，对应 r186 的 `Fog` 和 `FogExp2`。
pub(all) enum FogKind {
  Linear
  Exp2
}

///|
/// `near` 和 `far` 是视图空间深度，只给线性雾用。`density` 只给指数平方雾用。
pub(all) struct Fog {
  color : @math.Color
  mut near : Double
  mut far : Double
  mut density : Double
  kind : FogKind
}

///|
/// 线性雾。默认 `near = 1`、`far = 1000`，与 r186 `Fog` 相同。
pub fn Fog::linear(
  hex? : Int = 0xFFFFFF,
  near? : Double = 1.0,
  far? : Double = 1000.0,
) -> Fog {
  {
    color: @math.Color::new().set_hex(hex),
    near,
    far,
    density: 0.0,
    kind: Linear,
  }
}

///|
/// 指数平方雾。默认密度 `0.00025`，与 r186 `FogExp2` 相同。
pub fn Fog::exp2(hex? : Int = 0xFFFFFF, density? : Double = 0.00025) -> Fog {
  {
    color: @math.Color::new().set_hex(hex),
    near: 1.0,
    far: 1000.0,
    density,
    kind: Exp2,
  }
}

///|
/// 深度上的雾因子，0 是原色，1 是雾的颜色。线性雾用 smoothstep，指数雾是 `1 - exp(-density² depth²)`。
pub fn Fog::factor(self : Fog, depth : Double) -> Double {
  match self.kind {
    Linear => {
      let span = self.far - self.near
      let safe = if span > 0.000001 { span } else { 0.000001 }
      let mut t = (depth - self.near) / safe
      if t < 0.0 {
        t = 0.0
      }
      if t > 1.0 {
        t = 1.0
      }
      t * t * (3.0 - 2.0 * t)
    }
    Exp2 => {
      let amount = self.density * depth
      1.0 - @std.exp(-(amount * amount))
    }
  }
}

///|
/// 场景根节点。背景色是可选的纯色。雾是可选的线性雾或指数平方雾。
pub(all) struct Scene {
  node : Object3D
  mut background : @math.Color?
  mut background_blurriness : Double
  mut background_intensity : Double
  mut fog : Fog?
}

///|
pub fn Scene::new() -> Scene {
  {
    node: Object3D::new(kind=@core.Scene),
    background: None,
    background_blurriness: 0.0,
    background_intensity: 1.0,
    fog: None,
  }
}

///|
pub impl @core.AsNode for Scene with fn to_node(self) {
  self.node
}

///|
pub extend Scene with @core.AsNode::{to_node}

///|
pub fn[T : @core.AsNode] Scene::add(self : Scene, child : T) -> Scene {
  ignore(self.node.add(child.to_node()))
  self
}

///|
pub fn Scene::set_background(self : Scene, color : @math.Color) -> Unit {
  self.background = Some(color)
}

///|
/// `None` 表示这一帧不画雾。
pub fn Scene::set_fog(self : Scene, fog : Fog?) -> Unit {
  self.fog = fog
}
