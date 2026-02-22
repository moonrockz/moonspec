test "MessagesFormatter emits TestRunStarted envelope" {
  let fmt = MessagesFormatter::new()
  fmt.on_run_start({ feature_count: 1, scenario_count: 2 })
  let output = fmt.output()
  assert_true(string_contains(output, "testRunStarted"))
}

test "MessagesFormatter emits TestRunFinished envelope" {
  let fmt = MessagesFormatter::new()
  let run_result : @runner.RunResult = {
    features: [],
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
  assert_true(string_contains(output, "testRunFinished"))
}

test "MessagesFormatter TestRunFinished success is true when no failures" {
  let fmt = MessagesFormatter::new()
  let run_result : @runner.RunResult = {
    features: [],
    summary: {
      total_scenarios: 3,
      passed: 3,
      failed: 0,
      undefined: 0,
      pending: 0,
      skipped: 0,
      duration_ms: 100L,
    },
  }
  fmt.on_run_finish(run_result)
  let output = fmt.output()
  assert_true(string_contains(output, "\"success\":true"))
}

test "MessagesFormatter TestRunFinished success is false when failures exist" {
  let fmt = MessagesFormatter::new()
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
  fmt.on_run_finish(run_result)
  let output = fmt.output()
  assert_true(string_contains(output, "\"success\":false"))
}

test "MessagesFormatter emits NDJSON with both start and finish" {
  let fmt = MessagesFormatter::new()
  fmt.on_run_start({ feature_count: 1, scenario_count: 1 })
  let run_result : @runner.RunResult = {
    features: [],
    summary: {
      total_scenarios: 1,
      passed: 1,
      failed: 0,
      undefined: 0,
      pending: 0,
      skipped: 0,
      duration_ms: 10L,
    },
  }
  fmt.on_run_finish(run_result)
  let output = fmt.output()
  assert_true(string_contains(output, "testRunStarted"))
  assert_true(string_contains(output, "testRunFinished"))
}
