# Refactor: Introduce World and Hooks Traits

> **Note:** Save this plan to `docs/plans/2026-02-22-world-traits-refactor.md` before starting implementation.

## Context

The [design plan](docs/plans/2026-02-21-moonspec-design.md) specified core traits for per-scenario state isolation. The implementation skipped these, using closure captures over `mut` variables instead. This means no per-scenario isolation, no lifecycle hooks, and unsafe parallel execution.

Following [cucumber-rs's pattern](https://cucumber-rs.github.io/cucumber/main/quickstart.html), we use MoonBit's built-in `Default` trait for world construction (via `derive(Default)`) and a `World` trait for step registration.

No external consumers exist — we replace the existing API directly.

## Target API

```moonbit
// User imports: moonrockz/moonspec
struct MyWorld { mut cucumbers : Int } derive(Default)

impl @moonspec.World for MyWorld with register_steps(self, s) {
  s.given("I have {int} cucumbers", fn(args) {
    match args[0] { @moonspec.IntArg(n) => self.cucumbers = n | _ => () }
  })
  s.then("I should have {int} cucumbers", fn(args) raise {
    match args[0] { @moonspec.IntArg(n) => assert_eq(self.cucumbers, n) | _ => () }
  })
}

// Running:
async test "BDD" {
  let result = @moonspec.run[MyWorld]([feature_content])
  assert_eq(result.summary.passed, 2)
}
```

Users import just `moonrockz/moonspec` — no need to know about `core`/`runner` sub-packages. A top-level facade re-exports key types via `pub typealias` and `pub fnalias`.

Per scenario the runner does: `W::default()` → `world.register_steps(registry)` → execute steps.

## Design Decisions

1. **`Default` for construction** — `derive(Default)` zero-inits all fields, exactly like cucumber-rs uses `Default::default()`. No custom `new() -> Self` trait needed.
2. **`World` trait = step registration** — single trait with `register_steps(Self, StepRegistry) -> Unit`. World captured in closures via `self`.
3. **`StepRegistry` stays non-generic** — world is captured in closures inside `register_steps`, handler signature unchanged.
4. **`Hooks` trait is separate with defaults** — `run` for no-hooks path, `run_with_hooks` for hooks. All hook methods default to no-op.
5. **Hooks use `String?` for results** — `None` = success, `Some(msg)` = failure. Avoids moving enums across packages.
6. **No backward compat** — replace existing signatures directly.
7. **Top-level facade** — `src/lib.mbt` uses `pub using` to re-export key symbols so users import just `moonrockz/moonspec`.

## Implementation Steps

### Step 0: Create top-level facade package

Create [src/moon.pkg.json](src/moon.pkg.json):
```json
{ "import": ["moonrockz/moonspec/core", "moonrockz/moonspec/runner"] }
```

Create [src/lib.mbt](src/lib.mbt) using MoonBit's [`pub using`](https://docs.moonbitlang.com/en/latest/language/packages.html#using) re-export syntax:
```moonbit
pub using @core {trait World, trait Hooks, type StepRegistry, type StepArg, type ScenarioInfo, type StepInfo}
pub using @runner {run, run_with_hooks}
```

### Step 1: Add World trait to `src/core/`

Create [src/core/world.mbt](src/core/world.mbt):

```moonbit
///|
/// Step registration trait. Users implement this on their world struct.
/// Called once per scenario with a fresh Default-constructed instance.
/// Closures capture `self` to share world state between steps.
pub(open) trait World {
  register_steps(Self, StepRegistry) -> Unit
}
```

### Step 2: Add Hooks trait to `src/core/`

Create [src/core/hooks.mbt](src/core/hooks.mbt):

```moonbit
///|
pub(open) trait Hooks {
  before_scenario(Self, ScenarioInfo) -> Unit raise Error = _
  after_scenario(Self, ScenarioInfo, String?) -> Unit raise Error = _
  before_step(Self, StepInfo) -> Unit raise Error = _
  after_step(Self, StepInfo, String?) -> Unit raise Error = _
}

impl Hooks with before_scenario(_self, _info) { () }
impl Hooks with after_scenario(_self, _info, _result) { () }
impl Hooks with before_step(_self, _info) { () }
impl Hooks with after_step(_self, _info, _result) { () }
```

Following the [Formatter default pattern](src/format/formatter.mbt).

### Step 3: Replace `execute_feature_filtered` in runner

Modify [src/runner/feature.mbt](src/runner/feature.mbt):

```moonbit
pub fn execute_feature_filtered[W : Default + @core.World](
  content : String,
  tag_expr~ : String,
) -> FeatureResult raise Error
```

Per-scenario, replace `execute_scenario(registry, ...)` with:
```moonbit
let world : W = W::default()
let registry = @core.StepRegistry::new()
@core.World::register_steps(world, registry)
execute_scenario(registry, ...)
```

`execute_feature` gets the same treatment. The `registry` parameter is removed from both — it's created internally per scenario now.

### Step 4: Replace `run()` and `run_sequential`

Modify [src/runner/run.mbt](src/runner/run.mbt):

```moonbit
pub async fn run[W : Default + @core.World](
  features : Array[String],
  tag_expr? : String = "",
  parallel? : Int = 0,
) -> RunResult
```

`run_sequential` becomes:
```moonbit
fn run_sequential[W : Default + @core.World](
  features : Array[String],
  tag_expr~ : String,
) -> Array[FeatureResult] raise Error
```

`compute_summary` unchanged.

### Step 5: Replace `run_parallel`

Modify [src/runner/parallel.mbt](src/runner/parallel.mbt):

```moonbit
async fn run_parallel[W : Default + @core.World](
  features : Array[String],
  tag_expr~ : String,
  max_concurrent~ : Int,
) -> Array[FeatureResult]
```

Each async task calls `execute_feature_filtered[W](content, tag_expr~)` — per-scenario world isolation makes parallel safe.

### Step 6: Add hooks-aware variants

Add to [src/runner/executor.mbt](src/runner/executor.mbt):

```moonbit
pub fn execute_scenario_with_hooks[W : @core.Hooks](
  world : W,
  registry : @core.StepRegistry,
  feature_name~ : String,
  scenario_name~ : String,
  tags~ : Array[String],
  steps~ : Array[(String, String)],
) -> ScenarioResult
```

Add `run_with_hooks[W : Default + @core.World + @core.Hooks]` to [run.mbt](src/runner/run.mbt) and corresponding feature/parallel variants.

### Step 7: Update all existing tests

All test files that call `run(registry, ...)` or `execute_feature_filtered(registry, ...)` need updating:

- [src/runner/e2e_wbtest.mbt](src/runner/e2e_wbtest.mbt) — define `CalcWorld` struct, impl World, use `run[CalcWorld]`
- [src/runner/run_wbtest.mbt](src/runner/run_wbtest.mbt) — update run tests
- [src/runner/feature_wbtest.mbt](src/runner/feature_wbtest.mbt) — update feature tests
- [src/runner/parallel_wbtest.mbt](src/runner/parallel_wbtest.mbt) — update parallel tests
- [src/runner/executor_wbtest.mbt](src/runner/executor_wbtest.mbt) — executor tests keep `StepRegistry` (executor doesn't change)
- [src/runner/filter_wbtest.mbt](src/runner/filter_wbtest.mbt) — update if it calls feature functions
- [src/runner/background_wbtest.mbt](src/runner/background_wbtest.mbt) — update if it calls feature functions

### Step 8: Add new isolation + hooks tests

- **Isolation test**: Two scenarios — first sets world state to 42, second asserts it starts at 0 (default). Proves fresh world per scenario.
- **Parallel isolation**: Same with `parallel=2`.
- **Hook ordering**: Track hook calls in array on world, verify before_scenario → before_step → after_step → after_scenario.
- **Hook error**: `before_scenario` raises → scenario Failed, steps Skipped.

## Files Modified/Created

| File | Action |
|------|--------|
| [src/moon.pkg.json](src/moon.pkg.json) | **Create** — top-level facade package |
| [src/lib.mbt](src/lib.mbt) | **Create** — re-exports via `pub using` |
| [src/core/world.mbt](src/core/world.mbt) | **Create** — World trait |
| [src/core/hooks.mbt](src/core/hooks.mbt) | **Create** — Hooks trait with defaults |
| [src/runner/run.mbt](src/runner/run.mbt) | **Modify** — replace `run()` + add `run_with_hooks()` |
| [src/runner/feature.mbt](src/runner/feature.mbt) | **Modify** — replace `execute_feature_filtered` |
| [src/runner/parallel.mbt](src/runner/parallel.mbt) | **Modify** — replace `run_parallel` |
| [src/runner/executor.mbt](src/runner/executor.mbt) | **Modify** — add `execute_scenario_with_hooks` (existing `execute_scenario` unchanged) |
| [src/runner/e2e_wbtest.mbt](src/runner/e2e_wbtest.mbt) | **Modify** — rewrite with World trait API |
| [src/runner/run_wbtest.mbt](src/runner/run_wbtest.mbt) | **Modify** — update tests |
| [src/runner/feature_wbtest.mbt](src/runner/feature_wbtest.mbt) | **Modify** — update tests |
| [src/runner/parallel_wbtest.mbt](src/runner/parallel_wbtest.mbt) | **Modify** — update tests |
| [src/runner/filter_wbtest.mbt](src/runner/filter_wbtest.mbt) | **Modify** — update if needed |
| [src/runner/background_wbtest.mbt](src/runner/background_wbtest.mbt) | **Modify** — update if needed |

## Future Enhancement: Attribute-Based Step Registration

MoonBit supports [custom attributes](https://docs.moonbitlang.com/en/latest/language/attributes.html) that are compile-time only (no runtime reflection), readable by external tools via source parsing. This enables a cucumber-rs-style attribute API as a future enhancement.

### Target Developer Experience

**Basic (using `derive(Default)`):**
```moonbit
struct MyWorld { mut cucumbers : Int } derive(Default)

#moonspec.given("I have {int} cucumbers")
fn set_cucumbers(self : MyWorld, count : Int) -> Unit {
  self.cucumbers = count
}

#moonspec.when("I eat {int} cucumbers")
fn eat_cucumbers(self : MyWorld, count : Int) -> Unit {
  self.cucumbers = self.cucumbers - count
}

#moonspec.then("I should have {int} cucumbers")
fn check_cucumbers(self : MyWorld, count : Int) -> Unit raise Error {
  assert_eq(self.cucumbers, count)
}
```

**Custom constructor (like cucumber-rs `#[world(init = ...)]`):**
```moonbit
#moonspec.world(init = Self::new)
struct AnimalWorld {
  mut cat : Cat
}

fn AnimalWorld::new() -> AnimalWorld {
  { cat: Cat::new(hungry=true) }
}
```

When `#moonspec.world(init = ...)` is present, codegen uses the specified constructor instead of `Default::default()`. This supports cases where zero-initialization isn't sufficient (e.g., initializing with non-default values, connecting to test databases, etc.).

### How It Works

1. **Codegen scans source files** — `moonspec gen` parses `.mbt` files looking for `#moonspec.given`, `#moonspec.when`, `#moonspec.then` attributes on functions
2. **Extracts metadata** — function name, Cucumber Expression pattern from attribute, parameter types, the World type from `self` parameter
3. **Generates `register_steps` impl** — auto-generates the `impl World for MyWorld with register_steps(self, s) { ... }` block, wiring attribute-annotated functions as step handlers with type-safe argument extraction
4. **Runtime API unchanged** — the generated code calls `s.given(pattern, fn(args) { ... })` internally. The World trait's `register_steps` remains the single runtime registration mechanism.

### Design Constraints for Current Work

- The World trait's `register_steps` method MUST remain the single runtime registration point — attributes compile down to it
- Step handler closures MUST capture `self` (the world) — this is what attribute-annotated methods naturally do
- `StepArg` extraction logic should be reusable by codegen (it already exists in `StepArg::from_param`)

### Follow-On Steps

This feature should be taken through the speckit specify process (`/speckit-specify`) as a separate feature when ready. Key areas to spec:

1. **Attribute parsing** — extend `moonspec gen` to scan `.mbt` source files for `#moonspec.*` attributes (requires MoonBit source parser or AST access)
2. **Type-safe argument mapping** — map function parameter types (`Int`, `String`, `Double`) to Cucumber Expression parameter types (`{int}`, `{string}`, `{float}`) automatically
3. **World type discovery** — infer the World struct from the `self` parameter type
4. **Custom constructor** — support `#moonspec.world(init = Self::new)` attribute on the World struct for cases where `Default::default()` isn't sufficient (like cucumber-rs's `#[world(init = ...)]`). Codegen generates a factory function using the specified constructor instead of `W::default()`
5. **Conflict detection** — warn when both manual `register_steps` and attributes exist for the same World type
6. **Incremental generation** — only regenerate when source files change (extend existing hash-based staleness detection)

## Verification

```bash
mise run test:unit    # All tests pass
moon check --all      # Type checks
```

Key: the isolation test must prove state does NOT leak between scenarios.
