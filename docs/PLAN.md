# three-mbt migration plan

Move the drawable three.js r186 world to MoonBit: the scene graph plus a WebGPU-only renderer. Presentation and input go through [wasi-gfx](https://github.com/wasi-gfx/wasi-gfx). The GPU goes through [wasi:webgpu](https://github.com/WebAssembly/wasi-webgpu).

Phase 0 through phase 6 have landed: the module, a swapchain clear, the CPU scene graph, an unlit cube, a Lambert cube with ambient and directional light, an `rgba8` textured cube whose camera follows pointer events, and a Standard material cube. Phase 7 has started with points, lines, instancing, directional shadows, render targets, fog, the animation mixer, a glTF geometry and PBR subset, a compute shader that writes point positions, a grayscale fullscreen pass, transparent meshes drawn back to front, tone mapping through Neutral, a single-resolution bloom pass, and an effect-composer pass chain. The remaining bloom mips, half-float targets, `Custom` tone mapping, the node `RenderPipeline`, and the rest of the node builder stay later.

## Pins

| Item | Value |
|---|---|
| three.js | Tag `r186`, matching `src/Three.WebGPU.js` (published entry `three/webgpu`) |
| GPU | `wit/webgpu`, `wasi:webgpu@0.3.0-rc.2` |
| Window and input | `wit/surface`, `wasi-gfx:surface@0.2.0` and `surface-webgpu` |
| Host | [wasi-gfx-runtime](https://github.com/wasi-gfx/wasi-gfx), which provides both surface and wasi:webgpu |
| This repository | Apache-2.0 |
| Upstream three.js | MIT |

Commit hashes are in [wit/README.md](../wit/README.md). `wasi:webgpu` is in Phase 2. A WIT upgrade touches `wit/` and `bindings`, then both of those records.

## Scope

The world is the scene description and the draw of that scene:

- Math, scene graph, cameras, geometries, meshes, materials, lights, textures
- The traverse, lists, objects, and bindings from `src/renderers/common` that the WebGPU path uses
- `WebGPUBackend` and the WGSL it depends on

r186's `WebGPURenderer` falls back to `WebGLBackend` when WebGPU is missing. This project has a WebGPU interface only, so that fallback stays upstream, including `forceWebGL`.

After the world draws reliably, add features by how much they add to one scene: animation, a glTF subset, post-processing, shadows, instancing, points and lines, compute.

Out of scope:

- `WebGLRenderer`, `src/renderers/webgl`, `webgl-fallback`, `src/renderers/shaders` (GLSL)
- `webxr`, audio, CSS2D / CSS3D, the editor
- DOM image paths (`HTMLImageElement`, `createImageBitmap`). Textures enter the library as width, height, and `rgba8` bytes
- `wasi-gfx`'s `frame-buffer`. WebGPU presentation uses `surface-webgpu`

## Interface split

`wasi:webgpu` leaves presentation to the host. The current texture comes from `surface-webgpu.context`, and a finished frame calls `present`.

| Capability | Interface | Replaces in r186 |
|---|---|---|
| Device, buffers, textures, pipelines, drawing | `webgpu` in `wasi:webgpu@0.3.0-rc.2` | `GPUDevice`, `GPUQueue`, and the rest of the device API |
| Window, size, frames, keyboard, pointer | `surface` in `wasi-gfx:surface@0.2.0` | The canvas and DOM events |
| Turn the window into a swapchain | `configure`, `get-current-texture`, `present` on `surface-webgpu.context` | `CanvasTarget` |

`request-adapter` and `request-device` are async in the WIT. Phase 1 starts by confirming the MoonBit bindings can complete both calls.

## Architecture

Dependencies point downward. The scene graph has no WIT imports. `platform` and `renderer/webgpu` are the packages that import the WebGPU bindings. `platform` and the application shell are the packages that touch surface.

```text
src/examples                 executable samples
        |
src (facade fenriliuguang/three-mbt)
        |
+---------------------------+-------------------------------+
| world, CPU only           | renderer                      |
| math core cameras         | common: traverse, lists,      |
| scenes objects            |   objects, bindings           |
| geometries materials      | webgpu: backend, WGSL,        |
| lights textures constants |   pipelines                   |
+---------------------------+-------------------------------+
        |
src/platform                 Gpu, SurfaceTarget
        |
src/bindings                 generated from wit/
        |
wit/                         pinned webgpu and surface
        |
wasi-gfx-runtime
```

`moon.mod` sets `source = "src"`, so import paths omit `src`. `src/math` is imported as `fenriliuguang/three-mbt/math`. The public facade is the source-root package `fenriliuguang/three-mbt`.

One frame:

```text
surface.on-frame
  -> the application updates Object3D
  -> WebGPURenderer.render(scene, camera)
       -> update world matrices and the camera projection
       -> build the opaque render list
       -> context.get-current-texture()
       -> upload vertices and uniforms, draw
       -> context.present()
```

## Layout

```text
moon.mod
docs/PLAN.md
wit/webgpu/                  wasi:webgpu@0.3.0-rc.2
wit/surface/                 surface@0.2.0 and surface-webgpu
tests/fixtures/              r186 numeric fixtures, from phase 2
src/                         facade
src/bindings/
src/platform/
src/constants/
src/math/
src/core/
src/cameras/
src/scenes/
src/objects/
src/geometries/
src/materials/
src/lights/
src/textures/
src/renderer/common/
src/renderer/webgpu/
src/nodes/                   WGSL subset from phase 4, texture sample from phase 5
src/examples/clear/          phase 1
src/examples/cube/           phase 3
src/examples/lit/            phase 4
src/examples/textured/       phase 5
src/examples/standard/       phase 6
src/examples/points/         phase 7
src/examples/instanced/      phase 7
src/examples/shadow/         phase 7
src/examples/target/         phase 7
src/examples/fog/            phase 7
src/examples/animate/        phase 7
src/animation/               phase 7
src/examples/gltf/           phase 7
src/gltf/                    phase 7
src/examples/compute/        phase 7
src/compute/                 phase 7
src/examples/post/           phase 7
src/post/                    phase 7
src/examples/blend/          phase 7
src/examples/tone/           phase 7
src/examples/bloom/          phase 7
src/examples/compose/        phase 7
```

Samples live under `src/examples` because only packages inside the `source` directory belong to the module. The clear sample is the Wasm component built from `src/gen`; `moon run src/examples/cube` stays a placeholder until phase 3.

## Correspondence with r186

| This repository | r186 |
|---|---|
| `math` `core` `cameras` `scenes` `objects` `geometries` `materials` `lights` `textures` `constants` | The same directories, plus the used subset of `src/constants.js` |
| `renderer/common` | The list, object, and binding files in `src/renderers/common` |
| `renderer/webgpu` | `WebGPURenderer.js`, `WebGPUBackend.js`, `utils/*`, `nodes/WGSLNodeBuilder.js` |
| `platform` | `CanvasTarget.js`, retargeted at `surface` + `surface-webgpu.context` |
| `nodes` | The on-demand subset of `src/nodes` |
| No package | `WebGLBackend`, `webgl/`, `shaders/`, `webxr/`, `audio/` |

`Renderer.js` (about 108KB), `WebGPUBackend.js` (about 94KB), and `WGSLNodeBuilder.js` (about 81KB) move along the draw path, one slice at a time.

## Rules

1. The world comes before shaders. Scene-graph and matrix tests use r186 numbers and run without a GPU. Fixtures live in `tests/fixtures/`.
2. Hard-coded WGSL comes before the node graph. In r186, materials become TSL, then `WGSLNodeBuilder` emits WGSL. The first shading implementation is one WGSL program for `MeshBasicMaterial`. The node system grows later, following only the nodes that material actually reaches.
3. three.js runtime tags become MoonBit types. `isMesh` becomes a trait or an enum. Uniforms use explicit layouts. Constant numeric values stay aligned with r186 so fixtures compare directly.
4. Every phase has a runnable sample. The next phase starts after that sample runs.
5. This is a semantic port. Upstream files that the port uses are listed in the table below.
6. A ported implementation file carries an `r186` blob link. The first line is `// r186:` and points at the upstream file. Each public type that maps to a class, and each core function whose upstream name is not obvious from that type, has a `/// r186:` line on the declaration. The URL is `https://github.com/mrdoob/three.js/blob/r186/<path>#L<line>`. Tests, examples, ffi, and generated bindings stay unmarked. The comment rules are in `.cursor/skills/upstream-links/SKILL.md`.

## Phases

### 0. Skeleton

The module, package directories, pinned WIT, and `moon check`. Binding generation is the first step of phase 1.

### 1. Swapchain

Call `gpu.request-adapter`, then `request-device`. Create a `surface`, call `context.configure`, and on `on-frame` clear and `present`. This phase has no three.js types yet. The clear sample is the component exported from `src/gen` (`start`). Upstream still marks `present` on `surface-webgpu` as TODO. wasi-gfx-runtime's `cargo xtask run-demo --name clear` presents the dark blue clear (`0.05, 0.1, 0.2`), so `SurfaceTarget` stays at that behavior.

### 2. World (CPU)

`Vector3`, `Matrix4`, `Quaternion`, `Euler`, `Color`, `Object3D`, `PerspectiveCamera`, `Scene`, `BufferGeometry`, `BoxGeometry`, `Mesh`. Fixture tests cover r186 matrices, decomposition, and projection.

This phase has landed. Package tests compare compose and decompose, the WebGPU perspective and orthographic projections, a parent-child world matrix, `lookAt`, color hex, and the unit box against three.js r186. The numbers are also stored in `tests/fixtures/r186-world.json`. Cameras default to the WebGPU depth range. Drawing the cube stays in phase 3, and the phase 1 clear sample is still the host check.

### 3. First frame of the world

A minimal `WebGPURenderer.render`: matrix updates, one opaque list, a depth buffer, unlit WGSL, vertex buffers, and an MVP uniform. `examples/cube` is a rotating cube. Frustum culling, sorting, and multi-pass wait.

This phase has landed. `WebGPURenderer` updates matrices, collects visible opaque meshes, uploads positions and indices, and draws them with one unlit WGSL program. The cube scene lives in `examples/cube`. The window sample is the wasm component built by `scripts/build-cube.sh`. Frustum culling and wireframe stay later. Transparent meshes are drawn in phase 7.

### 4. A second material

Ambient light, one directional light, and `MeshLambertMaterial` or a thin Standard. This is the point to add a minimal node set (uniform, attribute, varying, a few vector operations) or a small compiler that knows these two materials. `WGSLNodeBuilder.js` stays whole upstream.

This phase has landed. `nodes` builds `MeshBasicMaterial` and `MeshLambertMaterial` from uniform, attribute, varying, and a few vector operations, then emits WGSL. The renderer uploads positions and normals, and packs ambient light plus the first directional light into the same uniform buffer. `examples/lit` is the rotating Lambert cube. The window sample is `scripts/build-lit.sh`. Host playback of that component stays out of this pass.

### 5. Textures and window events

`rgba8` textures and samplers. `on-resize` rebuilds the swapchain. A sample uses `on-pointer-*` to move the camera. Input stays in the sample.

This phase has landed. `Texture` is width, height, and `rgba8` bytes. Materials can hold one map; both shaders sample it, and a missing map binds a 1×1 white texture. `examples/textured` is a Lambert cube with a checker map. Its component reads `on-resize` and asks the renderer to reconfigure the swapchain, and reads `on-pointer-*` to orbit the camera. The window sample is `scripts/build-textured.sh`. Host playback of that component stays out of this pass.

### 6. PBR subset

`MeshStandardMaterial` with baseColor, roughness, and metalness, plus the directional light already in place. Environment maps and PMREM stay later.

This phase has landed. `MeshStandardMaterial` defaults to roughness 1 and metalness 0. The shader is the direct Cook-Torrance term from r186: GGX distribution, Smith correlated visibility, Schlick fresnel, dielectric F0 of 0.04, and a roughness floor of 0.0525. Ambient light only multiplies the diffuse lobe. `examples/standard` is the rotating cube. The window sample is `scripts/build-standard.sh`. Host playback of that component stays out of this pass. Environment maps stay later.

### 7. Whatever the next scene needs

Order: `Points` / `Line`, instancing, shadows, `RenderTarget`, fog, the animation mixer, a glTF geometry and PBR subset, compute, a grayscale post pass, transparent meshes, tone mapping, bloom, an effect composer. Each addition changes the matching row below from "later" to "ported".

Points and lines have landed. `PointsMaterial.size` is in pixels. When `sizeAttenuation` is set and the camera is perspective, the quad scales by `viewportHeight * 0.5 / -viewZ`, matching r186. WebGPU lines stay one pixel wide, as `Line` (strip) and `LineSegments` (list). `examples/points` draws both. The window sample is `scripts/build-points.sh`. Host playback stays out of this pass.

Instancing has landed. `InstancedMesh` stores column-major instance matrices and an optional per-instance color. The instance matrix is applied before the object matrix. A missing color is white. `count` can be lowered without reallocating. `compute_bounding_box` unions each transformed geometry box in local space. `examples/instanced` draws three Lambert cubes from one mesh. The window sample is `scripts/build-instanced.sh`. Host playback stays out of this pass.

Directional shadows have landed. The first visible directional light can cast one `depth32float` map from its orthographic shadow camera. Casters are opaque meshes with `cast_shadow`. Receivers multiply only the direct term by a 3×3 comparison sample. Ambient light is unchanged. `examples/shadow` is a Lambert cube on a plane. The window sample is `scripts/build-shadow.sh`. Host playback stays out of this pass.

Render targets have landed. `RenderTarget` is a color texture plus a private `depth24plus` buffer. The color format is the preferred canvas format, so the mesh pipelines can draw into it. `set_render_target(None)` draws to the window and calls `present`. An active target skips the swapchain and `present`, and still draws when the window size is 0. The attachment keeps `flip_y` false, so the top of the picture is at v = 0. `examples/target` draws a Lambert cube into a 256×256 target, then a screen quad with flipped v. The window sample is `scripts/build-target.sh`. Host playback stays out of this pass.

Fog has landed. `Fog` is linear, with `near` and `far` in view-space depth, and `FogExp2` is `1 - exp(-density² depth²)`. The factor is the same smoothstep r186 uses for linear fog. A material with `fog` set to false keeps its own color. `examples/fog` is three Lambert cubes fading into the background. The window sample is `scripts/build-fog.sh`. Host playback stays out of this pass.

The animation mixer has landed. `AnimationClip` holds vector and quaternion tracks. Sampling is linear, or discrete; quaternion tracks use slerp. `LoopRepeat`, `LoopOnce`, and `LoopPingPong` match the r186 numbers. A weight below 1 blends with the pose captured on the first update. `InterpolateSmooth` stays later. `examples/animate` bobs and turns a Lambert cube. The window sample is `scripts/build-animate.sh`. Host playback stays out of this pass.

A glTF 2.0 subset has landed. `parse` reads one JSON document. Buffer bytes come from a base64 `data:` URI, or from the caller when buffer 0 has no URI. Triangle primitives become meshes with `POSITION`, `NORMAL`, `TEXCOORD_0`, and indices. `baseColorFactor` is written as linear RGB, with `roughnessFactor`, `metallicFactor`, and `doubleSided`. A node `matrix` replaces translation, rotation, and scale. Images, skins, morph targets, animations, cameras, and punctual lights stay later. `examples/gltf` draws that unit box under a directional light. The window sample is `scripts/build-gltf.sh`. Host playback stays out of this pass.

A compute pass has landed. `StoragePositions` keeps one `vec3` per point and the same positions on the CPU. The formula is `y = sin(x π + time) * 0.5`, with `x` running from -1 to 1. `WebGPURenderer.compute` dispatches a 64-wide workgroup into a storage buffer that is also the point instance buffer. `examples/compute` is 65 points, so the dispatch is two workgroups. The window sample is `scripts/build-compute.sh`. Host playback stays out of this pass.

A grayscale post pass has landed. The scene is drawn into a color target, then a fullscreen triangle mixes each pixel toward `0.25 r + 0.5 g + 0.25 b` by `amount`. Those weights are dyadic, so the CPU mix and the shader agree on exact values. The attachment stores the top of the picture at v = 0, and the triangle samples that row from the top of the window. `examples/post` is a Lambert cube at amount 0.5. The window sample is `scripts/build-post.sh`. Host playback stays out of this pass.

Transparent meshes have landed. A mesh with `transparent` set is drawn after the opaque list, from far to near in view space. The camera looks down -Z, so a smaller view-space z is farther and is drawn first. Equal depth keeps traverse order. Blending is source alpha over one-minus source alpha, and depth write stays on, matching r186's default material. Wireframe, transparent points, and transparent lines stay out of both lists. `examples/blend` is an opaque Lambert cube behind one at opacity 0.5. The window sample is `scripts/build-blend.sh`. Host playback stays out of this pass.

Tone mapping has landed for the r186 operators except `Custom`. `No` leaves the color alone and ignores exposure. `Linear` multiplies by exposure and clamps to [0, 1]. `Reinhard` is `scaled / (scaled + 1)`. Cineon is the Hejl/Burgess-Dawson curve. ACES is the RRT and ODT fit. AgX goes through Rec.2020, the inset and outset matrices, and the contrast polynomial. Neutral subtracts the low-end offset, then compresses highlights above 0.76. The default pass is `No` at exposure 1, matching r186's renderer. The curve runs as a fullscreen triangle over a color target, because the output node is not built yet. `examples/tone` is a Lambert cube with ACES at exposure 1. The window sample is `scripts/build-tone.sh`. Host playback stays out of this pass. `Custom` stays later.

A single-resolution bloom pass has landed. The high pass uses Rec.709 luminance and `smoothstep` across `smoothWidth`. One separable Gaussian of kernel radius 6 blurs that result, then the composite adds it with `lerpBloomFactor` for the first mip. The four passes are separate submits so each uniform is visible, and a pass never samples the texture it is rendering. `examples/bloom` is a Lambert cube with threshold 0.2, strength 1, and radius 0. The window sample is `scripts/build-bloom.sh`. Host playback stays out of this pass. Mips 1–4 and half-float targets stay later.

An effect composer has landed as an ordered pass chain. `EffectComposer` holds grayscale, tone-mapping, and bloom passes. A pass with `enabled` false is skipped. Earlier passes draw into a pair of full-size canvas-format buffers, and the last enabled pass draws to the window and presents. The scene is still drawn by `render` into a color target first. `examples/compose` is a Lambert cube with grayscale at amount 0.5, then ACES at exposure 1. The window sample is `scripts/build-compose.sh`. Host playback stays out of this pass. The node `RenderPipeline`, half-float targets, masks, and a copy pass stay later.

Phase 4 adds the two-material compiler. The rest of TSL and `WGSLNodeBuilder.js` stay upstream.

## Upstream file map

Status: planned = ported in that phase; later = decided in phase 7; excluded = stays out of this repository.

| Status | Phase | r186 | This repository |
|---|---|---|---|
| planned | 2 | Vector2/3/4, Matrix3/4, Quaternion, Euler, Color, Box3, Sphere, Frustum from `src/math` | `math` |
| planned | 2 | Object3D, BufferAttribute, BufferGeometry, Layers from `src/core`. EventDispatcher keeps the part the scene graph uses | `core` |
| planned | 2 | Camera, PerspectiveCamera, OrthographicCamera from `src/cameras` | `cameras` |
| planned | 2 | `src/scenes/Scene.js` | `scenes` |
| planned | 2 | Group, Mesh from `src/objects` | `objects` |
| planned | 2 | `src/geometries/BoxGeometry.js` | `geometries` |
| planned | 2–6 | Material and MeshBasicMaterial from `src/materials`, then Lambert and Standard | `materials` |
| planned | 2, 4 | Light, AmbientLight, DirectionalLight from `src/lights` | `lights` |
| planned | 5 | `src/textures/Texture.js` | `textures` |
| planned | 2 onward | Enums from `src/constants.js` as they are used | `constants` |
| planned | 3 | The Renderer, RenderList, RenderObject, Geometries, and Attributes subset of `src/renderers/common` | `renderer/common` |
| planned | 3 | The clear and draw path of `src/renderers/webgpu/WebGPURenderer.js` and `WebGPUBackend.js` | `renderer/webgpu` |
| planned | 3 | Hand-written unlit WGSL, with no single upstream file | `renderer/webgpu` |
| planned | 1 | `src/renderers/common/CanvasTarget.js` | `platform` |
| planned | 4, 6 | The nodes in `src/nodes` that Lambert and Standard reach | `nodes` |
| planned | 7 | Points, Line, LineSegments, PointsMaterial, LineBasicMaterial | `objects`, `materials`, `renderer` |
| planned | 7 | InstancedMesh | `objects`, `renderer` |
| planned | 7 | Directional light shadows | `lights`, `renderer` |
| planned | 7 | RenderTarget | `textures`, `renderer` |
| planned | 7 | Fog, FogExp2 | `scenes`, `materials`, `renderer` |
| planned | 7 | AnimationClip, AnimationMixer | `animation` |
| planned | 7 | a glTF loader subset | `gltf` |
| planned | 7 | a compute shader for point positions | `compute`, `renderer` |
| planned | 7 | a grayscale post pass | `post`, `renderer` |
| planned | 7 | transparent meshes, back to front | `objects`, `renderer` |
| planned | 7 | No, Linear, Reinhard, Cineon, ACES Filmic, AgX, and Neutral tone mapping | `post`, `renderer` |
| planned | 7 | Single-resolution bloom: high pass, kernel radius 6, additive composite | `post`, `renderer` |
| planned | 7 | Effect composer pass chain: grayscale, tone mapping, bloom | `post`, `renderer` |
| later | 7 | Custom tone mapping, bloom mips 1–4, half-float targets, node `RenderPipeline` | `post` |
| later | 7 | The whole of `WGSLNodeBuilder.js`, the whole of `src/nodes`, PMREM, MaterialX | The fragment a material needs, when it needs it |
| excluded |  | `src/renderers/webgl`, `webgl-fallback`, `WebGLRenderer.js`, `shaders/`, `webxr/`, `audio/` | None |

## Risks

- If phase 1 shows that the component-model bindings cannot express async `request-adapter` / `request-device`, the scene graph keeps its own call shape. `bindings` is a separate package so that layer can be replaced.
- Schedule risk sits in the node compiler. Hard-coded WGSL pushes that risk to phase 4.
- Phase 1 confirmed `present` on wasi-gfx-runtime: the clear sample's swapchain color reaches the window.
