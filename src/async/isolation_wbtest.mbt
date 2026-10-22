///|
struct IsolationWorld {
  mut counter : Int32
} derive(Default)

///|
pub extend IsolationWorld with Default::{default}

///|
impl @core.World for IsolationWorld with fn configure(self, setup) {
  setup.given("I set counter to {int}", ctx => {
    match ctx[0] {
      { value: @core.StepValue::IntVal(n), .. } => self.counter = n
      _ => ()
    }
  })
  setup.then("counter should be {int}", fn(ctx) raise {
    match ctx[0] {
      { value: @core.StepValue::IntVal(expected), .. } =>
        assert_eq(self.counter, expected)
      _ => ()
    }
  })
}

///|
async test "isolation: parallel execution with fresh worlds" {
  let feature1 = "Feature: F1\n\n  Scenario: Set counter\n    Given I set counter to 99\n    Then counter should be 99\n"
  let feature2 = "Feature: F2\n\n  Scenario: Fresh world\n    Then counter should be 0\n"
  let opts = RunOptions([
    FeatureSource::Text("test://iso-f1", feature1),
    FeatureSource::Text("test://iso-f2", feature2),
  ])
  opts.parallel(true)
  opts.max_concurrent(2)
  let result = run(IsolationWorld::default, opts)
  assert_eq(result.summary.total_scenarios, 2)
  assert_eq(result.summary.passed, 2)
}
