# Pinned WIT

[中文](README.zh.md)

Interface text lives here until bindings are generated, so the implementation stays on these snapshots instead of drifting with upstream `main`.

| Path | Package | Upstream | Commit |
|---|---|---|---|
| `webgpu/` | `wasi:webgpu@0.3.0-rc.2` | https://github.com/WebAssembly/wasi-webgpu | `6a776bada0b66d3dbf9da304a49ff2947ce4e1f8` |
| `surface/surface.wit` | `wasi-gfx:surface@0.2.0` | https://github.com/wasi-gfx/wasi-gfx | `24615bbdf06f5a55ea6506db4596ed24072d3a6e` |
| `surface/surface-webgpu.wit` | depends on the two packages above | same repository | same commit |

Fetched on 2026-10-08.

`surface/surface-webgpu.wit`'s `webgpu-imports` world also imports `surface`, matching the world used by wasi-gfx-runtime. `guest/world.wit` is this repository's component world (`example:example/example`): it includes those imports, imports `print`, and exports async `start`.

Regenerate the MoonBit bindings with:

```sh
wit-bindgen moonbit wit/webgpu wit/surface wit/guest --out-dir src --project-name fenriliuguang/three-mbt --ignore-module-file --derive-show --derive-eq --derive-error --world example:example/example
```

`src/gen/world/example/start.mbt` and its `platform` import are hand-written. Keep them across regeneration.

`wasi:webgpu` text is licensed by the Contributors to the WASI Specification under the W3C Community CLA. That `wasi-gfx` commit has no separate license file. When bumping a version, update this table and [docs/PLAN.md](../docs/PLAN.md) together.

This tree vendors `surface` only. `wasi-gfx`'s `frame-buffer` stays in the upstream repository.
