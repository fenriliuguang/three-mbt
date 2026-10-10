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

$core = "_build/wasm/debug/build/examples/bloom/component/component.wasm"
wasm-tools component embed $bundle $core --encoding utf16 --world example:example/example -o target/bloom.core.wasm
wasm-tools component new target/bloom.core.wasm -o target/bloom.component.wasm
wasm-tools component wit target/bloom.component.wasm
Write-Output "wrote target/bloom.component.wasm"
