# cameras

Landed. Behavior notes are the phase log. The checklist is the upstream file map for this module.

## Behavior

Perspective `zoom` and `filmOffset` have landed. `zoom` defaults to 1 and divides the vertical field, so 2 doubles the projection scale. `filmOffset` defaults to 0. A nonzero value shifts the frustum horizontally by `near * filmOffset / filmWidth`, where `filmWidth` is `filmGauge * min(aspect, 1)` and `filmGauge` defaults to 35. Orthographic `zoom` was already applied. View offset stays out.

Perspective focal length has landed. `filmGauge` still defaults to 35. Landscape film width is the gauge and the height is `gauge / aspect`. Portrait swaps that. `focalLength` is `0.5 * filmHeight / tan(fov / 2)`. `set_focal_length` writes `fov` from that and rebuilds the projection. `effectiveFOV` divides the half-angle tangent by `zoom`. View offset stays out.

Perspective `getViewBounds` and `getViewSize` have landed. At a distance along the view direction, the bounds are the NDC corners `(-1, -1, 0.5)` and `(1, 1, 0.5)` through the inverse projection, then scaled by `-distance / z`. The size is the width and height of that rectangle. `zoom` 2 halves both. A perspective view offset already in the projection is included.

Perspective `setViewOffset` has landed. It sets `aspect` to `fullWidth / fullHeight`, then shifts and scales the frustum by the sub-rectangle. The left half of a 16:9 frame doubles the horizontal scale and puts `-1` in the x offset term. `clearViewOffset` turns that sub-rectangle off and rebuilds the full frustum. Film offset is applied after the sub-rectangle.

Orthographic `setViewOffset` has landed. It does not change `aspect`. The scale is the frustum width and height divided by the full frame and by `zoom`. The left half of a frustum from `-2` to `2` and `-1` to `1` becomes `-2` to `0`, and the x translation term becomes `1`. `clearViewOffset` restores the full frustum.

`set_near` and `set_far` have landed on both cameras. They write the plane and rebuild the projection. Perspective keeps the same x and y scale, because the frustum height grows with `near`. Orthographic keeps the same x and y scale too. Only the depth terms change.

Orthographic `left`, `right`, `top`, and `bottom` setters have landed. Each one writes that edge and rebuilds the projection. From the default square, `left = -2` and `right = 2` with near `0.1` and far `10` match the existing wide frustum. Doubling `top` and `bottom` halves the vertical scale.

Perspective `set_film_gauge` has landed. The gauge still defaults to 35. Setting it to 70 doubles landscape film width and film height, and doubles the focal length at the same fov. A film offset of 3.5 then shifts the frustum by half as much, because the shift is `near * filmOffset / filmWidth`.

`ArrayCamera` has landed. It is a perspective camera with fov `50`, aspect `1`, near `0.1`, and far `2000`. A new array has no sub cameras. Passing one perspective camera of fov `40` stores that camera. `setFromArrayCamera` stays later.

`FrustumArray.setFromArrayCamera` has landed in `cameras`. Two perspective sub cameras, the second at `x=10`, store two frustums. Each frustum is `projectionMatrix * matrixWorldInverse` in that camera's coordinate system. The moved camera's first plane constant differs from the origin camera. Setting an empty array camera changes `count` to `0` and leaves the stored frustums in place.

## Checklist

| status | phase | item | packages |
|---|---|---|---|
| planned | 2 | Camera, PerspectiveCamera, OrthographicCamera from `src/cameras` | `cameras` |
| planned | 7 | perspective `zoom` and `filmOffset` | `cameras` |
| planned | 7 | perspective focal length, film width, and film height | `cameras` |
| planned | 7 | perspective view bounds and view size | `cameras` |
| planned | 7 | perspective `setViewOffset` and `clearViewOffset` | `cameras` |
| planned | 7 | orthographic `setViewOffset` and `clearViewOffset` | `cameras` |
| planned | 7 | `near` and `far` setters on both cameras | `cameras` |
| planned | 7 | orthographic `left`, `right`, `top`, and `bottom` setters | `cameras` |
| planned | 7 | perspective `filmGauge` setter | `cameras` |
| planned | 7 | `ArrayCamera` | `cameras` |
| planned | 7 | `FrustumArray.setFromArrayCamera` | `cameras` |
