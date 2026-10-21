///|
test "SkinnedMesh starts attached with identity bind matrices" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.5, 0.0, 0.0], 3),
    ),
  )
  let material = @materials.Material::basic()
  let skin = @objects.SkinnedMesh::new(geometry, material)
  assert_eq(skin.mesh.node.kind is @core.NodeKind::Mesh, true)
  assert_eq(physical_equal(skin.mesh.geometry, geometry), true)
  assert_eq(skin.mesh.geometry.get_attribute("position").unwrap().array[0], 0.5)
  assert_eq(skin.mesh.count, 1)
  assert_eq(skin.bind_mode is @constants.BindMode::Attached, true)
  assert_eq(skin.bind_matrix.elements[0], 1.0)
  assert_eq(skin.bind_matrix.elements[13], 0.0)
  assert_eq(skin.bind_matrix.elements[15], 1.0)
  assert_eq(skin.bind_matrix_inverse.elements[0], 1.0)
  assert_eq(skin.bind_matrix_inverse.elements[13], 0.0)
  assert_eq(skin.bind_matrix_inverse.elements[15], 1.0)
  assert_eq(skin.bounding_box is None, true)
  assert_eq(skin.bounding_sphere is None, true)
  assert_eq(skin.skeleton is None, true)
  skin.bind_mode = @constants.Detached
  assert_eq(skin.bind_mode is @constants.BindMode::Detached, true)
  assert_eq(physical_equal(skin.to_node(), skin.mesh.node), true)
}

///|
test "SkinnedMesh.bind stores the skeleton and the inverse bind matrix" {
  let bone = @objects.Bone::new()
  let given = @math.Matrix4::new()
  ignore(
    given.set(
      1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 4.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0,
    ),
  )
  let explicit = @objects.Skeleton::new(bones=[bone])
  assert_eq(explicit.bone_inverses[0].elements[13], 0.0)
  let held = @objects.SkinnedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
  )
  held.bind(explicit, bind_matrix=given)
  match held.skeleton {
    None => assert_eq(false, true)
    Some(skeleton) => assert_eq(physical_equal(skeleton, explicit), true)
  }
  assert_eq(held.bind_matrix.elements[13], 4.0)
  assert_eq(held.bind_matrix_inverse.elements[13], -4.0)
  assert_eq(given.elements[13], 4.0)
  assert_eq(explicit.bone_inverses[0].elements[13], 0.0)
  let shoulder = @objects.Bone::new()
  ignore(shoulder.node.position.set(0.0, -5.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  let arm = @objects.Skeleton::new(bones=[shoulder])
  assert_eq(arm.bone_inverses[0].elements[13], 5.0)
  ignore(shoulder.node.position.set(0.0, -2.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  let skin = @objects.SkinnedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
  )
  ignore(skin.mesh.node.position.set(0.0, 3.0, 0.0))
  skin.bind(arm)
  assert_eq(arm.bone_inverses[0].elements[13], 2.0)
  assert_eq(skin.bind_matrix.elements[13], 3.0)
  assert_eq(skin.bind_matrix_inverse.elements[13], -3.0)
  ignore(skin.mesh.node.position.set(0.0, 9.0, 0.0))
  skin.mesh.node.update_matrix_world(force=true)
  assert_eq(skin.bind_matrix.elements[13], 3.0)
  assert_eq(skin.mesh.node.matrix_world.elements[13], 9.0)
}

///|
test "SkinnedMesh.pose restores the bound skeleton" {
  let shoulder = @objects.Bone::new()
  let elbow = @objects.Bone::new()
  let hand = @objects.Bone::new()
  ignore(shoulder.add(elbow))
  ignore(elbow.add(hand))
  ignore(shoulder.node.position.set(0.0, -5.0, 0.0))
  ignore(elbow.node.position.set(0.0, 0.0, 0.0))
  ignore(hand.node.position.set(0.0, 5.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  let arm = @objects.Skeleton::new(bones=[shoulder, elbow, hand])
  let skin = @objects.SkinnedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
  )
  skin.bind(arm, bind_matrix=@math.Matrix4::new())
  ignore(shoulder.node.position.set(0.0, -2.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  assert_eq(shoulder.node.position.y, -2.0)
  skin.pose()
  assert_eq(shoulder.node.position.y, -5.0)
  assert_eq(elbow.node.position.y, 0.0)
  assert_eq(hand.node.position.y, 5.0)
  assert_eq(shoulder.node.matrix_world.elements[13], -5.0)
  assert_eq(hand.node.matrix_world.elements[13], 0.0)
  assert_eq(arm.bone_inverses[0].elements[13], 5.0)
}

///|
test "panic SkinnedMesh.pose requires a skeleton" {
  let skin = @objects.SkinnedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
  )
  skin.pose()
}

///|
test "SkinnedMesh.normalizeSkinWeights scales by the Manhattan length" {
  let geometry = @core.BufferGeometry::new()
  let weights = @core.BufferAttribute::new(
    [2.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0, 0.0, -2.0, 2.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0],
    4,
  )
  ignore(geometry.set_attribute("skinWeight", weights))
  let skin = @objects.SkinnedMesh::new(geometry, @materials.Material::basic())
  skin.normalize_skin_weights()
  let stored = skin.mesh.geometry.get_attribute("skinWeight").unwrap()
  assert_eq(physical_equal(stored, weights), true)
  assert_eq(stored.array[0], 0.5)
  assert_eq(stored.array[1], 0.0)
  assert_eq(stored.array[2], 0.0)
  assert_eq(stored.array[3], 0.5)
  assert_eq(stored.array[4], 1.0)
  assert_eq(stored.array[5], 0.0)
  assert_eq(stored.array[6], 0.0)
  assert_eq(stored.array[7], 0.0)
  assert_eq(stored.array[8], -0.5)
  assert_eq(stored.array[9], 0.5)
  assert_eq(stored.array[10], 0.0)
  assert_eq(stored.array[11], 0.0)
  assert_eq(stored.array[12], 0.25)
  assert_eq(stored.array[13], 0.25)
  assert_eq(stored.array[14], 0.25)
  assert_eq(stored.array[15], 0.25)
}

///|
test "panic SkinnedMesh.normalizeSkinWeights requires skinWeight" {
  let skin = @objects.SkinnedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
  )
  skin.normalize_skin_weights()
}

///|
test "SkinnedMesh.updateMatrixWorld refreshes the inverse bind matrix" {
  let skin = @objects.SkinnedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
  )
  ignore(skin.mesh.node.position.set(0.0, 3.0, 0.0))
  skin.update_matrix_world()
  assert_eq(skin.mesh.node.matrix_world.elements[13], 3.0)
  assert_eq(skin.bind_matrix.elements[13], 0.0)
  assert_eq(skin.bind_matrix_inverse.elements[13], -3.0)
  assert_eq(skin.bind_matrix_inverse.elements[0], 1.0)
  ignore(
    skin.bind_matrix.set(
      1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 4.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0,
    ),
  )
  skin.bind_mode = @constants.Detached
  ignore(skin.mesh.node.position.set(0.0, 9.0, 0.0))
  skin.update_matrix_world(force=true)
  assert_eq(skin.mesh.node.matrix_world.elements[13], 9.0)
  assert_eq(skin.bind_matrix.elements[13], 4.0)
  assert_eq(skin.bind_matrix_inverse.elements[13], -4.0)
}

///|
test "SkinnedMesh.applyBoneTransform blends bone translations" {
  let bone0 = @objects.Bone::new()
  let bone1 = @objects.Bone::new()
  bone0.node.update_matrix_world(force=true)
  bone1.node.update_matrix_world(force=true)
  let arm = @objects.Skeleton::new(bones=[bone0, bone1])
  ignore(bone0.node.position.set(0.0, 5.0, 0.0))
  ignore(bone1.node.position.set(4.0, 0.0, 0.0))
  bone0.node.update_matrix_world(force=true)
  bone1.node.update_matrix_world(force=true)
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "skinIndex",
      @core.BufferAttribute::new([0.0, 99.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0], 4),
    ),
  )
  ignore(
    geometry.set_attribute(
      "skinWeight",
      @core.BufferAttribute::new([1.0, 0.0, 0.0, 0.0, 0.25, 0.75, 0.0, 0.0], 4),
    ),
  )
  let skin = @objects.SkinnedMesh::new(geometry, @materials.Material::basic())
  skin.bind(arm, bind_matrix=@math.Matrix4::new())
  let point = @math.Vector3::new(x=1.0, y=0.0, z=0.0)
  let transformed = skin.apply_bone_transform(0, point)
  assert_eq(physical_equal(transformed, point), true)
  assert_eq(point.x, 1.0)
  assert_eq(point.y, 5.0)
  assert_eq(point.z, 0.0)
  let blended = @math.Vector3::new()
  ignore(skin.apply_bone_transform(1, blended))
  assert_eq(blended.x, 3.0)
  assert_eq(blended.y, 1.25)
  assert_eq(blended.z, 0.0)
}

///|
test "SkinnedMesh.applyBoneTransform keeps a Vector4 homogeneous weight" {
  let bone0 = @objects.Bone::new()
  let bone1 = @objects.Bone::new()
  bone0.node.update_matrix_world(force=true)
  bone1.node.update_matrix_world(force=true)
  let arm = @objects.Skeleton::new(bones=[bone0, bone1])
  ignore(bone0.node.position.set(0.0, 5.0, 0.0))
  bone0.node.update_matrix_world(force=true)
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "skinIndex",
      @core.BufferAttribute::new(
        [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0],
        4,
      ),
    ),
  )
  ignore(
    geometry.set_attribute(
      "skinWeight",
      @core.BufferAttribute::new(
        [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0],
        4,
      ),
    ),
  )
  let skin = @objects.SkinnedMesh::new(geometry, @materials.Material::basic())
  skin.bind(arm, bind_matrix=@math.Matrix4::new())
  assert_eq(skin.bind_matrix.elements[0], 1.0)
  assert_eq(skin.bind_matrix.elements[13], 0.0)
  let point = @math.Vector4::new(x=1.0, y=0.0, z=0.0, w=1.0)
  let transformed = skin.apply_bone_transform_vector4(0, point)
  assert_eq(physical_equal(transformed, point), true)
  assert_eq(point.x, 1.0)
  assert_eq(point.y, 5.0)
  assert_eq(point.z, 0.0)
  assert_eq(point.w, 1.0)
  let direction = @math.Vector4::new(x=1.0, y=0.0, z=0.0, w=0.0)
  ignore(skin.apply_bone_transform_vector4(1, direction))
  assert_eq(direction.x, 1.0)
  assert_eq(direction.y, 0.0)
  assert_eq(direction.z, 0.0)
  assert_eq(direction.w, 0.0)
  let weighted = @math.Vector4::new(x=0.0, y=0.0, z=0.0, w=2.0)
  ignore(skin.apply_bone_transform_vector4(2, weighted))
  assert_eq(weighted.x, 0.0)
  assert_eq(weighted.y, 0.0)
  assert_eq(weighted.z, 0.0)
  assert_eq(weighted.w, 2.0)
}

///|
test "panic SkinnedMesh.applyBoneTransform requires a skeleton" {
  let skin = @objects.SkinnedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
  )
  ignore(skin.apply_bone_transform(0, @math.Vector3::new()))
}

///|
test "panic SkinnedMesh.applyBoneTransform Vector4 requires a skeleton" {
  let skin = @objects.SkinnedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
  )
  ignore(skin.apply_bone_transform_vector4(0, @math.Vector4::new()))
}

///|
test "SkinnedMesh.getVertexPosition applies morphs then bones" {
  let bone = @objects.Bone::new()
  bone.node.update_matrix_world(force=true)
  let arm = @objects.Skeleton::new(bones=[bone])
  ignore(bone.node.position.set(0.0, 5.0, 0.0))
  bone.node.update_matrix_world(force=true)
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([1.0, 2.0, 3.0], 3),
    ),
  )
  ignore(
    geometry.set_attribute(
      "skinIndex",
      @core.BufferAttribute::new([0.0, 0.0, 0.0, 0.0], 4),
    ),
  )
  ignore(
    geometry.set_attribute(
      "skinWeight",
      @core.BufferAttribute::new([1.0, 0.0, 0.0, 0.0], 4),
    ),
  )
  let skin = @objects.SkinnedMesh::new(geometry, @materials.Material::basic())
  skin.bind(arm, bind_matrix=@math.Matrix4::new())
  let target = @math.Vector3::new()
  let written = skin.get_vertex_position(0, target)
  assert_eq(physical_equal(written, target), true)
  assert_eq(target.x, 1.0)
  assert_eq(target.y, 7.0)
  assert_eq(target.z, 3.0)
  geometry.morph_targets_relative = true
  geometry.morph_attributes.set(
    "position",
    [@core.BufferAttribute::new([2.0, 0.0, 0.0], 3)],
  )
  skin.mesh.node.morph = Some(@core.MorphState::{
    base_position: [1.0, 2.0, 3.0],
    base_normal: None,
    base_color: None,
    targets: [],
    weights: [0.5],
    shared: false,
  })
  ignore(skin.get_vertex_position(0, target))
  assert_eq(target.x, 2.0)
  assert_eq(target.y, 7.0)
  assert_eq(target.z, 3.0)
}

///|
test "panic SkinnedMesh.getVertexPosition requires a skeleton" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([1.0, 2.0, 3.0], 3),
    ),
  )
  let skin = @objects.SkinnedMesh::new(geometry, @materials.Material::basic())
  ignore(skin.get_vertex_position(0, @math.Vector3::new()))
}

///|
test "SkinnedMesh.computeBoundingBox unions skinned vertices" {
  let bone = @objects.Bone::new()
  bone.node.update_matrix_world(force=true)
  let arm = @objects.Skeleton::new(bones=[bone])
  ignore(bone.node.position.set(0.0, 5.0, 0.0))
  bone.node.update_matrix_world(force=true)
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([1.0, 0.0, 0.0, 0.0, 4.0, 0.0], 3),
    ),
  )
  ignore(
    geometry.set_attribute(
      "skinIndex",
      @core.BufferAttribute::new([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], 4),
    ),
  )
  ignore(
    geometry.set_attribute(
      "skinWeight",
      @core.BufferAttribute::new([1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0], 4),
    ),
  )
  let skin = @objects.SkinnedMesh::new(geometry, @materials.Material::basic())
  skin.bind(arm, bind_matrix=@math.Matrix4::new())
  let box = skin.compute_bounding_box()
  match skin.bounding_box {
    None => abort("bounding box was not stored")
    Some(stored) => assert_eq(physical_equal(box, stored), true)
  }
  assert_eq(box.min.x, 0.0)
  assert_eq(box.min.y, 5.0)
  assert_eq(box.min.z, 0.0)
  assert_eq(box.max.x, 1.0)
  assert_eq(box.max.y, 9.0)
  assert_eq(box.max.z, 0.0)
  ignore(bone.node.position.set(0.0, 1.0, 0.0))
  bone.node.update_matrix_world(force=true)
  let again = skin.compute_bounding_box()
  assert_eq(physical_equal(again, box), true)
  assert_eq(box.min.x, 0.0)
  assert_eq(box.min.y, 1.0)
  assert_eq(box.min.z, 0.0)
  assert_eq(box.max.x, 1.0)
  assert_eq(box.max.y, 5.0)
  assert_eq(box.max.z, 0.0)
  let empty_geometry = @core.BufferGeometry::new()
  ignore(
    empty_geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([], 3),
    ),
  )
  let empty_skin = @objects.SkinnedMesh::new(
    empty_geometry,
    @materials.Material::basic(),
  )
  let empty_box = empty_skin.compute_bounding_box()
  assert_eq(empty_box.is_empty(), true)
  let empty_again = empty_skin.compute_bounding_box()
  assert_eq(physical_equal(empty_again, empty_box), true)
  assert_eq(empty_box.is_empty(), true)
}

///|
test "panic SkinnedMesh.computeBoundingBox requires a position attribute" {
  let skin = @objects.SkinnedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
  )
  ignore(skin.compute_bounding_box())
}

///|
test "SkinnedMesh.computeBoundingSphere encloses skinned vertices" {
  let bone = @objects.Bone::new()
  bone.node.update_matrix_world(force=true)
  let arm = @objects.Skeleton::new(bones=[bone])
  ignore(bone.node.position.set(0.0, 5.0, 0.0))
  bone.node.update_matrix_world(force=true)
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([1.0, 0.0, 0.0, -1.0, 0.0, 0.0], 3),
    ),
  )
  ignore(
    geometry.set_attribute(
      "skinIndex",
      @core.BufferAttribute::new([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], 4),
    ),
  )
  ignore(
    geometry.set_attribute(
      "skinWeight",
      @core.BufferAttribute::new([1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0], 4),
    ),
  )
  let skin = @objects.SkinnedMesh::new(geometry, @materials.Material::basic())
  skin.bind(arm, bind_matrix=@math.Matrix4::new())
  let sphere = skin.compute_bounding_sphere()
  match skin.bounding_sphere {
    None => abort("bounding sphere was not stored")
    Some(stored) => assert_eq(physical_equal(sphere, stored), true)
  }
  assert_eq(sphere.center.x, 0.0)
  assert_eq(sphere.center.y, 5.0)
  assert_eq(sphere.center.z, 0.0)
  assert_eq(sphere.radius, 1.0)
  ignore(bone.node.position.set(0.0, 1.0, 0.0))
  bone.node.update_matrix_world(force=true)
  let again = skin.compute_bounding_sphere()
  assert_eq(physical_equal(again, sphere), true)
  assert_eq(sphere.center.x, 0.0)
  assert_eq(sphere.center.y, 1.0)
  assert_eq(sphere.center.z, 0.0)
  assert_eq(sphere.radius, 1.0)
  let empty_geometry = @core.BufferGeometry::new()
  ignore(
    empty_geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([], 3),
    ),
  )
  let empty_skin = @objects.SkinnedMesh::new(
    empty_geometry,
    @materials.Material::basic(),
  )
  let empty_sphere = empty_skin.compute_bounding_sphere()
  assert_eq(empty_sphere.is_empty(), true)
  let empty_again = empty_skin.compute_bounding_sphere()
  assert_eq(physical_equal(empty_again, empty_sphere), true)
  assert_eq(empty_sphere.is_empty(), true)
  assert_eq(empty_sphere.radius, -1.0)
}

///|
test "panic SkinnedMesh.computeBoundingSphere requires a position attribute" {
  let skin = @objects.SkinnedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
  )
  ignore(skin.compute_bounding_sphere())
}

///|
test "SkinnedMesh.copy shares the skeleton and clones the bounds" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.5, 0.0, 0.0], 3),
    ),
  )
  let material = @materials.Material::basic()
  let source = @objects.SkinnedMesh::new(geometry, material)
  ignore(source.mesh.node.position.set(0.0, 3.0, 0.0))
  source.mesh.node.render_order = 4
  let child = @core.Object3D::new()
  child.name = "marker"
  ignore(source.mesh.node.add(child))
  source.bind_mode = @constants.Detached
  ignore(
    source.bind_matrix.set(
      1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 4.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0,
    ),
  )
  ignore(
    source.bind_matrix_inverse.set(
      1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, -4.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0,
      1.0,
    ),
  )
  let arm = @objects.Skeleton::new(bones=[@objects.Bone::new()])
  source.skeleton = Some(arm)
  let source_box = @math.Box3::new(
    @math.Vector3::new(x=0.0, y=5.0, z=0.0),
    @math.Vector3::new(x=1.0, y=9.0, z=0.0),
  )
  let source_sphere = @math.Sphere::new(
    center=@math.Vector3::new(x=0.0, y=5.0, z=0.0),
    radius=1.0,
  )
  source.bounding_box = Some(source_box)
  source.bounding_sphere = Some(source_sphere)
  let destination = @objects.SkinnedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::lambert(),
  )
  ignore(destination.mesh.node.position.set(1.0, 0.0, 0.0))
  destination.bounding_box = Some(
    @math.Box3::new(
      @math.Vector3::new(x=0.0, y=9.0, z=0.0),
      @math.Vector3::new(x=1.0, y=9.0, z=0.0),
    ),
  )
  destination.bounding_sphere = Some(@math.Sphere::new(radius=8.0))
  let copied = destination.copy(source)
  assert_eq(physical_equal(copied, destination), true)
  assert_eq(physical_equal(destination.mesh.geometry, geometry), true)
  assert_eq(physical_equal(destination.mesh.material, material), true)
  assert_eq(destination.mesh.node.position.y, 3.0)
  assert_eq(destination.mesh.node.position.x, 0.0)
  assert_eq(destination.mesh.node.render_order, 4)
  assert_eq(destination.mesh.node.children.length(), 1)
  assert_eq(destination.mesh.node.children[0].name, "marker")
  assert_eq(physical_equal(destination.mesh.node.children[0], child), false)
  assert_eq(destination.bind_mode is @constants.BindMode::Detached, true)
  assert_eq(destination.bind_matrix.elements[13], 4.0)
  assert_eq(destination.bind_matrix_inverse.elements[13], -4.0)
  match destination.skeleton {
    None => assert_eq(false, true)
    Some(copied_arm) => assert_eq(physical_equal(copied_arm, arm), true)
  }
  match destination.bounding_box {
    None => assert_eq(false, true)
    Some(box) => {
      assert_eq(physical_equal(box, source_box), false)
      assert_eq(box.min.y, 5.0)
      assert_eq(box.max.x, 1.0)
      assert_eq(box.max.y, 9.0)
      box.min.y = 7.0
    }
  }
  assert_eq(source_box.min.y, 5.0)
  match destination.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(physical_equal(sphere, source_sphere), false)
      assert_eq(sphere.center.y, 5.0)
      assert_eq(sphere.radius, 1.0)
      sphere.radius = 3.0
    }
  }
  assert_eq(source_sphere.radius, 1.0)
  arm.bones.push(@objects.Bone::new())
  match destination.skeleton {
    None => assert_eq(false, true)
    Some(copied_arm) => assert_eq(copied_arm.bones.length(), 2)
  }
  let bare = @objects.SkinnedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::lambert(),
  )
  ignore(bare.copy(source, recursive=false))
  assert_eq(bare.mesh.node.children.length(), 0)
  assert_eq(bare.mesh.node.position.y, 3.0)
  assert_eq(source.mesh.node.children[0].name, "marker")
  let plain = @objects.SkinnedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
  )
  let held = @objects.SkinnedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
  )
  held.bind_mode = @constants.Detached
  held.skeleton = Some(@objects.Skeleton::new(bones=[@objects.Bone::new()]))
  held.bounding_box = Some(
    @math.Box3::new(
      @math.Vector3::new(x=0.0, y=9.0, z=0.0),
      @math.Vector3::new(x=1.0, y=9.0, z=0.0),
    ),
  )
  held.bounding_sphere = Some(@math.Sphere::new(radius=8.0))
  ignore(held.copy(plain))
  assert_eq(held.bind_mode is @constants.BindMode::Attached, true)
  assert_eq(held.bind_matrix.elements[13], 0.0)
  assert_eq(held.skeleton is None, true)
  match held.bounding_box {
    None => assert_eq(false, true)
    Some(box) => assert_eq(box.min.y, 9.0)
  }
  match held.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => assert_eq(sphere.radius, 8.0)
  }
}

///|
test "SkinnedMesh.clone shares the skeleton and drops children when asked" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.5, 0.0, 0.0], 3),
    ),
  )
  let material = @materials.Material::basic()
  let source = @objects.SkinnedMesh::new(geometry, material)
  ignore(source.mesh.node.position.set(0.0, 3.0, 0.0))
  source.mesh.node.render_order = 4
  let child = @core.Object3D::new()
  child.name = "marker"
  ignore(source.mesh.node.add(child))
  source.bind_mode = @constants.Detached
  ignore(
    source.bind_matrix.set(
      1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 4.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0,
    ),
  )
  ignore(
    source.bind_matrix_inverse.set(
      1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, -4.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0,
      1.0,
    ),
  )
  let arm = @objects.Skeleton::new(bones=[@objects.Bone::new()])
  source.skeleton = Some(arm)
  let source_box = @math.Box3::new(
    @math.Vector3::new(x=0.0, y=5.0, z=0.0),
    @math.Vector3::new(x=1.0, y=9.0, z=0.0),
  )
  source.bounding_box = Some(source_box)
  source.bounding_sphere = Some(
    @math.Sphere::new(center=@math.Vector3::new(x=0.0, y=5.0, z=0.0), radius=1.0),
  )
  let cloned = source.clone()
  assert_eq(physical_equal(cloned, source), false)
  assert_eq(cloned.mesh.node.id == source.mesh.node.id, false)
  assert_eq(physical_equal(cloned.mesh.geometry, geometry), true)
  assert_eq(physical_equal(cloned.mesh.material, material), true)
  assert_eq(cloned.mesh.node.position.y, 3.0)
  assert_eq(cloned.mesh.node.position.x, 0.0)
  assert_eq(cloned.mesh.node.render_order, 4)
  assert_eq(cloned.mesh.node.children.length(), 1)
  assert_eq(cloned.mesh.node.children[0].name, "marker")
  assert_eq(physical_equal(cloned.mesh.node.children[0], child), false)
  assert_eq(cloned.bind_mode is @constants.BindMode::Detached, true)
  assert_eq(cloned.bind_matrix.elements[13], 4.0)
  assert_eq(cloned.bind_matrix_inverse.elements[13], -4.0)
  match cloned.skeleton {
    None => assert_eq(false, true)
    Some(copied_arm) => assert_eq(physical_equal(copied_arm, arm), true)
  }
  match cloned.bounding_box {
    None => assert_eq(false, true)
    Some(box) => {
      assert_eq(physical_equal(box, source_box), false)
      assert_eq(box.min.y, 5.0)
      assert_eq(box.max.y, 9.0)
      box.min.y = 7.0
    }
  }
  assert_eq(source_box.min.y, 5.0)
  match cloned.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(sphere.center.y, 5.0)
      assert_eq(sphere.radius, 1.0)
    }
  }
  let bare = source.clone(recursive=false)
  assert_eq(bare.mesh.node.children.length(), 0)
  assert_eq(bare.mesh.node.position.y, 3.0)
  assert_eq(bare.bind_matrix.elements[13], 4.0)
  assert_eq(source.mesh.node.children.length(), 1)
  assert_eq(source.mesh.node.position.y, 3.0)
}

///|
test "SkinnedMesh.raycast hits the deformed triangle" {
  let bone = @objects.Bone::new()
  bone.node.update_matrix_world(force=true)
  let arm = @objects.Skeleton::new(bones=[bone])
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0],
        3,
      ),
    ),
  )
  ignore(
    geometry.set_attribute(
      "skinIndex",
      @core.BufferAttribute::new(
        [
          0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        ],
        4,
      ),
    ),
  )
  ignore(
    geometry.set_attribute(
      "skinWeight",
      @core.BufferAttribute::new(
        [
          1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
        ],
        4,
      ),
    ),
  )
  let skin = @objects.SkinnedMesh::new(geometry, @materials.Material::basic())
  skin.bind(arm, bind_matrix=@math.Matrix4::new())
  skin.mesh.node.update_matrix_world()
  let hits = []
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  skin.raycast(raycaster, hits)
  assert_eq(hits.length(), 1)
  assert_eq(hits[0].distance, 1.0)
  assert_eq(hits[0].point.x, 0.25)
  assert_eq(hits[0].point.y, 0.25)
  assert_eq(hits[0].point.z, 0.0)
  assert_eq(physical_equal(hits[0].object, skin.mesh.node), true)
  match hits[0].face {
    None => assert_eq(false, true)
    Some(face) => {
      assert_eq(face.a, 0)
      assert_eq(face.b, 1)
      assert_eq(face.c, 2)
      assert_eq(face.normal.z, 1.0)
    }
  }
  match hits[0].barycoord {
    None => assert_eq(false, true)
    Some(bary) => {
      assert_eq(bary.x, 0.5)
      assert_eq(bary.y, 0.25)
      assert_eq(bary.z, 0.25)
    }
  }
  ignore(bone.node.position.set(0.0, 5.0, 0.0))
  bone.node.update_matrix_world(force=true)
  skin.bounding_sphere = None
  hits.clear()
  let lifted = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=5.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  skin.raycast(lifted, hits)
  assert_eq(hits.length(), 1)
  assert_eq(hits[0].distance, 1.0)
  assert_eq(hits[0].point.x, 0.25)
  assert_eq(hits[0].point.y, 5.25)
  assert_eq(hits[0].point.z, 0.0)
  skin.bounding_box = Some(
    @math.Box3::new(
      @math.Vector3::new(x=10.0, y=10.0, z=10.0),
      @math.Vector3::new(x=11.0, y=11.0, z=11.0),
    ),
  )
  hits.clear()
  skin.raycast(lifted, hits)
  assert_eq(hits.length(), 0)
  skin.bounding_box = None
  let missed = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.0, y=100.0, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  skin.raycast(missed, hits)
  assert_eq(hits.length(), 0)
}

///|
test "Object3D.raycast uses the skinned hook" {
  let bone = @objects.Bone::new()
  bone.node.update_matrix_world(force=true)
  let arm = @objects.Skeleton::new(bones=[bone])
  ignore(bone.node.position.set(0.0, 5.0, 0.0))
  bone.node.update_matrix_world(force=true)
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0],
        3,
      ),
    ),
  )
  ignore(
    geometry.set_attribute(
      "skinIndex",
      @core.BufferAttribute::new(
        [
          0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        ],
        4,
      ),
    ),
  )
  ignore(
    geometry.set_attribute(
      "skinWeight",
      @core.BufferAttribute::new(
        [
          1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
        ],
        4,
      ),
    ),
  )
  let material = @materials.Material::basic()
  let skin = @objects.SkinnedMesh::new(geometry, material)
  skin.bind(arm, bind_matrix=@math.Matrix4::new())
  skin.mesh.node.update_matrix_world()
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=5.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  let hits = raycaster.intersect_object(skin.mesh.node)
  assert_eq(hits.length(), 1)
  assert_eq(hits[0].distance, 1.0)
  assert_eq(hits[0].point.x, 0.25)
  assert_eq(hits[0].point.y, 5.25)
  assert_eq(hits[0].point.z, 0.0)
  assert_eq(physical_equal(hits[0].object, skin.mesh.node), true)
  let cloned = skin.clone()
  cloned.mesh.node.update_matrix_world()
  let cloned_hits = raycaster.intersect_object(cloned.mesh.node)
  assert_eq(cloned_hits.length(), 1)
  assert_eq(cloned_hits[0].point.y, 5.25)
  assert_eq(physical_equal(cloned_hits[0].object, cloned.mesh.node), true)
  let again = raycaster.intersect_object(skin.mesh.node)
  assert_eq(again.length(), 1)
  assert_eq(again[0].point.y, 5.25)
  let plain = @objects.Mesh::new(geometry, material)
  plain.node.update_matrix_world()
  assert_eq(plain.node.skinned_raycast is None, true)
  assert_eq(raycaster.intersect_object(plain.node).length(), 0)
}

///|
test "SkinnedMesh.raycast uses a material array" {
  let bone = @objects.Bone::new()
  bone.node.update_matrix_world(force=true)
  let arm = @objects.Skeleton::new(bones=[bone])
  ignore(bone.node.position.set(0.0, 5.0, 0.0))
  bone.node.update_matrix_world(force=true)
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0],
        3,
      ),
    ),
  )
  ignore(
    geometry.set_attribute(
      "skinIndex",
      @core.BufferAttribute::new([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], 4),
    ),
  )
  ignore(
    geometry.set_attribute(
      "skinWeight",
      @core.BufferAttribute::new([1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0], 4),
    ),
  )
  let back = @materials.Material::basic()
  back.side = @constants.Back
  let front = @materials.Material::basic()
  let skin = @objects.SkinnedMesh::new(geometry, front)
  skin.bind(arm, bind_matrix=@math.Matrix4::new())
  skin.set_materials([back, front])
  skin.mesh.node.update_matrix_world()
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=5.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  let hits = []
  skin.raycast(raycaster, hits)
  assert_eq(hits.length(), 0)
  geometry.add_group(0, 3, material_index=1)
  skin.raycast(raycaster, hits)
  assert_eq(hits.length(), 1)
  assert_eq(hits[0].distance, 1.0)
  assert_eq(hits[0].point.x, 0.25)
  assert_eq(hits[0].point.y, 5.25)
  assert_eq(hits[0].point.z, 0.0)
  match hits[0].face {
    None => assert_eq(false, true)
    Some(face) => assert_eq(face.material_index, 1)
  }
  let cloned = skin.clone()
  match cloned.mesh.materials {
    None => assert_eq(false, true)
    Some(copied) => {
      assert_eq(copied.length(), 2)
      copied.push(@materials.Material::basic())
      assert_eq(copied.length(), 3)
    }
  }
  match skin.mesh.materials {
    None => assert_eq(false, true)
    Some(source) => assert_eq(source.length(), 2)
  }
}

///|
test "panic SkinnedMesh.raycast material index is out of range" {
  let bone = @objects.Bone::new()
  bone.node.update_matrix_world(force=true)
  let arm = @objects.Skeleton::new(bones=[bone])
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0],
        3,
      ),
    ),
  )
  ignore(
    geometry.set_attribute(
      "skinIndex",
      @core.BufferAttribute::new([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], 4),
    ),
  )
  ignore(
    geometry.set_attribute(
      "skinWeight",
      @core.BufferAttribute::new([1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0], 4),
    ),
  )
  geometry.add_group(0, 3, material_index=1)
  let skin = @objects.SkinnedMesh::new(geometry, @materials.Material::basic())
  skin.bind(arm, bind_matrix=@math.Matrix4::new())
  skin.set_materials([@materials.Material::basic()])
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  ignore(skin.raycast(raycaster, []))
}

