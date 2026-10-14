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

///|
test "TagExpression parses nested parentheses" {
  let expr = TagExpression::parse("(@a or @b) and not (@c)")
  assert_true(expr.matches(["@a"]))
  assert_true(expr.matches(["@b"]))
  assert_false(expr.matches(["@a", "@c"]))
  assert_false(expr.matches(["@d"]))
}

///|
test "TagExpression whitespace-only input matches everything" {
  assert_eq(TagExpression::parse("  \t "), Always)
}

///|
test "TagExpression rejects a missing operand at the end" {
  assert_true(parse_result("@a and") is Err(UnexpectedEnd(expression="@a and")))
  assert_true(parse_result("not") is Err(UnexpectedEnd(..)))
  assert_true(parse_result("(") is Err(UnexpectedEnd(..)))
}

///|
test "TagExpression rejects an operator in operand position" {
  assert_true(
    parse_result("and @a")
    is Err(UnexpectedToken(token="and", expression="and @a")),
  )
  assert_true(
    parse_result("@a or or @b") is Err(UnexpectedToken(token="or", ..)),
  )
  assert_true(parse_result("()") is Err(UnexpectedToken(token=")", ..)))
}

///|
test "TagExpression rejects trailing tokens" {
  assert_true(parse_result("@a @b") is Err(UnexpectedToken(token="@b", ..)))
  assert_true(parse_result("@a)") is Err(UnexpectedToken(token=")", ..)))
}

///|
test "TagExpression rejects an unclosed parenthesis" {
  assert_true(
    parse_result("(@a or @b") is Err(UnclosedParen(expression="(@a or @b")),
  )
}

///|
test "TagExpressionError message names the expression" {
  let msg = match parse_result("@a and") {
    Err(e) => e.to_string()
    Ok(_) => "parsed"
  }
  inspect(
    msg,
    content="invalid tag expression \"@a and\": expected a tag, `not` or `(` but the expression ended",
  )
}

///|
fn parse_result(input : String) -> Result[TagExpression, TagExpressionError] {
  try TagExpression::parse(input) catch {
    e => Err(e)
  } noraise {
    expr => Ok(expr)
  }
}
