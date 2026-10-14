///|
pub(all) enum Theme {
  Auto
  Light
  Dark
} derive(Eq, Debug)

///|
pub extend Theme with Eq::{equal, not_equal}

///|
pub extend Theme with @debug.Debug::{to_repr}

///|
pub fn Theme::parse(s : String) -> Theme {
  match s {
    "light" => Light
    "dark" => Dark
    _ => Auto
  }
}

///|
pub fn Theme::to_string(self : Theme) -> String {
  match self {
    Auto => "auto"
    Light => "light"
    Dark => "dark"
  }
}

///|
pub(all) enum PageState {
  /// The landing page and pages that do not exist.
  NoContent
  Loading
  Ready(@markdown.Document)
  PageFailed
} derive(Eq, Debug)

///|
pub extend PageState with Eq::{equal, not_equal}

///|
pub extend PageState with @debug.Debug::{to_repr}

///|
pub(all) enum IndexState {
  NotLoaded
  LoadingIndex
  IndexReady(@search.Index)
  IndexFailed
} derive(Eq, Debug)

///|
pub extend IndexState with Eq::{equal, not_equal}

///|
pub extend IndexState with @debug.Debug::{to_repr}

///|
pub(all) enum InstallTab {
  Installed
  Moonx
} derive(Eq, Debug)

///|
pub extend InstallTab with Eq::{equal, not_equal}

///|
pub extend InstallTab with @debug.Debug::{to_repr}

///|
pub(all) struct SearchState {
  open : Bool
  query : String
  selected : Int32
  index : IndexState
} derive(Eq, Debug)

///|
pub extend SearchState with Eq::{equal, not_equal}

///|
pub extend SearchState with @debug.Debug::{to_repr}

///|
pub(all) struct Model {
  config : @data.SiteConfig
  manifest : @content.Manifest
  route : @route.Route
  page : PageState
  theme : Theme
  search : SearchState
  install_tab : InstallTab
  menu_open : Bool
  // Fragment to scroll to once the page being loaded is ready.
  pending_anchor : String?
} derive(Eq, Debug)

///|
pub extend Model with Eq::{equal, not_equal}

///|
pub extend Model with @debug.Debug::{to_repr}

///|
pub(all) enum Msg {
  UrlChanged(@url.Url)
  UrlRequested(@url.UrlRequest)
  ContentLoaded(@route.Route, Result[String, Error])
  ThemeLoaded(Theme)
  ToggleTheme
  OpenSearch
  CloseSearch
  SearchInput(String)
  IndexLoaded(Result[String, Error])
  MoveSelection(Int32)
  OpenSelected
  KeyDown(@common.Keyboard)
  SelectTab(InstallTab)
  ToggleMenu
}

///|
let closed_search : SearchState = {
  open: false,
  query: "",
  selected: 0,
  index: NotLoaded,
}

///|
fn parse_page(
  config : @data.SiteConfig,
  manifest : @content.Manifest,
  route : @route.Route,
  markdown : String,
) -> @markdown.Document {
  let source = match manifest.find(route) {
    Some(page) => page.source
    None => ""
  }
  @markdown.parse(markdown, @data.link_context(config, manifest, source))
}

///|
pub fn Model::init(data : @data.SiteData) -> Model {
  let manifest = data.manifest()
  let page = match (manifest.find(data.route), data.markdown) {
    (None, _) => NoContent
    (Some(_), Some(md)) =>
      Ready(parse_page(data.config, manifest, data.route, md))
    (Some(_), None) => Loading
  }
  {
    config: data.config,
    manifest,
    route: data.route,
    page,
    theme: Auto,
    search: closed_search,
    install_tab: Installed,
    menu_open: false,
    pending_anchor: None,
  }
}
