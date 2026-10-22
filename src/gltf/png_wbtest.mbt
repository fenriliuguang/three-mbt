///|
fn png_bytes(payload : String) -> Bytes raise GltfError {
  @base64.decode(payload) catch {
    _ => raise GltfError::Invalid("png fixture")
  }
}

///|
test "png decodes rgb, sub filter, grayscale, stored deflate, and paeth" {
  let (rw, rh, red) = decode_png(
    png_bytes(
      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGP4z8AAAAMBAQDJ/pLvAAAAAElFTkSuQmCC",
    ),
  )
  assert_eq(rw, 1)
  assert_eq(rh, 1)
  assert_eq(red[0], b'\xff')
  assert_eq(red[1], b'\x00')
  assert_eq(red[2], b'\x00')
  assert_eq(red[3], b'\xff')
  let (sw, sh, sub) = decode_png(
    png_bytes(
      "iVBORw0KGgoAAAANSUhEUgAAAAIAAAABCAIAAAB7QOjdAAAAD0lEQVR4nGPkEpFjZWMHAAFIAFDvtu5tAAAAAElFTkSuQmCC",
    ),
  )
  assert_eq(sw, 2)
  assert_eq(sh, 1)
  assert_eq(sub[0], b'\x0a')
  assert_eq(sub[1], b'\x14')
  assert_eq(sub[2], b'\x1e')
  assert_eq(sub[4], b'\x0f')
  assert_eq(sub[5], b'\x1a')
  assert_eq(sub[6], b'\x25')
  let (_, _, gray) = decode_png(
    png_bytes(
      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAAAAAA6fptVAAAACklEQVR4nGPQAAAAKgApazFUcwAAAABJRU5ErkJggg==",
    ),
  )
  assert_eq(gray[0], b'\x28')
  assert_eq(gray[1], b'\x28')
  assert_eq(gray[2], b'\x28')
  assert_eq(gray[3], b'\xff')
  let (_, _, stored) = decode_png(
    png_bytes(
      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAEElEQVR4AQEFAPr/AAECA/8BFAEGUZo7bQAAAABJRU5ErkJggg==",
    ),
  )
  assert_eq(stored[0], b'\x01')
  assert_eq(stored[1], b'\x02')
  assert_eq(stored[2], b'\x03')
  assert_eq(stored[3], b'\xff')
  let (_, ph, paeth) = decode_png(
    png_bytes(
      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAACCAIAAAAW4yFwAAAAEElEQVR4nGPgEpFjYWJiBgABeQBI/SYG8wAAAABJRU5ErkJggg==",
    ),
  )
  assert_eq(ph, 2)
  assert_eq(paeth[0], b'\x0a')
  assert_eq(paeth[1], b'\x14')
  assert_eq(paeth[2], b'\x1e')
  assert_eq(paeth[4], b'\x0c')
  assert_eq(paeth[5], b'\x16')
  assert_eq(paeth[6], b'\x21')
}

///|
test "png rejects a short header" {
  let failed = try {
    ignore(decode_png(b"nope"))
    false
  } catch {
    GltfError::Invalid(_) => true
  }
  assert_eq(failed, true)
}
