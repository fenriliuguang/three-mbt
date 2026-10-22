///|
fn image_mesh(text : String) -> @core.MeshBinding raise @gltf.GltfError {
  let node = @gltf.parse(text).scene.node.children[0]
  match node.mesh {
    None => panic()
    Some(binding) => binding
  }
}

///|
fn image_failed(text : String) -> Bool {
  try {
    ignore(@gltf.parse(text).scene)
    false
  } catch {
    @gltf.GltfError::Invalid(_) => true
  }
}

///|
test "glTF assigns one png to emissive, roughness, and metalness" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0]}],"nodes":[{"mesh":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0},"material":0}]}],"materials":[{"emissiveFactor":[1,0,0],"emissiveTexture":{"index":0},"pbrMetallicRoughness":{"metallicRoughnessTexture":{"index":0}}}],"textures":[{"source":0}],"images":[{"uri":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGP4z8AAAAMBAQDJ/pLvAAAAAElFTkSuQmCC"}],"accessors":[{"bufferView":0,"componentType":5126,"count":1,"type":"VEC3"}],"bufferViews":[{"buffer":0,"byteLength":12}],"buffers":[{"byteLength":12,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAA"}]}
  let binding = image_mesh(text)
  match binding.emissive_map {
    None => panic()
    Some(texture) => {
      assert_eq(texture.width, 1)
      assert_eq(texture.height, 1)
      assert_eq(texture.flip_y, false)
      assert_eq(texture.wrap_s is @constants.Repeat, true)
      assert_eq(texture.wrap_t is @constants.Repeat, true)
      assert_eq(texture.mag_filter is @constants.Linear, true)
      assert_eq(texture.min_filter is @constants.LinearMipmapLinear, true)
      let pixels = texture.rgba8()
      assert_eq(pixels[0], b'\xff')
      assert_eq(pixels[1], b'\x00')
      assert_eq(pixels[2], b'\x00')
      assert_eq(pixels[3], b'\xff')
    }
  }
  match (binding.roughness_map, binding.metalness_map) {
    (Some(roughness), Some(metalness)) => {
      assert_eq(roughness.rgba8()[0], b'\xff')
      assert_eq(metalness.rgba8()[0], b'\xff')
    }
    _ => panic()
  }
}

///|
test "glTF sampler overrides wrap and filter" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0]}],"nodes":[{"mesh":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0},"material":0}]}],"materials":[{"emissiveTexture":{"index":0,"texCoord":0}}],"samplers":[{"magFilter":9728,"minFilter":9986,"wrapS":33071,"wrapT":33648}],"textures":[{"sampler":0,"source":0}],"images":[{"uri":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGP4z8AAAAMBAQDJ/pLvAAAAAElFTkSuQmCC"}],"accessors":[{"bufferView":0,"componentType":5126,"count":1,"type":"VEC3"}],"bufferViews":[{"buffer":0,"byteLength":12}],"buffers":[{"byteLength":12,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAA"}]}
  let binding = image_mesh(text)
  match binding.emissive_map {
    None => panic()
    Some(texture) => {
      assert_eq(texture.mag_filter is @constants.Nearest, true)
      assert_eq(texture.min_filter is @constants.NearestMipmapLinear, true)
      assert_eq(texture.wrap_s is @constants.ClampToEdge, true)
      assert_eq(texture.wrap_t is @constants.MirroredRepeat, true)
    }
  }
  assert_eq(binding.roughness_map is None, true)
}

///|
test "glTF unlit material ignores emissive and metal-rough maps" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0]}],"nodes":[{"mesh":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0},"material":0}]}],"materials":[{"extensions":{"KHR_materials_unlit":{}},"emissiveTexture":{"index":0},"pbrMetallicRoughness":{"metallicRoughnessTexture":{"index":0}}}],"textures":[{"source":0}],"images":[{"uri":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGP4z8AAAAMBAQDJ/pLvAAAAAElFTkSuQmCC"}],"accessors":[{"bufferView":0,"componentType":5126,"count":1,"type":"VEC3"}],"bufferViews":[{"buffer":0,"byteLength":12}],"buffers":[{"byteLength":12,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAA"}]}
  let binding = image_mesh(text)
  assert_eq(binding.shading is @constants.Shading::Basic, true)
  assert_eq(binding.emissive_map is None, true)
  assert_eq(binding.roughness_map is None, true)
  assert_eq(binding.metalness_map is None, true)
}

///|
test "glTF reads a png from a buffer view" {
  let text =
    #|{"asset":{"version":"2.0"},"scenes":[{"nodes":[0]}],"nodes":[{"mesh":0}],"meshes":[{"primitives":[{"attributes":{"POSITION":0},"material":0}]}],"materials":[{"emissiveTexture":{"index":0}}],"textures":[{"source":0}],"images":[{"bufferView":1,"mimeType":"image/png"}],"accessors":[{"bufferView":0,"componentType":5126,"count":1,"type":"VEC3"}],"bufferViews":[{"buffer":0,"byteLength":12},{"buffer":0,"byteOffset":12,"byteLength":69}],"buffers":[{"byteLength":81,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAAiVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGP4z8AAAAMBAQDJ/pLvAAAAAElFTkSuQmCC"}]}
  let binding = image_mesh(text)
  match binding.emissive_map {
    None => panic()
    Some(texture) => assert_eq(texture.rgba8()[0], b'\xff')
  }
}

///|
test "glTF rejects a second uv set and jpeg images" {
  let second =
    #|{"asset":{"version":"2.0"},"images":[],"materials":[{"emissiveTexture":{"index":0,"texCoord":1}}],"textures":[],"meshes":[{"primitives":[{"attributes":{"POSITION":0},"material":0}]}],"nodes":[{"mesh":0}],"accessors":[{"bufferView":0,"componentType":5126,"count":1,"type":"VEC3"}],"bufferViews":[{"buffer":0,"byteLength":12}],"buffers":[{"byteLength":12,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAA"}]}
  assert_eq(image_failed(second), true)
  let jpeg =
    #|{"asset":{"version":"2.0"},"images":[{"uri":"data:image/jpeg;base64,/9j/4AAQ"}],"textures":[{"source":0}],"materials":[{"emissiveTexture":{"index":0}}],"meshes":[{"primitives":[{"attributes":{"POSITION":0},"material":0}]}],"nodes":[{"mesh":0}],"accessors":[{"bufferView":0,"componentType":5126,"count":1,"type":"VEC3"}],"bufferViews":[{"buffer":0,"byteLength":12}],"buffers":[{"byteLength":12,"uri":"data:application/octet-stream;base64,AAAAAAAAAAAAAAAA"}]}
  assert_eq(image_failed(jpeg), true)
}
