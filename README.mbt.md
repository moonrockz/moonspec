# moonspec

BDD test framework for MoonBit with Gherkin and Cucumber Expressions.

## Installation

```bash
moon add moonrockz/moonspec
```

Add `moonrockz/moonspec` to the `import` array in your `moon.pkg.json`.

## Quick Start

Define a World, implement step definitions, and run against inline Gherkin:

```moonbit
struct CalcWorld { mut result : Int } derive(Default)

impl @moonspec.World for CalcWorld with configure(self, setup) {
  setup.given0("a calculator", fn() { self.result = 0 })
  setup.when2("I add {int} and {int}", fn(a : Int, b : Int) {
    self.result = a + b
  })
  setup.then1("the result should be {int}", fn(n : Int) {
    assert_eq!(self.result, n)
  })
}

async test "Feature: Calculator" {
  let feature =
    #|Feature: Calculator
    #|  Scenario: Addition
    #|    Given a calculator
    #|    When I add 2 and 3
    #|    Then the result should be 5
  @moonspec.run_or_fail(CalcWorld::default,
    @moonspec.RunOptions::new([@moonspec.FeatureSource::Text("calc", feature)]),
  )
}
```

Each scenario gets a fresh World via `derive(Default)`. MoonBit structs are
reference types -- mutations in closures are visible across step handlers.

## Features

- **World trait** -- per-scenario state with `derive(Default)`
- **StepLibrary trait** -- composable, reusable step groups
- **Cucumber Expressions** -- 11 built-in parameter types plus custom types
- **Gherkin** -- Feature, Scenario, Scenario Outline, Background, Rules, Data Tables, Doc Strings
- **Lifecycle hooks** -- before/after for test run, test case, and test step
- **Tag filtering** -- boolean expressions (`@smoke and not @slow`)
- **Retries** -- `@retry(N)` tags or global config
- **Dry-run** -- validate wiring without execution
- **Skip** -- `@skip` / `@ignore` with optional reason
- **Parallel execution** -- bounded concurrency via `@async.all()`
- **Attachments** -- text, binary, or URL on steps and hooks
- **Structured errors** -- `run_or_fail` with snippets and suggestions
- **Codegen** -- generate `_test.mbt` runners from `.feature` files
- **Formatters** -- Pretty, Cucumber Messages (NDJSON), JUnit XML

## Cucumber Expression Parameters

| Expression | MoonBit Type | StepValue Variant |
|---|---|---|
| `{int}` | `Int` | `IntVal(Int)` |
| `{float}` | `Double` | `FloatVal(Double)` |
| `{double}` | `Double` | `DoubleVal(Double)` |
| `{long}` | `Int64` | `LongVal(Int64)` |
| `{byte}` | `Byte` | `ByteVal(Byte)` |
| `{short}` | `Int` | `ShortVal(Int)` |
| `{bigdecimal}` | `@decimal.Decimal` | `BigDecimalVal(@decimal.Decimal)` |
| `{biginteger}` | `BigInt` | `BigIntegerVal(BigInt)` |
| `{string}` | `String` | `StringVal(String)` |
| `{word}` | `String` | `WordVal(String)` |
| `{}` | `String` | `AnonymousVal(String)` |

Custom types: `setup.add_param_type_strings(name, patterns, transformer?)`.

## Step Registration

Register steps inside `World::configure` using typed arity-suffixed methods.
The numeric suffix indicates how many parameters the handler takes:

```moonbit
setup.given0("a calculator", fn() { self.result = 0 })
setup.given1("a user named {string}", fn(name : String) { self.user = name })
setup.when2("I add {int} and {int}", fn(a : Int, b : Int) { self.result = a + b })
setup.then1("the result should be {int}", fn(n : Int) { assert_eq!(self.result, n) })
setup.step0("the system is ready", fn() { () }) // matches any keyword
```

The `_ctx` variants provide access to the full `Ctx` as the last parameter:

```moonbit
setup.given1_ctx("a user named {string}", fn(name : String, ctx : Ctx) {
  self.user = name
  self.feature = ctx.scenario().feature_name
})
```

Arities 0--22 are supported for all keywords (`given`, `when`, `then`, `step`).
The original `setup.given("pattern", fn(ctx) { ... })` form remains available
for advanced use cases.

## Ctx and StepArg

`Ctx` provides indexed access to matched arguments. Each `StepArg` has
`value` (typed `StepValue`) and `raw` (original text). Use struct
destructuring: `match ctx[0] { { value: IntVal(n), .. } => ... }`.

Other methods: `ctx.value(0)` returns `StepValue` directly,
`ctx.args()` returns `ArrayView[StepArg]`, `ctx.scenario()` returns
`ScenarioInfo` (feature name, scenario name, tags), `ctx.step()` returns
`StepInfo` (keyword, text).

## StepLibrary

Composable step groups via the `StepLibrary` trait. Returns `ArrayView[StepDef]`:

```moonbit
struct AccountSteps { world : BankWorld }

impl @moonspec.StepLibrary for AccountSteps with steps(self) {
  let defs : Array[@moonspec.StepDef] = [
    @moonspec.StepDef::given1("a balance of {int}", fn(n : Int) {
      self.world.balance = n
    }),
  ]
  defs[:]
}

// Compose libraries in World::configure:
setup.use_library(AccountSteps::new(self))
```

## Hooks

Register lifecycle hooks on `Setup`. "After" variants receive `HookResult`:

```moonbit
setup.before_test_case(fn(ctx) {
  println("Starting: " + ctx.scenario().scenario_name)
})
setup.after_test_case(fn(_ctx, result) {
  // result: HookResult::Passed or HookResult::Failed(Array[HookError])
  ignore(result)
})
```

All six: `before/after_test_run`, `before/after_test_case`,
`before/after_test_step`.

## Attachments

All context types (`Ctx`, `CaseHookCtx`, `StepHookCtx`, `RunHookCtx`)
support attachments:

```moonbit
ctx.attach("log output", "text/plain")
ctx.attach_bytes(png_bytes, "image/png", file_name="screenshot.png")
ctx.attach_url("https://example.com/report", "text/html")
```

## RunOptions

Configure a test run with `RunOptions::new(features)`:

| Method | Default | Description |
|---|---|---|
| `parallel(Bool)` | `false` | Enable parallel scenario execution |
| `max_concurrent(Int)` | `4` | Max concurrent scenarios when parallel |
| `tag_expr(String)` | `""` | Boolean tag filter expression |
| `scenario_name(String)` | `""` | Filter scenarios by name |
| `retries(Int)` | `0` | Global retry count for failed scenarios |
| `dry_run(Bool)` | `false` | Validate wiring without execution |
| `skip_tags(Array[String])` | `["@skip", "@ignore"]` | Tags that skip scenarios |
| `add_sink(&MessageSink)` | -- | Add a formatter for envelope output |
| `add_formatter(sink, dest)` | -- | Register formatter with output destination |
| `clear_sinks()` | -- | Remove all sinks and formatters |

Feature sources: `FeatureSource::Text(uri, content)` for inline Gherkin,
`FeatureSource::File(path)` to load from disk.

## Formatters

Three built-in formatters (all implement `MessageSink`):

- **Pretty** -- `@format.PrettyFormatter::new()` -- colored console output
- **JUnit** -- `@format.JUnitFormatter::new()` -- XML for CI
- **Messages** -- `@format.MessagesFormatter::new()` -- Cucumber Messages NDJSON

Register with a destination:

```moonbit
options.add_formatter(&@format.PrettyFormatter::new(), @moonspec.Stdout)
options.add_formatter(&@format.JUnitFormatter::new(), @moonspec.File("report.xml"))
```

Output destinations: `@moonspec.Stdout`, `@moonspec.Stderr`, `@moonspec.File(path)`.

When no formatters are configured, defaults to pretty output on stdout.

## Tag Filtering

```moonbit
opts.tag_expr("@smoke")                // only @smoke
opts.tag_expr("@smoke and not @slow")  // boolean operators
opts.tag_expr("@smoke or @regression") // either tag
```

## Retrying, Dry-Run, Skip

**Retrying** -- global or per-scenario `@retry(N)` tag (overrides global).
Each retry creates a fresh World:

```moonbit
opts.retries(2)  // retry failed scenarios up to 2 times
```

**Dry-run** -- validate step wiring without execution. Matched steps report
as `Skipped("dry run")`, undefined steps report with snippets:

```moonbit
opts.dry_run(true)
```

**Skip** -- scenarios tagged `@skip` or `@ignore` are skipped by default.
Add a reason with `@skip("flaky on CI")`. Configure:

```moonbit
opts.skip_tags(["@skip", "@ignore", "@wip"])
```

## Config File

`moonspec.json5` controls codegen and runtime behavior:

```json5
{
  world: "MyWorld",
  mode: "per-scenario",  // or "per-feature", or per-file map
  steps: { output: "steps.mbt", exclude: ["features/wip/**"] },
  skip_tags: ["@skip", "@ignore"],
  formatters: [
    { type: "pretty", output: "stdout" },
    { type: "junit", output: "reports/results.xml" }
  ]
}
```

## Packages

| Package | Description |
|---|---|
| `moonrockz/moonspec` | Facade -- `World`, `Setup`, `Ctx`, `RunOptions`, `run`, `run_or_fail` |
| `moonrockz/moonspec/core` | World, Setup, HookRegistry, StepRegistry, Ctx |
| `moonrockz/moonspec/runner` | Executor with tag filtering and parallel support |
| `moonrockz/moonspec/format` | Pretty, Messages, JUnit formatters |
| `moonrockz/moonspec/codegen` | Generate test files from Gherkin features |
| `moonrockz/moonspec/config` | Configuration parsing (moonspec.json5) |
| `moonrockz/moonspec/scanner` | Feature file discovery and conflict detection |

## Documentation

Full docs, CLI reference, architecture, and examples:
[github.com/moonrockz/moonspec](https://github.com/moonrockz/moonspec)

## License

Apache-2.0
