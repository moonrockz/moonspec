///|
struct RunWorld {} derive(Default)

///|
impl @core.World for RunWorld with configure(_self, setup) {
  setup.given("a step", fn(_args) {  })
}

///|
async test "run single feature and collect summary" {
  let features = [
    FeatureSource::Text(
      "test://one", "Feature: One\n\n  Scenario: Pass\n    Given a step\n",
    ),
  ]
  let result = run(RunWorld::default, features)
  assert_eq(result.summary.total_scenarios, 1)
  assert_eq(result.summary.passed, 1)
  assert_eq(result.summary.failed, 0)
}

///|
struct RunWorld2 {} derive(Default)

///|
impl @core.World for RunWorld2 with configure(_self, setup) {
  setup.given("pass", fn(_args) {  })
  setup.given("fail", fn(_args) raise { raise Failure::Failure("fail") })
}

///|
async test "run multiple features" {
  let features = [
    FeatureSource::Text(
      "test://a", "Feature: A\n\n  Scenario: Pass\n    Given pass\n",
    ),
    FeatureSource::Text(
      "test://b", "Feature: B\n\n  Scenario: Fail\n    Given fail\n",
    ),
  ]
  let result = run(RunWorld2::default, features)
  assert_eq(result.summary.total_scenarios, 2)
  assert_eq(result.summary.passed, 1)
  assert_eq(result.summary.failed, 1)
  assert_eq(result.features.length(), 2)
}

///|
struct PassWorld {} derive(Default)

///|
impl @core.World for PassWorld with configure(_self, setup) {
  setup.given("a calculator", fn(_args) {  })
}

///|
async test "run_or_fail succeeds when all pass" {
  let content = "Feature: Simple\n\n  Scenario: Pass\n    Given a calculator\n"
  let result = run_or_fail(PassWorld::default, [
    FeatureSource::Text("test://pass", content),
  ])
  assert_eq(result.summary.passed, 1)
}

///|
struct NoStepsWorld {} derive(Default)

///|
impl @core.World for NoStepsWorld with configure(_self, _setup) {

}

///|
async test "run_or_fail raises RunFailed on undefined steps" {
  let content = "Feature: Fail\n\n  Scenario: Undefined\n    Given an undefined step\n"
  let mut caught = false
  try
    run_or_fail(NoStepsWorld::default, [
      FeatureSource::Text("test://fail", content),
    ])
    |> ignore
  catch {
    @core.RunFailed(..) => caught = true
    _ => ()
  }
  assert_true(caught)
}

///|
async test "run accepts sinks parameter" {
  let collector = CollectorSink::new()
  let features = [
    FeatureSource::Text(
      "test://sink", "Feature: Sink\n\n  Scenario: Pass\n    Given a step\n",
    ),
  ]
  let result = run(RunWorld::default, features, sinks=[collector])
  assert_eq(result.summary.passed, 1)
}

///|
async test "run emits Meta envelope first" {
  let collector = CollectorSink::new()
  let features = [
    FeatureSource::Text(
      "test://meta", "Feature: Meta\n\n  Scenario: S\n    Given a step\n",
    ),
  ]
  let _ = run(RunWorld::default, features, sinks=[collector])
  assert_true(collector.envelopes.length() > 0)
  guard collector.envelopes[0] is @cucumber_messages.Envelope::Meta(_)
}

///|
async test "run emits Source envelope for each feature" {
  let collector = CollectorSink::new()
  let content = "Feature: Src\n\n  Scenario: S\n    Given a step\n"
  let features = [FeatureSource::Text("test://src", content)]
  let _ = run(RunWorld::default, features, sinks=[collector])
  let mut found = false
  for env in collector.envelopes {
    match env {
      @cucumber_messages.Envelope::Source(src) => {
        assert_eq(src.uri, "test://src")
        assert_eq(src.data, content)
        found = true
        break
      }
      _ => continue
    }
  }
  assert_true(found)
}

///|
async test "run emits GherkinDocument envelope after parsing" {
  let collector = CollectorSink::new()
  let features = [
    FeatureSource::Text(
      "test://gdoc", "Feature: GDoc\n\n  Scenario: S\n    Given a step\n",
    ),
  ]
  let _ = run(RunWorld::default, features, sinks=[collector])
  let mut found = false
  for env in collector.envelopes {
    if env is @cucumber_messages.Envelope::GherkinDocument(_) {
      found = true
      break
    }
  }
  assert_true(found)
}

///|
async test "run emits Pickle envelopes after compilation" {
  let collector = CollectorSink::new()
  let features = [
    FeatureSource::Text(
      "test://pickle", "Feature: P\n\n  Scenario: One\n    Given a step\n  Scenario: Two\n    Given a step\n",
    ),
  ]
  let _ = run(RunWorld::default, features, sinks=[collector])
  let mut pickle_count = 0
  for env in collector.envelopes {
    if env is @cucumber_messages.Envelope::Pickle(_) {
      pickle_count += 1
    }
  }
  assert_eq(pickle_count, 2)
}

///|
async test "run emits StepDefinition envelopes after Pickles" {
  let collector = CollectorSink::new()
  let features = [
    FeatureSource::Text(
      "test://sd", "Feature: SD\n\n  Scenario: S\n    Given a step\n",
    ),
  ]
  let _ = run(RunWorld::default, features, sinks=[collector])
  let mut sd_count = 0
  let mut pickle_idx = -1
  let mut first_sd_idx = -1
  let mut first_tc_idx = -1
  for i, env in collector.envelopes {
    match env {
      @cucumber_messages.Envelope::Pickle(_) =>
        if pickle_idx < 0 {
          pickle_idx = i
        }
      @cucumber_messages.Envelope::StepDefinition(_) => {
        sd_count += 1
        if first_sd_idx < 0 {
          first_sd_idx = i
        }
      }
      @cucumber_messages.Envelope::TestCase(_) =>
        if first_tc_idx < 0 {
          first_tc_idx = i
        }
      _ => ()
    }
  }
  // RunWorld registers one step ("a step"), so exactly one StepDefinition
  assert_eq(sd_count, 1)
  // StepDefinition appears after Pickle and before TestCase
  assert_true(first_sd_idx > pickle_idx)
  assert_true(first_sd_idx < first_tc_idx)
}

///|
async test "run emits TestCase envelopes with test steps" {
  let collector = CollectorSink::new()
  let features = [
    FeatureSource::Text(
      "test://tc", "Feature: TC\n\n  Scenario: S\n    Given a step\n",
    ),
  ]
  let _ = run(RunWorld::default, features, sinks=[collector])
  let mut found = false
  for env in collector.envelopes {
    if env is @cucumber_messages.Envelope::TestCase(_) {
      found = true
      break
    }
  }
  assert_true(found)
}

///|
async test "run emits envelopes in canonical order" {
  let collector = CollectorSink::new()
  let features = [
    FeatureSource::Text(
      "test://order", "Feature: Order\n\n  Scenario: S\n    Given a step\n",
    ),
  ]
  let _ = run(RunWorld::default, features, sinks=[collector])
  let types : Array[String] = []
  for env in collector.envelopes {
    match env {
      @cucumber_messages.Envelope::Meta(_) => types.push("Meta")
      @cucumber_messages.Envelope::Source(_) => types.push("Source")
      @cucumber_messages.Envelope::GherkinDocument(_) =>
        types.push("GherkinDocument")
      @cucumber_messages.Envelope::Pickle(_) => types.push("Pickle")
      @cucumber_messages.Envelope::StepDefinition(_) =>
        types.push("StepDefinition")
      @cucumber_messages.Envelope::TestCase(_) => types.push("TestCase")
      @cucumber_messages.Envelope::TestRunStarted(_) =>
        types.push("TestRunStarted")
      @cucumber_messages.Envelope::TestCaseStarted(_) =>
        types.push("TestCaseStarted")
      @cucumber_messages.Envelope::TestStepStarted(_) =>
        types.push("TestStepStarted")
      @cucumber_messages.Envelope::TestStepFinished(_) =>
        types.push("TestStepFinished")
      @cucumber_messages.Envelope::TestCaseFinished(_) =>
        types.push("TestCaseFinished")
      @cucumber_messages.Envelope::TestRunFinished(_) =>
        types.push("TestRunFinished")
      _ => types.push("Other")
    }
  }
  let expected : Array[String] = [
    "Meta", "Source", "GherkinDocument", "Pickle", "StepDefinition", "TestCase",
    "TestRunStarted", "TestCaseStarted", "TestStepStarted", "TestStepFinished", "TestCaseFinished",
    "TestRunFinished",
  ]
  assert_eq(types, expected)
}

///|
async test "full envelope sequence for two-scenario feature" {
  let collector = CollectorSink::new()
  let content = "Feature: Full\n\n  Scenario: A\n    Given a step\n\n  Scenario: B\n    Given a step\n"
  let features = [FeatureSource::Text("test://full", content)]
  let _ = run(RunWorld::default, features, sinks=[collector])
  let types : Array[String] = []
  for env in collector.envelopes {
    match env {
      @cucumber_messages.Envelope::Meta(_) => types.push("Meta")
      @cucumber_messages.Envelope::Source(_) => types.push("Source")
      @cucumber_messages.Envelope::GherkinDocument(_) =>
        types.push("GherkinDocument")
      @cucumber_messages.Envelope::Pickle(_) => types.push("Pickle")
      @cucumber_messages.Envelope::StepDefinition(_) =>
        types.push("StepDefinition")
      @cucumber_messages.Envelope::TestCase(_) => types.push("TestCase")
      @cucumber_messages.Envelope::TestRunStarted(_) =>
        types.push("TestRunStarted")
      @cucumber_messages.Envelope::TestCaseStarted(_) =>
        types.push("TestCaseStarted")
      @cucumber_messages.Envelope::TestStepStarted(_) =>
        types.push("TestStepStarted")
      @cucumber_messages.Envelope::TestStepFinished(_) =>
        types.push("TestStepFinished")
      @cucumber_messages.Envelope::TestCaseFinished(_) =>
        types.push("TestCaseFinished")
      @cucumber_messages.Envelope::TestRunFinished(_) =>
        types.push("TestRunFinished")
      _ => types.push("Other")
    }
  }
  // Expected: Meta, Source, GherkinDocument, 2x Pickle, StepDefinition,
  // 2x TestCase, TestRunStarted,
  // 2x (TestCaseStarted, TestStepStarted, TestStepFinished, TestCaseFinished),
  // TestRunFinished
  let expected : Array[String] = [
    "Meta", "Source", "GherkinDocument", "Pickle", "Pickle", "StepDefinition", "TestCase",
    "TestCase", "TestRunStarted", "TestCaseStarted", "TestStepStarted", "TestStepFinished",
    "TestCaseFinished", "TestCaseStarted", "TestStepStarted", "TestStepFinished",
    "TestCaseFinished", "TestRunFinished",
  ]
  assert_eq(types, expected)
  // Verify first is Meta, last is TestRunFinished
  guard collector.envelopes[0] is @cucumber_messages.Envelope::Meta(_)
  guard collector.envelopes[collector.envelopes.length() - 1]
    is @cucumber_messages.Envelope::TestRunFinished(_)
}

///|
async test "run emits no ParameterType envelopes for built-in types only" {
  let collector = CollectorSink::new()
  let features = [
    FeatureSource::Text(
      "test://pt", "Feature: PT\n\n  Scenario: S\n    Given a step\n",
    ),
  ]
  let _ = run(RunWorld::default, features, sinks=[collector])
  let mut pt_count = 0
  for env in collector.envelopes {
    if env is @cucumber_messages.Envelope::ParameterType(_) {
      pt_count += 1
    }
  }
  assert_eq(pt_count, 0)
}

///|
struct ParamWorld {} derive(Default)

///|
impl @core.World for ParamWorld with configure(_self, setup) {
  setup.add_param_type_strings("color", ["red|blue|green"])
  setup.given("I pick a {color} cucumber", fn(_args) {  })
}

///|
async test "run emits ParameterType envelopes for custom types" {
  let collector = CollectorSink::new()
  let features = [
    FeatureSource::Text(
      "test://pt", "Feature: PT\n\n  Scenario: S\n    Given I pick a red cucumber\n",
    ),
  ]
  let _ = run(ParamWorld::default, features, sinks=[collector])
  let mut pt_count = 0
  for env in collector.envelopes {
    if env is @cucumber_messages.Envelope::ParameterType(_) {
      pt_count += 1
    }
  }
  assert_eq(pt_count, 1)
}

///|
async test "run emits ParameterType after StepDefinition before TestCase" {
  let collector = CollectorSink::new()
  let features = [
    FeatureSource::Text(
      "test://pt-order", "Feature: PTO\n\n  Scenario: S\n    Given I pick a blue cucumber\n",
    ),
  ]
  let _ = run(ParamWorld::default, features, sinks=[collector])
  let mut sd_idx = -1
  let mut pt_idx = -1
  let mut tc_idx = -1
  for i, env in collector.envelopes {
    match env {
      @cucumber_messages.Envelope::StepDefinition(_) =>
        if sd_idx < 0 {
          sd_idx = i
        }
      @cucumber_messages.Envelope::ParameterType(_) =>
        if pt_idx < 0 {
          pt_idx = i
        }
      @cucumber_messages.Envelope::TestCase(_) => if tc_idx < 0 { tc_idx = i }
      _ => ()
    }
  }
  assert_true(pt_idx > sd_idx)
  assert_true(pt_idx < tc_idx)
}

///|
async test "run emits ParseError envelope for invalid feature" {
  let collector = CollectorSink::new()
  let features = [
    FeatureSource::Text("test://bad", "This is not valid Gherkin"),
    FeatureSource::Text(
      "test://ok", "Feature: OK\n\n  Scenario: S\n    Given a step\n",
    ),
  ]
  let result = run(RunWorld::default, features, sinks=[collector])
  // Run should continue with valid features
  assert_eq(result.summary.total_scenarios, 1)
  // Parse errors should be in result
  assert_eq(result.parse_errors.length(), 1)
  assert_eq(result.parse_errors[0].uri, "test://bad")
  // ParseError envelope should be emitted
  let mut found_parse_error = false
  for env in collector.envelopes {
    if env is @cucumber_messages.Envelope::ParseError(_) {
      found_parse_error = true
    }
  }
  assert_true(found_parse_error)
}

///|
async test "run_or_fail raises on parse errors" {
  let mut caught = false
  try
    run_or_fail(RunWorld::default, [
      FeatureSource::Text("test://bad", "Not valid Gherkin"),
    ])
    |> ignore
  catch {
    @core.RunFailed(..) => caught = true
    _ => ()
  }
  assert_true(caught)
}
