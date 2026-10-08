# Pinned WIT

[中文](README.zh.md)

Interface text lives here until bindings are generated, so the implementation stays on these snapshots instead of drifting with upstream `main`.

| Path | Package | Upstream | Commit |
|---|---|---|---|
| `webgpu/` | `wasi:webgpu@0.3.0-rc.2` | https://github.com/WebAssembly/wasi-webgpu | `6a776bada0b66d3dbf9da304a49ff2947ce4e1f8` |
| `surface/surface.wit` | `wasi-gfx:surface@0.2.0` | https://github.com/wasi-gfx/wasi-gfx | `24615bbdf06f5a55ea6506db4596ed24072d3a6e` |
| `surface/surface-webgpu.wit` | depends on the two packages above | same repository | same commit |

Fetched on 2026-10-08.

`wasi:webgpu` text is licensed by the Contributors to the WASI Specification under the W3C Community CLA. That `wasi-gfx` commit has no separate license file. When bumping a version, update this table and [docs/PLAN.md](../docs/PLAN.md) together.

This tree vendors `surface` only. `wasi-gfx`'s `frame-buffer` stays in the upstream repository.
