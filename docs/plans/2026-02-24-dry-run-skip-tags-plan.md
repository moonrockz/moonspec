# Dry-Run Mode & Skip Tags Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add dry-run mode, skip-with-reason, and configurable @skip/@ignore tag support to moonspec.

**Architecture:** Change `StepStatus::Skipped` and `ScenarioStatus::Skipped` to carry an optional reason string. Add `dry_run` and `skip_tags` fields to `RunOptions`. Thread dry-run flag through the execution chain to skip handlers and hooks. Check skip tags in `execute_pickle` to skip entire scenarios before execution.

**Tech Stack:** MoonBit, Cucumber Messages protocol, moonspec runner

---

### Task 1: Change StepStatus::Skipped to Skipped(String?)

**Files:**
- Modify: `src/runner/results.mbt:14` — change `Skipped` to `Skipped(String?)`
- Modify: `src/runner/results.mbt:33` — change `ScenarioStatus::Skipped` to `Skipped(String?)`
- Modify: `src/runner/results.mbt:50` — update `from_steps` match arm
- Modify: `src/runner/results.mbt:61` — propagate reason in `from_steps` return
- Modify: `src/runner/results_wbtest.mbt` — update existing tests, add new ones
- Modify: `src/runner/executor.mbt:170,272` — update `StepStatus::Skipped` to `Skipped(None)`
- Modify: `src/runner/executor_wbtest.mbt:85` — update `StepStatus::Skipped` match
- Modify: `src/runner/hooks_wbtest.mbt:176` — update `StepStatus::Skipped` match
- Modify: `src/runner/run.mbt:303` — update `step_status_to_string` match
- Modify: `src/runner/run.mbt:1035` — update `compute_summary` match

**Step 1: Update the enums in results.mbt**

Change `StepStatus::Skipped` to `Skipped(String?)`:

```moonbit
pub(all) enum StepStatus {
  Passed
  Failed(String)
  Skipped(String?)
  Undefined
  Pending
} derive(Show, Eq)
```

Change `ScenarioStatus::Skipped` to `Skipped(String?)`:

```moonbit
pub(all) enum ScenarioStatus {
  Passed
  Failed
  Skipped(String?)
  Undefined
  Pending
} derive(Show, Eq)
```

Update `ScenarioStatus::from_steps` — track the first skip reason:

```moonbit
pub fn ScenarioStatus::from_steps(steps : Array[StepStatus]) -> ScenarioStatus {
  let mut has_failed = false
  let mut has_undefined = false
  let mut has_pending = false
  let mut skip_reason : String?? = None  // None = not skipped, Some(r) = skipped with reason r
  for step in steps {
    match step {
      StepStatus::Failed(_) => has_failed = true
      StepStatus::Undefined => has_undefined = true
      StepStatus::Pending => has_pending = true
      StepStatus::Skipped(reason) =>
        if skip_reason is None {
          skip_reason = Some(reason)
        }
      StepStatus::Passed => ()
    }
  }
  if has_failed {
    ScenarioStatus::Failed
  } else if has_undefined {
    ScenarioStatus::Undefined
  } else if has_pending {
    ScenarioStatus::Pending
  } else if skip_reason is Some(reason) {
    ScenarioStatus::Skipped(reason)
  } else {
    ScenarioStatus::Passed
  }
}
```

**Step 2: Fix all pattern matches across the codebase**

In `src/runner/executor.mbt`, change both occurrences of `StepStatus::Skipped` (lines 170 and 272) to:
```moonbit
status: StepStatus::Skipped(None),
```

In `src/runner/run.mbt`, update `step_status_to_string` (line 303):
```moonbit
StepStatus::Skipped(_) => "SKIPPED"
```

In `src/runner/run.mbt`, update `step_status_message` to also return skip reason:
```moonbit
fn step_status_message(status : StepStatus) -> String? {
  match status {
    StepStatus::Failed(msg) => Some(msg)
    StepStatus::Skipped(reason) => reason
    _ => None
  }
}
```

In `src/runner/run.mbt`, update `compute_summary` (line 1035):
```moonbit
ScenarioStatus::Skipped(_) => skipped = skipped + 1
```

**Step 3: Update existing tests**

In `src/runner/results_wbtest.mbt`, update the Skipped show test:
```moonbit
test "StepStatus::Skipped shows correctly" {
  inspect(StepStatus::Skipped(None), content="Skipped(None)")
}
```

Add new test for Skipped with reason:
```moonbit
test "StepStatus::Skipped with reason shows correctly" {
  inspect(StepStatus::Skipped(Some("dry run")), content="Skipped(Some(\"dry run\"))")
}

test "ScenarioStatus from all skipped propagates reason" {
  let result = ScenarioStatus::from_steps([
    StepStatus::Skipped(Some("dry run")),
    StepStatus::Skipped(Some("dry run")),
  ])
  assert_eq(result, ScenarioStatus::Skipped(Some("dry run")))
}

test "ScenarioStatus from skipped without reason" {
  let result = ScenarioStatus::from_steps([StepStatus::Skipped(None)])
  assert_eq(result, ScenarioStatus::Skipped(None))
}
```

In `src/runner/executor_wbtest.mbt` line 85, update:
```moonbit
assert_eq(result.steps[2].status, StepStatus::Skipped(None))
```

In `src/runner/hooks_wbtest.mbt` line 176, update:
```moonbit
assert_eq(result.steps[0].status, StepStatus::Skipped(None))
```

**Step 4: Run tests**

Run: `mise run test:unit`
Expected: All 249 tests pass

**Step 5: Commit**

```bash
git add src/runner/results.mbt src/runner/results_wbtest.mbt src/runner/executor.mbt src/runner/executor_wbtest.mbt src/runner/hooks_wbtest.mbt src/runner/run.mbt
git commit -m "feat(runner): change Skipped to Skipped(String?) for skip reason support"
```

---

### Task 2: Add dry_run and skip_tags fields to RunOptions

**Files:**
- Modify: `src/runner/options.mbt` — add fields, constructor defaults, getter/setter methods
- Modify: `src/runner/options_wbtest.mbt` — add tests

**Step 1: Write tests first**

Add to `src/runner/options_wbtest.mbt`:
```moonbit
test "dry_run defaults to false" {
  let opts = RunOptions::new([])
  assert_false(opts.is_dry_run())
}

test "dry_run can be enabled" {
  let opts = RunOptions::new([])
  opts.dry_run(true)
  assert_true(opts.is_dry_run())
}

test "skip_tags defaults to @skip and @ignore" {
  let opts = RunOptions::new([])
  assert_eq(opts.get_skip_tags(), ["@skip", "@ignore"])
}

test "skip_tags can be customized" {
  let opts = RunOptions::new([])
  opts.skip_tags(["@skip", "@wip"])
  assert_eq(opts.get_skip_tags(), ["@skip", "@wip"])
}
```

**Step 2: Run tests to verify they fail**

Run: `mise run test:unit`
Expected: FAIL — fields and methods don't exist yet

**Step 3: Implement**

Add fields to `RunOptions` struct:
```moonbit
pub(all) struct RunOptions {
  priv features_ : Array[FeatureSource]
  priv mut parallel_ : Bool
  priv mut max_concurrent_ : Int
  priv sinks_ : Array[&@core.MessageSink]
  priv mut tag_expr_ : String
  priv mut scenario_name_ : String
  priv mut retries_ : Int
  priv mut dry_run_ : Bool
  priv skip_tags_ : Array[String]

  fn new(features : Array[FeatureSource]) -> RunOptions
}
```

Update constructor:
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
    dry_run_: false,
    skip_tags_: ["@skip", "@ignore"],
  }
}
```

Add methods:
```moonbit
///|
/// Enable or disable dry-run mode.
///
/// When enabled, steps are matched against definitions but handlers are not
/// executed. All hooks are skipped. Matched steps report as
/// `Skipped(Some("dry run"))` and undefined steps remain `Undefined`.
///
/// ```moonbit nocheck
/// let opts = RunOptions::new(features)
/// opts.dry_run(true) // validate step wiring without execution
/// ```
pub fn RunOptions::dry_run(self : RunOptions, value : Bool) -> Unit {
  self.dry_run_ = value
}

///|
/// Check if dry-run mode is enabled.
pub fn RunOptions::is_dry_run(self : RunOptions) -> Bool {
  self.dry_run_
}

///|
/// Set the tags that cause scenarios to be skipped.
///
/// Scenarios with any of these tags are skipped without executing steps or
/// hooks. Tags may include a reason: `@skip("reason")`. The reason is
/// extracted and attached to the skip status.
///
/// Defaults to `["@skip", "@ignore"]`.
///
/// ```moonbit nocheck
/// let opts = RunOptions::new(features)
/// opts.skip_tags(["@skip", "@ignore", "@wip"])
/// ```
pub fn RunOptions::skip_tags(self : RunOptions, tags : Array[String]) -> Unit {
  self.skip_tags_.clear()
  for tag in tags {
    self.skip_tags_.push(tag)
  }
}

///|
/// Get the configured skip tags.
pub fn RunOptions::get_skip_tags(self : RunOptions) -> Array[String] {
  self.skip_tags_
}
```

**Step 4: Run tests**

Run: `mise run test:unit`
Expected: All tests pass (249 + 4 new = 253)

**Step 5: Commit**

```bash
git add src/runner/options.mbt src/runner/options_wbtest.mbt
git commit -m "feat(runner): add dry_run and skip_tags fields to RunOptions"
```

---

### Task 3: Add parse_skip_tag helper

**Files:**
- Modify: `src/runner/run.mbt` — add `parse_skip_tag` function
- Modify: `src/runner/run_wbtest.mbt` — add tests

**Step 1: Write tests**

Add to `src/runner/run_wbtest.mbt`:
```moonbit
test "parse_skip_tag returns None when no skip tag present" {
  let result = parse_skip_tag(["@smoke", "@fast"], ["@skip", "@ignore"])
  assert_eq(result, None)
}

test "parse_skip_tag matches bare @skip tag" {
  let result = parse_skip_tag(["@smoke", "@skip"], ["@skip", "@ignore"])
  assert_eq(result, Some("skip"))
}

test "parse_skip_tag matches bare @ignore tag" {
  let result = parse_skip_tag(["@ignore", "@smoke"], ["@skip", "@ignore"])
  assert_eq(result, Some("ignore"))
}

test "parse_skip_tag extracts reason from @skip(\"reason\")" {
  let result = parse_skip_tag(["@skip(\"flaky on CI\")"], ["@skip", "@ignore"])
  assert_eq(result, Some("flaky on CI"))
}

test "parse_skip_tag extracts reason from @ignore(\"reason\")" {
  let result = parse_skip_tag(["@ignore(\"not implemented\")"], ["@skip", "@ignore"])
  assert_eq(result, Some("not implemented"))
}

test "parse_skip_tag uses tag name for @skip() with empty parens" {
  let result = parse_skip_tag(["@skip()"], ["@skip", "@ignore"])
  assert_eq(result, Some("skip"))
}

test "parse_skip_tag uses tag name for @skip(no quotes)" {
  let result = parse_skip_tag(["@skip(no quotes)"], ["@skip", "@ignore"])
  assert_eq(result, Some("skip"))
}

test "parse_skip_tag works with custom skip tags" {
  let result = parse_skip_tag(["@wip"], ["@wip"])
  assert_eq(result, Some("wip"))
}

test "parse_skip_tag returns first match" {
  let result = parse_skip_tag(["@ignore(\"a\")", "@skip(\"b\")"], ["@skip", "@ignore"])
  assert_eq(result, Some("a"))
}
```

**Step 2: Run tests to verify they fail**

Run: `mise run test:unit`
Expected: FAIL — `parse_skip_tag` doesn't exist yet

**Step 3: Implement**

Add to `src/runner/run.mbt` (near `parse_retry_tag`):

```moonbit
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
    for skip in skip_tags {
      let skip_len = skip.length()
      let tag_len = tag.length()
      // Exact match: bare tag like @skip
      if tag == skip {
        // Strip leading @ for the reason
        let reason = if skip_len > 1 && skip[0] == '@' {
          skip.substring(start=1, end=skip_len)
        } else {
          skip
        }
        return Some(reason)
      }
      // Parameterized match: @skip("reason") or @skip(...)
      if tag_len > skip_len &&
        tag.substring(start=0, end=skip_len) == skip &&
        tag[skip_len] == '(' &&
        tag[tag_len - 1] == ')' {
        let inner = tag.substring(start=skip_len + 1, end=tag_len - 1)
        let inner_len = inner.length()
        // Extract quoted reason: "reason"
        if inner_len >= 2 && inner[0] == '"' && inner[inner_len - 1] == '"' {
          let reason = inner.substring(start=1, end=inner_len - 1)
          if reason.length() > 0 {
            return Some(reason)
          }
        }
        // Fall back to tag name for invalid formats
        let reason = if skip_len > 1 && skip[0] == '@' {
          skip.substring(start=1, end=skip_len)
        } else {
          skip
        }
        return Some(reason)
      }
    }
  }
  None
}
```

**Step 4: Run tests**

Run: `mise run test:unit`
Expected: All tests pass

**Step 5: Commit**

```bash
git add src/runner/run.mbt src/runner/run_wbtest.mbt
git commit -m "feat(runner): add parse_skip_tag helper for @skip/@ignore tags"
```

---

### Task 4: Implement dry-run in execute_scenario

**Files:**
- Modify: `src/runner/executor.mbt:64-75` — add `dry_run?` parameter
- Modify: `src/runner/executor_wbtest.mbt` — add dry-run tests

**Step 1: Write tests**

Add to `src/runner/executor_wbtest.mbt`:
```moonbit
test "execute_scenario dry-run matches steps without executing" {
  let setup = @core.Setup::new()
  let mut executed = false
  setup.given("a defined step", fn(_ctx) { executed = true })
  let registry = setup.step_registry()
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "a defined step",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: None,
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test",
    scenario_name="Dry",
    pickle_id="p-dry-1",
    tags=[],
    steps~,
    dry_run=true,
  )
  assert_false(executed)
  assert_eq(result.steps[0].status, StepStatus::Skipped(Some("dry run")))
  assert_eq(result.status, ScenarioStatus::Skipped(Some("dry run")))
}

test "execute_scenario dry-run still reports undefined steps" {
  let setup = @core.Setup::new()
  let registry = setup.step_registry()
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "a step that does not exist",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: None,
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test",
    scenario_name="Dry Undef",
    pickle_id="p-dry-2",
    tags=[],
    steps~,
    dry_run=true,
  )
  assert_eq(result.steps[0].status, StepStatus::Undefined)
  assert_eq(result.status, ScenarioStatus::Undefined)
}

test "execute_scenario dry-run skips hooks" {
  let setup = @core.Setup::new()
  let mut hook_called = false
  setup.given("a defined step", fn(_ctx) {  })
  setup.before_test_case(fn(_ctx) { hook_called = true })
  let registry = setup.step_registry()
  let hook_registry = setup.hook_registry()
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "a defined step",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: None,
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test",
    scenario_name="Dry Hooks",
    pickle_id="p-dry-3",
    tags=[],
    steps~,
    hook_registry~,
    dry_run=true,
  )
  assert_false(hook_called)
  assert_eq(result.status, ScenarioStatus::Skipped(Some("dry run")))
}

test "execute_scenario dry-run with mixed defined and undefined" {
  let setup = @core.Setup::new()
  setup.given("a defined step", fn(_ctx) {  })
  let registry = setup.step_registry()
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "a defined step",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: None,
    },
    {
      id: "s2",
      text: "an undefined step",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Action),
      argument: None,
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test",
    scenario_name="Dry Mixed",
    pickle_id="p-dry-4",
    tags=[],
    steps~,
    dry_run=true,
  )
  assert_eq(result.steps[0].status, StepStatus::Skipped(Some("dry run")))
  assert_eq(result.steps[1].status, StepStatus::Undefined)
  assert_eq(result.status, ScenarioStatus::Undefined)
}
```

**Step 2: Run tests to verify they fail**

Run: `mise run test:unit`
Expected: FAIL — `dry_run` parameter doesn't exist yet

**Step 3: Implement dry-run in execute_scenario**

Add `dry_run? : Bool = false` parameter to `execute_scenario`:

```moonbit
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
```

When `dry_run` is true, insert a fast path after the variable setup (after line 81) that skips all hooks and only matches steps:

```moonbit
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
        emit(sinks, make_test_step_started_envelope(test_case_started_id, ts_id))
      }
      let (status, diagnostic) : (StepStatus, Error?) = match registry.find_match(step.text, keyword~) {
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
        Matched(..) =>
          (StepStatus::Skipped(Some("dry run")), None)
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
```

**Step 4: Run tests**

Run: `mise run test:unit`
Expected: All tests pass

**Step 5: Commit**

```bash
git add src/runner/executor.mbt src/runner/executor_wbtest.mbt
git commit -m "feat(runner): implement dry-run mode in execute_scenario"
```

---

### Task 5: Thread dry_run and skip_tags through the execution chain

**Files:**
- Modify: `src/runner/run.mbt` — thread `dry_run` and `skip_tags` from `run()` through `execute_pickle` and `run_pickles_sequential`
- Modify: `src/runner/parallel.mbt` — add `dry_run` parameter

**Step 1: Update execute_pickle**

Add `dry_run? : Bool = false` and `skip_tags? : Array[String] = []` parameters to `execute_pickle`. Before calling `execute_scenario`, check skip tags:

```moonbit
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
```

Add skip tag check early in `execute_pickle`, after extracting tags and mapping but before the attempt logic:

```moonbit
  // Check if scenario should be skipped via tags
  let skip_reason = parse_skip_tag(tags, skip_tags)
  if skip_reason is Some(reason) {
    // Build skipped result without executing anything
    let step_results : Array[StepResult] = pickle.steps.map(fn(step) {
      let keyword = match step.type_ {
        Some(@cucumber_messages.PickleStepType::Context) => "Given "
        Some(@cucumber_messages.PickleStepType::Action) => "When "
        Some(@cucumber_messages.PickleStepType::Outcome) => "Then "
        _ => "* "
      }
      { text: step.text, keyword, status: StepStatus::Skipped(Some(reason)), duration_ms: 0L, diagnostic: None }
    })
    // Emit TestCaseStarted/Finished if sinks present
    match mapping {
      Some(_) => {
        let tcs_id = id_gen.next("tcs")
        if sinks.length() > 0 {
          emit(sinks, make_test_case_started_envelope(tcs_id, test_case_id))
          // Emit step envelopes
          let mut si = 0
          for _step in pickle.steps {
            let ts_id = if si < test_step_ids.length() { test_step_ids[si] } else { "" }
            si += 1
            emit(sinks, make_test_step_started_envelope(tcs_id, ts_id))
            emit(sinks, make_test_step_finished_envelope(tcs_id, ts_id, "SKIPPED", Some(reason)))
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
    return { result, was_retried: false }
  }
```

Pass `dry_run` through to `execute_scenario` in the execute_attempt closure:

```moonbit
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
```

When dry-run is enabled, skip the retry logic — go straight to single execution:

In `execute_pickle`, the retry-or-not decision should also account for dry_run. When `dry_run` is true, always take the non-retry path regardless of max_retries:

```moonbit
  let result = if max_retries > 0 && not(dry_run) {
    // retry path...
  } else {
    execute_attempt()
  }
```

**Step 2: Update run_pickles_sequential**

Add `dry_run? : Bool = false` and `skip_tags? : Array[String] = []`:

```moonbit
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
```

Pass through to `execute_pickle`:
```moonbit
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
```

**Step 3: Update run_pickles_parallel**

Add same parameters to `src/runner/parallel.mbt`:

```moonbit
async fn[W : @core.World] run_pickles_parallel(
  factory : () -> W,
  pickles : Array[@cucumber_messages.Pickle],
  max_concurrent~ : Int,
  sinks? : Array[&@core.MessageSink] = [],
  tc_mappings? : Map[String, TestCaseMapping] = {},
  id_gen? : IdGenerator = IdGenerator::new(),
  retries? : Int = 0,
  dry_run? : Bool = false,
  skip_tags? : Array[String] = [],
) -> Array[PickleResult] {
```

Pass through:
```moonbit
  let tasks : Array[async () -> PickleResult] = pickles.map(fn(pickle) {
    async fn() -> PickleResult {
      execute_pickle(factory, pickle, sinks~, tc_mappings~, id_gen~, retries~, dry_run~, skip_tags~)
    }
  })
```

**Step 4: Update run() to pass options through**

In `run()`, extract the new options and pass them:

```moonbit
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
```

**Step 5: Run tests**

Run: `mise run test:unit`
Expected: All tests pass

**Step 6: Commit**

```bash
git add src/runner/run.mbt src/runner/parallel.mbt
git commit -m "feat(runner): thread dry_run and skip_tags through execution chain"
```

---

### Task 6: Add E2E tests

**Files:**
- Modify: `src/runner/e2e_wbtest.mbt` — add end-to-end tests

**Step 1: Write E2E tests**

Add to `src/runner/e2e_wbtest.mbt`:

```moonbit
///|
struct DryRunWorld {} derive(Default)

///|
impl @core.World for DryRunWorld with configure(_self, setup) {
  setup.given("a defined step", fn(_ctx) {  })
  setup.when("another defined step", fn(_ctx) {  })
}

///|
async test "dry-run: steps matched but not executed" {
  let content =
    #|Feature: DryRun
    #|
    #|  Scenario: Defined steps
    #|    Given a defined step
    #|    When another defined step
  let opts = RunOptions([FeatureSource::Text("test://dryrun", content)])
  opts.dry_run(true)
  let result = run(DryRunWorld::default, opts)
  assert_eq(result.summary.total_scenarios, 1)
  assert_eq(result.summary.skipped, 1)
  assert_eq(result.summary.passed, 0)
  assert_eq(result.features[0].scenarios[0].status, ScenarioStatus::Skipped(Some("dry run")))
}

///|
async test "dry-run: undefined steps still reported" {
  let content =
    #|Feature: DryRunUndef
    #|
    #|  Scenario: Missing step
    #|    Given an undefined step
  let opts = RunOptions([FeatureSource::Text("test://dryrun-undef", content)])
  opts.dry_run(true)
  let result = run(DryRunWorld::default, opts)
  assert_eq(result.summary.undefined, 1)
  assert_eq(result.summary.skipped, 0)
}

///|
async test "dry-run: envelopes emitted with SKIPPED status" {
  let content =
    #|Feature: DryRunEnv
    #|
    #|  Scenario: Defined
    #|    Given a defined step
  let collector = CollectorSink::new()
  let opts = RunOptions([FeatureSource::Text("test://dryrun-env", content)])
  opts.dry_run(true)
  opts.add_sink(collector)
  let _ = run(DryRunWorld::default, opts)
  let mut found_skipped = false
  for env in collector.envelopes {
    match env {
      @cucumber_messages.Envelope::TestStepFinished(tsf) =>
        if tsf.testStepResult.status == @cucumber_messages.TestStepResultStatus::SKIPPED {
          found_skipped = true
        }
      _ => ()
    }
  }
  assert_true(found_skipped)
}

///|
struct SkipTagWorld {} derive(Default)

///|
impl @core.World for SkipTagWorld with configure(_self, setup) {
  setup.given("a step", fn(_ctx) {  })
}

///|
async test "skip tag: @skip scenario is skipped" {
  let content =
    #|Feature: SkipTag
    #|
    #|  @skip
    #|  Scenario: Skipped
    #|    Given a step
    #|
    #|  Scenario: Normal
    #|    Given a step
  let result = run(
    SkipTagWorld::default,
    RunOptions([FeatureSource::Text("test://skip-tag", content)]),
  )
  assert_eq(result.summary.total_scenarios, 2)
  assert_eq(result.summary.passed, 1)
  assert_eq(result.summary.skipped, 1)
}

///|
async test "skip tag: @skip(\"reason\") carries reason" {
  let content = "Feature: SkipReason\n\n  @skip(\"flaky on CI\")\n  Scenario: Flaky\n    Given a step\n"
  let result = run(
    SkipTagWorld::default,
    RunOptions([FeatureSource::Text("test://skip-reason", content)]),
  )
  assert_eq(result.summary.skipped, 1)
  assert_eq(
    result.features[0].scenarios[0].status,
    ScenarioStatus::Skipped(Some("flaky on CI")),
  )
}

///|
async test "skip tag: @ignore scenario is skipped" {
  let content =
    #|Feature: IgnoreTag
    #|
    #|  @ignore
    #|  Scenario: Ignored
    #|    Given a step
  let result = run(
    SkipTagWorld::default,
    RunOptions([FeatureSource::Text("test://ignore-tag", content)]),
  )
  assert_eq(result.summary.skipped, 1)
}

///|
async test "skip tag: custom skip tags" {
  let content =
    #|Feature: CustomSkip
    #|
    #|  @wip
    #|  Scenario: WIP
    #|    Given a step
    #|
    #|  Scenario: Normal
    #|    Given a step
  let opts = RunOptions([FeatureSource::Text("test://custom-skip", content)])
  opts.skip_tags(["@wip"])
  let result = run(SkipTagWorld::default, opts)
  assert_eq(result.summary.skipped, 1)
  assert_eq(result.summary.passed, 1)
}

///|
async test "skip tag: takes precedence over dry-run" {
  let content =
    #|Feature: SkipPrecedence
    #|
    #|  @skip("explicit skip")
    #|  Scenario: Skipped
    #|    Given a step
  let opts = RunOptions([FeatureSource::Text("test://skip-precedence", content)])
  opts.dry_run(true)
  let result = run(SkipTagWorld::default, opts)
  assert_eq(result.summary.skipped, 1)
  assert_eq(
    result.features[0].scenarios[0].status,
    ScenarioStatus::Skipped(Some("explicit skip")),
  )
}
```

**Step 2: Run tests**

Run: `mise run test:unit`
Expected: All tests pass

**Step 3: Commit**

```bash
git add src/runner/e2e_wbtest.mbt
git commit -m "test(runner): add E2E tests for dry-run mode and skip tags"
```

---

### Task 7: Format, regenerate mbti, and update documentation

**Files:**
- Run: `moon fmt` (revert `.pkg` file changes after)
- Run: `moon info` to regenerate `pkg.generated.mbti`
- Modify: `README.md` — add dry-run and skip tags documentation

**Step 1: Run moon fmt**

```bash
moon fmt
git checkout -- src/core/moon.pkg src/format/moon.pkg src/runner/moon.pkg src/cmd/main/moon.pkg
```

**Step 2: Regenerate mbti**

```bash
moon info
```

**Step 3: Update README.md**

Add a "Dry-Run Mode" section after the "Retrying Flaky Tests" section:

```markdown
### Dry-Run Mode

Validate step definitions without executing handlers or hooks:

```moonbit nocheck
let opts = RunOptions::new(features)
opts.dry_run(true)
let result = run(MyWorld::default, opts)
// result.summary.undefined shows unmatched steps
// result.summary.skipped shows matched-but-not-executed steps
```

Matched steps report as `Skipped("dry run")`. Undefined steps remain
`Undefined` with snippet suggestions. No hooks are called, no retries attempted.
```

Add a "Skipping Scenarios" section after "Dry-Run Mode":

```markdown
### Skipping Scenarios

Tag scenarios with `@skip` or `@ignore` to skip them without execution:

```gherkin
@skip
Scenario: Not ready yet
  Given a step

@skip("flaky on CI")
Scenario: Intermittent failure
  Given a step

@ignore("waiting on upstream fix")
Scenario: Blocked
  Given a step
```

Skipped scenarios appear in the summary as skipped with their reason.

#### Custom Skip Tags

Configure which tags trigger skipping:

```moonbit nocheck
let opts = RunOptions::new(features)
opts.skip_tags(["@skip", "@ignore", "@wip"])
```

The default skip tags are `@skip` and `@ignore`.
```

Update the RunOptions builder methods list to include `dry_run(bool)` and `skip_tags(array)`.

Update the Tags description to mention `@skip` and `@ignore`.

**Step 4: Run tests one final time**

Run: `mise run test:unit`
Expected: All tests pass

**Step 5: Commit**

```bash
git add -A
git checkout -- src/core/moon.pkg src/format/moon.pkg src/runner/moon.pkg src/cmd/main/moon.pkg
git commit -m "chore: moon fmt, regenerate mbti, add dry-run and skip tags docs"
```
