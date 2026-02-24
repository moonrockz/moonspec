# Attachment Envelope Support Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Enable step definitions and test case hooks to attach content (text, binary, URLs) to test results via Cucumber Messages Attachment/ExternalAttachment envelopes, and rename StepArg to Ctx.

**Architecture:** `Ctx` replaces `StepArg` as the step execution context, gaining an internal attachment buffer. After each step/hook executes, the runner drains buffered attachments and emits Attachment/ExternalAttachment envelopes. Base64 encoding uses `moonbitlang/x/codec/base64`.

**Tech Stack:** MoonBit, moonrockz/cucumber-messages (Attachment, ExternalAttachment, AttachmentContentEncoding), moonbitlang/x/codec/base64

---

### Task 1: Rename StepArg to Ctx in core types

**Files:**
- Modify: `src/core/types.mbt:70-93`
- Modify: `src/core/types.mbt:98`
- Modify: `src/core/registry.mbt:3`
- Modify: `src/core/registry.mbt:94`
- Modify: `src/core/step_def.mbt:64,73,82,91`
- Modify: `src/core/setup.mbt:79,98,117,136`
- Modify: `src/core/types_wbtest.mbt` (all StepArg references)
- Modify: `src/runner/executor.mbt:236,245,255`
- Modify: `src/lib.mbt:11`

**Step 1: Rename the struct in types.mbt**

In `src/core/types.mbt`, rename the struct and its factory:

```moonbit
pub(all) struct Ctx {
  value : StepValue
  raw : String
} derive(Show, Eq)

pub fn Ctx::from_param(param : @cucumber_expressions.Param) -> Ctx {
  // ... same body ...
}
```

And update `StepMatchResult`:

```moonbit
pub(all) enum StepMatchResult {
  Matched(StepDef, Array[Ctx])
  Undefined(
    step_text~ : String,
    keyword~ : String,
    snippet~ : String,
    suggestions~ : Array[String]
  )
}
```

**Step 2: Update StepHandler in registry.mbt**

```moonbit
pub struct StepHandler((Array[Ctx]) -> Unit raise Error)
```

And update `find_match`:

```moonbit
let args = m.params.map(Ctx::from_param)
```

**Step 3: Update StepDef factory methods in step_def.mbt**

Change all four method signatures from `(Array[StepArg])` to `(Array[Ctx])`:

```moonbit
pub fn StepDef::given(
  pattern : String,
  handler : (Array[Ctx]) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
```

(Same for `when`, `then`, `step`.)

**Step 4: Update Setup registration methods in setup.mbt**

Change all four method signatures from `(Array[StepArg])` to `(Array[Ctx])`:

```moonbit
pub fn Setup::given(
  self : Setup,
  pattern : String,
  handler : (Array[Ctx]) -> Unit raise Error,
) -> Unit {
```

(Same for `when`, `then`, `step`.)

**Step 5: Update executor.mbt references**

In `src/runner/executor.mbt`, update the two places that construct StepArg:

```moonbit
// Line 245 — change @core.StepArg:: to @core.Ctx::
args.push(@core.Ctx::{
  value: DocStringVal(doc),
  raw: ds.content,
})
// Line 255 — same
args.push(@core.Ctx::{
  value: DataTableVal(table),
  raw: "",
})
```

Update the comment at line 236 from "last StepArg" to "last Ctx".

**Step 6: Update re-exports in lib.mbt**

```moonbit
type Ctx,  // was type StepArg,
```

**Step 7: Update tests in types_wbtest.mbt**

Replace all `StepArg` references with `Ctx`. Test names should be updated too (e.g., `"Ctx struct destructuring"`).

**Step 8: Update e2e tests in e2e_wbtest.mbt**

The e2e tests use `@core.StepArg::` — no, they use pattern matching on `@core.StepValue::IntVal` which doesn't reference `StepArg` directly. Verify by searching. The `{ value: ..., .. }` destructuring syntax works regardless of type name since it's structural.

**Step 9: Build and verify**

Run: `mise run test:unit`
Expected: All tests pass with the rename.

**Step 10: Commit**

```bash
git add src/core/types.mbt src/core/registry.mbt src/core/step_def.mbt src/core/setup.mbt src/runner/executor.mbt src/lib.mbt src/core/types_wbtest.mbt
git commit -m "refactor(core)!: rename StepArg to Ctx

BREAKING CHANGE: StepArg type is now Ctx. All step handler signatures
use Array[Ctx] instead of Array[StepArg]."
```

---

### Task 2: Add PendingAttachment type and attachment buffer to Ctx

**Files:**
- Modify: `src/core/types.mbt`
- Modify: `src/core/moon.pkg.json` (add base64 dependency)
- Test: `src/core/types_wbtest.mbt`

**Step 1: Write the failing test**

Add to `src/core/types_wbtest.mbt`:

```moonbit
test "Ctx attach text" {
  let ctx : Ctx = { value: IntVal(42), raw: "42", attachments: [] }
  ctx.attach("hello world", "text/plain")
  assert_eq(ctx.attachments.length(), 1)
  match ctx.attachments[0] {
    PendingAttachment::Embedded(body=b, encoding=e, media_type=mt, ..) => {
      assert_eq(b, "hello world")
      assert_eq(mt, "text/plain")
      match e {
        @cucumber_messages.AttachmentContentEncoding::Identity => ()
        _ => fail("expected Identity encoding")
      }
    }
    _ => fail("expected Embedded attachment")
  }
}
```

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — `attachments` field doesn't exist yet.

**Step 3: Add PendingAttachment enum and update Ctx**

In `src/core/types.mbt`, add the enum and update Ctx:

```moonbit
///|
/// A buffered attachment waiting to be emitted as an envelope.
pub(all) enum PendingAttachment {
  Embedded(
    body~ : String,
    encoding~ : @cucumber_messages.AttachmentContentEncoding,
    media_type~ : String,
    file_name~ : String?,
  )
  External(
    url~ : String,
    media_type~ : String,
  )
}

///|
pub(all) struct Ctx {
  value : StepValue
  raw : String
  attachments : Array[PendingAttachment]
} derive(Show, Eq)
```

**Step 4: Add dependency on cucumber-messages to core package**

In `src/core/moon.pkg.json`, ensure `moonrockz/cucumber-messages` is in the imports (it may already be there for other types). Check and add if missing.

**Step 5: Run test to verify it passes**

Run: `mise run test:unit`
Expected: PASS

**Step 6: Fix all Ctx construction sites**

Every place that constructs a `Ctx` now needs `attachments: []`. Update:

- `src/core/types.mbt` — `Ctx::from_param`: add `attachments: []` to the return struct
- `src/runner/executor.mbt` — the two `@core.Ctx::{ value: ..., raw: ... }` sites: add `attachments: []`
- `src/core/types_wbtest.mbt` — all existing test Ctx constructions: add `attachments: []`

**Step 7: Run all tests**

Run: `mise run test:unit`
Expected: All pass.

**Step 8: Commit**

```bash
git add src/core/types.mbt src/core/types_wbtest.mbt src/core/moon.pkg.json src/runner/executor.mbt
git commit -m "feat(core): add PendingAttachment type and attachments buffer to Ctx"
```

---

### Task 3: Implement attach(), attach_bytes(), attach_url() methods on Ctx

**Files:**
- Modify: `src/core/types.mbt`
- Modify: `src/core/moon.pkg.json` (add base64 dep)
- Test: `src/core/types_wbtest.mbt`

**Step 1: Write the failing tests**

Add to `src/core/types_wbtest.mbt`:

```moonbit
test "Ctx attach_bytes base64 encodes" {
  let ctx : Ctx = { value: IntVal(0), raw: "", attachments: [] }
  ctx.attach_bytes(b"hello", "application/octet-stream")
  assert_eq(ctx.attachments.length(), 1)
  match ctx.attachments[0] {
    PendingAttachment::Embedded(body=b, encoding=e, media_type=mt, ..) => {
      assert_eq(mt, "application/octet-stream")
      // "hello" base64 = "aGVsbG8="
      assert_eq(b, "aGVsbG8=")
      match e {
        @cucumber_messages.AttachmentContentEncoding::Base64 => ()
        _ => fail("expected Base64 encoding")
      }
    }
    _ => fail("expected Embedded attachment")
  }
}

test "Ctx attach_url" {
  let ctx : Ctx = { value: IntVal(0), raw: "", attachments: [] }
  ctx.attach_url("https://example.com/img.png", "image/png")
  assert_eq(ctx.attachments.length(), 1)
  match ctx.attachments[0] {
    PendingAttachment::External(url=u, media_type=mt) => {
      assert_eq(u, "https://example.com/img.png")
      assert_eq(mt, "image/png")
    }
    _ => fail("expected External attachment")
  }
}

test "Ctx attach with file_name" {
  let ctx : Ctx = { value: IntVal(0), raw: "", attachments: [] }
  ctx.attach("content", "text/plain", file_name="notes.txt")
  match ctx.attachments[0] {
    PendingAttachment::Embedded(file_name=Some("notes.txt"), ..) => ()
    _ => fail("expected file_name=notes.txt")
  }
}
```

**Step 2: Run tests to verify they fail**

Run: `mise run test:unit`
Expected: FAIL — methods don't exist yet.

**Step 3: Add base64 dependency to core moon.pkg.json**

In `src/core/moon.pkg.json`, add `"moonbitlang/x/codec/base64"` to imports.

**Step 4: Implement the three methods**

In `src/core/types.mbt`:

```moonbit
///|
/// Attach text content to the current step/hook.
pub fn Ctx::attach(
  self : Ctx,
  body : String,
  media_type : String,
  file_name~ : String? = None,
) -> Unit {
  self.attachments.push(
    PendingAttachment::Embedded(
      body~,
      encoding=@cucumber_messages.AttachmentContentEncoding::Identity,
      media_type~,
      file_name~,
    ),
  )
}

///|
/// Attach binary content (Base64 encoded) to the current step/hook.
pub fn Ctx::attach_bytes(
  self : Ctx,
  data : Bytes,
  media_type : String,
  file_name~ : String? = None,
) -> Unit {
  let body = @base64.encode(data[:])
  self.attachments.push(
    PendingAttachment::Embedded(
      body~,
      encoding=@cucumber_messages.AttachmentContentEncoding::Base64,
      media_type~,
      file_name~,
    ),
  )
}

///|
/// Attach an external URL reference to the current step/hook.
pub fn Ctx::attach_url(
  self : Ctx,
  url : String,
  media_type : String,
) -> Unit {
  self.attachments.push(PendingAttachment::External(url~, media_type~))
}
```

**Step 5: Run tests to verify they pass**

Run: `mise run test:unit`
Expected: All pass.

**Step 6: Commit**

```bash
git add src/core/types.mbt src/core/types_wbtest.mbt src/core/moon.pkg.json
git commit -m "feat(core): add attach, attach_bytes, attach_url methods to Ctx"
```

---

### Task 4: Emit Attachment/ExternalAttachment envelopes in executor

**Files:**
- Modify: `src/runner/run.mbt` (add make_attachment_envelope, make_external_attachment_envelope)
- Modify: `src/runner/executor.mbt` (drain attachments after step/hook execution)

**Step 1: Add envelope factory functions**

In `src/runner/run.mbt`, add:

```moonbit
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
  json_map["timestamp"] = ({
    "seconds": (0 : Int).to_json(),
    "nanos": (0 : Int).to_json(),
  } : Json)
  let json : Json = { "attachment": json_map.to_json() }
  @json.from_json(json) catch { _ => panic() }
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
  json_map["timestamp"] = ({
    "seconds": (0 : Int).to_json(),
    "nanos": (0 : Int).to_json(),
  } : Json)
  let json : Json = { "externalAttachment": json_map.to_json() }
  @json.from_json(json) catch { _ => panic() }
}
```

**Step 2: Add drain_attachments helper to executor**

In `src/runner/executor.mbt`, add a helper that drains Ctx attachments and emits envelopes:

```moonbit
///|
fn emit_attachments(
  sinks : Array[&@core.MessageSink],
  attachments : Array[@core.PendingAttachment],
  test_case_started_id : String,
  test_step_id : String?,
) -> Unit {
  for att in attachments {
    match att {
      @core.PendingAttachment::Embedded(body~, encoding~, media_type~, file_name~) => {
        let enc_str = match encoding {
          @cucumber_messages.AttachmentContentEncoding::Identity => "IDENTITY"
          @cucumber_messages.AttachmentContentEncoding::Base64 => "BASE64"
        }
        emit(
          sinks,
          make_attachment_envelope(
            body, enc_str, media_type, file_name,
            Some(test_case_started_id), test_step_id,
          ),
        )
      }
      @core.PendingAttachment::External(url~, media_type~) =>
        emit(
          sinks,
          make_external_attachment_envelope(
            url, media_type,
            Some(test_case_started_id), test_step_id,
          ),
        )
    }
  }
}
```

**Step 3: Wire attachment emission into step execution**

In `src/runner/executor.mbt`, after the `TestStepFinished` emission for regular steps (around line 286-296), add attachment draining. The step handler receives `args` which contains `Ctx` values — we need to collect attachments from all args after execution.

The key insight: step handlers receive `Array[Ctx]` and can call `attach()` on any of them. We drain attachments from all Ctx values in args after step execution.

After `TestStepFinished` emission (line ~296), before the after_step_hooks block:

```moonbit
// Drain attachments from step args
if has_sinks {
  for arg in args_for_drain {
    if arg.attachments.length() > 0 {
      emit_attachments(sinks, arg.attachments, test_case_started_id, Some(ts_id))
      arg.attachments.clear()
    }
  }
}
```

We need to capture `args` from the Matched branch so they're accessible after execution. Add a mutable variable before the match block:

```moonbit
let args_for_drain : Array[@core.Ctx] = []
```

Then in the `Matched` branch, after `(step_def.handler.0)(args)`:

```moonbit
args_for_drain.append(args)
```

**Step 4: Wire attachment emission into before/after test case hooks**

For hook steps, we need to pass a Ctx to hook handlers so they can attach content. This requires changing the hook handler signatures to accept an optional Ctx, or creating a dedicated Ctx for hook attachment collection.

Simpler approach: create a fresh Ctx per hook invocation, pass it alongside existing params, and drain after execution.

This requires updating `HookHandler::CaseHandler` to accept a Ctx. Since this is a larger change to the hook system, we'll take a focused approach:

- Create a fresh `Ctx` with empty values before each before/after_test_case hook call
- The hook handler doesn't receive it directly (signature unchanged)
- Instead, we'll add a `hook_ctx` field to the `Setup` that hooks can access

**Alternative (simpler):** Since hook handlers currently have the signature `(ScenarioInfo, String?) -> Unit`, changing them to also accept a Ctx would be a breaking change. For this first iteration, we support attachments in step handlers only, and add hook attachment support as a fast follow-up.

**Decision: Steps only for now, hooks in a follow-up commit within this branch.**

**Step 5: Build and verify**

Run: `mise run test:unit`
Expected: All pass (no behavioral change yet in tests).

**Step 6: Commit**

```bash
git add src/runner/run.mbt src/runner/executor.mbt
git commit -m "feat(runner): emit Attachment/ExternalAttachment envelopes after step execution"
```

---

### Task 5: Add Ctx to hook handlers for test case hooks

**Files:**
- Modify: `src/core/registry.mbt` — update CaseHandler to include Ctx
- Modify: `src/core/hooks.mbt` or wherever HookHandler is defined
- Modify: `src/core/setup.mbt` — update before/after_test_case to create and pass Ctx
- Modify: `src/runner/executor.mbt` — create Ctx for hooks and drain attachments

**Step 1: Find HookHandler definition**

Search for `HookHandler` enum definition to understand current structure.

**Step 2: Update CaseHandler to pass Ctx**

Change `CaseHandler` from `(ScenarioInfo, String?) -> Unit` to `(ScenarioInfo, String?, Ctx) -> Unit`.

In `setup.mbt`, update `before_test_case`:

```moonbit
pub fn Setup::before_test_case(
  self : Setup,
  handler : (ScenarioInfo, Ctx) -> Unit raise Error,
  loc~ : SourceLoc,
) -> Unit {
  let source : StepSource? = Some(StepSource::new(uri=loc.to_string()))
  self.hook_reg.add(
    HookType::BeforeTestCase,
    CaseHandler((info, _result, ctx) => handler(info, ctx)),
    source~,
  )
}
```

And `after_test_case`:

```moonbit
pub fn Setup::after_test_case(
  self : Setup,
  handler : (ScenarioInfo, String?, Ctx) -> Unit raise Error,
  loc~ : SourceLoc,
) -> Unit {
  let source : StepSource? = Some(StepSource::new(uri=loc.to_string()))
  self.hook_reg.add(HookType::AfterTestCase, CaseHandler(handler), source~)
}
```

**Step 3: Update executor to create Ctx for hook invocations and drain**

In executor.mbt, for before_test_case hooks:

```moonbit
let hook_ctx : @core.Ctx = { value: @core.StepValue::IntVal(0), raw: "", attachments: [] }
match hook.handler {
  @core.CaseHandler(h) =>
    try {
      h(info, None, hook_ctx)
      "PASSED"
    } catch {
      e => {
        hook_err = Some(e.to_string())
        "FAILED"
      }
    }
  _ => "PASSED"
}
// After TestStepFinished emission:
if has_sinks && hook_ctx.attachments.length() > 0 {
  emit_attachments(sinks, hook_ctx.attachments, test_case_started_id, Some(ts_id))
}
```

Same pattern for after_test_case hooks.

**Step 4: Build and verify**

Run: `mise run test:unit`
Expected: All pass.

**Step 5: Commit**

```bash
git add src/core/setup.mbt src/core/hooks.mbt src/runner/executor.mbt
git commit -m "feat(runner): pass Ctx to test case hooks for attachment support"
```

---

### Task 6: Add PrettyFormatter support for Attachment envelopes

**Files:**
- Modify: `src/format/pretty.mbt`
- Test: `src/format/pretty_wbtest.mbt` (if exists, otherwise add to e2e tests)

**Step 1: Write the failing test**

Add to the appropriate test file:

```moonbit
test "PrettyFormatter handles Attachment envelope" {
  let fmt = PrettyFormatter::new(no_color=true)
  let att_json : Json = {
    "attachment": {
      "body": "hello",
      "contentEncoding": "IDENTITY",
      "mediaType": "text/plain",
      "fileName": "notes.txt",
      "timestamp": { "seconds": 0, "nanos": 0 },
    },
  }
  let envelope : @cucumber_messages.Envelope = @json.from_json(att_json) catch {
    _ => panic()
  }
  (@core.MessageSink::on_message(fmt, envelope) : Unit)
  assert_true(fmt.output().contains("notes.txt"))
}
```

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — no match arm for Attachment.

**Step 3: Add match arms in PrettyFormatter**

In `src/format/pretty.mbt`, in the `on_message` match block, before the `_ => ()` catch-all:

```moonbit
Attachment(att) => {
  let name = match att.fileName {
    Some(f) => f
    None => att.mediaType
  }
  self.buffer = self.buffer + "    [attached: " + name + "]\n"
}
ExternalAttachment(ext) => {
  self.buffer = self.buffer + "    [attached: " + ext.url + " (" + ext.mediaType + ")]\n"
}
```

**Step 4: Run test to verify it passes**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add src/format/pretty.mbt src/format/pretty_wbtest.mbt
git commit -m "feat(format): display attachment info in PrettyFormatter"
```

---

### Task 7: E2E test — step attaches text, verify in message stream

**Files:**
- Modify: `src/runner/e2e_wbtest.mbt`

**Step 1: Write the E2E test**

```moonbit
struct AttachWorld {
  mut log : String
} derive(Default)

impl @core.World for AttachWorld with configure(self, setup) {
  setup.given("I attach a note", fn(args) {
    args[0].attach("my note", "text/plain", file_name="note.txt")
    self.log = "attached"
  })
}

async test "end-to-end: step attachment emits envelope" {
  let content =
    #|Feature: Attachments
    #|
    #|  Scenario: Attach text
    #|    Given I attach a note
  let messages = @format.MessagesFormatter::new()
  let opts = RunOptions([FeatureSource::Text("test://attach", content)])
  opts.add_sink(messages)
  let result = run(AttachWorld::default, opts)
  assert_eq(result.summary.passed, 1)
  let output = messages.output()
  // Verify Attachment envelope was emitted
  assert_true(output.contains("\"attachment\""))
  assert_true(output.contains("my note"))
  assert_true(output.contains("note.txt"))
}
```

**Step 2: Run test to verify**

Run: `mise run test:unit`
Expected: PASS (if all wiring is correct). If FAIL, debug the attachment drain path.

**Step 3: Commit**

```bash
git add src/runner/e2e_wbtest.mbt
git commit -m "test: add e2e test for step attachment envelope emission"
```

---

### Task 8: E2E test — attach_url emits ExternalAttachment

**Files:**
- Modify: `src/runner/e2e_wbtest.mbt`

**Step 1: Write the test**

```moonbit
struct UrlAttachWorld {} derive(Default)

impl @core.World for UrlAttachWorld with configure(_self, setup) {
  setup.given("I attach an external image", fn(args) {
    args[0].attach_url("https://example.com/img.png", "image/png")
  })
}

async test "end-to-end: attach_url emits ExternalAttachment" {
  let content =
    #|Feature: External
    #|
    #|  Scenario: URL attachment
    #|    Given I attach an external image
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

Run: `mise run test:unit`
Expected: PASS

**Step 3: Commit**

```bash
git add src/runner/e2e_wbtest.mbt
git commit -m "test: add e2e test for ExternalAttachment envelope emission"
```

---

### Task 9: Update re-exports, run moon fmt, regenerate mbti

**Files:**
- Modify: `src/lib.mbt` — add `type PendingAttachment` to re-exports
- All files: run `moon fmt`
- Generated: regenerate `pkg.generated.mbti` files

**Step 1: Update lib.mbt re-exports**

Add to the `pub using @core` block:

```moonbit
type PendingAttachment,
```

**Step 2: Run moon fmt**

Run: `moon fmt`

**Step 3: Regenerate mbti**

Run: `moon info`

**Step 4: Run all tests**

Run: `mise run test:unit`
Expected: All pass.

**Step 5: Commit**

```bash
git add -A
git commit -m "chore: moon fmt and regenerate mbti interfaces"
```

---

### Task 10: Update README and examples

**Files:**
- Modify: `README.md` — update StepArg references to Ctx, document attach API
- Modify: `README.mbt.md` — same
- Modify: examples that reference StepArg

**Step 1: Search and update all StepArg references in docs**

Replace `StepArg` with `Ctx` in README.md, README.mbt.md, and AGENTS.md.

Add a section documenting the attachment API:

```markdown
### Attachments

Steps and hooks can attach content to test results:

```moonbit
setup.given("I take a screenshot", fn(args) {
  // Attach text
  args[0].attach("log output", "text/plain")

  // Attach binary (auto base64-encoded)
  args[0].attach_bytes(screenshot_bytes, "image/png", file_name="screenshot.png")

  // Attach external URL
  args[0].attach_url("https://ci.example.com/artifacts/log.txt", "text/plain")
})
```
```

**Step 2: Update examples**

Check each example directory for StepArg references and update to Ctx.

**Step 3: Commit**

```bash
git add README.md README.mbt.md AGENTS.md examples/
git commit -m "docs: update documentation for Ctx rename and attachment API"
```

---

### Notes for the implementer

1. **pkg.generated.mbti files** are auto-generated — run `moon info` to regenerate after code changes. Never edit them manually.
2. **The `args[0].attach()` pattern** works because MoonBit structs are reference types — the Ctx in the args array is the same object the runner drains.
3. **Base64 import path** is `@base64` after adding `"moonbitlang/x/codec/base64"` to moon.pkg.json imports.
4. **HookHandler definition** — search for `pub(all) enum HookHandler` to find its location (likely in `src/core/hooks.mbt` or similar).
5. **The `add_sink` method on RunOptions** — verify it exists or check how sinks are configured. It may be `RunOptions::sink()` or similar.
6. **Conventional Commits** — all commit messages must use the format specified in CLAUDE.md.
