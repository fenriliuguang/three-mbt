// r186: `OrthographicCamera` https://github.com/mrdoob/three.js/blob/r186/src/cameras/OrthographicCamera.js#L17

///|
/// 正交相机。`left` / `right` / `top` / `bottom` 是相机空间里的视锥边界。
/// `set_view_offset` 在这块视锥里取子矩形，不改 `aspect`。`set_left`、`set_right`、`set_top`、`set_bottom` 改视锥边界。`set_near` 和 `set_far` 只改深度项。
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
pub fn OrthographicCamera::set_left(
  self : OrthographicCamera,
  left : Double,
) -> Unit {
  match self.node.camera {
    None => ()
    Some(camera) => {
      camera.left = left
      camera.update_projection()
    }
  }
}

///|
pub fn OrthographicCamera::set_right(
  self : OrthographicCamera,
  right : Double,
) -> Unit {
  match self.node.camera {
    None => ()
    Some(camera) => {
      camera.right = right
      camera.update_projection()
    }
  }
}

///|
pub fn OrthographicCamera::set_top(
  self : OrthographicCamera,
  top : Double,
) -> Unit {
  match self.node.camera {
    None => ()
    Some(camera) => {
      camera.top = top
      camera.update_projection()
    }
  }
}

///|
pub fn OrthographicCamera::set_bottom(
  self : OrthographicCamera,
  bottom : Double,
) -> Unit {
  match self.node.camera {
    None => ()
    Some(camera) => {
      camera.bottom = bottom
      camera.update_projection()
    }
  }
}

///|
pub fn OrthographicCamera::set_near(
  self : OrthographicCamera,
  near : Double,
) -> Unit {
  match self.node.camera {
    None => ()
    Some(camera) => {
      camera.near = near
      camera.update_projection()
    }
  }
}

///|
pub fn OrthographicCamera::set_far(
  self : OrthographicCamera,
  far : Double,
) -> Unit {
  match self.node.camera {
    None => ()
    Some(camera) => {
      camera.far = far
      camera.update_projection()
    }
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

///|
/// 在正交视锥里取一块子矩形。不改 `aspect`。
/// r186: `setViewOffset` https://github.com/mrdoob/three.js/blob/r186/src/cameras/OrthographicCamera.js#L148
pub fn OrthographicCamera::set_view_offset(
  self : OrthographicCamera,
  full_width : Double,
  full_height : Double,
  offset_x : Double,
  offset_y : Double,
  width : Double,
  height : Double,
) -> Unit {
  match self.node.camera {
    None => ()
    Some(camera) =>
      camera.write_view(
        full_width, full_height, offset_x, offset_y, width, height,
      )
  }
}

///|
/// 关掉子矩形偏移并重算投影。
/// r186: `clearViewOffset` https://github.com/mrdoob/three.js/blob/r186/src/cameras/OrthographicCamera.js#L179
pub fn OrthographicCamera::clear_view_offset(self : OrthographicCamera) -> Unit {
  match self.node.camera {
    None => ()
    Some(camera) => camera.clear_view()
  }
}

