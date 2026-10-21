// r186: `ArrayCamera` https://github.com/mrdoob/three.js/blob/r186/src/cameras/ArrayCamera.js#L14

///|
/// 一组透视子相机。自身也是透视相机，默认视场 `50`、宽高比 `1`、近 `0.1`、远 `2000`。没传入的子相机列表是空数组。
/// r186: `ArrayCamera` https://github.com/mrdoob/three.js/blob/r186/src/cameras/ArrayCamera.js#L14
/// r186: `cameras` https://github.com/mrdoob/three.js/blob/r186/src/cameras/ArrayCamera.js#L48
pub(all) struct ArrayCamera {
  node : Object3D
  cameras : Array[PerspectiveCamera]
}

///|
pub fn ArrayCamera::new(
  cameras? : Array[PerspectiveCamera],
) -> ArrayCamera {
  let node = Object3D::new(kind=@core.PerspectiveCamera)
  let camera = CameraState::perspective(50.0, 1.0, 0.1, 2000.0)
  camera.update_projection()
  node.camera = Some(camera)
  let cameras = match cameras {
    None => []
    Some(cameras) => cameras
  }
  { node, cameras, }
}

///|
pub impl @core.AsNode for ArrayCamera with fn to_node(self) {
  self.node
}

///|
pub extend ArrayCamera with @core.AsNode::{to_node}

///|
/// 为每台子相机缓存一个视锥。投影矩阵乘上世界矩阵的逆。已有的多余视锥留着，只把 `count` 改成子相机数量。没有相机会中止。
/// r186: `setFromArrayCamera` https://github.com/mrdoob/three.js/blob/r186/src/math/FrustumArray.js#L55
pub fn set_from_array_camera(
  frustums : @math.FrustumArray,
  array_camera : ArrayCamera,
) -> @math.FrustumArray {
  let cameras = array_camera.cameras
  for i in 0..<cameras.length() {
    match cameras[i].node.camera {
      None => abort("FrustumArray.set_from_array_camera requires a camera")
      Some(state) => {
        let projected = @math.Matrix4::new().multiply_matrices(
          state.projection,
          state.matrix_world_inverse,
        )
        if i >= frustums.frustums.length() {
          frustums.frustums.push(@math.Frustum::new())
        }
        ignore(
          frustums.frustums[i].set_from_projection_matrix(
            projected,
            coordinate_system=state.coordinate_system,
            reversed_depth=state.reversed_depth,
          ),
        )
      }
    }
  }
  frustums.count = cameras.length()
  frustums
}
