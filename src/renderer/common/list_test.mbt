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
  assert_eq(uniforms[280], b'\x00')
  assert_eq(uniforms[281], b'\x00')
  assert_eq(uniforms[282], b'\x00')
  assert_eq(uniforms[283], b'\x00')
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
  assert_eq(lights.point_enabled, 0.0)
  assert_eq(lights.spot_enabled, 0.0)
}

///|
test "frame lights keep the first point light" {
  let scene = @scenes.Scene::new()
  let bulb = @lights.PointLight::new(
    hex=0xFF0000,
    intensity=2.0,
    distance=4.0,
    decay=2.0,
  )
  ignore(bulb.node.position.set(0.0, 3.0, 0.0))
  ignore(scene.add(bulb))
  let other = @lights.PointLight::new(intensity=9.0)
  ignore(other.node.position.set(8.0, 0.0, 0.0))
  ignore(scene.add(other))
  @common.update_frame(scene.node, scene.node)
  let lights = @common.collect_lights(scene.node)
  assert_eq(lights.point_enabled, 1.0)
  assert_eq(lights.point_position.y, 3.0)
  assert_eq(lights.point_position.x, 0.0)
  assert_eq(lights.point_color.x, 2.0)
  assert_eq(lights.point_color.y, 0.0)
  assert_eq(lights.point_distance, 4.0)
  assert_eq(lights.point_decay, 2.0)
  assert_eq(lights.spot_enabled, 0.0)
}

///|
test "frame lights keep the first spot light" {
  let scene = @scenes.Scene::new()
  let fresh = @lights.SpotLight::new()
  assert_eq(fresh.node.position.y, 1.0)
  assert_eq(fresh.node.position.x, 0.0)
  let lamp = @lights.SpotLight::new(
    hex=0xFF0000,
    intensity=2.0,
    distance=4.0,
    angle=@std.PI / 3.0,
    penumbra=0.0,
    decay=2.0,
  )
  ignore(lamp.node.position.set(0.0, 4.0, 0.0))
  ignore(scene.add(lamp))
  let other = @lights.SpotLight::new(intensity=9.0, distance=1.0)
  ignore(other.node.position.set(8.0, 0.0, 0.0))
  ignore(scene.add(other))
  @common.update_frame(scene.node, scene.node)
  let lights = @common.collect_lights(scene.node)
  assert_eq(lights.spot_enabled, 1.0)
  assert_eq(lights.point_enabled, 0.0)
  assert_eq(lights.spot_position.y, 4.0)
  assert_eq(lights.spot_position.x, 0.0)
  assert_eq(lights.spot_direction.x, 0.0)
  assert_eq(lights.spot_direction.y, 1.0)
  assert_eq(lights.spot_direction.z, 0.0)
  assert_eq(lights.spot_color.x, 2.0)
  assert_eq(lights.spot_color.y, 0.0)
  assert_eq(lights.spot_distance, 4.0)
  assert_eq(lights.spot_decay, 2.0)
  assert_eq(lights.spot_cone_cos, @std.cos(@std.PI / 3.0))
  assert_eq(lights.spot_penumbra_cos, @std.cos(@std.PI / 3.0))
}

///|
test "frame lights keep the first hemisphere light" {
  let scene = @scenes.Scene::new()
  let fresh = @lights.HemisphereLight::new()
  assert_eq(fresh.node.position.y, 1.0)
  assert_eq(fresh.node.position.x, 0.0)
  let sky = @lights.HemisphereLight::new(
    sky=0xFF0000,
    ground=0x0000FF,
    intensity=2.0,
  )
  ignore(scene.add(sky))
  let other = @lights.HemisphereLight::new(sky=0x00FF00, intensity=9.0)
  ignore(other.node.position.set(4.0, 0.0, 0.0))
  ignore(scene.add(other))
  @common.update_frame(scene.node, scene.node)
  let lights = @common.collect_lights(scene.node)
  assert_eq(lights.hemisphere_enabled, 1.0)
  assert_eq(lights.hemisphere_sky.x, 2.0)
  assert_eq(lights.hemisphere_sky.y, 0.0)
  assert_eq(lights.hemisphere_sky.z, 0.0)
  assert_eq(lights.hemisphere_ground.x, 0.0)
  assert_eq(lights.hemisphere_ground.y, 0.0)
  assert_eq(lights.hemisphere_ground.z, 2.0)
  assert_eq(lights.hemisphere_direction.x, 0.0)
  assert_eq(lights.hemisphere_direction.y, 1.0)
  assert_eq(lights.hemisphere_direction.z, 0.0)
  assert_eq(lights.ambient.x, 0.0)
  ignore(sky.node.position.set(3.0, 0.0, 0.0))
  @common.update_frame(scene.node, scene.node)
  let moved = @common.collect_lights(scene.node)
  assert_eq(moved.hemisphere_direction.x, 1.0)
  assert_eq(moved.hemisphere_direction.y, 0.0)
  assert_eq(moved.hemisphere_direction.z, 0.0)
  ignore(sky.node.position.set(0.0, 0.0, 0.0))
  @common.update_frame(scene.node, scene.node)
  let origin = @common.collect_lights(scene.node)
  assert_eq(origin.hemisphere_enabled, 1.0)
  assert_eq(origin.hemisphere_direction.x, 0.0)
  assert_eq(origin.hemisphere_direction.y, 0.0)
  assert_eq(origin.hemisphere_direction.z, 0.0)
  let camera = @cameras.PerspectiveCamera::new()
  sky.node.layers.set(1)
  other.node.layers.set(1)
  let hidden = @common.collect_lights(scene.node, camera=camera.node)
  assert_eq(hidden.hemisphere_enabled, 0.0)
  let mvp = @math.Matrix4::new()
  let zero = @math.Vector3::new()
  let packed = @common.pack_uniforms(
    mvp,
    mvp,
    @math.Color::new(),
    1.0,
    zero,
    zero,
    zero,
    mvp,
    zero,
    1.0,
    0.0,
    mvp,
    1.0,
    1.0,
    1.0,
    0.0,
    mvp,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0,
    0.0,
    hemisphere_sky_r=lights.hemisphere_sky.x,
    hemisphere_sky_g=lights.hemisphere_sky.y,
    hemisphere_sky_b=lights.hemisphere_sky.z,
    hemisphere_ground_r=lights.hemisphere_ground.x,
    hemisphere_ground_g=lights.hemisphere_ground.y,
    hemisphere_ground_b=lights.hemisphere_ground.z,
    hemisphere_x=lights.hemisphere_direction.x,
    hemisphere_y=lights.hemisphere_direction.y,
    hemisphere_z=lights.hemisphere_direction.z,
    hemisphere_enabled=lights.hemisphere_enabled,
  )
  assert_eq(packed.length(), 672)
  assert_eq(packed[624], b'\x00')
  assert_eq(packed[625], b'\x00')
  assert_eq(packed[626], b'\x00')
  assert_eq(packed[627], b'\x40')
  assert_eq(packed[640], b'\x00')
  assert_eq(packed[648], b'\x00')
  assert_eq(packed[649], b'\x00')
  assert_eq(packed[650], b'\x00')
  assert_eq(packed[651], b'\x40')
  assert_eq(packed[656], b'\x00')
  assert_eq(packed[660], b'\x00')
  assert_eq(packed[661], b'\x00')
  assert_eq(packed[662], b'\x80')
  assert_eq(packed[663], b'\x3F')
  assert_eq(packed[668], b'\x00')
  assert_eq(packed[669], b'\x00')
  assert_eq(packed[670], b'\x80')
  assert_eq(packed[671], b'\x3F')
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
  assert_eq(sun.shadow.blur_samples, 8)
  ignore(scene.add(sun))
  @common.update_frame(scene.node, scene.node)
  let lights = @common.collect_lights(scene.node)
  match lights.shadow {
    None => panic()
    Some(shadow) => {
      assert_eq(shadow.map_size, 512)
      assert_eq(shadow.blur_samples, 8)
      assert_eq(shadow.matrix.elements[12] > 0.49, true)
      assert_eq(shadow.matrix.elements[12] < 0.51, true)
      assert_eq(shadow.matrix.elements[13] > 0.49, true)
      assert_eq(shadow.matrix.elements[13] < 0.51, true)
      assert_eq(shadow.matrix.elements[14] > 0.0, true)
      assert_eq(shadow.matrix.elements[14] < 1.0, true)
      match shadow.camera.camera {
        None => panic()
        Some(state) => {
          assert_eq(state.reversed_depth, false)
          assert_eq(state.projection.elements[10] < 0.0, true)
        }
      }
    }
  }
  let reversed = @common.collect_lights(scene.node, reversed_depth=true)
  match reversed.shadow {
    None => panic()
    Some(shadow) =>
      match shadow.camera.camera {
        None => panic()
        Some(state) => {
          assert_eq(state.reversed_depth, true)
          assert_eq(state.projection.elements[10] > 0.0, true)
        }
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
  assert_eq(packed[32], b'\x00')
  assert_eq(packed[33], b'\x00')
  assert_eq(packed[34], b'\x80')
  assert_eq(packed[35], b'\x3F')
  assert_eq(packed[44], b'\x00')
  assert_eq(packed[45], b'\x00')
  assert_eq(packed[46], b'\x80')
  assert_eq(packed[47], b'\x3F')
  let rgb = @core.BufferAttribute::new([2.0, 0.0, 0.0], 3)
  let rgba = @core.BufferAttribute::new([0.0, 1.0, 0.0, 0.5], 4)
  let packed_rgb = @common.pack_position_normal_uv(
    position,
    None,
    None,
    color=Some(rgb),
  )
  assert_eq(packed_rgb[32], b'\x00')
  assert_eq(packed_rgb[33], b'\x00')
  assert_eq(packed_rgb[34], b'\x00')
  assert_eq(packed_rgb[35], b'\x40')
  assert_eq(packed_rgb[44], b'\x00')
  assert_eq(packed_rgb[45], b'\x00')
  assert_eq(packed_rgb[46], b'\x80')
  assert_eq(packed_rgb[47], b'\x3F')
  let packed_rgba = @common.pack_position_normal_uv(
    position,
    None,
    None,
    color=Some(rgba),
  )
  assert_eq(packed_rgba[36], b'\x00')
  assert_eq(packed_rgba[37], b'\x00')
  assert_eq(packed_rgba[38], b'\x80')
  assert_eq(packed_rgba[39], b'\x3F')
  assert_eq(packed_rgba[44], b'\x00')
  assert_eq(packed_rgba[45], b'\x00')
  assert_eq(packed_rgba[46], b'\x00')
  assert_eq(packed_rgba[47], b'\x3F')
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

///|
test "frustum drops spheres behind the camera" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let front = @objects.Mesh::new(
    box.geometry,
    @materials.MeshBasicMaterial::new().material,
  )
  ignore(front.node.position.set(0.0, 0.0, -5.0))
  ignore(scene.add(front))
  let behind = @objects.Mesh::new(
    box.geometry,
    @materials.MeshBasicMaterial::new().material,
  )
  ignore(behind.node.position.set(0.0, 0.0, 5.0))
  ignore(scene.add(behind))
  let aside = @objects.Mesh::new(
    box.geometry,
    @materials.MeshBasicMaterial::new().material,
  )
  ignore(aside.node.position.set(20.0, 0.0, -2.0))
  ignore(scene.add(aside))
  let kept = @objects.Mesh::new(
    box.geometry,
    @materials.MeshBasicMaterial::new().material,
  )
  ignore(kept.node.position.set(0.0, 0.0, 5.0))
  kept.node.frustum_culled = false
  ignore(scene.add(kept))
  let glass = @materials.MeshBasicMaterial::new()
  glass.material.transparent = true
  let glass_front = @objects.Mesh::new(box.geometry, glass.material)
  ignore(glass_front.node.position.set(0.0, 0.0, -4.0))
  ignore(scene.add(glass_front))
  let glass_behind = @objects.Mesh::new(box.geometry, glass.material)
  ignore(glass_behind.node.position.set(0.0, 0.0, 4.0))
  ignore(scene.add(glass_behind))
  let camera = @cameras.PerspectiveCamera::new(
    fov=50.0,
    aspect=1.0,
    near=0.1,
    far=100.0,
  )
  @common.update_frame(scene.node, camera.node)
  match camera.node.camera {
    None => assert_eq(false, true)
    Some(state) => {
      let view = @common.camera_frustum(state)
      let drawn = @common.collect_opaque(scene.node, frustum=view)
      assert_eq(drawn.length(), 2)
      assert_eq(physical_equal(drawn[0].node, front.node), true)
      assert_eq(physical_equal(drawn[1].node, kept.node), true)
      assert_eq(@common.collect_opaque(scene.node).length(), 4)
      let clear = @common.collect_transparent(
        scene.node,
        camera.node,
        frustum=view,
      )
      assert_eq(clear.length(), 1)
      assert_eq(physical_equal(clear[0].node, glass_front.node), true)
    }
  }
}

///|
test "camera layers hide meshes and lights" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let mesh = @objects.Mesh::new(
    box.geometry,
    @materials.MeshBasicMaterial::new().material,
  )
  mesh.node.layers.set(1)
  ignore(scene.add(mesh))
  let ambient = @lights.AmbientLight::new(hex=0xFFFFFF, intensity=0.25)
  ambient.node.layers.set(1)
  ignore(scene.add(ambient))
  let camera = @cameras.PerspectiveCamera::new(
    fov=50.0,
    aspect=1.0,
    near=0.1,
    far=100.0,
  )
  @common.update_frame(scene.node, camera.node)
  assert_eq(@common.collect_opaque(scene.node, camera=camera.node).length(), 0)
  let hidden = @common.collect_lights(scene.node, camera=camera.node)
  assert_eq(hidden.ambient.x, 0.0)
  assert_eq(hidden.ambient.y, 0.0)
  assert_eq(hidden.ambient.z, 0.0)
  let all = @common.collect_lights(scene.node)
  assert_eq(all.ambient.x, 0.25)
  camera.node.layers.enable(1)
  assert_eq(@common.collect_opaque(scene.node, camera=camera.node).length(), 1)
  let shown = @common.collect_lights(scene.node, camera=camera.node)
  assert_eq(shown.ambient.x, 0.25)
  assert_eq(shown.ambient.y, 0.25)
  assert_eq(shown.ambient.z, 0.25)
}

///|
test "wireframe expands each triangle into three edges" {
  let box = @geometries.BoxGeometry::new()
  let lines = @common.wireframe_line_indices(box.geometry)
  match box.geometry.index {
    None => assert_eq(false, true)
    Some(index) => {
      assert_eq(lines.length(), index.count * 2)
      assert_eq(lines[0], index.get_x(0).to_int())
      assert_eq(lines[1], index.get_x(1).to_int())
      assert_eq(lines[2], index.get_x(1).to_int())
      assert_eq(lines[3], index.get_x(2).to_int())
      assert_eq(lines[4], index.get_x(2).to_int())
      assert_eq(lines[5], index.get_x(0).to_int())
    }
  }
  let bare = @core.BufferGeometry::new()
  ignore(
    bare.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0],
        3,
      ),
    ),
  )
  let open = @common.wireframe_line_indices(bare)
  assert_eq(open.length(), 6)
  assert_eq(open[0], 0)
  assert_eq(open[1], 1)
  assert_eq(open[2], 1)
  assert_eq(open[3], 2)
  assert_eq(open[4], 2)
  assert_eq(open[5], 0)
  let scene = @scenes.Scene::new()
  let wire = @materials.MeshBasicMaterial::new()
  wire.material.wireframe = true
  let mesh = @objects.Mesh::new(box.geometry, wire.material)
  ignore(scene.add(mesh))
  let solid = @objects.Mesh::new(
    box.geometry,
    @materials.MeshBasicMaterial::new().material,
  )
  ignore(scene.add(solid))
  let drawn = @common.collect_wireframe(scene.node)
  assert_eq(drawn.length(), 1)
  assert_eq(physical_equal(drawn[0].node, mesh.node), true)
  assert_eq(@common.collect_opaque(scene.node).length(), 1)
}

///|
test "wireframe meshes stay in the shadow list as triangles" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let wire = @materials.MeshBasicMaterial::new()
  wire.material.wireframe = true
  let mesh = @objects.Mesh::new(box.geometry, wire.material)
  mesh.node.cast_shadow = true
  ignore(scene.add(mesh))
  let glass = @materials.MeshBasicMaterial::new()
  glass.material.wireframe = true
  glass.material.transparent = true
  let clear = @objects.Mesh::new(box.geometry, glass.material)
  clear.node.cast_shadow = true
  ignore(scene.add(clear))
  let casters = @common.collect_shadow(scene.node)
  assert_eq(casters.length(), 1)
  assert_eq(physical_equal(casters[0].node, mesh.node), true)
  assert_eq(@common.collect_opaque(scene.node).length(), 0)
  assert_eq(@common.collect_wireframe(scene.node).length(), 2)
}

///|
test "instanced wireframes stay in the wireframe list" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let wire = @materials.MeshBasicMaterial::new()
  wire.material.wireframe = true
  let mesh = @objects.InstancedMesh::new(box.geometry, wire.material, 2)
  ignore(scene.add(mesh))
  let solid = @objects.InstancedMesh::new(
    box.geometry,
    @materials.MeshBasicMaterial::new().material,
    2,
  )
  ignore(scene.add(solid))
  let drawn = @common.collect_wireframe(scene.node)
  assert_eq(drawn.length(), 1)
  assert_eq(physical_equal(drawn[0].node, mesh.node), true)
  match drawn[0].instances {
    None => panic()
    Some(data) => assert_eq(data.count, 2)
  }
  assert_eq(@common.collect_opaque(scene.node).length(), 1)
}

///|
test "alpha test reaches the render list" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let material = @materials.MeshBasicMaterial::new()
  material.material.alpha_test = 0.5
  let mesh = @objects.Mesh::new(box.geometry, material.material)
  ignore(scene.add(mesh))
  let drawn = @common.collect_opaque(scene.node)
  assert_eq(drawn.length(), 1)
  assert_eq(drawn[0].alpha_test, 0.5)
}

///|
test "alpha test is packed into surface z" {
  let mvp = @math.Matrix4::new()
  let zero = @math.Vector3::new()
  let uniforms = @common.pack_uniforms(
    mvp,
    mvp,
    @math.Color::new(),
    1.0,
    zero,
    zero,
    zero,
    mvp,
    zero,
    1.0,
    0.0,
    mvp,
    1.0,
    1.0,
    1.0,
    0.0,
    mvp,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    alpha_test=0.5,
  )
  assert_eq(uniforms[280], b'\x00')
  assert_eq(uniforms[281], b'\x00')
  assert_eq(uniforms[282], b'\x00')
  assert_eq(uniforms[283], b'\x3F')
}

///|
test "material side is packed into surface w" {
  let mvp = @math.Matrix4::new()
  let zero = @math.Vector3::new()
  let front = @common.pack_uniforms(
    mvp,
    mvp,
    @math.Color::new(),
    1.0,
    zero,
    zero,
    zero,
    mvp,
    zero,
    1.0,
    0.0,
    mvp,
    1.0,
    1.0,
    1.0,
    0.0,
    mvp,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
  )
  assert_eq(front[284], b'\x00')
  assert_eq(front[287], b'\x00')
  let double = @common.pack_uniforms(
    mvp,
    mvp,
    @math.Color::new(),
    1.0,
    zero,
    zero,
    zero,
    mvp,
    zero,
    1.0,
    0.0,
    mvp,
    1.0,
    1.0,
    1.0,
    0.0,
    mvp,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    side=1.0,
  )
  assert_eq(double[284], b'\x00')
  assert_eq(double[285], b'\x00')
  assert_eq(double[286], b'\x80')
  assert_eq(double[287], b'\x3F')
  let back = @common.pack_uniforms(
    mvp,
    mvp,
    @math.Color::new(),
    1.0,
    zero,
    zero,
    zero,
    mvp,
    zero,
    1.0,
    0.0,
    mvp,
    1.0,
    1.0,
    1.0,
    0.0,
    mvp,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    side=-1.0,
  )
  assert_eq(back[284], b'\x00')
  assert_eq(back[285], b'\x00')
  assert_eq(back[286], b'\x80')
  assert_eq(back[287], b'\xBF')
}

///|
test "emissive reaches the render list" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let material = @materials.MeshLambertMaterial::new()
  ignore(material.material.emissive.set_rgb(0.25, 0.5, 0.0))
  let mesh = @objects.Mesh::new(box.geometry, material.material)
  ignore(scene.add(mesh))
  let drawn = @common.collect_opaque(scene.node)
  assert_eq(drawn.length(), 1)
  assert_eq(drawn[0].emissive.r, 0.25)
  assert_eq(drawn[0].emissive.g, 0.5)
  assert_eq(drawn[0].emissive.b, 0.0)
  assert_eq(drawn[0].emissive_intensity, 1.0)
}

///|
test "flat shading reaches the render list" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let material = @materials.MeshLambertMaterial::new()
  assert_eq(material.material.flat_shading, false)
  material.material.flat_shading = true
  let mesh = @objects.Mesh::new(box.geometry, material.material)
  ignore(scene.add(mesh))
  let drawn = @common.collect_opaque(scene.node)
  assert_eq(drawn[0].flat_shading, true)
}

///|
test "depth write defaults on and can be turned off" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let kept = @objects.Mesh::new(
    box.geometry,
    @materials.MeshBasicMaterial::new().material,
  )
  ignore(scene.add(kept))
  let quiet = @materials.MeshBasicMaterial::new()
  quiet.material.depth_write = false
  let mesh = @objects.Mesh::new(box.geometry, quiet.material)
  ignore(scene.add(mesh))
  let drawn = @common.collect_opaque(scene.node)
  assert_eq(drawn.length(), 2)
  assert_eq(drawn[0].depth_write, true)
  assert_eq(drawn[1].depth_write, false)
  let spot = point_at(0.0)
  let points_material = @materials.PointsMaterial::new()
  points_material.depth_write = false
  let points = @objects.Points::new(spot, points_material)
  ignore(scene.add(points))
  let line_material = @materials.LineBasicMaterial::new()
  assert_eq(line_material.depth_write, true)
  let line = @objects.Line::new(spot, line_material)
  ignore(scene.add(line))
  let strokes = @common.collect_primitives(scene.node)
  assert_eq(strokes.length(), 2)
  assert_eq(strokes[0].depth_write, false)
  assert_eq(strokes[1].depth_write, true)
}

///|
test "depth test defaults on and can be turned off" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let kept = @objects.Mesh::new(
    box.geometry,
    @materials.MeshBasicMaterial::new().material,
  )
  ignore(scene.add(kept))
  let quiet = @materials.MeshLambertMaterial::new()
  assert_eq(quiet.material.depth_test, true)
  quiet.material.depth_test = false
  let mesh = @objects.Mesh::new(box.geometry, quiet.material)
  ignore(scene.add(mesh))
  let drawn = @common.collect_opaque(scene.node)
  assert_eq(drawn.length(), 2)
  assert_eq(drawn[0].depth_test, true)
  assert_eq(drawn[0].depth_write, true)
  assert_eq(drawn[1].depth_test, false)
  assert_eq(drawn[1].depth_write, true)
  quiet.material.wireframe = true
  mesh.refresh()
  let wires = @common.collect_wireframe(scene.node)
  assert_eq(wires.length(), 1)
  assert_eq(wires[0].depth_test, false)
  let spot = point_at(0.0)
  let points_material = @materials.PointsMaterial::new()
  assert_eq(points_material.depth_test, true)
  points_material.depth_test = false
  let points = @objects.Points::new(spot, points_material)
  ignore(scene.add(points))
  let line_material = @materials.LineBasicMaterial::new()
  assert_eq(line_material.depth_test, true)
  let line = @objects.Line::new(spot, line_material)
  ignore(scene.add(line))
  let strokes = @common.collect_primitives(scene.node)
  assert_eq(strokes.length(), 2)
  assert_eq(strokes[0].depth_test, false)
  assert_eq(strokes[0].depth_write, true)
  assert_eq(strokes[1].depth_test, true)
}

///|
test "depth func defaults to less-equal and reaches the render list" {
  assert_eq(@constants.NEVER_DEPTH, 0)
  assert_eq(@constants.ALWAYS_DEPTH, 1)
  assert_eq(@constants.LESS_DEPTH, 2)
  assert_eq(@constants.LESS_EQUAL_DEPTH, 3)
  assert_eq(@constants.EQUAL_DEPTH, 4)
  assert_eq(@constants.GREATER_EQUAL_DEPTH, 5)
  assert_eq(@constants.GREATER_DEPTH, 6)
  assert_eq(@constants.NOT_EQUAL_DEPTH, 7)
  assert_eq(@constants.DepthFunc::LessEqual.to_int(), 3)
  assert_eq(
    @constants.DepthFunc::Never.reversed().to_int(),
    @constants.ALWAYS_DEPTH,
  )
  assert_eq(
    @constants.DepthFunc::Less.reversed().to_int(),
    @constants.GREATER_DEPTH,
  )
  assert_eq(
    @constants.DepthFunc::Equal.reversed().to_int(),
    @constants.NOT_EQUAL_DEPTH,
  )
  assert_eq(
    @constants.DepthFunc::LessEqual.reversed().to_int(),
    @constants.GREATER_EQUAL_DEPTH,
  )
  assert_eq(
    @constants.DepthFunc::Always.reversed().to_int(),
    @constants.NEVER_DEPTH,
  )
  assert_eq(
    @constants.DepthFunc::Greater.reversed().to_int(),
    @constants.LESS_DEPTH,
  )
  assert_eq(
    @constants.DepthFunc::NotEqual.reversed().to_int(),
    @constants.EQUAL_DEPTH,
  )
  assert_eq(
    @constants.DepthFunc::GreaterEqual.reversed().to_int(),
    @constants.LESS_EQUAL_DEPTH,
  )
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let material = @materials.MeshStandardMaterial::new()
  assert_eq(material.material.depth_func.to_int(), @constants.LESS_EQUAL_DEPTH)
  material.material.depth_func = @constants.Greater
  let mesh = @objects.Mesh::new(box.geometry, material.material)
  ignore(scene.add(mesh))
  let drawn = @common.collect_opaque(scene.node)
  assert_eq(drawn[0].depth_func.to_int(), @constants.GREATER_DEPTH)
  assert_eq(drawn[0].depth_test, true)
  let spot = point_at(0.0)
  let points_material = @materials.PointsMaterial::new()
  assert_eq(points_material.depth_func.to_int(), @constants.LESS_EQUAL_DEPTH)
  points_material.depth_func = @constants.Equal
  let points = @objects.Points::new(spot, points_material)
  ignore(scene.add(points))
  let line_material = @materials.LineBasicMaterial::new()
  line_material.depth_func = @constants.NotEqual
  let line = @objects.Line::new(spot, line_material)
  ignore(scene.add(line))
  let strokes = @common.collect_primitives(scene.node)
  assert_eq(strokes[0].depth_func.to_int(), @constants.EQUAL_DEPTH)
  assert_eq(strokes[1].depth_func.to_int(), @constants.NOT_EQUAL_DEPTH)
}

///|
test "color write defaults on and can be turned off" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let kept = @objects.Mesh::new(
    box.geometry,
    @materials.MeshBasicMaterial::new().material,
  )
  ignore(scene.add(kept))
  let quiet = @materials.MeshLambertMaterial::new()
  assert_eq(quiet.material.color_write, true)
  quiet.material.color_write = false
  let mesh = @objects.Mesh::new(box.geometry, quiet.material)
  ignore(scene.add(mesh))
  let drawn = @common.collect_opaque(scene.node)
  assert_eq(drawn.length(), 2)
  assert_eq(drawn[0].color_write, true)
  assert_eq(drawn[1].color_write, false)
  assert_eq(drawn[1].depth_write, true)
  let spot = point_at(0.0)
  let points_material = @materials.PointsMaterial::new()
  assert_eq(points_material.color_write, true)
  points_material.color_write = false
  let points = @objects.Points::new(spot, points_material)
  ignore(scene.add(points))
  let line_material = @materials.LineBasicMaterial::new()
  let line = @objects.Line::new(spot, line_material)
  ignore(scene.add(line))
  let strokes = @common.collect_primitives(scene.node)
  assert_eq(strokes[0].color_write, false)
  assert_eq(strokes[1].color_write, true)
}

///|
test "premultiplied alpha defaults off and reaches blended lists" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.premultiplied_alpha, false)
  let kept = @objects.Mesh::new(box.geometry, basic.material)
  ignore(scene.add(kept))
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.premultiplied_alpha, false)
  lambert.material.premultiplied_alpha = true
  let mesh = @objects.Mesh::new(box.geometry, lambert.material)
  ignore(scene.add(mesh))
  let drawn = @common.collect_opaque(scene.node)
  assert_eq(drawn.length(), 2)
  assert_eq(drawn[0].premultiplied_alpha, false)
  assert_eq(drawn[1].premultiplied_alpha, true)
  assert_eq(drawn[1].depth_write, true)
  let glass = @materials.MeshLambertMaterial::new()
  glass.material.transparent = true
  glass.material.premultiplied_alpha = true
  let blended = @objects.Mesh::new(box.geometry, glass.material)
  ignore(scene.add(blended))
  let camera = @cameras.PerspectiveCamera::new(fov=50.0, aspect=1.0)
  ignore(camera.node.position.set(0.0, 0.0, 5.0))
  @common.update_frame(scene.node, camera.node)
  let transparent = @common.collect_transparent(scene.node, camera.node)
  assert_eq(transparent.length(), 1)
  assert_eq(transparent[0].premultiplied_alpha, true)
  let spot = point_at(0.0)
  let points_material = @materials.PointsMaterial::new()
  assert_eq(points_material.premultiplied_alpha, false)
  points_material.premultiplied_alpha = true
  let points = @objects.Points::new(spot, points_material)
  ignore(scene.add(points))
  let line_material = @materials.LineBasicMaterial::new()
  assert_eq(line_material.premultiplied_alpha, false)
  let line = @objects.Line::new(spot, line_material)
  ignore(scene.add(line))
  let strokes = @common.collect_primitives(scene.node)
  assert_eq(strokes[0].premultiplied_alpha, true)
  assert_eq(strokes[1].premultiplied_alpha, false)
}

///|
test "point and line alphaTest reaches the draw list" {
  let scene = @scenes.Scene::new()
  let spot = point_at(0.0)
  let points_material = @materials.PointsMaterial::new()
  points_material.alpha_test = 0.4
  points_material.opacity = 1.0
  let points = @objects.Points::new(spot, points_material)
  ignore(scene.add(points))
  let line_material = @materials.LineBasicMaterial::new()
  line_material.alpha_test = 0.4
  line_material.opacity = 1.0
  let line = @objects.Line::new(spot, line_material)
  ignore(scene.add(line))
  let strokes = @common.collect_primitives(scene.node)
  assert_eq(strokes.length(), 2)
  assert_eq(strokes[0].alpha_test, 0.4)
  assert_eq(strokes[0].opacity, 1.0)
  assert_eq(strokes[1].alpha_test, 0.4)
  assert_eq(strokes[1].opacity, 1.0)
}

///|
test "shadow side flips the material side unless set" {
  assert_eq(
    @common.shadow_cast_side(@constants.Front, None).to_int(),
    @constants.BACK_SIDE,
  )
  assert_eq(
    @common.shadow_cast_side(@constants.Back, None).to_int(),
    @constants.FRONT_SIDE,
  )
  assert_eq(
    @common.shadow_cast_side(@constants.Double, None).to_int(),
    @constants.DOUBLE_SIDE,
  )
  assert_eq(
    @common.shadow_cast_side(@constants.Front, Some(@constants.Front)).to_int(),
    @constants.FRONT_SIDE,
  )
  assert_eq(
    @common.shadow_cast_side(@constants.Back, Some(@constants.Double)).to_int(),
    @constants.DOUBLE_SIDE,
  )
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let plain = @materials.MeshLambertMaterial::new()
  assert_eq(plain.material.shadow_side is None, true)
  let kept = @objects.Mesh::new(box.geometry, plain.material)
  kept.node.cast_shadow = true
  ignore(scene.add(kept))
  let explicit = @materials.MeshBasicMaterial::new()
  explicit.material.side = @constants.Back
  explicit.material.shadow_side = Some(@constants.Front)
  let mesh = @objects.Mesh::new(box.geometry, explicit.material)
  mesh.node.cast_shadow = true
  ignore(scene.add(mesh))
  let drawn = @common.collect_shadow(scene.node)
  assert_eq(drawn.length(), 2)
  assert_eq(drawn[0].shadow_side is None, true)
  assert_eq(drawn[0].side.to_int(), @constants.FRONT_SIDE)
  assert_eq(
    @common.shadow_cast_side(drawn[0].side, drawn[0].shadow_side).to_int(),
    @constants.BACK_SIDE,
  )
  match drawn[1].shadow_side {
    None => assert_eq(false, true)
    Some(side) => assert_eq(side.to_int(), @constants.FRONT_SIDE)
  }
  assert_eq(drawn[1].side.to_int(), @constants.BACK_SIDE)
}

///|
test "material visible defaults on and hides draws" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let shown = @materials.MeshBasicMaterial::new()
  assert_eq(shown.material.visible, true)
  let kept = @objects.Mesh::new(box.geometry, shown.material)
  kept.node.cast_shadow = true
  ignore(scene.add(kept))
  let hidden = @materials.MeshLambertMaterial::new()
  hidden.material.visible = false
  let mesh = @objects.Mesh::new(box.geometry, hidden.material)
  mesh.node.cast_shadow = true
  ignore(scene.add(mesh))
  let drawn = @common.collect_opaque(scene.node)
  assert_eq(drawn.length(), 1)
  assert_eq(physical_equal(drawn[0].node, kept.node), true)
  let shadows = @common.collect_shadow(scene.node)
  assert_eq(shadows.length(), 1)
  assert_eq(physical_equal(shadows[0].node, kept.node), true)
  let wire = @materials.MeshBasicMaterial::new()
  wire.material.wireframe = true
  wire.material.visible = false
  let edges = @objects.Mesh::new(box.geometry, wire.material)
  ignore(scene.add(edges))
  assert_eq(@common.collect_wireframe(scene.node).length(), 0)
  let glass = @materials.MeshLambertMaterial::new()
  glass.material.transparent = true
  glass.material.visible = false
  let blended = @objects.Mesh::new(box.geometry, glass.material)
  ignore(scene.add(blended))
  let camera = @cameras.PerspectiveCamera::new(fov=50.0, aspect=1.0)
  ignore(camera.node.position.set(0.0, 0.0, 5.0))
  @common.update_frame(scene.node, camera.node)
  assert_eq(@common.collect_transparent(scene.node, camera.node).length(), 0)
  let spot = point_at(0.0)
  let points_material = @materials.PointsMaterial::new()
  assert_eq(points_material.visible, true)
  points_material.visible = false
  let points = @objects.Points::new(spot, points_material)
  ignore(scene.add(points))
  let line_material = @materials.LineBasicMaterial::new()
  line_material.transparent = true
  line_material.visible = false
  let line = @objects.Line::new(spot, line_material)
  ignore(scene.add(line))
  assert_eq(@common.collect_primitives(scene.node).length(), 0)
  assert_eq(
    @common.collect_transparent_primitives(scene.node, camera.node).length(),
    0,
  )
}

///|
test "transparent double side draws back then front" {
  assert_eq(
    @common.color_sides(@constants.Front, true, false, false)[0].to_int(),
    @constants.FRONT_SIDE,
  )
  let split = @common.color_sides(@constants.Double, true, false, false)
  assert_eq(split.length(), 2)
  assert_eq(split[0].to_int(), @constants.BACK_SIDE)
  assert_eq(split[1].to_int(), @constants.FRONT_SIDE)
  let single = @common.color_sides(@constants.Double, true, false, true)
  assert_eq(single.length(), 1)
  assert_eq(single[0].to_int(), @constants.DOUBLE_SIDE)
  assert_eq(
    @common.color_sides(@constants.Double, false, false, false).length(),
    1,
  )
  assert_eq(
    @common.color_sides(@constants.Double, true, true, false).length(),
    1,
  )
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let glass = @materials.MeshLambertMaterial::new()
  assert_eq(glass.material.force_single_pass, false)
  glass.material.transparent = true
  glass.material.side = @constants.Double
  let mesh = @objects.Mesh::new(box.geometry, glass.material)
  ignore(scene.add(mesh))
  let forced = @materials.MeshBasicMaterial::new()
  forced.material.transparent = true
  forced.material.side = @constants.Double
  forced.material.force_single_pass = true
  let once = @objects.Mesh::new(box.geometry, forced.material)
  ignore(scene.add(once))
  let camera = @cameras.PerspectiveCamera::new(fov=50.0, aspect=1.0)
  ignore(camera.node.position.set(0.0, 0.0, 5.0))
  @common.update_frame(scene.node, camera.node)
  let drawn = @common.collect_transparent(scene.node, camera.node)
  assert_eq(drawn.length(), 2)
  assert_eq(drawn[0].force_single_pass, false)
  assert_eq(drawn[0].side.to_int(), @constants.DOUBLE_SIDE)
  assert_eq(drawn[1].force_single_pass, true)
}

///|
test "emissive intensity reaches the render list" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let material = @materials.MeshStandardMaterial::new()
  ignore(material.material.emissive.set_rgb(0.25, 0.0, 0.0))
  material.material.emissive_intensity = 2.0
  let mesh = @objects.Mesh::new(box.geometry, material.material)
  ignore(scene.add(mesh))
  let drawn = @common.collect_opaque(scene.node)
  assert_eq(drawn[0].emissive.r, 0.25)
  assert_eq(drawn[0].emissive_intensity, 2.0)
}

///|
test "an emissive map reaches the render list" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let material = @materials.MeshLambertMaterial::new()
  let map = @textures.Texture::checker(
    width=2,
    height=2,
    cell=1,
    first=0xFFFFFF,
    second=0x000000,
  )
  material.material.emissive_map = Some(map)
  let mesh = @objects.Mesh::new(box.geometry, material.material)
  ignore(scene.add(mesh))
  let drawn = @common.collect_opaque(scene.node)
  assert_eq(drawn.length(), 1)
  match drawn[0].emissive_map {
    None => assert_eq(false, true)
    Some(stored) => assert_eq(physical_equal(stored, map), true)
  }
}

///|
test "a roughness map reaches the render list" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let material = @materials.MeshStandardMaterial::new()
  let map = @textures.Texture::checker(
    width=2,
    height=2,
    cell=1,
    first=0xFFFFFF,
    second=0x000000,
  )
  material.material.roughness_map = Some(map)
  let mesh = @objects.Mesh::new(box.geometry, material.material)
  ignore(scene.add(mesh))
  let drawn = @common.collect_opaque(scene.node)
  assert_eq(drawn.length(), 1)
  match drawn[0].roughness_map {
    None => assert_eq(false, true)
    Some(stored) => assert_eq(physical_equal(stored, map), true)
  }
}

///|
test "a metalness map reaches the render list" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let material = @materials.MeshStandardMaterial::new()
  let map = @textures.Texture::checker(
    width=2,
    height=2,
    cell=1,
    first=0xFFFFFF,
    second=0x000000,
  )
  material.material.metalness_map = Some(map)
  let mesh = @objects.Mesh::new(box.geometry, material.material)
  ignore(scene.add(mesh))
  let drawn = @common.collect_opaque(scene.node)
  assert_eq(drawn.length(), 1)
  match drawn[0].metalness_map {
    None => assert_eq(false, true)
    Some(stored) => assert_eq(physical_equal(stored, map), true)
  }
}

///|
test "an environment map reaches the render list" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let material = @materials.MeshStandardMaterial::new()
  let map = @textures.Texture::from_rgba8(1, 1, FixedArray::make(4, b'\xFF'))
  material.material.env_map = Some(map)
  material.material.env_map_intensity = 2.0
  ignore(material.material.env_map_rotation.set(0.0, @std.PI / 2.0, 0.0))
  let mesh = @objects.Mesh::new(box.geometry, material.material)
  ignore(scene.add(mesh))
  let drawn = @common.collect_opaque(scene.node)
  assert_eq(drawn.length(), 1)
  assert_eq(drawn[0].env_map_intensity, 2.0)
  let expected = @math.Matrix4::new()
  ignore(expected.make_rotation_from_euler(material.material.env_map_rotation))
  let mut index = 0
  while index < 16 {
    assert_eq(drawn[0].env_rotation.elements[index], expected.elements[index])
    index = index + 1
  }
  match drawn[0].env_map {
    None => assert_eq(false, true)
    Some(stored) => assert_eq(physical_equal(stored, map), true)
  }
}

///|
test "env params pack a matrix and four floats" {
  let bytes = @common.pack_env_params(@math.Matrix4::new(), 2.0, true)
  assert_eq(bytes.length(), 80)
  assert_eq(bytes[0], b'\x00')
  assert_eq(bytes[1], b'\x00')
  assert_eq(bytes[2], b'\x80')
  assert_eq(bytes[3], b'\x3F')
  assert_eq(bytes[64], b'\x00')
  assert_eq(bytes[65], b'\x00')
  assert_eq(bytes[66], b'\x00')
  assert_eq(bytes[67], b'\x40')
  assert_eq(bytes[68], b'\x00')
  assert_eq(bytes[69], b'\x00')
  assert_eq(bytes[70], b'\xA0')
  assert_eq(bytes[71], b'\x40')
  assert_eq(bytes[72], b'\x00')
  assert_eq(bytes[73], b'\x00')
  assert_eq(bytes[74], b'\x80')
  assert_eq(bytes[75], b'\x3F')
  assert_eq(bytes[76], b'\x00')
  assert_eq(bytes[77], b'\x00')
  assert_eq(bytes[78], b'\xA0')
  assert_eq(bytes[79], b'\x40')
  let off = @common.pack_env_params(@math.Matrix4::new(), 0.0, false)
  assert_eq(off[64], b'\x00')
  assert_eq(off[72], b'\x00')
  assert_eq(off[75], b'\x00')
}

///|
test "detail maps reach the render list" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let material = @materials.MeshStandardMaterial::new()
  let normal = @textures.Texture::from_rgba8(1, 1, FixedArray::make(4, b'\x80'))
  let bump = @textures.Texture::from_rgba8(1, 1, FixedArray::make(4, b'\x40'))
  let ao = @textures.Texture::from_rgba8(1, 1, FixedArray::make(4, b'\xFF'))
  let light = @textures.Texture::from_rgba8(1, 1, FixedArray::make(4, b'\x10'))
  let displacement = @textures.Texture::from_rgba8(
    1,
    1,
    FixedArray::make(4, b'\x20'),
  )
  material.material.normal_map = Some(normal)
  material.material.normal_map_type = @constants.ObjectSpace
  material.material.normal_scale.x = 2.0
  material.material.normal_scale.y = 3.0
  material.material.bump_map = Some(bump)
  material.material.bump_scale = 4.0
  material.material.ao_map = Some(ao)
  material.material.ao_map_intensity = 0.5
  material.material.light_map = Some(light)
  material.material.light_map_intensity = 1.5
  material.material.displacement_map = Some(displacement)
  material.material.displacement_scale = 0.25
  material.material.displacement_bias = -0.1
  let mesh = @objects.Mesh::new(box.geometry, material.material)
  ignore(scene.add(mesh))
  let drawn = @common.collect_opaque(scene.node)
  assert_eq(drawn.length(), 1)
  assert_eq(
    drawn[0].normal_map_type.to_int(),
    @constants.OBJECT_SPACE_NORMAL_MAP,
  )
  assert_eq(drawn[0].normal_scale.x, 2.0)
  assert_eq(drawn[0].normal_scale.y, 3.0)
  assert_eq(drawn[0].bump_scale, 4.0)
  assert_eq(drawn[0].ao_map_intensity, 0.5)
  assert_eq(drawn[0].light_map_intensity, 1.5)
  assert_eq(drawn[0].displacement_scale, 0.25)
  assert_eq(drawn[0].displacement_bias, -0.1)
  match drawn[0].normal_map {
    None => assert_eq(false, true)
    Some(stored) => assert_eq(physical_equal(stored, normal), true)
  }
  match drawn[0].bump_map {
    None => assert_eq(false, true)
    Some(stored) => assert_eq(physical_equal(stored, bump), true)
  }
  match drawn[0].ao_map {
    None => assert_eq(false, true)
    Some(stored) => assert_eq(physical_equal(stored, ao), true)
  }
  match drawn[0].light_map {
    None => assert_eq(false, true)
    Some(stored) => assert_eq(physical_equal(stored, light), true)
  }
  match drawn[0].displacement_map {
    None => assert_eq(false, true)
    Some(stored) => assert_eq(physical_equal(stored, displacement), true)
  }
}

///|
test "detail uniforms occupy the spare frame slots" {
  let mvp = @math.Matrix4::new()
  let zero = @math.Vector3::new()
  let packed = @common.pack_uniforms(
    mvp,
    mvp,
    @math.Color::new(),
    1.0,
    zero,
    zero,
    zero,
    mvp,
    zero,
    1.0,
    0.0,
    mvp,
    1.0,
    1.0,
    1.0,
    0.0,
    mvp,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    has_normal=1.0,
    normal_scale_x=2.0,
    normal_scale_y=0.5,
    normal_object_space=1.0,
    bump_scale=2.0,
    ao_intensity=0.5,
    light_map_intensity=2.0,
    displacement_scale=5.0,
    displacement_bias=0.5,
    has_displacement=1.0,
  )
  assert_eq(packed[148], b'\x00')
  assert_eq(packed[149], b'\x00')
  assert_eq(packed[150], b'\x80')
  assert_eq(packed[151], b'\x3F')
  assert_eq(packed[172], b'\x00')
  assert_eq(packed[173], b'\x00')
  assert_eq(packed[174], b'\x00')
  assert_eq(packed[175], b'\x3F')
  assert_eq(packed[188], b'\x00')
  assert_eq(packed[189], b'\x00')
  assert_eq(packed[190], b'\x00')
  assert_eq(packed[191], b'\x40')
  assert_eq(packed[268], b'\x00')
  assert_eq(packed[269], b'\x00')
  assert_eq(packed[270], b'\x80')
  assert_eq(packed[271], b'\x3F')
  assert_eq(packed[296], b'\x00')
  assert_eq(packed[297], b'\x00')
  assert_eq(packed[298], b'\x00')
  assert_eq(packed[299], b'\x40')
  assert_eq(packed[300], b'\x00')
  assert_eq(packed[301], b'\x00')
  assert_eq(packed[302], b'\x00')
  assert_eq(packed[303], b'\x3F')
  assert_eq(packed[312], b'\x00')
  assert_eq(packed[313], b'\x00')
  assert_eq(packed[314], b'\x00')
  assert_eq(packed[315], b'\x40')
  assert_eq(packed[316], b'\x00')
  assert_eq(packed[317], b'\x00')
  assert_eq(packed[318], b'\xA0')
  assert_eq(packed[319], b'\x40')
  assert_eq(packed[524], b'\x00')
  assert_eq(packed[525], b'\x00')
  assert_eq(packed[526], b'\x00')
  assert_eq(packed[527], b'\x3F')
  assert_eq(packed[540], b'\x00')
  assert_eq(packed[541], b'\x00')
  assert_eq(packed[542], b'\x80')
  assert_eq(packed[543], b'\x3F')
  let plain = @common.pack_uniforms(
    mvp,
    mvp,
    @math.Color::new(),
    1.0,
    zero,
    zero,
    zero,
    mvp,
    zero,
    1.0,
    0.0,
    mvp,
    1.0,
    1.0,
    1.0,
    0.0,
    mvp,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
  )
  assert_eq(plain[148], b'\x00')
  assert_eq(plain[172], b'\x00')
  assert_eq(plain[188], b'\x00')
  assert_eq(plain[268], b'\x00')
  assert_eq(plain[296], b'\x00')
  assert_eq(plain[300], b'\x00')
  assert_eq(plain[312], b'\x00')
  assert_eq(plain[316], b'\x00')
  assert_eq(plain[524], b'\x00')
  assert_eq(plain[540], b'\x00')
}

///|
test "an alpha map reaches the render list" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let material = @materials.MeshBasicMaterial::new()
  let map = @textures.Texture::checker(
    width=2,
    height=2,
    cell=1,
    first=0xFFFFFF,
    second=0x000000,
  )
  material.material.alpha_map = Some(map)
  let mesh = @objects.Mesh::new(box.geometry, material.material)
  ignore(scene.add(mesh))
  let drawn = @common.collect_opaque(scene.node)
  assert_eq(drawn.length(), 1)
  match drawn[0].alpha_map {
    None => assert_eq(false, true)
    Some(stored) => assert_eq(physical_equal(stored, map), true)
  }
}

///|
test "emissive is packed after the fog parameters" {
  let mvp = @math.Matrix4::new()
  let zero = @math.Vector3::new()
  let uniforms = @common.pack_uniforms(
    mvp,
    mvp,
    @math.Color::new(),
    1.0,
    zero,
    zero,
    zero,
    mvp,
    zero,
    1.0,
    0.0,
    mvp,
    1.0,
    1.0,
    1.0,
    0.0,
    mvp,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    emissive_r=0.25,
    emissive_g=0.5,
    emissive_b=0.0,
  )
  assert_eq(uniforms.length(), @common.uniform_bytes)
  assert_eq(uniforms[496], b'\x00')
  assert_eq(uniforms[497], b'\x00')
  assert_eq(uniforms[498], b'\x80')
  assert_eq(uniforms[499], b'\x3E')
  assert_eq(uniforms[500], b'\x00')
  assert_eq(uniforms[501], b'\x00')
  assert_eq(uniforms[502], b'\x00')
  assert_eq(uniforms[503], b'\x3F')
  assert_eq(uniforms[504], b'\x00')
  assert_eq(uniforms[505], b'\x00')
  assert_eq(uniforms[506], b'\x00')
  assert_eq(uniforms[507], b'\x00')
  assert_eq(uniforms[508], b'\x00')
  assert_eq(uniforms[511], b'\x00')
  let flat = @common.pack_uniforms(
    mvp,
    mvp,
    @math.Color::new(),
    1.0,
    @math.Vector3::new(x=0.0, y=0.0, z=0.0),
    @math.Vector3::new(x=0.0, y=0.0, z=0.0),
    @math.Vector3::new(x=0.0, y=0.0, z=1.0),
    mvp,
    @math.Vector3::new(x=0.0, y=0.0, z=0.0),
    1.0,
    0.0,
    mvp,
    1.0,
    1.0,
    1.0,
    0.0,
    mvp,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    flat_shading=1.0,
  )
  assert_eq(flat[508], b'\x00')
  assert_eq(flat[509], b'\x00')
  assert_eq(flat[510], b'\x80')
  assert_eq(flat[511], b'\x3F')
}

///|
test "emissive intensity scales the packed color" {
  let mvp = @math.Matrix4::new()
  let zero = @math.Vector3::new()
  let uniforms = @common.pack_uniforms(
    mvp,
    mvp,
    @math.Color::new(),
    1.0,
    zero,
    zero,
    zero,
    mvp,
    zero,
    1.0,
    0.0,
    mvp,
    1.0,
    1.0,
    1.0,
    0.0,
    mvp,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    emissive_r=0.25,
    emissive_g=0.5,
    emissive_b=0.0,
    emissive_intensity=2.0,
  )
  assert_eq(uniforms[496], b'\x00')
  assert_eq(uniforms[497], b'\x00')
  assert_eq(uniforms[498], b'\x00')
  assert_eq(uniforms[499], b'\x3F')
  assert_eq(uniforms[500], b'\x00')
  assert_eq(uniforms[501], b'\x00')
  assert_eq(uniforms[502], b'\x80')
  assert_eq(uniforms[503], b'\x3F')
  assert_eq(uniforms[504], b'\x00')
  assert_eq(uniforms[505], b'\x00')
  assert_eq(uniforms[506], b'\x00')
  assert_eq(uniforms[507], b'\x00')
  let dark = @common.pack_uniforms(
    mvp,
    mvp,
    @math.Color::new(),
    1.0,
    zero,
    zero,
    zero,
    mvp,
    zero,
    1.0,
    0.0,
    mvp,
    1.0,
    1.0,
    1.0,
    0.0,
    mvp,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    emissive_r=0.25,
    emissive_intensity=0.0,
  )
  assert_eq(dark[496], b'\x00')
  assert_eq(dark[499], b'\x00')
}

///|
test "a point light is packed after emissive" {
  let mvp = @math.Matrix4::new()
  let zero = @math.Vector3::new()
  let uniforms = @common.pack_uniforms(
    mvp,
    mvp,
    @math.Color::new(),
    1.0,
    zero,
    zero,
    zero,
    mvp,
    zero,
    1.0,
    0.0,
    mvp,
    1.0,
    1.0,
    1.0,
    0.0,
    mvp,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    point_x=0.0,
    point_y=3.0,
    point_z=0.0,
    point_r=2.0,
    point_distance=4.0,
    point_decay=2.0,
    point_enabled=1.0,
  )
  assert_eq(uniforms.length(), @common.uniform_bytes)
  assert_eq(uniforms[516], b'\x00')
  assert_eq(uniforms[517], b'\x00')
  assert_eq(uniforms[518], b'\x40')
  assert_eq(uniforms[519], b'\x40')
  assert_eq(uniforms[528], b'\x00')
  assert_eq(uniforms[529], b'\x00')
  assert_eq(uniforms[530], b'\x00')
  assert_eq(uniforms[531], b'\x40')
  assert_eq(uniforms[544], b'\x00')
  assert_eq(uniforms[545], b'\x00')
  assert_eq(uniforms[546], b'\x80')
  assert_eq(uniforms[547], b'\x40')
  assert_eq(uniforms[548], b'\x00')
  assert_eq(uniforms[549], b'\x00')
  assert_eq(uniforms[550], b'\x00')
  assert_eq(uniforms[551], b'\x40')
  assert_eq(uniforms[552], b'\x00')
  assert_eq(uniforms[553], b'\x00')
  assert_eq(uniforms[554], b'\x80')
  assert_eq(uniforms[555], b'\x3F')
}

///|
test "a spot light is packed after the point light" {
  let mvp = @math.Matrix4::new()
  let zero = @math.Vector3::new()
  let uniforms = @common.pack_uniforms(
    mvp,
    mvp,
    @math.Color::new(),
    1.0,
    zero,
    zero,
    zero,
    mvp,
    zero,
    1.0,
    0.0,
    mvp,
    1.0,
    1.0,
    1.0,
    0.0,
    mvp,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    spot_y=4.0,
    spot_dy=1.0,
    spot_r=2.0,
    spot_distance=4.0,
    spot_decay=2.0,
    spot_cone_cos=0.5,
    spot_penumbra_cos=1.0,
    spot_enabled=1.0,
  )
  assert_eq(uniforms.length(), @common.uniform_bytes)
  assert_eq(uniforms[564], b'\x00')
  assert_eq(uniforms[565], b'\x00')
  assert_eq(uniforms[566], b'\x80')
  assert_eq(uniforms[567], b'\x40')
  assert_eq(uniforms[580], b'\x00')
  assert_eq(uniforms[581], b'\x00')
  assert_eq(uniforms[582], b'\x80')
  assert_eq(uniforms[583], b'\x3F')
  assert_eq(uniforms[588], b'\x00')
  assert_eq(uniforms[589], b'\x00')
  assert_eq(uniforms[590], b'\x80')
  assert_eq(uniforms[591], b'\x3F')
  assert_eq(uniforms[592], b'\x00')
  assert_eq(uniforms[593], b'\x00')
  assert_eq(uniforms[594], b'\x00')
  assert_eq(uniforms[595], b'\x40')
  assert_eq(uniforms[608], b'\x00')
  assert_eq(uniforms[609], b'\x00')
  assert_eq(uniforms[610], b'\x80')
  assert_eq(uniforms[611], b'\x40')
  assert_eq(uniforms[612], b'\x00')
  assert_eq(uniforms[613], b'\x00')
  assert_eq(uniforms[614], b'\x00')
  assert_eq(uniforms[615], b'\x40')
  assert_eq(uniforms[616], b'\x00')
  assert_eq(uniforms[617], b'\x00')
  assert_eq(uniforms[618], b'\x00')
  assert_eq(uniforms[619], b'\x3F')
  assert_eq(uniforms[620], b'\x00')
  assert_eq(uniforms[621], b'\x00')
  assert_eq(uniforms[622], b'\x80')
  assert_eq(uniforms[623], b'\x3F')
}

///|
fn point_at(z : Double) -> @core.BufferGeometry {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, z], 3),
    ),
  )
  geometry
}

///|
test "transparent points and lines sort far to near" {
  let scene = @scenes.Scene::new()
  let camera = @cameras.PerspectiveCamera::new(
    fov=50.0,
    aspect=1.0,
    near=0.1,
    far=100.0,
  )
  ignore(camera.node.position.set(0.0, 0.0, 5.0))
  let spot = point_at(0.0)
  let far = @objects.Points::new(spot, @materials.PointsMaterial::new())
  far.set_transparent(true, opacity=0.25)
  ignore(scene.add(far))
  let near = @objects.Points::new(spot, @materials.PointsMaterial::new())
  near.set_transparent(true, opacity=0.5)
  ignore(near.node.position.set(0.0, 0.0, 2.0))
  ignore(scene.add(near))
  let line = @objects.Line::new(spot, @materials.LineBasicMaterial::new())
  line.set_transparent(true, opacity=0.75)
  ignore(line.node.position.set(0.0, 0.0, -1.0))
  ignore(scene.add(line))
  let segments = @objects.LineSegments::new(
    spot,
    @materials.LineBasicMaterial::new(),
  )
  segments.set_transparent(true, opacity=0.4)
  ignore(segments.node.position.set(0.0, 0.0, -2.0))
  ignore(scene.add(segments))
  let solid = @objects.Points::new(spot, @materials.PointsMaterial::new())
  ignore(solid.node.position.set(0.0, 0.0, 1.0))
  ignore(scene.add(solid))
  @common.update_frame(scene.node, camera.node)
  let clear = @common.collect_transparent_primitives(scene.node, camera.node)
  assert_eq(clear.length(), 4)
  assert_eq(physical_equal(clear[0].node, segments.node), true)
  assert_eq(clear[0].opacity, 0.4)
  assert_eq(physical_equal(clear[1].node, line.node), true)
  assert_eq(clear[1].opacity, 0.75)
  assert_eq(physical_equal(clear[2].node, far.node), true)
  assert_eq(clear[2].opacity, 0.25)
  assert_eq(physical_equal(clear[3].node, near.node), true)
  assert_eq(clear[3].opacity, 0.5)
  assert_eq(@common.view_depth(camera.node, segments.node), -7.0)
  assert_eq(@common.view_depth(camera.node, line.node), -6.0)
  assert_eq(@common.view_depth(camera.node, far.node), -5.0)
  assert_eq(@common.view_depth(camera.node, near.node), -3.0)
  assert_eq(@common.collect_primitives(scene.node).length(), 1)
}

///|
test "update_frame skins a mesh from its bind pose" {
  let scene = @scenes.Scene::new()
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0], 3),
    ),
  )
  let mesh = @objects.Mesh::new(
    geometry,
    @materials.MeshBasicMaterial::new().material,
  )
  let joint = @core.Object3D::new()
  ignore(joint.position.set(2.0, 0.0, 0.0))
  ignore(scene.add(joint))
  ignore(scene.add(mesh))
  mesh.node.skin = Some(@core.SkinState::{
    joints: [joint],
    inverse_binds: [@math.Matrix4::new()],
    bind_position: [0.0, 0.0, 0.0],
    bind_normal: None,
    indices: [0, 0, 0, 0],
    weights: [1.0, 0.0, 0.0, 0.0],
  })
  let camera = @cameras.PerspectiveCamera::new()
  @common.update_frame(scene.node, camera.node)
  match mesh.node.mesh {
    None => assert_eq(false, true)
    Some(binding) =>
      assert_eq(
        binding.geometry.get_attribute("position").unwrap().get_x(0),
        2.0,
      )
  }
}

///|
test "render order draws lower values first and leaves shadows unsorted" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let camera = @cameras.PerspectiveCamera::new(
    fov=50.0,
    aspect=1.0,
    near=0.1,
    far=100.0,
  )
  ignore(camera.node.position.set(0.0, 0.0, 5.0))
  let far_mesh = @objects.Mesh::new(
    box.geometry,
    @materials.MeshBasicMaterial::new().material,
  )
  far_mesh.node.render_order = 0
  far_mesh.node.cast_shadow = true
  ignore(far_mesh.node.position.set(0.0, 0.0, 0.0))
  ignore(scene.add(far_mesh))
  let near_mesh = @objects.Mesh::new(
    box.geometry,
    @materials.MeshBasicMaterial::new().material,
  )
  near_mesh.node.render_order = 0
  near_mesh.node.cast_shadow = true
  ignore(near_mesh.node.position.set(0.0, 0.0, 2.0))
  ignore(scene.add(near_mesh))
  @common.update_frame(scene.node, camera.node)
  let depth_tied = @common.collect_opaque(scene.node)
  assert_eq(depth_tied.length(), 2)
  assert_eq(physical_equal(depth_tied[0].node, far_mesh.node), true)
  assert_eq(physical_equal(depth_tied[1].node, near_mesh.node), true)
  let early = @objects.Mesh::new(
    box.geometry,
    @materials.MeshBasicMaterial::new().material,
  )
  early.node.render_order = -1
  early.node.cast_shadow = true
  ignore(early.node.position.set(0.0, 0.0, 2.0))
  ignore(scene.add(early))
  let late = @objects.Mesh::new(
    box.geometry,
    @materials.MeshBasicMaterial::new().material,
  )
  late.node.render_order = 2
  ignore(scene.add(late))
  let drawn = @common.collect_opaque(scene.node)
  assert_eq(drawn.length(), 4)
  assert_eq(physical_equal(drawn[0].node, early.node), true)
  assert_eq(physical_equal(drawn[1].node, far_mesh.node), true)
  assert_eq(physical_equal(drawn[2].node, near_mesh.node), true)
  assert_eq(physical_equal(drawn[3].node, late.node), true)
  let casters = @common.collect_shadow(scene.node)
  assert_eq(casters.length(), 4)
  assert_eq(physical_equal(casters[0].node, far_mesh.node), true)
  assert_eq(physical_equal(casters[1].node, near_mesh.node), true)
  assert_eq(physical_equal(casters[2].node, early.node), true)
  assert_eq(physical_equal(casters[3].node, late.node), true)
  let wire_late = @materials.MeshBasicMaterial::new()
  wire_late.material.wireframe = true
  let back = @objects.Mesh::new(box.geometry, wire_late.material)
  back.node.render_order = 4
  ignore(scene.add(back))
  let wire_early = @materials.MeshBasicMaterial::new()
  wire_early.material.wireframe = true
  let front = @objects.Mesh::new(box.geometry, wire_early.material)
  front.node.render_order = 1
  ignore(scene.add(front))
  let wires = @common.collect_wireframe(scene.node)
  assert_eq(wires.length(), 2)
  assert_eq(physical_equal(wires[0].node, front.node), true)
  assert_eq(physical_equal(wires[1].node, back.node), true)
}

///|
test "transparent render order precedes view depth" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let camera = @cameras.PerspectiveCamera::new(
    fov=50.0,
    aspect=1.0,
    near=0.1,
    far=100.0,
  )
  ignore(camera.node.position.set(0.0, 0.0, 5.0))
  let far_mesh = @objects.Mesh::new(
    box.geometry,
    @materials.MeshBasicMaterial::new().material,
  )
  far_mesh.set_transparent(true, opacity=0.25)
  far_mesh.node.render_order = 1
  ignore(far_mesh.node.position.set(0.0, 0.0, 0.0))
  ignore(scene.add(far_mesh))
  let near_mesh = @objects.Mesh::new(
    box.geometry,
    @materials.MeshBasicMaterial::new().material,
  )
  near_mesh.set_transparent(true, opacity=0.5)
  near_mesh.node.render_order = 0
  ignore(near_mesh.node.position.set(0.0, 0.0, 2.0))
  ignore(scene.add(near_mesh))
  @common.update_frame(scene.node, camera.node)
  let glass = @common.collect_transparent(scene.node, camera.node)
  assert_eq(glass.length(), 2)
  assert_eq(physical_equal(glass[0].node, near_mesh.node), true)
  assert_eq(physical_equal(glass[1].node, far_mesh.node), true)
  let tied = @objects.Mesh::new(
    box.geometry,
    @materials.MeshBasicMaterial::new().material,
  )
  tied.set_transparent(true, opacity=1.0)
  tied.node.render_order = 0
  ignore(tied.node.position.set(0.0, 0.0, 0.0))
  ignore(scene.add(tied))
  @common.update_frame(scene.node, camera.node)
  let same = @common.collect_transparent(scene.node, camera.node)
  assert_eq(same.length(), 3)
  assert_eq(physical_equal(same[0].node, tied.node), true)
  assert_eq(physical_equal(same[1].node, near_mesh.node), true)
  assert_eq(physical_equal(same[2].node, far_mesh.node), true)
  let spot = point_at(0.0)
  let far_point = @objects.Points::new(spot, @materials.PointsMaterial::new())
  far_point.set_transparent(true, opacity=0.2)
  far_point.node.render_order = 3
  ignore(scene.add(far_point))
  let near_point = @objects.Points::new(spot, @materials.PointsMaterial::new())
  near_point.set_transparent(true, opacity=0.8)
  near_point.node.render_order = -2
  ignore(near_point.node.position.set(0.0, 0.0, 2.0))
  ignore(scene.add(near_point))
  let solid = @objects.Points::new(spot, @materials.PointsMaterial::new())
  solid.node.render_order = 5
  ignore(scene.add(solid))
  let sooner = @objects.Line::new(spot, @materials.LineBasicMaterial::new())
  sooner.node.render_order = -1
  ignore(scene.add(sooner))
  @common.update_frame(scene.node, camera.node)
  let clear = @common.collect_transparent_primitives(scene.node, camera.node)
  assert_eq(clear.length(), 2)
  assert_eq(physical_equal(clear[0].node, near_point.node), true)
  assert_eq(physical_equal(clear[1].node, far_point.node), true)
  let strokes = @common.collect_primitives(scene.node)
  assert_eq(strokes.length(), 2)
  assert_eq(physical_equal(strokes[0].node, sooner.node), true)
  assert_eq(physical_equal(strokes[1].node, solid.node), true)
}

///|
test "frustum culls instanced meshes with their bounding sphere" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0], 3),
    ),
  )
  let outside = @objects.InstancedMesh::new(
    geometry,
    @materials.Material::basic(),
    1,
  )
  let matrix = @math.Matrix4::new()
  ignore(matrix.make_translation(-2.0, 0.0, 0.0))
  outside.set_matrix_at(0, matrix)
  outside.node.frustum_culled = true
  outside.node.update_matrix_world()
  let inside = @objects.InstancedMesh::new(
    geometry,
    @materials.Material::basic(),
    1,
  )
  ignore(matrix.make_translation(0.5, 0.5, 0.5))
  inside.set_matrix_at(0, matrix)
  inside.node.frustum_culled = true
  inside.node.update_matrix_world()
  let scene = @scenes.Scene::new()
  ignore(scene.add(outside))
  ignore(scene.add(inside))
  let frustum = @math.Frustum::new()
  ignore(
    frustum.set(
      @math.Plane::new(normal=@math.Vector3::new(x=1.0), constant=0.0),
      @math.Plane::new(normal=@math.Vector3::new(x=-1.0), constant=1.0),
      @math.Plane::new(normal=@math.Vector3::new(y=1.0), constant=0.0),
      @math.Plane::new(normal=@math.Vector3::new(y=-1.0), constant=1.0),
      @math.Plane::new(normal=@math.Vector3::new(z=1.0), constant=0.0),
      @math.Plane::new(normal=@math.Vector3::new(z=-1.0), constant=1.0),
    ),
  )
  let drawn = @common.collect_opaque(scene.node, frustum~)
  assert_eq(drawn.length(), 1)
  assert_eq(physical_equal(drawn[0].node, inside.node), true)
  match outside.instances.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(sphere.center.x, -2.0)
      assert_eq(sphere.center.y, 0.0)
      assert_eq(sphere.center.z, 0.0)
      assert_eq(sphere.radius, 0.0)
    }
  }
  match geometry.bounding_sphere {
    None => assert_eq(false, true)
    Some(geometry_sphere) => {
      assert_eq(geometry_sphere.center.x, 0.0)
      assert_eq(geometry_sphere.radius, 0.0)
    }
  }
  outside.node.frustum_culled = false
  let kept = @common.collect_opaque(scene.node, frustum~)
  assert_eq(kept.length(), 2)
  assert_eq(physical_equal(kept[0].node, outside.node), true)
  assert_eq(physical_equal(kept[1].node, inside.node), true)
}

///|
test "material groups draw as separate list items" {
  let scene = @scenes.Scene::new()
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [
          0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 5.0, 0.0, 0.0, 6.0, 0.0, 0.0,
          5.0, 1.0, 0.0,
        ],
        3,
      ),
    ),
  )
  let red = @materials.Material::basic(hex=0xFF0000)
  let green = @materials.Material::basic(hex=0x00FF00)
  let mesh = @objects.Mesh::new(geometry, red)
  mesh.set_materials([red, green])
  ignore(scene.add(mesh))
  assert_eq(@common.collect_opaque(scene.node).length(), 0)
  geometry.add_group(0, 3, material_index=0)
  geometry.add_group(3, 3, material_index=1)
  let drawn = @common.collect_opaque(scene.node)
  assert_eq(drawn.length(), 2)
  assert_eq(drawn[0].color.r, 1.0)
  assert_eq(drawn[0].color.g, 0.0)
  assert_eq(drawn[0].group_start, 0)
  assert_eq(drawn[0].group_count, 3)
  assert_eq(drawn[1].color.r, 0.0)
  assert_eq(drawn[1].color.g, 1.0)
  assert_eq(drawn[1].group_start, 3)
  assert_eq(drawn[1].group_count, 3)
  let shadows = @common.collect_shadow(scene.node)
  assert_eq(shadows.length(), 2)
  assert_eq(shadows[0].group_start, 0)
  assert_eq(shadows[0].group_count, 3)
  assert_eq(shadows[1].group_start, 3)
  assert_eq(shadows[1].group_count, 3)
  green.transparent = true
  mesh.refresh()
  let camera = @cameras.PerspectiveCamera::new(
    fov=50.0,
    aspect=1.0,
    near=0.1,
    far=100.0,
  )
  @common.update_frame(scene.node, camera.node)
  let kept = @common.collect_opaque(scene.node)
  assert_eq(kept.length(), 1)
  assert_eq(kept[0].color.r, 1.0)
  assert_eq(kept[0].group_count, 3)
  let glass = @common.collect_transparent(scene.node, camera.node)
  assert_eq(glass.length(), 1)
  assert_eq(glass[0].color.g, 1.0)
  assert_eq(glass[0].group_start, 3)
  assert_eq(glass[0].group_count, 3)
  geometry.add_group(6, 3, material_index=9)
  assert_eq(@common.collect_opaque(scene.node).length(), 1)
  assert_eq(@common.collect_transparent(scene.node, camera.node).length(), 1)
  let alone = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let solid = @objects.Mesh::new(
    box.geometry,
    @materials.MeshBasicMaterial::new().material,
  )
  ignore(alone.add(solid))
  let one = @common.collect_opaque(alone.node)
  assert_eq(one.length(), 1)
  assert_eq(one[0].group_start, 0)
  assert_eq(one[0].group_count, -1)
}

///|
test "wireframe groups stay on the wire list" {
  let scene = @scenes.Scene::new()
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [
          0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 5.0, 0.0, 0.0, 6.0, 0.0, 0.0,
          5.0, 1.0, 0.0,
        ],
        3,
      ),
    ),
  )
  let red = @materials.Material::basic(hex=0xFF0000)
  red.wireframe = true
  let green = @materials.Material::basic(hex=0x00FF00)
  let mesh = @objects.Mesh::new(geometry, red)
  mesh.set_materials([red, green])
  ignore(scene.add(mesh))
  assert_eq(@common.collect_wireframe(scene.node).length(), 0)
  assert_eq(@common.collect_opaque(scene.node).length(), 0)
  geometry.add_group(0, 3, material_index=0)
  geometry.add_group(3, 3, material_index=1)
  let wires = @common.collect_wireframe(scene.node)
  assert_eq(wires.length(), 1)
  assert_eq(wires[0].color.r, 1.0)
  assert_eq(wires[0].color.g, 0.0)
  assert_eq(wires[0].group_start, 0)
  assert_eq(wires[0].group_count, 6)
  let drawn = @common.collect_opaque(scene.node)
  assert_eq(drawn.length(), 1)
  assert_eq(drawn[0].color.g, 1.0)
  assert_eq(drawn[0].group_start, 3)
  assert_eq(drawn[0].group_count, 3)
  let shadows = @common.collect_shadow(scene.node)
  assert_eq(shadows.length(), 2)
  green.wireframe = true
  green.transparent = true
  mesh.refresh()
  let camera = @cameras.PerspectiveCamera::new(
    fov=50.0,
    aspect=1.0,
    near=0.1,
    far=100.0,
  )
  @common.update_frame(scene.node, camera.node)
  let both = @common.collect_wireframe(scene.node)
  assert_eq(both.length(), 2)
  assert_eq(both[1].color.g, 1.0)
  assert_eq(both[1].group_start, 6)
  assert_eq(both[1].group_count, 6)
  assert_eq(@common.collect_opaque(scene.node).length(), 0)
  assert_eq(@common.collect_transparent(scene.node, camera.node).length(), 0)
  assert_eq(@common.collect_shadow(scene.node).length(), 1)
  geometry.add_group(6, 3, material_index=9)
  assert_eq(@common.collect_wireframe(scene.node).length(), 2)
  let alone = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let solid = @materials.MeshBasicMaterial::new()
  solid.material.wireframe = true
  let whole = @objects.Mesh::new(box.geometry, solid.material)
  ignore(alone.add(whole))
  let one = @common.collect_wireframe(alone.node)
  assert_eq(one.length(), 1)
  assert_eq(one[0].group_start, 0)
  assert_eq(one[0].group_count, -1)
}

///|
test "draw range clips mesh groups" {
  let scene = @scenes.Scene::new()
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [
          0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 5.0, 0.0, 0.0, 6.0, 0.0, 0.0,
          5.0, 1.0, 0.0,
        ],
        3,
      ),
    ),
  )
  let mesh = @objects.Mesh::new(geometry, @materials.Material::basic())
  ignore(scene.add(mesh))
  let whole = @common.collect_opaque(scene.node)
  assert_eq(whole.length(), 1)
  assert_eq(whole[0].group_start, 0)
  assert_eq(whole[0].group_count, -1)
  geometry.set_draw_range(1.0, 4.0)
  let clipped = @common.collect_opaque(scene.node)
  assert_eq(clipped.length(), 1)
  assert_eq(clipped[0].group_start, 1)
  assert_eq(clipped[0].group_count, 4)
  geometry.set_draw_range(0.0, 6.0)
  assert_eq(@common.collect_opaque(scene.node)[0].group_count, -1)
  geometry.set_draw_range(2.0, 0.0)
  assert_eq(@common.collect_opaque(scene.node)[0].group_start, 2)
  assert_eq(@common.collect_opaque(scene.node)[0].group_count, 0)
  geometry.set_draw_range(10.0, 2.0)
  assert_eq(@common.collect_opaque(scene.node).length(), 0)
  ignore(geometry.set_index_array([0, 1, 2]))
  geometry.set_draw_range(1.0, 4.0)
  let indexed = @common.collect_opaque(scene.node)
  assert_eq(indexed.length(), 1)
  assert_eq(indexed[0].group_start, 1)
  assert_eq(indexed[0].group_count, 2)
  let grouped = @core.BufferGeometry::new()
  ignore(
    grouped.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [
          0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 5.0, 0.0, 0.0, 6.0, 0.0, 0.0,
          5.0, 1.0, 0.0,
        ],
        3,
      ),
    ),
  )
  grouped.add_group(0, 3, material_index=0)
  grouped.add_group(3, 3, material_index=1)
  grouped.set_draw_range(2.0, 3.0)
  let red = @materials.Material::basic(hex=0xFF0000)
  let green = @materials.Material::basic(hex=0x00FF00)
  let pair = @objects.Mesh::new(grouped, red)
  pair.set_materials([red, green])
  ignore(scene.add(pair))
  geometry.set_draw_range(10.0, 2.0)
  let parts = @common.collect_opaque(scene.node)
  assert_eq(parts.length(), 2)
  assert_eq(parts[0].group_start, 2)
  assert_eq(parts[0].group_count, 1)
  assert_eq(parts[1].group_start, 3)
  assert_eq(parts[1].group_count, 2)
  let shadowed = @common.collect_shadow(scene.node)
  assert_eq(shadowed.length(), 2)
  assert_eq(shadowed[0].group_count, 1)
  assert_eq(shadowed[1].group_count, 2)
  red.wireframe = true
  green.wireframe = true
  pair.refresh()
  let wires = @common.collect_wireframe(scene.node)
  assert_eq(wires.length(), 2)
  assert_eq(wires[0].group_start, 4)
  assert_eq(wires[0].group_count, 2)
  assert_eq(wires[1].group_start, 6)
  assert_eq(wires[1].group_count, 4)
  assert_eq(@common.collect_opaque(scene.node).length(), 0)
  let empty = @objects.Mesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
  )
  ignore(scene.add(empty))
  assert_eq(@common.collect_opaque(scene.node).length(), 0)
}

///|
test "draw range clips points and lines" {
  let scene = @scenes.Scene::new()
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 2.0, 0.0, 0.0, 3.0, 0.0, 0.0],
        3,
      ),
    ),
  )
  let points = @objects.Points::new(geometry, @materials.PointsMaterial::new())
  ignore(scene.add(points))
  let line = @objects.Line::new(geometry, @materials.LineBasicMaterial::new())
  ignore(scene.add(line))
  let strokes = @common.collect_primitives(scene.node)
  assert_eq(strokes.length(), 2)
  assert_eq(strokes[0].draw_start, 0)
  assert_eq(strokes[0].draw_count, -1)
  assert_eq(strokes[1].draw_start, 0)
  assert_eq(strokes[1].draw_count, -1)
  geometry.set_draw_range(1.0, 2.0)
  let clipped = @common.collect_primitives(scene.node)
  assert_eq(clipped.length(), 2)
  assert_eq(clipped[0].draw_start, 1)
  assert_eq(clipped[0].draw_count, 2)
  assert_eq(clipped[1].kind is @core.PrimitiveKind::Line, true)
  assert_eq(clipped[1].draw_start, 1)
  assert_eq(clipped[1].draw_count, 2)
  geometry.set_draw_range(1.0, 0.0)
  assert_eq(@common.collect_primitives(scene.node)[0].draw_count, 0)
  geometry.set_draw_range(8.0, 1.0)
  assert_eq(@common.collect_primitives(scene.node).length(), 0)
  ignore(geometry.set_index_array([2, 0, 1]))
  geometry.set_draw_range(1.0, 4.0)
  let indexed = @common.collect_primitives(scene.node)
  assert_eq(indexed.length(), 2)
  assert_eq(indexed[0].draw_start, 1)
  assert_eq(indexed[0].draw_count, 2)
  assert_eq(indexed[1].draw_count, 2)
  points.set_transparent(true, opacity=0.5)
  let camera = @cameras.PerspectiveCamera::new(
    fov=50.0,
    aspect=1.0,
    near=0.1,
    far=100.0,
  )
  @common.update_frame(scene.node, camera.node)
  let glass = @common.collect_transparent_primitives(scene.node, camera.node)
  assert_eq(glass.length(), 1)
  assert_eq(glass[0].draw_start, 1)
  assert_eq(glass[0].draw_count, 2)
  assert_eq(glass[0].opacity, 0.5)
  let segments = @objects.LineSegments::new(
    geometry,
    @materials.LineBasicMaterial::new(),
  )
  ignore(scene.add(segments))
  let paired = @common.collect_primitives(scene.node)
  assert_eq(paired.length(), 2)
  assert_eq(paired[1].kind is @core.PrimitiveKind::LineSegments, true)
  assert_eq(paired[1].draw_start, 1)
  assert_eq(paired[1].draw_count, 2)
  let empty = @objects.Points::new(
    @core.BufferGeometry::new(),
    @materials.PointsMaterial::new(),
  )
  ignore(scene.add(empty))
  assert_eq(@common.collect_primitives(scene.node).length(), 2)
}

///|
test "point and line material groups draw separately" {
  let scene = @scenes.Scene::new()
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 2.0, 0.0, 0.0, 3.0, 0.0, 0.0],
        3,
      ),
    ),
  )
  let red = @materials.PointsMaterial::new(hex=0xFF0000, size=4.0)
  let green = @materials.PointsMaterial::new(
    hex=0x00FF00,
    size=8.0,
    size_attenuation=false,
  )
  let points = @objects.Points::new(geometry, red)
  points.set_materials([red, green])
  ignore(scene.add(points))
  assert_eq(@common.collect_primitives(scene.node).length(), 0)
  geometry.add_group(0, 2, material_index=0)
  geometry.add_group(2, 2, material_index=1)
  let drawn = @common.collect_primitives(scene.node)
  assert_eq(drawn.length(), 2)
  assert_eq(drawn[0].color.r, 1.0)
  assert_eq(drawn[0].color.g, 0.0)
  assert_eq(drawn[0].size, 4.0)
  assert_eq(drawn[0].size_attenuation, true)
  assert_eq(drawn[0].draw_start, 0)
  assert_eq(drawn[0].draw_count, 2)
  assert_eq(drawn[1].color.r, 0.0)
  assert_eq(drawn[1].color.g, 1.0)
  assert_eq(drawn[1].size, 8.0)
  assert_eq(drawn[1].size_attenuation, false)
  assert_eq(drawn[1].draw_start, 2)
  assert_eq(drawn[1].draw_count, 2)
  geometry.set_draw_range(1.0, 2.0)
  let clipped = @common.collect_primitives(scene.node)
  assert_eq(clipped.length(), 2)
  assert_eq(clipped[0].draw_start, 1)
  assert_eq(clipped[0].draw_count, 1)
  assert_eq(clipped[1].draw_start, 2)
  assert_eq(clipped[1].draw_count, 1)
  green.transparent = true
  points.refresh()
  let camera = @cameras.PerspectiveCamera::new(
    fov=50.0,
    aspect=1.0,
    near=0.1,
    far=100.0,
  )
  @common.update_frame(scene.node, camera.node)
  let kept = @common.collect_primitives(scene.node)
  assert_eq(kept.length(), 1)
  assert_eq(kept[0].color.r, 1.0)
  assert_eq(kept[0].draw_count, 1)
  let glass = @common.collect_transparent_primitives(scene.node, camera.node)
  assert_eq(glass.length(), 1)
  assert_eq(glass[0].color.g, 1.0)
  assert_eq(glass[0].draw_start, 2)
  assert_eq(glass[0].draw_count, 1)
  assert_eq(glass[0].opacity, 1.0)
  geometry.add_group(4, 2, material_index=9)
  assert_eq(@common.collect_primitives(scene.node).length(), 1)
  match points.materials {
    None => assert_eq(false, true)
    Some(list) => assert_eq(list.length(), 2)
  }
  let cloned = points.clone()
  match cloned.materials {
    None => assert_eq(false, true)
    Some(list) => {
      assert_eq(list.length(), 2)
      list.push(@materials.PointsMaterial::new())
      assert_eq(list.length(), 3)
    }
  }
  match points.materials {
    None => assert_eq(false, true)
    Some(list) => assert_eq(list.length(), 2)
  }
  let line_geometry = @core.BufferGeometry::new()
  ignore(
    line_geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 2.0, 0.0, 0.0, 3.0, 0.0, 0.0],
        3,
      ),
    ),
  )
  line_geometry.add_group(0, 2, material_index=0)
  line_geometry.add_group(2, 2, material_index=1)
  let line_red = @materials.LineBasicMaterial::new(hex=0xFF0000)
  let line_green = @materials.LineBasicMaterial::new(hex=0x00FF00)
  let line = @objects.Line::new(line_geometry, line_red)
  line.set_materials([line_red, line_green])
  let line_scene = @scenes.Scene::new()
  ignore(line_scene.add(line))
  let wires = @common.collect_primitives(line_scene.node)
  assert_eq(wires.length(), 2)
  assert_eq(wires[0].kind is @core.PrimitiveKind::Line, true)
  assert_eq(wires[0].color.r, 1.0)
  assert_eq(wires[0].draw_start, 0)
  assert_eq(wires[0].draw_count, 2)
  assert_eq(wires[1].color.g, 1.0)
  assert_eq(wires[1].draw_start, 2)
  assert_eq(wires[1].draw_count, 2)
  let segments = @objects.LineSegments::new(
    line_geometry,
    @materials.LineBasicMaterial::new(),
  )
  segments.set_materials([line_red, line_green])
  ignore(line_scene.add(segments))
  let paired = @common.collect_primitives(line_scene.node)
  assert_eq(paired.length(), 4)
  assert_eq(paired[2].kind is @core.PrimitiveKind::LineSegments, true)
  assert_eq(paired[2].draw_count, 2)
  assert_eq(paired[3].draw_start, 2)
}
