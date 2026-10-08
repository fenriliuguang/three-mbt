# 钉住的 WIT

[English](README.md)

绑定生成之前，接口文本放在这里，实现固定在这些快照上，不跟着上游 `main` 漂移。

| 路径 | 包 | 上游 | 提交 |
|---|---|---|---|
| `webgpu/` | `wasi:webgpu@0.3.0-rc.2` | https://github.com/WebAssembly/wasi-webgpu | `6a776bada0b66d3dbf9da304a49ff2947ce4e1f8` |
| `surface/surface.wit` | `wasi-gfx:surface@0.2.0` | https://github.com/wasi-gfx/wasi-gfx | `24615bbdf06f5a55ea6506db4596ed24072d3a6e` |
| `surface/surface-webgpu.wit` | 依赖上面两个包 | 同一仓库 | 同一提交 |

取用日期：2026-10-08。

`surface/surface-webgpu.wit` 里的 `webgpu-imports` 世界同时导入 `surface`，与 wasi-gfx-runtime 使用的世界一致。`guest/world.wit` 是本仓库的组件世界（`example:example/example`）：它包含上述导入，另导入 `print`，并导出异步 `start`。

重新生成 MoonBit 绑定：

```sh
wit-bindgen moonbit wit/webgpu wit/surface wit/guest --out-dir src --project-name fenriliuguang/three-mbt --ignore-module-file --derive-show --derive-eq --derive-error --world example:example/example
```

`src/gen/world/example/start.mbt` 以及它对 `platform` 的导入是手写的。重新生成时保留这两处。

`wasi:webgpu` 的文本由 WASI 规范贡献者以 W3C Community CLA 授权。`wasi-gfx` 该提交没有单独的许可证文件。升级版本时同时改本表和 [docs/PLAN.md](../docs/PLAN.md)。

本目录只收录 `surface`。`wasi-gfx` 的 `frame-buffer` 留在上游仓库。
