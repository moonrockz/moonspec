///|
test "classify: only guides and migrations are published" {
  assert_eq(
    classify("docs/guide/configuration.md"),
    Some((Doc("configuration"), Guides)),
  )
  assert_eq(
    classify("./docs/guide/configuration.md"),
    Some((Doc("configuration"), Guides)),
  )
  assert_eq(
    classify("docs/migrations/v0.11.0.md"),
    Some((Migration("v0.11.0"), Migrations)),
  )
  assert_eq(classify("docs/plans/2026-10-13-site-design.md"), None)
  assert_eq(classify("README.md"), None)
  assert_eq(classify("docs/guide/nested/x.md"), None)
  assert_eq(classify("docs/guide/Bad Name.md"), None)
  assert_eq(classify("docs/guide/configuration.txt"), None)
  assert_eq(classify("docs/migrations/latest.md"), None)
}

///|
test "compare_versions orders numerically" {
  assert_true(compare_versions("v0.9.0", "v0.11.0") < 0)
  assert_true(compare_versions("v1.0.0", "v0.11.0") > 0)
  assert_eq(compare_versions("v0.11.0", "v0.11.0"), 0)
}

///|
fn sample_files() -> Array[SourceFile] {
  [
    { path: "docs/migrations/v0.9.0.md", title: "To 0.9", },
    { path: "docs/guide/configuration.md", title: "Configuration Reference", },
    { path: "docs/plans/secret-design.md", title: "Secret", },
    { path: "docs/guide/zzz-extra.md", title: "Extra", },
    { path: "docs/guide/getting-started.md", title: "Getting Started", },
    { path: "docs/migrations/v0.11.0.md", title: "To 0.11", },
  ]
}

///|
test "build: guides in fixed order, then migrations newest first" {
  let m = Manifest::build(sample_files())
  assert_eq(m.pages.map(p => p.route), [
    Doc("getting-started"),
    Doc("configuration"),
    Doc("zzz-extra"),
    Migration("v0.11.0"),
    Migration("v0.9.0"),
  ])
  assert_eq(m.pages[0].title, "Getting Started")
  assert_eq(m.pages[0].source, "docs/guide/getting-started.md")
}

///|
test "build: a tree without migrations still builds" {
  let m = Manifest::build([
    { path: "docs/guide/getting-started.md", title: "Start", },
  ])
  assert_eq(m.pages.length(), 1)
  assert_eq(m.find(Migration("v0.11.0")), None)
}

///|
test "find, find_source and neighbors" {
  let m = Manifest::build(sample_files())
  assert_eq(
    m.find(Doc("configuration")).map(p => p.title),
    Some("Configuration Reference"),
  )
  assert_eq(m.find(Doc("nope")), None)
  assert_eq(
    m.find_source("./docs/guide/configuration.md").map(p => p.route),
    Some(Doc("configuration")),
  )
  assert_eq(m.find_source("docs/plans/secret-design.md"), None)
  let (prev, next) = m.neighbors(Doc("configuration"))
  assert_eq(prev.map(p => p.route), Some(Doc("getting-started")))
  assert_eq(next.map(p => p.route), Some(Doc("zzz-extra")))
  let (first_prev, _) = m.neighbors(Doc("getting-started"))
  assert_eq(first_prev, None)
  let (_, last_next) = m.neighbors(Migration("v0.9.0"))
  assert_eq(last_next, None)
}
