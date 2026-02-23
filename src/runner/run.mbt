///|
/// Broadcast an envelope to all sinks.
fn emit(sinks : Array[&@core.MessageSink], envelope : @cucumber_messages.Envelope) -> Unit {
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
        "version": "0.2.0".to_json(),
      },
      "runtime": { "name": "moonbit".to_json() },
      "os": { "name": "unknown".to_json() },
      "cpu": { "name": "unknown".to_json() },
    },
  }
  @json.from_json(json) catch { _ => panic() }
}

///|
fn make_source_envelope(uri : String, data : String) -> @cucumber_messages.Envelope {
  let json : Json = {
    "source": {
      "uri": uri.to_json(),
      "data": data.to_json(),
      "mediaType": "text/x.cucumber.gherkin+plain".to_json(),
    },
  }
  @json.from_json(json) catch { _ => panic() }
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
  @json.from_json(json) catch { _ => panic() }
}

///|
fn make_test_run_finished_envelope(
  success : Bool,
  run_id : String
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
  @json.from_json(json) catch { _ => panic() }
}

///|
fn make_test_case_started_envelope(
  id : String,
  test_case_id : String
) -> @cucumber_messages.Envelope {
  let json : Json = {
    "testCaseStarted": {
      "attempt": (0 : Int).to_json(),
      "id": id.to_json(),
      "testCaseId": test_case_id.to_json(),
      "timestamp": {
        "seconds": (0 : Int).to_json(),
        "nanos": (0 : Int).to_json(),
      },
    },
  }
  @json.from_json(json) catch { _ => panic() }
}

///|
fn make_test_case_finished_envelope(
  test_case_started_id : String
) -> @cucumber_messages.Envelope {
  let json : Json = {
    "testCaseFinished": {
      "testCaseStartedId": test_case_started_id.to_json(),
      "timestamp": {
        "seconds": (0 : Int).to_json(),
        "nanos": (0 : Int).to_json(),
      },
      "willBeRetried": false.to_json(),
    },
  }
  @json.from_json(json) catch { _ => panic() }
}

///|
fn make_test_step_started_envelope(
  test_case_started_id : String,
  test_step_id : String
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
  @json.from_json(json) catch { _ => panic() }
}

///|
fn make_test_step_finished_envelope(
  test_case_started_id : String,
  test_step_id : String,
  status : String,
  message : String?
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
  @json.from_json(json) catch { _ => panic() }
}

///|
/// Map a StepStatus to a cucumber-messages status string.
fn step_status_to_string(status : StepStatus) -> String {
  match status {
    StepStatus::Passed => "PASSED"
    StepStatus::Failed(_) => "FAILED"
    StepStatus::Skipped => "SKIPPED"
    StepStatus::Undefined => "UNDEFINED"
    StepStatus::Pending => "PENDING"
  }
}

///|
/// Map a StepStatus to a failure message (if any).
fn step_status_message(status : StepStatus) -> String? {
  match status {
    StepStatus::Failed(msg) => Some(msg)
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
  tc_envelopes : Array[@cucumber_messages.Envelope]
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
/// Run all features and collect results.
///
/// A fresh world is created per scenario via `factory()` for isolation.
/// When `parallel` is greater than 0, pickles are executed concurrently using
/// `@async.all()` with bounded concurrency. Otherwise, pickles run sequentially.
pub async fn[W : @core.World] run(
  factory : () -> W,
  features : Array[FeatureSource],
  tag_expr? : String = "",
  scenario_name? : String = "",
  parallel? : Int = 0,
  sinks? : Array[&@core.MessageSink] = [],
) -> RunResult {
  let cache = FeatureCache::new()
  if sinks.length() > 0 {
    emit(sinks, make_meta_envelope())
  }
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
    cache.load_from_source(source)
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
  // Test planning phase
  let id_gen = IdGenerator::new()
  let tc_mappings : Map[String, TestCaseMapping] = if sinks.length() > 0 {
    let tc_envelopes = build_test_cases(factory, filtered, id_gen)
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
  let results = if parallel > 0 {
    run_pickles_parallel(factory, filtered, max_concurrent=parallel, sinks~, tc_mappings~, id_gen~)
  } else {
    run_pickles_sequential(factory, filtered, sinks~, tc_mappings~, id_gen~)
  }
  // Emit TestRunFinished
  if sinks.length() > 0 {
    let all_passed = results.iter().all(fn(r) { r.status == ScenarioStatus::Passed })
    emit(sinks, make_test_run_finished_envelope(all_passed, run_id))
  }
  let feature_results = group_by_feature(results, cache)
  let summary = compute_summary(feature_results)
  { features: feature_results, summary }
}

///|
/// Run all features with lifecycle hooks and collect results.
///
/// Like `run`, but calls before/after_scenario and before/after_step hooks
/// on the world. The world must implement both `World` and `Hooks` traits.
pub async fn[W : @core.World + @core.Hooks] run_with_hooks(
  factory : () -> W,
  features : Array[FeatureSource],
  tag_expr? : String = "",
  scenario_name? : String = "",
  parallel? : Int = 0,
  sinks? : Array[&@core.MessageSink] = [],
) -> RunResult {
  let cache = FeatureCache::new()
  if sinks.length() > 0 {
    emit(sinks, make_meta_envelope())
  }
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
    cache.load_from_source(source)
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
  // Test planning phase
  let id_gen = IdGenerator::new()
  let tc_mappings : Map[String, TestCaseMapping] = if sinks.length() > 0 {
    let tc_envelopes = build_test_cases(factory, filtered, id_gen)
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
  let results = if parallel > 0 {
    run_pickles_parallel_with_hooks(factory, filtered, max_concurrent=parallel, sinks~, tc_mappings~, id_gen~)
  } else {
    run_pickles_sequential_with_hooks(factory, filtered, sinks~, tc_mappings~, id_gen~)
  }
  // Emit TestRunFinished
  if sinks.length() > 0 {
    let all_passed = results.iter().all(fn(r) { r.status == ScenarioStatus::Passed })
    emit(sinks, make_test_run_finished_envelope(all_passed, run_id))
  }
  let feature_results = group_by_feature(results, cache)
  let summary = compute_summary(feature_results)
  { features: feature_results, summary }
}

///|
/// Run all features, raising MoonspecError on any failure.
///
/// This is the ergonomic test API. Use in generated tests and manual tests
/// where you want structured error output instead of manual result inspection.
pub async fn[W : @core.World] run_or_fail(
  factory : () -> W,
  features : Array[FeatureSource],
  tag_expr? : String = "",
  scenario_name? : String = "",
  parallel? : Int = 0,
  sinks? : Array[&@core.MessageSink] = [],
) -> RunResult {
  let result = run(factory, features, tag_expr~, scenario_name~, parallel~, sinks~)
  if result.summary.failed > 0 ||
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
              Some(@core.StepFailed(..) as e) => step_errors.push(e)
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
  parts.push(summary.total_scenarios.to_string() + " total")
  parts.join(", ")
}

///|
/// Run pickles sequentially (the default path).
fn[W : @core.World] run_pickles_sequential(
  factory : () -> W,
  pickles : Array[@cucumber_messages.Pickle],
  sinks? : Array[&@core.MessageSink] = [],
  tc_mappings? : Map[String, TestCaseMapping] = {},
  id_gen? : IdGenerator = IdGenerator::new(),
) -> Array[ScenarioResult] {
  let results : Array[ScenarioResult] = []
  for pickle in pickles {
    let result = execute_pickle(
      factory,
      pickle,
      sinks~,
      tc_mappings~,
      id_gen~,
    )
    results.push(result)
  }
  results
}

///|
/// Run pickles sequentially with hooks.
fn[W : @core.World + @core.Hooks] run_pickles_sequential_with_hooks(
  factory : () -> W,
  pickles : Array[@cucumber_messages.Pickle],
  sinks? : Array[&@core.MessageSink] = [],
  tc_mappings? : Map[String, TestCaseMapping] = {},
  id_gen? : IdGenerator = IdGenerator::new(),
) -> Array[ScenarioResult] {
  let results : Array[ScenarioResult] = []
  for pickle in pickles {
    let result = execute_pickle_with_hooks(
      factory,
      pickle,
      sinks~,
      tc_mappings~,
      id_gen~,
    )
    results.push(result)
  }
  results
}

///|
/// Execute a single pickle with a fresh world.
fn[W : @core.World] execute_pickle(
  factory : () -> W,
  pickle : @cucumber_messages.Pickle,
  sinks? : Array[&@core.MessageSink] = [],
  tc_mappings? : Map[String, TestCaseMapping] = {},
  id_gen? : IdGenerator = IdGenerator::new(),
) -> ScenarioResult {
  let world = factory()
  let registry = @core.StepRegistry::new()
  @core.World::register_steps(world, registry)
  // Emit TestCaseStarted
  let mapping = tc_mappings.get(pickle.id)
  let tcs_id = match mapping {
    Some(m) => {
      let tcs_id = id_gen.next("tcs")
      if sinks.length() > 0 {
        emit(sinks, make_test_case_started_envelope(tcs_id, m.test_case_id))
      }
      Some(tcs_id)
    }
    None => None
  }
  let test_step_ids = match mapping {
    Some(m) => m.test_step_ids
    None => []
  }
  let result = execute_scenario(
    registry,
    feature_name=pickle.uri,
    scenario_name=pickle.name,
    pickle_id=pickle.id,
    tags=pickle.tags.map(fn(t) { t.name }),
    steps=pickle.steps,
    sinks~,
    test_case_started_id=tcs_id.unwrap_or(""),
    test_step_ids~,
  )
  // Emit TestCaseFinished
  match tcs_id {
    Some(id) =>
      if sinks.length() > 0 {
        emit(sinks, make_test_case_finished_envelope(id))
      }
    None => ()
  }
  result
}

///|
/// Execute a single pickle with hooks and a fresh world.
fn[W : @core.World + @core.Hooks] execute_pickle_with_hooks(
  factory : () -> W,
  pickle : @cucumber_messages.Pickle,
  sinks? : Array[&@core.MessageSink] = [],
  tc_mappings? : Map[String, TestCaseMapping] = {},
  id_gen? : IdGenerator = IdGenerator::new(),
) -> ScenarioResult {
  let world = factory()
  let registry = @core.StepRegistry::new()
  @core.World::register_steps(world, registry)
  // Emit TestCaseStarted
  let mapping = tc_mappings.get(pickle.id)
  let tcs_id = match mapping {
    Some(m) => {
      let tcs_id = id_gen.next("tcs")
      if sinks.length() > 0 {
        emit(sinks, make_test_case_started_envelope(tcs_id, m.test_case_id))
      }
      Some(tcs_id)
    }
    None => None
  }
  let test_step_ids = match mapping {
    Some(m) => m.test_step_ids
    None => []
  }
  let result = execute_scenario_with_hooks(
    world,
    registry,
    feature_name=pickle.uri,
    scenario_name=pickle.name,
    pickle_id=pickle.id,
    tags=pickle.tags.map(fn(t) { t.name }),
    steps=pickle.steps,
    sinks~,
    test_case_started_id=tcs_id.unwrap_or(""),
    test_step_ids~,
  )
  // Emit TestCaseFinished
  match tcs_id {
    Some(id) =>
      if sinks.length() > 0 {
        emit(sinks, make_test_case_finished_envelope(id))
      }
    None => ()
  }
  result
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
