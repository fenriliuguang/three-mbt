# materials

Not started. These items stay out of the active slice.

## Behavior

Environment maps and PMREM stay out. Standard shading is the direct Cook-Torrance term with no environment.

GLSL `ShaderLib`, shader chunks, and `WebGLPrograms` parameter readers stay upstream. Do not add them. The rule is in `.cursor/skills/no-webgl/SKILL.md`.
