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

///|
/// Execute a single scenario with lifecycle hooks.
/// Calls before/after_scenario and before/after_step on the world.
pub fn[W : @core.Hooks] execute_scenario_with_hooks(
  world : W,
  registry : @core.StepRegistry,
  feature_name~ : String,
  scenario_name~ : String,
  tags~ : Array[String],
  steps~ : Array[(String, String)],
) -> ScenarioResult {
  let info : @core.ScenarioInfo = { feature_name, scenario_name, tags }
  // before_scenario hook
  let hook_err = try {
    @core.Hooks::before_scenario(world, info)
    None
  } catch {
    e => Some(e.to_string())
  }
  if hook_err is Some(msg) {
    // All steps skipped when before_scenario fails
    let step_results = steps.map(fn(pair) {
      let (keyword, text) = pair
      { text, keyword, status: StepStatus::Skipped, duration_ms: 0L }
    })
    let _ = try {
      @core.Hooks::after_scenario(world, info, Some(msg))
    } catch {
      _ => ()
    }
    return {
      feature_name,
      scenario_name,
      tags,
      steps: step_results,
      status: ScenarioStatus::Failed,
      duration_ms: 0L,
    }
  }
  // Execute steps with before/after_step hooks
  let step_results : Array[StepResult] = []
  let mut failed = false
  let mut scenario_error : String? = None
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
    let step_info : @core.StepInfo = { keyword, text }
    // before_step hook
    let before_err = try {
      @core.Hooks::before_step(world, step_info)
      None
    } catch {
      e => Some(e.to_string())
    }
    let status = if before_err is Some(msg) {
      StepStatus::Failed(msg)
    } else {
      match registry.find_match(text) {
        None => StepStatus::Undefined
        Some((handler, args, _)) =>
          try {
            (handler.0)(args)
            StepStatus::Passed
          } catch {
            e => StepStatus::Failed(e.to_string())
          }
      }
    }
    // after_step hook
    let step_result_msg : String? = match status {
      StepStatus::Failed(msg) => Some(msg)
      _ => None
    }
    let _ = try {
      @core.Hooks::after_step(world, step_info, step_result_msg)
    } catch {
      _ => ()
    }
    match status {
      StepStatus::Failed(msg) => {
        failed = true
        scenario_error = Some(msg)
      }
      StepStatus::Undefined => {
        failed = true
        scenario_error = None
      }
      _ => ()
    }
    step_results.push({ text, keyword, status, duration_ms: 0L })
  }
  // after_scenario hook
  let _ = try {
    @core.Hooks::after_scenario(world, info, scenario_error)
  } catch {
    _ => ()
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
