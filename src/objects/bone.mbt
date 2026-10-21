// r186: `Bone` https://github.com/mrdoob/three.js/blob/r186/src/objects/Bone.js#L17

///|
/// 骨架上的一根骨骼。种类是 `Bone`。
/// r186: `Bone` https://github.com/mrdoob/three.js/blob/r186/src/objects/Bone.js#L17
pub(all) struct Bone {
  node : Object3D
}

///|
pub fn Bone::new() -> Bone {
  { node: Object3D::new(kind=@core.Bone), }
}

///|
pub impl @core.AsNode for Bone with fn to_node(self) {
  self.node
}

///|
pub extend Bone with @core.AsNode::{to_node}

///|
pub fn[T : @core.AsNode] Bone::add(self : Bone, child : T) -> Bone {
  ignore(self.node.add(child.to_node()))
  self
}

///|
/// 复制变换和子节点。`Bone` 没有自己的 `copy`，行为来自 `Object3D.copy`。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1605
pub fn Bone::copy(
  self : Bone,
  source : Bone,
  recursive? : Bool = true,
) -> Bone {
  ignore(self.node.copy(source.node, recursive~))
  self
}

///|
/// 新建一根骨骼再复制。three.js 没有单独的 `Bone.clone`，用的是 `Object3D.clone`。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1592
pub fn Bone::clone(self : Bone, recursive? : Bool = true) -> Bone {
  Bone::new().copy(self, recursive~)
}

