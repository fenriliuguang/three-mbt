# animation

Landed. Behavior notes are the phase log. The checklist is the upstream file map for this module.

## Behavior

The animation mixer has landed. `AnimationClip` holds vector and quaternion tracks. Sampling is linear, discrete, or smooth. Quaternion tracks use slerp. `Smooth` on a quaternion track still slerps, because that track has no smooth factory. Vector `Smooth` is the cubic spline with zero-curvature ends. `LoopRepeat`, `LoopOnce`, and `LoopPingPong` match the r186 numbers. A weight below 1 blends with the pose captured on the first update. `examples/animate` bobs and turns a Lambert cube. The window sample is `scripts/build-animate.sh`. Host playback stays out of this pass.

## Checklist

| status | phase | item | packages |
|---|---|---|---|
| planned | 7 | AnimationClip, AnimationMixer, cubic smooth on vector tracks | `animation` |
| planned | 7 | glTF cubic spline tangents | `animation`, `gltf` |
| planned | 7 | glTF morph weight animation | `animation`, `gltf` |
