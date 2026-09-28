///|
/// Code generation mode.
pub(all) enum CodegenMode {
  PerScenario
  PerFeature
} derive(Debug, Eq)

///|
pub extend CodegenMode with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend CodegenMode with Eq::{not_equal, equal}

///|
/// Configuration for code generation.
pub(all) struct CodegenConfig {
  mode : CodegenMode
  world : String
  skip_tags : Array[String]?
  formatters : Array[@config.FormatterConfig]?
} derive(Debug, Eq)

///|
pub extend CodegenConfig with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend CodegenConfig with Eq::{not_equal, equal}

///|
/// Create a default config (per-scenario mode, empty world name).
pub fn CodegenConfig::default() -> CodegenConfig {
  { mode: PerScenario, world: "", skip_tags: None, formatters: None, }
}

///|
/// Parse a CodegenConfig from a JSON5 string.
///
/// Expected format:
/// ```json5
/// {
///   "world": "CalcWorld",
///   "mode": "per-scenario"  // or "per-feature"
/// }
/// ```
pub fn CodegenConfig::from_json5(input : String) -> CodegenConfig raise Error {
  let json = @json5.parse(input)
  let mut mode = PerScenario
  let mut world = ""
  match json {
    Object(obj) => {
      match obj.get("world") {
        Some(String(s)) => world = s
        _ => ()
      }
      match obj.get("mode") {
        Some(String(s)) => if s == "per-feature" { mode = PerFeature }
        _ => ()
      }
    }
    _ => ()
  }
  { mode, world, skip_tags: None, formatters: None, }
}
