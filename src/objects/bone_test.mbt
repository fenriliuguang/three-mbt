///|
test "Bone adds a child bone at y 5" {
  let root = @objects.Bone::new()
  let child = @objects.Bone::new()
  ignore(root.add(child))
  ignore(child.node.position.set(0.0, 5.0, 0.0))
  assert_eq(root.node.kind is @core.NodeKind::Bone, true)
  assert_eq(child.node.kind is @core.NodeKind::Bone, true)
  assert_eq(child.node.position.y, 5.0)
  assert_eq(root.node.children.length(), 1)
  assert_eq(physical_equal(root.node.children[0], child.node), true)
  assert_eq(root.node.children[0].position.y, 5.0)
}

///|
test "Bone.copy clones the child and keeps the transform" {
  let source = @objects.Bone::new()
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  source.node.render_order = 4
  let child = @objects.Bone::new()
  child.node.name = "marker"
  ignore(source.add(child))
  let destination = @objects.Bone::new()
  ignore(destination.node.position.set(1.0, 0.0, 0.0))
  let copied = destination.copy(source)
  assert_eq(physical_equal(copied, destination), true)
  assert_eq(destination.node.kind is @core.NodeKind::Bone, true)
  assert_eq(destination.node.position.y, 3.0)
  assert_eq(destination.node.position.x, 0.0)
  assert_eq(destination.node.render_order, 4)
  assert_eq(destination.node.children.length(), 1)
  assert_eq(destination.node.children[0].name, "marker")
  assert_eq(destination.node.children[0].kind is @core.NodeKind::Bone, true)
  assert_eq(physical_equal(destination.node.children[0], child.node), false)
  assert_eq(source.node.children.length(), 1)
  let bare = @objects.Bone::new()
  ignore(bare.copy(source, recursive=false))
  assert_eq(bare.node.children.length(), 0)
  assert_eq(bare.node.position.y, 3.0)
  assert_eq(bare.node.render_order, 4)
  assert_eq(source.node.children[0].name, "marker")
}

///|
test "Bone.clone keeps the transform and drops children when asked" {
  let source = @objects.Bone::new()
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  source.node.render_order = 4
  let child = @objects.Bone::new()
  child.node.name = "marker"
  ignore(source.add(child))
  let cloned = source.clone()
  assert_eq(physical_equal(cloned, source), false)
  assert_eq(cloned.node.kind is @core.NodeKind::Bone, true)
  assert_eq(cloned.node.position.y, 3.0)
  assert_eq(cloned.node.position.x, 0.0)
  assert_eq(cloned.node.render_order, 4)
  assert_eq(cloned.node.children.length(), 1)
  assert_eq(cloned.node.children[0].name, "marker")
  assert_eq(cloned.node.children[0].kind is @core.NodeKind::Bone, true)
  assert_eq(physical_equal(cloned.node.children[0], child.node), false)
  let bare = source.clone(recursive=false)
  assert_eq(bare.node.children.length(), 0)
  assert_eq(bare.node.position.y, 3.0)
  assert_eq(bare.node.render_order, 4)
  assert_eq(source.node.children.length(), 1)
  assert_eq(source.node.position.y, 3.0)
}

