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
  assert_true(result is Some(_))
}

///|
test "StepRegistry returns None for no match" {
  let reg = StepRegistry::new()
  reg.given("I have {int} cucumbers", fn(_args) {  })
  let result = reg.find_match("I have many cucumbers")
  assert_true(result is None)
}

///|
test "StepRegistry extracts parameters" {
  let reg = StepRegistry::new()
  reg.given("I have {int} cucumbers", fn(_args) {  })
  let (_, args, _) = reg.find_match("I have 42 cucumbers").unwrap()
  assert_eq(args[0], StepArg::IntArg(42))
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
  assert_true(reg.find_match("something happens") is Some(_))
}
