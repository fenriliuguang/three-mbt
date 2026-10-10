---
name: upstream-links
description: >
  移植 three.js 时，在实现文件上标注 tag r186 的 GitHub 链接。
  Use when porting three.js, adding a type or core function, editing implementation comments, or writing an upstream three.js link for r186.
---

# 上游链接

本仓库是 three.js tag `r186` 的语义移植。每个移植文件都要能从注释跳回上游声明。可检索的标记是 `r186:`。

## 写在哪里

实现用的 `.mbt`（`src/` 下的库代码）在文件第一行写：

```
// r186: `ClassName` https://github.com/mrdoob/three.js/blob/r186/<path>#L<line>
```

这一行放在第一个 `///|` 之前，用 `//`，不要写成该段的文档注释。一个文件对应多个上游文件时，用 ` ; ` 隔开。

映射到上游类的公开类型，以及行为来自具名上游函数、但从类型名看不出来的核心函数，在声明前加一行：

```
/// r186: `Name` https://github.com/mrdoob/three.js/blob/r186/<path>#L<line>
```

放在该 `///|` 段已有的 `///` 说明之后、声明之前。已有中文说明保留，不要改写成只剩链接。

类型上已经有链接时，普通方法不再各写一条。`Vector3::add`、`copy` 这类运算跟着类型走。`compose`、`decompose`、`lookAt`、`makePerspective`、`makeOrthographic`、`slerp`、`setFromEuler`、`setFromQuaternion`、`setHex`、`applyMatrix4`、`updateMatrix`、`updateMatrixWorld`、`traverse`、`dispatchEvent`、`updateProjectionMatrix`、`painterSortStable`、`render`、`compute`、`setRenderTarget`、`parse`、`D_GGX` 这类有自己上游名字的函数要单独标。

## URL

- 固定 tag `r186`，形如 `https://github.com/mrdoob/three.js/blob/r186/<path>#L<line>`。
- `#L` 指向上游声明所在行。不链 `main` 或 `dev`。
- 不编造文件或行号。行号从该 tag 的源文件数出来。
- 没有同名符号时，注释里写明，并链到最近的真实上游。灰度通道没有同名类，输出路径是 `PostProcessing`，全屏形状是 `ShaderPass`。计算波公式是本地的，存储类型对应 `StorageBufferAttribute`，派发对应 `Renderer.compute`。`SurfaceTarget` 对应 `CanvasTarget`，窗口是 wasi-gfx，不是 DOM canvas。`Fog` 的因子来自 `src/nodes/fog/Fog.js` 的 `rangeFogFactor` 和 `densityFogFactor`，类型本身仍是 `src/scenes/Fog.js` 与 `FogExp2.js`。

## 不标注

- `src/interface/**` 和 `src/bindings` 里的生成文件。
- `*_test.mbt`、`*_wbtest.mbt`。
- `src/examples/**` 和 ffi 胶水。示例只有在逐行对照某一份 three.js example 时才加链接。

## 检查

只改注释时仍运行 `moon fmt`，并确认 `moon check` 与 `moon check --target wasm` 的错误数没有增加。不要为了注释去手改 `.mbti`。
