///|
test "Sprite.copy shares material and copies the center" {
  let material = @materials.SpriteMaterial::new(
    rotation=0.5,
    size_attenuation=false,
  )
  let source = @objects.Sprite::new(material)
  ignore(source.center.set(0.25, 0.75))
  source.count = 4
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  source.node.render_order = 4
  let child = @core.Object3D::new()
  child.name = "marker"
  ignore(source.node.add(child))
  let destination = @objects.Sprite::new(@materials.SpriteMaterial::new())
  let copied = destination.copy(source)
  assert_eq(physical_equal(copied, destination), true)
  assert_eq(physical_equal(destination.material, material), true)
  assert_eq(destination.material.rotation, 0.5)
  assert_eq(destination.material.size_attenuation, false)
  assert_eq(destination.center.x, 0.25)
  assert_eq(destination.center.y, 0.75)
  assert_eq(destination.count, 1)
  assert_eq(source.count, 4)
  assert_eq(physical_equal(destination.geometry, source.geometry), true)
  assert_eq(destination.node.position.y, 3.0)
  assert_eq(destination.node.render_order, 4)
  assert_eq(destination.node.children.length(), 1)
  assert_eq(destination.node.children[0].name, "marker")
  assert_eq(physical_equal(destination.node.children[0], child), false)
  match destination.node.sprite {
    None => assert_eq(false, true)
    Some(state) => {
      assert_eq(state.rotation, 0.5)
      assert_eq(state.size_attenuation, false)
      assert_eq(physical_equal(state.center, destination.center), true)
      assert_eq(state.center.x, 0.25)
    }
  }
  ignore(destination.center.set(0.1, 0.75))
  assert_eq(source.center.x, 0.25)
  let bare = @objects.Sprite::new(@materials.SpriteMaterial::new())
  ignore(bare.copy(source, recursive=false))
  assert_eq(bare.node.children.length(), 0)
  assert_eq(bare.node.position.y, 3.0)
  assert_eq(bare.center.x, 0.25)
  assert_eq(bare.material.rotation, 0.5)
  assert_eq(bare.count, 1)
}

///|
test "Sprite.clone copies the center and keeps count at one" {
  let material = @materials.SpriteMaterial::new(
    rotation=0.5,
    size_attenuation=false,
  )
  let source = @objects.Sprite::new(material)
  ignore(source.center.set(0.25, 0.75))
  source.count = 4
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  source.node.render_order = 4
  let child = @core.Object3D::new()
  child.name = "marker"
  ignore(source.node.add(child))
  let cloned = source.clone()
  assert_eq(physical_equal(cloned, source), false)
  assert_eq(physical_equal(cloned.material, material), true)
  assert_eq(cloned.material.rotation, 0.5)
  assert_eq(cloned.material.size_attenuation, false)
  assert_eq(cloned.center.x, 0.25)
  assert_eq(cloned.center.y, 0.75)
  assert_eq(cloned.count, 1)
  assert_eq(source.count, 4)
  assert_eq(physical_equal(cloned.geometry, source.geometry), true)
  assert_eq(cloned.node.position.y, 3.0)
  assert_eq(cloned.node.render_order, 4)
  assert_eq(cloned.node.children.length(), 1)
  assert_eq(cloned.node.children[0].name, "marker")
  assert_eq(physical_equal(cloned.node.children[0], child), false)
  match cloned.node.sprite {
    None => assert_eq(false, true)
    Some(state) => {
      assert_eq(state.rotation, 0.5)
      assert_eq(state.size_attenuation, false)
      assert_eq(physical_equal(state.center, cloned.center), true)
      assert_eq(state.center.x, 0.25)
    }
  }
  ignore(cloned.center.set(0.1, 0.75))
  assert_eq(source.center.x, 0.25)
  let bare = source.clone(recursive=false)
  assert_eq(bare.node.children.length(), 0)
  assert_eq(bare.center.x, 0.25)
  assert_eq(bare.count, 1)
  assert_eq(source.node.children.length(), 1)
  assert_eq(source.count, 4)
}

///|
test "sprite raycast hits the camera-facing quad" {
  let sprite = @objects.Sprite::new(@materials.SpriteMaterial::new())
  ignore(sprite.node.position.set(0.0, 0.0, -1.0))
  sprite.node.update_matrix_world()
  let camera = @core.Object3D::new(kind=@core.NodeKind::PerspectiveCamera)
  camera.camera = Some(@core.CameraState::perspective(50.0, 1.0, 0.1, 2000.0))
  camera.update_matrix_world()
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=-0.25),
    direction=@math.Vector3::new(z=-1.0),
  )
  raycaster.camera = Some(camera)
  let hits = raycaster.intersect_object(sprite.node)
  assert_eq(hits.length(), 1)
  assert_eq(hits[0].distance, 1.0)
  assert_eq(hits[0].point.x, 0.25)
  assert_eq(hits[0].point.y, -0.25)
  assert_eq(hits[0].point.z, -1.0)
  assert_eq(physical_equal(hits[0].object, sprite.node), true)
  match hits[0].uv {
    None => assert_eq(false, true)
    Some(uv) => {
      assert_eq(uv.x, 0.75)
      assert_eq(uv.y, 0.25)
    }
  }
  match hits[0].face {
    None => ()
    Some(_) => assert_eq(false, true)
  }
}

///|
test "panic sprite raycast without a camera" {
  let sprite = @objects.Sprite::new(@materials.SpriteMaterial::new())
  sprite.node.update_matrix_world()
  let raycaster = @core.Raycaster::new()
  ignore(raycaster.intersect_object(sprite.node))
}

///|
test "Sprite.geometry is one shared quad" {
  let first = @objects.Sprite::new(@materials.SpriteMaterial::new())
  let second = @objects.Sprite::new(@materials.SpriteMaterial::new())
  assert_eq(physical_equal(first.geometry, second.geometry), true)
  match first.geometry.get_attribute("position") {
    None => assert_eq(false, true)
    Some(position) => {
      assert_eq(position.count, 4)
      assert_eq(position.get_x(0), -0.5)
      assert_eq(position.get_y(0), -0.5)
      assert_eq(position.get_z(0), 0.0)
      assert_eq(position.get_x(1), 0.5)
      assert_eq(position.get_y(1), -0.5)
      assert_eq(position.get_x(2), 0.5)
      assert_eq(position.get_y(2), 0.5)
      assert_eq(position.get_x(3), -0.5)
      assert_eq(position.get_y(3), 0.5)
      assert_eq(position.get_z(3), 0.0)
    }
  }
  match first.geometry.get_attribute("uv") {
    None => assert_eq(false, true)
    Some(uv) => {
      assert_eq(uv.get_x(0), 0.0)
      assert_eq(uv.get_y(0), 0.0)
      assert_eq(uv.get_x(2), 1.0)
      assert_eq(uv.get_y(2), 1.0)
      assert_eq(uv.get_x(3), 0.0)
      assert_eq(uv.get_y(3), 1.0)
    }
  }
  match first.geometry.get_index() {
    None => assert_eq(false, true)
    Some(index) => {
      assert_eq(index.count, 6)
      assert_eq(index.get_x(0), 0.0)
      assert_eq(index.get_x(1), 1.0)
      assert_eq(index.get_x(2), 2.0)
      assert_eq(index.get_x(3), 0.0)
      assert_eq(index.get_x(4), 2.0)
      assert_eq(index.get_x(5), 3.0)
    }
  }
}

///|
test "Sprite.count defaults to one instance" {
  let sprite = @objects.Sprite::new(@materials.SpriteMaterial::new())
  assert_eq(sprite.count, 1)
  sprite.count = 4
  assert_eq(sprite.count, 4)
  let other = @objects.Sprite::new(@materials.SpriteMaterial::new())
  assert_eq(other.count, 1)
  assert_eq(sprite.count, 4)
}

///|
test "Sprite.intersectsFrustum uses a sphere around the sprite" {
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
  let inside = @objects.Sprite::new(@materials.SpriteMaterial::new())
  ignore(inside.node.position.set(0.5, 0.5, 0.5))
  inside.node.update_matrix_world()
  assert_eq(inside.intersects_frustum(frustum), true)
  let outside = @objects.Sprite::new(@materials.SpriteMaterial::new())
  ignore(outside.node.position.set(-2.0, 0.5, 0.5))
  outside.node.update_matrix_world()
  assert_eq(outside.intersects_frustum(frustum), false)
  assert_eq(inside.center.x, 0.5)
  assert_eq(inside.center.y, 0.5)
  assert_eq(frustum.planes[0].constant, 0.0)
}

///|
test "Sprite.intersectsFrustumArray uses only the counted frustums" {
  let sprite = @objects.Sprite::new(@materials.SpriteMaterial::new())
  ignore(sprite.node.position.set(0.5, 0.5, 0.5))
  sprite.node.update_matrix_world()
  let frustums = @math.FrustumArray::new()
  assert_eq(sprite.intersects_frustum_array(frustums), false)
  let cube = @math.Frustum::new()
  ignore(
    cube.set(
      @math.Plane::new(normal=@math.Vector3::new(x=1.0), constant=0.0),
      @math.Plane::new(normal=@math.Vector3::new(x=-1.0), constant=1.0),
      @math.Plane::new(normal=@math.Vector3::new(y=1.0), constant=0.0),
      @math.Plane::new(normal=@math.Vector3::new(y=-1.0), constant=1.0),
      @math.Plane::new(normal=@math.Vector3::new(z=1.0), constant=0.0),
      @math.Plane::new(normal=@math.Vector3::new(z=-1.0), constant=1.0),
    ),
  )
  frustums.frustums.push(cube)
  assert_eq(sprite.intersects_frustum_array(frustums), false)
  frustums.count = 1
  assert_eq(sprite.intersects_frustum_array(frustums), true)
  ignore(sprite.node.position.set(-2.0, 0.5, 0.5))
  sprite.node.update_matrix_world()
  assert_eq(sprite.intersects_frustum_array(frustums), false)
  let wide = @math.Frustum::new()
  ignore(
    wide.set(
      @math.Plane::new(constant=10.0),
      @math.Plane::new(constant=10.0),
      @math.Plane::new(constant=10.0),
      @math.Plane::new(constant=10.0),
      @math.Plane::new(constant=10.0),
      @math.Plane::new(constant=10.0),
    ),
  )
  frustums.frustums.push(wide)
  assert_eq(sprite.intersects_frustum_array(frustums), false)
  frustums.count = 2
  assert_eq(sprite.intersects_frustum_array(frustums), true)
}
