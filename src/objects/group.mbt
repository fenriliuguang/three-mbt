// r186: `Group` https://github.com/mrdoob/three.js/blob/r186/src/objects/Group.js#L20

///|
/// 用来把若干节点当作一个整体变换。
/// r186: `Group` https://github.com/mrdoob/three.js/blob/r186/src/objects/Group.js#L20
pub(all) struct Group {
  node : Object3D
}

///|
pub fn Group::new() -> Group {
  { node: Object3D::new(kind=@core.Group), }
}

///|
pub impl @core.AsNode for Group with fn to_node(self) {
  self.node
}

///|
pub extend Group with @core.AsNode::{to_node}

///|
pub fn[T : @core.AsNode] Group::add(self : Group, child : T) -> Group {
  ignore(self.node.add(child.to_node()))
  self
}

///|
/// 复制变换和子节点。`Group` 没有自己的 `copy`，行为来自 `Object3D.copy`。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1605
pub fn Group::copy(
  self : Group,
  source : Group,
  recursive? : Bool = true,
) -> Group {
  ignore(self.node.copy(source.node, recursive~))
  self
}

///|
/// 新建一个组再复制。three.js 没有单独的 `Group.clone`，用的是 `Object3D.clone`。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/Object3D.js#L1592
pub fn Group::clone(self : Group, recursive? : Bool = true) -> Group {
  Group::new().copy(self, recursive~)
}

