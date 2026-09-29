///|
/// Mode configuration — either a simple string or a per-file map.
pub(all) enum ModeConfig {
  Simple(String)
  PerFile(Map[String, String])
} derive(Debug, Eq)

///|
pub extend ModeConfig with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ModeConfig with Eq::{not_equal, equal}

///|
/// Steps codegen configuration.
pub(all) struct StepsConfig {
  output : String?
  exclude : Array[String]?
} derive(Debug, Eq)

///|
pub extend StepsConfig with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend StepsConfig with Eq::{not_equal, equal}

///|
/// Configuration for a single output formatter.
pub(all) struct FormatterConfig {
  type_ : String
  output : String
  no_color : Bool
} derive(Debug, Eq)

///|
pub extend FormatterConfig with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend FormatterConfig with Eq::{not_equal, equal}

///|
/// Moonspec configuration with optional fields for hierarchical merging.
pub(all) struct MoonspecConfig {
  world : String?
  mode : ModeConfig?
  steps : StepsConfig?
  skip_tags : Array[String]?
  formatters : Array[FormatterConfig]?
} derive(Debug, Eq)

///|
pub extend MoonspecConfig with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend MoonspecConfig with Eq::{not_equal, equal}

///|
pub fn MoonspecConfig::empty() -> MoonspecConfig {
  { world: None, mode: None, steps: None, skip_tags: None, formatters: None, }
}

///|
/// Parse config from a JSON5 string.
pub fn MoonspecConfig::from_json5(input : String) -> MoonspecConfig {
  let json = @json5.parse(input) catch { _ => return MoonspecConfig::empty() }
  let mut world : String? = None
  let mut mode : ModeConfig? = None
  let mut steps : StepsConfig? = None
  let mut skip_tags : Array[String]? = None
  let mut formatters : Array[FormatterConfig]? = None
  match json {
    Object(obj) => {
      match obj.get("world") {
        Some(String(s)) => world = Some(s)
        _ => ()
      }
      match obj.get("mode") {
        Some(String(s)) => mode = Some(Simple(s))
        Some(Object(map)) => {
          let result : Map[String, String] = Map([])
          for key, value in map {
            match value {
              String(s) => result.set(key, s)
              _ => ()
            }
          }
          mode = Some(PerFile(result))
        }
        _ => ()
      }
      match obj.get("skip_tags") {
        Some(Array(arr)) => {
          let items : Array[String] = []
          for item in arr {
            match item {
              String(s) => items.push(s)
              _ => ()
            }
          }
          skip_tags = Some(items)
        }
        _ => ()
      }
      match obj.get("steps") {
        Some(Object(steps_obj)) => {
          let mut output : String? = None
          let mut exclude : Array[String]? = None
          match steps_obj.get("output") {
            Some(String(s)) => output = Some(s)
            _ => ()
          }
          match steps_obj.get("exclude") {
            Some(Array(arr)) => {
              let items : Array[String] = []
              for item in arr {
                match item {
                  String(s) => items.push(s)
                  _ => ()
                }
              }
              exclude = Some(items)
            }
            _ => ()
          }
          steps = Some(StepsConfig::{ output, exclude, })
        }
        _ => ()
      }
      match obj.get("formatters") {
        Some(Array(arr)) => {
          let items : Array[FormatterConfig] = []
          for item in arr {
            match item {
              Object(fmt_obj) => {
                let mut type_ = ""
                let mut output = ""
                let mut no_color = false
                match fmt_obj.get("type") {
                  Some(String(s)) => type_ = s
                  _ => ()
                }
                match fmt_obj.get("output") {
                  Some(String(s)) => output = s
                  _ => ()
                }
                match fmt_obj.get("no_color") {
                  Some(True) => no_color = true
                  _ => ()
                }
                items.push(FormatterConfig::{ type_, output, no_color, })
              }
              _ => ()
            }
          }
          formatters = Some(items)
        }
        _ => ()
      }
    }
    _ => ()
  }
  { world, mode, steps, skip_tags, formatters, }
}

///|
/// Merge two configs. Fields from `override_` take precedence when present.
pub fn MoonspecConfig::merge(
  self : MoonspecConfig,
  override_ : MoonspecConfig,
) -> MoonspecConfig {
  {
    world: match override_.world {
      Some(_) => override_.world
      None => self.world
    },
    mode: match override_.mode {
      Some(_) => override_.mode
      None => self.mode
    },
    steps: match (self.steps, override_.steps) {
      (_, Some(s)) => Some(s)
      (Some(s), None) => Some(s)
      (None, None) => None
    },
    skip_tags: match (self.skip_tags, override_.skip_tags) {
      (_, Some(s)) => Some(s)
      (Some(s), None) => Some(s)
      (None, None) => None
    },
    formatters: match (self.formatters, override_.formatters) {
      (_, Some(s)) => Some(s)
      (Some(s), None) => Some(s)
      (None, None) => None
    },
  }
}

///|
/// Resolve the codegen mode for a specific feature file path.
pub fn MoonspecConfig::resolve_mode(
  self : MoonspecConfig,
  feature_path : String,
) -> String {
  match self.mode {
    Some(Simple(s)) => s
    Some(PerFile(map)) =>
      match map.get(feature_path) {
        Some(m) => m
        None =>
          match map.get("*") {
            Some(m) => m
            None => "per-scenario"
          }
      }
    None => "per-scenario"
  }
}

///|
/// Skip tags used when no `skip_tags` are configured.
pub fn default_skip_tags() -> Array[String] {
  ["@skip", "@ignore"]
}

///|
/// Check if tags match any configured skip tag.
///
/// Shared by the runner (runtime skip) and codegen (`#skip` attribute).
///
/// Scans tags for matches against the skip tag list. Supports two formats:
/// - Bare tag: `@skip` → reason is the tag name without `@` (e.g., `"skip"`)
/// - Tag with reason: `@skip("reason")` → extracts the quoted reason string
///
/// Returns `Some(reason)` for the first match, or `None` if no skip tag found.
/// Invalid reason formats (empty parens, unquoted) fall back to the tag name.
///
/// ```
/// skip_reason(["@skip(\"flaky\")"], ["@skip"]) // => Some("flaky")
/// skip_reason(["@smoke"], ["@skip"])            // => None
/// ```
pub fn skip_reason(tags : Array[String], skip_tags : Array[String]) -> String? {
  for tag in tags {
    let (name, reason) : (String, String?) = lexmatch tag with longest {
      (re"^@[a-zA-Z_][a-zA-Z0-9_]*" as ident, after=rest) => {
        let n = ident[1:].to_owned()
        lexmatch rest with longest {
          re"^\(\"[^\"]+\"\)$" as quoted =>
            (n, Some(quoted[2:quoted.length() - 2].to_owned()))
          re"^\([^)]*\)$" => (n, None)
          re"^$" => (n, None)
          _ => continue
        }
      }
      _ => continue
    }
    let full_tag = "@" + name
    for skip in skip_tags {
      if full_tag == skip {
        return Some(reason.unwrap_or(name))
      }
    }
  }
  None
}
