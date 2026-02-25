///|
test "StepStatus::Passed shows correctly" {
  inspect(StepStatus::Passed, content="Passed")
}

///|
test "StepStatus::Failed shows with error" {
  let status = StepStatus::Failed("assertion failed")
  inspect(status, content="Failed(\"assertion failed\")")
}

///|
test "StepStatus::Skipped shows correctly" {
  inspect(StepStatus::Skipped(None), content="Skipped(None)")
}

///|
test "StepStatus::Skipped with reason shows correctly" {
  inspect(
    StepStatus::Skipped(Some("dry run")),
    content="Skipped(Some(\"dry run\"))",
  )
}

///|
test "StepStatus::Undefined shows correctly" {
  inspect(StepStatus::Undefined, content="Undefined")
}

///|
test "StepStatus::Pending shows correctly" {
  inspect(StepStatus::Pending, content="Pending")
}

///|
test "StepStatus is_passed returns true for Passed" {
  assert_true(StepStatus::Passed.is_passed())
}

///|
test "StepStatus is_passed returns false for Failed" {
  assert_false(StepStatus::Failed("err").is_passed())
}

///|
test "ScenarioStatus from empty steps is Passed" {
  let result = ScenarioStatus::from_steps([])
  assert_eq(result, ScenarioStatus::Passed)
}

///|
test "ScenarioStatus from all passed steps is Passed" {
  let result = ScenarioStatus::from_steps([
    StepStatus::Passed,
    StepStatus::Passed,
  ])
  assert_eq(result, ScenarioStatus::Passed)
}

///|
test "ScenarioStatus with one Failed is Failed" {
  let result = ScenarioStatus::from_steps([
    StepStatus::Passed,
    StepStatus::Failed("err"),
  ])
  assert_eq(result, ScenarioStatus::Failed)
}

///|
test "ScenarioStatus with Undefined is Undefined" {
  let result = ScenarioStatus::from_steps([StepStatus::Undefined])
  assert_eq(result, ScenarioStatus::Undefined)
}

///|
test "RunSummary includes retried field" {
  let summary : RunSummary = {
    total_scenarios: 5,
    passed: 4,
    failed: 1,
    undefined: 0,
    pending: 0,
    skipped: 0,
    retried: 2,
    duration_ms: 0L,
  }
  assert_eq(summary.retried, 2)
}

///|
test "ScenarioStatus from all skipped propagates reason" {
  let result = ScenarioStatus::from_steps([
    StepStatus::Skipped(Some("dry run")),
    StepStatus::Skipped(Some("dry run")),
  ])
  assert_eq(result, ScenarioStatus::Skipped(Some("dry run")))
}

///|
test "ScenarioStatus from skipped without reason" {
  let result = ScenarioStatus::from_steps([StepStatus::Skipped(None)])
  assert_eq(result, ScenarioStatus::Skipped(None))
}
