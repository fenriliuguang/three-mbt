///|
pub async fn start(_background_group : @async-core.TaskGroup[Unit]) -> Unit {
  match @platform.SurfaceTarget::open() {
    None => @host.print("three-mbt clear: failed to open a WebGPU surface")
    Some(target) => target.run_clear()
  }
}
