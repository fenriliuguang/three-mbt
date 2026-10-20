# nodes

Landed. Behavior notes are the phase log. The checklist is the upstream file map for this module.

## Phase

### 4. A second material

Ambient light, one directional light, and `MeshLambertMaterial` or a thin Standard. This is the point to add a minimal node set (uniform, attribute, varying, a few vector operations) or a small compiler that knows these two materials. `WGSLNodeBuilder.js` stays whole upstream.

This phase has landed. `nodes` builds `MeshBasicMaterial` and `MeshLambertMaterial` from uniform, attribute, varying, and a few vector operations, then emits WGSL. The renderer uploads positions and normals, and packs ambient light plus the first directional light into the same uniform buffer. `examples/lit` is the rotating Lambert cube. The window sample is `scripts/build-lit.sh`. Host playback of that component stays out of this pass.

## Checklist

| status | phase | item | packages |
|---|---|---|---|
| planned | 4, 6 | The nodes in `src/nodes` that Lambert and Standard reach | `nodes` |
| planned | 7 | double-sided and back-sided shading normals | `nodes`, `renderer` |
| planned | 7 | sRGB decode of base color and emissive maps | `nodes` |
