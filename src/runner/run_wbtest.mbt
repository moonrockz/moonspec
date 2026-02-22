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
