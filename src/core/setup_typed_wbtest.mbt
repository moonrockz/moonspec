///|
test "Setup::given0 registers and runs zero-arg handler" {
  let setup = Setup::new()
  let called = [false]
  setup.given0("an empty cart", fn() { called[0] = true })
  let reg = setup.step_registry()
  assert_eq(reg.len(), 1)
  let ctx = Ctx::new([], { feature_name: "f", scenario_name: "s", tags: [], }, {
    keyword: "Given ",
    text: "an empty cart",
  })
  let step_def = reg.step_defs()[0]
  (step_def.handler.0)(ctx)
  assert_true(called[0])
}

///|
test "Setup::given1 extracts Int arg" {
  let setup = Setup::new()
  let captured : Array[Int32] = []
  setup.given1("I have {int} items", fn(count : Int32) { captured.push(count) })
  let ctx = Ctx::new(
    [{ value: IntVal(5), raw: "5", }],
    { feature_name: "f", scenario_name: "s", tags: [], },
    { keyword: "Given ", text: "I have 5 items", },
  )
  (setup.step_registry().step_defs()[0].handler.0)(ctx)
  assert_eq(captured[0], 5)
}

///|
test "Setup::given2 extracts String and Int args" {
  let setup = Setup::new()
  let names : Array[String] = []
  let prices : Array[Int32] = []
  setup.given2("I add {string} at {int}", fn(name : String, price : Int32) {
    names.push(name)
    prices.push(price)
  })
  let ctx = Ctx::new(
    [
      { value: StringVal("apple"), raw: "apple", },
      { value: IntVal(3), raw: "3", },
    ],
    { feature_name: "f", scenario_name: "s", tags: [], },
    { keyword: "Given ", text: "I add apple at 3", },
  )
  (setup.step_registry().step_defs()[0].handler.0)(ctx)
  assert_eq(names[0], "apple")
  assert_eq(prices[0], 3)
}

///|
test "Setup::given1_ctx passes Ctx as last arg" {
  let setup = Setup::new()
  let captured_feature : Array[String] = []
  setup.given1_ctx("I have {int} items", fn(_count : Int32, ctx : Ctx) {
    captured_feature.push(ctx.scenario().feature_name)
  })
  let ctx = Ctx::new(
    [{ value: IntVal(5), raw: "5", }],
    { feature_name: "test_feature", scenario_name: "s", tags: [], },
    { keyword: "Given ", text: "I have 5 items", },
  )
  (setup.step_registry().step_defs()[0].handler.0)(ctx)
  assert_eq(captured_feature[0], "test_feature")
}

///|
test "Setup::given1 raises on arity mismatch" {
  let setup = Setup::new()
  setup.given1("I have {int} items", fn(_count : Int32) { () })
  let ctx = Ctx::new([], { feature_name: "f", scenario_name: "s", tags: [], }, {
    keyword: "Given ",
    text: "I have items",
  })
  let result : Result[Unit, _] = Ok(
    (setup.step_registry().step_defs()[0].handler.0)(ctx),
  ) catch {
    e => Err(e)
  }
  assert_true(result is Err(_))
}

///|
test "Setup::when1 works for When keyword" {
  let setup = Setup::new()
  let captured : Array[String] = []
  setup.when1("I search for {string}", fn(query : String) {
    captured.push(query)
  })
  let ctx = Ctx::new(
    [{ value: StringVal("moonbit"), raw: "moonbit", }],
    { feature_name: "f", scenario_name: "s", tags: [], },
    { keyword: "When ", text: "I search for moonbit", },
  )
  (setup.step_registry().step_defs()[0].handler.0)(ctx)
  assert_eq(captured[0], "moonbit")
}

///|
test "Setup::then1 works for Then keyword" {
  let setup = Setup::new()
  let captured : Array[Int32] = []
  setup.then1("I should see {int} results", fn(count : Int32) {
    captured.push(count)
  })
  let ctx = Ctx::new(
    [{ value: IntVal(10), raw: "10", }],
    { feature_name: "f", scenario_name: "s", tags: [], },
    { keyword: "Then ", text: "I should see 10 results", },
  )
  (setup.step_registry().step_defs()[0].handler.0)(ctx)
  assert_eq(captured[0], 10)
}

///|
test "Setup::step0 works for Step keyword" {
  let setup = Setup::new()
  let called = [false]
  setup.step0("something happens", fn() { called[0] = true })
  let ctx = Ctx::new([], { feature_name: "f", scenario_name: "s", tags: [], }, {
    keyword: "* ",
    text: "something happens",
  })
  (setup.step_registry().step_defs()[0].handler.0)(ctx)
  assert_true(called[0])
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
    { feature_name: "f", scenario_name: "my_scenario", tags: [], },
    { keyword: "Given ", text: "an empty cart", },
  )
  (setup.step_registry().step_defs()[0].handler.0)(ctx)
  assert_eq(captured[0], "my_scenario")
}

///|
test "Setup::given3 extracts three args" {
  let setup = Setup::new()
  let result : Array[(String, Int32, String)] = []
  setup.given3("I add {string} qty {int} note {string}", fn(
    name : String,
    qty : Int32,
    note : String,
  ) {
    result.push((name, qty, note))
  })
  let ctx = Ctx::new(
    [
      { value: StringVal("apple"), raw: "apple", },
      { value: IntVal(3), raw: "3", },
      { value: StringVal("fresh"), raw: "fresh", },
    ],
    { feature_name: "f", scenario_name: "s", tags: [], },
    { keyword: "Given ", text: "I add apple qty 3 note fresh", },
  )
  (setup.step_registry().step_defs()[0].handler.0)(ctx)
  assert_eq(result[0], ("apple", 3, "fresh"))
}

///|
test "Setup::given9 extracts nine args" {
  let setup = Setup::new()
  let result : Array[Int32] = []
  setup.given9("{int} {int} {int} {int} {int} {int} {int} {int} {int}", fn(
    a : Int32,
    b : Int32,
    c : Int32,
    d : Int32,
    e : Int32,
    f : Int32,
    g : Int32,
    h : Int32,
    i : Int32,
  ) {
    result.push(a + b + c + d + e + f + g + h + i)
  })
  let args : Array[StepArg] = []
  for n = 1; n <= 9; n = n + 1 {
    args.push({ value: IntVal(n), raw: n.to_string(), })
  }
  let ctx = Ctx::new(
    args,
    { feature_name: "f", scenario_name: "s", tags: [], },
    { keyword: "Given ", text: "1 2 3 4 5 6 7 8 9", },
  )
  (setup.step_registry().step_defs()[0].handler.0)(ctx)
  assert_eq(result[0], 45)
}

///|
test "Setup::given5_ctx passes five typed args and Ctx" {
  let setup = Setup::new()
  let captured : Array[String] = []
  setup.given5_ctx("{int} {int} {int} {int} {int}", fn(
    a : Int32,
    b : Int32,
    c : Int32,
    d : Int32,
    e : Int32,
    ctx : Ctx,
  ) {
    captured.push(
      (a + b + c + d + e).to_string() + " " + ctx.scenario().feature_name,
    )
  })
  let ctx = Ctx::new(
    [
      { value: IntVal(0), raw: "0", },
      { value: IntVal(1), raw: "1", },
      { value: IntVal(2), raw: "2", },
      { value: IntVal(3), raw: "3", },
      { value: IntVal(4), raw: "4", },
    ],
    { feature_name: "f5", scenario_name: "s", tags: [], },
    { keyword: "Given ", text: "0 1 2 3 4", },
  )
  (setup.step_registry().step_defs()[0].handler.0)(ctx)
  assert_eq(captured, ["10 f5"])
}

///|
test "Setup::step22_ctx passes 22 typed args and Ctx" {
  let setup = Setup::new()
  let captured : Array[String] = []
  setup.step22_ctx(
    "{int} {int} {int} {int} {int} {int} {int} {int} {int} {int} {int} {int} {int} {int} {int} {int} {int} {int} {int} {int} {int} {int}",
    fn(
      x0 : Int32,
      x1 : Int32,
      x2 : Int32,
      x3 : Int32,
      x4 : Int32,
      x5 : Int32,
      x6 : Int32,
      x7 : Int32,
      x8 : Int32,
      x9 : Int32,
      x10 : Int32,
      x11 : Int32,
      x12 : Int32,
      x13 : Int32,
      x14 : Int32,
      x15 : Int32,
      x16 : Int32,
      x17 : Int32,
      x18 : Int32,
      x19 : Int32,
      x20 : Int32,
      x21 : Int32,
      ctx : Ctx,
    ) {
      captured.push(
        (x0 +
        x1 +
        x2 +
        x3 +
        x4 +
        x5 +
        x6 +
        x7 +
        x8 +
        x9 +
        x10 +
        x11 +
        x12 +
        x13 +
        x14 +
        x15 +
        x16 +
        x17 +
        x18 +
        x19 +
        x20 +
        x21).to_string() +
        " " +
        ctx.step().text,
      )
    },
  )
  let ctx = Ctx::new(
    [
      { value: IntVal(0), raw: "0", },
      { value: IntVal(1), raw: "1", },
      { value: IntVal(2), raw: "2", },
      { value: IntVal(3), raw: "3", },
      { value: IntVal(4), raw: "4", },
      { value: IntVal(5), raw: "5", },
      { value: IntVal(6), raw: "6", },
      { value: IntVal(7), raw: "7", },
      { value: IntVal(8), raw: "8", },
      { value: IntVal(9), raw: "9", },
      { value: IntVal(10), raw: "10", },
      { value: IntVal(11), raw: "11", },
      { value: IntVal(12), raw: "12", },
      { value: IntVal(13), raw: "13", },
      { value: IntVal(14), raw: "14", },
      { value: IntVal(15), raw: "15", },
      { value: IntVal(16), raw: "16", },
      { value: IntVal(17), raw: "17", },
      { value: IntVal(18), raw: "18", },
      { value: IntVal(19), raw: "19", },
      { value: IntVal(20), raw: "20", },
      { value: IntVal(21), raw: "21", },
    ],
    { feature_name: "f", scenario_name: "s", tags: [], },
    { keyword: "* ", text: "twenty-two", },
  )
  (setup.step_registry().step_defs()[0].handler.0)(ctx)
  assert_eq(captured, ["231 twenty-two"])
}

///|
test "Setup::when5_ctx checks the arity" {
  let setup = Setup::new()
  setup.when5_ctx("{int} {int} {int} {int} {int}", fn(
    _a : Int32,
    _b : Int32,
    _c : Int32,
    _d : Int32,
    _e : Int32,
    _ctx : Ctx,
  ) {
    ()
  })
  let ctx = Ctx::new(
    [
      { value: IntVal(0), raw: "0", },
      { value: IntVal(1), raw: "1", },
      { value: IntVal(2), raw: "2", },
      { value: IntVal(3), raw: "3", },
    ],
    { feature_name: "f", scenario_name: "s", tags: [], },
    { keyword: "When ", text: "0 1 2 3", },
  )
  let failed = try (setup.step_registry().step_defs()[0].handler.0)(ctx) catch {
    _ => true
  } noraise {
    _ => false
  }
  assert_true(failed)
}
