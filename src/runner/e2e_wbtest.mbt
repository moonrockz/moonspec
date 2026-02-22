///|
struct CalcWorld {
  mut result_val : Int
} derive(Default)

///|
impl @core.World for CalcWorld with register_steps(self, s) {
  s.given("a calculator", fn(_args) { self.result_val = 0 })
  s.when("I add {int} and {int}", fn(args) {
    match (args[0], args[1]) {
      (@core.StepArg::IntArg(a), @core.StepArg::IntArg(b)) =>
        self.result_val = a + b
      _ => ()
    }
  })
  s.when("I subtract {int} from {int}", fn(args) {
    match (args[0], args[1]) {
      (@core.StepArg::IntArg(a), @core.StepArg::IntArg(b)) =>
        self.result_val = b - a
      _ => ()
    }
  })
  s.when("I multiply {int} and {int}", fn(args) {
    match (args[0], args[1]) {
      (@core.StepArg::IntArg(a), @core.StepArg::IntArg(b)) =>
        self.result_val = a * b
      _ => ()
    }
  })
  s.then("the result should be {int}", fn(args) raise {
    match args[0] {
      @core.StepArg::IntArg(expected) => assert_eq(self.result_val, expected)
      _ => ()
    }
  })
}

///|
async test "end-to-end: calculator feature" {
  let content = "Feature: Calculator\n\n  Background:\n    Given a calculator\n\n  Scenario: Addition\n    When I add 5 and 3\n    Then the result should be 8\n\n  Scenario: Subtraction\n    When I subtract 3 from 10\n    Then the result should be 7\n\n  @slow\n  Scenario Outline: Multiplication\n    When I multiply <a> and <b>\n    Then the result should be <result>\n\n    Examples:\n      | a  | b  | result |\n      | 2  | 3  | 6      |\n      | 10 | 5  | 50     |\n"
  let result = run(CalcWorld::default, [
    FeatureSource::Text("test://calc", content),
  ])
  assert_eq(result.summary.total_scenarios, 4) // 2 regular + 2 outline rows
  assert_eq(result.summary.passed, 4)
  assert_eq(result.summary.failed, 0)
}

///|
struct TagWorld {} derive(Default)

///|
impl @core.World for TagWorld with register_steps(_self, s) {
  s.given("a calculator", fn(_args) {  })
  s.when("I add {int} and {int}", fn(_args) {  })
  s.then("the result should be {int}", fn(_args) {  })
}

///|
async test "end-to-end: tag filtering" {
  let content = "Feature: Tagged\n\n  @smoke\n  Scenario: Fast\n    Given a calculator\n\n  @slow\n  Scenario: Slow\n    Given a calculator\n"
  let result = run(
    TagWorld::default,
    [FeatureSource::Text("test://tagged", content)],
    tag_expr="@smoke",
  )
  assert_eq(result.summary.total_scenarios, 1)
}
