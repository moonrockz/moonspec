///|
fn make_summary(
  total_scenarios~ : Int = 0,
  passed~ : Int = 0,
  failed~ : Int = 0,
  undefined~ : Int = 0,
  pending~ : Int = 0,
  skipped~ : Int = 0,
  retried~ : Int = 0,
  duration_ms~ : Int64 = 0L,
) -> @runner.RunSummary {
  { total_scenarios, passed, failed, undefined, pending, skipped, retried, duration_ms }
}

///|
fn make_result(
  summary~ : @runner.RunSummary = make_summary(),
  parse_errors~ : Array[@runner.ParseErrorInfo] = [],
) -> @runner.RunResult {
  { features: [], summary, parse_errors }
}

///|
test "assert_passed succeeds on all-passing result" {
  let result = make_result(summary=make_summary(total_scenarios=3, passed=3))
  assert_passed(result)
}

///|
test "assert_passed fails when there are failures" {
  let result = make_result(summary=make_summary(total_scenarios=3, passed=2, failed=1))
  let mut caught = false
  try {
    assert_passed(result)
  } catch {
    Failure::Failure(msg) => {
      assert_true(msg.contains("1 failed"))
      caught = true
    }
    _ => ()
  }
  assert_true(caught)
}

///|
test "assert_passed fails when there are undefined steps" {
  let result = make_result(summary=make_summary(total_scenarios=2, passed=1, undefined=1))
  let mut caught = false
  try {
    assert_passed(result)
  } catch {
    Failure::Failure(msg) => {
      assert_true(msg.contains("1 undefined"))
      caught = true
    }
    _ => ()
  }
  assert_true(caught)
}

///|
test "assert_failed succeeds when there are failures" {
  let result = make_result(summary=make_summary(total_scenarios=3, passed=2, failed=1))
  assert_failed(result)
}

///|
test "assert_failed fails when all pass" {
  let result = make_result(summary=make_summary(total_scenarios=3, passed=3))
  let mut caught = false
  try {
    assert_failed(result)
  } catch {
    Failure::Failure(msg) => {
      assert_true(msg.contains("all 3 scenarios passed"))
      caught = true
    }
    _ => ()
  }
  assert_true(caught)
}

///|
test "assert_summary passes when counts match" {
  let summary = make_summary(total_scenarios=5, passed=3, failed=1, skipped=1)
  assert_summary(summary, passed=3, failed=1, skipped=1)
}

///|
test "assert_summary fails with mismatch details" {
  let summary = make_summary(total_scenarios=5, passed=3, failed=2)
  let mut caught = false
  try {
    assert_summary(summary, passed=4, failed=1)
  } catch {
    Failure::Failure(msg) => {
      assert_true(msg.contains("passed: expected 4, got 3"))
      assert_true(msg.contains("failed: expected 1, got 2"))
      caught = true
    }
    _ => ()
  }
  assert_true(caught)
}

///|
test "assert_no_parse_errors passes on empty parse_errors" {
  let result = make_result()
  assert_no_parse_errors(result)
}

///|
test "assert_no_parse_errors fails when parse errors exist" {
  let result = make_result(
    parse_errors=[
      { uri: "test.feature", message: "syntax error", line: Some(1) },
    ],
  )
  let mut caught = false
  try {
    assert_no_parse_errors(result)
  } catch {
    Failure::Failure(msg) => {
      assert_true(msg.contains("found 1"))
      caught = true
    }
    _ => ()
  }
  assert_true(caught)
}
