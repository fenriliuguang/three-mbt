# materials

Not started. These items stay out of the active slice.

## Behavior

Environment maps and PMREM stay out. Standard shading is the direct Cook-Torrance term with no environment.

Built-in `ShaderLib` sources stay empty. `program_vertex_shader` and `program_fragment_shader` return nothing for built-in materials. Shader and Raw materials keep their own source strings.

The active `program_*` readers in [../active/materials.md](../active/materials.md) are separate functions. They are not one `getParameters` object, they are not written into the shader prefixes, and the renderer does not compile those strings.
