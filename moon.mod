// Module layout: https://docs.moonbitlang.com/en/latest/toolchain/moon/module.html
// Migration plan: docs/PLAN.md

name = "fenriliuguang/three-mbt"

version = "0.1.0"

readme = "README.md"

repository = "https://github.com/fenriliuguang/three-mbt"

license = "Apache-2.0"

keywords = [ "threejs", "webgpu", "wasi", "graphics" ]

preferred_target = "wasm-gc"

supported_targets = "+wasm-gc+native"

source = "src"

description = "MoonBit migration of the three.js r186 WebGPU world, on wasi:webgpu and wasi-gfx."
