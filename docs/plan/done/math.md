# math

Landed. Behavior notes are the phase log. The checklist is the upstream file map for this module.

## Behavior

`Vector3.transformDirection` has landed. It multiplies by the upper 3×3 of a matrix and normalizes. Translation is ignored, so a pure shift leaves `(0, 0, 1)` unchanged. A right-angle yaw turns `(1, 0, 0)` into `(0, 0, -1)`. Scale `(2, 1, 1)` turns `(1, 1, 0)` into `(0.894427190999916, 0.447213595499958, 0)`.

`Vector3.angleTo` has landed. It is the inverse cosine of the normalized dot product, clamped to [-1, 1]. A vector against itself is 0. `(1, 0, 0)` against `(0, 0, -1)` is a right angle, against `(-1, 0, 0)` is π, and against `(1, 1, 0)` is π/4. A zero-length vector returns π/2. The vectors are not modified.

`Vector3.distanceTo` has landed. It is the square root of `distanceToSquared`. The distance from the origin to `(3, 4, 0)` is 5. A vector's distance to itself is 0. Neither vector is modified.

`Vector3.manhattanDistanceTo` has landed. It is the sum of the absolute component differences. The Manhattan distance from the origin to `(3, 4, 0)` is 7. `(1, -2, 3)` to the origin is 6. A vector's distance to itself is 0. Neither vector is modified.

`Vector3.setFromSphericalCoords` has landed. `phi` is the angle from the positive Y axis, and `theta` turns around Y from positive Z toward positive X. Radius 5 at `phi` 0 is `(0, 5, 0)`. Radius 2 at `phi` π/2 and `theta` 0 is `(0, 0, 2)`. The same radius at `theta` π/2 is `(2, 0, 0)`. Radius 4 at `phi` 0.5 and `theta` -0.3 is about `(-0.566719736988, 3.51033024756, 1.83205084339)`. The vector is overwritten. The `Spherical` wrapper stays out until that type exists.

`Vector3.setFromCylindricalCoords` has landed. `theta` turns around Y from positive Z toward positive X, and `y` is the height. Radius 2 at `theta` 0 and height 5 is `(0, 5, 2)`. The same radius at `theta` π/2 and height -1 is `(2, -1, 0)`. Radius 3 at `theta` -0.3 and height 1 is about `(-0.886560619984, 1, 2.86600946738)`. The vector is overwritten. The `Cylindrical` wrapper stays out until that type exists.

`Vector3.setFromMatrixScale` has landed. It reads the length of the first three columns. A matrix composed with scale `(2, 3, 4)` and a translation of 10 on x yields `(2, 3, 4)`. A negative x scale of `-2` still yields `2`, because the length is unsigned. The vector is overwritten.

`Vector3.setFromMatrix3Column` has landed. The matrix is column-major, and `set` still takes its nine arguments in row order. Column 0 of the matrix written as rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` is `(1, 4, 7)`. Column 1 is `(2, 5, 8)`, and column 2 is `(3, 6, 9)`. The vector is overwritten.

`Vector3.setFromEuler` has landed. It copies the three angles and ignores the rotation order. Euler `(0.2, -0.4, 0.6)` with order `YXZ` becomes that same triple. Changing the Euler afterwards leaves the vector alone.

`Vector3.setFromColor` has landed. It copies the stored linear channels and does not run the sRGB conversion that `setHex` does. Color `(0.25, 0.5, 0.75)` becomes that same triple. Changing the color afterwards leaves the vector alone.

`Vector3.fromArray` has landed. It reads three components starting at `offset`, which defaults to 0. From `[1, 2, 3, 4, 5]`, offset 0 is `(1, 2, 3)` and offset 2 is `(3, 4, 5)`. The array is not modified.

`Vector3.toArray` has landed. A missing array becomes `[x, y, z]`. An existing array is written at `offset`, which defaults to 0, and the same array is returned. `[9, 8, 7, 6, 5]` at offset 1 becomes `[9, x, y, z, 5]` for vector `(1, 2, 3)`. An array shorter than `offset + 3` is padded with zeros before the write. The vector is not modified.

`Vector3.setScalar` has landed. It writes the same value into x, y, and z. `(1, 2, 3)` set to 4 becomes `(4, 4, 4)`.

`Vector3.setX`, `setY`, and `setZ` have landed. Each writes one component and leaves the other two alone. `(1, 2, 3)` then `setX(9)`, `setY(8)`, and `setZ(7)` becomes `(9, 8, 7)`.

`Vector3.setComponent` and `getComponent` have landed. Index 0 is x, 1 is y, and 2 is z. `(1, 2, 3)` with `setComponent(1, 8)` becomes `(1, 8, 3)`. Any other index aborts.

`Vector3.addScalar` has landed. It adds one number to every component. `(1, 2, 3)` plus 4 is `(5, 6, 7)`. Adding `-1` then yields `(4, 5, 6)`.

`Vector3.addScaledVector` has landed. It adds `v * s` to this vector. `(1, 2, 3)` plus `(4, 5, 6)` scaled by 2 is `(9, 12, 15)`. The other vector is not modified. The `Vector4` overload stays out.

`Vector3.subScalar` has landed. It subtracts one number from every component. `(5, 6, 7)` minus 4 is `(1, 2, 3)`. Subtracting `-1` then yields `(2, 3, 4)`.

`Vector3.multiply` has landed. It multiplies each component by the matching component of the other vector. `(2, 3, 4)` times `(5, 6, 0.5)` is `(10, 18, 2)`. The other vector is not modified.

`Vector3.multiplyVectors` has landed. It stores the component-wise product of two vectors. The product of `(2, 3, 4)` and `(5, 6, 0.5)` is `(10, 18, 2)`. Writing the product back into the first vector still yields that result, and the second vector is not modified.

`Vector3.applyEuler` has landed. It converts the Euler angles to a quaternion and applies that. The identity leaves `(1, 0, 0)` unchanged. A yaw of a right angle, order `XYZ`, turns it into `(0, 0, -1)`. The temporary quaternion is not stored.

`Vector3.applyAxisAngle` has landed. The axis is assumed to be unit length. Angle 0 leaves `(1, 0, 0)` unchanged. A right-angle turn around `(0, 1, 0)` makes it `(0, 0, -1)`. The axis and the temporary quaternion are not stored as part of the vector.

`Vector3.applyMatrix3` has landed. It multiplies by a column-major 3×3 matrix and does not divide by a perspective term. The identity leaves `(1, 2, 3)` unchanged. A diagonal scale of `(2, 3, 4)` turns it into `(2, 6, 12)`. The first column of the matrix written as rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` turns `(1, 0, 0)` into `(1, 4, 7)`.

`Vector3.applyNormalMatrix` has landed. It multiplies by the 3×3 matrix and then normalizes. The identity takes `(0, 3, 4)` to `(0, 0.6, 0.8)`. A zero vector stays zero. `project` and `unproject` stay out of `math`, because that package does not import cameras.

`Vector3.divide` has landed. It divides each component by the matching component of the other vector. `(10, 18, 2)` divided by `(5, 6, 0.5)` is `(2, 3, 4)`. The other vector is not modified.

`Vector3.divideScalar` has landed. It divides every component by one number, through `multiplyScalar(1 / scalar)`. `(2, 4, 6)` divided by 2 is `(1, 2, 3)`. Dividing by `-1` then yields `(-1, -2, -3)`.

`Vector3.clamp` has landed. Each component is limited by the matching component of `min` and `max`, which are assumed to be ordered. `(0, 5, -2)` clamped by `(1, 0, -1)` and `(3, 4, 1)` becomes `(1, 4, -1)`. `(2, 2, 2)` inside `(0, 0, 0)` and `(3, 3, 3)` stays put. The bound vectors are not modified.

`Vector3.clampScalar` has landed. Every component uses the same lower and upper bound, which are assumed to be ordered. `(0, 5, -2)` clamped to `[1, 4]` becomes `(1, 4, 1)`. `(2, 3, 4)` inside `[0, 5]` stays put.

`Vector3.clampLength` has landed. It rescales the vector so its length lies between `min` and `max`, which are assumed to be ordered. Length 8 clamped to `[1, 2]` becomes 2, and length 0.5 becomes 1, both along the original direction. Length 4 inside `[1, 8]` stays 4. A zero vector stays zero.

`Vector3.floor` has landed. Each component rounds toward negative infinity. `(1.2, -1.2, 3)` becomes `(1, -2, 3)`.

`Vector3.ceil` has landed. Each component rounds toward positive infinity. `(1.2, -1.2, 3)` becomes `(2, -1, 3)`.

`Vector3.round` has landed. A halfway case rounds toward positive infinity. `(1.5, -1.5, 1.2)` becomes `(2, -1, 1)`.

`Vector3.roundToZero` has landed. Each component drops its fraction toward zero. `(1.8, -1.8, 3)` becomes `(1, -1, 3)`.

`Vector3.manhattanLength` has landed. It is the sum of the absolute components. `(3, -4, 0)` has length 7. A zero vector has length 0. The vector is not modified.

`Vector3.setLength` has landed. It normalizes and then multiplies by the requested length. `(0, 0, 4)` set to length 2 becomes `(0, 0, 2)`, and setting that to length 0 becomes zero. A zero vector stays zero.

`Vector3.lerpVectors` has landed. It stores `(1 - alpha)` of the first vector plus `alpha` of the second. Alpha 0.25 from `(1, 2, 3)` toward `(5, 6, 7)` is `(2, 3, 4)`. Alpha 0 keeps the first vector, and alpha 1 keeps the second. Neither input is modified.

`Vector3.projectOnVector` has landed. It replaces this vector with its projection onto the target. `(2, 3, 0)` onto `(4, 0, 0)` becomes `(2, 0, 0)`. Projecting onto the zero vector yields zero. The target is not modified.

`Vector3.projectOnPlane` has landed. It removes the component along the plane normal. The normal does not need to be unit length. `(2, 3, 4)` with normal `(0, 4, 0)` becomes `(2, 0, 4)`. A zero normal leaves the vector unchanged. The normal is not modified.

`Vector3.reflect` has landed. It reflects this vector across the plane with the given unit normal. `(1, -1, 0)` reflected by `(0, 1, 0)` becomes `(1, 1, 0)`. The normal is not modified.

`Vector3.setFromSpherical` has landed, along with `Spherical`. The spherical value stores a radius and two angles, defaulting to radius 1, `phi` 0, and `theta` 0. The vector method copies those three fields into `setFromSphericalCoords`. Radius 5 at `phi` 0 is `(0, 5, 0)`. The spherical value is not modified. `set`, `copy`, `makeSafe`, and the Cartesian constructors stay later.

`Spherical.set` has landed. It writes the radius and both angles. The default value set to radius 2, `phi` 0.5, and `theta` -0.3 becomes that triple. `copy`, `makeSafe`, and the Cartesian constructors stay later.

`Spherical.copy` has landed. It copies radius, `phi`, and `theta` from another spherical value. Copying radius 2, `phi` 0.5, and `theta` -0.3 onto the default value yields that triple. The source is not modified. `makeSafe` and the Cartesian constructors stay later.

`Spherical.makeSafe` has landed. It clamps `phi` to the open interval from `0.000001` to `π - 0.000001`. A polar angle of 0 becomes `0.000001`, and `π` becomes `π - 0.000001`. An angle of 0.5 stays 0.5. Radius and `theta` are not modified. The Cartesian constructors stay later.

`Spherical.setFromCartesianCoords` has landed. The radius is the distance from the origin. `phi` is the angle from the positive Y axis, and `theta` turns around Y from positive Z toward positive X. The origin stays radius 0 with both angles 0. `(0, 5, 0)` is radius 5 at `phi` 0. `(0, 0, 2)` is radius 2 at `phi` π/2 and `theta` 0. `(2, 0, 0)` is the same radius at `theta` π/2. The point produced by radius 4, `phi` 0.5, and `theta` -0.3 converts back to those coordinates. `setFromVector3` stays later.

`Spherical.setFromVector3` has landed. It reads the vector's three components and passes them to `setFromCartesianCoords`. `(0, 5, 0)` is radius 5 at `phi` 0. The zero vector is radius 0 with both angles 0. The vector is not modified. `clone` stays later.

`Spherical.clone` has landed. It returns a new spherical value with the same radius, `phi`, and `theta`. Cloning radius 2, `phi` 0.5, and `theta` -0.3 yields that triple. Changing the clone leaves the source alone.

`Vector3.setFromCylindrical` has landed, along with `Cylindrical`. The cylindrical value stores a radius, an angle, and a height, defaulting to radius 1, `theta` 0, and height 0. The vector method copies those three fields into `setFromCylindricalCoords`. Radius 2 at `theta` 0 and height 5 is `(0, 5, 2)`. The cylindrical value is not modified. `set`, `copy`, the Cartesian constructors, and `clone` stay later.

`Cylindrical.set` has landed. It writes the radius, the angle, and the height. The default value set to radius 2, `theta` -0.3, and height 5 becomes that triple. `copy`, the Cartesian constructors, and `clone` stay later.

`Cylindrical.copy` has landed. It copies radius, `theta`, and height from another cylindrical value. Copying radius 2, `theta` -0.3, and height 5 onto the default value yields that triple. The source is not modified. The Cartesian constructors and `clone` stay later.

`Cylindrical.setFromCartesianCoords` has landed. The radius is the distance from the origin in the xz plane, `theta` turns around Y from positive Z toward positive X, and `y` is the height. `(0, 5, 2)` is radius 2 at `theta` 0 and height 5. `(2, -1, 0)` is radius 2 at `theta` π/2 and height -1. The origin is radius 0 at `theta` 0 and height 0. The point produced by radius 3, `theta` -0.3, and height 1 converts back to those coordinates. `setFromVector3` stays later.

`Cylindrical.setFromVector3` has landed. It reads the vector's three components and passes them to `setFromCartesianCoords`. `(0, 5, 2)` is radius 2 at `theta` 0 and height 5. The vector is not modified. `clone` stays later.

`Cylindrical.clone` has landed. It returns a new cylindrical value with the same radius, `theta`, and height. Cloning radius 2, `theta` -0.3, and height 5 yields that triple. Changing the clone leaves the source alone.

`Vector2.setScalar` has landed. It writes the same value into x and y. `(1, 2)` set to 4 becomes `(4, 4)`.

`Vector2.setX` has landed. It writes x and leaves y alone. `(1, 2)` then `setX(9)` becomes `(9, 2)`.

`Vector2.setY` has landed. It writes y and leaves x alone. `(1, 2)` then `setY(8)` becomes `(1, 8)`.

`Vector2.setComponent` has landed. Index 0 is x and 1 is y. `(1, 2)` with `setComponent(1, 8)` becomes `(1, 8)`. Any other index aborts.

`Vector2.getComponent` has landed. Index 0 is x and 1 is y. `(1, 2)` returns 1 at index 0 and 2 at index 1. The vector is not modified. Any other index aborts.

`Vector2.addScalar` has landed. It adds one number to both components. `(1, 2)` plus 4 is `(5, 6)`. Adding `-1` then yields `(4, 5)`.

`Vector2.addVectors` has landed. It stores the sum of two vectors. The sum of `(1, 2)` and `(3, 4)` is `(4, 6)`. Writing the sum back into the first vector still yields that result, and the second vector is not modified.

`Vector2.addScaledVector` has landed. It adds `v * s` to this vector. `(1, 2)` plus `(4, 5)` scaled by 2 is `(9, 12)`. The other vector is not modified.

`Vector2.subScalar` has landed. It subtracts one number from both components. `(5, 6)` minus 4 is `(1, 2)`. Subtracting `-1` then yields `(2, 3)`.

`Vector2.subVectors` has landed. It stores the difference of two vectors. `(5, 6)` minus `(1, 2)` is `(4, 4)`. Writing the difference back into the first vector still yields that result, and the second vector is not modified.

`Vector2.multiply` has landed. It multiplies each component by the matching component of the other vector. `(2, 4)` times `(5, 6)` is `(10, 24)`. The other vector is not modified.

`Vector2.divide` has landed. It divides each component by the matching component of the other vector. `(10, 24)` divided by `(5, 6)` is `(2, 4)`. The other vector is not modified.

`Vector2.divideScalar` has landed. It divides both components by one number, through `multiplyScalar(1 / scalar)`. `(2, 4)` divided by 2 is `(1, 2)`. Dividing by `-1` then yields `(-1, -2)`.

`Vector2.applyMatrix3` has landed. The third component is an implicit 1, and only x and y are stored. The identity leaves `(1, 2)` unchanged. A translation of `(3, 4)` turns it into `(4, 6)`. The matrix written as rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` turns `(1, 0)` into `(4, 10)`.

`Vector2.min` has landed. Each component becomes the smaller of the two vectors. `(0, 5)` against `(1, 4)` becomes `(0, 4)`. The other vector is not modified.

`Vector2.max` has landed. Each component becomes the larger of the two vectors. `(0, 5)` against `(1, 4)` becomes `(1, 5)`. The other vector is not modified.

`Vector2.clamp` has landed. Each component is limited by the matching component of `min` and `max`, which are assumed to be ordered. `(0, 5)` clamped by `(1, 0)` and `(3, 4)` becomes `(1, 4)`. `(2, 2)` inside `(0, 0)` and `(3, 3)` stays put. The bound vectors are not modified.

`Vector2.clampScalar` has landed. Both components use the same lower and upper bound, which are assumed to be ordered. `(0, 5)` clamped to `[1, 4]` becomes `(1, 4)`. `(2, 3)` inside `[0, 5]` stays put.

`Vector2.clampLength` has landed. It rescales the vector so its length lies between `min` and `max`, which are assumed to be ordered. Length 4 clamped to `[1, 2]` becomes 2, and length 0.5 becomes 1, both along the original direction. Length 4 inside `[1, 8]` stays 4. A zero vector stays zero.

`Vector2.floor` has landed. Each component rounds toward negative infinity. `(1.2, -1.2)` becomes `(1, -2)`.

`Vector2.ceil` has landed. Each component rounds toward positive infinity. `(1.2, -1.2)` becomes `(2, -1)`.

`Vector2.round` has landed. A halfway case rounds toward positive infinity. `(1.5, -1.5)` becomes `(2, -1)`.

`Vector2.roundToZero` has landed. Each component drops its fraction toward zero. `(1.8, -1.8)` becomes `(1, -1)`.

`Vector2.negate` has landed. It flips the sign of both components. `(1, -2)` becomes `(-1, 2)`.

`Vector2.cross` has landed. It returns the z component of the cross product, `x * v.y - y * v.x`. `(2, 3)` crossed with `(4, 5)` is `-2`. `(1, 0)` crossed with `(0, 1)` is `1`. Neither vector is modified.

`Vector2.manhattanLength` has landed. It is the sum of the absolute components. `(3, -4)` has length 7. A zero vector has length 0. The vector is not modified.

`Vector2.angle` has landed. It is the angle from the positive X axis, in `[0, 2π)`. `(1, 0)` is 0, `(0, 1)` is π/2, `(-1, 0)` is π, and `(0, -1)` is 3π/2. The vector is not modified.

`Vector2.angleTo` has landed. It is the inverse cosine of the normalized dot product, clamped to [-1, 1]. A vector against itself is 0. `(1, 0)` against `(0, 1)` is a right angle, against `(-1, 0)` is π, and against `(1, 1)` is π/4. A zero-length vector returns π/2. The vectors are not modified.

`Vector2.distanceToSquared` has landed. It is the square of the straight-line separation. The squared distance from the origin to `(3, 4)` is 25. A vector's squared distance to itself is 0. Neither vector is modified. `distanceTo` stays later.

`Vector2.distanceTo` has landed. It is the square root of `distanceToSquared`. The distance from the origin to `(3, 4)` is 5. A vector's distance to itself is 0. Neither vector is modified.

`Vector2.manhattanDistanceTo` has landed. It is the sum of the absolute component differences. The Manhattan distance from the origin to `(3, 4)` is 7. `(1, -2)` to the origin is 3. A vector's distance to itself is 0. Neither vector is modified.

`Vector2.setLength` has landed. It normalizes and then multiplies by the requested length. `(0, 4)` set to length 2 becomes `(0, 2)`, and setting that to length 0 becomes zero. A zero vector stays zero.

`Vector2.lerpVectors` has landed. It stores `(1 - alpha)` of the first vector plus `alpha` of the second. Alpha 0.25 from `(1, 2)` toward `(5, 6)` is `(2, 3)`. Alpha 0 keeps the first vector, and alpha 1 keeps the second. Neither input is modified.

`Vector2.fromArray` has landed. It reads two components starting at `offset`, which defaults to 0. From `[1, 2, 3, 4, 5]`, offset 0 is `(1, 2)` and offset 2 is `(3, 4)`. The array is not modified.

`Vector2.toArray` has landed. A missing array becomes `[x, y]`. An existing array is written at `offset`, which defaults to 0, and the same array is returned. `[9, 8, 7, 6]` at offset 1 becomes `[9, x, y, 6]` for vector `(1, 2)`. An array shorter than `offset + 2` is padded with zeros before the write. The vector is not modified.

`Vector2.rotateAround` has landed. It rotates this vector counterclockwise around a center. Angle 0 leaves `(1, 2)` unchanged. A right angle around the origin turns `(1, 0)` into `(0, 1)`. The same turn around `(1, 1)` takes `(2, 1)` to `(1, 2)`. The center is not modified. `Vector2.random` stays out, because it draws from `Math.random`.

`Vector4.setScalar` has landed. It writes the same value into x, y, z, and w. `(1, 2, 3, 4)` set to 5 becomes `(5, 5, 5, 5)`.

`Vector4.setX` has landed. It writes x and leaves y, z, and w alone. `(1, 2, 3, 4)` then `setX(9)` becomes `(9, 2, 3, 4)`.

`Vector4.setY` has landed. It writes y and leaves x, z, and w alone. `(1, 2, 3, 4)` then `setY(8)` becomes `(1, 8, 3, 4)`.

`Vector4.setZ` has landed. It writes z and leaves x, y, and w alone. `(1, 2, 3, 4)` then `setZ(7)` becomes `(1, 2, 7, 4)`.

`Vector4.setW` has landed. It writes w and leaves x, y, and z alone. `(1, 2, 3, 4)` then `setW(6)` becomes `(1, 2, 3, 6)`.

`Vector4.setComponent` has landed. Index 0 is x, 1 is y, 2 is z, and 3 is w. `(1, 2, 3, 4)` with `setComponent(3, 6)` becomes `(1, 2, 3, 6)`. Any other index aborts.

`Vector4.getComponent` has landed. Index 0 is x, 1 is y, 2 is z, and 3 is w. `(1, 2, 3, 4)` returns 1, 2, 3, and 4. The vector is not modified. Any other index aborts.

`Vector4.add` has landed. It adds another vector into this one. `(1, 2, 3, 4)` plus `(5, 6, 7, 8)` becomes `(6, 8, 10, 12)`. The other vector is unchanged.

`Vector4.addScalar` has landed. It adds one number to x, y, z, and w. `(1, 2, 3, 4)` plus 4 becomes `(5, 6, 7, 8)`, then minus 1 becomes `(4, 5, 6, 7)`.

`Vector4.addVectors` has landed. It writes the sum of two vectors into this one. `(1, 2, 3, 4)` plus `(5, 6, 7, 8)` becomes `(6, 8, 10, 12)`. Writing into the first vector still works. The second vector is unchanged.

`Vector4.addScaledVector` has landed. It adds `v * s` into this vector. `(1, 2, 3, 4)` plus `(4, 5, 6, 7)` scaled by 2 becomes `(9, 12, 15, 18)`. The other vector is unchanged.

`Vector4.sub` has landed. It subtracts another vector from this one. `(6, 8, 10, 12)` minus `(1, 2, 3, 4)` becomes `(5, 6, 7, 8)`. The other vector is unchanged.

`Vector4.subScalar` has landed. It subtracts one number from x, y, z, and w. `(5, 6, 7, 8)` minus 4 becomes `(1, 2, 3, 4)`, then minus -1 becomes `(2, 3, 4, 5)`.

`Vector4.subVectors` has landed. It writes the difference of two vectors into this one. `(5, 6, 7, 8)` minus `(1, 2, 3, 4)` becomes `(4, 4, 4, 4)`. Writing into the first vector still works. The second vector is unchanged.

`Vector4.multiply` has landed. It multiplies matching components. `(2, 4, 6, 8)` times `(5, 6, 7, 8)` becomes `(10, 24, 42, 64)`. The other vector is unchanged.

`Vector4.multiplyScalar` has landed. It multiplies x, y, z, and w by one number. `(2, 4, 6, 8)` times 2 becomes `(4, 8, 12, 16)`, then times -1 becomes `(-4, -8, -12, -16)`.

`Vector4.divide` has landed. It divides matching components. `(10, 24, 42, 64)` divided by `(5, 6, 7, 8)` becomes `(2, 4, 6, 8)`. The other vector is unchanged.

`Vector4.divideScalar` has landed. It divides by one number through `multiplyScalar(1 / scalar)`. `(2, 4, 6, 8)` divided by 2 becomes `(1, 2, 3, 4)`, then divided by -1 becomes `(-1, -2, -3, -4)`.

`Vector4.setAxisAngleFromQuaternion` has landed. It writes the quaternion axis into x, y, and z and the angle into w. The identity quaternion becomes axis `(1, 0, 0)` and angle 0. A quarter turn around Y becomes axis `(0, 1, 0)` and angle π/2. The quaternion is unchanged.

`Vector4.setAxisAngleFromRotationMatrix` has landed. It reads the axis and angle from the upper 3×3 of a pure rotation matrix. The identity matrix becomes axis `(1, 0, 0)` and angle 0. A quarter turn around Y becomes axis `(0, 1, 0)` and angle π/2. A half turn around X becomes axis `(1, 0, 0)` and angle π. The matrix is unchanged.

`Vector4.setFromMatrixPosition` has landed. It copies the last column. The identity matrix becomes `(0, 0, 0, 1)`. A matrix whose last column is `(3, 4, 5, 6)` becomes `(3, 4, 5, 6)`. The matrix is unchanged.

`Vector4.min` has landed. It keeps the smaller value of each component. `(0, 5, 2, 8)` against `(1, 4, 3, 7)` becomes `(0, 4, 2, 7)`. The other vector is unchanged.

`Vector4.max` has landed. It keeps the larger value of each component. `(0, 5, 2, 8)` against `(1, 4, 3, 7)` becomes `(1, 5, 3, 8)`. The other vector is unchanged.

`Vector4.clamp` has landed. It assumes min is less than max on each component. `(0, 5, 2, 9)` clamped by `(1, 0, 1, 0)` and `(3, 4, 4, 8)` becomes `(1, 4, 2, 8)`. `(2, 2, 2, 2)` inside `(0, 0, 0, 0)` and `(3, 3, 3, 3)` stays. The bounds are unchanged.

`Vector4.clampScalar` has landed. It assumes the lower number is less than the upper number. `(0, 5, 2, 9)` clamped to `[1, 4]` becomes `(1, 4, 2, 4)`. `(2, 3, 1, 4)` inside `[0, 5]` stays.

`Vector4.clampLength` has landed. It scales the vector so its length lies between min and max. Length 4 clamped to `[1, 2]` becomes length 2. Length 0.5 becomes 1. Length 4 inside `[1, 8]` stays. A zero vector stays zero.

`Vector4.floor` has landed. It rounds each component down. `(1.2, -1.2, 2.8, -2.8)` becomes `(1, -2, 2, -3)`.

`Vector4.ceil` has landed. It rounds each component up. `(1.2, -1.2, 2.8, -2.8)` becomes `(2, -1, 3, -2)`.

`Vector4.round` has landed. Half values round toward positive infinity. `(1.5, -1.5, 2.5, -2.5)` becomes `(2, -1, 3, -2)`.

`Vector4.roundToZero` has landed. It rounds each component toward zero. `(1.8, -1.8, 2.8, -2.8)` becomes `(1, -1, 2, -2)`.

`Vector4.negate` has landed. It flips the sign of every component. `(1, -2, 3, -4)` becomes `(-1, 2, -3, 4)`.

`Vector4.manhattanLength` has landed. It sums the absolute components. `(3, -4, 5, -6)` is 18. A zero vector is 0. The vector is not modified.

`Vector4.setLength` has landed. It divides by the current length, using 1 when that length is zero, then multiplies by the requested length. `(0, 0, 0, 4)` set to length 2 becomes `(0, 0, 0, 2)`, then set to 0 becomes zero. A zero vector set to 5 stays zero.

`Vector4.lerp` has landed. Alpha 0 keeps this vector and alpha 1 copies the other. `(1, 2, 3, 4)` toward `(5, 6, 7, 8)` at alpha 0.25 becomes `(2, 3, 4, 5)`. The other vector is unchanged.

`Vector4.lerpVectors` has landed. It writes the interpolation of two vectors into this one. Alpha 0.25 from `(1, 2, 3, 4)` toward `(5, 6, 7, 8)` is `(2, 3, 4, 5)`. Alpha 0 and 1 copy the endpoints. Both inputs stay unchanged.

`Vector4.equals` has landed. It compares x, y, z, and w. `(1, 2, 3, 4)` equals a copy of itself. Changing any one component makes it unequal. Neither vector is modified.

`Vector4.fromArray` has landed. Offset defaults to 0. `[1, 2, 3, 4, 5, 6, 7]` at offset 0 becomes `(1, 2, 3, 4)`, and at offset 2 becomes `(3, 4, 5, 6)`. The array is unchanged.

`Vector4.toArray` has landed. A missing array becomes `[x, y, z, w]`. `[9, 8, 7, 6, 5]` at offset 1 becomes `[9, 1, 2, 3, 4]` for `(1, 2, 3, 4)`. A short array is padded with zeros up to `offset + 4`. The same array is returned. The vector is unchanged.

`Box2` has landed. A box with no arguments is empty: the lower corner is `(+∞, +∞)` and the upper corner is `(-∞, -∞)`. Passing corners copies them, so later changes to those vectors leave the box alone.

`Box2.set` has landed. It copies both corners into the box. An empty box set to `(1, 2)` and `(3, 4)` becomes that box. Later changes to the source vectors leave the box alone.

`Box2.makeEmpty` has landed. It sets the lower corner to `(+∞, +∞)` and the upper corner to `(-∞, -∞)`. A box from `(1, 2)` to `(3, 4)` becomes empty.

`Box2.expandByPoint` has landed. It widens the box to include the point. An empty box expanded by `(1, 2)` becomes that point. Expanding it by `(0, 5)` reaches from `(0, 2)` to `(1, 5)`. The point is unchanged.

`Box2.setFromPoints` has landed. It empties the box, then expands it by each point. Points `(1, 2)` and `(0, 5)` become a box from `(0, 2)` to `(1, 5)`. An empty list leaves the box empty. The points are unchanged.

`Box2.setFromCenterAndSize` has landed. Center `(5, 6)` and size `(2, 4)` become a box from `(4, 4)` to `(6, 8)`. The center and the size are unchanged.

`Box2.copy` has landed. It copies both corners into the box. A box from `(1, 2)` to `(3, 4)` copied into an empty box becomes that box. Later changes to the source corners leave the copy alone.

`Box2.clone` has landed. It returns a new box with the same corners. Cloning a box from `(1, 2)` to `(3, 4)` yields that box. Later changes to the source corners leave the clone alone.

`Box2.isEmpty` has landed. A box is empty when either upper bound is below its lower bound. A fresh box is empty. A box from `(1, 2)` to `(3, 4)` is not. Equal corners `(1, 2)` and `(1, 2)` still hold that one point, so the box is not empty.

`Box2.getCenter` has landed. It writes the midpoint into the given vector. A box from `(1, 2)` to `(3, 4)` has center `(2, 3)`. An empty box writes `(0, 0)`. The box is unchanged.

`Box2.getSize` has landed. It writes the width and height into the given vector. A box from `(1, 2)` to `(3, 4)` has size `(2, 2)`. An empty box writes `(0, 0)`. The box is unchanged.

`Box2.expandByVector` has landed. It moves the lower corner back by the vector and the upper corner forward by the same vector. A box from `(1, 2)` to `(3, 4)` expanded by `(1, 2)` reaches from `(0, 0)` to `(4, 6)`. The vector is unchanged.

`Box2.expandByScalar` has landed. It grows each side by the scalar. A negative scalar shrinks the box. A box from `(1, 2)` to `(3, 4)` expanded by `1` reaches from `(0, 1)` to `(4, 5)`, and expanding by `-1` returns it to `(1, 2)` and `(3, 4)`.

`Box2.containsPoint` has landed. A point on or inside the bounds counts. In a box from `(1, 2)` to `(3, 4)`, `(2, 3)` and the corner `(1, 2)` are inside, and `(0, 3)` is outside. The point and the box are unchanged.

`Box2.containsBox` has landed. The other box must lie entirely on or inside the bounds. A box from `(1, 2)` to `(5, 6)` contains `(2, 3)` to `(4, 5)` and an identical copy of itself. A box from `(0, 3)` to `(4, 5)` sticks out, so it is not contained. Neither box changes.

`Box2.getParameter` has landed. It writes the point as a fraction of the box width and height. In a box from `(1, 2)` to `(3, 6)`, the point `(2, 4)` is `(0.5, 0.5)` and the lower corner `(1, 2)` is `(0, 0)`. The point and the box are unchanged.

`Box2.intersectsBox` has landed. Overlap and a shared edge both count. A box from `(1, 2)` to `(3, 4)` meets `(2, 3)` to `(4, 5)` and the edge-touching box from `(3, 2)` to `(5, 4)`. The box from `(4, 2)` to `(5, 4)` stays apart. Neither box changes.

`Box2.clampPoint` has landed. It writes the point clamped into the box. For a box from `(1, 2)` to `(3, 4)`, `(0, 5)` becomes `(1, 4)` and `(2, 3)` stays `(2, 3)`. The point and the box are unchanged.

`Box2.distanceToPoint` has landed. A point inside the box is distance `0`. For a box from `(1, 2)` to `(3, 4)`, the point `(0, 3)` is distance `1`. The point and the box are unchanged.

`Box2.intersect` has landed. It keeps the overlap of the two boxes. A box from `(1, 2)` to `(5, 6)` intersected with `(3, 0)` to `(4, 4)` becomes `(3, 2)` to `(4, 4)`. A box with no overlap becomes empty. The other box is unchanged.

`Box2.union` has landed. It grows the box until it covers both. A box from `(1, 2)` to `(3, 4)` united with `(0, 5)` to `(2, 6)` reaches from `(0, 2)` to `(3, 6)`. An empty box united with that second box becomes the second box. The other box is unchanged.

`Box2.translate` has landed. It adds the offset to both corners. A box from `(1, 2)` to `(3, 4)` moved by `(1, -2)` reaches from `(2, 0)` to `(4, 2)`. The offset is unchanged.

`Box2.equals` has landed. Both corners must match. A box from `(1, 2)` to `(3, 4)` equals a copy of itself and does not equal a box whose upper corner is `(3, 5)`. Neither box changes.

`Box3.setFromArray` has landed. It empties the box, then expands it by each group of three numbers. `[1, 2, 3, 0, 5, 4]` becomes a box from `(0, 2, 3)` to `(1, 5, 4)`. An empty list leaves the box empty. The array is unchanged.

`Box3.setFromCenterAndSize` has landed. Center `(5, 6, 7)` and size `(2, 4, 6)` become a box from `(4, 4, 4)` to `(6, 8, 10)`. The center and the size are unchanged.

`Box3.copy` has landed. It copies both corners into the box. A box from `(1, 2, 3)` to `(4, 5, 6)` copied into an empty box becomes that box. Later changes to the source corners leave the copy alone.

`Box3.clone` has landed. It returns a new box with the same corners. Cloning a box from `(1, 2, 3)` to `(4, 5, 6)` yields that box. Later changes to the source corners leave the clone alone.

`Box3.expandByVector` has landed. It moves the lower corner back by the vector and the upper corner forward by the same vector. A box from `(1, 2, 3)` to `(4, 5, 6)` expanded by `(1, 2, 3)` reaches from `(0, 0, 0)` to `(5, 7, 9)`. The vector is unchanged.

`Box3.expandByScalar` has landed. It grows each side by the scalar. A negative scalar shrinks the box. A box from `(1, 2, 3)` to `(4, 5, 6)` expanded by `1` reaches from `(0, 1, 2)` to `(5, 6, 7)`, and expanding by `-1` returns it to `(1, 2, 3)` and `(4, 5, 6)`.

`Box3.containsPoint` has landed. A point on or inside the bounds counts. In a box from `(1, 2, 3)` to `(4, 5, 6)`, `(2, 3, 4)` and the corner `(1, 2, 3)` are inside, and `(0, 3, 4)` is outside. The point and the box are unchanged.

`Box3.containsBox` has landed. The other box must lie entirely on or inside the bounds. A box from `(1, 2, 3)` to `(7, 8, 9)` contains `(2, 3, 4)` to `(6, 7, 8)` and an identical copy of itself. A box from `(0, 3, 4)` to `(6, 7, 8)` sticks out, so it is not contained. Neither box changes.

`Box3.getParameter` has landed. It writes the point as a fraction of the box width, height, and depth. In a box from `(1, 2, 3)` to `(3, 6, 5)`, the point `(2, 4, 4)` is `(0.5, 0.5, 0.5)` and the lower corner `(1, 2, 3)` is `(0, 0, 0)`. The point and the box are unchanged.

`Box3.intersectsBox` has landed. Overlap and a shared face both count. A box from `(1, 2, 3)` to `(4, 5, 6)` meets `(3, 4, 5)` to `(6, 7, 8)` and the face-touching box from `(4, 2, 3)` to `(6, 5, 6)`. The box from `(5, 2, 3)` to `(6, 5, 6)` stays apart. Neither box changes.

`Box3.clampPoint` has landed. It writes the point clamped into the box. For a box from `(1, 2, 3)` to `(4, 5, 6)`, `(0, 7, 3)` becomes `(1, 5, 3)` and `(2, 3, 4)` stays `(2, 3, 4)`. The point and the box are unchanged.

`Box3.intersectsSphere` has landed. A sphere meets the box when the closest point on the box is inside the sphere, including a tangent. For a box from `(1, 2, 3)` to `(4, 5, 6)`, a sphere at `(0, 3, 4)` with radius `1` touches the face, radius `0.5` stays apart, and a zero-radius sphere at `(2, 3, 4)` is inside. The sphere and the box are unchanged.

`Box3.intersectsPlane` has landed. The plane meets the box when the box's projected range crosses the plane, including a face. For a box from `(1, 2, 3)` to `(4, 5, 6)`, the plane `x = 2` intersects it. The plane `x = 0` and the plane `y = 0` with normal `(0, -1, 0)` stay apart. The plane and the box are unchanged.

`Box3.distanceToPoint` has landed. A point inside the box is distance `0`. For a box from `(1, 2, 3)` to `(4, 5, 6)`, the point `(0, 3, 4)` is distance `1`. The point and the box are unchanged.

`Box3.getBoundingSphere` has landed. It writes a sphere around the box. A box from `(0, 0, 0)` to `(2, 0, 0)` becomes a sphere at `(1, 0, 0)` with radius `1`. An empty box writes an empty sphere, center `(0, 0, 0)` and radius `-1`. The box is unchanged.

`Box3.intersect` has landed. It keeps the overlap of the two boxes. A box from `(1, 2, 3)` to `(5, 6, 7)` intersected with `(3, 0, 4)` to `(4, 4, 8)` becomes `(3, 2, 4)` to `(4, 4, 7)`. A box with no overlap becomes empty. The other box is unchanged.

`Box3.translate` has landed. It adds the offset to both corners. A box from `(1, 2, 3)` to `(4, 5, 6)` moved by `(1, -2, 3)` reaches from `(2, 0, 6)` to `(5, 3, 9)`. The offset is unchanged.

`Box3.equals` has landed. Both corners must match. A box from `(1, 2, 3)` to `(4, 5, 6)` equals a copy of itself and does not equal a box whose upper corner is `(4, 5, 7)`. Neither box changes.

`Box3.toJSON` has landed. It writes both corners as arrays. A box from `(1, 2, 3)` to `(4, 5, 6)` becomes `[1, 2, 3]` and `[4, 5, 6]`. Changing the arrays leaves the box alone.

`Box3.fromJSON` has landed. It reads both corners from arrays. `[1, 2, 3]` and `[4, 5, 6]` become a box from `(1, 2, 3)` to `(4, 5, 6)`. The arrays are unchanged.

`Triangle` has landed. A triangle with no arguments has all three corners at the origin. Passing corners copies them, so later changes to those vectors leave the triangle alone.

`Triangle.getNormal` has landed. It writes a unit normal into the given vector. Corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)` give `(0, 0, 1)`. Three copies of the same point give `(0, 0, 0)`. The corners are unchanged.

`Triangle.getBarycoord` has landed. It writes barycentric weights that sum to 1. For corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)`, the point `(1, 0, 0)` is `(0, 1, 0)`. A degenerate triangle writes `(0, 0, 0)` and returns nothing. The point and the corners are unchanged.

`Triangle.containsPoint` has landed. A point projected onto the triangle plane counts when it lands inside or on the boundary. For corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)`, `(0.25, 0.25, 0)` and the corner `(1, 0, 0)` are inside, and `(2, 0, 0)` is outside. A degenerate triangle contains nothing. The point and the corners are unchanged.

`Triangle.getInterpolation` has landed. It blends three values with the barycentric weights. For corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)`, the point `(0.5, 0.5, 0)` blends `(1, 0, 0)`, `(0, 1, 0)`, and `(0, 0, 1)` into `(0, 0.5, 0.5)`. A degenerate triangle writes `(0, 0, 0)` and returns nothing. The inputs are unchanged.

`Triangle.isFrontFacing` has landed. It is true when the cross product of `(c - b)` and `(a - b)` points against the direction. For corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)`, direction `(0, 0, -1)` is front facing and `(0, 0, 1)` is not. The corners and the direction are unchanged.

`Triangle.set` has landed. It copies three corners into the triangle. Setting `(1, 2, 3)`, `(4, 5, 6)`, and `(7, 8, 9)` stores those values. Later changes to the source vectors leave the triangle alone.

`Triangle.setFromPointsAndIndices` has landed. It copies three indexed points into the corners. Indices `0`, `1`, and `2` on `(0, 0, 1)`, `(1, 2, 3)`, and `(4, 5, 6)` store those corners. Later changes to the source points leave the triangle alone.

`Triangle.copy` has landed. It copies the three corners from another triangle. Copying `(1, 2, 3)`, `(4, 5, 6)`, and `(7, 8, 9)` stores those values. Later changes to the source leave the copy alone.

`Triangle.clone` has landed. It returns a new triangle with the same three corners. Cloning `(1, 2, 3)`, `(4, 5, 6)`, and `(7, 8, 9)` stores those values. Later changes to either triangle leave the other alone.

`Triangle.getArea` has landed. It is half the length of the cross product of `(c - b)` and `(a - b)`. Corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)` have area `0.5`. A triangle with three identical corners has area `0`. The corners are unchanged.

`Triangle.getMidpoint` has landed. It writes the average of the three corners into the target. Corners `(1, 2, 3)`, `(4, 5, 6)`, and `(7, 8, 9)` average to `(4, 5, 6)`. The corners are unchanged.

`Triangle.normal` has landed. It is the instance form of `getNormal`, and it writes the same unit normal as the static function. Corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)` give `(0, 0, 1)`. A triangle with three identical corners writes `(0, 0, 0)`. The corners are unchanged.

`Plane.setFromNormalAndCoplanarPoint` has landed. It copies the normal and sets the constant so the point lies on the plane. Normal `(0, 1, 0)` and point `(1, 2, 3)` give constant `-2`. Later changes to the source normal and point leave the plane alone.

`Plane.setFromCoplanarPoints` has landed. It builds the unit normal from `(c - b)` and `(a - b)`, then places the plane through the first point. Points `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)` give normal `(0, 0, 1)` and constant `0`. Three copies of the same point give a zero normal and constant `0`. The points are unchanged.

`Triangle.getPlane` has landed. It writes the plane through the three corners. Corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)` give normal `(0, 0, 1)` and constant `0`. The corners are unchanged.

`Triangle.barycoord` has landed. It is the instance form of `getBarycoord`. For corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)`, the point `(1, 0, 0)` is `(0, 1, 0)`. A triangle with three identical corners writes `(0, 0, 0)` and returns nothing. The point and the corners are unchanged.

`Triangle.interpolation` has landed. It is the instance form of `getInterpolation`. For corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)`, the point `(0.5, 0.5, 0)` blends `(1, 0, 0)`, `(0, 1, 0)`, and `(0, 0, 1)` into `(0, 0.5, 0.5)`. A triangle with three identical corners writes `(0, 0, 0)` and returns nothing. The inputs are unchanged.

`Triangle.contains` has landed. It is the instance form of `containsPoint`. For corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)`, `(0.25, 0.25, 0)` and the corner `(1, 0, 0)` are inside, and `(2, 0, 0)` is outside. A triangle with three identical corners contains nothing. The point and the corners are unchanged.

`Triangle.front_facing` has landed. It is the instance form of `isFrontFacing`. For corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)`, direction `(0, 0, -1)` is front facing and `(0, 0, 1)` is not. The corners and the direction are unchanged.

`Box3.intersectsTriangle` has landed. It uses the separating-axis test. The box `(0, 0, 0)`–`(1, 1, 1)` meets the triangle with corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)`, and misses the same triangle shifted to `z = 5`. An empty box misses the triangle. The box and the triangle are unchanged.

`Triangle.intersectsBox` has landed. It asks the box whether it meets this triangle. Corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)` meet the box `(0, 0, 0)`–`(1, 1, 1)`, and miss the box `(0, 0, 5)`–`(1, 1, 6)`. An empty box misses the triangle. The triangle and the box are unchanged.

`Triangle.closestPointToPoint` has landed. It writes the closest point on the triangle. For corners `(0, 0, 0)`, `(1, 0, 0)`, and `(0, 1, 0)`, the point `(0.25, 0.25, 3)` projects to `(0.25, 0.25, 0)`, and `(2, -1, 0)` lands on `(1, 0, 0)`. The point and the corners are unchanged.

`Triangle.equals` has landed. It is true when all three corners match. A triangle with corners `(1, 2, 3)`, `(4, 5, 6)`, and `(7, 8, 9)` equals its clone, and differs once the clone's last corner moves to `z = 0`.

`Plane.set` has landed. It copies the normal and stores the constant. Normal `(0, 1, 0)` and constant `-2` are stored. Later changes to the source normal leave the plane alone.

`Plane.negate` has landed. It flips both the normal and the constant. Normal `(0, 1, 0)` and constant `-2` become `(0, -1, 0)` and `2`. The point `(1, 2, 3)` stays on the plane.

`Plane.distanceToSphere` has landed. It subtracts the radius from the signed distance of the center. The plane `x = 0` and a sphere at `(3, 0, 0)` with radius `1` are distance `2` apart. The sphere and the plane are unchanged.

`Plane.projectPoint` has landed. It moves the point along the normal onto the plane. On the plane `x = 0`, the point `(3, 4, 5)` projects to `(0, 4, 5)`. The point and the plane are unchanged.

`Line3` has landed. A line with no arguments has both ends at the origin. Passing the ends copies them, so later changes to those vectors leave the line alone.

`Line3.set` has landed. It copies the start and the end into the line. Setting `(1, 2, 3)` and `(4, 5, 6)` stores those points. Later changes to the source vectors leave the line alone.

`Line3.copy` has landed. It copies both ends from another line. Copying `(1, 2, 3)` and `(4, 5, 6)` stores those points. Later changes to the source leave the copy alone.

`Line3.getCenter` has landed. It writes the midpoint of the two ends. Ends `(1, 2, 3)` and `(3, 6, 9)` average to `(2, 4, 6)`. The line is unchanged.

`Line3.delta` has landed. It writes the end minus the start. Ends `(1, 2, 3)` and `(4, 6, 9)` give `(3, 4, 6)`. The line is unchanged.

`Line3.distanceSq` has landed. It is the squared distance between the ends. Ends `(1, 2, 3)` and `(4, 6, 9)` are `61` apart, squared. The line is unchanged.

`Line3.distance` has landed. It is the distance between the ends. Ends `(1, 2, 3)` and `(4, 6, 3)` are `5` apart. The line is unchanged.

`Line3.at` has landed. It writes the point at parameter `t`. Ends `(1, 2, 3)` and `(5, 6, 7)` give `(3, 4, 5)` at `t = 0.5`, and the start at `t = 0`. The line is unchanged.

`Line3.closestPointToPointParameter` has landed. It returns where the point projects along the segment. On the segment from `(0, 0, 0)` to `(2, 0, 0)`, `(1, 5, 0)` is `0.5` and `(4, 0, 0)` is `2`. Clamping that last value gives `1`. A segment with equal ends returns `0`. The point and the line are unchanged.

`Line3.closestPointToPoint` has landed. It writes the nearest point on the line. On the segment from `(0, 0, 0)` to `(2, 0, 0)`, `(1, 5, 0)` lands on `(1, 0, 0)`. `(4, 0, 0)` stays at `(4, 0, 0)` without clamping and becomes `(2, 0, 0)` with clamping. The point and the line are unchanged.

`Line3.distanceSqToLine3` has landed. It returns the squared distance between two segments and, when given, writes the closest points. The segment from `(0, 0, 0)` to `(2, 0, 0)` and the one from `(0, 1, 0)` to `(2, 1, 0)` are `1` apart, squared, at `(0, 0, 0)` and `(0, 1, 0)`. A segment against itself is `0`. Two points at `(0, 0, 0)` and `(3, 0, 0)` are `9` apart, squared. The segments are unchanged.

`Line3.applyMatrix4` has landed. It transforms both ends. A segment from `(0, 0, 0)` to `(4, 0, 0)` translated by `(1, 2, 3)` becomes `(1, 2, 3)` to `(5, 2, 3)`. The matrix is unchanged.

`Line3.equals` has landed. It is true when both ends match. A segment from `(1, 2, 3)` to `(4, 5, 6)` equals a segment with the same ends, and differs once the other end moves to `z = 0`.

`Line3.clone` has landed. It returns a new segment with the same ends. Cloning `(1, 2, 3)` to `(4, 5, 6)` stores those points. Later changes to either segment leave the other alone.

`Plane.intersectLine` has landed. It writes where a segment crosses the plane. On the plane `x = 0`, the segment from `(-1, 2, 3)` to `(1, 2, 3)` hits `(0, 2, 3)`. The segment from `(1, 0, 0)` to `(2, 0, 0)` misses. A segment lying on the plane returns its start. The segment and the plane are unchanged.

`Plane.intersectsLine` has landed. It is true only when the ends sit on opposite sides of the plane. On the plane `x = 0`, the segment from `(-1, 0, 0)` to `(1, 0, 0)` crosses, the segment from `(1, 0, 0)` to `(2, 0, 0)` stays on one side, and a segment lying on the plane does not count. The segment and the plane are unchanged.

`Plane.intersectsBox` has landed. It asks the box whether it meets this plane. For a box from `(1, 2, 3)` to `(4, 5, 6)`, the plane `x = 2` intersects it and the plane `x = 0` stays apart. An empty box misses the plane. The plane and the box are unchanged.

`Sphere.intersectsPlane` has landed. It is true when the center is at most one radius from the plane. On the plane `x = 0`, a sphere at `(1, 0, 0)` with radius `1` touches, a sphere at `(3, 0, 0)` with radius `1` stays apart, and an empty sphere misses. The sphere and the plane are unchanged.

`Plane.intersectsSphere` has landed. It asks the sphere whether it meets this plane. On the plane `x = 0`, a sphere at `(1, 0, 0)` with radius `1` touches, a sphere at `(3, 0, 0)` with radius `1` stays apart, and an empty sphere misses. The plane and the sphere are unchanged.

`Plane.coplanarPoint` has landed. It writes the normal scaled by the negated constant. The plane `x = 2`, with normal `(1, 0, 0)` and constant `-2`, gives `(2, 0, 0)`. That point lies on the plane. The plane is unchanged.

`Plane.applyMatrix4` has landed. It transforms a point on the plane and the normal. The plane `x = 0` translated by `(2, 0, 0)` becomes the plane `x = 2`, with normal `(1, 0, 0)` and constant `-2`. The matrix is unchanged.

`Plane.translate` has landed. It subtracts the offset's projection on the normal from the constant. The plane `x = 0` moved by `(2, 3, 0)` keeps normal `(1, 0, 0)` and gets constant `-2`. The offset is unchanged.

`Plane.equals` has landed. It is true when the normal and the constant both match. The plane `x = 2` equals another with constant `-2` and normal `(1, 0, 0)`, and differs from constant `-1` or from normal `(1, 1, 0)`.

`Plane.clone` has landed. It returns a new plane with the same normal and constant. Cloning normal `(0, 1, 0)` and constant `-2` stores those values. Later changes to either plane leave the other alone.

`Plane.toJSON` has landed. It writes the normal as an array and keeps the constant beside it. Normal `(0, 1, 0)` and constant `-2` become `[0, 1, 0]` and `-2`. Changing the array leaves the plane alone.

`Plane.fromJSON` has landed. It reads the normal from an array and stores the constant. `[0, 1, 0]` and `-2` become normal `(0, 1, 0)` and constant `-2`. Changing the array afterwards leaves the plane alone.

`Sphere.set` has landed. It copies the center and stores the radius. Center `(1, 2, 3)` and radius `4` are stored. Later changes to the source center leave the sphere alone.

`Sphere.distanceToPoint` has landed. It is the distance from the point to the center, minus the radius. A unit sphere at the origin is `2` from `(3, 0, 0)` and `-1` from the origin. The point and the sphere are unchanged.

`Sphere.intersectsBox` has landed. It asks the box whether it meets this sphere. A sphere at `(0, 3, 4)` with radius `1` touches the box from `(1, 2, 3)` to `(4, 5, 6)`, radius `0.5` stays apart, and a zero-radius sphere at `(2, 3, 4)` counts as inside. The sphere and the box are unchanged.

`Sphere.clampPoint` has landed. It copies an inside point and pulls an outside point onto the surface. A unit sphere at the origin leaves `(0.5, 0, 0)` in place and turns `(2, 0, 0)` into `(1, 0, 0)`. The point and the sphere are unchanged.

`Sphere.getBoundingBox` has landed. It writes the box from the center expanded by the radius. Center `(1, 2, 3)` and radius `1` give the box from `(0, 1, 2)` to `(2, 3, 4)`. An empty sphere writes an empty box. The sphere is unchanged.

`Sphere.translate` has landed. It adds the offset to the center and leaves the radius alone. A unit sphere at the origin moved by `(1, 2, 3)` has center `(1, 2, 3)`. The offset is unchanged.

`Sphere.expandByPoint` has landed. A point already inside leaves the sphere alone. A unit sphere at the origin grown to include `(3, 0, 0)` moves its center to `(1, 0, 0)` and its radius to `2`. An empty sphere becomes a zero-radius sphere at the point. The point is unchanged.

`Sphere.union` has landed. It expands this sphere to enclose another. A unit sphere at the origin unioned with a unit sphere at `(4, 0, 0)` becomes center `(2, 0, 0)` and radius `3`. The same center keeps the larger radius. An empty sphere leaves this one unchanged. The other sphere is unchanged.

`Sphere.equals` has landed. It is true when the center and the radius both match. Center `(1, 2, 3)` and radius `4` equal another sphere with those values, and differ from radius `5` or from center `(0, 2, 3)`. Both spheres are unchanged.

`Sphere.clone` has landed. It returns a new sphere with the same center and radius. Cloning center `(1, 2, 3)` and radius `4` stores those values. Later changes to either sphere leave the other alone.

`Sphere.toJSON` has landed. It writes the center as an array and keeps the radius beside it. Center `(1, 2, 3)` and radius `4` become `[1, 2, 3]` and `4`. Changing the array leaves the sphere alone.

`Sphere.fromJSON` has landed. It reads the center from an array and stores the radius. `[1, 2, 3]` and `4` become center `(1, 2, 3)` and radius `4`. Changing the array afterwards leaves the sphere alone.

`Ray` has landed. A ray with no arguments starts at the origin and points along `(0, 0, -1)`. Passing the origin and the direction copies them, so later changes to those vectors leave the ray alone.

`Ray.set` has landed. It copies the origin and the direction. Origin `(1, 2, 3)` and direction `(4, 5, 6)` are stored. Later changes to those vectors leave the ray alone.

`Ray.copy` has landed. It copies another ray's origin and direction. Copying origin `(1, 2, 3)` and direction `(4, 5, 6)` stores those values. Later changes to the source leave the copy alone.

`Ray.at` has landed. It writes the origin plus the direction scaled by a distance. Origin `(1, 2, 3)` and direction `(0, 1, 0)` at distance `0.5` is `(1, 2.5, 3)`, and distance `0` is the origin. The ray is unchanged.

`Ray.lookAt` has landed. It points the direction from the origin at a position and normalizes it. Origin `(1, 2, 3)` looking at `(1, 5, 3)` gets direction `(0, 1, 0)`. The position is unchanged.

`Ray.recast` has landed. It moves the origin along the direction and leaves the direction alone. Origin `(1, 2, 3)` and direction `(0, 1, 0)` recast by `0.5` has origin `(1, 2.5, 3)`.

`Ray.closestPointToPoint` has landed. It writes the nearest point on the ray. The default ray, pointing along `(0, 0, -1)`, meets `(4, 5, -2)` at `(0, 0, -2)`. A point behind the origin, such as `(4, 5, 3)`, stays at the origin. The point and the ray are unchanged.

`Ray.distanceSqToPoint` has landed. It is the squared distance to the closest point on the ray. The default ray is `41` from `(4, 5, -2)`, `50` from `(4, 5, 3)` behind the origin, and `0` from `(0, 0, -2)` on the ray. The point and the ray are unchanged.

`Ray.distanceToPoint` has landed. It is the square root of that squared distance. The default ray is `5` from `(3, 4, -2)`, `3` from `(0, 0, 3)` behind the origin, and `0` from `(0, 0, -2)` on the ray. The point and the ray are unchanged.

`Ray.distanceSqToSegment` has landed. It returns the squared distance from the ray to a segment and, when given, writes the closest points. A ray from the origin along `(1, 0, 0)` meets the segment from `(2, -1, 0)` to `(2, 1, 0)` at `(2, 0, 0)`, so the squared distance is `0`. The parallel segment from `(0, 1, 0)` to `(2, 1, 0)` is `1` away, squared. The ray and the endpoints are unchanged.

`Ray.intersectSphere` has landed. It writes the first intersection in front of the ray. A ray from `(-2, 0, 0)` along `(1, 0, 0)` meets the unit sphere at `(-1, 0, 0)`. A ray from `(0, 3, 0)` along `(1, 0, 0)` misses. The default ray starts inside that sphere and exits at `(0, 0, -1)`. An empty sphere misses. The ray and the sphere are unchanged.

`Ray.intersectsSphere` has landed. It is true when the squared distance from the ray to the center is within the squared radius. A ray from `(-2, 0, 0)` along `(1, 0, 0)` meets the unit sphere. A ray from `(0, 3, 0)` misses, and a ray from `(2, 0, 0)` along `(1, 0, 0)` leaves the sphere behind. The default ray starts inside. An empty sphere misses. The ray and the sphere are unchanged.

`Ray.distanceToPlane` has landed. It returns the distance from the origin to the plane, or nothing when the ray misses. A ray from `(-2, 0, 0)` along `(1, 0, 0)` meets the plane `x = 0` at distance `2`. A ray pointing the other way from `(1, 0, 0)` misses. A ray parallel to the plane misses unless it already lies on it, in which case the distance is `0`. The ray and the plane are unchanged.

`Ray.intersectPlane` has landed. It writes the point at that distance. The same ray meets the plane `x = 0` at `(0, 0, 0)`. A ray from `(1, 0, 0)` along `(1, 0, 0)` misses and leaves the target alone. The ray and the plane are unchanged.

`Ray.intersectsPlane` has landed. It is true when the origin lies on the plane or the ray points toward it. A ray from `(-2, 0, 0)` along `(1, 0, 0)` meets the plane `x = 0`. A ray from `(1, 0, 0)` along `(1, 0, 0)` points away. A ray parallel to the plane misses unless its origin is already on the plane. The ray and the plane are unchanged.

`Ray.intersectBox` has landed. It writes the first intersection in front of the ray. A ray from `(-1, 0.5, 0.5)` along `(1, 0, 0)` meets the box from `(0, 0, 0)` to `(1, 1, 1)` at `(0, 0.5, 0.5)`. A ray from `(-1, 2, 0.5)` along `(1, 0, 0)` misses and leaves the target alone. The ray and the box are unchanged.

`Ray.intersectsBox` has landed. It asks whether that intersection exists. The same ray from `(-1, 0.5, 0.5)` meets the unit box, and the ray from `(-1, 2, 0.5)` misses. The ray and the box are unchanged.

`Ray.intersectTriangle` has landed. It writes the watertight intersection with a triangle. A ray from `(0.25, 0.25, 1)` along `(0, 0, -1)` meets the triangle `(0, 0, 0)`, `(1, 0, 0)`, `(0, 1, 0)` at `(0.25, 0.25, 0)`. A ray from `(2, 2, 1)` misses. Coming from below, backface culling misses and turning it off hits the same point. The vertices and the ray are unchanged.

`Ray.applyMatrix4` has landed. It transforms the origin and the direction. The default ray, translated by `(1, 2, 3)`, has origin `(1, 2, 3)` and keeps direction `(0, 0, -1)`. The matrix is unchanged.

`Ray.equals` has landed. It is true when the origin and the direction both match. Origin `(1, 2, 3)` and direction `(4, 5, 6)` equal another ray with those values, and differ when the origin becomes `(0, 2, 3)` or the direction's z becomes `0`. Both rays are unchanged.

`Ray.clone` has landed. It returns a new ray with the same origin and direction. Cloning origin `(1, 2, 3)` and direction `(4, 5, 6)` stores those values. Later changes to either ray leave the other alone.

`Color.set` has landed. It stores three linear channels. `(0.25, 0.5, 0.75)` is stored as those components.

`Color.setScalar` has landed. It writes the same value into every channel. `0.25` becomes `(0.25, 0.25, 0.25)`.

`MathUtils.clamp` has landed. It limits a number to a closed range. `1.5` clamped to `[0, 1]` is `1`, `-0.5` is `0`, and `0.25` stays `0.25`.

`MathUtils.euclideanModulo` has landed. It wraps the remainder so the result has the same sign as the divisor. `1.25` modulo `1` is `0.25`, and `-0.25` modulo `1` is `0.75`.

`Color.setHSL` has landed. It writes linear channels from hue, saturation, and lightness, already in the linear working space. Hue `0`, saturation `1`, lightness `0.5` is `(1, 0, 0)`. Saturation `0` and lightness `0.25` is `(0.25, 0.25, 0.25)`. Hue `1` wraps to the same red.

`Color.setStyle` parses CSS strings, so it stays later. `Color.copySRGBToLinear` has landed. It copies a color and converts each channel from sRGB to linear. `(0, 0.5, 1)` becomes `(0, 0.2140411404715882, 1)`. The source color stays `(0, 0.5, 1)`.

`Color.copyLinearToSRGB` has landed. It copies a color and converts each channel from linear to sRGB. `(0, 0.5, 1)` becomes `(0, 0.7353606352856507, 0.9999999999999999)`. The source color stays `(0, 0.5, 1)`.

`Color.convertSRGBToLinear` has landed. It converts this color's own channels from sRGB to linear. `(0, 0.5, 1)` becomes `(0, 0.2140411404715882, 1)`.

`Color.convertLinearToSRGB` has landed. It converts this color's own channels from linear to sRGB. `(0, 0.5, 1)` becomes `(0, 0.7353606352856507, 0.9999999999999999)`.

`Color.getHexString` has landed. It writes six lowercase hexadecimal digits. Linear black is `000000`. `setHex(0x00FF00)` reads back as `00ff00`.

`Color.getHSL` has landed. It reads hue, saturation, and lightness from the linear channels. Linear red `(1, 0, 0)` is hue `0`, saturation `1`, lightness `0.5`. `(0.25, 0.25, 0.25)` is hue `0`, saturation `0`, lightness `0.25`. The color is unchanged.

`Color.getRGB` has landed. It writes the linear channels into a target color. `(0.25, 0.5, 0.75)` is copied as those components. The source color is unchanged.

`Color.getStyle` has landed. It writes an sRGB `rgb()` string. Linear red `(1, 0, 0)` is `rgb(255,0,0)`. Linear black is `rgb(0,0,0)`. The color is unchanged.

`Color.offsetHSL` has landed. It adds to hue, saturation, and lightness, then writes the linear channels back. Linear red offset by `(0, 0, 0)` stays `(1, 0, 0)`. `(0.25, 0.25, 0.25)` offset by `(0, 0, 0.25)` becomes `(0.5, 0.5, 0.5)`.

`Color.add` has landed. It adds another color's channels. `(0.25, 0.5, 0.75)` plus `(0.25, 0.5, 0.25)` becomes `(0.5, 1, 1)`. The other color is unchanged.

`Color.addColors` has landed. It stores the sum of two colors. `(0.25, 0.5, 0.75)` plus `(0.25, 0.5, 0.25)` is written as `(0.5, 1, 1)`. Both inputs stay unchanged.

`Color.addScalar` has landed. It adds one value to every channel. `(0.25, 0.5, 0.75)` plus `0.25` becomes `(0.5, 0.75, 1)`.

`Color.sub` has landed. It subtracts another color and keeps each channel at or above zero. `(0.5, 1, 0.75)` minus `(0.25, 0.25, 0.25)` becomes `(0.25, 0.75, 0.5)`. `(0.25, 0.5, 0.75)` minus `(0.5, 0, 0)` becomes `(0, 0.5, 0.75)`. The other color is unchanged.

`Color.multiply` has landed. It multiplies channels. `(0.5, 0.25, 1)` times `(0.5, 0.5, 0.25)` becomes `(0.25, 0.125, 0.25)`. The other color is unchanged.

`Color.multiplyScalar` has landed. It multiplies every channel by one value. `(0.5, 0.25, 1)` times `0.5` becomes `(0.25, 0.125, 0.5)`.

`Color.lerp` is already present. `Color.lerpColors` has landed. It stores the blend of two colors. Alpha `0.25` from `(0, 0, 0)` toward `(1, 0.5, 0)` is `(0.25, 0.125, 0)`. Alpha `0` keeps the first color and alpha `1` keeps the second. Both inputs stay unchanged.

`MathUtils.lerp` has landed. It blends two numbers. `0.25` of the way from `0` to `1` is `0.25`. From `1` to `5`, factor `0` stays `1` and factor `1` stays `5`.

`Color.lerpHSL` has landed. It blends hue, saturation, and lightness, then writes the linear channels back. Halfway from `(0.25, 0.25, 0.25)` toward `(0.75, 0.75, 0.75)` is `(0.5, 0.5, 0.5)`. Factor `0` leaves `(0.25, 0.25, 0.25)`. The other color is unchanged.

`Color.setFromVector3` has landed. It copies the vector components into the channels. `(0.25, 0.5, 0.75)` is stored as those components. The vector is unchanged.

`Color.applyMatrix3` has landed. It transforms the channels by a column-major 3×3 matrix. Swapping the first two axes turns `(0.25, 0.5, 0.75)` into `(0.5, 0.25, 0.75)`. The matrix is unchanged.

`Color.equals` has landed. It is true when all three channels match. `(0.25, 0.5, 0.75)` equals another color with those values, and differs when any channel is `0`. Both colors are unchanged.

`Color.fromArray` has landed. It reads three channels from an array. The default offset reads `(1, 2, 3)` from `[1, 2, 3, 0.25, 0.5, 0.75]`. Offset `3` reads `(0.25, 0.5, 0.75)`. The array is unchanged.

`Color.toArray` has landed. It writes three channels. `(0.25, 0.5, 0.75)` becomes `[0.25, 0.5, 0.75]`. Writing at offset `1` into `[9, 8, 7, 6]` leaves `9` and stores the channels after it. A one-element array at offset `2` grows to `[4, 0, 0.25, 0.5, 0.75]`. The color is unchanged.

`Euler.clone` has landed. It returns a new euler with the same angles and order. Cloning `(1, 2, 3)` in order `ZYX` stores those values. Later changes to either euler leave the other alone. The change callback is not copied.

`Euler.setFromVector3` has landed. It writes the vector components as angles. `(1, 2, 3)` is stored as those angles. Omitting the order keeps `XYZ`. Passing `ZYX` stores that order. The vector is unchanged.

`Euler.equals` has landed. It is true when the angles and the order both match. `(1, 2, 3)` in order `ZYX` equals another euler with those values, and differs when `x` is `0` or the order is `XYZ`. Both eulers are unchanged.

`Euler.fromArray` has landed. It reads three angles from an array. The order is a separate argument, because the array holds only numbers. `[1, 2, 3]` written onto an euler in order `YXZ` stores those angles and keeps `YXZ`. Passing `ZYX` stores that order. The array is unchanged.

`Euler.toArray` has landed. It writes three angles and returns the order beside the array. `(1, 2, 3)` in order `ZYX` becomes `[1, 2, 3]` and `ZYX`. Writing at offset `1` into `[9, 8, 7, 6]` leaves `9` and stores the angles after it. A one-element array at offset `2` grows to `[4, 0, 1, 2, 3]`. The euler is unchanged.

`Frustum.set` has landed. It copies six planes. Constants `1` through `6`, with the second normal `(0, 1, 0)`, are stored on the frustum. Later changes to those planes leave the frustum alone.

`Frustum.copy` has landed. It copies another frustum's six planes. Those same constants and the second normal `(0, 1, 0)` are stored on the copy. Later changes to the source frustum leave the copy alone.

`Frustum.containsPoint` has landed. A point is inside when it is on the inner side of every plane, including the plane itself. The unit-cube frustum accepts `(0.5, 0.5, 0.5)` and `(0, 0.5, 0.5)`, and rejects `(-1, 0.5, 0.5)`. The point and the frustum are unchanged.

`Frustum.clone` has landed. It returns a new frustum with the same six planes. Constants `1` through `6` and the second normal `(0, 1, 0)` are stored on the clone. Later changes to either frustum leave the other alone.

`Matrix3.extractBasis` has landed. It writes the three columns into three vectors. The matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` gives axes `(1, 4, 7)`, `(2, 5, 8)`, and `(3, 6, 9)`. The matrix is unchanged.

`Matrix3.multiply` calls `multiplyMatrices`, so that product lands first. `Matrix3.multiplyMatrices` has landed. It stores the product of two matrices. Scaling by `(2, 3, 4)` times the matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` writes elements `[2, 12, 28, 4, 15, 32, 6, 18, 36]`. Both inputs stay unchanged.

`Matrix3.multiply` has landed. It post-multiplies this matrix by another. Scaling by `(2, 3, 4)` times the matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` writes elements `[2, 12, 28, 4, 15, 32, 6, 18, 36]`. The other matrix stays unchanged.

`Matrix3.premultiply` has landed. It pre-multiplies this matrix by another. The matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` times scaling by `(2, 3, 4)` writes elements `[2, 8, 14, 6, 15, 24, 12, 24, 36]`. The other matrix stays unchanged.

`Matrix3.multiplyScalar` has landed. It multiplies every element by a scalar. The matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` times `2` writes elements `[2, 8, 14, 4, 10, 16, 6, 12, 18]`.

`Matrix3.transposeIntoArray` has landed. It writes the transpose into an array and leaves the matrix unchanged. The matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` writes `[1, 2, 3, 4, 5, 6, 7, 8, 9]`. A short array grows with zeros up to nine elements.

`Matrix3.setUvTransform` has landed. It builds a UV matrix from offset, repeat, rotation, and center. Offset `(0.25, 0.5)`, repeat `(2, 3)`, rotation `0`, and center `(1, 0)` write elements `[2, 0, 0, 0, 3, 0, -0.75, 0.5, 1]`.

`Matrix3.scale` calls `makeScale`, so that constructor lands first. `Matrix3.makeScale` has landed. It stores a 2D scale. Scaling by `(2, 3)` writes elements `[2, 0, 0, 0, 3, 0, 0, 0, 1]`.

`Matrix3.scale` has landed. It pre-multiplies a 2D scale. Scaling the matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` by `(2, 3)` writes elements `[2, 12, 7, 4, 15, 8, 6, 18, 9]`.

`Matrix3.rotate` calls `makeRotation`, so that constructor lands first. `Matrix3.makeRotation` has landed. It stores a counterclockwise 2D rotation. Angle `0` writes the identity `[1, 0, 0, 0, 1, 0, 0, 0, 1]`.

`Matrix3.rotate` has landed. It pre-multiplies a rotation of the negated angle. Rotating the matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` by angle `0` leaves elements `[1, 4, 7, 2, 5, 8, 3, 6, 9]`.

`Matrix3.translate` calls `makeTranslation`, so that constructor lands first. `Matrix3.makeTranslation` has landed. It stores a 2D translation from two numbers. Translating by `(0.25, 0.5)` writes elements `[1, 0, 0, 0, 1, 0, 0.25, 0.5, 1]`. The `Vector2` argument stays out.

`Matrix3.translate` has landed. It pre-multiplies a 2D translation. Translating the matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` by `(0.25, 0.5)` writes elements `[2.75, 7.5, 7, 4, 9, 8, 5.25, 10.5, 9]`.

`Matrix3.equals` has landed. It compares all nine elements. The matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` matches a copy, and differs once the first element is `0`.

`Matrix3.fromArray` has landed. It reads nine column-major elements. `[1, 4, 7, 2, 5, 8, 3, 6, 9]` stores those values. The same nine numbers at offset `1` in a longer array store the same matrix.

`Matrix3.toArray` has landed. It writes nine column-major elements. The matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` writes `[1, 4, 7, 2, 5, 8, 3, 6, 9]`. Offset `1` into a ten-element array keeps the first value and writes the matrix after it. A one-element array at offset `2` grows to length `11`. The matrix is unchanged.

`Matrix4.copyPosition` has landed. It copies only the translation. A translation of `(0.25, 0.5, 0.75)` is stored in elements `12`, `13`, and `14`, while element `0` and element `15` stay `1`. Later changes to the source leave the copy alone.

`Matrix4.setFromMatrix3` has landed. It copies a 3×3 matrix into the upper left and writes a homogeneous last row and column. The matrix with rows `(1, 2, 3)`, `(4, 5, 6)`, `(7, 8, 9)` writes `[1, 4, 7, 0, 2, 5, 8, 0, 3, 6, 9, 0, 0, 0, 0, 1]`. Later changes to the 3×3 matrix leave the 4×4 matrix alone.

`Matrix4.extractBasis` has landed. It writes the first three columns into three vectors. Scaling by `(2, 3, 4)` gives axes `(2, 0, 0)`, `(0, 3, 0)`, and `(0, 0, 4)`. A matrix whose affine determinant is `0` writes the identity axes instead. The matrix is unchanged.

`Matrix4.makeBasis` has landed. It stores three axes and a zero translation. Axes `(2, 0, 0)`, `(0, 3, 0)`, and `(0, 0, 4)` write elements `0`, `5`, `10`, and `15` as `2`, `3`, `4`, and `1`. Later changes to an axis leave the matrix alone.

`Matrix4.multiplyScalar` has landed. It multiplies every element by a scalar. A translation of `(0.25, 0.5, 0.75)` times `2` writes elements `0`, `5`, `10`, and `15` as `2`, and elements `12`, `13`, and `14` as `0.5`, `1`, and `1.5`.

`Matrix4.makeRotationX` has landed. It stores a rotation around the X axis. Angle `0` replaces a translation of `(0.25, 0.5, 0.75)` with the identity: elements `0`, `5`, `10`, and `15` are `1`, and element `12` is `0`.

`Matrix4.makeRotationY` has landed. It stores a rotation around the Y axis. Angle `0` replaces a translation of `(0.25, 0.5, 0.75)` with the identity: elements `0`, `5`, `10`, and `15` are `1`, and elements `2` and `8` are `0`.

`Matrix4.makeRotationZ` has landed. It stores a rotation around the Z axis. Angle `0` replaces a translation of `(0.25, 0.5, 0.75)` with the identity: elements `0`, `5`, `10`, and `15` are `1`, and elements `1` and `4` are `0`.

`Matrix4.makeRotationAxis` has landed. It stores a rotation around a unit axis. Angle `0` around `(0, 1, 0)` replaces a translation of `(0.25, 0.5, 0.75)` with the identity: elements `0`, `5`, `10`, and `15` are `1`, and element `12` is `0`. Later changes to the axis leave the matrix alone.

`Matrix4.makeScale` has landed. It stores a scale. Scaling by `(2, 3, 4)` replaces a translation of `(0.25, 0.5, 0.75)`: elements `0`, `5`, `10`, and `15` are `2`, `3`, `4`, and `1`, and element `12` is `0`.

`Matrix4.makeShear` has landed. It stores six shear terms. Shearing by `xy = 2`, `xz = 3`, `yx = 4`, `yz = 5`, `zx = 6`, and `zy = 7` replaces a translation of `(0.25, 0.5, 0.75)` and writes `[1, 2, 3, 0, 4, 1, 5, 0, 6, 7, 1, 0, 0, 0, 0, 1]`.

`Matrix4.fromArray` has landed. It reads sixteen column-major elements. The scale `(2, 3, 4)` is stored from `[2, 0, 0, 0, 0, 3, 0, 0, 0, 0, 4, 0, 0, 0, 0, 1]`. The same sixteen numbers at offset `1` store the same matrix.

`Matrix4.toArray` has landed. It writes sixteen column-major elements. Scaling by `(2, 3, 4)` writes `[2, 0, 0, 0, 0, 3, 0, 0, 0, 0, 4, 0, 0, 0, 0, 1]`. Offset `1` into a seventeen-element array keeps the first value and writes the matrix after it. A one-element array at offset `2` grows to length `18`. The matrix is unchanged.

`Quaternion.slerpFlat` has landed. It writes a spherical interpolation of two flat quaternions. Identical quaternions `(0, 0, 0, 1)` at offset `1`, with factor `0.25`, write `[0, 0, 0, 1]`. Both source arrays stay unchanged.

`Quaternion.multiplyQuaternionsFlat` has landed. It multiplies two flat quaternions into an array and returns that array. The identity `(0, 0, 0, 1)` times `(0.25, 0.5, 0.75, 1)` at offset `1` writes `[0.25, 0.5, 0.75, 1]`. Both source arrays stay unchanged.

`Quaternion` `x` setter has landed as `setX`. It writes `x` and runs the change callback. Setting `x` to `0.25` on `(0, 0.5, 0.25, 1)` stores that `x` and leaves the other components. The callback runs once.

`Quaternion` `y` setter has landed as `setY`. It writes `y` and runs the change callback. Setting `y` to `0.5` on `(0.25, 0, 0.25, 1)` stores that `y` and leaves the other components. The callback runs once.

`Quaternion` `z` setter has landed as `setZ`. It writes `z` and runs the change callback. Setting `z` to `0.25` on `(0.25, 0.5, 0, 1)` stores that `z` and leaves the other components. The callback runs once.

`Quaternion` `w` setter has landed as `setW`. It writes `w` and runs the change callback. Setting `w` to `0.75` on `(0.25, 0.5, 0.25, 1)` stores that `w` and leaves the other components. The callback runs once.

`Quaternion.setFromUnitVectors` has landed. It stores the rotation that takes one unit direction onto another. `(1, 0, 0)` onto itself is `(0, 0, 0, 1)`. `(1, 0, 0)` onto `(-1, 0, 0)` is `(0, 1, 0, 0)`. The direction vectors stay unchanged.

`Quaternion.angleTo` has landed. It returns the angle in radians between two quaternions. The identity against itself is `0`, and against `(0, 0, 0, -1)` is also `0`. Both quaternions stay unchanged.

`Quaternion.rotateTowards` has landed. It rotates toward another quaternion by an angular step and does not pass the target. The identity rotated toward `(0, 0, 0, -1)` by `1` stays `(0, 0, 0, 1)`. The change callback does not run. The target stays unchanged.

`Quaternion.lengthSq` has landed. It returns the sum of the squared components. `(0.25, 0.5, 0.25, 0.75)` has squared length `0.9375`. The quaternion stays unchanged.

`Quaternion.slerpQuaternions` has landed. It copies the first quaternion and interpolates toward the second. `(0, 1, 0, 0)` toward itself with factor `0.25` stays `(0, 1, 0, 0)`. Later changes to either source leave the result alone.

`Quaternion.random` has landed. It stores a uniformly random unit quaternion. The squared length is `1`. The change callback runs once.

`Quaternion.equals` has landed. It compares all four components. `(0.25, 0.5, 0.25, 0.75)` matches a copy, and differs once `w` is `0`.

`Quaternion.fromArray` has landed. It reads four components and runs the change callback. `[0.25, 0.5, 0.25, 0.75]` stores those components. The same four numbers at offset `1` in a longer array store the same quaternion.

`Quaternion.toArray` has landed. It writes four components and leaves the quaternion unchanged. `(0.25, 0.5, 0.25, 0.75)` fills a new array. The same components at offset `1` keep the leading value. A one-element array at offset `2` grows to length `6` and pads the gap with `0`. The change callback does not run. `Quaternion.fromBufferAttribute` reads a `BufferAttribute`, so it stays with attributes.

`Quaternion.toJSON` has landed. It returns `[x, y, z, w]`. `(0.25, 0.5, 0.25, 0.75)` serializes to those four numbers. The quaternion is unchanged and the change callback does not run.

`MathUtils.mapLinear` has landed. It maps a number from one range onto another. `0.25` from `[0, 1]` onto `[0, 4]` is `1`. The endpoints `0` and `1` map onto `10` and `20`.

`MathUtils.inverseLerp` has landed. It returns where a number sits between two endpoints. `1` between `0` and `4` is `0.25`. The endpoints themselves are `0` and `1`. Equal endpoints return `0`.

`MathUtils.damp` has landed. It eases from the current value toward a target. With `lambda` `0` or `dt` `0`, `4` toward `8` stays `4`. Equal values stay put. From `0` toward `4` with `lambda` `1` and `dt` `1` is about `2.5284822353142307`.

`MathUtils.pingpong` has landed. It folds a value back and forth between `0` and a length. With the default length `1`, `0.25` stays `0.25`, `1.25` folds to `0.75`, and both `0` and `2` are `0`. A negative `-0.25` folds to `0.25`. Length `2` folds `3` to `1`.

`MathUtils.smoothstep` has landed. It eases between two endpoints and clamps outside them. Below `0` and at `0` the result is `0`. At `1` and above it the result is `1`. The midpoint `0.5` stays `0.5`. `0.25` between `0` and `1` is `0.15625`.

`MathUtils.smootherstep` has landed. It eases the same way, with flat first and second derivatives at the endpoints. Below `0` and at `0` the result is `0`. At `1` and above it the result is `1`. The midpoint `0.5` stays `0.5`. `0.25` between `0` and `1` is `0.103515625`.

`MathUtils.randInt` has landed. It returns a number from a closed range. `0` through `0` is `0`, and `2` through `2` is `2`. A draw from `1` through `3` is `1`, `2`, or `3`.

`MathUtils.randFloat` has landed. It returns a number from a half-open range. `2` through `2` is `2`. A draw from `0` up to `1` stays in `[0, 1)`. A draw from `1` up to `4` stays in `[1, 4)`.

`MathUtils.randFloatSpread` has landed. It returns a number centered on `0`. A range of `0` is `0`. A range of `4` stays in `(-2, 2]`.

`MathUtils.seededRandom` has landed. It draws from the Mulberry32 sequence in `[0, 1)`. The default seed `1234567` starts at `0.6074679309967905`. Seed `1` starts at `0.6270739405881613`, then `0.002735721180215478`, then `0.5274470399599522`. Passing seed `1` again repeats the first value.

`MathUtils.isPowerOfTwo` has landed. It accepts a positive integer that is a power of two. `1`, `2`, and `8` are powers of two. `3`, `6`, `0`, `-2`, and `1.5` are not.

`MathUtils.ceilPowerOfTwo` has landed. It returns the smallest power of two that is not below the value. `0.5` stays `0.5`. `1` stays `1`. `3` and `4` become `4`. `5` becomes `8`. `9` becomes `16`.

`MathUtils.floorPowerOfTwo` has landed. It returns the largest power of two that is not above the value. `0.5` stays `0.5`, and `0.6` drops to `0.5`. `1` stays `1`. `3` drops to `2`. `4` stays `4`, and `5` drops to `4`. `9` drops to `8`.

`MathUtils.setQuaternionFromProperEuler` has landed. It writes an intrinsic proper Euler rotation into a quaternion. Angles `0`, `0`, `0` in order `XYX` store the identity `(0, 0, 0, 1)` and run the change callback. Angles `0.5`, `0.25`, `0.125` in order `XYX` store about `(0.3050397769831039, 0.12248959836900034, 0.023239781325963473, 0.9441434982635958)`. The same angles in order `ZYZ` store about `(-0.023239781325963473, 0.12248959836900034, 0.3050397769831039, 0.9441434982635958)`.

`MathUtils.denormalize` has landed. The typed-array constructor is `ArrayComponentType`, because `math` has no typed arrays. `Float32` leaves `0.25` as `0.25`. `Uint8` and `Uint8Clamped` map `255` to `1` and `0` to `0`. `Uint16` maps `65535` to `1`, and `Uint32` maps `4294967295` to `1`. `Int8` maps `-127` and `-128` to `-1`. `Int16` maps `-32768` to `-1`, and `Int32` maps `-2147483648` to `-1`.

`MathUtils.normalize` has landed. It packs a unit-range value back into the same component type. `Float32` leaves `0.25` as `0.25`. `Uint8` maps `0` to `0`, `0.25` to `64`, and `1` to `255`. `Uint8Clamped` also maps `1` to `255`. `Uint16` maps `1` to `65535`, and `Uint32` maps `1` to `4294967295`. `Int8` maps `1` to `127` and `-1` to `-127`. `Int16` maps `1` to `32767`, and `Int32` maps `1` to `2147483647`.

`MathUtils.generateUUID` has landed. It returns a 36-character lowercase UUID. The hyphens sit at indexes `8`, `13`, `18`, and `23`. The version character is `4`. The variant character is `8`, `9`, `a`, or `b`.

`Matrix2` has landed. `new` stores the column-major identity `[1, 0, 0, 1]`.

`Matrix2.set` has landed. Its arguments are row-major and the storage is column-major. `set(11, 12, 21, 22)` stores `[11, 21, 12, 22]`.

`Matrix2.identity` has landed. It replaces those elements with the column-major identity `[1, 0, 0, 1]`.

`Matrix2.fromArray` has landed. It reads four column-major elements. `[11, 21, 12, 22]` stores those elements. The same four numbers at offset `1` in a longer array store the same matrix.

`SphericalHarmonics3` has landed. `new` stores nine zero coefficients. The first and the last are `(0, 0, 0)`.

`SphericalHarmonics3.set` has landed. It copies nine coefficients. The first becomes `(1, 2, 3)` and the last becomes `(4, 5, 6)`. The middle stays `(0, 0, 0)`. Changing the source afterward leaves the copy at `(1, 2, 3)`.

`SphericalHarmonics3.zero` has landed. It clears every coefficient. After the first is `(1, 2, 3)` and the last is `(4, 5, 6)`, both return to `(0, 0, 0)`.

`SphericalHarmonics3.getAt` has landed. It writes the radiance along a unit normal and leaves the normal unchanged. A zero probe along `(0, 1, 0)` writes `(0, 0, 0)`. With the first coefficient `(1, 0, 0)`, that direction writes `(0.282095, 0, 0)`. With only the fourth coefficient `(1, 0, 0)` and normal `(1, 0, 0)`, the result is `(0.488603, 0, 0)`.

`SphericalHarmonics3.getIrradianceAt` has landed. It writes the irradiance along a unit normal and leaves the normal unchanged. A zero probe along `(0, 1, 0)` writes `(0, 0, 0)`. With the first coefficient `(1, 0, 0)`, that direction writes `(0.886227, 0, 0)`. With only the fourth coefficient `(1, 0, 0)` and normal `(1, 0, 0)`, the result is `2 * 0.511664` on x.

`SphericalHarmonics3.add` has landed. It adds nine coefficients and leaves the source unchanged. `(1, 2, 3)` plus `(4, 5, 6)` is `(5, 7, 9)`. The last coefficient `(1, 0, 0)` plus `(0, 1, 0)` is `(1, 1, 0)`. The middle stays `(0, 0, 0)`.

`SphericalHarmonics3.addScaledSH` has landed. It adds a scaled copy and leaves the source unchanged. `(1, 2, 3)` plus twice `(4, 5, 6)` is `(9, 12, 15)`. The last coefficient `(1, 0, 0)` plus twice `(0, 1, 0)` is `(1, 2, 0)`. The middle stays `(0, 0, 0)`.

`SphericalHarmonics3.scale` has landed. It multiplies every coefficient by the same factor. `(1, 2, 3)` scaled by `2` is `(2, 4, 6)`. The last coefficient `(4, 5, 6)` becomes `(8, 10, 12)`. The middle stays `(0, 0, 0)`.

`SphericalHarmonics3.lerp` has landed. It blends toward another probe and leaves that probe unchanged. Factor `0` stays at `(0, 0, 0)`. Factor `0.25` of the way from `(0, 0, 0)` toward `(4, 8, 12)` is `(1, 2, 3)`. The last coefficient moves a quarter of the way toward `(4, 0, 0)`, which is `(1, 0, 0)`.

`SphericalHarmonics3.equals` has landed. It compares all nine coefficients. Two zero probes match. They differ once the first coefficient is `(1, 2, 3)`. They match again when both hold that vector, and differ once the last coefficient is `(4, 5, 6)`.

`SphericalHarmonics3.copy` has landed. It copies nine coefficients. The first becomes `(1, 2, 3)` and the last becomes `(4, 5, 6)`. The middle stays `(0, 0, 0)`. Changing the source afterward leaves the copy at `(1, 2, 3)`.

`SphericalHarmonics3.clone` has landed. It returns a new probe with the same coefficients. The first is `(1, 2, 3)` and the last is `(4, 5, 6)`. The middle stays `(0, 0, 0)`. Changing the original afterward leaves the clone at `(1, 2, 3)`.

`SphericalHarmonics3.fromArray` has landed. It reads nine coefficients as flat triples. The first triple `(1, 2, 3)` and the last triple `(4, 5, 6)` land in those coefficients. The middle stays `(0, 0, 0)`. The same 27 numbers at offset `1` store the same probe, and the source array is unchanged.

`SphericalHarmonics3.toArray` has landed. It writes 27 numbers and leaves the probe unchanged. `(1, 2, 3)` and `(4, 5, 6)` occupy the first and last triples. A one-element array at offset `1` keeps the leading value and grows to length `28`. The same array at offset `2` grows to length `29` and pads the gap with `0`.

`SphericalHarmonics3.getBasisAt` has landed. It writes nine basis weights for a unit normal and leaves the normal unchanged. An empty array grows to length `9`. Along `(0, 1, 0)`, the first weight is `0.282095`, the second is `0.488603`, the seventh is `-0.315392`, and the ninth is `-0.546274`.

`FrustumArray` has landed. `new` stores no frustums and a count of `0`. The coordinate system starts as WebGL.

`FrustumArray.intersectsSphere` has landed. With `count` `0` it is false, including when a frustum is already stored. A unit-cube frustum and a sphere of radius `0.25` at `(0.5, 0.5, 0.5)` is true. The same radius at `(-2, 0, 0)` stays false while `count` is `1`, and becomes true once a second frustum with constant `10` is counted. `setFromArrayCamera` reads an `ArrayCamera`, `intersectsObject` reads an `Object3D`, and `intersectsSprite` reads a sprite, so those three stay out of `math`.

`FrustumArray.intersectsBox` has landed. With `count` `0` it is false, including when a frustum is already stored. A unit-cube frustum accepts the box from `(0.25, 0.25, 0.25)` to `(0.75, 0.75, 0.75)`. The box from `(-2, -2, -2)` to `(-1, -1, -1)` stays false while `count` is `1`, and becomes true once a second frustum with constant `10` is counted.

`FrustumArray.containsPoint` has landed. With `count` `0` it is false, including when a frustum is already stored. A unit-cube frustum contains `(0.5, 0.5, 0.5)` and the face point `(0, 0.5, 0.5)`. The point `(-1, 0.5, 0.5)` stays false while `count` is `1`, and becomes true once a second frustum with constant `10` is counted.

`FrustumArray.copy` has landed. It copies the coordinate system and the counted frustums. A WebGPU source with plane constants `1` through `6` lands those values, and a later edit of the source leaves the copy at constant `1`. A second frustum with constant `10` grows the destination to length `2`. Copying a count of `0` sets the count to `0` and leaves both stored frustums in place.

`FrustumArray.clone` has landed. It returns a new array with the same coordinate system and counted frustums. A WebGPU source with plane constants `1` through `6` produces a clone whose first constant stays `1` after the source is edited, and whose last constant stays `6` after the clone is edited. An empty array clones to a count of `0` in WebGL coordinates. `setFromArrayCamera`, `intersectsObject`, and `intersectsSprite` still stay out of `math`.

`Interpolant` has landed. `new` stores the parameter positions and sample values by reference. Positions `(0, 1, 2)` and six sample numbers with `sampleSize` `2` keep a cached index of `0` and a zero result buffer of length `2`. A supplied result buffer `(1, 2, 3)` is stored as given. Editing the position array changes the stored `0` to `9`.

`Interpolant.copySampleValue_` has landed. It writes one sample into the result buffer and returns that buffer. With `sampleSize` `2`, index `0` writes `(10, 20)` and leaves a longer buffer's third value `3` in place. Index `2` writes `(50, 60)`. The sample values stay `(10, ..., 60)`.

`Interpolant.interpolate_` has landed. The base method aborts. Calling it with interval index `1`, previous time `0`, time `0.5`, and next time `1` does not write a sample.

`Interpolant.intervalChanged_` has landed. The base method does nothing. Interval index `1` between times `0` and `1` leaves the cached index at `0`, the result buffer at `(1, 2, 3)`, and the sample values at `(10, ..., 60)`.

`Interpolant.evaluate` has landed. Time `-1` on positions `(0, 1, 2, 3, 4)` and samples `(10, 20, 30, 40, 50)` copies `10` and keeps the cached index at `0`. Time `10` and the last position `4` copy `50` and set the cached index to `5`. Time `1.5` reaches the base `interpolate_` and aborts. `getSettings_` stays later.

`Interpolant.getSettings_` has landed. A new interpolant with positions `(0, 1)` and samples `(10, 20)` returns its default settings object. Assigning another settings object makes the method return that object. Clearing the assignment returns the default object again.

`BezierInterpolant` has landed. `new` stores positions `(0, 1)`, samples `(10, 20)`, and a sample size of `1`. The cached index is `0`, the result buffer is `(0)`, and both tangent arrays are absent. A supplied result buffer `(4, 5)` is stored as given.

`cubicBezier` has landed. Parameter `0` on controls `(10, 20, 30, 40)` is `10`. Parameter `1` is `40`. Parameter `0.5` is `25`.

`cubicBezierSlope` has landed. Controls `(0, 0, 0, 1)` have slope `0` at parameter `0`, `0.75` at `0.5`, and `3` at `1`. Controls `(10, 20, 30, 40)` have slope `30` at `0.5`.

`solveBezierParameter` has landed. On controls `(0, 10, 20, 30)`, the parameter for `0` is `0`, for `30` is `1`, and for `15` is `0.5`. On controls `(0, 0, 0, 1)`, the parameter for `0.5` is about `0.793700526`.

`BezierInterpolant.interpolate_` has landed. Without both tangents, time `0.25` between `0` and `1` blends samples `10` and `40` to `17.5`. With out-tangent `(10, 20)` and in-tangent `(20, 30)`, time `15` between `0` and `30` is `25`. The samples stay `10` and `40`.

`CubicInterpolant` has landed. `new` stores positions `(0, 1, 2)` and samples `(10, 20, 30)`. The weights start at `-0`, the offsets start at `0`, and both endings are zero curvature. Those endings are `2400`. Zero slope is `2401` and wrap-around is `2402`.

`CubicInterpolant.intervalChanged_` has landed. For sample size `2` and positions `(0, 1, 2, 3)`, the interval from `1` to `2` stores weights `0.5` and `0.5`, with offsets `0` and `6`. A zero-curvature start gives previous weight `-0.5`. Zero slope and wrap-around both give `0.5`, with offsets `2` and `4`. A zero-curvature end gives next weight `-0.5`. Zero slope and wrap-around give `0.5`, with offsets `6` and `2`.

`CubicInterpolant.interpolate_` has landed. After that same interval is recorded for samples `(10, 20, 30, 40)`, time `1` is `20`, time `1.5` is `25`, and time `2` is `30`. The samples stay unchanged.

`DiscreteInterpolant` has landed. `new` stores positions `(0, 1)` and samples `(10, 20)` with a sample size of `1`. The cached index is `0` and the result buffer is `(0)`. A supplied result buffer `(4, 5)` is stored as given.

`DiscreteInterpolant.interpolate_` has landed. With sample size `2`, interval index `2` at time `1.5` copies `(20, 21)` and leaves a longer buffer's third value `3` in place. Interval index `1` copies `(10, 11)`. The samples stay unchanged.

`LinearInterpolant` has landed. `new` stores positions `(0, 1)` and samples `(10, 20)` with a sample size of `1`. The cached index is `0` and the result buffer is `(0)`. A supplied result buffer `(4, 5)` is stored as given.

`LinearInterpolant.interpolate_` has landed. With sample size `2`, time `0` copies `(10, 11)`, time `0.25` blends to `(12.5, 13.5)`, and time `1` copies `(20, 21)`. A longer buffer's third value stays `3`. The samples stay unchanged.

`QuaternionLinearInterpolant` has landed. `new` stores positions `(0, 1)` and two quaternions `(0, 0, 0, 1)` and `(0, 0, 1, 0)`. The sample size is `4`, the cached index is `0`, and the result buffer is four zeros. A supplied result buffer `(4, 5, 6, 8)` is stored as given.

`QuaternionLinearInterpolant.interpolate_` has landed. From `(0, 0, 0, 1)` to `(0, 0, 1, 0)`, time `0` is the first quaternion, time `1` is the second, and time `0.5` is about `(0, 0, 0.707106781, 0.707106781)`. A longer buffer's fifth value stays `4`.

`Color.setColorName` has landed. It reads the 148 X11 names, ignoring case. `red` is `(1, 0, 0)` and hex `0xFF0000`. `AliceBlue` is hex `0xF0F8FF`. An unknown name leaves `(0.25, 0.5, 0.75)` unchanged. `setStyle` stays later.

`Color.setStyle` has landed. `rgb(255, 0, 0)`, `rgb(100%, 0%, 0%)`, `#ff0000`, `#f00`, and `red` are `(1, 0, 0)`. `hsl(0, 0%, 50%)` is linear `srgb_to_linear(0.5)` on each channel. `AliceBlue` is hex `0xF0F8FF`. An empty string, `#ff`, and an unknown name leave `(0.25, 0.5, 0.75)` unchanged. Alpha is ignored.

## Checklist

| status | phase | item | packages |
|---|---|---|---|
| planned | 2 | Vector2/3/4, Matrix3/4, Quaternion, Euler, Color, Box3, Sphere, Frustum from `src/math` | `math` |
| planned | 7 | `Vector3.transformDirection` | `math` |
| planned | 7 | `Vector3.angleTo` | `math` |
| planned | 7 | `Vector3.distanceTo` | `math` |
| planned | 7 | `Vector3.manhattanDistanceTo` | `math` |
| planned | 7 | `Vector3.setFromSphericalCoords` | `math` |
| planned | 7 | `Vector3.setFromCylindricalCoords` | `math` |
| planned | 7 | `Vector3.setFromMatrixScale` | `math` |
| planned | 7 | `Vector3.setFromMatrix3Column` | `math` |
| planned | 7 | `Vector3.setFromEuler` | `math` |
| planned | 7 | `Vector3.setFromColor` | `math` |
| planned | 7 | `Vector3.fromArray` | `math` |
| planned | 7 | `Vector3.toArray` | `math` |
| planned | 7 | `Vector3.setScalar` | `math` |
| planned | 7 | `Vector3.setX`, `setY`, and `setZ` | `math` |
| planned | 7 | `Vector3.setComponent` and `getComponent` | `math` |
| planned | 7 | `Vector3.addScalar` | `math` |
| planned | 7 | `Vector3.addScaledVector` | `math` |
| planned | 7 | `Vector3.subScalar` | `math` |
| planned | 7 | `Vector3.multiply` | `math` |
| planned | 7 | `Vector3.multiplyVectors` | `math` |
| planned | 7 | `Vector3.applyEuler` | `math` |
| planned | 7 | `Vector3.applyAxisAngle` | `math` |
| planned | 7 | `Vector3.applyMatrix3` | `math` |
| planned | 7 | `Vector3.applyNormalMatrix` | `math` |
| planned | 7 | `Vector3.divide` | `math` |
| planned | 7 | `Vector3.divideScalar` | `math` |
| planned | 7 | `Vector3.clamp` | `math` |
| planned | 7 | `Vector3.clampScalar` | `math` |
| planned | 7 | `Vector3.clampLength` | `math` |
| planned | 7 | `Vector3.floor` | `math` |
| planned | 7 | `Vector3.ceil` | `math` |
| planned | 7 | `Vector3.round` | `math` |
| planned | 7 | `Vector3.roundToZero` | `math` |
| planned | 7 | `Vector3.manhattanLength` | `math` |
| planned | 7 | `Vector3.setLength` | `math` |
| planned | 7 | `Vector3.lerpVectors` | `math` |
| planned | 7 | `Vector3.projectOnVector` | `math` |
| planned | 7 | `Vector3.projectOnPlane` | `math` |
| planned | 7 | `Vector3.reflect` | `math` |
| planned | 7 | `Vector3.setFromSpherical` | `math` |
| planned | 7 | `Spherical.set` | `math` |
| planned | 7 | `Spherical.copy` | `math` |
| planned | 7 | `Spherical.makeSafe` | `math` |
| planned | 7 | `Spherical.setFromCartesianCoords` | `math` |
| planned | 7 | `Spherical.setFromVector3` | `math` |
| planned | 7 | `Spherical.clone` | `math` |
| planned | 7 | `Vector3.setFromCylindrical` | `math` |
| planned | 7 | `Cylindrical.set` | `math` |
| planned | 7 | `Cylindrical.copy` | `math` |
| planned | 7 | `Cylindrical.setFromCartesianCoords` | `math` |
| planned | 7 | `Cylindrical.setFromVector3` | `math` |
| planned | 7 | `Cylindrical.clone` | `math` |
| planned | 7 | `Vector2.setScalar` | `math` |
| planned | 7 | `Vector2.setX` | `math` |
| planned | 7 | `Vector2.setY` | `math` |
| planned | 7 | `Vector2.setComponent` | `math` |
| planned | 7 | `Vector2.getComponent` | `math` |
| planned | 7 | `Vector2.addScalar` | `math` |
| planned | 7 | `Vector2.addVectors` | `math` |
| planned | 7 | `Vector2.addScaledVector` | `math` |
| planned | 7 | `Vector2.subScalar` | `math` |
| planned | 7 | `Vector2.subVectors` | `math` |
| planned | 7 | `Vector2.multiply` | `math` |
| planned | 7 | `Vector2.divide` | `math` |
| planned | 7 | `Vector2.divideScalar` | `math` |
| planned | 7 | `Vector2.applyMatrix3` | `math` |
| planned | 7 | `Vector2.min` | `math` |
| planned | 7 | `Vector2.max` | `math` |
| planned | 7 | `Vector2.clamp` | `math` |
| planned | 7 | `Vector2.clampScalar` | `math` |
| planned | 7 | `Vector2.clampLength` | `math` |
| planned | 7 | `Vector2.floor` | `math` |
| planned | 7 | `Vector2.ceil` | `math` |
| planned | 7 | `Vector2.round` | `math` |
| planned | 7 | `Vector2.roundToZero` | `math` |
| planned | 7 | `Vector2.negate` | `math` |
| planned | 7 | `Vector2.cross` | `math` |
| planned | 7 | `Vector2.manhattanLength` | `math` |
| planned | 7 | `Vector2.angle` | `math` |
| planned | 7 | `Vector2.angleTo` | `math` |
| planned | 7 | `Vector2.distanceToSquared` | `math` |
| planned | 7 | `Vector2.distanceTo` | `math` |
| planned | 7 | `Vector2.manhattanDistanceTo` | `math` |
| planned | 7 | `Vector2.setLength` | `math` |
| planned | 7 | `Vector2.lerpVectors` | `math` |
| planned | 7 | `Vector2.fromArray` | `math` |
| planned | 7 | `Vector2.toArray` | `math` |
| planned | 7 | `Vector2.rotateAround` | `math` |
| planned | 7 | `Vector4.setScalar` | `math` |
| planned | 7 | `Vector4.setX` | `math` |
| planned | 7 | `Vector4.setY` | `math` |
| planned | 7 | `Vector4.setZ` | `math` |
| planned | 7 | `Vector4.setW` | `math` |
| planned | 7 | `Vector4.setComponent` | `math` |
| planned | 7 | `Vector4.getComponent` | `math` |
| planned | 7 | `Vector4.add` | `math` |
| planned | 7 | `Vector4.addScalar` | `math` |
| planned | 7 | `Vector4.addVectors` | `math` |
| planned | 7 | `Vector4.addScaledVector` | `math` |
| planned | 7 | `Vector4.sub` | `math` |
| planned | 7 | `Vector4.subScalar` | `math` |
| planned | 7 | `Vector4.subVectors` | `math` |
| planned | 7 | `Vector4.multiply` | `math` |
| planned | 7 | `Vector4.multiplyScalar` | `math` |
| planned | 7 | `Vector4.divide` | `math` |
| planned | 7 | `Vector4.divideScalar` | `math` |
| planned | 7 | `Vector4.setAxisAngleFromQuaternion` | `math` |
| planned | 7 | `Vector4.setAxisAngleFromRotationMatrix` | `math` |
| planned | 7 | `Vector4.setFromMatrixPosition` | `math` |
| planned | 7 | `Vector4.min` | `math` |
| planned | 7 | `Vector4.max` | `math` |
| planned | 7 | `Vector4.clamp` | `math` |
| planned | 7 | `Vector4.clampScalar` | `math` |
| planned | 7 | `Vector4.clampLength` | `math` |
| planned | 7 | `Vector4.floor` | `math` |
| planned | 7 | `Vector4.ceil` | `math` |
| planned | 7 | `Vector4.round` | `math` |
| planned | 7 | `Vector4.roundToZero` | `math` |
| planned | 7 | `Vector4.negate` | `math` |
| planned | 7 | `Vector4.manhattanLength` | `math` |
| planned | 7 | `Vector4.setLength` | `math` |
| planned | 7 | `Vector4.lerp` | `math` |
| planned | 7 | `Vector4.lerpVectors` | `math` |
| planned | 7 | `Vector4.equals` | `math` |
| planned | 7 | `Vector4.fromArray` | `math` |
| planned | 7 | `Vector4.toArray` | `math` |
| planned | 7 | `Box2` | `math` |
| planned | 7 | `Box2.set` | `math` |
| planned | 7 | `Box2.makeEmpty` | `math` |
| planned | 7 | `Box2.expandByPoint` | `math` |
| planned | 7 | `Box2.setFromPoints` | `math` |
| planned | 7 | `Box2.setFromCenterAndSize` | `math` |
| planned | 7 | `Box2.copy` | `math` |
| planned | 7 | `Box2.clone` | `math` |
| planned | 7 | `Box2.isEmpty` | `math` |
| planned | 7 | `Box2.getCenter` | `math` |
| planned | 7 | `Box2.getSize` | `math` |
| planned | 7 | `Box2.expandByVector` | `math` |
| planned | 7 | `Box2.expandByScalar` | `math` |
| planned | 7 | `Box2.containsPoint` | `math` |
| planned | 7 | `Box2.containsBox` | `math` |
| planned | 7 | `Box2.getParameter` | `math` |
| planned | 7 | `Box2.intersectsBox` | `math` |
| planned | 7 | `Box2.clampPoint` | `math` |
| planned | 7 | `Box2.distanceToPoint` | `math` |
| planned | 7 | `Box2.intersect` | `math` |
| planned | 7 | `Box2.union` | `math` |
| planned | 7 | `Box2.translate` | `math` |
| planned | 7 | `Box2.equals` | `math` |
| planned | 7 | `Box3.setFromArray` | `math` |
| planned | 7 | `Box3.setFromCenterAndSize` | `math` |
| planned | 7 | `Box3.copy` | `math` |
| planned | 7 | `Box3.clone` | `math` |
| planned | 7 | `Box3.expandByVector` | `math` |
| planned | 7 | `Box3.expandByScalar` | `math` |
| planned | 7 | `Box3.containsPoint` | `math` |
| planned | 7 | `Box3.containsBox` | `math` |
| planned | 7 | `Box3.getParameter` | `math` |
| planned | 7 | `Box3.intersectsBox` | `math` |
| planned | 7 | `Box3.clampPoint` | `math` |
| planned | 7 | `Box3.intersectsSphere` | `math` |
| planned | 7 | `Box3.intersectsPlane` | `math` |
| planned | 7 | `Box3.distanceToPoint` | `math` |
| planned | 7 | `Box3.getBoundingSphere` | `math` |
| planned | 7 | `Box3.intersect` | `math` |
| planned | 7 | `Box3.translate` | `math` |
| planned | 7 | `Box3.equals` | `math` |
| planned | 7 | `Box3.toJSON` | `math` |
| planned | 7 | `Box3.fromJSON` | `math` |
| planned | 7 | `Triangle` | `math` |
| planned | 7 | `Triangle.getNormal` | `math` |
| planned | 7 | `Triangle.getBarycoord` | `math` |
| planned | 7 | `Triangle.containsPoint` | `math` |
| planned | 7 | `Triangle.getInterpolation` | `math` |
| planned | 7 | `Triangle.isFrontFacing` | `math` |
| planned | 7 | `Triangle.set` | `math` |
| planned | 7 | `Triangle.setFromPointsAndIndices` | `math` |
| planned | 7 | `Triangle.copy` | `math` |
| planned | 7 | `Triangle.clone` | `math` |
| planned | 7 | `Triangle.getArea` | `math` |
| planned | 7 | `Triangle.getMidpoint` | `math` |
| planned | 7 | `Triangle.normal`, the instance `getNormal` | `math` |
| planned | 7 | `Plane.setFromNormalAndCoplanarPoint` | `math` |
| planned | 7 | `Plane.setFromCoplanarPoints` | `math` |
| planned | 7 | `Triangle.getPlane` | `math` |
| planned | 7 | `Triangle.barycoord`, the instance `getBarycoord` | `math` |
| planned | 7 | `Triangle.interpolation`, the instance `getInterpolation` | `math` |
| planned | 7 | `Triangle.contains`, the instance `containsPoint` | `math` |
| planned | 7 | `Triangle.front_facing`, the instance `isFrontFacing` | `math` |
| planned | 7 | `Box3.intersectsTriangle` | `math` |
| planned | 7 | `Triangle.intersectsBox` | `math` |
| planned | 7 | `Triangle.closestPointToPoint` | `math` |
| planned | 7 | `Triangle.equals` | `math` |
| planned | 7 | `Plane.set` | `math` |
| planned | 7 | `Plane.negate` | `math` |
| planned | 7 | `Plane.distanceToSphere` | `math` |
| planned | 7 | `Plane.projectPoint` | `math` |
| planned | 7 | `Line3` | `math` |
| planned | 7 | `Line3.set` | `math` |
| planned | 7 | `Line3.copy` | `math` |
| planned | 7 | `Line3.getCenter` | `math` |
| planned | 7 | `Line3.delta` | `math` |
| planned | 7 | `Line3.distanceSq` | `math` |
| planned | 7 | `Line3.distance` | `math` |
| planned | 7 | `Line3.at` | `math` |
| planned | 7 | `Line3.closestPointToPointParameter` | `math` |
| planned | 7 | `Line3.closestPointToPoint` | `math` |
| planned | 7 | `Line3.distanceSqToLine3` | `math` |
| planned | 7 | `Line3.applyMatrix4` | `math` |
| planned | 7 | `Line3.equals` | `math` |
| planned | 7 | `Line3.clone` | `math` |
| planned | 7 | `Plane.intersectLine` | `math` |
| planned | 7 | `Plane.intersectsLine` | `math` |
| planned | 7 | `Plane.intersectsBox` | `math` |
| planned | 7 | `Sphere.intersectsPlane` | `math` |
| planned | 7 | `Plane.intersectsSphere` | `math` |
| planned | 7 | `Plane.coplanarPoint` | `math` |
| planned | 7 | `Plane.applyMatrix4` | `math` |
| planned | 7 | `Plane.translate` | `math` |
| planned | 7 | `Plane.equals` | `math` |
| planned | 7 | `Plane.clone` | `math` |
| planned | 7 | `Plane.toJSON` | `math` |
| planned | 7 | `Plane.fromJSON` | `math` |
| planned | 7 | `Sphere.set` | `math` |
| planned | 7 | `Sphere.distanceToPoint` | `math` |
| planned | 7 | `Sphere.intersectsBox` | `math` |
| planned | 7 | `Sphere.clampPoint` | `math` |
| planned | 7 | `Sphere.getBoundingBox` | `math` |
| planned | 7 | `Sphere.translate` | `math` |
| planned | 7 | `Sphere.expandByPoint` | `math` |
| planned | 7 | `Sphere.union` | `math` |
| planned | 7 | `Sphere.equals` | `math` |
| planned | 7 | `Sphere.clone` | `math` |
| planned | 7 | `Sphere.toJSON` | `math` |
| planned | 7 | `Sphere.fromJSON` | `math` |
| planned | 7 | `Ray` | `math` |
| planned | 7 | `Ray.set` | `math` |
| planned | 7 | `Ray.copy` | `math` |
| planned | 7 | `Ray.at` | `math` |
| planned | 7 | `Ray.lookAt` | `math` |
| planned | 7 | `Ray.recast` | `math` |
| planned | 7 | `Ray.closestPointToPoint` | `math` |
| planned | 7 | `Ray.distanceSqToPoint` | `math` |
| planned | 7 | `Ray.distanceToPoint` | `math` |
| planned | 7 | `Ray.distanceSqToSegment` | `math` |
| planned | 7 | `Ray.intersectSphere` | `math` |
| planned | 7 | `Ray.intersectsSphere` | `math` |
| planned | 7 | `Ray.distanceToPlane` | `math` |
| planned | 7 | `Ray.intersectPlane` | `math` |
| planned | 7 | `Ray.intersectsPlane` | `math` |
| planned | 7 | `Ray.intersectBox` | `math` |
| planned | 7 | `Ray.intersectsBox` | `math` |
| planned | 7 | `Ray.intersectTriangle` | `math` |
| planned | 7 | `Ray.applyMatrix4` | `math` |
| planned | 7 | `Ray.equals` | `math` |
| planned | 7 | `Ray.clone` | `math` |
| planned | 7 | `Color.set` | `math` |
| planned | 7 | `Color.setScalar` | `math` |
| planned | 7 | `MathUtils.clamp` | `math` |
| planned | 7 | `MathUtils.euclideanModulo` | `math` |
| planned | 7 | `Color.setHSL` | `math` |
| planned | 7 | `Color.copySRGBToLinear` | `math` |
| planned | 7 | `Color.copyLinearToSRGB` | `math` |
| planned | 7 | `Color.convertSRGBToLinear` | `math` |
| planned | 7 | `Color.convertLinearToSRGB` | `math` |
| planned | 7 | `Color.getHexString` | `math` |
| planned | 7 | `Color.getHSL` | `math` |
| planned | 7 | `Color.getRGB` | `math` |
| planned | 7 | `Color.getStyle` | `math` |
| planned | 7 | `Color.offsetHSL` | `math` |
| planned | 7 | `Color.add` | `math` |
| planned | 7 | `Color.addColors` | `math` |
| planned | 7 | `Color.addScalar` | `math` |
| planned | 7 | `Color.sub` | `math` |
| planned | 7 | `Color.multiply` | `math` |
| planned | 7 | `Color.multiplyScalar` | `math` |
| planned | 7 | `Color.lerpColors` | `math` |
| planned | 7 | `MathUtils.lerp` | `math` |
| planned | 7 | `Color.lerpHSL` | `math` |
| planned | 7 | `Color.setFromVector3` | `math` |
| planned | 7 | `Color.applyMatrix3` | `math` |
| planned | 7 | `Color.equals` | `math` |
| planned | 7 | `Color.fromArray` | `math` |
| planned | 7 | `Color.toArray` | `math` |
| planned | 7 | `Color.toJSON` | `math` |
| planned | 7 | `Euler.clone` | `math` |
| planned | 7 | `Euler.setFromVector3` | `math` |
| planned | 7 | `Euler.equals` | `math` |
| planned | 7 | `Euler.fromArray` | `math` |
| planned | 7 | `Euler.toArray` | `math` |
| planned | 7 | `Frustum.set` | `math` |
| planned | 7 | `Frustum.copy` | `math` |
| planned | 7 | `Frustum.intersectsBox` | `math` |
| planned | 7 | `Frustum.containsPoint` | `math` |
| planned | 7 | `Frustum.clone` | `math` |
| planned | 7 | `Matrix3.extractBasis` | `math` |
| planned | 7 | `Matrix3.multiplyMatrices` | `math` |
| planned | 7 | `Matrix3.multiply` | `math` |
| planned | 7 | `Matrix3.premultiply` | `math` |
| planned | 7 | `Matrix3.multiplyScalar` | `math` |
| planned | 7 | `Matrix3.transposeIntoArray` | `math` |
| planned | 7 | `Matrix3.setUvTransform` | `math` |
| planned | 7 | `Matrix3.makeScale` | `math` |
| planned | 7 | `Matrix3.scale` | `math` |
| planned | 7 | `Matrix3.makeRotation` | `math` |
| planned | 7 | `Matrix3.rotate` | `math` |
| planned | 7 | `Matrix3.makeTranslation` | `math` |
| planned | 7 | `Matrix3.translate` | `math` |
| planned | 7 | `Matrix3.equals` | `math` |
| planned | 7 | `Matrix3.fromArray` | `math` |
| planned | 7 | `Matrix3.toArray` | `math` |
| planned | 7 | `Matrix4.copyPosition` | `math` |
| planned | 7 | `Matrix4.setFromMatrix3` | `math` |
| planned | 7 | `Matrix4.extractBasis` | `math` |
| planned | 7 | `Matrix4.makeBasis` | `math` |
| planned | 7 | `Matrix4.multiplyScalar` | `math` |
| planned | 7 | `Matrix4.makeRotationX` | `math` |
| planned | 7 | `Matrix4.makeRotationY` | `math` |
| planned | 7 | `Matrix4.makeRotationZ` | `math` |
| planned | 7 | `Matrix4.makeRotationAxis` | `math` |
| planned | 7 | `Matrix4.makeScale` | `math` |
| planned | 7 | `Matrix4.makeShear` | `math` |
| planned | 7 | `Matrix4.fromArray` | `math` |
| planned | 7 | `Matrix4.toArray` | `math` |
| planned | 7 | `Quaternion.slerpFlat` | `math` |
| planned | 7 | `Quaternion.multiplyQuaternionsFlat` | `math` |
| planned | 7 | `Quaternion` `x` setter | `math` |
| planned | 7 | `Quaternion` `y` setter | `math` |
| planned | 7 | `Quaternion` `z` setter | `math` |
| planned | 7 | `Quaternion` `w` setter | `math` |
| planned | 7 | `Quaternion.setFromUnitVectors` | `math` |
| planned | 7 | `Quaternion.angleTo` | `math` |
| planned | 7 | `Quaternion.rotateTowards` | `math` |
| planned | 7 | `Quaternion.lengthSq` | `math` |
| planned | 7 | `Quaternion.slerpQuaternions` | `math` |
| planned | 7 | `Quaternion.random` | `math` |
| planned | 7 | `Quaternion.equals` | `math` |
| planned | 7 | `Quaternion.fromArray` | `math` |
| planned | 7 | `Quaternion.toArray` | `math` |
| planned | 7 | `Quaternion.toJSON` | `math` |
| planned | 7 | `MathUtils.mapLinear` | `math` |
| planned | 7 | `MathUtils.inverseLerp` | `math` |
| planned | 7 | `MathUtils.damp` | `math` |
| planned | 7 | `MathUtils.pingpong` | `math` |
| planned | 7 | `MathUtils.smoothstep` | `math` |
| planned | 7 | `MathUtils.smootherstep` | `math` |
| planned | 7 | `MathUtils.randInt` | `math` |
| planned | 7 | `MathUtils.randFloat` | `math` |
| planned | 7 | `MathUtils.randFloatSpread` | `math` |
| planned | 7 | `MathUtils.seededRandom` | `math` |
| planned | 7 | `MathUtils.isPowerOfTwo` | `math` |
| planned | 7 | `MathUtils.ceilPowerOfTwo` | `math` |
| planned | 7 | `MathUtils.floorPowerOfTwo` | `math` |
| planned | 7 | `MathUtils.setQuaternionFromProperEuler` | `math` |
| planned | 7 | `MathUtils.denormalize` | `math` |
| planned | 7 | `MathUtils.normalize` | `math` |
| planned | 7 | `MathUtils.generateUUID` | `math` |
| planned | 7 | `Matrix2` | `math` |
| planned | 7 | `Matrix2.set` | `math` |
| planned | 7 | `Matrix2.identity` | `math` |
| planned | 7 | `Matrix2.fromArray` | `math` |
| planned | 7 | `SphericalHarmonics3` | `math` |
| planned | 7 | `SphericalHarmonics3.set` | `math` |
| planned | 7 | `SphericalHarmonics3.zero` | `math` |
| planned | 7 | `SphericalHarmonics3.getAt` | `math` |
| planned | 7 | `SphericalHarmonics3.getIrradianceAt` | `math` |
| planned | 7 | `SphericalHarmonics3.add` | `math` |
| planned | 7 | `SphericalHarmonics3.addScaledSH` | `math` |
| planned | 7 | `SphericalHarmonics3.scale` | `math` |
| planned | 7 | `SphericalHarmonics3.lerp` | `math` |
| planned | 7 | `SphericalHarmonics3.equals` | `math` |
| planned | 7 | `SphericalHarmonics3.copy` | `math` |
| planned | 7 | `SphericalHarmonics3.clone` | `math` |
| planned | 7 | `SphericalHarmonics3.fromArray` | `math` |
| planned | 7 | `SphericalHarmonics3.toArray` | `math` |
| planned | 7 | `SphericalHarmonics3.getBasisAt` | `math` |
| planned | 7 | `FrustumArray` | `math` |
| planned | 7 | `FrustumArray.intersectsSphere` | `math` |
| planned | 7 | `FrustumArray.intersectsBox` | `math` |
| planned | 7 | `FrustumArray.containsPoint` | `math` |
| planned | 7 | `FrustumArray.copy` | `math` |
| planned | 7 | `FrustumArray.clone` | `math` |
| planned | 7 | `Interpolant` | `math` |
| planned | 7 | `Interpolant.copySampleValue_` | `math` |
| planned | 7 | `Interpolant.interpolate_` | `math` |
| planned | 7 | `Interpolant.intervalChanged_` | `math` |
| planned | 7 | `Interpolant.evaluate` | `math` |
| planned | 7 | `Interpolant.getSettings_` | `math` |
| planned | 7 | `BezierInterpolant` | `math` |
| planned | 7 | `cubicBezier` | `math` |
| planned | 7 | `cubicBezierSlope` | `math` |
| planned | 7 | `solveBezierParameter` | `math` |
| planned | 7 | `BezierInterpolant.interpolate_` | `math` |
| planned | 7 | `CubicInterpolant` | `math` |
| planned | 7 | `CubicInterpolant.intervalChanged_` | `math` |
| planned | 7 | `CubicInterpolant.interpolate_` | `math` |
| planned | 7 | `DiscreteInterpolant` | `math` |
| planned | 7 | `DiscreteInterpolant.interpolate_` | `math` |
| planned | 7 | `LinearInterpolant` | `math` |
| planned | 7 | `LinearInterpolant.interpolate_` | `math` |
| planned | 7 | `QuaternionLinearInterpolant` | `math` |
| planned | 7 | `QuaternionLinearInterpolant.interpolate_` | `math` |
| planned | 7 | `Color.setColorName` | `math` |
| planned | 7 | `Color.setStyle` | `math` |
