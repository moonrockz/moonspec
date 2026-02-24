# Test Case Retry Logic Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add configurable retry logic for failed test cases using `@async.retry`, with global and per-scenario `@retry(N)` tag support.

**Architecture:** Retry wraps `execute_pickle()` using `@async.retry(Immediate)`. On failure, the scenario re-executes with a fresh world, emitting new `TestCaseStarted`/`TestCaseFinished` envelope pairs per attempt. Only the final attempt's result feeds into `RunResult`. The retry count resolves from `@retry(N)` tag first, then `RunOptions.retries_` global default, then 0.

**Tech Stack:** MoonBit, `moonbitlang/async` (retry), Cucumber Messages protocol

---

### Task 1: Add `retries` field to RunOptions

**Files:**
- Modify: `src/runner/options.mbt`
- Test: `src/runner/options_wbtest.mbt`

**Step 1: Write the failing test**

Add to `src/runner/options_wbtest.mbt`:

```moonbit
///|
test "retries defaults to zero" {
  let opts = RunOptions::new([])
  assert_eq(opts.get_retries(), 0)
}

///|
test "retries can be set" {
  let opts = RunOptions::new([])
  opts.retries(3)
  assert_eq(opts.get_retries(), 3)
}
```

**Step 2: Run test to verify it fails**

Run: `moon test --target js`
Expected: FAIL — `get_retries` does not exist

**Step 3: Write minimal implementation**

In `src/runner/options.mbt`, add the field to `RunOptions`:

```moonbit
pub(all) struct RunOptions {
  priv features_ : Array[FeatureSource]
  priv mut parallel_ : Bool
  priv mut max_concurrent_ : Int
  priv sinks_ : Array[&@core.MessageSink]
  priv mut tag_expr_ : String
  priv mut scenario_name_ : String
  priv mut retries_ : Int

  fn new(features : Array[FeatureSource]) -> RunOptions
}
```

Update the constructor to initialize `retries_: 0`:

```moonbit
pub fn RunOptions::new(features : Array[FeatureSource]) -> RunOptions {
  {
    features_: features,
    parallel_: false,
    max_concurrent_: 4,
    sinks_: [],
    tag_expr_: "",
    scenario_name_: "",
    retries_: 0,
  }
}
```

Add setter and getter:

```moonbit
///|
/// Set the global retry count for failed scenarios.
pub fn RunOptions::retries(self : RunOptions, value : Int) -> Unit {
  self.retries_ = value
}

///|
/// Get the global retry count.
pub fn RunOptions::get_retries(self : RunOptions) -> Int {
  self.retries_
}
```

**Step 4: Run test to verify it passes**

Run: `moon test --target js`
Expected: All tests pass (234 + 2 new = 236)

**Step 5: Commit**

```bash
git add src/runner/options.mbt src/runner/options_wbtest.mbt
git commit -m "feat(runner): add retries field to RunOptions"
```

---

### Task 2: Add `parse_retry_tag` helper

**Files:**
- Modify: `src/runner/run.mbt`
- Test: `src/runner/run_wbtest.mbt`

**Step 1: Write the failing tests**

Add to `src/runner/run_wbtest.mbt`:

```moonbit
///|
test "parse_retry_tag returns None when no retry tag" {
  let result = parse_retry_tag(["@smoke", "@slow"])
  assert_eq(result, None)
}

///|
test "parse_retry_tag extracts count from @retry(N)" {
  let result = parse_retry_tag(["@smoke", "@retry(3)"])
  assert_eq(result, Some(3))
}

///|
test "parse_retry_tag returns None for empty tags" {
  let result = parse_retry_tag([])
  assert_eq(result, None)
}

///|
test "parse_retry_tag handles @retry(1)" {
  let result = parse_retry_tag(["@retry(1)"])
  assert_eq(result, Some(1))
}
```

**Step 2: Run test to verify it fails**

Run: `moon test --target js`
Expected: FAIL — `parse_retry_tag` does not exist

**Step 3: Write minimal implementation**

Add to `src/runner/run.mbt`:

```moonbit
///|
/// Parse a retry count from pickle tags. Returns Some(n) if @retry(n) is found.
fn parse_retry_tag(tags : Array[String]) -> Int? {
  for tag in tags {
    if tag.starts_with("@retry(") && tag.ends_with(")") {
      let inner = tag.substring(start=7, end=tag.length() - 1)
      let n = try { @strconv.parse_int(inner)! } catch { _ => continue }
      return Some(n)
    }
  }
  None
}
```

Check if `@strconv` is available. If not, use a simple manual parse approach:

```moonbit
///|
/// Parse a retry count from pickle tags. Returns Some(n) if @retry(n) is found.
fn parse_retry_tag(tags : Array[String]) -> Int? {
  for tag in tags {
    if tag.starts_with("@retry(") && tag.ends_with(")") {
      let inner = tag.substring(start=7, end=tag.length() - 1)
      let mut n = 0
      let mut valid = true
      for ch in inner {
        if ch >= '0' && ch <= '9' {
          n = n * 10 + (ch.to_int() - '0'.to_int())
        } else {
          valid = false
          break
        }
      }
      if valid && inner.length() > 0 {
        return Some(n)
      }
    }
  }
  None
}
```

Note: MoonBit's `String` has `starts_with` and `ends_with`. If `@strconv.parse_int` is available from the existing imports, prefer that. Otherwise use the manual parse. The implementer should check what's available and pick the simplest option that compiles.

**Step 4: Run test to verify it passes**

Run: `moon test --target js`
Expected: All tests pass (236 + 4 new = 240)

**Step 5: Commit**

```bash
git add src/runner/run.mbt src/runner/run_wbtest.mbt
git commit -m "feat(runner): add parse_retry_tag helper"
```

---

### Task 3: Add `retried` field to RunSummary

**Files:**
- Modify: `src/runner/results.mbt`
- Test: `src/runner/results_wbtest.mbt`

**Step 1: Write the failing test**

Add to `src/runner/results_wbtest.mbt`:

```moonbit
///|
test "RunSummary includes retried field" {
  let summary : RunSummary = {
    total_scenarios: 5,
    passed: 4,
    failed: 1,
    undefined: 0,
    pending: 0,
    skipped: 0,
    retried: 2,
    duration_ms: 0L,
  }
  assert_eq(summary.retried, 2)
}
```

**Step 2: Run test to verify it fails**

Run: `moon test --target js`
Expected: FAIL — `retried` field does not exist on `RunSummary`

**Step 3: Write minimal implementation**

Update `RunSummary` in `src/runner/results.mbt`:

```moonbit
pub(all) struct RunSummary {
  total_scenarios : Int
  passed : Int
  failed : Int
  undefined : Int
  pending : Int
  skipped : Int
  retried : Int
  duration_ms : Int64
} derive(Show, Eq)
```

Then update `compute_summary` in `src/runner/run.mbt` to initialize `retried: 0`:

```moonbit
fn compute_summary(features : Array[FeatureResult]) -> RunSummary {
  // ... existing counting logic ...
  {
    total_scenarios: total,
    passed,
    failed,
    undefined,
    pending,
    skipped,
    retried: 0,
    duration_ms: 0L,
  }
}
```

Also fix any other places that construct `RunSummary` literals (search for `RunSummary` constructors in test files — there may be existing tests that need `retried: 0` added).

**Step 4: Run test to verify it passes**

Run: `moon test --target js`
Expected: All tests pass (240 + 1 new = 241)

**Step 5: Commit**

```bash
git add src/runner/results.mbt src/runner/results_wbtest.mbt src/runner/run.mbt
git commit -m "feat(runner): add retried field to RunSummary"
```

---

### Task 4: Update envelope helpers for retry support

**Files:**
- Modify: `src/runner/run.mbt`

**Step 1: Update `make_test_case_started_envelope` to accept `attempt` parameter**

Change the signature and body in `src/runner/run.mbt`:

```moonbit
fn make_test_case_started_envelope(
  id : String,
  test_case_id : String,
  attempt~ : Int = 0,
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
```

**Step 2: Update `make_test_case_finished_envelope` to accept `will_be_retried` parameter**

```moonbit
fn make_test_case_finished_envelope(
  test_case_started_id : String,
  will_be_retried~ : Bool = false,
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
```

**Step 3: Run tests to verify nothing breaks**

Run: `moon test --target js`
Expected: All tests pass (241). The new parameters are optional with defaults matching the old behavior, so existing callers are unaffected.

**Step 4: Commit**

```bash
git add src/runner/run.mbt
git commit -m "feat(runner): add attempt and will_be_retried params to envelope helpers"
```

---

### Task 5: Implement retry logic in `execute_pickle`

This is the core task. `execute_pickle` gets a retry loop using `@async.retry`.

**Files:**
- Modify: `src/runner/run.mbt`
- Modify: `src/runner/parallel.mbt`

**Step 1: Add `retries` parameter to execution functions**

Thread the retries count through `run` → `run_pickles_sequential`/`run_pickles_parallel` → `execute_pickle`.

In `run_pickles_sequential`, add `retries? : Int = 0`:

```moonbit
fn[W : @core.World] run_pickles_sequential(
  factory : () -> W,
  pickles : Array[@cucumber_messages.Pickle],
  sinks? : Array[&@core.MessageSink] = [],
  tc_mappings? : Map[String, TestCaseMapping] = {},
  id_gen? : IdGenerator = IdGenerator::new(),
  retries? : Int = 0,
) -> Array[ScenarioResult] {
  let results : Array[ScenarioResult] = []
  for pickle in pickles {
    let result = execute_pickle(factory, pickle, sinks~, tc_mappings~, id_gen~, retries~)
    results.push(result)
  }
  results
}
```

In `run_pickles_parallel` (in `src/runner/parallel.mbt`), add `retries? : Int = 0`:

```moonbit
async fn[W : @core.World] run_pickles_parallel(
  factory : () -> W,
  pickles : Array[@cucumber_messages.Pickle],
  max_concurrent~ : Int,
  sinks? : Array[&@core.MessageSink] = [],
  tc_mappings? : Map[String, TestCaseMapping] = {},
  id_gen? : IdGenerator = IdGenerator::new(),
  retries? : Int = 0,
) -> Array[ScenarioResult] {
  let tasks : Array[async () -> ScenarioResult] = pickles.map(fn(pickle) {
    fn() -> ScenarioResult {
      execute_pickle(factory, pickle, sinks~, tc_mappings~, id_gen~, retries~)
    }
  })
  @async.all(tasks[:], max_concurrent~)
}
```

**Step 2: Rewrite `execute_pickle` with retry logic**

The key change: when `max_retries > 0`, use `@async.retry` to wrap the scenario execution. Each attempt emits its own `TestCaseStarted`/`TestCaseFinished` pair. A mutable `attempt` counter tracks the attempt number. On failure with retries remaining, the function raises to trigger the next retry.

```moonbit
///|
/// Error raised to signal a failed attempt that should be retried.
type! RetryableFailure ScenarioResult

///|
/// Execute a single pickle with a fresh world, with optional retry.
async fn[W : @core.World] execute_pickle(
  factory : () -> W,
  pickle : @cucumber_messages.Pickle,
  sinks? : Array[&@core.MessageSink] = [],
  tc_mappings? : Map[String, TestCaseMapping] = {},
  id_gen? : IdGenerator = IdGenerator::new(),
  retries? : Int = 0,
) -> ScenarioResult {
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
  let attempt = { val: 0 }
  let execute_attempt : async () -> ScenarioResult = fn() {
    let current_attempt = attempt.val
    attempt.val += 1
    let world = factory()
    let setup = @core.Setup::new()
    @core.World::configure(world, setup)
    let registry = setup.step_registry()
    let hook_registry = setup.hook_registry()
    // Emit TestCaseStarted
    let tcs_id = if mapping is Some(_) {
      let tcs_id = id_gen.next("tcs")
      if sinks.length() > 0 {
        emit(
          sinks,
          make_test_case_started_envelope(tcs_id, test_case_id, attempt=current_attempt),
        )
      }
      Some(tcs_id)
    } else {
      None
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
    )
    // Determine if this attempt failed and has retries left
    let is_failed = result.status != ScenarioStatus::Passed
    let has_retries_left = current_attempt < max_retries
    // Emit TestCaseFinished
    match tcs_id {
      Some(id) =>
        if sinks.length() > 0 {
          emit(
            sinks,
            make_test_case_finished_envelope(
              id,
              will_be_retried=(is_failed && has_retries_left),
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
  if max_retries > 0 {
    @async.retry(
      @async.Immediate,
      max_retry=max_retries,
      fatal_error=fn(e) { not(e is RetryableFailure(_)) },
      execute_attempt,
    )
  } else {
    // No retries — fast path, same as original behavior
    execute_attempt()
  }
}
```

**Important notes for the implementer:**
- `execute_pickle` must become `async` because `@async.retry` is async.
- The `{ val: 0 }` pattern uses a `Ref[Int]` or a mutable struct — check what MoonBit supports. A simple approach is `let attempt : Ref[Int] = { val: 0 }` since MoonBit has `Ref`.
- The `RetryableFailure` error type wraps the failed `ScenarioResult` so we can extract it if needed.
- `fatal_error` returns `true` for non-`RetryableFailure` errors (e.g., unexpected panics), so those don't get retried.

**Step 3: Update callers in `run()`**

In the `run` function, pass `retries` to the execution functions:

```moonbit
let retries = options.get_retries()
let results = if options.is_parallel() {
  run_pickles_parallel(
    factory,
    filtered,
    max_concurrent=options.get_max_concurrent(),
    sinks~,
    tc_mappings~,
    id_gen~,
    retries~,
  )
} else {
  run_pickles_sequential(factory, filtered, sinks~, tc_mappings~, id_gen~, retries~)
}
```

**Step 4: Run tests to verify nothing breaks**

Run: `moon test --target js`
Expected: All tests pass (241). Existing tests have retries=0 so the fast path is taken.

**Step 5: Commit**

```bash
git add src/runner/run.mbt src/runner/parallel.mbt
git commit -m "feat(runner): implement retry logic in execute_pickle using @async.retry"
```

---

### Task 6: Wire `retried` count into `compute_summary` and add E2E tests

**Files:**
- Modify: `src/runner/run.mbt`
- Modify: `src/runner/e2e_wbtest.mbt`

**Step 1: Write the E2E tests**

Add to `src/runner/e2e_wbtest.mbt`:

```moonbit
///|
struct RetryWorld {
  mut call_count : Int
} derive(Default)

///|
impl @core.World for RetryWorld with configure(self, setup) {
  setup.given("a step that fails once", fn(_ctx) raise {
    self.call_count += 1
    if self.call_count <= 1 {
      raise Failure::Failure("transient failure")
    }
  })
  setup.given("a step that always passes", fn(_ctx) {  })
}

///|
async test "retry: failed scenario retries and passes on second attempt" {
  let content =
    #|Feature: Retry
    #|
    #|  @retry(1)
    #|  Scenario: Flaky
    #|    Given a step that fails once
  let result = run(
    RetryWorld::default,
    RunOptions([FeatureSource::Text("test://retry", content)]),
  )
  assert_eq(result.summary.passed, 1)
  assert_eq(result.summary.failed, 0)
  assert_eq(result.summary.retried, 1)
}

///|
async test "retry: scenario without retry tag uses global retries" {
  let content =
    #|Feature: GlobalRetry
    #|
    #|  Scenario: Flaky
    #|    Given a step that fails once
  let opts = RunOptions([FeatureSource::Text("test://global-retry", content)])
  opts.retries(1)
  let result = run(RetryWorld::default, opts)
  assert_eq(result.summary.passed, 1)
  assert_eq(result.summary.failed, 0)
  assert_eq(result.summary.retried, 1)
}

///|
async test "retry: no retry when retries is zero" {
  let content =
    #|Feature: NoRetry
    #|
    #|  Scenario: Flaky
    #|    Given a step that fails once
  let result = run(
    RetryWorld::default,
    RunOptions([FeatureSource::Text("test://no-retry", content)]),
  )
  assert_eq(result.summary.passed, 0)
  assert_eq(result.summary.failed, 1)
  assert_eq(result.summary.retried, 0)
}

///|
async test "retry: passing scenario is not counted as retried" {
  let content =
    #|Feature: NoRetryNeeded
    #|
    #|  @retry(2)
    #|  Scenario: Stable
    #|    Given a step that always passes
  let result = run(
    RetryWorld::default,
    RunOptions([FeatureSource::Text("test://stable", content)]),
  )
  assert_eq(result.summary.passed, 1)
  assert_eq(result.summary.retried, 0)
}
```

**Step 2: Run test to verify they fail**

Run: `moon test --target js`
Expected: The retry tests should fail because `compute_summary` always sets `retried: 0` and the retry logic may not correctly track retried scenarios yet.

**Step 3: Wire retried count into results**

The approach: `execute_pickle` returns a `ScenarioResult`. We need to know if a scenario was retried. The simplest approach is to return a tuple or add a wrapper. However, to keep `ScenarioResult` unchanged, we can track retried pickles at the run level.

**Option A — Add tracking to `ScenarioResult`:** Not ideal per design doc ("ScenarioResult stays the same").

**Option B — Return retried count alongside results:** Change `execute_pickle` to return `(ScenarioResult, Bool)` where the `Bool` indicates "was retried". Thread this through `run_pickles_sequential` and `run_pickles_parallel`.

**Recommended: Option B.**

Update `execute_pickle` return type to `(ScenarioResult, Bool)`:

The `Bool` is `true` if `attempt.val > 1` after execution (meaning more than one attempt was made).

Update `run_pickles_sequential` and `run_pickles_parallel` to return `Array[(ScenarioResult, Bool)]`.

Update `run()` to extract the retried count from the results and pass to `compute_summary`:

```moonbit
fn compute_summary(features : Array[FeatureResult], retried~ : Int = 0) -> RunSummary {
  // ... existing counting ...
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
```

In `run()`, after collecting results:

```moonbit
let retried_count = paired_results.iter().fold(init=0, fn(acc, pair) {
  if pair.1 { acc + 1 } else { acc }
})
// ... group results (extract .0 from each pair) ...
let summary = compute_summary(feature_results, retried=retried_count)
```

**Step 4: Run test to verify they pass**

Run: `moon test --target js`
Expected: All tests pass (241 + 4 new = 245)

**Step 5: Commit**

```bash
git add src/runner/run.mbt src/runner/parallel.mbt src/runner/e2e_wbtest.mbt
git commit -m "feat(runner): wire retried count into RunSummary and add E2E retry tests"
```

---

### Task 7: Envelope E2E test for retry attempts

Verify that the Cucumber Messages envelope stream contains the correct `attempt` values and `willBeRetried` flags.

**Files:**
- Modify: `src/runner/e2e_wbtest.mbt`

**Step 1: Write the test**

```moonbit
///|
async test "retry: envelope stream contains multiple TestCaseStarted attempts" {
  let content =
    #|Feature: RetryEnvelopes
    #|
    #|  @retry(1)
    #|  Scenario: Flaky
    #|    Given a step that fails once
  let collector = CollectorSink::new()
  let opts = RunOptions([FeatureSource::Text("test://retry-env", content)])
  opts.add_sink(collector)
  let _ = run(RetryWorld::default, opts)
  // Should have 2 TestCaseStarted (attempt 0 and attempt 1)
  let mut tcs_count = 0
  let mut tcf_will_retry_count = 0
  for env in collector.envelopes {
    match env {
      @cucumber_messages.Envelope::TestCaseStarted(tcs) => {
        // First attempt=0, second attempt=1
        assert_eq(tcs.attempt, tcs_count)
        tcs_count += 1
      }
      @cucumber_messages.Envelope::TestCaseFinished(tcf) =>
        if tcf.willBeRetried {
          tcf_will_retry_count += 1
        }
      _ => ()
    }
  }
  assert_eq(tcs_count, 2)
  assert_eq(tcf_will_retry_count, 1) // First attempt has willBeRetried=true
}
```

**Step 2: Run test to verify it passes**

Run: `moon test --target js`
Expected: PASS (245 + 1 = 246). This test exercises the full envelope emission from Task 5.

**Step 3: Commit**

```bash
git add src/runner/e2e_wbtest.mbt
git commit -m "test: add envelope E2E test for retry attempt tracking"
```

---

### Task 8: Formatting, mbti regeneration, and re-exports

**Files:**
- Modify: various (formatting)
- Modify: `src/runner/pkg.generated.mbti`

**Step 1: Run moon fmt**

```bash
moon fmt
```

**Step 2: Regenerate mbti**

```bash
moon info --target js
```

**Step 3: Run tests to verify everything still works**

Run: `moon test --target js`
Expected: All tests pass (246)

**Step 4: Commit**

```bash
git add -A
git commit -m "chore: moon fmt, regenerate mbti for retry support"
```
