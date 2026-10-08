# 钉住的 WIT

[English](README.md)

绑定生成之前，接口文本放在这里，实现固定在这些快照上，不跟着上游 `main` 漂移。

| 路径 | 包 | 上游 | 提交 |
|---|---|---|---|
| `webgpu/` | `wasi:webgpu@0.3.0-rc.2` | https://github.com/WebAssembly/wasi-webgpu | `6a776bada0b66d3dbf9da304a49ff2947ce4e1f8` |
| `surface/surface.wit` | `wasi-gfx:surface@0.2.0` | https://github.com/wasi-gfx/wasi-gfx | `24615bbdf06f5a55ea6506db4596ed24072d3a6e` |
| `surface/surface-webgpu.wit` | 依赖上面两个包 | 同一仓库 | 同一提交 |

取用日期：2026-10-08。

`wasi:webgpu` 的文本由 WASI 规范贡献者以 W3C Community CLA 授权。`wasi-gfx` 该提交没有单独的许可证文件。升级版本时同时改本表和 [docs/PLAN.md](../docs/PLAN.md)。

本目录只收录 `surface`。`wasi-gfx` 的 `frame-buffer` 留在上游仓库。
