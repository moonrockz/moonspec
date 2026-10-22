///|
/// Run all features and collect results.
///
/// A fresh world is created per scenario via `factory()` for isolation.
/// When `parallel` is enabled, pickles are executed concurrently using
/// `@async.all()` with bounded concurrency. Otherwise, pickles run sequentially.
/// Lifecycle hooks registered via `Setup` are called automatically when present.
pub async fn[W : @core.World] run(
  factory : () -> W,
  options : RunOptions,
) -> RunResult {
  run_detailed(factory, options).0
}

///|
/// Run all features. Also return the `path:line` location of each pickle, by
/// pickle id, for the failure report of `run_or_fail`.
async fn[W : @core.World] run_detailed(
  factory : () -> W,
  options : RunOptions,
) -> (RunResult, Map[String, String]) {
  let prepared = prepare_run(factory, options)
  let paired_results = if options.is_parallel() {
    run_pickles_parallel(
      factory,
      prepared.filtered,
      max_concurrent=options.get_max_concurrent(),
      sinks=prepared.sinks,
      tc_mappings=prepared.tc_mappings,
      id_gen=prepared.id_gen,
      retries=options.get_retries(),
      dry_run=options.is_dry_run(),
      skip_tags=options.get_skip_tags(),
    )
  } else {
    run_prepared_sync(factory, prepared, options)
  }
  finish_run(prepared, options, paired_results)
}

///|
/// Run all features, raising MoonspecError on any failure.
///
/// This is the ergonomic test API. Use in generated tests and manual tests
/// where you want structured error output instead of manual result inspection.
/// The raised `RunFailed` prints a cucumber-style report of every parse error
/// and failed scenario. It uses ANSI colors unless `RunOptions::no_color` is
/// set, or the environment overrides it (see `@core.color_enabled`).
pub async fn[W : @core.World] run_or_fail(
  factory : () -> W,
  options : RunOptions,
) -> Unit {
  let (result, locations) = run_detailed(factory, options)
  check_run_result(result, locations, options)
}
