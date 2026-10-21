///|
test "Points.copy shares geometry and material" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.5, 0.0, 0.0], 3),
    ),
  )
  let material = @materials.PointsMaterial::new(size=2.0)
  let source = @objects.Points::new(geometry, material)
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  source.node.render_order = 4
  let child = @core.Object3D::new()
  child.name = "marker"
  ignore(source.node.add(child))
  let destination = @objects.Points::new(
    @core.BufferGeometry::new(),
    @materials.PointsMaterial::new(size=8.0),
  )
  let copied = destination.copy(source)
  assert_eq(physical_equal(copied, destination), true)
  assert_eq(physical_equal(destination.geometry, geometry), true)
  assert_eq(physical_equal(destination.material, material), true)
  assert_eq(destination.material.size, 2.0)
  assert_eq(destination.node.position.y, 3.0)
  assert_eq(destination.node.render_order, 4)
  assert_eq(destination.node.children.length(), 1)
  assert_eq(destination.node.children[0].name, "marker")
  assert_eq(physical_equal(destination.node.children[0], child), false)
  match destination.node.primitive {
    None => assert_eq(false, true)
    Some(binding) => {
      assert_eq(physical_equal(binding.geometry, geometry), true)
      assert_eq(binding.size, 2.0)
    }
  }
  let bare = @objects.Points::new(
    @core.BufferGeometry::new(),
    @materials.PointsMaterial::new(size=8.0),
  )
  ignore(bare.copy(source, recursive=false))
  assert_eq(bare.node.children.length(), 0)
  assert_eq(bare.node.position.y, 3.0)
  assert_eq(physical_equal(bare.geometry, geometry), true)
  assert_eq(bare.material.size, 2.0)
}

///|
test "Points.copy leaves morph weights in place" {
  let geometry = @core.BufferGeometry::new()
  let wide = @core.BufferAttribute::new([2.0, 0.0, 0.0], 3)
  wide.name = "wide"
  let tall = @core.BufferAttribute::new([0.0, 3.0, 0.0], 3)
  tall.name = "tall"
  geometry.morph_attributes.set("position", [wide, tall])
  let material = @materials.PointsMaterial::new()
  let source = @objects.Points::new(geometry, material)
  match source.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => weights[0] = 0.5
  }
  let destination = @objects.Points::new(
    @core.BufferGeometry::new(),
    @materials.PointsMaterial::new(),
  )
  ignore(destination.copy(source))
  assert_eq(destination.morph_target_influences is None, true)
  assert_eq(destination.morph_target_dictionary is None, true)
  match source.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => assert_eq(weights[0], 0.5)
  }
  match source.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => assert_eq(dictionary.get("wide"), Some(0))
  }
  let same = @objects.Points::new(geometry, material)
  ignore(same.copy(source))
  match same.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => {
      assert_eq(weights.length(), 2)
      assert_eq(weights[0], 0.0)
      assert_eq(weights[1], 0.0)
      weights[0] = 1.0
    }
  }
  match source.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => assert_eq(weights[0], 0.5)
  }
  let kept = @objects.Points::new(geometry, material)
  match kept.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => weights[0] = 0.25
  }
  let empty = @objects.Points::new(
    @core.BufferGeometry::new(),
    @materials.PointsMaterial::new(),
  )
  ignore(kept.copy(empty))
  match kept.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => assert_eq(weights[0], 0.25)
  }
  match kept.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => assert_eq(dictionary.get("wide"), Some(0))
  }
  let cloned = source.clone()
  match cloned.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => {
      assert_eq(weights[0], 0.0)
      assert_eq(weights[1], 0.0)
      weights[0] = 1.0
    }
  }
  match cloned.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => assert_eq(dictionary.get("tall"), Some(1))
  }
  match source.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => assert_eq(weights[0], 0.5)
  }
}

///|
test "Points.clone shares geometry and drops children when asked" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.5, 0.0, 0.0], 3),
    ),
  )
  let material = @materials.PointsMaterial::new(size=2.0)
  let source = @objects.Points::new(geometry, material)
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  source.node.render_order = 4
  let child = @core.Object3D::new()
  child.name = "marker"
  ignore(source.node.add(child))
  let cloned = source.clone()
  assert_eq(physical_equal(cloned, source), false)
  assert_eq(physical_equal(cloned.geometry, geometry), true)
  assert_eq(physical_equal(cloned.material, material), true)
  assert_eq(cloned.material.size, 2.0)
  assert_eq(cloned.node.position.y, 3.0)
  assert_eq(cloned.node.render_order, 4)
  assert_eq(cloned.node.children.length(), 1)
  assert_eq(cloned.node.children[0].name, "marker")
  assert_eq(physical_equal(cloned.node.children[0], child), false)
  match cloned.node.primitive {
    None => assert_eq(false, true)
    Some(binding) => {
      assert_eq(physical_equal(binding.geometry, geometry), true)
      assert_eq(binding.size, 2.0)
    }
  }
  let bare = source.clone(recursive=false)
  assert_eq(bare.node.children.length(), 0)
  assert_eq(bare.node.position.y, 3.0)
  assert_eq(physical_equal(bare.geometry, geometry), true)
  assert_eq(bare.material.size, 2.0)
  assert_eq(source.node.children.length(), 1)
}

///|
test "Points.updateMorphTargets indexes named targets" {
  let empty = @core.BufferGeometry::new()
  let bare = @objects.Points::new(empty, @materials.PointsMaterial::new())
  assert_eq(bare.morph_target_influences is None, true)
  assert_eq(bare.morph_target_dictionary is None, true)
  let geometry = @core.BufferGeometry::new()
  let wide = @core.BufferAttribute::new([2.0, 0.0, 0.0], 3)
  wide.name = "wide"
  let tall = @core.BufferAttribute::new([0.0, 3.0, 0.0], 3)
  tall.name = "tall"
  geometry.morph_attributes.set("position", [wide, tall])
  let points = @objects.Points::new(geometry, @materials.PointsMaterial::new())
  match points.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => {
      assert_eq(weights.length(), 2)
      assert_eq(weights[0], 0.0)
      assert_eq(weights[1], 0.0)
      weights[0] = 0.5
    }
  }
  match points.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => {
      assert_eq(dictionary.get("wide"), Some(0))
      assert_eq(dictionary.get("tall"), Some(1))
    }
  }
  let other = @objects.Points::new(geometry, @materials.PointsMaterial::new(size=4.0))
  match other.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => assert_eq(weights[0], 0.0)
  }
  match points.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => assert_eq(weights[0], 0.5)
  }
  let late = @objects.Points::new(
    @core.BufferGeometry::new(),
    @materials.PointsMaterial::new(),
  )
  late.geometry = geometry
  assert_eq(late.morph_target_influences is None, true)
  late.update_morph_targets()
  match late.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => assert_eq(dictionary.get("wide"), Some(0))
  }
  let unnamed = @core.BufferAttribute::new([1.0, 0.0, 0.0], 3)
  geometry.morph_attributes.set("position", [unnamed])
  points.update_morph_targets()
  match points.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => {
      assert_eq(dictionary.get("0"), Some(0))
      assert_eq(dictionary.get("wide"), None)
    }
  }
  geometry.morph_attributes.clear()
  points.update_morph_targets()
  match points.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => assert_eq(dictionary.get("0"), Some(0))
  }
}

///|
test "line raycast hits the nearest point on a segment" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0, 1.0, 0.0, 0.0], 3),
    ),
  )
  let line = @objects.Line::new(geometry, @materials.LineBasicMaterial::new())
  line.node.update_matrix_world()
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.5, y=0.5, z=0.0),
    direction=@math.Vector3::new(y=-1.0),
  )
  let hits = raycaster.intersect_object(line.node)
  assert_eq(hits.length(), 1)
  assert_eq(hits[0].distance, 0.5)
  assert_eq(hits[0].point.x, 0.5)
  assert_eq(hits[0].point.y, 0.0)
  assert_eq(hits[0].point.z, 0.0)
  match hits[0].index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 0)
  }
}

///|
test "points raycast records distance to the ray" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.5, 0.0, 0.0], 3),
    ),
  )
  let points = @objects.Points::new(geometry, @materials.PointsMaterial::new())
  points.node.update_matrix_world()
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(y=0.5),
    direction=@math.Vector3::new(y=-1.0),
  )
  let hits = raycaster.intersect_object(points.node)
  assert_eq(hits.length(), 1)
  assert_eq(hits[0].distance, 0.5)
  assert_eq(hits[0].point.x, 0.0)
  assert_eq(hits[0].point.y, 0.0)
  assert_eq(hits[0].point.z, 0.0)
  match hits[0].index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 0)
  }
  match hits[0].distance_to_ray {
    None => assert_eq(false, true)
    Some(distance) => assert_eq(distance, 0.5)
  }
  assert_eq(hits[0].material_index is None, true)
}

///|
test "point and line raycasts record the group material index" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0, 2.0, 0.0, 0.0], 3),
    ),
  )
  let points = @objects.Points::new(geometry, @materials.PointsMaterial::new())
  points.set_materials([
    @materials.PointsMaterial::new(),
    @materials.PointsMaterial::new(),
  ])
  points.node.update_matrix_world()
  let near = @core.Raycaster::new(
    origin=@math.Vector3::new(y=0.25),
    direction=@math.Vector3::new(y=-1.0),
  )
  assert_eq(near.intersect_object(points.node).length(), 0)
  geometry.add_group(0, 1, material_index=0)
  geometry.add_group(1, 1, material_index=1)
  let first = near.intersect_object(points.node)
  assert_eq(first.length(), 1)
  assert_eq(first[0].point.x, 0.0)
  assert_eq(first[0].point.y, 0.0)
  assert_eq(first[0].distance, 0.25)
  match first[0].index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 0)
  }
  match first[0].material_index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 0)
  }
  let far = @core.Raycaster::new(
    origin=@math.Vector3::new(x=2.0, y=0.25),
    direction=@math.Vector3::new(y=-1.0),
  )
  let second = far.intersect_object(points.node)
  assert_eq(second.length(), 1)
  assert_eq(second[0].point.x, 2.0)
  match second[0].index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 1)
  }
  match second[0].material_index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 1)
  }
  geometry.set_draw_range(1.0, 1.0)
  assert_eq(near.intersect_object(points.node).length(), 0)
  let kept = far.intersect_object(points.node)
  assert_eq(kept.length(), 1)
  match kept[0].material_index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 1)
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
  let line = @objects.Line::new(line_geometry, @materials.LineBasicMaterial::new())
  line.set_materials([
    @materials.LineBasicMaterial::new(),
    @materials.LineBasicMaterial::new(),
  ])
  line.node.update_matrix_world()
  line_geometry.add_group(0, 2, material_index=0)
  line_geometry.add_group(2, 2, material_index=1)
  let line_near = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.5, y=0.25),
    direction=@math.Vector3::new(y=-1.0),
  )
  let line_hit = line_near.intersect_object(line.node)
  assert_eq(line_hit.length(), 1)
  assert_eq(line_hit[0].point.x, 0.5)
  assert_eq(line_hit[0].point.y, 0.0)
  match line_hit[0].index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 0)
  }
  match line_hit[0].material_index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 0)
  }
  let line_far = @core.Raycaster::new(
    origin=@math.Vector3::new(x=2.5, y=0.25),
    direction=@math.Vector3::new(y=-1.0),
  )
  let line_second = line_far.intersect_object(line.node)
  assert_eq(line_second.length(), 1)
  assert_eq(line_second[0].point.x, 2.5)
  match line_second[0].index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 2)
  }
  match line_second[0].material_index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 1)
  }
  let segments = @objects.LineSegments::new(
    line_geometry,
    @materials.LineBasicMaterial::new(),
  )
  segments.set_materials([
    @materials.LineBasicMaterial::new(),
    @materials.LineBasicMaterial::new(),
  ])
  segments.node.update_matrix_world()
  let segment_hit = line_far.intersect_object(segments.node)
  assert_eq(segment_hit.length(), 1)
  match segment_hit[0].material_index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 1)
  }
}

///|
test "panic Points.raycast material index is out of range" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0], 3),
    ),
  )
  geometry.add_group(0, 1, material_index=5)
  let points = @objects.Points::new(geometry, @materials.PointsMaterial::new())
  points.set_materials([@materials.PointsMaterial::new()])
  points.node.update_matrix_world()
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(y=0.25),
    direction=@math.Vector3::new(y=-1.0),
  )
  ignore(raycaster.intersect_object(points.node))
}

