///|
struct BgWorld {
  mut context : String
} derive(Default)

///|
impl @core.World for BgWorld with register_steps(self, s) {
  s.given("a common setup", fn(_args) { self.context = "setup" })
  s.when("I do something", fn(_args) {  })
  s.then("it works", fn(_args) raise { assert_eq(self.context, "setup") })
}

///|
test "execute_feature prepends background steps to each scenario" {
  let content = "Feature: With Background\n\n  Background:\n    Given a common setup\n\n  Scenario: First\n    When I do something\n    Then it works\n\n  Scenario: Second\n    When I do something\n    Then it works\n"
  let result = execute_feature(BgWorld::default, content)
  assert_eq(result.scenarios.length(), 2)
  // Each scenario should have 3 steps (1 background + 2 scenario)
  assert_eq(result.scenarios[0].steps.length(), 3)
  assert_eq(result.scenarios[1].steps.length(), 3)
  assert_eq(result.scenarios[0].status, ScenarioStatus::Passed)
}
