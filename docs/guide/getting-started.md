# Getting Started with moonspec

moonspec is a BDD (Behavior-Driven Development) test framework for [MoonBit](https://www.moonbitlang.com/). It brings Gherkin feature files and Cucumber Expressions to MoonBit, letting you describe application behavior in plain English and verify it with executable step definitions.

This guide walks you through writing your first moonspec test from scratch.

## Prerequisites

- [MoonBit toolchain](https://www.moonbitlang.com/download/) installed (`moon` CLI available)
- An existing MoonBit project (create one with `moon new my-project` if needed)
- Node.js runtime (moonspec tests require the `--target js` flag)

## Step 1: Install moonspec

Add moonspec as a dependency to your project:

```sh
moon add moonrockz/moonspec
```

You will also need the `moonbitlang/async` package (required for async tests):

```sh
moon add moonbitlang/async
```

Then add `moonrockz/moonspec` to the `import` list in the `moon.pkg.json` file for the package where your tests will live:

```json
{
  "import": [
    "moonrockz/moonspec"
  ]
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
```

`derive(Default)` is required -- moonspec calls `CalcWorld::default()` to create a new instance before each scenario runs. Because MoonBit structs are reference types, mutations made by step closures are visible to all subsequent steps within the same scenario.

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
async test "calculator" {
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
  @moonspec.run_or_fail(
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
async test "calculator" {
  @moonspec.run_or_fail(
    CalcWorld::default,
    @moonspec.RunOptions::new(
      [@moonspec.FeatureSource::File("features/calculator.feature")],
    ),
  )
  |> ignore
}
```

The path is relative to the package directory at runtime.

In both cases:

- Tests **must** be `async test` blocks.
- `run_or_fail` runs the feature and raises a structured error if any scenario fails, is undefined, or is pending.
- `CalcWorld::default` is the factory function -- moonspec calls it to create a fresh World for each scenario.

## Step 7: Run the Test

moonspec tests must be run with the JavaScript target:

```sh
moon test --target js
```

If everything is wired up correctly, you will see output like:

```
Total tests: 1, passed: 1, failed: 0.
```

If a step is undefined (no matching step definition), moonspec will raise an error with a helpful message showing the unmatched step text and a suggested code snippet.

If an assertion fails, you will see a detailed error showing which scenario and step failed, along with the assertion message.

## Codegen Mode

For larger projects, manually writing `async test` blocks and `configure` methods for every scenario gets tedious. moonspec includes a CLI tool that generates boilerplate from your feature files and step annotations.

### Generating Test Files

The `moonspec gen tests` command reads `.feature` files and generates one `async test` block per scenario:

```sh
moon run moonrockz/moonspec/cmd -- gen tests -w CalcWorld -o src features/calculator.feature
```

This produces a file like `src/calculator_feature_wbtest.mbt`:

```moonbit
// Generated by moonspec codegen -- DO NOT EDIT
// Source: features/calculator.feature

async test "Feature: Calculator / Scenario: Addition" {
  let options = @moonspec.RunOptions::new(
    [@moonspec.FeatureSource::File("features/calculator.feature")],
  )
  options.scenario_name("Addition")
  @moonspec.run_or_fail(CalcWorld::default, options)
  |> ignore
}

async test "Feature: Calculator / Scenario: Subtraction" {
  let options = @moonspec.RunOptions::new(
    [@moonspec.FeatureSource::File("features/calculator.feature")],
  )
  options.scenario_name("Subtraction")
  @moonspec.run_or_fail(CalcWorld::default, options)
  |> ignore
}
```

Each scenario becomes its own test, so `moon test` reports pass/fail at the scenario level.

### Generating Step Definitions with Annotations

Instead of writing the `configure` method by hand, you can annotate standalone step functions with `#moonspec.*` attributes:

```moonbit
#moonspec.world
struct CalcWorld {
  mut result : Int
} derive(Default)

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
moon run moonrockz/moonspec/cmd -- gen steps
```

This scans your source files for `#moonspec.*` attributes and generates the `configure` implementation automatically. The generated code wires each annotated function into the World trait with the correct argument extraction.

### Configuration with moonspec.json5

You can create a `moonspec.json5` file in your project root to avoid repeating CLI flags:

```json5
{
  "world": "CalcWorld",
  "mode": "per-scenario"
}
```

Options:

- `world` -- the World type name (required for `gen tests`)
- `mode` -- `"per-scenario"` (default) generates one test per scenario; `"per-feature"` generates one test per feature file
- `steps.output` -- `"generated"` (default) writes to a `*_steps_gen.mbt` file; `"alongside"` places it next to the source files

### Pre-build Hooks

For a fully automated workflow, add the codegen commands as pre-build hooks so generated files stay up to date whenever you build or test. Consult the MoonBit documentation for how to configure pre-build scripts in your `moon.pkg.json`.

## Where to Put Files

A typical project layout looks like this:

```
my-project/
  moon.mod.json
  moonspec.json5          # optional: codegen configuration
  features/
    calculator.feature    # Gherkin feature files
  src/
    moon.pkg.json         # imports moonrockz/moonspec
    world.mbt             # World struct + configure implementation
    calculator_wbtest.mbt # async test blocks (manual or generated)
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
- **Parallel Execution** -- run scenarios concurrently with `options.parallel(true)`

For a complete working example, see the `examples/calculator/` directory in the moonspec repository.
