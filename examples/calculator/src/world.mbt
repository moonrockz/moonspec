///|
/// World struct holding per-scenario state for calculator tests.
/// Each scenario gets a fresh instance via `derive(Default)`.
struct CalcWorld {
  mut result : Int
} derive(Default)

///|
/// Register step definitions. Closures capture `self` to share state
/// between steps within a single scenario.
impl @moonspec.World for CalcWorld with configure(self, setup) {
  setup.given("a calculator", fn(_args) { self.result = 0 })
  setup.when("I add {int} and {int}", fn(args) {
    match (args[0], args[1]) {
      ({ value: @moonspec.StepValue::IntVal(a), .. }, { value: @moonspec.StepValue::IntVal(b), .. }) => self.result = a + b
      _ => ()
    }
  })
  setup.when("I subtract {int} from {int}", fn(args) {
    match (args[0], args[1]) {
      ({ value: @moonspec.StepValue::IntVal(a), .. }, { value: @moonspec.StepValue::IntVal(b), .. }) => self.result = b - a
      _ => ()
    }
  })
  setup.when("I multiply {int} and {int}", fn(args) {
    match (args[0], args[1]) {
      ({ value: @moonspec.StepValue::IntVal(a), .. }, { value: @moonspec.StepValue::IntVal(b), .. }) => self.result = a * b
      _ => ()
    }
  })
  setup.then("the result should be {int}", fn(args) raise {
    match args[0] {
      { value: @moonspec.StepValue::IntVal(expected), .. } => assert_eq(self.result, expected)
      _ => ()
    }
  })
}
