///|
fn ctx() -> @markdown.LinkContext {
  {
    source: "docs/guide/x.md",
    resolve: _ => None,
    repo_url: "https://github.com/moonrockz/moonspec",
    git_ref: "main",
  }
}

///|
fn config_doc() -> @markdown.Document {
  @markdown.parse(
    "# Configuration\n\nIntro words.\n\n## Config Fields\n\nFields list.\n\n### `test_kind` (string)\n\nThe kind of test file.\n\n#### Detail\n\nDeep text.\n\n## CLI Flags\n\n`--test-kind` flag.\n",
    ctx(),
  )
}

///|
test "entries_for splits a page at h2 and h3" {
  let entries = entries_for("Configuration", Doc("configuration"), config_doc())
  assert_eq(entries.map(e => e.anchor), [
    "", "config-fields", "test_kind-string", "cli-flags",
  ])
  assert_eq(entries[0].path, [])
  assert_eq(entries[0].text, "Intro words.")
  assert_eq(entries[2].path, ["Config Fields", "test_kind (string)"])
  assert_eq(entries[2].text, "The kind of test file. Detail Deep text.")
  assert_eq(entries[3].path, ["CLI Flags"])
}

///|
test "tokenize lowercases and splits on punctuation, _ and -" {
  assert_eq(tokenize("test_kind (string)"), ["test", "kind", "string"])
  assert_eq(tokenize("--test-kind"), ["test", "kind"])
  assert_eq(tokenize("Ünïcode & Co."), ["ünïcode", "co"])
  assert_eq(tokenize(""), [])
  assert_eq(tokenize("   "), [])
  assert_eq(tokenize("--"), [])
}

///|
fn index() -> Index {
  let doc = config_doc()
  let other = @markdown.parse(
    "# Testing Strategies\n\n## Tags\n\nUse a tag filter.\n",
    ctx(),
  )
  Index::new(
    [
      ..entries_for("Configuration", Doc("configuration"), doc),
      ..entries_for("Testing Strategies", Doc("testing-strategies"), other),
    ],
  )
}

///|
test "empty and punctuation-only queries return nothing" {
  assert_eq(search(index(), ""), [])
  assert_eq(search(index(), "   "), [])
  assert_eq(search(index(), "--"), [])
}

///|
test "headings outrank text; all terms outrank some terms" {
  let hits = search(index(), "test kind")
  assert_eq(hits[0].entry.anchor, "test_kind-string")
  assert_true(hits.length() >= 2)
  assert_true(hits.all(h => h.score > 0))
}

///|
test "prefix and case-insensitive matching" {
  let hits = search(index(), "CONF")
  assert_eq(hits[0].entry.page, "Configuration")
  assert_eq(search(index(), "zzz"), [])
}

///|
test "limit caps the result count" {
  assert_eq(search(index(), "test", limit=1).length(), 1)
}

///|
test "excerpt marks matched terms" {
  assert_eq(excerpt("The kind of test file.", ["test", "kind"]), [
    Plain("The "),
    Hit("kind"),
    Plain(" of "),
    Hit("test"),
    Plain(" file."),
  ])
  assert_eq(excerpt("no match here", ["zzz"]), [Plain("no match here")])
}

///|
test "group_by_page keeps first-seen page order" {
  let groups = group_by_page(search(index(), "test"))
  assert_true(groups.length() == 2)
  assert_true(groups.all(g => g.1.length() > 0))
}

///|
test "entries round-trip through JSON" {
  let entries = entries_for("Configuration", Doc("configuration"), config_doc())
  let back : Array[Entry] = @json.from_json(Json(entries))
  assert_eq(back, entries)
}
