///|
test "Material vertex colors default off" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.vertex_colors, false)
  basic.material.vertex_colors = true
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.vertex_colors, false)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.vertex_colors, false)
  standard.material.vertex_colors = true
  let other = @materials.Material::basic()
  assert_eq(other.vertex_colors, false)
  assert_eq(basic.material.vertex_colors, true)
  assert_eq(standard.material.vertex_colors, true)
}

///|
test "Material toneMapped defaults on" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.tone_mapped, true)
  basic.material.tone_mapped = false
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.tone_mapped, true)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.tone_mapped, true)
  standard.material.tone_mapped = false
  let other = @materials.Material::basic()
  assert_eq(other.tone_mapped, true)
  assert_eq(basic.material.tone_mapped, false)
  assert_eq(standard.material.tone_mapped, false)
}

///|
test "Material alphaHash defaults off" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.alpha_hash, false)
  basic.material.alpha_hash = true
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.alpha_hash, false)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.alpha_hash, false)
  standard.material.alpha_hash = true
  let other = @materials.Material::basic()
  assert_eq(other.alpha_hash, false)
  assert_eq(basic.material.alpha_hash, true)
  assert_eq(standard.material.alpha_hash, true)
}

///|
test "Material alphaToCoverage defaults off" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.alpha_to_coverage, false)
  basic.material.alpha_to_coverage = true
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.alpha_to_coverage, false)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.alpha_to_coverage, false)
  standard.material.alpha_to_coverage = true
  let other = @materials.Material::basic()
  assert_eq(other.alpha_to_coverage, false)
  assert_eq(basic.material.alpha_to_coverage, true)
  assert_eq(standard.material.alpha_to_coverage, true)
}

///|
test "Material dithering defaults off" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.dithering, false)
  basic.material.dithering = true
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.dithering, false)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.dithering, false)
  standard.material.dithering = true
  let other = @materials.Material::basic()
  assert_eq(other.dithering, false)
  assert_eq(basic.material.dithering, true)
  assert_eq(standard.material.dithering, true)
}

///|
test "Material polygonOffset defaults off" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.polygon_offset, false)
  assert_eq(basic.material.polygon_offset_factor, 0.0)
  assert_eq(basic.material.polygon_offset_units, 0.0)
  basic.material.polygon_offset = true
  basic.material.polygon_offset_factor = 1.0
  basic.material.polygon_offset_units = -2.0
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.polygon_offset, false)
  assert_eq(lambert.material.polygon_offset_factor, 0.0)
  assert_eq(lambert.material.polygon_offset_units, 0.0)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.polygon_offset, false)
  standard.material.polygon_offset = true
  standard.material.polygon_offset_factor = 2.0
  standard.material.polygon_offset_units = 4.0
  let other = @materials.Material::basic()
  assert_eq(other.polygon_offset, false)
  assert_eq(other.polygon_offset_factor, 0.0)
  assert_eq(other.polygon_offset_units, 0.0)
  assert_eq(basic.material.polygon_offset, true)
  assert_eq(basic.material.polygon_offset_factor, 1.0)
  assert_eq(basic.material.polygon_offset_units, -2.0)
  assert_eq(standard.material.polygon_offset, true)
  assert_eq(standard.material.polygon_offset_factor, 2.0)
  assert_eq(standard.material.polygon_offset_units, 4.0)
  assert_eq(lambert.material.polygon_offset, false)
}

///|
test "Material clipShadows defaults off" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.clip_shadows, false)
  basic.material.clip_shadows = true
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.clip_shadows, false)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.clip_shadows, false)
  standard.material.clip_shadows = true
  let other = @materials.Material::basic()
  assert_eq(other.clip_shadows, false)
  assert_eq(basic.material.clip_shadows, true)
  assert_eq(standard.material.clip_shadows, true)
}

///|
test "Material clipIntersection defaults off" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.clip_intersection, false)
  basic.material.clip_intersection = true
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.clip_intersection, false)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.clip_intersection, false)
  standard.material.clip_intersection = true
  let other = @materials.Material::basic()
  assert_eq(other.clip_intersection, false)
  assert_eq(basic.material.clip_intersection, true)
  assert_eq(standard.material.clip_intersection, true)
}

///|
test "Material allowOverride defaults on" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.allow_override, true)
  basic.material.allow_override = false
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.allow_override, true)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.allow_override, true)
  standard.material.allow_override = false
  let other = @materials.Material::basic()
  assert_eq(other.allow_override, true)
  assert_eq(basic.material.allow_override, false)
  assert_eq(standard.material.allow_override, false)
}

///|
test "Material blendAlpha defaults to zero" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.blend_alpha, 0.0)
  basic.material.blend_alpha = 0.25
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.blend_alpha, 0.0)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.blend_alpha, 0.0)
  standard.material.blend_alpha = 0.5
  let other = @materials.Material::basic()
  assert_eq(other.blend_alpha, 0.0)
  assert_eq(basic.material.blend_alpha, 0.25)
  assert_eq(standard.material.blend_alpha, 0.5)
}

///|
test "Material blendColor defaults to black" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.blend_color.r, 0.0)
  assert_eq(basic.material.blend_color.g, 0.0)
  assert_eq(basic.material.blend_color.b, 0.0)
  basic.material.blend_color.r = 1.0
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.blend_color.r, 0.0)
  assert_eq(lambert.material.blend_color.g, 0.0)
  assert_eq(lambert.material.blend_color.b, 0.0)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.blend_color.g, 0.0)
  standard.material.blend_color.g = 0.5
  let other = @materials.Material::basic()
  assert_eq(other.blend_color.r, 0.0)
  assert_eq(other.blend_color.g, 0.0)
  assert_eq(other.blend_color.b, 0.0)
  assert_eq(basic.material.blend_color.r, 1.0)
  assert_eq(standard.material.blend_color.g, 0.5)
  assert_eq(lambert.material.blend_color.r, 0.0)
}

///|
test "Material blending defaults to normal" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.blending is @constants.Blending::Normal, true)
  assert_eq(basic.material.blending.to_int(), 1)
  basic.material.blending = @constants.Blending::Additive
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.blending is @constants.Blending::Normal, true)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.blending is @constants.Blending::Normal, true)
  standard.material.blending = @constants.Blending::Multiply
  let other = @materials.Material::basic()
  assert_eq(other.blending is @constants.Blending::Normal, true)
  assert_eq(basic.material.blending is @constants.Blending::Additive, true)
  assert_eq(basic.material.blending.to_int(), 2)
  assert_eq(standard.material.blending is @constants.Blending::Multiply, true)
  assert_eq(standard.material.blending.to_int(), 4)
  assert_eq(lambert.material.blending is @constants.Blending::Normal, true)
  assert_eq(@constants.Blending::No.to_int(), 0)
  assert_eq(@constants.Blending::Subtractive.to_int(), 3)
  assert_eq(@constants.Blending::Custom.to_int(), 5)
}

///|
test "Material blendSrc defaults to source alpha" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.blend_src is @constants.BlendFactor::SrcAlpha, true)
  assert_eq(basic.material.blend_src.to_int(), 204)
  basic.material.blend_src = @constants.BlendFactor::One
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.blend_src is @constants.BlendFactor::SrcAlpha, true)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.blend_src is @constants.BlendFactor::SrcAlpha, true)
  standard.material.blend_src = @constants.BlendFactor::Zero
  let other = @materials.Material::basic()
  assert_eq(other.blend_src is @constants.BlendFactor::SrcAlpha, true)
  assert_eq(basic.material.blend_src is @constants.BlendFactor::One, true)
  assert_eq(basic.material.blend_src.to_int(), 201)
  assert_eq(standard.material.blend_src is @constants.BlendFactor::Zero, true)
  assert_eq(standard.material.blend_src.to_int(), 200)
  assert_eq(lambert.material.blend_src is @constants.BlendFactor::SrcAlpha, true)
  assert_eq(@constants.BlendFactor::SrcColor.to_int(), 202)
  assert_eq(@constants.BlendFactor::OneMinusSrcColor.to_int(), 203)
  assert_eq(@constants.BlendFactor::OneMinusSrcAlpha.to_int(), 205)
  assert_eq(@constants.BlendFactor::DstAlpha.to_int(), 206)
  assert_eq(@constants.BlendFactor::OneMinusDstAlpha.to_int(), 207)
  assert_eq(@constants.BlendFactor::DstColor.to_int(), 208)
  assert_eq(@constants.BlendFactor::OneMinusDstColor.to_int(), 209)
  assert_eq(@constants.BlendFactor::SrcAlphaSaturate.to_int(), 210)
  assert_eq(@constants.BlendFactor::ConstantColor.to_int(), 211)
  assert_eq(@constants.BlendFactor::OneMinusConstantColor.to_int(), 212)
  assert_eq(@constants.BlendFactor::ConstantAlpha.to_int(), 213)
  assert_eq(@constants.BlendFactor::OneMinusConstantAlpha.to_int(), 214)
}

///|
test "Material blendDst defaults to one minus source alpha" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(
    basic.material.blend_dst is @constants.BlendFactor::OneMinusSrcAlpha,
    true,
  )
  assert_eq(basic.material.blend_dst.to_int(), 205)
  basic.material.blend_dst = @constants.BlendFactor::Zero
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(
    lambert.material.blend_dst is @constants.BlendFactor::OneMinusSrcAlpha,
    true,
  )
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(
    standard.material.blend_dst is @constants.BlendFactor::OneMinusSrcAlpha,
    true,
  )
  standard.material.blend_dst = @constants.BlendFactor::One
  let other = @materials.Material::basic()
  assert_eq(other.blend_dst is @constants.BlendFactor::OneMinusSrcAlpha, true)
  assert_eq(basic.material.blend_dst is @constants.BlendFactor::Zero, true)
  assert_eq(basic.material.blend_dst.to_int(), 200)
  assert_eq(standard.material.blend_dst is @constants.BlendFactor::One, true)
  assert_eq(standard.material.blend_dst.to_int(), 201)
  assert_eq(
    lambert.material.blend_dst is @constants.BlendFactor::OneMinusSrcAlpha,
    true,
  )
}

///|
test "Material blendEquation defaults to add" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.blend_equation is @constants.BlendEquation::Add, true)
  assert_eq(basic.material.blend_equation.to_int(), 100)
  basic.material.blend_equation = @constants.BlendEquation::Subtract
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.blend_equation is @constants.BlendEquation::Add, true)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.blend_equation is @constants.BlendEquation::Add, true)
  standard.material.blend_equation = @constants.BlendEquation::Max
  let other = @materials.Material::basic()
  assert_eq(other.blend_equation is @constants.BlendEquation::Add, true)
  assert_eq(basic.material.blend_equation is @constants.BlendEquation::Subtract, true)
  assert_eq(basic.material.blend_equation.to_int(), 101)
  assert_eq(standard.material.blend_equation is @constants.BlendEquation::Max, true)
  assert_eq(standard.material.blend_equation.to_int(), 104)
  assert_eq(lambert.material.blend_equation is @constants.BlendEquation::Add, true)
  assert_eq(@constants.BlendEquation::ReverseSubtract.to_int(), 102)
  assert_eq(@constants.BlendEquation::Min.to_int(), 103)
}

///|
test "Material blendSrcAlpha defaults to empty" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.blend_src_alpha is None, true)
  basic.material.blend_src_alpha = Some(@constants.BlendFactor::One)
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.blend_src_alpha is None, true)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.blend_src_alpha is None, true)
  standard.material.blend_src_alpha = Some(@constants.BlendFactor::Zero)
  let other = @materials.Material::basic()
  assert_eq(other.blend_src_alpha is None, true)
  match basic.material.blend_src_alpha {
    Some(factor) => {
      assert_eq(factor is @constants.BlendFactor::One, true)
      assert_eq(factor.to_int(), 201)
    }
    None => abort("basic blendSrcAlpha is empty")
  }
  match standard.material.blend_src_alpha {
    Some(factor) => {
      assert_eq(factor is @constants.BlendFactor::Zero, true)
      assert_eq(factor.to_int(), 200)
    }
    None => abort("standard blendSrcAlpha is empty")
  }
  assert_eq(lambert.material.blend_src_alpha is None, true)
}

///|
test "Material blendDstAlpha defaults to empty" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.blend_dst_alpha is None, true)
  basic.material.blend_dst_alpha = Some(@constants.BlendFactor::One)
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.blend_dst_alpha is None, true)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.blend_dst_alpha is None, true)
  standard.material.blend_dst_alpha = Some(@constants.BlendFactor::Zero)
  let other = @materials.Material::basic()
  assert_eq(other.blend_dst_alpha is None, true)
  match basic.material.blend_dst_alpha {
    Some(factor) => {
      assert_eq(factor is @constants.BlendFactor::One, true)
      assert_eq(factor.to_int(), 201)
    }
    None => abort("basic blendDstAlpha is empty")
  }
  match standard.material.blend_dst_alpha {
    Some(factor) => {
      assert_eq(factor is @constants.BlendFactor::Zero, true)
      assert_eq(factor.to_int(), 200)
    }
    None => abort("standard blendDstAlpha is empty")
  }
  assert_eq(lambert.material.blend_dst_alpha is None, true)
}

///|
test "Material blendEquationAlpha defaults to empty" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.blend_equation_alpha is None, true)
  basic.material.blend_equation_alpha = Some(@constants.BlendEquation::Subtract)
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.blend_equation_alpha is None, true)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.blend_equation_alpha is None, true)
  standard.material.blend_equation_alpha = Some(@constants.BlendEquation::Max)
  let other = @materials.Material::basic()
  assert_eq(other.blend_equation_alpha is None, true)
  match basic.material.blend_equation_alpha {
    Some(equation) => {
      assert_eq(equation is @constants.BlendEquation::Subtract, true)
      assert_eq(equation.to_int(), 101)
    }
    None => abort("basic blendEquationAlpha is empty")
  }
  match standard.material.blend_equation_alpha {
    Some(equation) => {
      assert_eq(equation is @constants.BlendEquation::Max, true)
      assert_eq(equation.to_int(), 104)
    }
    None => abort("standard blendEquationAlpha is empty")
  }
  assert_eq(lambert.material.blend_equation_alpha is None, true)
}

///|
test "Material stencilWriteMask defaults to 255" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.stencil_write_mask, 255)
  basic.material.stencil_write_mask = 0
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.stencil_write_mask, 255)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.stencil_write_mask, 255)
  standard.material.stencil_write_mask = 1
  let other = @materials.Material::basic()
  assert_eq(other.stencil_write_mask, 255)
  assert_eq(basic.material.stencil_write_mask, 0)
  assert_eq(standard.material.stencil_write_mask, 1)
  assert_eq(lambert.material.stencil_write_mask, 255)
}

///|
test "Material stencilFunc defaults to Always" {
  assert_eq(@constants.StencilFunc::Never.to_int(), 512)
  assert_eq(@constants.StencilFunc::Less.to_int(), 513)
  assert_eq(@constants.StencilFunc::Equal.to_int(), 514)
  assert_eq(@constants.StencilFunc::LessEqual.to_int(), 515)
  assert_eq(@constants.StencilFunc::Greater.to_int(), 516)
  assert_eq(@constants.StencilFunc::NotEqual.to_int(), 517)
  assert_eq(@constants.StencilFunc::GreaterEqual.to_int(), 518)
  assert_eq(@constants.StencilFunc::Always.to_int(), 519)
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.stencil_func is @constants.StencilFunc::Always, true)
  assert_eq(basic.material.stencil_func.to_int(), 519)
  basic.material.stencil_func = @constants.StencilFunc::Never
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.stencil_func is @constants.StencilFunc::Always, true)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.stencil_func is @constants.StencilFunc::Always, true)
  standard.material.stencil_func = @constants.StencilFunc::Equal
  let other = @materials.Material::basic()
  assert_eq(other.stencil_func is @constants.StencilFunc::Always, true)
  assert_eq(basic.material.stencil_func.to_int(), 512)
  assert_eq(standard.material.stencil_func.to_int(), 514)
  assert_eq(lambert.material.stencil_func.to_int(), 519)
}
