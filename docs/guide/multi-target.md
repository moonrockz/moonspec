# One setup across targets

Define your World, steps, hooks and runtime settings once, then let the local
generator create separate sync and async test packages. This is an unreleased
pre-1.0 feature. Use the checkout CLI and runtime, as in the runnable
[multi-target example](../../examples/multi-target/). Published 0.11.0 does not
provide this contract, and no supporting registry policy release is assumed.

## Select execution by target

Scalar `execution: "async"` remains the default. Scalar `"sync"` keeps ordinary
same-package test generation. Existing scalar grouping and visibility choices
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

## Keep the shared package portable

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

## Hierarchy, suites and CLI precedence

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
`SyncExecutionError::ParallelNotSupported` before factories, hooks or events;
it never silently downgrades to sequential execution.

## Generate and regenerate

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

Generated per-package rules declare local outputs. They run the local CLI on
`PATH` with validated `--refresh-output` paths so Moon discovers changed test
counts. This refresh is for generated rules. Keep the manifest and generated
contents intact. Feature-body edits and existing grouping-config edits
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

## Source API migration

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
