///|
async test "run single feature and collect summary" {
  let registry = @core.StepRegistry::new()
  registry.given("a step", fn(_args) {  })
  let features = ["Feature: One\n\n  Scenario: Pass\n    Given a step\n"]
  let result = run(registry, features)
  assert_eq(result.summary.total_scenarios, 1)
  assert_eq(result.summary.passed, 1)
  assert_eq(result.summary.failed, 0)
}

///|
async test "run multiple features" {
  let registry = @core.StepRegistry::new()
  registry.given("pass", fn(_args) {  })
  registry.given("fail", fn(_args) raise { raise Failure::Failure("fail") })
  let features = [
    "Feature: A\n\n  Scenario: Pass\n    Given pass\n", "Feature: B\n\n  Scenario: Fail\n    Given fail\n",
  ]
  let result = run(registry, features)
  assert_eq(result.summary.total_scenarios, 2)
  assert_eq(result.summary.passed, 1)
  assert_eq(result.summary.failed, 1)
  assert_eq(result.features.length(), 2)
}
