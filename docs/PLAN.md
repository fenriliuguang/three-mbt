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

`traverseAncestors` has landed. It visits the parent first, then that parent's parent, and stops at the root. The node itself is not visited. A child under `parent` under `root` yields `parent`, then `root`. A node with no parent yields nothing. Changing the scene graph inside the callback stays unsupported.

`getObjectById` has landed. The search starts at the node itself, then walks children depth first, and returns the first match. A parent can find a grandchild. A child does not find its parent. An unknown id returns nothing. Dynamic property lookup stays out.

`copy` and `clone` have landed. `clone` keeps the node kind and assigns a new id. It copies the name, transform, Euler order, matrices, layer mask, visibility, shadow flags, frustum culling, render order, and a cloned pivot. Children are cloned by default and parented to the copy. `recursive` false copies only the node. Mesh bindings, cameras, lights, morphs, skins, listeners, and the parent pointer stay with the source. `static`, `animations`, and `userData` are not fields on this object.

`dispose` has landed. It dispatches a `dispose` event and does not remove the object from its parent. Geometries, materials, and textures stay shared, so this call does not free them.

`Vector3.transformDirection` has landed. It multiplies by the upper 3×3 of a matrix and normalizes. Translation is ignored, so a pure shift leaves `(0, 0, 1)` unchanged. A right-angle yaw turns `(1, 0, 0)` into `(0, 0, -1)`. Scale `(2, 1, 1)` turns `(1, 1, 0)` into `(0.894427190999916, 0.447213595499958, 0)`.

`Vector3.angleTo` has landed. It is the inverse cosine of the normalized dot product, clamped to [-1, 1]. A vector against itself is 0. `(1, 0, 0)` against `(0, 0, -1)` is a right angle, against `(-1, 0, 0)` is π, and against `(1, 1, 0)` is π/4. A zero-length vector returns π/2. The vectors are not modified.

`Vector3.distanceTo` has landed. It is the square root of `distanceToSquared`. The distance from the origin to `(3, 4, 0)` is 5. A vector's distance to itself is 0. Neither vector is modified.

`Vector3.manhattanDistanceTo` has landed. It is the sum of the absolute component differences. The Manhattan distance from the origin to `(3, 4, 0)` is 7. `(1, -2, 3)` to the origin is 6. A vector's distance to itself is 0. Neither vector is modified.

`Vector3.setFromSphericalCoords` has landed. `phi` is the angle from the positive Y axis, and `theta` turns around Y from positive Z toward positive X. Radius 5 at `phi` 0 is `(0, 5, 0)`. Radius 2 at `phi` π/2 and `theta` 0 is `(0, 0, 2)`. The same radius at `theta` π/2 is `(2, 0, 0)`. Radius 4 at `phi` 0.5 and `theta` -0.3 is about `(-0.566719736988, 3.51033024756, 1.83205084339)`. The vector is overwritten. The `Spherical` wrapper stays out until that type exists.

`Vector3.setFromCylindricalCoords` has landed. `theta` turns around Y from positive Z toward positive X, and `y` is the height. Radius 2 at `theta` 0 and height 5 is `(0, 5, 2)`. The same radius at `theta` π/2 and height -1 is `(2, -1, 0)`. Radius 3 at `theta` -0.3 and height 1 is about `(-0.886560619984, 1, 2.86600946738)`. The vector is overwritten. The `Cylindrical` wrapper stays out until that type exists.

`Vector3.setFromMatrixScale` has landed. It reads the length of the first three columns. A matrix composed with scale `(2, 3, 4)` and a translation of 10 on x yields `(2, 3, 4)`. A negative x scale of `-2` still yields `2`, because the length is unsigned. The vector is overwritten.

`Vector3.setFromMatrix3Column` has landed. The matrix is column-major, and `set` still takes its nine arguments in row order. Column 0 of the matrix written as rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` is `(1, 4, 7)`. Column 1 is `(2, 5, 8)`, and column 2 is `(3, 6, 9)`. The vector is overwritten.

`Vector3.setFromEuler` has landed. It copies the three angles and ignores the rotation order. Euler `(0.2, -0.4, 0.6)` with order `YXZ` becomes that same triple. Changing the Euler afterwards leaves the vector alone.

`Vector3.setFromColor` has landed. It copies the stored linear channels and does not run the sRGB conversion that `setHex` does. Color `(0.25, 0.5, 0.75)` becomes that same triple. Changing the color afterwards leaves the vector alone.

`Vector3.fromArray` has landed. It reads three components starting at `offset`, which defaults to 0. From `[1, 2, 3, 4, 5]`, offset 0 is `(1, 2, 3)` and offset 2 is `(3, 4, 5)`. The array is not modified.

`Vector3.toArray` has landed. A missing array becomes `[x, y, z]`. An existing array is written at `offset`, which defaults to 0, and the same array is returned. `[9, 8, 7, 6, 5]` at offset 1 becomes `[9, x, y, z, 5]` for vector `(1, 2, 3)`. An array shorter than `offset + 3` is padded with zeros before the write. The vector is not modified.

`Vector3.fromBufferAttribute` has landed as `BufferAttribute.copy_to_vector3`, because `math` does not import `core`. It writes `getX`, `getY`, and `getZ` into the target vector. Index 1 of `[1, 2, 3, 4, 5, 6]` with item size 3 is `(4, 5, 6)`. Item size 4 skips the fourth component, so index 1 of `[1, 2, 3, 9, 4, 5, 6, 8]` is also `(4, 5, 6)`. The attribute is not modified.

`Vector3.setScalar` has landed. It writes the same value into x, y, and z. `(1, 2, 3)` set to 4 becomes `(4, 4, 4)`.

`Vector3.setX`, `setY`, and `setZ` have landed. Each writes one component and leaves the other two alone. `(1, 2, 3)` then `setX(9)`, `setY(8)`, and `setZ(7)` becomes `(9, 8, 7)`.

`Vector3.setComponent` and `getComponent` have landed. Index 0 is x, 1 is y, and 2 is z. `(1, 2, 3)` with `setComponent(1, 8)` becomes `(1, 8, 3)`. Any other index aborts.

`Vector3.addScalar` has landed. It adds one number to every component. `(1, 2, 3)` plus 4 is `(5, 6, 7)`. Adding `-1` then yields `(4, 5, 6)`.

`Vector3.addScaledVector` has landed. It adds `v * s` to this vector. `(1, 2, 3)` plus `(4, 5, 6)` scaled by 2 is `(9, 12, 15)`. The other vector is not modified. The `Vector4` overload stays out.

`Vector3.subScalar` has landed. It subtracts one number from every component. `(5, 6, 7)` minus 4 is `(1, 2, 3)`. Subtracting `-1` then yields `(2, 3, 4)`.

`Vector3.multiply` has landed. It multiplies each component by the matching component of the other vector. `(2, 3, 4)` times `(5, 6, 0.5)` is `(10, 18, 2)`. The other vector is not modified.

`Vector3.multiplyVectors` has landed. It stores the component-wise product of two vectors. The product of `(2, 3, 4)` and `(5, 6, 0.5)` is `(10, 18, 2)`. Writing the product back into the first vector still yields that result, and the second vector is not modified.

`Vector3.applyEuler` has landed. It converts the Euler angles to a quaternion and applies that. The identity leaves `(1, 0, 0)` unchanged. A yaw of a right angle, order `XYZ`, turns it into `(0, 0, -1)`. The temporary quaternion is not stored.

`Vector3.applyAxisAngle` has landed. The axis is assumed to be unit length. Angle 0 leaves `(1, 0, 0)` unchanged. A right-angle turn around `(0, 1, 0)` makes it `(0, 0, -1)`. The axis and the temporary quaternion are not stored as part of the vector.

`Vector3.applyMatrix3` has landed. It multiplies by a column-major 3×3 matrix and does not divide by a perspective term. The identity leaves `(1, 2, 3)` unchanged. A diagonal scale of `(2, 3, 4)` turns it into `(2, 6, 12)`. The first column of the matrix written as rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` turns `(1, 0, 0)` into `(1, 4, 7)`.

`Vector3.applyNormalMatrix` has landed. It multiplies by the 3×3 matrix and then normalizes. The identity takes `(0, 3, 4)` to `(0, 0.6, 0.8)`. A zero vector stays zero. `project` and `unproject` stay out of `math`, because that package does not import cameras.

`Vector3.divide` has landed. It divides each component by the matching component of the other vector. `(10, 18, 2)` divided by `(5, 6, 0.5)` is `(2, 3, 4)`. The other vector is not modified.

`Vector3.divideScalar` has landed. It divides every component by one number, through `multiplyScalar(1 / scalar)`. `(2, 4, 6)` divided by 2 is `(1, 2, 3)`. Dividing by `-1` then yields `(-1, -2, -3)`.

`Vector3.clamp` has landed. Each component is limited by the matching component of `min` and `max`, which are assumed to be ordered. `(0, 5, -2)` clamped by `(1, 0, -1)` and `(3, 4, 1)` becomes `(1, 4, -1)`. `(2, 2, 2)` inside `(0, 0, 0)` and `(3, 3, 3)` stays put. The bound vectors are not modified.

`Vector3.clampScalar` has landed. Every component uses the same lower and upper bound, which are assumed to be ordered. `(0, 5, -2)` clamped to `[1, 4]` becomes `(1, 4, 1)`. `(2, 3, 4)` inside `[0, 5]` stays put.

`Vector3.clampLength` has landed. It rescales the vector so its length lies between `min` and `max`, which are assumed to be ordered. Length 8 clamped to `[1, 2]` becomes 2, and length 0.5 becomes 1, both along the original direction. Length 4 inside `[1, 8]` stays 4. A zero vector stays zero.

`Vector3.floor` has landed. Each component rounds toward negative infinity. `(1.2, -1.2, 3)` becomes `(1, -2, 3)`.

`Vector3.ceil` has landed. Each component rounds toward positive infinity. `(1.2, -1.2, 3)` becomes `(2, -1, 3)`.

`Vector3.round` has landed. A halfway case rounds toward positive infinity. `(1.5, -1.5, 1.2)` becomes `(2, -1, 1)`.

`Vector3.roundToZero` has landed. Each component drops its fraction toward zero. `(1.8, -1.8, 3)` becomes `(1, -1, 3)`.

`Vector3.manhattanLength` has landed. It is the sum of the absolute components. `(3, -4, 0)` has length 7. A zero vector has length 0. The vector is not modified.

`Vector3.setLength` has landed. It normalizes and then multiplies by the requested length. `(0, 0, 4)` set to length 2 becomes `(0, 0, 2)`, and setting that to length 0 becomes zero. A zero vector stays zero.

`Vector3.lerpVectors` has landed. It stores `(1 - alpha)` of the first vector plus `alpha` of the second. Alpha 0.25 from `(1, 2, 3)` toward `(5, 6, 7)` is `(2, 3, 4)`. Alpha 0 keeps the first vector, and alpha 1 keeps the second. Neither input is modified.

`Vector3.projectOnVector` has landed. It replaces this vector with its projection onto the target. `(2, 3, 0)` onto `(4, 0, 0)` becomes `(2, 0, 0)`. Projecting onto the zero vector yields zero. The target is not modified.

`Vector3.projectOnPlane` has landed. It removes the component along the plane normal. The normal does not need to be unit length. `(2, 3, 4)` with normal `(0, 4, 0)` becomes `(2, 0, 4)`. A zero normal leaves the vector unchanged. The normal is not modified.

`Vector3.reflect` has landed. It reflects this vector across the plane with the given unit normal. `(1, -1, 0)` reflected by `(0, 1, 0)` becomes `(1, 1, 0)`. The normal is not modified.

`Vector3.setFromSpherical` has landed, along with `Spherical`. The spherical value stores a radius and two angles, defaulting to radius 1, `phi` 0, and `theta` 0. The vector method copies those three fields into `setFromSphericalCoords`. Radius 5 at `phi` 0 is `(0, 5, 0)`. The spherical value is not modified. `set`, `copy`, `makeSafe`, and the Cartesian constructors stay later.

`Spherical.set` has landed. It writes the radius and both angles. The default value set to radius 2, `phi` 0.5, and `theta` -0.3 becomes that triple. `copy`, `makeSafe`, and the Cartesian constructors stay later.

`Spherical.copy` has landed. It copies radius, `phi`, and `theta` from another spherical value. Copying radius 2, `phi` 0.5, and `theta` -0.3 onto the default value yields that triple. The source is not modified. `makeSafe` and the Cartesian constructors stay later.

`Spherical.makeSafe` has landed. It clamps `phi` to the open interval from `0.000001` to `π - 0.000001`. A polar angle of 0 becomes `0.000001`, and `π` becomes `π - 0.000001`. An angle of 0.5 stays 0.5. Radius and `theta` are not modified. The Cartesian constructors stay later.

`Spherical.setFromCartesianCoords` has landed. The radius is the distance from the origin. `phi` is the angle from the positive Y axis, and `theta` turns around Y from positive Z toward positive X. The origin stays radius 0 with both angles 0. `(0, 5, 0)` is radius 5 at `phi` 0. `(0, 0, 2)` is radius 2 at `phi` π/2 and `theta` 0. `(2, 0, 0)` is the same radius at `theta` π/2. The point produced by radius 4, `phi` 0.5, and `theta` -0.3 converts back to those coordinates. `setFromVector3` stays later.

`Spherical.setFromVector3` has landed. It reads the vector's three components and passes them to `setFromCartesianCoords`. `(0, 5, 0)` is radius 5 at `phi` 0. The zero vector is radius 0 with both angles 0. The vector is not modified. `clone` stays later.

`Spherical.clone` has landed. It returns a new spherical value with the same radius, `phi`, and `theta`. Cloning radius 2, `phi` 0.5, and `theta` -0.3 yields that triple. Changing the clone leaves the source alone.

`Vector3.setFromCylindrical` has landed, along with `Cylindrical`. The cylindrical value stores a radius, an angle, and a height, defaulting to radius 1, `theta` 0, and height 0. The vector method copies those three fields into `setFromCylindricalCoords`. Radius 2 at `theta` 0 and height 5 is `(0, 5, 2)`. The cylindrical value is not modified. `set`, `copy`, the Cartesian constructors, and `clone` stay later.

`Cylindrical.set` has landed. It writes the radius, the angle, and the height. The default value set to radius 2, `theta` -0.3, and height 5 becomes that triple. `copy`, the Cartesian constructors, and `clone` stay later.

`Cylindrical.copy` has landed. It copies radius, `theta`, and height from another cylindrical value. Copying radius 2, `theta` -0.3, and height 5 onto the default value yields that triple. The source is not modified. The Cartesian constructors and `clone` stay later.

`Cylindrical.setFromCartesianCoords` has landed. The radius is the distance from the origin in the xz plane, `theta` turns around Y from positive Z toward positive X, and `y` is the height. `(0, 5, 2)` is radius 2 at `theta` 0 and height 5. `(2, -1, 0)` is radius 2 at `theta` π/2 and height -1. The origin is radius 0 at `theta` 0 and height 0. The point produced by radius 3, `theta` -0.3, and height 1 converts back to those coordinates. `setFromVector3` stays later.

`Cylindrical.setFromVector3` has landed. It reads the vector's three components and passes them to `setFromCartesianCoords`. `(0, 5, 2)` is radius 2 at `theta` 0 and height 5. The vector is not modified. `clone` stays later.

`Cylindrical.clone` has landed. It returns a new cylindrical value with the same radius, `theta`, and height. Cloning radius 2, `theta` -0.3, and height 5 yields that triple. Changing the clone leaves the source alone.

`Vector2.setScalar` has landed. It writes the same value into x and y. `(1, 2)` set to 4 becomes `(4, 4)`.

`Vector2.setX` has landed. It writes x and leaves y alone. `(1, 2)` then `setX(9)` becomes `(9, 2)`.

`Vector2.setY` has landed. It writes y and leaves x alone. `(1, 2)` then `setY(8)` becomes `(1, 8)`.

`Vector2.setComponent` has landed. Index 0 is x and 1 is y. `(1, 2)` with `setComponent(1, 8)` becomes `(1, 8)`. Any other index aborts.

`Vector2.getComponent` has landed. Index 0 is x and 1 is y. `(1, 2)` returns 1 at index 0 and 2 at index 1. The vector is not modified. Any other index aborts.

`Vector2.addScalar` has landed. It adds one number to both components. `(1, 2)` plus 4 is `(5, 6)`. Adding `-1` then yields `(4, 5)`.

`Vector2.addVectors` has landed. It stores the sum of two vectors. The sum of `(1, 2)` and `(3, 4)` is `(4, 6)`. Writing the sum back into the first vector still yields that result, and the second vector is not modified.

`Vector2.addScaledVector` has landed. It adds `v * s` to this vector. `(1, 2)` plus `(4, 5)` scaled by 2 is `(9, 12)`. The other vector is not modified.

`Vector2.subScalar` has landed. It subtracts one number from both components. `(5, 6)` minus 4 is `(1, 2)`. Subtracting `-1` then yields `(2, 3)`.

`Vector2.subVectors` has landed. It stores the difference of two vectors. `(5, 6)` minus `(1, 2)` is `(4, 4)`. Writing the difference back into the first vector still yields that result, and the second vector is not modified.

`Vector2.multiply` has landed. It multiplies each component by the matching component of the other vector. `(2, 4)` times `(5, 6)` is `(10, 24)`. The other vector is not modified.

`Vector2.divide` has landed. It divides each component by the matching component of the other vector. `(10, 24)` divided by `(5, 6)` is `(2, 4)`. The other vector is not modified.

`Vector2.divideScalar` has landed. It divides both components by one number, through `multiplyScalar(1 / scalar)`. `(2, 4)` divided by 2 is `(1, 2)`. Dividing by `-1` then yields `(-1, -2)`.

`Vector2.applyMatrix3` has landed. The third component is an implicit 1, and only x and y are stored. The identity leaves `(1, 2)` unchanged. A translation of `(3, 4)` turns it into `(4, 6)`. The matrix written as rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` turns `(1, 0)` into `(4, 10)`.

`Vector2.min` has landed. Each component becomes the smaller of the two vectors. `(0, 5)` against `(1, 4)` becomes `(0, 4)`. The other vector is not modified.

`Vector2.max` has landed. Each component becomes the larger of the two vectors. `(0, 5)` against `(1, 4)` becomes `(1, 5)`. The other vector is not modified.

`Vector2.clamp` has landed. Each component is limited by the matching component of `min` and `max`, which are assumed to be ordered. `(0, 5)` clamped by `(1, 0)` and `(3, 4)` becomes `(1, 4)`. `(2, 2)` inside `(0, 0)` and `(3, 3)` stays put. The bound vectors are not modified.

`Vector2.clampScalar` has landed. Both components use the same lower and upper bound, which are assumed to be ordered. `(0, 5)` clamped to `[1, 4]` becomes `(1, 4)`. `(2, 3)` inside `[0, 5]` stays put.

`Vector2.clampLength` has landed. It rescales the vector so its length lies between `min` and `max`, which are assumed to be ordered. Length 4 clamped to `[1, 2]` becomes 2, and length 0.5 becomes 1, both along the original direction. Length 4 inside `[1, 8]` stays 4. A zero vector stays zero.

`Vector2.floor` has landed. Each component rounds toward negative infinity. `(1.2, -1.2)` becomes `(1, -2)`.

`Vector2.ceil` has landed. Each component rounds toward positive infinity. `(1.2, -1.2)` becomes `(2, -1)`.

`Vector2.round` has landed. A halfway case rounds toward positive infinity. `(1.5, -1.5)` becomes `(2, -1)`.

`Vector2.roundToZero` has landed. Each component drops its fraction toward zero. `(1.8, -1.8)` becomes `(1, -1)`.

`Vector2.negate` has landed. It flips the sign of both components. `(1, -2)` becomes `(-1, 2)`.

`Vector2.cross` has landed. It returns the z component of the cross product, `x * v.y - y * v.x`. `(2, 3)` crossed with `(4, 5)` is `-2`. `(1, 0)` crossed with `(0, 1)` is `1`. Neither vector is modified.

`Vector2.manhattanLength` has landed. It is the sum of the absolute components. `(3, -4)` has length 7. A zero vector has length 0. The vector is not modified.

`Vector2.angle` has landed. It is the angle from the positive X axis, in `[0, 2π)`. `(1, 0)` is 0, `(0, 1)` is π/2, `(-1, 0)` is π, and `(0, -1)` is 3π/2. The vector is not modified.

`Vector2.angleTo` has landed. It is the inverse cosine of the normalized dot product, clamped to [-1, 1]. A vector against itself is 0. `(1, 0)` against `(0, 1)` is a right angle, against `(-1, 0)` is π, and against `(1, 1)` is π/4. A zero-length vector returns π/2. The vectors are not modified.

`Vector2.distanceToSquared` has landed. It is the square of the straight-line separation. The squared distance from the origin to `(3, 4)` is 25. A vector's squared distance to itself is 0. Neither vector is modified. `distanceTo` stays later.

`Vector2.distanceTo` has landed. It is the square root of `distanceToSquared`. The distance from the origin to `(3, 4)` is 5. A vector's distance to itself is 0. Neither vector is modified.

`Vector2.manhattanDistanceTo` has landed. It is the sum of the absolute component differences. The Manhattan distance from the origin to `(3, 4)` is 7. `(1, -2)` to the origin is 3. A vector's distance to itself is 0. Neither vector is modified.

`Vector2.setLength` has landed. It normalizes and then multiplies by the requested length. `(0, 4)` set to length 2 becomes `(0, 2)`, and setting that to length 0 becomes zero. A zero vector stays zero.

`Vector2.lerpVectors` has landed. It stores `(1 - alpha)` of the first vector plus `alpha` of the second. Alpha 0.25 from `(1, 2)` toward `(5, 6)` is `(2, 3)`. Alpha 0 keeps the first vector, and alpha 1 keeps the second. Neither input is modified.

`Vector2.fromArray` has landed. It reads two components starting at `offset`, which defaults to 0. From `[1, 2, 3, 4, 5]`, offset 0 is `(1, 2)` and offset 2 is `(3, 4)`. The array is not modified.

`Vector2.toArray` has landed. A missing array becomes `[x, y]`. An existing array is written at `offset`, which defaults to 0, and the same array is returned. `[9, 8, 7, 6]` at offset 1 becomes `[9, x, y, 6]` for vector `(1, 2)`. An array shorter than `offset + 2` is padded with zeros before the write. The vector is not modified.

`Vector2.fromBufferAttribute` has landed as `BufferAttribute.copy_to_vector2`, because `math` does not import `core`. It writes `getX` and `getY` into the target vector. Index 1 of `[1, 2, 3, 4, 5, 6]` with item size 2 is `(3, 4)`. Item size 3 skips the third component, so index 1 of the same array is `(4, 5)`. The attribute is not modified.

`Vector2.rotateAround` has landed. It rotates this vector counterclockwise around a center. Angle 0 leaves `(1, 2)` unchanged. A right angle around the origin turns `(1, 0)` into `(0, 1)`. The same turn around `(1, 1)` takes `(2, 1)` to `(1, 2)`. The center is not modified. `Vector2.random` stays out, because it draws from `Math.random`.

`Vector4.setScalar` has landed. It writes the same value into x, y, z, and w. `(1, 2, 3, 4)` set to 5 becomes `(5, 5, 5, 5)`.

`Vector4.setX` has landed. It writes x and leaves y, z, and w alone. `(1, 2, 3, 4)` then `setX(9)` becomes `(9, 2, 3, 4)`.

`Vector4.setY` has landed. It writes y and leaves x, z, and w alone. `(1, 2, 3, 4)` then `setY(8)` becomes `(1, 8, 3, 4)`.

`Vector4.setZ` has landed. It writes z and leaves x, y, and w alone. `(1, 2, 3, 4)` then `setZ(7)` becomes `(1, 2, 7, 4)`.

`Vector4.setW` has landed. It writes w and leaves x, y, and z alone. `(1, 2, 3, 4)` then `setW(6)` becomes `(1, 2, 3, 6)`.

`Vector4.setComponent` has landed. Index 0 is x, 1 is y, 2 is z, and 3 is w. `(1, 2, 3, 4)` with `setComponent(3, 6)` becomes `(1, 2, 3, 6)`. Any other index aborts.

`Vector4.getComponent` has landed. Index 0 is x, 1 is y, 2 is z, and 3 is w. `(1, 2, 3, 4)` returns 1, 2, 3, and 4. The vector is not modified. Any other index aborts.

`Vector4.add` has landed. It adds another vector into this one. `(1, 2, 3, 4)` plus `(5, 6, 7, 8)` becomes `(6, 8, 10, 12)`. The other vector is unchanged.

`Vector4.addScalar` has landed. It adds one number to x, y, z, and w. `(1, 2, 3, 4)` plus 4 becomes `(5, 6, 7, 8)`, then minus 1 becomes `(4, 5, 6, 7)`.

`Vector4.addVectors` has landed. It writes the sum of two vectors into this one. `(1, 2, 3, 4)` plus `(5, 6, 7, 8)` becomes `(6, 8, 10, 12)`. Writing into the first vector still works. The second vector is unchanged.

`Vector4.addScaledVector` has landed. It adds `v * s` into this vector. `(1, 2, 3, 4)` plus `(4, 5, 6, 7)` scaled by 2 becomes `(9, 12, 15, 18)`. The other vector is unchanged.

`Vector4.sub` has landed. It subtracts another vector from this one. `(6, 8, 10, 12)` minus `(1, 2, 3, 4)` becomes `(5, 6, 7, 8)`. The other vector is unchanged.

`Vector4.subScalar` has landed. It subtracts one number from x, y, z, and w. `(5, 6, 7, 8)` minus 4 becomes `(1, 2, 3, 4)`, then minus -1 becomes `(2, 3, 4, 5)`.

`Vector4.subVectors` has landed. It writes the difference of two vectors into this one. `(5, 6, 7, 8)` minus `(1, 2, 3, 4)` becomes `(4, 4, 4, 4)`. Writing into the first vector still works. The second vector is unchanged.

`Vector4.multiply` has landed. It multiplies matching components. `(2, 4, 6, 8)` times `(5, 6, 7, 8)` becomes `(10, 24, 42, 64)`. The other vector is unchanged.

`Vector4.multiplyScalar` has landed. It multiplies x, y, z, and w by one number. `(2, 4, 6, 8)` times 2 becomes `(4, 8, 12, 16)`, then times -1 becomes `(-4, -8, -12, -16)`.

`Vector4.divide` has landed. It divides matching components. `(10, 24, 42, 64)` divided by `(5, 6, 7, 8)` becomes `(2, 4, 6, 8)`. The other vector is unchanged.

`Vector4.divideScalar` has landed. It divides by one number through `multiplyScalar(1 / scalar)`. `(2, 4, 6, 8)` divided by 2 becomes `(1, 2, 3, 4)`, then divided by -1 becomes `(-1, -2, -3, -4)`.

`Vector4.setAxisAngleFromQuaternion` has landed. It writes the quaternion axis into x, y, and z and the angle into w. The identity quaternion becomes axis `(1, 0, 0)` and angle 0. A quarter turn around Y becomes axis `(0, 1, 0)` and angle π/2. The quaternion is unchanged.

`Vector4.setAxisAngleFromRotationMatrix` has landed. It reads the axis and angle from the upper 3×3 of a pure rotation matrix. The identity matrix becomes axis `(1, 0, 0)` and angle 0. A quarter turn around Y becomes axis `(0, 1, 0)` and angle π/2. A half turn around X becomes axis `(1, 0, 0)` and angle π. The matrix is unchanged.

`Vector4.setFromMatrixPosition` has landed. It copies the last column. The identity matrix becomes `(0, 0, 0, 1)`. A matrix whose last column is `(3, 4, 5, 6)` becomes `(3, 4, 5, 6)`. The matrix is unchanged.

`Vector4.min` has landed. It keeps the smaller value of each component. `(0, 5, 2, 8)` against `(1, 4, 3, 7)` becomes `(0, 4, 2, 7)`. The other vector is unchanged.

`Vector4.max` has landed. It keeps the larger value of each component. `(0, 5, 2, 8)` against `(1, 4, 3, 7)` becomes `(1, 5, 3, 8)`. The other vector is unchanged.

`Vector4.clamp` has landed. It assumes min is less than max on each component. `(0, 5, 2, 9)` clamped by `(1, 0, 1, 0)` and `(3, 4, 4, 8)` becomes `(1, 4, 2, 8)`. `(2, 2, 2, 2)` inside `(0, 0, 0, 0)` and `(3, 3, 3, 3)` stays. The bounds are unchanged.

`Vector4.clampScalar` has landed. It assumes the lower number is less than the upper number. `(0, 5, 2, 9)` clamped to `[1, 4]` becomes `(1, 4, 2, 4)`. `(2, 3, 1, 4)` inside `[0, 5]` stays.

`Vector4.clampLength` has landed. It scales the vector so its length lies between min and max. Length 4 clamped to `[1, 2]` becomes length 2. Length 0.5 becomes 1. Length 4 inside `[1, 8]` stays. A zero vector stays zero.

`Vector4.floor` has landed. It rounds each component down. `(1.2, -1.2, 2.8, -2.8)` becomes `(1, -2, 2, -3)`.

`Vector4.ceil` has landed. It rounds each component up. `(1.2, -1.2, 2.8, -2.8)` becomes `(2, -1, 3, -2)`.

`Vector4.round` has landed. Half values round toward positive infinity. `(1.5, -1.5, 2.5, -2.5)` becomes `(2, -1, 3, -2)`.

`Vector4.roundToZero` has landed. It rounds each component toward zero. `(1.8, -1.8, 2.8, -2.8)` becomes `(1, -1, 2, -2)`.

`Vector4.negate` has landed. It flips the sign of every component. `(1, -2, 3, -4)` becomes `(-1, 2, -3, 4)`.

`Vector4.manhattanLength` has landed. It sums the absolute components. `(3, -4, 5, -6)` is 18. A zero vector is 0. The vector is not modified.

`Vector4.setLength` has landed. It divides by the current length, using 1 when that length is zero, then multiplies by the requested length. `(0, 0, 0, 4)` set to length 2 becomes `(0, 0, 0, 2)`, then set to 0 becomes zero. A zero vector set to 5 stays zero.

`Vector4.lerp` has landed. Alpha 0 keeps this vector and alpha 1 copies the other. `(1, 2, 3, 4)` toward `(5, 6, 7, 8)` at alpha 0.25 becomes `(2, 3, 4, 5)`. The other vector is unchanged.

`Vector4.lerpVectors` has landed. It writes the interpolation of two vectors into this one. Alpha 0.25 from `(1, 2, 3, 4)` toward `(5, 6, 7, 8)` is `(2, 3, 4, 5)`. Alpha 0 and 1 copy the endpoints. Both inputs stay unchanged.

`Vector4.equals` has landed. It compares x, y, z, and w. `(1, 2, 3, 4)` equals a copy of itself. Changing any one component makes it unequal. Neither vector is modified.

`Vector4.fromArray` has landed. Offset defaults to 0. `[1, 2, 3, 4, 5, 6, 7]` at offset 0 becomes `(1, 2, 3, 4)`, and at offset 2 becomes `(3, 4, 5, 6)`. The array is unchanged.

`Vector4.toArray` has landed. A missing array becomes `[x, y, z, w]`. `[9, 8, 7, 6, 5]` at offset 1 becomes `[9, 1, 2, 3, 4]` for `(1, 2, 3, 4)`. A short array is padded with zeros up to `offset + 4`. The same array is returned. The vector is unchanged.

`Vector4.fromBufferAttribute` has landed as `BufferAttribute.copy_to_vector4`, because `math` does not import `core`. It writes x, y, z, and the fourth component into the target. Index 1 of `[1, 2, 3, 4, 5, 6, 7, 8]` with item size 4 is `(5, 6, 7, 8)`. Item size 3 still reads a fourth value, so index 0 of `[1, 2, 3, 4, 5, 6]` is `(1, 2, 3, 4)`. The attribute is not modified. `Vector4.random` stays out, because it draws from `Math.random`.

`Box2` has landed. A box with no arguments is empty: the lower corner is `(+∞, +∞)` and the upper corner is `(-∞, -∞)`. Passing corners copies them, so later changes to those vectors leave the box alone.

`Box2.set` has landed. It copies both corners into the box. An empty box set to `(1, 2)` and `(3, 4)` becomes that box. Later changes to the source vectors leave the box alone.

`Box2.makeEmpty` has landed. It sets the lower corner to `(+∞, +∞)` and the upper corner to `(-∞, -∞)`. A box from `(1, 2)` to `(3, 4)` becomes empty.

`Box2.expandByPoint` has landed. It widens the box to include the point. An empty box expanded by `(1, 2)` becomes that point. Expanding it by `(0, 5)` reaches from `(0, 2)` to `(1, 5)`. The point is unchanged.

`Box2.setFromPoints` has landed. It empties the box, then expands it by each point. Points `(1, 2)` and `(0, 5)` become a box from `(0, 2)` to `(1, 5)`. An empty list leaves the box empty. The points are unchanged.

`Box2.setFromCenterAndSize` has landed. Center `(5, 6)` and size `(2, 4)` become a box from `(4, 4)` to `(6, 8)`. The center and the size are unchanged.

`Box2.copy` has landed. It copies both corners into the box. A box from `(1, 2)` to `(3, 4)` copied into an empty box becomes that box. Later changes to the source corners leave the copy alone.

`Box2.clone` has landed. It returns a new box with the same corners. Cloning a box from `(1, 2)` to `(3, 4)` yields that box. Later changes to the source corners leave the clone alone.

`Box2.isEmpty` has landed. A box is empty when either upper bound is below its lower bound. A fresh box is empty. A box from `(1, 2)` to `(3, 4)` is not. Equal corners `(1, 2)` and `(1, 2)` still hold that one point, so the box is not empty.

`Box2.getCenter` has landed. It writes the midpoint into the given vector. A box from `(1, 2)` to `(3, 4)` has center `(2, 3)`. An empty box writes `(0, 0)`. The box is unchanged.

`Box2.getSize` has landed. It writes the width and height into the given vector. A box from `(1, 2)` to `(3, 4)` has size `(2, 2)`. An empty box writes `(0, 0)`. The box is unchanged.

`Box2.expandByVector` has landed. It moves the lower corner back by the vector and the upper corner forward by the same vector. A box from `(1, 2)` to `(3, 4)` expanded by `(1, 2)` reaches from `(0, 0)` to `(4, 6)`. The vector is unchanged.

`Box2.expandByScalar` has landed. It grows each side by the scalar. A negative scalar shrinks the box. A box from `(1, 2)` to `(3, 4)` expanded by `1` reaches from `(0, 1)` to `(4, 5)`, and expanding by `-1` returns it to `(1, 2)` and `(3, 4)`.

`Box2.containsPoint` has landed. A point on or inside the bounds counts. In a box from `(1, 2)` to `(3, 4)`, `(2, 3)` and the corner `(1, 2)` are inside, and `(0, 3)` is outside. The point and the box are unchanged.

`Box2.containsBox` has landed. The other box must lie entirely on or inside the bounds. A box from `(1, 2)` to `(5, 6)` contains `(2, 3)` to `(4, 5)` and an identical copy of itself. A box from `(0, 3)` to `(4, 5)` sticks out, so it is not contained. Neither box changes.

`Box2.getParameter` has landed. It writes the point as a fraction of the box width and height. In a box from `(1, 2)` to `(3, 6)`, the point `(2, 4)` is `(0.5, 0.5)` and the lower corner `(1, 2)` is `(0, 0)`. The point and the box are unchanged.

`Box2.intersectsBox` has landed. Overlap and a shared edge both count. A box from `(1, 2)` to `(3, 4)` meets `(2, 3)` to `(4, 5)` and the edge-touching box from `(3, 2)` to `(5, 4)`. The box from `(4, 2)` to `(5, 4)` stays apart. Neither box changes.

`Box2.clampPoint` has landed. It writes the point clamped into the box. For a box from `(1, 2)` to `(3, 4)`, `(0, 5)` becomes `(1, 4)` and `(2, 3)` stays `(2, 3)`. The point and the box are unchanged.

`Box2.distanceToPoint` has landed. A point inside the box is distance `0`. For a box from `(1, 2)` to `(3, 4)`, the point `(0, 3)` is distance `1`. The point and the box are unchanged.

`Box2.intersect` has landed. It keeps the overlap of the two boxes. A box from `(1, 2)` to `(5, 6)` intersected with `(3, 0)` to `(4, 4)` becomes `(3, 2)` to `(4, 4)`. A box with no overlap becomes empty. The other box is unchanged.

`Box2.union` has landed. It grows the box until it covers both. A box from `(1, 2)` to `(3, 4)` united with `(0, 5)` to `(2, 6)` reaches from `(0, 2)` to `(3, 6)`. An empty box united with that second box becomes the second box. The other box is unchanged.

`Box2.translate` has landed. It adds the offset to both corners. A box from `(1, 2)` to `(3, 4)` moved by `(1, -2)` reaches from `(2, 0)` to `(4, 2)`. The offset is unchanged.

`Box2.equals` has landed. Both corners must match. A box from `(1, 2)` to `(3, 4)` equals a copy of itself and does not equal a box whose upper corner is `(3, 5)`. Neither box changes.

`Box3.setFromArray` has landed. It empties the box, then expands it by each group of three numbers. `[1, 2, 3, 0, 5, 4]` becomes a box from `(0, 2, 3)` to `(1, 5, 4)`. An empty list leaves the box empty. The array is unchanged.

`Box3.setFromBufferAttribute` has landed as `BufferAttribute.set_box3`, because `math` does not import `core`. It empties the box, then expands it by each vertex. Item size 3 of `[1, 2, 3, 0, 5, 4]` becomes a box from `(0, 2, 3)` to `(1, 5, 4)`. Item size 4 still reads only xyz, so the fourth components `9` and `8` stay out of the box. An empty attribute leaves the box empty. The attribute is unchanged.

`Box3.setFromCenterAndSize` has landed. Center `(5, 6, 7)` and size `(2, 4, 6)` become a box from `(4, 4, 4)` to `(6, 8, 10)`. The center and the size are unchanged.

`Box3.copy` has landed. It copies both corners into the box. A box from `(1, 2, 3)` to `(4, 5, 6)` copied into an empty box becomes that box. Later changes to the source corners leave the copy alone.

`Box3.clone` has landed. It returns a new box with the same corners. Cloning a box from `(1, 2, 3)` to `(4, 5, 6)` yields that box. Later changes to the source corners leave the clone alone.

`Box3.expandByVector` has landed. It moves the lower corner back by the vector and the upper corner forward by the same vector. A box from `(1, 2, 3)` to `(4, 5, 6)` expanded by `(1, 2, 3)` reaches from `(0, 0, 0)` to `(5, 7, 9)`. The vector is unchanged.

`Box3.expandByScalar` has landed. It grows each side by the scalar. A negative scalar shrinks the box. A box from `(1, 2, 3)` to `(4, 5, 6)` expanded by `1` reaches from `(0, 1, 2)` to `(5, 6, 7)`, and expanding by `-1` returns it to `(1, 2, 3)` and `(4, 5, 6)`.

`Box3.containsPoint` has landed. A point on or inside the bounds counts. In a box from `(1, 2, 3)` to `(4, 5, 6)`, `(2, 3, 4)` and the corner `(1, 2, 3)` are inside, and `(0, 3, 4)` is outside. The point and the box are unchanged.

`Box3.containsBox` has landed. The other box must lie entirely on or inside the bounds. A box from `(1, 2, 3)` to `(7, 8, 9)` contains `(2, 3, 4)` to `(6, 7, 8)` and an identical copy of itself. A box from `(0, 3, 4)` to `(6, 7, 8)` sticks out, so it is not contained. Neither box changes.

`Box3.getParameter` has landed. It writes the point as a fraction of the box width, height, and depth. In a box from `(1, 2, 3)` to `(3, 6, 5)`, the point `(2, 4, 4)` is `(0.5, 0.5, 0.5)` and the lower corner `(1, 2, 3)` is `(0, 0, 0)`. The point and the box are unchanged.

`Box3.intersectsBox` has landed. Overlap and a shared face both count. A box from `(1, 2, 3)` to `(4, 5, 6)` meets `(3, 4, 5)` to `(6, 7, 8)` and the face-touching box from `(4, 2, 3)` to `(6, 5, 6)`. The box from `(5, 2, 3)` to `(6, 5, 6)` stays apart. Neither box changes.

`Box3.clampPoint` has landed. It writes the point clamped into the box. For a box from `(1, 2, 3)` to `(4, 5, 6)`, `(0, 7, 3)` becomes `(1, 5, 3)` and `(2, 3, 4)` stays `(2, 3, 4)`. The point and the box are unchanged.

`Box3.intersectsSphere` has landed. A sphere meets the box when the closest point on the box is inside the sphere, including a tangent. For a box from `(1, 2, 3)` to `(4, 5, 6)`, a sphere at `(0, 3, 4)` with radius `1` touches the face, radius `0.5` stays apart, and a zero-radius sphere at `(2, 3, 4)` is inside. The sphere and the box are unchanged.

`Box3.intersectsPlane` has landed. The plane meets the box when the box's projected range crosses the plane, including a face. For a box from `(1, 2, 3)` to `(4, 5, 6)`, the plane `x = 2` intersects it. The plane `x = 0` and the plane `y = 0` with normal `(0, -1, 0)` stay apart. The plane and the box are unchanged.

`Box3.distanceToPoint` has landed. A point inside the box is distance `0`. For a box from `(1, 2, 3)` to `(4, 5, 6)`, the point `(0, 3, 4)` is distance `1`. The point and the box are unchanged.

`Box3.getBoundingSphere` has landed. It writes a sphere around the box. A box from `(0, 0, 0)` to `(2, 0, 0)` becomes a sphere at `(1, 0, 0)` with radius `1`. An empty box writes an empty sphere, center `(0, 0, 0)` and radius `-1`. The box is unchanged.

`Box3.intersect` has landed. It keeps the overlap of the two boxes. A box from `(1, 2, 3)` to `(5, 6, 7)` intersected with `(3, 0, 4)` to `(4, 4, 8)` becomes `(3, 2, 4)` to `(4, 4, 7)`. A box with no overlap becomes empty. The other box is unchanged.

`Box3.translate` has landed. It adds the offset to both corners. A box from `(1, 2, 3)` to `(4, 5, 6)` moved by `(1, -2, 3)` reaches from `(2, 0, 6)` to `(5, 3, 9)`. The offset is unchanged.

`Box3.equals` has landed. Both corners must match. A box from `(1, 2, 3)` to `(4, 5, 6)` equals a copy of itself and does not equal a box whose upper corner is `(4, 5, 7)`. Neither box changes.

`Box3.toJSON` has landed. It writes both corners as arrays. A box from `(1, 2, 3)` to `(4, 5, 6)` becomes `[1, 2, 3]` and `[4, 5, 6]`. Changing the arrays leaves the box alone.

`Box3.fromJSON` has landed. It reads both corners from arrays. `[1, 2, 3]` and `[4, 5, 6]` become a box from `(1, 2, 3)` to `(4, 5, 6)`. The arrays are unchanged.

`Triangle` has landed. A triangle with no arguments has all three corners at the origin. Passing corners copies them, so later changes to those vectors leave the triangle alone.

`Triangle.getNormal` has landed. It writes a unit normal into the given vector. Corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)` give `(0, 0, 1)`. Three copies of the same point give `(0, 0, 0)`. The corners are unchanged.

`Triangle.getBarycoord` has landed. It writes barycentric weights that sum to 1. For corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)`, the point `(1, 0, 0)` is `(0, 1, 0)`. A degenerate triangle writes `(0, 0, 0)` and returns nothing. The point and the corners are unchanged.

`Triangle.containsPoint` has landed. A point projected onto the triangle plane counts when it lands inside or on the boundary. For corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)`, `(0.25, 0.25, 0)` and the corner `(1, 0, 0)` are inside, and `(2, 0, 0)` is outside. A degenerate triangle contains nothing. The point and the corners are unchanged.

`Triangle.getInterpolation` has landed. It blends three values with the barycentric weights. For corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)`, the point `(0.5, 0.5, 0)` blends `(1, 0, 0)`, `(0, 1, 0)`, and `(0, 0, 1)` into `(0, 0.5, 0.5)`. A degenerate triangle writes `(0, 0, 0)` and returns nothing. The inputs are unchanged.

`Triangle.getInterpolatedAttribute` has landed on `BufferAttribute`. It reads three vertices and blends their xyz with the barycentric weights. For the attribute `[1, 0, 0, 0, 1, 0, 0, 0, 1]`, barycentric `(0, 0.5, 0.5)` writes `(0, 0.5, 0.5)`. The attribute and the weights are unchanged.

`Triangle.isFrontFacing` has landed. It is true when the cross product of `(c - b)` and `(a - b)` points against the direction. For corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)`, direction `(0, 0, -1)` is front facing and `(0, 0, 1)` is not. The corners and the direction are unchanged.

`Triangle.set` has landed. It copies three corners into the triangle. Setting `(1, 2, 3)`, `(4, 5, 6)`, and `(7, 8, 9)` stores those values. Later changes to the source vectors leave the triangle alone.

`Triangle.setFromPointsAndIndices` has landed. It copies three indexed points into the corners. Indices `0`, `1`, and `2` on `(0, 0, 1)`, `(1, 2, 3)`, and `(4, 5, 6)` store those corners. Later changes to the source points leave the triangle alone.

`Triangle.setFromAttributeAndIndices` has landed on `BufferAttribute`. It reads three indexed vertices into the corners. Indices `3`, `0`, and `1` on `[1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 0, 1]` store `(0, 0, 1)`, `(1, 2, 3)`, and `(4, 5, 6)`. The attribute is unchanged.

`Triangle.copy` has landed. It copies the three corners from another triangle. Copying `(1, 2, 3)`, `(4, 5, 6)`, and `(7, 8, 9)` stores those values. Later changes to the source leave the copy alone.

`Triangle.clone` has landed. It returns a new triangle with the same three corners. Cloning `(1, 2, 3)`, `(4, 5, 6)`, and `(7, 8, 9)` stores those values. Later changes to either triangle leave the other alone.

`Triangle.getArea` has landed. It is half the length of the cross product of `(c - b)` and `(a - b)`. Corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)` have area `0.5`. A triangle with three identical corners has area `0`. The corners are unchanged.

`Triangle.getMidpoint` has landed. It writes the average of the three corners into the target. Corners `(1, 2, 3)`, `(4, 5, 6)`, and `(7, 8, 9)` average to `(4, 5, 6)`. The corners are unchanged.

`Triangle.normal` has landed. It is the instance form of `getNormal`, and it writes the same unit normal as the static function. Corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)` give `(0, 0, 1)`. A triangle with three identical corners writes `(0, 0, 0)`. The corners are unchanged.

`Plane.setFromNormalAndCoplanarPoint` has landed. It copies the normal and sets the constant so the point lies on the plane. Normal `(0, 1, 0)` and point `(1, 2, 3)` give constant `-2`. Later changes to the source normal and point leave the plane alone.

`Plane.setFromCoplanarPoints` has landed. It builds the unit normal from `(c - b)` and `(a - b)`, then places the plane through the first point. Points `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)` give normal `(0, 0, 1)` and constant `0`. Three copies of the same point give a zero normal and constant `0`. The points are unchanged.

`Triangle.getPlane` has landed. It writes the plane through the three corners. Corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)` give normal `(0, 0, 1)` and constant `0`. The corners are unchanged.

`Triangle.barycoord` has landed. It is the instance form of `getBarycoord`. For corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)`, the point `(1, 0, 0)` is `(0, 1, 0)`. A triangle with three identical corners writes `(0, 0, 0)` and returns nothing. The point and the corners are unchanged.

`Triangle.interpolation` has landed. It is the instance form of `getInterpolation`. For corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)`, the point `(0.5, 0.5, 0)` blends `(1, 0, 0)`, `(0, 1, 0)`, and `(0, 0, 1)` into `(0, 0.5, 0.5)`. A triangle with three identical corners writes `(0, 0, 0)` and returns nothing. The inputs are unchanged.

`Triangle.contains` has landed. It is the instance form of `containsPoint`. For corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)`, `(0.25, 0.25, 0)` and the corner `(1, 0, 0)` are inside, and `(2, 0, 0)` is outside. A triangle with three identical corners contains nothing. The point and the corners are unchanged.

`Triangle.front_facing` has landed. It is the instance form of `isFrontFacing`. For corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)`, direction `(0, 0, -1)` is front facing and `(0, 0, 1)` is not. The corners and the direction are unchanged.

`Box3.intersectsTriangle` has landed. It uses the separating-axis test. The box `(0, 0, 0)`–`(1, 1, 1)` meets the triangle with corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)`, and misses the same triangle shifted to `z = 5`. An empty box misses the triangle. The box and the triangle are unchanged.

`Triangle.intersectsBox` has landed. It asks the box whether it meets this triangle. Corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)` meet the box `(0, 0, 0)`–`(1, 1, 1)`, and miss the box `(0, 0, 5)`–`(1, 1, 6)`. An empty box misses the triangle. The triangle and the box are unchanged.

`Triangle.closestPointToPoint` has landed. It writes the closest point on the triangle. For corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)`, the point `(0.25, 0.25, 3)` projects to `(0.25, 0.25, 0)`, and `(2, -1, 0)` lands on `(1, 0, 0)`. The point and the corners are unchanged.

`Triangle.equals` has landed. It is true when all three corners match. A triangle with corners `(1, 2, 3)`, `(4, 5, 6)`, and `(7, 8, 9)` equals its clone, and differs once the clone's last corner moves to `z = 0`.

`Plane.set` has landed. It copies the normal and stores the constant. Normal `(0, 1, 0)` and constant `-2` are stored. Later changes to the source normal leave the plane alone.

`Plane.negate` has landed. It flips both the normal and the constant. Normal `(0, 1, 0)` and constant `-2` become `(0, -1, 0)` and `2`. The point `(1, 2, 3)` stays on the plane.

`Plane.distanceToSphere` has landed. It subtracts the radius from the signed distance of the center. The plane `x = 0` and a sphere at `(3, 0, 0)` with radius `1` are distance `2` apart. The sphere and the plane are unchanged.

`Plane.projectPoint` has landed. It moves the point along the normal onto the plane. On the plane `x = 0`, the point `(3, 4, 5)` projects to `(0, 4, 5)`. The point and the plane are unchanged.

`Line3` has landed. A line with no arguments has both ends at the origin. Passing the ends copies them, so later changes to those vectors leave the line alone.

`Line3.set` has landed. It copies the start and the end into the line. Setting `(1, 2, 3)` and `(4, 5, 6)` stores those points. Later changes to the source vectors leave the line alone.

`Line3.copy` has landed. It copies both ends from another line. Copying `(1, 2, 3)` and `(4, 5, 6)` stores those points. Later changes to the source leave the copy alone.

`Line3.getCenter` has landed. It writes the midpoint of the two ends. Ends `(1, 2, 3)` and `(3, 6, 9)` average to `(2, 4, 6)`. The line is unchanged.

`Line3.delta` has landed. It writes the end minus the start. Ends `(1, 2, 3)` and `(4, 6, 9)` give `(3, 4, 6)`. The line is unchanged.

`Line3.distanceSq` has landed. It is the squared distance between the ends. Ends `(1, 2, 3)` and `(4, 6, 9)` are `61` apart, squared. The line is unchanged.

`Line3.distance` has landed. It is the distance between the ends. Ends `(1, 2, 3)` and `(4, 6, 3)` are `5` apart. The line is unchanged.

`Line3.at` has landed. It writes the point at parameter `t`. Ends `(1, 2, 3)` and `(5, 6, 7)` give `(3, 4, 5)` at `t = 0.5`, and the start at `t = 0`. The line is unchanged.

`Line3.closestPointToPointParameter` has landed. It returns where the point projects along the segment. On the segment from `(0, 0, 0)` to `(2, 0, 0)`, `(1, 5, 0)` is `0.5` and `(4, 0, 0)` is `2`. Clamping that last value gives `1`. A segment with equal ends returns `0`. The point and the line are unchanged.

`Line3.closestPointToPoint` has landed. It writes the nearest point on the line. On the segment from `(0, 0, 0)` to `(2, 0, 0)`, `(1, 5, 0)` lands on `(1, 0, 0)`. `(4, 0, 0)` stays at `(4, 0, 0)` without clamping and becomes `(2, 0, 0)` with clamping. The point and the line are unchanged.

`Line3.distanceSqToLine3` has landed. It returns the squared distance between two segments and, when given, writes the closest points. The segment from `(0, 0, 0)` to `(2, 0, 0)` and the one from `(0, 1, 0)` to `(2, 1, 0)` are `1` apart, squared, at `(0, 0, 0)` and `(0, 1, 0)`. A segment against itself is `0`. Two points at `(0, 0, 0)` and `(3, 0, 0)` are `9` apart, squared. The segments are unchanged.

`Line3.applyMatrix4` has landed. It transforms both ends. A segment from `(0, 0, 0)` to `(4, 0, 0)` translated by `(1, 2, 3)` becomes `(1, 2, 3)` to `(5, 2, 3)`. The matrix is unchanged.

`Line3.equals` has landed. It is true when both ends match. A segment from `(1, 2, 3)` to `(4, 5, 6)` equals a segment with the same ends, and differs once the other end moves to `z = 0`.

`Line3.clone` has landed. It returns a new segment with the same ends. Cloning `(1, 2, 3)` to `(4, 5, 6)` stores those points. Later changes to either segment leave the other alone.

`Plane.intersectLine` has landed. It writes where a segment crosses the plane. On the plane `x = 0`, the segment from `(-1, 2, 3)` to `(1, 2, 3)` hits `(0, 2, 3)`. The segment from `(1, 0, 0)` to `(2, 0, 0)` misses. A segment lying on the plane returns its start. The segment and the plane are unchanged.

`Plane.intersectsLine` has landed. It is true only when the ends sit on opposite sides of the plane. On the plane `x = 0`, the segment from `(-1, 0, 0)` to `(1, 0, 0)` crosses, the segment from `(1, 0, 0)` to `(2, 0, 0)` stays on one side, and a segment lying on the plane does not count. The segment and the plane are unchanged.

`Plane.intersectsBox` has landed. It asks the box whether it meets this plane. For a box from `(1, 2, 3)` to `(4, 5, 6)`, the plane `x = 2` intersects it and the plane `x = 0` stays apart. An empty box misses the plane. The plane and the box are unchanged.

`Sphere.intersectsPlane` has landed. It is true when the center is at most one radius from the plane. On the plane `x = 0`, a sphere at `(1, 0, 0)` with radius `1` touches, a sphere at `(3, 0, 0)` with radius `1` stays apart, and an empty sphere misses. The sphere and the plane are unchanged.

`Plane.intersectsSphere` has landed. It asks the sphere whether it meets this plane. On the plane `x = 0`, a sphere at `(1, 0, 0)` with radius `1` touches, a sphere at `(3, 0, 0)` with radius `1` stays apart, and an empty sphere misses. The plane and the sphere are unchanged.

`Plane.coplanarPoint` has landed. It writes the normal scaled by the negated constant. The plane `x = 2`, with normal `(1, 0, 0)` and constant `-2`, gives `(2, 0, 0)`. That point lies on the plane. The plane is unchanged.

`Plane.applyMatrix4` has landed. It transforms a point on the plane and the normal. The plane `x = 0` translated by `(2, 0, 0)` becomes the plane `x = 2`, with normal `(1, 0, 0)` and constant `-2`. The matrix is unchanged.

`Plane.translate` has landed. It subtracts the offset's projection on the normal from the constant. The plane `x = 0` moved by `(2, 3, 0)` keeps normal `(1, 0, 0)` and gets constant `-2`. The offset is unchanged.

`Plane.equals` has landed. It is true when the normal and the constant both match. The plane `x = 2` equals another with constant `-2` and normal `(1, 0, 0)`, and differs from constant `-1` or from normal `(1, 1, 0)`.

`Plane.clone` has landed. It returns a new plane with the same normal and constant. Cloning normal `(0, 1, 0)` and constant `-2` stores those values. Later changes to either plane leave the other alone.

`Plane.toJSON` has landed. It writes the normal as an array and keeps the constant beside it. Normal `(0, 1, 0)` and constant `-2` become `[0, 1, 0]` and `-2`. Changing the array leaves the plane alone.

`Plane.fromJSON` has landed. It reads the normal from an array and stores the constant. `[0, 1, 0]` and `-2` become normal `(0, 1, 0)` and constant `-2`. Changing the array afterwards leaves the plane alone.

`Sphere.set` has landed. It copies the center and stores the radius. Center `(1, 2, 3)` and radius `4` are stored. Later changes to the source center leave the sphere alone.

`Sphere.distanceToPoint` has landed. It is the distance from the point to the center, minus the radius. A unit sphere at the origin is `2` from `(3, 0, 0)` and `-1` from the origin. The point and the sphere are unchanged.

`Sphere.intersectsBox` has landed. It asks the box whether it meets this sphere. A sphere at `(0, 3, 4)` with radius `1` touches the box from `(1, 2, 3)` to `(4, 5, 6)`, radius `0.5` stays apart, and a zero-radius sphere at `(2, 3, 4)` counts as inside. The sphere and the box are unchanged.

`Sphere.clampPoint` has landed. It copies an inside point and pulls an outside point onto the surface. A unit sphere at the origin leaves `(0.5, 0, 0)` in place and turns `(2, 0, 0)` into `(1, 0, 0)`. The point and the sphere are unchanged.

`Sphere.getBoundingBox` has landed. It writes the box from the center expanded by the radius. Center `(1, 2, 3)` and radius `1` give the box from `(0, 1, 2)` to `(2, 3, 4)`. An empty sphere writes an empty box. The sphere is unchanged.

`Sphere.translate` has landed. It adds the offset to the center and leaves the radius alone. A unit sphere at the origin moved by `(1, 2, 3)` has center `(1, 2, 3)`. The offset is unchanged.

`Sphere.expandByPoint` has landed. A point already inside leaves the sphere alone. A unit sphere at the origin grown to include `(3, 0, 0)` moves its center to `(1, 0, 0)` and its radius to `2`. An empty sphere becomes a zero-radius sphere at the point. The point is unchanged.

`Sphere.union` has landed. It expands this sphere to enclose another. A unit sphere at the origin unioned with a unit sphere at `(4, 0, 0)` becomes center `(2, 0, 0)` and radius `3`. The same center keeps the larger radius. An empty sphere leaves this one unchanged. The other sphere is unchanged.

`Sphere.equals` has landed. It is true when the center and the radius both match. Center `(1, 2, 3)` and radius `4` equal another sphere with those values, and differ from radius `5` or from center `(0, 2, 3)`. Both spheres are unchanged.

`Sphere.clone` has landed. It returns a new sphere with the same center and radius. Cloning center `(1, 2, 3)` and radius `4` stores those values. Later changes to either sphere leave the other alone.

`Sphere.toJSON` has landed. It writes the center as an array and keeps the radius beside it. Center `(1, 2, 3)` and radius `4` become `[1, 2, 3]` and `4`. Changing the array leaves the sphere alone.

`Sphere.fromJSON` has landed. It reads the center from an array and stores the radius. `[1, 2, 3]` and `4` become center `(1, 2, 3)` and radius `4`. Changing the array afterwards leaves the sphere alone.

`Ray` has landed. A ray with no arguments starts at the origin and points along `(0, 0, -1)`. Passing the origin and the direction copies them, so later changes to those vectors leave the ray alone.

`Ray.set` has landed. It copies the origin and the direction. Origin `(1, 2, 3)` and direction `(4, 5, 6)` are stored. Later changes to those vectors leave the ray alone.

`Ray.copy` has landed. It copies another ray's origin and direction. Copying origin `(1, 2, 3)` and direction `(4, 5, 6)` stores those values. Later changes to the source leave the copy alone.

`Ray.at` has landed. It writes the origin plus the direction scaled by a distance. Origin `(1, 2, 3)` and direction `(0, 1, 0)` at distance `0.5` is `(1, 2.5, 3)`, and distance `0` is the origin. The ray is unchanged.

`Ray.lookAt` has landed. It points the direction from the origin at a position and normalizes it. Origin `(1, 2, 3)` looking at `(1, 5, 3)` gets direction `(0, 1, 0)`. The position is unchanged.

`Ray.recast` has landed. It moves the origin along the direction and leaves the direction alone. Origin `(1, 2, 3)` and direction `(0, 1, 0)` recast by `0.5` has origin `(1, 2.5, 3)`.

`Ray.closestPointToPoint` has landed. It writes the nearest point on the ray. The default ray, pointing along `(0, 0, -1)`, meets `(4, 5, -2)` at `(0, 0, -2)`. A point behind the origin, such as `(4, 5, 3)`, stays at the origin. The point and the ray are unchanged.

`Ray.distanceSqToPoint` has landed. It is the squared distance to the closest point on the ray. The default ray is `41` from `(4, 5, -2)`, `50` from `(4, 5, 3)` behind the origin, and `0` from `(0, 0, -2)` on the ray. The point and the ray are unchanged.

`Ray.distanceToPoint` has landed. It is the square root of that squared distance. The default ray is `5` from `(3, 4, -2)`, `3` from `(0, 0, 3)` behind the origin, and `0` from `(0, 0, -2)` on the ray. The point and the ray are unchanged.

`Ray.distanceSqToSegment` has landed. It returns the squared distance from the ray to a segment and, when given, writes the closest points. A ray from the origin along `(1, 0, 0)` meets the segment from `(2, -1, 0)` to `(2, 1, 0)` at `(2, 0, 0)`, so the squared distance is `0`. The parallel segment from `(0, 1, 0)` to `(2, 1, 0)` is `1` away, squared. The ray and the endpoints are unchanged.

`Ray.intersectSphere` has landed. It writes the first intersection in front of the ray. A ray from `(-2, 0, 0)` along `(1, 0, 0)` meets the unit sphere at `(-1, 0, 0)`. A ray from `(0, 3, 0)` along `(1, 0, 0)` misses. The default ray starts inside that sphere and exits at `(0, 0, -1)`. An empty sphere misses. The ray and the sphere are unchanged.

`Ray.intersectsSphere` has landed. It is true when the squared distance from the ray to the center is within the squared radius. A ray from `(-2, 0, 0)` along `(1, 0, 0)` meets the unit sphere. A ray from `(0, 3, 0)` misses, and a ray from `(2, 0, 0)` along `(1, 0, 0)` leaves the sphere behind. The default ray starts inside. An empty sphere misses. The ray and the sphere are unchanged.

`Ray.distanceToPlane` has landed. It returns the distance from the origin to the plane, or nothing when the ray misses. A ray from `(-2, 0, 0)` along `(1, 0, 0)` meets the plane `x = 0` at distance `2`. A ray pointing the other way from `(1, 0, 0)` misses. A ray parallel to the plane misses unless it already lies on it, in which case the distance is `0`. The ray and the plane are unchanged.

`Ray.intersectPlane` has landed. It writes the point at that distance. The same ray meets the plane `x = 0` at `(0, 0, 0)`. A ray from `(1, 0, 0)` along `(1, 0, 0)` misses and leaves the target alone. The ray and the plane are unchanged.

`Ray.intersectsPlane` has landed. It is true when the origin lies on the plane or the ray points toward it. A ray from `(-2, 0, 0)` along `(1, 0, 0)` meets the plane `x = 0`. A ray from `(1, 0, 0)` along `(1, 0, 0)` points away. A ray parallel to the plane misses unless its origin is already on the plane. The ray and the plane are unchanged.

`Ray.intersectBox` has landed. It writes the first intersection in front of the ray. A ray from `(-1, 0.5, 0.5)` along `(1, 0, 0)` meets the box from `(0, 0, 0)` to `(1, 1, 1)` at `(0, 0.5, 0.5)`. A ray from `(-1, 2, 0.5)` along `(1, 0, 0)` misses and leaves the target alone. The ray and the box are unchanged.

`Ray.intersectsBox` has landed. It asks whether that intersection exists. The same ray from `(-1, 0.5, 0.5)` meets the unit box, and the ray from `(-1, 2, 0.5)` misses. The ray and the box are unchanged.

`Ray.intersectTriangle` has landed. It writes the watertight intersection with a triangle. A ray from `(0.25, 0.25, 1)` along `(0, 0, -1)` meets the triangle `(0, 0, 0)`, `(1, 0, 0)`, `(0, 1, 0)` at `(0.25, 0.25, 0)`. A ray from `(2, 2, 1)` misses. Coming from below, backface culling misses and turning it off hits the same point. The vertices and the ray are unchanged.

`Ray.applyMatrix4` has landed. It transforms the origin and the direction. The default ray, translated by `(1, 2, 3)`, has origin `(1, 2, 3)` and keeps direction `(0, 0, -1)`. The matrix is unchanged.

`Ray.equals` has landed. It is true when the origin and the direction both match. Origin `(1, 2, 3)` and direction `(4, 5, 6)` equal another ray with those values, and differ when the origin becomes `(0, 2, 3)` or the direction's z becomes `0`. Both rays are unchanged.

`Ray.clone` has landed. It returns a new ray with the same origin and direction. Cloning origin `(1, 2, 3)` and direction `(4, 5, 6)` stores those values. Later changes to either ray leave the other alone.

`Color.set` has landed. It stores three linear channels. `(0.25, 0.5, 0.75)` is stored as those components.

`Color.setScalar` has landed. It writes the same value into every channel. `0.25` becomes `(0.25, 0.25, 0.25)`.

`MathUtils.clamp` has landed. It limits a number to a closed range. `1.5` clamped to `[0, 1]` is `1`, `-0.5` is `0`, and `0.25` stays `0.25`.

`MathUtils.euclideanModulo` has landed. It wraps the remainder so the result has the same sign as the divisor. `1.25` modulo `1` is `0.25`, and `-0.25` modulo `1` is `0.75`.

`Color.setHSL` has landed. It writes linear channels from hue, saturation, and lightness, already in the linear working space. Hue `0`, saturation `1`, lightness `0.5` is `(1, 0, 0)`. Saturation `0` and lightness `0.25` is `(0.25, 0.25, 0.25)`. Hue `1` wraps to the same red.

`Color.setStyle` parses CSS strings, so it stays later. `Color.copySRGBToLinear` has landed. It copies a color and converts each channel from sRGB to linear. `(0, 0.5, 1)` becomes `(0, 0.2140411404715882, 1)`. The source color stays `(0, 0.5, 1)`.

`Color.copyLinearToSRGB` has landed. It copies a color and converts each channel from linear to sRGB. `(0, 0.5, 1)` becomes `(0, 0.7353606352856507, 0.9999999999999999)`. The source color stays `(0, 0.5, 1)`.

`Color.convertSRGBToLinear` has landed. It converts this color's own channels from sRGB to linear. `(0, 0.5, 1)` becomes `(0, 0.2140411404715882, 1)`.

`Color.convertLinearToSRGB` has landed. It converts this color's own channels from linear to sRGB. `(0, 0.5, 1)` becomes `(0, 0.7353606352856507, 0.9999999999999999)`.

`Color.getHexString` has landed. It writes six lowercase hexadecimal digits. Linear black is `000000`. `setHex(0x00FF00)` reads back as `00ff00`.

`Color.getHSL` has landed. It reads hue, saturation, and lightness from the linear channels. Linear red `(1, 0, 0)` is hue `0`, saturation `1`, lightness `0.5`. `(0.25, 0.25, 0.25)` is hue `0`, saturation `0`, lightness `0.25`. The color is unchanged.

`Color.getRGB` has landed. It writes the linear channels into a target color. `(0.25, 0.5, 0.75)` is copied as those components. The source color is unchanged.

`Color.getStyle` has landed. It writes an sRGB `rgb()` string. Linear red `(1, 0, 0)` is `rgb(255,0,0)`. Linear black is `rgb(0,0,0)`. The color is unchanged.

`Color.offsetHSL` has landed. It adds to hue, saturation, and lightness, then writes the linear channels back. Linear red offset by `(0, 0, 0)` stays `(1, 0, 0)`. `(0.25, 0.25, 0.25)` offset by `(0, 0, 0.25)` becomes `(0.5, 0.5, 0.5)`.

`Color.add` has landed. It adds another color's channels. `(0.25, 0.5, 0.75)` plus `(0.25, 0.5, 0.25)` becomes `(0.5, 1, 1)`. The other color is unchanged.

`Color.addColors` has landed. It stores the sum of two colors. `(0.25, 0.5, 0.75)` plus `(0.25, 0.5, 0.25)` is written as `(0.5, 1, 1)`. Both inputs stay unchanged.

`Color.addScalar` has landed. It adds one value to every channel. `(0.25, 0.5, 0.75)` plus `0.25` becomes `(0.5, 0.75, 1)`.

`Color.sub` has landed. It subtracts another color and keeps each channel at or above zero. `(0.5, 1, 0.75)` minus `(0.25, 0.25, 0.25)` becomes `(0.25, 0.75, 0.5)`. `(0.25, 0.5, 0.75)` minus `(0.5, 0, 0)` becomes `(0, 0.5, 0.75)`. The other color is unchanged.

`Color.multiply` has landed. It multiplies channels. `(0.5, 0.25, 1)` times `(0.5, 0.5, 0.25)` becomes `(0.25, 0.125, 0.25)`. The other color is unchanged.

`Color.multiplyScalar` has landed. It multiplies every channel by one value. `(0.5, 0.25, 1)` times `0.5` becomes `(0.25, 0.125, 0.5)`.

`Color.lerp` is already present. `Color.lerpColors` has landed. It stores the blend of two colors. Alpha `0.25` from `(0, 0, 0)` toward `(1, 0.5, 0)` is `(0.25, 0.125, 0)`. Alpha `0` keeps the first color and alpha `1` keeps the second. Both inputs stay unchanged.

`MathUtils.lerp` has landed. It blends two numbers. `0.25` of the way from `0` to `1` is `0.25`. From `1` to `5`, factor `0` stays `1` and factor `1` stays `5`.

`Color.lerpHSL` has landed. It blends hue, saturation, and lightness, then writes the linear channels back. Halfway from `(0.25, 0.25, 0.25)` toward `(0.75, 0.75, 0.75)` is `(0.5, 0.5, 0.5)`. Factor `0` leaves `(0.25, 0.25, 0.25)`. The other color is unchanged.

`Color.setFromVector3` has landed. It copies the vector components into the channels. `(0.25, 0.5, 0.75)` is stored as those components. The vector is unchanged.

`Color.applyMatrix3` has landed. It transforms the channels by a column-major 3×3 matrix. Swapping the first two axes turns `(0.25, 0.5, 0.75)` into `(0.5, 0.25, 0.75)`. The matrix is unchanged.

`Color.equals` has landed. It is true when all three channels match. `(0.25, 0.5, 0.75)` equals another color with those values, and differs when any channel is `0`. Both colors are unchanged.

`Color.fromArray` has landed. It reads three channels from an array. The default offset reads `(1, 2, 3)` from `[1, 2, 3, 0.25, 0.5, 0.75]`. Offset `3` reads `(0.25, 0.5, 0.75)`. The array is unchanged.

`Color.toArray` has landed. It writes three channels. `(0.25, 0.5, 0.75)` becomes `[0.25, 0.5, 0.75]`. Writing at offset `1` into `[9, 8, 7, 6]` leaves `9` and stores the channels after it. A one-element array at offset `2` grows to `[4, 0, 0.25, 0.5, 0.75]`. The color is unchanged.

`Color.fromBufferAttribute` reads a `BufferAttribute`, so it stays with attributes. `Color.toJSON` has landed. It returns the sRGB hexadecimal integer. Linear black is `0`. `setHex(0x00FF00)` returns `65280`. Linear red `(1, 0, 0)` returns `16711680`. The color is unchanged.

`Euler.clone` has landed. It returns a new euler with the same angles and order. Cloning `(1, 2, 3)` in order `ZYX` stores those values. Later changes to either euler leave the other alone. The change callback is not copied.

`Euler.setFromVector3` has landed. It writes the vector components as angles. `(1, 2, 3)` is stored as those angles. Omitting the order keeps `XYZ`. Passing `ZYX` stores that order. The vector is unchanged.

`Euler.equals` has landed. It is true when the angles and the order both match. `(1, 2, 3)` in order `ZYX` equals another euler with those values, and differs when `x` is `0` or the order is `XYZ`. Both eulers are unchanged.

`Euler.fromArray` has landed. It reads three angles from an array. The order is a separate argument, because the array holds only numbers. `[1, 2, 3]` written onto an euler in order `YXZ` stores those angles and keeps `YXZ`. Passing `ZYX` stores that order. The array is unchanged.

`Euler.toArray` has landed. It writes three angles and returns the order beside the array. `(1, 2, 3)` in order `ZYX` becomes `[1, 2, 3]` and `ZYX`. Writing at offset `1` into `[9, 8, 7, 6]` leaves `9` and stores the angles after it. A one-element array at offset `2` grows to `[4, 0, 1, 2, 3]`. The euler is unchanged.

`Frustum.set` has landed. It copies six planes. Constants `1` through `6`, with the second normal `(0, 1, 0)`, are stored on the frustum. Later changes to those planes leave the frustum alone.

`Frustum.copy` has landed. It copies another frustum's six planes. Those same constants and the second normal `(0, 1, 0)` are stored on the copy. Later changes to the source frustum leave the copy alone.

`Frustum.intersectsObject` needs `Object3D`, and `Frustum.intersectsSprite` needs a sprite, so they stay later. `Frustum.intersectsBox` has landed. It rejects a box only when that box lies fully outside one plane. The unit-cube frustum accepts the box from `(0.25, 0.25, 0.25)` to `(0.75, 0.75, 0.75)` and rejects the box from `(-2, -2, -2)` to `(-1, -1, -1)`. The box and the frustum are unchanged.

`Frustum.containsPoint` has landed. A point is inside when it is on the inner side of every plane, including the plane itself. The unit-cube frustum accepts `(0.5, 0.5, 0.5)` and `(0, 0.5, 0.5)`, and rejects `(-1, 0.5, 0.5)`. The point and the frustum are unchanged.

`Frustum.clone` has landed. It returns a new frustum with the same six planes. Constants `1` through `6` and the second normal `(0, 1, 0)` are stored on the clone. Later changes to either frustum leave the other alone.

`Matrix3.extractBasis` has landed. It writes the three columns into three vectors. The matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` gives axes `(1, 4, 7)`, `(2, 5, 8)`, and `(3, 6, 9)`. The matrix is unchanged.

`Matrix3.multiply` calls `multiplyMatrices`, so that product lands first. `Matrix3.multiplyMatrices` has landed. It stores the product of two matrices. Scaling by `(2, 3, 4)` times the matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` writes elements `[2, 12, 28, 4, 15, 32, 6, 18, 36]`. Both inputs stay unchanged.

`Matrix3.multiply` has landed. It post-multiplies this matrix by another. Scaling by `(2, 3, 4)` times the matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` writes elements `[2, 12, 28, 4, 15, 32, 6, 18, 36]`. The other matrix stays unchanged.

`Matrix3.premultiply` has landed. It pre-multiplies this matrix by another. The matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` times scaling by `(2, 3, 4)` writes elements `[2, 8, 14, 6, 15, 24, 12, 24, 36]`. The other matrix stays unchanged.

`Matrix3.multiplyScalar` has landed. It multiplies every element by a scalar. The matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` times `2` writes elements `[2, 8, 14, 4, 10, 16, 6, 12, 18]`.

`Matrix3.transposeIntoArray` has landed. It writes the transpose into an array and leaves the matrix unchanged. The matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` writes `[1, 2, 3, 4, 5, 6, 7, 8, 9]`. A short array grows with zeros up to nine elements.

`Matrix3.setUvTransform` has landed. It builds a UV matrix from offset, repeat, rotation, and center. Offset `(0.25, 0.5)`, repeat `(2, 3)`, rotation `0`, and center `(1, 0)` write elements `[2, 0, 0, 0, 3, 0, -0.75, 0.5, 1]`.

`Matrix3.scale` calls `makeScale`, so that constructor lands first. `Matrix3.makeScale` has landed. It stores a 2D scale. Scaling by `(2, 3)` writes elements `[2, 0, 0, 0, 3, 0, 0, 0, 1]`.

`Matrix3.scale` has landed. It pre-multiplies a 2D scale. Scaling the matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` by `(2, 3)` writes elements `[2, 12, 7, 4, 15, 8, 6, 18, 9]`.

`Matrix3.rotate` calls `makeRotation`, so that constructor lands first. `Matrix3.makeRotation` has landed. It stores a counterclockwise 2D rotation. Angle `0` writes the identity `[1, 0, 0, 0, 1, 0, 0, 0, 1]`.

`Matrix3.rotate` has landed. It pre-multiplies a rotation of the negated angle. Rotating the matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` by angle `0` leaves elements `[1, 4, 7, 2, 5, 8, 3, 6, 9]`.

`Matrix3.translate` calls `makeTranslation`, so that constructor lands first. `Matrix3.makeTranslation` has landed. It stores a 2D translation from two numbers. Translating by `(0.25, 0.5)` writes elements `[1, 0, 0, 0, 1, 0, 0.25, 0.5, 1]`. The `Vector2` argument stays out.

`Matrix3.translate` has landed. It pre-multiplies a 2D translation. Translating the matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` by `(0.25, 0.5)` writes elements `[2.75, 7.5, 7, 4, 9, 8, 5.25, 10.5, 9]`.

`Matrix3.equals` has landed. It compares all nine elements. The matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` matches a copy, and differs once the first element is `0`.

`Matrix3.fromArray` has landed. It reads nine column-major elements. `[1, 4, 7, 2, 5, 8, 3, 6, 9]` stores those values. The same nine numbers at offset `1` in a longer array store the same matrix.

`Matrix3.toArray` has landed. It writes nine column-major elements. The matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` writes `[1, 4, 7, 2, 5, 8, 3, 6, 9]`. Offset `1` into a ten-element array keeps the first value and writes the matrix after it. A one-element array at offset `2` grows to length `11`. The matrix is unchanged.

`Matrix4.copyPosition` has landed. It copies only the translation. A translation of `(0.25, 0.5, 0.75)` is stored in elements `12`, `13`, and `14`, while element `0` and element `15` stay `1`. Later changes to the source leave the copy alone.

`Matrix4.setFromMatrix3` has landed. It copies a 3×3 matrix into the upper left and writes a homogeneous last row and column. The matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` writes `[1, 4, 7, 0, 2, 5, 8, 0, 3, 6, 9, 0, 0, 0, 0, 1]`. Later changes to the 3×3 matrix leave the 4×4 matrix alone.

`Matrix4.extractBasis` has landed. It writes the first three columns into three vectors. Scaling by `(2, 3, 4)` gives axes `(2, 0, 0)`, `(0, 3, 0)`, and `(0, 0, 4)`. A matrix whose affine determinant is `0` writes the identity axes instead. The matrix is unchanged.

`Matrix4.makeBasis` has landed. It stores three axes and a zero translation. Axes `(2, 0, 0)`, `(0, 3, 0)`, and `(0, 0, 4)` write elements `0`, `5`, `10`, and `15` as `2`, `3`, `4`, and `1`. Later changes to an axis leave the matrix alone.

`Matrix4.multiplyScalar` has landed. It multiplies every element by a scalar. A translation of `(0.25, 0.5, 0.75)` times `2` writes elements `0`, `5`, `10`, and `15` as `2`, and elements `12`, `13`, and `14` as `0.5`, `1`, and `1.5`.

`Matrix4.makeRotationX` has landed. It stores a rotation around the X axis. Angle `0` replaces a translation of `(0.25, 0.5, 0.75)` with the identity: elements `0`, `5`, `10`, and `15` are `1`, and element `12` is `0`.

`Matrix4.makeRotationY` has landed. It stores a rotation around the Y axis. Angle `0` replaces a translation of `(0.25, 0.5, 0.75)` with the identity: elements `0`, `5`, `10`, and `15` are `1`, and elements `2` and `8` are `0`.

`Matrix4.makeRotationZ` has landed. It stores a rotation around the Z axis. Angle `0` replaces a translation of `(0.25, 0.5, 0.75)` with the identity: elements `0`, `5`, `10`, and `15` are `1`, and elements `1` and `4` are `0`.

`Matrix4.makeRotationAxis` has landed. It stores a rotation around a unit axis. Angle `0` around `(0, 1, 0)` replaces a translation of `(0.25, 0.5, 0.75)` with the identity: elements `0`, `5`, `10`, and `15` are `1`, and element `12` is `0`. Later changes to the axis leave the matrix alone.

`Matrix4.makeScale` has landed. It stores a scale. Scaling by `(2, 3, 4)` replaces a translation of `(0.25, 0.5, 0.75)`: elements `0`, `5`, `10`, and `15` are `2`, `3`, `4`, and `1`, and element `12` is `0`.

`Matrix4.makeShear` has landed. It stores six shear terms. Shearing by `xy = 2`, `xz = 3`, `yx = 4`, `yz = 5`, `zx = 6`, and `zy = 7` replaces a translation of `(0.25, 0.5, 0.75)` and writes `[1, 2, 3, 0, 4, 1, 5, 0, 6, 7, 1, 0, 0, 0, 0, 1]`.

`Matrix4.fromArray` has landed. It reads sixteen column-major elements. The scale `(2, 3, 4)` is stored from `[2, 0, 0, 0, 0, 3, 0, 0, 0, 0, 4, 0, 0, 0, 0, 1]`. The same sixteen numbers at offset `1` store the same matrix.

`Matrix4.toArray` has landed. It writes sixteen column-major elements. Scaling by `(2, 3, 4)` writes `[2, 0, 0, 0, 0, 3, 0, 0, 0, 0, 4, 0, 0, 0, 0, 1]`. Offset `1` into a seventeen-element array keeps the first value and writes the matrix after it. A one-element array at offset `2` grows to length `18`. The matrix is unchanged.

`Quaternion.slerpFlat` has landed. It writes a spherical interpolation of two flat quaternions. Identical quaternions `(0, 0, 0, 1)` at offset `1`, with factor `0.25`, write `[0, 0, 0, 1]`. Both source arrays stay unchanged.

`Quaternion.multiplyQuaternionsFlat` has landed. It multiplies two flat quaternions into an array and returns that array. The identity `(0, 0, 0, 1)` times `(0.25, 0.5, 0.75, 1)` at offset `1` writes `[0.25, 0.5, 0.75, 1]`. Both source arrays stay unchanged.

`Quaternion` `x` setter has landed as `setX`. It writes `x` and runs the change callback. Setting `x` to `0.25` on `(0, 0.5, 0.25, 1)` stores that `x` and leaves the other components. The callback runs once.

`Quaternion` `y` setter has landed as `setY`. It writes `y` and runs the change callback. Setting `y` to `0.5` on `(0.25, 0, 0.25, 1)` stores that `y` and leaves the other components. The callback runs once.

`Quaternion` `z` setter has landed as `setZ`. It writes `z` and runs the change callback. Setting `z` to `0.25` on `(0.25, 0.5, 0, 1)` stores that `z` and leaves the other components. The callback runs once.

`Quaternion` `w` setter has landed as `setW`. It writes `w` and runs the change callback. Setting `w` to `0.75` on `(0.25, 0.5, 0.25, 1)` stores that `w` and leaves the other components. The callback runs once.

`Quaternion.setFromUnitVectors` has landed. It stores the rotation that takes one unit direction onto another. `(1, 0, 0)` onto itself is `(0, 0, 0, 1)`. `(1, 0, 0)` onto `(-1, 0, 0)` is `(0, 1, 0, 0)`. The direction vectors stay unchanged.

`Quaternion.angleTo` has landed. It returns the angle in radians between two quaternions. The identity against itself is `0`, and against `(0, 0, 0, -1)` is also `0`. Both quaternions stay unchanged.

`Quaternion.rotateTowards` has landed. It rotates toward another quaternion by an angular step and does not pass the target. The identity rotated toward `(0, 0, 0, -1)` by `1` stays `(0, 0, 0, 1)`. The change callback does not run. The target stays unchanged.

`Quaternion.lengthSq` has landed. It returns the sum of the squared components. `(0.25, 0.5, 0.25, 0.75)` has squared length `0.9375`. The quaternion stays unchanged.

`Quaternion.slerpQuaternions` has landed. It copies the first quaternion and interpolates toward the second. `(0, 1, 0, 0)` toward itself with factor `0.25` stays `(0, 1, 0, 0)`. Later changes to either source leave the result alone.

`Quaternion.random` has landed. It stores a uniformly random unit quaternion. The squared length is `1`. The change callback runs once.

`Quaternion.equals` has landed. It compares all four components. `(0.25, 0.5, 0.25, 0.75)` matches a copy, and differs once `w` is `0`.

`Quaternion.fromArray` has landed. It reads four components and runs the change callback. `[0.25, 0.5, 0.25, 0.75]` stores those components. The same four numbers at offset `1` in a longer array store the same quaternion.

`Quaternion.toArray` has landed. It writes four components and leaves the quaternion unchanged. `(0.25, 0.5, 0.25, 0.75)` fills a new array. The same components at offset `1` keep the leading value. A one-element array at offset `2` grows to length `6` and pads the gap with `0`. The change callback does not run. `Quaternion.fromBufferAttribute` reads a `BufferAttribute`, so it stays with attributes.

`Quaternion.toJSON` has landed. It returns `[x, y, z, w]`. `(0.25, 0.5, 0.25, 0.75)` serializes to those four numbers. The quaternion is unchanged and the change callback does not run.

`MathUtils.mapLinear` has landed. It maps a number from one range onto another. `0.25` from `[0, 1]` onto `[0, 4]` is `1`. The endpoints `0` and `1` map onto `10` and `20`.

`MathUtils.inverseLerp` has landed. It returns where a number sits between two endpoints. `1` between `0` and `4` is `0.25`. The endpoints themselves are `0` and `1`. Equal endpoints return `0`.

`MathUtils.damp` has landed. It eases from the current value toward a target. With `lambda` `0` or `dt` `0`, `4` toward `8` stays `4`. Equal values stay put. From `0` toward `4` with `lambda` `1` and `dt` `1` is about `2.5284822353142307`.

`MathUtils.pingpong` has landed. It folds a value back and forth between `0` and a length. With the default length `1`, `0.25` stays `0.25`, `1.25` folds to `0.75`, and both `0` and `2` are `0`. A negative `-0.25` folds to `0.25`. Length `2` folds `3` to `1`.

`MathUtils.smoothstep` has landed. It eases between two endpoints and clamps outside them. Below `0` and at `0` the result is `0`. At `1` and above it the result is `1`. The midpoint `0.5` stays `0.5`. `0.25` between `0` and `1` is `0.15625`.

`MathUtils.smootherstep` has landed. It eases the same way, with flat first and second derivatives at the endpoints. Below `0` and at `0` the result is `0`. At `1` and above it the result is `1`. The midpoint `0.5` stays `0.5`. `0.25` between `0` and `1` is `0.103515625`.

`MathUtils.randInt` has landed. It returns a number from a closed range. `0` through `0` is `0`, and `2` through `2` is `2`. A draw from `1` through `3` is `1`, `2`, or `3`.

`MathUtils.randFloat` has landed. It returns a number from a half-open range. `2` through `2` is `2`. A draw from `0` up to `1` stays in `[0, 1)`. A draw from `1` up to `4` stays in `[1, 4)`.

`MathUtils.randFloatSpread` has landed. It returns a number centered on `0`. A range of `0` is `0`. A range of `4` stays in `(-2, 2]`.

`MathUtils.seededRandom` has landed. It draws from the Mulberry32 sequence in `[0, 1)`. The default seed `1234567` starts at `0.6074679309967905`. Seed `1` starts at `0.6270739405881613`, then `0.002735721180215478`, then `0.5274470399599522`. Passing seed `1` again repeats the first value.

`MathUtils.isPowerOfTwo` has landed. It accepts a positive integer that is a power of two. `1`, `2`, and `8` are powers of two. `3`, `6`, `0`, `-2`, and `1.5` are not.

`MathUtils.ceilPowerOfTwo` has landed. It returns the smallest power of two that is not below the value. `0.5` stays `0.5`. `1` stays `1`. `3` and `4` become `4`. `5` becomes `8`. `9` becomes `16`.

`MathUtils.floorPowerOfTwo` has landed. It returns the largest power of two that is not above the value. `0.5` stays `0.5`, and `0.6` drops to `0.5`. `1` stays `1`. `3` drops to `2`. `4` stays `4`, and `5` drops to `4`. `9` drops to `8`.

`MathUtils.setQuaternionFromProperEuler` has landed. It writes an intrinsic proper Euler rotation into a quaternion. Angles `0`, `0`, `0` in order `XYX` store the identity `(0, 0, 0, 1)` and run the change callback. Angles `0.5`, `0.25`, `0.125` in order `XYX` store about `(0.3050397769831039, 0.12248959836900034, 0.023239781325963473, 0.9441434982635958)`. The same angles in order `ZYZ` store about `(-0.023239781325963473, 0.12248959836900034, 0.3050397769831039, 0.9441434982635958)`.

`MathUtils.denormalize` has landed. The typed-array constructor is `ArrayComponentType`, because `math` has no typed arrays. `Float32` leaves `0.25` as `0.25`. `Uint8` and `Uint8Clamped` map `255` to `1` and `0` to `0`. `Uint16` maps `65535` to `1`, and `Uint32` maps `4294967295` to `1`. `Int8` maps `-127` and `-128` to `-1`. `Int16` maps `-32768` to `-1`, and `Int32` maps `-2147483648` to `-1`.

`MathUtils.normalize` has landed. It packs a unit-range value back into the same component type. `Float32` leaves `0.25` as `0.25`. `Uint8` maps `0` to `0`, `0.25` to `64`, and `1` to `255`. `Uint8Clamped` also maps `1` to `255`. `Uint16` maps `1` to `65535`, and `Uint32` maps `1` to `4294967295`. `Int8` maps `1` to `127` and `-1` to `-127`. `Int16` maps `1` to `32767`, and `Int32` maps `1` to `2147483647`.

`MathUtils.generateUUID` has landed. It returns a 36-character lowercase UUID. The hyphens sit at indexes `8`, `13`, `18`, and `23`. The version character is `4`. The variant character is `8`, `9`, `a`, or `b`.

`Matrix2` has landed. `new` stores the column-major identity `[1, 0, 0, 1]`.

`Matrix2.set` has landed. Its arguments are row-major and the storage is column-major. `set(11, 12, 21, 22)` stores `[11, 21, 12, 22]`.

`Matrix2.identity` has landed. It replaces those elements with the column-major identity `[1, 0, 0, 1]`.

`Matrix2.fromArray` has landed. It reads four column-major elements. `[11, 21, 12, 22]` stores those elements. The same four numbers at offset `1` in a longer array store the same matrix.

`SphericalHarmonics3` has landed. `new` stores nine zero coefficients. The first and the last are `(0, 0, 0)`.

`SphericalHarmonics3.set` has landed. It copies nine coefficients. The first becomes `(1, 2, 3)` and the last becomes `(4, 5, 6)`. The middle stays `(0, 0, 0)`. Changing the source afterward leaves the copy at `(1, 2, 3)`.

`SphericalHarmonics3.zero` has landed. It clears every coefficient. After the first is `(1, 2, 3)` and the last is `(4, 5, 6)`, both return to `(0, 0, 0)`.

`SphericalHarmonics3.getAt` has landed. It writes the radiance along a unit normal and leaves the normal unchanged. A zero probe along `(0, 1, 0)` writes `(0, 0, 0)`. With the first coefficient `(1, 0, 0)`, that direction writes `(0.282095, 0, 0)`. With only the fourth coefficient `(1, 0, 0)` and normal `(1, 0, 0)`, the result is `(0.488603, 0, 0)`.

`SphericalHarmonics3.getIrradianceAt` has landed. It writes the irradiance along a unit normal and leaves the normal unchanged. A zero probe along `(0, 1, 0)` writes `(0, 0, 0)`. With the first coefficient `(1, 0, 0)`, that direction writes `(0.886227, 0, 0)`. With only the fourth coefficient `(1, 0, 0)` and normal `(1, 0, 0)`, the result is `2 * 0.511664` on x.

`SphericalHarmonics3.add` has landed. It adds nine coefficients and leaves the source unchanged. `(1, 2, 3)` plus `(4, 5, 6)` is `(5, 7, 9)`. The last coefficient `(1, 0, 0)` plus `(0, 1, 0)` is `(1, 1, 0)`. The middle stays `(0, 0, 0)`.

`SphericalHarmonics3.addScaledSH` has landed. It adds a scaled copy and leaves the source unchanged. `(1, 2, 3)` plus twice `(4, 5, 6)` is `(9, 12, 15)`. The last coefficient `(1, 0, 0)` plus twice `(0, 1, 0)` is `(1, 2, 0)`. The middle stays `(0, 0, 0)`.

`SphericalHarmonics3.scale` has landed. It multiplies every coefficient by the same factor. `(1, 2, 3)` scaled by `2` is `(2, 4, 6)`. The last coefficient `(4, 5, 6)` becomes `(8, 10, 12)`. The middle stays `(0, 0, 0)`.

`SphericalHarmonics3.lerp` has landed. It blends toward another probe and leaves that probe unchanged. Factor `0` stays at `(0, 0, 0)`. Factor `0.25` of the way from `(0, 0, 0)` toward `(4, 8, 12)` is `(1, 2, 3)`. The last coefficient moves a quarter of the way toward `(4, 0, 0)`, which is `(1, 0, 0)`.

`SphericalHarmonics3.equals` has landed. It compares all nine coefficients. Two zero probes match. They differ once the first coefficient is `(1, 2, 3)`. They match again when both hold that vector, and differ once the last coefficient is `(4, 5, 6)`.

`SphericalHarmonics3.copy` has landed. It copies nine coefficients. The first becomes `(1, 2, 3)` and the last becomes `(4, 5, 6)`. The middle stays `(0, 0, 0)`. Changing the source afterward leaves the copy at `(1, 2, 3)`.

`SphericalHarmonics3.clone` has landed. It returns a new probe with the same coefficients. The first is `(1, 2, 3)` and the last is `(4, 5, 6)`. The middle stays `(0, 0, 0)`. Changing the original afterward leaves the clone at `(1, 2, 3)`.

`SphericalHarmonics3.fromArray` has landed. It reads nine coefficients as flat triples. The first triple `(1, 2, 3)` and the last triple `(4, 5, 6)` land in those coefficients. The middle stays `(0, 0, 0)`. The same 27 numbers at offset `1` store the same probe, and the source array is unchanged.

`SphericalHarmonics3.toArray` has landed. It writes 27 numbers and leaves the probe unchanged. `(1, 2, 3)` and `(4, 5, 6)` occupy the first and last triples. A one-element array at offset `1` keeps the leading value and grows to length `28`. The same array at offset `2` grows to length `29` and pads the gap with `0`.

`SphericalHarmonics3.getBasisAt` has landed. It writes nine basis weights for a unit normal and leaves the normal unchanged. An empty array grows to length `9`. Along `(0, 1, 0)`, the first weight is `0.282095`, the second is `0.488603`, the seventh is `-0.315392`, and the ninth is `-0.546274`.

`FrustumArray` has landed. `new` stores no frustums and a count of `0`. The coordinate system starts as WebGL.

`FrustumArray.intersectsSphere` has landed. With `count` `0` it is false, including when a frustum is already stored. A unit-cube frustum and a sphere of radius `0.25` at `(0.5, 0.5, 0.5)` is true. The same radius at `(-2, 0, 0)` stays false while `count` is `1`, and becomes true once a second frustum with constant `10` is counted. `setFromArrayCamera` reads an `ArrayCamera`, `intersectsObject` reads an `Object3D`, and `intersectsSprite` reads a sprite, so those three stay out of `math`.

`FrustumArray.intersectsBox` has landed. With `count` `0` it is false, including when a frustum is already stored. A unit-cube frustum accepts the box from `(0.25, 0.25, 0.25)` to `(0.75, 0.75, 0.75)`. The box from `(-2, -2, -2)` to `(-1, -1, -1)` stays false while `count` is `1`, and becomes true once a second frustum with constant `10` is counted.

`FrustumArray.containsPoint` has landed. With `count` `0` it is false, including when a frustum is already stored. A unit-cube frustum contains `(0.5, 0.5, 0.5)` and the face point `(0, 0.5, 0.5)`. The point `(-1, 0.5, 0.5)` stays false while `count` is `1`, and becomes true once a second frustum with constant `10` is counted.

`FrustumArray.copy` has landed. It copies the coordinate system and the counted frustums. A WebGPU source with plane constants `1` through `6` lands those values, and a later edit of the source leaves the copy at constant `1`. A second frustum with constant `10` grows the destination to length `2`. Copying a count of `0` sets the count to `0` and leaves both stored frustums in place.

`FrustumArray.clone` has landed. It returns a new array with the same coordinate system and counted frustums. A WebGPU source with plane constants `1` through `6` produces a clone whose first constant stays `1` after the source is edited, and whose last constant stays `6` after the clone is edited. An empty array clones to a count of `0` in WebGL coordinates. `setFromArrayCamera`, `intersectsObject`, and `intersectsSprite` still stay out of `math`.

`Interpolant` has landed. `new` stores the parameter positions and sample values by reference. Positions `(0, 1, 2)` and six sample numbers with `sampleSize` `2` keep a cached index of `0` and a zero result buffer of length `2`. A supplied result buffer `(1, 2, 3)` is stored as given. Editing the position array changes the stored `0` to `9`.

`Interpolant.copySampleValue_` has landed. It writes one sample into the result buffer and returns that buffer. With `sampleSize` `2`, index `0` writes `(10, 20)` and leaves a longer buffer's third value `3` in place. Index `2` writes `(50, 60)`. The sample values stay `(10, ..., 60)`.

`Interpolant.interpolate_` has landed. The base method aborts. Calling it with interval index `1`, previous time `0`, time `0.5`, and next time `1` does not write a sample.

`Interpolant.intervalChanged_` has landed. The base method does nothing. Interval index `1` between times `0` and `1` leaves the cached index at `0`, the result buffer at `(1, 2, 3)`, and the sample values at `(10, ..., 60)`.

`Interpolant.evaluate` has landed. Time `-1` on positions `(0, 1, 2, 3, 4)` and samples `(10, 20, 30, 40, 50)` copies `10` and keeps the cached index at `0`. Time `10` and the last position `4` copy `50` and set the cached index to `5`. Time `1.5` reaches the base `interpolate_` and aborts. `getSettings_` stays later.

`Interpolant.getSettings_` has landed. A new interpolant with positions `(0, 1)` and samples `(10, 20)` returns its default settings object. Assigning another settings object makes the method return that object. Clearing the assignment returns the default object again.

`BezierInterpolant` has landed. `new` stores positions `(0, 1)`, samples `(10, 20)`, and a sample size of `1`. The cached index is `0`, the result buffer is `(0)`, and both tangent arrays are absent. A supplied result buffer `(4, 5)` is stored as given.

`cubicBezier` has landed. Parameter `0` on controls `(10, 20, 30, 40)` is `10`. Parameter `1` is `40`. Parameter `0.5` is `25`.

`cubicBezierSlope` has landed. Controls `(0, 0, 0, 1)` have slope `0` at parameter `0`, `0.75` at `0.5`, and `3` at `1`. Controls `(10, 20, 30, 40)` have slope `30` at `0.5`.

`solveBezierParameter` has landed. On controls `(0, 10, 20, 30)`, the parameter for `0` is `0`, for `30` is `1`, and for `15` is `0.5`. On controls `(0, 0, 0, 1)`, the parameter for `0.5` is about `0.793700526`.

`BezierInterpolant.interpolate_` has landed. Without both tangents, time `0.25` between `0` and `1` blends samples `10` and `40` to `17.5`. With out-tangent `(10, 20)` and in-tangent `(20, 30)`, time `15` between `0` and `30` is `25`. The samples stay `10` and `40`.

`CubicInterpolant` has landed. `new` stores positions `(0, 1, 2)` and samples `(10, 20, 30)`. The weights start at `-0`, the offsets start at `0`, and both endings are zero curvature. Those endings are `2400`. Zero slope is `2401` and wrap-around is `2402`.

`CubicInterpolant.intervalChanged_` has landed. For sample size `2` and positions `(0, 1, 2, 3)`, the interval from `1` to `2` stores weights `0.5` and `0.5`, with offsets `0` and `6`. A zero-curvature start gives previous weight `-0.5`. Zero slope and wrap-around both give `0.5`, with offsets `2` and `4`. A zero-curvature end gives next weight `-0.5`. Zero slope and wrap-around give `0.5`, with offsets `6` and `2`.

`CubicInterpolant.interpolate_` has landed. After that same interval is recorded for samples `(10, 20, 30, 40)`, time `1` is `20`, time `1.5` is `25`, and time `2` is `30`. The samples stay unchanged.

`DiscreteInterpolant` has landed. `new` stores positions `(0, 1)` and samples `(10, 20)` with a sample size of `1`. The cached index is `0` and the result buffer is `(0)`. A supplied result buffer `(4, 5)` is stored as given.

`DiscreteInterpolant.interpolate_` has landed. With sample size `2`, interval index `2` at time `1.5` copies `(20, 21)` and leaves a longer buffer's third value `3` in place. Interval index `1` copies `(10, 11)`. The samples stay unchanged.

`LinearInterpolant` has landed. `new` stores positions `(0, 1)` and samples `(10, 20)` with a sample size of `1`. The cached index is `0` and the result buffer is `(0)`. A supplied result buffer `(4, 5)` is stored as given.

`LinearInterpolant.interpolate_` has landed. With sample size `2`, time `0` copies `(10, 11)`, time `0.25` blends to `(12.5, 13.5)`, and time `1` copies `(20, 21)`. A longer buffer's third value stays `3`. The samples stay unchanged.

`QuaternionLinearInterpolant` has landed. `new` stores positions `(0, 1)` and two quaternions `(0, 0, 0, 1)` and `(0, 0, 1, 0)`. The sample size is `4`, the cached index is `0`, and the result buffer is four zeros. A supplied result buffer `(4, 5, 6, 8)` is stored as given.

`QuaternionLinearInterpolant.interpolate_` has landed. From `(0, 0, 0, 1)` to `(0, 0, 1, 0)`, time `0` is the first quaternion, time `1` is the second, and time `0.5` is about `(0, 0, 0.707106781, 0.707106781)`. A longer buffer's fifth value stays `4`.

`Color.setColorName` has landed. It reads the 148 X11 names, ignoring case. `red` is `(1, 0, 0)` and hex `0xFF0000`. `AliceBlue` is hex `0xF0F8FF`. An unknown name leaves `(0.25, 0.5, 0.75)` unchanged. `setStyle` stays later.

`Color.setStyle` has landed. `rgb(255, 0, 0)`, `rgb(100%, 0%, 0%)`, `#ff0000`, `#f00`, and `red` are `(1, 0, 0)`. `hsl(0, 0%, 50%)` is linear `srgb_to_linear(0.5)` on each channel. `AliceBlue` is hex `0xF0F8FF`. An empty string, `#ff`, and an unknown name leave `(0.25, 0.5, 0.75)` unchanged. Alpha is ignored.

`Color.fromBufferAttribute` has landed as `BufferAttribute.copy_to_color`, because `math` does not import `core`. It writes `getX`, `getY`, and `getZ` into the color and leaves those numbers as stored. Index 1 of `[1, 2, 3, 4, 5, 6]` with item size 3 is `(4, 5, 6)`. Item size 4 skips the fourth component, so index 1 of `[1, 2, 3, 9, 4, 5, 6, 8]` is also `(4, 5, 6)`. The attribute is not modified.

`Quaternion.fromBufferAttribute` has landed as `BufferAttribute.copy_to_quaternion`, because `math` does not import `core`. It writes x, y, z, and w and notifies once. Index 1 of `[1, 2, 3, 4, 5, 6, 7, 8]` with item size 4 is `(5, 6, 7, 8)`. Item size 3 still reads a fourth value, so index 0 of `[1, 2, 3, 4, 5, 6]` is `(1, 2, 3, 4)`. The attribute is not modified.

`Vector3.project` has landed as `Object3D.project_point`, because `math` does not import cameras. It multiplies by the view inverse, then by the projection. On the wide orthographic camera, world `(2, 1, -0.1)` becomes NDC `(1, 1, 0)`. The same NDC comes from `(12, 1, -0.1)` when the camera sits at x `10`. A node without a camera aborts.

`Vector3.unproject` has landed as `Object3D.unproject_point`. It multiplies by the inverse projection, then by the world matrix. On that same camera, NDC `(1, 1, 0)` returns world `(2, 1, -0.1)`. With the camera at x `10`, the same NDC returns `(12, 1, -0.1)`. A node without a camera aborts.

`BufferGeometry.deleteAttribute` has landed. Deleting `normal` leaves `position` y at `2` and index `1` at `1`. A missing name leaves `position` x at `1`. The index is not cleared.

`BufferGeometry.hasAttribute` has landed. An empty geometry does not have `position`. After that attribute is set, `position` is present and `normal` is not. An index does not count as an attribute named `index`. Deleting `position` makes the check false again.

`BufferGeometry.clearGroups` has landed. Two groups, the first with material index `1` and the second starting at `3` with count `6`, become an empty list. `position` stays in place.

`BufferGeometry.setDrawRange` has landed. A new geometry starts at `0` and counts to positive infinity. Setting the range to `1` and `4` stores those two numbers. The renderer still draws the full geometry.

`BufferAttribute.applyMatrix4` has landed. A translation of `(10, 0, 0)` moves `(1, 2, 3)` to `(11, 2, 3)` and `(4, 5, 6)` to `(14, 5, 6)`. It walks an attribute whose item size is `3`.

`BufferAttribute.applyMatrix3` has landed. A 2D translation of `(0.25, 0.5)` moves `(1, 2)` to `(1.25, 2.5)`. A scale of `(2, 3, 4)` moves `(1, 1, 1)` to `(2, 3, 4)`. An item size of `4` stays `(9, 8, 7, 6)`.

`BufferAttribute.applyNormalMatrix` has landed. A quarter turn in the xy plane takes `(2, 0, 0)` to `(0, 1, 0)` and `(0, 3, 0)` to `(-1, 0, 0)`, after normalizing.

`BufferAttribute.transformDirection` has landed. A translation of `(10, 0, 0)` leaves `(0, 0, 1)` unchanged. A scale of `(2, 1, 1)` turns `(1, 1, 0)` into about `(0.894427191, 0.447213595, 0)`.

`BufferGeometry.applyMatrix4` has landed. A scale of `(2, 1, 1)` moves position `(1, 2, 3)` to `(2, 2, 3)`. The normal `(1, 1, 0)` becomes about `(0.447213595, 0.894427191, 0)`. The tangent `(1, 1, 0)` becomes about `(0.894427191, 0.447213595, 0)`. `uv` stays `(0.25, 0.5)`. An existing bounding box and sphere are recomputed, so the single point's box and sphere center are `(2, 2, 3)` and the radius is `0`.

`BufferGeometry.applyQuaternion` has landed. A right-angle yaw around Y takes position `(1, 0, 0)` to about `(0, 0, -1)`. The quaternion is not modified.

`BufferGeometry.rotateX` has landed. A right-angle turn around X takes position `(0, 1, 0)` to about `(0, 0, 1)`.

`BufferGeometry.rotateY` has landed. A right-angle turn around Y takes position `(1, 0, 0)` to about `(0, 0, -1)`.

`BufferGeometry.rotateZ` has landed. A right-angle turn around Z takes position `(1, 0, 0)` to about `(0, 1, 0)`.

`BufferGeometry.translate` has landed. An offset of `(10, 0, 0)` moves position `(1, 2, 3)` to `(11, 2, 3)`.

`BufferGeometry.scale` has landed. A scale of `(2, 1, 1)` moves position `(1, 2, 3)` to `(2, 2, 3)`.

`BufferGeometry.lookAt` has landed. Aiming at `(1, 0, 0)` turns local `+Z` `(0, 0, 1)` to about `(1, 0, 0)`.

`BufferGeometry.center` has landed. Points `(0, 0, 0)` and `(2, 4, 6)` move to `(-1, -2, -3)` and `(1, 2, 3)`.

`BufferGeometry.setFromPoints` has landed for `Vector3`. Points `(1, 2, 3)` and `(4, 5, 6)` become a new `position` attribute. An existing one-vertex buffer keeps only the first point.

`BufferAttribute.setXYZW` has landed. Index `1` of a four-wide attribute becomes `(2, 3, 4, 5)`. The first vertex stays `(0, 0, 0, 0)`.

`BufferGeometry.computeTangents` has landed. An indexed triangle on the XY plane, with UVs `(0, 0)`, `(1, 0)`, `(0, 1)` and normals `(0, 0, 1)`, gets tangent `(1, 0, 0, 1)` at each vertex. A geometry that only has `position` is left unchanged.

`BufferGeometry.normalizeNormals` has landed. Normals `(2, 0, 0)` and `(0, 3, 0)` become `(1, 0, 0)` and `(0, 1, 0)`.

`BufferGeometry.computeVertexNormals` has landed. An indexed triangle `(0, 0, 0)`, `(1, 0, 0)`, `(0, 1, 0)` gets normal `(0, 0, 1)` at each vertex. The same triangle without an index does too.

`BufferGeometry.toNonIndexed` has landed. Index `[0, 2, 1]` expands positions `(0, 0, 0)`, `(1, 0, 0)`, `(0, 1, 0)` into `(0, 0, 0)`, `(0, 1, 0)`, `(1, 0, 0)`. The group is copied. A geometry that already has no index is returned as itself.

`BufferAttribute.toJSON` has landed. An attribute of item size `3`, values `[1, 2, 3]`, and `normalized` true serializes to those three fields. Changing the copied array leaves the attribute at `1`.

`BufferGeometry.toJSON` has landed. Metadata is version `4.7`, type `BufferGeometry`, generator `BufferGeometry.toJSON`. Position `[1, 2, 3]`, index `[0]`, group `(0, 3, material 1)`, and bounding sphere center `(1, 2, 3)` with radius `4` are recorded. Changing the copied position leaves the geometry at `1`.

`BufferAttribute.copy` has landed. Copying item size `3`, values `[1, 2, 3]`, and `normalized` true replaces a one-element destination. Changing the destination leaves the source at `1`.

`BufferAttribute.clone` has landed. Cloning item size `3`, values `[1, 2, 3]`, and `normalized` true makes a new attribute. Changing the clone leaves the source at `1`.

`BufferGeometry.copy` has landed. It copies position `[1, 2, 3]`, index `[0]`, a group with material `1`, a bounding sphere of radius `4`, and draw range `(2, 4)`. A previous `uv` attribute is cleared. Changing the copied position leaves the source at `1`.

`BufferAttribute.copyAt` has landed. Copying vertex `0` of `[1, 2, 3, 4, 5, 6]` onto vertex `1` of `[0, 0, 0, 9, 9, 9]` produces `[0, 0, 0, 1, 2, 3]`. The source stays `[1, 2, 3, 4, 5, 6]`.

`BufferAttribute.copyArray` has landed. Writing `[1, 2, 3]` into `[0, 0, 0, 9]` produces `[1, 2, 3, 9]`. Changing the source array leaves the attribute at `1`.

`BufferAttribute.set` has landed. Writing `[1, 2]` at offset `1` into `[0, 0, 0, 9]` produces `[0, 1, 2, 9]`. Changing the source array leaves the attribute at `1`.

`BufferAttribute.setComponent` has landed. Writing `9` into component `1` of `[1, 2, 3]` produces `[1, 9, 3]`.

`BufferAttribute.setX` has landed. Writing `9` into the x channel of `[1, 2, 3]` produces `[9, 2, 3]`.

`BufferAttribute.setY` has landed. Writing `9` into the y channel of `[1, 2, 3]` produces `[1, 9, 3]`.

`BufferAttribute.setZ` has landed. Writing `9` into the z channel of `[1, 2, 3]` produces `[1, 2, 9]`.

`BufferAttribute.getW` has landed. The fourth channel of `[1, 2, 3, 4]` is `4`.

`BufferAttribute.setW` has landed. Writing `9` into the w channel of `[1, 2, 3, 4]` produces `[1, 2, 3, 9]`.

`BufferAttribute.setXY` has landed. Writing `(1, 2)` into `[0, 0, 0]` produces `[1, 2, 0]`.

`BufferAttribute.needsUpdate` has landed. A new attribute starts at version `0`. Setting the flag false leaves it at `0`. Setting it true twice makes the version `2`.

`BufferAttribute.setUsage` has landed. A new attribute uses `StaticDrawUsage` `35044`. Setting `DynamicDrawUsage` stores `35048`, and copying the attribute carries that usage.

`BufferAttribute.addUpdateRange` has landed. A new attribute has no ranges. Adding start `1` and count `2` stores that one span.

`BufferAttribute.clearUpdateRanges` has landed. After adding start `1` and count `2`, clearing leaves no spans.

`BufferAttribute.onUpload` has landed. The stored callback runs once and increments a counter from `0` to `1`.

`BufferAttribute.addEventListener` has landed. Registering the same `dispose` listener twice leaves a single entry.

`BufferAttribute.dispose` has landed. A `dispose` listener adds `1` and another event's listener adds `10`, so the counter ends at `1`.

`BufferAttribute.hasEventListener` has landed. Before registration the check is false. After `addEventListener`, the same `dispose` listener checks true.

`BufferAttribute.removeEventListener` has landed. After removing the registered `dispose` listener, `hasEventListener` is false.

`BufferAttribute.dispatchEvent` has landed. Dispatching `change` adds `1`. A `dispose` listener that would add `10` stays quiet, so the counter ends at `1`.

`BufferGeometry.clone` has landed. It copies a tangent `[1, 0, 0, 1]`, index `[0]`, a group with material `1`, and draw range `(2, 4)`. Changing the clone's tangent leaves the source at `1`.

`BufferGeometry.addEventListener` has landed. Registering the same `dispose` listener twice leaves a single entry.

`BufferGeometry.hasEventListener` has landed. Before registration the check is false. After `addEventListener`, the same `dispose` listener checks true.

`BufferGeometry.removeEventListener` has landed. After removing the registered `dispose` listener, `hasEventListener` is false.

`BufferGeometry.dispatchEvent` has landed. Dispatching `change` adds `1`. A `dispose` listener that would add `10` stays quiet, so the counter ends at `1`.

`BufferGeometry.dispose` has landed. A `dispose` listener adds `1` and another event's listener adds `10`, so the counter ends at `1`.

`BufferAttribute.id` has landed. Two new attributes receive consecutive ids, and the second is greater by `1`. `copy` keeps the destination id.

`BufferAttribute.name` has landed. A new attribute is named `""`. Setting it to `tangent` and copying carries `tangent`.

`BufferAttribute.gpuType` has landed. A new attribute uses `FloatType` (`1015`). Setting it to `IntType` (`1013`) and copying carries `1013`.

`BufferGeometry.id` has landed. Two new geometries receive consecutive ids, and the second is greater by `1`. `copy` keeps the destination id.

`BufferGeometry.uuid` has landed. A new geometry's uuid is 36 characters and its version nibble is `4`. `copy` keeps the destination uuid.

`BufferGeometry.name` has landed. A new geometry is named `""`. Setting it to `square` and copying carries `square`.

`BufferGeometry.type` has landed. A new geometry's type is `BufferGeometry`. `copy` leaves a destination typed `SphereGeometry` unchanged when the source is `BoxGeometry`.

`BufferGeometry.setIndirect` has landed. A new geometry has no indirect attribute and offset `0`. Setting `[1, 2, 3, 4, 5]` with offset `16` stores that first component and the offset.

`BufferGeometry.getIndirect` has landed. Before `setIndirect` it is empty. After storing `[1, 2, 3, 4, 5]`, it returns that attribute and the first component is `1`.

`BufferGeometry.morphAttributes` has landed. A new geometry has no morph attributes. Copying a `position` target `[1, 2, 3]` drops a previous `normal` target. Changing the copy leaves the source at `1`.

`BufferGeometry.morphTargetsRelative` has landed. A new geometry is `false`. Setting it to `true` and copying carries `true`.

`BufferGeometry.userData` has landed. A new geometry has no `label`. Setting `label` to `square` and copying shares that map, so changing the copy to `cube` leaves the source at `cube`.

`BufferGeometry._transformed` has landed. A new geometry is `false`. `applyMatrix4` sets it to `true`, and copying carries `true`.

`BufferGeometry.getIndex` has landed. A new geometry has no index. After `setIndex` of `[0]`, the returned index starts at `0`.

`BufferAttribute.toJSON` now writes `name`, `usage`, and `gpuType`. A `tangent` attribute with `DynamicDrawUsage` (`35048`) and `IntType` (`1013`) keeps those three values.

`BufferGeometry.toJSON` now writes `uuid`, `name`, and `type`. A geometry named `square` with type `BoxGeometry` keeps that uuid, that name, and `BoxGeometry`, while the metadata type stays `BufferGeometry`. An empty `userData` is omitted. A `label` of `square` is included.

`BufferGeometry.applyMatrix4` now marks `position`, `normal`, and `tangent` as needing an update. Their `version` goes from `0` to `1`. A `uv` attribute stays at `0`.

`BufferGeometry.computeBoundingBox` now includes morph positions. A point at `(0, 0, 0)` with an absolute morph target at `(2, 0, 0)` has max x `2`. A point at `(1, 0, 0)` with a relative morph `(2, 0, 0)` has max x `5`.

`BufferGeometry.computeBoundingSphere` now includes morph positions. A point at `(1, 1, 0)` with absolute morphs `(0, 0, 0)` and `(2, 2, 0)` has radius `sqrt(2)`.

`BufferGeometry.toNonIndexed` now expands morph attributes. Index `[0, 2, 1]` turns morph values `[4, 5, 6]` into `[4, 6, 5]`. `morphTargetsRelative` set to `true` is kept. The source stays at `5`.

`BufferGeometry.toJSON` now writes morph attributes. A `position` target `[1, 2, 3]` with `morphTargetsRelative` set to `true` is included. A geometry without morph attributes omits them.

`BufferGeometry.setIndirect` now accepts several byte offsets. Offsets `[8, 24]` are stored with an attribute whose first component is `1`. Changing the source array leaves the first offset at `8`.

`Timer.update` has landed. The time origin is `0`. Updating at `1000` makes `getDelta` `1`. Updating at `2500` makes `getDelta` `1.5`.

`Timer.getElapsed` has landed. Updating at `1000` makes the elapsed time `1`. Updating at `2500` makes it `2.5`.

`Timer.getTimescale` has landed. A new timer's timescale is `1`.

`Timer.setTimescale` has landed. Setting the timescale to `2` and updating at `1000` makes `getDelta` `2`.

`Timer.reset` has landed. After an update at `1000`, resetting at `4000` and updating at `5000` makes `getDelta` `1`.

`InstancedBufferAttribute.meshPerAttribute` has landed on `BufferAttribute`. It defaults to `1`. Constructing with `2` and copying carries `2`.

`InstancedBufferAttribute.toJSON` has landed on `BufferAttribute.toJSON`. A repeat count of `1` omits both instance fields. A repeat count of `2` writes `meshPerAttribute` `2` and `isInstancedBufferAttribute` true.

`InstancedBufferGeometry.instanceCount` has landed on `BufferGeometry`. It defaults to positive infinity. Setting it to `4` and copying carries `4`.

`InstancedBufferGeometry.toJSON` has landed on `BufferGeometry.toJSON`. Positive infinity omits both instance fields. A count of `4` writes `instanceCount` `4` and `isInstancedBufferGeometry` true.

`InterleavedBuffer` has landed. An array `[1, 2, 3, 4, 5, 6]` with stride `3` has count `2`.

`InterleavedBuffer.setUsage` has landed. A new buffer is `StaticDrawUsage` (`35044`). `setUsage` of `DynamicDrawUsage` stores `35048`.

`InterleavedBuffer.addUpdateRange` has landed. A new buffer has no ranges. Adding start `1` and count `2` stores that one span.

`InterleavedBuffer.clearUpdateRanges` has landed. After adding start `1` and count `2`, clearing leaves no ranges.

`InterleavedBuffer.copy` has landed. Copying stride `3` and values `[1, 2, 3, 4, 5, 6]` onto `[9]` replaces the array, the stride, the count, and `DynamicDrawUsage` (`35048`). The destination keeps its own update range. Changing the copy leaves the source at `1`.

`InterleavedBuffer.copyAt` has landed. Vertex `0` of `[1, 2, 3, 4, 5, 6]` copied onto vertex `1` of `[0, 0, 0, 9, 9, 9]` becomes `[0, 0, 0, 1, 2, 3]`. The source stays at `1`.

`InterleavedBuffer.set` has landed. Writing `[1, 2]` at offset `1` into `[0, 0, 0, 9]` becomes `[0, 1, 2, 9]`.

`InterleavedBuffer.clone` has landed. Cloning stride `3`, values `[1, 2, 3, 4, 5, 6]`, and `DynamicDrawUsage` (`35048`) makes a new buffer. The clone has no update range. Changing the clone leaves the source at `1`.

`InterleavedBuffer.onUpload` has landed. Running the stored callback takes a counter from `0` to `1`.

`InterleavedBuffer.needsUpdate` has landed. A new buffer's version is `0`. Setting it false leaves `0`. Setting it true twice makes the version `2`.

`InterleavedBuffer.uuid` has landed. A new buffer's id has length `36` and version nibble `4`. `copy` keeps the destination id.

`InterleavedBuffer.toJSON` has landed. Stride `3`, values `[1, 2, 3, 4, 5, 6]`, and `DynamicDrawUsage` (`35048`) are written with the buffer's uuid. Changing the copied array leaves the buffer at `1`.

`InterleavedBufferAttribute` has landed. Item size `2` and offset `1` on a stride-`3` buffer of `[1, 2, 3, 4, 5, 6]` has count `2`. The name is empty and `normalized` is false.

`InterleavedBufferAttribute.array` has landed. Index `1` reads `2`. Writing `8` there changes the shared buffer to `8`.

`InterleavedBufferAttribute.needsUpdate` has landed. The attribute buffer's version starts at `0`. Setting it false leaves `0`. Setting it true twice makes the version `2`.

`InterleavedBufferAttribute.getX` has landed. On `[1, 2, 3, 4, 5, 6]` with stride `3`, index `1` at offset `0` is `4`, and index `0` at offset `1` is `2`.

`InterleavedBufferAttribute.setX` has landed. On `[0, 0, 0, 9, 9, 9]` with stride `3`, `setX(1, 4)` at offset `0` writes `4` at index `3`. The following value stays `9`.

`InterleavedBufferAttribute.setY` has landed. On the same buffer, `setY(1, 4)` at offset `0` writes `4` at index `4`. The values on either side stay `9`.

`InterleavedBufferAttribute.setZ` has landed. On `[0, 0, 0, 9, 9, 9]` with stride `3`, `setZ(1, 4)` at offset `0` writes `4` at index `5`. The preceding value stays `9`.

`InterleavedBufferAttribute.setW` has landed. On `[0, 0, 0, 0, 9, 9, 9, 9]` with stride `4`, `setW(1, 4)` at offset `0` writes `4` at index `7`. The preceding value stays `9`.

`InterleavedBufferAttribute.getY` has landed. On `[1, 2, 3, 4, 5, 6]` with stride `3`, index `1` at offset `0` is `5`, and index `0` at offset `1` is `3`.

`InterleavedBufferAttribute.getZ` has landed. On the same buffer, index `1` at offset `0` is `6`, and index `0` at offset `1` is `4`.

`InterleavedBufferAttribute.getW` has landed. On `[1, 2, 3, 4, 5, 6, 7, 8]` with stride `4`, index `1` at offset `0` is `8`, and index `0` at offset `1` is `5`.

`InterleavedBufferAttribute.setXY` has landed. On `[0, 0, 0, 9, 9, 9]` with stride `3`, `setXY(1, 1, 2)` at offset `0` writes `[0, 0, 0, 1, 2, 9]`.

`InterleavedBufferAttribute.setXYZ` has landed. On the same buffer, `setXYZ(1, 1, 2, 3)` at offset `0` writes `[0, 0, 0, 1, 2, 3]`.

`InterleavedBufferAttribute.setXYZW` has landed. On `[0, 0, 0, 0, 9, 9, 9, 9]` with stride `4`, `setXYZW(1, 1, 2, 3, 4)` at offset `0` writes `[0, 0, 0, 0, 1, 2, 3, 4]`.

`InterleavedBufferAttribute.applyMatrix4` has landed. Translating `[1, 2, 3, 4, 5, 6]` by `(10, 0, 0)` makes the vertices `(11, 2, 3)` and `(14, 5, 6)`.

`InterleavedBufferAttribute.applyNormalMatrix` has landed. A quarter turn sends `(2, 0, 0)` to `(0, 1, 0)` and `(0, 3, 0)` to `(-1, 0, 0)`.

`InterleavedBufferAttribute.transformDirection` has landed. Translating `(0, 0, 1)` by `(10, 0, 0)` leaves it at `(0, 0, 1)`.

`InterleavedBufferAttribute.getComponent` has landed. On `[1, 2, 3, 4, 5, 6]` with stride `3`, index `1` component `2` at offset `0` is `6`, and index `0` component `0` at offset `1` is `2`.

`InterleavedBufferAttribute.setComponent` has landed. On `[0, 0, 0, 9, 9, 9]` with stride `3`, `setComponent(1, 2, 4)` at offset `0` writes `4` at index `5`. The preceding value stays `9`.

`InterleavedBufferAttribute.clone` has landed. Item size `2` and offset `1` on `[1, 2, 3, 4, 5, 6]` with stride `3` becomes a `BufferAttribute` of `[2, 3, 5, 6]`. `normalized` true is kept. Changing the clone leaves the source at `2`.

`InterleavedBufferAttribute.toJSON` has landed. The same attribute serializes as item size `2`, `normalized` true, and array `[2, 3, 5, 6]`. Changing the copied array leaves the source at `2`.

`InstancedInterleavedBuffer.meshPerAttribute` has landed on `InterleavedBuffer`. It defaults to `1`. Constructing with `2` and copying carries `2`.

`InstancedInterleavedBuffer.toJSON` has landed on `InterleavedBuffer.toJSON`. A repeat count of `1` omits both instance fields. A repeat count of `2` writes `meshPerAttribute` `2` and `isInstancedInterleavedBuffer` true.

`Raycaster` has landed. A new raycaster starts at `(0, 0, 0)` and points along `(0, 0, -1)`, with `near` `0` and `far` positive infinity. Origin `(1, 2, 3)`, direction `(0, 1, 0)`, `near` `0.5`, and `far` `10` are stored. Changing the caller's origin leaves the ray at `1`.

`Raycaster.set` has landed. Setting origin `(1, 2, 3)` and direction `(0, 1, 0)` replaces the ray. Changing the caller's origin leaves the ray at `1`.

`Raycaster.setFromCamera` has landed. An orthographic camera with bounds `left=-2`, `right=2`, `top=1`, `bottom=-1`, `near=0.1`, and `far=10` aims NDC `(1, 1)` at origin `(2, 1, 0)` and direction `(0, 0, -1)`. Moving the camera to `x=10` aims the same NDC at `(12, 1, 0)` with the same direction. The raycaster stores that camera.

`Raycaster.layers` has landed. A new raycaster belongs to layer `0`, so the mask is `1`. `layers.set(1)` stores mask `2`.

`Raycaster.params` has landed. A new raycaster starts `Line.threshold` and `Points.threshold` at `1`. Setting them to `0.5` and `2` stores those values. `Mesh`, `LOD`, and `Sprite` stay empty.

`Object3D.raycast` has landed as the empty base method. It leaves the hit list empty and returns `None`, so a later traversal still visits children. `Some(false)` is the only result that stops them.

`Raycaster.intersectObject` has landed. It visits the object and its children when layers overlap, then sorts the hit list by distance. A list seeded with distances `2` and `1` comes back as `1` then `2`. The nearer point stays at `x=4`. The returned array is the one passed in. The empty base `raycast` adds nothing.

`Raycaster.intersectObjects` has landed. It visits each root, then sorts once. A list seeded with distances `3` and `1` across two roots comes back as `1` then `3`. The nearer point stays at `x=5`. The returned array is the one passed in.

`Mesh.getVertexPosition` has landed on `Object3D`. Index `1` of `[1, 2, 3, 4, 5, 6]` is `(4, 5, 6)`. A relative morph of `(2, 0, 0)` at weight `0.5` moves `(1, 2, 3)` to `(2, 2, 3)`.

`Mesh.raycast` has landed for a single material. A ray from `(0.25, 0.25, 1)` along `(0, 0, -1)` hits the triangle `(0, 0, 0)`, `(1, 0, 0)`, `(0, 1, 0)` at `(0.25, 0.25, 0)`, distance `1`. Material groups, `uv`, normals, and `face` stay out of this pass.

`Mesh.raycast` now records `face`, `faceIndex`, and `barycoord`. The same hit uses vertices `0`, `1`, `2`, face index `0`, material index `0`, normal `(0, 0, 1)`, and barycentric coordinates `(0.5, 0.25, 0.25)`.

`Triangle.getInterpolatedAttribute` has landed for a `Vector2` target on `BufferAttribute`. UVs `(0, 0)`, `(1, 0)`, and `(0, 1)` with barycentric coordinates `(0.5, 0.25, 0.25)` blend to `(0.25, 0.25)`.

`Mesh.raycast` now writes `uv` when the geometry has that attribute. The same triangle and ray store `(0.25, 0.25)`. A geometry without `uv` leaves the field empty.

`Mesh.raycast` now writes `uv1` the same way. UVs `(0, 1)`, `(1, 1)`, and `(0, 0)` on that ray store `(0.25, 0.75)`. A geometry without `uv1` leaves the field empty.

`Mesh.raycast` now writes an interpolated `normal`. Vertex normals `(0, 0, -1)` face the local ray, so the hit stores `(0, 0, 1)`. A geometry without `normal` leaves the field empty. The triangle `face.normal` stays the geometric normal.

`Line.raycast` has landed. A ray from `(0.5, 0.5, 0)` along `(0, -1, 0)` hits the segment from `(0, 0, 0)` to `(1, 0, 0)` at `(0.5, 0, 0)`, distance `0.5`, index `0`. The default line threshold is `1`. `LineSegments` uses the same test with a step of `2`.

`Points.raycast` has landed. A point at `(0.5, 0, 0)` and a ray from `(0, 0.5, 0)` along `(0, -1, 0)` meet the ray at `(0, 0, 0)`. The hit distance is `0.5` and `distanceToRay` is `0.5`. The default points threshold is `1`.

`Sprite.raycast` has landed. A perspective camera at the origin and a sprite at `(0, 0, -1)`, center `(0.5, 0.5)`, rotation `0`, and `sizeAttenuation` true, are hit by a ray from `(0.25, -0.25, 0)` along `(0, 0, -1)` at `(0.25, -0.25, -1)`. The distance is `1` and the uv is `(0.75, 0.25)`. A raycaster without a camera aborts. Sprite geometry, `count`, and the frustum test stay later.

`LOD.addLevel` has landed. Adding distances `10`, `0`, and `-5` stores levels at `0`, `5`, and `10`. The middle level keeps hysteresis `0.25`. The three objects stay children in the order they were added, and `autoUpdate` stays true. `removeLevel`, `getObjectForDistance`, `raycast`, and `update` stay later.

`LOD.removeLevel` has landed. From levels at `0`, `5`, and `10`, removing distance `5` leaves `0` and `10`, and that object leaves the children. Removing distance `7` returns false and leaves both lists unchanged. `getObjectForDistance`, `raycast`, and `update` stay later.

`LOD.getObjectForDistance` has landed. An empty LOD returns nothing. Levels at `0` and `10` with hysteresis `0.5` on the farther object use threshold `5` while that object is visible, so distance `4` returns the near object and distance `5` returns the far object. Hiding the far object keeps its threshold at `10`, so distance `8` returns the near object. `raycast` and `update` stay later.

`LOD.raycast` has landed. With `recursive` false, an empty LOD records nothing. A ray from `(0.25, 0.25, 1)` along `(0, 0, -1)` is farther than `0.5` from the LOD origin, so the second level is tested. That triangle hits `(0.25, 0.25, 0)` at distance `1`. `update` stays later.

`LOD.update` has landed. A camera at `(0, 0, 10)` with zoom `1` is distance `10` from an LOD at the origin. Levels at `0`, `10`, and `20` show the middle object, hide the other two, and store current level `1`. Zoom `2` makes the distance `5`, so only the near object stays visible and the current level is `0`. One level is left unchanged.

`LineLoop` raycast has landed. With the line threshold at `0`, a ray from `(0.5, 0.5, 1)` along `(0, 0, -1)` misses the open segments of `(0, 0, 0)`, `(1, 0, 0)`, `(1, 1, 0)`. The closing segment hits `(0.5, 0.5, 0)` at distance `1`, index `2`.

`Sprite.intersectsFrustum` has landed. It builds the sphere from `Frustum.intersectsSprite`: center at the sprite origin, radius `0.7071067811865476` plus the distance from `center` to `(0.5, 0.5)`, then applies `matrixWorld`. A sprite at `(0.5, 0.5, 0.5)` with the default center meets the unit-cube frustum. A sprite at `(-2, 0.5, 0.5)` does not. The sprite center and the frustum planes stay unchanged.

`Object3D.intersectsFrustum` has landed for a mesh, point, or line geometry. A single point at `(0.5, 0.5, 0.5)` has sphere radius `0` and meets the unit-cube frustum. Moving the node by `(-2.5, 0, 0)` puts that sphere at `(-2, 0.5, 0.5)` and misses. A node without geometry misses. The stored sphere stays at the local point. Instanced bounds stay later.

`Object3D.intersectsFrustumArray` has landed. With `count` `0` the same point misses, including when a unit-cube frustum is already stored. `count` `1` accepts it. After the node moves by `(-2.5, 0, 0)` that one frustum misses, and a second frustum of constant `10` accepts it only once `count` is `2`.

`Sprite.intersectsFrustumArray` has landed. A sprite at `(0.5, 0.5, 0.5)` with the default center misses while `count` is `0`, including when a unit-cube frustum is stored, and meets it once `count` is `1`. Moving the sprite to `(-2, 0.5, 0.5)` makes that frustum miss. A second frustum of constant `10` accepts it only once `count` is `2`.

`ArrayCamera` has landed. It is a perspective camera with fov `50`, aspect `1`, near `0.1`, and far `2000`. A new array has no sub cameras. Passing one perspective camera of fov `40` stores that camera. `setFromArrayCamera` stays later.

`FrustumArray.setFromArrayCamera` has landed in `cameras`. Two perspective sub cameras, the second at `x=10`, store two frustums. Each frustum is `projectionMatrix * matrixWorldInverse` in that camera's coordinate system. The moved camera's first plane constant differs from the origin camera. Setting an empty array camera changes `count` to `0` and leaves the stored frustums in place.

`InstancedMesh.computeBoundingSphere` has landed. A point at the origin, drawn at the origin and at `x=2`, stores a sphere centered at `(1, 0, 0)` with radius `1`. The geometry sphere stays at the origin with radius `0`. `count` `1` keeps only the origin sphere. `count` `0`, and a geometry with no position, both leave an empty sphere of radius `-1`. Frustum tests still ignore this sphere.

`InstancedMesh.intersectsFrustum` has landed. A point at the origin, instanced at `x=-2`, misses the unit-cube frustum, and the call computes the sphere at `(-2, 0, 0)` with radius `0`. The geometry sphere stays at the origin. Moving that instance to `(0.5, 0.5, 0.5)` and recomputing meets the frustum. With the instance back at the origin, moving the node by `(-2.5, 0, 0)` misses, and the stored sphere stays at the origin. `Object3D.intersectsFrustum` still uses the geometry sphere.

`InstancedMesh.intersectsFrustumArray` has landed. A point at the origin, instanced at `(0.5, 0.5, 0.5)`, misses while `count` is `0`, including when a unit-cube frustum is stored, and the sphere stays uncomputed. `count` `1` meets that frustum and stores the sphere at `(0.5, 0.5, 0.5)` with radius `0`. Moving the instance to `(-2, 0.5, 0.5)` and recomputing makes that frustum miss. A second frustum of constant `10` accepts it only once `count` is `2`. The geometry sphere stays at the origin.

`Object3D.intersectsFrustum` now uses the instanced bounding sphere when the mesh has instance data. A plain mesh of a point at the origin meets the unit-cube frustum. The same point instanced at `x=-2` misses, and the call stores the sphere at `(-2, 0, 0)` with radius `0` on the instance data. `computeBoundingSphere` returns that same sphere. The geometry sphere stays at the origin. Moving the instance to `(0.5, 0.5, 0.5)` and recomputing meets the frustum. With the instance back at the origin, moving the node by `(-2.5, 0, 0)` misses, and the stored sphere stays at the origin.

Opaque list culling uses that same instance sphere when `frustum_culled` is true. A point at the origin instanced at `x=-2` drops out of the unit-cube frustum, and the sphere is stored at `(-2, 0, 0)` with radius `0`. The same point instanced at `(0.5, 0.5, 0.5)` stays. The geometry sphere stays at the origin. Setting `frustum_culled` back to false keeps both. New instanced meshes still start with culling off.

`InstancedMesh.raycast` has landed. A triangle `(0, 0, 0)`, `(1, 0, 0)`, `(0, 1, 0)` is drawn at the origin and at `x=2`. A ray from `(0.25, 0.25, 1)` along `(0, 0, -1)` hits `(0.25, 0.25, 0)` at distance `1`, instance `0`. A ray from `(2.25, 0.25, 1)` hits `(2.25, 0.25, 0)`, instance `1`. `matrixWorld` stays the identity. The geometry sphere stays centered at `(0.5, 0.5, 0)`. Moving both instances to `x=10` and `x=12` and recomputing misses. `count` `0` also misses.

`InstancedMesh.copy` has landed. A point at the origin, with `count` `1`, instance translation `x=2`, and color `(0.25, 0.5, 1)`, copies onto another mesh. The node position `y=3`, frustum culling, and a child named `marker` come along. Geometry and material are the source objects. Before bounds exist, the destination sphere is cleared. After computing, the box is the point `(2, 0, 0)` and the sphere has radius `0`. Editing the copy's box, sphere, matrix, or color leaves the source unchanged. Morph textures stay later.

`InstancedMesh.clone` has landed. The same point, stored in a mesh of capacity `2` with `count` `1`, produces a new mesh. Capacity stays `2`, count stays `1`, the matrix translation stays `x=2`, and the color stays `(0.25, 0.5, 1)`. The node position is `y=3`, and the child named `marker` is a new node. Geometry is shared. The cloned sphere is centered at `(2, 0, 0)` with radius `0`, and setting that radius to `5` leaves the source radius at `0`. `recursive` false keeps the instance data and drops the child.

`LOD.copy` has landed. Levels at distance `0` and `10`, the farther one with hysteresis `0.25`, copy onto a LOD whose current level is `3`. The copy keeps current level `3`, sets `autoUpdate` false, and moves the node to `y=4`. The near clone is named `near` at `y=1`, and the far clone is named `far`. Both clones are new objects. Renaming the near clone leaves the source name `near`.

`LOD.clone` has landed. The same two levels, with `autoUpdate` false, current level `1`, and the node at `y=4`, produce a new LOD. Its current level is `0`. The near object is a new node named `near` at `y=1`, and the far object is a new node named `far` at distance `10` with hysteresis `0.25`. Renaming the far clone leaves the source name `far`. The source current level stays `1`.

`LOD.getCurrentLevel` has landed. A new LOD returns `0`. Levels at `0`, `10`, and `20` with a camera at `(0, 0, 10)` and zoom `1` return `1`. Zoom `2` makes the distance `5` and the level `0`.

`Sprite.geometry` has landed. Every sprite shares one quad. Positions are `(-0.5, -0.5, 0)`, `(0.5, -0.5, 0)`, `(0.5, 0.5, 0)`, and `(-0.5, 0.5, 0)`. Uvs are `(0, 0)`, `(1, 0)`, `(1, 1)`, and `(0, 1)`. The index is `0, 1, 2, 0, 2, 3`. `count` stays later.

`Sprite.count` has landed. A new sprite has count `1`. Setting it to `4` leaves another new sprite at `1`.

`Mesh.copy` has landed. A mesh whose position is a single point at `(0.5, 0, 0)`, with node position `y=3` and render order `4`, copies onto another mesh. Geometry and material are the source objects, and the node binding reads that same geometry. A child named `marker` is cloned. `recursive` false keeps the transform and geometry and drops the child. Morph weights stay later.

`Mesh.clone` has landed. The same point, node position `y=3`, and render order `4` produce a new mesh. Geometry and material are shared, and the node binding reads that geometry. The child named `marker` is a new node. `recursive` false drops the child and leaves the source child in place.

`Mesh.count` has landed. A new mesh has count `1`. Setting it to `4` leaves another new mesh at `1`.

`Mesh.updateMorphTargets` has landed. A new mesh with no morph attributes keeps influences and the dictionary empty. A position group with targets named `wide` and `tall` stores influences `[0, 0]` and maps those names to `0` and `1`. Replacing that group with an unnamed target maps `"0"` to `0` and resets the first weight to `0`. Setting the first weight to `0.5` leaves another new mesh at `0`. Assigning the geometry after construction leaves the dictionary empty until the call. Clearing the morph attributes and calling again keeps `"0"` at `0`. Copying weights stays later.

`Mesh.copy` now copies morph weights. A position group named `wide` and `tall`, with the first weight set to `0.5`, copies onto a mesh that had none. The copy stores `[0.5, 0]` and maps `wide` to `0` and `tall` to `1`. Setting the copy's first weight to `1` and `wide` to `9` leaves the source at `0.5` and `wide` at `0`. Copying a mesh with no morph data onto one whose first weight is `0.25` leaves that weight and `wide` at `0`. `Mesh.clone` uses the same copy, so the clone starts at `0.5`, and setting its first weight to `0` leaves the source at `0.5`.

`Points.copy` has landed. A point cloud whose position is a single point at `(0.5, 0, 0)`, with material size `2`, node position `y=3`, and render order `4`, copies onto another cloud whose material size was `8`. Geometry and material are the source objects, and the node binding reads that same geometry at size `2`. A child named `marker` is cloned. `recursive` false keeps the transform and geometry and drops the child.

`Points.clone` has landed. The same point, material size `2`, node position `y=3`, and render order `4` produce a new point cloud. Geometry and material are shared, and the node binding reads that geometry at size `2`. The child named `marker` is a new node. `recursive` false drops the child and leaves the source child in place.

`Line.copy` has landed. A line from `(0, 0, 0)` to `(1, 0, 0)`, with opacity `0.25`, node position `y=3`, and render order `4`, copies onto another line whose opacity was `1`. Geometry and material are the source objects, and the node binding reads that same geometry at opacity `0.25`. A child named `marker` is cloned. `recursive` false keeps the transform and geometry and drops the child.

`Line.clone` has landed. The same line, opacity `0.25`, node position `y=3`, and render order `4` produce a new line. Geometry and material are shared, and the node binding reads that geometry at opacity `0.25`. The child named `marker` is a new node. `recursive` false drops the child and leaves the source child in place.

`LineSegments.copy` has landed. `LineSegments` has no `copy` of its own; it follows `Line.copy`. A segment from `(0, 0, 0)` to `(1, 0, 0)`, with opacity `0.25`, node position `y=3`, and render order `4`, copies onto another segment whose opacity was `1`. Geometry and material are the source objects, and the node binding reads that same geometry at opacity `0.25`. A child named `marker` is cloned. `recursive` false keeps the transform and geometry and drops the child.

`LineSegments.clone` has landed. The same segment, opacity `0.25`, node position `y=3`, and render order `4` produce a new line segments object. Geometry and material are shared, and the node binding reads that geometry at opacity `0.25`. The child named `marker` is a new node. `recursive` false drops the child and leaves the source child in place.

`LineLoop.copy` has landed. `LineLoop` has no `copy` of its own; it follows `Line.copy`. A loop from `(0, 0, 0)` to `(1, 0, 0)`, with opacity `0.25`, node position `y=3`, and render order `4`, copies onto another loop whose opacity was `1`. Geometry and material are the source objects, and the node binding reads that same geometry at opacity `0.25`. A child named `marker` is cloned. `recursive` false keeps the transform and geometry and drops the child.

`LineLoop.clone` has landed. The same loop, opacity `0.25`, node position `y=3`, and render order `4` produce a new line loop. Geometry and material are shared, and the node binding reads that geometry at opacity `0.25`. The child named `marker` is a new node. `recursive` false drops the child and leaves the source child in place.

`Sprite.copy` has landed. A sprite with center `(0.25, 0.75)`, material rotation `0.5`, size attenuation off, count `4`, node position `y=3`, and render order `4` copies onto a sprite whose center was `(0.5, 0.5)` and whose count was `1`. The material is the source object. The center values are copied into the destination vector, and setting that vector's x to `0.1` leaves the source at `0.25`. The node sprite state reads rotation `0.5` and the same center. Count stays `1`. Geometry stays the shared quad. A child named `marker` is cloned. `recursive` false keeps the transform and center and drops the child.

`Sprite.clone` has landed. The same sprite produces a new sprite. The material is shared, and the center is `(0.25, 0.75)` on a new vector. Setting the clone's x to `0.1` leaves the source at `0.25`. The node sprite state reads rotation `0.5` and that center. Count stays `1` while the source stays at `4`. Geometry stays the shared quad. The child named `marker` is a new node. `recursive` false drops the child and leaves the source child in place.

`Line.computeLineDistances` has landed. Vertices at `(0, 0, 0)`, `(3, 0, 0)`, and `(0, 4, 0)` store `lineDistance` values `0`, `3`, and `8`. The call returns the same line. An indexed geometry is left unchanged, so `lineDistance` stays absent. `LineSegments` stays later.

`LineSegments.computeLineDistances` has landed. Pairs `(0, 0, 0)` to `(3, 0, 0)` and `(0, 0, 0)` to `(0, 4, 0)` store `lineDistance` values `0`, `3`, `3`, and `7`. The second pair starts where the first pair ended. The call returns the same line segments. An indexed geometry is left unchanged, so `lineDistance` stays absent.

`LineLoop.computeLineDistances` has landed. `LineLoop` has no method of its own; it follows `Line`. Vertices at `(0, 0, 0)`, `(3, 0, 0)`, and `(0, 4, 0)` store `lineDistance` values `0`, `3`, and `8`. The closing edge back to the first vertex is not included. The call returns the same line loop. An indexed geometry is left unchanged, so `lineDistance` stays absent.

`Points.updateMorphTargets` has landed. A new point cloud with no morph attributes keeps influences and the dictionary empty. A position group with targets named `wide` and `tall` stores influences `[0, 0]` and maps those names to `0` and `1`. Setting the first weight to `0.5` leaves another new point cloud at `0`. Assigning the geometry after construction leaves the dictionary empty until the call. Replacing that group with an unnamed target maps `"0"` to `0`. Clearing the morph attributes and calling again keeps `"0"` at `0`. Copying weights stays later.

`Line.updateMorphTargets` has landed. A new line with no morph attributes keeps influences and the dictionary empty. A position group with targets named `wide` and `tall` stores influences `[0, 0]` and maps those names to `0` and `1`. Setting the first weight to `0.5` leaves another new line at `0`. Assigning the geometry after construction leaves the dictionary empty until the call. Replacing that group with an unnamed target maps `"0"` to `0`. Clearing the morph attributes and calling again keeps `"0"` at `0`. `LineSegments` and `LineLoop` stay later.

`LineSegments.updateMorphTargets` has landed. `LineSegments` has no method of its own; it follows `Line`. A new line segments object with no morph attributes keeps influences and the dictionary empty. A position group with targets named `wide` and `tall` stores influences `[0, 0]` and maps those names to `0` and `1`. Setting the first weight to `0.5` leaves another new line segments object at `0`. Assigning the geometry after construction leaves the dictionary empty until the call. Replacing that group with an unnamed target maps `"0"` to `0`. Clearing the morph attributes and calling again keeps `"0"` at `0`. `LineLoop` stays later.

`LineLoop.updateMorphTargets` has landed. `LineLoop` has no method of its own; it follows `Line`. A new line loop with no morph attributes keeps influences and the dictionary empty. A position group with targets named `wide` and `tall` stores influences `[0, 0]` and maps those names to `0` and `1`. Setting the first weight to `0.5` leaves another new line loop at `0`. Assigning the geometry after construction leaves the dictionary empty until the call. Replacing that group with an unnamed target maps `"0"` to `0`. Clearing the morph attributes and calling again keeps `"0"` at `0`.

`InstancedMesh.setMorphAt` has landed. A mesh of count `2` starts with no morph data. Weights `[0.25, 0.5]` written to instance `1` allocate six zeros and store `[0, 0, 0, 0.25, 0.25, 0.5]`. The base influence is `1 - 0.75`. Turning `morphTargetsRelative` on and writing instance `0` keeps that length and stores `[1, 0.25, 0.5, 0.25, 0.25, 0.5]`. The value is the `DataTexture` float buffer. The texture object, `getMorphAt`, and copying the buffer stay later.

`InstancedMesh.getMorphAt` has landed. The same buffer is read into a mesh whose weights started at `[9, 9]`. Instance `1` becomes `[0.25, 0.5]`. Instance `0` also becomes `[0.25, 0.5]`, and the stored base `1` stays in the buffer. The source mesh stays at `[0.25, 0.5]`. The texture object and copying the buffer stay later.

`InstancedMesh.copy` now copies the morph buffer. Instance `1` with weights `[0.25, 0.5]` stores `[0, 0, 0, 0.25, 0.25, 0.5]`. The copy has those six values. Setting the copy's fourth value to `1` leaves the source at `0.25`. Copying a mesh with no morph data onto that copy leaves the `1` in place. `InstancedMesh.clone` uses the same copy, so the clone's fourth value starts at `0.25`, and setting it to `0` leaves the source at `0.25`. The texture object stays later.

`InstancedMesh.dispose` has landed. Instance `1` with weights `[0.25, 0.5]` stores `0.25` at the fourth buffer value. Dispose emits one `dispose` event and clears that buffer. A clone made first still has `0.25` and `0.5` at the fourth and sixth values. A mesh with no morph data stays empty after dispose.

`InstancedMesh.updateMorphTargets` has landed. It does nothing. A count `2` mesh whose geometry has position targets named `wide` and `tall` keeps an empty morph buffer, while a plain mesh maps `wide` to `0`. After writing weights `[0.25, 0.5]` to instance `1`, the call leaves the six values in place, including `0.25`, `0.25`, and `0.5` at the end.

`Group.copy` has landed. `Group` has no `copy` of its own; it follows `Object3D.copy`. A group at `y=3` with render order `4` and a child named `marker` copies onto a group that was at `x=1`. The destination moves to `y=3` with `x` `0`, and the child is a new node. `recursive` false keeps the transform and drops the child. The source child stays in place.

`Group.clone` has landed. The same group produces a new group at `y=3` with render order `4` and `x` `0`. The child named `marker` is a new node. `recursive` false drops the child and leaves the source child in place.

`Bone` has landed. A root bone adds a child bone, and that child sits at `y=5`. Both nodes have kind `Bone`. The child is the root's only child. `copy` and `clone` stay later.

`Bone.copy` has landed. `Bone` has no `copy` of its own; it follows `Object3D.copy`. A bone at `y=3` with render order `4` and a child bone named `marker` copies onto a bone that was at `x=1`. The destination moves to `y=3` with `x` `0`, and the child is a new bone. `recursive` false keeps the transform and drops the child. The source child stays in place. `clone` stays later.

`Bone.clone` has landed. The same bone produces a new bone at `y=3` with render order `4` and `x` `0`. The child bone named `marker` is a new bone. `recursive` false drops the child and leaves the source child in place.

`Skeleton` has landed. A shoulder at local `y=-5`, an elbow at `0`, and a hand at `5` are copied into the skeleton after their world matrices update. The shoulder and elbow inverses translate by `y=5`, and the hand inverse is identity. The bone matrix buffer holds 48 zeros. Moving the shoulder to `y=-2` and calculating again stores inverses at `y=2`, `y=2`, and `y=-3`. An empty skeleton has no bones, no inverses, and an empty buffer. A caller-supplied inverse list of the same length is kept. A list of the wrong length is replaced by one identity matrix per bone, and the supplied matrix stays at translation `y=9`. `pose`, `update`, and the bone texture stay later.

`Skeleton.pose` has landed. The same chain is moved so the shoulder sits at `y=-2`, then pose restores local positions `-5`, `0`, and `5`. The world translations are `y=-5`, `y=-5`, and `0`. The shoulder quaternion stays identity and the scales stay `1`. The stored inverses stay at `y=5`. A bone at local `y=5` under a group at `y=10` becomes local `y=15`, because that parent is not a bone. An empty skeleton stays empty. `update` and the bone texture stay later.

`Skeleton.update` has landed. At the bind pose the 48-float buffer holds three identity matrices. Moving the shoulder to `y=-2` writes translation `y=3` into each matrix, at floats `13`, `29`, and `45`. The shoulder position stays `-2`. An empty skeleton keeps an empty buffer. The bone texture stays later.

`Skeleton.clone` has landed. The same chain, after that update has stored `3` at float `13`, clones to a new skeleton. The bones array is new and still holds the shoulder and the hand. Pushing another bone leaves the source at length `3`. The inverse matrices are the same array, so writing translation `y=7` into the clone's first inverse changes the source too. The clone's matrix buffer is 48 zeros, and the source float `13` stays `3`. An empty skeleton clones to an empty skeleton that shares its inverse list. The bone texture stays later.

`Skeleton.getBoneByName` has landed. A shoulder named `shoulder` at `y=-5`, an elbow named `elbow` at `y=0`, and an unnamed hand at `y=5` are searched by name. `elbow` returns the elbow, and `""` returns the hand. Naming the hand `elbow` as well still returns the first elbow. `wrist` and an empty skeleton return nothing. The bone texture stays later.

`Skeleton.computeBoneTexture` has landed for the float layout. Three bones whose update stored `3` at float `13` grow from 48 floats to 64. Float `13` stays `3`, and floats `48` and `63` are `0`. Calling it again keeps that length and the `3`. An empty skeleton grows from nothing to 64 zeros. Seventeen bones grow from 272 floats to 576, and a `4` written at the first float stays there. A buffer longer than the layout aborts. The `DataTexture` object stays later.

`Skeleton.dispose` has landed. The same three-bone buffer, grown to 64 floats with `3` at float `13`, stays at that length after dispose. Float `63` stays `0`, the three bones stay, and the shoulder stays at `y=-2`. An empty skeleton stays empty. The `DataTexture` object stays later.

`Object3D.uuid` has landed. A new node stores a 36-character version-4 id. Copying another node onto it leaves that id in place. Cloning a node named `box` keeps a 36-character version-4 uuid and the name `box`, and the numeric id is new.

`Skeleton.toJSON` has landed. The shoulder, elbow, and hand chain writes version `4.7`, type `Skeleton`, and generator `Skeleton.toJSON`. The skeleton uuid is its own. The bone list is the shoulder, elbow, and hand uuids. The shoulder and elbow inverses translate by `y=5`, and the hand inverse is identity. Writing `9` into the serialized shoulder inverse leaves the stored matrix at `y=5`. An empty skeleton writes two empty lists. `fromJSON` stays later.

`Skeleton.fromJSON` has landed. That serialized chain, loaded into an empty skeleton with the three bones looked up by uuid, restores the skeleton uuid, the same three bones, inverses at `y=5`, `y=5`, and identity, and a 48-zero matrix buffer. Loading it again appends three more bones and the buffer becomes 96 zeros. A bone uuid `missing` creates a new bone, stores an identity inverse, and sets the skeleton uuid to `skeleton-id`.

`SkinnedMesh` has landed. A geometry point at `(0.5, 0, 0)` is kept on the inner mesh, whose count is `1` and whose node kind is `Mesh`. `bindMode` starts attached and can be set to detached. Both bind matrices are identity. The bounding box, bounding sphere, and skeleton are empty. `bind` stays later.

`SkinnedMesh.bind` has landed. A bind matrix translating by `y=4` is copied in, and its inverse translates by `y=-4`. The supplied matrix stays at `y=4`, and the bone inverse stays `0`. Binding without a matrix updates the mesh at `y=3`, recalculates the bone that moved from `y=-5` to `y=-2`, and stores inverse `y=2`. The bind matrix translates by `y=3` and its inverse by `y=-3`. Moving the mesh to `y=9` leaves the stored bind matrix at `y=3`.

`SkinnedMesh.pose` has landed. A shoulder at `y=-5`, an elbow at `0`, and a hand at `5` are bound with an identity matrix, then the shoulder moves to `y=-2`. Pose restores local positions `-5`, `0`, and `5`. The shoulder world translation is `y=-5`, the hand world translation is `0`, and the stored inverse stays at `y=5`. Posing without a skeleton aborts.

`SkinnedMesh.normalizeSkinWeights` has landed. Four weights `(2, 0, 0, 2)`, `(0, 0, 0, 0)`, `(-2, 2, 0, 0)`, and `(1, 1, 1, 1)` become `(0.5, 0, 0, 0.5)`, `(1, 0, 0, 0)`, `(-0.5, 0.5, 0, 0)`, and `(0.25, 0.25, 0.25, 0.25)`. The attribute is the same object. A mesh without `skinWeight` aborts.

`SkinnedMesh.updateMatrixWorld` has landed. A mesh at `y=3` in attached mode stores world translation `y=3` and an inverse bind translation of `y=-3`. The bind matrix stays identity. Switching to detached mode with a bind translation of `y=4` and moving the mesh to `y=9` keeps the world translation at `y=9` and writes the inverse bind translation `y=-4`.

`SkinnedMesh.applyBoneTransform` has landed for a `Vector3`. A point `(1, 0, 0)` with weight `1` on a bone that moved to `y=5` becomes `(1, 5, 0)`. The unused index `99` has weight `0` and is skipped. A zero point with weights `0.25` and `0.75` on bones at `y=5` and `x=4` becomes `(3, 1.25, 0)`. The bind matrix is identity. Calling it without a skeleton aborts. The `Vector4` target stays later.

`SkinnedMesh.applyBoneTransform` has landed for a `Vector4`. A point `(1, 0, 0, 1)` with weight `1` on a bone that moved to `y=5` becomes `(1, 5, 0, 1)`. A direction `(1, 0, 0, 0)` on that bone stays `(1, 0, 0, 0)`. A vector `(0, 0, 0, 2)` with weight `0.5` on an unmoved bone stays `(0, 0, 0, 2)`, because the blended `w` is written back to the value after the bind matrix. The bind matrix is identity. Calling it without a skeleton aborts. `computeBoundingBox` stays later.

`SkinnedMesh.getVertexPosition` has landed. A vertex `(1, 2, 3)` with weight `1` on a bone that moved to `y=5` becomes `(1, 7, 3)`. A relative morph `(2, 0, 0)` at weight `0.5` then becomes `(2, 7, 3)`. The bind matrix is identity. Calling it without a skeleton aborts. `computeBoundingBox` stays later.

`SkinnedMesh.computeBoundingBox` has landed. Vertices `(1, 0, 0)` and `(0, 4, 0)` with weight `1` on a bone that moved to `y=5` produce a box from `(0, 5, 0)` to `(1, 9, 0)`. Moving the bone to `y=1` and computing again writes `(0, 1, 0)` to `(1, 5, 0)` into the same box. An empty position attribute leaves the box empty. A mesh without `position` aborts. `computeBoundingSphere` stays later.

`SkinnedMesh.computeBoundingSphere` has landed. Vertices `(1, 0, 0)` and `(-1, 0, 0)` with weight `1` on a bone that moved to `y=5` produce a sphere centered at `(0, 5, 0)` with radius `1`. Moving the bone to `y=1` and computing again writes center `(0, 1, 0)` and radius `1` into the same sphere. An empty position attribute leaves the sphere empty, with radius `-1`. A mesh without `position` aborts. `copy` stays later.

`SkinnedMesh.copy` has landed. A mesh at `y=3` with render order `4`, a detached bind translation of `y=4`, and an inverse of `y=-4` copies onto a mesh that started at `x=1`. The destination ends at `y=3` and `x=0`, shares the geometry, material, and skeleton, and keeps a cloned box from `y=5` to `y=9` plus a cloned sphere of radius `1`. Writing `7` into the clone's minimum leaves the source at `5`. `recursive=false` drops the child named `marker`. A source without bounds leaves the destination's box at `y=9` and its sphere radius at `8`, and clears a skeleton the destination already held. `clone` stays later.

`SkinnedMesh.clone` has landed. The same mesh, with a child named `marker`, a detached bind translation of `y=4`, and a box from `y=5` to `y=9`, clones to a new mesh at `y=3` and `x=0`. The numeric id is new. The geometry, material, and skeleton are shared. Writing `7` into the cloned box minimum leaves the source at `5`. The cloned sphere stays centered at `y=5` with radius `1`. `recursive=false` drops the child, and the source child stays. `raycast` stays later.

`SkinnedMesh.raycast` has landed. A triangle `(0, 0, 0)`, `(1, 0, 0)`, `(0, 1, 0)` with weight `1` is hit by a ray from `(0.25, 0.25, 1)` toward `-z` at `(0.25, 0.25, 0)`, distance `1`. The barycentric weights are `0.5`, `0.25`, and `0.25`. Moving the bone to `y=5` moves the hit to `(0.25, 5.25, 0)`. A local box from `(10, 10, 10)` to `(11, 11, 11)` rejects that ray. A ray from `(0, 100, 1)` misses the skinned sphere. `Object3D.raycast` still uses the unskinned mesh path.

`Object3D.raycast` calls `SkinnedMesh.raycast` when the mesh node carries that hook. The same triangle, after the bone moves to `y=5`, is hit through `intersect_object` at `(0.25, 5.25, 0)`, distance `1`. A clone keeps its own hook and reports the hit on the clone. A plain mesh has no hook, and the same ray misses its unskinned triangle. Material arrays in the triangle walk stay later.

Mesh raycast material arrays have landed. Two triangles and an empty group list produce no hit. Groups `(0, 3)` at material `0` and `(3, 3)` at material `1`, with sides front and back, hit `(0.25, 0.25, 0)` at material index `0` and miss the second triangle. Switching the second side to front hits `(5.25, 0.25, 0)` at material index `1` and face index `1`. Copying the mesh keeps a new list of length `2`. A draw range starting at `3` with count `3` keeps only the second triangle, at material index `0`. An out-of-range material index aborts. Instanced and skinned material arrays stay later.

Instanced mesh raycast material arrays have landed. Two instances of one triangle, with the second translated by `x=2`, produce no hit while the group list is empty. A group `(0, 3)` at material `1` then hits `(0.25, 0.25, 0)` on instance `0` and `(2.25, 0.25, 0)` on instance `1`, both at material index `1` and distance `1`. Copying the mesh keeps a new list of length `2`. An out-of-range material index aborts. Skinned material arrays stay later.

Skinned mesh raycast material arrays have landed. A triangle with weight `1` on a bone that moved to `y=5` produces no hit while the group list is empty. A group `(0, 3)` at material `1` then hits `(0.25, 5.25, 0)`, distance `1`, material index `1`. Cloning keeps a new list of length `2`. An out-of-range material index aborts. The renderer still draws the single `material` and ignores the array.

Renderer material groups have landed. Two triangles with groups `(0, 3)` and `(3, 3)`, materials `0xFF0000` and `0x00FF00`, produce two opaque items and two shadow items. The first color is red `(1, 0)` and draws range `0` for `3`. The second is green `(0, 1)` and draws range `3` for `3`. An empty group list produces no item. Making the second material transparent leaves one opaque item and one transparent item. A material index past the array is skipped. A mesh without a material array still draws the whole geometry, with `group_count` `-1`. Wireframe groups stay later. `drawRange` intersection stays later.

Wireframe material groups have landed. The same two groups, with the first material wireframe and the second solid, put one red item on the wire list at range `0` for `3` and one green item on the opaque list at range `3` for `3`. An empty group list produces no wire item. Making the second material wireframe and transparent puts both items on the wire list and leaves the transparent list empty. The shadow list then keeps only the first group. A mesh without a material array and `wireframe` true still has `group_count` `-1`. The wire index draw multiplies that range by `2`. `drawRange` intersection stays later.

Draw range intersection has landed. Six vertices with `setDrawRange(1, 4)` draw from `1` for `4`. The same range on an index of length `3` draws from `1` for `2`. Groups `(0, 3)` and `(3, 3)` with range `(2, 3)` draw `(2, 1)` and `(3, 2)` in both the opaque list and the shadow list. A range of `(10, 2)` produces no item. Those groups as wireframe draw wire indices `(4, 2)` and `(6, 4)`. A mesh with no position stays out of the list. A mesh whose range covers the whole geometry still has `group_count` `-1`. Points and lines stay later.

Point and line draw ranges have landed. Four vertices start with `draw_count` `-1`. `setDrawRange(1, 2)` draws the points and the line from `1` for `2`. An index of length `3` with range `(1, 4)` draws from `1` for `2`. A range of `(8, 1)` produces no item. A transparent point keeps that range in the transparent list. Line segments use the same range. A points object with no position stays out of the list. Point and line material arrays stay later.

Point and line material arrays have landed. Four points with groups `(0, 2)` and `(2, 2)`, sizes `4` and `8`, produce two items. The first is red `(1, 0)` from `0` for `2`. The second is green `(0, 1)` from `2` for `2`, with size attenuation off. An empty group list produces no item. `setDrawRange(1, 2)` clips them to `(1, 1)` and `(2, 1)`. Making the second material transparent leaves one opaque item and one transparent item. A material index past the array is skipped. Cloning keeps a new list of length `2`. A line and line segments with the same groups draw `(0, 2)` and `(2, 2)`. Raycast material indices stay later.

Point and line raycast material indices have landed. Points at `x=0` and `x=2` with groups `(0, 1)` and `(1, 1)` miss while the group list is empty. A ray from `(0, 0.25, 0)` then hits `(0, 0, 0)` at material `0`, and a ray from `(2, 0.25, 0)` hits `(2, 0, 0)` at material `1`. `setDrawRange(1, 1)` keeps only the second hit. A line from `(0, 0, 0)` to `(1, 0, 0)` and `(2, 0, 0)` to `(3, 0, 0)` hits `(0.5, 0, 0)` at material `0` and `(2.5, 0, 0)` at material `1`. Line segments report the same second material. An out-of-range material index aborts. A point or line without a material array leaves `material_index` empty.

`DataTexture` has landed for the float RGBA layout `Skeleton.computeBoneTexture` uses. A one-texel texture stores `[1, 0, 0, 1]`. Filters are nearest, `flipY` is false, mipmaps stay off, and `unpackAlignment` is `1`. `needsUpdate` starts false. Writing `0.25` into the source array changes the texture, and `dispose` leaves that `0.25` in place. Three bones whose update stored `3` at float `13` grow to a `4×4` texture. Float `13` is `3` in both the matrix buffer and the texture, and `needsUpdate` is true. Setting it false and calling `update` turns it true again, and float `13` stays `3`. A clone has no texture. Calling `computeBoneTexture` again keeps length `64` and shares the new buffer, so writing `9` into float `13` shows up in the texture. Dispose drops the texture and leaves float `13` at `3`. An empty skeleton grows a `4×4` texture of zeros. Seventeen bones grow a `12×12` texture, and a `4` written at the first float stays there. A float count that is not `width * height * 4` aborts. The instanced morph texture object stays later.

`InstancedMesh.morphTexture` has landed as a red-format `DataTexture`. `RedFormat` is `1028` and stores one float per texel. Count `2` and weights `[0.25, 0.5]` written to instance `1` allocate six zeros. The texture is width `3` and height `2`, and `needsUpdate` stays false. The fourth value is `0.25`. Copying shares that float array. The new texture has `needsUpdate` true, and writing `1` into its fourth value changes the source to `1`. The source `needsUpdate` stays false. Copying a mesh with no morph data leaves the `1`. A clone shares the same array, so setting its fourth value to `0` changes the source to `0`. Dispose drops the texture. A clone made first still reads `0.25` and `0.5`.

`Points.copy` leaves morph weights in place. A position group named `wide` and `tall`, with the first weight set to `0.5`, copies onto a point cloud that had none. The destination influences and dictionary stay empty, and the source stays at `0.5` with `wide` at `0`. A destination built from that geometry starts at `[0, 0]`. Copying the weighted cloud onto it leaves the first weight at `0`. Setting that weight to `1` leaves the source at `0.5`. Copying a cloud with no morph data onto one whose first weight is `0.25` leaves that weight and `wide` at `0`. `Points.clone` builds a new cloud first, so the clone starts at `0` with `tall` at `1`, and setting its first weight to `1` leaves the source at `0.5`.

`SpriteMaterial` color, map, and transparency have landed. A new material is white `(1, 1, 1)`, opacity `1`, transparent, rotation `0`, and size attenuation on. The map is empty. `hex=0xFF0000`, opacity `0.25`, and transparent off store red `(1, 0, 0)`. A 1×1 map stays that texture object. Setting the red channel to `0.5` leaves another new material at `1`. `alphaMap` and fog stay later. The renderer still does not draw sprites.

`SpriteMaterial` alpha map and fog have landed. A new material has fog on and an empty alpha map. `fog=false` stores false. A 1×1 alpha map whose second byte is `0x80` stays that texture object. Another new material stays fog on with an empty alpha map. The renderer still does not draw sprites.

`SpriteMaterial.copy` has landed. A red material at opacity `0.25`, transparent off, fog off, rotation `0.5`, and size attenuation off copies onto a white material. The destination color object stays in place and becomes `(1, 0, 0)`. Setting its red channel to `0.5` leaves the source at `1`. The color map and the alpha map are the source objects. Opacity, transparency, fog, rotation, and size attenuation match the source.

`Line.copy` leaves morph weights in place. A position group named `wide` and `tall`, with the first weight set to `0.5`, copies onto a line that had none. The destination influences and dictionary stay empty, and the source stays at `0.5` with `wide` at `0`. A destination built from that geometry starts at `[0, 0]`. Copying the weighted line onto it leaves the first weight at `0`. Setting that weight to `1` leaves the source at `0.5`. Copying a line with no morph data onto one whose first weight is `0.25` leaves that weight and `wide` at `0`. `Line.clone` builds a new line first, so the clone starts at `0` with `tall` at `1`, and setting its first weight to `1` leaves the source at `0.5`. `LineSegments` and `LineLoop` use that same copy.

`PointsMaterial.map` has landed. A new material has an empty map, size `1`, and size attenuation on. A 1×1 map stays that texture object. Another new material stays empty. The point shader still draws from the material color and does not sample this map. `alphaMap` stays later.

`PointsMaterial.alphaMap` has landed. A new material has an empty alpha map and fog on. A 1×1 alpha map whose second byte is `0x80` stays that texture object. Another new material stays empty, and fog stays on. The point shader still draws from the material color and does not sample this map.

`PointsMaterial.copy` has landed. A red material at size `4`, size attenuation off, opacity `0.25`, transparent on, fog off, depth write off, depth test off, depth func `6`, color write off, premultiplied alpha on, and visible off copies onto a white material. The destination color object stays in place and becomes `(1, 0, 0)`. Setting its red channel to `0.5` leaves the source at `1`. Setting the destination size to `8` leaves the source at `4`. The color map and the alpha map are the source objects. Opacity, transparency, fog, size attenuation, depth, color write, premultiplied alpha, and visibility match the source.

`LineBasicMaterial.map` has landed. A new material has an empty map, white color, opacity `1`, and fog on. `hex=0x00FF00` stores green `(0, 1, 0)`. A 1×1 map stays that texture object. Another new material stays empty. The line shader still draws from the material color and does not sample this map. `linewidth`, `linecap`, and `linejoin` stay out.

`LineBasicMaterial.copy` has landed. A green material at opacity `0.25`, transparent on, fog off, depth write off, depth test off, depth func `6`, color write off, premultiplied alpha on, and visible off copies onto a white material. The destination color object stays in place and becomes `(0, 1, 0)`. Setting its green channel to `0.5` leaves the source at `1`. The color map is the source object. Opacity, transparency, fog, depth, color write, premultiplied alpha, and visibility match the source.

`SpriteMaterial` depth and visibility have landed. A new material writes depth, tests depth with func `3`, writes color, leaves premultiplied alpha off, and stays visible. Copying a material with depth write off, depth test off, depth func `6`, color write off, premultiplied alpha on, and visible off stores those values. The renderer still does not draw sprites.

`PointsMaterial.alphaTest` has landed. A new material stores `0`. Setting it to `0.4` leaves another new material at `0`. Copying onto a default material stores `0.4`. Setting the destination to `0.8` leaves the source at `0.4`. The point shader still does not discard fragments from this value.

`LineBasicMaterial.alphaTest` has landed. A new material stores `0`. Setting it to `0.4` leaves another new material at `0`. Copying onto a default material stores `0.4`. Setting the destination to `0.8` leaves the source at `0.4`. The line shader still does not discard fragments from this value.

`SpriteMaterial.alphaTest` has landed. A new material stores `0`. Setting it to `0.4` leaves another new material at `0`. Copying onto a default material stores `0.4`. Setting the destination to `0.8` leaves the source at `0.4`. The renderer still does not draw sprites.

Point and line `alphaTest` reaches the shader. A points material and a line material with `alphaTest` `0.4` and opacity `1` each store `0.4` on the collected item. The points shader discards when fragment alpha is below `uniforms.surface.z`. The line shader already discarded on that compare, and the uniform now carries the material value. Opacity `1` stays above `0.4`. Sprite `alphaTest` still has no draw.

`LineDashedMaterial` has landed. A new material has scale `1`, dash size `3`, and gap size `1`. The line fields live on the inner `line` material, which starts white with an empty map and `alphaTest` `0`. `hex=0x00FF00`, scale `2`, dash size `4`, and gap size `0.5` copy onto a default material. The destination color object stays in place and its green channel is `1`. Setting that channel to `0.5` leaves the source at `1`. Setting the destination dash size to `9` leaves the source at `4`. The color map is the source object. Another new material stays at scale `1`, dash size `3`, and gap size `1`. Lines still use `LineBasicMaterial`, and the shader still draws a solid line.

`LineDashedMaterial.keepsDistance` has landed. It has no upstream method of that name. Distance is multiplied by scale, then wrapped with GLSL `mod` over `dashSize + gapSize`. A remainder above `dashSize` is a gap. With scale `1`, dash size `3`, and gap size `1`, distances `0`, `3`, `4`, and `8` stay, and `3.5` is a gap. Distance `-0.5` wraps to `3.5` and is a gap. Scale `2` keeps distance `1.5` and drops `1.75`. A period of `0` aborts. The shader still draws a solid line.

`Material.vertexColors` has landed. A new basic, Lambert, or Standard material stores false. Setting the basic material to true leaves another basic material at false. Setting the Standard material to true leaves the Lambert material at false. The shader still ignores vertex colors.

`PointsMaterial.vertexColors` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. The point shader still ignores vertex colors.

`LineBasicMaterial.vertexColors` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. A dashed material copies the flag through its inner line material. The line shader still ignores vertex colors.

`SpriteMaterial.vertexColors` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. The renderer still does not draw sprites.

`Material.toneMapped` has landed. A new basic, Lambert, or Standard material stores true. Setting the basic material to false leaves another basic material at true. Setting the Standard material to false leaves the Lambert material at true. The tone-mapping pass still applies to every drawn material.

`PointsMaterial.toneMapped` has landed. A new material stores true. Setting it to false leaves another new material at true. Copying onto a default material stores false. Setting the destination back to true leaves the source at false. The tone-mapping pass still applies to every drawn point.

`LineBasicMaterial.toneMapped` has landed. A new material stores true. Setting it to false leaves another new material at true. Copying onto a default material stores false. Setting the destination back to true leaves the source at false. A dashed material copies the flag through its inner line material. The tone-mapping pass still applies to every drawn line.

`SpriteMaterial.toneMapped` has landed. A new material stores true. Setting it to false leaves another new material at true. Copying onto a default material stores false. Setting the destination back to true leaves the source at false. The renderer still does not draw sprites.

`Material.alphaHash` has landed. A new basic, Lambert, or Standard material stores false. Setting the basic material to true leaves another basic material at false. Setting the Standard material to true leaves the Lambert material at false. The shader still does not hash alpha.

`PointsMaterial.alphaHash` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. The point shader still does not hash alpha.

`LineBasicMaterial.alphaHash` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. A dashed material copies the flag through its inner line material. The line shader still does not hash alpha.

`SpriteMaterial.alphaHash` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. The renderer still does not draw sprites.

`Material.alphaToCoverage` has landed. A new basic, Lambert, or Standard material stores false. Setting the basic material to true leaves another basic material at false. Setting the Standard material to true leaves the Lambert material at false. The pipeline still does not enable alpha to coverage.

`PointsMaterial.alphaToCoverage` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. Point drawing still does not enable alpha to coverage.

`LineBasicMaterial.alphaToCoverage` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. A dashed material copies the flag through its inner line material. Line drawing still does not enable alpha to coverage.

`SpriteMaterial.alphaToCoverage` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. The renderer still does not draw sprites.

`Material.dithering` has landed. A new basic, Lambert, or Standard material stores false. Setting the basic material to true leaves another basic material at false. Setting the Standard material to true leaves the Lambert material at false. The shader still does not dither the color.

`PointsMaterial.dithering` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. The point shader still does not dither the color.

`LineBasicMaterial.dithering` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. A dashed material copies the flag through its inner line material. The line shader still does not dither the color.

`SpriteMaterial.dithering` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. The renderer still does not draw sprites.

`Material.polygonOffset` has landed. A new basic, Lambert, or Standard material stores false, factor `0`, and units `0`. Setting the basic material to true with factor `1` and units `-2` leaves another basic material at false, factor `0`, and units `0`. Setting the Standard material to true with factor `2` and units `4` leaves the Lambert material at false, factor `0`, and units `0`. The pipeline still does not offset polygons.

`PointsMaterial.polygonOffset` has landed. A new material stores false, factor `0`, and units `0`. Setting it to true with factor `1` and units `-2` leaves another new material at false, factor `0`, and units `0`. Copying onto a default material stores true, factor `1`, and units `-2`. Setting the destination factor to `3` and units to `5` leaves the source at `1` and `-2`. Point drawing still does not offset polygons.

`LineBasicMaterial.polygonOffset` has landed. A new material stores false, factor `0`, and units `0`. Setting it to true with factor `1` and units `-2` leaves another new material at false, factor `0`, and units `0`. Copying onto a default material stores true, factor `1`, and units `-2`. Setting the destination factor to `3` and units to `5` leaves the source at `1` and `-2`. A dashed material copies the three values through its inner line material. Setting the destination factor to `9` leaves the source at `1`. Line drawing still does not offset polygons.

`SpriteMaterial.polygonOffset` has landed. A new material stores false, factor `0`, and units `0`. Setting it to true with factor `1` and units `-2` leaves another new material at false, factor `0`, and units `0`. Copying onto a default material stores true, factor `1`, and units `-2`. Setting the destination factor to `3` and units to `5` leaves the source at `1` and `-2`. The renderer still does not draw sprites.

`Material.clipShadows` has landed. A new basic, Lambert, or Standard material stores false. Setting the basic material to true leaves another basic material at false. Setting the Standard material to true leaves the Lambert material at false. The shadow pass still does not clip.

`PointsMaterial.clipShadows` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. Points still do not cast shadows.

`LineBasicMaterial.clipShadows` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. A dashed material copies the flag through its inner line material. Lines still do not cast shadows.

`SpriteMaterial.clipShadows` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. The renderer still does not draw sprites.

`Material.clipIntersection` has landed. A new basic, Lambert, or Standard material stores false. Setting the basic material to true leaves another basic material at false. Setting the Standard material to true leaves the Lambert material at false. Clipping still uses the union, and the renderer still has no clipping planes.

`PointsMaterial.clipIntersection` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. Point drawing still has no clipping planes.

`LineBasicMaterial.clipIntersection` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. A dashed material copies the flag through its inner line material. Line drawing still has no clipping planes.

`SpriteMaterial.clipIntersection` has landed. A new material stores false. Setting it to true leaves another new material at false. Copying onto a default material stores true. Setting the destination back to false leaves the source at true. The renderer still does not draw sprites.

`Material.allowOverride` has landed. A new basic, Lambert, or Standard material stores true. Setting the basic material to false leaves another basic material at true. Setting the Standard material to false leaves the Lambert material at true. The renderer still does not replace a material with a scene override.

`PointsMaterial.allowOverride` has landed. A new material stores true. Setting it to false leaves another new material at true. Copying onto a default material stores false. Setting the destination back to true leaves the source at false. Point drawing still does not replace a material with a scene override.

`LineBasicMaterial.allowOverride` has landed. A new material stores true. Setting it to false leaves another new material at true. Copying onto a default material stores false. Setting the destination back to true leaves the source at false. A dashed material copies the flag through its inner line material. Line drawing still does not replace a material with a scene override.

`SpriteMaterial.allowOverride` has landed. A new material stores true. Setting it to false leaves another new material at true. Copying onto a default material stores false. Setting the destination back to true leaves the source at false. The renderer still does not draw sprites.

`Material.blendAlpha` has landed. A new basic, Lambert, or Standard material stores `0`. Setting the basic material to `0.25` leaves another basic material at `0`. Setting the Standard material to `0.5` leaves the Lambert material at `0`. Blending still does not use the constant alpha.

`PointsMaterial.blendAlpha` has landed. A new material stores `0`. Setting it to `0.25` leaves another new material at `0`. Copying onto a default material stores `0.25`. Setting the destination to `0.5` leaves the source at `0.25`. Point blending still does not use the constant alpha.

`LineBasicMaterial.blendAlpha` has landed. A new material stores `0`. Setting it to `0.25` leaves another new material at `0`. Copying onto a default material stores `0.25`. Setting the destination to `0.5` leaves the source at `0.25`. A dashed material copies the value through its inner line material. Setting the destination to `0.75` leaves the source at `0.25`. Line blending still does not use the constant alpha.

`SpriteMaterial.blendAlpha` has landed. A new material stores `0`. Setting it to `0.25` leaves another new material at `0`. Copying onto a default material stores `0.25`. Setting the destination to `0.5` leaves the source at `0.25`. The renderer still does not draw sprites.

`Material.blendColor` has landed. A new basic, Lambert, or Standard material stores black `(0, 0, 0)`. Setting the basic material red channel to `1` leaves another basic material at black. Setting the Standard material green channel to `0.5` leaves the Lambert material at black. Blending still does not use the constant color.

`PointsMaterial.blendColor` has landed. A new material stores black `(0, 0, 0)`. Setting its red channel to `1` leaves another new material at black. Copying onto a default material writes `(1, 0, 0)` into the destination's own color object. Setting that red channel to `0.5` leaves the source at `1`. Point blending still does not use the constant color.

`LineBasicMaterial.blendColor` has landed. A new material stores black `(0, 0, 0)`. Setting its red channel to `1` leaves another new material at black. Copying onto a default material writes `(1, 0, 0)` into the destination's own color object. Setting that red channel to `0.5` leaves the source at `1`. A dashed material copies the color through its inner line material. Setting the destination red channel to `0.5` leaves the source at `1`. Line blending still does not use the constant color.

`SpriteMaterial.blendColor` has landed. A new material stores black `(0, 0, 0)`. Setting its red channel to `1` leaves another new material at black. Copying onto a default material writes `(1, 0, 0)` into the destination's own color object. Setting that red channel to `0.5` leaves the source at `1`. The renderer still does not draw sprites. Blending still does not use the constant color.

`Material.blending` has landed. A new basic, Lambert, or Standard material stores `Normal`, whose integer is `1`. Setting the basic material to `Additive` (`2`) leaves another basic material at `Normal`. Setting the Standard material to `Multiply` (`4`) leaves the Lambert material at `Normal`. `No` is `0`, `Subtractive` is `3`, and `Custom` is `5`. Transparent draws still use the existing source-alpha blend. The pipeline still does not read this field.

`PointsMaterial.blending` has landed. A new material stores `Normal`, whose integer is `1`. Setting it to `Additive` (`2`) leaves another new material at `Normal`. Copying onto a default material stores `Additive`. Setting the destination to `Multiply` (`4`) leaves the source at `Additive`. Point draws still use the existing source-alpha blend. The pipeline still does not read this field.

`LineBasicMaterial.blending` has landed. A new material stores `Normal`, whose integer is `1`. Setting it to `Additive` (`2`) leaves another new material at `Normal`. Copying onto a default material stores `Additive`. Setting the destination to `Multiply` (`4`) leaves the source at `Additive`. A dashed material copies the mode through its inner line material. Setting the destination to `Subtractive` (`3`) leaves the source at `Additive`. Line draws still use the existing source-alpha blend. The pipeline still does not read this field.

`SpriteMaterial.blending` has landed. A new material stores `Normal`, whose integer is `1`. Setting it to `Additive` (`2`) leaves another new material at `Normal`. Copying onto a default material stores `Additive`. Setting the destination to `Multiply` (`4`) leaves the source at `Additive`. The renderer still does not draw sprites. The pipeline still does not read this field.

`Material.blendSrc` has landed. A new basic, Lambert, or Standard material stores `SrcAlpha`, whose integer is `204`. Setting the basic material to `One` (`201`) leaves another basic material at `SrcAlpha`. Setting the Standard material to `Zero` (`200`) leaves the Lambert material at `SrcAlpha`. The remaining factors are `SrcColor` `202`, `OneMinusSrcColor` `203`, `OneMinusSrcAlpha` `205`, `DstAlpha` `206`, `OneMinusDstAlpha` `207`, `DstColor` `208`, `OneMinusDstColor` `209`, `SrcAlphaSaturate` `210`, `ConstantColor` `211`, `OneMinusConstantColor` `212`, `ConstantAlpha` `213`, and `OneMinusConstantAlpha` `214`. Transparent draws still use the existing source-alpha blend. The pipeline still does not read this field.

`PointsMaterial.blendSrc` has landed. A new material stores `SrcAlpha`, whose integer is `204`. Setting it to `One` (`201`) leaves another new material at `SrcAlpha`. Copying onto a default material stores `One`. Setting the destination to `Zero` (`200`) leaves the source at `One`. Point draws still use the existing source-alpha blend. The pipeline still does not read this field.

`LineBasicMaterial.blendSrc` has landed. A new material stores `SrcAlpha`, whose integer is `204`. Setting it to `One` (`201`) leaves another new material at `SrcAlpha`. Copying onto a default material stores `One`. Setting the destination to `Zero` (`200`) leaves the source at `One`. A dashed material copies the factor through its inner line material. Setting the destination to `DstColor` (`208`) leaves the source at `One`. Line draws still use the existing source-alpha blend. The pipeline still does not read this field.

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
| planned | 7 | Object3D `traverseAncestors` | `core` |
| planned | 7 | Object3D `getObjectById` | `core` |
| planned | 7 | Object3D `copy` and `clone` | `core` |
| planned | 7 | Object3D `dispose` | `core` |
| planned | 7 | `Vector3.transformDirection` | `math` |
| planned | 7 | `Vector3.angleTo` | `math` |
| planned | 7 | `Vector3.distanceTo` | `math` |
| planned | 7 | `Vector3.manhattanDistanceTo` | `math` |
| planned | 7 | `Vector3.setFromSphericalCoords` | `math` |
| planned | 7 | `Vector3.setFromCylindricalCoords` | `math` |
| planned | 7 | `Vector3.setFromMatrixScale` | `math` |
| planned | 7 | `Vector3.setFromMatrix3Column` | `math` |
| planned | 7 | `Vector3.setFromEuler` | `math` |
| planned | 7 | `Vector3.setFromColor` | `math` |
| planned | 7 | `Vector3.fromArray` | `math` |
| planned | 7 | `Vector3.toArray` | `math` |
| planned | 7 | `Vector3.fromBufferAttribute` on `BufferAttribute` | `core` |
| planned | 7 | `Vector3.setScalar` | `math` |
| planned | 7 | `Vector3.setX`, `setY`, and `setZ` | `math` |
| planned | 7 | `Vector3.setComponent` and `getComponent` | `math` |
| planned | 7 | `Vector3.addScalar` | `math` |
| planned | 7 | `Vector3.addScaledVector` | `math` |
| planned | 7 | `Vector3.subScalar` | `math` |
| planned | 7 | `Vector3.multiply` | `math` |
| planned | 7 | `Vector3.multiplyVectors` | `math` |
| planned | 7 | `Vector3.applyEuler` | `math` |
| planned | 7 | `Vector3.applyAxisAngle` | `math` |
| planned | 7 | `Vector3.applyMatrix3` | `math` |
| planned | 7 | `Vector3.applyNormalMatrix` | `math` |
| planned | 7 | `Vector3.divide` | `math` |
| planned | 7 | `Vector3.divideScalar` | `math` |
| planned | 7 | `Vector3.clamp` | `math` |
| planned | 7 | `Vector3.clampScalar` | `math` |
| planned | 7 | `Vector3.clampLength` | `math` |
| planned | 7 | `Vector3.floor` | `math` |
| planned | 7 | `Vector3.ceil` | `math` |
| planned | 7 | `Vector3.round` | `math` |
| planned | 7 | `Vector3.roundToZero` | `math` |
| planned | 7 | `Vector3.manhattanLength` | `math` |
| planned | 7 | `Vector3.setLength` | `math` |
| planned | 7 | `Vector3.lerpVectors` | `math` |
| planned | 7 | `Vector3.projectOnVector` | `math` |
| planned | 7 | `Vector3.projectOnPlane` | `math` |
| planned | 7 | `Vector3.reflect` | `math` |
| planned | 7 | `Vector3.setFromSpherical` | `math` |
| planned | 7 | `Spherical.set` | `math` |
| planned | 7 | `Spherical.copy` | `math` |
| planned | 7 | `Spherical.makeSafe` | `math` |
| planned | 7 | `Spherical.setFromCartesianCoords` | `math` |
| planned | 7 | `Spherical.setFromVector3` | `math` |
| planned | 7 | `Spherical.clone` | `math` |
| planned | 7 | `Vector3.setFromCylindrical` | `math` |
| planned | 7 | `Cylindrical.set` | `math` |
| planned | 7 | `Cylindrical.copy` | `math` |
| planned | 7 | `Cylindrical.setFromCartesianCoords` | `math` |
| planned | 7 | `Cylindrical.setFromVector3` | `math` |
| planned | 7 | `Cylindrical.clone` | `math` |
| planned | 7 | `Vector2.setScalar` | `math` |
| planned | 7 | `Vector2.setX` | `math` |
| planned | 7 | `Vector2.setY` | `math` |
| planned | 7 | `Vector2.setComponent` | `math` |
| planned | 7 | `Vector2.getComponent` | `math` |
| planned | 7 | `Vector2.addScalar` | `math` |
| planned | 7 | `Vector2.addVectors` | `math` |
| planned | 7 | `Vector2.addScaledVector` | `math` |
| planned | 7 | `Vector2.subScalar` | `math` |
| planned | 7 | `Vector2.subVectors` | `math` |
| planned | 7 | `Vector2.multiply` | `math` |
| planned | 7 | `Vector2.divide` | `math` |
| planned | 7 | `Vector2.divideScalar` | `math` |
| planned | 7 | `Vector2.applyMatrix3` | `math` |
| planned | 7 | `Vector2.min` | `math` |
| planned | 7 | `Vector2.max` | `math` |
| planned | 7 | `Vector2.clamp` | `math` |
| planned | 7 | `Vector2.clampScalar` | `math` |
| planned | 7 | `Vector2.clampLength` | `math` |
| planned | 7 | `Vector2.floor` | `math` |
| planned | 7 | `Vector2.ceil` | `math` |
| planned | 7 | `Vector2.round` | `math` |
| planned | 7 | `Vector2.roundToZero` | `math` |
| planned | 7 | `Vector2.negate` | `math` |
| planned | 7 | `Vector2.cross` | `math` |
| planned | 7 | `Vector2.manhattanLength` | `math` |
| planned | 7 | `Vector2.angle` | `math` |
| planned | 7 | `Vector2.angleTo` | `math` |
| planned | 7 | `Vector2.distanceToSquared` | `math` |
| planned | 7 | `Vector2.distanceTo` | `math` |
| planned | 7 | `Vector2.manhattanDistanceTo` | `math` |
| planned | 7 | `Vector2.setLength` | `math` |
| planned | 7 | `Vector2.lerpVectors` | `math` |
| planned | 7 | `Vector2.fromArray` | `math` |
| planned | 7 | `Vector2.toArray` | `math` |
| planned | 7 | `Vector2.fromBufferAttribute` on `BufferAttribute` | `core` |
| planned | 7 | `Vector2.rotateAround` | `math` |
| planned | 7 | `Vector4.setScalar` | `math` |
| planned | 7 | `Vector4.setX` | `math` |
| planned | 7 | `Vector4.setY` | `math` |
| planned | 7 | `Vector4.setZ` | `math` |
| planned | 7 | `Vector4.setW` | `math` |
| planned | 7 | `Vector4.setComponent` | `math` |
| planned | 7 | `Vector4.getComponent` | `math` |
| planned | 7 | `Vector4.add` | `math` |
| planned | 7 | `Vector4.addScalar` | `math` |
| planned | 7 | `Vector4.addVectors` | `math` |
| planned | 7 | `Vector4.addScaledVector` | `math` |
| planned | 7 | `Vector4.sub` | `math` |
| planned | 7 | `Vector4.subScalar` | `math` |
| planned | 7 | `Vector4.subVectors` | `math` |
| planned | 7 | `Vector4.multiply` | `math` |
| planned | 7 | `Vector4.multiplyScalar` | `math` |
| planned | 7 | `Vector4.divide` | `math` |
| planned | 7 | `Vector4.divideScalar` | `math` |
| planned | 7 | `Vector4.setAxisAngleFromQuaternion` | `math` |
| planned | 7 | `Vector4.setAxisAngleFromRotationMatrix` | `math` |
| planned | 7 | `Vector4.setFromMatrixPosition` | `math` |
| planned | 7 | `Vector4.min` | `math` |
| planned | 7 | `Vector4.max` | `math` |
| planned | 7 | `Vector4.clamp` | `math` |
| planned | 7 | `Vector4.clampScalar` | `math` |
| planned | 7 | `Vector4.clampLength` | `math` |
| planned | 7 | `Vector4.floor` | `math` |
| planned | 7 | `Vector4.ceil` | `math` |
| planned | 7 | `Vector4.round` | `math` |
| planned | 7 | `Vector4.roundToZero` | `math` |
| planned | 7 | `Vector4.negate` | `math` |
| planned | 7 | `Vector4.manhattanLength` | `math` |
| planned | 7 | `Vector4.setLength` | `math` |
| planned | 7 | `Vector4.lerp` | `math` |
| planned | 7 | `Vector4.lerpVectors` | `math` |
| planned | 7 | `Vector4.equals` | `math` |
| planned | 7 | `Vector4.fromArray` | `math` |
| planned | 7 | `Vector4.toArray` | `math` |
| planned | 7 | `Vector4.fromBufferAttribute` on `BufferAttribute` | `core` |
| planned | 7 | `Box2` | `math` |
| planned | 7 | `Box2.set` | `math` |
| planned | 7 | `Box2.makeEmpty` | `math` |
| planned | 7 | `Box2.expandByPoint` | `math` |
| planned | 7 | `Box2.setFromPoints` | `math` |
| planned | 7 | `Box2.setFromCenterAndSize` | `math` |
| planned | 7 | `Box2.copy` | `math` |
| planned | 7 | `Box2.clone` | `math` |
| planned | 7 | `Box2.isEmpty` | `math` |
| planned | 7 | `Box2.getCenter` | `math` |
| planned | 7 | `Box2.getSize` | `math` |
| planned | 7 | `Box2.expandByVector` | `math` |
| planned | 7 | `Box2.expandByScalar` | `math` |
| planned | 7 | `Box2.containsPoint` | `math` |
| planned | 7 | `Box2.containsBox` | `math` |
| planned | 7 | `Box2.getParameter` | `math` |
| planned | 7 | `Box2.intersectsBox` | `math` |
| planned | 7 | `Box2.clampPoint` | `math` |
| planned | 7 | `Box2.distanceToPoint` | `math` |
| planned | 7 | `Box2.intersect` | `math` |
| planned | 7 | `Box2.union` | `math` |
| planned | 7 | `Box2.translate` | `math` |
| planned | 7 | `Box2.equals` | `math` |
| planned | 7 | `Box3.setFromArray` | `math` |
| planned | 7 | `Box3.setFromBufferAttribute` on `BufferAttribute` | `core` |
| planned | 7 | `Box3.setFromCenterAndSize` | `math` |
| planned | 7 | `Box3.copy` | `math` |
| planned | 7 | `Box3.clone` | `math` |
| planned | 7 | `Box3.expandByVector` | `math` |
| planned | 7 | `Box3.expandByScalar` | `math` |
| planned | 7 | `Box3.containsPoint` | `math` |
| planned | 7 | `Box3.containsBox` | `math` |
| planned | 7 | `Box3.getParameter` | `math` |
| planned | 7 | `Box3.intersectsBox` | `math` |
| planned | 7 | `Box3.clampPoint` | `math` |
| planned | 7 | `Box3.intersectsSphere` | `math` |
| planned | 7 | `Box3.intersectsPlane` | `math` |
| planned | 7 | `Box3.distanceToPoint` | `math` |
| planned | 7 | `Box3.getBoundingSphere` | `math` |
| planned | 7 | `Box3.intersect` | `math` |
| planned | 7 | `Box3.translate` | `math` |
| planned | 7 | `Box3.equals` | `math` |
| planned | 7 | `Box3.toJSON` | `math` |
| planned | 7 | `Box3.fromJSON` | `math` |
| planned | 7 | `Triangle` | `math` |
| planned | 7 | `Triangle.getNormal` | `math` |
| planned | 7 | `Triangle.getBarycoord` | `math` |
| planned | 7 | `Triangle.containsPoint` | `math` |
| planned | 7 | `Triangle.getInterpolation` | `math` |
| planned | 7 | `Triangle.getInterpolatedAttribute` on `BufferAttribute` | `core` |
| planned | 7 | `Triangle.isFrontFacing` | `math` |
| planned | 7 | `Triangle.set` | `math` |
| planned | 7 | `Triangle.setFromPointsAndIndices` | `math` |
| planned | 7 | `Triangle.setFromAttributeAndIndices` on `BufferAttribute` | `core` |
| planned | 7 | `Triangle.copy` | `math` |
| planned | 7 | `Triangle.clone` | `math` |
| planned | 7 | `Triangle.getArea` | `math` |
| planned | 7 | `Triangle.getMidpoint` | `math` |
| planned | 7 | `Triangle.normal`, the instance `getNormal` | `math` |
| planned | 7 | `Plane.setFromNormalAndCoplanarPoint` | `math` |
| planned | 7 | `Plane.setFromCoplanarPoints` | `math` |
| planned | 7 | `Triangle.getPlane` | `math` |
| planned | 7 | `Triangle.barycoord`, the instance `getBarycoord` | `math` |
| planned | 7 | `Triangle.interpolation`, the instance `getInterpolation` | `math` |
| planned | 7 | `Triangle.contains`, the instance `containsPoint` | `math` |
| planned | 7 | `Triangle.front_facing`, the instance `isFrontFacing` | `math` |
| planned | 7 | `Box3.intersectsTriangle` | `math` |
| planned | 7 | `Triangle.intersectsBox` | `math` |
| planned | 7 | `Triangle.closestPointToPoint` | `math` |
| planned | 7 | `Triangle.equals` | `math` |
| planned | 7 | `Plane.set` | `math` |
| planned | 7 | `Plane.negate` | `math` |
| planned | 7 | `Plane.distanceToSphere` | `math` |
| planned | 7 | `Plane.projectPoint` | `math` |
| planned | 7 | `Line3` | `math` |
| planned | 7 | `Line3.set` | `math` |
| planned | 7 | `Line3.copy` | `math` |
| planned | 7 | `Line3.getCenter` | `math` |
| planned | 7 | `Line3.delta` | `math` |
| planned | 7 | `Line3.distanceSq` | `math` |
| planned | 7 | `Line3.distance` | `math` |
| planned | 7 | `Line3.at` | `math` |
| planned | 7 | `Line3.closestPointToPointParameter` | `math` |
| planned | 7 | `Line3.closestPointToPoint` | `math` |
| planned | 7 | `Line3.distanceSqToLine3` | `math` |
| planned | 7 | `Line3.applyMatrix4` | `math` |
| planned | 7 | `Line3.equals` | `math` |
| planned | 7 | `Line3.clone` | `math` |
| planned | 7 | `Plane.intersectLine` | `math` |
| planned | 7 | `Plane.intersectsLine` | `math` |
| planned | 7 | `Plane.intersectsBox` | `math` |
| planned | 7 | `Sphere.intersectsPlane` | `math` |
| planned | 7 | `Plane.intersectsSphere` | `math` |
| planned | 7 | `Plane.coplanarPoint` | `math` |
| planned | 7 | `Plane.applyMatrix4` | `math` |
| planned | 7 | `Plane.translate` | `math` |
| planned | 7 | `Plane.equals` | `math` |
| planned | 7 | `Plane.clone` | `math` |
| planned | 7 | `Plane.toJSON` | `math` |
| planned | 7 | `Plane.fromJSON` | `math` |
| planned | 7 | `Sphere.set` | `math` |
| planned | 7 | `Sphere.distanceToPoint` | `math` |
| planned | 7 | `Sphere.intersectsBox` | `math` |
| planned | 7 | `Sphere.clampPoint` | `math` |
| planned | 7 | `Sphere.getBoundingBox` | `math` |
| planned | 7 | `Sphere.translate` | `math` |
| planned | 7 | `Sphere.expandByPoint` | `math` |
| planned | 7 | `Sphere.union` | `math` |
| planned | 7 | `Sphere.equals` | `math` |
| planned | 7 | `Sphere.clone` | `math` |
| planned | 7 | `Sphere.toJSON` | `math` |
| planned | 7 | `Sphere.fromJSON` | `math` |
| planned | 7 | `Ray` | `math` |
| planned | 7 | `Ray.set` | `math` |
| planned | 7 | `Ray.copy` | `math` |
| planned | 7 | `Ray.at` | `math` |
| planned | 7 | `Ray.lookAt` | `math` |
| planned | 7 | `Ray.recast` | `math` |
| planned | 7 | `Ray.closestPointToPoint` | `math` |
| planned | 7 | `Ray.distanceSqToPoint` | `math` |
| planned | 7 | `Ray.distanceToPoint` | `math` |
| planned | 7 | `Ray.distanceSqToSegment` | `math` |
| planned | 7 | `Ray.intersectSphere` | `math` |
| planned | 7 | `Ray.intersectsSphere` | `math` |
| planned | 7 | `Ray.distanceToPlane` | `math` |
| planned | 7 | `Ray.intersectPlane` | `math` |
| planned | 7 | `Ray.intersectsPlane` | `math` |
| planned | 7 | `Ray.intersectBox` | `math` |
| planned | 7 | `Ray.intersectsBox` | `math` |
| planned | 7 | `Ray.intersectTriangle` | `math` |
| planned | 7 | `Ray.applyMatrix4` | `math` |
| planned | 7 | `Ray.equals` | `math` |
| planned | 7 | `Ray.clone` | `math` |
| planned | 7 | `Color.set` | `math` |
| planned | 7 | `Color.setScalar` | `math` |
| planned | 7 | `MathUtils.clamp` | `math` |
| planned | 7 | `MathUtils.euclideanModulo` | `math` |
| planned | 7 | `Color.setHSL` | `math` |
| planned | 7 | `Color.copySRGBToLinear` | `math` |
| planned | 7 | `Color.copyLinearToSRGB` | `math` |
| planned | 7 | `Color.convertSRGBToLinear` | `math` |
| planned | 7 | `Color.convertLinearToSRGB` | `math` |
| planned | 7 | `Color.getHexString` | `math` |
| planned | 7 | `Color.getHSL` | `math` |
| planned | 7 | `Color.getRGB` | `math` |
| planned | 7 | `Color.getStyle` | `math` |
| planned | 7 | `Color.offsetHSL` | `math` |
| planned | 7 | `Color.add` | `math` |
| planned | 7 | `Color.addColors` | `math` |
| planned | 7 | `Color.addScalar` | `math` |
| planned | 7 | `Color.sub` | `math` |
| planned | 7 | `Color.multiply` | `math` |
| planned | 7 | `Color.multiplyScalar` | `math` |
| planned | 7 | `Color.lerpColors` | `math` |
| planned | 7 | `MathUtils.lerp` | `math` |
| planned | 7 | `Color.lerpHSL` | `math` |
| planned | 7 | `Color.setFromVector3` | `math` |
| planned | 7 | `Color.applyMatrix3` | `math` |
| planned | 7 | `Color.equals` | `math` |
| planned | 7 | `Color.fromArray` | `math` |
| planned | 7 | `Color.toArray` | `math` |
| planned | 7 | `Color.toJSON` | `math` |
| planned | 7 | `Euler.clone` | `math` |
| planned | 7 | `Euler.setFromVector3` | `math` |
| planned | 7 | `Euler.equals` | `math` |
| planned | 7 | `Euler.fromArray` | `math` |
| planned | 7 | `Euler.toArray` | `math` |
| planned | 7 | `Frustum.set` | `math` |
| planned | 7 | `Frustum.copy` | `math` |
| planned | 7 | `Frustum.intersectsBox` | `math` |
| planned | 7 | `Frustum.containsPoint` | `math` |
| planned | 7 | `Frustum.clone` | `math` |
| planned | 7 | `Matrix3.extractBasis` | `math` |
| planned | 7 | `Matrix3.multiplyMatrices` | `math` |
| planned | 7 | `Matrix3.multiply` | `math` |
| planned | 7 | `Matrix3.premultiply` | `math` |
| planned | 7 | `Matrix3.multiplyScalar` | `math` |
| planned | 7 | `Matrix3.transposeIntoArray` | `math` |
| planned | 7 | `Matrix3.setUvTransform` | `math` |
| planned | 7 | `Matrix3.makeScale` | `math` |
| planned | 7 | `Matrix3.scale` | `math` |
| planned | 7 | `Matrix3.makeRotation` | `math` |
| planned | 7 | `Matrix3.rotate` | `math` |
| planned | 7 | `Matrix3.makeTranslation` | `math` |
| planned | 7 | `Matrix3.translate` | `math` |
| planned | 7 | `Matrix3.equals` | `math` |
| planned | 7 | `Matrix3.fromArray` | `math` |
| planned | 7 | `Matrix3.toArray` | `math` |
| planned | 7 | `Matrix4.copyPosition` | `math` |
| planned | 7 | `Matrix4.setFromMatrix3` | `math` |
| planned | 7 | `Matrix4.extractBasis` | `math` |
| planned | 7 | `Matrix4.makeBasis` | `math` |
| planned | 7 | `Matrix4.multiplyScalar` | `math` |
| planned | 7 | `Matrix4.makeRotationX` | `math` |
| planned | 7 | `Matrix4.makeRotationY` | `math` |
| planned | 7 | `Matrix4.makeRotationZ` | `math` |
| planned | 7 | `Matrix4.makeRotationAxis` | `math` |
| planned | 7 | `Matrix4.makeScale` | `math` |
| planned | 7 | `Matrix4.makeShear` | `math` |
| planned | 7 | `Matrix4.fromArray` | `math` |
| planned | 7 | `Matrix4.toArray` | `math` |
| planned | 7 | `Quaternion.slerpFlat` | `math` |
| planned | 7 | `Quaternion.multiplyQuaternionsFlat` | `math` |
| planned | 7 | `Quaternion` `x` setter | `math` |
| planned | 7 | `Quaternion` `y` setter | `math` |
| planned | 7 | `Quaternion` `z` setter | `math` |
| planned | 7 | `Quaternion` `w` setter | `math` |
| planned | 7 | `Quaternion.setFromUnitVectors` | `math` |
| planned | 7 | `Quaternion.angleTo` | `math` |
| planned | 7 | `Quaternion.rotateTowards` | `math` |
| planned | 7 | `Quaternion.lengthSq` | `math` |
| planned | 7 | `Quaternion.slerpQuaternions` | `math` |
| planned | 7 | `Quaternion.random` | `math` |
| planned | 7 | `Quaternion.equals` | `math` |
| planned | 7 | `Quaternion.fromArray` | `math` |
| planned | 7 | `Quaternion.toArray` | `math` |
| planned | 7 | `Quaternion.toJSON` | `math` |
| planned | 7 | `MathUtils.mapLinear` | `math` |
| planned | 7 | `MathUtils.inverseLerp` | `math` |
| planned | 7 | `MathUtils.damp` | `math` |
| planned | 7 | `MathUtils.pingpong` | `math` |
| planned | 7 | `MathUtils.smoothstep` | `math` |
| planned | 7 | `MathUtils.smootherstep` | `math` |
| planned | 7 | `MathUtils.randInt` | `math` |
| planned | 7 | `MathUtils.randFloat` | `math` |
| planned | 7 | `MathUtils.randFloatSpread` | `math` |
| planned | 7 | `MathUtils.seededRandom` | `math` |
| planned | 7 | `MathUtils.isPowerOfTwo` | `math` |
| planned | 7 | `MathUtils.ceilPowerOfTwo` | `math` |
| planned | 7 | `MathUtils.floorPowerOfTwo` | `math` |
| planned | 7 | `MathUtils.setQuaternionFromProperEuler` | `math` |
| planned | 7 | `MathUtils.denormalize` | `math` |
| planned | 7 | `MathUtils.normalize` | `math` |
| planned | 7 | `MathUtils.generateUUID` | `math` |
| planned | 7 | `Matrix2` | `math` |
| planned | 7 | `Matrix2.set` | `math` |
| planned | 7 | `Matrix2.identity` | `math` |
| planned | 7 | `Matrix2.fromArray` | `math` |
| planned | 7 | `SphericalHarmonics3` | `math` |
| planned | 7 | `SphericalHarmonics3.set` | `math` |
| planned | 7 | `SphericalHarmonics3.zero` | `math` |
| planned | 7 | `SphericalHarmonics3.getAt` | `math` |
| planned | 7 | `SphericalHarmonics3.getIrradianceAt` | `math` |
| planned | 7 | `SphericalHarmonics3.add` | `math` |
| planned | 7 | `SphericalHarmonics3.addScaledSH` | `math` |
| planned | 7 | `SphericalHarmonics3.scale` | `math` |
| planned | 7 | `SphericalHarmonics3.lerp` | `math` |
| planned | 7 | `SphericalHarmonics3.equals` | `math` |
| planned | 7 | `SphericalHarmonics3.copy` | `math` |
| planned | 7 | `SphericalHarmonics3.clone` | `math` |
| planned | 7 | `SphericalHarmonics3.fromArray` | `math` |
| planned | 7 | `SphericalHarmonics3.toArray` | `math` |
| planned | 7 | `SphericalHarmonics3.getBasisAt` | `math` |
| planned | 7 | `FrustumArray` | `math` |
| planned | 7 | `FrustumArray.intersectsSphere` | `math` |
| planned | 7 | `FrustumArray.intersectsBox` | `math` |
| planned | 7 | `FrustumArray.containsPoint` | `math` |
| planned | 7 | `FrustumArray.copy` | `math` |
| planned | 7 | `FrustumArray.clone` | `math` |
| planned | 7 | `Interpolant` | `math` |
| planned | 7 | `Interpolant.copySampleValue_` | `math` |
| planned | 7 | `Interpolant.interpolate_` | `math` |
| planned | 7 | `Interpolant.intervalChanged_` | `math` |
| planned | 7 | `Interpolant.evaluate` | `math` |
| planned | 7 | `Interpolant.getSettings_` | `math` |
| planned | 7 | `BezierInterpolant` | `math` |
| planned | 7 | `cubicBezier` | `math` |
| planned | 7 | `cubicBezierSlope` | `math` |
| planned | 7 | `solveBezierParameter` | `math` |
| planned | 7 | `BezierInterpolant.interpolate_` | `math` |
| planned | 7 | `CubicInterpolant` | `math` |
| planned | 7 | `CubicInterpolant.intervalChanged_` | `math` |
| planned | 7 | `CubicInterpolant.interpolate_` | `math` |
| planned | 7 | `DiscreteInterpolant` | `math` |
| planned | 7 | `DiscreteInterpolant.interpolate_` | `math` |
| planned | 7 | `LinearInterpolant` | `math` |
| planned | 7 | `LinearInterpolant.interpolate_` | `math` |
| planned | 7 | `QuaternionLinearInterpolant` | `math` |
| planned | 7 | `QuaternionLinearInterpolant.interpolate_` | `math` |
| planned | 7 | `Color.setColorName` | `math` |
| planned | 7 | `Color.setStyle` | `math` |
| planned | 7 | `Color.fromBufferAttribute` on `BufferAttribute` | `core` |
| planned | 7 | `Quaternion.fromBufferAttribute` on `BufferAttribute` | `core` |
| planned | 7 | `Vector3.project` on `Object3D` | `core` |
| planned | 7 | `Vector3.unproject` on `Object3D` | `core` |
| planned | 7 | `BufferGeometry.deleteAttribute` | `core` |
| planned | 7 | `BufferGeometry.hasAttribute` | `core` |
| planned | 7 | `BufferGeometry.clearGroups` | `core` |
| planned | 7 | `BufferGeometry.setDrawRange` | `core` |
| planned | 7 | `BufferAttribute.applyMatrix4` | `core` |
| planned | 7 | `BufferAttribute.applyMatrix3` | `core` |
| planned | 7 | `BufferAttribute.applyNormalMatrix` | `core` |
| planned | 7 | `BufferAttribute.transformDirection` | `core` |
| planned | 7 | `BufferGeometry.applyMatrix4` | `core` |
| planned | 7 | `BufferGeometry.applyQuaternion` | `core` |
| planned | 7 | `BufferGeometry.rotateX` | `core` |
| planned | 7 | `BufferGeometry.rotateY` | `core` |
| planned | 7 | `BufferGeometry.rotateZ` | `core` |
| planned | 7 | `BufferGeometry.translate` | `core` |
| planned | 7 | `BufferGeometry.scale` | `core` |
| planned | 7 | `BufferGeometry.lookAt` | `core` |
| planned | 7 | `BufferGeometry.center` | `core` |
| planned | 7 | `BufferGeometry.setFromPoints` | `core` |
| planned | 7 | `BufferAttribute.setXYZW` | `core` |
| planned | 7 | `BufferGeometry.computeTangents` | `core` |
| planned | 7 | `BufferGeometry.normalizeNormals` | `core` |
| planned | 7 | `BufferGeometry.computeVertexNormals` | `core` |
| planned | 7 | `BufferGeometry.toNonIndexed` | `core` |
| planned | 7 | `BufferAttribute.toJSON` | `core` |
| planned | 7 | `BufferGeometry.toJSON` | `core` |
| planned | 7 | `BufferAttribute.copy` | `core` |
| planned | 7 | `BufferAttribute.clone` | `core` |
| planned | 7 | `BufferGeometry.copy` | `core` |
| planned | 7 | `BufferAttribute.copyAt` | `core` |
| planned | 7 | `BufferAttribute.copyArray` | `core` |
| planned | 7 | `BufferAttribute.set` | `core` |
| planned | 7 | `BufferAttribute.setComponent` | `core` |
| planned | 7 | `BufferAttribute.setX` | `core` |
| planned | 7 | `BufferAttribute.setY` | `core` |
| planned | 7 | `BufferAttribute.setZ` | `core` |
| planned | 7 | `BufferAttribute.getW` | `core` |
| planned | 7 | `BufferAttribute.setW` | `core` |
| planned | 7 | `BufferAttribute.setXY` | `core` |
| planned | 7 | `BufferAttribute.needsUpdate` | `core` |
| planned | 7 | `BufferAttribute.setUsage` | `core` |
| planned | 7 | `BufferAttribute.addUpdateRange` | `core` |
| planned | 7 | `BufferAttribute.clearUpdateRanges` | `core` |
| planned | 7 | `BufferAttribute.onUpload` | `core` |
| planned | 7 | `BufferAttribute.addEventListener` | `core` |
| planned | 7 | `BufferAttribute.dispose` | `core` |
| planned | 7 | `BufferAttribute.hasEventListener` | `core` |
| planned | 7 | `BufferAttribute.removeEventListener` | `core` |
| planned | 7 | `BufferAttribute.dispatchEvent` | `core` |
| planned | 7 | `BufferGeometry.clone` | `core` |
| planned | 7 | `BufferGeometry.addEventListener` | `core` |
| planned | 7 | `BufferGeometry.hasEventListener` | `core` |
| planned | 7 | `BufferGeometry.removeEventListener` | `core` |
| planned | 7 | `BufferGeometry.dispatchEvent` | `core` |
| planned | 7 | `BufferGeometry.dispose` | `core` |
| planned | 7 | `BufferAttribute.id` | `core` |
| planned | 7 | `BufferAttribute.name` | `core` |
| planned | 7 | `BufferAttribute.gpuType` | `core` |
| planned | 7 | `BufferGeometry.id` | `core` |
| planned | 7 | `BufferGeometry.uuid` | `core` |
| planned | 7 | `BufferGeometry.name` | `core` |
| planned | 7 | `BufferGeometry.type` | `core` |
| planned | 7 | `BufferGeometry.setIndirect` | `core` |
| planned | 7 | `BufferGeometry.getIndirect` | `core` |
| planned | 7 | `BufferGeometry.morphAttributes` | `core` |
| planned | 7 | `BufferGeometry.morphTargetsRelative` | `core` |
| planned | 7 | `BufferGeometry.userData` | `core` |
| planned | 7 | `BufferGeometry._transformed` | `core` |
| planned | 7 | `BufferGeometry.getIndex` | `core` |
| planned | 7 | `BufferAttribute.toJSON` name, usage, and gpuType | `core` |
| planned | 7 | `BufferGeometry.toJSON` uuid, name, type, and userData | `core` |
| planned | 7 | `BufferGeometry.applyMatrix4` needsUpdate | `core` |
| planned | 7 | `BufferGeometry.computeBoundingBox` morph positions | `core` |
| planned | 7 | `BufferGeometry.computeBoundingSphere` morph positions | `core` |
| planned | 7 | `BufferGeometry.toNonIndexed` morph attributes | `core` |
| planned | 7 | `BufferGeometry.toJSON` morph attributes | `core` |
| planned | 7 | `BufferGeometry.setIndirect` byte offsets | `core` |
| planned | 7 | `Timer.update` | `core` |
| planned | 7 | `Timer.getElapsed` | `core` |
| planned | 7 | `Timer.getTimescale` | `core` |
| planned | 7 | `Timer.setTimescale` | `core` |
| planned | 7 | `Timer.reset` | `core` |
| planned | 7 | `InstancedBufferAttribute.meshPerAttribute` | `core` |
| planned | 7 | `InstancedBufferAttribute.toJSON` | `core` |
| planned | 7 | `InstancedBufferGeometry.instanceCount` | `core` |
| planned | 7 | `InstancedBufferGeometry.toJSON` | `core` |
| planned | 7 | `InterleavedBuffer` | `core` |
| planned | 7 | `InterleavedBuffer.setUsage` | `core` |
| planned | 7 | `InterleavedBuffer.addUpdateRange` | `core` |
| planned | 7 | `InterleavedBuffer.clearUpdateRanges` | `core` |
| planned | 7 | `InterleavedBuffer.copy` | `core` |
| planned | 7 | `InterleavedBuffer.copyAt` | `core` |
| planned | 7 | `InterleavedBuffer.set` | `core` |
| planned | 7 | `InterleavedBuffer.clone` | `core` |
| planned | 7 | `InterleavedBuffer.onUpload` | `core` |
| planned | 7 | `InterleavedBuffer.needsUpdate` | `core` |
| planned | 7 | `InterleavedBuffer.uuid` | `core` |
| planned | 7 | `InterleavedBuffer.toJSON` | `core` |
| planned | 7 | `InterleavedBufferAttribute` | `core` |
| planned | 7 | `InterleavedBufferAttribute.array` | `core` |
| planned | 7 | `InterleavedBufferAttribute.needsUpdate` | `core` |
| planned | 7 | `InterleavedBufferAttribute.getX` | `core` |
| planned | 7 | `InterleavedBufferAttribute.setX` | `core` |
| planned | 7 | `InterleavedBufferAttribute.setY` | `core` |
| planned | 7 | `InterleavedBufferAttribute.setZ` | `core` |
| planned | 7 | `InterleavedBufferAttribute.setW` | `core` |
| planned | 7 | `InterleavedBufferAttribute.getY` | `core` |
| planned | 7 | `InterleavedBufferAttribute.getZ` | `core` |
| planned | 7 | `InterleavedBufferAttribute.getW` | `core` |
| planned | 7 | `InterleavedBufferAttribute.setXY` | `core` |
| planned | 7 | `InterleavedBufferAttribute.setXYZ` | `core` |
| planned | 7 | `InterleavedBufferAttribute.setXYZW` | `core` |
| planned | 7 | `InterleavedBufferAttribute.applyMatrix4` | `core` |
| planned | 7 | `InterleavedBufferAttribute.applyNormalMatrix` | `core` |
| planned | 7 | `InterleavedBufferAttribute.transformDirection` | `core` |
| planned | 7 | `InterleavedBufferAttribute.getComponent` | `core` |
| planned | 7 | `InterleavedBufferAttribute.setComponent` | `core` |
| planned | 7 | `InterleavedBufferAttribute.clone` | `core` |
| planned | 7 | `InterleavedBufferAttribute.toJSON` | `core` |
| planned | 7 | `InstancedInterleavedBuffer.meshPerAttribute` | `core` |
| planned | 7 | `InstancedInterleavedBuffer.toJSON` | `core` |
| planned | 7 | `Raycaster` | `core` |
| planned | 7 | `Raycaster.set` | `core` |
| planned | 7 | `Raycaster.setFromCamera` | `core` |
| planned | 7 | `Raycaster.layers` | `core` |
| planned | 7 | `Raycaster.params` | `core` |
| planned | 7 | `Object3D.raycast` | `core` |
| planned | 7 | `Raycaster.intersectObject` | `core` |
| planned | 7 | `Raycaster.intersectObjects` | `core` |
| planned | 7 | `Mesh.getVertexPosition` | `core` |
| planned | 7 | `Mesh.raycast` | `core` |
| planned | 7 | `Mesh.raycast` face | `core` |
| planned | 7 | `Triangle.getInterpolatedAttribute` for `Vector2` | `core` |
| planned | 7 | `Mesh.raycast` uv | `core` |
| planned | 7 | `Mesh.raycast` uv1 | `core` |
| planned | 7 | `Mesh.raycast` normal | `core` |
| planned | 7 | `Line.raycast` | `core` |
| planned | 7 | `Points.raycast` | `core` |
| planned | 7 | `Sprite.raycast` | `core` |
| planned | 7 | `LOD.addLevel` | `objects` |
| planned | 7 | `LOD.removeLevel` | `objects` |
| planned | 7 | `LOD.getObjectForDistance` | `objects` |
| planned | 7 | `LOD.raycast` | `core` |
| planned | 7 | `LOD.update` | `objects` |
| planned | 7 | `LineLoop` raycast | `core` |
| planned | 7 | `Sprite.intersectsFrustum` | `objects` |
| planned | 7 | `Object3D.intersectsFrustum` | `core` |
| planned | 7 | `Object3D.intersectsFrustumArray` | `core` |
| planned | 7 | `Sprite.intersectsFrustumArray` | `objects` |
| planned | 7 | `ArrayCamera` | `cameras` |
| planned | 7 | `FrustumArray.setFromArrayCamera` | `cameras` |
| planned | 7 | `InstancedMesh.computeBoundingSphere` | `objects` |
| planned | 7 | `InstancedMesh.intersectsFrustum` | `objects` |
| planned | 7 | `InstancedMesh.intersectsFrustumArray` | `objects` |
| planned | 7 | `Object3D.intersectsFrustum` uses the instanced bounding sphere | `core` |
| planned | 7 | opaque list culling uses the instanced bounding sphere | `renderer` |
| planned | 7 | `InstancedMesh.raycast` | `core` |
| planned | 7 | `InstancedMesh.copy` | `objects` |
| planned | 7 | `InstancedMesh.clone` | `objects` |
| planned | 7 | `LOD.copy` | `objects` |
| planned | 7 | `LOD.clone` | `objects` |
| planned | 7 | `LOD.getCurrentLevel` | `objects` |
| planned | 7 | `Sprite.geometry` | `objects` |
| planned | 7 | `Sprite.count` | `objects` |
| planned | 7 | `Mesh.copy` | `objects` |
| planned | 7 | `Mesh.clone` | `objects` |
| planned | 7 | `Mesh.count` | `objects` |
| planned | 7 | `Mesh.updateMorphTargets` | `objects` |
| planned | 7 | `Mesh.copy` copies morph weights | `objects` |
| planned | 7 | `Points.copy` | `objects` |
| planned | 7 | `Points.clone` | `objects` |
| planned | 7 | `Line.copy` | `objects` |
| planned | 7 | `Line.clone` | `objects` |
| planned | 7 | `LineSegments.copy` | `objects` |
| planned | 7 | `LineSegments.clone` | `objects` |
| planned | 7 | `LineLoop.copy` | `objects` |
| planned | 7 | `LineLoop.clone` | `objects` |
| planned | 7 | `Sprite.copy` | `objects` |
| planned | 7 | `Sprite.clone` | `objects` |
| planned | 7 | `Line.computeLineDistances` | `objects` |
| planned | 7 | `LineSegments.computeLineDistances` | `objects` |
| planned | 7 | `LineLoop.computeLineDistances` | `objects` |
| planned | 7 | `Points.updateMorphTargets` | `objects` |
| planned | 7 | `Line.updateMorphTargets` | `objects` |
| planned | 7 | `LineSegments.updateMorphTargets` | `objects` |
| planned | 7 | `LineLoop.updateMorphTargets` | `objects` |
| planned | 7 | `InstancedMesh.setMorphAt` | `objects` |
| planned | 7 | `InstancedMesh.getMorphAt` | `objects` |
| planned | 7 | `InstancedMesh.copy` copies the morph buffer | `objects` |
| planned | 7 | `InstancedMesh.dispose` | `objects` |
| planned | 7 | `InstancedMesh.updateMorphTargets` | `objects` |
| planned | 7 | `Group.copy` | `objects` |
| planned | 7 | `Group.clone` | `objects` |
| planned | 7 | `Bone` | `objects` |
| planned | 7 | `Bone.copy` | `objects` |
| planned | 7 | `Bone.clone` | `objects` |
| planned | 7 | `Skeleton` | `objects` |
| planned | 7 | `Skeleton.pose` | `objects` |
| planned | 7 | `Skeleton.update` | `objects` |
| planned | 7 | `Skeleton.clone` | `objects` |
| planned | 7 | `Skeleton.getBoneByName` | `objects` |
| planned | 7 | `Skeleton.computeBoneTexture` | `objects` |
| planned | 7 | `Skeleton.dispose` | `objects` |
| planned | 7 | `Object3D.uuid` | `core` |
| planned | 7 | `Skeleton.toJSON` | `objects` |
| planned | 7 | `Skeleton.fromJSON` | `objects` |
| planned | 7 | `SkinnedMesh` | `objects` |
| planned | 7 | `SkinnedMesh.bind` | `objects` |
| planned | 7 | `SkinnedMesh.pose` | `objects` |
| planned | 7 | `SkinnedMesh.normalizeSkinWeights` | `objects` |
| planned | 7 | `SkinnedMesh.updateMatrixWorld` | `objects` |
| planned | 7 | `SkinnedMesh.applyBoneTransform` | `objects` |
| planned | 7 | `SkinnedMesh.applyBoneTransform` for `Vector4` | `objects` |
| planned | 7 | `SkinnedMesh.getVertexPosition` | `objects` |
| planned | 7 | `SkinnedMesh.computeBoundingBox` | `objects` |
| planned | 7 | `SkinnedMesh.computeBoundingSphere` | `objects` |
| planned | 7 | `SkinnedMesh.copy` | `objects` |
| planned | 7 | `SkinnedMesh.clone` | `objects` |
| planned | 7 | `SkinnedMesh.raycast` | `objects` |
| planned | 7 | `Object3D.raycast` skinned hook | `core`, `objects` |
| planned | 7 | mesh raycast material arrays | `core`, `objects` |
| planned | 7 | instanced mesh raycast material arrays | `objects` |
| planned | 7 | skinned mesh raycast material arrays | `objects` |
| planned | 7 | renderer material groups | `renderer` |
| planned | 7 | wireframe material groups | `renderer` |
| planned | 7 | draw range intersection | `renderer` |
| planned | 7 | point and line draw ranges | `renderer` |
| planned | 7 | point and line material arrays | `objects`, `renderer` |
| planned | 7 | point and line raycast material indices | `core` |
| planned | 7 | `DataTexture` for skeleton bone matrices | `textures`, `objects` |
| planned | 7 | `InstancedMesh.morphTexture` | `textures`, `objects` |
| planned | 7 | `Points.copy` leaves morph weights in place | `objects` |
| planned | 7 | `SpriteMaterial` color, map, and transparency | `materials` |
| planned | 7 | `SpriteMaterial` alpha map and fog | `materials` |
| planned | 7 | `SpriteMaterial.copy` | `materials` |
| planned | 7 | `Line.copy` leaves morph weights in place | `objects` |
| planned | 7 | `PointsMaterial.map` | `materials` |
| planned | 7 | `PointsMaterial.alphaMap` | `materials` |
| planned | 7 | `PointsMaterial.copy` | `materials` |
| planned | 7 | `LineBasicMaterial.map` | `materials` |
| planned | 7 | `LineBasicMaterial.copy` | `materials` |
| planned | 7 | `SpriteMaterial` depth and visibility | `materials` |
| planned | 7 | `PointsMaterial.alphaTest` | `materials` |
| planned | 7 | `LineBasicMaterial.alphaTest` | `materials` |
| planned | 7 | `SpriteMaterial.alphaTest` | `materials` |
| planned | 7 | point and line `alphaTest` in the shader | `objects`, `renderer`, `nodes` |
| planned | 7 | `LineDashedMaterial` scale, dash size, and gap size | `materials` |
| planned | 7 | `LineDashedMaterial.keepsDistance` | `materials` |
| planned | 7 | `Material.vertexColors` | `materials` |
| planned | 7 | `PointsMaterial.vertexColors` | `materials` |
| planned | 7 | `LineBasicMaterial.vertexColors` | `materials` |
| planned | 7 | `SpriteMaterial.vertexColors` | `materials` |
| planned | 7 | `Material.toneMapped` | `materials` |
| planned | 7 | `PointsMaterial.toneMapped` | `materials` |
| planned | 7 | `LineBasicMaterial.toneMapped` | `materials` |
| planned | 7 | `SpriteMaterial.toneMapped` | `materials` |
| planned | 7 | `Material.alphaHash` | `materials` |
| planned | 7 | `PointsMaterial.alphaHash` | `materials` |
| planned | 7 | `LineBasicMaterial.alphaHash` | `materials` |
| planned | 7 | `SpriteMaterial.alphaHash` | `materials` |
| planned | 7 | `Material.alphaToCoverage` | `materials` |
| planned | 7 | `PointsMaterial.alphaToCoverage` | `materials` |
| planned | 7 | `LineBasicMaterial.alphaToCoverage` | `materials` |
| planned | 7 | `SpriteMaterial.alphaToCoverage` | `materials` |
| planned | 7 | `Material.dithering` | `materials` |
| planned | 7 | `PointsMaterial.dithering` | `materials` |
| planned | 7 | `LineBasicMaterial.dithering` | `materials` |
| planned | 7 | `SpriteMaterial.dithering` | `materials` |
| planned | 7 | `Material.polygonOffset` | `materials` |
| planned | 7 | `PointsMaterial.polygonOffset` | `materials` |
| planned | 7 | `LineBasicMaterial.polygonOffset` | `materials` |
| planned | 7 | `SpriteMaterial.polygonOffset` | `materials` |
| planned | 7 | `Material.clipShadows` | `materials` |
| planned | 7 | `PointsMaterial.clipShadows` | `materials` |
| planned | 7 | `LineBasicMaterial.clipShadows` | `materials` |
| planned | 7 | `SpriteMaterial.clipShadows` | `materials` |
| planned | 7 | `Material.clipIntersection` | `materials` |
| planned | 7 | `PointsMaterial.clipIntersection` | `materials` |
| planned | 7 | `LineBasicMaterial.clipIntersection` | `materials` |
| planned | 7 | `SpriteMaterial.clipIntersection` | `materials` |
| planned | 7 | `Material.allowOverride` | `materials` |
| planned | 7 | `PointsMaterial.allowOverride` | `materials` |
| planned | 7 | `LineBasicMaterial.allowOverride` | `materials` |
| planned | 7 | `SpriteMaterial.allowOverride` | `materials` |
| planned | 7 | `Material.blendAlpha` | `materials` |
| planned | 7 | `PointsMaterial.blendAlpha` | `materials` |
| planned | 7 | `LineBasicMaterial.blendAlpha` | `materials` |
| planned | 7 | `SpriteMaterial.blendAlpha` | `materials` |
| planned | 7 | `Material.blendColor` | `materials` |
| planned | 7 | `PointsMaterial.blendColor` | `materials` |
| planned | 7 | `LineBasicMaterial.blendColor` | `materials` |
| planned | 7 | `SpriteMaterial.blendColor` | `materials` |
| planned | 7 | `Material.blending` | `materials` |
| planned | 7 | `PointsMaterial.blending` | `materials` |
| planned | 7 | `LineBasicMaterial.blending` | `materials` |
| planned | 7 | `SpriteMaterial.blending` | `materials` |
| planned | 7 | `Material.blendSrc` | `materials` |
| planned | 7 | `PointsMaterial.blendSrc` | `materials` |
| planned | 7 | `LineBasicMaterial.blendSrc` | `materials` |
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
