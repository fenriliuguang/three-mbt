///|
pub async fn start(_background_group : @async-core.TaskGroup[Unit]) -> Unit {
  match @platform.SurfaceTarget::open() {
    None => @host.print("three-mbt animate: failed to open a WebGPU surface")
    Some(target) => {
      let renderer = @renderer.WebGPURenderer::new(target)
      let world = @animate.AnimateScene::new()
      let frames = target.window().on_frame()
      while true {
        match frames.read(1) {
          None => break
          Some(_) => {
            world.step(0.01)
            renderer.render(world.scene, world.camera.node)
          }
        }
      }
    }
  }
}
