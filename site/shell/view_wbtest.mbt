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
#cfg(not(target="js"))
async test "the menu button appears only where there is a sidebar" {
  assert_true(!render_route(Landing, None).contains("ms-menu"))
  assert_true(!render_route(Doc("nope"), None).contains("ms-menu"))
  assert_true(
    render_route(Doc("configuration"), Some("# C\n")).contains("ms-menu"),
  )
}

///|
#cfg(not(target="js"))
async test "an open phone menu renders a backdrop" {
  let m = Model::init(site_data(Doc("configuration"), Some("# C\n")))
  assert_true(!render_model(m).contains("ms-sidebar-backdrop"))
  assert_true(
    render_model({ ..m, menu_open: true, }).contains("ms-sidebar-backdrop"),
  )
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

///|
#cfg(not(target="js"))
async test "search dialog, install tabs and heading anchors carry ARIA" {
  let landing = render_route(Landing, None)
  assert_true(landing.contains("role=\"tablist\""))
  assert_true(landing.contains("aria-selected=\"true\""))
  assert_true(landing.contains("aria-selected=\"false\""))
  assert_true(landing.contains("id=\"ms-search-btn\""))
  let docs = render_route(Doc("configuration"), Some("# Configuration\n"))
  assert_true(docs.contains("aria-hidden=\"true\""))
  assert_true(docs.contains("tabindex=\"-1\""))
}

///|
/// Renders the page with the model's state fixed to `m`.
#cfg(not(target="js"))
async fn render_model(m : Model) -> String {
  let json = site_data(m.route, None).encode()
  @rabbita.new(() => {
    let (model, emit) = @rabbita.create_state(m, update~)
    model.map(m => view(m, emit, json))
  }).render(url="http://localhost/moonspec/")
}

///|
#cfg(not(target="js"))
async test "the open search dialog is modal and marks the selection" {
  let m = Model::init(site_data(Landing, None))
  let html = render_model({ ..m, search: { ..m.search, open: true, }, })
  assert_true(html.contains("role=\"dialog\""))
  assert_true(html.contains("aria-modal=\"true\""))
}

///|
#cfg(not(target="js"))
async test "the search modal marks the selected result and the hits" {
  let m = step(searching(), MoveSelection(1))
  let html = render_model(m)
  // One selected item, and it is the second result.
  let first = html.find("ms-search-selected").unwrap()
  assert_true(!html[first + 1:].to_owned().contains("ms-search-selected"))
  assert_true(
    html.contains(
      "href=\"/moonspec/docs/configuration/#two\" target=\"_self\" class=\"ms-search-item ms-search-selected\"",
    ),
  )
  assert_true(html.contains("<mark>needle</mark>"))
  assert_true(html.contains("ms-search-item"))
}

///|
#cfg(not(target="js"))
async test "the next banner appears only on the next channel" {
  let m = Model::init(site_data(Doc("configuration"), Some("# C\n")))
  assert_true(!render_model(m).contains("ms-banner"))
  let next : Model = {
    ..m,
    config: {
      ..m.config,
      channel: Next,
      base: "/moonspec/next/",
      version: "next",
    },
  }
  let html = render_model(next)
  assert_true(html.contains("ms-banner"))
  assert_true(html.contains("docs for main (unreleased)"))
  assert_true(html.contains("Go to the v0.11.0 docs."))
}

///|
#cfg(not(target="js"))
async test "the version picker marks the current version" {
  let m = Model::init(site_data(Doc("configuration"), Some("# C\n")))
  let release = render_model(m)
  assert_true(release.contains("ms-version-link ms-version-current"))
  assert_true(
    release.contains("class=\"ms-version-link ms-version-current\">v0.11.0</a>"),
  )
  assert_true(!release.contains("ms-version-current\">next"))
  let next = render_model({
    ..m,
    config: { ..m.config, channel: Next, base: "/moonspec/next/", },
  })
  assert_true(
    next.contains(
      "href=\"/moonspec/next/docs/configuration/\" target=\"_self\" class=\"ms-version-link ms-version-current\">next</a>",
    ),
  )
}

///|
#cfg(not(target="js"))
async test "loading and failed pages render their texts" {
  let m = Model::init(site_data(Doc("configuration"), None))
  assert_true(render_model(m).contains("Loading…"))
  let failed = render_model({ ..m, page: PageFailed, })
  assert_true(failed.contains("This page could not be loaded."))
  assert_true(failed.contains("Read it on GitHub"))
}

///|
#cfg(not(target="js"))
async test "the moonx install tab shows the moonx commands" {
  let m = Model::init(site_data(Landing, None))
  assert_true(
    !render_model(m).contains("moonx moonrockz/moonspec/cmd/moonspec@latest"),
  )
  let html = render_model({ ..m, install_tab: Moonx, })
  assert_true(
    html.contains("moonx moonrockz/moonspec/cmd/moonspec@latest gen steps"),
  )
}
