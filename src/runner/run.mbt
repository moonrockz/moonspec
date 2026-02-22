///|
/// Run all features and collect results.
///
/// When `parallel` is greater than 0, it indicates the desired concurrency level
/// for feature execution. Currently executes sequentially regardless; true async
/// parallel execution will be enabled in a future release once the runner's
/// error-raising functions are adapted for async contexts.
pub fn run(
  registry : @core.StepRegistry,
  features : Array[String],
  tag_expr? : String = "",
  parallel? : Int = 0,
) -> RunResult raise Error {
  let feature_results = if parallel > 0 {
    run_parallel(registry, features, tag_expr~, max_concurrent=parallel)
  } else {
    run_sequential(registry, features, tag_expr~)
  }
  let summary = compute_summary(feature_results)
  { features: feature_results, summary }
}

///|
/// Run features sequentially (the default path).
fn run_sequential(
  registry : @core.StepRegistry,
  features : Array[String],
  tag_expr~ : String,
) -> Array[FeatureResult] raise Error {
  let results : Array[FeatureResult] = []
  for content in features {
    let result = execute_feature_filtered(registry, content, tag_expr~)
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
