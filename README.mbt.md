# moonspec

BDD test framework for MoonBit with Gherkin and Cucumber Expressions.

## Installation

```bash
moon add moonrockz/moonspec
```

## Quick Start

Define a World struct, implement step definitions, and run:

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

Each scenario gets a fresh World instance via `derive(Default)` for state isolation.

## Features

- **World trait** -- per-scenario state isolation following cucumber-rs patterns
- **StepLibrary trait** -- composable, reusable step definition groups
- **StepDef type** -- first-class step definitions you can inspect, test, and pass around
- **Structured errors** -- `MoonspecError` hierarchy with `run_or_fail` throwing variant
- **Undefined step diagnostics** -- copy-paste snippets and "did you mean?" suggestions
- **Lifecycle hooks** -- `before_test_case`, `after_test_case`, `before_test_step`, `after_test_step`, `before_test_run`, `after_test_run`
- **Gherkin parsing** -- Feature, Scenario, Scenario Outline, Background, Rules, Data Tables, Doc Strings
- **Cucumber Expressions** -- type-safe step matching with 11 built-in types (`{int}`, `{float}`, `{double}`, `{long}`, `{byte}`, `{short}`, `{bigdecimal}`, `{biginteger}`, `{string}`, `{word}`) plus custom parameter types with transformers
- **Tag filtering** -- boolean tag expressions (`@smoke and not @slow`)
- **Scenario Outline expansion** -- parameterized scenarios from Examples tables
- **Background steps** -- shared Given setup across scenarios
- **Async/parallel execution** -- concurrent feature processing with bounded concurrency
- **Codegen** -- generate `_test.mbt` runner tests from `.feature` files
- **Formatters** -- Pretty (console), Cucumber Messages (NDJSON), JUnit XML (CI)

## Packages

| Package | Description |
|---------|-------------|
| `moonrockz/moonspec` | Top-level facade -- `World`, `Setup`, `Ctx`, `RunOptions`, `run`, `run_or_fail` |
| `moonrockz/moonspec/core` | World trait, Setup facade, HookRegistry, StepRegistry, Ctx types |
| `moonrockz/moonspec/runner` | Feature/scenario executor with tag filtering and parallel support |
| `moonrockz/moonspec/format` | Formatter trait + Pretty, Messages, JUnit implementations |
| `moonrockz/moonspec/codegen` | Generate test files from Gherkin features |

## Documentation

Full documentation with CLI reference, architecture, and examples:
[github.com/moonrockz/moonspec](https://github.com/moonrockz/moonspec)

## License

Apache-2.0
