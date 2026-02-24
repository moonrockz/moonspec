///|
test "StepRegistry starts empty" {
  let reg = StepRegistry::new()
  assert_eq(reg.len(), 0)
}

///|
test "StepRegistry registers a Given step via Setup" {
  let setup = Setup::new()
  setup.given("I have {int} cucumbers", fn(_ctx) {  })
  assert_eq(setup.step_registry().len(), 1)
}

///|
test "StepRegistry matches step text" {
  let setup = Setup::new()
  setup.given("I have {int} cucumbers", fn(_ctx) {  })
  let result = setup.step_registry().find_match("I have 42 cucumbers")
  assert_true(result is Matched(_, _))
}

///|
test "StepRegistry returns Undefined for no match" {
  let setup = Setup::new()
  setup.given("I have {int} cucumbers", fn(_ctx) {  })
  let result = setup.step_registry().find_match("I have many cucumbers")
  assert_true(result is Undefined(_))
}

///|
test "StepRegistry extracts parameters" {
  let setup = Setup::new()
  setup.given("I have {int} cucumbers", fn(_ctx) {  })
  match setup.step_registry().find_match("I have 42 cucumbers") {
    Matched(_, args) =>
      match args[0] {
        { value: IntVal(n), .. } => assert_eq(n, 42)
        _ => fail("expected IntVal")
      }
    _ => fail("expected Matched")
  }
}

///|
test "StepRegistry when and then register correctly" {
  let setup = Setup::new()
  setup.when("I eat {int}", fn(_ctx) {  })
  setup.then("I should have {int}", fn(_ctx) {  })
  assert_eq(setup.step_registry().len(), 2)
}

///|
test "StepRegistry step registers with any keyword" {
  let setup = Setup::new()
  setup.step("something happens", fn(_ctx) {  })
  assert_eq(setup.step_registry().len(), 1)
  assert_true(
    setup.step_registry().find_match("something happens") is Matched(_, _),
  )
}

///|
test "StepRegistry find_match returns Matched with StepDef" {
  let setup = Setup::new()
  setup.given("I have {int} cucumbers", fn(_ctx) {  })
  match setup.step_registry().find_match("I have 42 cucumbers") {
    Matched(step_def, args) => {
      assert_eq(step_def.keyword, StepKeyword::Given)
      match args[0] {
        { value: IntVal(n), .. } => assert_eq(n, 42)
        _ => fail("expected IntVal")
      }
    }
    _ => fail("expected Matched")
  }
}

///|
test "StepRegistry find_match returns Undefined with snippet" {
  let setup = Setup::new()
  setup.given("I have {int} cucumbers", fn(_ctx) {  })
  match setup.step_registry().find_match("I have many bananas") {
    Undefined(step_text~, snippet~, ..) => {
      assert_eq(step_text, "I have many bananas")
      assert_true(contains(snippet, "s.step"))
    }
    _ => fail("expected Undefined")
  }
}

///|
test "StepRegistry use_library registers library steps" {
  let setup = Setup::new()
  let world : TestWorld = { value: 0 }
  let lib = MathSteps::new(world)
  setup.use_library(lib)
  assert_true(setup.step_registry().find_match("a value of 5") is Matched(_, _))
}

///|
test "StepRegistry register_def registers a StepDef directly" {
  let reg = StepRegistry::new()
  let param_reg = @cucumber_expressions.ParamTypeRegistry::default()
  let def = StepDef::given("hello world", fn(_ctx) {  })
  reg.register_def(def, param_reg)
  assert_eq(reg.len(), 1)
  assert_true(reg.find_match("hello world") is Matched(_, _))
}

///|
test "register_def assigns a StepDefId" {
  let reg = StepRegistry::new()
  let param_reg = @cucumber_expressions.ParamTypeRegistry::default()
  let def = StepDef::given("I have {int} cucumbers", fn(_ctx) {  })
  assert_true(def.id is None)
  reg.register_def(def, param_reg)
  assert_true(def.id is Some(_))
}

///|
test "step_defs returns all registered definitions" {
  let setup = Setup::new()
  setup.given("step one", fn(_ctx) {  })
  setup.when("step two", fn(_ctx) {  })
  setup.then("step three", fn(_ctx) {  })
  let defs = setup.step_registry().step_defs()
  assert_eq(defs.length(), 3)
  assert_eq(defs[0].keyword, StepKeyword::Given)
  assert_eq(defs[1].keyword, StepKeyword::When)
  assert_eq(defs[2].keyword, StepKeyword::Then)
}

///|
test "StepDefIds are unique across registrations" {
  let setup = Setup::new()
  setup.given("first step", fn(_ctx) {  })
  setup.when("second step", fn(_ctx) {  })
  setup.then("third step", fn(_ctx) {  })
  let defs = setup.step_registry().step_defs()
  let ids = defs.map(fn(d) { d.id })
  // All ids should be Some and distinct
  assert_true(ids[0] != ids[1])
  assert_true(ids[1] != ids[2])
  assert_true(ids[0] != ids[2])
}
