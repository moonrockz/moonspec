///|
test "execute_scenario with all steps passing" {
  let setup = @core.Setup::new()
  let mut count = 0
  setup.given("a passing step", fn(_args) { count = count + 1 })
  setup.when("another passing step", fn(_args) { count = count + 1 })
  setup.then("all is well", fn(_args) { count = count + 1 })
  let registry = setup.step_registry()
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "a passing step",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: None,
    },
    {
      id: "s2",
      text: "another passing step",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Action),
      argument: None,
    },
    {
      id: "s3",
      text: "all is well",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Outcome),
      argument: None,
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test Feature",
    scenario_name="All pass",
    pickle_id="test-pickle-1",
    tags=[],
    steps~,
  )
  assert_eq(result.status, ScenarioStatus::Passed)
  assert_eq(result.steps.length(), 3)
  assert_eq(count, 3)
}

///|
test "execute_scenario skips remaining steps after failure" {
  let setup = @core.Setup::new()
  setup.given("a passing step", fn(_args) {  })
  setup.when("a failing step", fn(_args) raise {
    raise Failure::Failure("boom")
  })
  setup.then("this should be skipped", fn(_args) {  })
  let registry = setup.step_registry()
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "a passing step",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: None,
    },
    {
      id: "s2",
      text: "a failing step",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Action),
      argument: None,
    },
    {
      id: "s3",
      text: "this should be skipped",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Outcome),
      argument: None,
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test Feature",
    scenario_name="Failure test",
    pickle_id="test-pickle-2",
    tags=[],
    steps~,
  )
  assert_eq(result.status, ScenarioStatus::Failed)
  assert_true(result.steps[0].status.is_passed())
  assert_eq(result.steps[2].status, StepStatus::Skipped)
}

///|
test "execute_scenario marks undefined steps" {
  let setup = @core.Setup::new()
  let registry = setup.step_registry()
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "an undefined step",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: None,
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test Feature",
    scenario_name="Undefined test",
    pickle_id="test-pickle-3",
    tags=[],
    steps~,
  )
  assert_eq(result.status, ScenarioStatus::Undefined)
  assert_eq(result.steps[0].status, StepStatus::Undefined)
}

///|
test "execute_scenario carries UndefinedStep diagnostic" {
  let setup = @core.Setup::new()
  setup.given("I have {int} cucumbers", fn(_args) {  })
  let registry = setup.step_registry()
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "an undefined step",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: None,
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test Feature",
    scenario_name="Diagnostic test",
    pickle_id="test-pickle-diag",
    tags=[],
    steps~,
  )
  assert_eq(result.steps[0].status, StepStatus::Undefined)
  assert_true(result.steps[0].diagnostic is Some(_))
}

///|
test "execute_scenario catches PendingStep" {
  let setup = @core.Setup::new()
  setup.given("a pending step", fn(_args) raise {
    raise @core.pending_step_error(
      step="a pending step",
      keyword="Given",
      message="TODO",
    )
  })
  let registry = setup.step_registry()
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "a pending step",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: None,
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test Feature",
    scenario_name="Pending test",
    pickle_id="test-pickle-pending",
    tags=[],
    steps~,
  )
  assert_eq(result.steps[0].status, StepStatus::Pending)
}
