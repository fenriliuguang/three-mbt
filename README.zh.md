# three-mbt

[English](README.md)

把 [three.js](https://github.com/mrdoob/three.js) **r186** 的 WebGPU 世界迁到 MoonBit。GPU 使用 [wasi:webgpu](https://github.com/WebAssembly/wasi-webgpu)，窗口、帧循环和输入使用 [wasi-gfx](https://github.com/wasi-gfx/wasi-gfx)。

阶段 1 会打开 wasi-gfx 窗口，配置 WebGPU 交换链，并在每一帧清屏。阶段 2 是 CPU 场景图，并用 r186 的数值做对照。阶段 3 绘制一个不受光照的旋转立方体。阶段 4 加上 Lambert 着色、环境光和一盏平行光。范围写在 [docs/PLAN.md](docs/PLAN.md)。

## 检查

```sh
moon check
moon check --target wasm
moon test
```

清屏组件用 [wasi-gfx-runtime](https://github.com/wasi-gfx/wasi-gfx-runtime) 运行：

```sh
powershell -File scripts/build-clear.ps1
```

把 `target/clear.component.wasm` 复制到 wasi-gfx-runtime 的 `examples/apps/clear/clear.component.wasm`，然后：

```sh
cargo xtask run-demo --name clear
```

组件导出异步 `start`，并导入 `wasi:webgpu`、`wasi-gfx:surface` 和 `print`。

立方体用同样的方式构建：

```sh
sh scripts/build-cube.sh
```

把 `target/cube.component.wasm` 复制到 wasi-gfx-runtime 的 `examples/apps/cube/cube.component.wasm`，然后 `cargo xtask run-demo --name cube`。`moon run src/examples/cube/app` 只构建场景，不会打开窗口。

Lambert 样本同样是组件：

```sh
sh scripts/build-lit.sh
```

把 `target/lit.component.wasm` 复制到 `examples/apps/lit/lit.component.wasm`，然后 `cargo xtask run-demo --name lit`。`moon run src/examples/lit/app` 不会打开窗口。

## 许可

本仓库代码使用 Apache-2.0。three.js r186 是 MIT。`wit/` 中的接口文本来自上游仓库，版权归原作者，见 [wit/README.md](wit/README.md)。
