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
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.precision = Some(@constants.Precision::Mediump)
  assert_eq(shader.prefixed_vertex_shader().length(), 1644)
  assert_eq(shader.prefixed_fragment_shader().length(), 2077)
  assert_eq(1644 - 1608, 36)
  assert_eq(
    shader.prefixed_vertex_shader()[84:108].to_owned(),
    "precision mediump float;",
  )
  shader.precision = Some(@constants.Precision::Lowp)
  assert_eq(shader.prefixed_vertex_shader().length(), 1590)
  assert_eq(shader.prefixed_fragment_shader().length(), 2023)
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
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.name = "Cube"
  assert_eq(shader.prefixed_vertex_shader().length(), 1612)
  assert_eq(shader.prefixed_fragment_shader().length(), 2045)
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
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.defines.set("FOO", "1")
  assert_eq(shader.prefixed_vertex_shader().length(), 1622)
  assert_eq(shader.prefixed_fragment_shader().length(), 2055)
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
  assert_eq(shader.prefixed_vertex_shader().length(), 1642)
  assert_eq(shader.prefixed_fragment_shader().length(), 2057)
  assert_eq(1642 - 1608, 34)
  assert_eq(
    shader.prefixed_vertex_shader()[683:698].to_owned(),
    "#define USE_MAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1094].to_owned(),
    "#define USE_MAP",
  )
  shader.defines.set("FOO", "1")
  assert_eq(shader.prefixed_vertex_shader().length(), 1656)
  assert_eq(1656 - 1642, 14)
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
  assert_eq(shader.prefixed_fragment_shader().length(), 2149)
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
  assert_eq(shader.prefixed_vertex_shader().length(), 1692)
  assert_eq(1692 - 1658, 34)
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
  assert_eq(shader.prefixed_fragment_shader().length(), 2149)
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
  assert_eq(shader.prefixed_vertex_shader().length(), 1692)
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
  assert_eq(shader.prefixed_fragment_shader().length(), 2149)
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
  assert_eq(shader.prefixed_fragment_shader().length(), 2149)
  assert_eq(1330 - 1297, 33)
  assert_eq(
    shader.prefixed_fragment_shader()[1154:1186].to_owned(),
    "#define ENVMAP_BLENDING_MULTIPLY",
  )
  shader.combine = @constants.Combine::Mix
  assert_eq(shader.prefixed_fragment_shader().length(), 2144)
  assert_eq(1325 - 1297, 28)
  assert_eq(
    shader.prefixed_fragment_shader()[1154:1181].to_owned(),
    "#define ENVMAP_BLENDING_MIX",
  )
  shader.combine = @constants.Combine::Add
  assert_eq(shader.prefixed_fragment_shader().length(), 2144)
  assert_eq(
    shader.prefixed_fragment_shader()[1154:1181].to_owned(),
    "#define ENVMAP_BLENDING_ADD",
  )
  let bare = @materials.Material::shader()
  bare.combine = @constants.Combine::Mix
  assert_eq(bare.prefixed_fragment_shader().length(), 2041)
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
test "Material shader writes USE_LIGHTMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let light_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.light_map = Some(light_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1652)
  assert_eq(shader.prefixed_fragment_shader().length(), 2062)
  assert_eq(1652 - 1608, 44)
  assert_eq(
    shader.prefixed_vertex_shader()[683:703].to_owned(),
    "#define USE_LIGHTMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1099].to_owned(),
    "#define USE_LIGHTMAP",
  )
  shader.env_map = Some(light_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1702)
  assert_eq(
    shader.prefixed_vertex_shader()[733:753].to_owned(),
    "#define USE_LIGHTMAP",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2170)
  assert_eq(
    shader.prefixed_fragment_shader()[1187:1207].to_owned(),
    "#define USE_LIGHTMAP",
  )
  let raw = @materials.Material::raw()
  raw.light_map = Some(light_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.light_map = Some(light_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_AOMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let ao_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.ao_map = Some(ao_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1646)
  assert_eq(shader.prefixed_fragment_shader().length(), 2059)
  assert_eq(1646 - 1608, 38)
  assert_eq(
    shader.prefixed_vertex_shader()[683:700].to_owned(),
    "#define USE_AOMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1096].to_owned(),
    "#define USE_AOMAP",
  )
  shader.light_map = Some(ao_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1690)
  assert_eq(
    shader.prefixed_vertex_shader()[704:721].to_owned(),
    "#define USE_AOMAP",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2080)
  assert_eq(
    shader.prefixed_fragment_shader()[1100:1117].to_owned(),
    "#define USE_AOMAP",
  )
  let raw = @materials.Material::raw()
  raw.ao_map = Some(ao_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.ao_map = Some(ao_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_BUMPMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let bump_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.bump_map = Some(bump_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1650)
  assert_eq(shader.prefixed_fragment_shader().length(), 2061)
  assert_eq(1650 - 1608, 42)
  assert_eq(
    shader.prefixed_vertex_shader()[683:702].to_owned(),
    "#define USE_BUMPMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1098].to_owned(),
    "#define USE_BUMPMAP",
  )
  shader.ao_map = Some(bump_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1688)
  assert_eq(
    shader.prefixed_vertex_shader()[701:720].to_owned(),
    "#define USE_BUMPMAP",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2079)
  assert_eq(
    shader.prefixed_fragment_shader()[1097:1116].to_owned(),
    "#define USE_BUMPMAP",
  )
  let raw = @materials.Material::raw()
  raw.bump_map = Some(bump_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.bump_map = Some(bump_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_NORMALMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let normal_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.normal_map = Some(normal_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1689)
  assert_eq(shader.prefixed_fragment_shader().length(), 2098)
  assert_eq(1689 - 1608, 81)
  assert_eq(
    shader.prefixed_vertex_shader()[683:704].to_owned(),
    "#define USE_NORMALMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1100].to_owned(),
    "#define USE_NORMALMAP",
  )
  shader.bump_map = Some(normal_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1731)
  assert_eq(
    shader.prefixed_vertex_shader()[703:724].to_owned(),
    "#define USE_NORMALMAP",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2118)
  assert_eq(
    shader.prefixed_fragment_shader()[1099:1120].to_owned(),
    "#define USE_NORMALMAP",
  )
  let raw = @materials.Material::raw()
  raw.normal_map = Some(normal_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.normal_map = Some(normal_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_NORMALMAP_TANGENTSPACE" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let normal_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.normal_map = Some(normal_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1689)
  assert_eq(shader.prefixed_fragment_shader().length(), 2098)
  assert_eq(1689 - 1654, 35)
  assert_eq(
    shader.prefixed_vertex_shader()[705:739].to_owned(),
    "#define USE_NORMALMAP_TANGENTSPACE",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1101:1135].to_owned(),
    "#define USE_NORMALMAP_TANGENTSPACE",
  )
  shader.normal_map_type = @constants.NormalMapType::ObjectSpace
  assert_eq(shader.prefixed_vertex_shader().length(), 1688)
  assert_eq(shader.prefixed_fragment_shader().length(), 2097)
  let raw = @materials.Material::raw()
  raw.normal_map = Some(normal_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.normal_map = Some(normal_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_NORMALMAP_OBJECTSPACE" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let normal_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.normal_map = Some(normal_map)
  shader.normal_map_type = @constants.NormalMapType::ObjectSpace
  assert_eq(shader.prefixed_vertex_shader().length(), 1688)
  assert_eq(shader.prefixed_fragment_shader().length(), 2097)
  assert_eq(1688 - 1654, 34)
  assert_eq(
    shader.prefixed_vertex_shader()[705:738].to_owned(),
    "#define USE_NORMALMAP_OBJECTSPACE",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1101:1134].to_owned(),
    "#define USE_NORMALMAP_OBJECTSPACE",
  )
  shader.normal_map_type = @constants.NormalMapType::TangentSpace
  assert_eq(
    shader.prefixed_vertex_shader()[705:739].to_owned(),
    "#define USE_NORMALMAP_TANGENTSPACE",
  )
  let raw = @materials.Material::raw()
  raw.normal_map = Some(normal_map)
  raw.normal_map_type = @constants.NormalMapType::ObjectSpace
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.normal_map = Some(normal_map)
  basic.normal_map_type = @constants.NormalMapType::ObjectSpace
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_DISPLACEMENTMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let displacement_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.displacement_map = Some(displacement_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1666)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(1666 - 1608, 58)
  assert_eq(
    shader.prefixed_vertex_shader()[683:710].to_owned(),
    "#define USE_DISPLACEMENTMAP",
  )
  shader.normal_map = Some(displacement_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1747)
  assert_eq(
    shader.prefixed_vertex_shader()[740:767].to_owned(),
    "#define USE_DISPLACEMENTMAP",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2098)
  let raw = @materials.Material::raw()
  raw.displacement_map = Some(displacement_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.displacement_map = Some(displacement_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_EMISSIVEMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let emissive_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.emissive_map = Some(emissive_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1658)
  assert_eq(shader.prefixed_fragment_shader().length(), 2065)
  assert_eq(1658 - 1608, 50)
  assert_eq(
    shader.prefixed_vertex_shader()[683:706].to_owned(),
    "#define USE_EMISSIVEMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1102].to_owned(),
    "#define USE_EMISSIVEMAP",
  )
  shader.displacement_map = Some(emissive_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1716)
  assert_eq(
    shader.prefixed_vertex_shader()[711:734].to_owned(),
    "#define USE_EMISSIVEMAP",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2065)
  let raw = @materials.Material::raw()
  raw.emissive_map = Some(emissive_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.emissive_map = Some(emissive_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_ANISOTROPY" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.anisotropy = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1631)
  assert_eq(shader.prefixed_fragment_shader().length(), 2064)
  assert_eq(1631 - 1608, 23)
  assert_eq(
    shader.prefixed_vertex_shader()[683:705].to_owned(),
    "#define USE_ANISOTROPY",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1101].to_owned(),
    "#define USE_ANISOTROPY",
  )
  shader.anisotropy = -1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.anisotropy = 1.0
  let pixels = FixedArray::make(4, b'\xFF')
  shader.emissive_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.prefixed_vertex_shader().length(), 1681)
  assert_eq(
    shader.prefixed_vertex_shader()[707:729].to_owned(),
    "#define USE_ANISOTROPY",
  )
  let raw = @materials.Material::raw()
  raw.anisotropy = 1.0
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.anisotropy = 1.0
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_ANISOTROPYMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let anisotropy_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.anisotropy_map = Some(anisotropy_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.anisotropy = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1685)
  assert_eq(shader.prefixed_fragment_shader().length(), 2090)
  assert_eq(1685 - 1659, 26)
  assert_eq(
    shader.prefixed_vertex_shader()[706:731].to_owned(),
    "#define USE_ANISOTROPYMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1102:1127].to_owned(),
    "#define USE_ANISOTROPYMAP",
  )
  shader.anisotropy = 0.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  let raw = @materials.Material::raw()
  raw.anisotropy = 1.0
  raw.anisotropy_map = Some(anisotropy_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.anisotropy = 1.0
  basic.anisotropy_map = Some(anisotropy_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_CLEARCOAT" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.clearcoat = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2063)
  assert_eq(1244 - 1222, 22)
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1100].to_owned(),
    "#define USE_CLEARCOAT",
  )
  shader.clearcoat = -1.0
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.clearcoat = 1.0
  shader.anisotropy = 1.0
  assert_eq(shader.prefixed_fragment_shader().length(), 2086)
  assert_eq(
    shader.prefixed_fragment_shader()[1102:1123].to_owned(),
    "#define USE_CLEARCOAT",
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1631)
  let raw = @materials.Material::raw()
  raw.clearcoat = 1.0
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  let basic = @materials.Material::basic()
  basic.clearcoat = 1.0
  assert_eq(basic.prefixed_fragment_shader(), "")
}

///|
test "Material shader writes USE_CLEARCOATMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let clearcoat_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.clearcoat_map = Some(clearcoat_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.clearcoat = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1660)
  assert_eq(shader.prefixed_fragment_shader().length(), 2088)
  assert_eq(1660 - 1608, 52)
  assert_eq(1269 - 1244, 25)
  assert_eq(
    shader.prefixed_vertex_shader()[683:707].to_owned(),
    "#define USE_CLEARCOATMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1100].to_owned(),
    "#define USE_CLEARCOAT",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1101:1125].to_owned(),
    "#define USE_CLEARCOATMAP",
  )
  shader.clearcoat = 0.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let raw = @materials.Material::raw()
  raw.clearcoat = 1.0
  raw.clearcoat_map = Some(clearcoat_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.clearcoat = 1.0
  basic.clearcoat_map = Some(clearcoat_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_CLEARCOAT_ROUGHNESSMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let roughness_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.clearcoat_roughness_map = Some(roughness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.clearcoat = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1680)
  assert_eq(shader.prefixed_fragment_shader().length(), 2098)
  assert_eq(1680 - 1608, 72)
  assert_eq(
    shader.prefixed_vertex_shader()[683:717].to_owned(),
    "#define USE_CLEARCOAT_ROUGHNESSMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1101:1135].to_owned(),
    "#define USE_CLEARCOAT_ROUGHNESSMAP",
  )
  shader.clearcoat_map = Some(roughness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1732)
  assert_eq(
    shader.prefixed_vertex_shader()[708:742].to_owned(),
    "#define USE_CLEARCOAT_ROUGHNESSMAP",
  )
  let raw = @materials.Material::raw()
  raw.clearcoat = 1.0
  raw.clearcoat_roughness_map = Some(roughness_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.clearcoat = 1.0
  basic.clearcoat_roughness_map = Some(roughness_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_CLEARCOAT_NORMALMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let normal_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.clearcoat_normal_map = Some(normal_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.clearcoat = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1674)
  assert_eq(shader.prefixed_fragment_shader().length(), 2095)
  assert_eq(1674 - 1608, 66)
  assert_eq(
    shader.prefixed_vertex_shader()[683:714].to_owned(),
    "#define USE_CLEARCOAT_NORMALMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1101:1132].to_owned(),
    "#define USE_CLEARCOAT_NORMALMAP",
  )
  shader.clearcoat_roughness_map = Some(normal_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1746)
  assert_eq(
    shader.prefixed_vertex_shader()[718:749].to_owned(),
    "#define USE_CLEARCOAT_NORMALMAP",
  )
  let raw = @materials.Material::raw()
  raw.clearcoat = 1.0
  raw.clearcoat_normal_map = Some(normal_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.clearcoat = 1.0
  basic.clearcoat_normal_map = Some(normal_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_IRIDESCENCEMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let iridescence_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.iridescence_map = Some(iridescence_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.iridescence = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1664)
  assert_eq(shader.prefixed_fragment_shader().length(), 2068)
  assert_eq(1664 - 1608, 56)
  assert_eq(
    shader.prefixed_vertex_shader()[683:709].to_owned(),
    "#define USE_IRIDESCENCEMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1105].to_owned(),
    "#define USE_IRIDESCENCEMAP",
  )
  shader.iridescence = -1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.iridescence = 1.0
  shader.clearcoat = 1.0
  shader.clearcoat_normal_map = Some(iridescence_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1730)
  assert_eq(
    shader.prefixed_vertex_shader()[715:741].to_owned(),
    "#define USE_IRIDESCENCEMAP",
  )
  let raw = @materials.Material::raw()
  raw.iridescence = 1.0
  raw.iridescence_map = Some(iridescence_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.iridescence = 1.0
  basic.iridescence_map = Some(iridescence_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_IRIDESCENCE_THICKNESSMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let thickness_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.iridescence_thickness_map = Some(thickness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.iridescence = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1684)
  assert_eq(shader.prefixed_fragment_shader().length(), 2078)
  assert_eq(1684 - 1608, 76)
  assert_eq(
    shader.prefixed_vertex_shader()[683:719].to_owned(),
    "#define USE_IRIDESCENCE_THICKNESSMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1115].to_owned(),
    "#define USE_IRIDESCENCE_THICKNESSMAP",
  )
  shader.iridescence_map = Some(thickness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1740)
  assert_eq(
    shader.prefixed_vertex_shader()[710:746].to_owned(),
    "#define USE_IRIDESCENCE_THICKNESSMAP",
  )
  let raw = @materials.Material::raw()
  raw.iridescence = 1.0
  raw.iridescence_thickness_map = Some(thickness_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.iridescence = 1.0
  basic.iridescence_thickness_map = Some(thickness_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_SPECULARMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let specular_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.specular_map = Some(specular_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1658)
  assert_eq(shader.prefixed_fragment_shader().length(), 2065)
  assert_eq(1658 - 1608, 50)
  assert_eq(
    shader.prefixed_vertex_shader()[683:706].to_owned(),
    "#define USE_SPECULARMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1102].to_owned(),
    "#define USE_SPECULARMAP",
  )
  shader.iridescence = 1.0
  shader.iridescence_thickness_map = Some(specular_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1734)
  assert_eq(
    shader.prefixed_vertex_shader()[720:743].to_owned(),
    "#define USE_SPECULARMAP",
  )
  let raw = @materials.Material::raw()
  raw.specular_map = Some(specular_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.specular_map = Some(specular_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_SPECULAR_COLORMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let color_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.specular_color_map = Some(color_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1670)
  assert_eq(shader.prefixed_fragment_shader().length(), 2071)
  assert_eq(1670 - 1608, 62)
  assert_eq(
    shader.prefixed_vertex_shader()[683:712].to_owned(),
    "#define USE_SPECULAR_COLORMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1108].to_owned(),
    "#define USE_SPECULAR_COLORMAP",
  )
  shader.specular_map = Some(color_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1720)
  assert_eq(
    shader.prefixed_vertex_shader()[707:736].to_owned(),
    "#define USE_SPECULAR_COLORMAP",
  )
  let raw = @materials.Material::raw()
  raw.specular_color_map = Some(color_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.specular_color_map = Some(color_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_SPECULAR_INTENSITYMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let intensity_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.specular_intensity_map = Some(intensity_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1678)
  assert_eq(shader.prefixed_fragment_shader().length(), 2075)
  assert_eq(1678 - 1608, 70)
  assert_eq(
    shader.prefixed_vertex_shader()[683:716].to_owned(),
    "#define USE_SPECULAR_INTENSITYMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1112].to_owned(),
    "#define USE_SPECULAR_INTENSITYMAP",
  )
  shader.specular_color_map = Some(intensity_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1740)
  assert_eq(
    shader.prefixed_vertex_shader()[713:746].to_owned(),
    "#define USE_SPECULAR_INTENSITYMAP",
  )
  let raw = @materials.Material::raw()
  raw.specular_intensity_map = Some(intensity_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.specular_intensity_map = Some(intensity_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_ROUGHNESSMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let roughness_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.roughness_map = Some(roughness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1660)
  assert_eq(shader.prefixed_fragment_shader().length(), 2066)
  assert_eq(1660 - 1608, 52)
  assert_eq(
    shader.prefixed_vertex_shader()[683:707].to_owned(),
    "#define USE_ROUGHNESSMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1103].to_owned(),
    "#define USE_ROUGHNESSMAP",
  )
  shader.specular_intensity_map = Some(roughness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1730)
  assert_eq(
    shader.prefixed_vertex_shader()[717:741].to_owned(),
    "#define USE_ROUGHNESSMAP",
  )
  let raw = @materials.Material::raw()
  raw.roughness_map = Some(roughness_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.roughness_map = Some(roughness_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_METALNESSMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let metalness_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.metalness_map = Some(metalness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1660)
  assert_eq(shader.prefixed_fragment_shader().length(), 2066)
  assert_eq(1660 - 1608, 52)
  assert_eq(
    shader.prefixed_vertex_shader()[683:707].to_owned(),
    "#define USE_METALNESSMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1103].to_owned(),
    "#define USE_METALNESSMAP",
  )
  shader.roughness_map = Some(metalness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1712)
  assert_eq(
    shader.prefixed_vertex_shader()[708:732].to_owned(),
    "#define USE_METALNESSMAP",
  )
  let raw = @materials.Material::raw()
  raw.metalness_map = Some(metalness_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.metalness_map = Some(metalness_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_ALPHAMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let alpha_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.alpha_map = Some(alpha_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1652)
  assert_eq(shader.prefixed_fragment_shader().length(), 2062)
  assert_eq(1652 - 1608, 44)
  assert_eq(
    shader.prefixed_vertex_shader()[683:703].to_owned(),
    "#define USE_ALPHAMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1099].to_owned(),
    "#define USE_ALPHAMAP",
  )
  shader.metalness_map = Some(alpha_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1704)
  assert_eq(
    shader.prefixed_vertex_shader()[708:728].to_owned(),
    "#define USE_ALPHAMAP",
  )
  let raw = @materials.Material::raw()
  raw.alpha_map = Some(alpha_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.alpha_map = Some(alpha_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_ALPHAHASH" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.alpha_hash = true
  assert_eq(shader.prefixed_vertex_shader().length(), 1630)
  assert_eq(shader.prefixed_fragment_shader().length(), 2063)
  assert_eq(1630 - 1608, 22)
  assert_eq(
    shader.prefixed_vertex_shader()[683:704].to_owned(),
    "#define USE_ALPHAHASH",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1100].to_owned(),
    "#define USE_ALPHAHASH",
  )
  shader.alpha_hash = false
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.alpha_hash = true
  let pixels = FixedArray::make(4, b'\xFF')
  shader.alpha_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.prefixed_vertex_shader().length(), 1674)
  assert_eq(
    shader.prefixed_vertex_shader()[704:725].to_owned(),
    "#define USE_ALPHAHASH",
  )
  let raw = @materials.Material::raw()
  raw.alpha_hash = true
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.alpha_hash = true
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_TRANSMISSION" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.transmission = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1633)
  assert_eq(shader.prefixed_fragment_shader().length(), 2066)
  assert_eq(1633 - 1608, 25)
  assert_eq(
    shader.prefixed_vertex_shader()[683:707].to_owned(),
    "#define USE_TRANSMISSION",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1103].to_owned(),
    "#define USE_TRANSMISSION",
  )
  shader.transmission = -1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.transmission = 1.0
  shader.alpha_hash = true
  assert_eq(shader.prefixed_vertex_shader().length(), 1655)
  assert_eq(
    shader.prefixed_vertex_shader()[705:729].to_owned(),
    "#define USE_TRANSMISSION",
  )
  let raw = @materials.Material::raw()
  raw.transmission = 1.0
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.transmission = 1.0
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_TRANSMISSIONMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let transmission_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.transmission_map = Some(transmission_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.transmission = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1691)
  assert_eq(shader.prefixed_fragment_shader().length(), 2094)
  assert_eq(1691 - 1633, 58)
  assert_eq(
    shader.prefixed_vertex_shader()[708:735].to_owned(),
    "#define USE_TRANSMISSIONMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1104:1131].to_owned(),
    "#define USE_TRANSMISSIONMAP",
  )
  shader.transmission = 0.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  let raw = @materials.Material::raw()
  raw.transmission = 1.0
  raw.transmission_map = Some(transmission_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.transmission = 1.0
  basic.transmission_map = Some(transmission_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_THICKNESSMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let thickness_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.thickness_map = Some(thickness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.transmission = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1685)
  assert_eq(shader.prefixed_fragment_shader().length(), 2091)
  assert_eq(1685 - 1633, 52)
  assert_eq(
    shader.prefixed_vertex_shader()[708:732].to_owned(),
    "#define USE_THICKNESSMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1104:1128].to_owned(),
    "#define USE_THICKNESSMAP",
  )
  shader.transmission_map = Some(thickness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1743)
  assert_eq(
    shader.prefixed_vertex_shader()[736:760].to_owned(),
    "#define USE_THICKNESSMAP",
  )
  let raw = @materials.Material::raw()
  raw.transmission = 1.0
  raw.thickness_map = Some(thickness_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.transmission = 1.0
  basic.thickness_map = Some(thickness_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_SHEEN_COLORMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let sheen_color_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.sheen_color_map = Some(sheen_color_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.sheen = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1664)
  assert_eq(shader.prefixed_fragment_shader().length(), 2068)
  assert_eq(1664 - 1608, 56)
  assert_eq(
    shader.prefixed_vertex_shader()[683:709].to_owned(),
    "#define USE_SHEEN_COLORMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1105].to_owned(),
    "#define USE_SHEEN_COLORMAP",
  )
  shader.sheen = -1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.sheen = 1.0
  shader.transmission = 1.0
  shader.thickness_map = Some(sheen_color_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1741)
  assert_eq(
    shader.prefixed_vertex_shader()[733:759].to_owned(),
    "#define USE_SHEEN_COLORMAP",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2118)
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1105].to_owned(),
    "#define USE_SHEEN_COLORMAP",
  )
  let raw = @materials.Material::raw()
  raw.sheen = 1.0
  raw.sheen_color_map = Some(sheen_color_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.sheen = 1.0
  basic.sheen_color_map = Some(sheen_color_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_SHEEN_ROUGHNESSMAP" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let roughness_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.sheen_roughness_map = Some(roughness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.sheen = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1672)
  assert_eq(shader.prefixed_fragment_shader().length(), 2072)
  assert_eq(1672 - 1608, 64)
  assert_eq(
    shader.prefixed_vertex_shader()[683:713].to_owned(),
    "#define USE_SHEEN_ROUGHNESSMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1109].to_owned(),
    "#define USE_SHEEN_ROUGHNESSMAP",
  )
  shader.sheen_color_map = Some(roughness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1728)
  assert_eq(
    shader.prefixed_vertex_shader()[710:740].to_owned(),
    "#define USE_SHEEN_ROUGHNESSMAP",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2099)
  assert_eq(
    shader.prefixed_fragment_shader()[1106:1136].to_owned(),
    "#define USE_SHEEN_ROUGHNESSMAP",
  )
  let raw = @materials.Material::raw()
  raw.sheen = 1.0
  raw.sheen_roughness_map = Some(roughness_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.sheen = 1.0
  basic.sheen_roughness_map = Some(roughness_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes MAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(map.channel, 0)
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1642)
  assert_eq(shader.prefixed_fragment_shader().length(), 2057)
  assert_eq(1642 - 1608, 34)
  assert_eq(shader.prefixed_vertex_shader()[699:716].to_owned(), "#define MAP_UV uv")
  map.channel = 1
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1659)
  assert_eq(shader.prefixed_fragment_shader().length(), 2073)
  assert_eq(1659 - 1608, 51)
  assert_eq(
    shader.prefixed_vertex_shader()[699:717].to_owned(),
    "#define MAP_UV uv1",
  )
  map.channel = 0
  shader.map = Some(map)
  shader.sheen = 1.0
  shader.sheen_roughness_map = Some(map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1706)
  assert_eq(
    shader.prefixed_vertex_shader()[730:747].to_owned(),
    "#define MAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.map = Some(map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.map = Some(map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes ALPHAMAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let alpha_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(alpha_map.channel, 0)
  shader.alpha_map = Some(alpha_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1652)
  assert_eq(shader.prefixed_fragment_shader().length(), 2062)
  assert_eq(1652 - 1608, 44)
  assert_eq(
    shader.prefixed_vertex_shader()[704:726].to_owned(),
    "#define ALPHAMAP_UV uv",
  )
  alpha_map.channel = 1
  shader.alpha_map = Some(alpha_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1669)
  assert_eq(shader.prefixed_fragment_shader().length(), 2078)
  assert_eq(1669 - 1608, 61)
  assert_eq(
    shader.prefixed_vertex_shader()[704:727].to_owned(),
    "#define ALPHAMAP_UV uv1",
  )
  alpha_map.channel = 0
  shader.alpha_map = Some(alpha_map)
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1686)
  assert_eq(
    shader.prefixed_vertex_shader()[738:760].to_owned(),
    "#define ALPHAMAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.alpha_map = Some(alpha_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.alpha_map = Some(alpha_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes LIGHTMAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let light_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(light_map.channel, 0)
  shader.light_map = Some(light_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1652)
  assert_eq(shader.prefixed_fragment_shader().length(), 2062)
  assert_eq(1652 - 1608, 44)
  assert_eq(
    shader.prefixed_vertex_shader()[704:726].to_owned(),
    "#define LIGHTMAP_UV uv",
  )
  light_map.channel = 1
  shader.light_map = Some(light_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1669)
  assert_eq(shader.prefixed_fragment_shader().length(), 2078)
  assert_eq(1669 - 1608, 61)
  assert_eq(
    shader.prefixed_vertex_shader()[704:727].to_owned(),
    "#define LIGHTMAP_UV uv1",
  )
  light_map.channel = 0
  shader.light_map = Some(light_map)
  let alpha_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.alpha_map = Some(alpha_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1696)
  assert_eq(
    shader.prefixed_vertex_shader()[748:770].to_owned(),
    "#define LIGHTMAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.light_map = Some(light_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.light_map = Some(light_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes AOMAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let ao_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(ao_map.channel, 0)
  shader.ao_map = Some(ao_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1646)
  assert_eq(shader.prefixed_fragment_shader().length(), 2059)
  assert_eq(1646 - 1608, 38)
  assert_eq(
    shader.prefixed_vertex_shader()[701:720].to_owned(),
    "#define AOMAP_UV uv",
  )
  ao_map.channel = 1
  shader.ao_map = Some(ao_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1663)
  assert_eq(shader.prefixed_fragment_shader().length(), 2075)
  assert_eq(1663 - 1608, 55)
  assert_eq(
    shader.prefixed_vertex_shader()[701:721].to_owned(),
    "#define AOMAP_UV uv1",
  )
  ao_map.channel = 0
  shader.ao_map = Some(ao_map)
  let light_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.light_map = Some(light_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1690)
  assert_eq(
    shader.prefixed_vertex_shader()[745:764].to_owned(),
    "#define AOMAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.ao_map = Some(ao_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.ao_map = Some(ao_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes EMISSIVEMAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let emissive_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(emissive_map.channel, 0)
  shader.emissive_map = Some(emissive_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1658)
  assert_eq(shader.prefixed_fragment_shader().length(), 2065)
  assert_eq(1658 - 1608, 50)
  assert_eq(
    shader.prefixed_vertex_shader()[707:732].to_owned(),
    "#define EMISSIVEMAP_UV uv",
  )
  emissive_map.channel = 1
  shader.emissive_map = Some(emissive_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1675)
  assert_eq(shader.prefixed_fragment_shader().length(), 2081)
  assert_eq(1675 - 1608, 67)
  assert_eq(
    shader.prefixed_vertex_shader()[707:733].to_owned(),
    "#define EMISSIVEMAP_UV uv1",
  )
  emissive_map.channel = 0
  shader.emissive_map = Some(emissive_map)
  let ao_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.ao_map = Some(ao_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1696)
  assert_eq(
    shader.prefixed_vertex_shader()[745:770].to_owned(),
    "#define EMISSIVEMAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.emissive_map = Some(emissive_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.emissive_map = Some(emissive_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes BUMPMAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let bump_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(bump_map.channel, 0)
  shader.bump_map = Some(bump_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1650)
  assert_eq(shader.prefixed_fragment_shader().length(), 2061)
  assert_eq(1650 - 1608, 42)
  assert_eq(
    shader.prefixed_vertex_shader()[703:724].to_owned(),
    "#define BUMPMAP_UV uv",
  )
  bump_map.channel = 1
  shader.bump_map = Some(bump_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1667)
  assert_eq(shader.prefixed_fragment_shader().length(), 2077)
  assert_eq(1667 - 1608, 59)
  assert_eq(
    shader.prefixed_vertex_shader()[703:725].to_owned(),
    "#define BUMPMAP_UV uv1",
  )
  shader.wireframe = true
  assert_eq(shader.prefixed_vertex_shader().length(), 1628)
  shader.wireframe = false
  bump_map.channel = 0
  shader.bump_map = Some(bump_map)
  let emissive_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.emissive_map = Some(emissive_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1700)
  assert_eq(
    shader.prefixed_vertex_shader()[753:774].to_owned(),
    "#define BUMPMAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.bump_map = Some(bump_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.bump_map = Some(bump_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes NORMALMAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let normal_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(normal_map.channel, 0)
  shader.normal_map = Some(normal_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1689)
  assert_eq(shader.prefixed_fragment_shader().length(), 2098)
  assert_eq(1689 - 1608, 81)
  assert_eq(
    shader.prefixed_vertex_shader()[740:763].to_owned(),
    "#define NORMALMAP_UV uv",
  )
  normal_map.channel = 1
  shader.normal_map = Some(normal_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1706)
  assert_eq(shader.prefixed_fragment_shader().length(), 2114)
  assert_eq(1706 - 1608, 98)
  assert_eq(
    shader.prefixed_vertex_shader()[740:764].to_owned(),
    "#define NORMALMAP_UV uv1",
  )
  normal_map.channel = 0
  shader.normal_map = Some(normal_map)
  let bump_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.bump_map = Some(bump_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1731)
  assert_eq(
    shader.prefixed_vertex_shader()[782:805].to_owned(),
    "#define NORMALMAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.normal_map = Some(normal_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.normal_map = Some(normal_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes DISPLACEMENTMAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let displacement_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(displacement_map.channel, 0)
  shader.displacement_map = Some(displacement_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1666)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(1666 - 1608, 58)
  assert_eq(
    shader.prefixed_vertex_shader()[711:740].to_owned(),
    "#define DISPLACEMENTMAP_UV uv",
  )
  displacement_map.channel = 1
  shader.displacement_map = Some(displacement_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1683)
  assert_eq(shader.prefixed_fragment_shader().length(), 2057)
  assert_eq(1683 - 1608, 75)
  assert_eq(
    shader.prefixed_vertex_shader()[711:741].to_owned(),
    "#define DISPLACEMENTMAP_UV uv1",
  )
  displacement_map.channel = 0
  shader.displacement_map = Some(displacement_map)
  let normal_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.normal_map = Some(normal_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1747)
  assert_eq(
    shader.prefixed_vertex_shader()[792:821].to_owned(),
    "#define DISPLACEMENTMAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.displacement_map = Some(displacement_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.displacement_map = Some(displacement_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes METALNESSMAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let metalness_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(metalness_map.channel, 0)
  shader.metalness_map = Some(metalness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1660)
  assert_eq(shader.prefixed_fragment_shader().length(), 2066)
  assert_eq(1660 - 1608, 52)
  assert_eq(
    shader.prefixed_vertex_shader()[708:734].to_owned(),
    "#define METALNESSMAP_UV uv",
  )
  metalness_map.channel = 1
  shader.metalness_map = Some(metalness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1677)
  assert_eq(shader.prefixed_fragment_shader().length(), 2082)
  assert_eq(1677 - 1608, 69)
  assert_eq(
    shader.prefixed_vertex_shader()[708:735].to_owned(),
    "#define METALNESSMAP_UV uv1",
  )
  metalness_map.channel = 0
  shader.metalness_map = Some(metalness_map)
  let displacement_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.displacement_map = Some(displacement_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1718)
  assert_eq(
    shader.prefixed_vertex_shader()[766:792].to_owned(),
    "#define METALNESSMAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.metalness_map = Some(metalness_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.metalness_map = Some(metalness_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes ROUGHNESSMAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let roughness_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(roughness_map.channel, 0)
  shader.roughness_map = Some(roughness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1660)
  assert_eq(shader.prefixed_fragment_shader().length(), 2066)
  assert_eq(1660 - 1608, 52)
  assert_eq(
    shader.prefixed_vertex_shader()[708:734].to_owned(),
    "#define ROUGHNESSMAP_UV uv",
  )
  roughness_map.channel = 1
  shader.roughness_map = Some(roughness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1677)
  assert_eq(shader.prefixed_fragment_shader().length(), 2082)
  assert_eq(1677 - 1608, 69)
  assert_eq(
    shader.prefixed_vertex_shader()[708:735].to_owned(),
    "#define ROUGHNESSMAP_UV uv1",
  )
  roughness_map.channel = 0
  shader.roughness_map = Some(roughness_map)
  let metalness_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.metalness_map = Some(metalness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1712)
  assert_eq(
    shader.prefixed_vertex_shader()[760:786].to_owned(),
    "#define ROUGHNESSMAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.roughness_map = Some(roughness_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.roughness_map = Some(roughness_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes ANISOTROPYMAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let anisotropy_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(anisotropy_map.channel, 0)
  shader.anisotropy_map = Some(anisotropy_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.anisotropy = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1685)
  assert_eq(shader.prefixed_fragment_shader().length(), 2090)
  assert_eq(1685 - 1608, 77)
  assert_eq(
    shader.prefixed_vertex_shader()[732:759].to_owned(),
    "#define ANISOTROPYMAP_UV uv",
  )
  anisotropy_map.channel = 1
  shader.anisotropy_map = Some(anisotropy_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1702)
  assert_eq(shader.prefixed_fragment_shader().length(), 2106)
  assert_eq(1702 - 1608, 94)
  assert_eq(
    shader.prefixed_vertex_shader()[732:760].to_owned(),
    "#define ANISOTROPYMAP_UV uv1",
  )
  shader.anisotropy = 0.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.anisotropy = 1.0
  anisotropy_map.channel = 0
  shader.anisotropy_map = Some(anisotropy_map)
  let roughness_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.roughness_map = Some(roughness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1737)
  assert_eq(
    shader.prefixed_vertex_shader()[784:811].to_owned(),
    "#define ANISOTROPYMAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.anisotropy = 1.0
  raw.anisotropy_map = Some(anisotropy_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.anisotropy = 1.0
  basic.anisotropy_map = Some(anisotropy_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes CLEARCOATMAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let clearcoat_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(clearcoat_map.channel, 0)
  shader.clearcoat_map = Some(clearcoat_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.clearcoat = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1660)
  assert_eq(shader.prefixed_fragment_shader().length(), 2088)
  assert_eq(1660 - 1608, 52)
  assert_eq(
    shader.prefixed_vertex_shader()[708:734].to_owned(),
    "#define CLEARCOATMAP_UV uv",
  )
  clearcoat_map.channel = 1
  shader.clearcoat_map = Some(clearcoat_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1677)
  assert_eq(shader.prefixed_fragment_shader().length(), 2104)
  assert_eq(1677 - 1608, 69)
  assert_eq(
    shader.prefixed_vertex_shader()[708:735].to_owned(),
    "#define CLEARCOATMAP_UV uv1",
  )
  shader.clearcoat = 0.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.clearcoat = 1.0
  clearcoat_map.channel = 0
  shader.clearcoat_map = Some(clearcoat_map)
  let anisotropy_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.anisotropy = 1.0
  shader.anisotropy_map = Some(anisotropy_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1737)
  assert_eq(
    shader.prefixed_vertex_shader()[785:811].to_owned(),
    "#define CLEARCOATMAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.clearcoat = 1.0
  raw.clearcoat_map = Some(clearcoat_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.clearcoat = 1.0
  basic.clearcoat_map = Some(clearcoat_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes CLEARCOAT_NORMALMAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let normal_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(normal_map.channel, 0)
  shader.clearcoat_normal_map = Some(normal_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.clearcoat = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1674)
  assert_eq(shader.prefixed_fragment_shader().length(), 2095)
  assert_eq(1674 - 1608, 66)
  assert_eq(
    shader.prefixed_vertex_shader()[715:748].to_owned(),
    "#define CLEARCOAT_NORMALMAP_UV uv",
  )
  normal_map.channel = 1
  shader.clearcoat_normal_map = Some(normal_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1691)
  assert_eq(shader.prefixed_fragment_shader().length(), 2111)
  assert_eq(1691 - 1608, 83)
  assert_eq(
    shader.prefixed_vertex_shader()[715:749].to_owned(),
    "#define CLEARCOAT_NORMALMAP_UV uv1",
  )
  shader.clearcoat = 0.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.clearcoat = 1.0
  normal_map.channel = 0
  shader.clearcoat_normal_map = Some(normal_map)
  let clearcoat_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.clearcoat_map = Some(clearcoat_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1726)
  assert_eq(
    shader.prefixed_vertex_shader()[767:800].to_owned(),
    "#define CLEARCOAT_NORMALMAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.clearcoat = 1.0
  raw.clearcoat_normal_map = Some(normal_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.clearcoat = 1.0
  basic.clearcoat_normal_map = Some(normal_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes CLEARCOAT_ROUGHNESSMAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let roughness_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(roughness_map.channel, 0)
  shader.clearcoat_roughness_map = Some(roughness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.clearcoat = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1680)
  assert_eq(shader.prefixed_fragment_shader().length(), 2098)
  assert_eq(1680 - 1608, 72)
  assert_eq(
    shader.prefixed_vertex_shader()[718:754].to_owned(),
    "#define CLEARCOAT_ROUGHNESSMAP_UV uv",
  )
  roughness_map.channel = 1
  shader.clearcoat_roughness_map = Some(roughness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1697)
  assert_eq(shader.prefixed_fragment_shader().length(), 2114)
  assert_eq(1697 - 1608, 89)
  assert_eq(
    shader.prefixed_vertex_shader()[718:755].to_owned(),
    "#define CLEARCOAT_ROUGHNESSMAP_UV uv1",
  )
  shader.clearcoat = 0.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.clearcoat = 1.0
  roughness_map.channel = 0
  shader.clearcoat_roughness_map = Some(roughness_map)
  let normal_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.clearcoat_normal_map = Some(normal_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1746)
  assert_eq(
    shader.prefixed_vertex_shader()[784:820].to_owned(),
    "#define CLEARCOAT_ROUGHNESSMAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.clearcoat = 1.0
  raw.clearcoat_roughness_map = Some(roughness_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.clearcoat = 1.0
  basic.clearcoat_roughness_map = Some(roughness_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes IRIDESCENCEMAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let iridescence_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(iridescence_map.channel, 0)
  shader.iridescence_map = Some(iridescence_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.iridescence = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1664)
  assert_eq(shader.prefixed_fragment_shader().length(), 2068)
  assert_eq(1664 - 1608, 56)
  assert_eq(
    shader.prefixed_vertex_shader()[710:738].to_owned(),
    "#define IRIDESCENCEMAP_UV uv",
  )
  iridescence_map.channel = 1
  shader.iridescence_map = Some(iridescence_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1681)
  assert_eq(shader.prefixed_fragment_shader().length(), 2084)
  assert_eq(1681 - 1608, 73)
  assert_eq(
    shader.prefixed_vertex_shader()[710:739].to_owned(),
    "#define IRIDESCENCEMAP_UV uv1",
  )
  shader.iridescence = 0.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.iridescence = 1.0
  iridescence_map.channel = 0
  shader.iridescence_map = Some(iridescence_map)
  let roughness_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.clearcoat = 1.0
  shader.clearcoat_roughness_map = Some(roughness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1736)
  assert_eq(
    shader.prefixed_vertex_shader()[782:810].to_owned(),
    "#define IRIDESCENCEMAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.iridescence = 1.0
  raw.iridescence_map = Some(iridescence_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.iridescence = 1.0
  basic.iridescence_map = Some(iridescence_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes IRIDESCENCE_THICKNESSMAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let thickness_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(thickness_map.channel, 0)
  shader.iridescence_thickness_map = Some(thickness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.iridescence = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1684)
  assert_eq(shader.prefixed_fragment_shader().length(), 2078)
  assert_eq(1684 - 1608, 76)
  assert_eq(
    shader.prefixed_vertex_shader()[720:758].to_owned(),
    "#define IRIDESCENCE_THICKNESSMAP_UV uv",
  )
  thickness_map.channel = 1
  shader.iridescence_thickness_map = Some(thickness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1701)
  assert_eq(shader.prefixed_fragment_shader().length(), 2094)
  assert_eq(1701 - 1608, 93)
  assert_eq(
    shader.prefixed_vertex_shader()[720:759].to_owned(),
    "#define IRIDESCENCE_THICKNESSMAP_UV uv1",
  )
  shader.iridescence = 0.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.iridescence = 1.0
  thickness_map.channel = 0
  shader.iridescence_thickness_map = Some(thickness_map)
  let iridescence_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.iridescence_map = Some(iridescence_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1740)
  assert_eq(
    shader.prefixed_vertex_shader()[776:814].to_owned(),
    "#define IRIDESCENCE_THICKNESSMAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.iridescence = 1.0
  raw.iridescence_thickness_map = Some(thickness_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.iridescence = 1.0
  basic.iridescence_thickness_map = Some(thickness_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes SHEEN_COLORMAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let sheen_color_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(sheen_color_map.channel, 0)
  shader.sheen_color_map = Some(sheen_color_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.sheen = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1664)
  assert_eq(shader.prefixed_fragment_shader().length(), 2068)
  assert_eq(1664 - 1608, 56)
  assert_eq(
    shader.prefixed_vertex_shader()[710:738].to_owned(),
    "#define SHEEN_COLORMAP_UV uv",
  )
  sheen_color_map.channel = 1
  shader.sheen_color_map = Some(sheen_color_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1681)
  assert_eq(shader.prefixed_fragment_shader().length(), 2084)
  assert_eq(1681 - 1608, 73)
  assert_eq(
    shader.prefixed_vertex_shader()[710:739].to_owned(),
    "#define SHEEN_COLORMAP_UV uv1",
  )
  shader.sheen = 0.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.sheen = 1.0
  sheen_color_map.channel = 0
  shader.sheen_color_map = Some(sheen_color_map)
  let thickness_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.iridescence = 1.0
  shader.iridescence_thickness_map = Some(thickness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1740)
  assert_eq(
    shader.prefixed_vertex_shader()[786:814].to_owned(),
    "#define SHEEN_COLORMAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.sheen = 1.0
  raw.sheen_color_map = Some(sheen_color_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.sheen = 1.0
  basic.sheen_color_map = Some(sheen_color_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes SHEEN_ROUGHNESSMAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let sheen_roughness_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(sheen_roughness_map.channel, 0)
  shader.sheen_roughness_map = Some(sheen_roughness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.sheen = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1672)
  assert_eq(shader.prefixed_fragment_shader().length(), 2072)
  assert_eq(1672 - 1608, 64)
  assert_eq(
    shader.prefixed_vertex_shader()[714:746].to_owned(),
    "#define SHEEN_ROUGHNESSMAP_UV uv",
  )
  sheen_roughness_map.channel = 1
  shader.sheen_roughness_map = Some(sheen_roughness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1689)
  assert_eq(shader.prefixed_fragment_shader().length(), 2088)
  assert_eq(1689 - 1608, 81)
  assert_eq(
    shader.prefixed_vertex_shader()[714:747].to_owned(),
    "#define SHEEN_ROUGHNESSMAP_UV uv1",
  )
  shader.sheen = 0.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.sheen = 1.0
  sheen_roughness_map.channel = 0
  shader.sheen_roughness_map = Some(sheen_roughness_map)
  let sheen_color_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.sheen_color_map = Some(sheen_color_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1728)
  assert_eq(
    shader.prefixed_vertex_shader()[770:802].to_owned(),
    "#define SHEEN_ROUGHNESSMAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.sheen = 1.0
  raw.sheen_roughness_map = Some(sheen_roughness_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.sheen = 1.0
  basic.sheen_roughness_map = Some(sheen_roughness_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes SPECULARMAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let specular_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(specular_map.channel, 0)
  shader.specular_map = Some(specular_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1658)
  assert_eq(shader.prefixed_fragment_shader().length(), 2065)
  assert_eq(1658 - 1608, 50)
  assert_eq(
    shader.prefixed_vertex_shader()[707:732].to_owned(),
    "#define SPECULARMAP_UV uv",
  )
  specular_map.channel = 1
  shader.specular_map = Some(specular_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1675)
  assert_eq(shader.prefixed_fragment_shader().length(), 2081)
  assert_eq(1675 - 1608, 67)
  assert_eq(
    shader.prefixed_vertex_shader()[707:733].to_owned(),
    "#define SPECULARMAP_UV uv1",
  )
  specular_map.channel = 0
  shader.specular_map = Some(specular_map)
  let sheen_roughness_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.sheen = 1.0
  shader.sheen_roughness_map = Some(sheen_roughness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1722)
  assert_eq(
    shader.prefixed_vertex_shader()[771:796].to_owned(),
    "#define SPECULARMAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.specular_map = Some(specular_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.specular_map = Some(specular_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes SPECULAR_COLORMAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let specular_color_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(specular_color_map.channel, 0)
  shader.specular_color_map = Some(specular_color_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1670)
  assert_eq(shader.prefixed_fragment_shader().length(), 2071)
  assert_eq(1670 - 1608, 62)
  assert_eq(
    shader.prefixed_vertex_shader()[713:744].to_owned(),
    "#define SPECULAR_COLORMAP_UV uv",
  )
  specular_color_map.channel = 1
  shader.specular_color_map = Some(specular_color_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1687)
  assert_eq(shader.prefixed_fragment_shader().length(), 2087)
  assert_eq(1687 - 1608, 79)
  assert_eq(
    shader.prefixed_vertex_shader()[713:745].to_owned(),
    "#define SPECULAR_COLORMAP_UV uv1",
  )
  specular_color_map.channel = 0
  shader.specular_color_map = Some(specular_color_map)
  let specular_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.specular_map = Some(specular_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1720)
  assert_eq(
    shader.prefixed_vertex_shader()[763:794].to_owned(),
    "#define SPECULAR_COLORMAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.specular_color_map = Some(specular_color_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.specular_color_map = Some(specular_color_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes SPECULAR_INTENSITYMAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let specular_intensity_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(specular_intensity_map.channel, 0)
  shader.specular_intensity_map = Some(specular_intensity_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1678)
  assert_eq(shader.prefixed_fragment_shader().length(), 2075)
  assert_eq(1678 - 1608, 70)
  assert_eq(
    shader.prefixed_vertex_shader()[717:752].to_owned(),
    "#define SPECULAR_INTENSITYMAP_UV uv",
  )
  specular_intensity_map.channel = 1
  shader.specular_intensity_map = Some(specular_intensity_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1695)
  assert_eq(shader.prefixed_fragment_shader().length(), 2091)
  assert_eq(1695 - 1608, 87)
  assert_eq(
    shader.prefixed_vertex_shader()[717:753].to_owned(),
    "#define SPECULAR_INTENSITYMAP_UV uv1",
  )
  specular_intensity_map.channel = 0
  shader.specular_intensity_map = Some(specular_intensity_map)
  let specular_color_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.specular_color_map = Some(specular_color_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1740)
  assert_eq(
    shader.prefixed_vertex_shader()[779:814].to_owned(),
    "#define SPECULAR_INTENSITYMAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.specular_intensity_map = Some(specular_intensity_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.specular_intensity_map = Some(specular_intensity_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes TRANSMISSIONMAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let transmission_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(transmission_map.channel, 0)
  shader.transmission_map = Some(transmission_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.transmission = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1691)
  assert_eq(shader.prefixed_fragment_shader().length(), 2094)
  assert_eq(1691 - 1608, 83)
  assert_eq(
    shader.prefixed_vertex_shader()[736:765].to_owned(),
    "#define TRANSMISSIONMAP_UV uv",
  )
  transmission_map.channel = 1
  shader.transmission_map = Some(transmission_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1708)
  assert_eq(shader.prefixed_fragment_shader().length(), 2110)
  assert_eq(1708 - 1608, 100)
  assert_eq(
    shader.prefixed_vertex_shader()[736:766].to_owned(),
    "#define TRANSMISSIONMAP_UV uv1",
  )
  shader.transmission = 0.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.transmission = 1.0
  transmission_map.channel = 0
  shader.transmission_map = Some(transmission_map)
  let specular_intensity_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.specular_intensity_map = Some(specular_intensity_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1761)
  assert_eq(
    shader.prefixed_vertex_shader()[806:835].to_owned(),
    "#define TRANSMISSIONMAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.transmission = 1.0
  raw.transmission_map = Some(transmission_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.transmission = 1.0
  basic.transmission_map = Some(transmission_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes THICKNESSMAP_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let thickness_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(thickness_map.channel, 0)
  shader.thickness_map = Some(thickness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.transmission = 1.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1685)
  assert_eq(shader.prefixed_fragment_shader().length(), 2091)
  assert_eq(1685 - 1608, 77)
  assert_eq(
    shader.prefixed_vertex_shader()[733:759].to_owned(),
    "#define THICKNESSMAP_UV uv",
  )
  thickness_map.channel = 1
  shader.thickness_map = Some(thickness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1702)
  assert_eq(shader.prefixed_fragment_shader().length(), 2107)
  assert_eq(1702 - 1608, 94)
  assert_eq(
    shader.prefixed_vertex_shader()[733:760].to_owned(),
    "#define THICKNESSMAP_UV uv1",
  )
  shader.transmission = 0.0
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.transmission = 1.0
  thickness_map.channel = 0
  shader.thickness_map = Some(thickness_map)
  let transmission_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.transmission_map = Some(transmission_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1743)
  assert_eq(
    shader.prefixed_vertex_shader()[791:817].to_owned(),
    "#define THICKNESSMAP_UV uv",
  )
  let raw = @materials.Material::raw()
  raw.transmission = 1.0
  raw.thickness_map = Some(thickness_map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.transmission = 1.0
  basic.thickness_map = Some(thickness_map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_TANGENT" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let normal_map = @textures.Texture::from_rgba8(1, 1, pixels)
  assert_eq(shader.prefixed_vertex_shader(has_tangent=true).length(), 1608)
  assert_eq(shader.prefixed_fragment_shader(has_tangent=true).length(), 2041)
  shader.normal_map = Some(normal_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1689)
  assert_eq(shader.prefixed_fragment_shader().length(), 2098)
  assert_eq(shader.prefixed_vertex_shader(has_tangent=true).length(), 1709)
  assert_eq(shader.prefixed_fragment_shader(has_tangent=true).length(), 2118)
  assert_eq(1709 - 1689, 20)
  assert_eq(
    shader.prefixed_vertex_shader(has_tangent=true)[764:783].to_owned(),
    "#define USE_TANGENT",
  )
  assert_eq(
    shader.prefixed_fragment_shader(has_tangent=true)[1136:1155].to_owned(),
    "#define USE_TANGENT",
  )
  shader.normal_map = None
  shader.anisotropy = 1.0
  assert_eq(shader.prefixed_vertex_shader(has_tangent=true).length(), 1651)
  assert_eq(shader.prefixed_fragment_shader(has_tangent=true).length(), 2084)
  assert_eq(
    shader.prefixed_vertex_shader(has_tangent=true)[706:725].to_owned(),
    "#define USE_TANGENT",
  )
  assert_eq(
    shader.prefixed_fragment_shader(has_tangent=true)[1102:1121].to_owned(),
    "#define USE_TANGENT",
  )
  shader.anisotropy = 0.0
  assert_eq(shader.prefixed_vertex_shader(has_tangent=true).length(), 1608)
  shader.normal_map = Some(normal_map)
  shader.flat_shading = true
  assert_eq(shader.prefixed_vertex_shader(has_tangent=true).length(), 1709)
  assert_eq(shader.prefixed_fragment_shader(has_tangent=true).length(), 2118)
  assert_eq(
    shader.prefixed_vertex_shader(has_tangent=true)[764:783].to_owned(),
    "#define FLAT_SHADED",
  )
  assert_eq(
    shader.prefixed_fragment_shader(has_tangent=true)[1136:1155].to_owned(),
    "#define FLAT_SHADED",
  )
  shader.wireframe = true
  assert_eq(shader.prefixed_vertex_shader(has_tangent=true).length(), 1709)
  assert_eq(shader.prefixed_fragment_shader(has_tangent=true).length(), 2118)
  assert_eq(
    shader.prefixed_vertex_shader(has_tangent=true)[764:783].to_owned(),
    "#define USE_TANGENT",
  )
  shader.wireframe = false
  shader.flat_shading = false
  shader.normal_map = None
  shader.anisotropy = 1.0
  shader.transmission = 1.0
  let thickness_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.thickness_map = Some(thickness_map)
  assert_eq(shader.prefixed_vertex_shader(has_tangent=true).length(), 1728)
  assert_eq(
    shader.prefixed_vertex_shader(has_tangent=true)[783:802].to_owned(),
    "#define USE_TANGENT",
  )
  assert_eq(shader.prefixed_fragment_shader(has_tangent=true).length(), 2134)
  assert_eq(
    shader.prefixed_fragment_shader(has_tangent=true)[1152:1171].to_owned(),
    "#define USE_TANGENT",
  )
  let raw = @materials.Material::raw()
  raw.anisotropy = 1.0
  assert_eq(raw.prefixed_vertex_shader(has_tangent=true).length(), 92)
  let basic = @materials.Material::basic()
  basic.anisotropy = 1.0
  assert_eq(basic.prefixed_vertex_shader(has_tangent=true), "")
}

///|
test "Material shader writes HAS_NORMAL" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader(has_normal=false).length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_vertex_shader(has_normal=true).length(), 1627)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(1627 - 1608, 19)
  assert_eq(
    shader.prefixed_vertex_shader(has_normal=true)[683:701].to_owned(),
    "#define HAS_NORMAL",
  )
  shader.anisotropy = 1.0
  assert_eq(
    shader.prefixed_vertex_shader(has_tangent=true, has_normal=true).length(),
    1670,
  )
  assert_eq(
    shader.prefixed_vertex_shader(has_tangent=true, has_normal=true)[726:744].to_owned(),
    "#define HAS_NORMAL",
  )
  assert_eq(shader.prefixed_fragment_shader(has_tangent=true).length(), 2084)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_vertex_shader(has_normal=true).length(), 92)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_vertex_shader(has_normal=true), "")
}

///|
test "Material shader writes USE_COLOR" {
  let shader = @materials.Material::shader()
  assert_eq(shader.vertex_colors, false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.vertex_colors = true
  assert_eq(shader.prefixed_vertex_shader().length(), 1626)
  assert_eq(shader.prefixed_fragment_shader().length(), 2059)
  assert_eq(1626 - 1608, 18)
  assert_eq(shader.prefixed_vertex_shader()[683:700].to_owned(), "#define USE_COLOR")
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1096].to_owned(),
    "#define USE_COLOR",
  )
  shader.vertex_colors = false
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.vertex_colors = true
  assert_eq(shader.prefixed_vertex_shader(has_normal=true).length(), 1645)
  assert_eq(
    shader.prefixed_vertex_shader(has_normal=true)[702:719].to_owned(),
    "#define USE_COLOR",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2059)
  let raw = @materials.Material::raw()
  raw.vertex_colors = true
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.vertex_colors = true
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_COLOR_ALPHA" {
  let shader = @materials.Material::shader()
  shader.vertex_colors = true
  assert_eq(shader.prefixed_vertex_shader().length(), 1626)
  assert_eq(shader.prefixed_fragment_shader().length(), 2059)
  assert_eq(shader.prefixed_vertex_shader(has_vertex_alpha=true).length(), 1650)
  assert_eq(shader.prefixed_fragment_shader(has_vertex_alpha=true).length(), 2083)
  assert_eq(1650 - 1626, 24)
  assert_eq(
    shader.prefixed_vertex_shader(has_vertex_alpha=true)[701:724].to_owned(),
    "#define USE_COLOR_ALPHA",
  )
  assert_eq(
    shader.prefixed_fragment_shader(has_vertex_alpha=true)[1097:1120].to_owned(),
    "#define USE_COLOR_ALPHA",
  )
  shader.vertex_colors = false
  assert_eq(shader.prefixed_vertex_shader(has_vertex_alpha=true).length(), 1608)
  assert_eq(shader.prefixed_fragment_shader(has_vertex_alpha=true).length(), 2041)
  shader.vertex_colors = true
  assert_eq(
    shader.prefixed_vertex_shader(has_normal=true, has_vertex_alpha=true).length(),
    1669,
  )
  assert_eq(
    shader.prefixed_vertex_shader(has_normal=true, has_vertex_alpha=true)[720:743].to_owned(),
    "#define USE_COLOR_ALPHA",
  )
  assert_eq(shader.prefixed_fragment_shader(has_vertex_alpha=true).length(), 2083)
  let raw = @materials.Material::raw()
  raw.vertex_colors = true
  assert_eq(raw.prefixed_vertex_shader(has_vertex_alpha=true).length(), 92)
  let basic = @materials.Material::basic()
  basic.vertex_colors = true
  assert_eq(basic.prefixed_vertex_shader(has_vertex_alpha=true), "")
}

///|
test "Material shader writes USE_UV1" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1642)
  assert_eq(shader.prefixed_fragment_shader().length(), 2057)
  map.channel = 1
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1659)
  assert_eq(shader.prefixed_fragment_shader().length(), 2073)
  assert_eq(1659 - 1643, 16)
  assert_eq(
    shader.prefixed_vertex_shader()[718:733].to_owned(),
    "#define USE_UV1",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1095:1110].to_owned(),
    "#define USE_UV1",
  )
  map.channel = 2
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1659)
  assert_eq(shader.prefixed_fragment_shader().length(), 2073)
  map.channel = 1
  shader.map = Some(map)
  shader.vertex_colors = true
  assert_eq(
    shader.prefixed_vertex_shader(has_vertex_alpha=true).length(),
    1701,
  )
  assert_eq(
    shader.prefixed_vertex_shader(has_vertex_alpha=true)[760:775].to_owned(),
    "#define USE_UV1",
  )
  assert_eq(shader.prefixed_fragment_shader(has_vertex_alpha=true).length(), 2115)
  assert_eq(
    shader.prefixed_fragment_shader(has_vertex_alpha=true)[1137:1152].to_owned(),
    "#define USE_UV1",
  )
  let raw = @materials.Material::raw()
  raw.map = Some(map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.map = Some(map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_UV2" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1642)
  assert_eq(shader.prefixed_fragment_shader().length(), 2057)
  map.channel = 2
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1659)
  assert_eq(shader.prefixed_fragment_shader().length(), 2073)
  assert_eq(1659 - 1643, 16)
  assert_eq(
    shader.prefixed_vertex_shader()[718:733].to_owned(),
    "#define USE_UV2",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1095:1110].to_owned(),
    "#define USE_UV2",
  )
  map.channel = 3
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1659)
  assert_eq(shader.prefixed_fragment_shader().length(), 2073)
  map.channel = 2
  shader.map = Some(map)
  let alpha_map = @textures.Texture::from_rgba8(1, 1, pixels)
  alpha_map.channel = 1
  shader.alpha_map = Some(alpha_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1720)
  assert_eq(
    shader.prefixed_vertex_shader()[779:794].to_owned(),
    "#define USE_UV2",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2110)
  assert_eq(
    shader.prefixed_fragment_shader()[1132:1147].to_owned(),
    "#define USE_UV2",
  )
  let raw = @materials.Material::raw()
  raw.map = Some(map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.map = Some(map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_UV3" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1642)
  assert_eq(shader.prefixed_fragment_shader().length(), 2057)
  map.channel = 3
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1659)
  assert_eq(shader.prefixed_fragment_shader().length(), 2073)
  assert_eq(1659 - 1643, 16)
  assert_eq(
    shader.prefixed_vertex_shader()[718:733].to_owned(),
    "#define USE_UV3",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1095:1110].to_owned(),
    "#define USE_UV3",
  )
  map.channel = 4
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1643)
  assert_eq(shader.prefixed_fragment_shader().length(), 2057)
  map.channel = 3
  shader.map = Some(map)
  let alpha_map = @textures.Texture::from_rgba8(1, 1, pixels)
  alpha_map.channel = 2
  shader.alpha_map = Some(alpha_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1720)
  assert_eq(
    shader.prefixed_vertex_shader()[779:794].to_owned(),
    "#define USE_UV3",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2110)
  assert_eq(
    shader.prefixed_fragment_shader()[1132:1147].to_owned(),
    "#define USE_UV3",
  )
  let raw = @materials.Material::raw()
  raw.map = Some(map)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.map = Some(map)
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_POINTS_UV" {
  let shader = @materials.Material::shader()
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1642)
  assert_eq(shader.prefixed_fragment_shader().length(), 2057)
  assert_eq(shader.prefixed_vertex_shader(has_points_uv=true).length(), 1664)
  assert_eq(shader.prefixed_fragment_shader(has_points_uv=true).length(), 2079)
  assert_eq(1664 - 1642, 22)
  assert_eq(
    shader.prefixed_vertex_shader(has_points_uv=true)[717:738].to_owned(),
    "#define USE_POINTS_UV",
  )
  assert_eq(
    shader.prefixed_fragment_shader(has_points_uv=true)[1095:1116].to_owned(),
    "#define USE_POINTS_UV",
  )
  shader.map = None
  assert_eq(shader.prefixed_vertex_shader(has_points_uv=true).length(), 1608)
  assert_eq(shader.prefixed_fragment_shader(has_points_uv=true).length(), 2041)
  let alpha_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.alpha_map = Some(alpha_map)
  assert_eq(shader.prefixed_vertex_shader(has_points_uv=true).length(), 1674)
  assert_eq(
    shader.prefixed_vertex_shader(has_points_uv=true)[727:748].to_owned(),
    "#define USE_POINTS_UV",
  )
  assert_eq(shader.prefixed_fragment_shader(has_points_uv=true).length(), 2084)
  assert_eq(
    shader.prefixed_fragment_shader(has_points_uv=true)[1100:1121].to_owned(),
    "#define USE_POINTS_UV",
  )
  shader.alpha_map = None
  map.channel = 3
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader(has_points_uv=true).length(), 1681)
  assert_eq(
    shader.prefixed_vertex_shader(has_points_uv=true)[734:755].to_owned(),
    "#define USE_POINTS_UV",
  )
  assert_eq(shader.prefixed_fragment_shader(has_points_uv=true).length(), 2095)
  assert_eq(
    shader.prefixed_fragment_shader(has_points_uv=true)[1111:1132].to_owned(),
    "#define USE_POINTS_UV",
  )
  let raw = @materials.Material::raw()
  raw.map = Some(map)
  assert_eq(raw.prefixed_vertex_shader(has_points_uv=true).length(), 92)
  let basic = @materials.Material::basic()
  basic.map = Some(map)
  assert_eq(basic.prefixed_vertex_shader(has_points_uv=true), "")
}

///|
test "Material shader writes FLAT_SHADED" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.flat_shading = true
  assert_eq(shader.prefixed_vertex_shader().length(), 1628)
  assert_eq(shader.prefixed_fragment_shader().length(), 2061)
  assert_eq(1628 - 1608, 20)
  assert_eq(shader.prefixed_vertex_shader()[683:702].to_owned(), "#define FLAT_SHADED")
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1098].to_owned(),
    "#define FLAT_SHADED",
  )
  shader.wireframe = true
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.wireframe = false
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader(has_points_uv=true).length(), 1684)
  assert_eq(
    shader.prefixed_vertex_shader(has_points_uv=true)[739:758].to_owned(),
    "#define FLAT_SHADED",
  )
  assert_eq(shader.prefixed_fragment_shader(has_points_uv=true).length(), 2099)
  assert_eq(
    shader.prefixed_fragment_shader(has_points_uv=true)[1117:1136].to_owned(),
    "#define FLAT_SHADED",
  )
  shader.flat_shading = false
  assert_eq(shader.prefixed_vertex_shader(has_points_uv=true).length(), 1664)
  assert_eq(shader.prefixed_fragment_shader(has_points_uv=true).length(), 2079)
  let raw = @materials.Material::raw()
  raw.flat_shading = true
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.flat_shading = true
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_SKINNING" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_vertex_shader(has_skinning=true).length(), 1629)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(1629 - 1608, 21)
  assert_eq(
    shader.prefixed_vertex_shader(has_skinning=true)[683:703].to_owned(),
    "#define USE_SKINNING",
  )
  shader.flat_shading = true
  assert_eq(shader.prefixed_vertex_shader(has_skinning=true).length(), 1649)
  assert_eq(
    shader.prefixed_vertex_shader(has_skinning=true)[703:723].to_owned(),
    "#define USE_SKINNING",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2061)
  shader.flat_shading = false
  assert_eq(shader.prefixed_vertex_shader(has_skinning=false).length(), 1608)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_vertex_shader(has_skinning=true).length(), 92)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_vertex_shader(has_skinning=true), "")
}

///|
test "Material shader writes USE_MORPHTARGETS" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_vertex_shader(has_morph_targets=true).length(), 1633)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(1633 - 1608, 25)
  assert_eq(
    shader.prefixed_vertex_shader(has_morph_targets=true)[683:707].to_owned(),
    "#define USE_MORPHTARGETS",
  )
  assert_eq(shader.prefixed_vertex_shader(has_skinning=true, has_morph_targets=true).length(), 1654)
  assert_eq(
    shader.prefixed_vertex_shader(has_skinning=true, has_morph_targets=true)[704:728].to_owned(),
    "#define USE_MORPHTARGETS",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_vertex_shader(has_morph_targets=false).length(), 1608)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_vertex_shader(has_morph_targets=true).length(), 92)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_vertex_shader(has_morph_targets=true), "")
}

///|
test "Material shader writes USE_MORPHNORMALS" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_vertex_shader(has_morph_normals=true).length(), 1633)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(1633 - 1608, 25)
  assert_eq(
    shader.prefixed_vertex_shader(has_morph_normals=true)[683:707].to_owned(),
    "#define USE_MORPHNORMALS",
  )
  shader.flat_shading = true
  assert_eq(shader.prefixed_vertex_shader(has_morph_normals=true).length(), 1628)
  assert_eq(shader.prefixed_fragment_shader().length(), 2061)
  shader.wireframe = true
  assert_eq(shader.prefixed_vertex_shader(has_morph_normals=true).length(), 1633)
  assert_eq(
    shader.prefixed_vertex_shader(has_morph_normals=true)[683:707].to_owned(),
    "#define USE_MORPHNORMALS",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.wireframe = false
  shader.flat_shading = false
  assert_eq(
    shader.prefixed_vertex_shader(has_morph_targets=true, has_morph_normals=true).length(),
    1658,
  )
  assert_eq(
    shader.prefixed_vertex_shader(has_morph_targets=true, has_morph_normals=true)[708:732].to_owned(),
    "#define USE_MORPHNORMALS",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_vertex_shader(has_morph_normals=false).length(), 1608)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_vertex_shader(has_morph_normals=true).length(), 92)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_vertex_shader(has_morph_normals=true), "")
}

///|
test "Material shader writes USE_MORPHCOLORS" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_vertex_shader(has_morph_colors=true).length(), 1632)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(1632 - 1608, 24)
  assert_eq(
    shader.prefixed_vertex_shader(has_morph_colors=true)[683:706].to_owned(),
    "#define USE_MORPHCOLORS",
  )
  assert_eq(
    shader.prefixed_vertex_shader(has_morph_normals=true, has_morph_colors=true).length(),
    1657,
  )
  assert_eq(
    shader.prefixed_vertex_shader(has_morph_normals=true, has_morph_colors=true)[708:731].to_owned(),
    "#define USE_MORPHCOLORS",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_vertex_shader(has_morph_colors=false).length(), 1608)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_vertex_shader(has_morph_colors=true).length(), 92)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_vertex_shader(has_morph_colors=true), "")
}

///|
test "Material shader writes MORPHTARGETS_TEXTURE_STRIDE" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.prefixed_vertex_shader(morph_targets_count=0, morph_texture_stride=1).length(),
    1608,
  )
  assert_eq(
    shader.prefixed_vertex_shader(morph_targets_count=1, morph_texture_stride=1).length(),
    1675,
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(1675 - 1608, 67)
  assert_eq(
    shader.prefixed_vertex_shader(morph_targets_count=1, morph_texture_stride=1)[683:720].to_owned(),
    "#define MORPHTARGETS_TEXTURE_STRIDE 1",
  )
  assert_eq(
    shader.prefixed_vertex_shader(morph_targets_count=2, morph_texture_stride=1)[683:720].to_owned(),
    "#define MORPHTARGETS_TEXTURE_STRIDE 1",
  )
  assert_eq(
    shader.prefixed_vertex_shader(morph_targets_count=1, morph_texture_stride=3)[683:720].to_owned(),
    "#define MORPHTARGETS_TEXTURE_STRIDE 3",
  )
  assert_eq(
    shader.prefixed_vertex_shader(
      has_morph_colors=true,
      morph_targets_count=1,
      morph_texture_stride=1,
    ).length(),
    1699,
  )
  assert_eq(
    shader.prefixed_vertex_shader(
      has_morph_colors=true,
      morph_targets_count=1,
      morph_texture_stride=1,
    )[707:744].to_owned(),
    "#define MORPHTARGETS_TEXTURE_STRIDE 1",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_vertex_shader(morph_targets_count=1, morph_texture_stride=1).length(), 92)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_vertex_shader(morph_targets_count=1, morph_texture_stride=1), "")
}

///|
test "Material shader writes MORPHTARGETS_COUNT" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader(morph_targets_count=0).length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.prefixed_vertex_shader(morph_targets_count=1, morph_texture_stride=1).length(),
    1675,
  )
  assert_eq(1675 - 1646, 29)
  assert_eq(
    shader.prefixed_vertex_shader(morph_targets_count=1, morph_texture_stride=1)[721:749].to_owned(),
    "#define MORPHTARGETS_COUNT 1",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.prefixed_vertex_shader(morph_targets_count=2, morph_texture_stride=1)[721:749].to_owned(),
    "#define MORPHTARGETS_COUNT 2",
  )
  assert_eq(
    shader.prefixed_vertex_shader(morph_targets_count=10, morph_texture_stride=1).length(),
    1676,
  )
  assert_eq(
    shader.prefixed_vertex_shader(morph_targets_count=10, morph_texture_stride=1)[721:750].to_owned(),
    "#define MORPHTARGETS_COUNT 10",
  )
  assert_eq(
    shader.prefixed_vertex_shader(
      has_morph_colors=true,
      morph_targets_count=1,
      morph_texture_stride=1,
    ).length(),
    1699,
  )
  assert_eq(
    shader.prefixed_vertex_shader(
      has_morph_colors=true,
      morph_targets_count=1,
      morph_texture_stride=1,
    )[745:773].to_owned(),
    "#define MORPHTARGETS_COUNT 1",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_vertex_shader(morph_targets_count=1).length(), 92)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_vertex_shader(morph_targets_count=1), "")
}

///|
test "Material shader writes DOUBLE_SIDED" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.side = @constants.Double
  assert_eq(shader.prefixed_vertex_shader().length(), 1629)
  assert_eq(shader.prefixed_fragment_shader().length(), 2062)
  assert_eq(1629 - 1608, 21)
  assert_eq(shader.prefixed_vertex_shader()[683:703].to_owned(), "#define DOUBLE_SIDED")
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1099].to_owned(),
    "#define DOUBLE_SIDED",
  )
  shader.side = @constants.Back
  assert_eq(shader.prefixed_vertex_shader().length(), 1627)
  assert_eq(shader.prefixed_fragment_shader().length(), 2060)
  shader.side = @constants.Front
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.side = @constants.Double
  assert_eq(
    shader.prefixed_vertex_shader(morph_targets_count=1, morph_texture_stride=1).length(),
    1696,
  )
  assert_eq(
    shader.prefixed_vertex_shader(morph_targets_count=1, morph_texture_stride=1)[750:770].to_owned(),
    "#define DOUBLE_SIDED",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2062)
  let raw = @materials.Material::raw()
  raw.side = @constants.Double
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.side = @constants.Double
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes FLIP_SIDED" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.side = @constants.Back
  assert_eq(shader.prefixed_vertex_shader().length(), 1627)
  assert_eq(shader.prefixed_fragment_shader().length(), 2060)
  assert_eq(1627 - 1608, 19)
  assert_eq(shader.prefixed_vertex_shader()[683:701].to_owned(), "#define FLIP_SIDED")
  assert_eq(shader.prefixed_fragment_shader()[1079:1097].to_owned(), "#define FLIP_SIDED")
  shader.side = @constants.Front
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.side = @constants.Double
  assert_eq(shader.prefixed_vertex_shader().length(), 1629)
  assert_eq(shader.prefixed_fragment_shader().length(), 2062)
  shader.side = @constants.Back
  assert_eq(
    shader.prefixed_vertex_shader(morph_targets_count=1, morph_texture_stride=1).length(),
    1694,
  )
  assert_eq(
    shader.prefixed_vertex_shader(morph_targets_count=1, morph_texture_stride=1)[750:768].to_owned(),
    "#define FLIP_SIDED",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2060)
  let raw = @materials.Material::raw()
  raw.side = @constants.Back
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.side = @constants.Back
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_SHADOWMAP" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_vertex_shader(shadow_map_enabled=true).length(), 1659)
  assert_eq(shader.prefixed_fragment_shader(shadow_map_enabled=true).length(), 2092)
  assert_eq(1659 - 1608, 51)
  assert_eq(
    shader.prefixed_vertex_shader(shadow_map_enabled=true)[683:704].to_owned(),
    "#define USE_SHADOWMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader(shadow_map_enabled=true)[1079:1100].to_owned(),
    "#define USE_SHADOWMAP",
  )
  shader.side = @constants.Back
  assert_eq(shader.prefixed_vertex_shader(shadow_map_enabled=true).length(), 1678)
  assert_eq(
    shader.prefixed_vertex_shader(shadow_map_enabled=true)[702:723].to_owned(),
    "#define USE_SHADOWMAP",
  )
  assert_eq(shader.prefixed_fragment_shader(shadow_map_enabled=true).length(), 2111)
  assert_eq(
    shader.prefixed_fragment_shader(shadow_map_enabled=true)[1098:1119].to_owned(),
    "#define USE_SHADOWMAP",
  )
  assert_eq(shader.prefixed_vertex_shader(shadow_map_enabled=false).length(), 1627)
  assert_eq(shader.prefixed_fragment_shader(shadow_map_enabled=false).length(), 2060)
  let raw = @materials.Material::raw()
  raw.side = @constants.Back
  assert_eq(raw.prefixed_vertex_shader(shadow_map_enabled=true).length(), 92)
  let basic = @materials.Material::basic()
  basic.side = @constants.Back
  assert_eq(basic.prefixed_vertex_shader(shadow_map_enabled=true), "")
}

///|
test "Material shader writes SHADOWMAP_TYPE_BASIC" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader(shadow_map_enabled=false).length(), 1608)
  assert_eq(shader.prefixed_fragment_shader(shadow_map_enabled=false).length(), 2041)
  assert_eq(shader.prefixed_vertex_shader(shadow_map_enabled=true).length(), 1659)
  assert_eq(shader.prefixed_fragment_shader(shadow_map_enabled=true).length(), 2092)
  assert_eq(1659 - 1630, 29)
  assert_eq(
    shader.prefixed_vertex_shader(shadow_map_enabled=true)[705:733].to_owned(),
    "#define SHADOWMAP_TYPE_BASIC",
  )
  assert_eq(
    shader.prefixed_fragment_shader(shadow_map_enabled=true)[1101:1129].to_owned(),
    "#define SHADOWMAP_TYPE_BASIC",
  )
  shader.side = @constants.Back
  assert_eq(shader.prefixed_vertex_shader(shadow_map_enabled=true).length(), 1678)
  assert_eq(
    shader.prefixed_vertex_shader(shadow_map_enabled=true)[724:752].to_owned(),
    "#define SHADOWMAP_TYPE_BASIC",
  )
  assert_eq(shader.prefixed_fragment_shader(shadow_map_enabled=true).length(), 2111)
  assert_eq(
    shader.prefixed_fragment_shader(shadow_map_enabled=true)[1120:1148].to_owned(),
    "#define SHADOWMAP_TYPE_BASIC",
  )
  assert_eq(shader.prefixed_vertex_shader(shadow_map_enabled=false).length(), 1627)
  assert_eq(shader.prefixed_fragment_shader(shadow_map_enabled=false).length(), 2060)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_vertex_shader(shadow_map_enabled=true).length(), 92)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_vertex_shader(shadow_map_enabled=true), "")
}

///|
test "Material shader writes SHADOWMAP_TYPE_PCF" {
  let shader = @materials.Material::shader()
  assert_eq(
    shader.prefixed_vertex_shader(shadow_map_enabled=false, shadow_map_pcf=true).length(),
    1608,
  )
  assert_eq(
    shader.prefixed_fragment_shader(shadow_map_enabled=false, shadow_map_pcf=true).length(),
    2041,
  )
  assert_eq(
    shader.prefixed_vertex_shader(shadow_map_enabled=true, shadow_map_pcf=true).length(),
    1657,
  )
  assert_eq(
    shader.prefixed_fragment_shader(shadow_map_enabled=true, shadow_map_pcf=true).length(),
    2090,
  )
  assert_eq(1659 - 1657, 2)
  assert_eq(
    shader.prefixed_vertex_shader(shadow_map_enabled=true, shadow_map_pcf=true)[705:731].to_owned(),
    "#define SHADOWMAP_TYPE_PCF",
  )
  assert_eq(
    shader.prefixed_fragment_shader(shadow_map_enabled=true, shadow_map_pcf=true)[1101:1127].to_owned(),
    "#define SHADOWMAP_TYPE_PCF",
  )
  shader.side = @constants.Back
  assert_eq(
    shader.prefixed_vertex_shader(shadow_map_enabled=true, shadow_map_pcf=true).length(),
    1676,
  )
  assert_eq(
    shader.prefixed_vertex_shader(shadow_map_enabled=true, shadow_map_pcf=true)[724:750].to_owned(),
    "#define SHADOWMAP_TYPE_PCF",
  )
  assert_eq(
    shader.prefixed_fragment_shader(shadow_map_enabled=true, shadow_map_pcf=true).length(),
    2109,
  )
  assert_eq(
    shader.prefixed_fragment_shader(shadow_map_enabled=true, shadow_map_pcf=true)[1120:1146].to_owned(),
    "#define SHADOWMAP_TYPE_PCF",
  )
  assert_eq(
    shader.prefixed_vertex_shader(shadow_map_enabled=true, shadow_map_pcf=false).length(),
    1678,
  )
  assert_eq(
    shader.prefixed_vertex_shader(shadow_map_enabled=true, shadow_map_pcf=false)[724:752].to_owned(),
    "#define SHADOWMAP_TYPE_BASIC",
  )
  let raw = @materials.Material::raw()
  assert_eq(
    raw.prefixed_vertex_shader(shadow_map_enabled=true, shadow_map_pcf=true).length(),
    92,
  )
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_vertex_shader(shadow_map_enabled=true, shadow_map_pcf=true), "")
}

///|
test "Material shader writes SHADOWMAP_TYPE_VSM" {
  let shader = @materials.Material::shader()
  assert_eq(
    shader.prefixed_vertex_shader(shadow_map_enabled=false, shadow_map_vsm=true).length(),
    1608,
  )
  assert_eq(
    shader.prefixed_fragment_shader(shadow_map_enabled=false, shadow_map_vsm=true).length(),
    2041,
  )
  assert_eq(
    shader.prefixed_vertex_shader(shadow_map_enabled=true, shadow_map_vsm=true).length(),
    1657,
  )
  assert_eq(
    shader.prefixed_fragment_shader(shadow_map_enabled=true, shadow_map_vsm=true).length(),
    2090,
  )
  assert_eq(
    shader.prefixed_vertex_shader(shadow_map_enabled=true, shadow_map_vsm=true)[705:731].to_owned(),
    "#define SHADOWMAP_TYPE_VSM",
  )
  assert_eq(
    shader.prefixed_fragment_shader(shadow_map_enabled=true, shadow_map_vsm=true)[1101:1127].to_owned(),
    "#define SHADOWMAP_TYPE_VSM",
  )
  assert_eq(
    shader.prefixed_vertex_shader(
      shadow_map_enabled=true,
      shadow_map_pcf=true,
      shadow_map_vsm=true,
    )[705:731].to_owned(),
    "#define SHADOWMAP_TYPE_VSM",
  )
  shader.side = @constants.Back
  assert_eq(
    shader.prefixed_vertex_shader(shadow_map_enabled=true, shadow_map_vsm=true).length(),
    1676,
  )
  assert_eq(
    shader.prefixed_vertex_shader(shadow_map_enabled=true, shadow_map_vsm=true)[724:750].to_owned(),
    "#define SHADOWMAP_TYPE_VSM",
  )
  assert_eq(
    shader.prefixed_fragment_shader(shadow_map_enabled=true, shadow_map_vsm=true).length(),
    2109,
  )
  assert_eq(
    shader.prefixed_fragment_shader(shadow_map_enabled=true, shadow_map_vsm=true)[1120:1146].to_owned(),
    "#define SHADOWMAP_TYPE_VSM",
  )
  assert_eq(
    shader.prefixed_vertex_shader(shadow_map_enabled=true, shadow_map_pcf=true, shadow_map_vsm=false)[724:750].to_owned(),
    "#define SHADOWMAP_TYPE_PCF",
  )
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_vertex_shader(shadow_map_enabled=true, shadow_map_vsm=true).length(), 92)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_vertex_shader(shadow_map_enabled=true, shadow_map_vsm=true), "")
}

///|
test "Material shader writes USE_SIZEATTENUATION" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_vertex_shader(size_attenuation=true).length(), 1636)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(1636 - 1608, 28)
  assert_eq(
    shader.prefixed_vertex_shader(size_attenuation=true)[683:710].to_owned(),
    "#define USE_SIZEATTENUATION",
  )
  assert_eq(
    shader.prefixed_vertex_shader(shadow_map_enabled=true, size_attenuation=true).length(),
    1687,
  )
  assert_eq(
    shader.prefixed_vertex_shader(shadow_map_enabled=true, size_attenuation=true)[734:761].to_owned(),
    "#define USE_SIZEATTENUATION",
  )
  assert_eq(shader.prefixed_fragment_shader(shadow_map_enabled=true).length(), 2092)
  assert_eq(shader.prefixed_vertex_shader(size_attenuation=false).length(), 1608)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_vertex_shader(size_attenuation=true).length(), 92)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_vertex_shader(size_attenuation=true), "")
}

///|
test "Material shader writes USE_LIGHT_PROBES" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader(num_light_probes=0).length(), 1608)
  assert_eq(shader.prefixed_fragment_shader(num_light_probes=0).length(), 2041)
  assert_eq(shader.prefixed_vertex_shader(num_light_probes=1).length(), 1633)
  assert_eq(shader.prefixed_fragment_shader(num_light_probes=1).length(), 2066)
  assert_eq(1633 - 1608, 25)
  assert_eq(
    shader.prefixed_vertex_shader(num_light_probes=1)[683:707].to_owned(),
    "#define USE_LIGHT_PROBES",
  )
  assert_eq(
    shader.prefixed_fragment_shader(num_light_probes=1)[1079:1103].to_owned(),
    "#define USE_LIGHT_PROBES",
  )
  assert_eq(
    shader.prefixed_vertex_shader(size_attenuation=true, num_light_probes=2).length(),
    1661,
  )
  assert_eq(
    shader.prefixed_vertex_shader(size_attenuation=true, num_light_probes=2)[711:735].to_owned(),
    "#define USE_LIGHT_PROBES",
  )
  assert_eq(shader.prefixed_fragment_shader(num_light_probes=2).length(), 2066)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_vertex_shader(num_light_probes=1).length(), 92)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_vertex_shader(num_light_probes=1), "")
}

///|
test "Material shader writes USE_LOGARITHMIC_DEPTH_BUFFER" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_vertex_shader(logarithmic_depth_buffer=true).length(), 1645)
  assert_eq(shader.prefixed_fragment_shader(logarithmic_depth_buffer=true).length(), 2078)
  assert_eq(1645 - 1608, 37)
  assert_eq(
    shader.prefixed_vertex_shader(logarithmic_depth_buffer=true)[683:719].to_owned(),
    "#define USE_LOGARITHMIC_DEPTH_BUFFER",
  )
  assert_eq(
    shader.prefixed_fragment_shader(logarithmic_depth_buffer=true)[1079:1115].to_owned(),
    "#define USE_LOGARITHMIC_DEPTH_BUFFER",
  )
  assert_eq(
    shader.prefixed_vertex_shader(num_light_probes=1, logarithmic_depth_buffer=true).length(),
    1670,
  )
  assert_eq(
    shader.prefixed_vertex_shader(num_light_probes=1, logarithmic_depth_buffer=true)[708:744].to_owned(),
    "#define USE_LOGARITHMIC_DEPTH_BUFFER",
  )
  assert_eq(
    shader.prefixed_fragment_shader(num_light_probes=1, logarithmic_depth_buffer=true).length(),
    2103,
  )
  assert_eq(
    shader.prefixed_fragment_shader(num_light_probes=1, logarithmic_depth_buffer=true)[1104:1140].to_owned(),
    "#define USE_LOGARITHMIC_DEPTH_BUFFER",
  )
  assert_eq(shader.prefixed_vertex_shader(logarithmic_depth_buffer=false).length(), 1608)
  assert_eq(shader.prefixed_fragment_shader(logarithmic_depth_buffer=false).length(), 2041)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_vertex_shader(logarithmic_depth_buffer=true).length(), 92)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_vertex_shader(logarithmic_depth_buffer=true), "")
}

///|
test "Material shader writes USE_REVERSED_DEPTH_BUFFER" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_vertex_shader(reversed_depth_buffer=true).length(), 1642)
  assert_eq(shader.prefixed_fragment_shader(reversed_depth_buffer=true).length(), 2075)
  assert_eq(1642 - 1608, 34)
  assert_eq(
    shader.prefixed_vertex_shader(reversed_depth_buffer=true)[683:716].to_owned(),
    "#define USE_REVERSED_DEPTH_BUFFER",
  )
  assert_eq(
    shader.prefixed_fragment_shader(reversed_depth_buffer=true)[1079:1112].to_owned(),
    "#define USE_REVERSED_DEPTH_BUFFER",
  )
  assert_eq(
    shader.prefixed_vertex_shader(logarithmic_depth_buffer=true, reversed_depth_buffer=true).length(),
    1679,
  )
  assert_eq(
    shader.prefixed_vertex_shader(logarithmic_depth_buffer=true, reversed_depth_buffer=true)[720:753].to_owned(),
    "#define USE_REVERSED_DEPTH_BUFFER",
  )
  assert_eq(
    shader.prefixed_fragment_shader(logarithmic_depth_buffer=true, reversed_depth_buffer=true).length(),
    2112,
  )
  assert_eq(
    shader.prefixed_fragment_shader(logarithmic_depth_buffer=true, reversed_depth_buffer=true)[1116:1149].to_owned(),
    "#define USE_REVERSED_DEPTH_BUFFER",
  )
  assert_eq(shader.prefixed_vertex_shader(reversed_depth_buffer=false).length(), 1608)
  assert_eq(shader.prefixed_fragment_shader(reversed_depth_buffer=false).length(), 2041)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_vertex_shader(reversed_depth_buffer=true).length(), 92)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_vertex_shader(reversed_depth_buffer=true), "")
}

///|
test "Material shader writes TONE_MAPPING" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.Linear).length(), 7364)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(6561 - 1238, 5323)
  assert_eq(
    shader.prefixed_fragment_shader(tone_mapping=@constants.Linear)[1162:1182].to_owned(),
    "#define TONE_MAPPING",
  )
  assert_eq(
    shader.prefixed_fragment_shader(reversed_depth_buffer=true, tone_mapping=@constants.Linear).length(),
    7398,
  )
  assert_eq(
    shader.prefixed_fragment_shader(reversed_depth_buffer=true, tone_mapping=@constants.Linear)[1196:1216].to_owned(),
    "#define TONE_MAPPING",
  )
  assert_eq(shader.prefixed_vertex_shader(reversed_depth_buffer=true).length(), 1642)
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.No).length(), 2041)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_fragment_shader(tone_mapping=@constants.Linear).length(), 61)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_fragment_shader(tone_mapping=@constants.Linear), "")
}

///|
test "Material shader writes tonemapping_pars_fragment" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.No).length(), 2041)
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.Linear).length(), 7364)
  assert_eq(
    shader.prefixed_fragment_shader(tone_mapping=@constants.Linear)[1183:6414].length(),
    5231,
  )
  assert_eq(
    shader.prefixed_fragment_shader(tone_mapping=@constants.Linear)[1184:1200].to_owned(),
    "#ifndef saturate",
  )
  assert_eq(
    shader.prefixed_fragment_shader(tone_mapping=@constants.Linear)[6359:6413].to_owned(),
    "vec3 CustomToneMapping( vec3 color ) { return color; }",
  )
  assert_eq(
    shader.prefixed_fragment_shader(reversed_depth_buffer=true, tone_mapping=@constants.Linear).length(),
    7398,
  )
  assert_eq(
    shader.prefixed_fragment_shader(reversed_depth_buffer=true, tone_mapping=@constants.Linear)[1218:1234].to_owned(),
    "#ifndef saturate",
  )
  assert_eq(
    shader.prefixed_fragment_shader(reversed_depth_buffer=true, tone_mapping=@constants.Linear)[6393:6447].to_owned(),
    "vec3 CustomToneMapping( vec3 color ) { return color; }",
  )
  assert_eq(shader.prefixed_vertex_shader(reversed_depth_buffer=true).length(), 1642)
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.No).length(), 2041)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_fragment_shader(tone_mapping=@constants.Linear).length(), 61)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_fragment_shader(tone_mapping=@constants.Linear), "")
}

///|
test "Material shader writes getToneMappingFunction" {
  let shader = @materials.Material::shader()
  let linear = "vec3 toneMapping( vec3 color ) { return LinearToneMapping( color ); }"
  let reinhard = "vec3 toneMapping( vec3 color ) { return ReinhardToneMapping( color ); }"
  let cineon = "vec3 toneMapping( vec3 color ) { return CineonToneMapping( color ); }"
  let aces = "vec3 toneMapping( vec3 color ) { return ACESFilmicToneMapping( color ); }"
  let agx = "vec3 toneMapping( vec3 color ) { return AgXToneMapping( color ); }"
  let neutral = "vec3 toneMapping( vec3 color ) { return NeutralToneMapping( color ); }"
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.No).length(), 2041)
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.Linear).length(), 7364)
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.Linear)[6415:6484].to_owned(), linear)
  assert_eq(6546 - 6475, 71)
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.Reinhard).length(), 7366)
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.Reinhard)[6415:6486].to_owned(), reinhard)
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.Cineon).length(), 7364)
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.Cineon)[6415:6484].to_owned(), cineon)
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.ACES).length(), 7368)
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.ACES)[6415:6488].to_owned(), aces)
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.AgX).length(), 7361)
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.AgX)[6415:6481].to_owned(), agx)
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.Neutral).length(), 7365)
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.Neutral)[6415:6485].to_owned(), neutral)
  assert_eq(
    shader.prefixed_fragment_shader(reversed_depth_buffer=true, tone_mapping=@constants.Linear).length(),
    7398,
  )
  assert_eq(
    shader.prefixed_fragment_shader(reversed_depth_buffer=true, tone_mapping=@constants.Linear)[6449:6518].to_owned(),
    linear,
  )
  assert_eq(shader.prefixed_vertex_shader(reversed_depth_buffer=true).length(), 1642)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_fragment_shader(tone_mapping=@constants.Linear).length(), 61)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_fragment_shader(tone_mapping=@constants.ACES), "")
}

///|
test "Material shader writes DITHERING" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.dithering = true
  assert_eq(shader.prefixed_fragment_shader().length(), 2059)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(1256 - 1238, 18)
  assert_eq(shader.prefixed_fragment_shader()[1162:1179].to_owned(), "#define DITHERING")
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.Linear).length(), 7382)
  assert_eq(
    shader.prefixed_fragment_shader(tone_mapping=@constants.Linear)[6485:6502].to_owned(),
    "#define DITHERING",
  )
  assert_eq(
    shader.prefixed_fragment_shader(reversed_depth_buffer=true, tone_mapping=@constants.Linear).length(),
    7416,
  )
  assert_eq(
    shader.prefixed_fragment_shader(reversed_depth_buffer=true, tone_mapping=@constants.Linear)[6519:6536].to_owned(),
    "#define DITHERING",
  )
  assert_eq(shader.prefixed_vertex_shader(reversed_depth_buffer=true).length(), 1642)
  shader.dithering = false
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.Linear).length(), 7364)
  let raw = @materials.Material::raw()
  raw.dithering = true
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  let basic = @materials.Material::basic()
  basic.dithering = true
  assert_eq(basic.prefixed_fragment_shader(), "")
}

///|
test "Material shader writes OPAQUE" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(1238 - 1222, 16)
  assert_eq(shader.prefixed_fragment_shader()[1162:1176].to_owned(), "#define OPAQUE")
  shader.transparent = true
  assert_eq(shader.prefixed_fragment_shader().length(), 2026)
  shader.transparent = false
  shader.blending = @constants.Additive
  assert_eq(shader.prefixed_fragment_shader().length(), 2026)
  shader.blending = @constants.Normal
  shader.alpha_to_coverage = true
  assert_eq(shader.prefixed_fragment_shader().length(), 2052)
  shader.alpha_to_coverage = false
  shader.dithering = true
  assert_eq(shader.prefixed_fragment_shader().length(), 2059)
  assert_eq(shader.prefixed_fragment_shader()[1180:1194].to_owned(), "#define OPAQUE")
  shader.dithering = false
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.Linear).length(), 7364)
  assert_eq(
    shader.prefixed_fragment_shader(tone_mapping=@constants.Linear)[6485:6499].to_owned(),
    "#define OPAQUE",
  )
  assert_eq(
    shader.prefixed_fragment_shader(reversed_depth_buffer=true, tone_mapping=@constants.Linear).length(),
    7398,
  )
  assert_eq(
    shader.prefixed_fragment_shader(reversed_depth_buffer=true, tone_mapping=@constants.Linear)[6519:6533].to_owned(),
    "#define OPAQUE",
  )
  assert_eq(shader.prefixed_vertex_shader(reversed_depth_buffer=true).length(), 1642)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_fragment_shader(), "")
}

///|
test "Material shader writes colorspace_pars_fragment" {
  let shader = @materials.Material::shader()
  let head = "vec4 LinearTransferOETF( in vec4 value ) {"
  let tail = "vec4 sRGBTransferOETF( in vec4 value ) {"
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(1734 - 1238, 496)
  assert_eq(shader.prefixed_fragment_shader()[1179:1221].to_owned(), head)
  assert_eq(shader.prefixed_fragment_shader()[1464:1504].to_owned(), tail)
  shader.transparent = true
  assert_eq(shader.prefixed_fragment_shader().length(), 2026)
  assert_eq(shader.prefixed_fragment_shader()[1164:1206].to_owned(), head)
  shader.transparent = false
  shader.dithering = true
  assert_eq(shader.prefixed_fragment_shader().length(), 2059)
  assert_eq(shader.prefixed_fragment_shader()[1197:1239].to_owned(), head)
  shader.dithering = false
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.Linear).length(), 7364)
  assert_eq(
    shader.prefixed_fragment_shader(tone_mapping=@constants.Linear)[6502:6544].to_owned(),
    head,
  )
  assert_eq(
    shader.prefixed_fragment_shader(reversed_depth_buffer=true, tone_mapping=@constants.Linear).length(),
    7398,
  )
  assert_eq(
    shader.prefixed_fragment_shader(reversed_depth_buffer=true, tone_mapping=@constants.Linear)[6536:6578].to_owned(),
    head,
  )
  assert_eq(shader.prefixed_vertex_shader(reversed_depth_buffer=true).length(), 1642)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_fragment_shader(), "")
}

///|
test "Material shader writes getTexelEncodingFunction" {
  let shader = @materials.Material::shader()
  let srgb = "vec4 linearToOutputTexel( vec4 value ) {\n return sRGBTransferOETF( vec4( value.rgb * mat3( 1.0000, 0.0000, 0.0000, 0.0000, 1.0000, 0.0000, 0.0000, 0.0000, 1.0000 ), value.a ) );\n}"
  let linear = "vec4 linearToOutputTexel( vec4 value ) {\n return LinearTransferOETF( vec4( value.rgb * mat3( 1.0000, 0.0000, 0.0000, 0.0000, 1.0000, 0.0000, 0.0000, 0.0000, 1.0000 ), value.a ) );\n}"
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(1915 - 1734, 181)
  assert_eq(shader.prefixed_fragment_shader()[1674:1853].to_owned(), srgb)
  assert_eq(shader.prefixed_fragment_shader(output_srgb=false).length(), 2043)
  assert_eq(shader.prefixed_fragment_shader(output_srgb=false)[1674:1855].to_owned(), linear)
  assert_eq(1917 - 1915, 2)
  shader.transparent = true
  assert_eq(shader.prefixed_fragment_shader().length(), 2026)
  shader.dithering = true
  shader.transparent = false
  assert_eq(shader.prefixed_fragment_shader().length(), 2059)
  shader.dithering = false
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.Linear).length(), 7364)
  assert_eq(
    shader.prefixed_fragment_shader(reversed_depth_buffer=true, tone_mapping=@constants.Linear).length(),
    7398,
  )
  assert_eq(shader.prefixed_vertex_shader(reversed_depth_buffer=true).length(), 1642)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_fragment_shader(output_srgb=false), "")
}

///|
test "Material shader writes getLuminanceFunction" {
  let shader = @materials.Material::shader()
  let body = "float luminance( const in vec3 rgb ) {\n const vec3 weights = vec3( 0.2126, 0.7152, 0.0722 );\n return dot( weights, rgb );\n}"
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(2040 - 1915, 125)
  assert_eq(shader.prefixed_fragment_shader()[1855:1978].to_owned(), body)
  assert_eq(shader.prefixed_fragment_shader(output_srgb=false).length(), 2043)
  shader.transparent = true
  assert_eq(shader.prefixed_fragment_shader().length(), 2026)
  shader.transparent = false
  shader.dithering = true
  assert_eq(shader.prefixed_fragment_shader().length(), 2059)
  shader.dithering = false
  assert_eq(shader.prefixed_fragment_shader(tone_mapping=@constants.Linear).length(), 7364)
  assert_eq(
    shader.prefixed_fragment_shader(reversed_depth_buffer=true, tone_mapping=@constants.Linear).length(),
    7398,
  )
  assert_eq(shader.prefixed_vertex_shader(reversed_depth_buffer=true).length(), 1642)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_fragment_shader(), "")
}

///|
test "Material shader writes DEPTH_PACKING" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_fragment_shader(depth_packing=-1).length(), 2041)
  assert_eq(shader.prefixed_fragment_shader(depth_packing=3200).length(), 2068)
  assert_eq(2067 - 2040, 27)
  assert_eq(
    shader.prefixed_fragment_shader(depth_packing=3200)[1979:2005].to_owned(),
    "#define DEPTH_PACKING 3200",
  )
  assert_eq(shader.prefixed_fragment_shader(depth_packing=3201).length(), 2068)
  assert_eq(
    shader.prefixed_fragment_shader(depth_packing=3201)[1979:2005].to_owned(),
    "#define DEPTH_PACKING 3201",
  )
  assert_eq(shader.prefixed_fragment_shader(depth_packing=0).length(), 2065)
  assert_eq(
    shader.prefixed_fragment_shader(depth_packing=0)[1979:2002].to_owned(),
    "#define DEPTH_PACKING 0",
  )
  assert_eq(
    shader.prefixed_fragment_shader(reversed_depth_buffer=true, tone_mapping=@constants.Linear, depth_packing=3200).length(),
    7425,
  )
  assert_eq(
    shader.prefixed_fragment_shader(reversed_depth_buffer=true, tone_mapping=@constants.Linear, depth_packing=3200)[7336:7362].to_owned(),
    "#define DEPTH_PACKING 3200",
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_fragment_shader(depth_packing=3200).length(), 61)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_fragment_shader(depth_packing=3200), "")
}

///|
test "Material shader writes prefixFragment newline" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_fragment_shader()[1978:1980].to_owned(), "\n\n")
  assert_eq(shader.prefixed_fragment_shader(depth_packing=3200).length(), 2068)
  assert_eq(
    shader.prefixed_fragment_shader(depth_packing=3200)[1979:2005].to_owned(),
    "#define DEPTH_PACKING 3200",
  )
  assert_eq(
    shader.prefixed_fragment_shader(depth_packing=3200)[2005:2007].to_owned(),
    "\n\n",
  )
  assert_eq(
    shader
    .prefixed_fragment_shader(
      reversed_depth_buffer=true,
      tone_mapping=@constants.Linear,
    )
    .length(),
    7398,
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_fragment_shader(), "")
}

///|
test "Material shader writes USE_GRADIENTMAP" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.gradient_map = Some(map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2065)
  assert_eq(2065 - 2041, 24)
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1102].to_owned(),
    "#define USE_GRADIENTMAP",
  )
  shader.flat_shading = true
  assert_eq(shader.prefixed_vertex_shader().length(), 1628)
  assert_eq(shader.prefixed_fragment_shader().length(), 2085)
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1102].to_owned(),
    "#define USE_GRADIENTMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1103:1122].to_owned(),
    "#define FLAT_SHADED",
  )
  shader.flat_shading = false
  shader.gradient_map = None
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.map = Some(map)
  shader.gradient_map = Some(map)
  assert_eq(shader.prefixed_vertex_shader(has_points_uv=true).length(), 1664)
  assert_eq(shader.prefixed_fragment_shader(has_points_uv=true).length(), 2103)
  assert_eq(
    shader.prefixed_fragment_shader(has_points_uv=true)[1117:1140].to_owned(),
    "#define USE_GRADIENTMAP",
  )
  let raw = @materials.Material::raw()
  raw.gradient_map = Some(map)
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  let basic = @materials.Material::basic()
  basic.gradient_map = Some(map)
  assert_eq(basic.prefixed_fragment_shader(), "")
}

///|
test "Material shader writes PREMULTIPLIED_ALPHA" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.premultiplied_alpha = true
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2069)
  assert_eq(2069 - 2041, 28)
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1106].to_owned(),
    "#define PREMULTIPLIED_ALPHA",
  )
  assert_eq(shader.prefixed_vertex_shader(num_light_probes=1).length(), 1633)
  assert_eq(shader.prefixed_fragment_shader(num_light_probes=1).length(), 2094)
  assert_eq(
    shader.prefixed_fragment_shader(num_light_probes=1)[1079:1106].to_owned(),
    "#define PREMULTIPLIED_ALPHA",
  )
  assert_eq(
    shader.prefixed_fragment_shader(num_light_probes=1)[1107:1131].to_owned(),
    "#define USE_LIGHT_PROBES",
  )
  shader.premultiplied_alpha = false
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.premultiplied_alpha = true
  assert_eq(shader.prefixed_vertex_shader(shadow_map_enabled=true).length(), 1659)
  assert_eq(shader.prefixed_fragment_shader(shadow_map_enabled=true).length(), 2120)
  assert_eq(
    shader.prefixed_fragment_shader(shadow_map_enabled=true)[1130:1157].to_owned(),
    "#define PREMULTIPLIED_ALPHA",
  )
  let raw = @materials.Material::raw()
  raw.premultiplied_alpha = true
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  let basic = @materials.Material::basic()
  basic.premultiplied_alpha = true
  assert_eq(basic.prefixed_fragment_shader(), "")
}

///|
test "Material shader writes USE_LIGHT_PROBES_GRID" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_fragment_shader(num_light_probe_grids=0).length(), 2041)
  assert_eq(shader.prefixed_fragment_shader(num_light_probe_grids=-1).length(), 2041)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader(num_light_probe_grids=1).length(), 2071)
  assert_eq(2071 - 2041, 30)
  assert_eq(
    shader.prefixed_fragment_shader(num_light_probe_grids=1)[1079:1108].to_owned(),
    "#define USE_LIGHT_PROBES_GRID",
  )
  assert_eq(shader.prefixed_vertex_shader(num_light_probes=1).length(), 1633)
  assert_eq(
    shader.prefixed_fragment_shader(num_light_probes=1, num_light_probe_grids=2).length(),
    2096,
  )
  assert_eq(
    shader.prefixed_fragment_shader(num_light_probes=1, num_light_probe_grids=2)[1104:1133].to_owned(),
    "#define USE_LIGHT_PROBES_GRID",
  )
  shader.premultiplied_alpha = true
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader(num_light_probe_grids=1).length(), 2099)
  assert_eq(
    shader.prefixed_fragment_shader(num_light_probe_grids=1)[1107:1136].to_owned(),
    "#define USE_LIGHT_PROBES_GRID",
  )
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_fragment_shader(num_light_probe_grids=1).length(), 61)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_fragment_shader(num_light_probe_grids=1), "")
}

///|
test "Material shader writes DECODE_VIDEO_TEXTURE" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_fragment_shader(decode_video_texture=false).length(), 2041)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader(decode_video_texture=true).length(), 2070)
  assert_eq(2070 - 2041, 29)
  assert_eq(
    shader.prefixed_fragment_shader(decode_video_texture=true)[1079:1107].to_owned(),
    "#define DECODE_VIDEO_TEXTURE",
  )
  assert_eq(
    shader.prefixed_fragment_shader(num_light_probe_grids=1, decode_video_texture=true).length(),
    2100,
  )
  assert_eq(
    shader.prefixed_fragment_shader(num_light_probe_grids=1, decode_video_texture=true)[1109:1137].to_owned(),
    "#define DECODE_VIDEO_TEXTURE",
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_fragment_shader(decode_video_texture=true).length(), 61)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_fragment_shader(decode_video_texture=true), "")
}

///|
test "Material shader writes DECODE_VIDEO_TEXTURE_EMISSIVE" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.prefixed_fragment_shader(decode_video_texture_emissive=false).length(),
    2041,
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(
    shader.prefixed_fragment_shader(decode_video_texture_emissive=true).length(),
    2079,
  )
  assert_eq(2079 - 2041, 38)
  assert_eq(
    shader.prefixed_fragment_shader(decode_video_texture_emissive=true)[1079:1116].to_owned(),
    "#define DECODE_VIDEO_TEXTURE_EMISSIVE",
  )
  assert_eq(
    shader
    .prefixed_fragment_shader(
      decode_video_texture=true,
      decode_video_texture_emissive=true,
    )
    .length(),
    2108,
  )
  assert_eq(
    shader
    .prefixed_fragment_shader(
      decode_video_texture=true,
      decode_video_texture_emissive=true,
    )[1108:1145]
    .to_owned(),
    "#define DECODE_VIDEO_TEXTURE_EMISSIVE",
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_fragment_shader(decode_video_texture_emissive=true).length(), 61)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_fragment_shader(decode_video_texture_emissive=true), "")
}

///|
test "Material shader resolveIncludes expands chunks" {
  let chunks : Map[String, String] = Map([])
  chunks.set("common", "float x;\n")
  chunks.set("a", "#include <b>\n")
  chunks.set("b", "vec3 y;\n")
  chunks.set("lights/common.glsl", "int n;\n")
  assert_eq(@materials.resolve_includes("float z;\n", chunks), "float z;\n")
  assert_eq(@materials.resolve_includes("#include <common>", chunks), "float x;\n")
  assert_eq(@materials.resolve_includes("  #include <common>", chunks), "float x;\n")
  assert_eq(
    @materials.resolve_includes("#include <common> // keep\n", chunks),
    "float x;\n // keep\n",
  )
  assert_eq(
    @materials.resolve_includes("#include\t<common>\n", chunks),
    "#include\t<common>\n",
  )
  assert_eq(
    @materials.resolve_includes("void main() {\n#include <common>\n}\n", chunks),
    "void main() {\nfloat x;\n\n}\n",
  )
  assert_eq(@materials.resolve_includes("#include <a>", chunks), "vec3 y;\n\n")
  assert_eq(
    @materials.resolve_includes("#include <lights/common.glsl>", chunks),
    "int n;\n",
  )
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader replaceLightNums writes light counts" {
  let source = "NUM_DIR_LIGHTS NUM_DIR_LIGHTS NUM_SPOT_LIGHT_MAPS NUM_SPOT_LIGHTS NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS NUM_SPOT_LIGHT_SHADOWS NUM_SPOT_LIGHT_COORDS NUM_POINT_LIGHTS NUM_HEMI_LIGHTS NUM_SUN_LIGHTS NUM_SUN_LIGHT_SHADOWS NUM_DIR_LIGHT_SHADOWS NUM_RECT_AREA_LIGHTS NUM_POINT_LIGHT_SHADOWS"
  assert_eq(
    @materials.replace_light_nums(source),
    "0 0 0 0 0 0 0 0 0 0 0 0 0 0",
  )
  assert_eq(
    @materials.replace_light_nums(
      source,
      num_dir_lights=2,
      num_spot_lights=5,
      num_spot_light_maps=4,
      num_spot_light_shadows=3,
      num_spot_light_shadows_with_maps=1,
      num_point_lights=6,
      num_hemi_lights=1,
      num_sun_lights=7,
      num_sun_light_shadows=8,
      num_dir_light_shadows=9,
      num_rect_area_lights=10,
      num_point_light_shadows=11,
    ),
    "2 2 4 5 1 3 6 6 1 7 8 9 10 11",
  )
  assert_eq(
    @materials.replace_light_nums(
      "NUM_SPOT_LIGHT_COORDS",
      num_spot_light_shadows=0,
      num_spot_light_maps=0,
      num_spot_light_shadows_with_maps=2,
    ),
    "-2",
  )
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader replaceClippingPlaneNums writes plane counts" {
  assert_eq(
    @materials.replace_clipping_plane_nums(
      "NUM_CLIPPING_PLANES UNION_CLIPPING_PLANES NUM_CLIPPING_PLANES",
    ),
    "0 0 0",
  )
  assert_eq(
    @materials.replace_clipping_plane_nums(
      "NUM_CLIPPING_PLANES UNION_CLIPPING_PLANES",
      num_clipping_planes=5,
      num_clip_intersection=2,
    ),
    "5 3",
  )
  assert_eq(
    @materials.replace_clipping_plane_nums(
      "UNION_CLIPPING_PLANES",
      num_clipping_planes=1,
      num_clip_intersection=7,
    ),
    "-6",
  )
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader unrollLoops expands indexed loops" {
  assert_eq(@materials.unroll_loops("float x;"), "float x;")
  assert_eq(
    @materials.unroll_loops(
      "before\n#pragma unroll_loop_start\nfor ( int i = 0; i < 2; i ++ ) {\n\ttexel[ i ] = UNROLLED_LOOP_INDEX;\n}\n#pragma unroll_loop_end\nafter",
    ),
    "before\n\n\ttexel[ 0 ] = 0;\n\n\ttexel[ 1 ] = 1;\n\nafter",
  )
  assert_eq(
    @materials.unroll_loops(
      "#pragma unroll_loop_start\nfor ( int i = 2; i < 2; i ++ ) {\n\tx;\n}\n#pragma unroll_loop_end",
    ),
    "",
  )
  assert_eq(
    @materials.unroll_loops("#pragma unroll_loop_start for ("),
    "#pragma unroll_loop_start for (",
  )
  assert_eq(
    @materials.unroll_loops(
      "#pragma unroll_loop_start for(int i=1;i<3;i++){[i] UNROLLED_LOOP_INDEX;}#pragma unroll_loop_end",
    ),
    "[ 1 ] 1;[ 2 ] 2;",
  )
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader getProgramCacheKey joins parameters" {
  assert_eq(
    @materials.program_cache_key(),
    ",,highp,,false,,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,0,false,false,0,,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,,",
  )
  assert_eq(
    @materials.program_cache_key(shader_id=Some("lambert"), custom_program_cache_key="custom"),
    "lambert,highp,,false,,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,0,false,false,0,,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,,custom",
  )
  assert_eq(
    @materials.program_cache_key(
      shader_id=Some("basic"),
      is_raw=true,
      defines=[("FOO", "1"), ("BAR", "2")],
      custom_program_cache_key="k",
    ),
    "basic,FOO,1,BAR,2,k",
  )
  assert_eq(
    @materials.program_cache_key(shader_id=Some("phong"), defines=[("A", "1"), ("B", "2")])[0:15].to_owned(),
    "phong,A,1,B,2,h",
  )
  assert_eq(
    @materials.program_cache_key(num_dir_lights="3").contains("0,,0,3,0"),
    true,
  )
  assert_eq(
    @materials.program_cache_key(instancing=true, retroreflection=true).contains(",16777217,0,,"),
    true,
  )
  assert_eq(
    @materials.program_cache_key(is_opaque=true, light_probe_grids=true).contains(",0,4325376,,"),
    true,
  )
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader getUniforms clones builtin tables" {
  let library : Map[String, Map[String, Double]] = Map([])
  let names = [
    ("MeshDepthMaterial", "depth"),
    ("MeshDistanceMaterial", "distance"),
    ("MeshNormalMaterial", "normal"),
    ("MeshBasicMaterial", "basic"),
    ("MeshLambertMaterial", "lambert"),
    ("MeshPhongMaterial", "phong"),
    ("MeshToonMaterial", "toon"),
    ("MeshStandardMaterial", "physical"),
    ("MeshPhysicalMaterial", "physical"),
    ("MeshMatcapMaterial", "matcap"),
    ("LineBasicMaterial", "basic"),
    ("LineDashedMaterial", "dashed"),
    ("PointsMaterial", "points"),
    ("ShadowMaterial", "shadow"),
    ("SpriteMaterial", "sprite"),
  ]
  let mut index = 0
  while index < names.length() {
    let (type_name, shader_id) = names[index]
    let table : Map[String, Double] = Map([])
    table.set("marker", 1.0)
    library.set(shader_id, table)
    let own : Map[String, Double] = Map([])
    own.set("time", 9.0)
    let got = @materials.program_uniforms(type_name, own, library)
    assert_eq(got.get("marker"), Some(1.0))
    match got.get("time") {
      None => ()
      Some(_) => abort("builtin uniforms kept the material map")
    }
    got.set("marker", 5.0)
    assert_eq(table.get("marker"), Some(1.0))
    index = index + 1
  }
  let shader = @materials.Material::shader()
  shader.uniforms.set("time", 1.0)
  let got = @materials.program_uniforms(shader.type_name, shader.uniforms, library)
  assert_eq(got.get("time"), Some(1.0))
  match got.get("marker") {
    None => ()
    Some(_) => abort("shader uniforms came from the library")
  }
  got.set("time", 4.0)
  assert_eq(shader.uniforms.get("time"), Some(4.0))
  let raw = @materials.Material::raw()
  raw.uniforms.set("scale", 2.0)
  let raw_got = @materials.program_uniforms(raw.type_name, raw.uniforms, library)
  raw_got.set("scale", 6.0)
  assert_eq(raw.uniforms.get("scale"), Some(6.0))
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader acquireProgram reuses a cache key" {
  let cache = @materials.ProgramCache::new()
  assert_eq(cache.programs.length(), 0)
  let first = cache.acquire("a")
  assert_eq(first.cache_key, "a")
  assert_eq(first.used_times.val, 1)
  let again = cache.acquire("a")
  assert_eq(again.used_times.val, 2)
  assert_eq(first.used_times.val, 2)
  assert_eq(cache.programs.length(), 1)
  let second = cache.acquire("b")
  assert_eq(second.cache_key, "b")
  assert_eq(second.used_times.val, 1)
  assert_eq(cache.programs.length(), 2)
  assert_eq(cache.programs[0].cache_key, "a")
  assert_eq(cache.programs[1].cache_key, "b")
  assert_eq(first.used_times.val, 2)
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader releaseProgram drops a zero count" {
  let cache = @materials.ProgramCache::new()
  let first = cache.acquire("a")
  ignore(cache.acquire("a"))
  cache.release(first)
  assert_eq(first.used_times.val, 1)
  assert_eq(cache.programs.length(), 1)
  assert_eq(cache.by_key.get("a") is Some(_), true)
  cache.release(first)
  assert_eq(first.used_times.val, 0)
  assert_eq(cache.programs.length(), 0)
  match cache.by_key.get("a") {
    None => ()
    Some(_) => abort("released program stayed in the key map")
  }
  let again = cache.acquire("a")
  assert_eq(again.used_times.val, 1)
  assert_eq(first.used_times.val, 0)
  let left = cache.acquire("b")
  let middle = cache.acquire("c")
  let right = cache.acquire("d")
  cache.release(middle)
  assert_eq(middle.used_times.val, 0)
  assert_eq(cache.programs.length(), 3)
  assert_eq(cache.programs[0].cache_key, "a")
  assert_eq(cache.programs[1].cache_key, "b")
  assert_eq(cache.programs[2].cache_key, "d")
  assert_eq(left.used_times.val, 1)
  assert_eq(right.used_times.val, 1)
  match cache.by_key.get("c") {
    None => ()
    Some(_) => abort("swapped program stayed in the key map")
  }
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader releaseShaderCache drops unused stages" {
  let cache = @materials.ShaderCache::new()
  let shader = @materials.Material::shader()
  let raw = @materials.Material::raw()
  cache.update(shader.id, "vert", "frag")
  let vert = match cache.shader_cache.get("vert") {
    Some(stage) => stage
    None => abort("vertex stage missing")
  }
  let frag = match cache.shader_cache.get("frag") {
    Some(stage) => stage
    None => abort("fragment stage missing")
  }
  assert_eq(vert.used_times.val, 1)
  assert_eq(frag.used_times.val, 1)
  assert_eq(frag.id, vert.id + 1)
  cache.update(shader.id, "vert", "frag")
  assert_eq(vert.used_times.val, 1)
  cache.update(raw.id, "vert", "other")
  assert_eq(vert.used_times.val, 2)
  let other = match cache.shader_cache.get("other") {
    Some(stage) => stage
    None => abort("other stage missing")
  }
  assert_eq(other.used_times.val, 1)
  assert_eq(other.id == vert.id, false)
  cache.release_shader_cache(shader.id)
  assert_eq(vert.used_times.val, 1)
  match cache.shader_cache.get("frag") {
    None => ()
    Some(_) => abort("unused fragment stage stayed")
  }
  match cache.material_cache.get(shader.id) {
    None => ()
    Some(_) => abort("released material stayed")
  }
  cache.release_shader_cache(raw.id)
  match cache.shader_cache.get("vert") {
    None => ()
    Some(_) => abort("shared vertex stage stayed")
  }
  match cache.shader_cache.get("other") {
    None => ()
    Some(_) => abort("other stage stayed")
  }
  cache.update(shader.id, "same", "same")
  let same = match cache.shader_cache.get("same") {
    Some(stage) => stage
    None => abort("same stage missing")
  }
  assert_eq(same.used_times.val, 1)
  cache.release_shader_cache(shader.id)
  match cache.shader_cache.get("same") {
    None => ()
    Some(_) => abort("identical stage stayed")
  }
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader dispose clears shader caches" {
  let cache = @materials.ShaderCache::new()
  let programs = @materials.ProgramCache::new()
  let shader = @materials.Material::shader()
  ignore(programs.acquire("kept"))
  cache.update(shader.id, "vert", "frag")
  let vert = match cache.shader_cache.get("vert") {
    Some(stage) => stage
    None => abort("vertex stage missing")
  }
  cache.dispose()
  match cache.shader_cache.get("vert") {
    None => ()
    Some(_) => abort("disposed shader code stayed")
  }
  match cache.material_cache.get(shader.id) {
    None => ()
    Some(_) => abort("disposed material stayed")
  }
  assert_eq(vert.used_times.val, 1)
  assert_eq(programs.programs.length(), 1)
  assert_eq(programs.programs[0].cache_key, "kept")
  cache.update(shader.id, "vert", "frag")
  let again = match cache.shader_cache.get("vert") {
    Some(stage) => stage
    None => abort("vertex stage missing after dispose")
  }
  assert_eq(again.used_times.val, 1)
  assert_eq(again.id, vert.id + 2)
  assert_eq(vert.used_times.val, 1)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader getVertexShaderStage reuses source" {
  let cache = @materials.ShaderCache::new()
  let shader = @materials.Material::shader()
  let stage = cache.get_vertex_shader_stage(shader)
  assert_eq(stage.code, shader.vertex_shader)
  assert_eq(stage.used_times.val, 0)
  let again = cache.get_vertex_shader_stage(shader)
  assert_eq(again.id, stage.id)
  assert_eq(again.used_times.val, 0)
  let raw = @materials.Material::raw()
  assert_eq(cache.get_vertex_shader_stage(raw).id, stage.id)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.vertex_shader = "custom"
  let custom = cache.get_vertex_shader_stage(shader)
  assert_eq(custom.code, "custom")
  assert_eq(custom.id == stage.id, false)
  assert_eq(custom.used_times.val, 0)
  let basic = @materials.Material::basic()
  let empty = cache.get_vertex_shader_stage(basic)
  assert_eq(empty.code, "")
  assert_eq(empty.used_times.val, 0)
  assert_eq(empty.id == custom.id, false)
  match cache.material_cache.get(shader.id) {
    None => ()
    Some(_) => abort("vertex stage wrote the material map")
  }
}

///|
test "Material shader getFragmentShaderStage reuses source" {
  let cache = @materials.ShaderCache::new()
  let shader = @materials.Material::shader()
  let stage = cache.get_fragment_shader_stage(shader)
  assert_eq(stage.code, shader.fragment_shader)
  assert_eq(stage.used_times.val, 0)
  let again = cache.get_fragment_shader_stage(shader)
  assert_eq(again.id, stage.id)
  assert_eq(again.used_times.val, 0)
  let raw = @materials.Material::raw()
  assert_eq(cache.get_fragment_shader_stage(raw).id, stage.id)
  let vertex = cache.get_vertex_shader_stage(shader)
  assert_eq(vertex.id == stage.id, false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.fragment_shader = "custom"
  let custom = cache.get_fragment_shader_stage(shader)
  assert_eq(custom.code, "custom")
  assert_eq(custom.id == stage.id, false)
  assert_eq(custom.used_times.val, 0)
  let basic = @materials.Material::basic()
  let empty = cache.get_fragment_shader_stage(basic)
  assert_eq(empty.code, "")
  assert_eq(empty.used_times.val, 0)
  assert_eq(empty.id == custom.id, false)
  match cache.material_cache.get(shader.id) {
    None => ()
    Some(_) => abort("fragment stage wrote the material map")
  }
}

///|
test "Material shader customVertexShaderID skips builtin types" {
  let cache = @materials.ShaderCache::new()
  let shader = @materials.Material::shader()
  let stage = cache.get_vertex_shader_stage(shader)
  match cache.custom_vertex_shader_id(shader) {
    Some(id) => assert_eq(id, stage.id)
    None => abort("shader vertex id missing")
  }
  assert_eq(stage.used_times.val, 0)
  let raw = @materials.Material::raw()
  match cache.custom_vertex_shader_id(raw) {
    Some(id) => assert_eq(id, stage.id)
    None => abort("raw vertex id missing")
  }
  match cache.custom_vertex_shader_id(@materials.Material::basic()) {
    None => ()
    Some(_) => abort("basic gained a custom vertex id")
  }
  match cache.custom_vertex_shader_id(@materials.Material::lambert()) {
    None => ()
    Some(_) => abort("lambert gained a custom vertex id")
  }
  match cache.custom_vertex_shader_id(@materials.Material::physical()) {
    None => ()
    Some(_) => abort("physical gained a custom vertex id")
  }
  match cache.shader_cache.get("") {
    None => ()
    Some(_) => abort("builtin vertex id stored an empty stage")
  }
  match cache.material_cache.get(shader.id) {
    None => ()
    Some(_) => abort("vertex id wrote the material map")
  }
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.vertex_shader = "custom"
  match cache.custom_vertex_shader_id(shader) {
    Some(id) => assert_eq(id == stage.id, false)
    None => abort("replaced vertex id missing")
  }
  assert_eq(stage.used_times.val, 0)
}

///|
test "Material shader customFragmentShaderID skips builtin types" {
  let cache = @materials.ShaderCache::new()
  let shader = @materials.Material::shader()
  let stage = cache.get_fragment_shader_stage(shader)
  let vertex = cache.get_vertex_shader_stage(shader)
  match cache.custom_fragment_shader_id(shader) {
    Some(id) => assert_eq(id, stage.id)
    None => abort("shader fragment id missing")
  }
  assert_eq(stage.id == vertex.id, false)
  assert_eq(stage.used_times.val, 0)
  let raw = @materials.Material::raw()
  match cache.custom_fragment_shader_id(raw) {
    Some(id) => assert_eq(id, stage.id)
    None => abort("raw fragment id missing")
  }
  match cache.custom_fragment_shader_id(@materials.Material::basic()) {
    None => ()
    Some(_) => abort("basic gained a custom fragment id")
  }
  match cache.custom_fragment_shader_id(@materials.Material::lambert()) {
    None => ()
    Some(_) => abort("lambert gained a custom fragment id")
  }
  match cache.custom_fragment_shader_id(@materials.Material::physical()) {
    None => ()
    Some(_) => abort("physical gained a custom fragment id")
  }
  match cache.shader_cache.get("") {
    None => ()
    Some(_) => abort("builtin fragment id stored an empty stage")
  }
  match cache.material_cache.get(shader.id) {
    None => ()
    Some(_) => abort("fragment id wrote the material map")
  }
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.fragment_shader = "custom"
  match cache.custom_fragment_shader_id(shader) {
    Some(id) => assert_eq(id == stage.id, false)
    None => abort("replaced fragment id missing")
  }
  assert_eq(stage.used_times.val, 0)
}

///|
test "Material shader shaderType reads the material type" {
  assert_eq(@materials.Material::basic().shader_type(), "MeshBasicMaterial")
  assert_eq(@materials.Material::lambert().shader_type(), "MeshLambertMaterial")
  assert_eq(@materials.Material::standard().shader_type(), "MeshStandardMaterial")
  assert_eq(@materials.Material::physical().shader_type(), "MeshPhysicalMaterial")
  assert_eq(@materials.Material::toon().shader_type(), "MeshToonMaterial")
  assert_eq(@materials.Material::matcap().shader_type(), "MeshMatcapMaterial")
  assert_eq(@materials.Material::normal().shader_type(), "MeshNormalMaterial")
  assert_eq(@materials.Material::depth().shader_type(), "MeshDepthMaterial")
  assert_eq(@materials.Material::distance().shader_type(), "MeshDistanceMaterial")
  assert_eq(@materials.Material::phong().shader_type(), "MeshPhongMaterial")
  assert_eq(@materials.Material::shadow().shader_type(), "ShadowMaterial")
  let shader = @materials.Material::shader()
  assert_eq(shader.shader_type(), "ShaderMaterial")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.name = "renamed"
  assert_eq(shader.shader_type(), "ShaderMaterial")
  assert_eq(@materials.Material::raw().shader_type(), "RawShaderMaterial")
}

///|
test "Material shader shaderName reads the material name" {
  let shader = @materials.Material::shader()
  assert_eq(shader.shader_name(), "")
  assert_eq(shader.shader_type(), "ShaderMaterial")
  assert_eq(@materials.Material::basic().shader_name(), "")
  assert_eq(@materials.Material::lambert().shader_name(), "")
  assert_eq(@materials.Material::raw().shader_name(), "")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.name = "renamed"
  assert_eq(shader.shader_name(), "renamed")
  assert_eq(shader.shader_type(), "ShaderMaterial")
}

///|
test "Material shader vertexShader keeps builtin source out" {
  let shader = @materials.Material::shader()
  let raw = @materials.Material::raw()
  match shader.program_vertex_shader() {
    Some(code) => assert_eq(code, shader.vertex_shader)
    None => abort("shader vertex source missing")
  }
  match raw.program_vertex_shader() {
    Some(code) => assert_eq(code, shader.vertex_shader)
    None => abort("raw vertex source missing")
  }
  match @materials.Material::basic().program_vertex_shader() {
    None => ()
    Some(_) => abort("basic returned vertex source")
  }
  match @materials.Material::lambert().program_vertex_shader() {
    None => ()
    Some(_) => abort("lambert returned vertex source")
  }
  match @materials.Material::physical().program_vertex_shader() {
    None => ()
    Some(_) => abort("physical returned vertex source")
  }
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.vertex_shader = "custom"
  match shader.program_vertex_shader() {
    Some(code) => assert_eq(code, "custom")
    None => abort("replaced vertex source missing")
  }
}

///|
test "Material shader fragmentShader keeps builtin source out" {
  let shader = @materials.Material::shader()
  let raw = @materials.Material::raw()
  match shader.program_fragment_shader() {
    Some(code) => assert_eq(code, shader.fragment_shader)
    None => abort("shader fragment source missing")
  }
  match raw.program_fragment_shader() {
    Some(code) => assert_eq(code, shader.fragment_shader)
    None => abort("raw fragment source missing")
  }
  match shader.program_vertex_shader() {
    Some(code) => assert_eq(code == shader.fragment_shader, false)
    None => abort("shader vertex source missing")
  }
  match @materials.Material::basic().program_fragment_shader() {
    None => ()
    Some(_) => abort("basic returned fragment source")
  }
  match @materials.Material::lambert().program_fragment_shader() {
    None => ()
    Some(_) => abort("lambert returned fragment source")
  }
  match @materials.Material::physical().program_fragment_shader() {
    None => ()
    Some(_) => abort("physical returned fragment source")
  }
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.fragment_shader = "custom"
  match shader.program_fragment_shader() {
    Some(code) => assert_eq(code, "custom")
    None => abort("replaced fragment source missing")
  }
}

///|
test "Material shader defines returns the material map" {
  let shader = @materials.Material::shader()
  let defines = shader.program_defines()
  match defines.get("FOO") {
    None => ()
    Some(_) => abort("shader defines started with FOO")
  }
  let basic = @materials.Material::basic()
  match basic.program_defines().get("STANDARD") {
    None => ()
    Some(_) => abort("basic defines gained STANDARD")
  }
  match @materials.Material::standard().program_defines().get("STANDARD") {
    Some(value) => assert_eq(value, "")
    None => abort("standard defines missing STANDARD")
  }
  let physical = @materials.Material::physical().program_defines()
  match physical.get("STANDARD") {
    Some(value) => assert_eq(value, "")
    None => abort("physical defines missing STANDARD")
  }
  match physical.get("PHYSICAL") {
    Some(value) => assert_eq(value, "")
    None => abort("physical defines missing PHYSICAL")
  }
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  defines.set("FOO", "1")
  assert_eq(shader.defines.get("FOO"), Some("1"))
}

///|
test "Material shader isRawShaderMaterial is only set on raw" {
  assert_eq(@materials.Material::raw().program_is_raw_shader_material(), true)
  let shader = @materials.Material::shader()
  assert_eq(shader.program_is_raw_shader_material(), false)
  assert_eq(@materials.Material::basic().program_is_raw_shader_material(), false)
  assert_eq(@materials.Material::lambert().program_is_raw_shader_material(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader glslVersion starts empty" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_glsl_version() is None, true)
  assert_eq(@materials.Material::raw().program_glsl_version() is None, true)
  assert_eq(@materials.Material::basic().program_glsl_version() is None, true)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.glsl_version = Some(@materials.GlslVersion::GLSL3)
  assert_eq(
    shader.program_glsl_version() is Some(@materials.GlslVersion::GLSL3),
    true,
  )
  shader.glsl_version = Some(@materials.GlslVersion::GLSL1)
  assert_eq(
    shader.program_glsl_version() is Some(@materials.GlslVersion::GLSL1),
    true,
  )
}

///|
test "Material shader precision uses capabilities unless set" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_precision("highp"), "highp")
  assert_eq(shader.program_precision("mediump"), "mediump")
  assert_eq(@materials.Material::basic().program_precision("lowp"), "lowp")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.precision = Some(@constants.Precision::Mediump)
  assert_eq(shader.program_precision("highp"), "mediump")
  shader.precision = Some(@constants.Precision::Lowp)
  assert_eq(shader.program_precision("highp"), "lowp")
  shader.precision = Some(@constants.Precision::Highp)
  assert_eq(shader.program_precision("lowp"), "highp")
}

///|
test "Material shader getMaxPrecision drops unavailable floats" {
  assert_eq(@materials.max_precision("highp"), "highp")
  assert_eq(@materials.max_precision("highp", vertex_highp=false), "mediump")
  assert_eq(@materials.max_precision("highp", fragment_highp=false), "mediump")
  assert_eq(
    @materials.max_precision("highp", vertex_highp=false, fragment_mediump=false),
    "lowp",
  )
  assert_eq(@materials.max_precision("mediump"), "mediump")
  assert_eq(@materials.max_precision("mediump", vertex_mediump=false), "lowp")
  assert_eq(@materials.max_precision("lowp", vertex_mediump=false), "lowp")
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.precision = Some(@constants.Precision::Highp)
  assert_eq(shader.program_precision("lowp", vertex_highp=false), "mediump")
}

///|
test "Material shader batching follows the batched mesh flag" {
  assert_eq(@materials.program_batching(), false)
  assert_eq(@materials.program_batching(is_batched_mesh=true), true)
  assert_eq(@materials.program_batching(is_batched_mesh=false), false)
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader batchingColor needs a colors texture" {
  assert_eq(@materials.program_batching_color(), false)
  assert_eq(@materials.program_batching_color(is_batched_mesh=true), false)
  assert_eq(@materials.program_batching_color(has_colors_texture=true), false)
  assert_eq(
    @materials.program_batching_color(is_batched_mesh=true, has_colors_texture=true),
    true,
  )
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader instancing follows the instanced mesh flag" {
  assert_eq(@materials.program_instancing(), false)
  assert_eq(@materials.program_instancing(is_instanced_mesh=true), true)
  assert_eq(@materials.program_instancing(is_instanced_mesh=false), false)
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader instancingColor needs instance color" {
  assert_eq(@materials.program_instancing_color(), false)
  assert_eq(@materials.program_instancing_color(is_instanced_mesh=true), false)
  assert_eq(@materials.program_instancing_color(has_instance_color=true), false)
  assert_eq(
    @materials.program_instancing_color(
      is_instanced_mesh=true,
      has_instance_color=true,
    ),
    true,
  )
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader instancingMorph needs a morph texture" {
  assert_eq(@materials.program_instancing_morph(), false)
  assert_eq(@materials.program_instancing_morph(is_instanced_mesh=true), false)
  assert_eq(@materials.program_instancing_morph(has_morph_texture=true), false)
  assert_eq(
    @materials.program_instancing_morph(
      is_instanced_mesh=true,
      has_morph_texture=true,
    ),
    true,
  )
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader outputColorSpace picks the active space" {
  assert_eq(@materials.program_output_color_space("srgb", "srgb-linear"), "srgb")
  assert_eq(
    @materials.program_output_color_space(
      "srgb",
      "srgb-linear",
      is_xr_render_target=true,
      target_color_space="display-p3",
    ),
    "srgb",
  )
  assert_eq(
    @materials.program_output_color_space(
      "srgb",
      "srgb-linear",
      has_render_target=true,
    ),
    "srgb-linear",
  )
  assert_eq(
    @materials.program_output_color_space(
      "srgb",
      "srgb-linear",
      has_render_target=true,
      is_xr_render_target=true,
      target_color_space="display-p3",
    ),
    "display-p3",
  )
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
}

///|
test "Material shader alphaToCoverage starts off" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_alpha_to_coverage(), false)
  assert_eq(@materials.Material::raw().program_alpha_to_coverage(), false)
  assert_eq(@materials.Material::basic().program_alpha_to_coverage(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.alpha_to_coverage = true
  assert_eq(shader.program_alpha_to_coverage(), true)
}

///|
test "Material shader map follows the color texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_map(), false)
  assert_eq(@materials.Material::raw().program_map(), false)
  assert_eq(@materials.Material::basic().program_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_map(), true)
  shader.map = None
  assert_eq(shader.program_map(), false)
}

///|
test "Material shader matcap follows the matcap texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_matcap(), false)
  assert_eq(@materials.Material::raw().program_matcap(), false)
  assert_eq(@materials.Material::matcap().program_matcap(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.matcap = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_matcap(), true)
  shader.matcap = None
  assert_eq(shader.program_matcap(), false)
}

///|
test "Material shader envMap uses the scene for lit materials" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_env_map(), false)
  assert_eq(shader.program_env_map(has_scene_environment=true), false)
  assert_eq(@materials.Material::basic().program_env_map(has_scene_environment=true), false)
  assert_eq(@materials.Material::matcap().program_env_map(has_scene_environment=true), false)
  assert_eq(@materials.Material::lambert().program_env_map(), false)
  assert_eq(@materials.Material::lambert().program_env_map(has_scene_environment=true), true)
  assert_eq(@materials.Material::phong().program_env_map(has_scene_environment=true), true)
  assert_eq(@materials.Material::toon().program_env_map(has_scene_environment=true), true)
  assert_eq(@materials.Material::standard().program_env_map(has_scene_environment=true), true)
  assert_eq(@materials.Material::physical().program_env_map(has_scene_environment=true), true)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.env_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_env_map(), true)
  shader.env_map = None
  assert_eq(shader.program_env_map(), false)
}

///|
test "Material shader envMapMode is the mapping when a map exists" {
  let shader = @materials.Material::shader()
  match shader.program_env_map_mode(301) {
    None => ()
    Some(_) => abort("shader env map mode without a map")
  }
  match @materials.Material::basic().program_env_map_mode(301, has_scene_environment=true) {
    None => ()
    Some(_) => abort("basic env map mode from the scene")
  }
  match @materials.Material::lambert().program_env_map_mode(301, has_scene_environment=true) {
    Some(mode) => assert_eq(mode, 301)
    None => abort("lambert env map mode missing")
  }
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.env_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  match shader.program_env_map_mode(302) {
    Some(mode) => assert_eq(mode, 302)
    None => abort("shader env map mode missing")
  }
  shader.env_map = None
  match shader.program_env_map_mode(302) {
    None => ()
    Some(_) => abort("cleared env map kept a mode")
  }
}

///|
test "Material shader envMapCubeUVHeight needs cube UV mapping" {
  let shader = @materials.Material::shader()
  match shader.program_env_map_cube_uv_height(306) {
    None => ()
    Some(_) => abort("cube UV height without an env map")
  }
  match @materials.Material::basic().program_env_map_cube_uv_height(
    306,
    scene_environment_height=512,
    has_scene_environment=true,
  ) {
    None => ()
    Some(_) => abort("basic cube UV height from the scene")
  }
  match @materials.Material::lambert().program_env_map_cube_uv_height(
    306,
    scene_environment_height=512,
    has_scene_environment=true,
  ) {
    Some(height) => assert_eq(height, 512)
    None => abort("lambert cube UV height missing")
  }
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.env_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  match shader.program_env_map_cube_uv_height(301) {
    None => ()
    Some(_) => abort("reflection mapping wrote a cube UV height")
  }
  match shader.program_env_map_cube_uv_height(306) {
    Some(height) => assert_eq(height, 1)
    None => abort("shader cube UV height missing")
  }
}

///|
test "Material shader aoMap follows the occlusion texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_ao_map(), false)
  assert_eq(@materials.Material::raw().program_ao_map(), false)
  assert_eq(@materials.Material::standard().program_ao_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.ao_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_ao_map(), true)
  shader.ao_map = None
  assert_eq(shader.program_ao_map(), false)
}

///|
test "Material shader lightMap follows the light texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_light_map(), false)
  assert_eq(@materials.Material::raw().program_light_map(), false)
  assert_eq(@materials.Material::lambert().program_light_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.light_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_light_map(), true)
  shader.light_map = None
  assert_eq(shader.program_light_map(), false)
}

///|
test "Material shader bumpMap turns off for wireframe" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_bump_map(), false)
  assert_eq(@materials.Material::raw().program_bump_map(), false)
  assert_eq(@materials.Material::phong().program_bump_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.bump_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_bump_map(), true)
  shader.wireframe = true
  assert_eq(shader.program_bump_map(), false)
  shader.wireframe = false
  assert_eq(shader.program_bump_map(), true)
  shader.bump_map = None
  assert_eq(shader.program_bump_map(), false)
}

///|
test "Material shader normalMap follows the normal texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_normal_map(), false)
  assert_eq(@materials.Material::raw().program_normal_map(), false)
  assert_eq(@materials.Material::standard().program_normal_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.normal_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_normal_map(), true)
  shader.normal_map = None
  assert_eq(shader.program_normal_map(), false)
}

///|
test "Material shader normalMapObjectSpace follows object space" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_normal_map_object_space(), false)
  assert_eq(@materials.Material::raw().program_normal_map_object_space(), false)
  assert_eq(@materials.Material::standard().program_normal_map_object_space(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.normal_map_type = @constants.ObjectSpace
  assert_eq(shader.program_normal_map_object_space(), false)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.normal_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_normal_map_object_space(), true)
  shader.normal_map_type = @constants.TangentSpace
  assert_eq(shader.program_normal_map_object_space(), false)
  shader.normal_map_type = @constants.ObjectSpace
  assert_eq(shader.program_normal_map_object_space(), true)
  shader.normal_map = None
  assert_eq(shader.program_normal_map_object_space(), false)
}

///|
test "Material shader normalMapTangentSpace follows tangent space" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_normal_map_tangent_space(), false)
  assert_eq(@materials.Material::raw().program_normal_map_tangent_space(), false)
  assert_eq(@materials.Material::standard().program_normal_map_tangent_space(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.normal_map_type = @constants.TangentSpace
  assert_eq(shader.program_normal_map_tangent_space(), false)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.normal_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_normal_map_tangent_space(), true)
  shader.normal_map_type = @constants.ObjectSpace
  assert_eq(shader.program_normal_map_tangent_space(), false)
  shader.normal_map_type = @constants.TangentSpace
  assert_eq(shader.program_normal_map_tangent_space(), true)
  shader.normal_map = None
  assert_eq(shader.program_normal_map_tangent_space(), false)
}

///|
test "Material shader packedNormalMap follows packed RG formats" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_packed_normal_map(1030), false)
  assert_eq(@materials.Material::raw().program_packed_normal_map(37490), false)
  assert_eq(@materials.Material::standard().program_packed_normal_map(36285), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.normal_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_packed_normal_map(1023), false)
  assert_eq(shader.program_packed_normal_map(1028), false)
  assert_eq(shader.program_packed_normal_map(1030), true)
  assert_eq(shader.program_packed_normal_map(37490), true)
  assert_eq(shader.program_packed_normal_map(36285), true)
  assert_eq(shader.program_packed_normal_map(37491), false)
  assert_eq(shader.program_packed_normal_map(36286), false)
  shader.normal_map_type = @constants.ObjectSpace
  assert_eq(shader.program_packed_normal_map(1030), false)
  shader.normal_map_type = @constants.TangentSpace
  assert_eq(shader.program_packed_normal_map(1030), true)
  shader.normal_map = None
  assert_eq(shader.program_packed_normal_map(1030), false)
}

///|
test "Material shader displacementMap follows the displacement texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_displacement_map(), false)
  assert_eq(@materials.Material::raw().program_displacement_map(), false)
  assert_eq(@materials.Material::lambert().program_displacement_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.displacement_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_displacement_map(), true)
  shader.displacement_map = None
  assert_eq(shader.program_displacement_map(), false)
}

///|
test "Material shader emissiveMap follows the emissive texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_emissive_map(), false)
  assert_eq(@materials.Material::raw().program_emissive_map(), false)
  assert_eq(@materials.Material::standard().program_emissive_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.emissive_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_emissive_map(), true)
  shader.emissive_map = None
  assert_eq(shader.program_emissive_map(), false)
}

///|
test "Material shader metalnessMap follows the metalness texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_metalness_map(), false)
  assert_eq(@materials.Material::raw().program_metalness_map(), false)
  assert_eq(@materials.Material::standard().program_metalness_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.metalness_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_metalness_map(), true)
  shader.metalness_map = None
  assert_eq(shader.program_metalness_map(), false)
}

///|
test "Material shader roughnessMap follows the roughness texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_roughness_map(), false)
  assert_eq(@materials.Material::raw().program_roughness_map(), false)
  assert_eq(@materials.Material::standard().program_roughness_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.roughness_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_roughness_map(), true)
  shader.roughness_map = None
  assert_eq(shader.program_roughness_map(), false)
}

///|
test "Material shader anisotropy is true above zero" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_anisotropy(), false)
  assert_eq(@materials.Material::raw().program_anisotropy(), false)
  assert_eq(@materials.Material::physical().program_anisotropy(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.anisotropy = -1.0
  assert_eq(shader.program_anisotropy(), false)
  shader.anisotropy = 0.25
  assert_eq(shader.program_anisotropy(), true)
  shader.anisotropy = 0.0
  assert_eq(shader.program_anisotropy(), false)
}

///|
test "Material shader anisotropyMap needs strength and a texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_anisotropy_map(), false)
  assert_eq(@materials.Material::raw().program_anisotropy_map(), false)
  assert_eq(@materials.Material::physical().program_anisotropy_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.anisotropy_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_anisotropy_map(), false)
  shader.anisotropy = 0.25
  assert_eq(shader.program_anisotropy_map(), true)
  shader.anisotropy = 0.0
  assert_eq(shader.program_anisotropy_map(), false)
  shader.anisotropy = 0.25
  shader.anisotropy_map = None
  assert_eq(shader.program_anisotropy_map(), false)
}

///|
test "Material shader clearcoat is true above zero" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_clearcoat(), false)
  assert_eq(@materials.Material::raw().program_clearcoat(), false)
  assert_eq(@materials.Material::physical().program_clearcoat(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.clearcoat = -1.0
  assert_eq(shader.program_clearcoat(), false)
  shader.clearcoat = 0.25
  assert_eq(shader.program_clearcoat(), true)
  shader.clearcoat = 0.0
  assert_eq(shader.program_clearcoat(), false)
}

///|
test "Material shader clearcoatMap needs strength and a texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_clearcoat_map(), false)
  assert_eq(@materials.Material::raw().program_clearcoat_map(), false)
  assert_eq(@materials.Material::physical().program_clearcoat_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.clearcoat_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_clearcoat_map(), false)
  shader.clearcoat = 0.25
  assert_eq(shader.program_clearcoat_map(), true)
  shader.clearcoat = 0.0
  assert_eq(shader.program_clearcoat_map(), false)
  shader.clearcoat = 0.25
  shader.clearcoat_map = None
  assert_eq(shader.program_clearcoat_map(), false)
}

///|
test "Material shader clearcoatNormalMap needs strength and a texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_clearcoat_normal_map(), false)
  assert_eq(@materials.Material::raw().program_clearcoat_normal_map(), false)
  assert_eq(@materials.Material::physical().program_clearcoat_normal_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.clearcoat_normal_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_clearcoat_normal_map(), false)
  shader.clearcoat = 0.25
  assert_eq(shader.program_clearcoat_normal_map(), true)
  shader.clearcoat = 0.0
  assert_eq(shader.program_clearcoat_normal_map(), false)
  shader.clearcoat = 0.25
  shader.clearcoat_normal_map = None
  assert_eq(shader.program_clearcoat_normal_map(), false)
}

///|
test "Material shader clearcoatRoughnessMap needs strength and a texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_clearcoat_roughness_map(), false)
  assert_eq(@materials.Material::raw().program_clearcoat_roughness_map(), false)
  assert_eq(@materials.Material::physical().program_clearcoat_roughness_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.clearcoat_roughness_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_clearcoat_roughness_map(), false)
  shader.clearcoat = 0.25
  assert_eq(shader.program_clearcoat_roughness_map(), true)
  shader.clearcoat = 0.0
  assert_eq(shader.program_clearcoat_roughness_map(), false)
  shader.clearcoat = 0.25
  shader.clearcoat_roughness_map = None
  assert_eq(shader.program_clearcoat_roughness_map(), false)
}

///|
test "Material shader dispersion is true above zero" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_dispersion(), false)
  assert_eq(@materials.Material::raw().program_dispersion(), false)
  assert_eq(@materials.Material::physical().program_dispersion(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.dispersion = -1.0
  assert_eq(shader.program_dispersion(), false)
  shader.dispersion = 0.25
  assert_eq(shader.program_dispersion(), true)
  shader.dispersion = 0.0
  assert_eq(shader.program_dispersion(), false)
}

///|
test "Material shader retroreflection is true above zero" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_retroreflection(), false)
  assert_eq(@materials.Material::raw().program_retroreflection(), false)
  assert_eq(@materials.Material::physical().program_retroreflection(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.retroreflectivity = -1.0
  assert_eq(shader.program_retroreflection(), false)
  shader.retroreflectivity = 0.25
  assert_eq(shader.program_retroreflection(), true)
  shader.retroreflectivity = 0.0
  assert_eq(shader.program_retroreflection(), false)
}

///|
test "Material shader iridescence is true above zero" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_iridescence(), false)
  assert_eq(@materials.Material::raw().program_iridescence(), false)
  assert_eq(@materials.Material::physical().program_iridescence(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.iridescence = -1.0
  assert_eq(shader.program_iridescence(), false)
  shader.iridescence = 0.25
  assert_eq(shader.program_iridescence(), true)
  shader.iridescence = 0.0
  assert_eq(shader.program_iridescence(), false)
}

///|
test "Material shader iridescenceMap needs strength and a texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_iridescence_map(), false)
  assert_eq(@materials.Material::raw().program_iridescence_map(), false)
  assert_eq(@materials.Material::physical().program_iridescence_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.iridescence_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_iridescence_map(), false)
  shader.iridescence = 0.25
  assert_eq(shader.program_iridescence_map(), true)
  shader.iridescence = 0.0
  assert_eq(shader.program_iridescence_map(), false)
  shader.iridescence = 0.25
  shader.iridescence_map = None
  assert_eq(shader.program_iridescence_map(), false)
}

///|
test "Material shader iridescenceThicknessMap needs strength and a texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_iridescence_thickness_map(), false)
  assert_eq(@materials.Material::raw().program_iridescence_thickness_map(), false)
  assert_eq(@materials.Material::physical().program_iridescence_thickness_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.iridescence_thickness_map = Some(
    @textures.Texture::from_rgba8(1, 1, pixels),
  )
  assert_eq(shader.program_iridescence_thickness_map(), false)
  shader.iridescence = 0.25
  assert_eq(shader.program_iridescence_thickness_map(), true)
  shader.iridescence = 0.0
  assert_eq(shader.program_iridescence_thickness_map(), false)
  shader.iridescence = 0.25
  shader.iridescence_thickness_map = None
  assert_eq(shader.program_iridescence_thickness_map(), false)
}

///|
test "Material shader sheen is true above zero" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_sheen(), false)
  assert_eq(@materials.Material::raw().program_sheen(), false)
  assert_eq(@materials.Material::physical().program_sheen(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.sheen = -1.0
  assert_eq(shader.program_sheen(), false)
  shader.sheen = 0.25
  assert_eq(shader.program_sheen(), true)
  shader.sheen = 0.0
  assert_eq(shader.program_sheen(), false)
}

///|
test "Material shader sheenColorMap needs strength and a texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_sheen_color_map(), false)
  assert_eq(@materials.Material::raw().program_sheen_color_map(), false)
  assert_eq(@materials.Material::physical().program_sheen_color_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.sheen_color_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_sheen_color_map(), false)
  shader.sheen = 0.25
  assert_eq(shader.program_sheen_color_map(), true)
  shader.sheen = 0.0
  assert_eq(shader.program_sheen_color_map(), false)
  shader.sheen = 0.25
  shader.sheen_color_map = None
  assert_eq(shader.program_sheen_color_map(), false)
}

///|
test "Material shader sheenRoughnessMap needs strength and a texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_sheen_roughness_map(), false)
  assert_eq(@materials.Material::raw().program_sheen_roughness_map(), false)
  assert_eq(@materials.Material::physical().program_sheen_roughness_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.sheen_roughness_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_sheen_roughness_map(), false)
  shader.sheen = 0.25
  assert_eq(shader.program_sheen_roughness_map(), true)
  shader.sheen = 0.0
  assert_eq(shader.program_sheen_roughness_map(), false)
  shader.sheen = 0.25
  shader.sheen_roughness_map = None
  assert_eq(shader.program_sheen_roughness_map(), false)
}

///|
test "Material shader specularMap follows the specular texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_specular_map(), false)
  assert_eq(@materials.Material::raw().program_specular_map(), false)
  assert_eq(@materials.Material::phong().program_specular_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.specular_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_specular_map(), true)
  shader.specular_map = None
  assert_eq(shader.program_specular_map(), false)
}

///|
test "Material shader specularColorMap follows the specular color texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_specular_color_map(), false)
  assert_eq(@materials.Material::raw().program_specular_color_map(), false)
  assert_eq(@materials.Material::physical().program_specular_color_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.specular_color_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_specular_color_map(), true)
  shader.specular_color_map = None
  assert_eq(shader.program_specular_color_map(), false)
}

///|
test "Material shader specularIntensityMap follows the intensity texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_specular_intensity_map(), false)
  assert_eq(@materials.Material::raw().program_specular_intensity_map(), false)
  assert_eq(@materials.Material::physical().program_specular_intensity_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.specular_intensity_map = Some(
    @textures.Texture::from_rgba8(1, 1, pixels),
  )
  assert_eq(shader.program_specular_intensity_map(), true)
  shader.specular_intensity_map = None
  assert_eq(shader.program_specular_intensity_map(), false)
}

///|
test "Material shader transmission is true above zero" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_transmission(), false)
  assert_eq(@materials.Material::raw().program_transmission(), false)
  assert_eq(@materials.Material::physical().program_transmission(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.transmission = -1.0
  assert_eq(shader.program_transmission(), false)
  shader.transmission = 0.25
  assert_eq(shader.program_transmission(), true)
  shader.transmission = 0.0
  assert_eq(shader.program_transmission(), false)
}

///|
test "Material shader transmissionMap needs strength and a texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_transmission_map(), false)
  assert_eq(@materials.Material::raw().program_transmission_map(), false)
  assert_eq(@materials.Material::physical().program_transmission_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.transmission_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_transmission_map(), false)
  shader.transmission = 0.25
  assert_eq(shader.program_transmission_map(), true)
  shader.transmission = 0.0
  assert_eq(shader.program_transmission_map(), false)
  shader.transmission = 0.25
  shader.transmission_map = None
  assert_eq(shader.program_transmission_map(), false)
}

///|
test "Material shader thicknessMap needs transmission and a texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_thickness_map(), false)
  assert_eq(@materials.Material::raw().program_thickness_map(), false)
  assert_eq(@materials.Material::physical().program_thickness_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.thickness_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_thickness_map(), false)
  shader.transmission = 0.25
  assert_eq(shader.program_thickness_map(), true)
  shader.transmission = 0.0
  assert_eq(shader.program_thickness_map(), false)
  shader.transmission = 0.25
  shader.thickness_map = None
  assert_eq(shader.program_thickness_map(), false)
}

///|
test "Material shader gradientMap follows the gradient texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_gradient_map(), false)
  assert_eq(@materials.Material::raw().program_gradient_map(), false)
  assert_eq(@materials.Material::toon().program_gradient_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.gradient_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_gradient_map(), true)
  shader.gradient_map = None
  assert_eq(shader.program_gradient_map(), false)
}

///|
test "Material shader opaque needs normal blending" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_opaque(), true)
  assert_eq(@materials.Material::raw().program_opaque(), true)
  assert_eq(@materials.Material::basic().program_opaque(), true)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.transparent = true
  assert_eq(shader.program_opaque(), false)
  shader.transparent = false
  assert_eq(shader.program_opaque(), true)
  shader.blending = @constants.Additive
  assert_eq(shader.program_opaque(), false)
  shader.blending = @constants.Normal
  assert_eq(shader.program_opaque(), true)
  shader.alpha_to_coverage = true
  assert_eq(shader.program_opaque(), false)
  shader.alpha_to_coverage = false
  assert_eq(shader.program_opaque(), true)
}

///|
test "Material shader alphaMap follows the alpha texture" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_alpha_map(), false)
  assert_eq(@materials.Material::raw().program_alpha_map(), false)
  assert_eq(@materials.Material::basic().program_alpha_map(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.alpha_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_alpha_map(), true)
  shader.alpha_map = None
  assert_eq(shader.program_alpha_map(), false)
}

///|
test "Material shader alphaTest is true above zero" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_alpha_test(), false)
  assert_eq(@materials.Material::raw().program_alpha_test(), false)
  assert_eq(@materials.Material::basic().program_alpha_test(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.alpha_test = -1.0
  assert_eq(shader.program_alpha_test(), false)
  shader.alpha_test = 0.25
  assert_eq(shader.program_alpha_test(), true)
  shader.alpha_test = 0.0
  assert_eq(shader.program_alpha_test(), false)
}

///|
test "Material shader alphaHash follows the flag" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_alpha_hash(), false)
  assert_eq(@materials.Material::raw().program_alpha_hash(), false)
  assert_eq(@materials.Material::basic().program_alpha_hash(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.alpha_hash = true
  assert_eq(shader.program_alpha_hash(), true)
  shader.alpha_hash = false
  assert_eq(shader.program_alpha_hash(), false)
}

///|
test "Material shader combine returns the operation" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_combine() is @constants.Multiply, true)
  assert_eq(shader.program_combine().to_int(), 0)
  assert_eq(@materials.Material::raw().program_combine().to_int(), 0)
  assert_eq(@materials.Material::phong().program_combine().to_int(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.combine = @constants.Mix
  assert_eq(shader.program_combine() is @constants.Mix, true)
  assert_eq(shader.program_combine().to_int(), 1)
  shader.combine = @constants.Add
  assert_eq(shader.program_combine() is @constants.Add, true)
  assert_eq(shader.program_combine().to_int(), 2)
  shader.combine = @constants.Multiply
  assert_eq(shader.program_combine().to_int(), 0)
}

///|
test "Material shader mapUv names the color texture channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_map_uv(), "false")
  assert_eq(@materials.Material::basic().program_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.program_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_map_uv(), "uv2")
  shader.map = None
  assert_eq(shader.program_map_uv(), "false")
}

///|
test "Material shader aoMapUv names the occlusion texture channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_ao_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_ao_map_uv(), "false")
  assert_eq(@materials.Material::standard().program_ao_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.ao_map = Some(map)
  assert_eq(shader.program_ao_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_ao_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_ao_map_uv(), "uv2")
  shader.ao_map = None
  assert_eq(shader.program_ao_map_uv(), "false")
}

///|
test "Material shader lightMapUv names the light texture channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_light_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_light_map_uv(), "false")
  assert_eq(@materials.Material::lambert().program_light_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.light_map = Some(map)
  assert_eq(shader.program_light_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_light_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_light_map_uv(), "uv2")
  shader.light_map = None
  assert_eq(shader.program_light_map_uv(), "false")
}

///|
test "Material shader bumpMapUv turns off for wireframe" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_bump_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_bump_map_uv(), "false")
  assert_eq(@materials.Material::phong().program_bump_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.bump_map = Some(map)
  assert_eq(shader.program_bump_map_uv(), "uv")
  shader.wireframe = true
  assert_eq(shader.program_bump_map_uv(), "false")
  shader.wireframe = false
  map.channel = 1
  assert_eq(shader.program_bump_map_uv(), "uv1")
  shader.bump_map = None
  assert_eq(shader.program_bump_map_uv(), "false")
}

///|
test "Material shader normalMapUv names the normal texture channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_normal_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_normal_map_uv(), "false")
  assert_eq(@materials.Material::standard().program_normal_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.normal_map = Some(map)
  assert_eq(shader.program_normal_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_normal_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_normal_map_uv(), "uv2")
  shader.normal_map = None
  assert_eq(shader.program_normal_map_uv(), "false")
}

///|
test "Material shader displacementMapUv names the displacement texture channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_displacement_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_displacement_map_uv(), "false")
  assert_eq(@materials.Material::lambert().program_displacement_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.displacement_map = Some(map)
  assert_eq(shader.program_displacement_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_displacement_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_displacement_map_uv(), "uv2")
  shader.displacement_map = None
  assert_eq(shader.program_displacement_map_uv(), "false")
}

///|
test "Material shader emissiveMapUv names the emissive texture channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_emissive_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_emissive_map_uv(), "false")
  assert_eq(@materials.Material::standard().program_emissive_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.emissive_map = Some(map)
  assert_eq(shader.program_emissive_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_emissive_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_emissive_map_uv(), "uv2")
  shader.emissive_map = None
  assert_eq(shader.program_emissive_map_uv(), "false")
}

///|
test "Material shader metalnessMapUv names the metalness texture channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_metalness_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_metalness_map_uv(), "false")
  assert_eq(@materials.Material::standard().program_metalness_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.metalness_map = Some(map)
  assert_eq(shader.program_metalness_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_metalness_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_metalness_map_uv(), "uv2")
  shader.metalness_map = None
  assert_eq(shader.program_metalness_map_uv(), "false")
}

///|
test "Material shader roughnessMapUv names the roughness texture channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_roughness_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_roughness_map_uv(), "false")
  assert_eq(@materials.Material::standard().program_roughness_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.roughness_map = Some(map)
  assert_eq(shader.program_roughness_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_roughness_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_roughness_map_uv(), "uv2")
  shader.roughness_map = None
  assert_eq(shader.program_roughness_map_uv(), "false")
}

///|
test "Material shader anisotropyMapUv needs strength and a channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_anisotropy_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_anisotropy_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_anisotropy_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.anisotropy_map = Some(map)
  assert_eq(shader.program_anisotropy_map_uv(), "false")
  shader.anisotropy = 0.25
  assert_eq(shader.program_anisotropy_map_uv(), "uv")
  shader.anisotropy = 0.0
  assert_eq(shader.program_anisotropy_map_uv(), "false")
  shader.anisotropy = 0.25
  map.channel = 1
  assert_eq(shader.program_anisotropy_map_uv(), "uv1")
  shader.anisotropy_map = None
  assert_eq(shader.program_anisotropy_map_uv(), "false")
}

///|
test "Material shader clearcoatMapUv needs strength and a channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_clearcoat_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_clearcoat_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_clearcoat_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.clearcoat_map = Some(map)
  assert_eq(shader.program_clearcoat_map_uv(), "false")
  shader.clearcoat = 0.25
  assert_eq(shader.program_clearcoat_map_uv(), "uv")
  shader.clearcoat = 0.0
  assert_eq(shader.program_clearcoat_map_uv(), "false")
  shader.clearcoat = 0.25
  map.channel = 1
  assert_eq(shader.program_clearcoat_map_uv(), "uv1")
  shader.clearcoat_map = None
  assert_eq(shader.program_clearcoat_map_uv(), "false")
}

///|
test "Material shader clearcoatNormalMapUv needs strength and a channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_clearcoat_normal_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_clearcoat_normal_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_clearcoat_normal_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.clearcoat_normal_map = Some(map)
  assert_eq(shader.program_clearcoat_normal_map_uv(), "false")
  shader.clearcoat = 0.25
  assert_eq(shader.program_clearcoat_normal_map_uv(), "uv")
  shader.clearcoat = 0.0
  assert_eq(shader.program_clearcoat_normal_map_uv(), "false")
  shader.clearcoat = 0.25
  map.channel = 1
  assert_eq(shader.program_clearcoat_normal_map_uv(), "uv1")
  shader.clearcoat_normal_map = None
  assert_eq(shader.program_clearcoat_normal_map_uv(), "false")
}

///|
test "Material shader clearcoatRoughnessMapUv needs strength and a channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_clearcoat_roughness_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_clearcoat_roughness_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_clearcoat_roughness_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.clearcoat_roughness_map = Some(map)
  assert_eq(shader.program_clearcoat_roughness_map_uv(), "false")
  shader.clearcoat = 0.25
  assert_eq(shader.program_clearcoat_roughness_map_uv(), "uv")
  shader.clearcoat = 0.0
  assert_eq(shader.program_clearcoat_roughness_map_uv(), "false")
  shader.clearcoat = 0.25
  map.channel = 1
  assert_eq(shader.program_clearcoat_roughness_map_uv(), "uv1")
  shader.clearcoat_roughness_map = None
  assert_eq(shader.program_clearcoat_roughness_map_uv(), "false")
}

///|
test "Material shader iridescenceMapUv needs strength and a channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_iridescence_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_iridescence_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_iridescence_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.iridescence_map = Some(map)
  assert_eq(shader.program_iridescence_map_uv(), "false")
  shader.iridescence = 0.25
  assert_eq(shader.program_iridescence_map_uv(), "uv")
  shader.iridescence = 0.0
  assert_eq(shader.program_iridescence_map_uv(), "false")
  shader.iridescence = 0.25
  map.channel = 1
  assert_eq(shader.program_iridescence_map_uv(), "uv1")
  shader.iridescence_map = None
  assert_eq(shader.program_iridescence_map_uv(), "false")
}

///|
test "Material shader iridescenceThicknessMapUv needs strength and a channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_iridescence_thickness_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_iridescence_thickness_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_iridescence_thickness_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.iridescence_thickness_map = Some(map)
  assert_eq(shader.program_iridescence_thickness_map_uv(), "false")
  shader.iridescence = 0.25
  assert_eq(shader.program_iridescence_thickness_map_uv(), "uv")
  shader.iridescence = 0.0
  assert_eq(shader.program_iridescence_thickness_map_uv(), "false")
  shader.iridescence = 0.25
  map.channel = 1
  assert_eq(shader.program_iridescence_thickness_map_uv(), "uv1")
  shader.iridescence_thickness_map = None
  assert_eq(shader.program_iridescence_thickness_map_uv(), "false")
}

///|
test "Material shader sheenColorMapUv needs strength and a channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_sheen_color_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_sheen_color_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_sheen_color_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.sheen_color_map = Some(map)
  assert_eq(shader.program_sheen_color_map_uv(), "false")
  shader.sheen = 0.25
  assert_eq(shader.program_sheen_color_map_uv(), "uv")
  shader.sheen = 0.0
  assert_eq(shader.program_sheen_color_map_uv(), "false")
  shader.sheen = 0.25
  map.channel = 1
  assert_eq(shader.program_sheen_color_map_uv(), "uv1")
  shader.sheen_color_map = None
  assert_eq(shader.program_sheen_color_map_uv(), "false")
}

///|
test "Material shader sheenRoughnessMapUv needs strength and a channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_sheen_roughness_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_sheen_roughness_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_sheen_roughness_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.sheen_roughness_map = Some(map)
  assert_eq(shader.program_sheen_roughness_map_uv(), "false")
  shader.sheen = 0.25
  assert_eq(shader.program_sheen_roughness_map_uv(), "uv")
  shader.sheen = 0.0
  assert_eq(shader.program_sheen_roughness_map_uv(), "false")
  shader.sheen = 0.25
  map.channel = 1
  assert_eq(shader.program_sheen_roughness_map_uv(), "uv1")
  shader.sheen_roughness_map = None
  assert_eq(shader.program_sheen_roughness_map_uv(), "false")
}

///|
test "Material shader specularMapUv names the specular texture channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_specular_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_specular_map_uv(), "false")
  assert_eq(@materials.Material::lambert().program_specular_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.specular_map = Some(map)
  assert_eq(shader.program_specular_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_specular_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_specular_map_uv(), "uv2")
  shader.specular_map = None
  assert_eq(shader.program_specular_map_uv(), "false")
}

///|
test "Material shader specularColorMapUv names the specular color channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_specular_color_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_specular_color_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_specular_color_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.specular_color_map = Some(map)
  assert_eq(shader.program_specular_color_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_specular_color_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_specular_color_map_uv(), "uv2")
  shader.specular_color_map = None
  assert_eq(shader.program_specular_color_map_uv(), "false")
}

///|
test "Material shader specularIntensityMapUv names the intensity channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_specular_intensity_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_specular_intensity_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_specular_intensity_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.specular_intensity_map = Some(map)
  assert_eq(shader.program_specular_intensity_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_specular_intensity_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_specular_intensity_map_uv(), "uv2")
  shader.specular_intensity_map = None
  assert_eq(shader.program_specular_intensity_map_uv(), "false")
}

///|
test "Material shader transmissionMapUv needs strength and a channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_transmission_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_transmission_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_transmission_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.transmission_map = Some(map)
  assert_eq(shader.program_transmission_map_uv(), "false")
  shader.transmission = 0.25
  assert_eq(shader.program_transmission_map_uv(), "uv")
  shader.transmission = 0.0
  assert_eq(shader.program_transmission_map_uv(), "false")
  shader.transmission = 0.25
  map.channel = 1
  assert_eq(shader.program_transmission_map_uv(), "uv1")
  shader.transmission_map = None
  assert_eq(shader.program_transmission_map_uv(), "false")
}

///|
test "Material shader thicknessMapUv needs transmission and a channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_thickness_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_thickness_map_uv(), "false")
  assert_eq(@materials.Material::physical().program_thickness_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.thickness_map = Some(map)
  assert_eq(shader.program_thickness_map_uv(), "false")
  shader.transmission = 0.25
  assert_eq(shader.program_thickness_map_uv(), "uv")
  shader.transmission = 0.0
  assert_eq(shader.program_thickness_map_uv(), "false")
  shader.transmission = 0.25
  map.channel = 1
  assert_eq(shader.program_thickness_map_uv(), "uv1")
  shader.thickness_map = None
  assert_eq(shader.program_thickness_map_uv(), "false")
}

///|
test "Material shader alphaMapUv names the alpha texture channel" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_alpha_map_uv(), "false")
  assert_eq(@materials.Material::raw().program_alpha_map_uv(), "false")
  assert_eq(@materials.Material::basic().program_alpha_map_uv(), "false")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.alpha_map = Some(map)
  assert_eq(shader.program_alpha_map_uv(), "uv")
  map.channel = 1
  assert_eq(shader.program_alpha_map_uv(), "uv1")
  map.channel = 2
  assert_eq(shader.program_alpha_map_uv(), "uv2")
  shader.alpha_map = None
  assert_eq(shader.program_alpha_map_uv(), "false")
}

///|
test "Material shader vertexTangents needs a tangent and a normal source" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_vertex_tangents(), false)
  assert_eq(@materials.Material::raw().program_vertex_tangents(), false)
  assert_eq(@materials.Material::physical().program_vertex_tangents(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_vertex_tangents(has_tangent=true), false)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.normal_map = Some(map)
  assert_eq(shader.program_vertex_tangents(), false)
  assert_eq(shader.program_vertex_tangents(has_tangent=true), true)
  shader.normal_map = None
  shader.anisotropy = 0.25
  assert_eq(shader.program_vertex_tangents(has_tangent=true), true)
  shader.anisotropy = 0.0
  assert_eq(shader.program_vertex_tangents(has_tangent=true), false)
}

///|
test "Material shader vertexNormals reads the geometry normal attribute" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_vertex_normals(), false)
  assert_eq(@materials.Material::raw().program_vertex_normals(), false)
  assert_eq(@materials.Material::basic().program_vertex_normals(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_vertex_normals(has_normal=true), true)
  assert_eq(shader.program_vertex_normals(has_normal=false), false)
  shader.vertex_colors = true
  assert_eq(shader.program_vertex_normals(has_normal=true), true)
}

///|
test "Material shader vertexColors reads the material flag" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_vertex_colors(), false)
  assert_eq(@materials.Material::raw().program_vertex_colors(), false)
  assert_eq(@materials.Material::basic().program_vertex_colors(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.vertex_colors = true
  assert_eq(shader.program_vertex_colors(), true)
  shader.vertex_colors = false
  assert_eq(shader.program_vertex_colors(), false)
}

///|
test "Material shader vertexAlphas needs colors and a four-wide attribute" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_vertex_alphas(), false)
  assert_eq(@materials.Material::raw().program_vertex_alphas(), false)
  assert_eq(@materials.Material::basic().program_vertex_alphas(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.vertex_colors = true
  assert_eq(shader.program_vertex_alphas(), false)
  assert_eq(shader.program_vertex_alphas(has_vertex_alpha=true), true)
  shader.vertex_colors = false
  assert_eq(shader.program_vertex_alphas(has_vertex_alpha=true), false)
}

///|
test "Material shader pointsUvs needs points, a uv, and a map" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_points_uvs(), false)
  assert_eq(@materials.Material::raw().program_points_uvs(), false)
  assert_eq(@materials.Material::basic().program_points_uvs(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_points_uvs(has_points_uv=true), false)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.program_points_uvs(), false)
  assert_eq(shader.program_points_uvs(has_points_uv=true), true)
  shader.map = None
  let alpha = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.alpha_map = Some(alpha)
  assert_eq(shader.program_points_uvs(has_points_uv=true), true)
  shader.alpha_map = None
  assert_eq(shader.program_points_uvs(has_points_uv=true), false)
}

///|
test "Material shader fog reads the scene fog" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  assert_eq(shader.program_fog(), false)
  assert_eq(@materials.Material::raw().program_fog(), false)
  assert_eq(basic.program_fog(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_fog(has_fog=true), true)
  shader.fog = true
  assert_eq(shader.program_fog(), false)
  basic.fog = false
  assert_eq(basic.program_fog(has_fog=true), true)
}

///|
test "Material shader useFog reads the material flag" {
  let shader = @materials.Material::shader()
  let basic = @materials.Material::basic()
  assert_eq(shader.program_use_fog(), false)
  assert_eq(@materials.Material::raw().program_use_fog(), false)
  assert_eq(basic.program_use_fog(), true)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.fog = true
  assert_eq(shader.program_use_fog(), true)
  shader.fog = false
  assert_eq(shader.program_use_fog(), false)
  assert_eq(shader.program_fog(has_fog=true), true)
}

///|
test "Material shader fogExp2 needs scene fog of that kind" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_fog_exp2(), false)
  assert_eq(@materials.Material::raw().program_fog_exp2(), false)
  assert_eq(@materials.Material::basic().program_fog_exp2(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_fog_exp2(has_fog=true), false)
  assert_eq(shader.program_fog_exp2(fog_exp2=true), false)
  assert_eq(shader.program_fog_exp2(has_fog=true, fog_exp2=true), true)
  shader.fog = true
  assert_eq(shader.program_fog_exp2(), false)
  shader.fog = false
  assert_eq(shader.program_fog_exp2(has_fog=true, fog_exp2=true), true)
}

///|
test "Material shader flatShading skips wireframes and derived lit meshes" {
  let shader = @materials.Material::shader()
  let lambert = @materials.Material::lambert()
  assert_eq(shader.program_flat_shading(), false)
  assert_eq(@materials.Material::raw().program_flat_shading(), false)
  assert_eq(@materials.Material::basic().program_flat_shading(), false)
  assert_eq(@materials.Material::toon().program_flat_shading(), false)
  assert_eq(lambert.program_flat_shading(), true)
  assert_eq(@materials.Material::phong().program_flat_shading(), true)
  assert_eq(@materials.Material::standard().program_flat_shading(), true)
  assert_eq(@materials.Material::physical().program_flat_shading(), true)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(lambert.program_flat_shading(has_normal=true), false)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  lambert.normal_map = Some(map)
  assert_eq(lambert.program_flat_shading(), false)
  lambert.normal_map = None
  shader.flat_shading = true
  assert_eq(shader.program_flat_shading(), true)
  shader.wireframe = true
  assert_eq(shader.program_flat_shading(), false)
  lambert.flat_shading = true
  lambert.wireframe = true
  assert_eq(lambert.program_flat_shading(has_normal=true), false)
  lambert.wireframe = false
  assert_eq(lambert.program_flat_shading(has_normal=true), true)
}

///|
test "Material shader sizeAttenuation is only on points and sprites" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_size_attenuation(), false)
  assert_eq(@materials.Material::raw().program_size_attenuation(), false)
  assert_eq(@materials.Material::basic().program_size_attenuation(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let points = @materials.PointsMaterial::new()
  assert_eq(points.program_size_attenuation(), true)
  points.size_attenuation = false
  assert_eq(points.program_size_attenuation(), false)
  points.size_attenuation = true
  assert_eq(points.program_size_attenuation(), true)
  let sprite = @materials.SpriteMaterial::new()
  assert_eq(sprite.program_size_attenuation(), true)
  sprite.size_attenuation = false
  assert_eq(sprite.program_size_attenuation(), false)
}

///|
test "Material shader logarithmicDepthBuffer reads the renderer flag" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_logarithmic_depth_buffer(), false)
  assert_eq(@materials.Material::raw().program_logarithmic_depth_buffer(), false)
  assert_eq(@materials.Material::basic().program_logarithmic_depth_buffer(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_logarithmic_depth_buffer(logarithmic_depth_buffer=true), true)
  assert_eq(shader.program_logarithmic_depth_buffer(logarithmic_depth_buffer=false), false)
}

///|
test "Material shader reversedDepthBuffer reads the renderer flag" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_reversed_depth_buffer(), false)
  assert_eq(@materials.Material::raw().program_reversed_depth_buffer(), false)
  assert_eq(@materials.Material::basic().program_reversed_depth_buffer(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_reversed_depth_buffer(reversed_depth_buffer=true), true)
  assert_eq(shader.program_reversed_depth_buffer(reversed_depth_buffer=false), false)
  assert_eq(shader.program_logarithmic_depth_buffer(logarithmic_depth_buffer=true), true)
  assert_eq(shader.program_reversed_depth_buffer(), false)
}

///|
test "Material shader skinning reads whether the object is skinned" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_skinning(), false)
  assert_eq(@materials.Material::raw().program_skinning(), false)
  assert_eq(@materials.Material::basic().program_skinning(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_skinning(has_skinning=true), true)
  assert_eq(shader.program_skinning(has_skinning=false), false)
  assert_eq(shader.program_reversed_depth_buffer(reversed_depth_buffer=true), true)
  assert_eq(shader.program_skinning(), false)
}

///|
test "Material shader hasPositionAttribute reads the geometry position" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_has_position_attribute(), false)
  assert_eq(@materials.Material::raw().program_has_position_attribute(), false)
  assert_eq(@materials.Material::basic().program_has_position_attribute(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_has_position_attribute(has_position=true), true)
  assert_eq(shader.program_has_position_attribute(has_position=false), false)
  assert_eq(shader.program_skinning(has_skinning=true), true)
  assert_eq(shader.program_has_position_attribute(), false)
}

///|
test "Material shader morphTargets reads position morph attributes" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_morph_targets(), false)
  assert_eq(@materials.Material::raw().program_morph_targets(), false)
  assert_eq(@materials.Material::basic().program_morph_targets(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_morph_targets(has_morph_targets=true), true)
  assert_eq(shader.program_morph_targets(has_morph_targets=false), false)
  assert_eq(shader.program_has_position_attribute(has_position=true), true)
  assert_eq(shader.program_morph_targets(), false)
}

///|
test "Material shader morphNormals reads normal morph attributes" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_morph_normals(), false)
  assert_eq(@materials.Material::raw().program_morph_normals(), false)
  assert_eq(@materials.Material::basic().program_morph_normals(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_morph_normals(has_morph_normals=true), true)
  assert_eq(shader.program_morph_normals(has_morph_normals=false), false)
  assert_eq(shader.program_morph_targets(has_morph_targets=true), true)
  assert_eq(shader.program_morph_normals(), false)
}

///|
test "Material shader morphColors reads color morph attributes" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_morph_colors(), false)
  assert_eq(@materials.Material::raw().program_morph_colors(), false)
  assert_eq(@materials.Material::basic().program_morph_colors(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_morph_colors(has_morph_colors=true), true)
  assert_eq(shader.program_morph_colors(has_morph_colors=false), false)
  assert_eq(shader.program_morph_normals(has_morph_normals=true), true)
  assert_eq(shader.program_morph_colors(), false)
}

///|
test "Material shader morphTargetsCount prefers position then normal then color" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_morph_targets_count(), 0)
  assert_eq(@materials.Material::raw().program_morph_targets_count(), 0)
  assert_eq(@materials.Material::basic().program_morph_targets_count(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.program_morph_targets_count(
      position_count=Some(3),
      normal_count=Some(2),
      color_count=Some(4),
    ),
    3,
  )
  assert_eq(shader.program_morph_targets_count(normal_count=Some(2)), 2)
  assert_eq(shader.program_morph_targets_count(color_count=Some(4)), 4)
  assert_eq(
    shader.program_morph_targets_count(position_count=Some(0), normal_count=Some(5)),
    0,
  )
  assert_eq(shader.program_morph_colors(has_morph_colors=true), true)
  assert_eq(shader.program_morph_targets_count(), 0)
}

///|
test "Material shader morphTextureStride lets later attributes overwrite" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_morph_texture_stride(), 0)
  assert_eq(@materials.Material::raw().program_morph_texture_stride(), 0)
  assert_eq(@materials.Material::basic().program_morph_texture_stride(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_morph_texture_stride(has_position_morph=true), 1)
  assert_eq(
    shader.program_morph_texture_stride(has_position_morph=true, has_normal_morph=true),
    2,
  )
  assert_eq(
    shader.program_morph_texture_stride(
      has_position_morph=true,
      has_normal_morph=true,
      has_color_morph=true,
    ),
    3,
  )
  assert_eq(shader.program_morph_texture_stride(has_color_morph=true), 3)
  assert_eq(shader.program_morph_texture_stride(has_normal_morph=true), 2)
  assert_eq(shader.program_morph_targets_count(position_count=Some(4)), 4)
  assert_eq(shader.program_morph_texture_stride(), 0)
}

///|
test "Material shader numSunLights reads the sun light count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_sun_lights(), 0)
  assert_eq(@materials.Material::raw().program_num_sun_lights(), 0)
  assert_eq(@materials.Material::basic().program_num_sun_lights(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_sun_lights(num_sun_lights=2), 2)
  assert_eq(shader.program_num_sun_lights(num_sun_lights=0), 0)
  assert_eq(shader.program_morph_texture_stride(has_color_morph=true), 3)
  assert_eq(shader.program_num_sun_lights(), 0)
}

///|
test "Material shader numDirLights reads the directional light count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_dir_lights(), 0)
  assert_eq(@materials.Material::raw().program_num_dir_lights(), 0)
  assert_eq(@materials.Material::basic().program_num_dir_lights(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_dir_lights(num_dir_lights=3), 3)
  assert_eq(shader.program_num_dir_lights(num_dir_lights=0), 0)
  assert_eq(shader.program_num_sun_lights(num_sun_lights=2), 2)
  assert_eq(shader.program_num_dir_lights(), 0)
}

///|
test "Material shader numPointLights reads the point light count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_point_lights(), 0)
  assert_eq(@materials.Material::raw().program_num_point_lights(), 0)
  assert_eq(@materials.Material::basic().program_num_point_lights(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_point_lights(num_point_lights=4), 4)
  assert_eq(shader.program_num_point_lights(num_point_lights=0), 0)
  assert_eq(shader.program_num_dir_lights(num_dir_lights=3), 3)
  assert_eq(shader.program_num_point_lights(), 0)
}

///|
test "Material shader numSpotLights reads the spot light count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_spot_lights(), 0)
  assert_eq(@materials.Material::raw().program_num_spot_lights(), 0)
  assert_eq(@materials.Material::basic().program_num_spot_lights(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_spot_lights(num_spot_lights=2), 2)
  assert_eq(shader.program_num_spot_lights(num_spot_lights=0), 0)
  assert_eq(shader.program_num_point_lights(num_point_lights=4), 4)
  assert_eq(shader.program_num_spot_lights(), 0)
}

///|
test "Material shader numSpotLightMaps reads the spot light map count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_spot_light_maps(), 0)
  assert_eq(@materials.Material::raw().program_num_spot_light_maps(), 0)
  assert_eq(@materials.Material::basic().program_num_spot_light_maps(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_spot_light_maps(num_spot_light_maps=1), 1)
  assert_eq(shader.program_num_spot_light_maps(num_spot_light_maps=0), 0)
  assert_eq(shader.program_num_spot_lights(num_spot_lights=2), 2)
  assert_eq(shader.program_num_spot_light_maps(), 0)
}

///|
test "Material shader numRectAreaLights reads the rect area light count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_rect_area_lights(), 0)
  assert_eq(@materials.Material::raw().program_num_rect_area_lights(), 0)
  assert_eq(@materials.Material::basic().program_num_rect_area_lights(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_rect_area_lights(num_rect_area_lights=2), 2)
  assert_eq(shader.program_num_rect_area_lights(num_rect_area_lights=0), 0)
  assert_eq(shader.program_num_spot_light_maps(num_spot_light_maps=1), 1)
  assert_eq(shader.program_num_rect_area_lights(), 0)
}

///|
test "Material shader numHemiLights reads the hemisphere light count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_hemi_lights(), 0)
  assert_eq(@materials.Material::raw().program_num_hemi_lights(), 0)
  assert_eq(@materials.Material::basic().program_num_hemi_lights(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_hemi_lights(num_hemi_lights=1), 1)
  assert_eq(shader.program_num_hemi_lights(num_hemi_lights=0), 0)
  assert_eq(shader.program_num_rect_area_lights(num_rect_area_lights=2), 2)
  assert_eq(shader.program_num_hemi_lights(), 0)
}

///|
test "Material shader numSunLightShadows reads the sun shadow count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_sun_light_shadows(), 0)
  assert_eq(@materials.Material::raw().program_num_sun_light_shadows(), 0)
  assert_eq(@materials.Material::basic().program_num_sun_light_shadows(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_sun_light_shadows(num_sun_light_shadows=1), 1)
  assert_eq(shader.program_num_sun_light_shadows(num_sun_light_shadows=0), 0)
  assert_eq(shader.program_num_sun_lights(num_sun_lights=2), 2)
  assert_eq(shader.program_num_sun_light_shadows(), 0)
}

///|
test "Material shader numDirLightShadows reads the directional shadow count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_dir_light_shadows(), 0)
  assert_eq(@materials.Material::raw().program_num_dir_light_shadows(), 0)
  assert_eq(@materials.Material::basic().program_num_dir_light_shadows(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_dir_light_shadows(num_dir_light_shadows=2), 2)
  assert_eq(shader.program_num_dir_light_shadows(num_dir_light_shadows=0), 0)
  assert_eq(shader.program_num_dir_lights(num_dir_lights=3), 3)
  assert_eq(shader.program_num_dir_light_shadows(), 0)
}

///|
test "Material shader numPointLightShadows reads the point shadow count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_point_light_shadows(), 0)
  assert_eq(@materials.Material::raw().program_num_point_light_shadows(), 0)
  assert_eq(@materials.Material::basic().program_num_point_light_shadows(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_point_light_shadows(num_point_light_shadows=3), 3)
  assert_eq(shader.program_num_point_light_shadows(num_point_light_shadows=0), 0)
  assert_eq(shader.program_num_point_lights(num_point_lights=4), 4)
  assert_eq(shader.program_num_point_light_shadows(), 0)
}

///|
test "Material shader numSpotLightShadows reads the spot shadow count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_spot_light_shadows(), 0)
  assert_eq(@materials.Material::raw().program_num_spot_light_shadows(), 0)
  assert_eq(@materials.Material::basic().program_num_spot_light_shadows(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_spot_light_shadows(num_spot_light_shadows=2), 2)
  assert_eq(shader.program_num_spot_light_shadows(num_spot_light_shadows=0), 0)
  assert_eq(shader.program_num_spot_lights(num_spot_lights=2), 2)
  assert_eq(shader.program_num_spot_light_shadows(), 0)
}

///|
test "Material shader numSpotLightShadowsWithMaps reads that shadow count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_spot_light_shadows_with_maps(), 0)
  assert_eq(@materials.Material::raw().program_num_spot_light_shadows_with_maps(), 0)
  assert_eq(@materials.Material::basic().program_num_spot_light_shadows_with_maps(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.program_num_spot_light_shadows_with_maps(num_spot_light_shadows_with_maps=1),
    1,
  )
  assert_eq(
    shader.program_num_spot_light_shadows_with_maps(num_spot_light_shadows_with_maps=0),
    0,
  )
  assert_eq(shader.program_num_spot_light_shadows(num_spot_light_shadows=2), 2)
  assert_eq(shader.program_num_spot_light_shadows_with_maps(), 0)
}

///|
test "Material shader numLightProbes reads the light probe count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_light_probes(), 0)
  assert_eq(@materials.Material::raw().program_num_light_probes(), 0)
  assert_eq(@materials.Material::basic().program_num_light_probes(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_light_probes(num_light_probes=2), 2)
  assert_eq(shader.program_num_light_probes(num_light_probes=0), 0)
  assert_eq(
    shader.program_num_spot_light_shadows_with_maps(num_spot_light_shadows_with_maps=1),
    1,
  )
  assert_eq(shader.program_num_light_probes(), 0)
}

///|
test "Material shader numLightProbeGrids reads the probe grid count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_light_probe_grids(), 0)
  assert_eq(@materials.Material::raw().program_num_light_probe_grids(), 0)
  assert_eq(@materials.Material::basic().program_num_light_probe_grids(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_light_probe_grids(num_light_probe_grids=2), 2)
  assert_eq(shader.program_num_light_probe_grids(num_light_probe_grids=0), 0)
  assert_eq(shader.program_num_light_probes(num_light_probes=2), 2)
  assert_eq(shader.program_num_light_probe_grids(), 0)
}

///|
test "Material shader numClippingPlanes reads the clipping plane count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_clipping_planes(), 0)
  assert_eq(@materials.Material::raw().program_num_clipping_planes(), 0)
  assert_eq(@materials.Material::basic().program_num_clipping_planes(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_clipping_planes(num_clipping_planes=3), 3)
  assert_eq(shader.program_num_clipping_planes(num_clipping_planes=0), 0)
  assert_eq(shader.program_num_light_probe_grids(num_light_probe_grids=2), 2)
  assert_eq(shader.program_num_clipping_planes(), 0)
}

///|
test "Material shader numClipIntersection reads the intersection count" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_num_clip_intersection(), 0)
  assert_eq(@materials.Material::raw().program_num_clip_intersection(), 0)
  assert_eq(@materials.Material::basic().program_num_clip_intersection(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_num_clip_intersection(num_clip_intersection=2), 2)
  assert_eq(shader.program_num_clip_intersection(num_clip_intersection=0), 0)
  assert_eq(shader.program_num_clipping_planes(num_clipping_planes=3), 3)
  assert_eq(shader.program_num_clip_intersection(), 0)
}

///|
test "Material shader dithering reads the material flag" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_dithering(), false)
  assert_eq(@materials.Material::raw().program_dithering(), false)
  assert_eq(@materials.Material::basic().program_dithering(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.dithering = true
  assert_eq(shader.program_dithering(), true)
  shader.dithering = false
  assert_eq(shader.program_dithering(), false)
  assert_eq(shader.program_num_clip_intersection(num_clip_intersection=2), 2)
  assert_eq(shader.program_dithering(), false)
}

///|
test "Material shader shadowMapEnabled needs the renderer flag and a shadow" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_shadow_map_enabled(), false)
  assert_eq(@materials.Material::raw().program_shadow_map_enabled(), false)
  assert_eq(@materials.Material::basic().program_shadow_map_enabled(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_shadow_map_enabled(shadow_map_enabled=true), false)
  assert_eq(shader.program_shadow_map_enabled(has_shadows=true), false)
  assert_eq(
    shader.program_shadow_map_enabled(shadow_map_enabled=true, has_shadows=true),
    true,
  )
  shader.dithering = true
  assert_eq(shader.program_shadow_map_enabled(), false)
}

///|
test "Material shader shadowMapType reads the renderer type" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_shadow_map_type(), 0)
  assert_eq(@materials.Material::raw().program_shadow_map_type(), 0)
  assert_eq(@materials.Material::basic().program_shadow_map_type(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_shadow_map_type(shadow_map_type=1), 1)
  assert_eq(shader.program_shadow_map_type(shadow_map_type=3), 3)
  assert_eq(
    shader.program_shadow_map_enabled(shadow_map_enabled=true, has_shadows=true),
    true,
  )
  assert_eq(shader.program_shadow_map_type(), 0)
}

///|
test "Material shader toneMapping follows toneMapped and the render target" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_tone_mapping() is @constants.No, true)
  assert_eq(shader.program_tone_mapping().to_int(), 0)
  assert_eq(@materials.Material::raw().program_tone_mapping().to_int(), 0)
  assert_eq(@materials.Material::basic().program_tone_mapping().to_int(), 0)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_tone_mapping(tone_mapping=@constants.Linear) is @constants.Linear, true)
  assert_eq(shader.program_tone_mapping(tone_mapping=@constants.Linear).to_int(), 1)
  assert_eq(shader.program_tone_mapping(tone_mapping=@constants.ACES) is @constants.ACES, true)
  assert_eq(shader.program_tone_mapping(tone_mapping=@constants.ACES).to_int(), 4)
  shader.tone_mapped = false
  assert_eq(shader.program_tone_mapping(tone_mapping=@constants.Linear).to_int(), 0)
  shader.tone_mapped = true
  assert_eq(
    shader.program_tone_mapping(tone_mapping=@constants.Linear, has_render_target=true).to_int(),
    0,
  )
  assert_eq(shader.program_shadow_map_type(shadow_map_type=3), 3)
  assert_eq(shader.program_tone_mapping().to_int(), 0)
}

///|
test "Material shader decodeVideoTexture needs a video map in sRGB" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_decode_video_texture(), false)
  assert_eq(@materials.Material::raw().program_decode_video_texture(), false)
  assert_eq(@materials.Material::basic().program_decode_video_texture(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.program_decode_video_texture(video_texture=true, srgb_transfer=true),
    false,
  )
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.program_decode_video_texture(), false)
  assert_eq(shader.program_decode_video_texture(video_texture=true), false)
  assert_eq(shader.program_decode_video_texture(srgb_transfer=true), false)
  assert_eq(
    shader.program_decode_video_texture(video_texture=true, srgb_transfer=true),
    true,
  )
  assert_eq(shader.program_tone_mapping(tone_mapping=@constants.Linear).to_int(), 1)
  assert_eq(shader.program_decode_video_texture(), false)
}

///|
test "Material shader decodeVideoTextureEmissive needs a video emissive map in sRGB" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_decode_video_texture_emissive(), false)
  assert_eq(@materials.Material::raw().program_decode_video_texture_emissive(), false)
  assert_eq(@materials.Material::basic().program_decode_video_texture_emissive(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.program_decode_video_texture_emissive(video_texture=true, srgb_transfer=true),
    false,
  )
  let pixels = FixedArray::make(4, b'\xFF')
  shader.map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(
    shader.program_decode_video_texture(video_texture=true, srgb_transfer=true),
    true,
  )
  assert_eq(
    shader.program_decode_video_texture_emissive(video_texture=true, srgb_transfer=true),
    false,
  )
  shader.emissive_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.program_decode_video_texture_emissive(), false)
  assert_eq(shader.program_decode_video_texture_emissive(video_texture=true), false)
  assert_eq(shader.program_decode_video_texture_emissive(srgb_transfer=true), false)
  assert_eq(
    shader.program_decode_video_texture_emissive(video_texture=true, srgb_transfer=true),
    true,
  )
}

///|
test "Material shader premultipliedAlpha reads the material flag" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_premultiplied_alpha(), false)
  assert_eq(@materials.Material::raw().program_premultiplied_alpha(), false)
  assert_eq(@materials.Material::basic().program_premultiplied_alpha(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.premultiplied_alpha = true
  assert_eq(shader.program_premultiplied_alpha(), true)
  shader.premultiplied_alpha = false
  assert_eq(shader.program_premultiplied_alpha(), false)
  assert_eq(
    shader.program_decode_video_texture_emissive(video_texture=true, srgb_transfer=true),
    false,
  )
  assert_eq(shader.program_premultiplied_alpha(), false)
}

///|
test "Material shader doubleSided reads Double side" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_double_sided(), false)
  assert_eq(@materials.Material::raw().program_double_sided(), false)
  assert_eq(@materials.Material::basic().program_double_sided(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.side = @constants.Back
  assert_eq(shader.program_double_sided(), false)
  shader.side = @constants.Double
  assert_eq(shader.program_double_sided(), true)
  shader.side = @constants.Front
  assert_eq(shader.program_double_sided(), false)
  shader.premultiplied_alpha = true
  assert_eq(shader.program_double_sided(), false)
}

///|
test "Material shader flipSided reads Back side" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_flip_sided(), false)
  assert_eq(@materials.Material::raw().program_flip_sided(), false)
  assert_eq(@materials.Material::basic().program_flip_sided(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.side = @constants.Front
  assert_eq(shader.program_flip_sided(), false)
  shader.side = @constants.Double
  assert_eq(shader.program_double_sided(), true)
  assert_eq(shader.program_flip_sided(), false)
  shader.side = @constants.Back
  assert_eq(shader.program_flip_sided(), true)
  shader.side = @constants.Front
  assert_eq(shader.program_flip_sided(), false)
}

///|
test "Material shader useDepthPacking is on for a stored packing" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_use_depth_packing(), true)
  assert_eq(@materials.Material::raw().program_use_depth_packing(), true)
  assert_eq(@materials.Material::basic().program_use_depth_packing(), true)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.depth_packing = @constants.DepthPacking::RGBA
  assert_eq(shader.program_use_depth_packing(), true)
  shader.depth_packing = @constants.DepthPacking::Basic
  assert_eq(shader.program_use_depth_packing(), true)
  shader.side = @constants.Back
  assert_eq(shader.program_flip_sided(), true)
  assert_eq(shader.program_use_depth_packing(), true)
}

///|
test "Material shader depthPacking reads the packing integer" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_depth_packing(), 3200)
  assert_eq(@materials.Material::raw().program_depth_packing(), 3200)
  assert_eq(@materials.Material::basic().program_depth_packing(), 3200)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.depth_packing = @constants.DepthPacking::RGBA
  assert_eq(shader.program_depth_packing(), 3201)
  shader.depth_packing = @constants.DepthPacking::RGB
  assert_eq(shader.program_depth_packing(), 3202)
  shader.depth_packing = @constants.DepthPacking::RG
  assert_eq(shader.program_depth_packing(), 3203)
  shader.depth_packing = @constants.DepthPacking::Basic
  assert_eq(shader.program_depth_packing(), 3200)
  shader.side = @constants.Back
  assert_eq(shader.program_use_depth_packing(), true)
  assert_eq(shader.program_depth_packing(), 3200)
}

///|
test "Material shader index0AttributeName reads the attribute name" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_index0_attribute_name(), None)
  assert_eq(@materials.Material::raw().program_index0_attribute_name(), None)
  assert_eq(@materials.Material::basic().program_index0_attribute_name(), None)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.index0_attribute_name = Some("position")
  assert_eq(shader.program_index0_attribute_name(), Some("position"))
  shader.index0_attribute_name = None
  assert_eq(shader.program_index0_attribute_name(), None)
  shader.depth_packing = @constants.DepthPacking::RGBA
  assert_eq(shader.program_depth_packing(), 3201)
  assert_eq(shader.program_index0_attribute_name(), None)
}

///|
test "Material shader extensionClipCullDistance needs the flag and the extension" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_extension_clip_cull_distance(), false)
  assert_eq(@materials.Material::raw().program_extension_clip_cull_distance(), false)
  assert_eq(@materials.Material::basic().program_extension_clip_cull_distance(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.index0_attribute_name = Some("position")
  assert_eq(shader.program_extension_clip_cull_distance(has_extension=true), false)
  shader.index0_attribute_name = None
  assert_eq(shader.program_extension_clip_cull_distance(has_extension=true), false)
  shader.extensions.clip_cull_distance = true
  assert_eq(shader.program_extension_clip_cull_distance(), false)
  assert_eq(shader.program_extension_clip_cull_distance(has_extension=true), true)
  shader.extensions.clip_cull_distance = false
  assert_eq(shader.program_extension_clip_cull_distance(has_extension=true), false)
}

///|
test "Material shader extensionMultiDraw needs the extension and a draw path" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_extension_multi_draw(), false)
  assert_eq(@materials.Material::raw().program_extension_multi_draw(), false)
  assert_eq(@materials.Material::basic().program_extension_multi_draw(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.extensions.clip_cull_distance = true
  assert_eq(shader.program_extension_clip_cull_distance(has_extension=true), true)
  assert_eq(shader.program_extension_multi_draw(has_extension=true), false)
  shader.extensions.clip_cull_distance = false
  assert_eq(shader.program_extension_multi_draw(is_batched_mesh=true), false)
  shader.extensions.multi_draw = true
  assert_eq(shader.program_extension_multi_draw(), false)
  assert_eq(shader.program_extension_multi_draw(has_extension=true), true)
  shader.extensions.multi_draw = false
  assert_eq(
    shader.program_extension_multi_draw(has_extension=true, is_batched_mesh=true),
    true,
  )
  assert_eq(shader.program_extension_multi_draw(has_extension=true), false)
}

///|
test "Material shader rendererExtensionParallelShaderCompile reads the renderer extension" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_renderer_extension_parallel_shader_compile(), false)
  assert_eq(
    @materials.Material::raw().program_renderer_extension_parallel_shader_compile(),
    false,
  )
  assert_eq(
    @materials.Material::basic().program_renderer_extension_parallel_shader_compile(),
    false,
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.program_renderer_extension_parallel_shader_compile(has_extension=true),
    true,
  )
  assert_eq(
    shader.program_renderer_extension_parallel_shader_compile(has_extension=false),
    false,
  )
  assert_eq(
    shader.program_extension_multi_draw(has_extension=true, is_batched_mesh=true),
    true,
  )
  assert_eq(shader.program_renderer_extension_parallel_shader_compile(), false)
}

///|
test "Material shader customProgramCacheKey reads the caller key" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_custom_program_cache_key(), "")
  assert_eq(@materials.Material::raw().program_custom_program_cache_key(), "")
  assert_eq(@materials.Material::basic().program_custom_program_cache_key(), "")
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.program_custom_program_cache_key(custom_program_cache_key="custom"),
    "custom",
  )
  assert_eq(shader.program_custom_program_cache_key(), "")
  assert_eq(
    shader.program_renderer_extension_parallel_shader_compile(has_extension=true),
    true,
  )
  assert_eq(shader.program_custom_program_cache_key(), "")
}

///|
test "Material shader vertexUv1s reads channel 1" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_vertex_uv1s(), false)
  assert_eq(@materials.Material::raw().program_vertex_uv1s(), false)
  assert_eq(@materials.Material::basic().program_vertex_uv1s(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.program_map_uv(), "uv")
  assert_eq(shader.program_vertex_uv1s(), false)
  map.channel = 2
  shader.map = Some(map)
  assert_eq(shader.program_vertex_uv1s(), false)
  map.channel = 1
  shader.map = Some(map)
  assert_eq(shader.program_map_uv(), "uv1")
  assert_eq(shader.program_vertex_uv1s(), true)
  shader.map = None
  assert_eq(shader.program_vertex_uv1s(), false)
  shader.anisotropy_map = Some(map)
  assert_eq(shader.program_vertex_uv1s(), false)
  shader.anisotropy = 1.0
  assert_eq(shader.program_vertex_uv1s(), true)
  shader.anisotropy = 0.0
  assert_eq(shader.program_vertex_uv1s(), false)
  assert_eq(
    shader.program_custom_program_cache_key(custom_program_cache_key="custom"),
    "custom",
  )
  assert_eq(shader.program_vertex_uv1s(), false)
}

///|
test "Material shader vertexUv2s reads channel 2" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_vertex_uv2s(), false)
  assert_eq(@materials.Material::raw().program_vertex_uv2s(), false)
  assert_eq(@materials.Material::basic().program_vertex_uv2s(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.program_vertex_uv2s(), false)
  map.channel = 1
  shader.map = Some(map)
  assert_eq(shader.program_vertex_uv1s(), true)
  assert_eq(shader.program_vertex_uv2s(), false)
  map.channel = 3
  shader.map = Some(map)
  assert_eq(shader.program_vertex_uv2s(), false)
  map.channel = 2
  shader.map = Some(map)
  assert_eq(shader.program_map_uv(), "uv2")
  assert_eq(shader.program_vertex_uv2s(), true)
  shader.map = None
  assert_eq(shader.program_vertex_uv2s(), false)
  shader.anisotropy_map = Some(map)
  assert_eq(shader.program_vertex_uv2s(), false)
  shader.anisotropy = 1.0
  assert_eq(shader.program_vertex_uv2s(), true)
  shader.anisotropy = 0.0
  assert_eq(shader.program_vertex_uv2s(), false)
  assert_eq(
    shader.program_custom_program_cache_key(custom_program_cache_key="custom"),
    "custom",
  )
  assert_eq(shader.program_vertex_uv2s(), false)
}

///|
test "Material shader vertexUv3s reads channel 3" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_vertex_uv3s(), false)
  assert_eq(@materials.Material::raw().program_vertex_uv3s(), false)
  assert_eq(@materials.Material::basic().program_vertex_uv3s(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.program_vertex_uv3s(), false)
  map.channel = 1
  shader.map = Some(map)
  assert_eq(shader.program_vertex_uv1s(), true)
  assert_eq(shader.program_vertex_uv3s(), false)
  map.channel = 2
  shader.map = Some(map)
  assert_eq(shader.program_vertex_uv2s(), true)
  assert_eq(shader.program_vertex_uv3s(), false)
  map.channel = 4
  shader.map = Some(map)
  assert_eq(shader.program_vertex_uv3s(), false)
  map.channel = 3
  shader.map = Some(map)
  assert_eq(shader.program_map_uv(), "uv3")
  assert_eq(shader.program_vertex_uv3s(), true)
  shader.map = None
  assert_eq(shader.program_vertex_uv3s(), false)
  shader.anisotropy_map = Some(map)
  assert_eq(shader.program_vertex_uv3s(), false)
  shader.anisotropy = 1.0
  assert_eq(shader.program_vertex_uv3s(), true)
  shader.anisotropy = 0.0
  assert_eq(shader.program_vertex_uv3s(), false)
  assert_eq(
    shader.program_custom_program_cache_key(custom_program_cache_key="custom"),
    "custom",
  )
  assert_eq(shader.program_vertex_uv3s(), false)
}

///|
test "Material shader shaderID reads the builtin id" {
  let shader = @materials.Material::shader()
  assert_eq(shader.program_shader_id(), None)
  assert_eq(@materials.Material::raw().program_shader_id(), None)
  assert_eq(@materials.Material::basic().program_shader_id(), Some("basic"))
  assert_eq(@materials.Material::lambert().program_shader_id(), Some("lambert"))
  assert_eq(@materials.Material::phong().program_shader_id(), Some("phong"))
  assert_eq(@materials.Material::toon().program_shader_id(), Some("toon"))
  assert_eq(@materials.Material::standard().program_shader_id(), Some("physical"))
  assert_eq(@materials.Material::physical().program_shader_id(), Some("physical"))
  assert_eq(@materials.Material::matcap().program_shader_id(), Some("matcap"))
  assert_eq(@materials.Material::normal().program_shader_id(), Some("normal"))
  assert_eq(@materials.Material::depth().program_shader_id(), Some("depth"))
  assert_eq(@materials.Material::distance().program_shader_id(), Some("distance"))
  assert_eq(@materials.Material::shadow().program_shader_id(), Some("shadow"))
  assert_eq(@materials.PointsMaterial::new().program_shader_id(), Some("points"))
  assert_eq(@materials.SpriteMaterial::new().program_shader_id(), Some("sprite"))
  assert_eq(
    @materials.LineBasicMaterial::new().program_shader_id(),
    Some("basic"),
  )
  assert_eq(
    @materials.LineDashedMaterial::new().program_shader_id(),
    Some("dashed"),
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.name = "renamed"
  assert_eq(shader.shader_type(), "ShaderMaterial")
  assert_eq(shader.program_shader_id(), None)
  let basic = @materials.Material::basic()
  basic.name = "renamed"
  assert_eq(basic.shader_type(), "MeshBasicMaterial")
  assert_eq(basic.program_shader_id(), Some("basic"))
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  map.channel = 3
  shader.map = Some(map)
  assert_eq(shader.program_vertex_uv3s(), true)
  assert_eq(shader.program_shader_id(), None)
}

///|
test "Material shader writes USE_FOG" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_vertex_shader(has_fog=true).length(), 1608)
  assert_eq(shader.prefixed_fragment_shader(has_fog=true).length(), 2041)
  shader.fog = true
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_vertex_shader(has_fog=true).length(), 1624)
  assert_eq(shader.prefixed_fragment_shader(has_fog=true).length(), 2057)
  assert_eq(1624 - 1608, 16)
  assert_eq(
    shader.prefixed_vertex_shader(has_fog=true)[683:698].to_owned(),
    "#define USE_FOG",
  )
  assert_eq(
    shader.prefixed_fragment_shader(has_fog=true)[1079:1094].to_owned(),
    "#define USE_FOG",
  )
  assert_eq(shader.program_fog_exp2(has_fog=true, fog_exp2=true), true)
  assert_eq(shader.prefixed_vertex_shader(has_fog=true).length(), 1624)
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader(has_fog=true).length(), 1658)
  assert_eq(shader.prefixed_fragment_shader(has_fog=true).length(), 2073)
  assert_eq(
    shader.prefixed_vertex_shader(has_fog=true)[683:698].to_owned(),
    "#define USE_FOG",
  )
  assert_eq(
    shader.prefixed_vertex_shader(has_fog=true)[699:714].to_owned(),
    "#define USE_MAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader(has_fog=true)[1079:1094].to_owned(),
    "#define USE_FOG",
  )
  assert_eq(
    shader.prefixed_fragment_shader(has_fog=true)[1095:1110].to_owned(),
    "#define USE_MAP",
  )
  shader.fog = false
  assert_eq(shader.prefixed_vertex_shader(has_fog=true).length(), 1642)
  assert_eq(shader.prefixed_fragment_shader(has_fog=true).length(), 2057)
  let raw = @materials.Material::raw()
  raw.fog = true
  assert_eq(raw.prefixed_vertex_shader(has_fog=true).length(), 92)
  assert_eq(raw.prefixed_fragment_shader(has_fog=true).length(), 61)
  let basic = @materials.Material::basic()
  assert_eq(basic.program_use_fog(), true)
  assert_eq(basic.prefixed_vertex_shader(has_fog=true), "")
  assert_eq(basic.prefixed_fragment_shader(has_fog=true), "")
}

///|
test "Material shader writes FOG_EXP2" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.prefixed_vertex_shader(has_fog=true, fog_exp2=true).length(),
    1608,
  )
  shader.fog = true
  assert_eq(shader.prefixed_vertex_shader(has_fog=true).length(), 1624)
  assert_eq(shader.prefixed_fragment_shader(has_fog=true).length(), 2057)
  assert_eq(shader.prefixed_vertex_shader(fog_exp2=true).length(), 1625)
  assert_eq(shader.prefixed_fragment_shader(fog_exp2=true).length(), 2058)
  assert_eq(
    shader.prefixed_vertex_shader(has_fog=true, fog_exp2=true).length(),
    1641,
  )
  assert_eq(
    shader.prefixed_fragment_shader(has_fog=true, fog_exp2=true).length(),
    2074,
  )
  assert_eq(1641 - 1608, 33)
  assert_eq(1625 - 1608, 17)
  assert_eq(
    shader.prefixed_vertex_shader(has_fog=true, fog_exp2=true)[683:698].to_owned(),
    "#define USE_FOG",
  )
  assert_eq(
    shader.prefixed_vertex_shader(has_fog=true, fog_exp2=true)[699:715].to_owned(),
    "#define FOG_EXP2",
  )
  assert_eq(
    shader.prefixed_fragment_shader(has_fog=true, fog_exp2=true)[1079:1094]
      .to_owned(),
    "#define USE_FOG",
  )
  assert_eq(
    shader.prefixed_fragment_shader(has_fog=true, fog_exp2=true)[1095:1111]
      .to_owned(),
    "#define FOG_EXP2",
  )
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(
    shader.prefixed_vertex_shader(has_fog=true, fog_exp2=true).length(),
    1675,
  )
  assert_eq(
    shader.prefixed_fragment_shader(has_fog=true, fog_exp2=true).length(),
    2090,
  )
  assert_eq(
    shader.prefixed_vertex_shader(has_fog=true, fog_exp2=true)[716:731].to_owned(),
    "#define USE_MAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader(has_fog=true, fog_exp2=true)[1112:1127]
      .to_owned(),
    "#define USE_MAP",
  )
  shader.fog = false
  assert_eq(
    shader.prefixed_vertex_shader(has_fog=true, fog_exp2=true).length(),
    1642,
  )
  assert_eq(
    shader.prefixed_fragment_shader(has_fog=true, fog_exp2=true).length(),
    2057,
  )
  let raw = @materials.Material::raw()
  raw.fog = true
  assert_eq(raw.prefixed_vertex_shader(has_fog=true, fog_exp2=true).length(), 92)
  assert_eq(
    raw.prefixed_fragment_shader(has_fog=true, fog_exp2=true).length(),
    61,
  )
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_vertex_shader(has_fog=true, fog_exp2=true), "")
  assert_eq(basic.prefixed_fragment_shader(has_fog=true, fog_exp2=true), "")
}

///|
test "Material shader writes ALPHA_TO_COVERAGE" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.fog = true
  assert_eq(shader.prefixed_fragment_shader(has_fog=true).length(), 2057)
  assert_eq(
    shader.prefixed_fragment_shader(has_fog=true)[1079:1094].to_owned(),
    "#define USE_FOG",
  )
  shader.fog = false
  shader.alpha_to_coverage = true
  assert_eq(shader.program_alpha_to_coverage(), true)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2052)
  assert_eq(2052 - 2026, 26)
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1104].to_owned(),
    "#define ALPHA_TO_COVERAGE",
  )
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1642)
  assert_eq(shader.prefixed_fragment_shader().length(), 2068)
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1104].to_owned(),
    "#define ALPHA_TO_COVERAGE",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1105:1120].to_owned(),
    "#define USE_MAP",
  )
  shader.map = None
  shader.alpha_to_coverage = false
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let raw = @materials.Material::raw()
  raw.alpha_to_coverage = true
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  let basic = @materials.Material::basic()
  basic.alpha_to_coverage = true
  assert_eq(basic.prefixed_vertex_shader(), "")
  assert_eq(basic.prefixed_fragment_shader(), "")
}

///|
test "Material shader writes USE_MATCAP" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.alpha_to_coverage = true
  assert_eq(shader.prefixed_fragment_shader().length(), 2052)
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1104].to_owned(),
    "#define ALPHA_TO_COVERAGE",
  )
  shader.alpha_to_coverage = false
  let pixels = FixedArray::make(4, b'\xFF')
  let matcap = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.matcap = Some(matcap)
  assert_eq(shader.program_matcap(), true)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2060)
  assert_eq(2060 - 2041, 19)
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1097].to_owned(),
    "#define USE_MATCAP",
  )
  let map_pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, map_pixels)
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1642)
  assert_eq(shader.prefixed_fragment_shader().length(), 2076)
  assert_eq(shader.prefixed_fragment_shader()[1079:1094].to_owned(), "#define USE_MAP")
  assert_eq(
    shader.prefixed_fragment_shader()[1095:1113].to_owned(),
    "#define USE_MATCAP",
  )
  shader.matcap = None
  assert_eq(shader.program_matcap(), false)
  assert_eq(shader.prefixed_vertex_shader().length(), 1642)
  assert_eq(shader.prefixed_fragment_shader().length(), 2057)
  shader.map = None
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let raw = @materials.Material::raw()
  raw.matcap = Some(matcap)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  let basic = @materials.Material::basic()
  basic.matcap = Some(matcap)
  assert_eq(basic.prefixed_vertex_shader(), "")
  assert_eq(basic.prefixed_fragment_shader(), "")
  assert_eq(@materials.Material::matcap().prefixed_fragment_shader(), "")
}

///|
test "Material shader writes CUBEUV_TEXEL_WIDTH" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let pixels = FixedArray::make(4, b'\xFF')
  let matcap = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.matcap = Some(matcap)
  assert_eq(shader.prefixed_fragment_shader().length(), 2060)
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1097].to_owned(),
    "#define USE_MATCAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(256)).length(),
    2174,
  )
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(256))[1098:1145]
      .to_owned(),
    "#define CUBEUV_TEXEL_WIDTH 0.002976190476190476",
  )
  shader.matcap = None
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(256)).length(),
    2155,
  )
  assert_eq(2155 - 2041, 114)
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(256))[1079:1126]
      .to_owned(),
    "#define CUBEUV_TEXEL_WIDTH 0.002976190476190476",
  )
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(512)).length(),
    2157,
  )
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(512))[1079:1127]
      .to_owned(),
    "#define CUBEUV_TEXEL_WIDTH 0.0026041666666666665",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let env_pixels = FixedArray::make(4, b'\xFF')
  let env_map = @textures.Texture::from_rgba8(1, 1, env_pixels)
  shader.env_map = Some(env_map)
  assert_eq(shader.program_env_map_cube_uv_height(0), None)
  assert_eq(shader.program_env_map_cube_uv_height(306), Some(1))
  assert_eq(shader.prefixed_fragment_shader().length(), 2149)
  assert_eq(shader.prefixed_vertex_shader().length(), 1658)
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(256)).length(),
    2263,
  )
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(256))[1187:1234]
      .to_owned(),
    "#define CUBEUV_TEXEL_WIDTH 0.002976190476190476",
  )
  let raw = @materials.Material::raw()
  assert_eq(
    raw.prefixed_fragment_shader(env_map_cube_uv_height=Some(256)).length(),
    61,
  )
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_fragment_shader(env_map_cube_uv_height=Some(256)), "")
}

///|
test "Material shader writes CUBEUV_TEXEL_HEIGHT" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(256)).length(),
    2155,
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(256))[1079:1126]
      .to_owned(),
    "#define CUBEUV_TEXEL_WIDTH 0.002976190476190476",
  )
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(256))[1127:1165]
      .to_owned(),
    "#define CUBEUV_TEXEL_HEIGHT 0.00390625",
  )
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(512)).length(),
    2157,
  )
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(512))[1128:1167]
      .to_owned(),
    "#define CUBEUV_TEXEL_HEIGHT 0.001953125",
  )
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(1)).length(),
    2147,
  )
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(1))[1127:1156]
      .to_owned(),
    "#define CUBEUV_TEXEL_HEIGHT 1",
  )
  let pixels = FixedArray::make(4, b'\xFF')
  let env_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.env_map = Some(env_map)
  assert_eq(shader.prefixed_fragment_shader().length(), 2149)
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(256)).length(),
    2263,
  )
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(256))[1235:1273]
      .to_owned(),
    "#define CUBEUV_TEXEL_HEIGHT 0.00390625",
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1658)
  let raw = @materials.Material::raw()
  assert_eq(
    raw.prefixed_fragment_shader(env_map_cube_uv_height=Some(256)).length(),
    61,
  )
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_fragment_shader(env_map_cube_uv_height=Some(1)), "")
}

///|
test "Material shader writes CUBEUV_MAX_MIP" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(256)).length(),
    2155,
  )
  assert_eq(2155 - 2041, 114)
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(256))[1127:1165]
      .to_owned(),
    "#define CUBEUV_TEXEL_HEIGHT 0.00390625",
  )
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(256))[1166:1192]
      .to_owned(),
    "#define CUBEUV_MAX_MIP 6.0",
  )
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(512)).length(),
    2157,
  )
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(512))[1168:1194]
      .to_owned(),
    "#define CUBEUV_MAX_MIP 7.0",
  )
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(1)).length(),
    2147,
  )
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(1))[1157:1184]
      .to_owned(),
    "#define CUBEUV_MAX_MIP -2.0",
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  let pixels = FixedArray::make(4, b'\xFF')
  let env_map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.env_map = Some(env_map)
  assert_eq(shader.prefixed_fragment_shader().length(), 2149)
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(256)).length(),
    2263,
  )
  assert_eq(
    shader.prefixed_fragment_shader(env_map_cube_uv_height=Some(256))[1274:1300]
      .to_owned(),
    "#define CUBEUV_MAX_MIP 6.0",
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1658)
  let raw = @materials.Material::raw()
  assert_eq(
    raw.prefixed_fragment_shader(env_map_cube_uv_height=Some(256)).length(),
    61,
  )
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_fragment_shader(env_map_cube_uv_height=Some(256)), "")
}

///|
test "Material shader writes USE_CLIP_DISTANCE" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.prefixed_vertex_shader(has_clip_cull_distance=true).length(),
    1608,
  )
  assert_eq(
    shader.program_extension_clip_cull_distance(has_extension=true),
    false,
  )
  shader.extensions.clip_cull_distance = true
  assert_eq(shader.prefixed_vertex_shader().length(), 1656)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.program_extension_clip_cull_distance(has_extension=true),
    true,
  )
  assert_eq(
    shader.prefixed_vertex_shader(has_clip_cull_distance=true).length(),
    1682,
  )
  assert_eq(1682 - 1656, 26)
  assert_eq(
    shader.prefixed_vertex_shader(has_clip_cull_distance=true)[731:756].to_owned(),
    "#define USE_CLIP_DISTANCE",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.fog = true
  assert_eq(
    shader
    .prefixed_vertex_shader(has_clip_cull_distance=true, has_fog=true)
    .length(),
    1698,
  )
  assert_eq(shader.prefixed_fragment_shader(has_fog=true).length(), 2057)
  assert_eq(
    shader.prefixed_vertex_shader(has_clip_cull_distance=true, has_fog=true)[
      731:756
    ].to_owned(),
    "#define USE_CLIP_DISTANCE",
  )
  assert_eq(
    shader.prefixed_vertex_shader(has_clip_cull_distance=true, has_fog=true)[
      757:772
    ].to_owned(),
    "#define USE_FOG",
  )
  assert_eq(
    shader.prefixed_fragment_shader(has_fog=true)[1079:1094].to_owned(),
    "#define USE_FOG",
  )
  shader.fog = false
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(
    shader.prefixed_vertex_shader(has_clip_cull_distance=true).length(),
    1716,
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2057)
  assert_eq(
    shader.prefixed_vertex_shader(has_clip_cull_distance=true)[757:772].to_owned(),
    "#define USE_MAP",
  )
  shader.extensions.clip_cull_distance = false
  assert_eq(
    shader.prefixed_vertex_shader(has_clip_cull_distance=true).length(),
    1642,
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2057)
  let raw = @materials.Material::raw()
  raw.extensions.clip_cull_distance = true
  assert_eq(raw.prefixed_vertex_shader(has_clip_cull_distance=true).length(), 92)
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  let basic = @materials.Material::basic()
  basic.extensions.clip_cull_distance = true
  assert_eq(basic.prefixed_vertex_shader(has_clip_cull_distance=true), "")
  assert_eq(basic.prefixed_fragment_shader(), "")
}

///|
test "Material shader writes USE_BATCHING" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(@materials.program_batching(is_batched_mesh=true), true)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_vertex_shader(batching=true).length(), 1629)
  assert_eq(1629 - 1608, 21)
  assert_eq(
    shader.prefixed_vertex_shader(batching=true)[683:703].to_owned(),
    "#define USE_BATCHING",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.extensions.clip_cull_distance = true
  assert_eq(
    shader
    .prefixed_vertex_shader(batching=true, has_clip_cull_distance=true)
    .length(),
    1703,
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.prefixed_vertex_shader(batching=true, has_clip_cull_distance=true)[
      731:756
    ].to_owned(),
    "#define USE_CLIP_DISTANCE",
  )
  assert_eq(
    shader.prefixed_vertex_shader(batching=true, has_clip_cull_distance=true)[
      757:777
    ].to_owned(),
    "#define USE_BATCHING",
  )
  shader.extensions.clip_cull_distance = false
  shader.fog = true
  assert_eq(
    shader.prefixed_vertex_shader(batching=true, has_fog=true).length(),
    1645,
  )
  assert_eq(shader.prefixed_fragment_shader(has_fog=true).length(), 2057)
  assert_eq(
    shader.prefixed_vertex_shader(batching=true, has_fog=true)[683:703].to_owned(),
    "#define USE_BATCHING",
  )
  assert_eq(
    shader.prefixed_vertex_shader(batching=true, has_fog=true)[704:719].to_owned(),
    "#define USE_FOG",
  )
  shader.fog = false
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader(batching=true).length(), 1663)
  assert_eq(shader.prefixed_fragment_shader().length(), 2057)
  assert_eq(
    shader.prefixed_vertex_shader(batching=true)[704:719].to_owned(),
    "#define USE_MAP",
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1642)
  assert_eq(shader.prefixed_fragment_shader().length(), 2057)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_vertex_shader(batching=true).length(), 92)
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_vertex_shader(batching=true), "")
  assert_eq(basic.prefixed_fragment_shader(), "")
}

///|
test "Material shader writes USE_BATCHING_COLOR" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    @materials.program_batching_color(
      is_batched_mesh=true,
      has_colors_texture=true,
    ),
    true,
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_vertex_shader(batching_color=true).length(), 1635)
  assert_eq(1635 - 1608, 27)
  assert_eq(
    shader.prefixed_vertex_shader(batching_color=true)[683:709].to_owned(),
    "#define USE_BATCHING_COLOR",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.prefixed_vertex_shader(batching=true, batching_color=true).length(),
    1656,
  )
  assert_eq(
    shader.prefixed_vertex_shader(batching=true, batching_color=true)[683:703]
      .to_owned(),
    "#define USE_BATCHING",
  )
  assert_eq(
    shader.prefixed_vertex_shader(batching=true, batching_color=true)[704:730]
      .to_owned(),
    "#define USE_BATCHING_COLOR",
  )
  shader.fog = true
  assert_eq(
    shader.prefixed_vertex_shader(batching_color=true, has_fog=true).length(),
    1651,
  )
  assert_eq(shader.prefixed_fragment_shader(has_fog=true).length(), 2057)
  assert_eq(
    shader.prefixed_vertex_shader(batching_color=true, has_fog=true)[683:709]
      .to_owned(),
    "#define USE_BATCHING_COLOR",
  )
  assert_eq(
    shader.prefixed_vertex_shader(batching_color=true, has_fog=true)[710:725]
      .to_owned(),
    "#define USE_FOG",
  )
  shader.fog = false
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader(batching_color=true).length(), 1669)
  assert_eq(shader.prefixed_fragment_shader().length(), 2057)
  assert_eq(
    shader.prefixed_vertex_shader(batching_color=true)[710:725].to_owned(),
    "#define USE_MAP",
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1642)
  assert_eq(shader.prefixed_fragment_shader().length(), 2057)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_vertex_shader(batching_color=true).length(), 92)
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_vertex_shader(batching_color=true), "")
  assert_eq(basic.prefixed_fragment_shader(), "")
}

///|
test "Material shader writes USE_INSTANCING" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(@materials.program_instancing(is_instanced_mesh=true), true)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_vertex_shader(instancing=true).length(), 1631)
  assert_eq(1631 - 1608, 23)
  assert_eq(
    shader.prefixed_vertex_shader(instancing=true)[683:705].to_owned(),
    "#define USE_INSTANCING",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.prefixed_vertex_shader(batching_color=true, instancing=true).length(),
    1658,
  )
  assert_eq(
    shader.prefixed_vertex_shader(batching_color=true, instancing=true)[683:709]
      .to_owned(),
    "#define USE_BATCHING_COLOR",
  )
  assert_eq(
    shader.prefixed_vertex_shader(batching_color=true, instancing=true)[710:732]
      .to_owned(),
    "#define USE_INSTANCING",
  )
  shader.fog = true
  assert_eq(
    shader.prefixed_vertex_shader(instancing=true, has_fog=true).length(),
    1647,
  )
  assert_eq(shader.prefixed_fragment_shader(has_fog=true).length(), 2057)
  assert_eq(
    shader.prefixed_vertex_shader(instancing=true, has_fog=true)[683:705].to_owned(),
    "#define USE_INSTANCING",
  )
  assert_eq(
    shader.prefixed_vertex_shader(instancing=true, has_fog=true)[706:721].to_owned(),
    "#define USE_FOG",
  )
  shader.fog = false
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader(instancing=true).length(), 1665)
  assert_eq(shader.prefixed_fragment_shader().length(), 2057)
  assert_eq(
    shader.prefixed_vertex_shader(instancing=true)[706:721].to_owned(),
    "#define USE_MAP",
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1642)
  assert_eq(shader.prefixed_fragment_shader().length(), 2057)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_vertex_shader(instancing=true).length(), 92)
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_vertex_shader(instancing=true), "")
  assert_eq(basic.prefixed_fragment_shader(), "")
}

///|
test "Material shader writes USE_INSTANCING_COLOR" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    @materials.program_instancing_color(
      is_instanced_mesh=true,
      has_instance_color=true,
    ),
    true,
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_vertex_shader(instancing_color=true).length(), 1637)
  assert_eq(1637 - 1608, 29)
  assert_eq(
    shader.prefixed_vertex_shader(instancing_color=true)[683:711].to_owned(),
    "#define USE_INSTANCING_COLOR",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader.prefixed_vertex_shader(instancing=true, instancing_color=true).length(),
    1660,
  )
  assert_eq(
    shader.prefixed_vertex_shader(instancing=true, instancing_color=true)[683:705]
      .to_owned(),
    "#define USE_INSTANCING",
  )
  assert_eq(
    shader.prefixed_vertex_shader(instancing=true, instancing_color=true)[706:734]
      .to_owned(),
    "#define USE_INSTANCING_COLOR",
  )
  shader.fog = true
  assert_eq(
    shader.prefixed_vertex_shader(instancing_color=true, has_fog=true).length(),
    1653,
  )
  assert_eq(shader.prefixed_fragment_shader(has_fog=true).length(), 2057)
  assert_eq(
    shader.prefixed_vertex_shader(instancing_color=true, has_fog=true)[683:711]
      .to_owned(),
    "#define USE_INSTANCING_COLOR",
  )
  assert_eq(
    shader.prefixed_vertex_shader(instancing_color=true, has_fog=true)[712:727]
      .to_owned(),
    "#define USE_FOG",
  )
  shader.fog = false
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader(instancing_color=true).length(), 1671)
  assert_eq(shader.prefixed_fragment_shader().length(), 2057)
  assert_eq(
    shader.prefixed_vertex_shader(instancing_color=true)[712:727].to_owned(),
    "#define USE_MAP",
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1642)
  assert_eq(shader.prefixed_fragment_shader().length(), 2057)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_vertex_shader(instancing_color=true).length(), 92)
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_vertex_shader(instancing_color=true), "")
  assert_eq(basic.prefixed_fragment_shader(), "")
}

///|
test "Material shader writes USE_INSTANCING_MORPH" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    @materials.program_instancing_morph(
      is_instanced_mesh=true,
      has_morph_texture=true,
    ),
    true,
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_vertex_shader(instancing_morph=true).length(), 1637)
  assert_eq(1637 - 1608, 29)
  assert_eq(
    shader.prefixed_vertex_shader(instancing_morph=true)[683:711].to_owned(),
    "#define USE_INSTANCING_MORPH",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(
    shader
    .prefixed_vertex_shader(instancing_color=true, instancing_morph=true)
    .length(),
    1666,
  )
  assert_eq(
    shader.prefixed_vertex_shader(instancing_color=true, instancing_morph=true)[
      683:711
    ].to_owned(),
    "#define USE_INSTANCING_COLOR",
  )
  assert_eq(
    shader.prefixed_vertex_shader(instancing_color=true, instancing_morph=true)[
      712:740
    ].to_owned(),
    "#define USE_INSTANCING_MORPH",
  )
  shader.fog = true
  assert_eq(
    shader.prefixed_vertex_shader(instancing_morph=true, has_fog=true).length(),
    1653,
  )
  assert_eq(shader.prefixed_fragment_shader(has_fog=true).length(), 2057)
  assert_eq(
    shader.prefixed_vertex_shader(instancing_morph=true, has_fog=true)[683:711]
      .to_owned(),
    "#define USE_INSTANCING_MORPH",
  )
  assert_eq(
    shader.prefixed_vertex_shader(instancing_morph=true, has_fog=true)[712:727]
      .to_owned(),
    "#define USE_FOG",
  )
  shader.fog = false
  let pixels = FixedArray::make(4, b'\xFF')
  let map = @textures.Texture::from_rgba8(1, 1, pixels)
  shader.map = Some(map)
  assert_eq(shader.prefixed_vertex_shader(instancing_morph=true).length(), 1671)
  assert_eq(shader.prefixed_fragment_shader().length(), 2057)
  assert_eq(
    shader.prefixed_vertex_shader(instancing_morph=true)[712:727].to_owned(),
    "#define USE_MAP",
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1642)
  assert_eq(shader.prefixed_fragment_shader().length(), 2057)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_vertex_shader(instancing_morph=true).length(), 92)
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_vertex_shader(instancing_morph=true), "")
  assert_eq(basic.prefixed_fragment_shader(), "")
}

///|
test "Material shader writes USE_PACKED_NORMALMAP" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_fragment_shader(normal_map_format=1030).length(), 2041)
  assert_eq(shader.program_packed_normal_map(1030), false)
  let pixels = FixedArray::make(4, b'\xFF')
  shader.normal_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.prefixed_fragment_shader(normal_map_format=1023).length(), 2098)
  assert_eq(shader.prefixed_vertex_shader().length(), 1689)
  assert_eq(shader.program_packed_normal_map(1030), true)
  assert_eq(shader.prefixed_fragment_shader(normal_map_format=1030).length(), 2127)
  assert_eq(2127 - 2098, 29)
  assert_eq(shader.prefixed_vertex_shader().length(), 1689)
  assert_eq(
    shader.prefixed_fragment_shader(normal_map_format=1030)[1101:1135].to_owned(),
    "#define USE_NORMALMAP_TANGENTSPACE",
  )
  assert_eq(
    shader.prefixed_fragment_shader(normal_map_format=1030)[1136:1164].to_owned(),
    "#define USE_PACKED_NORMALMAP",
  )
  assert_eq(shader.prefixed_fragment_shader(normal_map_format=37490).length(), 2127)
  assert_eq(shader.prefixed_fragment_shader(normal_map_format=36285).length(), 2127)
  shader.normal_map_type = @constants.ObjectSpace
  assert_eq(shader.program_packed_normal_map(1030), false)
  assert_eq(shader.prefixed_fragment_shader(normal_map_format=1030).length(), 2097)
  shader.normal_map_type = @constants.TangentSpace
  let emissive_pixels = FixedArray::make(4, b'\xFF')
  shader.emissive_map = Some(@textures.Texture::from_rgba8(1, 1, emissive_pixels))
  assert_eq(shader.prefixed_fragment_shader(normal_map_format=1030).length(), 2151)
  assert_eq(
    shader.prefixed_fragment_shader(normal_map_format=1030)[1165:1188].to_owned(),
    "#define USE_EMISSIVEMAP",
  )
  shader.normal_map = None
  assert_eq(shader.prefixed_fragment_shader(normal_map_format=1030).length(), 2065)
  let raw = @materials.Material::raw()
  raw.normal_map = Some(@textures.Texture::from_rgba8(1, 1, FixedArray::make(4, b'\xFF')))
  assert_eq(raw.prefixed_fragment_shader(normal_map_format=1030).length(), 61)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.normal_map = Some(@textures.Texture::from_rgba8(1, 1, FixedArray::make(4, b'\xFF')))
  assert_eq(basic.prefixed_fragment_shader(normal_map_format=1030), "")
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader prefixes fragment uniforms" {
  let shader = @materials.Material::shader()
  let raw = @materials.Material::raw()
  let basic = @materials.Material::basic()
  let prefixed = shader.prefixed_fragment_shader()
  assert_eq(prefixed.length() - shader.fragment_shader.length(), 1980)
  assert_eq(prefixed.length(), 2041)
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
  assert_eq(custom.length(), 1994)
  assert_eq(custom[custom.length() - 14:custom.length()].to_owned(), "void main() {}")
  raw.fragment_shader = "void main() {}"
  assert_eq(raw.prefixed_fragment_shader(), "void main() {}")
  assert_eq(raw.prefixed_fragment_shader().length(), 14)
}

///|
test "Material shader adds GLSL3 fragment defines" {
  let shader = @materials.Material::shader()
  let prefixed = shader.prefixed_fragment_shader()
  assert_eq(prefixed.length(), 2041)
  assert_eq(prefixed[0:15].to_owned(), "#version 300 es")
  assert_eq(
    prefixed[35:84].to_owned(),
    "layout(location = 0) out highp vec4 pc_fragColor;",
  )
  assert_eq(prefixed[85:118].to_owned(), "#define gl_FragColor pc_fragColor")
  shader.glsl_version = Some(@materials.GlslVersion::GLSL1)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  shader.glsl_version = Some(@materials.GlslVersion::GLSL3)
  let g3 = shader.prefixed_fragment_shader()
  assert_eq(g3.length(), 1959)
  assert_eq(2041 - g3.length(), 82)
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
