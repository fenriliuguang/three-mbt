///|
fn main {
  let world = @compute.ComputeScene::new()
  world.step(0.01)
  println(
    "three-mbt compute: scene is ready, the window sample is the wasm component",
  )
}
