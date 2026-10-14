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
