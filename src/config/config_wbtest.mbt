///|
test "MoonspecConfig::from_json5 parses simple mode" {
  let json5 = "{ \"world\": \"MyWorld\", \"mode\": \"per-scenario\" }"
  let config = MoonspecConfig::from_json5(json5)
  assert_eq(config.world, Some("MyWorld"))
  match config.mode {
    Some(Simple(mode)) => assert_eq(mode, "per-scenario")
    _ => assert_true(false)
  }
}

///|
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

///|
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

///|
test "merge: package config overrides module config" {
  let module_config = MoonspecConfig::{
    world: Some("ModuleWorld"),
    mode: Some(Simple("per-scenario")),
    steps: None,
    skip_tags: None,
    formatters: None,
  }
  let package_config = MoonspecConfig::{
    world: None,
    mode: Some(Simple("per-feature")),
    steps: Some(StepsConfig::{ output: Some("alongside"), exclude: None }),
    skip_tags: None,
    formatters: None,
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

///|
test "resolve_mode with simple mode" {
  let config = MoonspecConfig::{
    world: None,
    mode: Some(Simple("per-feature")),
    steps: None,
    skip_tags: None,
    formatters: None,
  }
  assert_eq(config.resolve_mode("any/file.feature"), "per-feature")
}

///|
test "resolve_mode with per-file map" {
  let map : Map[String, String] = {}
  map.set("features/checkout.feature", "per-feature")
  map.set("*", "per-scenario")
  let config = MoonspecConfig::{
    world: None,
    mode: Some(PerFile(map)),
    steps: None,
    skip_tags: None,
    formatters: None,
  }
  assert_eq(config.resolve_mode("features/checkout.feature"), "per-feature")
  assert_eq(config.resolve_mode("features/other.feature"), "per-scenario")
}

///|
test "resolve_mode defaults to per-scenario" {
  let config = MoonspecConfig::empty()
  assert_eq(config.resolve_mode("any.feature"), "per-scenario")
}

///|
test "from_json5 handles empty/invalid input" {
  let config = MoonspecConfig::from_json5("")
  assert_eq(config.world, None)
  assert_eq(config.mode, None)
  assert_eq(config.steps, None)
  assert_eq(config.skip_tags, None)
}

///|
test "MoonspecConfig::from_json5 parses skip_tags" {
  let json5 =
    #|{
    #|  "skip_tags": ["@skip", "@ignore", "@wip"]
    #|}
  let config = MoonspecConfig::from_json5(json5)
  assert_eq(config.skip_tags, Some(["@skip", "@ignore", "@wip"]))
}

///|
test "MoonspecConfig::from_json5 parses empty skip_tags" {
  let json5 =
    #|{
    #|  "skip_tags": []
    #|}
  let config = MoonspecConfig::from_json5(json5)
  assert_eq(config.skip_tags, Some([]))
}

///|
test "merge: skip_tags override takes precedence" {
  let module_config = MoonspecConfig::{
    world: None,
    mode: None,
    steps: None,
    skip_tags: Some(["@skip", "@ignore"]),
    formatters: None,
  }
  let package_config = MoonspecConfig::{
    world: None,
    mode: None,
    steps: None,
    skip_tags: Some(["@wip"]),
    formatters: None,
  }
  let merged = module_config.merge(package_config)
  assert_eq(merged.skip_tags, Some(["@wip"]))
}

///|
test "merge: skip_tags falls back to base when override absent" {
  let module_config = MoonspecConfig::{
    world: None,
    mode: None,
    steps: None,
    skip_tags: Some(["@skip", "@ignore"]),
    formatters: None,
  }
  let package_config = MoonspecConfig::empty()
  let merged = module_config.merge(package_config)
  assert_eq(merged.skip_tags, Some(["@skip", "@ignore"]))
}

///|
test "MoonspecConfig::from_json5 parses formatters" {
  let json5 =
    #|{
    #|  "formatters": [
    #|    { "type": "pretty", "output": "stdout" },
    #|    { "type": "junit", "output": "reports/results.xml" }
    #|  ]
    #|}
  let config = MoonspecConfig::from_json5(json5)
  match config.formatters {
    Some(fmts) => {
      assert_eq(fmts.length(), 2)
      assert_eq(fmts[0].type_, "pretty")
      assert_eq(fmts[0].output, "stdout")
      assert_eq(fmts[0].no_color, false)
      assert_eq(fmts[1].type_, "junit")
      assert_eq(fmts[1].output, "reports/results.xml")
    }
    None => assert_true(false)
  }
}

///|
test "MoonspecConfig::from_json5 parses formatter with no_color" {
  let json5 =
    #|{
    #|  "formatters": [
    #|    { "type": "pretty", "output": "stderr", "no_color": true }
    #|  ]
    #|}
  let config = MoonspecConfig::from_json5(json5)
  match config.formatters {
    Some(fmts) => assert_eq(fmts[0].no_color, true)
    None => assert_true(false)
  }
}

///|
test "MoonspecConfig::from_json5 empty formatters array" {
  let json5 =
    #|{
    #|  "formatters": []
    #|}
  let config = MoonspecConfig::from_json5(json5)
  assert_eq(config.formatters, Some([]))
}

///|
test "merge: formatters override takes precedence" {
  let base = MoonspecConfig::{
    world: None,
    mode: None,
    steps: None,
    skip_tags: None,
    formatters: Some([
      FormatterConfig::{ type_: "pretty", output: "stdout", no_color: false },
    ]),
  }
  let override_ = MoonspecConfig::{
    world: None,
    mode: None,
    steps: None,
    skip_tags: None,
    formatters: Some([
      FormatterConfig::{ type_: "junit", output: "report.xml", no_color: false },
    ]),
  }
  let merged = base.merge(override_)
  match merged.formatters {
    Some(fmts) => {
      assert_eq(fmts.length(), 1)
      assert_eq(fmts[0].type_, "junit")
    }
    None => assert_true(false)
  }
}

///|
test "merge: formatters falls back to base when override absent" {
  let base = MoonspecConfig::{
    world: None,
    mode: None,
    steps: None,
    skip_tags: None,
    formatters: Some([
      FormatterConfig::{ type_: "pretty", output: "stdout", no_color: false },
    ]),
  }
  let override_ = MoonspecConfig::empty()
  let merged = base.merge(override_)
  match merged.formatters {
    Some(fmts) => assert_eq(fmts.length(), 1)
    None => assert_true(false)
  }
}
