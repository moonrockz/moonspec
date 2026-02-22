///|
struct CucumberWorld {
  mut total : Int
} derive(Default)

///|
impl @core.World for CucumberWorld with register_steps(self, s) {
  s.given("I have {int} cucumbers", fn(args) {
    match args[0] {
      @core.StepArg::IntArg(n) => self.total = n
      _ => ()
    }
  })
  s.when("I eat {int} cucumbers", fn(args) {
    match args[0] {
      @core.StepArg::IntArg(n) => self.total = self.total - n
      _ => ()
    }
  })
  s.then("I should have {int} cucumbers", fn(args) raise {
    match args[0] {
      @core.StepArg::IntArg(n) => assert_eq(self.total, n)
      _ => ()
    }
  })
}

///|
async test "feature parses and runs all scenarios" {
  let feature_content = "Feature: Simple math\n\n  Scenario: Addition\n    Given I have 5 cucumbers\n    When I eat 3 cucumbers\n    Then I should have 2 cucumbers\n\n  Scenario: No eating\n    Given I have 10 cucumbers\n    Then I should have 10 cucumbers\n"
  let result = run(CucumberWorld::default, [FeatureSource::Text("test://math", feature_content)])
  assert_eq(result.features[0].name, "Simple math")
  assert_eq(result.summary.total_scenarios, 2)
  assert_eq(result.summary.passed, 2)
}

///|
struct EmptyWorld {} derive(Default)

///|
impl @core.World for EmptyWorld with register_steps(_self, _s) { () }

///|
async test "feature handles undefined steps" {
  let feature_content = "Feature: Unknown\n\n  Scenario: Missing step\n    Given something undefined\n"
  let result = run(EmptyWorld::default, [FeatureSource::Text("test://undefined", feature_content)])
  assert_eq(result.features[0].scenarios[0].status, ScenarioStatus::Undefined)
}
