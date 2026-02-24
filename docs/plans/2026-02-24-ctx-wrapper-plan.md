# Ctx Wrapper Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Revert the StepArg→Ctx rename, then create Ctx as a new wrapper type around Array[StepArg] that carries scenario/step metadata and the attachment buffer.

**Architecture:** StepArg returns to being the individual argument type (value + raw). Ctx becomes a new struct wrapping args + ScenarioInfo + StepInfo + attachments. Handler signature changes from `(Array[Ctx]) -> Unit raise Error` to `(Ctx) -> Unit raise Error`. The executor constructs Ctx with full context before calling the handler.

**Tech Stack:** MoonBit, moonrockz/cucumber-messages, moonbitlang/x/codec/base64

---

### Task 1: Revert Ctx back to StepArg

**Files:**
- Modify: `src/core/types.mbt` — rename struct `Ctx` back to `StepArg`, remove `attachments` field, rename `Ctx::from_param` to `StepArg::from_param`, remove attach/attach_bytes/attach_url methods
- Modify: `src/core/registry.mbt:3` — `StepHandler((Array[Ctx])...)` → `StepHandler((Array[StepArg])...)`
- Modify: `src/core/registry.mbt:94` — `Ctx::from_param` → `StepArg::from_param`
- Modify: `src/core/step_def.mbt:64,73,82,91` — all handler signatures back to `Array[StepArg]`
- Modify: `src/core/setup.mbt:79,98,117,136` — all handler signatures back to `Array[StepArg]`
- Modify: `src/core/types.mbt:188` — `StepMatchResult::Matched(StepDef, Array[Ctx])` → `Array[StepArg]`
- Modify: `src/runner/executor.mbt:293,304` — `@core.Ctx::` → `@core.StepArg::`; remove `attachments: []` from construction
- Modify: `src/lib.mbt:11` — `type Ctx` → `type StepArg`
- Modify: `src/core/types_wbtest.mbt` — revert all `Ctx` references to `StepArg`, remove attach-related tests

**DO NOT remove** the `PendingAttachment` enum or the `emit_attachments` function — those stay.

**Step 1: Revert the struct name and remove attachments field**

In `src/core/types.mbt`, change:

```moonbit
pub(all) struct StepArg {
  value : StepValue
  raw : String
} derive(Show, Eq)
```

Remove `Ctx::attach`, `Ctx::attach_bytes`, `Ctx::attach_url` methods entirely.

Rename `Ctx::from_param` to `StepArg::from_param`, remove `attachments: []` from return.

**Step 2: Update all references**

Change `Array[Ctx]` back to `Array[StepArg]` in:
- `src/core/registry.mbt` (StepHandler, find_match)
- `src/core/step_def.mbt` (all factory methods)
- `src/core/setup.mbt` (given/when/then/step)
- `src/core/types.mbt` (StepMatchResult)

**Step 3: Update executor**

In `src/runner/executor.mbt`:
- Change `@core.Ctx::` to `@core.StepArg::` for DocString/DataTable construction
- Remove `attachments: []` from those constructions
- Remove the `args_for_drain` logic and the attachment drain loop (lines 262, 315, 348-361)

**Step 4: Update lib.mbt re-exports**

Change `type Ctx` to `type StepArg`.

**Step 5: Update tests**

In `src/core/types_wbtest.mbt`:
- Revert all `Ctx` references to `StepArg`
- Remove all attach-related tests (they'll be re-added for the new Ctx in Task 3)
- Remove `attachments: []` from all StepArg constructions

**Step 6: Update e2e tests**

In `src/runner/e2e_wbtest.mbt`:
- Remove the `AttachWorld` and `UrlAttachWorld` tests (they'll be re-added for new Ctx in Task 5)

**Step 7: Build and verify**

Run: `moon test --target js`
Expected: All tests pass (fewer tests since attach tests removed).

**Step 8: Commit**

```bash
git commit -m "refactor(core)!: revert Ctx back to StepArg, prepare for Ctx wrapper"
```

---

### Task 2: Create new Ctx wrapper type

**Files:**
- Modify: `src/core/types.mbt` — add Ctx struct, op_get, arg, args, scenario, step methods
- Test: `src/core/types_wbtest.mbt`

**Step 1: Write failing tests**

Add to `src/core/types_wbtest.mbt`:

```moonbit
test "Ctx op_get returns StepArg" {
  let args = [StepArg::{ value: IntVal(42), raw: "42" }]
  let info : ScenarioInfo = { feature_name: "F", scenario_name: "S", tags: [] }
  let step : StepInfo = { keyword: "Given ", text: "something" }
  let ctx = Ctx::new(args, info, step)
  assert_eq(ctx[0].value, IntVal(42))
}

test "Ctx arg method" {
  let args = [StepArg::{ value: StringVal("hello"), raw: "hello" }]
  let info : ScenarioInfo = { feature_name: "F", scenario_name: "S", tags: [] }
  let step : StepInfo = { keyword: "Given ", text: "something" }
  let ctx = Ctx::new(args, info, step)
  assert_eq(ctx.arg(0).raw, "hello")
}

test "Ctx args returns view" {
  let args = [
    StepArg::{ value: IntVal(1), raw: "1" },
    StepArg::{ value: IntVal(2), raw: "2" },
  ]
  let info : ScenarioInfo = { feature_name: "F", scenario_name: "S", tags: [] }
  let step : StepInfo = { keyword: "Given ", text: "something" }
  let ctx = Ctx::new(args, info, step)
  let view = ctx.args()
  assert_eq(view.length(), 2)
}

test "Ctx scenario and step accessors" {
  let args : Array[StepArg] = []
  let info : ScenarioInfo = { feature_name: "MyFeature", scenario_name: "MyScenario", tags: ["@smoke"] }
  let step : StepInfo = { keyword: "When ", text: "I do something" }
  let ctx = Ctx::new(args, info, step)
  assert_eq(ctx.scenario().feature_name, "MyFeature")
  assert_eq(ctx.scenario().tags[0], "@smoke")
  assert_eq(ctx.step().keyword, "When ")
  assert_eq(ctx.step().text, "I do something")
}
```

**Step 2: Run tests to verify they fail**

Run: `moon test --target js`
Expected: FAIL — Ctx type doesn't exist yet.

**Step 3: Implement Ctx struct and methods**

In `src/core/types.mbt`, add after PendingAttachment:

```moonbit
///|
/// Step execution context. Wraps matched arguments with scenario/step metadata
/// and an attachment buffer.
pub(all) struct Ctx {
  priv step_args : Array[StepArg]
  priv scenario_info : ScenarioInfo
  priv step_info : StepInfo
  attachments : Array[PendingAttachment]
}

///|
/// Create a new Ctx.
pub fn Ctx::new(
  args : Array[StepArg],
  scenario : ScenarioInfo,
  step : StepInfo,
) -> Ctx {
  {
    step_args: args,
    scenario_info: scenario,
    step_info: step,
    attachments: [],
  }
}

///|
/// Index access to step arguments.
pub fn Ctx::op_get(self : Ctx, index : Int) -> StepArg {
  self.step_args[index]
}

///|
/// Explicit index access to a step argument.
pub fn Ctx::arg(self : Ctx, index : Int) -> StepArg {
  self.step_args[index]
}

///|
/// View of all step arguments.
pub fn Ctx::args(self : Ctx) -> ArrayView[StepArg] {
  self.step_args[:]
}

///|
/// Scenario metadata (feature name, scenario name, tags).
pub fn Ctx::scenario(self : Ctx) -> ScenarioInfo {
  self.scenario_info
}

///|
/// Step metadata (keyword, text).
pub fn Ctx::step(self : Ctx) -> StepInfo {
  self.step_info
}
```

**Step 4: Run tests to verify they pass**

Run: `moon test --target js`
Expected: PASS

**Step 5: Commit**

```bash
git commit -m "feat(core): add Ctx wrapper type with args, scenario, step accessors"
```

---

### Task 3: Add attach methods to new Ctx

**Files:**
- Modify: `src/core/types.mbt` — add attach/attach_bytes/attach_url to new Ctx
- Test: `src/core/types_wbtest.mbt`

**Step 1: Write failing tests**

```moonbit
test "Ctx attach text" {
  let ctx = Ctx::new(
    [],
    { feature_name: "F", scenario_name: "S", tags: [] },
    { keyword: "Given ", text: "step" },
  )
  ctx.attach("hello", "text/plain")
  assert_eq(ctx.attachments.length(), 1)
}

test "Ctx attach_bytes base64 encodes" {
  let ctx = Ctx::new(
    [],
    { feature_name: "F", scenario_name: "S", tags: [] },
    { keyword: "Given ", text: "step" },
  )
  ctx.attach_bytes(b"hello", "application/octet-stream")
  assert_eq(ctx.attachments.length(), 1)
}

test "Ctx attach_url" {
  let ctx = Ctx::new(
    [],
    { feature_name: "F", scenario_name: "S", tags: [] },
    { keyword: "Given ", text: "step" },
  )
  ctx.attach_url("https://example.com/img.png", "image/png")
  assert_eq(ctx.attachments.length(), 1)
}
```

**Step 2: Implement**

Move the attach/attach_bytes/attach_url methods from the old design, but now on the new Ctx struct. Same implementation (JSON round-trip for encoding, base64 for bytes).

**Step 3: Run tests, verify pass**

**Step 4: Commit**

```bash
git commit -m "feat(core): add attach, attach_bytes, attach_url methods to Ctx"
```

---

### Task 4: Change handler signature to (Ctx) and wire executor

**Files:**
- Modify: `src/core/registry.mbt:3` — `StepHandler((Array[StepArg])...)` → `StepHandler((Ctx) -> Unit raise Error)`
- Modify: `src/core/step_def.mbt` — all factory signatures to `(Ctx) -> Unit raise Error`
- Modify: `src/core/setup.mbt:76-148` — given/when/then/step signatures to `(Ctx) -> Unit raise Error`
- Modify: `src/runner/executor.mbt` — construct Ctx with args + info + step_info, call handler with it, drain attachments from ctx after
- Modify: `src/core/types_wbtest.mbt` — update any tests that construct StepHandler
- Modify: `src/runner/e2e_wbtest.mbt` — update all World configure implementations to use `(ctx)` instead of `(args)`
- Modify: `src/lib.mbt` — add `type Ctx` back to re-exports (alongside `type StepArg`)

**Step 1: Update StepHandler type**

In `src/core/registry.mbt`:

```moonbit
pub struct StepHandler((Ctx) -> Unit raise Error)
```

**Step 2: Update StepDef factory methods**

In `src/core/step_def.mbt`, all four methods:

```moonbit
pub fn StepDef::given(
  pattern : String,
  handler : (Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
```

**Step 3: Update Setup registration methods**

In `src/core/setup.mbt`, all four methods:

```moonbit
pub fn Setup::given(
  self : Setup,
  pattern : String,
  handler : (Ctx) -> Unit raise Error,
) -> Unit {
```

**Step 4: Update executor to construct Ctx and call handler**

In `src/runner/executor.mbt`, in the `Matched(step_def, args)` branch:

Replace:
```moonbit
(step_def.handler.0)(args)
args_for_drain.append(args)
```

With:
```moonbit
let ctx = @core.Ctx::new(args, info, step_info)
(step_def.handler.0)(ctx)
```

Remove `args_for_drain`. After TestStepFinished emission, drain from `ctx.attachments` instead:

```moonbit
if has_sinks && ctx_for_drain is Some(c) {
  if c.attachments.length() > 0 {
    emit_attachments(sinks, c.attachments, test_case_started_id, Some(ts_id))
    c.attachments.clear()
  }
}
```

Use `let mut ctx_for_drain : @core.Ctx? = None` before the match, set it to `Some(ctx)` in the Matched branch.

**Step 5: Update lib.mbt**

Ensure both `type StepArg` and `type Ctx` are in re-exports.

**Step 6: Update e2e tests**

All World implementations change from `fn(args)` to `fn(ctx)`. Replace `args[0]` with `ctx[0]`, `args[1]` with `ctx[1]`, etc.

Example for CalcWorld:
```moonbit
impl @core.World for CalcWorld with configure(self, setup) {
  setup.given("a calculator", fn(_ctx) { self.result_val = 0 })
  setup.when("I add {int} and {int}", fn(ctx) {
    match (ctx[0], ctx[1]) {
      (
        { value: @core.StepValue::IntVal(a), .. },
        { value: @core.StepValue::IntVal(b), .. },
      ) => self.result_val = a + b
      _ => ()
    }
  })
  // ... etc
}
```

**Step 7: Update other test files**

Search for `fn(args)` patterns in all `*_wbtest.mbt` files that register steps, and update to `fn(ctx)`.

**Step 8: Build and verify**

Run: `moon test --target js`
Expected: All tests pass.

**Step 9: Commit**

```bash
git commit -m "feat(core)!: change step handler signature from Array[StepArg] to Ctx

BREAKING CHANGE: Step handlers now receive a Ctx (execution context)
instead of Array[StepArg]. Use ctx[0], ctx.arg(0), ctx.args() to
access arguments. ctx.scenario() and ctx.step() provide metadata."
```

---

### Task 5: Re-add E2E attachment tests

**Files:**
- Modify: `src/runner/e2e_wbtest.mbt`

**Step 1: Add tests using new Ctx API**

```moonbit
struct AttachWorld {} derive(Default)

impl @core.World for AttachWorld with configure(_self, setup) {
  setup.given("I attach a {string}", fn(ctx) {
    ctx.attach("my note", "text/plain", file_name="note.txt")
  })
}

async test "end-to-end: step attachment emits envelope" {
  let content =
    #|Feature: Attachments
    #|
    #|  Scenario: Attach text
    #|    Given I attach a "note"
  let messages = @format.MessagesFormatter::new()
  let opts = RunOptions([FeatureSource::Text("test://attach", content)])
  opts.add_sink(messages)
  let result = run(AttachWorld::default, opts)
  assert_eq(result.summary.passed, 1)
  let output = messages.output()
  assert_true(output.contains("\"attachment\""))
  assert_true(output.contains("my note"))
}

struct UrlAttachWorld {} derive(Default)

impl @core.World for UrlAttachWorld with configure(_self, setup) {
  setup.given("I attach an external {string}", fn(ctx) {
    ignore(ctx)
    ctx.attach_url("https://example.com/img.png", "image/png")
  })
}

async test "end-to-end: attach_url emits ExternalAttachment" {
  let content =
    #|Feature: External
    #|
    #|  Scenario: URL attachment
    #|    Given I attach an external "image"
  let messages = @format.MessagesFormatter::new()
  let opts = RunOptions([FeatureSource::Text("test://extattach", content)])
  opts.add_sink(messages)
  let result = run(UrlAttachWorld::default, opts)
  assert_eq(result.summary.passed, 1)
  let output = messages.output()
  assert_true(output.contains("\"externalAttachment\""))
  assert_true(output.contains("https://example.com/img.png"))
}
```

**Step 2: Run and verify**

Run: `moon test --target js`
Expected: All tests pass.

**Step 3: Commit**

```bash
git commit -m "test: add e2e tests for Ctx attachment envelope emission"
```

---

### Task 6: moon fmt, regenerate mbti, update docs

**Files:**
- All `.mbt` files — run `moon fmt`
- Generated `.mbti` files — run `moon info`
- `README.md`, `README.mbt.md`, `AGENTS.md` — update for new Ctx wrapper design

**Step 1: Run moon fmt**

**Step 2: Run moon info**

**Step 3: Update documentation**

Update README to show new Ctx API:

```markdown
### Step Execution Context

Step handlers receive a `Ctx` (execution context):

```moonbit
setup.when("I add {int} and {int}", fn(ctx) {
  // Access arguments
  let a = ctx[0]           // index operator
  let b = ctx.arg(1)       // explicit method
  for arg in ctx.args() {  // iterate all
    // ...
  }

  // Scenario metadata
  let name = ctx.scenario().scenario_name
  let tags = ctx.scenario().tags

  // Step metadata
  let keyword = ctx.step().keyword

  // Attachments
  ctx.attach("log output", "text/plain")
  ctx.attach_bytes(screenshot, "image/png", file_name="shot.png")
  ctx.attach_url("https://ci.example.com/log.txt", "text/plain")
})
```
```

**Step 4: Run all tests**

Run: `moon test --target js`
Expected: All pass.

**Step 5: Commit**

```bash
git commit -m "chore: moon fmt, regenerate mbti, update documentation"
```

---

### Notes for the implementer

1. **StepHandler in hooks uses a different type** — `@core.StepHandler` in `hooks.mbt` is the hook handler variant `StepHandler((StepInfo, String?) -> Unit raise Error)`, NOT the same as `registry.mbt`'s `StepHandler((Ctx) -> Unit raise Error)`. Be careful not to confuse them.
2. **The executor already has `info : @core.ScenarioInfo` and `step_info : @core.StepInfo`** in scope at the point where it calls the handler — these are the values to pass to `Ctx::new()`.
3. **DocString/DataTable args** are pushed to the args array before constructing Ctx — the Ctx wraps the complete array including block arguments.
4. **`pkg.generated.mbti` files** are auto-generated — run `moon info` to regenerate.
5. **`moon fmt`** may update `moon.pkg` syntax — if it breaks the build, revert those specific changes.
