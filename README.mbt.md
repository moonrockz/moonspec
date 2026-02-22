# moonspec

BDD test framework for MoonBit with Gherkin and Cucumber Expressions.

## Installation

```bash
moon add moonrockz/moonspec
```

## Quick Start

Write a Gherkin feature, register step definitions, and run:

```moonbit
async test "calculator" {
  let registry = @core.StepRegistry::new()
  let mut result_val = 0

  registry.given("a calculator", fn(_args) { result_val = 0 })
  registry.when("I add {int} and {int}", fn(args) {
    match (args[0], args[1]) {
      (@core.StepArg::IntArg(a), @core.StepArg::IntArg(b)) => result_val = a + b
      _ => ()
    }
  })
  registry.then("the result should be {int}", fn(args) raise {
    match args[0] {
      @core.StepArg::IntArg(expected) => assert_eq(result_val, expected)
      _ => ()
    }
  })

  let feature =
    "Feature: Calculator\n  Scenario: Addition\n    Given a calculator\n    When I add 2 and 3\n    Then the result should be 5"
  let result = @runner.run!(registry, [feature])
  assert_eq(result.summary.passed, 1)
}
```

## Features

- **Gherkin parsing** -- Feature, Scenario, Scenario Outline, Background, Rules, Data Tables, Doc Strings
- **Cucumber Expressions** -- type-safe step matching with `{int}`, `{float}`, `{string}`, `{word}`
- **Tag filtering** -- boolean tag expressions (`@smoke and not @slow`)
- **Scenario Outline expansion** -- parameterized scenarios from Examples tables
- **Background steps** -- shared Given setup across scenarios
- **Async/parallel execution** -- concurrent scenario processing
- **Codegen** -- generate `_test.mbt` from `.feature` files for `moon test`
- **Formatters** -- Pretty (console), Cucumber Messages (NDJSON), JUnit XML (CI)

## Packages

| Package | Description |
|---------|-------------|
| `moonrockz/moonspec/core` | StepRegistry, StepArg types, step matching |
| `moonrockz/moonspec/runner` | Feature/scenario executor with tag filtering |
| `moonrockz/moonspec/format` | Formatter trait + Pretty, Messages, JUnit |
| `moonrockz/moonspec/codegen` | Generate test files from Gherkin features |

## Documentation

Full documentation with CLI reference, architecture, and examples:
[github.com/moonrockz/moonspec](https://github.com/moonrockz/moonspec)

## License

Apache-2.0
