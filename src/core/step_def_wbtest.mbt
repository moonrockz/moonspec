///|
test "StepDef::given creates Given keyword" {
  let def = StepDef::given("a step", StepHandler(fn(_args) {  }))
  assert_eq(def.keyword, StepKeyword::Given)
  assert_eq(def.pattern, "a step")
  assert_true(def.source is None)
}

///|
test "StepDef::when creates When keyword" {
  let def = StepDef::when("a step", StepHandler(fn(_args) {  }))
  assert_eq(def.keyword, StepKeyword::When)
}

///|
test "StepDef::then creates Then keyword" {
  let def = StepDef::then("a step", StepHandler(fn(_args) {  }))
  assert_eq(def.keyword, StepKeyword::Then)
}

///|
test "StepDef::step creates Step keyword" {
  let def = StepDef::step("a step", StepHandler(fn(_args) {  }))
  assert_eq(def.keyword, StepKeyword::Step)
}

///|
test "StepDef with source" {
  let def = StepDef::given(
    "a step",
    StepHandler(fn(_args) {  }),
    source=StepSource::new(uri="test.mbt", line=42),
  )
  assert_true(def.source is Some(_))
}
