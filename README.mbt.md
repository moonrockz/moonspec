# moonspec

BDD test framework for MoonBit with Gherkin and Cucumber Expressions.

## Installation

```bash
moon add moonrockz/moonspec
```

## Quick Start

Register step definitions and run Gherkin features:

```moonbit
let registry = @core.StepRegistry::new()

registry.given("a calculator", fn(_args) { /* setup */ })
registry.when("I add {int} and {int}", fn(args) {
  ignore(args)
})
registry.then("the result is {int}", fn(args) {
  ignore(args)
})

let feature = "Feature: Calculator\n  Scenario: Add\n    Given a calculator\n    When I add 2 and 3\n    Then the result is 5"
let result = @runner.run!(registry, [feature])
```

Or generate test files from `.feature` files with codegen:

```moonbit
let test_code = @codegen.generate_test_file(feature_content, "features/calc.feature")
// Produces async test blocks for each scenario
```

## Features

- **Gherkin parsing** -- Feature, Scenario, Scenario Outline, Background, Examples
- **Cucumber Expressions** -- `{int}`, `{float}`, `{string}`, `{word}`, custom types
- **Tag filtering** -- boolean tag expressions (`@smoke and not @slow`)
- **Scenario Outline expansion** -- parameterized scenarios from Examples tables
- **Formatters** -- Pretty (console), Cucumber Messages (NDJSON), JUnit XML
- **Codegen** -- generate `_test.mbt` from `.feature` files for `moon test`

## Packages

| Package | Description |
|---------|-------------|
| `moonrockz/moonspec/core` | Step arguments, registry, info types |
| `moonrockz/moonspec/runner` | Feature/scenario executor with tag filtering |
| `moonrockz/moonspec/format` | Formatter trait + Pretty, Messages, JUnit |
| `moonrockz/moonspec/codegen` | Generate test files from Gherkin features |

## License

Apache-2.0
