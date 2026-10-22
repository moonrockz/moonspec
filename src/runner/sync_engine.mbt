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
/// Write formatter output to the configured destination.
fn write_formatter_output(
  entry : FormatterEntry,
  strict~ : Bool = false,
) -> Unit raise SyncExecutionError {
  let content = entry.sink.output()
  if content.length() == 0 {
    return
  }
  match entry.dest {
    Stdout => println(content)
    Stderr => write_host_output("/dev/stderr", content + "\n", strict~)
    File(path) => write_host_output(path, content, strict~)
  }
}

///|
fn write_host_output(
  path : String,
  content : String,
  strict~ : Bool,
) -> Unit raise SyncExecutionError {
  @fs.write_string_to_file(path, content) catch {
    @fs.IOError(message) =>
      if strict {
        raise SyncExecutionError::HostIoFailed(
          operation="write",
          path~,
          message~,
        )
      }
  }
}

///|
fn make_meta_envelope() -> @cucumber_messages.Envelope {
  let json : Json = {
    "meta": {
      "protocolVersion": Json("25.0.1"),
      "implementation": { "name": Json("moonspec"), "version": Json("0.4.0") },
      "runtime": { "name": Json("moonbit") },
      "os": { "name": Json("unknown") },
      "cpu": { "name": Json("unknown") },
    },
  }
  @json.from_json(json) catch {
    _ => panic()
  }
}

///|
/// Cucumber Messages media type for a Gherkin source, based on its URI.
fn gherkin_media_type(uri : String) -> String {
  if uri.has_suffix(".feature.md") {
    "text/x.cucumber.gherkin+markdown"
  } else {
    "text/x.cucumber.gherkin+plain"
  }
}

///|
fn make_source_envelope(
  uri : String,
  data : String,
) -> @cucumber_messages.Envelope {
  let json : Json = {
    "source": {
      "uri": Json(uri),
      "data": Json(data),
      "mediaType": Json(gherkin_media_type(uri)),
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
      "timestamp": { "seconds": Json((0 : Int32)), "nanos": Json((0 : Int32)) },
      "id": Json(id),
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
      "success": Json(success),
      "timestamp": { "seconds": Json((0 : Int32)), "nanos": Json((0 : Int32)) },
      "testRunStartedId": Json(run_id),
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
  attempt~ : Int32 = 0,
) -> @cucumber_messages.Envelope {
  let json : Json = {
    "testCaseStarted": {
      "attempt": Json(attempt),
      "id": Json(id),
      "testCaseId": Json(test_case_id),
      "timestamp": { "seconds": Json((0 : Int32)), "nanos": Json((0 : Int32)) },
    },
  }
  @json.from_json(json) catch {
    _ => panic()
  }
}

///|
fn make_test_case_finished_envelope(
  test_case_started_id : String,
  will_be_retried~ : Bool = false,
) -> @cucumber_messages.Envelope {
  let json : Json = {
    "testCaseFinished": {
      "testCaseStartedId": Json(test_case_started_id),
      "timestamp": { "seconds": Json((0 : Int32)), "nanos": Json((0 : Int32)) },
      "willBeRetried": Json(will_be_retried),
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
      "testCaseStartedId": Json(test_case_started_id),
      "testStepId": Json(test_step_id),
      "timestamp": { "seconds": Json((0 : Int32)), "nanos": Json((0 : Int32)) },
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
  let result_json : Map[String, Json] = Map([])
  result_json["duration"] = {
    "seconds": Json((0 : Int32)),
    "nanos": Json((0 : Int32)),
  }
  result_json["status"] = Json(status)
  match message {
    Some(msg) => result_json["message"] = Json(msg)
    None => ()
  }
  let json : Json = {
    "testStepFinished": {
      "testCaseStartedId": Json(test_case_started_id),
      "testStepId": Json(test_step_id),
      "testStepResult": Json(result_json),
      "timestamp": { "seconds": Json((0 : Int32)), "nanos": Json((0 : Int32)) },
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
  let json_map : Map[String, Json] = Map([])
  json_map["body"] = Json(body)
  json_map["contentEncoding"] = Json(content_encoding)
  json_map["mediaType"] = Json(media_type)
  match file_name {
    Some(f) => json_map["fileName"] = Json(f)
    None => ()
  }
  match test_case_started_id {
    Some(id) => json_map["testCaseStartedId"] = Json(id)
    None => ()
  }
  match test_step_id {
    Some(id) => json_map["testStepId"] = Json(id)
    None => ()
  }
  json_map["timestamp"] = (
    { "seconds": Json((0 : Int32)), "nanos": Json((0 : Int32)) } : Json)
  let json : Json = { "attachment": Json(json_map) }
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
  let json_map : Map[String, Json] = Map([])
  json_map["url"] = Json(url)
  json_map["mediaType"] = Json(media_type)
  match test_case_started_id {
    Some(id) => json_map["testCaseStartedId"] = Json(id)
    None => ()
  }
  match test_step_id {
    Some(id) => json_map["testStepId"] = Json(id)
    None => ()
  }
  json_map["timestamp"] = (
    { "seconds": Json((0 : Int32)), "nanos": Json((0 : Int32)) } : Json)
  let json : Json = { "externalAttachment": Json(json_map) }
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
        let enc_clean = enc_str[1:enc_str.length() - 1].to_owned()
        let json_map : Map[String, Json] = Map([])
        json_map["body"] = Json(body)
        json_map["contentEncoding"] = Json(enc_clean)
        json_map["mediaType"] = Json(media_type)
        match file_name {
          Some(f) => json_map["fileName"] = Json(f)
          None => ()
        }
        json_map["testRunHookStartedId"] = Json(test_run_hook_started_id)
        json_map["timestamp"] = (
          { "seconds": Json((0 : Int32)), "nanos": Json((0 : Int32)) } : Json)
        let json : Json = { "attachment": Json(json_map) }
        let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch {
          _ => continue
        }
        emit(sinks, envelope)
      }
      @core.PendingAttachment::External(url~, media_type~) => {
        let json_map : Map[String, Json] = Map([])
        json_map["url"] = Json(url)
        json_map["mediaType"] = Json(media_type)
        json_map["testRunHookStartedId"] = Json(test_run_hook_started_id)
        json_map["timestamp"] = (
          { "seconds": Json((0 : Int32)), "nanos": Json((0 : Int32)) } : Json)
        let json : Json = { "externalAttachment": Json(json_map) }
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
  regular_step_ids : Array[String]
}

///|
/// Extract test case mappings from test case envelopes, keyed by pickle ID.
fn extract_test_case_mappings(
  tc_envelopes : Array[@cucumber_messages.Envelope],
) -> Map[String, TestCaseMapping] {
  let mappings : Map[String, TestCaseMapping] = Map([])
  for env in tc_envelopes {
    match env {
      @cucumber_messages.Envelope::TestCase(tc) => {
        let step_ids : Array[String] = []
        let regular_step_ids : Array[String] = []
        for ts in tc.testSteps {
          step_ids.push(ts.id)
          if ts.pickleStepId is Some(_) {
            regular_step_ids.push(ts.id)
          }
        }
        mappings[tc.pickleId] = {
          test_case_id: tc.id,
          test_step_ids: step_ids,
          regular_step_ids,
        }
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
fn parse_retry_tag(tags : Array[String]) -> Int32? {
  let max_retries = 100
  for tag in tags {
    let n : Int32 = lexmatch tag with longest {
      re"^@retry\([0-9]+\)$" as matched => {
        let digits = matched["@retry(".length():matched.length() - 1]
        let parsed = @string.parse_int(digits) catch { _ => 0 }
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
/// Find the line of the scenario, or of the Examples row, that a pickle was
/// compiled from.
fn pickle_line(
  cache : FeatureCache,
  pickle : @cucumber_messages.Pickle,
) -> Int32? {
  guard cache.get(pickle.uri) is Some(feature) else { return None }
  guard pickle.astNodeIds.get(0) is Some(scenario_id) else { return None }
  let scenarios : Array[@gherkin.Scenario] = []
  for child in feature.children {
    match child {
      Scenario(s) => scenarios.push(s)
      Rule(rule) =>
        for rule_child in rule.children {
          if rule_child is Scenario(s) {
            scenarios.push(s)
          }
        }
      _ => ()
    }
  }
  for scenario in scenarios {
    if scenario.id != scenario_id {
      continue
    }
    guard pickle.astNodeIds.get(1) is Some(row_id) else {
      return Some(scenario.location.line)
    }
    for examples in scenario.examples {
      for row in examples.table_body {
        if row.id == row_id {
          return Some(row.location.line)
        }
      }
    }
    return Some(scenario.location.line)
  }
  None
}

///|
/// Collect MoonspecError for each non-passing scenario, with every step.
fn collect_scenario_errors(
  result : RunResult,
  locations : Map[String, String],
) -> Array[@core.MoonspecError] {
  let errors : Array[@core.MoonspecError] = []
  for feature in result.features {
    for scenario in feature.scenarios {
      match scenario.status {
        ScenarioStatus::Passed | ScenarioStatus::Skipped(_) => continue
        _ => {
          let steps : Array[@core.StepReport] = []
          let step_errors : Array[@core.MoonspecError] = []
          for step in scenario.steps {
            let problem : @core.MoonspecError? = match
              (step.status, step.diagnostic) {
              (_, Some(@core.UndefinedStep(..) as e)) => Some(e)
              (_, Some(@core.PendingStep(..) as e)) => Some(e)
              (_, Some(@core.MoonspecError::StepFailed(..) as e)) => Some(e)
              (StepStatus::Failed(message), _) =>
                match
                  @core.step_failed_error(
                    step=step.text,
                    keyword=step.keyword,
                    message~,
                  ) {
                  @core.MoonspecError::StepFailed(..) as e => Some(e)
                  _ => None
                }
              _ => None
            }
            match (problem, step.status) {
              (Some(e), _) => {
                steps.push(Problem(e))
                step_errors.push(e)
              }
              (None, StepStatus::Passed) =>
                steps.push(Passed(keyword=step.keyword, step=step.text))
              (None, _) =>
                steps.push(Skipped(keyword=step.keyword, step=step.text))
            }
          }
          errors.push(
            @core.scenario_failed_error(
              scenario=scenario.scenario_name,
              feature=feature.name,
              location=locations.get(scenario.pickle_id),
              steps~,
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
fn format_run_summary(
  summary : RunSummary,
  parse_errors~ : Int32 = 0,
) -> String {
  let parts : Array[String] = []
  if parse_errors > 0 {
    let noun = if parse_errors == 1 { "parse error" } else { "parse errors" }
    parts.push(parse_errors.to_string() + " " + noun)
  }
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
fn[W : @core.World] run_pickles_sequential(
  factory : () -> W,
  pickles : Array[@cucumber_messages.Pickle],
  sinks~ : Array[&@core.MessageSink] = [],
  tc_mappings~ : Map[String, TestCaseMapping] = {},
  id_gen~ : IdGenerator = IdGenerator::new(),
  retries~ : Int32 = 0,
  dry_run~ : Bool = false,
  skip_tags~ : Array[String] = [],
) -> Array[PickleResult] raise Error {
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
  { result, was_retried: false, }
}

///|
/// Execute a single pickle with a fresh world, with optional retry.
///
/// When `retries > 0` or the pickle has a `@retry(N)` tag, failed scenarios are
/// re-executed synchronously. Each attempt creates a fresh
/// World instance via `factory()` and emits its own `TestCaseStarted`/
/// `TestCaseFinished` envelope pair with the correct `attempt` number and
/// `willBeRetried` flag.
///
/// The `@retry(N)` tag takes priority over the global `retries` parameter.
/// Returns a `PickleResult` containing the final attempt's `ScenarioResult` and
/// a flag indicating whether the scenario was retried.
fn[W : @core.World] execute_pickle(
  factory : () -> W,
  pickle : @cucumber_messages.Pickle,
  sinks~ : Array[&@core.MessageSink] = [],
  tc_mappings~ : Map[String, TestCaseMapping] = {},
  id_gen~ : IdGenerator = IdGenerator::new(),
  retries~ : Int32 = 0,
  dry_run~ : Bool = false,
  skip_tags~ : Array[String] = [],
) -> PickleResult raise Error {
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
  let skip_reason = @config.skip_reason(tags, skip_tags)
  if skip_reason is Some(reason) {
    let regular_step_ids = match mapping {
      Some(m) => m.regular_step_ids
      None => []
    }
    return make_skipped_pickle_result(
      pickle, tags, reason, mapping, test_case_id, regular_step_ids, sinks, id_gen,
    )
  }
  for current_attempt = 0 {
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
    let has_retries_left = !dry_run && current_attempt < max_retries
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
    if !is_failed || !has_retries_left {
      break { result, was_retried: current_attempt > 0, }
    }
    continue current_attempt + 1
  }
}

///|
/// Group scenario results by feature URI and look up feature names from cache.
fn group_by_feature(
  results : Array[ScenarioResult],
  cache : FeatureCache,
) -> Array[FeatureResult] {
  let groups : Map[String, Array[ScenarioResult]] = Map([])
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
    feature_results.push({ name, scenarios, duration_ms: 0L, })
  }
  feature_results
}

///|
fn compute_summary(
  features : Array[FeatureResult],
  retried~ : Int32 = 0,
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
