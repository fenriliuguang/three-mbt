// r186: `EventDispatcher` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L23

///|
/// 场景图实际会发出的事件。`kind` 取 `added`、`removed`、`childadded`、`childremoved`。
/// r186: `EventDispatcher` https://github.com/mrdoob/three.js/blob/r186/src/core/EventDispatcher.js#L23
pub(all) struct ObjectEvent {
  kind : String
  mut target : Object3D?
  mut child : Object3D?
}

///|
pub fn ObjectEvent::new(kind : String) -> ObjectEvent {
  { kind, target: None, child: None, }
}
