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

///|
test "expect to_contain passes when string contains substring" {
  expect("hello world").to_contain("world")
}

///|
test "expect to_contain fails when string missing substring" {
  let mut caught = false
  try {
    expect("hello").to_contain("xyz")
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("hello") && e.to_string().contains("to contain") && e.to_string().contains("xyz"))
    }
  }
  assert_true(caught)
}

///|
test "expect to_contain_element passes when array contains element" {
  expect([1, 2, 3]).to_contain_element(2)
}

///|
test "expect to_contain_element fails when array missing element" {
  let mut caught = false
  try {
    expect([1, 2, 3]).to_contain_element(5)
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("Expected [1, 2, 3] to contain 5"))
    }
  }
  assert_true(caught)
}

///|
test "expect to_be_empty passes on empty array" {
  let arr : Array[Int] = []
  expect(arr).to_be_empty()
}

///|
test "expect to_be_empty fails on non-empty array" {
  let mut caught = false
  try {
    expect([1, 2]).to_be_empty()
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("to be empty, but has 2 elements"))
    }
  }
  assert_true(caught)
}

///|
test "expect to_be_empty_string passes on empty string" {
  expect("").to_be_empty_string()
}

///|
test "expect to_be_empty_string fails on non-empty string" {
  let mut caught = false
  try {
    expect("hello").to_be_empty_string()
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("to be empty, but has length 5"))
    }
  }
  assert_true(caught)
}

///|
test "expect to_have_length passes on correct array length" {
  expect([1, 2, 3]).to_have_length(3)
}

///|
test "expect to_have_length fails on wrong array length" {
  let mut caught = false
  try {
    expect([1, 2]).to_have_length(5)
  } catch {
    e => {
      caught = true
      assert_true(
        e.to_string().contains("to have length 5, but has length 2"),
      )
    }
  }
  assert_true(caught)
}

///|
test "expect to_have_length_string passes on correct string length" {
  expect("hello").to_have_length_string(5)
}

///|
test "expect to_have_length_string fails on wrong string length" {
  let mut caught = false
  try {
    expect("hello").to_have_length_string(3)
  } catch {
    e => {
      caught = true
      assert_true(
        e.to_string().contains("to have length 3, but has length 5"),
      )
    }
  }
  assert_true(caught)
}
