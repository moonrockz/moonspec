# Test Case Retry Logic Design

## Goal

Add configurable retry logic for failed test cases, using the existing `@async.retry` infrastructure and Cucumber Messages protocol fields (`TestCaseStarted.attempt`, `TestCaseFinished.willBeRetried`).

## Retry Count Resolution

Per-scenario retry count resolves in priority order:

1. `@retry(N)` tag on the scenario (highest priority)
2. `RunOptions.retries_` global default
3. `0` (no retries)

## RunOptions

```moonbit
// New field
priv mut retries_ : Int  // default 0

// New builder method
pub fn retries(self : RunOptions, value : Int) -> RunOptions
```

## Execution Flow

In `execute_pickle()`, when `max_retries > 0`:

1. Wrap scenario execution in `@async.retry(Immediate, max_retry=max_retries)`:
   - Mutable `attempt` counter starts at 0, increments each call
   - Each attempt emits `TestCaseStarted` with the `attempt` field
   - Each attempt emits `TestCaseFinished`:
     - On failure with retries remaining: `willBeRetried: true`, then raise to trigger retry
     - On final attempt or pass: `willBeRetried: false`
2. Each attempt uses a fresh world instance via `factory()`
3. Only the final attempt's `ScenarioResult` is returned

When `max_retries == 0`, the current code path is unchanged (no async overhead).

## Tag Parsing

Extract retry count from pickle tags matching `@retry(\d+)`:

```moonbit
fn parse_retry_tag(tags : Array[String]) -> Int?
```

Returns `Some(n)` if a `@retry(N)` tag is found, `None` otherwise.

## RunSummary

```moonbit
pub(all) struct RunSummary {
  // ... existing fields
  retried : Int  // scenarios that needed at least one retry
}
```

A scenario counts as "retried" if it took more than one attempt, regardless of final outcome.

## Reporting

Summary line example: `5 scenarios (4 passed, 1 failed), 2 retried`

## What Stays the Same

- `ScenarioResult` struct (no changes)
- Parallel execution via `@async.all()` (retries happen inside each task)
- Hook execution (hooks run normally on each attempt)
- Step execution and envelope emission within an attempt
- Existing tests (retry count defaults to 0)
