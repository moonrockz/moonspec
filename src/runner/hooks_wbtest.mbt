///|
/// Tests for World isolation (fresh per scenario) and hook lifecycle.

///|
struct IsolationWorld {
  mut counter : Int
} derive(Default)

///|
impl @core.World for IsolationWorld with configure(self, setup) {
  setup.given("I set counter to {int}", fn(ctx) {
    match ctx[0] {
      { value: @core.StepValue::IntVal(n), .. } => self.counter = n
      _ => ()
    }
  })
  setup.then("counter should be {int}", fn(ctx) raise {
    match ctx[0] {
      { value: @core.StepValue::IntVal(expected), .. } =>
        assert_eq(self.counter, expected)
      _ => ()
    }
  })
}

///|
async test "isolation: each scenario gets a fresh world" {
  // Scenario 1 sets counter to 42, scenario 2 expects default (0).
  // If isolation is broken, scenario 2 would see 42.
  let content = "Feature: Isolation\n\n  Scenario: Set counter\n    Given I set counter to 42\n    Then counter should be 42\n\n  Scenario: Fresh world\n    Then counter should be 0\n"
  let result = run(
    IsolationWorld::default,
    RunOptions([FeatureSource::Text("test://isolation", content)]),
  )
  assert_eq(result.summary.total_scenarios, 2)
  assert_eq(result.summary.passed, 2)
  assert_eq(result.summary.failed, 0)
}

///|
async test "isolation: parallel execution with fresh worlds" {
  let feature1 = "Feature: F1\n\n  Scenario: Set counter\n    Given I set counter to 99\n    Then counter should be 99\n"
  let feature2 = "Feature: F2\n\n  Scenario: Fresh world\n    Then counter should be 0\n"
  let opts = RunOptions([
    FeatureSource::Text("test://iso-f1", feature1),
    FeatureSource::Text("test://iso-f2", feature2),
  ])
  opts.parallel(true)
  opts.max_concurrent(2)
  let result = run(IsolationWorld::default, opts)
  assert_eq(result.summary.total_scenarios, 2)
  assert_eq(result.summary.passed, 2)
}

///|
struct HookWorld {
  log : Array[String]
} derive(Default)

///|
impl @core.World for HookWorld with configure(self, setup) {
  setup.given("a step", fn(_ctx) { () })
  setup.then("it passes", fn(_ctx) { () })
  setup.before_test_case(fn(ctx) {
    self.log.push("before_scenario:" + ctx.scenario().scenario_name)
  })
  setup.after_test_case(fn(ctx, result) {
    let status = match result {
      @core.HookResult::Passed => "ok"
      @core.HookResult::Failed(errors) =>
        match errors[0] {
          @core.HookError::StepFailed(message~, ..) => message
          @core.HookError::ScenarioFailed(message~, ..) => message
        }
    }
    self.log.push(
      "after_scenario:" + ctx.scenario().scenario_name + ":" + status,
    )
  })
  setup.before_test_step(fn(ctx) {
    self.log.push("before_step:" + ctx.step().text)
  })
  setup.after_test_step(fn(ctx, result) {
    let status = match result {
      @core.HookResult::Passed => "ok"
      @core.HookResult::Failed(errors) =>
        match errors[0] {
          @core.HookError::StepFailed(message~, ..) => message
          @core.HookError::ScenarioFailed(message~, ..) => message
        }
    }
    self.log.push("after_step:" + ctx.step().text + ":" + status)
  })
}

///|
test "hooks: correct ordering of lifecycle calls" {
  let world = HookWorld::default()
  let setup = @core.Setup::new()
  @core.World::configure(world, setup)
  let registry = setup.step_registry()
  let hook_registry = setup.hook_registry()
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "a step",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: None,
    },
    {
      id: "s2",
      text: "it passes",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Outcome),
      argument: None,
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="Hooks",
    scenario_name="One",
    pickle_id="test-pickle-1",
    tags=[],
    steps~,
    hook_registry~,
  )
  assert_eq(result.status, ScenarioStatus::Passed)
  assert_eq(world.log, [
    "before_scenario:One", "before_step:a step", "after_step:a step:ok", "before_step:it passes",
    "after_step:it passes:ok", "after_scenario:One:ok",
  ])
}

///|
struct FailHookWorld {
  log : Array[String]
} derive(Default)

///|
impl @core.World for FailHookWorld with configure(self, setup) {
  setup.given("a step", fn(_ctx) { () })
  setup.before_test_case(fn(_ctx) raise {
    self.log.push("before_scenario")
    raise Failure::Failure("setup failed")
  })
  setup.after_test_case(fn(_ctx, _result) { self.log.push("after_scenario") })
}

///|
test "hooks: before_scenario failure skips all steps" {
  let world = FailHookWorld::default()
  let setup = @core.Setup::new()
  @core.World::configure(world, setup)
  let registry = setup.step_registry()
  let hook_registry = setup.hook_registry()
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "a step",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: None,
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="F",
    scenario_name="S",
    pickle_id="test-pickle-2",
    tags=[],
    steps~,
    hook_registry~,
  )
  assert_eq(result.status, ScenarioStatus::Failed)
  assert_eq(result.steps[0].status, StepStatus::Skipped(None))
  // after_scenario should still be called even when before_scenario fails
  assert_eq(world.log, ["before_scenario", "after_scenario"])
}

///|
async test "hooks: run end-to-end with hooks" {
  let content = "Feature: Hooks E2E\n\n  Scenario: Pass\n    Given a step\n    Then it passes\n"
  let result = run(
    HookWorld::default,
    RunOptions([FeatureSource::Text("test://hooks-e2e", content)]),
  )
  assert_eq(result.summary.total_scenarios, 1)
  assert_eq(result.summary.passed, 1)
}
