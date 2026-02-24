///|
test "Setup registers given step" {
  let setup = Setup::new()
  setup.given("a calculator", fn(_args) {  })
  assert_eq(setup.step_registry().len(), 1)
}

///|
test "Setup registers when/then/step" {
  let setup = Setup::new()
  setup.when("I add {int}", fn(_args) {  })
  setup.then("the result is {int}", fn(_args) {  })
  setup.step("anything", fn(_args) {  })
  assert_eq(setup.step_registry().len(), 3)
}

///|
test "Setup registers custom param type" {
  let setup = Setup::new()
  setup.add_param_type("color", [
    @cucumber_expressions.RegexPattern("red|blue|green"),
  ])
  setup.given("I pick a {color} cucumber", fn(_args) {  })
  assert_eq(setup.step_registry().len(), 1)
  let entries = setup.param_registry().entries_view()
  // 5 built-in + 1 custom = 6
  assert_eq(entries.length(), 6)
}
