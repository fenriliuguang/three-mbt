// r186: `Sprite` https://github.com/mrdoob/three.js/blob/r186/src/objects/Sprite.js#L47

///|
/// 始终朝向相机的四边形。`center` 与节点上的锚点是同一个向量，默认 `(0.5, 0.5)`。几何体是所有精灵共用的那一份。`count` 默认是 `1`。
/// r186: `Sprite` https://github.com/mrdoob/three.js/blob/r186/src/objects/Sprite.js#L47
/// r186: `center` https://github.com/mrdoob/three.js/blob/r186/src/objects/Sprite.js#L110
/// r186: `geometry` https://github.com/mrdoob/three.js/blob/r186/src/objects/Sprite.js#L93
/// r186: `count` https://github.com/mrdoob/three.js/blob/r186/src/objects/Sprite.js#L119
pub(all) struct Sprite {
  node : Object3D
  mut material : @materials.SpriteMaterial
  center : @math.Vector2
  geometry : BufferGeometry
  mut count : Int
}

///|
pub fn Sprite::new(material : @materials.SpriteMaterial) -> Sprite {
  let node = Object3D::new(kind=@core.NodeKind::Sprite)
  let center = @math.Vector2::new(x=0.5, y=0.5)
  node.sprite = Some(@core.SpriteState::{
    center,
    rotation: material.rotation,
    size_attenuation: material.size_attenuation,
  })
  { node, material, center, geometry: sprite_geometry(), count: 1, }
}

///|
pub impl @core.AsNode for Sprite with fn to_node(self) {
  self.node
}

///|
pub extend Sprite with @core.AsNode::{to_node}

///|
/// 复制变换、锚点和材质。锚点写入已有的向量，材质沿用源对象。`count` 不复制。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/objects/Sprite.js#L216
pub fn Sprite::copy(
  self : Sprite,
  source : Sprite,
  recursive? : Bool = true,
) -> Sprite {
  ignore(self.node.copy(source.node, recursive~))
  ignore(self.center.copy(source.center))
  self.material = source.material
  self.refresh()
  self
}

///|
/// 新建一只精灵再复制。three.js 没有单独的 `Sprite.clone`，用的是 `Object3D.clone`。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1592
pub fn Sprite::clone(self : Sprite, recursive? : Bool = true) -> Sprite {
  Sprite::new(self.material).copy(self, recursive~)
}

///|
/// 把材质上的旋转和尺寸衰减写回节点。直接改这两个字段不会更新射线用的状态。锚点是共享的。
pub fn Sprite::refresh(self : Sprite) -> Unit {
  match self.node.sprite {
    None => ()
    Some(state) => {
      state.rotation = self.material.rotation
      state.size_attenuation = self.material.size_attenuation
    }
  }
}

///|
/// 用世界矩阵变换一个包围球，再交给视锥。球心从原点出发，半径是 `sqrt(2) / 2` 加上锚点到 `(0.5, 0.5)` 的距离。
/// r186: `intersectsFrustum` https://github.com/mrdoob/three.js/blob/r186/src/objects/Sprite.js#L129
/// r186: `intersectsSprite` https://github.com/mrdoob/three.js/blob/r186/src/math/Frustum.js#L174
pub fn Sprite::intersects_frustum(
  self : Sprite,
  frustum : @math.Frustum,
) -> Bool {
  let sphere = @math.Sphere::new(radius=0.0)
  let offset = @math.Vector2::new(x=0.5, y=0.5).distance_to(self.center)
  sphere.radius = 0.7071067811865476 + offset
  ignore(sphere.apply_matrix4(self.node.matrix_world))
  frustum.intersects_sphere(sphere)
}

///|
/// 任一已用视锥碰到这张精灵则为真。`count` 为 0 时为假。
/// r186: `intersectsSprite` https://github.com/mrdoob/three.js/blob/r186/src/math/FrustumArray.js#L108
pub fn Sprite::intersects_frustum_array(
  self : Sprite,
  frustums : @math.FrustumArray,
) -> Bool {
  for i in 0..<frustums.count {
    if self.intersects_frustum(frustums.frustums[i]) {
      return true
    }
  }
  false
}

