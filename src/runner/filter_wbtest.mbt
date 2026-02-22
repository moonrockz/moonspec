///|
struct FilterWorld {} derive(Default)

///|
impl @core.World for FilterWorld with register_steps(_self, s) {
  s.given("a step", fn(_args) {  })
}

///|
async test "tag filtering skips non-matching scenarios" {
  let content = "Feature: Tagged\n\n  @smoke\n  Scenario: Tagged\n    Given a step\n\n  Scenario: Untagged\n    Given a step\n"
  let result = run(FilterWorld::default, [FeatureSource::Text("test://filter", content)], tag_expr="@smoke")
  assert_eq(result.summary.total_scenarios, 1)
  assert_eq(result.features[0].scenarios[0].scenario_name, "Tagged")
}

///|
async test "no tag filter runs all" {
  let content = "Feature: All\n\n  Scenario: One\n    Given a step\n\n  Scenario: Two\n    Given a step\n"
  let result = run(FilterWorld::default, [FeatureSource::Text("test://all", content)])
  assert_eq(result.summary.total_scenarios, 2)
}
