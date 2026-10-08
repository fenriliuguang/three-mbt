///|
/// 场景图实际会发出的事件。`kind` 取 `added`、`removed`、`childadded`、`childremoved`。
pub(all) struct ObjectEvent {
  kind : String
  mut target : Object3D?
  mut child : Object3D?
}

///|
pub fn ObjectEvent::new(kind : String) -> ObjectEvent {
  { kind, target: None, child: None, }
}
