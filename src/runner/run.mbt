///|
/// Run all features and collect results.
pub fn run(
  registry : @core.StepRegistry,
  features : Array[String],
  tag_expr~ : String = "",
) -> RunResult!Error {
  let feature_results : Array[FeatureResult] = []
  for content in features {
    let result = execute_feature_filtered!(registry, content, tag_expr~)
    feature_results.push(result)
  }
  let summary = compute_summary(feature_results)
  { features: feature_results, summary }
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
