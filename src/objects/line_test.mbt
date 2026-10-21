///|
test "Line.copy shares geometry and material" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0, 1.0, 0.0, 0.0], 3),
    ),
  )
  let material = @materials.LineBasicMaterial::new(hex=0x00FF00)
  material.opacity = 0.25
  let source = @objects.Line::new(geometry, material)
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  source.node.render_order = 4
  let child = @core.Object3D::new()
  child.name = "marker"
  ignore(source.node.add(child))
  let destination = @objects.Line::new(
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
  let bare = @objects.Line::new(
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
test "Line.copy leaves morph weights in place" {
  let geometry = @core.BufferGeometry::new()
  let wide = @core.BufferAttribute::new([2.0, 0.0, 0.0], 3)
  wide.name = "wide"
  let tall = @core.BufferAttribute::new([0.0, 3.0, 0.0], 3)
  tall.name = "tall"
  geometry.morph_attributes.set("position", [wide, tall])
  let material = @materials.LineBasicMaterial::new()
  let source = @objects.Line::new(geometry, material)
  match source.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => weights[0] = 0.5
  }
  let destination = @objects.Line::new(
    @core.BufferGeometry::new(),
    @materials.LineBasicMaterial::new(),
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
  let same = @objects.Line::new(geometry, material)
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
  let kept = @objects.Line::new(geometry, material)
  match kept.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => weights[0] = 0.25
  }
  let empty = @objects.Line::new(
    @core.BufferGeometry::new(),
    @materials.LineBasicMaterial::new(),
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
test "Line.clone shares geometry and drops children when asked" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0, 1.0, 0.0, 0.0], 3),
    ),
  )
  let material = @materials.LineBasicMaterial::new(hex=0x00FF00)
  material.opacity = 0.25
  let source = @objects.Line::new(geometry, material)
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
test "Line.computeLineDistances accumulates segment lengths" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [0.0, 0.0, 0.0, 3.0, 0.0, 0.0, 0.0, 4.0, 0.0],
        3,
      ),
    ),
  )
  let line = @objects.Line::new(geometry, @materials.LineBasicMaterial::new())
  let computed = line.compute_line_distances()
  assert_eq(physical_equal(computed, line), true)
  match geometry.get_attribute("lineDistance") {
    None => assert_eq(false, true)
    Some(distances) => {
      assert_eq(distances.count, 3)
      assert_eq(distances.get_x(0), 0.0)
      assert_eq(distances.get_x(1), 3.0)
      assert_eq(distances.get_x(2), 8.0)
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
  let skipped = @objects.Line::new(indexed, @materials.LineBasicMaterial::new())
  ignore(skipped.compute_line_distances())
  match indexed.get_attribute("lineDistance") {
    None => ()
    Some(_) => assert_eq(false, true)
  }
}

///|
test "Line.updateMorphTargets indexes named targets" {
  let empty = @core.BufferGeometry::new()
  let bare = @objects.Line::new(empty, @materials.LineBasicMaterial::new())
  assert_eq(bare.morph_target_influences is None, true)
  assert_eq(bare.morph_target_dictionary is None, true)
  let geometry = @core.BufferGeometry::new()
  let wide = @core.BufferAttribute::new([2.0, 0.0, 0.0], 3)
  wide.name = "wide"
  let tall = @core.BufferAttribute::new([0.0, 3.0, 0.0], 3)
  tall.name = "tall"
  geometry.morph_attributes.set("position", [wide, tall])
  let line = @objects.Line::new(geometry, @materials.LineBasicMaterial::new())
  match line.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => {
      assert_eq(weights.length(), 2)
      assert_eq(weights[0], 0.0)
      assert_eq(weights[1], 0.0)
      weights[0] = 0.5
    }
  }
  match line.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => {
      assert_eq(dictionary.get("wide"), Some(0))
      assert_eq(dictionary.get("tall"), Some(1))
    }
  }
  let other = @objects.Line::new(
    geometry,
    @materials.LineBasicMaterial::new(hex=0x0000FF),
  )
  match other.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => assert_eq(weights[0], 0.0)
  }
  match line.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => assert_eq(weights[0], 0.5)
  }
  let late = @objects.Line::new(
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
  line.update_morph_targets()
  match line.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => {
      assert_eq(dictionary.get("0"), Some(0))
      assert_eq(dictionary.get("wide"), None)
    }
  }
  geometry.morph_attributes.clear()
  line.update_morph_targets()
  match line.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => assert_eq(dictionary.get("0"), Some(0))
  }
}

///|
test "panic Line.raycast material index is out of range" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0, 1.0, 0.0, 0.0], 3),
    ),
  )
  geometry.add_group(0, 2, material_index=5)
  let line = @objects.Line::new(geometry, @materials.LineBasicMaterial::new())
  line.set_materials([@materials.LineBasicMaterial::new()])
  line.node.update_matrix_world()
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.5, y=0.25),
    direction=@math.Vector3::new(y=-1.0),
  )
  ignore(raycaster.intersect_object(line.node))
}

