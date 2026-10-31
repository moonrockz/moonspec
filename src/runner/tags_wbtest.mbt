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
  assert_true(parse_error("@a and") is Some(UnexpectedEnd(expression="@a and")))
  assert_true(parse_error("not") is Some(UnexpectedEnd(..)))
  assert_true(parse_error("(") is Some(UnexpectedEnd(..)))
}

///|
test "TagExpression rejects an operator in operand position" {
  assert_true(
    parse_error("and @a")
    is Some(UnexpectedToken(token="and", expression="and @a")),
  )
  assert_true(
    parse_error("@a or or @b") is Some(UnexpectedToken(token="or", ..)),
  )
  assert_true(parse_error("()") is Some(UnexpectedToken(token=")", ..)))
}

///|
test "TagExpression rejects trailing tokens" {
  assert_true(parse_error("@a @b") is Some(UnexpectedToken(token="@b", ..)))
  assert_true(parse_error("@a)") is Some(UnexpectedToken(token=")", ..)))
}

///|
test "TagExpression rejects an unclosed parenthesis" {
  assert_true(
    parse_error("(@a or @b") is Some(UnclosedParen(expression="(@a or @b")),
  )
}

///|
test "TagExpressionError message names the expression" {
  let msg = match parse_error("@a and") {
    Some(e) => e.to_string()
    None => "parsed"
  }
  inspect(
    msg,
    content="invalid tag expression \"@a and\": expected a tag, `not` or `(` but the expression ended",
  )
}

///|
/// The error that parsing `input` raises, or `None` when `input` parses.
fn parse_error(input : String) -> TagExpressionError? {
  try TagExpression::parse(input) catch {
    e => Some(e)
  } noraise {
    _ => None
  }
}
