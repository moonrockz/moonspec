///|
test "parse: landing and docs index" {
  assert_eq(Route::parse(""), Landing)
  assert_eq(Route::parse("/"), Landing)
  assert_eq(Route::parse("index.html"), Landing)
  assert_eq(Route::parse("docs"), Doc("getting-started"))
  assert_eq(Route::parse("docs/"), Doc("getting-started"))
}

///|
test "parse: equivalent path shapes give the same route" {
  assert_eq(Route::parse("docs/configuration"), Doc("configuration"))
  assert_eq(Route::parse("/docs/configuration/"), Doc("configuration"))
  assert_eq(Route::parse("docs//configuration"), Doc("configuration"))
  assert_eq(Route::parse("docs/configuration/index.html"), Doc("configuration"))
  assert_eq(Route::parse("migrations/v0.11.0"), Migration("v0.11.0"))
}

///|
test "parse: anything else is not found" {
  assert_eq(Route::parse("docs/a/b"), NotFound("docs/a/b"))
  assert_eq(Route::parse("blog"), NotFound("blog"))
  assert_eq(Route::parse("migrations"), NotFound("migrations"))
}

///|
test "to_path and href" {
  assert_eq(Landing.to_path(), "")
  assert_eq(Doc("configuration").to_path(), "docs/configuration")
  assert_eq(Migration("v0.11.0").to_path(), "migrations/v0.11.0")
  assert_eq(href("/moonspec/", Landing), "/moonspec/")
  assert_eq(
    href("/moonspec/next/", Doc("configuration")),
    "/moonspec/next/docs/configuration/",
  )
  assert_eq(
    href("/moonspec/", Migration("v0.11.0")),
    "/moonspec/migrations/v0.11.0/",
  )
}

///|
test "strip_base: paths inside and outside the base" {
  assert_eq(strip_base("/moonspec/", "/moonspec/docs/x"), Some("docs/x"))
  assert_eq(strip_base("/moonspec/", "moonspec/docs/x"), Some("docs/x"))
  assert_eq(strip_base("/moonspec/next/", "/moonspec/next"), Some(""))
  assert_eq(strip_base("/moonspec/next/", "/moonspec/next/"), Some(""))
  assert_eq(strip_base("/moonspec/next/", "/moonspec/docs/x"), None)
  assert_eq(strip_base("/moonspec/", "/other/docs/x"), None)
  assert_eq(strip_base("/", "/docs/x"), Some("docs/x"))
  assert_eq(strip_base("/moonspec/", "/moonspec/docs/x/"), Some("docs/x/"))
  assert_eq(Route::parse("docs/x/"), Doc("x"))
}

///|
test "routes round-trip through JSON" {
  for r in [Landing, Doc("configuration"), Migration("v0.11.0"), NotFound("x")] {
    let back : Route = @json.from_json(r.to_json())
    assert_eq(back, r)
  }
}
