///|
/// Tests for World isolation (fresh per scenario) and Hooks lifecycle.

///|
struct IsolationWorld {
  mut counter : Int
} derive(Default)

///|
impl @core.World for IsolationWorld with register_steps(self, s) {
  s.given("I set counter to {int}", fn(args) {
    match args[0] {
      @core.StepArg::IntArg(n) => self.counter = n
      _ => ()
    }
  })
  s.then("counter should be {int}", fn(args) raise {
    match args[0] {
      @core.StepArg::IntArg(expected) => assert_eq(self.counter, expected)
      _ => ()
    }
  })
}

///|
async test "isolation: each scenario gets a fresh world" {
  // Scenario 1 sets counter to 42, scenario 2 expects default (0).
  // If isolation is broken, scenario 2 would see 42.
  let content = "Feature: Isolation\n\n  Scenario: Set counter\n    Given I set counter to 42\n    Then counter should be 42\n\n  Scenario: Fresh world\n    Then counter should be 0\n"
  let result = run(IsolationWorld::default, [content])
  assert_eq(result.summary.total_scenarios, 2)
  assert_eq(result.summary.passed, 2)
  assert_eq(result.summary.failed, 0)
}

///|
async test "isolation: parallel execution with fresh worlds" {
  let feature1 = "Feature: F1\n\n  Scenario: Set counter\n    Given I set counter to 99\n    Then counter should be 99\n"
  let feature2 = "Feature: F2\n\n  Scenario: Fresh world\n    Then counter should be 0\n"
  let result = run(IsolationWorld::default, [feature1, feature2], parallel=2)
  assert_eq(result.summary.total_scenarios, 2)
  assert_eq(result.summary.passed, 2)
}

///|
struct HookWorld {
  log : Array[String]
} derive(Default)

///|
impl @core.World for HookWorld with register_steps(_self, s) {
  s.given("a step", fn(_args) { () })
  s.then("it passes", fn(_args) { () })
}

///|
impl @core.Hooks for HookWorld with before_scenario(self, info) {
  self.log.push("before_scenario:" + info.scenario_name)
}

///|
impl @core.Hooks for HookWorld with after_scenario(self, info, result) {
  let status = match result {
    None => "ok"
    Some(msg) => msg
  }
  self.log.push("after_scenario:" + info.scenario_name + ":" + status)
}

///|
impl @core.Hooks for HookWorld with before_step(self, info) {
  self.log.push("before_step:" + info.text)
}

///|
impl @core.Hooks for HookWorld with after_step(self, info, result) {
  let status = match result {
    None => "ok"
    Some(msg) => msg
  }
  self.log.push("after_step:" + info.text + ":" + status)
}

///|
test "hooks: correct ordering of lifecycle calls" {
  let world = HookWorld::default()
  let registry = @core.StepRegistry::new()
  @core.World::register_steps(world, registry)
  let result = execute_scenario_with_hooks(
    world,
    registry,
    feature_name="Hooks",
    scenario_name="One",
    tags=[],
    steps=[("Given ", "a step"), ("Then ", "it passes")],
  )
  assert_eq(result.status, ScenarioStatus::Passed)
  assert_eq(
    world.log,
    [
      "before_scenario:One",
      "before_step:a step",
      "after_step:a step:ok",
      "before_step:it passes",
      "after_step:it passes:ok",
      "after_scenario:One:ok",
    ],
  )
}

///|
struct FailHookWorld {
  log : Array[String]
} derive(Default)

///|
impl @core.World for FailHookWorld with register_steps(_self, s) {
  s.given("a step", fn(_args) { () })
}

///|
impl @core.Hooks for FailHookWorld with before_scenario(self, _info) raise {
  self.log.push("before_scenario")
  raise Failure::Failure("setup failed")
}

///|
impl @core.Hooks for FailHookWorld with after_scenario(self, _info, _result) {
  self.log.push("after_scenario")
}

///|
test "hooks: before_scenario failure skips all steps" {
  let world = FailHookWorld::default()
  let registry = @core.StepRegistry::new()
  @core.World::register_steps(world, registry)
  let result = execute_scenario_with_hooks(
    world,
    registry,
    feature_name="F",
    scenario_name="S",
    tags=[],
    steps=[("Given ", "a step")],
  )
  assert_eq(result.status, ScenarioStatus::Failed)
  assert_eq(result.steps[0].status, StepStatus::Skipped)
  // after_scenario should still be called even when before_scenario fails
  assert_eq(world.log, ["before_scenario", "after_scenario"])
}

///|
async test "hooks: run_with_hooks end-to-end" {
  let content = "Feature: Hooks E2E\n\n  Scenario: Pass\n    Given a step\n    Then it passes\n"
  let result = run_with_hooks(HookWorld::default, [content])
  assert_eq(result.summary.total_scenarios, 1)
  assert_eq(result.summary.passed, 1)
}
