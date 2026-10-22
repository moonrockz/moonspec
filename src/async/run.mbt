///|
/// Run all features with optional bounded parallel scenario scheduling.
pub async fn[W : @moonspec.World] run(
  factory : () -> W,
  options : RunOptions,
) -> RunResult {
  let prepared = @runner.prepare_run(factory, options)
  let results = execute_tasks(prepared.tasks(factory, options), options)
  prepared.finish(options, results)
}

///|
/// Run all features, raising the shared structured report for any failure.
pub async fn[W : @moonspec.World] run_or_fail(
  factory : () -> W,
  options : RunOptions,
) -> Unit {
  let prepared = @runner.prepare_run(factory, options)
  let results = execute_tasks(prepared.tasks(factory, options), options)
  let result = prepared.finish(options, results)
  prepared.check(result, options)
}

///|
// Scenario handlers are synchronous; the scheduler still requires async tasks.
#warnings("-unused_async")
async fn execute_tasks(
  tasks : Array[() -> @runner.PickleResult raise Error],
  options : RunOptions,
) -> Array[@runner.PickleResult] {
  let async_tasks : Array[async () -> @runner.PickleResult] = tasks.map(fn(
    task,
  ) {
    async fn() { task() }
  })
  schedule_tasks(async_tasks, options)
}

///|
async fn[X] schedule_tasks(
  tasks : Array[async () -> X],
  options : RunOptions,
) -> Array[X] {
  if options.is_parallel() {
    @runtime.all(tasks[:], max_concurrent=options.get_max_concurrent())
  } else {
    let results : Array[X] = []
    for task in tasks {
      results.push(task())
    }
    results
  }
}
