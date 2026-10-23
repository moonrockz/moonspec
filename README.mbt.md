# moonspec

BDD test framework for MoonBit with Gherkin and Cucumber Expressions.

## Sync and async execution

The sync APIs and async import migration below are unreleased pre-1.0 changes.
Use this checkout for them; published 0.11.0 does not contain these APIs.
The tested toolchain is moon/moonrun 0.1.20261012 with moonc and core
0.10.15+943464bfa, and `moonbitlang/async` 0.22.4.

| Execution | Package imported as `@moonspec` | Executed targets |
|---|---|---|
| Sync | `moonrockz/moonspec` | `wasm-gc`, `wasm`, `js`, `native` |
| Async | `moonrockz/moonspec/async` | `wasm`, `js`, `native` |

`wasm-gc` uses WebAssembly GC; `wasm` is the separate linear-memory backend.
Wasm-GC is sync-only until upstream async support is verified. LLVM remains
experimental and is outside this support matrix.

The root exports `run_sync` and `run_or_fail_sync` for ordinary `test` blocks.
`run_sync(factory, options)` returns `RunResult`; `run_or_fail_sync` raises a
structured failure report. Existing async callers change one package import:

```moonbit
import {
  "moonrockz/moonspec/async" @moonspec,
}
```

Keep existing `run` / `run_or_fail` calls, their async effects and test bodies.
The optional facade re-exports the shared types and sync APIs. Retain the
`moonbitlang/async` test-driver import for async tests. Root and runner no
longer export async aliases. Step handlers and all six hook handlers keep
their synchronous APIs.

Separate packages keep the root dependency graph free of the async runtime.
A virtual package cannot change a function's effect from sync to async, so
no virtual packages or implementation overrides are required.

`run_sync` rejects `parallel(true)` with
`SyncExecutionError::ParallelNotSupported` before World factories, hooks or events.
`max_concurrent` applies only to async parallel execution. Both execution modes
share failed-only retries and fresh Worlds per attempt. Dry-run suppresses
step handlers and case/step hooks, but before/after TestRun hooks still execute.

For generated sync tests, select `--execution sync` or config
`execution: "sync"`. CLI selection wins over merged config, then the `async`
default. Execution is independent of `mode` and `test_kind`. Sync generation
embeds the complete original source in `FeatureSource::Text` and emits ordinary
tests calling `run_or_fail_sync`. Async defaults retain `FeatureSource::File`,
`async test` and `run_or_fail`.

`Text` and `Parsed` do not read source files. File input and file/stderr output
depend on the host. Sync output write failures raise
`SyncExecutionError::HostIoFailed`; async output retains best-effort writes.
Raw Wasm and browser hosts must supply the standard MoonBit host ABI used by
the program. Embedding feature text does not provide a browser filesystem.

Run the real generated example from this repository root:

```sh
mise run examples:sync-wasm -- wasm-gc
mise run examples:sync-wasm  # all four sync targets
```

For one shared World, steps, hooks and options factory, use the unreleased
[target-policy guide](docs/guide/testing-strategies.md#one-setup-across-targets) and
[multi-target example](examples/multi-target/). Scalar execution still defaults
to async. Object policy opts into separate common/sync/async packages and
requires shared public factories in your own module; World fields stay private.
Nearer config replaces the whole policy, and CLI `--execution` wins. Fresh
options and stateful sinks are required on every call. Sync parallel mode
raises a typed error before World factories, hooks or events.
All policy `--moonx` rules reject until a
supporting registry release is verified; use the local CLI on `PATH`.

```sh
mise run examples:multi-target
```

The example verifies sync on four targets, async on three, both modes together
on native, safe regeneration and unchanged manual generation without writes.
The guide records pre-1.0 constructor and `GenerationError` migration.

## Installation

```bash
moon add moonrockz/moonspec
```

Add `moonrockz/moonspec` to the `import` array in your `moon.pkg`.

## Quick Start

Define a World, implement step definitions, and run against inline Gherkin:

```moonbit
struct CalcWorld { mut result : Int } derive(Default)

pub extend CalcWorld with Default::{default}

impl @moonspec.World for CalcWorld with configure(self, setup) {
  setup.given0("a calculator", fn() { self.result = 0 })
  setup.when2("I add {int} and {int}", fn(a : Int, b : Int) {
    self.result = a + b
  })
  setup.then1("the result should be {int}", fn(n : Int) raise {
    assert_eq(self.result, n)
  })
}

test "Feature: Calculator" {
  let feature =
    #|Feature: Calculator
    #|  Scenario: Addition
    #|    Given a calculator
    #|    When I add 2 and 3
    #|    Then the result should be 5
  @moonspec.run_or_fail_sync(CalcWorld::default,
    @moonspec.RunOptions::new([@moonspec.FeatureSource::Text("calc", feature)]),
  )
}
```

Each scenario gets a fresh World via `derive(Default)`. MoonBit structs are
reference types -- mutations in closures are visible across step handlers.

## Generate Tests with the CLI

The `moonspec` CLI writes the wiring for you. You write `.feature` files and
annotated step functions. The CLI then generates the World `configure` impl
and one `moon test` test per scenario. Build rules keep the generated tests in
step with the feature files.

You can use the CLI in two ways. Both run the same commands.

| | Installed CLI | moonx (no install) |
|---|---|---|
| Set up | `moon install moonrockz/moonspec/cmd/moonspec` | None. `moonx` comes with the MoonBit toolchain |
| Run a command | `moonspec <command>` | `moonx moonrockz/moonspec/cmd/moonspec@latest <command>` |
| Build rules | `moonspec gen build ... --apply` | `... gen build ... --apply --moonx` |

`moon install` puts `moonspec` in `~/.moon/bin`. With `--moonx`, the build rule
runs a pinned CLI version through `moonx`, so nobody who builds the project
needs to install the CLI.

The following workflow preserves the async generator default. For sync, use
the root package, omit the async test-driver import and pass `--execution sync`
to `gen tests` or `gen build`.

### 1. Add the dependencies

```bash
moon add moonrockz/moonspec
moon add moonbitlang/async
```

In the `moon.pkg` of the package that holds your steps (here `src`):

```
import {
  "moonrockz/moonspec/async" @moonspec,
}

import {
  "moonrockz/moonspec/format",
  "moonbitlang/async",
} for "wbtest"
```

### 2. Write a feature file

`features/calculator.feature`:

```gherkin
Feature: Calculator

  Scenario: Addition
    Given a calculator
    When I add 2 and 3
    Then the result should be 5
```

### 3. Write annotated step functions

`src/calc.mbt`:

```moonbit
#moonspec.world
struct CalcWorld {
  mut result : Int
} derive(Default)

pub extend CalcWorld with Default::{default}

#moonspec.given("a calculator")
fn given_calculator(world : CalcWorld) -> Unit {
  world.result = 0
}

#moonspec.when("I add {int} and {int}")
fn when_add(world : CalcWorld, a : Int, b : Int) -> Unit {
  world.result = a + b
}

#moonspec.then("the result should be {int}")
fn then_result(world : CalcWorld, expected : Int) -> Unit raise Error {
  assert_eq(world.result, expected)
}
```

### 4. Generate the World impl

```bash
moonspec gen steps
# or: moonx moonrockz/moonspec/cmd/moonspec@latest gen steps
```

This scans `src` (`-d` sets another directory) and writes
`src/calcworld_steps_gen.mbt`. The file implements `World` for `CalcWorld`
with one registration per annotated function:

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

Run it again when you add or change a step function. The parameters after the
world select the registration:

| Step function parameters | Registration |
|---|---|
| `(world)` or `(world, a : A, ...)` | `given0`, `given2`, ... (typed, up to 22) |
| `(world, a : A, ..., ctx : @moonspec.Ctx)` | `given1_ctx`, ... (typed plus `Ctx`, up to 22) |
| `(world, ctx : @moonspec.Ctx)` | `given("...", fn(ctx) ...)`, a handler that reads its own arguments |
| any of the above with `handler=true` in the attribute | `given("...", fn(ctx) ...)`, decoding typed values with no arity check; `T?` is `None` for a missing argument |

Typed values are decoded with `FromStepArg` (`Int`, `String`,
`@moonspec.DataTable`, ...). The attributes are `#moonspec.given`, `when`,
`then` and `step`.

### 5. Add build rules and generate the tests

```bash
moonspec gen build features/calculator.feature -w CalcWorld --apply
# or: moonx moonrockz/moonspec/cmd/moonspec@latest gen build \
#       features/calculator.feature -w CalcWorld --apply --moonx
```

This adds a `rule` and a `dev_build` entry to `src/moon.pkg` and writes
`src/calculator_feature_wbtest.mbt`, with one `async test` per scenario. From
then on, moon regenerates the test file before each `moon check`, `moon build`
and `moon test` when the feature file changes.

### 6. Run the tests

```bash
moon test
```

Each scenario is its own test, so `moon test -f "Feature: Calculator / Scenario: Add*"`
runs a subset and `moon test --outline` lists them.

Pass `--execution sync` to generate ordinary tests with complete embedded
source and `run_or_fail_sync`. Generated sync tests do not read the source file.

Commit the generated files. moon does not run build rules when your package is
a dependency of another module.

### CLI commands

| Command | Purpose |
|---|---|
| `gen steps [-d <dir>]` | Generate the World `configure` impl from `#moonspec.*` attributes |
| `gen build <features...> -w <World> [--apply] [--moonx] [-p <pkg>] [--test-kind <kind>] [--execution <execution>]` | Print or apply `moon.pkg` build rules; with `--apply`, also generate missing test files |
| `gen tests <features...> -w <World> -o <dir or file.mbt> [--test-kind <kind>] [--execution <execution>]` | Generate test files once, without build rules |
| `check <features...>` | Parse feature files and report errors |
| `version` | Print the CLI version |

Generated test files are white-box tests (`*_wbtest.mbt`) by default, so they
can use a private World impl, such as the one `gen steps` generates. Pass
`--test-kind test` (or set `test_kind: "test"` in `moonspec.json5`) for
black-box `*_test.mbt` files; these see only the package's public API. An
`-o` value that ends in `.mbt` is the exact file name. A `moonspec.json5`
file can set `world`, the codegen `mode` and other defaults; see
[Config File](#config-file).

## Features

- **World trait** -- per-scenario state with `derive(Default)`
- **StepLibrary trait** -- composable, reusable step groups
- **Cucumber Expressions** -- 11 built-in parameter types, custom typed handles, and capture decoders
- **Expression tools** -- registry-aware expression factory and candidate generator
- **Gherkin** -- Feature, Scenario, Scenario Outline, Background, Rules, Data Tables, Doc Strings
- **Markdown with Gherkin** -- `.feature.md` files are parsed as [MDG](https://github.com/cucumber/gherkin/blob/main/MARKDOWN_WITH_GHERKIN.md)
- **Lifecycle hooks** -- before/after for test run, test case, and test step
- **Tag filtering** -- boolean expressions (`@smoke and not @slow`)
- **Retries** -- `@retry(N)` tags or global config
- **Dry-run** -- validate wiring without execution
- **Skip** -- `@skip` / `@ignore` with optional reason
- **Parallel execution** -- bounded concurrency via `@async.all()`
- **Attachments** -- text, binary, or URL on steps and hooks
- **Structured errors** -- `run_or_fail` with snippets and suggestions
- **Codegen** -- generate `moon test` runners from `.feature` and `.feature.md` files
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

## Typed parameters and expression tools

Define custom domain values with `setup.define_param_type1` or composable
`@moonspec.Captures` decoders through `setup.define_param_type_with`. Retrieve
values with `ctx[index].get(handle)`:

```moonbit
let color : @moonspec.ParameterType[String] = setup.define_param_type1(
  "color", ["red|blue"], fn(text) { text },
)
setup.given("I pick {color}", fn(ctx) raise {
  assert_eq(ctx[0].get(color), "red")
})
```

The expression factory and generator are available through the same setup,
using its registered parameter types:

```moonbit
let factory = setup.expression_factory()
let expression = factory.create_expression("I pick {color}")
let candidates = setup.expression_generator().generate_expressions("I pick red")
// candidates[0].source() is "I pick {color}".
```

The factory creates expression objects for validation and explicit matching.
Anchored patterns and `/.../` patterns create regex objects; other patterns
create Cucumber Expressions. The generator returns candidates and parameter
metadata, honoring custom types' `use_for_snippets` flags. Choose a candidate's
`source()` to register a Cucumber step pattern.

`ParameterType`, `Captures`, `Captures1`, `ExpressionFactory`,
`CucumberExpressionGenerator`, `StepExpression`, `GeneratedExpression`, `Match`,
and the expression/parameter error types are re-exported by `@moonspec`.
Step registration currently accepts Cucumber Expressions, and automatic
undefined-step snippets use moonspec's built-in inference. The factory and
generator are exposed for users' own tools and workflows.

See the [expression tools guide](https://github.com/moonrockz/moonspec/blob/main/docs/guide/step-definitions.md#expression-tools)
for full examples.

## Step Registration

Register steps inside `World::configure` using typed arity-suffixed methods.
The numeric suffix indicates how many parameters the handler takes:

```moonbit
setup.given0("a calculator", fn() { self.result = 0 })
setup.given1("a user named {string}", fn(name : String) { self.user = name })
setup.when2("I add {int} and {int}", fn(a : Int, b : Int) { self.result = a + b })
setup.then1("the result should be {int}", fn(n : Int) raise { assert_eq(self.result, n) })
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
| `parallel(Bool)` | `false` | Async parallel execution; sync rejects true before effects |
| `max_concurrent(Int)` | `4` | Max scenarios in async parallel mode only |
| `tag_expr(String)` | `""` | Boolean tag filter expression |
| `scenario_name(String)` | `""` | Filter scenarios by name |
| `retries(Int)` | `0` | Global retry count for failed scenarios |
| `dry_run(Bool)` | `false` | Validate wiring without execution |
| `skip_tags(Array[String])` | `["@skip", "@ignore"]` | Tags that skip scenarios |
| `add_sink(&MessageSink)` | -- | Add a formatter for envelope output |
| `add_formatter(sink, dest)` | -- | Register formatter with output destination |
| `clear_sinks()` | -- | Remove all sinks and formatters |

Feature sources: `FeatureSource::Text(uri, content)` for inline Gherkin,
`FeatureSource::File(path)` for host-dependent file reads, and
`FeatureSource::Parsed(uri, feature)` for a parsed feature without a source read.

## Formatters

Three built-in formatters (all implement `MessageSink`):

- **Pretty** -- `@format.PrettyFormatter::new()` -- colored console output
- **JUnit** -- `@format.JUnitFormatter::new()` -- XML for CI
- **Messages** -- `@format.MessagesFormatter::new()` -- Cucumber Messages NDJSON

Register with a destination:

```moonbit
options.add_formatter(@format.PrettyFormatter::new(), @moonspec.OutputDest::Stdout)
options.add_formatter(@format.JUnitFormatter::new(), @moonspec.OutputDest::File("report.xml"))
```

Output destinations: `@moonspec.OutputDest::Stdout`, `@moonspec.OutputDest::Stderr`, `@moonspec.OutputDest::File(path)`.

When no formatters are configured, defaults to pretty output on stdout.

## Tag Filtering

```moonbit
opts.tag_expr("@smoke")                // only @smoke
opts.tag_expr("@smoke and not @slow")  // boolean operators
opts.tag_expr("@smoke or @regression") // either tag
```

## Retrying, Dry-Run, Skip

**Retrying** -- global or per-scenario `@retry(N)` tag (overrides global).
Both sync and async retry only Failed scenarios, never Undefined, Pending or
Skipped. Each retry creates a fresh World:

```moonbit
opts.retries(2)  // retry failed scenarios up to 2 times
```

**Dry-run** -- validate step wiring without execution. Matched steps report
as `Skipped("dry run")`, undefined steps report with snippets. Before/after
TestRun hooks still execute; case/step hooks and handlers do not. Dry-run never
retries:

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
  execution: "async",    // default; choose "sync" for embedded ordinary tests
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
| `moonrockz/moonspec` | Sync facade: `World`, `Setup`, `Ctx`, `RunOptions`, `run_sync`, `run_or_fail_sync` |
| `moonrockz/moonspec/async` | Optional facade: root exports plus async `run`, `run_or_fail` and parallel scheduling |
| `moonrockz/moonspec/core` | World, Setup, HookRegistry, StepRegistry, Ctx |
| `moonrockz/moonspec/runner` | Shared sync executor, tag filtering, retries, hooks and results |
| `moonrockz/moonspec/format` | Pretty, Messages, JUnit formatters |
| `moonrockz/moonspec/codegen` | Generate test files from Gherkin features |
| `moonrockz/moonspec/config` | Configuration parsing (moonspec.json5) |
| `moonrockz/moonspec/scanner` | `#moonspec.*` attribute scanner for `gen steps` |
| `moonrockz/moonspec/cli` | CLI implementation |
| `moonrockz/moonspec/cmd/moonspec` | CLI executable (`moonspec`) |

## Documentation

See the [sync execution and migration guide](https://github.com/moonrockz/moonspec/blob/main/docs/guide/testing-strategies.md#sync-execution-and-target-support)
and the [generated sync-wasm example](https://github.com/moonrockz/moonspec/tree/main/examples/sync-wasm).

Full docs, CLI reference, architecture, and examples:
<https://moonrockz.github.io/moonspec/>, or
[github.com/moonrockz/moonspec](https://github.com/moonrockz/moonspec)

Upgrading from 0.10.x? See the
[0.11.0 migration guide](https://github.com/moonrockz/moonspec/blob/main/docs/migrations/v0.11.0.md).

## License

Apache-2.0
