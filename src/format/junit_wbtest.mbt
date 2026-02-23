// ---------------------------------------------------------------------------
// Test helper: TestStepFinished envelope with a failure message
// ---------------------------------------------------------------------------

///|
fn make_test_step_finished_with_message_envelope(
  tcs_id : String,
  test_step_id : String,
  status : String,
  message : String,
) -> @cucumber_messages.Envelope {
  let json : Json = {
    "testStepFinished": {
      "testCaseStartedId": tcs_id,
      "testStepId": test_step_id,
      "testStepResult": {
        "duration": { "seconds": 0, "nanos": 1000000 },
        "status": status,
        "message": message,
      },
      "timestamp": { "seconds": 0, "nanos": 1000000 },
    },
  }
  @json.from_json(json) catch { _ => panic() }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

///|
test "JUnitFormatter produces valid XML structure for passed scenario" {
  let fmt = JUnitFormatter::new()
  let sink : &@core.MessageSink = fmt
  sink.on_message(make_gherkin_doc_envelope("math.feature", "Math"))
  sink.on_message(
    make_pickle_envelope(
      "p1",
      "math.feature",
      "Addition",
      [("ps1", "I have 5 cucumbers", "Context")],
    ),
  )
  sink.on_message(make_test_case_envelope("tc1", "p1", [("ts1", Some("ps1"))]))
  sink.on_message(make_test_case_started_envelope("tcs1", "tc1"))
  sink.on_message(make_test_step_finished_envelope("tcs1", "ts1", "PASSED"))
  sink.on_message(make_test_case_finished_envelope("tcs1"))
  sink.on_message(make_test_run_finished_envelope())
  let output = fmt.output()
  assert_true(string_contains(output, "<?xml"))
  assert_true(string_contains(output, "<testsuites"))
  assert_true(string_contains(output, "tests=\"1\""))
  assert_true(string_contains(output, "failures=\"0\""))
  assert_true(string_contains(output, "<testsuite"))
  assert_true(string_contains(output, "name=\"Math\""))
  assert_true(string_contains(output, "<testcase"))
  assert_true(string_contains(output, "name=\"Addition\""))
  assert_true(string_contains(output, "classname=\"Math\""))
  assert_true(string_contains(output, "</testcase>"))
  assert_true(string_contains(output, "</testsuite>"))
  assert_true(string_contains(output, "</testsuites>"))
}

///|
test "JUnitFormatter formats failed scenario with failure element" {
  let fmt = JUnitFormatter::new()
  let sink : &@core.MessageSink = fmt
  sink.on_message(make_gherkin_doc_envelope("math.feature", "Math"))
  sink.on_message(
    make_pickle_envelope(
      "p2",
      "math.feature",
      "Division",
      [("ps2", "I divide by zero", "Action")],
    ),
  )
  sink.on_message(make_test_case_envelope("tc2", "p2", [("ts2", Some("ps2"))]))
  sink.on_message(make_test_case_started_envelope("tcs2", "tc2"))
  sink.on_message(
    make_test_step_finished_with_message_envelope(
      "tcs2",
      "ts2",
      "FAILED",
      "division by zero",
    ),
  )
  sink.on_message(make_test_case_finished_envelope("tcs2"))
  sink.on_message(make_test_run_finished_envelope())
  let output = fmt.output()
  assert_true(string_contains(output, "<failure"))
  assert_true(string_contains(output, "division by zero"))
  assert_true(string_contains(output, "failures=\"1\""))
}

///|
test "JUnitFormatter formats skipped scenario" {
  let fmt = JUnitFormatter::new()
  let sink : &@core.MessageSink = fmt
  sink.on_message(make_gherkin_doc_envelope("skip.feature", "Skipped Feature"))
  sink.on_message(
    make_pickle_envelope(
      "p3",
      "skip.feature",
      "Skipped Scenario",
      [("ps3", "a pending step", "Context")],
    ),
  )
  sink.on_message(make_test_case_envelope("tc3", "p3", [("ts3", Some("ps3"))]))
  sink.on_message(make_test_case_started_envelope("tcs3", "tc3"))
  sink.on_message(make_test_step_finished_envelope("tcs3", "ts3", "UNDEFINED"))
  sink.on_message(make_test_case_finished_envelope("tcs3"))
  sink.on_message(make_test_run_finished_envelope())
  let output = fmt.output()
  assert_true(string_contains(output, "<skipped/>"))
}

///|
test "JUnitFormatter escapes XML special characters" {
  let fmt = JUnitFormatter::new()
  let sink : &@core.MessageSink = fmt
  sink.on_message(
    make_gherkin_doc_envelope("special.feature", "Math <&> \"ops\""),
  )
  sink.on_message(
    make_pickle_envelope(
      "p4",
      "special.feature",
      "A & B",
      [("ps4", "some step", "Context")],
    ),
  )
  sink.on_message(make_test_case_envelope("tc4", "p4", [("ts4", Some("ps4"))]))
  sink.on_message(make_test_case_started_envelope("tcs4", "tc4"))
  sink.on_message(make_test_step_finished_envelope("tcs4", "ts4", "PASSED"))
  sink.on_message(make_test_case_finished_envelope("tcs4"))
  sink.on_message(make_test_run_finished_envelope())
  let output = fmt.output()
  // The xml Writer auto-escapes attribute values
  assert_true(string_contains(output, "&amp;"))
  assert_true(string_contains(output, "&lt;"))
  assert_true(string_contains(output, "&gt;"))
  assert_true(string_contains(output, "&quot;"))
}

///|
test "JUnitFormatter handles multiple features" {
  let fmt = JUnitFormatter::new()
  let sink : &@core.MessageSink = fmt
  // Two features
  sink.on_message(make_gherkin_doc_envelope("a.feature", "Feature A"))
  sink.on_message(make_gherkin_doc_envelope("b.feature", "Feature B"))
  // Pickles
  sink.on_message(
    make_pickle_envelope(
      "p1",
      "a.feature",
      "Scenario A",
      [("ps1", "step a", "Context")],
    ),
  )
  sink.on_message(
    make_pickle_envelope(
      "p2",
      "b.feature",
      "Scenario B",
      [("ps2", "step b", "Action")],
    ),
  )
  // Test cases
  sink.on_message(make_test_case_envelope("tc1", "p1", [("ts1", Some("ps1"))]))
  sink.on_message(make_test_case_envelope("tc2", "p2", [("ts2", Some("ps2"))]))
  // Run scenario from feature A
  sink.on_message(make_test_case_started_envelope("tcs1", "tc1"))
  sink.on_message(make_test_step_finished_envelope("tcs1", "ts1", "PASSED"))
  sink.on_message(make_test_case_finished_envelope("tcs1"))
  // Run scenario from feature B
  sink.on_message(make_test_case_started_envelope("tcs2", "tc2"))
  sink.on_message(make_test_step_finished_envelope("tcs2", "ts2", "PASSED"))
  sink.on_message(make_test_case_finished_envelope("tcs2"))
  sink.on_message(make_test_run_finished_envelope())
  let output = fmt.output()
  assert_true(string_contains(output, "name=\"Feature A\""))
  assert_true(string_contains(output, "name=\"Feature B\""))
  assert_true(string_contains(output, "tests=\"2\""))
  // Each testsuite should have tests="1"
  assert_true(string_contains(output, "name=\"Scenario A\""))
  assert_true(string_contains(output, "name=\"Scenario B\""))
}
