// r186: `loadImageSource` https://github.com/mrdoob/three.js/blob/r186/examples/jsm/loaders/GLTFLoader.js#L3341

///|
/// 把 PNG 解成紧排 `rgba8`。只接受 8 位、不交错的灰度、灰度和 alpha、RGB、RGBA。
/// 压缩是 zlib 包起来的 deflate，包含存储块、固定哈夫曼和动态哈夫曼。
fn decode_png(data : Bytes) -> (Int32, Int32, FixedArray[Byte]) raise GltfError {
  if data.length() < 8 {
    raise GltfError::Invalid("png")
  }
  let signature = [137, 80, 78, 71, 13, 10, 26, 10]
  let mut i = 0
  while i < 8 {
    if data.at(i).to_int() != signature[i] {
      raise GltfError::Invalid("png")
    }
    i = i + 1
  }
  let mut pos = 8
  let mut width = 0
  let mut height = 0
  let mut color = -1
  let idat_bytes = []
  while pos + 8 <= data.length() {
    let length = be32(data, pos)
    let start = pos + 8
    if length < 0 || start + length + 4 > data.length() {
      raise GltfError::Invalid("png chunk")
    }
    if chunk_is(data, pos + 4, b'I', b'H', b'D', b'R') {
      if length < 13 {
        raise GltfError::Invalid("png header")
      }
      width = be32(data, start)
      height = be32(data, start + 4)
      if data.at(start + 8).to_int() != 8 ||
        data.at(start + 10).to_int() != 0 ||
        data.at(start + 11).to_int() != 0 ||
        data.at(start + 12).to_int() != 0 {
        raise GltfError::Invalid("png header")
      }
      color = data.at(start + 9).to_int()
    } else if chunk_is(data, pos + 4, b'I', b'D', b'A', b'T') {
      let mut offset = 0
      while offset < length {
        idat_bytes.push(data.at(start + offset))
        offset = offset + 1
      }
    } else if chunk_is(data, pos + 4, b'I', b'E', b'N', b'D') {
      break
    }
    pos = start + length + 4
  }
  let idat = Bytes::from_array(idat_bytes)
  if width < 1 || height < 1 || color < 0 {
    raise GltfError::Invalid("png header")
  }
  let channels = match color {
    0 => 1
    2 => 3
    4 => 2
    6 => 4
    _ => raise GltfError::Invalid("png color")
  }
  let raw = inflate_zlib(idat)
  let pixels = unfilter_png(raw, width, height, channels)
  (width, height, pixels)
}

///|
fn be32(data : Bytes, offset : Int32) -> Int32 raise GltfError {
  if offset < 0 || offset + 4 > data.length() {
    raise GltfError::Invalid("png chunk")
  }
  data.at(offset).to_int() * 16777216 +
  data.at(offset + 1).to_int() * 65536 +
  data.at(offset + 2).to_int() * 256 +
  data.at(offset + 3).to_int()
}

///|
fn chunk_is(
  data : Bytes,
  offset : Int32,
  a : Byte,
  b : Byte,
  c : Byte,
  d : Byte,
) -> Bool raise GltfError {
  if offset < 0 || offset + 4 > data.length() {
    raise GltfError::Invalid("png chunk")
  }
  data.at(offset) == a &&
  data.at(offset + 1) == b &&
  data.at(offset + 2) == c &&
  data.at(offset + 3) == d
}

///|
fn inflate_zlib(data : Bytes) -> Array[Int32] raise GltfError {
  if data.length() < 2 {
    raise GltfError::Invalid("png zlib")
  }
  let cmf = data.at(0).to_int()
  let flg = data.at(1).to_int()
  if (cmf & 15) != 8 || (cmf * 256 + flg) % 31 != 0 || (flg & 32) != 0 {
    raise GltfError::Invalid("png zlib")
  }
  let (out, pos, bit) = inflate_blocks(data, 2, 0)
  if pos > data.length() - 4 {
    raise GltfError::Invalid("png adler")
  }
  let mut aligned = pos
  if bit != 0 {
    aligned = pos + 1
  }
  if aligned + 4 > data.length() {
    raise GltfError::Invalid("png adler")
  }
  let expected = be32(data, aligned)
  if adler32(out) != expected {
    raise GltfError::Invalid("png adler")
  }
  out
}

///|
fn adler32(data : Array[Int32]) -> Int32 {
  let mut a = 1
  let mut b = 0
  let mut i = 0
  while i < data.length() {
    a = (a + data[i]) % 65521
    b = (b + a) % 65521
    i = i + 1
  }
  b * 65536 + a
}

///|
fn inflate_blocks(
  data : Bytes,
  pos : Int32,
  bit : Int32,
) -> (Array[Int32], Int32, Int32) raise GltfError {
  let out = []
  let mut p = pos
  let mut b = bit
  let mut last = 0
  while last == 0 {
    let (header, p1, b1) = take_bits(data, p, b, 3)
    p = p1
    b = b1
    last = header & 1
    let kind = header >> 1
    if kind == 0 {
      let (p2, b2) = align_bits(p, b)
      p = p2
      b = b2
      let (len, p3, b3) = take_bits(data, p, b, 16)
      p = p3
      b = b3
      let (nlen, p4, b4) = take_bits(data, p, b, 16)
      p = p4
      b = b4
      if (len ^ 0xFFFF) != nlen {
        raise GltfError::Invalid("png stored")
      }
      if p + len > data.length() {
        raise GltfError::Invalid("png stored")
      }
      let mut i = 0
      while i < len {
        out.push(data.at(p + i).to_int())
        i = i + 1
      }
      p = p + len
    } else if kind == 1 {
      let (p2, b2) = inflate_huffman(
        data,
        p,
        b,
        fixed_lengths(true),
        fixed_lengths(false),
        out,
      )
      p = p2
      b = b2
    } else if kind == 2 {
      let (lit, dist, p2, b2) = dynamic_lengths(data, p, b)
      p = p2
      b = b2
      let (p3, b3) = inflate_huffman(data, p, b, lit, dist, out)
      p = p3
      b = b3
    } else {
      raise GltfError::Invalid("png deflate")
    }
  }
  (out, p, b)
}

///|
fn fixed_lengths(literal : Bool) -> Array[Int32] {
  let out = []
  if literal {
    let mut i = 0
    while i < 288 {
      let len = if i < 144 {
        8
      } else if i < 256 {
        9
      } else if i < 280 {
        7
      } else {
        8
      }
      out.push(len)
      i = i + 1
    }
  } else {
    let mut i = 0
    while i < 32 {
      out.push(5)
      i = i + 1
    }
  }
  out
}

///|
fn dynamic_lengths(
  data : Bytes,
  pos : Int32,
  bit : Int32,
) -> (Array[Int32], Array[Int32], Int32, Int32) raise GltfError {
  let (hlit, p1, b1) = take_bits(data, pos, bit, 5)
  let (hdist, p2, b2) = take_bits(data, p1, b1, 5)
  let (hclen, p3, b3) = take_bits(data, p2, b2, 4)
  let order = [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15]
  let code_lengths = []
  let mut i = 0
  while i < 19 {
    code_lengths.push(0)
    i = i + 1
  }
  let mut p = p3
  let mut b = b3
  i = 0
  while i < hclen + 4 {
    let (len, p4, b4) = take_bits(data, p, b, 3)
    p = p4
    b = b4
    code_lengths[order[i]] = len
    i = i + 1
  }
  let total = hlit + 257 + hdist + 1
  let lengths = []
  while lengths.length() < total {
    let (symbol, p5, b5) = decode_one(data, p, b, code_lengths)
    p = p5
    b = b5
    if symbol < 16 {
      lengths.push(symbol)
    } else if symbol == 16 {
      if lengths.length() == 0 {
        raise GltfError::Invalid("png dynamic")
      }
      let (extra, p6, b6) = take_bits(data, p, b, 2)
      p = p6
      b = b6
      let previous = lengths[lengths.length() - 1]
      let mut n = 0
      while n < extra + 3 {
        lengths.push(previous)
        n = n + 1
      }
    } else if symbol == 17 {
      let (extra, p6, b6) = take_bits(data, p, b, 3)
      p = p6
      b = b6
      let mut n = 0
      while n < extra + 3 {
        lengths.push(0)
        n = n + 1
      }
    } else if symbol == 18 {
      let (extra, p6, b6) = take_bits(data, p, b, 7)
      p = p6
      b = b6
      let mut n = 0
      while n < extra + 11 {
        lengths.push(0)
        n = n + 1
      }
    } else {
      raise GltfError::Invalid("png dynamic")
    }
  }
  if lengths.length() != total {
    raise GltfError::Invalid("png dynamic")
  }
  let lit = []
  let dist = []
  i = 0
  while i < hlit + 257 {
    lit.push(lengths[i])
    i = i + 1
  }
  while i < total {
    dist.push(lengths[i])
    i = i + 1
  }
  (lit, dist, p, b)
}

///|
fn inflate_huffman(
  data : Bytes,
  pos : Int32,
  bit : Int32,
  literal : Array[Int32],
  distance : Array[Int32],
  out : Array[Int32],
) -> (Int32, Int32) raise GltfError {
  let mut p = pos
  let mut b = bit
  while true {
    let (symbol, p1, b1) = decode_one(data, p, b, literal)
    p = p1
    b = b1
    if symbol < 256 {
      out.push(symbol)
    } else if symbol == 256 {
      break
    } else if symbol < 286 {
      let index = symbol - 257
      let (extra, p2, b2) = take_bits(data, p, b, length_extra(index))
      p = p2
      b = b2
      let length = length_base(index) + extra
      let (dist_symbol, p3, b3) = decode_one(data, p, b, distance)
      p = p3
      b = b3
      let (dist_extra, p4, b4) = take_bits(
        data,
        p,
        b,
        distance_extra(dist_symbol),
      )
      p = p4
      b = b4
      let distance = distance_base(dist_symbol) + dist_extra
      if distance <= 0 || distance > out.length() {
        raise GltfError::Invalid("png distance")
      }
      let mut n = 0
      while n < length {
        let at = out.length() - distance
        out.push(out[at])
        n = n + 1
      }
    } else {
      raise GltfError::Invalid("png literal")
    }
  }
  (p, b)
}

///|
fn decode_one(
  data : Bytes,
  pos : Int32,
  bit : Int32,
  lengths : Array[Int32],
) -> (Int32, Int32, Int32) raise GltfError {
  let (symbol, left, right) = huff_tree(lengths)
  let mut node = 0
  let mut p = pos
  let mut b = bit
  while symbol[node] < 0 {
    let (one, p1, b1) = take_bits(data, p, b, 1)
    p = p1
    b = b1
    node = if one == 0 { left[node] } else { right[node] }
    if node < 0 || node >= symbol.length() {
      raise GltfError::Invalid("png huffman")
    }
  }
  (symbol[node], p, b)
}

///|
fn huff_tree(
  lengths : Array[Int32],
) -> (Array[Int32], Array[Int32], Array[Int32]) raise GltfError {
  let counts = FixedArray::make(16, 0)
  let mut i = 0
  while i < lengths.length() {
    let len = lengths[i]
    if len < 0 || len > 15 {
      raise GltfError::Invalid("png huffman")
    }
    if len > 0 {
      counts[len] = counts[len] + 1
    }
    i = i + 1
  }
  let next = FixedArray::make(16, 0)
  let mut code = 0
  let mut bits = 1
  while bits <= 15 {
    code = (code + counts[bits - 1]) << 1
    next[bits] = code
    bits = bits + 1
  }
  let symbol = [-1]
  let left = [-1]
  let right = [-1]
  i = 0
  while i < lengths.length() {
    let len = lengths[i]
    if len > 0 {
      add_code(symbol, left, right, next[len], len, i)
      next[len] = next[len] + 1
    }
    i = i + 1
  }
  (symbol, left, right)
}

///|
fn add_code(
  symbol : Array[Int32],
  left : Array[Int32],
  right : Array[Int32],
  code : Int32,
  length : Int32,
  value : Int32,
) -> Unit {
  let mut node = 0
  let mut i = length - 1
  while i >= 0 {
    let bit = (code >> i) & 1
    let child = if bit == 0 { left[node] } else { right[node] }
    if i == 0 {
      let leaf = if child >= 0 {
        child
      } else {
        let id = symbol.length()
        symbol.push(value)
        left.push(-1)
        right.push(-1)
        if bit == 0 {
          left[node] = id
        } else {
          right[node] = id
        }
        id
      }
      symbol[leaf] = value
    } else if child >= 0 {
      node = child
    } else {
      let id = symbol.length()
      symbol.push(-1)
      left.push(-1)
      right.push(-1)
      if bit == 0 {
        left[node] = id
      } else {
        right[node] = id
      }
      node = id
    }
    i = i - 1
  }
}

///|
fn take_bits(
  data : Bytes,
  pos : Int32,
  bit : Int32,
  n : Int32,
) -> (Int32, Int32, Int32) raise GltfError {
  let mut value = 0
  let mut p = pos
  let mut b = bit
  let mut i = 0
  while i < n {
    if p < 0 || p >= data.length() {
      raise GltfError::Invalid("png deflate")
    }
    let one = (data.at(p).to_int() >> b) & 1
    value = value | (one << i)
    b = b + 1
    if b == 8 {
      b = 0
      p = p + 1
    }
    i = i + 1
  }
  (value, p, b)
}

///|
fn align_bits(pos : Int32, bit : Int32) -> (Int32, Int32) {
  if bit == 0 {
    (pos, 0)
  } else {
    (pos + 1, 0)
  }
}

///|
fn length_base(index : Int32) -> Int32 raise GltfError {
  let bases = [
    3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67,
    83, 99, 115, 131, 163, 195, 227, 258,
  ]
  if index < 0 || index >= bases.length() {
    raise GltfError::Invalid("png length")
  }
  bases[index]
}

///|
fn length_extra(index : Int32) -> Int32 raise GltfError {
  let extras = [
    0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5,
    5, 5, 0,
  ]
  if index < 0 || index >= extras.length() {
    raise GltfError::Invalid("png length")
  }
  extras[index]
}

///|
fn distance_base(index : Int32) -> Int32 raise GltfError {
  let bases = [
    1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513, 769,
    1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577,
  ]
  if index < 0 || index >= bases.length() {
    raise GltfError::Invalid("png distance")
  }
  bases[index]
}

///|
fn distance_extra(index : Int32) -> Int32 raise GltfError {
  let extras = [
    0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11,
    11, 12, 12, 13, 13,
  ]
  if index < 0 || index >= extras.length() {
    raise GltfError::Invalid("png distance")
  }
  extras[index]
}

///|
fn unfilter_png(
  raw : Array[Int32],
  width : Int32,
  height : Int32,
  channels : Int32,
) -> FixedArray[Byte] raise GltfError {
  let stride = width * channels
  let expected = height * (stride + 1)
  if raw.length() < expected {
    raise GltfError::Invalid("png rows")
  }
  let prior = FixedArray::make(stride, 0)
  let current = FixedArray::make(stride, 0)
  let pixels = FixedArray::make(width * height * 4, b'\x00')
  let mut y = 0
  while y < height {
    let filter = raw[y * (stride + 1)]
    let mut x = 0
    while x < stride {
      let value = raw[y * (stride + 1) + 1 + x]
      let left = if x >= channels { current[x - channels] } else { 0 }
      let up = prior[x]
      let up_left = if x >= channels { prior[x - channels] } else { 0 }
      let recon = match filter {
        0 => value
        1 => value + left
        2 => value + up
        3 => value + (left + up) / 2
        4 => value + paeth(left, up, up_left)
        _ => raise GltfError::Invalid("png filter")
      }
      current[x] = recon & 255
      x = x + 1
    }
    let mut px = 0
    while px < width {
      let base = px * channels
      let (r, g, b, a) = match channels {
        1 => {
          let v = current[base]
          (v, v, v, 255)
        }
        2 => {
          let v = current[base]
          (v, v, v, current[base + 1])
        }
        3 => (current[base], current[base + 1], current[base + 2], 255)
        _ =>
          (
            current[base],
            current[base + 1],
            current[base + 2],
            current[base + 3],
          )
      }
      let dst = (y * width + px) * 4
      pixels[dst] = r.to_byte()
      pixels[dst + 1] = g.to_byte()
      pixels[dst + 2] = b.to_byte()
      pixels[dst + 3] = a.to_byte()
      px = px + 1
    }
    let mut copy = 0
    while copy < stride {
      prior[copy] = current[copy]
      copy = copy + 1
    }
    y = y + 1
  }
  pixels
}

///|
fn paeth(left : Int32, up : Int32, up_left : Int32) -> Int32 {
  let estimate = left + up - up_left
  let dl = abs_int(estimate - left)
  let du = abs_int(estimate - up)
  let dul = abs_int(estimate - up_left)
  if dl <= du && dl <= dul {
    left
  } else if du <= dul {
    up
  } else {
    up_left
  }
}

///|
fn abs_int(value : Int32) -> Int32 {
  if value < 0 {
    -value
  } else {
    value
  }
}
