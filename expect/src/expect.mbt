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

///|
/// Assert a String contains the given substring.
pub fn Expectation::to_contain(
  self : Expectation[String],
  substring : String,
) -> Unit raise Error {
  if not(self.actual.contains(substring)) {
    raise Failure::Failure(
      "Expected \"\{self.actual}\" to contain \"\{substring}\"",
    )
  }
}

///|
/// Assert a String is empty.
pub fn Expectation::to_be_empty_string(
  self : Expectation[String],
) -> Unit raise Error {
  if self.actual.length() != 0 {
    raise Failure::Failure(
      "Expected \"\{self.actual}\" to be empty, but has length \{self.actual.length()}",
    )
  }
}

///|
/// Assert a String has the given length.
pub fn Expectation::to_have_length_string(
  self : Expectation[String],
  expected : Int,
) -> Unit raise Error {
  let actual_len = self.actual.length()
  if actual_len != expected {
    raise Failure::Failure(
      "Expected \"\{self.actual}\" to have length \{expected}, but has length \{actual_len}",
    )
  }
}

///|
/// Assert an Array contains the given element.
pub fn[T : Eq + Show] Expectation::to_contain_element(
  self : Expectation[Array[T]],
  element : T,
) -> Unit raise Error {
  if not(self.actual.contains(element)) {
    raise Failure::Failure("Expected \{self.actual} to contain \{element}")
  }
}

///|
/// Assert an Array is empty.
pub fn[T : Show] Expectation::to_be_empty(
  self : Expectation[Array[T]],
) -> Unit raise Error {
  if self.actual.length() != 0 {
    raise Failure::Failure(
      "Expected \{self.actual} to be empty, but has \{self.actual.length()} elements",
    )
  }
}

///|
/// Assert an Array has the given length.
pub fn[T : Show] Expectation::to_have_length(
  self : Expectation[Array[T]],
  expected : Int,
) -> Unit raise Error {
  let actual_len = self.actual.length()
  if actual_len != expected {
    raise Failure::Failure(
      "Expected \{self.actual} to have length \{expected}, but has length \{actual_len}",
    )
  }
}
