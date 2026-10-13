///|
test "StepDef::given0 creates zero-arg step def" {
  let called = [false]
  let sd = StepDef::given0("an empty cart", fn() { called[0] = true })
  assert_eq(sd.keyword, StepKeyword::Given)
  assert_eq(sd.pattern, "an empty cart")
  let ctx = Ctx::new([], { feature_name: "f", scenario_name: "s", tags: [], }, {
    keyword: "Given ",
    text: "an empty cart",
  })
  (sd.handler.0)(ctx)
  assert_true(called[0])
}

///|
test "StepDef::given1 creates one-arg step def" {
  let captured : Array[Int32] = []
  let sd = StepDef::given1("I have {int} items", fn(count : Int32) {
    captured.push(count)
  })
  assert_eq(sd.keyword, StepKeyword::Given)
  let ctx = Ctx::new(
    [{ value: IntVal(7), raw: "7", }],
    { feature_name: "f", scenario_name: "s", tags: [], },
    { keyword: "Given ", text: "I have 7 items", },
  )
  (sd.handler.0)(ctx)
  assert_eq(captured[0], 7)
}

///|
test "StepDef::given2 creates two-arg step def" {
  let captured : Array[(String, Int32)] = []
  let sd = StepDef::given2("I add {string} at {int}", fn(
    name : String,
    price : Int32,
  ) {
    captured.push((name, price))
  })
  let ctx = Ctx::new(
    [
      { value: StringVal("apple"), raw: "apple", },
      { value: IntVal(5), raw: "5", },
    ],
    { feature_name: "f", scenario_name: "s", tags: [], },
    { keyword: "Given ", text: "I add apple at 5", },
  )
  (sd.handler.0)(ctx)
  assert_eq(captured[0], ("apple", 5))
}

///|
test "StepDef::when1 creates When step def" {
  let sd = StepDef::when1("I press {string}", fn(_s : String) { () })
  assert_eq(sd.keyword, StepKeyword::When)
}

///|
test "StepDef::then1 creates Then step def" {
  let sd = StepDef::then1("I see {int}", fn(_n : Int32) { () })
  assert_eq(sd.keyword, StepKeyword::Then)
}

///|
test "StepDef::step1 creates Step step def" {
  let sd = StepDef::step1("there are {int}", fn(_n : Int32) { () })
  assert_eq(sd.keyword, StepKeyword::Step)
}

///|
test "StepDef::given1_ctx passes Ctx" {
  let captured : Array[String] = []
  let sd = StepDef::given1_ctx("I have {int}", fn(_n : Int32, ctx : Ctx) {
    captured.push(ctx.scenario().feature_name)
  })
  let ctx = Ctx::new(
    [{ value: IntVal(1), raw: "1", }],
    { feature_name: "test_feat", scenario_name: "s", tags: [], },
    { keyword: "Given ", text: "I have 1", },
  )
  (sd.handler.0)(ctx)
  assert_eq(captured[0], "test_feat")
}

///|
test "StepDef::given1 with source" {
  let sd = StepDef::given1(
    "I have {int}",
    fn(_n : Int32) { () },
    source=StepSource::new(uri="test.mbt", line=42),
  )
  assert_true(sd.source is Some(_))
}

///|
test "StepDef::given9 creates nine-arg step def" {
  let result : Array[Int32] = []
  let sd = StepDef::given9(
    "{int} {int} {int} {int} {int} {int} {int} {int} {int}",
    fn(
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
    },
  )
  let args : Array[StepArg] = []
  for n = 1; n <= 9; n = n + 1 {
    args.push({ value: IntVal(n), raw: n.to_string(), })
  }
  let ctx = Ctx::new(
    args,
    { feature_name: "f", scenario_name: "s", tags: [], },
    { keyword: "Given ", text: "1 2 3 4 5 6 7 8 9", },
  )
  (sd.handler.0)(ctx)
  assert_eq(result[0], 45)
}
