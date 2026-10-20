# platform

Landed. Behavior notes are the phase log. The checklist is the upstream file map for this module.

## Phase

### 0. Skeleton

The module, package directories, pinned WIT, and `moon check`. Binding generation is the first step of phase 1.

### 1. Swapchain

Call `gpu.request-adapter`, then `request-device`. Create a `surface`, call `context.configure`, and on `on-frame` clear and `present`. This phase has no three.js types yet. The clear sample is the component exported from `src/gen` (`start`). Upstream still marks `present` on `surface-webgpu` as TODO. wasi-gfx-runtime's `cargo xtask run-demo --name clear` presents the dark blue clear (`0.05, 0.1, 0.2`), so `SurfaceTarget` stays at that behavior.

## Checklist

| status | phase | item | packages |
|---|---|---|---|
| planned | 1 | `src/renderers/common/CanvasTarget.js` | `platform` |
