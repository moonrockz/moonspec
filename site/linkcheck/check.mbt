///|
fn decode_entities(s : String) -> String {
  s.replace_all(old="&amp;", new="&")
}

///|
/// Values of `href="..."` and `src="..."` attributes, in document order.
pub fn extract_links(html : String) -> Array[String] {
  let out : Array[String] = []
  let chars = html.to_array()
  let mut i = 0
  while i < chars.length() {
    let end = if i + 6 < chars.length() { i + 6 } else { chars.length() }
    let rest = String::from_array(chars[i:end].to_owned())
    let skip = if rest.has_prefix("href=\"") {
      6
    } else if rest.has_prefix("src=\"") {
      5
    } else {
      0
    }
    if skip > 0 {
      let start = i + skip
      let mut j = start
      while j < chars.length() && chars[j] != '"' {
        j = j + 1
      }
      out.push(decode_entities(String::from_array(chars[start:j].to_owned())))
      i = j + 1
    } else {
      i = i + 1
    }
  }
  out
}

///|
/// The site path of an internal link (after `base`, without `#` or `?`), or
/// `None` for external, same-page and ignored links.
pub fn internal_path(
  base : String,
  ignore : Array[String],
  link : String,
) -> String? {
  guard link.has_prefix(base) else { return None }
  for prefix in ignore {
    if link.has_prefix(prefix) {
      return None
    }
  }
  let mut path = link[base.length():].to_owned()
  match path.find("#") {
    Some(k) => path = path[:k].to_owned()
    None => ()
  }
  match path.find("?") {
    Some(k) => path = path[:k].to_owned()
    None => ()
  }
  Some(path)
}

///|
/// The file, relative to `dist`, that serves the site path `path`.
pub fn target_file(path : String) -> String {
  if path == "" {
    return "index.html"
  }
  if path.has_suffix("/") {
    return path + "index.html"
  }
  let exts = [
    ".html", ".css", ".js", ".json", ".md", ".png", ".ico", ".svg", ".txt",
  ]
  if exts.iter().any(e => path.has_suffix(e)) {
    path
  } else {
    path + "/index.html"
  }
}

///|
fn html_files(dir : String, rel : String, out : Array[String]) -> Unit raise {
  for name in @fs.read_dir(dir) {
    let full = dir + "/" + name
    let relative = if rel == "" { name } else { rel + "/" + name }
    if @fs.is_dir(full) {
      html_files(full, relative, out)
    } else if name.has_suffix(".html") {
      out.push(relative)
    }
  }
}

///|
/// All problems found in `dist`; empty when the build is consistent.
pub fn check(
  dist : String,
  base : String,
  ignore : Array[String],
) -> Array[String] raise {
  let problems : Array[String] = []
  let pages : Array[String] = []
  html_files(dist, "", pages)
  for page in pages {
    let html = @fs.read_file_to_string(dist + "/" + page)
    for link in extract_links(html) {
      match internal_path(base, ignore, link) {
        Some(path) =>
          if !@fs.path_exists(dist + "/" + target_file(path)) {
            problems.push("\{page}: broken link \{link}")
          }
        None => ()
      }
    }
  }
  let routes : Array[String] = @json.from_json(
    @json.parse(@fs.read_file_to_string(dist + "/routes.json")),
  )
  let entries : Array[@search.Entry] = @json.from_json(
    @json.parse(@fs.read_file_to_string(dist + "/search-index.json")),
  )
  for route in routes {
    if !@fs.path_exists(dist + "/" + target_file(route)) {
      problems.push("route \{route} has no HTML file")
    }
    if route != "" && !entries.iter().any(e => e.route.to_path() == route) {
      problems.push("route \{route} is not in the search index")
    }
  }
  if !@fs.path_exists(dist + "/404.html") {
    problems.push("404.html is missing")
  }
  problems
}
