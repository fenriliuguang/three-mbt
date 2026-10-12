// r186: `PerspectiveCamera` https://github.com/mrdoob/three.js/blob/r186/src/cameras/PerspectiveCamera.js#L23 ; `OrthographicCamera` https://github.com/mrdoob/three.js/blob/r186/src/cameras/OrthographicCamera.js#L17

///|
using @core {type Object3D, type CameraState}

///|
/// 透视相机。投影默认使用 WebGPU 坐标系，近平面深度为 0。
/// `zoom` 默认 1，除在垂直视场上。`film_offset` 默认 0，非 0 时按胶片宽度把视锥水平平移。两个设置都会重算投影。
/// `film_gauge` 默认 35。横构图的胶片宽度等于它，高度按宽高比缩小；竖构图相反。`set_focal_length` 用胶片高度改 `fov` 并重算投影。
/// r186: `PerspectiveCamera` https://github.com/mrdoob/three.js/blob/r186/src/cameras/PerspectiveCamera.js#L23 ; `zoom` https://github.com/mrdoob/three.js/blob/r186/src/cameras/PerspectiveCamera.js#L63 ; `filmOffset` https://github.com/mrdoob/three.js/blob/r186/src/cameras/PerspectiveCamera.js#L129
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
/// r186: `updateProjectionMatrix` https://github.com/mrdoob/three.js/blob/r186/src/cameras/PerspectiveCamera.js#L131
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
pub fn PerspectiveCamera::set_zoom(
  self : PerspectiveCamera,
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

///|
pub fn PerspectiveCamera::set_film_offset(
  self : PerspectiveCamera,
  film_offset : Double,
) -> Unit {
  match self.node.camera {
    None => ()
    Some(camera) => {
      camera.film_offset = film_offset
      camera.update_projection()
    }
  }
}

///|
/// r186: `getFilmWidth` https://github.com/mrdoob/three.js/blob/r186/src/cameras/PerspectiveCamera.js#L206
pub fn PerspectiveCamera::film_width(self : PerspectiveCamera) -> Double {
  match self.node.camera {
    None => 0.0
    Some(camera) => camera.film_width()
  }
}

///|
/// r186: `getFilmHeight` https://github.com/mrdoob/three.js/blob/r186/src/cameras/PerspectiveCamera.js#L219
pub fn PerspectiveCamera::film_height(self : PerspectiveCamera) -> Double {
  match self.node.camera {
    None => 0.0
    Some(camera) => camera.film_height()
  }
}

///|
/// r186: `getFocalLength` https://github.com/mrdoob/three.js/blob/r186/src/cameras/PerspectiveCamera.js#L180
pub fn PerspectiveCamera::focal_length(self : PerspectiveCamera) -> Double {
  match self.node.camera {
    None => 0.0
    Some(camera) => camera.focal_length()
  }
}

///|
/// r186: `setFocalLength` https://github.com/mrdoob/three.js/blob/r186/src/cameras/PerspectiveCamera.js#L164
pub fn PerspectiveCamera::set_focal_length(
  self : PerspectiveCamera,
  focal_length : Double,
) -> Unit {
  match self.node.camera {
    None => ()
    Some(camera) => camera.set_focal_length(focal_length)
  }
}

///|
/// r186: `getEffectiveFOV` https://github.com/mrdoob/three.js/blob/r186/src/cameras/PerspectiveCamera.js#L193
pub fn PerspectiveCamera::effective_fov(self : PerspectiveCamera) -> Double {
  match self.node.camera {
    None => 0.0
    Some(camera) => camera.effective_fov()
  }
}

///|
/// 正交相机。`left` / `right` / `top` / `bottom` 是相机空间里的视锥边界。
/// r186: `OrthographicCamera` https://github.com/mrdoob/three.js/blob/r186/src/cameras/OrthographicCamera.js#L17
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
/// r186: `updateProjectionMatrix` https://github.com/mrdoob/three.js/blob/r186/src/cameras/OrthographicCamera.js#L195
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
