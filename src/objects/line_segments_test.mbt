///|
test "LineSegments.copy shares geometry and material" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0, 1.0, 0.0, 0.0], 3),
    ),
  )
  let material = @materials.LineBasicMaterial::new(hex=0x00FF00)
  material.opacity = 0.25
  let source = @objects.LineSegments::new(geometry, material)
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  source.node.render_order = 4
  let child = @core.Object3D::new()
  child.name = "marker"
  ignore(source.node.add(child))
  let destination = @objects.LineSegments::new(
    @core.BufferGeometry::new(),
    @materials.LineBasicMaterial::new(hex=0x0000FF),
  )
  let copied = destination.copy(source)
  assert_eq(physical_equal(copied, destination), true)
  assert_eq(physical_equal(destination.geometry, geometry), true)
  assert_eq(physical_equal(destination.material, material), true)
  assert_eq(destination.material.opacity, 0.25)
  assert_eq(destination.material.color.g, 1.0)
  assert_eq(destination.node.position.y, 3.0)
  assert_eq(destination.node.render_order, 4)
  assert_eq(destination.node.children.length(), 1)
  assert_eq(destination.node.children[0].name, "marker")
  assert_eq(physical_equal(destination.node.children[0], child), false)
  match destination.node.primitive {
    None => assert_eq(false, true)
    Some(binding) => {
      assert_eq(physical_equal(binding.geometry, geometry), true)
      assert_eq(binding.opacity, 0.25)
    }
  }
  let bare = @objects.LineSegments::new(
    @core.BufferGeometry::new(),
    @materials.LineBasicMaterial::new(hex=0x0000FF),
  )
  ignore(bare.copy(source, recursive=false))
  assert_eq(bare.node.children.length(), 0)
  assert_eq(bare.node.position.y, 3.0)
  assert_eq(physical_equal(bare.geometry, geometry), true)
  assert_eq(bare.material.opacity, 0.25)
}

///|
test "LineSegments.clone shares geometry and drops children when asked" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0, 1.0, 0.0, 0.0], 3),
    ),
  )
  let material = @materials.LineBasicMaterial::new(hex=0x00FF00)
  material.opacity = 0.25
  let source = @objects.LineSegments::new(geometry, material)
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  source.node.render_order = 4
  let child = @core.Object3D::new()
  child.name = "marker"
  ignore(source.node.add(child))
  let cloned = source.clone()
  assert_eq(physical_equal(cloned, source), false)
  assert_eq(physical_equal(cloned.geometry, geometry), true)
  assert_eq(physical_equal(cloned.material, material), true)
  assert_eq(cloned.material.opacity, 0.25)
  assert_eq(cloned.material.color.g, 1.0)
  assert_eq(cloned.node.position.y, 3.0)
  assert_eq(cloned.node.render_order, 4)
  assert_eq(cloned.node.children.length(), 1)
  assert_eq(cloned.node.children[0].name, "marker")
  assert_eq(physical_equal(cloned.node.children[0], child), false)
  match cloned.node.primitive {
    None => assert_eq(false, true)
    Some(binding) => {
      assert_eq(physical_equal(binding.geometry, geometry), true)
      assert_eq(binding.opacity, 0.25)
    }
  }
  let bare = source.clone(recursive=false)
  assert_eq(bare.node.children.length(), 0)
  assert_eq(bare.node.position.y, 3.0)
  assert_eq(physical_equal(bare.geometry, geometry), true)
  assert_eq(bare.material.opacity, 0.25)
  assert_eq(source.node.children.length(), 1)
}

///|
test "LineSegments.computeLineDistances accumulates each pair" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [0.0, 0.0, 0.0, 3.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 0.0],
        3,
      ),
    ),
  )
  let segments = @objects.LineSegments::new(
    geometry,
    @materials.LineBasicMaterial::new(),
  )
  let computed = segments.compute_line_distances()
  assert_eq(physical_equal(computed, segments), true)
  match geometry.get_attribute("lineDistance") {
    None => assert_eq(false, true)
    Some(distances) => {
      assert_eq(distances.count, 4)
      assert_eq(distances.get_x(0), 0.0)
      assert_eq(distances.get_x(1), 3.0)
      assert_eq(distances.get_x(2), 3.0)
      assert_eq(distances.get_x(3), 7.0)
    }
  }
  let indexed = @core.BufferGeometry::new()
  ignore(
    indexed.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0, 3.0, 0.0, 0.0], 3),
    ),
  )
  ignore(indexed.set_index_array([0, 1]))
  let skipped = @objects.LineSegments::new(
    indexed,
    @materials.LineBasicMaterial::new(),
  )
  ignore(skipped.compute_line_distances())
  match indexed.get_attribute("lineDistance") {
    None => ()
    Some(_) => assert_eq(false, true)
  }
}

///|
test "LineSegments.updateMorphTargets indexes named targets" {
  let empty = @core.BufferGeometry::new()
  let bare = @objects.LineSegments::new(
    empty,
    @materials.LineBasicMaterial::new(),
  )
  assert_eq(bare.morph_target_influences is None, true)
  assert_eq(bare.morph_target_dictionary is None, true)
  let geometry = @core.BufferGeometry::new()
  let wide = @core.BufferAttribute::new([2.0, 0.0, 0.0], 3)
  wide.name = "wide"
  let tall = @core.BufferAttribute::new([0.0, 3.0, 0.0], 3)
  tall.name = "tall"
  geometry.morph_attributes.set("position", [wide, tall])
  let segments = @objects.LineSegments::new(
    geometry,
    @materials.LineBasicMaterial::new(),
  )
  match segments.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => {
      assert_eq(weights.length(), 2)
      assert_eq(weights[0], 0.0)
      assert_eq(weights[1], 0.0)
      weights[0] = 0.5
    }
  }
  match segments.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => {
      assert_eq(dictionary.get("wide"), Some(0))
      assert_eq(dictionary.get("tall"), Some(1))
    }
  }
  let other = @objects.LineSegments::new(
    geometry,
    @materials.LineBasicMaterial::new(hex=0x0000FF),
  )
  match other.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => assert_eq(weights[0], 0.0)
  }
  match segments.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => assert_eq(weights[0], 0.5)
  }
  let late = @objects.LineSegments::new(
    @core.BufferGeometry::new(),
    @materials.LineBasicMaterial::new(),
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
  segments.update_morph_targets()
  match segments.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => {
      assert_eq(dictionary.get("0"), Some(0))
      assert_eq(dictionary.get("wide"), None)
    }
  }
  geometry.morph_attributes.clear()
  segments.update_morph_targets()
  match segments.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => assert_eq(dictionary.get("0"), Some(0))
  }
}
