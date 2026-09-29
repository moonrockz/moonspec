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
    "login_feature_test.mbt",
  )
  assert_eq(
    feature_to_test_filename("features/admin/users.feature"),
    "admin_users_feature_test.mbt",
  )
}

///|
test "feature_to_test_filename converts Markdown with Gherkin paths" {
  assert_eq(
    feature_to_test_filename("features/login.feature.md"),
    "login_feature_test.mbt",
  )
  assert_eq(
    feature_to_test_filename("features/admin/users.feature.md"),
    "admin_users_feature_test.mbt",
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
    mode: PerScenario,
    world: "MyWorld",
    skip_tags: None,
    formatters: None,
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
    mode: PerFeature,
    world: "MyWorld",
    skip_tags: None,
    formatters: None,
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
    mode: PerScenario,
    world: "AuthWorld",
    skip_tags: None,
    formatters: None,
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
    mode: PerScenario,
    world: "MathWorld",
    skip_tags: None,
    formatters: None,
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
    mode: PerScenario,
    world: "MyWorld",
    skip_tags: None,
    formatters: None,
  }
  let output = generate_test_file(content, "features/login.feature", config~)
  assert_true(output.contains("options.scenario_name("))
  assert_true(!output.contains("options.skip_tags("))
}

///|
test "per-scenario mode emits skip_tags when configured" {
  let content = "Feature: Login\n\n  Scenario: Valid credentials\n    Given a user\n"
  let config = CodegenConfig::{
    mode: PerScenario,
    world: "MyWorld",
    skip_tags: Some(["@skip", "@wip"]),
    formatters: None,
  }
  let output = generate_test_file(content, "features/login.feature", config~)
  assert_true(output.contains("options.skip_tags([\"@skip\", \"@wip\"])"))
}

///|
test "per-feature mode emits skip_tags when configured" {
  let content = "Feature: Login\n\n  Scenario: Valid credentials\n    Given a user\n"
  let config = CodegenConfig::{
    mode: PerFeature,
    world: "MyWorld",
    skip_tags: Some(["@ignore"]),
    formatters: None,
  }
  let output = generate_test_file(content, "features/login.feature", config~)
  assert_true(output.contains("options.skip_tags([\"@ignore\"])"))
}

///|
test "skip_tags not emitted for stub tests" {
  let content = "Feature: Login\n\n  Scenario: Valid credentials\n    Given a user\n"
  let config = CodegenConfig::{
    mode: PerScenario,
    world: "",
    skip_tags: Some(["@skip"]),
    formatters: None,
  }
  let output = generate_test_file(content, "features/login.feature", config~)
  assert_true(output.contains("ignore(\"\")"))
  assert_true(!output.contains("options.skip_tags("))
}

///|
test "empty skip_tags array emits empty array call" {
  let content = "Feature: Login\n\n  Scenario: Valid credentials\n    Given a user\n"
  let config = CodegenConfig::{
    mode: PerScenario,
    world: "MyWorld",
    skip_tags: Some([]),
    formatters: None,
  }
  let output = generate_test_file(content, "features/login.feature", config~)
  assert_true(output.contains("options.skip_tags([])"))
}

///|
test "codegen emits default pretty formatter when formatters is None" {
  let content = "Feature: Login\n\n  Scenario: Valid credentials\n    Given a user\n"
  let config = CodegenConfig::{
    mode: PerScenario,
    world: "MyWorld",
    skip_tags: None,
    formatters: None,
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
    mode: PerScenario,
    world: "MyWorld",
    skip_tags: None,
    formatters: Some([]),
  }
  let output = generate_test_file(content, "features/login.feature", config~)
  assert_true(!output.contains("add_formatter"))
}

///|
fn skip_config(mode : CodegenMode, skip_tags : Array[String]?) -> CodegenConfig {
  CodegenConfig::{ mode, world: "MyWorld", skip_tags, formatters: Some([]), }
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
    mode: PerScenario,
    world: "",
    skip_tags: None,
    formatters: None,
  }
  let output = generate_test_file(content, "features/login.feature", config~)
  assert_true(!output.contains("#skip("))
}
