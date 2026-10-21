---
name: source-layout
description: >
  实现文件按 three.js r186 的源文件边界拆开，一个上游类或模块对应一个 .mbt。
  Use when adding a type, splitting a long .mbt, deciding which file a function belongs in, or reviewing file size.
---

# 源文件划分

three.js 一个类一个文件。这里同样：一个上游源文件对应同一个包目录里的一个 `.mbt`。包仍然是一个目录、一个 `moon.pkg`，导入路径不因为拆文件而改变。

## 怎么拆

- 文件名用上游类名的 snake_case。`MeshStandardMaterial` 写成 `mesh_standard_material.mbt`，`AnimationMixer` 写成 `animation_mixer.mbt`。
- 不建 `webgl_` 文件。WebGL 和 GLSL 不移植，见 [no-webgl](../no-webgl/SKILL.md)。
- 公开类型、它的构造和只服务于这个类型的方法放进这个文件。同一包的其它文件可以直接调用，不需要把符号再导出一次。
- 几个类型共用的私有函数跟它的上游文件走。上游没有单独文件时，放在第一个调用方那个文件里。
- `using` 在整个包里声明一次。拆出去的文件直接用这些短名字，不要再写一份，重复声明会报类型重复。
- 文件第一行仍是 `// r186:`，只列这个文件对应的上游文件，用 ` ; ` 隔开。不要把整个包的链接复制到每一份文件上。

## 不要拆

- 上游自己就是一个文件时，保持一个 `.mbt`。`GLTFLoader.js`、`BufferGeometry.js`、`Object3D.js`、`constants.js`、`Renderer.js` 都属于这一类。
- 不要按函数条数把同一个类再切开。
- 不要为了变短而新开包。场景图包的依赖方向不变。
- `bindings` 和 `interface` 里的生成文件不手改，也不拆。
- 测试、示例、ffi 不加 `r186` 链接。

## 测试

黑盒测试 `*_test.mbt`、白盒测试 `*_wbtest.mbt` 跟实现的上游边界走。一个类型一份测试。测两个类型的用例放在标题里先出现的那个类型的测试文件里。`math/world_test.mbt` 和 `core/world_test.mbt` 仍是早先的合集；改到其中某个类型时，把该类型的用例拆出去，不要再往里追加。

## 已经按这个边界分开的例子

`math` 和 `core` 本来就是一个类一个文件。`materials`、`objects`、`lights`、`cameras`、`scenes`、`textures`、`animation`、`post` 也按上游文件分开。`renderer/webgpu` 里，渲染器、后端资源、管线工具、后处理通道分属 `WebGPURenderer.js`、`WebGPUBackend.js`、`WebGPUPipelineUtils.js` 和后处理示例。
