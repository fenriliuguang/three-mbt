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

core="_build/wasm/debug/build/examples/standard/component/component.wasm"
mkdir -p target
wasm-tools component embed "$bundle" "$core" --encoding utf16 --world example:example/example -o target/standard.core.wasm
wasm-tools component new target/standard.core.wasm -o target/standard.component.wasm
wasm-tools component wit target/standard.component.wasm
echo "wrote target/standard.component.wasm"
