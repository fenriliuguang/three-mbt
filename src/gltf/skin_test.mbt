///|
fn skin_node(root : @core.Object3D, name : String) -> @core.Object3D {
  match root.get_object_by_name(name) {
    None => panic()
    Some(node) => node
  }
}

///|
fn pose_skin(root : @core.Object3D) -> Unit {
  root.update_matrix_world(force=true)
  @core.apply_skins(root)
}

///|
fn has_skin(node : @core.Object3D) -> Bool {
  match node.skin {
    None => false
    Some(_) => true
  }
}

///|
fn position_x(node : @core.Object3D) -> Double {
  match node.mesh {
    None => panic()
    Some(binding) =>
      binding.geometry.get_attribute("position").unwrap().get_x(0)
  }
}

///|
fn failed_parse(text : String) -> Bool {
  try {
    ignore(@gltf.parse(text).scene)
    false
  } catch {
    @gltf.GltfError::Invalid(_) => true
  }
}

///|
test "glTF skin follows a joint in mesh space" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0,1]}],"nodes":[{"name":"bone","translation":[1,0,0]},{"name":"mesh","mesh":0,"skin":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0,"NORMAL":1,"JOINTS_0":2,"WEIGHTS_0":3}}]}],"skins":[{"joints":[0],"inverseBindMatrices":4}],"accessors":[{"bufferView":0,"componentType":5126,"count":1,"type":"VEC3"},{"bufferView":1,"componentType":5126,"count":1,"type":"VEC3"},{"bufferView":2,"componentType":5121,"count":1,"type":"VEC4"},{"bufferView":3,"componentType":5126,"count":1,"type":"VEC4"},{"bufferView":4,"componentType":5126,"count":1,"type":"MAT4"}],"bufferViews":[{"buffer":0,"byteLength":12},{"buffer":0,"byteOffset":12,"byteLength":12},{"buffer":0,"byteOffset":24,"byteLength":4},{"buffer":0,"byteOffset":28,"byteLength":16},{"buffer":0,"byteOffset":44,"byteLength":64}],"buffers":[{"byteLength":108,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAIA/AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAAAAAACAPwAAAAAAAIC/AAAAAAAAAAAAAIA/"}]}
  let root = @gltf.parse(text).scene.node
  let mesh = skin_node(root, "mesh")
  let bone = skin_node(root, "bone")
  assert_eq(has_skin(mesh), true)
  pose_skin(root)
  assert_eq(position_x(mesh), 0.0)
  match mesh.mesh {
    None => panic()
    Some(binding) => {
      let normal = binding.geometry.get_attribute("normal").unwrap()
      assert_eq(normal.get_x(0), 0.0)
      assert_eq(normal.get_y(0), 1.0)
      assert_eq(normal.get_z(0), 0.0)
      assert_eq(binding.geometry.version, 1)
    }
  }
  ignore(bone.position.set(3.0, 0.0, 0.0))
  pose_skin(root)
  assert_eq(position_x(mesh), 2.0)
  ignore(bone.quaternion.set(0.0, 0.0, 1.0, 0.0))
  pose_skin(root)
  assert_eq(position_x(mesh), 4.0)
  match mesh.mesh {
    None => panic()
    Some(binding) => {
      let normal = binding.geometry.get_attribute("normal").unwrap()
      assert_eq(normal.get_y(0), -1.0)
      assert_eq(normal.get_x(0), 0.0)
      assert_eq(binding.geometry.version, 3)
    }
  }
}

///|
test "glTF skin brings the vertex back into mesh space" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0,1]}],"nodes":[{"name":"bone"},{"name":"mesh","translation":[0,5,0],"mesh":0,"skin":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0,"JOINTS_0":1,"WEIGHTS_0":2}}]}],"skins":[{"joints":[0],"inverseBindMatrices":3}],"accessors":[{"bufferView":0,"componentType":5126,"count":1,"type":"VEC3"},{"bufferView":1,"componentType":5121,"count":1,"type":"VEC4"},{"bufferView":2,"componentType":5126,"count":1,"type":"VEC4"},{"bufferView":3,"componentType":5126,"count":1,"type":"MAT4"}],"bufferViews":[{"buffer":0,"byteLength":12},{"buffer":0,"byteOffset":12,"byteLength":4},{"buffer":0,"byteOffset":16,"byteLength":16},{"buffer":0,"byteOffset":32,"byteLength":64}],"buffers":[{"byteLength":96,"uri":"data:application/octet-stream;base64,AACAPwAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAIA/AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAAAAAAIA/"}]}
  let root = @gltf.parse(text).scene.node
  pose_skin(root)
  let mesh = skin_node(root, "mesh")
  match mesh.mesh {
    None => panic()
    Some(binding) => {
      let position = binding.geometry.get_attribute("position").unwrap()
      assert_eq(position.get_x(0), 1.0)
      assert_eq(position.get_y(0), -5.0)
      assert_eq(position.get_z(0), 0.0)
    }
  }
}

///|
test "glTF skin clones geometry away from an unskinned user" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0,1,2,3]}],"nodes":[{"name":"bone"},{"name":"still","mesh":0},{"name":"moved","mesh":0,"skin":0},{"name":"also","mesh":0,"skin":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0,"JOINTS_0":1,"WEIGHTS_0":2}}]}],"skins":[{"joints":[0],"inverseBindMatrices":3}],"accessors":[{"bufferView":0,"componentType":5126,"count":1,"type":"VEC3"},{"bufferView":1,"componentType":5121,"count":1,"type":"VEC4"},{"bufferView":2,"componentType":5126,"count":1,"type":"VEC4"},{"bufferView":3,"componentType":5126,"count":1,"type":"MAT4"}],"bufferViews":[{"buffer":0,"byteLength":12},{"buffer":0,"byteOffset":12,"byteLength":4},{"buffer":0,"byteOffset":16,"byteLength":16},{"buffer":0,"byteOffset":32,"byteLength":64}],"buffers":[{"byteLength":96,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAIA/AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAAAAAAIA/"}]}
  let root = @gltf.parse(text).scene.node
  let still = skin_node(root, "still")
  let moved = skin_node(root, "moved")
  let also = skin_node(root, "also")
  assert_eq(has_skin(still), false)
  assert_eq(has_skin(moved), true)
  assert_eq(has_skin(also), true)
  match (still.mesh, moved.mesh, also.mesh) {
    (Some(left), Some(mid), Some(right)) => {
      assert_eq(physical_equal(left.geometry, mid.geometry), false)
      assert_eq(physical_equal(mid.geometry, right.geometry), false)
    }
    _ => panic()
  }
  ignore(skin_node(root, "bone").position.set(2.0, 0.0, 0.0))
  pose_skin(root)
  assert_eq(position_x(still), 0.0)
  assert_eq(position_x(moved), 2.0)
  assert_eq(position_x(also), 2.0)
}

///|
test "glTF skin blends two joints and repairs a zero weight" {
  let blend =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0,1,2]}],"nodes":[{"name":"a"},{"name":"b"},{"name":"blend","mesh":0,"skin":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0,"JOINTS_0":1,"WEIGHTS_0":2}}]}],"skins":[{"joints":[0,1],"inverseBindMatrices":3}],"accessors":[{"bufferView":0,"componentType":5126,"count":1,"type":"VEC3"},{"bufferView":1,"componentType":5121,"count":1,"type":"VEC4"},{"bufferView":2,"componentType":5126,"count":1,"type":"VEC4"},{"bufferView":3,"componentType":5126,"count":2,"type":"MAT4"}],"bufferViews":[{"buffer":0,"byteLength":12},{"buffer":0,"byteOffset":12,"byteLength":4},{"buffer":0,"byteOffset":16,"byteLength":16},{"buffer":0,"byteOffset":32,"byteLength":128}],"buffers":[{"byteLength":160,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAAEAAAAAgD4AAEA/AAAAAAAAAAAAAIA/AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAAAAAAIA/AACAPwAAAAAAAAAAAAAAAAAAAAAAAIA/AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAAAAAACAPw=="}]}
  let root = @gltf.parse(blend).scene.node
  ignore(skin_node(root, "a").position.set(2.0, 0.0, 0.0))
  ignore(skin_node(root, "b").position.set(4.0, 0.0, 0.0))
  pose_skin(root)
  assert_eq(position_x(skin_node(root, "blend")), 3.5)
  let zero =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0,1]}],"nodes":[{"name":"bone"},{"name":"blob","mesh":0,"skin":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0,"JOINTS_0":1,"WEIGHTS_0":2}}]}],"skins":[{"joints":[0],"inverseBindMatrices":3}],"accessors":[{"bufferView":0,"componentType":5126,"count":1,"type":"VEC3"},{"bufferView":1,"componentType":5121,"count":1,"type":"VEC4"},{"bufferView":2,"componentType":5126,"count":1,"type":"VEC4"},{"bufferView":3,"componentType":5126,"count":1,"type":"MAT4"}],"bufferViews":[{"buffer":0,"byteLength":12},{"buffer":0,"byteOffset":12,"byteLength":4},{"buffer":0,"byteOffset":16,"byteLength":16},{"buffer":0,"byteOffset":32,"byteLength":64}],"buffers":[{"byteLength":96,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIA/AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAAAAAAIA/"}]}
  let posed = @gltf.parse(zero).scene.node
  ignore(skin_node(posed, "bone").position.set(2.0, 0.0, 0.0))
  pose_skin(posed)
  assert_eq(position_x(skin_node(posed, "blob")), 2.0)
}

///|
test "glTF skin uses an identity inverse bind and a parent joint" {
  let plain =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0,1]}],"nodes":[{"name":"bone","translation":[1,0,0]},{"name":"mesh","mesh":0,"skin":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0,"JOINTS_0":1,"WEIGHTS_0":2}}]}],"skins":[{"joints":[0]}],"accessors":[{"bufferView":0,"componentType":5126,"count":1,"type":"VEC3"},{"bufferView":1,"componentType":5121,"count":1,"type":"VEC4"},{"bufferView":2,"componentType":5126,"count":1,"type":"VEC4"}],"bufferViews":[{"buffer":0,"byteLength":12},{"buffer":0,"byteOffset":12,"byteLength":4},{"buffer":0,"byteOffset":16,"byteLength":16}],"buffers":[{"byteLength":32,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAA="}]}
  let root = @gltf.parse(plain).scene.node
  pose_skin(root)
  assert_eq(position_x(skin_node(root, "mesh")), 1.0)
  let parented =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0,2]}],"nodes":[{"name":"parent","translation":[1,0,0],"children":[1]},{"name":"bone"},{"name":"mesh","mesh":0,"skin":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0,"JOINTS_0":1,"WEIGHTS_0":2}}]}],"skins":[{"joints":[1],"inverseBindMatrices":3}],"accessors":[{"bufferView":0,"componentType":5126,"count":1,"type":"VEC3"},{"bufferView":1,"componentType":5123,"count":1,"type":"VEC4"},{"bufferView":2,"componentType":5121,"count":1,"type":"VEC4","normalized":true},{"bufferView":3,"componentType":5126,"count":1,"type":"MAT4"}],"bufferViews":[{"buffer":0,"byteLength":12},{"buffer":0,"byteOffset":12,"byteLength":8},{"buffer":0,"byteOffset":20,"byteLength":4},{"buffer":0,"byteOffset":24,"byteLength":64}],"buffers":[{"byteLength":88,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAAAAAAAAAAD/AAAAAACAPwAAAAAAAAAAAAAAAAAAAAAAAIA/AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAACAvwAAAAAAAAAAAACAPw=="}]}
  let posed = @gltf.parse(parented).scene.node
  pose_skin(posed)
  assert_eq(position_x(skin_node(posed, "mesh")), 0.0)
  ignore(skin_node(posed, "parent").position.set(4.0, 0.0, 0.0))
  pose_skin(posed)
  assert_eq(position_x(skin_node(posed, "mesh")), 3.0)
}

///|
test "glTF skin covers each primitive and morphs before the joint" {
  let duo =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0,1]}],"nodes":[{"name":"bone"},{"name":"duo","mesh":0,"skin":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0,"JOINTS_0":1,"WEIGHTS_0":2}},{"attributes":{"POSITION":0,"JOINTS_0":1,"WEIGHTS_0":2}}]}],"skins":[{"joints":[0],"inverseBindMatrices":3}],"accessors":[{"bufferView":0,"componentType":5126,"count":1,"type":"VEC3"},{"bufferView":1,"componentType":5121,"count":1,"type":"VEC4"},{"bufferView":2,"componentType":5126,"count":1,"type":"VEC4"},{"bufferView":3,"componentType":5126,"count":1,"type":"MAT4"}],"bufferViews":[{"buffer":0,"byteLength":12},{"buffer":0,"byteOffset":12,"byteLength":4},{"buffer":0,"byteOffset":16,"byteLength":16},{"buffer":0,"byteOffset":32,"byteLength":64}],"buffers":[{"byteLength":96,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAIA/AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAAAAAAIA/"}]}
  let root = @gltf.parse(duo).scene.node
  let group = skin_node(root, "duo")
  assert_eq(has_skin(group), false)
  assert_eq(group.children.length(), 2)
  ignore(skin_node(root, "bone").position.set(2.0, 0.0, 0.0))
  pose_skin(root)
  assert_eq(has_skin(group.children[0]), true)
  assert_eq(has_skin(group.children[1]), true)
  assert_eq(position_x(group.children[0]), 2.0)
  assert_eq(position_x(group.children[1]), 2.0)
  let morph =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0,1]}],"nodes":[{"name":"bone","translation":[5,0,0]},{"name":"blob","mesh":0,"skin":0}],"meshes":[{"weights":[1],"primitives":[{"attributes":{"POSITION":0,"JOINTS_0":2,"WEIGHTS_0":3},"targets":[{"POSITION":1}]}]}],"skins":[{"joints":[0],"inverseBindMatrices":4}],"accessors":[{"bufferView":0,"componentType":5126,"count":1,"type":"VEC3"},{"bufferView":1,"componentType":5126,"count":1,"type":"VEC3"},{"bufferView":2,"componentType":5121,"count":1,"type":"VEC4"},{"bufferView":3,"componentType":5126,"count":1,"type":"VEC4"},{"bufferView":4,"componentType":5126,"count":1,"type":"MAT4"}],"bufferViews":[{"buffer":0,"byteLength":12},{"buffer":0,"byteOffset":12,"byteLength":12},{"buffer":0,"byteOffset":24,"byteLength":4},{"buffer":0,"byteOffset":28,"byteLength":16},{"buffer":0,"byteOffset":44,"byteLength":64}],"buffers":[{"byteLength":108,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAIA/AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAAAAAAIA/"}]}
  let morphed = @gltf.parse(morph).scene.node
  let blob = skin_node(morphed, "blob")
  assert_eq(has_skin(blob), true)
  pose_skin(morphed)
  match blob.mesh {
    None => panic()
    Some(binding) => {
      let position = binding.geometry.get_attribute("position").unwrap()
      assert_eq(position.get_x(0), 5.0)
      assert_eq(position.get_y(0), 1.0)
      assert_eq(position.get_z(0), 0.0)
    }
  }
  match blob.morph {
    None => panic()
    Some(state) => state.weights[0] = 0.0
  }
  pose_skin(morphed)
  pose_skin(morphed)
  match blob.mesh {
    None => panic()
    Some(binding) => {
      let position = binding.geometry.get_attribute("position").unwrap()
      assert_eq(position.get_x(0), 5.0)
      assert_eq(position.get_y(0), 0.0)
    }
  }
  let partial =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0,1]}],"nodes":[{"name":"bone","translation":[4,0,0]},{"name":"rigid","mesh":0,"skin":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0,"JOINTS_1":1,"WEIGHTS_0":2}}]}],"skins":[{"joints":[0]}],"accessors":[{"bufferView":0,"componentType":5126,"count":1,"type":"VEC3"},{"bufferView":1,"componentType":5121,"count":1,"type":"VEC4"},{"bufferView":2,"componentType":5126,"count":1,"type":"VEC4"}],"bufferViews":[{"buffer":0,"byteLength":12},{"buffer":0,"byteOffset":12,"byteLength":4},{"buffer":0,"byteOffset":16,"byteLength":16}],"buffers":[{"byteLength":32,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAA="}]}
  let rigid = @gltf.parse(partial).scene.node
  pose_skin(rigid)
  let stayed = skin_node(rigid, "rigid")
  assert_eq(has_skin(stayed), false)
  assert_eq(position_x(stayed), 0.0)
}

///|
test "glTF rejects a bad skin, a bad joint, and bad skin accessors" {
  let bad_skin =
    #|{"asset":{"version":"2.0"},"nodes":[{"skin":1}],"skins":[{"joints":[0]}]}
  let short_bind =
    #|{"asset":{"version":"2.0"},"nodes":[{},{}],"skins":[{"joints":[0,1],"inverseBindMatrices":0}],"accessors":[{"bufferView":0,"componentType":5126,"count":1,"type":"MAT4"}],"bufferViews":[{"buffer":0,"byteLength":64}],"buffers":[{"byteLength":64,"uri":"data:application/octet-stream;base64,AACAPwAAAAAAAAAAAAAAAAAAAAAAAIA/AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAAAAAACAPw=="}]}
  let bad_joint =
    #|{"asset":{"version":"2.0"},"nodes":[{}],"skins":[{"joints":[5]}]}
  let float_joints =
    #|{"asset":{"version":"2.0"},"nodes":[{"mesh":0,"skin":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0,"JOINTS_0":1,"WEIGHTS_0":2}}]}],"skins":[{"joints":[0]}],"accessors":[{"bufferView":0,"componentType":5126,"count":1,"type":"VEC3"},{"bufferView":1,"componentType":5126,"count":1,"type":"VEC4"},{"bufferView":2,"componentType":5126,"count":1,"type":"VEC4"}],"bufferViews":[{"buffer":0,"byteLength":12},{"buffer":0,"byteOffset":12,"byteLength":16},{"buffer":0,"byteOffset":28,"byteLength":16}],"buffers":[{"byteLength":44,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="}]}
  let raw_weights =
    #|{"asset":{"version":"2.0"},"nodes":[{"mesh":0,"skin":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0,"JOINTS_0":1,"WEIGHTS_0":2}}]}],"skins":[{"joints":[0]}],"accessors":[{"bufferView":0,"componentType":5126,"count":1,"type":"VEC3"},{"bufferView":1,"componentType":5121,"count":1,"type":"VEC4"},{"bufferView":2,"componentType":5121,"count":1,"type":"VEC4"}],"bufferViews":[{"buffer":0,"byteLength":12},{"buffer":0,"byteOffset":12,"byteLength":4},{"buffer":0,"byteOffset":16,"byteLength":4}],"buffers":[{"byteLength":20,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAAAAAP8AAAA="}]}
  assert_eq(failed_parse(bad_skin), true)
  assert_eq(failed_parse(short_bind), true)
  assert_eq(failed_parse(bad_joint), true)
  assert_eq(failed_parse(float_joints), true)
  assert_eq(failed_parse(raw_weights), true)
}

///|
test "glTF JOINTS_1 adds four influences and normalizes with the first set" {
  let blend =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0,1,2]}],"nodes":[{"name":"a"},{"name":"b"},{"name":"mesh","mesh":0,"skin":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0,"JOINTS_0":1,"WEIGHTS_0":2,"JOINTS_1":3,"WEIGHTS_1":4}}]}],"skins":[{"joints":[0,1],"inverseBindMatrices":5}],"accessors":[{"bufferView":0,"componentType":5126,"count":1,"type":"VEC3"},{"bufferView":1,"componentType":5121,"count":1,"type":"VEC4"},{"bufferView":2,"componentType":5126,"count":1,"type":"VEC4"},{"bufferView":3,"componentType":5121,"count":1,"type":"VEC4"},{"bufferView":4,"componentType":5126,"count":1,"type":"VEC4"},{"bufferView":5,"componentType":5126,"count":2,"type":"MAT4"}],"bufferViews":[{"buffer":0,"byteLength":12},{"buffer":0,"byteOffset":12,"byteLength":4},{"buffer":0,"byteOffset":16,"byteLength":16},{"buffer":0,"byteOffset":32,"byteLength":4},{"buffer":0,"byteOffset":36,"byteLength":16},{"buffer":0,"byteOffset":52,"byteLength":128}],"buffers":[{"byteLength":180,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAAAAAAAAgD4AAAAAAAAAAAAAAAABAAAAAABAPwAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAAAAAAIA/AAAAAAAAAAAAAAAAAAAAAAAAgD8AAIA/AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAAAAAAIA/"}]}
  let root = @gltf.parse(blend).scene.node
  ignore(skin_node(root, "a").position.set(4.0, 0.0, 0.0))
  pose_skin(root)
  assert_eq(position_x(skin_node(root, "mesh")), 1.0)
  let scaled =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0,1,2]}],"nodes":[{"name":"a"},{"name":"b"},{"name":"mesh","mesh":0,"skin":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0,"JOINTS_0":1,"WEIGHTS_0":2,"JOINTS_1":3,"WEIGHTS_1":4}}]}],"skins":[{"joints":[0,1],"inverseBindMatrices":5}],"accessors":[{"bufferView":0,"componentType":5126,"count":1,"type":"VEC3"},{"bufferView":1,"componentType":5121,"count":1,"type":"VEC4"},{"bufferView":2,"componentType":5126,"count":1,"type":"VEC4"},{"bufferView":3,"componentType":5121,"count":1,"type":"VEC4"},{"bufferView":4,"componentType":5126,"count":1,"type":"VEC4"},{"bufferView":5,"componentType":5126,"count":2,"type":"MAT4"}],"bufferViews":[{"buffer":0,"byteLength":12},{"buffer":0,"byteOffset":12,"byteLength":4},{"buffer":0,"byteOffset":16,"byteLength":16},{"buffer":0,"byteOffset":32,"byteLength":4},{"buffer":0,"byteOffset":36,"byteLength":16},{"buffer":0,"byteOffset":52,"byteLength":128}],"buffers":[{"byteLength":180,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAABAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAAAAAAIA/AAAAAAAAAAAAAAAAAAAAAAAAgD8AAIA/AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAAAAAAIA/"}]}
  let posed = @gltf.parse(scaled).scene.node
  ignore(skin_node(posed, "a").position.set(2.0, 0.0, 0.0))
  ignore(skin_node(posed, "b").position.set(6.0, 0.0, 0.0))
  pose_skin(posed)
  assert_eq(position_x(skin_node(posed, "mesh")), 4.0)
  let lone =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0,1]}],"nodes":[{"name":"bone"},{"name":"mesh","mesh":0,"skin":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0,"JOINTS_0":1,"WEIGHTS_0":2,"JOINTS_1":3}}]}],"skins":[{"joints":[0],"inverseBindMatrices":4}],"accessors":[{"bufferView":0,"componentType":5126,"count":1,"type":"VEC3"},{"bufferView":1,"componentType":5121,"count":1,"type":"VEC4"},{"bufferView":2,"componentType":5126,"count":1,"type":"VEC4"},{"bufferView":3,"componentType":5121,"count":1,"type":"VEC4"},{"bufferView":4,"componentType":5126,"count":1,"type":"MAT4"}],"bufferViews":[{"buffer":0,"byteLength":12},{"buffer":0,"byteOffset":12,"byteLength":4},{"buffer":0,"byteOffset":16,"byteLength":16},{"buffer":0,"byteOffset":32,"byteLength":4},{"buffer":0,"byteOffset":36,"byteLength":64}],"buffers":[{"byteLength":100,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAABAAAAAACAPwAAAAAAAAAAAAAAAAAAAAAAAIA/AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAAAAAACAPw=="}]}
  let single = @gltf.parse(lone).scene.node
  ignore(skin_node(single, "bone").position.set(2.0, 0.0, 0.0))
  pose_skin(single)
  assert_eq(position_x(skin_node(single, "mesh")), 2.0)
}
