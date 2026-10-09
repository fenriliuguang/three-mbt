///|
fn main {
  let world = @animate.AnimateScene::new()
  world.step(0.01)
  println(
    "three-mbt animate: scene is ready, the window sample is the wasm component",
  )
}
