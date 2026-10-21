# materials

Active. This is the `WebGLPrograms` prefix and `getParameters` port. Each note below has landed as its own prefix line or `Material::program_*` reader. Those readers are not wired into the prefixes, and the renderer does not compile the strings. The next slice is named at the end of the last behavior paragraph.

## Behavior

`ShaderMaterial` vertex prefix has landed. `prefixed_vertex_shader` on a Shader material is `833` characters longer than `vertex_shader` and `925` characters with the default body. It starts with `uniform mat4 modelMatrix;` and has `attribute vec3 position;` at index `392`. A raw material stays at the default `92` characters and still starts with a newline. Setting both bodies to `void main() {}` makes the Shader string `847` characters and the raw string `14`. A Basic material stays `""`. The fragment prefix stays later.

`ShaderMaterial` fragment prefix has landed. `prefixed_fragment_shader` on a Shader material is `82` characters longer than `fragment_shader` and `143` characters with the default body. It starts with `uniform mat4 viewMatrix;` and `uniform bool isOrthographic;` occupies index `54` through `82`. A raw material stays at the default `61` characters. Setting both bodies to `void main() {}` makes the Shader string `96` characters and the raw string `14`. A Basic material stays `""`. The GLSL3 fragment defines stay later.

`ShaderMaterial` GLSL3 fragment defines have landed. With `glsl_version` empty, `prefixed_fragment_shader` is `546` characters longer than the fragment shader and `607` with the default body. It starts with `#define varying in`, and `uniform mat4 viewMatrix;` is at index `464`. `GLSL1` keeps length `607`. `GLSL3` drops `layout(location = 0)` and `#define gl_FragColor pc_fragColor`, so the default string is `525` and the difference is `82`. A raw material set to `GLSL3` stays at `61`. A Basic material stays `""`. The `#version 300 es` line stays later.

Shader `#version 300 es` has landed. `prefixed_vertex_shader` and `prefixed_fragment_shader` on a Shader material both start with those 16 characters. The default vertex string is `941` and the default fragment string is `623`. `GLSL3` still starts with `#version 300 es` and keeps the fragment string at `541`, which is `82` shorter than `623`. A raw material stays at `92` vertex characters and `61` fragment characters, with no version line. A Basic material stays `""`. Vertex GLSL3 defines stay later.

Shader vertex GLSL3 defines have landed. With both extension flags off, `prefixed_vertex_shader` is `917` characters longer than `vertex_shader` and `1009` with the default body. Index `17` is `#define attribute in`. Turning on `clip_cull_distance` makes the string `1057`, which is `48` longer. `multi_draw` alone makes it `1049`, which is `40` longer. Both flags make it `1098`, which is `89` longer. A raw material with both flags stays at `92`. Precision and `SHADER_TYPE` stay later.

Shader precision prefix has landed. An empty `precision` writes 17 `precision highp` lines and `#define HIGH_PRECISION`, `543` characters, on both prefixed shaders. The default vertex string is `1552` and the default fragment string is `1166`. `mediump` adds `36`, so those lengths become `1588` and `1202`. `lowp` subtracts `18`, so they become `1534` and `1148`. A raw material set to `lowp` stays at `92` and `61`. `SHADER_TYPE` stays later.

`SHADER_TYPE` has landed. A Shader material writes `#define SHADER_TYPE ShaderMaterial` after the precision block. That line is `35` characters with the newline. The default vertex string is `1587` and the default fragment string is `1201`. `mediump` still adds `36`, so those lengths are `1623` and `1237`. `lowp` still subtracts `18`, so they are `1569` and `1183`. A raw material stays at `92` and `61`. `SHADER_NAME` stays later.

`SHADER_NAME` has landed. An empty name writes `#define SHADER_NAME ` and a newline, `21` characters, on both prefixed shaders. The default vertex string is `1608` and the default fragment string is `1222`. Naming the material `Cube` adds `4`, so those lengths become `1612` and `1226`. A raw material named `Cube` stays at `92` and `61`. Custom defines stay later.

Custom defines have landed. An empty `defines` table adds nothing, so the default vertex string stays `1608` and the default fragment string stays `1222`. Setting `FOO` to `1` adds `#define FOO 1` and a newline, `14` characters, so those lengths become `1622` and `1236`. A raw material with `FOO` stays at `92` and `61`. A Basic material stays `""`. Feature defines such as `USE_MAP` stay later.

`USE_MAP` has landed. A Shader material with a 1×1 color map writes `#define USE_MAP` and a newline, `16` characters, on both prefixed shaders. The vertex string grows from `1608` to `1624`, and the fragment string from `1222` to `1238`. Adding `FOO` = `1` as well adds another `14`, so the vertex string is `1638` and `USE_MAP` follows that define. A raw material with the same map stays at `92`. A Basic material stays `""`. `USE_ENVMAP` stays later.

`USE_ENVMAP` has landed. A Shader material with a 1×1 env map writes `#define USE_ENVMAP` and a newline, `19` characters, on both prefixed shaders. The vertex string grows from `1608` to `1627`, and the fragment string from `1222` to `1241`. A color map as well adds the earlier `16`, so the vertex string is `1643` and `USE_ENVMAP` follows `USE_MAP`. A raw material with the same env map stays at `92`. A Basic material stays `""`. `ENVMAP_MODE` stays later.

`ENVMAP_MODE` has landed. A Shader material with a 1×1 env map writes `#define ENVMAP_MODE_REFLECTION` and a newline, `31` characters, after `USE_ENVMAP` on both prefixed shaders. The vertex string grows from `1608` to `1658`, and the fragment string from `1222` to `1272`. A color map as well adds the earlier `16`, so the vertex string is `1674` and the mode line follows `USE_MAP`. Textures have no mapping, so refraction is not written. A raw material with the same env map stays at `92`. A Basic material stays `""`. Fragment `ENVMAP_TYPE` stays later.

`ENVMAP_TYPE` has landed. A Shader material with a 1×1 env map writes `#define ENVMAP_TYPE_CUBE` and a newline, `25` characters, on the fragment prefix only, between `USE_ENVMAP` and `ENVMAP_MODE`. The fragment string grows from `1272` to `1297`. The vertex string stays `1658` and still has `ENVMAP_MODE_REFLECTION` where the fragment now has the type line. Textures have no mapping, so the type stays cube. A raw material stays at `61` fragment characters. A Basic material stays `""`. `ENVMAP_BLENDING` stays later.

`ENVMAP_BLENDING` has landed. A Shader material with a 1×1 env map and the default multiply combine writes `#define ENVMAP_BLENDING_MULTIPLY` and a newline, `33` characters, on the fragment prefix after `ENVMAP_MODE`. The fragment string grows from `1297` to `1330`. The vertex string stays `1658`. Mix writes `ENVMAP_BLENDING_MIX` and Add writes `ENVMAP_BLENDING_ADD`, each `28` characters, so the fragment string is `1325`. Mix without an env map stays at `1222`. A raw material stays at `61`. A Basic material stays `""`. `USE_LIGHTMAP` stays later.

`USE_LIGHTMAP` has landed. A Shader material with a 1×1 light map writes `#define USE_LIGHTMAP` and a newline, `21` characters, on both prefixed shaders. The vertex string grows from `1608` to `1629`, and the fragment string from `1222` to `1243`. An env map as well puts that line after the env-map defines, so the vertex string is `1679` and the fragment string is `1351`. A raw material stays at `92`. A Basic material stays `""`. `USE_AOMAP` stays later.

`USE_AOMAP` has landed. A Shader material with a 1×1 ambient-occlusion map writes `#define USE_AOMAP` and a newline, `18` characters, on both prefixed shaders. The vertex string grows from `1608` to `1626`, and the fragment string from `1222` to `1240`. A light map as well puts that line after `USE_LIGHTMAP`, so the vertex string is `1647` and the fragment string is `1261`. A raw material stays at `92`. A Basic material stays `""`. `USE_BUMPMAP` stays later.

`USE_BUMPMAP` has landed. A Shader material with a 1×1 bump map writes `#define USE_BUMPMAP` and a newline, `20` characters, on both prefixed shaders. The vertex string grows from `1608` to `1628`, and the fragment string from `1222` to `1242`. An ambient-occlusion map as well puts that line after `USE_AOMAP`, so the vertex string is `1646` and the fragment string is `1260`. A raw material stays at `92`. A Basic material stays `""`. `USE_NORMALMAP` stays later.

`USE_NORMALMAP` has landed. A Shader material with a 1×1 normal map writes `#define USE_NORMALMAP` and a newline, `22` characters, on both prefixed shaders. The vertex string grows from `1608` to `1630`, and the fragment string from `1222` to `1244`. A bump map as well puts that line after `USE_BUMPMAP`, so the vertex string is `1650` and the fragment string is `1264`. The tangent-space and object-space lines are not written yet. A raw material stays at `92`. A Basic material stays `""`. `USE_NORMALMAP_TANGENTSPACE` stays later.

`USE_NORMALMAP_TANGENTSPACE` has landed. A Shader material with a 1×1 normal map and the default tangent-space type writes `#define USE_NORMALMAP_TANGENTSPACE` and a newline, `35` characters, after `USE_NORMALMAP` on both prefixed shaders. The vertex string grows from `1630` to `1665`, and the fragment string from `1244` to `1279`. Object space writes neither that line, so those lengths stay `1630` and `1244`. A raw material stays at `92`. A Basic material stays `""`. `USE_NORMALMAP_OBJECTSPACE` stays later.

`USE_NORMALMAP_OBJECTSPACE` has landed. A Shader material with a 1×1 normal map and object-space type writes `#define USE_NORMALMAP_OBJECTSPACE` and a newline, `34` characters, after `USE_NORMALMAP` and instead of the tangent-space line. The vertex string grows from `1630` to `1664`, and the fragment string from `1244` to `1278`. Switching back to tangent space writes `USE_NORMALMAP_TANGENTSPACE` at the same index. A raw material stays at `92`. A Basic material stays `""`. `USE_DISPLACEMENTMAP` stays later.

`USE_DISPLACEMENTMAP` has landed. A Shader material with a 1×1 displacement map writes `#define USE_DISPLACEMENTMAP` and a newline, `28` characters, on the vertex prefix only. The vertex string grows from `1608` to `1636`. The fragment string stays `1222`. A tangent-space normal map as well puts that line after `USE_NORMALMAP_TANGENTSPACE`, so the vertex string is `1693` and the fragment string stays `1279`. A raw material stays at `92`. A Basic material stays `""`. `USE_EMISSIVEMAP` stays later.

`USE_EMISSIVEMAP` has landed. A Shader material with a 1×1 emissive map writes `#define USE_EMISSIVEMAP` and a newline, `24` characters, on both prefixed shaders. The vertex string grows from `1608` to `1632`, and the fragment string from `1222` to `1246`. A displacement map as well puts that line after `USE_DISPLACEMENTMAP` on the vertex string, which becomes `1660`. The fragment string stays `1246`. A raw material stays at `92`. A Basic material stays `""`. `USE_ANISOTROPY` stays later.

`USE_ANISOTROPY` has landed. A Shader material with `anisotropy` set to `1` writes `#define USE_ANISOTROPY` and a newline, `23` characters, on both prefixed shaders. The vertex string grows from `1608` to `1631`, and the fragment string from `1222` to `1245`. `0` and `-1` add nothing. An emissive map as well puts that line after `USE_EMISSIVEMAP`, so the vertex string is `1655`. A raw material stays at `92`. A Basic material stays `""`. `USE_ANISOTROPYMAP` stays later.

`USE_ANISOTROPYMAP` has landed. A Shader material with `anisotropy` set to `1` and a 1×1 anisotropy map writes `#define USE_ANISOTROPYMAP` and a newline, `26` characters, after `USE_ANISOTROPY` on both prefixed shaders. The vertex string grows from `1631` to `1657`, and the fragment string from `1245` to `1271`. The map with `anisotropy` at `0` adds nothing, so both strings stay `1608` and `1222`. A raw material stays at `92`. A Basic material stays `""`. `USE_CLEARCOAT` stays later.

`USE_CLEARCOAT` has landed. A Shader material with `clearcoat` set to `1` writes `#define USE_CLEARCOAT` and a newline, `22` characters, on the fragment prefix only. The fragment string grows from `1222` to `1244`. The vertex string stays `1608`. `0` and `-1` add nothing. Anisotropy set to `1` as well puts that line after `USE_ANISOTROPY`, so the fragment string is `1267` and the vertex string is `1631`. A raw material stays at `61`. A Basic material stays `""`. `USE_CLEARCOATMAP` stays later.

`USE_CLEARCOATMAP` has landed. A Shader material with `clearcoat` set to `1` and a 1×1 clearcoat map writes `#define USE_CLEARCOATMAP` and a newline, `25` characters, on both prefixed shaders. The vertex string grows from `1608` to `1633`. The fragment string also writes `USE_CLEARCOAT` first, so it grows from `1244` to `1269`. The map with `clearcoat` at `0` adds nothing, so both strings stay `1608` and `1222`. A raw material stays at `92`. A Basic material stays `""`. `USE_CLEARCOAT_ROUGHNESSMAP` stays later.

`USE_CLEARCOAT_ROUGHNESSMAP` has landed. A Shader material with `clearcoat` set to `1` and a 1×1 clearcoat roughness map writes `#define USE_CLEARCOAT_ROUGHNESSMAP` and a newline, `35` characters, on both prefixed shaders. The vertex string grows from `1608` to `1643`. The fragment string also writes `USE_CLEARCOAT`, so it grows from `1244` to `1279`. A clearcoat map as well puts the roughness line after `USE_CLEARCOATMAP`, so the vertex string is `1668`. The roughness map with `clearcoat` at `0` adds nothing. A raw material stays at `92`. A Basic material stays `""`. `USE_CLEARCOAT_NORMALMAP` stays later.

`USE_CLEARCOAT_NORMALMAP` has landed. A Shader material with `clearcoat` set to `1` and a 1×1 clearcoat normal map writes `#define USE_CLEARCOAT_NORMALMAP` and a newline, `32` characters, on both prefixed shaders. The vertex string grows from `1608` to `1640`. The fragment string also writes `USE_CLEARCOAT`, so it grows from `1244` to `1276`. A clearcoat roughness map as well puts the normal line after `USE_CLEARCOAT_ROUGHNESSMAP`, so the vertex string is `1675`. The normal map with `clearcoat` at `0` adds nothing. A raw material stays at `92`. A Basic material stays `""`. `USE_IRIDESCENCEMAP` stays later.

`USE_IRIDESCENCEMAP` has landed. A Shader material with `iridescence` set to `1` and a 1×1 iridescence map writes `#define USE_IRIDESCENCEMAP` and a newline, `27` characters, on both prefixed shaders. The vertex string grows from `1608` to `1635`, and the fragment string from `1222` to `1249`. `-1` adds nothing. A clearcoat normal map with `clearcoat` at `1` puts that line after `USE_CLEARCOAT_NORMALMAP`, so the vertex string is `1667`. A raw material stays at `92`. A Basic material stays `""`. `USE_IRIDESCENCE_THICKNESSMAP` stays later.

`USE_IRIDESCENCE_THICKNESSMAP` has landed. A Shader material with `iridescence` set to `1` and a 1×1 thickness map writes `#define USE_IRIDESCENCE_THICKNESSMAP` and a newline, `37` characters, on both prefixed shaders. The vertex string grows from `1608` to `1645`, and the fragment string from `1222` to `1259`. An iridescence map as well puts that line after `USE_IRIDESCENCEMAP`, so the vertex string is `1672`. The thickness map with `iridescence` at `0` adds nothing. A raw material stays at `92`. A Basic material stays `""`. `USE_SPECULARMAP` stays later.

`USE_SPECULARMAP` has landed. A Shader material with a 1×1 specular map writes `#define USE_SPECULARMAP` and a newline, `24` characters, on both prefixed shaders. The vertex string grows from `1608` to `1632`, and the fragment string from `1222` to `1246`. An iridescence thickness map with `iridescence` at `1` puts that line after `USE_IRIDESCENCE_THICKNESSMAP`, so the vertex string is `1669`. A raw material stays at `92`. A Basic material stays `""`. `USE_SPECULAR_COLORMAP` stays later.

`USE_SPECULAR_COLORMAP` has landed. A Shader material with a 1×1 specular color map writes `#define USE_SPECULAR_COLORMAP` and a newline, `30` characters, on both prefixed shaders. The vertex string grows from `1608` to `1638`, and the fragment string from `1222` to `1252`. A specular map as well puts that line after `USE_SPECULARMAP`, so the vertex string is `1662`. A raw material stays at `92`. A Basic material stays `""`. `USE_SPECULAR_INTENSITYMAP` stays later.

`USE_SPECULAR_INTENSITYMAP` has landed. A Shader material with a 1×1 specular intensity map writes `#define USE_SPECULAR_INTENSITYMAP` and a newline, `34` characters, on both prefixed shaders. The vertex string grows from `1608` to `1642`, and the fragment string from `1222` to `1256`. A specular color map as well puts that line after `USE_SPECULAR_COLORMAP`, so the vertex string is `1672`. A raw material stays at `92`. A Basic material stays `""`. `USE_ROUGHNESSMAP` stays later.

`USE_ROUGHNESSMAP` has landed. A Shader material with a 1×1 roughness map writes `#define USE_ROUGHNESSMAP` and a newline, `25` characters, on both prefixed shaders. The vertex string grows from `1608` to `1633`, and the fragment string from `1222` to `1247`. A specular intensity map as well puts that line after `USE_SPECULAR_INTENSITYMAP`, so the vertex string is `1667`. A raw material stays at `92`. A Basic material stays `""`. `USE_METALNESSMAP` stays later.

`USE_METALNESSMAP` has landed. A Shader material with a 1×1 metalness map writes `#define USE_METALNESSMAP` and a newline, `25` characters, on both prefixed shaders. The vertex string grows from `1608` to `1633`, and the fragment string from `1222` to `1247`. A roughness map as well puts that line after `USE_ROUGHNESSMAP`, so the vertex string is `1658`. A raw material stays at `92`. A Basic material stays `""`. `USE_ALPHAMAP` stays later.

`USE_ALPHAMAP` has landed. A Shader material with a 1×1 alpha map writes `#define USE_ALPHAMAP` and a newline, `21` characters, on both prefixed shaders. The vertex string grows from `1608` to `1629`, and the fragment string from `1222` to `1243`. A metalness map as well puts that line after `USE_METALNESSMAP`, so the vertex string is `1654`. A raw material stays at `92`. A Basic material stays `""`. `USE_ALPHAHASH` stays later.

`USE_ALPHAHASH` has landed. A Shader material with `alpha_hash` set true writes `#define USE_ALPHAHASH` and a newline, `22` characters, on both prefixed shaders. The vertex string grows from `1608` to `1630`, and the fragment string from `1222` to `1244`. Setting it false adds nothing. An alpha map as well puts that line after `USE_ALPHAMAP`, so the vertex string is `1651`. A raw material stays at `92`. A Basic material stays `""`. `USE_TRANSMISSION` stays later.

`USE_TRANSMISSION` has landed. A Shader material with `transmission` set to `1` writes `#define USE_TRANSMISSION` and a newline, `25` characters, on both prefixed shaders. The vertex string grows from `1608` to `1633`, and the fragment string from `1222` to `1247`. `-1` adds nothing. `alpha_hash` set true as well puts that line after `USE_ALPHAHASH`, so the vertex string is `1655`. A raw material stays at `92`. A Basic material stays `""`. `USE_TRANSMISSIONMAP` stays later.

`USE_TRANSMISSIONMAP` has landed. A Shader material with `transmission` set to `1` and a 1×1 transmission map writes `#define USE_TRANSMISSIONMAP` and a newline, `28` characters, after `USE_TRANSMISSION` on both prefixed shaders. The vertex string grows from `1633` to `1661`, and the fragment string from `1247` to `1275`. The map with `transmission` at `0` adds nothing, so both strings stay `1608` and `1222`. A raw material stays at `92`. A Basic material stays `""`. `USE_THICKNESSMAP` stays later.

`USE_THICKNESSMAP` has landed. A Shader material with `transmission` set to `1` and a 1×1 thickness map writes `#define USE_THICKNESSMAP` and a newline, `25` characters, after `USE_TRANSMISSION` on both prefixed shaders. The vertex string grows from `1633` to `1658`, and the fragment string from `1247` to `1272`. A transmission map as well puts that line after `USE_TRANSMISSIONMAP`, so the vertex string is `1686`. The thickness map with `transmission` at `0` adds nothing. A raw material stays at `92`. A Basic material stays `""`. `USE_SHEEN_COLORMAP` stays later.

`USE_SHEEN_COLORMAP` has landed. A Shader material with `sheen` set to `1` and a 1×1 sheen color map writes `#define USE_SHEEN_COLORMAP` and a newline, `27` characters, on both prefixed shaders. The vertex string grows from `1608` to `1635`, and the fragment string from `1222` to `1249`. `-1` adds nothing. With `transmission` at `1` and a thickness map, the vertex line follows `USE_THICKNESSMAP` and the vertex string is `1685`. The fragment line stays before `USE_TRANSMISSION`, so that string is `1299`. A raw material stays at `92`. A Basic material stays `""`. `USE_SHEEN_ROUGHNESSMAP` stays later.

`USE_SHEEN_ROUGHNESSMAP` has landed. A Shader material with `sheen` set to `1` and a 1×1 sheen roughness map writes `#define USE_SHEEN_ROUGHNESSMAP` and a newline, `31` characters, on both prefixed shaders. The vertex string grows from `1608` to `1639`, and the fragment string from `1222` to `1253`. A sheen color map as well puts that line after `USE_SHEEN_COLORMAP`, so the vertex string is `1666` and the fragment string is `1280`. The roughness map with `sheen` at `0` adds nothing. A raw material stays at `92`. A Basic material stays `""`. `MAP_UV` stays later.

`MAP_UV` has landed. A Shader material with a 1×1 color map writes `#define MAP_UV uv` and a newline, `18` characters, on the vertex prefix only. The vertex string grows from `1608` to `1642`. The fragment string grows only by `USE_MAP`, from `1222` to `1238`. The texture `channel` starts at `0`. Setting it to `1` writes `#define MAP_UV uv1`, `19` characters, and the vertex string is `1643`. With `sheen` at `1` and a sheen roughness map, that line follows `USE_SHEEN_ROUGHNESSMAP`, so channel `0` makes the vertex string `1673`. A raw material stays at `92`. A Basic material stays `""`. `ALPHAMAP_UV` stays later.

`ALPHAMAP_UV` has landed. A Shader material with a 1×1 alpha map writes `#define ALPHAMAP_UV uv` and a newline, `23` characters, on the vertex prefix only. The vertex string grows from `1608` to `1652`. The fragment string grows only by `USE_ALPHAMAP`, from `1222` to `1243`. Setting the texture `channel` to `1` writes `#define ALPHAMAP_UV uv1`, `24` characters, and the vertex string is `1653`. A color map as well puts that line after `MAP_UV`, so channel `0` makes the vertex string `1686`. A raw material stays at `92`. A Basic material stays `""`. `LIGHTMAP_UV` stays later.

`LIGHTMAP_UV` has landed. A Shader material with a 1×1 light map writes `#define LIGHTMAP_UV uv` and a newline, `23` characters, on the vertex prefix only. The vertex string grows from `1608` to `1652`. The fragment string grows only by `USE_LIGHTMAP`, from `1222` to `1243`. Setting the texture `channel` to `1` writes `#define LIGHTMAP_UV uv1`, `24` characters, and the vertex string is `1653`. An alpha map as well puts that line after `ALPHAMAP_UV`, so channel `0` makes the vertex string `1696`. A raw material stays at `92`. A Basic material stays `""`. `AOMAP_UV` stays later.

`AOMAP_UV` has landed. A Shader material with a 1×1 ambient-occlusion map writes `#define AOMAP_UV uv` and a newline, `20` characters, on the vertex prefix only. The vertex string grows from `1608` to `1646`. The fragment string grows only by `USE_AOMAP`, from `1222` to `1240`. Setting the texture `channel` to `1` writes `#define AOMAP_UV uv1`, `21` characters, and the vertex string is `1647`. A light map as well puts that line after `LIGHTMAP_UV`, so channel `0` makes the vertex string `1690`. A raw material stays at `92`. A Basic material stays `""`. `EMISSIVEMAP_UV` stays later.

`EMISSIVEMAP_UV` has landed. A Shader material with a 1×1 emissive map writes `#define EMISSIVEMAP_UV uv` and a newline, `26` characters, on the vertex prefix only. The vertex string grows from `1608` to `1658`. The fragment string grows only by `USE_EMISSIVEMAP`, from `1222` to `1246`. Setting the texture `channel` to `1` writes `#define EMISSIVEMAP_UV uv1`, `27` characters, and the vertex string is `1659`. An ambient-occlusion map as well puts that line after `AOMAP_UV`, so channel `0` makes the vertex string `1696`. A raw material stays at `92`. A Basic material stays `""`. `BUMPMAP_UV` stays later.

`BUMPMAP_UV` has landed. A Shader material with a 1×1 bump map and `wireframe` left false writes `#define BUMPMAP_UV uv` and a newline, `22` characters, on the vertex prefix only. The vertex string grows from `1608` to `1650`. The fragment string grows only by `USE_BUMPMAP`, from `1222` to `1242`. Setting the texture `channel` to `1` writes `#define BUMPMAP_UV uv1`, `23` characters, and the vertex string is `1651`. Turning `wireframe` on drops the line, so the vertex string is `1628`. An emissive map as well puts that line after `EMISSIVEMAP_UV`, so channel `0` makes the vertex string `1700`. A raw material stays at `92`. A Basic material stays `""`. `NORMALMAP_UV` stays later.

`NORMALMAP_UV` has landed. A Shader material with a 1×1 normal map writes `#define NORMALMAP_UV uv` and a newline, `24` characters, on the vertex prefix only. The default tangent-space lines stay, so the vertex string grows from `1608` to `1689`. The fragment string grows only by those normal-map lines, from `1222` to `1279`. Setting the texture `channel` to `1` writes `#define NORMALMAP_UV uv1`, `25` characters, and the vertex string is `1690`. A bump map as well puts that line after `BUMPMAP_UV`, so channel `0` makes the vertex string `1731`. A raw material stays at `92`. A Basic material stays `""`. `DISPLACEMENTMAP_UV` stays later.

`DISPLACEMENTMAP_UV` has landed. A Shader material with a 1×1 displacement map writes `#define DISPLACEMENTMAP_UV uv` and a newline, `30` characters, on the vertex prefix only. The vertex string grows from `1608` to `1666`. The fragment string stays `1222`. Setting the texture `channel` to `1` writes `#define DISPLACEMENTMAP_UV uv1`, `31` characters, and the vertex string is `1667`. A normal map as well puts that line after `NORMALMAP_UV`, so channel `0` makes the vertex string `1747`. A raw material stays at `92`. A Basic material stays `""`. `METALNESSMAP_UV` stays later.

`METALNESSMAP_UV` has landed. A Shader material with a 1×1 metalness map writes `#define METALNESSMAP_UV uv` and a newline, `27` characters, on the vertex prefix only. The vertex string grows from `1608` to `1660`. The fragment string grows only by `USE_METALNESSMAP`, from `1222` to `1247`. Setting the texture `channel` to `1` writes `#define METALNESSMAP_UV uv1`, `28` characters, and the vertex string is `1661`. A displacement map as well puts that line after `DISPLACEMENTMAP_UV`, so channel `0` makes the vertex string `1718`. A raw material stays at `92`. A Basic material stays `""`. `ROUGHNESSMAP_UV` stays later.

`ROUGHNESSMAP_UV` has landed. A Shader material with a 1×1 roughness map writes `#define ROUGHNESSMAP_UV uv` and a newline, `27` characters, on the vertex prefix only. The vertex string grows from `1608` to `1660`. The fragment string grows only by `USE_ROUGHNESSMAP`, from `1222` to `1247`. Setting the texture `channel` to `1` writes `#define ROUGHNESSMAP_UV uv1`, `28` characters, and the vertex string is `1661`. A metalness map as well puts that line after `METALNESSMAP_UV`, so channel `0` makes the vertex string `1712`. A raw material stays at `92`. A Basic material stays `""`. `ANISOTROPYMAP_UV` stays later.

`ANISOTROPYMAP_UV` has landed. A Shader material with `anisotropy` at `0` and a 1×1 anisotropy map adds nothing. Setting `anisotropy` to `1` writes `#define ANISOTROPYMAP_UV uv` and a newline, `28` characters, on the vertex prefix only. The vertex string grows from `1608` to `1685`. The fragment string grows only by `USE_ANISOTROPY` and `USE_ANISOTROPYMAP`, from `1222` to `1271`. Setting the texture `channel` to `1` writes `#define ANISOTROPYMAP_UV uv1`, `29` characters, and the vertex string is `1686`. Putting `anisotropy` back to `0` drops the line. A roughness map as well puts that line after `ROUGHNESSMAP_UV`, so channel `0` makes the vertex string `1737`. A raw material stays at `92`. A Basic material stays `""`. `CLEARCOATMAP_UV` stays later.

`CLEARCOATMAP_UV` has landed. A Shader material with `clearcoat` at `0` and a 1×1 clearcoat map adds nothing. Setting `clearcoat` to `1` writes `#define CLEARCOATMAP_UV uv` and a newline, `27` characters, on the vertex prefix only. The vertex string grows from `1608` to `1660`. The fragment string grows only by `USE_CLEARCOAT` and `USE_CLEARCOATMAP`, from `1222` to `1269`. Setting the texture `channel` to `1` writes `#define CLEARCOATMAP_UV uv1`, `28` characters, and the vertex string is `1661`. Putting `clearcoat` back to `0` drops the line. An anisotropy map with `anisotropy` at `1` puts that line after `ANISOTROPYMAP_UV`, so channel `0` makes the vertex string `1737`. A raw material stays at `92`. A Basic material stays `""`. `CLEARCOAT_NORMALMAP_UV` stays later.

`CLEARCOAT_NORMALMAP_UV` has landed. A Shader material with `clearcoat` at `0` and a 1×1 clearcoat normal map adds nothing. Setting `clearcoat` to `1` writes `#define CLEARCOAT_NORMALMAP_UV uv` and a newline, `34` characters, on the vertex prefix only. The vertex string grows from `1608` to `1674`. The fragment string grows only by `USE_CLEARCOAT` and `USE_CLEARCOAT_NORMALMAP`, from `1222` to `1276`. Setting the texture `channel` to `1` writes `#define CLEARCOAT_NORMALMAP_UV uv1`, `35` characters, and the vertex string is `1675`. Putting `clearcoat` back to `0` drops the line. A clearcoat map as well puts that line after `CLEARCOATMAP_UV`, so channel `0` makes the vertex string `1726`. A raw material stays at `92`. A Basic material stays `""`. `CLEARCOAT_ROUGHNESSMAP_UV` stays later.

`CLEARCOAT_ROUGHNESSMAP_UV` has landed. A Shader material with `clearcoat` at `0` and a 1×1 clearcoat roughness map adds nothing. Setting `clearcoat` to `1` writes `#define CLEARCOAT_ROUGHNESSMAP_UV uv` and a newline, `37` characters, on the vertex prefix only. The vertex string grows from `1608` to `1680`. The fragment string grows only by `USE_CLEARCOAT` and `USE_CLEARCOAT_ROUGHNESSMAP`, from `1222` to `1279`. Setting the texture `channel` to `1` writes `#define CLEARCOAT_ROUGHNESSMAP_UV uv1`, `38` characters, and the vertex string is `1681`. Putting `clearcoat` back to `0` drops the line. A clearcoat normal map as well puts that line after `CLEARCOAT_NORMALMAP_UV`, so channel `0` makes the vertex string `1746`. A raw material stays at `92`. A Basic material stays `""`. `IRIDESCENCEMAP_UV` stays later.

`IRIDESCENCEMAP_UV` has landed. A Shader material with `iridescence` at `0` and a 1×1 iridescence map adds nothing. Setting `iridescence` to `1` writes `#define IRIDESCENCEMAP_UV uv` and a newline, `29` characters, on the vertex prefix only. The vertex string grows from `1608` to `1664`. The fragment string grows only by `USE_IRIDESCENCEMAP`, from `1222` to `1249`. Setting the texture `channel` to `1` writes `#define IRIDESCENCEMAP_UV uv1`, `30` characters, and the vertex string is `1665`. Putting `iridescence` back to `0` drops the line. A clearcoat roughness map with `clearcoat` at `1` puts that line after `CLEARCOAT_ROUGHNESSMAP_UV`, so channel `0` makes the vertex string `1736`. A raw material stays at `92`. A Basic material stays `""`. `IRIDESCENCE_THICKNESSMAP_UV` stays later.

`IRIDESCENCE_THICKNESSMAP_UV` has landed. A Shader material with `iridescence` at `0` and a 1×1 iridescence thickness map adds nothing. Setting `iridescence` to `1` writes `#define IRIDESCENCE_THICKNESSMAP_UV uv` and a newline, `39` characters, on the vertex prefix only. The vertex string grows from `1608` to `1684`. The fragment string grows only by `USE_IRIDESCENCE_THICKNESSMAP`, from `1222` to `1259`. Setting the texture `channel` to `1` writes `#define IRIDESCENCE_THICKNESSMAP_UV uv1`, `40` characters, and the vertex string is `1685`. Putting `iridescence` back to `0` drops the line. An iridescence map as well puts that line after `IRIDESCENCEMAP_UV`, so channel `0` makes the vertex string `1740`. A raw material stays at `92`. A Basic material stays `""`. `SHEEN_COLORMAP_UV` stays later.

`SHEEN_COLORMAP_UV` has landed. A Shader material with `sheen` at `0` and a 1×1 sheen color map adds nothing. Setting `sheen` to `1` writes `#define SHEEN_COLORMAP_UV uv` and a newline, `29` characters, on the vertex prefix only. The vertex string grows from `1608` to `1664`. The fragment string grows only by `USE_SHEEN_COLORMAP`, from `1222` to `1249`. Setting the texture `channel` to `1` writes `#define SHEEN_COLORMAP_UV uv1`, `30` characters, and the vertex string is `1665`. Putting `sheen` back to `0` drops the line. An iridescence thickness map with `iridescence` at `1` puts that line after `IRIDESCENCE_THICKNESSMAP_UV`, so channel `0` makes the vertex string `1740`. A raw material stays at `92`. A Basic material stays `""`. `SHEEN_ROUGHNESSMAP_UV` stays later.

`SHEEN_ROUGHNESSMAP_UV` has landed. A Shader material with `sheen` at `0` and a 1×1 sheen roughness map adds nothing. Setting `sheen` to `1` writes `#define SHEEN_ROUGHNESSMAP_UV uv` and a newline, `33` characters, on the vertex prefix only. The vertex string grows from `1608` to `1672`. The fragment string grows only by `USE_SHEEN_ROUGHNESSMAP`, from `1222` to `1253`. Setting the texture `channel` to `1` writes `#define SHEEN_ROUGHNESSMAP_UV uv1`, `34` characters, and the vertex string is `1673`. Putting `sheen` back to `0` drops the line. A sheen color map as well puts that line after `SHEEN_COLORMAP_UV`, so channel `0` makes the vertex string `1728`. A raw material stays at `92`. A Basic material stays `""`. `SPECULARMAP_UV` stays later.

`SPECULARMAP_UV` has landed. A Shader material with a 1×1 specular map writes `#define SPECULARMAP_UV uv` and a newline, `26` characters, on the vertex prefix only. The vertex string grows from `1608` to `1658`. The fragment string grows only by `USE_SPECULARMAP`, from `1222` to `1246`. Setting the texture `channel` to `1` writes `#define SPECULARMAP_UV uv1`, `27` characters, and the vertex string is `1659`. A sheen roughness map with `sheen` at `1` puts that line after `SHEEN_ROUGHNESSMAP_UV`, so channel `0` makes the vertex string `1722`. A raw material stays at `92`. A Basic material stays `""`. `SPECULAR_COLORMAP_UV` stays later.

`SPECULAR_COLORMAP_UV` has landed. A Shader material with a 1×1 specular color map writes `#define SPECULAR_COLORMAP_UV uv` and a newline, `32` characters, on the vertex prefix only. The vertex string grows from `1608` to `1670`. The fragment string grows only by `USE_SPECULAR_COLORMAP`, from `1222` to `1252`. Setting the texture `channel` to `1` writes `#define SPECULAR_COLORMAP_UV uv1`, `33` characters, and the vertex string is `1671`. A specular map as well puts that line after `SPECULARMAP_UV`, so channel `0` makes the vertex string `1720`. A raw material stays at `92`. A Basic material stays `""`. `SPECULAR_INTENSITYMAP_UV` stays later.

`SPECULAR_INTENSITYMAP_UV` has landed. A Shader material with a 1×1 specular intensity map writes `#define SPECULAR_INTENSITYMAP_UV uv` and a newline, `36` characters, on the vertex prefix only. The vertex string grows from `1608` to `1678`. The fragment string grows only by `USE_SPECULAR_INTENSITYMAP`, from `1222` to `1256`. Setting the texture `channel` to `1` writes `#define SPECULAR_INTENSITYMAP_UV uv1`, `37` characters, and the vertex string is `1679`. A specular color map as well puts that line after `SPECULAR_COLORMAP_UV`, so channel `0` makes the vertex string `1740`. A raw material stays at `92`. A Basic material stays `""`. `TRANSMISSIONMAP_UV` stays later.

`TRANSMISSIONMAP_UV` has landed. A Shader material with `transmission` at `0` and a 1×1 transmission map adds nothing. Setting `transmission` to `1` writes `#define TRANSMISSIONMAP_UV uv` and a newline, `30` characters, on the vertex prefix only. The vertex string grows from `1608` to `1691`. The fragment string grows only by `USE_TRANSMISSION` and `USE_TRANSMISSIONMAP`, from `1222` to `1275`. Setting the texture `channel` to `1` writes `#define TRANSMISSIONMAP_UV uv1`, `31` characters, and the vertex string is `1692`. Putting `transmission` back to `0` drops the line. A specular intensity map as well puts that line after `SPECULAR_INTENSITYMAP_UV`, so channel `0` makes the vertex string `1761`. A raw material stays at `92`. A Basic material stays `""`. `THICKNESSMAP_UV` stays later.

`THICKNESSMAP_UV` has landed. A Shader material with `transmission` at `0` and a 1×1 thickness map adds nothing. Setting `transmission` to `1` writes `#define THICKNESSMAP_UV uv` and a newline, `27` characters, on the vertex prefix only. The vertex string grows from `1608` to `1685`. The fragment string grows only by `USE_TRANSMISSION` and `USE_THICKNESSMAP`, from `1222` to `1272`. Setting the texture `channel` to `1` writes `#define THICKNESSMAP_UV uv1`, `28` characters, and the vertex string is `1686`. Putting `transmission` back to `0` drops the line. A transmission map as well puts that line after `TRANSMISSIONMAP_UV`, so channel `0` makes the vertex string `1743`. A raw material stays at `92`. A Basic material stays `""`. `USE_TANGENT` stays later.

`USE_TANGENT` has landed. A Shader material with a tangent attribute, no normal map, and `anisotropy` at `0` adds nothing. A 1×1 normal map with that attribute writes `#define USE_TANGENT` and a newline, `20` characters, on both prefixes. The vertex string grows from the normal-map length `1689` to `1709`. The fragment string grows from `1279` to `1299`. The vertex line follows `NORMALMAP_UV`. `anisotropy` at `1` without a normal map also writes it: vertex `1651`, fragment `1265`. Putting `anisotropy` back to `0` drops the line. `flat_shading` true with `wireframe` false drops both lines. Turning `wireframe` on writes them again. A thickness map with `transmission` at `1` and `anisotropy` at `1` puts the vertex line after `THICKNESSMAP_UV`, so the vertex string is `1728` and the fragment string is `1315`. Omitting the tangent attribute leaves the normal-map lengths. A raw material stays at `92`. A Basic material stays `""`. Flat shading for a lit mesh with no normals stays later. `HAS_NORMAL` stays later.

`HAS_NORMAL` has landed. A Shader material without a normal attribute adds nothing. Passing `has_normal` as true writes `#define HAS_NORMAL` and a newline, `19` characters, on the vertex prefix only. The vertex string grows from `1608` to `1627`. The fragment string stays `1222`. `anisotropy` at `1` with a tangent attribute puts that line after `USE_TANGENT`, so the vertex string is `1670`. A raw material stays at `92`. A Basic material stays `""`. `USE_COLOR` stays later.

`USE_COLOR` has landed. A Shader material with `vertex_colors` false adds nothing. Setting it to true writes `#define USE_COLOR` and a newline, `18` characters, on both prefixes. The vertex string grows from `1608` to `1626`. The fragment string grows from `1222` to `1240`. Putting `vertex_colors` back to false drops both lines. A normal attribute puts the vertex line after `HAS_NORMAL`, so the vertex string is `1645` and the fragment string stays `1240`. A raw material stays at `92`. A Basic material stays `""`. Instancing color stays later. `USE_COLOR_ALPHA` stays later.

`USE_COLOR_ALPHA` has landed. A Shader material with `vertex_colors` true and a 3-component color attribute adds only `USE_COLOR`. Passing `has_vertex_alpha` as true writes `#define USE_COLOR_ALPHA` and a newline, `24` characters, on both prefixes. The vertex string grows from `1626` to `1650`. The fragment string grows from `1240` to `1264`. Putting `vertex_colors` back to false drops both color lines. A normal attribute puts the vertex line after `USE_COLOR`, so the vertex string is `1669` and the fragment string stays `1264`. A raw material stays at `92`. A Basic material stays `""`. Batching color stays later. `USE_UV1` stays later.

`USE_UV1` has landed. A Shader material with a 1×1 map on channel `0` adds no `USE_UV1` line. Setting the channel to `1` writes `#define USE_UV1` and a newline, `16` characters, on both prefixes. The vertex string grows from `1643` to `1659`. The fragment string grows from `1238` to `1254`. Channel `2` drops the line. `vertex_colors` with a 4-component color attribute puts the vertex line after `USE_COLOR_ALPHA`, so the vertex string is `1701` and the fragment string is `1296`. A raw material stays at `92`. A Basic material stays `""`. `USE_UV2` stays later.

`USE_UV2` has landed. A Shader material with a 1×1 map on channel `0` adds no `USE_UV2` line. Setting the channel to `2` writes `#define USE_UV2` and a newline, `16` characters, on both prefixes. The vertex string grows from `1643` to `1659`. The fragment string grows from `1238` to `1254`. Channel `3` drops the line. An alpha map on channel `1` puts that line after `USE_UV1`, so the vertex string is `1720` and the fragment string is `1291`. A raw material stays at `92`. A Basic material stays `""`. `USE_UV3` stays later.

`USE_UV3` has landed. A Shader material with a 1×1 map on channel `0` adds no `USE_UV3` line. Setting the channel to `3` writes `#define USE_UV3` and a newline, `16` characters, on both prefixes. The vertex string grows from `1643` to `1659`. The fragment string grows from `1238` to `1254`. Channel `4` drops the line. An alpha map on channel `2` puts that line after `USE_UV2`, so the vertex string is `1720` and the fragment string is `1291`. A raw material stays at `92`. A Basic material stays `""`. `USE_POINTS_UV` stays later.

`USE_POINTS_UV` has landed. A Shader material with a 1×1 map and `has_points_uv` false adds no `USE_POINTS_UV` line. Passing `has_points_uv` as true writes `#define USE_POINTS_UV` and a newline, `22` characters, on both prefixes. The vertex string grows from `1642` to `1664`. The fragment string grows from `1238` to `1260`. Clearing the map drops the line. An alpha map alone writes it, so the vertex string is `1674` and the fragment string is `1265`. A map on channel `3` puts that line after `USE_UV3`, so the vertex string is `1681` and the fragment string is `1276`. A raw material stays at `92`. A Basic material stays `""`. `FLAT_SHADED` stays later.

`FLAT_SHADED` has landed. A Shader material with `flat_shading` false adds nothing. Setting it to true writes `#define FLAT_SHADED` and a newline, `20` characters, on both prefixes. The vertex string grows from `1608` to `1628`. The fragment string grows from `1222` to `1242`. Turning `wireframe` on drops both lines. A 1×1 map with `has_points_uv` true puts that line after `USE_POINTS_UV`, so the vertex string is `1684` and the fragment string is `1280`. Putting `flat_shading` back to false leaves those map lengths at `1664` and `1260`. A normal map with a tangent attribute and `flat_shading` true replaces `USE_TANGENT` with this line, so both strings stay `1709` and `1299`. Turning `wireframe` on restores `USE_TANGENT`. A raw material stays at `92`. A Basic material stays `""`. A lit mesh with no normals still does not imply this line. `USE_SKINNING` stays later.

`USE_SKINNING` has landed. A Shader material with `has_skinning` false adds nothing. Passing `has_skinning` as true writes `#define USE_SKINNING` and a newline, `21` characters, on the vertex prefix only. The vertex string grows from `1608` to `1629`. The fragment string stays `1222`. `flat_shading` true puts that line after `FLAT_SHADED`, so the vertex string is `1649` and the fragment string is `1242`. Passing `has_skinning` as false drops the line. A raw material stays at `92`. A Basic material stays `""`. `USE_MORPHTARGETS` stays later.

`USE_MORPHTARGETS` has landed. A Shader material with `has_morph_targets` false adds nothing. Passing `has_morph_targets` as true writes `#define USE_MORPHTARGETS` and a newline, `25` characters, on the vertex prefix only. The vertex string grows from `1608` to `1633`. The fragment string stays `1222`. `has_skinning` true puts that line after `USE_SKINNING`, so the vertex string is `1654` and the fragment string stays `1222`. Passing `has_morph_targets` as false drops the line. A raw material stays at `92`. A Basic material stays `""`. `USE_MORPHNORMALS` stays later.

`USE_MORPHNORMALS` has landed. A Shader material with `has_morph_normals` false adds nothing. Passing `has_morph_normals` as true writes `#define USE_MORPHNORMALS` and a newline, `25` characters, on the vertex prefix only. The vertex string grows from `1608` to `1633`. The fragment string stays `1222`. `flat_shading` true with `wireframe` false drops the line and writes `FLAT_SHADED` instead, so the vertex string is `1628` and the fragment string is `1242`. Turning `wireframe` on writes `USE_MORPHNORMALS` again and the vertex string returns to `1633`. `has_morph_targets` true puts that line after `USE_MORPHTARGETS`, so the vertex string is `1658` and the fragment string stays `1222`. Passing `has_morph_normals` as false drops the line. A raw material stays at `92`. A Basic material stays `""`. `USE_MORPHCOLORS` stays later.

`USE_MORPHCOLORS` has landed. A Shader material with `has_morph_colors` false adds nothing. Passing `has_morph_colors` as true writes `#define USE_MORPHCOLORS` and a newline, `24` characters, on the vertex prefix only. The vertex string grows from `1608` to `1632`. The fragment string stays `1222`. `has_morph_normals` true puts that line after `USE_MORPHNORMALS`, so the vertex string is `1657` and the fragment string stays `1222`. Passing `has_morph_colors` as false drops the line. A raw material stays at `92`. A Basic material stays `""`. `MORPHTARGETS_TEXTURE_STRIDE` stays later.

`MORPHTARGETS_TEXTURE_STRIDE` has landed. A Shader material with `morph_targets_count` at `0` adds nothing, even when `morph_texture_stride` is `1`. A count of `1` and a stride of `1` writes `#define MORPHTARGETS_TEXTURE_STRIDE 1` and a newline, `38` characters, on the vertex prefix only. The vertex string grows from `1608` to `1646`. The fragment string stays `1222`. A count of `2` still writes stride `1`. A stride of `3` writes `3`. `has_morph_colors` true puts that line after `USE_MORPHCOLORS`, so the vertex string is `1670` and the fragment string stays `1222`. A raw material stays at `92`. A Basic material stays `""`. `MORPHTARGETS_COUNT` stays later.

`MORPHTARGETS_COUNT` has landed. A Shader material with `morph_targets_count` at `0` adds nothing. A count of `1` and a stride of `1` writes `#define MORPHTARGETS_COUNT 1` and a newline, `29` characters, on the vertex prefix only, after `MORPHTARGETS_TEXTURE_STRIDE`. The vertex string is `1675`. The fragment string stays `1222`. A count of `2` writes `2`. A count of `10` writes `10` and the vertex string is `1676`. `has_morph_colors` true puts that line after the stride line, so the vertex string is `1699` and the fragment string stays `1222`. A raw material stays at `92`. A Basic material stays `""`. `DOUBLE_SIDED` stays later.

`DOUBLE_SIDED` has landed. A Shader material with `side` front adds nothing. Setting `side` to double writes `#define DOUBLE_SIDED` and a newline, `21` characters, on both prefixes. The vertex string grows from `1608` to `1629`. The fragment string grows from `1222` to `1243`. Back and front drop the line. A morph target count of `1` and stride `1` puts the vertex line after `MORPHTARGETS_COUNT`, so the vertex string is `1696` and the fragment string stays `1243`. A raw material stays at `92`. A Basic material stays `""`. `FLIP_SIDED` stays later.

`FLIP_SIDED` has landed. A Shader material with `side` front adds nothing. Setting `side` to back writes `#define FLIP_SIDED` and a newline, `19` characters, on both prefixes. The vertex string grows from `1608` to `1627`. The fragment string grows from `1222` to `1241`. Front drops the line. Double writes `DOUBLE_SIDED` instead, so the vertex string is `1629` and the fragment string is `1243`. A morph target count of `1` and stride `1` with `side` back puts the vertex line after `MORPHTARGETS_COUNT`, so the vertex string is `1694` and the fragment string stays `1241`. A raw material stays at `92`. A Basic material stays `""`. `USE_SHADOWMAP` stays later.

`USE_SHADOWMAP` has landed. A Shader material with `shadow_map_enabled` false adds nothing. Passing it as true writes `#define USE_SHADOWMAP` and a newline, `22` characters, on both prefixes. The vertex string grows from `1608` to `1630`. The fragment string grows from `1222` to `1244`. `side` back puts that line after `FLIP_SIDED`, so the vertex string is `1649` and the fragment string is `1263`. Passing it as false leaves the back-side lengths at `1627` and `1241`. A raw material stays at `92`. A Basic material stays `""`. `SHADOWMAP_TYPE_BASIC` stays later.

`SHADOWMAP_TYPE_BASIC` has landed. A Shader material with `shadow_map_enabled` false adds nothing. Passing it as true writes `#define SHADOWMAP_TYPE_BASIC` and a newline, `29` characters, on both prefixes, after `USE_SHADOWMAP`. The vertex string is `1659`. The fragment string is `1273`. `side` back puts that line after `USE_SHADOWMAP`, so the vertex string is `1678` and the fragment string is `1292`. Passing it as false leaves the back-side lengths at `1627` and `1241`. A raw material stays at `92`. A Basic material stays `""`. `SHADOWMAP_TYPE_PCF` stays later.

`SHADOWMAP_TYPE_PCF` has landed. A Shader material with `shadow_map_enabled` false writes nothing even when `shadow_map_pcf` is true. Enabling the shadow map and PCF writes `#define SHADOWMAP_TYPE_PCF` and a newline, `27` characters, on both prefixes, instead of `SHADOWMAP_TYPE_BASIC`. The vertex string is `1657`. The fragment string is `1271`. `side` back puts that line after `USE_SHADOWMAP`, so the vertex string is `1676` and the fragment string is `1290`. Putting `shadow_map_pcf` back to false restores `SHADOWMAP_TYPE_BASIC` and the back-side lengths `1678` and `1292`. A raw material stays at `92`. A Basic material stays `""`. `SHADOWMAP_TYPE_VSM` stays later.

`SHADOWMAP_TYPE_VSM` has landed. A Shader material with `shadow_map_enabled` false writes nothing even when `shadow_map_vsm` is true. Enabling the shadow map and VSM writes `#define SHADOWMAP_TYPE_VSM` and a newline, `27` characters, on both prefixes, instead of `SHADOWMAP_TYPE_BASIC`. The vertex string is `1657`. The fragment string is `1271`. PCF and VSM together still write VSM. `side` back puts that line after `USE_SHADOWMAP`, so the vertex string is `1676` and the fragment string is `1290`. Putting `shadow_map_vsm` back to false with PCF true restores `SHADOWMAP_TYPE_PCF`. A raw material stays at `92`. A Basic material stays `""`. `USE_SIZEATTENUATION` stays later.

`USE_SIZEATTENUATION` has landed. A Shader material with `size_attenuation` false adds nothing. Passing it as true writes `#define USE_SIZEATTENUATION` and a newline, `28` characters, on the vertex prefix only. The vertex string grows from `1608` to `1636`. The fragment string stays `1222`. `shadow_map_enabled` true puts that line after `SHADOWMAP_TYPE_BASIC`, so the vertex string is `1687` and the fragment string is `1273`. Passing it as false drops the line. A raw material stays at `92`. A Basic material stays `""`. `USE_LIGHT_PROBES` stays later.

`USE_LIGHT_PROBES` has landed. A Shader material with `num_light_probes` at `0` adds nothing. A count of `1` writes `#define USE_LIGHT_PROBES` and a newline, `25` characters, on both prefixes. The vertex string grows from `1608` to `1633`. The fragment string grows from `1222` to `1247`. `size_attenuation` true puts the vertex line after `USE_SIZEATTENUATION`, so the vertex string is `1661` and the fragment string stays `1247`. A count of `2` writes the same line. A raw material stays at `92`. A Basic material stays `""`. `USE_LOGARITHMIC_DEPTH_BUFFER` stays later.

`USE_LOGARITHMIC_DEPTH_BUFFER` has landed. A Shader material with `logarithmic_depth_buffer` false adds nothing. Passing it as true writes `#define USE_LOGARITHMIC_DEPTH_BUFFER` and a newline, `37` characters, on both prefixes. The vertex string grows from `1608` to `1645`. The fragment string grows from `1222` to `1259`. `num_light_probes` at `1` puts that line after `USE_LIGHT_PROBES`, so the vertex string is `1670` and the fragment string is `1284`. Passing it as false drops both lines. A raw material stays at `92`. A Basic material stays `""`. `USE_REVERSED_DEPTH_BUFFER` stays later.

`USE_REVERSED_DEPTH_BUFFER` has landed. A Shader material with `reversed_depth_buffer` false adds nothing. Passing it as true writes `#define USE_REVERSED_DEPTH_BUFFER` and a newline, `34` characters, on both prefixes. The vertex string grows from `1608` to `1642`. The fragment string grows from `1222` to `1256`. `logarithmic_depth_buffer` true puts that line after `USE_LOGARITHMIC_DEPTH_BUFFER`, so the vertex string is `1679` and the fragment string is `1293`. Passing it as false drops both lines. A raw material stays at `92`. A Basic material stays `""`. `TONE_MAPPING` stays later.

`TONE_MAPPING` has landed. A Shader material with `tone_mapping` false adds nothing. Passing it as true writes a newline, `#define TONE_MAPPING`, and a newline, `22` characters, on the fragment prefix after the builtin uniforms. The fragment string grows from `1222` to `1244`. The vertex string stays `1608`. `reversed_depth_buffer` true puts that line after the uniforms that follow `USE_REVERSED_DEPTH_BUFFER`, so the fragment string is `1278` and the vertex string is `1642`. Passing it as false drops the line. A raw material stays at `61`. A Basic material stays `""`. `tonemapping_pars_fragment` stays later.

`tonemapping_pars_fragment` has landed. A Shader material with `tone_mapping` false adds nothing. Passing it as true keeps `#define TONE_MAPPING` and then writes the tone-mapping pars chunk. The chunk starts and ends with a newline and is `5231` characters, so the fragment string grows from `1222` to `6475`. The vertex string stays `1608`. `reversed_depth_buffer` true puts the chunk after `TONE_MAPPING`, so the fragment string is `6509` and the vertex string is `1642`. Passing it as false drops the define and the chunk. A raw material stays at `61`. A Basic material stays `""`. `getToneMappingFunction` stays later.

`getToneMappingFunction` has landed. A Shader material with `tone_mapping` at `No` adds nothing. `Linear` writes `vec3 toneMapping( vec3 color ) { return LinearToneMapping( color ); }` after `tonemapping_pars_fragment`, `69` characters, with a newline on each side, `71` in total. The fragment string grows from `1222` to `6546`. The vertex string stays `1608`. `Reinhard` is `71` characters and the fragment string is `6548`. `Cineon` is `69` and stays `6546`. `ACES` writes `ACESFilmic`, `73` characters, and the fragment string is `6550`. `AgX` is `66` and the fragment string is `6543`. `Neutral` is `70` and the fragment string is `6547`. `reversed_depth_buffer` true puts the `Linear` line after the chunk, so the fragment string is `6580` and the vertex string is `1642`. A raw material stays at `61`. A Basic material stays `""`. `DITHERING` stays later.

`DITHERING` has landed. A Shader material with `dithering` false adds nothing. Setting it to true writes `#define DITHERING` on the fragment prefix. With `tone_mapping` at `No`, a leading newline is included, so the line is `19` characters and the fragment string grows from `1222` to `1241`. The vertex string stays `1608`. `Linear` already ends the tone-mapping function with a newline, so the define adds `18` characters and the fragment string is `6564`. `reversed_depth_buffer` true with `Linear` puts that line after the tone-mapping function, so the fragment string is `6598` and the vertex string is `1642`. Setting `dithering` back to false drops the line. A raw material stays at `61`. A Basic material stays `""`. `OPAQUE` stays later.

`OPAQUE` has landed. A default Shader material is opaque: `transparent` is false, `blending` is `Normal`, and `alpha_to_coverage` is false. The fragment prefix writes `#define OPAQUE` after the builtin uniforms. A leading newline is included, so the line is `16` characters and the fragment string grows from `1222` to `1238`. The vertex string stays `1608`. `transparent` true drops it, and so do `Additive` blending and `alpha_to_coverage` true. `dithering` true already ends with a newline, so the define adds `15` characters and the fragment string is `1256`. `Linear` tone mapping likewise adds `15`, and the fragment string is `6561`. `reversed_depth_buffer` true with `Linear` puts that line after the tone-mapping function, so the fragment string is `6595` and the vertex string is `1642`. A raw material stays at `61`. A Basic material stays `""`. `colorspace_pars_fragment` stays later.

`colorspace_pars_fragment` has landed. Every non-raw Shader material writes this chunk after `OPAQUE`. The chunk starts with two newlines, ends with a newline, and is `496` characters. A default opaque material grows the fragment string from `1238` to `1734`. The vertex string stays `1608`. `transparent` true, with no dithering and `tone_mapping` at `No`, adds one more leading newline, so the fragment string is `1719`. `dithering` true keeps the chunk after `OPAQUE` and the fragment string is `1752`. `Linear` tone mapping makes the fragment string `7057`. `reversed_depth_buffer` true with `Linear` makes it `7091`, and the vertex string is `1642`. A raw material stays at `61`. A Basic material stays `""`. `getTexelEncodingFunction` stays later.

`getTexelEncodingFunction` has landed. Every non-raw Shader material writes `linearToOutputTexel` after `colorspace_pars_fragment`. The default `output_srgb` true calls `sRGBTransferOETF`. That function is `179` characters, `181` with the newlines on each side, so the fragment string grows from `1734` to `1915`. The vertex string stays `1608`. `output_srgb` false calls `LinearTransferOETF`, `181` characters and `183` with the newlines, so the fragment string is `1917`. `transparent` true keeps the sRGB function and the fragment string is `1900`. `dithering` true makes it `1933`. `Linear` tone mapping makes it `7238`. `reversed_depth_buffer` true with `Linear` makes it `7272`, and the vertex string is `1642`. A raw material stays at `61`. A Basic material stays `""`. `getLuminanceFunction` stays later.

`getLuminanceFunction` has landed. Every non-raw Shader material writes `luminance` after `linearToOutputTexel`. The function is `123` characters, `125` with the newlines on each side, so the fragment string grows from `1915` to `2040`. The vertex string stays `1608`. The weights are `0.2126`, `0.7152`, and `0.0722`. `output_srgb` false makes the fragment string `2042`. `transparent` true makes it `2025`. `dithering` true makes it `2058`. `Linear` tone mapping makes it `7363`. `reversed_depth_buffer` true with `Linear` makes it `7397`, and the vertex string is `1642`. A raw material stays at `61`. A Basic material stays `""`. `DEPTH_PACKING` stays later.

`DEPTH_PACKING` has landed. A Shader material with `depth_packing` below `0` adds nothing. The fragment string stays `2040` and the vertex string stays `1608`. Passing `3200` writes `#define DEPTH_PACKING 3200` and a newline, `27` characters, so the fragment string is `2067`. `3201` is the same length and writes `3201`. Passing `0` writes `#define DEPTH_PACKING 0`, `24` characters, and the fragment string is `2064`. `reversed_depth_buffer` true with `Linear` tone mapping puts that line after `luminance`, so `3200` makes the fragment string `7424` and the vertex string stays `1608`. A raw material stays at `61`. A Basic material stays `""`. The trailing newline of `prefixFragment` stays later.

The trailing newline of `prefixFragment` has landed. Every non-raw Shader fragment prefix gains one newline after `luminance` or `DEPTH_PACKING`. The default fragment string grows from `2040` to `2041`. The vertex string stays `1608`. `depth_packing` `3200` grows from `2067` to `2068` and the define slice stays `[1979:2005]`. A raw material stays at `61`. A Basic material stays `""`. `USE_GRADIENTMAP` stays later.

`USE_GRADIENTMAP` has landed. A Shader material with an empty `gradient_map` adds nothing. The fragment string stays `2041` and the vertex string stays `1608`. A set map writes `#define USE_GRADIENTMAP` and a newline, `24` characters, so the fragment string is `2065`. The vertex string stays `1608`. `flat_shading` true keeps the vertex string at `1628` and writes the define before `FLAT_SHADED`, so the fragment string is `2085`. Clearing the map drops the line. A raw material stays at `61`. A Basic material stays `""`. `PREMULTIPLIED_ALPHA` stays later.

`PREMULTIPLIED_ALPHA` has landed. A Shader material with `premultiplied_alpha` false adds nothing. The fragment string stays `2041` and the vertex string stays `1608`. Setting it to true writes `#define PREMULTIPLIED_ALPHA` and a newline, `28` characters, so the fragment string is `2069`. The vertex string stays `1608`. `num_light_probes` `1` keeps the vertex string at `1633` and writes the define before `USE_LIGHT_PROBES`, so the fragment string is `2094`. `shadow_map_enabled` true keeps the vertex string at `1659` and puts the define after `SHADOWMAP_TYPE_BASIC`, so the fragment string is `2120`. Setting it back to false drops the line. A raw material stays at `61`. A Basic material stays `""`. `USE_LIGHT_PROBES_GRID` stays later.

`USE_LIGHT_PROBES_GRID` has landed. A Shader material with `num_light_probe_grids` at `0` or below adds nothing. The fragment string stays `2041` and the vertex string stays `1608`. Passing `1` writes `#define USE_LIGHT_PROBES_GRID` and a newline, `30` characters, so the fragment string is `2071`. The vertex string stays `1608`. `num_light_probes` `1` keeps the vertex string at `1633` and writes the grid define after `USE_LIGHT_PROBES`, so the fragment string is `2096`. `premultiplied_alpha` true keeps the vertex string at `1608` and puts the define after `PREMULTIPLIED_ALPHA`, so the fragment string is `2099`. A raw material stays at `61`. A Basic material stays `""`. `DECODE_VIDEO_TEXTURE` stays later.

`DECODE_VIDEO_TEXTURE` has landed. A Shader material with `decode_video_texture` false adds nothing. The fragment string stays `2041` and the vertex string stays `1608`. Setting it to true writes `#define DECODE_VIDEO_TEXTURE` and a newline, `29` characters, so the fragment string is `2070`. The vertex string stays `1608`. `num_light_probe_grids` `1` writes the define after `USE_LIGHT_PROBES_GRID`, so the fragment string is `2100` and the vertex string stays `1608`. A raw material stays at `61`. A Basic material stays `""`. `DECODE_VIDEO_TEXTURE_EMISSIVE` stays later.

`DECODE_VIDEO_TEXTURE_EMISSIVE` has landed. A Shader material with `decode_video_texture_emissive` false adds nothing. The fragment string stays `2041` and the vertex string stays `1608`. Setting it to true writes `#define DECODE_VIDEO_TEXTURE_EMISSIVE` and a newline, `38` characters, so the fragment string is `2079`. The vertex string stays `1608`. `decode_video_texture` true writes the define after `DECODE_VIDEO_TEXTURE`, so the fragment string is `2108` and the vertex string stays `1608`. A raw material stays at `61`. A Basic material stays `""`. `resolveIncludes` stays later.

`resolveIncludes` has landed. It rewrites a shader string. A line that begins with optional spaces or tabs, then `#include <name>`, is replaced by that chunk. The chunk is expanded the same way. `#include <common>` with chunk `float x;` and a newline becomes that text. Two leading spaces are part of the match. Text after `>` on the same line stays. `#include` followed by a tab stays unchanged. A name can contain letters, digits, `_`, `.`, and `/`. A missing name aborts. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `replaceLightNums` stays later.

`replaceLightNums` has landed. It rewrites light-count tokens in a shader string. Unset counts become `0`. `NUM_DIR_LIGHTS` `2` is written twice when the token appears twice. `NUM_SPOT_LIGHT_COORDS` is spot-light shadows plus spot-light maps minus spot-light shadows that have maps, so `3`, `4`, and `1` write `6`. `NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS` is replaced before `NUM_SPOT_LIGHT_SHADOWS`. A negative coordinate count writes `-2`. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `replaceClippingPlaneNums` stays later.

`replaceClippingPlaneNums` has landed. It rewrites clipping-plane tokens in a shader string. Unset counts become `0`, so `NUM_CLIPPING_PLANES` and `UNION_CLIPPING_PLANES` both write `0`. `NUM_CLIPPING_PLANES` `5` with `num_clip_intersection` `2` writes `5` and `3`. `UNION_CLIPPING_PLANES` is the plane count minus the intersection count, so `1` and `7` write `-6`. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `unrollLoops` stays later.

`unrollLoops` has landed. It expands `#pragma unroll_loop_start` through `#pragma unroll_loop_end`. The loop is `for ( int i = start; i < end; i ++ )`. The start index is included and the end index is not. `[ i ]` becomes `[ 0 ]` with spaces, and `UNROLLED_LOOP_INDEX` becomes the same integer. A loop from `0` to `2` writes both indexes. A loop from `2` to `2` removes the block. A pragma that does not match stays unchanged. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `getProgramCacheKey` stays later.

`getProgramCacheKey` has landed. The key is comma-separated. With no shader id the first two fields are the custom vertex and fragment ids, both empty by default. A shader id replaces those two fields with one id. Defines are appended as name then value, in the given order. A raw material skips the parameter list, both boolean masks, and the renderer output color space. The default non-raw key starts `,,highp,` and ends `,0,0,,`. `instancing` and `retroreflection` set mask bits `0` and `24`, so the first mask is `16777217`. `opaque` and light-probe grids set bits `17` and `22`, so the second mask is `4325376`. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `getUniforms` stays later.

`getUniforms` has landed. A builtin material type is turned into a shader id, then that id selects a table from the given library and the table is copied. `MeshStandardMaterial` and `MeshPhysicalMaterial` both use `physical`. `LineBasicMaterial` uses `basic`. Changing the copy leaves the library table unchanged, and the material's own numeric map is not returned. `ShaderMaterial` and `RawShaderMaterial` return the map that was passed in, so writing a value there changes that map. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `acquireProgram` stays later.

`acquireProgram` has landed. An empty cache holds no programs. The first acquire of a key stores one record with `usedTimes` `1`. Acquiring that key again increments the same record, so the count is `2` and the list length stays `1`. A second key is appended, and the first record stays at `2`. No WebGL program is compiled. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `releaseProgram` stays later.

`releaseProgram` has landed. Releasing a program decrements `usedTimes`. A count of `2` becomes `1` and the list stays. A count of `1` becomes `0`, that entry is removed, and the last list item moves into the empty slot. Acquiring the same key afterwards starts again at `1`. No WebGL program is destroyed. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `releaseShaderCache` stays later.

`releaseShaderCache` has landed. A material claims a vertex code and a fragment code once each, and each distinct code starts at `usedTimes` `1`. Claiming the same codes again does not increment. Two materials sharing a vertex code make that count `2`. Releasing the first material drops it to `1` and deletes the fragment code that reached `0`. Releasing the second deletes the shared code. Identical vertex and fragment code increment once. No shader is compiled. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `dispose` stays later.

`dispose` has landed. It clears the shader-code map and the material map. A stage that was already read keeps its `usedTimes`, and the next stage id keeps climbing. A program cache is left as it was. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `getVertexShaderStage` stays later.

`getVertexShaderStage` has landed. It returns the stage for the material's vertex shader. A missing code is stored with `usedTimes` `0`. Reading it again keeps that count and the same id. Shader and Raw share the default vertex code, so they share one stage. A Basic material uses the empty string and gets another stage. The material map stays empty. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `getFragmentShaderStage` stays later.

`getFragmentShaderStage` has landed. It returns the stage for the material's fragment shader. A missing code is stored with `usedTimes` `0`. Reading it again keeps that count and the same id. Shader and Raw share the default fragment code, so they share one stage. That stage is not the vertex stage. A Basic material uses the empty string and gets another stage. The material map stays empty. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `customVertexShaderID` stays later.

`customVertexShaderID` has landed. A builtin material type has no custom vertex id. Shader and Raw return the vertex stage id, and `usedTimes` stays `0`. They share the default vertex code, so they share that id. Replacing the vertex code returns a new id. The material map stays empty. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `customFragmentShaderID` stays later.

`customFragmentShaderID` has landed. A builtin material type has no custom fragment id. Shader and Raw return the fragment stage id, and `usedTimes` stays `0`. They share the default fragment code, so they share that id. That id is not the vertex stage id. Replacing the fragment code returns a new id. The material map stays empty. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `shaderType` stays later.

`shaderType` has landed. It is the material `type` string. Basic is `MeshBasicMaterial`, Lambert is `MeshLambertMaterial`, Standard is `MeshStandardMaterial`, Physical is `MeshPhysicalMaterial`, Toon is `MeshToonMaterial`, Matcap is `MeshMatcapMaterial`, Normal is `MeshNormalMaterial`, Depth is `MeshDepthMaterial`, Distance is `MeshDistanceMaterial`, Phong is `MeshPhongMaterial`, Shadow is `ShadowMaterial`, Shader is `ShaderMaterial`, and Raw is `RawShaderMaterial`. Changing the material name leaves the type unchanged. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `shaderName` stays later.

`shaderName` has landed. It is the material `name`. A new Shader material reads `""`. Setting the name to `renamed` makes `shaderName` read `renamed`, and `shaderType` stays `ShaderMaterial`. Basic, Lambert, and Raw also start empty. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `vertexShader` stays later.

`vertexShader` has landed. A builtin material type does not return source, because that source still lives in `ShaderLib`. Shader and Raw return their own vertex shader string. Replacing that string changes the parameter. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `fragmentShader` stays later.

`fragmentShader` has landed. A builtin material type does not return source, because that source still lives in `ShaderLib`. Shader and Raw return their own fragment shader string. That string is not the vertex shader. Replacing it changes the parameter. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `defines` stays later.

`defines` has landed. The parameter is the material's own map. A Shader material starts empty, and writing `FOO` through the parameter writes the material. Basic stays empty. Standard contains `STANDARD` mapped to an empty string. Physical contains that key and `PHYSICAL`, also empty. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `isRawShaderMaterial` stays later.

`isRawShaderMaterial` has landed. Raw reads `true`. Shader, Basic, and Lambert read `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `glslVersion` stays later.

`glslVersion` has landed. Shader, Raw, and Basic start empty. Setting Shader to `GLSL3` makes the parameter read `GLSL3`. Setting it to `GLSL1` reads `GLSL1`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the field is still empty. `precision` stays later.

`precision` has landed. With no material precision, the parameter is the capabilities string, so `mediump` stays `mediump`. Setting the material to `mediump` or `lowp` replaces a `highp` capabilities value. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the material precision is still empty. `getMaxPrecision` stays later.

`getMaxPrecision` has landed. `highp` stays `highp` when both vertex and fragment high floats are available. If either high float is missing, it becomes `mediump` when both medium floats are available, and `lowp` when a medium float is missing. A `mediump` request becomes `lowp` when a medium float is missing. `lowp` stays `lowp`. A material precision of `highp` uses this check, so a missing vertex high float makes `program_precision` return `mediump`. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `batching` stays later.

`batching` has landed. It is true only when the object is a batched mesh. The default is `false`. Passing `true` keeps `true`. There is no batched-mesh type yet, so the flag is an argument. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `batchingColor` stays later.

`batchingColor` has landed. It is `true` only when the object is a batched mesh and it has a colors texture. Either flag alone stays `false`. The default is `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `instancing` stays later.

`instancing` has landed. It is true only when the object is an instanced mesh. The default is `false`. Passing `true` keeps `true`. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `instancingColor` stays later.

`instancingColor` has landed. It is `true` only when the object is an instanced mesh and it has `instanceColor`. Either flag alone stays `false`. The default is `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `instancingMorph` stays later.

`instancingMorph` has landed. It is `true` only when the object is an instanced mesh and it has `morphTexture`. Either flag alone stays `false`. The default is `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `outputColorSpace` stays later.

`outputColorSpace` has landed. With no render target it returns the renderer output space, so `srgb` stays `srgb`. A normal render target returns the working space, so `srgb-linear` replaces `srgb`. An XR target returns the target texture space, so `display-p3` is kept. The XR flag does nothing when there is no target. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `alphaToCoverage` stays later.

`alphaToCoverage` has landed. Shader, Raw, and Basic start `false`. Setting Shader to `true` makes the parameter read `true`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the switch is still off. `map` stays later.

`map` has landed. Shader, Raw, and Basic start `false`. Giving Shader a 1×1 map makes the parameter `true`. Clearing it returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the map is still empty. `matcap` stays later.

`matcap` has landed. Shader, Raw, and a Matcap material start `false`. Giving Shader a 1×1 matcap makes the parameter `true`. Clearing it returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the matcap is still empty. `envMap` stays later.

`envMap` has landed. A material with its own env map reads `true`. Lambert, Phong, Toon, Standard, and Physical also read `true` when the scene has an environment and the material map is empty. Basic, Shader, and Matcap stay `false` in that case. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the env map is still empty. `envMapMode` stays later.

`envMapMode` has landed. With no env map the parameter is empty, and a passed mapping is ignored. Lambert with a scene environment returns that mapping, so `301` stays `301`. A Shader material with its own env map returns the mapping it was given, so `302` stays `302`. Basic with only a scene environment stays empty. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the env map is still empty. `envMapCubeUVHeight` stays later.

`envMapCubeUVHeight` has landed. With no env map, or with a mapping other than `306`, the parameter is empty. `306` is `CubeUVReflectionMapping`. A Shader material whose env map is 1×1 and whose mapping is `306` returns `1`. Lambert with only a scene environment and mapping `306` returns the given height, so `512` stays `512`. Basic with that scene stays empty. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the env map is still empty. `aoMap` stays later.

`aoMap` has landed. Shader, Raw, and Standard start `false`. Giving Shader a 1×1 ao map makes the parameter `true`. Clearing it returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the ao map is still empty. `lightMap` stays later.

`lightMap` has landed. Shader, Raw, and Lambert start `false`. Giving Shader a 1×1 light map makes the parameter `true`. Clearing it returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the light map is still empty. `bumpMap` stays later.

`bumpMap` has landed. Shader, Raw, and Phong start `false`. Giving Shader a 1×1 bump map makes the parameter `true`. Turning `wireframe` on makes it `false` while the map stays. Clearing the map keeps it `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the bump map is still empty. `normalMap` stays later.

`normalMap` has landed. Shader, Raw, and Standard start `false`. Giving Shader a 1×1 normal map makes the parameter `true`. Clearing it returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the normal map is still empty. `normalMapObjectSpace` stays later.

`normalMapObjectSpace` has landed. Shader, Raw, and Standard start `false`. Object space without a normal map stays `false`. Giving Shader a 1×1 normal map in object space makes the parameter `true`. Tangent space with that map stays `false`. Clearing the map keeps it `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the normal map is still empty. `normalMapTangentSpace` stays later.

`normalMapTangentSpace` has landed. Shader, Raw, and Standard start `false`. Tangent space without a normal map stays `false`. Giving Shader a 1×1 normal map in tangent space makes the parameter `true`. Object space with that map stays `false`. Clearing the map keeps it `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the normal map is still empty. `packedNormalMap` stays later.

`packedNormalMap` has landed. Shader, Raw, and Standard stay `false` without a normal map, even when the passed format is `1030`, `37490`, or `36285`. Those integers are `RGFormat`, `RG11_EAC_Format`, and `RED_GREEN_RGTC2_Format`. A Shader material with a 1×1 normal map in tangent space stays `false` for `1023` and `1028`, and reads `true` for the three packed formats. The signed formats `37491` and `36286` stay `false`. Object space with format `1030` stays `false`. Clearing the map keeps it `false`. The texture still has no format field, so the caller passes the integer. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the normal map is still empty. `displacementMap` stays later.

`displacementMap` has landed. Shader, Raw, and Lambert start `false`. Giving Shader a 1×1 displacement map makes the parameter `true`. Clearing it returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the displacement map is still empty. `emissiveMap` stays later.

`emissiveMap` has landed. Shader, Raw, and Standard start `false`. Giving Shader a 1×1 emissive map makes the parameter `true`. Clearing it returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the emissive map is still empty. `metalnessMap` stays later.

`metalnessMap` has landed. Shader, Raw, and Standard start `false`. Giving Shader a 1×1 metalness map makes the parameter `true`. Clearing it returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the metalness map is still empty. `roughnessMap` stays later.

`roughnessMap` has landed. Shader, Raw, and Standard start `false`. Giving Shader a 1×1 roughness map makes the parameter `true`. Clearing it returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the roughness map is still empty. `anisotropy` stays later.

`anisotropy` has landed. Shader, Raw, and Physical start `false`. A negative value stays `false`. Setting Shader to `0.25` makes the parameter `true`. Setting it back to `0` returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while anisotropy is still `0`. `anisotropyMap` stays later.

`anisotropyMap` has landed. Shader, Raw, and Physical start `false`. A 1×1 anisotropy map with strength `0` stays `false`. Strength `0.25` with that map makes the parameter `true`. Returning the strength to `0` makes it `false` while the map stays. Clearing the map with strength `0.25` keeps it `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while both are still unset. `clearcoat` stays later.

`clearcoat` has landed. Shader, Raw, and Physical start `false`. A negative value stays `false`. Setting Shader to `0.25` makes the parameter `true`. Setting it back to `0` returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while clearcoat is still `0`. `clearcoatMap` stays later.

`clearcoatMap` has landed. Shader, Raw, and Physical start `false`. A 1×1 clearcoat map with strength `0` stays `false`. Strength `0.25` with that map makes the parameter `true`. Returning the strength to `0` makes it `false` while the map stays. Clearing the map with strength `0.25` keeps it `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while both are still unset. `clearcoatNormalMap` stays later.

`clearcoatNormalMap` has landed. Shader, Raw, and Physical start `false`. A 1×1 clearcoat normal map with strength `0` stays `false`. Strength `0.25` with that map makes the parameter `true`. Returning the strength to `0` makes it `false` while the map stays. Clearing the map with strength `0.25` keeps it `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while both are still unset. `clearcoatRoughnessMap` stays later.

`clearcoatRoughnessMap` has landed. Shader, Raw, and Physical start `false`. A 1×1 clearcoat roughness map with strength `0` stays `false`. Strength `0.25` with that map makes the parameter `true`. Returning the strength to `0` makes it `false` while the map stays. Clearing the map with strength `0.25` keeps it `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while both are still unset. `dispersion` stays later.

`dispersion` has landed. Shader, Raw, and Physical start `false`. A negative value stays `false`. Setting Shader to `0.25` makes the parameter `true`. Setting it back to `0` returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while dispersion is still `0`. `retroreflection` stays later.

`retroreflection` has landed. Shader, Raw, and Physical start `false`. A negative retroreflectivity stays `false`. Setting Shader to `0.25` makes the parameter `true`. Setting it back to `0` returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while retroreflectivity is still `0`. `iridescence` stays later.

`iridescence` has landed. Shader, Raw, and Physical start `false`. A negative value stays `false`. Setting Shader to `0.25` makes the parameter `true`. Setting it back to `0` returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while iridescence is still `0`. `iridescenceMap` stays later.

`iridescenceMap` has landed. Shader, Raw, and Physical start `false`. A 1×1 iridescence map with strength `0` stays `false`. Strength `0.25` with that map makes the parameter `true`. Returning the strength to `0` makes it `false` while the map stays. Clearing the map with strength `0.25` keeps it `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while both are still unset. `iridescenceThicknessMap` stays later.

`iridescenceThicknessMap` has landed. Shader, Raw, and Physical start `false`. A 1×1 iridescence thickness map with strength `0` stays `false`. Strength `0.25` with that map makes the parameter `true`. Returning the strength to `0` makes it `false` while the map stays. Clearing the map with strength `0.25` keeps it `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while both are still unset. `sheen` stays later.

`sheen` has landed. Shader, Raw, and Physical start `false`. A negative value stays `false`. Setting Shader to `0.25` makes the parameter `true`. Setting it back to `0` returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while sheen is still `0`. `sheenColorMap` stays later.

`sheenColorMap` has landed. Shader, Raw, and Physical start `false`. A 1×1 sheen color map with strength `0` stays `false`. Strength `0.25` with that map makes the parameter `true`. Returning the strength to `0` makes it `false` while the map stays. Clearing the map with strength `0.25` keeps it `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while both are still unset. `sheenRoughnessMap` stays later.

`sheenRoughnessMap` has landed. Shader, Raw, and Physical start `false`. A 1×1 sheen roughness map with strength `0` stays `false`. Strength `0.25` with that map makes the parameter `true`. Returning the strength to `0` makes it `false` while the map stays. Clearing the map with strength `0.25` keeps it `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while both are still unset. `specularMap` stays later.

`specularMap` has landed. Shader, Raw, and Phong start `false`. Giving Shader a 1×1 specular map makes the parameter `true`. Clearing it returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the specular map is still empty. `specularColorMap` stays later.

`specularColorMap` has landed. Shader, Raw, and Physical start `false`. Giving Shader a 1×1 specular color map makes the parameter `true`. Clearing it returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the specular color map is still empty. `specularIntensityMap` stays later.

`specularIntensityMap` has landed. Shader, Raw, and Physical start `false`. Giving Shader a 1×1 specular intensity map makes the parameter `true`. Clearing it returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the specular intensity map is still empty. `transmission` stays later.

`transmission` has landed. Shader, Raw, and Physical start `false`. A negative value stays `false`. Setting Shader to `0.25` makes the parameter `true`. Setting it back to `0` returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while transmission is still `0`. `transmissionMap` stays later.

`transmissionMap` has landed. Shader, Raw, and Physical start `false`. A 1×1 transmission map with strength `0` stays `false`. Strength `0.25` with that map makes the parameter `true`. Returning the strength to `0` makes it `false` while the map stays. Clearing the map with strength `0.25` keeps it `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while both are still unset. `thicknessMap` stays later.

`thicknessMap` has landed. Shader, Raw, and Physical start `false`. A 1×1 thickness map with transmission `0` stays `false`. Transmission `0.25` with that map makes the parameter `true`. Returning transmission to `0` makes it `false` while the map stays. Clearing the map with transmission `0.25` keeps it `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while both are still unset. `gradientMap` stays later.

`gradientMap` has landed. Shader, Raw, and Toon start `false`. Giving Shader a 1×1 gradient map makes the parameter `true`. Clearing it returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the gradient map is still empty. `opaque` stays later.

`opaque` has landed. Shader, Raw, and Basic start `true`. Turning transparency on makes the parameter `false`. Additive blending also makes it `false`. Alpha to coverage makes it `false`. Restoring an opaque, normally blended material with coverage off returns `true`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while those three fields are still at their defaults. `alphaMap` stays later.

`alphaMap` has landed. Shader, Raw, and Basic start `false`. Giving Shader a 1×1 alpha map makes the parameter `true`. Clearing it returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the alpha map is still empty. `alphaTest` stays later.

`alphaTest` has landed. Shader, Raw, and Basic start `false`. A negative value stays `false`. Setting Shader to `0.25` makes the parameter `true`. Setting it back to `0` returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while alpha test is still `0`. `alphaHash` stays later.

`alphaHash` has landed. Shader, Raw, and Basic start `false`. Turning the flag on makes the parameter `true`. Turning it off returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while alpha hash is still off. `combine` stays later.

`combine` has landed. Shader, Raw, and Phong start at multiply, integer `0`. Setting Shader to mix stores `1`. Setting it to add stores `2`. Setting it back to multiply stores `0`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while combine is still multiply. `mapUv` stays later.

`mapUv` has landed. Shader, Raw, and Basic start at `false`. Giving Shader a 1×1 color map on channel `0` returns `uv`. Channel `1` returns `uv1`. Channel `2` returns `uv2`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the color map is still empty. `aoMapUv` stays later.

`aoMapUv` has landed. Shader, Raw, and Standard start at `false`. Giving Shader a 1×1 ao map on channel `0` returns `uv`. Channel `1` returns `uv1`. Channel `2` returns `uv2`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the ao map is still empty. `lightMapUv` stays later.

`lightMapUv` has landed. Shader, Raw, and Lambert start at `false`. Giving Shader a 1×1 light map on channel `0` returns `uv`. Channel `1` returns `uv1`. Channel `2` returns `uv2`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the light map is still empty. `bumpMapUv` stays later.

`bumpMapUv` has landed. Shader, Raw, and Phong start at `false`. Giving Shader a 1×1 bump map on channel `0` returns `uv`. Turning `wireframe` on returns `false` while the map stays. Turning it off and setting channel `1` returns `uv1`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the bump map is still empty. `normalMapUv` stays later.

`normalMapUv` has landed. Shader, Raw, and Standard start at `false`. Giving Shader a 1×1 normal map on channel `0` returns `uv`. Channel `1` returns `uv1`. Channel `2` returns `uv2`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the normal map is still empty. `displacementMapUv` stays later.

`displacementMapUv` has landed. Shader, Raw, and Lambert start at `false`. Giving Shader a 1×1 displacement map on channel `0` returns `uv`. Channel `1` returns `uv1`. Channel `2` returns `uv2`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the displacement map is still empty. `emissiveMapUv` stays later.

`emissiveMapUv` has landed. Shader, Raw, and Standard start at `false`. Giving Shader a 1×1 emissive map on channel `0` returns `uv`. Channel `1` returns `uv1`. Channel `2` returns `uv2`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the emissive map is still empty. `metalnessMapUv` stays later.

`metalnessMapUv` has landed. Shader, Raw, and Standard start at `false`. Giving Shader a 1×1 metalness map on channel `0` returns `uv`. Channel `1` returns `uv1`. Channel `2` returns `uv2`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the metalness map is still empty. `roughnessMapUv` stays later.

`roughnessMapUv` has landed. Shader, Raw, and Standard start at `false`. Giving Shader a 1×1 roughness map on channel `0` returns `uv`. Channel `1` returns `uv1`. Channel `2` returns `uv2`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the roughness map is still empty. `anisotropyMapUv` stays later.

`anisotropyMapUv` has landed. Shader, Raw, and Physical start at `false`. A 1×1 anisotropy map with strength `0` stays `false`. Strength `0.25` on channel `0` returns `uv`. Returning the strength to `0` returns `false` while the map stays. Strength `0.25` on channel `1` returns `uv1`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while both are still unset. `clearcoatMapUv` stays later.

`clearcoatMapUv` has landed. Shader, Raw, and Physical start at `false`. A 1×1 clearcoat map with clearcoat `0` stays `false`. Clearcoat `0.25` on channel `0` returns `uv`. Returning clearcoat to `0` returns `false` while the map stays. Clearcoat `0.25` on channel `1` returns `uv1`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while both are still unset. `clearcoatNormalMapUv` stays later.

`clearcoatNormalMapUv` has landed. Shader, Raw, and Physical start at `false`. A 1×1 clearcoat normal map with clearcoat `0` stays `false`. Clearcoat `0.25` on channel `0` returns `uv`. Returning clearcoat to `0` returns `false` while the map stays. Clearcoat `0.25` on channel `1` returns `uv1`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while both are still unset. `clearcoatRoughnessMapUv` stays later.

`clearcoatRoughnessMapUv` has landed. Shader, Raw, and Physical start at `false`. A 1×1 clearcoat roughness map with clearcoat `0` stays `false`. Clearcoat `0.25` on channel `0` returns `uv`. Returning clearcoat to `0` returns `false` while the map stays. Clearcoat `0.25` on channel `1` returns `uv1`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while both are still unset. `iridescenceMapUv` stays later.

`iridescenceMapUv` has landed. Shader, Raw, and Physical start at `false`. A 1×1 iridescence map with iridescence `0` stays `false`. Iridescence `0.25` on channel `0` returns `uv`. Returning iridescence to `0` returns `false` while the map stays. Iridescence `0.25` on channel `1` returns `uv1`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while both are still unset. `iridescenceThicknessMapUv` stays later.

`iridescenceThicknessMapUv` has landed. Shader, Raw, and Physical start at `false`. A 1×1 iridescence thickness map with iridescence `0` stays `false`. Iridescence `0.25` on channel `0` returns `uv`. Returning iridescence to `0` returns `false` while the map stays. Iridescence `0.25` on channel `1` returns `uv1`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while both are still unset. `sheenColorMapUv` stays later.

`sheenColorMapUv` has landed. Shader, Raw, and Physical start at `false`. A 1×1 sheen color map with sheen `0` stays `false`. Sheen `0.25` on channel `0` returns `uv`. Returning sheen to `0` returns `false` while the map stays. Sheen `0.25` on channel `1` returns `uv1`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while both are still unset. `sheenRoughnessMapUv` stays later.

`sheenRoughnessMapUv` has landed. Shader, Raw, and Physical start at `false`. A 1×1 sheen roughness map with sheen `0` stays `false`. Sheen `0.25` on channel `0` returns `uv`. Returning sheen to `0` returns `false` while the map stays. Sheen `0.25` on channel `1` returns `uv1`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while both are still unset. `specularMapUv` stays later.

`specularMapUv` has landed. Shader, Raw, and Lambert start at `false`. Giving Shader a 1×1 specular map on channel `0` returns `uv`. Channel `1` returns `uv1`. Channel `2` returns `uv2`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the specular map is still empty. `specularColorMapUv` stays later.

`specularColorMapUv` has landed. Shader, Raw, and Physical start at `false`. Giving Shader a 1×1 specular color map on channel `0` returns `uv`. Channel `1` returns `uv1`. Channel `2` returns `uv2`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the specular color map is still empty. `specularIntensityMapUv` stays later.

`specularIntensityMapUv` has landed. Shader, Raw, and Physical start at `false`. Giving Shader a 1×1 specular intensity map on channel `0` returns `uv`. Channel `1` returns `uv1`. Channel `2` returns `uv2`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the specular intensity map is still empty. `transmissionMapUv` stays later.

`transmissionMapUv` has landed. Shader, Raw, and Physical start at `false`. A 1×1 transmission map with transmission `0` stays `false`. Transmission `0.25` on channel `0` returns `uv`. Returning transmission to `0` returns `false` while the map stays. Transmission `0.25` on channel `1` returns `uv1`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while both are still unset. `thicknessMapUv` stays later.

`thicknessMapUv` has landed. Shader, Raw, and Physical start at `false`. A 1×1 thickness map with transmission `0` stays `false`. Transmission `0.25` on channel `0` returns `uv`. Returning transmission to `0` returns `false` while the map stays. Transmission `0.25` on channel `1` returns `uv1`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while both are still unset. `alphaMapUv` stays later.

`alphaMapUv` has landed. Shader, Raw, and Basic start at `false`. Giving Shader a 1×1 alpha map on channel `0` returns `uv`. Channel `1` returns `uv1`. Channel `2` returns `uv2`. Clearing the map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the alpha map is still empty. `vertexTangents` stays later.

`vertexTangents` has landed. Shader, Raw, and Physical start at `false` when the geometry has no tangent. A tangent with neither a normal map nor anisotropy stays `false`. A 1×1 normal map without a tangent stays `false`. The same map with a tangent returns `true`. Clearing the map and setting anisotropy to `0.25` with a tangent returns `true`. Anisotropy `0` without a map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the normal map and anisotropy are still unset. `vertexNormals` stays later.

`vertexNormals` has landed. Shader, Raw, and Basic start at `false` when the geometry has no normal. Passing a normal attribute returns `true`. Passing none returns `false`. Turning on `vertex_colors` does not change that result. The vertex prefix stays `1608` and the fragment prefix stays `2041` while `vertex_colors` is still off. `vertexColors` stays later.

`vertexColors` has landed. Shader, Raw, and Basic start at `false`. Setting `vertex_colors` to `true` returns `true`. Setting it back to `false` returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while `vertex_colors` is still off. `vertexAlphas` stays later.

`vertexAlphas` has landed. Shader, Raw, and Basic start at `false`. Turning on `vertex_colors` without a four-component color attribute stays `false`. Both together return `true`. Turning `vertex_colors` back off returns `false` while the attribute stays. The vertex prefix stays `1608` and the fragment prefix stays `2041` while `vertex_colors` is still off. `pointsUvs` stays later.

`pointsUvs` has landed. Shader, Raw, and Basic start at `false`. A points object with a uv attribute but neither a color map nor an alpha map stays `false`. A 1×1 color map without that points uv stays `false`. The same map with the points uv returns `true`. Clearing the color map and setting a 1×1 alpha map with the points uv returns `true`. Clearing the alpha map returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while both maps are still empty. `fog` stays later.

`fog` has landed. Shader, Raw, and Basic start at `false` when the scene has no fog. Passing scene fog returns `true`. Turning the material `fog` flag on does not make a fogless scene true. Turning the material flag off does not clear a scene that has fog. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the material flag is still at its default. `useFog` stays later.

`useFog` has landed. Shader and Raw start at `false`. Basic starts at `true`. Setting Shader `fog` to `true` returns `true`. Setting it back to `false` returns `false`. A scene with fog does not turn the material flag on. The vertex prefix stays `1608` and the fragment prefix stays `2041` while Shader `fog` is still off. `fogExp2` stays later.

`fogExp2` has landed. Shader, Raw, and Basic start at `false`. Scene fog that is not exponential stays `false`. An exponential flag without scene fog stays `false`. Both together return `true`. Turning the material `fog` flag on does not make a fogless scene exponential. Turning it off does not clear exponential scene fog. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the material flag is still off. `flatShading` stays later.

`flatShading` has landed. Shader, Raw, Basic, and Toon start at `false`. Lambert, Phong, Standard, and Physical start at `true` when the geometry has no normal and the normal map is empty. Giving Lambert a normal attribute returns `false`. A normal map does the same. Shader with `flat_shading` on returns `true`, and a wireframe returns `false`. Lambert with `flat_shading` on and a normal attribute stays `false` while wireframe is on, then returns `true` when the wireframe is off. The vertex prefix stays `1608` and the fragment prefix stays `2041` while Shader `flat_shading` and `wireframe` are still off. `sizeAttenuation` stays later.

`sizeAttenuation` has landed. Shader, Raw, and Basic stay `false` because mesh materials have no such field. Points and Sprite start at `true`. Turning the points flag off returns `false`, and turning it back on returns `true`. Turning the sprite flag off returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `logarithmicDepthBuffer` stays later.

`logarithmicDepthBuffer` has landed. Shader, Raw, and Basic start at `false`. Passing the renderer flag returns `true`. Passing it off returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `reversedDepthBuffer` stays later.

`reversedDepthBuffer` has landed. Shader, Raw, and Basic start at `false`. Passing the renderer flag returns `true`. Passing it off returns `false`. Turning on the logarithmic depth flag does not turn this one on. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `skinning` stays later.

`skinning` has landed. Shader, Raw, and Basic start at `false`. Passing a skinned mesh returns `true`. Passing a mesh that is not skinned returns `false`. Turning on the reversed depth flag does not turn skinning on. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `hasPositionAttribute` stays later.

`hasPositionAttribute` has landed. Shader, Raw, and Basic start at `false` when the geometry has no position attribute. Passing a position attribute returns `true`. Passing none returns `false`. Turning on skinning does not invent a position attribute. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `morphTargets` stays later.

`morphTargets` has landed. Shader, Raw, and Basic start at `false` when the geometry has no position morph attribute. Passing one returns `true`. Passing none returns `false`. A position attribute does not count as a morph target. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `morphNormals` stays later.

`morphNormals` has landed. Shader, Raw, and Basic start at `false` when the geometry has no normal morph attribute. Passing one returns `true`. Passing none returns `false`. A position morph target does not count as a normal morph. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `morphColors` stays later.

`morphColors` has landed. Shader, Raw, and Basic start at `false` when the geometry has no color morph attribute. Passing one returns `true`. Passing none returns `false`. A normal morph target does not count as a color morph. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `morphTargetsCount` stays later.

`morphTargetsCount` has landed. Shader, Raw, and Basic start at `0`. A position morph list of `3` wins over a normal list of `2` and a color list of `4`. With no position list, a normal list of `2` is used. With only a color list of `4`, that count is used. An empty position list counts as present and returns `0` instead of falling through. A color morph flag without a list stays `0`. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `morphTextureStride` stays later.

`morphTextureStride` has landed. Shader, Raw, and Basic start at `0`. A position morph attribute returns `1`. Adding a normal morph attribute returns `2`. Adding a color morph attribute returns `3`. Color alone is `3`, and normal alone is `2`. A position morph count does not set the stride by itself. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `numSunLights` stays later.

`numSunLights` has landed. Shader, Raw, and Basic start at `0`. Passing two sun lights returns `2`. Passing none returns `0`. A color morph attribute does not add a sun light. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `numDirLights` stays later.

`numDirLights` has landed. Shader, Raw, and Basic start at `0`. Passing three directional lights returns `3`. Passing none returns `0`. Two sun lights do not count as directional lights. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `numPointLights` stays later.

`numPointLights` has landed. Shader, Raw, and Basic start at `0`. Passing four point lights returns `4`. Passing none returns `0`. Three directional lights do not count as point lights. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `numSpotLights` stays later.

`numSpotLights` has landed. Shader, Raw, and Basic start at `0`. Passing two spot lights returns `2`. Passing none returns `0`. Four point lights do not count as spot lights. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `numSpotLightMaps` stays later.

`numSpotLightMaps` has landed. Shader, Raw, and Basic start at `0`. Passing one spot light map returns `1`. Passing none returns `0`. Two spot lights do not count as spot light maps. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `numRectAreaLights` stays later.

`numRectAreaLights` has landed. Shader, Raw, and Basic start at `0`. Passing two rect area lights returns `2`. Passing none returns `0`. One spot light map does not count as a rect area light. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `numHemiLights` stays later.

`numHemiLights` has landed. Shader, Raw, and Basic start at `0`. Passing one hemisphere light returns `1`. Passing none returns `0`. Two rect area lights do not count as hemisphere lights. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `numSunLightShadows` stays later.

`numSunLightShadows` has landed. Shader, Raw, and Basic start at `0`. Passing one sun light shadow returns `1`. Passing none returns `0`. Two sun lights do not count as sun light shadows. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `numDirLightShadows` stays later.

`numDirLightShadows` has landed. Shader, Raw, and Basic start at `0`. Passing two directional light shadows returns `2`. Passing none returns `0`. Three directional lights do not count as directional light shadows. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `numPointLightShadows` stays later.

`numPointLightShadows` has landed. Shader, Raw, and Basic start at `0`. Passing three point light shadows returns `3`. Passing none returns `0`. Four point lights do not count as point light shadows. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `numSpotLightShadows` stays later.

`numSpotLightShadows` has landed. Shader, Raw, and Basic start at `0`. Passing two spot light shadows returns `2`. Passing none returns `0`. Two spot lights do not count as spot light shadows. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `numSpotLightShadowsWithMaps` stays later.

`numSpotLightShadowsWithMaps` has landed. Shader, Raw, and Basic start at `0`. Passing one mapped spot light shadow returns `1`. Passing none returns `0`. Two spot light shadows do not count as mapped spot light shadows. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `numLightProbes` stays later.

`numLightProbes` has landed. Shader, Raw, and Basic start at `0`. Passing two light probes returns `2`. Passing none returns `0`. One mapped spot light shadow does not count as a light probe. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `numLightProbeGrids` stays later.

`numLightProbeGrids` has landed. Shader, Raw, and Basic start at `0`. Passing two light probe grids returns `2`. Passing none returns `0`. Two light probes do not count as light probe grids. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `numClippingPlanes` stays later.

`numClippingPlanes` has landed. Shader, Raw, and Basic start at `0`. Passing three clipping planes returns `3`. Passing none returns `0`. Two light probe grids do not count as clipping planes. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `numClipIntersection` stays later.

`numClipIntersection` has landed. Shader, Raw, and Basic start at `0`. Passing two clip intersections returns `2`. Passing none returns `0`. Three clipping planes do not count as clip intersections. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `dithering` stays later.

`dithering` has landed. Shader, Raw, and Basic start at `false`. Setting Shader `dithering` to `true` returns `true`. Setting it back to `false` returns `false`. Two clip intersections do not turn dithering on. The vertex prefix stays `1608` and the fragment prefix stays `2041` while `dithering` is still off. `shadowMapEnabled` stays later.

`shadowMapEnabled` has landed. Shader, Raw, and Basic start at `false`. The renderer flag without a shadow stays `false`. A shadow without the renderer flag stays `false`. Both together return `true`. Turning on `dithering` does not enable shadow maps. The vertex prefix stays `1608` and the fragment prefix stays `2041` while `dithering` is still off. `shadowMapType` stays later.

`shadowMapType` has landed. Shader, Raw, and Basic start at `0`. Passing type `1` returns `1`. Passing type `3` returns `3`. Enabling shadow maps does not change the type. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `toneMapping` stays later.

`toneMapping` has landed. Shader, Raw, and Basic start at `No`. Passing `Linear` returns `Linear`. Passing `ACES` returns `ACES`. Turning `tone_mapped` off returns `No`. A render target returns `No`. Shadow map type `3` does not change the mapping. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `decodeVideoTexture` stays later.

`decodeVideoTexture` has landed. Shader, Raw, and Basic start at `false`. A video sRGB flag without a map stays `false`. A map alone stays `false`. A video map without sRGB transfer stays `false`. A map with both flags returns `true`. `Linear` tone mapping does not turn it on. The vertex prefix stays `1608` and the fragment prefix stays `2041` before the map is set. `decodeVideoTextureEmissive` stays later.

`decodeVideoTextureEmissive` has landed. Shader, Raw, and Basic start at `false`. A video sRGB flag without an emissive map stays `false`. A color map with both flags does not count. An emissive map alone stays `false`. A video emissive map without sRGB transfer stays `false`. An emissive map with both flags returns `true`. The vertex prefix stays `1608` and the fragment prefix stays `2041` before either map is set. `premultipliedAlpha` stays later.

`premultipliedAlpha` has landed. Shader, Raw, and Basic start at `false`. Setting Shader `premultiplied_alpha` to `true` returns `true`. Setting it back to `false` returns `false`. A video sRGB flag without an emissive map does not turn it on. The vertex prefix stays `1608` and the fragment prefix stays `2041` while `premultiplied_alpha` is still off. `doubleSided` stays later.

`doubleSided` has landed. Shader, Raw, and Basic start at `false`. `Back` stays `false`. `Double` returns `true`. Setting the side back to `Front` returns `false`. Turning on `premultiplied_alpha` does not make it double sided. The vertex prefix stays `1608` and the fragment prefix stays `2041` while `side` is still `Front`. `flipSided` stays later.

`flipSided` has landed. Shader, Raw, and Basic start at `false`. `Front` stays `false`. `Double` stays `false`. `Back` returns `true`. Setting the side back to `Front` returns `false`. The vertex prefix stays `1608` and the fragment prefix stays `2041` while `side` is still `Front`. `useDepthPacking` stays later.

`useDepthPacking` has landed. Shader, Raw, and Basic start at `true` because `depth_packing` is `Basic` (`3200`). `RGBA` stays `true`. Setting `side` to `Back` does not turn it off. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `depthPacking` stays later.

`depthPacking` has landed. Shader, Raw, and Basic start at `3200`. `RGBA` returns `3201`. `RGB` returns `3202`. `RG` returns `3203`. Setting it back to `Basic` returns `3200`. `Back` keeps the packing at `3200` and leaves `useDepthPacking` on. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `index0AttributeName` stays later.

`index0AttributeName` has landed. Shader, Raw, and Basic start at `None`. Setting Shader to `position` returns that name. Clearing it returns `None`. `RGBA` depth packing does not invent a name. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the name is still empty. `extensionClipCullDistance` stays later.

`extensionClipCullDistance` has landed. Shader, Raw, and Basic start at `false`. The extension without the material flag stays `false`. The material flag without the extension stays `false`. Both together return `true`. An `index0` name does not turn it on. The vertex prefix stays `1608` and the fragment prefix stays `2041` while `clip_cull_distance` is still off. `extensionMultiDraw` stays later.

`extensionMultiDraw` has landed. Shader, Raw, and Basic start at `false`. Clip cull distance does not turn it on. A batched mesh without the extension stays `false`. The material flag without the extension stays `false`. The flag and the extension together return `true`. A batched mesh with the extension returns `true` while `multi_draw` is off. The vertex prefix stays `1608` and the fragment prefix stays `2041` while `multi_draw` is still off. `rendererExtensionParallelShaderCompile` stays later.

`rendererExtensionParallelShaderCompile` has landed. Shader, Raw, and Basic start at `false`. Passing the extension returns `true`. Passing it off returns `false`. A batched mesh with the multi-draw extension does not turn parallel compile on. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `customProgramCacheKey` stays later.

`customProgramCacheKey` has landed. Shader, Raw, and Basic start at `""`. Passing `custom` returns that string. Omitting it returns `""`. Parallel shader compile does not change the key. The vertex prefix stays `1608` and the fragment prefix stays `2041`. `vertexUv1s` stays later.

`vertexUv1s` has landed. Shader, Raw, and Basic start at `false`. A color map on channel `0` stays `false`. Channel `2` stays `false`. Channel `1` returns `true`. Clearing the map returns `false`. An anisotropy map on channel `1` stays `false` until `anisotropy` is above `0`. A custom program cache key does not turn it on. The vertex prefix stays `1608` and the fragment prefix stays `2041` while no channel-`1` map is active. `vertexUv2s` stays later.

`vertexUv2s` has landed. Shader, Raw, and Basic start at `false`. A color map on channel `0` stays `false`. Channel `1` stays `false` while `vertexUv1s` is `true`. Channel `3` stays `false`. Channel `2` returns `true`. Clearing the map returns `false`. An anisotropy map on channel `2` stays `false` until `anisotropy` is above `0`. A custom program cache key does not turn it on. The vertex prefix stays `1608` and the fragment prefix stays `2041` while no channel-`2` map is active. `vertexUv3s` stays later.

`vertexUv3s` has landed. Shader, Raw, and Basic start at `false`. A color map on channel `0` stays `false`. Channel `1` stays `false` while `vertexUv1s` is `true`. Channel `2` stays `false` while `vertexUv2s` is `true`. Channel `4` stays `false`. Channel `3` returns `true`. Clearing the map returns `false`. An anisotropy map on channel `3` stays `false` until `anisotropy` is above `0`. A custom program cache key does not turn it on. The vertex prefix stays `1608` and the fragment prefix stays `2041` while no channel-`3` map is active. `shaderID` stays later.

`shaderID` has landed. Shader and Raw stay at `None`. Basic is `basic`, Lambert is `lambert`, Phong is `phong`, Toon is `toon`, and Standard and Physical are both `physical`. Matcap is `matcap`, Normal is `normal`, Depth is `depth`, Distance is `distance`, and Shadow is `shadow`. Points is `points`, Sprite is `sprite`, LineBasic is `basic`, and LineDashed is `dashed`. Renaming Shader or Basic leaves the id unchanged. A channel-`3` color map turns `vertexUv3s` on and leaves the Shader id empty. The vertex prefix stays `1608` and the fragment prefix stays `2041` while the name is still empty. `USE_FOG` stays later.

`USE_FOG` has landed. A Shader material with `fog` off adds nothing, even when the scene has fog. Turning `fog` on without scene fog adds nothing. Both together write `#define USE_FOG` and a newline, `16` characters, on both prefixes. The vertex string grows from `1608` to `1624`. The fragment string grows from `2041` to `2057`. A color map puts `USE_MAP` after that line, so the vertex string is `1658` and the fragment string is `2073`. Turning `fog` back off leaves the map lengths at `1642` and `2057`. `fogExp2` does not add `FOG_EXP2`. A raw material stays at `92` and `61`. A Basic material stays `""`. `FOG_EXP2` stays later.

`FOG_EXP2` has landed. A Shader material with `fog` off adds nothing, even when the scene fog is exponential. Turning `fog` on and passing only exponential fog writes `#define FOG_EXP2` and a newline, `17` characters, on both prefixes. The vertex string grows from `1608` to `1625`. The fragment string grows from `2041` to `2058`. Scene fog without the exponential flag still writes only `USE_FOG`, so those lengths stay `1624` and `2057`. Both together write `USE_FOG` then `FOG_EXP2`, `33` characters. The vertex string is `1641` and the fragment string is `2074`. A color map puts `USE_MAP` after those lines, so the vertex string is `1675` and the fragment string is `2090`. Turning `fog` back off leaves the map lengths at `1642` and `2057`. A raw material stays at `92` and `61`. A Basic material stays `""`. `ALPHA_TO_COVERAGE` stays later.

## Checklist

| status | phase | item | packages |
|---|---|---|---|
| planned | 7 | `ShaderMaterial` vertex prefix | `materials` |
| planned | 7 | `ShaderMaterial` fragment prefix | `materials` |
| planned | 7 | `ShaderMaterial` GLSL3 fragment defines | `materials` |
| planned | 7 | Shader `#version 300 es` | `materials` |
| planned | 7 | Shader vertex GLSL3 defines | `materials` |
| planned | 7 | Shader precision prefix | `materials` |
| planned | 7 | `SHADER_TYPE` | `materials` |
| planned | 7 | `SHADER_NAME` | `materials` |
| planned | 7 | Shader custom defines | `materials` |
| planned | 7 | `USE_MAP` | `materials` |
| planned | 7 | `USE_ENVMAP` | `materials` |
| planned | 7 | `ENVMAP_MODE` | `materials` |
| planned | 7 | `ENVMAP_TYPE` | `materials` |
| planned | 7 | `ENVMAP_BLENDING` | `materials` |
| planned | 7 | `USE_LIGHTMAP` | `materials` |
| planned | 7 | `USE_AOMAP` | `materials` |
| planned | 7 | `USE_BUMPMAP` | `materials` |
| planned | 7 | `USE_NORMALMAP` | `materials` |
| planned | 7 | `USE_NORMALMAP_TANGENTSPACE` | `materials` |
| planned | 7 | `USE_NORMALMAP_OBJECTSPACE` | `materials` |
| planned | 7 | `USE_DISPLACEMENTMAP` | `materials` |
| planned | 7 | `USE_EMISSIVEMAP` | `materials` |
| planned | 7 | `USE_ANISOTROPY` | `materials` |
| planned | 7 | `USE_ANISOTROPYMAP` | `materials` |
| planned | 7 | `USE_CLEARCOAT` | `materials` |
| planned | 7 | `USE_CLEARCOATMAP` | `materials` |
| planned | 7 | `USE_CLEARCOAT_ROUGHNESSMAP` | `materials` |
| planned | 7 | `USE_CLEARCOAT_NORMALMAP` | `materials` |
| planned | 7 | `USE_IRIDESCENCEMAP` | `materials` |
| planned | 7 | `USE_IRIDESCENCE_THICKNESSMAP` | `materials` |
| planned | 7 | `USE_SPECULARMAP` | `materials` |
| planned | 7 | `USE_SPECULAR_COLORMAP` | `materials` |
| planned | 7 | `USE_SPECULAR_INTENSITYMAP` | `materials` |
| planned | 7 | `USE_ROUGHNESSMAP` | `materials` |
| planned | 7 | `USE_METALNESSMAP` | `materials` |
| planned | 7 | `USE_ALPHAMAP` | `materials` |
| planned | 7 | `USE_ALPHAHASH` | `materials` |
| planned | 7 | `USE_TRANSMISSION` | `materials` |
| planned | 7 | `USE_TRANSMISSIONMAP` | `materials` |
| planned | 7 | `USE_THICKNESSMAP` | `materials` |
| planned | 7 | `USE_SHEEN_COLORMAP` | `materials` |
| planned | 7 | `USE_SHEEN_ROUGHNESSMAP` | `materials` |
| planned | 7 | `MAP_UV` | `materials` |
| planned | 7 | `ALPHAMAP_UV` | `materials` |
| planned | 7 | `LIGHTMAP_UV` | `materials` |
| planned | 7 | `AOMAP_UV` | `materials` |
| planned | 7 | `EMISSIVEMAP_UV` | `materials` |
| planned | 7 | `BUMPMAP_UV` | `materials` |
| planned | 7 | `NORMALMAP_UV` | `materials` |
| planned | 7 | `DISPLACEMENTMAP_UV` | `materials` |
| planned | 7 | `METALNESSMAP_UV` | `materials` |
| planned | 7 | `ROUGHNESSMAP_UV` | `materials` |
| planned | 7 | `ANISOTROPYMAP_UV` | `materials` |
| planned | 7 | `CLEARCOATMAP_UV` | `materials` |
| planned | 7 | `CLEARCOAT_NORMALMAP_UV` | `materials` |
| planned | 7 | `CLEARCOAT_ROUGHNESSMAP_UV` | `materials` |
| planned | 7 | `IRIDESCENCEMAP_UV` | `materials` |
| planned | 7 | `IRIDESCENCE_THICKNESSMAP_UV` | `materials` |
| planned | 7 | `SHEEN_COLORMAP_UV` | `materials` |
| planned | 7 | `SHEEN_ROUGHNESSMAP_UV` | `materials` |
| planned | 7 | `SPECULARMAP_UV` | `materials` |
| planned | 7 | `SPECULAR_COLORMAP_UV` | `materials` |
| planned | 7 | `SPECULAR_INTENSITYMAP_UV` | `materials` |
| planned | 7 | `TRANSMISSIONMAP_UV` | `materials` |
| planned | 7 | `THICKNESSMAP_UV` | `materials` |
| planned | 7 | `USE_TANGENT` | `materials` |
| planned | 7 | `HAS_NORMAL` | `materials` |
| planned | 7 | `USE_COLOR` | `materials` |
| planned | 7 | `USE_COLOR_ALPHA` | `materials` |
| planned | 7 | `USE_UV1` | `materials` |
| planned | 7 | `USE_UV2` | `materials` |
| planned | 7 | `USE_UV3` | `materials` |
| planned | 7 | `USE_POINTS_UV` | `materials` |
| planned | 7 | `FLAT_SHADED` | `materials` |
| planned | 7 | `USE_SKINNING` | `materials` |
| planned | 7 | `USE_MORPHTARGETS` | `materials` |
| planned | 7 | `USE_MORPHNORMALS` | `materials` |
| planned | 7 | `USE_MORPHCOLORS` | `materials` |
| planned | 7 | `MORPHTARGETS_TEXTURE_STRIDE` | `materials` |
| planned | 7 | `MORPHTARGETS_COUNT` | `materials` |
| planned | 7 | `DOUBLE_SIDED` | `materials` |
| planned | 7 | `FLIP_SIDED` | `materials` |
| planned | 7 | `USE_SHADOWMAP` | `materials` |
| planned | 7 | `SHADOWMAP_TYPE_BASIC` | `materials` |
| planned | 7 | `SHADOWMAP_TYPE_PCF` | `materials` |
| planned | 7 | `SHADOWMAP_TYPE_VSM` | `materials` |
| planned | 7 | `USE_SIZEATTENUATION` | `materials` |
| planned | 7 | `USE_LIGHT_PROBES` | `materials` |
| planned | 7 | `USE_LOGARITHMIC_DEPTH_BUFFER` | `materials` |
| planned | 7 | `USE_REVERSED_DEPTH_BUFFER` | `materials` |
| planned | 7 | `TONE_MAPPING` | `materials` |
| planned | 7 | `tonemapping_pars_fragment` | `materials` |
| planned | 7 | `getToneMappingFunction` | `materials` |
| planned | 7 | `DITHERING` | `materials` |
| planned | 7 | `OPAQUE` | `materials` |
| planned | 7 | `colorspace_pars_fragment` | `materials` |
| planned | 7 | `getTexelEncodingFunction` | `materials` |
| planned | 7 | `getLuminanceFunction` | `materials` |
| planned | 7 | `DEPTH_PACKING` | `materials` |
| planned | 7 | `prefixFragment` newline | `materials` |
| planned | 7 | `USE_GRADIENTMAP` | `materials` |
| planned | 7 | `PREMULTIPLIED_ALPHA` | `materials` |
| planned | 7 | `USE_LIGHT_PROBES_GRID` | `materials` |
| planned | 7 | `DECODE_VIDEO_TEXTURE` | `materials` |
| planned | 7 | `DECODE_VIDEO_TEXTURE_EMISSIVE` | `materials` |
| planned | 7 | `resolveIncludes` | `materials` |
| planned | 7 | `replaceLightNums` | `materials` |
| planned | 7 | `replaceClippingPlaneNums` | `materials` |
| planned | 7 | `unrollLoops` | `materials` |
| planned | 7 | `getProgramCacheKey` | `materials` |
| planned | 7 | `getUniforms` | `materials` |
| planned | 7 | `acquireProgram` | `materials` |
| planned | 7 | `releaseProgram` | `materials` |
| planned | 7 | `releaseShaderCache` | `materials` |
| planned | 7 | `dispose` | `materials` |
| planned | 7 | `getVertexShaderStage` | `materials` |
| planned | 7 | `getFragmentShaderStage` | `materials` |
| planned | 7 | `customVertexShaderID` | `materials` |
| planned | 7 | `customFragmentShaderID` | `materials` |
| planned | 7 | `shaderType` | `materials` |
| planned | 7 | `shaderName` | `materials` |
| planned | 7 | `vertexShader` | `materials` |
| planned | 7 | `fragmentShader` | `materials` |
| planned | 7 | `defines` | `materials` |
| planned | 7 | `isRawShaderMaterial` | `materials` |
| planned | 7 | `glslVersion` | `materials` |
| planned | 7 | `precision` | `materials` |
| planned | 7 | `getMaxPrecision` | `materials` |
| planned | 7 | `batching` | `materials` |
| planned | 7 | `batchingColor` | `materials` |
| planned | 7 | `instancing` | `materials` |
| planned | 7 | `instancingColor` | `materials` |
| planned | 7 | `instancingMorph` | `materials` |
| planned | 7 | `outputColorSpace` | `materials` |
| planned | 7 | `alphaToCoverage` | `materials` |
| planned | 7 | `map` | `materials` |
| planned | 7 | `matcap` | `materials` |
| planned | 7 | `envMap` | `materials` |
| planned | 7 | `envMapMode` | `materials` |
| planned | 7 | `envMapCubeUVHeight` | `materials` |
| planned | 7 | `aoMap` | `materials` |
| planned | 7 | `lightMap` | `materials` |
| planned | 7 | `bumpMap` | `materials` |
| planned | 7 | `normalMap` | `materials` |
| planned | 7 | `normalMapObjectSpace` | `materials` |
| planned | 7 | `normalMapTangentSpace` | `materials` |
| planned | 7 | `packedNormalMap` | `materials` |
| planned | 7 | `displacementMap` | `materials` |
| planned | 7 | `emissiveMap` | `materials` |
| planned | 7 | `metalnessMap` | `materials` |
| planned | 7 | `roughnessMap` | `materials` |
| planned | 7 | `anisotropy` | `materials` |
| planned | 7 | `anisotropyMap` | `materials` |
| planned | 7 | `clearcoat` | `materials` |
| planned | 7 | `clearcoatMap` | `materials` |
| planned | 7 | `clearcoatNormalMap` | `materials` |
| planned | 7 | `clearcoatRoughnessMap` | `materials` |
| planned | 7 | `dispersion` | `materials` |
| planned | 7 | `retroreflection` | `materials` |
| planned | 7 | `iridescence` | `materials` |
| planned | 7 | `iridescenceMap` | `materials` |
| planned | 7 | `iridescenceThicknessMap` | `materials` |
| planned | 7 | `sheen` | `materials` |
| planned | 7 | `sheenColorMap` | `materials` |
| planned | 7 | `sheenRoughnessMap` | `materials` |
| planned | 7 | `specularMap` | `materials` |
| planned | 7 | `specularColorMap` | `materials` |
| planned | 7 | `specularIntensityMap` | `materials` |
| planned | 7 | `transmission` | `materials` |
| planned | 7 | `transmissionMap` | `materials` |
| planned | 7 | `thicknessMap` | `materials` |
| planned | 7 | `gradientMap` | `materials` |
| planned | 7 | `opaque` | `materials` |
| planned | 7 | `alphaMap` | `materials` |
| planned | 7 | `alphaTest` | `materials` |
| planned | 7 | `alphaHash` | `materials` |
| planned | 7 | `combine` | `materials` |
| planned | 7 | `mapUv` | `materials` |
| planned | 7 | `aoMapUv` | `materials` |
| planned | 7 | `lightMapUv` | `materials` |
| planned | 7 | `bumpMapUv` | `materials` |
| planned | 7 | `normalMapUv` | `materials` |
| planned | 7 | `displacementMapUv` | `materials` |
| planned | 7 | `emissiveMapUv` | `materials` |
| planned | 7 | `metalnessMapUv` | `materials` |
| planned | 7 | `roughnessMapUv` | `materials` |
| planned | 7 | `anisotropyMapUv` | `materials` |
| planned | 7 | `clearcoatMapUv` | `materials` |
| planned | 7 | `clearcoatNormalMapUv` | `materials` |
| planned | 7 | `clearcoatRoughnessMapUv` | `materials` |
| planned | 7 | `iridescenceMapUv` | `materials` |
| planned | 7 | `iridescenceThicknessMapUv` | `materials` |
| planned | 7 | `sheenColorMapUv` | `materials` |
| planned | 7 | `sheenRoughnessMapUv` | `materials` |
| planned | 7 | `specularMapUv` | `materials` |
| planned | 7 | `specularColorMapUv` | `materials` |
| planned | 7 | `specularIntensityMapUv` | `materials` |
| planned | 7 | `transmissionMapUv` | `materials` |
| planned | 7 | `thicknessMapUv` | `materials` |
| planned | 7 | `alphaMapUv` | `materials` |
| planned | 7 | `vertexTangents` | `materials` |
| planned | 7 | `vertexNormals` | `materials` |
| planned | 7 | `vertexColors` | `materials` |
| planned | 7 | `vertexAlphas` | `materials` |
| planned | 7 | `pointsUvs` | `materials` |
| planned | 7 | `fog` | `materials` |
| planned | 7 | `useFog` | `materials` |
| planned | 7 | `fogExp2` | `materials` |
| planned | 7 | `flatShading` | `materials` |
| planned | 7 | `sizeAttenuation` | `materials` |
| planned | 7 | `logarithmicDepthBuffer` | `materials` |
| planned | 7 | `reversedDepthBuffer` | `materials` |
| planned | 7 | `skinning` | `materials` |
| planned | 7 | `hasPositionAttribute` | `materials` |
| planned | 7 | `morphTargets` | `materials` |
| planned | 7 | `morphNormals` | `materials` |
| planned | 7 | `morphColors` | `materials` |
| planned | 7 | `morphTargetsCount` | `materials` |
| planned | 7 | `morphTextureStride` | `materials` |
| planned | 7 | `numSunLights` | `materials` |
| planned | 7 | `numDirLights` | `materials` |
| planned | 7 | `numPointLights` | `materials` |
| planned | 7 | `numSpotLights` | `materials` |
| planned | 7 | `numSpotLightMaps` | `materials` |
| planned | 7 | `numRectAreaLights` | `materials` |
| planned | 7 | `numHemiLights` | `materials` |
| planned | 7 | `numSunLightShadows` | `materials` |
| planned | 7 | `numDirLightShadows` | `materials` |
| planned | 7 | `numPointLightShadows` | `materials` |
| planned | 7 | `numSpotLightShadows` | `materials` |
| planned | 7 | `numSpotLightShadowsWithMaps` | `materials` |
| planned | 7 | `numLightProbes` | `materials` |
| planned | 7 | `numLightProbeGrids` | `materials` |
| planned | 7 | `numClippingPlanes` | `materials` |
| planned | 7 | `numClipIntersection` | `materials` |
| planned | 7 | `dithering` | `materials` |
| planned | 7 | `shadowMapEnabled` | `materials` |
| planned | 7 | `shadowMapType` | `materials` |
| planned | 7 | `toneMapping` | `materials` |
| planned | 7 | `decodeVideoTexture` | `materials` |
| planned | 7 | `decodeVideoTextureEmissive` | `materials` |
| planned | 7 | `premultipliedAlpha` | `materials` |
| planned | 7 | `doubleSided` | `materials` |
| planned | 7 | `flipSided` | `materials` |
| planned | 7 | `useDepthPacking` | `materials` |
| planned | 7 | `depthPacking` | `materials` |
| planned | 7 | `index0AttributeName` | `materials` |
| planned | 7 | `extensionClipCullDistance` | `materials` |
| planned | 7 | `extensionMultiDraw` | `materials` |
| planned | 7 | `rendererExtensionParallelShaderCompile` | `materials` |
| planned | 7 | `customProgramCacheKey` | `materials` |
| planned | 7 | `vertexUv1s` | `materials` |
| planned | 7 | `vertexUv2s` | `materials` |
| planned | 7 | `vertexUv3s` | `materials` |
| planned | 7 | `shaderID` | `materials` |
| planned | 7 | `USE_FOG` | `materials` |
| planned | 7 | `FOG_EXP2` | `materials` |
