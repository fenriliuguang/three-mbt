# three-mbt

[English](README.md)

把 [three.js](https://github.com/mrdoob/three.js) **r186** 的 WebGPU 世界迁到 MoonBit。GPU 使用 [wasi:webgpu](https://github.com/WebAssembly/wasi-webgpu)，窗口、帧循环和输入使用 [wasi-gfx](https://github.com/wasi-gfx/wasi-gfx)。

当前是阶段 0：模块、包目录和计划已经就位。场景图与渲染器随后实现。迁移范围、阶段和目录约定写在 [docs/PLAN.md](docs/PLAN.md)。

## 检查

```sh
moon check
moon test
moon run src/examples/clear
moon run src/examples/cube
```

`examples/clear` 与 `examples/cube` 现在只打印占位信息。

## 许可

本仓库代码使用 Apache-2.0。three.js r186 是 MIT。`wit/` 中的接口文本来自上游仓库，版权归原作者，见 [wit/README.md](wit/README.md)。
