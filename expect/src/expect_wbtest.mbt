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

///|
test "expect to_be_true passes" {
  expect(true).to_be_true()
}

///|
test "expect to_be_true fails on false" {
  let mut caught = false
  try {
    expect(false).to_be_true()
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("Expected false to be true"))
    }
  }
  assert_true(caught)
}

///|
test "expect to_be_false passes" {
  expect(false).to_be_false()
}

///|
test "expect to_be_false fails on true" {
  let mut caught = false
  try {
    expect(true).to_be_false()
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("Expected true to be false"))
    }
  }
  assert_true(caught)
}

///|
test "expect to_be_some passes on Some" {
  let opt : Int? = Some(42)
  expect(opt).to_be_some()
}

///|
test "expect to_be_some fails on None" {
  let mut caught = false
  try {
    let opt : Int? = None
    expect(opt).to_be_some()
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("Expected None to be Some"))
    }
  }
  assert_true(caught)
}

///|
test "expect to_be_none passes on None" {
  let opt : Int? = None
  expect(opt).to_be_none()
}

///|
test "expect to_be_none fails on Some" {
  let mut caught = false
  try {
    let opt : Int? = Some(42)
    expect(opt).to_be_none()
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("to be None"))
    }
  }
  assert_true(caught)
}
