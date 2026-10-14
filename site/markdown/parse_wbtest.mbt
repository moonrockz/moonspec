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
