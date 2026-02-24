///|
test "UndefinedStep carries step text and snippet" {
  let err : Error = UndefinedStep(
    step="I have 5 bananas",
    keyword="Given",
    snippet="s.given(\"I have {int} bananas\", fn(ctx) { ... })",
    suggestions=["I have {int} cucumbers"],
  )
  match err {
    UndefinedStep(step~, keyword~, snippet~, suggestions~) => {
      assert_eq(step, "I have 5 bananas")
      assert_eq(keyword, "Given")
      assert_true(snippet.length() > 0)
      assert_eq(suggestions.length(), 1)
    }
    _ => fail("expected UndefinedStep")
  }
}

///|
test "PendingStep carries message" {
  let err : Error = PendingStep(
    step="a pending step",
    keyword="Given",
    message="TODO: implement",
  )
  match err {
    PendingStep(step~, ..) => assert_eq(step, "a pending step")
    _ => fail("expected PendingStep")
  }
}

///|
test "ScenarioFailed aggregates step errors" {
  let step_errors : Array[MoonspecError] = [
    UndefinedStep(step="undefined one", keyword="Given", snippet="", suggestions=[]),
    MoonspecError::StepFailed(step="failed one", keyword="Then", message="assertion failed"),
  ]
  let err : Error = MoonspecError::ScenarioFailed(
    scenario="My Scenario",
    feature="My Feature",
    errors=step_errors,
  )
  match err {
    MoonspecError::ScenarioFailed(errors~, ..) => assert_eq(errors.length(), 2)
    _ => fail("expected ScenarioFailed")
  }
}

///|
test "RunFailed aggregates scenario errors" {
  let scenario_errors : Array[MoonspecError] = [
    MoonspecError::ScenarioFailed(scenario="S1", feature="F1", errors=[]),
  ]
  let err : Error = RunFailed(
    summary="1 scenario failed",
    errors=scenario_errors,
  )
  match err {
    RunFailed(summary~, errors~) => {
      assert_eq(summary, "1 scenario failed")
      assert_eq(errors.length(), 1)
    }
    _ => fail("expected RunFailed")
  }
}
