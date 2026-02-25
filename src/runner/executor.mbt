///|
/// Drain pending attachments from args and emit as envelopes.
fn emit_attachments(
  sinks : Array[&@core.MessageSink],
  attachments : Array[@core.PendingAttachment],
  test_case_started_id : String,
  test_step_id : String?,
) -> Unit {
  for att in attachments {
    match att {
      @core.PendingAttachment::Embedded(
        body~,
        encoding~,
        media_type~,
        file_name~
      ) => {
        // AttachmentContentEncoding constructors are not directly accessible
        // from outside cucumber-messages, so we convert via JSON stringify
        // and strip the surrounding quotes.
        let enc_str = encoding.to_json().stringify()
        let enc_clean = enc_str.substring(start=1, end=enc_str.length() - 1)
        emit(
          sinks,
          make_attachment_envelope(
            body,
            enc_clean,
            media_type,
            file_name,
            Some(test_case_started_id),
            test_step_id,
          ),
        )
      }
      @core.PendingAttachment::External(url~, media_type~) =>
        emit(
          sinks,
          make_external_attachment_envelope(
            url,
            media_type,
            Some(test_case_started_id),
            test_step_id,
          ),
        )
    }
  }
}

///|
fn parse_keyword_string(s : String) -> @core.StepKeyword {
  match s {
    "Given " => @core.StepKeyword::Given
    "When " => @core.StepKeyword::When
    "Then " => @core.StepKeyword::Then
    _ => @core.StepKeyword::Step
  }
}

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
  dry_run? : Bool = false,
) -> ScenarioResult {
  let info : @core.ScenarioInfo = { feature_name, scenario_name, tags }
  let has_sinks = sinks.length() > 0 && test_step_ids.length() > 0
  let before_case_hooks = hook_registry.by_type(@core.HookType::BeforeTestCase)
  let after_case_hooks = hook_registry.by_type(@core.HookType::AfterTestCase)
  let before_step_hooks = hook_registry.by_type(@core.HookType::BeforeTestStep)
  let after_step_hooks = hook_registry.by_type(@core.HookType::AfterTestStep)
  // Dry-run: match steps but skip hooks and handler execution
  if dry_run {
    let step_results : Array[StepResult] = []
    let mut step_idx = 0
    for _i, step in steps {
      let keyword = match step.type_ {
        Some(@cucumber_messages.PickleStepType::Context) => "Given "
        Some(@cucumber_messages.PickleStepType::Action) => "When "
        Some(@cucumber_messages.PickleStepType::Outcome) => "Then "
        _ => "* "
      }
      let ts_id = if step_idx < test_step_ids.length() {
        test_step_ids[step_idx]
      } else {
        ""
      }
      step_idx += 1
      if has_sinks {
        emit(
          sinks,
          make_test_step_started_envelope(test_case_started_id, ts_id),
        )
      }
      let (status, diagnostic) : (StepStatus, Error?) = match
        registry.find_match(step.text, keyword~) {
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
        Matched(_, _) => (StepStatus::Skipped(Some("dry run")), None)
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
      step_results.push({
        text: step.text,
        keyword,
        status,
        duration_ms: 0L,
        diagnostic,
      })
    }
    let statuses = step_results.map(fn(r) { r.status })
    return {
      feature_name,
      scenario_name,
      pickle_id,
      tags,
      steps: step_results,
      status: ScenarioStatus::from_steps(statuses),
      duration_ms: 0L,
    }
  }
  // Track overall test step index across hook steps and regular steps
  let mut step_idx = 0
  // before_test_case hooks — emit TestStepStarted/Finished for each
  let mut hook_err : String? = None
  for hook in before_case_hooks {
    let ts_id = if step_idx < test_step_ids.length() {
      test_step_ids[step_idx]
    } else {
      ""
    }
    step_idx += 1
    if has_sinks {
      emit(sinks, make_test_step_started_envelope(test_case_started_id, ts_id))
    }
    let status_str = if hook_err is Some(_) {
      "SKIPPED"
    } else {
      match hook.handler {
        @core.CaseHandler(h) =>
          try {
            let hook_ctx = @core.CaseHookCtx::new(info)
            h(hook_ctx)
            if has_sinks && hook_ctx.pending_attachments().length() > 0 {
              emit_attachments(
                sinks,
                hook_ctx.pending_attachments(),
                test_case_started_id,
                Some(ts_id),
              )
              hook_ctx.pending_attachments().clear()
            }
            "PASSED"
          } catch {
            e => {
              hook_err = Some(e.to_string())
              "FAILED"
            }
          }
        _ => "PASSED"
      }
    }
    let err_msg : String? = match status_str {
      "FAILED" => hook_err
      _ => None
    }
    if has_sinks {
      emit(
        sinks,
        make_test_step_finished_envelope(
          test_case_started_id, ts_id, status_str, err_msg,
        ),
      )
    }
  }
  // If before_test_case hook failed, skip all regular steps
  if hook_err is Some(msg) {
    let step_results : Array[StepResult] = []
    for _i, step in steps {
      let keyword = match step.type_ {
        Some(@cucumber_messages.PickleStepType::Context) => "Given "
        Some(@cucumber_messages.PickleStepType::Action) => "When "
        Some(@cucumber_messages.PickleStepType::Outcome) => "Then "
        _ => "* "
      }
      let ts_id = if step_idx < test_step_ids.length() {
        test_step_ids[step_idx]
      } else {
        ""
      }
      step_idx += 1
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
        status: StepStatus::Skipped(None),
        duration_ms: 0L,
        diagnostic: None,
      })
    }
    // after_test_case hooks still run even on before failure
    let case_hook_result : @core.HookResult = @core.HookResult::Failed([
      @core.HookError::StepFailed(
        step="",
        keyword=@core.StepKeyword::Step,
        message=msg,
      ),
    ])
    for hook in after_case_hooks {
      let ts_id = if step_idx < test_step_ids.length() {
        test_step_ids[step_idx]
      } else {
        ""
      }
      step_idx += 1
      if has_sinks {
        emit(
          sinks,
          make_test_step_started_envelope(test_case_started_id, ts_id),
        )
      }
      let after_status = match hook.handler {
        @core.CaseAfterHandler(h) =>
          try {
            let hook_ctx = @core.CaseHookCtx::new(info)
            h(hook_ctx, case_hook_result)
            if has_sinks && hook_ctx.pending_attachments().length() > 0 {
              emit_attachments(
                sinks,
                hook_ctx.pending_attachments(),
                test_case_started_id,
                Some(ts_id),
              )
              hook_ctx.pending_attachments().clear()
            }
            "PASSED"
          } catch {
            _ => "FAILED"
          }
        _ => "PASSED"
      }
      if has_sinks {
        emit(
          sinks,
          make_test_step_finished_envelope(
            test_case_started_id,
            ts_id,
            after_status,
            None,
          ),
        )
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
  for _i, step in steps {
    let keyword = match step.type_ {
      Some(@cucumber_messages.PickleStepType::Context) => "Given "
      Some(@cucumber_messages.PickleStepType::Action) => "When "
      Some(@cucumber_messages.PickleStepType::Outcome) => "Then "
      _ => "* "
    }
    let ts_id = if step_idx < test_step_ids.length() {
      test_step_ids[step_idx]
    } else {
      ""
    }
    step_idx += 1
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
        status: StepStatus::Skipped(None),
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
          @core.StepHandler(h) => {
            let hook_ctx = @core.StepHookCtx::new(info, step_info)
            h(hook_ctx) catch {
              e => err = Some(e.to_string())
            }
            if has_sinks && hook_ctx.pending_attachments().length() > 0 {
              emit_attachments(
                sinks,
                hook_ctx.pending_attachments(),
                test_case_started_id,
                Some(ts_id),
              )
              hook_ctx.pending_attachments().clear()
            }
          }
          _ => ()
        }
      }
      err
    } else {
      None
    }
    let mut ctx_for_drain : @core.Ctx? = None
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
            // Append block argument (DocString/DataTable) as last StepArg
            match step.argument {
              Some(arg) =>
                match (arg.docString, arg.dataTable) {
                  (Some(ds), _) => {
                    let doc : @core.DocString = {
                      content: ds.content,
                      media_type: ds.mediaType,
                    }
                    args.push(@core.StepArg::{
                      value: DocStringVal(doc),
                      raw: ds.content,
                    })
                  }
                  (_, Some(dt)) => {
                    let raw_rows = dt.rows.map(fn(row) {
                      row.cells.map(fn(cell) { cell.value })
                    })
                    let table = @core.DataTable::from_rows(raw_rows)
                    args.push(@core.StepArg::{
                      value: DataTableVal(table),
                      raw: "",
                    })
                  }
                  _ => ()
                }
              None => ()
            }
            let ctx = @core.Ctx::new(args, info, step_info)
            (step_def.handler.0)(ctx)
            ctx_for_drain = Some(ctx)
            (StepStatus::Passed, None)
          } catch {
            @core.MoonspecError::PendingStep(step~, keyword=kw, message~) =>
              (
                StepStatus::Pending,
                Some(@core.pending_step_error(step~, keyword=kw, message~)),
              )
            e => {
              let enriched = "Step '" +
                step.text +
                "' (" +
                keyword.trim(chars=" ").to_string() +
                "): " +
                e.to_string()
              (
                StepStatus::Failed(enriched),
                Some(
                  @core.step_failed_error(
                    step=step.text,
                    keyword~,
                    message=enriched,
                  ),
                ),
              )
            }
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
    // Drain attachments from ctx
    if has_sinks {
      match ctx_for_drain {
        Some(c) =>
          if c.pending_attachments().length() > 0 {
            emit_attachments(
              sinks,
              c.pending_attachments(),
              test_case_started_id,
              Some(ts_id),
            )
            c.pending_attachments().clear()
          }
        None => ()
      }
    }
    // after_test_step hooks
    if after_step_hooks.length() > 0 {
      let step_hook_result : @core.HookResult = match status {
        StepStatus::Failed(msg) =>
          @core.HookResult::Failed([
            @core.HookError::StepFailed(
              step=step.text,
              keyword=parse_keyword_string(keyword),
              message=msg,
            ),
          ])
        _ => @core.HookResult::Passed
      }
      for hook in after_step_hooks {
        match hook.handler {
          @core.StepAfterHandler(h) => {
            let hook_ctx = @core.StepHookCtx::new(info, step_info)
            let _ = h(hook_ctx, step_hook_result) catch { _ => () }
            if has_sinks && hook_ctx.pending_attachments().length() > 0 {
              emit_attachments(
                sinks,
                hook_ctx.pending_attachments(),
                test_case_started_id,
                Some(ts_id),
              )
              hook_ctx.pending_attachments().clear()
            }
          }
          _ => ()
        }
      }
    }
    match status {
      StepStatus::Failed(_) | StepStatus::Undefined | StepStatus::Pending =>
        failed = true
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
  // after_test_case hooks — emit TestStepStarted/Finished for each
  let step_errors : Array[@core.HookError] = []
  for r in step_results {
    match r.status {
      StepStatus::Failed(msg) =>
        step_errors.push(
          @core.HookError::StepFailed(
            step=r.text,
            keyword=parse_keyword_string(r.keyword),
            message=msg,
          ),
        )
      _ => ()
    }
  }
  let case_hook_result : @core.HookResult = if step_errors.length() > 0 {
    @core.HookResult::Failed(step_errors)
  } else {
    @core.HookResult::Passed
  }
  for hook in after_case_hooks {
    let ts_id = if step_idx < test_step_ids.length() {
      test_step_ids[step_idx]
    } else {
      ""
    }
    step_idx += 1
    if has_sinks {
      emit(sinks, make_test_step_started_envelope(test_case_started_id, ts_id))
    }
    let after_status = match hook.handler {
      @core.CaseAfterHandler(h) =>
        try {
          let hook_ctx = @core.CaseHookCtx::new(info)
          h(hook_ctx, case_hook_result)
          if has_sinks && hook_ctx.pending_attachments().length() > 0 {
            emit_attachments(
              sinks,
              hook_ctx.pending_attachments(),
              test_case_started_id,
              Some(ts_id),
            )
            hook_ctx.pending_attachments().clear()
          }
          "PASSED"
        } catch {
          _ => "FAILED"
        }
      _ => "PASSED"
    }
    if has_sinks {
      emit(
        sinks,
        make_test_step_finished_envelope(
          test_case_started_id,
          ts_id,
          after_status,
          None,
        ),
      )
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
