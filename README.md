# three-mbt

[中文](README.zh.md)

A MoonBit migration of the [three.js](https://github.com/mrdoob/three.js) **r186** WebGPU world. GPU access goes through [wasi:webgpu](https://github.com/WebAssembly/wasi-webgpu). Windows, the frame loop, and input go through [wasi-gfx](https://github.com/wasi-gfx/wasi-gfx).

Phase 1 opens a wasi-gfx surface, configures a WebGPU swapchain, and clears it on each frame. Phase 2 is the CPU scene graph: math, objects, cameras, `BoxGeometry`, a basic material, and lights, checked against r186 fixtures. The rotating cube is phase 3. Scope is in [docs/PLAN.md](docs/PLAN.md).

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

The component exports async `start` and imports `wasi:webgpu`, `wasi-gfx:surface`, and `print`. `moon run src/examples/cube` is still a placeholder.

## License

Code in this repository is Apache-2.0. three.js r186 is MIT. Interface text under `wit/` comes from the upstream repositories and stays under their copyright. See [wit/README.md](wit/README.md).
