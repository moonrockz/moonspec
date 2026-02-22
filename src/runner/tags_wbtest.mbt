///|
test "TagExpression matches single tag" {
  let expr = TagExpression::parse("@smoke")
  assert_true(expr.matches(["@smoke"]))
  assert_true(expr.matches(["@smoke", "@fast"]))
  assert_false(expr.matches(["@slow"]))
}

///|
test "TagExpression not operator" {
  let expr = TagExpression::parse("not @slow")
  assert_true(expr.matches(["@fast"]))
  assert_false(expr.matches(["@slow"]))
  assert_true(expr.matches([]))
}

///|
test "TagExpression and operator" {
  let expr = TagExpression::parse("@smoke and @fast")
  assert_true(expr.matches(["@smoke", "@fast"]))
  assert_false(expr.matches(["@smoke"]))
}

///|
test "TagExpression or operator" {
  let expr = TagExpression::parse("@smoke or @fast")
  assert_true(expr.matches(["@smoke"]))
  assert_true(expr.matches(["@fast"]))
  assert_false(expr.matches(["@slow"]))
}

///|
test "TagExpression complex expression" {
  let expr = TagExpression::parse("@smoke and not @slow")
  assert_true(expr.matches(["@smoke", "@fast"]))
  assert_false(expr.matches(["@smoke", "@slow"]))
}

///|
test "TagExpression empty matches everything" {
  let expr = TagExpression::parse("")
  assert_true(expr.matches(["@anything"]))
  assert_true(expr.matches([]))
}
