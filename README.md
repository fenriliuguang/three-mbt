# three-mbt

[中文](README.zh.md)

A MoonBit migration of the [three.js](https://github.com/mrdoob/three.js) **r186** WebGPU world. GPU access goes through [wasi:webgpu](https://github.com/WebAssembly/wasi-webgpu). Windows, the frame loop, and input go through [wasi-gfx](https://github.com/wasi-gfx/wasi-gfx).

Phase 1 opens a wasi-gfx surface, configures a WebGPU swapchain, and clears it on each frame. Phase 2 is the CPU scene graph, checked against r186 fixtures. Phase 3 draws an unlit rotating cube. Phase 4 adds Lambert shading with ambient light and one directional light. Phase 5 adds `rgba8` textures, rebuilds the swapchain on resize, and orbits the camera from pointer events in the sample. Phase 6 adds `MeshStandardMaterial` with roughness, metalness, and the directional light. Phase 7 has started with points and lines. Scope is in [docs/PLAN.md](docs/PLAN.md).

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

## License

Code in this repository is Apache-2.0. three.js r186 is MIT. Interface text under `wit/` comes from the upstream repositories and stays under their copyright. See [wit/README.md](wit/README.md).
