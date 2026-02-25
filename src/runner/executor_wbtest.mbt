///|
test "execute_scenario with all steps passing" {
  let setup = @core.Setup::new()
  let mut count = 0
  setup.given("a passing step", fn(_ctx) { count = count + 1 })
  setup.when("another passing step", fn(_ctx) { count = count + 1 })
  setup.then("all is well", fn(_ctx) { count = count + 1 })
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
  setup.given("a passing step", fn(_ctx) {  })
  setup.when("a failing step", fn(_ctx) raise { raise Failure::Failure("boom") })
  setup.then("this should be skipped", fn(_ctx) {  })
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
  assert_eq(result.steps[2].status, StepStatus::Skipped(None))
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
  setup.given("I have {int} cucumbers", fn(_ctx) {  })
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
  setup.given("a pending step", fn(_ctx) raise {
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

///|
test "execute_scenario passes doc string as last arg" {
  let setup = @core.Setup::new()
  let mut received_content = ""
  let mut received_media_type : String? = None
  setup.given("a payload", fn(ctx) {
    match ctx[0] {
      { value: @core.StepValue::DocStringVal(doc), .. } => {
        received_content = doc.content
        received_media_type = doc.media_type
      }
      _ => ()
    }
  })
  let registry = setup.step_registry()
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "a payload",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: Some({
        docString: Some({ content: "hello world", mediaType: Some("json") }),
        dataTable: None,
      }),
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test",
    scenario_name="DocString",
    pickle_id="p1",
    tags=[],
    steps~,
  )
  assert_eq(result.status, ScenarioStatus::Passed)
  assert_eq(received_content, "hello world")
  assert_eq(received_media_type, Some("json"))
}

///|
test "execute_scenario passes data table as last arg" {
  let setup = @core.Setup::new()
  let mut received_rows = 0
  let mut first_name = ""
  setup.given("the following users", fn(ctx) {
    match ctx[0] {
      { value: @core.StepValue::DataTableVal(table), .. } => {
        received_rows = table.row_count()
        first_name = table.rows.get(1).cells.get(0)
      }
      _ => ()
    }
  })
  let registry = setup.step_registry()
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "the following users",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: Some({
        docString: None,
        dataTable: Some({
          rows: [
            { cells: [{ value: "name" }, { value: "age" }] },
            { cells: [{ value: "Alice" }, { value: "30" }] },
          ],
        }),
      }),
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test",
    scenario_name="DataTable",
    pickle_id="p1",
    tags=[],
    steps~,
  )
  assert_eq(result.status, ScenarioStatus::Passed)
  assert_eq(received_rows, 2)
  assert_eq(first_name, "Alice")
}

///|
test "execute_scenario appends doc string after text params" {
  let setup = @core.Setup::new()
  let mut url = ""
  let mut body = ""
  setup.when("I POST to {string}", fn(ctx) {
    match ctx[0] {
      { value: @core.StepValue::StringVal(u), .. } => url = u
      _ => ()
    }
    match ctx[1] {
      { value: @core.StepValue::DocStringVal(doc), .. } => body = doc.content
      _ => ()
    }
  })
  let registry = setup.step_registry()
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "I POST to \"http://example.com\"",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Action),
      argument: Some({
        docString: Some({
          content: "{\"name\":\"Alice\"}",
          mediaType: Some("json"),
        }),
        dataTable: None,
      }),
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test",
    scenario_name="Mixed",
    pickle_id="p1",
    tags=[],
    steps~,
  )
  assert_eq(result.status, ScenarioStatus::Passed)
  assert_eq(url, "http://example.com")
  assert_eq(body, "{\"name\":\"Alice\"}")
}
