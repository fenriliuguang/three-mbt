# three-mbt

[English](README.md)

把 [three.js](https://github.com/mrdoob/three.js) **r186** 的 WebGPU 世界迁到 MoonBit。GPU 使用 [wasi:webgpu](https://github.com/WebAssembly/wasi-webgpu)，窗口、帧循环和输入使用 [wasi-gfx](https://github.com/wasi-gfx/wasi-gfx)。

阶段 1 会打开 wasi-gfx 窗口，配置 WebGPU 交换链，并在每一帧清屏。阶段 2 是 CPU 场景图，并用 r186 的数值做对照。阶段 3 绘制一个不受光照的旋转立方体。阶段 4 加上 Lambert 着色、环境光和一盏平行光。阶段 5 加上 `rgba8` 纹理，在窗口缩放时重建交换链，并在样本里用指针事件转动相机。阶段 6 加上 `MeshStandardMaterial` 的粗糙度、金属度和平行光。阶段 7 从点、线、实例化、平行光阴影、渲染目标和雾开始。范围写在 [docs/PLAN.md](docs/PLAN.md)。

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

纹理样本是一个带 `rgba8` 棋盘格的 Lambert 立方体。指针事件让相机绕原点转，窗口缩放会重新配置交换链：

```sh
sh scripts/build-textured.sh
```

把 `target/textured.component.wasm` 复制到 `examples/apps/textured/textured.component.wasm`，然后 `cargo xtask run-demo --name textured`。`moon run src/examples/textured/app` 不会打开窗口。

Standard 样本是一个带粗糙度和金属度的旋转立方体：

```sh
sh scripts/build-standard.sh
```

把 `target/standard.component.wasm` 复制到 `examples/apps/standard/standard.component.wasm`，然后 `cargo xtask run-demo --name standard`。`moon run src/examples/standard/app` 不会打开窗口。

点和线在同一个样本里。点的大小按像素计算，并随距离缩小；线宽是 1 像素：

```sh
sh scripts/build-points.sh
```

把 `target/points.component.wasm` 复制到 `examples/apps/points/points.component.wasm`，然后 `cargo xtask run-demo --name points`。`moon run src/examples/points/app` 不会打开窗口。

实例化样本用一个网格画三个 Lambert 立方体：

```sh
sh scripts/build-instanced.sh
```

把 `target/instanced.component.wasm` 复制到 `examples/apps/instanced/instanced.component.wasm`，然后 `cargo xtask run-demo --name instanced`。`moon run src/examples/instanced/app` 不会打开窗口。

阴影样本是一个 Lambert 立方体，把影子投到地面上：

```sh
sh scripts/build-shadow.sh
```

把 `target/shadow.component.wasm` 复制到 `examples/apps/shadow/shadow.component.wasm`，然后 `cargo xtask run-demo --name shadow`。`moon run src/examples/shadow/app` 不会打开窗口。

渲染目标样本先把 Lambert 立方体画进 256×256 的颜色目标，再贴到铺满窗口的四边形上：

```sh
sh scripts/build-target.sh
```

把 `target/target.component.wasm` 复制到 `examples/apps/target/target.component.wasm`，然后 `cargo xtask run-demo --name target`。`moon run src/examples/target/app` 不会打开窗口。

雾样本把三个 Lambert 立方体沿着视线排开，远处混进背景色：

```sh
sh scripts/build-fog.sh
```

把 `target/fog.component.wasm` 复制到 `examples/apps/fog/fog.component.wasm`，然后 `cargo xtask run-demo --name fog`。`moon run src/examples/fog/app` 不会打开窗口。

## 许可

本仓库代码使用 Apache-2.0。three.js r186 是 MIT。`wit/` 中的接口文本来自上游仓库，版权归原作者，见 [wit/README.md](wit/README.md)。
