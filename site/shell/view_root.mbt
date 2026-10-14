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
/// Runs before the first paint: applies the stored theme so a reader who
/// chose one never sees the other. Static text, so the pre-rendered and the
/// hydrated head are identical.
let theme_script : String =
  #|try{var t=localStorage.getItem('moonspec-theme');if(t==='light'||t==='dark'){document.documentElement.dataset.theme=t}}catch(e){}

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
      script(theme_script),
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
/// `initial_theme` is the theme the head script already applied; the
/// pre-render uses `Auto`.
pub fn component(
  data : @data.SiteData,
  site_json : String,
  initial_theme~ : Theme = Auto,
) -> @rabbita.Val[Html] {
  let (model, emit) = @rabbita.create_state(
    { ..Model::init(data), theme: initial_theme, },
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
