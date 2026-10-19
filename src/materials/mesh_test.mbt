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
