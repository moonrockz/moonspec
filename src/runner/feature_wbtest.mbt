///|
test "execute_feature parses and runs all scenarios" {
  let registry = @core.StepRegistry::new()
  let mut total = 0
  registry.given("I have {int} cucumbers", fn(args) {
    match args[0] {
      @core.StepArg::IntArg(n) => total = n
      _ => ()
    }
  })
  registry.when("I eat {int} cucumbers", fn(args) {
    match args[0] {
      @core.StepArg::IntArg(n) => total = total - n
      _ => ()
    }
  })
  registry.then("I should have {int} cucumbers", fn(args) raise {
    match args[0] {
      @core.StepArg::IntArg(n) => assert_eq(total, n)
      _ => ()
    }
  })
  let feature_content = "Feature: Simple math\n\n  Scenario: Addition\n    Given I have 5 cucumbers\n    When I eat 3 cucumbers\n    Then I should have 2 cucumbers\n\n  Scenario: No eating\n    Given I have 10 cucumbers\n    Then I should have 10 cucumbers\n"
  let result = execute_feature(registry, feature_content)
  assert_eq(result.name, "Simple math")
  assert_eq(result.scenarios.length(), 2)
  assert_eq(result.scenarios[0].status, ScenarioStatus::Passed)
  assert_eq(result.scenarios[1].status, ScenarioStatus::Passed)
}

///|
test "execute_feature handles undefined steps" {
  let registry = @core.StepRegistry::new()
  let feature_content = "Feature: Unknown\n\n  Scenario: Missing step\n    Given something undefined\n"
  let result = execute_feature(registry, feature_content)
  assert_eq(result.scenarios[0].status, ScenarioStatus::Undefined)
}
