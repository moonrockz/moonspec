///|
struct ParWorld {} derive(Default)

///|
impl @core.World for ParWorld with register_steps(_self, s) {
  s.given("a step", fn(_args) {  })
  s.given("step a", fn(_args) {  })
  s.given("step b", fn(_args) {  })
}

///|
async test "run with parallel parameter executes all features" {
  let features = [
    FeatureSource::Text(
      "test://par-a", "Feature: A\n\n  Scenario: S1\n    Given a step\n",
    ),
    FeatureSource::Text(
      "test://par-b", "Feature: B\n\n  Scenario: S2\n    Given a step\n",
    ),
  ]
  let result = run(ParWorld::default, features, parallel=2)
  assert_eq(result.summary.total_scenarios, 2)
  assert_eq(result.summary.passed, 2)
}

///|
async test "run with parallel=0 falls back to sequential" {
  let features = [
    FeatureSource::Text(
      "test://par-seq", "Feature: A\n\n  Scenario: S1\n    Given a step\n",
    ),
  ]
  let result = run(ParWorld::default, features, parallel=0)
  assert_eq(result.summary.total_scenarios, 1)
  assert_eq(result.summary.passed, 1)
}

///|
async test "run with parallel preserves feature order" {
  let features = [
    FeatureSource::Text(
      "test://par-first", "Feature: First\n\n  Scenario: S1\n    Given step a\n",
    ),
    FeatureSource::Text(
      "test://par-second", "Feature: Second\n\n  Scenario: S2\n    Given step b\n",
    ),
  ]
  let result = run(ParWorld::default, features, parallel=4)
  assert_eq(result.features[0].name, "First")
  assert_eq(result.features[1].name, "Second")
}

///|
async test "run with parallel and tag filtering" {
  let features = [
    FeatureSource::Text(
      "test://par-tag-a", "Feature: A\n\n  @smoke\n  Scenario: S1\n    Given a step\n",
    ),
    FeatureSource::Text(
      "test://par-tag-b", "Feature: B\n\n  Scenario: S2\n    Given a step\n",
    ),
  ]
  let result = run(ParWorld::default, features, parallel=2, tag_expr="@smoke")
  assert_eq(result.summary.total_scenarios, 1)
  assert_eq(result.summary.passed, 1)
}
