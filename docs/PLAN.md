# three-mbt migration plan

Move the drawable three.js r186 world to MoonBit: the scene graph plus a WebGPU-only renderer. Presentation and input go through [wasi-gfx](https://github.com/wasi-gfx/wasi-gfx). The GPU goes through [wasi:webgpu](https://github.com/WebAssembly/wasi-webgpu).

Phase 0 through phase 6 have landed: the module, a swapchain clear, the CPU scene graph, an unlit cube, a Lambert cube with ambient and directional light, an `rgba8` textured cube whose camera follows pointer events, and a Standard material cube. Phase 7 has started with points, lines, instancing, directional shadows, render targets, fog, the animation mixer, a glTF geometry and PBR subset, a compute shader that writes point positions, a grayscale fullscreen pass, transparent meshes drawn back to front, tone mapping through Neutral, a five-level bloom pass, and an effect-composer pass chain. `Custom` tone mapping, half-float scene targets, the node `RenderPipeline`, and the rest of the node builder stay later.

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

This phase has landed. `WebGPURenderer` updates matrices, collects visible opaque meshes, uploads positions and indices, and draws them with one unlit WGSL program. The cube scene lives in `examples/cube`. The window sample is the wasm component built by `scripts/build-cube.sh`. The color pass drops a mesh, point, or line when `frustum_culled` is set and its bounding sphere misses the camera frustum. The sphere is computed on first use. `frustum_culled` false keeps the object. The shadow pass still draws every caster, but it uses the shadow camera's layers. A mesh, point, line, or light whose layer mask misses the camera is skipped. A wireframe mesh is drawn after the opaque list: each triangle becomes three edges, with the same material shader. An instanced wireframe uses the instanced shader and draws those edges once per instance. Its shadow uses the triangles, not the edges. Transparent meshes are drawn in phase 7.

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

The animation mixer has landed. `AnimationClip` holds vector and quaternion tracks. Sampling is linear, discrete, or smooth. Quaternion tracks use slerp. `Smooth` on a quaternion track still slerps, because that track has no smooth factory. Vector `Smooth` is the cubic spline with zero-curvature ends. `LoopRepeat`, `LoopOnce`, and `LoopPingPong` match the r186 numbers. A weight below 1 blends with the pose captured on the first update. `examples/animate` bobs and turns a Lambert cube. The window sample is `scripts/build-animate.sh`. Host playback stays out of this pass.

A glTF 2.0 subset has landed. `parse` reads one JSON document. Buffer bytes come from a base64 `data:` URI, or from the caller when buffer 0 has no URI. Triangle primitives become meshes with `POSITION`, `NORMAL`, `TEXCOORD_0`, and indices. `baseColorFactor` is written as linear RGB, with `roughnessFactor`, `metallicFactor`, and `doubleSided`. A double-sided material flips the shading normal on back faces. A back-sided material always flips it. Front-sided materials leave the normal alone. The flag is `surface.w`: `1` for double, `-1` for back, and `0` for front. `KHR_materials_unlit` becomes `MeshBasicMaterial`. `OPAQUE` ignores base-color alpha. `MASK` stores `alphaCutoff` as `alphaTest` (default 0.5) and discards fragments below it. `BLEND` is transparent and keeps that alpha, including 1. A node `matrix` replaces translation, rotation, and scale. A node camera becomes a perspective or orthographic camera. `yfov` is converted to degrees. A missing aspect ratio is 1, and a missing or zero far plane is 2e6, matching `GLTFLoader.loadCamera`. A node that only references a camera becomes that camera. A mesh and a camera on the same node become a group, and a repeated camera index is a separate object. Animations become clips: `translation` is `.position`, `rotation` is `.quaternion`, and `scale` is `.scale`. `LINEAR` and `STEP` map to linear and discrete sampling. A missing clip name is `animation_` plus its index. `CUBICSPLINE` stores an in-tangent, a vertex, and an out-tangent on each key. Quaternion samples are normalized. A `KHR_lights_punctual` directional light uses a linear color, intensity 1 when omitted, and a target at local `(0, 0, -1)`. Its position is reset to the origin before the node transform. The first visible point light adds a direct term. Attenuation is `1 / max(distance^decay, 0.01)`, and a positive distance smooths the light to zero at that cutoff. Decay defaults to 2. A glTF point light uses the node position, stores `range` as `distance` (`0` means no cutoff), and keeps intensity `0`. Point lights do not cast shadows. The first visible spot light adds an unshadowed direct term. It uses the same distance attenuation as a point light, then multiplies by a smoothstep from `coneCos` to `penumbraCos`. `angleCos` is the dot of the normalized vector from the fragment to the light and the normalized vector from the target to the light. `coneCos` is `cos(angle)` and `penumbraCos` is `cos(angle * (1 - penumbra))`. Equal cosines are a hard edge. A glTF spot light stores `outerConeAngle` as `angle` (default π/4), `penumbra` as `1 - innerConeAngle / outerConeAngle`, and `range` as `distance`. Decay is 2. Intensity 0 is kept. The target sits at local `(0, 0, -1)`. Spot lights do not cast shadows. The first four joint influences skin on the CPU. `JOINTS_0` and `WEIGHTS_0` select joints and weights. A missing pair leaves the mesh rigid. `JOINTS_1` and `WEIGHTS_1`, when both are present, add four more influences and are normalized together with the first four. A second set with only one of the two attributes is ignored. r186's loader attribute map has no `JOINTS_1` entry; the accessor rules match `JOINTS_0`. `JOINTS_2` and `WEIGHTS_2`, when both are present and the second set was read, add four more influences and are normalized with the earlier ones. A third set without the second set is ignored. r186's attribute map has no `JOINTS_2` entry either. `JOINTS_3` and `WEIGHTS_3`, when both are present and the third set was read, add four more influences and are normalized with the earlier ones. A fourth set without the third set is ignored. r186's attribute map has no `JOINTS_3` entry either. Weights are scaled so their absolute values sum to 1, and a zero weight vector becomes `(1, 0, 0, 0)`. The joint matrix is `joint.matrixWorld * inverseBindMatrix`. The skinned point is then multiplied by the inverse of the mesh `matrixWorld`, matching `SkinnedMesh` attached mode with the identity bind matrix `GLTFLoader` passes to `bind`. A missing `inverseBindMatrices` accessor uses identity. Each skinned primitive gets its own geometry, so an unskinned user of the same mesh keeps the bind pose. Position and, when present, normal are rewritten from that bind pose on every `update_frame`. A primitive that also has morph targets adds those `POSITION` and `NORMAL` displacements to the unbaked base before skinning, using the weights currently stored on the morph state. Color morphs stay on the morph write and are not skinned. GPU skinning stays out. Images stay later. A mesh `weights` entry bakes that `POSITION` morph delta into the vertices and, when a normal attribute is already present, the `NORMAL` morph delta into those normals. A missing normal attribute skips the normal target. A node `weights` list overrides the mesh weights by index, and a shorter list keeps the later mesh weights. A node whose weights differ gets its own geometry. A `weights` animation channel becomes `.morphTargetInfluences` and rebakes position, normal, and color from the unbaked base. A node without morph targets skips that channel. The first write clones a shared geometry so other nodes keep their pose. A `COLOR_0` morph delta is baked into an existing color attribute, including a fourth component when the accessor is `VEC4`. A missing color attribute skips that target. A mesh color attribute is multiplied into the base color, including its alpha. A mesh without one is packed as white. Lambert and Standard add an emissive color after lighting, so it is not shadowed and is not multiplied by the vertex color. Basic materials leave it out. A glTF `emissiveFactor` is linear RGB and defaults to black; a channel of `0` is kept. Unlit materials ignore it. `KHR_materials_emissive_strength` stores `emissiveIntensity`, which defaults to 1 and is multiplied into the emissive uniform. A strength of 0 is kept. Unlit materials ignore it. An emissive map multiplies the emissive color. A missing map binds a white texture, so the color is unchanged. glTF `emissiveTexture` stays out until images are read. A Standard roughness map multiplies roughness by the texture's green channel, then applies the 0.0525 floor. A missing map binds white, so the factor is unchanged. Lambert and Basic do not sample it. The sample shares bind group 3 with the emissive map: bindings 0 and 1 stay emissive, and 2 and 3 are roughness. Group 1 stays the two-binding color map. glTF `roughnessTexture` stays out until images are read. A Standard metalness map multiplies metalness by the texture's blue channel, then clamps the product to [0, 1]. A missing map binds white. It uses bind group 3 bindings 4 and 5. Lambert and Basic do not sample it. glTF `metalnessTexture` stays out until images are read. An alpha map multiplies fragment alpha by the texture's green channel after the vertex color, and before the alpha test. Fog does not change that alpha. Basic, Lambert, and Standard sample it. A missing map binds white. It uses bind group 3 bindings 6 and 7. Points and lines do not sample it. glTF does not read an alpha texture. Base color and emissive samples decode sRGB to linear with `SRGBToLinear` before shading. The color map's alpha stays as stored. Roughness, metalness, and alpha maps stay linear. A white texel stays white. Lambert and Standard can set `flatShading`. The flag is `emissive.w`: above 0.5, the shader replaces the vertex normal with the cross product of the screen derivatives of the view-space position, transformed back to world space, and skips the side flip. The uniform block stays 624 bytes. Basic materials store the flag and do not shade with it. A sparse accessor replaces indexed elements, and an accessor with no buffer view starts at zero. `examples/gltf` draws that unit box under a directional light. The window sample is `scripts/build-gltf.sh`. Host playback stays out of this pass.

A compute pass has landed. `StoragePositions` keeps one `vec3` per point and the same positions on the CPU. The formula is `y = sin(x π + time) * 0.5`, with `x` running from -1 to 1. `WebGPURenderer.compute` dispatches a 64-wide workgroup into a storage buffer that is also the point instance buffer. `examples/compute` is 65 points, so the dispatch is two workgroups. The window sample is `scripts/build-compute.sh`. Host playback stays out of this pass.

A grayscale post pass has landed. The scene is drawn into a color target, then a fullscreen triangle mixes each pixel toward `0.25 r + 0.5 g + 0.25 b` by `amount`. Those weights are dyadic, so the CPU mix and the shader agree on exact values. The attachment stores the top of the picture at v = 0, and the triangle samples that row from the top of the window. `examples/post` is a Lambert cube at amount 0.5. The window sample is `scripts/build-post.sh`. Host playback stays out of this pass.

Transparent meshes have landed. A mesh with `transparent` set is drawn after the opaque list, from far to near in view space. The camera looks down -Z, so a smaller view-space z is farther and is drawn first. Equal `render_order` and equal depth keep traverse order. Blending is source alpha over one-minus source alpha, and depth write stays on, matching r186's default material. Wireframe meshes are drawn as edges and stay out of both triangle lists. Transparent points and lines are sorted with the transparent meshes, far to near, and blended with source alpha over one-minus source alpha. Depth write stays on. `examples/blend` is an opaque Lambert cube behind one at opacity 0.5. The window sample is `scripts/build-blend.sh`. Host playback stays out of this pass.

`depthWrite` has landed. It defaults to true. A mesh, point, or line with it set to false uses a color pipeline that does not write depth. Blended and wireframe draws follow the same flag. The shadow pass still writes depth.

`depthTest` has landed. It defaults to true. A mesh, point, or line with it set to false uses a color pipeline whose depth compare is `always`, so the fragment passes the depth test. `depthWrite` stays independent, matching the WebGPU backend: the color pass still writes depth when that flag is on. The shadow pass still uses `less` and always writes depth.

`depthFunc` has landed. It defaults to `LessEqual`, matching r186. While `depthTest` is on, the color pipeline uses that compare: never, always, less, less-equal, equal, greater-equal, greater, or not-equal. Turning the test off still forces `always` and ignores the function. The shadow pass does not read it.

`reversedDepthBuffer` has landed as `WebGPURenderer.set_reversed_depth`. It defaults to false. When it is on, the view camera's projection uses reversed depth and the color pass clears depth to 0. The compare is remapped with `ReversedDepthFuncs`: never and always swap, equal and not-equal swap, and the inequalities flip. The shadow camera uses the same reversed projection, the shadow pass clears depth to 0 and compares with `greater`, and the comparison sampler uses `greater`. Turning the flag off keeps the forward shadow map, `less`, and a clear value of 1.

`colorWrite` has landed. It defaults to true. A mesh, point, or line with it set to false uses a color pipeline whose fragment write mask is empty, so the color target is unchanged. Depth test and depth write stay as set, which is how an invisible occluder is drawn. The shadow pass has no color target.

`premultipliedAlpha` has landed. It defaults to false. A transparent mesh, point, or line with it set to true uses a blend whose color and alpha source factors are `one`, and whose destination factors stay `one-minus-src-alpha`. With the flag off, both source factors stay `src-alpha`. Opaque draws and wireframes have no blend, so the flag does not change them. The shadow pass has no color blend. Additive, subtractive, and multiply blending stay out.

Perspective `zoom` and `filmOffset` have landed. `zoom` defaults to 1 and divides the vertical field, so 2 doubles the projection scale. `filmOffset` defaults to 0. A nonzero value shifts the frustum horizontally by `near * filmOffset / filmWidth`, where `filmWidth` is `filmGauge * min(aspect, 1)` and `filmGauge` defaults to 35. Orthographic `zoom` was already applied. View offset stays out.

Perspective focal length has landed. `filmGauge` still defaults to 35. Landscape film width is the gauge and the height is `gauge / aspect`. Portrait swaps that. `focalLength` is `0.5 * filmHeight / tan(fov / 2)`. `set_focal_length` writes `fov` from that and rebuilds the projection. `effectiveFOV` divides the half-angle tangent by `zoom`. View offset stays out.

Perspective `getViewBounds` and `getViewSize` have landed. At a distance along the view direction, the bounds are the NDC corners `(-1, -1, 0.5)` and `(1, 1, 0.5)` through the inverse projection, then scaled by `-distance / z`. The size is the width and height of that rectangle. `zoom` 2 halves both. A perspective view offset already in the projection is included.

Perspective `setViewOffset` has landed. It sets `aspect` to `fullWidth / fullHeight`, then shifts and scales the frustum by the sub-rectangle. The left half of a 16:9 frame doubles the horizontal scale and puts `-1` in the x offset term. `clearViewOffset` turns that sub-rectangle off and rebuilds the full frustum. Film offset is applied after the sub-rectangle.

Orthographic `setViewOffset` has landed. It does not change `aspect`. The scale is the frustum width and height divided by the full frame and by `zoom`. The left half of a frustum from `-2` to `2` and `-1` to `1` becomes `-2` to `0`, and the x translation term becomes `1`. `clearViewOffset` restores the full frustum.

`set_near` and `set_far` have landed on both cameras. They write the plane and rebuild the projection. Perspective keeps the same x and y scale, because the frustum height grows with `near`. Orthographic keeps the same x and y scale too. Only the depth terms change.

Orthographic `left`, `right`, `top`, and `bottom` setters have landed. Each one writes that edge and rebuilds the projection. From the default square, `left = -2` and `right = 2` with near `0.1` and far `10` match the existing wide frustum. Doubling `top` and `bottom` halves the vertical scale.

Perspective `set_film_gauge` has landed. The gauge still defaults to 35. Setting it to 70 doubles landscape film width and film height, and doubles the focal length at the same fov. A film offset of 3.5 then shifts the frustum by half as much, because the shift is `near * filmOffset / filmWidth`.

Object3D local-axis `rotateOnAxis` and `translateOnAxis` have landed, with the X, Y, and Z helpers. The axis is assumed normalized. Rotation multiplies the quaternion on the right, so the bound Euler stays in step. Translation copies the axis, rotates it by the quaternion, and adds that offset to the position. `rotateY` by a right angle then `translateX(2)` lands at `(0, 0, -2)`.

`rotateOnWorldAxis` has landed. The axis is assumed normalized, and the parent is assumed not rotated. The turn is premultiplied, so it applies before the object's existing rotation. A right-angle yaw then a world-X quarter turn is `(0.5, 0.5, 0.5, 0.5)`. The same yaw then a local X quarter turn is `(0.5, 0.5, -0.5, 0.5)`.

`localToWorld` and `worldToLocal` have landed. Both update the world matrix from the parents first. Local to world multiplies by that matrix. World to local multiplies by a copy of its inverse, so the stored world matrix stays intact. A child at local `(0, 0, 4)` under a parent shifted by 10 and yawed by 0.5 turns local `(0, 0, 1)` into world `(12.397127693021, 0, 4.38791280945)`, and the reverse returns the local point.

`getWorldQuaternion`, `getWorldScale`, and `getWorldDirection` have landed. Each updates the world matrix from the parents first. The quaternion and scale come from decomposing that matrix. The direction is the matrix's third column, normalized, which is the object's positive Z axis in world space. A child with no local rotation copies its parent's quaternion. Parent scale `(2, 3, 4)` and child scale `(0.5, 2, 1)` multiply to `(1, 6, 4)`. The same yawed child used above looks along `(0.479425538604, 0, 0.87758256189)`.

`applyMatrix4` and `applyQuaternion` have landed. When `matrixAutoUpdate` is on, the matrix is composed from position, quaternion, and scale first. The given matrix is premultiplied, then decomposed back into those three. A yaw of a right angle applied to a point at `(1, 0, 0)` lands at `(0, 0, -1)` with quaternion `(0, 0.7071067811865476, 0, 0.7071067811865476)`. `applyQuaternion` premultiplies, so a local yaw then an X quarter turn is `(0.5, 0.5, 0.5, 0.5)`.

`setRotationFromAxisAngle`, `setRotationFromEuler`, `setRotationFromMatrix`, and `setRotationFromQuaternion` have landed. Each writes the quaternion, and the bound Euler follows. The axis and the quaternion are assumed normalized, and the matrix's upper 3×3 is assumed to be a pure rotation. An axis-angle yaw of a right angle is `(0, 0.7071067811865476, 0, 0.7071067811865476)`. Euler `(0.2, -0.4, 0.6)` matches the existing compose fixture, and copying that quaternion or its rotation matrix keeps both the quaternion and the Euler.

`attach` has landed. It adds the object as a child while keeping the world transform. The new local matrix is the new parent's inverse world matrix times the old parent's world matrix, applied with `applyMatrix4`. Non-uniform parent scale stays unsupported. A child at local x `1` under a parent at x `10`, attached to a parent at x `3`, keeps world x `11` and becomes local x `8`. A child at local `(0, 0, 4)` under a parent shifted by 10 and yawed by 0.5 keeps world `(11.9177021544, 0, 3.51033024756)` and takes that parent's quaternion when the new parent is the identity.

Material `visible` has landed. It defaults to true. A mesh, point, or line with it set to false stays out of the opaque, transparent, wireframe, and shadow lists. `Object3D.visible` still hides the whole subtree on its own.

`forceSinglePass` has landed. It defaults to false. A transparent double-sided mesh draws its back faces, then its front faces, in that order inside the same sorted slot. Setting it to true keeps the one double-sided draw. Opaque meshes and wireframes stay one draw. The normal uniform still uses the material side.

`shadowSide` has landed. It defaults to null. A null side flips the material side for the shadow pass: front draws back faces, back draws front faces, and double draws both. A set value is used as-is. The shadow map is not VSM, so that path's unflipped default stays out. Points and lines do not cast shadows.

A hemisphere light has landed. The first visible one adds indirect diffuse on Lambert and Standard. Sky and ground colors are multiplied by intensity. The direction is the light's world position, normalized, and defaults to `(0, 1, 0)`. A zero-length position stays zero, so the mix weight is 0.5. The weight is `dot(normal, direction) * 0.5 + 0.5`, then `mix(ground, sky, weight)`. It does not add specular and does not cast shadows. A second hemisphere light is ignored. The uniform block grows by 48 bytes to 672. Basic materials, points, and lines do not sample it.

`Object3D.render_order` is honored inside each color list. A lower value is drawn first. Opaque meshes, wireframe meshes, and opaque points and lines use that as their only sort key and keep traverse order on a tie. They are not sorted by depth. Transparent meshes and transparent points and lines compare `render_order` before view-space depth. The shadow list stays in traverse order. There is no `groupOrder`.

Tone mapping has landed for the r186 operators except `Custom`. `No` leaves the color alone and ignores exposure. `Linear` multiplies by exposure and clamps to [0, 1]. `Reinhard` is `scaled / (scaled + 1)`. Cineon is the Hejl/Burgess-Dawson curve. ACES is the RRT and ODT fit. AgX goes through Rec.2020, the inset and outset matrices, and the contrast polynomial. Neutral subtracts the low-end offset, then compresses highlights above 0.76. The default pass is `No` at exposure 1, matching r186's renderer. After the curve, `set_srgb` encodes each channel with `LinearToSRGB`. The flag defaults to false, so existing curve numbers stay linear. `No` still ignores exposure, then encodes when the flag is on. The curve runs as a fullscreen triangle over a color target, because the output node is not built yet. `examples/tone` is a Lambert cube with ACES at exposure 1 and sRGB encoding on. The compose sample leaves encoding off. The window sample is `scripts/build-tone.sh`. Host playback stays out of this pass. `Custom` stays later.

A five-level bloom pass has landed. The high pass uses Rec.709 luminance and `smoothstep` across `smoothWidth`. Separable Gaussians use kernel radii 6, 10, 14, 18, and 22. Level 0 uses `resolutionScale`, which defaults to 1 so it stays full resolution. r186's 0.5 is `set_resolution_scale`. Each later level is half the previous one, at least one pixel. The composite adds `strength * lerpBloomFactor(bloomFactors[level], radius)` for factors 1, 0.8, 0.6, 0.4, and 0.2, then multiplies by that level's tint. Tints default to white. Each pass is its own submit, and a pass never samples the texture it is rendering. `examples/bloom` is a Lambert cube with threshold 0.2, strength 1, radius 0, and a `(0.5, 1, 0.25)` tint on the last level. The window sample is `scripts/build-bloom.sh`. The bloom intermediates are `rgba16float`. The scene target and the swapchain stay on the canvas format. Host playback stays out of this pass. A half-float scene target stays later.

An effect composer has landed as an ordered pass chain. `EffectComposer` holds grayscale, tone-mapping, bloom, and copy passes. A pass with `enabled` false is skipped. Earlier passes draw into a pair of full-size canvas-format buffers, and the last enabled pass draws to the window and presents. The copy pass multiplies every channel by `opacity`, which defaults to 1 and is not clamped. The scene is still drawn by `render` into a color target first. `examples/compose` is a Lambert cube with grayscale at amount 0.5, then ACES at exposure 1. The window sample is `scripts/build-compose.sh`. Host playback stays out of this pass. The node `RenderPipeline`, half-float scene targets, and masks stay later.

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
| planned | 7 | AnimationClip, AnimationMixer, cubic smooth on vector tracks | `animation` |
| planned | 7 | a glTF loader subset | `gltf` |
| planned | 7 | glTF perspective and orthographic cameras | `gltf` |
| planned | 7 | glTF translation, rotation, and scale animation | `gltf` |
| planned | 7 | glTF cubic spline tangents | `animation`, `gltf` |
| planned | 7 | glTF punctual directional lights | `gltf` |
| planned | 7 | point lights and glTF punctual point lights | `lights`, `renderer`, `gltf` |
| planned | 7 | spot lights and glTF punctual spot lights | `lights`, `renderer`, `gltf` |
| planned | 7 | hemisphere lights on Lambert and Standard diffuse | `lights`, `nodes`, `renderer` |
| planned | 7 | `depthWrite` on meshes, points, and lines | `materials`, `renderer` |
| planned | 7 | `depthTest` on meshes, points, and lines | `materials`, `renderer` |
| planned | 7 | `depthFunc` on meshes, points, and lines | `constants`, `materials`, `renderer` |
| planned | 7 | reversed depth on the color pass and the shadow pass | `constants`, `cameras`, `renderer` |
| planned | 7 | `colorWrite` on meshes, points, and lines | `materials`, `renderer` |
| planned | 7 | `premultipliedAlpha` on meshes, points, and lines | `materials`, `renderer` |
| planned | 7 | perspective `zoom` and `filmOffset` | `cameras` |
| planned | 7 | perspective focal length, film width, and film height | `cameras` |
| planned | 7 | perspective view bounds and view size | `cameras` |
| planned | 7 | perspective `setViewOffset` and `clearViewOffset` | `cameras` |
| planned | 7 | orthographic `setViewOffset` and `clearViewOffset` | `cameras` |
| planned | 7 | `near` and `far` setters on both cameras | `cameras` |
| planned | 7 | orthographic `left`, `right`, `top`, and `bottom` setters | `cameras` |
| planned | 7 | perspective `filmGauge` setter | `cameras` |
| planned | 7 | Object3D local `rotateOnAxis` and `translateOnAxis` | `core`, `math` |
| planned | 7 | Object3D `rotateOnWorldAxis` | `core` |
| planned | 7 | Object3D `localToWorld` and `worldToLocal` | `core` |
| planned | 7 | Object3D `getWorldQuaternion`, `getWorldScale`, and `getWorldDirection` | `core` |
| planned | 7 | Object3D `applyMatrix4` and `applyQuaternion` | `core` |
| planned | 7 | Object3D `setRotationFromAxisAngle`, `setRotationFromEuler`, `setRotationFromMatrix`, and `setRotationFromQuaternion` | `core` |
| planned | 7 | Object3D `attach` | `core` |
| planned | 7 | material `visible` on meshes, points, and lines | `materials`, `renderer` |
| planned | 7 | `forceSinglePass` on transparent double-sided meshes | `materials`, `renderer` |
| planned | 7 | `shadowSide` on shadow casters | `materials`, `renderer` |
| planned | 7 | double-sided and back-sided shading normals | `nodes`, `renderer` |
| planned | 7 | emissive maps on Lambert and Standard | `materials`, `renderer` |
| planned | 7 | roughness maps on Standard | `materials`, `nodes`, `renderer` |
| planned | 7 | metalness maps on Standard | `materials`, `nodes`, `renderer` |
| planned | 7 | alpha maps on Basic, Lambert, and Standard | `materials`, `nodes`, `renderer` |
| planned | 7 | sRGB decode of base color and emissive maps | `nodes` |
| planned | 7 | flat shading on Lambert and Standard | `materials`, `nodes`, `renderer` |
| planned | 7 | glTF linear blend skinning on the CPU | `core`, `gltf`, `renderer` |
| planned | 7 | glTF morph displacements before CPU skinning | `core`, `gltf` |
| planned | 7 | glTF `JOINTS_1` and `WEIGHTS_1` on CPU skinning | `core`, `gltf` |
| planned | 7 | glTF `JOINTS_2` and `WEIGHTS_2` on CPU skinning | `core`, `gltf` |
| planned | 7 | glTF `JOINTS_3` and `WEIGHTS_3` on CPU skinning | `core`, `gltf` |
| planned | 7 | glTF unlit materials | `gltf` |
| planned | 7 | alpha test and glTF masked materials | `materials`, `renderer`, `gltf` |
| planned | 7 | glTF static position morph weights | `gltf` |
| planned | 7 | glTF static normal morph weights | `gltf` |
| planned | 7 | glTF node morph weight overrides | `gltf` |
| planned | 7 | glTF static color morph weights | `gltf` |
| planned | 7 | glTF morph weight animation | `animation`, `gltf` |
| planned | 7 | vertex colors multiplied into the base color | `renderer` |
| planned | 7 | emissive color on Lambert and Standard, including glTF emissiveFactor | `materials`, `renderer`, `gltf` |
| planned | 7 | emissive intensity, including glTF KHR_materials_emissive_strength | `materials`, `renderer`, `gltf` |
| planned | 7 | glTF sparse accessors | `gltf` |
| planned | 7 | a compute shader for point positions | `compute`, `renderer` |
| planned | 7 | a grayscale post pass | `post`, `renderer` |
| planned | 7 | transparent meshes, back to front | `objects`, `renderer` |
| planned | 7 | view frustum culling by bounding sphere | `renderer` |
| planned | 7 | camera layers filter meshes, points, lines, and lights | `renderer` |
| planned | 7 | wireframe meshes drawn as triangle edges | `renderer` |
| planned | 7 | wireframe meshes cast triangle shadows | `renderer` |
| planned | 7 | instanced wireframe meshes drawn as triangle edges | `renderer` |
| planned | 7 | transparent points and lines, back to front | `objects`, `renderer` |
| planned | 7 | `renderOrder` before depth on transparent lists, and as the only key on opaque lists | `renderer` |
| planned | 7 | No, Linear, Reinhard, Cineon, ACES Filmic, AgX, and Neutral tone mapping, optional sRGB output | `post`, `renderer` |
| planned | 7 | Five-level bloom: kernels 6, 10, 14, 18, 22 and additive composite | `post`, `renderer` |
| planned | 7 | Effect composer pass chain: grayscale, tone mapping, bloom, copy | `post`, `renderer` |
| planned | 7 | Half-float bloom intermediates | `renderer` |
| later | 7 | Custom tone mapping, half-float scene targets, node `RenderPipeline` | `post` |
| later | 7 | The whole of `WGSLNodeBuilder.js`, the whole of `src/nodes`, PMREM, MaterialX | The fragment a material needs, when it needs it |
| excluded |  | `src/renderers/webgl`, `webgl-fallback`, `WebGLRenderer.js`, `shaders/`, `webxr/`, `audio/` | None |

## Risks

- If phase 1 shows that the component-model bindings cannot express async `request-adapter` / `request-device`, the scene graph keeps its own call shape. `bindings` is a separate package so that layer can be replaced.
- Schedule risk sits in the node compiler. Hard-coded WGSL pushes that risk to phase 4.
- Phase 1 confirmed `present` on wasi-gfx-runtime: the clear sample's swapchain color reaches the window.
