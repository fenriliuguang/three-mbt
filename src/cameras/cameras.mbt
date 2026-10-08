///|
using @core {type Object3D, type CameraState}

///|
/// 透视相机。投影默认使用 WebGPU 坐标系，近平面深度为 0。
pub(all) struct PerspectiveCamera {
  node : Object3D
}

///|
pub fn PerspectiveCamera::new(
  fov? : Double = 50.0,
  aspect? : Double = 1.0,
  near? : Double = 0.1,
  far? : Double = 2000.0,
) -> PerspectiveCamera {
  let node = Object3D::new(kind=@core.PerspectiveCamera)
  let camera = CameraState::perspective(fov, aspect, near, far)
  camera.update_projection()
  node.camera = Some(camera)
  { node, }
}

///|
pub impl @core.AsNode for PerspectiveCamera with fn to_node(self) {
  self.node
}

///|
pub extend PerspectiveCamera with @core.AsNode::{to_node}

///|
pub fn PerspectiveCamera::update_projection(self : PerspectiveCamera) -> Unit {
  match self.node.camera {
    None => ()
    Some(camera) => camera.update_projection()
  }
}

///|
pub fn PerspectiveCamera::set_fov(
  self : PerspectiveCamera,
  fov : Double,
) -> Unit {
  match self.node.camera {
    None => ()
    Some(camera) => {
      camera.fov = fov
      camera.update_projection()
    }
  }
}

///|
pub fn PerspectiveCamera::set_aspect(
  self : PerspectiveCamera,
  aspect : Double,
) -> Unit {
  match self.node.camera {
    None => ()
    Some(camera) => {
      camera.aspect = aspect
      camera.update_projection()
    }
  }
}

///|
/// 正交相机。`left` / `right` / `top` / `bottom` 是相机空间里的视锥边界。
pub(all) struct OrthographicCamera {
  node : Object3D
}

///|
pub fn OrthographicCamera::new(
  left? : Double = -1.0,
  right? : Double = 1.0,
  top? : Double = 1.0,
  bottom? : Double = -1.0,
  near? : Double = 0.1,
  far? : Double = 2000.0,
) -> OrthographicCamera {
  let node = Object3D::new(kind=@core.OrthographicCamera)
  let camera = CameraState::orthographic(left, right, top, bottom, near, far)
  camera.update_projection()
  node.camera = Some(camera)
  { node, }
}

///|
pub impl @core.AsNode for OrthographicCamera with fn to_node(self) {
  self.node
}

///|
pub extend OrthographicCamera with @core.AsNode::{to_node}

///|
pub fn OrthographicCamera::update_projection(self : OrthographicCamera) -> Unit {
  match self.node.camera {
    None => ()
    Some(camera) => camera.update_projection()
  }
}

///|
pub fn OrthographicCamera::set_zoom(
  self : OrthographicCamera,
  zoom : Double,
) -> Unit {
  match self.node.camera {
    None => ()
    Some(camera) => {
      camera.zoom = zoom
      camera.update_projection()
    }
  }
}
