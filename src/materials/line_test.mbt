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

///|
test "LineBasicMaterial stores and copies blendColor" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.blend_color.r, 0.0)
  assert_eq(defaults.blend_color.g, 0.0)
  assert_eq(defaults.blend_color.b, 0.0)
  let source = @materials.LineBasicMaterial::new()
  source.blend_color.r = 1.0
  assert_eq(defaults.blend_color.r, 0.0)
  let destination = @materials.LineBasicMaterial::new()
  let color = destination.blend_color
  ignore(destination.copy(source))
  assert_eq(physical_equal(destination.blend_color, color), true)
  assert_eq(destination.blend_color.r, 1.0)
  assert_eq(destination.blend_color.g, 0.0)
  assert_eq(destination.blend_color.b, 0.0)
  destination.blend_color.r = 0.5
  assert_eq(source.blend_color.r, 1.0)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.blend_color.r = 1.0
  let other = @materials.LineDashedMaterial::new()
  let dashed_color = other.line.blend_color
  ignore(other.copy(dashed))
  assert_eq(physical_equal(other.line.blend_color, dashed_color), true)
  assert_eq(other.line.blend_color.r, 1.0)
  assert_eq(other.line.blend_color.g, 0.0)
  assert_eq(other.line.blend_color.b, 0.0)
  other.line.blend_color.r = 0.5
  assert_eq(dashed.line.blend_color.r, 1.0)
}

///|
test "LineBasicMaterial stores and copies blending" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.blending is @constants.Blending::Normal, true)
  assert_eq(defaults.blending.to_int(), 1)
  let source = @materials.LineBasicMaterial::new()
  source.blending = @constants.Blending::Additive
  assert_eq(defaults.blending is @constants.Blending::Normal, true)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.blending is @constants.Blending::Additive, true)
  assert_eq(destination.blending.to_int(), 2)
  destination.blending = @constants.Blending::Multiply
  assert_eq(source.blending is @constants.Blending::Additive, true)
  assert_eq(destination.blending.to_int(), 4)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.blending = @constants.Blending::Additive
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  assert_eq(other.line.blending is @constants.Blending::Additive, true)
  assert_eq(other.line.blending.to_int(), 2)
  other.line.blending = @constants.Blending::Subtractive
  assert_eq(dashed.line.blending is @constants.Blending::Additive, true)
  assert_eq(other.line.blending.to_int(), 3)
}

///|
test "LineBasicMaterial stores and copies blendSrc" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.blend_src is @constants.BlendFactor::SrcAlpha, true)
  assert_eq(defaults.blend_src.to_int(), 204)
  let source = @materials.LineBasicMaterial::new()
  source.blend_src = @constants.BlendFactor::One
  assert_eq(defaults.blend_src is @constants.BlendFactor::SrcAlpha, true)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.blend_src is @constants.BlendFactor::One, true)
  assert_eq(destination.blend_src.to_int(), 201)
  destination.blend_src = @constants.BlendFactor::Zero
  assert_eq(source.blend_src is @constants.BlendFactor::One, true)
  assert_eq(destination.blend_src.to_int(), 200)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.blend_src = @constants.BlendFactor::One
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  assert_eq(other.line.blend_src is @constants.BlendFactor::One, true)
  assert_eq(other.line.blend_src.to_int(), 201)
  other.line.blend_src = @constants.BlendFactor::DstColor
  assert_eq(dashed.line.blend_src is @constants.BlendFactor::One, true)
  assert_eq(other.line.blend_src.to_int(), 208)
}

///|
test "LineBasicMaterial stores and copies blendDst" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.blend_dst is @constants.BlendFactor::OneMinusSrcAlpha, true)
  assert_eq(defaults.blend_dst.to_int(), 205)
  let source = @materials.LineBasicMaterial::new()
  source.blend_dst = @constants.BlendFactor::Zero
  assert_eq(defaults.blend_dst is @constants.BlendFactor::OneMinusSrcAlpha, true)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.blend_dst is @constants.BlendFactor::Zero, true)
  assert_eq(destination.blend_dst.to_int(), 200)
  destination.blend_dst = @constants.BlendFactor::One
  assert_eq(source.blend_dst is @constants.BlendFactor::Zero, true)
  assert_eq(destination.blend_dst.to_int(), 201)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.blend_dst = @constants.BlendFactor::Zero
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  assert_eq(other.line.blend_dst is @constants.BlendFactor::Zero, true)
  assert_eq(other.line.blend_dst.to_int(), 200)
  other.line.blend_dst = @constants.BlendFactor::DstColor
  assert_eq(dashed.line.blend_dst is @constants.BlendFactor::Zero, true)
  assert_eq(other.line.blend_dst.to_int(), 208)
}

///|
test "LineBasicMaterial stores and copies blendEquation" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.blend_equation is @constants.BlendEquation::Add, true)
  assert_eq(defaults.blend_equation.to_int(), 100)
  let source = @materials.LineBasicMaterial::new()
  source.blend_equation = @constants.BlendEquation::Subtract
  assert_eq(defaults.blend_equation is @constants.BlendEquation::Add, true)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.blend_equation is @constants.BlendEquation::Subtract, true)
  assert_eq(destination.blend_equation.to_int(), 101)
  destination.blend_equation = @constants.BlendEquation::Max
  assert_eq(source.blend_equation is @constants.BlendEquation::Subtract, true)
  assert_eq(destination.blend_equation.to_int(), 104)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.blend_equation = @constants.BlendEquation::Subtract
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  assert_eq(other.line.blend_equation is @constants.BlendEquation::Subtract, true)
  assert_eq(other.line.blend_equation.to_int(), 101)
  other.line.blend_equation = @constants.BlendEquation::Min
  assert_eq(dashed.line.blend_equation is @constants.BlendEquation::Subtract, true)
  assert_eq(other.line.blend_equation.to_int(), 103)
}

///|
test "LineBasicMaterial stores and copies blendSrcAlpha" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.blend_src_alpha is None, true)
  let source = @materials.LineBasicMaterial::new()
  source.blend_src_alpha = Some(@constants.BlendFactor::One)
  assert_eq(defaults.blend_src_alpha is None, true)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  match destination.blend_src_alpha {
    Some(factor) => {
      assert_eq(factor is @constants.BlendFactor::One, true)
      assert_eq(factor.to_int(), 201)
    }
    None => abort("destination blendSrcAlpha is empty")
  }
  destination.blend_src_alpha = Some(@constants.BlendFactor::Zero)
  match source.blend_src_alpha {
    Some(factor) => assert_eq(factor.to_int(), 201)
    None => abort("source blendSrcAlpha is empty")
  }
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.blend_src_alpha = Some(@constants.BlendFactor::One)
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  match other.line.blend_src_alpha {
    Some(factor) => assert_eq(factor.to_int(), 201)
    None => abort("dashed destination blendSrcAlpha is empty")
  }
  other.line.blend_src_alpha = None
  match dashed.line.blend_src_alpha {
    Some(factor) => assert_eq(factor.to_int(), 201)
    None => abort("dashed source blendSrcAlpha is empty")
  }
  assert_eq(other.line.blend_src_alpha is None, true)
}

///|
test "LineBasicMaterial stores and copies blendDstAlpha" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.blend_dst_alpha is None, true)
  let source = @materials.LineBasicMaterial::new()
  source.blend_dst_alpha = Some(@constants.BlendFactor::One)
  assert_eq(defaults.blend_dst_alpha is None, true)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  match destination.blend_dst_alpha {
    Some(factor) => {
      assert_eq(factor is @constants.BlendFactor::One, true)
      assert_eq(factor.to_int(), 201)
    }
    None => abort("destination blendDstAlpha is empty")
  }
  destination.blend_dst_alpha = Some(@constants.BlendFactor::Zero)
  match source.blend_dst_alpha {
    Some(factor) => assert_eq(factor.to_int(), 201)
    None => abort("source blendDstAlpha is empty")
  }
  match destination.blend_dst_alpha {
    Some(factor) => assert_eq(factor.to_int(), 200)
    None => abort("changed destination blendDstAlpha is empty")
  }
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.blend_dst_alpha = Some(@constants.BlendFactor::One)
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  match other.line.blend_dst_alpha {
    Some(factor) => assert_eq(factor.to_int(), 201)
    None => abort("dashed destination blendDstAlpha is empty")
  }
  other.line.blend_dst_alpha = None
  match dashed.line.blend_dst_alpha {
    Some(factor) => assert_eq(factor.to_int(), 201)
    None => abort("dashed source blendDstAlpha is empty")
  }
  assert_eq(other.line.blend_dst_alpha is None, true)
}

///|
test "LineBasicMaterial stores and copies blendEquationAlpha" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.blend_equation_alpha is None, true)
  let source = @materials.LineBasicMaterial::new()
  source.blend_equation_alpha = Some(@constants.BlendEquation::Subtract)
  assert_eq(defaults.blend_equation_alpha is None, true)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  match destination.blend_equation_alpha {
    Some(equation) => {
      assert_eq(equation is @constants.BlendEquation::Subtract, true)
      assert_eq(equation.to_int(), 101)
    }
    None => abort("destination blendEquationAlpha is empty")
  }
  destination.blend_equation_alpha = Some(@constants.BlendEquation::Max)
  match source.blend_equation_alpha {
    Some(equation) => assert_eq(equation.to_int(), 101)
    None => abort("source blendEquationAlpha is empty")
  }
  match destination.blend_equation_alpha {
    Some(equation) => assert_eq(equation.to_int(), 104)
    None => abort("changed destination blendEquationAlpha is empty")
  }
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.blend_equation_alpha = Some(@constants.BlendEquation::Subtract)
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  match other.line.blend_equation_alpha {
    Some(equation) => assert_eq(equation.to_int(), 101)
    None => abort("dashed destination blendEquationAlpha is empty")
  }
  other.line.blend_equation_alpha = None
  match dashed.line.blend_equation_alpha {
    Some(equation) => assert_eq(equation.to_int(), 101)
    None => abort("dashed source blendEquationAlpha is empty")
  }
  assert_eq(other.line.blend_equation_alpha is None, true)
}

///|
test "LineBasicMaterial stores and copies stencilWriteMask" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.stencil_write_mask, 255)
  let source = @materials.LineBasicMaterial::new()
  source.stencil_write_mask = 0
  assert_eq(defaults.stencil_write_mask, 255)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.stencil_write_mask, 0)
  destination.stencil_write_mask = 1
  assert_eq(source.stencil_write_mask, 0)
  assert_eq(destination.stencil_write_mask, 1)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.stencil_write_mask = 0
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  assert_eq(other.line.stencil_write_mask, 0)
  other.line.stencil_write_mask = 9
  assert_eq(dashed.line.stencil_write_mask, 0)
  assert_eq(other.line.stencil_write_mask, 9)
}

///|
test "LineBasicMaterial stores and copies stencilFunc" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.stencil_func is @constants.StencilFunc::Always, true)
  assert_eq(defaults.stencil_func.to_int(), 519)
  let source = @materials.LineBasicMaterial::new()
  source.stencil_func = @constants.StencilFunc::Never
  assert_eq(defaults.stencil_func is @constants.StencilFunc::Always, true)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.stencil_func is @constants.StencilFunc::Never, true)
  assert_eq(destination.stencil_func.to_int(), 512)
  destination.stencil_func = @constants.StencilFunc::Equal
  assert_eq(source.stencil_func.to_int(), 512)
  assert_eq(destination.stencil_func.to_int(), 514)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.stencil_func = @constants.StencilFunc::Never
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  assert_eq(other.line.stencil_func.to_int(), 512)
  other.line.stencil_func = @constants.StencilFunc::Greater
  assert_eq(dashed.line.stencil_func.to_int(), 512)
  assert_eq(other.line.stencil_func.to_int(), 516)
}

///|
test "LineBasicMaterial stores and copies stencilRef" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.stencil_ref, 0)
  let source = @materials.LineBasicMaterial::new()
  source.stencil_ref = 1
  assert_eq(defaults.stencil_ref, 0)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.stencil_ref, 1)
  destination.stencil_ref = 7
  assert_eq(source.stencil_ref, 1)
  assert_eq(destination.stencil_ref, 7)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.stencil_ref = 1
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  assert_eq(other.line.stencil_ref, 1)
  other.line.stencil_ref = 9
  assert_eq(dashed.line.stencil_ref, 1)
  assert_eq(other.line.stencil_ref, 9)
}

///|
test "LineBasicMaterial stores and copies stencilFuncMask" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.stencil_func_mask, 255)
  let source = @materials.LineBasicMaterial::new()
  source.stencil_func_mask = 0
  assert_eq(defaults.stencil_func_mask, 255)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.stencil_func_mask, 0)
  destination.stencil_func_mask = 1
  assert_eq(source.stencil_func_mask, 0)
  assert_eq(destination.stencil_func_mask, 1)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.stencil_func_mask = 0
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  assert_eq(other.line.stencil_func_mask, 0)
  other.line.stencil_func_mask = 9
  assert_eq(dashed.line.stencil_func_mask, 0)
  assert_eq(other.line.stencil_func_mask, 9)
}

///|
test "LineBasicMaterial stores and copies stencilFail" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.stencil_fail is @constants.StencilOp::Keep, true)
  assert_eq(defaults.stencil_fail.to_int(), 7680)
  let source = @materials.LineBasicMaterial::new()
  source.stencil_fail = @constants.StencilOp::Zero
  assert_eq(defaults.stencil_fail is @constants.StencilOp::Keep, true)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.stencil_fail is @constants.StencilOp::Zero, true)
  assert_eq(destination.stencil_fail.to_int(), 0)
  destination.stencil_fail = @constants.StencilOp::Replace
  assert_eq(source.stencil_fail.to_int(), 0)
  assert_eq(destination.stencil_fail.to_int(), 7681)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.stencil_fail = @constants.StencilOp::Zero
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  assert_eq(other.line.stencil_fail is @constants.StencilOp::Zero, true)
  assert_eq(other.line.stencil_fail.to_int(), 0)
  other.line.stencil_fail = @constants.StencilOp::Increment
  assert_eq(dashed.line.stencil_fail.to_int(), 0)
  assert_eq(other.line.stencil_fail.to_int(), 7682)
}

///|
test "LineBasicMaterial stores and copies stencilZFail" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.stencil_z_fail is @constants.StencilOp::Keep, true)
  assert_eq(defaults.stencil_z_fail.to_int(), 7680)
  let source = @materials.LineBasicMaterial::new()
  source.stencil_z_fail = @constants.StencilOp::Zero
  assert_eq(defaults.stencil_z_fail is @constants.StencilOp::Keep, true)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.stencil_z_fail is @constants.StencilOp::Zero, true)
  assert_eq(destination.stencil_z_fail.to_int(), 0)
  destination.stencil_z_fail = @constants.StencilOp::Replace
  assert_eq(source.stencil_z_fail.to_int(), 0)
  assert_eq(destination.stencil_z_fail.to_int(), 7681)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.stencil_z_fail = @constants.StencilOp::Zero
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  assert_eq(other.line.stencil_z_fail is @constants.StencilOp::Zero, true)
  assert_eq(other.line.stencil_z_fail.to_int(), 0)
  other.line.stencil_z_fail = @constants.StencilOp::Increment
  assert_eq(dashed.line.stencil_z_fail.to_int(), 0)
  assert_eq(other.line.stencil_z_fail.to_int(), 7682)
}

///|
test "LineBasicMaterial stores and copies stencilZPass" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.stencil_z_pass is @constants.StencilOp::Keep, true)
  assert_eq(defaults.stencil_z_pass.to_int(), 7680)
  let source = @materials.LineBasicMaterial::new()
  source.stencil_z_pass = @constants.StencilOp::Zero
  assert_eq(defaults.stencil_z_pass is @constants.StencilOp::Keep, true)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.stencil_z_pass is @constants.StencilOp::Zero, true)
  assert_eq(destination.stencil_z_pass.to_int(), 0)
  destination.stencil_z_pass = @constants.StencilOp::Replace
  assert_eq(source.stencil_z_pass.to_int(), 0)
  assert_eq(destination.stencil_z_pass.to_int(), 7681)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.stencil_z_pass = @constants.StencilOp::Zero
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  assert_eq(other.line.stencil_z_pass is @constants.StencilOp::Zero, true)
  assert_eq(other.line.stencil_z_pass.to_int(), 0)
  other.line.stencil_z_pass = @constants.StencilOp::Increment
  assert_eq(dashed.line.stencil_z_pass.to_int(), 0)
  assert_eq(other.line.stencil_z_pass.to_int(), 7682)
}

///|
test "LineBasicMaterial stores and copies stencilWrite" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.stencil_write, false)
  let source = @materials.LineBasicMaterial::new()
  source.stencil_write = true
  assert_eq(defaults.stencil_write, false)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.stencil_write, true)
  destination.stencil_write = false
  assert_eq(source.stencil_write, true)
  assert_eq(destination.stencil_write, false)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.stencil_write = true
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  assert_eq(other.line.stencil_write, true)
  other.line.stencil_write = false
  assert_eq(dashed.line.stencil_write, true)
  assert_eq(other.line.stencil_write, false)
}

///|
test "LineBasicMaterial stores and copies clippingPlanes" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.clipping_planes is None, true)
  let source = @materials.LineBasicMaterial::new()
  source.clipping_planes = Some([@math.Plane::new(constant=1.0)])
  assert_eq(defaults.clipping_planes is None, true)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  match destination.clipping_planes {
    None => abort("copied clipping planes")
    Some(planes) => {
      assert_eq(planes.length(), 1)
      assert_eq(planes[0].constant, 1.0)
    }
  }
  destination.clipping_planes = Some([@math.Plane::new(constant=2.0)])
  match source.clipping_planes {
    None => abort("source clipping planes")
    Some(planes) => assert_eq(planes[0].constant, 1.0)
  }
  match destination.clipping_planes {
    None => abort("destination clipping planes")
    Some(planes) => assert_eq(planes[0].constant, 2.0)
  }
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.clipping_planes = Some([@math.Plane::new(constant=1.0)])
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  match other.line.clipping_planes {
    None => abort("dashed clipping planes")
    Some(planes) => assert_eq(planes[0].constant, 1.0)
  }
  other.line.clipping_planes = Some([@math.Plane::new(constant=3.0)])
  match dashed.line.clipping_planes {
    None => abort("dashed source clipping planes")
    Some(planes) => assert_eq(planes[0].constant, 1.0)
  }
  match other.line.clipping_planes {
    None => abort("dashed destination clipping planes")
    Some(planes) => assert_eq(planes[0].constant, 3.0)
  }
}

///|
test "LineBasicMaterial stores and copies precision" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.precision is None, true)
  let source = @materials.LineBasicMaterial::new()
  source.precision = Some(@constants.Precision::Highp)
  assert_eq(defaults.precision is None, true)
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  match destination.precision {
    None => abort("copied precision")
    Some(precision) => assert_eq(precision is @constants.Precision::Highp, true)
  }
  destination.precision = Some(@constants.Precision::Mediump)
  match source.precision {
    None => abort("source precision")
    Some(precision) => assert_eq(precision is @constants.Precision::Highp, true)
  }
  match destination.precision {
    None => abort("destination precision")
    Some(precision) => assert_eq(precision is @constants.Precision::Mediump, true)
  }
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.precision = Some(@constants.Precision::Highp)
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  match other.line.precision {
    None => abort("dashed precision")
    Some(precision) => assert_eq(precision is @constants.Precision::Highp, true)
  }
  other.line.precision = Some(@constants.Precision::Lowp)
  match dashed.line.precision {
    None => abort("dashed source precision")
    Some(precision) => assert_eq(precision is @constants.Precision::Highp, true)
  }
  match other.line.precision {
    None => abort("dashed destination precision")
    Some(precision) => assert_eq(precision is @constants.Precision::Lowp, true)
  }
}

///|
test "LineBasicMaterial stores and copies userData" {
  let defaults = @materials.LineBasicMaterial::new()
  match defaults.user_data.get("label") {
    None => ()
    Some(_) => abort("default user data")
  }
  let source = @materials.LineBasicMaterial::new()
  source.user_data.set("label", "line")
  match defaults.user_data.get("label") {
    None => ()
    Some(_) => abort("other user data")
  }
  let destination = @materials.LineBasicMaterial::new()
  ignore(destination.copy(source))
  match destination.user_data.get("label") {
    None => abort("copied user data")
    Some(label) => assert_eq(label, "line")
  }
  destination.user_data.set("label", "copy")
  match source.user_data.get("label") {
    None => abort("source user data")
    Some(label) => assert_eq(label, "line")
  }
  match destination.user_data.get("label") {
    None => abort("destination user data")
    Some(label) => assert_eq(label, "copy")
  }
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.user_data.set("label", "dash")
  let other = @materials.LineDashedMaterial::new()
  ignore(other.copy(dashed))
  match other.line.user_data.get("label") {
    None => abort("dashed user data")
    Some(label) => assert_eq(label, "dash")
  }
  other.line.user_data.set("label", "other")
  match dashed.line.user_data.get("label") {
    None => abort("dashed source user data")
    Some(label) => assert_eq(label, "dash")
  }
  match other.line.user_data.get("label") {
    None => abort("dashed destination user data")
    Some(label) => assert_eq(label, "other")
  }
}

///|
test "LineBasicMaterial stores version" {
  let defaults = @materials.LineBasicMaterial::new()
  assert_eq(defaults.version, 0)
  let source = @materials.LineBasicMaterial::new()
  source.version = 1
  assert_eq(defaults.version, 0)
  let destination = @materials.LineBasicMaterial::new()
  destination.version = 3
  ignore(destination.copy(source))
  assert_eq(destination.version, 3)
  assert_eq(source.version, 1)
  destination.version = 2
  assert_eq(source.version, 1)
  assert_eq(destination.version, 2)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.version = 4
  let other = @materials.LineDashedMaterial::new()
  other.line.version = 5
  ignore(other.copy(dashed))
  assert_eq(other.line.version, 5)
  assert_eq(dashed.line.version, 4)
  other.line.version = 6
  assert_eq(dashed.line.version, 4)
}

///|
test "LineBasicMaterial needsUpdate increments version" {
  let source = @materials.LineBasicMaterial::new()
  source.set_needs_update(false)
  assert_eq(source.version, 0)
  source.set_needs_update(true)
  assert_eq(source.version, 1)
  source.set_needs_update(true)
  assert_eq(source.version, 2)
  let other = @materials.LineBasicMaterial::new()
  assert_eq(other.version, 0)
  let destination = @materials.LineBasicMaterial::new()
  destination.version = 3
  ignore(destination.copy(source))
  assert_eq(destination.version, 3)
  assert_eq(source.version, 2)
  let dashed = @materials.LineDashedMaterial::new()
  dashed.line.set_needs_update(true)
  assert_eq(dashed.line.version, 1)
  let copied = @materials.LineDashedMaterial::new()
  copied.line.version = 5
  ignore(copied.copy(dashed))
  assert_eq(copied.line.version, 5)
  assert_eq(dashed.line.version, 1)
  dashed.line.set_needs_update(false)
  assert_eq(dashed.line.version, 1)
}
