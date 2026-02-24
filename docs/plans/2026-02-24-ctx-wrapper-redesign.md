# Ctx Wrapper Redesign

## Overview

Revert the StepArg→Ctx rename. StepArg remains the individual argument type. Ctx becomes a new wrapper type that serves as the step execution context, carrying args, scenario/step metadata, and the attachment buffer.

## Ctx Type

```moonbit
pub(all) struct Ctx {
  priv args : Array[StepArg]
  priv scenario : ScenarioInfo
  priv step : StepInfo
  attachments : Array[PendingAttachment]
}
```

## Access API

```moonbit
ctx[0]              // op_get(Int) -> StepArg
ctx.arg(0)          // explicit index access
ctx.args()          // -> ArrayView[StepArg] for iteration
ctx.scenario()      // -> ScenarioInfo (feature name, scenario name, tags)
ctx.step()          // -> StepInfo (keyword, text)
ctx.attach(body, media_type, file_name?)       // text attachment
ctx.attach_bytes(data, media_type, file_name?) // binary (base64 encoded)
ctx.attach_url(url, media_type)                // external URL
```

## Handler Signature

```moonbit
// All step handlers change from:
(Array[StepArg]) -> Unit raise Error

// To:
(Ctx) -> Unit raise Error
```

Affects: `StepHandler`, `Setup::given/when/then/step`, `StepDef::given/when/then/step`.

## Executor Wiring

The executor already has `ScenarioInfo` and `StepInfo` in scope. After matching a step, it constructs `Ctx` wrapping the matched args + scenario/step info + empty attachment buffer, passes it to the handler, then drains attachments after execution.

`StepMatchResult::Matched(StepDef, Array[StepArg])` remains unchanged — Ctx is constructed by the executor, not the registry.

## What Changes vs Current PR

- Revert: StepArg name restored (was renamed to Ctx)
- New: Ctx struct wrapping Array[StepArg] + ScenarioInfo + StepInfo + attachments
- Move: attach/attach_bytes/attach_url methods from StepArg to Ctx
- Update: handler signatures from Array[StepArg] to Ctx
- Update: executor constructs Ctx with scenario/step info before calling handler

## What Stays the Same

- StepArg struct (value + raw)
- PendingAttachment enum (Embedded/External)
- Attachment envelope emission logic
- PrettyFormatter/MessagesFormatter attachment support
