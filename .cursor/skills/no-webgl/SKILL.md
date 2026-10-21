---
name: no-webgl
description: >
  本仓库只有 wasi:webgpu，不移植 WebGL 或 GLSL。
  Use when porting three.js, adding a renderer, shader, material parameter, WebGLProgram, WebGLPrograms, ShaderChunk, ShaderLib, GLSL prefix, or a file named webgl.
---

# 不移植 WebGL

宿主提供 `wasi:webgpu`，没有 WebGL 上下文，也没有 GLSL 编译器。迁移只走 WebGPU 和 WGSL。已经写过的 WebGL 程序路径要删掉，不要补回来。

## 不写

- `WebGLRenderer`、`WebGLBackend`、`forceWebGL`、`webgl-fallback`。
- `src/renderers/webgl/`，包括 `WebGLProgram`、`WebGLPrograms`、`WebGLShaderCache`、`WebGLMaterials`、`WebGLLights`、`WebGLCapabilities`。
- `src/renderers/shaders/`，包括 `ShaderChunk`、`ShaderLib`、GLSL 前缀、`#define USE_*`、`resolveIncludes`、`replaceLightNums`、`unrollLoops`。
- 文件名带 `webgl_` 的实现或测试。
- 只为 `getParameters` 服务的 `program_*` 读取函数，以及 `prefixed_vertex_shader`、`prefixed_fragment_shader`。

场景图上的材质字段可以留下。`ShaderMaterial` 和 `RawShaderMaterial` 可以保存它们自己的着色器字符串，渲染器不编译这两串。不要把这两串扩展成着色器块库，也不要给它们生成 GLSL 前缀。

## 可以留下

- `renderer/webgpu` 和 `nodes` 里的 WGSL。
- 公式来自某个 GLSL 块、实现却是 WGSL 或 CPU 的代码。`r186` 链接可以指向那份块，用来标明数字从哪来。不要把那份块移植过来。
- `CoordinateSystem::WebGL` 和 `WEBGL_COORDINATE_SYSTEM`（2000）。这是深度 NDC 为 \[-1, 1\] 的常量，投影和视锥用它分支。它不是后端。不要写一个选中它来绘制的渲染器。

## 计划

`docs/plan/active/materials.md` 不再排 GLSL 前缀。定时推进如果读到 WebGL、GLSL 前缀、`WebGLPrograms` 或 `ShaderLib`，不要开工。下一刀必须是 WebGPU 路径上的工作。
