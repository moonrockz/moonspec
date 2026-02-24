# moonspec

[![CI](https://github.com/moonrockz/moonspec/actions/workflows/ci.yml/badge.svg)](https://github.com/moonrockz/moonspec/actions/workflows/ci.yml)

**BDD test framework for MoonBit** with Gherkin and Cucumber Expressions.

moonspec brings Behavior-Driven Development to [MoonBit](https://www.moonbitlang.com/).
Write specifications in Gherkin, match steps with Cucumber Expressions, and run
them natively with `moon test` or via the programmatic Runner API.

## Quick Start

### Installation

```bash
moon add moonrockz/moonspec
```

### Minimal Working Example

1. Write a feature file (`features/calculator.feature`):

```gherkin
Feature: Calculator

  Scenario: Addition
    Given a calculator
    When I add 2 and 3
    Then the result should be 5
```

2. Define a World struct with step definitions:

```moonbit
struct CalcWorld {
  mut result : Int
} derive(Default)

impl @moonspec.World for CalcWorld with configure(self, setup) {
  setup.given("a calculator", fn(_ctx) { self.result = 0 })
  setup.when("I add {int} and {int}", fn(ctx) {
    match (ctx[0], ctx[1]) {
      ({ value: @moonspec.StepValue::IntVal(a), .. }, { value: @moonspec.StepValue::IntVal(b), .. }) =>
        self.result = a + b
      _ => ()
    }
  })
  setup.then("the result should be {int}", fn(ctx) raise {
    match ctx[0] {
      { value: @moonspec.StepValue::IntVal(expected), .. } => assert_eq(self.result, expected)
      _ => ()
    }
  })
}
```

3. Run the feature:

```moonbit
async test "calculator" {
  let feature =
    #|Feature: Calculator
    #|
    #|  Scenario: Addition
    #|    Given a calculator
    #|    When I add 2 and 3
    #|    Then the result should be 5
  @moonspec.run_or_fail(
    CalcWorld::default,
    @moonspec.RunOptions::new([@moonspec.FeatureSource::Text("test://calculator", feature)]),
  )
  |> ignore
}
```

Each scenario gets a fresh `CalcWorld` instance (via `derive(Default)`), so state
never leaks between scenarios.

## Writing Features

moonspec uses standard [Gherkin](https://cucumber.io/docs/gherkin/) syntax:

```gherkin
@smoke
Feature: Shopping Cart

  Background:
    Given a logged-in user
    And an empty cart

  Scenario: Add item to cart
    When I add "Widget" to the cart
    Then the cart should contain 1 item

  @slow
  Scenario Outline: Bulk discount
    When I add <quantity> of "<product>" to the cart
    Then the discount should be <discount>%

    Examples:
      | quantity | product | discount |
      | 10       | Widget  | 5        |
      | 50       | Widget  | 15       |
      | 100      | Gadget  | 20       |
```

Supported constructs:

- **Feature** -- top-level container with optional description
- **Scenario** -- a concrete test case
- **Scenario Outline** -- parameterized scenario with Examples table
- **Background** -- shared Given steps run before each scenario
- **Rule** -- grouping scenarios under a business rule
- **Data Tables** -- tabular data attached to a step
- **Doc Strings** -- multiline text attached to a step
- **Tags** -- `@tag` annotations for filtering and metadata
- **Comments** -- lines starting with `#`

## World and Step Definitions

Following the [cucumber-rs pattern](https://cucumber-rs.github.io/cucumber/main/quickstart.html),
moonspec uses a **World struct** to hold per-scenario state. Each scenario gets a
fresh instance constructed via MoonBit's `Default` trait.

### Defining a World

```moonbit
struct MyWorld {
  mut cucumbers : Int
  mut belly_full : Bool
} derive(Default)
```

`derive(Default)` zero-initializes all fields. For custom initialization, implement
`Default` manually.

### Configuring Steps

Implement the `World` trait to configure step definitions. The `self` parameter is
your world instance -- closures capture it to share state between steps. Step
handlers receive a `Ctx` wrapper that provides indexed access to arguments,
scenario/step metadata, and attachment methods:

```moonbit
impl @moonspec.World for MyWorld with configure(self, setup) {
  setup.given("I have {int} cucumbers", fn(ctx) {
    match ctx[0] {
      { value: @moonspec.StepValue::IntVal(n), .. } => self.cucumbers = n
      _ => ()
    }
  })

  setup.when("I eat {int} cucumbers", fn(ctx) {
    match ctx[0] {
      { value: @moonspec.StepValue::IntVal(n), .. } => self.cucumbers = self.cucumbers - n
      _ => ()
    }
  })

  setup.then("I should have {int} cucumbers", fn(ctx) raise {
    match ctx[0] {
      { value: @moonspec.StepValue::IntVal(expected), .. } => assert_eq(self.cucumbers, expected)
      _ => ()
    }
  })
}
```

### Cucumber Expression Parameters

| Parameter | StepValue Variant | Example Pattern |
|-----------|-------------------|-----------------|
| `{int}` | `IntVal(Int)` | `"I have {int} items"` |
| `{float}` | `FloatVal(Double)` | `"priced at {float}"` |
| `{double}` | `DoubleVal(Double)` | `"ratio is {double}"` |
| `{long}` | `LongVal(Int64)` | `"id is {long}"` |
| `{byte}` | `ByteVal(Byte)` | `"byte {byte}"` |
| `{short}` | `ShortVal(Int)` | `"port {short}"` |
| `{bigdecimal}` | `BigDecimalVal(@decimal.Decimal)` | `"amount {bigdecimal}"` |
| `{biginteger}` | `BigIntegerVal(BigInt)` | `"value {biginteger}"` |
| `{string}` | `StringVal(String)` | `"named {string}"` |
| `{word}` | `WordVal(String)` | `"as {word}"` |
| custom | `CustomVal(@any.Any)` | user-defined types (see [Custom Parameter Types](#custom-parameter-types)) |

### Ctx and StepArg Destructuring

Step handlers receive a `Ctx` object. Use `ctx[i]` or `ctx.arg(i)` to access
individual `StepArg` values (each has `value : StepValue` and `raw : String`).
Use struct destructuring on `StepArg` to extract typed values:

```moonbit
setup.when("I transfer {float} from {string} to {string}", fn(ctx) {
  match (ctx[0], ctx[1], ctx[2]) {
    ({ value: @moonspec.StepValue::FloatVal(amount), .. },
     { value: @moonspec.StepValue::StringVal(from), .. },
     { value: @moonspec.StepValue::StringVal(to), .. }) =>
      transfer(amount, from, to)
    _ => ()
  }
})
```

### Attachments

Steps can attach content to test results for reporting. Attachment methods are
called directly on the `Ctx` object:

```moonbit
setup.given("I take a screenshot", fn(ctx) {
  // Attach text
  ctx.attach("log output here", "text/plain")

  // Attach binary (auto base64-encoded)
  ctx.attach_bytes(screenshot_bytes, "image/png", file_name="screenshot.png")

  // Attach external URL
  ctx.attach_url("https://ci.example.com/artifacts/log.txt", "text/plain")
})
```

Attachments are emitted as `Attachment` and `ExternalAttachment` envelopes in the Cucumber Messages protocol, visible in the Messages formatter output.

### Generic Steps

Use `setup.step()` to register a step that matches any keyword (Given/When/Then):

```moonbit
setup.step("I wait {int} seconds", fn(ctx) {
  // matches "Given I wait 5 seconds", "When I wait 5 seconds", etc.
  ignore(ctx)
})
```

### Composable Step Libraries

For larger projects, organize step definitions into reusable libraries using the
`StepLibrary` trait. Each library returns an `ArrayView[StepDef]`:

```moonbit
struct AccountSteps { world : BankWorld }

impl @moonspec.StepLibrary for AccountSteps with steps(self) {
  [
    @moonspec.StepDef::given("a bank account with balance {int}", fn(ctx) {
      match ctx[0] {
        { value: @moonspec.StepValue::IntVal(n), .. } => self.world.balance = n
        _ => ()
      }
    }),
    @moonspec.StepDef::then("the balance should be {int}", fn(ctx) raise {
      match ctx[0] {
        { value: @moonspec.StepValue::IntVal(n), .. } => assert_eq(self.world.balance, n)
        _ => ()
      }
    }),
  ][:]
}
```

Compose multiple libraries into a single World:

```moonbit
impl @moonspec.World for BankWorld with configure(self, setup) {
  setup.use_library(AccountSteps::new(self))
  setup.use_library(TransactionSteps::new(self))
}
```

See [`examples/bank-account/`](examples/bank-account/) for a complete example.

### Custom Parameter Types

Register custom parameter types to extend Cucumber Expressions beyond the
built-in `{int}`, `{float}`, `{string}`, and `{word}` types:

```moonbit
impl @moonspec.World for MyWorld with configure(self, setup) {
  setup.add_param_type("color", [@cucumber_expressions.RegexPattern("red|green|blue")])

  setup.then("the light should be {color}", fn(ctx) raise {
    match ctx[0] {
      { value: @moonspec.StepValue::CustomVal(any), .. } => {
        let color : String = any.to()
        assert_eq(self.light_color, color)
      }
      _ => ()
    }
  })
}
```

Custom parameter types match as `CustomVal(@any.Any)` in the `StepValue` enum. Use `any.to()` to unbox the value.

### Error Handling

moonspec uses a structured error hierarchy (`MoonspecError`) for test failures:

- `UndefinedStep` -- step has no matching definition (includes a copy-paste snippet and "did you mean?" suggestions)
- `PendingStep` -- step is marked as pending (placeholder implementation)
- `StepFailed` -- step assertion failed
- `ScenarioFailed` -- aggregates step errors for a scenario
- `RunFailed` -- aggregates scenario errors for a run

Use `run_or_fail` to raise on any failure instead of inspecting results manually:

```moonbit
async test "my feature" {
  @moonspec.run_or_fail(MyWorld::default, @moonspec.RunOptions::new(features)) |> ignore
}
```

## Lifecycle Hooks

Register hooks in your World's `configure` method for setup/teardown logic.
Hook handlers receive typed context objects that provide access to scenario/step
metadata and support attachments:

```moonbit
impl @moonspec.World for MyWorld with configure(self, setup) {
  setup.before_test_case(fn(ctx) {
    // ctx is CaseHookCtx -- access scenario info and attach content
    let name = ctx.scenario().scenario_name
    ctx.attach("starting: " + name, "text/plain")
  })
  setup.after_test_case(fn(ctx, result) {
    // ctx is CaseHookCtx, result is HookResult (Passed or Failed)
    match result {
      @moonspec.HookResult::Passed => ()
      @moonspec.HookResult::Failed(errors) => {
        for err in errors {
          println("Hook error: " + err.to_string())
        }
      }
    }
  })
  setup.before_test_step(fn(ctx) {
    // ctx is StepHookCtx -- access step info and attach content
    let text = ctx.step().step_text
    ctx.attach("running step: " + text, "text/plain")
  })
  setup.after_test_step(fn(ctx, result) {
    // ctx is StepHookCtx, result is HookResult
    ignore(ctx)
    ignore(result)
  })
  // Register steps as usual
  setup.given("a step", fn(_ctx) {  })
}
```

Register only the hooks you need -- unregistered hooks are simply not called.

Additional hook types for test run boundaries:

```moonbit
setup.before_test_run(fn(ctx) {
  // ctx is RunHookCtx -- supports attachments
  ctx.attach("test run starting", "text/plain")
})
setup.after_test_run(fn(ctx, result) {
  // ctx is RunHookCtx, result is HookResult
  ignore(ctx)
  ignore(result)
})
```

All hook context types (`RunHookCtx`, `CaseHookCtx`, `StepHookCtx`) implement
the `Attachable` trait, providing these methods:

- `ctx.attach(body, media_type)` -- attach text content
- `ctx.attach_bytes(bytes, media_type, file_name~)` -- attach binary content (auto base64-encoded)
- `ctx.attach_url(url, media_type)` -- attach an external URL

Hook behavior:
- If `before_test_case` raises, all steps are **Skipped** and the scenario is **Failed**
- `after_test_case` is always called, even when `before_test_case` fails
- `after_test_step` is always called after each step, regardless of pass/fail
- Multiple hooks per type are supported and execute in registration order
- `HookResult` is either `Passed` or `Failed(Array[HookError])`

## Running Tests

### Mode 1: Runner API

Use the Runner API directly in your test files for full programmatic control:

```moonbit
async test "calculator features" {
  // run_or_fail raises MoonspecError on any failure
  let opts = @moonspec.RunOptions::new([
    @moonspec.FeatureSource::File("features/calculator.feature"),
  ])
  opts.tag_expr("@smoke and not @slow")
  opts.parallel(true)
  opts.max_concurrent(4)
  @moonspec.run_or_fail(CalcWorld::default, opts) |> ignore
}
```

For cases where you need to inspect results programmatically, use `run` directly:

```moonbit
async test "inspect results" {
  let result = @moonspec.run(CalcWorld::default, @moonspec.RunOptions::new(features))
  assert_eq(result.summary.failed, 0)
}
```

`RunOptions` accepts an array of `FeatureSource` values and supports builder-style configuration:

- `FeatureSource::File(path)` -- load a `.feature` file from disk
- `FeatureSource::Text(path, content)` -- parse inline Gherkin text
- `FeatureSource::Parsed(path, feature)` -- use a pre-parsed feature

Builder methods (use `..` cascade syntax):
- `parallel(bool)` -- enable parallel execution (default: `false`)
- `max_concurrent(int)` -- max concurrent scenarios (default: `4`)
- `tag_expr(string)` -- boolean tag expression for filtering
- `scenario_name(string)` -- run only the scenario matching this name
- `add_sink(sink)` -- add a message sink for envelope output

### Mode 2: Pre-build Codegen

Use `moonspec gen` as a [pre-build](https://docs.moonbitlang.com/en/latest/toolchain/moon/package.html#pre-build)
step so that test files are regenerated automatically from `.feature` files on
every `moon check`, `moon build`, or `moon test`:

```json
{
  "pre-build": [
    {
      "input": "../features/calculator.feature",
      "output": "calculator_feature_test.mbt",
      "command": "moonspec gen features/calculator.feature -w CalcWorld -o src/"
    }
  ]
}
```

The `--world` (`-w`) flag tells codegen which World type to use. Generated tests
call `@moonspec.run_or_fail` with `FeatureSource::File` to load the `.feature`
file at runtime and execute each scenario through the full runner pipeline.

The generated `*_feature_test.mbt` files should be gitignored -- your `.feature`
files are the single source of truth.

See [CLI: `gen` command](#gen----generate-test-files) and the
[calculator example](examples/calculator/) for a full walkthrough.

### Multiple Feature Files

Pass multiple `FeatureSource::File` entries to run all features in a single call:

```moonbit
async test "all features" {
  let opts = @moonspec.RunOptions::new([
    @moonspec.FeatureSource::File("features/cart.feature"),
    @moonspec.FeatureSource::File("features/checkout.feature"),
    @moonspec.FeatureSource::File("features/inventory.feature"),
  ])
  opts.tag_expr("@smoke and not @slow")
  @moonspec.run_or_fail(MyWorld::default, opts) |> ignore
}
```

Tag expressions filter across all features in the list. See [`examples/ecommerce/`](examples/ecommerce/) for a complete multi-feature setup.

### Embedding the Runner

You can embed the moonspec runner in your own binary to build custom CLI tools.
Use `run` (not `run_or_fail`) to get the `RunResult` and wire it to a formatter:

```moonbit
async fn main {
  let features = [
    @moonspec.FeatureSource::File("features/cart.feature"),
    @moonspec.FeatureSource::File("features/checkout.feature"),
  ]
  let result = @moonspec.run(MyWorld::default, @moonspec.RunOptions::new(features))
  let fmt = @format.PrettyFormatter::new()
  for feature in result.features {
    @format.Formatter::on_feature_start(fmt, feature.name)
    for scenario in feature.scenarios {
      @format.Formatter::on_scenario_finish(fmt, scenario)
    }
  }
  @format.Formatter::on_run_finish(fmt, result)
  println(fmt.output())
}
```

See [`examples/ecommerce-cli/`](examples/ecommerce-cli/) for a complete CLI runner example.

## CLI

### Installing the CLI

Install the moonspec CLI globally with `moon install`:

```bash
moon install moonrockz/moonspec/src/cmd/main
```

This makes `moonspec` available as a global command. You can then run:

```bash
moonspec gen features/*.feature -o src/
moonspec check features/*.feature
moonspec version
```

Alternatively, run the CLI directly from the project without installing:

```bash
moon run src/cmd/main -- <command> [args...]
```

### `gen` -- Generate Test Files

```bash
moon run src/cmd/main -- gen <feature-files...> -w <WorldType> [--output-dir <dir>]
```

Reads `.feature` files and generates `_test.mbt` test files. Each scenario becomes
an `async test` block that calls `@moonspec.run_or_fail` with `FeatureSource::File`
to load the feature at runtime and execute it through the full runner pipeline.

**Arguments:**
- One or more `.feature` file paths (required)
- `--world` / `-w`: World type name, e.g. `CalcWorld` (required)
- `--output-dir` / `-o`: write generated files to this directory (default: current directory)
- `--mode` / `-m`: `per-scenario` (default) or `per-feature`
- `--config` / `-c`: path to a `moonspec.json5` config file

**Config file** (`moonspec.json5`):

```json5
{
  "world": "CalcWorld",
  "mode": "per-scenario"  // or "per-feature"
}
```

If a `moonspec.json5` file exists in the current directory, it is loaded
automatically. CLI flags override config file values.

**Examples:**

```bash
# Generate a single test file
moon run src/cmd/main -- gen features/calculator.feature -w CalcWorld

# Generate into a specific directory
moon run src/cmd/main -- gen features/*.feature -w CalcWorld -o src/

# Per-feature mode (single test per feature file)
moon run src/cmd/main -- gen features/*.feature -w CalcWorld -m per-feature -o src/

# Then run the generated tests (async tests require JS target)
moon test --target js
```

**Generated output** for `features/calculator.feature` (per-scenario mode):

```moonbit
// Generated by moonspec codegen — DO NOT EDIT
// Source: features/calculator.feature
// moonspec:hash:a1b2c3d4

async test "Feature: Calculator / Scenario: Addition" {
  let options = @moonspec.RunOptions::new([@moonspec.FeatureSource::File("features/calculator.feature")])
  options.scenario_name("Addition")
  @moonspec.run_or_fail(CalcWorld::default, options) |> ignore
}
```

**Filename mapping:**
- `features/calculator.feature` → `calculator_feature_test.mbt`
- `features/auth/login.feature` → `auth_login_feature_test.mbt`

The `// moonspec:hash:...` comment enables future staleness detection -- regenerate
only when the feature file changes.

**Scenario Outlines** expand to one test per Examples row:

```moonbit
async test "Feature: Calculator / Scenario: Multiplication (a=2, b=3, result=6)" {
  let options = @moonspec.RunOptions::new([@moonspec.FeatureSource::File("features/calculator.feature")])
  options.scenario_name("Multiplication (a=2, b=3, result=6)")
  @moonspec.run_or_fail(CalcWorld::default, options) |> ignore
}
```

**Per-feature mode** generates a single test that runs the entire feature file:

```moonbit
async test "Feature: Calculator" {
  @moonspec.run_or_fail(
    CalcWorld::default,
    @moonspec.RunOptions::new([@moonspec.FeatureSource::File("features/calculator.feature")]),
  )
  |> ignore
}
```

### `check` -- Validate Feature Files

```bash
moon run src/cmd/main -- check <feature-files...>
```

Parses `.feature` files and reports their structure. Exits with code 1 on parse errors.

```bash
$ moon run src/cmd/main -- check features/calculator.feature
features/calculator.feature:
  Feature: Calculator
  Scenarios: 3
  Steps: 7
  Tags: @slow
```

### `version`

```bash
moon run src/cmd/main -- version
```

Prints `moonspec <version>`.

## Tag Filtering

Filter scenarios by tags using boolean expressions:

```moonbit
let features = [@moonspec.FeatureSource::File("features/my.feature")]

// Run only @smoke scenarios
let opts = @moonspec.RunOptions::new(features)
opts.tag_expr("@smoke")
let result = @moonspec.run(MyWorld::default, opts)

// Run @smoke but not @slow
let opts = @moonspec.RunOptions::new(features)
opts.tag_expr("@smoke and not @slow")
let result = @moonspec.run(MyWorld::default, opts)

// Run @smoke or @regression
let opts = @moonspec.RunOptions::new(features)
opts.tag_expr("@smoke or @regression")
let result = @moonspec.run(MyWorld::default, opts)
```

Tag expression syntax:

| Expression | Meaning |
|------------|---------|
| `@smoke` | Scenarios tagged `@smoke` |
| `not @slow` | Scenarios NOT tagged `@slow` |
| `@smoke and @fast` | Scenarios tagged with BOTH |
| `@smoke or @regression` | Scenarios tagged with EITHER |
| `@smoke and not @slow` | Combined expressions |

Tags are inherited: a tag on a Feature applies to all its scenarios.

## Scenario Outlines

Parameterized scenarios generate one test per row in the Examples table:

```gherkin
Scenario Outline: Arithmetic
  When I compute <a> <op> <b>
  Then the result should be <result>

  Examples:
    | a  | op  | b  | result |
    | 2  | +   | 3  | 5      |
    | 10 | -   | 4  | 6      |
    | 3  | *   | 7  | 21     |
```

Each row produces a separate scenario with `<placeholder>` values substituted.

## Background Steps

Background steps run before every scenario in a feature:

```gherkin
Feature: Account Management

  Background:
    Given a logged-in user
    And the account page is open

  Scenario: Change email
    When I update my email to "new@example.com"
    Then the email should be "new@example.com"

  Scenario: Change password
    When I change my password
    Then I should see a confirmation
```

## Async and Parallel Execution

The Runner API supports async execution and parallel feature processing:

```moonbit
async test "parallel features" {
  let features = [
    @moonspec.FeatureSource::File("features/auth.feature"),
    @moonspec.FeatureSource::File("features/cart.feature"),
    @moonspec.FeatureSource::File("features/checkout.feature"),
  ]
  // Run up to 4 features concurrently
  let opts = @moonspec.RunOptions::new(features)
  opts.parallel(true)
  opts.max_concurrent(4)
  @moonspec.run_or_fail(MyWorld::default, opts) |> ignore
}
```

- `parallel` controls max concurrent features (0 = sequential)
- Each scenario gets a fresh World instance, making parallel execution safe
- Tests must use `async test` blocks
- Requires JS target: `moon test --target js`

## Formatters

moonspec includes three formatters for different output needs:

### Pretty Formatter (Console)

Human-readable colored output:

```moonbit
let fmt = @format.PrettyFormatter::new()
// or disable colors:
let fmt = @format.PrettyFormatter::new(no_color=true)

// After running, get the formatted output:
let output = fmt.output()
```

### Cucumber Messages (NDJSON)

Standard Cucumber Messages protocol for tool integration:

```moonbit
let fmt = @format.MessagesFormatter::new()
// ... run features with formatter ...
let ndjson = fmt.output()
```

### JUnit XML

For CI/CD integration:

```moonbit
let fmt = @format.JUnitFormatter::new()
// ... run features with formatter ...
let xml = fmt.output()
```

### Using Formatters

Formatters implement the `Formatter` trait with event-driven callbacks:

```moonbit
pub(open) trait Formatter {
  on_run_start(Self, RunInfo) -> Unit
  on_feature_start(Self, String) -> Unit
  on_scenario_start(Self, ScenarioResult) -> Unit
  on_step_finish(Self, StepResult) -> Unit
  on_scenario_finish(Self, ScenarioResult) -> Unit
  on_feature_finish(Self, FeatureResult) -> Unit
  on_run_finish(Self, RunResult) -> Unit
}
```

## Example Projects

### Calculator (PerScenario mode)

See [`examples/calculator/`](examples/calculator/) -- one test per scenario:

- Codegen via `moonspec gen` with per-scenario mode (default)
- World struct with `derive(Default)` and inline step definitions
- Background steps, Scenario Outlines, and tag filtering

### Bank Account (PerFeature mode + StepLibrary)

See [`examples/bank-account/`](examples/bank-account/) -- single test per feature:

- Codegen via `moonspec gen -m per-feature`
- Composable step libraries (`AccountSteps`, `TransactionSteps`) via `StepLibrary` trait
- `use_library()` composition in the World

### E-commerce (Multi-Feature + StepLibrary)

See [`examples/ecommerce/`](examples/ecommerce/) -- multiple feature files with tag filtering:

- Three feature files (cart, checkout, inventory) with feature-level and scenario-level tags
- Composable step libraries (`CartSteps`, `CheckoutSteps`, `InventorySteps`) via `StepLibrary` trait
- Codegen (PerScenario) and programmatic tests in a single project
- Cross-feature tag filtering with `@smoke` and `not @inventory`

### E-commerce CLI (Embedded Runner)

See [`examples/ecommerce-cli/`](examples/ecommerce-cli/) -- standalone CLI runner:

- `async fn main` entry point embedding the moonspec runner
- Manual `PrettyFormatter` wiring from `RunResult`
- CLI argument handling for feature file paths
- Exit code semantics (1 on failures or undefined steps)

## Architecture

```
                    .feature files
                         |
          +--------------+--------------+
          |                             |
          v                             v
   +------+------+              +------+------+
   |   codegen   |              |   gherkin   |  (parser)
   +------+------+              +------+------+
          |                             |
    _test.mbt files            GherkinDocument
    (calls runner)                      |
                                +-------+-------+
                                |               |
                                v               v
                          FeatureCache    compile_pickles
                          (parse once)    (flatten/expand)
                                |               |
                                v               v
                          +-----+-------+  PickleFilter
                          |   runner    |  (tags/names)
                          +-----+-------+
                                |
                           World + Setup
                           (StepRegistry + ParamTypeRegistry)
                           cucumber-expressions
                                |
                                v
                         +------+------+
                         |   executor  |
                         +------+------+
                                |
                           RunResult
                                |
                    +-----------+-----------+
                    |           |           |
                    v           v           v
                 Pretty     Messages     JUnit
                (console)   (NDJSON)     (XML)
```

## Packages

| Package | Description |
|---------|-------------|
| `moonrockz/moonspec` | Top-level facade -- re-exports `World`, `Hooks`, `StepLibrary`, `StepDef`, `Ctx`, `MoonspecError`, `run`, `run_or_fail` |
| `moonrockz/moonspec/core` | World, Hooks, StepLibrary traits, Setup, StepRegistry, ParamTypeRegistry, StepDef, Ctx, MoonspecError |
| `moonrockz/moonspec/runner` | Feature/scenario executor with tag filtering and parallel support |
| `moonrockz/moonspec/format` | Formatter trait + Pretty, Messages, JUnit implementations |
| `moonrockz/moonspec/codegen` | Generate `_test.mbt` runner tests from Gherkin features |

Users should import `moonrockz/moonspec` and reference types via `@moonspec.World`,
`@moonspec.run_or_fail`, etc. The sub-packages are implementation details.

## Dependencies

| Package | Purpose |
|---------|---------|
| [moonrockz/gherkin](https://mooncakes.io/docs/#/moonrockz/gherkin/) | Gherkin parser |
| [moonrockz/cucumber-expressions](https://mooncakes.io/docs/#/moonrockz/cucumber-expressions/) | Step pattern matching |
| [moonrockz/cucumber-messages](https://mooncakes.io/docs/#/moonrockz/cucumber-messages/) | Cucumber Messages protocol |
| [TheWaWaR/clap](https://mooncakes.io/docs/#/TheWaWaR/clap/) | CLI argument parsing |
| [moonbitlang/x](https://mooncakes.io/docs/#/moonbitlang/x/) | Standard library extensions |
| [moonbitlang/async](https://mooncakes.io/docs/#/moonbitlang/async/) | Async execution primitives |
| [moonbitlang/regexp](https://mooncakes.io/docs/#/moonbitlang/regexp/) | Regular expressions |

## Development

```bash
moon check          # Type-check the project
moon test           # Run all tests
moon test --target js  # Run tests (required for async/parallel)
moon fmt            # Format code
moon info           # Update .mbti interface files
mise run test:unit  # Run tests via mise
```

## License

Apache-2.0 -- see [LICENSE](LICENSE) for details.
