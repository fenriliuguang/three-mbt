// r186: `CanvasTarget` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/CanvasTarget.js#L11 。窗口改接到 wasi-gfx surface，不走 DOM canvas

///|
/// A window whose swapchain is configured for a WebGPU device.
/// r186: `CanvasTarget` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/CanvasTarget.js#L11
pub struct SurfaceTarget {
  device : @webgpu.GpuDevice
  window : @surface.Surface
  context : @canvas.Context
}

///|
/// Requests an adapter and a device, then configures the surface swapchain.
pub async fn SurfaceTarget::open() -> SurfaceTarget? {
  let gpu = @webgpu.get_gpu()
  match gpu.request_adapter(None) {
    None => None
    Some(adapter) =>
      match adapter.request_device(None) {
        Err(_) => None
        Ok(device) => {
          let window = @surface.Surface::surface({ height: None, width: None, })
          let context = @canvas.Context::context(window)
          let format = gpu.get_preferred_canvas_format()
          context.configure({
            device,
            format,
            usage: None,
            view_formats: None,
            color_space: None,
            tone_mapping: None,
            alpha_mode: None,
          })
          Some({ device, window, context, })
        }
      }
  }
}

///|
pub fn SurfaceTarget::device(self : SurfaceTarget) -> @webgpu.GpuDevice {
  self.device
}

///|
pub fn SurfaceTarget::window(self : SurfaceTarget) -> @surface.Surface {
  self.window
}

///|
pub fn SurfaceTarget::context(self : SurfaceTarget) -> @canvas.Context {
  self.context
}

///|
/// Clears the current swapchain texture and presents it.
pub fn SurfaceTarget::clear(
  self : SurfaceTarget,
  r : Double,
  g : Double,
  b : Double,
  a : Double,
) -> Unit {
  let texture = self.context.get_current_texture()
  let view = texture.create_view(None)
  let encoder = self.device.create_command_encoder(None)
  let pass = encoder.begin_render_pass({
    color_attachments: [
      Some({
        view,
        depth_slice: None,
        resolve_target: None,
        clear_value: Some({ r, g, b, a, }),
        load_op: @webgpu.CLEAR,
        store_op: @webgpu.STORE,
      }),
    ],
    depth_stencil_attachment: None,
    occlusion_query_set: None,
    timestamp_writes: None,
    max_draw_count: None,
    label: Some("clear"),
  })
  pass.end()
  self.device.queue().submit([encoder.finish(None)])
  self.context.present()
}

///|
/// Clears to a dark blue on every frame until the frame stream closes.
pub async fn SurfaceTarget::run_clear(self : SurfaceTarget) -> Unit {
  let frames = self.window.on_frame()
  while true {
    match frames.read(1) {
      None => break
      Some(_) => self.clear(0.05, 0.1, 0.2, 1.0)
    }
  }
}
