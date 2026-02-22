///|
struct FilterWorld {} derive(Default)

///|
impl @core.World for FilterWorld with register_steps(_self, s) {
  s.given("a step", fn(_args) {  })
}

///|
test "execute_feature_filtered skips non-matching scenarios" {
  let content = "Feature: Tagged\n\n  @smoke\n  Scenario: Tagged\n    Given a step\n\n  Scenario: Untagged\n    Given a step\n"
  let result = execute_feature_filtered(FilterWorld::default, content, tag_expr="@smoke")
  assert_eq(result.scenarios.length(), 1)
  assert_eq(result.scenarios[0].scenario_name, "Tagged")
}

///|
test "execute_feature_filtered with no tag filter runs all" {
  let content = "Feature: All\n\n  Scenario: One\n    Given a step\n\n  Scenario: Two\n    Given a step\n"
  let result = execute_feature_filtered(FilterWorld::default, content, tag_expr="")
  assert_eq(result.scenarios.length(), 2)
}
