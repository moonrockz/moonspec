///|
test "execute_feature prepends background steps to each scenario" {
  let registry = @core.StepRegistry::new()
  let mut context = ""
  registry.given("a common setup", fn(_args) { context = "setup" })
  registry.when("I do something", fn(_args) {  })
  registry.then("it works", fn(_args) raise { assert_eq(context, "setup") })
  let content = "Feature: With Background\n\n  Background:\n    Given a common setup\n\n  Scenario: First\n    When I do something\n    Then it works\n\n  Scenario: Second\n    When I do something\n    Then it works\n"
  let result = execute_feature(registry, content)
  assert_eq(result.scenarios.length(), 2)
  // Each scenario should have 3 steps (1 background + 2 scenario)
  assert_eq(result.scenarios[0].steps.length(), 3)
  assert_eq(result.scenarios[1].steps.length(), 3)
  assert_eq(result.scenarios[0].status, ScenarioStatus::Passed)
}
