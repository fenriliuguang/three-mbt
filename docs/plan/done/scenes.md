# scenes

Landed. Behavior notes are the phase log. The checklist is the upstream file map for this module.

## Behavior

Fog has landed. `Fog` is linear, with `near` and `far` in view-space depth, and `FogExp2` is `1 - exp(-density² depth²)`. The factor is the same smoothstep r186 uses for linear fog. A material with `fog` set to false keeps its own color. `examples/fog` is three Lambert cubes fading into the background. The window sample is `scripts/build-fog.sh`. Host playback stays out of this pass.

## Checklist

| status | phase | item | packages |
|---|---|---|---|
| planned | 2 | `src/scenes/Scene.js` | `scenes` |
| planned | 7 | Fog, FogExp2 | `scenes`, `materials`, `renderer` |
