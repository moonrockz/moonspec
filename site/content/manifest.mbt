///|
/// Guides in sidebar order. Guides not in this list follow, by slug.
pub let guide_order : Array[String] = [
  "getting-started", "step-definitions", "hooks-and-attachments", "testing-strategies",
  "configuration",
]

///|
pub(all) enum Group {
  Guides
  Migrations
} derive(Eq, Debug, ToJson, FromJson)

///|
pub extend Group with Eq::{equal, not_equal}

///|
pub extend Group with @debug.Debug::{to_repr}

///|
pub extend Group with ToJson::{to_json}

///|
pub extend Group with FromJson::{from_json}

///|
/// A published page. `source` is the repository path of its Markdown file.
pub(all) struct Page {
  route : @route.Route
  title : String
  source : String
  group : Group
} derive(Eq, Debug, ToJson, FromJson)

///|
pub extend Page with Eq::{equal, not_equal}

///|
pub extend Page with @debug.Debug::{to_repr}

///|
pub extend Page with ToJson::{to_json}

///|
pub extend Page with FromJson::{from_json}

///|
/// A Markdown file found in the content tree, with the text of its first `#` heading.
pub(all) struct SourceFile {
  path : String
  title : String
} derive(Eq, Debug)

///|
pub extend SourceFile with Eq::{equal, not_equal}

///|
pub extend SourceFile with @debug.Debug::{to_repr}

///|
/// The published pages of one version, in sidebar order.
pub(all) struct Manifest {
  pages : Array[Page]
} derive(Eq, Debug)

///|
pub extend Manifest with Eq::{equal, not_equal}

///|
pub extend Manifest with @debug.Debug::{to_repr}

///|
/// A repository path without a leading `./`.
pub fn normalize_path(path : String) -> String {
  let mut p = path
  while p.has_prefix("./") {
    p = p[2:].to_owned()
  }
  p
}

///|
fn is_slug(s : String) -> Bool {
  s != "" &&
  s
  .iter()
  .all(c => (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '-')
}

///|
/// `[major, minor, patch]` of `vX.Y.Z`, or `None`.
fn version_numbers(v : String) -> Array[Int32]? {
  guard v.has_prefix("v") else { return None }
  let out : Array[Int32] = []
  for part in v[1:].split(".") {
    let s = part.to_owned()
    guard s != "" && s.iter().all(c => c >= '0' && c <= '9') else {
      return None
    }
    let mut n = 0
    for c in s {
      n = n * 10 + (c.to_int() - '0'.to_int())
    }
    out.push(n)
  }
  if out.length() == 3 {
    Some(out)
  } else {
    None
  }
}

///|
/// Compares `vX.Y.Z` strings numerically. Invalid versions sort first.
pub fn compare_versions(a : String, b : String) -> Int32 {
  match (version_numbers(a), version_numbers(b)) {
    (Some(x), Some(y)) =>
      if x[0] != y[0] {
        x[0] - y[0]
      } else if x[1] != y[1] {
        x[1] - y[1]
      } else {
        x[2] - y[2]
      }
    (None, Some(_)) => -1
    (Some(_), None) => 1
    (None, None) => a.compare(b)
  }
}

///|
/// The route and group of a published source file, or `None` when the file
/// is not published (for example anything under `docs/plans/`).
pub fn classify(path : String) -> (@route.Route, Group)? {
  let p = normalize_path(path)
  guard p.has_suffix(".md") else { return None }
  let segs = p[:p.length() - 3].split("/").map(s => s.to_owned()).collect()
  match segs {
    ["docs", "guide", slug] if is_slug(slug) => Some((Doc(slug), Guides))
    ["docs", "migrations", version] if version_numbers(version) is Some(_) =>
      Some((Migration(version), Migrations))
    _ => None
  }
}

///|
fn guide_rank(route : @route.Route) -> (Int32, String) {
  match route {
    Doc(slug) => {
      let mut rank = guide_order.length()
      for i, s in guide_order {
        if s == slug && rank == guide_order.length() {
          rank = i
        }
      }
      (rank, slug)
    }
    _ => (guide_order.length(), "")
  }
}

///|
fn migration_version(route : @route.Route) -> String {
  match route {
    Migration(v) => v
    _ => ""
  }
}

///|
/// The manifest of the published files among `files`.
pub fn Manifest::build(files : Array[SourceFile]) -> Manifest {
  let guides : Array[Page] = []
  let migrations : Array[Page] = []
  for f in files {
    match classify(f.path) {
      Some((route, Guides)) =>
        guides.push({
          route,
          title: f.title,
          source: normalize_path(f.path),
          group: Guides,
        })
      Some((route, Migrations)) =>
        migrations.push({
          route,
          title: f.title,
          source: normalize_path(f.path),
          group: Migrations,
        })
      None => ()
    }
  }
  guides.sort_by((a, b) => {
    let (ra, sa) = guide_rank(a.route)
    let (rb, sb) = guide_rank(b.route)
    if ra != rb {
      ra - rb
    } else {
      sa.compare(sb)
    }
  })
  migrations.sort_by((a, b) => {
    compare_versions(migration_version(b.route), migration_version(a.route))
  })
  { pages: [..guides, ..migrations], }
}

///|
pub fn Manifest::find(self : Manifest, route : @route.Route) -> Page? {
  for page in self.pages {
    if page.route == route {
      return Some(page)
    }
  }
  None
}

///|
pub fn Manifest::find_source(self : Manifest, source : String) -> Page? {
  let wanted = normalize_path(source)
  for page in self.pages {
    if page.source == wanted {
      return Some(page)
    }
  }
  None
}

///|
/// The pages before and after `route` in sidebar order.
pub fn Manifest::neighbors(
  self : Manifest,
  route : @route.Route,
) -> (Page?, Page?) {
  for i, page in self.pages {
    if page.route == route {
      let prev = if i > 0 { Some(self.pages[i - 1]) } else { None }
      let next = if i + 1 < self.pages.length() {
        Some(self.pages[i + 1])
      } else {
        None
      }
      return (prev, next)
    }
  }
  (None, None)
}
