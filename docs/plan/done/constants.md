# constants

Landed. Behavior notes are the phase log. The checklist is the upstream file map for this module.

## Behavior

`Material.normalMapType` has landed. A new Basic, Lambert, and Standard material each store tangent space, integer `0`. A Lambert material set to object space stores `1`. Another Lambert material stays at `0`. Copying onto a Basic material stores `1`. Setting the destination back to tangent space leaves the source at `1`. A new Standard material stays at `0`. The renderer still does not sample the normal map. `normalScale` stays later.

`Material.combine` has landed. A new Basic, Lambert, and Standard material each store multiply, integer `0`. A Lambert material set to mix stores `1`. Another Lambert material stays at `0`. Copying onto a Basic material stores `1`. Setting the destination to add leaves the source at `1`, and add is `2`. A new Standard material stays at `0`. The renderer still does not sample the environment map.

## Checklist

| status | phase | item | packages |
|---|---|---|---|
| planned | 2 onward | Enums from `src/constants.js` as they are used | `constants` |
| planned | 7 | `depthFunc` on meshes, points, and lines | `constants`, `materials`, `renderer` |
| planned | 7 | reversed depth on the color pass and the shadow pass | `constants`, `cameras`, `renderer` |
| planned | 7 | `Material.normalMapType` | `constants`, `materials` |
| planned | 7 | `Material.combine` | `constants`, `materials` |
