///|
fn main {
  let world = @instanced.InstancedScene::new()
  world.spin(0.01)
  println(
    "three-mbt instanced: scene is ready, the window sample is the wasm component",
  )
}
