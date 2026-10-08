# three-mbt

MoonBit 移植 three.js r186 的 WebGPU 世界。动手前先读 [docs/PLAN.md](docs/PLAN.md)。

## 边界

- 场景图包（`math`、`core`、`cameras`、`scenes`、`objects`、`geometries`、`materials`、`lights`、`textures`、`constants`）不得 import `bindings` 或 `platform`。
- 只有 `platform` 和 `renderer/webgpu` 接触 `wasi:webgpu`。
- 只有应用壳和 `platform` 接触 `wasi-gfx` surface。
- 不实现 WebGL、WebXR、音频。
- `bindings` 里的生成文件不手改。

## 工具

- 包按目录划分，每个目录有一个 `moon.pkg`。模块元数据在根目录 `moon.mod`，`source = "src"`，导入路径不含 `src`。
- 黑盒测试文件以 `_test.mbt` 结尾，白盒测试以 `_wbtest.mbt` 结尾。
- 代码按 `///|` 分块。
- 改完后运行 `moon info && moon fmt`，并查看 `.mbti` 差异。
- 运行 `moon test`。稳定结果用 `assert_eq`。
