# Message Stream Phase 2A Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Emit StepDefinition, ParameterType, and ParseError envelopes, and migrate PrettyFormatter and JUnitFormatter to be fully envelope-driven MessageSinks.

**Architecture:** The runner builds a single shared StepRegistry at the top of `run()`, emits glue registration envelopes (StepDefinition, ParameterType), then proceeds with test execution. FeatureCache's `load_from_source()` is changed to return parse errors instead of raising, enabling graceful degradation and ParseError envelope emission. PrettyFormatter and JUnitFormatter become state machines driven entirely by `on_message()`, with their direct formatting methods removed.

**Tech Stack:** MoonBit, cucumber-messages (moonrockz/cucumber-messages), cucumber-expressions (moonrockz/cucumber-expressions), Milky2018/xml (new dependency for JUnit XML generation)

---

### Task 1: StepDefId Newtype

**Files:**
- Modify: `src/core/step_def.mbt`
- Test: `src/core/step_def_wbtest.mbt`

**Step 1: Write the failing test**

In `src/core/step_def_wbtest.mbt`, add:

```moonbit
///|
test "StepDefId displays its value" {
  // StepDefId is constructed internally, but we can test via StepDef
  // after registration assigns one. For now, test the to_string method.
  let id = StepDefId::from_string("sd-1")
  assert_eq(id.to_string(), "sd-1")
}
```

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — `StepDefId` type does not exist yet.

**Step 3: Write minimal implementation**

In `src/core/step_def.mbt`, add the `StepDefId` newtype and update `StepDef`:

```moonbit
///|
/// Strongly-typed identifier for a step definition.
/// Only StepRegistry can mint these during registration.
pub(all) struct StepDefId {
  priv value : String
} derive(Show, Eq, Hash)

///|
/// Create a StepDefId from a raw string. Internal use only.
pub fn StepDefId::from_string(value : String) -> StepDefId {
  { value, }
}

///|
pub fn StepDefId::to_string(self : StepDefId) -> String {
  self.value
}
```

Add `id : StepDefId?` field to `StepDef`:

```moonbit
pub(all) struct StepDef {
  keyword : StepKeyword
  pattern : String
  handler : StepHandler
  source : StepSource?
  id : StepDefId?
}
```

Update all `StepDef` factory methods (`given`, `when`, `then`, `step`) to include `id: None`.

**Step 4: Run test to verify it passes**

Run: `mise run test:unit`
Expected: PASS (all existing tests still pass, new test passes)

**Step 5: Commit**

```bash
git add src/core/step_def.mbt src/core/step_def_wbtest.mbt
git commit -m "feat(core): add StepDefId newtype for step definition identity"
```

---

### Task 2: StepRegistry Assigns StepDefIds

**Files:**
- Modify: `src/core/registry.mbt`
- Test: `src/core/registry_wbtest.mbt`

**Step 1: Write the failing test**

In `src/core/registry_wbtest.mbt`, add:

```moonbit
///|
test "register_def assigns StepDefId" {
  let reg = StepRegistry::new()
  let step = StepDef::given("a step", fn(_args) {  })
  assert_true(step.id is None)
  reg.register_def(step)
  assert_true(step.id is Some(_))
}

///|
test "step_defs returns all registered definitions" {
  let reg = StepRegistry::new()
  reg.given("first", fn(_args) {  })
  reg.given("second", fn(_args) {  })
  let defs = reg.step_defs()
  assert_eq(defs.length(), 2)
}

///|
test "StepDefIds are unique across registrations" {
  let reg = StepRegistry::new()
  reg.given("one", fn(_args) {  })
  reg.given("two", fn(_args) {  })
  let defs = reg.step_defs()
  assert_true(defs[0].id != defs[1].id)
}
```

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — `step_defs()` method doesn't exist, `register_def` doesn't assign IDs.

**Step 3: Write minimal implementation**

In `src/core/registry.mbt`:

1. Add an `IdGenerator` to `StepRegistry`:

```moonbit
pub(all) struct StepRegistry {
  priv entries : Array[CompiledStep]
  priv param_registry : @cucumber_expressions.ParamTypeRegistry
  priv id_gen : IdGenerator
}
```

Where `IdGenerator` is a private struct in the same file:

```moonbit
///|
priv struct IdGenerator {
  mut counter : Int
}

///|
fn IdGenerator::new() -> IdGenerator {
  { counter: 0 }
}

///|
fn IdGenerator::next_step_def_id(self : IdGenerator) -> StepDefId {
  self.counter += 1
  StepDefId::from_string("sd-" + self.counter.to_string())
}
```

2. Update `StepRegistry::new()` to include `id_gen: IdGenerator::new()`.

3. Update `register_def()` to assign an ID:

```moonbit
pub fn StepRegistry::register_def(
  self : StepRegistry,
  step_def : StepDef,
) -> Unit {
  let expr = @cucumber_expressions.Expression::parse_with_registry(
    step_def.pattern,
    self.param_registry,
  ) catch {
    _ => return
  }
  step_def.id = Some(self.id_gen.next_step_def_id())
  self.entries.push({ def: step_def, expression: expr })
}
```

Note: `StepDef` is a struct (reference type in MoonBit), so mutating `step_def.id` is visible to the caller.

4. Add `step_defs()` accessor:

```moonbit
///|
/// Return all registered step definitions.
pub fn StepRegistry::step_defs(self : StepRegistry) -> Array[StepDef] {
  self.entries.map(fn(e) { e.def })
}
```

**Step 4: Run test to verify it passes**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add src/core/registry.mbt src/core/registry_wbtest.mbt
git commit -m "feat(core): StepRegistry assigns StepDefIds during registration"
```

---

### Task 3: Emit StepDefinition Envelopes

**Files:**
- Modify: `src/runner/run.mbt`
- Modify: `src/runner/planner.mbt`
- Test: `src/runner/run_wbtest.mbt`

**Step 1: Write the failing test**

In `src/runner/run_wbtest.mbt`, add:

```moonbit
///|
async test "run emits StepDefinition envelopes after Pickles" {
  let collector = CollectorSink::new()
  let features = [
    FeatureSource::Text(
      "test://sd", "Feature: SD\n\n  Scenario: S\n    Given a step\n",
    ),
  ]
  let _ = run(RunWorld::default, features, sinks=[collector])
  let types : Array[String] = []
  for env in collector.envelopes {
    match env {
      @cucumber_messages.Envelope::Pickle(_) => types.push("Pickle")
      @cucumber_messages.Envelope::StepDefinition(_) => types.push("StepDefinition")
      @cucumber_messages.Envelope::TestCase(_) => types.push("TestCase")
      _ => ()
    }
  }
  // StepDefinition must appear after Pickle, before TestCase
  let mut sd_idx = -1
  let mut pickle_idx = -1
  let mut tc_idx = -1
  for i, t in types {
    if t == "Pickle" && pickle_idx == -1 { pickle_idx = i }
    if t == "StepDefinition" && sd_idx == -1 { sd_idx = i }
    if t == "TestCase" && tc_idx == -1 { tc_idx = i }
  }
  assert_true(sd_idx > pickle_idx)
  assert_true(sd_idx < tc_idx)
}
```

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — no StepDefinition envelopes emitted.

**Step 3: Write minimal implementation**

Restructure `run()` to build the registry once and emit StepDefinition envelopes.

In `src/runner/run.mbt`, in the `run()` function, after emitting Pickle envelopes and before the test planning phase:

1. Build registry once at top of `run()`:

```moonbit
// Build registry once for step matching and envelope emission
let world_for_registry = factory()
let registry = @core.StepRegistry::new()
@core.World::register_steps(world_for_registry, registry)
```

2. Emit StepDefinition envelopes:

```moonbit
// Emit StepDefinition envelopes
if sinks.length() > 0 {
  for step_def in registry.step_defs() {
    let sd_id = match step_def.id {
      Some(id) => id.to_string()
      None => continue
    }
    let source_ref : Map[String, Json] = {}
    match step_def.source {
      Some(src) => {
        match src.uri {
          Some(uri) => source_ref["uri"] = uri.to_json()
          None => ()
        }
        match src.line {
          Some(line) =>
            source_ref["location"] = { "line": line.to_json() }
          None => ()
        }
      }
      None => ()
    }
    let json : Json = {
      "stepDefinition": {
        "id": sd_id.to_json(),
        "pattern": {
          "source": step_def.pattern.to_json(),
          "type": "CUCUMBER_EXPRESSION".to_json(),
        },
        "sourceReference": source_ref.to_json(),
      },
    }
    let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch {
      _ => continue
    }
    emit(sinks, envelope)
  }
}
```

3. Pass the shared `registry` to `build_test_cases()` instead of having it create its own. Modify `build_test_cases()` in `src/runner/planner.mbt` to accept a registry:

```moonbit
pub fn build_test_cases(
  registry : @core.StepRegistry,
  pickles : Array[@cucumber_messages.Pickle],
  id_gen : IdGenerator,
) -> Array[@cucumber_messages.Envelope] {
```

Remove the throwaway world+registry creation from `build_test_cases()`.

4. Wire `stepDefinitionIds` — when a pickle step matches, include the matched StepDefId:

```moonbit
let step_def_ids : Array[Json] = match
  registry.find_match(step.text, keyword~) {
  Matched(sd, _) =>
    match sd.id {
      Some(id) => [id.to_string().to_json()]
      None => []
    }
  Undefined(..) => []
}
```

5. Update all callers: remove the `factory` parameter from `build_test_cases()` calls and pass `registry` instead. Also pass the shared `registry` down to `execute_pickle()` instead of creating a new one per pickle.

6. Apply the same changes to `run_with_hooks()`.

**Step 4: Run test to verify it passes**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Update the canonical ordering test**

Update the "run emits envelopes in canonical order" test to include `StepDefinition` in the expected sequence:

```moonbit
let expected : Array[String] = [
  "Meta", "Source", "GherkinDocument", "Pickle", "StepDefinition", "TestCase",
  "TestRunStarted", "TestCaseStarted", "TestStepStarted", "TestStepFinished",
  "TestCaseFinished", "TestRunFinished",
]
```

Also update the two-scenario test's expected sequence similarly.

**Step 6: Run all tests**

Run: `mise run test:unit`
Expected: PASS

**Step 7: Commit**

```bash
git add src/runner/run.mbt src/runner/planner.mbt src/runner/run_wbtest.mbt
git commit -m "feat(runner): emit StepDefinition envelopes with stepDefinitionIds"
```

---

### Task 4: ParameterType Envelope Plumbing

**Files:**
- Modify: `src/runner/run.mbt`
- Test: `src/runner/run_wbtest.mbt`

**Context:** The `cucumber-expressions` package needs a `param_types() -> ArrayView[ParamType]` accessor on `ParamTypeRegistry`. Since `moonrockz/cucumber-expressions` is a published dependency, this requires a release of that package first. This task implements the plumbing in moonspec assuming that accessor exists. If the accessor isn't available yet, this task creates a placeholder that emits zero ParameterType envelopes with a TODO comment.

**Step 1: Write the failing test**

In `src/runner/run_wbtest.mbt`, add:

```moonbit
///|
async test "run emits no ParameterType envelopes for built-in types only" {
  let collector = CollectorSink::new()
  let features = [
    FeatureSource::Text(
      "test://pt", "Feature: PT\n\n  Scenario: S\n    Given a step\n",
    ),
  ]
  let _ = run(RunWorld::default, features, sinks=[collector])
  let mut pt_count = 0
  for env in collector.envelopes {
    if env is @cucumber_messages.Envelope::ParameterType(_) {
      pt_count += 1
    }
  }
  // No custom parameter types registered, so zero ParameterType envelopes
  assert_eq(pt_count, 0)
}
```

**Step 2: Run test to verify it passes**

Run: `mise run test:unit`
Expected: PASS (no ParameterType envelopes emitted is the current behavior). This is a "green from the start" test that documents expected behavior.

**Step 3: Add ParameterType emission slot**

In `src/runner/run.mbt`, after StepDefinition emission and before TestCase emission, add a placeholder:

```moonbit
// Emit ParameterType envelopes for custom parameter types
// TODO: Requires param_types() -> ArrayView[ParamType] accessor
// on cucumber-expressions ParamTypeRegistry. Currently no custom
// parameter types are supported, so this emits nothing.
```

**Step 4: Run tests**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add src/runner/run.mbt src/runner/run_wbtest.mbt
git commit -m "feat(runner): add ParameterType envelope slot (placeholder)"
```

---

### Task 5: ParseErrorInfo and FeatureCache Breaking Change

**Files:**
- Modify: `src/runner/cache.mbt`
- Modify: `src/runner/results.mbt`
- Test: `src/runner/cache_wbtest.mbt`

**Step 1: Write the failing test**

In `src/runner/cache_wbtest.mbt`, add:

```moonbit
///|
test "load_from_source returns empty errors on valid feature" {
  let cache = FeatureCache::new()
  let errors = cache.load_from_source(
    FeatureSource::Text(
      "test://ok",
      "Feature: OK\n\n  Scenario: S\n    Given a step\n",
    ),
  )
  assert_eq(errors.length(), 0)
  assert_true(cache.contains("test://ok"))
}

///|
test "load_from_source returns ParseErrorInfo on invalid feature" {
  let cache = FeatureCache::new()
  let errors = cache.load_from_source(
    FeatureSource::Text("test://bad", "This is not valid Gherkin"),
  )
  assert_true(errors.length() > 0)
  assert_eq(errors[0].uri, "test://bad")
  assert_true(not(cache.contains("test://bad")))
}
```

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — `load_from_source` currently raises instead of returning errors.

**Step 3: Write minimal implementation**

In `src/runner/results.mbt`, add:

```moonbit
///|
/// Information about a parse error encountered while loading a feature.
pub(all) struct ParseErrorInfo {
  uri : String
  message : String
  line : Int?
} derive(Show, Eq)
```

Add `parse_errors` field to `RunResult`:

```moonbit
pub(all) struct RunResult {
  features : Array[FeatureResult]
  summary : RunSummary
  parse_errors : Array[ParseErrorInfo]
} derive(Show)
```

In `src/runner/cache.mbt`, change `load_from_source`:

```moonbit
///|
/// Load a feature from any FeatureSource variant.
/// Returns parse errors instead of raising. Empty on success.
pub fn FeatureCache::load_from_source(
  self : FeatureCache,
  source : FeatureSource,
) -> Array[ParseErrorInfo] {
  let (path, load_fn) : (String, () -> Unit raise Error) = match source {
    Text(path, content) => (path, fn() { self.load_text(path, content) })
    File(path) => (path, fn() { self.load_file(path) })
    Parsed(path, feature) => {
      self.load_parsed(path, feature)
      return []
    }
  }
  try {
    load_fn()
    []
  } catch {
    e => [{ uri: path, message: e.to_string(), line: None }]
  }
}
```

Remove `raise Error` from `load_from_source`'s signature.

**Step 4: Fix all callers**

Update `run()` and `run_with_hooks()` in `src/runner/run.mbt`:
- Change `cache.load_from_source(source)` calls to collect the returned errors
- Remove the implicit `raise` handling
- Update `RunResult` construction to include `parse_errors` field

Update all test files that construct `RunResult` literals to include `parse_errors: []`.

**Step 5: Run test to verify it passes**

Run: `mise run test:unit`
Expected: PASS

**Step 6: Commit**

```bash
git add src/runner/cache.mbt src/runner/results.mbt src/runner/cache_wbtest.mbt src/runner/run.mbt src/format/pretty_wbtest.mbt src/format/junit_wbtest.mbt
git commit -m "feat(runner): FeatureCache returns ParseErrorInfo instead of raising"
```

---

### Task 6: Emit ParseError Envelopes and Update run_or_fail

**Files:**
- Modify: `src/runner/run.mbt`
- Test: `src/runner/run_wbtest.mbt`

**Step 1: Write the failing test**

In `src/runner/run_wbtest.mbt`, add:

```moonbit
///|
async test "run emits ParseError envelope for invalid feature" {
  let collector = CollectorSink::new()
  let features = [
    FeatureSource::Text("test://bad", "This is not valid Gherkin"),
    FeatureSource::Text(
      "test://ok", "Feature: OK\n\n  Scenario: S\n    Given a step\n",
    ),
  ]
  let result = run(RunWorld::default, features, sinks=[collector])
  // Run should continue with valid features
  assert_eq(result.summary.total_scenarios, 1)
  // Parse errors should be in result
  assert_eq(result.parse_errors.length(), 1)
  assert_eq(result.parse_errors[0].uri, "test://bad")
  // ParseError envelope should be emitted
  let mut found_parse_error = false
  for env in collector.envelopes {
    if env is @cucumber_messages.Envelope::ParseError(_) {
      found_parse_error = true
    }
  }
  assert_true(found_parse_error)
}

///|
async test "run_or_fail raises on parse errors" {
  let mut caught = false
  try
    run_or_fail(RunWorld::default, [
      FeatureSource::Text("test://bad", "Not valid Gherkin"),
    ])
    |> ignore
  catch {
    @core.RunFailed(..) => caught = true
    _ => ()
  }
  assert_true(caught)
}
```

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — no ParseError envelopes emitted, `run_or_fail` doesn't check parse_errors.

**Step 3: Write minimal implementation**

In `src/runner/run.mbt`, in `run()`:

1. Collect parse errors during feature loading:

```moonbit
let all_parse_errors : Array[ParseErrorInfo] = []
for source in features {
  // ... existing Source envelope emission ...
  let errors = cache.load_from_source(source)
  all_parse_errors.append(errors)
}
```

2. After GherkinDocument emission, emit ParseError envelopes:

```moonbit
if sinks.length() > 0 {
  for pe in all_parse_errors {
    let source_ref : Map[String, Json] = {}
    source_ref["uri"] = pe.uri.to_json()
    match pe.line {
      Some(line) =>
        source_ref["location"] = { "line": line.to_json() }
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
```

3. Pass `all_parse_errors` into `RunResult`:

```moonbit
{ features: feature_results, summary, parse_errors: all_parse_errors }
```

4. Apply same changes to `run_with_hooks()`.

5. Update `run_or_fail()` to check parse errors:

```moonbit
if result.parse_errors.length() > 0 ||
  result.summary.failed > 0 ||
  result.summary.undefined > 0 ||
  result.summary.pending > 0 {
  // ... existing error handling ...
}
```

**Step 4: Run test to verify it passes**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add src/runner/run.mbt src/runner/run_wbtest.mbt
git commit -m "feat(runner): emit ParseError envelopes, run_or_fail checks parse errors"
```

---

### Task 7: PrettyFormatter Envelope-Driven Migration

**Files:**
- Modify: `src/format/pretty.mbt`
- Modify: `src/format/pretty_wbtest.mbt`

**Step 1: Write the failing test**

In `src/format/pretty_wbtest.mbt`, add a new test that feeds envelopes and checks output:

```moonbit
///|
test "PrettyFormatter renders scenario from envelopes" {
  let fmt = PrettyFormatter::new(no_color=true)
  // Feed envelopes in order
  let envelopes = build_pretty_test_envelopes()
  for env in envelopes {
    @core.MessageSink::on_message(fmt, env)
  }
  let output = fmt.output()
  assert_true(string_contains(output, "Feature: Math"))
  assert_true(string_contains(output, "Addition"))
  assert_true(string_contains(output, "PASS") || string_contains(output, "\u{2713}"))
  assert_true(string_contains(output, "1 scenario"))
}
```

Where `build_pretty_test_envelopes()` is a helper that constructs a minimal envelope sequence: GherkinDocument, Pickle, TestCase, TestRunStarted, TestCaseStarted, TestStepStarted, TestStepFinished (PASSED), TestCaseFinished, TestRunFinished.

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — `on_message` is still a no-op.

**Step 3: Write minimal implementation**

Rewrite `PrettyFormatter` in `src/format/pretty.mbt`:

1. Add state fields:

```moonbit
pub(all) struct PrettyFormatter {
  no_color : Bool
  mut buffer : String
  // Envelope-driven state
  priv features : Map[String, String]          // uri -> feature name
  priv pickles : Map[String, PickleInfo]       // pickle id -> info
  priv test_cases : Map[String, String]        // test case id -> pickle id
  priv test_case_started : Map[String, String] // tcs id -> test case id
  priv step_lookup : Map[String, Array[StepInfo]] // pickle id -> steps
  priv mut current_feature_uri : String
  priv mut scenario_counts : SummaryCounts
}
```

With private helper structs:

```moonbit
priv struct PickleInfo {
  name : String
  uri : String
}

priv struct StepInfo {
  text : String
  keyword : String
}

priv struct SummaryCounts {
  mut total : Int
  mut passed : Int
  mut failed : Int
  mut undefined : Int
  mut pending : Int
  mut skipped : Int
}
```

2. Implement `on_message()` as a state machine matching on envelope variants.

3. Remove `format_feature_start()`, `format_scenario()`, `format_summary()`.

**Step 4: Update existing tests**

Rewrite existing tests to feed envelopes instead of calling removed direct methods. The tests should construct envelope sequences and verify the output matches expected patterns.

**Step 5: Run test to verify it passes**

Run: `mise run test:unit`
Expected: PASS

**Step 6: Commit**

```bash
git add src/format/pretty.mbt src/format/pretty_wbtest.mbt
git commit -m "feat(format): PrettyFormatter fully driven by on_message envelopes"
```

---

### Task 8: JUnitFormatter Envelope-Driven Migration

**Files:**
- Modify: `src/format/junit.mbt`
- Modify: `src/format/junit_wbtest.mbt`
- Modify: `src/format/moon.pkg`

**Step 1: Add Milky2018/xml dependency**

In `moon.mod.json`, add `"Milky2018/xml"` to deps. Run `moon install` (or `moon update`) to fetch it.

In `src/format/moon.pkg`, add:

```
"Milky2018/xml" as @xml,
```

**Step 2: Write the failing test**

In `src/format/junit_wbtest.mbt`, add:

```moonbit
///|
test "JUnitFormatter produces XML from envelopes" {
  let fmt = JUnitFormatter::new()
  let envelopes = build_junit_test_envelopes()
  for env in envelopes {
    @core.MessageSink::on_message(fmt, env)
  }
  let output = fmt.output()
  assert_true(string_contains(output, "<?xml"))
  assert_true(string_contains(output, "<testsuites"))
  assert_true(string_contains(output, "name=\"Math\""))
  assert_true(string_contains(output, "name=\"Addition\""))
}
```

Where `build_junit_test_envelopes()` constructs a minimal sequence including GherkinDocument (with feature name "Math"), Pickle, TestCase, TestRunStarted, TestCaseStarted, TestStepStarted, TestStepFinished (PASSED), TestCaseFinished, TestRunFinished.

**Step 3: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — `on_message` is still a no-op.

**Step 4: Write minimal implementation**

Rewrite `JUnitFormatter` in `src/format/junit.mbt`:

1. Add state fields:

```moonbit
pub(all) struct JUnitFormatter {
  priv mut buffer : String
  priv features : Map[String, String]          // uri -> feature name
  priv pickles : Map[String, PickleData]       // pickle id -> data
  priv test_cases : Map[String, String]        // test case id -> pickle id
  priv test_case_started : Map[String, String] // tcs id -> test case id
  priv results : Array[JUnitTestCase]          // accumulated results
  priv mut current_tcs_failure : String?       // failure msg for current tcs
}

priv struct PickleData {
  name : String
  uri : String
}

priv struct JUnitTestCase {
  name : String
  classname : String
  status : String
  failure_message : String?
}
```

2. Implement `on_message()`:
   - GherkinDocument → store feature name
   - Pickle → store pickle data
   - TestCase → store test case → pickle mapping
   - TestCaseStarted → initialize current test case tracking
   - TestStepFinished → if FAILED, capture failure message
   - TestCaseFinished → push JUnitTestCase to results
   - TestRunFinished → generate XML using `Milky2018/xml` and write to buffer

3. Remove `format_result()`.

4. Use `@xml` to build the JUnit XML structure instead of string concatenation.

**Step 5: Update existing tests**

Rewrite tests to feed envelopes instead of calling `format_result()`. Keep assertions about XML structure, escaping, etc.

**Step 6: Run test to verify it passes**

Run: `mise run test:unit`
Expected: PASS

**Step 7: Commit**

```bash
git add moon.mod.json src/format/moon.pkg src/format/junit.mbt src/format/junit_wbtest.mbt
git commit -m "feat(format): JUnitFormatter fully driven by on_message with xml package"
```

---

### Task 9: Remove Direct Formatter Calls from Runner

**Files:**
- Modify: `src/runner/run.mbt` (if any direct formatter calls remain)
- Modify: `src/runner/lib.mbt` (re-exports)
- Test: `src/runner/run_wbtest.mbt`

**Context:** After Tasks 7-8, the formatters are fully envelope-driven. The runner should no longer have any knowledge of specific formatter types. This task verifies that and removes any remaining coupling.

**Step 1: Search for remaining direct formatter references**

Search for `format_result`, `format_scenario`, `format_summary`, `format_feature_start` in `src/runner/`. If none found, this task is a no-op verification.

**Step 2: Write integration test**

In `src/runner/run_wbtest.mbt`, add an integration test that uses PrettyFormatter as a sink and verifies output:

```moonbit
///|
async test "run with PrettyFormatter sink produces output" {
  let fmt = @format.PrettyFormatter::new(no_color=true)
  let features = [
    FeatureSource::Text(
      "test://pretty", "Feature: Pretty\n\n  Scenario: Works\n    Given a step\n",
    ),
  ]
  let _ = run(RunWorld::default, features, sinks=[fmt])
  let output = fmt.output()
  assert_true(@format.string_contains(output, "Feature: Pretty"))
  assert_true(@format.string_contains(output, "Works"))
  assert_true(@format.string_contains(output, "1 scenario"))
}
```

Note: This requires `src/runner/moon.pkg` to import `moonrockz/moonspec/format` for the test file. If circular dependency is an issue, move this test to an integration test file or use `CollectorSink` to verify envelope content instead.

**Step 3: Run tests**

Run: `mise run test:unit`
Expected: PASS

**Step 4: Commit**

```bash
git add src/runner/run_wbtest.mbt
git commit -m "test(runner): integration test for formatter as pure MessageSink"
```

---

### Task 10: Update Canonical Ordering Tests and Final Cleanup

**Files:**
- Modify: `src/runner/run_wbtest.mbt`
- Modify: `src/runner/run.mbt` (remove any dead code)

**Step 1: Verify canonical ordering includes all new envelope types**

Update the "run emits envelopes in canonical order" test to match the final expected sequence:

```moonbit
let expected : Array[String] = [
  "Meta", "Source", "GherkinDocument", "Pickle", "StepDefinition",
  "TestCase", "TestRunStarted", "TestCaseStarted", "TestStepStarted",
  "TestStepFinished", "TestCaseFinished", "TestRunFinished",
]
```

And the two-scenario test similarly.

**Step 2: Run all tests**

Run: `mise run test:unit`
Expected: PASS

**Step 3: Run moon fmt**

Run: `moon fmt`

Important: After running `moon fmt`, check `git diff` on `moon.pkg` files. If `moon fmt` changes the import syntax in `moon.pkg` files, revert those changes with `git checkout -- src/*/moon.pkg` while keeping `.mbt` formatting changes. This is a known issue from Phase 1.

**Step 4: Regenerate .mbti files**

Run: `moon info`

This regenerates the `pkg.generated.mbti` files to reflect the new/changed public APIs.

**Step 5: Run all tests one final time**

Run: `mise run test:unit`
Expected: PASS

**Step 6: Commit**

```bash
git add -A
git commit -m "chore: final cleanup, formatting, and regenerated .mbti files"
```
