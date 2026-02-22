# Parse-Once Pickle Pipeline Design

**Issue:** moonspec-1e8
**Date:** 2026-02-22
**Status:** Approved
**Follow-on:** moonspec-kyq (message-stream pipeline, blocked by this)

## Problem

The current execution pipeline parses feature files multiple times:

1. **Codegen phase** parses each `.feature` to extract structure for test generation.
2. **Runtime phase** re-parses the same content via `FeatureSource::Text` or `FeatureSource::File`.
3. **PerScenario codegen** embeds the full feature text as a string literal in each generated test — a feature with 10 scenarios duplicates the text 10 times.
4. **Parallel execution** independently parses each input per async task with no shared cache.

Additionally, the runner operates directly on `@gherkin.Feature` AST nodes, bypassing the Pickle compilation step that all canonical cucumber implementations use.

## Solution: Composable Pipeline with Pickle Compilation

Refactor the pipeline into distinct phases matching the canonical cucumber architecture:

```
Source inputs → FeatureCache → Pickle Compiler → PickleFilter → Runner → Results
                 (parse once)   (flatten/expand)   (tags/lines)   (execute)
```

Each phase is independently testable. The `cucumber-messages` package (v0.1.0) already defines all Pickle types.

## Phase 1: FeatureCache

A newtype wrapping `Map[String, @gherkin.Feature]` with controlled mutation. The `Map` type is available from `moonbitlang/core/builtin`.

```moonbit
struct FeatureCache {
  priv cache : Map[String, @gherkin.Feature]
}

fn FeatureCache::new() -> FeatureCache

// Loading — the only mutation path
fn FeatureCache::load_file(self, path: String) -> Unit!
fn FeatureCache::load_text(self, path: String, content: String) -> Unit!
fn FeatureCache::load_parsed(self, path: String, feature: @gherkin.Feature) -> Unit

// Read-only access
fn FeatureCache::get(self, path: String) -> @gherkin.Feature?
fn FeatureCache::features(self) -> Array[(String, @gherkin.Feature)]
fn FeatureCache::contains(self, path: String) -> Bool
fn FeatureCache::size(self) -> Int
```

Behaviors:
- `load_file` is idempotent — second call with same path is a no-op.
- `load_text` always overwrites — inline content may differ between calls.
- Parse errors are raised, not swallowed.
- No `remove` or `clear` — append-only for the duration of a run.

## Phase 2: Pickle Compiler

A function that transforms cached features into `@cucumber_messages.Pickle` instances:

```moonbit
fn compile_pickles(cache: FeatureCache) -> Array[@cucumber_messages.Pickle]
```

Compilation rules (per the cucumber spec):

1. **Regular Scenario** → 1 Pickle. Background steps prepended, tags inherited from Feature/Rule/Scenario. `astNodeIds = [scenarioNodeId]`.
2. **Scenario Outline + Examples** → 1 Pickle per Examples row. `<placeholder>` values interpolated into step text. `astNodeIds = [outlineNodeId, rowNodeId]`.
3. **Empty Scenarios** → no Pickle emitted.
4. **Rules** → scoped background inheritance (Rule background prepended to its children, Feature background prepended before that).

Each Pickle gets:
- `id` — generated unique identifier
- `uri` — cache key (file path)
- `name` — scenario name (interpolated for outlines)
- `language` — from the feature
- `steps` — `Array[PickleStep]` with `type_` (Context/Action/Outcome)
- `tags` — all inherited `PickleTag` entries
- `astNodeIds` — traceability to source AST

This replaces `expand_outline()` from `outline.mbt` and `collect_background_steps()` from `feature.mbt`.

## Phase 3: PickleFilter

Filtering operates on compiled pickles:

```moonbit
struct PickleFilter {
  tag_expression : TagExpression?
  scenario_names : Array[String]?
  uri_lines : Array[(String, Int)]?
}

fn PickleFilter::new() -> PickleFilter
fn PickleFilter::with_tags(self, expr: String) -> PickleFilter!
fn PickleFilter::with_names(self, names: Array[String]) -> PickleFilter
fn PickleFilter::with_lines(self, uri_lines: Array[(String, Int)]) -> PickleFilter
fn PickleFilter::apply(self, pickles: Array[@cucumber_messages.Pickle]) -> Array[@cucumber_messages.Pickle]
```

- **Tags**: reuses existing `TagExpression` parser and `matches()` from `tags.mbt`.
- **Names**: substring match against `Pickle.name`.
- **URI + line**: matches `Pickle.uri` and checks `astNodeIds` for line resolution.
- Multiple filters are AND'd.

## Phase 4: Runner (Builder API)

The runner only knows about Pickles:

```moonbit
struct Runner[W : World] {
  priv pickles : Array[@cucumber_messages.Pickle]
  priv parallel : Int
  priv factory : () -> W
}

fn Runner::new(factory: () -> W) -> Runner[W]
fn Runner::with_pickles(self, pickles: Array[@cucumber_messages.Pickle]) -> Runner[W]
fn Runner::with_parallel(self, max_concurrent: Int) -> Runner[W]
fn Runner::run(self) -> RunResult!
fn Runner::run_with_hooks(self) -> RunResult!  // W : World + Hooks
```

Per-Pickle execution:
1. `factory()` creates fresh World.
2. `StepRegistry::new()` + `World::register_steps(world, registry)`.
3. For each `PickleStep`: match via `registry.find_match(step.text)`, execute handler.
4. Skip remaining steps after first failure.
5. Collect `ScenarioResult` (now includes `pickle_id: String` for traceability).

**Convenience function** (wraps full pipeline for simple cases):

```moonbit
fn run(
  factory: () -> W,
  sources: Array[FeatureSource],
  tag_expr~: String = "",
  scenario_name~: String = "",
  parallel~: Int = 0
) -> RunResult!
```

## FeatureSource Rework

All variants now carry a path (no published consumers, clean replacement):

```moonbit
pub enum FeatureSource {
  Text(String, String)              // (path, content)
  File(String)                      // (path)
  Parsed(String, @gherkin.Feature)  // (path, feature)
}
```

`FeatureSource` is an input type for `FeatureCache`, not something the runner touches.

## Codegen Changes

**PerFeature mode** — unchanged, emits `FeatureSource::File(path)`.

**PerScenario mode** — stops embedding feature text. Emits `File(path)` with a scenario name filter:

```moonbit
async test "Feature: Login / Scenario: Valid credentials" {
  let result = @moonspec.run(
    MyWorld::default,
    [@moonspec.FeatureSource::File("features/login.feature")],
    scenario_name="Valid credentials"
  )
  assert_eq!(result.summary.failed, 0)
}
```

The cache ensures the feature is parsed once even when multiple tests reference the same file. Staleness detection via content hash (`// moonspec:hash:...`) stays.

## File Changes

**Deleted functions:**
- `resolve_feature()` from `runner/feature.mbt` (replaced by FeatureCache)
- `execute_feature_filtered()` from `runner/feature.mbt` (replaced by Runner)
- `collect_background_steps()` from `runner/feature.mbt` (moved to compiler)
- `expand_outline()` from `runner/outline.mbt` (moved to compiler)

**New files:**
- `runner/cache.mbt` — `FeatureCache` type
- `runner/compiler.mbt` — `compile_pickles()` function
- `runner/filter.mbt` — `PickleFilter` type

**Modified files:**
- `runner/results.mbt` — `FeatureSource` enum updated, `ScenarioResult` gains `pickle_id`
- `runner/run.mbt` — `run()` signature updated, internals refactored to pipeline
- `runner/parallel.mbt` — iterates Pickles instead of FeatureSources
- `codegen/codegen.mbt` — PerScenario stops embedding text, uses File + scenario name

**Test migration:**
- `FeatureSource::Text(content)` → `FeatureSource::Text("test://name", content)` across all `_wbtest.mbt` files
