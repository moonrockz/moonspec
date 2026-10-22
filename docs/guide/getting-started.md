# Getting Started with moonspec

moonspec is a BDD (Behavior-Driven Development) test framework for [MoonBit](https://www.moonbitlang.com/). It brings Gherkin feature files and Cucumber Expressions to MoonBit, letting you describe application behavior in plain English and verify it with executable step definitions.

This guide starts with the root synchronous API. The later codegen walkthrough
keeps the async generator default. These execution changes are unreleased;
use a local checkout as described in [sync execution](testing-strategies.md#sync-execution-and-target-support).

## Prerequisites

- [MoonBit toolchain](https://www.moonbitlang.com/download/) installed (`moon` CLI available)
- An existing MoonBit project (create one with `moon new my-project` if needed)
- moon/moonrun 0.1.20261012 and moonc/core 0.10.15+943464bfa for the tested setup
- Node.js only when running the JavaScript target

## Step 1: Install moonspec

Add moonspec as a dependency to your project:

```sh
moon add moonrockz/moonspec
```

Sync tests need no async test-driver import. For the optional async workflow,
add `moonbitlang/async` and import `"moonrockz/moonspec/async" @moonspec` instead.
For unreleased sync APIs, use the local `moon.work` from the
[sync-wasm example](../../examples/sync-wasm/); `moon add` alone selects a
published version.

Then add `moonrockz/moonspec` to the `import` list in the `moon.pkg` file for the package where your tests will live:

```
import {
  "moonrockz/moonspec",
}
```

## Step 2: Write a Feature File

Feature files describe the behavior you want to test using Gherkin syntax. Create a `features/` directory in your project and add a file called `calculator.feature`:

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
```

Each **Feature** groups related scenarios. A **Background** runs before every scenario. Each **Scenario** describes a concrete example with **Given** (setup), **When** (action), and **Then** (assertion) steps.

## Step 3: Create a World Struct

The World struct holds per-scenario state. moonspec creates a fresh instance for each scenario, so every scenario starts with a clean slate. Define it with `derive(Default)`:

```moonbit
struct CalcWorld {
  mut result : Int
} derive(Default)

pub extend CalcWorld with Default::{default}
```

`derive(Default)` is required -- moonspec calls `CalcWorld::default()` to create a new instance before each scenario runs. The `pub extend` line makes `CalcWorld::default` a regular method, so you can pass it as the World factory. Without it, current MoonBit versions warn that the method is "implicitly promoted" from the `Default` impl. Because MoonBit structs are reference types, mutations made by step closures are visible to all subsequent steps within the same scenario.

## Step 4: Implement the World Trait

The `@moonspec.World` trait has a single method, `configure`, where you register your step definitions. Each step maps a Cucumber Expression pattern to a handler function:

```moonbit
impl @moonspec.World for CalcWorld with configure(self, setup) {
  // Given steps set up initial state
  setup.given("a calculator", fn(_ctx) { self.result = 0 })

  // When steps perform actions
  setup.when("I add {int} and {int}", fn(ctx) {
    match (ctx[0], ctx[1]) {
      (
        { value: @moonspec.StepValue::IntVal(a), .. },
        { value: @moonspec.StepValue::IntVal(b), .. },
      ) => self.result = a + b
      _ => ()
    }
  })

  setup.when("I subtract {int} from {int}", fn(ctx) {
    match (ctx[0], ctx[1]) {
      (
        { value: @moonspec.StepValue::IntVal(a), .. },
        { value: @moonspec.StepValue::IntVal(b), .. },
      ) => self.result = b - a
      _ => ()
    }
  })

  // Then steps verify results (note `raise` for assertions)
  setup.then("the result should be {int}", fn(ctx) raise {
    match ctx[0] {
      { value: @moonspec.StepValue::IntVal(expected), .. } =>
        assert_eq(self.result, expected)
      _ => ()
    }
  })
}
```

Key things to notice:

- The `self` parameter is the World instance. Closures capture it, sharing state between steps.
- `setup.given(...)`, `setup.when(...)`, and `setup.then(...)` register step handlers.
- `{int}`, `{string}`, `{float}`, and `{word}` are built-in Cucumber Expression parameter types.
- Step handlers that perform assertions use `fn(ctx) raise { ... }` so they can raise errors.

## Step 5: Understanding StepArg and StepValue

When a step pattern contains parameters like `{int}` or `{string}`, moonspec extracts them and passes them to your handler through the `Ctx` object. Access arguments by index:

```moonbit
ctx[0]  // First captured parameter (a StepArg)
ctx[1]  // Second captured parameter
```

Each `StepArg` is a struct with two fields:

- `value` -- a `StepValue` enum variant with the typed value
- `raw` -- the original matched text as a `String`

Use pattern matching to destructure the value:

```moonbit
// Single argument
match ctx[0] {
  { value: @moonspec.StepValue::IntVal(n), .. } => {
    // n is an Int
  }
  _ => ()
}

// String argument
match ctx[0] {
  { value: @moonspec.StepValue::StringVal(s), .. } => {
    // s is a String (matched with quotes, e.g., "hello")
  }
  _ => ()
}

// Multiple arguments at once
match (ctx[0], ctx[1]) {
  (
    { value: @moonspec.StepValue::IntVal(a), .. },
    { value: @moonspec.StepValue::IntVal(b), .. },
  ) => {
    // a and b are both Int
  }
  _ => ()
}
```

The `..` in the pattern match ignores the `raw` field. The common `StepValue` variants are:

| Cucumber Expression | StepValue variant  | MoonBit type |
|---------------------|--------------------|--------------|
| `{int}`             | `IntVal(n)`        | `Int`        |
| `{float}`           | `FloatVal(f)`      | `Double`     |
| `{string}`          | `StringVal(s)`     | `String`     |
| `{word}`            | `WordVal(s)`       | `String`     |

## Step 6: Write the Test

Now create a test file (the filename must end in `_test.mbt` or `_wbtest.mbt`). There are two ways to provide feature content.

### Option A: Inline Feature Text

Use multi-line string literals to embed the feature directly in your test file:

```moonbit
test "calculator" {
  let feature =
    #|Feature: Calculator
    #|
    #|  Background:
    #|    Given a calculator
    #|
    #|  Scenario: Addition
    #|    When I add 5 and 3
    #|    Then the result should be 8
    #|
    #|  Scenario: Subtraction
    #|    When I subtract 3 from 10
    #|    Then the result should be 7
  @moonspec.run_or_fail_sync(
    CalcWorld::default,
    @moonspec.RunOptions::new(
      [@moonspec.FeatureSource::Text("test://calculator", feature)],
    ),
  )
  |> ignore
}
```

The `FeatureSource::Text(uri, content)` variant takes:
- A URI string (can be any identifier, used in error messages)
- The feature content as a string

### Option B: Feature File on Disk

Point to the `.feature` file you created earlier:

```moonbit
test "calculator" {
  @moonspec.run_or_fail_sync(
    CalcWorld::default,
    @moonspec.RunOptions::new(
      [@moonspec.FeatureSource::File("features/calculator.feature")],
    ),
  )
  |> ignore
}
```

File reads depend on the host filesystem. Paths are resolved by that host
relative to its runtime working directory. Use inline text or generated sync
embedding to avoid reading the feature file.

In both cases:

- Root sync calls use ordinary `test` blocks.
- `run_or_fail_sync` runs the feature and raises a structured error if any scenario fails, is undefined, or is pending.
- `CalcWorld::default` is the factory function -- moonspec calls it to create a fresh World for each scenario.

## Step 7: Run the Test

Root sync tests run on `wasm-gc`, `wasm`, `js` and `native`. For example:

```sh
moon test --target js
```

If everything is wired up correctly, you will see output like:

```
Total tests: 1, passed: 1, failed: 0.
```

If a step is undefined (no matching step definition), moonspec will raise an error with a helpful message showing the unmatched step text and a suggested code snippet.

If an assertion fails, you will see a detailed error showing which scenario and step failed, along with the assertion message:

```
[moon/test] test ... ("calculator") failed: 1 failed, 2 total

1) Feature: Calculator / Scenario: Subtraction # features/calculator.feature:9
   ✔ Given a calculator
   ✔ When I subtract 3 from 10
   ✖ Then the result should be 7
       Step 'the result should be 7' (Then): ...
```

The report lists every step of each failed scenario, in the style of other
cucumber implementations: `✔` passed (green), `✖` failed (red), `?` undefined
or pending (yellow), `-` skipped (cyan). Feature files that do not parse are
listed too, with their line and the parser message. See
[Colors](configuration.md#colors) to turn colors off.

## Codegen Mode

For larger projects, manually writing test blocks and `configure` methods for every scenario gets tedious. The moonspec CLI generates this code from your feature files and step annotations.

### Get the CLI

You can use the CLI in two ways. Both run the same commands.

The registry commands below describe the released installation route. Until
these execution changes are released, build the checkout CLI with
`mise run build:cli` and use `_build/bin/moonspec` from the repository root.
The sync-wasm task uses that local binary.

**Installed CLI.** Install it once; `moon install` puts `moonspec` in `~/.moon/bin`:

```sh
moon install moonrockz/moonspec/cmd/moonspec
moonspec version
```

**moonx.** Run it from the registry without an install. `moonx` comes with the MoonBit toolchain:

```sh
moonx moonrockz/moonspec/cmd/moonspec@latest version
```

The commands below use `moonspec`. With moonx, replace `moonspec` with `moonx moonrockz/moonspec/cmd/moonspec@latest`.

### Imports for Generated Code

Async is the generator default. For that workflow, switch the package import
to the optional facade and retain the async test driver. The generated body
still uses `@moonspec.run_or_fail`:

```
import {
  "moonrockz/moonspec/async" @moonspec,
}

import {
  "moonrockz/moonspec/format",
  "moonbitlang/async",
} for "wbtest"
```

For generated sync tests, keep the root import, omit `moonbitlang/async` and
pass `--execution sync` to `gen tests` or `gen build`. They are ordinary tests
with complete embedded source and `run_or_fail_sync`. See the
[generated sync example](../../examples/sync-wasm/).

### Generating Step Definitions with Annotations

Instead of writing the `configure` method by hand, annotate standalone step functions with `#moonspec.*` attributes:

```moonbit
#moonspec.world
struct CalcWorld {
  mut result : Int
} derive(Default)

pub extend CalcWorld with Default::{default}

///|
#moonspec.given("a calculator")
fn given_calculator(world : CalcWorld) -> Unit {
  world.result = 0
}

///|
#moonspec.when("I add {int} and {int}")
fn when_add(world : CalcWorld, a : Int, b : Int) -> Unit {
  world.result = a + b
}

///|
#moonspec.then("the result should be {int}")
fn then_result(world : CalcWorld, expected : Int) -> Unit raise Error {
  assert_eq(world.result, expected)
}
```

Then run:

```sh
moonspec gen steps
```

This scans `src` (`-d` sets another directory) for `#moonspec.*` attributes and writes `src/calcworld_steps_gen.mbt`, which implements `configure` for `CalcWorld`:

```moonbit
// Generated by moonspec gen steps — DO NOT EDIT
#warnings("-unused_value")
impl @moonspec.World for CalcWorld with configure(self, setup) {
  setup.given0("a calculator", fn() {
    given_calculator(self)
  })
  setup.when2("I add {int} and {int}", fn(_arg0 : Int, _arg1 : Int) {
    when_add(self, _arg0, _arg1)
  })
  setup.then1("the result should be {int}", fn(_arg0 : Int) raise {
    then_result(self, _arg0)
  })
}
```

Run the command again when you add or change a step function. Step functions can also take `ctx : @moonspec.Ctx` as the last parameter, or only `Ctx` to read their own arguments; see [Step Function Shapes](step-definitions.md#step-function-shapes).

### Build Rules

Add `rule` and `dev_build` entries to `moon.pkg`. moon runs them before `moon check`, `moon build` and `moon test`, so the test files stay in step with the feature files. To write the entries for you, run:

```sh
moonspec gen build features/calculator.feature -w CalcWorld --apply
```

It adds missing entries to `src/moon.pkg`, updates the rule when execution
changes and generates test files that do not exist yet. Use `-p` for another
package:

```moonbit
rule(
  name: "moonspec-tests",
  command: "moonspec gen tests $input -w CalcWorld -o $output --execution async",
)

dev_build(
  rule: "moonspec-tests",
  input: "../features/calculator.feature",
  output: "calculator_feature_wbtest.mbt",
)
```

With moonx, add `--moonx`. The rule then runs a pinned CLI version, so nobody who builds the project needs an installed CLI:

```sh
moonx moonrockz/moonspec/cmd/moonspec@latest gen build \
  features/calculator.feature -w CalcWorld --apply --moonx
```

```moonbit
rule(
  name: "moonspec-tests",
  command: "moonx moonrockz/moonspec/cmd/moonspec@<version> gen tests $input -w CalcWorld -o $output --execution async",
)
```

Add one `dev_build` entry per feature file. To share one `rule` between
packages, declare it in `moon.mod`. Commit the generated files: moon does not
run `dev_build` steps when the package is used as a dependency. The older
`options("pre-build": [...])` form is deprecated.

### Generated Test Files

The build rule runs `moonspec gen tests`, which defaults to one `async test`
block per scenario. A sync rule pins `--execution sync` instead, embedding the
full source into ordinary tests. `src/calculator_feature_wbtest.mbt` looks like this:

```moonbit
// Generated by moonspec codegen — DO NOT EDIT
// Source: features/calculator.feature
// moonspec:hash:6a7ef305

async test "Feature: Calculator / Scenario: Addition" {
  let options = @moonspec.RunOptions::new([@moonspec.FeatureSource::File("features/calculator.feature")])
  options.scenario_name("Addition")
  options.add_formatter(@format.PrettyFormatter::new(), @moonspec.OutputDest::Stdout)
  @moonspec.run_or_fail(
    CalcWorld::default, options,
  )
}
```

Each scenario becomes its own test, so `moon test` reports pass/fail at the scenario level.

You can also run `gen tests` by hand, without build rules:

```sh
moonspec gen tests features/calculator.feature -w CalcWorld -o src
```

It writes white-box tests (`*_wbtest.mbt`) by default, so they can use the private World impl that `gen steps` generates. `--test-kind test` (or `test_kind: "test"` in `moonspec.json5`) writes black-box `*_test.mbt` files, which see only the public API.

### Running Scenarios with moon test

Because each scenario is a normal `moon test` test, the native `moon test`
options work on scenarios:

```sh
# Run the scenarios whose test name matches a glob pattern
moon test --target js -f "Feature: Calculator / Scenario: Add*"

# List the scenarios that will run, without running them
moon test --target js --outline

# Run one scenario by its 0-based index in a generated file (see --outline)
moon test --target js src/calculator_feature_wbtest.mbt -i 1

# Also run scenarios that have a skip tag (@skip, @ignore, ...)
moon test --target js --include-skipped
```

Each row of a `Scenario Outline` is its own test, named
`Feature: <feature> / Scenario: <outline> (<header>=<value>, ...)`.

Scenarios with a skip tag get a `#skip("reason")` attribute, so `moon test`
reports them as skipped. In `per-feature` mode the whole feature is one test,
so these options work only at the feature level.

### Configuration with moonspec.json5

You can create a `moonspec.json5` file in your project root to avoid repeating CLI flags:

```json5
{
  "world": "CalcWorld",
  "mode": "per-scenario"
}
```

Options:

- `world` -- the World type name (required for `gen tests` and `gen build`)
- `execution` -- `"async"` by default; `"sync"` emits ordinary tests with embedded source. CLI `--execution` overrides merged config, then the default; this choice is independent of `mode` and `test_kind`
- `mode` -- `"per-scenario"` (default) generates one test per scenario; `"per-feature"` generates one test per feature file
- `steps.output` -- `"alongside"` (default) writes `<world>_steps_gen.mbt` next to the step functions; see the [configuration reference](configuration.md#steps-object) for the other strategies

## Where to Put Files

A typical project layout looks like this:

```
my-project/
  moon.mod
  moonspec.json5          # optional: codegen configuration
  features/
    calculator.feature    # Gherkin feature files
  src/
    moon.pkg              # root for sync; /async @moonspec for async
    world.mbt             # World struct + configure implementation
    calculator_wbtest.mbt # ordinary sync or async test blocks
```

Feature files live in `features/` by convention. Step definitions and World structs live in your source directory alongside the test files.

## State Isolation with derive(Default)

Every scenario gets a completely fresh World instance created by calling the `default()` constructor. This means:

- Scenarios are fully isolated from each other -- no shared mutable state leaks between them.
- You can safely use `mut` fields in your World struct without worrying about test ordering.
- Background steps run on the fresh instance before each scenario's own steps.

```moonbit
struct CalcWorld {
  mut result : Int    // Reset to 0 (default) for every scenario
} derive(Default)

pub extend CalcWorld with Default::{default}
```

This design follows the same principle as Cucumber's World pattern: each scenario is an independent test that sets up, acts, and asserts without depending on any other scenario's side effects.

## Next Steps

Now that you have a working moonspec test, here are some things to explore:

- **Scenario Outlines** -- parameterize scenarios with example tables
- **Data Tables** -- pass tabular data to steps using `DataTableVal`
- **Doc Strings** -- pass multi-line text to steps using `DocStringVal`
- **Tags** -- annotate scenarios with `@tagname` and filter with `options.tag_expr("@tagname")`
- **Hooks** -- run setup/teardown code with `setup.before_test_case(...)` and `setup.after_test_case(...)`
- **Custom Parameter Types** -- register your own types with `setup.add_param_type_strings(...)`
- **Parallel Execution** -- use the optional async facade and `options.parallel(true)` on wasm, js or native; sync rejects parallel mode

Run `mise run examples:sync-wasm -- wasm-gc` from this checkout for the complete
sync example. The [calculator example](../../examples/calculator/) keeps the
async workflow executable. See [sync execution](testing-strategies.md#sync-execution-and-target-support) for the full
target matrix, import migration and host ABI limits.
