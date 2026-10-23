///|
test "shared settings filter scenarios and retry with fresh Worlds" {
  let result = @moonspec.run_sync(
    @shared.world,
    @shared.options(@shared.sources()),
  )
  @shared.verify_result(result)
}

///|
test "sync rejects the explicit parallel factory before World or sink effects" {
  let options = @shared.parallel_options(@shared.sources())
  let worlds = Ref(0)
  try {
    ignore(
      @moonspec.run_sync(
        fn() {
          worlds.val += 1
          @shared.world()
        },
        options,
      ),
    )
    fail("parallel sync should be rejected")
  } catch {
    @moonspec.SyncExecutionError::ParallelNotSupported => ()
    error => fail("unexpected error: \{error}")
  }
  assert_eq(worlds.val, 0)
  assert_eq(options.get_sinks()[0].output(), "")
  assert_true(options.is_parallel())
}

///|
test "shared hooks observe every attempt and keep lifecycle order" {
  let options = @shared.options(@shared.sources())
  @shared.verify_result(@moonspec.run_sync(@shared.world, options))
  @shared.verify_hooks(options)
}

///|
test "each factory call owns its mutable options and message sink" {
  let first = @shared.options(@shared.sources())
  let second = @shared.options(@shared.sources())
  assert_eq(first.get_sinks().length(), 1)
  assert_eq(second.get_sinks().length(), 1)
  first.scenario_name("Portable")
  first.retries(0)
  first.no_color(false)
  first.skip_tags(["@local"])
  assert_eq(second.get_scenario_name(), "")
  assert_eq(second.get_retries(), 1)
  assert_true(second.get_no_color())
  assert_eq(second.get_skip_tags(), ["@skip", "@ignore"])
  let result = @moonspec.run_sync(@shared.world, first)
  assert_eq(result.summary.total_scenarios, 1)
  assert_eq(result.summary.passed, 1)
  assert_true(first.get_sinks()[0].output().contains("testCaseFinished"))
  assert_eq(second.get_sinks()[0].output(), "")
  @shared.verify_result(@moonspec.run_sync(@shared.world, second))
}
