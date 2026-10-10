// r186: `Three.WebGPU` https://github.com/mrdoob/three.js/blob/r186/src/Three.WebGPU.js#L1

///|
/// 本模块对齐的 three.js 修订版本。
pub let upstream_revision : String = "r186"

///|
pub using @constants {
  BACK_SIDE,
  DOUBLE_SIDE,
  FRONT_SIDE,
  WEBGL_COORDINATE_SYSTEM,
  CLAMP_TO_EDGE_WRAPPING,
  INTERPOLATE_DISCRETE,
  INTERPOLATE_LINEAR,
  INTERPOLATE_SMOOTH,
  LINEAR_FILTER,
  LINEAR_MIPMAP_LINEAR_FILTER,
  LINEAR_MIPMAP_NEAREST_FILTER,
  LOOP_ONCE,
  LOOP_PING_PONG,
  LOOP_REPEAT,
  MIRRORED_REPEAT_WRAPPING,
  NEAREST_FILTER,
  NEAREST_MIPMAP_LINEAR_FILTER,
  NEAREST_MIPMAP_NEAREST_FILTER,
  ACES_FILMIC_TONE_MAPPING,
  AGX_TONE_MAPPING,
  CINEON_TONE_MAPPING,
  CUSTOM_TONE_MAPPING,
  LINEAR_TONE_MAPPING,
  NEUTRAL_TONE_MAPPING,
  NO_TONE_MAPPING,
  REINHARD_TONE_MAPPING,
  REPEAT_WRAPPING,
  WEBGPU_COORDINATE_SYSTEM,
  type CoordinateSystem,
  type Interpolation,
  type LoopMode,
  type Shading,
  type ToneMapping,
  type Side,
  type TextureFilter,
  type Wrapping,
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
  type PrimitiveKind,
  type Object3D,
  type ObjectEvent,
}

///|
pub using @cameras {type OrthographicCamera, type PerspectiveCamera}

///|
pub using @compute {type StoragePositions, wave_position, workgroup_count}

///|
pub using @post {
  bloom_mix,
  grayscale,
  high_pass,
  luminance,
  tone_map,
  type BloomPass,
  type ComposerEffect,
  type ComposerPass,
  type EffectComposer,
  type GrayscalePass,
  type ToneMappingPass,
}

///|
pub using @scenes {type Fog, type FogKind, type Scene}

///|
pub using @animation {
  type AnimationAction,
  type AnimationClip,
  type AnimationMixer,
  type KeyframeTrack,
}

///|
pub using @gltf {parse, type GltfError}

///|
pub using @objects {
  type Group,
  type InstancedMesh,
  type Line,
  type LineSegments,
  type Mesh,
  type Points,
}

///|
pub using @geometries {type BoxGeometry, type BoxParameters}

///|
pub using @materials {
  type Material,
  type MaterialKind,
  type MeshBasicMaterial,
  type LineBasicMaterial,
  type MeshLambertMaterial,
  type MeshStandardMaterial,
  type PointsMaterial,
}

///|
pub using @lights {type AmbientLight, type DirectionalLight}

///|
pub using @textures {type RenderTarget, type Texture}
