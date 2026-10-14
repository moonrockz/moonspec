///|
fn plain_ctx(source : String) -> LinkContext {
  {
    source,
    resolve: _ => None,
    repo_url: "https://github.com/moonrockz/moonspec",
    git_ref: "v0.11.0",
  }
}

///|
test "title, toc levels and block kinds" {
  let src =
    #|# Configuration Reference
    #|
    #|Intro *text* and `code`.
    #|
    #|## Config File
    #|
    #|### `test_kind` (string)
    #|
    #|#### Deep heading
    #|
    #|```json5
    #|{ "world": "W" }
    #|```
    #|
    #|- one
    #|- two
    #|
    #|3. three
    #|
    #|> quoted
    #|
    #|---
  let doc = parse(src, plain_ctx("docs/guide/configuration.md"))
  assert_eq(doc.title, "Configuration Reference")
  assert_eq(doc.toc, [
    { level: 2, id: "config-file", text: "Config File", },
    { level: 3, id: "test_kind-string", text: "test_kind (string)", },
  ])
  assert_eq(
    doc.blocks[1],
    Paragraph([
      Text("Intro "),
      Emph([Text("text")]),
      Text(" and "),
      Code("code"),
      Text("."),
    ]),
  )
  assert_true(doc.blocks.contains(CodeBlock("json5", "{ \"world\": \"W\" }")))
  assert_true(
    doc.blocks.contains(
      BulletList([[Paragraph([Text("one")])], [Paragraph([Text("two")])]]),
    ),
  )
  assert_true(
    doc.blocks.contains(OrderedList(3, [[Paragraph([Text("three")])]])),
  )
  assert_true(doc.blocks.contains(Quote([Paragraph([Text("quoted")])])))
  assert_true(doc.blocks.contains(Rule))
}

///|
test "duplicate headings get unique ids, GitHub style" {
  let src = "# T\n\n## Example\n\na\n\n## Example\n\nb\n\n## Example\n"
  let doc = parse(src, plain_ctx("docs/guide/x.md"))
  assert_eq(doc.toc.map(e => e.id), ["example", "example-1", "example-2"])
  let ids : Array[String] = []
  for b in doc.blocks {
    match b {
      Heading(2, id, _) => ids.push(id)
      _ => ()
    }
  }
  assert_eq(ids, ["example", "example-1", "example-2"])
}

///|
test "tables become header cells and rows" {
  let src = "| A | B |\n|---|---|\n| 1 | `x` |\n"
  let doc = parse(src, plain_ctx("docs/guide/x.md"))
  assert_eq(doc.blocks, [
    Table([[Text("A")], [Text("B")]], [[[Text("1")], [Code("x")]]]),
  ])
}

///|
test "inline_text and block_text flatten content" {
  assert_eq(inline_text([Text("a "), Strong([Text("b")]), Code(" c")]), "a b c")
  assert_eq(
    block_text(BulletList([[Paragraph([Text("x")])], [Paragraph([Text("y")])]])),
    "x y",
  )
  assert_eq(title_of("intro\n\n# Real Title\n"), "Real Title")
  assert_eq(title_of("no heading"), "")
}

///|
fn para(src : String) -> Array[Inline] {
  let doc = parse(src, site_ctx("docs/guide/getting-started.md"))
  match doc.blocks {
    [Paragraph(inlines)] => inlines
    _ => []
  }
}

///|
test "autolinks" {
  assert_eq(para("<https://e.com>"), [
    Link(External("https://e.com"), [Text("https://e.com")]),
  ])
  assert_eq(para("<a@b.c>"), [Link(External("mailto:a@b.c"), [Text("a@b.c")])])
}

///|
test "two trailing spaces make a hard break" {
  assert_eq(para("a  \nb"), [Text("a"), LineBreak, Text("b")])
}

///|
test "images use the raw GitHub URL" {
  assert_eq(para("![alt](img/a.png)"), [
    Image(
      "https://raw.githubusercontent.com/moonrockz/moonspec/v0.11.0/docs/guide/img/a.png",
      "alt",
    ),
  ])
}

///|
test "reference links resolve to site routes" {
  let doc = parse(
    "[x][r]\n\n[r]: step-definitions.md\n",
    site_ctx("docs/guide/getting-started.md"),
  )
  assert_eq(doc.blocks, [
    Paragraph([Link(Internal(Doc("step-definitions"), None), [Text("x")])]),
  ])
}

///|
test "strikethrough" {
  assert_eq(para("~~a~~"), [Strike([Text("a")])])
}

///|
test "nested lists" {
  let doc = parse("- a\n  - b\n", site_ctx("docs/guide/getting-started.md"))
  assert_eq(doc.blocks, [
    BulletList([
      [Paragraph([Text("a")]), BulletList([[Paragraph([Text("b")])]])],
    ]),
  ])
}

///|
test "the first of two h1 headings is the title" {
  let doc = parse("# One\n\n# Two\n", site_ctx("docs/guide/getting-started.md"))
  assert_eq(doc.title, "One")
}

///|
test "rewrite_link: empty and bare-hash destinations" {
  let ctx = site_ctx("docs/guide/getting-started.md")
  assert_eq(
    rewrite_link("", ctx),
    External("https://github.com/moonrockz/moonspec/tree/v0.11.0/docs/guide"),
  )
  assert_eq(rewrite_link("#", ctx), Anchor(""))
}

///|
test "rewrite_link: tel and protocol-relative links are external, data links are not" {
  let ctx = site_ctx("docs/guide/getting-started.md")
  assert_eq(rewrite_link("tel:+123", ctx), External("tel:+123"))
  assert_eq(rewrite_link("//host/x", ctx), External("//host/x"))
  assert_eq(rewrite_link("data:image/png;base64,AAA", ctx), External("#"))
}

///|
test "rewrite_link: javascript links are never clickable" {
  let ctx = site_ctx("docs/guide/getting-started.md")
  assert_eq(rewrite_link("javascript:alert(1)", ctx), External("#"))
  assert_eq(rewrite_link("JavaScript:alert(1)", ctx), External("#"))
  assert_eq(rewrite_link("vbscript:x", ctx), External("#"))
  assert_eq(rewrite_link("data:text/html,hi", ctx), External("#"))
  assert_eq(rewrite_link("file:///etc/passwd", ctx), External("#"))
  assert_eq(rewrite_link("HTTPS://e.com", ctx), External("HTTPS://e.com"))
}

///|
test "autolinks and inline links never emit a script href" {
  assert_eq(para("<javascript:alert(1)>"), [
    Link(External("#"), [Text("javascript:alert(1)")]),
  ])
  assert_eq(para("<JavaScript:alert(1)>"), [
    Link(External("#"), [Text("JavaScript:alert(1)")]),
  ])
  assert_eq(para("[x](vbscript:x)"), [Link(External("#"), [Text("x")])])
  assert_eq(para("[x](data:text/html,hi)"), [Link(External("#"), [Text("x")])])
  assert_eq(para("[x]( javascript:alert(1))"), [
    Link(External("#"), [Text("x")]),
  ])
}

///|
test "a tab inside a scheme is not a scheme" {
  let ctx = site_ctx("docs/guide/getting-started.md")
  assert_eq(
    rewrite_link("java\tscript:alert(1)", ctx),
    External(
      "https://github.com/moonrockz/moonspec/tree/v0.11.0/docs/guide/java\tscript:alert(1)",
    ),
  )
}

///|
test "rewrite_link: paths and anchors that only look like schemes stay relative" {
  let ctx = site_ctx("docs/guide/getting-started.md")
  assert_eq(
    rewrite_link("a.md#x://y", ctx),
    External(
      "https://github.com/moonrockz/moonspec/blob/v0.11.0/docs/guide/a.md#x://y",
    ),
  )
  assert_eq(
    rewrite_link("./a.md", ctx),
    External(
      "https://github.com/moonrockz/moonspec/blob/v0.11.0/docs/guide/a.md",
    ),
  )
}
