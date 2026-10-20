# renderer

Landed. Behavior notes are the phase log. The checklist is the upstream file map for this module.

## Phase

### 3. First frame of the world

A minimal `WebGPURenderer.render`: matrix updates, one opaque list, a depth buffer, unlit WGSL, vertex buffers, and an MVP uniform. `examples/cube` is a rotating cube. Frustum culling, sorting, and multi-pass wait.

This phase has landed. `WebGPURenderer` updates matrices, collects visible opaque meshes, uploads positions and indices, and draws them with one unlit WGSL program. The cube scene lives in `examples/cube`. The window sample is the wasm component built by `scripts/build-cube.sh`. The color pass drops a mesh, point, or line when `frustum_culled` is set and its bounding sphere misses the camera frustum. The sphere is computed on first use. `frustum_culled` false keeps the object. The shadow pass still draws every caster, but it uses the shadow camera's layers. A mesh, point, line, or light whose layer mask misses the camera is skipped. A wireframe mesh is drawn after the opaque list: each triangle becomes three edges, with the same material shader. An instanced wireframe uses the instanced shader and draws those edges once per instance. Its shadow uses the triangles, not the edges. Transparent meshes are drawn in phase 7.

## Behavior

Transparent meshes have landed. A mesh with `transparent` set is drawn after the opaque list, from far to near in view space. The camera looks down -Z, so a smaller view-space z is farther and is drawn first. Equal `render_order` and equal depth keep traverse order. Blending is source alpha over one-minus source alpha, and depth write stays on, matching r186's default material. Wireframe meshes are drawn as edges and stay out of both triangle lists. Transparent points and lines are sorted with the transparent meshes, far to near, and blended with source alpha over one-minus source alpha. Depth write stays on. `examples/blend` is an opaque Lambert cube behind one at opacity 0.5. The window sample is `scripts/build-blend.sh`. Host playback stays out of this pass.

`depthWrite` has landed. It defaults to true. A mesh, point, or line with it set to false uses a color pipeline that does not write depth. Blended and wireframe draws follow the same flag. The shadow pass still writes depth.

`depthTest` has landed. It defaults to true. A mesh, point, or line with it set to false uses a color pipeline whose depth compare is `always`, so the fragment passes the depth test. `depthWrite` stays independent, matching the WebGPU backend: the color pass still writes depth when that flag is on. The shadow pass still uses `less` and always writes depth.

`depthFunc` has landed. It defaults to `LessEqual`, matching r186. While `depthTest` is on, the color pipeline uses that compare: never, always, less, less-equal, equal, greater-equal, greater, or not-equal. Turning the test off still forces `always` and ignores the function. The shadow pass does not read it.

`colorWrite` has landed. It defaults to true. A mesh, point, or line with it set to false uses a color pipeline whose fragment write mask is empty, so the color target is unchanged. Depth test and depth write stay as set, which is how an invisible occluder is drawn. The shadow pass has no color target.

Opaque list culling uses that same instance sphere when `frustum_culled` is true. A point at the origin instanced at `x=-2` drops out of the unit-cube frustum, and the sphere is stored at `(-2, 0, 0)` with radius `0`. The same point instanced at `(0.5, 0.5, 0.5)` stays. The geometry sphere stays at the origin. Setting `frustum_culled` back to false keeps both. New instanced meshes still start with culling off.

Renderer material groups have landed. Two triangles with groups `(0, 3)` and `(3, 3)`, materials `0xFF0000` and `0x00FF00`, produce two opaque items and two shadow items. The first color is red `(1, 0)` and draws range `0` for `3`. The second is green `(0, 1)` and draws range `3` for `3`. An empty group list produces no item. Making the second material transparent leaves one opaque item and one transparent item. A material index past the array is skipped. A mesh without a material array still draws the whole geometry, with `group_count` `-1`. Wireframe groups stay later. `drawRange` intersection stays later.

Wireframe material groups have landed. The same two groups, with the first material wireframe and the second solid, put one red item on the wire list at range `0` for `3` and one green item on the opaque list at range `3` for `3`. An empty group list produces no wire item. Making the second material wireframe and transparent puts both items on the wire list and leaves the transparent list empty. The shadow list then keeps only the first group. A mesh without a material array and `wireframe` true still has `group_count` `-1`. The wire index draw multiplies that range by `2`. `drawRange` intersection stays later.

Material `visible` has landed. It defaults to true. A mesh, point, or line with it set to false stays out of the opaque, transparent, wireframe, and shadow lists. `Object3D.visible` still hides the whole subtree on its own.

`forceSinglePass` has landed. It defaults to false. A transparent double-sided mesh draws its back faces, then its front faces, in that order inside the same sorted slot. Setting it to true keeps the one double-sided draw. Opaque meshes and wireframes stay one draw. The normal uniform still uses the material side.

`shadowSide` has landed. It defaults to null. A null side flips the material side for the shadow pass: front draws back faces, back draws front faces, and double draws both. A set value is used as-is. The shadow map is not VSM, so that path's unflipped default stays out. Points and lines do not cast shadows.

`Object3D.render_order` is honored inside each color list. A lower value is drawn first. Opaque meshes, wireframe meshes, and opaque points and lines use that as their only sort key and keep traverse order on a tie. They are not sorted by depth. Transparent meshes and transparent points and lines compare `render_order` before view-space depth. The shadow list stays in traverse order. There is no `groupOrder`.

## Checklist

| status | phase | item | packages |
|---|---|---|---|
| planned | 3 | The Renderer, RenderList, RenderObject, Geometries, and Attributes subset of `src/renderers/common` | `renderer/common` |
| planned | 3 | The clear and draw path of `src/renderers/webgpu/WebGPURenderer.js` and `WebGPUBackend.js` | `renderer/webgpu` |
| planned | 3 | Hand-written unlit WGSL, with no single upstream file | `renderer/webgpu` |
| planned | 7 | opaque list culling uses the instanced bounding sphere | `renderer` |
| planned | 7 | renderer material groups | `renderer` |
| planned | 7 | wireframe material groups | `renderer` |
| planned | 7 | draw range intersection | `renderer` |
| planned | 7 | point and line draw ranges | `renderer` |
| planned | 7 | vertex colors multiplied into the base color | `renderer` |
| planned | 7 | view frustum culling by bounding sphere | `renderer` |
| planned | 7 | camera layers filter meshes, points, lines, and lights | `renderer` |
| planned | 7 | wireframe meshes drawn as triangle edges | `renderer` |
| planned | 7 | wireframe meshes cast triangle shadows | `renderer` |
| planned | 7 | instanced wireframe meshes drawn as triangle edges | `renderer` |
| planned | 7 | `renderOrder` before depth on transparent lists, and as the only key on opaque lists | `renderer` |
| planned | 7 | Half-float bloom intermediates | `renderer` |
