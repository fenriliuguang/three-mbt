# objects

Landed. Behavior notes are the phase log. The checklist is the upstream file map for this module.

## Behavior

Points and lines have landed. `PointsMaterial.size` is in pixels. When `sizeAttenuation` is set and the camera is perspective, the quad scales by `viewportHeight * 0.5 / -viewZ`, matching r186. WebGPU lines stay one pixel wide, as `Line` (strip) and `LineSegments` (list). `examples/points` draws both. The window sample is `scripts/build-points.sh`. Host playback stays out of this pass.

Instancing has landed. `InstancedMesh` stores column-major instance matrices and an optional per-instance color. The instance matrix is applied before the object matrix. A missing color is white. `count` can be lowered without reallocating. `compute_bounding_box` unions each transformed geometry box in local space. `examples/instanced` draws three Lambert cubes from one mesh. The window sample is `scripts/build-instanced.sh`. Host playback stays out of this pass.

`LOD.addLevel` has landed. Adding distances `10`, `0`, and `-5` stores levels at `0`, `5`, and `10`. The middle level keeps hysteresis `0.25`. The three objects stay children in the order they were added, and `autoUpdate` stays true. `removeLevel`, `getObjectForDistance`, `raycast`, and `update` stay later.

`LOD.removeLevel` has landed. From levels at `0`, `5`, and `10`, removing distance `5` leaves `0` and `10`, and that object leaves the children. Removing distance `7` returns false and leaves both lists unchanged. `getObjectForDistance`, `raycast`, and `update` stay later.

`LOD.getObjectForDistance` has landed. An empty LOD returns nothing. Levels at `0` and `10` with hysteresis `0.5` on the farther object use threshold `5` while that object is visible, so distance `4` returns the near object and distance `5` returns the far object. Hiding the far object keeps its threshold at `10`, so distance `8` returns the near object. `raycast` and `update` stay later.

`LOD.update` has landed. A camera at `(0, 0, 10)` with zoom `1` is distance `10` from an LOD at the origin. Levels at `0`, `10`, and `20` show the middle object, hide the other two, and store current level `1`. Zoom `2` makes the distance `5`, so only the near object stays visible and the current level is `0`. One level is left unchanged.

`LineLoop` raycast has landed. With the line threshold at `0`, a ray from `(0.5, 0.5, 1)` along `(0, 0, -1)` misses the open segments of `(0, 0, 0)`, `(1, 0, 0)`, `(1, 1, 0)`. The closing segment hits `(0.5, 0.5, 0)` at distance `1`, index `2`.

`Sprite.intersectsFrustum` has landed. It builds the sphere from `Frustum.intersectsSprite`: center at the sprite origin, radius `0.7071067811865476` plus the distance from `center` to `(0.5, 0.5)`, then applies `matrixWorld`. A sprite at `(0.5, 0.5, 0.5)` with the default center meets the unit-cube frustum. A sprite at `(-2, 0.5, 0.5)` does not. The sprite center and the frustum planes stay unchanged.

`Sprite.intersectsFrustumArray` has landed. A sprite at `(0.5, 0.5, 0.5)` with the default center misses while `count` is `0`, including when a unit-cube frustum is stored, and meets it once `count` is `1`. Moving the sprite to `(-2, 0.5, 0.5)` makes that frustum miss. A second frustum of constant `10` accepts it only once `count` is `2`.

`InstancedMesh.computeBoundingSphere` has landed. A point at the origin, drawn at the origin and at `x=2`, stores a sphere centered at `(1, 0, 0)` with radius `1`. The geometry sphere stays at the origin with radius `0`. `count` `1` keeps only the origin sphere. `count` `0`, and a geometry with no position, both leave an empty sphere of radius `-1`. Frustum tests still ignore this sphere.

`InstancedMesh.intersectsFrustum` has landed. A point at the origin, instanced at `x=-2`, misses the unit-cube frustum, and the call computes the sphere at `(-2, 0, 0)` with radius `0`. The geometry sphere stays at the origin. Moving that instance to `(0.5, 0.5, 0.5)` and recomputing meets the frustum. With the instance back at the origin, moving the node by `(-2.5, 0, 0)` misses, and the stored sphere stays at the origin. `Object3D.intersectsFrustum` still uses the geometry sphere.

`InstancedMesh.intersectsFrustumArray` has landed. A point at the origin, instanced at `(0.5, 0.5, 0.5)`, misses while `count` is `0`, including when a unit-cube frustum is stored, and the sphere stays uncomputed. `count` `1` meets that frustum and stores the sphere at `(0.5, 0.5, 0.5)` with radius `0`. Moving the instance to `(-2, 0.5, 0.5)` and recomputing makes that frustum miss. A second frustum of constant `10` accepts it only once `count` is `2`. The geometry sphere stays at the origin.

`InstancedMesh.copy` has landed. A point at the origin, with `count` `1`, instance translation `x=2`, and color `(0.25, 0.5, 1)`, copies onto another mesh. The node position `y=3`, frustum culling, and a child named `marker` come along. Geometry and material are the source objects. Before bounds exist, the destination sphere is cleared. After computing, the box is the point `(2, 0, 0)` and the sphere has radius `0`. Editing the copy's box, sphere, matrix, or color leaves the source unchanged. Morph textures stay later.

`InstancedMesh.clone` has landed. The same point, stored in a mesh of capacity `2` with `count` `1`, produces a new mesh. Capacity stays `2`, count stays `1`, the matrix translation stays `x=2`, and the color stays `(0.25, 0.5, 1)`. The node position is `y=3`, and the child named `marker` is a new node. Geometry is shared. The cloned sphere is centered at `(2, 0, 0)` with radius `0`, and setting that radius to `5` leaves the source radius at `0`. `recursive` false keeps the instance data and drops the child.

`LOD.copy` has landed. Levels at distance `0` and `10`, the farther one with hysteresis `0.25`, copy onto a LOD whose current level is `3`. The copy keeps current level `3`, sets `autoUpdate` false, and moves the node to `y=4`. The near clone is named `near` at `y=1`, and the far clone is named `far`. Both clones are new objects. Renaming the near clone leaves the source name `near`.

`LOD.clone` has landed. The same two levels, with `autoUpdate` false, current level `1`, and the node at `y=4`, produce a new LOD. Its current level is `0`. The near object is a new node named `near` at `y=1`, and the far object is a new node named `far` at distance `10` with hysteresis `0.25`. Renaming the far clone leaves the source name `far`. The source current level stays `1`.

`LOD.getCurrentLevel` has landed. A new LOD returns `0`. Levels at `0`, `10`, and `20` with a camera at `(0, 0, 10)` and zoom `1` return `1`. Zoom `2` makes the distance `5` and the level `0`.

`Sprite.geometry` has landed. Every sprite shares one quad. Positions are `(-0.5, -0.5, 0)`, `(0.5, -0.5, 0)`, `(0.5, 0.5, 0)`, and `(-0.5, 0.5, 0)`. Uvs are `(0, 0)`, `(1, 0)`, `(1, 1)`, and `(0, 1)`. The index is `0, 1, 2, 0, 2, 3`. `count` stays later.

`Sprite.count` has landed. A new sprite has count `1`. Setting it to `4` leaves another new sprite at `1`.

`Mesh.copy` has landed. A mesh whose position is a single point at `(0.5, 0, 0)`, with node position `y=3` and render order `4`, copies onto another mesh. Geometry and material are the source objects, and the node binding reads that same geometry. A child named `marker` is cloned. `recursive` false keeps the transform and geometry and drops the child. Morph weights stay later.

`Mesh.clone` has landed. The same point, node position `y=3`, and render order `4` produce a new mesh. Geometry and material are shared, and the node binding reads that geometry. The child named `marker` is a new node. `recursive` false drops the child and leaves the source child in place.

`Mesh.count` has landed. A new mesh has count `1`. Setting it to `4` leaves another new mesh at `1`.

`Mesh.updateMorphTargets` has landed. A new mesh with no morph attributes keeps influences and the dictionary empty. A position group with targets named `wide` and `tall` stores influences `[0, 0]` and maps those names to `0` and `1`. Replacing that group with an unnamed target maps `"0"` to `0` and resets the first weight to `0`. Setting the first weight to `0.5` leaves another new mesh at `0`. Assigning the geometry after construction leaves the dictionary empty until the call. Clearing the morph attributes and calling again keeps `"0"` at `0`. Copying weights stays later.

`Mesh.copy` now copies morph weights. A position group named `wide` and `tall`, with the first weight set to `0.5`, copies onto a mesh that had none. The copy stores `[0.5, 0]` and maps `wide` to `0` and `tall` to `1`. Setting the copy's first weight to `1` and `wide` to `9` leaves the source at `0.5` and `wide` at `0`. Copying a mesh with no morph data onto one whose first weight is `0.25` leaves that weight and `wide` at `0`. `Mesh.clone` uses the same copy, so the clone starts at `0.5`, and setting its first weight to `0` leaves the source at `0.5`.

`Points.copy` has landed. A point cloud whose position is a single point at `(0.5, 0, 0)`, with material size `2`, node position `y=3`, and render order `4`, copies onto another cloud whose material size was `8`. Geometry and material are the source objects, and the node binding reads that same geometry at size `2`. A child named `marker` is cloned. `recursive` false keeps the transform and geometry and drops the child.

`Points.clone` has landed. The same point, material size `2`, node position `y=3`, and render order `4` produce a new point cloud. Geometry and material are shared, and the node binding reads that geometry at size `2`. The child named `marker` is a new node. `recursive` false drops the child and leaves the source child in place.

`Line.copy` has landed. A line from `(0, 0, 0)` to `(1, 0, 0)`, with opacity `0.25`, node position `y=3`, and render order `4`, copies onto another line whose opacity was `1`. Geometry and material are the source objects, and the node binding reads that same geometry at opacity `0.25`. A child named `marker` is cloned. `recursive` false keeps the transform and geometry and drops the child.

`Line.clone` has landed. The same line, opacity `0.25`, node position `y=3`, and render order `4` produce a new line. Geometry and material are shared, and the node binding reads that geometry at opacity `0.25`. The child named `marker` is a new node. `recursive` false drops the child and leaves the source child in place.

`LineSegments.copy` has landed. `LineSegments` has no `copy` of its own; it follows `Line.copy`. A segment from `(0, 0, 0)` to `(1, 0, 0)`, with opacity `0.25`, node position `y=3`, and render order `4`, copies onto another segment whose opacity was `1`. Geometry and material are the source objects, and the node binding reads that same geometry at opacity `0.25`. A child named `marker` is cloned. `recursive` false keeps the transform and geometry and drops the child.

`LineSegments.clone` has landed. The same segment, opacity `0.25`, node position `y=3`, and render order `4` produce a new line segments object. Geometry and material are shared, and the node binding reads that geometry at opacity `0.25`. The child named `marker` is a new node. `recursive` false drops the child and leaves the source child in place.

`LineLoop.copy` has landed. `LineLoop` has no `copy` of its own; it follows `Line.copy`. A loop from `(0, 0, 0)` to `(1, 0, 0)`, with opacity `0.25`, node position `y=3`, and render order `4`, copies onto another loop whose opacity was `1`. Geometry and material are the source objects, and the node binding reads that same geometry at opacity `0.25`. A child named `marker` is cloned. `recursive` false keeps the transform and geometry and drops the child.

`LineLoop.clone` has landed. The same loop, opacity `0.25`, node position `y=3`, and render order `4` produce a new line loop. Geometry and material are shared, and the node binding reads that geometry at opacity `0.25`. The child named `marker` is a new node. `recursive` false drops the child and leaves the source child in place.

`Sprite.copy` has landed. A sprite with center `(0.25, 0.75)`, material rotation `0.5`, size attenuation off, count `4`, node position `y=3`, and render order `4` copies onto a sprite whose center was `(0.5, 0.5)` and whose count was `1`. The material is the source object. The center values are copied into the destination vector, and setting that vector's x to `0.1` leaves the source at `0.25`. The node sprite state reads rotation `0.5` and the same center. Count stays `1`. Geometry stays the shared quad. A child named `marker` is cloned. `recursive` false keeps the transform and center and drops the child.

`Sprite.clone` has landed. The same sprite produces a new sprite. The material is shared, and the center is `(0.25, 0.75)` on a new vector. Setting the clone's x to `0.1` leaves the source at `0.25`. The node sprite state reads rotation `0.5` and that center. Count stays `1` while the source stays at `4`. Geometry stays the shared quad. The child named `marker` is a new node. `recursive` false drops the child and leaves the source child in place.

`Line.computeLineDistances` has landed. Vertices at `(0, 0, 0)`, `(3, 0, 0)`, and `(0, 4, 0)` store `lineDistance` values `0`, `3`, and `8`. The call returns the same line. An indexed geometry is left unchanged, so `lineDistance` stays absent. `LineSegments` stays later.

`LineSegments.computeLineDistances` has landed. Pairs `(0, 0, 0)` to `(3, 0, 0)` and `(0, 0, 0)` to `(0, 4, 0)` store `lineDistance` values `0`, `3`, `3`, and `7`. The second pair starts where the first pair ended. The call returns the same line segments. An indexed geometry is left unchanged, so `lineDistance` stays absent.

`LineLoop.computeLineDistances` has landed. `LineLoop` has no method of its own; it follows `Line`. Vertices at `(0, 0, 0)`, `(3, 0, 0)`, and `(0, 4, 0)` store `lineDistance` values `0`, `3`, and `8`. The closing edge back to the first vertex is not included. The call returns the same line loop. An indexed geometry is left unchanged, so `lineDistance` stays absent.

`Points.updateMorphTargets` has landed. A new point cloud with no morph attributes keeps influences and the dictionary empty. A position group with targets named `wide` and `tall` stores influences `[0, 0]` and maps those names to `0` and `1`. Setting the first weight to `0.5` leaves another new point cloud at `0`. Assigning the geometry after construction leaves the dictionary empty until the call. Replacing that group with an unnamed target maps `"0"` to `0`. Clearing the morph attributes and calling again keeps `"0"` at `0`. Copying weights stays later.

`Line.updateMorphTargets` has landed. A new line with no morph attributes keeps influences and the dictionary empty. A position group with targets named `wide` and `tall` stores influences `[0, 0]` and maps those names to `0` and `1`. Setting the first weight to `0.5` leaves another new line at `0`. Assigning the geometry after construction leaves the dictionary empty until the call. Replacing that group with an unnamed target maps `"0"` to `0`. Clearing the morph attributes and calling again keeps `"0"` at `0`. `LineSegments` and `LineLoop` stay later.

`LineSegments.updateMorphTargets` has landed. `LineSegments` has no method of its own; it follows `Line`. A new line segments object with no morph attributes keeps influences and the dictionary empty. A position group with targets named `wide` and `tall` stores influences `[0, 0]` and maps those names to `0` and `1`. Setting the first weight to `0.5` leaves another new line segments object at `0`. Assigning the geometry after construction leaves the dictionary empty until the call. Replacing that group with an unnamed target maps `"0"` to `0`. Clearing the morph attributes and calling again keeps `"0"` at `0`. `LineLoop` stays later.

`LineLoop.updateMorphTargets` has landed. `LineLoop` has no method of its own; it follows `Line`. A new line loop with no morph attributes keeps influences and the dictionary empty. A position group with targets named `wide` and `tall` stores influences `[0, 0]` and maps those names to `0` and `1`. Setting the first weight to `0.5` leaves another new line loop at `0`. Assigning the geometry after construction leaves the dictionary empty until the call. Replacing that group with an unnamed target maps `"0"` to `0`. Clearing the morph attributes and calling again keeps `"0"` at `0`.

`InstancedMesh.setMorphAt` has landed. A mesh of count `2` starts with no morph data. Weights `[0.25, 0.5]` written to instance `1` allocate six zeros and store `[0, 0, 0, 0.25, 0.25, 0.5]`. The base influence is `1 - 0.75`. Turning `morphTargetsRelative` on and writing instance `0` keeps that length and stores `[1, 0.25, 0.5, 0.25, 0.25, 0.5]`. The value is the `DataTexture` float buffer. The texture object, `getMorphAt`, and copying the buffer stay later.

`InstancedMesh.getMorphAt` has landed. The same buffer is read into a mesh whose weights started at `[9, 9]`. Instance `1` becomes `[0.25, 0.5]`. Instance `0` also becomes `[0.25, 0.5]`, and the stored base `1` stays in the buffer. The source mesh stays at `[0.25, 0.5]`. The texture object and copying the buffer stay later.

`InstancedMesh.copy` now copies the morph buffer. Instance `1` with weights `[0.25, 0.5]` stores `[0, 0, 0, 0.25, 0.25, 0.5]`. The copy has those six values. Setting the copy's fourth value to `1` leaves the source at `0.25`. Copying a mesh with no morph data onto that copy leaves the `1` in place. `InstancedMesh.clone` uses the same copy, so the clone's fourth value starts at `0.25`, and setting it to `0` leaves the source at `0.25`. The texture object stays later.

`InstancedMesh.dispose` has landed. Instance `1` with weights `[0.25, 0.5]` stores `0.25` at the fourth buffer value. Dispose emits one `dispose` event and clears that buffer. A clone made first still has `0.25` and `0.5` at the fourth and sixth values. A mesh with no morph data stays empty after dispose.

`InstancedMesh.updateMorphTargets` has landed. It does nothing. A count `2` mesh whose geometry has position targets named `wide` and `tall` keeps an empty morph buffer, while a plain mesh maps `wide` to `0`. After writing weights `[0.25, 0.5]` to instance `1`, the call leaves the six values in place, including `0.25`, `0.25`, and `0.5` at the end.

`Group.copy` has landed. `Group` has no `copy` of its own; it follows `Object3D.copy`. A group at `y=3` with render order `4` and a child named `marker` copies onto a group that was at `x=1`. The destination moves to `y=3` with `x` `0`, and the child is a new node. `recursive` false keeps the transform and drops the child. The source child stays in place.

`Group.clone` has landed. The same group produces a new group at `y=3` with render order `4` and `x` `0`. The child named `marker` is a new node. `recursive` false drops the child and leaves the source child in place.

`Bone` has landed. A root bone adds a child bone, and that child sits at `y=5`. Both nodes have kind `Bone`. The child is the root's only child. `copy` and `clone` stay later.

`Bone.copy` has landed. `Bone` has no `copy` of its own; it follows `Object3D.copy`. A bone at `y=3` with render order `4` and a child bone named `marker` copies onto a bone that was at `x=1`. The destination moves to `y=3` with `x` `0`, and the child is a new bone. `recursive` false keeps the transform and drops the child. The source child stays in place. `clone` stays later.

`Bone.clone` has landed. The same bone produces a new bone at `y=3` with render order `4` and `x` `0`. The child bone named `marker` is a new bone. `recursive` false drops the child and leaves the source child in place.

`Skeleton` has landed. A shoulder at local `y=-5`, an elbow at `0`, and a hand at `5` are copied into the skeleton after their world matrices update. The shoulder and elbow inverses translate by `y=5`, and the hand inverse is identity. The bone matrix buffer holds 48 zeros. Moving the shoulder to `y=-2` and calculating again stores inverses at `y=2`, `y=2`, and `y=-3`. An empty skeleton has no bones, no inverses, and an empty buffer. A caller-supplied inverse list of the same length is kept. A list of the wrong length is replaced by one identity matrix per bone, and the supplied matrix stays at translation `y=9`. `pose`, `update`, and the bone texture stay later.

`Skeleton.pose` has landed. The same chain is moved so the shoulder sits at `y=-2`, then pose restores local positions `-5`, `0`, and `5`. The world translations are `y=-5`, `y=-5`, and `0`. The shoulder quaternion stays identity and the scales stay `1`. The stored inverses stay at `y=5`. A bone at local `y=5` under a group at `y=10` becomes local `y=15`, because that parent is not a bone. An empty skeleton stays empty. `update` and the bone texture stay later.

`Skeleton.update` has landed. At the bind pose the 48-float buffer holds three identity matrices. Moving the shoulder to `y=-2` writes translation `y=3` into each matrix, at floats `13`, `29`, and `45`. The shoulder position stays `-2`. An empty skeleton keeps an empty buffer. The bone texture stays later.

`Skeleton.clone` has landed. The same chain, after that update has stored `3` at float `13`, clones to a new skeleton. The bones array is new and still holds the shoulder and the hand. Pushing another bone leaves the source at length `3`. The inverse matrices are the same array, so writing translation `y=7` into the clone's first inverse changes the source too. The clone's matrix buffer is 48 zeros, and the source float `13` stays `3`. An empty skeleton clones to an empty skeleton that shares its inverse list. The bone texture stays later.

`Skeleton.getBoneByName` has landed. A shoulder named `shoulder` at `y=-5`, an elbow named `elbow` at `y=0`, and an unnamed hand at `y=5` are searched by name. `elbow` returns the elbow, and `""` returns the hand. Naming the hand `elbow` as well still returns the first elbow. `wrist` and an empty skeleton return nothing. The bone texture stays later.

`Skeleton.computeBoneTexture` has landed for the float layout. Three bones whose update stored `3` at float `13` grow from 48 floats to 64. Float `13` stays `3`, and floats `48` and `63` are `0`. Calling it again keeps that length and the `3`. An empty skeleton grows from nothing to 64 zeros. Seventeen bones grow from 272 floats to 576, and a `4` written at the first float stays there. A buffer longer than the layout aborts. The `DataTexture` object stays later.

`Skeleton.dispose` has landed. The same three-bone buffer, grown to 64 floats with `3` at float `13`, stays at that length after dispose. Float `63` stays `0`, the three bones stay, and the shoulder stays at `y=-2`. An empty skeleton stays empty. The `DataTexture` object stays later.

`Skeleton.toJSON` has landed. The shoulder, elbow, and hand chain writes version `4.7`, type `Skeleton`, and generator `Skeleton.toJSON`. The skeleton uuid is its own. The bone list is the shoulder, elbow, and hand uuids. The shoulder and elbow inverses translate by `y=5`, and the hand inverse is identity. Writing `9` into the serialized shoulder inverse leaves the stored matrix at `y=5`. An empty skeleton writes two empty lists. `fromJSON` stays later.

`Skeleton.fromJSON` has landed. That serialized chain, loaded into an empty skeleton with the three bones looked up by uuid, restores the skeleton uuid, the same three bones, inverses at `y=5`, `y=5`, and identity, and a 48-zero matrix buffer. Loading it again appends three more bones and the buffer becomes 96 zeros. A bone uuid `missing` creates a new bone, stores an identity inverse, and sets the skeleton uuid to `skeleton-id`.

`SkinnedMesh` has landed. A geometry point at `(0.5, 0, 0)` is kept on the inner mesh, whose count is `1` and whose node kind is `Mesh`. `bindMode` starts attached and can be set to detached. Both bind matrices are identity. The bounding box, bounding sphere, and skeleton are empty. `bind` stays later.

`SkinnedMesh.bind` has landed. A bind matrix translating by `y=4` is copied in, and its inverse translates by `y=-4`. The supplied matrix stays at `y=4`, and the bone inverse stays `0`. Binding without a matrix updates the mesh at `y=3`, recalculates the bone that moved from `y=-5` to `y=-2`, and stores inverse `y=2`. The bind matrix translates by `y=3` and its inverse by `y=-3`. Moving the mesh to `y=9` leaves the stored bind matrix at `y=3`.

`SkinnedMesh.pose` has landed. A shoulder at `y=-5`, an elbow at `0`, and a hand at `5` are bound with an identity matrix, then the shoulder moves to `y=-2`. Pose restores local positions `-5`, `0`, and `5`. The shoulder world translation is `y=-5`, the hand world translation is `0`, and the stored inverse stays at `y=5`. Posing without a skeleton aborts.

`SkinnedMesh.normalizeSkinWeights` has landed. Four weights `(2, 0, 0, 2)`, `(0, 0, 0, 0)`, `(-2, 2, 0, 0)`, and `(1, 1, 1, 1)` become `(0.5, 0, 0, 0.5)`, `(1, 0, 0, 0)`, `(-0.5, 0.5, 0, 0)`, and `(0.25, 0.25, 0.25, 0.25)`. The attribute is the same object. A mesh without `skinWeight` aborts.

`SkinnedMesh.updateMatrixWorld` has landed. A mesh at `y=3` in attached mode stores world translation `y=3` and an inverse bind translation of `y=-3`. The bind matrix stays identity. Switching to detached mode with a bind translation of `y=4` and moving the mesh to `y=9` keeps the world translation at `y=9` and writes the inverse bind translation `y=-4`.

`SkinnedMesh.applyBoneTransform` has landed for a `Vector3`. A point `(1, 0, 0)` with weight `1` on a bone that moved to `y=5` becomes `(1, 5, 0)`. The unused index `99` has weight `0` and is skipped. A zero point with weights `0.25` and `0.75` on bones at `y=5` and `x=4` becomes `(3, 1.25, 0)`. The bind matrix is identity. Calling it without a skeleton aborts. The `Vector4` target stays later.

`SkinnedMesh.applyBoneTransform` has landed for a `Vector4`. A point `(1, 0, 0, 1)` with weight `1` on a bone that moved to `y=5` becomes `(1, 5, 0, 1)`. A direction `(1, 0, 0, 0)` on that bone stays `(1, 0, 0, 0)`. A vector `(0, 0, 0, 2)` with weight `0.5` on an unmoved bone stays `(0, 0, 0, 2)`, because the blended `w` is written back to the value after the bind matrix. The bind matrix is identity. Calling it without a skeleton aborts. `computeBoundingBox` stays later.

`SkinnedMesh.getVertexPosition` has landed. A vertex `(1, 2, 3)` with weight `1` on a bone that moved to `y=5` becomes `(1, 7, 3)`. A relative morph `(2, 0, 0)` at weight `0.5` then becomes `(2, 7, 3)`. The bind matrix is identity. Calling it without a skeleton aborts. `computeBoundingBox` stays later.

`SkinnedMesh.computeBoundingBox` has landed. Vertices `(1, 0, 0)` and `(0, 4, 0)` with weight `1` on a bone that moved to `y=5` produce a box from `(0, 5, 0)` to `(1, 9, 0)`. Moving the bone to `y=1` and computing again writes `(0, 1, 0)` to `(1, 5, 0)` into the same box. An empty position attribute leaves the box empty. A mesh without `position` aborts. `computeBoundingSphere` stays later.

`SkinnedMesh.computeBoundingSphere` has landed. Vertices `(1, 0, 0)` and `(-1, 0, 0)` with weight `1` on a bone that moved to `y=5` produce a sphere centered at `(0, 5, 0)` with radius `1`. Moving the bone to `y=1` and computing again writes center `(0, 1, 0)` and radius `1` into the same sphere. An empty position attribute leaves the sphere empty, with radius `-1`. A mesh without `position` aborts. `copy` stays later.

`SkinnedMesh.copy` has landed. A mesh at `y=3` with render order `4`, a detached bind translation of `y=4`, and an inverse of `y=-4` copies onto a mesh that started at `x=1`. The destination ends at `y=3` and `x=0`, shares the geometry, material, and skeleton, and keeps a cloned box from `y=5` to `y=9` plus a cloned sphere of radius `1`. Writing `7` into the clone's minimum leaves the source at `5`. `recursive=false` drops the child named `marker`. A source without bounds leaves the destination's box at `y=9` and its sphere radius at `8`, and clears a skeleton the destination already held. `clone` stays later.

`SkinnedMesh.clone` has landed. The same mesh, with a child named `marker`, a detached bind translation of `y=4`, and a box from `y=5` to `y=9`, clones to a new mesh at `y=3` and `x=0`. The numeric id is new. The geometry, material, and skeleton are shared. Writing `7` into the cloned box minimum leaves the source at `5`. The cloned sphere stays centered at `y=5` with radius `1`. `recursive=false` drops the child, and the source child stays. `raycast` stays later.

`SkinnedMesh.raycast` has landed. A triangle `(0, 0, 0)`, `(1, 0, 0)`, `(0, 1, 0)` with weight `1` is hit by a ray from `(0.25, 0.25, 1)` toward `-z` at `(0.25, 0.25, 0)`, distance `1`. The barycentric weights are `0.5`, `0.25`, and `0.25`. Moving the bone to `y=5` moves the hit to `(0.25, 5.25, 0)`. A local box from `(10, 10, 10)` to `(11, 11, 11)` rejects that ray. A ray from `(0, 100, 1)` misses the skinned sphere. `Object3D.raycast` still uses the unskinned mesh path.

Mesh raycast material arrays have landed. Two triangles and an empty group list produce no hit. Groups `(0, 3)` at material `0` and `(3, 3)` at material `1`, with sides front and back, hit `(0.25, 0.25, 0)` at material index `0` and miss the second triangle. Switching the second side to front hits `(5.25, 0.25, 0)` at material index `1` and face index `1`. Copying the mesh keeps a new list of length `2`. A draw range starting at `3` with count `3` keeps only the second triangle, at material index `0`. An out-of-range material index aborts. Instanced and skinned material arrays stay later.

Instanced mesh raycast material arrays have landed. Two instances of one triangle, with the second translated by `x=2`, produce no hit while the group list is empty. A group `(0, 3)` at material `1` then hits `(0.25, 0.25, 0)` on instance `0` and `(2.25, 0.25, 0)` on instance `1`, both at material index `1` and distance `1`. Copying the mesh keeps a new list of length `2`. An out-of-range material index aborts. Skinned material arrays stay later.

Skinned mesh raycast material arrays have landed. A triangle with weight `1` on a bone that moved to `y=5` produces no hit while the group list is empty. A group `(0, 3)` at material `1` then hits `(0.25, 5.25, 0)`, distance `1`, material index `1`. Cloning keeps a new list of length `2`. An out-of-range material index aborts. The renderer still draws the single `material` and ignores the array.

Point and line draw ranges have landed. Four vertices start with `draw_count` `-1`. `setDrawRange(1, 2)` draws the points and the line from `1` for `2`. An index of length `3` with range `(1, 4)` draws from `1` for `2`. A range of `(8, 1)` produces no item. A transparent point keeps that range in the transparent list. Line segments use the same range. A points object with no position stays out of the list. Point and line material arrays stay later.

Point and line material arrays have landed. Four points with groups `(0, 2)` and `(2, 2)`, sizes `4` and `8`, produce two items. The first is red `(1, 0)` from `0` for `2`. The second is green `(0, 1)` from `2` for `2`, with size attenuation off. An empty group list produces no item. `setDrawRange(1, 2)` clips them to `(1, 1)` and `(2, 1)`. Making the second material transparent leaves one opaque item and one transparent item. A material index past the array is skipped. Cloning keeps a new list of length `2`. A line and line segments with the same groups draw `(0, 2)` and `(2, 2)`. Raycast material indices stay later.

Point and line raycast material indices have landed. Points at `x=0` and `x=2` with groups `(0, 1)` and `(1, 1)` miss while the group list is empty. A ray from `(0, 0.25, 0)` then hits `(0, 0, 0)` at material `0`, and a ray from `(2, 0.25, 0)` hits `(2, 0, 0)` at material `1`. `setDrawRange(1, 1)` keeps only the second hit. A line from `(0, 0, 0)` to `(1, 0, 0)` and `(2, 0, 0)` to `(3, 0, 0)` hits `(0.5, 0, 0)` at material `0` and `(2.5, 0, 0)` at material `1`. Line segments report the same second material. An out-of-range material index aborts. A point or line without a material array leaves `material_index` empty.

`Points.copy` leaves morph weights in place. A position group named `wide` and `tall`, with the first weight set to `0.5`, copies onto a point cloud that had none. The destination influences and dictionary stay empty, and the source stays at `0.5` with `wide` at `0`. A destination built from that geometry starts at `[0, 0]`. Copying the weighted cloud onto it leaves the first weight at `0`. Setting that weight to `1` leaves the source at `0.5`. Copying a cloud with no morph data onto one whose first weight is `0.25` leaves that weight and `wide` at `0`. `Points.clone` builds a new cloud first, so the clone starts at `0` with `tall` at `1`, and setting its first weight to `1` leaves the source at `0.5`.

`Line.copy` leaves morph weights in place. A position group named `wide` and `tall`, with the first weight set to `0.5`, copies onto a line that had none. The destination influences and dictionary stay empty, and the source stays at `0.5` with `wide` at `0`. A destination built from that geometry starts at `[0, 0]`. Copying the weighted line onto it leaves the first weight at `0`. Setting that weight to `1` leaves the source at `0.5`. Copying a line with no morph data onto one whose first weight is `0.25` leaves that weight and `wide` at `0`. `Line.clone` builds a new line first, so the clone starts at `0` with `tall` at `1`, and setting its first weight to `1` leaves the source at `0.5`. `LineSegments` and `LineLoop` use that same copy.

## Checklist

| status | phase | item | packages |
|---|---|---|---|
| planned | 2 | Group, Mesh from `src/objects` | `objects` |
| planned | 7 | Points, Line, LineSegments, PointsMaterial, LineBasicMaterial | `objects`, `materials`, `renderer` |
| planned | 7 | InstancedMesh | `objects`, `renderer` |
| planned | 7 | `LOD.addLevel` | `objects` |
| planned | 7 | `LOD.removeLevel` | `objects` |
| planned | 7 | `LOD.getObjectForDistance` | `objects` |
| planned | 7 | `LOD.update` | `objects` |
| planned | 7 | `Sprite.intersectsFrustum` | `objects` |
| planned | 7 | `Sprite.intersectsFrustumArray` | `objects` |
| planned | 7 | `InstancedMesh.computeBoundingSphere` | `objects` |
| planned | 7 | `InstancedMesh.intersectsFrustum` | `objects` |
| planned | 7 | `InstancedMesh.intersectsFrustumArray` | `objects` |
| planned | 7 | `InstancedMesh.copy` | `objects` |
| planned | 7 | `InstancedMesh.clone` | `objects` |
| planned | 7 | `LOD.copy` | `objects` |
| planned | 7 | `LOD.clone` | `objects` |
| planned | 7 | `LOD.getCurrentLevel` | `objects` |
| planned | 7 | `Sprite.geometry` | `objects` |
| planned | 7 | `Sprite.count` | `objects` |
| planned | 7 | `Mesh.copy` | `objects` |
| planned | 7 | `Mesh.clone` | `objects` |
| planned | 7 | `Mesh.count` | `objects` |
| planned | 7 | `Mesh.updateMorphTargets` | `objects` |
| planned | 7 | `Mesh.copy` copies morph weights | `objects` |
| planned | 7 | `Points.copy` | `objects` |
| planned | 7 | `Points.clone` | `objects` |
| planned | 7 | `Line.copy` | `objects` |
| planned | 7 | `Line.clone` | `objects` |
| planned | 7 | `LineSegments.copy` | `objects` |
| planned | 7 | `LineSegments.clone` | `objects` |
| planned | 7 | `LineLoop.copy` | `objects` |
| planned | 7 | `LineLoop.clone` | `objects` |
| planned | 7 | `Sprite.copy` | `objects` |
| planned | 7 | `Sprite.clone` | `objects` |
| planned | 7 | `Line.computeLineDistances` | `objects` |
| planned | 7 | `LineSegments.computeLineDistances` | `objects` |
| planned | 7 | `LineLoop.computeLineDistances` | `objects` |
| planned | 7 | `Points.updateMorphTargets` | `objects` |
| planned | 7 | `Line.updateMorphTargets` | `objects` |
| planned | 7 | `LineSegments.updateMorphTargets` | `objects` |
| planned | 7 | `LineLoop.updateMorphTargets` | `objects` |
| planned | 7 | `InstancedMesh.setMorphAt` | `objects` |
| planned | 7 | `InstancedMesh.getMorphAt` | `objects` |
| planned | 7 | `InstancedMesh.copy` copies the morph buffer | `objects` |
| planned | 7 | `InstancedMesh.dispose` | `objects` |
| planned | 7 | `InstancedMesh.updateMorphTargets` | `objects` |
| planned | 7 | `Group.copy` | `objects` |
| planned | 7 | `Group.clone` | `objects` |
| planned | 7 | `Bone` | `objects` |
| planned | 7 | `Bone.copy` | `objects` |
| planned | 7 | `Bone.clone` | `objects` |
| planned | 7 | `Skeleton` | `objects` |
| planned | 7 | `Skeleton.pose` | `objects` |
| planned | 7 | `Skeleton.update` | `objects` |
| planned | 7 | `Skeleton.clone` | `objects` |
| planned | 7 | `Skeleton.getBoneByName` | `objects` |
| planned | 7 | `Skeleton.computeBoneTexture` | `objects` |
| planned | 7 | `Skeleton.dispose` | `objects` |
| planned | 7 | `Skeleton.toJSON` | `objects` |
| planned | 7 | `Skeleton.fromJSON` | `objects` |
| planned | 7 | `SkinnedMesh` | `objects` |
| planned | 7 | `SkinnedMesh.bind` | `objects` |
| planned | 7 | `SkinnedMesh.pose` | `objects` |
| planned | 7 | `SkinnedMesh.normalizeSkinWeights` | `objects` |
| planned | 7 | `SkinnedMesh.updateMatrixWorld` | `objects` |
| planned | 7 | `SkinnedMesh.applyBoneTransform` | `objects` |
| planned | 7 | `SkinnedMesh.applyBoneTransform` for `Vector4` | `objects` |
| planned | 7 | `SkinnedMesh.getVertexPosition` | `objects` |
| planned | 7 | `SkinnedMesh.computeBoundingBox` | `objects` |
| planned | 7 | `SkinnedMesh.computeBoundingSphere` | `objects` |
| planned | 7 | `SkinnedMesh.copy` | `objects` |
| planned | 7 | `SkinnedMesh.clone` | `objects` |
| planned | 7 | `SkinnedMesh.raycast` | `objects` |
| planned | 7 | instanced mesh raycast material arrays | `objects` |
| planned | 7 | skinned mesh raycast material arrays | `objects` |
| planned | 7 | point and line material arrays | `objects`, `renderer` |
| planned | 7 | `Points.copy` leaves morph weights in place | `objects` |
| planned | 7 | `Line.copy` leaves morph weights in place | `objects` |
| planned | 7 | point and line `alphaTest` in the shader | `objects`, `renderer`, `nodes` |
| planned | 7 | transparent meshes, back to front | `objects`, `renderer` |
| planned | 7 | transparent points and lines, back to front | `objects`, `renderer` |
