# post

Landed. Behavior notes are the phase log. The checklist is the upstream file map for this module.

## Behavior

A grayscale post pass has landed. The scene is drawn into a color target, then a fullscreen triangle mixes each pixel toward `0.25 r + 0.5 g + 0.25 b` by `amount`. Those weights are dyadic, so the CPU mix and the shader agree on exact values. The attachment stores the top of the picture at v = 0, and the triangle samples that row from the top of the window. `examples/post` is a Lambert cube at amount 0.5. The window sample is `scripts/build-post.sh`. Host playback stays out of this pass.

Tone mapping has landed for the r186 operators except `Custom`. `No` leaves the color alone and ignores exposure. `Linear` multiplies by exposure and clamps to [0, 1]. `Reinhard` is `scaled / (scaled + 1)`. Cineon is the Hejl/Burgess-Dawson curve. ACES is the RRT and ODT fit. AgX goes through Rec.2020, the inset and outset matrices, and the contrast polynomial. Neutral subtracts the low-end offset, then compresses highlights above 0.76. The default pass is `No` at exposure 1, matching r186's renderer. After the curve, `set_srgb` encodes each channel with `LinearToSRGB`. The flag defaults to false, so existing curve numbers stay linear. `No` still ignores exposure, then encodes when the flag is on. The curve runs as a fullscreen triangle over a color target, because the output node is not built yet. `examples/tone` is a Lambert cube with ACES at exposure 1 and sRGB encoding on. The compose sample leaves encoding off. The window sample is `scripts/build-tone.sh`. Host playback stays out of this pass. `Custom` stays later.

A five-level bloom pass has landed. The high pass uses Rec.709 luminance and `smoothstep` across `smoothWidth`. Separable Gaussians use kernel radii 6, 10, 14, 18, and 22. Level 0 uses `resolutionScale`, which defaults to 1 so it stays full resolution. r186's 0.5 is `set_resolution_scale`. Each later level is half the previous one, at least one pixel. The composite adds `strength * lerpBloomFactor(bloomFactors[level], radius)` for factors 1, 0.8, 0.6, 0.4, and 0.2, then multiplies by that level's tint. Tints default to white. Each pass is its own submit, and a pass never samples the texture it is rendering. `examples/bloom` is a Lambert cube with threshold 0.2, strength 1, radius 0, and a `(0.5, 1, 0.25)` tint on the last level. The window sample is `scripts/build-bloom.sh`. The bloom intermediates are `rgba16float`. The scene target and the swapchain stay on the canvas format. Host playback stays out of this pass. A half-float scene target stays later.

An effect composer has landed as an ordered pass chain. `EffectComposer` holds grayscale, tone-mapping, bloom, and copy passes. A pass with `enabled` false is skipped. Earlier passes draw into a pair of full-size canvas-format buffers, and the last enabled pass draws to the window and presents. The copy pass multiplies every channel by `opacity`, which defaults to 1 and is not clamped. The scene is still drawn by `render` into a color target first. `examples/compose` is a Lambert cube with grayscale at amount 0.5, then ACES at exposure 1. The window sample is `scripts/build-compose.sh`. Host playback stays out of this pass. The node `RenderPipeline`, half-float scene targets, and masks stay later.

## Checklist

| status | phase | item | packages |
|---|---|---|---|
| planned | 7 | a grayscale post pass | `post`, `renderer` |
| planned | 7 | No, Linear, Reinhard, Cineon, ACES Filmic, AgX, and Neutral tone mapping, optional sRGB output | `post`, `renderer` |
| planned | 7 | Five-level bloom: kernels 6, 10, 14, 18, 22 and additive composite | `post`, `renderer` |
| planned | 7 | Effect composer pass chain: grayscale, tone mapping, bloom, copy | `post`, `renderer` |
