# three-mbt

[中文](README.zh.md)

A MoonBit migration of the [three.js](https://github.com/mrdoob/three.js) **r186** WebGPU world. GPU access goes through [wasi:webgpu](https://github.com/WebAssembly/wasi-webgpu). Windows, the frame loop, and input go through [wasi-gfx](https://github.com/wasi-gfx/wasi-gfx).

Phase 1 opens a wasi-gfx surface, configures a WebGPU swapchain, and clears it on each frame. Phase 2 is the CPU scene graph, checked against r186 fixtures. Phase 3 draws an unlit rotating cube. Phase 4 adds Lambert shading with ambient light and one directional light. Phase 5 adds `rgba8` textures, rebuilds the swapchain on resize, and orbits the camera from pointer events in the sample. Phase 6 adds `MeshStandardMaterial` with roughness, metalness, and the directional light. Phase 7 has started with points, lines, instancing, directional shadows, render targets, fog, an animation mixer, a glTF geometry and PBR subset, a compute shader that writes point positions, a grayscale fullscreen pass, transparent meshes drawn back to front, tone mapping through Neutral, and a single-resolution bloom pass. Scope is in [docs/PLAN.md](docs/PLAN.md).

## Check

```sh
moon check
moon check --target wasm
moon test
```

Build the clear component, then run it with [wasi-gfx-runtime](https://github.com/wasi-gfx/wasi-gfx-runtime):

```sh
powershell -File scripts/build-clear.ps1
```

Copy `target/clear.component.wasm` to `examples/apps/clear/clear.component.wasm` in wasi-gfx-runtime, then:

```sh
cargo xtask run-demo --name clear
```

The component exports async `start` and imports `wasi:webgpu`, `wasi-gfx:surface`, and `print`.

Build the cube the same way:

```sh
sh scripts/build-cube.sh
```

Copy `target/cube.component.wasm` to `examples/apps/cube/cube.component.wasm` in wasi-gfx-runtime, then `cargo xtask run-demo --name cube`. `moon run src/examples/cube/app` only builds the scene and does not open a window.

The Lambert sample is the same kind of component:

```sh
sh scripts/build-lit.sh
```

Copy `target/lit.component.wasm` to `examples/apps/lit/lit.component.wasm`, then `cargo xtask run-demo --name lit`. `moon run src/examples/lit/app` does not open a window.

The textured sample is a Lambert cube with an `rgba8` checker. Pointer events orbit the camera, and resize reconfigures the swapchain:

```sh
sh scripts/build-textured.sh
```

Copy `target/textured.component.wasm` to `examples/apps/textured/textured.component.wasm`, then `cargo xtask run-demo --name textured`. `moon run src/examples/textured/app` does not open a window.

The Standard sample is a rotating cube with roughness and metalness:

```sh
sh scripts/build-standard.sh
```

Copy `target/standard.component.wasm` to `examples/apps/standard/standard.component.wasm`, then `cargo xtask run-demo --name standard`. `moon run src/examples/standard/app` does not open a window.

Points and lines share one sample. Point size is in pixels and shrinks with distance; lines are one pixel wide:

```sh
sh scripts/build-points.sh
```

Copy `target/points.component.wasm` to `examples/apps/points/points.component.wasm`, then `cargo xtask run-demo --name points`. `moon run src/examples/points/app` does not open a window.

The instanced sample draws three Lambert cubes from one mesh:

```sh
sh scripts/build-instanced.sh
```

Copy `target/instanced.component.wasm` to `examples/apps/instanced/instanced.component.wasm`, then `cargo xtask run-demo --name instanced`. `moon run src/examples/instanced/app` does not open a window.

The shadow sample is a Lambert cube casting onto a plane:

```sh
sh scripts/build-shadow.sh
```

Copy `target/shadow.component.wasm` to `examples/apps/shadow/shadow.component.wasm`, then `cargo xtask run-demo --name shadow`. `moon run src/examples/shadow/app` does not open a window.

The render-target sample draws a Lambert cube into a 256×256 color target, then samples it on a screen quad:

```sh
sh scripts/build-target.sh
```

Copy `target/target.component.wasm` to `examples/apps/target/target.component.wasm`, then `cargo xtask run-demo --name target`. `moon run src/examples/target/app` does not open a window.

The fog sample fades three Lambert cubes into the background:

```sh
sh scripts/build-fog.sh
```

Copy `target/fog.component.wasm` to `examples/apps/fog/fog.component.wasm`, then `cargo xtask run-demo --name fog`. `moon run src/examples/fog/app` does not open a window.

The animation sample plays a two-second clip that bobs and turns a Lambert cube:

```sh
sh scripts/build-animate.sh
```

Copy `target/animate.component.wasm` to `examples/apps/animate/animate.component.wasm`, then `cargo xtask run-demo --name animate`. `moon run src/examples/animate/app` does not open a window.

The glTF sample loads a unit box from an embedded glTF 2.0 document and shades it with `MeshStandardMaterial`:

```sh
sh scripts/build-gltf.sh
```

Copy `target/gltf.component.wasm` to `examples/apps/gltf/gltf.component.wasm`, then `cargo xtask run-demo --name gltf`. `moon run src/examples/gltf/app` does not open a window.

The compute sample moves 65 points along a sine wave. The positions are written by a compute shader:

```sh
sh scripts/build-compute.sh
```

Copy `target/compute.component.wasm` to `examples/apps/compute/compute.component.wasm`, then `cargo xtask run-demo --name compute`. `moon run src/examples/compute/app` does not open a window.

The post sample draws a Lambert cube into a color target, then mixes it halfway to grayscale:

```sh
sh scripts/build-post.sh
```

Copy `target/post.component.wasm` to `examples/apps/post/post.component.wasm`, then `cargo xtask run-demo --name post`. `moon run src/examples/post/app` does not open a window.

The blend sample draws an opaque Lambert cube behind a second cube at opacity 0.5:

```sh
sh scripts/build-blend.sh
```

Copy `target/blend.component.wasm` to `examples/apps/blend/blend.component.wasm`, then `cargo xtask run-demo --name blend`. `moon run src/examples/blend/app` does not open a window.

The tone-mapping sample draws a Lambert cube into a color target, then applies ACES Filmic at exposure 1:

```sh
sh scripts/build-tone.sh
```

Copy `target/tone.component.wasm` to `examples/apps/tone/tone.component.wasm`, then `cargo xtask run-demo --name tone`. `moon run src/examples/tone/app` does not open a window.

The bloom sample draws a Lambert cube into a color target, then adds one full-resolution glow at threshold 0.2:

```sh
sh scripts/build-bloom.sh
```

Copy `target/bloom.component.wasm` to `examples/apps/bloom/bloom.component.wasm`, then `cargo xtask run-demo --name bloom`. `moon run src/examples/bloom/app` does not open a window.

## License

Code in this repository is Apache-2.0. three.js r186 is MIT. Interface text under `wit/` comes from the upstream repositories and stays under their copyright. See [wit/README.md](wit/README.md).
