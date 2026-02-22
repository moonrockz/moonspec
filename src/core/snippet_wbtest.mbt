///|
test "generate_snippet for plain step text" {
  let snippet = generate_snippet("hello world", "Given ")
  assert_true!(contains(snippet, "s.given"))
  assert_true!(contains(snippet, "hello world"))
  assert_true!(contains(snippet, "PendingStep"))
}

///|
test "generate_snippet detects integer parameters" {
  let snippet = generate_snippet("I have 42 cucumbers", "Given ")
  assert_true!(contains(snippet, "{int}"))
}

///|
test "generate_snippet detects quoted string parameters" {
  let snippet = generate_snippet("I say \"hello\"", "When ")
  assert_true!(contains(snippet, "{string}"))
}

///|
test "generate_snippet for Then keyword" {
  let snippet = generate_snippet("the result is 5", "Then ")
  assert_true!(contains(snippet, "s.then"))
}

///|
test "generate_snippet for unknown keyword uses step" {
  let snippet = generate_snippet("something", "* ")
  assert_true!(contains(snippet, "s.step"))
}
