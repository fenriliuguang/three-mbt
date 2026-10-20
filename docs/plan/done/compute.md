# compute

Landed. Behavior notes are the phase log. The checklist is the upstream file map for this module.

## Behavior

A compute pass has landed. `StoragePositions` keeps one `vec3` per point and the same positions on the CPU. The formula is `y = sin(x π + time) * 0.5`, with `x` running from -1 to 1. `WebGPURenderer.compute` dispatches a 64-wide workgroup into a storage buffer that is also the point instance buffer. `examples/compute` is 65 points, so the dispatch is two workgroups. The window sample is `scripts/build-compute.sh`. Host playback stays out of this pass.

## Checklist

| status | phase | item | packages |
|---|---|---|---|
| planned | 7 | a compute shader for point positions | `compute`, `renderer` |
