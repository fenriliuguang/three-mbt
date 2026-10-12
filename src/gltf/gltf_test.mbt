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
  let asset = @gltf.parse(triangle_gltf())
  assert_eq(asset.animations.length(), 0)
  let group = asset.scene
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
  let group = @gltf.parse(text).scene
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
  let group = @gltf.parse(text, bin~).scene
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
    ignore(@gltf.parse(text).scene)
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
  let node = must(@gltf.parse(text).scene.node, "multi")
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
  let group = @gltf.parse(text).scene
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
  let wide = @gltf.parse(wide_text).scene
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
  let group = @gltf.parse(text).scene
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
    ignore(@gltf.parse(text).scene)
    false
  } catch {
    @gltf.GltfError::Invalid(_) => true
  }
  assert_eq(failed, true)
}

///|
test "glTF translation and scale become keyframe tracks" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0]}],"nodes":[{"name":"arm","translation":[8,0,0]}],"animations":[{"name":"slide","samplers":[{"input":0,"output":1},{"input":0,"output":1,"interpolation":"STEP"}],"channels":[{"sampler":0,"target":{"node":0,"path":"translation"}},{"sampler":1,"target":{"node":0,"path":"scale"}},{"sampler":0,"target":{"path":"translation"}},{"sampler":0,"target":{"node":0,"path":"weights"}}]},{"samplers":[],"channels":[]}],"accessors":[{"bufferView":0,"componentType":5126,"count":2,"type":"SCALAR"},{"bufferView":1,"componentType":5126,"count":2,"type":"VEC3"}],"bufferViews":[{"buffer":0,"byteLength":8},{"buffer":0,"byteOffset":8,"byteLength":24}],"buffers":[{"byteLength":32,"uri":"data:application/octet-stream;base64,AAAAAAAAgD8AAAAAAAAAAAAAAAAAAIBAAAAAAAAAAAA="}]}
  let asset = @gltf.parse(text)
  assert_eq(asset.animations.length(), 2)
  let slide = asset.animations[0]
  assert_eq(slide.name, "slide")
  assert_eq(slide.duration, 1.0)
  assert_eq(slide.tracks.length(), 2)
  assert_eq(slide.tracks[0].name, "arm.position")
  assert_eq(
    slide.tracks[0].interpolation is @constants.Interpolation::Linear,
    true,
  )
  assert_eq(slide.tracks[0].times[1], 1.0)
  assert_eq(slide.tracks[0].values[3], 4.0)
  assert_eq(slide.tracks[1].name, "arm.scale")
  assert_eq(
    slide.tracks[1].interpolation is @constants.Interpolation::Discrete,
    true,
  )
  assert_eq(asset.animations[1].name, "animation_1")
  assert_eq(asset.animations[1].tracks.length(), 0)
  let mixer = @animation.AnimationMixer::new(asset.scene.node)
  let action = mixer.clip_action(slide)
  action.play()
  mixer.update(0.0)
  assert_eq(must(asset.scene.node, "arm").position.x, 0.0)
  mixer.update(0.5)
  assert_eq(must(asset.scene.node, "arm").position.x, 2.0)
}

///|
test "a glTF cubic spline follows the out tangent" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0]}],"nodes":[{"name":"arm"}],"animations":[{"name":"bend","samplers":[{"input":0,"output":1,"interpolation":"CUBICSPLINE"}],"channels":[{"sampler":0,"target":{"node":0,"path":"translation"}}]}],"accessors":[{"bufferView":0,"componentType":5126,"count":2,"type":"SCALAR"},{"bufferView":1,"componentType":5126,"count":6,"type":"VEC3"}],"bufferViews":[{"buffer":0,"byteLength":8},{"buffer":0,"byteOffset":8,"byteLength":72}],"buffers":[{"byteLength":80,"uri":"data:application/octet-stream;base64,AAAAAAAAgD8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="}]}
  let asset = @gltf.parse(text)
  let track = asset.animations[0].tracks[0]
  assert_eq(track.cubic_spline, true)
  assert_eq(track.name, "arm.position")
  let mixer = @animation.AnimationMixer::new(asset.scene.node)
  let action = mixer.clip_action(asset.animations[0])
  action.play()
  mixer.update(0.5)
  assert_eq(must(asset.scene.node, "arm").position.x, 0.5)
  assert_eq(must(asset.scene.node, "arm").position.y, 0.0)
  assert_eq(must(asset.scene.node, "arm").position.z, 0.0)
}

///|
test "glTF directional lights point down local -Z" {
  let text =
    #|{"asset":{"version":"2.0"},"extensions":{"KHR_lights_punctual":{"lights":[{"type":"directional","name":"unused","color":[0.5,0.25,0],"intensity":2},{"type":"directional"}]}},"scenes":[{"nodes":[0,1]}],"nodes":[{"name":"sun","translation":[1,2,3],"extensions":{"KHR_lights_punctual":{"light":0}}},{"extensions":{"KHR_lights_punctual":{"light":1}}}]}
  let scene = @gltf.parse(text).scene
  let sun = must(scene.node, "sun")
  assert_eq(sun.kind is @core.NodeKind::DirectionalLight, true)
  assert_eq(sun.position.x, 1.0)
  assert_eq(sun.position.y, 2.0)
  assert_eq(sun.position.z, 3.0)
  assert_eq(sun.children.length(), 1)
  match sun.light {
    None => panic()
    Some(state) => {
      assert_eq(state.kind is @core.LightKind::Directional, true)
      assert_eq(state.intensity, 2.0)
      assert_eq(state.color.r, 0.5)
      assert_eq(state.color.g, 0.25)
      assert_eq(state.color.b, 0.0)
      match state.target {
        None => panic()
        Some(target) => {
          assert_eq(physical_equal(target, sun.children[0]), true)
          assert_eq(target.position.x, 0.0)
          assert_eq(target.position.y, 0.0)
          assert_eq(target.position.z, -1.0)
        }
      }
    }
  }
  let fill = must(scene.node, "light_1")
  assert_eq(fill.position.x, 0.0)
  assert_eq(fill.position.y, 0.0)
  assert_eq(fill.position.z, 0.0)
  match fill.light {
    None => panic()
    Some(state) => {
      assert_eq(state.intensity, 1.0)
      assert_eq(state.color.r, 1.0)
      assert_eq(state.color.g, 1.0)
      assert_eq(state.color.b, 1.0)
    }
  }
}

///|
test "a glTF point light is rejected" {
  let text =
    #|{"asset":{"version":"2.0"},"extensions":{"KHR_lights_punctual":{"lights":[{"type":"point"}]}},"nodes":[{}]}
  let failed = try {
    ignore(@gltf.parse(text).scene)
    false
  } catch {
    @gltf.GltfError::Invalid(_) => true
  }
  assert_eq(failed, true)
}

///|
test "an unlit glTF material becomes a basic mesh" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0]}],"nodes":[{"name":"flat","mesh":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0},"material":0}]}],"materials":[{"extensions":{"KHR_materials_unlit":{}},"pbrMetallicRoughness":{"baseColorFactor":[0.5,0.25,0,1],"metallicFactor":1,"roughnessFactor":0}}],"accessors":[{"bufferView":0,"componentType":5126,"count":3,"type":"VEC3"}],"bufferViews":[{"buffer":0,"byteLength":36}],"buffers":[{"byteLength":36,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAA"}]}
  match must(@gltf.parse(text).scene.node, "flat").mesh {
    None => panic()
    Some(binding) => {
      assert_eq(binding.shading is @constants.Shading::Basic, true)
      assert_eq(binding.color.r, 0.5)
      assert_eq(binding.color.g, 0.25)
      assert_eq(binding.color.b, 0.0)
    }
  }
}

///|
test "glTF position morph weights are baked into vertices" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0]}],"nodes":[{"name":"blob","mesh":0}],"meshes":[{"weights":[0.5],"primitives":[{"attributes":{"POSITION":0},"targets":[{"POSITION":1}]}]}],"accessors":[{"bufferView":0,"componentType":5126,"count":3,"type":"VEC3"},{"bufferView":1,"componentType":5126,"count":3,"type":"VEC3"}],"bufferViews":[{"buffer":0,"byteLength":36},{"buffer":0,"byteOffset":36,"byteLength":36}],"buffers":[{"byteLength":72,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAA"}]}
  match must(@gltf.parse(text).scene.node, "blob").mesh {
    None => panic()
    Some(binding) => {
      let position = binding.geometry.get_attribute("position").unwrap()
      assert_eq(position.get_y(0), 1.0)
      assert_eq(position.get_x(1), 1.0)
      assert_eq(position.get_y(1), 1.0)
      assert_eq(position.get_y(2), 2.0)
      assert_eq(position.get_z(2), 0.0)
    }
  }
}

///|
test "glTF normal morph weights are baked into normals" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0]}],"nodes":[{"name":"blob","mesh":0}],"meshes":[{"weights":[0.5],"primitives":[{"attributes":{"POSITION":0,"NORMAL":1},"targets":[{"POSITION":2,"NORMAL":3}]}]}],"accessors":[{"bufferView":0,"componentType":5126,"count":3,"type":"VEC3"},{"bufferView":1,"componentType":5126,"count":3,"type":"VEC3"},{"bufferView":2,"componentType":5126,"count":3,"type":"VEC3"},{"bufferView":3,"componentType":5126,"count":3,"type":"VEC3"}],"bufferViews":[{"buffer":0,"byteLength":36},{"buffer":0,"byteOffset":36,"byteLength":36},{"buffer":0,"byteOffset":72,"byteLength":36},{"buffer":0,"byteOffset":108,"byteLength":36}],"buffers":[{"byteLength":144,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAIA/AAAAAAAAAAAAAIA/AAAAAAAAAAAAAIA/AAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAABA"}]}
  match must(@gltf.parse(text).scene.node, "blob").mesh {
    None => panic()
    Some(binding) => {
      let position = binding.geometry.get_attribute("position").unwrap()
      let normal = binding.geometry.get_attribute("normal").unwrap()
      assert_eq(position.get_y(0), 1.0)
      assert_eq(position.get_y(1), 1.0)
      assert_eq(position.get_y(2), 2.0)
      assert_eq(normal.get_z(0), 2.0)
      assert_eq(normal.get_x(1), 0.0)
      assert_eq(normal.get_z(1), 2.0)
      assert_eq(normal.get_z(2), 2.0)
    }
  }
}

///|
test "glTF node weights override mesh morph weights" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0,1,2,3,4,5]}],"nodes":[{"name":"heavy","mesh":0,"weights":[1,0]},{"name":"plain","mesh":0},{"name":"flat","mesh":0,"weights":[0,0]},{"name":"flat2","mesh":0,"weights":[0,0]},{"name":"partial","mesh":0,"weights":[1]},{"name":"copy","mesh":0,"weights":[0.5,0.25]}],"meshes":[{"weights":[0.5,0.25],"primitives":[{"attributes":{"POSITION":0},"targets":[{"POSITION":1},{"POSITION":2}]}]}],"accessors":[{"bufferView":0,"componentType":5126,"count":3,"type":"VEC3"},{"bufferView":1,"componentType":5126,"count":3,"type":"VEC3"},{"bufferView":2,"componentType":5126,"count":3,"type":"VEC3"}],"bufferViews":[{"buffer":0,"byteLength":36},{"buffer":0,"byteOffset":36,"byteLength":36},{"buffer":0,"byteOffset":72,"byteLength":36}],"buffers":[{"byteLength":108,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAACAQAAAAAAAAAAAAACAQAAAAAAAAAAAAACAQAAAAAAAAAAA"}]}
  let root = @gltf.parse(text).scene.node
  fn position(name : String) -> @core.BufferAttribute {
    match must(root, name).mesh {
      None => panic()
      Some(binding) => binding.geometry.get_attribute("position").unwrap()
    }
  }
  fn geometry(name : String) -> @core.BufferGeometry {
    match must(root, name).mesh {
      None => panic()
      Some(binding) => binding.geometry
    }
  }
  let heavy = position("heavy")
  assert_eq(heavy.get_y(0), 2.0)
  assert_eq(heavy.get_y(2), 3.0)
  assert_eq(heavy.get_x(0), 0.0)
  assert_eq(heavy.get_x(1), 1.0)
  let plain = position("plain")
  assert_eq(plain.get_y(0), 1.0)
  assert_eq(plain.get_y(2), 2.0)
  assert_eq(plain.get_x(0), 1.0)
  assert_eq(plain.get_x(1), 2.0)
  let partial = position("partial")
  assert_eq(partial.get_y(0), 2.0)
  assert_eq(partial.get_x(0), 1.0)
  assert_eq(partial.get_x(1), 2.0)
  let flat = position("flat")
  assert_eq(flat.get_y(0), 0.0)
  assert_eq(flat.get_y(2), 1.0)
  assert_eq(flat.get_x(1), 1.0)
  assert_eq(physical_equal(geometry("plain"), geometry("copy")), true)
  assert_eq(physical_equal(geometry("flat"), geometry("flat2")), true)
  assert_eq(physical_equal(geometry("plain"), geometry("heavy")), false)
  assert_eq(physical_equal(geometry("plain"), geometry("flat")), false)
  assert_eq(physical_equal(geometry("plain"), geometry("partial")), false)
}

///|
test "glTF color morph weights are baked into vertex colors" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0,1,2]}],"nodes":[{"name":"rgb","mesh":0},{"name":"rgba","mesh":1},{"name":"plain","mesh":2}],"meshes":[{"weights":[0.5],"primitives":[{"attributes":{"POSITION":0,"COLOR_0":1},"targets":[{"COLOR_0":2}]}]},{"weights":[0.5],"primitives":[{"attributes":{"POSITION":0,"COLOR_0":3},"targets":[{"COLOR_0":4}]}]},{"weights":[1],"primitives":[{"attributes":{"POSITION":0},"targets":[{"COLOR_0":2}]}]}],"accessors":[{"bufferView":0,"componentType":5126,"count":3,"type":"VEC3"},{"bufferView":1,"componentType":5126,"count":3,"type":"VEC3"},{"bufferView":2,"componentType":5126,"count":3,"type":"VEC3"},{"bufferView":3,"componentType":5126,"count":3,"type":"VEC4"},{"bufferView":4,"componentType":5126,"count":3,"type":"VEC4"}],"bufferViews":[{"buffer":0,"byteLength":36},{"buffer":0,"byteOffset":36,"byteLength":36},{"buffer":0,"byteOffset":72,"byteLength":36},{"buffer":0,"byteOffset":108,"byteLength":48},{"buffer":0,"byteOffset":156,"byteLength":48}],"buffers":[{"byteLength":204,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAAAAIA/AAAAAAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAABAAACAPwAAAAAAAAAAAACAPwAAgD8AAAAAAAAAAAAAgD8AAIA/AAAAAAAAAAAAAIA/AAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAABA"}]}
  let root = @gltf.parse(text).scene.node
  match must(root, "rgb").mesh {
    None => panic()
    Some(binding) => {
      let color = binding.geometry.get_attribute("color").unwrap()
      let position = binding.geometry.get_attribute("position").unwrap()
      assert_eq(color.item_size, 3)
      assert_eq(color.get_x(0), 1.0)
      assert_eq(color.get_z(0), 1.0)
      assert_eq(color.get_y(1), 1.0)
      assert_eq(color.get_z(1), 1.0)
      assert_eq(color.get_z(2), 2.0)
      assert_eq(position.get_x(1), 1.0)
      assert_eq(position.get_y(2), 1.0)
    }
  }
  match must(root, "rgba").mesh {
    None => panic()
    Some(binding) => {
      let color = binding.geometry.get_attribute("color").unwrap()
      assert_eq(color.item_size, 4)
      assert_eq(color.get_x(0), 1.0)
      assert_eq(color.get_y(0), 0.0)
      assert_eq(color.get_component(0, 3), 2.0)
      assert_eq(color.get_component(2, 3), 2.0)
    }
  }
  match must(root, "plain").mesh {
    None => panic()
    Some(binding) => {
      assert_eq(binding.geometry.get_attribute("color") is None, true)
      assert_eq(
        binding.geometry.get_attribute("position").unwrap().get_y(2),
        1.0,
      )
    }
  }
}

///|
test "glTF sparse accessors replace indexed elements" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0,1]}],"nodes":[{"name":"moved","mesh":0},{"name":"zeros","mesh":1}],"meshes":[{"primitives":[{"attributes":{"POSITION":0}}]},{"primitives":[{"attributes":{"POSITION":1}}]}],"accessors":[{"bufferView":0,"componentType":5126,"count":3,"type":"VEC3","sparse":{"count":1,"indices":{"bufferView":1,"componentType":5123},"values":{"bufferView":2}}},{"componentType":5126,"count":3,"type":"VEC3","sparse":{"count":1,"indices":{"bufferView":3,"componentType":5123},"values":{"bufferView":4}}}],"bufferViews":[{"buffer":0,"byteLength":36},{"buffer":0,"byteOffset":36,"byteLength":2},{"buffer":0,"byteOffset":38,"byteLength":12},{"buffer":0,"byteOffset":50,"byteLength":2},{"buffer":0,"byteOffset":52,"byteLength":12}],"buffers":[{"byteLength":64,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAAAQAAAIBAAACgQAAAwEAAAAAAAEEAAAAAAAAAAA=="}]}
  let root = @gltf.parse(text).scene.node
  match must(root, "moved").mesh {
    None => panic()
    Some(binding) => {
      let position = binding.geometry.get_attribute("position").unwrap()
      assert_eq(position.get_x(0), 0.0)
      assert_eq(position.get_x(1), 4.0)
      assert_eq(position.get_y(1), 5.0)
      assert_eq(position.get_z(1), 6.0)
      assert_eq(position.get_y(2), 1.0)
      assert_eq(position.get_x(2), 0.0)
    }
  }
  match must(root, "zeros").mesh {
    None => panic()
    Some(binding) => {
      let position = binding.geometry.get_attribute("position").unwrap()
      assert_eq(position.get_x(0), 8.0)
      assert_eq(position.get_y(0), 0.0)
      assert_eq(position.get_x(1), 0.0)
      assert_eq(position.get_y(2), 0.0)
    }
  }
}

///|
test "glTF mask and blend set alpha test and opacity" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0,1,2,3]}],"nodes":[{"name":"mask","mesh":0},{"name":"tight","mesh":1},{"name":"blend","mesh":2},{"name":"plain","mesh":3}],"meshes":[{"primitives":[{"attributes":{"POSITION":0},"material":0}]},{"primitives":[{"attributes":{"POSITION":0},"material":1}]},{"primitives":[{"attributes":{"POSITION":0},"material":2}]},{"primitives":[{"attributes":{"POSITION":0},"material":3}]}],"materials":[{"alphaMode":"MASK","pbrMetallicRoughness":{"baseColorFactor":[1,0,0,0.25]}},{"alphaMode":"MASK","alphaCutoff":0.2,"pbrMetallicRoughness":{"baseColorFactor":[0,1,0,0.8]}},{"alphaMode":"BLEND","pbrMetallicRoughness":{"baseColorFactor":[0,0,1,1]}},{"pbrMetallicRoughness":{"baseColorFactor":[1,1,1,0.2]}}],"accessors":[{"bufferView":0,"componentType":5126,"count":3,"type":"VEC3"}],"bufferViews":[{"buffer":0,"byteLength":36}],"buffers":[{"byteLength":36,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAA"}]}
  let root = @gltf.parse(text).scene.node
  match must(root, "mask").mesh {
    None => panic()
    Some(binding) => {
      assert_eq(binding.transparent, false)
      assert_eq(binding.opacity, 0.25)
      assert_eq(binding.alpha_test, 0.5)
    }
  }
  match must(root, "tight").mesh {
    None => panic()
    Some(binding) => {
      assert_eq(binding.transparent, false)
      assert_eq(binding.opacity, 0.8)
      assert_eq(binding.alpha_test, 0.2)
    }
  }
  match must(root, "blend").mesh {
    None => panic()
    Some(binding) => {
      assert_eq(binding.transparent, true)
      assert_eq(binding.opacity, 1.0)
      assert_eq(binding.alpha_test, 0.0)
    }
  }
  match must(root, "plain").mesh {
    None => panic()
    Some(binding) => {
      assert_eq(binding.transparent, false)
      assert_eq(binding.opacity, 1.0)
      assert_eq(binding.alpha_test, 0.0)
    }
  }
}

///|
test "glTF emissiveFactor is linear and unlit ignores it" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0,1,2]}],"nodes":[{"name":"glow","mesh":0},{"name":"flat","mesh":1},{"name":"plain","mesh":2}],"meshes":[{"primitives":[{"attributes":{"POSITION":0},"material":0}]},{"primitives":[{"attributes":{"POSITION":0},"material":1}]},{"primitives":[{"attributes":{"POSITION":0},"material":2}]}],"materials":[{"emissiveFactor":[0.5,0.25,0],"pbrMetallicRoughness":{"baseColorFactor":[1,0,0,1]}},{"extensions":{"KHR_materials_unlit":{}},"emissiveFactor":[1,0,0],"pbrMetallicRoughness":{"baseColorFactor":[0,1,0,1]}},{"pbrMetallicRoughness":{"baseColorFactor":[0,0,1,1]}}],"accessors":[{"bufferView":0,"componentType":5126,"count":3,"type":"VEC3"}],"bufferViews":[{"buffer":0,"byteLength":36}],"buffers":[{"byteLength":36,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAA"}]}
  let root = @gltf.parse(text).scene.node
  match must(root, "glow").mesh {
    None => panic()
    Some(binding) => {
      assert_eq(binding.emissive.r, 0.5)
      assert_eq(binding.emissive.g, 0.25)
      assert_eq(binding.emissive.b, 0.0)
    }
  }
  match must(root, "flat").mesh {
    None => panic()
    Some(binding) => {
      assert_eq(binding.emissive.r, 0.0)
      assert_eq(binding.emissive.g, 0.0)
      assert_eq(binding.emissive.b, 0.0)
    }
  }
  match must(root, "plain").mesh {
    None => panic()
    Some(binding) => {
      assert_eq(binding.emissive.r, 0.0)
      assert_eq(binding.emissive.g, 0.0)
      assert_eq(binding.emissive.b, 0.0)
    }
  }
}

///|
test "glTF rejects a short emissiveFactor" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0]}],"nodes":[{"mesh":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0},"material":0}]}],"materials":[{"emissiveFactor":[1,0]}],"accessors":[{"bufferView":0,"componentType":5126,"count":3,"type":"VEC3"}],"bufferViews":[{"buffer":0,"byteLength":36}],"buffers":[{"byteLength":36,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAA"}]}
  let failed = try {
    ignore(@gltf.parse(text).scene)
    false
  } catch {
    @gltf.GltfError::Invalid(_) => true
  }
  assert_eq(failed, true)
}

///|
test "glTF rejects an unknown alpha mode" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0]}],"nodes":[{"mesh":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0},"material":0}]}],"materials":[{"alphaMode":"HASH"}],"accessors":[{"bufferView":0,"componentType":5126,"count":3,"type":"VEC3"}],"bufferViews":[{"buffer":0,"byteLength":36}],"buffers":[{"byteLength":36,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAA"}]}
  let failed = try {
    ignore(@gltf.parse(text).scene)
    false
  } catch {
    @gltf.GltfError::Invalid(_) => true
  }
  assert_eq(failed, true)
}
