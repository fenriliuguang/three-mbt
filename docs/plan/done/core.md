# core

Landed. Behavior notes are the phase log. The checklist is the upstream file map for this module.

## Behavior

Object3D local-axis `rotateOnAxis` and `translateOnAxis` have landed, with the X, Y, and Z helpers. The axis is assumed normalized. Rotation multiplies the quaternion on the right, so the bound Euler stays in step. Translation copies the axis, rotates it by the quaternion, and adds that offset to the position. `rotateY` by a right angle then `translateX(2)` lands at `(0, 0, -2)`.

`rotateOnWorldAxis` has landed. The axis is assumed normalized, and the parent is assumed not rotated. The turn is premultiplied, so it applies before the object's existing rotation. A right-angle yaw then a world-X quarter turn is `(0.5, 0.5, 0.5, 0.5)`. The same yaw then a local X quarter turn is `(0.5, 0.5, -0.5, 0.5)`.

`localToWorld` and `worldToLocal` have landed. Both update the world matrix from the parents first. Local to world multiplies by that matrix. World to local multiplies by a copy of its inverse, so the stored world matrix stays intact. A child at local `(0, 0, 4)` under a parent shifted by 10 and yawed by 0.5 turns local `(0, 0, 1)` into world `(12.397127693021, 0, 4.38791280945)`, and the reverse returns the local point.

`getWorldQuaternion`, `getWorldScale`, and `getWorldDirection` have landed. Each updates the world matrix from the parents first. The quaternion and scale come from decomposing that matrix. The direction is the matrix's third column, normalized, which is the object's positive Z axis in world space. A child with no local rotation copies its parent's quaternion. Parent scale `(2, 3, 4)` and child scale `(0.5, 2, 1)` multiply to `(1, 6, 4)`. The same yawed child used above looks along `(0.479425538604, 0, 0.87758256189)`.

`applyMatrix4` and `applyQuaternion` have landed. When `matrixAutoUpdate` is on, the matrix is composed from position, quaternion, and scale first. The given matrix is premultiplied, then decomposed back into those three. A yaw of a right angle applied to a point at `(1, 0, 0)` lands at `(0, 0, -1)` with quaternion `(0, 0.7071067811865476, 0, 0.7071067811865476)`. `applyQuaternion` premultiplies, so a local yaw then an X quarter turn is `(0.5, 0.5, 0.5, 0.5)`.

`setRotationFromAxisAngle`, `setRotationFromEuler`, `setRotationFromMatrix`, and `setRotationFromQuaternion` have landed. Each writes the quaternion, and the bound Euler follows. The axis and the quaternion are assumed normalized, and the matrix's upper 3×3 is assumed to be a pure rotation. An axis-angle yaw of a right angle is `(0, 0.7071067811865476, 0, 0.7071067811865476)`. Euler `(0.2, -0.4, 0.6)` matches the existing compose fixture, and copying that quaternion or its rotation matrix keeps both the quaternion and the Euler.

`attach` has landed. It adds the object as a child while keeping the world transform. The new local matrix is the new parent's inverse world matrix times the old parent's world matrix, applied with `applyMatrix4`. Non-uniform parent scale stays unsupported. A child at local x `1` under a parent at x `10`, attached to a parent at x `3`, keeps world x `11` and becomes local x `8`. A child at local `(0, 0, 4)` under a parent shifted by 10 and yawed by 0.5 keeps world `(11.9177021544, 0, 3.51033024756)` and takes that parent's quaternion when the new parent is the identity.

`traverseAncestors` has landed. It visits the parent first, then that parent's parent, and stops at the root. The node itself is not visited. A child under `parent` under `root` yields `parent`, then `root`. A node with no parent yields nothing. Changing the scene graph inside the callback stays unsupported.

`getObjectById` has landed. The search starts at the node itself, then walks children depth first, and returns the first match. A parent can find a grandchild. A child does not find its parent. An unknown id returns nothing. Dynamic property lookup stays out.

`copy` and `clone` have landed. `clone` keeps the node kind and assigns a new id. It copies the name, transform, Euler order, matrices, layer mask, visibility, shadow flags, frustum culling, render order, and a cloned pivot. Children are cloned by default and parented to the copy. `recursive` false copies only the node. Mesh bindings, cameras, lights, morphs, skins, listeners, and the parent pointer stay with the source. `static`, `animations`, and `userData` are not fields on this object.

`Vector3.fromBufferAttribute` has landed as `BufferAttribute.copy_to_vector3`, because `math` does not import `core`. It writes `getX`, `getY`, and `getZ` into the target vector. Index 1 of `[1, 2, 3, 4, 5, 6]` with item size 3 is `(4, 5, 6)`. Item size 4 skips the fourth component, so index 1 of `[1, 2, 3, 9, 4, 5, 6, 8]` is also `(4, 5, 6)`. The attribute is not modified.

`Vector2.fromBufferAttribute` has landed as `BufferAttribute.copy_to_vector2`, because `math` does not import `core`. It writes `getX` and `getY` into the target vector. Index 1 of `[1, 2, 3, 4, 5, 6]` with item size 2 is `(3, 4)`. Item size 3 skips the third component, so index 1 of the same array is `(4, 5)`. The attribute is not modified.

`Vector4.fromBufferAttribute` has landed as `BufferAttribute.copy_to_vector4`, because `math` does not import `core`. It writes x, y, z, and the fourth component into the target. Index 1 of `[1, 2, 3, 4, 5, 6, 7, 8]` with item size 4 is `(5, 6, 7, 8)`. Item size 3 still reads a fourth value, so index 0 of `[1, 2, 3, 4, 5, 6]` is `(1, 2, 3, 4)`. The attribute is not modified. `Vector4.random` stays out, because it draws from `Math.random`.

`Box3.setFromBufferAttribute` has landed as `BufferAttribute.set_box3`, because `math` does not import `core`. It empties the box, then expands it by each vertex. Item size 3 of `[1, 2, 3, 0, 5, 4]` becomes a box from `(0, 2, 3)` to `(1, 5, 4)`. Item size 4 still reads only xyz, so the fourth components `9` and `8` stay out of the box. An empty attribute leaves the box empty. The attribute is unchanged.

`Triangle.getInterpolatedAttribute` has landed on `BufferAttribute`. It reads three vertices and blends their xyz with the barycentric weights. For the attribute `[1, 0, 0, 0, 1, 0, 0, 0, 1]`, barycentric `(0, 0.5, 0.5)` writes `(0, 0.5, 0.5)`. The attribute and the weights are unchanged.

`Triangle.setFromAttributeAndIndices` has landed on `BufferAttribute`. It reads three indexed vertices into the corners. Indices `3`, `0`, and `1` on `[1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 0, 1]` store `(0, 0, 1)`, `(1, 2, 3)`, and `(4, 5, 6)`. The attribute is unchanged.

`Color.fromBufferAttribute` reads a `BufferAttribute`, so it stays with attributes. `Color.toJSON` has landed. It returns the sRGB hexadecimal integer. Linear black is `0`. `setHex(0x00FF00)` returns `65280`. Linear red `(1, 0, 0)` returns `16711680`. The color is unchanged.

`Frustum.intersectsObject` needs `Object3D`, and `Frustum.intersectsSprite` needs a sprite, so they stay later. `Frustum.intersectsBox` has landed. It rejects a box only when that box lies fully outside one plane. The unit-cube frustum accepts the box from `(0.25, 0.25, 0.25)` to `(0.75, 0.75, 0.75)` and rejects the box from `(-2, -2, -2)` to `(-1, -1, -1)`. The box and the frustum are unchanged.

`Color.fromBufferAttribute` has landed as `BufferAttribute.copy_to_color`, because `math` does not import `core`. It writes `getX`, `getY`, and `getZ` into the color and leaves those numbers as stored. Index 1 of `[1, 2, 3, 4, 5, 6]` with item size 3 is `(4, 5, 6)`. Item size 4 skips the fourth component, so index 1 of `[1, 2, 3, 9, 4, 5, 6, 8]` is also `(4, 5, 6)`. The attribute is not modified.

`Quaternion.fromBufferAttribute` has landed as `BufferAttribute.copy_to_quaternion`, because `math` does not import `core`. It writes x, y, z, and w and notifies once. Index 1 of `[1, 2, 3, 4, 5, 6, 7, 8]` with item size 4 is `(5, 6, 7, 8)`. Item size 3 still reads a fourth value, so index 0 of `[1, 2, 3, 4, 5, 6]` is `(1, 2, 3, 4)`. The attribute is not modified.

`Vector3.project` has landed as `Object3D.project_point`, because `math` does not import cameras. It multiplies by the view inverse, then by the projection. On the wide orthographic camera, world `(2, 1, -0.1)` becomes NDC `(1, 1, 0)`. The same NDC comes from `(12, 1, -0.1)` when the camera sits at x `10`. A node without a camera aborts.

`Vector3.unproject` has landed as `Object3D.unproject_point`. It multiplies by the inverse projection, then by the world matrix. On that same camera, NDC `(1, 1, 0)` returns world `(2, 1, -0.1)`. With the camera at x `10`, the same NDC returns `(12, 1, -0.1)`. A node without a camera aborts.

`BufferGeometry.deleteAttribute` has landed. Deleting `normal` leaves `position` y at `2` and index `1` at `1`. A missing name leaves `position` x at `1`. The index is not cleared.

`BufferGeometry.hasAttribute` has landed. An empty geometry does not have `position`. After that attribute is set, `position` is present and `normal` is not. An index does not count as an attribute named `index`. Deleting `position` makes the check false again.

`BufferGeometry.clearGroups` has landed. Two groups, the first with material index `1` and the second starting at `3` with count `6`, become an empty list. `position` stays in place.

`BufferGeometry.setDrawRange` has landed. A new geometry starts at `0` and counts to positive infinity. Setting the range to `1` and `4` stores those two numbers. The renderer still draws the full geometry.

`BufferAttribute.applyMatrix4` has landed. A translation of `(10, 0, 0)` moves `(1, 2, 3)` to `(11, 2, 3)` and `(4, 5, 6)` to `(14, 5, 6)`. It walks an attribute whose item size is `3`.

`BufferAttribute.applyMatrix3` has landed. A 2D translation of `(0.25, 0.5)` moves `(1, 2)` to `(1.25, 2.5)`. A scale of `(2, 3, 4)` moves `(1, 1, 1)` to `(2, 3, 4)`. An item size of `4` stays `(9, 8, 7, 6)`.

`BufferAttribute.applyNormalMatrix` has landed. A quarter turn in the xy plane takes `(2, 0, 0)` to `(0, 1, 0)` and `(0, 3, 0)` to `(-1, 0, 0)`, after normalizing.

`BufferAttribute.transformDirection` has landed. A translation of `(10, 0, 0)` leaves `(0, 0, 1)` unchanged. A scale of `(2, 1, 1)` turns `(1, 1, 0)` into about `(0.894427191, 0.447213595, 0)`.

`BufferGeometry.applyMatrix4` has landed. A scale of `(2, 1, 1)` moves position `(1, 2, 3)` to `(2, 2, 3)`. The normal `(1, 1, 0)` becomes about `(0.447213595, 0.894427191, 0)`. The tangent `(1, 1, 0)` becomes about `(0.894427191, 0.447213595, 0)`. `uv` stays `(0.25, 0.5)`. An existing bounding box and sphere are recomputed, so the single point's box and sphere center are `(2, 2, 3)` and the radius is `0`.

`BufferGeometry.applyQuaternion` has landed. A right-angle yaw around Y takes position `(1, 0, 0)` to about `(0, 0, -1)`. The quaternion is not modified.

`BufferGeometry.rotateX` has landed. A right-angle turn around X takes position `(0, 1, 0)` to about `(0, 0, 1)`.

`BufferGeometry.rotateY` has landed. A right-angle turn around Y takes position `(1, 0, 0)` to about `(0, 0, -1)`.

`BufferGeometry.rotateZ` has landed. A right-angle turn around Z takes position `(1, 0, 0)` to about `(0, 1, 0)`.

`BufferGeometry.translate` has landed. An offset of `(10, 0, 0)` moves position `(1, 2, 3)` to `(11, 2, 3)`.

`BufferGeometry.scale` has landed. A scale of `(2, 1, 1)` moves position `(1, 2, 3)` to `(2, 2, 3)`.

`BufferGeometry.lookAt` has landed. Aiming at `(1, 0, 0)` turns local `+Z` `(0, 0, 1)` to about `(1, 0, 0)`.

`BufferGeometry.center` has landed. Points `(0, 0, 0)` and `(2, 4, 6)` move to `(-1, -2, -3)` and `(1, 2, 3)`.

`BufferGeometry.setFromPoints` has landed for `Vector3`. Points `(1, 2, 3)` and `(4, 5, 6)` become a new `position` attribute. An existing one-vertex buffer keeps only the first point.

`BufferAttribute.setXYZW` has landed. Index `1` of a four-wide attribute becomes `(2, 3, 4, 5)`. The first vertex stays `(0, 0, 0, 0)`.

`BufferGeometry.computeTangents` has landed. An indexed triangle on the XY plane, with UVs `(0, 0)`, `(1, 0)`, `(0, 1)` and normals `(0, 0, 1)`, gets tangent `(1, 0, 0, 1)` at each vertex. A geometry that only has `position` is left unchanged.

`BufferGeometry.normalizeNormals` has landed. Normals `(2, 0, 0)` and `(0, 3, 0)` become `(1, 0, 0)` and `(0, 1, 0)`.

`BufferGeometry.computeVertexNormals` has landed. An indexed triangle `(0, 0, 0)`, `(1, 0, 0)`, `(0, 1, 0)` gets normal `(0, 0, 1)` at each vertex. The same triangle without an index does too.

`BufferGeometry.toNonIndexed` has landed. Index `[0, 2, 1]` expands positions `(0, 0, 0)`, `(1, 0, 0)`, `(0, 1, 0)` into `(0, 0, 0)`, `(0, 1, 0)`, `(1, 0, 0)`. The group is copied. A geometry that already has no index is returned as itself.

`BufferAttribute.toJSON` has landed. An attribute of item size `3`, values `[1, 2, 3]`, and `normalized` true serializes to those three fields. Changing the copied array leaves the attribute at `1`.

`BufferGeometry.toJSON` has landed. Metadata is version `4.7`, type `BufferGeometry`, generator `BufferGeometry.toJSON`. Position `[1, 2, 3]`, index `[0]`, group `(0, 3, material 1)`, and bounding sphere center `(1, 2, 3)` with radius `4` are recorded. Changing the copied position leaves the geometry at `1`.

`BufferAttribute.copy` has landed. Copying item size `3`, values `[1, 2, 3]`, and `normalized` true replaces a one-element destination. Changing the destination leaves the source at `1`.

`BufferAttribute.clone` has landed. Cloning item size `3`, values `[1, 2, 3]`, and `normalized` true makes a new attribute. Changing the clone leaves the source at `1`.

`BufferGeometry.copy` has landed. It copies position `[1, 2, 3]`, index `[0]`, a group with material `1`, a bounding sphere of radius `4`, and draw range `(2, 4)`. A previous `uv` attribute is cleared. Changing the copied position leaves the source at `1`.

`BufferAttribute.copyAt` has landed. Copying vertex `0` of `[1, 2, 3, 4, 5, 6]` onto vertex `1` of `[0, 0, 0, 9, 9, 9]` produces `[0, 0, 0, 1, 2, 3]`. The source stays `[1, 2, 3, 4, 5, 6]`.

`BufferAttribute.copyArray` has landed. Writing `[1, 2, 3]` into `[0, 0, 0, 9]` produces `[1, 2, 3, 9]`. Changing the source array leaves the attribute at `1`.

`BufferAttribute.set` has landed. Writing `[1, 2]` at offset `1` into `[0, 0, 0, 9]` produces `[0, 1, 2, 9]`. Changing the source array leaves the attribute at `1`.

`BufferAttribute.setComponent` has landed. Writing `9` into component `1` of `[1, 2, 3]` produces `[1, 9, 3]`.

`BufferAttribute.setX` has landed. Writing `9` into the x channel of `[1, 2, 3]` produces `[9, 2, 3]`.

`BufferAttribute.setY` has landed. Writing `9` into the y channel of `[1, 2, 3]` produces `[1, 9, 3]`.

`BufferAttribute.setZ` has landed. Writing `9` into the z channel of `[1, 2, 3]` produces `[1, 2, 9]`.

`BufferAttribute.getW` has landed. The fourth channel of `[1, 2, 3, 4]` is `4`.

`BufferAttribute.setW` has landed. Writing `9` into the w channel of `[1, 2, 3, 4]` produces `[1, 2, 3, 9]`.

`BufferAttribute.setXY` has landed. Writing `(1, 2)` into `[0, 0, 0]` produces `[1, 2, 0]`.

`BufferAttribute.needsUpdate` has landed. A new attribute starts at version `0`. Setting the flag false leaves it at `0`. Setting it true twice makes the version `2`.

`BufferAttribute.setUsage` has landed. A new attribute uses `StaticDrawUsage` `35044`. Setting `DynamicDrawUsage` stores `35048`, and copying the attribute carries that usage.

`BufferAttribute.addUpdateRange` has landed. A new attribute has no ranges. Adding start `1` and count `2` stores that one span.

`BufferAttribute.clearUpdateRanges` has landed. After adding start `1` and count `2`, clearing leaves no spans.

`BufferAttribute.onUpload` has landed. The stored callback runs once and increments a counter from `0` to `1`.

`BufferAttribute.addEventListener` has landed. Registering the same `dispose` listener twice leaves a single entry.

`BufferAttribute.dispose` has landed. A `dispose` listener adds `1` and another event's listener adds `10`, so the counter ends at `1`.

`BufferAttribute.hasEventListener` has landed. Before registration the check is false. After `addEventListener`, the same `dispose` listener checks true.

`BufferAttribute.removeEventListener` has landed. After removing the registered `dispose` listener, `hasEventListener` is false.

`BufferAttribute.dispatchEvent` has landed. Dispatching `change` adds `1`. A `dispose` listener that would add `10` stays quiet, so the counter ends at `1`.

`BufferGeometry.clone` has landed. It copies a tangent `[1, 0, 0, 1]`, index `[0]`, a group with material `1`, and draw range `(2, 4)`. Changing the clone's tangent leaves the source at `1`.

`BufferGeometry.addEventListener` has landed. Registering the same `dispose` listener twice leaves a single entry.

`BufferGeometry.hasEventListener` has landed. Before registration the check is false. After `addEventListener`, the same `dispose` listener checks true.

`BufferGeometry.removeEventListener` has landed. After removing the registered `dispose` listener, `hasEventListener` is false.

`BufferGeometry.dispatchEvent` has landed. Dispatching `change` adds `1`. A `dispose` listener that would add `10` stays quiet, so the counter ends at `1`.

`BufferGeometry.dispose` has landed. A `dispose` listener adds `1` and another event's listener adds `10`, so the counter ends at `1`.

`BufferAttribute.id` has landed. Two new attributes receive consecutive ids, and the second is greater by `1`. `copy` keeps the destination id.

`BufferAttribute.name` has landed. A new attribute is named `""`. Setting it to `tangent` and copying carries `tangent`.

`BufferAttribute.gpuType` has landed. A new attribute uses `FloatType` (`1015`). Setting it to `IntType` (`1013`) and copying carries `1013`.

`BufferGeometry.id` has landed. Two new geometries receive consecutive ids, and the second is greater by `1`. `copy` keeps the destination id.

`BufferGeometry.uuid` has landed. A new geometry's uuid is 36 characters and its version nibble is `4`. `copy` keeps the destination uuid.

`BufferGeometry.name` has landed. A new geometry is named `""`. Setting it to `square` and copying carries `square`.

`BufferGeometry.type` has landed. A new geometry's type is `BufferGeometry`. `copy` leaves a destination typed `SphereGeometry` unchanged when the source is `BoxGeometry`.

`BufferGeometry.setIndirect` has landed. A new geometry has no indirect attribute and offset `0`. Setting `[1, 2, 3, 4, 5]` with offset `16` stores that first component and the offset.

`BufferGeometry.getIndirect` has landed. Before `setIndirect` it is empty. After storing `[1, 2, 3, 4, 5]`, it returns that attribute and the first component is `1`.

`BufferGeometry.morphAttributes` has landed. A new geometry has no morph attributes. Copying a `position` target `[1, 2, 3]` drops a previous `normal` target. Changing the copy leaves the source at `1`.

`BufferGeometry.morphTargetsRelative` has landed. A new geometry is `false`. Setting it to `true` and copying carries `true`.

`BufferGeometry.userData` has landed. A new geometry has no `label`. Setting `label` to `square` and copying shares that map, so changing the copy to `cube` leaves the source at `cube`.

`BufferGeometry._transformed` has landed. A new geometry is `false`. `applyMatrix4` sets it to `true`, and copying carries `true`.

`BufferGeometry.getIndex` has landed. A new geometry has no index. After `setIndex` of `[0]`, the returned index starts at `0`.

`BufferAttribute.toJSON` now writes `name`, `usage`, and `gpuType`. A `tangent` attribute with `DynamicDrawUsage` (`35048`) and `IntType` (`1013`) keeps those three values.

`BufferGeometry.toJSON` now writes `uuid`, `name`, and `type`. A geometry named `square` with type `BoxGeometry` keeps that uuid, that name, and `BoxGeometry`, while the metadata type stays `BufferGeometry`. An empty `userData` is omitted. A `label` of `square` is included.

`BufferGeometry.applyMatrix4` now marks `position`, `normal`, and `tangent` as needing an update. Their `version` goes from `0` to `1`. A `uv` attribute stays at `0`.

`BufferGeometry.computeBoundingBox` now includes morph positions. A point at `(0, 0, 0)` with an absolute morph target at `(2, 0, 0)` has max x `2`. A point at `(1, 0, 0)` with a relative morph `(2, 0, 0)` has max x `5`.

`BufferGeometry.computeBoundingSphere` now includes morph positions. A point at `(1, 1, 0)` with absolute morphs `(0, 0, 0)` and `(2, 2, 0)` has radius `sqrt(2)`.

`BufferGeometry.toNonIndexed` now expands morph attributes. Index `[0, 2, 1]` turns morph values `[4, 5, 6]` into `[4, 6, 5]`. `morphTargetsRelative` set to `true` is kept. The source stays at `5`.

`BufferGeometry.toJSON` now writes morph attributes. A `position` target `[1, 2, 3]` with `morphTargetsRelative` set to `true` is included. A geometry without morph attributes omits them.

`BufferGeometry.setIndirect` now accepts several byte offsets. Offsets `[8, 24]` are stored with an attribute whose first component is `1`. Changing the source array leaves the first offset at `8`.

`Timer.update` has landed. The time origin is `0`. Updating at `1000` makes `getDelta` `1`. Updating at `2500` makes `getDelta` `1.5`.

`Timer.getElapsed` has landed. Updating at `1000` makes the elapsed time `1`. Updating at `2500` makes it `2.5`.

`Timer.getTimescale` has landed. A new timer's timescale is `1`.

`Timer.setTimescale` has landed. Setting the timescale to `2` and updating at `1000` makes `getDelta` `2`.

`Timer.reset` has landed. After an update at `1000`, resetting at `4000` and updating at `5000` makes `getDelta` `1`.

`InstancedBufferAttribute.meshPerAttribute` has landed on `BufferAttribute`. It defaults to `1`. Constructing with `2` and copying carries `2`.

`InstancedBufferAttribute.toJSON` has landed on `BufferAttribute.toJSON`. A repeat count of `1` omits both instance fields. A repeat count of `2` writes `meshPerAttribute` `2` and `isInstancedBufferAttribute` true.

`InstancedBufferGeometry.instanceCount` has landed on `BufferGeometry`. It defaults to positive infinity. Setting it to `4` and copying carries `4`.

`InstancedBufferGeometry.toJSON` has landed on `BufferGeometry.toJSON`. Positive infinity omits both instance fields. A count of `4` writes `instanceCount` `4` and `isInstancedBufferGeometry` true.

`InterleavedBuffer` has landed. An array `[1, 2, 3, 4, 5, 6]` with stride `3` has count `2`.

`InterleavedBuffer.setUsage` has landed. A new buffer is `StaticDrawUsage` (`35044`). `setUsage` of `DynamicDrawUsage` stores `35048`.

`InterleavedBuffer.addUpdateRange` has landed. A new buffer has no ranges. Adding start `1` and count `2` stores that one span.

`InterleavedBuffer.clearUpdateRanges` has landed. After adding start `1` and count `2`, clearing leaves no ranges.

`InterleavedBuffer.copy` has landed. Copying stride `3` and values `[1, 2, 3, 4, 5, 6]` onto `[9]` replaces the array, the stride, the count, and `DynamicDrawUsage` (`35048`). The destination keeps its own update range. Changing the copy leaves the source at `1`.

`InterleavedBuffer.copyAt` has landed. Vertex `0` of `[1, 2, 3, 4, 5, 6]` copied onto vertex `1` of `[0, 0, 0, 9, 9, 9]` becomes `[0, 0, 0, 1, 2, 3]`. The source stays at `1`.

`InterleavedBuffer.set` has landed. Writing `[1, 2]` at offset `1` into `[0, 0, 0, 9]` becomes `[0, 1, 2, 9]`.

`InterleavedBuffer.clone` has landed. Cloning stride `3`, values `[1, 2, 3, 4, 5, 6]`, and `DynamicDrawUsage` (`35048`) makes a new buffer. The clone has no update range. Changing the clone leaves the source at `1`.

`InterleavedBuffer.onUpload` has landed. Running the stored callback takes a counter from `0` to `1`.

`InterleavedBuffer.needsUpdate` has landed. A new buffer's version is `0`. Setting it false leaves `0`. Setting it true twice makes the version `2`.

`InterleavedBuffer.uuid` has landed. A new buffer's id has length `36` and version nibble `4`. `copy` keeps the destination id.

`InterleavedBuffer.toJSON` has landed. Stride `3`, values `[1, 2, 3, 4, 5, 6]`, and `DynamicDrawUsage` (`35048`) are written with the buffer's uuid. Changing the copied array leaves the buffer at `1`.

`InterleavedBufferAttribute` has landed. Item size `2` and offset `1` on a stride-`3` buffer of `[1, 2, 3, 4, 5, 6]` has count `2`. The name is empty and `normalized` is false.

`InterleavedBufferAttribute.array` has landed. Index `1` reads `2`. Writing `8` there changes the shared buffer to `8`.

`InterleavedBufferAttribute.needsUpdate` has landed. The attribute buffer's version starts at `0`. Setting it false leaves `0`. Setting it true twice makes the version `2`.

`InterleavedBufferAttribute.getX` has landed. On `[1, 2, 3, 4, 5, 6]` with stride `3`, index `1` at offset `0` is `4`, and index `0` at offset `1` is `2`.

`InterleavedBufferAttribute.setX` has landed. On `[0, 0, 0, 9, 9, 9]` with stride `3`, `setX(1, 4)` at offset `0` writes `4` at index `3`. The following value stays `9`.

`InterleavedBufferAttribute.setY` has landed. On the same buffer, `setY(1, 4)` at offset `0` writes `4` at index `4`. The values on either side stay `9`.

`InterleavedBufferAttribute.setZ` has landed. On `[0, 0, 0, 9, 9, 9]` with stride `3`, `setZ(1, 4)` at offset `0` writes `4` at index `5`. The preceding value stays `9`.

`InterleavedBufferAttribute.setW` has landed. On `[0, 0, 0, 0, 9, 9, 9, 9]` with stride `4`, `setW(1, 4)` at offset `0` writes `4` at index `7`. The preceding value stays `9`.

`InterleavedBufferAttribute.getY` has landed. On `[1, 2, 3, 4, 5, 6]` with stride `3`, index `1` at offset `0` is `5`, and index `0` at offset `1` is `3`.

`InterleavedBufferAttribute.getZ` has landed. On the same buffer, index `1` at offset `0` is `6`, and index `0` at offset `1` is `4`.

`InterleavedBufferAttribute.getW` has landed. On `[1, 2, 3, 4, 5, 6, 7, 8]` with stride `4`, index `1` at offset `0` is `8`, and index `0` at offset `1` is `5`.

`InterleavedBufferAttribute.setXY` has landed. On `[0, 0, 0, 9, 9, 9]` with stride `3`, `setXY(1, 1, 2)` at offset `0` writes `[0, 0, 0, 1, 2, 9]`.

`InterleavedBufferAttribute.setXYZ` has landed. On the same buffer, `setXYZ(1, 1, 2, 3)` at offset `0` writes `[0, 0, 0, 1, 2, 3]`.

`InterleavedBufferAttribute.setXYZW` has landed. On `[0, 0, 0, 0, 9, 9, 9, 9]` with stride `4`, `setXYZW(1, 1, 2, 3, 4)` at offset `0` writes `[0, 0, 0, 0, 1, 2, 3, 4]`.

`InterleavedBufferAttribute.applyMatrix4` has landed. Translating `[1, 2, 3, 4, 5, 6]` by `(10, 0, 0)` makes the vertices `(11, 2, 3)` and `(14, 5, 6)`.

`InterleavedBufferAttribute.applyNormalMatrix` has landed. A quarter turn sends `(2, 0, 0)` to `(0, 1, 0)` and `(0, 3, 0)` to `(-1, 0, 0)`.

`InterleavedBufferAttribute.transformDirection` has landed. Translating `(0, 0, 1)` by `(10, 0, 0)` leaves it at `(0, 0, 1)`.

`InterleavedBufferAttribute.getComponent` has landed. On `[1, 2, 3, 4, 5, 6]` with stride `3`, index `1` component `2` at offset `0` is `6`, and index `0` component `0` at offset `1` is `2`.

`InterleavedBufferAttribute.setComponent` has landed. On `[0, 0, 0, 9, 9, 9]` with stride `3`, `setComponent(1, 2, 4)` at offset `0` writes `4` at index `5`. The preceding value stays `9`.

`InterleavedBufferAttribute.clone` has landed. Item size `2` and offset `1` on `[1, 2, 3, 4, 5, 6]` with stride `3` becomes a `BufferAttribute` of `[2, 3, 5, 6]`. `normalized` true is kept. Changing the clone leaves the source at `2`.

`InterleavedBufferAttribute.toJSON` has landed. The same attribute serializes as item size `2`, `normalized` true, and array `[2, 3, 5, 6]`. Changing the copied array leaves the source at `2`.

`InstancedInterleavedBuffer.meshPerAttribute` has landed on `InterleavedBuffer`. It defaults to `1`. Constructing with `2` and copying carries `2`.

`InstancedInterleavedBuffer.toJSON` has landed on `InterleavedBuffer.toJSON`. A repeat count of `1` omits both instance fields. A repeat count of `2` writes `meshPerAttribute` `2` and `isInstancedInterleavedBuffer` true.

`Raycaster` has landed. A new raycaster starts at `(0, 0, 0)` and points along `(0, 0, -1)`, with `near` `0` and `far` positive infinity. Origin `(1, 2, 3)`, direction `(0, 1, 0)`, `near` `0.5`, and `far` `10` are stored. Changing the caller's origin leaves the ray at `1`.

`Raycaster.set` has landed. Setting origin `(1, 2, 3)` and direction `(0, 1, 0)` replaces the ray. Changing the caller's origin leaves the ray at `1`.

`Raycaster.setFromCamera` has landed. An orthographic camera with bounds `left=-2`, `right=2`, `top=1`, `bottom=-1`, `near=0.1`, and `far=10` aims NDC `(1, 1)` at origin `(2, 1, 0)` and direction `(0, 0, -1)`. Moving the camera to `x=10` aims the same NDC at `(12, 1, 0)` with the same direction. The raycaster stores that camera.

`Raycaster.layers` has landed. A new raycaster belongs to layer `0`, so the mask is `1`. `layers.set(1)` stores mask `2`.

`Raycaster.params` has landed. A new raycaster starts `Line.threshold` and `Points.threshold` at `1`. Setting them to `0.5` and `2` stores those values. `Mesh`, `LOD`, and `Sprite` stay empty.

`Object3D.raycast` has landed as the empty base method. It leaves the hit list empty and returns `None`, so a later traversal still visits children. `Some(false)` is the only result that stops them.

`Raycaster.intersectObject` has landed. It visits the object and its children when layers overlap, then sorts the hit list by distance. A list seeded with distances `2` and `1` comes back as `1` then `2`. The nearer point stays at `x=4`. The returned array is the one passed in. The empty base `raycast` adds nothing.

`Raycaster.intersectObjects` has landed. It visits each root, then sorts once. A list seeded with distances `3` and `1` across two roots comes back as `1` then `3`. The nearer point stays at `x=5`. The returned array is the one passed in.

`Mesh.getVertexPosition` has landed on `Object3D`. Index `1` of `[1, 2, 3, 4, 5, 6]` is `(4, 5, 6)`. A relative morph of `(2, 0, 0)` at weight `0.5` moves `(1, 2, 3)` to `(2, 2, 3)`.

`Mesh.raycast` has landed for a single material. A ray from `(0.25, 0.25, 1)` along `(0, 0, -1)` hits the triangle `(0, 0, 0)`, `(1, 0, 0)`, `(0, 1, 0)` at `(0.25, 0.25, 0)`, distance `1`. Material groups, `uv`, normals, and `face` stay out of this pass.

`Mesh.raycast` now records `face`, `faceIndex`, and `barycoord`. The same hit uses vertices `0`, `1`, `2`, face index `0`, material index `0`, normal `(0, 0, 1)`, and barycentric coordinates `(0.5, 0.25, 0.25)`.

`Triangle.getInterpolatedAttribute` has landed for a `Vector2` target on `BufferAttribute`. UVs `(0, 0)`, `(1, 0)`, and `(0, 1)` with barycentric coordinates `(0.5, 0.25, 0.25)` blend to `(0.25, 0.25)`.

`Mesh.raycast` now writes `uv` when the geometry has that attribute. The same triangle and ray store `(0.25, 0.25)`. A geometry without `uv` leaves the field empty.

`Mesh.raycast` now writes `uv1` the same way. UVs `(0, 1)`, `(1, 1)`, and `(0, 0)` on that ray store `(0.25, 0.75)`. A geometry without `uv1` leaves the field empty.

`Mesh.raycast` now writes an interpolated `normal`. Vertex normals `(0, 0, -1)` face the local ray, so the hit stores `(0, 0, 1)`. A geometry without `normal` leaves the field empty. The triangle `face.normal` stays the geometric normal.

`Line.raycast` has landed. A ray from `(0.5, 0.5, 0)` along `(0, -1, 0)` hits the segment from `(0, 0, 0)` to `(1, 0, 0)` at `(0.5, 0, 0)`, distance `0.5`, index `0`. The default line threshold is `1`. `LineSegments` uses the same test with a step of `2`.

`Points.raycast` has landed. A point at `(0.5, 0, 0)` and a ray from `(0, 0.5, 0)` along `(0, -1, 0)` meet the ray at `(0, 0, 0)`. The hit distance is `0.5` and `distanceToRay` is `0.5`. The default points threshold is `1`.

`Sprite.raycast` has landed. A perspective camera at the origin and a sprite at `(0, 0, -1)`, center `(0.5, 0.5)`, rotation `0`, and `sizeAttenuation` true, are hit by a ray from `(0.25, -0.25, 0)` along `(0, 0, -1)` at `(0.25, -0.25, -1)`. The distance is `1` and the uv is `(0.75, 0.25)`. A raycaster without a camera aborts. Sprite geometry, `count`, and the frustum test stay later.

`LOD.raycast` has landed. With `recursive` false, an empty LOD records nothing. A ray from `(0.25, 0.25, 1)` along `(0, 0, -1)` is farther than `0.5` from the LOD origin, so the second level is tested. That triangle hits `(0.25, 0.25, 0)` at distance `1`. `update` stays later.

`Object3D.intersectsFrustum` has landed for a mesh, point, or line geometry. A single point at `(0.5, 0.5, 0.5)` has sphere radius `0` and meets the unit-cube frustum. Moving the node by `(-2.5, 0, 0)` puts that sphere at `(-2, 0.5, 0.5)` and misses. A node without geometry misses. The stored sphere stays at the local point. Instanced bounds stay later.

`Object3D.intersectsFrustumArray` has landed. With `count` `0` the same point misses, including when a unit-cube frustum is already stored. `count` `1` accepts it. After the node moves by `(-2.5, 0, 0)` that one frustum misses, and a second frustum of constant `10` accepts it only once `count` is `2`.

`Object3D.intersectsFrustum` now uses the instanced bounding sphere when the mesh has instance data. A plain mesh of a point at the origin meets the unit-cube frustum. The same point instanced at `x=-2` misses, and the call stores the sphere at `(-2, 0, 0)` with radius `0` on the instance data. `computeBoundingSphere` returns that same sphere. The geometry sphere stays at the origin. Moving the instance to `(0.5, 0.5, 0.5)` and recomputing meets the frustum. With the instance back at the origin, moving the node by `(-2.5, 0, 0)` misses, and the stored sphere stays at the origin.

`InstancedMesh.raycast` has landed. A triangle `(0, 0, 0)`, `(1, 0, 0)`, `(0, 1, 0)` is drawn at the origin and at `x=2`. A ray from `(0.25, 0.25, 1)` along `(0, 0, -1)` hits `(0.25, 0.25, 0)` at distance `1`, instance `0`. A ray from `(2.25, 0.25, 1)` hits `(2.25, 0.25, 0)`, instance `1`. `matrixWorld` stays the identity. The geometry sphere stays centered at `(0.5, 0.5, 0)`. Moving both instances to `x=10` and `x=12` and recomputing misses. `count` `0` also misses.

`Object3D.uuid` has landed. A new node stores a 36-character version-4 id. Copying another node onto it leaves that id in place. Cloning a node named `box` keeps a 36-character version-4 uuid and the name `box`, and the numeric id is new.

`Object3D.raycast` calls `SkinnedMesh.raycast` when the mesh node carries that hook. The same triangle, after the bone moves to `y=5`, is hit through `intersect_object` at `(0.25, 5.25, 0)`, distance `1`. A clone keeps its own hook and reports the hit on the clone. A plain mesh has no hook, and the same ray misses its unskinned triangle. Material arrays in the triangle walk stay later.

Draw range intersection has landed. Six vertices with `setDrawRange(1, 4)` draw from `1` for `4`. The same range on an index of length `3` draws from `1` for `2`. Groups `(0, 3)` and `(3, 3)` with range `(2, 3)` draw `(2, 1)` and `(3, 2)` in both the opaque list and the shadow list. A range of `(10, 2)` produces no item. Those groups as wireframe draw wire indices `(4, 2)` and `(6, 4)`. A mesh with no position stays out of the list. A mesh whose range covers the whole geometry still has `group_count` `-1`. Points and lines stay later.

## Checklist

| status | phase | item | packages |
|---|---|---|---|
| planned | 2 | Object3D, BufferAttribute, BufferGeometry, Layers from `src/core`. EventDispatcher keeps the part the scene graph uses | `core` |
| planned | 7 | Object3D local `rotateOnAxis` and `translateOnAxis` | `core`, `math` |
| planned | 7 | Object3D `rotateOnWorldAxis` | `core` |
| planned | 7 | Object3D `localToWorld` and `worldToLocal` | `core` |
| planned | 7 | Object3D `getWorldQuaternion`, `getWorldScale`, and `getWorldDirection` | `core` |
| planned | 7 | Object3D `applyMatrix4` and `applyQuaternion` | `core` |
| planned | 7 | Object3D `setRotationFromAxisAngle`, `setRotationFromEuler`, `setRotationFromMatrix`, and `setRotationFromQuaternion` | `core` |
| planned | 7 | Object3D `attach` | `core` |
| planned | 7 | Object3D `traverseAncestors` | `core` |
| planned | 7 | Object3D `getObjectById` | `core` |
| planned | 7 | Object3D `copy` and `clone` | `core` |
| planned | 7 | Object3D `dispose` | `core` |
| planned | 7 | `Vector3.fromBufferAttribute` on `BufferAttribute` | `core` |
| planned | 7 | `Vector2.fromBufferAttribute` on `BufferAttribute` | `core` |
| planned | 7 | `Vector4.fromBufferAttribute` on `BufferAttribute` | `core` |
| planned | 7 | `Box3.setFromBufferAttribute` on `BufferAttribute` | `core` |
| planned | 7 | `Triangle.getInterpolatedAttribute` on `BufferAttribute` | `core` |
| planned | 7 | `Triangle.setFromAttributeAndIndices` on `BufferAttribute` | `core` |
| planned | 7 | `Color.fromBufferAttribute` on `BufferAttribute` | `core` |
| planned | 7 | `Quaternion.fromBufferAttribute` on `BufferAttribute` | `core` |
| planned | 7 | `Vector3.project` on `Object3D` | `core` |
| planned | 7 | `Vector3.unproject` on `Object3D` | `core` |
| planned | 7 | `BufferGeometry.deleteAttribute` | `core` |
| planned | 7 | `BufferGeometry.hasAttribute` | `core` |
| planned | 7 | `BufferGeometry.clearGroups` | `core` |
| planned | 7 | `BufferGeometry.setDrawRange` | `core` |
| planned | 7 | `BufferAttribute.applyMatrix4` | `core` |
| planned | 7 | `BufferAttribute.applyMatrix3` | `core` |
| planned | 7 | `BufferAttribute.applyNormalMatrix` | `core` |
| planned | 7 | `BufferAttribute.transformDirection` | `core` |
| planned | 7 | `BufferGeometry.applyMatrix4` | `core` |
| planned | 7 | `BufferGeometry.applyQuaternion` | `core` |
| planned | 7 | `BufferGeometry.rotateX` | `core` |
| planned | 7 | `BufferGeometry.rotateY` | `core` |
| planned | 7 | `BufferGeometry.rotateZ` | `core` |
| planned | 7 | `BufferGeometry.translate` | `core` |
| planned | 7 | `BufferGeometry.scale` | `core` |
| planned | 7 | `BufferGeometry.lookAt` | `core` |
| planned | 7 | `BufferGeometry.center` | `core` |
| planned | 7 | `BufferGeometry.setFromPoints` | `core` |
| planned | 7 | `BufferAttribute.setXYZW` | `core` |
| planned | 7 | `BufferGeometry.computeTangents` | `core` |
| planned | 7 | `BufferGeometry.normalizeNormals` | `core` |
| planned | 7 | `BufferGeometry.computeVertexNormals` | `core` |
| planned | 7 | `BufferGeometry.toNonIndexed` | `core` |
| planned | 7 | `BufferAttribute.toJSON` | `core` |
| planned | 7 | `BufferGeometry.toJSON` | `core` |
| planned | 7 | `BufferAttribute.copy` | `core` |
| planned | 7 | `BufferAttribute.clone` | `core` |
| planned | 7 | `BufferGeometry.copy` | `core` |
| planned | 7 | `BufferAttribute.copyAt` | `core` |
| planned | 7 | `BufferAttribute.copyArray` | `core` |
| planned | 7 | `BufferAttribute.set` | `core` |
| planned | 7 | `BufferAttribute.setComponent` | `core` |
| planned | 7 | `BufferAttribute.setX` | `core` |
| planned | 7 | `BufferAttribute.setY` | `core` |
| planned | 7 | `BufferAttribute.setZ` | `core` |
| planned | 7 | `BufferAttribute.getW` | `core` |
| planned | 7 | `BufferAttribute.setW` | `core` |
| planned | 7 | `BufferAttribute.setXY` | `core` |
| planned | 7 | `BufferAttribute.needsUpdate` | `core` |
| planned | 7 | `BufferAttribute.setUsage` | `core` |
| planned | 7 | `BufferAttribute.addUpdateRange` | `core` |
| planned | 7 | `BufferAttribute.clearUpdateRanges` | `core` |
| planned | 7 | `BufferAttribute.onUpload` | `core` |
| planned | 7 | `BufferAttribute.addEventListener` | `core` |
| planned | 7 | `BufferAttribute.dispose` | `core` |
| planned | 7 | `BufferAttribute.hasEventListener` | `core` |
| planned | 7 | `BufferAttribute.removeEventListener` | `core` |
| planned | 7 | `BufferAttribute.dispatchEvent` | `core` |
| planned | 7 | `BufferGeometry.clone` | `core` |
| planned | 7 | `BufferGeometry.addEventListener` | `core` |
| planned | 7 | `BufferGeometry.hasEventListener` | `core` |
| planned | 7 | `BufferGeometry.removeEventListener` | `core` |
| planned | 7 | `BufferGeometry.dispatchEvent` | `core` |
| planned | 7 | `BufferGeometry.dispose` | `core` |
| planned | 7 | `BufferAttribute.id` | `core` |
| planned | 7 | `BufferAttribute.name` | `core` |
| planned | 7 | `BufferAttribute.gpuType` | `core` |
| planned | 7 | `BufferGeometry.id` | `core` |
| planned | 7 | `BufferGeometry.uuid` | `core` |
| planned | 7 | `BufferGeometry.name` | `core` |
| planned | 7 | `BufferGeometry.type` | `core` |
| planned | 7 | `BufferGeometry.setIndirect` | `core` |
| planned | 7 | `BufferGeometry.getIndirect` | `core` |
| planned | 7 | `BufferGeometry.morphAttributes` | `core` |
| planned | 7 | `BufferGeometry.morphTargetsRelative` | `core` |
| planned | 7 | `BufferGeometry.userData` | `core` |
| planned | 7 | `BufferGeometry._transformed` | `core` |
| planned | 7 | `BufferGeometry.getIndex` | `core` |
| planned | 7 | `BufferAttribute.toJSON` name, usage, and gpuType | `core` |
| planned | 7 | `BufferGeometry.toJSON` uuid, name, type, and userData | `core` |
| planned | 7 | `BufferGeometry.applyMatrix4` needsUpdate | `core` |
| planned | 7 | `BufferGeometry.computeBoundingBox` morph positions | `core` |
| planned | 7 | `BufferGeometry.computeBoundingSphere` morph positions | `core` |
| planned | 7 | `BufferGeometry.toNonIndexed` morph attributes | `core` |
| planned | 7 | `BufferGeometry.toJSON` morph attributes | `core` |
| planned | 7 | `BufferGeometry.setIndirect` byte offsets | `core` |
| planned | 7 | `Timer.update` | `core` |
| planned | 7 | `Timer.getElapsed` | `core` |
| planned | 7 | `Timer.getTimescale` | `core` |
| planned | 7 | `Timer.setTimescale` | `core` |
| planned | 7 | `Timer.reset` | `core` |
| planned | 7 | `InstancedBufferAttribute.meshPerAttribute` | `core` |
| planned | 7 | `InstancedBufferAttribute.toJSON` | `core` |
| planned | 7 | `InstancedBufferGeometry.instanceCount` | `core` |
| planned | 7 | `InstancedBufferGeometry.toJSON` | `core` |
| planned | 7 | `InterleavedBuffer` | `core` |
| planned | 7 | `InterleavedBuffer.setUsage` | `core` |
| planned | 7 | `InterleavedBuffer.addUpdateRange` | `core` |
| planned | 7 | `InterleavedBuffer.clearUpdateRanges` | `core` |
| planned | 7 | `InterleavedBuffer.copy` | `core` |
| planned | 7 | `InterleavedBuffer.copyAt` | `core` |
| planned | 7 | `InterleavedBuffer.set` | `core` |
| planned | 7 | `InterleavedBuffer.clone` | `core` |
| planned | 7 | `InterleavedBuffer.onUpload` | `core` |
| planned | 7 | `InterleavedBuffer.needsUpdate` | `core` |
| planned | 7 | `InterleavedBuffer.uuid` | `core` |
| planned | 7 | `InterleavedBuffer.toJSON` | `core` |
| planned | 7 | `InterleavedBufferAttribute` | `core` |
| planned | 7 | `InterleavedBufferAttribute.array` | `core` |
| planned | 7 | `InterleavedBufferAttribute.needsUpdate` | `core` |
| planned | 7 | `InterleavedBufferAttribute.getX` | `core` |
| planned | 7 | `InterleavedBufferAttribute.setX` | `core` |
| planned | 7 | `InterleavedBufferAttribute.setY` | `core` |
| planned | 7 | `InterleavedBufferAttribute.setZ` | `core` |
| planned | 7 | `InterleavedBufferAttribute.setW` | `core` |
| planned | 7 | `InterleavedBufferAttribute.getY` | `core` |
| planned | 7 | `InterleavedBufferAttribute.getZ` | `core` |
| planned | 7 | `InterleavedBufferAttribute.getW` | `core` |
| planned | 7 | `InterleavedBufferAttribute.setXY` | `core` |
| planned | 7 | `InterleavedBufferAttribute.setXYZ` | `core` |
| planned | 7 | `InterleavedBufferAttribute.setXYZW` | `core` |
| planned | 7 | `InterleavedBufferAttribute.applyMatrix4` | `core` |
| planned | 7 | `InterleavedBufferAttribute.applyNormalMatrix` | `core` |
| planned | 7 | `InterleavedBufferAttribute.transformDirection` | `core` |
| planned | 7 | `InterleavedBufferAttribute.getComponent` | `core` |
| planned | 7 | `InterleavedBufferAttribute.setComponent` | `core` |
| planned | 7 | `InterleavedBufferAttribute.clone` | `core` |
| planned | 7 | `InterleavedBufferAttribute.toJSON` | `core` |
| planned | 7 | `InstancedInterleavedBuffer.meshPerAttribute` | `core` |
| planned | 7 | `InstancedInterleavedBuffer.toJSON` | `core` |
| planned | 7 | `Raycaster` | `core` |
| planned | 7 | `Raycaster.set` | `core` |
| planned | 7 | `Raycaster.setFromCamera` | `core` |
| planned | 7 | `Raycaster.layers` | `core` |
| planned | 7 | `Raycaster.params` | `core` |
| planned | 7 | `Object3D.raycast` | `core` |
| planned | 7 | `Raycaster.intersectObject` | `core` |
| planned | 7 | `Raycaster.intersectObjects` | `core` |
| planned | 7 | `Mesh.getVertexPosition` | `core` |
| planned | 7 | `Mesh.raycast` | `core` |
| planned | 7 | `Mesh.raycast` face | `core` |
| planned | 7 | `Triangle.getInterpolatedAttribute` for `Vector2` | `core` |
| planned | 7 | `Mesh.raycast` uv | `core` |
| planned | 7 | `Mesh.raycast` uv1 | `core` |
| planned | 7 | `Mesh.raycast` normal | `core` |
| planned | 7 | `Line.raycast` | `core` |
| planned | 7 | `Points.raycast` | `core` |
| planned | 7 | `Sprite.raycast` | `core` |
| planned | 7 | `LOD.raycast` | `core` |
| planned | 7 | `LineLoop` raycast | `core` |
| planned | 7 | `Object3D.intersectsFrustum` | `core` |
| planned | 7 | `Object3D.intersectsFrustumArray` | `core` |
| planned | 7 | `Object3D.intersectsFrustum` uses the instanced bounding sphere | `core` |
| planned | 7 | `InstancedMesh.raycast` | `core` |
| planned | 7 | `Object3D.uuid` | `core` |
| planned | 7 | `Object3D.raycast` skinned hook | `core`, `objects` |
| planned | 7 | mesh raycast material arrays | `core`, `objects` |
| planned | 7 | point and line raycast material indices | `core` |
| planned | 7 | glTF linear blend skinning on the CPU | `core`, `gltf`, `renderer` |
| planned | 7 | glTF morph displacements before CPU skinning | `core`, `gltf` |
| planned | 7 | glTF `JOINTS_1` and `WEIGHTS_1` on CPU skinning | `core`, `gltf` |
| planned | 7 | glTF `JOINTS_2` and `WEIGHTS_2` on CPU skinning | `core`, `gltf` |
| planned | 7 | glTF `JOINTS_3` and `WEIGHTS_3` on CPU skinning | `core`, `gltf` |
