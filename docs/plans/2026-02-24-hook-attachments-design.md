# Hook Attachment Support Design

## Goal

Add attachment capability to all hook types (run, case, step) with properly typed contexts and structured error results.

## New Types

### HookError

Discriminated error for hook results:

```moonbit
pub(all) enum HookError {
  StepFailed(step~ : String, keyword~ : StepKeyword, message~ : String)
  ScenarioFailed(feature_name~ : String, scenario_name~ : String, message~ : String)
}
```

### HookResult

Outcome passed to `after_*` hooks, replacing the current `String?`:

```moonbit
pub(all) enum HookResult {
  Passed
  Failed(Array[HookError])
}
```

- `after_test_step`: `Failed([StepFailed(...)])` — one element
- `after_test_case`: `Failed([StepFailed(...), ...])` — the step(s) that failed
- `after_test_run`: `Failed([ScenarioFailed(...), ...])` — all failed scenarios

### Attachable Trait

Shared interface for any context that supports attachments:

```moonbit
pub(all) trait Attachable {
  attach(Self, String, String, file_name? : String) -> Unit
  attach_bytes(Self, Bytes, String, file_name? : String) -> Unit
  attach_url(Self, String, String) -> Unit
  pending_attachments(Self) -> Array[PendingAttachment]
}
```

Implemented by `Ctx`, `RunHookCtx`, `CaseHookCtx`, and `StepHookCtx`.

### Hook Context Types

```moonbit
pub(all) struct RunHookCtx {
  priv attachments : Array[PendingAttachment]
}

pub(all) struct CaseHookCtx {
  priv scenario_info : ScenarioInfo
  priv attachments : Array[PendingAttachment]
}

pub(all) struct StepHookCtx {
  priv scenario_info : ScenarioInfo
  priv step_info : StepInfo
  priv attachments : Array[PendingAttachment]
}
```

Each has accessors for its metadata fields:
- `CaseHookCtx::scenario() -> ScenarioInfo`
- `StepHookCtx::scenario() -> ScenarioInfo`
- `StepHookCtx::step() -> StepInfo`

## HookHandler Enum

Expanded from 3 to 6 variants to distinguish before/after signatures:

```moonbit
pub(all) enum HookHandler {
  RunHandler((RunHookCtx) -> Unit raise Error)
  RunAfterHandler((RunHookCtx, HookResult) -> Unit raise Error)
  CaseHandler((CaseHookCtx) -> Unit raise Error)
  CaseAfterHandler((CaseHookCtx, HookResult) -> Unit raise Error)
  StepHandler((StepHookCtx) -> Unit raise Error)
  StepAfterHandler((StepHookCtx, HookResult) -> Unit raise Error)
}
```

## Setup Registration API

```moonbit
setup.before_test_run(fn(ctx) { ctx.attach("setup log", "text/plain") })
setup.after_test_run(fn(ctx, result) { ... })
setup.before_test_case(fn(ctx) { let name = ctx.scenario().scenario_name })
setup.after_test_case(fn(ctx, result) {
  match result {
    Failed(errors) => ...
    Passed => ...
  }
})
setup.before_test_step(fn(ctx) { let kw = ctx.step().keyword })
setup.after_test_step(fn(ctx, result) { ... })
```

## Executor/Runner Wiring

- Executor constructs `CaseHookCtx`/`StepHookCtx` before calling hooks, drains `pending_attachments()` after
- Runner constructs `RunHookCtx` for run-level hooks, drains after
- Attachment envelopes use the appropriate IDs:
  - Step hooks: `testCaseStartedId` + `testStepId`
  - Case hooks: `testCaseStartedId` only
  - Run hooks: `testRunHookStartedId`

## Changes to Existing Code

- `Ctx`: `attachments` field becomes `priv`, implements `Attachable`
- `HookHandler` enum: 3 variants → 6 variants
- Hook registration methods in `Setup`: signatures updated to new context types + `HookResult`
- Executor: constructs hook contexts, drains attachments, builds `HookResult` from step/scenario errors
- Runner: constructs `RunHookCtx`, drains attachments, builds `HookResult` from run results

## What Stays the Same

- `Ctx` struct fields and step handler signature `(Ctx) -> Unit raise Error`
- `PendingAttachment` enum
- `emit_attachments` helper
- Step-level attachment emission flow
