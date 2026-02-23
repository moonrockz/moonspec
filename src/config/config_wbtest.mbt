test "MoonspecConfig::from_json5 parses simple mode" {
  let json5 = "{ \"world\": \"MyWorld\", \"mode\": \"per-scenario\" }"
  let config = MoonspecConfig::from_json5(json5)
  assert_eq(config.world, Some("MyWorld"))
  match config.mode {
    Some(Simple(mode)) => assert_eq(mode, "per-scenario")
    _ => assert_true(false)
  }
}

test "MoonspecConfig::from_json5 parses map mode" {
  let json5 =
    #|{
    #|  "world": "MyWorld",
    #|  "mode": {
    #|    "features/checkout.feature": "per-feature",
    #|    "*": "per-scenario"
    #|  }
    #|}
  let config = MoonspecConfig::from_json5(json5)
  match config.mode {
    Some(PerFile(map)) => {
      assert_eq(map.get("features/checkout.feature"), Some("per-feature"))
      assert_eq(map.get("*"), Some("per-scenario"))
    }
    _ => assert_true(false)
  }
}

test "MoonspecConfig::from_json5 parses steps config" {
  let json5 =
    #|{
    #|  "steps": {
    #|    "output": "alongside",
    #|    "exclude": ["lib/*", "vendor/*"]
    #|  }
    #|}
  let config = MoonspecConfig::from_json5(json5)
  match config.steps {
    Some(steps) => {
      assert_eq(steps.output, Some("alongside"))
      assert_eq(steps.exclude, Some(["lib/*", "vendor/*"]))
    }
    None => assert_true(false)
  }
}

test "merge: package config overrides module config" {
  let module_config = MoonspecConfig::{
    world: Some("ModuleWorld"),
    mode: Some(Simple("per-scenario")),
    steps: None,
  }
  let package_config = MoonspecConfig::{
    world: None,
    mode: Some(Simple("per-feature")),
    steps: Some(StepsConfig::{ output: Some("alongside"), exclude: None }),
  }
  let merged = module_config.merge(package_config)
  assert_eq(merged.world, Some("ModuleWorld"))
  match merged.mode {
    Some(Simple(m)) => assert_eq(m, "per-feature")
    _ => assert_true(false)
  }
  match merged.steps {
    Some(s) => assert_eq(s.output, Some("alongside"))
    None => assert_true(false)
  }
}

test "resolve_mode with simple mode" {
  let config = MoonspecConfig::{
    world: None,
    mode: Some(Simple("per-feature")),
    steps: None,
  }
  assert_eq(config.resolve_mode("any/file.feature"), "per-feature")
}

test "resolve_mode with per-file map" {
  let map : Map[String, String] = {}
  map.set("features/checkout.feature", "per-feature")
  map.set("*", "per-scenario")
  let config = MoonspecConfig::{
    world: None,
    mode: Some(PerFile(map)),
    steps: None,
  }
  assert_eq(config.resolve_mode("features/checkout.feature"), "per-feature")
  assert_eq(config.resolve_mode("features/other.feature"), "per-scenario")
}

test "resolve_mode defaults to per-scenario" {
  let config = MoonspecConfig::empty()
  assert_eq(config.resolve_mode("any.feature"), "per-scenario")
}

test "from_json5 handles empty/invalid input" {
  let config = MoonspecConfig::from_json5("")
  assert_eq(config.world, None)
  assert_eq(config.mode, None)
  assert_eq(config.steps, None)
}
