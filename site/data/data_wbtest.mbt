///|
fn sample() -> SiteData {
  {
    config: {
      base: "/moonspec/next/",
      version: "next",
      channel: Next,
      git_ref: "abc123",
      release_base: "/moonspec/",
      next_base: "/moonspec/next/",
      release_version: "v0.11.0",
    },
    pages: [
      {
        route: Doc("configuration"),
        title: "Configuration",
        source: "docs/guide/configuration.md",
        group: Guides,
      },
    ],
    route: Doc("configuration"),
    markdown: Some("# Configuration\n\nQuote \" < > & </script> done\n"),
  }
}

///|
test "encode and decode round-trip, including HTML-special text" {
  let data = sample()
  assert_eq(SiteData::decode(data.encode()), Some(data))
}

///|
test "decode rejects invalid input" {
  assert_eq(SiteData::decode(""), None)
  assert_eq(SiteData::decode("{\"config\": 1}"), None)
}

///|
test "link_context resolves published sources only" {
  let data = sample()
  let ctx = link_context(
    data.config,
    data.manifest(),
    "docs/guide/getting-started.md",
  )
  assert_eq(
    (ctx.resolve)("docs/guide/configuration.md"),
    Some(Doc("configuration")),
  )
  assert_eq((ctx.resolve)("docs/plans/x.md"), None)
  assert_eq(ctx.git_ref, "abc123")
  assert_eq(ctx.repo_url, github_repo)
}
