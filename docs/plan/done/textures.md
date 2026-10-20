# textures

Landed. Behavior notes are the phase log. The checklist is the upstream file map for this module.

## Phase

### 5. Textures and window events

`rgba8` textures and samplers. `on-resize` rebuilds the swapchain. A sample uses `on-pointer-*` to move the camera. Input stays in the sample.

This phase has landed. `Texture` is width, height, and `rgba8` bytes. Materials can hold one map; both shaders sample it, and a missing map binds a 1×1 white texture. `examples/textured` is a Lambert cube with a checker map. Its component reads `on-resize` and asks the renderer to reconfigure the swapchain, and reads `on-pointer-*` to orbit the camera. The window sample is `scripts/build-textured.sh`. Host playback of that component stays out of this pass.

## Behavior

Render targets have landed. `RenderTarget` is a color texture plus a private `depth24plus` buffer. The color format is the preferred canvas format, so the mesh pipelines can draw into it. `set_render_target(None)` draws to the window and calls `present`. An active target skips the swapchain and `present`, and still draws when the window size is 0. The attachment keeps `flip_y` false, so the top of the picture is at v = 0. `examples/target` draws a Lambert cube into a 256×256 target, then a screen quad with flipped v. The window sample is `scripts/build-target.sh`. Host playback stays out of this pass.

`DataTexture` has landed for the float RGBA layout `Skeleton.computeBoneTexture` uses. A one-texel texture stores `[1, 0, 0, 1]`. Filters are nearest, `flipY` is false, mipmaps stay off, and `unpackAlignment` is `1`. `needsUpdate` starts false. Writing `0.25` into the source array changes the texture, and `dispose` leaves that `0.25` in place. Three bones whose update stored `3` at float `13` grow to a `4×4` texture. Float `13` is `3` in both the matrix buffer and the texture, and `needsUpdate` is true. Setting it false and calling `update` turns it true again, and float `13` stays `3`. A clone has no texture. Calling `computeBoneTexture` again keeps length `64` and shares the new buffer, so writing `9` into float `13` shows up in the texture. Dispose drops the texture and leaves float `13` at `3`. An empty skeleton grows a `4×4` texture of zeros. Seventeen bones grow a `12×12` texture, and a `4` written at the first float stays there. A float count that is not `width * height * 4` aborts. The instanced morph texture object stays later.

`InstancedMesh.morphTexture` has landed as a red-format `DataTexture`. `RedFormat` is `1028` and stores one float per texel. Count `2` and weights `[0.25, 0.5]` written to instance `1` allocate six zeros. The texture is width `3` and height `2`, and `needsUpdate` stays false. The fourth value is `0.25`. Copying shares that float array. The new texture has `needsUpdate` true, and writing `1` into its fourth value changes the source to `1`. The source `needsUpdate` stays false. Copying a mesh with no morph data leaves the `1`. A clone shares the same array, so setting its fourth value to `0` changes the source to `0`. Dispose drops the texture. A clone made first still reads `0.25` and `0.5`.

## Checklist

| status | phase | item | packages |
|---|---|---|---|
| planned | 5 | `src/textures/Texture.js` | `textures` |
| planned | 7 | RenderTarget | `textures`, `renderer` |
| planned | 7 | `DataTexture` for skeleton bone matrices | `textures`, `objects` |
| planned | 7 | `InstancedMesh.morphTexture` | `textures`, `objects` |
