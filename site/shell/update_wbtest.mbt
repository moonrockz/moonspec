///|
fn noop_emit() -> @rabbita.Emit[Msg] {
  @cmd.Emit(_ => @rabbita.none)
}

///|
fn site_data(route : @route.Route, markdown : String?) -> @data.SiteData {
  {
    config: {
      base: "/moonspec/",
      version: "v0.11.0",
      channel: Release,
      git_ref: "v0.11.0",
      release_base: "/moonspec/",
      next_base: "/moonspec/next/",
      release_version: "v0.11.0",
    },
    pages: [
      {
        route: Doc("getting-started"),
        title: "Getting Started",
        source: "docs/guide/getting-started.md",
        group: Guides,
      },
      {
        route: Doc("configuration"),
        title: "Configuration",
        source: "docs/guide/configuration.md",
        group: Guides,
      },
    ],
    counterpart_routes: [Doc("getting-started"), Doc("configuration")],
    route,
    markdown,
  }
}

///|
fn step(m : Model, msg : Msg) -> Model {
  update(m, msg, noop_emit()).0
}

///|
test "init parses the current page" {
  let m = Model::init(
    site_data(Doc("configuration"), Some("# Configuration\n\n## A\n")),
  )
  match m.page {
    Ready(doc) => assert_eq(doc.title, "Configuration")
    _ => fail("expected a ready page")
  }
  assert_eq(Model::init(site_data(Landing, None)).page, NoContent)
}

///|
test "url changes inside the base switch routes" {
  let m = Model::init(site_data(Landing, None))
  let m2 = step(
    m,
    UrlChanged(@url.parse("http://localhost/moonspec/docs/configuration")),
  )
  assert_eq(m2.route, Doc("configuration"))
  assert_eq(m2.page, Loading)
  let m3 = step(
    m2,
    ContentLoaded(Doc("configuration"), Ok("# Configuration\n")),
  )
  assert_true(m3.page is Ready(_))
}

///|
test "url changes with a trailing slash switch routes" {
  let m = Model::init(site_data(Landing, None))
  let m2 = step(
    m,
    UrlChanged(@url.parse("http://localhost/moonspec/docs/configuration/")),
  )
  assert_eq(m2.route, Doc("configuration"))
  let config = m.config
  assert_eq(
    site_path(config, "/moonspec/docs/configuration/"),
    Some("docs/configuration/"),
  )
  assert_eq(site_path(config, "/moonspec/next/docs/x/"), None)
}

///|
test "url changes outside the base are ignored" {
  let m = Model::init(site_data(Landing, None))
  let m2 = step(
    m,
    UrlChanged(@url.parse("http://localhost/moonspec/next/docs/configuration")),
  )
  assert_eq(m2.route, Landing)
}

///|
test "unknown pages have no content" {
  let m = Model::init(site_data(Landing, None))
  let m2 = step(
    m,
    UrlChanged(@url.parse("http://localhost/moonspec/docs/nope")),
  )
  assert_eq(m2.route, Doc("nope"))
  assert_eq(m2.page, NoContent)
}

///|
test "stale content for another route is dropped" {
  let m = Model::init(
    site_data(Doc("configuration"), Some("# Configuration\n")),
  )
  let m2 = step(m, ContentLoaded(Doc("getting-started"), Ok("# Other\n")))
  assert_eq(m2.page, m.page)
}

///|
test "search opens, filters and closes" {
  let m = Model::init(site_data(Landing, None))
  let opened = step(m, OpenSearch)
  assert_true(opened.search.open)
  assert_eq(opened.search.index, LoadingIndex)
  let entries : Array[@search.Entry] = [
    {
      route: Doc("configuration"),
      anchor: "test_kind-string",
      page: "Configuration",
      path: ["test_kind (string)"],
      text: "kind of test file",
    },
  ]
  let ready = step(opened, IndexLoaded(Ok(Json(entries).stringify())))
  assert_true(ready.search.index is IndexReady(_))
  let typed = step(ready, SearchInput("test kind"))
  assert_eq(current_results(typed).length(), 1)
  let closed = step(typed, CloseSearch)
  assert_false(closed.search.open)
}

///|
test "a broken index shows the failure state" {
  let m = step(Model::init(site_data(Landing, None)), OpenSearch)
  assert_eq(step(m, IndexLoaded(Ok("not json"))).search.index, IndexFailed)
}

///|
test "selection stays within the results" {
  let m = Model::init(site_data(Landing, None))
  let moved = step(step(m, OpenSearch), MoveSelection(5))
  assert_eq(moved.search.selected, 0)
}

///|
test "theme cycles auto, dark, light" {
  let m = Model::init(site_data(Landing, None))
  assert_eq(step(m, ToggleTheme).theme, Dark)
  assert_eq(step(step(m, ToggleTheme), ToggleTheme).theme, Light)
  assert_eq(
    step(step(step(m, ToggleTheme), ToggleTheme), ToggleTheme).theme,
    Auto,
  )
  assert_eq(Theme::parse("dark"), Dark)
  assert_eq(Theme::parse("bogus"), Auto)
}

///|
test "entry_href builds route and anchor" {
  let config = site_data(Landing, None).config
  let e : @search.Entry = {
    route: Doc("configuration"),
    anchor: "a-b",
    page: "C",
    path: [],
    text: "",
  }
  assert_eq(entry_href(config, e), "/moonspec/docs/configuration/#a-b")
  assert_eq(
    entry_href(config, { ..e, anchor: "", }),
    "/moonspec/docs/configuration/",
  )
}

///|
test "a fragment waits for the content of another page" {
  let m = Model::init(site_data(Landing, None))
  let m2 = step(
    m,
    UrlChanged(
      @url.parse("http://localhost/moonspec/docs/configuration#test_kind"),
    ),
  )
  assert_eq(m2.page, Loading)
  assert_eq(m2.pending_anchor, Some("test_kind"))
  let m3 = step(
    m2,
    ContentLoaded(Doc("configuration"), Ok("# Configuration\n")),
  )
  assert_true(m3.page is Ready(_))
  assert_eq(m3.pending_anchor, None)
}

///|
test "no fragment leaves nothing pending" {
  let m = Model::init(site_data(Landing, None))
  let m2 = step(
    m,
    UrlChanged(@url.parse("http://localhost/moonspec/docs/configuration")),
  )
  assert_eq(m2.pending_anchor, None)
}

///|
test "a same-page fragment scrolls at once and stays unpended" {
  let m = Model::init(
    site_data(Doc("configuration"), Some("# Configuration\n")),
  )
  let m2 = step(
    m,
    UrlChanged(@url.parse("http://localhost/moonspec/docs/configuration#a")),
  )
  assert_eq(m2.pending_anchor, None)
  assert_eq(m2.page, m.page)
}

///|
fn key(k : String, meta~ : Bool = false) -> Msg {
  KeyDown(
    @common.Keyboard::new(
      key=k,
      code="",
      alt_key=false,
      ctrl_key=false,
      shift_key=false,
      meta_key=meta,
      is_composing=false,
      repeat=false,
      location=0,
    ),
  )
}

///|
fn three_entries() -> Array[@search.Entry] {
  ["one", "two", "three"].map(a => {
    route: Doc("configuration"),
    anchor: a,
    page: "Configuration",
    path: [a],
    text: "needle in " + a,
  })
}

///|
/// A model with the search open, the index ready and three results for "needle".
fn searching() -> Model {
  let m = step(Model::init(site_data(Landing, None)), OpenSearch)
  let ready = step(m, IndexLoaded(Ok(Json(three_entries()).stringify())))
  step(ready, SearchInput("needle"))
}

///|
test "internal link requests inside the base keep the model" {
  let m = Model::init(site_data(Landing, None))
  let req = UrlRequested(
    Internal(@url.parse("http://localhost/moonspec/docs/configuration/")),
  )
  assert_eq(step(m, req), m)
}

///|
test "link requests into the other channel keep the model" {
  let m = Model::init(site_data(Landing, None))
  let req = UrlRequested(
    Internal(@url.parse("http://localhost/moonspec/next/docs/configuration/")),
  )
  assert_eq(step(m, req), m)
  assert_eq(step(m, req).route, Landing)
}

///|
test "ctrl or meta K and slash open search" {
  let m = Model::init(site_data(Landing, None))
  assert_true(step(m, key("k", meta=true)).search.open)
  assert_true(step(m, key("/")).search.open)
  assert_false(step(m, key("k")).search.open)
}

///|
test "Escape closes search" {
  let opened = step(Model::init(site_data(Landing, None)), key("/"))
  assert_true(opened.search.open)
  assert_false(step(opened, key("Escape")).search.open)
}

///|
test "MoveSelection wraps around the results" {
  let m = searching()
  assert_eq(flat_results(m).length(), 3)
  assert_eq(m.search.selected, 0)
  assert_eq(step(m, MoveSelection(-1)).search.selected, 2)
  assert_eq(
    step(step(m, MoveSelection(-1)), MoveSelection(1)).search.selected,
    0,
  )
  assert_eq(step(m, MoveSelection(1)).search.selected, 1)
}

///|
test "OpenSelected closes search" {
  let m = searching()
  assert_true(m.search.open)
  assert_false(step(m, OpenSelected).search.open)
}

///|
test "failed loads set the failure states" {
  let m = Model::init(site_data(Doc("configuration"), None))
  assert_eq(m.page, Loading)
  assert_eq(
    step(m, ContentLoaded(Doc("configuration"), Err(Failure("x")))).page,
    PageFailed,
  )
  let s = step(m, OpenSearch)
  assert_eq(step(s, IndexLoaded(Err(Failure("x")))).search.index, IndexFailed)
}

///|
test "a same-route fragment change keeps the page ready" {
  let m = Model::init(
    site_data(Doc("configuration"), Some("# Configuration\n\n## A\n")),
  )
  let m2 = step(
    m,
    UrlChanged(@url.parse("http://localhost/moonspec/docs/configuration/#a")),
  )
  assert_true(m2.page is Ready(_))
  assert_eq(m2.page, m.page)
  assert_eq(m2.route, m.route)
}

///|
test "Escape closes the phone menu when search is closed" {
  let m = { ..Model::init(site_data(Landing, None)), menu_open: true, }
  assert_false(step(m, key("Escape")).menu_open)
  // Other keys leave the menu alone.
  assert_true(step(m, key("x")).menu_open)
}

///|
test "opening search closes the phone menu" {
  let m = { ..Model::init(site_data(Landing, None)), menu_open: true, }
  let s = step(m, OpenSearch)
  assert_true(s.search.open)
  assert_false(s.menu_open)
  assert_false(step(m, key("/")).menu_open)
}

///|
test "hydrated counterpart routes remain valid after client navigation" {
  let source = site_data(Doc("configuration"), Some("# Configuration\n"))
  let data : @data.SiteData = {
    ..source,
    config: { ..source.config, channel: Next, base: "/moonspec/next/", },
    pages: [
      ..source.pages,
      {
        route: Doc("next-only"),
        title: "Next only",
        source: "docs/guide/next-only.md",
        group: Guides,
      },
    ],
  }
  let m = Model::init(@data.SiteData::decode(data.encode()).unwrap())
  assert_eq(version_href(m, Release, m.route), "/moonspec/docs/configuration/")
  let navigated = step(
    m,
    UrlChanged(@url.parse("http://localhost/moonspec/next/docs/next-only/")),
  )
  assert_eq(version_href(navigated, Release, navigated.route), "/moonspec/")
  assert_eq(
    version_href(navigated, Next, navigated.route),
    "/moonspec/next/docs/next-only/",
  )
}

///|
test "version links handle migrations missing routes and alternate bases" {
  let data = site_data(Landing, None)
  let source = Model::init({
    ..data,
    counterpart_routes: [Migration("v0.11.0")],
  })
  let m = {
    ..source,
    config: {
      ..source.config,
      base: "/",
      release_base: "/",
      next_base: "/next/",
    },
  }
  assert_eq(
    version_href(m, Next, Migration("v0.11.0")),
    "/next/migrations/v0.11.0/",
  )
  assert_eq(version_href(m, Next, Migration("v0.10.0")), "/next/")
  assert_eq(version_href(m, Release, Doc("missing")), "/")
  assert_eq(version_href(m, Next, NotFound("missing")), "/next/")
  assert_eq(version_href(m, Release, Landing), "/")
  assert_eq(version_href(m, Next, Landing), "/next/")
}
