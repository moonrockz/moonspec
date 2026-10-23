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
  setup.given("a payload", ctx => {
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
        docString: Some({ content: "hello world", mediaType: Some("json"), }),
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
  setup.given("the following users", ctx => {
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
            { cells: [{ value: "name", }, { value: "age", }], },
            { cells: [{ value: "Alice", }, { value: "30", }], },
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
  setup.when("I POST to {string}", ctx => {
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

///|
test "execute_scenario dry-run matches steps without executing" {
  let setup = @core.Setup::new()
  let mut executed = false
  setup.given("a defined step", fn(_ctx) { executed = true })
  let registry = setup.step_registry()
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "a defined step",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: None,
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test",
    scenario_name="Dry",
    pickle_id="p-dry-1",
    tags=[],
    steps~,
    dry_run=true,
  )
  assert_false(executed)
  assert_eq(result.steps[0].status, StepStatus::Skipped(Some("dry run")))
  assert_eq(result.status, ScenarioStatus::Skipped(Some("dry run")))
}

///|
test "execute_scenario dry-run still reports undefined steps" {
  let setup = @core.Setup::new()
  let registry = setup.step_registry()
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "a step that does not exist",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: None,
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test",
    scenario_name="Dry Undef",
    pickle_id="p-dry-2",
    tags=[],
    steps~,
    dry_run=true,
  )
  assert_eq(result.steps[0].status, StepStatus::Undefined)
  assert_eq(result.status, ScenarioStatus::Undefined)
}

///|
test "execute_scenario dry-run skips hooks" {
  let setup = @core.Setup::new()
  let mut hook_called = false
  setup.given("a defined step", fn(_ctx) {  })
  setup.before_test_case(fn(_ctx) { hook_called = true })
  let registry = setup.step_registry()
  let hook_registry = setup.hook_registry()
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "a defined step",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: None,
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test",
    scenario_name="Dry Hooks",
    pickle_id="p-dry-3",
    tags=[],
    steps~,
    hook_registry~,
    dry_run=true,
  )
  assert_false(hook_called)
  assert_eq(result.status, ScenarioStatus::Skipped(Some("dry run")))
}

///|
test "execute_scenario dry-run with mixed defined and undefined" {
  let setup = @core.Setup::new()
  setup.given("a defined step", fn(_ctx) {  })
  let registry = setup.step_registry()
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "a defined step",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: None,
    },
    {
      id: "s2",
      text: "an undefined step",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Action),
      argument: None,
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test",
    scenario_name="Dry Mixed",
    pickle_id="p-dry-4",
    tags=[],
    steps~,
    dry_run=true,
  )
  assert_eq(result.steps[0].status, StepStatus::Skipped(Some("dry run")))
  assert_eq(result.steps[1].status, StepStatus::Undefined)
  assert_eq(result.status, ScenarioStatus::Undefined)
}

///|
/// Collect each Attachment and ExternalAttachment envelope as
/// "testStepId:body" or "testStepId:url".
fn collected_attachments(sink : CollectorSink) -> Array[String] {
  let out : Array[String] = []
  for envelope in sink.envelopes {
    match envelope {
      @cucumber_messages.Envelope::Attachment(event) =>
        out.push(event.testStepId.unwrap_or("") + ":" + event.body)
      @cucumber_messages.Envelope::ExternalAttachment(event) =>
        out.push(event.testStepId.unwrap_or("") + ":" + event.url)
      _ => ()
    }
  }
  out
}

///|
/// Collect each TestStepFinished envelope as "testStepId:STATUS".
fn collected_step_statuses(sink : CollectorSink) -> Array[String] {
  let out : Array[String] = []
  for envelope in sink.envelopes {
    match envelope {
      @cucumber_messages.Envelope::TestStepFinished(event) =>
        out.push(
          event.testStepId +
          ":" +
          event.testStepResult.status.to_json().stringify(),
        )
      _ => ()
    }
  }
  out
}

///|
test "execute_scenario emits step attachments when the handler raises" {
  let setup = @core.Setup::new()
  setup.given("a step that attaches and fails", fn(ctx) raise {
    ctx.attach("text before failure", "text/plain")
    ctx.attach_bytes(b"abc", "application/octet-stream")
    ctx.attach_url("https://example.com/failure.png", "image/png")
    raise Failure::Failure("boom")
  })
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "a step that attaches and fails",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: None,
    },
  ]
  let sink = CollectorSink::new()
  let result = execute_scenario(
    setup.step_registry(),
    feature_name="Attachments",
    scenario_name="Failing step attaches",
    pickle_id="pickle-attach-fail",
    tags=[],
    steps~,
    sinks=[sink],
    test_case_started_id="tcs-1",
    test_step_ids=["ts-1"],
  )
  assert_true(result.steps[0].status is StepStatus::Failed(_))
  assert_eq(result.status, ScenarioStatus::Failed)
  assert_eq(collected_step_statuses(sink), ["ts-1:\"FAILED\""])
  assert_eq(collected_attachments(sink), [
    "ts-1:text before failure", "ts-1:YWJj", "ts-1:https://example.com/failure.png",
  ])
}

///|
test "execute_scenario emits step attachments when the step is pending" {
  let setup = @core.Setup::new()
  setup.given("a step that attaches and is pending", fn(ctx) raise {
    ctx.attach("text before pending", "text/plain")
    raise @core.pending_step_error(
      step="a step that attaches and is pending",
      keyword="Given",
      message="TODO",
    )
  })
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "a step that attaches and is pending",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: None,
    },
  ]
  let sink = CollectorSink::new()
  let result = execute_scenario(
    setup.step_registry(),
    feature_name="Attachments",
    scenario_name="Pending step attaches",
    pickle_id="pickle-attach-pending",
    tags=[],
    steps~,
    sinks=[sink],
    test_case_started_id="tcs-1",
    test_step_ids=["ts-1"],
  )
  assert_eq(result.steps[0].status, StepStatus::Pending)
  assert_eq(collected_step_statuses(sink), ["ts-1:\"PENDING\""])
  assert_eq(collected_attachments(sink), ["ts-1:text before pending"])
}

///|
test "execute_scenario emits case hook attachments when the hook raises" {
  let setup = @core.Setup::new()
  setup.before_test_case(fn(ctx) raise {
    ctx.attach("before case failure", "text/plain")
    raise Failure::Failure("before case")
  })
  setup.after_test_case(fn(ctx, _result) raise {
    ctx.attach("after case failure", "text/plain")
    raise Failure::Failure("after case")
  })
  setup.given("a step", fn(_ctx) {  })
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "a step",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: None,
    },
  ]
  let sink = CollectorSink::new()
  let result = execute_scenario(
    setup.step_registry(),
    feature_name="Attachments",
    scenario_name="Failing case hooks attach",
    pickle_id="pickle-attach-case-hooks",
    tags=[],
    steps~,
    hook_registry=setup.hook_registry(),
    sinks=[sink],
    test_case_started_id="tcs-1",
    test_step_ids=["ts-before", "ts-1", "ts-after"],
  )
  assert_eq(result.status, ScenarioStatus::Failed)
  assert_eq(collected_step_statuses(sink), [
    "ts-before:\"FAILED\"", "ts-1:\"SKIPPED\"", "ts-after:\"FAILED\"",
  ])
  assert_eq(collected_attachments(sink), [
    "ts-before:before case failure", "ts-after:after case failure",
  ])
}

///|
test "execute_scenario emits after case hook attachments when the hook raises after steps run" {
  let setup = @core.Setup::new()
  setup.after_test_case(fn(ctx, _result) raise {
    ctx.attach("after case failure", "text/plain")
    raise Failure::Failure("after case")
  })
  setup.given("a step", fn(_ctx) {  })
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "a step",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: None,
    },
  ]
  let sink = CollectorSink::new()
  let _ = execute_scenario(
    setup.step_registry(),
    feature_name="Attachments",
    scenario_name="Failing after case hook attaches",
    pickle_id="pickle-attach-after-case",
    tags=[],
    steps~,
    hook_registry=setup.hook_registry(),
    sinks=[sink],
    test_case_started_id="tcs-1",
    test_step_ids=["ts-1", "ts-after"],
  )
  assert_eq(collected_step_statuses(sink), [
    "ts-1:\"PASSED\"", "ts-after:\"FAILED\"",
  ])
  assert_eq(collected_attachments(sink), ["ts-after:after case failure"])
}
