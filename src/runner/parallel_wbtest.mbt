///|
test "run with parallel parameter executes all features" {
  let registry = @core.StepRegistry::new()
  registry.given("a step", fn(_args) {  })
  let features = [
    "Feature: A\n\n  Scenario: S1\n    Given a step\n", "Feature: B\n\n  Scenario: S2\n    Given a step\n",
  ]
  let result = run(registry, features, parallel=2)
  assert_eq(result.summary.total_scenarios, 2)
  assert_eq(result.summary.passed, 2)
}

///|
test "run with parallel=0 falls back to sequential" {
  let registry = @core.StepRegistry::new()
  registry.given("a step", fn(_args) {  })
  let features = ["Feature: A\n\n  Scenario: S1\n    Given a step\n"]
  let result = run(registry, features, parallel=0)
  assert_eq(result.summary.total_scenarios, 1)
  assert_eq(result.summary.passed, 1)
}

///|
test "run with parallel preserves feature order" {
  let registry = @core.StepRegistry::new()
  registry.given("step a", fn(_args) {  })
  registry.given("step b", fn(_args) {  })
  let features = [
    "Feature: First\n\n  Scenario: S1\n    Given step a\n", "Feature: Second\n\n  Scenario: S2\n    Given step b\n",
  ]
  let result = run(registry, features, parallel=4)
  assert_eq(result.features[0].name, "First")
  assert_eq(result.features[1].name, "Second")
}

///|
test "run with parallel and tag filtering" {
  let registry = @core.StepRegistry::new()
  registry.given("a step", fn(_args) {  })
  let features = [
    "Feature: A\n\n  @smoke\n  Scenario: S1\n    Given a step\n", "Feature: B\n\n  Scenario: S2\n    Given a step\n",
  ]
  let result = run(registry, features, parallel=2, tag_expr="@smoke")
  assert_eq(result.summary.total_scenarios, 1)
  assert_eq(result.summary.passed, 1)
}
