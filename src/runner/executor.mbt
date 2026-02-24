///|
/// Execute a single scenario from a compiled Pickle.
///
/// When a `hook_registry` is provided (and contains hooks), lifecycle hooks
/// are called at the appropriate points: before/after test case and
/// before/after each test step.
pub fn execute_scenario(
  registry : @core.StepRegistry,
  feature_name~ : String,
  scenario_name~ : String,
  pickle_id~ : String,
  tags~ : Array[String],
  steps~ : Array[@cucumber_messages.PickleStep],
  hook_registry? : @core.HookRegistry = @core.HookRegistry::new(),
  sinks? : Array[&@core.MessageSink] = [],
  test_case_started_id? : String = "",
  test_step_ids? : Array[String] = [],
) -> ScenarioResult {
  let info : @core.ScenarioInfo = { feature_name, scenario_name, tags }
  let has_sinks = sinks.length() > 0 && test_step_ids.length() > 0
  let before_case_hooks = hook_registry.by_type(@core.HookType::BeforeTestCase)
  let after_case_hooks = hook_registry.by_type(@core.HookType::AfterTestCase)
  let before_step_hooks = hook_registry.by_type(@core.HookType::BeforeTestStep)
  let after_step_hooks = hook_registry.by_type(@core.HookType::AfterTestStep)
  let has_hooks = before_case_hooks.length() > 0 ||
    after_case_hooks.length() > 0 ||
    before_step_hooks.length() > 0 ||
    after_step_hooks.length() > 0
  // before_test_case hooks
  let hook_err : String? = if has_hooks {
    let mut err : String? = None
    for hook in before_case_hooks {
      if err is Some(_) {
        break
      }
      match hook.handler {
        @core.CaseHandler(h) =>
          try {
            h(info, None)
          } catch {
            e => err = Some(e.to_string())
          }
        _ => ()
      }
    }
    err
  } else {
    None
  }
  // If before_test_case hook failed, skip all steps
  if hook_err is Some(msg) {
    let step_results : Array[StepResult] = []
    for i, step in steps {
      let keyword = match step.type_ {
        Some(@cucumber_messages.PickleStepType::Context) => "Given "
        Some(@cucumber_messages.PickleStepType::Action) => "When "
        Some(@cucumber_messages.PickleStepType::Outcome) => "Then "
        _ => "* "
      }
      let ts_id = if i < test_step_ids.length() { test_step_ids[i] } else { "" }
      if has_sinks {
        emit(
          sinks,
          make_test_step_started_envelope(test_case_started_id, ts_id),
        )
        emit(
          sinks,
          make_test_step_finished_envelope(
            test_case_started_id,
            ts_id,
            "SKIPPED",
            None,
          ),
        )
      }
      step_results.push({
        text: step.text,
        keyword,
        status: StepStatus::Skipped,
        duration_ms: 0L,
        diagnostic: None,
      })
    }
    // after_test_case hooks still run even on before failure
    for hook in after_case_hooks {
      match hook.handler {
        @core.CaseHandler(h) => {
          let _ = h(info, Some(msg)) catch { _ => () }
        }
        _ => ()
      }
    }
    return {
      feature_name,
      scenario_name,
      pickle_id,
      tags,
      steps: step_results,
      status: ScenarioStatus::Failed,
      duration_ms: 0L,
    }
  }
  // Execute steps with optional before/after_step hooks
  let step_results : Array[StepResult] = []
  let mut failed = false
  let mut scenario_error : String? = None
  for i, step in steps {
    let keyword = match step.type_ {
      Some(@cucumber_messages.PickleStepType::Context) => "Given "
      Some(@cucumber_messages.PickleStepType::Action) => "When "
      Some(@cucumber_messages.PickleStepType::Outcome) => "Then "
      _ => "* "
    }
    let ts_id = if i < test_step_ids.length() { test_step_ids[i] } else { "" }
    if has_sinks {
      emit(sinks, make_test_step_started_envelope(test_case_started_id, ts_id))
    }
    if failed {
      if has_sinks {
        emit(
          sinks,
          make_test_step_finished_envelope(
            test_case_started_id,
            ts_id,
            "SKIPPED",
            None,
          ),
        )
      }
      step_results.push({
        text: step.text,
        keyword,
        status: StepStatus::Skipped,
        duration_ms: 0L,
        diagnostic: None,
      })
      continue
    }
    let step_info : @core.StepInfo = { keyword, text: step.text }
    // before_test_step hooks
    let before_err : String? = if before_step_hooks.length() > 0 {
      let mut err : String? = None
      for hook in before_step_hooks {
        if err is Some(_) {
          break
        }
        match hook.handler {
          @core.StepHandler(h) =>
            try {
              h(step_info, None)
            } catch {
              e => err = Some(e.to_string())
            }
          _ => ()
        }
      }
      err
    } else {
      None
    }
    let (status, diagnostic) : (StepStatus, Error?) = if before_err is Some(msg) {
      (
        StepStatus::Failed(msg),
        Some(@core.step_failed_error(step=step.text, keyword~, message=msg)),
      )
    } else {
      match registry.find_match(step.text, keyword~) {
        Undefined(step_text~, keyword=kw, snippet~, suggestions~) =>
          (
            StepStatus::Undefined,
            Some(
              @core.undefined_step_error(
                step=step_text,
                keyword=kw,
                snippet~,
                suggestions~,
              ),
            ),
          )
        Matched(step_def, args) =>
          try {
            (step_def.handler.0)(args)
            (StepStatus::Passed, None)
          } catch {
            @core.MoonspecError::PendingStep(step~, keyword=kw, message~) =>
              (
                StepStatus::Pending,
                Some(@core.pending_step_error(step~, keyword=kw, message~)),
              )
            e =>
              (
                StepStatus::Failed(e.to_string()),
                Some(
                  @core.step_failed_error(
                    step=step.text,
                    keyword~,
                    message=e.to_string(),
                  ),
                ),
              )
          }
      }
    }
    if has_sinks {
      emit(
        sinks,
        make_test_step_finished_envelope(
          test_case_started_id,
          ts_id,
          step_status_to_string(status),
          step_status_message(status),
        ),
      )
    }
    // after_test_step hooks
    if after_step_hooks.length() > 0 {
      let step_result_msg : String? = match status {
        StepStatus::Failed(msg) => Some(msg)
        _ => None
      }
      for hook in after_step_hooks {
        match hook.handler {
          @core.StepHandler(h) => {
            let _ = h(step_info, step_result_msg) catch { _ => () }
          }
          _ => ()
        }
      }
    }
    match status {
      StepStatus::Failed(msg) => {
        failed = true
        scenario_error = Some(msg)
      }
      StepStatus::Undefined | StepStatus::Pending => {
        failed = true
        scenario_error = None
      }
      _ => ()
    }
    step_results.push({
      text: step.text,
      keyword,
      status,
      duration_ms: 0L,
      diagnostic,
    })
  }
  // after_test_case hooks
  if after_case_hooks.length() > 0 {
    for hook in after_case_hooks {
      match hook.handler {
        @core.CaseHandler(h) => {
          let _ = h(info, scenario_error) catch { _ => () }
        }
        _ => ()
      }
    }
  }
  let statuses = step_results.map(fn(r) { r.status })
  {
    feature_name,
    scenario_name,
    pickle_id,
    tags,
    steps: step_results,
    status: ScenarioStatus::from_steps(statuses),
    duration_ms: 0L,
  }
}
