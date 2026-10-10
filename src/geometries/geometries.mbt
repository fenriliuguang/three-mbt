// r186: `BoxGeometry` https://github.com/mrdoob/three.js/blob/r186/src/geometries/BoxGeometry.js#L20

///|
using @core {type BufferGeometry, type BufferAttribute}

///|
/// 盒子构造参数。生成之后再改这些数不会重建顶点。
/// r186: `BoxGeometry` https://github.com/mrdoob/three.js/blob/r186/src/geometries/BoxGeometry.js#L20
pub(all) struct BoxParameters {
  width : Double
  height : Double
  depth : Double
  width_segments : Int
  height_segments : Int
  depth_segments : Int
}

///|
/// 以原点为中心、棱平行于坐标轴的盒子。顶点布局对齐 r186 `BoxGeometry`。
/// r186: `BoxGeometry` https://github.com/mrdoob/three.js/blob/r186/src/geometries/BoxGeometry.js#L20
pub(all) struct BoxGeometry {
  geometry : BufferGeometry
  parameters : BoxParameters
}

///|
fn set_axis(vector : @math.Vector3, axis : Int, value : Double) -> Unit {
  match axis {
    0 => vector.x = value
    1 => vector.y = value
    _ => vector.z = value
  }
}

///|
fn build_plane(
  vertices : Array[Double],
  normals : Array[Double],
  uvs : Array[Double],
  indices : Array[Int],
  geometry : BufferGeometry,
  u : Int,
  v : Int,
  w : Int,
  udir : Double,
  vdir : Double,
  width : Double,
  height : Double,
  depth : Double,
  grid_x : Int,
  grid_y : Int,
  material_index : Int,
  number_of_vertices : Int,
) -> Int {
  let segment_width = width / grid_x.to_double()
  let segment_height = height / grid_y.to_double()
  let width_half = width / 2.0
  let height_half = height / 2.0
  let depth_half = depth / 2.0
  let grid_x1 = grid_x + 1
  let grid_y1 = grid_y + 1
  let mut vertex_counter = 0
  let vector = @math.Vector3::new()
  let mut iy = 0
  while iy < grid_y1 {
    let y = iy.to_double() * segment_height - height_half
    let mut ix = 0
    while ix < grid_x1 {
      let x = ix.to_double() * segment_width - width_half
      set_axis(vector, u, x * udir)
      set_axis(vector, v, y * vdir)
      set_axis(vector, w, depth_half)
      vertices.push(vector.x)
      vertices.push(vector.y)
      vertices.push(vector.z)
      set_axis(vector, u, 0.0)
      set_axis(vector, v, 0.0)
      if depth > 0.0 {
        set_axis(vector, w, 1.0)
      } else {
        set_axis(vector, w, -1.0)
      }
      normals.push(vector.x)
      normals.push(vector.y)
      normals.push(vector.z)
      uvs.push(ix.to_double() / grid_x.to_double())
      uvs.push(1.0 - iy.to_double() / grid_y.to_double())
      vertex_counter = vertex_counter + 1
      ix = ix + 1
    }
    iy = iy + 1
  }
  let group_start = indices.length()
  let mut group_count = 0
  iy = 0
  while iy < grid_y {
    let mut ix = 0
    while ix < grid_x {
      let a = number_of_vertices + ix + grid_x1 * iy
      let b = number_of_vertices + ix + grid_x1 * (iy + 1)
      let c = number_of_vertices + (ix + 1) + grid_x1 * (iy + 1)
      let d = number_of_vertices + (ix + 1) + grid_x1 * iy
      indices.push(a)
      indices.push(b)
      indices.push(d)
      indices.push(b)
      indices.push(c)
      indices.push(d)
      group_count = group_count + 6
      ix = ix + 1
    }
    iy = iy + 1
  }
  geometry.add_group(group_start, group_count, material_index~)
  number_of_vertices + vertex_counter
}

///|
pub fn BoxGeometry::new(
  width? : Double = 1.0,
  height? : Double = 1.0,
  depth? : Double = 1.0,
  width_segments? : Int = 1,
  height_segments? : Int = 1,
  depth_segments? : Int = 1,
) -> BoxGeometry {
  let geometry = BufferGeometry::new()
  let vertices = []
  let normals = []
  let uvs = []
  let indices = []
  let mut number_of_vertices = 0
  number_of_vertices = build_plane(
    vertices, normals, uvs, indices, geometry, 2, 1, 0, -1.0, -1.0, depth, height,
    width, depth_segments, height_segments, 0, number_of_vertices,
  )
  number_of_vertices = build_plane(
    vertices,
    normals,
    uvs,
    indices,
    geometry,
    2,
    1,
    0,
    1.0,
    -1.0,
    depth,
    height,
    -width,
    depth_segments,
    height_segments,
    1,
    number_of_vertices,
  )
  number_of_vertices = build_plane(
    vertices, normals, uvs, indices, geometry, 0, 2, 1, 1.0, 1.0, width, depth, height,
    width_segments, depth_segments, 2, number_of_vertices,
  )
  number_of_vertices = build_plane(
    vertices,
    normals,
    uvs,
    indices,
    geometry,
    0,
    2,
    1,
    1.0,
    -1.0,
    width,
    depth,
    -height,
    width_segments,
    depth_segments,
    3,
    number_of_vertices,
  )
  number_of_vertices = build_plane(
    vertices, normals, uvs, indices, geometry, 0, 1, 2, 1.0, -1.0, width, height,
    depth, width_segments, height_segments, 4, number_of_vertices,
  )
  let _ = build_plane(
    vertices,
    normals,
    uvs,
    indices,
    geometry,
    0,
    1,
    2,
    -1.0,
    -1.0,
    width,
    height,
    -depth,
    width_segments,
    height_segments,
    5,
    number_of_vertices,
  )
  ignore(geometry.set_index_array(indices))
  ignore(geometry.set_attribute("position", BufferAttribute::new(vertices, 3)))
  ignore(geometry.set_attribute("normal", BufferAttribute::new(normals, 3)))
  ignore(geometry.set_attribute("uv", BufferAttribute::new(uvs, 2)))
  {
    geometry,
    parameters: {
      width,
      height,
      depth,
      width_segments,
      height_segments,
      depth_segments,
    },
  }
}
