///|
test "PrettyFormatter formats passed scenario" {
  let fmt = PrettyFormatter::new(no_color=true)
  let result : @runner.ScenarioResult = {
    feature_name: "Math",
    scenario_name: "Addition",
    pickle_id: "p1",
    tags: [],
    steps: [
      {
        text: "I have 5 cucumbers",
        keyword: "Given ",
        status: @runner.StepStatus::Passed,
        duration_ms: 1L,
        diagnostic: None,
      },
    ],
    status: @runner.ScenarioStatus::Passed,
    duration_ms: 1L,
  }
  fmt.format_scenario(result)
  let output = fmt.output()
  assert_true(string_contains(output, "Addition"))
  assert_true(
    string_contains(output, "PASS") || string_contains(output, "\u{2713}"),
  )
}

///|
test "PrettyFormatter formats failed scenario" {
  let fmt = PrettyFormatter::new(no_color=true)
  let result : @runner.ScenarioResult = {
    feature_name: "Math",
    scenario_name: "Division by zero",
    pickle_id: "p2",
    tags: [],
    steps: [
      {
        text: "I divide by zero",
        keyword: "When ",
        status: @runner.StepStatus::Failed("boom"),
        duration_ms: 2L,
        diagnostic: None,
      },
    ],
    status: @runner.ScenarioStatus::Failed,
    duration_ms: 2L,
  }
  fmt.format_scenario(result)
  let output = fmt.output()
  assert_true(string_contains(output, "Division by zero"))
  assert_true(
    string_contains(output, "FAIL") || string_contains(output, "\u{2717}"),
  )
}

///|
test "PrettyFormatter formats summary" {
  let fmt = PrettyFormatter::new(no_color=true)
  let run_result : @runner.RunResult = {
    features: [],
    summary: {
      total_scenarios: 3,
      passed: 2,
      failed: 1,
      undefined: 0,
      pending: 0,
      skipped: 0,
      duration_ms: 100L,
    },
  }
  fmt.format_summary(run_result)
  let output = fmt.output()
  assert_true(string_contains(output, "3 scenario"))
  assert_true(string_contains(output, "2 passed"))
  assert_true(string_contains(output, "1 failed"))
}

///|
test "PrettyFormatter on_feature_start writes feature header" {
  let fmt = PrettyFormatter::new(no_color=true)
  fmt.format_feature_start("Calculator")
  let output = fmt.output()
  assert_true(string_contains(output, "Feature: Calculator"))
}

///|
test "PrettyFormatter step markers in no_color mode" {
  let fmt = PrettyFormatter::new(no_color=true)
  let result : @runner.ScenarioResult = {
    feature_name: "Test",
    scenario_name: "Steps",
    pickle_id: "p3",
    tags: [],
    steps: [
      {
        text: "step one",
        keyword: "Given ",
        status: @runner.StepStatus::Passed,
        duration_ms: 1L,
        diagnostic: None,
      },
      {
        text: "step two",
        keyword: "When ",
        status: @runner.StepStatus::Undefined,
        duration_ms: 0L,
        diagnostic: None,
      },
      {
        text: "step three",
        keyword: "Then ",
        status: @runner.StepStatus::Skipped,
        duration_ms: 0L,
        diagnostic: None,
      },
    ],
    status: @runner.ScenarioStatus::Undefined,
    duration_ms: 1L,
  }
  fmt.format_scenario(result)
  let output = fmt.output()
  assert_true(string_contains(output, "Given step one"))
  assert_true(string_contains(output, "When step two"))
  assert_true(string_contains(output, "Then step three"))
}

///|
test "PrettyFormatter implements MessageSink" {
  let fmt = PrettyFormatter::new(no_color=true)
  let json : Json = {
    "testRunStarted": {
      "timestamp": {
        "seconds": (0 : Int).to_json(),
        "nanos": (0 : Int).to_json(),
      },
    },
  }
  let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch {
    _ => panic()
  }
  @core.MessageSink::on_message(fmt, envelope)
  // Currently a no-op, so no output expected
  assert_eq(fmt.output(), "")
}

///|
test "string_contains basic cases" {
  assert_true(string_contains("hello world", "world"))
  assert_true(string_contains("hello world", "hello"))
  assert_true(string_contains("hello world", ""))
  assert_true(not(string_contains("hello", "xyz")))
  assert_true(not(string_contains("hi", "longer string")))
}
