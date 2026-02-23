///|
struct RunWorld {} derive(Default)

///|
impl @core.World for RunWorld with register_steps(_self, s) {
  s.given("a step", fn(_args) {  })
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
impl @core.World for RunWorld2 with register_steps(_self, s) {
  s.given("pass", fn(_args) {  })
  s.given("fail", fn(_args) raise { raise Failure::Failure("fail") })
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
impl @core.World for PassWorld with register_steps(_self, s) {
  s.given("a calculator", fn(_args) {  })
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
impl @core.World for NoStepsWorld with register_steps(_self, _s) {

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
