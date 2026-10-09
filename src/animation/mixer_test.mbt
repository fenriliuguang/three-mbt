///|
fn bob_clip() -> @animation.AnimationClip {
  let position = @animation.KeyframeTrack::vector(".position", [0.0, 2.0], [
    0.0, 0.0, 0.0, 0.0, 2.0, 0.0,
  ])
  @animation.AnimationClip::new("bob", [position])
}

///|
test "loop modes and interpolation keep r186 numbers" {
  assert_eq(@constants.LoopMode::Once.to_int(), 2200)
  assert_eq(@constants.LoopMode::Repeat.to_int(), 2201)
  assert_eq(@constants.LoopMode::PingPong.to_int(), 2202)
  assert_eq(@constants.Interpolation::Discrete.to_int(), 2300)
  assert_eq(@constants.Interpolation::Linear.to_int(), 2301)
  assert_eq(@constants.INTERPOLATE_SMOOTH, 2302)
  assert_eq(@constants.LOOP_ONCE, 2200)
  assert_eq(@constants.LOOP_REPEAT, 2201)
  assert_eq(@constants.LOOP_PING_PONG, 2202)
}

///|
test "linear playback blends and loop repeat wraps" {
  let root = @core.Object3D::new()
  let mixer = @animation.AnimationMixer::new(root)
  let clip = bob_clip()
  assert_eq(clip.duration, 2.0)
  let action = mixer.clip_action(clip)
  assert_eq(physical_equal(mixer.clip_action(clip), action), true)
  action.play()
  mixer.update(1.0)
  assert_eq(action.time, 1.0)
  assert_eq(root.position.y, 1.0)
  mixer.update(2.0)
  assert_eq(action.time, 1.0)
  assert_eq(root.position.y, 1.0)
}

///|
test "discrete holds the previous key and quaternion slerps" {
  let root = @core.Object3D::new()
  let position = @animation.KeyframeTrack::vector(".position", [0.0, 1.0], [
    0.0, 0.0, 0.0, 0.0, 4.0, 0.0,
  ])
  position.interpolation = Discrete
  let rotation = @animation.KeyframeTrack::quaternion(
    ".quaternion",
    [0.0, 1.0],
    [0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0],
  )
  let clip = @animation.AnimationClip::new("turn", [position, rotation])
  let mixer = @animation.AnimationMixer::new(root)
  let action = mixer.clip_action(clip)
  action.set_loop(Once)
  action.set_clamp(true)
  action.play()
  mixer.update(0.5)
  assert_eq(root.position.y, 0.0)
  assert_eq(root.quaternion.y > 0.707 && root.quaternion.y < 0.708, true)
  assert_eq(root.quaternion.w > 0.707 && root.quaternion.w < 0.708, true)
  mixer.update(0.5)
  assert_eq(action.time, 1.0)
  assert_eq(action.paused, true)
  assert_eq(root.position.y, 4.0)
  assert_eq(root.quaternion.y, 1.0)
  assert_eq(root.quaternion.w, 0.0)
}

///|
test "loop once restores the rest pose unless clamped" {
  let root = @core.Object3D::new()
  ignore(root.position.set(0.0, 5.0, 0.0))
  let mixer = @animation.AnimationMixer::new(root)
  let action = mixer.clip_action(bob_clip())
  action.set_loop(Once)
  action.play()
  mixer.update(2.0)
  assert_eq(root.position.y, 2.0)
  assert_eq(action.enabled, false)
  mixer.update(1.0)
  assert_eq(root.position.y, 5.0)
}

///|
test "pingpong returns and a named child can be the target" {
  let root = @core.Object3D::new()
  let arm = @core.Object3D::new()
  arm.name = "arm"
  ignore(root.add(arm))
  match root.get_object_by_name("arm") {
    None => panic()
    Some(found) => assert_eq(physical_equal(found, arm), true)
  }
  assert_eq(root.get_object_by_name("missing") is None, true)
  let track = @animation.KeyframeTrack::vector("arm.position", [0.0, 2.0], [
    0.0, 0.0, 0.0, 0.0, 2.0, 0.0,
  ])
  let mixer = @animation.AnimationMixer::new(root)
  let action = mixer.clip_action(@animation.AnimationClip::new("arm", [track]))
  action.set_loop(PingPong)
  action.play()
  mixer.update(3.0)
  assert_eq(arm.position.y, 1.0)
  assert_eq(root.position.y, 0.0)
}

///|
test "weight blends the sample with the captured rest pose" {
  let root = @core.Object3D::new()
  let mixer = @animation.AnimationMixer::new(root)
  let action = mixer.clip_action(bob_clip())
  action.weight = 0.5
  action.set_loop(Once)
  action.set_clamp(true)
  action.play()
  mixer.update(2.0)
  assert_eq(root.position.y, 1.0)
  action.stop()
  mixer.update(0.0)
  assert_eq(root.position.y, 0.0)
  assert_eq(action.playing, false)
}
