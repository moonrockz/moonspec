///|
/// Mode configuration — either a simple string or a per-file map.
pub(all) enum ModeConfig {
  Simple(String)
  PerFile(Map[String, String])
} derive(Show, Eq)

///|
/// Steps codegen configuration.
pub(all) struct StepsConfig {
  output : String?
  exclude : Array[String]?
} derive(Show, Eq)

///|
/// Moonspec configuration with optional fields for hierarchical merging.
pub(all) struct MoonspecConfig {
  world : String?
  mode : ModeConfig?
  steps : StepsConfig?
} derive(Show, Eq)

///|
pub fn MoonspecConfig::empty() -> MoonspecConfig {
  { world: None, mode: None, steps: None }
}

///|
/// Parse config from a JSON5 string.
pub fn MoonspecConfig::from_json5(input : String) -> MoonspecConfig {
  let json = @json5.parse(input) catch { _ => return MoonspecConfig::empty() }
  let mut world : String? = None
  let mut mode : ModeConfig? = None
  let mut steps : StepsConfig? = None
  match json {
    Object(obj) => {
      match obj.get("world") {
        Some(String(s)) => world = Some(s)
        _ => ()
      }
      match obj.get("mode") {
        Some(String(s)) => mode = Some(Simple(s))
        Some(Object(map)) => {
          let result : Map[String, String] = {}
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
          steps = Some(StepsConfig::{ output, exclude })
        }
        _ => ()
      }
    }
    _ => ()
  }
  { world, mode, steps }
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
