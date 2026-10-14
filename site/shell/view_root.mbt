///|
using @html {type Html, html, head, body, meta, title, link, script, main_}

///|
fn theme_attrs(theme : Theme) -> @html.Attrs {
  match theme {
    Auto => @html.Attrs::build()
    Light => @html.Attrs::build().data_set("theme", "light")
    Dark => @html.Attrs::build().data_set("theme", "dark")
  }
}

///|
fn page_title(m : Model) -> String {
  match (m.route, m.manifest.find(m.route)) {
    (Landing, _) => "moonspec — BDD test framework for MoonBit"
    (_, Some(page)) => page.title + " — moonspec"
    (_, None) => "Page not found — moonspec"
  }
}

///|
/// The whole document. `site_json` is the encoded first-render data; it is
/// constant, so the pre-rendered `<meta>` and the hydrated one match.
pub fn view(m : Model, emit : @rabbita.Emit[Msg], site_json : String) -> Html {
  let base = m.config.base
  html(lang="en", attrs=theme_attrs(m.theme), [
    head([
      meta(charset="utf-8"),
      meta(name="viewport", content="width=device-width, initial-scale=1"),
      title(page_title(m)),
      meta(
        name="description",
        content="moonspec: BDD test framework for MoonBit with Gherkin and Cucumber Expressions.",
      ),
      link(rel="icon", href=base + "favicon.png"),
      link(rel="preconnect", href="https://fonts.googleapis.com"),
      link(
        rel="stylesheet",
        href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;800&display=swap",
      ),
      link(rel="stylesheet", href=base + "styles.css"),
      meta(name="ms-data", content=site_json),
      script(src=base + "index.js", type_="module", ([] : Array[Html])),
    ]),
    body([
      nav_bar(m, emit),
      main_(class="ms-main", [content_view(m, emit)]),
      footer_view(m),
      search_view(m, emit),
    ]),
  ])
}

///|
fn content_view(m : Model, emit : @rabbita.Emit[Msg]) -> Html {
  match (m.route, m.manifest.find(m.route)) {
    (Landing, _) => landing_view(m, emit)
    (_, Some(page)) => docs_view(m, page)
    (_, None) => not_found_view(m)
  }
}

///|
/// The site component: one state, one view of the whole document.
pub fn component(
  data : @data.SiteData,
  site_json : String,
) -> @rabbita.Val[Html] {
  let (model, emit) = @rabbita.create_state_with_init(
    init=emit => (Model::init(data), load_theme(emit)),
    update~,
    subscriptions=(_m, emit) => {
      @sub.batch([
        @sub.on_url_changed(emit.map(u => UrlChanged(u))),
        @sub.on_url_request(emit.map(r => UrlRequested(r))),
        @sub.on_key_down(emit.map(k => KeyDown(k))),
      ])
    },
  )
  model.map(m => view(m, emit, site_json))
}

///|
/// Reads the stored theme. `perform` exists only on the JS target, so native
/// builds (used for tests) skip it.
#cfg(target="js")
fn load_theme(emit : @rabbita.Emit[Msg]) -> @rabbita.Cmd {
  @rabbita.perform(theme => emit(ThemeLoaded(theme)), fn() noraise {
    read_theme()
  })
}

///|
#cfg(not(target="js"))
fn load_theme(_emit : @rabbita.Emit[Msg]) -> @rabbita.Cmd {
  @rabbita.none
}
