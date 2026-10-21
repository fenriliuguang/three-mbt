// r186: `UniformsGroup` https://github.com/mrdoob/three.js/blob/r186/src/core/UniformsGroup.js#L15

///|
/// 把数字 uniform 复制成一张新表。改目标里的数不会改到源。
/// r186: `cloneUniforms` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/UniformsUtils.js#L18
fn copied_uniforms(source : Map[String, Double]) -> Map[String, Double] {
  let copied : Map[String, Double] = Map([])
  for pair in source.iter() {
    let (key, value) = pair
    copied.set(key, value)
  }
  copied
}

///|
let next_uniforms_group_id : Ref[Int] = Ref::Ref(0)

///|
fn fresh_uniforms_group_id() -> Int {
  let id = next_uniforms_group_id.val
  next_uniforms_group_id.val = id + 1
  id
}

///|
/// 一组 uniform。渲染器会把它收成一个 UBO。这一刀存编号、名字、`usage`、一组数字和监听表。颜色、向量、数组和贴图仍不进组。`dispose` 只通知 `dispose` 监听。
/// r186: `UniformsGroup` https://github.com/mrdoob/three.js/blob/r186/src/core/UniformsGroup.js#L15 ; `id` https://github.com/mrdoob/three.js/blob/r186/src/core/UniformsGroup.js#L40 ; `name` https://github.com/mrdoob/three.js/blob/r186/src/core/UniformsGroup.js#L47 ; `usage` https://github.com/mrdoob/three.js/blob/r186/src/core/UniformsGroup.js#L55 ; `uniforms` https://github.com/mrdoob/three.js/blob/r186/src/core/UniformsGroup.js#L62 ; `dispose` https://github.com/mrdoob/three.js/blob/r186/src/core/UniformsGroup.js#L130
pub(all) struct UniformsGroup {
  id : Int
  mut name : String
  mut usage : Int
  mut uniforms : Array[Double]
  listeners : Map[String, Array[() -> Unit]]
}

///|
/// 新建一组。名字默认空，`usage` 默认 `35044`，数字列表和监听表默认空。编号从 `0` 起递增。
/// r186: `UniformsGroup` https://github.com/mrdoob/three.js/blob/r186/src/core/UniformsGroup.js#L20
pub fn UniformsGroup::new(name? : String = "") -> UniformsGroup {
  {
    id: fresh_uniforms_group_id(),
    name,
    usage: @constants.STATIC_DRAW_USAGE,
    uniforms: [],
    listeners: Map([]),
  }
}

///|
/// 把一个数字追加进组，并返回这一组。颜色、向量、数组和贴图仍不能加进来。
/// r186: `add` https://github.com/mrdoob/three.js/blob/r186/src/core/UniformsGroup.js#L72
pub fn UniformsGroup::add(self : UniformsGroup, value : Double) -> UniformsGroup {
  self.uniforms.push(value)
  self
}

///|
/// 从组里去掉第一次出现的这个数字，并返回这一组。没有这个数字时列表不变。
/// r186: `remove` https://github.com/mrdoob/three.js/blob/r186/src/core/UniformsGroup.js#L86
pub fn UniformsGroup::remove(
  self : UniformsGroup,
  value : Double,
) -> UniformsGroup {
  let mut found = None
  for i in 0..<self.uniforms.length() {
    if found is None && self.uniforms[i] == value {
      found = Some(i)
    }
  }
  match found {
    None => ()
    Some(index) => ignore(self.uniforms.remove(index))
  }
  self
}

///|
/// 改这一组的名字，并返回这一组。
/// r186: `setName` https://github.com/mrdoob/three.js/blob/r186/src/core/UniformsGroup.js#L102
pub fn UniformsGroup::set_name(
  self : UniformsGroup,
  name : String,
) -> UniformsGroup {
  self.name = name
  self
}

///|
/// 改这一组的 `usage`，并返回这一组。`35044` 是静态绘制，`35048` 是动态绘制。
/// r186: `setUsage` https://github.com/mrdoob/three.js/blob/r186/src/core/UniformsGroup.js#L116
pub fn UniformsGroup::set_usage(
  self : UniformsGroup,
  value : Int,
) -> UniformsGroup {
  self.usage = value
  self
}

///|
/// 登记一个监听。同一种事件里，同一个函数只保留一次。
/// r186: `addEventListener` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L31
pub fn UniformsGroup::add_event_listener(
  self : UniformsGroup,
  kind : String,
  listener : () -> Unit,
) -> Unit {
  let listeners = self.listeners.get_or_init(kind, fn() { [] })
  let mut found = false
  for existing in listeners {
    if physical_equal(existing, listener) {
      found = true
    }
  }
  if !found {
    listeners.push(listener)
  }
}

///|
/// 同一种事件里是否已经有这个监听。
/// r186: `hasEventListener` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L58
pub fn UniformsGroup::has_event_listener(
  self : UniformsGroup,
  kind : String,
  listener : () -> Unit,
) -> Bool {
  match self.listeners.get(kind) {
    None => false
    Some(listeners) => {
      let mut found = false
      for existing in listeners {
        if physical_equal(existing, listener) {
          found = true
        }
      }
      found
    }
  }
}

///|
/// 从一种事件里移除这个监听。没有登记时不动。
/// r186: `removeEventListener` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L74
pub fn UniformsGroup::remove_event_listener(
  self : UniformsGroup,
  kind : String,
  listener : () -> Unit,
) -> Unit {
  match self.listeners.get(kind) {
    None => ()
    Some(listeners) => {
      let mut index = None
      for i in 0..<listeners.length() {
        if physical_equal(listeners[i], listener) {
          index = Some(i)
        }
      }
      match index {
        None => ()
        Some(index) => ignore(listeners.remove(index))
      }
    }
  }
}

///|
/// 按名字通知已经登记的监听。调用期间改列表不会漏掉这一轮快照。
/// r186: `dispatchEvent` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L101
pub fn UniformsGroup::dispatch_event(self : UniformsGroup, kind : String) -> Unit {
  match self.listeners.get(kind) {
    None => ()
    Some(listeners) => {
      let snapshot = listeners.copy()
      for listener in snapshot {
        listener()
      }
    }
  }
}

///|
/// 通知 `dispose` 监听。其它事件不动。渲染器仍不因这次调用释放 GPU 缓冲。
/// r186: `dispose` https://github.com/mrdoob/three.js/blob/r186/src/core/UniformsGroup.js#L130
pub fn UniformsGroup::dispose(self : UniformsGroup) -> Unit {
  self.dispatch_event("dispose")
}

///|
/// 新建一组，沿用名字、`usage` 和数字。编号是新的，数字数组是新的一份，监听表是空的。
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/UniformsGroup.js#L172
pub fn UniformsGroup::clone(self : UniformsGroup) -> UniformsGroup {
  {
    id: fresh_uniforms_group_id(),
    name: self.name,
    usage: self.usage,
    uniforms: copied_doubles(self.uniforms),
    listeners: Map([]),
  }
}

///|
/// 把源的名字、`usage` 和数字写进这一组。编号和监听留在目标上。数字写进目标原来的数组，改目标不改源。
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/core/UniformsGroup.js#L142
pub fn UniformsGroup::copy(
  self : UniformsGroup,
  source : UniformsGroup,
) -> UniformsGroup {
  self.name = source.name
  self.usage = source.usage
  self.uniforms.clear()
  for value in source.uniforms {
    self.uniforms.push(value)
  }
  self
}

///|
/// 把 uniform 组复制成一张新数组。每组拿新的编号，名字、`usage` 和数字列表跟着走。数字数组是新的一份。监听表留空。
/// r186: `cloneUniformsGroups` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/UniformsUtils.js#L114
/// r186: `clone` https://github.com/mrdoob/three.js/blob/r186/src/core/UniformsGroup.js#L172
/// r186: `copy` https://github.com/mrdoob/three.js/blob/r186/src/core/UniformsGroup.js#L142
fn copied_uniforms_groups(
  source : Array[UniformsGroup],
) -> Array[UniformsGroup] {
  let copied : Array[UniformsGroup] = []
  for group in source {
    copied.push(group.clone())
  }
  copied
}

