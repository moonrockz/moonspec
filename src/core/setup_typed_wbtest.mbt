///|
test "Setup::given0 registers and runs zero-arg handler" {
  let setup = Setup::new()
  let called = [false]
  setup.given0("an empty cart", fn() { called[0] = true })
  let reg = setup.step_registry()
  assert_eq!(reg.len(), 1)
  let ctx = Ctx::new(
    [],
    { feature_name: "f", scenario_name: "s", tags: [] },
    { keyword: "Given ", text: "an empty cart" },
  )
  let step_def = reg.step_defs()[0]
  (step_def.handler.0)(ctx)
  assert_true!(called[0])
}

///|
test "Setup::given1 extracts Int arg" {
  let setup = Setup::new()
  let captured : Array[Int] = []
  setup.given1("I have {int} items", fn(count : Int) { captured.push(count) })
  let ctx = Ctx::new(
    [{ value: IntVal(5), raw: "5" }],
    { feature_name: "f", scenario_name: "s", tags: [] },
    { keyword: "Given ", text: "I have 5 items" },
  )
  (setup.step_registry().step_defs()[0].handler.0)(ctx)
  assert_eq!(captured[0], 5)
}

///|
test "Setup::given2 extracts String and Int args" {
  let setup = Setup::new()
  let names : Array[String] = []
  let prices : Array[Int] = []
  setup.given2("I add {string} at {int}", fn(name : String, price : Int) {
    names.push(name)
    prices.push(price)
  })
  let ctx = Ctx::new(
    [{ value: StringVal("apple"), raw: "apple" }, { value: IntVal(3), raw: "3" }],
    { feature_name: "f", scenario_name: "s", tags: [] },
    { keyword: "Given ", text: "I add apple at 3" },
  )
  (setup.step_registry().step_defs()[0].handler.0)(ctx)
  assert_eq!(names[0], "apple")
  assert_eq!(prices[0], 3)
}

///|
test "Setup::given1_ctx passes Ctx as last arg" {
  let setup = Setup::new()
  let captured_feature : Array[String] = []
  setup.given1_ctx("I have {int} items", fn(_count : Int, ctx : Ctx) {
    captured_feature.push(ctx.scenario().feature_name)
  })
  let ctx = Ctx::new(
    [{ value: IntVal(5), raw: "5" }],
    { feature_name: "test_feature", scenario_name: "s", tags: [] },
    { keyword: "Given ", text: "I have 5 items" },
  )
  (setup.step_registry().step_defs()[0].handler.0)(ctx)
  assert_eq!(captured_feature[0], "test_feature")
}

///|
test "Setup::given1 raises on arity mismatch" {
  let setup = Setup::new()
  setup.given1("I have {int} items", fn(_count : Int) { () })
  let ctx = Ctx::new(
    [],
    { feature_name: "f", scenario_name: "s", tags: [] },
    { keyword: "Given ", text: "I have items" },
  )
  let result : Result[Unit, _] = try {
    Ok((setup.step_registry().step_defs()[0].handler.0)(ctx))
  } catch {
    e => Err(e)
  }
  assert_true!(result.is_err())
}

///|
test "Setup::when1 works for When keyword" {
  let setup = Setup::new()
  let captured : Array[String] = []
  setup.when1("I search for {string}", fn(query : String) { captured.push(query) })
  let ctx = Ctx::new(
    [{ value: StringVal("moonbit"), raw: "moonbit" }],
    { feature_name: "f", scenario_name: "s", tags: [] },
    { keyword: "When ", text: "I search for moonbit" },
  )
  (setup.step_registry().step_defs()[0].handler.0)(ctx)
  assert_eq!(captured[0], "moonbit")
}

///|
test "Setup::then1 works for Then keyword" {
  let setup = Setup::new()
  let captured : Array[Int] = []
  setup.then1("I should see {int} results", fn(count : Int) { captured.push(count) })
  let ctx = Ctx::new(
    [{ value: IntVal(10), raw: "10" }],
    { feature_name: "f", scenario_name: "s", tags: [] },
    { keyword: "Then ", text: "I should see 10 results" },
  )
  (setup.step_registry().step_defs()[0].handler.0)(ctx)
  assert_eq!(captured[0], 10)
}

///|
test "Setup::step0 works for Step keyword" {
  let setup = Setup::new()
  let called = [false]
  setup.step0("something happens", fn() { called[0] = true })
  let ctx = Ctx::new(
    [],
    { feature_name: "f", scenario_name: "s", tags: [] },
    { keyword: "* ", text: "something happens" },
  )
  (setup.step_registry().step_defs()[0].handler.0)(ctx)
  assert_true!(called[0])
}

///|
test "Setup::given0_ctx passes Ctx with zero args" {
  let setup = Setup::new()
  let captured : Array[String] = []
  setup.given0_ctx("an empty cart", fn(ctx : Ctx) {
    captured.push(ctx.scenario().scenario_name)
  })
  let ctx = Ctx::new(
    [],
    { feature_name: "f", scenario_name: "my_scenario", tags: [] },
    { keyword: "Given ", text: "an empty cart" },
  )
  (setup.step_registry().step_defs()[0].handler.0)(ctx)
  assert_eq!(captured[0], "my_scenario")
}

///|
test "Setup::given3 extracts three args" {
  let setup = Setup::new()
  let result : Array[(String, Int, String)] = []
  setup.given3(
    "I add {string} qty {int} note {string}",
    fn(name : String, qty : Int, note : String) { result.push((name, qty, note)) },
  )
  let ctx = Ctx::new(
    [
      { value: StringVal("apple"), raw: "apple" },
      { value: IntVal(3), raw: "3" },
      { value: StringVal("fresh"), raw: "fresh" },
    ],
    { feature_name: "f", scenario_name: "s", tags: [] },
    { keyword: "Given ", text: "I add apple qty 3 note fresh" },
  )
  (setup.step_registry().step_defs()[0].handler.0)(ctx)
  assert_eq!(result[0], ("apple", 3, "fresh"))
}
