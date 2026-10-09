$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

moon build --target wasm

$bundle = "target/wit-bundle"
if (Test-Path $bundle) {
  Remove-Item -Recurse -Force $bundle
}
New-Item -ItemType Directory -Force -Path "$bundle/deps" | Out-Null
Copy-Item "wit/guest/world.wit" "$bundle/world.wit"
Copy-Item -Recurse "wit/webgpu" "$bundle/deps/webgpu"
Copy-Item -Recurse "wit/surface" "$bundle/deps/surface"

$core = "_build/wasm/debug/build/examples/gltf/component/component.wasm"
wasm-tools component embed $bundle $core --encoding utf16 --world example:example/example -o target/gltf.core.wasm
wasm-tools component new target/gltf.core.wasm -o target/gltf.component.wasm
wasm-tools component wit target/gltf.component.wasm
Write-Output "wrote target/gltf.component.wasm"
