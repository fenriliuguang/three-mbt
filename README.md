# three-mbt

[中文](README.zh.md)

A MoonBit migration of the [three.js](https://github.com/mrdoob/three.js) **r186** WebGPU world. GPU access goes through [wasi:webgpu](https://github.com/WebAssembly/wasi-webgpu). Windows, the frame loop, and input go through [wasi-gfx](https://github.com/wasi-gfx/wasi-gfx).

This is phase 0: the module, package layout, and plan are in place. Scene-graph and renderer work comes later. Scope, phases, and directory rules are in [docs/PLAN.md](docs/PLAN.md).

## Check

```sh
moon check
moon test
moon run src/examples/clear
moon run src/examples/cube
```

`examples/clear` and `examples/cube` print placeholders.

## License

Code in this repository is Apache-2.0. three.js r186 is MIT. Interface text under `wit/` comes from the upstream repositories and stays under their copyright. See [wit/README.md](wit/README.md).
