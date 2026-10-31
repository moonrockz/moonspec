# Testing Strategies

This guide covers scenario selection, execution, retries and reporting.
Examples calling `run` or `run_or_fail` use `"moonrockz/moonspec/async" @moonspec`
and retain the async test-driver import. For ordinary tests, import the root
and use `run_sync` / `run_or_fail_sync`. These APIs are unreleased. The following
section gives the tested toolchain and full matrix.

To share World, steps, hooks and settings across generated target launchers,
use the [one-setup target-policy guide](testing-strategies.md#one-setup-across-targets) and runnable
[multi-target example](../../examples/multi-target/). A capable host can run
sync and async suites together. Scalar execution still defaults to async.

## Sync execution and target support

The sync APIs and async import migration on this page are unreleased pre-1.0
changes. Use this repository checkout and a local `moon.work` to try them.
Published 0.11.0 does not contain these APIs. Under the existing pre-1.0
policy, `mise run release:version` computes `v0.12.0` for this breaking change.
The module version remains unchanged until the normal release process.

### Supported targets

These targets execute scenarios and generated consumer tests. Compile-only
checks do not establish support.

| Backend | Root sync API | Optional async API | Test host |
|---|---|---|---|
| `wasm-gc` | Supported | Unavailable at compile time | moonrun |
| `wasm` | Supported | Supported | moonrun |
| `js` | Supported | Supported | Node.js |
| `native` | Supported | Supported | Native process |

`wasm-gc` uses WebAssembly GC. `wasm` is the separate linear-memory backend.
Wasm-GC remains sync-only until upstream async integration is verified.
LLVM is experimental and is not part of this support matrix.

Verification uses moon and moonrun 0.1.20261028, moonc and its core distribution
0.10.18+6c83a7f62, and `moonbitlang/async` 0.22.4. The JavaScript examples also
test the async facade with `moonbitlang/async` 0.22.7. Modules that build for
`wasm-gc` stay on async 0.22.5 or earlier: async 0.22.7 casts the core scheduler
with `%identity`, and a Wasm-GC module that reaches the scheduler fails
validation. Use that tested toolchain for
reproduction; a newer compiler and a mismatched core distribution are not the
same environment.

### Public packages and APIs

Import the normal root package for synchronous execution:

```moonbit
import {
  "moonrockz/moonspec",
}
```

Root and `moonrockz/moonspec/runner` expose these signatures, with `World`,
`RunOptions` and `RunResult` referring to their shared public types:

```moonbit
pub fn[W : World] run_sync(
  factory : () -> W, options : RunOptions,
) -> RunResult raise Error

pub fn[W : World] run_or_fail_sync(
  factory : () -> W, options : RunOptions,
) -> Unit raise Error
```

Use ordinary `test` blocks and the same World, step and hook definitions:

```moonbit
test "calculator" {
  let source =
    #|Feature: Calculator
    #|  Scenario: Addition
    #|    Given a calculator
    #|    When I add 2 and 3
    #|    Then the result should be 5
  let options = @moonspec.RunOptions::new([
    @moonspec.FeatureSource::Text("calculator.feature", source),
  ])
  @moonspec.run_or_fail_sync(CalculatorWorld::default, options)
}
```

The executable [sync-wasm example](../../examples/sync-wasm/) defines this
calculator World and uses the actual CLI to generate its tests. `run_sync`
returns results for inspection. `run_or_fail_sync` reports parse errors and
failed, undefined or pending scenarios with the existing
`MoonspecError::RunFailed` report. Configure/parse diagnostics retain their
existing error types.

### Async migration

Existing async consumers change their package import to:

```moonbit
import {
  "moonrockz/moonspec/async" @moonspec,
}
```

Keep the existing test body and calls to `@moonspec.run` and
`@moonspec.run_or_fail`. Their argument order, async effects and behavior are
unchanged:

```moonbit
pub async fn[W : World] run(
  factory : () -> W, options : RunOptions,
) -> RunResult

pub async fn[W : World] run_or_fail(
  factory : () -> W, options : RunOptions,
) -> Unit
```

Retain `moonbitlang/async` in the test imports for `async test` blocks.
The optional facade re-exports the root types and sync APIs, so World and
Setup definitions need no renaming. Root and runner no longer export async
`run` or `run_or_fail` aliases on any backend. On Wasm-GC, importing `/async`
fails target checking. It never substitutes a synchronous implementation.
The [calculator example](../../examples/calculator/) retains executable async
tests on the supported async targets.

Steps and all six lifecycle hooks still use synchronous handlers. Selecting
async execution adds scheduling, not a new async step or hook API.

### Why separate packages

The root and shared runner dependency graph excludes `moonbitlang/async`.
Only the optional `/async` package imports the async runtime. A module-level
async dependency may still be resolved for the module's other packages;
resolution does not mean it is reachable from a root consumer.

Separate packages make the effect and target boundary explicit. Conditional
imports are not supported by the tested build system. Virtual packages require
implementations to retain the interface's function effects, so they cannot
make one function synchronous on one target and asynchronous on another.
No virtual packages or consumer implementation overrides are required.

### Shared execution policy

`run_sync` and `run_or_fail_sync` reject `parallel(true)` with
`SyncExecutionError::ParallelNotSupported` before calling the factory,
dispatching hooks or emitting events. Leave `parallel` false for sync.
`max_concurrent` is relevant only to async parallel execution.

Both modes use the same failed-only retry loop. `retries(N)` sets the global
limit and `@retry(N)` overrides it. Every attempt creates a fresh World and
Setup. Undefined, Pending and Skipped scenarios do not retry. Summaries count
the final attempt; message envelopes retain attempt numbers and whether another
attempt will run.

Dry-run performs matching without invoking step handlers or case/step hooks.
Before/after TestRun hooks still run. Dry-run never retries, including decoder
failures. Skip tags take precedence over dry-run. Filtering, backgrounds,
outlines, typed parameters, attachments and failure reports share the same
execution engine.

### Generate sync tests

For a clean consumer, use a `moon.mod` like the example:

```moonbit
name = "example/sync-wasm"
version = "0.0.1"
import { "moonrockz/moonspec@0.11.0" }
source = "src"
```

Until release, add a consumer-local `moon.work` whose members are the path to
this repository checkout and `"."`. This resolves the module above to local
source instead of published 0.11.0. The committed sync-wasm example uses
`members = ["../..", "."]`. In `src/moon.pkg`, use:

```moonbit
import { "moonrockz/moonspec" }
import { "moonrockz/moonspec/format" } for "wbtest"
supported_targets = "wasm+wasm-gc+js+native"
```

Define the World and features as in the example. Build this checkout's CLI with
`mise run build:cli` from the repository root and add its `_build/bin` directory
to your `PATH`. From the consumer root, generate once or add a build rule:

```sh
moonspec gen tests features/calculator.feature -w CalculatorWorld -o src --execution sync
moonspec gen build features/calculator.feature -w CalculatorWorld --execution sync --apply
```

Set `execution: "sync"` or `execution: "async"` in `moonspec.json5` instead of
repeating the flag. Precedence is CLI `--execution`, then merged configuration,
then `async`. Execution is independent of `mode`, which selects per-scenario or
per-feature tests, and `test_kind`, which selects white-box or black-box tests.
Both execution choices work with all mode/kind combinations and Markdown
features. The [configuration reference](configuration.md#execution-string-or-object)
describes the flags and merge behavior.

Sync output contains ordinary test blocks calling `run_or_fail_sync`, using
`FeatureSource::Text(original_uri, complete_original_source)`. Embedding the
whole source preserves outlines, backgrounds, locations and source envelopes.
The original URI remains a diagnostic identifier, not a runtime read. No
separate embedding flag is needed. Add `moonrockz/moonspec/format` to the test
imports for generated formatters; no async test-driver import is needed.

The unchanged async default emits `async test`, `run_or_fail` and
`FeatureSource::File`. Use the `/async` facade and the async test-driver import
for that output. Build-rule commands retain the selected execution; rerun
`gen build --apply` after changing the config selection to update existing
rules. In this checkout, `--moonx` pins published `0.11.0`, which supports
async generation only. Its rules omit `--execution`; requesting sync fails
before writes and directs you to the locally built CLI without `--moonx`.
Regeneration updates both the canonical rule's CLI prefix and its execution
selection, preserving unrelated options and rules. Commit generated source,
since dependency builds do not run those rules.

For direct codegen API callers, `render_build_rules` now raises the typed
`BuildRuleError`. `UnsupportedExecution(version~)` rejects sync with a legacy
stable pin below `0.12.0`; `UnsupportedVersion(version~)` rejects unknown or
prerelease pins in either mode. Stable numeric pins from `0.12.0` use the
explicit execution selection contract. No newer registry release is required
to use this checkout's locally built CLI.

### Host I/O

`FeatureSource::Text` and `FeatureSource::Parsed` do not read source files.
Use them with in-memory message sinks when the host has no filesystem.
Generated sync tests remove the source-file dependency by embedding the source.
Generating or regenerating them still needs a host that can read the feature.

`FeatureSource::File` reads through host filesystem support. Read failures
produce structured `ParseErrorInfo`; failure-reporting APIs aggregate them into
`RunFailed`. File and stderr formatter destinations also depend on the host.
Sync write failures raise
`SyncExecutionError::HostIoFailed(operation~, path~, message~)`. Async output
retains its existing best-effort write behavior. Stdout uses MoonBit's standard
print facility.

moonrun supplies host services for both Wasm backends; Wasm-GC does not mean
I/O is unavailable. Raw Wasm and browser embedders must supply the standard
MoonBit host ABI imports used by the compiled program. Embedding feature text
does not remove every host import or promise a general browser filesystem.

### Reproduce the example

From the repository root, using the tested toolchain:

```sh
mise run examples:sync-wasm -- wasm-gc
mise run examples:sync-wasm
mise run test:compat-generated
mise run examples:test
```

The first command builds the checkout CLI, generates the sync tests and runs
exactly three passing ordinary tests on Wasm-GC. The second runs the same
example on all four sync targets. The generated-consumer gate checks actual
CLI output across mode and test-kind combinations. The shared example gate
keeps the async examples executable on JavaScript.

## One setup across targets

Define your World, steps, hooks and runtime settings once, then let the local
generator create separate sync and async test packages. This is an unreleased
pre-1.0 feature. Use the checkout CLI and runtime, as in the runnable
[multi-target example](../../examples/multi-target/). Published 0.11.0 does not
provide this contract, and no supporting registry policy release is assumed.

### Select execution by target

Scalar `execution: "async"` remains the default. Without `shared`, scalar
`"sync"` keeps ordinary same-package test generation. A scalar with `shared`
uses the shared packages. Existing scalar grouping and visibility choices
remain available. Target selection is opt-in:

```json5
{
  execution: {
    default: "async",
    targets: { "wasm-gc": "sync" },
  },
  shared: {
    package: "example/multi-target/definitions",
    world_factory: "world",
    options_factory: "options",
  },
  test_kind: "test",
}
```

`default` is required in an execution object. `targets` is optional and can be
empty. Its keys are `wasm`, `wasm-gc`, `js` and `native`; values are `sync` or
`async`. An override wins over `default`. Planning validates every supported
target, so an async default needs an explicit sync override for Wasm-GC even if
you are generating on native. Unsupported targets, unknown keys and async on
Wasm-GC reject the plan before writes. There is no fallback to sync.

The [target matrix and host limits](testing-strategies.md#sync-execution-and-target-support)
still apply. Root sync supports all four targets. Async supports Wasm,
JavaScript and native; LLVM remains experimental. Separate launcher packages
keep the selected Wasm-GC graph free of the async runtime. Excluding an async
declaration with `#cfg` does not remove its package import from that graph.
No virtual package or effect-changing implementation override is needed.

### Keep the shared package portable

`shared.package` names the consumer's own module root or a compiler-visible
subpackage. External shared-library packages are outside this contract. You
can still compose external StepLibraries inside your own World. Import the
portable root in the shared package, and make its World type, World impl and
factory functions public. Fields can remain private:

```moonbit
pub struct CounterWorld {
  priv mut count : Int
}

pub impl @moonspec.World for CounterWorld with fn configure(self, setup) {
  setup.given("a fresh counter", fn(_) raise { assert_eq(self.count, 0) })
}

pub extend CounterWorld with @moonspec.World::{configure}

pub fn world() -> CounterWorld { { count: 0 } }

pub fn options(sources : Array[@moonspec.FeatureSource]) -> @moonspec.RunOptions {
  let options = @moonspec.RunOptions(sources)
  options.retries(1)
  options.add_formatter(
    @format.MessagesFormatter::new(),
    @moonspec.OutputDest::Stdout,
  )
  options
}
```

The example imports `moonrockz/moonspec/format` for that formatter. Every
factory invocation must return fresh options and fresh stateful sinks. A
global options object or formatter would retain state across generated tests
and concurrent invocations. Configure steps and hooks in the World impl once.
Generated common options call the factory and apply config formatter,
skip-tag and color settings, then each launcher adds its scenario selection.

`wbtest` and `test` both work, as do per-scenario and per-feature grouping.
Shared launchers are separate packages: whitebox mode does not grant access
to a private World in the definition package. Keep legacy same-package
whitebox generation when a private World is required. With `shared`, the
generator uses the factory and does not require the legacy `world` type name.

Current Moon rejects `moon.mod.json` and `moon.pkg.json`. Run `moon fmt` to
migrate manifests to `moon.mod` and `moon.pkg` before shared generation. The
planner discovers the module's actual source directory; do not put shared
packages in compiler-hidden directories such as `_generated`.

### Hierarchy, suites and CLI precedence

For test generation, config discovery walks from the module root toward the
selected output package. At each directory, `.json5` overrides `.json`.
Nearer configs override ancestors; a missing field inherits. `execution` and
`shared` each replace the whole inherited field. Target maps do not deep-merge.
For example, a nearer `{ execution: { default: "sync" } }` discards the parent's
async default and overrides, while inheriting its entire `shared` field.

The schema permits such partial configs without a local `shared`. The CLI
validates the effective merged result: an execution object requires shared
factories after inheritance. `--config` bypasses discovery and uses that file
alone. CLI `--execution sync|async` replaces the whole execution policy after
merging; it retains an inherited `shared` field. Without `shared`, a scalar CLI
override follows legacy same-package generation.

Different suite directories can select different execution modes while
inheriting one shared setup. The example also generates a separate suite with
`--execution sync` and executes its sync tests together with the policy suite's
async tests on native. Target selection and grouping `mode` are independent.

Shared options default to sequential execution in both modes. To use bounded
async parallelism, select a separate explicit options factory for an async
suite, then set `parallel(true)` and `max_concurrent(n)` there. Do not enable
parallel globally in a factory used by sync launchers. Sync raises the typed
`SyncExecutionError::ParallelNotSupported` before World factories, hooks or events;
it never silently downgrades to sequential execution.
The options factory has already run to construct `RunOptions` at that point.

### Generate and regenerate

From the repository root:

```sh
mise run build:cli
export PATH="$PWD/_build/bin:$PATH"
cd examples/multi-target
moonspec gen tests features/counter.feature -o src/suite
moonspec gen build features/counter.feature --package src/suite
moonspec gen build features/counter.feature --package src/suite --apply
moon test src/suite/moonspec_gen/sync --target wasm-gc
moon test src/suite/moonspec_gen/async --target native
```

`gen tests` writes the planned shared tree beneath the output directory. Use
`--preview` to inspect it without writes. `gen build` previews by default;
`--apply` writes the same tree with executable regeneration rules. Complete
original feature text and URI are embedded in the common source package for
both modes. There are no runtime feature-file reads in these launchers.

The generator owns `moonspec_gen/manifest.json` and the recorded files in
`shared`, `sync` and `async`. It validates the full plan before writing,
rejects modified owned files, malformed ownership and unowned collisions, and
removes only unchanged stale files that its manifest records. It preserves
manual files, shared definitions and parent package metadata. Unchanged manual
generation preserves bytes and modification times. Unexpected host write
failures still report errors; generation does not promise rollback after such
a failure.

Generated per-package rules declare local outputs. They run the local native
CLI on `PATH` with validated `--refresh-output` paths so Moon discovers changed test
counts. This refresh is for generated rules. The native CLI serializes shared
writers with a temporary `.moonspec-generation.lock` directory in the consumer
root, covering validation through manifest publication. If a killed generator
leaves that directory behind, confirm no generator is running before removing
it; a contender times out after ten seconds. Automatic refresh rejects other
CLI backends before output writes because their filesystem adapters lack an
exclusive directory operation. Manual generation and preview remain available.
Keep the manifest and generated contents intact. Feature-body edits and existing grouping-config edits
regenerate when Moon runs. Rerun `gen build --apply` explicitly when changing
target sets, package structure, feature lists or test kind, or when adding or
removing config paths. Preview first when reviewing structural changes.

All shared-policy `--moonx` rules currently reject before writes. Registry
target-policy capability is separate from the scalar execution flag contract:
stable scalar pins below 0.12.0 preserve async defaults and reject sync;
stable numeric pins from 0.12.0 accept explicit scalar selection. That threshold
does not establish availability of a published policy-capable release. Do not
fetch an imagined version to try this example.

Embedded source avoids feature reads, but runtime file/stderr output still
needs host support. Raw Wasm and browser hosts must provide the standard
MoonBit host ABI. This feature adds no browser filesystem emulation. See
[host I/O](testing-strategies.md#host-io) for typed sync write failures and
the existing async best-effort output behavior.

### Source API migration

These pre-1.0 changes preserve scalar generated behavior but change source
constructors. `MoonspecConfig.execution` is now `ExecutionPolicy?` and
`CodegenConfig.execution` is `ExecutionPolicy`; wrap old modes with
`ExecutionPolicy::Scalar(ExecutionMode::Sync)` or `Scalar(Async)`. Both structs
also have `shared: SharedConfig?`; add `shared: None` to explicit legacy
record constructors. `SharedConfig` uses the source field `package_path` for
the JSON `package` key, plus `world_factory` and `options_factory`.

`generate_test_file` now raises `GenerationError::SharedGenerationRequired`
for shared or target-policy config. Handle its typed error, and use
`plan_shared_generation` for these configs rather than the single-file
renderer. The shared planner returns an opaque `GenerationPlan` whose
`files()` returns copies of planned path/content records.

The unchanged version task computes v0.12.0 for these unreleased breaking
changes. The module version remains unchanged until the release process;
this work does not publish a release or establish registry policy support.

## Tag Filtering

Tags are annotations on Features, Rules, and Scenarios. moonspec supports boolean tag expressions to select which scenarios run.

### Basics

Tags declared on a Feature are inherited by every Scenario inside it. A Scenario's effective tag set is the union of its own tags and all ancestor tags.

```gherkin
@smoke
Feature: User login

  @fast
  Scenario: Login with valid credentials
    # effective tags: @smoke, @fast
    Given a registered user
    When the user logs in
    Then login succeeds

  @slow
  Scenario: Login with expired session
    # effective tags: @smoke, @slow
    Given an expired session
    When the user logs in
    Then the session is renewed
```

### Tag Expressions

Pass a tag expression string to `opts.tag_expr()` to filter scenarios before execution:

```moonbit
let opts = @moonspec.RunOptions::new([
  @moonspec.FeatureSource::File("features/login.feature"),
])
opts.tag_expr("@smoke and not @slow")
let result = @moonspec.run(MyWorld::default, opts)
```

The expression language supports the following operators:

| Expression                     | Meaning                                   |
|-------------------------------|-------------------------------------------|
| `@smoke`                      | Scenarios tagged `@smoke`                 |
| `not @slow`                   | Scenarios *not* tagged `@slow`            |
| `@smoke and not @slow`        | Tagged `@smoke` but not `@slow`           |
| `@smoke or @regression`       | Tagged `@smoke` or `@regression` (or both)|
| `(@smoke or @fast) and not @wip` | Compound with parentheses              |

Operator precedence from lowest to highest: `or`, `and`, `not`. Use parentheses to override.

An empty expression matches all scenarios.

A malformed expression stops the run with a `TagExpressionError`, before any
scenario runs. Examples are `@smoke and` (missing operand), `and @smoke`
(operator in operand position), `@smoke @fast` (missing operator) and
`(@smoke or @fast` (missing `)`).

### Example: Cross-Feature Filtering

Tag expressions work across multiple feature files:

```moonbit
let opts = @moonspec.RunOptions::new([
  @moonspec.FeatureSource::File("features/cart.feature"),
  @moonspec.FeatureSource::File("features/checkout.feature"),
  @moonspec.FeatureSource::File("features/inventory.feature"),
])
opts.tag_expr("@smoke")
let result = @moonspec.run(MyWorld::default, opts)
// Only scenarios tagged @smoke from all three features
```

---

## Scenario Outlines

Scenario Outlines let you run the same scenario structure with different data. Placeholders in angle brackets are substituted with values from the Examples table.

### Basic Outline

```gherkin
Feature: Calculator

  Scenario Outline: Addition
    Given the calculator is reset
    When I add <a> and <b>
    Then the result is <sum>

    Examples:
      | a  | b  | sum |
      | 1  | 2  | 3   |
      | 10 | 20 | 30  |
      | -1 | 1  | 0   |
```

Each row in the Examples table produces a separate scenario at compile time. The generated scenario names include the parameter values for identification:

- `Addition (a=1, b=2, sum=3)`
- `Addition (a=10, b=20, sum=30)`
- `Addition (a=-1, b=1, sum=0)`

### Multiple Examples Blocks

A single Scenario Outline can have multiple Examples blocks. This is useful for grouping related data or applying different tags to subsets:

```gherkin
Feature: Checkout

  Scenario Outline: Apply discount
    Given a cart with total <total>
    When I apply coupon "<coupon>"
    Then the discount is <discount>

    @valid-coupons
    Examples: Valid coupons
      | total | coupon  | discount |
      | 100   | SAVE10  | 10       |
      | 200   | SAVE20  | 40       |

    @expired-coupons
    Examples: Expired coupons
      | total | coupon  | discount |
      | 100   | OLD50   | 0        |
```

Tags from Examples blocks are merged with Feature and Scenario tags. In the example above, the first two scenarios have the `@valid-coupons` tag and the third has `@expired-coupons`.

### How Substitution Works

Placeholders like `<a>` in step text are replaced literally with the corresponding cell value from each row. Substitution also applies inside DocStrings and DataTable arguments attached to steps.

Step definitions match against the substituted text, so a step definition matching `"I add {int} and {int}"` handles all rows of the Addition outline above.

---

## Parallel Execution

Both execution modes default to sequential scenarios. Enable parallel mode
only through the optional async facade. Sync rejects `parallel(true)` with
`SyncExecutionError::ParallelNotSupported` before World factories, hooks or events.
`max_concurrent` applies only to async parallel execution.

### Configuration

```moonbit
let opts = @moonspec.RunOptions::new([
  @moonspec.FeatureSource::File("features/cart.feature"),
  @moonspec.FeatureSource::File("features/checkout.feature"),
])
opts.parallel(true)          // enable concurrent execution
opts.max_concurrent(4)       // at most 4 scenarios at once (default: 4)
```

### Isolation

Each scenario receives a fresh World instance created by the factory function. Because worlds are never shared between concurrent scenarios, parallel execution is safe without additional synchronization.

```moonbit
// Each scenario gets its own EcomWorld via this factory
@moonspec.run_or_fail(EcomWorld::default, opts)
```

### Requirements

Parallel execution uses MoonBit's async runtime on `wasm`, `js` or `native`.
Import `"moonrockz/moonspec/async" @moonspec`, retain the `moonbitlang/async`
test-driver import and use an `async test`:

```moonbit
async test "parallel ecommerce tests" {
  let opts = @moonspec.RunOptions::new([
    @moonspec.FeatureSource::File("features/cart.feature"),
    @moonspec.FeatureSource::File("features/checkout.feature"),
  ])
  opts.parallel(true)
  opts.max_concurrent(8)
  @moonspec.run_or_fail(EcomWorld::default, opts) |> ignore
}
```

```bash
moon test --target js
```

JavaScript is one supported async target; `wasm` and `native` are also tested.
`wasm-gc` supports the root synchronous APIs only.

---

## Retrying Flaky Tests

Sync and async execution share the same retry loop. Sync retries require no
async runtime.

moonspec can automatically retry failed scenarios with a fresh World on each attempt.

### Global Retry

Set a global retry count that applies to all scenarios:

```moonbit
let opts = @moonspec.RunOptions::new([
  @moonspec.FeatureSource::File("features/flaky.feature"),
])
opts.retries(2) // retry failed scenarios up to 2 additional times
```

With `retries(2)`, a failing scenario gets up to 3 total attempts (1 original + 2 retries).

### Per-Scenario Retry

Use the `@retry(N)` tag to override the global setting for individual scenarios:

```gherkin
Feature: External API

  @retry(3)
  Scenario: Fetch exchange rates
    Given the API is available
    When I request exchange rates
    Then rates are returned

  @retry(0)
  Scenario: Validate cached response
    # This scenario never retries, even with a global retry setting
    Given a cached response
    When I validate the cache
    Then the cache is valid
```

The `@retry(N)` tag takes priority over the global `retries` value. Use `@retry(0)` to explicitly opt a scenario out of retries. The maximum allowed value is 100.

### How Retries Work

- **Fresh World per attempt.** Each retry creates a new World instance via the factory function. No state leaks between attempts.
- **Immediate retry.** A failed scenario is retried immediately, before moving on to the next scenario.
- **Only failures trigger retries.** Scenarios with Undefined, Pending, or Skipped status are not retried.
- **Final result counts.** Only the last attempt's outcome appears in the `RunResult`. If a scenario fails twice then passes on the third attempt, it counts as passed.
- **`RunSummary.retried` tracks retried scenarios.** This count includes any scenario that required more than one attempt, regardless of final outcome.

### Cucumber Messages

When sinks are attached, each attempt emits its own `TestCaseStarted` / `TestCaseFinished` envelope pair. The `TestCaseStarted` envelope includes an `attempt` field (0-indexed), and the `TestCaseFinished` envelope includes a `willBeRetried` flag indicating whether another attempt will follow.

---

## Dry-Run Mode

Dry-run mode validates that all steps have matching definitions without executing step handlers or case/step hooks. Before/after TestRun hooks
still execute.

```moonbit
let opts = @moonspec.RunOptions::new([
  @moonspec.FeatureSource::File("features/cart.feature"),
])
opts.dry_run(true)
let result = @moonspec.run(MyWorld::default, opts)
```

### Behavior

- **Matched steps** are reported as `Skipped("dry run")`.
- **Undefined steps** are reported as `Undefined` with generated snippets suggesting step definitions.
- **Case and step hooks** do not run. Before/after TestRun hooks still execute.
- **No retries** are attempted.

### Use Case: CI Validation

Dry-run mode is useful in CI pipelines to verify that all Gherkin steps have corresponding step definitions before committing to a full test run:

```moonbit
async test "step coverage check" {
  let opts = @moonspec.RunOptions::new([
    @moonspec.FeatureSource::File("features/cart.feature"),
    @moonspec.FeatureSource::File("features/checkout.feature"),
  ])
  opts.dry_run(true)
  // run_or_fail raises if any steps are undefined
  @moonspec.run_or_fail(MyWorld::default, opts) |> ignore
}
```

---

## Skipping Scenarios

### Skip Tags

Use the `@skip` or `@ignore` tag to skip a scenario entirely:

```gherkin
Feature: Payments

  @skip
  Scenario: Pay with cryptocurrency
    Given a crypto wallet
    When I pay with Bitcoin
    Then payment is processed

  @ignore("blocked by API vendor")
  Scenario: Pay with wire transfer
    Given a bank account
    When I initiate a wire transfer
    Then transfer is queued
```

Skipped scenarios do not execute step handlers or case/step hooks. The enclosing
run still executes its before/after TestRun hooks. The optional reason in parentheses (e.g., `@skip("not-ready")` or `@ignore("blocked")`) is propagated to results and Cucumber Messages output.

### Custom Skip Tags

By default, `@skip` and `@ignore` are recognized as skip tags. You can configure additional skip tags:

```moonbit
let opts = @moonspec.RunOptions::new([
  @moonspec.FeatureSource::File("features/payments.feature"),
])
opts.skip_tags(["@skip", "@ignore", "@wip"])
```

This can also be set in `moonspec.json5`:

```json5
{
  "skip_tags": ["@skip", "@ignore", "@wip"]
}
```

### Limitations

Gherkin tags cannot contain spaces. The tokenizer splits at whitespace, so tags like `@skip("not ready")` will not parse correctly. Use single-word or underscore-separated reasons instead:

```gherkin
# Good
@skip("not_ready")
@ignore("blocked_by_api")

# Bad — will not parse as expected
@skip("not ready")
```

### Skip Tags vs Tag Expressions

Skip tags and tag expressions serve different purposes and operate at different stages:

| Aspect | Tag expressions | Skip tags |
|--------|----------------|-----------|
| Purpose | Select which scenarios to run | Prevent execution of matched scenarios |
| When applied | During scenario selection (filtering) | After selection, before execution |
| Retry behavior | Filtered scenarios never enter the runner | Skipped scenarios bypass retry logic |
| API | `opts.tag_expr("@smoke")` | `opts.skip_tags(["@skip"])` |

Both can be used together. Tag expressions filter first, then skip tags are checked on the filtered set.

---

## Formatters

Formatters receive Cucumber Messages events during a test run and produce output in various formats. They implement the `MessageSink` trait.

### Pretty Formatter

Human-readable colored console output with pass/fail markers:

```moonbit
let fmt = @format.PrettyFormatter::new()
let opts = @moonspec.RunOptions::new([
  @moonspec.FeatureSource::File("features/cart.feature"),
])
opts.add_sink(fmt)
let result = @moonspec.run(MyWorld::default, opts)
println(fmt.output())
```

Disable colors for CI environments or file output:

```moonbit
let fmt = @format.PrettyFormatter::new(no_color=true)
```

Sample output:

```
Feature: Shopping Cart

  Scenario: Add item to cart
    ✓ Given an empty cart
    ✓ When I add "Laptop" to the cart
    ✓ Then the cart contains 1 item

1 scenario (1 passed)
```

### Messages Formatter

Standard Cucumber Messages in NDJSON (newline-delimited JSON) format for integration with external tools, reporting dashboards, and the Cucumber ecosystem:

```moonbit
let fmt = @format.MessagesFormatter::new()
let opts = @moonspec.RunOptions::new([
  @moonspec.FeatureSource::File("features/cart.feature"),
])
opts.add_sink(fmt)
let result = @moonspec.run(MyWorld::default, opts)
let ndjson = fmt.output() // each line is a JSON envelope
```

### JUnit Formatter

JUnit XML output for CI/CD systems (Jenkins, GitHub Actions, GitLab CI):

```moonbit
let fmt = @format.JUnitFormatter::new()
let opts = @moonspec.RunOptions::new([
  @moonspec.FeatureSource::File("features/cart.feature"),
])
opts.add_sink(fmt)
let result = @moonspec.run(MyWorld::default, opts)
let xml = fmt.output()
```

The XML follows the standard JUnit format:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<testsuites tests="3" failures="0">
  <testsuite name="Shopping Cart" tests="3">
    <testcase name="Add item to cart" classname="Shopping Cart"/>
    <testcase name="Remove item from cart" classname="Shopping Cart"/>
    <testcase name="Empty cart" classname="Shopping Cart"/>
  </testsuite>
</testsuites>
```

### Using Multiple Formatters

You can attach multiple sinks to a single run. Each receives the same stream of Cucumber Messages envelopes:

```moonbit
let pretty = @format.PrettyFormatter::new()
let messages = @format.MessagesFormatter::new()
let junit = @format.JUnitFormatter::new()

let opts = @moonspec.RunOptions::new([
  @moonspec.FeatureSource::File("features/cart.feature"),
])
opts.add_sink(pretty)
opts.add_sink(messages)
opts.add_sink(junit)

let result = @moonspec.run(MyWorld::default, opts)
println(pretty.output())  // console output
// messages.output()       // NDJSON for tooling
// junit.output()          // XML for CI
```

### Custom Sinks

Any type implementing the `MessageSink` trait can be used as a sink:

```moonbit
pub(open) trait MessageSink {
  on_message(Self, @cucumber_messages.Envelope) -> Unit
}
```

Register custom sinks with `opts.add_sink(sink)`.

---

## Report Output

Formatters can be configured with output destinations so results are automatically written when the run completes.

### Local Development

For local development, the default pretty formatter provides colored console output:

```json5
{
  "formatters": [
    { "type": "pretty", "output": "stdout" }
  ]
}
```

### CI/CD Integration

For CI pipelines, output JUnit XML alongside console output:

```json5
{
  "formatters": [
    { "type": "pretty", "output": "stderr" },
    { "type": "junit", "output": "reports/results.xml" }
  ]
}
```

### Cucumber Messages

For integration with Cucumber ecosystem tools, use the messages formatter:

```json5
{
  "formatters": [
    { "type": "messages", "output": "reports/messages.ndjson" }
  ]
}
```

---

## Running Tests

### Basic Invocation

moonspec tests are standard MoonBit tests. Run them with the `moon test` command targeting JavaScript:

```bash
moon test --target js
```

Async execution and parallel support work on `js`, `wasm` and `native`.
Root sync tests also work on `wasm-gc`.

### Feature Sources

moonspec supports multiple ways to load feature files:

```moonbit
// Load from the filesystem
let file_source = @moonspec.FeatureSource::File("features/cart.feature")

// Provide Gherkin text directly (useful for tests and dynamic content)
let text_source = @moonspec.FeatureSource::Text(
  "inline://cart.feature",
  #|Feature: Cart
  #|  Scenario: Add item
  #|    Given an empty cart
  #|    When I add "Laptop" to the cart
  #|    Then the cart contains 1 item
  ,
)
```

### Multi-Feature Runs

Pass multiple feature sources to run them together:

```moonbit
async test "all ecommerce features" {
  @moonspec.run_or_fail(
    EcomWorld::default,
    @moonspec.RunOptions::new([
      @moonspec.FeatureSource::File("features/cart.feature"),
      @moonspec.FeatureSource::File("features/checkout.feature"),
      @moonspec.FeatureSource::File("features/inventory.feature"),
    ]),
  )
  |> ignore
}
```

### `run` vs `run_or_fail`

Both facades provide result-returning and failure-reporting entry points:

| Function | Behavior on failure |
|----------|-------------------|
| `run_sync` or async `run` | Returns a `RunResult` with summary and per-scenario details |
| `run_or_fail_sync` or async `run_or_fail` | Raises a `MoonspecError` if any scenario fails, is undefined, or is pending |

Use `run_or_fail` in test functions where you want the test to fail on any non-passing scenario. Use `run` when you need to inspect results programmatically:

```moonbit
async test "check specific results" {
  let opts = @moonspec.RunOptions::new([
    @moonspec.FeatureSource::File("features/cart.feature"),
  ])
  let result = @moonspec.run(MyWorld::default, opts)
  assert_eq(result.summary.total_scenarios, 3)
  assert_eq(result.summary.passed, 3)
  assert_eq(result.summary.failed, 0)
}
```

### Combining Options

All options compose freely:

```moonbit
async test "full configuration example" {
  let pretty = @format.PrettyFormatter::new()
  let junit = @format.JUnitFormatter::new()

  let opts = @moonspec.RunOptions::new([
    @moonspec.FeatureSource::File("features/cart.feature"),
    @moonspec.FeatureSource::File("features/checkout.feature"),
  ])
  opts.tag_expr("@smoke and not @slow")
  opts.parallel(true)
  opts.max_concurrent(8)
  opts.retries(1)
  opts.skip_tags(["@skip", "@ignore", "@wip"])
  opts.add_sink(pretty)
  opts.add_sink(junit)

  @moonspec.run_or_fail(EcomWorld::default, opts) |> ignore
  println(pretty.output())
}
```
