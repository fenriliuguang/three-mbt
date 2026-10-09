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

core="_build/wasm/debug/build/examples/shadow/component/component.wasm"
mkdir -p target
wasm-tools component embed "$bundle" "$core" --encoding utf16 --world example:example/example -o target/shadow.core.wasm
wasm-tools component new target/shadow.core.wasm -o target/shadow.component.wasm
wasm-tools component wit target/shadow.component.wasm
echo "wrote target/shadow.component.wasm"
