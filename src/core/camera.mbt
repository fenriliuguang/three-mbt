// r186: `Camera` https://github.com/mrdoob/three.js/blob/r186/src/cameras/Camera.js#L18

///|
/// 透视相机在一块更大画面里的子矩形。`enabled` 为假时投影忽略它。
/// r186: `view` https://github.com/mrdoob/three.js/blob/r186/src/cameras/PerspectiveCamera.js#L111
pub(all) struct ViewOffset {
  mut enabled : Bool
  mut full_width : Double
  mut full_height : Double
  mut offset_x : Double
  mut offset_y : Double
  mut width : Double
  mut height : Double
}

///|
/// 相机的投影和视图逆矩阵。透视与正交共用这一组字段。
/// r186: `Camera` https://github.com/mrdoob/three.js/blob/r186/src/cameras/Camera.js#L18
pub(all) struct CameraState {
  projection : @math.Matrix4
  projection_inverse : @math.Matrix4
  matrix_world_inverse : @math.Matrix4
  mut fov : Double
  mut aspect : Double
  mut zoom : Double
  mut near : Double
  mut far : Double
  mut left : Double
  mut right : Double
  mut top : Double
  mut bottom : Double
  mut film_gauge : Double
  mut film_offset : Double
  mut view : ViewOffset?
  mut coordinate_system : @constants.CoordinateSystem
  mut reversed_depth : Bool
  kind : ProjectionKind
}

///|
pub fn CameraState::perspective(
  fov : Double,
  aspect : Double,
  near : Double,
  far : Double,
) -> CameraState {
  {
    projection: @math.Matrix4::new(),
    projection_inverse: @math.Matrix4::new(),
    matrix_world_inverse: @math.Matrix4::new(),
    fov,
    aspect,
    zoom: 1.0,
    near,
    far,
    left: -1.0,
    right: 1.0,
    top: 1.0,
    bottom: -1.0,
    film_gauge: 35.0,
    film_offset: 0.0,
    view: None,
    coordinate_system: @constants.WebGPU,
    reversed_depth: false,
    kind: Perspective,
  }
}

///|
pub fn CameraState::orthographic(
  left : Double,
  right : Double,
  top : Double,
  bottom : Double,
  near : Double,
  far : Double,
) -> CameraState {
  {
    projection: @math.Matrix4::new(),
    projection_inverse: @math.Matrix4::new(),
    matrix_world_inverse: @math.Matrix4::new(),
    fov: 50.0,
    aspect: 1.0,
    zoom: 1.0,
    near,
    far,
    left,
    right,
    top,
    bottom,
    film_gauge: 35.0,
    film_offset: 0.0,
    view: None,
    coordinate_system: @constants.WebGPU,
    reversed_depth: false,
    kind: Orthographic,
  }
}

///|
/// 胶片成像宽度。横构图等于 `film_gauge`，竖构图按宽高比缩小。
/// r186: `getFilmWidth` https://github.com/mrdoob/three.js/blob/r186/src/cameras/PerspectiveCamera.js#L206
pub fn CameraState::film_width(self : CameraState) -> Double {
  self.film_gauge * self.aspect.min(1.0)
}

///|
/// 胶片成像高度。竖构图等于 `film_gauge`，横构图按宽高比缩小。
/// r186: `getFilmHeight` https://github.com/mrdoob/three.js/blob/r186/src/cameras/PerspectiveCamera.js#L219
pub fn CameraState::film_height(self : CameraState) -> Double {
  self.film_gauge / self.aspect.max(1.0)
}

///|
/// r186: `getFocalLength` https://github.com/mrdoob/three.js/blob/r186/src/cameras/PerspectiveCamera.js#L180
pub fn CameraState::focal_length(self : CameraState) -> Double {
  let slope = @std.tan(@math.deg_to_rad(0.5 * self.fov))
  0.5 * self.film_height() / slope
}

///|
/// r186: `setFocalLength` https://github.com/mrdoob/three.js/blob/r186/src/cameras/PerspectiveCamera.js#L164
pub fn CameraState::set_focal_length(
  self : CameraState,
  focal_length : Double,
) -> Unit {
  let slope = 0.5 * self.film_height() / focal_length
  self.fov = @math.rad_to_deg(2.0 * @std.atan(slope))
  self.update_projection()
}

///|
/// 写入子矩形并重算投影。调用方决定要不要改 `aspect`。
pub fn CameraState::write_view(
  self : CameraState,
  full_width : Double,
  full_height : Double,
  offset_x : Double,
  offset_y : Double,
  width : Double,
  height : Double,
) -> Unit {
  self.view = Some({
    enabled: true,
    full_width,
    full_height,
    offset_x,
    offset_y,
    width,
    height,
  })
  self.update_projection()
}

///|
/// 关掉子矩形并重算投影。没有偏移时什么也不做。
pub fn CameraState::clear_view(self : CameraState) -> Unit {
  match self.view {
    None => ()
    Some(view) => {
      self.view = Some({
        enabled: false,
        full_width: view.full_width,
        full_height: view.full_height,
        offset_x: view.offset_x,
        offset_y: view.offset_y,
        width: view.width,
        height: view.height,
      })
      self.update_projection()
    }
  }
}

///|
/// r186: `getEffectiveFOV` https://github.com/mrdoob/three.js/blob/r186/src/cameras/PerspectiveCamera.js#L193
pub fn CameraState::effective_fov(self : CameraState) -> Double {
  let slope = @std.tan(@math.deg_to_rad(0.5 * self.fov)) / self.zoom
  @math.rad_to_deg(2.0 * @std.atan(slope))
}

///|
/// 按 r186 `PerspectiveCamera.updateProjectionMatrix` / `OrthographicCamera.updateProjectionMatrix` 重算投影。
/// 透视和正交都会吃 `view` 偏移。正交不改 `aspect`。
pub fn CameraState::update_projection(self : CameraState) -> Unit {
  match self.kind {
    Perspective => {
      let mut top = self.near *
        @std.tan(@math.deg_to_rad(0.5 * self.fov)) /
        self.zoom
      let mut height = 2.0 * top
      let mut width = self.aspect * height
      let mut left = -0.5 * width
      match self.view {
        Some(view) =>
          if view.enabled {
            left = left + view.offset_x * width / view.full_width
            top = top - view.offset_y * height / view.full_height
            width = width * view.width / view.full_width
            height = height * view.height / view.full_height
          }
        None => ()
      }
      if self.film_offset != 0.0 {
        left = left + self.near * self.film_offset / self.film_width()
      }
      ignore(
        self.projection.make_perspective(
          left,
          left + width,
          top,
          top - height,
          self.near,
          self.far,
          coordinate_system=self.coordinate_system,
          reversed_depth=self.reversed_depth,
        ),
      )
    }
    Orthographic => {
      let dx = (self.right - self.left) / (2.0 * self.zoom)
      let dy = (self.top - self.bottom) / (2.0 * self.zoom)
      let cx = (self.right + self.left) / 2.0
      let cy = (self.top + self.bottom) / 2.0
      let mut left = cx - dx
      let mut right = cx + dx
      let mut top = cy + dy
      let mut bottom = cy - dy
      match self.view {
        Some(view) =>
          if view.enabled {
            let scale_w = (self.right - self.left) / view.full_width / self.zoom
            let scale_h = (self.top - self.bottom) /
              view.full_height /
              self.zoom
            left = left + scale_w * view.offset_x
            right = left + scale_w * view.width
            top = top - scale_h * view.offset_y
            bottom = top - scale_h * view.height
          }
        None => ()
      }
      ignore(
        self.projection.make_orthographic(
          left,
          right,
          top,
          bottom,
          self.near,
          self.far,
          coordinate_system=self.coordinate_system,
          reversed_depth=self.reversed_depth,
        ),
      )
    }
  }
  ignore(self.projection_inverse.copy(self.projection).invert())
}
