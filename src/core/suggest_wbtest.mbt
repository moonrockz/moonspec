///|
test "levenshtein_distance identical strings" {
  assert_eq(levenshtein_distance("abc", "abc"), 0)
}

///|
test "levenshtein_distance one edit" {
  assert_eq(levenshtein_distance("abc", "abd"), 1)
}

///|
test "levenshtein_distance empty strings" {
  assert_eq(levenshtein_distance("", "abc"), 3)
  assert_eq(levenshtein_distance("abc", ""), 3)
}

///|
test "find_suggestions returns close matches" {
  let reg = StepRegistry::new()
  reg.given("I have {int} cucumbers", fn(_args) {  })
  reg.given("I have {int} tomatoes", fn(_args) {  })
  reg.given("something completely different", fn(_args) {  })
  let suggestions = find_suggestions(reg, "I have many cucumbers")
  assert_true(suggestions.length() > 0)
  assert_true(suggestions.length() <= 3)
}
