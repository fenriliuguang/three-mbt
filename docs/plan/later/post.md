# post

Not started. These items stay out of the active slice.

## Behavior

`Custom` tone mapping stays out. The landed curves are in [../done/post.md](../done/post.md).

Half-float scene targets stay out. Bloom intermediates are already `rgba16float`. The scene target and the swapchain stay on the canvas format.

The node `RenderPipeline` stays out. The composer still draws with the hand-written fullscreen passes.

Masks on the effect composer stay out.

## Checklist

| status | phase | item | packages |
|---|---|---|---|
| later | 7 | Custom tone mapping, half-float scene targets, node `RenderPipeline` | `post` |
