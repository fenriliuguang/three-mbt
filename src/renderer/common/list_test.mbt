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
test "transparent meshes draw far to near" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let camera = @cameras.PerspectiveCamera::new(
    fov=50.0,
    aspect=1.0,
    near=0.1,
    far=100.0,
  )
  ignore(camera.node.position.set(0.0, 0.0, 5.0))
  let far_material = @materials.MeshBasicMaterial::new(hex=0xFF0000)
  far_material.material.transparent = true
  far_material.material.opacity = 0.25
  let far_mesh = @objects.Mesh::new(box.geometry, far_material.material)
  ignore(far_mesh.node.position.set(0.0, 0.0, 0.0))
  ignore(scene.add(far_mesh))
  let near_mesh = @objects.Mesh::new(
    box.geometry,
    @materials.MeshBasicMaterial::new(hex=0x00FF00).material,
  )
  near_mesh.set_transparent(true, opacity=0.5)
  ignore(near_mesh.node.position.set(0.0, 0.0, 2.0))
  ignore(scene.add(near_mesh))
  let wire = @materials.MeshBasicMaterial::new()
  wire.material.transparent = true
  wire.material.wireframe = true
  let wire_mesh = @objects.Mesh::new(box.geometry, wire.material)
  ignore(scene.add(wire_mesh))
  let solid = @objects.Mesh::new(
    box.geometry,
    @materials.MeshBasicMaterial::new().material,
  )
  ignore(scene.add(solid))
  @common.update_frame(scene.node, camera.node)
  let drawn = @common.collect_opaque(scene.node)
  assert_eq(drawn.length(), 1)
  assert_eq(physical_equal(drawn[0].node, solid.node), true)
  let glass = @common.collect_transparent(scene.node, camera.node)
  assert_eq(glass.length(), 2)
  assert_eq(physical_equal(glass[0].node, far_mesh.node), true)
  assert_eq(glass[0].opacity, 0.25)
  assert_eq(@common.view_depth(camera.node, far_mesh.node), -5.0)
  assert_eq(physical_equal(glass[1].node, near_mesh.node), true)
  assert_eq(glass[1].opacity, 0.5)
  assert_eq(@common.view_depth(camera.node, near_mesh.node), -3.0)
  let tied = @objects.Mesh::new(
    box.geometry,
    @materials.MeshBasicMaterial::new().material,
  )
  tied.set_transparent(true, opacity=1.0)
  ignore(tied.node.position.set(0.0, 0.0, 2.0))
  ignore(scene.add(tied))
  @common.update_frame(scene.node, camera.node)
  let same = @common.collect_transparent(scene.node, camera.node)
  assert_eq(same.length(), 3)
  assert_eq(physical_equal(same[1].node, near_mesh.node), true)
  assert_eq(physical_equal(same[2].node, tied.node), true)
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
  let eye = @math.Vector3::new(y=1.0)
  let uniforms = @common.pack_uniforms(
    mvp,
    @common.normal_matrix(mvp),
    color,
    1.0,
    zero,
    zero,
    up,
    mvp,
    eye,
    0.5,
    1.0,
    mvp,
    2.0,
    4.0,
    8.0,
    1.0,
    mvp,
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0,
    0.0,
    1.0,
    2.0,
    4.0,
    0.5,
    1.0,
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
  assert_eq(uniforms[192], b'\x00')
  assert_eq(uniforms[193], b'\x00')
  assert_eq(uniforms[194], b'\x80')
  assert_eq(uniforms[195], b'\x3F')
  assert_eq(uniforms[260], b'\x00')
  assert_eq(uniforms[261], b'\x00')
  assert_eq(uniforms[262], b'\x80')
  assert_eq(uniforms[263], b'\x3F')
  assert_eq(uniforms[272], b'\x00')
  assert_eq(uniforms[273], b'\x00')
  assert_eq(uniforms[274], b'\x00')
  assert_eq(uniforms[275], b'\x3F')
  assert_eq(uniforms[276], b'\x00')
  assert_eq(uniforms[277], b'\x00')
  assert_eq(uniforms[278], b'\x80')
  assert_eq(uniforms[279], b'\x3F')
  assert_eq(uniforms[288], b'\x00')
  assert_eq(uniforms[289], b'\x00')
  assert_eq(uniforms[290], b'\x00')
  assert_eq(uniforms[291], b'\x40')
  assert_eq(uniforms[304], b'\x00')
  assert_eq(uniforms[305], b'\x00')
  assert_eq(uniforms[306], b'\x00')
  assert_eq(uniforms[307], b'\x41')
  assert_eq(uniforms[320], b'\x00')
  assert_eq(uniforms[321], b'\x00')
  assert_eq(uniforms[322], b'\x80')
  assert_eq(uniforms[323], b'\x3F')
  assert_eq(uniforms[384], b'\x00')
  assert_eq(uniforms[385], b'\x00')
  assert_eq(uniforms[386], b'\x80')
  assert_eq(uniforms[387], b'\x3F')
  assert_eq(uniforms[448], b'\x00')
  assert_eq(uniforms[460], b'\x00')
  assert_eq(uniforms[464], b'\x00')
  assert_eq(uniforms[465], b'\x00')
  assert_eq(uniforms[466], b'\x80')
  assert_eq(uniforms[467], b'\x3F')
  assert_eq(uniforms[476], b'\x00')
  assert_eq(uniforms[477], b'\x00')
  assert_eq(uniforms[478], b'\x80')
  assert_eq(uniforms[479], b'\x3F')
  assert_eq(uniforms[480], b'\x00')
  assert_eq(uniforms[481], b'\x00')
  assert_eq(uniforms[482], b'\x00')
  assert_eq(uniforms[483], b'\x40')
  assert_eq(uniforms[492], b'\x00')
  assert_eq(uniforms[493], b'\x00')
  assert_eq(uniforms[494], b'\x80')
  assert_eq(uniforms[495], b'\x3F')
}

///|
test "missing instance colors pack as white" {
  let packed = @common.pack_instance_colors(None, 1)
  assert_eq(packed.length(), @common.instance_color_stride)
  assert_eq(packed[0], b'\x00')
  assert_eq(packed[1], b'\x00')
  assert_eq(packed[2], b'\x80')
  assert_eq(packed[3], b'\x3F')
  let red = @core.BufferAttribute::new([1.0, 0.0, 0.0], 3)
  let tinted = @common.pack_instance_colors(Some(red), 1)
  assert_eq(tinted[4], b'\x00')
  assert_eq(tinted[8], b'\x00')
  assert_eq(@common.instance_matrix_stride, 64)
}

///|
test "point quads cover six corners and indexed points expand" {
  let quad = @common.point_quad_bytes()
  assert_eq(quad.length(), 48)
  assert_eq(quad[0], b'\x00')
  assert_eq(quad[1], b'\x00')
  assert_eq(quad[2], b'\x80')
  assert_eq(quad[3], b'\xBF')
  let position = @core.BufferAttribute::new([0.0, 1.0, 2.0, 3.0, 4.0, 5.0], 3)
  let index = @core.BufferAttribute::from_ints([1], 1)
  let packed = @common.pack_point_positions(position, Some(index))
  assert_eq(packed.length(), @common.position_stride)
  assert_eq(packed[0], b'\x00')
  assert_eq(packed[1], b'\x00')
  assert_eq(packed[2], b'\x40')
  assert_eq(packed[3], b'\x40')
}

///|
test "standard material keeps roughness and metalness" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let standard = @materials.MeshStandardMaterial::new(
    roughness=0.25,
    metalness=0.75,
  )
  assert_eq(standard.material.roughness, 0.25)
  assert_eq(standard.material.metalness, 0.75)
  let defaults = @materials.MeshStandardMaterial::new()
  assert_eq(defaults.material.roughness, 1.0)
  assert_eq(defaults.material.metalness, 0.0)
  let mesh = @objects.Mesh::new(box.geometry, standard.material)
  ignore(scene.add(mesh))
  let items = @common.collect_opaque(scene.node)
  assert_eq(items.length(), 1)
  assert_eq(items[0].shading is @constants.Standard, true)
  assert_eq(items[0].roughness, 0.25)
  assert_eq(items[0].metalness, 0.75)
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
  assert_eq(lights.shadow is None, true)
}

///|
test "a casting directional light builds a shadow matrix" {
  let bias = @common.shadow_matrix(@math.Matrix4::new(), @math.Matrix4::new())
  assert_eq(bias.elements[0], 0.5)
  assert_eq(bias.elements[5], -0.5)
  assert_eq(bias.elements[10], 1.0)
  assert_eq(bias.elements[12], 0.5)
  assert_eq(bias.elements[13], 0.5)
  assert_eq(bias.elements[15], 1.0)
  let scene = @scenes.Scene::new()
  let sun = @lights.DirectionalLight::new()
  ignore(sun.node.position.set(0.0, 5.0, 10.0))
  sun.cast_shadow(true)
  sun.set_shadow_bounds(-2.0, 2.0, 2.0, -2.0, 1.0, 21.0)
  assert_eq(sun.shadow.map_size, 512)
  assert_eq(sun.shadow.bias, 0.0)
  ignore(scene.add(sun))
  @common.update_frame(scene.node, scene.node)
  let lights = @common.collect_lights(scene.node)
  match lights.shadow {
    None => panic()
    Some(shadow) => {
      assert_eq(shadow.map_size, 512)
      assert_eq(shadow.matrix.elements[12] > 0.49, true)
      assert_eq(shadow.matrix.elements[12] < 0.51, true)
      assert_eq(shadow.matrix.elements[13] > 0.49, true)
      assert_eq(shadow.matrix.elements[13] < 0.51, true)
      assert_eq(shadow.matrix.elements[14] > 0.0, true)
      assert_eq(shadow.matrix.elements[14] < 1.0, true)
    }
  }
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
