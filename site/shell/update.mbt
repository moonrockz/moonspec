///|
pub fn entry_href(config : @data.SiteConfig, entry : @search.Entry) -> String {
  let path = @route.href(config.base, entry.route)
  if entry.anchor == "" {
    path
  } else {
    path + "#" + entry.anchor
  }
}

///|
/// Search results grouped by page, in display order.
pub fn current_results(m : Model) -> Array[(String, Array[@search.Match])] {
  match m.search.index {
    IndexReady(index) =>
      @search.group_by_page(@search.search(index, m.search.query))
    _ => []
  }
}

///|
fn flat_results(m : Model) -> Array[@search.Match] {
  let out : Array[@search.Match] = []
  for group in current_results(m) {
    for x in group.1 {
      out.push(x)
    }
  }
  out
}

///|
fn url_href(url : @url.Url) -> String {
  let query = match url.query {
    Some(q) => "?" + q
    None => ""
  }
  let fragment = match url.fragment {
    Some(f) => "#" + f
    None => ""
  }
  "/" + url.path + query + fragment
}

///|
/// The route text of `path` when it belongs to this site. The other
/// channel's site can live below this one (`/moonspec/next/` below
/// `/moonspec/`); its paths are not ours.
fn site_path(config : @data.SiteConfig, path : String) -> String? {
  let other = match config.channel {
    Release => config.next_base
    Next => config.release_base
  }
  if other != config.base &&
    other.has_prefix(config.base) &&
    @route.strip_base(other, path) is Some(_) {
    return None
  }
  @route.strip_base(config.base, path)
}

///|
fn fetch_page(
  config : @data.SiteConfig,
  page : @content.Page,
  emit : @rabbita.Emit[Msg],
) -> @rabbita.Cmd {
  @http.get(config.base + "content/" + page.source).expect_text(
    emit.map(r => ContentLoaded(page.route, r)),
  )
}

///|
fn open_search(m : Model, emit : @rabbita.Emit[Msg]) -> (Model, @rabbita.Cmd) {
  let focus_cmd = run_effect(fn() { focus("ms-search-input") })
  match m.search.index {
    NotLoaded | IndexFailed => {
      let search = { ..m.search, open: true, selected: 0, index: LoadingIndex, }
      let load = @http.get(m.config.base + "search-index.json").expect_text(
        emit.map(r => IndexLoaded(r)),
      )
      ({ ..m, search, }, @rabbita.batch([load, focus_cmd]))
    }
    _ => ({ ..m, search: { ..m.search, open: true, selected: 0, }, }, focus_cmd)
  }
}

///|
fn on_url_changed(
  m : Model,
  url : @url.Url,
  emit : @rabbita.Emit[Msg],
) -> (Model, @rabbita.Cmd) {
  guard site_path(m.config, url.path) is Some(rest) else {
    return (m, @rabbita.none)
  }
  let route = @route.Route::parse(rest)
  let anchor = match url.fragment {
    Some(id) if id != "" => Some(id)
    _ => None
  }
  let closed = { ..m, search: { ..m.search, open: false, }, menu_open: false, }
  if route == m.route {
    return (closed, scroll_cmd(anchor))
  }
  let next = { ..closed, route, }
  match m.manifest.find(route) {
    Some(page) =>
      // The anchor is not in the DOM until the content is Ready.
      (
        { ..next, page: Loading, pending_anchor: anchor, },
        fetch_page(m.config, page, emit),
      )
    None =>
      ({ ..next, page: NoContent, pending_anchor: None, }, @nav.scroll_to_top())
  }
}

///|
fn scroll_cmd(anchor : String?) -> @rabbita.Cmd {
  match anchor {
    Some(id) => @nav.scroll_to(id)
    None => @nav.scroll_to_top()
  }
}

///|
pub fn update(
  m : Model,
  msg : Msg,
  emit : @rabbita.Emit[Msg],
) -> (Model, @rabbita.Cmd) {
  match msg {
    UrlChanged(url) => on_url_changed(m, url, emit)
    UrlRequested(Internal(url)) =>
      if site_path(m.config, url.path) is Some(_) {
        (m, @nav.push_url(url_href(url)))
      } else {
        // Another version of the site: a full page load.
        (m, @nav.load(url_href(url)))
      }
    UrlRequested(External(href)) => (m, @nav.load(href))
    ContentLoaded(route, result) => {
      guard route == m.route else { return (m, @rabbita.none) }
      let page = match result {
        Ok(md) => Ready(parse_page(m.config, m.manifest, route, md))
        Err(_) => PageFailed
      }
      ({ ..m, page, pending_anchor: None, }, scroll_cmd(m.pending_anchor))
    }
    ToggleTheme => {
      let theme = match m.theme {
        Auto => Dark
        Dark => Light
        Light => Auto
      }
      ({ ..m, theme, }, run_effect(fn() { store_theme(theme) }))
    }
    OpenSearch => open_search(m, emit)
    CloseSearch =>
      (
        { ..m, search: { ..m.search, open: false, }, },
        run_effect(fn() { focus("ms-search-btn") }),
      )
    SearchInput(query) =>
      ({ ..m, search: { ..m.search, query, selected: 0, }, }, @rabbita.none)
    IndexLoaded(Ok(text)) => {
      let index = match parse_index(text) {
        Some(entries) => IndexReady(@search.Index::new(entries))
        None => IndexFailed
      }
      ({ ..m, search: { ..m.search, index, }, }, @rabbita.none)
    }
    IndexLoaded(Err(_)) =>
      ({ ..m, search: { ..m.search, index: IndexFailed, }, }, @rabbita.none)
    MoveSelection(delta) => {
      let count = flat_results(m).length()
      let selected = if count == 0 {
        0
      } else {
        (m.search.selected + delta + count) % count
      }
      ({ ..m, search: { ..m.search, selected, }, }, run_effect(scroll_selected))
    }
    OpenSelected =>
      match flat_results(m).get(m.search.selected) {
        Some(hit) =>
          (
            { ..m, search: { ..m.search, open: false, }, },
            @nav.push_url(entry_href(m.config, hit.entry)),
          )
        None => (m, @rabbita.none)
      }
    KeyDown(key) => on_key(m, key, emit)
    SelectTab(tab) => ({ ..m, install_tab: tab, }, @rabbita.none)
    ToggleMenu => ({ ..m, menu_open: !m.menu_open, }, @rabbita.none)
  }
}

///|
fn parse_index(text : String) -> Array[@search.Entry]? {
  let json = @json.parse(text) catch { _ => return None }
  let entries : Array[@search.Entry] = @json.from_json(json) catch {
    _ => return None
  }
  Some(entries)
}

///|
fn on_key(
  m : Model,
  key : @common.Keyboard,
  emit : @rabbita.Emit[Msg],
) -> (Model, @rabbita.Cmd) {
  let k = key.key()
  if !m.search.open {
    if ((k == "k" || k == "K") && (key.meta_key() || key.ctrl_key())) ||
      k == "/" {
      return open_search(m, emit)
    }
    return (m, @rabbita.none)
  }
  match k {
    "Escape" => update(m, CloseSearch, emit)
    "ArrowDown" => update(m, MoveSelection(1), emit)
    "ArrowUp" => update(m, MoveSelection(-1), emit)
    "Enter" => update(m, OpenSelected, emit)
    _ => (m, @rabbita.none)
  }
}
