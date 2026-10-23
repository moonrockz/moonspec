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
    no_color: None,
    execution: None,
    shared: None,
    test_kind: None,
  }
  let package_config = MoonspecConfig::{
    world: None,
    mode: Some(Simple("per-feature")),
    steps: Some(StepsConfig::{ output: Some("alongside"), exclude: None, }),
    skip_tags: None,
    formatters: None,
    no_color: None,
    execution: None,
    shared: None,
    test_kind: None,
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
    no_color: None,
    execution: None,
    shared: None,
    test_kind: None,
  }
  assert_eq(config.resolve_mode("any/file.feature"), "per-feature")
}

///|
test "resolve_mode with per-file map" {
  let map : Map[String, String] = Map([])
  map.set("features/checkout.feature", "per-feature")
  map.set("*", "per-scenario")
  let config = MoonspecConfig::{
    world: None,
    mode: Some(PerFile(map)),
    steps: None,
    skip_tags: None,
    formatters: None,
    no_color: None,
    execution: None,
    shared: None,
    test_kind: None,
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
    no_color: None,
    execution: None,
    shared: None,
    test_kind: None,
  }
  let package_config = MoonspecConfig::{
    world: None,
    mode: None,
    steps: None,
    skip_tags: Some(["@wip"]),
    formatters: None,
    no_color: None,
    execution: None,
    shared: None,
    test_kind: None,
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
    no_color: None,
    execution: None,
    shared: None,
    test_kind: None,
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
      FormatterConfig::{ type_: "pretty", output: "stdout", no_color: false, },
    ]),
    no_color: None,
    execution: None,
    shared: None,
    test_kind: None,
  }
  let override_ = MoonspecConfig::{
    world: None,
    mode: None,
    steps: None,
    skip_tags: None,
    formatters: Some([
      FormatterConfig::{
        type_: "junit",
        output: "report.xml",
        no_color: false,
      },
    ]),
    no_color: None,
    execution: None,
    shared: None,
    test_kind: None,
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
      FormatterConfig::{ type_: "pretty", output: "stdout", no_color: false, },
    ]),
    no_color: None,
    execution: None,
    shared: None,
    test_kind: None,
  }
  let override_ = MoonspecConfig::empty()
  let merged = base.merge(override_)
  match merged.formatters {
    Some(fmts) => assert_eq(fmts.length(), 1)
    None => assert_true(false)
  }
}

///|
test "skip_reason returns None when no skip tag present" {
  let result = skip_reason(["@smoke", "@fast"], ["@skip", "@ignore"])
  assert_eq(result, None)
}

///|
test "skip_reason matches bare @skip tag" {
  let result = skip_reason(["@smoke", "@skip"], ["@skip", "@ignore"])
  assert_eq(result, Some("skip"))
}

///|
test "skip_reason matches bare @ignore tag" {
  let result = skip_reason(["@ignore", "@smoke"], ["@skip", "@ignore"])
  assert_eq(result, Some("ignore"))
}

///|
test "skip_reason extracts reason from @skip with quoted reason" {
  let result = skip_reason(["@skip(\"flaky on CI\")"], ["@skip", "@ignore"])
  assert_eq(result, Some("flaky on CI"))
}

///|
test "skip_reason extracts reason from @ignore with quoted reason" {
  let result = skip_reason(["@ignore(\"not implemented\")"], [
    "@skip", "@ignore",
  ])
  assert_eq(result, Some("not implemented"))
}

///|
test "skip_reason uses tag name for empty parens" {
  let result = skip_reason(["@skip()"], ["@skip", "@ignore"])
  assert_eq(result, Some("skip"))
}

///|
test "skip_reason uses tag name for unquoted content" {
  let result = skip_reason(["@skip(no quotes)"], ["@skip", "@ignore"])
  assert_eq(result, Some("skip"))
}

///|
test "skip_reason works with custom skip tags" {
  let result = skip_reason(["@wip"], ["@wip"])
  assert_eq(result, Some("wip"))
}

///|
test "skip_reason returns first match" {
  let result = skip_reason(["@ignore(\"a\")", "@skip(\"b\")"], [
    "@skip", "@ignore",
  ])
  assert_eq(result, Some("a"))
}

///|
test "MoonspecConfig::from_json5 parses top-level no_color" {
  assert_eq(
    MoonspecConfig::from_json5("{ no_color: true }").no_color,
    Some(true),
  )
  assert_eq(
    MoonspecConfig::from_json5("{ no_color: false }").no_color,
    Some(false),
  )
  assert_eq(MoonspecConfig::from_json5("{}").no_color, None)
}

///|
test "merge: no_color override takes precedence" {
  let base = MoonspecConfig::from_json5("{ no_color: true }")
  assert_eq(base.merge(MoonspecConfig::empty()).no_color, Some(true))
  let override_ = MoonspecConfig::from_json5("{ no_color: false }")
  assert_eq(base.merge(override_).no_color, Some(false))
}

///|
test "TestKind parses the config and CLI values" {
  assert_eq(TestKind::parse("wbtest"), Some(WhiteBox))
  assert_eq(TestKind::parse("test"), Some(BlackBox))
  assert_eq(TestKind::parse("blackbox"), None)
}

///|
test "from_json5 reads test_kind" {
  assert_eq(
    MoonspecConfig::from_json5("{ test_kind: \"test\" }").test_kind,
    Some(BlackBox),
  )
  assert_eq(MoonspecConfig::from_json5("{ world: \"W\" }").test_kind, None)
}

///|
test "merge takes test_kind from the override" {
  let base = MoonspecConfig::from_json5("{ test_kind: \"test\" }")
  let override_ = MoonspecConfig::from_json5("{ test_kind: \"wbtest\" }")
  assert_eq(base.merge(override_).test_kind, Some(WhiteBox))
  assert_eq(base.merge(MoonspecConfig::empty()).test_kind, Some(BlackBox))
}

///|
test "execution parses independently of generation mode and test kind" {
  let config = MoonspecConfig::from_json5(
    "{ execution: 'sync', mode: 'per-feature', test_kind: 'test' }",
  )
  assert_eq(config.execution, Some(Scalar(Sync)))
  assert_eq(config.resolve_mode("features/login.feature"), "per-feature")
  assert_eq(config.test_kind, Some(BlackBox))
  assert_eq(MoonspecConfig::empty().execution, None)
  assert_eq(
    MoonspecConfig::from_json5("{ execution: 'async' }").execution,
    Some(Scalar(Async)),
  )
}

///|
test "invalid execution config is rejected with an actionable diagnostic" {
  for
    input in [
      "{ execution: 'parallel' }", "{ execution: true }", "{ execution: null }",
    ] {
    let message = try {
      ignore(MoonspecConfig::from_json5(input))
      "accepted invalid execution"
    } catch {
      ConfigError::InvalidExecution(message) => message
    }
    assert_true(message.contains("execution"))
    assert_true(message.contains("async"))
    assert_true(message.contains("sync"))
  }
}

///|
test "execution merge retains a parent and lets a child override either mode" {
  let sync = MoonspecConfig::from_json5("{ execution: 'sync' }")
  let async_ = MoonspecConfig::from_json5("{ execution: 'async' }")
  assert_eq(sync.merge(MoonspecConfig::empty()).execution, Some(Scalar(Sync)))
  assert_eq(sync.merge(async_).execution, Some(Scalar(Async)))
  assert_eq(async_.merge(sync).execution, Some(Scalar(Sync)))
}

///|
test "object execution resolves every supported target and keeps shared factories" {
  let config = MoonspecConfig::from_json5(
    (
      #|{ execution: { default: 'async', targets: { 'wasm-gc': 'sync' } },
      #|  shared: { package: 'consumer/module/definitions', world_factory: 'world', options_factory: 'options' } }
    ),
  )
  assert_eq(config.execution.unwrap().resolve(WasmGc), Sync)
  assert_eq(config.execution.unwrap().resolve(Native), Async)
  assert_eq(config.shared.unwrap().package_path, "consumer/module/definitions")
}

///|
test "execution policy rejects incomplete invalid and unsupported target maps" {
  for
    execution in [
      "{}", "{default:'parallel'}", "{default:'sync', extra: true}", "{default:'sync', targets: []}",
      "{default:'sync', targets:{llvm:'sync'}}", "{default:'sync', targets:{native:'parallel'}}",
      "{default:'async'}", "{default:'sync', targets:{'wasm-gc':'async'}}",
    ] {
    let message = try {
      ignore(MoonspecConfig::from_json5("{execution:" + execution + "}"))
      "accepted invalid execution"
    } catch {
      InvalidExecution(message) => message
    }
    assert_true(message.contains("execution"), msg=execution + ": " + message)
    assert_false(message == "accepted invalid execution", msg=execution)
  }
}

///|
test "shared factories reject missing unsafe and unknown fields" {
  for
    shared in [
      "true", "{}", "{package:'',world_factory:'world',options_factory:'options'}",
      "{package:'consumer/../defs',world_factory:'world',options_factory:'options'}",
      "{package:'consumer/defs',world_factory:'x()',options_factory:'options'}",
      "{package:'consumer/defs',world_factory:'world',options_factory:'bad.name'}",
      "{package:'consumer/defs',world_factory:'world',options_factory:'options',extra:1}",
    ] {
    let message = try {
      ignore(MoonspecConfig::from_json5("{shared:" + shared + "}"))
      "accepted"
    } catch {
      InvalidExecution(message) => message
    }
    assert_true(message.contains("shared"), msg=shared + ": " + message)
  }
}

///|
test "nearer execution and shared values replace complete inherited objects" {
  let parent = MoonspecConfig::from_json5(
    "{execution:{default:'async',targets:{'wasm-gc':'sync',native:'sync'}},shared:{package:'consumer/definitions',world_factory:'world',options_factory:'options'}}",
  )
  let child = MoonspecConfig::from_json5(
    "{execution:{default:'sync',targets:{}},shared:{package:'consumer/other',world_factory:'make_world',options_factory:'make_options'}}",
  )
  let merged = parent.merge(child)
  assert_eq(merged.execution.unwrap().resolve(Native), Sync)
  assert_eq(merged.execution.unwrap().resolve(Js), Sync)
  assert_eq(merged.shared.unwrap().package_path, "consumer/other")
  assert_eq(parent.merge(MoonspecConfig::empty()), parent)
  assert_eq(
    parent.merge(MoonspecConfig::from_json5("{execution:'sync'}")).execution,
    Some(Scalar(Sync)),
  )
  let async_child = MoonspecConfig::from_json5(
    "{execution:{default:'async',targets:{'wasm-gc':'sync'}}}",
  )
  assert_eq(parent.merge(async_child).execution.unwrap().resolve(Native), Async)
}

///|
test "shared factories reject reserved MoonBit identifiers" {
  let message = try {
    ignore(
      MoonspecConfig::from_json5(
        "{shared:{package:'consumer/definitions',world_factory:'fn',options_factory:'options'}}",
      ),
    )
    "accepted"
  } catch {
    InvalidExecution(message) => message
  }
  assert_true(message.contains("shared"))
}
