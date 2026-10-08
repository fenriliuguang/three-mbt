///|
fn main {
  let world = @textured.TexturedScene::new()
  world.pointer_down(0.0, 0.0)
  world.pointer_move(10.0, 0.0)
  world.spin(0.01)
  println(
    "three-mbt textured: scene is ready, the window sample is the wasm component",
  )
}
