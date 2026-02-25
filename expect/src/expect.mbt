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

///|
/// Assert the actual boolean value is true.
pub fn Expectation::to_be_true(self : Expectation[Bool]) -> Unit raise Error {
  if not(self.actual) {
    raise Failure::Failure("Expected false to be true")
  }
}

///|
/// Assert the actual boolean value is false.
pub fn Expectation::to_be_false(self : Expectation[Bool]) -> Unit raise Error {
  if self.actual {
    raise Failure::Failure("Expected true to be false")
  }
}

///|
/// Assert the actual Option value is Some.
pub fn[T] Expectation::to_be_some(
  self : Expectation[T?],
) -> Unit raise Error {
  match self.actual {
    Some(_) => ()
    None => raise Failure::Failure("Expected None to be Some")
  }
}

///|
/// Assert the actual Option value is None.
pub fn[T : Show] Expectation::to_be_none(
  self : Expectation[T?],
) -> Unit raise Error {
  match self.actual {
    None => ()
    Some(_) => raise Failure::Failure("Expected \{self.actual} to be None")
  }
}
