// r186: `loadImageSource` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L3341 ; `assignTexture` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L3440

///|
priv struct SamplerDesc {
  mag : @constants.TextureFilter
  min : @constants.TextureFilter
  wrap_s : @constants.Wrapping
  wrap_t : @constants.Wrapping
}

///|
priv struct ImagePixels {
  width : Int32
  height : Int32
  rgba : FixedArray[Byte]
}

///|
/// `texCoord` 缺省或 0 使用 `TEXCOORD_0`。大于 0 这份加载器没有第二套 uv。
/// r186: `assignTexture` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L3440
fn texture_info(obj : Map[String, Json], key : String) -> Int32 raise GltfError {
  match obj.get(key) {
    None => -1
    Some(value) => {
      let info = as_object(value)
      match info.get("texCoord") {
        None => ()
        Some(coord) =>
          if as_f64(coord).to_int() != 0 {
            raise GltfError::Invalid("texCoord")
          }
      }
      match info.get("index") {
        None => raise GltfError::Invalid("texture index")
        Some(index) => {
          let at = as_f64(index).to_int()
          if at < 0 {
            raise GltfError::Invalid("texture index")
          }
          at
        }
      }
    }
  }
}

///|
fn checked_texture(
  index : Int32,
  texture_count : Int32,
) -> Int32 raise GltfError {
  if index >= texture_count {
    raise GltfError::Invalid("texture index")
  }
  index
}

///|
fn load_images(
  root : Map[String, Json],
  bins : Array[Bin],
  views : Array[View],
) -> Array[ImagePixels] raise GltfError {
  let listed = objects(root, "images")
  let out = []
  let mut i = 0
  while i < listed.length() {
    let bytes = image_bytes(listed[i], bins, views)
    let (width, height, rgba) = decode_png(bytes)
    out.push({ width, height, rgba, })
    i = i + 1
  }
  out
}

///|
/// 有 `uri` 时走 data URI。否则要求 `bufferView` 和 `image/png`。JPEG 直接拒绝。
/// r186: `loadImageSource` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L3341
fn image_bytes(
  obj : Map[String, Json],
  bins : Array[Bin],
  views : Array[View],
) -> Bytes raise GltfError {
  match obj.get("uri") {
    Some(uri) => {
      let bytes = decode_uri(as_string(uri))
      if bytes.length() >= 2 && bytes.at(0) == b'\xff' && bytes.at(1) == b'\xd8' {
        raise GltfError::Invalid("jpeg")
      }
      bytes
    }
    None =>
      match obj.get("bufferView") {
        None => raise GltfError::Invalid("image")
        Some(index) => {
          let mime = opt_string(obj, "mimeType", "")
          if mime == "image/jpeg" {
            raise GltfError::Invalid("jpeg")
          }
          if mime != "image/png" {
            raise GltfError::Invalid("png")
          }
          view_bytes(bins, views, as_f64(index).to_int())
        }
      }
  }
}

///|
fn view_bytes(
  bins : Array[Bin],
  views : Array[View],
  index : Int32,
) -> Bytes raise GltfError {
  if index < 0 || index >= views.length() {
    raise GltfError::Invalid("image view")
  }
  let view = views[index]
  if view.buffer < 0 || view.buffer >= bins.length() {
    raise GltfError::Invalid("image view")
  }
  let bin = bins[view.buffer]
  let start = view.offset
  let length = view.byte_length
  if start < 0 || length < 0 || start + length > bin.limit {
    raise GltfError::Invalid("image view")
  }
  let raw = []
  let mut i = 0
  while i < length {
    raw.push(bin.bytes.at(start + i))
    i = i + 1
  }
  Bytes::from_array(raw)
}

///|
fn default_sampler() -> SamplerDesc {
  {
    mag: @constants.Linear,
    min: @constants.LinearMipmapLinear,
    wrap_s: @constants.Repeat,
    wrap_t: @constants.Repeat,
  }
}

///|
fn load_samplers(
  root : Map[String, Json],
) -> Array[SamplerDesc] raise GltfError {
  let listed = objects(root, "samplers")
  let out = []
  let mut i = 0
  while i < listed.length() {
    out.push(load_sampler(listed[i]))
    i = i + 1
  }
  out
}

///|
/// 缺省放大是线性，缩小是线性 mipmap 线性，包裹是重复。
/// r186: `loadTexture` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L3266
fn load_sampler(obj : Map[String, Json]) -> SamplerDesc raise GltfError {
  let fallback = default_sampler()
  {
    mag: match obj.get("magFilter") {
      None => fallback.mag
      Some(value) => gltf_filter(as_f64(value).to_int())
    },
    min: match obj.get("minFilter") {
      None => fallback.min
      Some(value) => gltf_filter(as_f64(value).to_int())
    },
    wrap_s: match obj.get("wrapS") {
      None => fallback.wrap_s
      Some(value) => gltf_wrap(as_f64(value).to_int())
    },
    wrap_t: match obj.get("wrapT") {
      None => fallback.wrap_t
      Some(value) => gltf_wrap(as_f64(value).to_int())
    },
  }
}

///|
fn gltf_filter(value : Int32) -> @constants.TextureFilter raise GltfError {
  match value {
    9728 => @constants.Nearest
    9729 => @constants.Linear
    9984 => @constants.NearestMipmapNearest
    9985 => @constants.LinearMipmapNearest
    9986 => @constants.NearestMipmapLinear
    9987 => @constants.LinearMipmapLinear
    _ => raise GltfError::Invalid("sampler filter")
  }
}

///|
fn gltf_wrap(value : Int32) -> @constants.Wrapping raise GltfError {
  match value {
    33071 => @constants.ClampToEdge
    33648 => @constants.MirroredRepeat
    10497 => @constants.Repeat
    _ => raise GltfError::Invalid("sampler wrap")
  }
}

///|
/// r186: `loadTextureImage` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L3287
fn load_gltf_textures(
  root : Map[String, Json],
  images : Array[ImagePixels],
  samplers : Array[SamplerDesc],
) -> Array[@textures.Texture] raise GltfError {
  let listed = objects(root, "textures")
  let out = []
  let mut i = 0
  while i < listed.length() {
    let obj = listed[i]
    let source = match obj.get("source") {
      None => raise GltfError::Invalid("texture source")
      Some(value) => as_f64(value).to_int()
    }
    if source < 0 || source >= images.length() {
      raise GltfError::Invalid("texture source")
    }
    let sampler = match obj.get("sampler") {
      None => default_sampler()
      Some(value) => {
        let index = as_f64(value).to_int()
        if index < 0 || index >= samplers.length() {
          raise GltfError::Invalid("sampler index")
        }
        samplers[index]
      }
    }
    let image = images[source]
    let texture = @textures.Texture::from_rgba8(
      image.width,
      image.height,
      image.rgba,
    )
    texture.flip_y = false
    texture.wrap_s = sampler.wrap_s
    texture.wrap_t = sampler.wrap_t
    texture.mag_filter = sampler.mag
    texture.min_filter = sampler.min
    out.push(texture)
    i = i + 1
  }
  out
}
