///|
/// Prepared run metadata and lifecycle shared by both entry points.
priv struct PreparedRun {
  cache : FeatureCache
  filtered : Array[@cucumber_messages.Pickle]
  locations : Map[String, String]
  sinks : Array[&@core.MessageSink]
  tc_mappings : Map[String, TestCaseMapping]
  setup : @core.Setup
  id_gen : IdGenerator
  run_id : String
  all_parse_errors : Array[ParseErrorInfo]
}

///|
fn[W : @core.World] prepare_run(
  factory : () -> W,
  options : RunOptions,
) -> PreparedRun raise Error {
  let features = options.features()
  let sinks = options.get_sinks()
  let tag_expr = options.get_tag_expr()
  let scenario_name = options.get_scenario_name()
  let cache = FeatureCache::new()
  if sinks.length() > 0 {
    emit(sinks, make_meta_envelope())
  }
  let all_parse_errors : Array[ParseErrorInfo] = []
  for source in features {
    if sinks.length() > 0 {
      let (uri, data) = match source {
        FeatureSource::Text(path, content) => (path, content)
        FeatureSource::File(path) => {
          let content = @fs.read_file_to_string(path) catch { _ => "" }
          (path, content)
        }
        FeatureSource::Parsed(path, _) => (path, "")
      }
      emit(sinks, make_source_envelope(uri, data))
    }
    let errors = cache.load_from_source(source)
    all_parse_errors.append(errors)
  }
  // Emit GherkinDocument envelopes
  if sinks.length() > 0 {
    for entry in cache.features() {
      let uri = entry.0
      let json : Json = {
        "gherkinDocument": {
          "uri": Json(uri),
          "comments": Json(([] : Array[Int32])),
        },
      }
      let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch {
        _ => continue
      }
      emit(sinks, envelope)
    }
  }
  // Emit ParseError envelopes
  if sinks.length() > 0 {
    for pe in all_parse_errors {
      let source_ref : Map[String, Json] = Map([])
      source_ref["uri"] = Json(pe.uri)
      match pe.line {
        Some(line) => source_ref["location"] = { "line": Json(line) }
        None => ()
      }
      let json : Json = {
        "parseError": {
          "source": Json(source_ref),
          "message": Json(pe.message),
        },
      }
      let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch {
        _ => continue
      }
      emit(sinks, envelope)
    }
  }
  let pickles = compile_pickles(cache)
  let locations : Map[String, String] = Map([])
  for pickle in pickles {
    if pickle_line(cache, pickle) is Some(line) {
      locations[pickle.id] = pickle.uri + ":" + line.to_string()
    }
  }
  // Emit Pickle envelopes
  if sinks.length() > 0 {
    for pickle in pickles {
      let json : Json = { "pickle": pickle.to_json() }
      let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch {
        _ => continue
      }
      emit(sinks, envelope)
    }
  }
  let filter = PickleFilter::new()
  let filter = if tag_expr != "" { filter.with_tags(tag_expr) } else { filter }
  let filter = if scenario_name != "" {
    filter.with_names([scenario_name])
  } else {
    filter
  }
  let filtered = filter.apply(pickles)
  // Build shared registry for envelope metadata
  let setup = @core.Setup::new()
  let world0 = factory()
  @core.World::configure(world0, setup)
  let registry = setup.step_registry()
  let custom_param_types = setup.custom_param_types()
  // Emit StepDefinition envelopes
  let id_gen = IdGenerator::new()
  if sinks.length() > 0 {
    let sd_envelopes = build_step_definition_envelopes(registry)
    for env in sd_envelopes {
      emit(sinks, env)
    }
  }
  // Emit ParameterType envelopes for custom parameter types
  if sinks.length() > 0 {
    for cpt in custom_param_types {
      let regex_json : Array[Json] = cpt.patterns.map(fn(p) { Json(p) })
      let json : Json = {
        "parameterType": {
          "id": Json(id_gen.next_param_type_id()),
          "name": Json(cpt.name),
          "regularExpressions": Json(regex_json),
          "preferForRegularExpressionMatch": Json(false),
          "useForSnippets": Json(true),
        },
      }
      let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch {
        _ => continue
      }
      emit(sinks, envelope)
    }
  }
  // Emit Hook envelopes
  if sinks.length() > 0 {
    let hook_reg = setup.hook_registry()
    for hook in hook_reg.hooks() {
      let source_ref : Map[String, Json] = Map([])
      match hook.source {
        Some(src) => {
          match src.uri {
            Some(uri) => source_ref["uri"] = Json(uri)
            None => ()
          }
          match src.line {
            Some(line) => source_ref["location"] = { "line": Json(line) }
            None => ()
          }
        }
        None => ()
      }
      let hook_type_str = match hook.type_ {
        @core.HookType::BeforeTestRun => "BEFORE_TEST_RUN"
        @core.HookType::AfterTestRun => "AFTER_TEST_RUN"
        @core.HookType::BeforeTestCase => "BEFORE_TEST_CASE"
        @core.HookType::AfterTestCase => "AFTER_TEST_CASE"
        @core.HookType::BeforeTestStep => "BEFORE_TEST_STEP"
        @core.HookType::AfterTestStep => "AFTER_TEST_STEP"
      }
      let json : Json = {
        "hook": {
          "id": Json(hook.id),
          "sourceReference": Json(source_ref),
          "type": Json(hook_type_str),
        },
      }
      let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch {
        _ => continue
      }
      emit(sinks, envelope)
    }
  }
  // Test planning phase
  let tc_mappings : Map[String, TestCaseMapping] = if sinks.length() > 0 {
    let tc_envelopes = build_test_cases(
      registry,
      setup.hook_registry(),
      filtered,
      id_gen,
    )
    for env in tc_envelopes {
      emit(sinks, env)
    }
    extract_test_case_mappings(tc_envelopes)
  } else {
    {}
  }
  // Emit TestRunStarted
  let run_id = id_gen.next("tr")
  if sinks.length() > 0 {
    emit(sinks, make_test_run_started_envelope(run_id))
  }
  // Execute before_test_run hooks
  let before_run_hooks = setup
    .hook_registry()
    .by_type(@core.HookType::BeforeTestRun)
  for hook in before_run_hooks {
    let trhs_id = id_gen.next("trhs")
    if sinks.length() > 0 {
      let json : Json = {
        "testRunHookStarted": {
          "id": Json(trhs_id),
          "testRunStartedId": Json(run_id),
          "hookId": Json(hook.id),
          "timestamp": {
            "seconds": Json((0 : Int32)),
            "nanos": Json((0 : Int32)),
          },
        },
      }
      let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch {
        _ => continue
      }
      emit(sinks, envelope)
    }
    let hook_ctx = @core.RunHookCtx::new()
    let result_status = try {
      match hook.handler {
        @core.HookHandler::RunHandler(h) => h(hook_ctx)
        _ => ()
      }
      "PASSED"
    } catch {
      _ => "FAILED"
    }
    if sinks.length() > 0 && hook_ctx.pending_attachments().length() > 0 {
      emit_run_hook_attachments(sinks, hook_ctx.pending_attachments(), trhs_id)
      hook_ctx.pending_attachments().clear()
    }
    if sinks.length() > 0 {
      let json : Json = {
        "testRunHookFinished": {
          "testRunHookStartedId": Json(trhs_id),
          "result": {
            "duration": {
              "seconds": Json((0 : Int32)),
              "nanos": Json((0 : Int32)),
            },
            "status": Json(result_status),
          },
          "timestamp": {
            "seconds": Json((0 : Int32)),
            "nanos": Json((0 : Int32)),
          },
        },
      }
      let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch {
        _ => continue
      }
      emit(sinks, envelope)
    }
  }
  {
    cache,
    filtered,
    locations,
    sinks,
    tc_mappings,
    setup,
    id_gen,
    run_id,
    all_parse_errors,
  }
}

///|
fn finish_run(
  prepared : PreparedRun,
  options : RunOptions,
  paired_results : Array[PickleResult],
  strict_output~ : Bool = false,
) -> (RunResult, Map[String, String]) raise SyncExecutionError {
  let cache = prepared.cache
  let locations = prepared.locations
  let sinks = prepared.sinks
  let setup = prepared.setup
  let id_gen = prepared.id_gen
  let run_id = prepared.run_id
  let all_parse_errors = prepared.all_parse_errors
  let results : Array[ScenarioResult] = paired_results.map(fn(pr) { pr.result })
  let retried_count = paired_results
    .iter()
    .fold(init=0, fn(acc, pr) { if pr.was_retried { acc + 1 } else { acc } })
  // Execute after_test_run hooks
  let run_errors : Array[@core.HookError] = []
  for r in results {
    if r.status != ScenarioStatus::Passed {
      let msg = match
        r.steps
        .iter()
        .find_first(fn(s) {
          match s.status {
            StepStatus::Failed(_) => true
            _ => false
          }
        }) {
        Some(s) =>
          match s.status {
            StepStatus::Failed(m) => m
            _ => "scenario failed"
          }
        None => "scenario failed"
      }
      run_errors.push(
        @core.HookError::ScenarioFailed(
          feature_name=r.feature_name,
          scenario_name=r.scenario_name,
          message=msg,
        ),
      )
    }
  }
  let run_hook_result : @core.HookResult = if run_errors.length() > 0 {
    @core.HookResult::Failed(run_errors)
  } else {
    @core.HookResult::Passed
  }
  let after_run_hooks = setup
    .hook_registry()
    .by_type(@core.HookType::AfterTestRun)
  for hook in after_run_hooks {
    let trhs_id = id_gen.next("trhs")
    if sinks.length() > 0 {
      let json : Json = {
        "testRunHookStarted": {
          "id": Json(trhs_id),
          "testRunStartedId": Json(run_id),
          "hookId": Json(hook.id),
          "timestamp": {
            "seconds": Json((0 : Int32)),
            "nanos": Json((0 : Int32)),
          },
        },
      }
      let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch {
        _ => continue
      }
      emit(sinks, envelope)
    }
    let hook_ctx = @core.RunHookCtx::new()
    let result_status = try {
      match hook.handler {
        @core.HookHandler::RunAfterHandler(h) => h(hook_ctx, run_hook_result)
        _ => ()
      }
      "PASSED"
    } catch {
      _ => "FAILED"
    }
    if sinks.length() > 0 && hook_ctx.pending_attachments().length() > 0 {
      emit_run_hook_attachments(sinks, hook_ctx.pending_attachments(), trhs_id)
      hook_ctx.pending_attachments().clear()
    }
    if sinks.length() > 0 {
      let json : Json = {
        "testRunHookFinished": {
          "testRunHookStartedId": Json(trhs_id),
          "result": {
            "duration": {
              "seconds": Json((0 : Int32)),
              "nanos": Json((0 : Int32)),
            },
            "status": Json(result_status),
          },
          "timestamp": {
            "seconds": Json((0 : Int32)),
            "nanos": Json((0 : Int32)),
          },
        },
      }
      let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch {
        _ => continue
      }
      emit(sinks, envelope)
    }
  }
  // Emit TestRunFinished
  if sinks.length() > 0 {
    let all_passed = results
      .iter()
      .all(fn(r) { r.status == ScenarioStatus::Passed })
    emit(sinks, make_test_run_finished_envelope(all_passed, run_id))
  }
  let feature_results = group_by_feature(results, cache)
  let summary = compute_summary(feature_results, retried=retried_count)
  // Write formatter output to configured destinations
  for entry in options.get_formatters() {
    write_formatter_output(entry, strict=strict_output)
  }
  (
    { features: feature_results, summary, parse_errors: all_parse_errors, },
    locations,
  )
}

///|
fn[W : @core.World] run_prepared_sync(
  factory : () -> W,
  prepared : PreparedRun,
  options : RunOptions,
) -> Array[PickleResult] raise Error {
  run_pickles_sequential(
    factory,
    prepared.filtered,
    sinks=prepared.sinks,
    tc_mappings=prepared.tc_mappings,
    id_gen=prepared.id_gen,
    retries=options.get_retries(),
    dry_run=options.is_dry_run(),
    skip_tags=options.get_skip_tags(),
  )
}

///|
/// Run features sequentially without an event loop.
/// Rejects parallel execution before effects. Formatter file and stderr write
/// failures raise `SyncExecutionError::HostIoFailed`.
pub fn[W : @core.World] run_sync(
  factory : () -> W,
  options : RunOptions,
) -> RunResult raise Error {
  run_sync_detailed(factory, options).0
}

///|
fn[W : @core.World] run_sync_detailed(
  factory : () -> W,
  options : RunOptions,
) -> (RunResult, Map[String, String]) raise Error {
  if options.is_parallel() {
    raise SyncExecutionError::ParallelNotSupported
  }
  let prepared = prepare_run(factory, options)
  finish_run(
    prepared,
    options,
    run_prepared_sync(factory, prepared, options),
    strict_output=true,
  )
}

///|
/// Run features synchronously, raising a structured report for any failure.
pub fn[W : @core.World] run_or_fail_sync(
  factory : () -> W,
  options : RunOptions,
) -> Unit raise Error {
  let (result, locations) = run_sync_detailed(factory, options)
  check_run_result(result, locations, options)
}

///|
fn check_run_result(
  result : RunResult,
  locations : Map[String, String],
  options : RunOptions,
) -> Unit raise Error {
  if result.parse_errors.length() > 0 ||
    result.summary.failed > 0 ||
    result.summary.undefined > 0 ||
    result.summary.pending > 0 {
    let errors : Array[@core.MoonspecError] = result.parse_errors.map(fn(pe) {
      @core.parse_failed_error(uri=pe.uri, line=pe.line, message=pe.message)
    })
    errors.append(collect_scenario_errors(result, locations))
    let summary = format_run_summary(
      result.summary,
      parse_errors=result.parse_errors.length(),
    )
    raise @core.run_failed_error(
      summary~,
      errors~,
      color=@core.color_enabled(no_color=options.get_no_color()),
    )
  }
}
