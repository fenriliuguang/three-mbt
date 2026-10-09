#!/bin/sh
set -eu
cd "$(dirname "$0")/.."

moon build --target wasm

bundle="target/wit-bundle"
rm -rf "$bundle"
mkdir -p "$bundle/deps"
cp wit/guest/world.wit "$bundle/world.wit"
cp -R wit/webgpu "$bundle/deps/webgpu"
cp -R wit/surface "$bundle/deps/surface"

core="_build/wasm/debug/build/examples/fog/component/component.wasm"
mkdir -p target
wasm-tools component embed "$bundle" "$core" --encoding utf16 --world example:example/example -o target/fog.core.wasm
wasm-tools component new target/fog.core.wasm -o target/fog.component.wasm
wasm-tools component wit target/fog.component.wasm
echo "wrote target/fog.component.wasm"
