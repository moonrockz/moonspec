///|
/// Supported portable execution targets. LLVM is experimental and excluded.
pub(all) enum Target {
  Wasm
  WasmGc
  Js
  Native
} derive(Debug, Eq, Hash)

///|
pub fn Target::parse(value : String) -> Target? {
  match value {
    "wasm" => Some(Wasm)
    "wasm-gc" => Some(WasmGc)
    "js" => Some(Js)
    "native" => Some(Native)
    _ => None
  }
}

///|
pub fn Target::name(self : Target) -> String {
  match self {
    Wasm => "wasm"
    WasmGc => "wasm-gc"
    Js => "js"
    Native => "native"
  }
}

///|
pub(all) enum ExecutionPolicy {
  Scalar(ExecutionMode)
  Targeted(default~ : ExecutionMode, targets~ : Map[Target, ExecutionMode])
} derive(Debug, Eq)

///|
pub fn ExecutionPolicy::resolve(
  self : ExecutionPolicy,
  target : Target,
) -> ExecutionMode {
  match self {
    Scalar(mode) => mode
    Targeted(default~, targets~) => targets.get(target).unwrap_or(default)
  }
}

///|
pub(all) struct SharedConfig {
  package_path : String
  world_factory : String
  options_factory : String
} derive(Debug, Eq)

///|
fn parse_execution(value : Json) -> ExecutionPolicy raise ConfigError {
  match value {
    String(s) =>
      match ExecutionMode::parse(s) {
        Some(mode) => Scalar(mode)
        None =>
          raise InvalidExecution(
            "execution must be \"async\" or \"sync\", got \"\{s}\"",
          )
      }
    Object(obj) => {
      for key, _ in obj {
        if key != "default" && key != "targets" {
          raise InvalidExecution("execution has unknown key: " + key)
        }
      }
      let default = parse_policy_mode(obj.get("default"), "execution.default")
      let targets : Map[Target, ExecutionMode] = Map([])
      match obj.get("targets") {
        None => ()
        Some(Object(values)) =>
          for key, value in values {
            let target = match Target::parse(key) {
              Some(target) => target
              None =>
                raise InvalidExecution(
                  "execution.targets: unsupported target " +
                  key +
                  "; expected wasm, wasm-gc, js, native",
                )
            }
            targets.set(
              target,
              parse_policy_mode(Some(value), "execution.targets." + key),
            )
          }
        _ => raise InvalidExecution("execution.targets must be an object")
      }
      if targets.get(WasmGc).unwrap_or(default) == Async {
        raise InvalidExecution(
          "execution resolves wasm-gc to async, which is unsupported; set execution.targets.wasm-gc to sync",
        )
      }
      Targeted(default~, targets~)
    }
    _ =>
      raise InvalidExecution(
        "execution must be \"async\", \"sync\", or a target policy object",
      )
  }
}

///|
fn parse_shared(value : Json) -> SharedConfig raise ConfigError {
  match value {
    Object(obj) => {
      for key, _ in obj {
        if key != "package" &&
          key != "world_factory" &&
          key != "options_factory" {
          raise InvalidExecution("shared has unknown key: " + key)
        }
      }
      let package_path = shared_string(obj.get("package"), "shared.package")
      let world_factory = shared_string(
        obj.get("world_factory"),
        "shared.world_factory",
      )
      let options_factory = shared_string(
        obj.get("options_factory"),
        "shared.options_factory",
      )
      let shared = { package_path, world_factory, options_factory, }
      shared.validate()
      shared
    }
    _ => raise InvalidExecution("shared must be an object")
  }
}

///|
pub extend Target with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Target with Eq::{equal, not_equal}

///|
pub extend Target with Hash::{hash, hash_combine}

///|
pub extend ExecutionPolicy with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ExecutionPolicy with Eq::{equal, not_equal}

///|
pub extend SharedConfig with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SharedConfig with Eq::{equal, not_equal}

///|
fn parse_policy_mode(
  value : Json?,
  path : String,
) -> ExecutionMode raise ConfigError {
  match value {
    Some(String(s)) =>
      match ExecutionMode::parse(s) {
        Some(mode) => mode
        None => raise InvalidExecution(path + " must be async or sync")
      }
    _ => raise InvalidExecution(path + " is required and must be async or sync")
  }
}

///|
fn shared_string(value : Json?, path : String) -> String raise ConfigError {
  match value {
    Some(String(s)) if !s.is_empty() => s
    _ =>
      raise InvalidExecution(
        path + " is required and must be a nonempty string",
      )
  }
}

///|
fn simple_identifier(value : String) -> Bool {
  if [
      "_", "abstract", "alias", "and", "as", "assert", "async", "await", "break",
      "catch", "const", "continue", "declare", "defer", "derive", "do", "dyn", "else",
      "enum", "enumview", "errdefer", "extend", "extenum", "extern", "false", "final",
      "fn", "for", "guard", "if", "impl", "import", "in", "is", "let", "letrec",
      "lexmatch", "lexscan", "local", "loop", "macro", "match", "method", "module",
      "move", "mut", "nobreak", "nocancel", "noraise", "override", "package", "priv",
      "proof_assert", "proof_let", "pub", "raise", "readonly", "ref", "return", "static",
      "struct", "suberror", "super", "test", "throw", "trait", "true", "try", "type",
      "typeof", "unsafe", "use", "using", "var", "virtual", "where", "while", "with",
      "yield",
    ].contains(value) {
    return false
  }
  for i, c in value.iter() {
    if !(c >= 'a' && c <= 'z') &&
      !(c >= 'A' && c <= 'Z') &&
      c != '_' &&
      !(i > 0 && c >= '0' && c <= '9') {
      return false
    }
  }
  !value.is_empty()
}

///|
/// Validate both parsed and directly constructed shared configuration.
pub fn SharedConfig::validate(self : SharedConfig) -> Unit raise ConfigError {
  let package_path = self.package_path
  let world_factory = self.world_factory
  let options_factory = self.options_factory
  for segment in package_path.split("/") {
    if segment.is_empty() || segment == "." || segment == ".." {
      raise InvalidExecution(
        "shared.package must be a nonempty package path without dot segments",
      )
    }
    for c in segment.to_owned().iter() {
      if !(c >= 'a' && c <= 'z') &&
        !(c >= 'A' && c <= 'Z') &&
        !(c >= '0' && c <= '9') &&
        c != '_' &&
        c != '-' {
        raise InvalidExecution("shared.package contains an invalid character")
      }
    }
  }
  for factory in [world_factory, options_factory] {
    if !simple_identifier(factory) {
      raise InvalidExecution(
        "shared factories must be simple MoonBit identifiers",
      )
    }
  }
}
