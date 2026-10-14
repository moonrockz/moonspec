///|
/// The guide that `/docs/` opens.
pub let default_doc_slug : String = "getting-started"

///|
/// A page of the site, without the base path.
pub(all) enum Route {
  Landing
  Doc(String)
  Migration(String)
  NotFound(String)
} derive(Eq, Debug, ToJson, FromJson)

///|
pub extend Route with Eq::{equal, not_equal}

///|
pub extend Route with @debug.Debug::{to_repr}

///|
pub extend Route with ToJson::{to_json}

///|
pub extend Route with FromJson::{from_json}

///|
/// Non-empty path segments; a trailing `index.html` is dropped.
fn segments(path : String) -> Array[String] {
  let out : Array[String] = []
  for part in path.split("/") {
    let s = part.to_owned()
    if s != "" {
      out.push(s)
    }
  }
  if out.last() == Some("index.html") {
    ignore(out.pop())
  }
  out
}

///|
/// Route of a path after the base path, for example `docs/configuration`.
pub fn Route::parse(path : String) -> Route {
  let segs = segments(path)
  match segs {
    [] => Landing
    ["docs"] => Doc(default_doc_slug)
    ["docs", slug] => Doc(slug)
    ["migrations", version] => Migration(version)
    _ => NotFound(segs.join("/"))
  }
}

///|
/// The path of the route after the base path, without leading or trailing `/`.
pub fn Route::to_path(self : Route) -> String {
  match self {
    Landing => ""
    Doc(slug) => "docs/" + slug
    Migration(version) => "migrations/" + version
    NotFound(path) => path
  }
}

///|
/// The URL path of `route` under `base` (which ends with `/`). Pages other than
/// the landing page end with `/`: GitHub Pages redirects the other form.
pub fn href(base : String, route : Route) -> String {
  match route {
    Landing => base
    _ => base + route.to_path() + "/"
  }
}

///|
/// The part of an URL path after `base`, or `None` when the path is not under
/// `base`. `path` may lack its leading `/` (rabbita's `Url.path` does).
pub fn strip_base(base : String, path : String) -> String? {
  let p = if path.has_prefix("/") { path } else { "/" + path }
  if p.has_prefix(base) {
    Some(p[base.length():].to_owned())
  } else if p + "/" == base {
    Some("")
  } else {
    None
  }
}
