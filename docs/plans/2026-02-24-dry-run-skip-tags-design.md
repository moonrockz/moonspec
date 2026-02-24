# Dry-Run Mode & Skip Tags Design

## Goal

Add dry-run mode for step-definition validation without execution, skip-with-reason
infrastructure, and configurable `@skip`/`@ignore` tag support.

## Architecture

Three composable features built on a shared foundation:

### A. Skipped(String?) Foundation

Change `StepStatus::Skipped` to `Skipped(String?)` and `ScenarioStatus::Skipped`
to `Skipped(String?)`. This carries an optional reason through the entire result
chain.

- `ScenarioStatus::from_steps` propagates the reason from the first skipped step
- `step_status_to_string` maps `Skipped(_)` to `"SKIPPED"`
- The reason populates the `message` field in `TestStepFinished` envelopes
- **Breaking change**: pattern matches on `Skipped` must update to `Skipped(_)`

### B. Dry-Run Mode

A `dry_run` flag on `RunOptions`. When enabled:

- Steps are matched against the registry but handlers are not called
- All hooks (test case and test step level) are skipped
- Matched steps get `StepStatus::Skipped(Some("dry run"))`
- Undefined steps remain `StepStatus::Undefined`
- Scenario status: `Skipped(Some("dry run"))` when all steps match,
  `Undefined` if any step is undefined
- Retries are not attempted (nothing failed)
- Cucumber Messages envelopes still emitted with `"SKIPPED"` status and
  `"dry run"` message

### C. Skip/Ignore Tags

Configurable tags that skip entire scenarios before execution:

- Default skip tags: `["@skip", "@ignore"]`
- Configured via `RunOptions.skip_tags(["@skip", "@ignore", "@wip"])`
- Tag format: `@skip("reason")` extracts the quoted reason;
  bare `@skip` uses the tag name as the reason
- Check happens in `execute_pickle` before calling `execute_scenario`
- When a skip tag matches: emit `TestCaseStarted`/`TestCaseFinished`,
  all steps as `Skipped(Some(reason))`, no hooks run
- First matching tag wins

### D. Follow-On Work (Separate Issues)

- Wire skip tag defaults into `MoonspecConfig` JSON5 schema
- Codegen picks up skip tag config from config file

## Components

### RunOptions Additions

```
dry_run_ : Bool          (default false)
skip_tags_ : Array[String]  (default ["@skip", "@ignore"])
```

With getter/setter methods for each.

### parse_skip_tag

```
parse_skip_tag(tags: Array[String], skip_tags: Array[String]) -> String?
```

Scans pickle tags against configured skip tag list. Extracts reason from
`@tag("reason")` format. Returns first match or None.

### Executor Changes

`execute_scenario` gains `dry_run? : Bool = false`. When true:
- Skip all hooks
- For each step: match against registry, report Skipped or Undefined
- Never call handlers

### Pickle-Level Skip

In `execute_pickle`, before calling `execute_scenario`:
- Call `parse_skip_tag` against pickle tags and configured skip tags
- If matched, build a ScenarioResult with all steps Skipped(reason)
- Emit envelope pair, return early

## Edge Cases

- **Dry-run + skip tags**: skip tag takes precedence (no step matching needed)
- **Dry-run + retries**: no retries (nothing failed)
- **Skip tag + retries**: not retried (Skipped != Failed)
- **Invalid tag format**: `@skip()`, `@skip(no quotes)` use bare tag name as reason
- **Mixed scenarios**: only tagged scenarios skip; others execute normally

## Testing

- Unit: `parse_skip_tag`, `Skipped(String?)` in `from_steps`, reason propagation
- Executor: dry-run match/undefined, dry-run skips hooks
- E2E: dry-run full run, `@skip("reason")`, `@ignore`, mixed skip/normal,
  dry-run + skip tag interaction, custom skip tags
- Envelope: `"SKIPPED"` status with message in `TestStepFinished`
