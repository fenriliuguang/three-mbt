///|
test "UniformsGroup copies numeric uniforms" {
  let frame = @materials.UniformsGroup::new(name="Frame")
  assert_eq(frame.uniforms.length(), 0)
  frame.uniforms.push(1.0)
  frame.uniforms.push(2.0)
  let shader = @materials.Material::shader()
  shader.uniforms_groups.push(frame)
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  assert_eq(onto.uniforms_groups[0].uniforms, [1.0, 2.0])
  assert_eq(onto.uniforms_groups[0].id == shader.uniforms_groups[0].id, false)
  onto.uniforms_groups[0].uniforms[0] = 9.0
  assert_eq(onto.uniforms_groups[0].uniforms[0], 9.0)
  assert_eq(shader.uniforms_groups[0].uniforms[0], 1.0)
  let cloned = shader.clone()
  assert_eq(cloned.uniforms_groups[0].uniforms, [1.0, 2.0])
  cloned.uniforms_groups[0].uniforms[0] = 8.0
  assert_eq(shader.uniforms_groups[0].uniforms[0], 1.0)
}

///|
test "UniformsGroup add appends a number" {
  let frame = @materials.UniformsGroup::new(name="Frame")
  let chained = frame.add(1.0).add(2.0)
  assert_eq(frame.uniforms, [1.0, 2.0])
  assert_eq(chained.uniforms, [1.0, 2.0])
  assert_eq(chained.id, frame.id)
  let shader = @materials.Material::shader()
  shader.uniforms_groups.push(frame)
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  ignore(shader.uniforms_groups[0].add(4.0))
  assert_eq(shader.uniforms_groups[0].uniforms, [1.0, 2.0, 4.0])
  assert_eq(onto.uniforms_groups[0].uniforms, [1.0, 2.0])
}

///|
test "UniformsGroup remove drops the first matching number" {
  let frame = @materials.UniformsGroup::new(name="Frame")
  ignore(frame.add(1.0).add(2.0).add(1.0))
  let chained = frame.remove(1.0)
  assert_eq(frame.uniforms, [2.0, 1.0])
  assert_eq(chained.uniforms, [2.0, 1.0])
  assert_eq(chained.id, frame.id)
  ignore(frame.remove(9.0))
  assert_eq(frame.uniforms, [2.0, 1.0])
  let shader = @materials.Material::shader()
  shader.uniforms_groups.push(frame)
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  ignore(shader.uniforms_groups[0].remove(2.0))
  assert_eq(shader.uniforms_groups[0].uniforms, [1.0])
  assert_eq(onto.uniforms_groups[0].uniforms, [2.0, 1.0])
}

///|
test "UniformsGroup setName replaces the name" {
  let frame = @materials.UniformsGroup::new()
  assert_eq(frame.name, "")
  let chained = frame.set_name("Frame").set_name("Lights")
  assert_eq(frame.name, "Lights")
  assert_eq(chained.name, "Lights")
  assert_eq(chained.id, frame.id)
  let shader = @materials.Material::shader()
  shader.uniforms_groups.push(frame)
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  ignore(shader.uniforms_groups[0].set_name("Renamed"))
  assert_eq(shader.uniforms_groups[0].name, "Renamed")
  assert_eq(onto.uniforms_groups[0].name, "Lights")
}

///|
test "UniformsGroup setUsage replaces the usage" {
  let frame = @materials.UniformsGroup::new(name="Frame")
  assert_eq(frame.usage, 35044)
  let chained = frame.set_usage(35048)
  assert_eq(frame.usage, 35048)
  assert_eq(chained.usage, 35048)
  assert_eq(chained.id, frame.id)
  let shader = @materials.Material::shader()
  shader.uniforms_groups.push(frame)
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  ignore(shader.uniforms_groups[0].set_usage(35044))
  assert_eq(shader.uniforms_groups[0].usage, 35044)
  assert_eq(onto.uniforms_groups[0].usage, 35048)
}

///|
test "UniformsGroup dispose runs dispose listeners" {
  let frame = @materials.UniformsGroup::new(name="Frame")
  let hits = Ref::Ref(0)
  let listener = fn() { hits.val = hits.val + 1 }
  frame.add_event_listener("dispose", listener)
  frame.add_event_listener("dispose", listener)
  frame.add_event_listener("change", fn() { hits.val = hits.val + 10 })
  frame.dispose()
  assert_eq(hits.val, 1)
  frame.dispose()
  assert_eq(hits.val, 2)
  let shader = @materials.Material::shader()
  shader.uniforms_groups.push(frame)
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  onto.uniforms_groups[0].dispose()
  assert_eq(hits.val, 2)
  shader.uniforms_groups[0].dispose()
  assert_eq(hits.val, 3)
}

///|
test "UniformsGroup hasEventListener checks one function" {
  let frame = @materials.UniformsGroup::new(name="Frame")
  let listener = fn() {  }
  let other = fn() {  }
  assert_eq(frame.has_event_listener("dispose", listener), false)
  frame.add_event_listener("dispose", listener)
  assert_eq(frame.has_event_listener("dispose", listener), true)
  assert_eq(frame.has_event_listener("dispose", other), false)
  assert_eq(frame.has_event_listener("change", listener), false)
  let fresh = @materials.UniformsGroup::new(name="Other")
  assert_eq(fresh.has_event_listener("dispose", listener), false)
  let shader = @materials.Material::shader()
  shader.uniforms_groups.push(frame)
  let onto = @materials.Material::shader()
  ignore(onto.copy(shader))
  assert_eq(
    onto.uniforms_groups[0].has_event_listener("dispose", listener),
    false,
  )
  assert_eq(
    shader.uniforms_groups[0].has_event_listener("dispose", listener),
    true,
  )
}

///|
test "UniformsGroup removeEventListener drops one function" {
  let frame = @materials.UniformsGroup::new(name="Frame")
  let hits = Ref::Ref(0)
  let listener = fn() { hits.val = hits.val + 1 }
  let other = fn() {  }
  frame.add_event_listener("dispose", listener)
  frame.remove_event_listener("dispose", listener)
  assert_eq(frame.has_event_listener("dispose", listener), false)
  frame.dispose()
  assert_eq(hits.val, 0)
  frame.add_event_listener("dispose", listener)
  frame.remove_event_listener("change", listener)
  frame.remove_event_listener("dispose", other)
  frame.dispose()
  assert_eq(hits.val, 1)
  frame.remove_event_listener("dispose", listener)
  frame.dispose()
  assert_eq(hits.val, 1)
}

///|
test "UniformsGroup dispatchEvent runs listeners of one kind" {
  let frame = @materials.UniformsGroup::new(name="Frame")
  let hits = Ref::Ref(0)
  frame.add_event_listener("change", fn() { hits.val = hits.val + 1 })
  frame.add_event_listener("dispose", fn() { hits.val = hits.val + 10 })
  frame.dispatch_event("change")
  assert_eq(hits.val, 1)
  frame.dispatch_event("missing")
  assert_eq(hits.val, 1)
  frame.dispatch_event("dispose")
  assert_eq(hits.val, 11)
  let other = @materials.UniformsGroup::new(name="Other")
  other.dispatch_event("change")
  assert_eq(hits.val, 11)
}

///|
test "UniformsGroup clone keeps values and drops listeners" {
  let frame = @materials.UniformsGroup::new(name="Frame")
  ignore(frame.set_usage(35048))
  ignore(frame.add(1.0).add(2.0))
  let listener = fn() {  }
  frame.add_event_listener("dispose", listener)
  let cloned = frame.clone()
  assert_eq(cloned.name, "Frame")
  assert_eq(cloned.usage, 35048)
  assert_eq(cloned.uniforms, [1.0, 2.0])
  assert_eq(cloned.id == frame.id, false)
  assert_eq(cloned.has_event_listener("dispose", listener), false)
  assert_eq(frame.has_event_listener("dispose", listener), true)
  cloned.uniforms[0] = 9.0
  cloned.name = "Other"
  assert_eq(frame.uniforms[0], 1.0)
  assert_eq(frame.name, "Frame")
}

///|
test "UniformsGroup copy keeps id and listeners" {
  let frame = @materials.UniformsGroup::new(name="Frame")
  ignore(frame.set_usage(35048))
  ignore(frame.add(1.0).add(2.0))
  let source_listener = fn() {  }
  frame.add_event_listener("dispose", source_listener)
  let onto = @materials.UniformsGroup::new(name="Other")
  ignore(onto.add(9.0))
  let kept = onto.uniforms
  let dest_listener = fn() {  }
  onto.add_event_listener("change", dest_listener)
  let id = onto.id
  ignore(onto.copy(frame))
  assert_eq(onto.name, "Frame")
  assert_eq(onto.usage, 35048)
  assert_eq(onto.uniforms, [1.0, 2.0])
  assert_eq(kept, [1.0, 2.0])
  assert_eq(onto.id, id)
  assert_eq(onto.has_event_listener("change", dest_listener), true)
  assert_eq(onto.has_event_listener("dispose", source_listener), false)
  onto.uniforms[0] = 8.0
  onto.name = "Renamed"
  assert_eq(frame.uniforms[0], 1.0)
  assert_eq(frame.name, "Frame")
}
