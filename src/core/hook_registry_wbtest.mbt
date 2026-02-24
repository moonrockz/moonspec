///|
test "HookRegistry starts empty" {
  let reg = HookRegistry::new()
  assert_eq(reg.hooks().length(), 0)
}

///|
test "HookRegistry registers hook" {
  let reg = HookRegistry::new()
  reg.add(BeforeTestCase, CaseHandler(fn(_ctx) {  }))
  assert_eq(reg.hooks().length(), 1)
  assert_eq(reg.hooks()[0].type_, BeforeTestCase)
}

///|
test "HookRegistry supports multiple hooks per type" {
  let reg = HookRegistry::new()
  reg.add(BeforeTestCase, CaseHandler(fn(_ctx) {  }))
  reg.add(AfterTestCase, CaseAfterHandler(fn(_ctx, _result) {  }))
  reg.add(BeforeTestCase, CaseHandler(fn(_ctx) {  }))
  assert_eq(reg.hooks().length(), 3)
  assert_eq(reg.by_type(BeforeTestCase).length(), 2)
  assert_eq(reg.by_type(AfterTestCase).length(), 1)
}

///|
test "HookRegistry assigns unique IDs" {
  let reg = HookRegistry::new()
  reg.add(BeforeTestRun, RunHandler(fn(_ctx) {  }))
  reg.add(AfterTestRun, RunAfterHandler(fn(_ctx, _result) {  }))
  assert_eq(reg.hooks()[0].id, "hook-1")
  assert_eq(reg.hooks()[1].id, "hook-2")
}
