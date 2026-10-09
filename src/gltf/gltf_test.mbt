///|
fn triangle_gltf() -> String {
  let text =
    #|{"asset":{"version":"2.0"},"scene":1,"scenes":[{"nodes":[]},{"name":"main","nodes":[0]}],"nodes":[{"name":"arm","translation":[1,0,0],"children":[1]},{"name":"tri","translation":[0.5,0,0],"rotation":[0,1,0,0],"scale":[2,2,2],"mesh":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0,"NORMAL":1,"TEXCOORD_0":2},"indices":3,"mode":4,"material":0}]}],"materials":[{"doubleSided":true,"pbrMetallicRoughness":{"baseColorFactor":[0.5,0.25,0,1],"metallicFactor":0.5,"roughnessFactor":0.25}}],"accessors":[{"bufferView":0,"componentType":5126,"count":3,"type":"VEC3"},{"bufferView":1,"componentType":5126,"count":3,"type":"VEC3"},{"bufferView":2,"componentType":5126,"count":3,"type":"VEC2"},{"bufferView":3,"componentType":5123,"count":3,"type":"SCALAR"}],"bufferViews":[{"buffer":0,"byteOffset":4,"byteLength":36},{"buffer":0,"byteOffset":40,"byteLength":36},{"buffer":0,"byteOffset":76,"byteLength":24},{"buffer":0,"byteOffset":100,"byteLength":6}],"buffers":[{"byteLength":106,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAIA/AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAACAPwAAAAAAAAAAAACAPwAAAAAAAAAAAACAPwAAAAAAAAAAAACAPwAAAQACAA=="}]}
  text
}

///|
fn must(root : @core.Object3D, name : String) -> @core.Object3D {
  match root.get_object_by_name(name) {
    None => panic()
    Some(node) => node
  }
}

///|
test "parse reads a triangle, a linear color, and the node hierarchy" {
  let group = @gltf.parse(triangle_gltf())
  assert_eq(group.node.name, "main")
  assert_eq(must(group.node, "arm").position.x, 1.0)
  let tri = must(group.node, "tri")
  assert_eq(tri.position.x, 0.5)
  assert_eq(tri.quaternion.y, 1.0)
  assert_eq(tri.quaternion.w, 0.0)
  assert_eq(tri.scale.x, 2.0)
  match tri.mesh {
    None => panic()
    Some(binding) => {
      assert_eq(binding.shading is @constants.Shading::Standard, true)
      assert_eq(binding.side is @constants.Side::Double, true)
      assert_eq(binding.color.r, 0.5)
      assert_eq(binding.color.g, 0.25)
      assert_eq(binding.color.b, 0.0)
      assert_eq(binding.roughness, 0.25)
      assert_eq(binding.metalness, 0.5)
      assert_eq(binding.transparent, false)
      let position = binding.geometry.get_attribute("position").unwrap()
      assert_eq(position.count, 3)
      assert_eq(position.get_x(1), 1.0)
      assert_eq(position.get_y(2), 1.0)
      let normal = binding.geometry.get_attribute("normal").unwrap()
      assert_eq(normal.get_z(0), 1.0)
      let uv = binding.geometry.get_attribute("uv").unwrap()
      assert_eq(uv.get_x(1), 1.0)
      assert_eq(uv.get_y(2), 1.0)
      match binding.geometry.index {
        None => panic()
        Some(index) => {
          assert_eq(index.count, 3)
          assert_eq(index.get_x(2), 2.0)
        }
      }
    }
  }
}

///|
test "a node matrix replaces translation rotation and scale" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0]}],"nodes":[{"name":"moved","translation":[9,9,9],"matrix":[1,0,0,0,0,1,0,0,0,0,1,0,4,0,0,1]}]}
  let group = @gltf.parse(text)
  let moved = must(group.node, "moved")
  assert_eq(moved.position.x, 4.0)
  assert_eq(moved.position.y, 0.0)
  assert_eq(moved.position.z, 0.0)
  assert_eq(moved.quaternion.w, 1.0)
  assert_eq(moved.scale.x, 1.0)
}

///|
test "buffer 0 can be supplied when the uri is missing" {
  let bin = @base64.decode(
    "AAAAAAAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAIA/AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAACAPwAAAAAAAAAAAACAPwAAAAAAAAAAAACAPwAAAAAAAAAAAACAPwAAAQACAA==",
  )
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0]}],"nodes":[{"name":"tri","mesh":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0}}]}],"accessors":[{"bufferView":0,"componentType":5126,"count":3,"type":"VEC3"}],"bufferViews":[{"buffer":0,"byteOffset":4,"byteLength":36}],"buffers":[{"byteLength":106}]}
  let group = @gltf.parse(text, bin~)
  match must(group.node, "tri").mesh {
    None => panic()
    Some(binding) =>
      assert_eq(
        binding.geometry.get_attribute("position").unwrap().get_x(1),
        1.0,
      )
  }
}

///|
test "glTF 1.0 is rejected" {
  let text =
    #|{"asset":{"version":"1.0"}}
  let failed = try {
    ignore(@gltf.parse(text))
    false
  } catch {
    @gltf.GltfError::Invalid(_) => true
  }
  assert_eq(failed, true)
}

///|
test "two primitives become children of the node" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0]}],"nodes":[{"name":"multi","mesh":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0}},{"attributes":{"POSITION":0}}]}],"accessors":[{"bufferView":0,"componentType":5126,"count":3,"type":"VEC3"}],"bufferViews":[{"buffer":0,"byteLength":36}],"buffers":[{"byteLength":36,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAA"}]}
  let node = must(@gltf.parse(text).node, "multi")
  assert_eq(node.kind is @core.NodeKind::Group, true)
  assert_eq(node.children.length(), 2)
  match node.children[0].mesh {
    None => panic()
    Some(binding) =>
      assert_eq(binding.geometry.get_attribute("position").unwrap().count, 3)
  }
  match node.children[1].mesh {
    None => panic()
    Some(_) => ()
  }
}
