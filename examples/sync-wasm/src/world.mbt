///|
struct CalculatorWorld {
  mut result : Int32
} derive(Default)

///|
pub extend CalculatorWorld with Default::{default}

///|
impl @moonspec.World for CalculatorWorld with fn configure(self, setup) {
  setup.given0("a calculator", fn() { self.result = 0 })
  setup.when2("I add {int} and {int}", fn(left : Int32, right : Int32) {
    self.result = left + right
  })
  setup.then1("the result should be {int}", fn(expected : Int32) {
    assert_eq(self.result, expected)
  })
}
