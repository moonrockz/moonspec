///|
test "execute_scenario with all steps passing" {
  let registry = @core.StepRegistry::new()
  let mut count = 0
  registry.given("a passing step", fn(_args) { count = count + 1 })
  registry.when("another passing step", fn(_args) { count = count + 1 })
  registry.then("all is well", fn(_args) { count = count + 1 })
  let steps : Array[(String, String)] = [
    ("Given ", "a passing step"),
    ("When ", "another passing step"),
    ("Then ", "all is well"),
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test Feature",
    scenario_name="All pass",
    tags=[],
    steps~,
  )
  assert_eq(result.status, ScenarioStatus::Passed)
  assert_eq(result.steps.length(), 3)
  assert_eq(count, 3)
}

///|
test "execute_scenario skips remaining steps after failure" {
  let registry = @core.StepRegistry::new()
  registry.given("a passing step", fn(_args) {  })
  registry.when("a failing step", fn(_args) raise {
    raise Failure::Failure("boom")
  })
  registry.then("this should be skipped", fn(_args) {  })
  let steps : Array[(String, String)] = [
    ("Given ", "a passing step"),
    ("When ", "a failing step"),
    ("Then ", "this should be skipped"),
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test Feature",
    scenario_name="Failure test",
    tags=[],
    steps~,
  )
  assert_eq(result.status, ScenarioStatus::Failed)
  assert_true(result.steps[0].status.is_passed())
  assert_eq(result.steps[2].status, StepStatus::Skipped)
}

///|
test "execute_scenario marks undefined steps" {
  let registry = @core.StepRegistry::new()
  let steps : Array[(String, String)] = [("Given ", "an undefined step")]
  let result = execute_scenario(
    registry,
    feature_name="Test Feature",
    scenario_name="Undefined test",
    tags=[],
    steps~,
  )
  assert_eq(result.status, ScenarioStatus::Undefined)
  assert_eq(result.steps[0].status, StepStatus::Undefined)
}
