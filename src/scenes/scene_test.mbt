///|
test "scene environment stores the texture" {
  let scene = @scenes.Scene::new()
  assert_eq(scene.environment is None, true)
  let map = @textures.Texture::from_rgba8(1, 1, FixedArray::make(4, b'\xFF'))
  scene.set_environment(Some(map))
  match scene.environment {
    None => assert_eq(false, true)
    Some(stored) => assert_eq(physical_equal(stored, map), true)
  }
  scene.set_environment(None)
  assert_eq(scene.environment is None, true)
}
