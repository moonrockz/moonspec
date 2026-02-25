///|
/// Wraps a value for fluent assertion chaining.
pub struct Expectation[T] {
  actual : T
}

///|
/// Create an expectation on a value.
pub fn[T] expect(actual : T) -> Expectation[T] {
  { actual, }
}

///|
/// Assert the actual value equals the expected value.
pub fn[T : Eq + Show] Expectation::to_equal(
  self : Expectation[T],
  expected : T,
) -> Unit raise Error {
  if self.actual != expected {
    raise Failure::Failure("Expected \{self.actual} to equal \{expected}")
  }
}

///|
/// Assert the actual value does not equal the given value.
pub fn[T : Eq + Show] Expectation::to_not_equal(
  self : Expectation[T],
  other : T,
) -> Unit raise Error {
  if self.actual == other {
    raise Failure::Failure("Expected \{self.actual} to not equal \{other}")
  }
}
