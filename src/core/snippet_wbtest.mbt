///|
test "generate_snippet for plain step text" {
  let snippet = generate_snippet("hello world", "Given ")
  assert_true(snippet.contains("s.given"))
  assert_true(snippet.contains("hello world"))
  assert_true(snippet.contains("PendingStep"))
}

///|
test "generate_snippet detects integer parameters" {
  let snippet = generate_snippet("I have 42 cucumbers", "Given ")
  assert_true(snippet.contains("{int}"))
}

///|
test "generate_snippet detects quoted string parameters" {
  let snippet = generate_snippet("I say \"hello\"", "When ")
  assert_true(snippet.contains("{string}"))
}

///|
test "generate_snippet for Then keyword" {
  let snippet = generate_snippet("the result is 5", "Then ")
  assert_true(snippet.contains("s.then"))
}

///|
test "generate_snippet for unknown keyword uses step" {
  let snippet = generate_snippet("something", "* ")
  assert_true(snippet.contains("s.step"))
}
