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

///|
test "glTF cameras become perspective and orthographic nodes" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0,1]}],"nodes":[{"name":"eye","translation":[1,2,3],"camera":0},{"camera":1}],"cameras":[{"name":"unused","type":"perspective","perspective":{"yfov":0.5,"aspectRatio":2,"znear":0.25,"zfar":40}},{"name":"flat","type":"orthographic","orthographic":{"xmag":2,"ymag":3,"znear":0.5,"zfar":50}}]}
  let group = @gltf.parse(text)
  let eye = must(group.node, "eye")
  assert_eq(eye.kind is @core.NodeKind::PerspectiveCamera, true)
  assert_eq(eye.position.x, 1.0)
  assert_eq(eye.position.y, 2.0)
  assert_eq(eye.position.z, 3.0)
  match eye.camera {
    None => panic()
    Some(state) => {
      assert_eq(state.kind is @core.ProjectionKind::Perspective, true)
      assert_eq(state.fov, @math.rad_to_deg(0.5))
      assert_eq(state.aspect, 2.0)
      assert_eq(state.near, 0.25)
      assert_eq(state.far, 40.0)
    }
  }
  let flat = must(group.node, "flat")
  assert_eq(flat.kind is @core.NodeKind::OrthographicCamera, true)
  match flat.camera {
    None => panic()
    Some(state) => {
      assert_eq(state.kind is @core.ProjectionKind::Orthographic, true)
      assert_eq(state.left, -2.0)
      assert_eq(state.right, 2.0)
      assert_eq(state.top, 3.0)
      assert_eq(state.bottom, -3.0)
      assert_eq(state.near, 0.5)
      assert_eq(state.far, 50.0)
    }
  }
  let wide_text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0]}],"nodes":[{"name":"wide","camera":0}],"cameras":[{"type":"perspective","perspective":{"yfov":0.5,"aspectRatio":0,"znear":0,"zfar":0}}]}
  let wide = @gltf.parse(wide_text)
  match must(wide.node, "wide").camera {
    None => panic()
    Some(state) => {
      assert_eq(state.aspect, 1.0)
      assert_eq(state.near, 1.0)
      assert_eq(state.far, 2000000.0)
    }
  }
}

///|
test "a mesh and a camera share a group, and a camera index can repeat" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0,1,2]}],"nodes":[{"name":"both","mesh":0,"camera":0},{"name":"left","translation":[1,0,0],"camera":0},{"name":"right","translation":[0,2,0],"camera":0}],"cameras":[{"name":"eye","type":"perspective","perspective":{"yfov":0.5,"znear":1}}],"meshes":[{"primitives":[{"attributes":{"POSITION":0}}]}],"accessors":[{"bufferView":0,"componentType":5126,"count":3,"type":"VEC3"}],"bufferViews":[{"buffer":0,"byteLength":36}],"buffers":[{"byteLength":36,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAA"}]}
  let group = @gltf.parse(text)
  let both = must(group.node, "both")
  assert_eq(both.kind is @core.NodeKind::Group, true)
  assert_eq(both.children.length(), 2)
  match both.children[0].mesh {
    None => panic()
    Some(binding) =>
      assert_eq(binding.geometry.get_attribute("position").unwrap().count, 3)
  }
  let child = both.children[1]
  assert_eq(child.name, "eye")
  assert_eq(child.kind is @core.NodeKind::PerspectiveCamera, true)
  let left = must(group.node, "left")
  let right = must(group.node, "right")
  assert_eq(physical_equal(left, right), false)
  assert_eq(left.position.x, 1.0)
  assert_eq(right.position.y, 2.0)
  match left.camera {
    None => panic()
    Some(state) => assert_eq(state.fov, @math.rad_to_deg(0.5))
  }
}

///|
test "an unknown glTF camera type is rejected" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0]}],"nodes":[{"camera":0}],"cameras":[{"type":"fisheye"}]}
  let failed = try {
    ignore(@gltf.parse(text))
    false
  } catch {
    @gltf.GltfError::Invalid(_) => true
  }
  assert_eq(failed, true)
}
