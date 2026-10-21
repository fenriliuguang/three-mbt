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
  assert_eq(shader.prefixed_fragment_shader().length(), 2092)
  assert_eq(1664 - 1608, 56)
  assert_eq(
    shader.prefixed_vertex_shader()[683:709].to_owned(),
    "#define USE_IRIDESCENCEMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1103:1129].to_owned(),
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
  assert_eq(shader.prefixed_fragment_shader().length(), 2102)
  assert_eq(1684 - 1608, 76)
  assert_eq(
    shader.prefixed_vertex_shader()[683:719].to_owned(),
    "#define USE_IRIDESCENCE_THICKNESSMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1103:1139].to_owned(),
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
  assert_eq(shader.prefixed_fragment_shader().length(), 2086)
  assert_eq(1664 - 1608, 56)
  assert_eq(
    shader.prefixed_vertex_shader()[683:709].to_owned(),
    "#define USE_SHEEN_COLORMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1097:1123].to_owned(),
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
  assert_eq(shader.prefixed_fragment_shader().length(), 2136)
  assert_eq(
    shader.prefixed_fragment_shader()[1097:1123].to_owned(),
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
  assert_eq(shader.prefixed_fragment_shader().length(), 2090)
  assert_eq(1672 - 1608, 64)
  assert_eq(
    shader.prefixed_vertex_shader()[683:713].to_owned(),
    "#define USE_SHEEN_ROUGHNESSMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1097:1127].to_owned(),
    "#define USE_SHEEN_ROUGHNESSMAP",
  )
  shader.sheen_color_map = Some(roughness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1728)
  assert_eq(
    shader.prefixed_vertex_shader()[710:740].to_owned(),
    "#define USE_SHEEN_ROUGHNESSMAP",
  )
  assert_eq(shader.prefixed_fragment_shader().length(), 2117)
  assert_eq(
    shader.prefixed_fragment_shader()[1124:1154].to_owned(),
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
  assert_eq(shader.prefixed_fragment_shader().length(), 2092)
  assert_eq(1664 - 1608, 56)
  assert_eq(
    shader.prefixed_vertex_shader()[710:738].to_owned(),
    "#define IRIDESCENCEMAP_UV uv",
  )
  iridescence_map.channel = 1
  shader.iridescence_map = Some(iridescence_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1681)
  assert_eq(shader.prefixed_fragment_shader().length(), 2108)
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
  assert_eq(shader.prefixed_fragment_shader().length(), 2102)
  assert_eq(1684 - 1608, 76)
  assert_eq(
    shader.prefixed_vertex_shader()[720:758].to_owned(),
    "#define IRIDESCENCE_THICKNESSMAP_UV uv",
  )
  thickness_map.channel = 1
  shader.iridescence_thickness_map = Some(thickness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1701)
  assert_eq(shader.prefixed_fragment_shader().length(), 2118)
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
  assert_eq(shader.prefixed_fragment_shader().length(), 2086)
  assert_eq(1664 - 1608, 56)
  assert_eq(
    shader.prefixed_vertex_shader()[710:738].to_owned(),
    "#define SHEEN_COLORMAP_UV uv",
  )
  sheen_color_map.channel = 1
  shader.sheen_color_map = Some(sheen_color_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1681)
  assert_eq(shader.prefixed_fragment_shader().length(), 2102)
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
  assert_eq(shader.prefixed_fragment_shader().length(), 2090)
  assert_eq(1672 - 1608, 64)
  assert_eq(
    shader.prefixed_vertex_shader()[714:746].to_owned(),
    "#define SHEEN_ROUGHNESSMAP_UV uv",
  )
  sheen_roughness_map.channel = 1
  shader.sheen_roughness_map = Some(sheen_roughness_map)
  assert_eq(shader.prefixed_vertex_shader().length(), 1689)
  assert_eq(shader.prefixed_fragment_shader().length(), 2106)
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
  assert_eq(basic.prefixed_vertex_shader(has_normal=true), "#define HAS_NORMAL\n")
  assert_eq(basic.prefixed_fragment_shader(has_normal=true), "")
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
test "Material shader writes USE_DISPERSION" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_dispersion(), false)
  shader.dispersion = -1.0
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.dispersion = 0.25
  assert_eq(shader.program_dispersion(), true)
  assert_eq(shader.prefixed_fragment_shader().length(), 2064)
  assert_eq(2064 - 2041, 23)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1101].to_owned(),
    "#define USE_DISPERSION",
  )
  shader.clearcoat = 1.0
  assert_eq(shader.prefixed_fragment_shader().length(), 2086)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1100].to_owned(),
    "#define USE_CLEARCOAT",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1101:1123].to_owned(),
    "#define USE_DISPERSION",
  )
  shader.dispersion = 0.0
  assert_eq(shader.prefixed_fragment_shader().length(), 2063)
  shader.clearcoat = 0.0
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let raw = @materials.Material::raw()
  raw.dispersion = 0.25
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.dispersion = 0.25
  assert_eq(basic.prefixed_fragment_shader(), "")
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_RETROREFLECTION" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_retroreflection(), false)
  shader.retroreflectivity = -1.0
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.retroreflectivity = 0.25
  assert_eq(shader.program_retroreflection(), true)
  assert_eq(shader.prefixed_fragment_shader().length(), 2069)
  assert_eq(2069 - 2041, 28)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1106].to_owned(),
    "#define USE_RETROREFLECTION",
  )
  shader.dispersion = 0.25
  assert_eq(shader.prefixed_fragment_shader().length(), 2092)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1101].to_owned(),
    "#define USE_DISPERSION",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1102:1129].to_owned(),
    "#define USE_RETROREFLECTION",
  )
  shader.retroreflectivity = 0.0
  assert_eq(shader.prefixed_fragment_shader().length(), 2064)
  shader.dispersion = 0.0
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let raw = @materials.Material::raw()
  raw.retroreflectivity = 0.25
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.retroreflectivity = 0.25
  assert_eq(basic.prefixed_fragment_shader(), "")
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_IRIDESCENCE" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_iridescence(), false)
  shader.iridescence = -1.0
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.iridescence = 1.0
  assert_eq(shader.program_iridescence(), true)
  assert_eq(shader.prefixed_fragment_shader().length(), 2065)
  assert_eq(2065 - 2041, 24)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1102].to_owned(),
    "#define USE_IRIDESCENCE",
  )
  shader.retroreflectivity = 0.25
  assert_eq(shader.prefixed_fragment_shader().length(), 2093)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1106].to_owned(),
    "#define USE_RETROREFLECTION",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1107:1130].to_owned(),
    "#define USE_IRIDESCENCE",
  )
  shader.iridescence = 0.0
  assert_eq(shader.prefixed_fragment_shader().length(), 2069)
  shader.retroreflectivity = 0.0
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let raw = @materials.Material::raw()
  raw.iridescence = 1.0
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.iridescence = 1.0
  assert_eq(basic.prefixed_fragment_shader(), "")
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_ALPHATEST" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_alpha_test(), false)
  shader.alpha_test = -1.0
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.alpha_test = 0.25
  assert_eq(shader.program_alpha_test(), true)
  assert_eq(shader.prefixed_fragment_shader().length(), 2063)
  assert_eq(2063 - 2041, 22)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1100].to_owned(),
    "#define USE_ALPHATEST",
  )
  shader.alpha_hash = true
  assert_eq(shader.prefixed_fragment_shader().length(), 2085)
  assert_eq(shader.prefixed_vertex_shader().length(), 1630)
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1100].to_owned(),
    "#define USE_ALPHATEST",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1101:1122].to_owned(),
    "#define USE_ALPHAHASH",
  )
  shader.alpha_hash = false
  let pixels = FixedArray::make(4, b'\xFF')
  shader.alpha_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.prefixed_fragment_shader().length(), 2084)
  assert_eq(shader.prefixed_vertex_shader().length(), 1652)
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1099].to_owned(),
    "#define USE_ALPHAMAP",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1100:1121].to_owned(),
    "#define USE_ALPHATEST",
  )
  shader.alpha_test = 0.0
  assert_eq(shader.prefixed_fragment_shader().length(), 2062)
  shader.alpha_map = None
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let raw = @materials.Material::raw()
  raw.alpha_test = 0.25
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.alpha_test = 0.25
  assert_eq(basic.prefixed_fragment_shader(), "")
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes USE_SHEEN" {
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.program_sheen(), false)
  shader.sheen = -1.0
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  shader.sheen = 1.0
  assert_eq(shader.program_sheen(), true)
  assert_eq(shader.prefixed_fragment_shader().length(), 2059)
  assert_eq(2059 - 2041, 18)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1096].to_owned(),
    "#define USE_SHEEN",
  )
  let pixels = FixedArray::make(4, b'\xFF')
  shader.sheen_color_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(shader.prefixed_fragment_shader().length(), 2086)
  assert_eq(shader.prefixed_vertex_shader().length(), 1664)
  assert_eq(
    shader.prefixed_fragment_shader()[1079:1096].to_owned(),
    "#define USE_SHEEN",
  )
  assert_eq(
    shader.prefixed_fragment_shader()[1097:1123].to_owned(),
    "#define USE_SHEEN_COLORMAP",
  )
  shader.sheen_color_map = None
  shader.sheen = 0.0
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let raw = @materials.Material::raw()
  raw.sheen = 1.0
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  basic.sheen = 1.0
  assert_eq(basic.prefixed_fragment_shader(), "")
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes instancing USE_COLOR" {
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
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_fragment_shader(instancing_color=true).length(), 2059)
  assert_eq(2059 - 2041, 18)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_vertex_shader(instancing_color=true).length(), 1637)
  assert_eq(
    shader.prefixed_vertex_shader(instancing_color=true)[683:711].to_owned(),
    "#define USE_INSTANCING_COLOR",
  )
  assert_eq(
    shader.prefixed_fragment_shader(instancing_color=true)[1079:1096].to_owned(),
    "#define USE_COLOR",
  )
  shader.vertex_colors = true
  assert_eq(shader.prefixed_fragment_shader(instancing_color=true).length(), 2059)
  assert_eq(
    shader.prefixed_fragment_shader(instancing_color=true)[1079:1096].to_owned(),
    "#define USE_COLOR",
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1626)
  shader.vertex_colors = false
  shader.sheen = 1.0
  assert_eq(shader.prefixed_fragment_shader(instancing_color=true).length(), 2077)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(
    shader.prefixed_fragment_shader(instancing_color=true)[1079:1096].to_owned(),
    "#define USE_SHEEN",
  )
  assert_eq(
    shader.prefixed_fragment_shader(instancing_color=true)[1097:1114].to_owned(),
    "#define USE_COLOR",
  )
  shader.sheen = 0.0
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_fragment_shader(instancing_color=true).length(), 61)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_fragment_shader(instancing_color=true), "")
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes batching USE_COLOR_ALPHA" {
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
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  assert_eq(shader.prefixed_fragment_shader(batching_color=true).length(), 2065)
  assert_eq(2065 - 2041, 24)
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_vertex_shader(batching_color=true).length(), 1635)
  assert_eq(
    shader.prefixed_vertex_shader(batching_color=true)[683:709].to_owned(),
    "#define USE_BATCHING_COLOR",
  )
  assert_eq(
    shader.prefixed_fragment_shader(batching_color=true)[1079:1102].to_owned(),
    "#define USE_COLOR_ALPHA",
  )
  shader.vertex_colors = true
  assert_eq(
    shader.prefixed_fragment_shader(has_vertex_alpha=true, batching_color=true).length(),
    2083,
  )
  assert_eq(
    shader.prefixed_fragment_shader(has_vertex_alpha=true, batching_color=true)[1097:1120].to_owned(),
    "#define USE_COLOR_ALPHA",
  )
  assert_eq(shader.prefixed_vertex_shader(has_vertex_alpha=true).length(), 1650)
  shader.vertex_colors = false
  assert_eq(
    shader.prefixed_fragment_shader(instancing_color=true, batching_color=true).length(),
    2083,
  )
  assert_eq(
    shader.prefixed_fragment_shader(instancing_color=true, batching_color=true)[1079:1096].to_owned(),
    "#define USE_COLOR",
  )
  assert_eq(
    shader.prefixed_fragment_shader(instancing_color=true, batching_color=true)[1097:1120].to_owned(),
    "#define USE_COLOR_ALPHA",
  )
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_fragment_shader(batching_color=true).length(), 61)
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_fragment_shader(batching_color=true), "")
  assert_eq(basic.prefixed_vertex_shader(), "")
}

///|
test "Material shader writes missing-normal FLAT_SHADED" {
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.program_flat_shading(), true)
  assert_eq(lambert.prefixed_vertex_shader(), "#define FLAT_SHADED\n")
  assert_eq(lambert.prefixed_fragment_shader(), "#define FLAT_SHADED\n")
  assert_eq(lambert.prefixed_vertex_shader().length(), 20)
  assert_eq(lambert.prefixed_fragment_shader().length(), 20)
  assert_eq(lambert.prefixed_vertex_shader(has_normal=true), "#define HAS_NORMAL\n")
  assert_eq(lambert.prefixed_fragment_shader(has_normal=true), "")
  let pixels = FixedArray::make(4, b'\xFF')
  lambert.normal_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(lambert.prefixed_vertex_shader(), "")
  assert_eq(lambert.prefixed_fragment_shader(), "")
  lambert.normal_map = None
  lambert.wireframe = true
  assert_eq(lambert.prefixed_vertex_shader(), "")
  assert_eq(lambert.prefixed_fragment_shader(), "")
  assert_eq(@materials.Material::phong().prefixed_vertex_shader().length(), 20)
  assert_eq(@materials.Material::standard().prefixed_fragment_shader().length(), 20)
  assert_eq(@materials.Material::physical().prefixed_vertex_shader().length(), 20)
  assert_eq(@materials.Material::toon().prefixed_vertex_shader(), "")
  assert_eq(@materials.Material::basic().prefixed_vertex_shader(), "")
  assert_eq(@materials.Material::basic().prefixed_fragment_shader(), "")
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader().length(), 1608)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let raw = @materials.Material::raw()
  raw.flat_shading = true
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
}

///|
test "Material shader writes missing-normal USE_TANGENT" {
  let lambert = @materials.Material::lambert()
  lambert.anisotropy = 1.0
  assert_eq(
    lambert.prefixed_vertex_shader(has_tangent=true),
    "#define FLAT_SHADED\n",
  )
  assert_eq(
    lambert.prefixed_fragment_shader(has_tangent=true),
    "#define FLAT_SHADED\n",
  )
  assert_eq(
    lambert.prefixed_vertex_shader(has_tangent=true, has_normal=true),
    "#define USE_TANGENT\n#define HAS_NORMAL\n",
  )
  assert_eq(
    lambert.prefixed_fragment_shader(has_tangent=true, has_normal=true),
    "#define USE_TANGENT\n",
  )
  assert_eq(lambert.prefixed_vertex_shader(has_tangent=true, has_normal=true).length(), 39)
  assert_eq(lambert.prefixed_vertex_shader(has_normal=true), "#define HAS_NORMAL\n")
  let pixels = FixedArray::make(4, b'\xFF')
  lambert.anisotropy = 0.0
  lambert.normal_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(
    lambert.prefixed_vertex_shader(has_tangent=true),
    "#define USE_TANGENT\n",
  )
  assert_eq(
    lambert.prefixed_fragment_shader(has_tangent=true),
    "#define USE_TANGENT\n",
  )
  assert_eq(@materials.Material::basic().prefixed_vertex_shader(has_tangent=true), "")
  let shader = @materials.Material::shader()
  shader.anisotropy = 1.0
  assert_eq(shader.prefixed_vertex_shader(has_tangent=true).length(), 1651)
  assert_eq(shader.prefixed_fragment_shader(has_tangent=true).length(), 2084)
  let raw = @materials.Material::raw()
  raw.anisotropy = 1.0
  assert_eq(raw.prefixed_vertex_shader(has_tangent=true).length(), 92)
  assert_eq(raw.prefixed_fragment_shader(has_tangent=true).length(), 61)
}

///|
test "Material shader writes missing-normal USE_MORPHNORMALS" {
  let lambert = @materials.Material::lambert()
  assert_eq(
    lambert.prefixed_vertex_shader(has_morph_normals=true),
    "#define FLAT_SHADED\n",
  )
  assert_eq(lambert.prefixed_fragment_shader(), "#define FLAT_SHADED\n")
  assert_eq(
    lambert.prefixed_vertex_shader(has_morph_normals=true, has_normal=true),
    "#define HAS_NORMAL\n#define USE_MORPHNORMALS\n",
  )
  assert_eq(
    lambert.prefixed_vertex_shader(has_morph_normals=true, has_normal=true).length(),
    44,
  )
  assert_eq(lambert.prefixed_fragment_shader(has_normal=true), "")
  lambert.anisotropy = 1.0
  assert_eq(
    lambert.prefixed_vertex_shader(
      has_tangent=true,
      has_morph_normals=true,
      has_normal=true,
    ),
    "#define USE_TANGENT\n#define HAS_NORMAL\n#define USE_MORPHNORMALS\n",
  )
  assert_eq(
    lambert.prefixed_vertex_shader(has_tangent=true, has_morph_normals=true),
    "#define FLAT_SHADED\n",
  )
  assert_eq(@materials.Material::basic().prefixed_vertex_shader(has_morph_normals=true), "")
  assert_eq(
    @materials.Material::phong().prefixed_vertex_shader(
      has_morph_normals=true,
      has_normal=true,
    ).length(),
    44,
  )
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader(has_morph_normals=true).length(), 1633)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_vertex_shader(has_morph_normals=true).length(), 92)
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
}

///|
test "Material shader writes lit flat_shading FLAT_SHADED" {
  let lambert = @materials.Material::lambert()
  lambert.flat_shading = true
  assert_eq(
    lambert.prefixed_vertex_shader(has_normal=true),
    "#define HAS_NORMAL\n#define FLAT_SHADED\n",
  )
  assert_eq(lambert.prefixed_fragment_shader(has_normal=true), "#define FLAT_SHADED\n")
  assert_eq(lambert.prefixed_vertex_shader(has_normal=true).length(), 39)
  lambert.wireframe = true
  assert_eq(lambert.prefixed_vertex_shader(has_normal=true), "#define HAS_NORMAL\n")
  assert_eq(lambert.prefixed_fragment_shader(has_normal=true), "")
  lambert.wireframe = false
  lambert.anisotropy = 1.0
  assert_eq(
    lambert.prefixed_vertex_shader(
      has_tangent=true,
      has_morph_normals=true,
      has_normal=true,
    ),
    "#define HAS_NORMAL\n#define FLAT_SHADED\n",
  )
  let pixels = FixedArray::make(4, b'\xFF')
  lambert.normal_map = Some(@textures.Texture::from_rgba8(1, 1, pixels))
  assert_eq(lambert.prefixed_fragment_shader(has_normal=true), "#define FLAT_SHADED\n")
  let basic = @materials.Material::basic()
  basic.flat_shading = true
  assert_eq(basic.prefixed_vertex_shader(has_normal=true), "#define HAS_NORMAL\n")
  assert_eq(basic.prefixed_fragment_shader(), "")
  let phong = @materials.Material::phong()
  phong.flat_shading = true
  assert_eq(phong.prefixed_vertex_shader(has_normal=true).length(), 39)
  let physical = @materials.Material::physical()
  physical.flat_shading = true
  assert_eq(physical.prefixed_fragment_shader(has_normal=true).length(), 20)
  let shader = @materials.Material::shader()
  shader.flat_shading = true
  assert_eq(shader.prefixed_vertex_shader().length(), 1628)
  assert_eq(shader.prefixed_fragment_shader().length(), 2061)
  let raw = @materials.Material::raw()
  raw.flat_shading = true
  assert_eq(raw.prefixed_vertex_shader().length(), 92)
  assert_eq(raw.prefixed_fragment_shader().length(), 61)
}

///|
test "Material shader writes builtin HAS_NORMAL" {
  let lambert = @materials.Material::lambert()
  assert_eq(lambert.prefixed_vertex_shader(has_normal=true), "#define HAS_NORMAL\n")
  assert_eq(lambert.prefixed_vertex_shader(has_normal=true).length(), 19)
  assert_eq(lambert.prefixed_fragment_shader(has_normal=true), "")
  assert_eq(lambert.prefixed_vertex_shader(), "#define FLAT_SHADED\n")
  let basic = @materials.Material::basic()
  assert_eq(basic.prefixed_vertex_shader(has_normal=true), "#define HAS_NORMAL\n")
  assert_eq(basic.prefixed_fragment_shader(has_normal=true), "")
  assert_eq(basic.prefixed_vertex_shader(), "")
  let toon = @materials.Material::toon()
  assert_eq(toon.prefixed_vertex_shader(has_normal=true).length(), 19)
  assert_eq(toon.prefixed_fragment_shader(has_normal=true), "")
  let shader = @materials.Material::shader()
  assert_eq(shader.prefixed_vertex_shader(has_normal=true).length(), 1627)
  assert_eq(shader.prefixed_fragment_shader().length(), 2041)
  let raw = @materials.Material::raw()
  assert_eq(raw.prefixed_vertex_shader(has_normal=true).length(), 92)
  assert_eq(raw.prefixed_fragment_shader(has_normal=true).length(), 61)
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

