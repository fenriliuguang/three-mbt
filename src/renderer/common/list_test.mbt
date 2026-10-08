///|
test "identity camera keeps the projection matrix" {
  let camera = @cameras.PerspectiveCamera::new(
    fov=50.0,
    aspect=1.0,
    near=0.1,
    far=100.0,
  )
  let mesh = @core.Object3D::new(kind=@core.Mesh)
  @common.update_frame(mesh, camera.node)
  match camera.node.camera {
    None => assert_eq(false, true)
    Some(state) => {
      let mvp = @common.model_view_projection(state, mesh)
      for index in 0..<16 {
        assert_eq(mvp.elements[index], state.projection.elements[index])
      }
    }
  }
}

///|
test "opaque list keeps a visible basic mesh" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let basic = @materials.MeshBasicMaterial::new(hex=0xFF8800)
  let mesh = @objects.Mesh::new(box.geometry, basic.material)
  ignore(scene.add(mesh))
  let hidden = @objects.Mesh::new(
    box.geometry,
    @materials.MeshBasicMaterial::new().material,
  )
  hidden.node.visible = false
  ignore(scene.add(hidden))
  basic.material.transparent = true
  let glass = @objects.Mesh::new(box.geometry, basic.material)
  ignore(scene.add(glass))
  let items = @common.collect_opaque(scene.node)
  assert_eq(items.length(), 1)
  assert_eq(items[0].geometry.get_attribute("position").unwrap().count, 24)
  assert_eq(items[0].color.get_hex(), 16746496)
  assert_eq(items[0].shading is @constants.Basic, true)
  assert_eq(items[0].map is None, true)
}

///|
test "opaque list keeps a mesh map" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let basic = @materials.MeshBasicMaterial::new()
  let mesh = @objects.Mesh::new(box.geometry, basic.material)
  let map = @textures.Texture::checker(
    width=2,
    height=2,
    cell=1,
    first=0xFFFFFF,
    second=0x000000,
  )
  mesh.set_map(Some(map))
  ignore(scene.add(mesh))
  let items = @common.collect_opaque(scene.node)
  assert_eq(items.length(), 1)
  match items[0].map {
    None => assert_eq(false, true)
    Some(stored) => {
      assert_eq(stored.width, 2)
      assert_eq(stored.height, 2)
      assert_eq(physical_equal(stored, map), true)
    }
  }
}

///|
test "packed vertices and uniforms are little-endian f32" {
  let attribute = @core.BufferAttribute::new([0.5, -1.0], 1)
  let packed = @common.pack_f32(attribute)
  assert_eq(packed.length(), 8)
  assert_eq(packed[0], b'\x00')
  assert_eq(packed[1], b'\x00')
  assert_eq(packed[2], b'\x00')
  assert_eq(packed[3], b'\x3F')
  assert_eq(packed[4], b'\x00')
  assert_eq(packed[5], b'\x00')
  assert_eq(packed[6], b'\x80')
  assert_eq(packed[7], b'\xBF')
  let indices = @core.BufferAttribute::from_ints([1, 2], 1)
  let packed_indices = @common.pack_u32_indices(indices)
  assert_eq(packed_indices.length(), 8)
  assert_eq(packed_indices[0], b'\x01')
  assert_eq(packed_indices[4], b'\x02')
  let mvp = @math.Matrix4::new()
  let color = @math.Color::new(r=0.0, g=1.0, b=0.0)
  let zero = @math.Vector3::new()
  let up = @math.Vector3::new(y=1.0)
  let uniforms = @common.pack_uniforms(
    mvp,
    @common.normal_matrix(mvp),
    color,
    1.0,
    zero,
    zero,
    up,
  )
  assert_eq(uniforms.length(), @common.uniform_bytes)
  assert_eq(uniforms[0], b'\x00')
  assert_eq(uniforms[1], b'\x00')
  assert_eq(uniforms[2], b'\x80')
  assert_eq(uniforms[3], b'\x3F')
  assert_eq(uniforms[132], b'\x00')
  assert_eq(uniforms[133], b'\x00')
  assert_eq(uniforms[134], b'\x80')
  assert_eq(uniforms[135], b'\x3F')
  assert_eq(uniforms[180], b'\x00')
  assert_eq(uniforms[181], b'\x00')
  assert_eq(uniforms[182], b'\x80')
  assert_eq(uniforms[183], b'\x3F')
}

///|
test "frame lights sum ambient and the first directional" {
  let scene = @scenes.Scene::new()
  let ambient = @lights.AmbientLight::new(hex=0xFFFFFF, intensity=0.25)
  ignore(scene.add(ambient))
  let sun = @lights.DirectionalLight::new(hex=0xFFFFFF, intensity=1.0)
  ignore(scene.add(sun))
  @common.update_frame(scene.node, scene.node)
  let lights = @common.collect_lights(scene.node)
  assert_eq(lights.ambient.x, 0.25)
  assert_eq(lights.ambient.y, 0.25)
  assert_eq(lights.ambient.z, 0.25)
  assert_eq(lights.color.x, 1.0)
  assert_eq(lights.direction.x, 0.0)
  assert_eq(lights.direction.y, 1.0)
  assert_eq(lights.direction.z, 0.0)
}

///|
test "vertices pack uv and texture rows pad to 256" {
  let position = @core.BufferAttribute::new([1.0, 0.0, 0.0], 3)
  let uv = @core.BufferAttribute::new([0.5, 0.25], 2)
  let packed = @common.pack_position_normal_uv(position, None, Some(uv))
  assert_eq(packed.length(), @common.vertex_stride)
  assert_eq(packed[20], b'\x00')
  assert_eq(packed[21], b'\x00')
  assert_eq(packed[22], b'\x80')
  assert_eq(packed[23], b'\x3F')
  assert_eq(packed[24], b'\x00')
  assert_eq(packed[25], b'\x00')
  assert_eq(packed[26], b'\x00')
  assert_eq(packed[27], b'\x3F')
  assert_eq(packed[28], b'\x00')
  assert_eq(packed[29], b'\x00')
  assert_eq(packed[30], b'\x80')
  assert_eq(packed[31], b'\x3E')
  let pixels = FixedArray::make(8, b'\x11')
  let (rows, stride) = @common.pad_texture_rows(pixels, 1, 2)
  assert_eq(@common.copy_bytes_per_row(4), 256)
  assert_eq(@common.copy_bytes_per_row(256), 256)
  assert_eq(stride, 256)
  assert_eq(rows.length(), 512)
  assert_eq(rows[0], b'\x11')
  assert_eq(rows[4], b'\x00')
  assert_eq(rows[256], b'\x11')
}
