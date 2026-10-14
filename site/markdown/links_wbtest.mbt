///|
fn site_ctx(source : String) -> LinkContext {
  {
    source,
    resolve: path => {
      match path {
        "docs/guide/step-definitions.md" => Some(Doc("step-definitions"))
        "docs/guide/configuration.md" => Some(Doc("configuration"))
        "docs/migrations/v0.11.0.md" => Some(Migration("v0.11.0"))
        _ => None
      }
    },
    repo_url: "https://github.com/moonrockz/moonspec",
    git_ref: "v0.11.0",
  }
}

///|
test "resolve_path normalizes relative paths" {
  assert_eq(resolve_path("docs/guide/a.md", "b.md"), "docs/guide/b.md")
  assert_eq(resolve_path("docs/guide/a.md", "./b.md"), "docs/guide/b.md")
  assert_eq(
    resolve_path("docs/migrations/v0.11.0.md", "../guide/step-definitions.md"),
    "docs/guide/step-definitions.md",
  )
  assert_eq(resolve_path("docs/guide/a.md", "../../README.md"), "README.md")
  assert_eq(resolve_path("docs/guide/a.md", "../../../x.md"), "x.md")
  assert_eq(resolve_path("", "docs/guide/a.md"), "docs/guide/a.md")
}

///|
test "links to published pages become site routes" {
  let ctx = site_ctx("docs/guide/getting-started.md")
  assert_eq(
    rewrite_link("step-definitions.md", ctx),
    Internal(Doc("step-definitions"), None),
  )
  assert_eq(
    rewrite_link("step-definitions.md#supported-types", ctx),
    Internal(Doc("step-definitions"), Some("supported-types")),
  )
  assert_eq(
    rewrite_link("./configuration.md", ctx),
    Internal(Doc("configuration"), None),
  )
  assert_eq(
    rewrite_link("../migrations/v0.11.0.md", ctx),
    Internal(Migration("v0.11.0"), None),
  )
  assert_eq(
    rewrite_link("/docs/guide/configuration.md#steps-object", ctx),
    Internal(Doc("configuration"), Some("steps-object")),
  )
}

///|
test "anchors and absolute URLs stay as they are" {
  let ctx = site_ctx("docs/guide/getting-started.md")
  assert_eq(rewrite_link("#codegen-mode", ctx), Anchor("codegen-mode"))
  assert_eq(
    rewrite_link("https://mooncakes.io/", ctx),
    External("https://mooncakes.io/"),
  )
  assert_eq(rewrite_link("mailto:a@b.c", ctx), External("mailto:a@b.c"))
}

///|
test "other repository files become GitHub links at the build ref" {
  let ctx = site_ctx("docs/guide/getting-started.md")
  assert_eq(
    rewrite_link("../plans/2026-10-13-site-design.md", ctx),
    External(
      "https://github.com/moonrockz/moonspec/blob/v0.11.0/docs/plans/2026-10-13-site-design.md",
    ),
  )
  assert_eq(
    rewrite_link("../../README.md#cli", ctx),
    External("https://github.com/moonrockz/moonspec/blob/v0.11.0/README.md#cli"),
  )
  assert_eq(
    rewrite_link("../../examples/todolist/", ctx),
    External(
      "https://github.com/moonrockz/moonspec/tree/v0.11.0/examples/todolist",
    ),
  )
  assert_eq(
    rewrite_link("unpublished.md", ctx),
    External(
      "https://github.com/moonrockz/moonspec/blob/v0.11.0/docs/guide/unpublished.md",
    ),
  )
}

///|
test "relative images load from raw GitHub" {
  let ctx = site_ctx("docs/guide/getting-started.md")
  assert_eq(
    image_src("img/flow.png", ctx),
    "https://raw.githubusercontent.com/moonrockz/moonspec/v0.11.0/docs/guide/img/flow.png",
  )
  assert_eq(
    image_src("https://example.com/a.png", ctx),
    "https://example.com/a.png",
  )
  assert_eq(
    image_src("data:image/png;base64,AAA", ctx),
    "data:image/png;base64,AAA",
  )
  assert_eq(image_src("javascript:alert(1)", ctx), "")
}

///|
test "parse applies link rewriting" {
  let doc = parse(
    "See [steps](step-definitions.md#x).",
    site_ctx("docs/guide/getting-started.md"),
  )
  assert_eq(doc.blocks, [
    Paragraph([
      Text("See "),
      Link(Internal(Doc("step-definitions"), Some("x")), [Text("steps")]),
      Text("."),
    ]),
  ])
}
