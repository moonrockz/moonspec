# moonspec

[![CI](https://github.com/moonrockz/moonspec/actions/workflows/ci.yml/badge.svg)](https://github.com/moonrockz/moonspec/actions/workflows/ci.yml)

**BDD test framework for MoonBit** with Gherkin and Cucumber Expressions.

moonspec brings Behavior-Driven Development to [MoonBit](https://www.moonbitlang.com/).
Write specifications in Gherkin, match steps with Cucumber Expressions, and run
them natively with `moon test` or via the programmatic Runner API.

## Features

- **Gherkin parsing** -- Feature, Scenario, Scenario Outline, Background, Rules,
  Examples, Data Tables, Doc Strings
- **Cucumber Expressions** -- type-safe step matching with `{int}`, `{float}`,
  `{string}`, `{word}`, and custom parameter types
- **Tag filtering** -- boolean tag expressions (`@smoke and not @slow`)
- **Scenario Outline expansion** -- parameterized scenarios from Examples tables
- **Background steps** -- shared setup across scenarios
- **Pluggable formatters** -- Pretty (console), Cucumber Messages (NDJSON),
  JUnit XML (CI integration)
- **Codegen** -- generate `_test.mbt` files from `.feature` files for native
  `moon test` integration
- **Event-driven architecture** -- formatters receive lifecycle events during
  execution

## Quick Start

### Installation

```bash
moon add moonrockz/moonspec
```

### Mode 1: Codegen (Recommended)

Generate MoonBit test files from Gherkin features for native `moon test`:

```moonbit
// Use the codegen package to generate _test.mbt from .feature files
let content = @codegen.generate_test_file(feature_content, "features/calculator.feature")
// Write `content` to a _test.mbt file, then run `moon test`
```

### Mode 2: Runner API

Register steps and execute features programmatically:

```moonbit
let registry = @core.StepRegistry::new()

registry.given("a calculator", fn(_args) { /* setup */ })
registry.when("I add {int} and {int}", fn(args) {
  // args[0] is IntArg(a), args[1] is IntArg(b)
  ignore(args)
})
registry.then("the result is {int}", fn(args) {
  // assert the result
  ignore(args)
})

let feature_content = "Feature: Calculator\n  Scenario: Add\n    Given a calculator\n    When I add 2 and 3\n    Then the result is 5"
let result = @runner.run!(registry, [feature_content])
```

### Mode 3: CLI

```bash
moon run src/cmd/main
```

## Architecture

```
                    .feature files
                         |
                         v
                  +------+------+
                  |   gherkin   |  (parser)
                  +------+------+
                         |
              GherkinDocument
                         |
          +--------------+--------------+
          |                             |
          v                             v
   +------+------+              +------+------+
   |   codegen   |              |   runner    |
   +------+------+              +------+------+
          |                       |         |
    _test.mbt files        StepRegistry  tag filter
                              |         |
                         cucumber-    outline
                         expressions  expansion
                              |         |
                              v         v
                         +----+---------+----+
                         |     executor      |
                         +----+---------+----+
                              |
                         RunResult
                              |
                    +---------+---------+
                    |         |         |
                    v         v         v
                 Pretty   Messages   JUnit
                (console)  (NDJSON)   (XML)
```

## Dependencies

| Package | Purpose |
|---------|---------|
| [moonrockz/gherkin](https://mooncakes.io/docs/#/moonrockz/gherkin/) | Gherkin parser |
| [moonrockz/cucumber-expressions](https://mooncakes.io/docs/#/moonrockz/cucumber-expressions/) | Step pattern matching |
| [moonrockz/cucumber-messages](https://mooncakes.io/docs/#/moonrockz/cucumber-messages/) | Cucumber Messages protocol |
| [moonbitlang/x](https://mooncakes.io/docs/#/moonbitlang/x/) | Standard library extensions |
| [moonbitlang/async](https://mooncakes.io/docs/#/moonbitlang/async/) | Async execution primitives |
| [moonbitlang/regexp](https://mooncakes.io/docs/#/moonbitlang/regexp/) | Regular expressions |

## Development

```bash
moon check          # Type-check the project
moon test           # Run all tests
moon fmt            # Format code
moon info           # Update .mbti interface files
mise run test:unit  # Run tests via mise
```

## License

Apache-2.0 -- see [LICENSE](LICENSE) for details.
