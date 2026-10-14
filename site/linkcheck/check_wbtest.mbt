///|
test "extract_links finds href and src values and decodes &amp;" {
  let html = "<a href=\"/moonspec/docs/x#y\">x</a><img src=\"/moonspec/a.png\"><a href=\"https://e.com/?a=1&amp;b=2\">e</a>"
  assert_eq(extract_links(html), [
    "/moonspec/docs/x#y", "/moonspec/a.png", "https://e.com/?a=1&b=2",
  ])
}

///|
test "target_file maps a site path to the file that serves it" {
  assert_eq(target_file(""), "index.html")
  assert_eq(target_file("docs/x"), "docs/x/index.html")
  assert_eq(target_file("docs/x/"), "docs/x/index.html")
  assert_eq(target_file("styles.css"), "styles.css")
  assert_eq(target_file("content/docs/guide/a.md"), "content/docs/guide/a.md")
}

///|
test "internal_path keeps only links under the base and not ignored" {
  assert_eq(
    internal_path("/moonspec/", ["/moonspec/next/"], "/moonspec/docs/x#y"),
    Some("docs/x"),
  )
  assert_eq(
    internal_path("/moonspec/", ["/moonspec/next/"], "/moonspec/next/docs/x"),
    None,
  )
  assert_eq(internal_path("/moonspec/", [], "https://e.com/"), None)
  assert_eq(internal_path("/moonspec/", [], "#top"), None)
}

///|
test "target_file treats dotted version routes as directories" {
  assert_eq(target_file("migrations/v0.11.0"), "migrations/v0.11.0/index.html")
  assert_eq(
    target_file("content/docs/migrations/v0.11.0.md"),
    "content/docs/migrations/v0.11.0.md",
  )
}

///|
fn mkdirs(path : String) -> Unit raise {
  let mut cur = ""
  for part in path.split("/") {
    cur = if cur == "" && path.has_prefix("/") {
      "/" + part.to_owned()
    } else if cur == "" {
      part.to_owned()
    } else {
      cur + "/" + part.to_owned()
    }
    if part.to_owned() != "" && !@fs.path_exists(cur) {
      @fs.create_dir(cur)
    }
  }
}

///|
fn rm_rf(path : String) -> Unit raise {
  if !@fs.path_exists(path) {
    return
  }
  if @fs.is_dir(path) {
    for name in @fs.read_dir(path) {
      rm_rf(path + "/" + name)
    }
    @fs.remove_dir(path)
  } else {
    @fs.remove_file(path)
  }
}

///|
fn put(root : String, rel : String, text : String) -> Unit raise {
  let full = root + "/" + rel
  match full.rev_find("/") {
    Some(i) => mkdirs(full[:i].to_owned())
    None => ()
  }
  @fs.write_string_to_file(full, text)
}

///|
fn entry_for(route : @route.Route) -> @search.Entry {
  { route, anchor: "", page: "X", path: ["X"], text: "text", }
}

///|
fn fixture(
  name : String,
  routes : Array[String],
  pages : Array[String],
  index_html : String,
) -> String raise {
  let root = "_build/linkcheck_fixture_" + name
  put(root, "index.html", index_html)
  put(root, "404.html", "<html></html>")
  for p in pages {
    put(root, p, "<html></html>")
  }
  put(root, "routes.json", Json(routes).stringify())
  put(
    root,
    "search-index.json",
    Json([entry_for(Doc("x")), entry_for(Migration("v0.11.0"))]).stringify(),
  )
  root
}

///|
test "check accepts a consistent dist" {
  let root = fixture(
    "ok",
    ["", "docs/x"],
    ["docs/x/index.html"],
    "<a href=\"/b/docs/x/\">x</a>",
  )
  let problems = check(root, "/b/", [])
  rm_rf(root)
  assert_eq(problems, [])
}

///|
test "check reports a broken internal link" {
  let root = fixture(
    "link",
    ["", "docs/x"],
    ["docs/x/index.html"],
    "<a href=\"/b/docs/missing/\">x</a>",
  )
  let problems = check(root, "/b/", [])
  rm_rf(root)
  assert_eq(problems, ["index.html: broken link /b/docs/missing/"])
}

///|
test "check reports a route without an HTML file" {
  let root = fixture("route", ["", "docs/x"], [], "<p></p>")
  let problems = check(root, "/b/", [])
  rm_rf(root)
  assert_eq(problems, ["route docs/x has no HTML file"])
}

///|
test "check reports a dotted migration route directory without index.html" {
  let root = fixture("dotted", ["", "migrations/v0.11.0"], [], "<p></p>")
  put(root, "migrations/v0.11.0/other.txt", "x")
  let problems = check(root, "/b/", [])
  rm_rf(root)
  assert_eq(problems, ["route migrations/v0.11.0 has no HTML file"])
}

///|
test "check accepts the docs alias route and its HTML file" {
  let root = fixture(
    "alias",
    ["", "docs", "docs/x"],
    ["docs/x/index.html", "docs/index.html"],
    "<a href=\"/b/docs/\">d</a>",
  )
  let problems = check(root, "/b/", [])
  rm_rf(root)
  assert_eq(problems, [])
}

///|
test "check reports a missing docs alias file" {
  let root = fixture(
    "noalias",
    ["", "docs", "docs/x"],
    ["docs/x/index.html"],
    "<p></p>",
  )
  let problems = check(root, "/b/", [])
  rm_rf(root)
  assert_eq(problems, ["route docs has no HTML file"])
}

///|
fn heading_fixture(name : String, page_html : String) -> String raise {
  let root = fixture(name, ["", "docs/x"], ["docs/x/index.html"], "<p></p>")
  put(root, "docs/x/index.html", page_html)
  put(
    root,
    "search-index.json",
    Json([
      entry_for(Doc("x")),
      { ..entry_for(Doc("x")), anchor: "intro", },
      { ..entry_for(Doc("x")), anchor: "deep", },
    ]).stringify(),
  )
  root
}

///|
test "check accepts headings that are all in the search index" {
  let root = heading_fixture(
    "headings_ok", "<h1 id=\"t\">T</h1><h2 id=\"intro\">Intro</h2><h3 id=\"deep\">Deep</h3>",
  )
  let problems = check(root, "/b/", [])
  rm_rf(root)
  assert_eq(problems, [])
}

///|
test "check reports a heading missing from the search index" {
  let root = heading_fixture(
    "headings_missing", "<h2 id=\"intro\">Intro</h2><h2 id=\"gone\">Gone</h2><h3 id=\"deep\">D</h3>",
  )
  let problems = check(root, "/b/", [])
  rm_rf(root)
  assert_eq(problems, ["heading docs/x#gone is not in the search index"])
}

///|
test "heading_ids finds h2 and h3 ids only" {
  assert_eq(
    heading_ids(
      "<h1 id=\"a\">x</h1><h2 id=\"b\">x</h2><p>h2 id=\"n\"</p><h3 id=\"c\">",
    ),
    ["b", "c"],
  )
}
