///|
/// 计算着色器一个工作组的线程数。与 `wave_wgsl` 里的 `@workgroup_size` 相同。
pub const WORKGROUP_SIZE : Int = 64

///|
const PI : Double = 3.141592653589793

///|
const AMPLITUDE : Double = 0.5

///|
/// 沿 X 铺开的点。`y = sin(x π + time) * 0.5`，`z` 为 0。
/// `count` 至少为 1。几何体上的 `position` 是同一公式的 CPU 副本。
pub(all) struct StoragePositions {
  geometry : @core.BufferGeometry
  count : Int
  mut time : Double
}

///|
pub fn StoragePositions::new(count : Int) -> StoragePositions {
  let safe = if count < 1 { 1 } else { count }
  let geometry = @core.BufferGeometry::new()
  let values = []
  let mut index = 0
  while index < safe {
    let position = wave_position(index, safe, 0.0)
    values.push(position.x)
    values.push(position.y)
    values.push(position.z)
    index = index + 1
  }
  ignore(
    geometry.set_attribute("position", @core.BufferAttribute::new(values, 3)),
  )
  { geometry, count: safe, time: 0.0, }
}

///|
/// 推进时间，并按同一公式重写 CPU 上的位置。GPU 缓冲要等渲染器 `compute`。
pub fn StoragePositions::set_time(
  self : StoragePositions,
  time : Double,
) -> Unit {
  self.time = time
  match self.geometry.get_attribute("position") {
    None => ()
    Some(position) => {
      let mut index = 0
      while index < self.count {
        let sample = wave_position(index, self.count, time)
        position.set_xyz(index, sample.x, sample.y, sample.z)
        index = index + 1
      }
    }
  }
}

///|
/// `ceil(count / 64)`。`count <= 0` 时不派发。
pub fn workgroup_count(count : Int) -> Int {
  if count <= 0 {
    0
  } else {
    (count + WORKGROUP_SIZE - 1) / WORKGROUP_SIZE
  }
}

///|
pub fn wave_position(index : Int, count : Int, time : Double) -> @math.Vector3 {
  let span = if count <= 1 { 1.0 } else { (count - 1).to_double() }
  let x = index.to_double() / span * 2.0 - 1.0
  let y = @std.sin(x * PI + time) * AMPLITUDE
  @math.Vector3::new(x~, y~, z=0.0)
}

///|
fn write_f32(dst : FixedArray[Byte], offset : Int, value : Double) -> Unit {
  let bytes = Float::from_double(value).to_le_bytes()
  let mut index = 0
  while index < 4 {
    dst[offset + index] = bytes.at(index)
    index = index + 1
  }
}

///|
/// 16 字节的 uniform：`(time, count, 0, 0)`，都是 `f32`。
pub fn pack_wave_params(time : Double, count : Int) -> FixedArray[Byte] {
  let dst = FixedArray::make(16, b'\x00')
  write_f32(dst, 0, time)
  write_f32(dst, 4, count.to_double())
  dst
}

///|
/// 写入 `array<f32>`，每个点三个紧排的 `xyz`。绑定组 0：存储缓冲和上面的 uniform。
pub fn wave_wgsl() -> String {
  let code =
    #|struct WaveParams {
    #|  time : f32,
    #|  count : f32,
    #|  pad0 : f32,
    #|  pad1 : f32,
    #|}
    #|
    #|@group(0) @binding(0) var<storage, read_write> positions : array<f32>;
    #|@group(0) @binding(1) var<uniform> params : WaveParams;
    #|
    #|@compute @workgroup_size(64)
    #|fn main(@builtin(global_invocation_id) id : vec3<u32>) {
    #|  let index = id.x;
    #|  if (f32(index) >= params.count) {
    #|    return;
    #|  }
    #|  let span = max(params.count - 1.0, 1.0);
    #|  let x = f32(index) / span * 2.0 - 1.0;
    #|  let y = sin(x * 3.141592653589793 + params.time) * 0.5;
    #|  let base = index * 3u;
    #|  positions[base] = x;
    #|  positions[base + 1u] = y;
    #|  positions[base + 2u] = 0.0;
    #|}
  code
}
