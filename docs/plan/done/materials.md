# materials

Landed. Behavior notes are the phase log. The checklist is the upstream file map for this module.

## Phase

### 4. A second material

Ambient light, one directional light, and `MeshLambertMaterial` or a thin Standard. This is the point to add a minimal node set (uniform, attribute, varying, a few vector operations) or a small compiler that knows these two materials. `WGSLNodeBuilder.js` stays whole upstream.

This phase has landed. `nodes` builds `MeshBasicMaterial` and `MeshLambertMaterial` from uniform, attribute, varying, and a few vector operations, then emits WGSL. The renderer uploads positions and normals, and packs ambient light plus the first directional light into the same uniform buffer. `examples/lit` is the rotating Lambert cube. The window sample is `scripts/build-lit.sh`. Host playback of that component stays out of this pass.

### 6. PBR subset

`MeshStandardMaterial` with baseColor, roughness, and metalness, plus the directional light already in place. Environment maps and PMREM stay later.

This phase has landed. `MeshStandardMaterial` defaults to roughness 1 and metalness 0. The shader is the direct Cook-Torrance term from r186: GGX distribution, Smith correlated visibility, Schlick fresnel, dielectric F0 of 0.04, and a roughness floor of 0.0525. Ambient light only multiplies the diffuse lobe. `examples/standard` is the rotating cube. The window sample is `scripts/build-standard.sh`. Host playback of that component stays out of this pass. Environment maps stay later.

## Behavior

`reversedDepthBuffer` has landed as `WebGPURenderer.set_reversed_depth`. It defaults to false. When it is on, the view camera's projection uses reversed depth and the color pass clears depth to 0. The compare is remapped with `ReversedDepthFuncs`: never and always swap, equal and not-equal swap, and the inequalities flip. The shadow camera uses the same reversed projection, the shadow pass clears depth to 0 and compares with `greater`, and the comparison sampler uses `greater`. Turning the flag off keeps the forward shadow map, `less`, and a clear value of 1.

`premultipliedAlpha` has landed. It defaults to false. A transparent mesh, point, or line with it set to true uses a blend whose color and alpha source factors are `one`, and whose destination factors stay `one-minus-src-alpha`. With the flag off, both source factors stay `src-alpha`. Opaque draws and wireframes have no blend, so the flag does not change them. The shadow pass has no color blend. Additive, subtractive, and multiply blending stay out.

`dispose` has landed. It dispatches a `dispose` event and does not remove the object from its parent. Geometries, materials, and textures stay shared, so this call does not free them.

`SpriteMaterial` color, map, and transparency have landed. A new material is white `(1, 1, 1)`, opacity `1`, transparent, rotation `0`, and size attenuation on. The map is empty. `hex=0xFF0000`, opacity `0.25`, and transparent off store red `(1, 0, 0)`. A 1×1 map stays that texture object. Setting the red channel to `0.5` leaves another new material at `1`. `alphaMap` and fog stay later. The renderer still does not draw sprites.

`SpriteMaterial` alpha map and fog have landed. A new material has fog on and an empty alpha map. `fog=false` stores false. A 1×1 alpha map whose second byte is `0x80` stays that texture object. Another new material stays fog on with an empty alpha map. The renderer still does not draw sprites.

`SpriteMaterial.copy` has landed. A red material at opacity `0.25`, transparent off, fog off, rotation `0.5`, and size attenuation off copies onto a white material. The destination color object stays in place and becomes `(1, 0, 0)`. Setting its red channel to `0.5` leaves the source at `1`. The color map and the alpha map are the source objects. Opacity, transparency, fog, rotation, and size attenuation match the source.

`PointsMaterial.map` has landed. A new material has an empty map, size `1`, and size attenuation on. A 1×1 map stays that texture object. Another new material stays empty. The point shader still draws from the material color and does not sample this map. `alphaMap` stays later.

`PointsMaterial.alphaMap` has landed. A new material has an empty alpha map and fog on. A 1×1 alpha map whose second byte is `0x80` stays that texture object. Another new material stays empty, and fog stays on. The point shader still draws from the material color and does not sample this map.

`PointsMaterial.copy` has landed. A red material at size `4`, size attenuation off, opacity `0.25`, transparent on, fog off, depth write off, depth test off, depth func `6`, color write off, premultiplied alpha on, and visible off copies onto a white material. The destination color object stays in place and becomes `(1, 0, 0)`. Setting its red channel to `0.5` leaves the source at `1`. Setting the destination size to `8` leaves the source at `4`. The color map and the alpha map are the source objects. Opacity, transparency, fog, size attenuation, depth, color write, premultiplied alpha, and visibility match the source.

`LineBasicMaterial.map` has landed. A new material has an empty map, white color, opacity `1`, and fog on. `hex=0x00FF00` stores green `(0, 1, 0)`. A 1×1 map stays that texture object. Another new material stays empty. The line shader still draws from the material color and does not sample this map. `linewidth`, `linecap`, and `linejoin` stay out.

`LineBasicMaterial.copy` has landed. A green material at opacity `0.25`, transparent on, fog off, depth write off, depth test off, depth func `6`, color write off, premultiplied alpha on, and visible off copies onto a white material. The destination color object stays in place and becomes `(0, 1, 0)`. Setting its green channel to `0.5` leaves the source at `1`. The color map is the source object. Opacity, transparency, fog, depth, color write, premultiplied alpha, and visibility match the source.

`SpriteMaterial` depth and visibility have landed. A new material writes depth, tests depth with func `3`, writes color, leaves premultiplied alpha off, and stays visible. Copying a material with depth write off, depth test off, depth func `6`, color write off, premultiplied alpha on, and visible off stores those values. The renderer still does not draw sprites.

`PointsMaterial.alphaTest` has landed. A new material stores `0`. Setting it to `0.4` leaves another new material at `0`. Copying onto a default material stores `0.4`. Setting the destination to `0.8` leaves the source at `0.4`. The point shader still does not discard fragments from this value.

`LineBasicMaterial.alphaTest` has landed. A new material stores `0`. Setting it to `0.4` leaves another new material at `0`. Copying onto a default material stores `0.4`. Setting the destination to `0.8` leaves the source at `0.4`. The line shader still does not discard fragments from this value.

`SpriteMaterial.alphaTest` has landed. A new material stores `0`. Setting it to `0.4` leaves another new material at `0`. Copying onto a default material stores `0.4`. Setting the destination to `0.8` leaves the source at `0.4`. The renderer still does not draw sprites.

Point and line `alphaTest` reaches the shader. A points material and a line material with `alphaTest` `0.4` and opacity `1` each store `0.4` on the collected item. The points shader discards when fragment alpha is below `uniforms.surface.z`. The line shader already discarded on that compare, and the uniform now carries the material value. Opacity `1` stays above `0.4`. Sprite `alphaTest` still has no draw.

`LineDashedMaterial` has landed. A new material has scale `1`, dash size `3`, and gap size `1`. The line fields live on the inner `line` material, which starts white with an empty map and `alphaTest` `0`. `hex=0x00FF00`, scale `2`, dash size `4`, and gap size `0.5` copy onto a default material. The destination color object stays in place and its green channel is `1`. Setting that channel to `0.5` leaves the source at `1`. Setting the destination dash size to `9` leaves the source at `4`. The color map is the source object. Another new material stays at scale `1`, dash size `3`, and gap size `1`. Lines still use `LineBasicMaterial`, and the shader still draws a solid line.

`LineDashedMaterial.keepsDistance` has landed. It has no upstream method of that name. Distance is multiplied by scale, then wrapped with GLSL `mod` over `dashSize + gapSize`. A remainder above `dashSize` is a gap. With scale `1`, dash size `3`, and gap size `1`, distances `0`, `3`, `4`, and `8` stay, and `3.5` is a gap. Distance `-0.5` wraps to `3.5` and is a gap. Scale `2` keeps distance `1.5` and drops `1.75`. A period of `0` aborts. The shader still draws a solid line.

`Material.vertexColors` has landed. A new basic, Lambert, or Standard material stores false. Setting the basic material to true leaves another basic material at false. Setting the Standard material to true leaves the Lambert material at false. The shader still ignores vertex colors.

`PointsMaterial.vertexColors` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. The point shader still ignores vertex colors.

`LineBasicMaterial.vertexColors` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. A dashed material copies the flag through its inner line material. The line shader still ignores vertex colors.

`SpriteMaterial.vertexColors` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. The renderer still does not draw sprites.

`Material.toneMapped` has landed. A new basic, Lambert, or Standard material stores true. Setting the basic material to false leaves another basic material at true. Setting the Standard material to false leaves the Lambert material at true. The tone-mapping pass still applies to every drawn material.

`PointsMaterial.toneMapped` has landed. A new material stores true. Setting it to false leaves another new material at true. Copying onto a default material stores false. Setting the destination back to true leaves the source at false. The tone-mapping pass still applies to every drawn point.

`LineBasicMaterial.toneMapped` has landed. A new material stores true. Setting it to false leaves another new material at true. Copying onto a default material stores false. Setting the destination back to true leaves the source at false. A dashed material copies the flag through its inner line material. The tone-mapping pass still applies to every drawn line.

`SpriteMaterial.toneMapped` has landed. A new material stores true. Setting it to false leaves another new material at true. Copying onto a default material stores false. Setting the destination back to true leaves the source at false. The renderer still does not draw sprites.

`Material.alphaHash` has landed. A new basic, Lambert, or Standard material stores false. Setting the basic material to true leaves another basic material at false. Setting the Standard material to true leaves the Lambert material at false. The shader still does not hash alpha.

`PointsMaterial.alphaHash` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. The point shader still does not hash alpha.

`LineBasicMaterial.alphaHash` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. A dashed material copies the flag through its inner line material. The line shader still does not hash alpha.

`SpriteMaterial.alphaHash` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. The renderer still does not draw sprites.

`Material.alphaToCoverage` has landed. A new basic, Lambert, or Standard material stores false. Setting the basic material to true leaves another basic material at false. Setting the Standard material to true leaves the Lambert material at false. The pipeline still does not enable alpha to coverage.

`PointsMaterial.alphaToCoverage` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. Point drawing still does not enable alpha to coverage.

`LineBasicMaterial.alphaToCoverage` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. A dashed material copies the flag through its inner line material. Line drawing still does not enable alpha to coverage.

`SpriteMaterial.alphaToCoverage` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. The renderer still does not draw sprites.

`Material.dithering` has landed. A new basic, Lambert, or Standard material stores false. Setting the basic material to true leaves another basic material at false. Setting the Standard material to true leaves the Lambert material at false. The shader still does not dither the color.

`PointsMaterial.dithering` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. The point shader still does not dither the color.

`LineBasicMaterial.dithering` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. A dashed material copies the flag through its inner line material. The line shader still does not dither the color.

`SpriteMaterial.dithering` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. The renderer still does not draw sprites.

`Material.polygonOffset` has landed. A new basic, Lambert, or Standard material stores false, factor `0`, and units `0`. Setting the basic material to true with factor `1` and units `-2` leaves another basic material at false, factor `0`, and units `0`. Setting the Standard material to true with factor `2` and units `4` leaves the Lambert material at false, factor `0`, and units `0`. The pipeline still does not offset polygons.

`PointsMaterial.polygonOffset` has landed. A new material stores false, factor `0`, and units `0`. Setting it to true with factor `1` and units `-2` leaves another new material at false, factor `0`, and units `0`. Copying onto a default material stores true, factor `1`, and units `-2`. Setting the destination factor to `3` and units to `5` leaves the source at `1` and `-2`. Point drawing still does not offset polygons.

`LineBasicMaterial.polygonOffset` has landed. A new material stores false, factor `0`, and units `0`. Setting it to true with factor `1` and units `-2` leaves another new material at false, factor `0`, and units `0`. Copying onto a default material stores true, factor `1`, and units `-2`. Setting the destination factor to `3` and units to `5` leaves the source at `1` and `-2`. A dashed material copies the three values through its inner line material. Setting the destination factor to `9` leaves the source at `1`. Line drawing still does not offset polygons.

`SpriteMaterial.polygonOffset` has landed. A new material stores false, factor `0`, and units `0`. Setting it to true with factor `1` and units `-2` leaves another new material at false, factor `0`, and units `0`. Copying onto a default material stores true, factor `1`, and units `-2`. Setting the destination factor to `3` and units to `5` leaves the source at `1` and `-2`. The renderer still does not draw sprites.

`Material.clipShadows` has landed. A new basic, Lambert, or Standard material stores false. Setting the basic material to true leaves another basic material at false. Setting the Standard material to true leaves the Lambert material at false. The shadow pass still does not clip.

`PointsMaterial.clipShadows` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. Points still do not cast shadows.

`LineBasicMaterial.clipShadows` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. A dashed material copies the flag through its inner line material. Lines still do not cast shadows.

`SpriteMaterial.clipShadows` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. The renderer still does not draw sprites.

`Material.clipIntersection` has landed. A new basic, Lambert, or Standard material stores false. Setting the basic material to true leaves another basic material at false. Setting the Standard material to true leaves the Lambert material at false. Clipping still uses the union, and the renderer still has no clipping planes.

`PointsMaterial.clipIntersection` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. Point drawing still has no clipping planes.

`LineBasicMaterial.clipIntersection` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. A dashed material copies the flag through its inner line material. Line drawing still has no clipping planes.

`SpriteMaterial.clipIntersection` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. The renderer still does not draw sprites.

`Material.allowOverride` has landed. A new basic, Lambert, or Standard material stores true. Setting the basic material to false leaves another basic material at true. Setting the Standard material to false leaves the Lambert material at true. The renderer still does not replace a material with a scene override.

`PointsMaterial.allowOverride` has landed. A new material stores true. Setting it to false leaves another new material at true. Copying onto a default material stores false. Setting the destination back to true leaves the source at false. Point drawing still does not replace a material with a scene override.

`LineBasicMaterial.allowOverride` has landed. A new material stores true. Setting it to false leaves another new material at true. Copying onto a default material stores false. Setting the destination back to true leaves the source at false. A dashed material copies the flag through its inner line material. Line drawing still does not replace a material with a scene override.

`SpriteMaterial.allowOverride` has landed. A new material stores true. Setting it to false leaves another new material at true. Copying onto a default material stores false. Setting the destination back to true leaves the source at false. The renderer still does not draw sprites.

`Material.blendAlpha` has landed. A new basic, Lambert, or Standard material stores `0`. Setting the basic material to `0.25` leaves another basic material at `0`. Setting the Standard material to `0.5` leaves the Lambert material at `0`. Blending still does not use the constant alpha.

`PointsMaterial.blendAlpha` has landed. A new material stores `0`. Setting it to `0.25` leaves another new material at `0`. Copying onto a default material stores `0.25`. Setting the destination to `0.5` leaves the source at `0.25`. Point blending still does not use the constant alpha.

`LineBasicMaterial.blendAlpha` has landed. A new material stores `0`. Setting it to `0.25` leaves another new material at `0`. Copying onto a default material stores `0.25`. Setting the destination to `0.5` leaves the source at `0.25`. A dashed material copies the value through its inner line material. Setting the destination to `0.75` leaves the source at `0.25`. Line blending still does not use the constant alpha.

`SpriteMaterial.blendAlpha` has landed. A new material stores `0`. Setting it to `0.25` leaves another new material at `0`. Copying onto a default material stores `0.25`. Setting the destination to `0.5` leaves the source at `0.25`. The renderer still does not draw sprites.

`Material.blendColor` has landed. A new basic, Lambert, or Standard material stores black `(0, 0, 0)`. Setting the basic material red channel to `1` leaves another basic material at black. Setting the Standard material green channel to `0.5` leaves the Lambert material at black. Blending still does not use the constant color.

`PointsMaterial.blendColor` has landed. A new material stores black `(0, 0, 0)`. Setting its red channel to `1` leaves another new material at black. Copying onto a default material writes `(1, 0, 0)` into the destination's own color object. Setting that red channel to `0.5` leaves the source at `1`. Point blending still does not use the constant color.

`LineBasicMaterial.blendColor` has landed. A new material stores black `(0, 0, 0)`. Setting its red channel to `1` leaves another new material at black. Copying onto a default material writes `(1, 0, 0)` into the destination's own color object. Setting that red channel to `0.5` leaves the source at `1`. A dashed material copies the color through its inner line material. Setting the destination red channel to `0.5` leaves the source at `1`. Line blending still does not use the constant color.

`SpriteMaterial.blendColor` has landed. A new material stores black `(0, 0, 0)`. Setting its red channel to `1` leaves another new material at black. Copying onto a default material writes `(1, 0, 0)` into the destination's own color object. Setting that red channel to `0.5` leaves the source at `1`. The renderer still does not draw sprites. Blending still does not use the constant color.

`Material.blending` has landed. A new basic, Lambert, or Standard material stores `Normal`, whose integer is `1`. Setting the basic material to `Additive` (`2`) leaves another basic material at `Normal`. Setting the Standard material to `Multiply` (`4`) leaves the Lambert material at `Normal`. `No` is `0`, `Subtractive` is `3`, and `Custom` is `5`. Transparent draws still use the existing source-alpha blend. The pipeline still does not read this field.

`PointsMaterial.blending` has landed. A new material stores `Normal`, whose integer is `1`. Setting it to `Additive` (`2`) leaves another new material at `Normal`. Copying onto a default material stores `Additive`. Setting the destination to `Multiply` (`4`) leaves the source at `Additive`. Point draws still use the existing source-alpha blend. The pipeline still does not read this field.

`LineBasicMaterial.blending` has landed. A new material stores `Normal`, whose integer is `1`. Setting it to `Additive` (`2`) leaves another new material at `Normal`. Copying onto a default material stores `Additive`. Setting the destination to `Multiply` (`4`) leaves the source at `Additive`. A dashed material copies the mode through its inner line material. Setting the destination to `Subtractive` (`3`) leaves the source at `Additive`. Line draws still use the existing source-alpha blend. The pipeline still does not read this field.

`SpriteMaterial.blending` has landed. A new material stores `Normal`, whose integer is `1`. Setting it to `Additive` (`2`) leaves another new material at `Normal`. Copying onto a default material stores `Additive`. Setting the destination to `Multiply` (`4`) leaves the source at `Additive`. The renderer still does not draw sprites. The pipeline still does not read this field.

`Material.blendSrc` has landed. A new basic, Lambert, or Standard material stores `SrcAlpha`, whose integer is `204`. Setting the basic material to `One` (`201`) leaves another basic material at `SrcAlpha`. Setting the Standard material to `Zero` (`200`) leaves the Lambert material at `SrcAlpha`. The remaining factors are `SrcColor` `202`, `OneMinusSrcColor` `203`, `OneMinusSrcAlpha` `205`, `DstAlpha` `206`, `OneMinusDstAlpha` `207`, `DstColor` `208`, `OneMinusDstColor` `209`, `SrcAlphaSaturate` `210`, `ConstantColor` `211`, `OneMinusConstantColor` `212`, `ConstantAlpha` `213`, and `OneMinusConstantAlpha` `214`. Transparent draws still use the existing source-alpha blend. The pipeline still does not read this field.

`PointsMaterial.blendSrc` has landed. A new material stores `SrcAlpha`, whose integer is `204`. Setting it to `One` (`201`) leaves another new material at `SrcAlpha`. Copying onto a default material stores `One`. Setting the destination to `Zero` (`200`) leaves the source at `One`. Point draws still use the existing source-alpha blend. The pipeline still does not read this field.

`LineBasicMaterial.blendSrc` has landed. A new material stores `SrcAlpha`, whose integer is `204`. Setting it to `One` (`201`) leaves another new material at `SrcAlpha`. Copying onto a default material stores `One`. Setting the destination to `Zero` (`200`) leaves the source at `One`. A dashed material copies the factor through its inner line material. Setting the destination to `DstColor` (`208`) leaves the source at `One`. Line draws still use the existing source-alpha blend. The pipeline still does not read this field.

`SpriteMaterial.blendSrc` has landed. A new material stores `SrcAlpha`, whose integer is `204`. Setting it to `One` (`201`) leaves another new material at `SrcAlpha`. Copying onto a default material stores `One`. Setting the destination to `Zero` (`200`) leaves the source at `One`. The renderer still does not draw sprites. The pipeline still does not read this field.

`Material.blendDst` has landed. A new basic, Lambert, or Standard material stores `OneMinusSrcAlpha`, whose integer is `205`. Setting the basic material to `Zero` (`200`) leaves another basic material at `OneMinusSrcAlpha`. Setting the Standard material to `One` (`201`) leaves the Lambert material at `OneMinusSrcAlpha`. Transparent draws still use the existing source-alpha blend. The pipeline still does not read this field.

`PointsMaterial.blendDst` has landed. A new material stores `OneMinusSrcAlpha`, whose integer is `205`. Setting it to `Zero` (`200`) leaves another new material at `OneMinusSrcAlpha`. Copying onto a default material stores `Zero`. Setting the destination to `One` (`201`) leaves the source at `Zero`. Point draws still use the existing source-alpha blend. The pipeline still does not read this field.

`LineBasicMaterial.blendDst` has landed. A new material stores `OneMinusSrcAlpha`, whose integer is `205`. Setting it to `Zero` (`200`) leaves another new material at `OneMinusSrcAlpha`. Copying onto a default material stores `Zero`. Setting the destination to `One` (`201`) leaves the source at `Zero`. A dashed material copies the factor through its inner line material. Setting the destination to `DstColor` (`208`) leaves the source at `Zero`. Line draws still use the existing source-alpha blend. The pipeline still does not read this field.

`SpriteMaterial.blendDst` has landed. A new material stores `OneMinusSrcAlpha`, whose integer is `205`. Setting it to `Zero` (`200`) leaves another new material at `OneMinusSrcAlpha`. Copying onto a default material stores `Zero`. Setting the destination to `One` (`201`) leaves the source at `Zero`. The renderer still does not draw sprites. The pipeline still does not read this field.

`Material.blendEquation` has landed. A new basic, Lambert, or Standard material stores `Add`, whose integer is `100`. Setting the basic material to `Subtract` (`101`) leaves another basic material at `Add`. Setting the Standard material to `Max` (`104`) leaves the Lambert material at `Add`. `ReverseSubtract` is `102` and `Min` is `103`. Transparent draws still use the existing source-alpha blend. The pipeline still does not read this field.

`PointsMaterial.blendEquation` has landed. A new material stores `Add`, whose integer is `100`. Setting it to `Subtract` (`101`) leaves another new material at `Add`. Copying onto a default material stores `Subtract`. Setting the destination to `Max` (`104`) leaves the source at `Subtract`. Point draws still use the existing source-alpha blend. The pipeline still does not read this field.

`LineBasicMaterial.blendEquation` has landed. A new material stores `Add`, whose integer is `100`. Setting it to `Subtract` (`101`) leaves another new material at `Add`. Copying onto a default material stores `Subtract`. Setting the destination to `Max` (`104`) leaves the source at `Subtract`. A dashed material copies the equation through its inner line material. Setting the destination to `Min` (`103`) leaves the source at `Subtract`. Line draws still use the existing source-alpha blend. The pipeline still does not read this field.

`SpriteMaterial.blendEquation` has landed. A new material stores `Add`, whose integer is `100`. Setting it to `Subtract` (`101`) leaves another new material at `Add`. Copying onto a default material stores `Subtract`. Setting the destination to `Max` (`104`) leaves the source at `Subtract`. The renderer still does not draw sprites. The pipeline still does not read this field.

`Material.blendSrcAlpha` has landed. A new basic, Lambert, or Standard material stores nothing. Setting the basic material to `One` (`201`) leaves another basic material empty. Setting the Standard material to `Zero` (`200`) leaves the Lambert material empty. An empty value means the alpha channel follows `blendSrc`. Transparent draws still use the existing source-alpha blend. The pipeline still does not read this field.

`PointsMaterial.blendSrcAlpha` has landed. A new material stores nothing. Setting it to `One` (`201`) leaves another new material empty. Copying onto a default material stores `One`. Setting the destination to `Zero` (`200`) leaves the source at `One`. An empty value means the alpha channel follows `blendSrc`. Point draws still use the existing source-alpha blend. The pipeline still does not read this field.

`LineBasicMaterial.blendSrcAlpha` has landed. A new material stores nothing. Setting it to `One` (`201`) leaves another new material empty. Copying onto a default material stores `One`. Setting the destination to `Zero` (`200`) leaves the source at `One`. A dashed material copies the factor through its inner line material. Clearing the destination leaves the source at `One`. An empty value means the alpha channel follows `blendSrc`. Line draws still use the existing source-alpha blend. The pipeline still does not read this field.

`SpriteMaterial.blendSrcAlpha` has landed. A new material stores nothing. Setting it to `One` (`201`) leaves another new material empty. Copying onto a default material stores `One`. Setting the destination to `Zero` (`200`) leaves the source at `One`. An empty value means the alpha channel follows `blendSrc`. The renderer still does not draw sprites. The pipeline still does not read this field.

`Material.blendDstAlpha` has landed. A new basic, Lambert, or Standard material stores nothing. Setting the basic material to `One` (`201`) leaves another basic material empty. Setting the Standard material to `Zero` (`200`) leaves the Lambert material empty. An empty value means the alpha channel follows `blendDst`. Transparent draws still use the existing source-alpha blend. The pipeline still does not read this field.

`PointsMaterial.blendDstAlpha` has landed. A new material stores nothing. Setting it to `One` (`201`) leaves another new material empty. Copying onto a default material stores `One`. Setting the destination to `Zero` (`200`) leaves the source at `One`. An empty value means the alpha channel follows `blendDst`. Point draws still use the existing source-alpha blend. The pipeline still does not read this field.

`LineBasicMaterial.blendDstAlpha` has landed. A new material stores nothing. Setting it to `One` (`201`) leaves another new material empty. Copying onto a default material stores `One`. Setting the destination to `Zero` (`200`) leaves the source at `One`. A dashed material copies the factor through its inner line material. Clearing the destination leaves the source at `One`. An empty value means the alpha channel follows `blendDst`. Line draws still use the existing source-alpha blend. The pipeline still does not read this field.

`SpriteMaterial.blendDstAlpha` has landed. A new material stores nothing. Setting it to `One` (`201`) leaves another new material empty. Copying onto a default material stores `One`. Setting the destination to `Zero` (`200`) leaves the source at `One`. An empty value means the alpha channel follows `blendDst`. The renderer still does not draw sprites. The pipeline still does not read this field.

`Material.blendEquationAlpha` has landed. A new basic, Lambert, or Standard material stores nothing. Setting the basic material to `Subtract` (`101`) leaves another basic material empty. Setting the Standard material to `Max` (`104`) leaves the Lambert material empty. An empty value means the alpha channel follows `blendEquation`. Transparent draws still use the existing source-alpha blend. The pipeline still does not read this field.

`PointsMaterial.blendEquationAlpha` has landed. A new material stores nothing. Setting it to `Subtract` (`101`) leaves another new material empty. Copying onto a default material stores `Subtract`. Setting the destination to `Max` (`104`) leaves the source at `Subtract`. An empty value means the alpha channel follows `blendEquation`. Point draws still use the existing source-alpha blend. The pipeline still does not read this field.

`LineBasicMaterial.blendEquationAlpha` has landed. A new material stores nothing. Setting it to `Subtract` (`101`) leaves another new material empty. Copying onto a default material stores `Subtract`. Setting the destination to `Max` (`104`) leaves the source at `Subtract`. A dashed material copies the equation through its inner line material. Clearing the destination leaves the source at `Subtract`. An empty value means the alpha channel follows `blendEquation`. Line draws still use the existing source-alpha blend. The pipeline still does not read this field.

`SpriteMaterial.blendEquationAlpha` has landed. A new material stores nothing. Setting it to `Subtract` (`101`) leaves another new material empty. Copying onto a default material stores `Subtract`. Setting the destination to `Max` (`104`) leaves the source at `Subtract`. An empty value means the alpha channel follows `blendEquation`. The renderer still does not draw sprites. The pipeline still does not read this field.

`Material.stencilWriteMask` has landed. A new basic, Lambert, or Standard material stores `255`. Setting the basic material to `0` leaves another basic material at `255`. Setting the Standard material to `1` leaves the Lambert material at `255`. The pipeline still does not read this field.

`PointsMaterial.stencilWriteMask` has landed. A new material stores `255`. Setting it to `0` leaves another new material at `255`. Copying onto a default material stores `0`. Setting the destination to `1` leaves the source at `0`. Point draws still do not read this field.

`LineBasicMaterial.stencilWriteMask` has landed. A new material stores `255`. Setting it to `0` leaves another new material at `255`. Copying onto a default material stores `0`. Setting the destination to `1` leaves the source at `0`. A dashed material copies the mask through its inner line material. Setting the destination to `9` leaves the source at `0`. Line draws still do not read this field.

`SpriteMaterial.stencilWriteMask` has landed. A new material stores `255`. Setting it to `0` leaves another new material at `255`. Copying onto a default material stores `0`. Setting the destination to `1` leaves the source at `0`. The renderer still does not draw sprites.

`Material.stencilFunc` has landed. A new basic, Lambert, or Standard material stores `Always`, whose integer is `519`. `Never` is `512`, `Less` is `513`, `Equal` is `514`, `LessEqual` is `515`, `Greater` is `516`, `NotEqual` is `517`, and `GreaterEqual` is `518`. Setting the basic material to `Never` leaves another basic material at `Always`. Setting the Standard material to `Equal` leaves the Lambert material at `Always`. The pipeline still does not read this field.

`PointsMaterial.stencilFunc` has landed. A new material stores `Always`, whose integer is `519`. Setting it to `Never` (`512`) leaves another new material at `Always`. Copying onto a default material stores `Never`. Setting the destination to `Equal` (`514`) leaves the source at `Never`. Point draws still do not read this field.

`LineBasicMaterial.stencilFunc` has landed. A new material stores `Always`, whose integer is `519`. Setting it to `Never` (`512`) leaves another new material at `Always`. Copying onto a default material stores `Never`. Setting the destination to `Equal` (`514`) leaves the source at `Never`. A dashed material copies the function through its inner line material. Setting the destination to `Greater` (`516`) leaves the source at `Never`. Line draws still do not read this field.

`SpriteMaterial.stencilFunc` has landed. A new material stores `Always`, whose integer is `519`. Setting it to `Never` (`512`) leaves another new material at `Always`. Copying onto a default material stores `Never`. Setting the destination to `Equal` (`514`) leaves the source at `Never`. The renderer still does not draw sprites.

`Material.stencilRef` has landed. A new basic, Lambert, or Standard material stores `0`. Setting the basic material to `1` leaves another basic material at `0`. Setting the Standard material to `7` leaves the Lambert material at `0`. The pipeline still does not read this field.

`PointsMaterial.stencilRef` has landed. A new material stores `0`. Setting it to `1` leaves another new material at `0`. Copying onto a default material stores `1`. Setting the destination to `7` leaves the source at `1`. Point draws still do not read this field.

`LineBasicMaterial.stencilRef` has landed. A new material stores `0`. Setting it to `1` leaves another new material at `0`. Copying onto a default material stores `1`. Setting the destination to `7` leaves the source at `1`. A dashed material copies the reference through its inner line material. Setting the destination to `9` leaves the source at `1`. Line draws still do not read this field.

`SpriteMaterial.stencilRef` has landed. A new material stores `0`. Setting it to `1` leaves another new material at `0`. Copying onto a default material stores `1`. Setting the destination to `7` leaves the source at `1`. The renderer still does not draw sprites.

`Material.stencilFuncMask` has landed. A new basic, Lambert, or Standard material stores `255`. Setting the basic material to `0` leaves another basic material at `255`. Setting the Standard material to `1` leaves the Lambert material at `255`. The pipeline still does not read this field.

`PointsMaterial.stencilFuncMask` has landed. A new material stores `255`. Setting it to `0` leaves another new material at `255`. Copying onto a default material stores `0`. Setting the destination to `1` leaves the source at `0`. Point draws still do not read this field.

`LineBasicMaterial.stencilFuncMask` has landed. A new material stores `255`. Setting it to `0` leaves another new material at `255`. Copying onto a default material stores `0`. Setting the destination to `1` leaves the source at `0`. A dashed material copies the mask through its inner line material. Setting the destination to `9` leaves the source at `0`. Line draws still do not read this field.

`SpriteMaterial.stencilFuncMask` has landed. A new material stores `255`. Setting it to `0` leaves another new material at `255`. Copying onto a default material stores `0`. Setting the destination to `1` leaves the source at `0`. The renderer still does not draw sprites.

`Material.stencilFail` has landed. A new basic, Lambert, or Standard material stores `Keep`, whose integer is `7680`. `Zero` is `0`, `Replace` is `7681`, `Increment` is `7682`, `Decrement` is `7683`, `IncrementWrap` is `34055`, `DecrementWrap` is `34056`, and `Invert` is `5386`. Setting the basic material to `Zero` leaves another basic material at `Keep`. Setting the Standard material to `Replace` leaves the Lambert material at `Keep`. The pipeline still does not read this field.

`PointsMaterial.stencilFail` has landed. A new material stores `Keep`, whose integer is `7680`. Setting it to `Zero` leaves another new material at `Keep`. Copying onto a default material stores `Zero` (`0`). Setting the destination to `Replace` (`7681`) leaves the source at `0`. Point draws still do not read this field.

`LineBasicMaterial.stencilFail` has landed. A new material stores `Keep`, whose integer is `7680`. Setting it to `Zero` leaves another new material at `Keep`. Copying onto a default material stores `Zero` (`0`). Setting the destination to `Replace` (`7681`) leaves the source at `0`. A dashed material copies the operation through its inner line material. Setting that destination to `Increment` (`7682`) leaves the source at `0`. Line draws still do not read this field.

`SpriteMaterial.stencilFail` has landed. A new material stores `Keep`, whose integer is `7680`. Setting it to `Zero` leaves another new material at `Keep`. Copying onto a default material stores `Zero` (`0`). Setting the destination to `Replace` (`7681`) leaves the source at `0`. The renderer still does not draw sprites.

`Material.stencilZFail` has landed. A new basic, Lambert, or Standard material stores `Keep`, whose integer is `7680`. Setting the basic material to `Zero` leaves another basic material at `Keep`. Setting the Standard material to `Replace` leaves the Lambert material at `Keep`. The pipeline still does not read this field.

`PointsMaterial.stencilZFail` has landed. A new material stores `Keep`, whose integer is `7680`. Setting it to `Zero` leaves another new material at `Keep`. Copying onto a default material stores `Zero` (`0`). Setting the destination to `Replace` (`7681`) leaves the source at `0`. Point draws still do not read this field.

`LineBasicMaterial.stencilZFail` has landed. A new material stores `Keep`, whose integer is `7680`. Setting it to `Zero` leaves another new material at `Keep`. Copying onto a default material stores `Zero` (`0`). Setting the destination to `Replace` (`7681`) leaves the source at `0`. A dashed material copies the operation through its inner line material. Setting that destination to `Increment` (`7682`) leaves the source at `0`. Line draws still do not read this field.

`SpriteMaterial.stencilZFail` has landed. A new material stores `Keep`, whose integer is `7680`. Setting it to `Zero` leaves another new material at `Keep`. Copying onto a default material stores `Zero` (`0`). Setting the destination to `Replace` (`7681`) leaves the source at `0`. The renderer still does not draw sprites.

`Material.stencilZPass` has landed. A new basic, Lambert, or Standard material stores `Keep`, whose integer is `7680`. Setting the basic material to `Zero` leaves another basic material at `Keep`. Setting the Standard material to `Replace` leaves the Lambert material at `Keep`. The pipeline still does not read this field.

`PointsMaterial.stencilZPass` has landed. A new material stores `Keep`, whose integer is `7680`. Setting it to `Zero` leaves another new material at `Keep`. Copying onto a default material stores `Zero` (`0`). Setting the destination to `Replace` (`7681`) leaves the source at `0`. Point draws still do not read this field.

`LineBasicMaterial.stencilZPass` has landed. A new material stores `Keep`, whose integer is `7680`. Setting it to `Zero` leaves another new material at `Keep`. Copying onto a default material stores `Zero` (`0`). Setting the destination to `Replace` (`7681`) leaves the source at `0`. A dashed material copies the operation through its inner line material. Setting that destination to `Increment` (`7682`) leaves the source at `0`. Line draws still do not read this field.

`SpriteMaterial.stencilZPass` has landed. A new material stores `Keep`, whose integer is `7680`. Setting it to `Zero` leaves another new material at `Keep`. Copying onto a default material stores `Zero` (`0`). Setting the destination to `Replace` (`7681`) leaves the source at `0`. The renderer still does not draw sprites.

`Material.stencilWrite` has landed. A new basic, Lambert, or Standard material stores `false`. Setting the basic material to `true` leaves another basic material at `false`. Setting the Standard material to `true` leaves the Lambert material at `false`. The pipeline still does not read this field.

`PointsMaterial.stencilWrite` has landed. A new material stores `false`. Setting it to `true` leaves another new material at `false`. Copying onto a default material stores `true`. Setting the destination to `false` leaves the source at `true`. Point draws still do not read this field.

`LineBasicMaterial.stencilWrite` has landed. A new material stores `false`. Setting it to `true` leaves another new material at `false`. Copying onto a default material stores `true`. Setting the destination to `false` leaves the source at `true`. A dashed material copies the flag through its inner line material. Setting that destination to `false` leaves the source at `true`. Line draws still do not read this field.

`SpriteMaterial.stencilWrite` has landed. A new material stores `false`. Setting it to `true` leaves another new material at `false`. Copying onto a default material stores `true`. Setting the destination to `false` leaves the source at `true`. The renderer still does not draw sprites.

`Material.clippingPlanes` has landed. A new basic, Lambert, or Standard material stores no planes. Setting the basic material to one plane with constant `1` leaves another basic material empty. Setting the Standard material to one plane with constant `2` leaves the Lambert material empty. The renderer still does not clip with these planes.

`PointsMaterial.clippingPlanes` has landed. A new material stores no planes. Setting it to one plane with constant `1` leaves another new material empty. Copying onto a default material stores that plane. Setting the destination to one plane with constant `2` leaves the source at `1`. Point draws still do not clip with these planes.

`LineBasicMaterial.clippingPlanes` has landed. A new material stores no planes. Setting it to one plane with constant `1` leaves another new material empty. Copying onto a default material stores that plane. Setting the destination to one plane with constant `2` leaves the source at `1`. A dashed material copies the planes through its inner line material. Setting that destination to one plane with constant `3` leaves the source at `1`. Line draws still do not clip with these planes.

`SpriteMaterial.clippingPlanes` has landed. A new material stores no planes. Setting it to one plane with constant `1` leaves another new material empty. Copying onto a default material stores that plane. Setting the destination to one plane with constant `2` leaves the source at `1`. The renderer still does not draw sprites.

`Material.precision` has landed. A new basic, Lambert, or Standard material stores no override. Setting the basic material to `Highp` leaves another basic material empty. Setting the Standard material to `Mediump` leaves the Lambert material empty. The pipeline still does not read this field.

`PointsMaterial.precision` has landed. A new material stores no override. Setting it to `Highp` leaves another new material empty. Copying onto a default material stores `Highp`. Setting the destination to `Mediump` leaves the source at `Highp`. Point draws still do not read this field.

`LineBasicMaterial.precision` has landed. A new material stores no override. Setting it to `Highp` leaves another new material empty. Copying onto a default material stores `Highp`. Setting the destination to `Mediump` leaves the source at `Highp`. A dashed material copies the override through its inner line material. Setting that destination to `Lowp` leaves the source at `Highp`. Line draws still do not read this field.

`SpriteMaterial.precision` has landed. A new material stores no override. Setting it to `Highp` leaves another new material empty. Copying onto a default material stores `Highp`. Setting the destination to `Mediump` leaves the source at `Highp`. The renderer still does not draw sprites.

`Material.userData` has landed. A new basic, Lambert, or Standard material stores an empty string map. Setting the basic material's `label` to `mesh` leaves another basic material empty. Setting the Standard material's `label` to `lit` leaves the Lambert material empty. The renderer still does not read this map.

`PointsMaterial.userData` has landed. A new material stores an empty string map. Setting its `label` to `point` leaves another new material empty. Copying onto a default material stores `point` in a new map. Setting the destination's `label` to `copy` leaves the source at `point`. Point draws still do not read this map.

`LineBasicMaterial.userData` has landed. A new material stores an empty string map. Setting its `label` to `line` leaves another new material empty. Copying onto a default material stores `line` in a new map. Setting the destination's `label` to `copy` leaves the source at `line`. A dashed material copies the map through its inner line material. Setting that destination's `label` to `other` leaves the source at `dash`. Line draws still do not read this map.

`SpriteMaterial.userData` has landed. A new material stores an empty string map. Setting its `label` to `sprite` leaves another new material empty. Copying onto a default material stores `sprite` in a new map. Setting the destination's `label` to `copy` leaves the source at `sprite`. The renderer still does not draw sprites.

`Material.version` has landed. A new basic, Lambert, or Standard material stores `0`. Setting the basic material to `1` leaves another basic material at `0`. Setting the Standard material to `2` leaves the Lambert material at `0`. The renderer still does not read this counter.

`PointsMaterial.version` has landed. A new material stores `0`. Setting it to `1` leaves another new material at `0`. Copying onto a material that already stores `3` leaves that counter at `3` and the source at `1`. Setting the destination to `2` leaves the source at `1`. Point draws still do not read this counter.

`LineBasicMaterial.version` has landed. A new material stores `0`. Setting it to `1` leaves another new material at `0`. Copying onto a material that already stores `3` leaves that counter at `3` and the source at `1`. Setting the destination to `2` leaves the source at `1`. A dashed material keeps its own counter through the inner line material: copying a source at `4` onto a destination at `5` leaves both numbers in place, and setting the destination to `6` leaves the source at `4`. Line draws still do not read this counter.

`SpriteMaterial.version` has landed. A new material stores `0`. Setting it to `1` leaves another new material at `0`. Copying onto a material that already stores `3` leaves that counter at `3` and the source at `1`. Setting the destination to `2` leaves the source at `1`. The renderer still does not draw sprites.

`Material.needsUpdate` has landed. `set_needs_update(false)` leaves a new basic material at `0`. `set_needs_update(true)` raises it to `1`, and a second call raises it to `2`. Another basic material stays at `0`. Setting a Standard material once leaves it at `1` and leaves the Lambert material at `0`. The renderer still does not recompile from this counter.

`PointsMaterial.needsUpdate` has landed. `set_needs_update(false)` leaves a new material at `0`. Two `true` calls raise it to `2` and leave another new material at `0`. Copying onto a material that already stores `3` leaves that counter at `3` and the source at `2`. Point draws still do not recompile from this counter.

`LineBasicMaterial.needsUpdate` has landed. `set_needs_update(false)` leaves a new material at `0`. Two `true` calls raise it to `2` and leave another new material at `0`. Copying onto a material that already stores `3` leaves that counter at `3` and the source at `2`. A dashed material increments through its inner line: one `true` call stores `1`, copying onto a destination at `5` leaves both numbers in place, and `false` leaves the source at `1`. Line draws still do not recompile from this counter.

`SpriteMaterial.needsUpdate` has landed. `set_needs_update(false)` leaves a new material at `0`. Two `true` calls raise it to `2` and leave another new material at `0`. Copying onto a material that already stores `3` leaves that counter at `3` and the source at `2`. The renderer still does not draw sprites.

`Material.setAlphaTest` has landed. Writing `0` onto a new basic material keeps `alpha_test` at `0` and `version` at `0`. Writing `0.2` stores that threshold and raises `version` to `1`. Writing `0.4` stores `0.4` and leaves `version` at `1`. Writing `0` stores `0` and raises `version` to `2`. Writing `-1` stores `-1` and leaves `version` at `2`. Another basic material stays at `0`. Writing `0.5` on a Standard material stores `0.5` and `version` `1`, and leaves the Lambert material at `0`. The renderer still discards fragments below the stored threshold.

`PointsMaterial.setAlphaTest` has landed. Writing `0` keeps `alpha_test` at `0` and `version` at `0`. Writing `0.2` stores `0.2` and raises `version` to `1`. Writing `0.4` leaves `version` at `1`. Writing `0` raises `version` to `2`. Writing `-1` stores `-1` and leaves `version` at `2`. Another new material stays at `0`. Copying that `-1` onto a material at `version` `3` stores `-1` and leaves the counter at `3`. Writing `0.2` on the source raises it to `3`. Copying again stores `0.2` on the destination and raises its counter to `4`, leaving the source at `3`. Point draws still discard fragments below the stored threshold.

`LineBasicMaterial.setAlphaTest` has landed. Writing `0` keeps `alpha_test` at `0` and `version` at `0`. Writing `0.2` stores `0.2` and raises `version` to `1`. Writing `0.4` leaves `version` at `1`. Writing `0` raises `version` to `2`. Writing `-1` stores `-1` and leaves `version` at `2`. Another new material stays at `0`. Copying that `-1` onto a material at `version` `3` stores `-1` and leaves the counter at `3`. Writing `0.2` on the source raises it to `3`. Copying again stores `0.2` on the destination and raises its counter to `4`, leaving the source at `3`. A dashed material writes through its inner line: `0.2` stores that threshold and `version` `1`. Copying onto a dashed material at `version` `5` stores `0.2` and raises that counter to `6`, leaving the source at `1`. Line draws still discard fragments below the stored threshold.

`SpriteMaterial.setAlphaTest` has landed. Writing `0` keeps `alpha_test` at `0` and `version` at `0`. Writing `0.2` stores `0.2` and raises `version` to `1`. Writing `0.4` leaves `version` at `1`. Writing `0` raises `version` to `2`. Writing `-1` stores `-1` and leaves `version` at `2`. Another new material stays at `0`. Copying that `-1` onto a material at `version` `3` stores `-1` and leaves the counter at `3`. Writing `0.2` on the source raises it to `3`. Copying again stores `0.2` on the destination and raises its counter to `4`, leaving the source at `3`. The renderer still does not draw sprites.

`Material.id` has landed. Each new basic, Lambert, or Standard material takes the next integer, starting at `0`. A second basic material is one past the first. Lambert is one past that basic material, and Standard is one past Lambert, three past the first basic material. The renderer still does not read this id.

`PointsMaterial.id` has landed. A new points material takes the next integer from the same counter as mesh materials. The following points material is one past that, and copying leaves both ids in place. A basic material created afterward is one past the second points material. Point draws still do not read this id.

`LineBasicMaterial.id` has landed. A new line material takes the next integer from the same counter as mesh materials. The following line material is one past that, and copying leaves both ids in place. A dashed material takes the next id through its inner line. Copying that dashed material onto the next one leaves both inner ids in place. Line draws still do not read this id.

`SpriteMaterial.id` has landed. A new sprite material takes the next integer from the same counter as mesh materials. The following sprite material is one past that, and copying leaves both ids in place. A points material created afterward is one past the second sprite material. The renderer still does not draw sprites.

`Material.uuid` has landed. A new basic, Lambert, or Standard material stores a 36-character id whose version nibble is `4`. Setting the basic material's uuid to `mesh` leaves another basic material at length 36. Setting the Lambert material to `lambert` and the Standard material to `lit` leaves those three strings in place. The renderer still does not read this string.

`PointsMaterial.uuid` has landed. A new material stores a 36-character id whose version nibble is `4`. Copying onto another new material leaves the destination string in place. Setting the source to `point` and the destination to `copy` leaves those two strings in place. Point draws still do not read this string.

`LineBasicMaterial.uuid` has landed. A new material stores a 36-character id whose version nibble is `4`. Copying onto another new material leaves the destination string in place. Setting the source to `line` and the destination to `copy` leaves the source at `line`. A dashed material stores its own 36-character id on the inner line. Copying onto another dashed material leaves that destination string in place. Setting the source to `dash` and the destination to `other` leaves the source at `dash`. Line draws still do not read this string.

`SpriteMaterial.uuid` has landed. A new material stores a 36-character id whose version nibble is `4`. Copying onto another new material leaves the destination string in place. Setting the source to `sprite` and the destination to `copy` leaves the source at `sprite`. The renderer still does not draw sprites.

`Material.name` has landed. A new basic, Lambert, or Standard material stores an empty string. Setting the basic material's name to `mesh` leaves another basic material empty. Setting the Standard material's name to `lit` leaves the Lambert material empty. The renderer still does not read this name.

`PointsMaterial.name` has landed. A new material stores an empty string. Setting its name to `point` leaves another new material empty. Copying onto a default material stores `point`. Setting the destination's name to `copy` leaves the source at `point`. Point draws still do not read this name.

`LineBasicMaterial.name` has landed. A new material stores an empty string. Setting its name to `line` leaves another new material empty. Copying onto a default material stores `line`. Setting the destination's name to `copy` leaves the source at `line`. A dashed material copies the name through its inner line. Setting that destination's name to `other` leaves the source at `dash`. Line draws still do not read this name.

`SpriteMaterial.name` has landed. A new material stores an empty string. Setting its name to `sprite` leaves another new material empty. Copying onto a default material stores `sprite`. Setting the destination's name to `copy` leaves the source at `sprite`. The renderer still does not draw sprites.

`Material.type` has landed as `type_name`. A new basic material stores `MeshBasicMaterial`. A Lambert material stores `MeshLambertMaterial`. A Standard material stores `MeshStandardMaterial`. The renderer still does not read this name.

`PointsMaterial.type` has landed as `type_name`. A new material stores `PointsMaterial`. Copying onto another new material leaves that class name in place. Point draws still do not read this name.

`LineBasicMaterial.type` has landed as `type_name`. A new material stores `LineBasicMaterial`. Copying onto another new material leaves that class name in place. A dashed material stores the same name on its inner line, and copying leaves both names in place. Line draws still do not read this name.

`SpriteMaterial.type` has landed as `type_name`. A new material stores `SpriteMaterial`. Copying onto another new material leaves that class name in place. The renderer still does not draw sprites.

`LineDashedMaterial.type` has landed as `type_name`. A new material stores `LineDashedMaterial`. Copying onto another new material leaves that class name in place. The inner line still stores `LineBasicMaterial`. Line draws still do not read this name.

`Material.copy` has landed. A Lambert material named `lit`, colored `(1, 0, 0)`, with emissive `(0.25, 0.5, 0.75)`, intensity `2`, opacity `0.25`, transparency on, fog off, wireframe on, roughness `0.4`, metalness `0.6`, flat shading on, side `Back`, shadow side `Back`, alpha test `0.2`, user data `mesh`, and one clipping plane of constant `1` copies onto a basic material whose version was `3`. The destination color, blend color, and emissive objects stay in place. Its version becomes `4` because alpha test crosses `0`. Its id, uuid, `MeshBasicMaterial` type name, and `Basic` kind stay in place. The source stays `MeshLambertMaterial` at version `1`. Setting the destination color red channel to `0.5`, emissive green to `0`, name to `copy`, and user data to `copy` leaves the source at `1`, `0.5`, `lit`, and `mesh`. Replacing the destination plane array with constant `2` leaves the source at `1`. A new Standard material stays empty, opaque, roughness `1`, and `MeshStandardMaterial`. The renderer still does not read this copy.

`Material.clone` has landed. It builds a new material of the same kind and then copies. A basic material named `plain` clones to another `MeshBasicMaterial` at version `0` with a new id. Renaming the clone to `copy` leaves the source at `plain`. A Lambert material named `lit`, colored `(1, 0, 0)`, with alpha test `0.2`, version `5`, uuid `mesh`, and user data `mesh` clones to `MeshLambertMaterial`. The clone's version is `1` because alpha test crosses `0` on a new material. Its uuid is 36 characters with version nibble `4`, and its id differs from the source. The source stays at version `5` and uuid `mesh`. Setting the clone's red channel to `0.5` and user data to `copy` leaves the source at `1` and `mesh`. A Standard material at roughness `0.2` and metalness `0.8` clones to `MeshStandardMaterial` with those values. The renderer still does not read this clone.

`PointsMaterial.clone` has landed. A new material clones to `PointsMaterial` at version `0`, size `1`, and a new id. A material named `point`, colored `(1, 0, 0)`, size `4`, size attenuation off, alpha test `0.2`, version `5`, uuid `point`, and user data `point` clones to `PointsMaterial`. The clone's version is `1`. Its uuid is 36 characters with version nibble `4`, and its id differs from the source. The source stays at version `5` and uuid `point`. Setting the clone's size to `8` and red channel to `0.5` leaves the source at `4` and `1`. Point draws still do not read this clone.

`LineBasicMaterial.clone` has landed. A new material clones to `LineBasicMaterial` at version `0`, opacity `1`, and a new id. A material named `line`, colored `(0, 1, 0)`, opacity `0.25`, fog off, alpha test `0.2`, version `5`, uuid `line`, and user data `line` clones to `LineBasicMaterial`. The clone's version is `1`. Its uuid is 36 characters with version nibble `4`, and its id differs from the source. The source stays at version `5` and uuid `line`. Setting the clone's opacity to `1` and green channel to `0.5` leaves the source at `0.25` and `1`. Line draws still do not read this clone.

`SpriteMaterial.clone` has landed. A new material clones to `SpriteMaterial` at version `0`, rotation `0`, size attenuation on, and a new id. A material named `sprite`, colored `(0, 0, 1)`, opacity `0.25`, fog off, rotation `0.5`, size attenuation off, alpha test `0.2`, version `5`, uuid `sprite`, and user data `sprite` clones to `SpriteMaterial`. The clone's version is `1`. Its uuid is 36 characters with version nibble `4`, and its id differs from the source. The source stays at version `5` and uuid `sprite`. Setting the clone's rotation to `1` and blue channel to `0.5` leaves the source at `0.5` and `1`. The renderer still does not draw sprites.

`LineDashedMaterial.clone` has landed. A new material clones to `LineDashedMaterial` with scale `1`, dash size `3`, gap size `1`, and an inner `LineBasicMaterial` at version `0` with a new id. A material with scale `2`, dash size `4`, gap size `5`, inner name `dash`, color `(0, 1, 0)`, alpha test `0.2`, version `5`, uuid `dash`, and user data `dash` clones to `LineDashedMaterial`. The inner line stays `LineBasicMaterial`. Its version is `1`. Its uuid is 36 characters with version nibble `4`, and its id differs from the source. The source stays at version `5` and uuid `dash`. Setting the clone's scale to `9` and green channel to `0.5` leaves the source at `2` and `1`. Line draws still do not read this clone.

`Material.addEventListener` has landed. Registering the same `dispose` listener twice on a basic material leaves one entry. Copying a Lambert material that has that listener onto a new basic material leaves the destination list empty and the source list at length `1`. A new Standard material has no `dispose` listeners. The renderer still does not read this list.

`PointsMaterial.addEventListener` has landed. Registering the same `dispose` listener twice leaves one entry. Copying a material that has that listener onto a new points material leaves the destination list empty and the source list at length `1`. Point draws still do not read this list.

`LineBasicMaterial.addEventListener` has landed. Registering the same `dispose` listener twice leaves one entry. Copying a material that has that listener onto a new line material leaves the destination list empty and the source list at length `1`. Line draws still do not read this list.

`SpriteMaterial.addEventListener` has landed. Registering the same `dispose` listener twice leaves one entry. Copying a material that has that listener onto a new sprite material leaves the destination list empty and the source list at length `1`. The renderer still does not draw sprites.

`Material.hasEventListener` has landed. Before registration a basic material reports false for a `dispose` listener. After `addEventListener`, that same listener reports true. A different function and the event name `change` stay false. A new Lambert material and a new Standard material also report false. The renderer still does not read this list.

`PointsMaterial.hasEventListener` has landed. Before registration a points material reports false for a `dispose` listener. After `addEventListener`, that same listener reports true. A different function and the event name `change` stay false. Another new points material also reports false. Point draws still do not read this list.

`LineBasicMaterial.hasEventListener` has landed. Before registration a line material reports false for a `dispose` listener. After `addEventListener`, that same listener reports true. A different function and the event name `change` stay false. Another new line material also reports false. Line draws still do not read this list.

`SpriteMaterial.hasEventListener` has landed. Before registration a sprite material reports false for a `dispose` listener. After `addEventListener`, that same listener reports true. A different function and the event name `change` stay false. Another new sprite material also reports false. The renderer still does not draw sprites.

`Material.removeEventListener` has landed. Removing a `dispose` listener that was never registered leaves the check false. After registering that listener and a `change` listener, removing the `dispose` listener leaves `dispose` false and `change` true. The same removal on the basic material leaves a Lambert material's `dispose` listener in place. The renderer still does not read this list.

`PointsMaterial.removeEventListener` has landed. Removing a `dispose` listener that was never registered leaves the check false. After registering that listener and a `change` listener, removing the `dispose` listener leaves `dispose` false and `change` true. The same removal leaves another points material's `dispose` listener in place. Point draws still do not read this list.

`LineBasicMaterial.removeEventListener` has landed. Removing a `dispose` listener that was never registered leaves the check false. After registering that listener and a `change` listener, removing the `dispose` listener leaves `dispose` false and `change` true. The same removal leaves another line material's `dispose` listener in place. Line draws still do not read this list.

`SpriteMaterial.removeEventListener` has landed. Removing a `dispose` listener that was never registered leaves the check false. After registering that listener and a `change` listener, removing the `dispose` listener leaves `dispose` false and `change` true. The same removal leaves another sprite material's `dispose` listener in place. The renderer still does not draw sprites.

`Material.dispatchEvent` has landed. A basic material's `change` listener adds `1` and its `dispose` listener adds `10`. Dispatching `change` leaves the counter at `1`. Dispatching a missing name leaves it at `1`. Dispatching `change` on a new Lambert material and `dispose` on a new Standard material also leaves it at `1`. The renderer still does not read this list.

`PointsMaterial.dispatchEvent` has landed. A points material's `change` listener adds `1` and its `dispose` listener adds `10`. Dispatching `change` leaves the counter at `1`. Dispatching a missing name leaves it at `1`. Dispatching `change` on another new points material also leaves it at `1`. Point draws still do not read this list.

`LineBasicMaterial.dispatchEvent` has landed. A line material's `change` listener adds `1` and its `dispose` listener adds `10`. Dispatching `change` leaves the counter at `1`. Dispatching a missing name leaves it at `1`. Dispatching `change` on another new line material also leaves it at `1`. Line draws still do not read this list.

`SpriteMaterial.dispatchEvent` has landed. A sprite material's `change` listener adds `1` and its `dispose` listener adds `10`. Dispatching `change` leaves the counter at `1`. Dispatching a missing name leaves it at `1`. Dispatching `change` on another new sprite material also leaves it at `1`. The renderer still does not draw sprites.

`Material.dispose` has landed. A basic material's `dispose` listener adds `1` and its `change` listener adds `10`. Disposing leaves the counter at `1`. Disposing a new Lambert material leaves it at `1`. A Standard material with only a `change` listener also leaves it at `1`. The renderer still does not free resources for this call.

`PointsMaterial.dispose` has landed. A points material's `dispose` listener adds `1` and its `change` listener adds `10`. Disposing leaves the counter at `1`. Another points material with only a `change` listener also leaves it at `1`. Point draws still do not free resources for this call.

`LineBasicMaterial.dispose` has landed. A line material's `dispose` listener adds `1` and its `change` listener adds `10`. Disposing leaves the counter at `1`. Another line material with only a `change` listener also leaves it at `1`. Line draws still do not free resources for this call.

`SpriteMaterial.dispose` has landed. A sprite material's `dispose` listener adds `1` and its `change` listener adds `10`. Disposing leaves the counter at `1`. Another sprite material with only a `change` listener also leaves it at `1`. The renderer still does not draw sprites.

`LineDashedMaterial.dispose` has landed. It notifies the inner line. That line's `dispose` listener adds `1` and its `change` listener adds `10`. Disposing leaves the counter at `1`. Another dashed material whose inner line has only a `change` listener also leaves it at `1`. Line draws still do not free resources for this call.

`Material.normalMap` has landed. A new Basic, Lambert, and Standard material each start with an empty normal map. A Lambert material stores a 1×1 map whose second byte is `0x80`. Another Lambert material stays empty. Copying onto a Basic material keeps that same texture object. Clearing the destination leaves the source map in place. A new Standard material stays empty. The renderer still does not sample this map. `normalMapType` and `normalScale` stay later.

`Material.normalScale` has landed. A new Basic, Lambert, and Standard material each store `(1, 1)`. A Lambert material set to `(0.25, 0.5)` leaves another Lambert material at `(1, 1)`. Copying onto a Basic material writes `(0.25, 0.5)` into the destination vector. Setting the destination x to `0` leaves the source at `0.25`. A new Standard material stays at `(1, 1)`. The renderer still does not sample the normal map.

`Material.displacementMap` has landed. A new Basic, Lambert, and Standard material each start with an empty displacement map. A Lambert material stores a 1×1 map whose second byte is `0x80`. Another Lambert material stays empty. Copying onto a Basic material keeps that same texture object. Clearing the destination leaves the source map in place. A new Standard material stays empty. The renderer still does not move vertices for this map. `displacementScale` and `displacementBias` stay later.

`Material.displacementScale` has landed. A new Basic, Lambert, and Standard material each store `1`. A Lambert material set to `0.25` leaves another Lambert material at `1`. Copying onto a Basic material stores `0.25`. Setting the destination to `2` leaves the source at `0.25`. A new Standard material stays at `1`. The renderer still does not move vertices for this scale. `displacementBias` stays later.

`Material.displacementBias` has landed. A new Basic, Lambert, and Standard material each store `0`. A Lambert material set to `0.25` leaves another Lambert material at `0`. Copying onto a Basic material stores `0.25`. Setting the destination to `-1` leaves the source at `0.25`. A new Standard material stays at `0`. The renderer still does not move vertices for this bias.

`Material.specularMap` has landed. A new Basic, Lambert, and Standard material each start with an empty specular map. A Lambert material stores a 1×1 map whose second byte is `0x80`. Another Lambert material stays empty. Copying onto a Basic material keeps that same texture object. Clearing the destination leaves the source map in place. A new Standard material stays empty. The renderer still does not sample this map.

`Material.envMap` has landed. A new Basic, Lambert, and Standard material each start with an empty environment map. A Lambert material stores a 1×1 map whose second byte is `0x80`. Another Lambert material stays empty. Copying onto a Basic material keeps that same texture object. Clearing the destination leaves the source map in place. A new Standard material stays empty. The renderer still does not sample this map. `envMapRotation` stays later.

`Material.envMapRotation` has landed. A new Basic, Lambert, and Standard material each store Euler `(0, 0, 0)` in `XYZ` order. A Lambert material set to `(0.25, 0.5, -0.1)` leaves another Lambert material at `(0, 0, 0)`. Copying onto a Basic material writes `(0.25, 0.5, -0.1)` into the destination Euler. Setting the destination x to `0` leaves the source at `0.25`. A new Standard material stays at `(0, 0, 0)`. The renderer still does not sample the environment map.

`Material.reflectivity` has landed. A new Basic, Lambert, and Standard material each store `1`. A Lambert material set to `0.25` leaves another Lambert material at `1`. Copying onto a Basic material stores `0.25`. Setting the destination to `0` leaves the source at `0.25`. A new Standard material stays at `1`. The renderer still does not sample the environment map. `envMapIntensity` stays later.

`Material.envMapIntensity` has landed. A new Basic, Lambert, and Standard material each store `1`. A Lambert material set to `2` leaves another Lambert material at `1`. Copying onto a Basic material stores `2`. Setting the destination to `0` leaves the source at `2`. A new Standard material stays at `1`. The renderer still does not sample the environment map. `refractionRatio` stays later.

`Material.refractionRatio` has landed. A new Basic, Lambert, and Standard material each store `0.98`. A Lambert material set to `0.5` leaves another Lambert material at `0.98`. Copying onto a Basic material stores `0.5`. Setting the destination to `1` leaves the source at `0.5`. A new Standard material stays at `0.98`. The renderer still does not refract with this ratio. `lightMap` stays later.

`Material.lightMap` has landed. A new Basic, Lambert, and Standard material each start with an empty light map. A Lambert material stores a 1×1 map whose second byte is `0x80`. Another Lambert material stays empty. Copying onto a Basic material keeps that same texture object. Clearing the destination leaves the source map in place. A new Standard material stays empty. The renderer still does not sample this map. `lightMapIntensity` stays later.

`Material.lightMapIntensity` has landed. A new Basic, Lambert, and Standard material each store `1`. A Lambert material set to `2` leaves another Lambert material at `1`. Copying onto a Basic material stores `2`. Setting the destination to `0` leaves the source at `2`. A new Standard material stays at `1`. The renderer still does not sample the light map. `aoMap` stays later.

`Material.aoMap` has landed. A new Basic, Lambert, and Standard material each start with an empty ambient occlusion map. A Lambert material stores a 1×1 map whose second byte is `0x80`. Another Lambert material stays empty. Copying onto a Basic material keeps that same texture object. Clearing the destination leaves the source map in place. A new Standard material stays empty. The renderer still does not sample this map. `aoMapIntensity` stays later.

`Material.aoMapIntensity` has landed. A new Basic, Lambert, and Standard material each store `1`. A Lambert material set to `2` leaves another Lambert material at `1`. Copying onto a Basic material stores `2`. Setting the destination to `0` leaves the source at `2`. A new Standard material stays at `1`. The renderer still does not sample the ambient occlusion map. `bumpMap` stays later.

`Material.bumpMap` has landed. A new Basic, Lambert, and Standard material each start with an empty bump map. A Lambert material stores a 1×1 map whose second byte is `0x80`. Another Lambert material stays empty. Copying onto a Basic material keeps that same texture object. Clearing the destination leaves the source map in place. A new Standard material stays empty. The renderer still does not sample this map. `bumpScale` stays later.

`Material.bumpScale` has landed. A new Basic, Lambert, and Standard material each store `1`. A Lambert material set to `2` leaves another Lambert material at `1`. Copying onto a Basic material stores `2`. Setting the destination to `0` leaves the source at `2`. A new Standard material stays at `1`. The renderer still does not sample the bump map.

`Material.wireframeLinewidth` has landed. A new Basic, Lambert, and Standard material each store `1`. A Lambert material set to `4` leaves another Lambert material at `1`. Copying onto a Basic material stores `4`. Setting the destination to `2` leaves the source at `4`. A new Standard material stays at `1`. Wireframe draws still use a 1-pixel line. `wireframeLinecap` stays later.

`Material.wireframeLinecap` has landed. A new Basic, Lambert, and Standard material each store round. A Lambert material set to bevel leaves another Lambert material round. Copying onto a Basic material stores bevel. Setting the destination to miter leaves the source bevel. A new Standard material stays round. Wireframe draws still use a 1-pixel line. `wireframeLinejoin` stays later.

`Material.wireframeLinejoin` has landed. A new Basic, Lambert, and Standard material each store round. A Lambert material set to bevel leaves another Lambert material round. Copying onto a Basic material stores bevel. Setting the destination to miter leaves the source bevel. A new Standard material stays round. Wireframe draws still use a 1-pixel line.

`Material.defines` has landed. A new Basic material and a new Lambert material each store an empty map. A new Standard material stores `STANDARD` mapped to an empty string. Setting `FOO` to `1` on one Standard material leaves another Standard material without `FOO`, and its `STANDARD` value stays an empty string. Copying that Standard material onto a Basic material leaves the destination without `STANDARD` and without `FOO`, and the source keeps `FOO` as `1`. Copying onto another Standard material stores only `STANDARD` mapped to an empty string. Setting the destination `STANDARD` to `x` leaves the source as an empty string. The renderer still does not read the map.

`PointsMaterial.side` has landed. A new material stores front. Setting it to back leaves another new material at front. Copying onto a default material stores back. Setting the destination to double leaves the source at back. Point drawing still does not cull from this value. `LineBasicMaterial.side` stays later.

`LineBasicMaterial.side` has landed. A new material stores front. Setting it to back leaves another new material at front. Copying onto a default material stores back. Setting the destination to double leaves the source at back. Line drawing still does not cull from this value. `SpriteMaterial.side` stays later.

`SpriteMaterial.side` has landed. A new material stores front. Setting it to back leaves another new material at front. Copying onto a default material stores back. Setting the destination to double leaves the source at back. The renderer still does not draw sprites. `PointsMaterial.shadowSide` stays later.

`PointsMaterial.shadowSide` has landed. A new material stores nothing. Setting it to back leaves another new material empty. Copying onto a default material stores back. Setting the destination to double leaves the source at back. Points still do not cast shadows. `LineBasicMaterial.shadowSide` stays later.

`LineBasicMaterial.shadowSide` has landed. A new material stores nothing. Setting it to back leaves another new material empty. Copying onto a default material stores back. Setting the destination to double leaves the source at back. Lines still do not cast shadows. `SpriteMaterial.shadowSide` stays later.

`SpriteMaterial.shadowSide` has landed. A new material stores nothing. Setting it to back leaves another new material empty. Copying onto a default material stores back. Setting the destination to double leaves the source at back. The renderer still does not draw sprites. `PointsMaterial.forceSinglePass` stays later.

`PointsMaterial.forceSinglePass` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. Point drawing still does not merge front and back faces. `LineBasicMaterial.forceSinglePass` stays later.

`LineBasicMaterial.forceSinglePass` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. Line drawing still does not merge front and back faces. `SpriteMaterial.forceSinglePass` stays later.

`SpriteMaterial.forceSinglePass` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. The renderer still does not draw sprites.

`Material.anisotropyRotation` has landed. The upstream comment says the default is `1`. The assignment stores `0`. A new Basic, Lambert, and Standard material each store `0`. A Lambert material set to `0.25` leaves another Lambert material at `0`. Copying onto a Basic material stores `0.25`. Setting the destination to `1` leaves the source at `0.25`. A new Standard material stays at `0`. The renderer still does not rotate anisotropy. `anisotropyMap` stays later.

`Material.anisotropyMap` has landed. A new Basic, Lambert, and Standard material each start with an empty anisotropy map. A Lambert material stores a 1×1 map whose second byte is `0x80`. Another Lambert material stays empty. Copying onto a Basic material keeps that same texture object. Clearing the destination leaves the source map in place. A new Standard material stays empty. The renderer still does not sample this map. `clearcoatMap` stays later.

`Material.clearcoatMap` has landed. A new Basic, Lambert, and Standard material each start with an empty clearcoat map. A Lambert material stores a 1×1 map whose second byte is `0x80`. Another Lambert material stays empty. Copying onto a Basic material keeps that same texture object. Clearing the destination leaves the source map in place. A new Standard material stays empty. The renderer still does not sample this map. `clearcoatRoughness` stays later.

`Material.clearcoatRoughness` has landed. A new Basic, Lambert, and Standard material each store `0`. A Lambert material set to `0.25` leaves another Lambert material at `0`. Copying onto a Basic material stores `0.25`. Setting the destination to `1` leaves the source at `0.25`. A new Standard material stays at `0`. The renderer still does not draw a clear coat. `clearcoatRoughnessMap` stays later.

`Material.clearcoatRoughnessMap` has landed. A new Basic, Lambert, and Standard material each start with an empty clearcoat roughness map. A Lambert material stores a 1×1 map whose second byte is `0x80`. Another Lambert material stays empty. Copying onto a Basic material keeps that same texture object. Clearing the destination leaves the source map in place. A new Standard material stays empty. The renderer still does not sample this map. `clearcoatNormalScale` stays later.

`Material.clearcoatNormalScale` has landed. A new Basic, Lambert, and Standard material each store `(1, 1)`. A Lambert material set to `(0.25, 0.5)` leaves another Lambert material at `(1, 1)`. Copying onto a Basic material stores `(0.25, 0.5)` in the destination vector. Setting the destination `x` to `0` leaves the source at `0.25`. A new Standard material stays at `(1, 1)`. The renderer still does not scale a clearcoat normal. `clearcoatNormalMap` stays later.

`Material.clearcoatNormalMap` has landed. A new Basic, Lambert, and Standard material each start with an empty clearcoat normal map. A Lambert material stores a 1×1 map whose second byte is `0x80`. Another Lambert material stays empty. Copying onto a Basic material keeps that same texture object. Clearing the destination leaves the source map in place. A new Standard material stays empty. The renderer still does not sample this map. `ior` stays later.

`Material.ior` has landed. A new Basic, Lambert, and Standard material each store `1.5`. A Lambert material set to `2` leaves another Lambert material at `1.5`. Copying onto a Basic material stores `2`. Setting the destination to `1` leaves the source at `2`. A new Standard material stays at `1.5`. The stored `reflectivity` stays independent of `ior`. The renderer still does not use this index of refraction. `iridescenceMap` stays later.

`Material.iridescenceMap` has landed. A new Basic, Lambert, and Standard material each start with an empty iridescence map. A Lambert material stores a 1×1 map whose second byte is `0x80`. Another Lambert material stays empty. Copying onto a Basic material keeps that same texture object. Clearing the destination leaves the source map in place. A new Standard material stays empty. The renderer still does not sample this map. `iridescenceIOR` stays later.

`Material.iridescenceIOR` has landed. A new Basic, Lambert, and Standard material each store `1.3`. A Lambert material set to `2` leaves another Lambert material at `1.3`. Copying onto a Basic material stores `2`. Setting the destination to `1` leaves the source at `2`. A new Standard material stays at `1.3`. The renderer still does not compute iridescence. `iridescenceThicknessRange` stays later.

`Material.iridescenceThicknessRange` has landed. A new Basic, Lambert, and Standard material each store `[100, 400]`. A Lambert material set to `[20, 80]` leaves another Lambert material at `[100, 400]`. Copying onto a Basic material stores `20` and `80` in a new array. Setting the destination minimum to `0` leaves the source at `20`. A new Standard material stays at `[100, 400]`. The renderer still does not compute iridescence. `iridescenceThicknessMap` stays later.

`Material.iridescenceThicknessMap` has landed. A new Basic, Lambert, and Standard material each start with an empty iridescence thickness map. A Lambert material stores a 1×1 map whose second byte is `0x80`. Another Lambert material stays empty. Copying onto a Basic material keeps that same texture object. Clearing the destination leaves the source map in place. A new Standard material stays empty. The renderer still does not sample this map. `sheenColor` stays later.

`Material.sheenColor` has landed. A new Basic, Lambert, and Standard material each store black. A Lambert material set to `(0.25, 0.5, 0.75)` leaves another Lambert material black. Copying onto a Basic material stores those components in the destination color. Setting the destination to red leaves the source at `(0.25, 0.5, 0.75)`. A new Standard material stays black. The renderer still does not compute sheen. `sheenColorMap` stays later.

`Material.sheenColorMap` has landed. A new Basic, Lambert, and Standard material each start with an empty sheen color map. A Lambert material stores a 1×1 map whose second byte is `0x80`. Another Lambert material stays empty. Copying onto a Basic material keeps that same texture object. Clearing the destination leaves the source map in place. A new Standard material stays empty. The renderer still does not sample this map. `sheenRoughness` stays later.

`Material.sheenRoughness` has landed. A new Basic, Lambert, and Standard material each store `1`. A Lambert material set to `0.25` leaves another Lambert material at `1`. Copying onto a Basic material stores `0.25`. Setting the destination to `0` leaves the source at `0.25`. A new Standard material stays at `1`. The renderer still does not compute sheen. `sheenRoughnessMap` stays later.

`Material.sheenRoughnessMap` has landed. A new Basic, Lambert, and Standard material each start with an empty sheen roughness map. A Lambert material stores a 1×1 map whose second byte is `0x80`. Another Lambert material stays empty. Copying onto a Basic material keeps that same texture object. Clearing the destination leaves the source map in place. A new Standard material stays empty. The renderer still does not sample this map. `transmissionMap` stays later.

`Material.transmissionMap` has landed. A new Basic, Lambert, and Standard material each start with an empty transmission map. A Lambert material stores a 1×1 map whose second byte is `0x80`. Another Lambert material stays empty. Copying onto a Basic material keeps that same texture object. Clearing the destination leaves the source map in place. A new Standard material stays empty. The renderer still does not sample this map. `thickness` stays later.

`Material.thickness` has landed. A new Basic, Lambert, and Standard material each store `0`. A Lambert material set to `0.25` leaves another Lambert material at `0`. Copying onto a Basic material stores `0.25`. Setting the destination to `1` leaves the source at `0.25`. A new Standard material stays at `0`. The renderer still does not compute transmission. `thicknessMap` stays later.

`Material.thicknessMap` has landed. A new Basic, Lambert, and Standard material each start with an empty thickness map. A Lambert material stores a 1×1 map whose second byte is `0x80`. Another Lambert material stays empty. Copying onto a Basic material keeps that same texture object. Clearing the destination leaves the source map in place. A new Standard material stays empty. The renderer still does not sample this map. `attenuationDistance` stays later.

`Material.attenuationDistance` has landed. A new Basic, Lambert, and Standard material each store positive infinity. A Lambert material set to `2` leaves another Lambert material at positive infinity. Copying onto a Basic material stores `2`. Setting the destination to `1` leaves the source at `2`. A new Standard material stays at positive infinity. The renderer still does not compute attenuation. `attenuationColor` stays later.

`Material.attenuationColor` has landed. A new Basic, Lambert, and Standard material each store white. A Lambert material set to `(0.25, 0.5, 0.75)` leaves another Lambert material white. Copying onto a Basic material stores those components in the destination color. Setting the destination to red leaves the source at `(0.25, 0.5, 0.75)`. A new Standard material stays white. The renderer still does not compute attenuation. `specularIntensity` stays later.

`Material.specularIntensity` has landed. A new Basic, Lambert, and Standard material each store `1`. A Lambert material set to `0.25` leaves another Lambert material at `1`. Copying onto a Basic material stores `0.25`. Setting the destination to `0` leaves the source at `0.25`. A new Standard material stays at `1`. The renderer still does not scale specular intensity. `specularIntensityMap` stays later.

`Material.specularIntensityMap` has landed. A new Basic, Lambert, and Standard material each start with an empty specular intensity map. A Lambert material stores a 1×1 map whose second byte is `0x80`. Another Lambert material stays empty. Copying onto a Basic material keeps that same texture object. Clearing the destination leaves the source map in place. A new Standard material stays empty. The renderer still does not sample this map. `specularColor` stays later.

`Material.specularColor` has landed. A new Basic, Lambert, and Standard material each store white. A Lambert material set to `(0.25, 0.5, 0.75)` leaves another Lambert material white. Copying onto a Basic material stores those components in the destination color. Setting the destination to red leaves the source at `(0.25, 0.5, 0.75)`. A new Standard material stays white. The renderer still does not tint specular reflection. `specularColorMap` stays later.

`Material.specularColorMap` has landed. A new Basic, Lambert, and Standard material each start with an empty specular color map. A Lambert material stores a 1×1 map whose second byte is `0x80`. Another Lambert material stays empty. Copying onto a Basic material keeps that same texture object. Clearing the destination leaves the source map in place. A new Standard material stays empty. The renderer still does not sample this map. `anisotropy` stays later.

`Material.anisotropy` has landed. A new Basic, Lambert, and Standard material each store `0` with `version` `0`. Setting `0` again leaves `version` at `0`. Setting `0.25` stores `0.25` and makes `version` `1`. Setting `0.5` keeps `version` at `1`. Setting `0` stores `0` and makes `version` `2`. Setting `-1` keeps `version` at `2`. A Lambert material set to `0.25` leaves another Lambert material at `0` with `version` `0`. Copying onto a Basic material stores `0.25` and makes the destination `version` `1`. Setting the destination back to `0` makes its `version` `2` and leaves the source at `0.25` with `version` `1`. A new Standard material stays at `0` with `version` `0`. The renderer still does not draw anisotropy. `clearcoat` stays later.

`Material.clearcoat` has landed. A new Basic, Lambert, and Standard material each store `0` with `version` `0`. Setting `0` again leaves `version` at `0`. Setting `0.25` stores `0.25` and makes `version` `1`. Setting `0.5` keeps `version` at `1`. Setting `0` stores `0` and makes `version` `2`. Setting `-1` keeps `version` at `2`. A Lambert material set to `0.25` leaves another Lambert material at `0` with `version` `0`. Copying onto a Basic material stores `0.25` and makes the destination `version` `1`. Setting the destination back to `0` makes its `version` `2` and leaves the source at `0.25` with `version` `1`. A new Standard material stays at `0` with `version` `0`. The renderer still does not draw a clear coat. `iridescence` stays later.

`Material.iridescence` has landed. A new Basic, Lambert, and Standard material each store `0` with `version` `0`. Setting `0` again leaves `version` at `0`. Setting `0.25` stores `0.25` and makes `version` `1`. Setting `0.5` keeps `version` at `1`. Setting `0` stores `0` and makes `version` `2`. Setting `-1` keeps `version` at `2`. A Lambert material set to `0.25` leaves another Lambert material at `0` with `version` `0`. Copying onto a Basic material stores `0.25` and makes the destination `version` `1`. Setting the destination back to `0` makes its `version` `2` and leaves the source at `0.25` with `version` `1`. A new Standard material stays at `0` with `version` `0`. The renderer still does not compute iridescence. `dispersion` stays later.

`Material.dispersion` has landed. A new Basic, Lambert, and Standard material each store `0` with `version` `0`. Setting `0` again leaves `version` at `0`. Setting `0.25` stores `0.25` and makes `version` `1`. Setting `0.5` keeps `version` at `1`. Setting `0` stores `0` and makes `version` `2`. Setting `-1` keeps `version` at `2`. A Lambert material set to `0.25` leaves another Lambert material at `0` with `version` `0`. Copying onto a Basic material stores `0.25` and makes the destination `version` `1`. Setting the destination back to `0` makes its `version` `2` and leaves the source at `0.25` with `version` `1`. A new Standard material stays at `0` with `version` `0`. The renderer still does not compute dispersion. `retroreflectivity` stays later.

`Material.retroreflectivity` has landed. A new Basic, Lambert, and Standard material each store `0` with `version` `0`. Setting `0` again leaves `version` at `0`. Setting `0.25` stores `0.25` and makes `version` `1`. Setting `0.5` keeps `version` at `1`. Setting `0` stores `0` and makes `version` `2`. Setting `-1` keeps `version` at `2`. A Lambert material set to `0.25` leaves another Lambert material at `0` with `version` `0`. Copying onto a Basic material stores `0.25` and makes the destination `version` `1`. Setting the destination back to `0` makes its `version` `2` and leaves the source at `0.25` with `version` `1`. A new Standard material stays at `0` with `version` `0`. The renderer still does not compute retroreflection. `sheen` stays later.

`Material.sheen` has landed. A new Basic, Lambert, and Standard material each store `0` with `version` `0`. Setting `0` again leaves `version` at `0`. Setting `0.25` stores `0.25` and makes `version` `1`. Setting `0.5` keeps `version` at `1`. Setting `0` stores `0` and makes `version` `2`. Setting `-1` keeps `version` at `2`. A Lambert material set to `0.25` leaves another Lambert material at `0` with `version` `0`. Copying onto a Basic material stores `0.25` and makes the destination `version` `1`. Setting the destination back to `0` makes its `version` `2` and leaves the source at `0.25` with `version` `1`. A new Standard material stays at `0` with `version` `0`. The renderer still does not compute sheen. `transmission` stays later.

`Material.transmission` has landed. A new Basic, Lambert, and Standard material each store `0` with `version` `0`. Setting `0` again leaves `version` at `0`. Setting `0.25` stores `0.25` and makes `version` `1`. Setting `0.5` keeps `version` at `1`. Setting `0` stores `0` and makes `version` `2`. Setting `-1` keeps `version` at `2`. A Lambert material set to `0.25` leaves another Lambert material at `0` with `version` `0`. Copying onto a Basic material stores `0.25` and makes the destination `version` `1`. Setting the destination back to `0` makes its `version` `2` and leaves the source at `0.25` with `version` `1`. A new Standard material stays at `0` with `version` `0`. The renderer still does not compute transmission. `isMeshPhysicalMaterial` stays later.

`Material.isMeshPhysicalMaterial` has landed. Basic, Lambert, and Standard stay false. `Material::physical` with hex `0xFF0000`, roughness `0.25`, and metalness `0.5` stores true, type `MeshPhysicalMaterial`, kind `Physical`, and shading `Standard`. Its defines map `STANDARD` and `PHYSICAL` to empty strings. Copying it onto a Basic material keeps the destination false, kind `Basic`, and type `MeshBasicMaterial`, and stores roughness `0.25`. Copying a Standard material onto a Physical material keeps the destination true and resets its defines to `STANDARD` and `PHYSICAL`, dropping a `FOO` key. Cloning keeps the flag, the type, the kind, and roughness `0.25`, with a new id. The renderer still shades it as Standard. `MeshToonMaterial` stays later.

`Material.isMeshToonMaterial` has landed. Basic, Lambert, Standard, and Physical stay false. `Material::toon` with hex `0x00FF00` stores true, type `MeshToonMaterial`, kind `Toon`, and shading `Lambert`. The green channel is `1` and the red channel is `0`. Its defines map `TOON` to an empty string and have no `STANDARD` key. Copying it onto a Basic material keeps the destination false, kind `Basic`, and type `MeshBasicMaterial`, and stores red `0` with green `1`. Copying a blue Basic material onto a Toon material keeps the destination true, stores blue `1`, and keeps a `FOO` define set to `1`, along with `TOON`. Cloning keeps the flag, the type, the kind, and green `1`, with a new id. The renderer still shades it as Lambert. `gradientMap` stays later.

`Material.gradientMap` has landed. A new Basic, Lambert, Toon, Standard, and Physical material each start with an empty gradient map. A Toon material stores a 1×1 map whose second byte is `0x80`. Another Toon material stays empty. Copying onto a Basic material keeps that same texture object. Clearing the destination leaves the source map in place. The renderer still does not sample this map. `matcap` stays later.

`Material.matcap` has landed. A new Basic, Lambert, Standard, Physical, and Toon material each start with an empty matcap. A Lambert material stores a 1×1 map whose second byte is `0x80`. Another Lambert material stays empty. Copying onto a Basic material keeps that same texture object. Clearing the destination leaves the source map in place. The renderer still does not sample this map. `isMeshMatcapMaterial` stays later.

`Material.isMeshMatcapMaterial` has landed. Basic, Lambert, Standard, Physical, and Toon stay false. `Material::matcap` with hex `0x0000FF` stores true, type `MeshMatcapMaterial`, kind `Matcap`, and shading `Basic`. The red channel is `0` and the blue channel is `1`. Its defines map `MATCAP` to an empty string and have no `TOON` key. Copying it onto a Basic material keeps the destination false, kind `Basic`, and type `MeshBasicMaterial`, and stores red `0` with blue `1`. Copying a Standard material onto a Matcap material keeps the destination true and resets its defines to `MATCAP`, dropping a `FOO` key and leaving out `STANDARD`. Cloning keeps the flag, the type, the kind, and blue `1`, with a new id. The renderer still shades it as Basic. `MeshNormalMaterial` stays later.

`Material.isMeshNormalMaterial` has landed. Basic, Lambert, Standard, Physical, Toon, and Matcap stay false. `Material::normal` with hex `0x00FF00` stores true, type `MeshNormalMaterial`, kind `Normal`, and shading `Basic`. The red channel is `0` and the green channel is `1`. Its defines stay empty. Copying it onto a Basic material keeps the destination false, kind `Basic`, and type `MeshBasicMaterial`, and stores red `0` with green `1`. Copying a red Matcap material onto a Normal material keeps the destination true, stores red `1` and green `0`, and keeps a `FOO` define set to `1` without adding `MATCAP`. Cloning keeps the flag, the type, the kind, and green `1`, with a new id. The renderer still shades it as Basic. `MeshDepthMaterial` stays later.

`Material.isMeshDepthMaterial` has landed. Basic, Lambert, Standard, Physical, Toon, Matcap, and Normal stay false. `Material::depth` with hex `0x0000FF` stores true, type `MeshDepthMaterial`, kind `Depth`, and shading `Basic`. The red channel is `0` and the blue channel is `1`. Its defines stay empty. Copying it onto a Basic material keeps the destination false, kind `Basic`, and type `MeshBasicMaterial`, and stores red `0` with blue `1`. Copying a green Normal material onto a Depth material keeps the destination true, stores red `0` and green `1`, and keeps a `FOO` define set to `1`. Cloning keeps the flag, the type, the kind, and blue `1`, with a new id. The renderer still shades it as Basic. `depthPacking` stays later.

`Material.depthPacking` has landed. A new Basic, Lambert, Standard, Physical, Toon, Matcap, Normal, and Depth material each store `Basic`, integer `3200`. Setting a Lambert material to `RGBA` stores `3201` and leaves another Lambert material at `3200`. Copying onto a Basic material stores `3201`. Setting the destination back to `Basic` leaves the source at `3201`. `RGB` is `3202` and `RG` is `3203`. The renderer still does not pack depth. `MeshDistanceMaterial` stays later.

`Material.isMeshDistanceMaterial` has landed. Basic, Lambert, Standard, Physical, Toon, Matcap, Normal, and Depth stay false. `Material::distance` with hex `0xFF0000` stores true, type `MeshDistanceMaterial`, kind `Distance`, and shading `Basic`. The red channel is `1` and the green channel is `0`. Its defines stay empty. Copying it onto a Basic material keeps the destination false, kind `Basic`, and type `MeshBasicMaterial`, and stores red `1` with green `0`. Copying a blue Depth material onto a Distance material keeps the destination true, stores red `0` and blue `1`, and keeps a `FOO` define set to `1`. Cloning keeps the flag, the type, the kind, and red `1`, with a new id. The renderer still shades it as Basic. `MeshPhongMaterial` stays later.

`Material.isMeshPhongMaterial` has landed. Basic, Lambert, Standard, Physical, Toon, Matcap, Normal, Depth, and Distance stay false. `Material::phong` with hex `0x00FF00` stores true, type `MeshPhongMaterial`, kind `Phong`, and shading `Lambert`. The red channel is `0` and the green channel is `1`. Its defines stay empty. Copying it onto a Basic material keeps the destination false, kind `Basic`, and type `MeshBasicMaterial`, and stores red `0` with green `1`. Copying a red Distance material onto a Phong material keeps the destination true, stores red `1` and green `0`, and keeps a `FOO` define set to `1`. Cloning keeps the flag, the type, the kind, and green `1`, with a new id. The renderer still shades it as Lambert. `specular` stays later.

`Material.specular` has landed. A new Basic, Lambert, Standard, Physical, Toon, Matcap, Normal, Depth, Distance, and Phong material each store hex `0x111111`. A Phong material's `specular_color` stays hex `0xFFFFFF`. Setting the Phong specular to `(0.25, 0.5, 0.75)` leaves another Phong material at `0x111111`. Copying onto a Basic material stores those components in the destination color. Setting the destination to red leaves the source at `(0.25, 0.5, 0.75)`. The renderer still does not use this color for Phong highlights. `shininess` stays later.

`Material.shininess` has landed. A new Basic, Lambert, Standard, Physical, Toon, Matcap, Normal, Depth, Distance, and Phong material each store `30`. Setting a Phong material to `80` leaves another Phong material at `30`. Copying onto a Basic material stores `80`. Setting the destination to `10` leaves the source at `80`. The renderer still does not use this value for Phong highlights. `ShadowMaterial` stays later.

`Material.isShadowMaterial` has landed. Basic, Lambert, Standard, Physical, Toon, Matcap, Normal, Depth, Distance, and Phong stay false, and a new Basic material is opaque. `Material::shadow` stores true, type `ShadowMaterial`, kind `Shadow`, and shading `Basic`. The color is black `0x000000`, `transparent` is true, and fog is on. Copying it onto a Basic material keeps the destination false, kind `Basic`, and type `MeshBasicMaterial`, stores black, and turns transparency on. Copying a green opaque Phong material onto a Shadow material keeps the destination true, stores red `0` and green `1`, turns transparency off, and keeps a `FOO` define set to `1`. Cloning keeps the flag, the type, the kind, black, and transparency, with a new id. The renderer still shades it as Basic. `ShaderMaterial` stays later.

`Material.isShaderMaterial` has landed. Basic, Lambert, Standard, Physical, Toon, Matcap, Normal, Depth, Distance, Phong, and Shadow stay false. `Material::shader` stores true, type `ShaderMaterial`, kind `Shader`, and shading `Basic`. The color is white `0xFFFFFF`, transparency is off, fog stays on, and `defines` starts empty. Copying it onto a Basic material keeps the destination false, kind `Basic`, and type `MeshBasicMaterial`. Copying a green Phong material onto a Shader material keeps the destination true, stores red `0` and green `1`, and keeps a `FOO` define set to `1`. Cloning keeps the flag, the type, the kind, and white, with a new id. The renderer still shades it as Basic. Copying `defines` from the source, the `fog` default of false, `lights`, `clipping`, and the shader strings stay later.

`ShaderMaterial` copies `defines` from the source. A Shader material with `FOO` set to `9` and `BAZ` set to `3`, copied from a Shader material with `FOO` `1` and `BAR` `2`, stores `FOO` `1` and `BAR` `2` and drops `BAZ`. Setting the destination `FOO` to `7` leaves the source at `1`. Copying that source onto a Basic material leaves the Basic `KEEP` define at `4` and does not add `FOO`. Copying an empty Phong material onto a Shader material drops `FOO`. Cloning copies `FOO` `1` and `BAR` `2` onto a new table, and setting the clone's `FOO` to `8` leaves the source at `1`. The renderer still does not read the table. The `fog` default of false stays later.

`ShaderMaterial.fog` has landed. A new Shader material stores false. A new Basic material stays true. Copying the Shader material onto that Basic material stores false on the destination and leaves the source false. Copying a Phong material onto a Shader material stores true. Setting the destination back to false leaves the Phong source true. Cloning keeps false, with a new id. The renderer mixes scene fog only when this flag is on. `lights` stays later.

`ShaderMaterial.lights` has landed. A new Shader, Basic, and Phong material each store false. Setting the Shader material to true and copying it onto a Basic material leaves the Basic material false and the source true. Copying that Shader material onto another Shader material stores true. Setting the destination back to false leaves the source true. Copying a Phong material onto that destination stores false. Cloning the source keeps true, and setting the clone to false leaves the source true. The renderer still does not pass lighting uniforms from this flag. `clipping` stays later.

`ShaderMaterial.clipping` has landed. A new Shader, Basic, and Phong material each store false. Setting the Shader material to true and copying it onto a Basic material leaves the Basic material false and the source true. Copying that Shader material onto another Shader material stores true. Setting the destination back to false leaves the source true. Copying a Phong material onto that destination stores false. Cloning the source keeps true, and setting the clone to false leaves the source true. The renderer still does not pass clipping planes from this flag. `vertexShader` stays later.

`ShaderMaterial.vertexShader` has landed. A new Shader material stores a string that starts with a newline, then `void main()`, then a tab and `gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );`, and ends with a newline. A new Basic material and a new Phong material store `""`. Setting the Shader material to `void main() {}` and copying it onto a Basic material leaves the Basic material `""` and the source unchanged. Copying that Shader material onto another Shader material stores `void main() {}`. Setting the destination to `changed` leaves the source unchanged. Copying a Phong material onto that destination stores `""`. Cloning the source keeps `void main() {}`, and setting the clone to `clone` leaves the source unchanged. The renderer still does not compile the string. `fragmentShader` stays later.

`ShaderMaterial.fragmentShader` has landed. A new Shader material stores a string that starts with a newline, then `void main()`, then a tab and `gl_FragColor = vec4( 1.0, 0.0, 0.0, 1.0 );`, and ends with a newline. A new Basic material and a new Phong material store `""`. Setting the Shader material to `void main() {}` and copying it onto a Basic material leaves the Basic material `""` and the source unchanged. Copying that Shader material onto another Shader material stores `void main() {}`. Setting the destination to `changed` leaves the source unchanged. Copying a Phong material onto that destination stores `""`. Cloning the source keeps `void main() {}`, and setting the clone to `clone` leaves the source unchanged. The renderer still does not compile the string. `uniforms` stays later.

`ShaderMaterial.uniforms` has landed for numeric values. A new Shader, Basic, and Phong material each store an empty table. Setting the Shader material's `time` to `1` and `scale` to `2`, then copying it onto a Basic material, leaves the Basic table empty and the source `time` at `1`. Copying that Shader material onto another Shader material that had `time` `9` and `extra` `3` stores `time` `1` and `scale` `2`, and drops `extra`. Setting the destination `time` to `7` leaves the source at `1`. Copying an empty Phong material onto that destination drops `time`. Cloning the source keeps `time` `1` and `scale` `2`, and setting the clone's `time` to `8` leaves the source at `1`. The renderer still does not pass these numbers to a shader. Colors, vectors, arrays, textures, and `uniformsGroups` stay later.

`ShaderMaterial.uniformsGroups` has landed for the group name and usage. A new Shader, Basic, and Phong material each store an empty array. A group named `Frame` starts with usage `35044`. A second group named `Other` with usage `35048` is copied onto another Shader material that held a group named `Drop`. The destination then has length `2`, names `Frame` and `Other`, and usages `35044` and `35048`. Each copied group has a new id. Renaming the destination's first group to `Renamed` leaves the source named `Frame`. Copying onto a Basic material leaves that array empty. Copying an empty Phong material onto the destination makes its length `0`. Cloning keeps length `2`, name `Frame`, and usage `35048`, with a new id. Renaming the clone's first group to `Clone` leaves the source named `Frame`. The uniforms stored inside a group stay later. `linewidth` stays later.

`ShaderMaterial.linewidth` has landed. A new Shader, Basic, and Phong material each store `1`. It is separate from `wireframe_linewidth`. Setting the Shader material's linewidth to `4` and its wireframe linewidth to `5`, then copying it onto a Basic material, leaves the Basic linewidth at `1` and stores wireframe linewidth `5`. The source linewidth stays `4`. Copying that Shader material onto another Shader material whose linewidth is `3` leaves the destination at `3`. Cloning the source stores `1`, with a new id, and the source stays `4`. The renderer still draws lines one pixel wide. Shader `forceSinglePass` default true stays later.

`ShaderMaterial.forceSinglePass` has landed. A new Shader material stores true. A new Basic material and a new Phong material stay false. Copying the Shader material onto the Basic material stores true and leaves the source true. Setting the Basic material back to false leaves the source true. Copying the Phong material onto a Shader material stores false. Cloning the Shader material keeps true, with a new id. A transparent double-sided mesh still draws in one pass when this flag is on. `extensions` stays later.

`ShaderMaterial.extensions` has landed. A new Shader, Basic, and Phong material each store `clip_cull_distance` false and `multi_draw` false. Setting both switches on a Shader material and copying it onto a Basic material leaves the Basic switches false and the source true. Copying that Shader material onto another Shader material stores both true. Setting the destination `clip_cull_distance` back to false leaves the source true. Copying a Phong material onto that destination stores both false. Cloning the source keeps both true, with a new id, and setting the clone's `multi_draw` to false leaves the source true. The renderer still does not enable these WebGL extensions. `defaultAttributeValues` stays later.

`ShaderMaterial.defaultAttributeValues` has landed. A new Shader material stores `color` `[1, 1, 1]`, `uv` `[0, 0]`, and `uv1` `[0, 0]`. A new Basic material and a new Phong material store an empty table. Setting the Shader `color` to `[2, 3, 4]` and `tangent` to `[5]`, then copying onto a Basic material, leaves the Basic table empty and the source `color` at `[2, 3, 4]`. Copying onto another Shader material that had `color` `[9, 9, 9]` and `drop` `[1]` stores `color` `[2, 3, 4]`, `uv` `[0, 0]`, `uv1` `[0, 0]`, and `tangent` `[5]`, and drops `drop`. Setting the destination `color` first component to `8` leaves the source at `2`. Copying an empty Phong material onto that destination drops `color`. Cloning keeps `color` `[2, 3, 4]` and `uv` `[0, 0]`, with a new id. Setting the clone's `color` first component to `6` leaves the source at `2`. The renderer still does not fill missing vertex attributes from these numbers. `glslVersion` stays later.

`ShaderMaterial.glslVersion` has landed. A new Shader, Basic, and Phong material each store nothing. `GLSL1` codes to `100` and `GLSL3` codes to `300 es`. Setting the Shader material to `GLSL3` and copying it onto a Basic material leaves the Basic material empty and the source at `GLSL3`. Copying that Shader material onto another Shader material that was `GLSL1` stores `GLSL3`. Setting the destination back to empty leaves the source at `GLSL3`. Copying a Phong material onto that destination stores nothing. Cloning the source keeps `GLSL3`, with a new id, and setting the clone to `GLSL1` leaves the source at `GLSL3`. The renderer still does not write a `#version` line from this field. `index0AttributeName` stays later.

`ShaderMaterial.index0AttributeName` has landed. A new Shader, Basic, and Phong material each store nothing. Setting the Shader material to `position` and copying it onto a Basic material leaves the Basic material empty and the source at `position`. Copying that Shader material onto another Shader material that was `normal` stores `position`. Setting the destination to `changed` leaves the source at `position`. Copying a Phong material onto that destination stores nothing. Cloning the source keeps `position`, with a new id, and setting the clone to `uv` leaves the source at `position`. The renderer still does not call `bindAttribLocation`. `uniformsNeedUpdate` stays later.

`ShaderMaterial.uniformsNeedUpdate` has landed. A new Shader, Basic, and Phong material each store false. Setting the Shader material to true and copying it onto a Basic material leaves the Basic material false and the source true. Copying that Shader material onto another Shader material stores true. Setting the destination back to false leaves the source true. Copying a Phong material onto that destination stores false. Cloning the source keeps true, with a new id, and setting the clone to false leaves the source true. The renderer still does not force a uniform upload from this flag. The uniforms stored inside a `UniformsGroup` stay later.

`UniformsGroup.uniforms` has landed for numeric values. A new group stores an empty array. Pushing `1` and `2` onto a group named `Frame`, then copying that Shader material onto another Shader material, stores `[1, 2]` on the destination. The copied group has a new id. Setting the destination's first number to `9` leaves the source at `1`. Cloning keeps `[1, 2]`, and setting the clone's first number to `8` leaves the source at `1`. Colors, vectors, arrays, and textures inside a group stay later. `UniformsGroup.add` stays later.

`UniformsGroup.add` has landed for a number. Adding `1` and then `2` stores `[1, 2]`. The chained result is the same group, with the same id. Copying that group onto another Shader material and then adding `4` on the source stores `[1, 2, 4]` on the source and leaves the destination at `[1, 2]`. Colors, vectors, arrays, and textures still cannot be added. `UniformsGroup.remove` stays later.

`UniformsGroup.remove` has landed for a number. A group holding `[1, 2, 1]` loses the first `1` and keeps `[2, 1]`. The chained result is the same group, with the same id. Removing `9` leaves `[2, 1]`. Copying that group onto another Shader material and then removing `2` from the source stores `[1]` on the source and leaves the destination at `[2, 1]`. `UniformsGroup.setName` stays later.

`UniformsGroup.setName` has landed. A new group starts with an empty name. Setting the name to `Frame` and then `Lights` stores `Lights`. The chained result is the same group, with the same id. Copying that group onto another Shader material and then setting the source name to `Renamed` leaves the destination named `Lights`. `UniformsGroup.setUsage` stays later.

`UniformsGroup.setUsage` has landed. A new group stores usage `35044`. Setting it to `35048` stores `35048`. The chained result is the same group, with the same id. Copying that group onto another Shader material and then setting the source usage back to `35044` leaves the destination at `35048`. `UniformsGroup.dispose` stays later.

`UniformsGroup.dispose` has landed. A listener registered twice for `dispose` runs once, so the hit count is `1`. A `change` listener does not run. Calling `dispose` again makes the count `2`. Copying the group onto another Shader material gives that group an empty listener table. Disposing the destination leaves the count at `2`. Disposing the source makes the count `3`. The renderer still does not free a GPU buffer from this call. `UniformsGroup.hasEventListener` stays later.

`UniformsGroup.hasEventListener` has landed. Before registration a group reports false for a `dispose` listener. After `addEventListener`, that same listener reports true. A different function and the event name `change` stay false. Another new group also reports false. Copying the group onto another Shader material leaves the destination false and the source true. `UniformsGroup.removeEventListener` stays later.

`UniformsGroup.removeEventListener` has landed. After removing the registered `dispose` listener, `hasEventListener` is false and `dispose` leaves the hit count at `0`. Removing that listener from `change`, or removing a different function from `dispose`, leaves it registered, so the next `dispose` makes the count `1`. Removing it again and calling `dispose` leaves the count at `1`. `UniformsGroup.dispatchEvent` stays later.

`UniformsGroup.dispatchEvent` has landed. A `change` listener adds `1` and a `dispose` listener adds `10`. Dispatching `change` makes the count `1`. Dispatching a missing name leaves it at `1`. Dispatching `dispose` makes it `11`. Dispatching `change` on another group leaves it at `11`. `UniformsGroup.clone` stays later.

`UniformsGroup.clone` has landed. A group named `Frame` with usage `35048` and numbers `[1, 2]` clones to the same name, usage, and numbers. The clone has a new id and an empty listener table. Setting the clone's first number to `9` and its name to `Other` leaves the source at `1` and `Frame`. `UniformsGroup.copy` stays later.

`UniformsGroup.copy` has landed. A group named `Other` with number `[9]` copies a group named `Frame`, usage `35048`, and numbers `[1, 2]`. The destination keeps its id and its `change` listener. The source `dispose` listener stays off the destination. The destination's original number array becomes `[1, 2]`. Setting the destination's first number to `8` and its name to `Renamed` leaves the source at `1` and `Frame`. `RawShaderMaterial` stays later.

`RawShaderMaterial` has landed. `Material::raw` sets `is_shader_material` and `is_raw_shader_material` true, `type_name` to `RawShaderMaterial`, and shading stays Basic. `linewidth` stays `1`. `Material::shader` keeps `is_raw_shader_material` false and `type_name` `ShaderMaterial`. Copying a raw material with `lights` set true onto a shader leaves the destination flag false and stores `lights` true. Copying a shader with `lights` false onto that raw material leaves `is_raw_shader_material` true and stores `lights` false. A clone keeps the raw flag, define `FOO` = `1`, and a different id. The built-in uniform and attribute prefix stays later.

## Checklist

| status | phase | item | packages |
|---|---|---|---|
| planned | 2–6 | Material and MeshBasicMaterial from `src/materials`, then Lambert and Standard | `materials` |
| planned | 7 | `depthWrite` on meshes, points, and lines | `materials`, `renderer` |
| planned | 7 | `depthTest` on meshes, points, and lines | `materials`, `renderer` |
| planned | 7 | `colorWrite` on meshes, points, and lines | `materials`, `renderer` |
| planned | 7 | `premultipliedAlpha` on meshes, points, and lines | `materials`, `renderer` |
| planned | 7 | `SpriteMaterial` color, map, and transparency | `materials` |
| planned | 7 | `SpriteMaterial` alpha map and fog | `materials` |
| planned | 7 | `SpriteMaterial.copy` | `materials` |
| planned | 7 | `PointsMaterial.map` | `materials` |
| planned | 7 | `PointsMaterial.alphaMap` | `materials` |
| planned | 7 | `PointsMaterial.copy` | `materials` |
| planned | 7 | `LineBasicMaterial.map` | `materials` |
| planned | 7 | `LineBasicMaterial.copy` | `materials` |
| planned | 7 | `SpriteMaterial` depth and visibility | `materials` |
| planned | 7 | `PointsMaterial.alphaTest` | `materials` |
| planned | 7 | `LineBasicMaterial.alphaTest` | `materials` |
| planned | 7 | `SpriteMaterial.alphaTest` | `materials` |
| planned | 7 | `LineDashedMaterial` scale, dash size, and gap size | `materials` |
| planned | 7 | `LineDashedMaterial.keepsDistance` | `materials` |
| planned | 7 | `Material.vertexColors` | `materials` |
| planned | 7 | `PointsMaterial.vertexColors` | `materials` |
| planned | 7 | `LineBasicMaterial.vertexColors` | `materials` |
| planned | 7 | `SpriteMaterial.vertexColors` | `materials` |
| planned | 7 | `Material.toneMapped` | `materials` |
| planned | 7 | `PointsMaterial.toneMapped` | `materials` |
| planned | 7 | `LineBasicMaterial.toneMapped` | `materials` |
| planned | 7 | `SpriteMaterial.toneMapped` | `materials` |
| planned | 7 | `Material.alphaHash` | `materials` |
| planned | 7 | `PointsMaterial.alphaHash` | `materials` |
| planned | 7 | `LineBasicMaterial.alphaHash` | `materials` |
| planned | 7 | `SpriteMaterial.alphaHash` | `materials` |
| planned | 7 | `Material.alphaToCoverage` | `materials` |
| planned | 7 | `PointsMaterial.alphaToCoverage` | `materials` |
| planned | 7 | `LineBasicMaterial.alphaToCoverage` | `materials` |
| planned | 7 | `SpriteMaterial.alphaToCoverage` | `materials` |
| planned | 7 | `Material.dithering` | `materials` |
| planned | 7 | `PointsMaterial.dithering` | `materials` |
| planned | 7 | `LineBasicMaterial.dithering` | `materials` |
| planned | 7 | `SpriteMaterial.dithering` | `materials` |
| planned | 7 | `Material.polygonOffset` | `materials` |
| planned | 7 | `PointsMaterial.polygonOffset` | `materials` |
| planned | 7 | `LineBasicMaterial.polygonOffset` | `materials` |
| planned | 7 | `SpriteMaterial.polygonOffset` | `materials` |
| planned | 7 | `Material.clipShadows` | `materials` |
| planned | 7 | `PointsMaterial.clipShadows` | `materials` |
| planned | 7 | `LineBasicMaterial.clipShadows` | `materials` |
| planned | 7 | `SpriteMaterial.clipShadows` | `materials` |
| planned | 7 | `Material.clipIntersection` | `materials` |
| planned | 7 | `PointsMaterial.clipIntersection` | `materials` |
| planned | 7 | `LineBasicMaterial.clipIntersection` | `materials` |
| planned | 7 | `SpriteMaterial.clipIntersection` | `materials` |
| planned | 7 | `Material.allowOverride` | `materials` |
| planned | 7 | `PointsMaterial.allowOverride` | `materials` |
| planned | 7 | `LineBasicMaterial.allowOverride` | `materials` |
| planned | 7 | `SpriteMaterial.allowOverride` | `materials` |
| planned | 7 | `Material.blendAlpha` | `materials` |
| planned | 7 | `PointsMaterial.blendAlpha` | `materials` |
| planned | 7 | `LineBasicMaterial.blendAlpha` | `materials` |
| planned | 7 | `SpriteMaterial.blendAlpha` | `materials` |
| planned | 7 | `Material.blendColor` | `materials` |
| planned | 7 | `PointsMaterial.blendColor` | `materials` |
| planned | 7 | `LineBasicMaterial.blendColor` | `materials` |
| planned | 7 | `SpriteMaterial.blendColor` | `materials` |
| planned | 7 | `Material.blending` | `materials` |
| planned | 7 | `PointsMaterial.blending` | `materials` |
| planned | 7 | `LineBasicMaterial.blending` | `materials` |
| planned | 7 | `SpriteMaterial.blending` | `materials` |
| planned | 7 | `Material.blendSrc` | `materials` |
| planned | 7 | `PointsMaterial.blendSrc` | `materials` |
| planned | 7 | `LineBasicMaterial.blendSrc` | `materials` |
| planned | 7 | `SpriteMaterial.blendSrc` | `materials` |
| planned | 7 | `Material.blendDst` | `materials` |
| planned | 7 | `PointsMaterial.blendDst` | `materials` |
| planned | 7 | `LineBasicMaterial.blendDst` | `materials` |
| planned | 7 | `SpriteMaterial.blendDst` | `materials` |
| planned | 7 | `Material.blendEquation` | `materials` |
| planned | 7 | `PointsMaterial.blendEquation` | `materials` |
| planned | 7 | `LineBasicMaterial.blendEquation` | `materials` |
| planned | 7 | `SpriteMaterial.blendEquation` | `materials` |
| planned | 7 | `Material.blendSrcAlpha` | `materials` |
| planned | 7 | `PointsMaterial.blendSrcAlpha` | `materials` |
| planned | 7 | `LineBasicMaterial.blendSrcAlpha` | `materials` |
| planned | 7 | `SpriteMaterial.blendSrcAlpha` | `materials` |
| planned | 7 | `Material.blendDstAlpha` | `materials` |
| planned | 7 | `PointsMaterial.blendDstAlpha` | `materials` |
| planned | 7 | `LineBasicMaterial.blendDstAlpha` | `materials` |
| planned | 7 | `SpriteMaterial.blendDstAlpha` | `materials` |
| planned | 7 | `Material.blendEquationAlpha` | `materials` |
| planned | 7 | `PointsMaterial.blendEquationAlpha` | `materials` |
| planned | 7 | `LineBasicMaterial.blendEquationAlpha` | `materials` |
| planned | 7 | `SpriteMaterial.blendEquationAlpha` | `materials` |
| planned | 7 | `Material.stencilWriteMask` | `materials` |
| planned | 7 | `PointsMaterial.stencilWriteMask` | `materials` |
| planned | 7 | `LineBasicMaterial.stencilWriteMask` | `materials` |
| planned | 7 | `SpriteMaterial.stencilWriteMask` | `materials` |
| planned | 7 | `Material.stencilFunc` | `materials` |
| planned | 7 | `PointsMaterial.stencilFunc` | `materials` |
| planned | 7 | `LineBasicMaterial.stencilFunc` | `materials` |
| planned | 7 | `SpriteMaterial.stencilFunc` | `materials` |
| planned | 7 | `Material.stencilRef` | `materials` |
| planned | 7 | `PointsMaterial.stencilRef` | `materials` |
| planned | 7 | `LineBasicMaterial.stencilRef` | `materials` |
| planned | 7 | `SpriteMaterial.stencilRef` | `materials` |
| planned | 7 | `Material.stencilFuncMask` | `materials` |
| planned | 7 | `PointsMaterial.stencilFuncMask` | `materials` |
| planned | 7 | `LineBasicMaterial.stencilFuncMask` | `materials` |
| planned | 7 | `SpriteMaterial.stencilFuncMask` | `materials` |
| planned | 7 | `Material.stencilFail` | `materials` |
| planned | 7 | `PointsMaterial.stencilFail` | `materials` |
| planned | 7 | `LineBasicMaterial.stencilFail` | `materials` |
| planned | 7 | `SpriteMaterial.stencilFail` | `materials` |
| planned | 7 | `Material.stencilZFail` | `materials` |
| planned | 7 | `PointsMaterial.stencilZFail` | `materials` |
| planned | 7 | `LineBasicMaterial.stencilZFail` | `materials` |
| planned | 7 | `SpriteMaterial.stencilZFail` | `materials` |
| planned | 7 | `Material.stencilZPass` | `materials` |
| planned | 7 | `PointsMaterial.stencilZPass` | `materials` |
| planned | 7 | `LineBasicMaterial.stencilZPass` | `materials` |
| planned | 7 | `SpriteMaterial.stencilZPass` | `materials` |
| planned | 7 | `Material.stencilWrite` | `materials` |
| planned | 7 | `PointsMaterial.stencilWrite` | `materials` |
| planned | 7 | `LineBasicMaterial.stencilWrite` | `materials` |
| planned | 7 | `SpriteMaterial.stencilWrite` | `materials` |
| planned | 7 | `Material.clippingPlanes` | `materials` |
| planned | 7 | `PointsMaterial.clippingPlanes` | `materials` |
| planned | 7 | `LineBasicMaterial.clippingPlanes` | `materials` |
| planned | 7 | `SpriteMaterial.clippingPlanes` | `materials` |
| planned | 7 | `Material.precision` | `materials` |
| planned | 7 | `PointsMaterial.precision` | `materials` |
| planned | 7 | `LineBasicMaterial.precision` | `materials` |
| planned | 7 | `SpriteMaterial.precision` | `materials` |
| planned | 7 | `Material.userData` | `materials` |
| planned | 7 | `PointsMaterial.userData` | `materials` |
| planned | 7 | `LineBasicMaterial.userData` | `materials` |
| planned | 7 | `SpriteMaterial.userData` | `materials` |
| planned | 7 | `Material.version` | `materials` |
| planned | 7 | `PointsMaterial.version` | `materials` |
| planned | 7 | `LineBasicMaterial.version` | `materials` |
| planned | 7 | `SpriteMaterial.version` | `materials` |
| planned | 7 | `Material.needsUpdate` | `materials` |
| planned | 7 | `PointsMaterial.needsUpdate` | `materials` |
| planned | 7 | `LineBasicMaterial.needsUpdate` | `materials` |
| planned | 7 | `SpriteMaterial.needsUpdate` | `materials` |
| planned | 7 | `Material.setAlphaTest` | `materials` |
| planned | 7 | `PointsMaterial.setAlphaTest` | `materials` |
| planned | 7 | `LineBasicMaterial.setAlphaTest` | `materials` |
| planned | 7 | `SpriteMaterial.setAlphaTest` | `materials` |
| planned | 7 | `Material.id` | `materials` |
| planned | 7 | `PointsMaterial.id` | `materials` |
| planned | 7 | `LineBasicMaterial.id` | `materials` |
| planned | 7 | `SpriteMaterial.id` | `materials` |
| planned | 7 | `Material.uuid` | `materials` |
| planned | 7 | `PointsMaterial.uuid` | `materials` |
| planned | 7 | `LineBasicMaterial.uuid` | `materials` |
| planned | 7 | `SpriteMaterial.uuid` | `materials` |
| planned | 7 | `Material.name` | `materials` |
| planned | 7 | `PointsMaterial.name` | `materials` |
| planned | 7 | `LineBasicMaterial.name` | `materials` |
| planned | 7 | `SpriteMaterial.name` | `materials` |
| planned | 7 | `Material.type` | `materials` |
| planned | 7 | `PointsMaterial.type` | `materials` |
| planned | 7 | `LineBasicMaterial.type` | `materials` |
| planned | 7 | `SpriteMaterial.type` | `materials` |
| planned | 7 | `LineDashedMaterial.type` | `materials` |
| planned | 7 | `Material.copy` | `materials` |
| planned | 7 | `Material.clone` | `materials` |
| planned | 7 | `PointsMaterial.clone` | `materials` |
| planned | 7 | `LineBasicMaterial.clone` | `materials` |
| planned | 7 | `SpriteMaterial.clone` | `materials` |
| planned | 7 | `LineDashedMaterial.clone` | `materials` |
| planned | 7 | `Material.addEventListener` | `materials` |
| planned | 7 | `PointsMaterial.addEventListener` | `materials` |
| planned | 7 | `LineBasicMaterial.addEventListener` | `materials` |
| planned | 7 | `SpriteMaterial.addEventListener` | `materials` |
| planned | 7 | `Material.hasEventListener` | `materials` |
| planned | 7 | `PointsMaterial.hasEventListener` | `materials` |
| planned | 7 | `LineBasicMaterial.hasEventListener` | `materials` |
| planned | 7 | `SpriteMaterial.hasEventListener` | `materials` |
| planned | 7 | `Material.removeEventListener` | `materials` |
| planned | 7 | `PointsMaterial.removeEventListener` | `materials` |
| planned | 7 | `LineBasicMaterial.removeEventListener` | `materials` |
| planned | 7 | `SpriteMaterial.removeEventListener` | `materials` |
| planned | 7 | `Material.dispatchEvent` | `materials` |
| planned | 7 | `PointsMaterial.dispatchEvent` | `materials` |
| planned | 7 | `LineBasicMaterial.dispatchEvent` | `materials` |
| planned | 7 | `SpriteMaterial.dispatchEvent` | `materials` |
| planned | 7 | `Material.dispose` | `materials` |
| planned | 7 | `PointsMaterial.dispose` | `materials` |
| planned | 7 | `LineBasicMaterial.dispose` | `materials` |
| planned | 7 | `SpriteMaterial.dispose` | `materials` |
| planned | 7 | `LineDashedMaterial.dispose` | `materials` |
| planned | 7 | `Material.normalMap` | `materials` |
| planned | 7 | `Material.normalScale` | `materials` |
| planned | 7 | `Material.displacementMap` | `materials` |
| planned | 7 | `Material.displacementScale` | `materials` |
| planned | 7 | `Material.displacementBias` | `materials` |
| planned | 7 | `Material.specularMap` | `materials` |
| planned | 7 | `Material.envMap` | `materials` |
| planned | 7 | `Material.envMapRotation` | `materials` |
| planned | 7 | `Material.reflectivity` | `materials` |
| planned | 7 | `Material.envMapIntensity` | `materials` |
| planned | 7 | `Material.refractionRatio` | `materials` |
| planned | 7 | `Material.lightMap` | `materials` |
| planned | 7 | `Material.lightMapIntensity` | `materials` |
| planned | 7 | `Material.aoMap` | `materials` |
| planned | 7 | `Material.aoMapIntensity` | `materials` |
| planned | 7 | `Material.bumpMap` | `materials` |
| planned | 7 | `Material.bumpScale` | `materials` |
| planned | 7 | `Material.wireframeLinewidth` | `materials` |
| planned | 7 | `Material.wireframeLinecap` | `materials` |
| planned | 7 | `Material.wireframeLinejoin` | `materials` |
| planned | 7 | `Material.defines` | `materials` |
| planned | 7 | `PointsMaterial.side` | `materials` |
| planned | 7 | `LineBasicMaterial.side` | `materials` |
| planned | 7 | `SpriteMaterial.side` | `materials` |
| planned | 7 | `PointsMaterial.shadowSide` | `materials` |
| planned | 7 | `LineBasicMaterial.shadowSide` | `materials` |
| planned | 7 | `SpriteMaterial.shadowSide` | `materials` |
| planned | 7 | `PointsMaterial.forceSinglePass` | `materials` |
| planned | 7 | `LineBasicMaterial.forceSinglePass` | `materials` |
| planned | 7 | `SpriteMaterial.forceSinglePass` | `materials` |
| planned | 7 | `Material.anisotropyRotation` | `materials` |
| planned | 7 | `Material.anisotropyMap` | `materials` |
| planned | 7 | `Material.clearcoatMap` | `materials` |
| planned | 7 | `Material.clearcoatRoughness` | `materials` |
| planned | 7 | `Material.clearcoatRoughnessMap` | `materials` |
| planned | 7 | `Material.clearcoatNormalScale` | `materials` |
| planned | 7 | `Material.clearcoatNormalMap` | `materials` |
| planned | 7 | `Material.ior` | `materials` |
| planned | 7 | `Material.iridescenceMap` | `materials` |
| planned | 7 | `Material.iridescenceIOR` | `materials` |
| planned | 7 | `Material.iridescenceThicknessRange` | `materials` |
| planned | 7 | `Material.iridescenceThicknessMap` | `materials` |
| planned | 7 | `Material.sheenColor` | `materials` |
| planned | 7 | `Material.sheenColorMap` | `materials` |
| planned | 7 | `Material.sheenRoughness` | `materials` |
| planned | 7 | `Material.sheenRoughnessMap` | `materials` |
| planned | 7 | `Material.transmissionMap` | `materials` |
| planned | 7 | `Material.thickness` | `materials` |
| planned | 7 | `Material.thicknessMap` | `materials` |
| planned | 7 | `Material.attenuationDistance` | `materials` |
| planned | 7 | `Material.attenuationColor` | `materials` |
| planned | 7 | `Material.specularIntensity` | `materials` |
| planned | 7 | `Material.specularIntensityMap` | `materials` |
| planned | 7 | `Material.specularColor` | `materials` |
| planned | 7 | `Material.specularColorMap` | `materials` |
| planned | 7 | `Material.anisotropy` | `materials` |
| planned | 7 | `Material.clearcoat` | `materials` |
| planned | 7 | `Material.iridescence` | `materials` |
| planned | 7 | `Material.dispersion` | `materials` |
| planned | 7 | `Material.retroreflectivity` | `materials` |
| planned | 7 | `Material.sheen` | `materials` |
| planned | 7 | `Material.transmission` | `materials` |
| planned | 7 | `Material.isMeshPhysicalMaterial` | `materials` |
| planned | 7 | `Material.isMeshToonMaterial` | `materials` |
| planned | 7 | `Material.gradientMap` | `materials` |
| planned | 7 | `Material.matcap` | `materials` |
| planned | 7 | `Material.isMeshMatcapMaterial` | `materials` |
| planned | 7 | `Material.isMeshNormalMaterial` | `materials` |
| planned | 7 | `Material.isMeshDepthMaterial` | `materials` |
| planned | 7 | `Material.depthPacking` | `materials` |
| planned | 7 | `Material.isMeshDistanceMaterial` | `materials` |
| planned | 7 | `Material.isMeshPhongMaterial` | `materials` |
| planned | 7 | `Material.specular` | `materials` |
| planned | 7 | `Material.shininess` | `materials` |
| planned | 7 | `Material.isShadowMaterial` | `materials` |
| planned | 7 | `Material.isShaderMaterial` | `materials` |
| planned | 7 | `ShaderMaterial` defines copy | `materials` |
| planned | 7 | `ShaderMaterial.fog` | `materials` |
| planned | 7 | `ShaderMaterial.lights` | `materials` |
| planned | 7 | `ShaderMaterial.clipping` | `materials` |
| planned | 7 | `ShaderMaterial.vertexShader` | `materials` |
| planned | 7 | `ShaderMaterial.fragmentShader` | `materials` |
| planned | 7 | `ShaderMaterial.uniforms` | `materials` |
| planned | 7 | `ShaderMaterial.uniformsGroups` | `materials` |
| planned | 7 | `ShaderMaterial.linewidth` | `materials` |
| planned | 7 | `ShaderMaterial.forceSinglePass` | `materials` |
| planned | 7 | `ShaderMaterial.extensions` | `materials` |
| planned | 7 | `ShaderMaterial.defaultAttributeValues` | `materials` |
| planned | 7 | `ShaderMaterial.glslVersion` | `materials` |
| planned | 7 | `ShaderMaterial.index0AttributeName` | `materials` |
| planned | 7 | `ShaderMaterial.uniformsNeedUpdate` | `materials` |
| planned | 7 | `UniformsGroup.uniforms` | `materials` |
| planned | 7 | `UniformsGroup.add` | `materials` |
| planned | 7 | `UniformsGroup.remove` | `materials` |
| planned | 7 | `UniformsGroup.setName` | `materials` |
| planned | 7 | `UniformsGroup.setUsage` | `materials` |
| planned | 7 | `UniformsGroup.dispose` | `materials` |
| planned | 7 | `UniformsGroup.hasEventListener` | `materials` |
| planned | 7 | `UniformsGroup.removeEventListener` | `materials` |
| planned | 7 | `UniformsGroup.dispatchEvent` | `materials` |
| planned | 7 | `UniformsGroup.clone` | `materials` |
| planned | 7 | `UniformsGroup.copy` | `materials` |
| planned | 7 | `RawShaderMaterial` | `materials` |
| planned | 7 | material `visible` on meshes, points, and lines | `materials`, `renderer` |
| planned | 7 | `forceSinglePass` on transparent double-sided meshes | `materials`, `renderer` |
| planned | 7 | `shadowSide` on shadow casters | `materials`, `renderer` |
| planned | 7 | emissive maps on Lambert and Standard | `materials`, `renderer` |
| planned | 7 | roughness maps on Standard | `materials`, `nodes`, `renderer` |
| planned | 7 | metalness maps on Standard | `materials`, `nodes`, `renderer` |
| planned | 7 | alpha maps on Basic, Lambert, and Standard | `materials`, `nodes`, `renderer` |
| planned | 7 | flat shading on Lambert and Standard | `materials`, `nodes`, `renderer` |
| planned | 7 | alpha test and glTF masked materials | `materials`, `renderer`, `gltf` |
| planned | 7 | emissive color on Lambert and Standard, including glTF emissiveFactor | `materials`, `renderer`, `gltf` |
| planned | 7 | emissive intensity, including glTF KHR_materials_emissive_strength | `materials`, `renderer`, `gltf` |
