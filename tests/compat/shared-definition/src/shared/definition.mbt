///|
pub struct SharedWorld {
  priv mut ready : Bool
}

///|
pub impl @moonspec.World for SharedWorld with fn configure(self, setup) {
  setup.before_test_run(ctx => ctx.attach("before_run", "text/plain"))
  setup.after_test_run(fn(ctx, result) {
    ctx.attach("after_run:" + hook_status(result), "text/plain")
  })
  setup.before_test_case(fn(ctx) raise {
    assert_false(self.ready)
    ctx.attach("before_case:" + ctx.scenario().scenario_name, "text/plain")
  })
  setup.before_test_step(ctx => {
    ctx.attach("before_step:" + ctx.step().text, "text/plain")
  })
  setup.after_test_step(fn(ctx, result) {
    ctx.attach("after_step:" + hook_status(result), "text/plain")
  })
  setup.given("a fresh World", fn(_) raise {
    assert_false(self.ready)
    self.ready = true
  })
  setup.when("the attempt fails", fn(_) raise {
    raise Failure("retry evidence")
  })
  setup.after_test_case(fn(ctx, result) raise {
    assert_true(self.ready)
    ctx.attach(
      "after_case:" + ctx.scenario().scenario_name + ":" + hook_status(result),
      "text/plain",
    )
  })
}

///|
fn hook_status(result : @moonspec.HookResult) -> String {
  match result {
    Passed => "Passed"
    Failed(_) => "Failed"
  }
}

///|
pub fn world() -> SharedWorld {
  { ready: false, }
}

///|
pub fn sources() -> Array[@moonspec.FeatureSource] {
  let source =
    #|Feature: Shared
    #|  @keep
    #|  Scenario: Portable
    #|    Given a fresh World
    #|
    #|  @keep
    #|  Scenario: Retry
    #|    Given a fresh World
    #|    When the attempt fails
    #|
    #|  Scenario: Excluded
    #|    Given an undefined step that must be filtered
    #|
  [@moonspec.FeatureSource::Text("original/shared.feature", source)]
}

///|
pub fn options(
  features : Array[@moonspec.FeatureSource],
) -> @moonspec.RunOptions {
  let options = @moonspec.RunOptions(features)
  options.tag_expr("@keep")
  options.retries(1)
  options.no_color(true)
  options.add_sink(@format.MessagesFormatter::new())
  options
}

///|
pub fn parallel_options(
  features : Array[@moonspec.FeatureSource],
) -> @moonspec.RunOptions {
  let options = options(features)
  options.parallel(true)
  options.max_concurrent(2)
  options
}

///|
pub extend SharedWorld with @moonspec.World::{configure}

///|
pub fn verify_result(result : @moonspec.RunResult) -> Unit raise {
  assert_eq(result.summary.total_scenarios, 2)
  assert_eq(result.summary.passed, 1)
  assert_eq(result.summary.failed, 1)
  assert_eq(result.summary.retried, 1)
  assert_eq(result.summary.undefined, 0)
  assert_eq(result.features[0].scenarios[0].scenario_name, "Portable")
  assert_eq(result.features[0].scenarios[1].scenario_name, "Retry")
  assert_eq(
    result.features[0].scenarios[1].steps[0].status,
    @moonspec.StepStatus::Passed,
  )
  match result.features[0].scenarios[1].steps[1].status {
    Failed(message) => assert_true(message.contains("retry evidence"))
    _ => fail("expected retry failure")
  }
}
