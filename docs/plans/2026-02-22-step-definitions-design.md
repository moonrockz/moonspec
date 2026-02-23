# Design: Improved Step Definitions (moonspec-mlp)

> Aligns moonspec with cucumber ecosystem patterns for step definition composition, diagnostics, and error handling — without runtime reflection.

## Context

MoonBit lacks runtime reflection, similar to Rust. cucumber-rs solves step registration through proc macros + the `inventory` crate for distributed registration via linker sections. MoonBit lacks proc macros, but has custom attributes readable by external tooling at compile time.

moonspec already has:
- `World` trait with `register_steps(Self, StepRegistry)`
- Cucumber expression support (`{int}`, `{float}`, `{string}`, `{word}`) via `moonrockz/cucumber-expressions`
- `StepArg` enum with typed variants
- Per-scenario world isolation via `Default` construction
- `Hooks` trait for lifecycle management

This design adds first-class step definitions, composable step libraries, structured error handling, and undefined step diagnostics.

## Design Decisions

1. **First-class `StepDef` type** — step definitions become values you can inspect, test, and pass around, rather than side-effects of calling `s.given(pattern, handler)`. Aligns with cucumber-messages `StepDefinition` envelope type for future moonspec-kyq integration.

2. **`StepLibrary` trait with `ArrayView[StepDef]`** — libraries return an immutable view of their step definitions. `ArrayView` is MoonBit's canonical read-only slice: known size, random access, multi-pass iteration, no structural mutation.

3. **`StepRegistry.use_library`** — generic method `use_library[L : StepLibrary]` composes libraries. No `ToStepLibrary` conversion trait needed; the generic method handles dispatch.

4. **`MoonspecError` suberror hierarchy** — replaces ad-hoc `String?` error passing with structured, aggregated errors. Follows the `CompositeError` pattern already established in `moonrockz/gherkin`.

5. **Snippet generation + fuzzy matching** — undefined steps produce copy-paste snippets (matching cucumber-ruby/jvm/js ecosystem norm) plus "did you mean?" suggestions via Levenshtein distance (novel differentiator).

6. **`run!` throwing variant** — ergonomic test API that raises `MoonspecError` on any failure, replacing `assert_eq(result.summary.failed, 0)` boilerplate.

7. **Existing convenience methods preserved** — `s.given()`, `s.when()`, `s.then()`, `s.step()` stay with the same signatures, constructing `StepDef` internally.

## New Types

### StepDef

```moonbit
pub struct StepDef {
  keyword : StepKeyword
  pattern : String             // Cucumber expression: "I have {int} cucumbers"
  handler : StepHandler
  source  : StepSource?        // Optional: populated by codegen
}

pub enum StepKeyword {
  Given
  When
  Then
  Step  // matches any keyword
}

pub struct StepSource {
  uri  : String?    // file path
  line : Int?       // line number
}
```

Convenience constructors:

```moonbit
pub fn StepDef::given(pattern : String, handler : StepHandler, source~? : StepSource) -> StepDef
pub fn StepDef::when(pattern : String, handler : StepHandler, source~? : StepSource) -> StepDef
pub fn StepDef::then(pattern : String, handler : StepHandler, source~? : StepSource) -> StepDef
pub fn StepDef::step(pattern : String, handler : StepHandler, source~? : StepSource) -> StepDef
```

### StepLibrary Trait

```moonbit
pub(open) trait StepLibrary {
  steps(Self) -> ArrayView[StepDef]
}
```

Usage:

```moonbit
struct AuthSteps { world : MyWorld }

impl StepLibrary for AuthSteps with steps(self) {
  [
    StepDef::given("I am logged in", fn(_args) { self.world.logged_in = true }),
    StepDef::then("I should be authenticated", fn(_args) raise {
      assert_true!(self.world.logged_in)
    }),
  ][:]
}

impl World for MyWorld with register_steps(self, s) {
  s.use_library(AuthSteps::new(self))
  s.use_library(CalcSteps::new(self))
}
```

### MoonspecError Hierarchy

```moonbit
pub suberror MoonspecError {
  UndefinedStep(step~ : String, keyword~ : String, snippet~ : String,
                suggestions~ : Array[String])
  PendingStep(step~ : String, keyword~ : String, message~ : String)
  StepFailed(step~ : String, keyword~ : String, message~ : String)
  ScenarioFailed(scenario~ : String, feature~ : String,
                 errors~ : Array[MoonspecError])
  RunFailed(summary~ : String, errors~ : Array[MoonspecError])
}
```

Aggregation model:
- Step-level errors: `UndefinedStep`, `PendingStep`, `StepFailed`
- Scenario-level: `ScenarioFailed` collects step errors
- Run-level: `RunFailed` collects scenario errors

### StepMatchResult

```moonbit
pub enum StepMatchResult {
  Matched(StepDef, Array[StepArg])
  Undefined(step_text~ : String, keyword~ : String, snippet~ : String,
            suggestions~ : Array[String])
}
```

Replaces the old `Option[(StepHandler, Array[StepArg], String)]` from `find_match`.

## Registry Changes

`StepRegistry` internal storage changes from `Array[StepEntry]` to `Array[StepDef]`:

```moonbit
pub struct StepRegistry {
  steps : Array[StepDef]
  param_registry : ParamTypeRegistry
}

// Existing convenience methods (same signature, new internals)
pub fn given(self, pattern : String, handler : StepHandler) -> Unit
pub fn when(self, pattern : String, handler : StepHandler) -> Unit
pub fn then(self, pattern : String, handler : StepHandler) -> Unit
pub fn step(self, pattern : String, handler : StepHandler) -> Unit

// New: compose libraries
pub fn use_library[L : StepLibrary](self, library : L) -> Unit

// New: register a StepDef directly
pub fn register_def(self, step_def : StepDef) -> Unit

// Changed return type
pub fn find_match(self, text : String) -> StepMatchResult
```

## Executor Changes

The executor consumes `StepMatchResult` and carries diagnostics:

```moonbit
let status = match registry.find_match(step.text) {
  Matched(step_def, args) =>
    try {
      (step_def.handler.0)(args)
      StepStatus::Passed
    } catch {
      PendingStep(..) as e => StepStatus::Pending
      e => StepStatus::Failed(e.to_string())
    }
  Undefined(..) => StepStatus::Undefined
}
```

`StepResult` gains a diagnostic field:

```moonbit
pub struct StepResult {
  keyword : String
  text : String
  status : StepStatus
  diagnostic : MoonspecError?  // populated for Undefined/Pending/Failed
}
```

## Runner Changes

New throwing variant alongside existing non-throwing `run`:

```moonbit
// Existing: returns RunResult
pub async fn run[W : World](
  factory : () -> W,
  features : Array[FeatureSource],
  ...
) -> RunResult

// New: raises MoonspecError on any failure
pub async fn run![W : World](
  factory : () -> W,
  features : Array[FeatureSource],
  ...
) -> RunResult raise MoonspecError
```

The `run!` variant calls `run` internally, then inspects the result and raises `RunFailed` if any scenarios failed, with the full error tree.

## Undefined Step Diagnostics

### Snippet Generation

When a step is undefined, generate a copy-paste snippet:

```
? Given I have 5 bananas
  Undefined step. You can implement it with:

    s.given("I have {int} bananas", fn(args) {
      raise PendingStep(step="I have {int} bananas", keyword="Given",
                        message="TODO: implement step")
    })

  Did you mean?
    - "I have {int} cucumbers"
```

Smart snippet generation detects potential cucumber expression parameters:
- Integers in step text → suggest `{int}`
- Quoted strings → suggest `{string}`
- Decimal numbers → suggest `{float}`

### Fuzzy Matching

Levenshtein distance on normalized pattern text (replace `{int}`, `{string}`, etc. with placeholder tokens) against all registered steps. Returns top 3 matches within a reasonable distance threshold.

When `StepSource` is available (from codegen), suggestions include the source location.

## Cucumber Workflow

The design enables the standard cucumber development workflow:

1. **Write feature file** — describe behavior in Gherkin
2. **Run** → steps are **Undefined** with copy-paste snippets + suggestions
3. **Copy-paste snippet** → steps are **Pending** (raises `PendingStep`)
4. **Implement logic** → steps **Pass**

## Facade Re-exports

```moonbit
pub using @core {
  trait World,
  trait Hooks,
  trait StepLibrary,
  type StepRegistry,
  type StepDef,
  type StepArg,
  type StepKeyword,
  type StepSource,
  type StepMatchResult,
  suberror MoonspecError,
  type ScenarioInfo,
  type StepInfo,
}

pub using @runner {type FeatureSource, run, run_with_hooks}
```

## Files Modified/Created

| File | Action |
|------|--------|
| `src/core/step_def.mbt` | **Create** — StepDef, StepKeyword, StepSource, constructors |
| `src/core/step_library.mbt` | **Create** — StepLibrary trait |
| `src/core/error.mbt` | **Create** — MoonspecError suberror hierarchy |
| `src/core/registry.mbt` | **Modify** — use StepDef internally, add use_library, register_def, new find_match |
| `src/core/types.mbt` | **Modify** — add StepMatchResult, remove StepEntry |
| `src/runner/executor.mbt` | **Modify** — consume StepMatchResult, carry diagnostics, catch PendingStep |
| `src/runner/run.mbt` | **Modify** — add run! throwing variant |
| `src/runner/snippet.mbt` | **Create** — snippet generation logic |
| `src/runner/suggest.mbt` | **Create** — Levenshtein fuzzy matching |
| `src/lib.mbt` | **Modify** — re-export new types |
| `src/codegen/codegen.mbt` | **Modify** — generated tests use run! |
| Test files | **Modify** — update to new APIs, add StepLibrary and error hierarchy tests |

## Out of Scope

| Feature | Deferred to | Reason |
|---------|-------------|--------|
| Custom parameter types (`{color}`, `{animal}`) | Future issue | Requires cucumber-expressions library changes |
| DataTable / DocString support | Future issue | Requires StepArg extension + gherkin parser changes |
| Attribute-based registration (`#moonspec.given`) | moonspec-sgg | Codegen will generate into StepLibrary/StepDef API |
| Cucumber-messages StepDefinition emission | moonspec-kyq | Will project from StepDef → protocol type |
| Ambiguous step detection (multiple matches) | Future issue | Current "first match wins" stays |

## Verification

```bash
mise run test:unit    # All tests pass
moon check --all      # Type checks
```

Key tests:
- StepLibrary composition: multiple libraries registered, steps from all are available
- StepDef constructors: given/when/then/step create correct keyword
- Undefined step diagnostics: snippet generated, suggestions returned
- PendingStep: raised in handler → StepStatus::Pending
- MoonspecError aggregation: RunFailed contains ScenarioFailed contains step errors
- run! variant: raises on failure, returns RunResult on success
- Backward compat: existing given/when/then/step convenience methods still work
