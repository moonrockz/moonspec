///|
/// Assert the run passed (no failures, undefined, or pending steps).
pub fn assert_passed(result : @runner.RunResult) -> Unit raise Error {
  let s = result.summary
  if s.failed > 0 || s.undefined > 0 || s.pending > 0 {
    let parts : Array[String] = []
    if s.failed > 0 {
      parts.push(s.failed.to_string() + " failed")
    }
    if s.undefined > 0 {
      parts.push(s.undefined.to_string() + " undefined")
    }
    if s.pending > 0 {
      parts.push(s.pending.to_string() + " pending")
    }
    raise Failure::Failure("Expected run to have passed, but: " + parts.join(", "))
  }
}

///|
/// Assert the run had failures.
pub fn assert_failed(result : @runner.RunResult) -> Unit raise Error {
  if result.summary.failed == 0 {
    raise Failure::Failure(
      "Expected run to have failed, but all \{result.summary.passed} scenarios passed",
    )
  }
}

///|
/// Assert the run had no parse errors.
pub fn assert_no_parse_errors(result : @runner.RunResult) -> Unit raise Error {
  let count = result.parse_errors.length()
  if count > 0 {
    raise Failure::Failure("Expected no parse errors, but found \{count}")
  }
}

///|
/// Assert the run summary has specific counts. Only provided fields are checked.
pub fn assert_summary(
  summary : @runner.RunSummary,
  passed? : Int,
  failed? : Int,
  undefined? : Int,
  pending? : Int,
  skipped? : Int,
) -> Unit raise Error {
  let mismatches : Array[String] = []
  match passed {
    Some(expected) =>
      if summary.passed != expected {
        mismatches.push("passed: expected \{expected}, got \{summary.passed}")
      }
    None => ()
  }
  match failed {
    Some(expected) =>
      if summary.failed != expected {
        mismatches.push("failed: expected \{expected}, got \{summary.failed}")
      }
    None => ()
  }
  match undefined {
    Some(expected) =>
      if summary.undefined != expected {
        mismatches.push("undefined: expected \{expected}, got \{summary.undefined}")
      }
    None => ()
  }
  match pending {
    Some(expected) =>
      if summary.pending != expected {
        mismatches.push("pending: expected \{expected}, got \{summary.pending}")
      }
    None => ()
  }
  match skipped {
    Some(expected) =>
      if summary.skipped != expected {
        mismatches.push("skipped: expected \{expected}, got \{summary.skipped}")
      }
    None => ()
  }
  if mismatches.length() > 0 {
    raise Failure::Failure("Run summary mismatch: " + mismatches.join(", "))
  }
}
