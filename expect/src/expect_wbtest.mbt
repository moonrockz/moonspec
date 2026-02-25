///|
test "expect to_equal passes on equal values" {
  expect(42).to_equal(42)
}

///|
test "expect to_equal fails on unequal values" {
  let mut caught = false
  try {
    expect(3).to_equal(5)
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("Expected 3 to equal 5"))
    }
  }
  assert_true(caught)
}

///|
test "expect to_not_equal passes on unequal values" {
  expect(3).to_not_equal(5)
}

///|
test "expect to_not_equal fails on equal values" {
  let mut caught = false
  try {
    expect(42).to_not_equal(42)
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("Expected 42 to not equal 42"))
    }
  }
  assert_true(caught)
}

///|
test "expect to_equal works with strings" {
  expect("hello").to_equal("hello")
}

///|
test "expect to_equal fails with string mismatch" {
  let mut caught = false
  try {
    expect("hello").to_equal("world")
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("Expected hello to equal world"))
    }
  }
  assert_true(caught)
}
