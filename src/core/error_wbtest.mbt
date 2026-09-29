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
    location=None,
    steps=[],
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
    scenario_failed_error(scenario="S1", feature="F1", errors=[]),
  ]
  let err : Error = RunFailed(
    summary="1 scenario failed",
    errors=scenario_errors,
    color=false,
  )
  match err {
    RunFailed(summary~, errors~, ..) => {
      assert_eq(summary, "1 scenario failed")
      assert_eq(errors.length(), 1)
    }
    _ => fail("expected RunFailed")
  }
}

///|
test "StepFailed shows a failure marker and the message" {
  let err = MoonspecError::StepFailed(
    step="the result is 4",
    keyword="Then ",
    message="Expected 3 to equal 4",
  )
  inspect(
    err,
    content=(
      #|✖ Then the result is 4
      #|    Expected 3 to equal 4
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
      #|? Given I have 5 bananas
      #|    Undefined step. Implement it with:
      #|      s.given("I have {int} bananas", fn(ctx) {
      #|        ...
      #|      })
      #|    Did you mean:
      #|      I have {int} cucumbers
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
      #|? Given a pending step
      #|    Pending: TODO: implement
    ),
  )
}

///|
test "ParseFailed shows location and message" {
  let err = MoonspecError::ParseFailed(
    uri="features/bad.feature",
    line=Some(3),
    message="unexpected token",
  )
  inspect(
    err,
    content=(
      #|Parse error: features/bad.feature:3
      #|    unexpected token
    ),
  )
}

///|
fn wrong_sum_scenario() -> MoonspecError {
  scenario_failed_error(
    scenario="wrong sum",
    feature="Add",
    location=Some("features/add.feature:3"),
    steps=[
      Passed(keyword="Given ", step="the numbers 1 and 2"),
      Problem(
        StepFailed(
          step="the result is 4",
          keyword="Then ",
          message="Expected 3 to equal 4",
        ),
      ),
      Skipped(keyword="And ", step="it is logged"),
    ],
    errors=[],
  )
}

///|
test "ScenarioFailed shows every step with a marker in front" {
  inspect(
    wrong_sum_scenario(),
    content=(
      #|Feature: Add / Scenario: wrong sum # features/add.feature:3
      #|   ✔ Given the numbers 1 and 2
      #|   ✖ Then the result is 4
      #|       Expected 3 to equal 4
      #|   - And it is logged
    ),
  )
}

///|
test "ScenarioFailed without steps shows its errors" {
  let err = scenario_failed_error(scenario="later", feature="Add", errors=[
    PendingStep(step="a later step", keyword="When ", message="TODO"),
  ])
  inspect(
    err,
    content=(
      #|Feature: Add / Scenario: later
      #|   ? When a later step
      #|       Pending: TODO
    ),
  )
}

///|
test "RunFailed numbers parse errors and failed scenarios" {
  let err : Error = RunFailed(
    summary="1 failed, 1 parse error, 1 total",
    errors=[
      ParseFailed(uri="test://bad", line=None, message="bad input"),
      wrong_sum_scenario(),
    ],
    color=false,
  )
  inspect(
    err,
    content=(
      #|1 failed, 1 parse error, 1 total
      #|
      #|1) Parse error: test://bad
      #|       bad input
      #|
      #|2) Feature: Add / Scenario: wrong sum # features/add.feature:3
      #|   ✔ Given the numbers 1 and 2
      #|   ✖ Then the result is 4
      #|       Expected 3 to equal 4
      #|   - And it is logged
    ),
  )
}

///|
test "RunFailed with color paints each step line by status" {
  let err = run_failed_error(
    summary="1 failed, 1 total",
    errors=[wrong_sum_scenario()],
    color=true,
  )
  let lines = err.to_string().split("\n").map(fn(l) { l.to_owned() }).collect()
  assert_eq(
    lines[2],
    "1) Feature: Add / Scenario: wrong sum # features/add.feature:3",
  )
  assert_eq(lines[3], "   \u001b[32m✔ Given the numbers 1 and 2\u001b[0m")
  assert_eq(lines[4], "   \u001b[31m✖ Then the result is 4\u001b[0m")
  assert_eq(lines[5], "       \u001b[31mExpected 3 to equal 4\u001b[0m")
  assert_eq(lines[6], "   \u001b[36m- And it is logged\u001b[0m")
}

///|
test "color_enabled follows no_color when no environment override is set" {
  with_color_env(moonspec_color=None, no_color=None, fn() raise {
    assert_true(color_enabled())
    assert_false(color_enabled(no_color=true))
  })
}

///|
test "NO_COLOR turns color off" {
  with_color_env(moonspec_color=None, no_color=Some("1"), fn() raise {
    assert_false(color_enabled())
  })
  with_color_env(moonspec_color=None, no_color=Some(""), fn() raise {
    assert_true(color_enabled())
  })
}

///|
test "MOONSPEC_COLOR overrides the compiled value and NO_COLOR" {
  with_color_env(moonspec_color=Some("always"), no_color=Some("1"), fn() raise {
    assert_true(color_enabled(no_color=true))
  })
  with_color_env(moonspec_color=Some("never"), no_color=None, fn() raise {
    assert_false(color_enabled())
  })
}

///|
fn with_color_env(
  moonspec_color~ : String?,
  no_color~ : String?,
  body : () -> Unit raise Error,
) -> Unit raise Error {
  let saved = (@env.get_env_var("MOONSPEC_COLOR"), @env.get_env_var("NO_COLOR"))
  fn set(key : String, value : String?) {
    match value {
      Some(v) => @env.set_env_var(key, v)
      None => @env.unset_env_var(key)
    }
  }
  set("MOONSPEC_COLOR", moonspec_color)
  set("NO_COLOR", no_color)
  defer {
    set("MOONSPEC_COLOR", saved.0)
    set("NO_COLOR", saved.1)
  }
  body()
}
