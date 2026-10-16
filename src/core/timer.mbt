// r186: `Timer` https://github.com/mrdoob/three.js/blob/r186/src/core/Timer.js#L15

///|
/// 模拟步长上的时间。时间原点默认是 `0`。
/// r186: `Timer` https://github.com/mrdoob/three.js/blob/r186/src/core/Timer.js#L15
pub(all) struct Timer {
  mut previous_time : Double
  mut current_time : Double
  mut start_time : Double
  mut delta : Double
  mut elapsed : Double
  mut timescale : Double
}

///|
pub fn Timer::new(start_time? : Double = 0.0) -> Timer {
  {
    previous_time: 0.0,
    current_time: 0.0,
    start_time,
    delta: 0.0,
    elapsed: 0.0,
    timescale: 1.0,
  }
}

///|
/// 返回上一次 `update` 的时间间隔，单位是秒。
/// r186: `getDelta` https://github.com/mrdoob/three.js/blob/r186/src/core/Timer.js#L80
pub fn Timer::get_delta(self : Timer) -> Double {
  self.delta / 1000.0
}

///|
/// 用毫秒时间戳更新内部时间。时间戳减去时间原点。
/// r186: `update` https://github.com/mrdoob/three.js/blob/r186/src/core/Timer.js#L156
pub fn Timer::update(self : Timer, timestamp : Double) -> Timer {
  self.previous_time = self.current_time
  self.current_time = timestamp - self.start_time
  self.delta = (self.current_time - self.previous_time) * self.timescale
  self.elapsed = self.elapsed + self.delta
  self
}
