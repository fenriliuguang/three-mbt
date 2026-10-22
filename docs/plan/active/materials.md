# materials

The `WebGLPrograms` prefix and `getParameters` port has been removed. `WebGLProgram`, `WebGLPrograms`, and `WebGLShaderCache` are not in this repository. The renderer never compiled those strings.

Do not append another GLSL prefix paragraph here. A materials slice starts only after a new behavior note names work on the WebGPU path. WebGL and GLSL program work stays upstream. The rule is in `.cursor/skills/no-webgl/SKILL.md`.

## Behavior

Scene-graph material fields stay. That includes `ShaderMaterial` and `RawShaderMaterial` source strings. The renderer still shades those materials with the built-in WebGPU programs and does not compile the stored strings.

Standard environment maps and PMREM have landed. There is no current materials slice.

## Checklist

| status | phase | item | packages |
|---|---|---|---|
| excluded | 7 | `WebGLProgram` / `WebGLPrograms` / `WebGLShaderCache` / GLSL prefixes | None |
