# Report Output Configuration Design

## Goal

Enable moonspec to automatically write formatter output to stdout, stderr, or files — configurable via config file or programmatic API.

## Current State

- Three formatters exist: PrettyFormatter, JUnitFormatter, MessagesFormatter
- All implement `MessageSink` trait, accumulate output in memory, expose `.output()` -> String
- Wired via `RunOptions::add_sink()` — user must manually retrieve and write output
- No config file support for formatters
- No default output behavior

## Design

### Config File Schema

```json5
{
  "formatters": [
    { "type": "pretty", "output": "stdout" },
    { "type": "junit", "output": "reports/results.xml" },
    { "type": "messages", "output": "stderr" }
  ]
}
```

- `type`: `"pretty"` | `"junit"` | `"messages"`
- `output`: `"stdout"` | `"stderr"` | file path
- Pretty-specific: `"no_color": true` (optional, default false)

### New Types

```moonbit
pub(all) enum OutputDest {
  Stdout
  Stderr
  File(String)
}
```

### RunOptions API Changes

New methods:
- `add_formatter(sink, dest)` — register a formatter with an output destination
- `clear_sinks()` — remove all sinks and formatters

Existing `add_sink()` remains for backward compatibility. Sinks added via `add_sink()` receive envelopes during execution but output is not auto-written.

### MoonspecConfig Changes

New field:
- `formatters : Array[FormatterConfig]?`

```moonbit
pub(all) struct FormatterConfig {
  type_ : String       // "pretty" | "junit" | "messages"
  output : String      // "stdout" | "stderr" | file path
  no_color : Bool      // pretty-specific, default false
}
```

### Runner Behavior

After `run()`/`run_or_fail()` completes:

1. For each formatter+destination pair, call `.output()` and write to the destination
2. For file destinations, create parent directories automatically
3. Raw sinks from `add_sink()` still receive envelopes but are not auto-written (backward compatible)

### Default Behavior

If no sinks AND no formatters are configured, the runner auto-adds PrettyFormatter targeting stdout before execution.

### Interaction Rules

- Config-defined formatters and programmatic sinks/formatters are **additive**
- `clear_sinks()` clears both raw sinks and formatter+destination pairs
- Users who want silence can pass `formatters: []` in config or call `clear_sinks()`

### Codegen Integration

Generated `_test.mbt` code wires config-defined formatters by reading `MoonspecConfig.formatters` and calling `add_formatter()` for each entry.
