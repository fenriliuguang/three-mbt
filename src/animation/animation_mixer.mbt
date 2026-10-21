// r186: `AnimationMixer` https://github.com/mrdoob/three.js/blob/r186/src/animation/AnimationMixer.js#L16

///|
using @core {type Object3D}

///|
using @constants {type Interpolation, type LoopMode}

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
/// 把片段写到 `root` 及其具名子节点上。
/// r186: `AnimationMixer` https://github.com/mrdoob/three.js/blob/r186/src/animation/AnimationMixer.js#L16
pub struct AnimationMixer {
  root : Object3D
  mut time : Double
  mut time_scale : Double
  actions : Array[AnimationAction]
  bindings : Array[PoseBinding]
  weight_poses : Array[WeightPose]
}

///|
pub fn AnimationMixer::new(root : Object3D) -> AnimationMixer {
  {
    root,
    time: 0.0,
    time_scale: 1.0,
    actions: [],
    bindings: [],
    weight_poses: [],
  }
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
  let samples = []
  for action in sampling {
    for track in action.clip.tracks {
      if track.name.has_suffix(".morphTargetInfluences") {
        let target_name = node_name(track.name, 22)
        let target = if target_name == "" {
          Some(self.root)
        } else {
          self.root.get_object_by_name(target_name)
        }
        match target {
          None => ()
          Some(node) => {
            ensure_weight_pose(self, node)
            samples.push({
              node,
              values: sample_values(track, clip_time(action)),
              weight: action.weight,
            })
          }
        }
      }
    }
  }
  for pose in self.weight_poses {
    apply_morph_weights(pose.node, blend_weights(pose.rest, samples, pose.node))
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

///|
fn spline_or_key(
  track : KeyframeTrack,
  index : Int,
) -> (Double, Double, Double, Double) {
  if track.cubic_spline {
    spline_vertex(track, index)
  } else {
    read_key(track, index)
  }
}

///|
fn spline_vertex(
  track : KeyframeTrack,
  index : Int,
) -> (Double, Double, Double, Double) {
  let stride = track.value_size
  let base = index * stride * 3 + stride
  let x = track.values[base]
  let y = if stride > 1 { track.values[base + 1] } else { 0.0 }
  let z = if stride > 2 { track.values[base + 2] } else { 0.0 }
  let w = if stride > 3 { track.values[base + 3] } else { 1.0 }
  (x, y, z, w)
}

///|
/// 切线布局是切入、顶点、切出。`index` 是左边那个关键帧。
/// r186: `interpolate_` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L2156
fn gltf_cubic(
  track : KeyframeTrack,
  index : Int,
  time : Double,
) -> (Double, Double, Double, Double) {
  let t0 = track.times[index]
  let t1 = track.times[index + 1]
  let td = t1 - t0
  if td == 0.0 {
    return spline_vertex(track, index)
  }
  let p = (time - t0) / td
  let pp = p * p
  let ppp = pp * p
  let s2 = -2.0 * ppp + 3.0 * pp
  let s3 = ppp - pp
  let s0 = 1.0 - s2
  let s1 = s3 - pp + p
  let stride = track.value_size
  let offset0 = index * stride * 3
  let offset1 = offset0 + stride * 3
  fn component(i : Int) -> Double {
    let p0 = track.values[offset0 + i + stride]
    let m0 = track.values[offset0 + i + stride * 2] * td
    let p1 = track.values[offset1 + i + stride]
    let m1 = track.values[offset1 + i] * td
    s0 * p0 + s1 * m0 + s2 * p1 + s3 * m1
  }
  let x = component(0)
  let y = if stride > 1 { component(1) } else { 0.0 }
  let z = if stride > 2 { component(2) } else { 0.0 }
  let w = if stride > 3 { component(3) } else { 0.0 }
  if stride == 4 {
    let rotation = @math.Quaternion::new(x~, y~, z~, w~)
    ignore(rotation.normalize())
    (rotation.x, rotation.y, rotation.z, rotation.w)
  } else {
    (x, y, z, w)
  }
}

///|
fn sample_track(
  track : KeyframeTrack,
  time : Double,
) -> (Double, Double, Double, Double) {
  let times = track.times
  let count = times.length()
  if time <= times[0] {
    return spline_or_key(track, 0)
  }
  let mut index = 0
  while index + 1 < count && times[index + 1] <= time {
    index = index + 1
  }
  if index >= count - 1 {
    return spline_or_key(track, index)
  }
  if track.cubic_spline {
    return gltf_cubic(track, index, time)
  }
  if track.interpolation is Discrete {
    return read_key(track, index)
  }
  let span = times[index + 1] - times[index]
  let alpha = if span <= 0.0 { 0.0 } else { (time - times[index]) / span }
  let (x0, y0, z0, w0) = read_key(track, index)
  let (x1, y1, z1, w1) = read_key(track, index + 1)
  if track.value_size == 4 {
    slerp_key(x0, y0, z0, w0, x1, y1, z1, w1, alpha)
  } else if track.interpolation is Smooth {
    match smooth_vector(track, index, alpha) {
      Some(sampled) => sampled
      None =>
        (
          x0 + (x1 - x0) * alpha,
          y0 + (y1 - y0) * alpha,
          z0 + (z1 - z0) * alpha,
          0.0,
        )
    }
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
/// 零曲率端点的三次样条。相邻时间相同则返回 `None`，调用方改走线性。
/// 四元数轨道不走这里。
/// r186: `interpolate_` https://github.com/mrdoob/three.js/blob/r186/src/math/interpolants/CubicInterpolant.js#L120
fn smooth_vector(
  track : KeyframeTrack,
  index : Int,
  p : Double,
) -> (Double, Double, Double, Double)? {
  let t0 = track.times[index]
  let t1 = track.times[index + 1]
  let span = t1 - t0
  if span == 0.0 {
    return None
  }
  let half = span * 0.5
  let (weight_prev, prev) = if index == 0 {
    (half / (t0 - t1), index + 1)
  } else {
    let denom = t0 - track.times[index - 1]
    if denom == 0.0 {
      return None
    }
    (half / denom, index - 1)
  }
  let (weight_next, next) = if index + 2 >= track.times.length() {
    (half / (t0 - t1), index)
  } else {
    let denom = track.times[index + 2] - t1
    if denom == 0.0 {
      return None
    }
    (half / denom, index + 2)
  }
  let (px, py, pz, _) = read_key(track, prev)
  let (x0, y0, z0, _) = read_key(track, index)
  let (x1, y1, z1, _) = read_key(track, index + 1)
  let (nx, ny, nz, _) = read_key(track, next)
  Some(
    (
      cubic_channel(px, x0, x1, nx, weight_prev, weight_next, p),
      cubic_channel(py, y0, y1, ny, weight_prev, weight_next, p),
      cubic_channel(pz, z0, z1, nz, weight_prev, weight_next, p),
      0.0,
    ),
  )
}

///|
fn cubic_channel(
  prev : Double,
  v0 : Double,
  v1 : Double,
  next : Double,
  weight_prev : Double,
  weight_next : Double,
  p : Double,
) -> Double {
  let pp = p * p
  let ppp = pp * p
  let s_prev = -weight_prev * ppp + 2.0 * weight_prev * pp - weight_prev * p
  let s0 = (1.0 + weight_prev) * ppp +
    (-1.5 - 2.0 * weight_prev) * pp +
    (-0.5 + weight_prev) * p +
    1.0
  let s1 = (-1.0 - weight_next) * ppp + (1.5 + weight_next) * pp + 0.5 * p
  let s_next = weight_next * ppp - weight_next * pp
  s_prev * prev + s0 * v0 + s1 * v1 + s_next * next
}

///|
struct WeightPose {
  node : Object3D
  rest : Array[Double]
}

///|
priv struct WeightSample {
  node : Object3D
  values : Array[Double]
  weight : Double
}

///|
fn ensure_weight_pose(mixer : AnimationMixer, node : Object3D) -> Unit {
  for pose in mixer.weight_poses {
    if physical_equal(pose.node, node) {
      return
    }
  }
  match current_weights(node) {
    None => ()
    Some(rest) => mixer.weight_poses.push({ node, rest, })
  }
}

///|
fn current_weights(node : Object3D) -> Array[Double]? {
  match node.morph {
    Some(state) => Some(state.weights.copy())
    None => {
      let mut found : Array[Double]? = None
      for child in node.children {
        if found is None {
          match child.morph {
            Some(state) => found = Some(state.weights.copy())
            None => ()
          }
        }
      }
      found
    }
  }
}

///|
fn blend_weights(
  rest : Array[Double],
  samples : Array[WeightSample],
  node : Object3D,
) -> Array[Double] {
  let out = []
  let mut index = 0
  while index < rest.length() {
    out.push(0.0)
    index = index + 1
  }
  let mut total = 0.0
  for sample in samples {
    if physical_equal(sample.node, node) && sample.weight != 0.0 {
      total = total + sample.weight
      index = 0
      while index < out.length() {
        let value = if index < sample.values.length() {
          sample.values[index]
        } else {
          0.0
        }
        out[index] = out[index] + value * sample.weight
        index = index + 1
      }
    }
  }
  if total <= 0.0 {
    rest.copy()
  } else {
    if total < 1.0 {
      let rest_weight = 1.0 - total
      index = 0
      while index < out.length() {
        out[index] = out[index] + rest[index] * rest_weight
        index = index + 1
      }
    }
    out
  }
}

///|
/// 写入这个节点，以及多原语分组的直接子网格。
/// r186: `weights` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L4597
fn apply_morph_weights(node : Object3D, weights : Array[Double]) -> Unit {
  write_morph(node, weights)
  for child in node.children {
    match child.morph {
      None => ()
      Some(_) => write_morph(child, weights)
    }
  }
}

///|
fn write_morph(node : Object3D, weights : Array[Double]) -> Unit {
  match node.morph {
    None => ()
    Some(state) => {
      state.weights = weights.copy()
      if state.shared {
        match node.mesh {
          None => ()
          Some(binding) => {
            binding.geometry = binding.geometry.clone()
            state.shared = false
          }
        }
      }
      match node.mesh {
        None => ()
        Some(binding) => state.write(binding.geometry)
      }
    }
  }
}

///|
fn sample_values(track : KeyframeTrack, time : Double) -> Array[Double] {
  let times = track.times
  let count = times.length()
  if time <= times[0] {
    return key_vector(track, 0)
  }
  let mut index = 0
  while index + 1 < count && times[index + 1] <= time {
    index = index + 1
  }
  if index >= count - 1 {
    return key_vector(track, index)
  }
  if track.cubic_spline {
    return cubic_vector(track, index, time)
  }
  if track.interpolation is Discrete {
    return key_vector(track, index)
  }
  let span = times[index + 1] - times[index]
  let alpha = if span <= 0.0 { 0.0 } else { (time - times[index]) / span }
  let out = []
  let mut component = 0
  while component < track.value_size {
    let start = keyed(track, index, component)
    let end = keyed(track, index + 1, component)
    out.push(start + (end - start) * alpha)
    component = component + 1
  }
  out
}

///|
fn key_vector(track : KeyframeTrack, index : Int) -> Array[Double] {
  let out = []
  let mut component = 0
  while component < track.value_size {
    out.push(keyed(track, index, component))
    component = component + 1
  }
  out
}

///|
fn keyed(track : KeyframeTrack, index : Int, component : Int) -> Double {
  let stride = track.value_size
  let base = if track.cubic_spline {
    index * stride * 3 + stride
  } else {
    index * stride
  }
  track.values[base + component]
}

///|
fn cubic_vector(
  track : KeyframeTrack,
  index : Int,
  time : Double,
) -> Array[Double] {
  let t0 = track.times[index]
  let t1 = track.times[index + 1]
  let td = t1 - t0
  if td == 0.0 {
    return key_vector(track, index)
  }
  let p = (time - t0) / td
  let pp = p * p
  let ppp = pp * p
  let s2 = -2.0 * ppp + 3.0 * pp
  let s3 = ppp - pp
  let s0 = 1.0 - s2
  let s1 = s3 - pp + p
  let stride = track.value_size
  let offset0 = index * stride * 3
  let offset1 = offset0 + stride * 3
  let out = []
  let mut component = 0
  while component < stride {
    let p0 = track.values[offset0 + component + stride]
    let m0 = track.values[offset0 + component + stride * 2] * td
    let p1 = track.values[offset1 + component + stride]
    let m1 = track.values[offset1 + component] * td
    out.push(s0 * p0 + s1 * m0 + s2 * p1 + s3 * m1)
    component = component + 1
  }
  out
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
