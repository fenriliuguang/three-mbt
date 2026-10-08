///|
fn main {
  let world = @standard.StandardScene::new()
  world.spin(0.01)
  println(
    "three-mbt standard: scene is ready, the window sample is the wasm component",
  )
}
