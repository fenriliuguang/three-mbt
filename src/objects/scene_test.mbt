///|
test "scene holds a mesh node" {
  let scene = @scenes.Scene::new()
  let box = @geometries.BoxGeometry::new()
  let basic = @materials.MeshBasicMaterial::new(hex=0x00FF00)
  let mesh = @objects.Mesh::new(box.geometry, basic.material)
  ignore(scene.add(mesh))
  let mut meshes = 0
  let mut green = 0.0
  let mut positions = 0
  scene.node.traverse(fn(node) {
    match node.kind {
      @core.Mesh => {
        meshes = meshes + 1
        match node.mesh {
          None => ()
          Some(binding) => {
            green = binding.color.g
            positions = binding.geometry.get_attribute("position").unwrap().count
          }
        }
      }
      _ => ()
    }
  })
  assert_eq(meshes, 1)
  assert_eq(green, 1.0)
  assert_eq(positions, 24)
}

///|
test "getVertexPosition applies a relative morph" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 3),
    ),
  )
  let mesh = @objects.Mesh::new(geometry, @materials.Material::basic())
  let target = @math.Vector3::new()
  let written = mesh.node.get_vertex_position(1, target)
  assert_eq(physical_equal(written, target), true)
  assert_eq(target.x, 4.0)
  assert_eq(target.y, 5.0)
  assert_eq(target.z, 6.0)
  geometry.morph_targets_relative = true
  geometry.morph_attributes.set(
    "position",
    [@core.BufferAttribute::new([2.0, 0.0, 0.0], 3)],
  )
  mesh.node.morph = Some(@core.MorphState::{
    base_position: [1.0, 2.0, 3.0],
    base_normal: None,
    base_color: None,
    targets: [],
    weights: [0.5],
    shared: false,
  })
  ignore(mesh.node.get_vertex_position(0, target))
  assert_eq(target.x, 2.0)
  assert_eq(target.y, 2.0)
  assert_eq(target.z, 3.0)
}

///|
test "Mesh.count defaults to one instance" {
  let geometry = @core.BufferGeometry::new()
  let mesh = @objects.Mesh::new(geometry, @materials.Material::basic())
  assert_eq(mesh.count, 1)
  mesh.count = 4
  assert_eq(mesh.count, 4)
  let other = @objects.Mesh::new(geometry, @materials.Material::basic())
  assert_eq(other.count, 1)
  assert_eq(mesh.count, 4)
}

///|
test "Mesh.updateMorphTargets indexes named targets" {
  let empty = @core.BufferGeometry::new()
  let bare = @objects.Mesh::new(empty, @materials.Material::basic())
  assert_eq(bare.morph_target_influences is None, true)
  assert_eq(bare.morph_target_dictionary is None, true)
  let geometry = @core.BufferGeometry::new()
  let wide = @core.BufferAttribute::new([2.0, 0.0, 0.0], 3)
  wide.name = "wide"
  let tall = @core.BufferAttribute::new([0.0, 3.0, 0.0], 3)
  tall.name = "tall"
  geometry.morph_attributes.set("position", [wide, tall])
  let mesh = @objects.Mesh::new(geometry, @materials.Material::basic())
  match mesh.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => {
      assert_eq(weights.length(), 2)
      assert_eq(weights[0], 0.0)
      assert_eq(weights[1], 0.0)
      weights[0] = 0.5
    }
  }
  match mesh.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => {
      assert_eq(dictionary.get("wide"), Some(0))
      assert_eq(dictionary.get("tall"), Some(1))
    }
  }
  let other = @objects.Mesh::new(geometry, @materials.Material::basic())
  match other.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => assert_eq(weights[0], 0.0)
  }
  match mesh.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => assert_eq(weights[0], 0.5)
  }
  let late = @objects.Mesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
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
  mesh.update_morph_targets()
  match mesh.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => {
      assert_eq(dictionary.get("0"), Some(0))
      assert_eq(dictionary.get("wide"), None)
    }
  }
  match mesh.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => {
      assert_eq(weights.length(), 1)
      assert_eq(weights[0], 0.0)
    }
  }
  geometry.morph_attributes.clear()
  mesh.update_morph_targets()
  match mesh.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => assert_eq(dictionary.get("0"), Some(0))
  }
  match mesh.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => assert_eq(weights[0], 0.0)
  }
}

///|
test "Mesh.copy shares geometry and material" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.5, 0.0, 0.0], 3),
    ),
  )
  let material = @materials.Material::basic()
  let source = @objects.Mesh::new(geometry, material)
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  source.node.render_order = 4
  let child = @core.Object3D::new()
  child.name = "marker"
  ignore(source.node.add(child))
  let destination = @objects.Mesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::lambert(),
  )
  let copied = destination.copy(source)
  assert_eq(physical_equal(copied, destination), true)
  assert_eq(physical_equal(destination.geometry, geometry), true)
  assert_eq(physical_equal(destination.material, material), true)
  assert_eq(destination.node.position.y, 3.0)
  assert_eq(destination.node.render_order, 4)
  assert_eq(destination.node.children.length(), 1)
  assert_eq(destination.node.children[0].name, "marker")
  assert_eq(physical_equal(destination.node.children[0], child), false)
  match destination.node.mesh {
    None => assert_eq(false, true)
    Some(binding) =>
      assert_eq(physical_equal(binding.geometry, geometry), true)
  }
  let bare = @objects.Mesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::lambert(),
  )
  ignore(bare.copy(source, recursive=false))
  assert_eq(bare.node.children.length(), 0)
  assert_eq(bare.node.position.y, 3.0)
  assert_eq(physical_equal(bare.geometry, geometry), true)
}

///|
test "Mesh.copy copies morph weights" {
  let geometry = @core.BufferGeometry::new()
  let wide = @core.BufferAttribute::new([2.0, 0.0, 0.0], 3)
  wide.name = "wide"
  let tall = @core.BufferAttribute::new([0.0, 3.0, 0.0], 3)
  tall.name = "tall"
  geometry.morph_attributes.set("position", [wide, tall])
  let source = @objects.Mesh::new(geometry, @materials.Material::basic())
  match source.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => weights[0] = 0.5
  }
  let destination = @objects.Mesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::lambert(),
  )
  ignore(destination.copy(source))
  match destination.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => {
      assert_eq(weights.length(), 2)
      assert_eq(weights[0], 0.5)
      assert_eq(weights[1], 0.0)
      weights[0] = 1.0
    }
  }
  match destination.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => {
      assert_eq(dictionary.get("wide"), Some(0))
      assert_eq(dictionary.get("tall"), Some(1))
      dictionary.set("wide", 9)
    }
  }
  match source.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => assert_eq(weights[0], 0.5)
  }
  match source.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => assert_eq(dictionary.get("wide"), Some(0))
  }
  let kept = @objects.Mesh::new(geometry, @materials.Material::basic())
  match kept.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => weights[0] = 0.25
  }
  let empty = @objects.Mesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
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
      assert_eq(weights[0], 0.5)
      assert_eq(weights[1], 0.0)
      weights[0] = 0.0
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
test "LineLoop.copy shares geometry and material" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0, 1.0, 0.0, 0.0], 3),
    ),
  )
  let material = @materials.LineBasicMaterial::new(hex=0x00FF00)
  material.opacity = 0.25
  let source = @objects.LineLoop::new(geometry, material)
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  source.node.render_order = 4
  let child = @core.Object3D::new()
  child.name = "marker"
  ignore(source.node.add(child))
  let destination = @objects.LineLoop::new(
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
  let bare = @objects.LineLoop::new(
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
test "LineLoop.clone shares geometry and drops children when asked" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0, 1.0, 0.0, 0.0], 3),
    ),
  )
  let material = @materials.LineBasicMaterial::new(hex=0x00FF00)
  material.opacity = 0.25
  let source = @objects.LineLoop::new(geometry, material)
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
test "LineLoop.computeLineDistances follows the open line" {
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
  let closed = @objects.LineLoop::new(geometry, @materials.LineBasicMaterial::new())
  let computed = closed.compute_line_distances()
  assert_eq(physical_equal(computed, closed), true)
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
  let skipped = @objects.LineLoop::new(indexed, @materials.LineBasicMaterial::new())
  ignore(skipped.compute_line_distances())
  match indexed.get_attribute("lineDistance") {
    None => ()
    Some(_) => assert_eq(false, true)
  }
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
test "LineSegments.updateMorphTargets indexes named targets" {
  let empty = @core.BufferGeometry::new()
  let bare = @objects.LineSegments::new(empty, @materials.LineBasicMaterial::new())
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

///|
test "LineLoop.updateMorphTargets indexes named targets" {
  let empty = @core.BufferGeometry::new()
  let bare = @objects.LineLoop::new(empty, @materials.LineBasicMaterial::new())
  assert_eq(bare.morph_target_influences is None, true)
  assert_eq(bare.morph_target_dictionary is None, true)
  let geometry = @core.BufferGeometry::new()
  let wide = @core.BufferAttribute::new([2.0, 0.0, 0.0], 3)
  wide.name = "wide"
  let tall = @core.BufferAttribute::new([0.0, 3.0, 0.0], 3)
  tall.name = "tall"
  geometry.morph_attributes.set("position", [wide, tall])
  let closed = @objects.LineLoop::new(geometry, @materials.LineBasicMaterial::new())
  match closed.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => {
      assert_eq(weights.length(), 2)
      assert_eq(weights[0], 0.0)
      assert_eq(weights[1], 0.0)
      weights[0] = 0.5
    }
  }
  match closed.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => {
      assert_eq(dictionary.get("wide"), Some(0))
      assert_eq(dictionary.get("tall"), Some(1))
    }
  }
  let other = @objects.LineLoop::new(
    geometry,
    @materials.LineBasicMaterial::new(hex=0x0000FF),
  )
  match other.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => assert_eq(weights[0], 0.0)
  }
  match closed.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => assert_eq(weights[0], 0.5)
  }
  let late = @objects.LineLoop::new(
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
  closed.update_morph_targets()
  match closed.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => {
      assert_eq(dictionary.get("0"), Some(0))
      assert_eq(dictionary.get("wide"), None)
    }
  }
  geometry.morph_attributes.clear()
  closed.update_morph_targets()
  match closed.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => assert_eq(dictionary.get("0"), Some(0))
  }
}

///|
test "InstancedMesh.setMorphAt stores base influence and weights" {
  let geometry = @core.BufferGeometry::new()
  let mesh = @objects.InstancedMesh::new(geometry, @materials.Material::basic(), 2)
  assert_eq(mesh.morph_texture is None, true)
  let source = @objects.Mesh::new(geometry, @materials.Material::basic())
  source.morph_target_influences = Some([0.25, 0.5])
  let written = mesh.set_morph_at(1, source)
  assert_eq(physical_equal(written, mesh), true)
  match mesh.morph_texture {
    None => assert_eq(false, true)
    Some(data) => {
      assert_eq(data.length(), 6)
      assert_eq(data[0], 0.0)
      assert_eq(data[1], 0.0)
      assert_eq(data[2], 0.0)
      assert_eq(data[3], 0.25)
      assert_eq(data[4], 0.25)
      assert_eq(data[5], 0.5)
    }
  }
  geometry.morph_targets_relative = true
  ignore(mesh.set_morph_at(0, source))
  match mesh.morph_texture {
    None => assert_eq(false, true)
    Some(data) => {
      assert_eq(data.length(), 6)
      assert_eq(data[0], 1.0)
      assert_eq(data[1], 0.25)
      assert_eq(data[2], 0.5)
      assert_eq(data[3], 0.25)
      assert_eq(data[4], 0.25)
      assert_eq(data[5], 0.5)
    }
  }
}

///|
test "InstancedMesh.getMorphAt reads weights and skips the base" {
  let geometry = @core.BufferGeometry::new()
  let mesh = @objects.InstancedMesh::new(geometry, @materials.Material::basic(), 2)
  let source = @objects.Mesh::new(geometry, @materials.Material::basic())
  source.morph_target_influences = Some([0.25, 0.5])
  ignore(mesh.set_morph_at(1, source))
  geometry.morph_targets_relative = true
  ignore(mesh.set_morph_at(0, source))
  let reader = @objects.Mesh::new(geometry, @materials.Material::basic())
  reader.morph_target_influences = Some([9.0, 9.0])
  mesh.get_morph_at(1, reader)
  match reader.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => {
      assert_eq(weights[0], 0.25)
      assert_eq(weights[1], 0.5)
    }
  }
  mesh.get_morph_at(0, reader)
  match reader.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => {
      assert_eq(weights[0], 0.25)
      assert_eq(weights[1], 0.5)
    }
  }
  match mesh.morph_texture {
    None => assert_eq(false, true)
    Some(data) => assert_eq(data[0], 1.0)
  }
  match source.morph_target_influences {
    None => assert_eq(false, true)
    Some(weights) => {
      assert_eq(weights[0], 0.25)
      assert_eq(weights[1], 0.5)
    }
  }
}

///|
test "InstancedMesh.copy clones the morph buffer" {
  let geometry = @core.BufferGeometry::new()
  let source = @objects.InstancedMesh::new(
    geometry,
    @materials.Material::basic(),
    2,
  )
  let weights = @objects.Mesh::new(geometry, @materials.Material::basic())
  weights.morph_target_influences = Some([0.25, 0.5])
  ignore(source.set_morph_at(1, weights))
  let destination = @objects.InstancedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::lambert(),
    1,
  )
  ignore(destination.copy(source))
  match destination.morph_texture {
    None => assert_eq(false, true)
    Some(data) => {
      assert_eq(data.length(), 6)
      assert_eq(data[0], 0.0)
      assert_eq(data[3], 0.25)
      assert_eq(data[4], 0.25)
      assert_eq(data[5], 0.5)
      data[3] = 1.0
    }
  }
  match source.morph_texture {
    None => assert_eq(false, true)
    Some(data) => assert_eq(data[3], 0.25)
  }
  let empty = @objects.InstancedMesh::new(
    geometry,
    @materials.Material::basic(),
    2,
  )
  ignore(destination.copy(empty))
  match destination.morph_texture {
    None => assert_eq(false, true)
    Some(data) => assert_eq(data[3], 1.0)
  }
  let cloned = source.clone()
  match cloned.morph_texture {
    None => assert_eq(false, true)
    Some(data) => {
      assert_eq(data[3], 0.25)
      assert_eq(data[5], 0.5)
      data[3] = 0.0
    }
  }
  match source.morph_texture {
    None => assert_eq(false, true)
    Some(data) => assert_eq(data[3], 0.25)
  }
}

///|
test "InstancedMesh.dispose clears the morph buffer" {
  let geometry = @core.BufferGeometry::new()
  let mesh = @objects.InstancedMesh::new(geometry, @materials.Material::basic(), 2)
  let weights = @objects.Mesh::new(geometry, @materials.Material::basic())
  weights.morph_target_influences = Some([0.25, 0.5])
  ignore(mesh.set_morph_at(1, weights))
  let cloned = mesh.clone()
  let hits = Ref::Ref(0)
  let kind = Ref::Ref("")
  mesh.node.add_event_listener("dispose", fn(event) {
    hits.val = hits.val + 1
    kind.val = event.kind
  })
  mesh.dispose()
  assert_eq(hits.val, 1)
  assert_eq(kind.val, "dispose")
  assert_eq(mesh.morph_texture is None, true)
  match cloned.morph_texture {
    None => assert_eq(false, true)
    Some(data) => {
      assert_eq(data[3], 0.25)
      assert_eq(data[5], 0.5)
    }
  }
  let bare = @objects.InstancedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
    1,
  )
  bare.dispose()
  assert_eq(bare.morph_texture is None, true)
}

///|
test "InstancedMesh.updateMorphTargets leaves the morph buffer alone" {
  let geometry = @core.BufferGeometry::new()
  let wide = @core.BufferAttribute::new([2.0, 0.0, 0.0], 3)
  wide.name = "wide"
  let tall = @core.BufferAttribute::new([0.0, 3.0, 0.0], 3)
  tall.name = "tall"
  geometry.morph_attributes.set("position", [wide, tall])
  let mesh = @objects.InstancedMesh::new(geometry, @materials.Material::basic(), 2)
  mesh.update_morph_targets()
  assert_eq(mesh.morph_texture is None, true)
  assert_eq(mesh.instances.count, 2)
  let plain = @objects.Mesh::new(geometry, @materials.Material::basic())
  match plain.morph_target_dictionary {
    None => assert_eq(false, true)
    Some(dictionary) => assert_eq(dictionary.get("wide"), Some(0))
  }
  let weights = @objects.Mesh::new(geometry, @materials.Material::basic())
  weights.morph_target_influences = Some([0.25, 0.5])
  ignore(mesh.set_morph_at(1, weights))
  mesh.update_morph_targets()
  match mesh.morph_texture {
    None => assert_eq(false, true)
    Some(data) => {
      assert_eq(data.length(), 6)
      assert_eq(data[3], 0.25)
      assert_eq(data[4], 0.25)
      assert_eq(data[5], 0.5)
    }
  }
}

///|
test "Group.copy clones the child and keeps the transform" {
  let source = @objects.Group::new()
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  source.node.render_order = 4
  let child = @core.Object3D::new()
  child.name = "marker"
  ignore(source.add(child))
  let destination = @objects.Group::new()
  ignore(destination.node.position.set(1.0, 0.0, 0.0))
  let copied = destination.copy(source)
  assert_eq(physical_equal(copied, destination), true)
  assert_eq(destination.node.position.y, 3.0)
  assert_eq(destination.node.position.x, 0.0)
  assert_eq(destination.node.render_order, 4)
  assert_eq(destination.node.children.length(), 1)
  assert_eq(destination.node.children[0].name, "marker")
  assert_eq(physical_equal(destination.node.children[0], child), false)
  assert_eq(source.node.children.length(), 1)
  let bare = @objects.Group::new()
  ignore(bare.copy(source, recursive=false))
  assert_eq(bare.node.children.length(), 0)
  assert_eq(bare.node.position.y, 3.0)
  assert_eq(bare.node.render_order, 4)
}

///|
test "Group.clone keeps the transform and drops children when asked" {
  let source = @objects.Group::new()
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  source.node.render_order = 4
  let child = @core.Object3D::new()
  child.name = "marker"
  ignore(source.add(child))
  let cloned = source.clone()
  assert_eq(physical_equal(cloned, source), false)
  assert_eq(cloned.node.position.y, 3.0)
  assert_eq(cloned.node.position.x, 0.0)
  assert_eq(cloned.node.render_order, 4)
  assert_eq(cloned.node.children.length(), 1)
  assert_eq(cloned.node.children[0].name, "marker")
  assert_eq(physical_equal(cloned.node.children[0], child), false)
  let bare = source.clone(recursive=false)
  assert_eq(bare.node.children.length(), 0)
  assert_eq(bare.node.position.y, 3.0)
  assert_eq(bare.node.render_order, 4)
  assert_eq(source.node.children.length(), 1)
  assert_eq(source.node.position.y, 3.0)
}

///|
test "Bone adds a child bone at y 5" {
  let root = @objects.Bone::new()
  let child = @objects.Bone::new()
  ignore(root.add(child))
  ignore(child.node.position.set(0.0, 5.0, 0.0))
  assert_eq(root.node.kind is @core.NodeKind::Bone, true)
  assert_eq(child.node.kind is @core.NodeKind::Bone, true)
  assert_eq(child.node.position.y, 5.0)
  assert_eq(root.node.children.length(), 1)
  assert_eq(physical_equal(root.node.children[0], child.node), true)
  assert_eq(root.node.children[0].position.y, 5.0)
}

///|
test "Bone.copy clones the child and keeps the transform" {
  let source = @objects.Bone::new()
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  source.node.render_order = 4
  let child = @objects.Bone::new()
  child.node.name = "marker"
  ignore(source.add(child))
  let destination = @objects.Bone::new()
  ignore(destination.node.position.set(1.0, 0.0, 0.0))
  let copied = destination.copy(source)
  assert_eq(physical_equal(copied, destination), true)
  assert_eq(destination.node.kind is @core.NodeKind::Bone, true)
  assert_eq(destination.node.position.y, 3.0)
  assert_eq(destination.node.position.x, 0.0)
  assert_eq(destination.node.render_order, 4)
  assert_eq(destination.node.children.length(), 1)
  assert_eq(destination.node.children[0].name, "marker")
  assert_eq(destination.node.children[0].kind is @core.NodeKind::Bone, true)
  assert_eq(physical_equal(destination.node.children[0], child.node), false)
  assert_eq(source.node.children.length(), 1)
  let bare = @objects.Bone::new()
  ignore(bare.copy(source, recursive=false))
  assert_eq(bare.node.children.length(), 0)
  assert_eq(bare.node.position.y, 3.0)
  assert_eq(bare.node.render_order, 4)
  assert_eq(source.node.children[0].name, "marker")
}

///|
test "Bone.clone keeps the transform and drops children when asked" {
  let source = @objects.Bone::new()
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  source.node.render_order = 4
  let child = @objects.Bone::new()
  child.node.name = "marker"
  ignore(source.add(child))
  let cloned = source.clone()
  assert_eq(physical_equal(cloned, source), false)
  assert_eq(cloned.node.kind is @core.NodeKind::Bone, true)
  assert_eq(cloned.node.position.y, 3.0)
  assert_eq(cloned.node.position.x, 0.0)
  assert_eq(cloned.node.render_order, 4)
  assert_eq(cloned.node.children.length(), 1)
  assert_eq(cloned.node.children[0].name, "marker")
  assert_eq(cloned.node.children[0].kind is @core.NodeKind::Bone, true)
  assert_eq(physical_equal(cloned.node.children[0], child.node), false)
  let bare = source.clone(recursive=false)
  assert_eq(bare.node.children.length(), 0)
  assert_eq(bare.node.position.y, 3.0)
  assert_eq(bare.node.render_order, 4)
  assert_eq(source.node.children.length(), 1)
  assert_eq(source.node.position.y, 3.0)
}

///|
test "Skeleton inverts the current world matrices" {
  let shoulder = @objects.Bone::new()
  let elbow = @objects.Bone::new()
  let hand = @objects.Bone::new()
  ignore(shoulder.add(elbow))
  ignore(elbow.add(hand))
  ignore(shoulder.node.position.set(0.0, -5.0, 0.0))
  ignore(elbow.node.position.set(0.0, 0.0, 0.0))
  ignore(hand.node.position.set(0.0, 5.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  let listed = [shoulder, elbow, hand]
  let inverses = []
  let arm = @objects.Skeleton::new(bones=listed, bone_inverses=inverses)
  listed.push(@objects.Bone::new())
  assert_eq(arm.bones.length(), 3)
  assert_eq(physical_equal(arm.bones[0], shoulder), true)
  assert_eq(physical_equal(arm.bones[2], hand), true)
  assert_eq(arm.bones[0].node.position.y, -5.0)
  assert_eq(arm.bones[1].node.position.y, 0.0)
  assert_eq(arm.bones[2].node.position.y, 5.0)
  assert_eq(physical_equal(arm.bone_inverses, inverses), true)
  assert_eq(inverses.length(), 3)
  assert_eq(inverses[0].elements[13], 5.0)
  assert_eq(inverses[1].elements[13], 5.0)
  assert_eq(inverses[2].elements[0], 1.0)
  assert_eq(inverses[2].elements[13], 0.0)
  assert_eq(arm.bone_matrices.length(), 48)
  assert_eq(arm.bone_matrices[0], 0.0)
  assert_eq(arm.bone_matrices[47], 0.0)
  assert_eq(arm.uuid.length(), 36)
  let empty = @objects.Skeleton::new()
  assert_eq(empty.bones.length(), 0)
  assert_eq(empty.bone_inverses.length(), 0)
  assert_eq(empty.bone_matrices.length(), 0)
  assert_eq(empty.uuid.length(), 36)
  arm.bone_matrices[0] = 4.0
  arm.init()
  assert_eq(arm.bone_matrices[0], 0.0)
  assert_eq(arm.bone_matrices.length(), 48)
  assert_eq(arm.bone_inverses[0].elements[13], 5.0)
  ignore(shoulder.node.position.set(0.0, -2.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  arm.calculate_inverses()
  assert_eq(arm.bone_inverses[0].elements[13], 2.0)
  assert_eq(arm.bone_inverses[1].elements[13], 2.0)
  assert_eq(arm.bone_inverses[2].elements[13], -3.0)
}

///|
test "Skeleton.init replaces a mismatched inverse list" {
  let shoulder = @objects.Bone::new()
  let elbow = @objects.Bone::new()
  let hand = @objects.Bone::new()
  let one = @math.Matrix4::new()
  ignore(
    one.set(
      1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 9.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0,
    ),
  )
  let mismatched = [one]
  let replaced = @objects.Skeleton::new(
    bones=[shoulder, elbow, hand],
    bone_inverses=mismatched,
  )
  assert_eq(physical_equal(replaced.bone_inverses, mismatched), false)
  assert_eq(replaced.bone_inverses.length(), 3)
  assert_eq(replaced.bone_inverses[0].elements[0], 1.0)
  assert_eq(replaced.bone_inverses[0].elements[13], 0.0)
  assert_eq(replaced.bone_inverses[2].elements[13], 0.0)
  assert_eq(mismatched.length(), 1)
  assert_eq(mismatched[0].elements[13], 9.0)
  assert_eq(replaced.bone_matrices.length(), 48)
}

///|
test "Skeleton.pose restores the bind positions" {
  let shoulder = @objects.Bone::new()
  let elbow = @objects.Bone::new()
  let hand = @objects.Bone::new()
  ignore(shoulder.add(elbow))
  ignore(elbow.add(hand))
  ignore(shoulder.node.position.set(0.0, -5.0, 0.0))
  ignore(elbow.node.position.set(0.0, 0.0, 0.0))
  ignore(hand.node.position.set(0.0, 5.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  let arm = @objects.Skeleton::new(bones=[shoulder, elbow, hand])
  ignore(shoulder.node.position.set(0.0, -2.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  assert_eq(shoulder.node.position.y, -2.0)
  arm.pose()
  assert_eq(shoulder.node.position.y, -5.0)
  assert_eq(elbow.node.position.y, 0.0)
  assert_eq(hand.node.position.y, 5.0)
  assert_eq(shoulder.node.matrix_world.elements[13], -5.0)
  assert_eq(elbow.node.matrix_world.elements[13], -5.0)
  assert_eq(hand.node.matrix_world.elements[13], 0.0)
  assert_eq(shoulder.node.quaternion.w, 1.0)
  assert_eq(shoulder.node.quaternion.x, 0.0)
  assert_eq(elbow.node.scale.y, 1.0)
  assert_eq(hand.node.scale.y, 1.0)
  assert_eq(arm.bone_inverses[0].elements[13], 5.0)
  let group = @objects.Group::new()
  ignore(group.node.position.set(0.0, 10.0, 0.0))
  let lone = @objects.Bone::new()
  ignore(lone.node.position.set(0.0, 5.0, 0.0))
  ignore(group.add(lone))
  group.node.update_matrix_world(force=true)
  let flat = @objects.Skeleton::new(bones=[lone])
  flat.pose()
  assert_eq(lone.node.position.y, 15.0)
  @objects.Skeleton::new().pose()
}

///|
test "Skeleton.update writes bind matrices into the buffer" {
  let shoulder = @objects.Bone::new()
  let elbow = @objects.Bone::new()
  let hand = @objects.Bone::new()
  ignore(shoulder.add(elbow))
  ignore(elbow.add(hand))
  ignore(shoulder.node.position.set(0.0, -5.0, 0.0))
  ignore(elbow.node.position.set(0.0, 0.0, 0.0))
  ignore(hand.node.position.set(0.0, 5.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  let arm = @objects.Skeleton::new(bones=[shoulder, elbow, hand])
  arm.update()
  assert_eq(arm.bone_matrices.length(), 48)
  assert_eq(arm.bone_matrices[0], 1.0)
  assert_eq(arm.bone_matrices[13], 0.0)
  assert_eq(arm.bone_matrices[15], 1.0)
  assert_eq(arm.bone_matrices[16], 1.0)
  assert_eq(arm.bone_matrices[29], 0.0)
  assert_eq(arm.bone_matrices[32], 1.0)
  assert_eq(arm.bone_matrices[45], 0.0)
  assert_eq(arm.bone_matrices[47], 1.0)
  ignore(shoulder.node.position.set(0.0, -2.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  arm.update()
  assert_eq(arm.bone_matrices[0], 1.0)
  assert_eq(arm.bone_matrices[13], 3.0)
  assert_eq(arm.bone_matrices[29], 3.0)
  assert_eq(arm.bone_matrices[45], 3.0)
  assert_eq(arm.bone_matrices[47], 1.0)
  assert_eq(shoulder.node.position.y, -2.0)
  let empty = @objects.Skeleton::new()
  empty.update()
  assert_eq(empty.bone_matrices.length(), 0)
}

///|
test "Skeleton.clone shares inverses and clears the matrix buffer" {
  let shoulder = @objects.Bone::new()
  let elbow = @objects.Bone::new()
  let hand = @objects.Bone::new()
  ignore(shoulder.add(elbow))
  ignore(elbow.add(hand))
  ignore(shoulder.node.position.set(0.0, -5.0, 0.0))
  ignore(elbow.node.position.set(0.0, 0.0, 0.0))
  ignore(hand.node.position.set(0.0, 5.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  let arm = @objects.Skeleton::new(bones=[shoulder, elbow, hand])
  ignore(shoulder.node.position.set(0.0, -2.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  arm.update()
  assert_eq(arm.bone_matrices[13], 3.0)
  let cloned = arm.clone()
  assert_eq(physical_equal(cloned, arm), false)
  assert_eq(cloned.bones.length(), 3)
  assert_eq(physical_equal(cloned.bones[0], shoulder), true)
  assert_eq(physical_equal(cloned.bones[2], hand), true)
  cloned.bones.push(@objects.Bone::new())
  assert_eq(cloned.bones.length(), 4)
  assert_eq(arm.bones.length(), 3)
  assert_eq(physical_equal(cloned.bone_inverses, arm.bone_inverses), true)
  assert_eq(cloned.bone_inverses[0].elements[13], 5.0)
  ignore(
    cloned.bone_inverses[0].set(
      1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 7.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0,
    ),
  )
  assert_eq(arm.bone_inverses[0].elements[13], 7.0)
  assert_eq(cloned.bone_matrices.length(), 48)
  assert_eq(cloned.bone_matrices[13], 0.0)
  assert_eq(arm.bone_matrices[13], 3.0)
  let empty = @objects.Skeleton::new()
  let copied = empty.clone()
  assert_eq(copied.bones.length(), 0)
  assert_eq(copied.bone_matrices.length(), 0)
  assert_eq(physical_equal(copied.bone_inverses, empty.bone_inverses), true)
}

///|
test "Skeleton.getBoneByName returns the first match" {
  let shoulder = @objects.Bone::new()
  let elbow = @objects.Bone::new()
  let hand = @objects.Bone::new()
  shoulder.node.name = "shoulder"
  elbow.node.name = "elbow"
  ignore(shoulder.node.position.set(0.0, -5.0, 0.0))
  ignore(elbow.node.position.set(0.0, 0.0, 0.0))
  ignore(hand.node.position.set(0.0, 5.0, 0.0))
  let arm = @objects.Skeleton::new(bones=[shoulder, elbow, hand])
  match arm.get_bone_by_name("elbow") {
    None => assert_eq(false, true)
    Some(bone) => {
      assert_eq(physical_equal(bone, elbow), true)
      assert_eq(bone.node.position.y, 0.0)
    }
  }
  match arm.get_bone_by_name("shoulder") {
    None => assert_eq(false, true)
    Some(bone) => assert_eq(bone.node.position.y, -5.0)
  }
  match arm.get_bone_by_name("") {
    None => assert_eq(false, true)
    Some(bone) => {
      assert_eq(physical_equal(bone, hand), true)
      assert_eq(bone.node.position.y, 5.0)
    }
  }
  hand.node.name = "elbow"
  match arm.get_bone_by_name("elbow") {
    None => assert_eq(false, true)
    Some(bone) => assert_eq(physical_equal(bone, elbow), true)
  }
  assert_eq(arm.get_bone_by_name("wrist") is None, true)
  assert_eq(@objects.Skeleton::new().get_bone_by_name("elbow") is None, true)
}

///|
test "Skeleton.computeBoneTexture grows the matrix buffer" {
  let shoulder = @objects.Bone::new()
  let elbow = @objects.Bone::new()
  let hand = @objects.Bone::new()
  ignore(shoulder.add(elbow))
  ignore(elbow.add(hand))
  ignore(shoulder.node.position.set(0.0, -5.0, 0.0))
  ignore(elbow.node.position.set(0.0, 0.0, 0.0))
  ignore(hand.node.position.set(0.0, 5.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  let arm = @objects.Skeleton::new(bones=[shoulder, elbow, hand])
  ignore(shoulder.node.position.set(0.0, -2.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  arm.update()
  assert_eq(arm.bone_matrices.length(), 48)
  assert_eq(arm.bone_matrices[13], 3.0)
  let computed = arm.compute_bone_texture()
  assert_eq(physical_equal(computed, arm), true)
  assert_eq(arm.bone_matrices.length(), 64)
  assert_eq(arm.bone_matrices[13], 3.0)
  assert_eq(arm.bone_matrices[48], 0.0)
  assert_eq(arm.bone_matrices[63], 0.0)
  ignore(arm.compute_bone_texture())
  assert_eq(arm.bone_matrices.length(), 64)
  assert_eq(arm.bone_matrices[13], 3.0)
  let empty = @objects.Skeleton::new()
  ignore(empty.compute_bone_texture())
  assert_eq(empty.bone_matrices.length(), 64)
  assert_eq(empty.bone_matrices[0], 0.0)
  assert_eq(empty.bone_matrices[63], 0.0)
  let bones = []
  let mut index = 0
  while index < 17 {
    bones.push(@objects.Bone::new())
    index = index + 1
  }
  let wide = @objects.Skeleton::new(bones=bones)
  assert_eq(wide.bone_matrices.length(), 272)
  wide.bone_matrices[0] = 4.0
  ignore(wide.compute_bone_texture())
  assert_eq(wide.bone_matrices.length(), 576)
  assert_eq(wide.bone_matrices[0], 4.0)
  assert_eq(wide.bone_matrices[271], 0.0)
  assert_eq(wide.bone_matrices[272], 0.0)
  assert_eq(wide.bone_matrices[575], 0.0)
}

///|
test "Skeleton.dispose leaves the matrix buffer in place" {
  let shoulder = @objects.Bone::new()
  let elbow = @objects.Bone::new()
  let hand = @objects.Bone::new()
  ignore(shoulder.node.position.set(0.0, -5.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  let arm = @objects.Skeleton::new(bones=[shoulder, elbow, hand])
  ignore(shoulder.node.position.set(0.0, -2.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  arm.update()
  ignore(arm.compute_bone_texture())
  assert_eq(arm.bone_matrices.length(), 64)
  assert_eq(arm.bone_matrices[13], 3.0)
  arm.dispose()
  assert_eq(arm.bone_matrices.length(), 64)
  assert_eq(arm.bone_matrices[13], 3.0)
  assert_eq(arm.bone_matrices[63], 0.0)
  assert_eq(arm.bones.length(), 3)
  assert_eq(shoulder.node.position.y, -2.0)
  let empty = @objects.Skeleton::new()
  empty.dispose()
  assert_eq(empty.bone_matrices.length(), 0)
  assert_eq(empty.bones.length(), 0)
}

///|
test "Skeleton.toJSON writes bone uuids and inverse matrices" {
  let shoulder = @objects.Bone::new()
  let elbow = @objects.Bone::new()
  let hand = @objects.Bone::new()
  ignore(shoulder.add(elbow))
  ignore(elbow.add(hand))
  ignore(shoulder.node.position.set(0.0, -5.0, 0.0))
  ignore(elbow.node.position.set(0.0, 0.0, 0.0))
  ignore(hand.node.position.set(0.0, 5.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  let arm = @objects.Skeleton::new(bones=[shoulder, elbow, hand])
  let data = arm.to_json()
  assert_eq(data.version, 4.7)
  assert_eq(data.type_name, "Skeleton")
  assert_eq(data.generator, "Skeleton.toJSON")
  assert_eq(data.uuid, arm.uuid)
  assert_eq(data.bones.length(), 3)
  assert_eq(data.bones[0], shoulder.node.uuid)
  assert_eq(data.bones[1], elbow.node.uuid)
  assert_eq(data.bones[2], hand.node.uuid)
  assert_eq(data.bone_inverses.length(), 3)
  assert_eq(data.bone_inverses[0].length(), 16)
  assert_eq(data.bone_inverses[0][0], 1.0)
  assert_eq(data.bone_inverses[0][13], 5.0)
  assert_eq(data.bone_inverses[1][13], 5.0)
  assert_eq(data.bone_inverses[2][0], 1.0)
  assert_eq(data.bone_inverses[2][13], 0.0)
  assert_eq(data.bone_inverses[2][15], 1.0)
  data.bone_inverses[0][13] = 9.0
  assert_eq(arm.bone_inverses[0].elements[13], 5.0)
  let empty = @objects.Skeleton::new().to_json()
  assert_eq(empty.bones.length(), 0)
  assert_eq(empty.bone_inverses.length(), 0)
  assert_eq(empty.version, 4.7)
}

///|
test "Skeleton.fromJSON appends bones and keeps their inverses" {
  let shoulder = @objects.Bone::new()
  let elbow = @objects.Bone::new()
  let hand = @objects.Bone::new()
  shoulder.node.uuid = "shoulder"
  elbow.node.uuid = "elbow"
  hand.node.uuid = "hand"
  ignore(shoulder.add(elbow))
  ignore(elbow.add(hand))
  ignore(shoulder.node.position.set(0.0, -5.0, 0.0))
  ignore(elbow.node.position.set(0.0, 0.0, 0.0))
  ignore(hand.node.position.set(0.0, 5.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  let arm = @objects.Skeleton::new(bones=[shoulder, elbow, hand])
  let data = arm.to_json()
  let listed : Map[String, @objects.Bone] = Map([])
  listed.set(shoulder.node.uuid, shoulder)
  listed.set(elbow.node.uuid, elbow)
  listed.set(hand.node.uuid, hand)
  let restored = @objects.Skeleton::new()
  let loaded = restored.from_json(data, listed)
  assert_eq(physical_equal(loaded, restored), true)
  assert_eq(restored.uuid, arm.uuid)
  assert_eq(restored.bones.length(), 3)
  assert_eq(physical_equal(restored.bones[0].node, shoulder.node), true)
  assert_eq(restored.bones[0].node.uuid, shoulder.node.uuid)
  assert_eq(physical_equal(restored.bones[2].node, hand.node), true)
  assert_eq(restored.bone_inverses[0].elements[13], 5.0)
  assert_eq(restored.bone_inverses[1].elements[13], 5.0)
  assert_eq(restored.bone_inverses[2].elements[13], 0.0)
  assert_eq(restored.bone_matrices.length(), 48)
  assert_eq(restored.bone_matrices[0], 0.0)
  ignore(restored.from_json(data, listed))
  assert_eq(restored.bones.length(), 6)
  assert_eq(physical_equal(restored.bones[3].node, shoulder.node), true)
  assert_eq(restored.bone_matrices.length(), 96)
  assert_eq(restored.bone_matrices[0], 0.0)
  let gap : @objects.SkeletonJson = {
    version: 4.7,
    type_name: "Skeleton",
    generator: "Skeleton.toJSON",
    uuid: "skeleton-id",
    bones: ["missing"],
    bone_inverses: [@math.Matrix4::new().to_array()],
  }
  let fresh = @objects.Skeleton::new()
  let known : Map[String, @objects.Bone] = Map([])
  ignore(fresh.from_json(gap, known))
  assert_eq(fresh.uuid, "skeleton-id")
  assert_eq(fresh.bones.length(), 1)
  assert_eq(physical_equal(fresh.bones[0], shoulder), false)
  assert_eq(fresh.bones[0].node.kind is @core.NodeKind::Bone, true)
  assert_eq(fresh.bone_inverses[0].elements[0], 1.0)
  assert_eq(fresh.bone_inverses[0].elements[13], 0.0)
  assert_eq(fresh.bone_matrices.length(), 16)
}

///|
test "SkinnedMesh starts attached with identity bind matrices" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.5, 0.0, 0.0], 3),
    ),
  )
  let material = @materials.Material::basic()
  let skin = @objects.SkinnedMesh::new(geometry, material)
  assert_eq(skin.mesh.node.kind is @core.NodeKind::Mesh, true)
  assert_eq(physical_equal(skin.mesh.geometry, geometry), true)
  assert_eq(skin.mesh.geometry.get_attribute("position").unwrap().array[0], 0.5)
  assert_eq(skin.mesh.count, 1)
  assert_eq(skin.bind_mode is @constants.BindMode::Attached, true)
  assert_eq(skin.bind_matrix.elements[0], 1.0)
  assert_eq(skin.bind_matrix.elements[13], 0.0)
  assert_eq(skin.bind_matrix.elements[15], 1.0)
  assert_eq(skin.bind_matrix_inverse.elements[0], 1.0)
  assert_eq(skin.bind_matrix_inverse.elements[13], 0.0)
  assert_eq(skin.bind_matrix_inverse.elements[15], 1.0)
  assert_eq(skin.bounding_box is None, true)
  assert_eq(skin.bounding_sphere is None, true)
  assert_eq(skin.skeleton is None, true)
  skin.bind_mode = @constants.Detached
  assert_eq(skin.bind_mode is @constants.BindMode::Detached, true)
  assert_eq(physical_equal(skin.to_node(), skin.mesh.node), true)
}

///|
test "SkinnedMesh.bind stores the skeleton and the inverse bind matrix" {
  let bone = @objects.Bone::new()
  let given = @math.Matrix4::new()
  ignore(
    given.set(
      1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 4.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0,
    ),
  )
  let explicit = @objects.Skeleton::new(bones=[bone])
  assert_eq(explicit.bone_inverses[0].elements[13], 0.0)
  let held = @objects.SkinnedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
  )
  held.bind(explicit, bind_matrix=given)
  match held.skeleton {
    None => assert_eq(false, true)
    Some(skeleton) => assert_eq(physical_equal(skeleton, explicit), true)
  }
  assert_eq(held.bind_matrix.elements[13], 4.0)
  assert_eq(held.bind_matrix_inverse.elements[13], -4.0)
  assert_eq(given.elements[13], 4.0)
  assert_eq(explicit.bone_inverses[0].elements[13], 0.0)
  let shoulder = @objects.Bone::new()
  ignore(shoulder.node.position.set(0.0, -5.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  let arm = @objects.Skeleton::new(bones=[shoulder])
  assert_eq(arm.bone_inverses[0].elements[13], 5.0)
  ignore(shoulder.node.position.set(0.0, -2.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  let skin = @objects.SkinnedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
  )
  ignore(skin.mesh.node.position.set(0.0, 3.0, 0.0))
  skin.bind(arm)
  assert_eq(arm.bone_inverses[0].elements[13], 2.0)
  assert_eq(skin.bind_matrix.elements[13], 3.0)
  assert_eq(skin.bind_matrix_inverse.elements[13], -3.0)
  ignore(skin.mesh.node.position.set(0.0, 9.0, 0.0))
  skin.mesh.node.update_matrix_world(force=true)
  assert_eq(skin.bind_matrix.elements[13], 3.0)
  assert_eq(skin.mesh.node.matrix_world.elements[13], 9.0)
}

///|
test "SkinnedMesh.pose restores the bound skeleton" {
  let shoulder = @objects.Bone::new()
  let elbow = @objects.Bone::new()
  let hand = @objects.Bone::new()
  ignore(shoulder.add(elbow))
  ignore(elbow.add(hand))
  ignore(shoulder.node.position.set(0.0, -5.0, 0.0))
  ignore(elbow.node.position.set(0.0, 0.0, 0.0))
  ignore(hand.node.position.set(0.0, 5.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  let arm = @objects.Skeleton::new(bones=[shoulder, elbow, hand])
  let skin = @objects.SkinnedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
  )
  skin.bind(arm, bind_matrix=@math.Matrix4::new())
  ignore(shoulder.node.position.set(0.0, -2.0, 0.0))
  shoulder.node.update_matrix_world(force=true)
  assert_eq(shoulder.node.position.y, -2.0)
  skin.pose()
  assert_eq(shoulder.node.position.y, -5.0)
  assert_eq(elbow.node.position.y, 0.0)
  assert_eq(hand.node.position.y, 5.0)
  assert_eq(shoulder.node.matrix_world.elements[13], -5.0)
  assert_eq(hand.node.matrix_world.elements[13], 0.0)
  assert_eq(arm.bone_inverses[0].elements[13], 5.0)
}

///|
test "panic SkinnedMesh.pose requires a skeleton" {
  let skin = @objects.SkinnedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
  )
  skin.pose()
}

///|
test "SkinnedMesh.normalizeSkinWeights scales by the Manhattan length" {
  let geometry = @core.BufferGeometry::new()
  let weights = @core.BufferAttribute::new(
    [2.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0, 0.0, -2.0, 2.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0],
    4,
  )
  ignore(geometry.set_attribute("skinWeight", weights))
  let skin = @objects.SkinnedMesh::new(geometry, @materials.Material::basic())
  skin.normalize_skin_weights()
  let stored = skin.mesh.geometry.get_attribute("skinWeight").unwrap()
  assert_eq(physical_equal(stored, weights), true)
  assert_eq(stored.array[0], 0.5)
  assert_eq(stored.array[1], 0.0)
  assert_eq(stored.array[2], 0.0)
  assert_eq(stored.array[3], 0.5)
  assert_eq(stored.array[4], 1.0)
  assert_eq(stored.array[5], 0.0)
  assert_eq(stored.array[6], 0.0)
  assert_eq(stored.array[7], 0.0)
  assert_eq(stored.array[8], -0.5)
  assert_eq(stored.array[9], 0.5)
  assert_eq(stored.array[10], 0.0)
  assert_eq(stored.array[11], 0.0)
  assert_eq(stored.array[12], 0.25)
  assert_eq(stored.array[13], 0.25)
  assert_eq(stored.array[14], 0.25)
  assert_eq(stored.array[15], 0.25)
}

///|
test "panic SkinnedMesh.normalizeSkinWeights requires skinWeight" {
  let skin = @objects.SkinnedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
  )
  skin.normalize_skin_weights()
}

///|
test "panic Skeleton.computeBoneTexture aborts when the buffer does not fit" {
  let arm = @objects.Skeleton::new(bones=[@objects.Bone::new()])
  let big = []
  let mut index = 0
  while index < 65 {
    big.push(1.0)
    index = index + 1
  }
  arm.bone_matrices = big
  ignore(arm.compute_bone_texture())
}

///|
test "Mesh.clone shares geometry and drops children when asked" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.5, 0.0, 0.0], 3),
    ),
  )
  let material = @materials.Material::basic()
  let source = @objects.Mesh::new(geometry, material)
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  source.node.render_order = 4
  let child = @core.Object3D::new()
  child.name = "marker"
  ignore(source.node.add(child))
  let cloned = source.clone()
  assert_eq(physical_equal(cloned, source), false)
  assert_eq(physical_equal(cloned.geometry, geometry), true)
  assert_eq(physical_equal(cloned.material, material), true)
  assert_eq(cloned.node.position.y, 3.0)
  assert_eq(cloned.node.render_order, 4)
  assert_eq(cloned.node.children.length(), 1)
  assert_eq(cloned.node.children[0].name, "marker")
  assert_eq(physical_equal(cloned.node.children[0], child), false)
  match cloned.node.mesh {
    None => assert_eq(false, true)
    Some(binding) =>
      assert_eq(physical_equal(binding.geometry, geometry), true)
  }
  let bare = source.clone(recursive=false)
  assert_eq(bare.node.children.length(), 0)
  assert_eq(bare.node.position.y, 3.0)
  assert_eq(physical_equal(bare.geometry, geometry), true)
  assert_eq(source.node.children.length(), 1)
}

///|
test "mesh raycast hits a front-facing triangle" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0],
        3,
      ),
    ),
  )
  let mesh = @objects.Mesh::new(geometry, @materials.Material::basic())
  mesh.node.update_matrix_world()
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  let hits = raycaster.intersect_object(mesh.node)
  assert_eq(hits.length(), 1)
  assert_eq(hits[0].distance, 1.0)
  assert_eq(hits[0].point.x, 0.25)
  assert_eq(hits[0].point.y, 0.25)
  assert_eq(hits[0].point.z, 0.0)
  assert_eq(physical_equal(hits[0].object, mesh.node), true)
  match hits[0].face {
    None => assert_eq(false, true)
    Some(face) => {
      assert_eq(face.a, 0)
      assert_eq(face.b, 1)
      assert_eq(face.c, 2)
      assert_eq(face.material_index, 0)
      assert_eq(face.normal.x, 0.0)
      assert_eq(face.normal.y, 0.0)
      assert_eq(face.normal.z, 1.0)
    }
  }
  match hits[0].face_index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 0)
  }
  match hits[0].barycoord {
    None => assert_eq(false, true)
    Some(bary) => {
      assert_eq(bary.x, 0.5)
      assert_eq(bary.y, 0.25)
      assert_eq(bary.z, 0.25)
    }
  }
  match hits[0].uv {
    None => ()
    Some(_) => assert_eq(false, true)
  }
  match hits[0].instance_id {
    None => ()
    Some(_) => assert_eq(false, true)
  }
}

///|
test "InstancedMesh.raycast hits one instance and records its index" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0],
        3,
      ),
    ),
  )
  let mesh = @objects.InstancedMesh::new(
    geometry,
    @materials.Material::basic(),
    2,
  )
  let matrix = @math.Matrix4::new()
  ignore(matrix.make_translation(2.0, 0.0, 0.0))
  mesh.set_matrix_at(1, matrix)
  mesh.node.update_matrix_world()
  let near = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  let first = near.intersect_object(mesh.node, recursive=false)
  assert_eq(first.length(), 1)
  assert_eq(first[0].distance, 1.0)
  assert_eq(first[0].point.x, 0.25)
  assert_eq(first[0].point.y, 0.25)
  assert_eq(first[0].point.z, 0.0)
  match first[0].instance_id {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 0)
  }
  assert_eq(physical_equal(first[0].object, mesh.node), true)
  let far = @core.Raycaster::new(
    origin=@math.Vector3::new(x=2.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  let second = far.intersect_object(mesh.node, recursive=false)
  assert_eq(second.length(), 1)
  assert_eq(second[0].point.x, 2.25)
  assert_eq(second[0].point.y, 0.25)
  assert_eq(second[0].point.z, 0.0)
  assert_eq(second[0].distance, 1.0)
  match second[0].instance_id {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 1)
  }
  assert_eq(mesh.node.matrix_world.elements[0], 1.0)
  assert_eq(mesh.node.matrix_world.elements[12], 0.0)
  match geometry.bounding_sphere {
    None => assert_eq(false, true)
    Some(geometry_sphere) => {
      assert_eq(geometry_sphere.center.x, 0.5)
      assert_eq(geometry_sphere.center.y, 0.5)
      assert_eq(geometry_sphere.center.z, 0.0)
    }
  }
  ignore(matrix.make_translation(10.0, 0.0, 0.0))
  mesh.set_matrix_at(0, matrix)
  ignore(matrix.make_translation(12.0, 0.0, 0.0))
  mesh.set_matrix_at(1, matrix)
  ignore(mesh.compute_bounding_sphere())
  let missed = near.intersect_object(mesh.node, recursive=false)
  assert_eq(missed.length(), 0)
  mesh.set_count(0)
  ignore(mesh.compute_bounding_sphere())
  ignore(matrix.make_translation(0.0, 0.0, 0.0))
  mesh.set_matrix_at(0, matrix)
  let none_drawn = near.intersect_object(mesh.node, recursive=false)
  assert_eq(none_drawn.length(), 0)
}

///|
test "InstancedMesh.copy clones bounds and shares geometry" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0], 3),
    ),
  )
  let material = @materials.Material::basic()
  let source = @objects.InstancedMesh::new(geometry, material, 2)
  source.set_count(1)
  let matrix = @math.Matrix4::new()
  ignore(matrix.make_translation(2.0, 0.0, 0.0))
  source.set_matrix_at(0, matrix)
  source.set_color_at(0, @math.Color::new(r=0.25, g=0.5, b=1.0))
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  source.node.frustum_culled = true
  let child = @core.Object3D::new()
  child.name = "marker"
  ignore(source.node.add(child))
  let destination = @objects.InstancedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::lambert(),
    1,
  )
  ignore(
    destination.geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([1.0, 1.0, 1.0], 3),
    ),
  )
  ignore(destination.compute_bounding_sphere())
  let copied = destination.copy(source)
  assert_eq(physical_equal(copied, destination), true)
  assert_eq(destination.instances.count, 1)
  assert_eq(destination.bounding_sphere is None, true)
  assert_eq(physical_equal(destination.geometry, geometry), true)
  assert_eq(physical_equal(destination.material, material), true)
  assert_eq(destination.node.position.y, 3.0)
  assert_eq(destination.node.frustum_culled, true)
  assert_eq(destination.node.children.length(), 1)
  assert_eq(destination.node.children[0].name, "marker")
  assert_eq(physical_equal(destination.node.children[0], child), false)
  ignore(source.compute_bounding_box())
  ignore(source.compute_bounding_sphere())
  ignore(destination.copy(source, recursive=false))
  assert_eq(destination.node.children.length(), 1)
  let read = @math.Matrix4::new()
  ignore(destination.get_matrix_at(0, read))
  assert_eq(read.elements[12], 2.0)
  let color = @math.Color::new(r=0.0, g=0.0, b=0.0)
  ignore(destination.get_color_at(0, color))
  assert_eq(color.r, 0.25)
  assert_eq(color.g, 0.5)
  assert_eq(color.b, 1.0)
  match destination.bounding_box {
    None => assert_eq(false, true)
    Some(box) => {
      assert_eq(box.min.x, 2.0)
      assert_eq(box.max.x, 2.0)
      assert_eq(box.min.y, 0.0)
      assert_eq(box.max.y, 0.0)
      assert_eq(box.min.z, 0.0)
      assert_eq(box.max.z, 0.0)
      box.max.x = 8.0
    }
  }
  match source.bounding_box {
    None => assert_eq(false, true)
    Some(box) => assert_eq(box.max.x, 2.0)
  }
  match destination.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(sphere.center.x, 2.0)
      assert_eq(sphere.center.y, 0.0)
      assert_eq(sphere.center.z, 0.0)
      assert_eq(sphere.radius, 0.0)
      sphere.radius = 5.0
    }
  }
  match source.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => assert_eq(sphere.radius, 0.0)
  }
  match destination.instances.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => assert_eq(sphere.radius, 5.0)
  }
  ignore(matrix.make_translation(9.0, 0.0, 0.0))
  destination.set_matrix_at(0, matrix)
  ignore(source.get_matrix_at(0, read))
  assert_eq(read.elements[12], 2.0)
  destination.set_color_at(0, @math.Color::new(r=0.0, g=0.0, b=0.0))
  ignore(source.get_color_at(0, color))
  assert_eq(color.r, 0.25)
  assert_eq(color.g, 0.5)
  assert_eq(color.b, 1.0)
}

///|
test "InstancedMesh.clone keeps capacity and detaches bounds" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0], 3),
    ),
  )
  let source = @objects.InstancedMesh::new(
    geometry,
    @materials.Material::basic(),
    2,
  )
  source.set_count(1)
  let matrix = @math.Matrix4::new()
  ignore(matrix.make_translation(2.0, 0.0, 0.0))
  source.set_matrix_at(0, matrix)
  source.set_color_at(0, @math.Color::new(r=0.25, g=0.5, b=1.0))
  ignore(source.node.position.set(0.0, 3.0, 0.0))
  let child = @core.Object3D::new()
  child.name = "marker"
  ignore(source.node.add(child))
  ignore(source.compute_bounding_sphere())
  let cloned = source.clone()
  assert_eq(physical_equal(cloned, source), false)
  assert_eq(cloned.instances.matrices.count, 2)
  assert_eq(cloned.instances.count, 1)
  assert_eq(physical_equal(cloned.geometry, geometry), true)
  assert_eq(cloned.node.position.y, 3.0)
  assert_eq(cloned.node.children.length(), 1)
  assert_eq(cloned.node.children[0].name, "marker")
  assert_eq(physical_equal(cloned.node.children[0], child), false)
  let read = @math.Matrix4::new()
  ignore(cloned.get_matrix_at(0, read))
  assert_eq(read.elements[12], 2.0)
  let color = @math.Color::new(r=0.0, g=0.0, b=0.0)
  ignore(cloned.get_color_at(0, color))
  assert_eq(color.r, 0.25)
  assert_eq(color.g, 0.5)
  assert_eq(color.b, 1.0)
  match cloned.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(sphere.center.x, 2.0)
      assert_eq(sphere.radius, 0.0)
      sphere.radius = 5.0
    }
  }
  match source.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => assert_eq(sphere.radius, 0.0)
  }
  let bare = source.clone(recursive=false)
  assert_eq(bare.node.children.length(), 0)
  assert_eq(bare.instances.count, 1)
  ignore(bare.get_matrix_at(0, read))
  assert_eq(read.elements[12], 2.0)
}

///|
test "LOD.copy clones levels and leaves the current level" {
  let source = @objects.LOD::new()
  let near = @core.Object3D::new()
  near.name = "near"
  ignore(near.position.set(0.0, 1.0, 0.0))
  let far = @core.Object3D::new()
  far.name = "far"
  ignore(source.add_level(near, distance=0.0, hysteresis=0.0))
  ignore(source.add_level(far, distance=10.0, hysteresis=0.25))
  source.auto_update = false
  source.current_level = 1
  ignore(source.node.position.set(0.0, 4.0, 0.0))
  let destination = @objects.LOD::new()
  destination.current_level = 3
  let copied = destination.copy(source)
  assert_eq(physical_equal(copied, destination), true)
  assert_eq(destination.auto_update, false)
  assert_eq(destination.current_level, 3)
  assert_eq(destination.node.position.y, 4.0)
  assert_eq(destination.levels.length(), 2)
  assert_eq(destination.levels[0].distance, 0.0)
  assert_eq(destination.levels[0].hysteresis, 0.0)
  assert_eq(destination.levels[1].distance, 10.0)
  assert_eq(destination.levels[1].hysteresis, 0.25)
  assert_eq(destination.levels[0].object.name, "near")
  assert_eq(destination.levels[1].object.name, "far")
  assert_eq(destination.levels[0].object.position.y, 1.0)
  assert_eq(physical_equal(destination.levels[0].object, near), false)
  assert_eq(physical_equal(destination.levels[1].object, far), false)
  assert_eq(destination.node.children.length(), 2)
  assert_eq(source.node.children.length(), 2)
  assert_eq(source.current_level, 1)
  destination.levels[0].object.name = "copy"
  assert_eq(near.name, "near")
}

///|
test "LOD.clone starts at level zero with new objects" {
  let source = @objects.LOD::new()
  let near = @core.Object3D::new()
  near.name = "near"
  ignore(near.position.set(0.0, 1.0, 0.0))
  let far = @core.Object3D::new()
  far.name = "far"
  ignore(source.add_level(near, distance=0.0, hysteresis=0.0))
  ignore(source.add_level(far, distance=10.0, hysteresis=0.25))
  source.auto_update = false
  source.current_level = 1
  ignore(source.node.position.set(0.0, 4.0, 0.0))
  let cloned = source.clone()
  assert_eq(physical_equal(cloned, source), false)
  assert_eq(cloned.auto_update, false)
  assert_eq(cloned.current_level, 0)
  assert_eq(cloned.node.position.y, 4.0)
  assert_eq(cloned.levels.length(), 2)
  assert_eq(cloned.levels[0].distance, 0.0)
  assert_eq(cloned.levels[0].hysteresis, 0.0)
  assert_eq(cloned.levels[1].distance, 10.0)
  assert_eq(cloned.levels[1].hysteresis, 0.25)
  assert_eq(cloned.levels[0].object.name, "near")
  assert_eq(cloned.levels[0].object.position.y, 1.0)
  assert_eq(cloned.levels[1].object.name, "far")
  assert_eq(physical_equal(cloned.levels[0].object, near), false)
  assert_eq(physical_equal(cloned.levels[1].object, far), false)
  assert_eq(source.current_level, 1)
  cloned.levels[1].object.name = "copy"
  assert_eq(far.name, "far")
}

///|
test "LOD.getCurrentLevel reads the level chosen for the camera" {
  let fresh = @objects.LOD::new()
  assert_eq(fresh.get_current_level(), 0)
  let camera = @core.Object3D::new(kind=@core.NodeKind::PerspectiveCamera)
  let state = @core.CameraState::perspective(50.0, 1.0, 0.1, 2000.0)
  camera.camera = Some(state)
  ignore(camera.position.set(0.0, 0.0, 10.0))
  camera.update_matrix_world()
  let lod = @objects.LOD::new()
  ignore(lod.add_level(@core.Object3D::new(), distance=0.0))
  ignore(lod.add_level(@core.Object3D::new(), distance=10.0))
  ignore(lod.add_level(@core.Object3D::new(), distance=20.0))
  lod.node.update_matrix_world()
  lod.update(camera)
  assert_eq(lod.get_current_level(), 1)
  state.zoom = 2.0
  lod.update(camera)
  assert_eq(lod.get_current_level(), 0)
}

///|
test "mesh raycast interpolates uv" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0],
        3,
      ),
    ),
  )
  ignore(
    geometry.set_attribute(
      "uv",
      @core.BufferAttribute::new([0.0, 0.0, 1.0, 0.0, 0.0, 1.0], 2),
    ),
  )
  let mesh = @objects.Mesh::new(geometry, @materials.Material::basic())
  mesh.node.update_matrix_world()
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  let hits = raycaster.intersect_object(mesh.node)
  assert_eq(hits.length(), 1)
  match hits[0].uv {
    None => assert_eq(false, true)
    Some(uv) => {
      assert_eq(uv.x, 0.25)
      assert_eq(uv.y, 0.25)
    }
  }
  match hits[0].uv1 {
    None => ()
    Some(_) => assert_eq(false, true)
  }
}

///|
test "mesh raycast interpolates uv1" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0],
        3,
      ),
    ),
  )
  ignore(
    geometry.set_attribute(
      "uv1",
      @core.BufferAttribute::new([0.0, 1.0, 1.0, 1.0, 0.0, 0.0], 2),
    ),
  )
  let mesh = @objects.Mesh::new(geometry, @materials.Material::basic())
  mesh.node.update_matrix_world()
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  let hits = raycaster.intersect_object(mesh.node)
  assert_eq(hits.length(), 1)
  match hits[0].uv1 {
    None => assert_eq(false, true)
    Some(uv) => {
      assert_eq(uv.x, 0.25)
      assert_eq(uv.y, 0.75)
    }
  }
}

///|
test "mesh raycast flips a back-facing shading normal" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0],
        3,
      ),
    ),
  )
  ignore(
    geometry.set_attribute(
      "normal",
      @core.BufferAttribute::new(
        [0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0],
        3,
      ),
    ),
  )
  let mesh = @objects.Mesh::new(geometry, @materials.Material::basic())
  mesh.node.update_matrix_world()
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  let hits = raycaster.intersect_object(mesh.node)
  assert_eq(hits.length(), 1)
  match hits[0].normal {
    None => assert_eq(false, true)
    Some(normal) => {
      assert_eq(normal.x, 0.0)
      assert_eq(normal.y, 0.0)
      assert_eq(normal.z, 1.0)
    }
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
test "LOD.addLevel sorts levels by absolute distance" {
  let lod = @objects.LOD::new()
  let far = @core.Object3D::new()
  let near = @core.Object3D::new()
  let mid = @core.Object3D::new()
  ignore(lod.add_level(far, distance=10.0))
  ignore(lod.add_level(near, distance=0.0))
  ignore(lod.add_level(mid, distance=-5.0, hysteresis=0.25))
  assert_eq(lod.levels.length(), 3)
  assert_eq(lod.levels[0].distance, 0.0)
  assert_eq(lod.levels[1].distance, 5.0)
  assert_eq(lod.levels[2].distance, 10.0)
  assert_eq(lod.levels[0].hysteresis, 0.0)
  assert_eq(lod.levels[1].hysteresis, 0.25)
  assert_eq(physical_equal(lod.levels[0].object, near), true)
  assert_eq(physical_equal(lod.levels[1].object, mid), true)
  assert_eq(physical_equal(lod.levels[2].object, far), true)
  assert_eq(lod.node.children.length(), 3)
  assert_eq(physical_equal(lod.node.children[0], far), true)
  assert_eq(lod.auto_update, true)
}

///|
test "LOD.removeLevel drops the matching distance" {
  let lod = @objects.LOD::new()
  let far = @core.Object3D::new()
  let near = @core.Object3D::new()
  let mid = @core.Object3D::new()
  ignore(lod.add_level(far, distance=10.0))
  ignore(lod.add_level(near, distance=0.0))
  ignore(lod.add_level(mid, distance=5.0))
  assert_eq(lod.remove_level(5.0), true)
  assert_eq(lod.levels.length(), 2)
  assert_eq(lod.levels[0].distance, 0.0)
  assert_eq(lod.levels[1].distance, 10.0)
  assert_eq(physical_equal(lod.levels[0].object, near), true)
  assert_eq(physical_equal(lod.levels[1].object, far), true)
  assert_eq(lod.node.children.length(), 2)
  match mid.parent {
    None => assert_eq(true, true)
    Some(_) => assert_eq(false, true)
  }
  assert_eq(lod.remove_level(7.0), false)
  assert_eq(lod.levels.length(), 2)
  assert_eq(lod.node.children.length(), 2)
}

///|
test "LOD.getObjectForDistance applies visible hysteresis" {
  let empty = @objects.LOD::new()
  match empty.get_object_for_distance(1.0) {
    None => assert_eq(true, true)
    Some(_) => assert_eq(false, true)
  }
  let lod = @objects.LOD::new()
  let near = @core.Object3D::new()
  let far = @core.Object3D::new()
  ignore(lod.add_level(near, distance=0.0))
  ignore(lod.add_level(far, distance=10.0, hysteresis=0.5))
  match lod.get_object_for_distance(4.0) {
    None => assert_eq(false, true)
    Some(object) => assert_eq(physical_equal(object, near), true)
  }
  match lod.get_object_for_distance(5.0) {
    None => assert_eq(false, true)
    Some(object) => assert_eq(physical_equal(object, far), true)
  }
  far.visible = false
  match lod.get_object_for_distance(8.0) {
    None => assert_eq(false, true)
    Some(object) => assert_eq(physical_equal(object, near), true)
  }
}

///|
test "LOD.raycast hits the level selected by distance" {
  let lod = @objects.LOD::new()
  lod.node.update_matrix_world()
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.25, y=0.25, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  assert_eq(raycaster.intersect_object(lod.node, recursive=false).length(), 0)
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0],
        3,
      ),
    ),
  )
  let mesh = @objects.Mesh::new(geometry, @materials.Material::basic())
  ignore(lod.add_level(@core.Object3D::new(), distance=0.0))
  ignore(lod.add_level(mesh.node, distance=0.5))
  lod.node.update_matrix_world()
  let hits = raycaster.intersect_object(lod.node, recursive=false)
  assert_eq(hits.length(), 1)
  assert_eq(hits[0].distance, 1.0)
  assert_eq(hits[0].point.x, 0.25)
  assert_eq(hits[0].point.y, 0.25)
  assert_eq(hits[0].point.z, 0.0)
  assert_eq(physical_equal(hits[0].object, mesh.node), true)
}

///|
test "LineLoop raycast closes the last vertex to the first" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new(
        [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0],
        3,
      ),
    ),
  )
  let open = @objects.Line::new(geometry, @materials.LineBasicMaterial::new())
  open.node.update_matrix_world()
  let raycaster = @core.Raycaster::new(
    origin=@math.Vector3::new(x=0.5, y=0.5, z=1.0),
    direction=@math.Vector3::new(z=-1.0),
  )
  raycaster.params.line.threshold = 0.0
  assert_eq(raycaster.intersect_object(open.node).length(), 0)
  let closed = @objects.LineLoop::new(geometry, @materials.LineBasicMaterial::new())
  closed.node.update_matrix_world()
  let hits = raycaster.intersect_object(closed.node)
  assert_eq(hits.length(), 1)
  assert_eq(hits[0].distance, 1.0)
  assert_eq(hits[0].point.x, 0.5)
  assert_eq(hits[0].point.y, 0.5)
  assert_eq(hits[0].point.z, 0.0)
  match hits[0].index {
    None => assert_eq(false, true)
    Some(index) => assert_eq(index, 2)
  }
}

///|
test "LOD.update shows the level for the camera distance" {
  let camera = @core.Object3D::new(kind=@core.NodeKind::PerspectiveCamera)
  let state = @core.CameraState::perspective(50.0, 1.0, 0.1, 2000.0)
  camera.camera = Some(state)
  ignore(camera.position.set(0.0, 0.0, 10.0))
  camera.update_matrix_world()
  let alone = @core.Object3D::new()
  let single = @objects.LOD::new()
  ignore(single.add_level(alone, distance=0.0))
  single.node.update_matrix_world()
  single.update(camera)
  assert_eq(alone.visible, true)
  assert_eq(single.current_level, 0)
  let lod = @objects.LOD::new()
  let near = @core.Object3D::new()
  let mid = @core.Object3D::new()
  let far = @core.Object3D::new()
  ignore(lod.add_level(near, distance=0.0))
  ignore(lod.add_level(mid, distance=10.0))
  ignore(lod.add_level(far, distance=20.0))
  lod.node.update_matrix_world()
  lod.update(camera)
  assert_eq(lod.current_level, 1)
  assert_eq(near.visible, false)
  assert_eq(mid.visible, true)
  assert_eq(far.visible, false)
  state.zoom = 2.0
  lod.update(camera)
  assert_eq(lod.current_level, 0)
  assert_eq(near.visible, true)
  assert_eq(mid.visible, false)
  assert_eq(far.visible, false)
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
test "Object3D.intersectsFrustum uses the geometry sphere" {
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
  assert_eq(@core.Object3D::new().intersects_frustum(frustum), false)
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.5, 0.5, 0.5], 3),
    ),
  )
  let mesh = @objects.Mesh::new(geometry, @materials.Material::basic())
  mesh.node.update_matrix_world()
  assert_eq(mesh.node.intersects_frustum(frustum), true)
  ignore(mesh.node.position.set(-2.5, 0.0, 0.0))
  mesh.node.update_matrix_world()
  assert_eq(mesh.node.intersects_frustum(frustum), false)
  match geometry.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(sphere.center.x, 0.5)
      assert_eq(sphere.center.y, 0.5)
      assert_eq(sphere.center.z, 0.5)
      assert_eq(sphere.radius, 0.0)
    }
  }
}

///|
test "Object3D.intersectsFrustumArray uses only the counted frustums" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.5, 0.5, 0.5], 3),
    ),
  )
  let mesh = @objects.Mesh::new(geometry, @materials.Material::basic())
  mesh.node.update_matrix_world()
  let frustums = @math.FrustumArray::new()
  assert_eq(mesh.node.intersects_frustum_array(frustums), false)
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
  assert_eq(mesh.node.intersects_frustum_array(frustums), false)
  frustums.count = 1
  assert_eq(mesh.node.intersects_frustum_array(frustums), true)
  ignore(mesh.node.position.set(-2.5, 0.0, 0.0))
  mesh.node.update_matrix_world()
  assert_eq(mesh.node.intersects_frustum_array(frustums), false)
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
  assert_eq(mesh.node.intersects_frustum_array(frustums), false)
  frustums.count = 2
  assert_eq(mesh.node.intersects_frustum_array(frustums), true)
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

///|
test "InstancedMesh.computeBoundingSphere unions transformed geometry spheres" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0], 3),
    ),
  )
  let mesh = @objects.InstancedMesh::new(
    geometry,
    @materials.Material::basic(),
    2,
  )
  let moved = @math.Matrix4::new()
  ignore(moved.make_translation(2.0, 0.0, 0.0))
  mesh.set_matrix_at(1, moved)
  let sphere = mesh.compute_bounding_sphere()
  assert_eq(sphere.center.x, 1.0)
  assert_eq(sphere.center.y, 0.0)
  assert_eq(sphere.center.z, 0.0)
  assert_eq(sphere.radius, 1.0)
  match geometry.bounding_sphere {
    None => assert_eq(false, true)
    Some(geometry_sphere) => {
      assert_eq(geometry_sphere.center.x, 0.0)
      assert_eq(geometry_sphere.center.y, 0.0)
      assert_eq(geometry_sphere.center.z, 0.0)
      assert_eq(geometry_sphere.radius, 0.0)
    }
  }
  mesh.set_count(1)
  let near = mesh.compute_bounding_sphere()
  assert_eq(near.center.x, 0.0)
  assert_eq(near.center.y, 0.0)
  assert_eq(near.center.z, 0.0)
  assert_eq(near.radius, 0.0)
  mesh.set_count(0)
  let none_drawn = mesh.compute_bounding_sphere()
  assert_eq(none_drawn.center.x, 0.0)
  assert_eq(none_drawn.radius, -1.0)
  let blank = @objects.InstancedMesh::new(
    @core.BufferGeometry::new(),
    @materials.Material::basic(),
    1,
  )
  let missing = blank.compute_bounding_sphere()
  assert_eq(missing.center.x, 0.0)
  assert_eq(missing.radius, -1.0)
}

///|
test "InstancedMesh.intersectsFrustum uses the instanced bounding sphere" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0], 3),
    ),
  )
  let mesh = @objects.InstancedMesh::new(
    geometry,
    @materials.Material::basic(),
    1,
  )
  let matrix = @math.Matrix4::new()
  ignore(matrix.make_translation(-2.0, 0.0, 0.0))
  mesh.set_matrix_at(0, matrix)
  mesh.node.update_matrix_world()
  assert_eq(mesh.bounding_sphere is None, true)
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
  assert_eq(mesh.intersects_frustum(frustum), false)
  match mesh.bounding_sphere {
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
      assert_eq(geometry_sphere.center.y, 0.0)
      assert_eq(geometry_sphere.center.z, 0.0)
      assert_eq(geometry_sphere.radius, 0.0)
    }
  }
  ignore(matrix.make_translation(0.5, 0.5, 0.5))
  mesh.set_matrix_at(0, matrix)
  ignore(mesh.compute_bounding_sphere())
  assert_eq(mesh.intersects_frustum(frustum), true)
  match mesh.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(sphere.center.x, 0.5)
      assert_eq(sphere.center.y, 0.5)
      assert_eq(sphere.center.z, 0.5)
      assert_eq(sphere.radius, 0.0)
    }
  }
  ignore(matrix.make_translation(0.0, 0.0, 0.0))
  mesh.set_matrix_at(0, matrix)
  ignore(mesh.compute_bounding_sphere())
  ignore(mesh.node.position.set(-2.5, 0.0, 0.0))
  mesh.node.update_matrix_world()
  assert_eq(mesh.intersects_frustum(frustum), false)
  match mesh.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(sphere.center.x, 0.0)
      assert_eq(sphere.center.y, 0.0)
      assert_eq(sphere.center.z, 0.0)
      assert_eq(sphere.radius, 0.0)
    }
  }
}

///|
test "InstancedMesh.intersectsFrustumArray uses only the counted frustums" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0], 3),
    ),
  )
  let mesh = @objects.InstancedMesh::new(
    geometry,
    @materials.Material::basic(),
    1,
  )
  let matrix = @math.Matrix4::new()
  ignore(matrix.make_translation(0.5, 0.5, 0.5))
  mesh.set_matrix_at(0, matrix)
  mesh.node.update_matrix_world()
  let frustums = @math.FrustumArray::new()
  assert_eq(mesh.intersects_frustum_array(frustums), false)
  assert_eq(mesh.bounding_sphere is None, true)
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
  assert_eq(mesh.intersects_frustum_array(frustums), false)
  assert_eq(mesh.bounding_sphere is None, true)
  frustums.count = 1
  assert_eq(mesh.intersects_frustum_array(frustums), true)
  match mesh.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(sphere.center.x, 0.5)
      assert_eq(sphere.center.y, 0.5)
      assert_eq(sphere.center.z, 0.5)
      assert_eq(sphere.radius, 0.0)
    }
  }
  ignore(matrix.make_translation(-2.0, 0.5, 0.5))
  mesh.set_matrix_at(0, matrix)
  ignore(mesh.compute_bounding_sphere())
  assert_eq(mesh.intersects_frustum_array(frustums), false)
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
  assert_eq(mesh.intersects_frustum_array(frustums), false)
  frustums.count = 2
  assert_eq(mesh.intersects_frustum_array(frustums), true)
  match mesh.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(sphere.center.x, -2.0)
      assert_eq(sphere.center.y, 0.5)
      assert_eq(sphere.center.z, 0.5)
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
}

///|
test "Object3D.intersectsFrustum uses the instanced bounding sphere" {
  let geometry = @core.BufferGeometry::new()
  ignore(
    geometry.set_attribute(
      "position",
      @core.BufferAttribute::new([0.0, 0.0, 0.0], 3),
    ),
  )
  let plain = @objects.Mesh::new(geometry, @materials.Material::basic())
  plain.node.update_matrix_world()
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
  assert_eq(plain.node.intersects_frustum(frustum), true)
  let mesh = @objects.InstancedMesh::new(
    geometry,
    @materials.Material::basic(),
    1,
  )
  let matrix = @math.Matrix4::new()
  ignore(matrix.make_translation(-2.0, 0.0, 0.0))
  mesh.set_matrix_at(0, matrix)
  mesh.node.update_matrix_world()
  assert_eq(mesh.node.intersects_frustum(frustum), false)
  match mesh.instances.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(sphere.center.x, -2.0)
      assert_eq(sphere.center.y, 0.0)
      assert_eq(sphere.center.z, 0.0)
      assert_eq(sphere.radius, 0.0)
    }
  }
  let stored = mesh.compute_bounding_sphere()
  assert_eq(stored.center.x, -2.0)
  assert_eq(stored.radius, 0.0)
  match mesh.instances.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => assert_eq(physical_equal(stored, sphere), true)
  }
  match geometry.bounding_sphere {
    None => assert_eq(false, true)
    Some(geometry_sphere) => {
      assert_eq(geometry_sphere.center.x, 0.0)
      assert_eq(geometry_sphere.radius, 0.0)
    }
  }
  ignore(matrix.make_translation(0.5, 0.5, 0.5))
  mesh.set_matrix_at(0, matrix)
  ignore(mesh.compute_bounding_sphere())
  assert_eq(mesh.node.intersects_frustum(frustum), true)
  ignore(matrix.make_translation(0.0, 0.0, 0.0))
  mesh.set_matrix_at(0, matrix)
  ignore(mesh.compute_bounding_sphere())
  ignore(mesh.node.position.set(-2.5, 0.0, 0.0))
  mesh.node.update_matrix_world()
  assert_eq(mesh.node.intersects_frustum(frustum), false)
  match mesh.bounding_sphere {
    None => assert_eq(false, true)
    Some(sphere) => {
      assert_eq(sphere.center.x, 0.0)
      assert_eq(sphere.center.y, 0.0)
      assert_eq(sphere.center.z, 0.0)
      assert_eq(sphere.radius, 0.0)
    }
  }
}
