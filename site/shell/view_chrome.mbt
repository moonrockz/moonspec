///|
fn class_if(base : String, extra : String, on : Bool) -> String {
  if on {
    base + " " + extra
  } else {
    base
  }
}

///|
fn theme_icon(theme : Theme) -> String {
  match theme {
    Auto => "◐"
    Dark => "☾"
    Light => "☀"
  }
}

///|
fn version_href(
  m : Model,
  channel : @data.Channel,
  route : @route.Route,
) -> String {
  let published = if channel == m.config.channel {
    m.manifest.find(route) is Some(_)
  } else {
    m.counterpart_routes.contains(route)
  }
  let destination = match route {
    Landing | NotFound(_) => @route.Landing
    _ if published => route
    _ => @route.Landing
  }
  let base = match channel {
    Release => m.config.release_base
    Next => m.config.next_base
  }
  @route.href(base, destination)
}

///|
fn version_picker(m : Model) -> Html {
  let c = m.config
  @html.div(class="ms-version", [
    @html.a(
      class=class_if(
        "ms-version-link",
        "ms-version-current",
        c.channel == Release,
      ),
      href=version_href(m, Release, m.route),
      c.release_version,
    ),
    @html.a(
      class=class_if("ms-version-link", "ms-version-current", c.channel == Next),
      href=version_href(m, Next, m.route),
      "next",
    ),
  ])
}

///|
/// Only documentation pages have a sidebar for the phone menu to open.
fn has_sidebar(m : Model) -> Bool {
  match (m.route, m.manifest.find(m.route)) {
    (Landing, _) | (_, None) => false
    (_, Some(_)) => true
  }
}

///|
fn nav_bar(m : Model, emit : @rabbita.Emit[Msg]) -> Html {
  let base = m.config.base
  @html.header(class="ms-nav", [
    if has_sidebar(m) {
      @html.button(
        class="ms-menu",
        title="Menu",
        on_click=emit(ToggleMenu),
        "☰",
      )
    } else {
      @html.nothing
    },
    @html.a(class="ms-brand", href=base, [
      @html.img(
        class="ms-avatar",
        src=base + "moonrockz.png",
        alt="moonrockz",
        width=28,
        height=28,
      ),
      @html.span(class="ms-word", [
        @html.text("moon"),
        @html.span(class="ms-accent", "spec"),
      ]),
    ]),
    @html.nav(class="ms-links", [
      @html.a(href=@route.href(base, Doc(@route.default_doc_slug)), "Docs"),
      @html.a(href=@data.api_docs_url, "API ↗"),
      @html.a(href=@data.github_repo, "GitHub ↗"),
    ]),
    @html.button(
      id="ms-search-btn",
      class="ms-search-btn",
      on_click=emit(OpenSearch),
      [@html.span("Search docs"), @html.kbd("⌘K")],
    ),
    version_picker(m),
    @html.button(
      class="ms-theme",
      title="Theme: " + m.theme.to_string(),
      on_click=emit(ToggleTheme),
      theme_icon(m.theme),
    ),
  ])
}

///|
fn footer_view(m : Model) -> Html {
  let base = m.config.base
  @html.footer(class="ms-footer", [
    @html.img(src=base + "moonrockz.png", alt="moonrockz", width=56, height=56),
    @html.span("A moonrockz project · Apache-2.0"),
    @html.a(href=@data.api_docs_url, "mooncakes.io ↗"),
    @html.a(href=@data.github_repo, "GitHub ↗"),
  ])
}

///|
/// The one `404.html` is served for every missing path, whichever version
/// it is under, so this view names no version.
fn not_found_view(m : Model) -> Html {
  let c = m.config
  let docs = @route.Doc(@route.default_doc_slug)
  @html.section(class="ms-notfound", [
    @html.h1("Page not found"),
    @html.p("This page does not exist."),
    @html.p([
      @html.a(href=c.base, "Home"),
      @html.text(" · "),
      @html.a(
        href=version_href(m, Release, docs),
        "Docs (\{c.release_version})",
      ),
      @html.text(" · "),
      @html.a(href=version_href(m, Next, docs), "Docs (next)"),
    ]),
  ])
}
