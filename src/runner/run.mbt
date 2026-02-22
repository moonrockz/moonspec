///|
/// Run all features and collect results.
///
/// A fresh world is created per scenario via `factory()` for isolation.
/// When `parallel` is greater than 0, features are executed concurrently using
/// `@async.all()` with bounded concurrency. Otherwise, features run sequentially.
pub async fn[W : @core.World] run(
  factory : () -> W,
  features : Array[String],
  tag_expr? : String = "",
  parallel? : Int = 0,
) -> RunResult {
  let feature_results = if parallel > 0 {
    run_parallel(factory, features, tag_expr~, max_concurrent=parallel)
  } else {
    run_sequential(factory, features, tag_expr~)
  }
  let summary = compute_summary(feature_results)
  { features: feature_results, summary }
}

///|
/// Run features sequentially (the default path).
fn[W : @core.World] run_sequential(
  factory : () -> W,
  features : Array[String],
  tag_expr~ : String,
) -> Array[FeatureResult] raise Error {
  let results : Array[FeatureResult] = []
  for content in features {
    let result = execute_feature_filtered(factory, content, tag_expr~)
    results.push(result)
  }
  results
}

///|
/// Run all features with lifecycle hooks and collect results.
///
/// Like `run`, but calls before/after_scenario and before/after_step hooks
/// on the world. The world must implement both `World` and `Hooks` traits.
pub async fn[W : @core.World + @core.Hooks] run_with_hooks(
  factory : () -> W,
  features : Array[String],
  tag_expr? : String = "",
  parallel? : Int = 0,
) -> RunResult {
  let feature_results = if parallel > 0 {
    run_parallel_with_hooks(factory, features, tag_expr~, max_concurrent=parallel)
  } else {
    run_sequential_with_hooks(factory, features, tag_expr~)
  }
  let summary = compute_summary(feature_results)
  { features: feature_results, summary }
}

///|
fn[W : @core.World + @core.Hooks] run_sequential_with_hooks(
  factory : () -> W,
  features : Array[String],
  tag_expr~ : String,
) -> Array[FeatureResult] raise Error {
  let results : Array[FeatureResult] = []
  for content in features {
    let result = execute_feature_filtered_with_hooks(factory, content, tag_expr~)
    results.push(result)
  }
  results
}

///|
fn compute_summary(features : Array[FeatureResult]) -> RunSummary {
  let mut total = 0
  let mut passed = 0
  let mut failed = 0
  let mut undefined = 0
  let mut pending = 0
  let mut skipped = 0
  for f in features {
    for s in f.scenarios {
      total = total + 1
      match s.status {
        ScenarioStatus::Passed => passed = passed + 1
        ScenarioStatus::Failed => failed = failed + 1
        ScenarioStatus::Undefined => undefined = undefined + 1
        ScenarioStatus::Pending => pending = pending + 1
        ScenarioStatus::Skipped => skipped = skipped + 1
      }
    }
  }
  {
    total_scenarios: total,
    passed,
    failed,
    undefined,
    pending,
    skipped,
    duration_ms: 0L,
  }
}
