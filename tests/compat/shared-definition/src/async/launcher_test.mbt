///|
async test "shared settings filter scenarios and retry with fresh Worlds" {
  let result = @moonspec.run(@shared.world, @shared.options(@shared.sources()))
  @shared.verify_result(result)
}

///|
async test "concurrently scheduled invocations keep options Worlds and sinks isolated" {
  let ready = Ref(0)
  let tasks : Array[async () -> (@portable.RunResult, @portable.RunOptions)] = [
    async fn() {
      let options = @shared.options(@shared.sources())
      options.scenario_name("Portable")
      options.retries(0)
      ready.val += 1
      while ready.val < 2 {
        @async_runtime.sleep(1)
      }
      (@moonspec.run(@shared.world, options), options)
    },
    async fn() {
      let options = @shared.parallel_options(@shared.sources())
      ready.val += 1
      while ready.val < 2 {
        @async_runtime.sleep(1)
      }
      (@moonspec.run(@shared.world, options), options)
    },
  ]
  let observations = @async_runtime.all(tasks[:], max_concurrent=2)
  assert_eq(ready.val, 2)
  let (portable, portable_options) = observations[0]
  let (full, full_options) = observations[1]
  assert_eq(portable.summary.total_scenarios, 1)
  assert_eq(portable.summary.passed, 1)
  assert_eq(portable.summary.retried, 0)
  assert_eq(portable_options.get_retries(), 0)
  assert_eq(full_options.get_retries(), 1)
  assert_eq(full_options.get_scenario_name(), "")
  assert_false(portable_options.is_parallel())
  assert_true(full_options.is_parallel())
  @shared.verify_result(full)
  assert_eq(@shared.hook_events(portable_options), [
    "before_run", "before_case:Portable", "before_step:a fresh World", "after_step:Passed",
    "after_case:Portable:Passed", "after_run:Passed",
  ])
  @shared.verify_hooks(full_options)
}

///|
async test "explicit parallel factory keeps shared scenario retry and hook settings" {
  let options = @shared.parallel_options(@shared.sources())
  assert_true(options.is_parallel())
  assert_eq(options.get_max_concurrent(), 2)
  @shared.verify_result(@moonspec.run(@shared.world, options))
  @shared.verify_hooks(options)
}

///|
async test "root and async facades exchange options results and Worlds without conversion" {
  let sources : Array[@moonspec.FeatureSource] = @shared.sources()
  let root_options : @portable.RunOptions = @shared.options(sources)
  let async_options : @moonspec.RunOptions = @shared.options(@shared.sources())
  let sync_result : @moonspec.RunResult = @portable.run_sync(
    @shared.world, async_options,
  )
  let async_result : @portable.RunResult = @moonspec.run(
    @shared.world, root_options,
  )
  @shared.verify_result(sync_result)
  @shared.verify_result(async_result)
  @shared.verify_hooks(async_options)
  @shared.verify_hooks(root_options)
}
