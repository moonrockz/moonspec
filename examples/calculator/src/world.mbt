///|
/// World struct holding per-scenario state for calculator tests.
/// Each scenario gets a fresh instance via `derive(Default)`.
struct CalcWorld {
  mut result : Int
} derive(Default)

///|
/// Register step definitions. Closures capture `self` to share state
/// between steps within a single scenario.
impl @moonspec.World for CalcWorld with register_steps(self, s) {
  s.given("a calculator", fn(_args) { self.result = 0 })
  s.when("I add {int} and {int}", fn(args) {
    match (args[0], args[1]) {
      (@moonspec.StepArg::IntArg(a), @moonspec.StepArg::IntArg(b)) => self.result = a + b
      _ => ()
    }
  })
  s.when("I subtract {int} from {int}", fn(args) {
    match (args[0], args[1]) {
      (@moonspec.StepArg::IntArg(a), @moonspec.StepArg::IntArg(b)) => self.result = b - a
      _ => ()
    }
  })
  s.when("I multiply {int} and {int}", fn(args) {
    match (args[0], args[1]) {
      (@moonspec.StepArg::IntArg(a), @moonspec.StepArg::IntArg(b)) => self.result = a * b
      _ => ()
    }
  })
  s.then("the result should be {int}", fn(args) raise {
    match args[0] {
      @moonspec.StepArg::IntArg(expected) => assert_eq(self.result, expected)
      _ => ()
    }
  })
}
