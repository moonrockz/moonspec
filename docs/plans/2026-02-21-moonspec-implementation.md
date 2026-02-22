# moonspec Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a BDD test framework for MoonBit that parses Gherkin features, matches steps via Cucumber Expressions, and executes scenarios with async parallel support.

**Architecture:** Multi-package library with layered dependencies: `core` (traits + registry) → `runner` (execution + results) → `format` (output) + `codegen` (test generation) + `cmd` (CLI). Uses `moonrockz/gherkin` for parsing, `moonrockz/cucumber-expressions` for step matching, `moonbitlang/async` for parallel execution.

**Tech Stack:** MoonBit 0.8+, moonbitlang/async, moonrockz/gherkin 0.3.0, moonrockz/cucumber-expressions 0.1.0, moonrockz/cucumber-messages 0.1.0, mise for tasks.

---

### Task 1: Project Scaffolding

**Files:**
- Create: `moon.mod.json`
- Create: `src/core/moon.pkg`
- Create: `src/runner/moon.pkg`
- Create: `src/format/moon.pkg`
- Create: `src/codegen/moon.pkg`
- Create: `src/cmd/main/moon.pkg`
- Create: `.gitignore`
- Create: `.mise.toml`
- Create: `mise-tasks/test/unit`
- Create: `CLAUDE.md`
- Modify: `AGENTS.md`

**Step 1: Create moon.mod.json**

```json
{
  "name": "moonrockz/moonspec",
  "version": "0.1.0",
  "deps": {
    "moonbitlang/x": "0.4.40",
    "moonbitlang/async": "0.16.6",
    "moonbitlang/regexp": "0.3.5",
    "moonrockz/gherkin": "0.3.0",
    "moonrockz/cucumber-expressions": "0.1.0",
    "moonrockz/cucumber-messages": "0.1.0"
  },
  "readme": "README.mbt.md",
  "repository": "https://github.com/moonrockz/moonspec",
  "license": "Apache-2.0",
  "keywords": ["bdd", "cucumber", "gherkin", "testing", "moonbit"],
  "description": "BDD test framework for MoonBit with Gherkin and Cucumber Expressions",
  "source": "src"
}
```

**Step 2: Create package configs**

`src/core/moon.pkg`:
```
import {
  "moonrockz/cucumber-expressions",
}
```

`src/runner/moon.pkg`:
```
import {
  "moonrockz/moonspec/core",
  "moonrockz/gherkin",
  "moonrockz/cucumber-expressions",
  "moonbitlang/async",
}
```

`src/format/moon.pkg`:
```
import {
  "moonrockz/moonspec/core",
  "moonrockz/moonspec/runner",
  "moonrockz/gherkin",
  "moonrockz/cucumber-messages",
}
```

`src/codegen/moon.pkg`:
```
import {
  "moonrockz/gherkin",
}
```

`src/cmd/main/moon.pkg`:
```
import {
  "moonrockz/moonspec/core",
  "moonrockz/moonspec/runner",
  "moonrockz/moonspec/format",
  "moonrockz/moonspec/codegen",
  "moonrockz/gherkin",
  "moonbitlang/async",
}

is-main = true
```

**Step 3: Create .gitignore**

```
target/
_build/
.mooncakes/
*.wasm
```

**Step 4: Create .mise.toml**

```toml
[tools]
```

**Step 5: Create mise-tasks/test/unit**

```bash
#!/usr/bin/env bash
#MISE description="Run MoonBit unit tests"
set -euo pipefail
moon test
```

Make it executable: `chmod +x mise-tasks/test/unit`

**Step 6: Create CLAUDE.md**

```markdown
# Claude Code Project Instructions

## Commit Messages

All commits MUST use **Conventional Commits** format:

```
type(scope): description
```

Types: `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `style`

## Build & Test

Use **`mise run`** for all operations:

```bash
mise run test:unit        # MoonBit unit tests
```

## Mise Tasks

Tasks are **file-based scripts** in `mise-tasks/`. Never add inline `[tasks]` to `.mise.toml`.
```

**Step 7: Create stub files so packages compile**

Each package needs at least one `.mbt` file or moon won't compile.

`src/core/lib.mbt`:
```moonbit
///|
/// moonspec core — World, Steps, and Hooks traits.
pub fn core_version() -> String {
  "0.1.0"
}
```

`src/runner/lib.mbt`:
```moonbit
///|
/// moonspec runner — Scenario execution and lifecycle.
pub fn runner_version() -> String {
  "0.1.0"
}
```

`src/format/lib.mbt`:
```moonbit
///|
/// moonspec format — Output formatters (pretty, messages, junit).
pub fn format_version() -> String {
  "0.1.0"
}
```

`src/codegen/lib.mbt`:
```moonbit
///|
/// moonspec codegen — Generate _test.mbt from .feature files.
pub fn codegen_version() -> String {
  "0.1.0"
}
```

`src/cmd/main/main.mbt`:
```moonbit
///|
fn main {
  println("moonspec 0.1.0")
}
```

**Step 8: Run moon update and verify**

```bash
moon update
moon check
moon test
```

Expected: Dependencies downloaded, all packages compile, no test failures.

**Step 9: Commit**

```bash
git add moon.mod.json src/ .gitignore .mise.toml mise-tasks/ CLAUDE.md AGENTS.md
git commit -m "chore: project scaffolding with multi-package structure"
```

---

### Task 2: Core Result Types

**Files:**
- Create: `src/runner/results.mbt`
- Create: `src/runner/results_wbtest.mbt`

These are needed before the core traits because `StepResult` and `ScenarioResult` flow through hooks and formatters.

**Step 1: Write the failing test**

`src/runner/results_wbtest.mbt`:
```moonbit
test "StepStatus::Passed shows correctly" {
  inspect!(StepStatus::Passed, content="Passed")
}

test "StepStatus::Failed shows with error" {
  let status = StepStatus::Failed("assertion failed")
  inspect!(status, content="Failed(\"assertion failed\")")
}

test "StepStatus::Skipped shows correctly" {
  inspect!(StepStatus::Skipped, content="Skipped")
}

test "StepStatus::Undefined shows correctly" {
  inspect!(StepStatus::Undefined, content="Undefined")
}

test "StepStatus::Pending shows correctly" {
  inspect!(StepStatus::Pending, content="Pending")
}

test "StepStatus is_passed returns true for Passed" {
  assert_true!(StepStatus::Passed.is_passed())
}

test "StepStatus is_passed returns false for Failed" {
  assert_true!(StepStatus::Failed("err").is_passed().not())
}

test "ScenarioStatus from empty steps is Passed" {
  let result = ScenarioStatus::from_steps([])
  assert_eq!(result, ScenarioStatus::Passed)
}

test "ScenarioStatus from all passed steps is Passed" {
  let result = ScenarioStatus::from_steps([StepStatus::Passed, StepStatus::Passed])
  assert_eq!(result, ScenarioStatus::Passed)
}

test "ScenarioStatus with one Failed is Failed" {
  let result = ScenarioStatus::from_steps([StepStatus::Passed, StepStatus::Failed("err")])
  assert_eq!(result, ScenarioStatus::Failed)
}

test "ScenarioStatus with Undefined is Undefined" {
  let result = ScenarioStatus::from_steps([StepStatus::Undefined])
  assert_eq!(result, ScenarioStatus::Undefined)
}
```

**Step 2: Run test to verify it fails**

```bash
mise run test:unit
```

Expected: FAIL — types not defined yet.

**Step 3: Write minimal implementation**

`src/runner/results.mbt`:
```moonbit
///|
/// Status of a single step execution.
pub(all) enum StepStatus {
  Passed
  Failed(String)
  Skipped
  Undefined
  Pending
} derive(Show, Eq)

///|
/// Check if a step passed.
pub fn StepStatus::is_passed(self : StepStatus) -> Bool {
  match self {
    Passed => true
    _ => false
  }
}

///|
/// Aggregate status of a scenario.
pub(all) enum ScenarioStatus {
  Passed
  Failed
  Skipped
  Undefined
  Pending
} derive(Show, Eq)

///|
/// Derive scenario status from step statuses.
pub fn ScenarioStatus::from_steps(steps : Array[StepStatus]) -> ScenarioStatus {
  let mut has_failed = false
  let mut has_undefined = false
  let mut has_pending = false
  let mut has_skipped = false
  for step in steps {
    match step {
      StepStatus::Failed(_) => has_failed = true
      StepStatus::Undefined => has_undefined = true
      StepStatus::Pending => has_pending = true
      StepStatus::Skipped => has_skipped = true
      StepStatus::Passed => ()
    }
  }
  if has_failed {
    ScenarioStatus::Failed
  } else if has_undefined {
    ScenarioStatus::Undefined
  } else if has_pending {
    ScenarioStatus::Pending
  } else if has_skipped {
    ScenarioStatus::Skipped
  } else {
    ScenarioStatus::Passed
  }
}

///|
/// Result of executing a single step.
pub(all) struct StepResult {
  text : String
  keyword : String
  status : StepStatus
  duration_ms : Int64
} derive(Show, Eq)

///|
/// Result of executing a scenario.
pub(all) struct ScenarioResult {
  feature_name : String
  scenario_name : String
  tags : Array[String]
  steps : Array[StepResult]
  status : ScenarioStatus
  duration_ms : Int64
} derive(Show, Eq)

///|
/// Result of executing a feature.
pub(all) struct FeatureResult {
  name : String
  scenarios : Array[ScenarioResult]
  duration_ms : Int64
} derive(Show, Eq)

///|
/// Summary of an entire run.
pub(all) struct RunSummary {
  total_scenarios : Int
  passed : Int
  failed : Int
  undefined : Int
  pending : Int
  skipped : Int
  duration_ms : Int64
} derive(Show, Eq)

///|
/// Complete result of a test run.
pub(all) struct RunResult {
  features : Array[FeatureResult]
  summary : RunSummary
} derive(Show, Eq)
```

**Step 4: Run test to verify it passes**

```bash
mise run test:unit
```

Expected: ALL PASS.

**Step 5: Commit**

```bash
git add src/runner/results.mbt src/runner/results_wbtest.mbt
git commit -m "feat(runner): add result types (StepStatus, ScenarioResult, RunResult)"
```

---

### Task 3: Core Types — StepArg and Info Structs

**Files:**
- Create: `src/core/types.mbt`
- Create: `src/core/types_wbtest.mbt`

**Step 1: Write the failing test**

`src/core/types_wbtest.mbt`:
```moonbit
test "StepArg::IntArg derives Show" {
  inspect!(StepArg::IntArg(42), content="IntArg(42)")
}

test "StepArg::StringArg derives Show" {
  inspect!(StepArg::StringArg("hello"), content="StringArg(\"hello\")")
}

test "StepArg from_param converts Int param" {
  let param = @cucumber_expressions.Param::{
    value: "42",
    type_: @cucumber_expressions.ParamType::Int,
  }
  let arg = StepArg::from_param(param)
  assert_eq!(arg, StepArg::IntArg(42))
}

test "StepArg from_param converts Float param" {
  let param = @cucumber_expressions.Param::{
    value: "3.14",
    type_: @cucumber_expressions.ParamType::Float,
  }
  let arg = StepArg::from_param(param)
  assert_eq!(arg, StepArg::FloatArg(3.14))
}

test "StepArg from_param converts String_ param" {
  let param = @cucumber_expressions.Param::{
    value: "hello",
    type_: @cucumber_expressions.ParamType::String_,
  }
  let arg = StepArg::from_param(param)
  assert_eq!(arg, StepArg::StringArg("hello"))
}

test "StepArg from_param converts Word param" {
  let param = @cucumber_expressions.Param::{
    value: "banana",
    type_: @cucumber_expressions.ParamType::Word,
  }
  let arg = StepArg::from_param(param)
  assert_eq!(arg, StepArg::WordArg("banana"))
}

test "StepArg from_param converts Custom param" {
  let param = @cucumber_expressions.Param::{
    value: "red",
    type_: @cucumber_expressions.ParamType::Custom("color"),
  }
  let arg = StepArg::from_param(param)
  assert_eq!(arg, StepArg::CustomArg("red"))
}
```

**Step 2: Run test to verify it fails**

```bash
mise run test:unit
```

**Step 3: Write minimal implementation**

`src/core/types.mbt`:
```moonbit
///|
/// A typed step argument extracted from step text via Cucumber Expressions.
pub(all) enum StepArg {
  IntArg(Int)
  FloatArg(Double)
  StringArg(String)
  WordArg(String)
  CustomArg(String)
} derive(Show, Eq)

///|
/// Convert a cucumber-expressions Param to a typed StepArg.
pub fn StepArg::from_param(
  param : @cucumber_expressions.Param,
) -> StepArg {
  match param.type_ {
    @cucumber_expressions.ParamType::Int => {
      let n = @strconv.parse_int!(param.value) catch { _ => 0 }
      IntArg(n)
    }
    @cucumber_expressions.ParamType::Float => {
      let f = @strconv.parse_double!(param.value) catch { _ => 0.0 }
      FloatArg(f)
    }
    @cucumber_expressions.ParamType::String_ => StringArg(param.value)
    @cucumber_expressions.ParamType::Word => WordArg(param.value)
    @cucumber_expressions.ParamType::Anonymous => StringArg(param.value)
    @cucumber_expressions.ParamType::Custom(_) => CustomArg(param.value)
  }
}

///|
/// Information about a scenario being executed.
pub(all) struct ScenarioInfo {
  feature_name : String
  scenario_name : String
  tags : Array[String]
} derive(Show, Eq)

///|
/// Information about a step being executed.
pub(all) struct StepInfo {
  keyword : String
  text : String
} derive(Show, Eq)
```

**Note:** The import of `@cucumber_expressions` may need the package alias to match
how MoonBit resolves hyphenated package names. Check `moon check` output. If the
alias is different (e.g. `@cucumber-expressions`), update accordingly.

**Step 4: Run test to verify it passes**

```bash
mise run test:unit
```

**Step 5: Commit**

```bash
git add src/core/types.mbt src/core/types_wbtest.mbt
git commit -m "feat(core): add StepArg, ScenarioInfo, StepInfo types"
```

---

### Task 4: Core — Step Registry

**Files:**
- Create: `src/core/registry.mbt`
- Create: `src/core/registry_wbtest.mbt`

The step registry holds compiled Cucumber Expressions paired with handler
functions. When the runner encounters a step, it iterates the registry to find
a match.

**Step 1: Write the failing test**

`src/core/registry_wbtest.mbt`:
```moonbit
test "StepRegistry starts empty" {
  let reg = StepRegistry::new()
  assert_eq!(reg.len(), 0)
}

test "StepRegistry registers a Given step" {
  let reg = StepRegistry::new()
  reg.given("I have {int} cucumbers", fn(_args) {  })
  assert_eq!(reg.len(), 1)
}

test "StepRegistry matches step text" {
  let reg = StepRegistry::new()
  reg.given("I have {int} cucumbers", fn(_args) {  })
  let result = reg.find_match("I have 42 cucumbers")
  assert_true!(result.is_some())
}

test "StepRegistry returns None for no match" {
  let reg = StepRegistry::new()
  reg.given("I have {int} cucumbers", fn(_args) {  })
  let result = reg.find_match("I have many cucumbers")
  assert_true!(result.is_none())
}

test "StepRegistry extracts parameters" {
  let reg = StepRegistry::new()
  reg.given("I have {int} cucumbers", fn(_args) {  })
  let (_, args, _) = reg.find_match("I have 42 cucumbers").unwrap()
  assert_eq!(args[0], StepArg::IntArg(42))
}

test "StepRegistry when and then register correctly" {
  let reg = StepRegistry::new()
  reg.when("I eat {int}", fn(_args) {  })
  reg.then("I should have {int}", fn(_args) {  })
  assert_eq!(reg.len(), 2)
}

test "StepRegistry step registers with any keyword" {
  let reg = StepRegistry::new()
  reg.step("something happens", fn(_args) {  })
  assert_eq!(reg.len(), 1)
  assert_true!(reg.find_match("something happens").is_some())
}
```

**Step 2: Run test to verify it fails**

```bash
mise run test:unit
```

**Step 3: Write minimal implementation**

`src/core/registry.mbt`:
```moonbit
///|
/// A step handler function that receives extracted arguments.
pub type StepHandler (Array[StepArg]) -> Unit!Error

///|
/// A registered step definition: compiled expression + handler.
struct StepEntry {
  expression : @cucumber_expressions.Expression
  handler : StepHandler
}

///|
/// Registry of step definitions keyed by Cucumber Expression patterns.
pub(all) struct StepRegistry {
  priv entries : Array[StepEntry]
  priv param_registry : @cucumber_expressions.ParamTypeRegistry
}

///|
/// Create an empty step registry with default parameter types.
pub fn StepRegistry::new() -> StepRegistry {
  {
    entries: [],
    param_registry: @cucumber_expressions.ParamTypeRegistry::default(),
  }
}

///|
/// Number of registered step definitions.
pub fn StepRegistry::len(self : StepRegistry) -> Int {
  self.entries.length()
}

///|
/// Register a step definition with a Cucumber Expression pattern.
fn StepRegistry::register(
  self : StepRegistry,
  pattern : String,
  handler : StepHandler,
) -> Unit {
  let expr = @cucumber_expressions.Expression::parse_with_registry(
    pattern,
    self.param_registry,
  ) catch {
    _ => return // silently skip invalid patterns — revisit error handling later
  }
  self.entries.push({ expression: expr, handler })
}

///|
/// Register a Given step.
pub fn StepRegistry::given(
  self : StepRegistry,
  pattern : String,
  handler : (Array[StepArg]) -> Unit!Error,
) -> Unit {
  self.register(pattern, StepHandler(handler))
}

///|
/// Register a When step.
pub fn StepRegistry::when(
  self : StepRegistry,
  pattern : String,
  handler : (Array[StepArg]) -> Unit!Error,
) -> Unit {
  self.register(pattern, StepHandler(handler))
}

///|
/// Register a Then step.
pub fn StepRegistry::then(
  self : StepRegistry,
  pattern : String,
  handler : (Array[StepArg]) -> Unit!Error,
) -> Unit {
  self.register(pattern, StepHandler(handler))
}

///|
/// Register a step that matches any keyword.
pub fn StepRegistry::step(
  self : StepRegistry,
  pattern : String,
  handler : (Array[StepArg]) -> Unit!Error,
) -> Unit {
  self.register(pattern, StepHandler(handler))
}

///|
/// Find a matching step definition for the given step text.
/// Returns (handler, extracted_args, expression_source) or None.
pub fn StepRegistry::find_match(
  self : StepRegistry,
  text : String,
) -> (StepHandler, Array[StepArg], String)? {
  for entry in self.entries {
    match entry.expression.match_(text) {
      Some(m) => {
        let args = m.params.map(StepArg::from_param)
        return Some((entry.handler, args, entry.expression.source()))
      }
      None => continue
    }
  }
  None
}
```

**Step 4: Run test to verify it passes**

```bash
mise run test:unit
```

**Step 5: Commit**

```bash
git add src/core/registry.mbt src/core/registry_wbtest.mbt
git commit -m "feat(core): add StepRegistry with cucumber expression matching"
```

---

### Task 5: Core — Formatter Trait

**Files:**
- Create: `src/format/formatter.mbt`

The formatter trait defines the event interface. No tests needed yet — it's just
a trait definition. We'll test it when we implement concrete formatters.

**Step 1: Write the trait definition**

`src/format/formatter.mbt`:
```moonbit
///|
/// Information about a test run starting.
pub(all) struct RunInfo {
  feature_count : Int
  scenario_count : Int
} derive(Show, Eq)

///|
/// Event-driven formatter trait. The runner notifies formatters as events happen.
/// All methods have default no-op implementations.
pub(open) trait Formatter {
  on_run_start(Self, RunInfo) -> Unit = _
  on_feature_start(Self, String) -> Unit = _
  on_scenario_start(Self, @runner.ScenarioResult) -> Unit = _
  on_step_finish(Self, @runner.StepResult) -> Unit = _
  on_scenario_finish(Self, @runner.ScenarioResult) -> Unit = _
  on_feature_finish(Self, @runner.FeatureResult) -> Unit = _
  on_run_finish(Self, @runner.RunResult) -> Unit = _
}
```

**Step 2: Verify it compiles**

```bash
moon check
```

**Step 3: Commit**

```bash
git add src/format/formatter.mbt
git commit -m "feat(format): add Formatter trait with event-driven interface"
```

---

### Task 6: Runner — Sequential Scenario Executor

**Files:**
- Create: `src/runner/executor.mbt`
- Create: `src/runner/executor_wbtest.mbt`

This is the heart of moonspec — it takes a parsed `GherkinDocument`, a
`StepRegistry`, and executes each scenario step-by-step.

**Step 1: Write the failing test**

`src/runner/executor_wbtest.mbt`:
```moonbit
test "execute_scenario with all steps passing" {
  let registry = @core.StepRegistry::new()
  let mut count = 0
  registry.given("a passing step", fn(_args) { count = count + 1 })
  registry.when("another passing step", fn(_args) { count = count + 1 })
  registry.then("all is well", fn(_args) { count = count + 1 })
  let steps = [
    make_step("Given ", "a passing step"),
    make_step("When ", "another passing step"),
    make_step("Then ", "all is well"),
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test Feature",
    scenario_name="All pass",
    tags=[],
    steps~,
  )
  assert_eq!(result.status, ScenarioStatus::Passed)
  assert_eq!(result.steps.length(), 3)
  assert_eq!(count, 3)
}

test "execute_scenario skips remaining steps after failure" {
  let registry = @core.StepRegistry::new()
  registry.given("a passing step", fn(_args) {  })
  registry.when("a failing step", fn(_args) { raise Error("boom") })
  registry.then("this should be skipped", fn(_args) {  })
  let steps = [
    make_step("Given ", "a passing step"),
    make_step("When ", "a failing step"),
    make_step("Then ", "this should be skipped"),
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test Feature",
    scenario_name="Failure test",
    tags=[],
    steps~,
  )
  assert_eq!(result.status, ScenarioStatus::Failed)
  assert_true!(result.steps[0].status.is_passed())
  assert_eq!(result.steps[2].status, StepStatus::Skipped)
}

test "execute_scenario marks undefined steps" {
  let registry = @core.StepRegistry::new()
  let steps = [make_step("Given ", "an undefined step")]
  let result = execute_scenario(
    registry,
    feature_name="Test Feature",
    scenario_name="Undefined test",
    tags=[],
    steps~,
  )
  assert_eq!(result.status, ScenarioStatus::Undefined)
  assert_eq!(result.steps[0].status, StepStatus::Undefined)
}

/// Helper to create a minimal step-like tuple for testing.
fn make_step(keyword : String, text : String) -> (String, String) {
  (keyword, text)
}
```

**Step 2: Run test to verify it fails**

```bash
mise run test:unit
```

**Step 3: Write minimal implementation**

`src/runner/executor.mbt`:
```moonbit
///|
/// Execute a single scenario against a step registry.
/// Steps are provided as (keyword, text) pairs.
pub fn execute_scenario(
  registry : @core.StepRegistry,
  feature_name~ : String,
  scenario_name~ : String,
  tags~ : Array[String],
  steps~ : Array[(String, String)],
) -> ScenarioResult {
  let step_results : Array[StepResult] = []
  let mut failed = false
  let start = now_ms()
  for pair in steps {
    let (keyword, text) = pair
    if failed {
      step_results.push({
        text,
        keyword,
        status: StepStatus::Skipped,
        duration_ms: 0L,
      })
      continue
    }
    let step_start = now_ms()
    let status = match registry.find_match(text) {
      None => StepStatus::Undefined
      Some((handler, args, _)) => {
        try {
          (handler._)(args)
          StepStatus::Passed
        } catch {
          e => StepStatus::Failed(e.to_string())
        }
      }
    }
    let step_duration = now_ms() - step_start
    match status {
      StepStatus::Failed(_) | StepStatus::Undefined => failed = true
      _ => ()
    }
    step_results.push({ text, keyword, status, duration_ms: step_duration })
  }
  let total_duration = now_ms() - start
  let statuses = step_results.map(fn(r) { r.status })
  {
    feature_name,
    scenario_name,
    tags,
    steps: step_results,
    status: ScenarioStatus::from_steps(statuses),
    duration_ms: total_duration,
  }
}

///|
/// Get current time in milliseconds. Uses @async.now() when available,
/// falls back to 0 for test environments.
fn now_ms() -> Int64 {
  0L // placeholder — will integrate with @async.now() in Task 9
}
```

**Step 4: Run test to verify it passes**

```bash
mise run test:unit
```

**Step 5: Commit**

```bash
git add src/runner/executor.mbt src/runner/executor_wbtest.mbt
git commit -m "feat(runner): add sequential scenario executor with step matching"
```

---

### Task 7: Runner — Feature Executor (Gherkin Integration)

**Files:**
- Create: `src/runner/feature.mbt`
- Create: `src/runner/feature_wbtest.mbt`
- Create: `tests/fixtures/simple.feature`

This task connects the Gherkin parser to the scenario executor. Given a
`.feature` file's content, parse it and execute all scenarios.

**Step 1: Create a test fixture**

`tests/fixtures/simple.feature`:
```gherkin
Feature: Simple math

  Scenario: Addition
    Given I have 5 cucumbers
    When I eat 3 cucumbers
    Then I should have 2 cucumbers

  Scenario: No eating
    Given I have 10 cucumbers
    Then I should have 10 cucumbers
```

**Step 2: Write the failing test**

`src/runner/feature_wbtest.mbt`:
```moonbit
test "execute_feature parses and runs all scenarios" {
  let registry = @core.StepRegistry::new()
  let mut total = 0
  registry.given("I have {int} cucumbers", fn(args) {
    match args[0] {
      @core.StepArg::IntArg(n) => total = n
      _ => ()
    }
  })
  registry.when("I eat {int} cucumbers", fn(args) {
    match args[0] {
      @core.StepArg::IntArg(n) => total = total - n
      _ => ()
    }
  })
  registry.then("I should have {int} cucumbers", fn(args) {
    match args[0] {
      @core.StepArg::IntArg(n) => assert_eq!(total, n)
      _ => ()
    }
  })
  let source = "@gherkin.Source::from_string(
    \"Feature: Simple math\\n\" +
    \"\\n\" +
    \"  Scenario: Addition\\n\" +
    \"    Given I have 5 cucumbers\\n\" +
    \"    When I eat 3 cucumbers\\n\" +
    \"    Then I should have 2 cucumbers\\n\" +
    \"\\n\" +
    \"  Scenario: No eating\\n\" +
    \"    Given I have 10 cucumbers\\n\" +
    \"    Then I should have 10 cucumbers\\n\"
  )"
  // Parse and execute using the actual gherkin parser
  let feature_content =
    "Feature: Simple math\n\n  Scenario: Addition\n    Given I have 5 cucumbers\n    When I eat 3 cucumbers\n    Then I should have 2 cucumbers\n\n  Scenario: No eating\n    Given I have 10 cucumbers\n    Then I should have 10 cucumbers\n"
  let result = execute_feature!(registry, feature_content)
  assert_eq!(result.name, "Simple math")
  assert_eq!(result.scenarios.length(), 2)
  assert_eq!(result.scenarios[0].status, ScenarioStatus::Passed)
  assert_eq!(result.scenarios[1].status, ScenarioStatus::Passed)
}

test "execute_feature handles undefined steps" {
  let registry = @core.StepRegistry::new()
  let feature_content =
    "Feature: Unknown\n\n  Scenario: Missing step\n    Given something undefined\n"
  let result = execute_feature!(registry, feature_content)
  assert_eq!(result.scenarios[0].status, ScenarioStatus::Undefined)
}
```

**Step 3: Write minimal implementation**

`src/runner/feature.mbt`:
```moonbit
///|
/// Execute all scenarios in a feature, given its content as a string.
pub fn execute_feature(
  registry : @core.StepRegistry,
  content : String,
) -> FeatureResult!Error {
  let source = @gherkin.Source::from_string(content)
  let doc = @gherkin.parse!(source)
  let feature = match doc.feature {
    Some(f) => f
    None =>
      return {
        name: "(empty)",
        scenarios: [],
        duration_ms: 0L,
      }
  }
  let scenario_results : Array[ScenarioResult] = []
  let start = now_ms()
  for child in feature.children {
    match child {
      @gherkin.FeatureChild::Scenario(scenario) => {
        let steps = scenario.steps.map(fn(s) { (s.keyword, s.text) })
        let tags = scenario.tags.map(fn(t) { t.name })
        let result = execute_scenario(
          registry,
          feature_name=feature.name,
          scenario_name=scenario.name,
          tags~,
          steps~,
        )
        scenario_results.push(result)
      }
      _ => () // Background, Rule handled later
    }
  }
  let total_duration = now_ms() - start
  { name: feature.name, scenarios: scenario_results, duration_ms: total_duration }
}
```

**Step 4: Run test to verify it passes**

```bash
mise run test:unit
```

**Step 5: Commit**

```bash
git add src/runner/feature.mbt src/runner/feature_wbtest.mbt tests/
git commit -m "feat(runner): add feature executor with gherkin integration"
```

---

### Task 8: Runner — Background Steps Support

**Files:**
- Modify: `src/runner/feature.mbt`
- Create: `src/runner/background_wbtest.mbt`

Gherkin Background steps are prepended to every scenario in the feature.

**Step 1: Write the failing test**

`src/runner/background_wbtest.mbt`:
```moonbit
test "execute_feature prepends background steps to each scenario" {
  let registry = @core.StepRegistry::new()
  let mut context = ""
  registry.given("a common setup", fn(_args) { context = "setup" })
  registry.when("I do something", fn(_args) {  })
  registry.then("it works", fn(_args) { assert_eq!(context, "setup") })
  let content =
    "Feature: With Background\n\n  Background:\n    Given a common setup\n\n  Scenario: First\n    When I do something\n    Then it works\n\n  Scenario: Second\n    When I do something\n    Then it works\n"
  let result = execute_feature!(registry, content)
  assert_eq!(result.scenarios.length(), 2)
  // Each scenario should have 3 steps (1 background + 2 scenario)
  assert_eq!(result.scenarios[0].steps.length(), 3)
  assert_eq!(result.scenarios[1].steps.length(), 3)
  assert_eq!(result.scenarios[0].status, ScenarioStatus::Passed)
}
```

**Step 2: Run test to verify it fails**

```bash
mise run test:unit
```

Expected: Background steps are not included — scenarios only have 2 steps.

**Step 3: Update feature.mbt to collect background steps**

Modify `execute_feature` in `src/runner/feature.mbt` to:
1. First pass: collect background steps from `FeatureChild::Background`
2. Second pass: prepend background steps to each scenario's steps

```moonbit
// In execute_feature, before the scenario loop:
let background_steps : Array[(String, String)] = []
for child in feature.children {
  match child {
    @gherkin.FeatureChild::Background(bg) =>
      for s in bg.steps {
        background_steps.push((s.keyword, s.text))
      }
    _ => ()
  }
}

// In the Scenario match arm, prepend background steps:
let all_steps = background_steps.copy()
for s in scenario.steps {
  all_steps.push((s.keyword, s.text))
}
let result = execute_scenario(
  registry,
  feature_name=feature.name,
  scenario_name=scenario.name,
  tags~,
  steps=all_steps,
)
```

**Step 4: Run test to verify it passes**

```bash
mise run test:unit
```

**Step 5: Commit**

```bash
git add src/runner/feature.mbt src/runner/background_wbtest.mbt
git commit -m "feat(runner): prepend background steps to each scenario"
```

---

### Task 9: Runner — Scenario Outline Expansion

**Files:**
- Create: `src/runner/outline.mbt`
- Create: `src/runner/outline_wbtest.mbt`

Scenario Outlines with Examples tables expand into concrete scenarios.
Each row produces one scenario, with `<placeholder>` values replaced.

**Step 1: Write the failing test**

`src/runner/outline_wbtest.mbt`:
```moonbit
test "expand_outline produces one scenario per examples row" {
  let template_steps = [
    ("Given ", "I have <start> cucumbers"),
    ("When ", "I eat <eat> cucumbers"),
    ("Then ", "I should have <left> cucumbers"),
  ]
  let headers = ["start", "eat", "left"]
  let rows = [
    ["12", "5", "7"],
    ["20", "5", "15"],
  ]
  let expanded = expand_outline("eating", template_steps, headers, rows)
  assert_eq!(expanded.length(), 2)
  assert_eq!(expanded[0].0, "eating (start=12, eat=5, left=7)")
  assert_eq!(expanded[0].1[0].1, "I have 12 cucumbers")
  assert_eq!(expanded[1].0, "eating (start=20, eat=5, left=15)")
}

test "expand_outline with single row" {
  let template_steps = [("Given ", "I have <n> items")]
  let headers = ["n"]
  let rows = [["42"]]
  let expanded = expand_outline("single", template_steps, headers, rows)
  assert_eq!(expanded.length(), 1)
  assert_eq!(expanded[0].1[0].1, "I have 42 items")
}
```

**Step 2: Run test to verify it fails**

**Step 3: Write minimal implementation**

`src/runner/outline.mbt`:
```moonbit
///|
/// Expand a Scenario Outline into concrete scenarios.
/// Returns array of (scenario_name, steps) pairs.
pub fn expand_outline(
  name : String,
  template_steps : Array[(String, String)],
  headers : Array[String],
  rows : Array[Array[String]],
) -> Array[(String, Array[(String, String)])] {
  let results : Array[(String, Array[(String, String)])] = []
  for row in rows {
    // Build parameter suffix for scenario name
    let params : Array[String] = []
    for i, header in headers {
      params.push(header + "=" + row[i])
    }
    let scenario_name = name + " (" + params.join(", ") + ")"
    // Substitute <placeholder> in each step text
    let steps : Array[(String, String)] = []
    for pair in template_steps {
      let (keyword, text) = pair
      let mut expanded_text = text
      for i, header in headers {
        expanded_text = expanded_text.replace("<" + header + ">", row[i])
      }
      steps.push((keyword, expanded_text))
    }
    results.push((scenario_name, steps))
  }
  results
}
```

**Step 4: Run test to verify it passes**

**Step 5: Integrate outline expansion into feature.mbt**

In `execute_feature`, handle `scenario.examples` when non-empty:

```moonbit
// Inside the Scenario match arm:
if scenario.examples.is_empty() {
  // ... existing code for regular scenarios
} else {
  // Scenario Outline — expand and execute each
  for examples in scenario.examples {
    match examples.table_header {
      Some(header_row) => {
        let headers = header_row.cells.map(fn(c) { c.value })
        let rows = examples.table_body.map(fn(r) { r.cells.map(fn(c) { c.value }) })
        let template_steps = scenario.steps.map(fn(s) { (s.keyword, s.text) })
        let expanded = expand_outline(scenario.name, template_steps, headers, rows)
        for pair in expanded {
          let (expanded_name, expanded_steps) = pair
          let all_steps = background_steps.copy()
          for s in expanded_steps {
            all_steps.push(s)
          }
          let result = execute_scenario(
            registry,
            feature_name=feature.name,
            scenario_name=expanded_name,
            tags~,
            steps=all_steps,
          )
          scenario_results.push(result)
        }
      }
      None => ()
    }
  }
}
```

**Step 6: Run all tests**

```bash
mise run test:unit
```

**Step 7: Commit**

```bash
git add src/runner/outline.mbt src/runner/outline_wbtest.mbt src/runner/feature.mbt
git commit -m "feat(runner): add Scenario Outline expansion with Examples tables"
```

---

### Task 10: Runner — Tag Expression Parser

**Files:**
- Create: `src/runner/tags.mbt`
- Create: `src/runner/tags_wbtest.mbt`

Boolean tag expressions: `@smoke`, `not @slow`, `@smoke and not @slow`,
`@fast or @critical`, with parentheses for grouping.

**Step 1: Write the failing test**

`src/runner/tags_wbtest.mbt`:
```moonbit
test "TagExpression matches single tag" {
  let expr = TagExpression::parse!("@smoke")
  assert_true!(expr.matches(["@smoke"]))
  assert_true!(expr.matches(["@smoke", "@fast"]))
  assert_true!(expr.matches(["@slow"]).not())
}

test "TagExpression not operator" {
  let expr = TagExpression::parse!("not @slow")
  assert_true!(expr.matches(["@fast"]))
  assert_true!(expr.matches(["@slow"]).not())
  assert_true!(expr.matches([]))
}

test "TagExpression and operator" {
  let expr = TagExpression::parse!("@smoke and @fast")
  assert_true!(expr.matches(["@smoke", "@fast"]))
  assert_true!(expr.matches(["@smoke"]).not())
}

test "TagExpression or operator" {
  let expr = TagExpression::parse!("@smoke or @fast")
  assert_true!(expr.matches(["@smoke"]))
  assert_true!(expr.matches(["@fast"]))
  assert_true!(expr.matches(["@slow"]).not())
}

test "TagExpression complex expression" {
  let expr = TagExpression::parse!("@smoke and not @slow")
  assert_true!(expr.matches(["@smoke", "@fast"]))
  assert_true!(expr.matches(["@smoke", "@slow"]).not())
}

test "TagExpression empty matches everything" {
  let expr = TagExpression::parse!("")
  assert_true!(expr.matches(["@anything"]))
  assert_true!(expr.matches([]))
}
```

**Step 2: Run test to verify it fails**

**Step 3: Write minimal implementation**

`src/runner/tags.mbt`:
```moonbit
///|
/// A parsed boolean tag expression.
pub(all) enum TagExpression {
  TagLiteral(String)
  Not(TagExpression)
  And(TagExpression, TagExpression)
  Or(TagExpression, TagExpression)
  Always
} derive(Show, Eq)

///|
/// Parse a tag expression string.
/// Supports: @tag, not @tag, @a and @b, @a or @b, parentheses.
pub fn TagExpression::parse(input : String) -> TagExpression!Error {
  let trimmed = input.trim()
  if trimmed.is_empty() {
    return Always
  }
  let tokens = tokenize_tags(trimmed)
  parse_or(tokens, 0).0
}

///|
/// Evaluate whether this expression matches the given set of tags.
pub fn TagExpression::matches(
  self : TagExpression,
  tags : Array[String],
) -> Bool {
  match self {
    Always => true
    TagLiteral(name) => tags.contains(name)
    Not(inner) => inner.matches(tags).not()
    And(left, right) => left.matches(tags) && right.matches(tags)
    Or(left, right) => left.matches(tags) || right.matches(tags)
  }
}

// --- Tokenizer ---

fn tokenize_tags(input : String) -> Array[String] {
  let tokens : Array[String] = []
  let chars = input.to_array()
  let len = chars.length()
  let mut i = 0
  while i < len {
    let c = chars[i]
    if c == ' ' {
      i = i + 1
      continue
    }
    if c == '(' {
      tokens.push("(")
      i = i + 1
    } else if c == ')' {
      tokens.push(")")
      i = i + 1
    } else {
      // Read a word
      let start = i
      while i < len && chars[i] != ' ' && chars[i] != '(' && chars[i] != ')' {
        i = i + 1
      }
      let word = String::from_array(chars[start:i].to_array())
      tokens.push(word)
    }
  }
  tokens
}

// --- Recursive Descent Parser ---
// Precedence: or < and < not < atom

fn parse_or(
  tokens : Array[String],
  pos : Int,
) -> (TagExpression, Int)!Error {
  let (mut left, mut p) = parse_and!(tokens, pos)
  while p < tokens.length() && tokens[p] == "or" {
    let (right, next_p) = parse_and!(tokens, p + 1)
    left = Or(left, right)
    p = next_p
  }
  (left, p)
}

fn parse_and(
  tokens : Array[String],
  pos : Int,
) -> (TagExpression, Int)!Error {
  let (mut left, mut p) = parse_not!(tokens, pos)
  while p < tokens.length() && tokens[p] == "and" {
    let (right, next_p) = parse_not!(tokens, p + 1)
    left = And(left, right)
    p = next_p
  }
  (left, p)
}

fn parse_not(
  tokens : Array[String],
  pos : Int,
) -> (TagExpression, Int)!Error {
  if pos < tokens.length() && tokens[pos] == "not" {
    let (inner, p) = parse_atom!(tokens, pos + 1)
    (Not(inner), p)
  } else {
    parse_atom!(tokens, pos)
  }
}

fn parse_atom(
  tokens : Array[String],
  pos : Int,
) -> (TagExpression, Int)!Error {
  guard pos < tokens.length() else {
    raise Error("unexpected end of tag expression")
  }
  let token = tokens[pos]
  if token == "(" {
    let (inner, p) = parse_or!(tokens, pos + 1)
    guard p < tokens.length() && tokens[p] == ")" else {
      raise Error("missing closing parenthesis in tag expression")
    }
    (inner, p + 1)
  } else if token.has_prefix("@") {
    (TagLiteral(token), pos + 1)
  } else {
    raise Error("unexpected token in tag expression: " + token)
  }
}
```

**Step 4: Run test to verify it passes**

```bash
mise run test:unit
```

**Step 5: Commit**

```bash
git add src/runner/tags.mbt src/runner/tags_wbtest.mbt
git commit -m "feat(runner): add tag expression parser with boolean operators"
```

---

### Task 11: Runner — Tag Filtering in Feature Executor

**Files:**
- Modify: `src/runner/feature.mbt`
- Create: `src/runner/filter_wbtest.mbt`

Add an optional `tags` parameter to `execute_feature` that filters scenarios.

**Step 1: Write the failing test**

`src/runner/filter_wbtest.mbt`:
```moonbit
test "execute_feature_filtered skips non-matching scenarios" {
  let registry = @core.StepRegistry::new()
  registry.given("a step", fn(_args) {  })
  let content =
    "Feature: Tagged\n\n  @smoke\n  Scenario: Tagged\n    Given a step\n\n  Scenario: Untagged\n    Given a step\n"
  let result = execute_feature_filtered!(registry, content, tag_expr="@smoke")
  assert_eq!(result.scenarios.length(), 1)
  assert_eq!(result.scenarios[0].scenario_name, "Tagged")
}

test "execute_feature_filtered with no tag filter runs all" {
  let registry = @core.StepRegistry::new()
  registry.given("a step", fn(_args) {  })
  let content =
    "Feature: All\n\n  Scenario: One\n    Given a step\n\n  Scenario: Two\n    Given a step\n"
  let result = execute_feature_filtered!(registry, content, tag_expr="")
  assert_eq!(result.scenarios.length(), 2)
}
```

**Step 2: Run test to verify it fails**

**Step 3: Write implementation**

Add to `src/runner/feature.mbt`:
```moonbit
///|
/// Execute a feature with optional tag filtering.
pub fn execute_feature_filtered(
  registry : @core.StepRegistry,
  content : String,
  tag_expr~ : String,
) -> FeatureResult!Error {
  let tag_filter = TagExpression::parse!(tag_expr)
  // ... same parsing as execute_feature, but add tag filter before executing:
  // if tag_filter.matches(tags).not() { continue }
}
```

Refactor `execute_feature` to delegate to `execute_feature_filtered` with
`tag_expr=""`.

**Step 4: Run test to verify it passes**

**Step 5: Commit**

```bash
git add src/runner/feature.mbt src/runner/filter_wbtest.mbt
git commit -m "feat(runner): add tag-based scenario filtering"
```

---

### Task 12: Runner — Run Orchestrator and RunResult

**Files:**
- Create: `src/runner/run.mbt`
- Create: `src/runner/run_wbtest.mbt`

The top-level `run` function ties everything together: takes a registry, feature
content(s), config, and returns a `RunResult` with summary.

**Step 1: Write the failing test**

`src/runner/run_wbtest.mbt`:
```moonbit
test "run single feature and collect summary" {
  let registry = @core.StepRegistry::new()
  registry.given("a step", fn(_args) {  })
  let features = [
    "Feature: One\n\n  Scenario: Pass\n    Given a step\n",
  ]
  let result = run!(registry, features)
  assert_eq!(result.summary.total_scenarios, 1)
  assert_eq!(result.summary.passed, 1)
  assert_eq!(result.summary.failed, 0)
}

test "run multiple features" {
  let registry = @core.StepRegistry::new()
  registry.given("pass", fn(_args) {  })
  registry.given("fail", fn(_args) { raise Error("fail") })
  let features = [
    "Feature: A\n\n  Scenario: Pass\n    Given pass\n",
    "Feature: B\n\n  Scenario: Fail\n    Given fail\n",
  ]
  let result = run!(registry, features)
  assert_eq!(result.summary.total_scenarios, 2)
  assert_eq!(result.summary.passed, 1)
  assert_eq!(result.summary.failed, 1)
  assert_eq!(result.features.length(), 2)
}
```

**Step 2: Run test to verify it fails**

**Step 3: Write implementation**

`src/runner/run.mbt`:
```moonbit
///|
/// Run all features and collect results.
pub fn run(
  registry : @core.StepRegistry,
  features : Array[String],
  tag_expr~ : String = "",
) -> RunResult!Error {
  let feature_results : Array[FeatureResult] = []
  let start = now_ms()
  for content in features {
    let result = execute_feature_filtered!(registry, content, tag_expr~)
    feature_results.push(result)
  }
  let total_duration = now_ms() - start
  let summary = compute_summary(feature_results, total_duration)
  { features: feature_results, summary }
}

///|
fn compute_summary(
  features : Array[FeatureResult],
  duration_ms : Int64,
) -> RunSummary {
  let mut total = 0
  let mut passed = 0
  let mut failed = 0
  let mut undefined = 0
  let mut pending = 0
  let mut skipped = 0
  for f in features {
    for s in f.scenarios {
      total = total + 1
      match s.status {
        ScenarioStatus::Passed => passed = passed + 1
        ScenarioStatus::Failed => failed = failed + 1
        ScenarioStatus::Undefined => undefined = undefined + 1
        ScenarioStatus::Pending => pending = pending + 1
        ScenarioStatus::Skipped => skipped = skipped + 1
      }
    }
  }
  {
    total_scenarios: total,
    passed,
    failed,
    undefined,
    pending,
    skipped,
    duration_ms,
  }
}
```

**Step 4: Run test to verify it passes**

**Step 5: Commit**

```bash
git add src/runner/run.mbt src/runner/run_wbtest.mbt
git commit -m "feat(runner): add run orchestrator with summary computation"
```

---

### Task 13: Format — Pretty Formatter

**Files:**
- Create: `src/format/pretty.mbt`
- Create: `src/format/pretty_wbtest.mbt`

Colored console output with pass/fail markers and scenario summary.

**Step 1: Write the failing test**

`src/format/pretty_wbtest.mbt`:
```moonbit
test "PrettyFormatter formats passed scenario" {
  let fmt = PrettyFormatter::new(no_color=true)
  let result : @runner.ScenarioResult = {
    feature_name: "Math",
    scenario_name: "Addition",
    tags: [],
    steps: [
      { text: "I have 5 cucumbers", keyword: "Given ", status: @runner.StepStatus::Passed, duration_ms: 1L },
    ],
    status: @runner.ScenarioStatus::Passed,
    duration_ms: 1L,
  }
  fmt.on_scenario_finish(result)
  let output = fmt.output()
  assert_true!(output.contains("Addition"))
  assert_true!(output.contains("PASS") || output.contains("✓"))
}

test "PrettyFormatter formats summary" {
  let fmt = PrettyFormatter::new(no_color=true)
  let run_result : @runner.RunResult = {
    features: [],
    summary: {
      total_scenarios: 3,
      passed: 2,
      failed: 1,
      undefined: 0,
      pending: 0,
      skipped: 0,
      duration_ms: 100L,
    },
  }
  fmt.on_run_finish(run_result)
  let output = fmt.output()
  assert_true!(output.contains("3 scenario"))
  assert_true!(output.contains("2 passed"))
  assert_true!(output.contains("1 failed"))
}
```

**Step 2: Run test to verify it fails**

**Step 3: Write implementation**

`src/format/pretty.mbt`:
```moonbit
///|
/// Pretty console formatter with colored output.
pub(all) struct PrettyFormatter {
  priv no_color : Bool
  priv mut buffer : String
}

///|
pub fn PrettyFormatter::new(no_color~ : Bool = false) -> PrettyFormatter {
  { no_color, buffer: "" }
}

///|
/// Get the accumulated output.
pub fn PrettyFormatter::output(self : PrettyFormatter) -> String {
  self.buffer
}

// Implement Formatter trait
impl Formatter for PrettyFormatter with on_feature_start(self, name) {
  self.buffer = self.buffer + "Feature: " + name + "\n\n"
}

impl Formatter for PrettyFormatter with on_scenario_finish(self, result) {
  let marker = match result.status {
    @runner.ScenarioStatus::Passed => if self.no_color { "  PASS" } else { "  \x1b[32m✓\x1b[0m" }
    @runner.ScenarioStatus::Failed => if self.no_color { "  FAIL" } else { "  \x1b[31m✗\x1b[0m" }
    @runner.ScenarioStatus::Undefined => if self.no_color { "  UNDEF" } else { "  \x1b[33m?\x1b[0m" }
    @runner.ScenarioStatus::Pending => if self.no_color { "  PENDING" } else { "  \x1b[33m⏸\x1b[0m" }
    @runner.ScenarioStatus::Skipped => if self.no_color { "  SKIP" } else { "  \x1b[36m-\x1b[0m" }
  }
  self.buffer = self.buffer + marker + " Scenario: " + result.scenario_name + "\n"
  for step in result.steps {
    let step_marker = match step.status {
      @runner.StepStatus::Passed => if self.no_color { "    ✓" } else { "    \x1b[32m✓\x1b[0m" }
      @runner.StepStatus::Failed(_) => if self.no_color { "    ✗" } else { "    \x1b[31m✗\x1b[0m" }
      @runner.StepStatus::Skipped => if self.no_color { "    -" } else { "    \x1b[36m-\x1b[0m" }
      @runner.StepStatus::Undefined => if self.no_color { "    ?" } else { "    \x1b[33m?\x1b[0m" }
      @runner.StepStatus::Pending => if self.no_color { "    ⏸" } else { "    \x1b[33m⏸\x1b[0m" }
    }
    self.buffer = self.buffer + step_marker + " " + step.keyword + step.text + "\n"
  }
  self.buffer = self.buffer + "\n"
}

impl Formatter for PrettyFormatter with on_run_finish(self, result) {
  let s = result.summary
  self.buffer = self.buffer +
    s.total_scenarios.to_string() + " scenarios (" +
    s.passed.to_string() + " passed"
  if s.failed > 0 {
    self.buffer = self.buffer + ", " + s.failed.to_string() + " failed"
  }
  if s.undefined > 0 {
    self.buffer = self.buffer + ", " + s.undefined.to_string() + " undefined"
  }
  if s.pending > 0 {
    self.buffer = self.buffer + ", " + s.pending.to_string() + " pending"
  }
  if s.skipped > 0 {
    self.buffer = self.buffer + ", " + s.skipped.to_string() + " skipped"
  }
  self.buffer = self.buffer + ")\n"
}
```

**Step 4: Run test to verify it passes**

**Step 5: Commit**

```bash
git add src/format/pretty.mbt src/format/pretty_wbtest.mbt
git commit -m "feat(format): add Pretty console formatter with colored output"
```

---

### Task 14: Format — Cucumber Messages Formatter

**Files:**
- Create: `src/format/messages.mbt`
- Create: `src/format/messages_wbtest.mbt`

NDJSON output using `moonrockz/cucumber-messages`.

**Step 1: Write the failing test**

`src/format/messages_wbtest.mbt`:
```moonbit
test "MessagesFormatter emits TestRunStarted envelope" {
  let fmt = MessagesFormatter::new()
  fmt.on_run_start({ feature_count: 1, scenario_count: 2 })
  let lines = fmt.output().split("\n")
  assert_true!(lines[0].contains("testRunStarted"))
}

test "MessagesFormatter emits TestRunFinished envelope" {
  let fmt = MessagesFormatter::new()
  let run_result : @runner.RunResult = {
    features: [],
    summary: {
      total_scenarios: 1,
      passed: 1,
      failed: 0,
      undefined: 0,
      pending: 0,
      skipped: 0,
      duration_ms: 50L,
    },
  }
  fmt.on_run_finish(run_result)
  let output = fmt.output()
  assert_true!(output.contains("testRunFinished"))
  assert_true!(output.contains("true")) // success: true
}
```

**Step 2: Run test to verify it fails**

**Step 3: Write implementation**

`src/format/messages.mbt`:
```moonbit
///|
/// Cucumber Messages NDJSON formatter.
pub(all) struct MessagesFormatter {
  priv mut buffer : String
}

///|
pub fn MessagesFormatter::new() -> MessagesFormatter {
  { buffer: "" }
}

///|
pub fn MessagesFormatter::output(self : MessagesFormatter) -> String {
  self.buffer
}

impl Formatter for MessagesFormatter with on_run_start(self, _info) {
  let ts = @cucumber_messages.Timestamp::{ seconds: 0, nanos: 0 }
  let env = @cucumber_messages.Envelope::TestRunStarted(
    @cucumber_messages.TestRunStarted::{ timestamp: ts, id: None },
  )
  self.buffer = self.buffer + env.to_ndjson_line() + "\n"
}

impl Formatter for MessagesFormatter with on_run_finish(self, result) {
  let ts = @cucumber_messages.Timestamp::{ seconds: 0, nanos: 0 }
  let success = result.summary.failed == 0 && result.summary.undefined == 0
  let env = @cucumber_messages.Envelope::TestRunFinished(
    @cucumber_messages.TestRunFinished::{
      message: None,
      success,
      timestamp: ts,
      exception: None,
      testRunStartedId: None,
    },
  )
  self.buffer = self.buffer + env.to_ndjson_line() + "\n"
}
```

**Note:** Full Messages protocol compliance (TestCaseStarted, TestStepStarted,
etc.) will be enhanced later. This task establishes the foundation.

**Step 4: Run test to verify it passes**

**Step 5: Commit**

```bash
git add src/format/messages.mbt src/format/messages_wbtest.mbt
git commit -m "feat(format): add Cucumber Messages NDJSON formatter"
```

---

### Task 15: Format — JUnit XML Formatter

**Files:**
- Create: `src/format/junit.mbt`
- Create: `src/format/junit_wbtest.mbt`

Standard JUnit XML output for CI systems.

**Step 1: Write the failing test**

`src/format/junit_wbtest.mbt`:
```moonbit
test "JUnitFormatter produces valid XML structure" {
  let fmt = JUnitFormatter::new()
  let run_result : @runner.RunResult = {
    features: [
      {
        name: "Math",
        scenarios: [
          {
            feature_name: "Math",
            scenario_name: "Addition",
            tags: [],
            steps: [],
            status: @runner.ScenarioStatus::Passed,
            duration_ms: 50L,
          },
        ],
        duration_ms: 50L,
      },
    ],
    summary: {
      total_scenarios: 1,
      passed: 1,
      failed: 0,
      undefined: 0,
      pending: 0,
      skipped: 0,
      duration_ms: 50L,
    },
  }
  fmt.on_run_finish(run_result)
  let output = fmt.output()
  assert_true!(output.contains("<?xml"))
  assert_true!(output.contains("<testsuites"))
  assert_true!(output.contains("<testsuite"))
  assert_true!(output.contains("name=\"Math\""))
  assert_true!(output.contains("<testcase"))
  assert_true!(output.contains("name=\"Addition\""))
}
```

**Step 2: Run test to verify it fails**

**Step 3: Write implementation**

`src/format/junit.mbt`:
```moonbit
///|
/// JUnit XML formatter for CI integration.
pub(all) struct JUnitFormatter {
  priv mut buffer : String
}

///|
pub fn JUnitFormatter::new() -> JUnitFormatter {
  { buffer: "" }
}

///|
pub fn JUnitFormatter::output(self : JUnitFormatter) -> String {
  self.buffer
}

impl Formatter for JUnitFormatter with on_run_finish(self, result) {
  let mut xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  xml = xml + "<testsuites tests=\"" + result.summary.total_scenarios.to_string() + "\""
  xml = xml + " failures=\"" + result.summary.failed.to_string() + "\""
  xml = xml + " time=\"" + ms_to_seconds(result.summary.duration_ms) + "\">\n"
  for feature in result.features {
    xml = xml + "  <testsuite name=\"" + escape_xml(feature.name) + "\""
    xml = xml + " tests=\"" + feature.scenarios.length().to_string() + "\""
    xml = xml + " time=\"" + ms_to_seconds(feature.duration_ms) + "\">\n"
    for scenario in feature.scenarios {
      xml = xml + "    <testcase name=\"" + escape_xml(scenario.scenario_name) + "\""
      xml = xml + " classname=\"" + escape_xml(scenario.feature_name) + "\""
      xml = xml + " time=\"" + ms_to_seconds(scenario.duration_ms) + "\">\n"
      match scenario.status {
        @runner.ScenarioStatus::Failed => {
          let msg = find_failure_message(scenario.steps)
          xml = xml + "      <failure message=\"" + escape_xml(msg) + "\"/>\n"
        }
        @runner.ScenarioStatus::Skipped =>
          xml = xml + "      <skipped/>\n"
        _ => ()
      }
      xml = xml + "    </testcase>\n"
    }
    xml = xml + "  </testsuite>\n"
  }
  xml = xml + "</testsuites>\n"
  self.buffer = xml
}

fn ms_to_seconds(ms : Int64) -> String {
  let s = ms / 1000L
  let frac = ms % 1000L
  s.to_string() + "." + frac.to_string().pad_start(3, '0')
}

fn escape_xml(s : String) -> String {
  s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    .replace("\"", "&quot;")
}

fn find_failure_message(steps : Array[@runner.StepResult]) -> String {
  for step in steps {
    match step.status {
      @runner.StepStatus::Failed(msg) => return msg
      _ => continue
    }
  }
  "unknown failure"
}
```

**Step 4: Run test to verify it passes**

**Step 5: Commit**

```bash
git add src/format/junit.mbt src/format/junit_wbtest.mbt
git commit -m "feat(format): add JUnit XML formatter for CI integration"
```

---

### Task 16: Async — Parallel Scenario Execution

**Files:**
- Create: `src/runner/parallel.mbt`
- Create: `src/runner/parallel_wbtest.mbt`
- Modify: `src/runner/run.mbt`

Integrate `moonbitlang/async` for concurrent scenario execution with
bounded concurrency.

**Step 1: Write the failing test**

`src/runner/parallel_wbtest.mbt`:
```moonbit
async test "run_parallel executes scenarios concurrently" {
  let registry = @core.StepRegistry::new()
  registry.given("a step", fn(_args) { @async.pause() })
  let features = [
    "Feature: A\n\n  Scenario: S1\n    Given a step\n",
    "Feature: B\n\n  Scenario: S2\n    Given a step\n",
  ]
  let result = run!(registry, features, parallel=2)
  assert_eq!(result.summary.total_scenarios, 2)
  assert_eq!(result.summary.passed, 2)
}
```

**Step 2: Run test to verify it fails**

**Step 3: Write implementation**

`src/runner/parallel.mbt`:
```moonbit
///|
/// Execute feature contents in parallel with bounded concurrency.
pub async fn run_parallel(
  registry : @core.StepRegistry,
  features : Array[String],
  max_concurrent~ : Int,
  tag_expr~ : String = "",
) -> RunResult!Error {
  let tasks : Array[async () -> FeatureResult] = features.map(fn(content) {
    async fn() -> FeatureResult {
      execute_feature_filtered!(registry, content, tag_expr~)
    }
  })
  let feature_results = @async.all(tasks[:], max_concurrent~)
  let summary = compute_summary(feature_results, 0L)
  { features: feature_results, summary }
}
```

Update `src/runner/run.mbt` to accept `parallel~` parameter:
```moonbit
pub async fn run(
  registry : @core.StepRegistry,
  features : Array[String],
  tag_expr~ : String = "",
  parallel~ : Int = 0,
) -> RunResult!Error {
  if parallel > 0 {
    run_parallel!(registry, features, max_concurrent=parallel, tag_expr~)
  } else {
    // existing sequential logic
  }
}
```

**Step 4: Run test to verify it passes**

```bash
mise run test:unit
```

**Note:** This task may require adjusting function signatures to be `async` throughout
the call chain. The test uses `async test` which requires the async runtime.

**Step 5: Commit**

```bash
git add src/runner/parallel.mbt src/runner/parallel_wbtest.mbt src/runner/run.mbt
git commit -m "feat(runner): add parallel scenario execution with bounded concurrency"
```

---

### Task 17: Codegen — Generate _test.mbt from .feature Files

**Files:**
- Create: `src/codegen/codegen.mbt`
- Create: `src/codegen/codegen_wbtest.mbt`

Generate `async test` blocks from parsed Gherkin features.

**Step 1: Write the failing test**

`src/codegen/codegen_wbtest.mbt`:
```moonbit
test "generate_test_file produces async test blocks" {
  let feature_content =
    "Feature: Login\n\n  Scenario: Valid credentials\n    Given a user\n    When they log in\n    Then they see the dashboard\n"
  let output = generate_test_file(feature_content, "features/login.feature")
  assert_true!(output.contains("async test"))
  assert_true!(output.contains("Feature: Login / Scenario: Valid credentials"))
  assert_true!(output.contains("features/login.feature"))
}

test "generate_test_file includes hash for staleness detection" {
  let content = "Feature: X\n\n  Scenario: Y\n    Given z\n"
  let output = generate_test_file(content, "features/x.feature")
  assert_true!(output.contains("// moonspec:hash:"))
}

test "feature_to_test_filename converts paths" {
  assert_eq!(feature_to_test_filename("features/login.feature"), "login_feature_test.mbt")
  assert_eq!(
    feature_to_test_filename("features/admin/users.feature"),
    "admin_users_feature_test.mbt",
  )
}
```

**Step 2: Run test to verify it fails**

**Step 3: Write implementation**

`src/codegen/codegen.mbt`:
```moonbit
///|
/// Generate a _test.mbt file from feature content.
pub fn generate_test_file(
  feature_content : String,
  feature_path : String,
) -> String {
  let hash = simple_hash(feature_content)
  let source = @gherkin.Source::from_string(feature_content, uri=feature_path)
  let doc = @gherkin.parse(source) catch { _ => return "// moonspec: parse error\n" }
  let feature = match doc.feature {
    Some(f) => f
    None => return "// moonspec: no feature found\n"
  }
  let mut output = "// Generated by moonspec — do not edit\n"
  output = output + "// Source: " + feature_path + "\n"
  output = output + "// moonspec:hash:" + hash + "\n\n"
  for child in feature.children {
    match child {
      @gherkin.FeatureChild::Scenario(scenario) => {
        if scenario.examples.is_empty() {
          output = output + generate_scenario_test(
            feature.name,
            scenario.name,
            feature_path,
          )
        } else {
          // Scenario Outline — generate one test per examples row
          for examples in scenario.examples {
            match examples.table_header {
              Some(header_row) => {
                let headers = header_row.cells.map(fn(c) { c.value })
                for row in examples.table_body {
                  let values = row.cells.map(fn(c) { c.value })
                  let params : Array[String] = []
                  for i, h in headers {
                    params.push(h + "=" + values[i])
                  }
                  let name = scenario.name + " (" + params.join(", ") + ")"
                  output = output + generate_scenario_test(
                    feature.name,
                    name,
                    feature_path,
                  )
                }
              }
              None => ()
            }
          }
        }
      }
      _ => ()
    }
  }
  output
}

fn generate_scenario_test(
  feature_name : String,
  scenario_name : String,
  feature_path : String,
) -> String {
  let test_name = "Feature: " + feature_name + " / Scenario: " + scenario_name
  let mut s = "async test \"" + escape_string(test_name) + "\" {\n"
  s = s + "  let runner = @moonspec.Runner::new(@myapp.MyWorld::new())\n"
  s = s + "  runner.run_scenario!(\n"
  s = s + "    feature=\"" + feature_path + "\",\n"
  s = s + "    scenario=\"" + escape_string(scenario_name) + "\",\n"
  s = s + "  )\n"
  s = s + "}\n\n"
  s
}

///|
/// Convert a feature file path to a test filename.
pub fn feature_to_test_filename(path : String) -> String {
  // Strip "features/" prefix if present
  let stripped = if path.has_prefix("features/") {
    path.view(start_offset=9).to_string()
  } else {
    path
  }
  // Replace / and . with _
  stripped.replace("/", "_").replace(".feature", "_feature_test.mbt")
}

fn escape_string(s : String) -> String {
  s.replace("\\", "\\\\").replace("\"", "\\\"")
}

fn simple_hash(s : String) -> String {
  // Simple FNV-like hash for staleness detection
  let mut h : Int64 = 2166136261L
  let chars = s.to_array()
  for c in chars {
    h = h.lxor(c.to_int().to_int64())
    h = h * 16777619L
  }
  h.to_string()
}
```

**Step 4: Run test to verify it passes**

**Step 5: Commit**

```bash
git add src/codegen/codegen.mbt src/codegen/codegen_wbtest.mbt
git commit -m "feat(codegen): generate async test files from .feature files"
```

---

### Task 18: AGENTS.md and README

**Files:**
- Modify: `AGENTS.md`
- Create: `README.md`
- Create: `README.mbt.md`

**Step 1: Write AGENTS.md**

Update with MoonBit project structure, moonspec-specific architecture,
TDD guidelines, conventional commits, mise tasks, beads integration, and
session completion protocol. Follow the pattern from `moonrockz/cucumber-expressions/AGENTS.md`.

**Step 2: Write README.md**

Include CI badge, project description, installation, quick start with all
three integration modes (codegen, runner API, CLI), feature list,
architecture diagram, and Apache-2.0 license.

**Step 3: Write README.mbt.md**

Mooncakes.io package README — shorter, focused on API usage.

**Step 4: Verify compilation**

```bash
moon check && moon test
```

**Step 5: Commit**

```bash
git add AGENTS.md README.md README.mbt.md
git commit -m "docs: add AGENTS.md and README with usage documentation"
```

---

### Task 19: CI and Release Workflows

**Files:**
- Create: `.github/workflows/ci.yml`
- Create: `.github/workflows/release.yml`
- Create: `mise-tasks/release/credentials`
- Create: `mise-tasks/release/publish`
- Create: `mise-tasks/release/version`

Follow the exact same pattern as `moonrockz/cucumber-expressions`. CI runs
lint + unit tests on push/PR. Release triggered by `v*` tags, publishes to
mooncakes.io, creates GitHub Release.

**Step 1: Create CI and release files**

Copy structure from cucumber-expressions, updating project name references.

**Step 2: Verify mise tasks work**

```bash
mise tasks
mise run test:unit
```

**Step 3: Commit**

```bash
git add .github/ mise-tasks/release/
git commit -m "ci: add CI and release workflows with mooncakes.io publishing"
```

---

### Task 20: End-to-End Integration Test

**Files:**
- Create: `src/runner/e2e_wbtest.mbt`
- Create: `tests/fixtures/calculator.feature`

Write a complete end-to-end test: parse a `.feature` file, register step
definitions, execute with the runner, verify results through the Pretty
formatter.

**Step 1: Create the fixture**

`tests/fixtures/calculator.feature`:
```gherkin
Feature: Calculator

  Background:
    Given a calculator

  Scenario: Addition
    When I add 5 and 3
    Then the result should be 8

  Scenario: Subtraction
    When I subtract 3 from 10
    Then the result should be 7

  @slow
  Scenario Outline: Multiplication
    When I multiply <a> and <b>
    Then the result should be <result>

    Examples:
      | a  | b  | result |
      | 2  | 3  | 6      |
      | 10 | 5  | 50     |
```

**Step 2: Write the end-to-end test**

`src/runner/e2e_wbtest.mbt`:
```moonbit
test "end-to-end: calculator feature" {
  let registry = @core.StepRegistry::new()
  let mut result_val = 0
  registry.given("a calculator", fn(_args) { result_val = 0 })
  registry.when("I add {int} and {int}", fn(args) {
    match (args[0], args[1]) {
      (@core.StepArg::IntArg(a), @core.StepArg::IntArg(b)) => result_val = a + b
      _ => ()
    }
  })
  registry.when("I subtract {int} from {int}", fn(args) {
    match (args[0], args[1]) {
      (@core.StepArg::IntArg(a), @core.StepArg::IntArg(b)) => result_val = b - a
      _ => ()
    }
  })
  registry.when("I multiply {int} and {int}", fn(args) {
    match (args[0], args[1]) {
      (@core.StepArg::IntArg(a), @core.StepArg::IntArg(b)) => result_val = a * b
      _ => ()
    }
  })
  registry.then("the result should be {int}", fn(args) {
    match args[0] {
      @core.StepArg::IntArg(expected) => assert_eq!(result_val, expected)
      _ => ()
    }
  })
  let content =
    "Feature: Calculator\n\n  Background:\n    Given a calculator\n\n  Scenario: Addition\n    When I add 5 and 3\n    Then the result should be 8\n\n  Scenario: Subtraction\n    When I subtract 3 from 10\n    Then the result should be 7\n\n  Scenario Outline: Multiplication\n    When I multiply <a> and <b>\n    Then the result should be <result>\n\n    Examples:\n      | a  | b  | result |\n      | 2  | 3  | 6      |\n      | 10 | 5  | 50     |\n"
  let result = run!(registry, [content])
  assert_eq!(result.summary.total_scenarios, 4) // 2 regular + 2 outline rows
  assert_eq!(result.summary.passed, 4)
  assert_eq!(result.summary.failed, 0)
}

test "end-to-end: tag filtering" {
  let registry = @core.StepRegistry::new()
  registry.given("a calculator", fn(_args) {  })
  registry.when("I add {int} and {int}", fn(_args) {  })
  registry.then("the result should be {int}", fn(_args) {  })
  let content =
    "Feature: Tagged\n\n  @smoke\n  Scenario: Fast\n    Given a calculator\n\n  @slow\n  Scenario: Slow\n    Given a calculator\n"
  let result = run!(registry, [content], tag_expr="@smoke")
  assert_eq!(result.summary.total_scenarios, 1)
}
```

**Step 3: Run all tests**

```bash
mise run test:unit
```

Expected: ALL PASS.

**Step 4: Commit**

```bash
git add src/runner/e2e_wbtest.mbt tests/fixtures/
git commit -m "test: add end-to-end integration tests with calculator feature"
```

---

## Dependency Order

```
Task 1 (scaffolding)
  ├── Task 2 (result types)
  ├── Task 3 (core types — StepArg, Info)
  │    └── Task 4 (step registry)
  │         └── Task 6 (scenario executor)
  │              └── Task 7 (feature executor — gherkin)
  │                   ├── Task 8 (background steps)
  │                   ├── Task 9 (scenario outline)
  │                   ├── Task 10 (tag parser)
  │                   │    └── Task 11 (tag filtering)
  │                   └── Task 12 (run orchestrator)
  │                        ├── Task 16 (parallel execution)
  │                        └── Task 20 (e2e tests)
  └── Task 5 (formatter trait)
       ├── Task 13 (pretty formatter)
       ├── Task 14 (messages formatter)
       └── Task 15 (junit formatter)

Task 17 (codegen) — independent, needs only gherkin
Task 18 (docs) — after core features complete
Task 19 (CI) — after docs
```

## Important Notes

**MoonBit package aliasing:** When importing `moonrockz/cucumber-expressions`,
check how MoonBit resolves hyphenated package names. The alias might be
`@cucumber_expressions` or `@cucumber-expressions`. Run `moon check` early and
adjust imports in `moon.pkg` files if needed.

**Async function coloring:** Once Task 16 makes `run()` async, the call chain
needs `async` annotations. This may require retrofitting earlier functions.
Plan for this — the executor and feature functions may need to become async too.

**String methods:** MoonBit 0.8 deprecated `starts_with`/`ends_with` in favor of
`has_prefix`/`has_suffix`. Use the new names.

**`moon.pkg` DSL format:** Use the new DSL format (not `.json`) per MoonBit 0.8.
