# three-mbt

MoonBit 移植 three.js r186 的 WebGPU 世界。动手前先读 [docs/PLAN.md](docs/PLAN.md)。已完成、活跃中、待实现分在 `docs/plan/done/`、`docs/plan/active/`、`docs/plan/later/`。当前没有排下一刀。`docs/plan/active/materials.md` 只记录 WebGL 程序路径已经删掉。

## 边界

- 场景图包（`math`、`core`、`cameras`、`scenes`、`objects`、`geometries`、`materials`、`lights`、`textures`、`constants`）不得 import `bindings` 或 `platform`。
- 只有 `platform` 和 `renderer/webgpu` 接触 `wasi:webgpu`。
- 只有应用壳和 `platform` 接触 `wasi-gfx` surface。
- 不实现 WebGL、WebXR、音频。宿主没有 WebGL。不移植 `src/renderers/webgl`、`src/renderers/shaders`、GLSL 前缀或 `WebGLPrograms`。细则见 [.cursor/skills/no-webgl/SKILL.md](.cursor/skills/no-webgl/SKILL.md)。
- `bindings` 里的生成文件不手改。

## 工具

- 包按目录划分，每个目录有一个 `moon.pkg`。模块元数据在根目录 `moon.mod`，`source = "src"`，导入路径不含 `src`。
- 黑盒测试文件以 `_test.mbt` 结尾，白盒测试以 `_wbtest.mbt` 结尾。
- 代码按 `///|` 分块。
- 改完后运行 `moon info && moon fmt`，并查看 `.mbti` 差异。
- 运行 `moon test`。稳定结果用 `assert_eq`。

## 文件划分

实现按 three.js r186 的源文件切开，而不是把一个包堆进一个 `.mbt`。同一个 `moon.pkg` 目录里可以有多个 `.mbt`，不为此新开包。一个上游类或模块对应一个文件；上游本身就是一个长文件时保持一个 `.mbt`。测试跟这个边界走。生成的 `bindings` 和 `interface` 不拆。细则见 [.cursor/skills/source-layout/SKILL.md](.cursor/skills/source-layout/SKILL.md)。

## 上游链接

移植 three.js 的实现文件要标注 tag `r186` 的 GitHub 链接。文件首行是 `// r186:`，公开类型和核心函数的声明前是 `/// r186:`。规则见 [.cursor/skills/upstream-links/SKILL.md](.cursor/skills/upstream-links/SKILL.md)。

## 提交

仓库尚未正式发版。云 Agent 在 `main` 上提交并 `git push origin main`，不建功能分支、不开 Pull Request。步骤见 [.cursor/skills/direct-to-main/SKILL.md](.cursor/skills/direct-to-main/SKILL.md)。

## 定时推进

用户指定截止时间后，没到点就开启下一刀，不判断这一刀能不能在截止前做完。规则见 [.cursor/skills/timed-advance/SKILL.md](.cursor/skills/timed-advance/SKILL.md)。
