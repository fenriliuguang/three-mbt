# renderer

Not started. These items stay out of the active slice.

## Behavior

Additive, subtractive, and multiply blending stay out. Landed blending is source alpha over one-minus source alpha, plus premultiplied alpha.

VSM shadow maps stay out. The landed shadow is one directional `depth32float` map with a 3×3 comparison sample. The shadow pass does not use the VSM unflipped `shadowSide` default.

A half-float scene color target stays out. See [post.md](post.md).
