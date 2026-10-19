///|
test "LineBasicMaterial stores a color map" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.map is None, true)
  assert_eq(defaults.color.r, 1.0)
  assert_eq(defaults.opacity, 1.0)
  assert_eq(defaults.fog, true)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  let material = @materials.LineBasicMaterial::new(hex=0x00FF00)
  material.map = Some(map)
  assert_eq(material.color.r, 0.0)
  assert_eq(material.color.g, 1.0)
  assert_eq(material.color.b, 0.0)
  match material.map {
    None => assert_eq(false, true)
    Some(stored) => {
      assert_eq(physical_equal(stored, map), true)
      assert_eq(stored.width, 1)
      assert_eq(stored.height, 1)
    }
  }
  assert_eq(defaults.map is None, true)
  assert_eq(defaults.color.g, 1.0)
}

///|
test "LineBasicMaterial.copy writes color and shares the map" {
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  let source = @materials.LineBasicMaterial::new(hex=0x00FF00)
  source.map = Some(map)
  source.opacity = 0.25
  source.transparent = true
  source.fog = false
  source.depth_write = false
  source.depth_test = false
  source.depth_func = @constants.DepthFunc::Greater
  source.color_write = false
  source.premultiplied_alpha = true
  source.visible = false
  let destination = @materials.LineBasicMaterial::new()
  let color = destination.color
  let copied = destination.copy(source)
  assert_eq(physical_equal(copied, destination), true)
  assert_eq(physical_equal(destination.color, color), true)
  assert_eq(destination.color.r, 0.0)
  assert_eq(destination.color.g, 1.0)
  assert_eq(destination.color.b, 0.0)
  assert_eq(destination.opacity, 0.25)
  assert_eq(destination.transparent, true)
  assert_eq(destination.fog, false)
  assert_eq(destination.depth_write, false)
  assert_eq(destination.depth_test, false)
  assert_eq(destination.depth_func.to_int(), 6)
  assert_eq(destination.color_write, false)
  assert_eq(destination.premultiplied_alpha, true)
  assert_eq(destination.visible, false)
  match destination.map {
    None => assert_eq(false, true)
    Some(stored) => assert_eq(physical_equal(stored, map), true)
  }
  destination.color.g = 0.5
  assert_eq(source.color.g, 1.0)
  assert_eq(source.opacity, 0.25)
}

///|
test "LineBasicMaterial stores and copies alphaTest" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.alpha_test, 0.0)
  let source = @materials.LineBasicMaterial::new()
  source.alpha_test = 0.4
  assert_eq(defaults.alpha_test, 0.0)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.alpha_test, 0.4)
  destination.alpha_test = 0.8
  assert_eq(source.alpha_test, 0.4)
}

///|
test "LineDashedMaterial stores scale, dash, and gap" {
  let defaults = @materials.LineDashedMaterial::new()
  assert_eq(defaults.scale, 1.0)
  assert_eq(defaults.dash_size, 3.0)
  assert_eq(defaults.gap_size, 1.0)
  assert_eq(defaults.line.color.r, 1.0)
  assert_eq(defaults.line.color.g, 1.0)
  assert_eq(defaults.line.color.b, 1.0)
  assert_eq(defaults.line.map is None, true)
  assert_eq(defaults.line.alpha_test, 0.0)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  let source = @materials.LineDashedMaterial::new(
    hex=0x00FF00,
    scale=2.0,
    dash_size=4.0,
    gap_size=0.5,
  )
  source.line.map = Some(map)
  assert_eq(source.line.color.r, 0.0)
  assert_eq(source.line.color.g, 1.0)
  assert_eq(source.line.color.b, 0.0)
  let destination = @materials.LineDashedMaterial::new()
  let color = destination.line.color
  let copied = destination.copy(source)
  assert_eq(physical_equal(copied, destination), true)
  assert_eq(physical_equal(destination.line.color, color), true)
  assert_eq(destination.line.color.g, 1.0)
  assert_eq(destination.scale, 2.0)
  assert_eq(destination.dash_size, 4.0)
  assert_eq(destination.gap_size, 0.5)
  match destination.line.map {
    None => assert_eq(false, true)
    Some(stored) => assert_eq(physical_equal(stored, map), true)
  }
  destination.line.color.g = 0.5
  destination.dash_size = 9.0
  assert_eq(source.line.color.g, 1.0)
  assert_eq(source.dash_size, 4.0)
  assert_eq(defaults.scale, 1.0)
  assert_eq(defaults.dash_size, 3.0)
  assert_eq(defaults.gap_size, 1.0)
}

///|
test "LineDashedMaterial keeps distances inside the dash" {
  let material = @materials.LineDashedMaterial::new()
  assert_eq(material.keeps_distance(0.0), true)
  assert_eq(material.keeps_distance(3.0), true)
  assert_eq(material.keeps_distance(3.5), false)
  assert_eq(material.keeps_distance(4.0), true)
  assert_eq(material.keeps_distance(8.0), true)
  assert_eq(material.keeps_distance(-0.5), false)
  let scaled = @materials.LineDashedMaterial::new(scale=2.0)
  assert_eq(scaled.keeps_distance(1.5), true)
  assert_eq(scaled.keeps_distance(1.75), false)
  assert_eq(material.scale, 1.0)
  assert_eq(material.dash_size, 3.0)
  assert_eq(material.gap_size, 1.0)
}

///|
test "panic LineDashedMaterial zero period" {
  let material = @materials.LineDashedMaterial::new(dash_size=0.0, gap_size=0.0)
  ignore(material.keeps_distance(1.0))
}

///|
test "LineBasicMaterial stores and copies vertex colors" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.vertex_colors, false)
  let source = @materials.LineBasicMaterial::new()
  source.vertex_colors = true
  assert_eq(defaults.vertex_colors, false)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.vertex_colors, true)
  destination.vertex_colors = false
  assert_eq(source.vertex_colors, true)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.vertex_colors = true
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  assert_eq(other.line.vertex_colors, true)
  other.line.vertex_colors = false
  assert_eq(dashed.line.vertex_colors, true)
}

///|
test "LineBasicMaterial stores and copies toneMapped" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.tone_mapped, true)
  let source = @materials.LineBasicMaterial::new()
  source.tone_mapped = false
  assert_eq(defaults.tone_mapped, true)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.tone_mapped, false)
  destination.tone_mapped = true
  assert_eq(source.tone_mapped, false)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.tone_mapped = false
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  assert_eq(other.line.tone_mapped, false)
  other.line.tone_mapped = true
  assert_eq(dashed.line.tone_mapped, false)
}

///|
test "LineBasicMaterial stores and copies alphaHash" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.alpha_hash, false)
  let source = @materials.LineBasicMaterial::new()
  source.alpha_hash = true
  assert_eq(defaults.alpha_hash, false)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.alpha_hash, true)
  destination.alpha_hash = false
  assert_eq(source.alpha_hash, true)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.alpha_hash = true
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  assert_eq(other.line.alpha_hash, true)
  other.line.alpha_hash = false
  assert_eq(dashed.line.alpha_hash, true)
}

///|
test "LineBasicMaterial stores and copies alphaToCoverage" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.alpha_to_coverage, false)
  let source = @materials.LineBasicMaterial::new()
  source.alpha_to_coverage = true
  assert_eq(defaults.alpha_to_coverage, false)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.alpha_to_coverage, true)
  destination.alpha_to_coverage = false
  assert_eq(source.alpha_to_coverage, true)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.alpha_to_coverage = true
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  assert_eq(other.line.alpha_to_coverage, true)
  other.line.alpha_to_coverage = false
  assert_eq(dashed.line.alpha_to_coverage, true)
}

///|
test "LineBasicMaterial stores and copies dithering" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.dithering, false)
  let source = @materials.LineBasicMaterial::new()
  source.dithering = true
  assert_eq(defaults.dithering, false)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.dithering, true)
  destination.dithering = false
  assert_eq(source.dithering, true)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.dithering = true
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  assert_eq(other.line.dithering, true)
  other.line.dithering = false
  assert_eq(dashed.line.dithering, true)
}

///|
test "LineBasicMaterial stores and copies polygonOffset" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.polygon_offset, false)
  assert_eq(defaults.polygon_offset_factor, 0.0)
  assert_eq(defaults.polygon_offset_units, 0.0)
  let source = @materials.LineBasicMaterial::new()
  source.polygon_offset = true
  source.polygon_offset_factor = 1.0
  source.polygon_offset_units = -2.0
  assert_eq(defaults.polygon_offset, false)
  assert_eq(defaults.polygon_offset_factor, 0.0)
  assert_eq(defaults.polygon_offset_units, 0.0)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.polygon_offset, true)
  assert_eq(destination.polygon_offset_factor, 1.0)
  assert_eq(destination.polygon_offset_units, -2.0)
  destination.polygon_offset_factor = 3.0
  destination.polygon_offset_units = 5.0
  assert_eq(source.polygon_offset_factor, 1.0)
  assert_eq(source.polygon_offset_units, -2.0)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.polygon_offset = true
  dashed.line.polygon_offset_factor = 1.0
  dashed.line.polygon_offset_units = -2.0
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  assert_eq(other.line.polygon_offset, true)
  assert_eq(other.line.polygon_offset_factor, 1.0)
  assert_eq(other.line.polygon_offset_units, -2.0)
  other.line.polygon_offset_factor = 9.0
  assert_eq(dashed.line.polygon_offset_factor, 1.0)
}

///|
test "LineBasicMaterial stores and copies clipShadows" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.clip_shadows, false)
  let source = @materials.LineBasicMaterial::new()
  source.clip_shadows = true
  assert_eq(defaults.clip_shadows, false)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.clip_shadows, true)
  destination.clip_shadows = false
  assert_eq(source.clip_shadows, true)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.clip_shadows = true
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  assert_eq(other.line.clip_shadows, true)
  other.line.clip_shadows = false
  assert_eq(dashed.line.clip_shadows, true)
}

///|
test "LineBasicMaterial stores and copies clipIntersection" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.clip_intersection, false)
  let source = @materials.LineBasicMaterial::new()
  source.clip_intersection = true
  assert_eq(defaults.clip_intersection, false)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.clip_intersection, true)
  destination.clip_intersection = false
  assert_eq(source.clip_intersection, true)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.clip_intersection = true
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  assert_eq(other.line.clip_intersection, true)
  other.line.clip_intersection = false
  assert_eq(dashed.line.clip_intersection, true)
}

///|
test "LineBasicMaterial stores and copies allowOverride" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.allow_override, true)
  let source = @materials.LineBasicMaterial::new()
  source.allow_override = false
  assert_eq(defaults.allow_override, true)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.allow_override, false)
  destination.allow_override = true
  assert_eq(source.allow_override, false)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.allow_override = false
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  assert_eq(other.line.allow_override, false)
  other.line.allow_override = true
  assert_eq(dashed.line.allow_override, false)
}

///|
test "LineBasicMaterial stores and copies blendAlpha" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.blend_alpha, 0.0)
  let source = @materials.LineBasicMaterial::new()
  source.blend_alpha = 0.25
  assert_eq(defaults.blend_alpha, 0.0)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.blend_alpha, 0.25)
  destination.blend_alpha = 0.5
  assert_eq(source.blend_alpha, 0.25)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.blend_alpha = 0.25
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  assert_eq(other.line.blend_alpha, 0.25)
  other.line.blend_alpha = 0.75
  assert_eq(dashed.line.blend_alpha, 0.25)
}
