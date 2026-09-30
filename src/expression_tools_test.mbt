///|
test "moonspec expression factory shares typed parameter registrations" {
  let setup = @moonspec.Setup::new()
  let factory : @moonspec.ExpressionFactory = setup.expression_factory()
  let color : @moonspec.ParameterType[String] = setup.define_param_type1(
    "color",
    ["red|blue"],
    fn(s) { s },
  )
  let expression : @moonspec.StepExpression = factory.create_expression(
    "I pick {color}",
  )
  match expression.match_("I pick red") {
    Some(matched) => assert_eq(matched.get(color), "red")
    None => fail("expected a match")
  }
}

///|
test "moonspec expression generator honors the setup registry and snippet flags" {
  let setup = @moonspec.Setup::new()
  let generator : @moonspec.CucumberExpressionGenerator = setup.expression_generator()
  let color = setup.define_param_type1("color", ["red|blue"], fn(s) { s })
  ignore(
    setup.define_param_type1(
      "hidden",
      ["hidden"],
      fn(s) { s },
      use_for_snippets=false,
    ),
  )
  let candidates : Array[@moonspec.GeneratedExpression] = generator.generate_expressions(
    "I pick red and hidden",
  )
  assert_eq(candidates.map(fn(e) { e.source() }), ["I pick {color} and hidden"])
  assert_eq(candidates[0].parameter_names(), ["color"])
  let expression = setup
    .expression_factory()
    .create_expression(candidates[0].source())
  match expression.match_("I pick red and hidden") {
    Some(matched) => assert_eq(matched.get(color), "red")
    None => fail("expected generated expression to match its source text")
  }
  setup.given(candidates[0].source(), fn(_ctx) {  })
  match setup.step_registry().find_match("I pick red and hidden") {
    @moonspec.StepMatchResult::Matched(_, args) =>
      assert_eq(args[0].get(color), "red")
    _ => fail("expected the generated candidate to register as a step")
  }
}

///|
test "moonspec factory supports explicit regex matching with typed handles" {
  let setup = @moonspec.Setup::new()
  let color = setup.define_param_type1(
    "color",
    ["red|blue"],
    fn(s) { s },
    prefer_for_regexp_match=true,
  )
  for pattern in ["^(red|blue)$", "/(red|blue)/"] {
    let expression = setup.expression_factory().create_expression(pattern)
    assert_true(expression is @moonspec.StepExpression::Regular(_))
    match expression.match_("red") {
      Some(matched) => assert_eq(matched.get(color), "red")
      None => fail("expected a regex match")
    }
  }
  let cucumber = setup.expression_factory().create_expression("I pick {color}")
  assert_true(cucumber is @moonspec.StepExpression::Cucumber(_))
}

///|
test "moonspec capture decoders are usable without an upstream import" {
  let setup = @moonspec.Setup::new()
  let decoder : @moonspec.Captures1[(String, String)] = @moonspec.Captures::string()
    .zip(@moonspec.Captures::string())
    .map(fn(color, tone) { (color, tone) })
  let shade : @moonspec.ParameterType[(String, String)] = setup.define_param_type_with(
    "shade",
    ["(red|blue)-(light|dark)"],
    decoder,
  )
  setup.given("I pick {shade}", fn(_ctx) {  })
  match setup.step_registry().find_match("I pick red-dark") {
    @moonspec.StepMatchResult::Matched(_, args) =>
      assert_eq(args[0].get(shade), ("red", "dark"))
    _ => fail("expected a typed step match")
  }
}

///|
test "moonspec expression errors can be caught through the public import" {
  let setup = @moonspec.Setup::new()
  let rejected = try {
    ignore(setup.expression_factory().create_expression("I pick {unknown}"))
    false
  } catch {
    @moonspec.ExpressionError::UnknownParameterType(name~, ..) =>
      name == "unknown"
    _ => false
  }
  assert_true(rejected)
}
