///|
struct Shade {
  color : String
  tone : String
} derive(Eq, Debug)

///|
test "typed parameter handles preserve domain values and raw text" {
  let setup = Setup::new()
  let shade = setup.define_param_type_with(
    "shade",
    ["(red|blue)-(light|dark)"],
    @cucumber_expressions.Captures::string()
    .zip(@cucumber_expressions.Captures::string())
    .map(fn(color, tone) { Shade::{ color, tone, } }),
  )
  setup.given("I pick {shade} and {int}", fn(_ctx) {  })
  match setup.step_registry().find_match("I pick red-dark and 42") {
    Matched(_, args) => {
      assert_true(args[0].value is TypedVal(_))
      assert_eq(args[0].get(shade), Shade::{ color: "red", tone: "dark", })
      assert_eq(args[0].get(shade), Shade::{ color: "red", tone: "dark", })
      assert_eq(args[0].raw, "red-dark")
      assert_eq(args[1].value, IntVal(42))
      assert_eq(args[0].value.to_string(), "TypedVal(<shade>)")
      assert_eq(args[0].value, args[0].value)
      match setup.step_registry().find_match("I pick red-dark and 42") {
        Matched(_, next) => assert_true(args[0].value != next[0].value)
        _ => fail("expected another match")
      }
    }
    _ => fail("expected Matched")
  }
}

///|
test "typed handles reject different handles even with the same name" {
  let setup = Setup::new()
  let color = setup.define_param_type1("color", ["red|blue"], fn(s) { s })
  let other_setup = Setup::new()
  let other = other_setup.define_param_type1("color", ["red|blue"], fn(_s) {
    42
  })
  setup.given("I pick {color}", fn(_ctx) {  })
  match setup.step_registry().find_match("I pick red") {
    Matched(_, args) => {
      assert_eq(args[0].get(color), "red")
      let rejected = try {
        ignore(args[0].get(other))
        false
      } catch {
        @cucumber_expressions.ParameterTypeError::WrongParameterType(..) => true
        _ => false
      }
      assert_true(rejected)
      assert_eq(args[0].get(color), "red")
    }
    _ => fail("expected Matched")
  }
}

///|
test "typed handles reject builtin values" {
  let setup = Setup::new()
  let color = setup.define_param_type1("color", ["red|blue"], fn(s) { s })
  let arg : StepArg = { value: StringVal("red"), raw: "red", }
  let rejected = try {
    ignore(arg.get(color))
    false
  } catch {
    Failure(message) =>
      message == "expected typed parameter 'color', got StringVal(red)"
    _ => false
  }
  assert_true(rejected)
}

///|
test "typed registration propagates duplicate and capture arity errors" {
  let setup = Setup::new()
  ignore(setup.define_param_type1("color", ["red|blue"], fn(s) { s }))
  let duplicate = try {
    ignore(setup.define_param_type1("color", ["green"], fn(s) { s }))
    false
  } catch {
    @cucumber_expressions.ParameterTypeError::DuplicateParameterType(..) => true
    _ => false
  }
  assert_true(duplicate)
  let arity = try {
    ignore(
      setup.define_param_type1("shade", ["(red|blue)-(light|dark)"], fn(s) { s }),
    )
    false
  } catch {
    @cucumber_expressions.ParameterTypeError::ArityMismatch(..) => true
    _ => false
  }
  assert_true(arity)
  assert_eq(setup.custom_param_types().length(), 1)
}

///|
test "typed decoder errors propagate from step matching" {
  let setup = Setup::new()
  let _color : @cucumber_expressions.ParameterType[String] = setup.define_param_type1(
    "color",
    ["red|blue"],
    fn(_s) raise { raise Failure("unsupported color") },
  )
  setup.given("I pick {color}", fn(_ctx) {  })
  let rejected = try {
    ignore(setup.step_registry().find_match("I pick red"))
    false
  } catch {
    Failure(message) => message == "unsupported color"
    _ => false
  }
  assert_true(rejected)
}

///|
test "typed optional captures preserve missing values" {
  let setup = Setup::new()
  let tone = setup.define_param_type_with(
    "tone",
    ["red(?:-(light|dark))?"],
    @cucumber_expressions.Captures::optional(
      @cucumber_expressions.Captures::string(),
    ),
  )
  setup.given("I pick {tone}", fn(_ctx) {  })
  for (text, expected) in [("red", None), ("red-dark", Some("dark"))] {
    match setup.step_registry().find_match("I pick \{text}") {
      Matched(_, args) => {
        assert_eq(args[0].get(tone), expected)
        assert_eq(args[0].raw, text)
      }
      _ => fail("expected Matched")
    }
  }
}
