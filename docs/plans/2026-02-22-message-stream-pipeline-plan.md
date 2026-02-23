# Message-Stream Pipeline Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add cucumber-messages streaming to the runner so formatters receive `Envelope` messages during execution.

**Architecture:** A `MessageSink` trait with a single `on_message(Envelope)` method replaces the current `Formatter` trait. The runner emits envelopes at each pipeline phase. Formatters pattern-match on envelope types they care about.

**Tech Stack:** MoonBit, `moonrockz/cucumber-messages` (Envelope types), `moonbitlang/async`

---

### Task 1: Add MessageSink trait to core

**Files:**
- Create: `src/core/sink.mbt`
- Modify: `src/core/moon.pkg` — add `"moonrockz/cucumber-messages" as @cucumber_messages` import

**Step 1: Create the MessageSink trait**

Create `src/core/sink.mbt`:

```moonbit
///|
/// A sink that receives cucumber-messages Envelope events during a test run.
pub(open) trait MessageSink {
  on_message(Self, @cucumber_messages.Envelope) -> Unit
}
```

**Step 2: Add cucumber-messages import to core moon.pkg**

In `src/core/moon.pkg`, add the import:

```
import {
  "moonrockz/cucumber-expressions" as @cucumber_expressions,
  "moonrockz/cucumber-messages" as @cucumber_messages,
  "moonbitlang/core/strconv",
}
```

**Step 3: Verify build**

Run: `moon check 2>&1`
Expected: 0 errors

**Step 4: Commit**

```
git add src/core/sink.mbt src/core/moon.pkg
git commit -m "feat(core): add MessageSink trait for envelope streaming"
```

---

### Task 2: Add CollectorSink test helper

**Files:**
- Create: `src/runner/collector_sink.mbt`

**Step 1: Create CollectorSink**

Create `src/runner/collector_sink.mbt`:

```moonbit
///|
/// Test helper that collects all envelopes into an array.
pub(all) struct CollectorSink {
  envelopes : Array[@cucumber_messages.Envelope]
}

///|
pub fn CollectorSink::new() -> CollectorSink {
  { envelopes: [] }
}

///|
pub impl @core.MessageSink for CollectorSink with on_message(self, envelope) {
  self.envelopes.push(envelope)
}
```

**Step 2: Verify build**

Run: `moon check 2>&1`
Expected: 0 errors

**Step 3: Commit**

```
git add src/runner/collector_sink.mbt
git commit -m "feat(runner): add CollectorSink test helper for envelope collection"
```

---

### Task 3: Add sinks parameter to run functions

**Files:**
- Modify: `src/runner/run.mbt`

**Step 1: Add sinks parameter to `run()`**

Change the signature of `run()` to accept sinks:

```moonbit
pub async fn[W : @core.World] run(
  factory : () -> W,
  features : Array[FeatureSource],
  tag_expr? : String = "",
  scenario_name? : String = "",
  parallel? : Int = 0,
  sinks? : Array[&@core.MessageSink] = [],
) -> RunResult {
```

The body stays the same for now. We'll wire up envelope emission in later tasks.

**Step 2: Add sinks to `run_with_hooks()`**

Same change:

```moonbit
pub async fn[W : @core.World + @core.Hooks] run_with_hooks(
  factory : () -> W,
  features : Array[FeatureSource],
  tag_expr? : String = "",
  scenario_name? : String = "",
  parallel? : Int = 0,
  sinks? : Array[&@core.MessageSink] = [],
) -> RunResult {
```

**Step 3: Add sinks to `run_or_fail()`**

```moonbit
pub async fn[W : @core.World] run_or_fail(
  factory : () -> W,
  features : Array[FeatureSource],
  tag_expr? : String = "",
  scenario_name? : String = "",
  parallel? : Int = 0,
  sinks? : Array[&@core.MessageSink] = [],
) -> RunResult {
  let result = run(factory, features, tag_expr~, scenario_name~, parallel~, sinks~)
```

**Step 4: Add an `emit` helper function**

Add this helper at the top of `run.mbt`:

```moonbit
///|
/// Broadcast an envelope to all sinks.
fn emit(sinks : Array[&@core.MessageSink], envelope : @cucumber_messages.Envelope) -> Unit {
  for sink in sinks {
    sink.on_message(envelope)
  }
}
```

**Step 5: Write test verifying sinks param works**

Add to `src/runner/run_wbtest.mbt`:

```moonbit
///|
async test "run accepts sinks parameter" {
  let collector = CollectorSink::new()
  let features = [
    FeatureSource::Text(
      "test://sink", "Feature: Sink\n\n  Scenario: Pass\n    Given a step\n",
    ),
  ]
  let result = run(RunWorld::default, features, sinks=[collector])
  assert_eq(result.summary.passed, 1)
  // No envelopes emitted yet — just verifying the parameter works
}
```

**Step 6: Run tests**

Run: `moon test 2>&1`
Expected: All tests pass (130 + 1 new)

**Step 7: Commit**

```
git add src/runner/run.mbt src/runner/run_wbtest.mbt
git commit -m "feat(runner): add sinks parameter to run functions"
```

---

### Task 4: Emit Meta and Source envelopes during discovery

**Files:**
- Modify: `src/runner/run.mbt`

**Step 1: Write test for Meta and Source emission**

Add to `src/runner/run_wbtest.mbt`:

```moonbit
///|
async test "run emits Meta envelope first" {
  let collector = CollectorSink::new()
  let features = [
    FeatureSource::Text(
      "test://meta", "Feature: Meta\n\n  Scenario: S\n    Given a step\n",
    ),
  ]
  let _ = run(RunWorld::default, features, sinks=[collector])
  assert_true(collector.envelopes.length() > 0)
  match collector.envelopes[0] {
    @cucumber_messages.Envelope::Meta(_) => ()
    other => fail("Expected Meta, got \{other}")
  }
}

///|
async test "run emits Source envelope for each feature" {
  let collector = CollectorSink::new()
  let content = "Feature: Src\n\n  Scenario: S\n    Given a step\n"
  let features = [FeatureSource::Text("test://src", content)]
  let _ = run(RunWorld::default, features, sinks=[collector])
  // Find Source envelope
  let mut found = false
  for env in collector.envelopes {
    match env {
      @cucumber_messages.Envelope::Source(src) => {
        assert_eq(src.uri, "test://src")
        assert_eq(src.data, content)
        found = true
        break
      }
      _ => continue
    }
  }
  assert_true(found)
}
```

**Step 2: Run tests to verify they fail**

Run: `moon test 2>&1`
Expected: New tests fail (no envelopes emitted yet)

**Step 3: Emit Meta envelope at start of run()**

In `run()`, after creating the cache but before loading sources, emit Meta:

```moonbit
  // Emit Meta envelope
  if sinks.length() > 0 {
    let meta : @cucumber_messages.Meta = {
      protocolVersion: "25.0.1",
      implementation: { name: "moonspec", version: "0.2.0" },
      runtime: { name: "moonbit", version: None },
      os: { name: "unknown", version: None },
      cpu: { name: "unknown", version: None },
      ci: None,
    }
    emit(sinks, @cucumber_messages.Envelope::Meta(meta))
  }
```

**Step 4: Emit Source envelope in cache loading**

After loading each source in the `run()` function, emit Source. Modify the source loading loop:

```moonbit
  for source in features {
    // Emit Source envelope before loading
    if sinks.length() > 0 {
      let (uri, data) = match source {
        FeatureSource::Text(path, content) => (path, content)
        FeatureSource::File(path) => {
          let content = @fs.read_file_to_string(path) catch { _ => "" }
          (path, content)
        }
        FeatureSource::Parsed(path, _) => (path, "")
      }
      emit(sinks, @cucumber_messages.Envelope::Source({
        uri,
        data,
        mediaType: @cucumber_messages.SourceMediaType::GherkinPlain,
      }))
    }
    cache.load_from_source(source)
  }
```

**Step 5: Apply same changes to `run_with_hooks()`**

The same Meta and Source emission logic needs to be in `run_with_hooks()`. Extract a helper or duplicate the code in both functions.

**Step 6: Run tests**

Run: `moon test 2>&1`
Expected: All tests pass

**Step 7: Commit**

```
git add src/runner/run.mbt src/runner/run_wbtest.mbt
git commit -m "feat(runner): emit Meta and Source envelopes during discovery"
```

---

### Task 5: Emit GherkinDocument and Pickle envelopes

**Files:**
- Modify: `src/runner/run.mbt`

**Step 1: Write tests**

Add to `src/runner/run_wbtest.mbt`:

```moonbit
///|
async test "run emits GherkinDocument envelope after parsing" {
  let collector = CollectorSink::new()
  let features = [
    FeatureSource::Text(
      "test://gdoc", "Feature: GDoc\n\n  Scenario: S\n    Given a step\n",
    ),
  ]
  let _ = run(RunWorld::default, features, sinks=[collector])
  let mut found = false
  for env in collector.envelopes {
    match env {
      @cucumber_messages.Envelope::GherkinDocument(doc) => {
        assert_eq(doc.uri, Some("test://gdoc"))
        found = true
        break
      }
      _ => continue
    }
  }
  assert_true(found)
}

///|
async test "run emits Pickle envelopes after compilation" {
  let collector = CollectorSink::new()
  let features = [
    FeatureSource::Text(
      "test://pickle", "Feature: P\n\n  Scenario: One\n    Given a step\n  Scenario: Two\n    Given a step\n",
    ),
  ]
  let _ = run(RunWorld::default, features, sinks=[collector])
  let mut pickle_count = 0
  for env in collector.envelopes {
    match env {
      @cucumber_messages.Envelope::Pickle(_) => pickle_count += 1
      _ => continue
    }
  }
  assert_eq(pickle_count, 2)
}
```

**Step 2: Run tests to verify they fail**

**Step 3: Emit GherkinDocument after cache loading**

After all sources are loaded, iterate the cache and emit GherkinDocument envelopes. The `@gherkin.Feature` from the cache needs to be converted to a `@cucumber_messages.GherkinDocument`. Since these are different types (gherkin parser types vs cucumber-messages types), create a minimal GherkinDocument:

```moonbit
  // Emit GherkinDocument envelopes
  if sinks.length() > 0 {
    for (uri, feature) in cache.features() {
      let doc : @cucumber_messages.GherkinDocument = {
        uri: Some(uri),
        feature: Some(convert_feature(feature)),
        comments: [],
      }
      emit(sinks, @cucumber_messages.Envelope::GherkinDocument(doc))
    }
  }
```

You'll need a `convert_feature` helper that maps `@gherkin.Feature` to `@cucumber_messages.Feature`. This can be a minimal conversion — populate name, keyword, language, location, tags. Children can be empty for now (the Pickle envelopes carry the executable content).

**Step 4: Emit Pickle envelopes after compilation**

After `compile_pickles(cache)`, emit each pickle:

```moonbit
  let pickles = compile_pickles(cache)
  // Emit Pickle envelopes
  if sinks.length() > 0 {
    for pickle in pickles {
      emit(sinks, @cucumber_messages.Envelope::Pickle(pickle))
    }
  }
```

**Step 5: Apply same to `run_with_hooks()`**

**Step 6: Run tests**

Run: `moon test 2>&1`
Expected: All tests pass

**Step 7: Commit**

```
git add src/runner/run.mbt src/runner/run_wbtest.mbt
git commit -m "feat(runner): emit GherkinDocument and Pickle envelopes"
```

---

### Task 6: Add test planning phase — emit TestCase envelopes

**Files:**
- Create: `src/runner/planner.mbt`
- Modify: `src/runner/run.mbt`

**Step 1: Write test**

Add to `src/runner/run_wbtest.mbt`:

```moonbit
///|
async test "run emits TestCase envelopes with test steps" {
  let collector = CollectorSink::new()
  let features = [
    FeatureSource::Text(
      "test://tc", "Feature: TC\n\n  Scenario: S\n    Given a step\n",
    ),
  ]
  let _ = run(RunWorld::default, features, sinks=[collector])
  let mut found = false
  for env in collector.envelopes {
    match env {
      @cucumber_messages.Envelope::TestCase(tc) => {
        assert_true(tc.testSteps.length() > 0)
        found = true
        break
      }
      _ => continue
    }
  }
  assert_true(found)
}
```

**Step 2: Create planner**

Create `src/runner/planner.mbt`:

```moonbit
///|
/// ID generator for test planning.
pub(all) struct IdGenerator {
  priv mut counter : Int
}

///|
pub fn IdGenerator::new() -> IdGenerator {
  { counter: 0 }
}

///|
pub fn IdGenerator::next(self : IdGenerator, prefix : String) -> String {
  self.counter += 1
  prefix + "-" + self.counter.to_string()
}

///|
/// Build TestCase envelopes by matching pickle steps against the registry.
pub fn plan_test_cases[W : @core.World](
  factory : () -> W,
  pickles : Array[@cucumber_messages.Pickle],
  id_gen : IdGenerator,
) -> Array[@cucumber_messages.TestCase] {
  let world = factory()
  let registry = @core.StepRegistry::new()
  @core.World::register_steps(world, registry)
  let test_cases : Array[@cucumber_messages.TestCase] = []
  for pickle in pickles {
    let test_steps : Array[@cucumber_messages.TestStep] = []
    for step in pickle.steps {
      let keyword = match step.type_ {
        Some(@cucumber_messages.PickleStepType::Context) => "Given "
        Some(@cucumber_messages.PickleStepType::Action) => "When "
        Some(@cucumber_messages.PickleStepType::Outcome) => "Then "
        _ => "* "
      }
      let step_def_ids : Array[String] = match registry.find_match(step.text, keyword~) {
        Matched(step_def, _) =>
          match step_def.source {
            Some(src) =>
              match src.uri {
                Some(uri) => [uri + ":" + src.line.unwrap_or(0).to_string()]
                None => []
              }
            None => []
          }
        Undefined(..) => []
      }
      test_steps.push({
        id: id_gen.next("ts"),
        hookId: None,
        pickleStepId: Some(step.id),
        stepDefinitionIds: Some(step_def_ids),
        stepMatchArgumentsLists: None,
      })
    }
    test_cases.push({
      id: id_gen.next("tc"),
      pickleId: pickle.id,
      testSteps: test_steps,
      testRunStartedId: None,
    })
  }
  test_cases
}
```

**Step 3: Wire into run()**

After filtering, before execution:

```moonbit
  let filtered = filter.apply(pickles)
  // Test planning phase — emit TestCase envelopes
  let test_cases = if sinks.length() > 0 {
    let id_gen = IdGenerator::new()
    let tcs = plan_test_cases(factory, filtered, id_gen)
    for tc in tcs {
      emit(sinks, @cucumber_messages.Envelope::TestCase(tc))
    }
    tcs
  } else {
    []
  }
```

Store `test_cases` for use during execution (Task 7 will need the IDs).

**Step 4: Apply same to `run_with_hooks()`**

**Step 5: Run tests**

Run: `moon test 2>&1`
Expected: All tests pass

**Step 6: Commit**

```
git add src/runner/planner.mbt src/runner/run.mbt src/runner/run_wbtest.mbt
git commit -m "feat(runner): add test planning phase with TestCase envelopes"
```

---

### Task 7: Emit execution lifecycle envelopes

**Files:**
- Modify: `src/runner/run.mbt`
- Modify: `src/runner/executor.mbt`

This is the largest task. The runner needs to emit `TestRunStarted`, `TestCaseStarted`, `TestStepStarted`, `TestStepFinished`, `TestCaseFinished`, `TestRunFinished` during execution.

**Step 1: Write test for full envelope ordering**

Add to `src/runner/run_wbtest.mbt`:

```moonbit
///|
async test "run emits envelopes in canonical order" {
  let collector = CollectorSink::new()
  let features = [
    FeatureSource::Text(
      "test://order", "Feature: Order\n\n  Scenario: S\n    Given a step\n",
    ),
  ]
  let _ = run(RunWorld::default, features, sinks=[collector])
  // Verify ordering: Meta, Source, GherkinDocument, Pickle, TestCase,
  // TestRunStarted, TestCaseStarted, TestStepStarted, TestStepFinished,
  // TestCaseFinished, TestRunFinished
  let types : Array[String] = []
  for env in collector.envelopes {
    match env {
      @cucumber_messages.Envelope::Meta(_) => types.push("Meta")
      @cucumber_messages.Envelope::Source(_) => types.push("Source")
      @cucumber_messages.Envelope::GherkinDocument(_) => types.push("GherkinDocument")
      @cucumber_messages.Envelope::Pickle(_) => types.push("Pickle")
      @cucumber_messages.Envelope::TestCase(_) => types.push("TestCase")
      @cucumber_messages.Envelope::TestRunStarted(_) => types.push("TestRunStarted")
      @cucumber_messages.Envelope::TestCaseStarted(_) => types.push("TestCaseStarted")
      @cucumber_messages.Envelope::TestStepStarted(_) => types.push("TestStepStarted")
      @cucumber_messages.Envelope::TestStepFinished(_) => types.push("TestStepFinished")
      @cucumber_messages.Envelope::TestCaseFinished(_) => types.push("TestCaseFinished")
      @cucumber_messages.Envelope::TestRunFinished(_) => types.push("TestRunFinished")
      _ => types.push("Other")
    }
  }
  let expected = [
    "Meta", "Source", "GherkinDocument", "Pickle", "TestCase",
    "TestRunStarted", "TestCaseStarted", "TestStepStarted", "TestStepFinished",
    "TestCaseFinished", "TestRunFinished",
  ]
  assert_eq(types, expected)
}
```

**Step 2: Emit TestRunStarted before execution**

In `run()`, after test planning, before executing pickles:

```moonbit
  let run_id = if sinks.length() > 0 {
    let id = id_gen.next("tr")
    emit(sinks, @cucumber_messages.Envelope::TestRunStarted({
      timestamp: zero_timestamp(),
      id: Some(id),
    }))
    id
  } else {
    ""
  }
```

Add a `zero_timestamp` helper in `run.mbt`:

```moonbit
///|
fn zero_timestamp() -> @cucumber_messages.Timestamp {
  { seconds: 0, nanos: 0 }
}
```

**Step 3: Thread sinks and test_cases into execution**

Modify `run_pickles_sequential` to accept sinks and test_cases:

```moonbit
fn[W : @core.World] run_pickles_sequential(
  factory : () -> W,
  pickles : Array[@cucumber_messages.Pickle],
  sinks~ : Array[&@core.MessageSink] = [],
  test_cases~ : Array[@cucumber_messages.TestCase] = [],
  id_gen~ : IdGenerator = IdGenerator::new(),
) -> Array[ScenarioResult] {
```

For each pickle, find the matching TestCase by `pickleId`, emit `TestCaseStarted` before execution and `TestCaseFinished` after.

**Step 4: Thread sinks into execute_scenario**

Modify `execute_scenario` to accept sinks and test step IDs, emitting `TestStepStarted` before each step and `TestStepFinished` after each step:

```moonbit
pub fn execute_scenario(
  registry : @core.StepRegistry,
  feature_name~ : String,
  scenario_name~ : String,
  pickle_id~ : String,
  tags~ : Array[String],
  steps~ : Array[@cucumber_messages.PickleStep],
  sinks~ : Array[&@core.MessageSink] = [],
  test_case_started_id~ : String = "",
  test_steps~ : Array[@cucumber_messages.TestStep] = [],
) -> ScenarioResult {
```

Inside the step loop, before executing a step:

```moonbit
    // Emit TestStepStarted
    if sinks.length() > 0 && i < test_steps.length() {
      emit(sinks, @cucumber_messages.Envelope::TestStepStarted({
        testCaseStartedId: test_case_started_id,
        testStepId: test_steps[i].id,
        timestamp: zero_timestamp(),
      }))
    }
```

After executing a step:

```moonbit
    // Emit TestStepFinished
    if sinks.length() > 0 && i < test_steps.length() {
      let msg_status = match status {
        StepStatus::Passed => @cucumber_messages.TestStepResultStatus::Passed
        StepStatus::Failed(_) => @cucumber_messages.TestStepResultStatus::Failed
        StepStatus::Skipped => @cucumber_messages.TestStepResultStatus::Skipped
        StepStatus::Undefined => @cucumber_messages.TestStepResultStatus::Undefined
        StepStatus::Pending => @cucumber_messages.TestStepResultStatus::Pending
      }
      emit(sinks, @cucumber_messages.Envelope::TestStepFinished({
        testCaseStartedId: test_case_started_id,
        testStepId: test_steps[i].id,
        testStepResult: {
          duration: { seconds: 0, nanos: 0 },
          status: msg_status,
          message: match status { StepStatus::Failed(msg) => Some(msg); _ => None },
          exception: None,
        },
        timestamp: zero_timestamp(),
      }))
    }
```

**Step 5: Emit TestRunFinished after execution**

In `run()`, after execution completes:

```moonbit
  if sinks.length() > 0 {
    emit(sinks, @cucumber_messages.Envelope::TestRunFinished({
      message: None,
      success: summary.failed == 0,
      timestamp: zero_timestamp(),
      exception: None,
      testRunStartedId: Some(run_id),
    }))
  }
```

**Step 6: Apply same changes to hooks variants**

Update `execute_scenario_with_hooks`, `run_pickles_sequential_with_hooks`, `run_pickles_parallel`, `run_pickles_parallel_with_hooks` with the same sink threading.

**Step 7: Run tests**

Run: `moon test 2>&1`
Expected: All tests pass (130 existing + new envelope tests)

**Step 8: Commit**

```
git add src/runner/run.mbt src/runner/executor.mbt src/runner/parallel.mbt src/runner/run_wbtest.mbt
git commit -m "feat(runner): emit execution lifecycle envelopes (TestRun/TestCase/TestStep)"
```

---

### Task 8: Refactor MessagesFormatter to implement MessageSink

**Files:**
- Modify: `src/format/messages.mbt`
- Modify: `src/format/messages_wbtest.mbt`

**Step 1: Rewrite MessagesFormatter**

Replace the current `Formatter` impl with `MessageSink`:

```moonbit
///|
/// Cucumber Messages NDJSON formatter.
/// Serializes every Envelope to JSON, one per line.
pub(all) struct MessagesFormatter {
  priv mut buffer : String
}

///|
pub fn MessagesFormatter::new() -> MessagesFormatter {
  { buffer: "" }
}

///|
pub fn MessagesFormatter::output(self : MessagesFormatter) -> String {
  self.buffer
}

///|
fn MessagesFormatter::emit_line(self : MessagesFormatter, line : String) -> Unit {
  if self.buffer.length() > 0 {
    self.buffer = self.buffer + "\n"
  }
  self.buffer = self.buffer + line
}

///|
pub impl @core.MessageSink for MessagesFormatter with on_message(self, envelope) {
  let json = envelope.to_json().stringify()
  self.emit_line(json)
}
```

**Step 2: Update tests**

Rewrite `src/format/messages_wbtest.mbt` to test via `on_message`:

```moonbit
///|
test "MessagesFormatter serializes TestRunStarted envelope" {
  let fmt = MessagesFormatter::new()
  let envelope = @cucumber_messages.Envelope::TestRunStarted({
    timestamp: { seconds: 0, nanos: 0 },
    id: Some("tr-1"),
  })
  fmt.on_message(envelope)
  let output = fmt.output()
  assert_true(string_contains(output, "testRunStarted"))
}

///|
test "MessagesFormatter serializes TestRunFinished envelope" {
  let fmt = MessagesFormatter::new()
  let envelope = @cucumber_messages.Envelope::TestRunFinished({
    message: None,
    success: true,
    timestamp: { seconds: 0, nanos: 0 },
    exception: None,
    testRunStartedId: Some("tr-1"),
  })
  fmt.on_message(envelope)
  let output = fmt.output()
  assert_true(string_contains(output, "testRunFinished"))
  assert_true(string_contains(output, "\"success\":true"))
}

///|
test "MessagesFormatter emits NDJSON with multiple envelopes" {
  let fmt = MessagesFormatter::new()
  fmt.on_message(@cucumber_messages.Envelope::TestRunStarted({
    timestamp: { seconds: 0, nanos: 0 },
    id: Some("tr-1"),
  }))
  fmt.on_message(@cucumber_messages.Envelope::TestRunFinished({
    message: None,
    success: true,
    timestamp: { seconds: 0, nanos: 0 },
    exception: None,
    testRunStartedId: Some("tr-1"),
  }))
  let output = fmt.output()
  assert_true(string_contains(output, "testRunStarted"))
  assert_true(string_contains(output, "testRunFinished"))
}
```

**Step 3: Run tests**

Run: `moon test 2>&1`
Expected: All tests pass

**Step 4: Commit**

```
git add src/format/messages.mbt src/format/messages_wbtest.mbt
git commit -m "refactor(format): rewrite MessagesFormatter as MessageSink"
```

---

### Task 9: Refactor PrettyFormatter to implement MessageSink

**Files:**
- Modify: `src/format/pretty.mbt`
- Modify: `src/format/pretty_wbtest.mbt`

**Step 1: Replace Formatter impl with MessageSink**

Keep all the ANSI helpers and status markers. Replace the `Formatter` trait impl with a single `MessageSink` impl that pattern-matches:

```moonbit
///|
pub impl @core.MessageSink for PrettyFormatter with on_message(self, envelope) {
  match envelope {
    @cucumber_messages.Envelope::TestCaseStarted(_) => ()  // Could print scenario header
    @cucumber_messages.Envelope::TestCaseFinished(_) => ()  // Handled via internal state
    @cucumber_messages.Envelope::TestRunFinished(_) => ()   // Summary handled separately
    _ => ()
  }
}
```

Note: The PrettyFormatter currently receives `ScenarioResult` and `RunResult` objects from the old `Formatter` trait, which contain all the data it needs. With `MessageSink`, it only gets `Envelope` objects. For this task, implement a minimal version that works. The PrettyFormatter will need internal state to accumulate results from `TestStepFinished` and `TestCaseFinished` envelopes.

For now, keep the PrettyFormatter functional by having it also accept `RunResult` through a separate method (not via the trait). The full streaming pretty output is a polish item.

**Step 2: Update tests**

Update `src/format/pretty_wbtest.mbt` to work with the new API.

**Step 3: Run tests**

Run: `moon test 2>&1`
Expected: All tests pass

**Step 4: Commit**

```
git add src/format/pretty.mbt src/format/pretty_wbtest.mbt
git commit -m "refactor(format): rewrite PrettyFormatter as MessageSink"
```

---

### Task 10: Refactor JUnitFormatter to implement MessageSink

**Files:**
- Modify: `src/format/junit.mbt`
- Modify: `src/format/junit_wbtest.mbt`

**Step 1: Replace Formatter impl with MessageSink**

Similar to PrettyFormatter — keep the XML generation logic, but wire it through `on_message`. The JUnit formatter is inherently batch (needs full results to emit XML), so it will buffer envelopes and generate XML on `TestRunFinished`.

For this task, keep it simple: maintain a separate `format_result(RunResult)` method for direct use, and implement `MessageSink` as a thin wrapper.

**Step 2: Update tests**

**Step 3: Run tests and commit**

```
git add src/format/junit.mbt src/format/junit_wbtest.mbt
git commit -m "refactor(format): rewrite JUnitFormatter as MessageSink"
```

---

### Task 11: Remove old Formatter trait

**Files:**
- Delete content of: `src/format/formatter.mbt` (keep file with just the RunInfo struct if needed)
- Modify: `src/format/moon.pkg` — remove unused imports

**Step 1: Remove the Formatter trait and its default impls**

Delete the `Formatter` trait, all `impl Formatter with ...` default implementations, from `src/format/formatter.mbt`. Keep `RunInfo` if any code still references it, or delete entirely.

**Step 2: Clean up moon.pkg imports**

Remove `"moonrockz/moonspec/runner"` and `"moonrockz/gherkin"` from `src/format/moon.pkg` if no longer needed. Add `"moonrockz/moonspec/core"` if not already there (needed for `MessageSink`).

**Step 3: Run tests**

Run: `moon test 2>&1`
Expected: All tests pass

**Step 4: Commit**

```
git add src/format/formatter.mbt src/format/moon.pkg
git commit -m "refactor(format): remove old Formatter trait"
```

---

### Task 12: Integration test — full envelope sequence end-to-end

**Files:**
- Modify: `src/runner/run_wbtest.mbt`

**Step 1: Write comprehensive integration test**

```moonbit
///|
async test "full envelope sequence for two-scenario feature" {
  let collector = CollectorSink::new()
  let content =
    "Feature: Full\n\n  Scenario: A\n    Given a step\n\n  Scenario: B\n    Given a step\n"
  let features = [FeatureSource::Text("test://full", content)]
  let _ = run(RunWorld::default, features, sinks=[collector])
  // Should have: Meta, Source, GherkinDocument, 2x Pickle, 2x TestCase,
  // TestRunStarted, 2x (TestCaseStarted, TestStepStarted, TestStepFinished, TestCaseFinished),
  // TestRunFinished
  // Total: 1+1+1+2+2+1+2+2+2+2+1 = 17 envelopes
  assert_true(collector.envelopes.length() >= 17)

  // Verify first is Meta, last is TestRunFinished
  match collector.envelopes[0] {
    @cucumber_messages.Envelope::Meta(_) => ()
    _ => fail("First envelope should be Meta")
  }
  match collector.envelopes[collector.envelopes.length() - 1] {
    @cucumber_messages.Envelope::TestRunFinished(_) => ()
    _ => fail("Last envelope should be TestRunFinished")
  }
}
```

**Step 2: Run tests**

Run: `moon test 2>&1`
Expected: All tests pass

**Step 3: Commit**

```
git add src/runner/run_wbtest.mbt
git commit -m "test(runner): add full envelope sequence integration test"
```
