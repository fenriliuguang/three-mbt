///|
test "Skeleton inverts the current world matrices" {
  let shoulder = @objects.Bone::new()
  let elbow = @objects.Bone::new()
  let hand = @objects.Bone::new()
  ignore(shoulder.add(elbow))
  ignore(elbow.add(hand))
  ignore(shoulder.node.position.set(0.0, -5.0, 0.0))
  ignore(elbow.node.position.set(0.0, 0.0, 0.0))
  ignore(hand.node.position.set(0.0, 5.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  let listed = [shoulder, elbow, hand]
  let inverses = []
  let arm = @objects.Skeleton::new(bones=listed, bone_inverses=inverses)
  listed.push(@objects.Bone::new())
  assert_eq(arm.bones.length(), 3)
  assert_eq(physical_equal(arm.bones[0], shoulder), true)
  assert_eq(physical_equal(arm.bones[2], hand), true)
  assert_eq(arm.bones[0].node.position.y, -5.0)
  assert_eq(arm.bones[1].node.position.y, 0.0)
  assert_eq(arm.bones[2].node.position.y, 5.0)
  assert_eq(physical_equal(arm.bone_inverses, inverses), true)
  assert_eq(inverses.length(), 3)
  assert_eq(inverses[0].elements[13], 5.0)
  assert_eq(inverses[1].elements[13], 5.0)
  assert_eq(inverses[2].elements[0], 1.0)
  assert_eq(inverses[2].elements[13], 0.0)
  assert_eq(arm.bone_matrices.length(), 48)
  assert_eq(arm.bone_matrices[0], 0.0)
  assert_eq(arm.bone_matrices[47], 0.0)
  assert_eq(arm.uuid.length(), 36)
  let empty = @objects.Skeleton::new()
  assert_eq(empty.bones.length(), 0)
  assert_eq(empty.bone_inverses.length(), 0)
  assert_eq(empty.bone_matrices.length(), 0)
  assert_eq(empty.uuid.length(), 36)
  arm.bone_matrices[0] = 4.0
  arm.init()
  assert_eq(arm.bone_matrices[0], 0.0)
  assert_eq(arm.bone_matrices.length(), 48)
  assert_eq(arm.bone_inverses[0].elements[13], 5.0)
  ignore(shoulder.node.position.set(0.0, -2.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  arm.calculate_inverses()
  assert_eq(arm.bone_inverses[0].elements[13], 2.0)
  assert_eq(arm.bone_inverses[1].elements[13], 2.0)
  assert_eq(arm.bone_inverses[2].elements[13], -3.0)
}

///|
test "Skeleton.init replaces a mismatched inverse list" {
  let shoulder = @objects.Bone::new()
  let elbow = @objects.Bone::new()
  let hand = @objects.Bone::new()
  let one = @math.Matrix4::new()
  ignore(
    one.set(
      1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 9.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0,
    ),
  )
  let mismatched = [one]
  let replaced = @objects.Skeleton::new(
    bones=[shoulder, elbow, hand],
    bone_inverses=mismatched,
  )
  assert_eq(physical_equal(replaced.bone_inverses, mismatched), false)
  assert_eq(replaced.bone_inverses.length(), 3)
  assert_eq(replaced.bone_inverses[0].elements[0], 1.0)
  assert_eq(replaced.bone_inverses[0].elements[13], 0.0)
  assert_eq(replaced.bone_inverses[2].elements[13], 0.0)
  assert_eq(mismatched.length(), 1)
  assert_eq(mismatched[0].elements[13], 9.0)
  assert_eq(replaced.bone_matrices.length(), 48)
}

///|
test "Skeleton.pose restores the bind positions" {
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
  ignore(shoulder.node.position.set(0.0, -2.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  assert_eq(shoulder.node.position.y, -2.0)
  arm.pose()
  assert_eq(shoulder.node.position.y, -5.0)
  assert_eq(elbow.node.position.y, 0.0)
  assert_eq(hand.node.position.y, 5.0)
  assert_eq(shoulder.node.matrix_world.elements[13], -5.0)
  assert_eq(elbow.node.matrix_world.elements[13], -5.0)
  assert_eq(hand.node.matrix_world.elements[13], 0.0)
  assert_eq(shoulder.node.quaternion.w, 1.0)
  assert_eq(shoulder.node.quaternion.x, 0.0)
  assert_eq(elbow.node.scale.y, 1.0)
  assert_eq(hand.node.scale.y, 1.0)
  assert_eq(arm.bone_inverses[0].elements[13], 5.0)
  let group = @objects.Group::new()
  ignore(group.node.position.set(0.0, 10.0, 0.0))
  let lone = @objects.Bone::new()
  ignore(lone.node.position.set(0.0, 5.0, 0.0))
  ignore(group.add(lone))
  group.node.update_matrix_world(force=true)
  let flat = @objects.Skeleton::new(bones=[lone])
  flat.pose()
  assert_eq(lone.node.position.y, 15.0)
  @objects.Skeleton::new().pose()
}

///|
test "Skeleton.update writes bind matrices into the buffer" {
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
  arm.update()
  assert_eq(arm.bone_matrices.length(), 48)
  assert_eq(arm.bone_matrices[0], 1.0)
  assert_eq(arm.bone_matrices[13], 0.0)
  assert_eq(arm.bone_matrices[15], 1.0)
  assert_eq(arm.bone_matrices[16], 1.0)
  assert_eq(arm.bone_matrices[29], 0.0)
  assert_eq(arm.bone_matrices[32], 1.0)
  assert_eq(arm.bone_matrices[45], 0.0)
  assert_eq(arm.bone_matrices[47], 1.0)
  ignore(shoulder.node.position.set(0.0, -2.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  arm.update()
  assert_eq(arm.bone_matrices[0], 1.0)
  assert_eq(arm.bone_matrices[13], 3.0)
  assert_eq(arm.bone_matrices[29], 3.0)
  assert_eq(arm.bone_matrices[45], 3.0)
  assert_eq(arm.bone_matrices[47], 1.0)
  assert_eq(shoulder.node.position.y, -2.0)
  let empty = @objects.Skeleton::new()
  empty.update()
  assert_eq(empty.bone_matrices.length(), 0)
}

///|
test "Skeleton.clone shares inverses and clears the matrix buffer" {
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
  ignore(shoulder.node.position.set(0.0, -2.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  arm.update()
  assert_eq(arm.bone_matrices[13], 3.0)
  let cloned = arm.clone()
  assert_eq(physical_equal(cloned, arm), false)
  assert_eq(cloned.bones.length(), 3)
  assert_eq(physical_equal(cloned.bones[0], shoulder), true)
  assert_eq(physical_equal(cloned.bones[2], hand), true)
  cloned.bones.push(@objects.Bone::new())
  assert_eq(cloned.bones.length(), 4)
  assert_eq(arm.bones.length(), 3)
  assert_eq(physical_equal(cloned.bone_inverses, arm.bone_inverses), true)
  assert_eq(cloned.bone_inverses[0].elements[13], 5.0)
  ignore(
    cloned.bone_inverses[0].set(
      1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 7.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0,
    ),
  )
  assert_eq(arm.bone_inverses[0].elements[13], 7.0)
  assert_eq(cloned.bone_matrices.length(), 48)
  assert_eq(cloned.bone_matrices[13], 0.0)
  assert_eq(arm.bone_matrices[13], 3.0)
  let empty = @objects.Skeleton::new()
  let copied = empty.clone()
  assert_eq(copied.bones.length(), 0)
  assert_eq(copied.bone_matrices.length(), 0)
  assert_eq(physical_equal(copied.bone_inverses, empty.bone_inverses), true)
}

///|
test "Skeleton.getBoneByName returns the first match" {
  let shoulder = @objects.Bone::new()
  let elbow = @objects.Bone::new()
  let hand = @objects.Bone::new()
  shoulder.node.name = "shoulder"
  elbow.node.name = "elbow"
  ignore(shoulder.node.position.set(0.0, -5.0, 0.0))
  ignore(elbow.node.position.set(0.0, 0.0, 0.0))
  ignore(hand.node.position.set(0.0, 5.0, 0.0))
  let arm = @objects.Skeleton::new(bones=[shoulder, elbow, hand])
  match arm.get_bone_by_name("elbow") {
    None => assert_eq(false, true)
    Some(bone) => {
      assert_eq(physical_equal(bone, elbow), true)
      assert_eq(bone.node.position.y, 0.0)
    }
  }
  match arm.get_bone_by_name("shoulder") {
    None => assert_eq(false, true)
    Some(bone) => assert_eq(bone.node.position.y, -5.0)
  }
  match arm.get_bone_by_name("") {
    None => assert_eq(false, true)
    Some(bone) => {
      assert_eq(physical_equal(bone, hand), true)
      assert_eq(bone.node.position.y, 5.0)
    }
  }
  hand.node.name = "elbow"
  match arm.get_bone_by_name("elbow") {
    None => assert_eq(false, true)
    Some(bone) => assert_eq(physical_equal(bone, elbow), true)
  }
  assert_eq(arm.get_bone_by_name("wrist") is None, true)
  assert_eq(@objects.Skeleton::new().get_bone_by_name("elbow") is None, true)
}

///|
test "Skeleton.computeBoneTexture grows the matrix buffer" {
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
  ignore(shoulder.node.position.set(0.0, -2.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  arm.update()
  assert_eq(arm.bone_matrices.length(), 48)
  assert_eq(arm.bone_matrices[13], 3.0)
  let computed = arm.compute_bone_texture()
  assert_eq(physical_equal(computed, arm), true)
  assert_eq(arm.bone_matrices.length(), 64)
  assert_eq(arm.bone_matrices[13], 3.0)
  assert_eq(arm.bone_matrices[48], 0.0)
  assert_eq(arm.bone_matrices[63], 0.0)
  match arm.bone_texture {
    None => assert_eq(false, true)
    Some(texture) => {
      assert_eq(texture.width, 4)
      assert_eq(texture.height, 4)
      assert_eq(texture.data.length(), 64)
      assert_eq(texture.data[13], 3.0)
      assert_eq(texture.data[63], 0.0)
      assert_eq(texture.needs_update, true)
      assert_eq(texture.flip_y, false)
      assert_eq(texture.generate_mipmaps, false)
      assert_eq(texture.unpack_alignment, 1)
      assert_eq(texture.mag_filter is @constants.Nearest, true)
      assert_eq(texture.min_filter is @constants.Nearest, true)
      arm.bone_matrices[13] = 9.0
      assert_eq(texture.data[13], 9.0)
      arm.bone_matrices[13] = 3.0
      texture.needs_update = false
    }
  }
  arm.update()
  match arm.bone_texture {
    None => assert_eq(false, true)
    Some(texture) => {
      assert_eq(texture.needs_update, true)
      assert_eq(texture.data[13], 3.0)
    }
  }
  let cloned = arm.clone()
  assert_eq(cloned.bone_texture is None, true)
  ignore(arm.compute_bone_texture())
  assert_eq(arm.bone_matrices.length(), 64)
  assert_eq(arm.bone_matrices[13], 3.0)
  match arm.bone_texture {
    None => assert_eq(false, true)
    Some(texture) => {
      assert_eq(texture.needs_update, true)
      arm.bone_matrices[13] = 9.0
      assert_eq(texture.data[13], 9.0)
      arm.bone_matrices[13] = 3.0
    }
  }
  let empty = @objects.Skeleton::new()
  ignore(empty.compute_bone_texture())
  assert_eq(empty.bone_matrices.length(), 64)
  assert_eq(empty.bone_matrices[0], 0.0)
  assert_eq(empty.bone_matrices[63], 0.0)
  match empty.bone_texture {
    None => assert_eq(false, true)
    Some(texture) => {
      assert_eq(texture.width, 4)
      assert_eq(texture.height, 4)
      assert_eq(texture.data[0], 0.0)
      assert_eq(texture.data[63], 0.0)
    }
  }
  let bones = []
  let mut index = 0
  while index < 17 {
    bones.push(@objects.Bone::new())
    index = index + 1
  }
  let wide = @objects.Skeleton::new(bones=bones)
  assert_eq(wide.bone_matrices.length(), 272)
  wide.bone_matrices[0] = 4.0
  ignore(wide.compute_bone_texture())
  assert_eq(wide.bone_matrices.length(), 576)
  assert_eq(wide.bone_matrices[0], 4.0)
  assert_eq(wide.bone_matrices[271], 0.0)
  assert_eq(wide.bone_matrices[272], 0.0)
  assert_eq(wide.bone_matrices[575], 0.0)
  match wide.bone_texture {
    None => assert_eq(false, true)
    Some(texture) => {
      assert_eq(texture.width, 12)
      assert_eq(texture.height, 12)
      assert_eq(texture.data.length(), 576)
      assert_eq(texture.data[0], 4.0)
    }
  }
}

///|
test "Skeleton.dispose leaves the matrix buffer in place" {
  let shoulder = @objects.Bone::new()
  let elbow = @objects.Bone::new()
  let hand = @objects.Bone::new()
  ignore(shoulder.node.position.set(0.0, -5.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  let arm = @objects.Skeleton::new(bones=[shoulder, elbow, hand])
  ignore(shoulder.node.position.set(0.0, -2.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  arm.update()
  ignore(arm.compute_bone_texture())
  assert_eq(arm.bone_matrices.length(), 64)
  assert_eq(arm.bone_matrices[13], 3.0)
  match arm.bone_texture {
    None => assert_eq(false, true)
    Some(texture) => assert_eq(texture.data[13], 3.0)
  }
  arm.dispose()
  assert_eq(arm.bone_texture is None, true)
  assert_eq(arm.bone_matrices.length(), 64)
  assert_eq(arm.bone_matrices[13], 3.0)
  assert_eq(arm.bone_matrices[63], 0.0)
  assert_eq(arm.bones.length(), 3)
  assert_eq(shoulder.node.position.y, -2.0)
  let empty = @objects.Skeleton::new()
  empty.dispose()
  assert_eq(empty.bone_matrices.length(), 0)
  assert_eq(empty.bones.length(), 0)
}

///|
test "Skeleton.toJSON writes bone uuids and inverse matrices" {
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
  let data = arm.to_json()
  assert_eq(data.version, 4.7)
  assert_eq(data.type_name, "Skeleton")
  assert_eq(data.generator, "Skeleton.toJSON")
  assert_eq(data.uuid, arm.uuid)
  assert_eq(data.bones.length(), 3)
  assert_eq(data.bones[0], shoulder.node.uuid)
  assert_eq(data.bones[1], elbow.node.uuid)
  assert_eq(data.bones[2], hand.node.uuid)
  assert_eq(data.bone_inverses.length(), 3)
  assert_eq(data.bone_inverses[0].length(), 16)
  assert_eq(data.bone_inverses[0][0], 1.0)
  assert_eq(data.bone_inverses[0][13], 5.0)
  assert_eq(data.bone_inverses[1][13], 5.0)
  assert_eq(data.bone_inverses[2][0], 1.0)
  assert_eq(data.bone_inverses[2][13], 0.0)
  assert_eq(data.bone_inverses[2][15], 1.0)
  data.bone_inverses[0][13] = 9.0
  assert_eq(arm.bone_inverses[0].elements[13], 5.0)
  let empty = @objects.Skeleton::new().to_json()
  assert_eq(empty.bones.length(), 0)
  assert_eq(empty.bone_inverses.length(), 0)
  assert_eq(empty.version, 4.7)
}

///|
test "Skeleton.fromJSON appends bones and keeps their inverses" {
  let shoulder = @objects.Bone::new()
  let elbow = @objects.Bone::new()
  let hand = @objects.Bone::new()
  shoulder.node.uuid = "shoulder"
  elbow.node.uuid = "elbow"
  hand.node.uuid = "hand"
  ignore(shoulder.add(elbow))
  ignore(elbow.add(hand))
  ignore(shoulder.node.position.set(0.0, -5.0, 0.0))
  ignore(elbow.node.position.set(0.0, 0.0, 0.0))
  ignore(hand.node.position.set(0.0, 5.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  let arm = @objects.Skeleton::new(bones=[shoulder, elbow, hand])
  let data = arm.to_json()
  let listed : Map[String, @objects.Bone] = Map([])
  listed.set(shoulder.node.uuid, shoulder)
  listed.set(elbow.node.uuid, elbow)
  listed.set(hand.node.uuid, hand)
  let restored = @objects.Skeleton::new()
  let loaded = restored.from_json(data, listed)
  assert_eq(physical_equal(loaded, restored), true)
  assert_eq(restored.uuid, arm.uuid)
  assert_eq(restored.bones.length(), 3)
  assert_eq(physical_equal(restored.bones[0].node, shoulder.node), true)
  assert_eq(restored.bones[0].node.uuid, shoulder.node.uuid)
  assert_eq(physical_equal(restored.bones[2].node, hand.node), true)
  assert_eq(restored.bone_inverses[0].elements[13], 5.0)
  assert_eq(restored.bone_inverses[1].elements[13], 5.0)
  assert_eq(restored.bone_inverses[2].elements[13], 0.0)
  assert_eq(restored.bone_matrices.length(), 48)
  assert_eq(restored.bone_matrices[0], 0.0)
  ignore(restored.from_json(data, listed))
  assert_eq(restored.bones.length(), 6)
  assert_eq(physical_equal(restored.bones[3].node, shoulder.node), true)
  assert_eq(restored.bone_matrices.length(), 96)
  assert_eq(restored.bone_matrices[0], 0.0)
  let gap : @objects.SkeletonJson = {
    version: 4.7,
    type_name: "Skeleton",
    generator: "Skeleton.toJSON",
    uuid: "skeleton-id",
    bones: ["missing"],
    bone_inverses: [@math.Matrix4::new().to_array()],
  }
  let fresh = @objects.Skeleton::new()
  let known : Map[String, @objects.Bone] = Map([])
  ignore(fresh.from_json(gap, known))
  assert_eq(fresh.uuid, "skeleton-id")
  assert_eq(fresh.bones.length(), 1)
  assert_eq(physical_equal(fresh.bones[0], shoulder), false)
  assert_eq(fresh.bones[0].node.kind is @core.NodeKind::Bone, true)
  assert_eq(fresh.bone_inverses[0].elements[0], 1.0)
  assert_eq(fresh.bone_inverses[0].elements[13], 0.0)
  assert_eq(fresh.bone_matrices.length(), 16)
}

///|
test "panic Skeleton.computeBoneTexture aborts when the buffer does not fit" {
  let arm = @objects.Skeleton::new(bones=[@objects.Bone::new()])
  let big = []
  let mut index = 0
  while index < 65 {
    big.push(1.0)
    index = index + 1
  }
  arm.bone_matrices = big
  ignore(arm.compute_bone_texture())
}

