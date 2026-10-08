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

$core = "_build/wasm/debug/build/gen/gen.wasm"
wasm-tools component embed $bundle $core --encoding utf16 --world example:example/example -o target/clear.core.wasm
wasm-tools component new target/clear.core.wasm -o target/clear.component.wasm
wasm-tools component wit target/clear.component.wasm
Write-Output "wrote target/clear.component.wasm"
