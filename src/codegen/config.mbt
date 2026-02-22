///|
/// Code generation mode.
pub(all) enum CodegenMode {
  PerScenario
  PerFeature
} derive(Show, Eq)

///|
/// Configuration for code generation.
pub(all) struct CodegenConfig {
  mode : CodegenMode
  world : String
} derive(Show, Eq)

///|
/// Create a default config (per-scenario mode, empty world name).
pub fn CodegenConfig::default() -> CodegenConfig {
  { mode: PerScenario, world: "" }
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
        Some(String(s)) =>
          if s == "per-feature" {
            mode = PerFeature
          }
        _ => ()
      }
    }
    _ => ()
  }
  { mode, world }
}
