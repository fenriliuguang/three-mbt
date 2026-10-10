// r186: `AnimationMixer` https://github.com/mrdoob/three.js/blob/r186/src/animation/AnimationMixer.js#L16

///|
using @core {type Object3D}

///|
using @constants {type Interpolation, type LoopMode}

///|
/// 一条关键帧。`value_size` 为 3 时按向量线性插值，为 4 时按四元数 slerp。
/// 时间必须非递减。三次样条不在这一阶段。
/// r186: `KeyframeTrack` https://github.com/mrdoob/three.js/blob/r186/src/animation/KeyframeTrack.js#L19
pub(all) struct KeyframeTrack {
  name : String
  times : Array[Double]
  values : Array[Double]
  value_size : Int
  mut interpolation : Interpolation
}

///|
fn check_track(
  times : Array[Double],
  values : Array[Double],
  size : Int,
) -> Unit {
  if times.length() == 0 || values.length() != times.length() * size {
    abort("keyframe track size does not match its times")
  }
  let mut previous = times[0]
  for index in 1..<times.length() {
    if times[index] < previous {
      abort("keyframe times must be sorted")
    }
    previous = times[index]
  }
}

///|
/// 向量轨道，对应 `.position` 或 `.scale`。每个关键帧 3 个数。
/// r186: `VectorKeyframeTrack` https://github.com/mrdoob/three.js/blob/r186/src/animation/tracks/VectorKeyframeTrack.js#L8
pub fn KeyframeTrack::vector(
  name : String,
  times : Array[Double],
  values : Array[Double],
) -> KeyframeTrack {
  check_track(times, values, 3)
  { name, times, values, value_size: 3, interpolation: Linear, }
}

///|
/// 四元数轨道，对应 `.quaternion`。每个关键帧 4 个数，顺序是 `xyzw`。
/// r186: `QuaternionKeyframeTrack` https://github.com/mrdoob/three.js/blob/r186/src/animation/tracks/QuaternionKeyframeTrack.js#L9
pub fn KeyframeTrack::quaternion(
  name : String,
  times : Array[Double],
  values : Array[Double],
) -> KeyframeTrack {
  check_track(times, values, 4)
  { name, times, values, value_size: 4, interpolation: Linear, }
}

///|
/// 一组轨道。`duration` 小于 0 时取最后一帧的时间。
/// r186: `AnimationClip` https://github.com/mrdoob/three.js/blob/r186/src/animation/AnimationClip.js#L15
pub(all) struct AnimationClip {
  name : String
  tracks : Array[KeyframeTrack]
  mut duration : Double
}

///|
pub fn AnimationClip::new(
  name : String,
  tracks : Array[KeyframeTrack],
  duration? : Double = -1.0,
) -> AnimationClip {
  let mut span = duration
  if span < 0.0 {
    span = 0.0
    for track in tracks {
      let last = track.times[track.times.length() - 1]
      if last > span {
        span = last
      }
    }
  }
  { name, tracks, duration: span, }
}

///|
priv enum Property {
  Position
  Quaternion
  Scale
}

///|
struct PoseBinding {
  node : Object3D
  property : Property
  x : Double
  y : Double
  z : Double
  w : Double
}

///|
priv struct Contrib {
  node : Object3D
  property : Property
  x : Double
  y : Double
  z : Double
  w : Double
  weight : Double
}

///|
/// 一个片段在混合器里的播放状态。`repetitions` 小于 0 表示无限循环。
/// 默认循环播放，权重 1。调用 `play` 之后才会写入场景。
/// r186: `AnimationAction` https://github.com/mrdoob/three.js/blob/r186/src/animation/AnimationAction.js#L7
pub(all) struct AnimationAction {
  clip : AnimationClip
  mut time : Double
  mut time_scale : Double
  mut weight : Double
  mut loop_mode : LoopMode
  mut repetitions : Int
  mut clamp_when_finished : Bool
  mut enabled : Bool
  mut paused : Bool
  mut playing : Bool
}

///|
fn AnimationAction::make(clip : AnimationClip) -> AnimationAction {
  {
    clip,
    time: 0.0,
    time_scale: 1.0,
    weight: 1.0,
    loop_mode: Repeat,
    repetitions: -1,
    clamp_when_finished: false,
    enabled: true,
    paused: false,
    playing: false,
  }
}

///|
/// r186: `play` https://github.com/mrdoob/three.js/blob/r186/src/animation/AnimationAction.js#L176
pub fn AnimationAction::play(self : AnimationAction) -> Unit {
  self.enabled = true
  self.paused = false
  self.playing = true
}

///|
/// 停止并回到片段时间 0。下一次 `update` 会把被动过的属性还原。
pub fn AnimationAction::stop(self : AnimationAction) -> Unit {
  self.playing = false
  self.paused = false
  self.enabled = true
  self.time = 0.0
}

///|
pub fn AnimationAction::set_loop(
  self : AnimationAction,
  mode : LoopMode,
  repetitions? : Int = -1,
) -> Unit {
  self.loop_mode = mode
  self.repetitions = repetitions
}

///|
pub fn AnimationAction::set_clamp(
  self : AnimationAction,
  enabled : Bool,
) -> Unit {
  self.clamp_when_finished = enabled
}

///|
pub fn AnimationAction::set_time_scale(
  self : AnimationAction,
  scale : Double,
) -> Unit {
  self.time_scale = scale
}

///|
/// 把片段写到 `root` 及其具名子节点上。
/// r186: `AnimationMixer` https://github.com/mrdoob/three.js/blob/r186/src/animation/AnimationMixer.js#L16
pub struct AnimationMixer {
  root : Object3D
  mut time : Double
  mut time_scale : Double
  actions : Array[AnimationAction]
  bindings : Array[PoseBinding]
}

///|
pub fn AnimationMixer::new(root : Object3D) -> AnimationMixer {
  { root, time: 0.0, time_scale: 1.0, actions: [], bindings: [], }
}

///|
pub fn AnimationMixer::set_time_scale(
  self : AnimationMixer,
  scale : Double,
) -> Unit {
  self.time_scale = scale
}

///|
/// 同一个片段再次调用会返回已经创建的动作。
/// r186: `clipAction` https://github.com/mrdoob/three.js/blob/r186/src/animation/AnimationMixer.js#L557
pub fn AnimationMixer::clip_action(
  self : AnimationMixer,
  clip : AnimationClip,
) -> AnimationAction {
  for action in self.actions {
    if physical_equal(action.clip, clip) {
      return action
    }
  }
  let action = AnimationAction::make(clip)
  self.actions.push(action)
  action
}

///|
/// r186: `update` https://github.com/mrdoob/three.js/blob/r186/src/animation/AnimationMixer.js#L676
pub fn AnimationMixer::update(self : AnimationMixer, delta : Double) -> Unit {
  let step = delta * self.time_scale
  self.time = self.time + step
  let sampling = []
  for action in self.actions {
    if action.playing && action.enabled {
      if !action.paused {
        advance(action, step * action.time_scale)
      }
      sampling.push(action)
    }
  }
  let contribs = []
  for action in sampling {
    for track in action.clip.tracks {
      match resolve(self.root, track.name) {
        None => ()
        Some((node, property)) => {
          ensure_binding(self, node, property)
          let (x, y, z, w) = sample_track(track, clip_time(action))
          contribs.push({ node, property, x, y, z, w, weight: action.weight, })
        }
      }
    }
  }
  for binding in self.bindings {
    apply_binding(binding, contribs)
  }
}

///|
fn finish(action : AnimationAction) -> Unit {
  if action.clamp_when_finished {
    action.paused = true
  } else {
    action.enabled = false
  }
}

///|
fn wrap_time(time : Double, duration : Double) -> Double {
  if duration <= 0.0 {
    return 0.0
  }
  let mut wrapped = time - duration * @std.floor(time / duration)
  if wrapped < 0.0 {
    wrapped = wrapped + duration
  }
  if wrapped >= duration {
    wrapped = 0.0
  }
  wrapped
}

///|
fn advance(action : AnimationAction, delta : Double) -> Unit {
  let duration = action.clip.duration
  if duration <= 0.0 {
    action.time = 0.0
    return
  }
  let time = action.time + delta
  match action.loop_mode {
    Once =>
      if time >= duration {
        action.time = duration
        finish(action)
      } else if time < 0.0 {
        action.time = 0.0
        finish(action)
      } else {
        action.time = time
      }
    Repeat =>
      if action.repetitions >= 0 {
        let limit = duration * action.repetitions.to_double()
        if time >= limit {
          action.time = duration
          finish(action)
        } else if time < 0.0 {
          action.time = 0.0
          finish(action)
        } else {
          action.time = wrap_time(time, duration)
        }
      } else {
        action.time = wrap_time(time, duration)
      }
    PingPong => action.time = time
  }
}

///|
fn pingpong_time(time : Double, duration : Double) -> Double {
  let cycle = duration * 2.0
  let wrapped = wrap_time(time, cycle)
  if wrapped <= duration {
    wrapped
  } else {
    cycle - wrapped
  }
}

///|
fn clip_time(action : AnimationAction) -> Double {
  match action.loop_mode {
    PingPong => pingpong_time(action.time, action.clip.duration)
    _ => action.time
  }
}

///|
fn read_key(
  track : KeyframeTrack,
  index : Int,
) -> (Double, Double, Double, Double) {
  let base = index * track.value_size
  let x = track.values[base]
  let y = if track.value_size > 1 { track.values[base + 1] } else { 0.0 }
  let z = if track.value_size > 2 { track.values[base + 2] } else { 0.0 }
  let w = if track.value_size > 3 { track.values[base + 3] } else { 1.0 }
  (x, y, z, w)
}

///|
fn slerp_key(
  ax : Double,
  ay : Double,
  az : Double,
  aw : Double,
  bx : Double,
  by : Double,
  bz : Double,
  bw : Double,
  t : Double,
) -> (Double, Double, Double, Double) {
  let from = @math.Quaternion::new(x=ax, y=ay, z=az, w=aw)
  let to = @math.Quaternion::new(x=bx, y=by, z=bz, w=bw)
  ignore(from.slerp(to, t))
  (from.x, from.y, from.z, from.w)
}

///|
fn sample_track(
  track : KeyframeTrack,
  time : Double,
) -> (Double, Double, Double, Double) {
  let times = track.times
  let count = times.length()
  if time <= times[0] {
    return read_key(track, 0)
  }
  let mut index = 0
  while index + 1 < count && times[index + 1] <= time {
    index = index + 1
  }
  if index >= count - 1 || track.interpolation is Discrete {
    return read_key(track, index)
  }
  let span = times[index + 1] - times[index]
  let alpha = if span <= 0.0 { 0.0 } else { (time - times[index]) / span }
  let (x0, y0, z0, w0) = read_key(track, index)
  let (x1, y1, z1, w1) = read_key(track, index + 1)
  if track.value_size == 4 {
    slerp_key(x0, y0, z0, w0, x1, y1, z1, w1, alpha)
  } else {
    (
      x0 + (x1 - x0) * alpha,
      y0 + (y1 - y0) * alpha,
      z0 + (z1 - z0) * alpha,
      0.0,
    )
  }
}

///|
fn node_name(name : String, suffix : Int) -> String {
  name[:name.length() - suffix].to_owned()
}

///|
/// r186: `PropertyBinding` https://github.com/mrdoob/three.js/blob/r186/src/animation/PropertyBinding.js#L109
fn property_of(name : String) -> (String, Property)? {
  if name.has_suffix(".position") {
    Some((node_name(name, 9), Position))
  } else if name.has_suffix(".quaternion") {
    Some((node_name(name, 11), Quaternion))
  } else if name.has_suffix(".scale") {
    Some((node_name(name, 6), Scale))
  } else {
    None
  }
}

///|
fn resolve(root : Object3D, name : String) -> (Object3D, Property)? {
  match property_of(name) {
    None => None
    Some((node_name, property)) =>
      if node_name == "" {
        Some((root, property))
      } else {
        match root.get_object_by_name(node_name) {
          None => None
          Some(node) => Some((node, property))
        }
      }
  }
}

///|
fn same_property(left : Property, right : Property) -> Bool {
  match (left, right) {
    (Position, Position) => true
    (Quaternion, Quaternion) => true
    (Scale, Scale) => true
    _ => false
  }
}

///|
fn capture(node : Object3D, property : Property) -> PoseBinding {
  match property {
    Position =>
      {
        node,
        property,
        x: node.position.x,
        y: node.position.y,
        z: node.position.z,
        w: 0.0,
      }
    Scale =>
      {
        node,
        property,
        x: node.scale.x,
        y: node.scale.y,
        z: node.scale.z,
        w: 0.0,
      }
    Quaternion =>
      {
        node,
        property,
        x: node.quaternion.x,
        y: node.quaternion.y,
        z: node.quaternion.z,
        w: node.quaternion.w,
      }
  }
}

///|
fn ensure_binding(
  mixer : AnimationMixer,
  node : Object3D,
  property : Property,
) -> Unit {
  for binding in mixer.bindings {
    if physical_equal(binding.node, node) &&
      same_property(binding.property, property) {
      return
    }
  }
  mixer.bindings.push(capture(node, property))
}

///|
fn write_pose(
  node : Object3D,
  property : Property,
  x : Double,
  y : Double,
  z : Double,
  w : Double,
) -> Unit {
  match property {
    Position => ignore(node.position.set(x, y, z))
    Scale => ignore(node.scale.set(x, y, z))
    Quaternion => {
      let len = (x * x + y * y + z * z + w * w).sqrt()
      if len == 0.0 {
        ignore(node.quaternion.set(0.0, 0.0, 0.0, 1.0))
      } else {
        let inv = 1.0 / len
        ignore(node.quaternion.set(x * inv, y * inv, z * inv, w * inv))
      }
    }
  }
}

///|
fn apply_binding(binding : PoseBinding, contribs : Array[Contrib]) -> Unit {
  let mut x = 0.0
  let mut y = 0.0
  let mut z = 0.0
  let mut w = 0.0
  let mut total = 0.0
  let mut started = false
  for sample in contribs {
    if physical_equal(sample.node, binding.node) &&
      same_property(sample.property, binding.property) &&
      sample.weight != 0.0 {
      let mut sx = sample.x
      let mut sy = sample.y
      let mut sz = sample.z
      let mut sw = sample.w
      if binding.property is Quaternion && started {
        let dot = x * sx + y * sy + z * sz + w * sw
        if dot < 0.0 {
          sx = -sx
          sy = -sy
          sz = -sz
          sw = -sw
        }
      }
      x = x + sx * sample.weight
      y = y + sy * sample.weight
      z = z + sz * sample.weight
      w = w + sw * sample.weight
      total = total + sample.weight
      started = true
    }
  }
  if total <= 0.0 {
    write_pose(
      binding.node,
      binding.property,
      binding.x,
      binding.y,
      binding.z,
      binding.w,
    )
  } else {
    if total < 1.0 {
      let rest = 1.0 - total
      let mut ox = binding.x
      let mut oy = binding.y
      let mut oz = binding.z
      let mut ow = binding.w
      if binding.property is Quaternion {
        let dot = x * ox + y * oy + z * oz + w * ow
        if dot < 0.0 {
          ox = -ox
          oy = -oy
          oz = -oz
          ow = -ow
        }
      }
      x = x + ox * rest
      y = y + oy * rest
      z = z + oz * rest
      w = w + ow * rest
    }
    write_pose(binding.node, binding.property, x, y, z, w)
  }
}
