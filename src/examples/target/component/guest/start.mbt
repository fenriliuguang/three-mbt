///|
pub async fn start(_background_group : @async-core.TaskGroup[Unit]) -> Unit {
  match @platform.SurfaceTarget::open() {
    None => @host.print("three-mbt target: failed to open a WebGPU surface")
    Some(target) => {
      let renderer = @renderer.WebGPURenderer::new(target)
      let world = @target.TargetScene::new()
      let frames = target.window().on_frame()
      while true {
        match frames.read(1) {
          None => break
          Some(_) => {
            world.spin(0.01)
            renderer.set_render_target(Some(world.target))
            renderer.render(world.offscreen, world.off_camera.node)
            renderer.set_render_target(None)
            renderer.render(world.screen, world.screen_camera.node)
          }
        }
      }
    }
  }
}
