# Message-Stream Pipeline Design

**Date:** 2026-02-22
**Issue:** moonspec-kyq

## Problem

The runner currently produces a `RunResult` after execution completes. Formatters consume this batch result. The cucumber protocol requires streaming `Envelope` messages during execution for interop with ecosystem tools.

## Design

### MessageSink Trait

Replace the multi-method `Formatter` trait with a single-method `MessageSink` trait:

```moonbit
pub trait MessageSink {
  on_message(Self, @cucumber_messages.Envelope) -> Unit
}
```

The runner accepts `sinks?: Array[&MessageSink] = []` as a new optional parameter on `run()`.

### Envelope Emission Points

The runner emits envelopes at each pipeline phase, matching canonical cucumber ordering:

| Phase | Envelope | When |
|-------|----------|------|
| Start | `Meta` | Before anything else |
| Discovery | `Source` | After loading each feature source |
| Discovery | `GherkinDocument` | After parsing each feature |
| Compilation | `Pickle` | After compiling each pickle |
| Test Planning | `TestCase` | After matching steps to definitions |
| Execution | `TestRunStarted` | Before first scenario |
| Execution | `TestCaseStarted` | Before each scenario |
| Execution | `TestStepStarted` | Before each step |
| Execution | `TestStepFinished` | After each step |
| Execution | `TestCaseFinished` | After each scenario |
| Execution | `TestRunFinished` | After all scenarios |

11 envelope types in this pass. Hook, StepDefinition, ParameterType, Attachment, Suggestion, ParseError added incrementally later.

### Test Planning Phase

New phase between filtering and execution:

```
Cache → Compile → Filter → Plan (NEW) → Execute → Results
```

Creates a throwaway world + registry to resolve step matches before execution. Builds `TestCase` envelopes with `TestStep` entries linking `pickleStepId` to `stepDefinitionIds`. Execution still creates fresh world/registry per scenario as today.

### ID Generation

Simple incrementing counter scoped to the run: `"tc-1"`, `"ts-1"`, `"tr-1"`. IDs cross-reference between messages (e.g., `TestCase.pickleId` → `Pickle.id`).

### Formatter Refactoring

Remove the `Formatter` trait. Each formatter implements `MessageSink`:

- **Pretty** — Pattern-matches on TestCaseStarted/TestStepFinished/TestRunFinished etc. Accumulates colored output in a buffer.
- **NDJSON** — Serializes every envelope to JSON + newline, writes immediately (true streaming).
- **JUnit** — Buffers TestCaseFinished/TestStepFinished envelopes, emits XML on TestRunFinished.

### Parallel Execution

Concurrent scenarios emit interleaved envelopes. This is protocol-correct. Sinks that need ordering buffer internally.

### Testing

- `CollectorSink` test helper that appends to `Array[Envelope]`
- Unit tests per phase verifying envelope types and ordering
- Integration test verifying full envelope sequence end-to-end
- NDJSON round-trip test (serialize → parse → verify)
- Existing tests unaffected (sinks defaults to empty)
