///|
/// `App::render` exists only on native; these tests skip the JS target.
#cfg(not(target="js"))
async fn render_route(route : @route.Route, markdown : String?) -> String {
  let data = site_data(route, markdown)
  let json = data.encode()
  @rabbita.new(() => component(data, json)).render(
    url="http://localhost" + @route.href(data.config.base, route),
  )
}

///|
#cfg(not(target="js"))
async test "landing page renders hero, tiles and install tabs" {
  let html = render_route(Landing, None)
  assert_true(html.contains("BDD test framework for MoonBit"))
  assert_true(html.contains("Why moonspec"))
  assert_true(html.contains("moon install moonrockz/moonspec/cmd/moonspec"))
  assert_true(html.contains("name=\"ms-data\""))
  assert_true(html.contains("/moonspec/index.js"))
}

///|
#cfg(not(target="js"))
async test "docs page renders sidebar, article, toc and edit link" {
  let md = "# Configuration\n\n## Config File\n\nSee [start](getting-started.md).\n\n```moonbit\nlet x = 1\n```\n"
  let html = render_route(Doc("configuration"), Some(md))
  assert_true(html.contains("Getting Started"))
  assert_true(html.contains("id=\"config-file\""))
  assert_true(html.contains("href=\"/moonspec/docs/getting-started/\""))
  assert_true(html.contains("On this page"))
  assert_true(html.contains("edit/main/docs/guide/configuration.md"))
  assert_true(html.contains("tk-kw"))
}

///|
#cfg(not(target="js"))
async test "unknown pages render the not-found view" {
  let html = render_route(Doc("nope"), None)
  assert_true(html.contains("Page not found"))
  assert_true(html.contains("This page does not exist."))
  assert_true(html.contains("Docs (next)"))
  assert_true(html.contains("href=\"/moonspec/next/docs/"))
  assert_true(html.contains("href=\"/moonspec/docs/"))
  assert_true(!html.contains("does not exist in"))
}

///|
test "target_href" {
  assert_eq(
    target_href("/moonspec/", Internal(Doc("x"), Some("a"))),
    "/moonspec/docs/x/#a",
  )
  assert_eq(target_href("/moonspec/", Anchor("a")), "#a")
  assert_eq(
    target_href("/moonspec/", External("https://e.com")),
    "https://e.com",
  )
}

///|
#cfg(not(target="js"))
async test "head starts with the stored-theme script" {
  let html = render_route(Landing, None)
  let head = html.find("<head>").unwrap()
  let script = html.find("localStorage.getItem('moonspec-theme')").unwrap()
  let css = html.find("styles.css").unwrap()
  assert_true(head < script && script < css)
  assert_true(html.contains("dataset.theme"))
}

///|
#cfg(not(target="js"))
async test "initial_theme sets the theme attribute on the first render" {
  let data = site_data(Landing, None)
  let html = @rabbita.new(() => {
    component(data, data.encode(), initial_theme=Dark)
  }).render(url="http://localhost/moonspec/")
  assert_true(html.contains("data-theme=\"dark\""))
}
