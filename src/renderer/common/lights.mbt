///|
using @core {type LightState}

///|
/// 这一帧要采样的平行光阴影。矩阵把世界坐标变到阴影贴图的 `uv` 和深度。
pub(all) struct ShadowFrame {
  camera : @core.Object3D
  matrix : @math.Matrix4
  bias : Double
  normal_bias : Double
  radius : Double
  map_size : Int
}

///|
/// 这一帧的环境光和第一盏平行光。颜色已经乘上强度。
pub(all) struct LightFrame {
  ambient : @math.Vector3
  color : @math.Vector3
  direction : @math.Vector3
  shadow : ShadowFrame?
}

///|
priv struct LightAccum {
  ambient : @math.Vector3
  color : @math.Vector3
  direction : @math.Vector3
  mut found_directional : Bool
  mut shadow : ShadowFrame?
}

///|
fn scaled_color(light : LightState) -> @math.Vector3 {
  @math.Vector3::new(
    x=light.color.r * light.intensity,
    y=light.color.g * light.intensity,
    z=light.color.b * light.intensity,
  )
}

///|
fn place_shadow(
  node : @core.Object3D,
  light : LightState,
  shadow : @core.ShadowState,
) -> ShadowFrame {
  let from = @math.Vector3::new()
  ignore(node.get_world_position(from))
  let toward = @math.Vector3::new()
  match light.target {
    None => ()
    Some(target) => ignore(target.get_world_position(toward))
  }
  ignore(shadow.camera.position.copy(from))
  shadow.camera.look_at(toward.x, toward.y, toward.z)
  shadow.camera.update_matrix_world(force=true)
  let (projection, view) = match shadow.camera.camera {
    None => (@math.Matrix4::new(), @math.Matrix4::new())
    Some(state) => {
      state.update_projection()
      (state.projection, state.matrix_world_inverse)
    }
  }
  let map_size = if shadow.map_size < 1 { 1 } else { shadow.map_size }
  {
    camera: shadow.camera,
    matrix: shadow_matrix(projection, view),
    bias: shadow.bias,
    normal_bias: shadow.normal_bias,
    radius: shadow.radius,
    map_size,
  }
}

///|
fn light_direction(node : @core.Object3D, light : LightState) -> @math.Vector3 {
  let from = @math.Vector3::new()
  ignore(node.get_world_position(from))
  let toward = @math.Vector3::new()
  match light.target {
    None => ()
    Some(target) => ignore(target.get_world_position(toward))
  }
  ignore(from.sub(toward))
  if from.length() == 0.0 {
    ignore(from.set(0.0, 1.0, 0.0))
  } else {
    ignore(from.normalize())
  }
  from
}

///|
/// 遍历可见节点。多盏平行光只保留第一盏。
pub fn collect_lights(root : @core.Object3D) -> LightFrame {
  let accum = {
    ambient: @math.Vector3::new(),
    color: @math.Vector3::new(),
    direction: @math.Vector3::new(y=1.0),
    found_directional: false,
    shadow: None,
  }
  root.traverse_visible(fn(node : @core.Object3D) {
    match node.light {
      None => ()
      Some(light) =>
        match light.kind {
          @core.Ambient => ignore(accum.ambient.add(scaled_color(light)))
          @core.Directional =>
            if !accum.found_directional {
              accum.found_directional = true
              ignore(accum.color.copy(scaled_color(light)))
              ignore(accum.direction.copy(light_direction(node, light)))
              if node.cast_shadow {
                match light.shadow {
                  None => ()
                  Some(shadow) =>
                    accum.shadow = Some(place_shadow(node, light, shadow))
                }
              }
            }
        }
    }
  })
  {
    ambient: accum.ambient,
    color: accum.color,
    direction: accum.direction,
    shadow: accum.shadow,
  }
}
