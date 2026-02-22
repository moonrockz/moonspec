///|
/// In-memory cache of parsed Gherkin features, keyed by path.
/// Mutation is controlled — only `load_*` methods can add entries.
pub struct FeatureCache {
  priv cache : Map[String, @gherkin.Feature]
}

///|
/// Create an empty feature cache.
pub fn FeatureCache::new() -> FeatureCache {
  { cache: {} }
}

///|
/// Load a feature from a file path. Idempotent — skips if already cached.
pub fn FeatureCache::load_file(self : FeatureCache, path : String) -> Unit raise Error {
  if self.cache.contains(path) {
    return
  }
  let content = @fs.read_file_to_string(path)
  let source = @gherkin.Source::from_string(content)
  let doc = @gherkin.parse(source)
  match doc.feature {
    Some(feature) => self.cache.set(path, feature)
    None => ()
  }
}

///|
/// Load a feature from inline text. Always overwrites existing entry.
pub fn FeatureCache::load_text(
  self : FeatureCache,
  path : String,
  content : String,
) -> Unit raise Error {
  let source = @gherkin.Source::from_string(content)
  let doc = @gherkin.parse(source)
  match doc.feature {
    Some(feature) => self.cache.set(path, feature)
    None => ()
  }
}

///|
/// Store a pre-parsed feature directly.
pub fn FeatureCache::load_parsed(
  self : FeatureCache,
  path : String,
  feature : @gherkin.Feature,
) -> Unit {
  self.cache.set(path, feature)
}

///|
/// Load a feature from any FeatureSource variant.
pub fn FeatureCache::load_from_source(
  self : FeatureCache,
  source : FeatureSource,
) -> Unit raise Error {
  match source {
    Text(path, content) => self.load_text!(path, content)
    File(path) => self.load_file!(path)
    Parsed(path, feature) => self.load_parsed(path, feature)
  }
}

///|
/// Look up a cached feature by path.
pub fn FeatureCache::get(self : FeatureCache, path : String) -> @gherkin.Feature? {
  self.cache.get(path)
}

///|
/// Return all cached features as (path, feature) pairs.
pub fn FeatureCache::features(self : FeatureCache) -> Array[(String, @gherkin.Feature)] {
  let result : Array[(String, @gherkin.Feature)] = []
  self.cache.each(fn(k, v) { result.push((k, v)) })
  result
}

///|
/// Check if a path is cached.
pub fn FeatureCache::contains(self : FeatureCache, path : String) -> Bool {
  self.cache.contains(path)
}

///|
/// Number of cached features.
pub fn FeatureCache::size(self : FeatureCache) -> Int {
  self.cache.size()
}
