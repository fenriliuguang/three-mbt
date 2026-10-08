///|
let next_object_id : Ref[Int] = Ref::Ref(1)

///|
fn fresh_object_id() -> Int {
  let id = next_object_id.val
  next_object_id.val = id + 1
  id
}

///|
fn bind_rotation(euler : @math.Euler, quaternion : @math.Quaternion) -> Unit {
  euler.on_change = Some(fn() {
    ignore(quaternion.set_from_euler(euler, update=false))
  })
  quaternion.on_change = Some(fn() {
    ignore(euler.set_from_quaternion(quaternion, update=false))
  })
}

///|
fn faces_negative_z(kind : NodeKind) -> Bool {
  match kind {
    PerspectiveCamera | OrthographicCamera | AmbientLight | DirectionalLight =>
      true
    _ => false
  }
}

///|
fn child_index(children : Array[Object3D], object : Object3D) -> Int? {
  for i in 0..<children.length() {
    if physical_equal(children[i], object) {
      return Some(i)
    }
  }
  None
}

///|
/// 场景图节点。欧拉角和四元数通过回调保持同步；直接写 `rotation.x` 不会更新四元数，
/// 请用 `rotation.set` 或 `set_x` / `set_y` / `set_z`。
pub(all) struct Object3D {
  id : Int
  mut name : String
  kind : NodeKind
  position : @math.Vector3
  rotation : @math.Euler
  quaternion : @math.Quaternion
  scale : @math.Vector3
  up : @math.Vector3
  matrix : @math.Matrix4
  matrix_world : @math.Matrix4
  model_view_matrix : @math.Matrix4
  normal_matrix : @math.Matrix3
  mut matrix_auto_update : Bool
  mut matrix_world_auto_update : Bool
  mut matrix_world_needs_update : Bool
  mut parent : Object3D?
  children : Array[Object3D]
  layers : Layers
  mut visible : Bool
  mut cast_shadow : Bool
  mut receive_shadow : Bool
  mut frustum_culled : Bool
  mut render_order : Int
  mut pivot : @math.Vector3?
  mut camera : CameraState?
  mut mesh : MeshBinding?
  mut light : LightState?
  listeners : Map[String, Array[(ObjectEvent) -> Unit]]
}

///|
pub fn Object3D::new(kind? : NodeKind = Object) -> Object3D {
  let rotation = @math.Euler::new()
  let quaternion = @math.Quaternion::new()
  bind_rotation(rotation, quaternion)
  {
    id: fresh_object_id(),
    name: "",
    kind,
    position: @math.Vector3::new(),
    rotation,
    quaternion,
    scale: @math.Vector3::new(x=1.0, y=1.0, z=1.0),
    up: @math.Vector3::new(x=0.0, y=1.0, z=0.0),
    matrix: @math.Matrix4::new(),
    matrix_world: @math.Matrix4::new(),
    model_view_matrix: @math.Matrix4::new(),
    normal_matrix: @math.Matrix3::new(),
    matrix_auto_update: true,
    matrix_world_auto_update: true,
    matrix_world_needs_update: false,
    parent: None,
    children: [],
    layers: Layers::new(),
    visible: true,
    cast_shadow: false,
    receive_shadow: false,
    frustum_culled: true,
    render_order: 0,
    pivot: None,
    camera: None,
    mesh: None,
    light: None,
    listeners: Map([]),
  }
}

///|
pub impl AsNode for Object3D with fn to_node(self) {
  self
}

///|
pub extend Object3D with AsNode::{to_node}

///|
pub fn Object3D::add_event_listener(
  self : Object3D,
  kind : String,
  listener : (ObjectEvent) -> Unit,
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
pub fn Object3D::remove_event_listener(
  self : Object3D,
  kind : String,
  listener : (ObjectEvent) -> Unit,
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
pub fn Object3D::dispatch_event(self : Object3D, event : ObjectEvent) -> Unit {
  match self.listeners.get(event.kind) {
    None => ()
    Some(listeners) => {
      event.target = Some(self)
      let snapshot = listeners.copy()
      for listener in snapshot {
        listener(event)
      }
      event.target = None
    }
  }
}

///|
pub fn Object3D::update_matrix(self : Object3D) -> Unit {
  ignore(self.matrix.compose(self.position, self.quaternion, self.scale))
  match self.pivot {
    None => ()
    Some(pivot) => {
      let px = pivot.x
      let py = pivot.y
      let pz = pivot.z
      let te = self.matrix.elements
      te[12] += px - te[0] * px - te[4] * py - te[8] * pz
      te[13] += py - te[1] * px - te[5] * py - te[9] * pz
      te[14] += pz - te[2] * px - te[6] * py - te[10] * pz
    }
  }
  self.matrix_world_needs_update = true
}

///|
fn Object3D::update_view_inverse(self : Object3D) -> Unit {
  match self.camera {
    None => ()
    Some(camera) => {
      let position = @math.Vector3::new()
      let quaternion = @math.Quaternion::new()
      let scale = @math.Vector3::new()
      ignore(self.matrix_world.decompose(position, quaternion, scale))
      if scale.x == 1.0 && scale.y == 1.0 && scale.z == 1.0 {
        ignore(camera.matrix_world_inverse.copy(self.matrix_world).invert())
      } else {
        ignore(scale.set(1.0, 1.0, 1.0))
        ignore(
          camera.matrix_world_inverse
          .compose(position, quaternion, scale)
          .invert(),
        )
      }
    }
  }
}

///|
pub fn Object3D::update_matrix_world(
  self : Object3D,
  force? : Bool = false,
) -> Unit {
  self.update_matrix_world_inner(force)
}

///|
fn Object3D::update_matrix_world_inner(self : Object3D, force : Bool) -> Unit {
  let mut force = force
  if self.matrix_auto_update {
    self.update_matrix()
  }
  if self.matrix_world_needs_update || force {
    if self.matrix_world_auto_update {
      match self.parent {
        None => ignore(self.matrix_world.copy(self.matrix))
        Some(parent) =>
          ignore(
            self.matrix_world.multiply_matrices(
              parent.matrix_world,
              self.matrix,
            ),
          )
      }
    }
    self.matrix_world_needs_update = false
    force = true
    self.update_view_inverse()
  }
  for child in self.children {
    child.update_matrix_world_inner(force)
  }
}

///|
pub fn Object3D::update_world_matrix(
  self : Object3D,
  update_parents? : Bool = false,
  update_children? : Bool = false,
  force? : Bool = false,
) -> Unit {
  if update_parents {
    match self.parent {
      None => ()
      Some(parent) =>
        parent.update_world_matrix(update_parents=true, update_children=false)
    }
  }
  let mut force = force
  if self.matrix_auto_update {
    self.update_matrix()
  }
  if self.matrix_world_needs_update || force {
    if self.matrix_world_auto_update {
      match self.parent {
        None => ignore(self.matrix_world.copy(self.matrix))
        Some(parent) =>
          ignore(
            self.matrix_world.multiply_matrices(
              parent.matrix_world,
              self.matrix,
            ),
          )
      }
    }
    self.matrix_world_needs_update = false
    force = true
    self.update_view_inverse()
  }
  if update_children {
    for child in self.children {
      child.update_world_matrix(
        update_parents=false,
        update_children=true,
        force~,
      )
    }
  }
}

///|
pub fn Object3D::get_world_position(
  self : Object3D,
  target : @math.Vector3,
) -> @math.Vector3 {
  self.update_world_matrix(update_parents=true, update_children=false)
  target.set_from_matrix_position(self.matrix_world)
}

///|
pub fn Object3D::look_at(
  self : Object3D,
  x : Double,
  y : Double,
  z : Double,
) -> Unit {
  self.look_at_vector(@math.Vector3::new(x~, y~, z~))
}

///|
pub fn Object3D::look_at_vector(
  self : Object3D,
  target : @math.Vector3,
) -> Unit {
  self.update_world_matrix(update_parents=true, update_children=false)
  let position = @math.Vector3::new().set_from_matrix_position(
    self.matrix_world,
  )
  let rotation = @math.Matrix4::new()
  if faces_negative_z(self.kind) {
    ignore(rotation.look_at(position, target, self.up))
  } else {
    ignore(rotation.look_at(target, position, self.up))
  }
  ignore(self.quaternion.set_from_rotation_matrix(rotation))
  match self.parent {
    None => ()
    Some(parent) => {
      let parent_rotation = @math.Matrix4::new().extract_rotation(
        parent.matrix_world,
      )
      let parent_quaternion = @math.Quaternion::new().set_from_rotation_matrix(
        parent_rotation,
      )
      ignore(self.quaternion.premultiply(parent_quaternion.invert()))
    }
  }
}

///|
pub fn Object3D::add(self : Object3D, object : Object3D) -> Object3D {
  if physical_equal(object, self) {
    return self
  }
  ignore(object.remove_from_parent())
  object.parent = Some(self)
  self.children.push(object)
  object.dispatch_event(ObjectEvent::new("added"))
  let child_added = ObjectEvent::new("childadded")
  child_added.child = Some(object)
  self.dispatch_event(child_added)
  self
}

///|
pub fn Object3D::remove(self : Object3D, object : Object3D) -> Object3D {
  match child_index(self.children, object) {
    None => ()
    Some(index) => {
      object.parent = None
      ignore(self.children.remove(index))
      object.dispatch_event(ObjectEvent::new("removed"))
      let child_removed = ObjectEvent::new("childremoved")
      child_removed.child = Some(object)
      self.dispatch_event(child_removed)
    }
  }
  self
}

///|
pub fn Object3D::remove_from_parent(self : Object3D) -> Object3D {
  match self.parent {
    None => ()
    Some(parent) => ignore(parent.remove(self))
  }
  self
}

///|
pub fn Object3D::clear(self : Object3D) -> Object3D {
  while self.children.length() > 0 {
    ignore(self.remove(self.children[0]))
  }
  self
}

///|
pub fn Object3D::traverse(self : Object3D, visit : (Object3D) -> Unit) -> Unit {
  visit(self)
  let count = self.children.length()
  let mut index = 0
  while index < count {
    self.children[index].traverse(visit)
    index = index + 1
  }
}

///|
pub fn Object3D::traverse_visible(
  self : Object3D,
  visit : (Object3D) -> Unit,
) -> Unit {
  if !self.visible {
    return
  }
  visit(self)
  let count = self.children.length()
  let mut index = 0
  while index < count {
    self.children[index].traverse_visible(visit)
    index = index + 1
  }
}
