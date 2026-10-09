///|
fn main {
  let world = @gltf.GltfScene::new()
  world.spin(0.01)
  println(
    "three-mbt gltf: scene is ready, the window sample is the wasm component",
  )
}
