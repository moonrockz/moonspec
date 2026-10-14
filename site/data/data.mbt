///|
pub let github_repo : String = "https://github.com/moonrockz/moonspec"

///|
/// The API reference on mooncakes.io (verified in Task 8, Step 3).
pub let api_docs_url : String = "https://mooncakes.io/docs/moonrockz/moonspec"

///|
pub(all) enum Channel {
  Release
  Next
} derive(Eq, Debug, ToJson, FromJson)

///|
pub extend Channel with Eq::{equal, not_equal}

///|
pub extend Channel with @debug.Debug::{to_repr}

///|
pub extend Channel with ToJson::{to_json}

///|
pub extend Channel with FromJson::{from_json}

///|
/// One built version of the site.
pub(all) struct SiteConfig {
  /// Base path of this version, for example "/moonspec/next/".
  base : String
  /// "v0.11.0" for the release, "next" for main.
  version : String
  channel : Channel
  /// Tag or commit SHA used for GitHub links.
  git_ref : String
  release_base : String
  next_base : String
  /// Label of the release version, for the version picker.
  release_version : String
} derive(Eq, Debug, ToJson, FromJson)

///|
pub extend SiteConfig with Eq::{equal, not_equal}

///|
pub extend SiteConfig with @debug.Debug::{to_repr}

///|
pub extend SiteConfig with ToJson::{to_json}

///|
pub extend SiteConfig with FromJson::{from_json}

///|
/// Everything the component needs for its first render. The pre-render puts
/// it in `<meta name="ms-data">`; the browser reads it back for hydration.
pub(all) struct SiteData {
  config : SiteConfig
  pages : Array[@content.Page]
  route : @route.Route
  /// Markdown of the current page; `None` for the landing page and 404.
  markdown : String?
} derive(Eq, Debug, ToJson, FromJson)

///|
pub extend SiteData with Eq::{equal, not_equal}

///|
pub extend SiteData with @debug.Debug::{to_repr}

///|
pub extend SiteData with ToJson::{to_json}

///|
pub extend SiteData with FromJson::{from_json}

///|
pub fn SiteData::encode(self : SiteData) -> String {
  Json(self).stringify()
}

///|
pub fn SiteData::decode(s : String) -> SiteData? {
  let json = @json.parse(s) catch { _ => return None }
  let data : SiteData = @json.from_json(json) catch { _ => return None }
  Some(data)
}

///|
pub fn SiteData::manifest(self : SiteData) -> @content.Manifest {
  { pages: self.pages, }
}

///|
/// The link context for the page whose repository path is `source`.
pub fn link_context(
  config : SiteConfig,
  manifest : @content.Manifest,
  source : String,
) -> @markdown.LinkContext {
  {
    source,
    resolve: path => manifest.find_source(path).map(p => p.route),
    repo_url: github_repo,
    git_ref: config.git_ref,
  }
}
