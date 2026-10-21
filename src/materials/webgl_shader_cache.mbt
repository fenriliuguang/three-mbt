// r186: `WebGLShaderCache` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLShaderCache.js#L3

///|
let next_shader_stage_id : Ref[Int] = Ref::Ref(0)

///|
/// 一段着色器源码。编号从 `0` 起递增。引用次数从 `0` 起，同一段源码在缓存里只有一条。
/// r186: `WebGLShaderStage` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLShaderCache.js#L105
/// r186: `id` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLShaderCache.js#L109
pub struct ShaderStage {
  id : Int
  code : String
  used_times : Ref[Int]
}

///|
/// 自定义着色器缓存。源码表按字符串保存阶段，材质表按材质编号保存它用过的阶段。
/// r186: `WebGLShaderCache` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLShaderCache.js#L3
pub struct ShaderCache {
  shader_cache : Map[String, ShaderStage]
  material_cache : Map[Int, Array[ShaderStage]]
}

///|
/// 新建空缓存。
/// r186: `WebGLShaderCache` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLShaderCache.js#L5
pub fn ShaderCache::new() -> ShaderCache {
  { shader_cache: Map([]), material_cache: Map([]) }
}

///|
fn ShaderCache::material_stages(
  self : ShaderCache,
  material_id : Int,
) -> Array[ShaderStage] {
  match self.material_cache.get(material_id) {
    Some(stages) => stages
    None => {
      let stages : Array[ShaderStage] = []
      self.material_cache.set(material_id, stages)
      stages
    }
  }
}

///|
fn ShaderCache::stage(self : ShaderCache, code : String) -> ShaderStage {
  match self.shader_cache.get(code) {
    Some(stage) => stage
    None => {
      let stage : ShaderStage = {
        id: next_shader_stage_id.val,
        code,
        used_times: Ref::Ref(0),
      }
      next_shader_stage_id.val = next_shader_stage_id.val + 1
      self.shader_cache.set(code, stage)
      stage
    }
  }
}

///|
/// 按材质的顶点着色器源码取出阶段。没有就新建，引用次数保持 `0`。同一段源码返回同一条。不写入材质表。
/// r186: `getVertexShaderStage` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLShaderCache.js#L52
pub fn ShaderCache::get_vertex_shader_stage(
  self : ShaderCache,
  material : Material,
) -> ShaderStage {
  self.stage(material.vertex_shader)
}

///|
/// 按材质的片元着色器源码取出阶段。没有就新建，引用次数保持 `0`。同一段源码返回同一条。不写入材质表。
/// r186: `getFragmentShaderStage` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLShaderCache.js#L58
pub fn ShaderCache::get_fragment_shader_stage(
  self : ShaderCache,
  material : Material,
) -> ShaderStage {
  self.stage(material.fragment_shader)
}

///|
/// 自定义顶点着色器的编号。内置材质没有这个编号。Shader 和 Raw 用顶点阶段的编号，引用次数不加，也不写入材质表。
/// r186: `customVertexShaderID` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L97
/// r186: `customVertexShaderID` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L116
pub fn ShaderCache::custom_vertex_shader_id(
  self : ShaderCache,
  material : Material,
) -> Int? {
  match builtin_shader_id(material.type_name) {
    Some(_) => None
    None => Some(self.get_vertex_shader_stage(material).id)
  }
}

///|
/// 自定义片元着色器的编号。内置材质没有这个编号。Shader 和 Raw 用片元阶段的编号，引用次数不加，也不写入材质表。
/// r186: `customFragmentShaderID` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L97
/// r186: `customFragmentShaderID` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L117
pub fn ShaderCache::custom_fragment_shader_id(
  self : ShaderCache,
  material : Material,
) -> Int? {
  match builtin_shader_id(material.type_name) {
    Some(_) => None
    None => Some(self.get_fragment_shader_stage(material).id)
  }
}

///|
fn ShaderCache::claim(
  self : ShaderCache,
  stages : Array[ShaderStage],
  code : String,
) -> Unit {
  let stage = self.stage(code)
  let mut index = 0
  while index < stages.length() {
    if stages[index].code == code {
      return
    }
    index = index + 1
  }
  stages.push(stage)
  stage.used_times.val = stage.used_times.val + 1
}

///|
/// 让这个材质记下顶点源码和片元源码。同一材质对同一段源码只记一次，引用次数加一。两边源码相同则只加一次。
/// r186: `update` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLShaderCache.js#L12
pub fn ShaderCache::update(
  self : ShaderCache,
  material_id : Int,
  vertex_code : String,
  fragment_code : String,
) -> Unit {
  let stages = self.material_stages(material_id)
  self.claim(stages, vertex_code)
  self.claim(stages, fragment_code)
}

///|
/// 放开这个材质记下的阶段。每个阶段的引用次数减一，减到 `0` 时从源码表删掉。材质自己的记录也删掉。没有记录时中止。不编译着色器。
/// r186: `releaseShaderCache` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L668
/// r186: `remove` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLShaderCache.js#L34
pub fn ShaderCache::release_shader_cache(
  self : ShaderCache,
  material_id : Int,
) -> Unit {
  match self.material_cache.get(material_id) {
    None =>
      abort(
        "THREE.WebGLShaderCache: Can not release material <" +
        material_id.to_string() +
        ">",
      )
    Some(stages) => {
      let mut index = 0
      while index < stages.length() {
        let stage = stages[index]
        stage.used_times.val = stage.used_times.val - 1
        if stage.used_times.val == 0 {
          ignore(self.shader_cache.remove(stage.code))
        }
        index = index + 1
      }
      ignore(self.material_cache.remove(material_id))
    }
  }
}

///|
/// 清空源码表和材质表。已经取出的阶段引用次数不变，编号也不回收。程序缓存不在这里清。
/// r186: `dispose` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L674
/// r186: `dispose` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLShaderCache.js#L64
pub fn ShaderCache::dispose(self : ShaderCache) -> Unit {
  self.shader_cache.clear()
  self.material_cache.clear()
}

