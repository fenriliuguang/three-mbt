///|
fn read_pointers(
  chunk : FixedArray[@surface.PointerEvent],
  handle : (@surface.PointerEvent) -> Unit,
) -> Unit {
  let mut index = 0
  while index < chunk.length() {
    handle(chunk[index])
    index = index + 1
  }
}

///|
pub async fn start(background_group : @async-core.TaskGroup[Unit]) -> Unit {
  match @platform.SurfaceTarget::open() {
    None => @host.print("three-mbt textured: failed to open a WebGPU surface")
    Some(target) => {
      let renderer = @renderer.WebGPURenderer::new(target)
      let world = @textured.TexturedScene::new()
      let window = target.window()
      background_group.spawn_bg(async fn() {
        let events = window.on_resize()
        while true {
          match events.read(1) {
            None => break
            Some(_) => renderer.invalidate_swapchain()
          }
        }
      })
      background_group.spawn_bg(async fn() {
        let events = window.on_pointer_down()
        while true {
          match events.read(1) {
            None => break
            Some(chunk) =>
              read_pointers(chunk, fn(event) {
                world.pointer_down(event.x, event.y)
              })
          }
        }
      })
      background_group.spawn_bg(async fn() {
        let events = window.on_pointer_up()
        while true {
          match events.read(1) {
            None => break
            Some(_) => world.pointer_up()
          }
        }
      })
      background_group.spawn_bg(async fn() {
        let events = window.on_pointer_move()
        while true {
          match events.read(1) {
            None => break
            Some(chunk) =>
              read_pointers(chunk, fn(event) {
                world.pointer_move(event.x, event.y)
              })
          }
        }
      })
      let frames = window.on_frame()
      while true {
        match frames.read(1) {
          None => break
          Some(_) => {
            world.spin(0.01)
            renderer.render(world.scene, world.camera.node)
          }
        }
      }
    }
  }
}
