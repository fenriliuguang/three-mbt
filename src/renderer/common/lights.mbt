// r186: `Lighting` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Lighting.js#L14 ; `test` https://github.com/mrdoob/three.js/blob/r186/src/core/Layers.js#L100

///|
using @core {type LightState}

///|
/// 这一帧要采样的平行光阴影。矩阵把世界坐标变到阴影贴图的 `uv` 和深度。
/// r186: `DirectionalLightShadow` https://github.com/mrdoob/three.js/blob/r186/src/lights/DirectionalLightShadow.js#L9
pub(all) struct ShadowFrame {
  camera : @core.Object3D
  matrix : @math.Matrix4
  bias : Double
  normal_bias : Double
  radius : Double
  map_size : Int
}

///|
/// 这一帧的环境光、第一盏平行光、第一盏点光、第一盏聚光和第一盏半球光。颜色已经乘上强度。
/// r186: `Lighting` https://github.com/mrdoob/three.js/blob/r186/src/renderers/common/Lighting.js#L14
pub(all) struct LightFrame {
  ambient : @math.Vector3
  color : @math.Vector3
  direction : @math.Vector3
  shadow : ShadowFrame?
  point_color : @math.Vector3
  point_position : @math.Vector3
  point_distance : Double
  point_decay : Double
  point_enabled : Double
  spot_color : @math.Vector3
  spot_position : @math.Vector3
  spot_direction : @math.Vector3
  spot_distance : Double
  spot_decay : Double
  spot_cone_cos : Double
  spot_penumbra_cos : Double
  spot_enabled : Double
  hemisphere_sky : @math.Vector3
  hemisphere_ground : @math.Vector3
  hemisphere_direction : @math.Vector3
  hemisphere_enabled : Double
}

///|
priv struct LightAccum {
  ambient : @math.Vector3
  color : @math.Vector3
  direction : @math.Vector3
  mut found_directional : Bool
  mut shadow : ShadowFrame?
  point_color : @math.Vector3
  point_position : @math.Vector3
  mut point_distance : Double
  mut point_decay : Double
  mut found_point : Bool
  spot_color : @math.Vector3
  spot_position : @math.Vector3
  spot_direction : @math.Vector3
  mut spot_distance : Double
  mut spot_decay : Double
  mut spot_cone_cos : Double
  mut spot_penumbra_cos : Double
  mut found_spot : Bool
  hemisphere_sky : @math.Vector3
  hemisphere_ground : @math.Vector3
  hemisphere_direction : @math.Vector3
  mut found_hemisphere : Bool
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
/// 遍历可见节点。多盏平行光、点光、聚光、半球光都只保留第一盏。传入相机时，层掩码不相交的灯跳过。
/// 点光、聚光和半球光不产生阴影贴图。聚光方向从目标指向灯。半球光方向是世界坐标位置，长度为 0 时保持零向量。
/// r186: `getDistanceAttenuation` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/lights_pars_begin.glsl.js#L56
/// r186: `getSpotLightInfo` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/lights_pars_begin.glsl.js#L163
/// r186: `coneCos` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLLights.js#L367
pub fn collect_lights(
  root : @core.Object3D,
  camera? : @core.Object3D,
) -> LightFrame {
  let accum = {
    ambient: @math.Vector3::new(),
    color: @math.Vector3::new(),
    direction: @math.Vector3::new(y=1.0),
    found_directional: false,
    shadow: None,
    point_color: @math.Vector3::new(),
    point_position: @math.Vector3::new(),
    point_distance: 0.0,
    point_decay: 2.0,
    found_point: false,
    spot_color: @math.Vector3::new(),
    spot_position: @math.Vector3::new(),
    spot_direction: @math.Vector3::new(y=1.0),
    spot_distance: 0.0,
    spot_decay: 2.0,
    spot_cone_cos: 1.0,
    spot_penumbra_cos: 1.0,
    found_spot: false,
    hemisphere_sky: @math.Vector3::new(),
    hemisphere_ground: @math.Vector3::new(),
    hemisphere_direction: @math.Vector3::new(),
    found_hemisphere: false,
  }
  root.traverse_visible(fn(node : @core.Object3D) {
    if on_camera_layer(node, camera) {
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
            @core.Point =>
              if !accum.found_point {
                accum.found_point = true
                ignore(accum.point_color.copy(scaled_color(light)))
                ignore(node.get_world_position(accum.point_position))
                accum.point_distance = light.distance
                accum.point_decay = light.decay
              }
            @core.Spot =>
              if !accum.found_spot {
                accum.found_spot = true
                ignore(accum.spot_color.copy(scaled_color(light)))
                ignore(node.get_world_position(accum.spot_position))
                ignore(accum.spot_direction.copy(light_direction(node, light)))
                accum.spot_distance = light.distance
                accum.spot_decay = light.decay
                accum.spot_cone_cos = @std.cos(light.angle)
                accum.spot_penumbra_cos = @std.cos(
                  light.angle * (1.0 - light.penumbra),
                )
              }
            @core.Hemisphere =>
              if !accum.found_hemisphere {
                accum.found_hemisphere = true
                ignore(accum.hemisphere_sky.copy(scaled_color(light)))
                ignore(accum.hemisphere_ground.copy(scaled_ground(light)))
                ignore(
                  accum.hemisphere_direction.copy(hemisphere_direction(node)),
                )
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
    point_color: accum.point_color,
    point_position: accum.point_position,
    point_distance: accum.point_distance,
    point_decay: accum.point_decay,
    point_enabled: if accum.found_point {
      1.0
    } else {
      0.0
    },
    spot_color: accum.spot_color,
    spot_position: accum.spot_position,
    spot_direction: accum.spot_direction,
    spot_distance: accum.spot_distance,
    spot_decay: accum.spot_decay,
    spot_cone_cos: accum.spot_cone_cos,
    spot_penumbra_cos: accum.spot_penumbra_cos,
    spot_enabled: if accum.found_spot {
      1.0
    } else {
      0.0
    },
    hemisphere_sky: accum.hemisphere_sky,
    hemisphere_ground: accum.hemisphere_ground,
    hemisphere_direction: accum.hemisphere_direction,
    hemisphere_enabled: if accum.found_hemisphere {
      1.0
    } else {
      0.0
    },
  }
}

///|
fn scaled_ground(light : LightState) -> @math.Vector3 {
  @math.Vector3::new(
    x=light.ground_color.r * light.intensity,
    y=light.ground_color.g * light.intensity,
    z=light.ground_color.b * light.intensity,
  )
}

///|
/// 半球光的方向是世界坐标位置。长度为 0 时不归一化。
/// r186: `lightDirectionNode` https://github.com/mrdoob/three.js/blob/r186/src/nodes/lighting/HemisphereLightNode.js#L44
fn hemisphere_direction(node : @core.Object3D) -> @math.Vector3 {
  let position = @math.Vector3::new()
  ignore(node.get_world_position(position))
  if position.length() == 0.0 {
    position
  } else {
    ignore(position.normalize())
    position
  }
}
