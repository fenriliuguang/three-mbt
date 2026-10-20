# lights

Landed. Behavior notes are the phase log. The checklist is the upstream file map for this module.

## Phase

### 4. A second material

Ambient light, one directional light, and `MeshLambertMaterial` or a thin Standard. This is the point to add a minimal node set (uniform, attribute, varying, a few vector operations) or a small compiler that knows these two materials. `WGSLNodeBuilder.js` stays whole upstream.

This phase has landed. `nodes` builds `MeshBasicMaterial` and `MeshLambertMaterial` from uniform, attribute, varying, and a few vector operations, then emits WGSL. The renderer uploads positions and normals, and packs ambient light plus the first directional light into the same uniform buffer. `examples/lit` is the rotating Lambert cube. The window sample is `scripts/build-lit.sh`. Host playback of that component stays out of this pass.

## Behavior

Directional shadows have landed. The first visible directional light can cast one `depth32float` map from its orthographic shadow camera. Casters are opaque meshes with `cast_shadow`. Receivers multiply only the direct term by a 3×3 comparison sample. Ambient light is unchanged. `examples/shadow` is a Lambert cube on a plane. The window sample is `scripts/build-shadow.sh`. Host playback stays out of this pass.

A hemisphere light has landed. The first visible one adds indirect diffuse on Lambert and Standard. Sky and ground colors are multiplied by intensity. The direction is the light's world position, normalized, and defaults to `(0, 1, 0)`. A zero-length position stays zero, so the mix weight is 0.5. The weight is `dot(normal, direction) * 0.5 + 0.5`, then `mix(ground, sky, weight)`. It does not add specular and does not cast shadows. A second hemisphere light is ignored. The uniform block grows by 48 bytes to 672. Basic materials, points, and lines do not sample it.

## Checklist

| status | phase | item | packages |
|---|---|---|---|
| planned | 2, 4 | Light, AmbientLight, DirectionalLight from `src/lights` | `lights` |
| planned | 7 | Directional light shadows | `lights`, `renderer` |
| planned | 7 | point lights and glTF punctual point lights | `lights`, `renderer`, `gltf` |
| planned | 7 | spot lights and glTF punctual spot lights | `lights`, `renderer`, `gltf` |
| planned | 7 | hemisphere lights on Lambert and Standard diffuse | `lights`, `nodes`, `renderer` |
