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
docs/PLAN.md                 index
docs/plan/done/              landed modules
docs/plan/active/            the current slice
docs/plan/later/             not started
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
5. This is a semantic port. Upstream files that the port uses are listed in the module checklists under `docs/plan/`.
6. A ported implementation file carries an `r186` blob link. The first line is `// r186:` and points at the upstream file. Each public type that maps to a class, and each core function whose upstream name is not obvious from that type, has a `/// r186:` line on the declaration. The URL is `https://github.com/mrdoob/three.js/blob/r186/<path>#L<line>`. Tests, examples, ffi, and generated bindings stay unmarked. The comment rules are in `.cursor/skills/upstream-links/SKILL.md`.
7. Split implementation files the way r186 splits source files. One upstream class or module is one `.mbt` in the existing package directory. A file that is already one upstream unit stays one file, even when that unit is long (`GLTFLoader.js`, `BufferGeometry.js`, `Object3D.js`, `constants.js`). Do not open a new package just to shorten a file. Tests follow the same boundary. The rule is in `.cursor/skills/source-layout/SKILL.md`.
8. Do not port WebGL. The host is `wasi:webgpu` only. `WebGLRenderer`, `WebGLBackend`, `src/renderers/webgl`, `src/renderers/shaders`, GLSL prefixes, and `WebGLPrograms` stay upstream. A comment may name a GLSL chunk when a WGSL or CPU formula took its numbers from there. `WebGLCoordinateSystem` stays as the NDC constant and is not a backend. The rule is in `.cursor/skills/no-webgl/SKILL.md`.


## Where the plan lives

`docs/plan/` is split by module. The directory is the status:

| Directory | 状态 | Meaning |
|---|---|---|
| [done](plan/done/) | 已完成 | Landed behavior and its checklist |
| [active](plan/active/) | 活跃中 | The slice being ported now |
| [later](plan/later/) | 待实现 | Decided, not started |

A module can appear in more than one directory. `materials` has landed shading in `done`. The `WebGLPrograms` prefix port was removed and stays out of scope. Environment maps stay in `later`. `ShaderLib` stays upstream with the rest of the GLSL sources.

The next slice is the WebGPU work named at the end of the last paragraph under `## Behavior` in a file under [plan/active/](plan/active/), when that sentence ends with “X stays later”. One slice is a module’s whole remaining WebGPU plan, not one sentence inside it, and it lands as one commit. The current materials note records that the WebGL program path was removed. Do not resume it. When no active file names such a slice, timed advance takes the next `later` file, moves its WebGPU items into `active`, and implements that file as one slice. Do not take the next slice from `done`. If `later` has no remaining WebGPU work, cancel the timer. WebGL and GLSL program work stays upstream.

### Done

- [animation](plan/done/animation.md)
- [cameras](plan/done/cameras.md)
- [compute](plan/done/compute.md)
- [constants](plan/done/constants.md)
- [core](plan/done/core.md)
- [geometries](plan/done/geometries.md)
- [gltf](plan/done/gltf.md)
- [lights](plan/done/lights.md)
- [materials](plan/done/materials.md)
- [math](plan/done/math.md)
- [nodes](plan/done/nodes.md)
- [objects](plan/done/objects.md)
- [platform](plan/done/platform.md)
- [post](plan/done/post.md)
- [renderer](plan/done/renderer.md)
- [scenes](plan/done/scenes.md)
- [textures](plan/done/textures.md)

### Active

- [materials](plan/active/materials.md)

### Later

- [gltf](plan/later/gltf.md)
- [materials](plan/later/materials.md)
- [nodes](plan/later/nodes.md)
- [post](plan/later/post.md)
- [renderer](plan/later/renderer.md)
- [textures](plan/later/textures.md)

## Phases

Phase 0 through phase 6 have landed. The notes for each module are in `docs/plan/done/`. Phase 7 is the open scene work: what has landed is in `done`, and the items still waiting are in `later`. The WebGL shader-parameter port was removed from `active`.

Out of scope, and not in `later`:

| status | item | packages |
|---|---|---|
| excluded | `src/renderers/webgl`, `webgl-fallback`, `WebGLRenderer.js`, `WebGLProgram.js`, `WebGLPrograms.js`, `WebGLShaderCache.js`, `shaders/`, `ShaderLib`, `webxr/`, `audio/` | None |

## Risks

- If phase 1 shows that the component-model bindings cannot express async `request-adapter` / `request-device`, the scene graph keeps its own call shape. `bindings` is a separate package so that layer can be replaced.
- Schedule risk sits in the node compiler. Hard-coded WGSL pushes that risk to phase 4.
- Phase 1 confirmed `present` on wasi-gfx-runtime: the clear sample's swapchain color reaches the window.
