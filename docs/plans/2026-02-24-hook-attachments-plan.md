# Hook Attachment Support Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add attachment capability to all hook types (run, case, step) with properly typed contexts, an `Attachable` trait, and structured `HookResult` error reporting.

**Architecture:** Three new hook context types (`RunHookCtx`, `CaseHookCtx`, `StepHookCtx`) each implement a shared `Attachable` trait alongside the existing `Ctx`. `HookHandler` expands from 3 to 6 variants (before/after split). The executor and runner construct the appropriate context, call the hook, drain `pending_attachments()`, and emit attachment envelopes. `HookResult` replaces `String?` for after-hooks with structured error reporting via `HookError`.

**Tech Stack:** MoonBit, moonrockz/cucumber-messages, moonbitlang/x/codec/base64

---

### Task 1: Add HookError and HookResult types

**Files:**
- Modify: `src/core/types.mbt` — add `HookError` enum and `HookResult` enum after `StepInfo`
- Test: `src/core/types_wbtest.mbt`

**Step 1: Write failing tests**

Add to `src/core/types_wbtest.mbt`:

```moonbit
///|
test "HookResult Passed" {
  let result : HookResult = Passed
  match result {
    Passed => ()
    _ => fail("expected Passed")
  }
}

///|
test "HookResult Failed with StepFailed" {
  let result : HookResult = Failed([
    HookError::StepFailed(
      step="I add 1 and 2",
      keyword=StepKeyword::When,
      message="assertion failed",
    ),
  ])
  match result {
    Failed(errors) => {
      assert_eq(errors.length(), 1)
      match errors[0] {
        StepFailed(step~, keyword~, message~) => {
          assert_eq(step, "I add 1 and 2")
          assert_eq(keyword, StepKeyword::When)
          assert_eq(message, "assertion failed")
        }
        _ => fail("expected StepFailed")
      }
    }
    _ => fail("expected Failed")
  }
}

///|
test "HookResult Failed with ScenarioFailed" {
  let result : HookResult = Failed([
    HookError::ScenarioFailed(
      feature_name="Calculator",
      scenario_name="Addition",
      message="step failed",
    ),
  ])
  match result {
    Failed(errors) => {
      assert_eq(errors.length(), 1)
      match errors[0] {
        ScenarioFailed(feature_name~, scenario_name~, message~) => {
          assert_eq(feature_name, "Calculator")
          assert_eq(scenario_name, "Addition")
          assert_eq(message, "step failed")
        }
        _ => fail("expected ScenarioFailed")
      }
    }
    _ => fail("expected Failed")
  }
}
```

**Step 2: Run tests to verify they fail**

Run: `moon test --target js`
Expected: FAIL — `HookError` and `HookResult` don't exist yet.

**Step 3: Implement types**

Add to `src/core/types.mbt` after the `StepInfo` struct (after `} derive(Show, Eq)` on line ~210):

```moonbit
///|
/// Structured error reported to after-hooks.
pub(all) enum HookError {
  StepFailed(step~ : String, keyword~ : StepKeyword, message~ : String)
  ScenarioFailed(
    feature_name~ : String,
    scenario_name~ : String,
    message~ : String,
  )
} derive(Show, Eq)

///|
/// Result passed to after-hooks indicating pass/fail with structured errors.
pub(all) enum HookResult {
  Passed
  Failed(Array[HookError])
} derive(Show, Eq)
```

**Step 4: Run tests to verify they pass**

Run: `moon test --target js`
Expected: PASS

**Step 5: Commit**

```bash
git add src/core/types.mbt src/core/types_wbtest.mbt
git commit -m "feat(core): add HookError and HookResult types"
```

---

### Task 2: Add Attachable trait and implement on Ctx

**Files:**
- Modify: `src/core/types.mbt` — add `Attachable` trait, implement on `Ctx`, make `attachments` field `priv`
- Modify: `src/core/types_wbtest.mbt` — update tests that access `ctx.attachments` directly
- Modify: `src/runner/executor.mbt` — use `pending_attachments()` instead of `c.attachments`

**Step 1: Write failing test**

Add to `src/core/types_wbtest.mbt`:

```moonbit
///|
test "Ctx implements Attachable" {
  let ctx = Ctx::new(
    [],
    { feature_name: "F", scenario_name: "S", tags: [] },
    { keyword: "Given ", text: "step" },
  )
  ctx.attach("hello", "text/plain")
  let pending = ctx.pending_attachments()
  assert_eq(pending.length(), 1)
}
```

**Step 2: Run tests — should fail because `pending_attachments` doesn't exist**

**Step 3: Implement**

In `src/core/types.mbt`, add after the `parse_encoding` function (before the `Ctx::attach` methods):

```moonbit
///|
/// Trait for any context that can buffer attachments.
pub(all) trait Attachable {
  attach(Self, String, String, file_name? : String) -> Unit
  attach_bytes(Self, Bytes, String, file_name? : String) -> Unit
  attach_url(Self, String, String) -> Unit
  pending_attachments(Self) -> Array[PendingAttachment]
}
```

Make the `attachments` field `priv` on `Ctx`:

```moonbit
pub(all) struct Ctx {
  priv step_args : Array[StepArg]
  priv scenario_info : ScenarioInfo
  priv step_info : StepInfo
  priv attachments : Array[PendingAttachment]
}
```

Add `pending_attachments` method to `Ctx`:

```moonbit
///|
/// Access buffered attachments (for executor draining).
pub fn Ctx::pending_attachments(self : Ctx) -> Array[PendingAttachment] {
  self.attachments
}
```

**Step 4: Fix existing tests**

In `src/core/types_wbtest.mbt`, update all tests that access `ctx.attachments` directly to use `ctx.pending_attachments()` instead. Tests affected:
- "Ctx attach text" — `ctx.attachments.length()` → `ctx.pending_attachments().length()`, `ctx.attachments[0]` → `ctx.pending_attachments()[0]`
- "Ctx attach_bytes base64 encodes" — same pattern
- "Ctx attach_url" — same pattern
- "Ctx attach with file_name" — same pattern

In `src/runner/executor.mbt`, update the attachment drain block (around line 349-361):
- `c.attachments.length()` → `c.pending_attachments().length()`
- `c.attachments` (passed to `emit_attachments`) → `c.pending_attachments()`
- `c.attachments.clear()` → `c.pending_attachments().clear()`

**Step 5: Run tests to verify they pass**

Run: `moon test --target js`
Expected: PASS

**Step 6: Commit**

```bash
git add src/core/types.mbt src/core/types_wbtest.mbt src/runner/executor.mbt
git commit -m "feat(core): add Attachable trait, implement on Ctx, make attachments priv"
```

---

### Task 3: Add hook context types implementing Attachable

**Files:**
- Modify: `src/core/types.mbt` — add `RunHookCtx`, `CaseHookCtx`, `StepHookCtx` structs with constructors, accessors, and `Attachable` implementations
- Test: `src/core/types_wbtest.mbt`

**Step 1: Write failing tests**

Add to `src/core/types_wbtest.mbt`:

```moonbit
///|
test "RunHookCtx attach and drain" {
  let ctx = RunHookCtx::new()
  ctx.attach("run log", "text/plain")
  ctx.attach_url("https://example.com/log", "text/plain")
  assert_eq(ctx.pending_attachments().length(), 2)
}

///|
test "CaseHookCtx scenario accessor and attach" {
  let info : ScenarioInfo = {
    feature_name: "F",
    scenario_name: "S",
    tags: ["@smoke"],
  }
  let ctx = CaseHookCtx::new(info)
  assert_eq(ctx.scenario().feature_name, "F")
  assert_eq(ctx.scenario().tags[0], "@smoke")
  ctx.attach("case log", "text/plain")
  assert_eq(ctx.pending_attachments().length(), 1)
}

///|
test "StepHookCtx scenario and step accessors and attach" {
  let info : ScenarioInfo = { feature_name: "F", scenario_name: "S", tags: [] }
  let step : StepInfo = { keyword: "When ", text: "I do something" }
  let ctx = StepHookCtx::new(info, step)
  assert_eq(ctx.scenario().scenario_name, "S")
  assert_eq(ctx.step().keyword, "When ")
  ctx.attach_bytes(b"data", "application/octet-stream")
  assert_eq(ctx.pending_attachments().length(), 1)
}
```

**Step 2: Run tests — should fail**

**Step 3: Implement in `src/core/types.mbt`**

Add after `HookResult` and before `StepMatchResult`:

```moonbit
///|
/// Hook context for test run-level hooks (before/after_test_run).
pub(all) struct RunHookCtx {
  priv attachments : Array[PendingAttachment]
}

///|
pub fn RunHookCtx::new() -> RunHookCtx {
  { attachments: [] }
}

///|
pub fn RunHookCtx::pending_attachments(
  self : RunHookCtx,
) -> Array[PendingAttachment] {
  self.attachments
}

///|
pub fn RunHookCtx::attach(
  self : RunHookCtx,
  body : String,
  media_type : String,
  file_name? : String,
) -> Unit {
  let encoding = parse_encoding("\"IDENTITY\"")
  self.attachments.push(
    PendingAttachment::Embedded(body~, encoding~, media_type~, file_name~),
  )
}

///|
pub fn RunHookCtx::attach_bytes(
  self : RunHookCtx,
  data : Bytes,
  media_type : String,
  file_name? : String,
) -> Unit {
  let body = @base64.encode(data[:])
  let encoding = parse_encoding("\"BASE64\"")
  self.attachments.push(
    PendingAttachment::Embedded(body~, encoding~, media_type~, file_name~),
  )
}

///|
pub fn RunHookCtx::attach_url(
  self : RunHookCtx,
  url : String,
  media_type : String,
) -> Unit {
  self.attachments.push(PendingAttachment::External(url~, media_type~))
}

///|
/// Hook context for test case-level hooks (before/after_test_case).
pub(all) struct CaseHookCtx {
  priv scenario_info : ScenarioInfo
  priv attachments : Array[PendingAttachment]
}

///|
pub fn CaseHookCtx::new(scenario : ScenarioInfo) -> CaseHookCtx {
  { scenario_info: scenario, attachments: [] }
}

///|
pub fn CaseHookCtx::scenario(self : CaseHookCtx) -> ScenarioInfo {
  self.scenario_info
}

///|
pub fn CaseHookCtx::pending_attachments(
  self : CaseHookCtx,
) -> Array[PendingAttachment] {
  self.attachments
}

///|
pub fn CaseHookCtx::attach(
  self : CaseHookCtx,
  body : String,
  media_type : String,
  file_name? : String,
) -> Unit {
  let encoding = parse_encoding("\"IDENTITY\"")
  self.attachments.push(
    PendingAttachment::Embedded(body~, encoding~, media_type~, file_name~),
  )
}

///|
pub fn CaseHookCtx::attach_bytes(
  self : CaseHookCtx,
  data : Bytes,
  media_type : String,
  file_name? : String,
) -> Unit {
  let body = @base64.encode(data[:])
  let encoding = parse_encoding("\"BASE64\"")
  self.attachments.push(
    PendingAttachment::Embedded(body~, encoding~, media_type~, file_name~),
  )
}

///|
pub fn CaseHookCtx::attach_url(
  self : CaseHookCtx,
  url : String,
  media_type : String,
) -> Unit {
  self.attachments.push(PendingAttachment::External(url~, media_type~))
}

///|
/// Hook context for test step-level hooks (before/after_test_step).
pub(all) struct StepHookCtx {
  priv scenario_info : ScenarioInfo
  priv step_info : StepInfo
  priv attachments : Array[PendingAttachment]
}

///|
pub fn StepHookCtx::new(
  scenario : ScenarioInfo,
  step : StepInfo,
) -> StepHookCtx {
  { scenario_info: scenario, step_info: step, attachments: [] }
}

///|
pub fn StepHookCtx::scenario(self : StepHookCtx) -> ScenarioInfo {
  self.scenario_info
}

///|
pub fn StepHookCtx::step(self : StepHookCtx) -> StepInfo {
  self.step_info
}

///|
pub fn StepHookCtx::pending_attachments(
  self : StepHookCtx,
) -> Array[PendingAttachment] {
  self.attachments
}

///|
pub fn StepHookCtx::attach(
  self : StepHookCtx,
  body : String,
  media_type : String,
  file_name? : String,
) -> Unit {
  let encoding = parse_encoding("\"IDENTITY\"")
  self.attachments.push(
    PendingAttachment::Embedded(body~, encoding~, media_type~, file_name~),
  )
}

///|
pub fn StepHookCtx::attach_bytes(
  self : StepHookCtx,
  data : Bytes,
  media_type : String,
  file_name? : String,
) -> Unit {
  let body = @base64.encode(data[:])
  let encoding = parse_encoding("\"BASE64\"")
  self.attachments.push(
    PendingAttachment::Embedded(body~, encoding~, media_type~, file_name~),
  )
}

///|
pub fn StepHookCtx::attach_url(
  self : StepHookCtx,
  url : String,
  media_type : String,
) -> Unit {
  self.attachments.push(PendingAttachment::External(url~, media_type~))
}
```

**Step 4: Run tests to verify they pass**

Run: `moon test --target js`
Expected: PASS

**Step 5: Commit**

```bash
git add src/core/types.mbt src/core/types_wbtest.mbt
git commit -m "feat(core): add RunHookCtx, CaseHookCtx, StepHookCtx implementing Attachable"
```

---

### Task 4: Update HookHandler enum and Setup registration

**Files:**
- Modify: `src/core/hook_registry.mbt` — expand `HookHandler` from 3 to 6 variants
- Modify: `src/core/setup.mbt` — update all 6 hook registration methods
- Modify: `src/runner/hooks_wbtest.mbt` — update test hook registrations
- Modify: `src/runner/executor.mbt` — update hook handler matching
- Modify: `src/runner/run.mbt` — update run-level hook handler matching

**Step 1: Update HookHandler enum**

In `src/core/hook_registry.mbt`, change `HookHandler` to:

```moonbit
///|
/// Typed handler for different hook scopes.
pub(all) enum HookHandler {
  RunHandler((RunHookCtx) -> Unit raise Error)
  RunAfterHandler((RunHookCtx, HookResult) -> Unit raise Error)
  CaseHandler((CaseHookCtx) -> Unit raise Error)
  CaseAfterHandler((CaseHookCtx, HookResult) -> Unit raise Error)
  StepHandler((StepHookCtx) -> Unit raise Error)
  StepAfterHandler((StepHookCtx, HookResult) -> Unit raise Error)
}
```

**Step 2: Update Setup registration methods**

In `src/core/setup.mbt`, update all 6 hook methods:

```moonbit
///|
#callsite(autofill(loc))
pub fn Setup::before_test_run(
  self : Setup,
  handler : (RunHookCtx) -> Unit raise Error,
  loc~ : SourceLoc,
) -> Unit {
  let source : StepSource? = Some(StepSource::new(uri=loc.to_string()))
  self.hook_reg.add(HookType::BeforeTestRun, RunHandler(handler), source~)
}

///|
#callsite(autofill(loc))
pub fn Setup::after_test_run(
  self : Setup,
  handler : (RunHookCtx, HookResult) -> Unit raise Error,
  loc~ : SourceLoc,
) -> Unit {
  let source : StepSource? = Some(StepSource::new(uri=loc.to_string()))
  self.hook_reg.add(HookType::AfterTestRun, RunAfterHandler(handler), source~)
}

///|
#callsite(autofill(loc))
pub fn Setup::before_test_case(
  self : Setup,
  handler : (CaseHookCtx) -> Unit raise Error,
  loc~ : SourceLoc,
) -> Unit {
  let source : StepSource? = Some(StepSource::new(uri=loc.to_string()))
  self.hook_reg.add(HookType::BeforeTestCase, CaseHandler(handler), source~)
}

///|
#callsite(autofill(loc))
pub fn Setup::after_test_case(
  self : Setup,
  handler : (CaseHookCtx, HookResult) -> Unit raise Error,
  loc~ : SourceLoc,
) -> Unit {
  let source : StepSource? = Some(StepSource::new(uri=loc.to_string()))
  self.hook_reg.add(HookType::AfterTestCase, CaseAfterHandler(handler), source~)
}

///|
#callsite(autofill(loc))
pub fn Setup::before_test_step(
  self : Setup,
  handler : (StepHookCtx) -> Unit raise Error,
  loc~ : SourceLoc,
) -> Unit {
  let source : StepSource? = Some(StepSource::new(uri=loc.to_string()))
  self.hook_reg.add(HookType::BeforeTestStep, StepHandler(handler), source~)
}

///|
#callsite(autofill(loc))
pub fn Setup::after_test_step(
  self : Setup,
  handler : (StepHookCtx, HookResult) -> Unit raise Error,
  loc~ : SourceLoc,
) -> Unit {
  let source : StepSource? = Some(StepSource::new(uri=loc.to_string()))
  self.hook_reg.add(HookType::AfterTestStep, StepAfterHandler(handler), source~)
}
```

**Step 3: Update executor hook invocations**

In `src/runner/executor.mbt`, update all hook handler matching. The executor currently uses `@core.CaseHandler(h)` and `@core.StepHandler(h)` patterns.

**before_test_case hooks** (around line 89-101): Change to construct `CaseHookCtx` and match `@core.CaseHandler`:
```moonbit
@core.CaseHandler(h) =>
  try {
    let hook_ctx = @core.CaseHookCtx::new(info)
    h(hook_ctx)
    // drain attachments after
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
```

**after_test_case hooks** (around line 169-177 and 408-416): Change to construct `CaseHookCtx`, build `HookResult`, match `@core.CaseAfterHandler`:
```moonbit
@core.CaseAfterHandler(h) =>
  try {
    let hook_ctx = @core.CaseHookCtx::new(info)
    h(hook_ctx, hook_result)
    // drain attachments
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
```

Where `hook_result` is built from the collected step errors. For the early-return path (before_test_case hook failed), build:
```moonbit
let hook_result : @core.HookResult = Failed([
  @core.HookError::StepFailed(step="", keyword=@core.StepKeyword::Step, message=msg)
])
```

For the normal path, build from `scenario_error`:
```moonbit
let hook_result : @core.HookResult = match scenario_error {
  Some(msg) => Failed([...collected step errors...])
  None => Passed
}
```

Note: Collecting full step errors requires tracking them during step execution. For simplicity, use the scenario_error message with the last failed step info. The step_results array has all the info needed.

**before_test_step hooks** (around line 246-257): Change to construct `StepHookCtx`, match `@core.StepHandler`:
```moonbit
@core.StepHandler(h) =>
  try {
    let hook_ctx = @core.StepHookCtx::new(info, step_info)
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
  } catch {
    e => err = Some(e.to_string())
  }
```

**after_test_step hooks** (around line 369-376): Change to construct `StepHookCtx`, build `HookResult`, match `@core.StepAfterHandler`:
```moonbit
@core.StepAfterHandler(h) => {
  let hook_ctx = @core.StepHookCtx::new(info, step_info)
  let step_hook_result : @core.HookResult = match step_result_msg {
    Some(msg) => Failed([
      @core.HookError::StepFailed(
        step=step.text,
        keyword=parse_step_keyword(step),
        message=msg,
      ),
    ])
    None => Passed
  }
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
```

**Step 4: Update run.mbt for run-level hooks**

In `src/runner/run.mbt`, the before/after_test_run hooks (around lines 491-521 and 558-566):

For **before_test_run** hooks, change:
```moonbit
match hook.handler {
  @core.HookHandler::RunHandler(h) => {
    let hook_ctx = @core.RunHookCtx::new()
    h(hook_ctx)
    // drain run-level attachments using testRunHookStartedId
    if sinks.length() > 0 && hook_ctx.pending_attachments().length() > 0 {
      emit_run_hook_attachments(sinks, hook_ctx.pending_attachments(), trhs_id)
      hook_ctx.pending_attachments().clear()
    }
  }
  _ => ()
}
```

For **after_test_run** hooks, build `HookResult` from scenario results, then:
```moonbit
match hook.handler {
  @core.HookHandler::RunAfterHandler(h) => {
    let hook_ctx = @core.RunHookCtx::new()
    h(hook_ctx, run_hook_result)
    if sinks.length() > 0 && hook_ctx.pending_attachments().length() > 0 {
      emit_run_hook_attachments(sinks, hook_ctx.pending_attachments(), trhs_id)
      hook_ctx.pending_attachments().clear()
    }
  }
  _ => ()
}
```

Add a new helper `emit_run_hook_attachments` in `src/runner/run.mbt` (or executor.mbt) that uses `testRunHookStartedId` instead of `testCaseStartedId`:

The existing `make_attachment_envelope` and `make_external_attachment_envelope` already accept optional `test_case_started_id` and `test_step_id`. For run-level hooks, we need to pass `None` for both and add a new field. The simplest approach: add `test_run_hook_started_id? : String` parameter to both helpers, and emit it when present.

**Step 5: Update test files**

In `src/runner/hooks_wbtest.mbt`, update `HookWorld` and `FailHookWorld`:

```moonbit
impl @core.World for HookWorld with configure(self, setup) {
  setup.given("a step", fn(_ctx) { () })
  setup.then("it passes", fn(_ctx) { () })
  setup.before_test_case(fn(ctx) {
    self.log.push("before_scenario:" + ctx.scenario().scenario_name)
  })
  setup.after_test_case(fn(ctx, result) {
    let status = match result {
      @core.HookResult::Passed => "ok"
      @core.HookResult::Failed(errors) => {
        let msgs = errors.map(fn(e) {
          match e {
            @core.HookError::StepFailed(message~, ..) => message
            @core.HookError::ScenarioFailed(message~, ..) => message
          }
        })
        msgs[0]
      }
    }
    self.log.push(
      "after_scenario:" + ctx.scenario().scenario_name + ":" + status,
    )
  })
  setup.before_test_step(fn(ctx) {
    self.log.push("before_step:" + ctx.step().text)
  })
  setup.after_test_step(fn(ctx, result) {
    let status = match result {
      @core.HookResult::Passed => "ok"
      @core.HookResult::Failed(errors) => {
        let msgs = errors.map(fn(e) {
          match e {
            @core.HookError::StepFailed(message~, ..) => message
            @core.HookError::ScenarioFailed(message~, ..) => message
          }
        })
        msgs[0]
      }
    }
    self.log.push("after_step:" + ctx.step().text + ":" + status)
  })
}
```

And `FailHookWorld`:
```moonbit
impl @core.World for FailHookWorld with configure(self, setup) {
  setup.given("a step", fn(_ctx) { () })
  setup.before_test_case(fn(_ctx) raise {
    self.log.push("before_scenario")
    raise Failure::Failure("setup failed")
  })
  setup.after_test_case(fn(_ctx, _result) { self.log.push("after_scenario") })
}
```

Also check `src/runner/run_wbtest.mbt` for any hook registrations that need updating.

**Step 6: Run tests**

Run: `moon test --target js`
Expected: All pass.

**Step 7: Commit**

```bash
git add -A
git commit -m "feat(core)!: expand HookHandler to 6 variants, update hook signatures

BREAKING CHANGE: Hook handlers now receive typed context objects
(RunHookCtx, CaseHookCtx, StepHookCtx) and after-hooks receive
HookResult instead of String?. All hook contexts support attach()."
```

---

### Task 5: Add E2E tests for hook attachments

**Files:**
- Modify: `src/runner/e2e_wbtest.mbt` — add tests for case and step hook attachments
- Modify: `src/runner/hooks_wbtest.mbt` — add test for run hook attachments

**Step 1: Add case hook attachment E2E test**

In `src/runner/e2e_wbtest.mbt`:

```moonbit
///|
struct CaseHookAttachWorld {} derive(Default)

///|
impl @core.World for CaseHookAttachWorld with configure(_self, setup) {
  setup.given("a step", fn(_ctx) { () })
  setup.before_test_case(fn(ctx) {
    ctx.attach("case setup log", "text/plain")
  })
}

///|
async test "end-to-end: case hook attachment emits envelope" {
  let content =
    #|Feature: CaseHookAttach
    #|
    #|  Scenario: With hook attachment
    #|    Given a step
  let messages = @format.MessagesFormatter::new()
  let opts = RunOptions([FeatureSource::Text("test://case-hook-attach", content)])
  opts.add_sink(messages)
  let result = run(CaseHookAttachWorld::default, opts)
  assert_eq(result.summary.passed, 1)
  let output = messages.output()
  assert_true(output.contains("case setup log"))
}
```

**Step 2: Add step hook attachment test**

```moonbit
///|
struct StepHookAttachWorld {} derive(Default)

///|
impl @core.World for StepHookAttachWorld with configure(_self, setup) {
  setup.given("a step", fn(_ctx) { () })
  setup.after_test_step(fn(ctx, _result) {
    ctx.attach("step trace", "text/plain")
  })
}

///|
async test "end-to-end: step hook attachment emits envelope" {
  let content =
    #|Feature: StepHookAttach
    #|
    #|  Scenario: With step hook attachment
    #|    Given a step
  let messages = @format.MessagesFormatter::new()
  let opts = RunOptions([FeatureSource::Text("test://step-hook-attach", content)])
  opts.add_sink(messages)
  let result = run(StepHookAttachWorld::default, opts)
  assert_eq(result.summary.passed, 1)
  let output = messages.output()
  assert_true(output.contains("step trace"))
}
```

**Step 3: Run tests**

Run: `moon test --target js`
Expected: All pass.

**Step 4: Commit**

```bash
git add src/runner/e2e_wbtest.mbt src/runner/hooks_wbtest.mbt
git commit -m "test: add e2e tests for hook attachment envelope emission"
```

---

### Task 6: Update lib.mbt re-exports, moon fmt, regenerate mbti, update docs

**Files:**
- Modify: `src/lib.mbt` — add new types to re-exports
- All `.mbt` files — run `moon fmt`
- Generated `.mbti` files — run `moon info`
- `README.md` — update hook documentation

**Step 1: Update re-exports**

In `src/lib.mbt`, add to the `pub using @core` block:

```
type HookError,
type HookResult,
type RunHookCtx,
type CaseHookCtx,
type StepHookCtx,
trait Attachable,
```

**Step 2: Run moon fmt**

```bash
moon fmt
```

If `moon fmt` changes `moon.pkg` files (as→@ syntax), revert those specific changes.

**Step 3: Run moon info**

```bash
moon info
```

**Step 4: Run tests**

Run: `moon test --target js`
Expected: All pass.

**Step 5: Update README.md**

Update the Hooks section to show the new API with typed contexts and HookResult. Update the Attachments section to mention hook attachment support.

**Step 6: Commit**

```bash
git add -A
git commit -m "chore: re-exports, moon fmt, regenerate mbti, update docs for hook attachments"
```

---

### Notes for the implementer

1. **`emit_attachments` in executor.mbt** takes `test_case_started_id` and `test_step_id`. For case/step hooks this works fine. For run-level hooks, you need a new helper or updated signature that uses `test_run_hook_started_id` instead.

2. **Building `HookResult` for after_test_case** — the executor tracks `scenario_error : String?`. To build a proper `HookResult::Failed`, iterate `step_results` to collect `StepFailed` entries for all failed steps:
   ```moonbit
   let errors : Array[@core.HookError] = []
   for r in step_results {
     match r.status {
       StepStatus::Failed(msg) =>
         errors.push(@core.HookError::StepFailed(
           step=r.text, keyword=parse_keyword(r.keyword), message=msg,
         ))
       _ => ()
     }
   }
   let hook_result = if errors.length() > 0 { Failed(errors) } else { Passed }
   ```

3. **Building `HookResult` for after_test_run** — iterate scenario results:
   ```moonbit
   let errors : Array[@core.HookError] = []
   for r in results {
     if r.status != ScenarioStatus::Passed {
       errors.push(@core.HookError::ScenarioFailed(
         feature_name=r.feature_name,
         scenario_name=r.scenario_name,
         message="scenario failed",
       ))
     }
   }
   let run_hook_result = if errors.length() > 0 { Failed(errors) } else { Passed }
   ```

4. **The `keyword` field in `StepResult` is `String` (e.g. "Given ")** — to convert to `StepKeyword` for `HookError::StepFailed`, add a helper:
   ```moonbit
   fn parse_keyword_string(s : String) -> @core.StepKeyword {
     match s {
       "Given " => @core.StepKeyword::Given
       "When " => @core.StepKeyword::When
       "Then " => @core.StepKeyword::Then
       _ => @core.StepKeyword::Step
     }
   }
   ```

5. **Hook tests in `hooks_wbtest.mbt`** — the "hooks: correct ordering" test asserts exact log entries. The new signatures change how hooks access info, but the log format should stay the same so the assertion still works.

6. **`make_attachment_envelope` for run hooks** — add optional `test_run_hook_started_id` parameter. When set, emit `"testRunHookStartedId"` instead of `"testCaseStartedId"`. Or create a separate `make_run_hook_attachment_envelope` helper to keep it simple.
