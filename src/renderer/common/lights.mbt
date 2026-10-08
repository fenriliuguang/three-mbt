///|
using @core {type LightState}

///|
/// 这一帧的环境光和第一盏平行光。颜色已经乘上强度。
pub(all) struct LightFrame {
  ambient : @math.Vector3
  color : @math.Vector3
  direction : @math.Vector3
}

///|
priv struct LightAccum {
  ambient : @math.Vector3
  color : @math.Vector3
  direction : @math.Vector3
  mut found_directional : Bool
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
            }
        }
    }
  })
  { ambient: accum.ambient, color: accum.color, direction: accum.direction, }
}
