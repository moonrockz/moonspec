# Hook Envelope Compliance Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Full cucumber-messages hook compliance — registration-based hooks on Setup with `#callsite` source locations, Hook/TestRunHookStarted/TestRunHookFinished envelope emission, and runner consolidation via RunOptions.

**Architecture:** Remove the `Hooks` trait, add hook registration methods to `Setup` backed by a new `HookRegistry`. Introduce `RunOptions` struct with struct constructor to replace parameter sprawl. Merge `run`/`run_with_hooks` into a single `run(factory, options)`. Merge `execute_scenario`/`execute_scenario_with_hooks` into one function that checks for hooks at runtime.

**Tech Stack:** MoonBit, cucumber-messages, moonspec core + runner

---

## Task 1: Add HookRegistry to Core

**Files:**
- Create: `src/core/hook_registry.mbt`
- Create: `src/core/hook_registry_wbtest.mbt`

**Context:** `HookRegistry` stores registered hooks with IDs, types, handlers, and source locations. It lives alongside `StepRegistry` and `ParamTypeRegistry`. Each hook type maps to a cucumber `HookType`. Multiple hooks per type are supported, executed in registration order.

**Step 1: Write the failing test**

In `src/core/hook_registry_wbtest.mbt`:

```moonbit
///|
test "HookRegistry starts empty" {
  let reg = HookRegistry::new()
  assert_eq(reg.hooks().length(), 0)
}

///|
test "HookRegistry registers before_test_case hook" {
  let reg = HookRegistry::new()
  reg.add(HookType::BeforeTestCase, fn(_info, _result) {  }, None)
  assert_eq(reg.hooks().length(), 1)
  assert_eq(reg.hooks()[0].type_, HookType::BeforeTestCase)
}

///|
test "HookRegistry supports multiple hooks per type" {
  let reg = HookRegistry::new()
  reg.add(HookType::BeforeTestCase, fn(_info, _result) {  }, None)
  reg.add(HookType::BeforeTestCase, fn(_info, _result) {  }, None)
  reg.add(HookType::AfterTestCase, fn(_info, _result) {  }, None)
  assert_eq(reg.hooks().length(), 3)
  let before = reg.by_type(HookType::BeforeTestCase)
  assert_eq(before.length(), 2)
}

///|
test "HookRegistry assigns unique IDs" {
  let reg = HookRegistry::new()
  reg.add(HookType::BeforeTestCase, fn(_info, _result) {  }, None)
  reg.add(HookType::AfterTestCase, fn(_info, _result) {  }, None)
  assert_eq(reg.hooks()[0].id, "hook-1")
  assert_eq(reg.hooks()[1].id, "hook-2")
}
```

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — `HookRegistry` not defined.

**Step 3: Write the implementation**

Create `src/core/hook_registry.mbt`:

```moonbit
///|
/// The 6 cucumber hook types.
pub(all) enum HookType {
  BeforeTestRun
  AfterTestRun
  BeforeTestCase
  AfterTestCase
  BeforeTestStep
  AfterTestStep
} derive(Show, Eq)

///|
/// A registered hook entry.
pub(all) struct RegisteredHook {
  id : String
  type_ : HookType
  handler : (ScenarioInfo?, String?) -> Unit raise Error
  source : StepSource?
}

///|
/// Registry for lifecycle hooks.
pub(all) struct HookRegistry {
  priv hooks_ : Array[RegisteredHook]
  priv mut counter : Int
}

///|
pub fn HookRegistry::new() -> HookRegistry {
  { hooks_: [], counter: 0 }
}

///|
pub fn HookRegistry::add(
  self : HookRegistry,
  type_ : HookType,
  handler : (ScenarioInfo?, String?) -> Unit raise Error,
  source : StepSource?,
) -> Unit {
  self.counter += 1
  let id = "hook-" + self.counter.to_string()
  self.hooks_.push({ id, type_, handler, source })
}

///|
/// All registered hooks in registration order.
pub fn HookRegistry::hooks(self : HookRegistry) -> ArrayView[RegisteredHook] {
  self.hooks_[:]
}

///|
/// Hooks of a specific type, in registration order.
pub fn HookRegistry::by_type(
  self : HookRegistry,
  type_ : HookType,
) -> Array[RegisteredHook] {
  let result : Array[RegisteredHook] = []
  for hook in self.hooks_ {
    if hook.type_ == type_ {
      result.push(hook)
    }
  }
  result
}
```

Note: The handler signature `(ScenarioInfo?, String?) -> Unit raise Error` is a unified type. For `BeforeTestRun`/`AfterTestRun` hooks, both params are `None`. For `BeforeTestCase`, `info` is `Some` and `result` is `None`. For `AfterTestCase`, both are `Some`. The Setup methods will wrap user-provided lambdas to match this unified type. Check how MoonBit's error type annotation works — it may be `!Error` instead of `raise Error`. Match the convention used in existing code (e.g., `StepHandler` in `step_def.mbt`).

**Step 4: Run tests**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add src/core/hook_registry.mbt src/core/hook_registry_wbtest.mbt
git commit -m "feat(core): add HookRegistry for registration-based lifecycle hooks"
```

---

## Task 2: Add Hook Registration to Setup

**Files:**
- Modify: `src/core/setup.mbt`
- Modify: `src/core/setup_wbtest.mbt`

**Context:** Add `HookRegistry` as a third sibling in `Setup`. Add registration methods for all 6 hook types. Use `#callsite(autofill(loc))` to capture source locations. The Setup methods wrap user-provided lambdas to match HookRegistry's unified handler type.

**Step 1: Write the failing test**

In `src/core/setup_wbtest.mbt`, add:

```moonbit
///|
test "Setup registers before_test_case hook" {
  let setup = Setup::new()
  setup.before_test_case(fn(_info) {  })
  assert_eq(setup.hook_registry().hooks().length(), 1)
}

///|
test "Setup registers all 6 hook types" {
  let setup = Setup::new()
  setup.before_test_run(fn() {  })
  setup.after_test_run(fn() {  })
  setup.before_test_case(fn(_info) {  })
  setup.after_test_case(fn(_info, _result) {  })
  setup.before_test_step(fn(_info) {  })
  setup.after_test_step(fn(_info, _result) {  })
  assert_eq(setup.hook_registry().hooks().length(), 6)
}
```

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — `hook_registry()` and hook methods not defined on Setup.

**Step 3: Implement**

In `src/core/setup.mbt`:

1. Add `hook_reg` field to Setup struct:
```moonbit
pub(all) struct Setup {
  priv step_reg : StepRegistry
  priv param_reg : @cucumber_expressions.ParamTypeRegistry
  priv hook_reg : HookRegistry
}
```

2. Update `Setup::new()` to initialize `hook_reg: HookRegistry::new()`.

3. Add accessor:
```moonbit
pub fn Setup::hook_registry(self : Setup) -> HookRegistry {
  self.hook_reg
}
```

4. Add registration methods. Check MoonBit docs for `#callsite(autofill(loc))` syntax — the attribute goes on the function and the `loc` parameter is auto-filled by the compiler. Example:

```moonbit
///|
#callsite(autofill(loc))
pub fn Setup::before_test_case(
  self : Setup,
  handler : (ScenarioInfo) -> Unit raise Error,
  loc~ : SourceLoc,
) -> Unit {
  let source = Some(StepSource::new(uri=Some(loc.to_string()), line=None))
  self.hook_reg.add(
    HookType::BeforeTestCase,
    fn(info, _result) { handler(info.unwrap()) },
    source,
  )
}
```

Add similar methods for all 6 types:
- `before_test_run(fn() -> Unit!Error)` — wraps to `fn(None, None)`
- `after_test_run(fn() -> Unit!Error)` — wraps to `fn(None, None)`
- `before_test_case(fn(ScenarioInfo) -> Unit!Error)` — wraps to `fn(Some(info), None)`
- `after_test_case(fn(ScenarioInfo, String?) -> Unit!Error)` — wraps to `fn(Some(info), result)`
- `before_test_step(fn(StepInfo) -> Unit!Error)` — needs `StepInfo` not `ScenarioInfo`; check if the unified handler type works or if you need a separate approach
- `after_test_step(fn(StepInfo, String?) -> Unit!Error)` — same consideration

**Important:** The handler type in `HookRegistry` may need to be more flexible. If `StepInfo` vs `ScenarioInfo` creates a type mismatch, consider using two handler fields or a union type. Read `src/core/types.mbt` to understand `StepInfo` and `ScenarioInfo`. The simplest approach may be to store closures that capture context and have a `() -> Unit raise Error` signature internally, with the Setup methods doing all the wrapping.

**Step 4: Run tests**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add src/core/setup.mbt src/core/setup_wbtest.mbt
git commit -m "feat(core): add hook registration methods to Setup with callsite"
```

---

## Task 3: Add RunOptions with Struct Constructor

**Files:**
- Create: `src/runner/options.mbt`
- Create: `src/runner/options_wbtest.mbt`

**Context:** `RunOptions` replaces the growing parameter lists. Uses struct constructor (`RunOptions(features)`) and builder-style methods with private fields. Supports MoonBit's `..` cascade syntax.

**Step 1: Write the failing test**

In `src/runner/options_wbtest.mbt`:

```moonbit
///|
test "RunOptions constructor sets features" {
  let features = [FeatureSource::Text("test://a", "Feature: A\n")]
  let opts = RunOptions(features)
  assert_eq(opts.features().length(), 1)
}

///|
test "RunOptions defaults" {
  let opts = RunOptions([])
  assert_eq(opts.is_parallel(), false)
  assert_eq(opts.get_max_concurrent(), 4)
  assert_eq(opts.get_sinks().length(), 0)
}

///|
test "RunOptions builder methods" {
  let collector = CollectorSink::new()
  let opts = RunOptions([])
    ..parallel(true)
    ..max_concurrent(8)
    ..add_sink(collector)
  assert_eq(opts.is_parallel(), true)
  assert_eq(opts.get_max_concurrent(), 8)
  assert_eq(opts.get_sinks().length(), 1)
}
```

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — `RunOptions` not defined.

**Step 3: Implement**

Create `src/runner/options.mbt`:

```moonbit
///|
/// Options for configuring a test run.
pub(all) struct RunOptions {
  priv features_ : Array[FeatureSource]
  priv mut parallel_ : Bool
  priv mut max_concurrent_ : Int
  priv sinks_ : Array[&@core.MessageSink]
  priv mut tag_expr_ : String
  priv mut scenario_name_ : String

  fn new(features : Array[FeatureSource]) -> RunOptions
}

///|
fn RunOptions::new(features : Array[FeatureSource]) -> RunOptions {
  {
    features_: features,
    parallel_: false,
    max_concurrent_: 4,
    sinks_: [],
    tag_expr_: "",
    scenario_name_: "",
  }
}

///|
pub fn RunOptions::parallel(self : RunOptions, value : Bool) -> Unit {
  self.parallel_ = value
}

///|
pub fn RunOptions::max_concurrent(self : RunOptions, value : Int) -> Unit {
  self.max_concurrent_ = value
}

///|
pub fn RunOptions::add_sink(self : RunOptions, sink : &@core.MessageSink) -> Unit {
  self.sinks_.push(sink)
}

///|
pub fn RunOptions::tag_expr(self : RunOptions, value : String) -> Unit {
  self.tag_expr_ = value
}

///|
pub fn RunOptions::scenario_name(self : RunOptions, value : String) -> Unit {
  self.scenario_name_ = value
}

// Accessors for runner internals
///|
pub fn RunOptions::features(self : RunOptions) -> Array[FeatureSource] {
  self.features_
}

///|
pub fn RunOptions::is_parallel(self : RunOptions) -> Bool {
  self.parallel_
}

///|
pub fn RunOptions::get_max_concurrent(self : RunOptions) -> Int {
  self.max_concurrent_
}

///|
pub fn RunOptions::get_sinks(self : RunOptions) -> Array[&@core.MessageSink] {
  self.sinks_
}

///|
pub fn RunOptions::get_tag_expr(self : RunOptions) -> String {
  self.tag_expr_
}

///|
pub fn RunOptions::get_scenario_name(self : RunOptions) -> String {
  self.scenario_name_
}
```

**Step 4: Run tests**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add src/runner/options.mbt src/runner/options_wbtest.mbt
git commit -m "feat(runner): add RunOptions with struct constructor and builder methods"
```

---

## Task 4: Consolidate Runner — Merge run/run_with_hooks

**Files:**
- Modify: `src/runner/run.mbt`
- Modify: `src/runner/executor.mbt`
- Modify: `src/runner/parallel.mbt`
- Modify: `src/runner/run_wbtest.mbt`

**Context:** Replace `run(factory, features, ...)` and `run_with_hooks(factory, features, ...)` with a single `run(factory, options)`. The new `run` creates `Setup`, calls `configure`, extracts registries including hooks, and dispatches to a single execution path. Hooks are checked at runtime — if none registered, they're simply not called.

Also merge `execute_scenario` and `execute_scenario_with_hooks` into a single function that takes a `HookRegistry` parameter. If the registry has hooks for a given type, they run; otherwise they're skipped.

Similarly merge `execute_pickle`/`execute_pickle_with_hooks`, `run_pickles_sequential`/`run_pickles_sequential_with_hooks`, `run_pickles_parallel`/`run_pickles_parallel_with_hooks`.

**Step 1: Rewrite `run` to accept `RunOptions`**

The new signature:
```moonbit
pub async fn[W : @core.World] run(
  factory : () -> W,
  options : RunOptions,
) -> RunResult {
```

Internally it:
1. Extracts features, sinks, parallel, etc. from options
2. Creates `Setup::new()`, calls `configure`
3. Extracts `step_registry`, `param_registry`, `hook_registry`
4. Does all envelope emission (same as current `run`)
5. Runs before_test_run hooks
6. Dispatches to sequential/parallel (single path, no `_with_hooks` variants)
7. Runs after_test_run hooks
8. Emits TestRunFinished

**Step 2: Rewrite `execute_scenario` to handle hooks**

The merged function takes `hook_registry : @core.HookRegistry` as a parameter. If `hook_registry.by_type(BeforeTestCase)` is non-empty, run those hooks. Same for step hooks and AfterTestCase.

Key: The hooks are now closures registered on the **shared** Setup, not trait methods on the per-scenario world. The shared Setup's hooks capture the world0 instance. But for per-scenario isolation, we need fresh worlds... This means hooks registered in `configure` capture `self` (the world), and each scenario gets a fresh world+setup, so hooks are re-registered per scenario and capture the fresh world.

Look at how the current code works: `execute_pickle` creates a fresh world, calls `configure`, gets a fresh registry. The hooks registered in `configure` will capture the fresh `self`. So the `HookRegistry` from the per-scenario `Setup` has the right world reference.

The shared Setup (created once for envelope emission) gives us the hook metadata (IDs, types, source locations) for emitting `Hook` envelopes. The per-scenario Setup gives us the actual executable hooks.

**Step 3: Update `execute_pickle` to pass `HookRegistry`**

Single `execute_pickle` that:
1. Creates fresh world + Setup
2. Calls `configure`
3. Extracts `step_registry` and `hook_registry`
4. Passes both to `execute_scenario`

**Step 4: Remove all `_with_hooks` variants**

Delete:
- `run_with_hooks`
- `execute_pickle_with_hooks`
- `execute_scenario_with_hooks`
- `run_pickles_sequential_with_hooks`
- `run_pickles_parallel_with_hooks`

**Step 5: Update `run_or_fail`**

Update to accept `RunOptions` and forward to `run`.

**Step 6: Update all test files**

Update `src/runner/run_wbtest.mbt` and other test files that call `run(factory, features, ...)` to use `run(factory, RunOptions(features))`. For tests that used `run_with_hooks`, they should now register hooks via `configure` on their World and use `run(factory, RunOptions(features))`.

Update `src/runner/hooks_wbtest.mbt`:
- `HookWorld` should register hooks in `configure` instead of implementing `Hooks` trait
- `FailHookWorld` same
- The `run_with_hooks` e2e test becomes just `run`
- Unit tests that call `execute_scenario_with_hooks` directly need updating to call `execute_scenario` with a `HookRegistry`

**Step 7: Run tests**

Run: `mise run test:unit`
Run: `moon test --target js`
Expected: PASS

**Step 8: Commit**

```bash
git add src/runner/ src/core/
git commit -m "feat(runner)!: consolidate run/run_with_hooks into single run(factory, options)

BREAKING CHANGE: run() now takes RunOptions instead of individual parameters.
run_with_hooks() removed — register hooks via Setup.configure() instead."
```

---

## Task 5: Remove Hooks Trait, Update lib.mbt and Public API

**Files:**
- Delete contents of: `src/core/hooks.mbt` (or repurpose)
- Modify: `src/lib.mbt`
- Modify: `src/runner/hooks_wbtest.mbt` (verify no Hooks trait references remain)

**Context:** The `Hooks` trait is no longer needed. All hook functionality is now registration-based on `Setup`. Remove the trait and update the public API re-exports.

**Step 1: Remove Hooks trait**

In `src/core/hooks.mbt`, delete the entire `Hooks` trait and its default implementations. The file can either be deleted or repurposed for hook-related types if needed.

**Step 2: Update `src/lib.mbt`**

Remove:
```moonbit
trait Hooks,
type ScenarioInfo,
type StepInfo,
```

Add (if not already exported):
```moonbit
type Setup,
type HookRegistry,
type HookType,
type RunOptions,  // from runner
```

Remove `run_with_hooks` from runner re-exports. Add `RunOptions` if needed.

**Step 3: Search for any remaining `Hooks` trait references**

Search the entire codebase for `@core.Hooks`, `impl Hooks`, `Hooks::`, etc. Fix any remaining references.

**Step 4: Run tests**

Run: `mise run test:unit`
Run: `moon test --target js`
Expected: PASS

**Step 5: Commit**

```bash
git add src/core/hooks.mbt src/lib.mbt src/runner/
git commit -m "refactor(core)!: remove Hooks trait, hooks are now registered on Setup

BREAKING CHANGE: Hooks trait removed. Use setup.before_test_case(),
setup.after_test_case(), etc. in World.configure() instead."
```

---

## Task 6: Emit Hook Envelopes

**Files:**
- Modify: `src/runner/run.mbt`
- Modify: `src/runner/planner.mbt`
- Modify: `src/runner/run_wbtest.mbt`

**Context:** Emit `Hook` envelopes during the planning phase (after ParameterType, before TestCase). Emit `TestRunHookStarted`/`TestRunHookFinished` envelopes when executing before_test_run/after_test_run hooks.

**Step 1: Write failing tests**

In `src/runner/run_wbtest.mbt`, add a World that registers hooks and verify envelopes:

```moonbit
///|
struct HookEnvWorld {
  log : Array[String]
} derive(Default)

///|
impl @core.World for HookEnvWorld with configure(self, setup) {
  setup.before_test_case(fn(_info) {
    self.log.push("before")
  })
  setup.after_test_case(fn(_info, _result) {
    self.log.push("after")
  })
  setup.given("a step", fn(_args) {  })
}

///|
async test "run emits Hook envelopes for registered hooks" {
  let collector = CollectorSink::new()
  let opts = RunOptions([
    FeatureSource::Text("test://hooks", "Feature: H\n\n  Scenario: S\n    Given a step\n"),
  ])
    ..add_sink(collector)
  let _ = run(HookEnvWorld::default, opts)
  let mut hook_count = 0
  for env in collector.envelopes {
    if env is @cucumber_messages.Envelope::Hook(_) {
      hook_count += 1
    }
  }
  // 2 hooks: before_test_case + after_test_case
  assert_eq(hook_count, 2)
}

///|
async test "run emits Hook after ParameterType before TestCase" {
  let collector = CollectorSink::new()
  let opts = RunOptions([
    FeatureSource::Text("test://hook-order", "Feature: HO\n\n  Scenario: S\n    Given a step\n"),
  ])
    ..add_sink(collector)
  let _ = run(HookEnvWorld::default, opts)
  let mut sd_idx = -1
  let mut hook_idx = -1
  let mut tc_idx = -1
  for i, env in collector.envelopes {
    match env {
      @cucumber_messages.Envelope::StepDefinition(_) =>
        if sd_idx < 0 { sd_idx = i }
      @cucumber_messages.Envelope::Hook(_) =>
        if hook_idx < 0 { hook_idx = i }
      @cucumber_messages.Envelope::TestCase(_) =>
        if tc_idx < 0 { tc_idx = i }
      _ => ()
    }
  }
  assert_true(hook_idx > sd_idx)
  assert_true(hook_idx < tc_idx)
}
```

**Step 2: Add IdGenerator method**

In `src/runner/planner.mbt`:
```moonbit
///|
pub fn IdGenerator::next_hook_id(self : IdGenerator) -> String {
  self.next("hook")
}
```

**Step 3: Implement Hook envelope emission**

In `src/runner/run.mbt`, after ParameterType emission and before TestCase building, add:

```moonbit
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
      HookType::BeforeTestRun => "BEFORE_TEST_RUN"
      HookType::AfterTestRun => "AFTER_TEST_RUN"
      HookType::BeforeTestCase => "BEFORE_TEST_CASE"
      HookType::AfterTestCase => "AFTER_TEST_CASE"
      HookType::BeforeTestStep => "BEFORE_TEST_STEP"
      HookType::AfterTestStep => "AFTER_TEST_STEP"
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
```

Note: The `HookType` enum here is `@core.HookType`. Check the actual import path.

**Step 4: Implement TestRunHookStarted/Finished emission**

In `run()`, after emitting TestRunStarted, before dispatching to sequential/parallel:

```moonbit
// Execute before_test_run hooks
let before_run_hooks = setup.hook_registry().by_type(@core.HookType::BeforeTestRun)
for hook in before_run_hooks {
  let trhs_id = id_gen.next("trhs")
  if sinks.length() > 0 {
    // emit TestRunHookStarted
    let json : Json = {
      "testRunHookStarted": {
        "id": trhs_id.to_json(),
        "testRunStartedId": run_id.to_json(),
        "hookId": hook.id.to_json(),
        "timestamp": { "seconds": (0 : Int).to_json(), "nanos": (0 : Int).to_json() },
      },
    }
    let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch { _ => continue }
    emit(sinks, envelope)
  }
  let result_status = try {
    (hook.handler)(None, None)
    "PASSED"
  } catch {
    _ => "FAILED"
  }
  if sinks.length() > 0 {
    // emit TestRunHookFinished
    let json : Json = {
      "testRunHookFinished": {
        "testRunHookStartedId": trhs_id.to_json(),
        "result": {
          "duration": { "seconds": (0 : Int).to_json(), "nanos": (0 : Int).to_json() },
          "status": result_status.to_json(),
        },
        "timestamp": { "seconds": (0 : Int).to_json(), "nanos": (0 : Int).to_json() },
      },
    }
    let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch { _ => continue }
    emit(sinks, envelope)
  }
}
```

Do the same for `after_test_run` hooks after the test execution but before TestRunFinished.

**Step 5: Run tests**

Run: `mise run test:unit`
Run: `moon test --target js`
Expected: PASS

**Step 6: Commit**

```bash
git add src/runner/run.mbt src/runner/planner.mbt src/runner/run_wbtest.mbt
git commit -m "feat(runner): emit Hook and TestRunHookStarted/Finished envelopes"
```

---

## Task 7: Update TestCase to Include Hook Steps

**Files:**
- Modify: `src/runner/planner.mbt`
- Modify: `src/runner/run_wbtest.mbt`

**Context:** Per the cucumber protocol, `before_test_case`/`after_test_case` hooks appear as special test steps in the `TestCase` envelope, with a `hookId` field instead of `pickleStepId`. The executor already runs these hooks and should emit `TestStepStarted`/`TestStepFinished` for them.

**Step 1: Write failing test**

```moonbit
///|
async test "TestCase envelope includes hook steps" {
  let collector = CollectorSink::new()
  let opts = RunOptions([
    FeatureSource::Text("test://tc-hooks", "Feature: TC\n\n  Scenario: S\n    Given a step\n"),
  ])
    ..add_sink(collector)
  let _ = run(HookEnvWorld::default, opts)
  for env in collector.envelopes {
    match env {
      @cucumber_messages.Envelope::TestCase(tc) => {
        // Should have: before_test_case step + 1 regular step + after_test_case step = 3
        assert_eq(tc.testSteps.length(), 3)
        // First step should have hookId (before_test_case)
        assert_true(tc.testSteps[0].hookId is Some(_))
        // Middle step should have pickleStepId (regular step)
        assert_true(tc.testSteps[1].pickleStepId is Some(_))
        // Last step should have hookId (after_test_case)
        assert_true(tc.testSteps[2].hookId is Some(_))
      }
      _ => ()
    }
  }
}
```

**Step 2: Update `build_test_cases` in planner.mbt**

Modify `build_test_cases` to accept the shared `HookRegistry` and prepend/append hook steps:

```moonbit
pub fn build_test_cases(
  registry : @core.StepRegistry,
  hook_registry : @core.HookRegistry,
  pickles : Array[@cucumber_messages.Pickle],
  id_gen : IdGenerator,
) -> Array[@cucumber_messages.Envelope] {
```

For each pickle:
1. Add hook steps for `BeforeTestCase` hooks (with `hookId`)
2. Add regular steps (with `pickleStepId` and `stepDefinitionIds`)
3. Add hook steps for `AfterTestCase` hooks (with `hookId`)

Each hook step JSON:
```json
{
  "id": "ts-N",
  "hookId": "hook-1"
}
```

**Step 3: Update `TestCaseMapping` and executor**

The `test_step_ids` array now includes hook step IDs. The executor needs to emit `TestStepStarted`/`TestStepFinished` for hook steps too. Update `execute_scenario` to:
1. Execute before_test_case hook steps (emit TestStepStarted/Finished)
2. Execute regular steps (existing logic)
3. Execute after_test_case hook steps (emit TestStepStarted/Finished)

**Step 4: Run tests**

Run: `mise run test:unit`
Run: `moon test --target js`
Expected: PASS

**Step 5: Commit**

```bash
git add src/runner/planner.mbt src/runner/run.mbt src/runner/executor.mbt src/runner/run_wbtest.mbt
git commit -m "feat(runner): include hook steps in TestCase envelopes"
```

---

## Task 8: Update All Callers and Examples

**Files:**
- Modify: all files calling `run(factory, features, ...)` or `run_with_hooks`
- Modify: `examples/*/src/world.mbt` (remove Hooks trait impls, use Setup)
- Modify: `src/runner/*_wbtest.mbt`

**Context:** Update every test and example to use the new `run(factory, RunOptions(features))` API. Migrate any `Hooks` trait implementations to Setup-based registration.

**Step 1: Search and update**

Search for all files with:
- `run(` or `run_with_hooks(` in test files — update to `run(factory, RunOptions(features))`
- `impl @core.Hooks` or `impl Hooks` — migrate to Setup registration
- `run_or_fail(` — update signature

**Step 2: Update example worlds**

Check `examples/*/src/world.mbt` for any `Hooks` implementations and migrate them.

**Step 3: Run tests**

Run: `mise run test:unit`
Run: `moon test --target js`
Expected: PASS

**Step 4: Commit**

```bash
git add src/runner/ examples/
git commit -m "refactor: migrate all callers to run(factory, RunOptions) API"
```

---

## Task 9: Update Documentation

**Files:**
- Modify: `README.md`
- Modify: `README.mbt.md`
- Modify: `AGENTS.md`
- Modify: `examples/*/README.md`

**Context:** Update all documentation to reflect the new API: `RunOptions`, hook registration on Setup, removal of `Hooks` trait and `run_with_hooks`.

**Step 1: Update README.md**

- Replace `run(factory, features, ...)` examples with `run(factory, RunOptions(features))`
- Replace any `Hooks` trait examples with Setup-based hook registration
- Remove `run_with_hooks` references
- Add section on hook registration via Setup
- Show `RunOptions` builder pattern with `..` cascade

**Step 2: Update other docs**

Same changes in README.mbt.md, AGENTS.md, and example READMEs.

**Step 3: Commit**

```bash
git add README.md README.mbt.md AGENTS.md examples/
git commit -m "docs: update documentation for RunOptions and Setup-based hooks"
```

---

## Task 10: Final Cleanup

**Files:**
- Various (formatting, mbti regeneration)

**Step 1: Run moon fmt**

```bash
moon fmt
```

Revert any `.pkg` file changes if new syntax breaks build.

**Step 2: Regenerate .mbti files**

```bash
moon info
```

**Step 3: Run full test suite**

```bash
mise run test:unit
moon test --target js
```

**Step 4: Commit if changes**

```bash
git add -A
git commit -m "chore: moon fmt and regenerate mbti interfaces"
```

---

## Execution Order Summary

| Task | Description |
|------|-------------|
| 1 | Add HookRegistry to core |
| 2 | Add hook registration to Setup with #callsite |
| 3 | Add RunOptions with struct constructor |
| 4 | Consolidate runner — merge run/run_with_hooks |
| 5 | Remove Hooks trait, update public API |
| 6 | Emit Hook and TestRunHookStarted/Finished envelopes |
| 7 | Update TestCase to include hook steps |
| 8 | Update all callers and examples |
| 9 | Update documentation |
| 10 | Final cleanup |
