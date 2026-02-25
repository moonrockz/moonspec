///|
/// Error raised to signal a failed attempt that should be retried.
priv suberror RetryableFailure {
  RetryableFailure(ScenarioResult)
}

///|
/// Broadcast an envelope to all sinks.
fn emit(
  sinks : Array[&@core.MessageSink],
  envelope : @cucumber_messages.Envelope,
) -> Unit {
  for sink in sinks {
    sink.on_message(envelope)
  }
}

///|
fn make_meta_envelope() -> @cucumber_messages.Envelope {
  let json : Json = {
    "meta": {
      "protocolVersion": "25.0.1".to_json(),
      "implementation": {
        "name": "moonspec".to_json(),
        "version": "0.3.2".to_json(),
      },
      "runtime": { "name": "moonbit".to_json() },
      "os": { "name": "unknown".to_json() },
      "cpu": { "name": "unknown".to_json() },
    },
  }
  @json.from_json(json) catch {
    _ => panic()
  }
}

///|
fn make_source_envelope(
  uri : String,
  data : String,
) -> @cucumber_messages.Envelope {
  let json : Json = {
    "source": {
      "uri": uri.to_json(),
      "data": data.to_json(),
      "mediaType": "text/x.cucumber.gherkin+plain".to_json(),
    },
  }
  @json.from_json(json) catch {
    _ => panic()
  }
}

///|
fn make_test_run_started_envelope(id : String) -> @cucumber_messages.Envelope {
  let json : Json = {
    "testRunStarted": {
      "timestamp": {
        "seconds": (0 : Int).to_json(),
        "nanos": (0 : Int).to_json(),
      },
      "id": id.to_json(),
    },
  }
  @json.from_json(json) catch {
    _ => panic()
  }
}

///|
fn make_test_run_finished_envelope(
  success : Bool,
  run_id : String,
) -> @cucumber_messages.Envelope {
  let json : Json = {
    "testRunFinished": {
      "success": success.to_json(),
      "timestamp": {
        "seconds": (0 : Int).to_json(),
        "nanos": (0 : Int).to_json(),
      },
      "testRunStartedId": run_id.to_json(),
    },
  }
  @json.from_json(json) catch {
    _ => panic()
  }
}

///|
fn make_test_case_started_envelope(
  id : String,
  test_case_id : String,
  attempt? : Int = 0,
) -> @cucumber_messages.Envelope {
  let json : Json = {
    "testCaseStarted": {
      "attempt": attempt.to_json(),
      "id": id.to_json(),
      "testCaseId": test_case_id.to_json(),
      "timestamp": {
        "seconds": (0 : Int).to_json(),
        "nanos": (0 : Int).to_json(),
      },
    },
  }
  @json.from_json(json) catch {
    _ => panic()
  }
}

///|
fn make_test_case_finished_envelope(
  test_case_started_id : String,
  will_be_retried? : Bool = false,
) -> @cucumber_messages.Envelope {
  let json : Json = {
    "testCaseFinished": {
      "testCaseStartedId": test_case_started_id.to_json(),
      "timestamp": {
        "seconds": (0 : Int).to_json(),
        "nanos": (0 : Int).to_json(),
      },
      "willBeRetried": will_be_retried.to_json(),
    },
  }
  @json.from_json(json) catch {
    _ => panic()
  }
}

///|
fn make_test_step_started_envelope(
  test_case_started_id : String,
  test_step_id : String,
) -> @cucumber_messages.Envelope {
  let json : Json = {
    "testStepStarted": {
      "testCaseStartedId": test_case_started_id.to_json(),
      "testStepId": test_step_id.to_json(),
      "timestamp": {
        "seconds": (0 : Int).to_json(),
        "nanos": (0 : Int).to_json(),
      },
    },
  }
  @json.from_json(json) catch {
    _ => panic()
  }
}

///|
fn make_test_step_finished_envelope(
  test_case_started_id : String,
  test_step_id : String,
  status : String,
  message : String?,
) -> @cucumber_messages.Envelope {
  let result_json : Map[String, Json] = {}
  result_json["duration"] = {
    "seconds": (0 : Int).to_json(),
    "nanos": (0 : Int).to_json(),
  }
  result_json["status"] = status.to_json()
  match message {
    Some(msg) => result_json["message"] = msg.to_json()
    None => ()
  }
  let json : Json = {
    "testStepFinished": {
      "testCaseStartedId": test_case_started_id.to_json(),
      "testStepId": test_step_id.to_json(),
      "testStepResult": result_json.to_json(),
      "timestamp": {
        "seconds": (0 : Int).to_json(),
        "nanos": (0 : Int).to_json(),
      },
    },
  }
  @json.from_json(json) catch {
    _ => panic()
  }
}

///|
fn make_attachment_envelope(
  body : String,
  content_encoding : String,
  media_type : String,
  file_name : String?,
  test_case_started_id : String?,
  test_step_id : String?,
) -> @cucumber_messages.Envelope {
  let json_map : Map[String, Json] = {}
  json_map["body"] = body.to_json()
  json_map["contentEncoding"] = content_encoding.to_json()
  json_map["mediaType"] = media_type.to_json()
  match file_name {
    Some(f) => json_map["fileName"] = f.to_json()
    None => ()
  }
  match test_case_started_id {
    Some(id) => json_map["testCaseStartedId"] = id.to_json()
    None => ()
  }
  match test_step_id {
    Some(id) => json_map["testStepId"] = id.to_json()
    None => ()
  }
  json_map["timestamp"] = (
    { "seconds": (0 : Int).to_json(), "nanos": (0 : Int).to_json() } : Json)
  let json : Json = { "attachment": json_map.to_json() }
  @json.from_json(json) catch {
    _ => panic()
  }
}

///|
fn make_external_attachment_envelope(
  url : String,
  media_type : String,
  test_case_started_id : String?,
  test_step_id : String?,
) -> @cucumber_messages.Envelope {
  let json_map : Map[String, Json] = {}
  json_map["url"] = url.to_json()
  json_map["mediaType"] = media_type.to_json()
  match test_case_started_id {
    Some(id) => json_map["testCaseStartedId"] = id.to_json()
    None => ()
  }
  match test_step_id {
    Some(id) => json_map["testStepId"] = id.to_json()
    None => ()
  }
  json_map["timestamp"] = (
    { "seconds": (0 : Int).to_json(), "nanos": (0 : Int).to_json() } : Json)
  let json : Json = { "externalAttachment": json_map.to_json() }
  @json.from_json(json) catch {
    _ => panic()
  }
}

///|
/// Drain pending attachments from a run-level hook and emit as envelopes.
fn emit_run_hook_attachments(
  sinks : Array[&@core.MessageSink],
  attachments : Array[@core.PendingAttachment],
  test_run_hook_started_id : String,
) -> Unit {
  for att in attachments {
    match att {
      @core.PendingAttachment::Embedded(
        body~,
        encoding~,
        media_type~,
        file_name~
      ) => {
        let enc_str = encoding.to_json().stringify()
        let enc_clean = enc_str.substring(start=1, end=enc_str.length() - 1)
        let json_map : Map[String, Json] = {}
        json_map["body"] = body.to_json()
        json_map["contentEncoding"] = enc_clean.to_json()
        json_map["mediaType"] = media_type.to_json()
        match file_name {
          Some(f) => json_map["fileName"] = f.to_json()
          None => ()
        }
        json_map["testRunHookStartedId"] = test_run_hook_started_id.to_json()
        json_map["timestamp"] = (
          { "seconds": (0 : Int).to_json(), "nanos": (0 : Int).to_json() } :
          Json)
        let json : Json = { "attachment": json_map.to_json() }
        let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch {
          _ => continue
        }
        emit(sinks, envelope)
      }
      @core.PendingAttachment::External(url~, media_type~) => {
        let json_map : Map[String, Json] = {}
        json_map["url"] = url.to_json()
        json_map["mediaType"] = media_type.to_json()
        json_map["testRunHookStartedId"] = test_run_hook_started_id.to_json()
        json_map["timestamp"] = (
          { "seconds": (0 : Int).to_json(), "nanos": (0 : Int).to_json() } :
          Json)
        let json : Json = { "externalAttachment": json_map.to_json() }
        let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch {
          _ => continue
        }
        emit(sinks, envelope)
      }
    }
  }
}

///|
/// Map a StepStatus to a cucumber-messages status string.
fn step_status_to_string(status : StepStatus) -> String {
  match status {
    StepStatus::Passed => "PASSED"
    StepStatus::Failed(_) => "FAILED"
    StepStatus::Skipped(_) => "SKIPPED"
    StepStatus::Undefined => "UNDEFINED"
    StepStatus::Pending => "PENDING"
  }
}

///|
/// Map a StepStatus to a failure message (if any).
fn step_status_message(status : StepStatus) -> String? {
  match status {
    StepStatus::Failed(msg) => Some(msg)
    StepStatus::Skipped(reason) => reason
    _ => None
  }
}

///|
/// Mapping from pickle to its test case ID and test step IDs.
priv struct TestCaseMapping {
  test_case_id : String
  test_step_ids : Array[String]
}

///|
/// Extract test case mappings from test case envelopes, keyed by pickle ID.
fn extract_test_case_mappings(
  tc_envelopes : Array[@cucumber_messages.Envelope],
) -> Map[String, TestCaseMapping] {
  let mappings : Map[String, TestCaseMapping] = {}
  for env in tc_envelopes {
    match env {
      @cucumber_messages.Envelope::TestCase(tc) => {
        let step_ids : Array[String] = []
        for ts in tc.testSteps {
          step_ids.push(ts.id)
        }
        mappings[tc.pickleId] = { test_case_id: tc.id, test_step_ids: step_ids }
      }
      _ => ()
    }
  }
  mappings
}

///|
/// Parse a retry count from pickle tags.
///
/// Scans for a tag matching `@retry(N)` where N is a non-negative integer.
/// Returns `Some(n)` for the first match, or `None` if no retry tag is found.
/// Invalid formats like `@retry()`, `@retry(abc)`, or `@retry(-1)` are ignored.
///
/// ```
/// parse_retry_tag(["@smoke", "@retry(3)"]) // => Some(3)
/// parse_retry_tag(["@smoke", "@slow"])      // => None
/// ```
fn parse_retry_tag(tags : Array[String]) -> Int? {
  let max_retries = 100
  for tag in tags {
    let n : Int = lexmatch tag with longest {
      ("@retry" "[(]" ("[0-9]+" as digits) "[)]") => {
        let parsed = @strconv.parse_int(digits.to_string()) catch { _ => 0 }
        if parsed > max_retries {
          max_retries
        } else {
          parsed
        }
      }
      _ => continue
    }
    return Some(n)
  }
  None
}

///|
/// Check if a pickle's tags match any configured skip tag.
///
/// Scans tags for matches against the skip tag list. Supports two formats:
/// - Bare tag: `@skip` → reason is the tag name without `@` (e.g., `"skip"`)
/// - Tag with reason: `@skip("reason")` → extracts the quoted reason string
///
/// Returns `Some(reason)` for the first match, or `None` if no skip tag found.
/// Invalid reason formats (empty parens, unquoted) fall back to the tag name.
///
/// ```
/// parse_skip_tag(["@skip(\"flaky\")"], ["@skip"]) // => Some("flaky")
/// parse_skip_tag(["@smoke"], ["@skip"])            // => None
/// ```
fn parse_skip_tag(tags : Array[String], skip_tags : Array[String]) -> String? {
  for tag in tags {
    let (name, reason) : (String, String?) = lexmatch tag with longest {
      ("@" ("[a-zA-Z_][a-zA-Z0-9_]*" as n) "[(]\"" ("[^\"]+" as r) "\"[)]") =>
        (n.to_string(), Some(r.to_string()))
      ("@" ("[a-zA-Z_][a-zA-Z0-9_]*" as n) "[(]" "[^)]*" "[)]") =>
        (n.to_string(), None)
      ("@" ("[a-zA-Z_][a-zA-Z0-9_]*" as n)) => (n.to_string(), None)
      _ => continue
    }
    let full_tag = "@" + name
    for skip in skip_tags {
      if full_tag == skip {
        return Some(reason.unwrap_or(name))
      }
    }
  }
  None
}

///|
/// Run all features and collect results.
///
/// A fresh world is created per scenario via `factory()` for isolation.
/// When `parallel` is greater than 0, pickles are executed concurrently using
/// `@async.all()` with bounded concurrency. Otherwise, pickles run sequentially.
/// Lifecycle hooks registered via `Setup` are called automatically when present.
pub async fn[W : @core.World] run(
  factory : () -> W,
  options : RunOptions,
) -> RunResult {
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
          "uri": uri.to_json(),
          "comments": ([] : Array[Int]).to_json(),
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
      let source_ref : Map[String, Json] = {}
      source_ref["uri"] = pe.uri.to_json()
      match pe.line {
        Some(line) => source_ref["location"] = { "line": line.to_json() }
        None => ()
      }
      let json : Json = {
        "parseError": {
          "source": source_ref.to_json(),
          "message": pe.message.to_json(),
        },
      }
      let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch {
        _ => continue
      }
      emit(sinks, envelope)
    }
  }
  let pickles = compile_pickles(cache)
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
      let regex_json : Array[Json] = cpt.patterns.map(fn(p) { p.to_json() })
      let json : Json = {
        "parameterType": {
          "id": id_gen.next_param_type_id().to_json(),
          "name": cpt.name.to_json(),
          "regularExpressions": regex_json.to_json(),
          "preferForRegularExpressionMatch": false.to_json(),
          "useForSnippets": true.to_json(),
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
      let source_ref : Map[String, Json] = {}
      match hook.source {
        Some(src) => {
          match src.uri {
            Some(uri) => source_ref["uri"] = uri.to_json()
            None => ()
          }
          match src.line {
            Some(line) => source_ref["location"] = { "line": line.to_json() }
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
          "id": hook.id.to_json(),
          "sourceReference": source_ref.to_json(),
          "type": hook_type_str.to_json(),
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
          "id": trhs_id.to_json(),
          "testRunStartedId": run_id.to_json(),
          "hookId": hook.id.to_json(),
          "timestamp": {
            "seconds": (0 : Int).to_json(),
            "nanos": (0 : Int).to_json(),
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
          "testRunHookStartedId": trhs_id.to_json(),
          "result": {
            "duration": {
              "seconds": (0 : Int).to_json(),
              "nanos": (0 : Int).to_json(),
            },
            "status": result_status.to_json(),
          },
          "timestamp": {
            "seconds": (0 : Int).to_json(),
            "nanos": (0 : Int).to_json(),
          },
        },
      }
      let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch {
        _ => continue
      }
      emit(sinks, envelope)
    }
  }
  let retries = options.get_retries()
  let dry_run = options.is_dry_run()
  let skip_tags = options.get_skip_tags()
  let paired_results = if options.is_parallel() {
    run_pickles_parallel(
      factory,
      filtered,
      max_concurrent=options.get_max_concurrent(),
      sinks~,
      tc_mappings~,
      id_gen~,
      retries~,
      dry_run~,
      skip_tags~,
    )
  } else {
    run_pickles_sequential(
      factory,
      filtered,
      sinks~,
      tc_mappings~,
      id_gen~,
      retries~,
      dry_run~,
      skip_tags~,
    )
  }
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
          "id": trhs_id.to_json(),
          "testRunStartedId": run_id.to_json(),
          "hookId": hook.id.to_json(),
          "timestamp": {
            "seconds": (0 : Int).to_json(),
            "nanos": (0 : Int).to_json(),
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
          "testRunHookStartedId": trhs_id.to_json(),
          "result": {
            "duration": {
              "seconds": (0 : Int).to_json(),
              "nanos": (0 : Int).to_json(),
            },
            "status": result_status.to_json(),
          },
          "timestamp": {
            "seconds": (0 : Int).to_json(),
            "nanos": (0 : Int).to_json(),
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
  { features: feature_results, summary, parse_errors: all_parse_errors }
}

///|
/// Run all features, raising MoonspecError on any failure.
///
/// This is the ergonomic test API. Use in generated tests and manual tests
/// where you want structured error output instead of manual result inspection.
pub async fn[W : @core.World] run_or_fail(
  factory : () -> W,
  options : RunOptions,
) -> RunResult {
  let result = run(factory, options)
  if result.parse_errors.length() > 0 ||
    result.summary.failed > 0 ||
    result.summary.undefined > 0 ||
    result.summary.pending > 0 {
    let errors = collect_scenario_errors(result)
    let summary = format_run_summary(result.summary)
    raise @core.run_failed_error(summary~, errors~)
  }
  result
}

///|
/// Collect MoonspecError for each non-passing scenario.
fn collect_scenario_errors(result : RunResult) -> Array[@core.MoonspecError] {
  let errors : Array[@core.MoonspecError] = []
  for feature in result.features {
    for scenario in feature.scenarios {
      match scenario.status {
        ScenarioStatus::Passed => continue
        _ => {
          let step_errors : Array[@core.MoonspecError] = []
          for step in scenario.steps {
            match step.diagnostic {
              Some(@core.UndefinedStep(..) as e) => step_errors.push(e)
              Some(@core.PendingStep(..) as e) => step_errors.push(e)
              Some(@core.MoonspecError::StepFailed(..) as e) =>
                step_errors.push(e)
              _ => ()
            }
          }
          errors.push(
            @core.scenario_failed_error(
              scenario=scenario.scenario_name,
              feature=feature.name,
              errors=step_errors,
            ),
          )
        }
      }
    }
  }
  errors
}

///|
fn format_run_summary(summary : RunSummary) -> String {
  let parts : Array[String] = []
  if summary.failed > 0 {
    parts.push(summary.failed.to_string() + " failed")
  }
  if summary.undefined > 0 {
    parts.push(summary.undefined.to_string() + " undefined")
  }
  if summary.pending > 0 {
    parts.push(summary.pending.to_string() + " pending")
  }
  if summary.retried > 0 {
    parts.push(summary.retried.to_string() + " retried")
  }
  parts.push(summary.total_scenarios.to_string() + " total")
  parts.join(", ")
}

///|
/// Run pickles sequentially (the default path).
async fn[W : @core.World] run_pickles_sequential(
  factory : () -> W,
  pickles : Array[@cucumber_messages.Pickle],
  sinks? : Array[&@core.MessageSink] = [],
  tc_mappings? : Map[String, TestCaseMapping] = {},
  id_gen? : IdGenerator = IdGenerator::new(),
  retries? : Int = 0,
  dry_run? : Bool = false,
  skip_tags? : Array[String] = [],
) -> Array[PickleResult] {
  let results : Array[PickleResult] = []
  for pickle in pickles {
    let result = execute_pickle(
      factory,
      pickle,
      sinks~,
      tc_mappings~,
      id_gen~,
      retries~,
      dry_run~,
      skip_tags~,
    )
    results.push(result)
  }
  results
}

///|
/// Build a PickleResult for a scenario that should be skipped.
///
/// Emits `TestCaseStarted`, per-step `TestStepStarted`/`TestStepFinished`,
/// and `TestCaseFinished` envelopes when sinks are present. All steps are
/// marked `SKIPPED` with the given reason.
fn make_skipped_pickle_result(
  pickle : @cucumber_messages.Pickle,
  tags : Array[String],
  reason : String,
  mapping : TestCaseMapping?,
  test_case_id : String,
  test_step_ids : Array[String],
  sinks : Array[&@core.MessageSink],
  id_gen : IdGenerator,
) -> PickleResult {
  let step_results : Array[StepResult] = pickle.steps.map(fn(step) {
    let keyword = match step.type_ {
      Some(@cucumber_messages.PickleStepType::Context) => "Given "
      Some(@cucumber_messages.PickleStepType::Action) => "When "
      Some(@cucumber_messages.PickleStepType::Outcome) => "Then "
      _ => "* "
    }
    {
      text: step.text,
      keyword,
      status: StepStatus::Skipped(Some(reason)),
      duration_ms: 0L,
      diagnostic: None,
    }
  })
  // Emit TestCaseStarted/Finished if sinks present
  match mapping {
    Some(_) => {
      let tcs_id = id_gen.next("tcs")
      if sinks.length() > 0 {
        emit(sinks, make_test_case_started_envelope(tcs_id, test_case_id))
        let mut si = 0
        for _step in pickle.steps {
          let ts_id = if si < test_step_ids.length() {
            test_step_ids[si]
          } else {
            ""
          }
          si += 1
          emit(sinks, make_test_step_started_envelope(tcs_id, ts_id))
          emit(
            sinks,
            make_test_step_finished_envelope(
              tcs_id,
              ts_id,
              "SKIPPED",
              Some(reason),
            ),
          )
        }
        emit(sinks, make_test_case_finished_envelope(tcs_id))
      }
    }
    None => ()
  }
  let result : ScenarioResult = {
    feature_name: pickle.uri,
    scenario_name: pickle.name,
    pickle_id: pickle.id,
    tags,
    steps: step_results,
    status: ScenarioStatus::Skipped(Some(reason)),
    duration_ms: 0L,
  }
  { result, was_retried: false }
}

///|
/// Execute a single pickle with a fresh world, with optional retry.
///
/// When `retries > 0` or the pickle has a `@retry(N)` tag, failed scenarios are
/// re-executed using `@async.retry(Immediate)`. Each attempt creates a fresh
/// World instance via `factory()` and emits its own `TestCaseStarted`/
/// `TestCaseFinished` envelope pair with the correct `attempt` number and
/// `willBeRetried` flag.
///
/// The `@retry(N)` tag takes priority over the global `retries` parameter.
/// Returns a `PickleResult` containing the final attempt's `ScenarioResult` and
/// a flag indicating whether the scenario was retried.
async fn[W : @core.World] execute_pickle(
  factory : () -> W,
  pickle : @cucumber_messages.Pickle,
  sinks? : Array[&@core.MessageSink] = [],
  tc_mappings? : Map[String, TestCaseMapping] = {},
  id_gen? : IdGenerator = IdGenerator::new(),
  retries? : Int = 0,
  dry_run? : Bool = false,
  skip_tags? : Array[String] = [],
) -> PickleResult {
  let tags = pickle.tags.map(fn(t) { t.name })
  let tag_retries = parse_retry_tag(tags)
  let max_retries = match tag_retries {
    Some(n) => n
    None => retries
  }
  let mapping = tc_mappings.get(pickle.id)
  let test_case_id = match mapping {
    Some(m) => m.test_case_id
    None => ""
  }
  let test_step_ids = match mapping {
    Some(m) => m.test_step_ids
    None => []
  }
  // Check if scenario should be skipped via tags
  let skip_reason = parse_skip_tag(tags, skip_tags)
  if skip_reason is Some(reason) {
    return make_skipped_pickle_result(
      pickle, tags, reason, mapping, test_case_id, test_step_ids, sinks, id_gen,
    )
  }
  let attempt : Ref[Int] = { val: 0 }
  let execute_attempt : async () -> ScenarioResult = () => {
    let current_attempt = attempt.val
    attempt.val += 1
    let world = factory()
    let setup = @core.Setup::new()
    @core.World::configure(world, setup)
    let registry = setup.step_registry()
    let hook_registry = setup.hook_registry()
    // Emit TestCaseStarted
    let tcs_id = match mapping {
      Some(_) => {
        let tcs_id = id_gen.next("tcs")
        if sinks.length() > 0 {
          emit(
            sinks,
            make_test_case_started_envelope(
              tcs_id,
              test_case_id,
              attempt=current_attempt,
            ),
          )
        }
        Some(tcs_id)
      }
      None => None
    }
    let result = execute_scenario(
      registry,
      feature_name=pickle.uri,
      scenario_name=pickle.name,
      pickle_id=pickle.id,
      tags~,
      steps=pickle.steps,
      hook_registry~,
      sinks~,
      test_case_started_id=tcs_id.unwrap_or(""),
      test_step_ids~,
      dry_run~,
    )
    // Only retry on actual failures — not Undefined, Pending, or Skipped
    let is_failed = result.status == ScenarioStatus::Failed
    let has_retries_left = current_attempt < max_retries
    // Emit TestCaseFinished
    match tcs_id {
      Some(id) =>
        if sinks.length() > 0 {
          emit(
            sinks,
            make_test_case_finished_envelope(
              id,
              will_be_retried=is_failed && has_retries_left,
            ),
          )
        }
      None => ()
    }
    // If failed and retries remain, raise to trigger @async.retry
    if is_failed && has_retries_left {
      raise RetryableFailure(result)
    }
    result
  }
  let result = if max_retries > 0 && not(dry_run) {
    @async.retry(
      @async.Immediate,
      max_retry=max_retries,
      fatal_error=fn(e) {
        match e {
          RetryableFailure(_) => false
          _ => true
        }
      },
      execute_attempt,
    ) catch {
      RetryableFailure(r) => r
      _ => panic()
    }
  } else {
    execute_attempt()
  }
  let was_retried = attempt.val > 1
  { result, was_retried }
}

///|
/// Group scenario results by feature URI and look up feature names from cache.
fn group_by_feature(
  results : Array[ScenarioResult],
  cache : FeatureCache,
) -> Array[FeatureResult] {
  let groups : Map[String, Array[ScenarioResult]] = {}
  let order : Array[String] = []
  for r in results {
    let key = r.feature_name
    match groups.get(key) {
      Some(arr) => arr.push(r)
      None => {
        groups.set(key, [r])
        order.push(key)
      }
    }
  }
  let feature_results : Array[FeatureResult] = []
  for uri in order {
    let scenarios = match groups.get(uri) {
      Some(arr) => arr
      None => []
    }
    let name = match cache.get(uri) {
      Some(f) => f.name
      None => uri
    }
    feature_results.push({ name, scenarios, duration_ms: 0L })
  }
  feature_results
}

///|
fn compute_summary(
  features : Array[FeatureResult],
  retried? : Int = 0,
) -> RunSummary {
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
        ScenarioStatus::Skipped(_) => skipped = skipped + 1
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
    retried,
    duration_ms: 0L,
  }
}
