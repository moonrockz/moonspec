// ---------------------------------------------------------------------------
// Test helpers: build minimal envelope sequences
// ---------------------------------------------------------------------------

///|
/// Build a GherkinDocument envelope with a feature.
fn make_gherkin_doc_envelope(
  uri : String,
  feature_name : String,
) -> @cucumber_messages.Envelope {
  let json : Json = {
    "gherkinDocument": {
      "uri": uri,
      "comments": [],
      "feature": {
        "location": { "line": 1 },
        "tags": [],
        "language": "en",
        "keyword": "Feature",
        "name": feature_name,
        "description": "",
        "children": [],
      },
    },
  }
  @json.from_json(json) catch {
    _ => panic()
  }
}

///|
/// Build a Pickle envelope.
fn make_pickle_envelope(
  id : String,
  uri : String,
  name : String,
  steps : Array[(String, String, String)],
) -> @cucumber_messages.Envelope {
  let step_arr : Array[Json] = []
  for step in steps {
    let (step_id, text, step_type) = step
    let step_json : Json = {
      "id": step_id,
      "text": text,
      "astNodeIds": ["ast1"],
      "type": step_type,
    }
    step_arr.push(step_json)
  }
  let json : Json = {
    "pickle": {
      "id": id,
      "uri": uri,
      "name": name,
      "language": "en",
      "steps": step_arr.to_json(),
      "tags": [],
      "astNodeIds": ["sc1"],
    },
  }
  @json.from_json(json) catch {
    _ => panic()
  }
}

///|
/// Build a TestCase envelope.
fn make_test_case_envelope(
  id : String,
  pickle_id : String,
  test_steps : Array[(String, String?)],
) -> @cucumber_messages.Envelope {
  let steps_arr : Array[Json] = []
  for step in test_steps {
    let (step_id, pickle_step_id) = step
    let step_json : Map[String, Json] = { "id": step_id.to_json() }
    match pickle_step_id {
      Some(psid) => step_json["pickleStepId"] = psid.to_json()
      None => ()
    }
    steps_arr.push(step_json.to_json())
  }
  let json : Json = {
    "testCase": {
      "id": id,
      "pickleId": pickle_id,
      "testSteps": steps_arr.to_json(),
    },
  }
  @json.from_json(json) catch {
    _ => panic()
  }
}

///|
/// Build a TestCaseStarted envelope.
fn make_test_case_started_envelope(
  id : String,
  test_case_id : String,
) -> @cucumber_messages.Envelope {
  let json : Json = {
    "testCaseStarted": {
      "id": id,
      "testCaseId": test_case_id,
      "attempt": 0,
      "timestamp": { "seconds": 0, "nanos": 0 },
    },
  }
  @json.from_json(json) catch {
    _ => panic()
  }
}

///|
/// Build a TestStepFinished envelope.
fn make_test_step_finished_envelope(
  tcs_id : String,
  test_step_id : String,
  status : String,
) -> @cucumber_messages.Envelope {
  let json : Json = {
    "testStepFinished": {
      "testCaseStartedId": tcs_id,
      "testStepId": test_step_id,
      "testStepResult": {
        "duration": { "seconds": 0, "nanos": 1000000 },
        "status": status,
      },
      "timestamp": { "seconds": 0, "nanos": 1000000 },
    },
  }
  @json.from_json(json) catch {
    _ => panic()
  }
}

///|
/// Build a TestCaseFinished envelope.
fn make_test_case_finished_envelope(
  tcs_id : String,
) -> @cucumber_messages.Envelope {
  let json : Json = {
    "testCaseFinished": {
      "testCaseStartedId": tcs_id,
      "timestamp": { "seconds": 0, "nanos": 2000000 },
      "willBeRetried": false,
    },
  }
  @json.from_json(json) catch {
    _ => panic()
  }
}

///|
/// Build a TestRunFinished envelope.
fn make_test_run_finished_envelope() -> @cucumber_messages.Envelope {
  let json : Json = {
    "testRunFinished": {
      "success": true,
      "timestamp": { "seconds": 1, "nanos": 0 },
    },
  }
  @json.from_json(json) catch {
    _ => panic()
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

///|
test "PrettyFormatter formats passed scenario via envelopes" {
  let fmt = PrettyFormatter::new(no_color=true)
  let sink : &@core.MessageSink = fmt
  sink.on_message(make_gherkin_doc_envelope("math.feature", "Math"))
  sink.on_message(
    make_pickle_envelope("p1", "math.feature", "Addition", [
      ("ps1", "I have 5 cucumbers", "Context"),
    ]),
  )
  sink.on_message(make_test_case_envelope("tc1", "p1", [("ts1", Some("ps1"))]))
  sink.on_message(make_test_case_started_envelope("tcs1", "tc1"))
  sink.on_message(make_test_step_finished_envelope("tcs1", "ts1", "PASSED"))
  sink.on_message(make_test_case_finished_envelope("tcs1"))
  sink.on_message(make_test_run_finished_envelope())
  let output = fmt.output()
  assert_true(string_contains(output, "Feature: Math"))
  assert_true(string_contains(output, "Addition"))
  assert_true(string_contains(output, "\u{2713}"))
  assert_true(string_contains(output, "Given I have 5 cucumbers"))
  assert_true(string_contains(output, "1 scenario (1 passed)"))
}

///|
test "PrettyFormatter formats failed scenario via envelopes" {
  let fmt = PrettyFormatter::new(no_color=true)
  let sink : &@core.MessageSink = fmt
  sink.on_message(make_gherkin_doc_envelope("math.feature", "Math"))
  sink.on_message(
    make_pickle_envelope("p2", "math.feature", "Division by zero", [
      ("ps2", "I divide by zero", "Action"),
    ]),
  )
  sink.on_message(make_test_case_envelope("tc2", "p2", [("ts2", Some("ps2"))]))
  sink.on_message(make_test_case_started_envelope("tcs2", "tc2"))
  sink.on_message(make_test_step_finished_envelope("tcs2", "ts2", "FAILED"))
  sink.on_message(make_test_case_finished_envelope("tcs2"))
  sink.on_message(make_test_run_finished_envelope())
  let output = fmt.output()
  assert_true(string_contains(output, "Division by zero"))
  assert_true(string_contains(output, "\u{2717}"))
  assert_true(string_contains(output, "1 scenario (1 failed)"))
}

///|
test "PrettyFormatter formats summary with mixed results" {
  let fmt = PrettyFormatter::new(no_color=true)
  let sink : &@core.MessageSink = fmt
  // Feature
  sink.on_message(make_gherkin_doc_envelope("test.feature", "Test"))
  // Scenario 1: passed
  sink.on_message(
    make_pickle_envelope("p1", "test.feature", "S1", [
      ("ps1", "step1", "Context"),
    ]),
  )
  sink.on_message(make_test_case_envelope("tc1", "p1", [("ts1", Some("ps1"))]))
  sink.on_message(make_test_case_started_envelope("tcs1", "tc1"))
  sink.on_message(make_test_step_finished_envelope("tcs1", "ts1", "PASSED"))
  sink.on_message(make_test_case_finished_envelope("tcs1"))
  // Scenario 2: passed
  sink.on_message(
    make_pickle_envelope("p2", "test.feature", "S2", [
      ("ps2", "step2", "Action"),
    ]),
  )
  sink.on_message(make_test_case_envelope("tc2", "p2", [("ts2", Some("ps2"))]))
  sink.on_message(make_test_case_started_envelope("tcs2", "tc2"))
  sink.on_message(make_test_step_finished_envelope("tcs2", "ts2", "PASSED"))
  sink.on_message(make_test_case_finished_envelope("tcs2"))
  // Scenario 3: failed
  sink.on_message(
    make_pickle_envelope("p3", "test.feature", "S3", [
      ("ps3", "step3", "Outcome"),
    ]),
  )
  sink.on_message(make_test_case_envelope("tc3", "p3", [("ts3", Some("ps3"))]))
  sink.on_message(make_test_case_started_envelope("tcs3", "tc3"))
  sink.on_message(make_test_step_finished_envelope("tcs3", "ts3", "FAILED"))
  sink.on_message(make_test_case_finished_envelope("tcs3"))
  // Summary
  sink.on_message(make_test_run_finished_envelope())
  let output = fmt.output()
  assert_true(string_contains(output, "3 scenarios"))
  assert_true(string_contains(output, "2 passed"))
  assert_true(string_contains(output, "1 failed"))
}

///|
test "PrettyFormatter prints feature header on URI change" {
  let fmt = PrettyFormatter::new(no_color=true)
  let sink : &@core.MessageSink = fmt
  sink.on_message(make_gherkin_doc_envelope("calc.feature", "Calculator"))
  sink.on_message(
    make_pickle_envelope("p1", "calc.feature", "Add", [
      ("ps1", "adding", "Context"),
    ]),
  )
  sink.on_message(make_test_case_envelope("tc1", "p1", [("ts1", Some("ps1"))]))
  sink.on_message(make_test_case_started_envelope("tcs1", "tc1"))
  let output = fmt.output()
  assert_true(string_contains(output, "Feature: Calculator"))
}

///|
test "PrettyFormatter step markers with multiple statuses" {
  let fmt = PrettyFormatter::new(no_color=true)
  let sink : &@core.MessageSink = fmt
  sink.on_message(make_gherkin_doc_envelope("test.feature", "Test"))
  sink.on_message(
    make_pickle_envelope("p1", "test.feature", "Steps", [
      ("ps1", "step one", "Context"),
      ("ps2", "step two", "Action"),
      ("ps3", "step three", "Outcome"),
    ]),
  )
  sink.on_message(
    make_test_case_envelope("tc1", "p1", [
      ("ts1", Some("ps1")),
      ("ts2", Some("ps2")),
      ("ts3", Some("ps3")),
    ]),
  )
  sink.on_message(make_test_case_started_envelope("tcs1", "tc1"))
  sink.on_message(make_test_step_finished_envelope("tcs1", "ts1", "PASSED"))
  sink.on_message(make_test_step_finished_envelope("tcs1", "ts2", "UNDEFINED"))
  sink.on_message(make_test_step_finished_envelope("tcs1", "ts3", "SKIPPED"))
  sink.on_message(make_test_case_finished_envelope("tcs1"))
  let output = fmt.output()
  assert_true(string_contains(output, "Given step one"))
  assert_true(string_contains(output, "When step two"))
  assert_true(string_contains(output, "Then step three"))
}

///|
test "PrettyFormatter implements MessageSink via envelopes" {
  let fmt = PrettyFormatter::new(no_color=true)
  let sink : &@core.MessageSink = fmt
  // Feed a full sequence
  sink.on_message(make_gherkin_doc_envelope("a.feature", "Alpha"))
  sink.on_message(
    make_pickle_envelope("p1", "a.feature", "Scenario A", [
      ("ps1", "a given step", "Context"),
    ]),
  )
  sink.on_message(make_test_case_envelope("tc1", "p1", [("ts1", Some("ps1"))]))
  sink.on_message(make_test_case_started_envelope("tcs1", "tc1"))
  sink.on_message(make_test_step_finished_envelope("tcs1", "ts1", "PASSED"))
  sink.on_message(make_test_case_finished_envelope("tcs1"))
  sink.on_message(make_test_run_finished_envelope())
  let output = fmt.output()
  assert_true(string_contains(output, "Feature: Alpha"))
  assert_true(string_contains(output, "Scenario A"))
  assert_true(string_contains(output, "1 scenario (1 passed)"))
}

///|
test "PrettyFormatter handles two features" {
  let fmt = PrettyFormatter::new(no_color=true)
  let sink : &@core.MessageSink = fmt
  // Two features
  sink.on_message(make_gherkin_doc_envelope("a.feature", "Feature A"))
  sink.on_message(make_gherkin_doc_envelope("b.feature", "Feature B"))
  // Pickles
  sink.on_message(
    make_pickle_envelope("p1", "a.feature", "S1", [("ps1", "step a", "Context")]),
  )
  sink.on_message(
    make_pickle_envelope("p2", "b.feature", "S2", [("ps2", "step b", "Action")]),
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
  assert_true(string_contains(output, "Feature: Feature A"))
  assert_true(string_contains(output, "Feature: Feature B"))
  assert_true(string_contains(output, "2 scenarios (2 passed)"))
}

///|
test "string_contains basic cases" {
  assert_true(string_contains("hello world", "world"))
  assert_true(string_contains("hello world", "hello"))
  assert_true(string_contains("hello world", ""))
  assert_true(not(string_contains("hello", "xyz")))
  assert_true(not(string_contains("hi", "longer string")))
}
