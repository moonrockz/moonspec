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
fn version_picker(m : Model) -> Html {
  let c = m.config
  // A missing page has no counterpart in the other version: link to its home.
  let route = match m.route {
    NotFound(_) => @route.Landing
    r => r
  }
  @html.div(class="ms-version", [
    @html.a(
      class=class_if(
        "ms-version-link",
        "ms-version-current",
        c.channel == Release,
      ),
      href=@route.href(c.release_base, route),
      c.release_version,
    ),
    @html.a(
      class=class_if("ms-version-link", "ms-version-current", c.channel == Next),
      href=@route.href(c.next_base, route),
      "next",
    ),
  ])
}

///|
fn nav_bar(m : Model, emit : @rabbita.Emit[Msg]) -> Html {
  let base = m.config.base
  @html.header(class="ms-nav", [
    @html.button(
      class="ms-menu",
      title="Menu",
      on_click=emit(ToggleMenu),
      "☰",
    ),
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
    @html.button(class="ms-search-btn", on_click=emit(OpenSearch), [
      @html.span("Search docs"),
      @html.kbd("⌘K"),
    ]),
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
fn not_found_view(m : Model) -> Html {
  let base = m.config.base
  @html.section(class="ms-notfound", [
    @html.h1("Page not found"),
    @html.p("This page does not exist in the \{m.config.version} docs."),
    @html.p([
      @html.a(href=base, "Home"),
      @html.text(" · "),
      @html.a(href=@route.href(base, Doc(@route.default_doc_slug)), "Docs"),
    ]),
  ])
}
