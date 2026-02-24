///|
struct BgWorld {
  mut context : String
} derive(Default)

///|
impl @core.World for BgWorld with configure(self, setup) {
  setup.given("a common setup", fn(_args) { self.context = "setup" })
  setup.when("I do something", fn(_args) {  })
  setup.then("it works", fn(_args) raise { assert_eq(self.context, "setup") })
}

///|
async test "background steps prepended to each scenario" {
  let content = "Feature: With Background\n\n  Background:\n    Given a common setup\n\n  Scenario: First\n    When I do something\n    Then it works\n\n  Scenario: Second\n    When I do something\n    Then it works\n"
  let result = run(
    BgWorld::default,
    RunOptions([FeatureSource::Text("test://bg", content)]),
  )
  assert_eq(result.summary.total_scenarios, 2)
  // Each scenario should have 3 steps (1 background + 2 scenario)
  assert_eq(result.features[0].scenarios[0].steps.length(), 3)
  assert_eq(result.features[0].scenarios[1].steps.length(), 3)
  assert_eq(result.summary.passed, 2)
}
