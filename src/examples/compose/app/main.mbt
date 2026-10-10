///|
fn main {
  let world = @compose.ComposeScene::new()
  world.spin(0.01)
  println(
    "three-mbt compose: scene is ready, the window sample is the wasm component",
  )
}
