// r186: `AnimationAction` https://github.com/mrdoob/three.js/blob/r186/src/animation/AnimationAction.js#L7

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
  mut repetitions : Int32
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
  repetitions~ : Int32 = -1,
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
