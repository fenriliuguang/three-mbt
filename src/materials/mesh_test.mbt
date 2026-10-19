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

///|
test "Material stencilRef defaults to 0" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.stencil_ref, 0)
  basic.material.stencil_ref = 1
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.stencil_ref, 0)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.stencil_ref, 0)
  standard.material.stencil_ref = 7
  let other = @materials.Material::basic()
  assert_eq(other.stencil_ref, 0)
  assert_eq(basic.material.stencil_ref, 1)
  assert_eq(standard.material.stencil_ref, 7)
  assert_eq(lambert.material.stencil_ref, 0)
}

///|
test "Material stencilFuncMask defaults to 255" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.stencil_func_mask, 255)
  basic.material.stencil_func_mask = 0
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.stencil_func_mask, 255)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.stencil_func_mask, 255)
  standard.material.stencil_func_mask = 1
  let other = @materials.Material::basic()
  assert_eq(other.stencil_func_mask, 255)
  assert_eq(basic.material.stencil_func_mask, 0)
  assert_eq(standard.material.stencil_func_mask, 1)
  assert_eq(lambert.material.stencil_func_mask, 255)
}

///|
test "Material stencilFail defaults to Keep" {
  assert_eq(@constants.StencilOp::Zero.to_int(), 0)
  assert_eq(@constants.StencilOp::Keep.to_int(), 7680)
  assert_eq(@constants.StencilOp::Replace.to_int(), 7681)
  assert_eq(@constants.StencilOp::Increment.to_int(), 7682)
  assert_eq(@constants.StencilOp::Decrement.to_int(), 7683)
  assert_eq(@constants.StencilOp::IncrementWrap.to_int(), 34055)
  assert_eq(@constants.StencilOp::DecrementWrap.to_int(), 34056)
  assert_eq(@constants.StencilOp::Invert.to_int(), 5386)
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.stencil_fail is @constants.StencilOp::Keep, true)
  assert_eq(basic.material.stencil_fail.to_int(), 7680)
  basic.material.stencil_fail = @constants.StencilOp::Zero
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.stencil_fail is @constants.StencilOp::Keep, true)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.stencil_fail is @constants.StencilOp::Keep, true)
  standard.material.stencil_fail = @constants.StencilOp::Replace
  let other = @materials.Material::basic()
  assert_eq(other.stencil_fail is @constants.StencilOp::Keep, true)
  assert_eq(basic.material.stencil_fail.to_int(), 0)
  assert_eq(standard.material.stencil_fail.to_int(), 7681)
  assert_eq(lambert.material.stencil_fail.to_int(), 7680)
}

///|
test "Material stencilZFail defaults to Keep" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.stencil_z_fail is @constants.StencilOp::Keep, true)
  assert_eq(basic.material.stencil_z_fail.to_int(), 7680)
  basic.material.stencil_z_fail = @constants.StencilOp::Zero
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.stencil_z_fail is @constants.StencilOp::Keep, true)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.stencil_z_fail is @constants.StencilOp::Keep, true)
  standard.material.stencil_z_fail = @constants.StencilOp::Replace
  let other = @materials.Material::basic()
  assert_eq(other.stencil_z_fail is @constants.StencilOp::Keep, true)
  assert_eq(basic.material.stencil_z_fail.to_int(), 0)
  assert_eq(standard.material.stencil_z_fail.to_int(), 7681)
  assert_eq(lambert.material.stencil_z_fail.to_int(), 7680)
}

///|
test "Material stencilZPass defaults to Keep" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.stencil_z_pass is @constants.StencilOp::Keep, true)
  assert_eq(basic.material.stencil_z_pass.to_int(), 7680)
  basic.material.stencil_z_pass = @constants.StencilOp::Zero
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.stencil_z_pass is @constants.StencilOp::Keep, true)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.stencil_z_pass is @constants.StencilOp::Keep, true)
  standard.material.stencil_z_pass = @constants.StencilOp::Replace
  let other = @materials.Material::basic()
  assert_eq(other.stencil_z_pass is @constants.StencilOp::Keep, true)
  assert_eq(basic.material.stencil_z_pass.to_int(), 0)
  assert_eq(standard.material.stencil_z_pass.to_int(), 7681)
  assert_eq(lambert.material.stencil_z_pass.to_int(), 7680)
}

///|
test "Material stencilWrite defaults to false" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.stencil_write, false)
  basic.material.stencil_write = true
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.stencil_write, false)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.stencil_write, false)
  standard.material.stencil_write = true
  let other = @materials.Material::basic()
  assert_eq(other.stencil_write, false)
  assert_eq(basic.material.stencil_write, true)
  assert_eq(standard.material.stencil_write, true)
  assert_eq(lambert.material.stencil_write, false)
}

///|
test "Material clippingPlanes defaults to empty" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.clipping_planes is None, true)
  basic.material.clipping_planes = Some([@math.Plane::new(constant=1.0)])
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.clipping_planes is None, true)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.clipping_planes is None, true)
  standard.material.clipping_planes = Some([@math.Plane::new(constant=2.0)])
  let other = @materials.Material::basic()
  assert_eq(other.clipping_planes is None, true)
  match basic.material.clipping_planes {
    None => abort("basic clipping planes")
    Some(planes) => {
      assert_eq(planes.length(), 1)
      assert_eq(planes[0].constant, 1.0)
    }
  }
  match standard.material.clipping_planes {
    None => abort("standard clipping planes")
    Some(planes) => {
      assert_eq(planes.length(), 1)
      assert_eq(planes[0].constant, 2.0)
    }
  }
  assert_eq(lambert.material.clipping_planes is None, true)
}

///|
test "Material precision defaults to empty" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.precision is None, true)
  basic.material.precision = Some(@constants.Precision::Highp)
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.precision is None, true)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.precision is None, true)
  standard.material.precision = Some(@constants.Precision::Mediump)
  let other = @materials.Material::basic()
  assert_eq(other.precision is None, true)
  match basic.material.precision {
    None => abort("basic precision")
    Some(precision) => assert_eq(precision is @constants.Precision::Highp, true)
  }
  match standard.material.precision {
    None => abort("standard precision")
    Some(precision) => assert_eq(precision is @constants.Precision::Mediump, true)
  }
  assert_eq(lambert.material.precision is None, true)
}

///|
test "Material userData starts empty" {
  let basic = @materials.MeshBasicMaterial::new()
  match basic.material.user_data.get("label") {
    None => ()
    Some(_) => abort("basic user data")
  }
  basic.material.user_data.set("label", "mesh")
  let lambert = @materials.MeshLambertMaterial::new()
  match lambert.material.user_data.get("label") {
    None => ()
    Some(_) => abort("lambert user data")
  }
  let standard = @materials.MeshStandardMaterial::new()
  match standard.material.user_data.get("label") {
    None => ()
    Some(_) => abort("standard user data")
  }
  standard.material.user_data.set("label", "lit")
  let other = @materials.Material::basic()
  match other.user_data.get("label") {
    None => ()
    Some(_) => abort("other user data")
  }
  match basic.material.user_data.get("label") {
    None => abort("basic label")
    Some(label) => assert_eq(label, "mesh")
  }
  match standard.material.user_data.get("label") {
    None => abort("standard label")
    Some(label) => assert_eq(label, "lit")
  }
}

///|
test "Material version starts at zero" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.version, 0)
  basic.material.version = 1
  let other = @materials.Material::basic()
  assert_eq(other.version, 0)
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.version, 0)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.version, 0)
  standard.material.version = 2
  assert_eq(lambert.material.version, 0)
  assert_eq(basic.material.version, 1)
  assert_eq(standard.material.version, 2)
}

///|
test "Material needsUpdate increments version" {
  let basic = @materials.MeshBasicMaterial::new()
  basic.material.set_needs_update(false)
  assert_eq(basic.material.version, 0)
  basic.material.set_needs_update(true)
  assert_eq(basic.material.version, 1)
  basic.material.set_needs_update(true)
  assert_eq(basic.material.version, 2)
  let other = @materials.Material::basic()
  assert_eq(other.version, 0)
  let lambert = @materials.MeshLambertMaterial::new()
  let standard = @materials.MeshStandardMaterial::new()
  standard.material.set_needs_update(true)
  assert_eq(standard.material.version, 1)
  assert_eq(lambert.material.version, 0)
  lambert.material.set_needs_update(false)
  assert_eq(lambert.material.version, 0)
}

///|
test "Material set_alpha_test bumps version across zero" {
  let basic = @materials.MeshBasicMaterial::new()
  basic.material.set_alpha_test(0.0)
  assert_eq(basic.material.alpha_test, 0.0)
  assert_eq(basic.material.version, 0)
  basic.material.set_alpha_test(0.2)
  assert_eq(basic.material.alpha_test, 0.2)
  assert_eq(basic.material.version, 1)
  basic.material.set_alpha_test(0.4)
  assert_eq(basic.material.alpha_test, 0.4)
  assert_eq(basic.material.version, 1)
  basic.material.set_alpha_test(0.0)
  assert_eq(basic.material.alpha_test, 0.0)
  assert_eq(basic.material.version, 2)
  basic.material.set_alpha_test(-1.0)
  assert_eq(basic.material.alpha_test, -1.0)
  assert_eq(basic.material.version, 2)
  let other = @materials.Material::basic()
  assert_eq(other.version, 0)
  assert_eq(other.alpha_test, 0.0)
  let lambert = @materials.MeshLambertMaterial::new()
  let standard = @materials.MeshStandardMaterial::new()
  standard.material.set_alpha_test(0.5)
  assert_eq(standard.material.alpha_test, 0.5)
  assert_eq(standard.material.version, 1)
  assert_eq(lambert.material.version, 0)
  assert_eq(lambert.material.alpha_test, 0.0)
}

///|
test "Material id increments" {
  let basic = @materials.MeshBasicMaterial::new()
  let other = @materials.Material::basic()
  assert_eq(other.id, basic.material.id + 1)
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.id, other.id + 1)
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.id, lambert.material.id + 1)
  assert_eq(basic.material.id + 3, standard.material.id)
}

///|
test "Material uuid is a version-4 id" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.uuid.length(), 36)
  assert_eq(basic.material.uuid[14:15].to_owned(), "4")
  let other = @materials.Material::basic()
  assert_eq(other.uuid.length(), 36)
  assert_eq(other.uuid[14:15].to_owned(), "4")
  basic.material.uuid = "mesh"
  assert_eq(other.uuid.length(), 36)
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.uuid.length(), 36)
  assert_eq(lambert.material.uuid[14:15].to_owned(), "4")
  lambert.material.uuid = "lambert"
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.uuid.length(), 36)
  assert_eq(standard.material.uuid[14:15].to_owned(), "4")
  standard.material.uuid = "lit"
  assert_eq(basic.material.uuid, "mesh")
  assert_eq(lambert.material.uuid, "lambert")
  assert_eq(standard.material.uuid, "lit")
}

///|
test "Material name starts empty" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.name, "")
  basic.material.name = "mesh"
  let other = @materials.Material::basic()
  assert_eq(other.name, "")
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.name, "")
  let standard = @materials.MeshStandardMaterial::new()
  standard.material.name = "lit"
  assert_eq(basic.material.name, "mesh")
  assert_eq(lambert.material.name, "")
  assert_eq(standard.material.name, "lit")
}

///|
test "Material type_name matches the mesh class" {
  let basic = @materials.MeshBasicMaterial::new()
  assert_eq(basic.material.type_name, "MeshBasicMaterial")
  let other = @materials.Material::basic()
  assert_eq(other.type_name, "MeshBasicMaterial")
  let lambert = @materials.MeshLambertMaterial::new()
  assert_eq(lambert.material.type_name, "MeshLambertMaterial")
  let standard = @materials.MeshStandardMaterial::new()
  assert_eq(standard.material.type_name, "MeshStandardMaterial")
}

///|
test "Material copy writes shared fields and keeps identity" {
  let source = @materials.Material::lambert()
  source.name = "lit"
  ignore(source.color.set_rgb(1.0, 0.0, 0.0))
  ignore(source.emissive.set_rgb(0.25, 0.5, 0.75))
  source.emissive_intensity = 2.0
  source.opacity = 0.25
  source.transparent = true
  source.fog = false
  source.wireframe = true
  source.roughness = 0.4
  source.metalness = 0.6
  source.flat_shading = true
  source.side = @constants.Back
  source.shadow_side = Some(@constants.Back)
  source.set_alpha_test(0.2)
  source.user_data.set("label", "mesh")
  source.clipping_planes = Some([@math.Plane::new(constant=1.0)])
  assert_eq(source.version, 1)
  let destination = @materials.Material::basic()
  destination.version = 3
  let kept_id = destination.id
  let kept_uuid = destination.uuid
  ignore(destination.copy(source))
  assert_eq(destination.name, "lit")
  assert_eq(destination.color.r, 1.0)
  assert_eq(destination.color.g, 0.0)
  assert_eq(destination.emissive.r, 0.25)
  assert_eq(destination.emissive.g, 0.5)
  assert_eq(destination.emissive.b, 0.75)
  assert_eq(destination.emissive_intensity, 2.0)
  assert_eq(destination.opacity, 0.25)
  assert_eq(destination.transparent, true)
  assert_eq(destination.fog, false)
  assert_eq(destination.wireframe, true)
  assert_eq(destination.roughness, 0.4)
  assert_eq(destination.metalness, 0.6)
  assert_eq(destination.flat_shading, true)
  assert_eq(destination.side is @constants.Back, true)
  match destination.shadow_side {
    None => abort("shadow side")
    Some(side) => assert_eq(side is @constants.Back, true)
  }
  assert_eq(destination.alpha_test, 0.2)
  assert_eq(destination.version, 4)
  assert_eq(destination.id, kept_id)
  assert_eq(destination.uuid, kept_uuid)
  assert_eq(destination.type_name, "MeshBasicMaterial")
  assert_eq(destination.kind is @materials.MaterialKind::Basic, true)
  assert_eq(source.type_name, "MeshLambertMaterial")
  assert_eq(source.kind is @materials.MaterialKind::Lambert, true)
  assert_eq(source.version, 1)
  destination.color.r = 0.5
  assert_eq(source.color.r, 1.0)
  destination.emissive.g = 0.0
  assert_eq(source.emissive.g, 0.5)
  destination.name = "copy"
  assert_eq(source.name, "lit")
  match destination.user_data.get("label") {
    None => abort("copied user data")
    Some(label) => assert_eq(label, "mesh")
  }
  destination.user_data.set("label", "copy")
  match source.user_data.get("label") {
    None => abort("source user data")
    Some(label) => assert_eq(label, "mesh")
  }
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
  let standard = @materials.Material::standard()
  assert_eq(standard.name, "")
  assert_eq(standard.opacity, 1.0)
  assert_eq(standard.roughness, 1.0)
  assert_eq(standard.type_name, "MeshStandardMaterial")
}

///|
test "Material clone keeps kind and takes a new id" {
  let basic = @materials.Material::basic()
  basic.name = "plain"
  let basic_clone = basic.clone()
  assert_eq(basic_clone.name, "plain")
  assert_eq(basic_clone.type_name, "MeshBasicMaterial")
  assert_eq(basic_clone.kind is @materials.MaterialKind::Basic, true)
  assert_eq(basic_clone.version, 0)
  assert_eq(basic_clone.id == basic.id, false)
  basic_clone.name = "copy"
  assert_eq(basic.name, "plain")
  let source = @materials.Material::lambert()
  source.name = "lit"
  ignore(source.color.set_rgb(1.0, 0.0, 0.0))
  source.set_alpha_test(0.2)
  source.version = 5
  source.uuid = "mesh"
  source.user_data.set("label", "mesh")
  let cloned = source.clone()
  assert_eq(cloned.name, "lit")
  assert_eq(cloned.color.r, 1.0)
  assert_eq(cloned.alpha_test, 0.2)
  assert_eq(cloned.version, 1)
  assert_eq(cloned.type_name, "MeshLambertMaterial")
  assert_eq(cloned.kind is @materials.MaterialKind::Lambert, true)
  assert_eq(cloned.id == source.id, false)
  assert_eq(cloned.uuid.length(), 36)
  assert_eq(cloned.uuid[14:15].to_owned(), "4")
  assert_eq(source.uuid, "mesh")
  assert_eq(source.version, 5)
  cloned.color.r = 0.5
  assert_eq(source.color.r, 1.0)
  cloned.user_data.set("label", "copy")
  match source.user_data.get("label") {
    None => abort("source user data")
    Some(label) => assert_eq(label, "mesh")
  }
  let standard = @materials.Material::standard(roughness=0.2, metalness=0.8)
  let standard_clone = standard.clone()
  assert_eq(standard_clone.roughness, 0.2)
  assert_eq(standard_clone.metalness, 0.8)
  assert_eq(standard_clone.type_name, "MeshStandardMaterial")
  assert_eq(standard_clone.kind is @materials.MaterialKind::Standard, true)
  assert_eq(standard.roughness, 0.2)
}

///|
test "Material addEventListener keeps one copy of a listener" {
  let material = @materials.Material::basic()
  let listener = fn() {}
  material.add_event_listener("dispose", listener)
  material.add_event_listener("dispose", listener)
  match material.listeners.get("dispose") {
    None => abort("dispose listeners")
    Some(listeners) => assert_eq(listeners.length(), 1)
  }
  let source = @materials.Material::lambert()
  source.add_event_listener("dispose", listener)
  let destination = @materials.Material::basic()
  ignore(destination.copy(source))
  match destination.listeners.get("dispose") {
    None => ()
    Some(_) => abort("copy brought listeners")
  }
  match source.listeners.get("dispose") {
    None => abort("source listeners")
    Some(listeners) => assert_eq(listeners.length(), 1)
  }
  let standard = @materials.Material::standard()
  match standard.listeners.get("dispose") {
    None => ()
    Some(_) => abort("standard listeners")
  }
}

///|
test "Material hasEventListener reports a registered listener" {
  let material = @materials.Material::basic()
  let listener = fn() {}
  let other_listener = fn() {}
  assert_eq(material.has_event_listener("dispose", listener), false)
  material.add_event_listener("dispose", listener)
  assert_eq(material.has_event_listener("dispose", listener), true)
  assert_eq(material.has_event_listener("dispose", other_listener), false)
  assert_eq(material.has_event_listener("change", listener), false)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.has_event_listener("dispose", listener), false)
  let standard = @materials.Material::standard()
  assert_eq(standard.has_event_listener("dispose", listener), false)
}

///|
test "Material removeEventListener drops a registered listener" {
  let material = @materials.Material::basic()
  let listener = fn() {}
  let other_listener = fn() {}
  material.remove_event_listener("dispose", listener)
  assert_eq(material.has_event_listener("dispose", listener), false)
  material.add_event_listener("dispose", listener)
  material.add_event_listener("change", other_listener)
  material.remove_event_listener("dispose", listener)
  assert_eq(material.has_event_listener("dispose", listener), false)
  assert_eq(material.has_event_listener("change", other_listener), true)
  let lambert = @materials.Material::lambert()
  lambert.add_event_listener("dispose", listener)
  material.remove_event_listener("dispose", listener)
  assert_eq(lambert.has_event_listener("dispose", listener), true)
}

///|
test "Material dispatchEvent runs listeners of one kind" {
  let material = @materials.Material::basic()
  let hits = Ref::Ref(0)
  material.add_event_listener("change", fn() { hits.val = hits.val + 1 })
  material.add_event_listener("dispose", fn() { hits.val = hits.val + 10 })
  material.dispatch_event("change")
  assert_eq(hits.val, 1)
  material.dispatch_event("missing")
  assert_eq(hits.val, 1)
  let lambert = @materials.Material::lambert()
  lambert.dispatch_event("change")
  assert_eq(hits.val, 1)
  let standard = @materials.Material::standard()
  standard.dispatch_event("dispose")
  assert_eq(hits.val, 1)
}

///|
test "Material dispose runs only dispose listeners" {
  let material = @materials.Material::basic()
  let hits = Ref::Ref(0)
  material.add_event_listener("dispose", fn() { hits.val = hits.val + 1 })
  material.add_event_listener("change", fn() { hits.val = hits.val + 10 })
  material.dispose()
  assert_eq(hits.val, 1)
  let lambert = @materials.Material::lambert()
  lambert.dispose()
  assert_eq(hits.val, 1)
  let standard = @materials.Material::standard()
  standard.add_event_listener("change", fn() { hits.val = hits.val + 10 })
  standard.dispose()
  assert_eq(hits.val, 1)
}

///|
test "Material normalMap starts empty and copies by reference" {
  let basic = @materials.Material::basic()
  assert_eq(basic.normal_map is None, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.normal_map is None, true)
  let pixels = FixedArray::make(4, b'\xFF')
  pixels[1] = b'\x80'
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  lambert.normal_map = Some(map)
  let other = @materials.Material::lambert()
  assert_eq(other.normal_map is None, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  match destination.normal_map {
    None => abort("copied normal map")
    Some(copied) => assert_eq(physical_equal(copied, map), true)
  }
  destination.normal_map = None
  match lambert.normal_map {
    None => abort("source normal map")
    Some(kept) => assert_eq(physical_equal(kept, map), true)
  }
  let standard = @materials.Material::standard()
  assert_eq(standard.normal_map is None, true)
}

///|
test "Material normalMapType defaults to tangent space and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.normal_map_type.to_int(), 0)
  assert_eq(basic.normal_map_type is @constants.TangentSpace, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.normal_map_type.to_int(), @constants.TANGENT_SPACE_NORMAL_MAP)
  lambert.normal_map_type = @constants.ObjectSpace
  let other = @materials.Material::lambert()
  assert_eq(other.normal_map_type.to_int(), 0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.normal_map_type.to_int(), 1)
  assert_eq(destination.normal_map_type is @constants.ObjectSpace, true)
  destination.normal_map_type = @constants.TangentSpace
  assert_eq(lambert.normal_map_type.to_int(), @constants.OBJECT_SPACE_NORMAL_MAP)
  let standard = @materials.Material::standard()
  assert_eq(standard.normal_map_type.to_int(), 0)
}

///|
test "Material normalScale starts at one and copies into the destination" {
  let basic = @materials.Material::basic()
  assert_eq(basic.normal_scale.x, 1.0)
  assert_eq(basic.normal_scale.y, 1.0)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.normal_scale.x, 1.0)
  assert_eq(lambert.normal_scale.y, 1.0)
  lambert.normal_scale.x = 0.25
  lambert.normal_scale.y = 0.5
  let other = @materials.Material::lambert()
  assert_eq(other.normal_scale.x, 1.0)
  assert_eq(other.normal_scale.y, 1.0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.normal_scale.x, 0.25)
  assert_eq(destination.normal_scale.y, 0.5)
  destination.normal_scale.x = 0.0
  assert_eq(lambert.normal_scale.x, 0.25)
  assert_eq(lambert.normal_scale.y, 0.5)
  let standard = @materials.Material::standard()
  assert_eq(standard.normal_scale.x, 1.0)
  assert_eq(standard.normal_scale.y, 1.0)
}

///|
test "Material displacementMap starts empty and copies by reference" {
  let basic = @materials.Material::basic()
  assert_eq(basic.displacement_map is None, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.displacement_map is None, true)
  let pixels = FixedArray::make(4, b'\xFF')
  pixels[1] = b'\x80'
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  lambert.displacement_map = Some(map)
  let other = @materials.Material::lambert()
  assert_eq(other.displacement_map is None, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  match destination.displacement_map {
    None => abort("copied displacement map")
    Some(copied) => assert_eq(physical_equal(copied, map), true)
  }
  destination.displacement_map = None
  match lambert.displacement_map {
    None => abort("source displacement map")
    Some(kept) => assert_eq(physical_equal(kept, map), true)
  }
  let standard = @materials.Material::standard()
  assert_eq(standard.displacement_map is None, true)
}

///|
test "Material displacementScale defaults to one and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.displacement_scale, 1.0)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.displacement_scale, 1.0)
  lambert.displacement_scale = 0.25
  let other = @materials.Material::lambert()
  assert_eq(other.displacement_scale, 1.0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.displacement_scale, 0.25)
  destination.displacement_scale = 2.0
  assert_eq(lambert.displacement_scale, 0.25)
  let standard = @materials.Material::standard()
  assert_eq(standard.displacement_scale, 1.0)
}

///|
test "Material displacementBias defaults to zero and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.displacement_bias, 0.0)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.displacement_bias, 0.0)
  lambert.displacement_bias = 0.25
  let other = @materials.Material::lambert()
  assert_eq(other.displacement_bias, 0.0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.displacement_bias, 0.25)
  destination.displacement_bias = -1.0
  assert_eq(lambert.displacement_bias, 0.25)
  let standard = @materials.Material::standard()
  assert_eq(standard.displacement_bias, 0.0)
}

///|
test "Material specularMap starts empty and copies by reference" {
  let basic = @materials.Material::basic()
  assert_eq(basic.specular_map is None, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.specular_map is None, true)
  let pixels = FixedArray::make(4, b'\xFF')
  pixels[1] = b'\x80'
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  lambert.specular_map = Some(map)
  let other = @materials.Material::lambert()
  assert_eq(other.specular_map is None, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  match destination.specular_map {
    None => abort("copied specular map")
    Some(copied) => assert_eq(physical_equal(copied, map), true)
  }
  destination.specular_map = None
  match lambert.specular_map {
    None => abort("source specular map")
    Some(kept) => assert_eq(physical_equal(kept, map), true)
  }
  let standard = @materials.Material::standard()
  assert_eq(standard.specular_map is None, true)
}

///|
test "Material envMap starts empty and copies by reference" {
  let basic = @materials.Material::basic()
  assert_eq(basic.env_map is None, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.env_map is None, true)
  let pixels = FixedArray::make(4, b'\xFF')
  pixels[1] = b'\x80'
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  lambert.env_map = Some(map)
  let other = @materials.Material::lambert()
  assert_eq(other.env_map is None, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  match destination.env_map {
    None => abort("copied env map")
    Some(copied) => assert_eq(physical_equal(copied, map), true)
  }
  destination.env_map = None
  match lambert.env_map {
    None => abort("source env map")
    Some(kept) => assert_eq(physical_equal(kept, map), true)
  }
  let standard = @materials.Material::standard()
  assert_eq(standard.env_map is None, true)
}

///|
test "Material envMapRotation starts at zero and copies into the destination" {
  let basic = @materials.Material::basic()
  assert_eq(basic.env_map_rotation.x, 0.0)
  assert_eq(basic.env_map_rotation.y, 0.0)
  assert_eq(basic.env_map_rotation.z, 0.0)
  match basic.env_map_rotation.order {
    @math.EulerOrder::XYZ => ()
    _ => abort("basic env map rotation order")
  }
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.env_map_rotation.x, 0.0)
  ignore(lambert.env_map_rotation.set(0.25, 0.5, -0.1))
  let other = @materials.Material::lambert()
  assert_eq(other.env_map_rotation.x, 0.0)
  assert_eq(other.env_map_rotation.y, 0.0)
  assert_eq(other.env_map_rotation.z, 0.0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.env_map_rotation.x, 0.25)
  assert_eq(destination.env_map_rotation.y, 0.5)
  assert_eq(destination.env_map_rotation.z, -0.1)
  match destination.env_map_rotation.order {
    @math.EulerOrder::XYZ => ()
    _ => abort("copied env map rotation order")
  }
  ignore(destination.env_map_rotation.set_x(0.0))
  assert_eq(lambert.env_map_rotation.x, 0.25)
  assert_eq(lambert.env_map_rotation.y, 0.5)
  assert_eq(lambert.env_map_rotation.z, -0.1)
  let standard = @materials.Material::standard()
  assert_eq(standard.env_map_rotation.x, 0.0)
  assert_eq(standard.env_map_rotation.y, 0.0)
  assert_eq(standard.env_map_rotation.z, 0.0)
}

///|
test "Material combine defaults to multiply and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.combine.to_int(), 0)
  assert_eq(basic.combine is @constants.Combine::Multiply, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.combine.to_int(), @constants.MULTIPLY_OPERATION)
  lambert.combine = @constants.Combine::Mix
  let other = @materials.Material::lambert()
  assert_eq(other.combine.to_int(), 0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.combine.to_int(), 1)
  assert_eq(destination.combine is @constants.Combine::Mix, true)
  destination.combine = @constants.Combine::Add
  assert_eq(lambert.combine.to_int(), @constants.MIX_OPERATION)
  assert_eq(@constants.Combine::Add.to_int(), @constants.ADD_OPERATION)
  let standard = @materials.Material::standard()
  assert_eq(standard.combine.to_int(), 0)
}

///|
test "Material reflectivity defaults to one and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.reflectivity, 1.0)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.reflectivity, 1.0)
  lambert.reflectivity = 0.25
  let other = @materials.Material::lambert()
  assert_eq(other.reflectivity, 1.0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.reflectivity, 0.25)
  destination.reflectivity = 0.0
  assert_eq(lambert.reflectivity, 0.25)
  let standard = @materials.Material::standard()
  assert_eq(standard.reflectivity, 1.0)
}

///|
test "Material envMapIntensity defaults to one and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.env_map_intensity, 1.0)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.env_map_intensity, 1.0)
  lambert.env_map_intensity = 2.0
  let other = @materials.Material::lambert()
  assert_eq(other.env_map_intensity, 1.0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.env_map_intensity, 2.0)
  destination.env_map_intensity = 0.0
  assert_eq(lambert.env_map_intensity, 2.0)
  let standard = @materials.Material::standard()
  assert_eq(standard.env_map_intensity, 1.0)
}

///|
test "Material refractionRatio defaults to 0.98 and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.refraction_ratio, 0.98)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.refraction_ratio, 0.98)
  lambert.refraction_ratio = 0.5
  let other = @materials.Material::lambert()
  assert_eq(other.refraction_ratio, 0.98)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.refraction_ratio, 0.5)
  destination.refraction_ratio = 1.0
  assert_eq(lambert.refraction_ratio, 0.5)
  let standard = @materials.Material::standard()
  assert_eq(standard.refraction_ratio, 0.98)
}

///|
test "Material lightMap starts empty and copies by reference" {
  let basic = @materials.Material::basic()
  assert_eq(basic.light_map is None, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.light_map is None, true)
  let pixels = FixedArray::make(4, b'\xFF')
  pixels[1] = b'\x80'
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  lambert.light_map = Some(map)
  let other = @materials.Material::lambert()
  assert_eq(other.light_map is None, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  match destination.light_map {
    None => abort("copied light map")
    Some(copied) => assert_eq(physical_equal(copied, map), true)
  }
  destination.light_map = None
  match lambert.light_map {
    None => abort("source light map")
    Some(kept) => assert_eq(physical_equal(kept, map), true)
  }
  let standard = @materials.Material::standard()
  assert_eq(standard.light_map is None, true)
}

///|
test "Material lightMapIntensity defaults to one and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.light_map_intensity, 1.0)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.light_map_intensity, 1.0)
  lambert.light_map_intensity = 2.0
  let other = @materials.Material::lambert()
  assert_eq(other.light_map_intensity, 1.0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.light_map_intensity, 2.0)
  destination.light_map_intensity = 0.0
  assert_eq(lambert.light_map_intensity, 2.0)
  let standard = @materials.Material::standard()
  assert_eq(standard.light_map_intensity, 1.0)
}

///|
test "Material aoMap starts empty and copies by reference" {
  let basic = @materials.Material::basic()
  assert_eq(basic.ao_map is None, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.ao_map is None, true)
  let pixels = FixedArray::make(4, b'\xFF')
  pixels[1] = b'\x80'
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  lambert.ao_map = Some(map)
  let other = @materials.Material::lambert()
  assert_eq(other.ao_map is None, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  match destination.ao_map {
    None => abort("copied ao map")
    Some(copied) => assert_eq(physical_equal(copied, map), true)
  }
  destination.ao_map = None
  match lambert.ao_map {
    None => abort("source ao map")
    Some(kept) => assert_eq(physical_equal(kept, map), true)
  }
  let standard = @materials.Material::standard()
  assert_eq(standard.ao_map is None, true)
}

///|
test "Material aoMapIntensity defaults to one and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.ao_map_intensity, 1.0)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.ao_map_intensity, 1.0)
  lambert.ao_map_intensity = 2.0
  let other = @materials.Material::lambert()
  assert_eq(other.ao_map_intensity, 1.0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.ao_map_intensity, 2.0)
  destination.ao_map_intensity = 0.0
  assert_eq(lambert.ao_map_intensity, 2.0)
  let standard = @materials.Material::standard()
  assert_eq(standard.ao_map_intensity, 1.0)
}

///|
test "Material bumpMap starts empty and copies by reference" {
  let basic = @materials.Material::basic()
  assert_eq(basic.bump_map is None, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.bump_map is None, true)
  let pixels = FixedArray::make(4, b'\xFF')
  pixels[1] = b'\x80'
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  lambert.bump_map = Some(map)
  let other = @materials.Material::lambert()
  assert_eq(other.bump_map is None, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  match destination.bump_map {
    None => abort("copied bump map")
    Some(copied) => assert_eq(physical_equal(copied, map), true)
  }
  destination.bump_map = None
  match lambert.bump_map {
    None => abort("source bump map")
    Some(kept) => assert_eq(physical_equal(kept, map), true)
  }
  let standard = @materials.Material::standard()
  assert_eq(standard.bump_map is None, true)
}

///|
test "Material bumpScale defaults to one and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.bump_scale, 1.0)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.bump_scale, 1.0)
  lambert.bump_scale = 2.0
  let other = @materials.Material::lambert()
  assert_eq(other.bump_scale, 1.0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.bump_scale, 2.0)
  destination.bump_scale = 0.0
  assert_eq(lambert.bump_scale, 2.0)
  let standard = @materials.Material::standard()
  assert_eq(standard.bump_scale, 1.0)
}

///|
test "Material wireframeLinewidth defaults to one and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.wireframe_linewidth, 1.0)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.wireframe_linewidth, 1.0)
  lambert.wireframe_linewidth = 4.0
  let other = @materials.Material::lambert()
  assert_eq(other.wireframe_linewidth, 1.0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.wireframe_linewidth, 4.0)
  destination.wireframe_linewidth = 2.0
  assert_eq(lambert.wireframe_linewidth, 4.0)
  let standard = @materials.Material::standard()
  assert_eq(standard.wireframe_linewidth, 1.0)
}

///|
test "Material wireframeLinecap defaults to round and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.wireframe_linecap is @materials.WireframeCap::Round, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.wireframe_linecap is @materials.WireframeCap::Round, true)
  lambert.wireframe_linecap = @materials.WireframeCap::Bevel
  let other = @materials.Material::lambert()
  assert_eq(other.wireframe_linecap is @materials.WireframeCap::Round, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.wireframe_linecap is @materials.WireframeCap::Bevel, true)
  destination.wireframe_linecap = @materials.WireframeCap::Miter
  assert_eq(lambert.wireframe_linecap is @materials.WireframeCap::Bevel, true)
  let standard = @materials.Material::standard()
  assert_eq(standard.wireframe_linecap is @materials.WireframeCap::Round, true)
}

///|
test "Material wireframeLinejoin defaults to round and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.wireframe_linejoin is @materials.WireframeJoin::Round, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.wireframe_linejoin is @materials.WireframeJoin::Round, true)
  lambert.wireframe_linejoin = @materials.WireframeJoin::Bevel
  let other = @materials.Material::lambert()
  assert_eq(other.wireframe_linejoin is @materials.WireframeJoin::Round, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.wireframe_linejoin is @materials.WireframeJoin::Bevel, true)
  destination.wireframe_linejoin = @materials.WireframeJoin::Miter
  assert_eq(lambert.wireframe_linejoin is @materials.WireframeJoin::Bevel, true)
  let standard = @materials.Material::standard()
  assert_eq(standard.wireframe_linejoin is @materials.WireframeJoin::Round, true)
}

///|
test "Material defines starts empty except standard and resets on copy" {
  let basic = @materials.Material::basic()
  match basic.defines.get("STANDARD") {
    None => ()
    Some(_) => abort("basic defines")
  }
  let lambert = @materials.Material::lambert()
  match lambert.defines.get("STANDARD") {
    None => ()
    Some(_) => abort("lambert defines")
  }
  let standard = @materials.Material::standard()
  match standard.defines.get("STANDARD") {
    None => abort("standard defines")
    Some(value) => assert_eq(value, "")
  }
  standard.defines.set("FOO", "1")
  let other = @materials.Material::standard()
  match other.defines.get("FOO") {
    None => ()
    Some(_) => abort("other foo")
  }
  match other.defines.get("STANDARD") {
    None => abort("other standard")
    Some(value) => assert_eq(value, "")
  }
  let basic_dest = @materials.Material::basic()
  ignore(basic_dest.copy(standard))
  match basic_dest.defines.get("STANDARD") {
    None => ()
    Some(_) => abort("basic dest standard")
  }
  match basic_dest.defines.get("FOO") {
    None => ()
    Some(_) => abort("basic dest foo")
  }
  match standard.defines.get("FOO") {
    None => abort("source foo")
    Some(value) => assert_eq(value, "1")
  }
  let standard_dest = @materials.Material::standard()
  ignore(standard_dest.copy(standard))
  match standard_dest.defines.get("STANDARD") {
    None => abort("dest standard")
    Some(value) => assert_eq(value, "")
  }
  match standard_dest.defines.get("FOO") {
    None => ()
    Some(_) => abort("dest foo")
  }
  match standard.defines.get("FOO") {
    None => abort("source foo after copy")
    Some(value) => assert_eq(value, "1")
  }
  standard_dest.defines.set("STANDARD", "x")
  match standard.defines.get("STANDARD") {
    None => abort("source standard")
    Some(value) => assert_eq(value, "")
  }
}

///|
test "Material anisotropyRotation defaults to zero and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.anisotropy_rotation, 0.0)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.anisotropy_rotation, 0.0)
  lambert.anisotropy_rotation = 0.25
  let other = @materials.Material::lambert()
  assert_eq(other.anisotropy_rotation, 0.0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.anisotropy_rotation, 0.25)
  destination.anisotropy_rotation = 1.0
  assert_eq(lambert.anisotropy_rotation, 0.25)
  let standard = @materials.Material::standard()
  assert_eq(standard.anisotropy_rotation, 0.0)
}

///|
test "Material anisotropyMap starts empty and copies by reference" {
  let basic = @materials.Material::basic()
  assert_eq(basic.anisotropy_map is None, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.anisotropy_map is None, true)
  let pixels = FixedArray::make(4, b'\xFF')
  pixels[1] = b'\x80'
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  lambert.anisotropy_map = Some(map)
  let other = @materials.Material::lambert()
  assert_eq(other.anisotropy_map is None, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  match destination.anisotropy_map {
    None => abort("copied anisotropy map")
    Some(copied) => assert_eq(physical_equal(copied, map), true)
  }
  destination.anisotropy_map = None
  match lambert.anisotropy_map {
    None => abort("source anisotropy map")
    Some(kept) => assert_eq(physical_equal(kept, map), true)
  }
  let standard = @materials.Material::standard()
  assert_eq(standard.anisotropy_map is None, true)
}

///|
test "Material clearcoatMap starts empty and copies by reference" {
  let basic = @materials.Material::basic()
  assert_eq(basic.clearcoat_map is None, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.clearcoat_map is None, true)
  let pixels = FixedArray::make(4, b'\xFF')
  pixels[1] = b'\x80'
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  lambert.clearcoat_map = Some(map)
  let other = @materials.Material::lambert()
  assert_eq(other.clearcoat_map is None, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  match destination.clearcoat_map {
    None => abort("copied clearcoat map")
    Some(copied) => assert_eq(physical_equal(copied, map), true)
  }
  destination.clearcoat_map = None
  match lambert.clearcoat_map {
    None => abort("source clearcoat map")
    Some(kept) => assert_eq(physical_equal(kept, map), true)
  }
  let standard = @materials.Material::standard()
  assert_eq(standard.clearcoat_map is None, true)
}

///|
test "Material clearcoatRoughness defaults to zero and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.clearcoat_roughness, 0.0)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.clearcoat_roughness, 0.0)
  lambert.clearcoat_roughness = 0.25
  let other = @materials.Material::lambert()
  assert_eq(other.clearcoat_roughness, 0.0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.clearcoat_roughness, 0.25)
  destination.clearcoat_roughness = 1.0
  assert_eq(lambert.clearcoat_roughness, 0.25)
  let standard = @materials.Material::standard()
  assert_eq(standard.clearcoat_roughness, 0.0)
}

///|
test "Material clearcoatRoughnessMap starts empty and copies by reference" {
  let basic = @materials.Material::basic()
  assert_eq(basic.clearcoat_roughness_map is None, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.clearcoat_roughness_map is None, true)
  let pixels = FixedArray::make(4, b'\xFF')
  pixels[1] = b'\x80'
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  lambert.clearcoat_roughness_map = Some(map)
  let other = @materials.Material::lambert()
  assert_eq(other.clearcoat_roughness_map is None, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  match destination.clearcoat_roughness_map {
    None => abort("copied clearcoat roughness map")
    Some(copied) => assert_eq(physical_equal(copied, map), true)
  }
  destination.clearcoat_roughness_map = None
  match lambert.clearcoat_roughness_map {
    None => abort("source clearcoat roughness map")
    Some(kept) => assert_eq(physical_equal(kept, map), true)
  }
  let standard = @materials.Material::standard()
  assert_eq(standard.clearcoat_roughness_map is None, true)
}

///|
test "Material clearcoatNormalScale starts at one and copies into the destination" {
  let basic = @materials.Material::basic()
  assert_eq(basic.clearcoat_normal_scale.x, 1.0)
  assert_eq(basic.clearcoat_normal_scale.y, 1.0)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.clearcoat_normal_scale.x, 1.0)
  assert_eq(lambert.clearcoat_normal_scale.y, 1.0)
  lambert.clearcoat_normal_scale.x = 0.25
  lambert.clearcoat_normal_scale.y = 0.5
  let other = @materials.Material::lambert()
  assert_eq(other.clearcoat_normal_scale.x, 1.0)
  assert_eq(other.clearcoat_normal_scale.y, 1.0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.clearcoat_normal_scale.x, 0.25)
  assert_eq(destination.clearcoat_normal_scale.y, 0.5)
  destination.clearcoat_normal_scale.x = 0.0
  assert_eq(lambert.clearcoat_normal_scale.x, 0.25)
  assert_eq(lambert.clearcoat_normal_scale.y, 0.5)
  let standard = @materials.Material::standard()
  assert_eq(standard.clearcoat_normal_scale.x, 1.0)
  assert_eq(standard.clearcoat_normal_scale.y, 1.0)
}

///|
test "Material clearcoatNormalMap starts empty and copies by reference" {
  let basic = @materials.Material::basic()
  assert_eq(basic.clearcoat_normal_map is None, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.clearcoat_normal_map is None, true)
  let pixels = FixedArray::make(4, b'\xFF')
  pixels[1] = b'\x80'
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  lambert.clearcoat_normal_map = Some(map)
  let other = @materials.Material::lambert()
  assert_eq(other.clearcoat_normal_map is None, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  match destination.clearcoat_normal_map {
    None => abort("copied clearcoat normal map")
    Some(copied) => assert_eq(physical_equal(copied, map), true)
  }
  destination.clearcoat_normal_map = None
  match lambert.clearcoat_normal_map {
    None => abort("source clearcoat normal map")
    Some(kept) => assert_eq(physical_equal(kept, map), true)
  }
  let standard = @materials.Material::standard()
  assert_eq(standard.clearcoat_normal_map is None, true)
}

///|
test "Material ior defaults to one and a half and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.ior, 1.5)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.ior, 1.5)
  lambert.ior = 2.0
  let other = @materials.Material::lambert()
  assert_eq(other.ior, 1.5)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.ior, 2.0)
  destination.ior = 1.0
  assert_eq(lambert.ior, 2.0)
  let standard = @materials.Material::standard()
  assert_eq(standard.ior, 1.5)
}

///|
test "Material iridescenceMap starts empty and copies by reference" {
  let basic = @materials.Material::basic()
  assert_eq(basic.iridescence_map is None, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.iridescence_map is None, true)
  let pixels = FixedArray::make(4, b'\xFF')
  pixels[1] = b'\x80'
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  lambert.iridescence_map = Some(map)
  let other = @materials.Material::lambert()
  assert_eq(other.iridescence_map is None, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  match destination.iridescence_map {
    None => abort("copied iridescence map")
    Some(copied) => assert_eq(physical_equal(copied, map), true)
  }
  destination.iridescence_map = None
  match lambert.iridescence_map {
    None => abort("source iridescence map")
    Some(kept) => assert_eq(physical_equal(kept, map), true)
  }
  let standard = @materials.Material::standard()
  assert_eq(standard.iridescence_map is None, true)
}

///|
test "Material iridescenceIOR defaults to 1.3 and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.iridescence_ior, 1.3)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.iridescence_ior, 1.3)
  lambert.iridescence_ior = 2.0
  let other = @materials.Material::lambert()
  assert_eq(other.iridescence_ior, 1.3)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.iridescence_ior, 2.0)
  destination.iridescence_ior = 1.0
  assert_eq(lambert.iridescence_ior, 2.0)
  let standard = @materials.Material::standard()
  assert_eq(standard.iridescence_ior, 1.3)
}

///|
test "Material iridescenceThicknessRange starts at 100 and 400 and copies by value" {
  let basic = @materials.Material::basic()
  assert_eq(basic.iridescence_thickness_range.length(), 2)
  assert_eq(basic.iridescence_thickness_range[0], 100.0)
  assert_eq(basic.iridescence_thickness_range[1], 400.0)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.iridescence_thickness_range[0], 100.0)
  assert_eq(lambert.iridescence_thickness_range[1], 400.0)
  lambert.iridescence_thickness_range[0] = 20.0
  lambert.iridescence_thickness_range[1] = 80.0
  let other = @materials.Material::lambert()
  assert_eq(other.iridescence_thickness_range[0], 100.0)
  assert_eq(other.iridescence_thickness_range[1], 400.0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.iridescence_thickness_range[0], 20.0)
  assert_eq(destination.iridescence_thickness_range[1], 80.0)
  destination.iridescence_thickness_range[0] = 0.0
  assert_eq(lambert.iridescence_thickness_range[0], 20.0)
  assert_eq(lambert.iridescence_thickness_range[1], 80.0)
  let standard = @materials.Material::standard()
  assert_eq(standard.iridescence_thickness_range[0], 100.0)
  assert_eq(standard.iridescence_thickness_range[1], 400.0)
}

///|
test "Material iridescenceThicknessMap starts empty and copies by reference" {
  let basic = @materials.Material::basic()
  assert_eq(basic.iridescence_thickness_map is None, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.iridescence_thickness_map is None, true)
  let pixels = FixedArray::make(4, b'\xFF')
  pixels[1] = b'\x80'
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  lambert.iridescence_thickness_map = Some(map)
  let other = @materials.Material::lambert()
  assert_eq(other.iridescence_thickness_map is None, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  match destination.iridescence_thickness_map {
    None => abort("copied iridescence thickness map")
    Some(copied) => assert_eq(physical_equal(copied, map), true)
  }
  destination.iridescence_thickness_map = None
  match lambert.iridescence_thickness_map {
    None => abort("source iridescence thickness map")
    Some(kept) => assert_eq(physical_equal(kept, map), true)
  }
  let standard = @materials.Material::standard()
  assert_eq(standard.iridescence_thickness_map is None, true)
}

///|
test "Material sheenColor starts black and copies into the destination" {
  let basic = @materials.Material::basic()
  assert_eq(basic.sheen_color.r, 0.0)
  assert_eq(basic.sheen_color.g, 0.0)
  assert_eq(basic.sheen_color.b, 0.0)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.sheen_color.r, 0.0)
  ignore(lambert.sheen_color.set_rgb(0.25, 0.5, 0.75))
  let other = @materials.Material::lambert()
  assert_eq(other.sheen_color.r, 0.0)
  assert_eq(other.sheen_color.g, 0.0)
  assert_eq(other.sheen_color.b, 0.0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.sheen_color.r, 0.25)
  assert_eq(destination.sheen_color.g, 0.5)
  assert_eq(destination.sheen_color.b, 0.75)
  ignore(destination.sheen_color.set_rgb(1.0, 0.0, 0.0))
  assert_eq(lambert.sheen_color.r, 0.25)
  assert_eq(lambert.sheen_color.g, 0.5)
  assert_eq(lambert.sheen_color.b, 0.75)
  let standard = @materials.Material::standard()
  assert_eq(standard.sheen_color.r, 0.0)
  assert_eq(standard.sheen_color.g, 0.0)
  assert_eq(standard.sheen_color.b, 0.0)
}

///|
test "Material sheenColorMap starts empty and copies by reference" {
  let basic = @materials.Material::basic()
  assert_eq(basic.sheen_color_map is None, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.sheen_color_map is None, true)
  let pixels = FixedArray::make(4, b'\xFF')
  pixels[1] = b'\x80'
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  lambert.sheen_color_map = Some(map)
  let other = @materials.Material::lambert()
  assert_eq(other.sheen_color_map is None, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  match destination.sheen_color_map {
    None => abort("copied sheen color map")
    Some(copied) => assert_eq(physical_equal(copied, map), true)
  }
  destination.sheen_color_map = None
  match lambert.sheen_color_map {
    None => abort("source sheen color map")
    Some(kept) => assert_eq(physical_equal(kept, map), true)
  }
  let standard = @materials.Material::standard()
  assert_eq(standard.sheen_color_map is None, true)
}

///|
test "Material sheenRoughness defaults to one and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.sheen_roughness, 1.0)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.sheen_roughness, 1.0)
  lambert.sheen_roughness = 0.25
  let other = @materials.Material::lambert()
  assert_eq(other.sheen_roughness, 1.0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.sheen_roughness, 0.25)
  destination.sheen_roughness = 0.0
  assert_eq(lambert.sheen_roughness, 0.25)
  let standard = @materials.Material::standard()
  assert_eq(standard.sheen_roughness, 1.0)
}

///|
test "Material sheenRoughnessMap starts empty and copies by reference" {
  let basic = @materials.Material::basic()
  assert_eq(basic.sheen_roughness_map is None, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.sheen_roughness_map is None, true)
  let pixels = FixedArray::make(4, b'\xFF')
  pixels[1] = b'\x80'
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  lambert.sheen_roughness_map = Some(map)
  let other = @materials.Material::lambert()
  assert_eq(other.sheen_roughness_map is None, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  match destination.sheen_roughness_map {
    None => abort("copied sheen roughness map")
    Some(copied) => assert_eq(physical_equal(copied, map), true)
  }
  destination.sheen_roughness_map = None
  match lambert.sheen_roughness_map {
    None => abort("source sheen roughness map")
    Some(kept) => assert_eq(physical_equal(kept, map), true)
  }
  let standard = @materials.Material::standard()
  assert_eq(standard.sheen_roughness_map is None, true)
}

///|
test "Material transmissionMap starts empty and copies by reference" {
  let basic = @materials.Material::basic()
  assert_eq(basic.transmission_map is None, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.transmission_map is None, true)
  let pixels = FixedArray::make(4, b'\xFF')
  pixels[1] = b'\x80'
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  lambert.transmission_map = Some(map)
  let other = @materials.Material::lambert()
  assert_eq(other.transmission_map is None, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  match destination.transmission_map {
    None => abort("copied transmission map")
    Some(copied) => assert_eq(physical_equal(copied, map), true)
  }
  destination.transmission_map = None
  match lambert.transmission_map {
    None => abort("source transmission map")
    Some(kept) => assert_eq(physical_equal(kept, map), true)
  }
  let standard = @materials.Material::standard()
  assert_eq(standard.transmission_map is None, true)
}

///|
test "Material thickness defaults to zero and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.thickness, 0.0)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.thickness, 0.0)
  lambert.thickness = 0.25
  let other = @materials.Material::lambert()
  assert_eq(other.thickness, 0.0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.thickness, 0.25)
  destination.thickness = 1.0
  assert_eq(lambert.thickness, 0.25)
  let standard = @materials.Material::standard()
  assert_eq(standard.thickness, 0.0)
}

///|
test "Material thicknessMap starts empty and copies by reference" {
  let basic = @materials.Material::basic()
  assert_eq(basic.thickness_map is None, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.thickness_map is None, true)
  let pixels = FixedArray::make(4, b'\xFF')
  pixels[1] = b'\x80'
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  lambert.thickness_map = Some(map)
  let other = @materials.Material::lambert()
  assert_eq(other.thickness_map is None, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  match destination.thickness_map {
    None => abort("copied thickness map")
    Some(copied) => assert_eq(physical_equal(copied, map), true)
  }
  destination.thickness_map = None
  match lambert.thickness_map {
    None => abort("source thickness map")
    Some(kept) => assert_eq(physical_equal(kept, map), true)
  }
  let standard = @materials.Material::standard()
  assert_eq(standard.thickness_map is None, true)
}

///|
test "Material attenuationDistance defaults to positive infinity and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.attenuation_distance.is_inf(), true)
  assert_eq(basic.attenuation_distance > 0.0, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.attenuation_distance.is_inf(), true)
  lambert.attenuation_distance = 2.0
  let other = @materials.Material::lambert()
  assert_eq(other.attenuation_distance.is_inf(), true)
  assert_eq(other.attenuation_distance > 0.0, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.attenuation_distance, 2.0)
  destination.attenuation_distance = 1.0
  assert_eq(lambert.attenuation_distance, 2.0)
  let standard = @materials.Material::standard()
  assert_eq(standard.attenuation_distance.is_inf(), true)
  assert_eq(standard.attenuation_distance > 0.0, true)
}

///|
test "Material attenuationColor starts white and copies into the destination" {
  let basic = @materials.Material::basic()
  assert_eq(basic.attenuation_color.r, 1.0)
  assert_eq(basic.attenuation_color.g, 1.0)
  assert_eq(basic.attenuation_color.b, 1.0)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.attenuation_color.r, 1.0)
  ignore(lambert.attenuation_color.set_rgb(0.25, 0.5, 0.75))
  let other = @materials.Material::lambert()
  assert_eq(other.attenuation_color.r, 1.0)
  assert_eq(other.attenuation_color.g, 1.0)
  assert_eq(other.attenuation_color.b, 1.0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.attenuation_color.r, 0.25)
  assert_eq(destination.attenuation_color.g, 0.5)
  assert_eq(destination.attenuation_color.b, 0.75)
  ignore(destination.attenuation_color.set_rgb(1.0, 0.0, 0.0))
  assert_eq(lambert.attenuation_color.r, 0.25)
  assert_eq(lambert.attenuation_color.g, 0.5)
  assert_eq(lambert.attenuation_color.b, 0.75)
  let standard = @materials.Material::standard()
  assert_eq(standard.attenuation_color.r, 1.0)
  assert_eq(standard.attenuation_color.g, 1.0)
  assert_eq(standard.attenuation_color.b, 1.0)
}

///|
test "Material specularIntensity defaults to one and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.specular_intensity, 1.0)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.specular_intensity, 1.0)
  lambert.specular_intensity = 0.25
  let other = @materials.Material::lambert()
  assert_eq(other.specular_intensity, 1.0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.specular_intensity, 0.25)
  destination.specular_intensity = 0.0
  assert_eq(lambert.specular_intensity, 0.25)
  let standard = @materials.Material::standard()
  assert_eq(standard.specular_intensity, 1.0)
}

///|
test "Material specularIntensityMap starts empty and copies by reference" {
  let basic = @materials.Material::basic()
  assert_eq(basic.specular_intensity_map is None, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.specular_intensity_map is None, true)
  let pixels = FixedArray::make(4, b'\xFF')
  pixels[1] = b'\x80'
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  lambert.specular_intensity_map = Some(map)
  let other = @materials.Material::lambert()
  assert_eq(other.specular_intensity_map is None, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  match destination.specular_intensity_map {
    None => abort("copied specular intensity map")
    Some(copied) => assert_eq(physical_equal(copied, map), true)
  }
  destination.specular_intensity_map = None
  match lambert.specular_intensity_map {
    None => abort("source specular intensity map")
    Some(kept) => assert_eq(physical_equal(kept, map), true)
  }
  let standard = @materials.Material::standard()
  assert_eq(standard.specular_intensity_map is None, true)
}

///|
test "Material specularColor starts white and copies into the destination" {
  let basic = @materials.Material::basic()
  assert_eq(basic.specular_color.r, 1.0)
  assert_eq(basic.specular_color.g, 1.0)
  assert_eq(basic.specular_color.b, 1.0)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.specular_color.r, 1.0)
  ignore(lambert.specular_color.set_rgb(0.25, 0.5, 0.75))
  let other = @materials.Material::lambert()
  assert_eq(other.specular_color.r, 1.0)
  assert_eq(other.specular_color.g, 1.0)
  assert_eq(other.specular_color.b, 1.0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.specular_color.r, 0.25)
  assert_eq(destination.specular_color.g, 0.5)
  assert_eq(destination.specular_color.b, 0.75)
  ignore(destination.specular_color.set_rgb(1.0, 0.0, 0.0))
  assert_eq(lambert.specular_color.r, 0.25)
  assert_eq(lambert.specular_color.g, 0.5)
  assert_eq(lambert.specular_color.b, 0.75)
  let standard = @materials.Material::standard()
  assert_eq(standard.specular_color.r, 1.0)
  assert_eq(standard.specular_color.g, 1.0)
  assert_eq(standard.specular_color.b, 1.0)
}

///|
test "Material specularColorMap starts empty and copies by reference" {
  let basic = @materials.Material::basic()
  assert_eq(basic.specular_color_map is None, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.specular_color_map is None, true)
  let pixels = FixedArray::make(4, b'\xFF')
  pixels[1] = b'\x80'
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  lambert.specular_color_map = Some(map)
  let other = @materials.Material::lambert()
  assert_eq(other.specular_color_map is None, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  match destination.specular_color_map {
    None => abort("copied specular color map")
    Some(copied) => assert_eq(physical_equal(copied, map), true)
  }
  destination.specular_color_map = None
  match lambert.specular_color_map {
    None => abort("source specular color map")
    Some(kept) => assert_eq(physical_equal(kept, map), true)
  }
  let standard = @materials.Material::standard()
  assert_eq(standard.specular_color_map is None, true)
}

///|
test "Material set_anisotropy bumps version across zero and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.anisotropy, 0.0)
  assert_eq(basic.version, 0)
  basic.set_anisotropy(0.0)
  assert_eq(basic.version, 0)
  basic.set_anisotropy(0.25)
  assert_eq(basic.anisotropy, 0.25)
  assert_eq(basic.version, 1)
  basic.set_anisotropy(0.5)
  assert_eq(basic.version, 1)
  basic.set_anisotropy(0.0)
  assert_eq(basic.anisotropy, 0.0)
  assert_eq(basic.version, 2)
  basic.set_anisotropy(-1.0)
  assert_eq(basic.anisotropy, -1.0)
  assert_eq(basic.version, 2)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.anisotropy, 0.0)
  lambert.set_anisotropy(0.25)
  assert_eq(lambert.version, 1)
  let other = @materials.Material::lambert()
  assert_eq(other.anisotropy, 0.0)
  assert_eq(other.version, 0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.anisotropy, 0.25)
  assert_eq(destination.version, 1)
  destination.set_anisotropy(0.0)
  assert_eq(destination.version, 2)
  assert_eq(lambert.anisotropy, 0.25)
  assert_eq(lambert.version, 1)
  let standard = @materials.Material::standard()
  assert_eq(standard.anisotropy, 0.0)
  assert_eq(standard.version, 0)
}

///|
test "Material set_clearcoat bumps version across zero and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.clearcoat, 0.0)
  assert_eq(basic.version, 0)
  basic.set_clearcoat(0.0)
  assert_eq(basic.version, 0)
  basic.set_clearcoat(0.25)
  assert_eq(basic.clearcoat, 0.25)
  assert_eq(basic.version, 1)
  basic.set_clearcoat(0.5)
  assert_eq(basic.version, 1)
  basic.set_clearcoat(0.0)
  assert_eq(basic.clearcoat, 0.0)
  assert_eq(basic.version, 2)
  basic.set_clearcoat(-1.0)
  assert_eq(basic.clearcoat, -1.0)
  assert_eq(basic.version, 2)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.clearcoat, 0.0)
  lambert.set_clearcoat(0.25)
  assert_eq(lambert.version, 1)
  let other = @materials.Material::lambert()
  assert_eq(other.clearcoat, 0.0)
  assert_eq(other.version, 0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.clearcoat, 0.25)
  assert_eq(destination.version, 1)
  destination.set_clearcoat(0.0)
  assert_eq(destination.version, 2)
  assert_eq(lambert.clearcoat, 0.25)
  assert_eq(lambert.version, 1)
  let standard = @materials.Material::standard()
  assert_eq(standard.clearcoat, 0.0)
  assert_eq(standard.version, 0)
}

///|
test "Material set_iridescence bumps version across zero and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.iridescence, 0.0)
  assert_eq(basic.version, 0)
  basic.set_iridescence(0.0)
  assert_eq(basic.version, 0)
  basic.set_iridescence(0.25)
  assert_eq(basic.iridescence, 0.25)
  assert_eq(basic.version, 1)
  basic.set_iridescence(0.5)
  assert_eq(basic.version, 1)
  basic.set_iridescence(0.0)
  assert_eq(basic.iridescence, 0.0)
  assert_eq(basic.version, 2)
  basic.set_iridescence(-1.0)
  assert_eq(basic.iridescence, -1.0)
  assert_eq(basic.version, 2)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.iridescence, 0.0)
  lambert.set_iridescence(0.25)
  assert_eq(lambert.version, 1)
  let other = @materials.Material::lambert()
  assert_eq(other.iridescence, 0.0)
  assert_eq(other.version, 0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.iridescence, 0.25)
  assert_eq(destination.version, 1)
  destination.set_iridescence(0.0)
  assert_eq(destination.version, 2)
  assert_eq(lambert.iridescence, 0.25)
  assert_eq(lambert.version, 1)
  let standard = @materials.Material::standard()
  assert_eq(standard.iridescence, 0.0)
  assert_eq(standard.version, 0)
}

///|
test "Material set_dispersion bumps version across zero and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.dispersion, 0.0)
  assert_eq(basic.version, 0)
  basic.set_dispersion(0.0)
  assert_eq(basic.version, 0)
  basic.set_dispersion(0.25)
  assert_eq(basic.dispersion, 0.25)
  assert_eq(basic.version, 1)
  basic.set_dispersion(0.5)
  assert_eq(basic.version, 1)
  basic.set_dispersion(0.0)
  assert_eq(basic.dispersion, 0.0)
  assert_eq(basic.version, 2)
  basic.set_dispersion(-1.0)
  assert_eq(basic.dispersion, -1.0)
  assert_eq(basic.version, 2)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.dispersion, 0.0)
  lambert.set_dispersion(0.25)
  assert_eq(lambert.version, 1)
  let other = @materials.Material::lambert()
  assert_eq(other.dispersion, 0.0)
  assert_eq(other.version, 0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.dispersion, 0.25)
  assert_eq(destination.version, 1)
  destination.set_dispersion(0.0)
  assert_eq(destination.version, 2)
  assert_eq(lambert.dispersion, 0.25)
  assert_eq(lambert.version, 1)
  let standard = @materials.Material::standard()
  assert_eq(standard.dispersion, 0.0)
  assert_eq(standard.version, 0)
}

///|
test "Material set_retroreflectivity bumps version across zero and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.retroreflectivity, 0.0)
  assert_eq(basic.version, 0)
  basic.set_retroreflectivity(0.0)
  assert_eq(basic.version, 0)
  basic.set_retroreflectivity(0.25)
  assert_eq(basic.retroreflectivity, 0.25)
  assert_eq(basic.version, 1)
  basic.set_retroreflectivity(0.5)
  assert_eq(basic.version, 1)
  basic.set_retroreflectivity(0.0)
  assert_eq(basic.retroreflectivity, 0.0)
  assert_eq(basic.version, 2)
  basic.set_retroreflectivity(-1.0)
  assert_eq(basic.retroreflectivity, -1.0)
  assert_eq(basic.version, 2)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.retroreflectivity, 0.0)
  lambert.set_retroreflectivity(0.25)
  assert_eq(lambert.version, 1)
  let other = @materials.Material::lambert()
  assert_eq(other.retroreflectivity, 0.0)
  assert_eq(other.version, 0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.retroreflectivity, 0.25)
  assert_eq(destination.version, 1)
  destination.set_retroreflectivity(0.0)
  assert_eq(destination.version, 2)
  assert_eq(lambert.retroreflectivity, 0.25)
  assert_eq(lambert.version, 1)
  let standard = @materials.Material::standard()
  assert_eq(standard.retroreflectivity, 0.0)
  assert_eq(standard.version, 0)
}

///|
test "Material set_sheen bumps version across zero and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.sheen, 0.0)
  assert_eq(basic.version, 0)
  basic.set_sheen(0.0)
  assert_eq(basic.version, 0)
  basic.set_sheen(0.25)
  assert_eq(basic.sheen, 0.25)
  assert_eq(basic.version, 1)
  basic.set_sheen(0.5)
  assert_eq(basic.version, 1)
  basic.set_sheen(0.0)
  assert_eq(basic.sheen, 0.0)
  assert_eq(basic.version, 2)
  basic.set_sheen(-1.0)
  assert_eq(basic.sheen, -1.0)
  assert_eq(basic.version, 2)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.sheen, 0.0)
  lambert.set_sheen(0.25)
  assert_eq(lambert.version, 1)
  let other = @materials.Material::lambert()
  assert_eq(other.sheen, 0.0)
  assert_eq(other.version, 0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.sheen, 0.25)
  assert_eq(destination.version, 1)
  destination.set_sheen(0.0)
  assert_eq(destination.version, 2)
  assert_eq(lambert.sheen, 0.25)
  assert_eq(lambert.version, 1)
  let standard = @materials.Material::standard()
  assert_eq(standard.sheen, 0.0)
  assert_eq(standard.version, 0)
}

///|
test "Material set_transmission bumps version across zero and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.transmission, 0.0)
  assert_eq(basic.version, 0)
  basic.set_transmission(0.0)
  assert_eq(basic.version, 0)
  basic.set_transmission(0.25)
  assert_eq(basic.transmission, 0.25)
  assert_eq(basic.version, 1)
  basic.set_transmission(0.5)
  assert_eq(basic.version, 1)
  basic.set_transmission(0.0)
  assert_eq(basic.transmission, 0.0)
  assert_eq(basic.version, 2)
  basic.set_transmission(-1.0)
  assert_eq(basic.transmission, -1.0)
  assert_eq(basic.version, 2)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.transmission, 0.0)
  lambert.set_transmission(0.25)
  assert_eq(lambert.version, 1)
  let other = @materials.Material::lambert()
  assert_eq(other.transmission, 0.0)
  assert_eq(other.version, 0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.transmission, 0.25)
  assert_eq(destination.version, 1)
  destination.set_transmission(0.0)
  assert_eq(destination.version, 2)
  assert_eq(lambert.transmission, 0.25)
  assert_eq(lambert.version, 1)
  let standard = @materials.Material::standard()
  assert_eq(standard.transmission, 0.0)
  assert_eq(standard.version, 0)
}

///|
test "Material physical sets isMeshPhysicalMaterial and keeps it on copy" {
  let basic = @materials.Material::basic()
  let lambert = @materials.Material::lambert()
  let standard = @materials.Material::standard()
  assert_eq(basic.is_mesh_physical_material, false)
  assert_eq(lambert.is_mesh_physical_material, false)
  assert_eq(standard.is_mesh_physical_material, false)
  assert_eq(standard.type_name, "MeshStandardMaterial")
  let physical = @materials.Material::physical(hex=0xFF0000, roughness=0.25, metalness=0.5)
  assert_eq(physical.is_mesh_physical_material, true)
  assert_eq(physical.type_name, "MeshPhysicalMaterial")
  assert_eq(physical.kind is @materials.MaterialKind::Physical, true)
  assert_eq(physical.shading() is @constants.Standard, true)
  assert_eq(physical.color.r, 1.0)
  assert_eq(physical.roughness, 0.25)
  assert_eq(physical.metalness, 0.5)
  match physical.defines.get("STANDARD") {
    None => abort("physical standard define")
    Some(value) => assert_eq(value, "")
  }
  match physical.defines.get("PHYSICAL") {
    None => abort("physical define")
    Some(value) => assert_eq(value, "")
  }
  physical.defines.set("FOO", "1")
  let destination = @materials.Material::basic()
  ignore(destination.copy(physical))
  assert_eq(destination.is_mesh_physical_material, false)
  assert_eq(destination.kind is @materials.MaterialKind::Basic, true)
  assert_eq(destination.type_name, "MeshBasicMaterial")
  assert_eq(destination.roughness, 0.25)
  assert_eq(physical.is_mesh_physical_material, true)
  match destination.defines.get("PHYSICAL") {
    None => ()
    Some(_) => abort("basic gained physical define")
  }
  let onto = @materials.Material::physical()
  onto.defines.set("FOO", "1")
  ignore(onto.copy(standard))
  assert_eq(onto.is_mesh_physical_material, true)
  assert_eq(onto.kind is @materials.MaterialKind::Physical, true)
  assert_eq(onto.type_name, "MeshPhysicalMaterial")
  assert_eq(onto.roughness, 1.0)
  match onto.defines.get("FOO") {
    None => ()
    Some(_) => abort("physical copy kept source define")
  }
  match onto.defines.get("STANDARD") {
    None => abort("physical copy standard define")
    Some(value) => assert_eq(value, "")
  }
  match onto.defines.get("PHYSICAL") {
    None => abort("physical copy physical define")
    Some(value) => assert_eq(value, "")
  }
  let cloned = physical.clone()
  assert_eq(cloned.is_mesh_physical_material, true)
  assert_eq(cloned.type_name, "MeshPhysicalMaterial")
  assert_eq(cloned.kind is @materials.MaterialKind::Physical, true)
  assert_eq(cloned.roughness, 0.25)
  assert_eq(cloned.id == physical.id, false)
}

///|
test "Material toon sets isMeshToonMaterial and keeps defines on copy" {
  let basic = @materials.Material::basic()
  let lambert = @materials.Material::lambert()
  let standard = @materials.Material::standard()
  let physical = @materials.Material::physical()
  assert_eq(basic.is_mesh_toon_material, false)
  assert_eq(lambert.is_mesh_toon_material, false)
  assert_eq(standard.is_mesh_toon_material, false)
  assert_eq(physical.is_mesh_toon_material, false)
  let toon = @materials.Material::toon(hex=0x00FF00)
  assert_eq(toon.is_mesh_toon_material, true)
  assert_eq(toon.is_mesh_physical_material, false)
  assert_eq(toon.type_name, "MeshToonMaterial")
  assert_eq(toon.kind is @materials.MaterialKind::Toon, true)
  assert_eq(toon.shading() is @constants.Lambert, true)
  assert_eq(toon.color.g, 1.0)
  assert_eq(toon.color.r, 0.0)
  match toon.defines.get("TOON") {
    None => abort("toon define")
    Some(value) => assert_eq(value, "")
  }
  match toon.defines.get("STANDARD") {
    None => ()
    Some(_) => abort("toon gained standard define")
  }
  let destination = @materials.Material::basic()
  ignore(destination.copy(toon))
  assert_eq(destination.is_mesh_toon_material, false)
  assert_eq(destination.kind is @materials.MaterialKind::Basic, true)
  assert_eq(destination.type_name, "MeshBasicMaterial")
  assert_eq(destination.color.r, 0.0)
  assert_eq(destination.color.g, 1.0)
  assert_eq(toon.is_mesh_toon_material, true)
  let onto = @materials.Material::toon()
  onto.defines.set("FOO", "1")
  let blue = @materials.Material::basic(hex=0x0000FF)
  ignore(onto.copy(blue))
  assert_eq(onto.is_mesh_toon_material, true)
  assert_eq(onto.kind is @materials.MaterialKind::Toon, true)
  assert_eq(onto.color.r, 0.0)
  assert_eq(onto.color.b, 1.0)
  match onto.defines.get("FOO") {
    None => abort("toon copy dropped define")
    Some(value) => assert_eq(value, "1")
  }
  match onto.defines.get("TOON") {
    None => abort("toon copy lost toon define")
    Some(value) => assert_eq(value, "")
  }
  let cloned = toon.clone()
  assert_eq(cloned.is_mesh_toon_material, true)
  assert_eq(cloned.type_name, "MeshToonMaterial")
  assert_eq(cloned.kind is @materials.MaterialKind::Toon, true)
  assert_eq(cloned.color.g, 1.0)
  assert_eq(cloned.id == toon.id, false)
}

///|
test "Material gradientMap starts empty and copies by reference" {
  let basic = @materials.Material::basic()
  assert_eq(basic.gradient_map is None, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.gradient_map is None, true)
  let toon = @materials.Material::toon()
  assert_eq(toon.gradient_map is None, true)
  let pixels = FixedArray::make(4, b'\xFF')
  pixels[1] = b'\x80'
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  toon.gradient_map = Some(map)
  let other = @materials.Material::toon()
  assert_eq(other.gradient_map is None, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(toon))
  match destination.gradient_map {
    None => abort("copied gradient map")
    Some(copied) => assert_eq(physical_equal(copied, map), true)
  }
  destination.gradient_map = None
  match toon.gradient_map {
    None => abort("source gradient map")
    Some(kept) => assert_eq(physical_equal(kept, map), true)
  }
  let standard = @materials.Material::standard()
  assert_eq(standard.gradient_map is None, true)
  let physical = @materials.Material::physical()
  assert_eq(physical.gradient_map is None, true)
}

///|
test "Material matcap starts empty and copies by reference" {
  let basic = @materials.Material::basic()
  assert_eq(basic.matcap is None, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.matcap is None, true)
  let pixels = FixedArray::make(4, b'\xFF')
  pixels[1] = b'\x80'
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  lambert.matcap = Some(map)
  let other = @materials.Material::lambert()
  assert_eq(other.matcap is None, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  match destination.matcap {
    None => abort("copied matcap")
    Some(copied) => assert_eq(physical_equal(copied, map), true)
  }
  destination.matcap = None
  match lambert.matcap {
    None => abort("source matcap")
    Some(kept) => assert_eq(physical_equal(kept, map), true)
  }
  let standard = @materials.Material::standard()
  assert_eq(standard.matcap is None, true)
  let physical = @materials.Material::physical()
  assert_eq(physical.matcap is None, true)
  let toon = @materials.Material::toon()
  assert_eq(toon.matcap is None, true)
}

///|
test "Material matcap sets isMeshMatcapMaterial and resets defines on copy" {
  let basic = @materials.Material::basic()
  let lambert = @materials.Material::lambert()
  let standard = @materials.Material::standard()
  let physical = @materials.Material::physical()
  let toon = @materials.Material::toon()
  assert_eq(basic.is_mesh_matcap_material, false)
  assert_eq(lambert.is_mesh_matcap_material, false)
  assert_eq(standard.is_mesh_matcap_material, false)
  assert_eq(physical.is_mesh_matcap_material, false)
  assert_eq(toon.is_mesh_matcap_material, false)
  let matcap = @materials.Material::matcap(hex=0x0000FF)
  assert_eq(matcap.is_mesh_matcap_material, true)
  assert_eq(matcap.is_mesh_toon_material, false)
  assert_eq(matcap.type_name, "MeshMatcapMaterial")
  assert_eq(matcap.kind is @materials.MaterialKind::Matcap, true)
  assert_eq(matcap.shading() is @constants.Basic, true)
  assert_eq(matcap.color.r, 0.0)
  assert_eq(matcap.color.b, 1.0)
  match matcap.defines.get("MATCAP") {
    None => abort("matcap define")
    Some(value) => assert_eq(value, "")
  }
  match matcap.defines.get("TOON") {
    None => ()
    Some(_) => abort("matcap gained toon define")
  }
  let destination = @materials.Material::basic()
  ignore(destination.copy(matcap))
  assert_eq(destination.is_mesh_matcap_material, false)
  assert_eq(destination.kind is @materials.MaterialKind::Basic, true)
  assert_eq(destination.type_name, "MeshBasicMaterial")
  assert_eq(destination.color.r, 0.0)
  assert_eq(destination.color.b, 1.0)
  assert_eq(matcap.is_mesh_matcap_material, true)
  let onto = @materials.Material::matcap()
  onto.defines.set("FOO", "1")
  ignore(onto.copy(standard))
  assert_eq(onto.is_mesh_matcap_material, true)
  assert_eq(onto.kind is @materials.MaterialKind::Matcap, true)
  assert_eq(onto.type_name, "MeshMatcapMaterial")
  assert_eq(onto.roughness, 1.0)
  match onto.defines.get("FOO") {
    None => ()
    Some(_) => abort("matcap copy kept source define")
  }
  match onto.defines.get("MATCAP") {
    None => abort("matcap copy define")
    Some(value) => assert_eq(value, "")
  }
  match onto.defines.get("STANDARD") {
    None => ()
    Some(_) => abort("matcap copy gained standard define")
  }
  let cloned = matcap.clone()
  assert_eq(cloned.is_mesh_matcap_material, true)
  assert_eq(cloned.type_name, "MeshMatcapMaterial")
  assert_eq(cloned.kind is @materials.MaterialKind::Matcap, true)
  assert_eq(cloned.color.b, 1.0)
  assert_eq(cloned.id == matcap.id, false)
}

///|
test "Material normal sets isMeshNormalMaterial and keeps defines on copy" {
  let basic = @materials.Material::basic()
  let lambert = @materials.Material::lambert()
  let standard = @materials.Material::standard()
  let physical = @materials.Material::physical()
  let toon = @materials.Material::toon()
  let matcap = @materials.Material::matcap()
  assert_eq(basic.is_mesh_normal_material, false)
  assert_eq(lambert.is_mesh_normal_material, false)
  assert_eq(standard.is_mesh_normal_material, false)
  assert_eq(physical.is_mesh_normal_material, false)
  assert_eq(toon.is_mesh_normal_material, false)
  assert_eq(matcap.is_mesh_normal_material, false)
  let normal = @materials.Material::normal(hex=0x00FF00)
  assert_eq(normal.is_mesh_normal_material, true)
  assert_eq(normal.is_mesh_matcap_material, false)
  assert_eq(normal.type_name, "MeshNormalMaterial")
  assert_eq(normal.kind is @materials.MaterialKind::Normal, true)
  assert_eq(normal.shading() is @constants.Basic, true)
  assert_eq(normal.color.r, 0.0)
  assert_eq(normal.color.g, 1.0)
  match normal.defines.get("MATCAP") {
    None => ()
    Some(_) => abort("normal gained matcap define")
  }
  let destination = @materials.Material::basic()
  ignore(destination.copy(normal))
  assert_eq(destination.is_mesh_normal_material, false)
  assert_eq(destination.kind is @materials.MaterialKind::Basic, true)
  assert_eq(destination.type_name, "MeshBasicMaterial")
  assert_eq(destination.color.r, 0.0)
  assert_eq(destination.color.g, 1.0)
  assert_eq(normal.is_mesh_normal_material, true)
  let onto = @materials.Material::normal()
  onto.defines.set("FOO", "1")
  let red = @materials.Material::matcap(hex=0xFF0000)
  ignore(onto.copy(red))
  assert_eq(onto.is_mesh_normal_material, true)
  assert_eq(onto.kind is @materials.MaterialKind::Normal, true)
  assert_eq(onto.color.r, 1.0)
  assert_eq(onto.color.g, 0.0)
  match onto.defines.get("FOO") {
    None => abort("normal copy dropped define")
    Some(value) => assert_eq(value, "1")
  }
  match onto.defines.get("MATCAP") {
    None => ()
    Some(_) => abort("normal copy gained matcap define")
  }
  let cloned = normal.clone()
  assert_eq(cloned.is_mesh_normal_material, true)
  assert_eq(cloned.type_name, "MeshNormalMaterial")
  assert_eq(cloned.kind is @materials.MaterialKind::Normal, true)
  assert_eq(cloned.color.g, 1.0)
  assert_eq(cloned.id == normal.id, false)
}

///|
test "Material depth sets isMeshDepthMaterial and keeps defines on copy" {
  let basic = @materials.Material::basic()
  let lambert = @materials.Material::lambert()
  let standard = @materials.Material::standard()
  let physical = @materials.Material::physical()
  let toon = @materials.Material::toon()
  let matcap = @materials.Material::matcap()
  let normal = @materials.Material::normal()
  assert_eq(basic.is_mesh_depth_material, false)
  assert_eq(lambert.is_mesh_depth_material, false)
  assert_eq(standard.is_mesh_depth_material, false)
  assert_eq(physical.is_mesh_depth_material, false)
  assert_eq(toon.is_mesh_depth_material, false)
  assert_eq(matcap.is_mesh_depth_material, false)
  assert_eq(normal.is_mesh_depth_material, false)
  let depth = @materials.Material::depth(hex=0x0000FF)
  assert_eq(depth.is_mesh_depth_material, true)
  assert_eq(depth.is_mesh_normal_material, false)
  assert_eq(depth.type_name, "MeshDepthMaterial")
  assert_eq(depth.kind is @materials.MaterialKind::Depth, true)
  assert_eq(depth.shading() is @constants.Basic, true)
  assert_eq(depth.color.r, 0.0)
  assert_eq(depth.color.b, 1.0)
  match depth.defines.get("MATCAP") {
    None => ()
    Some(_) => abort("depth gained matcap define")
  }
  let destination = @materials.Material::basic()
  ignore(destination.copy(depth))
  assert_eq(destination.is_mesh_depth_material, false)
  assert_eq(destination.kind is @materials.MaterialKind::Basic, true)
  assert_eq(destination.type_name, "MeshBasicMaterial")
  assert_eq(destination.color.r, 0.0)
  assert_eq(destination.color.b, 1.0)
  assert_eq(depth.is_mesh_depth_material, true)
  let onto = @materials.Material::depth()
  onto.defines.set("FOO", "1")
  let green = @materials.Material::normal(hex=0x00FF00)
  ignore(onto.copy(green))
  assert_eq(onto.is_mesh_depth_material, true)
  assert_eq(onto.kind is @materials.MaterialKind::Depth, true)
  assert_eq(onto.color.r, 0.0)
  assert_eq(onto.color.g, 1.0)
  match onto.defines.get("FOO") {
    None => abort("depth copy dropped define")
    Some(value) => assert_eq(value, "1")
  }
  let cloned = depth.clone()
  assert_eq(cloned.is_mesh_depth_material, true)
  assert_eq(cloned.type_name, "MeshDepthMaterial")
  assert_eq(cloned.kind is @materials.MaterialKind::Depth, true)
  assert_eq(cloned.color.b, 1.0)
  assert_eq(cloned.id == depth.id, false)
}

///|
test "Material depthPacking defaults to basic and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.depth_packing.to_int(), 3200)
  assert_eq(basic.depth_packing is @constants.DepthPacking::Basic, true)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.depth_packing.to_int(), @constants.BASIC_DEPTH_PACKING)
  lambert.depth_packing = @constants.DepthPacking::RGBA
  assert_eq(lambert.depth_packing.to_int(), 3201)
  let other = @materials.Material::lambert()
  assert_eq(other.depth_packing.to_int(), 3200)
  let destination = @materials.Material::basic()
  ignore(destination.copy(lambert))
  assert_eq(destination.depth_packing.to_int(), @constants.RGBA_DEPTH_PACKING)
  assert_eq(destination.depth_packing is @constants.DepthPacking::RGBA, true)
  destination.depth_packing = @constants.DepthPacking::Basic
  assert_eq(lambert.depth_packing.to_int(), 3201)
  assert_eq(@constants.DepthPacking::RGB.to_int(), @constants.RGB_DEPTH_PACKING)
  assert_eq(@constants.DepthPacking::RG.to_int(), 3203)
  let standard = @materials.Material::standard()
  assert_eq(standard.depth_packing.to_int(), 3200)
  let physical = @materials.Material::physical()
  assert_eq(physical.depth_packing.to_int(), 3200)
  let toon = @materials.Material::toon()
  assert_eq(toon.depth_packing.to_int(), 3200)
  let matcap = @materials.Material::matcap()
  assert_eq(matcap.depth_packing.to_int(), 3200)
  let normal = @materials.Material::normal()
  assert_eq(normal.depth_packing.to_int(), 3200)
  let depth = @materials.Material::depth()
  assert_eq(depth.depth_packing.to_int(), 3200)
}

///|
test "Material distance sets isMeshDistanceMaterial and keeps defines on copy" {
  let basic = @materials.Material::basic()
  let lambert = @materials.Material::lambert()
  let standard = @materials.Material::standard()
  let physical = @materials.Material::physical()
  let toon = @materials.Material::toon()
  let matcap = @materials.Material::matcap()
  let normal = @materials.Material::normal()
  let depth = @materials.Material::depth()
  assert_eq(basic.is_mesh_distance_material, false)
  assert_eq(lambert.is_mesh_distance_material, false)
  assert_eq(standard.is_mesh_distance_material, false)
  assert_eq(physical.is_mesh_distance_material, false)
  assert_eq(toon.is_mesh_distance_material, false)
  assert_eq(matcap.is_mesh_distance_material, false)
  assert_eq(normal.is_mesh_distance_material, false)
  assert_eq(depth.is_mesh_distance_material, false)
  let distance = @materials.Material::distance(hex=0xFF0000)
  assert_eq(distance.is_mesh_distance_material, true)
  assert_eq(distance.is_mesh_depth_material, false)
  assert_eq(distance.type_name, "MeshDistanceMaterial")
  assert_eq(distance.kind is @materials.MaterialKind::Distance, true)
  assert_eq(distance.shading() is @constants.Basic, true)
  assert_eq(distance.color.r, 1.0)
  assert_eq(distance.color.g, 0.0)
  match distance.defines.get("MATCAP") {
    None => ()
    Some(_) => abort("distance gained matcap define")
  }
  let destination = @materials.Material::basic()
  ignore(destination.copy(distance))
  assert_eq(destination.is_mesh_distance_material, false)
  assert_eq(destination.kind is @materials.MaterialKind::Basic, true)
  assert_eq(destination.type_name, "MeshBasicMaterial")
  assert_eq(destination.color.r, 1.0)
  assert_eq(destination.color.g, 0.0)
  assert_eq(distance.is_mesh_distance_material, true)
  let onto = @materials.Material::distance()
  onto.defines.set("FOO", "1")
  let blue = @materials.Material::depth(hex=0x0000FF)
  ignore(onto.copy(blue))
  assert_eq(onto.is_mesh_distance_material, true)
  assert_eq(onto.kind is @materials.MaterialKind::Distance, true)
  assert_eq(onto.color.r, 0.0)
  assert_eq(onto.color.b, 1.0)
  match onto.defines.get("FOO") {
    None => abort("distance copy dropped define")
    Some(value) => assert_eq(value, "1")
  }
  let cloned = distance.clone()
  assert_eq(cloned.is_mesh_distance_material, true)
  assert_eq(cloned.type_name, "MeshDistanceMaterial")
  assert_eq(cloned.kind is @materials.MaterialKind::Distance, true)
  assert_eq(cloned.color.r, 1.0)
  assert_eq(cloned.id == distance.id, false)
}

///|
test "Material phong sets isMeshPhongMaterial and keeps defines on copy" {
  let basic = @materials.Material::basic()
  let lambert = @materials.Material::lambert()
  let standard = @materials.Material::standard()
  let physical = @materials.Material::physical()
  let toon = @materials.Material::toon()
  let matcap = @materials.Material::matcap()
  let normal = @materials.Material::normal()
  let depth = @materials.Material::depth()
  let distance = @materials.Material::distance()
  assert_eq(basic.is_mesh_phong_material, false)
  assert_eq(lambert.is_mesh_phong_material, false)
  assert_eq(standard.is_mesh_phong_material, false)
  assert_eq(physical.is_mesh_phong_material, false)
  assert_eq(toon.is_mesh_phong_material, false)
  assert_eq(matcap.is_mesh_phong_material, false)
  assert_eq(normal.is_mesh_phong_material, false)
  assert_eq(depth.is_mesh_phong_material, false)
  assert_eq(distance.is_mesh_phong_material, false)
  let phong = @materials.Material::phong(hex=0x00FF00)
  assert_eq(phong.is_mesh_phong_material, true)
  assert_eq(phong.is_mesh_distance_material, false)
  assert_eq(phong.type_name, "MeshPhongMaterial")
  assert_eq(phong.kind is @materials.MaterialKind::Phong, true)
  assert_eq(phong.shading() is @constants.Lambert, true)
  assert_eq(phong.color.r, 0.0)
  assert_eq(phong.color.g, 1.0)
  match phong.defines.get("MATCAP") {
    None => ()
    Some(_) => abort("phong gained matcap define")
  }
  let destination = @materials.Material::basic()
  ignore(destination.copy(phong))
  assert_eq(destination.is_mesh_phong_material, false)
  assert_eq(destination.kind is @materials.MaterialKind::Basic, true)
  assert_eq(destination.type_name, "MeshBasicMaterial")
  assert_eq(destination.color.r, 0.0)
  assert_eq(destination.color.g, 1.0)
  assert_eq(phong.is_mesh_phong_material, true)
  let onto = @materials.Material::phong()
  onto.defines.set("FOO", "1")
  let red = @materials.Material::distance(hex=0xFF0000)
  ignore(onto.copy(red))
  assert_eq(onto.is_mesh_phong_material, true)
  assert_eq(onto.kind is @materials.MaterialKind::Phong, true)
  assert_eq(onto.color.r, 1.0)
  assert_eq(onto.color.g, 0.0)
  match onto.defines.get("FOO") {
    None => abort("phong copy dropped define")
    Some(value) => assert_eq(value, "1")
  }
  let cloned = phong.clone()
  assert_eq(cloned.is_mesh_phong_material, true)
  assert_eq(cloned.type_name, "MeshPhongMaterial")
  assert_eq(cloned.kind is @materials.MaterialKind::Phong, true)
  assert_eq(cloned.color.g, 1.0)
  assert_eq(cloned.id == phong.id, false)
}

///|
test "Material specular starts at 0x111111 and copies into the destination" {
  let basic = @materials.Material::basic()
  assert_eq(basic.specular.get_hex(), 0x111111)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.specular.get_hex(), 0x111111)
  let phong = @materials.Material::phong()
  assert_eq(phong.specular.get_hex(), 0x111111)
  assert_eq(phong.specular_color.get_hex(), 0xFFFFFF)
  ignore(phong.specular.set_rgb(0.25, 0.5, 0.75))
  let other = @materials.Material::phong()
  assert_eq(other.specular.get_hex(), 0x111111)
  let destination = @materials.Material::basic()
  ignore(destination.copy(phong))
  assert_eq(destination.specular.r, 0.25)
  assert_eq(destination.specular.g, 0.5)
  assert_eq(destination.specular.b, 0.75)
  ignore(destination.specular.set_rgb(1.0, 0.0, 0.0))
  assert_eq(phong.specular.r, 0.25)
  assert_eq(phong.specular.g, 0.5)
  assert_eq(phong.specular.b, 0.75)
  let standard = @materials.Material::standard()
  assert_eq(standard.specular.get_hex(), 0x111111)
  let physical = @materials.Material::physical()
  assert_eq(physical.specular.get_hex(), 0x111111)
  let toon = @materials.Material::toon()
  assert_eq(toon.specular.get_hex(), 0x111111)
  let matcap = @materials.Material::matcap()
  assert_eq(matcap.specular.get_hex(), 0x111111)
  let normal = @materials.Material::normal()
  assert_eq(normal.specular.get_hex(), 0x111111)
  let depth = @materials.Material::depth()
  assert_eq(depth.specular.get_hex(), 0x111111)
  let distance = @materials.Material::distance()
  assert_eq(distance.specular.get_hex(), 0x111111)
}

///|
test "Material shininess defaults to 30 and copies" {
  let basic = @materials.Material::basic()
  assert_eq(basic.shininess, 30.0)
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.shininess, 30.0)
  let phong = @materials.Material::phong()
  assert_eq(phong.shininess, 30.0)
  phong.shininess = 80.0
  let other = @materials.Material::phong()
  assert_eq(other.shininess, 30.0)
  let destination = @materials.Material::basic()
  ignore(destination.copy(phong))
  assert_eq(destination.shininess, 80.0)
  destination.shininess = 10.0
  assert_eq(phong.shininess, 80.0)
  let standard = @materials.Material::standard()
  assert_eq(standard.shininess, 30.0)
  let physical = @materials.Material::physical()
  assert_eq(physical.shininess, 30.0)
  let toon = @materials.Material::toon()
  assert_eq(toon.shininess, 30.0)
  let matcap = @materials.Material::matcap()
  assert_eq(matcap.shininess, 30.0)
  let normal = @materials.Material::normal()
  assert_eq(normal.shininess, 30.0)
  let depth = @materials.Material::depth()
  assert_eq(depth.shininess, 30.0)
  let distance = @materials.Material::distance()
  assert_eq(distance.shininess, 30.0)
}

///|
test "Material shadow sets isShadowMaterial and keeps defines on copy" {
  let basic = @materials.Material::basic()
  let lambert = @materials.Material::lambert()
  let standard = @materials.Material::standard()
  let physical = @materials.Material::physical()
  let toon = @materials.Material::toon()
  let matcap = @materials.Material::matcap()
  let normal = @materials.Material::normal()
  let depth = @materials.Material::depth()
  let distance = @materials.Material::distance()
  let phong = @materials.Material::phong()
  assert_eq(basic.is_shadow_material, false)
  assert_eq(basic.transparent, false)
  assert_eq(lambert.is_shadow_material, false)
  assert_eq(standard.is_shadow_material, false)
  assert_eq(physical.is_shadow_material, false)
  assert_eq(toon.is_shadow_material, false)
  assert_eq(matcap.is_shadow_material, false)
  assert_eq(normal.is_shadow_material, false)
  assert_eq(depth.is_shadow_material, false)
  assert_eq(distance.is_shadow_material, false)
  assert_eq(phong.is_shadow_material, false)
  let shadow = @materials.Material::shadow()
  assert_eq(shadow.is_shadow_material, true)
  assert_eq(shadow.is_mesh_phong_material, false)
  assert_eq(shadow.type_name, "ShadowMaterial")
  assert_eq(shadow.kind is @materials.MaterialKind::Shadow, true)
  assert_eq(shadow.shading() is @constants.Basic, true)
  assert_eq(shadow.color.get_hex(), 0x000000)
  assert_eq(shadow.transparent, true)
  assert_eq(shadow.fog, true)
  let destination = @materials.Material::basic()
  ignore(destination.copy(shadow))
  assert_eq(destination.is_shadow_material, false)
  assert_eq(destination.kind is @materials.MaterialKind::Basic, true)
  assert_eq(destination.type_name, "MeshBasicMaterial")
  assert_eq(destination.color.get_hex(), 0x000000)
  assert_eq(destination.transparent, true)
  assert_eq(shadow.is_shadow_material, true)
  let onto = @materials.Material::shadow()
  onto.defines.set("FOO", "1")
  let green = @materials.Material::phong(hex=0x00FF00)
  ignore(onto.copy(green))
  assert_eq(onto.is_shadow_material, true)
  assert_eq(onto.kind is @materials.MaterialKind::Shadow, true)
  assert_eq(onto.color.r, 0.0)
  assert_eq(onto.color.g, 1.0)
  assert_eq(onto.transparent, false)
  match onto.defines.get("FOO") {
    None => abort("shadow copy dropped define")
    Some(value) => assert_eq(value, "1")
  }
  let cloned = shadow.clone()
  assert_eq(cloned.is_shadow_material, true)
  assert_eq(cloned.type_name, "ShadowMaterial")
  assert_eq(cloned.kind is @materials.MaterialKind::Shadow, true)
  assert_eq(cloned.color.get_hex(), 0x000000)
  assert_eq(cloned.transparent, true)
  assert_eq(cloned.id == shadow.id, false)
}

///|
test "Material shader sets isShaderMaterial" {
  let basic = @materials.Material::basic()
  let lambert = @materials.Material::lambert()
  let standard = @materials.Material::standard()
  let physical = @materials.Material::physical()
  let toon = @materials.Material::toon()
  let matcap = @materials.Material::matcap()
  let normal = @materials.Material::normal()
  let depth = @materials.Material::depth()
  let distance = @materials.Material::distance()
  let phong = @materials.Material::phong()
  let shadow = @materials.Material::shadow()
  assert_eq(basic.is_shader_material, false)
  assert_eq(lambert.is_shader_material, false)
  assert_eq(standard.is_shader_material, false)
  assert_eq(physical.is_shader_material, false)
  assert_eq(toon.is_shader_material, false)
  assert_eq(matcap.is_shader_material, false)
  assert_eq(normal.is_shader_material, false)
  assert_eq(depth.is_shader_material, false)
  assert_eq(distance.is_shader_material, false)
  assert_eq(phong.is_shader_material, false)
  assert_eq(shadow.is_shader_material, false)
  let shader = @materials.Material::shader()
  assert_eq(shader.is_shader_material, true)
  assert_eq(shader.is_shadow_material, false)
  assert_eq(shader.type_name, "ShaderMaterial")
  assert_eq(shader.kind is @materials.MaterialKind::Shader, true)
  assert_eq(shader.shading() is @constants.Basic, true)
  assert_eq(shader.color.get_hex(), 0xFFFFFF)
  assert_eq(shader.transparent, false)
  assert_eq(shader.fog, false)
  match shader.defines.get("FOO") {
    None => ()
    Some(_) => abort("shader defines should start empty")
  }
  let destination = @materials.Material::basic()
  ignore(destination.copy(shader))
  assert_eq(destination.is_shader_material, false)
  assert_eq(destination.kind is @materials.MaterialKind::Basic, true)
  assert_eq(destination.type_name, "MeshBasicMaterial")
  assert_eq(shader.is_shader_material, true)
  let onto = @materials.Material::shader()
  onto.defines.set("FOO", "1")
  let green = @materials.Material::phong(hex=0x00FF00)
  ignore(onto.copy(green))
  assert_eq(onto.is_shader_material, true)
  assert_eq(onto.kind is @materials.MaterialKind::Shader, true)
  assert_eq(onto.color.r, 0.0)
  assert_eq(onto.color.g, 1.0)
  match onto.defines.get("FOO") {
    None => ()
    Some(_) => abort("shader copy kept define missing from source")
  }
  let cloned = shader.clone()
  assert_eq(cloned.is_shader_material, true)
  assert_eq(cloned.type_name, "ShaderMaterial")
  assert_eq(cloned.kind is @materials.MaterialKind::Shader, true)
  assert_eq(cloned.color.get_hex(), 0xFFFFFF)
  assert_eq(cloned.id == shader.id, false)
}

///|
test "Material raw sets isRawShaderMaterial" {
  let basic = @materials.Material::basic()
  let shader = @materials.Material::shader()
  let raw = @materials.Material::raw()
  assert_eq(basic.is_raw_shader_material, false)
  assert_eq(basic.is_shader_material, false)
  assert_eq(shader.is_raw_shader_material, false)
  assert_eq(shader.is_shader_material, true)
  assert_eq(shader.type_name, "ShaderMaterial")
  assert_eq(raw.is_shader_material, true)
  assert_eq(raw.is_raw_shader_material, true)
  assert_eq(raw.type_name, "RawShaderMaterial")
  assert_eq(raw.kind is @materials.MaterialKind::Raw, true)
  assert_eq(raw.shading() is @constants.Basic, true)
  assert_eq(raw.linewidth, 1.0)
  assert_eq(raw.fog, false)
  assert_eq(raw.lights, false)
  raw.lights = true
  raw.defines.set("FOO", "1")
  let onto_basic = @materials.Material::basic()
  ignore(onto_basic.copy(raw))
  assert_eq(onto_basic.is_raw_shader_material, false)
  assert_eq(onto_basic.lights, false)
  let onto_shader = @materials.Material::shader()
  ignore(onto_shader.copy(raw))
  assert_eq(onto_shader.is_raw_shader_material, false)
  assert_eq(onto_shader.is_shader_material, true)
  assert_eq(onto_shader.kind is @materials.MaterialKind::Shader, true)
  assert_eq(onto_shader.type_name, "ShaderMaterial")
  assert_eq(onto_shader.lights, true)
  match onto_shader.defines.get("FOO") {
    None => abort("raw copy onto shader dropped FOO")
    Some(value) => assert_eq(value, "1")
  }
  let onto_raw = @materials.Material::raw()
  onto_raw.lights = true
  onto_raw.defines.set("KEEP", "9")
  let green = @materials.Material::shader(hex=0x00FF00)
  green.lights = false
  ignore(onto_raw.copy(green))
  assert_eq(onto_raw.is_raw_shader_material, true)
  assert_eq(onto_raw.is_shader_material, true)
  assert_eq(onto_raw.kind is @materials.MaterialKind::Raw, true)
  assert_eq(onto_raw.type_name, "RawShaderMaterial")
  assert_eq(onto_raw.lights, false)
  assert_eq(onto_raw.color.g, 1.0)
  match onto_raw.defines.get("KEEP") {
    None => ()
    Some(_) => abort("raw copy kept define missing from source")
  }
  let cloned = raw.clone()
  assert_eq(cloned.is_raw_shader_material, true)
  assert_eq(cloned.is_shader_material, true)
  assert_eq(cloned.type_name, "RawShaderMaterial")
  assert_eq(cloned.kind is @materials.MaterialKind::Raw, true)
  assert_eq(cloned.lights, true)
  assert_eq(cloned.id == raw.id, false)
  match cloned.defines.get("FOO") {
    None => abort("raw clone dropped FOO")
    Some(value) => assert_eq(value, "1")
  }
}

///|
test "Material shader prefixes vertex uniforms" {
  let shader = @materials.Material::shader()
  let raw = @materials.Material::raw()
  let basic = @materials.Material::basic()
  let prefixed = shader.prefixed_vertex_shader()
  assert_eq(prefixed.length() - shader.vertex_shader.length(), 1516)
  assert_eq(prefixed.length(), 1608)
  assert_eq(prefixed[0:15].to_owned(), "#version 300 es")
  assert_eq(prefixed[17:37].to_owned(), "#define attribute in")
  assert_eq(prefixed[38:57].to_owned(), "#define varying out")
  assert_eq(prefixed[58:83].to_owned(), "#define texture2D texture")
  assert_eq(prefixed[84:106].to_owned(), "precision highp float;")
  assert_eq(prefixed[605:627].to_owned(), "#define HIGH_PRECISION")
  assert_eq(prefixed[627:661].to_owned(), "#define SHADER_TYPE ShaderMaterial")
  assert_eq(prefixed[662:682].to_owned(), "#define SHADER_NAME ")
  assert_eq(prefixed[683:708].to_owned(), "uniform mat4 modelMatrix;")
  assert_eq(
    prefixed[1075:1099].to_owned(),
    "attribute vec3 position;",
  )
  assert_eq(
    prefixed[prefixed.length() - 92:prefixed.length()].to_owned(),
    shader.vertex_shader,
  )
  assert_eq(raw.vertex_shader.length(), 92)
  assert_eq(raw.prefixed_vertex_shader(), raw.vertex_shader)
  assert_eq(raw.prefixed_vertex_shader()[0:7].to_owned(), "\nvoid m")
  assert_eq(basic.prefixed_vertex_shader(), "")
  shader.vertex_shader = "void main() {}"
  let custom = shader.prefixed_vertex_shader()
  assert_eq(custom.length(), 1530)
  assert_eq(custom[custom.length() - 14:custom.length()].to_owned(), "void main() {}")
  raw.vertex_shader = "void main() {}"
  assert_eq(raw.prefixed_vertex_shader(), "void main() {}")
  assert_eq(raw.prefixed_vertex_shader().length(), 14)
}

///|
test "Material shader adds vertex GLSL3 defines" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.extensions.clip_cull_distance = true
  let clip = shader.prefixed_vertex_shader()
  assert_eq(clip.length(), 1656)
  assert_eq(
    clip[16:64].to_owned(),
    "#extension GL_ANGLE_clip_cull_distance : require",
  )
  shader.extensions.clip_cull_distance = false
  shader.extensions.multi_draw = true
  let multi = shader.prefixed_vertex_shader()
  assert_eq(multi.length(), 1648)
  assert_eq(
    multi[16:56].to_owned(),
    "#extension GL_ANGLE_multi_draw : require",
  )
  shader.extensions.clip_cull_distance = true
  let both = shader.prefixed_vertex_shader()
  assert_eq(both.length(), 1697)
  assert_eq(1697 - 1608, 89)
  let raw = @materials.Material::raw()
  raw.extensions.clip_cull_distance = true
  raw.extensions.multi_draw = true
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
}

///|
test "Material shader writes precision prefix" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 1222)
  shader.precision = Some(@constants.Precision::Mediump)
  assert_eq(shader.prefixed_vertex_shader().length(), 1644)
  assert_eq(shader.prefixed_fragment_shader().length(), 1258)
  assert_eq(1644 - 1608, 36)
  assert_eq(
    shader.prefixed_vertex_shader()[84:108].to_owned(),
    "precision mediump float;",
  )
  shader.precision = Some(@constants.Precision::Lowp)
  assert_eq(shader.prefixed_vertex_shader().length(), 1590)
  assert_eq(shader.prefixed_fragment_shader().length(), 1204)
  assert_eq(1608 - 1590, 18)
  assert_eq(
    shader.prefixed_vertex_shader()[84:105].to_owned(),
    "precision lowp float;",
  )
  let raw = @materials.Material::raw()
  raw.precision = Some(@constants.Precision::Lowp)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
}

///|
test "Material shader writes SHADER_NAME" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 1222)
  shader.name = "Cube"
  assert_eq(shader.prefixed_vertex_shader().length(), 1612)
  assert_eq(shader.prefixed_fragment_shader().length(), 1226)
  assert_eq(1612 - 1608, 4)
  assert_eq(
    shader.prefixed_vertex_shader()[662:686].to_owned(),
    "#define SHADER_NAME Cube",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1058:1082].to_owned(),
    "#define SHADER_NAME Cube",
  )
  let raw = @materials.Material::raw()
  raw.name = "Cube"
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
}

///|
test "Material shader writes custom defines" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 1222)
  shader.defines.set("FOO", "1")
  assert_eq(shader.prefixed_vertex_shader().length(), 1622)
  assert_eq(shader.prefixed_fragment_shader().length(), 1236)
  assert_eq(1622 - 1608, 14)
  assert_eq(
    shader.prefixed_vertex_shader()[683:696].to_owned(),
    "#define FOO 1",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1092].to_owned(),
    "#define FOO 1",
  )
  let raw = @materials.Material::raw()
  raw.defines.set("FOO", "1")
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  let basic = @materials.Material::basic()
  basic.defines.set("FOO", "1")
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_MAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1624)
  assert_eq(shader.prefixed_fragment_shader().length(), 1238)
  assert_eq(1624 - 1608, 16)
  assert_eq(
    shader.prefixed_vertex_shader()[683:698].to_owned(),
    "#define USE_MAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1094].to_owned(),
    "#define USE_MAP",
  )
  shader.defines.set("FOO", "1")
  assert_eq(shader.prefixed_vertex_shader().length(), 1638)
  assert_eq(1638 - 1624, 14)
  assert_eq(
    shader.prefixed_vertex_shader()[697:712].to_owned(),
    "#define USE_MAP",
  )
  let raw = @materials.Material::raw()
  raw.map = Some(map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.map = Some(map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_ENVMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let env_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.env_map = Some(env_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1658)
  assert_eq(shader.prefixed_fragment_shader().length(), 1330)
  assert_eq(1658 - 1608, 50)
  assert_eq(
    shader.prefixed_vertex_shader()[683:701].to_owned(),
    "#define USE_ENVMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1097].to_owned(),
    "#define USE_ENVMAP",
  )
  shader.map = Some(env_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1674)
  assert_eq(1674 - 1658, 16)
  assert_eq(
    shader.prefixed_vertex_shader()[699:717].to_owned(),
    "#define USE_ENVMAP",
  )
  let raw = @materials.Material::raw()
  raw.env_map = Some(env_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.env_map = Some(env_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes ENVMAP_MODE" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let env_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.env_map = Some(env_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1658)
  assert_eq(shader.prefixed_fragment_shader().length(), 1330)
  assert_eq(1658 - 1627, 31)
  assert_eq(
    shader.prefixed_vertex_shader()[702:732].to_owned(),
    "#define ENVMAP_MODE_REFLECTION",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1123:1153].to_owned(),
    "#define ENVMAP_MODE_REFLECTION",
  )
  shader.map = Some(env_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1674)
  assert_eq(
    shader.prefixed_vertex_shader()[718:748].to_owned(),
    "#define ENVMAP_MODE_REFLECTION",
  )
  let raw = @materials.Material::raw()
  raw.env_map = Some(env_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.env_map = Some(env_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes ENVMAP_TYPE" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let env_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.env_map = Some(env_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1658)
  assert_eq(shader.prefixed_fragment_shader().length(), 1330)
  assert_eq(1297 - 1272, 25)
  assert_eq(
    shader.prefixed_fragment_shader()[1098:1122].to_owned(),
    "#define ENVMAP_TYPE_CUBE",
  )
  assert_eq(
    shader.prefixed_vertex_shader()[702:732].to_owned(),
    "#define ENVMAP_MODE_REFLECTION",
  )
  let raw = @materials.Material::raw()
  raw.env_map = Some(env_map)
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  let basic = @materials.Material::basic()
  basic.env_map = Some(env_map)
  assert_eq(basic.prefixed_fragment_shader(), "")
}

///|
test "Material shader writes ENVMAP_BLENDING" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let env_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.env_map = Some(env_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1658)
  assert_eq(shader.prefixed_fragment_shader().length(), 1330)
  assert_eq(1330 - 1297, 33)
  assert_eq(
    shader.prefixed_fragment_shader()[1154:1186].to_owned(),
    "#define ENVMAP_BLENDING_MULTIPLY",
  )
  shader.combine = @constants.Combine::Mix
  assert_eq(shader.prefixed_fragment_shader().length(), 1325)
  assert_eq(1325 - 1297, 28)
  assert_eq(
    shader.prefixed_fragment_shader()[1154:1181].to_owned(),
    "#define ENVMAP_BLENDING_MIX",
  )
  shader.combine = @constants.Combine::Add
  assert_eq(shader.prefixed_fragment_shader().length(), 1325)
  assert_eq(
    shader.prefixed_fragment_shader()[1154:1181].to_owned(),
    "#define ENVMAP_BLENDING_ADD",
  )
  let bare = @materials.Material::shader()
  bare.combine = @constants.Combine::Mix
  assert_eq(bare.prefixed_fragment_shader().length(), 1222)
  let raw = @materials.Material::raw()
  raw.env_map = Some(env_map)
  raw.combine = @constants.Combine::Add
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  let basic = @materials.Material::basic()
  basic.env_map = Some(env_map)
  basic.combine = @constants.Combine::Add
  assert_eq(basic.prefixed_fragment_shader(), "")
}

///|
test "Material shader prefixes fragment uniforms" {
  let shader = @materials.Material::shader()
  let raw = @materials.Material::raw()
  let basic = @materials.Material::basic()
  let prefixed = shader.prefixed_fragment_shader()
  assert_eq(prefixed.length() - shader.fragment_shader.length(), 1161)
  assert_eq(prefixed.length(), 1222)
  assert_eq(prefixed[0:15].to_owned(), "#version 300 es")
  assert_eq(prefixed[16:34].to_owned(), "#define varying in")
  assert_eq(prefixed[480:502].to_owned(), "precision highp float;")
  assert_eq(prefixed[1023:1057].to_owned(), "#define SHADER_TYPE ShaderMaterial")
  assert_eq(prefixed[1058:1078].to_owned(), "#define SHADER_NAME ")
  assert_eq(prefixed[1079:1103].to_owned(), "uniform mat4 viewMatrix;")
  assert_eq(prefixed[1133:1161].to_owned(), "uniform bool isOrthographic;")
  assert_eq(
    prefixed[prefixed.length() - 61:prefixed.length()].to_owned(),
    shader.fragment_shader,
  )
  assert_eq(raw.fragment_shader.length(), 61)
  assert_eq(raw.prefixed_fragment_shader(), raw.fragment_shader)
  assert_eq(basic.prefixed_fragment_shader(), "")
  shader.fragment_shader = "void main() {}"
  let custom = shader.prefixed_fragment_shader()
  assert_eq(custom.length(), 1175)
  assert_eq(custom[custom.length() - 14:custom.length()].to_owned(), "void main() {}")
  raw.fragment_shader = "void main() {}"
  assert_eq(raw.prefixed_fragment_shader(), "void main() {}")
  assert_eq(raw.prefixed_fragment_shader().length(), 14)
}

///|
test "Material shader adds GLSL3 fragment defines" {
  let shader = @materials.Material::shader()
  let prefixed = shader.prefixed_fragment_shader()
  assert_eq(prefixed.length(), 1222)
  assert_eq(prefixed[0:15].to_owned(), "#version 300 es")
  assert_eq(
    prefixed[35:84].to_owned(),
    "layout(location = 0) out highp vec4 pc_fragColor;",
  )
  assert_eq(prefixed[85:118].to_owned(), "#define gl_FragColor pc_fragColor")
  shader.glsl_version = Some(@materials.GlslVersion::GLSL1)
  assert_eq(shader.prefixed_fragment_shader().length(), 1222)
  shader.glsl_version = Some(@materials.GlslVersion::GLSL3)
  let g3 = shader.prefixed_fragment_shader()
  assert_eq(g3.length(), 1140)
  assert_eq(1222 - g3.length(), 82)
  assert_eq(g3[0:15].to_owned(), "#version 300 es")
  assert_eq(g3[34:37].to_owned(), "\n\n\n")
  assert_eq(g3[37:73].to_owned(), "#define gl_FragDepthEXT gl_FragDepth")
  let raw = @materials.Material::raw()
  raw.glsl_version = Some(@materials.GlslVersion::GLSL3)
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  let basic = @materials.Material::basic()
  basic.glsl_version = Some(@materials.GlslVersion::GLSL3)
  assert_eq(basic.prefixed_fragment_shader(), "")
}

///|
test "Material shader copies defines" {
  let source = @materials.Material::shader()
  source.defines.set("FOO", "1")
  source.defines.set("BAR", "2")
  let onto = @materials.Material::shader()
  onto.defines.set("FOO", "9")
  onto.defines.set("BAZ", "3")
  ignore(onto.copy(source))
  match onto.defines.get("FOO") {
    None => abort("shader copy dropped FOO")
    Some(value) => assert_eq(value, "1")
  }
  match onto.defines.get("BAR") {
    None => abort("shader copy dropped BAR")
    Some(value) => assert_eq(value, "2")
  }
  match onto.defines.get("BAZ") {
    None => ()
    Some(_) => abort("shader copy kept destination define")
  }
  onto.defines.set("FOO", "7")
  match source.defines.get("FOO") {
    None => abort("source lost FOO")
    Some(value) => assert_eq(value, "1")
  }
  let basic = @materials.Material::basic()
  basic.defines.set("KEEP", "4")
  ignore(basic.copy(source))
  match basic.defines.get("FOO") {
    None => ()
    Some(_) => abort("basic copy gained shader define")
  }
  match basic.defines.get("KEEP") {
    None => abort("basic copy dropped define")
    Some(value) => assert_eq(value, "4")
  }
  let cleared = @materials.Material::shader()
  cleared.defines.set("FOO", "1")
  ignore(cleared.copy(@materials.Material::phong()))
  match cleared.defines.get("FOO") {
    None => ()
    Some(_) => abort("shader copy kept define missing from source")
  }
  let cloned = source.clone()
  match cloned.defines.get("FOO") {
    None => abort("clone dropped FOO")
    Some(value) => assert_eq(value, "1")
  }
  match cloned.defines.get("BAR") {
    None => abort("clone dropped BAR")
    Some(value) => assert_eq(value, "2")
  }
  cloned.defines.set("FOO", "8")
  match source.defines.get("FOO") {
    None => abort("clone wrote source")
    Some(value) => assert_eq(value, "1")
  }
}

///|
test "Material shader defaults fog off" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  assert_eq(shader.fog, false)
  assert_eq(basic.fog, true)
  ignore(basic.copy(shader))
  assert_eq(basic.fog, false)
  assert_eq(shader.fog, false)
  let onto = @materials.Material::shader()
  let phong = @materials.Material::phong()
  assert_eq(phong.fog, true)
  ignore(onto.copy(phong))
  assert_eq(onto.fog, true)
  onto.fog = false
  assert_eq(phong.fog, true)
  let cloned = shader.clone()
  assert_eq(cloned.fog, false)
  assert_eq(cloned.id == shader.id, false)
}

///|
test "Material shader defaults lights off and copies only onto shader" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  assert_eq(shader.lights, false)
  assert_eq(basic.lights, false)
  assert_eq(phong.lights, false)
  shader.lights = true
  ignore(basic.copy(shader))
  assert_eq(basic.lights, false)
  assert_eq(shader.lights, true)
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  assert_eq(onto.lights, true)
  onto.lights = false
  assert_eq(shader.lights, true)
  ignore(onto.copy(phong))
  assert_eq(onto.lights, false)
  assert_eq(phong.lights, false)
  let cloned = shader.clone()
  assert_eq(cloned.lights, true)
  assert_eq(cloned.id == shader.id, false)
  cloned.lights = false
  assert_eq(shader.lights, true)
}

///|
test "Material shader defaults clipping off and copies only onto shader" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  assert_eq(shader.clipping, false)
  assert_eq(basic.clipping, false)
  assert_eq(phong.clipping, false)
  shader.clipping = true
  ignore(basic.copy(shader))
  assert_eq(basic.clipping, false)
  assert_eq(shader.clipping, true)
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  assert_eq(onto.clipping, true)
  onto.clipping = false
  assert_eq(shader.clipping, true)
  ignore(onto.copy(phong))
  assert_eq(onto.clipping, false)
  assert_eq(phong.clipping, false)
  let cloned = shader.clone()
  assert_eq(cloned.clipping, true)
  assert_eq(cloned.id == shader.id, false)
  cloned.clipping = false
  assert_eq(shader.clipping, true)
}

///|
test "Material shader stores the default vertex shader" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  let expected =
    "\nvoid main() {\n\tgl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );\n}\n"
  assert_eq(shader.vertex_shader, expected)
  assert_eq(basic.vertex_shader, "")
  assert_eq(phong.vertex_shader, "")
  shader.vertex_shader = "void main() {}"
  ignore(basic.copy(shader))
  assert_eq(basic.vertex_shader, "")
  assert_eq(shader.vertex_shader, "void main() {}")
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  assert_eq(onto.vertex_shader, "void main() {}")
  onto.vertex_shader = "changed"
  assert_eq(shader.vertex_shader, "void main() {}")
  ignore(onto.copy(phong))
  assert_eq(onto.vertex_shader, "")
  assert_eq(phong.vertex_shader, "")
  let cloned = shader.clone()
  assert_eq(cloned.vertex_shader, "void main() {}")
  assert_eq(cloned.id == shader.id, false)
  cloned.vertex_shader = "clone"
  assert_eq(shader.vertex_shader, "void main() {}")
}

///|
test "Material shader stores the default fragment shader" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  let expected =
    "\nvoid main() {\n\tgl_FragColor = vec4( 1.0, 0.0, 0.0, 1.0 );\n}\n"
  assert_eq(shader.fragment_shader, expected)
  assert_eq(basic.fragment_shader, "")
  assert_eq(phong.fragment_shader, "")
  shader.fragment_shader = "void main() {}"
  ignore(basic.copy(shader))
  assert_eq(basic.fragment_shader, "")
  assert_eq(shader.fragment_shader, "void main() {}")
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  assert_eq(onto.fragment_shader, "void main() {}")
  onto.fragment_shader = "changed"
  assert_eq(shader.fragment_shader, "void main() {}")
  ignore(onto.copy(phong))
  assert_eq(onto.fragment_shader, "")
  assert_eq(phong.fragment_shader, "")
  let cloned = shader.clone()
  assert_eq(cloned.fragment_shader, "void main() {}")
  assert_eq(cloned.id == shader.id, false)
  cloned.fragment_shader = "clone"
  assert_eq(shader.fragment_shader, "void main() {}")
}

///|
test "Material shader copies numeric uniforms" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  match shader.uniforms.get("time") {
    None => ()
    Some(_) => abort("shader uniforms should start empty")
  }
  match basic.uniforms.get("time") {
    None => ()
    Some(_) => abort("basic uniforms should start empty")
  }
  match phong.uniforms.get("time") {
    None => ()
    Some(_) => abort("phong uniforms should start empty")
  }
  shader.uniforms.set("time", 1.0)
  shader.uniforms.set("scale", 2.0)
  ignore(basic.copy(shader))
  match basic.uniforms.get("time") {
    None => ()
    Some(_) => abort("basic copy gained shader uniform")
  }
  assert_eq(shader.uniforms.get("time"), Some(1.0))
  let onto = @materials.Material::shader()
  onto.uniforms.set("time", 9.0)
  onto.uniforms.set("extra", 3.0)
  ignore(onto.copy(shader))
  assert_eq(onto.uniforms.get("time"), Some(1.0))
  assert_eq(onto.uniforms.get("scale"), Some(2.0))
  match onto.uniforms.get("extra") {
    None => ()
    Some(_) => abort("shader copy kept destination uniform")
  }
  onto.uniforms.set("time", 7.0)
  assert_eq(shader.uniforms.get("time"), Some(1.0))
  ignore(onto.copy(phong))
  match onto.uniforms.get("time") {
    None => ()
    Some(_) => abort("shader copy kept uniform missing from source")
  }
  let cloned = shader.clone()
  assert_eq(cloned.uniforms.get("time"), Some(1.0))
  assert_eq(cloned.uniforms.get("scale"), Some(2.0))
  assert_eq(cloned.id == shader.id, false)
  cloned.uniforms.set("time", 8.0)
  assert_eq(shader.uniforms.get("time"), Some(1.0))
}

///|
test "Material shader copies uniforms groups" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  assert_eq(shader.uniforms_groups.length(), 0)
  assert_eq(basic.uniforms_groups.length(), 0)
  assert_eq(phong.uniforms_groups.length(), 0)
  let frame = @materials.UniformsGroup::new(name="Frame")
  assert_eq(frame.name, "Frame")
  assert_eq(frame.usage, 35044)
  shader.uniforms_groups.push(frame)
  let other = @materials.UniformsGroup::new(name="Other")
  other.usage = 35048
  shader.uniforms_groups.push(other)
  ignore(basic.copy(shader))
  assert_eq(basic.uniforms_groups.length(), 0)
  assert_eq(shader.uniforms_groups[0].name, "Frame")
  let onto = @materials.Material::shader()
  onto.uniforms_groups.push(@materials.UniformsGroup::new(name="Drop"))
  ignore(onto.copy(shader))
  assert_eq(onto.uniforms_groups.length(), 2)
  assert_eq(onto.uniforms_groups[0].name, "Frame")
  assert_eq(onto.uniforms_groups[0].usage, 35044)
  assert_eq(onto.uniforms_groups[0].id == shader.uniforms_groups[0].id, false)
  assert_eq(onto.uniforms_groups[1].name, "Other")
  assert_eq(onto.uniforms_groups[1].usage, 35048)
  onto.uniforms_groups[0].name = "Renamed"
  assert_eq(onto.uniforms_groups[0].name, "Renamed")
  assert_eq(shader.uniforms_groups[0].name, "Frame")
  ignore(onto.copy(phong))
  assert_eq(onto.uniforms_groups.length(), 0)
  let cloned = shader.clone()
  assert_eq(cloned.uniforms_groups.length(), 2)
  assert_eq(cloned.uniforms_groups[0].name, "Frame")
  assert_eq(cloned.uniforms_groups[1].usage, 35048)
  assert_eq(cloned.uniforms_groups[0].id == shader.uniforms_groups[0].id, false)
  cloned.uniforms_groups[0].name = "Clone"
  assert_eq(cloned.uniforms_groups[0].name, "Clone")
  assert_eq(shader.uniforms_groups[0].name, "Frame")
}

///|
test "UniformsGroup copies numeric uniforms" {
  let frame = @materials.UniformsGroup::new(name="Frame")
  assert_eq(frame.uniforms.length(), 0)
  frame.uniforms.push(1.0)
  frame.uniforms.push(2.0)
  let shader = @materials.Material::shader()
  shader.uniforms_groups.push(frame)
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  assert_eq(onto.uniforms_groups[0].uniforms, [1.0, 2.0])
  assert_eq(onto.uniforms_groups[0].id == shader.uniforms_groups[0].id, false)
  onto.uniforms_groups[0].uniforms[0] = 9.0
  assert_eq(onto.uniforms_groups[0].uniforms[0], 9.0)
  assert_eq(shader.uniforms_groups[0].uniforms[0], 1.0)
  let cloned = shader.clone()
  assert_eq(cloned.uniforms_groups[0].uniforms, [1.0, 2.0])
  cloned.uniforms_groups[0].uniforms[0] = 8.0
  assert_eq(shader.uniforms_groups[0].uniforms[0], 1.0)
}

///|
test "UniformsGroup add appends a number" {
  let frame = @materials.UniformsGroup::new(name="Frame")
  let chained = frame.add(1.0).add(2.0)
  assert_eq(frame.uniforms, [1.0, 2.0])
  assert_eq(chained.uniforms, [1.0, 2.0])
  assert_eq(chained.id, frame.id)
  let shader = @materials.Material::shader()
  shader.uniforms_groups.push(frame)
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  ignore(shader.uniforms_groups[0].add(4.0))
  assert_eq(shader.uniforms_groups[0].uniforms, [1.0, 2.0, 4.0])
  assert_eq(onto.uniforms_groups[0].uniforms, [1.0, 2.0])
}

///|
test "UniformsGroup remove drops the first matching number" {
  let frame = @materials.UniformsGroup::new(name="Frame")
  ignore(frame.add(1.0).add(2.0).add(1.0))
  let chained = frame.remove(1.0)
  assert_eq(frame.uniforms, [2.0, 1.0])
  assert_eq(chained.uniforms, [2.0, 1.0])
  assert_eq(chained.id, frame.id)
  ignore(frame.remove(9.0))
  assert_eq(frame.uniforms, [2.0, 1.0])
  let shader = @materials.Material::shader()
  shader.uniforms_groups.push(frame)
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  ignore(shader.uniforms_groups[0].remove(2.0))
  assert_eq(shader.uniforms_groups[0].uniforms, [1.0])
  assert_eq(onto.uniforms_groups[0].uniforms, [2.0, 1.0])
}

///|
test "UniformsGroup setName replaces the name" {
  let frame = @materials.UniformsGroup::new()
  assert_eq(frame.name, "")
  let chained = frame.set_name("Frame").set_name("Lights")
  assert_eq(frame.name, "Lights")
  assert_eq(chained.name, "Lights")
  assert_eq(chained.id, frame.id)
  let shader = @materials.Material::shader()
  shader.uniforms_groups.push(frame)
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  ignore(shader.uniforms_groups[0].set_name("Renamed"))
  assert_eq(shader.uniforms_groups[0].name, "Renamed")
  assert_eq(onto.uniforms_groups[0].name, "Lights")
}

///|
test "UniformsGroup setUsage replaces the usage" {
  let frame = @materials.UniformsGroup::new(name="Frame")
  assert_eq(frame.usage, 35044)
  let chained = frame.set_usage(35048)
  assert_eq(frame.usage, 35048)
  assert_eq(chained.usage, 35048)
  assert_eq(chained.id, frame.id)
  let shader = @materials.Material::shader()
  shader.uniforms_groups.push(frame)
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  ignore(shader.uniforms_groups[0].set_usage(35044))
  assert_eq(shader.uniforms_groups[0].usage, 35044)
  assert_eq(onto.uniforms_groups[0].usage, 35048)
}

///|
test "UniformsGroup dispose runs dispose listeners" {
  let frame = @materials.UniformsGroup::new(name="Frame")
  let hits = Ref::Ref(0)
  let listener = fn() { hits.val = hits.val + 1 }
  frame.add_event_listener("dispose", listener)
  frame.add_event_listener("dispose", listener)
  frame.add_event_listener("change", fn() { hits.val = hits.val + 10 })
  frame.dispose()
  assert_eq(hits.val, 1)
  frame.dispose()
  assert_eq(hits.val, 2)
  let shader = @materials.Material::shader()
  shader.uniforms_groups.push(frame)
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  onto.uniforms_groups[0].dispose()
  assert_eq(hits.val, 2)
  shader.uniforms_groups[0].dispose()
  assert_eq(hits.val, 3)
}

///|
test "UniformsGroup hasEventListener checks one function" {
  let frame = @materials.UniformsGroup::new(name="Frame")
  let listener = fn() {}
  let other = fn() {}
  assert_eq(frame.has_event_listener("dispose", listener), false)
  frame.add_event_listener("dispose", listener)
  assert_eq(frame.has_event_listener("dispose", listener), true)
  assert_eq(frame.has_event_listener("dispose", other), false)
  assert_eq(frame.has_event_listener("change", listener), false)
  let fresh = @materials.UniformsGroup::new(name="Other")
  assert_eq(fresh.has_event_listener("dispose", listener), false)
  let shader = @materials.Material::shader()
  shader.uniforms_groups.push(frame)
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  assert_eq(onto.uniforms_groups[0].has_event_listener("dispose", listener), false)
  assert_eq(shader.uniforms_groups[0].has_event_listener("dispose", listener), true)
}

///|
test "UniformsGroup removeEventListener drops one function" {
  let frame = @materials.UniformsGroup::new(name="Frame")
  let hits = Ref::Ref(0)
  let listener = fn() { hits.val = hits.val + 1 }
  let other = fn() {}
  frame.add_event_listener("dispose", listener)
  frame.remove_event_listener("dispose", listener)
  assert_eq(frame.has_event_listener("dispose", listener), false)
  frame.dispose()
  assert_eq(hits.val, 0)
  frame.add_event_listener("dispose", listener)
  frame.remove_event_listener("change", listener)
  frame.remove_event_listener("dispose", other)
  frame.dispose()
  assert_eq(hits.val, 1)
  frame.remove_event_listener("dispose", listener)
  frame.dispose()
  assert_eq(hits.val, 1)
}

///|
test "UniformsGroup dispatchEvent runs listeners of one kind" {
  let frame = @materials.UniformsGroup::new(name="Frame")
  let hits = Ref::Ref(0)
  frame.add_event_listener("change", fn() { hits.val = hits.val + 1 })
  frame.add_event_listener("dispose", fn() { hits.val = hits.val + 10 })
  frame.dispatch_event("change")
  assert_eq(hits.val, 1)
  frame.dispatch_event("missing")
  assert_eq(hits.val, 1)
  frame.dispatch_event("dispose")
  assert_eq(hits.val, 11)
  let other = @materials.UniformsGroup::new(name="Other")
  other.dispatch_event("change")
  assert_eq(hits.val, 11)
}

///|
test "UniformsGroup clone keeps values and drops listeners" {
  let frame = @materials.UniformsGroup::new(name="Frame")
  ignore(frame.set_usage(35048))
  ignore(frame.add(1.0).add(2.0))
  let listener = fn() {}
  frame.add_event_listener("dispose", listener)
  let cloned = frame.clone()
  assert_eq(cloned.name, "Frame")
  assert_eq(cloned.usage, 35048)
  assert_eq(cloned.uniforms, [1.0, 2.0])
  assert_eq(cloned.id == frame.id, false)
  assert_eq(cloned.has_event_listener("dispose", listener), false)
  assert_eq(frame.has_event_listener("dispose", listener), true)
  cloned.uniforms[0] = 9.0
  cloned.name = "Other"
  assert_eq(frame.uniforms[0], 1.0)
  assert_eq(frame.name, "Frame")
}

///|
test "UniformsGroup copy keeps id and listeners" {
  let frame = @materials.UniformsGroup::new(name="Frame")
  ignore(frame.set_usage(35048))
  ignore(frame.add(1.0).add(2.0))
  let source_listener = fn() {}
  frame.add_event_listener("dispose", source_listener)
  let onto = @materials.UniformsGroup::new(name="Other")
  ignore(onto.add(9.0))
  let kept = onto.uniforms
  let dest_listener = fn() {}
  onto.add_event_listener("change", dest_listener)
  let id = onto.id
  ignore(onto.copy(frame))
  assert_eq(onto.name, "Frame")
  assert_eq(onto.usage, 35048)
  assert_eq(onto.uniforms, [1.0, 2.0])
  assert_eq(kept, [1.0, 2.0])
  assert_eq(onto.id, id)
  assert_eq(onto.has_event_listener("change", dest_listener), true)
  assert_eq(onto.has_event_listener("dispose", source_listener), false)
  onto.uniforms[0] = 8.0
  onto.name = "Renamed"
  assert_eq(frame.uniforms[0], 1.0)
  assert_eq(frame.name, "Frame")
}

///|
test "Material shader keeps its own linewidth on copy" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  assert_eq(shader.linewidth, 1.0)
  assert_eq(basic.linewidth, 1.0)
  assert_eq(phong.linewidth, 1.0)
  assert_eq(shader.wireframe_linewidth, 1.0)
  shader.linewidth = 4.0
  shader.wireframe_linewidth = 5.0
  ignore(basic.copy(shader))
  assert_eq(basic.linewidth, 1.0)
  assert_eq(basic.wireframe_linewidth, 5.0)
  assert_eq(shader.linewidth, 4.0)
  let onto = @materials.Material::shader()
  onto.linewidth = 3.0
  ignore(onto.copy(shader))
  assert_eq(onto.linewidth, 3.0)
  assert_eq(shader.linewidth, 4.0)
  let cloned = shader.clone()
  assert_eq(cloned.linewidth, 1.0)
  assert_eq(cloned.id == shader.id, false)
  assert_eq(shader.linewidth, 4.0)
}

///|
test "Material shader defaults forceSinglePass on" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  assert_eq(shader.force_single_pass, true)
  assert_eq(basic.force_single_pass, false)
  assert_eq(phong.force_single_pass, false)
  ignore(basic.copy(shader))
  assert_eq(basic.force_single_pass, true)
  assert_eq(shader.force_single_pass, true)
  basic.force_single_pass = false
  assert_eq(shader.force_single_pass, true)
  let onto = @materials.Material::shader()
  ignore(onto.copy(phong))
  assert_eq(onto.force_single_pass, false)
  assert_eq(phong.force_single_pass, false)
  let cloned = shader.clone()
  assert_eq(cloned.force_single_pass, true)
  assert_eq(cloned.id == shader.id, false)
}

///|
test "Material shader copies extensions only onto shader" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  assert_eq(shader.extensions.clip_cull_distance, false)
  assert_eq(shader.extensions.multi_draw, false)
  assert_eq(basic.extensions.clip_cull_distance, false)
  assert_eq(basic.extensions.multi_draw, false)
  assert_eq(phong.extensions.clip_cull_distance, false)
  assert_eq(phong.extensions.multi_draw, false)
  shader.extensions.clip_cull_distance = true
  shader.extensions.multi_draw = true
  ignore(basic.copy(shader))
  assert_eq(basic.extensions.clip_cull_distance, false)
  assert_eq(basic.extensions.multi_draw, false)
  assert_eq(shader.extensions.clip_cull_distance, true)
  assert_eq(shader.extensions.multi_draw, true)
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  assert_eq(onto.extensions.clip_cull_distance, true)
  assert_eq(onto.extensions.multi_draw, true)
  onto.extensions.clip_cull_distance = false
  assert_eq(shader.extensions.clip_cull_distance, true)
  ignore(onto.copy(phong))
  assert_eq(onto.extensions.clip_cull_distance, false)
  assert_eq(onto.extensions.multi_draw, false)
  let cloned = shader.clone()
  assert_eq(cloned.extensions.clip_cull_distance, true)
  assert_eq(cloned.extensions.multi_draw, true)
  assert_eq(cloned.id == shader.id, false)
  cloned.extensions.multi_draw = false
  assert_eq(shader.extensions.multi_draw, true)
}

///|
test "Material shader copies default attribute values only onto shader" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  assert_eq(shader.default_attribute_values.get("color"), Some([1.0, 1.0, 1.0]))
  assert_eq(shader.default_attribute_values.get("uv"), Some([0.0, 0.0]))
  assert_eq(shader.default_attribute_values.get("uv1"), Some([0.0, 0.0]))
  match basic.default_attribute_values.get("color") {
    None => ()
    Some(_) => abort("basic default attributes should start empty")
  }
  match phong.default_attribute_values.get("color") {
    None => ()
    Some(_) => abort("phong default attributes should start empty")
  }
  shader.default_attribute_values.set("color", [2.0, 3.0, 4.0])
  shader.default_attribute_values.set("tangent", [5.0])
  ignore(basic.copy(shader))
  match basic.default_attribute_values.get("color") {
    None => ()
    Some(_) => abort("basic copy gained shader default attributes")
  }
  assert_eq(shader.default_attribute_values.get("color"), Some([2.0, 3.0, 4.0]))
  let onto = @materials.Material::shader()
  onto.default_attribute_values.set("color", [9.0, 9.0, 9.0])
  onto.default_attribute_values.set("drop", [1.0])
  ignore(onto.copy(shader))
  assert_eq(onto.default_attribute_values.get("color"), Some([2.0, 3.0, 4.0]))
  assert_eq(onto.default_attribute_values.get("uv"), Some([0.0, 0.0]))
  assert_eq(onto.default_attribute_values.get("uv1"), Some([0.0, 0.0]))
  assert_eq(onto.default_attribute_values.get("tangent"), Some([5.0]))
  match onto.default_attribute_values.get("drop") {
    None => ()
    Some(_) => abort("shader copy kept destination default attribute")
  }
  onto.default_attribute_values.get("color").unwrap()[0] = 8.0
  assert_eq(onto.default_attribute_values.get("color"), Some([8.0, 3.0, 4.0]))
  assert_eq(shader.default_attribute_values.get("color"), Some([2.0, 3.0, 4.0]))
  ignore(onto.copy(phong))
  match onto.default_attribute_values.get("color") {
    None => ()
    Some(_) => abort("shader copy kept default attribute missing from source")
  }
  let cloned = shader.clone()
  assert_eq(cloned.default_attribute_values.get("color"), Some([2.0, 3.0, 4.0]))
  assert_eq(cloned.default_attribute_values.get("uv"), Some([0.0, 0.0]))
  assert_eq(cloned.id == shader.id, false)
  cloned.default_attribute_values.get("color").unwrap()[0] = 6.0
  assert_eq(shader.default_attribute_values.get("color"), Some([2.0, 3.0, 4.0]))
}

///|
test "Material shader copies glslVersion only onto shader" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  assert_eq(shader.glsl_version is None, true)
  assert_eq(basic.glsl_version is None, true)
  assert_eq(phong.glsl_version is None, true)
  assert_eq(@materials.GlslVersion::GLSL1.code(), "100")
  assert_eq(@materials.GlslVersion::GLSL3.code(), "300 es")
  shader.glsl_version = Some(@materials.GlslVersion::GLSL3)
  ignore(basic.copy(shader))
  assert_eq(basic.glsl_version is None, true)
  assert_eq(shader.glsl_version is Some(@materials.GlslVersion::GLSL3), true)
  let onto = @materials.Material::shader()
  onto.glsl_version = Some(@materials.GlslVersion::GLSL1)
  ignore(onto.copy(shader))
  assert_eq(onto.glsl_version is Some(@materials.GlslVersion::GLSL3), true)
  onto.glsl_version = None
  assert_eq(shader.glsl_version is Some(@materials.GlslVersion::GLSL3), true)
  ignore(onto.copy(phong))
  assert_eq(onto.glsl_version is None, true)
  let cloned = shader.clone()
  assert_eq(cloned.glsl_version is Some(@materials.GlslVersion::GLSL3), true)
  assert_eq(cloned.id == shader.id, false)
  cloned.glsl_version = Some(@materials.GlslVersion::GLSL1)
  assert_eq(shader.glsl_version is Some(@materials.GlslVersion::GLSL3), true)
}

///|
test "Material shader copies index0AttributeName only onto shader" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  assert_eq(shader.index0_attribute_name is None, true)
  assert_eq(basic.index0_attribute_name is None, true)
  assert_eq(phong.index0_attribute_name is None, true)
  shader.index0_attribute_name = Some("position")
  ignore(basic.copy(shader))
  assert_eq(basic.index0_attribute_name is None, true)
  assert_eq(shader.index0_attribute_name, Some("position"))
  let onto = @materials.Material::shader()
  onto.index0_attribute_name = Some("normal")
  ignore(onto.copy(shader))
  assert_eq(onto.index0_attribute_name, Some("position"))
  onto.index0_attribute_name = Some("changed")
  assert_eq(shader.index0_attribute_name, Some("position"))
  ignore(onto.copy(phong))
  assert_eq(onto.index0_attribute_name is None, true)
  let cloned = shader.clone()
  assert_eq(cloned.index0_attribute_name, Some("position"))
  assert_eq(cloned.id == shader.id, false)
  cloned.index0_attribute_name = Some("uv")
  assert_eq(shader.index0_attribute_name, Some("position"))
}

///|
test "Material shader copies uniformsNeedUpdate only onto shader" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  let phong = @materials.Material::phong()
  assert_eq(shader.uniforms_need_update, false)
  assert_eq(basic.uniforms_need_update, false)
  assert_eq(phong.uniforms_need_update, false)
  shader.uniforms_need_update = true
  ignore(basic.copy(shader))
  assert_eq(basic.uniforms_need_update, false)
  assert_eq(shader.uniforms_need_update, true)
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  assert_eq(onto.uniforms_need_update, true)
  onto.uniforms_need_update = false
  assert_eq(shader.uniforms_need_update, true)
  ignore(onto.copy(phong))
  assert_eq(onto.uniforms_need_update, false)
  let cloned = shader.clone()
  assert_eq(cloned.uniforms_need_update, true)
  assert_eq(cloned.id == shader.id, false)
  cloned.uniforms_need_update = false
  assert_eq(shader.uniforms_need_update, true)
}
