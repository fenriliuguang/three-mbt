///|
/// 本模块对齐的 three.js 修订版本。
pub let upstream_revision : String = "r186"

///|
pub using @constants {
  BACK_SIDE,
  DOUBLE_SIDE,
  FRONT_SIDE,
  WEBGL_COORDINATE_SYSTEM,
  WEBGPU_COORDINATE_SYSTEM,
  type CoordinateSystem,
  type Shading,
  type Side,
}

///|
pub using @math {
  deg_to_rad,
  linear_to_srgb,
  rad_to_deg,
  srgb_to_linear,
  type Box3,
  type Color,
  type Euler,
  type EulerOrder,
  type Frustum,
  type Matrix3,
  type Matrix4,
  type Plane,
  type Quaternion,
  type Sphere,
  type Vector2,
  type Vector3,
  type Vector4,
}

///|
pub using @core {
  trait AsNode,
  type BufferAttribute,
  type BufferGeometry,
  type GeometryGroup,
  type Layers,
  type NodeKind,
  type Object3D,
  type ObjectEvent,
}

///|
pub using @cameras {type OrthographicCamera, type PerspectiveCamera}

///|
pub using @scenes {type Scene}

///|
pub using @objects {type Group, type Mesh}

///|
pub using @geometries {type BoxGeometry, type BoxParameters}

///|
pub using @materials {
  type Material,
  type MaterialKind,
  type MeshBasicMaterial,
  type MeshLambertMaterial,
}

///|
pub using @lights {type AmbientLight, type DirectionalLight}
