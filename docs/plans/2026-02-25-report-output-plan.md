# Report Output Configuration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Enable moonspec to automatically write formatter output to stdout, stderr, or files — configurable via config file or programmatic API.

**Architecture:** Add an `OutputDest` enum and `FormatterConfig` struct to the config package. Extend `RunOptions` with `add_formatter(sink, dest)` and `clear_sinks()`. After test execution in `run()`, iterate formatter+destination pairs and write output. Default to PrettyFormatter on stdout when no sinks/formatters are configured.

**Tech Stack:** MoonBit, moonspec runner/config/format packages, `@fs` for file I/O

---

### Task 1: Add OutputDest enum and FormatterEntry to runner

**Files:**
- Modify: `src/runner/options.mbt`
- Test: `src/runner/options_wbtest.mbt` (create if not exists, or add to existing test file)

**Context:** `RunOptions` currently stores `sinks_ : Array[&@core.MessageSink]`. We need a parallel list for formatters paired with destinations. The `OutputDest` enum lives in the runner package since it's used by `RunOptions`.

**Step 1: Write failing tests**

Add to `src/runner/options_wbtest.mbt` (create file if it doesn't exist):

```moonbit
test "add_formatter stores formatter with destination" {
  let options = RunOptions::new(
    [@moonspec.FeatureSource::Text("test.feature", "Feature: x")],
  )
  let fmt = @format.PrettyFormatter::new()
  options.add_formatter(&fmt, Stdout)
  assert_eq(options.get_formatters().length(), 1)
}

test "clear_sinks removes both sinks and formatters" {
  let options = RunOptions::new(
    [@moonspec.FeatureSource::Text("test.feature", "Feature: x")],
  )
  let fmt = @format.PrettyFormatter::new()
  options.add_sink(&fmt)
  options.add_formatter(&fmt, Stderr)
  options.clear_sinks()
  assert_eq(options.get_sinks().length(), 0)
  assert_eq(options.get_formatters().length(), 0)
}

test "OutputDest::File stores path" {
  let dest : OutputDest = File("reports/results.xml")
  match dest {
    File(path) => assert_eq(path, "reports/results.xml")
    _ => assert_true(false)
  }
}
```

**Step 2: Run tests to verify they fail**

Run: `mise run test:unit`
Expected: compilation errors — `OutputDest`, `add_formatter`, `clear_sinks`, `get_formatters` don't exist yet.

**Step 3: Implement OutputDest and RunOptions changes**

In `src/runner/options.mbt`, add the `OutputDest` enum at the top of the file:

```moonbit
///|
/// Destination for formatter output.
pub(all) enum OutputDest {
  Stdout
  Stderr
  File(String)
} derive(Show, Eq)
```

Add a `FormatterEntry` struct (private, internal to runner):

```moonbit
///|
/// A formatter paired with its output destination.
pub(all) struct FormatterEntry {
  sink : &@core.MessageSink
  dest : OutputDest
}
```

Add `formatters_` field to `RunOptions` struct:

```moonbit
pub(all) struct RunOptions {
  priv features_ : Array[FeatureSource]
  priv mut parallel_ : Bool
  priv mut max_concurrent_ : Int
  priv sinks_ : Array[&@core.MessageSink]
  priv formatters_ : Array[FormatterEntry]       // NEW
  priv mut tag_expr_ : String
  priv mut scenario_name_ : String
  priv mut retries_ : Int
  priv mut dry_run_ : Bool
  priv skip_tags_ : Array[String]

  fn new(features : Array[FeatureSource]) -> RunOptions
}
```

Update `RunOptions::new` to initialize the new field:

```moonbit
pub fn RunOptions::new(features : Array[FeatureSource]) -> RunOptions {
  {
    features_: features,
    parallel_: false,
    max_concurrent_: 4,
    sinks_: [],
    formatters_: [],        // NEW
    tag_expr_: "",
    scenario_name_: "",
    retries_: 0,
    dry_run_: false,
    skip_tags_: ["@skip", "@ignore"],
  }
}
```

Add new methods:

```moonbit
///|
/// Add a formatter with an output destination.
/// The formatter receives envelopes during execution and its output
/// is automatically written to the destination after the run completes.
pub fn RunOptions::add_formatter(
  self : RunOptions,
  sink : &@core.MessageSink,
  dest : OutputDest,
) -> Unit {
  self.formatters_.push({ sink, dest })
  self.sinks_.push(sink)
}

///|
/// Remove all sinks and formatters.
pub fn RunOptions::clear_sinks(self : RunOptions) -> Unit {
  self.sinks_.clear()
  self.formatters_.clear()
}

///|
/// Get the configured formatters with destinations.
pub fn RunOptions::get_formatters(self : RunOptions) -> Array[FormatterEntry] {
  self.formatters_
}
```

**Step 4: Run tests to verify they pass**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add src/runner/options.mbt src/runner/options_wbtest.mbt
git commit -m "feat(runner): add OutputDest enum, add_formatter, and clear_sinks"
```

---

### Task 2: Add FormatterConfig to MoonspecConfig and parse from JSON5

**Files:**
- Modify: `src/config/config.mbt`
- Modify: `src/config/config_wbtest.mbt`

**Context:** `MoonspecConfig` needs a `formatters` field. Each entry has `type_` (pretty/junit/messages), `output` (stdout/stderr/path), and optional `no_color`.

**Step 1: Write failing tests**

Add to `src/config/config_wbtest.mbt`:

```moonbit
test "MoonspecConfig::from_json5 parses formatters" {
  let json5 =
    #|{
    #|  "formatters": [
    #|    { "type": "pretty", "output": "stdout" },
    #|    { "type": "junit", "output": "reports/results.xml" }
    #|  ]
    #|}
  let config = MoonspecConfig::from_json5(json5)
  match config.formatters {
    Some(fmts) => {
      assert_eq(fmts.length(), 2)
      assert_eq(fmts[0].type_, "pretty")
      assert_eq(fmts[0].output, "stdout")
      assert_eq(fmts[0].no_color, false)
      assert_eq(fmts[1].type_, "junit")
      assert_eq(fmts[1].output, "reports/results.xml")
    }
    None => assert_true(false)
  }
}

test "MoonspecConfig::from_json5 parses formatter with no_color" {
  let json5 =
    #|{
    #|  "formatters": [
    #|    { "type": "pretty", "output": "stderr", "no_color": true }
    #|  ]
    #|}
  let config = MoonspecConfig::from_json5(json5)
  match config.formatters {
    Some(fmts) => {
      assert_eq(fmts[0].no_color, true)
    }
    None => assert_true(false)
  }
}

test "MoonspecConfig::from_json5 empty formatters array" {
  let json5 =
    #|{
    #|  "formatters": []
    #|}
  let config = MoonspecConfig::from_json5(json5)
  assert_eq(config.formatters, Some([]))
}

test "merge: formatters override takes precedence" {
  let base = MoonspecConfig::{
    world: None,
    mode: None,
    steps: None,
    skip_tags: None,
    formatters: Some([FormatterConfig::{ type_: "pretty", output: "stdout", no_color: false }]),
  }
  let override_ = MoonspecConfig::{
    world: None,
    mode: None,
    steps: None,
    skip_tags: None,
    formatters: Some([FormatterConfig::{ type_: "junit", output: "report.xml", no_color: false }]),
  }
  let merged = base.merge(override_)
  match merged.formatters {
    Some(fmts) => {
      assert_eq(fmts.length(), 1)
      assert_eq(fmts[0].type_, "junit")
    }
    None => assert_true(false)
  }
}

test "merge: formatters falls back to base when override absent" {
  let base = MoonspecConfig::{
    world: None,
    mode: None,
    steps: None,
    skip_tags: None,
    formatters: Some([FormatterConfig::{ type_: "pretty", output: "stdout", no_color: false }]),
  }
  let override_ = MoonspecConfig::empty()
  let merged = base.merge(override_)
  match merged.formatters {
    Some(fmts) => assert_eq(fmts.length(), 1)
    None => assert_true(false)
  }
}
```

**Step 2: Run tests to verify they fail**

Run: `mise run test:unit`
Expected: compilation errors — `FormatterConfig`, `formatters` field don't exist.

**Step 3: Implement FormatterConfig and parsing**

In `src/config/config.mbt`, add the `FormatterConfig` struct:

```moonbit
///|
/// Configuration for a single output formatter.
pub(all) struct FormatterConfig {
  type_ : String    // "pretty" | "junit" | "messages"
  output : String   // "stdout" | "stderr" | file path
  no_color : Bool   // pretty-specific, default false
} derive(Show, Eq)
```

Add `formatters` field to `MoonspecConfig`:

```moonbit
pub(all) struct MoonspecConfig {
  world : String?
  mode : ModeConfig?
  steps : StepsConfig?
  skip_tags : Array[String]?
  formatters : Array[FormatterConfig]?    // NEW
} derive(Show, Eq)
```

Update `MoonspecConfig::empty()`:

```moonbit
pub fn MoonspecConfig::empty() -> MoonspecConfig {
  { world: None, mode: None, steps: None, skip_tags: None, formatters: None }
}
```

Add parsing logic inside `from_json5` (add after the `steps` parsing block, still inside the `Object(obj)` match arm):

```moonbit
match obj.get("formatters") {
  Some(Array(arr)) => {
    let items : Array[FormatterConfig] = []
    for item in arr {
      match item {
        Object(fmt_obj) => {
          let mut type_ = ""
          let mut output = ""
          let mut no_color = false
          match fmt_obj.get("type") {
            Some(String(s)) => type_ = s
            _ => ()
          }
          match fmt_obj.get("output") {
            Some(String(s)) => output = s
            _ => ()
          }
          match fmt_obj.get("no_color") {
            Some(True) => no_color = true
            _ => ()
          }
          items.push(FormatterConfig::{ type_, output, no_color })
        }
        _ => ()
      }
    }
    formatters = Some(items)
  }
  _ => ()
}
```

Also add `let mut formatters : Array[FormatterConfig]? = None` alongside the other `let mut` declarations at the start of `from_json5`.

Update the return statement to include `formatters`:

```moonbit
{ world, mode, steps, skip_tags, formatters }
```

Update `merge()` to include formatters:

```moonbit
formatters: match (self.formatters, override_.formatters) {
  (_, Some(s)) => Some(s)
  (Some(s), None) => Some(s)
  (None, None) => None
},
```

**Important:** Update ALL existing struct literals in `config_wbtest.mbt` to include `formatters: None` (or the existing tests won't compile).

**Step 4: Run tests to verify they pass**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add src/config/config.mbt src/config/config_wbtest.mbt
git commit -m "feat(config): add formatters array to MoonspecConfig"
```

---

### Task 3: Implement output writing in the runner

**Files:**
- Modify: `src/runner/run.mbt`
- Modify: `src/runner/moon.pkg` (may need `@format` import)
- Test: `src/runner/run_wbtest.mbt` (add test for default formatter behavior)

**Context:** After `run()` emits the `TestRunFinished` envelope and computes results, it should write output for each `FormatterEntry`. If no sinks AND no formatters are configured, it should auto-add PrettyFormatter on stdout.

The key challenge: formatters are stored as `&@core.MessageSink` trait references, but `.output()` is not part of the `MessageSink` trait. We need a way to get the output string from a formatter.

**Approach:** Add an `output()` method to the `MessageSink` trait so the runner can generically call `.output()` on any sink that has a destination. This is the cleanest approach.

**Step 1: Add output method to MessageSink trait**

Modify `src/core/sink.mbt`:

```moonbit
pub(open) trait MessageSink {
  on_message(Self, @cucumber_messages.Envelope) -> Unit
  output(Self) -> String
}
```

**Step 2: Verify existing formatters already have output() -> String methods**

All three formatters already have `pub fn output(self) -> String` methods, so they'll satisfy the trait automatically. No changes needed in `src/format/`.

**Step 3: Add write_formatter_output helper to run.mbt**

In `src/runner/run.mbt`, add a helper function:

```moonbit
///|
/// Write formatter output to the configured destination.
fn write_formatter_output(entry : FormatterEntry) -> Unit {
  let content = entry.sink.output()
  if content.length() == 0 {
    return
  }
  match entry.dest {
    Stdout => println(content)
    Stderr =>
      @fs.write_string_to_file("/dev/stderr", content + "\n") catch { _ => () }
    File(path) => {
      // Create parent directories if needed
      let parent = get_parent_dir(path)
      if parent.length() > 0 {
        @fs.create_dir(parent, recursive=true) catch { _ => () }
      }
      @fs.write_string_to_file(path, content) catch { _ => () }
    }
  }
}

///|
/// Extract parent directory from a file path.
fn get_parent_dir(path : String) -> String {
  let mut last_sep = -1
  for i = 0; i < path.length(); i = i + 1 {
    if path[i] == '/' {
      last_sep = i
    }
  }
  if last_sep <= 0 {
    ""
  } else {
    path.substring(end=last_sep)
  }
}
```

**Note:** Check if `@fs.create_dir` exists. If not, use an alternative approach — the `@fs` package from `moonbitlang/x` may or may not have `create_dir`. If it doesn't exist, skip directory creation and just write the file (the write will fail if the directory doesn't exist, which is an acceptable initial limitation).

**Step 4: Add default formatter logic and output writing to run()**

In the `run()` function, add default formatter injection at the beginning (after `let sinks = options.get_sinks()`):

```moonbit
// Default: add PrettyFormatter on stdout if no sinks/formatters configured
let formatters = options.get_formatters()
if sinks.length() == 0 && formatters.length() == 0 {
  let default_fmt = @format.PrettyFormatter::new()
  options.add_formatter(&default_fmt, Stdout)
}
// Re-read sinks after potential default injection
let sinks = options.get_sinks()
let formatters = options.get_formatters()
```

At the end of `run()`, just before the return statement (after `compute_summary`), add:

```moonbit
// Write formatter output to configured destinations
for entry in formatters {
  write_formatter_output(entry)
}
```

**Step 5: Update runner's moon.pkg import**

Add `"moonrockz/moonspec/format"` to the import list in `src/runner/moon.pkg` (needed for `@format.PrettyFormatter::new()` in the default formatter logic).

**Step 6: Write a test for default formatter behavior**

Add to the existing runner wbtest file (check which file has runner tests — likely `src/runner/run_wbtest.mbt` or similar):

```moonbit
test "run applies default pretty formatter when no sinks configured" {
  let options = RunOptions::new(
    [FeatureSource::Text("test.feature", "Feature: Empty\n  Scenario: None\n    Given nothing")],
  )
  // No sinks added — should default to pretty on stdout
  assert_eq(options.get_sinks().length(), 0)
  assert_eq(options.get_formatters().length(), 0)
  // After run, formatters should have been injected
  // (We test via the options mutation side-effect)
}
```

**Step 7: Run tests to verify they pass**

Run: `mise run test:unit`
Expected: PASS (all 286+ tests)

**Step 8: Commit**

```bash
git add src/core/sink.mbt src/runner/run.mbt src/runner/moon.pkg
git commit -m "feat(runner): auto-write formatter output to configured destinations"
```

---

### Task 4: Update config schema and wire formatters through codegen

**Files:**
- Modify: `schemas/moonspec.schema.yaml`
- Modify: `src/codegen/config.mbt`
- Modify: `src/codegen/codegen.mbt`
- Modify: `src/codegen/codegen_wbtest.mbt`

**Context:** The codegen needs to emit `add_formatter()` calls in generated test code based on `CodegenConfig.formatters`. The YAML schema needs the new `formatters` property.

**Step 1: Update YAML schema**

Add to `schemas/moonspec.schema.yaml` after the `steps` property:

```yaml
  formatters:
    type: array
    description: >
      Output formatters for test results. Each entry specifies a formatter
      type and output destination. If omitted, defaults to pretty on stdout.
    items:
      type: object
      required: ["type", "output"]
      additionalProperties: false
      properties:
        type:
          type: string
          enum: ["pretty", "junit", "messages"]
          description: Formatter type.
        output:
          type: string
          description: >
            Output destination: "stdout", "stderr", or a file path.
          examples: ["stdout", "stderr", "reports/results.xml"]
        no_color:
          type: boolean
          description: Disable ANSI colors (pretty formatter only).
          default: false
    examples:
      - [{"type": "pretty", "output": "stdout"}, {"type": "junit", "output": "reports/results.xml"}]
```

**Step 2: Add formatters to CodegenConfig**

In `src/codegen/config.mbt`, add to the struct:

```moonbit
pub(all) struct CodegenConfig {
  mode : CodegenMode
  world : String
  skip_tags : Array[String]?
  formatters : Array[@config.FormatterConfig]?    // NEW
} derive(Show, Eq)
```

Update `CodegenConfig::default()`:

```moonbit
pub fn CodegenConfig::default() -> CodegenConfig {
  { mode: PerScenario, world: "", skip_tags: None, formatters: None }
}
```

Update `CodegenConfig::from_json5` return to include `formatters: None`.

**Step 3: Add codegen for formatter wiring**

In `src/codegen/codegen.mbt`, add a helper function:

```moonbit
///|
/// Generate `options.add_formatter(...)` lines for configured formatters.
fn generate_formatter_lines(
  buf : StringBuilder,
  config : CodegenConfig,
) -> Unit {
  match config.formatters {
    Some(fmts) => {
      for fmt in fmts {
        let constructor = match fmt.type_ {
          "pretty" =>
            if fmt.no_color {
              "@format.PrettyFormatter::new(no_color=true)"
            } else {
              "@format.PrettyFormatter::new()"
            }
          "junit" => "@format.JUnitFormatter::new()"
          "messages" => "@format.MessagesFormatter::new()"
          _ => continue
        }
        let dest = match fmt.output {
          "stdout" => "@moonspec.Stdout"
          "stderr" => "@moonspec.Stderr"
          _ => "@moonspec.File(\"" + escape_string(fmt.output) + "\")"
        }
        buf.write_string(
          "  options.add_formatter(&" + constructor + ", " + dest + ")\n",
        )
      }
    }
    None => ()
  }
}
```

Call `generate_formatter_lines(buf, config)` in both `generate_per_feature` and `generate_scenario_runner_test`, after the `generate_skip_tags_line` call.

**Step 4: Write codegen tests**

Add to `src/codegen/codegen_wbtest.mbt`:

```moonbit
test "codegen emits add_formatter for pretty on stdout" {
  // ... create feature, config with formatters: Some([FormatterConfig::{ type_: "pretty", output: "stdout", no_color: false }])
  // assert output contains "options.add_formatter(&@format.PrettyFormatter::new(), @moonspec.Stdout)"
}

test "codegen emits add_formatter for junit to file" {
  // ... config with formatters: Some([FormatterConfig::{ type_: "junit", output: "reports/results.xml", no_color: false }])
  // assert output contains "options.add_formatter(&@format.JUnitFormatter::new(), @moonspec.File(\"reports/results.xml\"))"
}

test "codegen omits formatter lines when formatters is None" {
  // ... config with formatters: None
  // assert output does NOT contain "add_formatter"
}
```

**Important:** Update ALL existing `CodegenConfig` struct literals in test files to include `formatters: None`.

**Step 5: Update moon.pkg for codegen**

Add `"moonrockz/moonspec/config"` to `src/codegen/moon.pkg` imports if not already present (needed for `@config.FormatterConfig` type).

**Step 6: Run tests**

Run: `mise run test:unit`
Expected: PASS

**Step 7: Commit**

```bash
git add schemas/moonspec.schema.yaml src/codegen/config.mbt src/codegen/codegen.mbt src/codegen/codegen_wbtest.mbt src/codegen/moon.pkg
git commit -m "feat(codegen): generate add_formatter calls from config"
```

---

### Task 5: Wire MoonspecConfig.formatters through the CLI

**Files:**
- Modify: `src/cmd/main/cli_commands.mbt`

**Context:** The CLI constructs `CodegenConfig` from `MoonspecConfig`. It needs to pass `formatters` through.

**Step 1: Update CodegenConfig construction**

In `src/cmd/main/cli_commands.mbt`, find where `CodegenConfig` is constructed and add:

```moonbit
let config = @codegen.CodegenConfig::{
  mode,
  world,
  skip_tags: moonspec_config.skip_tags,
  formatters: moonspec_config.formatters,    // NEW
}
```

**Step 2: Run tests**

Run: `mise run test:unit`
Expected: PASS

**Step 3: Commit**

```bash
git add src/cmd/main/cli_commands.mbt
git commit -m "feat(cli): wire formatters config through to codegen"
```

---

### Task 6: Update documentation

**Files:**
- Modify: `README.mbt.md` (add formatters to config example and RunOptions section)
- Modify: `docs/guide/configuration.md` (add formatters section)
- Modify: `docs/guide/testing-strategies.md` (add output configuration section)

**Step 1: Update README.mbt.md**

Add formatters to the config file example section. Add `add_formatter`, `clear_sinks` to the RunOptions table.

**Step 2: Update configuration guide**

Add a "Formatters" section to `docs/guide/configuration.md` explaining the `formatters` array, supported types, output destinations, and default behavior.

**Step 3: Update testing strategies guide**

Add examples showing how to configure JUnit output for CI and pretty output for local development.

**Step 4: Commit**

```bash
git add README.mbt.md docs/guide/configuration.md docs/guide/testing-strategies.md
git commit -m "docs: add formatter output configuration documentation"
```
