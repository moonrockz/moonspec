///|
test "Setup registers given step" {
  let setup = Setup::new()
  setup.given("a calculator", fn(_ctx) {  })
  assert_eq(setup.step_registry().len(), 1)
}

///|
test "Setup registers when/then/step" {
  let setup = Setup::new()
  setup.when("I add {int}", fn(_ctx) {  })
  setup.then("the result is {int}", fn(_ctx) {  })
  setup.step("anything", fn(_ctx) {  })
  assert_eq(setup.step_registry().len(), 3)
}

///|
test "Setup registers custom param type" {
  let setup = Setup::new()
  setup.add_param_type("color", [
    @cucumber_expressions.RegexPattern("red|blue|green"),
  ])
  setup.given("I pick a {color} cucumber", fn(_ctx) {  })
  assert_eq(setup.step_registry().len(), 1)
  let entries = setup.param_registry().entries_view()
  // 11 built-in + 1 custom = 12
  assert_eq(entries.length(), 12)
}

///|
test "Setup registers before_test_case hook" {
  let setup = Setup::new()
  setup.before_test_case(fn(_info) {  })
  assert_eq(setup.hook_registry().hooks().length(), 1)
  assert_eq(setup.hook_registry().hooks()[0].type_, BeforeTestCase)
}

///|
test "Setup.add_param_type_strings with transformer" {
  let setup = Setup::new()
  setup.add_param_type_strings(
    "upper",
    ["\\w+"],
    transformer=@cucumber_expressions.Transformer::new(fn(groups) {
      @cucumber_expressions.ParamValue::CustomVal(
        @any.of(groups[0][:].to_upper().to_string()),
      )
    }),
  )
  setup.given("I say {upper}", fn(ctx) {
    match ctx[0] {
      { value: CustomVal(any), raw, .. } => {
        let v : String = any.to()
        assert_eq(v, "HELLO")
        assert_eq(raw, "hello")
      }
      _ => fail("expected CustomVal")
    }
  })
  // Verify registration succeeded
  let custom = setup.custom_param_types()
  assert_eq(custom.length(), 1)
  assert_eq(custom[0].name, "upper")
}

///|
test "Setup registers all 6 hook types" {
  let setup = Setup::new()
  setup.before_test_run(fn() {  })
  setup.after_test_run(fn() {  })
  setup.before_test_case(fn(_info) {  })
  setup.after_test_case(fn(_info, _result) {  })
  setup.before_test_step(fn(_info) {  })
  setup.after_test_step(fn(_info, _result) {  })
  assert_eq(setup.hook_registry().hooks().length(), 6)
}

///|
test "Setup hook registration captures source location" {
  let setup = Setup::new()
  setup.before_test_run(fn() {  })
  let hook = setup.hook_registry().hooks()[0]
  // Source should be populated via #callsite
  assert_true(hook.source is Some(_), msg="expected source to be populated")
}

///|
test "Setup hook by_type filters correctly" {
  let setup = Setup::new()
  setup.before_test_case(fn(_info) {  })
  setup.before_test_case(fn(_info) {  })
  setup.after_test_case(fn(_info, _result) {  })
  assert_eq(setup.hook_registry().by_type(BeforeTestCase).length(), 2)
  assert_eq(setup.hook_registry().by_type(AfterTestCase).length(), 1)
  assert_eq(setup.hook_registry().by_type(BeforeTestRun).length(), 0)
}
