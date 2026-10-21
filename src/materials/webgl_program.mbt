// r186: `prefixVertex` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L599

///|
/// 着色器材质的默认顶点着色器。字符串以换行开头，`gl_Position` 那一行用制表符缩进，并以换行结束。
/// r186: `default_vertex` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/default_vertex.glsl.js#L1
fn default_vertex_shader() -> String {
  "\nvoid main() {\n\tgl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );\n}\n"
}

///|
/// 着色器材质的默认片元着色器。字符串以换行开头，`gl_FragColor` 那一行用制表符缩进，红色通道是 `1`，绿色和蓝色是 `0`，并以换行结束。
/// r186: `default_fragment` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/default_fragment.glsl.js#L1
fn default_fragment_shader() -> String {
  "\nvoid main() {\n\tgl_FragColor = vec4( 1.0, 0.0, 0.0, 1.0 );\n}\n"
}

///|
/// 展开着色器里的 `#include <名字>`。行首可以有空格或制表符。`#include` 后面至少一个空格，然后是 `<名字>`。名字由字母、数字、下划线、`.` 和 `/` 组成。整段匹配换成表里的文本，并且继续展开。同一行 `>` 后面的文字留下。`#include` 后面紧跟制表符不展开。表里没有这个名字就中止。
/// r186: `resolveIncludes` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L247
pub fn resolve_includes(source : String, chunks : Map[String, String]) -> String {
  let count = source.length()
  let mut index = 0
  let mut resolved = ""
  while index < count {
    match include_at(source, index) {
      Some((end, name)) => {
        resolved = resolved + included_chunk(name, chunks)
        let mut line_end = end
        while line_end < count && source[line_end:line_end + 1] != "\n" {
          line_end = line_end + 1
        }
        if line_end < count {
          line_end = line_end + 1
        }
        resolved = resolved + source[end:line_end].to_owned()
        index = line_end
      }
      None => {
        let mut line_end = index
        while line_end < count && source[line_end:line_end + 1] != "\n" {
          line_end = line_end + 1
        }
        if line_end < count {
          line_end = line_end + 1
        }
        resolved = resolved + source[index:line_end].to_owned()
        index = line_end
      }
    }
  }
  resolved
}

///|
fn include_at(source : String, start : Int) -> Option[(Int, String)] {
  let count = source.length()
  let mut index = start
  while index < count {
    let ch = source[index:index + 1]
    if ch == " " || ch == "\t" {
      index = index + 1
    } else {
      break
    }
  }
  let keyword = "#include"
  let keyword_end = index + keyword.length()
  if keyword_end > count || source[index:keyword_end] != keyword {
    return None
  }
  index = keyword_end
  if index >= count || source[index:index + 1] != " " {
    return None
  }
  while index < count && source[index:index + 1] == " " {
    index = index + 1
  }
  if index >= count || source[index:index + 1] != "<" {
    return None
  }
  index = index + 1
  let name_start = index
  let charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_./"
  while index < count && charset.contains(source[index:index + 1]) {
    index = index + 1
  }
  if index == name_start || index >= count || source[index:index + 1] != ">" {
    return None
  }
  Some((index + 1, source[name_start:index].to_owned()))
}

///|
fn included_chunk(name : String, chunks : Map[String, String]) -> String {
  match chunks.get(name) {
    None => abort("THREE.WebGLProgram: Can not resolve #include <" + name + ">")
    Some(chunk) => resolve_includes(chunk, chunks)
  }
}

///|
/// 把着色器里的灯光数量占位符换成整数。`NUM_SUN_LIGHTS`、`NUM_DIR_LIGHTS`、`NUM_SPOT_LIGHTS`、`NUM_SPOT_LIGHT_MAPS`、`NUM_RECT_AREA_LIGHTS`、`NUM_POINT_LIGHTS`、`NUM_HEMI_LIGHTS`、`NUM_SUN_LIGHT_SHADOWS`、`NUM_DIR_LIGHT_SHADOWS`、`NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS`、`NUM_SPOT_LIGHT_SHADOWS` 和 `NUM_POINT_LIGHT_SHADOWS` 都会替换。`NUM_SPOT_LIGHT_COORDS` 是聚光阴影数加上聚光贴图数，再减去带贴图的聚光阴影数。没传的数量是 `0`。`NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS` 先换，避免被较短的 `NUM_SPOT_LIGHT_SHADOWS` 截断。顶点前缀和片元前缀不加这一步。
/// r186: `replaceLightNums` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L215
pub fn replace_light_nums(
  source : String,
  num_sun_lights~ : Int = 0,
  num_dir_lights~ : Int = 0,
  num_spot_lights~ : Int = 0,
  num_spot_light_maps~ : Int = 0,
  num_rect_area_lights~ : Int = 0,
  num_point_lights~ : Int = 0,
  num_hemi_lights~ : Int = 0,
  num_sun_light_shadows~ : Int = 0,
  num_dir_light_shadows~ : Int = 0,
  num_spot_light_shadows_with_maps~ : Int = 0,
  num_spot_light_shadows~ : Int = 0,
  num_point_light_shadows~ : Int = 0,
) -> String {
  let num_spot_light_coords = num_spot_light_shadows +
    num_spot_light_maps -
    num_spot_light_shadows_with_maps
  replace_all(source, "NUM_SUN_LIGHTS", num_sun_lights.to_string())
    |> replace_all("NUM_DIR_LIGHTS", num_dir_lights.to_string())
    |> replace_all("NUM_SPOT_LIGHTS", num_spot_lights.to_string())
    |> replace_all("NUM_SPOT_LIGHT_MAPS", num_spot_light_maps.to_string())
    |> replace_all("NUM_SPOT_LIGHT_COORDS", num_spot_light_coords.to_string())
    |> replace_all("NUM_RECT_AREA_LIGHTS", num_rect_area_lights.to_string())
    |> replace_all("NUM_POINT_LIGHTS", num_point_lights.to_string())
    |> replace_all("NUM_HEMI_LIGHTS", num_hemi_lights.to_string())
    |> replace_all("NUM_SUN_LIGHT_SHADOWS", num_sun_light_shadows.to_string())
    |> replace_all("NUM_DIR_LIGHT_SHADOWS", num_dir_light_shadows.to_string())
    |> replace_all(
      "NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS",
      num_spot_light_shadows_with_maps.to_string(),
    )
    |> replace_all("NUM_SPOT_LIGHT_SHADOWS", num_spot_light_shadows.to_string())
    |> replace_all("NUM_POINT_LIGHT_SHADOWS", num_point_light_shadows.to_string())
}

///|
fn replace_all(source : String, from : String, to : String) -> String {
  let count = source.length()
  let width = from.length()
  let mut index = 0
  let mut replaced = ""
  while index < count {
    if index + width <= count && source[index:index + width] == from {
      replaced = replaced + to
      index = index + width
    } else {
      replaced = replaced + source[index:index + 1].to_owned()
      index = index + 1
    }
  }
  replaced
}

///|
/// 把着色器里的裁剪平面数量换成整数。`NUM_CLIPPING_PLANES` 写成裁剪平面数。`UNION_CLIPPING_PLANES` 写成裁剪平面数减去相交裁剪平面数。没传的数量是 `0`。顶点前缀和片元前缀不加这一步。
/// r186: `replaceClippingPlaneNums` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L235
pub fn replace_clipping_plane_nums(
  source : String,
  num_clipping_planes~ : Int = 0,
  num_clip_intersection~ : Int = 0,
) -> String {
  let union_planes = num_clipping_planes - num_clip_intersection
  replace_all(source, "NUM_CLIPPING_PLANES", num_clipping_planes.to_string())
    |> replace_all("UNION_CLIPPING_PLANES", union_planes.to_string())
}

///|
/// 展开 `#pragma unroll_loop_start` 到 `#pragma unroll_loop_end` 之间的 `for ( int i = 起点; i < 终点; i ++ )`。起点含在内，终点不含。循环体里的 `[ i ]` 换成 `[ 数字 ]`，`UNROLLED_LOOP_INDEX` 换成同一个数字。起点不小于终点时，整段删掉。对不上的开头原样留下。顶点前缀和片元前缀不加这一步。
/// r186: `unrollLoops` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L284
pub fn unroll_loops(source : String) -> String {
  let count = source.length()
  let marker = "#pragma unroll_loop_start"
  let mut index = 0
  let mut resolved = ""
  while index < count {
    match find_from(source, marker, index) {
      None => {
        resolved = resolved + source[index:count].to_owned()
        index = count
      }
      Some(at) => {
        resolved = resolved + source[index:at].to_owned()
        match parse_unroll(source, at) {
          None => {
            resolved = resolved + source[at:at + 1].to_owned()
            index = at + 1
          }
          Some((end, loop_start, loop_end, snippet)) => {
            resolved = resolved + unroll_snippet(snippet, loop_start, loop_end)
            index = end
          }
        }
      }
    }
  }
  resolved
}

///|
fn find_from(source : String, needle : String, start : Int) -> Option[Int] {
  let count = source.length()
  let width = needle.length()
  let mut index = start
  while index + width <= count {
    if source[index:index + width] == needle {
      return Some(index)
    }
    index = index + 1
  }
  None
}

///|
fn is_shader_space(ch : String) -> Bool {
  ch == " " || ch == "\t" || ch == "\n" || ch == "\r"
}

///|
fn skip_shader_space(source : String, start : Int, required : Bool) -> Option[Int] {
  let count = source.length()
  let mut index = start
  let mut seen = false
  while index < count && is_shader_space(source[index:index + 1].to_owned()) {
    seen = true
    index = index + 1
  }
  if required && !seen {
    None
  } else {
    Some(index)
  }
}

///|
fn expect_literal(source : String, start : Int, literal : String) -> Option[Int] {
  let end = start + literal.length()
  if end <= source.length() && source[start:end] == literal {
    Some(end)
  } else {
    None
  }
}

///|
fn read_shader_digits(source : String, start : Int) -> Option[(Int, Int)] {
  let count = source.length()
  let mut index = start
  let mut value = 0
  let mut seen = false
  while index < count {
    let ch = source[index:index + 1]
    let digit = match ch {
      "0" => 0
      "1" => 1
      "2" => 2
      "3" => 3
      "4" => 4
      "5" => 5
      "6" => 6
      "7" => 7
      "8" => 8
      "9" => 9
      _ => -1
    }
    if digit < 0 {
      break
    }
    seen = true
    value = value * 10 + digit
    index = index + 1
  }
  if seen {
    Some((index, value))
  } else {
    None
  }
}

///|
fn parse_unroll(source : String, start : Int) -> Option[(Int, Int, Int, String)] {
  match expect_literal(source, start, "#pragma unroll_loop_start") {
    None => return None
    Some(index) => {
      match step_unroll(source, index) {
        None => None
        Some((end, loop_start, loop_end, snippet)) =>
          Some((end, loop_start, loop_end, snippet))
      }
    }
  }
}

///|
fn step_unroll(
  source : String,
  start : Int,
) -> Option[(Int, Int, Int, String)] {
  let mut index = start
  match skip_shader_space(source, index, true) {
    None => return None
    Some(next) => index = next
  }
  match expect_literal(source, index, "for") {
    None => return None
    Some(next) => index = next
  }
  match skip_shader_space(source, index, false) {
    None => return None
    Some(next) => index = next
  }
  match expect_literal(source, index, "(") {
    None => return None
    Some(next) => index = next
  }
  match skip_shader_space(source, index, false) {
    None => return None
    Some(next) => index = next
  }
  match expect_literal(source, index, "int") {
    None => return None
    Some(next) => index = next
  }
  match skip_shader_space(source, index, true) {
    None => return None
    Some(next) => index = next
  }
  match expect_literal(source, index, "i") {
    None => return None
    Some(next) => index = next
  }
  match skip_shader_space(source, index, false) {
    None => return None
    Some(next) => index = next
  }
  match expect_literal(source, index, "=") {
    None => return None
    Some(next) => index = next
  }
  match skip_shader_space(source, index, false) {
    None => return None
    Some(next) => index = next
  }
  let loop_start = match read_shader_digits(source, index) {
    None => return None
    Some((next, value)) => {
      index = next
      value
    }
  }
  match skip_shader_space(source, index, false) {
    None => return None
    Some(next) => index = next
  }
  match expect_literal(source, index, ";") {
    None => return None
    Some(next) => index = next
  }
  match skip_shader_space(source, index, false) {
    None => return None
    Some(next) => index = next
  }
  match expect_literal(source, index, "i") {
    None => return None
    Some(next) => index = next
  }
  match skip_shader_space(source, index, false) {
    None => return None
    Some(next) => index = next
  }
  match expect_literal(source, index, "<") {
    None => return None
    Some(next) => index = next
  }
  match skip_shader_space(source, index, false) {
    None => return None
    Some(next) => index = next
  }
  let loop_end = match read_shader_digits(source, index) {
    None => return None
    Some((next, value)) => {
      index = next
      value
    }
  }
  match skip_shader_space(source, index, false) {
    None => return None
    Some(next) => index = next
  }
  match expect_literal(source, index, ";") {
    None => return None
    Some(next) => index = next
  }
  match skip_shader_space(source, index, false) {
    None => return None
    Some(next) => index = next
  }
  match expect_literal(source, index, "i") {
    None => return None
    Some(next) => index = next
  }
  match skip_shader_space(source, index, false) {
    None => return None
    Some(next) => index = next
  }
  match expect_literal(source, index, "++") {
    None => return None
    Some(next) => index = next
  }
  match skip_shader_space(source, index, false) {
    None => return None
    Some(next) => index = next
  }
  match expect_literal(source, index, ")") {
    None => return None
    Some(next) => index = next
  }
  match skip_shader_space(source, index, false) {
    None => return None
    Some(next) => index = next
  }
  match expect_literal(source, index, "{") {
    None => return None
    Some(next) => index = next
  }
  match unroll_body(source, index) {
    None => None
    Some((end, snippet)) => Some((end, loop_start, loop_end, snippet))
  }
}

///|
fn unroll_body(source : String, body_start : Int) -> Option[(Int, String)] {
  let count = source.length()
  let mut index = body_start
  while index < count {
    if source[index:index + 1] == "}" {
      let snippet = source[body_start:index].to_owned()
      if snippet.length() > 0 {
        match skip_shader_space(source, index + 1, false) {
          None => ()
          Some(after) =>
            match expect_literal(source, after, "#pragma unroll_loop_end") {
              None => ()
              Some(end) => return Some((end, snippet))
            }
        }
      }
    }
    index = index + 1
  }
  None
}

///|
fn unroll_snippet(snippet : String, loop_start : Int, loop_end : Int) -> String {
  let mut index = loop_start
  let mut resolved = ""
  while index < loop_end {
    let replaced = replace_index_brackets(snippet, index)
      |> replace_all("UNROLLED_LOOP_INDEX", index.to_string())
    resolved = resolved + replaced
    index = index + 1
  }
  resolved
}

///|
fn replace_index_brackets(source : String, value : Int) -> String {
  let count = source.length()
  let mut index = 0
  let mut replaced = ""
  while index < count {
    match bracket_i_end(source, index) {
      Some(end) => {
        replaced = replaced + "[ " + value.to_string() + " ]"
        index = end
      }
      None => {
        replaced = replaced + source[index:index + 1].to_owned()
        index = index + 1
      }
    }
  }
  replaced
}

///|
fn bracket_i_end(source : String, start : Int) -> Option[Int] {
  if start >= source.length() || source[start:start + 1] != "[" {
    return None
  }
  match skip_shader_space(source, start + 1, false) {
    None => None
    Some(index) =>
      if index >= source.length() || source[index:index + 1] != "i" {
        None
      } else {
        match skip_shader_space(source, index + 1, false) {
          None => None
          Some(index) =>
            if index < source.length() && source[index:index + 1] == "]" {
              Some(index + 1)
            } else {
              None
            }
        }
      }
  }
}

///|
fn builtin_vertex_attribute_prefix() -> String {
  "uniform mat4 modelMatrix;\nuniform mat4 modelViewMatrix;\nuniform mat4 projectionMatrix;\nuniform mat4 viewMatrix;\nuniform mat3 normalMatrix;\nuniform vec3 cameraPosition;\nuniform bool isOrthographic;\n#ifdef USE_INSTANCING\n\tattribute mat4 instanceMatrix;\n#endif\n#ifdef USE_INSTANCING_COLOR\n\tattribute vec3 instanceColor;\n#endif\n#ifdef USE_INSTANCING_MORPH\n\tuniform sampler2D morphTexture;\n#endif\nattribute vec3 position;\nattribute vec3 normal;\nattribute vec2 uv;\n#ifdef USE_UV1\n\tattribute vec2 uv1;\n#endif\n#ifdef USE_UV2\n\tattribute vec2 uv2;\n#endif\n#ifdef USE_UV3\n\tattribute vec2 uv3;\n#endif\n#ifdef USE_TANGENT\n\tattribute vec4 tangent;\n#endif\n#if defined( USE_COLOR_ALPHA )\n\tattribute vec4 color;\n#elif defined( USE_COLOR )\n\tattribute vec3 color;\n#endif\n#ifdef USE_SKINNING\n\tattribute vec4 skinIndex;\n\tattribute vec4 skinWeight;\n#endif\n\n"
}

///|
fn precision_word(precision : @constants.Precision?) -> String {
  match precision {
    None => "highp"
    Some(@constants.Precision::Highp) => "highp"
    Some(@constants.Precision::Mediump) => "mediump"
    Some(@constants.Precision::Lowp) => "lowp"
  }
}

///|
fn precision_define(precision : @constants.Precision?) -> String {
  match precision {
    None => "HIGH_PRECISION"
    Some(@constants.Precision::Highp) => "HIGH_PRECISION"
    Some(@constants.Precision::Mediump) => "MEDIUM_PRECISION"
    Some(@constants.Precision::Lowp) => "LOW_PRECISION"
  }
}

///|
fn precision_prefix(precision : @constants.Precision?) -> String {
  let name = precision_word(precision)
  let kinds = [
    "int", "sampler2D", "samplerCube", "sampler3D", "sampler2DArray",
    "sampler2DShadow", "samplerCubeShadow", "sampler2DArrayShadow", "isampler2D",
    "isampler3D", "isamplerCube", "isampler2DArray", "usampler2D", "usampler3D",
    "usamplerCube", "usampler2DArray",
  ]
  let mut text = "precision " + name + " float;"
  for kind in kinds {
    text = text + "\n\tprecision " + name + " " + kind + ";"
  }
  text + "\n\t\n#define " + precision_define(precision)
}

///|
fn glsl3_vertex_defines(extensions : ShaderExtensions) -> String {
  let mut head = ""
  if extensions.clip_cull_distance {
    head = "#extension GL_ANGLE_clip_cull_distance : require"
  }
  if extensions.multi_draw {
    if head.length() > 0 {
      head = head + "\n"
    }
    head = head + "#extension GL_ANGLE_multi_draw : require"
  }
  head +
  "\n#define attribute in\n#define varying out\n#define texture2D texture\n"
}

///|
/// 顶点着色器前面的版本行、GLSL3 改写和内置 uniform。Shader 先写 `#version 300 es`，这 16 个字符后面是 `68` 个字符的顶点改写：空扩展时以换行开头，接着 `#define attribute in`、`#define varying out` 和 `#define texture2D texture`。`clip_cull_distance` 打开再加 `48`，`multi_draw` 打开再加 `40`，两个都开加 `89`。然后是长 `543` 的精度声明、长 `35` 的 `#define SHADER_TYPE ShaderMaterial`、空名字时长 `21` 的 `#define SHADER_NAME`，再加长 `833` 的 uniform 和 attribute。Raw 和其它材质原样返回 `vertex_shader`。表里的每个键写成 `#define 键 值`。空表不加字符。调用方标明裁剪剔除距离扩展可用，且材质 `clip_cull_distance` 打开时，再写 `#define USE_CLIP_DISTANCE`，连换行长 `26`。只开其中一项不加这行。这行只在顶点前缀。调用方标明对象是合批网格时再写 `#define USE_BATCHING`，连换行长 `21`。不是合批网格不加。这行只在顶点前缀。调用方标明合批网格带颜色贴图时再写 `#define USE_BATCHING_COLOR`，连换行长 `27`。没有这张贴图不加。这行只在顶点前缀。调用方标明对象是实例网格时再写 `#define USE_INSTANCING`，连换行长 `23`。不是实例网格不加。这行只在顶点前缀。调用方标明实例网格带 `instanceColor` 时再写 `#define USE_INSTANCING_COLOR`，连换行长 `29`。没有实例颜色不加。这行只在顶点前缀。调用方标明实例网格带 `morphTexture` 时再写 `#define USE_INSTANCING_MORPH`，连换行长 `29`。没有这张形变贴图不加。这行只在顶点前缀。打包法线只写在片元前缀。色散也只写在片元前缀。逆反射也只写在片元前缀。彩虹强度也只写在片元前缀。alpha 测试也只写在片元前缀。光泽也只写在片元前缀。实例色的 `USE_COLOR` 只写在片元前缀。合批颜色的 `USE_COLOR_ALPHA` 只写在片元前缀。Lambert、Phong、Standard、Physical 没有法线、没有法线贴图且不是线框时，两段前缀都写 `#define FLAT_SHADED`，连换行长 `20`，正文仍是空串。有法线、有法线贴图或线框不加。缺法线时不写 `USE_TANGENT`。有法线且各向异性大于 `0` 时写这行，连换行长 `20`。缺法线时不写 `USE_MORPHNORMALS`。有法线时顶点前缀写这行，连换行长 `25`，片元前缀不加。光照材质打开 `flat_shading` 且不是线框时写 `#define FLAT_SHADED`，连换行长 `20`。Basic 不加。内置前缀有法线时写 `#define HAS_NORMAL`，连换行长 `19`，片元前缀不加。内置前缀的 `USE_COLOR` 仍不写。场景有雾且材质 `fog` 打开时再写 `#define USE_FOG`，连换行长 `16`。缺一项不加。材质 `fog` 打开且场景雾是指数雾时再写 `#define FOG_EXP2`，连换行长 `17`。普通雾不加这行。有颜色贴图时再写 `#define USE_MAP`，连换行长 `16`。没有贴图不加。有环境贴图时再写 `#define USE_ENVMAP`，连换行长 `19`，接着写 `#define ENVMAP_MODE_REFLECTION`，连换行长 `31`。贴图还没有 mapping，所以这行固定是反射。没有环境贴图这两行都不加。有光照贴图时再写 `#define USE_LIGHTMAP`，连换行长 `21`。没有光照贴图不加。有环境光遮蔽贴图时再写 `#define USE_AOMAP`，连换行长 `18`。没有环境光遮蔽贴图不加。有凹凸贴图时再写 `#define USE_BUMPMAP`，连换行长 `20`。没有凹凸贴图不加。有法线贴图时再写 `#define USE_NORMALMAP`，连换行长 `22`。物体空间再写 `#define USE_NORMALMAP_OBJECTSPACE`，连换行长 `34`。切线空间再写 `#define USE_NORMALMAP_TANGENTSPACE`，连换行长 `35`。两种类型只写其中一行。没有法线贴图这三行都不加。有位移贴图时顶点字符串再写 `#define USE_DISPLACEMENTMAP`，连换行长 `28`。片元字符串不加。没有位移贴图不加。有自发光贴图时再写 `#define USE_EMISSIVEMAP`，连换行长 `24`。没有自发光贴图不加。各向异性大于 `0` 时再写 `#define USE_ANISOTROPY`，连换行长 `23`。等于 `0` 或小于 `0` 不加。大于 `0` 且有各向异性贴图时再写 `#define USE_ANISOTROPYMAP`，连换行长 `26`。没有贴图或各向异性不大于 `0` 不加。清漆大于 `0` 且有清漆贴图时再写 `#define USE_CLEARCOATMAP`，连换行长 `25`。没有贴图或清漆不大于 `0` 不加。清漆大于 `0` 且有清漆粗糙度贴图时再写 `#define USE_CLEARCOAT_ROUGHNESSMAP`，连换行长 `35`。没有这张贴图不加。清漆大于 `0` 且有清漆法线贴图时再写 `#define USE_CLEARCOAT_NORMALMAP`，连换行长 `32`。没有这张法线贴图不加。彩虹大于 `0` 且有彩虹贴图时再写 `#define USE_IRIDESCENCEMAP`，连换行长 `27`。彩虹不大于 `0` 或不挂贴图不加。彩虹大于 `0` 且有厚度贴图时再写 `#define USE_IRIDESCENCE_THICKNESSMAP`，连换行长 `37`。没有厚度贴图不加。有高光贴图时再写 `#define USE_SPECULARMAP`，连换行长 `24`。没有高光贴图不加。有高光颜色贴图时再写 `#define USE_SPECULAR_COLORMAP`，连换行长 `30`。没有高光颜色贴图不加。有高光强度贴图时再写 `#define USE_SPECULAR_INTENSITYMAP`，连换行长 `34`。没有高光强度贴图不加。有粗糙度贴图时再写 `#define USE_ROUGHNESSMAP`，连换行长 `25`。没有粗糙度贴图不加。有金属度贴图时再写 `#define USE_METALNESSMAP`，连换行长 `25`。没有金属度贴图不加。有透明贴图时再写 `#define USE_ALPHAMAP`，连换行长 `21`。没有透明贴图不加。`alpha_hash` 打开时再写 `#define USE_ALPHAHASH`，连换行长 `22`。关闭不加。`transmission` 大于 `0` 时再写 `#define USE_TRANSMISSION`，连换行长 `25`。等于 `0` 或小于 `0` 不加。大于 `0` 且有透射贴图时再写 `#define USE_TRANSMISSIONMAP`，连换行长 `28`。没有贴图或透射不大于 `0` 不加。大于 `0` 且有厚度贴图时再写 `#define USE_THICKNESSMAP`，连换行长 `25`。没有厚度贴图不加。`sheen` 大于 `0` 且有光泽颜色贴图时，顶点字符串在厚度宏后面写 `#define USE_SHEEN_COLORMAP`，连换行长 `27`。大于 `0` 且有光泽粗糙度贴图时再写 `#define USE_SHEEN_ROUGHNESSMAP`，连换行长 `31`。`sheen` 不大于 `0` 或不挂对应贴图不加。有颜色贴图时，顶点字符串在这些宏后面写 `#define MAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `18`。通道 `1` 是 `uv1`，连换行长 `19`。没有颜色贴图不加。有透明贴图时再写 `#define ALPHAMAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `23`。通道 `1` 是 `uv1`，连换行长 `24`。没有透明贴图不加。有光照贴图时再写 `#define LIGHTMAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `23`。通道 `1` 是 `uv1`，连换行长 `24`。没有光照贴图不加。有环境光遮蔽贴图时再写 `#define AOMAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `20`。通道 `1` 是 `uv1`，连换行长 `21`。没有环境光遮蔽贴图不加。有自发光贴图时再写 `#define EMISSIVEMAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `26`。通道 `1` 是 `uv1`，连换行长 `27`。没有自发光贴图不加。有凹凸贴图且 `wireframe` 关闭时再写 `#define BUMPMAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `22`。通道 `1` 是 `uv1`，连换行长 `23`。没有凹凸贴图或线框打开不加。有法线贴图时再写 `#define NORMALMAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `24`。通道 `1` 是 `uv1`，连换行长 `25`。没有法线贴图不加。有位移贴图时再写 `#define DISPLACEMENTMAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `30`。通道 `1` 是 `uv1`，连换行长 `31`。没有位移贴图不加。有金属度贴图时再写 `#define METALNESSMAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `27`。通道 `1` 是 `uv1`，连换行长 `28`。没有金属度贴图不加。有粗糙度贴图时再写 `#define ROUGHNESSMAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `27`。通道 `1` 是 `uv1`，连换行长 `28`。没有粗糙度贴图不加。`anisotropy` 大于 `0` 且有各向异性贴图时再写 `#define ANISOTROPYMAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `28`。通道 `1` 是 `uv1`，连换行长 `29`。不大于 `0` 或没有贴图不加。`clearcoat` 大于 `0` 且有清漆贴图时再写 `#define CLEARCOATMAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `27`。通道 `1` 是 `uv1`，连换行长 `28`。不大于 `0` 或没有清漆贴图不加。`clearcoat` 大于 `0` 且有清漆法线贴图时再写 `#define CLEARCOAT_NORMALMAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `34`。通道 `1` 是 `uv1`，连换行长 `35`。不大于 `0` 或没有清漆法线贴图不加。`clearcoat` 大于 `0` 且有清漆粗糙度贴图时再写 `#define CLEARCOAT_ROUGHNESSMAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `37`。通道 `1` 是 `uv1`，连换行长 `38`。不大于 `0` 或没有清漆粗糙度贴图不加。`iridescence` 大于 `0` 且有彩虹贴图时再写 `#define IRIDESCENCEMAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `29`。通道 `1` 是 `uv1`，连换行长 `30`。不大于 `0` 或没有彩虹贴图不加。`iridescence` 大于 `0` 且有彩虹厚度贴图时再写 `#define IRIDESCENCE_THICKNESSMAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `39`。通道 `1` 是 `uv1`，连换行长 `40`。不大于 `0` 或没有彩虹厚度贴图不加。`sheen` 大于 `0` 且有光泽颜色贴图时再写 `#define SHEEN_COLORMAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `29`。通道 `1` 是 `uv1`，连换行长 `30`。不大于 `0` 或没有光泽颜色贴图不加。`sheen` 大于 `0` 且有光泽粗糙度贴图时再写 `#define SHEEN_ROUGHNESSMAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `33`。通道 `1` 是 `uv1`，连换行长 `34`。不大于 `0` 或没有光泽粗糙度贴图不加。有高光贴图时再写 `#define SPECULARMAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `26`。通道 `1` 是 `uv1`，连换行长 `27`。没有高光贴图不加。有高光颜色贴图时再写 `#define SPECULAR_COLORMAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `32`。通道 `1` 是 `uv1`，连换行长 `33`。没有高光颜色贴图不加。有高光强度贴图时再写 `#define SPECULAR_INTENSITYMAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `36`。通道 `1` 是 `uv1`，连换行长 `37`。没有高光强度贴图不加。`transmission` 大于 `0` 且有透射贴图时再写 `#define TRANSMISSIONMAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `30`。通道 `1` 是 `uv1`，连换行长 `31`。不大于 `0` 或没有透射贴图不加。`transmission` 大于 `0` 且有厚度贴图时再写 `#define THICKNESSMAP_UV ` 加通道名。通道 `0` 是 `uv`，连换行长 `27`。通道 `1` 是 `uv1`，连换行长 `28`。不大于 `0` 或没有厚度贴图不加。片元字符串不加这二十三行。几何带切线，并且有法线贴图或各向异性大于 `0`，而且平坦着色参数为假时，顶点字符串和片元字符串都再写 `#define USE_TANGENT`，连换行长 `20`。`flat_shading` 打开且 `wireframe` 关闭时该参数为真，两行都不加。`wireframe` 打开时参数为假，行会留下。没有切线、没有法线贴图且各向异性不大于 `0` 不加。缺法线时不写 `USE_TANGENT`。有法线且各向异性大于 `0` 时写这行，连换行长 `20`。缺法线时不写 `USE_MORPHNORMALS`。有法线时顶点前缀写这行，连换行长 `25`，片元前缀不加。光照材质打开 `flat_shading` 且不是线框时写 `#define FLAT_SHADED`，连换行长 `20`。Basic 不加。内置前缀有法线时写 `#define HAS_NORMAL`，连换行长 `19`，片元前缀不加。内置前缀的 `USE_COLOR` 仍不写。几何带法线时顶点字符串再写 `#define HAS_NORMAL`，连换行长 `19`。片元字符串不加。没有法线不加。`vertex_colors` 打开时顶点字符串和片元字符串都再写 `#define USE_COLOR`，连换行长 `18`。关闭不加。实例色留到后面。`vertex_colors` 打开且颜色属性是四维时，顶点字符串和片元字符串都再写 `#define USE_COLOR_ALPHA`，连换行长 `24`。顶点色关闭或颜色不是四维不加。合批颜色留到后面。有贴图通道 `1` 时，顶点字符串和片元字符串都再写 `#define USE_UV1`，连换行长 `16`。通道 `0` 或其他通道不加。有贴图通道 `2` 时再写 `#define USE_UV2`，连换行长 `16`。通道 `0`、`1` 或其他通道不加。有贴图通道 `3` 时再写 `#define USE_UV3`，连换行长 `16`。通道 `0`、`1`、`2` 或其他通道不加。点对象带 `uv`，并且有颜色贴图或透明贴图时，再写 `#define USE_POINTS_UV`，连换行长 `22`。没有这个标记，或两种贴图都没有，不加。`flat_shading` 打开且 `wireframe` 关闭时，再写 `#define FLAT_SHADED`，连换行长 `20`。`wireframe` 打开或平坦着色关闭不加。Lambert、Phong、Standard、Physical 没有法线也没有法线贴图时同样写这行，连换行长 `20`，正文仍是空串。有法线、有法线贴图或线框不加。缺法线时不写 `USE_TANGENT`。有法线且各向异性大于 `0` 时写这行，连换行长 `20`。缺法线时不写 `USE_MORPHNORMALS`。有法线时顶点前缀写这行，连换行长 `25`，片元前缀不加。光照材质打开 `flat_shading` 且不是线框时写 `#define FLAT_SHADED`，连换行长 `20`。Basic 不加。内置前缀有法线时写 `#define HAS_NORMAL`，连换行长 `19`，片元前缀不加。内置前缀的 `USE_COLOR` 仍不写。蒙皮网格时再写 `#define USE_SKINNING`，连换行长 `21`。不是蒙皮网格不加。片元字符串不加。几何有位置变形目标时再写 `#define USE_MORPHTARGETS`，连换行长 `25`。没有位置变形目标不加。片元字符串不加。几何有法线变形目标且平坦着色参数为假时，再写 `#define USE_MORPHNORMALS`，连换行长 `25`。没有法线变形目标不加。`flat_shading` 打开且 `wireframe` 关闭时不加。`wireframe` 打开仍写。片元字符串不加。几何有颜色变形目标时再写 `#define USE_MORPHCOLORS`，连换行长 `24`。没有颜色变形目标不加。片元字符串不加。变形目标数量大于 `0` 时再写 `#define MORPHTARGETS_TEXTURE_STRIDE ` 加步长。步长 `1` 连换行长 `38`。数量不大于 `0` 不加。片元字符串不加。数量大于 `0` 时再写 `#define MORPHTARGETS_COUNT ` 加数量。数量 `1` 连换行长 `29`。数量不大于 `0` 不加。片元字符串不加。`side` 为双面时，顶点字符串再写 `#define DOUBLE_SIDED`，连换行长 `21`。正面或背面不加。`side` 为背面时，顶点字符串再写 `#define FLIP_SIDED`，连换行长 `19`。正面或双面不加。阴影贴图打开时，顶点字符串再写 `#define USE_SHADOWMAP`，连换行长 `22`。关闭不加。阴影贴图打开时再写 `#define SHADOWMAP_TYPE_BASIC`，连换行长 `29`。关闭不加。PCF 阴影改写 `#define SHADOWMAP_TYPE_PCF`，连换行长 `27`，不再写 `SHADOWMAP_TYPE_BASIC`。阴影贴图关闭仍不加。VSM 阴影改写 `#define SHADOWMAP_TYPE_VSM`，连换行长 `27`，不再写 `SHADOWMAP_TYPE_BASIC` 或 `SHADOWMAP_TYPE_PCF`。阴影贴图关闭仍不加。尺寸衰减打开时，顶点字符串再写 `#define USE_SIZEATTENUATION`，连换行长 `28`。关闭不加。片元字符串不加。光照探针数量大于 `0` 时，顶点字符串再写 `#define USE_LIGHT_PROBES`，连换行长 `25`。数量不大于 `0` 不加。对数深度打开时，顶点字符串再写 `#define USE_LOGARITHMIC_DEPTH_BUFFER`，连换行长 `37`。关闭不加。反向深度打开时，顶点字符串再写 `#define USE_REVERSED_DEPTH_BUFFER`，连换行长 `34`。关闭不加。渲染器仍不编译这串代码。
/// r186: `generatePrecision` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L308
/// r186: `SHADER_TYPE` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L479
/// r186: `SHADER_NAME` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L480
/// r186: `generateDefines` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L160
/// r186: `USE_MAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L494
/// r186: `USE_ENVMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L495
/// r186: `generateEnvMapModeDefine` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L376
/// r186: `ENVMAP_MODE` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L496
/// r186: `USE_LIGHTMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L497
/// r186: `USE_AOMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L498
/// r186: `USE_BUMPMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L499
/// r186: `USE_NORMALMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L500
/// r186: `normalMapObjectSpace` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L228
/// r186: `USE_NORMALMAP_OBJECTSPACE` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L501
/// r186: `normalMapTangentSpace` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L229
/// r186: `USE_NORMALMAP_TANGENTSPACE` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L502
/// r186: `USE_DISPLACEMENTMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L503
/// r186: `USE_EMISSIVEMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L504
/// r186: `HAS_ANISOTROPY` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L140
/// r186: `USE_ANISOTROPY` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L506
/// r186: `HAS_ANISOTROPYMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L148
/// r186: `USE_ANISOTROPYMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L507
/// r186: `HAS_CLEARCOATMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L150
/// r186: `USE_CLEARCOATMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L509
/// r186: `HAS_CLEARCOAT_ROUGHNESSMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L152
/// r186: `USE_CLEARCOAT_ROUGHNESSMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L510
/// r186: `HAS_CLEARCOAT_NORMALMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L151
/// r186: `USE_CLEARCOAT_NORMALMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L511
/// r186: `HAS_IRIDESCENCEMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L154
/// r186: `USE_IRIDESCENCEMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L513
/// r186: `HAS_IRIDESCENCE_THICKNESSMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L155
/// r186: `USE_IRIDESCENCE_THICKNESSMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L514
/// r186: `HAS_SPECULARMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L160
/// r186: `USE_SPECULARMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L516
/// r186: `HAS_SPECULAR_COLORMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L161
/// r186: `USE_SPECULAR_COLORMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L517
/// r186: `HAS_SPECULAR_INTENSITYMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L162
/// r186: `USE_SPECULAR_INTENSITYMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L518
/// r186: `HAS_ROUGHNESSMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L138
/// r186: `USE_ROUGHNESSMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L520
/// r186: `HAS_METALNESSMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L137
/// r186: `USE_METALNESSMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L521
/// r186: `HAS_ALPHAMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L169
/// r186: `USE_ALPHAMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L522
/// r186: `HAS_ALPHAHASH` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L173
/// r186: `USE_ALPHAHASH` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L523
/// r186: `HAS_TRANSMISSION` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L146
/// r186: `USE_TRANSMISSION` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L525
/// r186: `HAS_TRANSMISSIONMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L164
/// r186: `USE_TRANSMISSIONMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L526
/// r186: `HAS_THICKNESSMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L165
/// r186: `USE_THICKNESSMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L527
/// r186: `HAS_SHEEN_COLORMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L157
/// r186: `USE_SHEEN_COLORMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L529
/// r186: `HAS_SHEEN_ROUGHNESSMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L158
/// r186: `USE_SHEEN_ROUGHNESSMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L530
/// r186: `getChannel` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L46
/// r186: `mapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L274
/// r186: `MAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L534
/// r186: `HAS_ALPHAMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L169
/// r186: `alphaMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L304
/// r186: `ALPHAMAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L535
/// r186: `HAS_LIGHTMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L131
/// r186: `lightMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L276
/// r186: `LIGHTMAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L536
/// r186: `HAS_AOMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L130
/// r186: `aoMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L275
/// r186: `AOMAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L537
/// r186: `HAS_EMISSIVEMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L135
/// r186: `emissiveMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L280
/// r186: `EMISSIVEMAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L538
/// r186: `HAS_BUMPMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L132
/// r186: `bumpMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L277
/// r186: `BUMPMAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L539
/// r186: `HAS_NORMALMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L133
/// r186: `normalMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L278
/// r186: `NORMALMAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L540
/// r186: `HAS_DISPLACEMENTMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L134
/// r186: `displacementMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L279
/// r186: `DISPLACEMENTMAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L541
/// r186: `HAS_METALNESSMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L137
/// r186: `metalnessMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L282
/// r186: `METALNESSMAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L543
/// r186: `HAS_ROUGHNESSMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L138
/// r186: `roughnessMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L283
/// r186: `ROUGHNESSMAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L544
/// r186: `HAS_ANISOTROPYMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L148
/// r186: `anisotropyMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L285
/// r186: `ANISOTROPYMAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L546
/// r186: `HAS_CLEARCOATMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L150
/// r186: `clearcoatMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L287
/// r186: `CLEARCOATMAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L548
/// r186: `HAS_CLEARCOAT_NORMALMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L151
/// r186: `clearcoatNormalMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L288
/// r186: `CLEARCOAT_NORMALMAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L549
/// r186: `HAS_CLEARCOAT_ROUGHNESSMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L152
/// r186: `clearcoatRoughnessMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L289
/// r186: `CLEARCOAT_ROUGHNESSMAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L550
/// r186: `HAS_IRIDESCENCEMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L154
/// r186: `iridescenceMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L291
/// r186: `IRIDESCENCEMAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L552
/// r186: `HAS_IRIDESCENCE_THICKNESSMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L155
/// r186: `iridescenceThicknessMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L292
/// r186: `IRIDESCENCE_THICKNESSMAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L553
/// r186: `HAS_SHEEN_COLORMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L157
/// r186: `sheenColorMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L294
/// r186: `SHEEN_COLORMAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L555
/// r186: `HAS_SHEEN_ROUGHNESSMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L158
/// r186: `sheenRoughnessMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L295
/// r186: `SHEEN_ROUGHNESSMAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L556
/// r186: `HAS_SPECULARMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L160
/// r186: `specularMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L297
/// r186: `SPECULARMAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L558
/// r186: `HAS_SPECULAR_COLORMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L161
/// r186: `specularColorMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L298
/// r186: `SPECULAR_COLORMAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L559
/// r186: `HAS_SPECULAR_INTENSITYMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L162
/// r186: `specularIntensityMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L299
/// r186: `SPECULAR_INTENSITYMAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L560
/// r186: `HAS_TRANSMISSIONMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L164
/// r186: `transmissionMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L301
/// r186: `TRANSMISSIONMAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L562
/// r186: `HAS_THICKNESSMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L165
/// r186: `thicknessMapUv` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L302
/// r186: `THICKNESSMAP_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L563
/// r186: `vertexTangents` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L308
/// r186: `flatShading` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L319
/// r186: `USE_TANGENT` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L567
/// r186: `vertexNormals` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L309
/// r186: `HAS_NORMAL` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L568
/// r186: `vertexColors` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L310
/// r186: `USE_COLOR` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L569
/// r186: `vertexAlphas` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L311
/// r186: `USE_COLOR_ALPHA` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L570
/// r186: `vertexUv1s` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L392
/// r186: `USE_UV1` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L571
/// r186: `vertexUv2s` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L393
/// r186: `USE_UV2` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L572
/// r186: `vertexUv3s` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L394
/// r186: `USE_UV3` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L573
/// r186: `pointsUvs` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L313
/// r186: `USE_POINTS_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L575
/// r186: `flatShading` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L319
/// r186: `FLAT_SHADED` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L577
/// r186: `skinning` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L330
/// r186: `USE_SKINNING` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L579
/// r186: `morphTargets` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L334
/// r186: `USE_MORPHTARGETS` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L581
/// r186: `morphNormals` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L335
/// r186: `USE_MORPHNORMALS` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L582
/// r186: `morphColors` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L336
/// r186: `USE_MORPHCOLORS` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L583
/// r186: `morphTargetsCount` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L86
/// r186: `morphTextureStride` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L88
/// r186: `MORPHTARGETS_TEXTURE_STRIDE` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L584
/// r186: `MORPHTARGETS_COUNT` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L585
/// r186: `doubleSided` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L373
/// r186: `DOUBLE_SIDED` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L586
/// r186: `flipSided` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L374
/// r186: `FLIP_SIDED` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L587
/// r186: `shadowMapEnabled` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L363
/// r186: `USE_SHADOWMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L589
/// r186: `generateShadowMapTypeDefine` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L352
/// r186: `SHADOWMAP_TYPE_BASIC` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L354
/// r186: `PCFShadowMap` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L65
/// r186: `SHADOWMAP_TYPE_PCF` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L348
/// r186: `VSMShadowMap` https://github.com/mrdoob/three.js/blob/r186/src/constants.js#L84
/// r186: `SHADOWMAP_TYPE_VSM` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L349
/// r186: `sizeAttenuation` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L326
/// r186: `USE_SIZEATTENUATION` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L592
/// r186: `numLightProbes` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L354
/// r186: `USE_LIGHT_PROBES` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L594
/// r186: `logarithmicDepthBuffer` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L327
/// r186: `USE_LOGARITHMIC_DEPTH_BUFFER` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L596
/// r186: `reversedDepthBuffer` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L328
/// r186: `USE_REVERSED_DEPTH_BUFFER` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L597
/// r186: `shaderName` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L193
/// r186: `shaderType` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L192
/// r186: `versionString` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L808
/// r186: `prefixVertex` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L810
/// r186: `generateVertexExtensions` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L149
/// r186: `vertexGlsl` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L835
/// r186: `USE_CLIP_DISTANCE` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L484
/// r186: `USE_BATCHING` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L485
/// r186: `USE_BATCHING_COLOR` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L486
/// r186: `USE_INSTANCING` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L487
/// r186: `USE_INSTANCING_COLOR` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L488
/// r186: `USE_INSTANCING_MORPH` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L489
/// r186: `USE_FOG` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L491
/// r186: `FOG_EXP2` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L492
pub fn Material::prefixed_vertex_shader(
  self : Material,
  has_tangent~ : Bool = false,
  has_normal~ : Bool = false,
  has_vertex_alpha~ : Bool = false,
  has_points_uv~ : Bool = false,
  has_skinning~ : Bool = false,
  has_morph_targets~ : Bool = false,
  has_morph_normals~ : Bool = false,
  has_morph_colors~ : Bool = false,
  morph_targets_count~ : Int = 0,
  morph_texture_stride~ : Int = 0,
  shadow_map_enabled~ : Bool = false,
  shadow_map_pcf~ : Bool = false,
  shadow_map_vsm~ : Bool = false,
  size_attenuation~ : Bool = false,
  num_light_probes~ : Int = 0,
  logarithmic_depth_buffer~ : Bool = false,
  reversed_depth_buffer~ : Bool = false,
  has_fog~ : Bool = false,
  fog_exp2~ : Bool = false,
  has_clip_cull_distance~ : Bool = false,
  batching~ : Bool = false,
  batching_color~ : Bool = false,
  instancing~ : Bool = false,
  instancing_color~ : Bool = false,
  instancing_morph~ : Bool = false,
) -> String {
  if self.is_shader_material && !self.is_raw_shader_material {
    shader_version_line() +
    glsl3_vertex_defines(self.extensions) +
    precision_prefix(self.precision) +
    shader_type_line(self.type_name) +
    shader_name_line(self.name) +
    custom_define_lines(self.defines) +
    use_clip_distance_line(has_clip_cull_distance, self.extensions.clip_cull_distance) +
    use_batching_line(batching) +
    use_batching_color_line(batching_color) +
    use_instancing_line(instancing) +
    use_instancing_color_line(instancing_color) +
    use_instancing_morph_line(instancing_morph) +
    use_fog_line(has_fog, self.fog) +
    fog_exp2_line(self.fog, fog_exp2) +
    use_map_line(self.map) +
    use_envmap_line(self.env_map) +
    envmap_mode_line(self.env_map) +
    use_lightmap_line(self.light_map) +
    use_aomap_line(self.ao_map) +
    use_bumpmap_line(self.bump_map) +
    use_normalmap_line(self.normal_map) +
    normalmap_object_line(self.normal_map, self.normal_map_type) +
    normalmap_tangent_line(self.normal_map, self.normal_map_type) +
    use_displacementmap_line(self.displacement_map) +
    use_emissivemap_line(self.emissive_map) +
    use_anisotropy_line(self.anisotropy) +
    use_anisotropymap_line(self.anisotropy, self.anisotropy_map) +
    use_clearcoatmap_line(self.clearcoat, self.clearcoat_map) +
    use_clearcoat_roughnessmap_line(self.clearcoat, self.clearcoat_roughness_map) +
    use_clearcoat_normalmap_line(self.clearcoat, self.clearcoat_normal_map) +
    use_iridescencemap_line(self.iridescence, self.iridescence_map) +
    use_iridescence_thicknessmap_line(
      self.iridescence,
      self.iridescence_thickness_map,
    ) +
    use_specularmap_line(self.specular_map) +
    use_specular_colormap_line(self.specular_color_map) +
    use_specular_intensitymap_line(self.specular_intensity_map) +
    use_roughnessmap_line(self.roughness_map) +
    use_metalnessmap_line(self.metalness_map) +
    use_alphamap_line(self.alpha_map) +
    use_alphahash_line(self.alpha_hash) +
    use_transmission_line(self.transmission) +
    use_transmissionmap_line(self.transmission, self.transmission_map) +
    use_thicknessmap_line(self.transmission, self.thickness_map) +
    use_sheen_colormap_line(self.sheen, self.sheen_color_map) +
    use_sheen_roughnessmap_line(self.sheen, self.sheen_roughness_map) +
    map_uv_line(self.map) +
    alphamap_uv_line(self.alpha_map) +
    lightmap_uv_line(self.light_map) +
    aomap_uv_line(self.ao_map) +
    emissivemap_uv_line(self.emissive_map) +
    bumpmap_uv_line(self.bump_map, self.wireframe) +
    normalmap_uv_line(self.normal_map) +
    displacementmap_uv_line(self.displacement_map) +
    metalnessmap_uv_line(self.metalness_map) +
    roughnessmap_uv_line(self.roughness_map) +
    anisotropymap_uv_line(self.anisotropy, self.anisotropy_map) +
    clearcoatmap_uv_line(self.clearcoat, self.clearcoat_map) +
    clearcoat_normalmap_uv_line(self.clearcoat, self.clearcoat_normal_map) +
    clearcoat_roughnessmap_uv_line(self.clearcoat, self.clearcoat_roughness_map) +
    iridescencemap_uv_line(self.iridescence, self.iridescence_map) +
    iridescence_thicknessmap_uv_line(
      self.iridescence,
      self.iridescence_thickness_map,
    ) +
    sheen_colormap_uv_line(self.sheen, self.sheen_color_map) +
    sheen_roughnessmap_uv_line(self.sheen, self.sheen_roughness_map) +
    specularmap_uv_line(self.specular_map) +
    specular_colormap_uv_line(self.specular_color_map) +
    specular_intensitymap_uv_line(self.specular_intensity_map) +
    transmissionmap_uv_line(self.transmission, self.transmission_map) +
    thicknessmap_uv_line(self.transmission, self.thickness_map) +
    use_tangent_line(
      has_tangent,
      self.normal_map,
      self.anisotropy,
      self.wireframe,
      self.program_flat_shading(has_normal=has_normal),
    ) +
    has_normal_line(has_normal) +
    use_color_line(self.vertex_colors) +
    use_color_alpha_line(self.vertex_colors, has_vertex_alpha) +
    self.use_uv1_line() +
    self.use_uv2_line() +
    self.use_uv3_line() +
    use_points_uv_line(has_points_uv, self.map, self.alpha_map) +
    flat_shaded_line(
      self.wireframe,
      self.program_flat_shading(has_normal=has_normal),
    ) +
    use_skinning_line(has_skinning) +
    use_morph_targets_line(has_morph_targets) +
    use_morph_normals_line(
      has_morph_normals,
      self.wireframe,
      self.program_flat_shading(has_normal=has_normal),
    ) +
    use_morph_colors_line(has_morph_colors) +
    morph_targets_texture_stride_line(morph_targets_count, morph_texture_stride) +
    morph_targets_count_line(morph_targets_count) +
    double_sided_line(self.side) +
    flip_sided_line(self.side) +
    use_shadowmap_line(shadow_map_enabled) +
    shadowmap_type_line(shadow_map_enabled, shadow_map_pcf, shadow_map_vsm) +
    use_size_attenuation_line(size_attenuation) +
    use_light_probes_line(num_light_probes) +
    use_logarithmic_depth_buffer_line(logarithmic_depth_buffer) +
    use_reversed_depth_buffer_line(reversed_depth_buffer) +
    builtin_vertex_attribute_prefix() +
    self.vertex_shader
  } else {
    self.builtin_flat_shaded_prefix(
      has_normal,
      has_tangent,
      has_morph_normals,
      write_has_normal=has_normal,
    ) +
    self.vertex_shader
  }
}

///|
fn builtin_fragment_uniform_prefix() -> String {
  "uniform mat4 viewMatrix;\nuniform vec3 cameraPosition;\nuniform bool isOrthographic;"
}

///|
fn glsl3_fragment_defines(version : GlslVersion?) -> String {
  let layout = match version {
    Some(GLSL3) => ""
    Some(GLSL1) => "layout(location = 0) out highp vec4 pc_fragColor;"
    None => "layout(location = 0) out highp vec4 pc_fragColor;"
  }
  let frag_color = match version {
    Some(GLSL3) => ""
    Some(GLSL1) => "#define gl_FragColor pc_fragColor"
    None => "#define gl_FragColor pc_fragColor"
  }
  "#define varying in\n" +
  layout +
  "\n" +
  frag_color +
  "\n#define gl_FragDepthEXT gl_FragDepth\n#define texture2D texture\n#define textureCube texture\n#define texture2DProj textureProj\n#define texture2DLodEXT textureLod\n#define texture2DProjLodEXT textureProjLod\n#define textureCubeLodEXT textureLod\n#define texture2DGradEXT textureGrad\n#define texture2DProjGradEXT textureProjGrad\n#define textureCubeGradEXT textureGrad\n"
}

///|
fn shader_type_line(type_name : String) -> String {
  "#define SHADER_TYPE " + type_name + "\n"
}

///|
fn shader_name_line(name : String) -> String {
  "#define SHADER_NAME " + name + "\n"
}

///|
fn normalmap_object_line(
  normal_map : @textures.Texture?,
  normal_map_type : @constants.NormalMapType,
) -> String {
  match normal_map {
    None => ""
    Some(_) =>
      match normal_map_type {
        ObjectSpace => "#define USE_NORMALMAP_OBJECTSPACE\n"
        TangentSpace => ""
      }
  }
}

///|
fn normalmap_tangent_line(
  normal_map : @textures.Texture?,
  normal_map_type : @constants.NormalMapType,
) -> String {
  match normal_map {
    None => ""
    Some(_) =>
      match normal_map_type {
        TangentSpace => "#define USE_NORMALMAP_TANGENTSPACE\n"
        ObjectSpace => ""
      }
  }
}

///|
fn texture_uses_channel(texture : @textures.Texture?, channel : Int) -> Bool {
  match texture {
    None => false
    Some(texture) => texture.channel == channel
  }
}

///|
fn Material::uses_uv_channel(self : Material, channel : Int) -> Bool {
  texture_uses_channel(self.map, channel) ||
  texture_uses_channel(self.alpha_map, channel) ||
  texture_uses_channel(self.light_map, channel) ||
  texture_uses_channel(self.ao_map, channel) ||
  texture_uses_channel(self.emissive_map, channel) ||
  (!self.wireframe && texture_uses_channel(self.bump_map, channel)) ||
  texture_uses_channel(self.normal_map, channel) ||
  texture_uses_channel(self.displacement_map, channel) ||
  texture_uses_channel(self.metalness_map, channel) ||
  texture_uses_channel(self.roughness_map, channel) ||
  (self.anisotropy > 0.0 && texture_uses_channel(self.anisotropy_map, channel)) ||
  (self.clearcoat > 0.0 && texture_uses_channel(self.clearcoat_map, channel)) ||
  (self.clearcoat > 0.0 && texture_uses_channel(self.clearcoat_normal_map, channel)) ||
  (
    self.clearcoat > 0.0 && texture_uses_channel(self.clearcoat_roughness_map, channel)
  ) ||
  (self.iridescence > 0.0 && texture_uses_channel(self.iridescence_map, channel)) ||
  (
    self.iridescence > 0.0 &&
    texture_uses_channel(self.iridescence_thickness_map, channel)
  ) ||
  (self.sheen > 0.0 && texture_uses_channel(self.sheen_color_map, channel)) ||
  (self.sheen > 0.0 && texture_uses_channel(self.sheen_roughness_map, channel)) ||
  texture_uses_channel(self.specular_map, channel) ||
  texture_uses_channel(self.specular_color_map, channel) ||
  texture_uses_channel(self.specular_intensity_map, channel) ||
  (
    self.transmission > 0.0 && texture_uses_channel(self.transmission_map, channel)
  ) ||
  (self.transmission > 0.0 && texture_uses_channel(self.thickness_map, channel))
}

///|
fn Material::use_uv1_line(self : Material) -> String {
  if self.uses_uv_channel(1) {
    "#define USE_UV1\n"
  } else {
    ""
  }
}

///|
fn Material::use_uv2_line(self : Material) -> String {
  if self.uses_uv_channel(2) {
    "#define USE_UV2\n"
  } else {
    ""
  }
}

///|
fn Material::use_uv3_line(self : Material) -> String {
  if self.uses_uv_channel(3) {
    "#define USE_UV3\n"
  } else {
    ""
  }
}

///|
fn use_points_uv_line(
  has_points_uv : Bool,
  map : @textures.Texture?,
  alpha_map : @textures.Texture?,
) -> String {
  if has_points_uv {
    match (map, alpha_map) {
      (None, None) => ""
      _ => "#define USE_POINTS_UV\n"
    }
  } else {
    ""
  }
}

///|
fn use_gradientmap_line(gradient_map : @textures.Texture?) -> String {
  match gradient_map {
    None => ""
    Some(_) => "#define USE_GRADIENTMAP\n"
  }
}

///|
fn flat_shaded_line(wireframe : Bool, flat_shading : Bool) -> String {
  if !wireframe && flat_shading {
    "#define FLAT_SHADED\n"
  } else {
    ""
  }
}

///|
fn Material::builtin_flat_shaded_prefix(
  self : Material,
  has_normal : Bool,
  has_tangent : Bool,
  has_morph_normals : Bool,
  write_has_normal~ : Bool = false,
) -> String {
  if self.is_raw_shader_material || self.is_shader_material {
    ""
  } else {
    let flat = self.program_flat_shading(has_normal=has_normal)
    let tangent = if flat_shading_derived_kind(self.kind) {
      use_tangent_line(
        has_tangent,
        self.normal_map,
        self.anisotropy,
        self.wireframe,
        flat,
      )
    } else {
      ""
    }
    let morph = if flat_shading_derived_kind(self.kind) {
      use_morph_normals_line(has_morph_normals, self.wireframe, flat)
    } else {
      ""
    }
    let normal = has_normal_line(write_has_normal)
    let shaded = if flat_shading_derived_kind(self.kind) && flat {
      "#define FLAT_SHADED\n"
    } else {
      ""
    }
    tangent + normal + morph + shaded
  }
}

///|
fn use_skinning_line(has_skinning : Bool) -> String {
  if has_skinning {
    "#define USE_SKINNING\n"
  } else {
    ""
  }
}

///|
fn use_morph_targets_line(has_morph_targets : Bool) -> String {
  if has_morph_targets {
    "#define USE_MORPHTARGETS\n"
  } else {
    ""
  }
}

///|
fn use_morph_normals_line(
  has_morph_normals : Bool,
  wireframe : Bool,
  flat_shading : Bool,
) -> String {
  let flat = !wireframe && flat_shading
  if has_morph_normals && !flat {
    "#define USE_MORPHNORMALS\n"
  } else {
    ""
  }
}

///|
fn use_morph_colors_line(has_morph_colors : Bool) -> String {
  if has_morph_colors {
    "#define USE_MORPHCOLORS\n"
  } else {
    ""
  }
}

///|
fn morph_targets_texture_stride_line(count : Int, stride : Int) -> String {
  if count > 0 {
    "#define MORPHTARGETS_TEXTURE_STRIDE " + stride.to_string() + "\n"
  } else {
    ""
  }
}

///|
fn morph_targets_count_line(count : Int) -> String {
  if count > 0 {
    "#define MORPHTARGETS_COUNT " + count.to_string() + "\n"
  } else {
    ""
  }
}

///|
fn double_sided_line(side : @constants.Side) -> String {
  match side {
    Double => "#define DOUBLE_SIDED\n"
    Front | Back => ""
  }
}

///|
fn flip_sided_line(side : @constants.Side) -> String {
  match side {
    Back => "#define FLIP_SIDED\n"
    Front | Double => ""
  }
}

///|
fn use_shadowmap_line(shadow_map_enabled : Bool) -> String {
  if shadow_map_enabled {
    "#define USE_SHADOWMAP\n"
  } else {
    ""
  }
}

///|
fn premultiplied_alpha_line(premultiplied_alpha : Bool) -> String {
  if premultiplied_alpha {
    "#define PREMULTIPLIED_ALPHA\n"
  } else {
    ""
  }
}

///|
fn use_size_attenuation_line(size_attenuation : Bool) -> String {
  if size_attenuation {
    "#define USE_SIZEATTENUATION\n"
  } else {
    ""
  }
}

///|
fn use_light_probes_line(num_light_probes : Int) -> String {
  if num_light_probes > 0 {
    "#define USE_LIGHT_PROBES\n"
  } else {
    ""
  }
}

///|
fn use_light_probes_grid_line(num_light_probe_grids : Int) -> String {
  if num_light_probe_grids > 0 {
    "#define USE_LIGHT_PROBES_GRID\n"
  } else {
    ""
  }
}

///|
fn decode_video_texture_line(decode_video_texture : Bool) -> String {
  if decode_video_texture {
    "#define DECODE_VIDEO_TEXTURE\n"
  } else {
    ""
  }
}

///|
fn decode_video_texture_emissive_line(decode_video_texture_emissive : Bool) -> String {
  if decode_video_texture_emissive {
    "#define DECODE_VIDEO_TEXTURE_EMISSIVE\n"
  } else {
    ""
  }
}

///|
fn use_logarithmic_depth_buffer_line(logarithmic_depth_buffer : Bool) -> String {
  if logarithmic_depth_buffer {
    "#define USE_LOGARITHMIC_DEPTH_BUFFER\n"
  } else {
    ""
  }
}

///|
fn use_reversed_depth_buffer_line(reversed_depth_buffer : Bool) -> String {
  if reversed_depth_buffer {
    "#define USE_REVERSED_DEPTH_BUFFER\n"
  } else {
    ""
  }
}

///|
fn tone_mapping_line(tone_mapping : @constants.ToneMapping) -> String {
  match tone_mapping {
    No => ""
    Linear | Reinhard | Cineon | ACES | AgX | Neutral =>
      "\n#define TONE_MAPPING\n" +
      tonemapping_pars_fragment() +
      "\n" +
      tone_mapping_function(tone_mapping) +
      "\n"
  }
}

///|
/// `No` 回落到 `Linear`。调用处在 `No` 时不写这行。
/// r186: `getToneMappingFunction` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L110
/// r186: `getToneMappingFunction` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L776
fn tone_mapping_function(tone_mapping : @constants.ToneMapping) -> String {
  let name = match tone_mapping {
    No | Linear => "Linear"
    Reinhard => "Reinhard"
    Cineon => "Cineon"
    ACES => "ACESFilmic"
    AgX => "AgX"
    Neutral => "Neutral"
  }
  "vec3 toneMapping( vec3 color ) { return " + name + "ToneMapping( color ); }"
}

///|
/// `tone_mapping` 为 `No` 时，内置 uniform 不以换行结束，所以宏前面补一个换行。其它取值时，色调映射函数那一行已经以换行结束。
/// r186: `dithering` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L361
/// r186: `DITHERING` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L778
fn dithering_line(
  dithering : Bool,
  tone_mapping : @constants.ToneMapping,
) -> String {
  if dithering {
    match tone_mapping {
      No => "\n#define DITHERING\n"
      Linear | Reinhard | Cineon | ACES | AgX | Neutral => "#define DITHERING\n"
    }
  } else {
    ""
  }
}

///|
/// 不透明、普通混合、并且没有 alpha to coverage 时写这行。前面已经有换行时不再补换行。
/// r186: `opaque` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L264
/// r186: `OPAQUE` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L779
fn opaque_line(
  transparent : Bool,
  blending : @constants.Blending,
  alpha_to_coverage : Bool,
  dithering : Bool,
  tone_mapping : @constants.ToneMapping,
) -> String {
  let is_opaque = match blending {
    Normal => !transparent && !alpha_to_coverage
    No | Additive | Subtractive | Multiply | Custom => false
  }
  if is_opaque {
    if dithering {
      "#define OPAQUE\n"
    } else {
      match tone_mapping {
        No => "\n#define OPAQUE\n"
        Linear | Reinhard | Cineon | ACES | AgX | Neutral => "#define OPAQUE\n"
      }
    }
  } else {
    ""
  }
}

///|
/// 片元前缀里的颜色空间转换。字符串以两个换行开头、以换行结束，长 `496`。非 Raw 的 Shader 总是写入。前面没有换行时再补一个换行。
/// r186: `colorspace_pars_fragment` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/colorspace_pars_fragment.glsl.js#L1
/// r186: `colorspace_pars_fragment` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L781
fn colorspace_pars_fragment() -> String {
  let chunk =
    #|
    #|
    #|vec4 LinearTransferOETF( in vec4 value ) {
    #|	return value;
    #|}
    #|
    #|vec4 sRGBTransferEOTF( in vec4 value ) {
    #|	return vec4( mix( pow( value.rgb * 0.9478672986 + vec3( 0.0521327014 ), vec3( 2.4 ) ), value.rgb * 0.0773993808, vec3( lessThanEqual( value.rgb, vec3( 0.04045 ) ) ) ), value.a );
    #|}
    #|
    #|vec4 sRGBTransferOETF( in vec4 value ) {
    #|	return vec4( mix( pow( value.rgb, vec3( 0.41666 ) ) * 1.055 - vec3( 0.055 ), value.rgb * 12.92, vec3( lessThanEqual( value.rgb, vec3( 0.0031308 ) ) ) ), value.a );
    #|}
    #|
    #|
  chunk
}

///|
/// 颜色空间块接在 `OPAQUE` 后面。`dithering`、色调映射或 `OPAQUE` 已经以换行结束时直接接上。三者都没有时先补一个换行。
/// r186: `colorspace_pars_fragment` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L781
fn colorspace_pars_line(
  transparent : Bool,
  blending : @constants.Blending,
  alpha_to_coverage : Bool,
  dithering : Bool,
  tone_mapping : @constants.ToneMapping,
) -> String {
  let chunk = colorspace_pars_fragment()
  if dithering {
    chunk
  } else {
    match tone_mapping {
      No => {
        let is_opaque = match blending {
          Normal => !transparent && !alpha_to_coverage
          No | Additive | Subtractive | Multiply | Custom => false
        }
        if is_opaque {
          chunk
        } else {
          "\n" + chunk
        }
      }
      Linear | Reinhard | Cineon | ACES | AgX | Neutral => chunk
    }
  }
}

///|
/// 把线性颜色编成输出纹理。工作空间和线性 sRGB、sRGB 共用单位矩阵。`output_srgb` 为真时用 `sRGBTransferOETF`，为假时用 `LinearTransferOETF`。
/// r186: `getTexelEncodingFunction` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L84
/// r186: `getEncodingComponents` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L36
/// r186: `getTexelEncodingFunction` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L782
fn texel_encoding_line(output_srgb : Bool) -> String {
  let transfer = if output_srgb { "sRGBTransferOETF" } else { "LinearTransferOETF" }
  "\nvec4 linearToOutputTexel( vec4 value ) {\n return " +
  transfer +
  "( vec4( value.rgb * mat3( 1.0000, 0.0000, 0.0000, 0.0000, 1.0000, 0.0000, 0.0000, 0.0000, 1.0000 ), value.a ) );\n}\n"
}

///|
/// 线性 sRGB 的亮度权重。`0.2126`、`0.7152`、`0.0722` 各保留四位小数。
/// r186: `getLuminanceFunction` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L127
/// r186: `getLuminanceCoefficients` https://github.com/mrdoob/three.js/blob/r186/src/math/ColorManagement.js#L112
/// r186: `getLuminanceFunction` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L783
fn luminance_line() -> String {
  "\nfloat luminance( const in vec3 rgb ) {\n const vec3 weights = vec3( 0.2126, 0.7152, 0.0722 );\n return dot( weights, rgb );\n}\n"
}

///|
/// `depth_packing` 小于 `0` 表示材质没有这个字段。大于等于 `0` 时写成 `#define DEPTH_PACKING` 加这个整数。
/// r186: `useDepthPacking` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L376
/// r186: `depthPacking` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L377
/// r186: `DEPTH_PACKING` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L785
fn depth_packing_line(depth_packing : Int) -> String {
  if depth_packing >= 0 {
    "#define DEPTH_PACKING " + depth_packing.to_string() + "\n"
  } else {
    ""
  }
}

///|
/// 片元前缀里的色调映射函数。字符串以换行开头、以换行结束，长 `5231`。`tone_mapping` 关闭时不写。
/// r186: `tonemapping_pars_fragment` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/tonemapping_pars_fragment.glsl.js#L1
/// r186: `tonemapping_pars_fragment` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L775
fn tonemapping_pars_fragment() -> String {
  let chunk =
    #|
  #|#ifndef saturate
  #|// <common> may have defined saturate() already
  #|#define saturate( a ) clamp( a, 0.0, 1.0 )
  #|#endif
  #|
  #|uniform float toneMappingExposure;
  #|
  #|// exposure only
  #|vec3 LinearToneMapping( vec3 color ) {
  #|
  #|	return saturate( toneMappingExposure * color );
  #|
  #|}
  #|
  #|// source: https://www.cs.utah.edu/docs/techreports/2002/pdf/UUCS-02-001.pdf
  #|vec3 ReinhardToneMapping( vec3 color ) {
  #|
  #|	color *= toneMappingExposure;
  #|	return saturate( color / ( vec3( 1.0 ) + color ) );
  #|
  #|}
  #|
  #|// source: http://filmicworlds.com/blog/filmic-tonemapping-operators/
  #|vec3 CineonToneMapping( vec3 color ) {
  #|
  #|	// filmic operator by Jim Hejl and Richard Burgess-Dawson
  #|	color *= toneMappingExposure;
  #|	color = max( vec3( 0.0 ), color - 0.004 );
  #|	return pow( ( color * ( 6.2 * color + 0.5 ) ) / ( color * ( 6.2 * color + 1.7 ) + 0.06 ), vec3( 2.2 ) );
  #|
  #|}
  #|
  #|// source: https://github.com/selfshadow/ltc_code/blob/master/webgl/shaders/ltc/ltc_blit.fs
  #|vec3 RRTAndODTFit( vec3 v ) {
  #|
  #|	vec3 a = v * ( v + 0.0245786 ) - 0.000090537;
  #|	vec3 b = v * ( 0.983729 * v + 0.4329510 ) + 0.238081;
  #|	return a / b;
  #|
  #|}
  #|
  #|// this implementation of ACES is modified to accommodate a brighter viewing environment.
  #|// the scale factor of 1/0.6 is subjective. see discussion in #19621.
  #|
  #|vec3 ACESFilmicToneMapping( vec3 color ) {
  #|
  #|	// sRGB => XYZ => D65_2_D60 => AP1 => RRT_SAT
  #|	const mat3 ACESInputMat = mat3(
  #|		vec3( 0.59719, 0.07600, 0.02840 ), // transposed from source
  #|		vec3( 0.35458, 0.90834, 0.13383 ),
  #|		vec3( 0.04823, 0.01566, 0.83777 )
  #|	);
  #|
  #|	// ODT_SAT => XYZ => D60_2_D65 => sRGB
  #|	const mat3 ACESOutputMat = mat3(
  #|		vec3(  1.60475, -0.10208, -0.00327 ), // transposed from source
  #|		vec3( -0.53108,  1.10813, -0.07276 ),
  #|		vec3( -0.07367, -0.00605,  1.07602 )
  #|	);
  #|
  #|	color *= toneMappingExposure / 0.6;
  #|
  #|	color = ACESInputMat * color;
  #|
  #|	// Apply RRT and ODT
  #|	color = RRTAndODTFit( color );
  #|
  #|	color = ACESOutputMat * color;
  #|
  #|	// Clamp to [0, 1]
  #|	return saturate( color );
  #|
  #|}
  #|
  #|// Matrices for rec 2020 <> rec 709 color space conversion
  #|// matrix provided in row-major order so it has been transposed
  #|// https://www.itu.int/pub/R-REP-BT.2407-2017
  #|const mat3 LINEAR_REC2020_TO_LINEAR_SRGB = mat3(
  #|	vec3( 1.6605, - 0.1246, - 0.0182 ),
  #|	vec3( - 0.5876, 1.1329, - 0.1006 ),
  #|	vec3( - 0.0728, - 0.0083, 1.1187 )
  #|);
  #|
  #|const mat3 LINEAR_SRGB_TO_LINEAR_REC2020 = mat3(
  #|	vec3( 0.6274, 0.0691, 0.0164 ),
  #|	vec3( 0.3293, 0.9195, 0.0880 ),
  #|	vec3( 0.0433, 0.0113, 0.8956 )
  #|);
  #|
  #|// https://iolite-engine.com/blog_posts/minimal_agx_implementation
  #|// Mean error^2: 3.6705141e-06
  #|vec3 agxDefaultContrastApprox( vec3 x ) {
  #|
  #|	vec3 x2 = x * x;
  #|	vec3 x4 = x2 * x2;
  #|
  #|	return + 15.5 * x4 * x2
  #|		- 40.14 * x4 * x
  #|		+ 31.96 * x4
  #|		- 6.868 * x2 * x
  #|		+ 0.4298 * x2
  #|		+ 0.1191 * x
  #|		- 0.00232;
  #|
  #|}
  #|
  #|// AgX Tone Mapping implementation based on Filament, which in turn is based
  #|// on Blender's implementation using rec 2020 primaries
  #|// https://github.com/google/filament/pull/7236
  #|// Inputs and outputs are encoded as Linear-sRGB.
  #|
  #|vec3 AgXToneMapping( vec3 color ) {
  #|
  #|	// AgX constants
  #|	const mat3 AgXInsetMatrix = mat3(
  #|		vec3( 0.856627153315983, 0.137318972929847, 0.11189821299995 ),
  #|		vec3( 0.0951212405381588, 0.761241990602591, 0.0767994186031903 ),
  #|		vec3( 0.0482516061458583, 0.101439036467562, 0.811302368396859 )
  #|	);
  #|
  #|	// explicit AgXOutsetMatrix generated from Filaments AgXOutsetMatrixInv
  #|	const mat3 AgXOutsetMatrix = mat3(
  #|		vec3( 1.1271005818144368, - 0.1413297634984383, - 0.14132976349843826 ),
  #|		vec3( - 0.11060664309660323, 1.157823702216272, - 0.11060664309660294 ),
  #|		vec3( - 0.016493938717834573, - 0.016493938717834257, 1.2519364065950405 )
  #|	);
  #|
  #|	// LOG2_MIN      = -10.0
  #|	// LOG2_MAX      =  +6.5
  #|	// MIDDLE_GRAY   =  0.18
  #|	const float AgxMinEv = - 12.47393;  // log2( pow( 2, LOG2_MIN ) * MIDDLE_GRAY )
  #|	const float AgxMaxEv = 4.026069;    // log2( pow( 2, LOG2_MAX ) * MIDDLE_GRAY )
  #|
  #|	color *= toneMappingExposure;
  #|
  #|	color = LINEAR_SRGB_TO_LINEAR_REC2020 * color;
  #|
  #|	color = AgXInsetMatrix * color;
  #|
  #|	// Log2 encoding
  #|	color = max( color, 1e-10 ); // avoid 0 or negative numbers for log2
  #|	color = log2( color );
  #|	color = ( color - AgxMinEv ) / ( AgxMaxEv - AgxMinEv );
  #|
  #|	color = clamp( color, 0.0, 1.0 );
  #|
  #|	// Apply sigmoid
  #|	color = agxDefaultContrastApprox( color );
  #|
  #|	// Apply AgX look
  #|	// v = agxLook(v, look);
  #|
  #|	color = AgXOutsetMatrix * color;
  #|
  #|	// Linearize
  #|	color = pow( max( vec3( 0.0 ), color ), vec3( 2.2 ) );
  #|
  #|	color = LINEAR_REC2020_TO_LINEAR_SRGB * color;
  #|
  #|	// Gamut mapping. Simple clamp for now.
  #|	color = clamp( color, 0.0, 1.0 );
  #|
  #|	return color;
  #|
  #|}
  #|
  #|// https://modelviewer.dev/examples/tone-mapping
  #|
  #|vec3 NeutralToneMapping( vec3 color ) {
  #|
  #|	const float StartCompression = 0.8 - 0.04;
  #|	const float Desaturation = 0.15;
  #|
  #|	color *= toneMappingExposure;
  #|
  #|	float x = min( color.r, min( color.g, color.b ) );
  #|
  #|	float offset = x < 0.08 ? x - 6.25 * x * x : 0.04;
  #|
  #|	color -= offset;
  #|
  #|	float peak = max( color.r, max( color.g, color.b ) );
  #|
  #|	if ( peak < StartCompression ) return color;
  #|
  #|	float d = 1. - StartCompression;
  #|
  #|	float newPeak = 1. - d * d / ( peak + d - StartCompression );
  #|
  #|	color *= newPeak / peak;
  #|
  #|	float g = 1. - 1. / ( Desaturation * ( peak - newPeak ) + 1. );
  #|
  #|	return mix( color, vec3( newPeak ), g );
  #|
  #|}
  #|
  #|vec3 CustomToneMapping( vec3 color ) { return color; }
  #|
  chunk
}

///|
fn shadowmap_type_line(
  shadow_map_enabled : Bool,
  shadow_map_pcf : Bool,
  shadow_map_vsm : Bool,
) -> String {
  if shadow_map_enabled {
    if shadow_map_vsm {
      "#define SHADOWMAP_TYPE_VSM\n"
    } else {
      if shadow_map_pcf {
        "#define SHADOWMAP_TYPE_PCF\n"
      } else {
        "#define SHADOWMAP_TYPE_BASIC\n"
      }
    }
  } else {
    ""
  }
}

///|
fn use_color_alpha_line(
  vertex_colors : Bool,
  has_vertex_alpha : Bool,
  batching_color~ : Bool = false,
) -> String {
  if (vertex_colors && has_vertex_alpha) || batching_color {
    "#define USE_COLOR_ALPHA\n"
  } else {
    ""
  }
}

///|
fn use_color_line(
  vertex_colors : Bool,
  instancing_color~ : Bool = false,
) -> String {
  if vertex_colors || instancing_color {
    "#define USE_COLOR\n"
  } else {
    ""
  }
}

///|
fn has_normal_line(has_normal : Bool) -> String {
  if has_normal {
    "#define HAS_NORMAL\n"
  } else {
    ""
  }
}

///|
fn use_tangent_line(
  has_tangent : Bool,
  normal_map : @textures.Texture?,
  anisotropy : Double,
  wireframe : Bool,
  flat_shading : Bool,
) -> String {
  let flat = !wireframe && flat_shading
  let needs_tangent = match normal_map {
    Some(_) => true
    None => anisotropy > 0.0
  }
  if has_tangent && needs_tangent && !flat {
    "#define USE_TANGENT\n"
  } else {
    ""
  }
}

///|
fn thicknessmap_uv_line(
  transmission : Double,
  thickness_map : @textures.Texture?,
) -> String {
  if transmission > 0.0 {
    match thickness_map {
      None => ""
      Some(texture) =>
        "#define THICKNESSMAP_UV " + uv_channel_name(texture.channel) + "\n"
    }
  } else {
    ""
  }
}

///|
fn transmissionmap_uv_line(
  transmission : Double,
  transmission_map : @textures.Texture?,
) -> String {
  if transmission > 0.0 {
    match transmission_map {
      None => ""
      Some(texture) =>
        "#define TRANSMISSIONMAP_UV " + uv_channel_name(texture.channel) + "\n"
    }
  } else {
    ""
  }
}

///|
fn specular_intensitymap_uv_line(
  specular_intensity_map : @textures.Texture?,
) -> String {
  match specular_intensity_map {
    None => ""
    Some(texture) =>
      "#define SPECULAR_INTENSITYMAP_UV " +
      uv_channel_name(texture.channel) +
      "\n"
  }
}

///|
fn specular_colormap_uv_line(specular_color_map : @textures.Texture?) -> String {
  match specular_color_map {
    None => ""
    Some(texture) =>
      "#define SPECULAR_COLORMAP_UV " + uv_channel_name(texture.channel) + "\n"
  }
}

///|
fn specularmap_uv_line(specular_map : @textures.Texture?) -> String {
  match specular_map {
    None => ""
    Some(texture) =>
      "#define SPECULARMAP_UV " + uv_channel_name(texture.channel) + "\n"
  }
}

///|
fn sheen_roughnessmap_uv_line(
  sheen : Double,
  sheen_roughness_map : @textures.Texture?,
) -> String {
  if sheen > 0.0 {
    match sheen_roughness_map {
      None => ""
      Some(texture) =>
        "#define SHEEN_ROUGHNESSMAP_UV " +
        uv_channel_name(texture.channel) +
        "\n"
    }
  } else {
    ""
  }
}

///|
fn sheen_colormap_uv_line(
  sheen : Double,
  sheen_color_map : @textures.Texture?,
) -> String {
  if sheen > 0.0 {
    match sheen_color_map {
      None => ""
      Some(texture) =>
        "#define SHEEN_COLORMAP_UV " + uv_channel_name(texture.channel) + "\n"
    }
  } else {
    ""
  }
}

///|
fn iridescence_thicknessmap_uv_line(
  iridescence : Double,
  iridescence_thickness_map : @textures.Texture?,
) -> String {
  if iridescence > 0.0 {
    match iridescence_thickness_map {
      None => ""
      Some(texture) =>
        "#define IRIDESCENCE_THICKNESSMAP_UV " +
        uv_channel_name(texture.channel) +
        "\n"
    }
  } else {
    ""
  }
}

///|
fn iridescencemap_uv_line(
  iridescence : Double,
  iridescence_map : @textures.Texture?,
) -> String {
  if iridescence > 0.0 {
    match iridescence_map {
      None => ""
      Some(texture) =>
        "#define IRIDESCENCEMAP_UV " + uv_channel_name(texture.channel) + "\n"
    }
  } else {
    ""
  }
}

///|
fn clearcoat_roughnessmap_uv_line(
  clearcoat : Double,
  clearcoat_roughness_map : @textures.Texture?,
) -> String {
  if clearcoat > 0.0 {
    match clearcoat_roughness_map {
      None => ""
      Some(texture) =>
        "#define CLEARCOAT_ROUGHNESSMAP_UV " +
        uv_channel_name(texture.channel) +
        "\n"
    }
  } else {
    ""
  }
}

///|
fn clearcoat_normalmap_uv_line(
  clearcoat : Double,
  clearcoat_normal_map : @textures.Texture?,
) -> String {
  if clearcoat > 0.0 {
    match clearcoat_normal_map {
      None => ""
      Some(texture) =>
        "#define CLEARCOAT_NORMALMAP_UV " +
        uv_channel_name(texture.channel) +
        "\n"
    }
  } else {
    ""
  }
}

///|
fn clearcoatmap_uv_line(
  clearcoat : Double,
  clearcoat_map : @textures.Texture?,
) -> String {
  if clearcoat > 0.0 {
    match clearcoat_map {
      None => ""
      Some(texture) =>
        "#define CLEARCOATMAP_UV " + uv_channel_name(texture.channel) + "\n"
    }
  } else {
    ""
  }
}

///|
fn anisotropymap_uv_line(
  anisotropy : Double,
  anisotropy_map : @textures.Texture?,
) -> String {
  if anisotropy > 0.0 {
    match anisotropy_map {
      None => ""
      Some(texture) =>
        "#define ANISOTROPYMAP_UV " + uv_channel_name(texture.channel) + "\n"
    }
  } else {
    ""
  }
}

///|
fn roughnessmap_uv_line(roughness_map : @textures.Texture?) -> String {
  match roughness_map {
    None => ""
    Some(texture) =>
      "#define ROUGHNESSMAP_UV " + uv_channel_name(texture.channel) + "\n"
  }
}

///|
fn metalnessmap_uv_line(metalness_map : @textures.Texture?) -> String {
  match metalness_map {
    None => ""
    Some(texture) =>
      "#define METALNESSMAP_UV " + uv_channel_name(texture.channel) + "\n"
  }
}

///|
fn displacementmap_uv_line(displacement_map : @textures.Texture?) -> String {
  match displacement_map {
    None => ""
    Some(texture) =>
      "#define DISPLACEMENTMAP_UV " + uv_channel_name(texture.channel) + "\n"
  }
}

///|
fn normalmap_uv_line(normal_map : @textures.Texture?) -> String {
  match normal_map {
    None => ""
    Some(texture) =>
      "#define NORMALMAP_UV " + uv_channel_name(texture.channel) + "\n"
  }
}

///|
fn bumpmap_uv_line(
  bump_map : @textures.Texture?,
  wireframe : Bool,
) -> String {
  if wireframe {
    ""
  } else {
    match bump_map {
      None => ""
      Some(texture) =>
        "#define BUMPMAP_UV " + uv_channel_name(texture.channel) + "\n"
    }
  }
}

///|
fn emissivemap_uv_line(emissive_map : @textures.Texture?) -> String {
  match emissive_map {
    None => ""
    Some(texture) =>
      "#define EMISSIVEMAP_UV " + uv_channel_name(texture.channel) + "\n"
  }
}

///|
fn aomap_uv_line(ao_map : @textures.Texture?) -> String {
  match ao_map {
    None => ""
    Some(texture) => "#define AOMAP_UV " + uv_channel_name(texture.channel) + "\n"
  }
}

///|
fn lightmap_uv_line(light_map : @textures.Texture?) -> String {
  match light_map {
    None => ""
    Some(texture) =>
      "#define LIGHTMAP_UV " + uv_channel_name(texture.channel) + "\n"
  }
}

///|
fn alphamap_uv_line(alpha_map : @textures.Texture?) -> String {
  match alpha_map {
    None => ""
    Some(texture) =>
      "#define ALPHAMAP_UV " + uv_channel_name(texture.channel) + "\n"
  }
}

///|
fn map_uv_line(map : @textures.Texture?) -> String {
  match map {
    None => ""
    Some(texture) => "#define MAP_UV " + uv_channel_name(texture.channel) + "\n"
  }
}

///|
fn uv_channel_name(channel : Int) -> String {
  if channel == 0 {
    "uv"
  } else {
    "uv" + channel.to_string()
  }
}

///|
fn use_sheen_roughnessmap_line(
  sheen : Double,
  sheen_roughness_map : @textures.Texture?,
) -> String {
  if sheen > 0.0 {
    match sheen_roughness_map {
      None => ""
      Some(_) => "#define USE_SHEEN_ROUGHNESSMAP\n"
    }
  } else {
    ""
  }
}

///|
fn use_sheen_line(sheen : Double) -> String {
  if sheen > 0.0 {
    "#define USE_SHEEN\n"
  } else {
    ""
  }
}

///|
fn use_sheen_colormap_line(
  sheen : Double,
  sheen_color_map : @textures.Texture?,
) -> String {
  if sheen > 0.0 {
    match sheen_color_map {
      None => ""
      Some(_) => "#define USE_SHEEN_COLORMAP\n"
    }
  } else {
    ""
  }
}

///|
fn use_thicknessmap_line(
  transmission : Double,
  thickness_map : @textures.Texture?,
) -> String {
  if transmission > 0.0 {
    match thickness_map {
      None => ""
      Some(_) => "#define USE_THICKNESSMAP\n"
    }
  } else {
    ""
  }
}

///|
fn use_transmissionmap_line(
  transmission : Double,
  transmission_map : @textures.Texture?,
) -> String {
  if transmission > 0.0 {
    match transmission_map {
      None => ""
      Some(_) => "#define USE_TRANSMISSIONMAP\n"
    }
  } else {
    ""
  }
}

///|
fn use_transmission_line(transmission : Double) -> String {
  if transmission > 0.0 {
    "#define USE_TRANSMISSION\n"
  } else {
    ""
  }
}

///|
fn use_alphatest_line(alpha_test : Double) -> String {
  if alpha_test > 0.0 {
    "#define USE_ALPHATEST\n"
  } else {
    ""
  }
}

///|
fn use_alphahash_line(alpha_hash : Bool) -> String {
  if alpha_hash {
    "#define USE_ALPHAHASH\n"
  } else {
    ""
  }
}

///|
fn use_alphamap_line(alpha_map : @textures.Texture?) -> String {
  match alpha_map {
    None => ""
    Some(_) => "#define USE_ALPHAMAP\n"
  }
}

///|
fn use_metalnessmap_line(metalness_map : @textures.Texture?) -> String {
  match metalness_map {
    None => ""
    Some(_) => "#define USE_METALNESSMAP\n"
  }
}

///|
fn use_roughnessmap_line(roughness_map : @textures.Texture?) -> String {
  match roughness_map {
    None => ""
    Some(_) => "#define USE_ROUGHNESSMAP\n"
  }
}

///|
fn use_specular_intensitymap_line(
  specular_intensity_map : @textures.Texture?,
) -> String {
  match specular_intensity_map {
    None => ""
    Some(_) => "#define USE_SPECULAR_INTENSITYMAP\n"
  }
}

///|
fn use_specular_colormap_line(specular_color_map : @textures.Texture?) -> String {
  match specular_color_map {
    None => ""
    Some(_) => "#define USE_SPECULAR_COLORMAP\n"
  }
}

///|
fn use_specularmap_line(specular_map : @textures.Texture?) -> String {
  match specular_map {
    None => ""
    Some(_) => "#define USE_SPECULARMAP\n"
  }
}

///|
fn use_iridescence_thicknessmap_line(
  iridescence : Double,
  iridescence_thickness_map : @textures.Texture?,
) -> String {
  if iridescence > 0.0 {
    match iridescence_thickness_map {
      None => ""
      Some(_) => "#define USE_IRIDESCENCE_THICKNESSMAP\n"
    }
  } else {
    ""
  }
}

///|
fn use_iridescencemap_line(
  iridescence : Double,
  iridescence_map : @textures.Texture?,
) -> String {
  if iridescence > 0.0 {
    match iridescence_map {
      None => ""
      Some(_) => "#define USE_IRIDESCENCEMAP\n"
    }
  } else {
    ""
  }
}

///|
fn use_clearcoat_normalmap_line(
  clearcoat : Double,
  clearcoat_normal_map : @textures.Texture?,
) -> String {
  if clearcoat > 0.0 {
    match clearcoat_normal_map {
      None => ""
      Some(_) => "#define USE_CLEARCOAT_NORMALMAP\n"
    }
  } else {
    ""
  }
}

///|
fn use_clearcoat_roughnessmap_line(
  clearcoat : Double,
  clearcoat_roughness_map : @textures.Texture?,
) -> String {
  if clearcoat > 0.0 {
    match clearcoat_roughness_map {
      None => ""
      Some(_) => "#define USE_CLEARCOAT_ROUGHNESSMAP\n"
    }
  } else {
    ""
  }
}

///|
fn use_clearcoatmap_line(
  clearcoat : Double,
  clearcoat_map : @textures.Texture?,
) -> String {
  if clearcoat > 0.0 {
    match clearcoat_map {
      None => ""
      Some(_) => "#define USE_CLEARCOATMAP\n"
    }
  } else {
    ""
  }
}

///|
fn use_dispersion_line(dispersion : Double) -> String {
  if dispersion > 0.0 {
    "#define USE_DISPERSION\n"
  } else {
    ""
  }
}

///|
fn use_retroreflection_line(retroreflectivity : Double) -> String {
  if retroreflectivity > 0.0 {
    "#define USE_RETROREFLECTION\n"
  } else {
    ""
  }
}

///|
fn use_iridescence_line(iridescence : Double) -> String {
  if iridescence > 0.0 {
    "#define USE_IRIDESCENCE\n"
  } else {
    ""
  }
}

///|
fn use_clearcoat_line(clearcoat : Double) -> String {
  if clearcoat > 0.0 {
    "#define USE_CLEARCOAT\n"
  } else {
    ""
  }
}

///|
fn use_anisotropymap_line(
  anisotropy : Double,
  anisotropy_map : @textures.Texture?,
) -> String {
  if anisotropy > 0.0 {
    match anisotropy_map {
      None => ""
      Some(_) => "#define USE_ANISOTROPYMAP\n"
    }
  } else {
    ""
  }
}

///|
fn use_anisotropy_line(anisotropy : Double) -> String {
  if anisotropy > 0.0 {
    "#define USE_ANISOTROPY\n"
  } else {
    ""
  }
}

///|
fn use_packed_normalmap_line(packed_normal_map : Bool) -> String {
  if packed_normal_map {
    "#define USE_PACKED_NORMALMAP\n"
  } else {
    ""
  }
}

///|
fn use_emissivemap_line(emissive_map : @textures.Texture?) -> String {
  match emissive_map {
    None => ""
    Some(_) => "#define USE_EMISSIVEMAP\n"
  }
}

///|
fn use_displacementmap_line(displacement_map : @textures.Texture?) -> String {
  match displacement_map {
    None => ""
    Some(_) => "#define USE_DISPLACEMENTMAP\n"
  }
}

///|
fn use_normalmap_line(normal_map : @textures.Texture?) -> String {
  match normal_map {
    None => ""
    Some(_) => "#define USE_NORMALMAP\n"
  }
}

///|
fn use_bumpmap_line(bump_map : @textures.Texture?) -> String {
  match bump_map {
    None => ""
    Some(_) => "#define USE_BUMPMAP\n"
  }
}

///|
fn use_aomap_line(ao_map : @textures.Texture?) -> String {
  match ao_map {
    None => ""
    Some(_) => "#define USE_AOMAP\n"
  }
}

///|
fn use_lightmap_line(light_map : @textures.Texture?) -> String {
  match light_map {
    None => ""
    Some(_) => "#define USE_LIGHTMAP\n"
  }
}

///|
fn use_clip_distance_line(
  has_clip_cull_distance : Bool,
  clip_cull_distance : Bool,
) -> String {
  if has_clip_cull_distance && clip_cull_distance {
    "#define USE_CLIP_DISTANCE\n"
  } else {
    ""
  }
}

///|
fn use_batching_line(batching : Bool) -> String {
  if batching {
    "#define USE_BATCHING\n"
  } else {
    ""
  }
}

///|
fn use_batching_color_line(batching_color : Bool) -> String {
  if batching_color {
    "#define USE_BATCHING_COLOR\n"
  } else {
    ""
  }
}

///|
fn use_instancing_line(instancing : Bool) -> String {
  if instancing {
    "#define USE_INSTANCING\n"
  } else {
    ""
  }
}

///|
fn use_instancing_color_line(instancing_color : Bool) -> String {
  if instancing_color {
    "#define USE_INSTANCING_COLOR\n"
  } else {
    ""
  }
}

///|
fn use_instancing_morph_line(instancing_morph : Bool) -> String {
  if instancing_morph {
    "#define USE_INSTANCING_MORPH\n"
  } else {
    ""
  }
}

///|
fn use_fog_line(has_fog : Bool, use_fog : Bool) -> String {
  if has_fog && use_fog {
    "#define USE_FOG\n"
  } else {
    ""
  }
}

///|
fn fog_exp2_line(use_fog : Bool, fog_exp2 : Bool) -> String {
  if use_fog && fog_exp2 {
    "#define FOG_EXP2\n"
  } else {
    ""
  }
}

///|
fn alpha_to_coverage_line(alpha_to_coverage : Bool) -> String {
  if alpha_to_coverage {
    "#define ALPHA_TO_COVERAGE\n"
  } else {
    ""
  }
}

///|
fn use_map_line(map : @textures.Texture?) -> String {
  match map {
    None => ""
    Some(_) => "#define USE_MAP\n"
  }
}

///|
fn use_matcap_line(matcap : @textures.Texture?) -> String {
  match matcap {
    None => ""
    Some(_) => "#define USE_MATCAP\n"
  }
}

///|
fn floor_log2(value : Int) -> Int {
  let mut n = value
  let mut result = 0
  while n > 1 {
    n = n / 2
    result = result + 1
  }
  result
}

///|
fn cubeuv_texel_width(image_height : Int) -> Double {
  let max_mip = floor_log2(image_height) - 2
  let mut pow_mip = 1
  let mut index = 0
  while index < max_mip {
    pow_mip = pow_mip * 2
    index = index + 1
  }
  let span = if pow_mip > 112 { pow_mip } else { 112 }
  1.0 / (3.0 * span.to_double())
}

///|
fn cubeuv_texel_width_line(image_height : Int?) -> String {
  match image_height {
    None => ""
    Some(height) =>
      if height < 1 {
        ""
      } else {
        "#define CUBEUV_TEXEL_WIDTH " +
        cubeuv_texel_width(height).to_string() +
        "\n"
      }
  }
}

///|
fn cubeuv_texel_height_line(image_height : Int?) -> String {
  match image_height {
    None => ""
    Some(height) =>
      if height < 1 {
        ""
      } else {
        "#define CUBEUV_TEXEL_HEIGHT " + (1.0 / height.to_double()).to_string() + "\n"
      }
  }
}

///|
fn cubeuv_max_mip_line(image_height : Int?) -> String {
  match image_height {
    None => ""
    Some(height) =>
      if height < 1 {
        ""
      } else {
        let max_mip = floor_log2(height) - 2
        "#define CUBEUV_MAX_MIP " + max_mip.to_string() + ".0\n"
      }
  }
}

///|
fn use_envmap_line(env_map : @textures.Texture?) -> String {
  match env_map {
    None => ""
    Some(_) => "#define USE_ENVMAP\n"
  }
}

///|
fn envmap_type_line(env_map : @textures.Texture?) -> String {
  match env_map {
    None => ""
    Some(_) => "#define ENVMAP_TYPE_CUBE\n"
  }
}

///|
fn envmap_blending_line(
  env_map : @textures.Texture?,
  combine : @constants.Combine,
) -> String {
  match env_map {
    None => ""
    Some(_) =>
      match combine {
        Multiply => "#define ENVMAP_BLENDING_MULTIPLY\n"
        Mix => "#define ENVMAP_BLENDING_MIX\n"
        Add => "#define ENVMAP_BLENDING_ADD\n"
      }
  }
}

///|
fn envmap_mode_line(env_map : @textures.Texture?) -> String {
  match env_map {
    None => ""
    Some(_) => "#define ENVMAP_MODE_REFLECTION\n"
  }
}

///|
fn custom_define_lines(defines : Map[String, String]) -> String {
  let mut text = ""
  let mut first = true
  for pair in defines.iter() {
    let (key, value) = pair
    if first {
      first = false
    } else {
      text = text + "\n"
    }
    text = text + "#define " + key + " " + value
  }
  if text.length() == 0 {
    ""
  } else {
    text + "\n"
  }
}

///|
fn shader_version_line() -> String {
  "#version 300 es\n"
}

///|
/// 片元着色器前面的版本行、GLSL3 改写和内置 uniform。Shader 以 `#version 300 es` 开头，这 16 个字符不看 `glsl_version`。空的 `glsl_version` 与 `GLSL1` 接着写 `464` 个字符的宏，其中有 `layout(location = 0)` 和 `gl_FragColor`。`GLSL3` 这两行留空，宏段变成 `382`。接着是长 `543` 的精度声明、长 `35` 的 `#define SHADER_TYPE ShaderMaterial`、空名字时长 `21` 的 `#define SHADER_NAME` 和长 `82` 的 uniform。Raw 和其它材质原样返回 `fragment_shader`。表里的每个键写成 `#define 键 值`。空表不加字符。场景有雾且材质 `fog` 打开时再写 `#define USE_FOG`，连换行长 `16`。缺一项不加。材质 `fog` 打开且场景雾是指数雾时再写 `#define FOG_EXP2`，连换行长 `17`。普通雾不加这行。`alpha_to_coverage` 打开时再写 `#define ALPHA_TO_COVERAGE`，连换行长 `26`。这行只在片元前缀。有颜色贴图时再写 `#define USE_MAP`，连换行长 `16`。没有贴图不加。有 matcap 贴图时再写 `#define USE_MATCAP`，连换行长 `19`。没有这张贴图不加。这行只在片元前缀。有环境贴图时再写 `#define USE_ENVMAP`，连换行长 `19`，接着写 `#define ENVMAP_TYPE_CUBE`，连换行长 `25`，再写 `#define ENVMAP_MODE_REFLECTION`，连换行长 `31`，然后按 `combine` 写混合。相乘是 `#define ENVMAP_BLENDING_MULTIPLY`，连换行长 `33`。调用方给出立方 UV 高度时再写 `#define CUBEUV_TEXEL_WIDTH` 和算出来的宽度。高度 `256` 的宽度是 `0.002976190476190476`，连换行长 `48`。没有高度不加。同一高度再写 `#define CUBEUV_TEXEL_HEIGHT`，高度 `256` 是 `0.00390625`，连换行长 `39`。再写 `#define CUBEUV_MAX_MIP`，高度 `256` 是 `6.0`，连换行长 `27`。`USE_CLIP_DISTANCE` 仍不写。这三行只在片元前缀。混合与相加是 `ENVMAP_BLENDING_MIX` 和 `ENVMAP_BLENDING_ADD`，连换行都长 `28`。贴图还没有 mapping，所以类型固定是立方体、模式固定是反射。没有环境贴图这四行都不加。有光照贴图时再写 `#define USE_LIGHTMAP`，连换行长 `21`。没有光照贴图不加。有环境光遮蔽贴图时再写 `#define USE_AOMAP`，连换行长 `18`。没有环境光遮蔽贴图不加。有凹凸贴图时再写 `#define USE_BUMPMAP`，连换行长 `20`。没有凹凸贴图不加。有法线贴图时再写 `#define USE_NORMALMAP`，连换行长 `22`。物体空间再写 `#define USE_NORMALMAP_OBJECTSPACE`，连换行长 `34`。切线空间再写 `#define USE_NORMALMAP_TANGENTSPACE`，连换行长 `35`。两种类型只写其中一行。没有法线贴图这三行都不加。切线空间的法线贴图格式是打包 RG 时再写 `#define USE_PACKED_NORMALMAP`，连换行长 `29`。物体空间、没有贴图或其它格式不加。这行只在片元前缀。`dispersion` 大于 `0` 时再写 `#define USE_DISPERSION`，连换行长 `23`。等于 `0` 或小于 `0` 不加。这行只在片元前缀。`retroreflectivity` 大于 `0` 时再写 `#define USE_RETROREFLECTION`，连换行长 `28`。等于 `0` 或小于 `0` 不加。这行只在片元前缀。`iridescence` 大于 `0` 时再写 `#define USE_IRIDESCENCE`，连换行长 `24`。等于 `0` 或小于 `0` 不加。这行只在片元前缀。`alpha_test` 大于 `0` 时再写 `#define USE_ALPHATEST`，连换行长 `22`。等于 `0` 或小于 `0` 不加。这行只在片元前缀。`sheen` 大于 `0` 时再写 `#define USE_SHEEN`，连换行长 `18`。等于 `0` 或小于 `0` 不加。这行只在片元前缀。调用方标明实例颜色时再写 `#define USE_COLOR`，连换行长 `18`。顶点色已经打开时不重复。顶点前缀的 `USE_COLOR` 仍只看 `vertex_colors`。调用方标明合批颜色时再写 `#define USE_COLOR_ALPHA`，连换行长 `24`。顶点色已经带 alpha 时不重复。顶点前缀的 `USE_COLOR_ALPHA` 仍只看顶点色。Lambert、Phong、Standard、Physical 没有法线、没有法线贴图且不是线框时，片元字符串写 `#define FLAT_SHADED`，连换行长 `20`，正文仍是空串。有法线、有法线贴图或线框不加。缺法线时不写 `USE_TANGENT`。有法线且各向异性大于 `0` 时写这行，连换行长 `20`。缺法线时不写 `USE_MORPHNORMALS`。有法线时顶点前缀写这行，连换行长 `25`，片元前缀不加。光照材质打开 `flat_shading` 且不是线框时写 `#define FLAT_SHADED`，连换行长 `20`。Basic 不加。内置前缀有法线时写 `#define HAS_NORMAL`，连换行长 `19`，片元前缀不加。内置前缀的 `USE_COLOR` 仍不写。有自发光贴图时再写 `#define USE_EMISSIVEMAP`，连换行长 `24`。没有自发光贴图不加。各向异性大于 `0` 时再写 `#define USE_ANISOTROPY`，连换行长 `23`。等于 `0` 或小于 `0` 不加。大于 `0` 且有各向异性贴图时再写 `#define USE_ANISOTROPYMAP`，连换行长 `26`。没有贴图或各向异性不大于 `0` 不加。`clearcoat` 大于 `0` 时再写 `#define USE_CLEARCOAT`，连换行长 `22`。大于 `0` 且有清漆贴图时再写 `#define USE_CLEARCOATMAP`，连换行长 `25`。大于 `0` 且有清漆粗糙度贴图时再写 `#define USE_CLEARCOAT_ROUGHNESSMAP`，连换行长 `35`。大于 `0` 且有清漆法线贴图时再写 `#define USE_CLEARCOAT_NORMALMAP`，连换行长 `32`。等于 `0` 或小于 `0` 这些行都不加。顶点字符串只在有对应贴图且清漆大于 `0` 时写这三行贴图宏。彩虹大于 `0` 且有彩虹贴图时再写 `#define USE_IRIDESCENCEMAP`，连换行长 `27`。彩虹不大于 `0` 或不挂贴图不加。彩虹大于 `0` 且有厚度贴图时再写 `#define USE_IRIDESCENCE_THICKNESSMAP`，连换行长 `37`。没有厚度贴图不加。有高光贴图时再写 `#define USE_SPECULARMAP`，连换行长 `24`。没有高光贴图不加。有高光颜色贴图时再写 `#define USE_SPECULAR_COLORMAP`，连换行长 `30`。没有高光颜色贴图不加。有高光强度贴图时再写 `#define USE_SPECULAR_INTENSITYMAP`，连换行长 `34`。没有高光强度贴图不加。有粗糙度贴图时再写 `#define USE_ROUGHNESSMAP`，连换行长 `25`。没有粗糙度贴图不加。有金属度贴图时再写 `#define USE_METALNESSMAP`，连换行长 `25`。没有金属度贴图不加。有透明贴图时再写 `#define USE_ALPHAMAP`，连换行长 `21`。没有透明贴图不加。`alpha_hash` 打开时再写 `#define USE_ALPHAHASH`，连换行长 `22`。关闭不加。`transmission` 大于 `0` 时再写 `#define USE_TRANSMISSION`，连换行长 `25`。等于 `0` 或小于 `0` 不加。大于 `0` 且有透射贴图时再写 `#define USE_TRANSMISSIONMAP`，连换行长 `28`。没有贴图或透射不大于 `0` 不加。大于 `0` 且有厚度贴图时再写 `#define USE_THICKNESSMAP`，连换行长 `25`。没有厚度贴图不加。`sheen` 大于 `0` 且有光泽颜色贴图时，片元字符串在透射宏前面写 `#define USE_SHEEN_COLORMAP`，连换行长 `27`。大于 `0` 且有光泽粗糙度贴图时再写 `#define USE_SHEEN_ROUGHNESSMAP`，连换行长 `31`。`sheen` 不大于 `0` 或不挂对应贴图不加。几何带切线，并且有法线贴图或各向异性大于 `0`，而且平坦着色参数为假时，片元字符串在这些宏后面再写 `#define USE_TANGENT`，连换行长 `20`。`flat_shading` 打开且 `wireframe` 关闭时该参数为真，不加。没有切线、没有法线贴图且各向异性不大于 `0` 不加。缺法线时不写 `USE_TANGENT`。有法线且各向异性大于 `0` 时写这行，连换行长 `20`。缺法线时不写 `USE_MORPHNORMALS`。有法线时顶点前缀写这行，连换行长 `25`，片元前缀不加。光照材质打开 `flat_shading` 且不是线框时写 `#define FLAT_SHADED`，连换行长 `20`。Basic 不加。内置前缀有法线时写 `#define HAS_NORMAL`，连换行长 `19`，片元前缀不加。内置前缀的 `USE_COLOR` 仍不写。`vertex_colors` 打开或调用方标明实例颜色时，片元字符串再写 `#define USE_COLOR`，连换行长 `18`。两者都关不加，顶点色已经打开时不重复。`vertex_colors` 打开且颜色属性是四维，或调用方标明合批颜色时，片元字符串再写 `#define USE_COLOR_ALPHA`，连换行长 `24`。两者都不成立不加，顶点色已经带 alpha 时不重复。Lambert、Phong、Standard、Physical 没有法线也没有法线贴图时，片元字符串写 `#define FLAT_SHADED`，连换行长 `20`。有贴图通道 `1` 时，片元字符串再写 `#define USE_UV1`，连换行长 `16`。通道 `0` 或其他通道不加。有贴图通道 `2` 时，片元字符串再写 `#define USE_UV2`，连换行长 `16`。通道 `0`、`1` 或其他通道不加。有贴图通道 `3` 时，片元字符串再写 `#define USE_UV3`，连换行长 `16`。通道 `0`、`1`、`2` 或其他通道不加。点对象带 `uv`，并且有颜色贴图或透明贴图时，片元字符串再写 `#define USE_POINTS_UV`，连换行长 `22`。没有这个标记，或两种贴图都没有，不加。`gradient_map` 有贴图时，片元字符串再写 `#define USE_GRADIENTMAP`，连换行长 `24`。空贴图不加。顶点字符串不加。`flat_shading` 打开且 `wireframe` 关闭时，片元字符串再写 `#define FLAT_SHADED`，连换行长 `20`。`wireframe` 打开或平坦着色关闭不加。Lambert、Phong、Standard、Physical 没有法线也没有法线贴图时同样写这行，连换行长 `20`，正文仍是空串。有法线、有法线贴图或线框不加。缺法线时不写 `USE_TANGENT`。有法线且各向异性大于 `0` 时写这行，连换行长 `20`。缺法线时不写 `USE_MORPHNORMALS`。有法线时顶点前缀写这行，连换行长 `25`，片元前缀不加。光照材质打开 `flat_shading` 且不是线框时写 `#define FLAT_SHADED`，连换行长 `20`。Basic 不加。内置前缀有法线时写 `#define HAS_NORMAL`，连换行长 `19`，片元前缀不加。内置前缀的 `USE_COLOR` 仍不写。`side` 为双面时，片元字符串再写 `#define DOUBLE_SIDED`，连换行长 `21`。正面或背面不加。`side` 为背面时，片元字符串再写 `#define FLIP_SIDED`，连换行长 `19`。正面或双面不加。阴影贴图打开时，片元字符串再写 `#define USE_SHADOWMAP`，连换行长 `22`。关闭不加。阴影贴图打开时，片元字符串再写 `#define SHADOWMAP_TYPE_BASIC`，连换行长 `29`。关闭不加。PCF 阴影时，片元字符串改写 `#define SHADOWMAP_TYPE_PCF`，连换行长 `27`，不再写 `SHADOWMAP_TYPE_BASIC`。阴影贴图关闭仍不加。VSM 阴影时，片元字符串改写 `#define SHADOWMAP_TYPE_VSM`，连换行长 `27`，不再写 `SHADOWMAP_TYPE_BASIC` 或 `SHADOWMAP_TYPE_PCF`。阴影贴图关闭仍不加。`premultiplied_alpha` 打开时，片元字符串再写 `#define PREMULTIPLIED_ALPHA`，连换行长 `28`。关闭不加。顶点字符串不加。光照探针数量大于 `0` 时，片元字符串再写 `#define USE_LIGHT_PROBES`，连换行长 `25`。数量不大于 `0` 不加。光照探针网格数量大于 `0` 时，片元字符串再写 `#define USE_LIGHT_PROBES_GRID`，连换行长 `30`。数量不大于 `0` 不加。顶点字符串不加。`decode_video_texture` 打开时，片元字符串再写 `#define DECODE_VIDEO_TEXTURE`，连换行长 `29`。关闭不加。顶点字符串不加。`decode_video_texture_emissive` 打开时，片元字符串再写 `#define DECODE_VIDEO_TEXTURE_EMISSIVE`，连换行长 `38`。关闭不加。顶点字符串不加。对数深度打开时，片元字符串再写 `#define USE_LOGARITHMIC_DEPTH_BUFFER`，连换行长 `37`。关闭不加。反向深度打开时，片元字符串再写 `#define USE_REVERSED_DEPTH_BUFFER`，连换行长 `34`。关闭不加。`tone_mapping` 不是 `No` 时，片元字符串在内置 uniform 后面先补一个换行，再写 `#define TONE_MAPPING` 和换行，一共长 `22`，接着写入 `tonemapping_pars_fragment`。这块以换行开头、以换行结束，长 `5231`。两段合在一起长 `5253`。`No` 不加。顶点字符串不加。其它取值在 `tonemapping_pars_fragment` 后面先补一个换行，再写 `getToneMappingFunction` 生成的那一行和换行。`Linear` 写成 `vec3 toneMapping( vec3 color ) { return LinearToneMapping( color ); }`，这一行长 `69`，连前后换行长 `71`，片元字符串变成 `6546`。`Reinhard` 这一行长 `71`，`Cineon` 长 `69`，`ACES` 写成 `ACESFilmic` 长 `73`，`AgX` 长 `66`，`Neutral` 长 `70`。顶点字符串不加。`dithering` 打开时，片元字符串再写 `#define DITHERING`。`tone_mapping` 为 `No` 时，这一行前面补一个换行，连结尾换行一共长 `19`，片元字符串从 `1222` 变成 `1241`。`tone_mapping` 不是 `No` 时，色调映射函数那一行已经以换行结束，所以只再写宏和换行，长 `18`。`Linear` 时片元字符串变成 `6564`。关闭不加。顶点字符串不加。默认着色器材质不透明、混合是 `Normal`、`alpha_to_coverage` 关闭，片元字符串再写 `#define OPAQUE`。前面没有别的行时先补一个换行，连结尾换行一共长 `16`，片元字符串从 `1222` 变成 `1238`。`transparent` 打开、混合不是 `Normal`、或 `alpha_to_coverage` 打开时不加。`dithering` 或色调映射已经以换行结束时，只再写宏和换行，长 `15`。顶点字符串不加。非 Raw 的 Shader 接着写入 `colorspace_pars_fragment`。这块以两个换行开头、以换行结束，长 `496`。默认不透明时片元字符串从 `1238` 变成 `1734`。`transparent` 打开、混合不是 `Normal`、或 `alpha_to_coverage` 打开，并且没有 `dithering`、色调映射是 `No` 时，前面再补一个换行，片元字符串从 `1222` 变成 `1719`。顶点字符串不加。`getTexelEncodingFunction` 接在颜色空间块后面。默认 `output_srgb` 为真，写入 `vec4 linearToOutputTexel`，中间调用 `sRGBTransferOETF`，函数正文长 `179`，连前后换行长 `181`，片元字符串从 `1734` 变成 `1915`。`output_srgb` 为假时改叫 `LinearTransferOETF`，正文长 `181`，连前后换行长 `183`，片元字符串是 `1917`。顶点字符串不加。`getLuminanceFunction` 接在 `linearToOutputTexel` 后面。函数正文长 `123`，连前后换行长 `125`，片元字符串从 `1915` 变成 `2040`。权重是 `0.2126`、`0.7152`、`0.0722`。顶点字符串不加。`depth_packing` 小于 `0` 时不加。大于等于 `0` 时，片元字符串再写 `#define DEPTH_PACKING` 和这个整数。`3200` 连换行长 `27`，片元字符串从 `2040` 变成 `2067`。`0` 连换行长 `24`，片元字符串是 `2064`。顶点字符串不加。`prefixFragment` 末尾再写一个换行。默认片元字符串从 `2040` 变成 `2041`。`depth_packing` 为 `3200` 时从 `2067` 变成 `2068`。顶点字符串不加。`getUniforms` 按材质类型另取 uniform，不写进这两段前缀。`acquireProgram` 按缓存键另记引用次数，不写进这两段前缀。`releaseProgram` 按引用次数另从缓存移除，不写进这两段前缀。`releaseShaderCache` 按材质编号另放开着色器阶段，不写进这两段前缀。`dispose` 另清空着色器缓存，不写进这两段前缀。`getVertexShaderStage` 按顶点源码另取阶段，不写进这两段前缀。`getFragmentShaderStage` 按片元源码另取阶段，不写进这两段前缀。`customVertexShaderID` 另记自定义顶点阶段编号，不写进这两段前缀。`customFragmentShaderID` 另记自定义片元阶段编号，不写进这两段前缀。`shaderType` 另读材质类型名，不写进这两段前缀。`shaderName` 另读材质名字，不写进这两段前缀。`vertexShader` 另读自定义顶点源码，不写进这两段前缀。`fragmentShader` 另读自定义片元源码，不写进这两段前缀。`defines` 另读材质宏表，不写进这两段前缀。`isRawShaderMaterial` 另读 Raw 标记，不写进这两段前缀。`glslVersion` 另读 GLSL 版本，不写进这两段前缀。`precision` 另读精度参数，不写进这两段前缀。`getMaxPrecision` 另按浮点能力选精度，不写进这两段前缀。`batching` 另读合批标记，不写进这两段前缀。`batchingColor` 另读合批颜色，不写进这两段前缀。`instancing` 另读实例化标记，不写进这两段前缀。`instancingColor` 另读实例颜色，不写进这两段前缀。`instancingMorph` 另读实例形变，不写进这两段前缀。`outputColorSpace` 另选输出颜色空间，不写进这两段前缀。`alphaToCoverage` 另读这个开关，不写进这两段前缀。`map` 另读颜色贴图标记，不写进这两段前缀。`matcap` 另读 matcap 标记，不写进这两段前缀。`envMap` 另读环境贴图标记，不写进这两段前缀。`envMapMode` 另读环境贴图模式，不写进这两段前缀。`envMapCubeUVHeight` 另读立方 UV 高度，不写进这两段前缀。`aoMap` 另读环境光遮蔽贴图标记，不写进这两段前缀。`lightMap` 另读光照贴图标记，不写进这两段前缀。`bumpMap` 另读凹凸贴图标记，不写进这两段前缀。`normalMap` 另读法线贴图标记，不写进这两段前缀。`normalMapObjectSpace` 另读物体空间法线贴图标记，不写进这两段前缀。`normalMapTangentSpace` 另读切线空间法线贴图标记，不写进这两段前缀。`packedNormalMap` 另读打包法线贴图标记，不写进这两段前缀。`displacementMap` 另读位移贴图标记，不写进这两段前缀。`emissiveMap` 另读自发光贴图标记，不写进这两段前缀。`metalnessMap` 另读金属度贴图标记，不写进这两段前缀。`roughnessMap` 另读粗糙度贴图标记，不写进这两段前缀。`anisotropy` 另读各向异性标记，不写进这两段前缀。`anisotropyMap` 另读各向异性贴图标记，不写进这两段前缀。`clearcoat` 另读清漆标记，不写进这两段前缀。`clearcoatMap` 另读清漆贴图标记，不写进这两段前缀。`clearcoatNormalMap` 另读清漆法线贴图标记，不写进这两段前缀。`clearcoatRoughnessMap` 另读清漆粗糙度贴图标记，不写进这两段前缀。`dispersion` 另读色散标记，不写进这两段前缀。`retroreflection` 另读逆反射标记，不写进这两段前缀。`iridescence` 另读彩虹标记，不写进这两段前缀。`iridescenceMap` 另读彩虹贴图标记，不写进这两段前缀。`iridescenceThicknessMap` 另读彩虹厚度贴图标记，不写进这两段前缀。`sheen` 另读光泽标记，不写进这两段前缀。`sheenColorMap` 另读光泽颜色贴图标记，不写进这两段前缀。`sheenRoughnessMap` 另读光泽粗糙度贴图标记，不写进这两段前缀。`specularMap` 另读高光贴图标记，不写进这两段前缀。`specularColorMap` 另读高光颜色贴图标记，不写进这两段前缀。`specularIntensityMap` 另读高光强度贴图标记，不写进这两段前缀。`transmission` 另读透射标记，不写进这两段前缀。`transmissionMap` 另读透射贴图标记，不写进这两段前缀。`thicknessMap` 另读厚度贴图标记，不写进这两段前缀。`gradientMap` 另读渐变贴图标记，不写进这两段前缀。`opaque` 另读不透明标记，不写进这两段前缀。`alphaMap` 另读透明贴图标记，不写进这两段前缀。`alphaTest` 另读 alpha 测试标记，不写进这两段前缀。`alphaHash` 另读 alpha 散列标记，不写进这两段前缀。`combine` 另读环境贴图合成方式，不写进这两段前缀。`mapUv` 另读颜色贴图 UV 通道，不写进这两段前缀。`aoMapUv` 另读环境光遮蔽贴图 UV 通道，不写进这两段前缀。`lightMapUv` 另读光照贴图 UV 通道，不写进这两段前缀。`bumpMapUv` 另读凹凸贴图 UV 通道，不写进这两段前缀。`normalMapUv` 另读法线贴图 UV 通道，不写进这两段前缀。`displacementMapUv` 另读位移贴图 UV 通道，不写进这两段前缀。`emissiveMapUv` 另读自发光贴图 UV 通道，不写进这两段前缀。`metalnessMapUv` 另读金属度贴图 UV 通道，不写进这两段前缀。`roughnessMapUv` 另读粗糙度贴图 UV 通道，不写进这两段前缀。`anisotropyMapUv` 另读各向异性贴图 UV 通道，不写进这两段前缀。`clearcoatMapUv` 另读清漆贴图 UV 通道，不写进这两段前缀。`clearcoatNormalMapUv` 另读清漆法线贴图 UV 通道，不写进这两段前缀。`clearcoatRoughnessMapUv` 另读清漆粗糙度贴图 UV 通道，不写进这两段前缀。`iridescenceMapUv` 另读彩虹色贴图 UV 通道，不写进这两段前缀。`iridescenceThicknessMapUv` 另读彩虹色厚度贴图 UV 通道，不写进这两段前缀。`sheenColorMapUv` 另读光泽颜色贴图 UV 通道，不写进这两段前缀。`sheenRoughnessMapUv` 另读光泽粗糙度贴图 UV 通道，不写进这两段前缀。`specularMapUv` 另读高光贴图 UV 通道，不写进这两段前缀。`specularColorMapUv` 另读高光颜色贴图 UV 通道，不写进这两段前缀。`specularIntensityMapUv` 另读高光强度贴图 UV 通道，不写进这两段前缀。`transmissionMapUv` 另读透射贴图 UV 通道，不写进这两段前缀。`thicknessMapUv` 另读厚度贴图 UV 通道，不写进这两段前缀。`alphaMapUv` 另读透明贴图 UV 通道，不写进这两段前缀。`vertexTangents` 另读几何体切线，不写进这两段前缀。`vertexNormals` 另读几何体法线，不写进这两段前缀。`vertexColors` 另读材质的顶点色开关，不写进这两段前缀。`vertexAlphas` 另读顶点色的第四分量，不写进这两段前缀。`pointsUvs` 另读点的 UV，不写进这两段前缀。`fog` 另读场景有没有雾，不写进这两段前缀。`useFog` 另读材质雾开关，不写进这两段前缀。`fogExp2` 另读场景雾是不是指数雾，不写进这两段前缀。`flatShading` 另读平直着色，不写进这两段前缀。`sizeAttenuation` 另读点大小是否随距离缩小，不写进这两段前缀。`logarithmicDepthBuffer` 另读渲染器的对数深度缓冲，不写进这两段前缀。`reversedDepthBuffer` 另读渲染器的反向深度缓冲，不写进这两段前缀。`skinning` 另读对象是不是骨骼网格，不写进这两段前缀。`hasPositionAttribute` 另读几何体有没有位置属性，不写进这两段前缀。`morphTargets` 另读几何体有没有位置变形，不写进这两段前缀。`morphNormals` 另读几何体有没有法线变形，不写进这两段前缀。`morphColors` 另读几何体有没有颜色变形，不写进这两段前缀。`morphTargetsCount` 另读变形目标数量，不写进这两段前缀。`morphTextureStride` 另读变形纹理步长，不写进这两段前缀。`numSunLights` 另读太阳光数量，不写进这两段前缀。`numDirLights` 另读平行光数量，不写进这两段前缀。`numPointLights` 另读点光源数量，不写进这两段前缀。`numSpotLights` 另读聚光灯数量，不写进这两段前缀。`numSpotLightMaps` 另读带贴图的聚光灯数量，不写进这两段前缀。`numRectAreaLights` 另读矩形面光源数量，不写进这两段前缀。`numHemiLights` 另读半球光数量，不写进这两段前缀。`numSunLightShadows` 另读太阳光阴影数量，不写进这两段前缀。`numDirLightShadows` 另读平行光阴影数量，不写进这两段前缀。`numPointLightShadows` 另读点光源阴影数量，不写进这两段前缀。`numSpotLightShadows` 另读聚光灯阴影数量，不写进这两段前缀。`numSpotLightShadowsWithMaps` 另读带贴图的聚光灯阴影数量，不写进这两段前缀。`numLightProbes` 另读光照探针数量，不写进这两段前缀。`numLightProbeGrids` 另读光照探针网格数量，不写进这两段前缀。`numClippingPlanes` 另读裁剪平面数量，不写进这两段前缀。`numClipIntersection` 另读裁剪交集数量，不写进这两段前缀。`dithering` 另读材质抖动开关，不写进这两段前缀。`shadowMapEnabled` 另读阴影贴图是否启用，不写进这两段前缀。`shadowMapType` 另读渲染器阴影贴图类型，不写进这两段前缀。`toneMapping` 另读色调映射，不写进这两段前缀。`decodeVideoTexture` 另读视频贴图解码，不写进这两段前缀。`decodeVideoTextureEmissive` 另读自发光视频贴图解码，不写进这两段前缀。`premultipliedAlpha` 另读预乘透明度，不写进这两段前缀。`doubleSided` 另读双面标记，不写进这两段前缀。`flipSided` 另读背面标记，不写进这两段前缀。`useDepthPacking` 另读深度打包开关，不写进这两段前缀。`depthPacking` 另读深度打包整数，不写进这两段前缀。`index0AttributeName` 另读 0 号属性名，不写进这两段前缀。`extensionClipCullDistance` 另读裁剪剔除距离扩展，不写进这两段前缀。`extensionMultiDraw` 另读多重绘制扩展，不写进这两段前缀。`rendererExtensionParallelShaderCompile` 另读并行着色器编译扩展，不写进这两段前缀。`customProgramCacheKey` 另读自定义程序缓存键，不写进这两段前缀。`vertexUv1s` 另读 1 号 UV 通道是否在用，不写进这两段前缀。`vertexUv2s` 另读 2 号 UV 通道是否在用，不写进这两段前缀。`vertexUv3s` 另读 3 号 UV 通道是否在用，不写进这两段前缀。`shaderID` 另读内置着色器标识，不写进这两段前缀。`USE_FOG` 在场景有雾且材质 `fog` 打开时写进这两段前缀。`FOG_EXP2` 在材质 `fog` 打开且场景雾是指数雾时写在 `USE_FOG` 后面。`ALPHA_TO_COVERAGE` 在 `alpha_to_coverage` 打开时写进片元前缀。`USE_MATCAP` 在有 matcap 贴图时写进片元前缀。`CUBEUV_TEXEL_WIDTH` 在调用方给出立方 UV 高度时写进片元前缀。`CUBEUV_TEXEL_HEIGHT` 用同一高度写成 `1 / 高度`，接在宽度后面。`CUBEUV_MAX_MIP` 用 `log2(高度) - 2` 再加 `.0`，接在高度后面。`USE_CLIP_DISTANCE` 仍不在这里。渲染器仍不编译这串代码。
/// r186: `versionString` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L808
/// r186: `fragmentGlsl` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L836
/// r186: `prefixFragment` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L817
/// r186: `glslVersion` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L819
/// r186: `prefixFragment` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L770
/// r186: `USE_TANGENT` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L739
/// r186: `USE_COLOR` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L740
/// r186: `USE_COLOR_ALPHA` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L741
/// r186: `USE_UV1` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L742
/// r186: `USE_UV2` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L743
/// r186: `USE_UV3` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L744
/// r186: `USE_POINTS_UV` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L746
/// r186: `gradientMap` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L262
/// r186: `USE_GRADIENTMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L748
/// r186: `FLAT_SHADED` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L750
/// r186: `DOUBLE_SIDED` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L752
/// r186: `FLIP_SIDED` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L753
/// r186: `USE_SHADOWMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L755
/// r186: `SHADOWMAP_TYPE_BASIC` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L756
/// r186: `SHADOWMAP_TYPE_PCF` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L348
/// r186: `SHADOWMAP_TYPE_VSM` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L349
/// r186: `premultipliedAlpha` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L371
/// r186: `PREMULTIPLIED_ALPHA` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L758
/// r186: `USE_LIGHT_PROBES` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L760
/// r186: `numLightProbeGrids` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L356
/// r186: `USE_LIGHT_PROBES_GRID` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L762
/// r186: `decodeVideoTexture` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L368
/// r186: `DECODE_VIDEO_TEXTURE` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L764
/// r186: `decodeVideoTextureEmissive` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L369
/// r186: `DECODE_VIDEO_TEXTURE_EMISSIVE` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L765
/// r186: `USE_LOGARITHMIC_DEPTH_BUFFER` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L767
/// r186: `USE_REVERSED_DEPTH_BUFFER` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L768
/// r186: `toneMapping` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L366
/// r186: `TONE_MAPPING` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L774
/// r186: `tonemapping_pars_fragment` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/tonemapping_pars_fragment.glsl.js#L1
/// r186: `tonemapping_pars_fragment` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L775
/// r186: `getToneMappingFunction` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L110
/// r186: `getToneMappingFunction` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L776
/// r186: `dithering` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L361
/// r186: `DITHERING` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L778
/// r186: `opaque` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L264
/// r186: `OPAQUE` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L779
/// r186: `colorspace_pars_fragment` https://github.com/mrdoob/three.js/blob/r186/src/renderers/shaders/ShaderChunk/colorspace_pars_fragment.glsl.js#L1
/// r186: `colorspace_pars_fragment` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L781
/// r186: `getTexelEncodingFunction` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L84
/// r186: `getTexelEncodingFunction` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L782
/// r186: `getLuminanceFunction` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L127
/// r186: `getLuminanceFunction` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L783
/// r186: `useDepthPacking` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L376
/// r186: `DEPTH_PACKING` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L785
/// r186: `prefixFragment` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L787
/// r186: `generateEnvMapTypeDefine` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L364
/// r186: `ENVMAP_TYPE` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L690
/// r186: `generateEnvMapBlendingDefine` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L390
/// r186: `ENVMAP_BLENDING` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L692
/// r186: `HAS_CLEARCOAT` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLPrograms.js#L141
/// r186: `USE_PACKED_NORMALMAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L702
/// r186: `USE_CLEARCOAT` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L708
/// r186: `USE_DISPERSION` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L713
/// r186: `USE_RETROREFLECTION` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L714
/// r186: `USE_IRIDESCENCE` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L716
/// r186: `USE_ALPHATEST` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L728
/// r186: `USE_SHEEN` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L731
/// r186: `USE_FOG` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L683
/// r186: `FOG_EXP2` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L684
/// r186: `ALPHA_TO_COVERAGE` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L686
/// r186: `USE_MATCAP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L688
/// r186: `generateCubeUVSize` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L398
/// r186: `CUBEUV_TEXEL_WIDTH` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L693
/// r186: `CUBEUV_TEXEL_HEIGHT` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L694
/// r186: `CUBEUV_MAX_MIP` https://github.com/mrdoob/three.js/blob/r186/src/renderers/webgl/WebGLProgram.js#L695
pub fn Material::prefixed_fragment_shader(
  self : Material,
  has_tangent~ : Bool = false,
  has_vertex_alpha~ : Bool = false,
  has_points_uv~ : Bool = false,
  shadow_map_enabled~ : Bool = false,
  shadow_map_pcf~ : Bool = false,
  shadow_map_vsm~ : Bool = false,
  num_light_probes~ : Int = 0,
  num_light_probe_grids~ : Int = 0,
  decode_video_texture~ : Bool = false,
  decode_video_texture_emissive~ : Bool = false,
  logarithmic_depth_buffer~ : Bool = false,
  reversed_depth_buffer~ : Bool = false,
  tone_mapping~ : @constants.ToneMapping = @constants.No,
  output_srgb~ : Bool = true,
  depth_packing~ : Int = -1,
  has_fog~ : Bool = false,
  fog_exp2~ : Bool = false,
  env_map_cube_uv_height~ : Int? = None,
  normal_map_format~ : Int = 0,
  instancing_color~ : Bool = false,
  batching_color~ : Bool = false,
  has_normal~ : Bool = false,
) -> String {
  if self.is_shader_material && !self.is_raw_shader_material {
    shader_version_line() +
    glsl3_fragment_defines(self.glsl_version) +
    precision_prefix(self.precision) +
    shader_type_line(self.type_name) +
    shader_name_line(self.name) +
    custom_define_lines(self.defines) +
    use_fog_line(has_fog, self.fog) +
    fog_exp2_line(self.fog, fog_exp2) +
    alpha_to_coverage_line(self.alpha_to_coverage) +
    use_map_line(self.map) +
    use_matcap_line(self.matcap) +
    use_envmap_line(self.env_map) +
    envmap_type_line(self.env_map) +
    envmap_mode_line(self.env_map) +
    envmap_blending_line(self.env_map, self.combine) +
    cubeuv_texel_width_line(env_map_cube_uv_height) +
    cubeuv_texel_height_line(env_map_cube_uv_height) +
    cubeuv_max_mip_line(env_map_cube_uv_height) +
    use_lightmap_line(self.light_map) +
    use_aomap_line(self.ao_map) +
    use_bumpmap_line(self.bump_map) +
    use_normalmap_line(self.normal_map) +
    normalmap_object_line(self.normal_map, self.normal_map_type) +
    normalmap_tangent_line(self.normal_map, self.normal_map_type) +
    use_packed_normalmap_line(self.program_packed_normal_map(normal_map_format)) +
    use_emissivemap_line(self.emissive_map) +
    use_anisotropy_line(self.anisotropy) +
    use_anisotropymap_line(self.anisotropy, self.anisotropy_map) +
    use_clearcoat_line(self.clearcoat) +
    use_clearcoatmap_line(self.clearcoat, self.clearcoat_map) +
    use_clearcoat_roughnessmap_line(self.clearcoat, self.clearcoat_roughness_map) +
    use_clearcoat_normalmap_line(self.clearcoat, self.clearcoat_normal_map) +
    use_dispersion_line(self.dispersion) +
    use_retroreflection_line(self.retroreflectivity) +
    use_iridescence_line(self.iridescence) +
    use_iridescencemap_line(self.iridescence, self.iridescence_map) +
    use_iridescence_thicknessmap_line(
      self.iridescence,
      self.iridescence_thickness_map,
    ) +
    use_specularmap_line(self.specular_map) +
    use_specular_colormap_line(self.specular_color_map) +
    use_specular_intensitymap_line(self.specular_intensity_map) +
    use_roughnessmap_line(self.roughness_map) +
    use_metalnessmap_line(self.metalness_map) +
    use_alphamap_line(self.alpha_map) +
    use_alphatest_line(self.alpha_test) +
    use_alphahash_line(self.alpha_hash) +
    use_sheen_line(self.sheen) +
    use_sheen_colormap_line(self.sheen, self.sheen_color_map) +
    use_sheen_roughnessmap_line(self.sheen, self.sheen_roughness_map) +
    use_transmission_line(self.transmission) +
    use_transmissionmap_line(self.transmission, self.transmission_map) +
    use_thicknessmap_line(self.transmission, self.thickness_map) +
    use_tangent_line(
      has_tangent,
      self.normal_map,
      self.anisotropy,
      self.wireframe,
      self.program_flat_shading(has_normal=has_normal),
    ) +
    use_color_line(self.vertex_colors, instancing_color=instancing_color) +
    use_color_alpha_line(
      self.vertex_colors,
      has_vertex_alpha,
      batching_color=batching_color,
    ) +
    self.use_uv1_line() +
    self.use_uv2_line() +
    self.use_uv3_line() +
    use_points_uv_line(has_points_uv, self.map, self.alpha_map) +
    use_gradientmap_line(self.gradient_map) +
    flat_shaded_line(
      self.wireframe,
      self.program_flat_shading(has_normal=has_normal),
    ) +
    double_sided_line(self.side) +
    flip_sided_line(self.side) +
    use_shadowmap_line(shadow_map_enabled) +
    shadowmap_type_line(shadow_map_enabled, shadow_map_pcf, shadow_map_vsm) +
    premultiplied_alpha_line(self.premultiplied_alpha) +
    use_light_probes_line(num_light_probes) +
    use_light_probes_grid_line(num_light_probe_grids) +
    decode_video_texture_line(decode_video_texture) +
    decode_video_texture_emissive_line(decode_video_texture_emissive) +
    use_logarithmic_depth_buffer_line(logarithmic_depth_buffer) +
    use_reversed_depth_buffer_line(reversed_depth_buffer) +
    builtin_fragment_uniform_prefix() +
    tone_mapping_line(tone_mapping) +
    dithering_line(self.dithering, tone_mapping) +
    opaque_line(
      self.transparent,
      self.blending,
      self.alpha_to_coverage,
      self.dithering,
      tone_mapping,
    ) +
    colorspace_pars_line(
      self.transparent,
      self.blending,
      self.alpha_to_coverage,
      self.dithering,
      tone_mapping,
    ) +
    texel_encoding_line(output_srgb) +
    luminance_line() +
    depth_packing_line(depth_packing) +
    "\n" +
    self.fragment_shader
  } else {
    self.builtin_flat_shaded_prefix(has_normal, has_tangent, false) +
    self.fragment_shader
  }
}

