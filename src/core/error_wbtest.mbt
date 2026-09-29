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
    MoonspecError::StepFailed(
      step="failed one",
      keyword="Then",
      message="assertion failed",
    ),
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

///|
test "StepFailed shows keyword, step and message" {
  let err = MoonspecError::StepFailed(
    step="the result is 4",
    keyword="Then ",
    message="Expected 3 to equal 4",
  )
  inspect(
    err,
    content=(
      #|Then the result is 4
      #|  Expected 3 to equal 4
    ),
  )
}

///|
test "UndefinedStep shows snippet and suggestions" {
  let err = MoonspecError::UndefinedStep(
    step="I have 5 bananas",
    keyword="Given ",
    snippet="s.given(\"I have {int} bananas\", fn(ctx) {\n  ...\n})",
    suggestions=["I have {int} cucumbers"],
  )
  inspect(
    err,
    content=(
      #|Given I have 5 bananas
      #|  Undefined step. Implement it with:
      #|    s.given("I have {int} bananas", fn(ctx) {
      #|      ...
      #|    })
      #|  Did you mean:
      #|    I have {int} cucumbers
    ),
  )
}

///|
test "PendingStep shows message" {
  let err = MoonspecError::PendingStep(
    step="a pending step",
    keyword="Given",
    message="TODO: implement",
  )
  inspect(
    err,
    content=(
      #|Given a pending step
      #|  Pending: TODO: implement
    ),
  )
}

///|
test "RunFailed shows summary and each failed scenario" {
  let err : Error = RunFailed(summary="2 failed, 3 total", errors=[
    ScenarioFailed(scenario="wrong sum", feature="Add", errors=[
      StepFailed(
        step="the result is 4",
        keyword="Then ",
        message="Expected 3 to equal 4",
      ),
    ]),
    ScenarioFailed(scenario="later", feature="Add", errors=[
      PendingStep(step="a later step", keyword="When ", message="TODO"),
    ]),
  ])
  inspect(
    err,
    content=(
      #|2 failed, 3 total
      #|Feature: Add / Scenario: wrong sum
      #|  Then the result is 4
      #|    Expected 3 to equal 4
      #|Feature: Add / Scenario: later
      #|  When a later step
      #|    Pending: TODO
    ),
  )
}
