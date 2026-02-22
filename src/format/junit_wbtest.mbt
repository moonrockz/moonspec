///|
test "JUnitFormatter produces valid XML structure" {
  let fmt = JUnitFormatter::new()
  let run_result : @runner.RunResult = {
    features: [
      {
        name: "Math",
        scenarios: [
          {
            feature_name: "Math",
            scenario_name: "Addition",
            tags: [],
            steps: [],
            status: @runner.ScenarioStatus::Passed,
            duration_ms: 50L,
          },
        ],
        duration_ms: 50L,
      },
    ],
    summary: {
      total_scenarios: 1,
      passed: 1,
      failed: 0,
      undefined: 0,
      pending: 0,
      skipped: 0,
      duration_ms: 50L,
    },
  }
  fmt.on_run_finish(run_result)
  let output = fmt.output()
  assert_true(string_contains(output, "<?xml"))
  assert_true(string_contains(output, "<testsuites"))
  assert_true(string_contains(output, "<testsuite"))
  assert_true(string_contains(output, "name=\"Math\""))
  assert_true(string_contains(output, "<testcase"))
  assert_true(string_contains(output, "name=\"Addition\""))
}

///|
test "JUnitFormatter formats failed scenario with failure element" {
  let fmt = JUnitFormatter::new()
  let run_result : @runner.RunResult = {
    features: [
      {
        name: "Math",
        scenarios: [
          {
            feature_name: "Math",
            scenario_name: "Division",
            tags: [],
            steps: [
              {
                text: "I divide by zero",
                keyword: "When ",
                status: @runner.StepStatus::Failed("division by zero"),
                duration_ms: 10L,
              },
            ],
            status: @runner.ScenarioStatus::Failed,
            duration_ms: 10L,
          },
        ],
        duration_ms: 10L,
      },
    ],
    summary: {
      total_scenarios: 1,
      passed: 0,
      failed: 1,
      undefined: 0,
      pending: 0,
      skipped: 0,
      duration_ms: 10L,
    },
  }
  fmt.on_run_finish(run_result)
  let output = fmt.output()
  assert_true(string_contains(output, "<failure"))
  assert_true(string_contains(output, "division by zero"))
  assert_true(string_contains(output, "failures=\"1\""))
}

///|
test "JUnitFormatter formats skipped scenario" {
  let fmt = JUnitFormatter::new()
  let run_result : @runner.RunResult = {
    features: [
      {
        name: "Skipped Feature",
        scenarios: [
          {
            feature_name: "Skipped Feature",
            scenario_name: "Skipped Scenario",
            tags: [],
            steps: [],
            status: @runner.ScenarioStatus::Skipped,
            duration_ms: 0L,
          },
        ],
        duration_ms: 0L,
      },
    ],
    summary: {
      total_scenarios: 1,
      passed: 0,
      failed: 0,
      undefined: 0,
      pending: 0,
      skipped: 1,
      duration_ms: 0L,
    },
  }
  fmt.on_run_finish(run_result)
  let output = fmt.output()
  assert_true(string_contains(output, "<skipped/>"))
}

///|
test "JUnitFormatter escapes XML special characters" {
  let fmt = JUnitFormatter::new()
  let run_result : @runner.RunResult = {
    features: [
      {
        name: "Math <&> \"ops\"",
        scenarios: [
          {
            feature_name: "Math <&> \"ops\"",
            scenario_name: "A & B",
            tags: [],
            steps: [],
            status: @runner.ScenarioStatus::Passed,
            duration_ms: 5L,
          },
        ],
        duration_ms: 5L,
      },
    ],
    summary: {
      total_scenarios: 1,
      passed: 1,
      failed: 0,
      undefined: 0,
      pending: 0,
      skipped: 0,
      duration_ms: 5L,
    },
  }
  fmt.on_run_finish(run_result)
  let output = fmt.output()
  assert_true(string_contains(output, "&amp;"))
  assert_true(string_contains(output, "&lt;"))
  assert_true(string_contains(output, "&gt;"))
  assert_true(string_contains(output, "&quot;"))
}
