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
