///|
test "generate_test_file produces async test blocks" {
  let feature_content = "Feature: Login\n\n  Scenario: Valid credentials\n    Given a user\n    When they log in\n    Then they see the dashboard\n"
  let output = generate_test_file(feature_content, "features/login.feature")
  assert_true(output.contains("async test"))
  assert_true(output.contains("Feature: Login / Scenario: Valid credentials"))
  assert_true(output.contains("features/login.feature"))
}

///|
test "generate_test_file includes hash for staleness detection" {
  let content = "Feature: X\n\n  Scenario: Y\n    Given z\n"
  let output = generate_test_file(content, "features/x.feature")
  assert_true(output.contains("// moonspec:hash:"))
}

///|
test "feature_to_test_filename converts paths" {
  assert_eq(
    feature_to_test_filename("features/login.feature"),
    "login_feature_wbtest.mbt",
  )
  assert_eq(
    feature_to_test_filename("features/admin/users.feature"),
    "admin_users_feature_wbtest.mbt",
  )
}

///|
test "feature_to_test_filename names black-box tests on request" {
  assert_eq(
    feature_to_test_filename("features/login.feature", kind=BlackBox),
    "login_feature_test.mbt",
  )
  assert_eq(
    feature_to_test_filename("features/login.feature", kind=WhiteBox),
    "login_feature_wbtest.mbt",
  )
}

///|
test "feature_to_test_filename converts Markdown with Gherkin paths" {
  assert_eq(
    feature_to_test_filename("features/login.feature.md"),
    "login_feature_wbtest.mbt",
  )
  assert_eq(
    feature_to_test_filename("features/admin/users.feature.md"),
    "admin_users_feature_wbtest.mbt",
  )
}

///|
test "generate_test_file parses Markdown with Gherkin sources" {
  let content = "# Feature: Login\n\n## Scenario: Success\n\n- Given a user\n"
  let output = generate_test_file(content, "features/login.feature.md")
  assert_true(output.contains("Scenario: Success"))
  assert_false(output.contains("ERROR"))
}

///|
test "generate_test_file handles scenario outline with examples" {
  let content = "Feature: Math\n\n  Scenario Outline: Add numbers\n    Given <a> and <b>\n    Then result is <sum>\n\n    Examples:\n      | a | b | sum |\n      | 1 | 2 | 3   |\n      | 4 | 5 | 9   |\n"
  let output = generate_test_file(content, "features/math.feature")
  assert_true(output.contains("async test"))
  assert_true(output.contains("a=1"))
  assert_true(output.contains("a=4"))
}

///|
test "generate_test_file handles empty feature" {
  let content = "Feature: Empty\n"
  let output = generate_test_file(content, "features/empty.feature")
  assert_true(output.contains("// moonspec:hash:"))
  // Should not contain any async test blocks
  assert_true(!output.contains("async test"))
}

///|
test "simple_hash produces consistent output" {
  let h1 = simple_hash("hello")
  let h2 = simple_hash("hello")
  assert_eq(h1, h2)
  // Different input should produce different hash
  let h3 = simple_hash("world")
  assert_true(h1 != h3)
}

///|
test "per-scenario mode generates runner call with world" {
  let content = "Feature: Login\n\n  Scenario: Valid credentials\n    Given a user\n    When they log in\n    Then they see the dashboard\n"
  let config = CodegenConfig::{
    execution: Scalar(Async),
    shared: None,
    mode: PerScenario,
    world: "MyWorld",
    skip_tags: None,
    formatters: None,
    no_color: false,
  }
  let output = generate_test_file(content, "features/login.feature", config~)
  assert_true(output.contains("@moonspec.run_or_fail"))
  assert_true(output.contains("MyWorld::default"))
  assert_true(output.contains("@moonspec.FeatureSource::File"))
  assert_true(output.contains("options.scenario_name("))
  assert_true(output.contains("features/login.feature"))
  assert_true(!output.contains("|> ignore"))
  assert_true(!output.contains("assert_eq!(result.summary.failed, 0)"))
}

///|
test "per-feature mode generates file-based runner call" {
  let content = "Feature: Login\n\n  Scenario: Valid credentials\n    Given a user\n"
  let config = CodegenConfig::{
    execution: Scalar(Async),
    shared: None,
    mode: PerFeature,
    world: "MyWorld",
    skip_tags: None,
    formatters: None,
    no_color: false,
  }
  let output = generate_test_file(content, "features/login.feature", config~)
  assert_true(output.contains("@moonspec.run_or_fail"))
  assert_true(output.contains("MyWorld::default"))
  assert_true(output.contains("@moonspec.FeatureSource::File"))
  assert_true(output.contains("features/login.feature"))
  // Should produce a single test for the whole feature
  assert_true(output.contains("Feature: Login"))
  assert_true(!output.contains("Scenario:"))
}

///|
test "per-scenario mode uses file source with scenario_name" {
  let content = "Feature: Auth\n\n  Background:\n    Given a logged in user\n\n  Scenario: View profile\n    When I visit my profile\n    Then I see my name\n"
  let config = CodegenConfig::{
    execution: Scalar(Async),
    shared: None,
    mode: PerScenario,
    world: "AuthWorld",
    skip_tags: None,
    formatters: None,
    no_color: false,
  }
  let output = generate_test_file(content, "features/auth.feature", config~)
  assert_true(output.contains("@moonspec.FeatureSource::File"))
  assert_true(output.contains("options.scenario_name("))
  assert_true(output.contains("View profile"))
}

///|
test "per-scenario mode expands scenario outline" {
  let content = "Feature: Math\n\n  Scenario Outline: Add numbers\n    Given <a> and <b>\n    Then result is <sum>\n\n    Examples:\n      | a | b | sum |\n      | 1 | 2 | 3   |\n      | 4 | 5 | 9   |\n"
  let config = CodegenConfig::{
    execution: Scalar(Async),
    shared: None,
    mode: PerScenario,
    world: "MathWorld",
    skip_tags: None,
    formatters: None,
    no_color: false,
  }
  let output = generate_test_file(content, "features/math.feature", config~)
  assert_true(output.contains("a=1, b=2, sum=3"))
  assert_true(output.contains("a=4, b=5, sum=9"))
  assert_true(output.contains("MathWorld::default"))
  assert_true(output.contains("@moonspec.FeatureSource::File"))
  assert_true(output.contains("options.scenario_name("))
}

///|
test "stub mode when world is empty" {
  let content = "Feature: Login\n\n  Scenario: Valid credentials\n    Given a user\n"
  let output = generate_test_file(content, "features/login.feature")
  assert_true(output.contains("ignore"))
  assert_true(!output.contains("@moonspec.run"))
}

///|
test "config from_json5 parses world and mode" {
  let json5 = "{ \"world\": \"CalcWorld\", \"mode\": \"per-feature\" }"
  let config = CodegenConfig::from_json5(json5) catch {
    _ => {
      assert_true(false)
      return
    }
  }
  assert_eq(config.world, "CalcWorld")
  assert_eq(config.mode, PerFeature)
}

///|
test "config from_json5 defaults to per-scenario" {
  let json5 = "{ \"world\": \"MyWorld\" }"
  let config = CodegenConfig::from_json5(json5) catch {
    _ => {
      assert_true(false)
      return
    }
  }
  assert_eq(config.mode, PerScenario)
}

///|
test "per-scenario mode omits skip_tags when None" {
  let content = "Feature: Login\n\n  Scenario: Valid credentials\n    Given a user\n"
  let config = CodegenConfig::{
    execution: Scalar(Async),
    shared: None,
    mode: PerScenario,
    world: "MyWorld",
    skip_tags: None,
    formatters: None,
    no_color: false,
  }
  let output = generate_test_file(content, "features/login.feature", config~)
  assert_true(output.contains("options.scenario_name("))
  assert_true(!output.contains("options.skip_tags("))
}

///|
test "per-scenario mode emits skip_tags when configured" {
  let content = "Feature: Login\n\n  Scenario: Valid credentials\n    Given a user\n"
  let config = CodegenConfig::{
    execution: Scalar(Async),
    shared: None,
    mode: PerScenario,
    world: "MyWorld",
    skip_tags: Some(["@skip", "@wip"]),
    formatters: None,
    no_color: false,
  }
  let output = generate_test_file(content, "features/login.feature", config~)
  assert_true(output.contains("options.skip_tags([\"@skip\", \"@wip\"])"))
}

///|
test "per-feature mode emits skip_tags when configured" {
  let content = "Feature: Login\n\n  Scenario: Valid credentials\n    Given a user\n"
  let config = CodegenConfig::{
    execution: Scalar(Async),
    shared: None,
    mode: PerFeature,
    world: "MyWorld",
    skip_tags: Some(["@ignore"]),
    formatters: None,
    no_color: false,
  }
  let output = generate_test_file(content, "features/login.feature", config~)
  assert_true(output.contains("options.skip_tags([\"@ignore\"])"))
}

///|
test "skip_tags not emitted for stub tests" {
  let content = "Feature: Login\n\n  Scenario: Valid credentials\n    Given a user\n"
  let config = CodegenConfig::{
    execution: Scalar(Async),
    shared: None,
    mode: PerScenario,
    world: "",
    skip_tags: Some(["@skip"]),
    formatters: None,
    no_color: false,
  }
  let output = generate_test_file(content, "features/login.feature", config~)
  assert_true(output.contains("ignore(\"\")"))
  assert_true(!output.contains("options.skip_tags("))
}

///|
test "empty skip_tags array emits empty array call" {
  let content = "Feature: Login\n\n  Scenario: Valid credentials\n    Given a user\n"
  let config = CodegenConfig::{
    execution: Scalar(Async),
    shared: None,
    mode: PerScenario,
    world: "MyWorld",
    skip_tags: Some([]),
    formatters: None,
    no_color: false,
  }
  let output = generate_test_file(content, "features/login.feature", config~)
  assert_true(output.contains("options.skip_tags([])"))
}

///|
test "codegen emits default pretty formatter when formatters is None" {
  let content = "Feature: Login\n\n  Scenario: Valid credentials\n    Given a user\n"
  let config = CodegenConfig::{
    execution: Scalar(Async),
    shared: None,
    mode: PerScenario,
    world: "MyWorld",
    skip_tags: None,
    formatters: None,
    no_color: false,
  }
  let output = generate_test_file(content, "features/login.feature", config~)
  assert_true(
    output.contains(
      "options.add_formatter(@format.PrettyFormatter::new(), @moonspec.OutputDest::Stdout)",
    ),
  )
}

///|
test "codegen emits add_formatter for pretty on stdout" {
  let content = "Feature: Login\n\n  Scenario: Valid credentials\n    Given a user\n"
  let config = CodegenConfig::{
    execution: Scalar(Async),
    shared: None,
    mode: PerScenario,
    world: "MyWorld",
    skip_tags: None,
    formatters: Some([
      @config.FormatterConfig::{
        type_: "pretty",
        output: "stdout",
        no_color: false,
      },
    ]),
    no_color: false,
  }
  let output = generate_test_file(content, "features/login.feature", config~)
  assert_true(
    output.contains(
      "options.add_formatter(@format.PrettyFormatter::new(), @moonspec.OutputDest::Stdout)",
    ),
  )
}

///|
test "codegen emits add_formatter for junit to file" {
  let content = "Feature: Login\n\n  Scenario: Valid credentials\n    Given a user\n"
  let config = CodegenConfig::{
    execution: Scalar(Async),
    shared: None,
    mode: PerScenario,
    world: "MyWorld",
    skip_tags: None,
    formatters: Some([
      @config.FormatterConfig::{
        type_: "junit",
        output: "reports/results.xml",
        no_color: false,
      },
    ]),
    no_color: false,
  }
  let output = generate_test_file(content, "features/login.feature", config~)
  assert_true(
    output.contains(
      "options.add_formatter(@format.JUnitFormatter::new(), @moonspec.OutputDest::File(\"reports/results.xml\"))",
    ),
  )
}

///|
test "codegen emits add_formatter with no_color for pretty" {
  let content = "Feature: Login\n\n  Scenario: Valid credentials\n    Given a user\n"
  let config = CodegenConfig::{
    execution: Scalar(Async),
    shared: None,
    mode: PerScenario,
    world: "MyWorld",
    skip_tags: None,
    formatters: Some([
      @config.FormatterConfig::{
        type_: "pretty",
        output: "stderr",
        no_color: true,
      },
    ]),
    no_color: false,
  }
  let output = generate_test_file(content, "features/login.feature", config~)
  assert_true(
    output.contains(
      "options.add_formatter(@format.PrettyFormatter::new(no_color=true), @moonspec.OutputDest::Stderr)",
    ),
  )
}

///|
test "codegen emits no formatter lines for empty formatters array" {
  let content = "Feature: Login\n\n  Scenario: Valid credentials\n    Given a user\n"
  let config = CodegenConfig::{
    execution: Scalar(Async),
    shared: None,
    mode: PerScenario,
    world: "MyWorld",
    skip_tags: None,
    formatters: Some([]),
    no_color: false,
  }
  let output = generate_test_file(content, "features/login.feature", config~)
  assert_true(!output.contains("add_formatter"))
}

///|
fn skip_config(mode : CodegenMode, skip_tags : Array[String]?) -> CodegenConfig {
  CodegenConfig::{
    execution: Scalar(Async),
    shared: None,
    mode,
    world: "MyWorld",
    skip_tags,
    formatters: Some([]),
    no_color: false,
  }
}

///|
test "per-scenario mode emits #skip for a scenario with a skip tag" {
  let content = "Feature: Login\n\n  @skip\n  Scenario: Skipped\n    Given a user\n\n  Scenario: Runs\n    Given a user\n"
  let output = generate_test_file(
    content,
    "features/login.feature",
    config=skip_config(PerScenario, None),
  )
  assert_true(
    output.contains(
      "#skip(\"skip\")\nasync test \"Feature: Login / Scenario: Skipped\" {\n",
    ),
  )
  assert_true(
    output.contains(
      "\nasync test \"Feature: Login / Scenario: Runs\" {\n  let options",
    ),
  )
  assert_eq(output.split("#skip(").count(), 2)
}

///|
test "skipped test clears runtime skip tags so --include-skipped runs it" {
  let content = "Feature: Login\n\n  @wip\n  Scenario: Skipped\n    Given a user\n"
  let output = generate_test_file(
    content,
    "features/login.feature",
    config=skip_config(PerScenario, Some(["@wip"])),
  )
  assert_true(output.contains("#skip(\"wip\")"))
  assert_true(output.contains("options.skip_tags([])"))
  assert_true(!output.contains("options.skip_tags([\"@wip\"])"))
}

///|
test "feature-level skip tag skips every scenario" {
  let content = "@ignore\nFeature: Login\n\n  Scenario: A\n    Given a user\n\n  Scenario: B\n    Given a user\n"
  let output = generate_test_file(
    content,
    "features/login.feature",
    config=skip_config(PerScenario, None),
  )
  assert_eq(output.split("#skip(\"ignore\")\nasync test").count(), 3)
}

///|
test "skip tag argument becomes the #skip reason" {
  let content = "Feature: Login\n\n  @skip(\"flaky\")\n  Scenario: A\n    Given a user\n"
  let output = generate_test_file(
    content,
    "features/login.feature",
    config=skip_config(PerScenario, None),
  )
  assert_true(output.contains("#skip(\"flaky\")\nasync test"))
}

///|
test "configured skip tags replace the defaults" {
  let content = "Feature: Login\n\n  @skip\n  Scenario: A\n    Given a user\n\n  @wip\n  Scenario: B\n    Given a user\n"
  let output = generate_test_file(
    content,
    "features/login.feature",
    config=skip_config(PerScenario, Some(["@wip"])),
  )
  assert_true(
    output.contains(
      "#skip(\"wip\")\nasync test \"Feature: Login / Scenario: B\"",
    ),
  )
  assert_eq(output.split("#skip(").count(), 2)
}

///|
test "empty skip tags emit no #skip" {
  let content = "Feature: Login\n\n  @skip\n  Scenario: A\n    Given a user\n"
  let output = generate_test_file(
    content,
    "features/login.feature",
    config=skip_config(PerScenario, Some([])),
  )
  assert_true(!output.contains("#skip("))
}

///|
test "examples-level skip tag skips only the rows of that block" {
  let content = "Feature: Math\n\n  Scenario Outline: Add\n    Given <a>\n\n    Examples:\n      | a |\n      | 1 |\n\n    @skip\n    Examples:\n      | a |\n      | 2 |\n"
  let output = generate_test_file(
    content,
    "features/math.feature",
    config=skip_config(PerScenario, None),
  )
  assert_true(
    output.contains(
      "#skip(\"skip\")\nasync test \"Feature: Math / Scenario: Add (a=2)\"",
    ),
  )
  assert_eq(output.split("#skip(").count(), 2)
}

///|
test "per-feature mode emits #skip only for a feature-level skip tag" {
  let scenario_tagged = "Feature: Login\n\n  @skip\n  Scenario: A\n    Given a user\n"
  let output = generate_test_file(
    scenario_tagged,
    "features/login.feature",
    config=skip_config(PerFeature, None),
  )
  assert_true(!output.contains("#skip("))
  let feature_tagged = "@skip\nFeature: Login\n\n  Scenario: A\n    Given a user\n"
  let output = generate_test_file(
    feature_tagged,
    "features/login.feature",
    config=skip_config(PerFeature, None),
  )
  assert_true(
    output.contains("#skip(\"skip\")\nasync test \"Feature: Login\" {\n"),
  )
  assert_true(output.contains("options.skip_tags([])"))
}

///|
test "stub tests emit no #skip" {
  let content = "Feature: Login\n\n  @skip\n  Scenario: A\n    Given a user\n"
  let config = CodegenConfig::{
    execution: Scalar(Async),
    shared: None,
    mode: PerScenario,
    world: "",
    skip_tags: None,
    formatters: None,
    no_color: false,
  }
  let output = generate_test_file(content, "features/login.feature", config~)
  assert_true(!output.contains("#skip("))
}

///|
fn no_color_config(
  mode : CodegenMode,
  formatters : Array[@config.FormatterConfig]?,
) -> CodegenConfig {
  CodegenConfig::{
    execution: Scalar(Async),
    shared: None,
    mode,
    world: "MyWorld",
    skip_tags: None,
    formatters,
    no_color: true,
  }
}

///|
test "no_color emits options.no_color(true) in every generated test" {
  let content = "Feature: Login\n\n  Scenario: A\n    Given a user\n\n  Scenario: B\n    Given a user\n"
  let per_scenario = generate_test_file(
    content,
    "features/login.feature",
    config=no_color_config(PerScenario, Some([])),
  )
  assert_eq(per_scenario.split("  options.no_color(true)\n").count(), 3)
  let per_feature = generate_test_file(
    content,
    "features/login.feature",
    config=no_color_config(PerFeature, Some([])),
  )
  assert_eq(per_feature.split("  options.no_color(true)\n").count(), 2)
}

///|
test "no_color turns off color in pretty formatters" {
  let content = "Feature: Login\n\n  Scenario: A\n    Given a user\n"
  let default_fmt = generate_test_file(
    content,
    "features/login.feature",
    config=no_color_config(PerScenario, None),
  )
  assert_true(
    default_fmt.contains("@format.PrettyFormatter::new(no_color=true)"),
  )
  let configured = generate_test_file(
    content,
    "features/login.feature",
    config=no_color_config(
      PerScenario,
      Some([{ type_: "pretty", output: "stdout", no_color: false, }]),
    ),
  )
  assert_true(
    configured.contains("@format.PrettyFormatter::new(no_color=true)"),
  )
}

///|
test "no_color false emits no options.no_color line" {
  let content = "Feature: Login\n\n  Scenario: A\n    Given a user\n"
  let output = generate_test_file(content, "features/login.feature", config=CodegenConfig::{
    ..CodegenConfig::default(),
    world: "MyWorld",
  })
  assert_false(output.contains("options.no_color("))
}

///|
test "generate_test_file gives the same output with or without a leading ./" {
  let content = "Feature: Login\n\n  Scenario: A\n    Given a user\n"
  let config = CodegenConfig::{ ..CodegenConfig::default(), world: "MyWorld", }
  let plain = generate_test_file(content, "features/login.feature", config~)
  let dotted = generate_test_file(content, "./features/login.feature", config~)
  assert_eq(dotted, plain)
  assert_false(plain.contains("./features"))
}

///|
test "codegen config parses sync execution with async as the default" {
  assert_eq(CodegenConfig::default().execution, Scalar(Async))
  assert_eq(CodegenConfig::from_json5("{}").execution, Scalar(Async))
  assert_eq(
    CodegenConfig::from_json5("{ execution: 'sync' }").execution,
    Scalar(Sync),
  )
}

///|
test "codegen config rejects invalid execution values" {
  for input in ["{ execution: 'parallel' }", "{ execution: 42 }"] {
    let message = try {
      ignore(CodegenConfig::from_json5(input))
      "accepted invalid execution"
    } catch {
      @config.ConfigError::InvalidExecution(message) => message
      _ => "unexpected error"
    }
    assert_true(message.contains("execution"))
    assert_true(message.contains("async"))
    assert_true(message.contains("sync"))
  }
}

///|
test "sync per-feature emits ordinary test and embeds the original source URI and text" {
  let content = "Feature: Login\n\n  Scenario: A\n    Given a user\n"
  let config = CodegenConfig::{
    ..CodegenConfig::default(),
    mode: PerFeature,
    world: "MyWorld",
    execution: Scalar(Sync),
    shared: None,
  }
  let output = generate_test_file(content, "./features/login.feature", config~)
  assert_true(output.contains("test \"Feature: Login\" {"))
  assert_false(output.contains("async test"))
  assert_true(output.contains("@moonspec.run_or_fail_sync("))
  assert_true(
    output.contains(
      "@moonspec.FeatureSource::Text(\"./features/login.feature\", \"Feature: Login\\n\\n  Scenario: A\\n    Given a user\\n\")",
    ),
  )
  assert_false(output.contains("FeatureSource::File("))
  assert_false(output.contains("options.scenario_name("))
}

///|
test "sync per-scenario preserves outline row filtering with the full source" {
  let content = "Feature: Counts\n  Scenario Outline: Count\n    Given <n> users\n    Examples:\n      | n |\n      | 1 |\n      | 2 |\n"
  let config = CodegenConfig::{
    ..CodegenConfig::default(),
    world: "MyWorld",
    execution: Scalar(Sync),
    shared: None,
  }
  let output = generate_test_file(content, "features/counts.feature", config~)
  assert_false(output.contains("async test"))
  assert_true(
    output.contains("test \"Feature: Counts / Scenario: Count (n=1)\" {"),
  )
  assert_true(output.contains("options.scenario_name(\"Count (n=1)\")"))
  assert_true(output.contains("options.scenario_name(\"Count (n=2)\")"))
  assert_eq(output.split("@moonspec.run_or_fail_sync(").count(), 3)
  assert_eq(output.split("FeatureSource::Text(").count(), 3)
  assert_true(output.contains("Scenario Outline: Count\\n"))
  assert_false(output.contains("FeatureSource::File("))
}

///|
test "sync Markdown embeds prose and escaped source with formatter and skip settings" {
  let content = "`@skip`\r\n# Feature: Login\r\n\r\nA path: C:\\tmp\\{literal}\t雪\r\n\r\n## Scenario: A\r\n\r\n- Given a user\r\n"
  for mode in [CodegenMode::PerScenario, PerFeature] {
    let config = CodegenConfig::{
      ..CodegenConfig::default(),
      mode,
      world: "MyWorld",
      execution: Scalar(Sync),
      shared: None,
      no_color: true,
    }
    let output = generate_test_file(
      content,
      "features/login.feature.md",
      config~,
    )
    assert_false(output.contains("async test"))
    assert_true(output.contains("#skip(\"skip\")"))
    assert_true(output.contains("options.skip_tags([])"))
    assert_true(output.contains("options.no_color(true)"))
    assert_true(output.contains("@format.PrettyFormatter::new(no_color=true)"))
    assert_true(
      output.contains(
        "FeatureSource::Text(\"features/login.feature.md\", \"`@skip`\\r\\n",
      ),
    )
    assert_true(output.contains("A path: C:\\\\tmp\\\\{literal}\\t雪\\r\\n"))
  }
}

///|
test "sync preserves configured formatter destinations and custom skip tags" {
  let content = "Feature: Login\n  Scenario: A\n    Given a user\n"
  for mode in [CodegenMode::PerScenario, PerFeature] {
    let config = CodegenConfig::{
      ..CodegenConfig::default(),
      mode,
      world: "MyWorld",
      execution: Scalar(Sync),
      shared: None,
      skip_tags: Some(["@wip"]),
      formatters: Some([
        { type_: "junit", output: "reports/results.xml", no_color: false, },
        { type_: "messages", output: "stderr", no_color: false, },
      ]),
    }
    let output = generate_test_file(content, "features/login.feature", config~)
    assert_true(output.contains("options.skip_tags([\"@wip\"])"))
    assert_true(
      output.contains(
        "@format.JUnitFormatter::new(), @moonspec.OutputDest::File(\"reports/results.xml\")",
      ),
    )
    assert_true(
      output.contains(
        "@format.MessagesFormatter::new(), @moonspec.OutputDest::Stderr",
      ),
    )
  }
}

///|
test "codegen parser retains targeted policy and shared options factory" {
  let config = CodegenConfig::from_json5(
    "{ execution: {default:'async', targets:{'wasm-gc':'sync'}}, shared:{package:'consumer/definitions',world_factory:'world',options_factory:'options'} }",
  )
  assert_eq(config.execution.resolve(WasmGc), Sync)
  assert_eq(config.execution.resolve(Native), Async)
  assert_eq(config.shared.unwrap().options_factory, "options")
}

///|
test "single-file rendering rejects shared package policies explicitly" {
  let config = CodegenConfig::from_json5(
    "{execution:{default:'sync'},shared:{package:'consumer/definitions',world_factory:'world',options_factory:'options'}}",
  )
  let message = try {
    ignore(
      generate_test_file(
        "Feature: Shared\n Scenario: Works\n  Given ready\n",
        "features/shared.feature",
        config~,
      ),
    )
    "accepted"
  } catch {
    SharedGenerationRequired => "use plan_shared_generation"
  }
  assert_eq(message, "use plan_shared_generation")
}

///|
test "shared generation plans portable source and thin target packages" {
  let config = CodegenConfig::from_json5(
    "{execution:{default:'async',targets:{'wasm-gc':'sync'}},shared:{package:'consumer/module/definitions',world_factory:'world',options_factory:'options'}}",
  )
  let plan = plan_shared_generation(
    [
      FeatureInput::{
        uri: "./features/shared.feature",
        content: "Feature: Shared\n Scenario: Works\n  Given ready\n",
        mode: PerScenario,
      },
    ],
    module_name="consumer/module",
    package_path="suite",
    config~,
  )
  let files = plan.files()
  assert_eq(files.length(), 6)
  assert_true(
    files[0].content.contains(
      "FeatureSource::Text(\"./features/shared.feature\"",
    ),
  )
  assert_true(files[0].content.contains("@definitions.options(["))
  let sync = files.filter(fn(f) { f.path == "sync/moon.pkg" })[0].content
  assert_true(sync.contains("supported_targets = \"wasm-gc\""))
  assert_false(sync.contains("moonbitlang/async"))
  let async_ = files.filter(fn(f) { f.path == "async/moon.pkg" })[0].content
  assert_true(async_.contains("supported_targets = \"wasm+js+native\""))
}

///|
test "scalar shared CLI override emits only the supported selected mode" {
  let config = CodegenConfig::from_json5(
    "{execution:'async',shared:{package:'consumer/definitions',world_factory:'world',options_factory:'options'}}",
  )
  let plan = plan_shared_generation(
    [
      FeatureInput::{
        uri: "feature.feature",
        content: "Feature: Shared\n Scenario: Works\n  Given ready\n",
        mode: PerFeature,
      },
    ],
    module_name="consumer",
    package_path="suite",
    config~,
  )
  assert_true(plan.files().any(f => f.path == "async/moon.pkg"))
  assert_false(plan.files().any(f => f.path == "sync/moon.pkg"))
}

///|
test "shared planner validates all feature sources before exposing output" {
  let config = CodegenConfig::from_json5(
    "{execution:{default:'sync'},shared:{package:'consumer/definitions',world_factory:'world',options_factory:'options'}}",
  )
  let inputs = [
    FeatureInput::{
      uri: "first.feature",
      content: "Feature: Shared\n Scenario: Works\n  Given ready\n",
      mode: PerScenario,
    },
    FeatureInput::{
      uri: "broken.feature",
      content: "Feature: Broken\n  Scenario: No\n  Examples:\n    | x | y |\n    | 1 |\n",
      mode: PerScenario,
    },
  ]
  let message = try {
    ignore(
      plan_shared_generation(
        inputs,
        module_name="consumer",
        package_path="suite",
        config~,
      ),
    )
    "accepted"
  } catch {
    InvalidPlan(message) => message
  }
  assert_true(message.contains("broken.feature"))
}
