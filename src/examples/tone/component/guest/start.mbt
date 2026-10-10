///|
pub async fn start(_background_group : @async-core.TaskGroup[Unit]) -> Unit {
  match @platform.SurfaceTarget::open() {
    None => @host.print("three-mbt tone: failed to open a WebGPU surface")
    Some(target) => {
      let renderer = @renderer.WebGPURenderer::new(target)
      let world = @tone.ToneScene::new()
      let frames = target.window().on_frame()
      while true {
        match frames.read(1) {
          None => break
          Some(_) => {
            world.spin(0.01)
            renderer.set_render_target(Some(world.target))
            renderer.render(world.scene, world.camera.node)
            renderer.set_render_target(None)
            renderer.tone_map(world.target, world.pass)
          }
        }
      }
    }
  }
}
