// r186: `AnimationClip` https://github.com/mrdoob/three.js/blob/r186/src/animation/AnimationClip.js#L15

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

