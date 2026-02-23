///|
test "StepRegistry starts empty" {
  let reg = StepRegistry::new()
  assert_eq(reg.len(), 0)
}

///|
test "StepRegistry registers a Given step" {
  let reg = StepRegistry::new()
  reg.given("I have {int} cucumbers", fn(_args) {  })
  assert_eq(reg.len(), 1)
}

///|
test "StepRegistry matches step text" {
  let reg = StepRegistry::new()
  reg.given("I have {int} cucumbers", fn(_args) {  })
  let result = reg.find_match("I have 42 cucumbers")
  assert_true(result is Matched(_, _))
}

///|
test "StepRegistry returns Undefined for no match" {
  let reg = StepRegistry::new()
  reg.given("I have {int} cucumbers", fn(_args) {  })
  let result = reg.find_match("I have many cucumbers")
  assert_true(result is Undefined(_))
}

///|
test "StepRegistry extracts parameters" {
  let reg = StepRegistry::new()
  reg.given("I have {int} cucumbers", fn(_args) {  })
  match reg.find_match("I have 42 cucumbers") {
    Matched(_, args) => assert_eq(args[0], StepArg::IntArg(42))
    _ => fail("expected Matched")
  }
}

///|
test "StepRegistry when and then register correctly" {
  let reg = StepRegistry::new()
  reg.when("I eat {int}", fn(_args) {  })
  reg.then("I should have {int}", fn(_args) {  })
  assert_eq(reg.len(), 2)
}

///|
test "StepRegistry step registers with any keyword" {
  let reg = StepRegistry::new()
  reg.step("something happens", fn(_args) {  })
  assert_eq(reg.len(), 1)
  assert_true(reg.find_match("something happens") is Matched(_, _))
}

///|
test "StepRegistry find_match returns Matched with StepDef" {
  let reg = StepRegistry::new()
  reg.given("I have {int} cucumbers", fn(_args) {  })
  match reg.find_match("I have 42 cucumbers") {
    Matched(step_def, args) => {
      assert_eq(step_def.keyword, StepKeyword::Given)
      assert_eq(args[0], StepArg::IntArg(42))
    }
    _ => fail("expected Matched")
  }
}

///|
test "StepRegistry find_match returns Undefined with snippet" {
  let reg = StepRegistry::new()
  reg.given("I have {int} cucumbers", fn(_args) {  })
  match reg.find_match("I have many bananas") {
    Undefined(step_text~, snippet~, ..) => {
      assert_eq(step_text, "I have many bananas")
      assert_true(contains(snippet, "s.step"))
    }
    _ => fail("expected Undefined")
  }
}

///|
test "StepRegistry use_library registers library steps" {
  let reg = StepRegistry::new()
  let world : TestWorld = { value: 0 }
  let lib = MathSteps::new(world)
  reg.use_library(lib)
  assert_true(reg.find_match("a value of 5") is Matched(_, _))
}

///|
test "StepRegistry register_def registers a StepDef directly" {
  let reg = StepRegistry::new()
  let def = StepDef::given("hello world", fn(_args) {  })
  reg.register_def(def)
  assert_eq(reg.len(), 1)
  assert_true(reg.find_match("hello world") is Matched(_, _))
}

///|
test "register_def assigns a StepDefId" {
  let reg = StepRegistry::new()
  let def = StepDef::given("I have {int} cucumbers", fn(_args) {  })
  assert_true(def.id is None)
  reg.register_def(def)
  assert_true(def.id is Some(_))
}

///|
test "step_defs returns all registered definitions" {
  let reg = StepRegistry::new()
  reg.given("step one", fn(_args) {  })
  reg.when("step two", fn(_args) {  })
  reg.then("step three", fn(_args) {  })
  let defs = reg.step_defs()
  assert_eq(defs.length(), 3)
  assert_eq(defs[0].keyword, StepKeyword::Given)
  assert_eq(defs[1].keyword, StepKeyword::When)
  assert_eq(defs[2].keyword, StepKeyword::Then)
}

///|
test "StepDefIds are unique across registrations" {
  let reg = StepRegistry::new()
  reg.given("first step", fn(_args) {  })
  reg.when("second step", fn(_args) {  })
  reg.then("third step", fn(_args) {  })
  let defs = reg.step_defs()
  let ids = defs.map(fn(d) { d.id })
  // All ids should be Some and distinct
  assert_true(ids[0] != ids[1])
  assert_true(ids[1] != ids[2])
  assert_true(ids[0] != ids[2])
}
