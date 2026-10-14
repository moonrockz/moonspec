///|
fn path_parts(path : String) -> Array[String] {
  path.split("/").map(s => s.to_owned()).collect()
}

///|
/// The repository path of `rel`, relative to the file `from_file`.
pub fn resolve_path(from_file : String, rel : String) -> String {
  let parts : Array[String] = []
  let dir = path_parts(from_file)
  ignore(dir.pop())
  for p in dir {
    if p != "" && p != "." {
      parts.push(p)
    }
  }
  for s in path_parts(rel) {
    match s {
      "" | "." => ()
      ".." => ignore(parts.pop())
      _ => parts.push(s)
    }
  }
  parts.join("/")
}

///|
/// The lowercase URI scheme of `dest`, if it has one. A scheme is an ASCII
/// letter, then letters, digits, `+`, `-` or `.`, then `:`, all before the
/// first `/`, `?` or `#`.
fn uri_scheme(dest : String) -> String? {
  let head : Array[Char] = []
  for c in dest {
    if c == '/' || c == '?' || c == '#' {
      break
    }
    head.push(c)
  }
  let scheme : Array[Char] = []
  for c in head {
    if c == ':' {
      if scheme.is_empty() {
        return None
      }
      return Some(String::from_array(scheme))
    }
    let ok = if scheme.is_empty() {
      c.is_ascii_alphabetic()
    } else {
      c.is_ascii_alphabetic() ||
      c.is_ascii_digit() ||
      c == '+' ||
      c == '-' ||
      c == '.'
    }
    if !ok {
      return None
    }
    scheme.push(c.to_ascii_lowercase())
  }
  None
}

///|
/// A destination that leaves the site: protocol-relative or with a URI scheme.
fn is_absolute_url(dest : String) -> Bool {
  dest.has_prefix("//") || uri_scheme(dest) is Some(_)
}

///|
fn ascii_lower(s : String) -> String {
  let cs : Array[Char] = []
  for c in s {
    cs.push(c.to_ascii_lowercase())
  }
  String::from_array(cs)
}

///|
/// The only schemes a link may keep. Any other scheme becomes a dead link.
fn is_safe_link_scheme(scheme : String) -> Bool {
  match scheme {
    "http" | "https" | "mailto" | "tel" => true
    _ => false
  }
}

///|
/// Whether a `data:` image has a MIME type that cannot run script.
fn is_safe_image_data(dest : String) -> Bool {
  // The scheme is the four ASCII letters `data` and a colon, so the MIME type
  // starts at byte 5 and ends at the first `;` or `,`.
  let mime : Array[Char] = []
  for c in dest[5:].to_owned() {
    if c == ';' || c == ',' {
      break
    }
    mime.push(c)
  }
  match ascii_lower(String::from_array(mime)) {
    "image/png" | "image/jpeg" | "image/gif" | "image/webp" | "image/svg+xml" =>
      true
    _ => false
  }
}

///|
/// The safe href for a link destination that is absolute. Schemes outside
/// the allowlist become `#`, so the text stays but the link is dead.
fn sanitize_link_url(dest : String) -> String {
  match uri_scheme(dest) {
    Some(scheme) => if is_safe_link_scheme(scheme) { dest } else { "#" }
    None => dest
  }
}

///|
/// The safe source for an image destination that is absolute. Anything but
/// http(s) and raster or SVG `data:` images becomes the empty source.
fn sanitize_image_url(dest : String) -> String {
  match uri_scheme(dest) {
    Some(scheme) =>
      match scheme {
        "http" | "https" => dest
        "data" => if is_safe_image_data(dest) { dest } else { "" }
        _ => ""
      }
    None => dest
  }
}

///|
fn split_anchor(dest : String) -> (String, String?) {
  match dest.find("#") {
    Some(i) => (dest[:i].to_owned(), Some(dest[i + 1:].to_owned()))
    None => (dest, None)
  }
}

///|
fn repo_path(dest_path : String, ctx : LinkContext) -> String {
  if dest_path.has_prefix("/") {
    resolve_path("", dest_path)
  } else {
    resolve_path(ctx.source, dest_path)
  }
}

///|
fn github_url(ctx : LinkContext, path : String, anchor : String?) -> String {
  let last = path_parts(path).last().unwrap_or("")
  let kind = if last.contains(".") { "blob" } else { "tree" }
  let url = ctx.repo_url +
    "/" +
    kind +
    "/" +
    ctx.git_ref +
    (if path == "" { "" } else { "/" + path })
  match anchor {
    Some(a) => url + "#" + a
    None => url
  }
}

///|
/// Rewrites a Markdown link destination for the site.
pub fn rewrite_link(dest : String, ctx : LinkContext) -> Target {
  if dest.has_prefix("#") {
    return Anchor(dest[1:].to_owned())
  }
  if is_absolute_url(dest) {
    return External(sanitize_link_url(dest))
  }
  let (path, anchor) = split_anchor(dest)
  let target = repo_path(path, ctx)
  if target.has_suffix(".md") {
    match (ctx.resolve)(target) {
      Some(route) => return Internal(route, anchor)
      None => ()
    }
  }
  External(github_url(ctx, target, anchor))
}

///|
/// The URL of an image: absolute URLs stay; repository paths load from raw GitHub.
pub fn image_src(dest : String, ctx : LinkContext) -> String {
  if is_absolute_url(dest) {
    return sanitize_image_url(dest)
  }
  let raw_root = if ctx.repo_url.has_prefix("https://github.com/") {
    "https://raw.githubusercontent.com/" +
    ctx.repo_url["https://github.com/".length():].to_owned()
  } else {
    ctx.repo_url
  }
  raw_root + "/" + ctx.git_ref + "/" + repo_path(dest, ctx)
}
