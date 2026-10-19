///|
test "SpriteMaterial stores color, map, and transparency" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.color.r, 1.0)
  assert_eq(defaults.color.g, 1.0)
  assert_eq(defaults.color.b, 1.0)
  assert_eq(defaults.map is None, true)
  assert_eq(defaults.opacity, 1.0)
  assert_eq(defaults.transparent, true)
  assert_eq(defaults.rotation, 0.0)
  assert_eq(defaults.size_attenuation, true)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  let material = @materials.SpriteMaterial::new(
    hex=0xFF0000,
    opacity=0.25,
    transparent=false,
  )
  material.map = Some(map)
  assert_eq(material.color.r, 1.0)
  assert_eq(material.color.g, 0.0)
  assert_eq(material.color.b, 0.0)
  assert_eq(material.opacity, 0.25)
  assert_eq(material.transparent, false)
  match material.map {
    None => assert_eq(false, true)
    Some(stored) => {
      assert_eq(physical_equal(stored, map), true)
      assert_eq(stored.width, 1)
      assert_eq(stored.height, 1)
    }
  }
  material.color.r = 0.5
  assert_eq(material.color.r, 0.5)
  assert_eq(defaults.color.r, 1.0)
  assert_eq(defaults.opacity, 1.0)
}

///|
test "SpriteMaterial stores alpha map and fog" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.fog, true)
  assert_eq(defaults.alpha_map is None, true)
  let pixels = FixedArray::make(4, b'\x00')
  pixels[1] = b'\x80'
  let alpha = @textures.Texture::from_rgba8(1, 1, pixels)
  let material = @materials.SpriteMaterial::new(fog=false)
  material.alpha_map = Some(alpha)
  assert_eq(material.fog, false)
  match material.alpha_map {
    None => assert_eq(false, true)
    Some(stored) => {
      assert_eq(physical_equal(stored, alpha), true)
      assert_eq(stored.width, 1)
      assert_eq(stored.data[1], b'\x80')
    }
  }
  assert_eq(defaults.fog, true)
  assert_eq(defaults.alpha_map is None, true)
}

///|
test "SpriteMaterial.copy writes color and shares maps" {
  let color_pixels = FixedArray::make(4, b'\xFF')
  let color_map = @textures.Texture::from_rgba8(1, 1, color_pixels)
  let alpha_pixels = FixedArray::make(4, b'\x00')
  alpha_pixels[1] = b'\x80'
  let alpha_map = @textures.Texture::from_rgba8(1, 1, alpha_pixels)
  let source = @materials.SpriteMaterial::new(
    rotation=0.5,
    size_attenuation=false,
    hex=0xFF0000,
    opacity=0.25,
    transparent=false,
    fog=false,
  )
  source.map = Some(color_map)
  source.alpha_map = Some(alpha_map)
  source.depth_write = false
  source.depth_test = false
  source.depth_func = @constants.DepthFunc::Greater
  source.color_write = false
  source.premultiplied_alpha = true
  source.visible = false
  let destination = @materials.SpriteMaterial::new()
  assert_eq(destination.depth_write, true)
  assert_eq(destination.depth_test, true)
  assert_eq(destination.depth_func.to_int(), 3)
  assert_eq(destination.color_write, true)
  assert_eq(destination.premultiplied_alpha, false)
  assert_eq(destination.visible, true)
  let color = destination.color
  let copied = destination.copy(source)
  assert_eq(physical_equal(copied, destination), true)
  assert_eq(physical_equal(destination.color, color), true)
  assert_eq(destination.color.r, 1.0)
  assert_eq(destination.color.g, 0.0)
  assert_eq(destination.color.b, 0.0)
  assert_eq(destination.opacity, 0.25)
  assert_eq(destination.transparent, false)
  assert_eq(destination.fog, false)
  assert_eq(destination.rotation, 0.5)
  assert_eq(destination.size_attenuation, false)
  assert_eq(destination.depth_write, false)
  assert_eq(destination.depth_test, false)
  assert_eq(destination.depth_func.to_int(), 6)
  assert_eq(destination.color_write, false)
  assert_eq(destination.premultiplied_alpha, true)
  assert_eq(destination.visible, false)
  match destination.map {
    None => assert_eq(false, true)
    Some(stored) => assert_eq(physical_equal(stored, color_map), true)
  }
  match destination.alpha_map {
    None => assert_eq(false, true)
    Some(stored) => assert_eq(physical_equal(stored, alpha_map), true)
  }
  destination.color.r = 0.5
  assert_eq(source.color.r, 1.0)
  assert_eq(source.opacity, 0.25)
  assert_eq(source.rotation, 0.5)
}

///|
test "SpriteMaterial stores and copies alphaTest" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.alpha_test, 0.0)
  let source = @materials.SpriteMaterial::new()
  source.alpha_test = 0.4
  assert_eq(defaults.alpha_test, 0.0)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.alpha_test, 0.4)
  destination.alpha_test = 0.8
  assert_eq(source.alpha_test, 0.4)
}

///|
test "SpriteMaterial stores and copies vertex colors" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.vertex_colors, false)
  let source = @materials.SpriteMaterial::new()
  source.vertex_colors = true
  assert_eq(defaults.vertex_colors, false)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.vertex_colors, true)
  destination.vertex_colors = false
  assert_eq(source.vertex_colors, true)
}

///|
test "SpriteMaterial stores and copies toneMapped" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.tone_mapped, true)
  let source = @materials.SpriteMaterial::new()
  source.tone_mapped = false
  assert_eq(defaults.tone_mapped, true)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.tone_mapped, false)
  destination.tone_mapped = true
  assert_eq(source.tone_mapped, false)
}

///|
test "SpriteMaterial stores and copies alphaHash" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.alpha_hash, false)
  let source = @materials.SpriteMaterial::new()
  source.alpha_hash = true
  assert_eq(defaults.alpha_hash, false)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.alpha_hash, true)
  destination.alpha_hash = false
  assert_eq(source.alpha_hash, true)
}

///|
test "SpriteMaterial stores and copies alphaToCoverage" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.alpha_to_coverage, false)
  let source = @materials.SpriteMaterial::new()
  source.alpha_to_coverage = true
  assert_eq(defaults.alpha_to_coverage, false)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.alpha_to_coverage, true)
  destination.alpha_to_coverage = false
  assert_eq(source.alpha_to_coverage, true)
}

///|
test "SpriteMaterial stores and copies dithering" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.dithering, false)
  let source = @materials.SpriteMaterial::new()
  source.dithering = true
  assert_eq(defaults.dithering, false)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.dithering, true)
  destination.dithering = false
  assert_eq(source.dithering, true)
}

///|
test "SpriteMaterial stores and copies polygonOffset" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.polygon_offset, false)
  assert_eq(defaults.polygon_offset_factor, 0.0)
  assert_eq(defaults.polygon_offset_units, 0.0)
  let source = @materials.SpriteMaterial::new()
  source.polygon_offset = true
  source.polygon_offset_factor = 1.0
  source.polygon_offset_units = -2.0
  assert_eq(defaults.polygon_offset, false)
  assert_eq(defaults.polygon_offset_factor, 0.0)
  assert_eq(defaults.polygon_offset_units, 0.0)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.polygon_offset, true)
  assert_eq(destination.polygon_offset_factor, 1.0)
  assert_eq(destination.polygon_offset_units, -2.0)
  destination.polygon_offset_factor = 3.0
  destination.polygon_offset_units = 5.0
  assert_eq(source.polygon_offset_factor, 1.0)
  assert_eq(source.polygon_offset_units, -2.0)
}

///|
test "SpriteMaterial stores and copies clipShadows" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.clip_shadows, false)
  let source = @materials.SpriteMaterial::new()
  source.clip_shadows = true
  assert_eq(defaults.clip_shadows, false)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.clip_shadows, true)
  destination.clip_shadows = false
  assert_eq(source.clip_shadows, true)
}

///|
test "SpriteMaterial stores and copies clipIntersection" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.clip_intersection, false)
  let source = @materials.SpriteMaterial::new()
  source.clip_intersection = true
  assert_eq(defaults.clip_intersection, false)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.clip_intersection, true)
  destination.clip_intersection = false
  assert_eq(source.clip_intersection, true)
}

///|
test "SpriteMaterial stores and copies allowOverride" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.allow_override, true)
  let source = @materials.SpriteMaterial::new()
  source.allow_override = false
  assert_eq(defaults.allow_override, true)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.allow_override, false)
  destination.allow_override = true
  assert_eq(source.allow_override, false)
}

///|
test "SpriteMaterial stores and copies blendAlpha" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.blend_alpha, 0.0)
  let source = @materials.SpriteMaterial::new()
  source.blend_alpha = 0.25
  assert_eq(defaults.blend_alpha, 0.0)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.blend_alpha, 0.25)
  destination.blend_alpha = 0.5
  assert_eq(source.blend_alpha, 0.25)
}

///|
test "SpriteMaterial stores and copies blendColor" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.blend_color.r, 0.0)
  assert_eq(defaults.blend_color.g, 0.0)
  assert_eq(defaults.blend_color.b, 0.0)
  let source = @materials.SpriteMaterial::new()
  source.blend_color.r = 1.0
  assert_eq(defaults.blend_color.r, 0.0)
  let destination = @materials.SpriteMaterial::new()
  let color = destination.blend_color
  ignore(destination.copy(source))
  assert_eq(physical_equal(destination.blend_color, color), true)
  assert_eq(destination.blend_color.r, 1.0)
  assert_eq(destination.blend_color.g, 0.0)
  assert_eq(destination.blend_color.b, 0.0)
  destination.blend_color.r = 0.5
  assert_eq(source.blend_color.r, 1.0)
}

///|
test "SpriteMaterial stores and copies blending" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.blending is @constants.Blending::Normal, true)
  assert_eq(defaults.blending.to_int(), 1)
  let source = @materials.SpriteMaterial::new()
  source.blending = @constants.Blending::Additive
  assert_eq(defaults.blending is @constants.Blending::Normal, true)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.blending is @constants.Blending::Additive, true)
  assert_eq(destination.blending.to_int(), 2)
  destination.blending = @constants.Blending::Multiply
  assert_eq(source.blending is @constants.Blending::Additive, true)
  assert_eq(destination.blending.to_int(), 4)
}

///|
test "SpriteMaterial stores and copies blendSrc" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.blend_src is @constants.BlendFactor::SrcAlpha, true)
  assert_eq(defaults.blend_src.to_int(), 204)
  let source = @materials.SpriteMaterial::new()
  source.blend_src = @constants.BlendFactor::One
  assert_eq(defaults.blend_src is @constants.BlendFactor::SrcAlpha, true)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.blend_src is @constants.BlendFactor::One, true)
  assert_eq(destination.blend_src.to_int(), 201)
  destination.blend_src = @constants.BlendFactor::Zero
  assert_eq(source.blend_src is @constants.BlendFactor::One, true)
  assert_eq(destination.blend_src.to_int(), 200)
}

///|
test "SpriteMaterial stores and copies blendDst" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.blend_dst is @constants.BlendFactor::OneMinusSrcAlpha, true)
  assert_eq(defaults.blend_dst.to_int(), 205)
  let source = @materials.SpriteMaterial::new()
  source.blend_dst = @constants.BlendFactor::Zero
  assert_eq(defaults.blend_dst is @constants.BlendFactor::OneMinusSrcAlpha, true)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.blend_dst is @constants.BlendFactor::Zero, true)
  assert_eq(destination.blend_dst.to_int(), 200)
  destination.blend_dst = @constants.BlendFactor::One
  assert_eq(source.blend_dst is @constants.BlendFactor::Zero, true)
  assert_eq(destination.blend_dst.to_int(), 201)
}

///|
test "SpriteMaterial stores and copies blendEquation" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.blend_equation is @constants.BlendEquation::Add, true)
  assert_eq(defaults.blend_equation.to_int(), 100)
  let source = @materials.SpriteMaterial::new()
  source.blend_equation = @constants.BlendEquation::Subtract
  assert_eq(defaults.blend_equation is @constants.BlendEquation::Add, true)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.blend_equation is @constants.BlendEquation::Subtract, true)
  assert_eq(destination.blend_equation.to_int(), 101)
  destination.blend_equation = @constants.BlendEquation::Max
  assert_eq(source.blend_equation is @constants.BlendEquation::Subtract, true)
  assert_eq(destination.blend_equation.to_int(), 104)
}

///|
test "SpriteMaterial stores and copies blendSrcAlpha" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.blend_src_alpha is None, true)
  let source = @materials.SpriteMaterial::new()
  source.blend_src_alpha = Some(@constants.BlendFactor::One)
  assert_eq(defaults.blend_src_alpha is None, true)
  let destination = @materials.SpriteMaterial::new()
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
  match destination.blend_src_alpha {
    Some(factor) => assert_eq(factor.to_int(), 200)
    None => abort("changed destination blendSrcAlpha is empty")
  }
}

///|
test "SpriteMaterial stores and copies blendDstAlpha" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.blend_dst_alpha is None, true)
  let source = @materials.SpriteMaterial::new()
  source.blend_dst_alpha = Some(@constants.BlendFactor::One)
  assert_eq(defaults.blend_dst_alpha is None, true)
  let destination = @materials.SpriteMaterial::new()
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
}

///|
test "SpriteMaterial stores and copies blendEquationAlpha" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.blend_equation_alpha is None, true)
  let source = @materials.SpriteMaterial::new()
  source.blend_equation_alpha = Some(@constants.BlendEquation::Subtract)
  assert_eq(defaults.blend_equation_alpha is None, true)
  let destination = @materials.SpriteMaterial::new()
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
}

///|
test "SpriteMaterial stores and copies stencilWriteMask" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.stencil_write_mask, 255)
  let source = @materials.SpriteMaterial::new()
  source.stencil_write_mask = 0
  assert_eq(defaults.stencil_write_mask, 255)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.stencil_write_mask, 0)
  destination.stencil_write_mask = 1
  assert_eq(source.stencil_write_mask, 0)
  assert_eq(destination.stencil_write_mask, 1)
}

///|
test "SpriteMaterial stores and copies stencilFunc" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.stencil_func is @constants.StencilFunc::Always, true)
  assert_eq(defaults.stencil_func.to_int(), 519)
  let source = @materials.SpriteMaterial::new()
  source.stencil_func = @constants.StencilFunc::Never
  assert_eq(defaults.stencil_func is @constants.StencilFunc::Always, true)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.stencil_func is @constants.StencilFunc::Never, true)
  assert_eq(destination.stencil_func.to_int(), 512)
  destination.stencil_func = @constants.StencilFunc::Equal
  assert_eq(source.stencil_func.to_int(), 512)
  assert_eq(destination.stencil_func.to_int(), 514)
}

///|
test "SpriteMaterial stores and copies stencilRef" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.stencil_ref, 0)
  let source = @materials.SpriteMaterial::new()
  source.stencil_ref = 1
  assert_eq(defaults.stencil_ref, 0)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.stencil_ref, 1)
  destination.stencil_ref = 7
  assert_eq(source.stencil_ref, 1)
  assert_eq(destination.stencil_ref, 7)
}

///|
test "SpriteMaterial stores and copies stencilFuncMask" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.stencil_func_mask, 255)
  let source = @materials.SpriteMaterial::new()
  source.stencil_func_mask = 0
  assert_eq(defaults.stencil_func_mask, 255)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.stencil_func_mask, 0)
  destination.stencil_func_mask = 1
  assert_eq(source.stencil_func_mask, 0)
  assert_eq(destination.stencil_func_mask, 1)
}

///|
test "SpriteMaterial stores and copies stencilFail" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.stencil_fail is @constants.StencilOp::Keep, true)
  assert_eq(defaults.stencil_fail.to_int(), 7680)
  let source = @materials.SpriteMaterial::new()
  source.stencil_fail = @constants.StencilOp::Zero
  assert_eq(defaults.stencil_fail is @constants.StencilOp::Keep, true)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.stencil_fail is @constants.StencilOp::Zero, true)
  assert_eq(destination.stencil_fail.to_int(), 0)
  destination.stencil_fail = @constants.StencilOp::Replace
  assert_eq(source.stencil_fail.to_int(), 0)
  assert_eq(destination.stencil_fail.to_int(), 7681)
}

///|
test "SpriteMaterial stores and copies stencilZFail" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.stencil_z_fail is @constants.StencilOp::Keep, true)
  assert_eq(defaults.stencil_z_fail.to_int(), 7680)
  let source = @materials.SpriteMaterial::new()
  source.stencil_z_fail = @constants.StencilOp::Zero
  assert_eq(defaults.stencil_z_fail is @constants.StencilOp::Keep, true)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.stencil_z_fail is @constants.StencilOp::Zero, true)
  assert_eq(destination.stencil_z_fail.to_int(), 0)
  destination.stencil_z_fail = @constants.StencilOp::Replace
  assert_eq(source.stencil_z_fail.to_int(), 0)
  assert_eq(destination.stencil_z_fail.to_int(), 7681)
}

///|
test "SpriteMaterial stores and copies stencilZPass" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.stencil_z_pass is @constants.StencilOp::Keep, true)
  assert_eq(defaults.stencil_z_pass.to_int(), 7680)
  let source = @materials.SpriteMaterial::new()
  source.stencil_z_pass = @constants.StencilOp::Zero
  assert_eq(defaults.stencil_z_pass is @constants.StencilOp::Keep, true)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.stencil_z_pass is @constants.StencilOp::Zero, true)
  assert_eq(destination.stencil_z_pass.to_int(), 0)
  destination.stencil_z_pass = @constants.StencilOp::Replace
  assert_eq(source.stencil_z_pass.to_int(), 0)
  assert_eq(destination.stencil_z_pass.to_int(), 7681)
}

///|
test "SpriteMaterial stores and copies stencilWrite" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.stencil_write, false)
  let source = @materials.SpriteMaterial::new()
  source.stencil_write = true
  assert_eq(defaults.stencil_write, false)
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  assert_eq(destination.stencil_write, true)
  destination.stencil_write = false
  assert_eq(source.stencil_write, true)
  assert_eq(destination.stencil_write, false)
}

///|
test "SpriteMaterial stores and copies clippingPlanes" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.clipping_planes is None, true)
  let source = @materials.SpriteMaterial::new()
  source.clipping_planes = Some([@math.Plane::new(constant=1.0)])
  assert_eq(defaults.clipping_planes is None, true)
  let destination = @materials.SpriteMaterial::new()
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
}

///|
test "SpriteMaterial stores and copies precision" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.precision is None, true)
  let source = @materials.SpriteMaterial::new()
  source.precision = Some(@constants.Precision::Highp)
  assert_eq(defaults.precision is None, true)
  let destination = @materials.SpriteMaterial::new()
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
}

///|
test "SpriteMaterial stores and copies userData" {
  let defaults = @materials.SpriteMaterial::new()
  match defaults.user_data.get("label") {
    None => ()
    Some(_) => abort("default user data")
  }
  let source = @materials.SpriteMaterial::new()
  source.user_data.set("label", "sprite")
  match defaults.user_data.get("label") {
    None => ()
    Some(_) => abort("other user data")
  }
  let destination = @materials.SpriteMaterial::new()
  ignore(destination.copy(source))
  match destination.user_data.get("label") {
    None => abort("copied user data")
    Some(label) => assert_eq(label, "sprite")
  }
  destination.user_data.set("label", "copy")
  match source.user_data.get("label") {
    None => abort("source user data")
    Some(label) => assert_eq(label, "sprite")
  }
  match destination.user_data.get("label") {
    None => abort("destination user data")
    Some(label) => assert_eq(label, "copy")
  }
}

///|
test "SpriteMaterial stores version" {
  let defaults = @materials.SpriteMaterial::new()
  assert_eq(defaults.version, 0)
  let source = @materials.SpriteMaterial::new()
  source.version = 1
  assert_eq(defaults.version, 0)
  let destination = @materials.SpriteMaterial::new()
  destination.version = 3
  ignore(destination.copy(source))
  assert_eq(destination.version, 3)
  assert_eq(source.version, 1)
  destination.version = 2
  assert_eq(source.version, 1)
  assert_eq(destination.version, 2)
}

///|
test "SpriteMaterial needsUpdate increments version" {
  let source = @materials.SpriteMaterial::new()
  source.set_needs_update(false)
  assert_eq(source.version, 0)
  source.set_needs_update(true)
  assert_eq(source.version, 1)
  source.set_needs_update(true)
  assert_eq(source.version, 2)
  let other = @materials.SpriteMaterial::new()
  assert_eq(other.version, 0)
  let destination = @materials.SpriteMaterial::new()
  destination.version = 3
  ignore(destination.copy(source))
  assert_eq(destination.version, 3)
  assert_eq(source.version, 2)
}

///|
test "SpriteMaterial set_alpha_test bumps version across zero" {
  let source = @materials.SpriteMaterial::new()
  source.set_alpha_test(0.0)
  assert_eq(source.alpha_test, 0.0)
  assert_eq(source.version, 0)
  source.set_alpha_test(0.2)
  assert_eq(source.alpha_test, 0.2)
  assert_eq(source.version, 1)
  source.set_alpha_test(0.4)
  assert_eq(source.alpha_test, 0.4)
  assert_eq(source.version, 1)
  source.set_alpha_test(0.0)
  assert_eq(source.version, 2)
  source.set_alpha_test(-1.0)
  assert_eq(source.alpha_test, -1.0)
  assert_eq(source.version, 2)
  let other = @materials.SpriteMaterial::new()
  assert_eq(other.version, 0)
  let destination = @materials.SpriteMaterial::new()
  destination.version = 3
  ignore(destination.copy(source))
  assert_eq(destination.alpha_test, -1.0)
  assert_eq(destination.version, 3)
  assert_eq(source.version, 2)
  source.set_alpha_test(0.2)
  assert_eq(source.version, 3)
  ignore(destination.copy(source))
  assert_eq(destination.alpha_test, 0.2)
  assert_eq(destination.version, 4)
  assert_eq(source.version, 3)
}

///|
test "SpriteMaterial id increments" {
  let before = @materials.Material::basic()
  let source = @materials.SpriteMaterial::new()
  assert_eq(source.id, before.id + 1)
  let destination = @materials.SpriteMaterial::new()
  assert_eq(destination.id, source.id + 1)
  ignore(destination.copy(source))
  assert_eq(destination.id, source.id + 1)
  assert_eq(source.id, before.id + 1)
  let after = @materials.PointsMaterial::new()
  assert_eq(after.id, destination.id + 1)
}
