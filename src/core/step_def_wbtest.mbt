///|
test "StepDef::given creates Given keyword" {
  let def = StepDef::given("a step", fn(_args) {  })
  assert_eq(def.keyword, StepKeyword::Given)
  assert_eq(def.pattern, "a step")
  assert_true(def.source is None)
}

///|
test "StepDef::when creates When keyword" {
  let def = StepDef::when("a step", fn(_args) {  })
  assert_eq(def.keyword, StepKeyword::When)
}

///|
test "StepDef::then creates Then keyword" {
  let def = StepDef::then("a step", fn(_args) {  })
  assert_eq(def.keyword, StepKeyword::Then)
}

///|
test "StepDef::step creates Step keyword" {
  let def = StepDef::step("a step", fn(_args) {  })
  assert_eq(def.keyword, StepKeyword::Step)
}

///|
test "StepDef with source" {
  let def = StepDef::given(
    "a step",
    fn(_args) {  },
    source=StepSource::new(uri="test.mbt", line=42),
  )
  assert_true(def.source is Some(_))
}

///|
test "StepDefId from_string/to_string round-trip" {
  let id = StepDefId::from_string("step-def-abc-123")
  assert_eq(id.to_string(), "step-def-abc-123")
}

///|
test "StepDefId equality" {
  let a = StepDefId::from_string("id-1")
  let b = StepDefId::from_string("id-1")
  let c = StepDefId::from_string("id-2")
  assert_eq(a, b)
  assert_not_eq(a, c)
}

///|
test "StepDef factory methods default id to None" {
  let def = StepDef::given("a step", fn(_args) {  })
  assert_true(def.id is None)
}
