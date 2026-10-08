From phase 2 onward, put matrix, decomposition, and projection numbers exported from three.js r186 here. Package `*_test.mbt` files assert the same numbers. This directory is not a MoonBit package, and tests embed the values so they can run on wasm-gc without a filesystem.

`r186-world.json` was exported from `three@0.186.0` (`Matrix4.compose` / `decompose`, WebGPU and WebGL projection, a parent-child world matrix, `Object3D.lookAt`, `BoxGeometry`, and `Color.setHex`).
