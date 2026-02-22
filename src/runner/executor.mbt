///|
/// Execute a single scenario against a step registry.
/// Steps are provided as (keyword, text) pairs.
pub fn execute_scenario(
  registry : @core.StepRegistry,
  feature_name~ : String,
  scenario_name~ : String,
  tags~ : Array[String],
  steps~ : Array[(String, String)],
) -> ScenarioResult {
  let step_results : Array[StepResult] = []
  let mut failed = false
  for pair in steps {
    let (keyword, text) = pair
    if failed {
      step_results.push({
        text,
        keyword,
        status: StepStatus::Skipped,
        duration_ms: 0L,
      })
      continue
    }
    let status = match registry.find_match(text) {
      None => StepStatus::Undefined
      Some((handler, args, _)) =>
        try {
          (handler.0)(args)
          StepStatus::Passed
        } catch {
          e => StepStatus::Failed(e.to_string())
        }
    }
    match status {
      StepStatus::Failed(_) | StepStatus::Undefined => failed = true
      _ => ()
    }
    step_results.push({ text, keyword, status, duration_ms: 0L })
  }
  let statuses = step_results.map(fn(r) { r.status })
  {
    feature_name,
    scenario_name,
    tags,
    steps: step_results,
    status: ScenarioStatus::from_steps(statuses),
    duration_ms: 0L,
  }
}
